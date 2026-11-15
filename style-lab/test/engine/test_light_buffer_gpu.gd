extends GutTest
## Location → light buffer (GPU, window off screen). Gates check rules of light, not the look.

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
	await RenderingServer.frame_post_draw
	return engine


func _solid(at: Vector3, size: Vector3) -> Solid:
	var solid: Solid = Solid.new()
	solid.position_m = at
	solid.size_m = size
	return solid


## Natural light (lux) on the ground at (x, d).
func _ground(engine: LightEngine, x: float, d: float) -> float:
	var pixel: Vector2i = Vector2i(PROJECTION.to_screen(Vector3(x, d, 0.0)).floor()) - engine.buffer_area().position
	return engine.buffer_image().get_pixelv(pixel).get_luminance()


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
	assert_gt(_ground(engine, 1.0, 2.8), 0.0)


func test_the_top_of_the_post_takes_the_sun_its_shaded_front_does_not() -> void:
	var engine: LightEngine = await _location(12.5)
	var area: Rect2i = engine.buffer_area()
	var top: Vector2i = Vector2i(PROJECTION.to_screen(Vector3(0.0, 0.0, 3.0)).floor()) - area.position
	var front: Vector2i = Vector2i(PROJECTION.to_screen(Vector3(0.0, 0.5, 1.5)).floor()) - area.position
	var image: Image = engine.buffer_image()
	assert_gt(image.get_pixelv(top).get_luminance(), image.get_pixelv(front).get_luminance() * 2.0,
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
	await RenderingServer.frame_post_draw
	return engine


func _shaped(at: Vector3, size: Vector3, shape: Solid.Shape) -> Solid:
	var solid: Solid = _solid(at, size)
	solid.shape = shape
	return solid


## Natural light (lux) at the screen pixel showing the point (x, d, z) in metres.
func _lux(engine: LightEngine, point: Vector3) -> float:
	var pixel: Vector2i = Vector2i(PROJECTION.to_screen(point).floor()) - engine.buffer_area().position
	return engine.buffer_image().get_pixelv(pixel).get_luminance()


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
