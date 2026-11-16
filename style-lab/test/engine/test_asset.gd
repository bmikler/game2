extends GutTest
## Assets (headless): the import from the Prowadnice v2 export, the asset's place in the scene
## description, the rule for pixels with no solid face beneath, and the normal map's warnings.

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")

## A table as Prowadnice v2 exports it: y into the depth (away from the camera), anchor at (48, 73).
const TABLE_JSON: String = """{
	"zaczepienie_gra": [48, 73],
	"plotno_gra": [96, 96],
	"bryly": [
		{"nazwa": "blat", "typ": "uniesione", "min": [-0.6, 0.0, 0.64], "max": [0.6, 0.8, 0.76]},
		{"nazwa": "noga_0", "typ": "pudelko", "min": [-0.555, 0.04, 0.0], "max": [-0.505, 0.09, 0.64]},
		{"nazwa": "beczka", "typ": "walec", "min": [0.8, 0.0, 0.0], "max": [1.2, 0.4, 0.9]}
	]
}"""


func _sprite(size: Vector2i, opaque: Rect2i) -> ImageTexture:
	var image: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill_rect(opaque, Color(0.6, 0.4, 0.2, 1.0))
	return ImageTexture.create_from_image(image)


func test_import_turns_the_export_into_solids_in_engine_axes() -> void:
	var solids: Array[Solid] = GuidesImport.solids(TABLE_JSON)
	for solid: Solid in solids:
		autofree(solid)
	assert_eq(solids.size(), 3)
	var top: Solid = solids[0]
	assert_eq(top.shape, Solid.Shape.RAISED_BOX, "uniesione: a raised box")
	assert_almost_eq(top.position_m, Vector3(0.0, 0.0, 0.0), Vector3.ONE * 1e-5)
	assert_almost_eq(top.size_m, Vector3(1.2, 0.8, 0.76), Vector3.ONE * 1e-5)
	assert_almost_eq(top.clearance_m, 0.64, 1e-5)
	var leg: Solid = solids[1]
	assert_eq(leg.shape, Solid.Shape.BOX)
	# The export's y grows away from the camera, the engine's d towards it: the front is at d = −0,04.
	assert_almost_eq(leg.position_m, Vector3(-0.53, -0.04, 0.0), Vector3.ONE * 1e-5)
	assert_almost_eq(leg.size_m, Vector3(0.05, 0.05, 0.64), Vector3.ONE * 1e-5)
	assert_eq(solids[2].shape, Solid.Shape.CYLINDER, "walec")
	assert_almost_eq(solids[2].position_m, Vector3(1.0, 0.0, 0.0), Vector3.ONE * 1e-5)
	assert_almost_eq(solids[2].size_m, Vector3(0.4, 0.4, 0.9), Vector3.ONE * 1e-5)


func test_import_reads_the_anchor_pixel() -> void:
	assert_eq(GuidesImport.anchor_px(TABLE_JSON), Vector2i(48, 73))


func test_import_builds_an_asset_occluder_with_its_sprite() -> void:
	var sprite: ImageTexture = _sprite(Vector2i(96, 96), Rect2i(20, 30, 50, 40))
	var asset: Occluder = GuidesImport.build(TABLE_JSON, sprite, null)
	add_child_autofree(asset)
	assert_eq(asset.world_shapes().size(), 3)
	var asset_sprite: AssetSprite = asset.asset_sprite()
	assert_not_null(asset_sprite)
	assert_eq(asset_sprite.texture, sprite)
	assert_eq(asset_sprite.anchor_px, Vector2i(48, 73))


func _asset(at: Vector3, solids: Array[Solid], sprite: Texture2D, anchor: Vector2i) -> Occluder:
	var asset: Occluder = Occluder.new()
	for solid: Solid in solids:
		asset.add_child(solid)
	var asset_sprite: AssetSprite = AssetSprite.new()
	asset_sprite.texture = sprite
	asset_sprite.anchor_px = anchor
	asset.add_child(asset_sprite)
	asset.position_m = at
	return asset


func _box(at: Vector3, size: Vector3) -> Solid:
	var solid: Solid = Solid.new()
	solid.position_m = at
	solid.size_m = size
	return solid


