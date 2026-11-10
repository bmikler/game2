# PROTOTYP (ticket „Przepis postaci”): postać wycięta z tła (alfa albo kolor rogu) i przeskalowana do wysokości H,
# do porównań w HTML (wspólna wysokość, stopy na dole obrazu).
# godot --headless --path . --script tools/postac/wyrownaj.gd -- <H> <in.png> <out.png> [<in2.png> <out2.png> ...]
extends SceneTree


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var hh := int(a[0])
	for i in range(1, a.size() - 1, 2):
		_one(a[i], a[i + 1], hh)
	quit()


func _one(src: String, dst: String, hh: int) -> void:
	var img := Image.load_from_file(src)
	img.convert(Image.FORMAT_RGBA8)
	var bg := img.get_pixel(2, 2)
	if bg.a >= 0.5:
		for y in img.get_height():
			for x in img.get_width():
				var c := img.get_pixel(x, y)
				if maxf(maxf(absf(c.r - bg.r), absf(c.g - bg.g)), absf(c.b - bg.b)) < 0.06:
					img.set_pixel(x, y, Color(0, 0, 0, 0))
	img = img.get_region(img.get_used_rect())
	var k := float(hh) / img.get_height()
	img.resize(maxi(1, roundi(img.get_width() * k)), hh, Image.INTERPOLATE_LANCZOS)
	img.save_png(dst)
