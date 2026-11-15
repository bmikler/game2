extends GutTest
## Contract nodes → scene description (headless): receivers and the buffer area.

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")

## A house 4 m wide (x −2…2), 3 m deep (d −5…−2), 6 m tall.
const HOUSE: AABB = AABB(Vector3(-2.0, -5.0, 0.0), Vector3(4.0, 3.0, 6.0))


func _normals(description: SceneDescription) -> Array[Vector3]:
	var found: Array[Vector3] = []
	for receiver: Receiver in description.receivers:
		found.append(receiver.normal)
	return found


func test_a_box_receives_on_its_top_and_its_front_only() -> void:
	var description: SceneDescription = SceneDescription.from_boxes([HOUSE], PROJECTION)
	var normals: Array[Vector3] = _normals(description)
	assert_eq(normals.size(), 2)
	assert_has(normals, Vector3(0, 0, 1), "top")
	assert_has(normals, Vector3(0, 1, 0), "front, towards the camera")


func test_the_front_receiver_spans_the_front_face() -> void:
	var description: SceneDescription = SceneDescription.from_boxes([HOUSE], PROJECTION)
	for receiver: Receiver in description.receivers:
		if receiver.normal == Vector3(0, 1, 0):
			var corners: Array[Vector3] = receiver.corners()
			assert_has(corners, Vector3(-2, -2, 0))
			assert_has(corners, Vector3(2, -2, 0))
			assert_has(corners, Vector3(-2, -2, 6))
			assert_has(corners, Vector3(2, -2, 6))


func test_the_area_covers_the_house_on_screen_in_whole_pixels() -> void:
	var description: SceneDescription = SceneDescription.from_boxes([HOUSE], PROJECTION)
	# x: −2…2 m → −80…80 px; top back edge: (−5·0,6 − 6)·40 = −360 px; front base: −2·0,6·40 = −48 px.
	assert_eq(description.area, Rect2i(-80, -360, 160, 312))


func test_receivers_remember_their_solid() -> void:
	var second: AABB = AABB(Vector3(5.0, -5.0, 0.0), Vector3(1.0, 1.0, 1.0))
	var description: SceneDescription = SceneDescription.from_boxes([HOUSE, second], PROJECTION)
	var solids: Array[int] = []
	for receiver: Receiver in description.receivers:
		solids.append(receiver.solid)
	assert_eq(solids.count(0), 2)
	assert_eq(solids.count(1), 2)


func test_no_solids_no_area() -> void:
	var description: SceneDescription = SceneDescription.from_boxes([], PROJECTION)
	assert_eq(description.area, Rect2i())
	assert_true(description.receivers.is_empty())


func _occluder(at: Vector3) -> Occluder:
	var occluder: Occluder = Occluder.new()
	occluder.position_m = at
	add_child_autofree(occluder)
	return occluder


func _solid(occluder: Occluder, at: Vector3, size: Vector3) -> Solid:
	var solid: Solid = Solid.new()
	solid.position_m = at
	solid.size_m = size
	occluder.add_child(solid)
	return solid


func test_a_solid_stands_on_its_anchor_the_middle_of_its_front_bottom_edge() -> void:
	var occluder: Occluder = _occluder(Vector3(3.0, -4.0, 0.0))
	_solid(occluder, Vector3(0.0, 0.0, 1.0), Vector3(2.0, 1.0, 5.0))
	var description: SceneDescription = SceneDescription.from_tree(get_tree(), PROJECTION)
	assert_eq(description.solids.size(), 1)
	assert_eq(description.solids[0].box, AABB(Vector3(2.0, -5.0, 1.0), Vector3(2.0, 1.0, 5.0)))


func test_solids_of_all_occluders_count() -> void:
	_solid(_occluder(Vector3.ZERO), Vector3.ZERO, Vector3.ONE)
	var other: Occluder = _occluder(Vector3(10.0, 0.0, 0.0))
	_solid(other, Vector3.ZERO, Vector3.ONE)
	_solid(other, Vector3(0.0, -2.0, 0.0), Vector3.ONE)
	assert_eq(SceneDescription.from_tree(get_tree(), PROJECTION).solids.size(), 3)


