@tool
extends Node2D
## Stand-in albedo of the street Poligon's tenement houses until sprites come: the faces the
## projection shows of one Occluder's solids, front and top, far ones first. Poligon content, not
## the engine's; the engine gives the light.

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")

@export var occluder: Occluder:
	set(value):
		occluder = value
		_follow()
## Front colour of each solid in child order (repeats when there are more solids).
@export var front_colors: PackedColorArray = [Color("#a8796a")]:
	set(value):
		front_colors = value
		queue_redraw()
@export var top_color: Color = Color("#dfe3ea"):
	set(value):
		top_color = value
		queue_redraw()


func _ready() -> void:
	_follow()


func _draw() -> void:
	if occluder == null or front_colors.is_empty():
		return
	var receivers: Array[Receiver] = SceneDescription.from_boxes(occluder.world_boxes(), PROJECTION).receivers
	receivers.sort_custom(func(a: Receiver, b: Receiver) -> bool: return _nearness(a) < _nearness(b))
	for receiver: Receiver in receivers:
		var points: PackedVector2Array = PackedVector2Array()
		for corner: Vector3 in receiver.corners():
			points.append(PROJECTION.to_screen(corner) - position)
		var color: Color = top_color if receiver.normal.z > 0.5 else front_colors[receiver.solid % front_colors.size()]
		draw_colored_polygon(points, color)


## How near the camera a face's middle is.
static func _nearness(receiver: Receiver) -> float:
	return (receiver.origin + (receiver.edge_u + receiver.edge_v) * 0.5).dot(PROJECTION.toward_camera())


func _follow() -> void:
	if occluder == null or not is_inside_tree():
		return
	for child: Node in occluder.get_children():
		if child is Solid and not (child as Solid).changed.is_connected(queue_redraw):
			(child as Solid).changed.connect(queue_redraw)
	if not occluder.changed.is_connected(queue_redraw):
		occluder.changed.connect(queue_redraw)
	queue_redraw()
