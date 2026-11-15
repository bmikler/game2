extends GutTest
## The new street Poligon: frame, F1 with the engine panel, a Location with its environment.

const SCENE: String = "res://engine_poligons/street/poligon_street.tscn"


func _poligon() -> Node:
	var poligon: Node = (load(SCENE) as PackedScene).instantiate()
	add_child_autofree(poligon)
	return poligon


func test_location_has_an_environment_and_the_engine_no_warnings() -> void:
	var engine: LightEngine = _poligon().get_node("%Engine") as LightEngine
	assert_true(engine.warnings().is_empty(), str(engine.warnings()))


func test_frame_starts_at_960_and_switches_to_640_keeping_the_centre() -> void:
	var poligon: Node = _poligon()
	var frame: SubViewport = poligon.get_node("%Frame") as SubViewport
	var choice: OptionButton = poligon.get_node("%FrameChoice") as OptionButton
	assert_eq(frame.size, Vector2i(960, 540))
	await get_tree().process_frame
	var centre: Vector2 = frame.get_camera_2d().get_screen_center_position()
	choice.select(1)
	choice.item_selected.emit(1)
	await get_tree().process_frame
	assert_eq(frame.size, Vector2i(640, 360))
	assert_eq(frame.get_camera_2d().get_screen_center_position(), centre)


func test_engine_panel_sets_the_engine_hour() -> void:
	var poligon: Node = _poligon()
	var engine: LightEngine = poligon.get_node("%Engine") as LightEngine
	var panel: EnginePanel = poligon.get_node("%EnginePanel") as EnginePanel
	panel.hour_set.emit(18.0)
	assert_almost_eq(engine.hour, 18.0, 0.0001)


func test_shot_describes_the_scene_hour_and_frame_switch() -> void:
	var shot: EngineShot = _poligon().get_node("%Shot") as EngineShot
	var description: ShotDescription = shot.describe()
	assert_eq(description.scene, SCENE)
	assert_almost_eq(description.hour, 7.5, 0.05)
	assert_eq(description.switches, {"kadr": "960×540", "widok debug": "brak", "kamera": "0;-200"})


func test_replayed_shot_matches_its_description() -> void:
	var original: Node = _poligon()
	(original.get_node("%Engine") as LightEngine).set_hour(19.75)
	var choice: OptionButton = original.get_node("%FrameChoice") as OptionButton
	choice.select(1)
	choice.item_selected.emit(1)
	var description: ShotDescription = (original.get_node("%Shot") as EngineShot).describe()

	var replay: Node = _poligon()
	(replay.get_node("%Shot") as EngineShot).apply(description)
	assert_eq((replay.get_node("%Frame") as SubViewport).size, Vector2i(640, 360))
	assert_almost_eq((replay.get_node("%Engine") as LightEngine).hour, 19.75, 0.0001)
	assert_true((replay.get_node("%Shot") as EngineShot).describe().matches(description))


func test_engine_panel_shot_button_takes_a_shot() -> void:
	var poligon: Node = _poligon()
	var shot: EngineShot = poligon.get_node("%Shot") as EngineShot
	shot.folder = "user://test_poligon_street_shots"
	var before: String = DisplayServer.clipboard_get()
	watch_signals(shot)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	(poligon.get_node("%EnginePanel") as EnginePanel).shot_requested.emit()
	DisplayServer.clipboard_set(before)
	assert_signal_emitted(shot, "taken")


func test_the_alley_has_a_two_metre_gap_between_tenement_houses() -> void:
	var engine: LightEngine = _poligon().get_node("%Engine") as LightEngine
	var gaps: Array[float] = []
	var houses: Array[AABB] = []
	for box: AABB in engine.scene_description().solids:
		if box.size.z > 1.0:
			houses.append(box)
	houses.sort_custom(func(a: AABB, b: AABB) -> bool: return a.position.x < b.position.x)
	for index: int in range(1, houses.size()):
		gaps.append(houses[index].position.x - houses[index - 1].end.x)
	assert_has(gaps, 2.0)


func test_debug_view_from_f1_reaches_the_engine_and_the_shot() -> void:
	var poligon: Node = _poligon()
	var choice: OptionButton = (poligon.get_node("%EnginePanel") as EnginePanel).debug_view_choice()
	choice.select(1)
	choice.item_selected.emit(1)
	assert_eq((poligon.get_node("%Engine") as LightEngine).debug_view(), LightEngine.DebugView.SOLIDS)
	var description: ShotDescription = (poligon.get_node("%Shot") as EngineShot).describe()
	assert_eq(description.switches["widok debug"], "Bryły")
	var replay: Node = _poligon()
	(replay.get_node("%Shot") as EngineShot).apply(description)
	assert_eq((replay.get_node("%Engine") as LightEngine).debug_view(), LightEngine.DebugView.SOLIDS)


func test_move_actions_pan_the_camera_and_the_shot_keeps_it() -> void:
	var poligon: Node = _poligon()
	var camera: Camera2D = (poligon.get_node("%Frame") as SubViewport).get_camera_2d()
	var start: Vector2 = camera.position
	Input.action_press(&"move_right")
	Input.action_press(&"move_up")
	for frame: int in 5:
		await get_tree().process_frame
	Input.action_release(&"move_right")
	Input.action_release(&"move_up")
	assert_gt(camera.position.x, start.x, "right")
	assert_lt(camera.position.y, start.y, "up")
	assert_eq(camera.position, camera.position.round(), "whole pixels")
	var description: ShotDescription = (poligon.get_node("%Shot") as EngineShot).describe()
	var replay: Node = _poligon()
	(replay.get_node("%Shot") as EngineShot).apply(description)
	assert_eq((replay.get_node("%Frame") as SubViewport).get_camera_2d().position, camera.position)
