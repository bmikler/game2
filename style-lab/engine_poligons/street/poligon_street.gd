extends Node
## The new street Poligon (light engine): a Location built from contract nodes, rendered at the game
## frame and scaled to the window, with an F1 holding the engine panel and the frame switch. Shots
## (F12 or the panel's button) record the frame switch too.

## 960×540 as in game2 (×2 on 1080p), or 640×360 as in the engine map's prototypes.
const FRAMES: Array[Vector2i] = [Vector2i(960, 540), Vector2i(640, 360)]

@onready var _frame: SubViewport = %Frame
@onready var _picture: TextureRect = %Picture
@onready var _engine: LightEngine = %Engine
@onready var _f1: CanvasLayer = %F1
@onready var _engine_panel: EnginePanel = %EnginePanel
@onready var _frame_choice: OptionButton = %FrameChoice
@onready var _shot: EngineShot = %Shot


func _ready() -> void:
	_picture.texture = _frame.get_texture()
	_engine_panel.hour_set.connect(_engine.set_hour)
	_engine_panel.rate_set.connect(func(rate: float) -> void: _engine.rate = rate)
	_engine_panel.debug_view_set.connect(_engine.set_debug_view)
	_engine.state_changed.connect(_engine_panel.show_state)
	_engine_panel.set_rate(_engine.rate)
	_engine_panel.show_state(_engine.state())

	for frame: Vector2i in FRAMES:
		_frame_choice.add_item("%d×%d" % [frame.x, frame.y])
	_frame_choice.item_selected.connect(_set_frame)
	_set_frame(0)
	get_viewport().size_changed.connect(_fit_picture)

	_engine_panel.shot_requested.connect(func() -> void: _shot.take())
	_shot.taken.connect(_engine_panel.show_shot)
	_shot.add_switch("kadr", _frame_name, _select_frame)
	_shot.add_switch("widok debug", _debug_view_name, _select_debug_view)


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


func _debug_view_name() -> String:
	return EnginePanel.DEBUG_VIEWS[_engine.debug_view()]


func _select_debug_view(view_name: String) -> void:
	var index: int = EnginePanel.DEBUG_VIEWS.find(view_name)
	if index < 0:
		push_warning("Unknown debug view in the shot: %s" % view_name)
		return
	_engine_panel.debug_view_choice().select(index)
	_engine.set_debug_view(index as LightEngine.DebugView)


## The whole frame as large as the window allows, centred. The scale need not be whole (a maximised
## window is about 990 px tall); nearest filtering keeps the pixels square-edged.
func _fit_picture() -> void:
	var window: Vector2 = get_viewport().get_visible_rect().size
	var frame: Vector2 = Vector2(_frame.size)
	var scale: float = minf(window.x / frame.x, window.y / frame.y)
	_picture.size = (frame * scale).floor()
	_picture.position = ((window - _picture.size) * 0.5).floor()
