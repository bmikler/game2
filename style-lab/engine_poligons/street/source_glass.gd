@tool
extends Node2D
## Stand-in albedo of the street Poligon's lamp glass and window panes: each light source drawn as
## its shape seen through the projection (a sphere as a disc, a rectangle as its face). Poligon
## content, not the engine's: the engine gives the light, and a source's own surface glows with it.
## Keep this node at the Location's origin.

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")

@export var sources: Array[LightSource] = []:
	set(value):
		sources = value
		queue_redraw()
@export var glass_color: Color = Color("#8d949c"):
	set(value):
		glass_color = value
		queue_redraw()


func _draw() -> void:
	for source: LightSource in sources:
		if source == null:
			continue
		var entry: SourceEntry = source.entry()
		if entry.kind == LightSource.Shape.SPHERE:
			draw_circle(PROJECTION.to_screen(entry.centre), entry.radius * PROJECTION.px_per_m, glass_color)
			continue
		var corners: PackedVector2Array = PackedVector2Array()
		for corner: Vector3 in entry.corners():
			corners.append(PROJECTION.to_screen(corner))
		draw_colored_polygon(corners, glass_color)
