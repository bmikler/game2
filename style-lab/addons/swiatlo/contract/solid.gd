@tool
class_name Solid
extends Node2D
## Scene contract node: an invisible, simplified solid of its parent Occluder, in metres. The light
## engine casts its shadow and lights the faces the projection shows; colour comes from sprites.
## For now a box.

signal changed

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")
## Wireframe colour in the editor.
const EDITOR_COLOR: Color = Color(0.3, 0.9, 1.0, 0.8)

## The anchor relative to the Occluder: the middle of the box's front bottom edge.
@export var position_m: Vector3 = Vector3.ZERO:
	set(value):
		position_m = value
		position = PROJECTION.to_screen(value)
		_changed()
## Width (x), depth (d) and height (z).
@export var size_m: Vector3 = Vector3.ONE:
	set(value):
		size_m = value
		_changed()


func _draw() -> void:
	if Engine.is_editor_hint():
		SolidWireframe.draw(self, local_box(), EDITOR_COLOR)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if not get_parent() is Occluder:
		warnings.append("A Solid must be a child of an Occluder.")
	if size_m.x <= 0.0 or size_m.y <= 0.0 or size_m.z <= 0.0:
		warnings.append("Every dimension of a Solid must be above zero.")
	return warnings


## The box in metres relative to this node's anchor (the Occluder places it in the Location).
func local_box() -> AABB:
	return AABB(Vector3(-size_m.x * 0.5, -size_m.y, 0.0), size_m)



func _changed() -> void:
	queue_redraw()
	update_configuration_warnings()
	changed.emit()
