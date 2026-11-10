class_name SunSample
extends RefCounted
## Sun, sky and outside light for one moment. TimeOfDayProfile.sample() computes it once per game
## minute and passes it down. It holds no node references.

var hour: float = 0.0
var day: float = 0.0 ## 1 by day, 0 at night.
var night: float = 1.0
var gold: float = 0.0 ## Weight of the golden outside image (low sun).
var sun_azimuth_deg: float = 180.0 ## Compass azimuth, 180 = due south.
var sun_c: float = 1.3 ## Mood-compressed cot(elevation): beam length per metre of height.
var sun_lux: float = 0.0 ## The beam at clear sun, already scaled by cloud cover.
var sun_color: Color = Color.WHITE
var sun_knee: float = 1.5 ## Exposure.knee() point for the sun.
var out_lux: float = 0.0 ## Horizontal illuminance outside, overcast sky.
var sky_lux: float = 0.0 ## out_lux with the mood floor for the window light.
var sky_color: Color = Color.WHITE
var ambient_tint: Color = Color.WHITE ## Sky tint for ambient, normalised to max channel 1.
