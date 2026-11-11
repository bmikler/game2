class_name DomBryly
extends RzutPoligon
## PROTOTYPE (ticket Poligon Dom w bryłach): the inside of the two-storey house from ulica_bryly, drawn
## in code, to decide how an interior matches its facade. One script, two scenes: dom_parter (living
## room, hall with the stairs and the street door, kitchen behind a dining room) and dom_pietro
## (bedroom, upstairs hall over the stairwell, room). The facade's three window columns are the three
## columns of rooms, in the same order; the room behind each facade window lights it at night with its
## lamp (DomBryly.lamps, read by ulica_bryly).
## Settled (the human, 2026-11-09): no outer frames, the house hangs in black and its bottom and sides
## fade into it; windows in the bottom and side walls are not drawn, only their light (research 47,
## pattern A: sky pillow and the sun's band, parallel to every other beam); north at the top of the
## screen by default (F1 tries the other three), so the sun comes through the bottom and side windows; the street door is a floor tongue
## with a threshold, a mat and cold light from outside (43 §3); a room behind another is reached
## through a door in the partition, which cuts down while the player is behind it (ticket Rzut).
## Variants (F1): the top of the screen (compass), the edge into black, the lamps.
## Ground: x across from the left room's inner edge, z from the back wall (metres).

const ROOM_PROFILE: RoomLightingProfile = preload("res://lighting/data/evening_lamps.tres")
const WINDOW_PROFILE: WindowLightProfile = preload("res://lighting/data/window_light.tres")
const FLOOR_LAMP: FixtureDef = preload("res://lighting/data/floor_lamp.tres")
const CEILING_BULB: FixtureDef = preload("res://lighting/data/cell_bulb.tres")
const PARTER_SCENE: String = "res://poligony/dom_parter.tscn"
const PIETRO_SCENE: String = "res://poligony/dom_pietro.tscn"
const STREET_SCENE: String = "res://poligony/ulica_bryly.tscn"

## The house on ulica_bryly (HOUSE there): 10 m wide, 8 m deep, three window columns.
const FACADE_WIDTH_M: float = 10.0
const FACADE_DEPTH_M: float = 8.0
const FACADE_DEPTH_SHOWN: float = 0.5 ## Outside, buildings show half their depth.
const COLUMNS: int = 3
const WALL_M: float = 2.2
const STOREY_M: float = 2.9 ## 1.6 × the actor, floor to floor.
## How much bigger the inside is than the facade is chosen per building when the game's buildings and
## town map are made (the human, 2026-11-09), not here; the Poligon uses one working size.
const INSIDE_SCALE: float = 1.5
const DEPTH_M: float = 8.0
const ON_OFF: PackedStringArray = ["wl", "wyl"]
## What is at the top of the screen; the sun and every window beam follow (LightingDirector).
const TOPS: PackedStringArray = ["polnoc", "poludnie (game1)"] ## East and west dropped (the human).
const TOP_AZIMUTHS: PackedFloat32Array = [0.0, 180.0]
## Lamp names: ground floor left, hall, kitchen (back), dining room (front); upstairs left, hall, right.
const GROUND_ROOMS: PackedStringArray = ["salon", "korytarz", "kuchnia", "jadalnia"]
const UPPER_ROOMS: PackedStringArray = ["sypialnia", "korytarz_g", "pokoj"]

const WINDOW_W: float = 1.2 ## As on the facade.
const BACK_WINDOW_W: float = 1.4
const DOOR_W: float = 1.1
const INNER_DOOR_W: float = 1.0
const DOOR_MAX_M: float = 2.0 ## Door in a partition: min(2.0 m, wall − 0.35 m).
const DOOR_BELOW_CEILING_M: float = 0.35
const SIDE_DOOR_FROM_FRONT: float = 1.6 ## The stairs keep their old room (_run).
const SIDE_DOOR_FRONT_GAP: float = 0.6 ## A side door ends this far from the front wall.
const DOOR_LEAF_M: float = 0.9 ## Leaf of a side door, open flat against the wall behind the doorway.
const KITCHEN_SHARE: float = 0.45 ## Of the depth, behind the partition.
const PARTITION_M: float = 0.1
const PARTITION_CUT_M: float = 1.0
const CUT_SECONDS: float = 0.2
const STEPS: int = 14
const RUN_M: float = 0.27
const FLIGHT_W: float = 1.0 ## Along the hall's left wall, rising towards the back.
const FLIGHT_FROM_M: float = 0.15
## How the house ends at its bottom and outer sides (research 78): the old smooth gradient; A a slab
## in section (its front under the floor, a wall post at the sides, ragged edges); B the room dies
## out in an ordered dither; A+B; C the dither with a ragged, noisy edge ending in a cold dark blue.
const EDGES: PackedStringArray = ["gradient (byl)", "A plyta", "B gasnie", "A+B", "C mgla"]
const FADE_PX: int = 28 ## Gradient: the bottom and the sides fade into black over this much.
const FADE_STEPS: int = 14
const SLAB_PX: int = 7 ## A: the slab's front under the floor.
const POST_PX: int = 6 ## A: the wall post at an outer side.
const SLAB: Color = Color("0d0a09")
const SLAB_EDGE: Color = Color("2a211b")
const DITHER_BOTTOM_PX: int = 32 ## B, C (bottom; sides take SIDE).
const DITHER_SIDE_PX: int = 40
const DITHER_AB_PX: int = 16 ## A+B: only the last stretch inside the slab.
const MIST_BOTTOM_PX: int = 40
const MIST_SIDE_PX: int = 48
const MIST_AMPLITUDE_PX: float = 8.0
const MIST_WAVE_PX: float = 48.0
const MIST: Color = Color("03040a")
const BAYER: PackedInt32Array = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]
const TONGUE_M: Vector2 = Vector2(1.3, 0.7)
## Unseen windows: the window-shaped patch on the floor (times the sun's energy).
const PATCH_K: float = 1.0
## Window size (the human, 2026-11-09): bigger windows, less real, a better mood of light; every wall.
const WINDOW_SIZES: PackedStringArray = ["obecne", "srednie", "wieksze"]
## Per size (index 1, 2; 0: the old windows): back window width, sill above the floor, head below the ceiling.
const SIZE_BACK_W: PackedFloat32Array = [1.4, 1.7, 2.0]
const SIZE_SILL_M: PackedFloat32Array = [0.73, 0.55, 0.45]
const SIZE_HEAD_M: PackedFloat32Array = [0.25, 0.2, 0.15]
## Bigger windows look bigger but let in the old windows' daylight (glass area).
const SIZE_FLUX_K: PackedFloat32Array = [1.0, 0.7, 0.55]
## Ticket 31: the placeholder view (snow 242, sky 226 of 255) × view_max 1.6 burns out and blooms; game1's
## painted view has mean 123 (peak ~207) at the same view_k 1.6 (measured): × 0.55 matches its mean.
const VIEW_LEVELS: PackedStringArray = ["placeholder", "x0,7", "srednia jak game1 (x0,55)"]
const VIEW_LEVEL_K: PackedFloat32Array = [1.0, 0.7, 0.55]
## Window division, every wall (columns × rows; 2 rows: a transom, the window cross).
const DIVISIONS: PackedStringArray = ["2 skrzydla", "krzyz 2x2", "6 szybek 3x2"]
const DIVISION_COLS: PackedInt32Array = [2, 2, 3]
const DIVISION_ROWS: PackedInt32Array = [1, 2, 2]
## Ticket 31: the doorways between columns, a hole in the black wall top the player can read: the old gap
## (floor in the wall, threshold lines, one room's light) or the hole (floor without lines, lit by both rooms).
const SIDE_GAPS: PackedStringArray = ["jak dotad", "dziura (podloga obu pokoi)"]
const VIEW_ENVIRONMENT: Environment = preload("res://lighting/data/view_environment.tres")
const DOOR_SASH_W: float = 0.9 ## The street door as an opening in the bottom wall (its light from the buffer).
const DOOR_SASH_H: float = 1.9

