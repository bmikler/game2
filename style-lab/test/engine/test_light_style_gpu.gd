extends GutTest
## A′ stylisation pass (GPU, window off screen): synthetic light in, styled light out. Gates: the
## levels follow the tuning set, the seam is as wide in pixels on a gentle slope as on a steep one.

const WIDTH: int = 256
## Four periods of the 4×4 pattern.
const HEIGHT: int = 16


## Light in lux per pixel: `ev(x)` gives log2 of a grey light in column x.
func _gradient(ev: Callable) -> Image:
	var image: Image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBAF)
	for x: int in WIDTH:
		var level_ev: float = ev.call(x)
		var y: float = pow(2.0, level_ev)
		for row: int in HEIGHT:
			image.set_pixel(x, row, Color(y, y, y, 1.0))
	return image


func _uniform(light: Color) -> Image:
	var image: Image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBAF)
	image.fill(light)
	return image


## `full_dither_px` 0 (no short-step dither) unless given: most gates are about the narrow seam.
func _tuning(level_stops: float, seam_px: float, mode: TuningSet.StyleMode = TuningSet.StyleMode.SUM,
		full_dither_px: float = 0.0, sky_style: TuningSet.SkyStyle = TuningSet.SkyStyle.LEVELS) -> TuningSet:
	var tuning: TuningSet = TuningSet.new()
	tuning.level_stops = level_stops
	tuning.seam_px = seam_px
	tuning.full_dither_px = full_dither_px
	tuning.sky_style = sky_style
	tuning.style_mode = mode
	return tuning


## Runs the pass once: anchor 1 lux, exposure 1 unless given.
func _styled(natural: Image, tuning: TuningSet, artificial: Image = null, origin: Vector2i = Vector2i.ZERO,
		exposure: float = 1.0, anchor_lux: float = 1.0, sun_light: Vector3 = Vector3.ZERO,
		open_sky_light: Vector3 = Vector3.ZERO) -> Image:
	var style: LightStyle = LightStyle.new()
	add_child_autofree(style)
	var artificial_texture: Texture2D = ImageTexture.create_from_image(artificial) if artificial != null else null
	style.set_input(ImageTexture.create_from_image(natural), artificial_texture, natural.get_size(), origin)
	style.set_tuning(tuning, tuning.style_mode, tuning.full_dither_px, tuning.sky_style)
	style.set_exposure(exposure, anchor_lux)
	style.set_sun(sun_light, open_sky_light)
	await RenderingServer.frame_post_draw
	return style.image()


## Distinct levels (rounded EV over the anchor) on the first row.
func _levels(image: Image) -> Dictionary[float, bool]:
	var found: Dictionary[float, bool] = {}
	for x: int in image.get_width():
		found[snappedf(log(image.get_pixel(x, 0).r) / log(2.0), 0.01)] = true
	return found


## Columns whose pixels are not all the same (the dither seam).
func _mixed_columns(image: Image) -> int:
	var mixed: int = 0
	for x: int in image.get_width():
		var first: float = image.get_pixel(x, 0).r
		for row: int in range(1, image.get_height()):
			if not is_equal_approx(image.get_pixel(x, row).r, first):
				mixed += 1
				break
	return mixed


func test_level_count_follows_the_tuning_set() -> void:
	# −2 … +2 EV over the anchor: half-stop levels give twice as many as whole-stop ones.
	var ramp: Image = _gradient(func(x: int) -> float: return -2.0 + 4.0 * x / WIDTH)
	var half: Dictionary[float, bool] = _levels(await _styled(ramp, _tuning(0.5, 0.0)))
	var whole: Dictionary[float, bool] = _levels(await _styled(ramp, _tuning(1.0, 0.0)))
	assert_eq(half.size(), 9, "levels at −2, −1.5 … +2 EV")
	assert_eq(whole.size(), 5, "levels at −2, −1 … +2 EV")
	for level: float in half:
		assert_almost_eq(fposmod(level, 0.5), 0.0, 0.02, "every level lies on the half-stop grid: %s" % level)


