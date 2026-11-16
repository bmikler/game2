class_name ProgressiveLayer
extends Node
## A light buffer layer built once per scene description over several frames, one pass per frame,
## into a target never cleared in between (each pass adds its share with additive blending). The
## sky layer and the source layers. A helper of the LightBuffer; it has no owner, so it is never
## saved into a scene. Each pass sees `pass_index` and `pass_count` in its shader.

## Emitted after each pass reaches the layer's texture (`passes_done` of `pass_count`).
signal pass_rendered(passes_done: int)

var _view: SubViewport
var _material: ShaderMaterial
var _canvas: ColorRect
var _pass_count: int = 1
## Passes whose result is in the texture, and the pass sent to render (−1: none).
var _passes_done: int = 0
var _pass_sent: int = -1
## A build waits one frame before its first pass, so the asset layer it reads is drawn.
var _start_pending: bool = false
## Frames drawn when the pass was sent: it is in the texture once a later frame has been drawn.
var _sent_after_frame: int = 0


func _init(shader: Shader, pass_count: int) -> void:
	_pass_count = pass_count
	_passes_done = pass_count
	_view = SubViewport.new()
	_view.use_hdr_2d = true
	_view.disable_3d = true
	_view.transparent_bg = true
	_view.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_view.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	_view.size = Vector2i.ONE
	add_child(_view)
	_material = ShaderMaterial.new()
	_material.shader = shader
	_material.set_shader_parameter(&"pass_count", pass_count)
	_canvas = ColorRect.new()
	_canvas.material = _material
	_view.add_child(_canvas)


func _enter_tree() -> void:
	RenderingServer.frame_post_draw.connect(_on_frame_drawn)


func _exit_tree() -> void:
	RenderingServer.frame_post_draw.disconnect(_on_frame_drawn)


## Starts building the layer for a scene description (the same data and area as the buffer's).
func build(area: Rect2i, solids: Texture2D, solid_count: int, receivers: Texture2D, receiver_count: int,
		asset_layer: Texture2D, assets: Texture2D, projection: LightProjection) -> void:
	_view.size = area.size if area.has_area() else Vector2i.ONE
	_canvas.size = Vector2(_view.size)
	_material.set_shader_parameter(&"solids", solids)
	_material.set_shader_parameter(&"solid_count", solid_count)
	_material.set_shader_parameter(&"receivers", receivers)
	_material.set_shader_parameter(&"receiver_count", receiver_count)
	_material.set_shader_parameter(&"area_origin_px", Vector2(area.position))
	_material.set_shader_parameter(&"px_per_m", projection.px_per_m)
	_material.set_shader_parameter(&"depth_factor", projection.depth_factor)
	_material.set_shader_parameter(&"asset_layer", asset_layer)
	_material.set_shader_parameter(&"assets", assets)
	restart()


## Builds the layer again from the start (e.g. the receivers' modelling changed the normals).
func restart() -> void:
	_passes_done = 0
	_pass_sent = -1
	_start_pending = true


## The receivers' modelling (tuning set): sprite pixels take the light on the normal it gives.
func set_modelling(value: float) -> void:
	_material.set_shader_parameter(&"modelling", value)


func texture() -> Texture2D:
	return _view.get_texture()


func passes_done() -> int:
	return _passes_done


func is_complete() -> bool:
	return _passes_done >= _pass_count


func _send_pass(index: int) -> void:
	_material.set_shader_parameter(&"pass_index", index)
	_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	_pass_sent = index
	_sent_after_frame = Engine.get_frames_drawn()


## Counts the pass sent before this frame was drawn and sends the next one.
func _on_frame_drawn() -> void:
	if _start_pending:
		_start_pending = false
		_view.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
		_send_pass(0)
		return
	if _pass_sent < 0 or Engine.get_frames_drawn() <= _sent_after_frame:
		return
	_passes_done = _pass_sent + 1
	_pass_sent = -1
	if _passes_done < _pass_count:
		_send_pass(_passes_done)
	pass_rendered.emit(_passes_done)
