class_name DaySweep
extends RefCounted
## The day sweep gate (engine ticket 29): a Poligon's day sampled every few minutes and checked in
## numbers for what the human used to catch by eye (tickets 11 and 13): waves, jumps and pulsing of
## the light. A frame keeps, per sampled pixel, the levelled light (the part A′ puts on levels,
## before exposure), the artificial light and the sun's light; the rules compare frames.
## DaySweepSampler reads the frames on the GPU. Logic tests: test/tools/test_day_sweep.gd; the gate:
## test/engine_poligons/test_day_sweep_gpu.gd.

## A pixel's levelled light changed level when, over its level grid, it moved by more than this
## share: one A′ level is 2^0.5 = +41 % (or −29 %), while the readback (half floats, the smooth sky
## subtracted) is off by well under 1 %; a level always sits at the same place on its grid, so
## between levels nothing moves. The grid is the lamps' fixed lux and the sun's light on flat ground
## (engine ticket 30), a sum of both in between by the sun's share (LightStyle).
const LEVEL_CHANGE: float = 0.1
## ... and by more than this share of the pixel's whole light: less is not visible (under 1 % of a
## pixel's light, below 3 of 256 codes even at full white), and the readback's half floats (0.05 %
## of the styled light, again of the sky subtracted from it) stay well below.
const VISIBLE_SHARE: float = 0.01
## Below this the levelled light is noise of the smooth sky's subtraction (lux before exposure);
## a pixel without levelled light in one of two frames has no level to compare (a shadow came or
## went, the sun went out).
const LEVELLED_MIN_LUX: float = 0.05
## A pixel whose light with levels changed its mix by more than this (the sun's share of it) moved
## to another grid (LightStyle): its level may change whatever its light did.
const MIX_CHANGE: float = 0.1
## Pixels a source lights: at least this much artificial light (lux), and the sun under
## NO_SUN_SHARE of it (the sun on the same levels would move them by itself).
const SOURCE_LIT_LUX: float = 1.0
const NO_SUN_SHARE: float = 0.001
## A frame step outside source switching and twilight may change the level of at most this share of
## the levelled pixels (see LARGE_AREA_MIN_PIXELS). Measured on the street: surfaces of other slopes
## crossing their levels one after another change up to 8 % per 10 min (14 % with the sun's grid at
## fixed lux); a whole sunlit field crossing a level boundary at once, what the eye sees as a jump,
## 58–100 % (engine ticket 30, before its fix).
const LARGE_AREA_SHARE: float = 0.25
## A large change whose pixels are this share lit mostly by the sun is a sun jump (rule SUN_JUMP).
const SUN_JUMP_SHARE: float = 0.9
## The rule name of a large change made by the sun: its light crossing a level boundary over a whole
## sunlit field at once (the A′ grid of the sun at fixed lux, ticket 13, fixed in engine ticket 30).
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
	## The anchors of the level grids (lux before exposure): x the lamps', y the sun's.
	var level_anchors: Vector2 = Vector2.ONE
	## Per sampled pixel (row by row, `size`), four floats: the levelled light, the artificial light,
	## the sun's light and the whole styled light (lux before exposure).
	var data: PackedFloat32Array = PackedFloat32Array()

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


## What one frame step changed: the pixels whose level went up or down, and the counts the rules
## compare them with.
class Step:
	extends RefCounted
	var hour: float = 0.0
	## Pixels with levelled light in either frame.
	var lit: int = 0
	## Pixels lit by sources without the sun in both frames, and those of them that changed level.
	var source_lit: int = 0
	var source_moved: PackedInt32Array = PackedInt32Array()
	## Every pixel that changed level and its direction (Change), and how many were lit mostly by the sun.
	var changed: PackedInt32Array = PackedInt32Array()
	var directions: PackedByteArray = PackedByteArray()
	var sunlit: int = 0
	## The changed pixels whose light with levels (sun and sources) did not move the same way.
	var unexplained: PackedInt32Array = PackedInt32Array()
	var unexplained_directions: PackedByteArray = PackedByteArray()


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
				frame.data, frame.level_anchors])
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
		frame.level_anchors = row[6]
		sweep.frames.append(frame)
	return sweep


