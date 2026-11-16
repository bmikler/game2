extends SceneTree
## Furniture recipe: the normal map of a generated furniture sprite. Model pixels (the Blender mask) keep
## Blender's normals; add-on pixels (opaque in the sprite, outside the mask: goods on the top, a cloth
## hanging over the edge) get their own: inflated from the add-on's silhouette (height from the distance
## to the region's edge, normal from its slope: towards the camera inside, outwards at the edge), or one
## flat normal towards the camera. One rule for every add-on. Run from style-lab:
##   Godot_..._console.exe --headless --path . -s res://tools/meble/addon_normals.gd -- \
##       <guides export folder> <sprite png> <output folder>
## Writes normals_inflated.png and normals_flat.png (encoding of Prowadnice v2: 128 + 127·(nx, nz, −ny)).

enum Mode { INFLATED, FLAT }

const MASK_FILE: String = "maska_gra.png"
const NORMALS_FILE: String = "normalne_gra.png"
const OUTPUTS: Dictionary[Mode, String] = {Mode.INFLATED: "normals_inflated.png", Mode.FLAT: "normals_flat.png"}
## Add-ons round off over this many game pixels from their edge; further in they face the camera.
const INFLATE_RADIUS_PX: float = 3.0
const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() != 3:
		push_error("Usage: -- <guides export folder> <sprite png> <output folder>")
		quit(1)
		return
	var mask: Image = Image.load_from_file(args[0].path_join(MASK_FILE))
	var normals: Image = Image.load_from_file(args[0].path_join(NORMALS_FILE))
	var sprite: Image = Image.load_from_file(args[1])
	for mode: Mode in OUTPUTS:
		var path: String = args[2].path_join(OUTPUTS[mode])
		fill(sprite, mask, normals, mode).save_png(path)
		print("add-on normals: %s" % path)
	quit()


## The normal map for `sprite`: Blender's `normals` under `mask`, add-on normals by `mode` elsewhere.
static func fill(sprite: Image, mask: Image, normals: Image, mode: Mode) -> Image:
	var result: Image = Image.create_empty(sprite.get_width(), sprite.get_height(), false, Image.FORMAT_RGBA8)
	var camera: Vector3 = PROJECTION.toward_camera()
	# Screen right and screen up, across the line of sight.
	var screen_right: Vector3 = Vector3.RIGHT
	var screen_up: Vector3 = Vector3(0.0, -camera.z, camera.y)
	var heights: Image = _heights(sprite, mask) if mode == Mode.INFLATED else null
	for y: int in sprite.get_height():
		for x: int in sprite.get_width():
			if not _opaque(sprite, x, y):
				continue
			if _opaque(mask, x, y):
				result.set_pixel(x, y, normals.get_pixel(x, y))
				continue
			var normal: Vector3 = camera
			if heights != null:
				var slope_right: float = (_height(heights, x + 1, y) - _height(heights, x - 1, y)) * 0.5
				var slope_up: float = (_height(heights, x, y - 1) - _height(heights, x, y + 1)) * 0.5
				normal = (camera - slope_right * screen_right - slope_up * screen_up).normalized()
			result.set_pixel(x, y, encode(normal))
	return result


## Heights of the add-on pixels (opaque in the sprite, outside the mask), in pixels: a quarter circle
## of INFLATE_RADIUS_PX over the distance from the region's edge; 0 outside the region.
static func _heights(sprite: Image, mask: Image) -> Image:
	var heights: Image = Image.create_empty(sprite.get_width(), sprite.get_height(), false, Image.FORMAT_RF)
	var reach: int = ceili(INFLATE_RADIUS_PX) + 1
	for y: int in sprite.get_height():
		for x: int in sprite.get_width():
			if not _is_addon(sprite, mask, x, y):
				continue
			var nearest: float = float(reach)
			for dy: int in range(-reach, reach + 1):
				for dx: int in range(-reach, reach + 1):
					if not _is_addon(sprite, mask, x + dx, y + dy):
						nearest = minf(nearest, Vector2(dx, dy).length())
			var inside: float = minf(nearest - 0.5, INFLATE_RADIUS_PX)
			var height: float = sqrt(INFLATE_RADIUS_PX ** 2 - (INFLATE_RADIUS_PX - inside) ** 2)
			heights.set_pixel(x, y, Color(height, 0.0, 0.0))
	return heights


static func _height(heights: Image, x: int, y: int) -> float:
	if x < 0 or y < 0 or x >= heights.get_width() or y >= heights.get_height():
		return 0.0
	return heights.get_pixel(x, y).r


static func _is_addon(sprite: Image, mask: Image, x: int, y: int) -> bool:
	return _opaque(sprite, x, y) and not _opaque(mask, x, y)


## A unit normal in the engine's axes (x right, d towards the camera, z up) → a normal map pixel.
static func encode(normal: Vector3) -> Color:
	var channels: Vector3 = Vector3(normal.x, normal.z, normal.y) * AssetSprite.NORMAL_SCALE + Vector3.ONE * AssetSprite.NORMAL_ZERO
	return Color8(roundi(channels.x), roundi(channels.y), roundi(channels.z))


static func _opaque(image: Image, x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height() and image.get_pixel(x, y).a >= 0.5
