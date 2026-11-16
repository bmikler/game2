@tool
extends Node2D
## Stand-in albedo of flat things on a facade facing the camera (a door): rectangles in metres on
## the plane d = `d_m`. Poligon content, not the engine's. Keep this node at the Location's origin.

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")

@export var d_m: float = 0.0:
	set(value):
		d_m = value
		queue_redraw()
## Each rectangle: x and z of its bottom-left corner, width and height (metres).
@export var panes: Array[Rect2] = []:
	set(value):
		panes = value
		queue_redraw()
@export var color: Color = Color("#4a3a30"):
	set(value):
		color = value
		queue_redraw()


func _draw() -> void:
	for pane: Rect2 in panes:
		var low: Vector2 = PROJECTION.to_screen(Vector3(pane.position.x, d_m, pane.position.y))
		var high: Vector2 = PROJECTION.to_screen(Vector3(pane.end.x, d_m, pane.end.y))
		draw_rect(Rect2(Vector2(low.x, high.y), Vector2(high.x - low.x, low.y - high.y)), color)
