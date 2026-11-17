extends GutTest
## Location → light buffer (GPU, window off screen). Gates check rules of light, not the look.
## Sun gates read the channels view (the sun alone, without the sky that solids also shade).

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")


## A synthetic Location: ground (the top of a flat solid at z = 0) and a post 1×1×3 m at x, d = 0.
func _location(hour: float) -> LightEngine:
	var view: SubViewport = SubViewport.new()
	view.size = Vector2i(8, 8)
	view.add_child(LocationEnvironment.new())
	var ground: Occluder = Occluder.new()
	ground.add_child(_solid(Vector3(0.0, 20.0, -0.1), Vector3(40.0, 40.0, 0.1)))
	view.add_child(ground)
	var post: Occluder = Occluder.new()
	post.add_child(_solid(Vector3(0.0, 0.5, 0.0), Vector3(1.0, 1.0, 3.0)))
	view.add_child(post)
	var engine: LightEngine = LightEngine.new()
	engine.rate = 0.0
	view.add_child(engine)
	add_child_autofree(view)
	engine.set_hour(hour)
	await _channels_view(engine)
	return engine


func _solid(at: Vector3, size: Vector3) -> Solid:
	var solid: Solid = Solid.new()
	solid.position_m = at
	solid.size_m = size
	return solid


## Waits for the sky layer, then shows the channels view.
func _channels_view(engine: LightEngine) -> void:
	while not engine.is_sky_complete():
		await RenderingServer.frame_post_draw
	engine.set_debug_view(LightEngine.DebugView.CHANNELS)
	await RenderingServer.frame_post_draw


## Lux the sun alone gives the ground at (x, d) (channels view).
func _ground(engine: LightEngine, x: float, d: float) -> float:
	return _lux(engine, Vector3(x, d, 0.0))


## Lux the sun alone gives open ground now.
func _sun_on_ground(engine: LightEngine) -> float:
	var state: DayState = engine.state()
	return state.sun_color.get_luminance() * state.sun_intensity * state.sun_direction.z


func test_buffer_covers_the_location() -> void:
	var engine: LightEngine = await _location(12.0)
	assert_eq(engine.buffer_image().get_size(), engine.buffer_area().size)
	assert_eq(engine.buffer_area().size.x, 1600)


func test_morning_shadow_falls_right_away_from_the_eastern_sun() -> void:
	var engine: LightEngine = await _location(10.0)
	var west: float = _ground(engine, 1.0, 2.8)
	var east: float = _ground(engine, -1.0, 2.8)
	assert_gt(_sun_on_ground(engine), 100.0)
	assert_almost_eq(east - west, _sun_on_ground(engine), _sun_on_ground(engine) * 0.01, "the shadow lies west (right) of the post")


func test_afternoon_shadow_falls_left_away_from_the_western_sun() -> void:
	var engine: LightEngine = await _location(14.0)
	var west: float = _ground(engine, 1.0, 2.8)
	var east: float = _ground(engine, -1.0, 2.8)
	assert_gt(_sun_on_ground(engine), 100.0)
	assert_almost_eq(west - east, _sun_on_ground(engine), _sun_on_ground(engine) * 0.01, "the shadow lies east (left) of the post")


func test_shadow_light_is_what_still_reaches_it_not_black() -> void:
	var engine: LightEngine = await _location(10.0)
	assert_eq(_ground(engine, 1.0, 2.8), 0.0, "no sun in the shadow")
	engine.set_debug_view(LightEngine.DebugView.NONE)
	await RenderingServer.frame_post_draw
	assert_gt(_pixel(engine, Vector3(1.0, 2.8, 0.0)).get_luminance(), 0.0)


func test_the_top_of_the_post_takes_the_sun_its_shaded_front_does_not() -> void:
	var engine: LightEngine = await _location(12.5)
	assert_gt(_lux(engine, Vector3(0.0, 0.0, 3.0)), 100.0)
	assert_eq(_lux(engine, Vector3(0.0, 0.5, 1.5)), 0.0,
			"the front faces north, away from the noon sun")


