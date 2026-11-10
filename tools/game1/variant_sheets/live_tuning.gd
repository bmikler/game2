# Runs Main with a panel of sliders for ticket 27's look decisions (office lamps, monitor, back windows
# by night, wall shadows, snow), to try them live while walking. Like capture_variants.gd it drives the game
# from outside: the game itself has no variant flags (spec §14). Changes are not saved; "Zapisz
# wartości" prints the current values and appends them to user://tuning_values.txt.
# Usage: tools\variant_sheets\run_tuning.bat  (-- --shot=<file.png> saves the window and quits)
extends SceneTree

const SCENE: String = "res://main/main.tscn"
const FONT_SIZE: int = 11
const COLUMNS: int = 5
const CELL_WIDTH: float = 210.0
const VALUES_FILE: String = "user://tuning_values.txt"
## The night glow's colour runs from cold (0) to the profile's warm street-lamp colour (1).
const GLOW_COLD: Color = Color(0.62, 0.72, 1.0)
const SHADOW_MODES: Array[String] = ["pod tylną ścianą", "bez cieni"]

var _station: Station
var _clock: Node
var _lamp: LightFixture
var _monitor: LightFixture
var _windows: WindowLightProfile ## Shared by every back window, as in the game.
var _screen: Sprite2D
var _shadow_mode: int = 0
var _glow_warm: Color
var _glow_warmth: float = 1.0
var _hour_slider: HSlider
## Labels with the value they show: [Label, prefix, Callable returning the value text].
var _readouts: Array[Array] = []


func _initialize() -> void:
	_start()


func _start() -> void:
	var main: Node = (load(SCENE) as PackedScene).instantiate()
	root.add_child(main)
	await process_frame # _ready runs only once the main loop has started
	var view: LitView = main.get_node("World/LitView") as LitView
	_station = view.world as Station
	_clock = main.get_node("%ClockSystem")
	_lamp = _own_def(_station.get_node("Office/Lighting/DeskLamp") as LightFixture)
	_monitor = _own_def(_station.get_node("Office/Lighting/Monitor") as LightFixture)
	_windows = (_station.get_node("Office/Lighting/Window") as WindowLight).profile
	_screen = _glow(_station.get_node("Office/Props/Desk") as Prop)
	_build_panel()
	_set_clock_stopped(true)
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--shot="):
			for _i: int in 10:
				await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(argument.trim_prefix("--shot="))
			quit(0)


func _build_panel() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 100
	root.add_child(layer)
	# Along the bottom, in the black band below the station.
	var panel: PanelContainer = PanelContainer.new()
	var theme: Theme = Theme.new()
	theme.default_font_size = FONT_SIZE
	panel.theme = theme
	layer.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE, Control.PRESET_MODE_MINSIZE)
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var grid: GridContainer = GridContainer.new()
	grid.columns = COLUMNS
	grid.add_theme_constant_override("h_separation", 12)
	panel.add_child(grid)

	var hour_cell: VBoxContainer = _cell(grid, "Godzina", func() -> String:
		var minutes: int = roundi(_station.hour * 60.0)
		return "%02d:%02d" % [floori(minutes / 60.0), minutes % 60])
	_hour_slider = _slider(hour_cell, 0.0, 24.0, 0.05, _station.hour, func(value: float) -> void:
		_station.set_hour(value))
	_check(hour_cell, "Zatrzymaj zegar", true, _set_clock_stopped)

	_slider(_cell(grid, "Lampka biurkowa", func() -> String: return "%d lx" % _lamp.def.lux),
			0.0, 800.0, 10.0, _lamp.def.lux, func(value: float) -> void:
				_lamp.def.lux = value
				_reapply())
	_slider(_cell(grid, "Światło monitora", func() -> String: return "%d lx" % _monitor.def.lux),
			0.0, 480.0, 10.0, _monitor.def.lux, func(value: float) -> void:
				_monitor.def.lux = value
				_reapply())
	if _screen != null:
		_slider(_cell(grid, "Jasność ekranu", func() -> String: return "%.1f" % _screen.modulate.r),
				0.0, 3.0, 0.1, _screen.modulate.r, func(value: float) -> void:
					_screen.modulate = Color(value, value, value))
	_slider(_cell(grid, "Okna: widok nocą ×", func() -> String: return "%.2f" % _windows.night_view_gain),
			0.5, 3.0, 0.05, _windows.night_view_gain, func(value: float) -> void:
				_windows.night_view_gain = value
				_reapply())
	_slider(_cell(grid, "Okna: poświata nocą", func() -> String: return "%d lx" % _windows.night_glow_lux),
			0.0, 150.0, 5.0, _windows.night_glow_lux, func(value: float) -> void:
				_windows.night_glow_lux = value
				_reapply())
	_glow_warm = _windows.night_glow_color
	_slider(_cell(grid, "Okna: barwa poświaty", func() -> String: return "%.2f (0 zimna, 1 ciepła)" % _glow_warmth),
			0.0, 1.0, 0.05, _glow_warmth, func(value: float) -> void:
				_glow_warmth = value
				_windows.night_glow_color = GLOW_COLD.lerp(_glow_warm, value)
				_reapply())
	_slider(_cell(grid, "Okna: widok maks.", func() -> String: return "%.2f" % _windows.view_max),
			0.5, 3.0, 0.05, _windows.view_max, func(value: float) -> void:
				_windows.view_max = value
				_reapply())

	var shadow_cell: VBoxContainer = _cell(grid, "Cienie przy ścianach", Callable())
	var shadows: OptionButton = OptionButton.new()
	shadows.focus_mode = Control.FOCUS_NONE
	for mode: String in SHADOW_MODES:
		shadows.add_item(mode)
	shadows.item_selected.connect(func(index: int) -> void:
		_shadow_mode = index
		_apply_shadows())
	shadow_cell.add_child(shadows)

	var other_cell: VBoxContainer = _cell(grid, "", Callable())
	_check(other_cell, "Śnieg", true, func(on: bool) -> void:
		for window: Node in _station.find_children("*", "WindowLight", true, false):
			(window as WindowLight).snow.visible = on)
	var print_button: Button = Button.new()
	print_button.text = "Zapisz wartości"
	print_button.focus_mode = Control.FOCUS_NONE
	print_button.pressed.connect(_save_summary)
	other_cell.add_child(print_button)
	_update_readouts()


