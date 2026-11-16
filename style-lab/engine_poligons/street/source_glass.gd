@tool
extends Node2D
## Stand-in albedo of the street Poligon's lamp glass and window panes: each light source drawn as
## its shape seen through the projection (a sphere as a disc, a rectangle as its face). A rectangle
## also gets a frame round it and snow on a sill below, as the old street Poligon drew its windows; a
## window of two sashes is two rectangles whose frames meet in a mullion. Poligon content, not the
## engine's: the engine gives the light, and a source's own surface glows with it. Keep this node at
## the Location's origin.

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")

@export var sources: Array[LightSource] = []:
	set(value):
		sources = value
		queue_redraw()
## Light, so a lit pane reads as light (grey glass under warm light looked like brown boards).
@export var glass_color: Color = Color("#fcf8f2"):
	set(value):
		glass_color = value
		queue_redraw()
@export var frame_color: Color = Color("#cfc8b8"):
	set(value):
		frame_color = value
		queue_redraw()
@export var sill_color: Color = Color("#e8ecf2"):
	set(value):
		sill_color = value
		queue_redraw()
## The frame's width round a pane (half a mullion between two sashes 2 × this apart).
@export var frame_m: float = 0.04:
	set(value):
		frame_m = value
		queue_redraw()
## The sill's snow below the frame: how far it sticks out on each side (x) and its height (y).
@export var sill_m: Vector2 = Vector2(0.15, 0.1):
	set(value):
		sill_m = value
		queue_redraw()


func _draw() -> void:
	# Frames and sills first, so a sash's frame never covers its neighbour's glass.
	for source: LightSource in sources:
		if source == null or source.shape != LightSource.Shape.RECTANGLE:
			continue
		var entry: SourceEntry = source.entry()
		var u: Vector3 = entry.half_u.normalized()
		var v: Vector3 = entry.half_v.normalized()
		var outer_u: Vector3 = entry.half_u + u * frame_m
		var outer_v: Vector3 = entry.half_v + v * frame_m
		_draw_face(entry.centre, outer_u, outer_v, frame_color)
		var sill_centre: Vector3 = entry.centre - outer_v - v * (sill_m.y / 2.0)
		_draw_face(sill_centre, outer_u + u * sill_m.x, v * (sill_m.y / 2.0), sill_color)
	for source: LightSource in sources:
		if source == null:
			continue
		var entry: SourceEntry = source.entry()
		if entry.kind == LightSource.Shape.SPHERE:
			draw_circle(PROJECTION.to_screen(entry.centre), entry.radius * PROJECTION.px_per_m, glass_color)
			continue
		_draw_face(entry.centre, entry.half_u, entry.half_v, glass_color)


## The rectangle centre ± half_u ± half_v (metres) as seen through the projection.
func _draw_face(centre: Vector3, half_u: Vector3, half_v: Vector3, color: Color) -> void:
	var corners_m: Array[Vector3] = [centre - half_u - half_v, centre + half_u - half_v,
			centre + half_u + half_v, centre - half_u + half_v]
	var corners: PackedVector2Array = PackedVector2Array()
	for corner: Vector3 in corners_m:
		corners.append(PROJECTION.to_screen(corner))
	draw_colored_polygon(corners, color)