func test_debug_view_receivers_tells_tops_from_fronts() -> void:
	var engine: LightEngine = await _location(12.5)
	engine.set_debug_view(LightEngine.DebugView.RECEIVERS)
	await RenderingServer.frame_post_draw
	var area: Rect2i = engine.buffer_area()
	var image: Image = engine.buffer_image()
	var top: Color = image.get_pixelv(Vector2i(PROJECTION.to_screen(Vector3(0.0, 0.0, 3.0)).floor()) - area.position)
	var front: Color = image.get_pixelv(Vector2i(PROJECTION.to_screen(Vector3(0.0, 0.5, 1.5)).floor()) - area.position)
	assert_gt(top.b, top.r, "tops are blue")
	assert_gt(front.r, front.b, "fronts are orange")
	engine.set_debug_view(LightEngine.DebugView.NONE)
	await RenderingServer.frame_post_draw
	assert_gt(engine.buffer_image().get_pixelv(Vector2i(PROJECTION.to_screen(Vector3(0.0, 0.0, 3.0)).floor()) - area.position).r, 10.0,
			"back to lux")


func test_with_north_at_the_top_the_morning_shadow_falls_left() -> void:
	var engine: LightEngine = await _location(10.0)
	engine.set_north_at_top(true)
	await RenderingServer.frame_post_draw
	# The sun is now behind the camera on the right: the post's shadow goes left and up the screen.
	var west: float = _ground(engine, 1.0, -2.8)
	var east: float = _ground(engine, -1.0, -2.8)
	assert_almost_eq(west - east, _sun_on_ground(engine), _sun_on_ground(engine) * 0.01, "the shadow lies east (left) of the post")


## A synthetic Location: ground (the top of a flat solid at z = 0) and the given solids, one
## Occluder each.
func _scene(hour: float, solids: Array[Solid]) -> LightEngine:
	var view: SubViewport = SubViewport.new()
	view.size = Vector2i(8, 8)
	view.add_child(LocationEnvironment.new())
	var ground: Occluder = Occluder.new()
	ground.add_child(_solid(Vector3(0.0, 20.0, -0.1), Vector3(40.0, 40.0, 0.1)))
	view.add_child(ground)
	for solid: Solid in solids:
		var occluder: Occluder = Occluder.new()
		occluder.add_child(solid)
		view.add_child(occluder)
	var engine: LightEngine = LightEngine.new()
	engine.rate = 0.0
	view.add_child(engine)
	add_child_autofree(view)
	engine.set_hour(hour)
	await _channels_view(engine)
	return engine


func _shaped(at: Vector3, size: Vector3, shape: Solid.Shape) -> Solid:
	var solid: Solid = _solid(at, size)
	solid.shape = shape
	return solid


## Lux the sun alone gives the screen pixel showing the point (x, d, z) in metres (channels view).
func _lux(engine: LightEngine, point: Vector3) -> float:
	var state: DayState = engine.state()
	return _pixel(engine, point).r * state.sun_color.get_luminance() * state.sun_intensity


## The buffer pixel showing the point (x, d, z) in metres.
func _pixel(engine: LightEngine, point: Vector3) -> Color:
	var pixel: Vector2i = Vector2i(PROJECTION.to_screen(point).floor()) - engine.buffer_area().position
	return engine.buffer_image().get_pixelv(pixel)


## Where the sun's ray through `point` reaches the ground.
func _shadow_on_ground(engine: LightEngine, point: Vector3) -> Vector3:
	var sun: Vector3 = engine.state().sun_direction
	return point - sun * (point.z / sun.z)