func test_open_sky_lies_in_the_middle_of_a_level() -> void:
	# The anchor's own brightness and ±0.2 EV around it fall into one level, the anchor's.
	var near_anchor: Image = _gradient(func(x: int) -> float: return -0.2 + 0.4 * x / WIDTH)
	var levels: Dictionary[float, bool] = _levels(await _styled(near_anchor, _tuning(0.5, 0.0)))
	assert_eq(levels.keys(), [0.0])


func test_seam_is_as_wide_in_pixels_on_a_gentle_and_a_steep_slope() -> void:
	# Half-stop levels: boundaries where the EV is −0.25 + 0.5 n. The farthest dithered pixel (one
	# that differs from plain posterisation) lies half the seam from its boundary, on any slope.
	for ev_per_px: float in [0.01, 0.06]:
		var ramp: Image = _gradient(func(x: int) -> float: return -1.1 + ev_per_px * x)
		var seam: Image = await _styled(ramp, _tuning(0.5, 3.0))
		var plain: Image = await _styled(ramp, _tuning(0.5, 0.0))
		var farthest: float = 0.0
		for x: int in WIDTH:
			for row: int in HEIGHT:
				if not is_equal_approx(seam.get_pixel(x, row).r, plain.get_pixel(x, row).r):
					var ev: float = -1.1 + ev_per_px * x
					var from_boundary_ev: float = absf(fposmod(ev + 0.25 + 0.25, 0.5) - 0.25)
					farthest = maxf(farthest, from_boundary_ev / ev_per_px)
		assert_between(farthest, 1.0, 1.75, "half of a 3 px seam at %s EV/px" % ev_per_px)


func test_seam_zero_is_plain_posterisation() -> void:
	var ramp: Image = _gradient(func(x: int) -> float: return -1.1 + 0.01 * x)
	assert_eq(_mixed_columns(await _styled(ramp, _tuning(0.5, 0.0))), 0)


func test_a_hard_step_keeps_a_crisp_edge() -> void:
	# A shadow edge one pixel wide: the jump is not a slope, so no seam spreads around it.
	var step: Image = _gradient(func(x: int) -> float: return 0.0 if x < WIDTH / 2 else -2.0)
	assert_eq(_mixed_columns(await _styled(step, _tuning(0.5, 3.0))), 0)


func test_the_pattern_sticks_to_location_pixels() -> void:
	var ramp: Image = _gradient(func(x: int) -> float: return -1.1 + 0.03 * x)
	var styled: Image = await _styled(ramp, _tuning(0.5, 3.0))
	# The same light one Location pixel further: the output moves with it, pattern and all.
	var moved_light: Image = _gradient(func(x: int) -> float: return -1.1 + 0.03 * (x - 1))
	var moved: Image = await _styled(moved_light, _tuning(0.5, 3.0), null, Vector2i(-1, 0))
	var same: bool = true
	for x: int in range(2, WIDTH - 2):
		for row: int in HEIGHT:
			if not is_equal_approx(styled.get_pixel(x, row).r, moved.get_pixel(x + 1, row).r):
				same = false
	assert_true(same)


func test_colour_stays_continuous() -> void:
	var styled: Image = await _styled(_uniform(Color(1.3, 0.65, 0.325)), _tuning(0.5, 3.0))
	var pixel: Color = styled.get_pixel(10, 10)
	assert_almost_eq(pixel.g / pixel.r, 0.5, 0.001)
	assert_almost_eq(pixel.b / pixel.r, 0.25, 0.001)


func test_no_light_stays_black() -> void:
	var styled: Image = await _styled(_uniform(Color(0.0, 0.0, 0.0)), _tuning(0.5, 3.0))
	assert_eq(styled.get_pixel(10, 10).r, 0.0)


func test_exposure_scales_the_styled_light() -> void:
	var light: Image = _uniform(Color(1.3, 1.3, 1.3))
	var once: float = (await _styled(light, _tuning(0.5, 3.0))).get_pixel(10, 10).r
	var twice: float = (await _styled(light, _tuning(0.5, 3.0), null, Vector2i.ZERO, 2.0)).get_pixel(10, 10).r
	assert_almost_eq(twice, once * 2.0, once * 0.001)


