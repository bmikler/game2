extends GutTest
## A shot (button or F12): the frame as PNG, its description next to it, the path on the clipboard.

const FOLDER: String = "user://test_engine_shot"

var _frame_label: String = "960"


func _shot() -> EngineShot:
	var view: SubViewport = SubViewport.new()
	view.size = Vector2i(16, 8)
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var ground: ColorRect = ColorRect.new()
	ground.size = Vector2(16, 8)
	view.add_child(ground)
	var engine: LightEngine = LightEngine.new()
	engine.rate = 0.0
	engine.hour = 7.5
	view.add_child(engine)
	add_child_autofree(view)

	var shot: EngineShot = EngineShot.new()
	shot.frame = view
	shot.engine = engine
	shot.folder = FOLDER
	add_child_autofree(shot)
	shot.add_switch("kadr", func() -> String: return _frame_label,
			func(value: String) -> void: _frame_label = value)
	return shot


func test_shot_saves_the_frame_and_its_description() -> void:
	var shot: EngineShot = _shot()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path: String = shot.take()
	assert_true(FileAccess.file_exists(path), path)
	var image: Image = Image.load_from_file(path)
	assert_eq(image.get_size(), Vector2i(16, 8), "the frame before scaling")
	var description: ShotDescription = ShotDescription.load_next_to(path)
	assert_almost_eq(description.hour, 7.5, 0.0001)
	assert_eq(description.switches, {"kadr": "960"})
	assert_false(description.has_character)


func test_shot_path_goes_to_the_clipboard() -> void:
	var before: String = DisplayServer.clipboard_get()
	var shot: EngineShot = _shot()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path: String = shot.take()
	var clipboard: String = DisplayServer.clipboard_get()
	DisplayServer.clipboard_set(before)
	assert_eq(clipboard, path)
	assert_true(path.is_absolute_path() and not path.begins_with("user://"), "a path the agent can open")


func test_replay_applies_the_hour_and_switches_and_stops_time() -> void:
	var shot: EngineShot = _shot()
	var description: ShotDescription = shot.describe()
	description.hour = 18.25
	description.switches = {"kadr": "640"}
	shot.apply(description)
	assert_almost_eq(shot.engine.hour, 18.25, 0.0001)
	assert_eq(shot.engine.rate, 0.0)
	assert_eq(_frame_label, "640")
	assert_true(shot.describe().matches(description))


func test_screenshot_action_takes_a_shot() -> void:
	var before: String = DisplayServer.clipboard_get()
	var shot: EngineShot = _shot()
	watch_signals(shot)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var press: InputEventAction = InputEventAction.new()
	press.action = &"screenshot"
	press.pressed = true
	Input.parse_input_event(press)
	await get_tree().process_frame
	DisplayServer.clipboard_set(before)
	assert_signal_emitted(shot, "taken")
