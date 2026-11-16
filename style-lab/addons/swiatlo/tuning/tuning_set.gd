@tool
class_name TuningSet
extends Resource
## A tuning set: look constants that do not depend on the hour (A′ stylisation, penumbra, receivers,
## light shafts, window patches, dust). A Location picks one in its LocationEnvironment. Every field
## of the spec is here; the ones whose part of the engine is not built yet name the engine ticket
## that will read them.

## A′ on the luminance of the sum of both channels (continuous colour), or on the natural and the
## artificial channel apart, then summed.
enum StyleMode { SUM, PER_CHANNEL }
## The ordered pattern in the dither seam between two levels.
enum SeamPattern { BAYER, CHECKER }
## How light shafts and dust are drawn (they get no A′ levels).
enum ScatterStyle { SMOOTH, DITHER }

@export var label: String = ""

@export_group("A′ stylisation")
@export var style_mode: StyleMode = StyleMode.SUM:
	set(value):
		style_mode = value
		emit_changed()
## Size of one light level in EV (stops).
@export_range(0.1, 2.0, 0.05) var level_stops: float = 0.5:
	set(value):
		level_stops = value
		emit_changed()
## Width of the dither seam at a level boundary in game pixels (0: plain posterisation). Where a
## whole level fits in the seam (a sun penumbra), the seam covers it.
@export_range(0.0, 8.0, 0.5) var seam_px: float = 3.0:
	set(value):
		seam_px = value
		emit_changed()
@export var seam_pattern: SeamPattern = SeamPattern.BAYER:
	set(value):
		seam_pattern = value
		emit_changed()
## `Y_ref`: where the level grid sits, in EV over the light of open sky on flat ground (sky +
## ambient, × the Location's reference). 0 puts open sky in the middle of a level.
@export_range(-1.0, 1.0, 0.05) var anchor_ev: float = 0.0:
	set(value):
		anchor_ev = value
		emit_changed()

@export_group("Penumbra")
## Penumbra from geometry × this (engine ticket 14).
@export_range(0.0, 4.0, 0.05) var penumbra_gain: float = 1.0:
	set(value):
		penumbra_gain = value
		emit_changed()
## The widest penumbra in screen pixels (engine ticket 14).
@export_range(0.0, 32.0, 0.5) var penumbra_max_px: float = 6.0:
	set(value):
		penumbra_max_px = value
		emit_changed()

@export_group("Receivers")
## Sprites on solids (furniture, characters): how far the normal map shapes the light, 0 the solid
## face's normal (flat), 1 the normal map's (the asset prototype's start point).
@export_range(0.0, 1.0, 0.01) var receiver_modelling: float = 1.0:
	set(value):
		receiver_modelling = value
		emit_changed()
## Rim light from a sun behind the sprite, on the edges turned away from the camera (× sun light).
@export_range(0.0, 4.0, 0.01) var receiver_rim: float = 0.0:
	set(value):
		receiver_rim = value
		emit_changed()
## The least light a sprite keeps, as a share of the ambient and sky light of open ground.
@export_range(0.0, 1.0, 0.01) var receiver_fill: float = 0.0:
	set(value):
		receiver_fill = value
		emit_changed()

@export_group("Light shafts and window patches")
## Light shafts (scatter in the air) × this (engine ticket 22).
@export_range(0.0, 4.0, 0.01) var shaft_strength: float = 1.0:
	set(value):
		shaft_strength = value
		emit_changed()
## Window patches on floors and walls × this (engine ticket 20).
@export_range(0.0, 4.0, 0.01) var window_patch_strength: float = 1.0:
	set(value):
		window_patch_strength = value
		emit_changed()

@export_group("Shaft and dust style")
## Light shafts smooth or dithered (engine ticket 22).
@export var shaft_style: ScatterStyle = ScatterStyle.DITHER:
	set(value):
		shaft_style = value
		emit_changed()
## The shafts' own dither seam in game pixels (engine ticket 22).
@export_range(0.0, 8.0, 0.5) var shaft_seam_px: float = 3.0:
	set(value):
		shaft_seam_px = value
		emit_changed()
## Dust motes show where the scatter exceeds this, in lux (engine ticket 22).
@export_range(0.0, 1000.0, 0.1) var dust_threshold: float = 1.0:
	set(value):
		dust_threshold = value
		emit_changed()
## Dust motes per m² of shaft (engine ticket 22).
@export_range(0.0, 500.0, 0.5) var dust_density: float = 75.0:
	set(value):
		dust_density = value
		emit_changed()
## How fast dust motes drift, metres per second (engine ticket 22).
@export_range(0.0, 1.0, 0.005) var dust_motion: float = 0.05:
	set(value):
		dust_motion = value
		emit_changed()