func test_per_channel_mode_styles_natural_and_artificial_apart() -> void:
	# Natural 1 lux (the middle of level 0) and artificial 0.3 lux.
	var natural: Image = _uniform(Color(1.0, 1.0, 1.0))
	var artificial: Image = _uniform(Color(0.3, 0.3, 0.3))
	var on_sum: float = (await _styled(natural, _tuning(0.5, 0.0), artificial)).get_pixel(10, 10).r
	var apart: float = (await _styled(natural, _tuning(0.5, 0.0, TuningSet.StyleMode.PER_CHANNEL), artificial)).get_pixel(10, 10).r
	assert_almost_eq(on_sum, pow(2.0, 0.5), 0.001, "1.3 lux lands on the +0.5 EV level")
	assert_almost_eq(apart, 1.0 + pow(2.0, -1.5), 0.001, "1 lux stays, 0.3 lux lands on −1.5 EV")


func test_without_artificial_light_both_modes_agree() -> void:
	var ramp: Image = _gradient(func(x: int) -> float: return -1.1 + 0.03 * x)
	var on_sum: Image = await _styled(ramp, _tuning(0.5, 3.0))
	var apart: Image = await _styled(ramp, _tuning(0.5, 3.0, TuningSet.StyleMode.PER_CHANNEL))
	assert_eq(on_sum.get_data(), apart.get_data())


# Gates from research 92 §5c, run for every F1 variant of `full_dither_px` (the critic may change the
# look, not bring back edges from gradients or the grid on the street). Light is given in level
# steps (`s`, the anchor in the middle of level 0 at s = 0.5, level centres at n + 0.5).

## Light whose level coordinate is `s`, with half-stop levels and the anchor at 1 lux.
func _ev_of_steps(s: float) -> float:
	return (s - 0.5) * 0.5


## A ramp from `from` to `to` (level steps) over `length_px` from column `start`, flat around it.
func _steps_ramp(from: float, to: float, start: int, length_px: float) -> Callable:
	return func(x: int) -> float:
		return lerpf(from, to, clampf((x + 0.5 - start) / length_px, 0.0, 1.0))


## Level coordinate of a styled pixel (half-stop levels, anchor 1 lux): its level's centre.
func _steps_of_pixel(light: float) -> float:
	return log(light) / log(2.0) / 0.5 + 0.5


## Worst error of the 4 px mean (4×4 cells, whole pattern periods) of the styled light against the
## input's, and the worst jump between neighbouring cells beyond the input's own jump, in steps.
func _tracking(steps: Callable, styled: Image) -> Vector2:
	var cells_in: PackedFloat32Array = PackedFloat32Array()
	var cells_out: PackedFloat32Array = PackedFloat32Array()
	for cell: int in WIDTH / 4:
		var sum_in: float = 0.0
		var sum_out: float = 0.0
		for x: int in range(cell * 4, cell * 4 + 4):
			var s: float = steps.call(x)
			sum_in += s * HEIGHT
			for row: int in HEIGHT:
				sum_out += _steps_of_pixel(styled.get_pixel(x, row).r)
		cells_in.append(sum_in / (4 * HEIGHT))
		cells_out.append(sum_out / (4 * HEIGHT))
	var worst: Vector2 = Vector2.ZERO
	for cell: int in cells_in.size():
		worst.x = maxf(worst.x, absf(cells_out[cell] - cells_in[cell]))
		if cell > 0:
			var jump_out: float = absf(cells_out[cell] - cells_out[cell - 1])
			var jump_in: float = absf(cells_in[cell] - cells_in[cell - 1])
			worst.y = maxf(worst.y, jump_out - jump_in)
	return worst


func _styled_steps(steps: Callable, tuning: TuningSet) -> Image:
	return await _styled(_gradient(func(x: int) -> float:
		var s: float = steps.call(x)
		return _ev_of_steps(s)), tuning)