func test_contract_nodes_sit_on_screen_where_the_projection_puts_them() -> void:
	var occluder: Occluder = _occluder(Vector3(3.0, -4.0, 0.0))
	var solid: Solid = _solid(occluder, Vector3(1.0, 0.0, 2.0), Vector3.ONE)
	assert_eq(occluder.position, PROJECTION.to_screen(Vector3(3.0, -4.0, 0.0)))
	assert_eq(solid.global_position, PROJECTION.to_screen(Vector3(4.0, -4.0, 2.0)))


func test_moving_a_solid_reports_a_change() -> void:
	var solid: Solid = _solid(_occluder(Vector3.ZERO), Vector3.ZERO, Vector3.ONE)
	watch_signals(solid)
	solid.size_m = Vector3(2.0, 2.0, 2.0)
	assert_signal_emitted(solid, "changed")


func test_a_flat_solid_or_one_outside_an_occluder_warns() -> void:
	var flat: Solid = _solid(_occluder(Vector3.ZERO), Vector3.ZERO, Vector3(1.0, 0.0, 1.0))
	assert_eq(flat._get_configuration_warnings().size(), 1)
	var loose: Solid = Solid.new()
	add_child_autofree(loose)
	assert_eq(loose._get_configuration_warnings().size(), 1)


func _receivers_of(shape: SolidShape) -> Array[Receiver]:
	return SceneDescription.from_shapes([shape], PROJECTION).receivers


func _find(receivers: Array[Receiver], normal: Vector3) -> Receiver:
	for receiver: Receiver in receivers:
		if receiver.normal.is_equal_approx(normal):
			return receiver
	return null


## A house 6 m wide (x −3…3), 4 m deep (d −4…0), walls 3 m, ridge 6 m.
const ROOFED: AABB = AABB(Vector3(-3.0, -4.0, 0.0), Vector3(6.0, 4.0, 6.0))


func test_a_roof_falling_along_x_shows_its_front_wall_its_gable_and_both_slopes() -> void:
	var receivers: Array[Receiver] = _receivers_of(SolidShape.make_roof(false, ROOFED, 3.0))
	assert_eq(receivers.size(), 4)
	assert_not_null(_find(receivers, Vector3(-1.0, 0.0, 1.0).normalized()), "left slope")
	assert_not_null(_find(receivers, Vector3(1.0, 0.0, 1.0).normalized()), "right slope")
	var gable: Receiver = null
	for receiver: Receiver in receivers:
		if receiver.kind == Receiver.Kind.TRIANGLE:
			gable = receiver
	assert_not_null(gable, "the front gable is a triangle")
	assert_eq(gable.normal, Vector3(0, 1, 0))
	assert_has(gable.corners(), Vector3(0, 0, 6), "the ridge's front end")
	assert_has(gable.corners(), Vector3(-3, 0, 3))
	assert_has(gable.corners(), Vector3(3, 0, 3))


func test_a_roof_falling_along_d_shows_its_front_slope_and_hides_a_steep_back_slope() -> void:
	var receivers: Array[Receiver] = _receivers_of(SolidShape.make_roof(true, ROOFED, 3.0))
	# Rise 3 m over 2 m: the back slope's normal (0, −3, 2) turns from the camera (0, 1, 0.6).
	assert_eq(receivers.size(), 2)
	var front_slope: Receiver = _find(receivers, Vector3(0.0, 3.0, 2.0).normalized())
	assert_not_null(front_slope)
	assert_has(front_slope.corners(), Vector3(-3, 0, 3), "eave")
	assert_has(front_slope.corners(), Vector3(3, -2, 6), "ridge")
	assert_not_null(_find(receivers, Vector3(0, 1, 0)), "front wall up to the eave")


func test_a_shallow_back_slope_is_seen() -> void:
	var low: AABB = AABB(Vector3(-3.0, -4.0, 0.0), Vector3(6.0, 4.0, 4.0))
	var receivers: Array[Receiver] = _receivers_of(SolidShape.make_roof(true, low, 3.0))
	assert_not_null(_find(receivers, Vector3(0.0, -1.0, 2.0).normalized()))


func test_a_roof_without_a_rise_is_a_box() -> void:
	assert_eq(SolidShape.make_roof(true, ROOFED, 6.0).kind, SolidShape.Kind.BOX)