func _process(_delta: float) -> bool:
	if _hour_slider != null:
		_update_readouts()
	return false


func _update_readouts() -> void:
	if not is_equal_approx(_hour_slider.value, _station.hour):
		_hour_slider.set_value_no_signal(_station.hour) # the running clock moves it
	for readout: Array in _readouts:
		var label: Label = readout[0]
		var value: Callable = readout[2]
		label.text = "%s: %s" % [readout[1], value.call()]


func _summary() -> String:
	return "lampka %d lx, monitor %d lx, ekran %.1f, okna: widok nocą ×%.2f, poświata nocą %d lx, barwa poświaty %.2f, widok maks. %.2f, cienie: %s" % [
		_lamp.def.lux, _monitor.def.lux, _screen.modulate.r if _screen != null else 0.0,
		_windows.night_view_gain, _windows.night_glow_lux, _glow_warmth, _windows.view_max, SHADOW_MODES[_shadow_mode]]


## Printed and appended to user://tuning_values.txt, where Claude can read it.
func _save_summary() -> void:
	var line: String = "%s  %s" % [Time.get_datetime_string_from_system(), _summary()]
	print(line)
	var file: FileAccess = FileAccess.open(VALUES_FILE, FileAccess.READ_WRITE if FileAccess.file_exists(VALUES_FILE) else FileAccess.WRITE)
	if file == null:
		push_error("Cannot write %s" % VALUES_FILE)
		return
	file.seek_end()
	file.store_line(line)


func _set_clock_stopped(stopped: bool) -> void:
	_clock.process_mode = Node.PROCESS_MODE_DISABLED if stopped else Node.PROCESS_MODE_INHERIT


## Exposure and light energies follow the new values.
func _reapply() -> void:
	_station.set_hour(_station.hour)


func _apply_shadows() -> void:
	for shell: Node in _station.find_children("*", "RoomShell", true, false):
		for child: Node in shell.get_children():
			var sprite: Sprite2D = child as Sprite2D
			if sprite == null or sprite.z_index != RoomShell.SHADOW_Z:
				continue
			sprite.visible = _shadow_mode == 0


## The fixture gets its own copy of its def, so the shared .tres stays untouched.
static func _own_def(fixture: LightFixture) -> LightFixture:
	fixture.def = fixture.def.duplicate() as FixtureDef
	return fixture


## The prop's unshaded glow sprite (drawn over its lit sprite), or null.
static func _glow(prop: Prop) -> Sprite2D:
	for child: Node in prop.get_children():
		var sprite: Sprite2D = child as Sprite2D
		var material: CanvasItemMaterial = sprite.material as CanvasItemMaterial if sprite != null else null
		if material != null and material.light_mode == CanvasItemMaterial.LIGHT_MODE_UNSHADED:
			return sprite
	return null


## A grid cell with a title; `value` (may be empty) is shown after it and refreshed every frame.
func _cell(grid: GridContainer, title: String, value: Callable) -> VBoxContainer:
	var cell: VBoxContainer = VBoxContainer.new()
	cell.custom_minimum_size = Vector2(CELL_WIDTH, 0)
	grid.add_child(cell)
	var label: Label = Label.new()
	label.text = title
	cell.add_child(label)
	if value.is_valid():
		_readouts.append([label, title, value])
	return cell


func _slider(
		cell: VBoxContainer, low: float, high: float, step: float, value: float, changed: Callable) -> HSlider:
	var slider: HSlider = HSlider.new()
	slider.min_value = low
	slider.max_value = high
	slider.step = step
	slider.value = value
	slider.focus_mode = Control.FOCUS_NONE # arrow keys keep walking the investigator
	slider.value_changed.connect(changed)
	cell.add_child(slider)
	return slider


func _check(cell: VBoxContainer, text: String, on: bool, toggled: Callable) -> CheckBox:
	var check: CheckBox = CheckBox.new()
	check.text = text
	check.button_pressed = on
	check.focus_mode = Control.FOCUS_NONE
	check.toggled.connect(toggled)
	cell.add_child(check)
	return check
