class_name Receiver
extends RefCounted
## A receiver: a flat face of a solid that the game's projection shows (top, front, roof slope),
## so it takes light. It follows from the geometry, not from a flag. A parallelogram in metres:
## origin + a·edge_u + b·edge_v for a, b in 0…1.

var origin: Vector3
var edge_u: Vector3
var edge_v: Vector3
## Unit normal, out of the solid.
var normal: Vector3
## Index of the solid the face belongs to (in the scene description's `solids`).
var solid: int


func _init(face_origin: Vector3, u: Vector3, v: Vector3, face_normal: Vector3, solid_index: int) -> void:
	origin = face_origin
	edge_u = u
	edge_v = v
	normal = face_normal
	solid = solid_index


func corners() -> Array[Vector3]:
	return [origin, origin + edge_u, origin + edge_u + edge_v, origin + edge_v]
