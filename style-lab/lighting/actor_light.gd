class_name ActorLight
extends RefCounted
## Lights for actors standing in a floor light. A light's texture describes the light on the floor,
## and the engine reads it where a pixel is drawn. An actor is drawn up to about 2 m above its feet,
## so by the back wall its body sits on the wall, out of the lamps in front of it, and goes dark. Its
## twin, for actors only, reaches height_px() further up the screen: the whole body takes the light that
## falls at its feet. The twin stays where its source is, so normal maps shade the actor from the same
## direction as before.



## How far up the screen the twin reaches: 2 m (80 px at 40 px/m in game1).
static func height_px() -> float:
	return 2.0 * WindowLight.px_m()


## A child of `source` at its origin with the same look, its texture stretched up the screen.
static func twin(source: PointLight2D) -> PointLight2D:
	var light: PointLight2D = PointLight2D.new()
	light.texture = source.texture
	light.texture_scale = source.texture_scale
	light.height = source.height
	var texture_height: float = source.texture.get_height() * source.texture_scale
	var reach: float = height_px()
	# style-lab: the source may be shortened in depth (its scale.y); the twin is its child, so it takes
	# that scale too and undoes it.
	var source_y: float = source.scale.y
	var stretch: float = (texture_height * source_y + reach) / texture_height
	light.scale = Vector2(1.0, stretch / source_y)
	# The texture grows height_px(), half of it up and half down: move it up height_px() / 2 so its bottom
	# stays where the source ends. A light's offset is scaled by the node's scale, not by
	# texture_scale; the source's own offset is in screen pixels (its scale is 1).
	light.offset = (source.offset * Vector2(1.0, source_y) - Vector2(0.0, reach / 2.0)) / Vector2(1.0, stretch)
	source.add_child(light)
	return light


static func sync(source: PointLight2D, light: PointLight2D) -> void:
	light.color = source.color
	light.energy = source.energy
	light.enabled = source.enabled
