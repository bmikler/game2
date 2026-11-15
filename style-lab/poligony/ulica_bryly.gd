extends RzutPoligon
## PROTOTYPE (ticket Poligon Ulica w bryłach): a short winter street in the low 3/4 view, drawn in
## code, to choose the street layout, the scale of buildings from outside and how much street fits in
## the frame. A main street across the screen; north of it three buildings: a two-storey house (its
## door leads into rzut_dom), a shop with display windows, and a building that is only a facade in the
## depth. Where the facade stands depends on the layout variant: A on a terrace behind a low wall with
## stairs, B at the end of a short side street (T junction), C set back behind a front yard.
## Ground: x across, z into the depth from the map's back edge (metres). Nothing is see-through.

const OUTDOOR: RoomLightingProfile = preload("res://lighting/data/outdoor.tres")
const STREET_LAMP: FixtureDef = preload("res://lighting/data/street_lamp.tres")
const DOM_SCENE: String = "res://poligony/dom_parter.tscn"
## The house's window columns per storey: the room behind each (DomBryly.ROOMS), lit by its lamp.
const HOUSE_ROOMS: PackedStringArray = ["salon", "", "jadalnia", "sypialnia", "korytarz_g", "pokoj"] ## 3 per storey.

const LAYOUTS: PackedStringArray = ["A taras", "B przecznica T", "C cofniecia"]
const STOREYS: PackedFloat32Array = [1.3, 1.6, 1.9] ## Storey height × the actor.
const ROOFS: PackedStringArray = ["plaskie", "wzdluz ulicy", "szczytem", "mieszane"]
## Street from the building fronts towards the camera: north pavement, road, south pavement (m).
const STREETS: Array[Vector3] = [Vector3(2.0, 4.5, 1.5), Vector3(2.5, 6.0, 2.0), Vector3(3.0, 7.5, 2.5)]
const STREET_NAMES: PackedStringArray = ["waska 8m", "srednia 10,5m", "szeroka 13m"]
const SURFACES: PackedStringArray = ["odsniezona", "ubity snieg"]
const ON_OFF: PackedStringArray = ["tak", "nie"]
const WINDOWS_AT_NIGHT: PackedStringArray = ["cieple", "ciemne"]
const VERTICAL_SPEEDS: PackedFloat32Array = [1.0, 0.8, 0.6, 1.2]
const VERTICAL_NAMES: PackedStringArray = ["x1 (teraz)", "x0,8", "x0,6 (metrycznie)", "x1,2"]

const WIDTH_M: float = 44.0
const FRONT_Z_M: float = 20.0 ## Fronts of the street-level buildings: the north edge of the north pavement.
const NEAR_STRIP_M: float = 2.5 ## Snow and a low wall behind the south pavement, to the map's bottom.
const ABOVE_M: float = 16.0
const GAP_X: Vector2 = Vector2(14.0, 22.0) ## Between the house and the shop: stairs, side street or yard.

## Buildings: left x, width, depth (m), storeys.
const HOUSE: Vector4 = Vector4(4.0, 10.0, 8.0, 2.0)
const SHOP: Vector4 = Vector4(22.0, 14.0, 10.0, 2.0)
const BACKDROP: Vector4 = Vector4(12.0, 12.0, 6.0, 3.0)
const HOUSE_COLOR: Color = Color("7d7266")
const SHOP_COLOR: Color = Color("5f6871")
const BACKDROP_COLOR: Color = Color("6d625a")

const TERRACE_M: float = 1.2 ## Layout A: about 0.65 of the actor.
const TERRACE_Z: Vector2 = Vector2(4.0, 16.0) ## Its ground (before the lift) from the back to the wall.
const STAIRS_X: Vector2 = Vector2(17.0, 19.5)
## Stairs and the doorstep (variants "Schody", "Próg"); numbers from research 77.
const STAIR_MODES: PackedStringArray = ["plaskie (bylo)", "A czolowe", "B boczne"]
const DOORSTEP_MODES: PackedStringArray = ["brak", "C stopien"]
const STEP_M: float = 0.2 ## 8 px at 40 px/m.
const STEPS: int = 6
const RUN_M: float = 0.3
const SIDE_STAIRS_X: float = 17.0
const SIDE_RUN_M: float = 0.4
const SIDE_DEPTH_M: float = 1.0
const SIDE_LANDING_M: float = 0.8 ## Top landing of the side flight: the feet (0.4 m) turn up there.
const STAIRS_UP_SPEED: float = 0.6
const STAIRS_DOWN_SPEED: float = 0.7
const SIDE_STAIRS_SPEED: float = 0.75
const STEP_SMOOTH_S: float = 0.08
const DOORSTEP_M: Vector3 = Vector3(1.8, 0.5, 0.15) ## Width, depth, height.
const HOP_UP_S: float = 0.06
const HOP_ARC_S: float = 0.12
const HOP_ARC_PX: float = 3.0
const SIDE_STREET_END_Z: float = 6.0 ## Layout B: where the side street meets the facade.
const YARD_FRONT_Z: float = 12.0 ## Layout C: the facade's front behind the yard.
const HOUSE_SETBACK_M: float = 1.2 ## Layout C.

## Building depth as a share of its real depth (footprint and the roof's run): shallower buildings
## reach less into the depth of the frame.
const DEPTH_SCALES: PackedFloat32Array = [1.0, 0.7, 0.5, 0.35]
const DEPTH_NAMES: PackedStringArray = ["100%", "70%", "50%", "35%"]
## Roof rise per run: about 42°, 30°, 20°.
const PITCHES: PackedFloat32Array = [0.9, 0.58, 0.36]
const PITCH_NAMES: PackedStringArray = ["42st", "30st", "20st"]
const EAVE_M: float = 0.3
const WINDOW_M: Vector2 = Vector2(1.2, 1.5)
const SILL_M: float = 0.9
const DOOR_M: Vector2 = Vector2(1.1, 2.1)

const SNOW: Color = Color("e8ecf2")
const SNOW_SHADE: Color = Color("cdd5e0")
const SNOW_TOP: Color = Color("f2f4f8")
const ROOF_SNOW: Color = Color(0.86, 0.88, 0.92)
const ROOF_BARE: Color = Color("4e413b")
const FLAT_BARE: Color = Color("57524e")
const GLASS: Color = Color("262931")
const FRAME: Color = Color("cfc8b8")
const DOOR: Color = Color("3a2e28")
const PLINTH: Color = Color("4a4542")
const LIT_WINDOW: Color = Color(1.0, 0.78, 0.5)
const LIT_SHOP: Color = Color(1.0, 0.86, 0.66)
const SIGN: Color = Color("6b3a32")
const FENCE: Color = Color("3a3532")
const FENCE_TOP: Color = Color("4a4440")
const STONE: Color = Color("6e6a66")
const TRUNK: Color = Color("3b302a")
const SPRUCE: Color = Color("2e3b36")
const CAR: Color = Color("5a2f2f")
const CAR_GLASS: Color = Color("2a3038")

## Road and pavement colours per surface variant: pavement, road, wheel track, kerb.
## Inside and outside in one light (ticket 27): the sun on the faces the camera sees (they face the
## bottom of the screen, azimuth 0 in screen terms); no building shadows (the human: none); the glass by day
## (sky in it, the sun's glint when the sun stands in front); a lit window's glow on the snow by night.
const SUN_ON_FACADES: PackedStringArray = ["brak", "fasady"]
const GLASS_BY_DAY: PackedStringArray = ["ciemne (bylo)", "niebo", "niebo i blysk"]
const FACADE_SUN_K: float = 0.5
const SUN_SEEN_LUX: float = 1500.0 ## Sun lux at which glints are full.
const GLASS_SKY_K: float = 0.25
## Critic 2 (south on top: facades in shade): the snow on roof edges, chimneys and sills catches the
## low sun (warm, stronger at golden hour); some windows have a lamp on by day too (a lit window by
## day says someone is home).
const RIM_K: float = 0.35
const RIM_GOLD_K: float = 0.5 ## Added at golden hour.
const DAY_LAMP_EVERY: int = 2
const DAY_LAMP_K: float = 0.85
const GLINT_K: float = 1.2
## Which windows catch the sun's glint: about one in GLINT_EVERY, in a scattered pattern (a glint on
## every window reads as a texture).
const GLINT_EVERY: int = 3
const GLINT_PX: Vector2 = Vector2(3.0, 1.0) ## Widths of the two streaks.
const GLINT_GAP_PX: float = 4.0
const WINDOW_GLOW_LUX: float = 90.0 ## A lit window's glow on the snow under it, lx at its brightest.
const WINDOW_GLOW_M: float = 1.7 ## Its radius.
const UPPER_GLOW_K: float = 0.5 ## Upper storeys glow less on the ground.

