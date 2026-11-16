extends GutTest
## Assets in the light buffer (GPU, window off screen): sprite pixels lie on their invisible solids,
## take the normal map's normal (or the face's), and the solids still cast shadow.

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")
## The normal map's empty pixel (no normal) and a normal in the export's encoding.
const NO_NORMAL: Color = Color8(128, 128, 128)


## A synthetic Location: ground and the given nodes; waits for the sky, then shows `view`.
func _scene(hour: float, nodes: Array[Node], tuning: TuningSet = null,
		view: LightEngine.DebugView = LightEngine.DebugView.CHANNELS) -> LightEngine:
	var root: SubViewport = SubViewport.new()
	root.size = Vector2i(8, 8)
	var environment: LocationEnvironment = LocationEnvironment.new()
	if tuning != null:
		environment.tuning_set = tuning
	root.add_child(environment)
	var ground: Occluder = Occluder.new()
	ground.add_child(_solid(Vector3(0.0, 20.0, -0.1), Vector3(40.0, 40.0, 0.1)))
	root.add_child(ground)
	for node: Node in nodes:
		root.add_child(node)
	var engine: LightEngine = LightEngine.new()
	engine.rate = 0.0
	root.add_child(engine)
	add_child_autofree(root)
	engine.set_hour(hour)
	while not engine.is_sky_complete():
		await RenderingServer.frame_post_draw
	engine.set_debug_view(view)
	await RenderingServer.frame_post_draw
	return engine


func _solid(at: Vector3, size: Vector3, shape: Solid.Shape = Solid.Shape.BOX) -> Solid:
	var solid: Solid = Solid.new()
	solid.position_m = at
	solid.size_m = size
	solid.shape = shape
	return solid


## An asset at `at` whose sprite is opaque over the screen rectangle of `bounds` (metres relative to
## the anchor); `normal_of` (sprite pixel → encoded colour) makes a normal map when given.
func _asset(at: Vector3, solids: Array[Solid], bounds: AABB, normal_of: Callable = Callable()) -> Occluder:
	var top_left: Vector2 = PROJECTION.to_screen(Vector3(bounds.position.x, bounds.position.y, bounds.end.z))
	var bottom_right: Vector2 = PROJECTION.to_screen(Vector3(bounds.end.x, bounds.end.y, bounds.position.z))
	var size: Vector2i = Vector2i((bottom_right - top_left).round())
	var sprite: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	sprite.fill(Color(0.7, 0.6, 0.5, 1.0))
	var asset: Occluder = Occluder.new()
	for solid: Solid in solids:
		asset.add_child(solid)
	var node: AssetSprite = AssetSprite.new()
	node.texture = ImageTexture.create_from_image(sprite)
	node.anchor_px = Vector2i(-top_left.round())
	if normal_of.is_valid():
		var normals: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
		for y: int in size.y:
			for x: int in size.x:
				var color: Color = normal_of.call(Vector2i(x, y) - node.anchor_px)
				normals.set_pixel(x, y, color)
		node.normal_map = ImageTexture.create_from_image(normals)
	asset.add_child(node)
	asset.position_m = at
	return asset


## A normal (x, d, z) in the export's encoding.
static func _encode(normal: Vector3) -> Color:
	var n: Vector3 = normal.normalized()
	return Color8(roundi(128.0 + 127.0 * n.x), roundi(128.0 + 127.0 * n.z), roundi(128.0 + 127.0 * n.y))


## The buffer pixel showing the point (x, d, z) in metres.
func _pixel(engine: LightEngine, point: Vector3) -> Color:
	var pixel: Vector2i = Vector2i(PROJECTION.to_screen(point).floor()) - engine.buffer_area().position
	return engine.buffer_image().get_pixelv(pixel)


## A crate 1 × 1 × 1 m with its anchor at `at`.
func _crate(at: Vector3, normal_of: Callable = Callable()) -> Occluder:
	var box: AABB = AABB(Vector3(-0.5, -1.0, 0.0), Vector3.ONE)
	return _asset(at, [_solid(Vector3.ZERO, Vector3.ONE)], box, normal_of)


## A barrel (upright cylinder 1 m across, 1,5 m tall) with its anchor at `at`.
func _barrel(at: Vector3) -> Occluder:
	var box: AABB = AABB(Vector3(-0.5, -1.0, 0.0), Vector3(1.0, 1.0, 1.5))
	return _asset(at, [_solid(Vector3.ZERO, Vector3(1.0, 1.0, 1.5), Solid.Shape.CYLINDER)], box)