## Every rule over the swept frames (the day wraps: the last frame is followed by the first). One
## pass over the pixels per frame step; pulsing then looks only at the pixels that changed.
func check() -> Array[Finding]:
	var findings: Array[Finding] = []
	findings.append_array(check_monotonic())
	var count: int = frames.size()
	var steps: Array[Step] = []
	for index: int in count:
		var step: Step = _scan(frames[index], frames[(index + 1) % count])
		steps.append(step)
		var sources: SourceChange = source_change(index)
		# A step where any group switches is left out whole: the gate cannot tell which pixels
		# that group lights apart from the others' (a known limit; pulsing still looks at it).
		if sources == SourceChange.SWITCH:
			continue
		var standing: Finding = _sources_stand(step, sources == SourceChange.RAMP)
		if standing != null:
			findings.append(standing)
		if not is_twilight(frames[index], frames[(index + 1) % count]):
			var large: Finding = _large_change(step)
			if large != null:
				findings.append(large)
	findings.append_array(_pulsing(steps))
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


## One pass over the pixels of a frame step: which changed level and the counts the rules need.
func _scan(first: Frame, second: Frame) -> Step:
	var step: Step = Step.new()
	step.hour = second.hour
	var one: PackedFloat32Array = first.data
	var two: PackedFloat32Array = second.data
	for index: int in first.pixel_count():
		var at: int = index * 4
		var a: float = one[at]
		var b: float = two[at]
		if maxf(a, b) < LEVELLED_MIN_LUX:
			continue
		step.lit += 1
		var both_sources: bool = _source_lit(one[at + 1], one[at + 2]) and _source_lit(two[at + 1], two[at + 2])
		if both_sources:
			step.source_lit += 1
		var grid_a: float = _grid(first.level_anchors, one[at + 1], one[at + 2])
		var grid_b: float = _grid(second.level_anchors, two[at + 1], two[at + 2])
		var change: Change = _change(a, b, maxf(one[at + 3], two[at + 3]), grid_a, grid_b)
		if change == Change.NONE:
			continue
		if both_sources:
			step.source_moved.append(index)
		step.changed.append(index)
		step.directions.append(change)
		if maxf(one[at + 2], two[at + 2]) > maxf(one[at + 1], two[at + 1]):
			step.sunlit += 1
		var mixed: bool = absf(_sun_share(one[at + 1], one[at + 2]) - _sun_share(two[at + 1], two[at + 2])) > MIX_CHANGE
		if not mixed and not _input_moved((one[at + 1] + one[at + 2]) / grid_a, (two[at + 1] + two[at + 2]) / grid_b, change):
			step.unexplained.append(index)
			step.unexplained_directions.append(change)
	return step


## Outside switching, the pixels the sources light (without the sun) keep their level: with constant
## light the bands of a lamp's pool stand still; a source ramping its light moves them (`ramp`).
func _sources_stand(step: Step, ramp: bool) -> Finding:
	if step.source_moved.size() <= JITTER_SHARE * step.source_lit:
		return null
	var cause: String = "a source ramps its light over several frames (switch it at once)" if ramp \
			else "constant source light; levels anchored to something that changes?"
	return _finding("sources stand", step.hour, _place(step.source_moved), step.source_moved.size(),
			"%d px lit by sources changed level, the bands crawl: %s" % [step.source_moved.size(), cause])


