class_name LightStyle
extends Node
## The A′ stylisation pass: the light buffer's lux (natural channel, and the artificial one when
## there is one) → styled light after exposure, one pixel per buffer pixel, in its own viewport.
## The picture shows albedo × this; scatter (light shafts, dust) is added after it, unstyled.
## A helper of the LightBuffer, also usable alone on any light texture (the gates feed it gradients).

const SHADER: Shader = preload("res://addons/swiatlo/buffer/light_style.gdshader")
## Rec. 709 luma weights (as in the shader).
const LUMA: Vector3 = Vector3(0.2126, 0.7152, 0.0722)

var _view: SubViewport
var _canvas: ColorRect
var _material: ShaderMaterial
var _anchor_lux: float = 1.0
var _anchor_ev: float = 0.0
var _sun_light: Vector3 = Vector3.ZERO
var _sun_height: float = 1.0


func _init() -> void:
	_view = SubViewport.new()
	_view.use_hdr_2d = true
	_view.disable_3d = true
	_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	_view.size = Vector2i.ONE
	add_child(_view)
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_canvas = ColorRect.new()
	_canvas.material = _material
	_view.add_child(_canvas)


## The light to style (lux, HDR; the natural light's alpha is the sun's share, see `set_sun`), its size in pixels and the Location pixel of its first pixel
## (the dither pattern sticks to Location pixels). `artificial` may be null (no artificial light).
func set_input(natural: Texture2D, artificial: Texture2D, size: Vector2i, origin_px: Vector2i) -> void:
	_view.size = size.max(Vector2i.ONE)
	_canvas.size = Vector2(_view.size)
	_material.set_shader_parameter(&"natural", natural)
	_material.set_shader_parameter(&"artificial", artificial)
	_material.set_shader_parameter(&"has_artificial", artificial != null)
	_material.set_shader_parameter(&"size", _view.size)
	_material.set_shader_parameter(&"origin_px", Vector2(origin_px))
	redraw()


## The A′ constants of the tuning set; `style_mode` other than −1 replaces the set's mode (F1).
func set_tuning(tuning: TuningSet, style_mode: int = -1) -> void:
	_material.set_shader_parameter(&"mode", tuning.style_mode if style_mode < 0 else style_mode)
	_material.set_shader_parameter(&"full_dither_px", tuning.full_dither_px)
	_material.set_shader_parameter(&"sky_style", tuning.sky_style)
	_material.set_shader_parameter(&"level_stops", tuning.level_stops)
	_material.set_shader_parameter(&"seam_px", tuning.seam_px)
	_material.set_shader_parameter(&"seam_pattern", tuning.seam_pattern)
	_anchor_ev = tuning.anchor_ev
	_update_anchor()
	redraw()


## The day state's exposure (light multiplier) and level anchor (`Y_ref` of open sky, lux).
func set_exposure(exposure: float, anchor_lux: float) -> void:
	_material.set_shader_parameter(&"exposure", exposure)
	_anchor_lux = anchor_lux
	_update_anchor()
	redraw()


## The sun's light (colour × lux): the natural input's alpha × this is the sun's part of its light;
## `sun_height` the sun's height (its cosine on flat ground, `sun_direction.z`).
func set_sun(sun_light: Vector3, sun_height: float = 1.0) -> void:
	_material.set_shader_parameter(&"sun_light", sun_light)
	_sun_light = sun_light
	_sun_height = sun_height
	_update_anchor()
	redraw()


## Renders once more (after the input changed).
func redraw() -> void:
	_view.render_target_update_mode = SubViewport.UPDATE_ONCE


func texture() -> ViewportTexture:
	return _view.get_texture()


## The styled light as last rendered (after exposure, HDR).
func image() -> Image:
	return _view.get_texture().get_image()


## Where the lamps' levels sit with a smooth or dithered sky (lux before exposure): fixed, so a
## lamp's pool keeps its bands while the sky darkens (ticket 13).
static func lamps_anchor_lux(anchor_ev: float) -> float:
	return pow(2.0, anchor_ev)


## Where the sun's levels sit with a smooth or dithered sky (lux before exposure): its light on flat
## open ground, so flat ground in full sun keeps its level while the sun changes (engine ticket 30).
static func sun_anchor_lux(sun_light: Vector3, sun_height: float, anchor_ev: float) -> float:
	return maxf(sun_light.dot(LUMA) * maxf(sun_height, 0.0), DayState.MIN_BRIGHTNESS) * pow(2.0, anchor_ev)


func _update_anchor() -> void:
	_material.set_shader_parameter(&"anchor", maxf(_anchor_lux, DayState.MIN_BRIGHTNESS) * pow(2.0, _anchor_ev))
	_material.set_shader_parameter(&"hard_anchor", lamps_anchor_lux(_anchor_ev))
	_material.set_shader_parameter(&"sun_anchor", sun_anchor_lux(_sun_light, _sun_height, _anchor_ev))
