# PROTOTYP (ticket „Przepis postaci”): twarda alfa po downscale (alfa > próg = 1, reszta 0),
# opcjonalnie 1 px ciemnego konturu na zewnątrz sylwetki.
# godot --headless --script alpha_cut.gd -- <in.png> <out.png> [próg=0.5] [kontur=0|1]
extends SceneTree


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var img := Image.load_from_file(a[0])
	img.convert(Image.FORMAT_RGBA8)
	var cut := float(a[2]) if a.size() > 2 else 0.5
	var outline := a.size() > 3 and a[3] == "1"
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			c.a = 1.0 if c.a > cut else 0.0
			img.set_pixel(x, y, c)
	if outline:
		var src := img.duplicate() as Image
		for y in img.get_height():
			for x in img.get_width():
				if src.get_pixel(x, y).a > 0.0:
					continue
				for d: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					var p := Vector2i(x, y) + d
					if p.x >= 0 and p.y >= 0 and p.x < img.get_width() and p.y < img.get_height() and src.get_pixelv(p).a > 0.0:
						img.set_pixel(x, y, Color("15161c"))
						break
	img.save_png(a[1])
	quit()