const WALL_COLOR: Color = Color("8c8a80")
const WALL_TOP: Color = Color("2b2a2e")
const MOULDING: Color = Color("a9a69c")
const THRESHOLD: Color = Color("2a2522")
const FLOOR_LIVING: Color = Color("6b5d4f")
const FLOOR_HALL: Color = Color("756b60")
const FLOOR_KITCHEN: Color = Color("7a7266")
const FLOOR_DINING: Color = Color("6e6155")
const FLOOR_UPPER: PackedColorArray = [Color("6e5f52"), Color("756b60"), Color("675a4e")]
const DOOR_LEAF: Color = Color("4a3a2e")
const STAIR_FRONT: Color = Color("4d3f34")
const STAIR_TOP: Color = Color("7a6450")
const HOLE: Color = Color("141317")
const MAT: Color = Color("4a3a30")
const SNOW: Color = Color("e8ecf2")
## Back-window views (placeholder), 6 colours per time of day (day, dusk, night): sky top, sky low,
## snow, dark (fence, tree), wall, lit window.
const VIEW_PALETTE_SIZE: int = 6
const VIEW_PALETTES: PackedColorArray = [
	Color(0.66, 0.74, 0.86), Color(0.86, 0.89, 0.94), Color(0.93, 0.95, 0.97), Color(0.26, 0.27, 0.3), Color(0.55, 0.5, 0.46), Color(0.3, 0.33, 0.38),
	Color(0.62, 0.55, 0.62), Color(0.96, 0.78, 0.62), Color(0.95, 0.86, 0.8), Color(0.24, 0.2, 0.22), Color(0.6, 0.47, 0.42), Color(0.98, 0.78, 0.5),
	Color(0.03, 0.05, 0.14), Color(0.1, 0.13, 0.26), Color(0.3, 0.34, 0.47), Color(0.04, 0.05, 0.09), Color(0.12, 0.12, 0.17), Color(1.0, 0.76, 0.45),
]
const VIEW_SIZE: Vector2i = Vector2i(112, 160) ## The back window is 56 px wide (80 px when big).
const VIEW_HORIZON: int = 38

## Which floor this scene is: 0 ground floor, 1 upstairs.
@export_range(0, 1) var floor_index: int = 0

## Lamps of all the rooms (on unless switched off in F1); ulica_bryly lights the facade windows by it.
static var lamps: Dictionary[StringName, bool] = {}

var _room_w: float = 5.0
var _depth: float = 8.0
var _run: float = RUN_M
var _views: Array[Texture2D] = []
var _partition_blocks: Array[Block] = []
var _lintel: Block
var _door_h: float = 1.85
var _shown_m: float = WALL_M
var _back_room: RoomLighting
var _edge: int = 1
var _sun_map: SunMap
## The street door's spill light: off with the map, whose door glazing glows as the bottom windows do.
var _door_x_m: float = NAN ## The street door's middle, house metres.
var _stairs: Array[Block] = [] ## Steps: occluders only on the map (their faces cut a beam into stripes).
var _window_size: int = 1
var _cols: int = 2
var _rows: int = 2
var _window_profile: WindowLightProfile = WINDOW_PROFILE


static func lamp_on(room: StringName) -> bool:
	return lamps[room] if lamps.has(room) else true


func _character_options() -> bool:
	return false


func _add_layout_options() -> void:
	_layout_option(&"gora_mapy", "Góra ekranu", TOPS, 1) # ticket 31: the human leans to south on top
	_layout_option(&"brzeg", "Brzeg w czerń", EDGES, 1)
	for room: String in _room_names():
		_layout_option(StringName("lampa_" + room), "Lampa: " + room, ON_OFF, 0)
	_layout_option(&"okna", "Okna (wszystkie ściany)", WINDOW_SIZES, 1) # the human: big ones a little too big
	_layout_option(&"podzial", "Podział okien", DIVISIONS, 1)
	_layout_option(&"przejscia", "Przejścia boczne", SIDE_GAPS, 1)
	_layout_option(&"widok", "Widok za oknem: jasność", VIEW_LEVELS, 2)
	_add_sun_map_options()


## Ticket 36 (the human: the old variants out of F1): the panel shows the light's look and the quality
## checks; every other option keeps its value, hidden. The interior frame (resolution) stays.
const SHOWN_OPTIONS: Array[StringName] = [&"kadr_wn", &"cien_wyglad", &"slonce_tarcza", &"zarowka",
		&"widok_debug", &"smugi_gorne", &"test_cienia"]
const ACTOR_STEPS: PackedFloat32Array = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0]
const FILL_STEPS: PackedFloat32Array = [0.0, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0]
const NIGHT_WINDOW_STEPS: PackedFloat32Array = [0.0, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0, 8.0]
const LAMP_STEPS: PackedFloat32Array = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0]
## Sliders for how dark the game is (the human: lights should tell more, by night above all).
const AMBIENT_STEPS: PackedFloat32Array = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.25, 1.5]
const EXPOSURE_STEPS: PackedFloat32Array = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.25, 1.5]
## Ticket 36: the light buffer's variants and checks.
const LOOKS: PackedStringArray = ["gladki", "3 poziomy z ditherem", "2 poziomy twarde"]
static var SUN_DISC_STEPS: PackedFloat32Array = _steps(0.2, 4.0, 0.2)
static var BULB_STEPS: PackedFloat32Array = _steps(0.02, 0.4, 0.02)
const DEBUG_VIEWS: PackedStringArray = ["swiatlo", "tylko slonce (i wstegi)", "tylko niebo", "tylko noc", "tylko lampy",
		"udzial cienia (R slonce, G niebo, B noc)"]
const TOP_BEAM_MODES: PackedStringArray = ["wielokat z cieniem (jak t27)", "wolumetryczne"]
const TESTS: PackedStringArray = ["brak", "postac jako pudelko", "pudelko w miejscu postaci (postac bez cienia)",
		"pudelko przed drzwiami", "pudelko przed oknem"]
const COMPUTES: PackedStringArray = ["okno wokol postaci", "caly dom co klatke"]


## Ticket 36: the light buffer's options, live (each re-applies the light). The light's levels are the
## critic's C (ticket 31), on hidden sliders (--set= still sets them).
func _add_sun_map_options() -> void:
	DebugRegistry.add_variant(self, &"cien_wyglad", "Cienie: wygląd", LOOKS, 1, func(index: int) -> void:
		SunMap.shadow_look = index
		_refresh_sun())
	var discs: PackedStringArray = PackedStringArray()
	for degrees: float in SUN_DISC_STEPS:
		discs.append("%s st." % String.num(degrees, 1).replace(".", ","))
	DebugRegistry.add_slider(self, &"slonce_tarcza", "Tarcza słońca (promień): miękkość cieni okien", discs,
			_nearest(SUN_DISC_STEPS, 2.4), func(index: int) -> void:
		SunMap.sun_disc_deg = SUN_DISC_STEPS[index]
		_refresh_sun())
	var bulbs: PackedStringArray = PackedStringArray()
	for metres: float in BULB_STEPS:
		bulbs.append("%s m" % String.num(metres, 2).replace(".", ","))
	DebugRegistry.add_slider(self, &"zarowka", "Żarówka (średnica): miękkość cieni lamp", bulbs,
			_nearest(BULB_STEPS, 0.1), func(index: int) -> void:
		SunMap.bulb_m = BULB_STEPS[index]
		_refresh_sun())
	DebugRegistry.add_variant(self, &"widok_debug", "Widok debug (bufor)", DEBUG_VIEWS, 0, func(index: int) -> void:
		SunMap.debug_view = index
		_refresh_sun())
	DebugRegistry.add_variant(self, &"smugi_gorne", "Smugi okien górnych", TOP_BEAM_MODES, 0, func(index: int) -> void:
		SunMap.top_beams = index as SunMap.TopBeams
		_refresh_sun())
	DebugRegistry.add_variant(self, &"test_cienia", "Test cieni", TESTS, 0, func(index: int) -> void:
		SunMap.test = index as SunMap.Test
		_refresh_sun())
	DebugRegistry.add_variant(self, &"liczenie", "Liczenie (koszt)", COMPUTES, 0, func(index: int) -> void:
		SunMap.whole_every_frame = index == 1
		_refresh_sun())
	_darkness_slider(&"lampy_jasnosc", "Lampy z mapy: jasność", LAMP_STEPS, func(k: float) -> void: SunMap.room_lamp_k = k, 2.0)
	_darkness_slider(&"postac_jasnosc", "Postać: światło na ciele", ACTOR_STEPS, func(k: float) -> void: SunMap.actor_k = k, 1.0)
	_darkness_slider(&"lampy_rozlewanie", "Lampy: rozlewanie na pokój (poza plamą)", FILL_STEPS, func(k: float) -> void: RoomLighting.art_fill_k = k, 1.5)
	_darkness_slider(&"noc_okna", "Noc: zimne światło z okien (śnieg, latarnie)", NIGHT_WINDOW_STEPS, func(k: float) -> void: SunMap.night_window_k = k, 2.0)
	_darkness_slider(&"ambient_dzien", "Ambient pokoju w dzień", AMBIENT_STEPS, func(k: float) -> void: RoomLighting.day_ambient_k = k, 0.7)
	_darkness_slider(&"ambient_noc", "Ambient pokoju w nocy", AMBIENT_STEPS, func(k: float) -> void: RoomLighting.night_ambient_k = k, 0.4)
	_darkness_slider(&"ekspozycja_dzien", "Ekspozycja w dzień (całość)", EXPOSURE_STEPS, func(k: float) -> void: RoomLighting.day_exposure_k = k, 0.7)
	_darkness_slider(&"ekspozycja_noc", "Ekspozycja w nocy (całość)", EXPOSURE_STEPS, func(k: float) -> void: RoomLighting.night_exposure_k = k, 0.7)


