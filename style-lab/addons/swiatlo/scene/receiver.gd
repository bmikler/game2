class_name Receiver
extends RefCounted
## A receiver: a face of a solid that the game's projection shows (top, front, roof slope, the side
## of a cylinder), so it takes light. It follows from the geometry, not from a flag. Flat faces are
## spans of two edges in metres: origin + a·edge_u + b·edge_v, with a, b in 0…1 (parallelogram),
## a, b ≥ 0 and a + b ≤ 1 (triangle) or a² + b² ≤ 1 (disk, origin in the middle). A cylinder's side
## stands on the ellipse origin + cos·edge_u + sin·edge_v and is `height` tall.

## The numbers go to the light buffer shader as they are (`light_buffer.gdshader`, RECEIVER_*).
enum Kind { PARALLELOGRAM, TRIANGLE, DISK, CYLINDER }

var kind: Kind = Kind.PARALLELOGRAM
var origin: Vector3
var edge_u: Vector3
var edge_v: Vector3
## Unit normal, out of the solid (a cylinder's side: the normal at its front, towards the camera).
var normal: Vector3
## Cylinder side only.
var height: float = 0.0
## Index of the solid the face belongs to (in the scene description's `solids`).
var solid: int


func _init(face_origin: Vector3, u: Vector3, v: Vector3, face_normal: Vector3, solid_index: int,
		face_kind: Kind = Kind.PARALLELOGRAM) -> void:
	origin = face_origin
	edge_u = u
	edge_v = v
	normal = face_normal
	solid = solid_index
	kind = face_kind


## The parallelogram's four corners (or the triangle's three).
func corners() -> Array[Vector3]:
	if kind == Kind.TRIANGLE:
		return [origin, origin + edge_u, origin + edge_v]
	return [origin, origin + edge_u, origin + edge_u + edge_v, origin + edge_v]


## The face's middle (a disk's or cylinder's origin is already its centre).
func middle() -> Vector3:
	match kind:
		Kind.DISK:
			return origin
		Kind.CYLINDER:
			return origin + edge_v + Vector3(0.0, 0.0, height * 0.5)
		Kind.TRIANGLE:
			return origin + (edge_u + edge_v) / 3.0
	return origin + (edge_u + edge_v) * 0.5


## The face's outline as a polygon in metres; a cylinder's side as the half the camera sees.
func outline() -> Array[Vector3]:
	match kind:
		Kind.DISK:
			return _arc(origin, 0.0, TAU, 2 * SolidShape.OUTLINE_SEGMENTS)
		Kind.CYLINDER:
			var top: Vector3 = origin + Vector3(0.0, 0.0, height)
			var points: Array[Vector3] = _arc(origin, 0.0, PI, SolidShape.OUTLINE_SEGMENTS + 1)
			var upper: Array[Vector3] = _arc(top, 0.0, PI, SolidShape.OUTLINE_SEGMENTS + 1)
			upper.reverse()
			points.append_array(upper)
			return points
	return corners()


## `count` points on the ellipse around `centre` from angle `from` to `to` (both ends included for
## an open arc, the end left out for a full turn).
func _arc(centre: Vector3, from: float, to: float, count: int) -> Array[Vector3]:
	var points: Array[Vector3] = []
	var full: bool = is_equal_approx(to - from, TAU)
	for index: int in count:
		var angle: float = lerpf(from, to, float(index) / float(count if full else count - 1))
		points.append(centre + edge_u * cos(angle) + edge_v * sin(angle))
	return points