const CLEARED: PackedColorArray = [Color("c3cad4"), Color("8a919c"), Color("737a86"), Color("5d636d")]
const PACKED: PackedColorArray = [Color("d9dee6"), Color("c4cad3"), Color("a8afba"), Color("9aa1ad")]

var _storey_m: float = 2.9
var _street: Vector3 = Vector3.ZERO
var _sky: Polygon2D
var _night_painters: Array[ShapePainter] = []
var _street_room: RoomLighting
var _sun_light: PointLight2D
var _building_kind: int = 0
var _building_windows: int = 0
var _glass_painters: Array[ShapePainter] = []
var _glint_painters: Array[ShapePainter] = []
var _glows: Array[PointLight2D] = []
var _glow_ks: PackedFloat32Array = PackedFloat32Array()
var _rim_painters: Array[ShapePainter] = []
var _day_lamp_painters: Array[ShapePainter] = []
var _building_rim: ShapePainter
var _building_day_lamps: ShapePainter
var _building_glass: ShapePainter ## The building being built (_building, _window).
var _building_glint: ShapePainter
var _building_spec: Vector4 = Vector4.ZERO
var _building_front: float = 0.0
var _building_lift: float = 0.0
var _window_count: int = 0 ## For the pattern of dark windows.
var _overview: bool = false
var _pitch: float = 0.9
var _stairs: int = 1
var _zone_front: Rect2 = Rect2() ## Px of the world; empty when there is no such flight.
var _zone_side: Rect2 = Rect2() ## Bottom step's x range, y from its back to its front edge.
var _zone_door: Rect2 = Rect2()
var _stair_lag: float = 0.0
var _door_time: float = 0.0
var _door_down: float = 0.0
var _street_map: StreetMap ## Ticket 14: the street's light from one buffer.
var _street_box: RoomBox
var _ground_m: Vector2 = Vector2.ZERO
var _force_light: bool = true ## The next street light repaints whatever the clock (an option changed).


func _add_layout_options() -> void:
	_layout_option(&"gora_mapy", "Góra ekranu", DomBryly.TOPS, 1) # decided: south (tickets 27, 31), as the house
	_layout_option(&"slonce_fasady", "Słońce na ulicy", SUN_ON_FACADES, 1)
	_layout_option(&"szyby_dzien", "Szyby w dzień", GLASS_BY_DAY, 2)
	_layout_option(&"poswiata", "Poświata okien na śniegu", ON_OFF, 0)
	_layout_option(&"krawedz", "Ciepła krawędź śniegu (słońce)", ON_OFF, 0)
	_layout_option(&"lampy_dzien", "Lampy w oknach w dzień", ON_OFF, 0)
	_layout_option(&"uklad", "Układ głębi", LAYOUTS, 0)
	var names: PackedStringArray = PackedStringArray()
	for share: float in STOREYS:
		names.append("%.1fx" % share)
	_layout_option(&"pietro", "Piętro fasady (× postaci)", names, 1)
	_layout_option(&"dach", "Dachy", ROOFS, 3)
	_layout_option(&"glebia", "Głębia budynków (dach i obrys)", DEPTH_NAMES, 2)
	_layout_option(&"spadek", "Spadek dachu", PITCH_NAMES, 0)
	_layout_option(&"ulica", "Ulica (chodnik+jezdnia+chodnik)", STREET_NAMES, 1)
	_layout_option(&"nawierzchnia", "Jezdnia", SURFACES, 0)
	_layout_option(&"zaspy", "Zaspy i śnieg na parapetach", ON_OFF, 0)
	_layout_option(&"czapy", "Czapy śniegu na dachach", ON_OFF, 0)
	_layout_option(&"okna", "Okna nocą", WINDOWS_AT_NIGHT, 0)
	_layout_option(&"schody", "Schody na taras (układ A)", STAIR_MODES, 1)
	_layout_option(&"prog", "Próg drzwi domu (raczej nie)", DOORSTEP_MODES, 0)
	_layout_option(&"chod_pion", "Chód w pionie (ekran)", VERTICAL_NAMES, 0)
	_add_street_light_options()
	DebugRegistry.add_toggle(self, &"podglad", "Podgląd całości ×0,5 (nie do oceny pikseli)", false, func(on: bool) -> void:
		_overview = on
		_apply_overview())


func _build_world() -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	street_scene = scene_file_path
	LightingDirector.top_azimuth_deg = DomBryly.TOP_AZIMUTHS[_value(&"gora_mapy")]
	_storey_m = STOREYS[_value(&"pietro")] * config.actor_height_m
	_pitch = PITCHES[_value(&"spadek")]
	_stairs = _value(&"schody")
	_street = STREETS[_value(&"ulica")]
	var layout: int = _value(&"uklad")
	var road_z: float = FRONT_Z_M + _street.x
	var south_z: float = road_z + _street.y
	var bottom_z: float = south_z + _street.z + NEAR_STRIP_M

	_street_map = StreetMap.new()
	var box: RoomBox = RoomBox.new()
	box.width_m = WIDTH_M
	box.depth_m = bottom_z
	box.wall_height_m = 0.0
	box.above_m = ABOVE_M
	box.floor_color = SNOW
	var street: RoomLighting = _room(Vector2.ZERO, box, OUTDOOR)
	_street_room = street
	_street_box = box
	_ground_m = Vector2(WIDTH_M, bottom_z)
	_paint_ground(street, layout, road_z, south_z)
	_build_sun(street, box)
	_grid(street, box.floor_rect(), 0)
	var lamps: Array[Vector2] = [Vector2(2.5, road_z - 0.35), Vector2(GAP_X.x - 0.6, road_z - 0.35),
			Vector2(GAP_X.y + 1.5, road_z - 0.35), Vector2(38.0, road_z - 0.35)]
	for lamp: Vector2 in lamps:
		var spot: Node2D = Node2D.new()
		spot.position = ground(lamp.x, lamp.y)
		var fixture: LightFixture = LightFixture.new()
		fixture.def = STREET_LAMP
		spot.add_child(fixture)
		_street_map.fixtures.append(fixture)
		street.add_child(spot)
	world.add_child(street)
	for lamp: Vector2 in lamps:
		_block(world, ground(lamp.x, lamp.y), Vector3(0.2, 0.2, 4.2), Color(0.2, 0.2, 0.22), Color(0.3, 0.3, 0.32))

	var roofs: int = _value(&"dach")
	var house_front: float = FRONT_Z_M - (HOUSE_SETBACK_M if layout == 2 else 0.0)
	_building(HOUSE, house_front, 0.0, HOUSE_COLOR, _roof_for(roofs, 0), 0)
	_building(SHOP, FRONT_Z_M, 0.0, SHOP_COLOR, _roof_for(roofs, 1), 1)
	match layout:
		0:
			_terrace()
			_building(BACKDROP, 10.0, TERRACE_M, BACKDROP_COLOR, _roof_for(roofs, 2), 2)
		1:
			_building(Vector4(BACKDROP.x - 1.0, BACKDROP.y + 2.0, BACKDROP.z, BACKDROP.w), SIDE_STREET_END_Z, 0.0,
					BACKDROP_COLOR, _roof_for(roofs, 2), 2)
		_:
			_building(Vector4(BACKDROP.x + 1.0, BACKDROP.y - 2.0, BACKDROP.z, 2.0), YARD_FRONT_Z, 0.0,
					BACKDROP_COLOR, _roof_for(roofs, 2), 2)
			_yard()
	_fillers(layout, road_z, south_z, bottom_z)
	_comparison_row(world, ground(5.0, south_z + 1.4))

	var door_x: float = HOUSE.x + HOUSE.y / 2.0
	if _value(&"prog") == 1:
		_doorstep(door_x, house_front)
	var door: Door = Door.new()
	door.target_scene = DOM_SCENE
	door.spawn = &"z_ulicy"
	door.size_m = Vector2(DOOR_M.x, 0.3)
	door.at_m = ground(door_x, house_front + 0.15) / config.px_per_m
	world.add_child(door)
	_spawn("start", ground(GAP_X.x + 4.0, road_z + _street.y / 2.0))
	_spawn("z_domu", ground(door_x, house_front + 1.2))
	_spawn("przerwa", ground((GAP_X.x + GAP_X.y) / 2.0, FRONT_Z_M + 1.0)) # shots: the gap between the house and the shop
	_build_sky(box)
	for child: Node in world.get_children():
		if child is Block:
			_street_map.add_block(child as Block)
	world.add_child(_street_map)


