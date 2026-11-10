# PROTOTYP (ticket „Przepis postaci”): powiększony wycinek obrazu z siatką współrzędnych do odczytu punktów.
# Linie co <krok> px źródła (co 5. linia mocniejsza, czerwona = wielokrotność 5·krok).
# godot --headless --path . --script tools/postac/siatka.gd -- <in.png> <out.png> <x> <y> <w> <h> <powiększenie> [krok=10]
extends SceneTree


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var img := Image.load_from_file(a[0])
	img.convert(Image.FORMAT_RGBA8)
	var r := Rect2i(int(a[2]), int(a[3]), int(a[4]), int(a[5]))
	var k := int(a[6])
	var step := int(a[7]) if a.size() > 7 else 10
	var crop := img.get_region(r)
	var bg := Image.create(crop.get_width(), crop.get_height(), false, Image.FORMAT_RGBA8)
	bg.fill(Color(0.85, 0.86, 0.88))
	bg.blend_rect(crop, Rect2i(Vector2i.ZERO, crop.get_size()), Vector2i.ZERO)
	bg.resize(crop.get_width() * k, crop.get_height() * k, Image.INTERPOLATE_NEAREST)
	for sx in range(r.position.x, r.end.x):
		if sx % step == 0:
			var col := Color(1, 0, 0, 0.9) if sx % (step * 5) == 0 else Color(0, 0.6, 1, 0.5)
			for y in bg.get_height():
				bg.set_pixel((sx - r.position.x) * k, y, col)
	for sy in range(r.position.y, r.end.y):
		if sy % step == 0:
			var col := Color(1, 0, 0, 0.9) if sy % (step * 5) == 0 else Color(0, 0.6, 1, 0.5)
			for x in bg.get_width():
				bg.set_pixel(x, (sy - r.position.y) * k, col)
	bg.save_png(a[1])
	quit()
