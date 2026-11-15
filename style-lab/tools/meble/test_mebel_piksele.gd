# Testy tools/meble/mebel_piksele.gd (ticket silnika 02). Uruchomienie z style-lab/:
#   "$G" --headless --path . --script tools/meble/test_mebel_piksele.gd
extends SceneTree

const M := preload("res://tools/meble/mebel_piksele.gd")

var _failed: int = 0


func _init() -> void:
	_test_sito_identical_masks()
	_test_sito_shifted_mask()
	_test_sito_accepts_additions_beyond_the_base()
	_test_sito_measures_bottom_edge_off_the_floor_line()
	_test_generator_mask_floods_background_from_edges()
	_test_pixels_take_alpha_from_generator_mask_and_no_background_on_edges()
	_test_palette_limits_colours_and_keeps_transparency()
	print("FAILED %d" % _failed if _failed > 0 else "OK")
	quit(1 if _failed > 0 else 0)


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed += 1
		push_error("FAIL: " + what)


## Mask with an opaque rectangle (white = inside), the rest black.
func _rect_mask(size: Vector2i, rect: Rect2i) -> Image:
	var img := Image.create(size.x, size.y, false, Image.FORMAT_L8)
	img.fill_rect(rect, Color.WHITE)
	return img


func _test_sito_identical_masks() -> void:
	var a := _rect_mask(Vector2i(100, 100), Rect2i(20, 30, 40, 50))
	var r: M.Sito = M.sito(a, a)
	_check(is_equal_approx(r.iou, 1.0), "identical masks: iou 1, got %s" % r.iou)
	_check(is_equal_approx(r.pokrycie, 1.0) and is_equal_approx(r.nadmiar, 0.0) and r.dol == 0, "identical masks: covered, no extra")
	_check(M.zgodny(r), "identical masks pass")


func _test_sito_shifted_mask() -> void:
	var blender := _rect_mask(Vector2i(100, 100), Rect2i(20, 30, 40, 50))
	var gen := _rect_mask(Vector2i(100, 100), Rect2i(30, 30, 40, 50))
	var r: M.Sito = M.sito(gen, blender)
	# Overlap 30×50 = 1500, union 50×50 = 2500.
	_check(is_equal_approx(r.iou, 0.6), "shifted 10 px: iou 0.6, got %s" % r.iou)
	_check(is_equal_approx(r.pokrycie, 0.75), "shifted 10 px: 3/4 of the base covered, got %s" % r.pokrycie)
	_check(not M.zgodny(r), "shifted by a quarter of the width fails")


## A blanket hanging over the side and a lamp on top: the base is covered, the extra is allowed.
func _test_sito_accepts_additions_beyond_the_base() -> void:
	var blender := _rect_mask(Vector2i(100, 100), Rect2i(20, 30, 40, 50))
	var gen := _rect_mask(Vector2i(100, 100), Rect2i(20, 30, 40, 50))
	gen.fill_rect(Rect2i(55, 40, 8, 30), Color.WHITE)
	gen.fill_rect(Rect2i(30, 20, 6, 10), Color.WHITE)
	var r: M.Sito = M.sito(gen, blender)
	_check(is_equal_approx(r.pokrycie, 1.0), "base covered, got %s" % r.pokrycie)
	_check(is_equal_approx(r.nadmiar, (3.0 * 30.0 + 60.0) / 2000.0), "extra = 150 / 2000 px, got %s" % r.nadmiar)
	_check(M.zgodny(r), "additions pass")


## The same shape painted higher: the bottom edge is off the floor line.
func _test_sito_measures_bottom_edge_off_the_floor_line() -> void:
	var blender := _rect_mask(Vector2i(100, 100), Rect2i(20, 30, 40, 50))
	var gen := _rect_mask(Vector2i(100, 100), Rect2i(20, 15, 40, 63))
	var r: M.Sito = M.sito(gen, blender)
	_check(r.dol == -2, "bottom edge 2 px higher, got %d" % r.dol)
	_check(is_equal_approx(r.pokrycie, 48.0 / 50.0), "base mostly covered, got %s" % r.pokrycie)


func _test_generator_mask_floods_background_from_edges() -> void:
	var bg := Color(0.8, 0.81, 0.83)
	var img := Image.create(60, 60, false, Image.FORMAT_RGBA8)
	img.fill(bg)
	img.fill_rect(Rect2i(10, 10, 30, 30), Color(0.25, 0.18, 0.12))
	# Slightly off background colour (generator noise) outside: still background.
	img.set_pixel(50, 50, Color(0.79, 0.8, 0.84))
	# Background-coloured patch enclosed by the object: part of the object.
	img.fill_rect(Rect2i(20, 20, 5, 5), bg)
	var m: Image = M.maska_generatora(img)
	_check(m.get_pixel(15, 15).v > 0.5, "object pixel inside")
	_check(m.get_pixel(22, 22).v > 0.5, "enclosed background-coloured patch inside")
	_check(m.get_pixel(5, 5).v < 0.5, "background outside")
	_check(m.get_pixel(50, 50).v < 0.5, "noisy background outside")


func _test_pixels_take_alpha_from_generator_mask_and_no_background_on_edges() -> void:
	var red := Color(0.7, 0.1, 0.1)
	var img := Image.create(100, 100, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.8, 0.81, 0.83))
	img.fill_rect(Rect2i(20, 30, 40, 50), red)
	var mask := _rect_mask(Vector2i(100, 100), Rect2i(20, 30, 40, 50))
	var px: Image = M.piksele(img, mask, Vector2i(10, 10))
	_check(px.get_size() == Vector2i(10, 10), "game size 10×10, got %s" % px.get_size())
	_check(px.get_pixel(2, 3).a == 1.0 and px.get_pixel(5, 7).a == 1.0, "corners of the object opaque")
	_check(px.get_pixel(1, 3).a == 0.0 and px.get_pixel(6, 7).a == 0.0, "outside the object transparent")
	var edge := px.get_pixel(2, 3)
	_check(absf(edge.r - red.r) < 0.03 and absf(edge.g - red.g) < 0.03, "edge pixel keeps object colour, got %s" % edge)


func _colours(img: Image) -> Dictionary:
	var seen := {}
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a > 0.5:
				seen[c.to_rgba32()] = true
	return seen


func _test_palette_limits_colours_and_keeps_transparency() -> void:
	# Gradient 30×30 = 900 colours, left column transparent.
	var img := Image.create(30, 30, false, Image.FORMAT_RGBA8)
	for y in 30:
		for x in 30:
			img.set_pixel(x, y, Color(x / 29.0, y / 29.0, 0.4, 0.0 if x == 0 else 1.0))
	var out: Image = M.paleta(img, 8)
	_check(_colours(out).size() <= 8, "at most 8 colours, got %d" % _colours(out).size())
	_check(_colours(out).size() >= 6, "palette actually used, got %d" % _colours(out).size())
	_check(out.get_pixel(0, 5).a == 0.0 and out.get_pixel(1, 5).a == 1.0, "alpha unchanged")
	var far := out.get_pixel(29, 29)
	_check(far.r > 0.75 and far.g > 0.75, "bright corner stays bright, got %s" % far)
	# Two-colour sprite: unchanged.
	var two := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	two.fill(Color(0.2, 0.3, 0.4))
	two.fill_rect(Rect2i(0, 0, 2, 4), Color(0.8, 0.1, 0.1))
	var kept: Image = M.paleta(two, 8)
	_check(kept.get_pixel(0, 0) == two.get_pixel(0, 0) and kept.get_pixel(3, 3) == two.get_pixel(3, 3),
			"sprite with fewer colours than the palette unchanged")