## A slider over `steps` (× values, starting at ×1); `set_k` stores the chosen one.
func _darkness_slider(id: StringName, label: String, steps: PackedFloat32Array, set_k: Callable,
		start: float = 1.0) -> void:
	var names: PackedStringArray = PackedStringArray()
	for k: float in steps:
		names.append("x%s" % String.num(k, 2).replace(".", ","))
	var first: int = 0
	for index: int in steps.size():
		if absf(steps[index] - start) < absf(steps[first] - start):
			first = index
	DebugRegistry.add_slider(self, id, label, names, first, func(index: int) -> void:
		set_k.call(steps[index])
		_refresh_sun())


## The index of the value in `steps` nearest to `value`.
static func _nearest(steps: PackedFloat32Array, value: float) -> int:
	var best: int = 0
	for index: int in steps.size():
		if absf(steps[index] - value) < absf(steps[best] - value):
			best = index
	return best


## from, from + step, … up to `to`.
static func _steps(from: float, to: float, step: float) -> PackedFloat32Array:
	var values: PackedFloat32Array = PackedFloat32Array()
	for index: int in roundi((to - from) / step) + 1:
		values.append(snappedf(from + index * step, step))
	return values


func _refresh_sun() -> void:
	if director != null and director.sun != null:
		director.apply_time(director.sun.hour)
		if _sun_map != null:
			_sun_map.apply(director.sun)


func start(spawn: StringName) -> void:
	super.start(spawn)
	var hidden: Array[StringName] = []
	for option: DebugOption in DebugRegistry.options():
		if not SHOWN_OPTIONS.has(option.id):
			hidden.append(option.id)
	DebugRegistry.hidden = hidden
	DebugRegistry.minimal = true
	DebugRegistry.options_changed.emit()
	_readout.visible = false
	_build_sun_map()


func _exit_tree() -> void:
	DebugRegistry.hidden = []
	SunMap.enabled = false # ticket 36: the street keeps its own light
	RoomLighting.day_exposure_k = 1.0
	RoomLighting.night_exposure_k = 1.0
	RoomLighting.day_ambient_k = 1.0
	RoomLighting.night_ambient_k = 1.0
	LightFixture.map_lamps = false
	LightFixture.map_actor = false
	RoomLighting.art_fill_k = 1.0
	Figure.blob = Figure.Blob.FIXED # ticket 33: the street keeps its spot
	DebugRegistry.minimal = false


func apply_time(hour: float) -> void:
	super.apply_time(hour)
	if _sun_map != null:
		_sun_map.apply(director.sun)


## Ticket 36: the house's SunGeometry from what was built (windows of every wall, every block) plus
## the wall tops between the columns, and the SunMap over it.
func _build_sun_map() -> void:
	var data: SunGeometry = SunGeometry.new()
	data.floor_y = ProjectionConfig.current().px(WALL_M)
	data.fit_shell(rooms, WALL_M)
	for room: RoomLighting in rooms:
		_add_sun_windows(data, room)
	for child: Node in world.get_children():
		if child is Block:
			data.add_block(child as Block, not _stairs.has(child as Block))
	var door_from: float = _side_door_from()
	var door_to: float = door_from + _side_door_m()
	for column: int in range(1, COLUMNS):
		var right: float = column * (_room_w + RoomBox.WALL_TOP_M)
		var left: float = right - RoomBox.WALL_TOP_M
		# Drawn as a thin wall top only: they cast, but are no surface (a pixel in the doorway took the
		# light of the partition top in front, 2.2 m up: the hole was dark, the human).
		data.add_box(AABB(Vector3(left, 0.0, 0.0), Vector3(RoomBox.WALL_TOP_M, door_from, WALL_M)), null, false)
		data.add_box(AABB(Vector3(left, door_to, 0.0), Vector3(RoomBox.WALL_TOP_M, _depth - door_to, WALL_M)), null, false)
		# The lintel over the doorway: the gap is drawn as floor, so it only casts.
		data.add_box(AABB(Vector3(left, door_from, _door_h), Vector3(RoomBox.WALL_TOP_M, _side_door_m(), WALL_M - _door_h)),
				null, false)
	var door_sash: int = -1
	if not is_nan(_door_x_m):
		data.add_sash(SunGeometry.Wall.FRONT, _door_x_m - DOOR_SASH_W / 2.0, _door_x_m + DOOR_SASH_W / 2.0, 0.0, DOOR_SASH_H)
		door_sash = data.sashes.size() - 1
	_sun_map = SunMap.new()
	_sun_map.door_sash = door_sash
	world.add_child(_sun_map)
	_sun_map.setup(data, rooms, player, _window_profile)
	if director.sun != null:
		_sun_map.apply(director.sun)


func _add_sun_windows(data: SunGeometry, node: Node) -> void:
	for child: Node in node.get_children():
		if child is WindowLight:
			data.add_window_light(child as WindowLight)
		elif child is SideWindowLight:
			data.add_side_window(child as SideWindowLight, _rows)
		else:
			_add_sun_windows(data, child)


## A door in a side wall (lies along the depth, shortened ×depth_factor on screen): as long as the
## bottom door is wide on screen (the human: scaled as the side windows).
func _side_door_m() -> float:
	return INNER_DOOR_W / ProjectionConfig.current().depth_factor


func _side_door_from() -> float:
	return _depth - SIDE_DOOR_FRONT_GAP - _side_door_m()


func _side_w() -> float:
	return SIZE_BACK_W[_window_size] - 2.0 * RoomBox.FRAME_PX / ProjectionConfig.current().px_per_m if _window_size > 0 else WINDOW_W


func _room_names() -> PackedStringArray:
	return GROUND_ROOMS if floor_index == 0 else UPPER_ROOMS


