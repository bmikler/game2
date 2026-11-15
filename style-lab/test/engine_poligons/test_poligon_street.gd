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
