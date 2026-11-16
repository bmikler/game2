class_name SourceEntry
extends RefCounted
## A light source in the scene description, in the Location's metres: a sphere (centre, radius) or a
## rectangle (centre ± half_u ± half_v) shining from the face its normal points out of; and its
## group (its profile's place in the description's `source_groups`).

var kind: LightSource.Shape = LightSource.Shape.SPHERE
var centre: Vector3 = Vector3.ZERO
var radius: float = 0.0
## A rectangle's half width and half height along its face, and the normal of the face it shines from.
var half_u: Vector3 = Vector3.ZERO
var half_v: Vector3 = Vector3.ZERO
var normal: Vector3 = Vector3.ZERO
var profile: SourceProfile
var group: int = 0


## A rectangle's four corners in order round its edge (metres).
func corners() -> Array[Vector3]:
	return [centre - half_u - half_v, centre + half_u - half_v, centre + half_u + half_v, centre - half_u + half_v]
