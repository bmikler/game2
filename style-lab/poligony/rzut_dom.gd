extends RzutPoligon
## PROTOTYPE (ticket Rzut, skala i rozdzielczość): a house in section with two rooms, one behind the
## other, and a partition wall with a doorway between them. The partition is y-sorted blocks, so it
## hides whoever stands behind it in the back room. Variants: wall height, the partition (full height,
## cut down, only its top) and what surrounds rooms narrower than the frame.
## Ground: x across, z from the back room's back wall (metres).

const ROOM_PROFILE: RoomLightingProfile = preload("res://lighting/data/evening_lamps.tres")
const WINDOW_PROFILE: WindowLightProfile = preload("res://lighting/data/window_light.tres")
const FLOOR_LAMP: FixtureDef = preload("res://lighting/data/floor_lamp.tres")

## Interior walls; game1 lowered them to 1.9 m on purpose (ADR 0002 game1: better in the frame).
const WALLS_M: PackedFloat32Array = [1.9, 2.2, 2.6, 3.0]
## Full, cut down, only its top; or full that cuts down (or to its top) while the player is in the
## back room. Only the drawing changes: rooms keep their own light masks, so the light is the same as
## with the full wall standing.
const PARTITIONS: PackedStringArray = ["pelna", "obcieta", "wierzch", "pelna>obcieta", "pelna>wierzch"]
const CUT_SECONDS: float = 0.2 ## How long the wall takes to cut down or grow back.
const PARTITION_CUT_M: float = 1.0
const CONTENT_WIDTH_M: float = 9.0
const BACK_DEPTH_M: float = 4.5
const FRONT_DEPTH_M: float = 5.0
const PARTITION_M: float = 0.25 ## Thickness.
const INNER_DOOR_X_M: float = 5.0
const DOOR_WIDTH_M: float = 1.0
## Door with a frame and a lintel, as in game1: min(2.0 m, wall − 0.35 m), about 1.55 m at 1.9 m.
const DOOR_MAX_M: float = 2.0
const DOOR_BELOW_CEILING_M: float = 0.35
const STREET_DOOR_X_M: float = 0.6
const WALL_COLOR: Color = Color("8c8a80")
const WALL_TOP: Color = Color("2b2a2e")
## Around the house, stepping darker outwards ("oprawa").
const FRAME_STEPS: Array[Color] = [Color("26252b"), Color("1d1c22"), Color("15151a")]
const FRAME_STEP_M: float = 0.6

var _wall_m: float = 2.6
var _partition_m: float = 2.6
var _cut_to_m: float = -1.0 ## Below 0: the partition never cuts down.
var _shown_m: float = 2.6 ## Height drawn now (it moves towards full or cut).
var _partition_blocks: Array[Block] = []
var _lintel: Block
var _door_h: float = 1.55
var _back_room: RoomLighting


func _add_layout_options() -> void:
	var names: PackedStringArray = PackedStringArray()
	for wall: float in WALLS_M:
		names.append("%.1fm" % wall)
	names[0] += " (game1)"
	_layout_option(&"sciana", "Ściana pokoju", names, 1)
	_layout_option(&"dzialowa", "Ściana działowa", PARTITIONS, 3)
	_layout_option(&"otoczenie", "Wokół pokoju", PackedStringArray(["czern", "szerszy", "oprawa"]), 0)


