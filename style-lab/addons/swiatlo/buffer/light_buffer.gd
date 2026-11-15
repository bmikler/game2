class_name LightBuffer
extends Node
## The light buffer: the Location's light, one pixel per game pixel over the buffer area, in HDR
## (natural channel: sun, sky, ambient). Rendered in its own viewport when the scene or the day
## state changes, and shown over the Location's picture (albedo × light × exposure). A helper of the
## LightEngine; it has no owner, so it is never saved into a scene.

enum View { LIGHT, RECEIVERS }

const BUFFER_SHADER: Shader = preload("res://addons/swiatlo/buffer/light_buffer.gdshader")
const DISPLAY_SHADER: Shader = preload("res://addons/swiatlo/buffer/buffer_display.gdshader")
const DEBUG_SHADER: Shader = preload("res://addons/swiatlo/buffer/buffer_debug.gdshader")
## Debug view number the buffer shader understands for receivers.
const SHADER_RECEIVERS: int = 2

var _view: SubViewport
var _canvas: ColorRect
var _material: ShaderMaterial
var _display: Sprite2D
var _display_material: ShaderMaterial
var _debug_material: ShaderMaterial
var _area: Rect2i = Rect2i()


func _init() -> void:
	_view = SubViewport.new()
	_view.use_hdr_2d = true
	_view.disable_3d = true
	_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	_view.size = Vector2i.ONE
	add_child(_view)
	_material = ShaderMaterial.new()
	_material.shader = BUFFER_SHADER
	_canvas = ColorRect.new()
	_canvas.material = _material
	_view.add_child(_canvas)

	_display_material = ShaderMaterial.new()
	_display_material.shader = DISPLAY_SHADER
	_debug_material = ShaderMaterial.new()
	_debug_material.shader = DEBUG_SHADER
	_display = Sprite2D.new()
	_display.centered = false
	_display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_display.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	_display.texture = _view.get_texture()
	_display.material = _display_material
	add_child(_display)


## Takes a new scene description (after loading or changing the Location).
func set_scene(description: SceneDescription, projection: LightProjection) -> void:
	_area = description.area
	_display.visible = _area.has_area()
	_view.size = _area.size if _area.has_area() else Vector2i.ONE
	_canvas.size = Vector2(_view.size)
	_display.position = Vector2(_area.position)
	_material.set_shader_parameter(&"solids", ImageTexture.create_from_image(description.solid_data()))
	_material.set_shader_parameter(&"solid_count", description.solids.size())
	_material.set_shader_parameter(&"receivers", ImageTexture.create_from_image(description.receiver_data()))
	_material.set_shader_parameter(&"receiver_count", description.receivers.size())
	_material.set_shader_parameter(&"area_origin_px", Vector2(_area.position))
	_material.set_shader_parameter(&"px_per_m", projection.px_per_m)
	_material.set_shader_parameter(&"depth_factor", projection.depth_factor)
	_redraw()


## Takes the day state of this frame.
func set_state(state: DayState) -> void:
	_material.set_shader_parameter(&"sun_direction", state.sun_direction)
	_material.set_shader_parameter(&"sun_light", _rgb(state.sun_color) * state.sun_intensity)
	_material.set_shader_parameter(&"sky_light", _rgb(state.sky_color) * state.sky_intensity)
	_material.set_shader_parameter(&"ambient_light", _rgb(state.ambient_color) * state.ambient_intensity)
	_display_material.set_shader_parameter(&"exposure", state.exposure)
	_redraw()


func set_view(view: View) -> void:
	var receivers: bool = view == View.RECEIVERS
	_material.set_shader_parameter(&"debug_view", SHADER_RECEIVERS if receivers else 0)
	_display.material = _debug_material if receivers else _display_material
	_redraw()


## Screen pixels the buffer covers, relative to the Location's origin.
func area() -> Rect2i:
	return _area


## The buffer as last rendered (lux per pixel, HDR).
func image() -> Image:
	return _view.get_texture().get_image()


func _redraw() -> void:
	_view.render_target_update_mode = SubViewport.UPDATE_ONCE


static func _rgb(color: Color) -> Vector3:
	return Vector3(color.r, color.g, color.b)
