@tool
class_name Occluder
extends Node2D
## Scene contract node: something that casts shadow and hides the sky (a building, a lamp post, a
## piece of furniture). Made of one or more Solid children. Its position is in metres; the screen
## position follows from the projection. With an AssetSprite child it is an asset: its solids are
## invisible and the sprite gives the colour.

signal changed

const GROUP: StringName = &"swiatlo_occluder"
const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")

## The anchor in metres (x right, d towards the camera, z up); the solids stand relative to it.
@export var position_m: Vector3 = Vector3.ZERO:
	set(value):
		position_m = value
		position = PROJECTION.to_screen(value)
		_snap_sprite()
		changed.emit()


func _enter_tree() -> void:
	add_to_group(GROUP)


func _ready() -> void:
	_snap_sprite()


## The shapes of this Occluder's Solid children in the Location's metres.
func world_shapes() -> Array[SolidShape]:
	var shapes: Array[SolidShape] = []
	for child: Node in get_children():
		var solid: Solid = child as Solid
		if solid != null:
			shapes.append(solid.local_shape().moved(position_m + solid.position_m))
	return shapes


## The asset's sprite (null: not an asset).
func asset_sprite() -> AssetSprite:
	for child: Node in get_children():
		if child is AssetSprite:
			return child as AssetSprite
	return null


## Problems with the asset's data the author should see (empty: none, or not an asset): the
## sprite's own, and solids reaching beyond the sprite (they would darken ground beside the thing).
func asset_warnings() -> PackedStringArray:
	var sprite: AssetSprite = asset_sprite()
	if sprite == null:
		return PackedStringArray()
	var found: PackedStringArray = sprite.warnings()
	if sprite.texture != null:
		var shapes: Array[SolidShape] = []
		for child: Node in get_children():
			var solid: Solid = child as Solid
			if solid != null:
				shapes.append(solid.local_shape().moved(solid.position_m))
		var outside: int = AssetSprite.solid_pixels_outside(sprite.texture.get_image(), sprite.anchor_px, shapes)
		if outside > 0:
			found.append("%d screen pixels of the solids lie over 1 px outside the sprite's silhouette." % outside)
	return found


func _snap_sprite() -> void:
	var sprite: AssetSprite = asset_sprite()
	if sprite != null:
		sprite.snap_to(PROJECTION.to_screen(position_m))
