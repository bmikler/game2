extends Node
## The new street Poligon (light engine): a Location built from contract nodes, rendered at the game
## frame and scaled to the window, with an F1 holding the engine panel and the frame switch. Shots
## (F12 or the panel's button) record the frame switch too. Until the character comes, the move
## actions pan the camera over the street.

## 960×540 as in game2 (×2 on 1080p), or 640×360 as in the engine map's prototypes.
const FRAMES: Array[Vector2i] = [Vector2i(960, 540), Vector2i(640, 360)]
## Camera panning speed, screen pixels per second (8 m/s along x).
const PAN_SPEED_PX: float = 320.0

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

## The camera's position before snapping to whole pixels.
var _camera_at: Vector2 = Vector2.ZERO


func _ready() -> void:
	_camera_at = _camera.position
	_picture.texture = _frame.get_texture()
	_engine_panel.hour_set.connect(_engine.set_hour)
	_engine_panel.rate_set.connect(func(rate: float) -> void: _engine.rate = rate)
	_engine_panel.debug_view_set.connect(_engine.set_debug_view)
	_engine_panel.north_at_top_set.connect(_engine.set_north_at_top)
	_engine_panel.full_dither_set.connect(_engine.set_full_dither_px)
	_engine_panel.sky_style_set.connect(_engine.set_sky_style)
	_engine_panel.sky_style_choice().select(_engine.sky_style())
	_engine_panel.full_dither_choice().select(EnginePanel.FULL_DITHER_VARIANTS_PX.find(_engine.full_dither_px()))
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

	_engine_panel.shot_requested.connect(func() -> void: _shot.take())
	_shot.taken.connect(_engine_panel.show_shot)
	_shot.add_switch("kadr", _frame_name, _select_frame)
	_shot.add_switch("widok debug", _debug_view_name, _select_debug_view)
	_shot.add_switch("kamera", _camera_name, _place_camera)
	_shot.add_switch("góra mapy", _map_top_name, _select_map_top)
	_shot.add_switch("dither krótkich kroków", _full_dither_name, _select_full_dither)
	_shot.add_switch("światło nieba", _sky_style_name, _select_sky_style)
	if not asset_looks.is_empty():
		_shot.add_switch("wygląd assetu", _look_name, _select_look)


func _process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if direction != Vector2.ZERO:
		_camera_at += direction * PAN_SPEED_PX * delta
		_camera.position = _camera_at.round()


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


func _camera_name() -> String:
	return "%d;%d" % [roundi(_camera.position.x), roundi(_camera.position.y)]


func _place_camera(camera_name: String) -> void:
	var parts: PackedStringArray = camera_name.split(";")
	if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
		push_warning("Unknown camera in the shot: %s" % camera_name)
		return
	_camera_at = Vector2(parts[0].to_int(), parts[1].to_int())
	_camera.position = _camera_at


func _map_top_name() -> String:
	return EnginePanel.MAP_TOPS[1 if _engine.state().north_at_top else 0]


func _select_map_top(top_name: String) -> void:
	var index: int = EnginePanel.MAP_TOPS.find(top_name)
	if index < 0:
		push_warning("Unknown map top in the shot: %s" % top_name)
		return
	_engine_panel.map_top_choice().select(index)
	_engine.set_north_at_top(index == 1)


func _full_dither_name() -> String:
	return "%d px" % roundi(_engine.full_dither_px())


func _select_full_dither(variant_name: String) -> void:
	var index: int = EnginePanel.full_dither_names().find(variant_name)
	if index < 0:
		push_warning("Unknown short-step dither in the shot: %s" % variant_name)
		return
	_engine_panel.full_dither_choice().select(index)
	_engine.set_full_dither_px(EnginePanel.FULL_DITHER_VARIANTS_PX[index])


func _sky_style_name() -> String:
	return EnginePanel.SKY_STYLES[_engine.sky_style()]


func _select_sky_style(style_name: String) -> void:
	var index: int = EnginePanel.SKY_STYLES.find(style_name)
	if index < 0:
		push_warning("Unknown sky style in the shot: %s" % style_name)
		return
	_engine_panel.sky_style_choice().select(index)
	_engine.set_sky_style(index as TuningSet.SkyStyle)


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