## A point on the barrel's front at `across` (−1 left … 1 right) and height 0,75 m.
static func _on_barrel(at: Vector3, across: float) -> Vector3:
	return at + Vector3(across * 0.5, -0.5 + sqrt(1.0 - across * across) * 0.5, 0.75)


func test_gate_without_a_normal_map_the_side_toward_the_sun_is_brighter() -> void:
	var at: Vector3 = Vector3(2.0, 2.0, 0.0)
	var morning: LightEngine = await _scene(9.0, [_barrel(at)])
	var left: float = _pixel(morning, _on_barrel(at, -0.98)).r
	var right: float = _pixel(morning, _on_barrel(at, 0.98)).r
	assert_gt(left, 0.1, "9:00, the eastern sun lights the barrel's left")
	assert_gt(left, right + 0.1)
	var afternoon: LightEngine = await _scene(15.0, [_barrel(at)])
	assert_gt(_pixel(afternoon, _on_barrel(at, 0.98)).r, _pixel(afternoon, _on_barrel(at, -0.98)).r + 0.1,
			"15:00, the western sun lights its right")


## A crate whose normal map tilts its top's left half to the left and its right half to the right.
func _tilted_crate(at: Vector3) -> Occluder:
	var tilt: Callable = func(pixel: Vector2i) -> Color:
		return _encode(Vector3(-0.6 if pixel.x < 0 else 0.6, 0.0, 0.8))
	return _crate(at, tilt)


func test_gate_with_a_normal_map_the_side_toward_the_sun_is_brighter() -> void:
	var at: Vector3 = Vector3(2.0, 2.0, 0.0)
	var top_left: Vector3 = at + Vector3(-0.25, -0.5, 1.0)
	var top_right: Vector3 = at + Vector3(0.25, -0.5, 1.0)
	var morning: LightEngine = await _scene(9.0, [_tilted_crate(at)])
	assert_gt(_pixel(morning, top_left).r, _pixel(morning, top_right).r + 0.1, "9:00: the left-facing half")
	var afternoon: LightEngine = await _scene(15.0, [_tilted_crate(at)])
	assert_gt(_pixel(afternoon, top_right).r, _pixel(afternoon, top_left).r + 0.1, "15:00: the right-facing half")


func test_without_modelling_the_normal_map_is_ignored() -> void:
	var tuning: TuningSet = TuningSet.new()
	tuning.receiver_modelling = 0.0
	var at: Vector3 = Vector3(2.0, 2.0, 0.0)
	var engine: LightEngine = await _scene(9.0, [_tilted_crate(at)], tuning)
	var flat: float = engine.state().sun_direction.z
	assert_almost_eq(_pixel(engine, at + Vector3(-0.25, -0.5, 1.0)).r, flat, 0.002, "the top's own normal")
	assert_almost_eq(_pixel(engine, at + Vector3(0.25, -0.5, 1.0)).r, flat, 0.002)


func test_a_sprite_pixel_lies_on_its_solid_and_the_top_takes_the_sun_unshaded_by_it() -> void:
	var at: Vector3 = Vector3(2.0, 2.0, 0.0)
	var engine: LightEngine = await _scene(12.5, [_crate(at)])
	assert_almost_eq(_pixel(engine, at + Vector3(0.0, -0.5, 1.0)).r, engine.state().sun_direction.z, 0.002,
			"the top: the sun's cosine, no shadow from its own solid")
	assert_eq(_pixel(engine, at + Vector3(0.0, 0.0, 0.5)).r, 0.0, "the front faces north, away from the noon sun")
	assert_almost_eq(_pixel(engine, at + Vector3(0.0, -0.5, 1.0)).b, 1.0, 0.01, "the top sees the whole sky")
	assert_almost_eq(_pixel(engine, at + Vector3(0.0, 0.0, 0.5)).b, 0.5, 0.02, "the front, an open wall: half")


