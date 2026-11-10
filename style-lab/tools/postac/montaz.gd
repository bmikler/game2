# PROTOTYP (ticket „Przepis postaci”): obrazy obok siebie w jednym rzędzie, przeskalowane do wysokości H.
# godot --headless --path . --script tools/postac/montaz.gd -- <out.png> <H> <a.png> <b.png> ...
extends SceneTree


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var hh := int(a[1])
	var imgs: Array[Image] = []
	var w := 0
	for i in range(2, a.size()):
		var img := Image.load_from_file(a[i])
		img.convert(Image.FORMAT_RGBA8)
		img.resize(maxi(1, roundi(img.get_width() * float(hh) / img.get_height())), hh, Image.INTERPOLATE_LANCZOS)
		imgs.append(img)
		w += img.get_width() + 8
	var out := Image.create(w, hh, false, Image.FORMAT_RGBA8)
	out.fill(Color(0.3, 0.32, 0.36))
	var x := 0
	for img in imgs:
		out.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(x, 0))
		x += img.get_width() + 8
	out.save_png(a[0])
	quit()
