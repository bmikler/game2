extends SceneTree
## PROTOTYP (ticket „Przepis postaci”): render postaci 3D (stała skala, stopy w stałym wierszu) → sprite.
## Całe płótno zmniejszane Lanczosem do <rozmiar> px (bez dopasowania do obrysu, więc klatki chodu
## zachowują wspólną skalę i podskok), potem twarda alfa (alfa > próg = 1, reszta 0).
##   godot --headless --path style-lab --script tools/postac/zmniejsz.gd -- <rozmiar> <próg> <we.png> <wy.png> [<we> <wy> ...]


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var size: int = int(args[0])
	var cut: float = float(args[1])
	for i: int in range(2, args.size() - 1, 2):
		var img: Image = Image.load_from_file(args[i])
		img.convert(Image.FORMAT_RGBA8)
		img.resize(size, size, Image.INTERPOLATE_LANCZOS)
		for y: int in img.get_height():
			for x: int in img.get_width():
				var c: Color = img.get_pixel(x, y)
				if c.a > cut:
					c.a = 1.0
				else:
					c = Color(0.0, 0.0, 0.0, 0.0)
				img.set_pixel(x, y, c)
		img.save_png(args[i + 1])
	quit()