func test_gate_under_a_raised_box_the_low_sun_comes_in_from_the_side() -> void:
	# An awning 4 × 3 m with 2,2 m clear below it, front edge at d = 0.
	var awning: Solid = _shaped(Vector3.ZERO, Vector3(4.0, 3.0, 2.4), Solid.Shape.RAISED_BOX)
	awning.clearance_m = 2.2
	var engine: LightEngine = await _scene(10.0, [awning])
	var sun: float = _sun_on_ground(engine)
	var open: float = _lux(engine, Vector3(-8.0, 6.0, 0.0))
	assert_gt(sun, 100.0)
	assert_almost_eq(_lux(engine, Vector3(0.0, -0.5, 0.0)), open, sun * 0.01, "sun under the awning's front")
	assert_almost_eq(_lux(engine, Vector3(0.0, -2.5, 0.0)), open, sun * 0.01, "sun deep under the awning")
	var shade: Vector3 = _shadow_on_ground(engine, Vector3(0.0, -1.5, 2.2))
	assert_almost_eq(open - _lux(engine, shade), sun, sun * 0.01, "the awning's shadow lies away from the sun")


func test_a_cylinder_casts_a_shadow_as_wide_as_its_diameter_at_any_azimuth() -> void:
	for hour: float in [10.0, 14.0]:
		var post: Solid = _shaped(Vector3(0.0, 0.5, 0.0), Vector3(1.0, 1.0, 3.0), Solid.Shape.CYLINDER)
		var engine: LightEngine = await _scene(hour, [post])
		# The circle's edge 7.5 cm either side: the hard shadow (the penumbra has its own gates).
		engine.set_penumbra_on(false)
		await RenderingServer.frame_post_draw
		var sun: float = _sun_on_ground(engine)
		var toward_sun: Vector2 = Vector2(engine.state().sun_direction.x, engine.state().sun_direction.y).normalized()
		var across: Vector2 = toward_sun.orthogonal()
		for side: float in [-1.0, 1.0]:
			var inside: Vector2 = -toward_sun * 2.5 + across * side * 0.5 * 0.85
			var outside: Vector2 = -toward_sun * 2.5 + across * side * 0.5 * 1.15
			var lit: float = _lux(engine, Vector3(outside.x, outside.y, 0.0))
			assert_almost_eq(lit - _lux(engine, Vector3(inside.x, inside.y, 0.0)), sun, sun * 0.01,
					"%d:00, side %d: the shadow's edge is the circle's" % [hour, side])


func test_a_gable_casts_a_pointed_shadow_along_its_slopes() -> void:
	# Walls 3 m, ridge 6 m along d; the noon sun at 30° from the south.
	var house: Solid = _shaped(Vector3.ZERO, Vector3(6.0, 4.0, 6.0), Solid.Shape.ROOF_X)
	house.eave_m = 3.0
	var engine: LightEngine = await _scene(12.5, [house])
	var sun: float = _sun_on_ground(engine)
	var open: float = _lux(engine, Vector3(-10.0, 8.0, 0.0))
	# At d = 8 only the roof higher than 4,6 m still shades: |x| < 1,4.
	assert_almost_eq(open - _lux(engine, Vector3(0.0, 8.0, 0.0)), sun, sun * 0.01, "under the ridge")
	assert_almost_eq(_lux(engine, Vector3(2.6, 8.0, 0.0)), open, sun * 0.01, "beside the ridge, right")
	assert_almost_eq(_lux(engine, Vector3(-2.6, 8.0, 0.0)), open, sun * 0.01, "beside the ridge, left")
	assert_almost_eq(open - _lux(engine, Vector3(2.6, 4.0, 0.0)), sun, sun * 0.01, "the walls' shadow nearer")


func test_a_floor_up_high_is_the_top_of_a_solid_and_takes_sun_and_shadow() -> void:
	# A podium 0,5 m high (d −2…2) with a post on it.
	var podium: Solid = _solid(Vector3(0.0, 2.0, 0.0), Vector3(6.0, 4.0, 0.5))
	var post: Solid = _solid(Vector3(0.0, 0.5, 0.5), Vector3(1.0, 1.0, 3.0))
	var engine: LightEngine = await _scene(12.5, [podium, post])
	var sun: float = _sun_on_ground(engine)
	var open: float = _lux(engine, Vector3(-10.0, 8.0, 0.0))
	assert_almost_eq(_lux(engine, Vector3(2.0, 1.5, 0.5)), open, sun * 0.01, "the podium's top as lit as the street")
	assert_almost_eq(open - _lux(engine, Vector3(0.0, 1.5, 0.5)), sun, sun * 0.01, "the post's shadow on the podium")


