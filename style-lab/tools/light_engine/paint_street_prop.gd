extends SceneTree
## Paints simple stand-in sprites (flat albedo, plank lines, a dark rim) for the street Poligon's
## props from a Blender guides export (mask and normals in game pixels), until the furniture recipe
## makes real ones. Run from style-lab:
##   Godot_..._console.exe --headless --path . -s res://tools/light_engine/paint_street_prop.gd -- \
##       <guides export folder> <crate|bench> <output png>

const MASK_FILE: String = "maska_gra.png"
const NORMALS_FILE: String = "normalne_gra.png"
const GUIDES_FILE: String = "bryly.json"
const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")
## The bench's seat front edge above the floor (as in the Blender test bench).
const BENCH_SEAT_M: float = 0.4

const CRATE_TOP: Color = Color("#b48653")
const CRATE_FRONT: Color = Color("#9a6b3f")
const CRATE_GAP: Color = Color("#6e4a2b")
const CRATE_BATTEN: Color = Color("#83592f")
const CRATE_PLANK_PX: int = 6
const CRATE_BATTEN_PX: int = 3
const BENCH_WOOD: Color = Color("#a8743f")
const BENCH_GRAIN: Color = Color("#956535")
const BENCH_IRON: Color = Color("#3d4147")
const RIM: Color = Color("#4a3220")


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() != 3:
		push_error("Usage: -- <guides export folder> <crate|bench> <output png>")
		quit(1)
		return
	var folder: String = args[0]
	var mask: Image = Image.load_from_file(folder.path_join(MASK_FILE))
	var normals: Image = Image.load_from_file(folder.path_join(NORMALS_FILE))
	var anchor: Vector2i = GuidesImport.anchor_px(FileAccess.get_file_as_string(folder.path_join(GUIDES_FILE)))
	var sprite: Image
	match args[1]:
		"crate":
			sprite = _crate(mask, normals)
		"bench":
			sprite = _bench(mask, normals, anchor)
		var unknown:
			push_error("Unknown prop: %s" % unknown)
			quit(1)
			return
	_outline(sprite)
	sprite.save_png(args[2])
	print("painted %s: %s" % [args[1], args[2]])
	quit()


static func _opaque(mask: Image, x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < mask.get_width() and y < mask.get_height() and mask.get_pixel(x, y).a >= 0.5


static func _is_top(normals: Image, x: int, y: int) -> bool:
	return AssetSprite.decode_normal(normals.get_pixel(x, y)).z > 0.7


## Planks along x: horizontal gaps on the front, lighter top with gaps across it.
static func _crate(mask: Image, normals: Image) -> Image:
	var sprite: Image = Image.create_empty(mask.get_width(), mask.get_height(), false, Image.FORMAT_RGBA8)
	var left: int = mask.get_width()
	var right: int = 0
	var bottom: int = 0
	for y: int in mask.get_height():
		for x: int in mask.get_width():
			if _opaque(mask, x, y):
				left = mini(left, x)
				right = maxi(right, x)
				bottom = maxi(bottom, y)
	for y: int in mask.get_height():
		for x: int in mask.get_width():
			if not _opaque(mask, x, y):
				continue
			var color: Color
			if _is_top(normals, x, y):
				color = CRATE_GAP if (x - left) % CRATE_PLANK_PX == CRATE_PLANK_PX - 1 else CRATE_TOP
			elif x - left < CRATE_BATTEN_PX or right - x < CRATE_BATTEN_PX:
				color = CRATE_BATTEN
			else:
				color = CRATE_GAP if (bottom - y) % CRATE_PLANK_PX == CRATE_PLANK_PX - 1 else CRATE_FRONT
			sprite.set_pixel(x, y, color)
	return sprite


## Wooden slats with a little grain; the side legs below the seat in dark iron.
static func _bench(mask: Image, normals: Image, anchor: Vector2i) -> Image:
	var sprite: Image = Image.create_empty(mask.get_width(), mask.get_height(), false, Image.FORMAT_RGBA8)
	# Below the seat's front edge on screen only the legs.
	var seat_row: int = anchor.y - roundi(BENCH_SEAT_M * PROJECTION.px_per_m)
	for y: int in mask.get_height():
		for x: int in mask.get_width():
			if not _opaque(mask, x, y):
				continue
			var color: Color = BENCH_WOOD if (x * 7 + y * 3) % 11 != 0 else BENCH_GRAIN
			if y >= seat_row:
				color = BENCH_IRON
			elif _is_top(normals, x, y) and (x * 5) % 13 == 0:
				color = BENCH_GRAIN
			sprite.set_pixel(x, y, color)
	return sprite


## Darkens the opaque pixels that touch transparent ones (a painted rim, as pixel art has).
static func _outline(sprite: Image) -> void:
	var source: Image = sprite.duplicate()
	for y: int in source.get_height():
		for x: int in source.get_width():
			if not _opaque(source, x, y):
				continue
			for step: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				if not _opaque(source, x + step.x, y + step.y):
					sprite.set_pixel(x, y, source.get_pixel(x, y).lerp(RIM, 0.5))
					break
