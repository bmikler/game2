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
