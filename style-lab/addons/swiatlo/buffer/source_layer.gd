class_name SourceLayer
extends ProgressiveLayer
## A source layer of the light buffer: the light of one source group (one profile) at intensity 1,
## without colour. Built once per scene description over several frames; switching on, colour and
## intensity at the hour are only a multiplier (SourceLight).

const SHADER: Shader = preload("res://addons/swiatlo/buffer/source_layer.gdshader")
## Samples of each source's area per pass and passes per build: 128 over 16 frames (engine
## constants, not tuning).
const SAMPLES_PER_PASS: int = 8
const PASS_COUNT: int = 16


func _init() -> void:
	super(SHADER, PASS_COUNT)
	_material.set_shader_parameter(&"samples_per_pass", SAMPLES_PER_PASS)


## The group this layer holds: its index among the scene description's sources and its profile.
func set_group(group: int, profile: SourceProfile, sources: Texture2D, source_count: int) -> void:
	_material.set_shader_parameter(&"group", group)
	_material.set_shader_parameter(&"sources", sources)
	_material.set_shader_parameter(&"source_count", source_count)
	_material.set_shader_parameter(&"falloff", ImageTexture.create_from_image(profile.falloff_data()))
	_material.set_shader_parameter(&"reach_m", maxf(profile.reach_m(), 0.001))


## What the texture's red + green + blue must be multiplied by for the light at intensity 1: one over
## the passes done (each pass covers the whole area, so the light is usable before the last one); 0
## before the first pass.
func light_scale() -> float:
	return 1.0 / float(_passes_done) if _passes_done > 0 else 0.0