func test_gate_short_steps_leave_no_edge() -> void:
	# A thing's halo: 1–2 levels down over a step 8 px … `full_dither_px` long. Between two level
	# centres, so the flat light around it is a level of its own.
	for full: float in EnginePanel.FULL_DITHER_VARIANTS_PX:
		if full <= 0.0:
			continue # today's A′, kept in F1 for comparison: it makes the edges (the next test)
		for step_px: float in [8.0, full * 0.5, full]:
			for amplitude: float in [0.5, 1.0, 2.0]:
				# Half a level runs from a quarter below a boundary to a quarter above it.
				var from: float = 0.75 if amplitude < 1.0 else 0.5
				var steps: Callable = _steps_ramp(from, from + amplitude, 64, amplitude * step_px)
				var worst: Vector2 = _tracking(steps, await _styled_steps(steps, _tuning(0.5, 3.0, TuningSet.StyleMode.SUM, full)))
				var where: String = "full dither %s px, a step %s px, %s levels" % [full, step_px, amplitude]
				assert_lt(worst.x, 0.35, "the mean follows the light: %s" % where)
				assert_lt(worst.y, 0.35, "no jump of its own: %s" % where)


func test_gate_short_steps_catch_the_old_flat_rings() -> void:
	# The gate above is not empty: without the short-step dither a halo turns into flat rings.
	var steps: Callable = _steps_ramp(0.5, 1.5, 64, 16.0)
	var worst: Vector2 = _tracking(steps, await _styled_steps(steps, _tuning(0.5, 3.0)))
	assert_gt(worst.y, 0.35)


func test_gate_a_sharp_edge_stays_sharp() -> void:
	# 2 EV (4 levels) over 1 or 2 px, between two level centres: the edge is at most a seam wide.
	for full: float in EnginePanel.FULL_DITHER_VARIANTS_PX:
		for edge_px: float in [1.0, 2.0]:
			var steps: Callable = _steps_ramp(0.5, -3.5, 128, edge_px)
			var styled: Image = await _styled_steps(steps, _tuning(0.5, 3.0, TuningSet.StyleMode.SUM, full))
			var lit: float = styled.get_pixel(0, 0).r
			var dark: float = styled.get_pixel(WIDTH - 1, 0).r
			var between: int = 0
			for x: int in WIDTH:
				var all_lit: bool = true
				var all_dark: bool = true
				for row: int in HEIGHT:
					var light: float = styled.get_pixel(x, row).r
					all_lit = all_lit and is_equal_approx(light, lit)
					all_dark = all_dark and is_equal_approx(light, dark)
				if not all_lit and not all_dark:
					between += 1
			assert_lte(between, 4, "full dither %s px, an edge %s px: at most the 3 px seam + 1" % [full, edge_px])


func test_gate_the_street_keeps_flat_fields_with_a_narrow_seam() -> void:
	# The slope along a facade: a step 85–285 px long. Away from each boundary the light is the
	# plain posterisation; dithered pixels lie within half the seam (+ a pixel) of a boundary.
	for full: float in EnginePanel.FULL_DITHER_VARIANTS_PX:
		for step_px: float in [85.0, 285.0]:
			# Starts 0.3 steps below a boundary, so each ramp crosses at least one.
			var steps: Callable = func(x: int) -> float: return 0.7 + x / step_px
			var seam: Image = await _styled_steps(steps, _tuning(0.5, 3.0, TuningSet.StyleMode.SUM, full))
			var plain: Image = await _styled_steps(steps, _tuning(0.5, 0.0))
			var farthest: float = 0.0
			for x: int in WIDTH:
				for row: int in HEIGHT:
					if not is_equal_approx(seam.get_pixel(x, row).r, plain.get_pixel(x, row).r):
						var s: float = steps.call(x)
						farthest = maxf(farthest, absf(s - roundf(s)) * step_px)
			assert_lte(farthest, 2.5, "full dither %s px, a step %s px" % [full, step_px])


