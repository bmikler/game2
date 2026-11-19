extends GutTest
## SilhouetteStack: a solid from a sprite's silhouette, row by row (engine ticket 17).

const PX: float = 0.025


## A transparent image `size` with opaque rectangles.
func _image(size: Vector2i, rects: Array[Rect2i]) -> Image:
	var image: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	for rect: Rect2i in rects:
		image.fill_rect(rect, Color.WHITE)
	return image


func test_two_legs_make_two_spans_and_the_body_one() -> void:
	# 10 px wide, 8 tall; legs (rows 4–7 from the top) at x 2–3 and 6–7, body above at x 2–7.
	var sprite: Image = _image(Vector2i(10, 8), [Rect2i(2, 4, 2, 4), Rect2i(6, 4, 2, 4), Rect2i(2, 0, 6, 4)])
	var across: Image = _image(Vector2i(10, 8), [Rect2i(4, 0, 2, 8)])
	var stack: SilhouetteStack = SilhouetteStack.new(PX)
	var frame: int = stack.add_frame(sprite, Vector2i(5, 8), across, Vector2i(5, 8))
	var legs: PackedVector2Array = stack.spans(frame, 0)
	assert_almost_eq(legs[0].x, -2.0 * PX, 1e-6, "left leg's centre: pixels 2–3 around anchor 5")
	assert_almost_eq(legs[0].y, 1.0 * PX, 1e-6)
	assert_almost_eq(legs[1].x, 2.0 * PX, 1e-6)
	var body: PackedVector2Array = stack.spans(frame, 6)
	assert_almost_eq(body[0].x, 0.0, 1e-6)
	assert_almost_eq(body[0].y, 3.0 * PX, 1e-6)
	assert_eq(body[1].y, 0.0, "one span only")
	assert_almost_eq(stack.half_depth(frame, 0), 1.0 * PX, 1e-6, "depth: half the 2 px run seen across")


func test_bounds_cover_the_silhouette_from_the_feet_up() -> void:
	var sprite: Image = _image(Vector2i(10, 8), [Rect2i(3, 2, 4, 6)])
	var across: Image = _image(Vector2i(10, 8), [Rect2i(4, 0, 4, 8)])
	var stack: SilhouetteStack = SilhouetteStack.new(PX)
	var bounds: AABB = stack.frame_bounds(stack.add_frame(sprite, Vector2i(5, 8), across, Vector2i(5, 8)))
	assert_almost_eq(bounds.position.x, -2.0 * PX, 1e-6)
	assert_almost_eq(bounds.end.x, 2.0 * PX, 1e-6)
	assert_almost_eq(bounds.position.y, -2.0 * PX, 1e-6, "depth centred on the anchor")
	assert_almost_eq(bounds.position.z, 0.0, 1e-6)
	assert_almost_eq(bounds.end.z, 6.0 * PX, 1e-6, "6 opaque rows")


func test_mirrored_frame_flips_about_the_anchor() -> void:
	var sprite: Image = _image(Vector2i(10, 4), [Rect2i(1, 0, 2, 4)])
	var across: Image = _image(Vector2i(10, 4), [Rect2i(4, 0, 2, 4)])
	var stack: SilhouetteStack = SilhouetteStack.new(PX)
	var plain: int = stack.add_frame(sprite, Vector2i(5, 4), across, Vector2i(5, 4))
	var mirrored: int = stack.add_frame(sprite, Vector2i(5, 4), across, Vector2i(5, 4), true)
	assert_almost_eq(stack.spans(plain, 0)[0].x, -3.0 * PX, 1e-6)
	assert_almost_eq(stack.spans(mirrored, 0)[0].x, 3.0 * PX, 1e-6)


func test_more_runs_close_the_narrowest_gaps() -> void:
	# Runs at 0–1, 3–4 (gap 1) and 8–9 (gap 3): the first two join.
	var sprite: Image = _image(Vector2i(10, 1), [Rect2i(0, 0, 2, 1), Rect2i(3, 0, 2, 1), Rect2i(8, 0, 2, 1)])
	var stack: SilhouetteStack = SilhouetteStack.new(PX)
	var frame: int = stack.add_frame(sprite, Vector2i(0, 1), sprite, Vector2i(0, 1))
	var pair: PackedVector2Array = stack.spans(frame, 0)
	assert_almost_eq(pair[0].x, 2.5 * PX, 1e-6, "joined run 0–5")
	assert_almost_eq(pair[0].y, 2.5 * PX, 1e-6)
	assert_almost_eq(pair[1].x, 9.0 * PX, 1e-6)


func test_data_has_a_row_per_frame_and_the_anchor_offset() -> void:
	var sprite: Image = _image(Vector2i(10, 8), [Rect2i(3, 2, 4, 6)])
	var stack: SilhouetteStack = SilhouetteStack.new(PX)
	stack.add_frame(sprite, Vector2i(5, 8), sprite, Vector2i(5, 8))
	stack.add_frame(sprite, Vector2i(5, 8), sprite, Vector2i(5, 8), true)
	var data: Image = stack.data()
	assert_eq(data.get_height(), 2)
	assert_eq(data.get_width(), 1 + 8 * 2)
	assert_almost_eq(data.get_pixel(0, 0).r, 2.0 * PX, 1e-6, "anchor 2 px right of the bounds' left edge")
	assert_almost_eq(data.get_pixel(2, 0).r, 2.0 * PX, 1e-6, "row 0's half depth")
