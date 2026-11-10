# PROTOTYP (ticket „Przepis postaci”): arkusz obok siebie, powiększenie nearest.
# godot --headless --script arkusz.gd -- <out.png> <skala> <a.png> <b.png> ...
extends SceneTree


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var k := float(a[1])
	var imgs: Array[Image] = []
	for i in range(2, a.size()):
		var im := Image.load_from_file(a[i])
		im.convert(Image.FORMAT_RGBA8)
		im.resize(roundi(im.get_width() * k), roundi(im.get_height() * k), Image.INTERPOLATE_NEAREST if k >= 1.0 else Image.INTERPOLATE_LANCZOS)
		imgs.append(im)
	var w := 0
	var h := 0
	for im in imgs:
		w += im.get_width() + 8
		h = maxi(h, im.get_height())
	var out := Image.create(w, h, false, Image.FORMAT_RGBA8)
	out.fill(Color(0.55, 0.58, 0.62))
	var x := 0
	for im in imgs:
		out.blend_rect(im, Rect2i(Vector2i.ZERO, im.get_size()), Vector2i(x, 0))
		x += im.get_width() + 8
	out.save_png(a[0])
	quit()