func test_gate_brighter_sky_moves_no_level_boundary() -> void:
	# Lit by the sky alone, the light and the anchor scale together: the levels stay where they were,
	# only brighter by the same factor (research 84, 92 §5c.10).
	var ramp: Image = _gradient(func(x: int) -> float: return -1.1 + 0.02 * x)
	var brighter: Image = ramp.duplicate() as Image
	for x: int in WIDTH:
		for row: int in HEIGHT:
			brighter.set_pixel(x, row, ramp.get_pixel(x, row) * 3.0)
	for full: float in EnginePanel.FULL_DITHER_VARIANTS_PX:
		var tuning: TuningSet = _tuning(0.5, 3.0, TuningSet.StyleMode.SUM, full)
		var styled: Image = await _styled(ramp, tuning)
		var scaled: Image = await _styled(brighter, tuning, null, Vector2i.ZERO, 1.0, 3.0)
		var moved: int = 0
		for x: int in WIDTH:
			for row: int in HEIGHT:
				# The level relative to its anchor (the buffer holds half floats: compare levels, not lux).
				var level_scaled: float = _steps_of_pixel(scaled.get_pixel(x, row).r / 3.0)
				if absf(level_scaled - _steps_of_pixel(styled.get_pixel(x, row).r)) > 0.1:
					moved += 1
		assert_eq(moved, 0, "full dither %s px" % full)



# Sky styles: the buffer's alpha holds the sun's share (cosine × visibility; × the sun's light it is
# the sun's lux), the rest of the light (sky, ambient) has no hard edge. Levels for both (A), or
# levels for the sun only with the rest smooth (B) or always dithered (C).

## `soft` lux everywhere, plus a sun of `sun_lux` where `sunny` says so.
func _sun_and_soft(soft: Callable, sunny: Callable) -> Image:
	var image: Image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBAF)
	for x: int in WIDTH:
		var y: float = soft.call(x)
		var sun: float = 1.0 if sunny.call(x) else 0.0
		for row: int in HEIGHT:
			image.set_pixel(x, row, Color(y + 4.0 * sun, y + 4.0 * sun, y + 4.0 * sun, sun))
	return image


func test_smooth_sky_keeps_the_light_without_the_sun_as_it_is() -> void:
	var ramp: Image = _gradient(func(x: int) -> float: return -1.1 + 0.02 * x)
	for x: int in WIDTH:
		for row: int in HEIGHT:
			var pixel: Color = ramp.get_pixel(x, row)
			pixel.a = 0.0
			ramp.set_pixel(x, row, pixel)
	var styled: Image = await _styled(ramp, _tuning(0.5, 3.0, TuningSet.StyleMode.SUM, 24.0, TuningSet.SkyStyle.SMOOTH),
			null, Vector2i.ZERO, 1.0, 1.0, Vector3(4.0, 4.0, 4.0))
	for x: int in WIDTH:
		var lux: float = ramp.get_pixel(x, 5).r
		assert_almost_eq(styled.get_pixel(x, 5).r, lux, lux * 0.002, "column %d" % x)


func test_smooth_sky_adds_the_sun_on_its_level_with_a_crisp_edge() -> void:
	# A sun of 4 lux (the middle of a level) over half the strip, a soft slope under all of it.
	var soft: Callable = func(x: int) -> float: return 0.5 + 0.002 * x
	var light: Image = _sun_and_soft(soft, func(x: int) -> bool: return x < WIDTH / 2)
	var styled: Image = await _styled(light, _tuning(0.5, 3.0, TuningSet.StyleMode.SUM, 24.0, TuningSet.SkyStyle.SMOOTH),
			null, Vector2i.ZERO, 1.0, 1.0, Vector3(4.0, 4.0, 4.0))
	for x: int in WIDTH:
		var y: float = soft.call(x)
		var expected: float = y + (4.0 if x < WIDTH / 2 else 0.0)
		assert_almost_eq(styled.get_pixel(x, 7).r, expected, expected * 0.002, "column %d" % x)