func start(spawn: StringName) -> void:
	super.start(spawn)
	_street_map.setup(_street_room, player, _street_box.ambient_rect(), _ground_m)
	# As the house (the human: too many options to check): the light's few choices; the rest keeps its value, hidden.
	var hidden: Array[StringName] = []
	for option: DebugOption in DebugRegistry.options():
		if not SHOWN_OPTIONS.has(option.id):
			hidden.append(option.id)
	DebugRegistry.hidden = hidden
	DebugRegistry.minimal = true
	DebugRegistry.options_changed.emit()
	_readout.visible = false
	_apply_street_light()
	player.vertical_speed = VERTICAL_SPEEDS[_value(&"chod_pion")]
	_apply_overview()


## Zoomed out to see the whole street with its roofs; the limits widen with it.
func _apply_overview() -> void:
	if player == null:
		return
	var zoom: float = 0.5 if _overview else 1.0
	player.camera.zoom = Vector2(zoom, zoom)
	player.set_camera_limits(_fit_to_view(_bounds(), get_viewport().get_visible_rect().size / zoom))
	player.camera.reset_smoothing()


func apply_time(hour: float) -> void:
	super.apply_time(hour)
	var sky: Color = director.sun.sky_color
	var bright: float = lerpf(0.25, 1.0, director.sun.day)
	_sky.color = Color(sky.r * bright, sky.g * bright, sky.b * bright)
	var night: float = clampf(1.0 - director.sun.day * 1.6, 0.0, 1.0)
	if _value(&"okna") == 1:
		night = 0.0
	for painter: ShapePainter in _night_painters:
		painter.modulate = Color(1.0, 1.0, 1.0, night)
	_apply_sun(night)
	_apply_street_light()


func _readout_extra() -> String:
	var config: ProjectionConfig = ProjectionConfig.current()
	var actor: float = config.actor_height_m
	var view_m: float = get_viewport().get_visible_rect().size.y / config.px_per_m
	return "\nulica %.1f+%.1f+%.1f m = %d px wys. · piętro %.2f m = %.1f WP · dom 2 kond. %.1f WP do okapu · kadr %.1f m ekranu = %.1f m głębi ziemi" % [
		_street.x, _street.y, _street.z, roundi(config.depth_px(_street.x + _street.y + _street.z)),
		_storey_m, _storey_m / actor, 2.0 * _storey_m / actor, view_m, view_m / config.depth_factor]


## Roof type for building `which` (0 house, 1 shop, 2 facade): 0 flat, 1 ridge along the street,
## 2 gable to the street.
static func _roof_for(variant: int, which: int) -> int:
	if variant < 3:
		return variant
	var mixed: PackedInt32Array = [2, 0, 1]
	return mixed[which]


## A building: `spec` = left x, width, depth, storeys; front at ground z `front`, lifted `lift_m`
## (on the terrace). Walls, plinth, windows, door or display windows, roof; warm windows at night on
## an unshaded layer; the footprint stops walking.
func _building(spec: Vector4, front: float, lift_m: float, color: Color, roof: int, kind: int) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var width: float = spec.y
	var depth: float = spec.z * DEPTH_SCALES[_value(&"glebia")]
	var storeys: int = int(spec.w)
	var node: Node2D = Node2D.new()
	node.position = ground(spec.x + width / 2.0, front) - Vector2(0.0, config.px(lift_m))
	var paint: ShapePainter = ShapePainter.new(LightMasks.of(0, LightMasks.Receiver.SOLID))
	var lit: ShapePainter = ShapePainter.new(LightMasks.of(0, LightMasks.Receiver.SOLID))
	var unshaded: CanvasItemMaterial = CanvasItemMaterial.new()
	unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	lit.material = unshaded
	_night_painters.append(lit)
	_building_glass = _additive_painter()
	_building_rim = _additive_painter()
	_rim_painters.append(_building_rim)
	_building_day_lamps = ShapePainter.new(LightMasks.of(0, LightMasks.Receiver.SOLID))
	_building_day_lamps.material = unshaded
	_day_lamp_painters.append(_building_day_lamps)
	_building_glint = _additive_painter()
	_glass_painters.append(_building_glass)
	_glint_painters.append(_building_glint)
	_building_spec = spec
	_building_front = front
	_building_lift = lift_m
	_building_kind = kind
	_building_windows = 0
	var snow: bool = _value(&"zaspy") == 0
	var height: float = storeys * _storey_m
	var w: float = config.px(width)
	var h: float = config.px(height)
	_add_building_box(spec, depth, front, lift_m, height, roof)
	paint.add_rect(_px(Rect2(-w / 2.0, -h, w, h)), color)
	paint.add_rect(_px(Rect2(-w / 2.0, -config.px(0.4), w, config.px(0.4))), PLINTH)

	var openings: Array[Rect2] = [] ## In metres from the bottom left of the front.
	var behind: Array[StringName] = [] ## The house's room behind each opening (empty: anyone's).
	var shop_windows: Array[Rect2] = []
	var count: int = maxi(int(width / 2.8), 1)
	var step: float = width / count
	var door_column: int = count / 2
	for storey: int in storeys:
		if kind == 1 and storey == 0:
			continue
		for column: int in count:
			if kind == 0 and storey == 0 and column == door_column:
				continue
			var window_h: float = minf(WINDOW_M.y, _storey_m - SILL_M - 0.25)
			openings.append(Rect2(step * (column + 0.5) - WINDOW_M.x / 2.0, storey * _storey_m + SILL_M,
					WINDOW_M.x, window_h))
			var room: String = ""
			if kind == 0 and count == 3 and storey * 3 + column < HOUSE_ROOMS.size():
				room = HOUSE_ROOMS[storey * 3 + column]
			behind.append(StringName(room))
	if kind == 1:
		# Display windows on the ground floor, the door between them, a sign band above.
		var top: float = minf(2.6, _storey_m - 0.5)
		var door_left: float = width / 2.0 - 0.6
		for piece: Vector2 in [Vector2(0.6, door_left - 0.3), Vector2(door_left + 1.5, width - 0.6)]:
			shop_windows.append(Rect2(piece.x, 0.5, piece.y - piece.x, top - 0.5))
		paint.add_rect(_front(Rect2(door_left, 0.0, 1.2, minf(DOOR_M.y, top)), w), DOOR)
		paint.add_rect(_front(Rect2(0.4, _storey_m - 0.45, width - 0.8, 0.4), w), SIGN)
		for storey: int in range(1, storeys):
			paint.add_rect(_front(Rect2(0.0, storey * _storey_m - 0.12, width, 0.12), w), color.darkened(0.25))
	for index: int in openings.size():
		_window(paint, lit, openings[index], w, snow, LIT_WINDOW, behind[index])
	for window: Rect2 in shop_windows:
		_window(paint, lit, window, w, snow, LIT_SHOP)
	if kind == 0:
		var door_x: float = width / 2.0 - DOOR_M.x / 2.0
		var door_h: float = minf(DOOR_M.y, _storey_m - 0.3)
		paint.add_rect(_front(Rect2(door_x - 0.12, 0.0, DOOR_M.x + 0.24, door_h + 0.12), w), FRAME.darkened(0.3))
		paint.add_rect(_front(Rect2(door_x, 0.0, DOOR_M.x, door_h), w), DOOR)
		paint.add_rect(_front(Rect2(door_x - 0.3, door_h + 0.15, DOOR_M.x + 0.6, 0.12), w), FENCE)
		if DomBryly.lamp_on(&"korytarz"):
			lit.add_rect(_front(Rect2(width / 2.0 - 0.15, door_h + 0.3, 0.3, 0.2), w), LIT_WINDOW)
	_roof(paint, lit, width, depth, height, roof, kind)
	node.add_child(paint)
	node.add_child(_building_glass)
	node.add_child(_building_glint)
	node.add_child(_building_rim)
	node.add_child(_building_day_lamps)
	node.add_child(lit)
	_building_rim = null # snow edges outside buildings (terrace, stairs, fences) stay plain
	var body: StaticBody2D = StaticBody2D.new()
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(w, config.depth_px(depth))
	shape.shape = rect
	shape.position = Vector2(0.0, -rect.size.y / 2.0)
	body.add_child(shape)
	node.add_child(body)
	world.add_child(node)


