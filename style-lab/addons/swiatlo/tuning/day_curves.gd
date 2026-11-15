@tool
class_name DayCurves
extends Resource
## Day curves: the one set of artistic data for the whole game from which the day state is made.
## Curves span hours 0–24; gradients take hour / 24 as their offset. Intensities in lux.

const DEFAULT_PATH: String = "res://addons/swiatlo/tuning/day_curves.tres"

@export_group("Sun path")
## Sun elevation above the horizon in degrees (negative: below it).
@export var sun_elevation: Curve
## Sun azimuth in compass degrees: 90 east (screen left), 180 south (top), 270 west.
@export var sun_azimuth: Curve
## Sun disc radius in degrees (the width of the sun's penumbra).
@export var sun_disc: Curve

@export_group("Sun")
@export var sun_color: Gradient
## Sun intensity under a clear sky, perpendicular to the rays.
@export var sun_intensity: Curve

@export_group("Sky")
## The daytime sky; the night sky comes from the Location's sky profile.
@export var sky_color: Gradient
@export var sky_intensity: Curve

@export_group("Ambient")
@export var ambient_color: Gradient
@export var ambient_intensity: Curve

@export_group("Cloud cover")
## The fixed daily cloud pattern: 0 clear, 1 overcast. Sun × (1 − cloud cover).
@export var cloud_cover: Curve
## The colour the sky whitens to under full cover.
@export var overcast_sky_color: Color = Color(0.86, 0.88, 0.9)
## Sky intensity multiplier under full cover.
@export var overcast_sky_gain: float = 1.5
## Sun disc radius multiplier under full cover.
@export var overcast_disc_gain: float = 4.0

@export_group("Exposure")
## Automatic exposure: scene brightness in EV (log2 of lux on open ground) → white point in EV
## (the EV that shows albedo × 1); light multiplier = 2^−white point.
@export var exposure: Curve
