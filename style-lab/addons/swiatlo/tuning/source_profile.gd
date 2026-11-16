@tool
class_name SourceProfile
extends Resource
## A light source's profile: the kind of light (a lamp on a post, a lit window), shared by every
## LightSource that uses it. The light at a receiver is colour × intensity (both from the hour) ×
## falloff (from the distance) × the cosine at the receiver × visibility, averaged over the source's
## area; a rectangle also × its own cosine (it shines from one face). Sources of one profile make
## one layer of the light buffer, computed once at intensity 1.

## The light buffer's channel: natural (like the sun and sky) or artificial (lamps).
enum Channel { NATURAL, ARTIFICIAL }

## Texels the falloff is sampled into for the shaders, over 0 … reach.
const FALLOFF_TEXELS: int = 128

@export var channel: Channel = Channel.ARTIFICIAL:
	set(value):
		channel = value
		emit_changed()
## Colour over the day (offset = hour / 24).
@export var color: Gradient:
	set(value):
		color = value
		emit_changed()
## Lux where the falloff is 1, over hours 0–24: 0 is off, so the curve holds the hours it shines.
@export var intensity: Curve:
	set(value):
		intensity = value
		emit_changed()
## Multiplier over the distance from the source in metres; the curve's domain ends at the source's
## reach (beyond it no light). Its value at 0 is the light on the source's own surface.
@export var falloff: Curve:
	set(value):
		falloff = value
		emit_changed()


## Colour × lux at an hour (black when a curve is missing).
func light_at(hour: float) -> Color:
	if color == null or intensity == null:
		return Color.BLACK
	var hour_of_day: float = fposmod(hour, DayState.DAY_H)
	var light: Color = color.sample(hour_of_day / DayState.DAY_H) * maxf(intensity.sample(hour_of_day), 0.0)
	light.a = 1.0
	return light


## How far the light reaches in metres (0 without a falloff).
func reach_m() -> float:
	return falloff.max_domain if falloff != null else 0.0


## The falloff over 0 … reach in FALLOFF_TEXELS texels (red), for the shaders.
func falloff_data() -> Image:
	var image: Image = Image.create_empty(FALLOFF_TEXELS, 1, false, Image.FORMAT_RF)
	for index: int in FALLOFF_TEXELS:
		var at: float = reach_m() * float(index) / float(FALLOFF_TEXELS - 1)
		var value: float = maxf(falloff.sample(at), 0.0) if falloff != null else 0.0
		image.set_pixel(index, 0, Color(value, 0.0, 0.0))
	return image
