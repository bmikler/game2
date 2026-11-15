class_name SolidWireframe
extends RefCounted
## Draws a box's twelve edges through the projection (editor gizmo of a Solid, debug view "Bryły").

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")
## Pairs of AABB endpoint indices (bit 0: x, bit 1: d, bit 2: z) that make the edges.
const EDGES: PackedInt32Array = [0, 1, 2, 3, 4, 5, 6, 7, 0, 2, 1, 3, 4, 6, 5, 7, 0, 4, 1, 5, 2, 6, 3, 7]


## `box` in metres relative to the canvas item's origin.
static func draw(canvas: CanvasItem, box: AABB, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for endpoint: int in EDGES:
		points.append(PROJECTION.to_screen(_endpoint(box, endpoint)))
	canvas.draw_multiline(points, color, -1.0)


static func _endpoint(box: AABB, bits: int) -> Vector3:
	return box.position + box.size * Vector3(bits & 1, (bits >> 1) & 1, (bits >> 2) & 1)