func _build_world() -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	_wall_m = WALLS_M[_value(&"sciana")]
	_ground_wall_m = _wall_m
	match _value(&"dzialowa"):
		0:
			_partition_m = _wall_m
		1:
			_partition_m = PARTITION_CUT_M
		2:
			_partition_m = 0.0
		3:
			_partition_m = _wall_m
			_cut_to_m = PARTITION_CUT_M
		_:
			_partition_m = _wall_m
			_cut_to_m = 0.0
	_shown_m = _partition_m
	var surround: int = _value(&"otoczenie")
	var width_m: float = CONTENT_WIDTH_M
	if surround == 1:
		var view_m: float = get_viewport().get_visible_rect().size.x / config.px_per_m
		width_m = maxf(CONTENT_WIDTH_M, ceilf(view_m) + 2.0)
	var dx: float = (width_m - CONTENT_WIDTH_M) / 2.0
	var front_z: float = BACK_DEPTH_M + PARTITION_M ## Where the front room's floor starts.

	# Back room (slot 0): back wall with a window, a doorway gap in its front edge.
	var back_box: RoomBox = RoomBox.new()
	back_box.width_m = width_m
	back_box.depth_m = BACK_DEPTH_M
	back_box.wall_height_m = _wall_m
	back_box.wall_color = WALL_COLOR
	back_box.door_x_m = INNER_DOOR_X_M + dx
	back_box.door_width_m = DOOR_WIDTH_M
	# Window as in game1: sill at a third of the wall, top 0.25 m under the ceiling.
	back_box.windows = [Rect2(2.6 + dx, _wall_m / 3.0, 2.0, _wall_m * 2.0 / 3.0 - 0.25)]
	back_box.window_profile = WINDOW_PROFILE
	back_box.view_day = _view([Color(0.81, 0.86, 0.94), Color(0.91, 0.93, 0.96), Color(0.95, 0.96, 0.97), Color(0.85, 0.87, 0.9)])
	back_box.view_gold = _view([Color(0.94, 0.71, 0.54), Color(0.96, 0.83, 0.7), Color(0.95, 0.86, 0.8), Color(0.82, 0.74, 0.72)])
	back_box.view_night = _view([Color(0.06, 0.09, 0.23), Color(0.15, 0.19, 0.35), Color(0.35, 0.39, 0.53), Color(0.24, 0.27, 0.4)])
	var back_room: RoomLighting = _room(Vector2.ZERO, back_box, ROOM_PROFILE)
	_back_room = back_room
	back_room.add_child(_lamp(ground(0.6 + dx, 0.6, _wall_m)))
	world.add_child(back_room)
	_grid(back_room, back_box.floor_rect(), 0)

	# Front room (slot 1): no back wall of its own (the partition), a gap to the back room and the
	# street door in its front edge.
	var front_origin: Vector2 = ground(0.0, front_z, _wall_m)
	var front_box: RoomBox = RoomBox.new()
	front_box.slot = 1
	front_box.width_m = width_m
	front_box.depth_m = FRONT_DEPTH_M
	front_box.wall_height_m = 0.0
	front_box.open_back = true
	front_box.wall_color = WALL_COLOR
	front_box.back_door_x_m = INNER_DOOR_X_M + dx
	front_box.back_door_width_m = DOOR_WIDTH_M
	front_box.door_x_m = STREET_DOOR_X_M + dx
	front_box.door_width_m = 1.1
	var front_room: RoomLighting = _room(front_origin, front_box, ROOM_PROFILE)
	front_room.slot = 1
	front_room.add_child(_lamp(ground(8.4 + dx, 0.6)))
	world.add_child(front_room)
	_grid(front_room, front_box.floor_rect(), 1)

	_partition(width_m, front_z, dx)
	if surround == 2:
		var area: Rect2 = back_box.ambient_rect().merge(
				Rect2(front_origin + front_box.ambient_rect().position, front_box.ambient_rect().size))
		_frame(area)

	# Back room: lamp post, bed, wardrobe. Front room: lamp post, sofa, table, the comparison row.
	_block(world, ground(0.6 + dx, 0.6, _wall_m), Vector3(0.3, 0.3, 1.6), Color(0.25, 0.22, 0.2), Color(0.9, 0.8, 0.6))
	_block(world, ground(2.4 + dx, 2.3, _wall_m), Vector3(1.6, 2.0, 0.55), Color(0.35, 0.3, 0.33), Color(0.62, 0.6, 0.64))
	_block(world, ground(7.9 + dx, 0.6, _wall_m), Vector3(1.2, 0.6, 2.0), Color(0.36, 0.27, 0.2), Color(0.45, 0.34, 0.25))
	_block(world, ground(8.4 + dx, front_z + 0.6, _wall_m), Vector3(0.3, 0.3, 1.6), Color(0.25, 0.22, 0.2), Color(0.9, 0.8, 0.6), [], true, 0.0, 1)
	_block(world, ground(2.4 + dx, front_z + 2.6, _wall_m), Vector3(2.0, 0.9, 0.85), Color(0.3, 0.33, 0.36), Color(0.38, 0.41, 0.44), [], true, 0.0, 1)
	_block(world, ground(6.4 + dx, front_z + 2.0, _wall_m), Vector3(1.6, 0.8, 0.75), Color(0.42, 0.31, 0.22), Color(0.55, 0.42, 0.3), [], true, 0.0, 1)
	_comparison_row(world, ground(3.0 + dx, front_z + 4.6, _wall_m), 1)

	var door_x: float = STREET_DOOR_X_M + dx + 0.55
	var door: Door = Door.new()
	door.target_scene = street_scene
	door.spawn = &"z_domu"
	door.size_m = Vector2(1.1, 0.4)
	door.at_m = ground(door_x, front_z + FRONT_DEPTH_M + 0.45, _wall_m) / config.px_per_m
	world.add_child(door)
	_spawn("z_ulicy", ground(door_x, front_z + FRONT_DEPTH_M - 0.6, _wall_m))
	_spawn("tyl", ground(INNER_DOOR_X_M + dx + 1.5, 2.0, _wall_m)) # for shots in the back room


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _cut_to_m < 0.0 or player == null:
		return
	var inside: bool = _back_room.global_floor_rect().has_point(player.global_position)
	var target: float = _cut_to_m if inside else _partition_m
	if is_equal_approx(_shown_m, target):
		return
	_shown_m = move_toward(_shown_m, target, (_partition_m - _cut_to_m) / CUT_SECONDS * delta)
	_show_partition(_shown_m)