func test_receivers_follow_the_curve_of_a_cylinder_and_the_triangle_of_a_gable() -> void:
	var post: Solid = _shaped(Vector3(-6.0, 0.5, 0.0), Vector3(1.0, 1.0, 3.0), Solid.Shape.CYLINDER)
	var house: Solid = _shaped(Vector3(4.0, 0.0, 0.0), Vector3(6.0, 4.0, 6.0), Solid.Shape.ROOF_X)
	house.eave_m = 3.0
	var engine: LightEngine = await _scene(12.5, [post, house])
	engine.set_debug_view(LightEngine.DebugView.RECEIVERS)
	await RenderingServer.frame_post_draw
	var area: Rect2i = engine.buffer_area()
	var image: Image = engine.buffer_image()
	var at: Callable = func(point: Vector3) -> Color:
		return image.get_pixelv(Vector2i(PROJECTION.to_screen(point).floor()) - area.position)
	var corner: Color = at.call(Vector3(-6.0 + 0.45, 0.45, 0.0))
	assert_gt(corner.b, corner.r, "ground beside the round post, inside its box's corner")
	var front: Color = at.call(Vector3(-6.0, 0.5, 1.5))
	assert_gt(front.r, front.b, "the post's front")
	var gable: Color = at.call(Vector3(4.0, 0.0, 4.0))
	assert_gt(gable.r, gable.b, "inside the gable triangle: the front wall")
	var beside: Color = at.call(Vector3(6.5, 0.0, 5.5))
	assert_gt(beside.b, beside.r, "above the eave beside the gable: the slope behind")


## Sky share (0–1) at the screen pixel showing the point (channels view).
func _sky(engine: LightEngine, point: Vector3) -> float:
	return _pixel(engine, point).b


## Two blocks 6 × 6 × 8 m with a gap 2 m wide between them (x −1…1, d −3…3).
func _gap() -> Array[Solid]:
	return [_solid(Vector3(-4.0, 3.0, 0.0), Vector3(6.0, 6.0, 8.0)), _solid(Vector3(4.0, 3.0, 0.0), Vector3(6.0, 6.0, 8.0))]


func test_gate_open_ground_sees_the_whole_sky_and_an_open_wall_half() -> void:
	var engine: LightEngine = await _scene(12.0, [])
	assert_almost_eq(_sky(engine, Vector3(0.0, 0.0, 0.0)), 1.0, 0.002, "open ground")
	assert_almost_eq(_sky(engine, Vector3(15.0, -15.0, 0.0)), 1.0, 0.002, "open ground far off")
	var block: LightEngine = await _scene(12.0, [_solid(Vector3(0.0, 0.0, 0.0), Vector3(2.0, 2.0, 3.0))])
	assert_almost_eq(_sky(block, Vector3(0.0, 0.0, 2.0)), 0.5, 0.005, "an open wall sees half the sky")
	assert_almost_eq(_sky(block, Vector3(0.0, -1.0, 3.0)), 1.0, 0.002, "the top of the block")


func test_gate_a_narrow_gap_sees_less_sky_than_the_open_street() -> void:
	var engine: LightEngine = await _scene(12.0, _gap())
	var open: float = _sky(engine, Vector3(0.0, 15.0, 0.0))
	var mouth: float = _sky(engine, Vector3(0.0, 4.0, 0.0))
	var gap: float = _sky(engine, Vector3(0.0, 0.0, 0.0))
	# Out in the street the two blocks still hide about 5 % of the dome.
	assert_gt(open, 0.9, "open street in front of the gap")
	assert_lt(mouth, open, "the gap's mouth sees less")
	assert_lt(gap, mouth, "inside the gap less still")
	assert_lt(gap, 0.4, "the gap sees mostly the walls")
	assert_gt(gap, 0.05, "but never black: the strip of sky above it")


