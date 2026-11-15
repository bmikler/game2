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
	assert_eq(description.solids, [AABB(Vector3(2.0, -5.0, 1.0), Vector3(2.0, 1.0, 5.0))])


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
