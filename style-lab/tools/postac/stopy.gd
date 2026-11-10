# PROTOTYP (ticket „Przepis postaci”): geometryczny pomiar kąta z butów.
# Bok: w rzucie oblique dalsza stopa leży wyżej o df·rozstaw → uskok podeszew / wysokość postaci.
# Przód: but sięga ku kamerze → pionowy zasięg buta / wysokość postaci rośnie z df.
# Buty = brązowe piksele (r > g > b) w dolnych 20% postaci; tło: alfa albo kolor rogu.
# godot --headless --path . --script tools/postac/stopy.gd -- <a.png> <b.png> ...
# Wypisuje CSV: plik, wysokość_px, liczba_butów, uskok, zasięg_buta, rozstaw (środki butów w poziomie; ułamki wysokości).
# df boku = uskok(bok) / rozstaw(przód) tej samej postaci w tej samej pozie.
extends SceneTree

const BAND := 0.20 ## domyślny pas butów; STOPY_PAS (zmienna środowiskowa) nadpisuje, np. 0.35 dla klatek chodu


func _init() -> void:
	print("file,h_px,buty,uskok,zasieg,rozstaw")
	for path in OS.get_cmdline_user_args():
		print(_measure(path))
	quit()


func _measure(path: String) -> String:
	var img := Image.load_from_file(path)
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	var bg := img.get_pixel(2, 2)
	var fg := PackedByteArray()
	fg.resize(w * h)
	var top := h
	var bottom := -1
	for y in h:
		for x in w:
			var c := img.get_pixel(x, y)
			var on := c.a >= 0.5 and (bg.a < 0.5 or maxf(maxf(absf(c.r - bg.r), absf(c.g - bg.g)), absf(c.b - bg.b)) >= 0.08)
			if on:
				fg[y * w + x] = 1
				top = mini(top, y)
				bottom = maxi(bottom, y)
	var fh := bottom - top + 1
	var band := float(OS.get_environment("STOPY_PAS")) if OS.has_environment("STOPY_PAS") else BAND
	var y0 := bottom - int(fh * band)
	# maska butów
	var boot := PackedByteArray()
	boot.resize(w * h)
	for y in range(y0, bottom + 1):
		for x in w:
			if fg[y * w + x] == 0:
				continue
			var c := img.get_pixel(x, y)
			if c.r > c.g and c.g > c.b and c.r - c.b > 0.10 and c.v > 0.12 and c.s > 0.25:
				boot[y * w + x] = 1
	# składowe spójne (4-sąsiedztwo)
	var label := PackedInt32Array()
	label.resize(w * h)
	var comps: Array[Dictionary] = []
	for y in range(y0, bottom + 1):
		for x in w:
			var i := y * w + x
			if boot[i] == 0 or label[i] != 0:
				continue
			var id := comps.size() + 1
			var stack: Array[int] = [i]
			label[i] = id
			var n := 0
			var sx := 0
			var cy0 := y
			var cy1 := y
			while not stack.is_empty():
				var j: int = stack.pop_back()
				n += 1
				sx += j % w
				var jx := j % w
				var jy := j / w
				cy0 = mini(cy0, jy)
				cy1 = maxi(cy1, jy)
				for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var nx := jx + d.x
					var ny := jy + d.y
					if nx < 0 or nx >= w or ny < y0 or ny > bottom:
						continue
					var k := ny * w + nx
					if boot[k] == 1 and label[k] == 0:
						label[k] = id
						stack.append(k)
			comps.append({"n": n, "y0": cy0, "y1": cy1, "cx": float(sx) / n})
	comps.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.n > b.n)
	var big: Array[Dictionary] = []
	for c in comps:
		if c.n >= comps[0].n * 0.25 and big.size() < 2:
			big.append(c)
	var step := "-"
	var spread := "-"
	var reach := "-"
	if big.size() == 2:
		var d: int = big[0].y1 - big[1].y1
		step = "%.4f" % (absf(d) / fh)
		var dx: float = big[0].cx - big[1].cx
		spread = "%.4f" % (absf(dx) / fh)
	if not big.is_empty():
		var r := 0.0
		for c in big:
			var ext: int = c.y1 - c.y0 + 1
			r += float(ext) / fh
		reach = "%.4f" % (r / big.size())
	return "%s,%d,%d,%s,%s,%s" % [path, fh, big.size(), step, reach, spread]