func _build_world() -> void:
	_ground_wall_m = WALL_M
	street_scene = STREET_SCENE # the house stands on that street
	LightingDirector.top_azimuth_deg = TOP_AZIMUTHS[_value(&"gora_mapy")]
	# Ticket 36: all the light inside from the buffer (SunMap); the hand-made shapes stay off.
	SunMap.enabled = true
	LightFixture.map_lamps = true # before the rooms first apply: their hand-made pools never show
	LightFixture.map_actor = true
	SideWindowLight.beams = 0
	SideWindowLight.day_patch = false
	WindowLight.day_patch = false
	SideWindowLight.night_patch = 0
	WindowLight.night_patch = 0
	Figure.blob = Figure.Blob.NONE
	var environment: Environment = VIEW_ENVIRONMENT
	environment.glow_enabled = false # the glass bloomed onto the wall (the human, ticket 31)
	_door_h = minf(DOOR_MAX_M, WALL_M - DOOR_BELOW_CEILING_M)
	_window_size = _value(&"okna")
	_cols = DIVISION_COLS[_value(&"podzial")]
	_rows = DIVISION_ROWS[_value(&"podzial")]
	_window_profile = WINDOW_PROFILE
	if _window_size > 0:
		_window_profile = WINDOW_PROFILE.duplicate() as WindowLightProfile
		# Unseen windows' glass the same as the back window's (inside its frame): the same cross everywhere.
		var frame_m: float = RoomBox.FRAME_PX / ProjectionConfig.current().px_per_m
		_window_profile.top_sill_m = SIZE_SILL_M[_window_size] + frame_m
		_window_profile.sky_flux_coef *= SIZE_FLUX_K[_window_size]
		_window_profile.sun_flux_coef *= SIZE_FLUX_K[_window_size]
		_window_profile.top_head_m = SIZE_HEAD_M[_window_size] + frame_m
	_edge = _value(&"brzeg")
	_room_w = FACADE_WIDTH_M / COLUMNS * INSIDE_SCALE
	_depth = DEPTH_M
	_run = minf(RUN_M, (_depth - SIDE_DOOR_FROM_FRONT - 0.9) / STEPS)
	for room: String in _room_names():
		lamps[StringName(room)] = _value(StringName("lampa_" + room)) == 0
	_views.clear()
	for time: int in 3:
		_views.append(_view_texture(0, time, VIEW_LEVEL_K[_value(&"widok")]))
	if floor_index == 0:
		_build_ground_floor()
	else:
		_build_upper_floor()


func _build_ground_floor() -> void:
	# Living room: back window, a window in the bottom wall and one in the left (west) wall.
	var living: RoomLighting = _column_room(0, 0, FLOOR_LIVING, &"salon", true)
	_bottom_window(living)
	_side_window(living, true, _depth / 2.0)
	_fade_bottom(living, 0, -1.0)
	_fade_side(living, 0, true)
	world.add_child(living)
	var origin: Vector2 = _column_origin(0)
	_block(world, origin + ground(_room_w / 2.0, _depth * 0.6, WALL_M), Vector3(minf(2.0, _room_w - 1.0), 0.9, 0.85),
			Color(0.3, 0.33, 0.36), Color(0.38, 0.41, 0.44), [], true, 0.0, 0)
	_block(world, origin + ground(_room_w / 2.0, _depth * 0.35, WALL_M), Vector3(1.0, 0.6, 0.45),
			Color(0.42, 0.31, 0.22), Color(0.55, 0.42, 0.3), [], true, 0.0, 0)

	# Hall: the stairs along the back wall, the street door in the bottom wall, a door right to the dining room.
	var hall: RoomLighting = _column_room(1, 1, FLOOR_HALL, &"korytarz", true)
	origin = _column_origin(1)
	_fade_bottom(hall, 1, _room_w / 2.0)
	_flight(origin)
	_street_door(hall, origin)
	if lamp_on(&"korytarz"):
		hall.add_child(_light(ground(_room_w / 2.0, _depth / 2.0, WALL_M), CEILING_BULB))
	world.add_child(hall)

	# Kitchen behind the dining room: a partition with a door between them.
	_kitchen_and_dining()


func _build_upper_floor() -> void:
	var bedroom: RoomLighting = _column_room(0, 0, FLOOR_UPPER[0], &"sypialnia", true)
	_bottom_window(bedroom)
	_side_window(bedroom, true, _depth / 2.0)
	_fade_bottom(bedroom, 0, -1.0)
	_fade_side(bedroom, 0, true)
	world.add_child(bedroom)
	var origin: Vector2 = _column_origin(0)
	_block(world, origin + ground(_room_w / 2.0, 2.3, WALL_M), Vector3(1.6, 2.0, 0.55),
			Color(0.36, 0.27, 0.2), Color(0.62, 0.6, 0.64), [], true, 0.0, 0)
	_block(world, origin + ground(0.9, _depth * 0.75, WALL_M), Vector3(0.6, 0.6, 2.0),
			Color(0.35, 0.3, 0.33), Color(0.45, 0.4, 0.43), [], true, 0.0, 0)

	var hall: RoomLighting = _column_room(1, 1, FLOOR_UPPER[1], &"korytarz_g", true)
	_bottom_window(hall)
	_fade_bottom(hall, 1, -1.0)
	_stairwell(_column_origin(1))
	if lamp_on(&"korytarz_g"):
		hall.add_child(_light(ground(_room_w / 2.0, _depth / 2.0, WALL_M), CEILING_BULB))
	world.add_child(hall)

	var room: RoomLighting = _column_room(2, 2, FLOOR_UPPER[2], &"pokoj", true)
	_bottom_window(room)
	_side_window(room, false, _depth / 2.0)
	_fade_bottom(room, 2, -1.0)
	_fade_side(room, 2, false)
	world.add_child(room)
	origin = _column_origin(2)
	_block(world, origin + ground(_room_w / 2.0, 0.6, WALL_M), Vector3(1.4, 0.6, 0.75),
			Color(0.42, 0.31, 0.22), Color(0.55, 0.42, 0.3), [], true, 0.0, 2)
	_block(world, origin + ground(_room_w - 0.6, _depth * 0.45, WALL_M), Vector3(0.4, 1.0, 1.9),
			Color(0.36, 0.27, 0.2), Color(0.45, 0.34, 0.25), [], true, 0.0, 2)


func _readout_extra() -> String:
	var inside: float = COLUMNS * _room_w + (COLUMNS - 1) * RoomBox.WALL_TOP_M
	return "\nwnętrze %.1f × %.1f m · fasada %.0f m szer., z zewnątrz %.1f m głębi (%.0f%% z %.0f m) · pokój %.2f m (kolumna fasady %.2f m)\nschody %d × %.2f m = %.2f m (wygodnie %.2f m)%s · piętro %.1f m, ściana %.1f m · góra ekranu: %s" % [
		inside, _depth, FACADE_WIDTH_M, FACADE_DEPTH_M * FACADE_DEPTH_SHOWN, FACADE_DEPTH_SHOWN * 100.0,
		FACADE_DEPTH_M, _room_w, FACADE_WIDTH_M / COLUMNS, STEPS, _run, STEPS * _run, STEPS * RUN_M,
		" ZA KRÓTKO" if _run < RUN_M - 0.001 else "", STOREY_M, WALL_M, TOPS[_value(&"gora_mapy")]]


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _back_room == null or player == null:
		return
	var inside: bool = _back_room.global_floor_rect().has_point(player.global_position)
	var target: float = PARTITION_CUT_M if inside else WALL_M
	if is_equal_approx(_shown_m, target):
		return
	_shown_m = move_toward(_shown_m, target, (WALL_M - PARTITION_CUT_M) / CUT_SECONDS * delta)
	for block: Block in _partition_blocks:
		block.size_m.z = _shown_m
		block.repaint()
	if _lintel != null:
		_lintel.visible = _shown_m > _door_h
		_lintel.size_m.z = _shown_m
		_lintel.repaint()


func _column_origin(column: int) -> Vector2:
	return Vector2(ProjectionConfig.current().px(column * (_room_w + RoomBox.WALL_TOP_M)), 0.0)