func test_the_invisible_solids_cast_shadow_and_transparent_pixels_show_the_ground() -> void:
	# A table: a top 0,1 m thick on a single leg; the sprite is opaque only over the top's front.
	var at: Vector3 = Vector3(2.0, 2.0, 0.0)
	var top: Solid = _solid(Vector3.ZERO, Vector3(1.0, 1.0, 1.0), Solid.Shape.RAISED_BOX)
	top.clearance_m = 0.9
	var table: Occluder = _asset(at, [top, _solid(Vector3(0.0, -0.45, 0.0), Vector3(0.1, 0.1, 0.9))],
			AABB(Vector3(-0.5, -1.0, 0.9), Vector3(1.0, 1.0, 0.1)))
	var engine: LightEngine = await _scene(12.5, [table])
	var sun: Vector3 = engine.state().sun_direction
	var open: float = _pixel(engine, Vector3(-6.0, 6.0, 0.0)).r
	assert_gt(open, 0.3)
	# Ground under the top, seen through the sprite's transparent part, in the top's shadow.
	var shade: Vector3 = at + Vector3(0.3, -0.5, 0.95) - sun * (0.95 / sun.z)
	assert_eq(_pixel(engine, shade).r, 0.0, "the top's shadow on the ground")
	assert_almost_eq(_pixel(engine, at + Vector3(-0.3, 0.5, 0.0)).r, open, 0.002, "beside the shadow: open ground")


func test_in_the_shadow_of_a_house_the_sprite_takes_sky_light() -> void:
	var house: Occluder = Occluder.new()
	house.add_child(_solid(Vector3(2.0, -1.0, 0.0), Vector3(8.0, 4.0, 8.0)))
	var at: Vector3 = Vector3(2.0, 1.5, 0.0)
	var engine: LightEngine = await _scene(12.5, [house, _crate(at)])
	var top: Color = _pixel(engine, at + Vector3(0.0, -0.5, 1.0))
	assert_eq(top.r, 0.0, "no sun in the house's shadow")
	assert_gt(top.b, 0.2, "but the sky")
	assert_lt(top.b, 0.9, "less of it than in the open")
	engine.set_debug_view(LightEngine.DebugView.NONE)
	await RenderingServer.frame_post_draw
	assert_gt(_pixel(engine, at + Vector3(0.0, -0.5, 1.0)).get_luminance(), 0.0, "not black")


## A crate whose normal map turns its front's halves to the sides (as a rounded front).
func _rounded_crate(at: Vector3) -> Occluder:
	var round: Callable = func(pixel: Vector2i) -> Color:
		return _encode(Vector3(-0.9 if pixel.x < 0 else 0.9, 0.45, 0.0))
	return _crate(at, round)


func test_rim_light_lights_edges_turned_from_the_camera_against_a_sun_behind() -> void:
	var at: Vector3 = Vector3(2.0, 2.0, 0.0)
	var front: Vector3 = at + Vector3(-0.3, 0.0, 0.5)
	var plain: LightEngine = await _scene(12.5, [_rounded_crate(at)], null, LightEngine.DebugView.NONE)
	var dark: float = _pixel(plain, front).get_luminance()
	var plain_ground: float = _pixel(plain, Vector3(-6.0, 6.0, 0.0)).get_luminance()
	# One Location at a time: the engine takes the first LocationEnvironment in the tree.
	plain.get_parent().queue_free()
	await get_tree().process_frame
	var tuning: TuningSet = TuningSet.new()
	tuning.receiver_rim = 1.0
	var rimmed: LightEngine = await _scene(12.5, [_rounded_crate(at)], tuning, LightEngine.DebugView.NONE)
	assert_gt(_pixel(rimmed, front).get_luminance(), dark * 1.2, "the noon sun behind the crate rims its side")
	assert_almost_eq(_pixel(rimmed, Vector3(-6.0, 6.0, 0.0)).get_luminance(), plain_ground, 1.0,
			"the ground is no receiver of rim light")


func test_fill_keeps_a_least_light_on_sprites_only() -> void:
	var house: Occluder = Occluder.new()
	house.add_child(_solid(Vector3(2.0, -1.0, 0.0), Vector3(8.0, 4.0, 8.0)))
	var at: Vector3 = Vector3(2.0, 1.5, 0.0)
	var tuning: TuningSet = TuningSet.new()
	tuning.receiver_fill = 1.0
	var engine: LightEngine = await _scene(12.5, [house, _crate(at)], tuning, LightEngine.DebugView.NONE)
	var state: DayState = engine.state()
	var open_sky: float = (state.ambient_color * state.ambient_intensity + state.sky_color * state.sky_intensity).get_luminance()
	assert_gt(_pixel(engine, at + Vector3(0.0, 0.0, 0.5)).get_luminance(), open_sky * 0.99, "the crate's front: at least open sky")
	assert_lt(_pixel(engine, Vector3(-1.0, 1.0, 0.0)).get_luminance(), open_sky * 0.9, "the ground in the shade keeps its own")
