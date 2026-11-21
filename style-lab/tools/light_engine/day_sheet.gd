extends SceneTree
## The day sheet (engine ticket 29): a Poligon's frame at evenly spaced hours as thumbnails with
## their clock time, in one PNG, for a quick look at the whole day. Run with `node tools/day_sheet.mjs`
## (from style-lab), which imports the project first; rendering needs a window (not --headless):
##   Godot_..._console.exe --path . --resolution 64x64 --position -3000,-3000 \
##       -s res://tools/light_engine/day_sheet.gd -- <count> <output .png> [scene]

const DEFAULT_SCENE: String = "res://engine_poligons/street/poligon_street.tscn"
## Thumbnails are a quarter of the 960 × 540 frame.
const THUMB_SCALE: float = 0.25
const COLUMNS: int = 6
const LABEL_HEIGHT: int = 16


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() < 2:
		push_error("Usage: -- <count> <output .png> [scene]")
		quit(1)
		return
	_make(args[0].to_int(), args[1], args[2] if args.size() > 2 else DEFAULT_SCENE)


func _make(count: int, output: String, scene_path: String) -> void:
	count = clampi(count, 1, 48)
	var poligon: Node = (load(scene_path) as PackedScene).instantiate()
	root.add_child(poligon)
	var engine: LightEngine = poligon.get_node("%Engine") as LightEngine
	var frame: SubViewport = poligon.get_node("%Frame") as SubViewport
	engine.rate = 0.0
	# The engine builds its buffer in _ready, after this frame.
	await process_frame
	while not engine.is_complete():
		await RenderingServer.frame_post_draw
	var thumb_size: Vector2i = Vector2i((Vector2(frame.size) * THUMB_SCALE).round())
	var sheet: SubViewport = SubViewport.new()
	var rows: int = ceili(float(count) / COLUMNS)
	sheet.size = Vector2i(thumb_size.x * mini(count, COLUMNS), (thumb_size.y + LABEL_HEIGHT) * rows)
	sheet.render_target_update_mode = SubViewport.UPDATE_DISABLED
	var background: ColorRect = ColorRect.new()
	background.color = Color.BLACK
	background.size = Vector2(sheet.size)
	sheet.add_child(background)
	for index: int in count:
		var hour: float = DayState.DAY_H * index / count
		engine.set_hour(hour)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var image: Image = frame.get_texture().get_image()
		image.resize(thumb_size.x, thumb_size.y, Image.INTERPOLATE_NEAREST)
		var at: Vector2 = Vector2((index % COLUMNS) * thumb_size.x, (index / COLUMNS) * (thumb_size.y + LABEL_HEIGHT))
		var picture: TextureRect = TextureRect.new()
		picture.texture = ImageTexture.create_from_image(image)
		picture.position = at + Vector2(0.0, LABEL_HEIGHT)
		sheet.add_child(picture)
		var label: Label = Label.new()
		label.text = DaySweep.clock(hour)
		label.position = at + Vector2(4.0, -2.0)
		label.add_theme_font_size_override(&"font_size", 12)
		sheet.add_child(label)
	poligon.queue_free()
	root.add_child(sheet)
	sheet.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	var error: Error = sheet.get_texture().get_image().save_png(output)
	if error != OK:
		push_error("Cannot save %s: %s" % [output, error_string(error)])
		quit(1)
		return
	print("Day sheet: %d hours → %s" % [count, ProjectSettings.globalize_path(output)])
	quit(0)
