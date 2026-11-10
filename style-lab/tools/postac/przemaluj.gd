extends SceneTree
## PROTOTYP (ticket „Przepis postaci”): klatki animacji z Pixellab (szablon) sprowadzone do naszego sprite'a.
## 1) wspólna skala wszystkich klatek do wysokości wzoru (Lanczos, stopy na wierszu stóp wzoru, środek x jak wzór),
## 2) przeniesienie koloru w Lab (średnia i odchylenie kanałów, Reinhard), 3) kwantyzacja do palety wzoru.
##   godot --headless --path style-lab --script tools/postac/przemaluj.gd -- <wzór.png> <prefiks_wyjścia> <kl0.png> <kl1.png> ...
## Wynik: <prefiks_wyjścia><i>.png (płótno jak wzór).

const ALPHA_CUT: float = 0.5


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var ref: Image = Image.load_from_file(args[0])
	ref.convert(Image.FORMAT_RGBA8)
	var out_prefix: String = args[1]
	var frames: Array[Image] = []
	for i: int in range(2, args.size()):
		var im: Image = Image.load_from_file(args[i])
		im.convert(Image.FORMAT_RGBA8)
		frames.append(im)

	# 1) skala: najwyższa postać w klatkach = wysokość wzoru.
	var rb: Rect2i = _bbox(ref)
	var top: int = 1 << 20
	var bot: int = -1
	var cx_sum: float = 0.0
	for im: Image in frames:
		var b: Rect2i = _bbox(im)
		top = mini(top, b.position.y)
		bot = maxi(bot, b.end.y)
	var b0: Rect2i = _bbox(frames[0])
	cx_sum = b0.position.x + b0.size.x * 0.5
	var k: float = float(rb.size.y) / float(bot - top)
	print("skala ", snappedf(k, 0.001), " (wzór ", rb.size.y, " px, klatki ", bot - top, " px)")
	var w: int = ref.get_width()
	var h: int = ref.get_height()
	var scaled: Array[Image] = []
	for im: Image in frames:
		var big: Image = im.duplicate()
		big.resize(roundi(im.get_width() * k), roundi(im.get_height() * k), Image.INTERPOLATE_LANCZOS)
		var canvas: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
		# stopy (bot*k) → rb.end.y, środek klatki 0 → środek wzoru
		var dx: int = roundi(rb.position.x + rb.size.x * 0.5 - cx_sum * k)
		var dy: int = roundi(rb.end.y - bot * k)
		canvas.blend_rect(big, Rect2i(0, 0, big.get_width(), big.get_height()), Vector2i(dx, dy))
		scaled.append(canvas)

	# 2) statystyki Lab
	var ref_px: Array[Vector3] = _lab_pixels(ref)
	var src_px: Array[Vector3] = []
	for im: Image in scaled:
		src_px.append_array(_lab_pixels(im))
	var mr: Vector3 = _mean(ref_px)
	var sr: Vector3 = _std(ref_px, mr)
	var ms: Vector3 = _mean(src_px)
	var ss: Vector3 = _std(src_px, ms)
	print("Lab wzór ", mr, sr, " klatki ", ms, ss)

	# 3) paleta wzoru (unikalne kolory)
	var pal_c: Array[Color] = []
	var pal_l: Array[Vector3] = []
	var seen: Dictionary = {}
	for y: int in h:
		for x: int in w:
			var c: Color = ref.get_pixel(x, y)
			if c.a > ALPHA_CUT and not seen.has(c.to_rgba32()):
				seen[c.to_rgba32()] = true
				pal_c.append(Color(c.r, c.g, c.b, 1.0))
				pal_l.append(_lab(c))
	print("paleta wzoru: ", pal_c.size(), " kolorów")

	for n: int in scaled.size():
		var im: Image = scaled[n]
		var out: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
		for y: int in h:
			for x: int in w:
				var c: Color = im.get_pixel(x, y)
				if c.a <= ALPHA_CUT:
					continue
				var l: Vector3 = (_lab(c) - ms) / ss * sr + mr
				var best: int = 0
				var bd: float = INF
				for i: int in pal_l.size():
					var d: float = pal_l[i].distance_squared_to(l)
					if d < bd:
						bd = d
						best = i
				out.set_pixel(x, y, pal_c[best])
		out.save_png("%s%d.png" % [out_prefix, n])
	print("zapisano ", scaled.size(), " klatek")
	quit()


func _bbox(im: Image) -> Rect2i:
	var x0: int = im.get_width()
	var y0: int = im.get_height()
	var x1: int = -1
	var y1: int = -1
	for y: int in im.get_height():
		for x: int in im.get_width():
			if im.get_pixel(x, y).a > ALPHA_CUT:
				x0 = mini(x0, x)
				y0 = mini(y0, y)
				x1 = maxi(x1, x)
				y1 = maxi(y1, y)
	return Rect2i(x0, y0, x1 - x0 + 1, y1 - y0 + 1)


func _lab_pixels(im: Image) -> Array[Vector3]:
	var out: Array[Vector3] = []
	for y: int in im.get_height():
		for x: int in im.get_width():
			var c: Color = im.get_pixel(x, y)
			if c.a > ALPHA_CUT:
				out.append(_lab(c))
	return out


func _mean(px: Array[Vector3]) -> Vector3:
	var s: Vector3 = Vector3.ZERO
	for v: Vector3 in px:
		s += v
	return s / maxf(1.0, px.size())


func _std(px: Array[Vector3], m: Vector3) -> Vector3:
	var s: Vector3 = Vector3.ZERO
	for v: Vector3 in px:
		var d: Vector3 = v - m
		s += d * d
	s /= maxf(1.0, px.size())
	return Vector3(maxf(sqrt(s.x), 1e-3), maxf(sqrt(s.y), 1e-3), maxf(sqrt(s.z), 1e-3))


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
