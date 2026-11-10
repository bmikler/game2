class_name Mannequin
extends Node2D
## PROTOTYPE: a standing Figure in one view, lit like the player, to compare the three drawn views
## side by side with furniture. Origin: the feet (y-sorts with the world).

@export var view: Figure.View = Figure.View.FRONT
@export var mirrored: bool = false
@export_range(0, 3) var slot: int = 0 ## Light-mask slot of the room it stands in.


func _ready() -> void:
	material = Lit.material()
	light_mask = LightMasks.of(slot, LightMasks.Receiver.ACTOR)


func _draw() -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	Figure.draw(self, Vector2.ZERO, config.px(config.actor_height_m), view, mirrored, config.depth_factor)
