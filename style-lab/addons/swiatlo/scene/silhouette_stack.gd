class_name SilhouetteStack
extends RefCounted
## A solid built from a sprite's silhouette, frame by frame (an animated character): one slab per
## sprite pixel row (1 / px_per_m tall), each row at most MAX_SPANS elliptic spans. A span's width
## along x is a run of opaque pixels in the row (the sprite's x is the world's x); its depth along d
## is half the widest run in the same row of a sprite seen across (the front view for a side frame,
## the side view for a front or back frame). Frames are added once; the light engine picks one per
## animation frame (Solid.frame), so the shadow walks with the sprite.
## The feet stand on the floor: in the projection a shoe shows its sole, so its heel or the far foot
## ends a few pixels above the sprite's lowest pixel. Within the foot band (the lowest `foot_m`) each
## row takes every column opaque in the band's rows above it, so the whole foot reaches the floor.

## Elliptic spans per row (two legs); a row with more runs closes its narrowest gaps.
const MAX_SPANS: int = 2
## The foot band's height by default (a shoe up to the ankle).
const FOOT_M: float = 0.12

## Metres per sprite pixel (the projection's 1 / px_per_m): a row's height and a pixel's width.
var pixel_m: float = 0.025
## The foot band's height (0: row by row from the floor up).
var foot_m: float = FOOT_M
## Per frame: per row MAX_SPANS × (centre x, half width) in metres from the anchor, then half depth.
var _rows: Array[PackedFloat32Array] = []
## Per frame: the bounds relative to the anchor (x, d centred on it, z from 0 up).
var _bounds: Array[AABB] = []
var _row_count: int = 0


func _init(metres_per_pixel: float = 0.025) -> void:
	pixel_m = metres_per_pixel


## Adds a frame: `sprite` with its anchor (the corner of the pixel under the feet' middle, as
## AssetSprite.anchor_px), `across` the sprite seen at right angles with its anchor. `mirrored`
## flips the frame about the anchor (a side view walking the other way). Returns the frame's index.
func add_frame(sprite: Image, anchor_px: Vector2i, across: Image, across_anchor_px: Vector2i,
		mirrored: bool = false) -> int:
	var rows: PackedFloat32Array = PackedFloat32Array()
	var bounds: AABB = AABB()
	var has_bounds: bool = false
	var row_count: int = anchor_px.y
	var foot_rows: int = ceili(foot_m / pixel_m - 1e-4)
	for row: int in row_count:
		# Rows of the foot band also take the band's rows above them.
		var band_top: int = maxi(row, foot_rows - 1)
		var y: int = anchor_px.y - 1 - row
		var spans: Array[Vector2] = _merged(_runs(sprite, anchor_px.y - 1 - band_top, y), MAX_SPANS)
		var depth: float = _half_depth(across, across_anchor_px.y - 1 - band_top, across_anchor_px.y - 1 - row)
		for index: int in MAX_SPANS:
			var centre: float = 0.0
			var half: float = 0.0
			if index < spans.size() and depth > 0.0:
				var from_px: float = spans[index].x - anchor_px.x
				var to_px: float = spans[index].y - anchor_px.x
				if mirrored:
					var swapped: float = -to_px
					to_px = -from_px
					from_px = swapped
				centre = (from_px + to_px) * 0.5 * pixel_m
				half = (to_px - from_px) * 0.5 * pixel_m
				var slab: AABB = AABB(Vector3(centre - half, -depth, row * pixel_m), Vector3(half * 2.0, depth * 2.0, pixel_m))
				bounds = slab if not has_bounds else bounds.merge(slab)
				has_bounds = true
			rows.append_array([centre, half])
		rows.append(depth)
	_rows.append(rows)
	_bounds.append(bounds)
	_row_count = maxi(_row_count, row_count)
	return _rows.size() - 1


func frame_count() -> int:
	return _rows.size()


## Rows of the tallest frame (the data's width in rows).
func row_count() -> int:
	return _row_count


## The frame's bounds relative to the anchor: x and d around it, z from its feet up.
func frame_bounds(frame: int) -> AABB:
	return _bounds[clampi(frame, 0, _bounds.size() - 1)]