## A window with a frame, a mullion, snow on the sill; most windows also glow at night (a window of
## the house: when the room behind has its lamp on).
func _window(paint: ShapePainter, lit: ShapePainter, window: Rect2, w: float, snow: bool, glow: Color,
		room: StringName = &"") -> void:
	var frame: float = 0.08
	paint.add_rect(_front(window.grow(frame), w), FRAME)
	paint.add_rect(_front(window, w), GLASS)
	_glass_day(window, w)
	paint.add_rect(_front(Rect2(window.get_center().x - 0.04, window.position.y, 0.08, window.size.y), w), FRAME)
	_window_count += 1
	var glows: bool = DomBryly.lamp_on(room) if room != &"" else (_window_count * 7 + 3) % 10 < 7
	if glows:
		lit.add_rect(_front(Rect2(window.position.x, window.position.y, window.size.x / 2.0 - 0.04, window.size.y), w), glow)
		lit.add_rect(_front(Rect2(window.get_center().x + 0.04, window.position.y,
				window.size.x / 2.0 - 0.04, window.size.y), w), glow)
		_add_glow(window, glow)
		_street_map.add_window(Vector4(_building_spec.x + window.position.x, _building_spec.x + window.end.x,
				_building_lift + window.position.y, _building_lift + window.end.y), _building_front, glow,
				_window_count % DAY_LAMP_EVERY == 0)
		if _window_count % DAY_LAMP_EVERY == 0:
			_building_day_lamps.add_rect(_front(window, w), glow)
	if snow:
		_snow_edge(paint, _front(Rect2(window.position.x - 0.15, window.position.y - 0.18, window.size.x + 0.3, 0.1), w))


## The roof over a front `height` m tall: flat with a parapet, ridge along the street, or gable to the
## street. Only the front slopes show; the back ones are hidden behind the ridge at this angle.
func _roof(paint: ShapePainter, lit: ShapePainter, width: float, depth: float, height: float, roof: int,
		kind: int) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var capped: bool = _value(&"czapy") == 0
	var w: float = config.px(width)
	var h: float = config.px(height)
	var eave: float = config.px(EAVE_M)
	match roof:
		0:
			var top: float = config.depth_px(depth)
			paint.add_rect(_px(Rect2(-w / 2.0, -h - top, w, top)), ROOF_SNOW if capped else FLAT_BARE)
			var parapet: float = config.px(0.35)
			paint.add_rect(_px(Rect2(-w / 2.0, -h - parapet, w, parapet)), PLINTH.lightened(0.15))
			if capped:
				_snow_edge(paint, _px(Rect2(-w / 2.0, -h - parapet - 2.0, w, 2.0)))
		1:
			var rise: float = config.px(_pitch * depth / 2.0)
			var ridge: float = -h - rise - config.depth_px(depth / 2.0)
			_chimney(paint, w * 0.25, ridge, capped)
			var slope: Color = ROOF_SNOW if capped else ROOF_BARE
			paint.add_rect(_px(Rect2(-w / 2.0 - eave, ridge, w + 2.0 * eave, -h + eave * 0.6 - ridge)), slope)
			if capped:
				_snow_edge(paint, _px(Rect2(-w / 2.0 - eave, ridge, w + 2.0 * eave, 2.0)))
				paint.add_rect(_px(Rect2(-w / 2.0 - eave, -h + eave * 0.6 - 3.0, w + 2.0 * eave, 3.0)), SNOW_SHADE)
			paint.add_rect(_px(Rect2(-w / 2.0 - eave, -h + eave * 0.6, w + 2.0 * eave, 2.0)), FENCE)
		2:
			var rise: float = config.px(_pitch * width / 2.0)
			var back: float = config.depth_px(depth)
			var slope: Color = ROOF_SNOW if capped else ROOF_BARE
			var drop: float = eave * _pitch
			paint.add_polygon(_points([Vector2(0.0, -h - rise), Vector2(-w / 2.0, -h), Vector2(w / 2.0, -h)]),
					_gable_color(kind))
			paint.add_polygon(_points([Vector2(-w / 2.0 - eave, -h + drop), Vector2(0.0, -h - rise),
					Vector2(0.0, -h - rise - back), Vector2(-w / 2.0 - eave, -h + drop - back)]), slope)
			paint.add_polygon(_points([Vector2(w / 2.0 + eave, -h + drop), Vector2(0.0, -h - rise),
					Vector2(0.0, -h - rise - back), Vector2(w / 2.0 + eave, -h + drop - back)]), slope.darkened(0.08))
			_chimney(paint, w * 0.2, -h - rise * 0.5 - back * 0.6, capped)
			# Barge boards along the gable's edges.
			var board: float = 3.0
			paint.add_polygon(_points([Vector2(-w / 2.0 - eave, -h + drop), Vector2(0.0, -h - rise),
					Vector2(0.0, -h - rise + board), Vector2(-w / 2.0 - eave, -h + drop + board)]), FENCE)
			paint.add_polygon(_points([Vector2(w / 2.0 + eave, -h + drop), Vector2(0.0, -h - rise),
					Vector2(0.0, -h - rise + board), Vector2(w / 2.0 + eave, -h + drop + board)]), FENCE)
			# A small attic window in the gable.
			var attic: Rect2 = Rect2(width / 2.0 - 0.45, height + 0.6, 0.9, minf(1.1, _pitch * width / 2.0 - 1.4))
			if attic.size.y > 0.4:
				_window(paint, lit, attic, w, _value(&"zaspy") == 0, LIT_WINDOW)


func _gable_color(kind: int) -> Color:
	var colors: PackedColorArray = [HOUSE_COLOR, SHOP_COLOR, BACKDROP_COLOR]
	return colors[kind]


func _chimney(paint: ShapePainter, x: float, top: float, capped: bool) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var size: Vector2 = Vector2(config.px(0.6), config.px(1.6))
	paint.add_rect(_px(Rect2(x - size.x / 2.0, top - size.y * 0.6, size.x, size.y)), Color("4f3e36"))
	if capped:
		_snow_edge(paint, _px(Rect2(x - size.x / 2.0 - 1.0, top - size.y * 0.6 - 3.0, size.x + 2.0, 3.0)))


## Layout A: a raised terrace in the gap between the house and the shop, a stone wall in front with
## stairs (variant "Schody"), the facade standing on it. Painted as ground; the wall stops walking
## except at the stairs.
func _terrace() -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var lift: Vector2 = Vector2(0.0, config.px(TERRACE_M))
	var paint: ShapePainter = ShapePainter.new(LightMasks.of(0, LightMasks.Receiver.FLOOR), RoomBox.WALL_Z + 3)
	var top_from: Vector2 = ground(GAP_X.x, TERRACE_Z.x) - lift
	_street_map.add_box(AABB(Vector3(GAP_X.x, TERRACE_Z.x, 0.0), Vector3(GAP_X.y - GAP_X.x, TERRACE_Z.y - TERRACE_Z.x, TERRACE_M)), true, true)
	var top_to: Vector2 = ground(GAP_X.y, TERRACE_Z.y) - lift
	paint.add_rect(_px(Rect2(top_from, top_to - top_from)), Color("e0e5ec"))
	var face: Rect2 = Rect2(top_from.x, top_to.y, top_to.x - top_from.x, lift.y)
	paint.add_rect(_px(face), STONE)
	if _value(&"zaspy") == 0:
		_snow_edge(paint, _px(Rect2(face.position.x, face.position.y - 2.0, face.size.x, 3.0)))
	world.add_child(paint)
	var gap: Vector2 = STAIRS_X if _stairs != 2 else Vector2(SIDE_STAIRS_X,
			SIDE_STAIRS_X + STEPS * SIDE_RUN_M + SIDE_LANDING_M)
	var gap_px: Vector2 = Vector2(config.px(gap.x), config.px(gap.y))
	match _stairs:
		0:
			for index: int in STEPS:
				var y: float = face.position.y + face.size.y * index / STEPS
				paint.add_rect(_px(Rect2(gap_px.x, y, gap_px.y - gap_px.x, face.size.y / STEPS)),
						SNOW_SHADE if index % 2 == 0 else Color("9a978f"))
		1:
			_front_stairs(paint)
		_:
			_side_stairs(paint)
	# The wall stops walking except at the stairs; the terrace's sides and back too.
	_wall(Rect2(face.position.x, face.position.y, gap_px.x - face.position.x, face.size.y))
	_wall(Rect2(gap_px.y, face.position.y, face.end.x - gap_px.y, face.size.y))
	_wall(Rect2(top_from.x - 4.0, top_from.y - 4.0, 4.0, face.end.y - top_from.y + 4.0))
	_wall(Rect2(top_to.x, top_from.y - 4.0, 4.0, face.end.y - top_from.y + 4.0))
	_wall(Rect2(top_from.x, top_from.y - 4.0, top_to.x - top_from.x, 4.0))
	var lamp: Vector2 = ground(STAIRS_X.y + 0.6, TERRACE_Z.y - 0.4) - lift
	_block(world, lamp, Vector3(0.15, 0.15, 3.2), Color(0.2, 0.2, 0.22), Color(0.3, 0.3, 0.32))