## Outside switching and twilight a frame step changes the level of a small share of the levelled
## pixels only; a large change lit mostly by the sun is a sun jump.
func _large_change(step: Step) -> Finding:
	var changed: int = step.changed.size()
	if changed < LARGE_AREA_MIN_PIXELS or changed <= LARGE_AREA_SHARE * step.lit:
		return null
	var share: float = 100.0 * changed / maxf(step.lit, 1.0)
	if step.sunlit >= SUN_JUMP_SHARE * changed:
		return _finding(SUN_JUMP, step.hour, _place(step.changed), changed,
				"%.0f %% of the levelled pixels, lit mostly by the sun, changed level in one step (the sun's light crossed a level boundary everywhere at once)" % share)
	return _finding("local change", step.hour, _place(step.changed), changed,
			"%.0f %% of the levelled pixels changed level in one step outside switching and twilight (a wave or a ramp?)" % share)


## A pixel going up and back down (or down and back up) within PULSE_FRAMES steps is pulsing, unless
## its light with levels (sun and sources) did the same: a thin shadow passing over it.
func _pulsing(steps: Array[Step]) -> Array[Finding]:
	var findings: Array[Finding] = []
	var count: int = steps.size()
	# Each step's level changes by pixel, to look ahead.
	var by_pixel: Array[Dictionary] = []
	for step: Step in steps:
		var directions: Dictionary = {}
		for position: int in step.changed.size():
			directions[step.changed[position]] = step.directions[position]
		by_pixel.append(directions)
	for start: int in count:
		var step: Step = steps[start]
		var pulsing: PackedInt32Array = PackedInt32Array()
		for position: int in step.unexplained.size():
			var index: int = step.unexplained[position]
			var back: int = Change.DOWN if step.unexplained_directions[position] == Change.UP else Change.UP
			for ahead: int in range(1, PULSE_FRAMES):
				var later: Dictionary = by_pixel[(start + ahead) % count]
				if later.get(index, Change.NONE) == back:
					pulsing.append(index)
					break
		if pulsing.size() > JITTER_SHARE * step.lit:
			findings.append(_finding("pulsing", step.hour, _place(pulsing), pulsing.size(),
					"%d px change level and come back within %d steps while their light does not" % [pulsing.size(), PULSE_FRAMES]))
	return findings


## The level change from levelled light `a` to `b` (lux) in a pixel whose whole light is up to
## `total`, on level grids anchored at `grid_a` and `grid_b`.
static func _change(a: float, b: float, total: float, grid_a: float, grid_b: float) -> Change:
	if minf(a, b) < LEVELLED_MIN_LUX or absf(b - a) <= VISIBLE_SHARE * total:
		return Change.NONE
	var level_a: float = a / grid_a
	var level_b: float = b / grid_b
	if absf(level_b - level_a) <= LEVEL_CHANGE * maxf(level_a, level_b):
		return Change.NONE
	return Change.UP if level_b > level_a else Change.DOWN


## The anchor of a pixel's level grid (lux): between the lamps' and the sun's in EV by the sun's
## share of its light with levels, as the A′ pass puts them (LightStyle).
static func _grid(anchors: Vector2, artificial: float, sun: float) -> float:
	return pow(2.0, lerpf(log(anchors.x), log(anchors.y), _sun_share(artificial, sun)) / log(2.0))


## The sun's share of a pixel's light with levels (0 without light).
static func _sun_share(artificial: float, sun: float) -> float:
	return sun / (artificial + sun) if artificial + sun > 0.0 else 0.0


## Whether the light with levels (the sun and the artificial light) over its grid moved from `a` to
## `b` the way the level did.
static func _input_moved(a: float, b: float, change: Change) -> bool:
	if absf(b - a) <= VISIBLE_SHARE * maxf(a, b):
		return false
	return (b > a) == (change == Change.UP)


## Lit by sources without the sun on the same levels (the sun would move them by itself).
static func _source_lit(artificial: float, sun: float) -> bool:
	return artificial >= SOURCE_LIT_LUX and sun <= NO_SUN_SHARE * artificial


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
