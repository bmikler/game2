# PROTOTYPE (throwaway): make the flat background of a generated sprite transparent.
# godot --headless --script remove_bg.gd -- <in.png> <out.png> [tolerance]
# Flood-fills from the image edges over pixels close to the top-left corner colour.
extends SceneTree


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var img := Image.load_from_file(a[0])
	img.convert(Image.FORMAT_RGBA8)
	var tol := float(a[2]) if a.size() > 2 else 0.06
	var bg := img.get_pixel(0, 0)
	var w := img.get_width()
	var h := img.get_height()
	var seen := PackedByteArray()
	seen.resize(w * h)
	var stack: Array[Vector2i] = []
	for x in w:
		stack.append(Vector2i(x, 0))
		stack.append(Vector2i(x, h - 1))
	for y in h:
		stack.append(Vector2i(0, y))
		stack.append(Vector2i(w - 1, y))
	var removed := 0
	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h or seen[p.y * w + p.x]:
			continue
		seen[p.y * w + p.x] = 1
		var c := img.get_pixelv(p)
		if c.a > 0.0 and maxf(maxf(absf(c.r - bg.r), absf(c.g - bg.g)), absf(c.b - bg.b)) > tol:
			continue
		img.set_pixelv(p, Color(0, 0, 0, 0))
		removed += 1
		stack.append(p + Vector2i.LEFT)
		stack.append(p + Vector2i.RIGHT)
		stack.append(p + Vector2i.UP)
		stack.append(p + Vector2i.DOWN)
	img.save_png(a[1])
	print("removed ", removed, " used ", img.get_used_rect())
	quit()