## Variant A: a flight straight into the wall, sticking out STEPS × RUN_M in front of it, with stone
## cheeks at its sides. Drawn from the top step forward, each step's front covering the one behind.
func _front_stairs(paint: ShapePainter) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var step_h: float = config.px(STEP_M)
	var left: float = config.px(STAIRS_X.x)
	var width: float = config.px(STAIRS_X.y - STAIRS_X.x)
	var foot_z: float = TERRACE_Z.y + STEPS * RUN_M
	for index: int in range(STEPS - 1, -1, -1):
		var front_z: float = TERRACE_Z.y + RUN_M * (STEPS - index)
		var height: float = step_h * (index + 1)
		var tread_top: float = ground(0.0, front_z - RUN_M).y - height
		var front: float = ground(0.0, front_z).y - height
		paint.add_rect(_px(Rect2(left, tread_top, width, front - tread_top)), SNOW_SHADE)
		paint.add_rect(_px(Rect2(left, front, width, height)), Color("8a8780"))
		_snow_edge(paint, _px(Rect2(left, front, width, 1.0)))
	var cheek: float = config.px(0.3)
	var wall_top: float = ground(0.0, TERRACE_Z.y).y - config.px(TERRACE_M)
	var top: float = wall_top - config.px(0.15)
	var bottom: float = ground(0.0, foot_z).y
	for x: float in [left - cheek, left + width]:
		paint.add_rect(_px(Rect2(x, top, cheek, bottom - top - cheek)), STONE.lightened(0.12))
		paint.add_rect(_px(Rect2(x, bottom - cheek, cheek, cheek)), STONE.darkened(0.15))
		_wall(Rect2(x, top, cheek, bottom - top))
	_zone_front = Rect2(left, wall_top, width, bottom - wall_top)


## Variant B: a flight along the wall, rising to the right, SIDE_DEPTH_M deep; walls under it and
## above it keep the player on the flight.
func _side_stairs(paint: ShapePainter) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var step_h: float = config.px(STEP_M)
	var back: float = ground(0.0, TERRACE_Z.y).y
	var front: float = ground(0.0, TERRACE_Z.y + SIDE_DEPTH_M).y
	var from_x: float = config.px(SIDE_STAIRS_X)
	var run: float = config.px(SIDE_RUN_M)
	for index: int in STEPS:
		var x: float = from_x + run * index
		var height: float = step_h * (index + 1)
		paint.add_rect(_px(Rect2(x, back - height, run, front - back)), SNOW_SHADE)
		paint.add_rect(_px(Rect2(x, front - height, run, height)), Color("8a8780"))
		_snow_edge(paint, _px(Rect2(x, front - height, run, 1.0)))
	var to_x: float = from_x + run * STEPS
	var rise: float = config.px(TERRACE_M)
	# A landing at the top, wider than the feet, so the player can turn up onto the terrace.
	var landing: float = config.px(SIDE_LANDING_M)
	paint.add_rect(_px(Rect2(to_x, back - rise, landing, front - back)), SNOW_SHADE)
	paint.add_rect(_px(Rect2(to_x, front - rise, landing, rise)), Color("8a8780"))
	_snow_edge(paint, _px(Rect2(to_x, front - rise, landing, 1.0)))
	_wall_polygon(PackedVector2Array([Vector2(from_x, back - rise), Vector2(to_x, back - rise), Vector2(from_x, back)]))
	_wall_polygon(PackedVector2Array([Vector2(from_x, front + 2.0), Vector2(to_x, front - rise + 2.0),
			Vector2(to_x, front + 2.0)]))
	_wall(Rect2(to_x, front - rise + 2.0, landing, rise))
	_zone_side = Rect2(from_x, back, to_x - from_x, front - back)


## Variant C: one step in front of the house door.
func _doorstep(door_x: float, front_z: float) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var height: float = config.px(DOORSTEP_M.z)
	var from: Vector2 = ground(door_x - DOORSTEP_M.x / 2.0, front_z)
	var to: Vector2 = ground(door_x + DOORSTEP_M.x / 2.0, front_z + DOORSTEP_M.y)
	var paint: ShapePainter = ShapePainter.new(LightMasks.of(0, LightMasks.Receiver.FLOOR), RoomBox.WALL_Z + 4)
	paint.add_rect(_px(Rect2(from.x, from.y - height, to.x - from.x, to.y - from.y)), Color("b9b6ae"))
	paint.add_rect(_px(Rect2(from.x, to.y - height, to.x - from.x, height)), Color("7d7a73"))
	_snow_edge(paint, _px(Rect2(from.x, to.y - height, to.x - from.x, 1.0)))
	paint.add_rect(_px(Rect2(from.x, to.y, to.x - from.x, 2.0)), Color(0.0, 0.0, 0.0, 0.25))
	world.add_child(paint)
	_zone_door = Rect2(from.x, from.y, to.x - from.x, to.y - from.y)


## A wall that stops walking, a polygon in px of the world.
func _wall_polygon(points: PackedVector2Array) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	var shape: CollisionPolygon2D = CollisionPolygon2D.new()
	shape.polygon = points
	body.add_child(shape)
	world.add_child(body)


## Stairs and the doorstep (research 77): the feet move on, the figure is drawn lower until it has
## climbed a whole step, then jumps up by it (smoothed); slower on the flight; on the side flight
## left/right also climb. The doorstep: a small hop up when stepping on it.
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if player == null:
		return
	var config: ProjectionConfig = ProjectionConfig.current()
	var step_h: float = config.px(STEP_M)
	var rise: float = config.px(TERRACE_M)
	var at: Vector2 = player.position
	var lag: float = 0.0
	var speed: float = 1.0
	var slope: float = 0.0
	if _zone_front.has_area() and _zone_front.grow(1.0).has_point(at):
		var climbed: float = clampf((_zone_front.end.y - at.y) / _zone_front.size.y, 0.0, 1.0) * rise
		lag = climbed - floorf(climbed / step_h) * step_h
		speed = STAIRS_UP_SPEED if player.velocity.y < 0.0 else STAIRS_DOWN_SPEED
	elif _zone_side.has_area() and at.x >= _zone_side.position.x and at.x <= _zone_side.end.x:
		var share: float = (at.x - _zone_side.position.x) / _zone_side.size.x
		var back: float = _zone_side.position.y - share * rise
		if at.y >= back - 2.0 and at.y <= back + _zone_side.size.y + 2.0:
			var climbed: float = share * rise
			lag = climbed - floorf(climbed / step_h) * step_h
			speed = SIDE_STAIRS_SPEED
			slope = rise / _zone_side.size.x
	_stair_lag = move_toward(_stair_lag, lag, step_h / STEP_SMOOTH_S * delta)
	var step_px: float = config.px(DOORSTEP_M.z)
	var offset: float = _stair_lag
	if _zone_door.has_area() and _zone_door.has_point(at):
		_door_time += delta
		offset += -step_px * minf(_door_time / HOP_UP_S, 1.0) - HOP_ARC_PX * sin(PI * minf(_door_time / HOP_ARC_S, 1.0))
		_door_down = -step_px
	else:
		_door_time = 0.0
		_door_down = move_toward(_door_down, 0.0, step_px / HOP_UP_S * delta)
		offset += _door_down
	player.visual_offset = Vector2(0.0, roundf(offset))
	player.zone_speed = speed
	player.stair_slope = slope


