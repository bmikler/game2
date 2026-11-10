extends SceneTree
## PROTOTYP (ticket „Przepis postaci”): stojący sprite przeniesiony na paletę klatek animacji tej postaci
## (najbliższy kolor w Lab), żeby stanie i chód były tym samym rodzajem pixel artu (Pixellab daje ~30 kolorów).
##   godot --headless --path style-lab --script tools/postac/paleta_z_klatek.gd -- <stanie.png> <wynik.png> <kl1.png> <kl2.png> ...


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var src: Image = Image.load_from_file(args[0])
	src.convert(Image.FORMAT_RGBA8)
	var pal_c: Array[Color] = []
	var pal_l: Array[Vector3] = []
	var seen: Dictionary = {}
	for i: int in range(2, args.size()):
		var im: Image = Image.load_from_file(args[i])
		im.convert(Image.FORMAT_RGBA8)
		for y: int in im.get_height():
			for x: int in im.get_width():
				var c: Color = im.get_pixel(x, y)
				if c.a > 0.5 and not seen.has(c.to_rgba32()):
					seen[c.to_rgba32()] = true
					pal_c.append(Color(c.r, c.g, c.b, 1.0))
					pal_l.append(_lab(c))
	var out: Image = Image.create(src.get_width(), src.get_height(), false, Image.FORMAT_RGBA8)
	for y: int in src.get_height():
		for x: int in src.get_width():
			var c: Color = src.get_pixel(x, y)
			if c.a <= 0.5:
				continue
			var l: Vector3 = _lab(c)
			var best: int = 0
			var bd: float = INF
			for i: int in pal_l.size():
				var d: float = pal_l[i].distance_squared_to(l)
				if d < bd:
					bd = d
					best = i
			out.set_pixel(x, y, pal_c[best])
	out.save_png(args[1])
	print(args[1].get_file(), ": paleta ", pal_c.size(), " kolorów")
	quit()


func _lin(u: float) -> float:
	return u / 12.92 if u <= 0.04045 else pow((u + 0.055) / 1.055, 2.4)


func _f(t: float) -> float:
	return pow(t, 1.0 / 3.0) if t > 0.008856 else 7.787 * t + 16.0 / 116.0


func _lab(c: Color) -> Vector3:
	var r: float = _lin(c.r)
	var g: float = _lin(c.g)
	var b: float = _lin(c.b)
	var x: float = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
	var y: float = 0.2126 * r + 0.7152 * g + 0.0722 * b
	var z: float = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
	return Vector3(116.0 * _f(y) - 16.0, 500.0 * (_f(x) - _f(y)), 200.0 * (_f(y) - _f(z)))
