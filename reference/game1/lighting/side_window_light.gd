class_name SideWindowLight
extends Node2D
## A window in a side or front wall, which the 3/4 view shows only as glass in the wall top. A soft
## pillow of sky light along the wall and, while the sun stands in front of this wall, the same sun
## beam as a back-wall window, parallel to it, starting at that glass. Place the node on the inner edge
## of the wall where the window starts (side wall: at the floor y of its first px; front wall: at the
## floor's bottom edge).

const PILLOW_TEXTURE_LENGTH: float = 192.0 ## The SKY_PILLOW shape's width, for its scale.

@export var profile: WindowLightProfile
@export var wall_height_px: int = 104
@export var wall_azimuth_deg: float = 180.0 ## Outward normal, as on a WindowLight.
@export var span: int = 48 ## Px along the wall.
@export var into_right: bool = true ## Left wall: the light goes right (+x).
@export var into_up: bool = false ## Front wall: the light goes up (-y); span runs along x.
## The glass drawn in the wall top (RoomShell.glass_for(glass_kind, glass_gap)): brightened with the
## sky like a back window's view.
@export var shell: RoomShell
@export var glass_kind: String = ""
@export var glass_gap: Vector2i = Vector2i.ZERO

var _pillow: PointLight2D
var _beam: BeamCanvas


func _ready() -> void:
	_pillow = PointLight2D.new()
	_pillow.texture = LightTextures.get_shape(LightTextures.Shape.SKY_PILLOW)
	_pillow.offset = WindowLight.SKY_OFFSET
	_pillow.height = WindowLight.SKY_HEIGHT
	_pillow.scale = Vector2(profile.top_pillow_along * span / PILLOW_TEXTURE_LENGTH, 1.0)
	if into_up:
		_pillow.position = Vector2(span / 2.0, 0)
		_pillow.rotation = PI
	else:
		_pillow.position = Vector2(0, span / 2.0)
		_pillow.rotation = -PI / 2.0 if into_right else PI / 2.0
	add_child(_pillow)
	_beam = BeamCanvas.new()
	_beam.profile = profile
	add_child(_beam)


## `interior`: the room's back wall and floor in this node's pixels (the beam is clipped to it).
func setup(slot: int, interior: Rect2) -> void:
	_beam.interior = interior
	_pillow.range_item_cull_mask = LightMasks.of(slot, LightMasks.Receiver.FLOOR | LightMasks.Receiver.SOLID)


## Daylight this window adds to its room, lux × m²: x = sky, y = sun.
func flux(sun: SunSample) -> Vector2:
	return Vector2(
			sun.out_lux * profile.sky_flux_coef,
			sun.sun_lux * profile.sun_flux_coef * _facing(sun)) * _glass_m2()


func apply(sun: SunSample, exposure: float) -> void:
	var area_k: float = profile.beam_area_k(_glass_m2())
	# Sky: always the sky's colour, as strong as a back window's pillow (ADR 0007: lux only).
	_pillow.color = sun.sky_color
	_pillow.energy = Exposure.energy(
			sun.sky_lux * profile.df_near, exposure, LightTextures.peak(LightTextures.Shape.SKY_PILLOW)) * area_k
	_pillow.enabled = _pillow.energy > WindowLight.MIN_LIGHT_ENERGY
	if shell != null:
		var view_k: float = minf(profile.view_energy(sun, exposure), profile.top_glass_view_max)
		var layers: Array[Sprite2D] = shell.glass_for(glass_kind, glass_gap)
		if layers.size() == 3:
			layers[0].modulate = Color(view_k, view_k, view_k)
			layers[1].modulate = Color(view_k, view_k, view_k, sun.gold)
			layers[2].modulate = Color(view_k, view_k, view_k, sun.night)
	# Sun: one rule for every wall: the same screen direction as the back windows, gated by how
	# squarely the sun faces this wall.
	var azimuth: float = deg_to_rad(sun.sun_azimuth_deg)
	var travel: Vector2 = Vector2(sin(azimuth), -cos(azimuth)) * WindowLight.PX_M * sun.sun_c
	var facing: float = smoothstep(0.0, profile.top_facing_full, _facing(sun))
	var sun_k: float = Exposure.energy(
			sun.sun_lux, exposure, LightTextures.peak(LightTextures.Shape.FLAT), sun.sun_knee)
	var energy: float = profile.beam_energy * sun_k * area_k * facing * profile.top_beam_k
	# The beam starts at the glass as drawn in the wall top (on the floor line, 2 px into the room) and
	# lands as far as light from the middle of the opening falls.
	var fall_px: float = (profile.top_sill_m + wall_height_px / WindowLight.PX_M - profile.top_head_m) / 2.0 * WindowLight.PX_M
	var into: Vector2 = Vector2(0, -2) if into_up else Vector2(2 if into_right else -2, 0)
	var length: Vector2 = Vector2(span, 0) if into_up else Vector2(0, span)
	var near: PackedVector2Array = PackedVector2Array([Vector2.ZERO, length, length + into, into])
	var fall: PackedFloat32Array = PackedFloat32Array([fall_px, fall_px, fall_px, fall_px])
	_beam.paint(near, fall, travel, energy, sun.sun_color)


## Glass seen edge-on: span along the wall × the opening's height.
func _glass_m2() -> float:
	return span / WindowLight.PX_M * (wall_height_px / WindowLight.PX_M - profile.top_sill_m - profile.top_head_m)


## How squarely the sun stands in front of this wall (0 behind it).
func _facing(sun: SunSample) -> float:
	return clampf(cos(deg_to_rad(sun.sun_azimuth_deg - wall_azimuth_deg)), 0.0, 1.0)