## Layout C: a fenced front yard with a gate in front of the set-back facade, a spruce in it.
func _yard() -> void:
	var fence_z: float = FRONT_Z_M - 0.3
	for piece: Vector2 in [Vector2(GAP_X.x, 17.2), Vector2(18.8, GAP_X.y)]:
		_block(world, ground((piece.x + piece.y) / 2.0, fence_z), Vector3(piece.y - piece.x, 0.12, 1.3), FENCE, FENCE_TOP)
	_spruce(ground(20.5, 15.5), 4.5)


## Lamps aside: trees, a parked car, snowbanks, fences on the plots at both ends, the low wall on the
## camera side.
func _fillers(layout: int, road_z: float, south_z: float, bottom_z: float) -> void:
	var snow: bool = _value(&"zaspy") == 0
	_bare_tree(ground(2.0, FRONT_Z_M + 0.8), 6.0)
	_bare_tree(ground(40.5, road_z - 0.6), 6.5)
	_spruce(ground(39.0, FRONT_Z_M - 3.5), 6.0)
	for piece: Vector2 in [Vector2(0.0, HOUSE.x - 0.2), Vector2(SHOP.x + SHOP.y + 0.2, WIDTH_M)]:
		_block(world, ground((piece.x + piece.y) / 2.0, FRONT_Z_M - 0.2), Vector3(piece.y - piece.x, 0.12, 1.3),
				FENCE, FENCE_TOP)
	_car(ground(29.0, south_z - 0.4))
	_block(world, ground(SHOP.x + SHOP.y / 2.0 + 2.2, FRONT_Z_M + 0.5), Vector3(0.6, 0.5, 0.9), Color("3e4a44"),
			SNOW_TOP if snow else Color("55625b"))
	if snow:
		# Banks along both kerbs with gaps at crossings, and a heap at each facade.
		var gaps: Array[Vector2] = [GAP_X if layout == 1 else STAIRS_X]
		var x: float = 0.5
		while x < WIDTH_M - 1.0:
			var length: float = 2.6
			var blocked: bool = false
			for gap: Vector2 in gaps:
				if x + length > gap.x and x < gap.y:
					blocked = true
			if not blocked and not (x > 27.0 and x < 31.5):
				_block(world, ground(x + length / 2.0, road_z - 0.05), Vector3(length - 0.4, 0.5, 0.45), SNOW_SHADE, SNOW_TOP)
			if not blocked:
				_block(world, ground(x + length / 2.0, south_z + 0.55), Vector3(length - 0.6, 0.5, 0.5), SNOW_SHADE, SNOW_TOP)
			x += length + 0.6
		for heap: Vector3 in [Vector3(HOUSE.x + 1.2, FRONT_Z_M + 0.35, 1.6), Vector3(SHOP.x + SHOP.y - 1.0, FRONT_Z_M + 0.35, 1.4)]:
			_block(world, ground(heap.x, heap.y), Vector3(heap.z, 0.35, 0.4), SNOW_SHADE, SNOW_TOP)
	for piece: Vector2 in [Vector2(0.0, 9.0), Vector2(11.0, 24.0), Vector2(26.0, WIDTH_M)]:
		_block(world, ground((piece.x + piece.y) / 2.0, bottom_z - 0.4), Vector3(piece.y - piece.x, 0.4, 0.7),
				Color("5b5650"), SNOW_TOP if snow else Color("6b665f"))


## A bare deciduous tree `height_m` tall: trunk, a few branches as thin polygons.
func _bare_tree(foot: Vector2, height_m: float) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var h: float = config.px(height_m)
	var node: Node2D = _prop(foot, Vector2(0.4, 0.3))
	_occluder(foot, Vector3(0.4, 0.3, height_m * 0.55))
	var paint: ShapePainter = node.get_child(0) as ShapePainter
	paint.add_rect(_px(Rect2(-3.0, -h * 0.55, 6.0, h * 0.55)), TRUNK)
	var branches: Array[Vector4] = [Vector4(0.0, 0.5, -0.35, 0.95), Vector4(0.0, 0.45, 0.3, 0.9),
			Vector4(0.0, 0.6, 0.0, 1.0), Vector4(-0.1, 0.7, -0.3, 0.8), Vector4(0.1, 0.65, 0.35, 0.75),
			Vector4(0.0, 0.4, -0.25, 0.6), Vector4(0.0, 0.38, 0.22, 0.55)]
	for branch: Vector4 in branches:
		var from: Vector2 = Vector2(branch.x * h, -branch.y * h)
		var to: Vector2 = Vector2(branch.z * h, -branch.w * h)
		var side: Vector2 = (to - from).orthogonal().normalized() * 1.5
		paint.add_polygon(_points([from - side * 1.4, to - side * 0.5, to + side * 0.5, from + side * 1.4]), TRUNK)
		if _value(&"zaspy") == 0:
			_snow_edge(paint, _px(Rect2(to.x - 3.0, to.y - 1.0, 4.0, 2.0)))


## A spruce `height_m` tall: stacked triangles with snow on their tops.
func _spruce(foot: Vector2, height_m: float) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var h: float = config.px(height_m)
	var node: Node2D = _prop(foot, Vector2(0.5, 0.4))
	_occluder(foot, Vector3(height_m * 0.3, height_m * 0.3, height_m))
	var paint: ShapePainter = node.get_child(0) as ShapePainter
	paint.add_rect(_px(Rect2(-3.0, -h * 0.15, 6.0, h * 0.15)), TRUNK)
	var tiers: int = 4
	for tier: int in tiers:
		var bottom: float = -h * (0.12 + 0.2 * tier)
		var top: float = bottom - h * 0.36
		var half: float = h * (0.24 - 0.045 * tier)
		paint.add_polygon(_points([Vector2(-half, bottom), Vector2(0.0, top), Vector2(half, bottom)]), SPRUCE)
		if _value(&"zaspy") == 0:
			paint.add_polygon(_points([Vector2(-half * 0.55, bottom - h * 0.13), Vector2(0.0, top),
					Vector2(half * 0.55, bottom - h * 0.13), Vector2(0.0, bottom - h * 0.17)]), SNOW_TOP)


## A parked car with its side to the camera, foot at the middle of its near side.
func _car(foot: Vector2) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var length: float = config.px(4.2)
	var body_h: float = config.px(0.8)
	var deep: float = config.depth_px(1.8)
	var node: Node2D = _prop(foot, Vector2(4.2, 1.8))
	_occluder(foot, Vector3(4.2, 1.8, 1.65))
	var paint: ShapePainter = node.get_child(0) as ShapePainter
	var capped: bool = _value(&"czapy") == 0
	# Body top (bonnet and boot), the cabin set back, then the body's side and the wheels.
	paint.add_rect(_px(Rect2(-length / 2.0, -body_h - config.px(0.25) - deep, length, deep)),
			SNOW_TOP if capped else CAR.lightened(0.15))
	var cabin: Rect2 = Rect2(-length * 0.28, -body_h - config.px(0.25) - deep * 0.15 - config.px(0.6), length * 0.56, config.px(0.6))
	paint.add_rect(_px(Rect2(cabin.position.x, cabin.position.y - deep * 0.7, cabin.size.x, deep * 0.7)),
			SNOW_TOP if capped else CAR.lightened(0.1))
	paint.add_rect(_px(cabin), CAR)
	paint.add_rect(_px(cabin.grow(-3.0)), CAR_GLASS)
	paint.add_rect(_px(Rect2(-length / 2.0, -body_h - config.px(0.25), length, body_h)), CAR)
	for wheel: float in [-length * 0.32, length * 0.32]:
		paint.add_rect(_px(Rect2(wheel - config.px(0.35), -config.px(0.6), config.px(0.7), config.px(0.6))), Color("17171a"))


