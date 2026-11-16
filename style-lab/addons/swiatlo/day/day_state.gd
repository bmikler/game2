class_name DayState
extends RefCounted
## The day state: everything that depends on the hour at a given moment. A pure function of
## (day curves, sky profile, hour, the Location's exposure reference); the engine computes it once
## per frame for the whole Location (`compute` reuses this object).

const DAY_H: float = 24.0
## Lowest scene brightness for exposure (lux), so log2 stays finite.
const MIN_BRIGHTNESS: float = 0.001

var hour: float = 0.0
## The map's top is north (comparison with the default south at the top): the sun's direction turns
## 180° about the vertical, nothing else changes.
var north_at_top: bool = false
## Degrees above the horizon.
var sun_elevation: float = 0.0
## Compass degrees (90 east, 180 south, 270 west).
var sun_azimuth: float = 0.0
## Unit direction towards the sun in the world (x right, d towards the camera, z up).
var sun_direction: Vector3 = Vector3.UP
var sun_color: Color = Color.WHITE
## Lux perpendicular to the rays, after cloud cover.
var sun_intensity: float = 0.0
## Disc radius in degrees, after cloud cover.
var sun_disc: float = 0.0
var sky_color: Color = Color.WHITE
var sky_intensity: float = 0.0
var ambient_color: Color = Color.WHITE
var ambient_intensity: float = 0.0
var cloud_cover: float = 0.0
## The Location's exposure reference: the share of open-ground light its surfaces typically get.
var exposure_reference: float = 1.0
## Light multiplier before stylisation (automatic exposure from open-ground light × reference).
var exposure: float = 1.0
## `Y_ref`, the A′ level grid's anchor in lux before exposure: open sky and ambient on flat ground
## (no sun, so sky shadow boundaries stand still while the sun moves) × the exposure reference.
var level_anchor: float = 1.0


static func from_hour(curves: DayCurves, sky: SkyProfile, at_hour: float, north_up: bool = false,
		reference: float = 1.0) -> DayState:
	var state: DayState = DayState.new()
	state.compute(curves, sky, at_hour, north_up, reference)
	return state


## Recomputes this state for an hour (any value; wrapped into 0–24). `reference` is the Location's
## exposure reference (1 outdoors).
func compute(curves: DayCurves, sky: SkyProfile, at_hour: float, north_up: bool = false,
		reference: float = 1.0) -> void:
	hour = fposmod(at_hour, DAY_H)
	north_at_top = north_up
	var day: float = hour / DAY_H
	sun_elevation = curves.sun_elevation.sample(hour)
	sun_azimuth = curves.sun_azimuth.sample(hour)
	var elevation: float = deg_to_rad(sun_elevation)
	var azimuth: float = deg_to_rad(sun_azimuth)
	# North is +d (towards the camera), east is −x (screen left).
	sun_direction = Vector3(-sin(azimuth) * cos(elevation), cos(azimuth) * cos(elevation), sin(elevation))
	if north_at_top:
		sun_direction = Vector3(-sun_direction.x, -sun_direction.y, sun_direction.z)
	cloud_cover = clampf(curves.cloud_cover.sample(hour), 0.0, 1.0)

	sun_color = curves.sun_color.sample(day)
	sun_intensity = maxf(curves.sun_intensity.sample(hour), 0.0) * (1.0 - cloud_cover)
	sun_disc = curves.sun_disc.sample(hour) * lerpf(1.0, curves.overcast_disc_gain, cloud_cover)

	var night: float = sky.night_share(sun_elevation)
	sky_color = curves.sky_color.sample(day).lerp(sky.night_color, night)
	sky_color = sky_color.lerp(curves.overcast_sky_color, cloud_cover)
	sky_intensity = lerpf(maxf(curves.sky_intensity.sample(hour), 0.0), sky.night_intensity, night)
	sky_intensity *= lerpf(1.0, curves.overcast_sky_gain, cloud_cover)

	ambient_color = curves.ambient_color.sample(day)
	ambient_intensity = maxf(curves.ambient_intensity.sample(hour), 0.0)

	exposure_reference = maxf(reference, MIN_BRIGHTNESS)
	var brightness: float = maxf(_open_ground_lux().get_luminance() * exposure_reference, MIN_BRIGHTNESS)
	exposure = pow(2.0, -curves.exposure.sample(log(brightness) / log(2.0)))
	var open_sky: Color = sky_color * sky_intensity + ambient_color * ambient_intensity
	level_anchor = maxf(open_sky.get_luminance() * exposure_reference, MIN_BRIGHTNESS)


## Light on flat open ground without shadows (sun, sky, ambient) after exposure; multiplies the
## ground's albedo.
func floor_light() -> Color:
	var light: Color = _open_ground_lux() * exposure
	light.a = 1.0
	return light


## Lux on open ground, in the colour of the sources.
func _open_ground_lux() -> Color:
	var sun: float = sun_intensity * maxf(sun_direction.z, 0.0)
	var total: Color = sun_color * sun + sky_color * sky_intensity + ambient_color * ambient_intensity
	total.a = 1.0
	return total