func test_the_sprite_stands_with_its_anchor_on_a_whole_pixel() -> void:
	# x 0,3 m = 12 px; d 0,5 m = 12 px; 0,3 · 0,6 = 7,2 px: the sprite snaps to 7 px.
	var asset: Occluder = _asset(Vector3(0.3, 0.3, 0.0), [_box(Vector3.ZERO, Vector3.ONE)], _sprite(Vector2i(60, 60), Rect2i(0, 0, 60, 60)), Vector2i(30, 50))
	add_child_autofree(asset)
	var sprite: AssetSprite = asset.asset_sprite()
	assert_eq(sprite.top_left_px(), Vector2i(12 - 30, 7 - 50))
	assert_almost_eq(sprite.global_position + sprite.offset, Vector2(sprite.top_left_px()), Vector2.ONE * 1e-4)
	asset.position_m = Vector3(1.0, 0.0, 0.0)
	assert_eq(sprite.top_left_px(), Vector2i(40 - 30, -50), "follows the Occluder")


func _description(nodes: Array[Node]) -> SceneDescription:
	var root: Node = Node.new()
	for node: Node in nodes:
		root.add_child(node)
	add_child_autofree(root)
	return SceneDescription.from_tree(get_tree(), PROJECTION)


func test_an_assets_solids_cast_shadow_but_are_no_receivers() -> void:
	var house: Occluder = Occluder.new()
	house.add_child(_box(Vector3(0.0, -5.0, 0.0), Vector3(4.0, 3.0, 6.0)))
	var crate: Occluder = _asset(Vector3(5.0, 0.0, 0.0), [_box(Vector3.ZERO, Vector3(0.8, 0.6, 0.6))], _sprite(Vector2i(40, 40), Rect2i(4, 4, 32, 32)), Vector2i(20, 30))
	var description: SceneDescription = _description([house, crate])
	assert_eq(description.solids.size(), 2, "both cast shadow")
	assert_eq(description.receivers.size(), 2, "only the house's top and front")
	for receiver: Receiver in description.receivers:
		assert_eq(description.solids[receiver.solid].box.position.x, -2.0)
	assert_eq(description.assets.size(), 1)
	var entry: AssetEntry = description.assets[0]
	assert_almost_eq(description.solids[entry.first_solid].box.position.x, 4.6, 1e-5, "the entry knows its solids")
	assert_eq(entry.solid_count, 1)
	assert_almost_eq(entry.front_d, 0.0, 1e-5)
	assert_true(description.area.encloses(Rect2i(entry.top_left_px, entry.sprite.get_size())), "the area covers the sprite")


func test_assets_are_listed_far_ones_first() -> void:
	var near: Occluder = _asset(Vector3(0.0, 2.0, 0.0), [_box(Vector3.ZERO, Vector3.ONE)], _sprite(Vector2i(8, 8), Rect2i(0, 0, 8, 8)), Vector2i(4, 6))
	var far: Occluder = _asset(Vector3(3.0, -2.0, 0.0), [_box(Vector3.ZERO, Vector3.ONE)], _sprite(Vector2i(8, 8), Rect2i(0, 0, 8, 8)), Vector2i(4, 6))
	var description: SceneDescription = _description([near, far])
	assert_eq(description.assets[0].anchor_m, Vector3(3.0, -2.0, 0.0))
	assert_eq(description.assets[1].anchor_m, Vector3(0.0, 2.0, 0.0))


## A counter 2 × 0,6 × 1 m at the origin.
func _counter() -> SceneDescription:
	var counter: Occluder = _asset(Vector3.ZERO, [_box(Vector3.ZERO, Vector3(2.0, 0.6, 1.0))], _sprite(Vector2i(96, 96), Rect2i(0, 0, 96, 96)), Vector2i(48, 75))
	return _description([counter])


func _screen_m(point: Vector3) -> Vector2:
	return PROJECTION.to_screen(point) / PROJECTION.px_per_m


