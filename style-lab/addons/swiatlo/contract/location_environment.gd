@tool
class_name LocationEnvironment
extends Node
## Scene contract node, one per Location: data shared by the whole scene. No look knobs: the look
## lives in the tuning set and the sky profile.

signal changed

const GROUP: StringName = &"swiatlo_location_environment"

## The Location's tuning set (interior or outdoor).
@export var tuning_set: TuningSet = preload("res://addons/swiatlo/tuning/outdoor.tres"):
	set(value):
		tuning_set = value
		changed.emit()
## The Location's night sky (e.g. a city with a glow, a village with a moon).
@export var sky: SkyProfile = preload("res://addons/swiatlo/tuning/sky_city.tres"):
	set(value):
		sky = value
		changed.emit()
## Air density (dust, fog); 0: clear air, no light shafts.
@export_range(0.0, 1.0, 0.01) var air_density: float = 0.0:
	set(value):
		air_density = value
		changed.emit()
## Exposure reference brightness: the share of open-ground light (sun, sky, ambient) the
## Location's surfaces typically get, 1 outdoors, less inside (light only through openings).
## Automatic exposure and the A′ anchor (`Y_ref`) follow it; there is no manual exposure.
@export_range(0.001, 1.0, 0.001) var exposure_reference: float = 1.0:
	set(value):
		exposure_reference = value
		changed.emit()


func _enter_tree() -> void:
	add_to_group(GROUP)
