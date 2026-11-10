class_name DebugPanel
extends CanvasLayer
## The F1 panel: hour slider and time rate, pixel perfect, the Poligon's toggles and variants
## (DebugRegistry) and the screenshot button. It only reports what the user changes; Main acts on it.

signal hour_changed(hour: float)
signal rate_changed(minutes_per_second: float)
signal pixel_perfect_changed(on: bool)
signal screenshot_requested
## A cycling key (F2 angle, F3 px/m, F4 frame) for an option; Main knows which frame applies here.
signal cycle_requested(action: StringName)

const WIDTH: float = 300.0

var _hour: HSlider
var _hour_label: Label
var _rate_label: Label
var _options_box: VBoxContainer
var _setting_hour: bool = false
var _rebuild_queued: bool = false
var _extras: Array[Control] = [] ## Hidden in DebugRegistry.minimal.
var _fps_label: Label
var _fps_time: float = 0.0
var _fps_frames: int = 0
var _fps_worst: float = 0.0


func _ready() -> void:
	layer = 10
	_build()
	DebugRegistry.options_changed.connect(_queue_rebuild)
	_rebuild_options()


## Frames per second over the last half second, the mean and the slowest frame (ms): any drop in
## performance shows at once (the human). With vsync on the rate stops at the screen's.
func _process(delta: float) -> void:
	_fps_time += delta
	_fps_frames += 1
	_fps_worst = maxf(_fps_worst, delta)
	if _fps_time < 0.5:
		return
	_fps_label.text = "Klatki: %d/s (%.1f ms, najdłuższa %.1f ms)" % [
			roundi(_fps_frames / _fps_time), _fps_time * 1000.0 / _fps_frames, _fps_worst * 1000.0]
	_fps_time = 0.0
	_fps_frames = 0
	_fps_worst = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_debug"):
		visible = not visible
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"screenshot"):
		screenshot_requested.emit()
		get_viewport().set_input_as_handled()
	else:
		for action: StringName in [&"cycle_angle", &"cycle_scale", &"cycle_frame"]:
			if event.is_action_pressed(action):
				cycle_requested.emit(action)
				get_viewport().set_input_as_handled()


## Many options change at once (a Poligon adds dozens while it builds): rebuild once, at the frame's end.
func _queue_rebuild() -> void:
	if _rebuild_queued:
		return
	_rebuild_queued = true
	_rebuild_options.call_deferred()


## Shows the options again (after a value changed outside the panel).
func refresh() -> void:
	_rebuild_options()


## Shows the clock (Main calls this as time passes).
func show_time(hour: float, text: String) -> void:
	_hour_label.text = "Godzina: %s" % text
	_setting_hour = true
	_hour.set_value_no_signal(hour)
	_setting_hour = false


func _build() -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.position = Vector2(8, 8)
	panel.custom_minimum_size = Vector2(WIDTH, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)
	var box: VBoxContainer = VBoxContainer.new()
	panel.add_child(box)

	var title: Label = Label.new()
	title.text = "style-lab (F1 ukrywa, F12 zrzut)
F2 kąt, F3 px/m, F4 kadr"
	box.add_child(title)

	_fps_label = Label.new()
	_fps_label.text = "Klatki: …"
	box.add_child(_fps_label)

	_hour_label = Label.new()
	box.add_child(_hour_label)
	_hour = _slider(0.0, 23.99, 0.01)
	_hour.value_changed.connect(func(value: float) -> void:
		if not _setting_hour:
			hour_changed.emit(value))
	box.add_child(_hour)

	_rate_label = Label.new()
	box.add_child(_rate_label)
	var rate: HSlider = _slider(0.0, 60.0, 0.5)
	rate.value_changed.connect(func(value: float) -> void:
		_rate_label.text = "Tempo: %.1f min gry / s" % value
		rate_changed.emit(value))
	box.add_child(rate)
	_extras.append(_rate_label)
	_extras.append(rate)
	rate.value = 1.0

	var pixel: CheckBox = _check("Pixel perfect", true)
	pixel.toggled.connect(func(on: bool) -> void: pixel_perfect_changed.emit(on))
	box.add_child(pixel)
	_extras.append(pixel)

	box.add_child(HSeparator.new())
	_options_box = VBoxContainer.new()
	box.add_child(_options_box)
	box.add_child(HSeparator.new())

	var shot: Button = Button.new()
	shot.text = "Zrzut do shots/"
	shot.focus_mode = Control.FOCUS_NONE
	shot.pressed.connect(func() -> void: screenshot_requested.emit())
	box.add_child(shot)
	_extras.append(shot)


func _rebuild_options() -> void:
	_rebuild_queued = false
	for extra: Control in _extras:
		extra.visible = not DebugRegistry.minimal
	for child: Node in _options_box.get_children():
		child.queue_free()
	for option: DebugOption in DebugRegistry.options():
		var id: StringName = option.id
		if id in DebugRegistry.hidden:
			continue
		if option.is_toggle():
			var check: CheckBox = _check(option.label, option.value == 1)
			check.toggled.connect(func(on: bool) -> void: DebugRegistry.set_value(id, 1 if on else 0))
			_options_box.add_child(check)
			continue
		if option.slider:
			var caption: Label = Label.new()
			var choices: PackedStringArray = option.choices
			var text: String = option.label
			caption.text = "%s: %s" % [text, choices[option.value]]
			_options_box.add_child(caption)
			var bar: HSlider = _slider(0.0, choices.size() - 1, 1.0)
			bar.value = option.value
			bar.value_changed.connect(func(value: float) -> void:
				caption.text = "%s: %s" % [text, choices[int(value)]]
				DebugRegistry.set_value(id, int(value)))
			_options_box.add_child(bar)
			continue
		var row: HBoxContainer = HBoxContainer.new()
		var label: Label = Label.new()
		label.text = option.label
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
		var pick: OptionButton = OptionButton.new()
		pick.focus_mode = Control.FOCUS_NONE
		for choice: String in option.choices:
			pick.add_item(choice)
		pick.select(option.value)
		pick.item_selected.connect(func(index: int) -> void: DebugRegistry.set_value(id, index))
		row.add_child(pick)
		_options_box.add_child(row)


## Controls never take keyboard focus, so WASD and arrows keep moving the player.
static func _slider(from: float, to: float, step: float) -> HSlider:
	var slider: HSlider = HSlider.new()
	slider.min_value = from
	slider.max_value = to
	slider.step = step
	slider.focus_mode = Control.FOCUS_NONE
	slider.custom_minimum_size = Vector2(WIDTH - 16.0, 0)
	return slider


static func _check(text: String, on: bool) -> CheckBox:
	var check: CheckBox = CheckBox.new()
	check.text = text
	check.button_pressed = on
	check.focus_mode = Control.FOCUS_NONE
	return check
