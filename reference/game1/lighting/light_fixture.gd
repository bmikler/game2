class_name LightFixture
extends Node2D
## A placed light fixture (lamp, tube, door spill). Its room sets the mask slot and calls apply() with
## the level and exposure.

@export var def: FixtureDef

var _light: PointLight2D
var _actor: PointLight2D ## ActorLight twin, when the fixture lights actors.


func _ready() -> void:
	_light = _make_light()
	if def.actor_twin and def.receivers & LightMasks.Receiver.ACTOR:
		_actor = ActorLight.twin(_light)


func setup(slot: int) -> void:
	var main_receivers: int = def.receivers & ~LightMasks.Receiver.ACTOR if _actor != null else def.receivers
	_light.range_item_cull_mask = LightMasks.of(slot, main_receivers)
	if _actor != null:
		_actor.range_item_cull_mask = LightMasks.of(slot, LightMasks.Receiver.ACTOR)


## Also light these mask bits (the floors of the other rooms in the same space).
func add_receivers(mask: int) -> void:
	_light.range_item_cull_mask |= mask


## The mask bits this fixture's light reaches.
func cull_mask() -> int:
	return _light.range_item_cull_mask


## This fixture's share of the room's light (lux × m²).
func flux(level: float) -> float:
	return def.lux * level * def.footprint_m2


func apply(level: float, exposure: float) -> void:
	_light.energy = Exposure.energy(def.lux * level, exposure, LightTextures.peak(def.shape))
	_light.enabled = level > 0.01
	if _actor != null:
		ActorLight.sync(_light, _actor)


func _make_light() -> PointLight2D:
	var light: PointLight2D = PointLight2D.new()
	light.texture = LightTextures.get_shape(def.shape)
	light.texture_scale = def.texture_scale
	light.offset = def.offset
	light.color = def.color
	light.height = def.height
	add_child(light)
	return light
