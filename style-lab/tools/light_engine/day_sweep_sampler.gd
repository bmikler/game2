class_name DaySweepSampler
extends Node
## Reads a LightEngine's last rendered light into a DaySweep frame on the GPU (engine ticket 29):
## every `stride`-th buffer pixel, three numbers each, one small readback.

const SHADER: Shader = preload("res://tools/light_engine/day_sweep_sample.gdshader")

var _view: SubViewport
var _canvas: ColorRect
var _material: ShaderMaterial


func _init() -> void:
	_view = SubViewport.new()
	_view.use_hdr_2d = true
	_view.disable_3d = true
	_view.transparent_bg = true
	_view.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_view)
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_canvas = ColorRect.new()
	_canvas.material = _material
	_view.add_child(_canvas)


## The engine's light at its current hour as a frame of `sweep` (sized by its `prepare`); call after
## the engine rendered that hour. Waits one frame for its own render.
func sample(engine: LightEngine, sweep: DaySweep) -> DaySweep.Frame:
	var state: DayState = engine.state()
	var textures: Array[Texture2D] = engine.buffer_textures()
	_view.size = sweep.size
	_canvas.size = Vector2(sweep.size)
	_material.set_shader_parameter(&"natural", textures[0])
	_material.set_shader_parameter(&"artificial", textures[1])
	_material.set_shader_parameter(&"has_artificial", textures[1] != null)
	_material.set_shader_parameter(&"styled", textures[2])
	_material.set_shader_parameter(&"stride", sweep.stride)
	var sun_light: Color = state.sun_color * state.sun_intensity
	_material.set_shader_parameter(&"sun_light", Vector3(sun_light.r, sun_light.g, sun_light.b))
	_material.set_shader_parameter(&"to_lux", 1.0 / state.exposure)
	_material.set_shader_parameter(&"smooth_sky", engine.tuning_set().sky_style == TuningSet.SkyStyle.SMOOTH)
	_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	var image: Image = _view.get_texture().get_image()
	image.convert(Image.FORMAT_RGBAF)
	var frame: DaySweep.Frame = DaySweep.Frame.new()
	frame.hour = state.hour
	frame.sun_elevation = state.sun_elevation
	frame.exposure = state.exposure
	frame.open_lux = state.floor_light().get_luminance() / state.exposure
	frame.source_lights = state.source_lights.duplicate()
	var anchor_ev: float = engine.tuning_set().anchor_ev
	frame.level_anchors = Vector2(LightStyle.lamps_anchor_lux(anchor_ev),
			LightStyle.sun_anchor_lux(Vector3(sun_light.r, sun_light.g, sun_light.b), state.sun_direction.z, anchor_ev))
	frame.data = image.get_data().to_float32_array()
	sweep.frames.append(frame)
	return frame
