class_name DaySweep
extends RefCounted
## The day sweep gate (engine ticket 29): a Poligon's day sampled every few minutes and checked in
## numbers for what the human used to catch by eye (tickets 11 and 13): waves, jumps and pulsing of
## the light. A frame keeps, per sampled pixel, the levelled light (the part A′ puts on levels,
## before exposure), the artificial light and the sun's light; the rules compare frames.
## DaySweepSampler reads the frames on the GPU. Logic tests: test/tools/test_day_sweep.gd; the gate:
## test/engine_poligons/test_day_sweep_gpu.gd.

## A pixel's levelled light changed level when it moved by more than this share: one A′ level is
## 2^0.5 = +41 % (or −29 %), while the readback (half floats, the smooth sky subtracted) is off by
## well under 1 %; a level always gives exactly the same value, so between levels nothing moves.
const LEVEL_CHANGE: float = 0.1
## ... and by more than this share of the pixel's whole light: less is not visible (under 1 % of a
## pixel's light, below 3 of 256 codes even at full white), and the readback's half floats (0.05 %
## of the styled light, again of the sky subtracted from it) stay well below.
const VISIBLE_SHARE: float = 0.01
## Below this the levelled light is noise of the smooth sky's subtraction (lux before exposure).
const LEVELLED_MIN_LUX: float = 0.05
## Pixels a source lights: at least this much artificial light (lux), and the sun under
## NO_SUN_SHARE of it (the sun on the same levels would move them by itself).
const SOURCE_LIT_LUX: float = 1.0
const NO_SUN_SHARE: float = 0.001
## A frame step outside source switching and twilight may change the level of at most this share of
## the levelled pixels (see LARGE_AREA_MIN_PIXELS). Measured on the street: the sun's moving shadows
## and surfaces of other slopes crossing their levels one after another change 2–14 % per 10 min; a
## whole sunlit field crossing a level boundary at once, what the eye sees as a jump, 58–100 %.
const LARGE_AREA_SHARE: float = 0.25
## A large change whose pixels are this share lit mostly by the sun is a sun jump (rule SUN_JUMP).
const SUN_JUMP_SHARE: float = 0.9
## The rule name of a large change made by the sun: its light crossing a level boundary over a whole
## sunlit field at once (A′ grid at fixed lux, ticket 13). Known on the street, engine ticket 30.
const SUN_JUMP: String = "sun jump"
## Fewer changed pixels than this are local whatever their share (a frame with few lit pixels).
const LARGE_AREA_MIN_PIXELS: int = 200
## Twilight: the sun this close to the horizon (degrees, either frame) may change large areas: it
## comes out from below the horizon and its levels appear.
const TWILIGHT_ELEVATION: float = 3.0
## Share of the pixels that may change level with nothing changing their light: the artificial
## channel is stored in half floats and its last bit flips between hours, so a pixel exactly on a
## level boundary in a dither seam swaps (measured on the street: ≤ 0.05 % of the lamps' pixels).
const JITTER_SHARE: float = 0.001
## Pulsing: a pixel's level goes and comes back within this many frame steps.
const PULSE_FRAMES: int = 3
## A source group changing in this many frame steps in a row ramps its light (ticket 13's windows:
## half an hour, three steps of 10 min).
const RAMP_STEPS: int = 3
## Relative tolerance of the day state's monotonic check (float rounding).
const MONOTONIC_TOLERANCE: float = 1e-4
## Light of the source groups is the same in two frames within this (colour × lux).
const SAME_LIGHT: float = 1e-4

## The level change of a pixel between two frames.
enum Change { NONE, UP, DOWN }
## How the source groups' light changes between two frames: not at all, as a switch (constant
## before and after), or as a ramp over several frames (its bands crawl).
enum SourceChange { NONE, SWITCH, RAMP }


## One hour of the swept day.
class Frame:
	extends RefCounted
	var hour: float = 0.0
	var sun_elevation: float = 0.0
	var exposure: float = 1.0
	## Open-ground light before exposure (lux).
	var open_lux: float = 0.0
	## Colour × lux of each source group.
	var source_lights: Array[Color] = []
	## Per sampled pixel (row by row, `size`), four floats: the levelled light, the artificial light,
	## the sun's light and the whole styled light (lux before exposure).
	var data: PackedFloat32Array = PackedFloat32Array()

	func levelled(index: int) -> float:
		return data[index * 4]

	func artificial(index: int) -> float:
		return data[index * 4 + 1]

	func sun(index: int) -> float:
		return data[index * 4 + 2]

	func total(index: int) -> float:
		return data[index * 4 + 3]

	func pixel_count() -> int:
		return data.size() / 4


