extends GutTest
## Light sources → the artificial channel of the light buffer (GPU, window off screen). Gates check
## rules of light, not the look.

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")
## The test profile's lux where its falloff is 1 (at the source, falling to 0 at its reach).
const LUX: float = 50.0


## A profile at LUX all day unless `hours` says when (hour → lux points), falling linearly from 1 at
## the source to 0 at `reach` metres.
func _profile(reach: float = 10.0, hours: PackedVector2Array = PackedVector2Array()) -> SourceProfile:
	var profile: SourceProfile = SourceProfile.new()
	profile.color = Gradient.new()
	profile.color.set_color(0, Color.WHITE)
	profile.color.set_color(1, Color.WHITE)
	profile.intensity = Curve.new()
	profile.intensity.max_value = 100000.0
	profile.intensity.max_domain = 24.0
	if hours.is_empty():
		hours = PackedVector2Array([Vector2(0.0, LUX), Vector2(24.0, LUX)])
	for point: Vector2 in hours:
		profile.intensity.add_point(point, 0.0, 0.0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	profile.falloff = Curve.new()
	profile.falloff.max_domain = reach
	profile.falloff.add_point(Vector2(0.0, 1.0), 0.0, 0.0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	profile.falloff.add_point(Vector2(reach, 0.0), 0.0, 0.0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	return profile


func _sphere(at: Vector3, diameter: float, profile: SourceProfile) -> LightSource:
	var source: LightSource = LightSource.new()
	source.position_m = at
	source.size_m = Vector2(diameter, diameter)
	source.profile = profile
	return source


func _solid(at: Vector3, size: Vector3) -> Solid:
	var solid: Solid = Solid.new()
	solid.position_m = at
	solid.size_m = size
	return solid


## A synthetic Location: ground (the top of a flat solid at z = 0), the solids and the sources; waits
## until every layer is built.
func _scene(hour: float, sources: Array[LightSource], solids: Array[Solid] = []) -> LightEngine:
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
	for source: LightSource in sources:
		view.add_child(source)
	var engine: LightEngine = LightEngine.new()
	engine.rate = 0.0
	view.add_child(engine)
	add_child_autofree(view)
	engine.set_hour(hour)
	while not engine.is_complete():
		await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	return engine


## The artificial channel's luminance (lux) at the pixel showing the point (x, d, z).
func _artificial(engine: LightEngine, image: Image, point: Vector3) -> float:
	var pixel: Vector2i = Vector2i(PROJECTION.to_screen(point).floor()) - engine.buffer_area().position
	return image.get_pixelv(pixel).get_luminance()


## Removes a scene now: the scene description gathers every source and solid in the tree, so the
## next scene of the same test must not see this one's.
func _done(engine: LightEngine) -> void:
	var view: Node = engine.get_parent()
	view.get_parent().remove_child(view)
	view.free()


## The artificial channel's luminance at each point, in a scene removed afterwards.
func _measure(sources: Array[LightSource], solids: Array[Solid], points: Array[Vector3]) -> Array[float]:
	var engine: LightEngine = await _scene(22.0, sources, solids)
	var image: Image = engine.artificial_image()
	var values: Array[float] = []
	for point: Vector3 in points:
		values.append(_artificial(engine, image, point))
	_done(engine)
	return values


## Ground points around the sources and the post (x −6…6, d −4…4).
func _ground_points() -> Array[Vector3]:
	var points: Array[Vector3] = []
	for x: int in range(-6, 7, 2):
		for d: int in range(-4, 5, 2):
			points.append(Vector3(x + 0.3, d + 0.3, 0.0))
	return points


func _post() -> Array[Solid]:
	return [_solid(Vector3(0.5, 0.3, 0.0), Vector3(0.6, 0.6, 2.0))]


func test_gate_two_sources_together_give_the_sum_of_each_alone() -> void:
	for same_profile: bool in [true, false]:
		var first: SourceProfile = _profile()
		var second: SourceProfile = first if same_profile else _profile(8.0)
		var a_at: Vector3 = Vector3(-2.0, 0.0, 3.0)
		var b_at: Vector3 = Vector3(3.0, 1.5, 2.5)
		var points: Array[Vector3] = _ground_points()
		var alone_a: Array[float] = await _measure([_sphere(a_at, 0.3, first)], _post(), points)
		var alone_b: Array[float] = await _measure([_sphere(b_at, 0.3, second)], _post(), points)
		var both: LightEngine = await _scene(22.0, [_sphere(a_at, 0.3, first), _sphere(b_at, 0.3, second)], _post())
		assert_eq(both.source_light().layer_count(), 1 if same_profile else 2)
		var image_both: Image = both.artificial_image()
		var lit: int = 0
		for index: int in points.size():
			var sum: float = alone_a[index] + alone_b[index]
			var together: float = _artificial(both, image_both, points[index])
			assert_almost_eq(together, sum, sum * 0.01 + 0.01, "%s, one profile: %s" % [points[index], same_profile])
			if sum > 1.0:
				lit += 1
		_done(both)
		assert_gt(lit, 10, "the sources light the ground around them")


func test_gate_the_shadow_of_a_post_falls_away_from_the_lamp() -> void:
	# A lamp 4 m up over x = 0; a post 1.5 m tall at x 1.8…2.2 shades the ground at x 2.2…3.5.
	var engine: LightEngine = await _scene(22.0, [_sphere(Vector3(0.0, 0.0, 4.0), 0.1, _profile())],
			[_solid(Vector3(2.0, 0.2, 0.0), Vector3(0.4, 0.4, 1.5))])
	var image: Image = engine.artificial_image()
	var shaded: float = _artificial(engine, image, Vector3(3.0, 0.0, 0.0))
	var mirrored: float = _artificial(engine, image, Vector3(-3.0, 0.0, 0.0))
	assert_gt(mirrored, 1.0, "the open side is lit")
	assert_lt(shaded, mirrored * 0.05, "behind the post, away from the lamp")
	assert_gt(_artificial(engine, image, Vector3(1.0, 0.0, 0.0)), mirrored, "the lamp's side of the post is lit")


func test_gate_a_bigger_source_softens_the_shadow_edge() -> void:
	var points: Array[Vector3] = []
	for step: int in 40:
		points.append(Vector3(2.0 + step * 0.05, 0.0, 0.0))
		points.append(Vector3(-2.0 - step * 0.05, 0.0, 0.0))
	var shades: Array[float] = []
	for diameter: float in [0.05, 1.2]:
		var values: Array[float] = await _measure([_sphere(Vector3(0.0, 0.0, 4.0), diameter, _profile())],
				[_solid(Vector3(2.0, 0.2, 0.0), Vector3(0.4, 0.4, 1.5))], points)
		var partly: int = 0
		for step: int in 40:
			# Behind the post over the open ground as far on the other side.
			var ratio: float = values[step * 2] / maxf(values[step * 2 + 1], 1e-3)
			if ratio > 0.1 and ratio < 0.9:
				partly += 1
		shades.append(partly)
	assert_gt(shades[1], shades[0] + 2.0, "a 1.2 m lamp gives a wider penumbra than a 5 cm one")


func test_switching_on_at_the_profiles_hours_does_not_build_the_layer_again() -> void:
	var profile: SourceProfile = _profile(10.0, PackedVector2Array([Vector2(0.0, LUX), Vector2(8.0, LUX),
			Vector2(8.5, 0.0), Vector2(16.0, 0.0), Vector2(17.0, LUX), Vector2(24.0, LUX)]))
	var engine: LightEngine = await _scene(12.0, [_sphere(Vector3(0.0, 0.0, 3.0), 0.2, profile)])
	var built: int = engine.source_light().passes_done()
	var under: Vector3 = Vector3(0.3, 0.3, 0.0)
	assert_almost_eq(_artificial(engine, engine.artificial_image(), under), 0.0, 0.001, "off at noon")
	engine.set_hour(16.5)
	await RenderingServer.frame_post_draw
	var half: float = _artificial(engine, engine.artificial_image(), under)
	engine.set_hour(22.0)
	await RenderingServer.frame_post_draw
	var full: float = _artificial(engine, engine.artificial_image(), under)
	assert_gt(full, 1.0, "on at night")
	assert_almost_eq(half, full * 0.5, full * 0.02, "half on half way through switching on")
	assert_eq(engine.source_light().passes_done(), built, "only multiplied, the layer is not built again")


func test_a_source_glows_with_its_light_at_distance_zero() -> void:
	var engine: LightEngine = await _scene(22.0, [_sphere(Vector3(0.0, 0.0, 3.0), 1.0, _profile())])
	assert_almost_eq(_artificial(engine, engine.artificial_image(), Vector3(0.0, 0.0, 3.0)), LUX, LUX * 0.02)


func test_a_rectangle_shines_from_its_face_only() -> void:
	var window: LightSource = LightSource.new()
	window.shape = LightSource.Shape.RECTANGLE
	window.facing = LightSource.Facing.TOWARD_CAMERA
	window.size_m = Vector2(2.0, 1.0)
	window.position_m = Vector3(0.0, -2.0, 1.5)
	window.profile = _profile()
	var engine: LightEngine = await _scene(22.0, [window])
	var image: Image = engine.artificial_image()
	assert_gt(_artificial(engine, image, Vector3(0.3, 0.0, 0.0)), 1.0, "in front of its face")
	assert_almost_eq(_artificial(engine, image, Vector3(2.5, -4.0, 0.0)), 0.0, 0.001, "behind it (beside it on screen)")


func test_a_lit_panes_glass_takes_no_diffuse_light_from_other_sources() -> void:
	# A pane on a wall (front face at d = −2) and a lamp of another profile 0.3 m before the wall,
	# beside the pane: the wall round the pane takes the lamp's light, the glass only its own glow.
	var pane: SourceProfile = _profile()
	var lamp: SourceProfile = _profile(8.0)
	var glass: Vector3 = Vector3(0.45, -1.99, 2.0)
	var beside: Vector3 = Vector3(0.0, -2.0, 3.2)
	var alone: Array[float] = await _measure([_pane(pane)], _wall(), [glass])
	var with_lamp: Array[float] = await _measure([_pane(pane), _sphere(Vector3(1.2, -1.7, 2.0), 0.2, lamp)],
			_wall(), [glass, beside])
	assert_almost_eq(alone[0], LUX, LUX * 0.02, "the glass glows with its own light")
	assert_almost_eq(with_lamp[0], alone[0], LUX * 0.02, "the lamp's light does not land on the glass")
	assert_gt(with_lamp[1], 1.0, "the wall above the pane takes the lamp's light")


func test_a_lamp_before_another_groups_pane_keeps_its_glow() -> void:
	var lamp_at: Vector3 = Vector3(0.0, -1.4, 2.0)
	var values: Array[float] = await _measure([_pane(_profile()), _sphere(lamp_at, 0.4, _profile(8.0))], _wall(),
			[lamp_at])
	assert_gt(values[0], LUX * 1.9, "the lamp's glow adds to the pane's behind it")


## A 1.2 × 1.6 m pane facing the camera, 1 cm before the wall of _wall().
func _pane(profile: SourceProfile) -> LightSource:
	var pane: LightSource = LightSource.new()
	pane.shape = LightSource.Shape.RECTANGLE
	pane.size_m = Vector2(1.2, 1.6)
	pane.position_m = Vector3(0.0, -1.99, 2.0)
	pane.profile = profile
	return pane


## A wall 4 m tall whose front face stands at d = −2.
func _wall() -> Array[Solid]:
	return [_solid(Vector3(0.0, -2.0, 0.0), Vector3(10.0, 1.0, 4.0))]


func test_the_a_prime_mode_switch_changes_the_picture_where_sun_and_lamp_meet() -> void:
	var engine: LightEngine = await _scene(16.0, [_sphere(Vector3(0.0, 0.0, 3.0), 0.3, _profile(12.0,
			PackedVector2Array([Vector2(0.0, 3000.0), Vector2(24.0, 3000.0)])))])
	var sum: Image = engine.styled_image()
	engine.set_style_mode(TuningSet.StyleMode.PER_CHANNEL)
	assert_eq(engine.style_mode(), TuningSet.StyleMode.PER_CHANNEL)
	await RenderingServer.frame_post_draw
	var apart: Image = engine.styled_image()
	var differ: int = 0
	for y: int in range(0, sum.get_height(), 4):
		for x: int in range(0, sum.get_width(), 4):
			if not sum.get_pixel(x, y).is_equal_approx(apart.get_pixel(x, y)):
				differ += 1
	assert_gt(differ, 20, "levels on the sum of sun and lamp differ from levels on each")


func test_debug_view_channels_shows_the_artificial_channel_in_green() -> void:
	var engine: LightEngine = await _scene(22.0, [_sphere(Vector3(0.0, 0.0, 3.0), 0.3, _profile())])
	engine.set_debug_view(LightEngine.DebugView.CHANNELS)
	await RenderingServer.frame_post_draw
	var image: Image = engine.buffer_image()
	var near: Vector2i = Vector2i(PROJECTION.to_screen(Vector3(0.3, 0.3, 0.0)).floor()) - engine.buffer_area().position
	var far: Vector2i = Vector2i(PROJECTION.to_screen(Vector3(15.0, 0.3, 0.0)).floor()) - engine.buffer_area().position
	assert_gt(image.get_pixelv(near).g, 0.5, "under the lamp")
	assert_almost_eq(image.get_pixelv(far).g, 0.0, 0.001, "out of its reach")
