class_name ActorLight
extends RefCounted
## Lights for actors standing in a floor light. A light's texture describes the light on the floor,
## and the engine reads it where a pixel is drawn. An actor is drawn up to about 2 m above its feet,
## so by the back wall its body sits on the wall, out of the lamps in front of it, and goes dark. Its
## twin, for actors only, reaches HEIGHT_PX further up the screen: the whole body takes the light that
## falls at its feet. The twin stays where its source is, so normal maps shade the actor from the same
## direction as before.

const HEIGHT_PX: float = 80.0


## A child of `source` at its origin with the same look, its texture stretched up the screen.
static func twin(source: PointLight2D) -> PointLight2D:
	var light: PointLight2D = PointLight2D.new()
	light.texture = source.texture
	light.texture_scale = source.texture_scale
	light.height = source.height
	var texture_height: float = source.texture.get_height() * source.texture_scale
	var stretch: float = (texture_height + HEIGHT_PX) / texture_height
	light.scale = Vector2(1.0, stretch)
	# The texture grows HEIGHT_PX, half of it up and half down: move it up HEIGHT_PX / 2 so its bottom
	# stays where the source ends. A light's offset is scaled by the node's scale, not by
	# texture_scale; the source's own offset is in screen pixels (its scale is 1).
	light.offset = (source.offset - Vector2(0.0, HEIGHT_PX / 2.0)) / Vector2(1.0, stretch)
	source.add_child(light)
	return light


static func sync(source: PointLight2D, light: PointLight2D) -> void:
	light.color = source.color
	light.energy = source.energy
	light.enabled = source.enabled