func test_a_pixel_above_a_top_stands_on_the_tops_middle_plane() -> void:
	var description: SceneDescription = _counter()
	var entry: AssetEntry = description.assets[0]
	# A jar 0,2 m above the counter's top, on the plane halfway through the top (d = −0,3).
	var jar: Vector3 = Vector3(0.5, -0.3, 1.2)
	var rest: Vector3 = entry.rest_point(_screen_m(jar), description.solids, PROJECTION.depth_factor)
	assert_almost_eq(rest, jar, Vector3.ONE * 1e-4)


func test_any_other_loose_pixel_lies_on_the_front_plane_of_the_outline() -> void:
	var description: SceneDescription = _counter()
	var entry: AssetEntry = description.assets[0]
	# A throw hanging beside the counter (x 1,2 is outside it) at 0,5 m.
	var throw: Vector3 = Vector3(1.2, 0.0, 0.5)
	assert_almost_eq(entry.rest_point(_screen_m(throw), description.solids, PROJECTION.depth_factor), throw, Vector3.ONE * 1e-4)
	# Something far above the outline beside the counter: still the front plane.
	var beside: Vector3 = Vector3(1.4, 0.0, 1.5)
	assert_almost_eq(entry.rest_point(_screen_m(beside), description.solids, PROJECTION.depth_factor), beside, Vector3.ONE * 1e-4)


func test_above_two_tops_the_higher_one_counts() -> void:
	# A low box (0,4 m) in front, a high back (1 m) behind it, as a sofa's seat and backrest.
	var seat: Solid = _box(Vector3.ZERO, Vector3(1.0, 0.6, 0.4))
	var back: Solid = _box(Vector3(0.0, -0.6, 0.0), Vector3(1.0, 0.2, 1.0))
	var sofa: Occluder = _asset(Vector3.ZERO, [seat, back], _sprite(Vector2i(64, 64), Rect2i(0, 0, 64, 64)), Vector2i(32, 50))
	var description: SceneDescription = _description([sofa])
	var entry: AssetEntry = description.assets[0]
	var cushion: Vector3 = Vector3(0.0, -0.7, 1.2)
	assert_almost_eq(entry.rest_point(_screen_m(cushion), description.solids, PROJECTION.depth_factor), cushion, Vector3.ONE * 1e-4)


func test_normals_decode_as_prowadnice_v2_encode_them() -> void:
	# 128 + 127·(nx, nz, −ny): R right, G up, B towards the camera; engine axes (x, d, z).
	assert_almost_eq(AssetSprite.decode_normal(Color8(128, 255, 128)), Vector3(0.0, 0.0, 1.0), Vector3.ONE * 1e-5, "up")
	assert_almost_eq(AssetSprite.decode_normal(Color8(128, 128, 255)), Vector3(0.0, 1.0, 0.0), Vector3.ONE * 1e-5, "towards the camera")
	assert_almost_eq(AssetSprite.decode_normal(Color8(1, 128, 128)), Vector3(-1.0, 0.0, 0.0), Vector3.ONE * 1e-5, "left")


func test_a_normal_map_with_an_opaque_pixel_without_a_normal_warns() -> void:
	var sprite: Image = Image.create_empty(4, 4, false, Image.FORMAT_RGBA8)
	sprite.fill_rect(Rect2i(0, 0, 2, 4), Color.WHITE)
	var normals: Image = Image.create_empty(4, 4, false, Image.FORMAT_RGBA8)
	normals.fill(Color8(128, 128, 128))
	normals.fill_rect(Rect2i(0, 0, 2, 3), Color8(128, 128, 255))
	assert_eq(AssetSprite.missing_normals(sprite, normals), 2, "two opaque pixels have the empty normal")
	normals.fill_rect(Rect2i(0, 0, 2, 4), Color8(128, 255, 128))
	assert_eq(AssetSprite.missing_normals(sprite, normals), 0, "transparent pixels need none")


