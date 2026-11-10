class_name TimeOfDayProfile
extends Resource
## What the day looks like outside, as data. Mood over realism: a simple sun arc instead of an
## ephemeris, low clear sun in the morning and evening, overcast at midday (the `clear` curve).
## Curves and gradients take hour / 24.

@export var sunrise: float = 7.7
@export var sunset: float = 17.3
@export var max_phi_deg: float = 43.0 ## Sun azimuth off south at sunrise and sunset.
@export var sun_max_sin_e: float = 0.26 ## Sin of the noon elevation, about 15°.
@export var c_high_sun: float = 1.3 ## Beam length per metre of height, sun at its highest.
@export var c_low_sun: float = 2.0 ## ... and at the horizon.
## The sun's beams start this long after sunrise and end this long before sunset: the sun clears the
## hills and roofs late and drops behind them early.
@export var sun_delay_h: float = 0.0
@export var sun_early_h: float = 0.0
@export var sun_fade_h: float = 0.5 ## How long the sun takes to come up from behind the hills.
@export var sun_lux: float = 3000.0 ## The sun at low clear sky; mood, not physics.
## The sun is always far above the room's light, so its knee sets how bright it looks (at most
## 2 × sun_knee): lower keeps the floor's colour and the sun's hue in it.
@export var sun_knee: float = 1.0
@export var sun_noon_color: Color = Color(1.0, 0.9, 0.76)
@export var sun_morning_color: Color = Color(1.0, 0.55, 0.38)
@export var sun_evening_color: Color = Color(1.0, 0.45, 0.18)
@export var warm_from_low: float = 0.2 ## How low the sun starts turning warm (0 high, 1 horizon).
@export var warm_full_low: float = 0.85
@export var gold_from_low: float = 0.25 ## How low the golden outside image starts to show.
@export var gold_full_low: float = 0.7
@export var dawn_before_h: float = 0.7 ## Day starts fading in this long before sunrise...
@export var dawn_after_h: float = 0.5 ## ... and is full this long after it.
@export var dusk_before_h: float = 0.5 ## Day starts fading out this long before sunset...
@export var dusk_after_h: float = 0.7 ## ... and is gone this long after it.
@export var twilight_lux: float = 300.0 ## Overcast sky: twilight + k × sin(elevation).
@export var overcast_k: float = 21000.0
@export var night_out_lux: float = 1.0
@export var night_sky_lux: float = 150.0 ## Mood floor for window light: snow and town glow.
@export var clear: Curve ## Cloud cover: 1 clear, 0 overcast.
@export var sky_color: Gradient ## Colour of the light falling in through windows.
@export var ambient: Gradient ## Sky tint for room ambient (only its hue is used).


func sample(hour: float) -> SunSample:
	var sun: SunSample = SunSample.new()
	sun.hour = hour
	var day_part: float = hour / 24.0
	var arc: float = clampf((hour - sunrise) / (sunset - sunrise), 0.0, 1.0)
	var low: float = 1.0 - sin(PI * arc)
	sun.day = smoothstep(sunrise - dawn_before_h, sunrise + dawn_after_h, hour) \
			* (1.0 - smoothstep(sunset - dusk_before_h, sunset + dusk_after_h, hour))
	sun.night = 1.0 - sun.day
	sun.gold = smoothstep(gold_from_low, gold_full_low, low)
	sun.sun_azimuth_deg = 180.0 + lerpf(-max_phi_deg, max_phi_deg, arc) # Morning sun from the east.
	sun.sun_c = lerpf(c_high_sun, c_low_sun, low)
	var rise: float = sunrise + sun_delay_h
	var drop: float = sunset - sun_early_h
	var up: float = smoothstep(rise, rise + sun_fade_h, hour) \
			* (1.0 - smoothstep(drop - sun_fade_h, drop, hour))
	sun.sun_knee = sun_knee
	sun.sun_lux = sun_lux * up * (clear.sample(day_part) if clear != null else 1.0)
	var warm: Color = sun_morning_color if arc < 0.5 else sun_evening_color
	sun.sun_color = sun_noon_color.lerp(warm, smoothstep(warm_from_low, warm_full_low, low))
	var sin_elevation: float = sun_max_sin_e * sin(PI * arc) * up
	sun.out_lux = lerpf(night_out_lux, twilight_lux, sun.day) + overcast_k * sin_elevation
	sun.sky_lux = maxf(sun.out_lux, night_sky_lux)
	sun.sky_color = sky_color.sample(day_part)
	var tint: Color = ambient.sample(day_part)
	sun.ambient_tint = tint / maxf(tint.r, maxf(tint.g, tint.b))
	return sun
