extends GutTest
## Location → picture (GPU, window off screen): white ground under the engine shines with the hour.


func _read(hour: float) -> Color:
	var view: SubViewport = SubViewport.new()
	view.size = Vector2i(8, 8)
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	view.add_child(LocationEnvironment.new())
	var ground: ColorRect = ColorRect.new()
	ground.color = Color.WHITE
	ground.size = Vector2(8, 8)
	view.add_child(ground)
	var engine: LightEngine = LightEngine.new()
	engine.rate = 0.0
	view.add_child(engine)
	add_child_autofree(view)
	engine.set_hour(hour)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	return view.get_texture().get_image().get_pixel(4, 4)


func test_ground_is_brighter_at_noon_than_at_midnight() -> void:
	var noon: Color = await _read(12.5)
	var midnight: Color = await _read(0.0)
	assert_gt(noon.get_luminance(), midnight.get_luminance() + 0.2)
	assert_gt(midnight.get_luminance(), 0.0, "the night is not black")


func test_ground_is_cool_at_night() -> void:
	var midnight: Color = await _read(0.0)
	assert_gt(midnight.b, midnight.r)
