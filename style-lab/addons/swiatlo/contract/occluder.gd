@tool
class_name Occluder
extends Node2D
## Scene contract node: something that casts shadow and hides the sky (a building, a lamp post, a
## piece of furniture). Made of one or more Solid children. Its position is in metres; the screen
## position follows from the projection.

signal changed

const GROUP: StringName = &"swiatlo_occluder"
const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")

## The anchor in metres (x right, d towards the camera, z up); the solids stand relative to it.
@export var position_m: Vector3 = Vector3.ZERO:
	set(value):
		position_m = value
		position = PROJECTION.to_screen(value)
		changed.emit()


func _enter_tree() -> void:
	add_to_group(GROUP)


## The shapes of this Occluder's Solid children in the Location's metres.
func world_shapes() -> Array[SolidShape]:
	var shapes: Array[SolidShape] = []
	for child: Node in get_children():
		var solid: Solid = child as Solid
		if solid != null:
			shapes.append(solid.local_shape().moved(position_m + solid.position_m))
	return shapes
