class_name SkyLayer
extends Node
## The light buffer's sky layer: the share of the sky dome each pixel's receiver sees (geometry
## only). Built once per scene description over several frames, a pass of directions per frame; the
## buffer only multiplies it by the day state's sky colour × intensity. A helper of the LightBuffer;
## it has no owner, so it is never saved into a scene.

## Emitted after each pass reaches the layer's texture (`passes_done` of `PASS_COUNT`).
signal pass_rendered(passes_done: int)

const SHADER: Shader = preload("res://addons/swiatlo/buffer/sky_layer.gdshader")
## Directions per pass and passes per build: 2048 directions over 32 frames (engine constants, not
## tuning; a pass must stay short enough for a frame). At most 6144 directions in all (counts in
## three half-float channels).
const SAMPLES_PER_PASS: int = 64
const PASS_COUNT: int = 32

var _view: SubViewport
var _material: ShaderMaterial
var _canvas: ColorRect
## Passes whose result is in the texture, and the pass sent to render (−1: none).
var _passes_done: int = PASS_COUNT
var _pass_sent: int = -1
## Frames drawn when the pass was sent: it is in the texture once a later frame has been drawn.
var _sent_after_frame: int = 0


func _init() -> void:
	_view = SubViewport.new()
	_view.use_hdr_2d = true
	_view.disable_3d = true
	_view.transparent_bg = true
	_view.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_view.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	_view.size = Vector2i.ONE
	add_child(_view)
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_material.set_shader_parameter(&"samples_per_pass", SAMPLES_PER_PASS)
	_material.set_shader_parameter(&"pass_count", PASS_COUNT)
	_canvas = ColorRect.new()
	_canvas.material = _material
	_view.add_child(_canvas)


func _enter_tree() -> void:
	RenderingServer.frame_post_draw.connect(_on_frame_drawn)


func _exit_tree() -> void:
	RenderingServer.frame_post_draw.disconnect(_on_frame_drawn)


## Starts building the layer for a scene description (the same data and area as the buffer's).
func build(area: Rect2i, solids: Texture2D, solid_count: int, receivers: Texture2D, receiver_count: int,
		projection: LightProjection) -> void:
	_view.size = area.size if area.has_area() else Vector2i.ONE
	_canvas.size = Vector2(_view.size)
	_material.set_shader_parameter(&"solids", solids)
	_material.set_shader_parameter(&"solid_count", solid_count)
	_material.set_shader_parameter(&"receivers", receivers)
	_material.set_shader_parameter(&"receiver_count", receiver_count)
	_material.set_shader_parameter(&"area_origin_px", Vector2(area.position))
	_material.set_shader_parameter(&"px_per_m", projection.px_per_m)
	_material.set_shader_parameter(&"depth_factor", projection.depth_factor)
	_passes_done = 0
	_pass_sent = -1
	_view.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	_send_pass(0)


## The layer: counts of open directions in red + green + blue (see `share_scale`).
func texture() -> Texture2D:
	return _view.get_texture()


## What the texture's red + green + blue must be multiplied by for the sky share (1: the whole sky):
## one over the directions done so far (each pass covers the whole dome evenly, so the share is
## usable before the last pass); 0 before the first pass.
func share_scale() -> float:
	return 1.0 / float(_passes_done * SAMPLES_PER_PASS) if _passes_done > 0 else 0.0


func is_complete() -> bool:
	return _passes_done >= PASS_COUNT


func _send_pass(index: int) -> void:
	_material.set_shader_parameter(&"pass_index", index)
	_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	_pass_sent = index
	_sent_after_frame = Engine.get_frames_drawn()


## Counts the pass sent before this frame was drawn and sends the next one.
func _on_frame_drawn() -> void:
	if _pass_sent < 0 or Engine.get_frames_drawn() <= _sent_after_frame:
		return
	_passes_done = _pass_sent + 1
	_pass_sent = -1
	if _passes_done < PASS_COUNT:
		_send_pass(_passes_done)
	pass_rendered.emit(_passes_done)
