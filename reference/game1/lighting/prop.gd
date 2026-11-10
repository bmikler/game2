class_name Prop
extends Node2D
## A piece of furniture with an optional normal map. Origin: where it stands, base_y above the bottom
## of its pixels (0 for most; a desk with its chair pulled out stands higher than the chair's wheels).
## It is y-sorted with actors by that point. Optional footprint that blocks walking. Wall-hung props
## sit behind everything in the room.

const ON_WALL_Z: int = -15

@export var texture: Texture2D
@export var normal_map: Texture2D
@export_range(0, 3) var slot: int = 0
@export var on_wall: bool = false
@export var base_y: int = 0 ## Px from the bottom of the pixels up to the feet.
@export var blocker: Vector2 = Vector2.ZERO ## Footprint size in px, 0: walk through.
## Lit like an actor (ActorLight twins: the light at its feet over its whole height), for tall props by
## the back wall whose top would sit on the wall, out of the floor lights.
@export var lit_as_actor: bool = false
## Self-lit pixels (a switched-on screen): the same size as texture, drawn unshaded over it at
## glow_energy (above 1 blooms). The light it casts is a LightFixture.
@export var glow_texture: Texture2D
@export var glow_energy: float = 1.6

var sprite: Sprite2D ## Built in _ready.


func _ready() -> void:
	var canvas_texture: CanvasTexture = CanvasTexture.new()
	canvas_texture.diffuse_texture = texture
	canvas_texture.normal_texture = normal_map
	sprite = Sprite2D.new()
	sprite.texture = canvas_texture
	sprite.centered = false
	sprite.offset = _feet_offset() + Vector2(0, base_y)
	var receiver: int = LightMasks.Receiver.ACTOR if lit_as_actor else LightMasks.Receiver.SOLID
	sprite.light_mask = LightMasks.of(slot, receiver)
	sprite.material = Lit.material()
	if on_wall:
		z_index = ON_WALL_Z
	add_child(sprite)
	if glow_texture != null:
		var glow: Sprite2D = Sprite2D.new()
		glow.texture = glow_texture
		glow.centered = false
		glow.offset = sprite.offset
		var unshaded: CanvasItemMaterial = CanvasItemMaterial.new()
		unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		glow.material = unshaded
		glow.modulate = Color(glow_energy, glow_energy, glow_energy)
		add_child(glow)


## Footprint in global pixels (empty when it does not block).
func footprint() -> Rect2:
	if blocker == Vector2.ZERO:
		return Rect2()
	return Rect2(global_position.x - blocker.x / 2.0, global_position.y - blocker.y, blocker.x, blocker.y)


## Bottom-centre origin on the lowest opaque row.
func _feet_offset() -> Vector2:
	var image: Image = texture.get_image()
	return Vector2(-floori(image.get_width() / 2.0), -image.get_used_rect().end.y)
