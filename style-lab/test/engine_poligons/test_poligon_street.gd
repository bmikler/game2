extends GutTest
## The new street Poligon: frame, F1 with the engine panel, a Location with its environment.

const PoligonStreet := preload("res://engine_poligons/street/poligon_street.gd")
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
	assert_eq(description.switches, {"kadr": "960×540", "widok debug": "brak", "cień postaci": "bryła z sylwetki", "NPC": "brak", "kierunek postaci": "2", "góra mapy": "południe",
			"tryb A′": "na sumie", "półcień": "z geometrii (t14)", "wygląd assetu": "ComfyUI, dodatki nadmuchane"})


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
	var alley: Occluder = _poligon().get_node("Frame/Street/Alley") as Occluder
	var gaps: Array[float] = []
	var houses: Array[AABB] = []
	for shape: SolidShape in alley.world_shapes():
		houses.append(shape.box)
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


func test_move_actions_walk_the_character_the_camera_follows_and_the_shot_keeps_it() -> void:
	var poligon: Node = _poligon()
	var camera: Camera2D = (poligon.get_node("%Frame") as SubViewport).get_camera_2d()
	var body: Occluder = (poligon.get_node("%Walker") as PoligonWalker).body()
	var start: Vector2 = body.position
	Input.action_press(&"move_right")
	Input.action_press(&"move_up")
	for frame: int in 5:
		await get_tree().process_frame
	Input.action_release(&"move_right")
	Input.action_release(&"move_up")
	await get_tree().process_frame
	assert_gt(body.position.x, start.x, "right")
	assert_lt(body.position.y, start.y, "up")
	assert_eq(camera.position, (body.position - Vector2(0.0, 36.0)).round(), "the camera on the character, whole pixels")
	var description: ShotDescription = (poligon.get_node("%Shot") as EngineShot).describe()
	assert_true(description.has_character)
	var replay: Node = _poligon()
	(replay.get_node("%Shot") as EngineShot).apply(description)
	await get_tree().process_frame
	var replayed: PoligonWalker = replay.get_node("%Walker") as PoligonWalker
	assert_almost_eq(replayed.position_m().x, (poligon.get_node("%Walker") as PoligonWalker).position_m().x, 0.03)
	assert_eq((replay.get_node("%Frame") as SubViewport).get_camera_2d().position, camera.position)


func test_character_shadow_shape_from_f1_reaches_the_walker_and_the_shot() -> void:
	var poligon: Node = _poligon()
	var choice: OptionButton = poligon.get_node("%ShadowChoice") as OptionButton
	choice.select(0)
	choice.item_selected.emit(0)
	var walker: PoligonWalker = poligon.get_node("%Walker") as PoligonWalker
	assert_eq(walker.shadow_shape, PoligonWalker.ShadowShape.CYLINDER)
	var description: ShotDescription = (poligon.get_node("%Shot") as EngineShot).describe()
	assert_eq(description.switches["cień postaci"], "walec")
	var replay: Node = _poligon()
	(replay.get_node("%Shot") as EngineShot).apply(description)
	assert_eq((replay.get_node("%Walker") as PoligonWalker).shadow_shape, PoligonWalker.ShadowShape.CYLINDER)


func test_npcs_from_f1_walk_as_moving_occluders_and_reach_the_shot() -> void:
	var poligon: Node = _poligon()
	var engine: LightEngine = poligon.get_node("%Engine") as LightEngine
	assert_eq(engine.scene_description().moving_assets.size(), 1, "only the player without NPCs")
	var check: CheckBox = poligon.get_node("%NpcCheck") as CheckBox
	check.button_pressed = true
	assert_eq(engine.scene_description().moving_assets.size(), 3, "the player and two NPCs")
	var npc: PoligonWalker = poligon.get_node("Frame/Street/Npc1") as PoligonWalker
	var start: Vector3 = npc.position_m()
	for _frame: int in 10:
		await get_tree().process_frame
	assert_ne(npc.position_m(), start, "an NPC walks its routine")
	var description: ShotDescription = (poligon.get_node("%Shot") as EngineShot).describe()
	assert_eq(description.switches["NPC"], "2 na rutynie")
	check.button_pressed = false
	assert_eq(engine.scene_description().moving_assets.size(), 1, "the NPCs leave")
	var replay: Node = _poligon()
	(replay.get_node("%Shot") as EngineShot).apply(description)
	assert_true((replay.get_node("%NpcCheck") as CheckBox).button_pressed)


