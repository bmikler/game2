@tool
class_name AssetSprite
extends Sprite2D
## Scene contract node: the sprite of an asset, a child of the asset's Occluder (whose Solids are then
## invisible: they only cast shadow and hide the sky; colour comes from this sprite). The sprite is
## albedo; each of its pixels lies on the visible face of its solids (or, with no face beneath, on the
## rule's plane, see AssetEntry) and takes its normal from the normal map, or without one from the face.
## The Occluder's anchor (the middle of the front bottom edge) is the sprite's `anchor_px`.

signal changed

## The normal map's encoding (Prowadnice v2): channel = NORMAL_ZERO + NORMAL_SCALE · component.
const NORMAL_ZERO: float = 128.0
const NORMAL_SCALE: float = 127.0
## A decoded vector shorter than this is no normal (the map's empty pixel).
const NORMAL_MIN_LENGTH: float = 0.5

## Normal map in the encoding of Prowadnice v2: colour = 128 + 127·(nx, nz, −ny) in Blender's axes
## (R right, G up, B towards the camera). Optional; it must cover every opaque pixel.
@export var normal_map: Texture2D:
	set(value):
		normal_map = value
		_changed()
## The anchor in the sprite: the corner of a pixel, in pixels from the sprite's top-left.
@export var anchor_px: Vector2i = Vector2i.ZERO:
	set(value):
		anchor_px = value
		offset = Vector2(-anchor_px)
		_changed()

## The anchor's screen position, rounded to a whole pixel (set by the Occluder).
var _anchor_screen_px: Vector2i = Vector2i.ZERO


func _init() -> void:
	centered = false
	texture_changed.connect(_changed)


func _get_configuration_warnings() -> PackedStringArray:
	var found: PackedStringArray = warnings()
	if not get_parent() is Occluder:
		found.append("An AssetSprite must be a child of an Occluder.")
	return found


## Snaps the sprite so its anchor sits on the whole pixel nearest the Occluder's anchor on screen.
func snap_to(anchor_screen: Vector2) -> void:
	_anchor_screen_px = Vector2i(anchor_screen.round())
	position = Vector2(_anchor_screen_px) - anchor_screen


## The sprite's top-left pixel on screen, relative to the Location's origin.
func top_left_px() -> Vector2i:
	return _anchor_screen_px - anchor_px


## Problems with the asset's data the author should see (the normal map's size and gaps).
func warnings() -> PackedStringArray:
	var found: PackedStringArray = PackedStringArray()
	if texture == null or normal_map == null:
		return found
	if normal_map.get_size() != texture.get_size():
		found.append("The normal map's size %s differs from the sprite's %s." % [normal_map.get_size(), texture.get_size()])
		return found
	var missing: int = missing_normals(texture.get_image(), normal_map.get_image())
	if missing > 0:
		found.append("%d opaque sprite pixels have no normal (128, 128, 128) in the normal map." % missing)
	return found


## A pixel of the normal map → unit normal in the engine's axes (x right, d towards the camera, z up);
## zero when the pixel holds no normal.
static func decode_normal(color: Color) -> Vector3:
	var encoded: Vector3 = (Vector3(color.r8, color.b8, color.g8) - Vector3.ONE * NORMAL_ZERO) / NORMAL_SCALE
	return encoded.normalized() if encoded.length() > NORMAL_MIN_LENGTH else Vector3.ZERO


## How many opaque pixels of the sprite have no normal in the map.
static func missing_normals(sprite: Image, normals: Image) -> int:
	var count: int = 0
	for y: int in sprite.get_height():
		for x: int in sprite.get_width():
			if sprite.get_pixel(x, y).a >= 0.5 and decode_normal(normals.get_pixel(x, y)) == Vector3.ZERO:
				count += 1
	return count


func _changed() -> void:
	update_configuration_warnings()
	changed.emit()
