class_name LightEngine
extends Node
## The light engine's controller, one per Location. The hour is the only time input: from the day
## curves and the sky profile of the LocationEnvironment it makes the day state once per frame, and
## from that and the scene description (the Location's contract nodes) the light buffer, shown over
## the Location's picture. The engine must sit in the Location's viewport.

signal state_changed(state: DayState)

## What the engine shows over the picture: nothing extra, the solids' edges, the receivers, or the
## channels (the geometry of each light: red the sun, blue the sky share).
enum DebugView { NONE, SOLIDS, RECEIVERS, CHANNELS }

## The one projection of the engine, shared with the contract nodes.
const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")

@export var curves: DayCurves = preload("res://addons/swiatlo/tuning/day_curves.tres")
## Hour of the day, 0–24.
@export_range(0.0, 24.0, 0.01) var hour: float = 12.0
## Game minutes per real second (0 stops time).
@export var rate: float = 1.0

var _state: DayState = DayState.new()
var _north_at_top: bool = false
var _environment: LocationEnvironment
var _fallback_sky: SkyProfile = SkyProfile.new()
var _fallback_tuning: TuningSet = TuningSet.new()
var _description: SceneDescription = SceneDescription.new()
var _debug_view: DebugView = DebugView.NONE
## The A′ mode switched in F1 (−1: the tuning set's own).
var _style_mode_override: int = -1
## The short-step dither length picked in F1 (negative: the tuning set's own).
var _full_dither_override: float = -1.0
## The sky style picked in F1 (−1: the tuning set's own).
var _sky_style_override: int = -1
# Helper nodes without an owner: never saved into the scene.
var _buffer: LightBuffer
var _solids_overlay: SolidsOverlay


func _ready() -> void:
	refresh_environment()
	_buffer = LightBuffer.new()
	add_child(_buffer)
	_solids_overlay = SolidsOverlay.new()
	_solids_overlay.visible = false
	add_child(_solids_overlay)
	for warning: String in warnings():
		push_warning("Light engine: %s" % warning)
	rebuild_scene()


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


## Builds the scene description again from the Location's contract nodes.
func rebuild_scene() -> void:
	_description = SceneDescription.from_tree(get_tree(), PROJECTION)
	_buffer.set_scene(_description, PROJECTION)
	_solids_overlay.shapes = _description.solids
	_recompute()


## Scene errors the author should see (no LocationEnvironment, or several; assets' data).
func warnings() -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	if is_inside_tree():
		for node: Node in get_tree().get_nodes_in_group(Occluder.GROUP):
			for warning: String in (node as Occluder).asset_warnings():
				result.append("%s: %s" % [node.name, warning])
	for warning: String in tuning_set().warnings():
		result.append("tuning set: %s" % warning)
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


## Compares the map with north at the top (the default is south): only the sun's direction turns.
func set_north_at_top(north: bool) -> void:
	_north_at_top = north
	_recompute()


func set_debug_view(view: DebugView) -> void:
	_debug_view = view
	_solids_overlay.visible = view == DebugView.SOLIDS
	match view:
		DebugView.RECEIVERS:
			_buffer.set_view(LightBuffer.View.RECEIVERS)
		DebugView.CHANNELS:
			_buffer.set_view(LightBuffer.View.CHANNELS)
		_:
			_buffer.set_view(LightBuffer.View.LIGHT)


func debug_view() -> DebugView:
	return _debug_view


func state() -> DayState:
	return _state


func scene_description() -> SceneDescription:
	return _description


## Screen pixels the light buffer covers, relative to the Location's origin.
func buffer_area() -> Rect2i:
	return _buffer.area()


## The light buffer as last rendered (natural light in lux per pixel).
func buffer_image() -> Image:
	return _buffer.image()


## The light after A′ stylisation and exposure, as last rendered (what multiplies the albedo).
func styled_image() -> Image:
	return _buffer.styled_image()


## Whether the sky layer is complete: it is built over a few frames after loading or changing the
## Location (until then the sky is already there, from fewer directions).
func is_sky_complete() -> bool:
	return _buffer.is_sky_complete()


func sky() -> SkyProfile:
	if is_instance_valid(_environment) and _environment.sky != null:
		return _environment.sky
	return _fallback_sky


## The Location's tuning set (a default one without a LocationEnvironment).
func tuning_set() -> TuningSet:
	if is_instance_valid(_environment) and _environment.tuning_set != null:
		return _environment.tuning_set
	return _fallback_tuning


## The Location's exposure reference (1 without a LocationEnvironment).
func exposure_reference() -> float:
	if is_instance_valid(_environment):
		return _environment.exposure_reference
	return 1.0


## Compares the A′ modes live (F1) without changing the tuning set.
func set_style_mode(mode: TuningSet.StyleMode) -> void:
	_style_mode_override = mode
	_recompute()


## The A′ mode in use: the F1 switch's, or else the tuning set's.
func style_mode() -> TuningSet.StyleMode:
	if _style_mode_override >= 0:
		return _style_mode_override as TuningSet.StyleMode
	return tuning_set().style_mode


## Compares short-step dither lengths live (F1 variants) without changing the tuning set.
func set_full_dither_px(px: float) -> void:
	_full_dither_override = px
	_recompute()


## The short-step dither length in use: the F1 variant's, or else the tuning set's.
func full_dither_px() -> float:
	if _full_dither_override >= 0.0:
		return _full_dither_override
	return tuning_set().full_dither_px


## Compares sky styles live (F1 variants) without changing the tuning set.
func set_sky_style(style: TuningSet.SkyStyle) -> void:
	_sky_style_override = style
	_recompute()


## The sky style in use: the F1 variant's, or else the tuning set's.
func sky_style() -> TuningSet.SkyStyle:
	if _sky_style_override >= 0:
		return _sky_style_override as TuningSet.SkyStyle
	return tuning_set().sky_style


func _recompute() -> void:
	_state.compute(curves, sky(), hour, _north_at_top, exposure_reference())
	if is_instance_valid(_buffer):
		_buffer.set_tuning(tuning_set(), style_mode(), full_dither_px(), sky_style())
		_buffer.set_state(_state)
	state_changed.emit(_state)
