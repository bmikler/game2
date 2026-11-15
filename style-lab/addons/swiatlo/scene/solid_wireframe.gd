class_name SolidWireframe
extends RefCounted
## Draws a solid's edges through the projection (editor gizmo of a Solid, debug view "Bryły").

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")


## `shape` in metres relative to the canvas item's origin.
static func draw(canvas: CanvasItem, shape: SolidShape, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for point: Vector3 in shape.edges():
		points.append(PROJECTION.to_screen(point))
	canvas.draw_multiline(points, color, -1.0)
