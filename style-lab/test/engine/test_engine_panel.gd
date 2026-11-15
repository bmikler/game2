extends GutTest
## The engine panel: reports hour changes, shows the day state readout.


func _panel() -> EnginePanel:
	var panel: EnginePanel = EnginePanel.new()
	add_child_autofree(panel)
	return panel


func _state(hour: float) -> DayState:
	return DayState.from_hour(load(DayCurves.DEFAULT_PATH) as DayCurves, SkyProfile.new(), hour)


func _text(node: Node) -> String:
	var result: String = ""
	if node is Label:
		result += (node as Label).text + "\n"
	for child: Node in node.get_children():
		result += _text(child)
	return result


func test_morning_readout_shows_the_sun_on_the_left() -> void:
	var panel: EnginePanel = _panel()
	panel.show_state(_state(8.0))
	var text: String = _text(panel)
	assert_string_contains(text, "08:00")
	assert_string_contains(text, "lewo, wschód")


func test_evening_readout_shows_the_sun_on_the_right() -> void:
	var panel: EnginePanel = _panel()
	panel.show_state(_state(17.0))
	assert_string_contains(_text(panel), "prawo, zachód")


func test_night_readout_shows_the_sun_below_the_horizon() -> void:
	var panel: EnginePanel = _panel()
	panel.show_state(_state(23.0))
	assert_string_contains(_text(panel), "pod horyzontem")


func test_hour_slider_reports_the_hour() -> void:
	var panel: EnginePanel = _panel()
	watch_signals(panel)
	var slider: HSlider = panel.find_children("*", "HSlider", true, false)[0] as HSlider
	slider.value = 15.25
	assert_signal_emitted_with_parameters(panel, "hour_set", [15.25])


func test_shot_button_asks_for_a_shot_and_shows_the_path() -> void:
	var panel: EnginePanel = _panel()
	watch_signals(panel)
	var button: Button = panel.find_children("*", "Button", true, false)[0] as Button
	assert_eq(button.text, "Zrzut (F12)")
	button.pressed.emit()
	assert_signal_emitted(panel, "shot_requested")
	panel.show_shot("C:/shots/a.png")
	assert_string_contains(_text(panel), "a.png")
