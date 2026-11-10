class_name WindowLightProfile
extends Resource
## How windows bring light into a room, shared by every window. Openings and panes are per window
## (WindowLight).

@export_group("Daylight")
@export var df_near: float = 0.08 ## Daylight factor at the foot of the window.
## Extra glow at the foot of the window by night (snow and town light), in lux; fades in with sun.night.
@export var night_glow_lux: float = 0.0
## Street lamps and town lights: the glow's colour, mixed with the sky's by its share of the light.
@export var night_glow_color: Color = Color(1.0, 0.68, 0.38)
## Average daylight a window adds to the room, as lux × m² per m² of glass, for the sky and for the
## sun. The room divides the sum by its floor area.
@export var sky_flux_coef: float = 0.224
@export var sun_flux_coef: float = 1.12
@export var min_lit_energy: float = 0.02 ## Below this sun energy the window has no beams.

@export_group("View")
## The view is the outside seen at the room's exposure: sky_lux × X / view_ref_lux shows the images
## 1:1, softened by view_power (a lit room dims the glass, the day glows) and capped.
@export var view_power: float = 0.3
@export var view_ref_lux: float = 600.0
@export var view_max: float = 1.4
@export var top_glass_view_max: float = 1.0 ## Glass in a wall top: brighter loses its gradient.
@export var night_view_gain: float = 1.0 ## The view by night, times this (fades in with sun.night).

@export_group("Beam")
@export var beam_energy: float = 0.13
@export var beam_widen: float = 2.0 ## Far end width / glass width across the beam.
@export var beam_falloff: float = 1.4 ## Falloff exponent along the beam.
@export var beam_gain: float = 1.0
@export var beam_flat: float = 0.25 ## Share of the length at full brightness.
@export var beam_extend: float = 1.7 ## How far past the floor landing the beam reaches and fades out.
@export var beam_ref_m2: float = 1.42 ## Glass area of a full-strength beam (a back window).
@export var beam_min_area_k: float = 0.6 ## Smaller glass weakens the beam, down to this factor.

@export_group("Bounce and air")
@export var air_energy: float = 0.8
@export var air_stretch: float = 1.2
@export var bounce_energy: float = 0.3
@export var bounce_scale: float = 0.9
@export var bounce_tint: float = 1.4
@export var floor_albedo: Color = Color("8a8276") ## Tints the bounce.

@export_group("Reveals")
@export var reveal_full_phi_deg: float = 43.0 ## Sun this far off the normal fully lights a reveal.
@export var reveal_side_energy: float = 0.5
@export var reveal_sill_energy: float = 0.35

@export_group("Rim")
@export var rim_energy: float = 2.2 ## Rim energy per sun energy, actor fully in the beam.

@export_group("Snow")
## Snow falling behind a back window's glass: untextured squares, the same 90 flakes for any window
## size (denser in a small one), emitted from a strip above the opening wider than it.
@export var snow_amount: int = 90
@export var snow_lifetime: float = 8.0
@export var snow_preprocess: float = 8.0 ## Seconds simulated up front: already falling in the first frame.
@export var snow_emit_above: float = 6.0 ## Px above the opening's top.
@export var snow_emit_width: float = 0.73 ## Half-width of the strip, per opening width.
@export var snow_emit_half_height: float = 4.0
@export var snow_direction: Vector2 = Vector2(0.25, 1.0)
@export var snow_spread: float = 12.0
@export var snow_gravity: Vector2 = Vector2(0, 1.5)
@export var snow_velocity_min: float = 7.0
@export var snow_velocity_max: float = 13.0
@export var snow_scale_min: float = 1.0
@export var snow_scale_max: float = 2.0
## Colour by day, at golden hour and at night (mixed in that order), times the view's brightness.
@export var snow_day: Color = Color(1.1, 1.1, 1.15)
@export var snow_gold: Color = Color(1.0, 0.82, 0.7)
@export var snow_night: Color = Color(0.5, 0.58, 0.85)

@export_group("Side and front windows")
## A window in a wall top is only a few pixels, and a strong beam without a visible source reads as a
## lamp, so its beam is a little weaker.
@export var top_beam_k: float = 0.8
@export var top_pillow_along: float = 2.2 ## Sky pillow's length along the wall, per window length.
@export var top_sill_m: float = 0.61 ## Opening above the floor...
@export var top_head_m: float = 0.25 ## ... and below the ceiling.
@export var top_facing_full: float = 0.25 ## How squarely the sun must face the wall for a full beam.


## How bright the view outside is at the room's exposure, before its cap.
func view_energy(sun: SunSample, exposure: float) -> float:
	return pow(sun.sky_lux * exposure / view_ref_lux, view_power) * lerpf(1.0, night_view_gain, sun.night)


## Sky light at the foot of the window (the pillow), with the night glow, in lux.
func sky_glow_lux(sun: SunSample) -> float:
	return sun.sky_lux * df_near + night_glow_lux * sun.night


## Colour of that light: the sky's, warmed by the night glow's share.
func sky_glow_color(sun: SunSample) -> Color:
	var total: float = sky_glow_lux(sun)
	var share: float = night_glow_lux * sun.night / total if total > 0.0 else 0.0
	return sun.sky_color.lerp(night_glow_color, share)


## Smaller glass, weaker beam.
func beam_area_k(glass_m2: float) -> float:
	return clampf(sqrt(glass_m2 / beam_ref_m2), beam_min_area_k, 1.0)