## A room filling a column from the back wall to the front, not yet in the world: its windows and
## lamps must be added first (RoomLighting collects its lights when it enters the tree). The wall top on its right is the one it
## shares with the next column (none on the house's outer sides); doorways in it near the front.
func _column_room(column: int, slot: int, floor_color: Color, lamp: StringName, back_window: bool) -> RoomLighting:
	var box: RoomBox = _box(slot, _depth, WALL_M, floor_color)
	box.right_wall = column < COLUMNS - 1
	if column < COLUMNS - 1:
		box.right_door_z_m = _side_door_from()
	if column > 0:
		box.left_door_z_m = _side_door_from()
	if back_window:
		_add_back_window(box, (FLIGHT_FROM_M + FLIGHT_W + _room_w) / 2.0 if column == 1 else _room_w / 2.0)
	var room: RoomLighting = _room(_column_origin(column), box, ROOM_PROFILE)
	room.slot = slot
	_add_lamp(room, column, slot, lamp)
	_grid(room, box.floor_rect(), slot)
	if column < COLUMNS - 1:
		_side_doorway(room, column, slot, floor_color)
	return room


func _box(slot: int, depth: float, wall_m: float, floor_color: Color) -> RoomBox:
	var box: RoomBox = RoomBox.new()
	box.slot = slot
	box.width_m = _room_w
	box.depth_m = depth
	box.wall_height_m = wall_m
	box.wall_color = WALL_COLOR
	box.wall_top_color = WALL_TOP
	box.floor_color = floor_color
	box.left_wall = false
	box.right_wall = false
	box.front_wall = false
	box.side_door_m = _side_door_m()
	box.window_profile = _window_profile
	box.panes_per_window = _cols
	box.pane_rows = _rows
	box.view_day = _views[0]
	box.view_gold = _views[1]
	box.view_night = _views[2]
	if wall_m > 0.0:
		# A moulding along the top of the back wall instead of a wall top.
		var moulding: ShapePainter = ShapePainter.new(LightMasks.of(slot, LightMasks.Receiver.SOLID), RoomBox.WALL_Z + 1)
		moulding.add_rect(Rect2(0.0, 0.0, ProjectionConfig.current().px(_room_w), 2.0), MOULDING)
		box.add_child(moulding)
	return box


func _add_back_window(box: RoomBox, cx_m: float = -1.0) -> void:
	if cx_m < 0.0:
		cx_m = _room_w / 2.0
	if _window_size > 0:
		var w: float = SIZE_BACK_W[_window_size]
		var sill: float = SIZE_SILL_M[_window_size]
		box.windows = [Rect2(cx_m - w / 2.0, sill, w, WALL_M - sill - SIZE_HEAD_M[_window_size])]
		return
	box.windows = [Rect2(cx_m - BACK_WINDOW_W / 2.0, WALL_M / 3.0, BACK_WINDOW_W, WALL_M * 2.0 / 3.0 - 0.25)]


## A floor lamp near the back corner away from the middle column (the halls have a ceiling bulb).
func _add_lamp(room: RoomLighting, column: int, slot: int, lamp: StringName) -> void:
	if column == 1:
		return
	var at: Vector2 = Vector2(0.9, 0.6) if column == 0 else Vector2(_room_w - 0.9, 0.6)
	if lamp_on(lamp):
		room.add_child(_light(ground(at.x, at.y, room.box.wall_height_m), FLOOR_LAMP))
	_block(world, room.position + ground(at.x, at.y, room.box.wall_height_m), Vector3(0.3, 0.3, 1.6),
			Color(0.25, 0.22, 0.2), Color(0.9, 0.8, 0.6), [], true, 0.0, slot)


## Ground floor, right column: the kitchen behind (back window, a window in the right (east) wall)
## and the dining room in front (the facade's window); a partition between them with a door in it,
## cut down while the player is in the kitchen.
func _kitchen_and_dining() -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var origin: Vector2 = _column_origin(2)
	var back_d: float = snappedf(_depth * KITCHEN_SHARE, 0.1)
	var front_z: float = back_d + PARTITION_M
	var front_d: float = _depth - front_z
	var door_x: float = _room_w / 2.0 - INNER_DOOR_W / 2.0

	var kitchen_box: RoomBox = _box(2, back_d, WALL_M, FLOOR_KITCHEN)
	kitchen_box.door_x_m = door_x
	kitchen_box.door_width_m = INNER_DOOR_W
	_add_back_window(kitchen_box)
	var kitchen: RoomLighting = _room(origin, kitchen_box, ROOM_PROFILE)
	kitchen.slot = 2
	_add_lamp(kitchen, 2, 2, &"kuchnia")
	_grid(kitchen, kitchen_box.floor_rect(), 2)
	_side_window(kitchen, false, back_d / 2.0)
	_fade_side(kitchen, 2, false)
	world.add_child(kitchen)
	_back_room = kitchen
	_block(world, origin + ground(_room_w / 2.0, 0.6, WALL_M), Vector3(minf(2.4, _room_w - 0.6), 0.6, 0.9),
			Color("5e4a3a"), Color("8b6f55"), [], true, 0.0, 2)

	var dining_box: RoomBox = _box(3, front_d, 0.0, FLOOR_DINING)
	dining_box.open_back = true
	dining_box.above_m = WALL_M + PARTITION_M # the partition stands on its back edge: light all of it
	dining_box.back_door_x_m = door_x
	dining_box.back_door_width_m = INNER_DOOR_W
	dining_box.left_door_z_m = _side_door_from() - front_z
	var dining: RoomLighting = _room(origin + ground(0.0, front_z, WALL_M), dining_box, ROOM_PROFILE)
	dining.slot = 3
	if lamp_on(&"jadalnia"):
		dining.add_child(_light(ground(_room_w - 0.9, 0.6), FLOOR_LAMP))
	_block(world, origin + ground(_room_w - 0.9, front_z + 0.6, WALL_M), Vector3(0.3, 0.3, 1.6),
			Color(0.25, 0.22, 0.2), Color(0.9, 0.8, 0.6), [], true, 0.0, 3)
	_grid(dining, dining_box.floor_rect(), 3)
	_bottom_window(dining)
	_side_window(dining, false, front_d / 2.0) # ticket 31: beams from the right at sunrise or sunset
	_fade_bottom(dining, 3, -1.0)
	_fade_side(dining, 3, false)
	# The table stands aside, clear of the door to the kitchen.
	_block(world, origin + ground(_room_w * 0.25, front_z + front_d * 0.6, WALL_M), Vector3(1.4, 0.9, 0.75),
			Color(0.42, 0.31, 0.22), Color(0.55, 0.42, 0.3), [], true, 0.0, 3)

	# The partition: two pieces beside the door and a lintel over it, standing on the dining room's
	# back edge and lit with it; a threshold in the door on the dining room's floor.
	var right_from: float = door_x + INNER_DOOR_W
	_partition_blocks = [
		_block(world, origin + ground(door_x / 2.0, front_z, WALL_M), Vector3(door_x, PARTITION_M, WALL_M),
				WALL_COLOR, WALL_TOP, [], true, 0.0, 3),
		_block(world, origin + ground((right_from + _room_w) / 2.0, front_z, WALL_M),
				Vector3(_room_w - right_from, PARTITION_M, WALL_M), WALL_COLOR, WALL_TOP, [], true, 0.0, 3),
	]
	_lintel = _block(world, origin + ground(door_x + INNER_DOOR_W / 2.0, front_z, WALL_M),
			Vector3(INNER_DOOR_W, PARTITION_M, WALL_M), WALL_COLOR, WALL_TOP, [], false, _door_h, 3)
	var threshold: ShapePainter = ShapePainter.new(LightMasks.of(3, LightMasks.Receiver.FLOOR), RoomBox.WALL_Z + 3)
	threshold.add_rect(Rect2(config.px(door_x), 0.0, config.px(INNER_DOOR_W), 2.0), THRESHOLD)
	dining.add_child(threshold)
	world.add_child(dining)
	_shown_m = WALL_M


## A window in the bottom wall, in the middle of the room, not drawn: only its light (47 pattern A).
func _bottom_window(room: RoomLighting) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var area: Rect2 = room.box.floor_rect()
	var light: SideWindowLight = SideWindowLight.new()
	light.profile = _window_profile
	light.panes = _cols
	light.wall_height_px = roundi(config.px(WALL_M))
	light.wall_azimuth_deg = 0.0
	light.span = roundi(config.px(_side_w()))
	light.into_up = true
	light.street_side = true # the bottom wall is the facade on the street
	light.patch_k = PATCH_K
	light.position = Vector2(roundf(area.get_center().x - config.px(_side_w()) / 2.0), area.end.y)
	room.add_child(light)


