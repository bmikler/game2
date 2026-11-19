extends GutTest
## Moving Occluders (engine ticket 17, GPU, window off screen): a moving solid's shadow is the shadow
## of the same solid standing still, computed every frame around it.

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")
const LUX: float = 50.0
## A person as an upright cylinder (wayfinder 33, preset A4: radius 0.27 m).
const BODY: Vector3 = Vector3(0.54, 0.54, 1.8)


func _profile(reach: float = 10.0) -> SourceProfile:
	var profile: SourceProfile = SourceProfile.new()
	profile.color = Gradient.new()
	profile.color.set_color(0, Color.WHITE)
	profile.color.set_color(1, Color.WHITE)
	profile.intensity = Curve.new()
	profile.intensity.max_value = 100000.0
	profile.intensity.max_domain = 24.0
	for point: Vector2 in [Vector2(0.0, LUX), Vector2(24.0, LUX)]:
		profile.intensity.add_point(point, 0.0, 0.0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	profile.falloff = Curve.new()
	profile.falloff.max_domain = reach
	profile.falloff.add_point(Vector2(0.0, 1.0), 0.0, 0.0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	profile.falloff.add_point(Vector2(reach, 0.0), 0.0, 0.0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	return profile


func _solid(at: Vector3, size: Vector3, shape: Solid.Shape = Solid.Shape.BOX) -> Solid:
	var solid: Solid = Solid.new()
	solid.position_m = at
	solid.size_m = size
	solid.shape = shape
	return solid


## Ground, a lamp at `lamp` (none: Vector3.INF) and a body standing at `body_at` (none: INF), moving
## or not; waits until every layer is built and the moving layer drew.
func _scene(hour: float, lamp: Vector3, body_at: Vector3, moving: bool) -> LightEngine:
	var view: SubViewport = SubViewport.new()
	view.size = Vector2i(8, 8)
	view.add_child(LocationEnvironment.new())
	var ground: Occluder = Occluder.new()
	ground.add_child(_solid(Vector3(0.0, 20.0, -0.1), Vector3(40.0, 40.0, 0.1)))
	view.add_child(ground)
	if body_at != Vector3.INF:
		var body: Occluder = Occluder.new()
		body.moving = moving
		body.position_m = body_at
		body.add_child(_solid(Vector3(0.0, BODY.y * 0.5, 0.0), BODY, Solid.Shape.CYLINDER))
		view.add_child(body)
	if lamp != Vector3.INF:
		var source: LightSource = LightSource.new()
		source.position_m = lamp
		source.size_m = Vector2(0.24, 0.24)
		source.profile = _profile()
		view.add_child(source)
	var engine: LightEngine = LightEngine.new()
	engine.rate = 0.0
	engine.moving_in_view_only = false
	view.add_child(engine)
	add_child_autofree(view)
	engine.set_hour(hour)
	while not engine.is_complete():
		await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	return engine


func _done(engine: LightEngine) -> void:
	var view: Node = engine.get_parent()
	view.get_parent().remove_child(view)
	view.free()


func _pixel(engine: LightEngine, point: Vector3) -> Vector2i:
	return Vector2i(PROJECTION.to_screen(point).floor()) - engine.buffer_area().position


## Ground points round a body at the origin that its own picture does not cover (left, right, before).
func _ground_points() -> Array[Vector3]:
	var points: Array[Vector3] = []
	for x: float in [-3.0, -2.0, -1.2, -0.6, 0.6, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0]:
		for d: float in [-1.0, -0.4, 0.0, 0.4, 1.0]:
			points.append(Vector3(x, d, 0.0))
	for x: float in [-0.2, 0.0, 0.2]:
		points.append(Vector3(x, 0.6, 0.0))
		points.append(Vector3(x, 1.2, 0.0))
	return points


func _artificial_at(points: Array[Vector3], moving: bool, lamp: Vector3) -> Array[float]:
	var engine: LightEngine = await _scene(22.0, lamp, Vector3.ZERO, moving)
	var image: Image = engine.artificial_image()
	var values: Array[float] = []
	for point: Vector3 in points:
		values.append(image.get_pixelv(_pixel(engine, point)).get_luminance())
	_done(engine)
	return values


func test_gate_moving_body_casts_the_lamps_shadow_of_the_body_standing_still() -> void:
	var points: Array[Vector3] = _ground_points()
	for lamp: Vector3 in [Vector3(-2.0, 0.3, 3.0), Vector3(1.0, -1.5, 4.2)]:
		var still: Array[float] = await _artificial_at(points, false, lamp)
		var moving: Array[float] = await _artificial_at(points, true, lamp)
		var free: LightEngine = await _scene(22.0, lamp, Vector3.INF, false)
		var open: Image = free.artificial_image()
		var shaded: int = 0
		for index: int in points.size():
			var unshaded: float = open.get_pixelv(_pixel(free, points[index])).get_luminance()
			if still[index] < unshaded * 0.5:
				shaded += 1
			assert_almost_eq(moving[index], still[index], maxf(unshaded * 0.06, 0.05),
					"lamp %s, ground %s: moving %.3f, still %.3f lx" % [lamp, points[index], moving[index], still[index]])
		_done(free)
		assert_gt(shaded, 2, "the body shades some of the ground points from the lamp at %s" % lamp)


## The sun (red) and sky (blue) shares of the channels view at each point.
func _natural_at(points: Array[Vector3], moving: bool, hour: float) -> Array[Vector2]:
	var engine: LightEngine = await _scene(hour, Vector3.INF, Vector3.ZERO, moving)
	engine.set_debug_view(LightEngine.DebugView.CHANNELS)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var image: Image = engine.buffer_image()
	var values: Array[Vector2] = []
	for point: Vector3 in points:
		var pixel: Color = image.get_pixelv(_pixel(engine, point))
		values.append(Vector2(pixel.r, pixel.b))
	_done(engine)
	return values


func test_gate_moving_body_casts_the_suns_shadow_and_hides_the_sky_like_the_body_standing_still() -> void:
	var points: Array[Vector3] = _ground_points()
	for hour: float in [10.0, 15.0]:
		var still: Array[Vector2] = await _natural_at(points, false, hour)
		var moving: Array[Vector2] = await _natural_at(points, true, hour)
		var in_shadow: int = 0
		for index: int in points.size():
			if still[index].x < 0.05:
				in_shadow += 1
			assert_almost_eq(moving[index].x, still[index].x, 0.05, "%.0f h, sun at %s" % [hour, points[index]])
			assert_almost_eq(moving[index].y, still[index].y, 0.03, "%.0f h, sky at %s" % [hour, points[index]])
		assert_gt(in_shadow, 1, "the body shades some ground points from the sun at %.0f h" % hour)


## A figure 2 m tall from an image: legs (0.8 m) at x −0.2…−0.1 and 0.1…0.2 m, a body above
## −0.2…0.2 m, 0.2 m deep.
func _figure() -> SilhouetteStack:
	var sprite: Image = Image.create_empty(40, 80, false, Image.FORMAT_RGBA8)
	sprite.fill_rect(Rect2i(12, 48, 4, 32), Color.WHITE)
	sprite.fill_rect(Rect2i(24, 48, 4, 32), Color.WHITE)
	sprite.fill_rect(Rect2i(12, 8, 16, 40), Color.WHITE)
	var across: Image = Image.create_empty(40, 80, false, Image.FORMAT_RGBA8)
	across.fill_rect(Rect2i(16, 8, 8, 72), Color.WHITE)
	var stack: SilhouetteStack = SilhouetteStack.new(1.0 / PROJECTION.px_per_m)
	stack.add_frame(sprite, Vector2i(20, 80), across, Vector2i(20, 80))
	return stack


## The sun's share (channels view, red) at each point with the figure at the origin.
func _sun_on_figure(points: Array[Vector3], moving: bool) -> Array[float]:
	var view: SubViewport = SubViewport.new()
	view.size = Vector2i(8, 8)
	view.add_child(LocationEnvironment.new())
	var ground: Occluder = Occluder.new()
	ground.add_child(_solid(Vector3(0.0, 20.0, -0.1), Vector3(40.0, 40.0, 0.1)))
	view.add_child(ground)
	var figure: Occluder = Occluder.new()
	figure.moving = moving
	var solid: Solid = _solid(Vector3.ZERO, Vector3.ONE, Solid.Shape.SILHOUETTE)
	solid.silhouette = _figure()
	figure.add_child(solid)
	view.add_child(figure)
	var engine: LightEngine = LightEngine.new()
	engine.rate = 0.0
	engine.moving_in_view_only = false
	view.add_child(engine)
	add_child_autofree(view)
	engine.set_hour(12.0)
	engine.set_debug_view(LightEngine.DebugView.CHANNELS)
	while not engine.is_complete():
		await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var image: Image = engine.buffer_image()
	var values: Array[float] = []
	for point: Vector3 in points:
		values.append(image.get_pixelv(_pixel(engine, point)).r)
	_done(engine)
	return values


func test_gate_silhouette_shadow_has_its_legs_and_moves_like_it_stands() -> void:
	# Noon: the sun in the south, shadows fall north (towards the camera, +d), legs' shadows first.
	var points: Array[Vector3] = [Vector3(-0.15, 0.7, 0.0), Vector3(0.0, 0.7, 0.0), Vector3(0.15, 0.7, 0.0),
			Vector3(0.0, 2.2, 0.0), Vector3(0.6, 0.7, 0.0), Vector3(0.1, 2.6, 0.0)]
	var still: Array[float] = await _sun_on_figure(points, false)
	var moving: Array[float] = await _sun_on_figure(points, true)
	for index: int in points.size():
		assert_almost_eq(moving[index], still[index], 0.05, "sun at %s" % points[index])
	assert_lt(moving[0], 0.1, "the left leg's shadow")
	assert_gt(moving[1], 0.3, "sun between the legs' shadows")
	assert_lt(moving[2], 0.1, "the right leg's shadow")
	assert_lt(moving[3], 0.1, "the body's shadow further on")
	assert_gt(moving[4], 0.3, "open ground beside")
	assert_lt(moving[5], 0.1, "the top of the body's shadow (1.5 m up; at 12:00 the sun is still a little east, so it leans west)")


## A body with a sprite (an opaque 20×72 px rectangle, anchor at its bottom middle) at the origin,
## moving or not, a lamp beside it; the sky share (alpha) and the artificial light at its sprite's
## pixels, and the engine for more.
func _lit_body(moving: bool, hour: float) -> Array[Vector2]:
	var view: SubViewport = SubViewport.new()
	view.size = Vector2i(8, 8)
	view.add_child(LocationEnvironment.new())
	var ground: Occluder = Occluder.new()
	ground.add_child(_solid(Vector3(0.0, 20.0, -0.1), Vector3(40.0, 40.0, 0.1)))
	view.add_child(ground)
	var body: Occluder = Occluder.new()
	body.moving = moving
	body.add_child(_solid(Vector3(0.0, BODY.y * 0.5, 0.0), BODY, Solid.Shape.CYLINDER))
	var sprite: AssetSprite = AssetSprite.new()
	var image: Image = Image.create_empty(20, 72, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.anchor_px = Vector2i(10, 72)
	body.add_child(sprite)
	view.add_child(body)
	var source: LightSource = LightSource.new()
	source.position_m = Vector3(-1.5, 1.5, 2.5)
	source.size_m = Vector2(0.24, 0.24)
	source.profile = _profile()
	view.add_child(source)
	var engine: LightEngine = LightEngine.new()
	engine.rate = 0.0
	engine.moving_in_view_only = false
	view.add_child(engine)
	add_child_autofree(view)
	engine.set_hour(hour)
	while not engine.is_complete():
		await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var artificial: Image = engine.artificial_image()
	var values: Array[Vector2] = []
	for row: int in [10, 30, 50, 66]:
		for column: int in [-8, -4, 0, 4, 8]:
			var pixel: Vector2i = Vector2i(column, -72 + row) - engine.buffer_area().position
			var texel: Color = artificial.get_pixelv(pixel)
			values.append(Vector2(texel.get_luminance(), texel.a))
	_done(engine)
	return values


func test_gate_moving_sprite_takes_the_light_of_the_sprite_standing_still() -> void:
	var still: Array[Vector2] = await _lit_body(false, 22.0)
	var moving: Array[Vector2] = await _lit_body(true, 22.0)
	for index: int in still.size():
		assert_almost_eq(moving[index].x, still[index].x, maxf(still[index].x * 0.1, 0.1), "lamp light at sample %d" % index)
		assert_almost_eq(moving[index].y, still[index].y, 0.05, "sky share at sample %d" % index)
	assert_gt(still[2].y, 0.3, "the front of a body under open sky sees much of it")


func test_moved_body_takes_its_shadow_along() -> void:
	var lamp: Vector3 = Vector3(-2.0, 0.3, 3.0)
	var engine: LightEngine = await _scene(22.0, lamp, Vector3.ZERO, true)
	var behind: Vector3 = Vector3(1.0, 0.0, 0.0)
	var before: float = engine.artificial_image().get_pixelv(_pixel(engine, behind)).get_luminance()
	var body: Occluder
	for node: Node in engine.get_tree().get_nodes_in_group(Occluder.GROUP):
		if (node as Occluder).moving:
			body = node as Occluder
	body.position_m = Vector3(0.0, 3.0, 0.0)
	engine.refresh_moving()
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var after: float = engine.artificial_image().get_pixelv(_pixel(engine, behind)).get_luminance()
	assert_lt(before, after * 0.5, "the ground behind the body lights up once it walks away")
	_done(engine)

