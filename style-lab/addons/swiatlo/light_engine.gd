class_name LightEngine
extends Node
## The light engine's controller, one per Location. The hour is the only time input: from the day
## curves and the sky profile of the LocationEnvironment it makes the day state once per frame, and
## from that the Location's light. For now: flat ground without shadows (sun, sky, ambient) as a
## multiplier of the whole Location picture. The engine must sit in the Location's viewport.

signal state_changed(state: DayState)

@export var curves: DayCurves = preload("res://addons/swiatlo/tuning/day_curves.tres")
## Hour of the day, 0–24.
@export_range(0.0, 24.0, 0.01) var hour: float = 12.0
## Game minutes per real second (0 stops time).
@export var rate: float = 1.0

var _state: DayState = DayState.new()
var _environment: LocationEnvironment
var _fallback_sky: SkyProfile = SkyProfile.new()
var _modulate: CanvasModulate


func _ready() -> void:
	refresh_environment()
	# A helper node without an owner: never saved into the scene.
	_modulate = CanvasModulate.new()
	add_child(_modulate)
	for warning: String in warnings():
		push_warning("Light engine: %s" % warning)
	_recompute()


func _process(delta: float) -> void:
	advance(delta)


## Finds the LocationEnvironment in the tree (after loading or changing the Location).
func refresh_environment() -> void:
	if is_instance_valid(_environment) and _environment.changed.is_connected(_recompute):
		_environment.changed.disconnect(_recompute)
	_environment = null
	if not is_inside_tree():
		return
	var found: Array[Node] = get_tree().get_nodes_in_group(LocationEnvironment.GROUP)
	if not found.is_empty():
		_environment = found[0] as LocationEnvironment
		_environment.changed.connect(_recompute)


## Scene errors the author should see (no LocationEnvironment, or several).
func warnings() -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	var count: int = get_tree().get_nodes_in_group(LocationEnvironment.GROUP).size() if is_inside_tree() else 0
	if count == 0:
		result.append("no LocationEnvironment (fallback sky)")
	elif count > 1:
		result.append("%d LocationEnvironments, the first one counts" % count)
	return result


func set_hour(value: float) -> void:
	hour = fposmod(value, DayState.DAY_H)
	_recompute()


## Moves time on by `seconds` of real time at `rate` and recomputes the day state.
func advance(seconds: float) -> void:
	hour = fposmod(hour + seconds * rate / 60.0, DayState.DAY_H)
	_recompute()


func state() -> DayState:
	return _state


func sky() -> SkyProfile:
	if is_instance_valid(_environment) and _environment.sky != null:
		return _environment.sky
	return _fallback_sky


func _recompute() -> void:
	_state.compute(curves, sky(), hour)
	if is_instance_valid(_modulate):
		_modulate.color = _state.floor_light()
	state_changed.emit(_state)