## What a rule found, with the hour and the place (Location pixels).
class Finding:
	extends RefCounted
	var rule: String = ""
	var hour: float = 0.0
	var place: Rect2i = Rect2i()
	var pixels: int = 0
	var description: String = ""

	func _to_string() -> String:
		var where: String = ""
		if place.has_area():
			where = " at x %d…%d, y %d…%d" % [place.position.x, place.end.x, place.position.y, place.end.y]
		return "%s %s: %s%s" % [DaySweep.clock(hour), rule, description, where]


## Sampled pixels per row and rows.
var size: Vector2i = Vector2i.ZERO
## Every `stride`-th buffer pixel each way.
var stride: int = 1
## The Location pixel of the first buffer pixel.
var origin_px: Vector2i = Vector2i.ZERO
var frames: Array[Frame] = []


static func clock(hour: float) -> String:
	var minutes: int = roundi(fposmod(hour, DayState.DAY_H) * 60.0)
	return "%02d:%02d" % [minutes / 60, minutes % 60]


## Sets the sampling for a buffer of `buffer_size` pixels starting at the Location pixel `origin`.
func prepare(buffer_size: Vector2i, origin: Vector2i, every: int) -> void:
	stride = maxi(every, 1)
	origin_px = origin
	size = Vector2i(maxi(buffer_size.x / stride, 1), maxi(buffer_size.y / stride, 1))
	frames.clear()


## Writes the swept frames to a file (to try the rules again without sweeping the day).
func save(path: String) -> Error:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var rows: Array = []
	for frame: Frame in frames:
		rows.append([frame.hour, frame.sun_elevation, frame.exposure, frame.open_lux, frame.source_lights,
				frame.data])
	file.store_var([size, stride, origin_px, rows])
	return OK


## A sweep written by `save` (null when the file cannot be read).
static func load_from(path: String) -> DaySweep:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var data: Array = file.get_var()
	var sweep: DaySweep = DaySweep.new()
	sweep.size = data[0]
	sweep.stride = data[1]
	sweep.origin_px = data[2]
	var rows: Array = data[3]
	for row: Array in rows:
		var frame: Frame = Frame.new()
		frame.hour = row[0]
		frame.sun_elevation = row[1]
		frame.exposure = row[2]
		frame.open_lux = row[3]
		var lights: Array = row[4]
		frame.source_lights.assign(lights)
		frame.data = row[5]
		sweep.frames.append(frame)
	return sweep


## Every rule over the swept frames (the day wraps: the last frame is followed by the first).
func check() -> Array[Finding]:
	var findings: Array[Finding] = []
	findings.append_array(check_monotonic())
	var changes: Array[PackedByteArray] = []
	for index: int in frames.size():
		changes.append(level_changes(frames[index], frames[(index + 1) % frames.size()]))
	for index: int in frames.size():
		var first: Frame = frames[index]
		var second: Frame = frames[(index + 1) % frames.size()]
		var sources: SourceChange = source_change(index)
		if sources != SourceChange.SWITCH:
			var standing: Finding = check_sources_stand(first, second, changes[index], sources == SourceChange.RAMP)
			if standing != null:
				findings.append(standing)
		if sources != SourceChange.SWITCH and not is_twilight(first, second):
			var large: Finding = check_local(first, second, changes[index])
			if large != null:
				findings.append(large)
	findings.append_array(check_pulsing(changes))
	return findings