## A window in an outer side wall, its middle `z_m` into the room's depth: only its light.
func _side_window(room: RoomLighting, left: bool, z_m: float) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var area: Rect2 = room.box.floor_rect()
	var light: SideWindowLight = SideWindowLight.new()
	light.profile = _window_profile
	light.panes = _cols
	light.wall_height_px = roundi(config.px(WALL_M))
	light.wall_azimuth_deg = 90.0 if left else 270.0
	light.span = roundi(config.depth_px(_side_w()))
	light.into_right = left
	light.patch_k = PATCH_K
	light.position = Vector2(area.position.x if left else area.end.x,
			roundf(area.position.y + config.depth_px(z_m - _side_w() / 2.0)))
	room.add_child(light)


## The room's bottom edge (EDGES); a gap is left for a door centred at `door_x_m` (below 0: none).
func _fade_bottom(room: RoomLighting, slot: int, door_x_m: float) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var area: Rect2 = room.box.floor_rect()
	var spans: Array[Vector2] = [Vector2(area.position.x, area.end.x)]
	if door_x_m >= 0.0:
		var half: float = roundf(config.px(TONGUE_M.x) / 2.0)
		spans = [Vector2(area.position.x, config.px(door_x_m) - half), Vector2(config.px(door_x_m) + half, area.end.x)]
	var top: float = config.px(RoomBox.WALL_TOP_M)
	# Below the floor: the ends of the wall tops between the rooms always stop here.
	var cover: ShapePainter = _fade_painter(room, slot)
	cover.add_rect(Rect2(area.position.x - top, area.end.y, area.size.x + 2.0 * top, top + 1.0), Color.BLACK)
	match _edge:
		0:
			_gradient_bottom(room, slot, spans)
		1:
			_slab(room, slot, spans)
		2:
			_dither(room, Rect2(area.position.x, area.end.y - DITHER_BOTTOM_PX, area.size.x, DITHER_BOTTOM_PX), 0, Color.BLACK, 0.0)
		3:
			_slab(room, slot, spans)
			_dither(room, Rect2(area.position.x, area.end.y - DITHER_AB_PX, area.size.x, DITHER_AB_PX), 0, Color.BLACK, 0.0)
		_:
			_dither(room, Rect2(area.position.x, area.end.y - MIST_BOTTOM_PX, area.size.x, MIST_BOTTOM_PX), 0, MIST, MIST_AMPLITUDE_PX)
	if door_x_m >= 0.0 and _edge >= 2:
		# The dither stops at the door: the tongue stays lit.
		var gap: ShapePainter = ShapePainter.new(LightMasks.of(slot, LightMasks.Receiver.FLOOR), RoomBox.WALL_Z + 9)
		var half_px: float = roundf(config.px(TONGUE_M.x) / 2.0)
		gap.add_rect(Rect2(config.px(door_x_m) - half_px, area.end.y - MIST_BOTTOM_PX, 2.0 * half_px, MIST_BOTTOM_PX), room.box.floor_color)
		room.add_child(gap)


## An outer side of the house (EDGES), from the top of the back wall to the bottom of the floor.
func _fade_side(room: RoomLighting, slot: int, left: bool) -> void:
	var area: Rect2 = room.box.floor_rect()
	var side: int = 1 if left else 2
	match _edge:
		0:
			_gradient_side(room, slot, left)
		1:
			_post(room, slot, left)
		2:
			_dither(room, _side_strip(area, left, DITHER_SIDE_PX), side, Color.BLACK, 0.0)
		3:
			_post(room, slot, left)
			_dither(room, _side_strip(area, left, DITHER_AB_PX), side, Color.BLACK, 0.0)
		_:
			_dither(room, _side_strip(area, left, MIST_SIDE_PX), side, MIST, MIST_AMPLITUDE_PX)


static func _side_strip(area: Rect2, left: bool, width: int) -> Rect2:
	return Rect2(area.position.x if left else area.end.x - width, 0.0, width, area.end.y)


func _gradient_bottom(room: RoomLighting, slot: int, spans: Array[Vector2]) -> void:
	var area: Rect2 = room.box.floor_rect()
	var painter: ShapePainter = _fade_painter(room, slot)
	var band: float = float(FADE_PX) / FADE_STEPS
	for span: Vector2 in spans:
		for step: int in FADE_STEPS:
			var y: float = area.end.y - FADE_PX + band * step
			painter.add_rect(Rect2(span.x, roundf(y), span.y - span.x, ceilf(band)), _fade_color(step))


func _gradient_side(room: RoomLighting, slot: int, left: bool) -> void:
	var area: Rect2 = room.box.floor_rect()
	var painter: ShapePainter = _fade_painter(room, slot)
	var band: float = float(FADE_PX) / FADE_STEPS
	for step: int in FADE_STEPS:
		var offset: float = FADE_PX - band * (step + 1)
		var x: float = area.position.x + offset if left else area.end.x - offset - band
		painter.add_rect(Rect2(roundf(x), 0.0, ceilf(band), area.end.y), _fade_color(step))


## A: the floor slab cut in section under each span: its front SLAB_PX tall, a 1 px light cut edge on
## top, a ragged lower edge with chips; flat black below. Under a door gap: light falling out.
func _slab(room: RoomLighting, slot: int, spans: Array[Vector2]) -> void:
	var area: Rect2 = room.box.floor_rect()
	var painter: ShapePainter = ShapePainter.new(LightMasks.of(slot, LightMasks.Receiver.SOLID), RoomBox.WALL_Z + 9)
	var unshaded: CanvasItemMaterial = CanvasItemMaterial.new()
	unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	painter.material = unshaded
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash(room.position)
	var y0: float = area.end.y
	for span: Vector2 in spans:
		var points: PackedVector2Array = PackedVector2Array([Vector2(span.x, y0), Vector2(span.y, y0)])
		var x: float = span.y
		while x > span.x:
			points.append(Vector2(x, y0 + SLAB_PX + rng.randi_range(0, 3)))
			x -= rng.randi_range(8, 14)
		points.append(Vector2(span.x, y0 + SLAB_PX + rng.randi_range(0, 3)))
		painter.add_polygon(points, SLAB)
		painter.add_rect(Rect2(span.x, y0, span.y - span.x, 1.0), SLAB_EDGE)
		# Chips broken off the lower edge, and grit on the cut.
		var chips: int = maxi(1, roundi((span.y - span.x) / 70.0))
		for chip: int in chips:
			var cx: float = rng.randf_range(span.x + 6.0, span.y - 6.0)
			painter.add_polygon(PackedVector2Array([Vector2(cx - 3.0, y0 + SLAB_PX), Vector2(cx + 3.0, y0 + SLAB_PX),
					Vector2(cx, y0 + SLAB_PX + 4.0)]), SLAB)
			painter.add_rect(Rect2(roundf(rng.randf_range(span.x + 4.0, span.y - 4.0)), y0 + 2.0, 2.0, 2.0), SLAB_EDGE)
	room.add_child(painter)


## A: the outer wall cut in section, a post POST_PX wide with a ragged top, from the back wall's top
## to the slab.
func _post(room: RoomLighting, slot: int, left: bool) -> void:
	var area: Rect2 = room.box.floor_rect()
	var painter: ShapePainter = ShapePainter.new(LightMasks.of(slot, LightMasks.Receiver.SOLID), RoomBox.WALL_Z + 9)
	var unshaded: CanvasItemMaterial = CanvasItemMaterial.new()
	unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	painter.material = unshaded
	var x: float = area.position.x - POST_PX if left else area.end.x
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash(room.position) + (1 if left else 2)
	var bottom: float = area.end.y + SLAB_PX
	painter.add_polygon(PackedVector2Array([Vector2(x, rng.randi_range(-3, 1)), Vector2(x + POST_PX, rng.randi_range(-3, 1)),
			Vector2(x + POST_PX, bottom), Vector2(x, bottom)]), SLAB)
	painter.add_rect(Rect2(x + (POST_PX - 1 if left else 0), 0.0, 1.0, bottom), SLAB_EDGE)
	room.add_child(painter)


