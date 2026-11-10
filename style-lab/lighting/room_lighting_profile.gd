class_name RoomLightingProfile
extends Resource
## How a kind of room reacts to its light. Shared by rooms of the same kind; the colour slot and the
## rects are per room (RoomLighting).

@export var floor_lux: float = 3.0 ## Night is never black, but dark.
@export var exposure_alpha: float = 0.3 ## Below 1: dark rooms stay darker.
@export var fixture_schedule: Curve ## Scheduled fixtures' level by hour / 24; null = always on.
## style-lab: a space under the open sky (a street): its daylight is the sky and the sun on the whole
## floor, not what windows let in.
@export var outdoor: bool = false
@export var outdoor_night_lux: float = 20.0 ## Outside at night: snow and town glow, in lux.

@export_group("Ambient")
## Sky tint mixed with the lamps' tint by their share.
@export var sun_ambient_share: float = 0.1 ## How much of the sun fills the room.
@export var art_ambient_share: float = 0.1 ## How much of the lamps' light fills the room (low: pools).
@export var tint_saturation: float = 0.75 ## The sky's tint is cool and not very saturated.
@export var art_tint: Color = Color(0.97, 0.97, 0.93)
@export var ambient_max: float = 1.1

@export_group("Dust")
## Faint warm motes that hang and drift in the beams, so they do not read as snow.
@export var dust_amount: int = 25 ## 0: no dust.
@export var dust_lifetime: float = 14.0
@export var dust_velocity_min: float = 0.2
@export var dust_velocity_max: float = 0.8
@export var dust_color: Color = Color(1.0, 0.92, 0.8, 0.22)
