class_name SkyLayer
extends ProgressiveLayer
## The light buffer's sky layer: the share of the sky dome each pixel's receiver sees (geometry
## only). Built once per scene description over several frames, a pass of directions per frame; the
## buffer only multiplies it by the day state's sky colour × intensity.

const SHADER: Shader = preload("res://addons/swiatlo/buffer/sky_layer.gdshader")
## Directions per pass and passes per build: 2048 directions over 32 frames (engine constants, not
## tuning; a pass must stay short enough for a frame). At most 6144 directions in all (counts in
## three half-float channels).
const SAMPLES_PER_PASS: int = 64
const PASS_COUNT: int = 32


func _init() -> void:
	super(SHADER, PASS_COUNT)
	_material.set_shader_parameter(&"samples_per_pass", SAMPLES_PER_PASS)


## What the texture's red + green + blue must be multiplied by for the sky share (1: the whole sky):
## one over the directions done so far (each pass covers the whole dome evenly, so the share is
## usable before the last pass); 0 before the first pass.
func share_scale() -> float:
	return 1.0 / float(_passes_done * SAMPLES_PER_PASS) if _passes_done > 0 else 0.0
