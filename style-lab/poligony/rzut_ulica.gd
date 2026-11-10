extends RzutPoligon
## PROTOTYPE (ticket Rzut, skala i rozdzielczość): a town block in the low 3/4 view, to walk into the
## depth. From the back (top of the screen): houses facing the upper street, the upper street, fenced
## yards behind the next row, a row of houses facing the lower street, the lower street, a low wall on
## the camera side. A side street joins the two streets; a gate opens one yard. All facades face the
## camera; nothing is see-through, so every building hides a strip of ground behind it
## (height / angle), shown in the readout.

const OUTDOOR: RoomLightingProfile = preload("res://lighting/data/outdoor.tres")
const STREET_LAMP: FixtureDef = preload("res://lighting/data/street_lamp.tres")
const DOM_SCENE: String = "res://poligony/rzut_dom.tscn"

const WIDTH_M: float = 48.0
const DEPTH_M: float = 34.0
## Storey height as a share of the actor's height ("Miasto i budynki": wall 1.3–1.9 × the actor).
const STOREYS: PackedFloat32Array = [1.3, 1.6, 1.9]
const SNOW: Color = Color("e8ecf2")
const ROOF_SNOW: Color = Color(0.85, 0.87, 0.9)
const PAVEMENT: Color = Color("d3d9e2")
const ROAD: Color = Color("b4bac4")
const TRACK: Color = Color("9aa1ad")
const FENCE: Color = Color("3a3532")
const FENCE_TOP: Color = Color("4a4440")

## Ground bands (z) of the two streets: pavement from, road from, road to, pavement to.
const UPPER_STREET: PackedFloat32Array = [4.0, 6.0, 9.5, 11.0]
const LOWER_STREET: PackedFloat32Array = [24.0, 26.0, 30.5, 32.5]
const SIDE_STREET_X: Vector2 = Vector2(19.0, 25.0) ## Between the houses of the lower row.
const FENCE_Z_M: float = 11.3
const YARD_END_Z_M: float = 16.0 ## Where the lower row's houses start.
const NEAR_WALL_Z_M: float = 33.6

## Upper row: footprint z 0..4, facing the upper street. Lower row: z 16..24, facing the lower street.
const UPPER_X: PackedFloat32Array = [1.0, 9.0, 26.0, 35.5]
const UPPER_W: PackedFloat32Array = [7.5, 9.0, 9.0, 12.0]
const UPPER_STOREYS: PackedInt32Array = [3, 3, 2, 3]
const UPPER_COLORS: PackedColorArray = [Color("6d625a"), Color("7d7266"), Color("616970"), Color("74675e")]
const LOWER_X: PackedFloat32Array = [1.0, 9.0, 25.0, 34.0]
const LOWER_W: PackedFloat32Array = [8.0, 10.0, 9.0, 13.0]
const LOWER_STOREYS: PackedInt32Array = [2, 2, 1, 2]
const LOWER_COLORS: PackedColorArray = [Color("8e806d"), Color("6f6a64"), Color("5d6670"), Color("82766a")]
const DOOR_HOUSE: int = 1 ## Lower row: the house you can enter.
const DOOR_M: Vector2 = Vector2(1.1, 2.1)
const WINDOW_M: Vector2 = Vector2(1.2, 1.5)
const SILL_M: float = 0.9

var _storey_m: float = 2.9
var _sky: Polygon2D


func _add_layout_options() -> void:
	var names: PackedStringArray = PackedStringArray()
	for share: float in STOREYS:
		names.append("%.1fx" % share)
	_layout_option(&"pietro", "Piętro fasady (× postaci)", names, 1)


