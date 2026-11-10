# PROTOTYP (ticket „Przepis postaci”): porównanie kąta: wycinki głowy i stóp kilku obrazów obok siebie.
# Każdy obraz: tło usunięte po kolorze rogu, postać przeskalowana do tej samej wysokości (H px),
# potem górne i dolne 18% wysokości.
# godot --headless --script wycinki.gd -- <out.png> <H> <a.png> <b.png> ...
extends SceneTree


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var hh := int(a[1])
	var cols: Array[Image] = []
	for i in range(2, a.size()):
		var img := Image.load_from_file(a[i])
		img.convert(Image.FORMAT_RGBA8)
		var bg := img.get_pixel(2, 2)
		for y in img.get_height():
			for x in img.get_width():
				var c := img.get_pixel(x, y)
				if c.a < 0.5 or maxf(maxf(absf(c.r - bg.r), absf(c.g - bg.g)), absf(c.b - bg.b)) < 0.06:
					img.set_pixel(x, y, Color(0, 0, 0, 0))
		img = img.get_region(img.get_used_rect())
		var k := float(hh) / img.get_height()
		img.resize(roundi(img.get_width() * k), hh, Image.INTERPOLATE_LANCZOS)
		var band := roundi(hh * 0.18)
		var col := Image.create(maxi(img.get_width(), 10), band * 2 + 10, false, Image.FORMAT_RGBA8)
		col.fill(Color(0.85, 0.86, 0.88))
		col.blend_rect(img, Rect2i(0, 0, img.get_width(), band), Vector2i.ZERO)
		col.blend_rect(img, Rect2i(0, hh - band, img.get_width(), band), Vector2i(0, band + 10))
		cols.append(col)
	var w := 0
	var h := 0
	for c in cols:
		w += c.get_width() + 20
		h = maxi(h, c.get_height())
	var out := Image.create(w, h, false, Image.FORMAT_RGBA8)
	out.fill(Color(0.3, 0.32, 0.36))
	var x := 0
	for c in cols:
		out.blit_rect(c, Rect2i(Vector2i.ZERO, c.get_size()), Vector2i(x, 0))
		x += c.get_width() + 20
	out.save_png(a[0])
	quit()