## A y-sorted node at `foot` with one painter (child 0) and a footprint (m) that stops walking.
func _prop(foot: Vector2, footprint_m: Vector2) -> Node2D:
	var config: ProjectionConfig = ProjectionConfig.current()
	var node: Node2D = Node2D.new()
	node.position = foot
	node.add_child(ShapePainter.new(LightMasks.of(0, LightMasks.Receiver.SOLID)))
	var body: StaticBody2D = StaticBody2D.new()
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(config.px(footprint_m.x), config.depth_px(footprint_m.y))
	shape.shape = rect
	shape.position = Vector2(0.0, -rect.size.y / 2.0)
	body.add_child(shape)
	node.add_child(body)
	world.add_child(node)
	return node


## A wall that stops walking, `rect` in px of the world.
func _wall(rect: Rect2) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	var shape: CollisionShape2D = CollisionShape2D.new()
	var box: RectangleShape2D = RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	shape.position = rect.get_center()
	body.add_child(shape)
	world.add_child(body)


## Pavements, roads, kerbs and wheel tracks; the side street in layout B; a path to the stairs in A.
func _paint_ground(street: RoomLighting, layout: int, road_z: float, south_z: float) -> void:
	var colors: PackedColorArray = CLEARED if _value(&"nawierzchnia") == 0 else PACKED
	var paint: ShapePainter = ShapePainter.new(LightMasks.of(0, LightMasks.Receiver.FLOOR), RoomBox.WALL_Z + 1)
	_band(paint, 0.0, WIDTH_M, FRONT_Z_M, road_z, colors[0])
	_band(paint, 0.0, WIDTH_M, road_z, south_z, colors[1])
	_band(paint, 0.0, WIDTH_M, south_z, south_z + _street.z, colors[0])
	for track: float in [road_z + 0.8, road_z + 1.7, south_z - 1.9, south_z - 1.0]:
		_band(paint, 0.0, WIDTH_M, track, track + 0.3, colors[2])
	_band(paint, 0.0, WIDTH_M, road_z - 0.12, road_z, colors[3])
	_band(paint, 0.0, WIDTH_M, south_z, south_z + 0.12, colors[3])
	match layout:
		0:
			_band(paint, STAIRS_X.x - 0.3, STAIRS_X.y + 0.3, TERRACE_Z.y, FRONT_Z_M, colors[0])
			_band(paint, SIDE_STAIRS_X - 1.2, SIDE_STAIRS_X + 0.4, TERRACE_Z.y, FRONT_Z_M, colors[0])
		1:
			_band(paint, GAP_X.x, GAP_X.y, SIDE_STREET_END_Z, FRONT_Z_M, colors[0])
			_band(paint, GAP_X.x + 1.2, GAP_X.y - 1.2, SIDE_STREET_END_Z, road_z, colors[1])
			for track: float in [GAP_X.x + 2.2, GAP_X.x + 3.1, GAP_X.y - 3.4, GAP_X.y - 2.5]:
				_band(paint, track, track + 0.3, SIDE_STREET_END_Z + 1.0, road_z, colors[2])
		_:
			_band(paint, 17.2, 18.8, YARD_FRONT_Z, FRONT_Z_M, colors[0])
	street.add_child(paint)


static func _band(paint: ShapePainter, x0: float, x1: float, z0: float, z1: float, color: Color) -> void:
	var from: Vector2 = ground(x0, z0)
	paint.add_rect(_px(Rect2(from, ground(x1, z1) - from)), color)


## A rect on a front `w` px wide, given in metres from its bottom left; px relative to the foot.
static func _front(rect_m: Rect2, w: float) -> Rect2:
	var config: ProjectionConfig = ProjectionConfig.current()
	return _px(Rect2(-w / 2.0 + config.px(rect_m.position.x), -config.px(rect_m.position.y + rect_m.size.y),
			config.px(rect_m.size.x), config.px(rect_m.size.y)))


## Whole pixels.
static func _px(rect: Rect2) -> Rect2:
	var from: Vector2 = rect.position.round()
	return Rect2(from, rect.end.round() - from)


static func _points(points: Array[Vector2]) -> PackedVector2Array:
	var rounded: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in points:
		rounded.append(point.round())
	return rounded


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


## Ticket 27: the sun on every face the camera sees (they all face the bottom of the screen) and on
## actors, one flat light over the street.
func _build_sun(street: RoomLighting, box: RoomBox) -> void:
	var area: Rect2 = box.ambient_rect().grow(ProjectionConfig.current().px(20.0))
	var flat: Texture2D = LightTextures.get_shape(LightTextures.Shape.FLAT)
	_sun_light = PointLight2D.new()
	_sun_light.texture = flat
	_sun_light.position = area.get_center()
	_sun_light.scale = area.size / Vector2(flat.get_size())
	_sun_light.height = Lit.AMBIENT_HEIGHT # flat on every face: no N·L (lit.gdshader)
	_sun_light.range_item_cull_mask = LightMasks.of(0, LightMasks.Receiver.SOLID | LightMasks.Receiver.ACTOR)
	street.add_child(_sun_light)


## A strip of snow on top of something (roof edge, chimney, sill), which also catches the sun.
func _snow_edge(paint: ShapePainter, rect: Rect2) -> void:
	paint.add_rect(rect, SNOW_TOP)
	if _building_rim != null:
		_building_rim.add_rect(rect, Color.WHITE)


func _additive_painter() -> ShapePainter:
	var painter: ShapePainter = ShapePainter.new(LightMasks.of(0, LightMasks.Receiver.SOLID))
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	additive.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	painter.material = additive
	return painter


## The sky in the glass by day (white, tinted in _apply_sun) and, in about one window in three, the sun's
## glint: two thin parallel streaks across the left pane at 45°.
func _glass_day(window: Rect2, w: float) -> void:
	var rect: Rect2 = _front(window, w)
	_building_glass.add_rect(rect, Color.WHITE)
	_building_windows += 1
	if (_building_windows * 7 + _building_kind * 5) % GLINT_EVERY != 0:
		return
	var pane: Rect2 = Rect2(rect.position, Vector2(floorf(rect.size.x / 2.0) - 1.0, rect.size.y))
	var start: float = pane.position.x + pane.size.x * 0.75
	var clip: PackedVector2Array = _points([pane.position, Vector2(pane.end.x, pane.position.y), pane.end,
			Vector2(pane.position.x, pane.end.y)])
	for streak: int in 2:
		var left: float = start + streak * (GLINT_PX.x + GLINT_GAP_PX)
		var width: float = GLINT_PX[streak]
		var band: PackedVector2Array = _points([Vector2(left, pane.position.y), Vector2(left + width, pane.position.y),
				Vector2(left + width - pane.size.y, pane.end.y), Vector2(left - pane.size.y, pane.end.y)])
		for piece: PackedVector2Array in Geometry2D.intersect_polygons(band, clip):
			_building_glint.add_polygon(piece, Color.WHITE)


## A lit window's glow on the snow in front of the facade, weaker from the upper storeys.
func _add_glow(window: Rect2, glow: Color) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var radial: Texture2D = LightTextures.get_shape(LightTextures.Shape.RADIAL)
	var light: PointLight2D = PointLight2D.new()
	light.texture = radial
	light.texture_scale = 2.0 * config.px(WINDOW_GLOW_M) / radial.get_width()
	light.scale = Vector2(1.0, config.depth_factor)
	light.position = ground(_building_spec.x + window.get_center().x, _building_front + WINDOW_GLOW_M * 0.6) \
			- Vector2(0.0, config.px(_building_lift))
	light.color = glow
	light.height = Lit.AMBIENT_HEIGHT # a pool on the snow, no N·L (lit.gdshader)
	light.range_item_cull_mask = LightMasks.of(0, LightMasks.Receiver.FLOOR)
	world.add_child(light)
	_glows.append(light)
	_glow_ks.append(1.0 if window.position.y < _storey_m else UPPER_GLOW_K)


