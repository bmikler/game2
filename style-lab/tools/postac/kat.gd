# PROTOTYP (ticket „Przepis postaci”): pomiar kąta kamery (depth_factor) na obrazie postaci.
# W rzucie gry wysokość postaci nie zależy od kąta, a głębia skraca się razy kąt, więc buty
# (brązowe) wychodzą tym wyżej, im wyższa kamera:
#   przód/tył: średnia wysokość dwóch butów / wzrost (widać wierzch buta na długości stopy),
#   bok: pionowy zasięg obu butów razem / wzrost (dalsza stopa wyżej o rozstaw × kąt).
# Kalibracja: rendery MPFB z butami (tools/blender/kalibracja_kata.py) w znanych kątach; kąt obrazu
# to interpolacja liniowa cechy w tej tabeli.
#   godot --headless --script kat.gd -- <przod|bok|tyl> <katalog_kalibracji> <obraz.png> ...
# Wypisuje: kąt  cecha  plik  (kąt poza zakresem kalibracji: < lub >).
extends SceneTree

const FEET_BAND := 0.2 ## Buty szukane w dolnych 20% postaci.


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var view := a[0]
	var table: Array[Vector2] = [] # (cecha, kąt)
	var dir := DirAccess.open(a[1])
	for f in dir.get_files():
		if f.begins_with(view + "_") and f.ends_with(".png"):
			var df := f.trim_prefix(view + "_").trim_suffix(".png").to_float() / 100.0
			table.append(Vector2(_feature(a[1].path_join(f), view), df))
	table.sort_custom(func(p: Vector2, q: Vector2) -> bool: return p.y < q.y)
	var line := "kalibracja %s:" % view
	for t in table:
		line += " %.2f→%.3f" % [t.y, t.x]
	print(line)
	for i in range(2, a.size()):
		var f := _feature(a[i], view)
		print("%s  %.3f  %s" % [_angle(table, f), f, a[i].get_file()])
	quit()


static func _angle(table: Array[Vector2], f: float) -> String:
	if f < table[0].x:
		return "<%.2f" % table[0].y
	for i in range(1, table.size()):
		if f <= table[i].x:
			var t := (f - table[i - 1].x) / maxf(1e-6, table[i].x - table[i - 1].x)
			return "%.2f" % lerpf(table[i - 1].y, table[i].y, t)
	return ">%.2f" % table[-1].y


static func _is_brown(c: Color) -> bool:
	return c.a > 0.5 and (c.h < 0.12 or c.h > 0.97) and c.s > 0.35 and c.v > 0.12 and c.v < 0.85


static func _feature(path: String, view: String) -> float:
	var img := Image.load_from_file(path)
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	var bg := img.get_pixel(2, 2)
	# Góra postaci: pierwszy wiersz z pikselem wyraźnie innym niż tło.
	var top := -1
	for y in h:
		for x in w:
			var c := img.get_pixel(x, y)
			if c.a > 0.5 and (bg.a < 0.5 or maxf(maxf(absf(c.r - bg.r), absf(c.g - bg.g)), absf(c.b - bg.b)) > 0.15):
				top = y
				break
		if top >= 0:
			break
	# Dół: najniższy brązowy wiersz (podeszwa); cień pod butami nie jest brązowy.
	var bottom := -1
	for y in range(h - 1, top, -1):
		var count := 0
		for x in w:
			if _is_brown(img.get_pixel(x, y)):
				count += 1
		if count >= 3:
			bottom = y
			break
	var height := float(bottom - top + 1)
	var band_top := bottom - roundi(height * FEET_BAND)
	if view == "bok":
		var first := bottom
		for y in range(band_top, bottom + 1):
			var count := 0
			for x in w:
				if _is_brown(img.get_pixel(x, y)):
					count += 1
			if count >= 3:
				first = y
				break
		return (bottom - first + 1) / height
	# Przód/tył: lewy i prawy but osobno (podział w połowie szerokości brązowych pikseli).
	var xs: Array[int] = []
	for y in range(band_top, bottom + 1):
		for x in w:
			if _is_brown(img.get_pixel(x, y)):
				xs.append(x)
	xs.sort()
	var mid := xs[xs.size() / 2]
	var sum := 0.0
	for side in 2:
		var first := -1
		var last := -1
		for y in range(band_top, bottom + 1):
			var count := 0
			for x in w:
				if (x < mid) == (side == 0) and _is_brown(img.get_pixel(x, y)):
					count += 1
			if count >= 3:
				if first < 0:
					first = y
				last = y
		sum += (last - first + 1)
	return sum / 2.0 / height
