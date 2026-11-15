class_name EnginePanel
extends VBoxContainer
## The engine panel for a Location's F1: hour, time rate, the day state readout and the shot button.
## It only reports changes through signals; whoever embeds it wires them to the LightEngine and the
## EngineShot and calls `show_state` and `show_shot`.
## UI text is Polish (for the human).

signal hour_set(hour: float)
signal rate_set(minutes_per_second: float)
signal shot_requested
signal debug_view_set(view: LightEngine.DebugView)
signal north_at_top_set(north: bool)

const WIDTH: float = 300.0
const RATE_MAX: float = 60.0
const COMPASS: Vector2 = Vector2(64.0, 64.0)
## Debug view names in LightEngine.DebugView order.
const DEBUG_VIEWS: PackedStringArray = ["brak", "Bryły", "Odbiorniki"]
## Map top names: index 1 is north at the top.
const MAP_TOPS: PackedStringArray = ["południe", "północ"]
## Swatch rows: key → Polish label shown in F1.
const SOURCE_LABELS: Dictionary[String, String] = {
	"sun": "słońce", "sky": "niebo", "ambient": "ambient", "ground": "podłoga",
}

var _hour_label: Label
var _hour: HSlider
var _rate_label: Label
var _rate: HSlider
var _readout: Label
var _shot_label: Label
var _debug_view: OptionButton
var _map_top: OptionButton
var _compass: Control
var _swatches: Dictionary[String, ColorRect] = {}
var _swatch_labels: Dictionary[String, Label] = {}
## The sun's direction on the map (x right, d down) and whether it is up, for the compass.
var _sun_on_map: Vector2 = Vector2.ZERO
var _sun_up: bool = false
var _sun_color: Color = Color.WHITE
var _north_up: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2(WIDTH, 0.0)
	var title: Label = Label.new()
	title.text = "Silnik światła"
	add_child(title)

	_hour_label = Label.new()
	add_child(_hour_label)
	_hour = _slider(0.0, 24.0, 0.01)
	_hour.value_changed.connect(func(value: float) -> void: hour_set.emit(value))
	add_child(_hour)

	_rate_label = Label.new()
	add_child(_rate_label)
	_rate = _slider(0.0, RATE_MAX, 0.5)
	_rate.value_changed.connect(func(value: float) -> void:
		_show_rate(value)
		rate_set.emit(value))
	add_child(_rate)

	var row: HBoxContainer = HBoxContainer.new()
	add_child(row)
	_compass = Control.new()
	_compass.custom_minimum_size = COMPASS
	_compass.draw.connect(_draw_compass)
	row.add_child(_compass)
	var swatches: VBoxContainer = VBoxContainer.new()
	row.add_child(swatches)
	for source: String in SOURCE_LABELS:
		var line: HBoxContainer = HBoxContainer.new()
		var swatch: ColorRect = ColorRect.new()
		swatch.custom_minimum_size = Vector2(14.0, 14.0)
		line.add_child(swatch)
		var label: Label = Label.new()
		line.add_child(label)
		swatches.add_child(line)
		_swatches[source] = swatch
		_swatch_labels[source] = label

	_readout = Label.new()
	add_child(_readout)

	var shot: Button = Button.new()
	shot.text = "Zrzut (F12)"
	shot.focus_mode = Control.FOCUS_NONE
	shot.pressed.connect(func() -> void: shot_requested.emit())
	add_child(shot)
	_shot_label = Label.new()
	_shot_label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	_shot_label.custom_minimum_size = Vector2(WIDTH, 0.0)
	add_child(_shot_label)

	_map_top = _choice("Góra mapy", MAP_TOPS)
	_map_top.item_selected.connect(func(index: int) -> void: north_at_top_set.emit(index == 1))
	_debug_view = _choice("Widok debug", DEBUG_VIEWS)
	_debug_view.item_selected.connect(func(index: int) -> void:
		debug_view_set.emit(index as LightEngine.DebugView))


## Sets the rate slider without reporting a change (the engine's starting value).
func set_rate(minutes_per_second: float) -> void:
	_rate.set_value_no_signal(minutes_per_second)
	_show_rate(minutes_per_second)


## The map top choice (the embedder may set it without a signal, e.g. after a replayed shot).
func map_top_choice() -> OptionButton:
	return _map_top


## The debug view choice (the embedder may set it without a signal, e.g. after a replayed shot).
func debug_view_choice() -> OptionButton:
	return _debug_view