## Exposure only falls from the darkest frame to the brightest and only rises after it, and the
## open-ground light the other way round (night → the brightest minute → night).
func check_monotonic() -> Array[Finding]:
	var findings: Array[Finding] = []
	if frames.size() < 3:
		return findings
	var brightest: int = 0
	for index: int in frames.size():
		if frames[index].exposure < frames[brightest].exposure:
			brightest = index
	var darkest: int = 0
	for index: int in frames.size():
		if frames[index].exposure > frames[darkest].exposure:
			darkest = index
	# Walk the day from the darkest frame: brightening up to the brightest, darkening after it.
	var brightening: bool = true
	for step: int in range(1, frames.size() + 1):
		var previous: Frame = frames[(darkest + step - 1) % frames.size()]
		var current: Frame = frames[(darkest + step) % frames.size()]
		if brightening:
			if current.exposure > previous.exposure * (1.0 + MONOTONIC_TOLERANCE):
				findings.append(_finding("monotonic", current.hour, Rect2i(), 0,
						"the exposure opens again (%.5f → %.5f) before the brightest frame %s" % [
							previous.exposure, current.exposure, clock(frames[brightest].hour)]))
			if current.open_lux < previous.open_lux * (1.0 - MONOTONIC_TOLERANCE):
				findings.append(_finding("monotonic", current.hour, Rect2i(), 0,
						"open ground darkens (%.3f → %.3f lx) before the brightest frame" % [previous.open_lux, current.open_lux]))
		else:
			if current.exposure < previous.exposure * (1.0 - MONOTONIC_TOLERANCE):
				findings.append(_finding("monotonic", current.hour, Rect2i(), 0,
						"the exposure shuts again (%.5f → %.5f) after the brightest frame" % [previous.exposure, current.exposure]))
			if current.open_lux > previous.open_lux * (1.0 + MONOTONIC_TOLERANCE):
				findings.append(_finding("monotonic", current.hour, Rect2i(), 0,
						"open ground brightens (%.3f → %.3f lx) after the brightest frame" % [previous.open_lux, current.open_lux]))
		if (darkest + step) % frames.size() == brightest:
			brightening = false
	return findings


## Per sampled pixel whether its levelled light went up a level, down, or stayed.
func level_changes(first: Frame, second: Frame) -> PackedByteArray:
	var changes: PackedByteArray = PackedByteArray()
	changes.resize(first.pixel_count())
	for index: int in changes.size():
		var a: float = first.data[index * 4]
		var b: float = second.data[index * 4]
		var high: float = maxf(a, b)
		if high < LEVELLED_MIN_LUX or absf(b - a) <= LEVEL_CHANGE * high \
				or absf(b - a) <= VISIBLE_SHARE * maxf(first.data[index * 4 + 3], second.data[index * 4 + 3]):
			continue
		changes[index] = Change.UP if b > a else Change.DOWN
	return changes


## How the source groups' light changes between frame `index` and the next. A switch shorter than
## the frame step lands in at most two steps (a lamp switching within a minute, sampled in the middle
## of it); a group changing in RAMP_STEPS steps in a row ramps.
func source_change(index: int) -> SourceChange:
	var count: int = frames.size()
	var result: SourceChange = SourceChange.NONE
	for group: int in frames[index].source_lights.size():
		if not _group_changes(group, index):
			continue
		var run: int = 1
		var back: int = 1
		while back < RAMP_STEPS and _group_changes(group, (index - back + count) % count):
			run += 1
			back += 1
		var forward: int = 1
		while forward < RAMP_STEPS and _group_changes(group, (index + forward) % count):
			run += 1
			forward += 1
		if run >= RAMP_STEPS:
			return SourceChange.RAMP
		result = SourceChange.SWITCH
	return result


func _group_changes(group: int, index: int) -> bool:
	var next: Frame = frames[(index + 1) % frames.size()]
	return not _same(frames[index].source_lights[group], next.source_lights[group])


func is_twilight(first: Frame, second: Frame) -> bool:
	return absf(first.sun_elevation) <= TWILIGHT_ELEVATION or absf(second.sun_elevation) <= TWILIGHT_ELEVATION \
			or signf(first.sun_elevation) != signf(second.sun_elevation)


## Outside switching, the pixels the sources light (without the sun) keep their level: with constant
## light the bands of a lamp's pool stand still; a source ramping its light moves them (`ramp`).
func check_sources_stand(first: Frame, second: Frame, changes: PackedByteArray, ramp: bool = false) -> Finding:
	var moved: PackedInt32Array = PackedInt32Array()
	var lit: int = 0
	for index: int in changes.size():
		if not _source_lit(first, index) or not _source_lit(second, index):
			continue
		lit += 1
		if changes[index] != Change.NONE:
			moved.append(index)
	if moved.size() <= JITTER_SHARE * lit:
		return null
	var cause: String = "a source ramps its light over several frames (switch it at once)" if ramp 			else "constant source light; levels anchored to something that changes?"
	return _finding("sources stand", second.hour, _place(moved), moved.size(),
			"%d px lit by sources changed level, the bands crawl: %s" % [moved.size(), cause])


