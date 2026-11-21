extends GutTest
## The day sweep's rules on made-up frames (engine ticket 29); the GPU sweep of the street is
## test/engine_poligons/test_day_sweep_gpu.gd.

## 100 × 100 sampled pixels: enough for the large-area minimum and a fraction of jitter.
const SIDE: int = 100
const NIGHT: float = -30.0
const LAMP: Color = Color(30.0, 30.0, 30.0)


## A sweep of `hours` frames with the given source light per frame, every pixel from `pixel`:
## (frame index, pixel index) → Vector4(levelled, artificial, sun, total).
func _sweep(lights: Array[float], pixel: Callable, elevation: float = NIGHT) -> DaySweep:
	var sweep: DaySweep = DaySweep.new()
	sweep.prepare(Vector2i(SIDE, SIDE) * 4, Vector2i(-200, -100), 4)
	for frame_index: int in lights.size():
		var frame: DaySweep.Frame = DaySweep.Frame.new()
		frame.hour = frame_index / 6.0
		frame.sun_elevation = elevation
		frame.exposure = 0.01
		frame.open_lux = 5.0
		frame.source_lights.assign([LAMP * lights[frame_index]])
		frame.data.resize(SIDE * SIDE * 4)
		for index: int in SIDE * SIDE:
			var value: Vector4 = pixel.call(frame_index, index)
			frame.data[index * 4] = value.x
			frame.data[index * 4 + 1] = value.y
			frame.data[index * 4 + 2] = value.z
			frame.data[index * 4 + 3] = value.w
		sweep.frames.append(frame)
	return sweep


func _rules(findings: Array[DaySweep.Finding]) -> PackedStringArray:
	var rules: PackedStringArray = PackedStringArray()
	for finding: DaySweep.Finding in findings:
		rules.append(finding.rule)
	return rules


## The rules found at a clock time (the made-up day wraps: its last frame jumps back to the first).
func _at(clock: String, findings: Array[DaySweep.Finding]) -> PackedStringArray:
	var rules: PackedStringArray = PackedStringArray()
	for finding: DaySweep.Finding in findings:
		if DaySweep.clock(finding.hour) == clock:
			rules.append(finding.rule)
	return rules


## A lamp's pool on the left half: 32 lx on its levels, 30 lx of lamp light, 5 lx of smooth sky.
func _pool(index: int) -> Vector4:
	if index % SIDE < SIDE / 2:
		return Vector4(32.0, 30.0, 0.0, 37.0)
	return Vector4(0.0, 0.0, 0.0, 5.0)


func _constant(count: int) -> Array[float]:
	var lights: Array[float] = []
	for _index: int in count:
		lights.append(1.0)
	return lights


func test_a_steady_night_has_no_findings() -> void:
	var sweep: DaySweep = _sweep(_constant(6), func(_frame: int, index: int) -> Vector4: return _pool(index))
	assert_eq(sweep.check().size(), 0)


func test_exposure_opening_again_before_noon_is_found() -> void:
	# Ticket 13's dawn dip: the exposure opened a little before shutting fast.
	var sweep: DaySweep = _sweep(_constant(6), func(_frame: int, index: int) -> Vector4: return _pool(index))
	var exposures: Array[float] = [0.02, 0.019, 0.0195, 0.01, 0.005, 0.01]
	var open: Array[float] = [5.0, 5.3, 5.2, 10.0, 20.0, 10.0]
	for index: int in exposures.size():
		sweep.frames[index].exposure = exposures[index]
		sweep.frames[index].open_lux = open[index]
	var findings: Array[DaySweep.Finding] = sweep.check_monotonic()
	assert_eq(findings.size(), 2, "the exposure and the open ground, both at 00:20")
	for finding: DaySweep.Finding in findings:
		assert_eq(DaySweep.clock(finding.hour), "00:20")


func test_a_monotonic_day_passes() -> void:
	var sweep: DaySweep = _sweep(_constant(6), func(_frame: int, index: int) -> Vector4: return _pool(index))
	var exposures: Array[float] = [0.02, 0.015, 0.01, 0.005, 0.01, 0.015]
	for index: int in exposures.size():
		sweep.frames[index].exposure = exposures[index]
		sweep.frames[index].open_lux = 0.1 / exposures[index]
	assert_eq(sweep.check_monotonic().size(), 0)


func test_a_constant_lamps_bands_moving_are_found_with_hour_and_place() -> void:
	# Ticket 13's lamp: levels anchored to the darkening sky, the pool's bands moved.
	var sweep: DaySweep = _sweep(_constant(6), func(frame: int, index: int) -> Vector4:
		var pool: Vector4 = _pool(index)
		if frame == 3 and index % SIDE < 10:
			pool.x = 45.25
		return pool)
	var findings: Array[DaySweep.Finding] = sweep.check()
	assert_has(_rules(findings), "sources stand")
	var finding: DaySweep.Finding = findings[_rules(findings).find("sources stand")]
	assert_eq(DaySweep.clock(finding.hour), "00:30")
	assert_eq(finding.place, Rect2i(-200, -100, 40, 400), "the first 10 columns in Location pixels")