func test_dithered_sky_has_no_flat_field_on_a_long_slope() -> void:
	# A wall's sky shade: a level over 285 px. Levels make a flat field and an edge; the dithered
	# sky follows the slope in its 4 px mean.
	var steps: Callable = func(x: int) -> float: return 0.7 + x / 285.0
	var light: Image = _gradient(func(x: int) -> float:
		var s: float = steps.call(x)
		return _ev_of_steps(s))
	for x: int in WIDTH:
		for row: int in HEIGHT:
			var pixel: Color = light.get_pixel(x, row)
			pixel.a = 0.0
			light.set_pixel(x, row, pixel)
	var sun: Vector3 = Vector3(4.0, 4.0, 4.0)
	var dithered: Image = await _styled(light, _tuning(0.5, 3.0, TuningSet.StyleMode.SUM, 24.0, TuningSet.SkyStyle.DITHER),
			null, Vector2i.ZERO, 1.0, 1.0, sun)
	var worst: Vector2 = _tracking(steps, dithered)
	assert_lt(worst.x, 0.35, "the mean follows the light")
	assert_lt(worst.y, 0.35, "no jump of its own")
	var levels: Image = await _styled(light, _tuning(0.5, 3.0, TuningSet.StyleMode.SUM, 24.0, TuningSet.SkyStyle.LEVELS),
			null, Vector2i.ZERO, 1.0, 1.0, sun)
	assert_gt(_tracking(steps, levels).y, 0.35, "levels make an edge there")


func test_without_the_sun_every_sky_style_keeps_the_sun_edge_sharp() -> void:
	# The sun's shadow edge on a flat soft light: one pixel, whatever the sky style.
	for style: TuningSet.SkyStyle in [TuningSet.SkyStyle.SMOOTH, TuningSet.SkyStyle.DITHER]:
		var light: Image = _sun_and_soft(func(_x: int) -> float: return 1.0, func(x: int) -> bool: return x < WIDTH / 2)
		var styled: Image = await _styled(light, _tuning(0.5, 3.0, TuningSet.StyleMode.SUM, 24.0, style),
				null, Vector2i.ZERO, 1.0, 1.0, Vector3(4.0, 4.0, 4.0))
		assert_eq(_mixed_columns(styled), 0, "sky style %d" % style)
		assert_gt(styled.get_pixel(WIDTH / 2 - 1, 0).r, styled.get_pixel(WIDTH / 2, 0).r * 4.0, "the edge in one pixel")



func test_flat_sky_makes_a_sun_shadow_one_colour_with_the_sun_edge_in_levels() -> void:
	# Sky shade sloping inside and outside a sun shadow (a wall's): it no longer shows; the shadow is
	# one level (open ground's sky, 1 lux), the sunny side another (+ 4 lux), the edge one pixel.
	var soft: Callable = func(x: int) -> float: return 0.4 + 0.003 * x
	var light: Image = _sun_and_soft(soft, func(x: int) -> bool: return x < WIDTH / 2)
	var styled: Image = await _styled(light, _tuning(0.5, 3.0, TuningSet.StyleMode.SUM, 24.0, TuningSet.SkyStyle.FLAT),
			null, Vector2i.ZERO, 1.0, 1.0, Vector3(4.0, 4.0, 4.0), Vector3(1.0, 1.0, 1.0))
	var sunny: float = styled.get_pixel(0, 0).r
	var shade: float = styled.get_pixel(WIDTH - 1, 0).r
	assert_almost_eq(shade, 1.0, 0.002, "the shadow: open ground's sky, the middle of its level")
	assert_gt(sunny, shade * 2.0)
	for x: int in WIDTH:
		for row: int in HEIGHT:
			assert_almost_eq(styled.get_pixel(x, row).r, sunny if x < WIDTH / 2 else shade, 0.002, "column %d" % x)


func test_flat_sky_leaves_no_surface_dark() -> void:
	var styled: Image = await _styled(_uniform(Color(0.0, 0.0, 0.0, 0.0)),
			_tuning(0.5, 3.0, TuningSet.StyleMode.SUM, 24.0, TuningSet.SkyStyle.FLAT),
			null, Vector2i.ZERO, 1.0, 1.0, Vector3(4.0, 4.0, 4.0), Vector3(1.0, 1.0, 1.0))
	assert_eq(styled.get_pixel(10, 10).r, 0.0)