func _apply_sun(night: float) -> void:
	var sun: SunSample = director.sun
	var exposure: float = _street_room.exposure
	var mode: int = _value(&"slonce_fasady")
	var facing: float = smoothstep(0.0, 0.25, cos(deg_to_rad(sun.sun_azimuth_deg)))
	var seen: float = clampf(sun.sun_lux / SUN_SEEN_LUX, 0.0, 1.0)
	_sun_light.color = sun.sun_color
	_sun_light.energy = Exposure.energy(sun.sun_lux, exposure, 1.0, sun.sun_knee) * facing * FACADE_SUN_K
	_sun_light.enabled = mode > 0 and _sun_light.energy > WindowLight.MIN_LIGHT_ENERGY
	# Glass: the sky in it by day, the sun's glint while the sun stands in front of the facade.
	var glass: int = _value(&"szyby_dzien")
	var day: float = 1.0 - night
	var sky: Color = sun.sky_color * (GLASS_SKY_K * day if glass > 0 else 0.0)
	for painter: ShapePainter in _glass_painters:
		painter.modulate = Color(sky.r, sky.g, sky.b, 1.0)
	var glint: Color = sun.sun_color * (GLINT_K * facing * seen if glass == 2 else 0.0)
	for painter: ShapePainter in _glint_painters:
		painter.modulate = Color(glint.r, glint.g, glint.b, 1.0)
	# Warm snow edges while the sun is up; lamps in some windows by day.
	var rim: Color = sun.sun_color * ((RIM_K + RIM_GOLD_K * sun.gold) * seen if _value(&"krawedz") == 0 else 0.0)
	for painter: ShapePainter in _rim_painters:
		painter.modulate = Color(rim.r, rim.g, rim.b, 1.0)
	var day_lamps: float = DAY_LAMP_K * day if _value(&"lampy_dzien") == 0 and _value(&"okna") == 0 else 0.0
	for painter: ShapePainter in _day_lamp_painters:
		painter.modulate = Color(1.0, 1.0, 1.0, day_lamps)
	# Lit windows on the snow by night.
	var glows: bool = _value(&"poswiata") == 0 and _value(&"okna") == 0
	var radial_peak: float = LightTextures.peak(LightTextures.Shape.RADIAL)
	for index: int in _glows.size():
		var light: PointLight2D = _glows[index]
		light.energy = Exposure.energy(WINDOW_GLOW_LUX * _glow_ks[index] * night, exposure, radial_peak)
		light.enabled = glows and light.energy > WindowLight.MIN_LIGHT_ENERGY


## Ticket 14: a building as the map's box (its footprint as drawn: depth already scaled), with its roof.
func _add_building_box(spec: Vector4, depth: float, front: float, lift_m: float, height: float, roof: int) -> void:
	var rise: float = 0.0
	var kind: int = 0
	match roof:
		1:
			kind = 1
			rise = _pitch * depth / 2.0
		2:
			kind = 2
			rise = _pitch * spec.y / 2.0
	_street_map.add_box(AABB(Vector3(spec.x, front - depth, lift_m), Vector3(spec.y, depth, height + rise)), true, true,
			Vector2(kind, rise))


## Ticket 14: a drawn prop (tree, car) as the map's box standing behind its foot.
func _occluder(foot: Vector2, size_m: Vector3) -> void:
	var at: Vector2 = StreetMap.ground_m(foot)
	_street_map.add_box(AABB(Vector3(at.x - size_m.x / 2.0, at.y - size_m.y, 0.0), size_m), true, false)


## Ticket 14: the street's light (F1, live): the map or the old flat light, the buildings' shadows, the
## look shared with the house (the same ids: one choice for both), debug views and the critic's knobs.
const SHOWN_OPTIONS: Array[StringName] = [&"kadr", &"swiatlo_ulicy", &"cienie_budynkow", &"niebo_ulica", &"wyglad",
		&"swiatlo_res", &"widok_debug_ulica"]
const SKY_OCCLUDERS: PackedStringArray = ["tylko architektura", "architektura i obiekty (postac, zaspy...)"]
const STREET_LIGHTS: PackedStringArray = ["mapa (jak w domu)", "stare (plaskie, t27)"]
const STREET_DEBUG: PackedStringArray = ["swiatlo", "tylko slonce", "tylko niebo", "tylko okna", "tylko latarnie",
		"udzial cienia (R slonce, G niebo, B okna)"]
const STREET_TESTS: PackedStringArray = ["brak", "postac jako pudelko", "pudelko w miejscu postaci (postac bez cienia)"]
const STREET_K_STEPS: PackedFloat32Array = [0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0]
const SKY_SHARE_STEPS: PackedFloat32Array = [0.0, 0.25, 0.5, 0.6, 0.7, 0.75, 0.8, 0.9, 1.0]


func _add_street_light_options() -> void:
	DebugRegistry.add_variant(self, &"swiatlo_ulicy", "Światło ulicy", STREET_LIGHTS, 0, func(index: int) -> void:
		StreetMap.enabled = index == 0
		_refresh_light())
	DebugRegistry.add_variant(self, &"cienie_budynkow", "Cienie budynków od słońca", ON_OFF, 0, func(index: int) -> void:
		StreetMap.building_shadows = index == 0
		_refresh_light())
	DebugRegistry.add_variant(self, &"niebo_ulica", "Cień nieba zasłania", SKY_OCCLUDERS, 0, func(index: int) -> void:
		StreetMap.sky_objects = index == 1
		_refresh_light())
	DebugRegistry.add_variant(self, &"wyglad", "Cienie i światło: wygląd", DomBryly.LOOKS, 1, func(index: int) -> void:
		SunMap.look = index
		_refresh_light())
	DebugRegistry.add_variant(self, &"swiatlo_res", "Światło i cienie: rozdzielczość", DomBryly.LIGHT_RES, 1, func(index: int) -> void:
		SunMap.light_res = index + 1
		get_tree().call_group(&"lit_view", &"set", &"render_scale", index + 1)
		_refresh_light())
	DebugRegistry.add_variant(self, &"widok_debug_ulica", "Widok debug (bufor ulicy)", STREET_DEBUG, 0, func(index: int) -> void:
		StreetMap.debug_view = index
		_refresh_light())
	DebugRegistry.add_variant(self, &"test_ulica", "Test cieni (ulica)", STREET_TESTS, 0, func(index: int) -> void:
		StreetMap.test = index
		_refresh_light())
	DebugRegistry.add_variant(self, &"liczenie", "Liczenie (koszt)", DomBryly.COMPUTES, 0, func(index: int) -> void:
		SunMap.whole_every_frame = index == 1
		_refresh_light())
	_k_slider(&"ulica_slonce", "Ulica: słońce", STREET_K_STEPS, 0.5, func(k: float) -> void: StreetMap.sun_k = k)
	_k_slider(&"ulica_niebo", "Ulica: udział nieba w mapie (reszta płaska)", SKY_SHARE_STEPS, 0.75, func(k: float) -> void: StreetMap.sky_share = k)
	_k_slider(&"ulica_okna", "Ulica: światło zapalonych okien", STREET_K_STEPS, 1.0, func(k: float) -> void: StreetMap.window_k = k)
	_k_slider(&"ulica_latarnie", "Ulica: latarnie", STREET_K_STEPS, 1.0, func(k: float) -> void: StreetMap.lamp_k = k)


func _k_slider(id: StringName, label: String, steps: PackedFloat32Array, start: float, set_k: Callable) -> void:
	var names: PackedStringArray = PackedStringArray()
	for k: float in steps:
		names.append("x%s" % String.num(k, 2).replace(".", ","))
	DebugRegistry.add_slider(self, id, label, names, DomBryly._nearest(steps, start), func(index: int) -> void:
		set_k.call(steps[index])
		_refresh_light())


func _refresh_light() -> void:
	if director != null and director.sun != null:
		_force_light = true
		apply_time(director.sun.hour)


## The map's sources for this hour; the old flat lights step aside while it lights the street.
func _apply_street_light() -> void:
	if _street_map == null or _street_map.room == null or director.sun == null:
		return
	var on: bool = StreetMap.enabled
	Figure.blob = Figure.Blob.NONE if on else Figure.Blob.FIXED
	_street_map.window_night_k = 0.0 if _value(&"okna") == 1 else 1.0
	_street_map.window_day_k = DAY_LAMP_K if _value(&"lampy_dzien") == 0 and _value(&"okna") == 0 else 0.0
	_street_map.apply(director.sun, _force_light)
	_force_light = false
	if on:
		_sun_light.enabled = false
		for light: PointLight2D in _glows:
			light.enabled = false


func _exit_tree() -> void:
	DebugRegistry.hidden = []
	DebugRegistry.minimal = false
	LightFixture.map_lamps = false
	LightFixture.map_actor = false
	Figure.blob = Figure.Blob.FIXED