func test_a_few_jittering_pixels_are_not_moving_bands() -> void:
	# Half floats: a pixel exactly on a level boundary swaps now and then (≤ 0.1 % of the pool).
	var sweep: DaySweep = _sweep(_constant(6), func(frame: int, index: int) -> Vector4:
		var pool: Vector4 = _pool(index)
		if index == 0 and frame % 2 == 1:
			pool.x = 22.6
		return pool)
	assert_eq(sweep.check().size(), 0)


func test_a_lamp_switched_at_once_may_change_its_pool() -> void:
	var lights: Array[float] = [0.0, 0.0, 0.0, 1.0, 1.0, 1.0]
	var sweep: DaySweep = _sweep(lights, func(frame: int, index: int) -> Vector4:
		return _pool(index) if lights[frame] > 0.0 else Vector4(0.0, 0.0, 0.0, 5.0))
	assert_eq(sweep.check().size(), 0)


func test_a_switch_sampled_in_its_middle_spans_two_steps_and_is_still_a_switch() -> void:
	var lights: Array[float] = [0.0, 0.0, 0.0, 0.5, 1.0, 1.0, 1.0]
	assert_eq(_sweep(lights, func(_frame: int, index: int) -> Vector4: return _pool(index)).source_change(3),
			DaySweep.SourceChange.SWITCH)


func test_a_lamp_ramping_over_three_steps_crawls_its_bands() -> void:
	# Ticket 13's windows: switched on over half an hour, the bands crawled along the pavement.
	var lights: Array[float] = [1.0, 1.0, 1.25, 1.5, 1.75, 2.0, 2.0, 2.0]
	var sweep: DaySweep = _sweep(lights, func(frame: int, index: int) -> Vector4:
		var pool: Vector4 = _pool(index)
		if pool.y > 0.0:
			pool.y *= lights[frame]
			# The band boundary walks with the light: 10 columns per quarter.
			pool.x = 45.25 if index % SIDE < roundi(40.0 * (lights[frame] - 1.0)) else 32.0
		return pool)
	assert_eq(sweep.source_change(3), DaySweep.SourceChange.RAMP)
	var findings: Array[DaySweep.Finding] = sweep.check()
	assert_has(_rules(findings), "sources stand")
	assert_string_contains(str(findings[_rules(findings).find("sources stand")]), "ramps")


func test_the_whole_sunlit_field_crossing_a_level_is_a_sun_jump() -> void:
	var sweep: DaySweep = _sweep(_constant(6), func(frame: int, _index: int) -> Vector4:
		return Vector4(1000.0 if frame < 3 else 1414.0, 0.0, 1100.0 + frame * 20.0, 1500.0), 20.0)
	assert_eq(_at("00:30", sweep.check()), PackedStringArray([DaySweep.SUN_JUMP]))


func test_a_sunlit_field_following_the_suns_light_changes_no_level() -> void:
	# Ticket 30: the sun's levels sit on its own strength; its light on the field rises 20 % a step
	# and the levelled light with it, on the same level all along.
	var sun_at: Callable = func(frame: int) -> float: return 1000.0 * pow(1.2, frame)
	var sweep: DaySweep = _sweep(_constant(6), func(frame: int, _index: int) -> Vector4:
		var sun: float = sun_at.call(frame)
		return Vector4(sun * 1.1, 0.0, sun, sun + 100.0), 20.0)
	for index: int in sweep.frames.size():
		var sun: float = sun_at.call(index)
		sweep.frames[index].level_anchors = Vector2(1.0, sun * 0.5)
	assert_eq(sweep.check().size(), 0)


func test_a_wall_crossing_its_level_on_the_suns_grid_and_back_pulses() -> void:
	# The sun's grid follows the sun; a wall's sun rises with it, yet its level goes up and down.
	var sweep: DaySweep = _sweep(_constant(6), func(frame: int, _index: int) -> Vector4:
		var sun: float = 1000.0 * pow(1.2, frame)
		return Vector4(sun * (1.4 if frame == 2 else 1.0), 0.0, sun, sun + 100.0), 20.0)
	for index: int in sweep.frames.size():
		sweep.frames[index].level_anchors = Vector2(1.0, 500.0 * pow(1.2, index))
	assert_has(_rules(sweep.check()), "pulsing")


func test_the_sun_going_out_above_the_horizon_is_no_sun_jump() -> void:
	# The sun's strength fades to nothing at 5° (its levels follow it); then nothing is on levels.
	var suns: Array[float] = [200.0, 50.0, 14.0, 0.0, 0.0, 0.0]
	var sweep: DaySweep = _sweep(_constant(6), func(frame: int, _index: int) -> Vector4:
		return Vector4(suns[frame], 0.0, suns[frame], suns[frame] + 300.0), 5.0)
	for index: int in sweep.frames.size():
		sweep.frames[index].level_anchors = Vector2(1.0, maxf(suns[index], 0.001))
	assert_eq(sweep.check().size(), 0)