## The frame's spans in `row` (from the feet up): (centre x, half width) pairs, half width 0 for none.
func spans(frame: int, row: int) -> PackedVector2Array:
	var found: PackedVector2Array = PackedVector2Array()
	var rows: PackedFloat32Array = _rows[frame]
	var stride: int = MAX_SPANS * 2 + 1
	if row >= rows.size() / stride:
		return found
	for index: int in MAX_SPANS:
		found.append(Vector2(rows[row * stride + index * 2], rows[row * stride + index * 2 + 1]))
	return found


## The frame's half depth in `row` (0 where the row is empty).
func half_depth(frame: int, row: int) -> float:
	var rows: PackedFloat32Array = _rows[frame]
	var stride: int = MAX_SPANS * 2 + 1
	return rows[row * stride + MAX_SPANS * 2] if row < rows.size() / stride else 0.0


## The frames for the shaders (visibility.gdshaderinc), one texel row per frame, RGBAF: texel 0
## (the anchor's x from the bounds' left edge, 0, 0, 0), then per row (centre 1, half 1, centre 2,
## half 2) and (half depth, 0, 0, 0), centres from the anchor. Rows past a frame's top are empty.
func data() -> Image:
	return SilhouetteStack.data_of([self])


## Several stacks in one texture, frames in order (stack after stack): a solid's texel row is its
## stack's first row + its frame.
static func data_of(stacks: Array[SilhouetteStack]) -> Image:
	var rows: int = 1
	var frames: int = 0
	for stack: SilhouetteStack in stacks:
		rows = maxi(rows, stack.row_count())
		frames += stack.frame_count()
	var image: Image = Image.create_empty(1 + rows * 2, maxi(frames, 1), false, Image.FORMAT_RGBAF)
	var line: int = 0
	for stack: SilhouetteStack in stacks:
		for frame: int in stack.frame_count():
			image.set_pixel(0, line, Color(-stack.frame_bounds(frame).position.x, 0.0, 0.0, 0.0))
			for row: int in stack.row_count():
				var pair: PackedVector2Array = stack.spans(frame, row)
				if pair.is_empty():
					continue
				image.set_pixel(1 + row * 2, line, Color(pair[0].x, pair[0].y, pair[1].x, pair[1].y))
				image.set_pixel(2 + row * 2, line, Color(stack.half_depth(frame, row), 0.0, 0.0, 0.0))
			line += 1
	return image


## Runs of columns opaque in any row from `top_y` to `bottom_y`, as (first x, x past the last) in
## pixels.
static func _runs(image: Image, top_y: int, bottom_y: int) -> Array[Vector2]:
	var runs: Array[Vector2] = []
	var first: int = maxi(top_y, 0)
	var last: int = mini(bottom_y, image.get_height() - 1)
	if first > last:
		return runs
	var start: int = -1
	for x: int in image.get_width() + 1:
		var opaque: bool = false
		if x < image.get_width():
			for y: int in range(first, last + 1):
				if image.get_pixel(x, y).a >= 0.5:
					opaque = true
					break
		if opaque and start < 0:
			start = x
		elif not opaque and start >= 0:
			runs.append(Vector2(start, x))
			start = -1
	return runs


## At most `count` runs: the narrowest gaps close first.
static func _merged(runs: Array[Vector2], count: int) -> Array[Vector2]:
	var merged: Array[Vector2] = runs.duplicate()
	while merged.size() > count:
		var narrowest: int = 0
		for index: int in range(1, merged.size() - 1):
			if merged[index + 1].x - merged[index].y < merged[narrowest + 1].x - merged[narrowest].y:
				narrowest = index
		merged[narrowest] = Vector2(merged[narrowest].x, merged[narrowest + 1].y)
		merged.remove_at(narrowest + 1)
	return merged


## Half the widest run of `image` over rows `top_y` … `bottom_y`, in metres (0: empty rows).
func _half_depth(image: Image, top_y: int, bottom_y: int) -> float:
	var widest: float = 0.0
	for run: Vector2 in _runs(image, top_y, bottom_y):
		widest = maxf(widest, run.y - run.x)
	return widest * 0.5 * pixel_m