func test_gate_sky_without_stripes_out_of_the_gap() -> void:
	# Pixel by pixel down the screen from the middle of the gap out into the street (d 0 … 12): the
	# sky share only grows, and its slope changes gently: a band is a jump, then flat. The sharpest
	# real bend is the gap's mouth (about 0,005); one direction of the dome is 1/2048. A sky of 64
	# directions bends by 0,02 and more. The gap is open at both ends, so
	# its middle sees the least.
	var engine: LightEngine = await _scene(12.0, _gap())
	var area: Rect2i = engine.buffer_area()
	var image: Image = engine.buffer_image()
	var from: Vector2i = Vector2i(PROJECTION.to_screen(Vector3(0.0, 0.0, 0.0)).floor()) - area.position
	var to: Vector2i = Vector2i(PROJECTION.to_screen(Vector3(0.0, 12.0, 0.0)).floor()) - area.position
	var before: float = image.get_pixel(from.x, from.y).b
	var worst_drop: float = 0.0
	var worst_bend: float = 0.0
	var slope: float = 0.0
	for y: int in range(from.y + 1, to.y + 1):
		var share: float = image.get_pixel(from.x, y).b
		worst_drop = maxf(worst_drop, before - share)
		if y > from.y + 1:
			worst_bend = maxf(worst_bend, absf(share - before - slope))
		slope = share - before
		before = share
	assert_lt(worst_drop, 0.002, "the share never falls on the way out")
	assert_lt(worst_bend, 0.008, "no bands")


func test_gate_sky_is_built_over_frames_then_only_multiplied() -> void:
	var view: SubViewport = SubViewport.new()
	view.add_child(LocationEnvironment.new())
	var ground: Occluder = Occluder.new()
	ground.add_child(_solid(Vector3(0.0, 20.0, -0.1), Vector3(40.0, 40.0, 0.1)))
	view.add_child(ground)
	var engine: LightEngine = LightEngine.new()
	engine.rate = 0.0
	view.add_child(engine)
	add_child_autofree(view)
	await RenderingServer.frame_post_draw
	assert_false(engine.is_sky_complete(), "several frames, not one")
	while not engine.is_sky_complete():
		await RenderingServer.frame_post_draw
	for hour: float in [22.0, 7.0, 13.0]:
		engine.set_hour(hour)
		assert_true(engine.is_sky_complete(), "a new hour does not rebuild the sky")
		await RenderingServer.frame_post_draw
		var state: DayState = engine.state()
		var expected: float = (state.sky_color * state.sky_intensity + state.ambient_color * state.ambient_intensity).get_luminance()
		var open: float = _pixel(engine, Vector3(0.0, 0.0, 0.0)).get_luminance()
		if state.sun_elevation > 0.0:
			expected += state.sun_color.get_luminance() * state.sun_intensity * state.sun_direction.z
		assert_almost_eq(open, expected, expected * 0.01, "%d:00 open ground: ambient + sky + sun" % hour)


func test_debug_view_channels_shows_sun_in_red_and_sky_in_blue() -> void:
	var engine: LightEngine = await _scene(12.5, _gap())
	var open: Color = _pixel(engine, Vector3(0.0, 15.0, 0.0))
	assert_almost_eq(open.r, engine.state().sun_direction.z, 0.001, "red: the sun's cosine on open ground")
	assert_gt(open.b, 0.9, "blue: the sky share")
	assert_eq(open.g, 0.0, "green: no artificial channel yet")


## Luma the A′ pass gives a flat, evenly lit pixel: the middle of its level, after exposure.
func _level_of(engine: LightEngine, lux: Color) -> float:
	var state: DayState = engine.state()
	var stops: float = engine.tuning_set().level_stops
	var steps: float = log(lux.get_luminance() / state.level_anchor) / log(2.0) / stops + 0.5
	return state.exposure * state.level_anchor * pow(2.0, floorf(steps) * stops)


