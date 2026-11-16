@tool
class_name SkyProfile
extends Resource
## A Location's sky profile: the sky's own night light (e.g. a city's glow, or a dark village sky
## with a moon). It is always added to the daytime sky of the day curves: at night it is all the
## sky gives, by day it is lost in daylight. One sum, so dawn and dusk have no dip or bump.

@export var night_color: Color = Color(0.29, 0.33, 0.56)
## The night sky's own light in lux (added at every hour).
@export var night_intensity: float = 10.0
