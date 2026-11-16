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


func _tuning(level_stops: float, seam_px: float, mode: TuningSet.StyleMode = TuningSet.StyleMode.SUM) -> TuningSet:
	var tuning: TuningSet = TuningSet.new()
	tuning.level_stops = level_stops
	tuning.seam_px = seam_px
	tuning.style_mode = mode
	return tuning


## Runs the pass once: anchor 1 lux, exposure 1 unless given.
func _styled(natural: Image, tuning: TuningSet, artificial: Image = null, origin: Vector2i = Vector2i.ZERO,
		exposure: float = 1.0) -> Image:
	var style: LightStyle = LightStyle.new()
	add_child_autofree(style)
	var artificial_texture: Texture2D = ImageTexture.create_from_image(artificial) if artificial != null else null
	style.set_input(ImageTexture.create_from_image(natural), artificial_texture, natural.get_size(), origin)
	style.set_tuning(tuning, tuning.style_mode)
	style.set_exposure(exposure, 1.0)
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