func test_a_cylinder_shows_its_side_and_its_top() -> void:
	var post: AABB = AABB(Vector3(-0.5, -1.0, 0.0), Vector3(1.0, 1.0, 3.0))
	var receivers: Array[Receiver] = _receivers_of(SolidShape.make_cylinder(post))
	assert_eq(receivers.size(), 2)
	var kinds: Array[int] = []
	for receiver: Receiver in receivers:
		kinds.append(receiver.kind)
	assert_has(kinds, Receiver.Kind.CYLINDER)
	assert_has(kinds, Receiver.Kind.DISK)
	for receiver: Receiver in receivers:
		assert_eq(receiver.origin.x, 0.0, "centred on the axis")
		assert_eq(receiver.origin.y, -0.5)
		if receiver.kind == Receiver.Kind.CYLINDER:
			assert_eq(receiver.height, 3.0)


func test_the_area_reaches_the_ridge() -> void:
	var description: SceneDescription = SceneDescription.from_shapes([SolidShape.make_roof(false, ROOFED, 3.0)], PROJECTION)
	# Ridge 6 m high at the back (d −4): (−4·0,6 − 6)·40 = −336 px.
	assert_eq(description.area.position.y, -336)


func test_solid_shapes_from_the_contract() -> void:
	var occluder: Occluder = _occluder(Vector3(10.0, -2.0, 0.0))
	var roof: Solid = _solid(occluder, Vector3.ZERO, Vector3(6.0, 4.0, 6.0))
	roof.shape = Solid.Shape.ROOF_X
	roof.eave_m = 3.0
	var post: Solid = _solid(occluder, Vector3(5.0, 0.0, 0.0), Vector3(1.0, 1.0, 3.0))
	post.shape = Solid.Shape.CYLINDER
	var awning: Solid = _solid(occluder, Vector3(-5.0, 0.0, 0.0), Vector3(4.0, 3.0, 2.4))
	awning.shape = Solid.Shape.RAISED_BOX
	awning.clearance_m = 2.2
	var shapes: Array[SolidShape] = SceneDescription.from_tree(get_tree(), PROJECTION).solids
	assert_eq(shapes[0].kind, SolidShape.Kind.ROOF_X)
	assert_eq(shapes[0].box, AABB(Vector3(7.0, -6.0, 0.0), Vector3(6.0, 4.0, 6.0)))
	assert_eq(shapes[0].eave, 3.0)
	assert_eq(shapes[1].kind, SolidShape.Kind.CYLINDER)
	assert_eq(shapes[2].kind, SolidShape.Kind.BOX)
	assert_true(shapes[2].box.is_equal_approx(AABB(Vector3(3.0, -5.0, 2.2), Vector3(4.0, 3.0, 0.2))), "empty below the clearance")


func test_a_raised_box_shows_its_front_and_top_not_its_bottom() -> void:
	var awning: Solid = _solid(_occluder(Vector3.ZERO), Vector3.ZERO, Vector3(4.0, 3.0, 2.4))
	awning.shape = Solid.Shape.RAISED_BOX
	awning.clearance_m = 2.2
	var normals: Array[Vector3] = _normals(SceneDescription.from_tree(get_tree(), PROJECTION))
	assert_eq(normals.size(), 2)
	assert_does_not_have(normals, Vector3(0, 0, -1))


func test_bad_roof_eave_or_clearance_warns() -> void:
	var roof: Solid = _solid(_occluder(Vector3.ZERO), Vector3.ZERO, Vector3(2.0, 2.0, 3.0))
	roof.shape = Solid.Shape.ROOF_D
	roof.eave_m = 3.0
	assert_eq(roof._get_configuration_warnings().size(), 1)
	roof.eave_m = 2.0
	assert_eq(roof._get_configuration_warnings().size(), 0)
	roof.shape = Solid.Shape.RAISED_BOX
	assert_eq(roof._get_configuration_warnings().size(), 1, "no clearance")


func test_receiver_data_has_four_texels_per_receiver_with_kind_and_height() -> void:
	var post: AABB = AABB(Vector3(-0.5, -1.0, 0.0), Vector3(1.0, 1.0, 3.0))
	var description: SceneDescription = SceneDescription.from_shapes([SolidShape.make_cylinder(post)], PROJECTION)
	var data: Image = description.receiver_data()
	assert_eq(data.get_width(), 8)
	var side: int = 0 if description.receivers[0].kind == Receiver.Kind.CYLINDER else 1
	assert_eq(data.get_pixel(side * 4 + 3, 0), Color(Receiver.Kind.CYLINDER, 3.0, 0.0, 0.0))
	var solid_data: Image = description.solid_data()
	assert_eq(solid_data.get_pixel(0, 0).a, float(SolidShape.Kind.CYLINDER))
