extends Node
## The new street Poligon (light engine): a Location built from contract nodes, rendered at the game
## frame and scaled to the window, with an F1 holding the engine panel and the frame switch. Shots
## (F12 or the panel's button) record the frame switch too. The move actions walk the character
## (engine ticket 17); the camera follows it. Two NPCs on a routine join it when F1 asks (the cost of
## three walking characters).

## 960×540 as in game2 (×2 on 1080p), or 640×360 as in the engine map's prototypes.
const FRAMES: Array[Vector2i] = [Vector2i(960, 540), Vector2i(640, 360)]
## The camera looks at the character's middle: this far above its feet (half of 72 px).
const CAMERA_ABOVE_FEET_PX: float = 36.0
## The bench's warm-up and measured time (seconds).
const WARM_UP_S: float = 2.0
const MEASURE_S: float = 6.0

## Looks of one asset compared in F1 (engine ticket 10: the stall from ComfyUI with its two add-on
## normal maps, and the simple painted sprite); the first is the starting one.
@export var asset_looks: Array[AssetLook] = []
## The sprite whose look the switch changes.
@export var looked_asset: AssetSprite
## The NPCs' routines (x, d in metres; each starts at its last point) and speeds, when F1 adds them.
@export var npc_routes: Array[PackedVector2Array] = []
@export var npc_speeds_m_s: PackedFloat32Array = PackedFloat32Array()

## The NPCs on the street now (none until F1 adds them).
var _npcs: Array[PoligonWalker] = []

@onready var _frame: SubViewport = %Frame
@onready var _picture: TextureRect = %Picture
@onready var _engine: LightEngine = %Engine
@onready var _f1: CanvasLayer = %F1
@onready var _engine_panel: EnginePanel = %EnginePanel
@onready var _frame_choice: OptionButton = %FrameChoice
@onready var _look_choice: OptionButton = %LookChoice
@onready var _shot: EngineShot = %Shot
@onready var _camera: Camera2D = %Camera
@onready var _walker: PoligonWalker = %Walker
@onready var _shadow_choice: OptionButton = %ShadowChoice
@onready var _npc_check: CheckBox = %NpcCheck


func _ready() -> void:
	# After the walker moved (children process after this root otherwise): the camera follows the
	# feet of this frame.
	process_priority = 1
	_picture.texture = _frame.get_texture()
	_engine_panel.hour_set.connect(_engine.set_hour)
	_engine_panel.rate_set.connect(func(rate: float) -> void: _engine.rate = rate)
	_engine_panel.debug_view_set.connect(_engine.set_debug_view)
	_engine_panel.north_at_top_set.connect(_engine.set_north_at_top)
	_engine_panel.style_mode_set.connect(_engine.set_style_mode)
	_engine_panel.style_mode_choice().select(_engine.style_mode())
	_engine_panel.penumbra_set.connect(_engine.set_penumbra_on)
	_engine_panel.show_style_mode(_engine.source_light().has_channel(SourceProfile.Channel.ARTIFICIAL))
	_engine.state_changed.connect(_engine_panel.show_state)
	_engine_panel.set_rate(_engine.rate)
	_engine_panel.show_state(_engine.state())

	for frame: Vector2i in FRAMES:
		_frame_choice.add_item("%d×%d" % [frame.x, frame.y])
	_frame_choice.item_selected.connect(_set_frame)
	_set_frame(0)
	get_viewport().size_changed.connect(_fit_picture)

	for look: AssetLook in asset_looks:
		_look_choice.add_item(look.look_name)
	_look_choice.item_selected.connect(_set_look)
	if not asset_looks.is_empty():
		_set_look(0)

	for shape_name: String in PoligonWalker.SHADOW_SHAPES:
		_shadow_choice.add_item(shape_name)
	_shadow_choice.select(_walker.shadow_shape)
	_shadow_choice.item_selected.connect(func(index: int) -> void: _set_shadow_shape(index as PoligonWalker.ShadowShape))
	_npc_check.toggled.connect(_set_npcs)
	_follow_walker()

	var bench: String = _user_arg("bench")
	if not bench.is_empty():
		_bench.call_deferred(bench.to_float())

	_engine_panel.shot_requested.connect(func() -> void: _shot.take())
	_shot.taken.connect(_engine_panel.show_shot)
	_shot.character = _walker.body()
	_shot.add_switch("kadr", _frame_name, _select_frame)
	_shot.add_switch("widok debug", _debug_view_name, _select_debug_view)
	_shot.add_switch("cień postaci", _shadow_name, _select_shadow)
	_shot.add_switch("NPC", _npc_name, _select_npc)
	_shot.add_switch("góra mapy", _map_top_name, _select_map_top)
	_shot.add_switch("tryb A′", _style_mode_name, _select_style_mode)
	_shot.add_switch("półcień", _penumbra_name, _select_penumbra)
	if not asset_looks.is_empty():
		_shot.add_switch("wygląd assetu", _look_name, _select_look)


