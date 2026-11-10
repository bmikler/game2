# PROTOTYP (ticket „Przepis postaci”): poprawka klatek chodu bokiem z Pixellab, w których kurtka „rozchyla się”
# (jasna koszula przy przedniej krawędzi, brązowa plama na piersi). W pasie tułowia (ułamki wysokości postaci
# <od>..<do>, liczone od czubka głowy) piksel, który nie jest kolorem kurtki (ciemny, niebieskawy), dostaje kolor
# najbliższego piksela kurtki w tym samym wierszu. Wcześniej w pasie <od>..<do_szczelin> wąskie przezroczyste szczeliny
# (≤ MAX_SLIT px, postać z obu stron w wierszu; Pixellab zostawia je przy krawędzi kurtki, w grze prześwituje
# przez nie podłoże) dostają kolor sąsiedniego piksela postaci. Nic nie jest wklejane z innych klatek ani prób.
# godot --headless --path . --script tools/postac/zamaluj_tors.gd -- <od> <do> <do_szczelin> <in.png> <out.png> [<in2> <out2> ...]
extends SceneTree

const JACKET_V := 0.30 ## kurtka: jasność poniżej
const JACKET_WARM := 0.02 ## kurtka: r - b poniżej (nie ciepła)
const MAX_SLIT := 2


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var from := float(a[0])
	var to := float(a[1])
	var slit_to := float(a[2])
	for i in range(3, a.size() - 1, 2):
		var img := Image.load_from_file(a[i])
		img.convert(Image.FORMAT_RGBA8)
		var holes := _slits(img, from, slit_to)
		var n := _paint(img, from, to)
		img.save_png(a[i + 1])
		print(a[i + 1], " szczeliny: ", holes, " zamalowane: ", n)
	quit()


func _jacket(c: Color) -> bool:
	return c.a > 0.5 and c.v < JACKET_V and c.r - c.b < JACKET_WARM


func _paint(img: Image, from: float, to: float) -> int:
	var used := img.get_used_rect()
	var y0 := used.position.y + roundi(used.size.y * from)
	var y1 := used.position.y + roundi(used.size.y * to)
	var src := img.duplicate() as Image
	var count := 0
	for y in range(y0, y1):
		for x in range(used.position.x, used.end.x):
			var c := src.get_pixel(x, y)
			if c.a <= 0.5 or _jacket(c):
				continue
			# najbliższy piksel kurtki w wierszu (w obie strony)
			for d in range(1, used.size.x):
				var found := false
				for sx: int in [x + d, x - d]:
					if sx >= used.position.x and sx < used.end.x and _jacket(src.get_pixel(sx, y)):
						img.set_pixel(x, y, src.get_pixel(sx, y))
						found = true
						break
				if found:
					count += 1
					break
	return count


func _slits(img: Image, from: float, to: float) -> int:
	var used := img.get_used_rect()
	var y0 := used.position.y + roundi(used.size.y * from)
	var y1 := used.position.y + roundi(used.size.y * to)
	var count := 0
	for y in range(y0, y1):
		var x := used.position.x + 1
		while x < used.end.x - 1:
			if img.get_pixel(x, y).a > 0.5 or img.get_pixel(x - 1, y).a <= 0.5:
				x += 1
				continue
			var run := 0
			while x + run < used.end.x and img.get_pixel(x + run, y).a <= 0.5:
				run += 1
			if run <= MAX_SLIT and x + run < used.end.x:
				var right := img.get_pixel(x + run, y)
				var left := img.get_pixel(x - 1, y)
				var fill := right if _jacket(right) or not _jacket(left) else left
				for k in run:
					img.set_pixel(x + k, y, fill)
				count += run
			x += run
	return count