func test_the_picture_gets_open_ground_light_styled_into_levels() -> void:
	var engine: LightEngine = await _location(10.0)
	engine.set_debug_view(LightEngine.DebugView.NONE)
	for hour: float in [10.0, 21.0]:
		engine.set_hour(hour)
		await RenderingServer.frame_post_draw
		var pixel: Vector2i = Vector2i(PROJECTION.to_screen(Vector3(-6.0, 6.0, 0.0)).floor()) - engine.buffer_area().position
		var lux: Color = engine.buffer_image().get_pixelv(pixel)
		var styled: Color = engine.styled_image().get_pixelv(pixel)
		assert_almost_eq(styled.get_luminance(), _level_of(engine, lux), _level_of(engine, lux) * 0.01,
				"open ground at %s h" % hour)
		assert_almost_eq(styled.b / styled.r, lux.b / lux.r, 0.01, "the colour stays")


# Sky oracle (research 92 §5a): the sky share of ground points beside boxes, computed on the CPU
# with plain ray–box tests over a cosine-weighted dome, against the buffer's sky layer. The gates
# check the sky layer, the projection and how solids stand, not the tuning.

## Directions of the oracle's dome (a finer set than the sky layer's 2048).
const ORACLE_DIRECTIONS: int = 8192
const GOLDEN_ANGLE: float = 2.39996323


## The cosine-weighted share of the sky an upward-facing ground point sees past the boxes
## (each an AABB: position, size), from just above the ground as the sky layer starts its rays.
func _oracle_sky(point: Vector3, boxes: Array[AABB]) -> float:
	var start: Vector3 = point + Vector3(0.0, 0.0, 0.02)
	var seen: int = 0
	for i: int in ORACLE_DIRECTIONS:
		var r: float = sqrt((i + 0.5) / ORACLE_DIRECTIONS)
		var angle: float = i * GOLDEN_ANGLE
		var direction: Vector3 = Vector3(r * cos(angle), r * sin(angle), sqrt(maxf(1.0 - r * r, 0.0)))
		var open: bool = true
		for box: AABB in boxes:
			if box.intersects_ray(start, direction) != null:
				open = false
				break
		if open:
			seen += 1
	return float(seen) / ORACLE_DIRECTIONS


## A solid's box in world metres (`position_m` is the front-bottom centre).
func _box_of(solid: Solid) -> AABB:
	return AABB(solid.position_m - Vector3(solid.size_m.x * 0.5, solid.size_m.y, 0.0), solid.size_m)


## The ground point at the centre of the buffer pixel showing the ground at (x, d).
func _ground_at_pixel(engine: LightEngine, x: float, d: float) -> Vector3:
	var pixel: Vector2 = PROJECTION.to_screen(Vector3(x, d, 0.0)).floor() + Vector2(0.5, 0.5)
	return Vector3(pixel.x / PROJECTION.px_per_m, pixel.y / (PROJECTION.px_per_m * PROJECTION.depth_factor), 0.0)


func _ev(ratio: float) -> float:
	return log(ratio) / log(2.0)


func test_gate_sky_oracle_around_a_crate_on_open_ground() -> void:
	# A crate 0.6 m under the whole sky; ground in front of it (d) and beside it (x). Research 92 §1c:
	# about −0.67 / −0.30 / −0.11 EV at 10 / 30 / 60 cm.
	var crate: Solid = _solid(Vector3(0.0, 0.3, 0.0), Vector3(0.6, 0.6, 0.6))
	var engine: LightEngine = await _scene(12.0, [crate])
	var boxes: Array[AABB] = [_box_of(crate)]
	for away: float in [0.02, 0.1, 0.3, 0.6]:
		for along_x: bool in [false, true]:
			var at: Vector3 = Vector3(0.3 + away, 0.0, 0.0) if along_x else Vector3(0.0, 0.3 + away, 0.0)
			var ground: Vector3 = _ground_at_pixel(engine, at.x, at.y)
			var buffer_ev: float = _ev(_sky(engine, at))
			var oracle_ev: float = _ev(_oracle_sky(ground, boxes))
			assert_almost_eq(buffer_ev, oracle_ev, 0.1, "%s cm %s the crate" % [away * 100.0, "beside" if along_x else "in front of"])
	var ten_cm: float = _ev(_oracle_sky(Vector3(0.0, 0.4, 0.0), boxes))
	assert_almost_eq(ten_cm, -0.67, 0.05, "the oracle agrees with research 92 (10 cm)")