func test_the_sun_passing_over_a_lamps_pool_for_a_frame_is_not_pulsing() -> void:
	# A gap lets the sun onto a dim pool for one frame: the light's mix changes, its grid with it.
	var sweep: DaySweep = _sweep(_constant(6), func(frame: int, index: int) -> Vector4:
		if frame == 2 and index / SIDE < 10:
			return Vector4(18.3, 1.4, 16.2, 400.0)
		return Vector4(0.87, 1.4, 0.0, 400.0), 5.0)
	for index: int in sweep.frames.size():
		sweep.frames[index].level_anchors = Vector2(1.0, 16.2)
	assert_does_not_have(_rules(sweep.check()), "pulsing")


func test_the_whole_sunlit_field_crossing_a_level_on_the_suns_grid_is_a_sun_jump() -> void:
	# The sun's grid follows the sun (+2 % a step); the field's levelled light jumps a level anyway.
	var sun_at: Callable = func(frame: int) -> float: return 1100.0 * pow(1.02, frame)
	var sweep: DaySweep = _sweep(_constant(6), func(frame: int, _index: int) -> Vector4:
		var sun: float = sun_at.call(frame)
		return Vector4(sun * (1.0 if frame < 3 else 1.414), 0.0, sun, 1500.0), 20.0)
	for index: int in sweep.frames.size():
		var sun: float = sun_at.call(index)
		sweep.frames[index].level_anchors = Vector2(1.0, sun * 0.7)
	assert_eq(_at("00:30", sweep.check()), PackedStringArray([DaySweep.SUN_JUMP]))


func test_a_large_change_not_made_by_the_sun_is_a_local_change_finding() -> void:
	# Weak artificial light (under the pool's minimum) on levels, the whole field jumping.
	var sweep: DaySweep = _sweep(_constant(6), func(frame: int, _index: int) -> Vector4:
		return Vector4(0.5 if frame < 3 else 0.707, 0.6, 0.0, 1.0))
	assert_eq(_at("00:30", sweep.check()), PackedStringArray(["local change"]))


func test_at_twilight_large_changes_are_allowed() -> void:
	var sweep: DaySweep = _sweep(_constant(6), func(frame: int, _index: int) -> Vector4:
		return Vector4(1000.0 if frame < 3 else 1414.0, 0.0, 1100.0, 1500.0), 1.0)
	assert_eq(sweep.check().size(), 0)


func test_a_pixel_going_up_and_back_with_steady_light_pulses() -> void:
	var sweep: DaySweep = _sweep(_constant(6), func(frame: int, index: int) -> Vector4:
		var pool: Vector4 = _pool(index)
		if frame == 2 and index % SIDE < 10 and index / SIDE < 10:
			pool.x = 45.25
		return pool, 20.0)
	assert_has(_rules(sweep.check()), "pulsing")


func test_a_thin_shadow_passing_is_not_pulsing() -> void:
	# The sun's light at the pixel goes away and comes back with its level: a post's shadow.
	var sweep: DaySweep = _sweep(_constant(6), func(frame: int, index: int) -> Vector4:
		var shaded: bool = frame == 2 and index / SIDE < 10
		return Vector4(0.0 if shaded else 1000.0, 0.0, 0.0 if shaded else 1100.0, 1500.0), 20.0)
	assert_does_not_have(_rules(sweep.check()), "pulsing")


func test_changes_under_a_visible_share_of_the_pixels_light_are_no_level_change() -> void:
	# The whole field moves 2 → 3 lx on its levels, but in 1000 lx of light: not a visible change.
	var sweep: DaySweep = _sweep(_constant(6), func(frame: int, _index: int) -> Vector4:
		return Vector4(2.0 if frame < 3 else 3.0, 0.0, 0.0, 1000.0), 20.0)
	assert_eq(sweep.check().size(), 0)


func test_a_saved_sweep_loads_the_same() -> void:
	var sweep: DaySweep = _sweep(_constant(3), func(frame: int, index: int) -> Vector4:
		return Vector4(frame, index, 2.0, 3.0))
	var path: String = "user://test_day_sweep.bin"
	assert_eq(sweep.save(path), OK)
	var loaded: DaySweep = DaySweep.load_from(path)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	assert_eq(loaded.size, sweep.size)
	assert_eq(loaded.origin_px, sweep.origin_px)
	assert_eq(loaded.frames.size(), 3)
	assert_eq(loaded.frames[2].data, sweep.frames[2].data)
	assert_eq(loaded.frames[1].source_lights, sweep.frames[1].source_lights)
