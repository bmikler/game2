# PROTOTYP (ticket „Przepis postaci”): usuwa jasne resztki cienia konceptu przy stopach.
# godot --headless --script clean_feet.gd -- <in.png> <out.png> [wiersze=14] [jasność=0.5]
extends SceneTree


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var img := Image.load_from_file(a[0])
	img.convert(Image.FORMAT_RGBA8)
	var rows := int(a[2]) if a.size() > 2 else 14
	var light := float(a[3]) if a.size() > 3 else 0.5
	var used := img.get_used_rect()
	var removed := 0
	for y in range(used.end.y - rows, used.end.y):
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a > 0.0 and c.v > light and c.s < 0.3:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				removed += 1
	img.save_png(a[1])
	print("removed ", removed, " used ", img.get_used_rect())
	quit()
