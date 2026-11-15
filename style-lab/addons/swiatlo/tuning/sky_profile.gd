@tool
class_name SkyProfile
extends Resource
## A Location's sky profile: the night sky (e.g. with a city glow, or dark with a moon). The daytime
## sky comes from the day curves; the night takes over smoothly as the sun goes below the horizon.

@export var night_color: Color = Color(0.29, 0.33, 0.56)
## Sky intensity at night in lux.
@export var night_intensity: float = 10.0
## Sun elevation (degrees) where the night sky begins.
@export var night_from_elevation: float = 0.0
## Sun elevation (degrees) from which the sky is fully night.
@export var night_full_at: float = -8.0


## The night's share of the sky (0 day, 1 night) at this sun elevation.
func night_share(sun_elevation: float) -> float:
	return smoothstep(night_from_elevation, night_full_at, sun_elevation)
