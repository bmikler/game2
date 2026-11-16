@tool
class_name LightSource
extends Node2D
## Scene contract node: an area light source in metres (a sphere, e.g. a lamp's bulb, or a
## rectangle shining from one face, e.g. a lit window). What light it gives is its profile's; sources
## of one profile make one layer of the light buffer. The source's own surface glows with the light
## its profile gives at distance 0. It must not sit inside a solid (its light would not get out).

signal changed

enum Shape { SPHERE, RECTANGLE }
## The face a rectangle shines from: towards the camera (+d), away from it (−d), right (+x), left
## (−x), up (+z) or down (−z).
enum Facing { TOWARD_CAMERA, AWAY_FROM_CAMERA, RIGHT, LEFT, UP, DOWN }

const GROUP: StringName = &"swiatlo_light_source"
const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")
## Outline colour in the editor.
const EDITOR_COLOR: Color = Color(1.0, 0.8, 0.3, 0.9)
## Each Facing's normal, and the directions its width and height lie along.
const FACING_NORMALS: Array[Vector3] = [Vector3(0, 1, 0), Vector3(0, -1, 0), Vector3(1, 0, 0),
		Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]
const FACING_WIDTHS: Array[Vector3] = [Vector3(1, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0),
		Vector3(0, 1, 0), Vector3(1, 0, 0), Vector3(1, 0, 0)]
const FACING_HEIGHTS: Array[Vector3] = [Vector3(0, 0, 1), Vector3(0, 0, 1), Vector3(0, 0, 1),
		Vector3(0, 0, 1), Vector3(0, 1, 0), Vector3(0, 1, 0)]

## The source's middle in the Location's metres (x right, d towards the camera, z up).
@export var position_m: Vector3 = Vector3.ZERO:
	set(value):
		position_m = value
		position = PROJECTION.to_screen(value)
		_changed()
@export var shape: Shape = Shape.SPHERE:
	set(value):
		shape = value
		_changed()
## A rectangle's width and height (along its face); a sphere's diameter is the width.
@export var size_m: Vector2 = Vector2(0.2, 0.2):
	set(value):
		size_m = value
		_changed()
## The face a rectangle shines from (a sphere shines every way).
@export var facing: Facing = Facing.TOWARD_CAMERA:
	set(value):
		facing = value
		_changed()
@export var profile: SourceProfile:
	set(value):
		profile = value
		_changed()


func _enter_tree() -> void:
	add_to_group(GROUP)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	if shape == Shape.SPHERE:
		draw_arc(Vector2.ZERO, size_m.x * 0.5 * PROJECTION.px_per_m, 0.0, TAU, 24, EDITOR_COLOR, -1.0)
		return
	var outline: PackedVector2Array = PackedVector2Array()
	for corner: Vector3 in entry().corners():
		outline.append(PROJECTION.to_screen(corner - position_m))
	outline.append(outline[0])
	draw_polyline(outline, EDITOR_COLOR, -1.0)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if profile == null:
		warnings.append("A LightSource needs a SourceProfile.")
	if size_m.x <= 0.0 or (shape == Shape.RECTANGLE and size_m.y <= 0.0):
		warnings.append("A LightSource's size must be above zero.")
	return warnings


## The source in the scene description (its group is set there).
func entry() -> SourceEntry:
	var source: SourceEntry = SourceEntry.new()
	source.kind = shape
	source.centre = position_m
	source.profile = profile
	if shape == Shape.SPHERE:
		source.radius = size_m.x * 0.5
	else:
		source.normal = FACING_NORMALS[facing]
		source.half_u = FACING_WIDTHS[facing] * size_m.x * 0.5
		source.half_v = FACING_HEIGHTS[facing] * size_m.y * 0.5
	return source


func _changed() -> void:
	queue_redraw()
	update_configuration_warnings()
	changed.emit()
