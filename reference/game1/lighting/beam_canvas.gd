class_name BeamCanvas
extends Node2D
## One additive sun beam from a window's glass, whichever wall the glass is in. Brightness depends only
## on the distance along the beam, cut into bands so any triangulation is exact; each band is clipped
## to the room. Draws with draw_polygon: a Polygon2D with several `polygons` drew nothing inside the
## station scene, though it worked in isolation.

const BANDS: int = 8
const MIN_ENERGY: float = 0.002
const MIN_TRAVEL: float = 0.5
const MIN_LENGTH: float = 1.0
const MIN_WIDTH: float = 2.0
const AIR_Z: int = 3

var profile: WindowLightProfile
var interior: Rect2 = Rect2() ## The room's back wall and floor in this node's pixels.

var _polygons: Array[PackedVector2Array] = []
var _colors: Array[PackedColorArray] = []


func _init() -> void:
	z_index = AIR_Z
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	additive.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = additive


func _draw() -> void:
	for index: int in _polygons.size():
		draw_polygon(_polygons[index], _colors[index])


## The convex hull of the glass `near` (points at heights `fall` px) and where they land (`travel` per
## metre of fall, × beam_extend), the landings widened sideways. `away`: from the middle of the window
## to this pane; the pane widens only on that side, so the mullion's shadow stays a clean gap down the
## whole beam.
func paint(
		near: PackedVector2Array, fall: PackedFloat32Array, travel: Vector2,
		energy: float, color: Color, away: Vector2 = Vector2.ZERO) -> void:
	if travel.length() < MIN_TRAVEL or energy < MIN_ENERGY:
		visible = false
		return
	visible = true
	var along: Vector2 = travel.normalized()
	var across: Vector2 = Vector2(-along.y, along.x)
	var far_points: PackedVector2Array = PackedVector2Array()
	var start: float = INF
	var low: float = INF
	var high: float = -INF
	for index: int in near.size():
		far_points.append(near[index] + travel * fall[index] / WindowLight.PX_M * profile.beam_extend)
		start = minf(start, near[index].dot(along))
		low = minf(low, near[index].dot(across))
		high = maxf(high, near[index].dot(across))
	var end: float = -INF
	for point: Vector2 in far_points:
		end = maxf(end, point.dot(along))
	# The far end is the glass moved along the beam (its landings), every landing pushed out sideways
	# by (beam_widen − 1) × half the glass's width across the beam: the beam keeps the glass's shape
	# and direction and only grows wider.
	var extra: float = maxf(high - low, MIN_WIDTH) * 0.5 * (profile.beam_widen - 1.0)
	var points: PackedVector2Array = near.duplicate()
	var side: float = signf(away.dot(across)) if away.length() > 1.0 else 0.0
	for point: Vector2 in far_points:
		points.append(point - across * extra * (1.0 if side <= 0.0 else 0.0))
		points.append(point + across * extra * (1.0 if side >= 0.0 else 0.0))
	var hull: PackedVector2Array = Geometry2D.convex_hull(points)
	if hull.size() > 1 and hull[0] == hull[hull.size() - 1]:
		hull.remove_at(hull.size() - 1)
	var length: float = maxf(end - start, MIN_LENGTH)
	_polygons = []
	_colors = []
	for band_index: int in BANDS:
		var from: float = float(band_index) / BANDS
		var to: float = float(band_index + 1) / BANDS
		var band: PackedVector2Array = _cut(
				_cut(hull, along, start + from * length, 1.0), along, start + to * length, -1.0)
		if band.size() < 3:
			continue
		var band_colors: PackedColorArray = PackedColorArray()
		for point: Vector2 in band:
			var at: float = clampf((point.dot(along) - start) / length, from, to)
			var gain: float = energy * profile.beam_gain \
					* lerpf(_brightness(from), _brightness(to), (at - from) / (to - from))
			band_colors.append(Color(color.r * gain, color.g * gain, color.b * gain, 1.0))
		var clipped: PackedVector2Array = band
		for edge: int in 4:
			var result: Array = _clip_edge(clipped, band_colors, edge)
			clipped = result[0]
			band_colors = result[1]
		if clipped.size() >= 3:
			_polygons.append(clipped)
			_colors.append(band_colors)
	queue_redraw()


## The part of a convex polygon on one side of the line p·along = at (side 1: >=, -1: <=).
static func _cut(points: PackedVector2Array, along: Vector2, at: float, side: float) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	var count: int = points.size()
	for index: int in count:
		var point: Vector2 = points[index]
		var next: Vector2 = points[(index + 1) % count]
		var here: float = (point.dot(along) - at) * side
		var there: float = (next.dot(along) - at) * side
		if here >= 0.0:
			result.append(point)
		if (here >= 0.0) != (there >= 0.0):
			result.append(point.lerp(next, here / (here - there)))
	return result


## Brightness along the beam: full for the first beam_flat of it, then (1 − v')^beam_falloff.
func _brightness(along: float) -> float:
	if along <= profile.beam_flat:
		return 1.0
	return pow(1.0 - (along - profile.beam_flat) / (1.0 - profile.beam_flat), profile.beam_falloff)


## One Sutherland–Hodgman step: keep the part of the polygon inside one edge of `interior` (0 left,
## 1 right, 2 top, 3 bottom), colours interpolated where an edge is cut.
func _clip_edge(points: PackedVector2Array, colors: PackedColorArray, edge: int) -> Array:
	var result: PackedVector2Array = PackedVector2Array()
	var result_colors: PackedColorArray = PackedColorArray()
	var count: int = points.size()
	for index: int in count:
		var point: Vector2 = points[index]
		var next: Vector2 = points[(index + 1) % count]
		var here: float = _inside(point, edge)
		var there: float = _inside(next, edge)
		if here >= 0.0:
			result.append(point)
			result_colors.append(colors[index])
		if (here >= 0.0) != (there >= 0.0):
			var cut: float = here / (here - there)
			result.append(point.lerp(next, cut))
			result_colors.append(colors[index].lerp(colors[(index + 1) % count], cut))
	return [result, result_colors]


## Signed distance of `point` inside one edge of `interior` (>= 0: inside).
func _inside(point: Vector2, edge: int) -> float:
	match edge:
		0:
			return point.x - interior.position.x
		1:
			return interior.end.x - point.x
		2:
			return point.y - interior.position.y
		_:
			return interior.end.y - point.y