func _build_world() -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	street_scene = scene_file_path
	_storey_m = STOREYS[_value(&"pietro")] * config.actor_height_m
	var box: RoomBox = RoomBox.new()
	box.width_m = WIDTH_M
	box.depth_m = DEPTH_M
	box.wall_height_m = 0.0
	box.above_m = 3 * _storey_m + 2.0
	box.floor_color = SNOW
	var street: RoomLighting = _room(Vector2.ZERO, box, OUTDOOR)
	_paint_ground(street)
	_grid(street, box.floor_rect(), 0)
	var lamps: Array[Vector2] = [Vector2(14.0, UPPER_STREET[0] + 0.4), Vector2(40.0, UPPER_STREET[0] + 0.4),
			Vector2(13.0, LOWER_STREET[0] + 0.4), Vector2(41.0, LOWER_STREET[0] + 0.4),
			Vector2(SIDE_STREET_X.x + 0.4, 19.0)]
	for lamp: Vector2 in lamps:
		var spot: Node2D = Node2D.new()
		spot.position = ground(lamp.x, lamp.y)
		var fixture: LightFixture = LightFixture.new()
		fixture.def = STREET_LAMP
		spot.add_child(fixture)
		street.add_child(spot)
	world.add_child(street)

	for index: int in UPPER_X.size():
		_house(UPPER_X[index], UPPER_W[index], UPPER_STOREYS[index], UPPER_COLORS[index], 0.0, UPPER_STREET[0], false)
	for index: int in LOWER_X.size():
		_house(LOWER_X[index], LOWER_W[index], LOWER_STOREYS[index], LOWER_COLORS[index],
				YARD_END_Z_M, LOWER_STREET[0], index == DOOR_HOUSE)
	# A gate between two upper houses (closed), showing a way further back.
	_block(world, ground(22.0, 3.0), Vector3(7.5, 0.15, 1.8), FENCE, FENCE_TOP)
	for lamp: Vector2 in lamps:
		_block(world, ground(lamp.x, lamp.y), Vector3(0.2, 0.2, 4.2), Color(0.2, 0.2, 0.22), Color(0.3, 0.3, 0.32))
	_yards()
	# The camera side: a low wall with gaps and snowbanks, never taller than a person's waist.
	for piece: Vector2 in [Vector2(0.0, 9.0), Vector2(11.0, 18.0), Vector2(26.0, 48.0)]:
		_block(world, ground((piece.x + piece.y) / 2.0, NEAR_WALL_Z_M), Vector3(piece.y - piece.x, 0.4, 0.8),
				Color("5b5650"), ROOF_SNOW)
	for bank: Vector3 in [Vector3(10.0, 32.8, 1.6), Vector3(22.5, 33.0, 2.4), Vector3(37.0, 32.9, 1.2)]:
		_block(world, ground(bank.x, bank.y), Vector3(bank.z, 0.8, 0.45), Color("cdd5e0"), Color("eef1f6"))
	_comparison_row(world, ground(26.0, LOWER_STREET[0] + 1.6))

	var door_x: float = LOWER_X[DOOR_HOUSE] + LOWER_W[DOOR_HOUSE] / 2.0
	var door: Door = Door.new()
	door.target_scene = DOM_SCENE
	door.spawn = &"z_ulicy"
	door.size_m = Vector2(DOOR_M.x, 0.3)
	door.at_m = ground(door_x, LOWER_STREET[0] + 0.15) / config.px_per_m
	world.add_child(door)
	_spawn("start", ground(22.0, 27.0))
	_spawn("z_domu", ground(door_x, LOWER_STREET[0] + 1.2))
	_build_sky(box)


func apply_time(hour: float) -> void:
	super.apply_time(hour)
	var sky: Color = director.sun.sky_color
	var bright: float = lerpf(0.25, 1.0, director.sun.day)
	_sky.color = Color(sky.r * bright, sky.g * bright, sky.b * bright)


func _readout_extra() -> String:
	return "\npiętro %.1f m · dom 2-piętrowy zasłania %.1f m za sobą, 3-piętrowy %.1f m" % [
		_storey_m, hidden_m(2 * _storey_m), hidden_m(3 * _storey_m)]


