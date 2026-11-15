@tool
class_name Solid
extends Node2D
## Scene contract node: an invisible, simplified solid of its parent Occluder, in metres. The light
## engine casts its shadow and lights the faces the projection shows; colour comes from sprites.
## Shapes: a box, a box with a gable roof (slopes falling along x or along d), an upright cylinder,
## or a raised box (empty below, e.g. an awning or a table top).

signal changed

enum Shape { BOX, ROOF_X, ROOF_D, CYLINDER, RAISED_BOX }

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")
## Wireframe colour in the editor.
const EDITOR_COLOR: Color = Color(0.3, 0.9, 1.0, 0.8)

## The anchor relative to the Occluder: the middle of the solid's front bottom edge (on the floor
## also for a raised box).
@export var position_m: Vector3 = Vector3.ZERO:
	set(value):
		position_m = value
		position = PROJECTION.to_screen(value)
		_changed()
## Width (x), depth (d) and height (z); a roof's height is its ridge, a cylinder's width and depth
## its diameters.
@export var size_m: Vector3 = Vector3.ONE:
	set(value):
		size_m = value
		_changed()
@export var shape: Shape = Shape.BOX:
	set(value):
		shape = value
		_changed()
## Roofs: height of the walls, where the slopes start (below the ridge).
@export var eave_m: float = 0.0:
	set(value):
		eave_m = value
		_changed()
## Raised box: the empty space below it, from the floor up.
@export var clearance_m: float = 0.0:
	set(value):
		clearance_m = value
		_changed()


func _draw() -> void:
	if Engine.is_editor_hint():
		SolidWireframe.draw(self, local_shape(), EDITOR_COLOR)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if not get_parent() is Occluder:
		warnings.append("A Solid must be a child of an Occluder.")
	if size_m.x <= 0.0 or size_m.y <= 0.0 or size_m.z <= 0.0:
		warnings.append("Every dimension of a Solid must be above zero.")
	if (shape == Shape.ROOF_X or shape == Shape.ROOF_D) and (eave_m <= 0.0 or eave_m >= size_m.z):
		warnings.append("A roof's eave must lie between the floor and the ridge (height).")
	if shape == Shape.RAISED_BOX and (clearance_m <= 0.0 or clearance_m >= size_m.z):
		warnings.append("A raised box's clearance must lie between the floor and its top (height).")
	return warnings


## The solid in metres relative to this node's anchor (the Occluder places it in the Location).
func local_shape() -> SolidShape:
	var bounds: AABB = AABB(Vector3(-size_m.x * 0.5, -size_m.y, 0.0), size_m)
	match shape:
		Shape.ROOF_X, Shape.ROOF_D:
			return SolidShape.make_roof(shape == Shape.ROOF_D, bounds, eave_m)
		Shape.CYLINDER:
			return SolidShape.make_cylinder(bounds)
		Shape.RAISED_BOX:
			var lift: float = clampf(clearance_m, 0.0, size_m.z)
			return SolidShape.make_box(AABB(bounds.position + Vector3(0.0, 0.0, lift), bounds.size - Vector3(0.0, 0.0, lift)))
	return SolidShape.make_box(bounds)


func _changed() -> void:
	queue_redraw()
	update_configuration_warnings()
	changed.emit()