## Outside switching and twilight a frame step changes the level of a small share of the levelled
## pixels only.
func check_local(first: Frame, second: Frame, changes: PackedByteArray) -> Finding:
	var lit: int = 0
	var changed: PackedInt32Array = PackedInt32Array()
	var sunlit: int = 0
	for index: int in changes.size():
		if maxf(first.data[index * 4], second.data[index * 4]) >= LEVELLED_MIN_LUX:
			lit += 1
		if changes[index] != Change.NONE:
			changed.append(index)
			if maxf(first.data[index * 4 + 2], second.data[index * 4 + 2]) > maxf(first.data[index * 4 + 1], second.data[index * 4 + 1]):
				sunlit += 1
	if changed.size() < LARGE_AREA_MIN_PIXELS or changed.size() <= LARGE_AREA_SHARE * lit:
		return null
	var share: float = 100.0 * changed.size() / maxf(lit, 1.0)
	if sunlit >= SUN_JUMP_SHARE * changed.size():
		return _finding(SUN_JUMP, second.hour, _place(changed), changed.size(),
				"%.0f %% of the levelled pixels, lit mostly by the sun, changed level in one step (the sun's light crossed a level boundary everywhere at once)" % share)
	return _finding("local change", second.hour, _place(changed), changed.size(),
			"%.0f %% of the levelled pixels changed level in one step outside switching and twilight (a wave or a ramp?)" % share)


## A pixel going up and back down (or down and back up) within PULSE_FRAMES steps is pulsing, unless
## its light with levels (sun and sources) did the same: a thin shadow passing over it.
func check_pulsing(changes: Array[PackedByteArray]) -> Array[Finding]:
	var findings: Array[Finding] = []
	var count: int = changes.size()
	for start: int in count:
		var pulsing: PackedInt32Array = PackedInt32Array()
		var lit: int = 0
		var first: PackedByteArray = changes[start]
		var before: Frame = frames[start]
		var after: Frame = frames[(start + 1) % count]
		for index: int in first.size():
			if maxf(before.data[index * 4], after.data[index * 4]) >= LEVELLED_MIN_LUX:
				lit += 1
			var change: int = first[index]
			if change == Change.NONE or _input_moved(before, after, index, change):
				continue
			var back: int = Change.DOWN if change == Change.UP else Change.UP
			for step: int in range(1, PULSE_FRAMES):
				var at: int = (start + step) % count
				if changes[at][index] == back:
					pulsing.append(index)
					break
		if pulsing.size() > JITTER_SHARE * lit:
			findings.append(_finding("pulsing", after.hour, _place(pulsing), pulsing.size(),
					"%d px change level and come back within %d steps while their light does not" % [pulsing.size(), PULSE_FRAMES]))
	return findings


## Whether the light with levels (the sun and the artificial light) moved the way the level did.
func _input_moved(first: Frame, second: Frame, index: int, change: int) -> bool:
	var a: float = first.data[index * 4 + 1] + first.data[index * 4 + 2]
	var b: float = second.data[index * 4 + 1] + second.data[index * 4 + 2]
	if absf(b - a) <= VISIBLE_SHARE * maxf(a, b):
		return false
	return (b > a) == (change == Change.UP)


func _source_lit(frame: Frame, index: int) -> bool:
	var artificial: float = frame.data[index * 4 + 1]
	return artificial >= SOURCE_LIT_LUX and frame.data[index * 4 + 2] <= NO_SUN_SHARE * artificial


## The Location-pixel box of sampled pixels.
func _place(indices: PackedInt32Array) -> Rect2i:
	var low: Vector2i = Vector2i(size.x, size.y)
	var high: Vector2i = Vector2i(-1, -1)
	for index: int in indices:
		var cell: Vector2i = Vector2i(index % size.x, index / size.x)
		low = low.min(cell)
		high = high.max(cell)
	return Rect2i(origin_px + low * stride, (high - low + Vector2i.ONE) * stride)


func _finding(rule: String, hour: float, place: Rect2i, pixels: int, description: String) -> Finding:
	var finding: Finding = Finding.new()
	finding.rule = rule
	finding.hour = hour
	finding.place = place
	finding.pixels = pixels
	finding.description = description
	return finding


static func _same(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) <= SAME_LIGHT and absf(a.g - b.g) <= SAME_LIGHT and absf(a.b - b.b) <= SAME_LIGHT