func test_the_sprite_node_shows_the_normal_map_warning() -> void:
	var sprite: Image = Image.create_empty(4, 4, false, Image.FORMAT_RGBA8)
	sprite.fill(Color.WHITE)
	var normals: Image = Image.create_empty(4, 4, false, Image.FORMAT_RGBA8)
	normals.fill(Color8(128, 128, 128))
	var asset: Occluder = _asset(Vector3.ZERO, [_box(Vector3.ZERO, Vector3.ONE)], ImageTexture.create_from_image(sprite), Vector2i(2, 3))
	add_child_autofree(asset)
	var node: AssetSprite = asset.asset_sprite()
	assert_true(node.warnings().is_empty(), "no map, no warning")
	node.normal_map = ImageTexture.create_from_image(normals)
	assert_eq(node.warnings().size(), 1)
	var other: Image = Image.create_empty(8, 4, false, Image.FORMAT_RGBA8)
	node.normal_map = ImageTexture.create_from_image(other)
	assert_string_contains(node.warnings()[0], "size")


func test_the_engine_reports_an_assets_normal_map_warning() -> void:
	var sprite: Image = Image.create_empty(4, 4, false, Image.FORMAT_RGBA8)
	sprite.fill(Color.WHITE)
	var normals: Image = Image.create_empty(4, 4, false, Image.FORMAT_RGBA8)
	normals.fill(Color8(128, 128, 128))
	# A solid as small as the 4 px sprite: no silhouette warning, only the normal map's.
	var asset: Occluder = _asset(Vector3.ZERO, [_box(Vector3.ZERO, Vector3(0.05, 0.05, 0.05))], ImageTexture.create_from_image(sprite), Vector2i(2, 3))
	asset.asset_sprite().normal_map = ImageTexture.create_from_image(normals)
	var root: Node = Node.new()
	root.add_child(LocationEnvironment.new())
	root.add_child(asset)
	var engine: LightEngine = LightEngine.new()
	root.add_child(engine)
	add_child_autofree(root)
	assert_eq(engine.warnings().size(), 1)
	assert_string_contains(engine.warnings()[0], "no normal")


func test_solids_must_lie_in_the_sprites_silhouette() -> void:
	# A box 1 × 1 × 1 m covers screen x −20…20, y −64…0 around the anchor (research 92 §5b: a solid
	# beyond the thing darkens ground where nothing stands). One pixel off is allowed.
	var box: Solid = autofree(_box(Vector3.ZERO, Vector3.ONE))
	var shapes: Array[SolidShape] = [box.local_shape()]
	var anchor: Vector2i = Vector2i(30, 70)
	var fits: Image = _sprite(Vector2i(60, 80), Rect2i(10, 6, 40, 64)).get_image()
	assert_eq(AssetSprite.solid_pixels_outside(fits, anchor, shapes), 0)
	var a_pixel_short: Image = _sprite(Vector2i(60, 80), Rect2i(10, 6, 39, 64)).get_image()
	assert_eq(AssetSprite.solid_pixels_outside(a_pixel_short, anchor, shapes), 0, "1 px tolerance")
	var narrow: Image = _sprite(Vector2i(60, 80), Rect2i(10, 6, 36, 64)).get_image()
	assert_eq(AssetSprite.solid_pixels_outside(narrow, anchor, shapes), 3 * 64, "4 px short: 3 columns out")


func test_the_engine_reports_solids_outside_the_sprite() -> void:
	var asset: Occluder = _asset(Vector3.ZERO, [_box(Vector3.ZERO, Vector3.ONE)],
			_sprite(Vector2i(60, 80), Rect2i(10, 6, 20, 64)), Vector2i(30, 70))
	var root: Node = Node.new()
	root.add_child(LocationEnvironment.new())
	root.add_child(asset)
	var engine: LightEngine = LightEngine.new()
	root.add_child(engine)
	add_child_autofree(root)
	assert_eq(engine.warnings().size(), 1)
	assert_string_contains(engine.warnings()[0], "silhouette")


func test_gate_the_street_assets_solids_lie_in_their_sprites() -> void:
	for path: String in ["res://engine_poligons/street/props/bench/bench.tscn",
			"res://engine_poligons/street/props/stall/stall.tscn", "res://engine_poligons/street/props/crate/crate.tscn"]:
		var asset: Occluder = (load(path) as PackedScene).instantiate() as Occluder
		add_child_autofree(asset)
		assert_eq(asset.asset_warnings(), PackedStringArray(), path)