func _process(_delta: float) -> void:
	if not _walker.is_inside_tree():
		return
	_follow_walker()
	_sort_walkers()


## Draws each character before the assets and characters standing nearer the camera than its feet
## (larger d), so the stall in front hides its legs; after the rest of the street. Far ones first.
func _sort_walkers() -> void:
	var street: Node = _walker.get_parent()
	var walkers: Array[PoligonWalker] = [_walker]
	walkers.append_array(_npcs)
	walkers.sort_custom(func(a: PoligonWalker, b: PoligonWalker) -> bool: return a.position_m().y < b.position_m().y)
	for walker: PoligonWalker in walkers:
		var feet_d: float = walker.position_m().y
		var target: int = 0
		for child: Node in street.get_children():
			if child == walker:
				continue
			if _feet_d(child) > feet_d:
				break
			target += 1
		if walker.get_index() != target:
			street.move_child(walker, target)


## The d of a street child drawn in depth order: an asset's or a character's feet (−INF: the rest).
static func _feet_d(child: Node) -> float:
	var walker: PoligonWalker = child as PoligonWalker
	if walker != null:
		return walker.position_m().y
	var occluder: Occluder = child as Occluder
	if occluder != null and occluder.asset_sprite() != null:
		return occluder.position_m.y
	return -INF


## Puts the NPCs on the street or takes them off; the engine reads its Occluders again.
func _set_npcs(on: bool) -> void:
	var street: Node = _walker.get_parent()
	for npc: PoligonWalker in _npcs:
		street.remove_child(npc)
		npc.queue_free()
	_npcs.clear()
	if on:
		for index: int in npc_routes.size():
			var npc: PoligonWalker = PoligonWalker.new()
			npc.name = "Npc%d" % (index + 1)
			npc.route_m = npc_routes[index]
			npc.speed_m_s = npc_speeds_m_s[index] if index < npc_speeds_m_s.size() else npc.speed_m_s
			var start: Vector2 = npc_routes[index][-1]
			npc.start_m = Vector3(start.x, start.y, 0.0)
			street.add_child(npc)
			npc.shadow_shape = _walker.shadow_shape
			_npcs.append(npc)
	_engine.rebuild_scene()


## The shadow shape of every character (F1, shots).
func _set_shadow_shape(shape: PoligonWalker.ShadowShape) -> void:
	_walker.shadow_shape = shape
	for npc: PoligonWalker in _npcs:
		npc.shadow_shape = shape


## The NPC switch as shots record it.
func _npc_name() -> String:
	return "2 na rutynie" if _npc_check.button_pressed else "brak"


## Sets the NPC switch from a shot.
func _select_npc(npc_name: String) -> void:
	_npc_check.button_pressed = npc_name != "brak"


## The camera on the character, on whole pixels.
func _follow_walker() -> void:
	_camera.position = (_walker.body().position - Vector2(0.0, CAMERA_ABOVE_FEET_PX)).round()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_debug"):
		_f1.visible = not _f1.visible
		get_viewport().set_input_as_handled()


## Changes the frame size; the camera stays put, so the centre of the view does not move.
func _set_frame(index: int) -> void:
	_frame.size = FRAMES[index]
	_fit_picture()


func _frame_name() -> String:
	return _frame_choice.get_item_text(_frame_choice.selected)


func _select_frame(frame_name: String) -> void:
	for index: int in _frame_choice.item_count:
		if _frame_choice.get_item_text(index) == frame_name:
			_frame_choice.select(index)
			_set_frame(index)
			return
	push_warning("Unknown frame in the shot: %s" % frame_name)


## Gives the looked-at asset the chosen look; the engine reads sprites when it builds the scene.
func _set_look(index: int) -> void:
	var look: AssetLook = asset_looks[index]
	looked_asset.texture = look.sprite
	looked_asset.normal_map = look.normal_map
	_engine.rebuild_scene()


func _look_name() -> String:
	return asset_looks[_look_choice.selected].look_name


func _select_look(look_name: String) -> void:
	for index: int in asset_looks.size():
		if asset_looks[index].look_name == look_name:
			_look_choice.select(index)
			_set_look(index)
			return
	push_warning("Unknown asset look in the shot: %s" % look_name)


func _shadow_name() -> String:
	return PoligonWalker.SHADOW_SHAPES[_walker.shadow_shape]


func _select_shadow(shape_name: String) -> void:
	var index: int = PoligonWalker.SHADOW_SHAPES.find(shape_name)
	if index < 0:
		push_warning("Unknown character shadow in the shot: %s" % shape_name)
		return
	_shadow_choice.select(index)
	_set_shadow_shape(index as PoligonWalker.ShadowShape)


func _map_top_name() -> String:
	return EnginePanel.MAP_TOPS[1 if _engine.state().north_at_top else 0]


