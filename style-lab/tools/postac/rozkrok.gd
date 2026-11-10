extends SceneTree
## PROTOTYP (ticket „Przepis postaci”): automatyczny wybór klatki w rozkroku z animacji stanie→stanie
## (krok 1 łańcucha chodu). Miara: ile pikseli dolnych 40% postaci (nogi) różni się od klatki 0 (stanie);
## brane są tylko klatki środkowe (bez 2 pierwszych i 2 ostatnich). Wypisuje ścieżkę zwycięzcy w ostatniej linii.
##   godot --headless --path style-lab --script tools/postac/rozkrok.gd -- <kl0.png> <kl1.png> ... <klN.png>

const LEGS: float = 0.4
const DIFF: float = 0.15


func _init() -> void:
	var paths: PackedStringArray = OS.get_cmdline_user_args()
	var base: Image = Image.load_from_file(paths[0])
	var used: Rect2i = base.get_used_rect()
	var y0: int = used.end.y - roundi(used.size.y * LEGS)
	var best: int = -1
	var best_score: int = -1
	for i: int in range(2, paths.size() - 2):
		var im: Image = Image.load_from_file(paths[i])
		var score: int = 0
		for y: int in range(y0, im.get_height()):
			for x: int in im.get_width():
				var a: Color = base.get_pixel(x, y)
				var b: Color = im.get_pixel(x, y)
				if (a.a > 0.5) != (b.a > 0.5):
					score += 1
				elif a.a > 0.5 and absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > DIFF:
					score += 1
		print(paths[i].get_file(), " ", score)
		if score > best_score:
			best_score = score
			best = i
	print(paths[best])
	quit()