## Walls 15 m high on both sides of a street 12 m wide (faces at x −1.3 and 10.7).
func _street_walls() -> Array[Solid]:
	return [_solid(Vector3(-1.8, 20.0, 0.0), Vector3(1.0, 40.0, 15.0)), _solid(Vector3(11.2, 20.0, 0.0), Vector3(1.0, 40.0, 15.0))]


func test_gate_a_crate_by_a_wall_takes_no_sky_the_wall_took() -> void:
	# A crate 1 m off the left wall. Occluders overlap, they do not add up (research 91 §3): on the
	# street side the crate adds next to no darkening, in the gap by the wall it takes much of what
	# the wall left.
	var street_side: Vector3 = Vector3(0.6, 0.0, 0.0) # 30 cm off the crate
	var gap: Vector3 = Vector3(-0.4, 0.0, 0.0) # 10 cm off the crate
	var bare: LightEngine = await _scene(12.0, _street_walls())
	var bare_street_side: float = _sky(bare, street_side)
	var bare_gap: float = _sky(bare, gap)
	bare.get_parent().free()
	var solids: Array[Solid] = _street_walls()
	solids.append(_solid(Vector3(0.0, 0.3, 0.0), Vector3(0.6, 0.6, 0.6)))
	var engine: LightEngine = await _scene(12.0, solids)
	assert_gt(_ev(_sky(engine, street_side) / bare_street_side), -0.05, "30 cm on the street side")
	assert_lt(_ev(_sky(engine, gap) / bare_gap), -0.8, "10 cm in the gap by the wall")
	var boxes: Array[AABB] = []
	for solid: Solid in solids:
		boxes.append(_box_of(solid))
	for at: Vector3 in [street_side, gap]:
		var oracle_ev: float = _ev(_oracle_sky(_ground_at_pixel(engine, at.x, at.y), boxes))
		assert_almost_eq(_ev(_sky(engine, at)), oracle_ev, 0.1, "the oracle at x %s" % at.x)


func test_the_buffers_alpha_is_the_suns_share_and_smooth_sky_keeps_the_shade_as_it_is() -> void:
	# The outdoor tuning set styles sky light smooth (the human's pick, ticket 11).
	var engine: LightEngine = await _location(10.0)
	engine.set_debug_view(LightEngine.DebugView.NONE)
	await RenderingServer.frame_post_draw
	var sunny: Color = _pixel(engine, Vector3(-6.0, 6.0, 0.0))
	assert_almost_eq(sunny.a, engine.state().sun_direction.z, 0.002, "open ground: the sun's cosine")
	var shade_point: Vector3 = Vector3(1.0, 2.8, 0.0)
	var shade: Color = _pixel(engine, shade_point)
	assert_eq(shade.a, 0.0, "the post's shadow: no sun")
	var at: Vector2i = Vector2i(PROJECTION.to_screen(shade_point).floor()) - engine.buffer_area().position
	var styled: Color = engine.styled_image().get_pixelv(at)
	var expected: float = shade.get_luminance() * engine.state().exposure
	assert_almost_eq(styled.get_luminance(), expected, expected * 0.01, "the shade's sky light, unstyled")