## A house from x `left`, footprint from z `back` to its front at z `front`, windows on every storey,
## a door in the middle when `with_door`.
func _house(left: float, width: float, storeys: int, color: Color, back: float, front: float,
		with_door: bool) -> void:
	var details: Array[Rect2] = []
	var count: int = maxi(int(width / 2.6), 1)
	var step: float = width / count
	for storey: int in storeys:
		for column: int in count:
			var x: float = step * (column + 0.5) - WINDOW_M.x / 2.0
			if storey == 0 and with_door and absf(x + WINDOW_M.x / 2.0 - width / 2.0) < step * 0.6:
				continue
			var height: float = minf(WINDOW_M.y, _storey_m - SILL_M - 0.25)
			details.append(Rect2(x, storey * _storey_m + SILL_M, WINDOW_M.x, height))
	if with_door:
		details.append(Rect2(width / 2.0 - DOOR_M.x / 2.0, 0.0, DOOR_M.x, DOOR_M.y))
	_block(world, ground(left + width / 2.0, front), Vector3(width, front - back, storeys * _storey_m),
			color, ROOF_SNOW, details)


## Fences between the upper street and the yards, with the side street open; the side street fenced
## along its sides, one gate into the east yard, a shed in that yard.
func _yards() -> void:
	for piece: Vector2 in [Vector2(0.0, SIDE_STREET_X.x), Vector2(SIDE_STREET_X.y, WIDTH_M)]:
		_block(world, ground((piece.x + piece.y) / 2.0, FENCE_Z_M), Vector3(piece.y - piece.x, 0.15, 1.6),
				FENCE, FENCE_TOP)
	_block(world, ground(SIDE_STREET_X.x, YARD_END_Z_M), Vector3(0.15, YARD_END_Z_M - FENCE_Z_M, 1.6),
			FENCE, FENCE_TOP)
	var gate_from: float = 13.0
	var gate_to: float = 14.6
	_block(world, ground(SIDE_STREET_X.y, gate_from), Vector3(0.15, gate_from - FENCE_Z_M, 1.6), FENCE, FENCE_TOP)
	_block(world, ground(SIDE_STREET_X.y, YARD_END_Z_M), Vector3(0.15, YARD_END_Z_M - gate_to, 1.6), FENCE, FENCE_TOP)
	_block(world, ground(30.0, 14.2), Vector3(3.0, 2.0, 2.2), Color("4d4540"), ROOF_SNOW)


## Pavements, roads and wheel tracks, drawn as part of the snowy ground.
func _paint_ground(street: RoomLighting) -> void:
	var paint: ShapePainter = ShapePainter.new(LightMasks.of(0, LightMasks.Receiver.FLOOR), RoomBox.WALL_Z + 1)
	for bands: PackedFloat32Array in [UPPER_STREET, LOWER_STREET]:
		_band(paint, 0.0, WIDTH_M, bands[0], bands[3], PAVEMENT)
		_band(paint, 0.0, WIDTH_M, bands[1], bands[2], ROAD)
		for track: float in [bands[1] + 0.9, bands[1] + 1.8, bands[2] - 2.0, bands[2] - 1.1]:
			_band(paint, 0.0, WIDTH_M, track, track + 0.3, TRACK)
	_band(paint, SIDE_STREET_X.x, SIDE_STREET_X.y, UPPER_STREET[3], LOWER_STREET[0], PAVEMENT)
	_band(paint, SIDE_STREET_X.x + 1.0, SIDE_STREET_X.y - 1.0, UPPER_STREET[3], LOWER_STREET[0], ROAD)
	street.add_child(paint)


static func _band(paint: ShapePainter, x0: float, x1: float, z0: float, z1: float, color: Color) -> void:
	var from: Vector2 = ground(x0, z0)
	paint.add_rect(Rect2(from, ground(x1, z1) - from), color)


func _build_sky(box: RoomBox) -> void:
	var area: Rect2 = box.ambient_rect().grow(ProjectionConfig.current().px(20.0))
	_sky = Polygon2D.new()
	_sky.z_index = -100
	var unshaded: CanvasItemMaterial = CanvasItemMaterial.new()
	unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	_sky.material = unshaded
	var bottom: float = box.floor_rect().position.y + 2.0
	_sky.polygon = PackedVector2Array([area.position, Vector2(area.end.x, area.position.y),
			Vector2(area.end.x, bottom), Vector2(area.position.x, bottom)])
	add_child(_sky)