## B, C: an ordered (Bayer 4×4) dither into `color` across `rect` (room px), dark at the outer edge
## (`side` 0 bottom, 1 left, 2 right); darkness t² in sRGB terms. C shifts the edge with value noise.
func _dither(room: RoomLighting, rect: Rect2, side: int, color: Color, amplitude: float) -> void:
	var size: Vector2i = Vector2i(roundi(rect.size.x), roundi(rect.size.y))
	if size.x <= 0 or size.y <= 0:
		return
	var image: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	var zone: float = float(size.y if side == 0 else size.x)
	var origin: Vector2i = Vector2i(roundi(room.position.x + rect.position.x), roundi(room.position.y + rect.position.y))
	var waves: PackedFloat32Array = PackedFloat32Array()
	var along_px: int = size.x if side == 0 else size.y
	if amplitude > 0.0:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = hash(room.position) + side
		for knot: int in ceili(along_px / MIST_WAVE_PX) + 2:
			waves.append(rng.randf())
	for y: int in size.y:
		for x: int in size.x:
			var along: int = x if side == 0 else y
			var from_edge: float = float(size.y - 1 - y) if side == 0 else (float(x) if side == 1 else float(size.x - 1 - x))
			if amplitude > 0.0:
				var at: float = along / MIST_WAVE_PX
				var knot: int = floori(at)
				var wave: float = lerpf(waves[knot], waves[knot + 1], smoothstep(0.0, 1.0, at - knot))
				from_edge -= (wave - 0.5) * 2.0 * amplitude + ((hash(Vector2i(origin.x + x, origin.y + y)) % 3) - 1)
			var t: float = clampf(1.0 - from_edge / zone, 0.0, 1.0)
			var dark: float = t * t
			var threshold: float = (BAYER[((origin.y + y) % 4) * 4 + (origin.x + x) % 4] + 0.5) / 16.0
			if dark > threshold:
				image.set_pixel(x, y, color)
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.centered = false
	sprite.position = rect.position
	sprite.z_index = RoomBox.WALL_Z + 8
	var unshaded: CanvasItemMaterial = CanvasItemMaterial.new()
	unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	sprite.material = unshaded
	room.add_child(sprite)
	if color != Color.BLACK:
		# C: the last 6 px go from the dark blue to black.
		var last: ShapePainter = _fade_painter(room, 0)
		var edge: Rect2 = Rect2(rect.position.x, rect.end.y - 6.0, rect.size.x, 6.0) if side == 0 				else (Rect2(rect.position.x, 0.0, 6.0, rect.size.y) if side == 1 else Rect2(rect.end.x - 6.0, 0.0, 6.0, rect.size.y))
		last.add_rect(edge, Color.BLACK)


func _fade_painter(room: RoomLighting, slot: int) -> ShapePainter:
	var painter: ShapePainter = ShapePainter.new(LightMasks.of(slot, LightMasks.Receiver.FLOOR), RoomBox.WALL_Z + 8)
	var unshaded: CanvasItemMaterial = CanvasItemMaterial.new()
	unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	painter.material = unshaded
	room.add_child(painter)
	return painter


static func _fade_color(step: int) -> Color:
	var t: float = float(step + 1) / FADE_STEPS
	return Color(0.0, 0.0, 0.0, pow(t, 1.6))


## Ground floor hall: a flight along the left wall rising towards the back (risers to the camera), cut
## by the ceiling; walking into its foot goes upstairs.
func _flight(origin: Vector2) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var riser: float = STOREY_M / STEPS
	var foot_z: float = STEPS * _run
	var x: float = FLIGHT_FROM_M + FLIGHT_W / 2.0
	for step: int in STEPS:
		var front: float = foot_z - step * _run
		_stairs.append(_block(world, origin + ground(x, front, WALL_M), Vector3(FLIGHT_W, _run, minf((step + 1) * riser, WALL_M)),
				STAIR_FRONT, STAIR_TOP, [], false, 0.0, 1))
	_static_rect(origin + ground(FLIGHT_FROM_M, 0.0, WALL_M),
			Vector2(config.px(FLIGHT_W), config.depth_px(foot_z - 2.0 * _run)))
	_door(PIETRO_SCENE, &"ze_schodow", origin + ground(x, foot_z - _run + 0.15, WALL_M),
			Vector2(FLIGHT_W, 2.0 * _run + 0.3))
	_spawn("z_pietra", origin + ground(x, foot_z + 0.9, WALL_M))


## Upstairs hall: the stairwell over the flight along the left wall, a balustrade on its right and in
## front; the top steps (at the back) lead down, reached from the right.
func _stairwell(origin: Vector2) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var foot_z: float = STEPS * _run
	var hole: Rect2 = Rect2(origin + ground(FLIGHT_FROM_M, 0.0, WALL_M), Vector2(config.px(FLIGHT_W), config.depth_px(foot_z)))
	var painter: ShapePainter = ShapePainter.new(LightMasks.of(1, LightMasks.Receiver.FLOOR), RoomBox.WALL_Z + 2)
	painter.add_rect(hole, HOLE)
	# Treads going down towards the front, darker the deeper they are.
	for step: int in STEPS:
		var y: float = hole.position.y + config.depth_px(step * _run)
		painter.add_rect(Rect2(hole.position.x, roundf(y), hole.size.x, 2.0), STAIR_TOP.darkened(0.3 + 0.6 * float(step) / STEPS))
	world.add_child(painter)
	var top: float = 2.0 * _run
	var rail: Color = Color(0.3, 0.24, 0.2)
	var rail_top: Color = Color(0.45, 0.36, 0.28)
	_block(world, origin + ground(FLIGHT_FROM_M + FLIGHT_W + 0.03, foot_z, WALL_M), Vector3(0.06, foot_z - top, 0.9),
			rail, rail_top, [], true, 0.0, 1)
	_block(world, origin + ground(FLIGHT_FROM_M + FLIGHT_W / 2.0, foot_z + 0.06, WALL_M), Vector3(FLIGHT_W + 0.06, 0.06, 0.9),
			rail, rail_top, [], true, 0.0, 1)
	_static_rect(origin + ground(FLIGHT_FROM_M, top, WALL_M), Vector2(config.px(FLIGHT_W), config.depth_px(foot_z - top)))
	_door(PARTER_SCENE, &"z_pietra", origin + ground(FLIGHT_FROM_M + FLIGHT_W / 2.0, top / 2.0, WALL_M), Vector2(FLIGHT_W, top))
	_spawn("ze_schodow", origin + ground(FLIGHT_FROM_M + FLIGHT_W + 0.5, top, WALL_M))


## A doorway in the room's right wall top (43 §3): the floor runs through the gap, and the door's
## leaf stands open flat against the wall behind it, a thin tall block that reads as a door.
func _side_doorway(room: RoomLighting, column: int, slot: int, floor_color: Color) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var area: Rect2 = room.box.floor_rect()
	var door_z: float = _side_door_from()
	var y: float = roundf(area.position.y + config.depth_px(door_z))
	var length: float = roundf(config.depth_px(_side_door_m()))
	var wall: float = config.px(RoomBox.WALL_TOP_M)
	var hole: bool = _value(&"przejscia") == 1
	var gap: ShapePainter = ShapePainter.new(LightMasks.of(slot, LightMasks.Receiver.FLOOR), RoomBox.WALL_Z + 1)
	if not hole:
		gap.add_rect(Rect2(area.end.x, y, wall, length), floor_color)
		gap.add_rect(Rect2(area.end.x, y, 1.0, length), THRESHOLD)
		gap.add_rect(Rect2(area.end.x + wall - 1.0, y, 1.0, length), THRESHOLD)
		room.add_child(gap)
		# The leaf, open flat against the wall: drawn up the wall as a thin brown strip (the human: a bug).
		_block(world, room.position + ground(_room_w - 0.04, door_z, WALL_M), Vector3(0.05, DOOR_LEAF_M * _side_door_m() / INNER_DOOR_W, _door_h),
				DOOR_LEAF, DOOR_LEAF.lightened(0.15), [], false, 0.0, slot)
		return
	# The hole: the floor and the light pass from this room to the next across the wall, so each edge is
	# exactly the floor beside it (the human: no seam, no colour of its own). Per 1 px strip: the colour
	# blends, and a copy in the next room's light fades in over this room's.
	var next_color: Color = _next_floor_color(column)
	var far: ShapePainter = ShapePainter.new(LightMasks.of(_next_slot(column), LightMasks.Receiver.FLOOR), RoomBox.WALL_Z + 2)
	var strips: int = maxi(roundi(wall), 2)
	for strip: int in strips:
		var share: float = float(strip) / (strips - 1)
		var strip_rect: Rect2 = Rect2(area.end.x + wall * strip / strips, y, wall / strips, length)
		var color: Color = floor_color.lerp(next_color, share)
		gap.add_rect(strip_rect, color)
		far.add_rect(strip_rect, Color(color, share))
	room.add_child(gap)
	room.add_child(far)