func test_map_top_from_f1_reaches_the_engine_and_the_shot() -> void:
	var poligon: Node = _poligon()
	var choice: OptionButton = (poligon.get_node("%EnginePanel") as EnginePanel).map_top_choice()
	choice.select(1)
	choice.item_selected.emit(1)
	var engine: LightEngine = poligon.get_node("%Engine") as LightEngine
	assert_true(engine.state().north_at_top)
	var description: ShotDescription = (poligon.get_node("%Shot") as EngineShot).describe()
	assert_eq(description.switches["góra mapy"], "północ")
	var replay: Node = _poligon()
	(replay.get_node("%Shot") as EngineShot).apply(description)
	assert_true((replay.get_node("%Engine") as LightEngine).state().north_at_top)


func test_look_switch_gives_the_stall_each_look_and_the_engine_reads_it() -> void:
	var poligon: Node = _poligon()
	var engine: LightEngine = poligon.get_node("%Engine") as LightEngine
	var choice: OptionButton = poligon.get_node("%LookChoice") as OptionButton
	var sprite: AssetSprite = poligon.get_node("Frame/Street/Stall/Sprite") as AssetSprite
	var looks: Array[AssetLook] = (poligon as PoligonStreet).asset_looks
	assert_eq(choice.item_count, 3)
	for index: int in choice.item_count:
		choice.select(index)
		choice.item_selected.emit(index)
		var look: AssetLook = looks[index]
		assert_eq(sprite.texture, look.sprite)
		var normal_maps: Array[Texture2D] = []
		for entry: AssetEntry in engine.scene_description().assets:
			normal_maps.append(entry.normal_map)
		assert_has(normal_maps, look.normal_map, "the engine's scene has look %s" % look.look_name)
	assert_true(engine.warnings().is_empty(), str(engine.warnings()))


func test_replayed_shot_keeps_the_stall_look() -> void:
	var original: Node = _poligon()
	var choice: OptionButton = original.get_node("%LookChoice") as OptionButton
	choice.select(2)
	choice.item_selected.emit(2)
	var description: ShotDescription = (original.get_node("%Shot") as EngineShot).describe()
	assert_eq(description.switches["wygląd assetu"], "prosty sprite")
	var replay: Node = _poligon()
	(replay.get_node("%Shot") as EngineShot).apply(description)
	assert_eq((replay.get_node("%LookChoice") as OptionButton).selected, 2)


func test_style_mode_from_f1_reaches_the_engine_and_the_shot() -> void:
	var poligon: Node = _poligon()
	var choice: OptionButton = (poligon.get_node("%EnginePanel") as EnginePanel).style_mode_choice()
	var engine: LightEngine = poligon.get_node("%Engine") as LightEngine
	assert_eq(choice.selected, engine.tuning_set().style_mode, "F1 starts at the tuning set's mode")
	assert_true((choice.get_parent() as Control).visible, "shown: the street has lamps (an artificial channel)")
	choice.select(1)
	choice.item_selected.emit(1)
	assert_eq(engine.style_mode(), TuningSet.StyleMode.PER_CHANNEL)
	assert_eq(engine.tuning_set().style_mode, TuningSet.StyleMode.SUM, "the set itself stays")
	var description: ShotDescription = (poligon.get_node("%Shot") as EngineShot).describe()
	assert_eq(description.switches["tryb A′"], "na kanałach")
	var replay: Node = _poligon()
	(replay.get_node("%Shot") as EngineShot).apply(description)
	assert_eq((replay.get_node("%Engine") as LightEngine).style_mode(), TuningSet.StyleMode.PER_CHANNEL)


func test_the_shop_has_its_lamps_and_lit_windows() -> void:
	var poligon: Node = _poligon()
	var description: SceneDescription = (poligon.get_node("%Engine") as LightEngine).scene_description()
	var by_profile: Dictionary[String, int] = {}
	for source: SourceEntry in description.sources:
		var profile_name: String = source.profile.resource_path.get_file().get_basename()
		var count: int = by_profile.get(profile_name, 0)
		by_profile[profile_name] = count + 1
	var street_lamps: int = by_profile.get("street_lamp", 0)
	var wall_lamps: int = by_profile.get("wall_lamp", 0)
	var windows: int = by_profile.get("lit_window", 0)
	assert_eq(street_lamps, 3, "three street lamps")
	assert_eq(wall_lamps, 1, "a lamp over the shop door")
	assert_gt(windows, 1, "the shop window and lit windows above")
	assert_eq(description.source_groups.size(), 3, "one layer per profile")