## A Location for the penumbra gates: ground and a tall post 1×1×6 m at x, d = 0; the sun's disc
## `disc_deg` (radius) all day, a widest penumbra wide enough not to cut the gates' widths, and the
## penumbra of ticket 14 on or off.
func _penumbra_scene(hour: float, disc_deg: float, on: bool = true) -> LightEngine:
	var view: SubViewport = SubViewport.new()
	view.size = Vector2i(8, 8)
	var environment: LocationEnvironment = LocationEnvironment.new()
	environment.tuning_set = environment.tuning_set.duplicate() as TuningSet
	environment.tuning_set.penumbra_gain = 1.0
	environment.tuning_set.penumbra_max_px = 32.0
	view.add_child(environment)
	var ground: Occluder = Occluder.new()
	ground.add_child(_solid(Vector3(0.0, 20.0, -0.1), Vector3(40.0, 40.0, 0.1)))
	view.add_child(ground)
	var post: Occluder = Occluder.new()
	post.add_child(_solid(Vector3(0.0, 0.5, 0.0), Vector3(1.0, 1.0, 6.0)))
	view.add_child(post)
	var engine: LightEngine = LightEngine.new()
	engine.rate = 0.0
	engine.curves = engine.curves.duplicate() as DayCurves
	engine.curves.sun_disc = Curve.new()
	engine.curves.sun_disc.max_value = 45.0
	engine.curves.sun_disc.max_domain = 24.0
	engine.curves.sun_disc.add_point(Vector2(0.0, disc_deg))
	engine.curves.sun_disc.add_point(Vector2(24.0, disc_deg))
	view.add_child(engine)
	add_child_autofree(view)
	engine.set_penumbra_on(on)
	engine.set_hour(hour)
	await _channels_view(engine)
	return engine


## Pixels of the post's noon shadow edge at depth d (neither full sun nor full shade), scanning the
## ground row from the post's axis 3 m to the east (right).
func _penumbra_px(engine: LightEngine, d: float) -> int:
	var image: Image = engine.buffer_image()
	var start: Vector2i = Vector2i(PROJECTION.to_screen(Vector3(0.0, d, 0.0)).floor()) - engine.buffer_area().position
	var steps: int = int(3.0 * PROJECTION.px_per_m)
	var full: float = image.get_pixel(start.x + steps, start.y).r
	var count: int = 0
	for step: int in steps:
		var share: float = image.get_pixel(start.x + step, start.y).r / full
		if share > 0.02 and share < 0.98:
			count += 1
	return count


func test_gate_penumbra_widens_away_from_the_occluder() -> void:
	var engine: LightEngine = await _penumbra_scene(12.0, 2.4)
	var near: int = _penumbra_px(engine, 1.2)
	var far: int = _penumbra_px(engine, 7.0)
	assert_gt(near, 0, "soft even at the base")
	assert_gt(far, near * 2, "the far end of the shadow is softer: near %d px, far %d px" % [near, far])


func test_gate_penumbra_widens_with_the_sun_disc() -> void:
	var small: LightEngine = await _penumbra_scene(12.0, 1.2)
	var small_px: int = _penumbra_px(small, 5.0)
	small.get_parent().queue_free()
	await RenderingServer.frame_post_draw
	var large: LightEngine = await _penumbra_scene(12.0, 3.6)
	var large_px: int = _penumbra_px(large, 5.0)
	assert_gt(large_px, small_px * 2, "a larger disc, a wider penumbra: %d px vs %d px" % [large_px, small_px])


func test_gate_penumbra_stops_at_the_tuning_sets_widest() -> void:
	var engine: LightEngine = await _penumbra_scene(12.0, 3.6)
	engine.tuning_set().penumbra_max_px = 4.0
	engine.set_penumbra_on(true)
	await RenderingServer.frame_post_draw
	assert_lte(_penumbra_px(engine, 7.0), 5, "at most the widest penumbra (+1 px of rounding)")


func test_penumbra_off_casts_the_hard_shadow_of_before() -> void:
	var engine: LightEngine = await _penumbra_scene(12.0, 3.6, false)
	assert_lte(_penumbra_px(engine, 7.0), 1, "one ray: no penumbra")