func _select_map_top(top_name: String) -> void:
	var index: int = EnginePanel.MAP_TOPS.find(top_name)
	if index < 0:
		push_warning("Unknown map top in the shot: %s" % top_name)
		return
	_engine_panel.map_top_choice().select(index)
	_engine.set_north_at_top(index == 1)


func _style_mode_name() -> String:
	return EnginePanel.STYLE_MODES[_engine.style_mode()]


func _select_style_mode(mode_name: String) -> void:
	var index: int = EnginePanel.STYLE_MODES.find(mode_name)
	if index < 0:
		push_warning("Unknown A′ mode in the shot: %s" % mode_name)
		return
	_engine_panel.style_mode_choice().select(index)
	_engine.set_style_mode(index as TuningSet.StyleMode)


func _penumbra_name() -> String:
	return EnginePanel.PENUMBRAS[0 if _engine.is_penumbra_on() else 1]


func _select_penumbra(penumbra_name: String) -> void:
	var index: int = EnginePanel.PENUMBRAS.find(penumbra_name)
	if index < 0:
		push_warning("Unknown penumbra in the shot: %s" % penumbra_name)
		return
	_engine_panel.penumbra_choice().select(index)
	_engine.set_penumbra_on(index == 0)


func _debug_view_name() -> String:
	return EnginePanel.DEBUG_VIEWS[_engine.debug_view()]


func _select_debug_view(view_name: String) -> void:
	var index: int = EnginePanel.DEBUG_VIEWS.find(view_name)
	if index < 0:
		push_warning("Unknown debug view in the shot: %s" % view_name)
		return
	_engine_panel.debug_view_choice().select(index)
	_engine_panel.show_debug_hint(index)
	_engine.set_debug_view(index as LightEngine.DebugView)


## PROTOTYPE (engine ticket 17): `-- --bench=22 [--chod] [--npc] [--cien=walec] [--bez-postaci] [--at=x,y]`:
## frames per second without vsync (MEASURE_S after WARM_UP_S, time stopped), printed as a BENCH line
## with the count of each second, then quit. `--chod` walks the character left and right (1 s each
## way); `--cien` picks the shadow shape by its F1 name; `--at` puts the feet there (screen px).
func _bench(hour: float) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	_engine.rate = 0.0
	_engine.set_hour(hour)
	var shadow: String = _user_arg("cien")
	if not shadow.is_empty():
		_select_shadow(shadow)
	var at: PackedFloat64Array = _user_arg("at").split_floats(",")
	if at.size() == 2:
		_walker.body().position = Vector2(at[0], at[1])
	if _user_arg("bez-postaci") == "1":
		_walker.get_parent().remove_child(_walker)
		_engine.rebuild_scene()
	var walking: bool = _user_arg("chod") == "1"
	if _user_arg("npc") == "1":
		_npc_check.button_pressed = true
	while not _engine.is_complete():
		await RenderingServer.frame_post_draw
	var start: int = Time.get_ticks_usec()
	var second_start: int = start
	var frames: int = 0
	var second_frames: int = 0
	var per_second: PackedStringArray = PackedStringArray()
	var measured: int = 0
	while true:
		var clock: float = (Time.get_ticks_usec() - start) / 1e6
		if clock >= WARM_UP_S + MEASURE_S:
			break
		if walking:
			var right: bool = fmod(clock, 2.0) < 1.0
			Input.action_release(&"move_left" if right else &"move_right")
			Input.action_press(&"move_right" if right else &"move_left")
		await RenderingServer.frame_post_draw
		second_frames += 1
		var now: int = Time.get_ticks_usec()
		if now - second_start >= 1000000:
			per_second.append(str(second_frames))
			second_frames = 0
			second_start = now
		if clock < WARM_UP_S:
			measured = now
			frames = 0
		else:
			frames += 1
	var seconds: float = (Time.get_ticks_usec() - measured) / 1e6
	print("BENCH %.1f%s%s: %.0f fps (%.2f ms); per second: %s" % [hour, " chód" if walking else "",
			" +2 NPC" if _npc_check.button_pressed else "", frames / seconds,
			seconds * 1000.0 / frames, " ".join(per_second)])
	get_tree().quit()


## The value of `--key=value` after `--` on the command line ("1" for a bare `--key`, "" without it).
static func _user_arg(key: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--" + key:
			return "1"
		if argument.begins_with("--%s=" % key):
			return argument.trim_prefix("--%s=" % key)
	return ""


## The whole frame as large as the window allows, centred. The scale need not be whole (a maximised
## window is about 990 px tall); nearest filtering keeps the pixels square-edged.
func _fit_picture() -> void:
	var window: Vector2 = get_viewport().get_visible_rect().size
	var frame: Vector2 = Vector2(_frame.size)
	var scale: float = minf(window.x / frame.x, window.y / frame.y)
	_picture.size = (frame * scale).floor()
	_picture.position = ((window - _picture.size) * 0.5).floor()
