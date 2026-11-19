extends Node
## The new street Poligon (light engine): a Location built from contract nodes, rendered at the game
## frame and scaled to the window, with an F1 holding the engine panel and the frame switch. Shots
## (F12 or the panel's button) record the frame switch too. The move actions walk the character
## (engine ticket 17); the camera follows it.

## 960×540 as in game2 (×2 on 1080p), or 640×360 as in the engine map's prototypes.
const FRAMES: Array[Vector2i] = [Vector2i(960, 540), Vector2i(640, 360)]
## The camera looks at the character's middle: this far above its feet (half of 72 px).
const CAMERA_ABOVE_FEET_PX: float = 36.0

## Looks of one asset compared in F1 (engine ticket 10: the stall from ComfyUI with its two add-on
## normal maps, and the simple painted sprite); the first is the starting one.
@export var asset_looks: Array[AssetLook] = []
## The sprite whose look the switch changes.
@export var looked_asset: AssetSprite

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
	_shadow_choice.item_selected.connect(func(index: int) -> void: _walker.shadow_shape = index as PoligonWalker.ShadowShape)
	_follow_walker()

	_engine_panel.shot_requested.connect(func() -> void: _shot.take())
	_shot.taken.connect(_engine_panel.show_shot)
	_shot.character = _walker.body()
	_shot.add_switch("kadr", _frame_name, _select_frame)
	_shot.add_switch("widok debug", _debug_view_name, _select_debug_view)
	_shot.add_switch("cień postaci", _shadow_name, _select_shadow)
	_shot.add_switch("góra mapy", _map_top_name, _select_map_top)
	_shot.add_switch("tryb A′", _style_mode_name, _select_style_mode)
	_shot.add_switch("półcień", _penumbra_name, _select_penumbra)
	if not asset_looks.is_empty():
		_shot.add_switch("wygląd assetu", _look_name, _select_look)


func _process(_delta: float) -> void:
	_follow_walker()
	_sort_walker()


## Draws the character before the assets standing nearer the camera than its feet (larger d), so
## the stall in front hides its legs; after the rest of the street.
func _sort_walker() -> void:
	var street: Node = _walker.get_parent()
	var feet_d: float = _walker.position_m().y
	var target: int = 0
	for child: Node in street.get_children():
		if child == _walker:
			continue
		var occluder: Occluder = child as Occluder
		if occluder != null and occluder.asset_sprite() != null and occluder.position_m.y > feet_d:
			break
		target += 1
	if _walker.get_index() != target:
		street.move_child(_walker, target)


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
	_walker.shadow_shape = index as PoligonWalker.ShadowShape


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


## The whole frame as large as the window allows, centred. The scale need not be whole (a maximised
## window is about 990 px tall); nearest filtering keeps the pixels square-edged.
func _fit_picture() -> void:
	var window: Vector2 = get_viewport().get_visible_rect().size
	var frame: Vector2 = Vector2(_frame.size)
	var scale: float = minf(window.x / frame.x, window.y / frame.y)
	_picture.size = (frame * scale).floor()
	_picture.position = ((window - _picture.size) * 0.5).floor()
