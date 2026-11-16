@tool
class_name TuningSet
extends Resource
## A tuning set: look constants that do not depend on the hour (A′ stylisation, penumbra, receivers,
## light shafts, window patches, dust). A Location picks one in its LocationEnvironment. The fields
## arrive with the parts of the engine that use them.

@export var label: String = ""

@export_group("Receivers")
## Sprites on solids (furniture, characters): how far the normal map shapes the light, 0 the solid
## face's normal (flat), 1 the normal map's (the asset prototype's start point).
@export_range(0.0, 1.0, 0.01) var receiver_modelling: float = 1.0:
	set(value):
		receiver_modelling = value
		emit_changed()
## Rim light from a sun behind the sprite, on the edges turned away from the camera (× sun light).
@export_range(0.0, 4.0, 0.01) var receiver_rim: float = 0.0:
	set(value):
		receiver_rim = value
		emit_changed()
## The least light a sprite keeps, as a share of the ambient and sky light of open ground.
@export_range(0.0, 1.0, 0.01) var receiver_fill: float = 0.0:
	set(value):
		receiver_fill = value
		emit_changed()