func _readout_extra() -> String:
	var text: String = "\nściana działowa %.1f m zasłania %.1f m pokoju za nią (z %.1f m głębi)" % [
		_partition_m, minf(hidden_m(_partition_m), BACK_DEPTH_M), BACK_DEPTH_M]
	if _cut_to_m >= 0.0:
		text += "; w tylnym pokoju obcięta do %.1f m" % _cut_to_m
	return text


## The partition between the rooms: two pieces beside the doorway and a lintel over it (only when
## the wall is taller than the door; a cut-down wall has only the gap), all standing on the front room's back edge and lit with it.
func _partition(width_m: float, front_z: float, dx: float) -> void:
	var height: float = _partition_m
	var door_h: float = minf(DOOR_MAX_M, _wall_m - DOOR_BELOW_CEILING_M)
	_door_h = door_h
	var left_w: float = INNER_DOOR_X_M + dx + RoomBox.WALL_TOP_M
	var right_from: float = INNER_DOOR_X_M + dx + DOOR_WIDTH_M
	var right_w: float = width_m + RoomBox.WALL_TOP_M - right_from
	_partition_blocks = [
		_block(world, ground(left_w / 2.0 - RoomBox.WALL_TOP_M, front_z, _wall_m),
				Vector3(left_w, PARTITION_M, height), WALL_COLOR, WALL_TOP, [], true, 0.0, 1),
		_block(world, ground(right_from + right_w / 2.0, front_z, _wall_m),
				Vector3(right_w, PARTITION_M, height), WALL_COLOR, WALL_TOP, [], true, 0.0, 1),
	]
	if height > door_h:
		_lintel = _block(world, ground(INNER_DOOR_X_M + dx + DOOR_WIDTH_M / 2.0, front_z, _wall_m),
				Vector3(DOOR_WIDTH_M, PARTITION_M, height), WALL_COLOR, WALL_TOP, [], false, door_h, 1)


## Draws the partition `height_m` tall (the lintel only while the wall is taller than the door).
func _show_partition(height_m: float) -> void:
	for block: Block in _partition_blocks:
		block.size_m.z = height_m
		block.repaint()
	if _lintel != null:
		_lintel.visible = height_m > _door_h
		_lintel.size_m.z = height_m
		_lintel.repaint()


func _lamp(at: Vector2) -> Node2D:
	var spot: Node2D = Node2D.new()
	spot.position = at
	var lamp: LightFixture = LightFixture.new()
	lamp.def = FLOOR_LAMP
	spot.add_child(lamp)
	return spot


## A dark surround stepping darker outwards, unlit, so the house is not a box in a black void.
func _frame(area: Rect2) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var unshaded: CanvasItemMaterial = CanvasItemMaterial.new()
	unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	var painter: Node2D = Node2D.new()
	painter.z_index = RoomBox.WALL_Z - 10
	world.add_child(painter)
	for index: int in range(FRAME_STEPS.size() - 1, -1, -1):
		var last: bool = index == FRAME_STEPS.size() - 1
		var rect: Rect2 = area.grow(config.px(60.0) if last else config.px(FRAME_STEP_M * (index + 1)))
		var step: Polygon2D = Polygon2D.new()
		step.polygon = PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end,
				Vector2(rect.position.x, rect.end.y)])
		step.color = FRAME_STEPS[index]
		step.material = unshaded
		painter.add_child(step)


static func _view(colors: Array[Color]) -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.55, 0.56, 1.0])
	gradient.colors = PackedColorArray(colors)
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 256
	texture.height = 160
	texture.fill_to = Vector2(0.0, 1.0)
	return texture