## The room through the doorway in a column's right wall: its light slot and its floor colour.
func _next_slot(column: int) -> int:
	if floor_index == 0:
		return 1 if column == 0 else 3
	return column + 1


func _next_floor_color(column: int) -> Color:
	if floor_index == 0:
		return FLOOR_HALL if column == 0 else FLOOR_DINING
	return FLOOR_UPPER[column + 1]


## The street door (43 §3): a floor tongue out of the bottom edge with a threshold, a mat with snow on
## it, and cold light from outside falling in.
func _street_door(room: RoomLighting, origin: Vector2) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var cx: float = _room_w / 2.0
	_door_x_m = origin.x / config.px_per_m + cx
	var edge: float = room.box.floor_rect().end.y
	var tongue: Rect2 = Rect2(config.px(cx - TONGUE_M.x / 2.0), edge, config.px(TONGUE_M.x), config.depth_px(TONGUE_M.y))
	var painter: ShapePainter = ShapePainter.new(LightMasks.of(1, LightMasks.Receiver.FLOOR), RoomBox.WALL_Z + 9)
	painter.add_rect(tongue, FLOOR_HALL.darkened(0.1))
	painter.add_rect(Rect2(tongue.position.x, edge, tongue.size.x, 2.0), THRESHOLD)
	painter.add_rect(Rect2(config.px(cx - 0.45), edge + config.depth_px(0.15), config.px(0.9), config.depth_px(0.4)), MAT)
	painter.add_rect(Rect2(config.px(cx - 0.3), edge + config.depth_px(0.2), 2.0, 1.0), SNOW)
	painter.add_rect(Rect2(config.px(cx + 0.2), edge + config.depth_px(0.45), 2.0, 1.0), SNOW)
	painter.add_rect(Rect2(config.px(cx - 0.05), edge + config.depth_px(0.35), 1.0, 1.0), SNOW)
	room.add_child(painter)
	# The tongue's own fade at its far end.
	var fade: ShapePainter = _fade_painter(room, 1)
	fade.z_index = RoomBox.WALL_Z + 10
	var steps: int = 5
	for step: int in steps:
		fade.add_rect(Rect2(tongue.position.x, tongue.end.y - steps + step, tongue.size.x, 1.0),
				Color(0.0, 0.0, 0.0, float(step + 1) / (steps + 1)))
	# Ticket 36: no spill light; the door is an opening in the bottom wall (its light from the buffer).
	var door: Door = Door.new()
	door.target_scene = street_scene
	door.spawn = &"z_domu"
	door.size_m = Vector2(DOOR_W, 0.3)
	door.at_m = (origin + ground(cx, _depth + TONGUE_M.y + 0.05, WALL_M)) / config.px_per_m
	world.add_child(door)
	_spawn("z_ulicy", origin + ground(cx, _depth - 0.8, WALL_M))


func _static_rect(top_left: Vector2, size: Vector2) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	shape.position = top_left + size / 2.0
	body.add_child(shape)
	world.add_child(body)


## A passage centred at `at` (px), `size_m` metres on the ground.
func _door(target: String, spawn: StringName, at: Vector2, size_m: Vector2) -> void:
	var door: Door = Door.new()
	door.target_scene = target
	door.spawn = spawn
	door.size_m = size_m
	door.at_m = at / ProjectionConfig.current().px_per_m
	world.add_child(door)


func _light(at: Vector2, def: FixtureDef) -> Node2D:
	var spot: Node2D = Node2D.new()
	spot.position = at
	var fixture: LightFixture = LightFixture.new()
	fixture.def = def
	spot.add_child(fixture)
	return spot


## The back windows' view (placeholder), a little wider than the window so it never sticks out of
## a narrow room: `kind` 0 the back of the plot (fence, shed, spruce, a neighbour's back wall), 1 a
## street (wrong for a back window, for comparison); `time` 0 day, 1 dusk, 2 night.
static func _view_texture(kind: int, time: int, level: float = 1.0) -> ImageTexture:
	var pal: PackedColorArray = VIEW_PALETTES.slice(time * VIEW_PALETTE_SIZE, (time + 1) * VIEW_PALETTE_SIZE)
	for index: int in pal.size():
		var lit_window: bool = index == 5 and time > 0
		if not lit_window:
			pal[index] = Color(pal[index].r * level, pal[index].g * level, pal[index].b * level)
	var image: Image = Image.create_empty(VIEW_SIZE.x, VIEW_SIZE.y, false, Image.FORMAT_RGBA8)
	for y: int in VIEW_HORIZON:
		image.fill_rect(Rect2i(0, y, VIEW_SIZE.x, 1), pal[0].lerp(pal[1], float(y) / VIEW_HORIZON))
	image.fill_rect(Rect2i(0, VIEW_HORIZON, VIEW_SIZE.x, VIEW_SIZE.y - VIEW_HORIZON), pal[2])
	var c: int = VIEW_SIZE.x / 2
	var lit: bool = time > 0
	if kind == 0:
		# A neighbour's house far back, its roof white with snow.
		image.fill_rect(Rect2i(c + 4, 22, 40, 16), pal[4])
		image.fill_rect(Rect2i(c + 2, 18, 44, 4), pal[2].darkened(0.05))
		image.fill_rect(Rect2i(c + 10, 27, 5, 6), pal[5] if lit else pal[3])
		image.fill_rect(Rect2i(c + 26, 27, 5, 6), pal[3])
		# A shed and a spruce in the yard.
		image.fill_rect(Rect2i(c - 14, 30, 16, 10), pal[3].lightened(0.15))
		image.fill_rect(Rect2i(c - 15, 28, 18, 2), pal[2])
		for row: int in 6:
			image.fill_rect(Rect2i(c - 24 - row, 14 + row * 5, 6 + row * 2, 5), pal[3])
		# The fence across the plot.
		image.fill_rect(Rect2i(0, 44, VIEW_SIZE.x, 1), pal[3])
		image.fill_rect(Rect2i(0, 50, VIEW_SIZE.x, 1), pal[3])
		for x: int in range(2, VIEW_SIZE.x, 9):
			image.fill_rect(Rect2i(x, 42, 2, 12), pal[3])
	else:
		# Facades across a street, a lamp post, the road.
		image.fill_rect(Rect2i(0, 8, VIEW_SIZE.x, 30), pal[4])
		for x: int in range(c - 30, c + 30, 14):
			image.fill_rect(Rect2i(x, 14, 6, 8), pal[5] if lit and (x / 14) % 2 == 0 else pal[3])
			image.fill_rect(Rect2i(x, 27, 6, 8), pal[5] if lit else pal[3])
		image.fill_rect(Rect2i(c + 12, 18, 2, 32), pal[3])
		image.fill_rect(Rect2i(0, 46, VIEW_SIZE.x, 8), pal[2].darkened(0.3))
	return ImageTexture.create_from_image(image)
