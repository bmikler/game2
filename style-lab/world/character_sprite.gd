class_name CharacterSprite
extends Node2D
## PROTOTYPE (ticket Przepis postaci): a standing character sprite, lit like the player, next to the
## mannequins. Origin: the feet (y-sorts with the world).

var texture: Texture2D
var slot: int = 0 ## Light-mask slot of the room it stands in.


func _ready() -> void:
	material = Lit.material()
	light_mask = LightMasks.of(slot, LightMasks.Receiver.ACTOR)


func _draw() -> void:
	if texture == null:
		return
	var config: ProjectionConfig = ProjectionConfig.current()
	PlaceholderActor.draw_sprite(self, texture, config.px(config.actor_height_m))