## Shows the day state (the embedder calls it on every change).
func show_state(state: DayState) -> void:
	var minutes: int = int(state.hour * 60.0)
	_hour_label.text = "Godzina: %02d:%02d" % [minutes / 60, minutes % 60]
	_hour.set_value_no_signal(state.hour)

	_sun_on_map = Vector2(state.sun_direction.x, state.sun_direction.y).normalized()
	_sun_up = state.sun_elevation > 0.0
	_north_up = state.north_at_top
	_sun_color = state.sun_color
	_compass.queue_redraw()

	_show_swatch("sun", state.sun_color, "%.0f lx" % state.sun_intensity)
	_show_swatch("sky", state.sky_color, "%.0f lx" % state.sky_intensity)
	_show_swatch("ambient", state.ambient_color, "%.0f lx" % state.ambient_intensity)
	var ground: Color = state.floor_light()
	_show_swatch("ground", ground, "%.2f %.2f %.2f" % [ground.r, ground.g, ground.b])

	_readout.text = _decimal_comma(
			"Słońce: wys. %.1f°, azymut %.0f° (%s)\nTarcza %.1f°, zachmurzenie %.0f %%\nEkspozycja ×%.5f" % [
			state.sun_elevation, state.sun_azimuth, _sun_side(state), state.sun_disc,
			state.cloud_cover * 100.0, state.exposure])


## Shows where the last shot went (its path is also on the clipboard).
func show_shot(path: String) -> void:
	_shot_label.text = "Zapisano, ścieżka w schowku:\n%s" % path


func _show_swatch(source: String, color: Color, text: String) -> void:
	var shown: Color = color.clamp()
	shown.a = 1.0
	_swatches[source].color = shown
	_swatch_labels[source].text = _decimal_comma("%s %s" % [SOURCE_LABELS[source], text])


## Where the sun is on screen: with south at the top east is on the left, with north at the top on
## the right.
static func _sun_side(state: DayState) -> String:
	if state.sun_elevation <= 0.0:
		return "pod horyzontem"
	var x: float = state.sun_direction.x
	if absf(x) <= 0.2:
		return "dół, południe" if state.north_at_top else "góra, południe"
	var on_right: bool = x > 0.0
	var side: String = "prawo" if on_right else "lewo"
	var east: bool = on_right == state.north_at_top
	return "%s, %s" % [side, "wschód" if east else "zachód"]


## Top-down map as on screen (south or north at the top); a line to the sun in its colour.
func _draw_compass() -> void:
	var centre: Vector2 = COMPASS * 0.5
	var radius: float = COMPASS.x * 0.5 - 10.0
	_compass.draw_arc(centre, radius, 0.0, TAU, 32, Color(1, 1, 1, 0.4), 1.0)
	var font: Font = get_theme_default_font()
	var top: String = "N" if _north_up else "S"
	var left: String = "W" if _north_up else "E"
	var right: String = "E" if _north_up else "W"
	_compass.draw_string(font, Vector2(centre.x - 4.0, 9.0), top, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
	_compass.draw_string(font, Vector2(0.0, centre.y + 4.0), left, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
	_compass.draw_string(font, Vector2(COMPASS.x - 8.0, centre.y + 4.0), right, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
	var tip: Vector2 = centre + _sun_on_map * radius
	var color: Color = _sun_color.clamp() if _sun_up else Color(0.5, 0.5, 0.6)
	color.a = 1.0
	_compass.draw_line(centre, tip, color, 2.0)
	_compass.draw_circle(tip, 4.0 if _sun_up else 2.0, color)


func _show_rate(minutes_per_second: float) -> void:
	_rate_label.text = _decimal_comma("Tempo: %.1f min gry / s" % minutes_per_second)


## A labelled row with a choice list, added to the panel.
func _choice(label_text: String, items: PackedStringArray) -> OptionButton:
	var row: HBoxContainer = HBoxContainer.new()
	add_child(row)
	var label: Label = Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var choice: OptionButton = OptionButton.new()
	choice.focus_mode = Control.FOCUS_NONE
	for item: String in items:
		choice.add_item(item)
	row.add_child(choice)
	return choice


## Controls never take keyboard focus (keys keep driving the game).
static func _slider(from: float, to: float, step: float) -> HSlider:
	var slider: HSlider = HSlider.new()
	slider.min_value = from
	slider.max_value = to
	slider.step = step
	slider.focus_mode = Control.FOCUS_NONE
	slider.custom_minimum_size = Vector2(WIDTH - 16.0, 0.0)
	return slider


## Polish decimal comma for the UI.
static func _decimal_comma(text: String) -> String:
	return text.replace(".", ",")
