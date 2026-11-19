class_name LightBuffer
extends Node
## The light buffer: the Location's light, one pixel per game pixel over the buffer area, in HDR
## (natural channel: sun, sky, ambient and natural sources; artificial channel: the other sources,
## SourceLight). Rendered in its own viewport when the scene or the day
## state changes (and while the sky layer is being built), styled by the A′ pass (with exposure)
## and shown over the Location's picture: albedo × styled light. A helper of the LightEngine; it
## has no owner, so it is never saved into a scene.

enum View { LIGHT, RECEIVERS, CHANNELS }

const BUFFER_SHADER: Shader = preload("res://addons/swiatlo/buffer/light_buffer.gdshader")
const DISPLAY_SHADER: Shader = preload("res://addons/swiatlo/buffer/buffer_display.gdshader")
const DEBUG_SHADER: Shader = preload("res://addons/swiatlo/buffer/buffer_debug.gdshader")
## Debug view numbers the buffer shader understands.
const SHADER_VIEWS: Dictionary[View, int] = { View.LIGHT: 0, View.RECEIVERS: 2, View.CHANNELS: 3 }

var _view: SubViewport
var _canvas: ColorRect
var _material: ShaderMaterial
## The penumbra pass (the same shader over the buffer with hard sun shadows): softens the sun only
## near its edges; the buffer the rest reads.
var _soft_view: SubViewport
var _soft_canvas: ColorRect
var _soft_material: ShaderMaterial
var _display: Sprite2D
var _display_material: ShaderMaterial
var _debug_material: ShaderMaterial
var _area: Rect2i = Rect2i()
var _sky: SkyLayer
var _style: LightStyle
var _assets: AssetLayer
## The asset layer with the moving assets too (drawn when they move), and the moving layer.
var _assets_all: AssetLayer
var _moving: MovingLayer
var _sources: SourceLight
## The static solids followed by the moving ones, the assets likewise, and the silhouettes' frames.
var _all_solids: ImageTexture
var _all_assets: ImageTexture
var _silhouettes: ImageTexture
var _windows: Array[Rect2i] = []
var _modelling: float = -1.0
## The penumbra last set: on (1 or 0), gain, widest in screen pixels (−1: none yet).
var _penumbra: Vector3 = -Vector3.ONE


func _init() -> void:
	# The asset layer first: the layers that read it are drawn after it.
	_assets = AssetLayer.new()
	add_child(_assets)
	_assets_all = AssetLayer.new(true)
	add_child(_assets_all)
	# The source layers and channels next: the moving layer reads them, the buffer and the A′ pass
	# read the moving layer.
	_sources = SourceLight.new()
	add_child(_sources)
	_sources.changed.connect(_redraw)
	_moving = MovingLayer.new()
	add_child(_moving)
	_view = SubViewport.new()
	_view.use_hdr_2d = true
	_view.disable_3d = true
	# Alpha carries the sun's share, not coverage.
	_view.transparent_bg = true
	_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	_view.size = Vector2i.ONE
	add_child(_view)
	_material = ShaderMaterial.new()
	_material.shader = BUFFER_SHADER
	_canvas = ColorRect.new()
	_canvas.material = _material
	_view.add_child(_canvas)
	# After the hard buffer: it reads it.
	_soft_view = SubViewport.new()
	_soft_view.use_hdr_2d = true
	_soft_view.disable_3d = true
	_soft_view.transparent_bg = true
	_soft_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	_soft_view.size = Vector2i.ONE
	add_child(_soft_view)
	_soft_material = ShaderMaterial.new()
	_soft_material.shader = BUFFER_SHADER
	_soft_material.set_shader_parameter(&"penumbra_pass", true)
	_soft_material.set_shader_parameter(&"hard_buffer", _view.get_texture())
	_soft_canvas = ColorRect.new()
	_soft_canvas.material = _soft_material
	_soft_view.add_child(_soft_canvas)
	# After the buffer's viewport: it reads it.
	_style = LightStyle.new()
	add_child(_style)

	_sky = SkyLayer.new()
	add_child(_sky)
	_sky.pass_rendered.connect(_on_sky_pass)
	_set_param(&"sky_share", _moving.texture(SourceProfile.Channel.ARTIFICIAL))
	_set_param(&"natural_sources", _moving.texture(SourceProfile.Channel.NATURAL))
	_set_param(&"artificial_sources", _moving.texture(SourceProfile.Channel.ARTIFICIAL))
	_set_param(&"asset_layer", _assets_all.texture())

	_display_material = ShaderMaterial.new()
	_display_material.shader = DISPLAY_SHADER
	_debug_material = ShaderMaterial.new()
	_debug_material.shader = DEBUG_SHADER
	_display = Sprite2D.new()
	_display.centered = false
	_display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_display.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	_display.texture = _style.texture()
	_display.material = _display_material
	add_child(_display)


## Takes a new scene description (after loading or changing the Location).
func set_scene(description: SceneDescription, projection: LightProjection) -> void:
	_area = description.area
	_display.visible = _area.has_area()
	_view.size = _area.size if _area.has_area() else Vector2i.ONE
	_canvas.size = Vector2(_view.size)
	_soft_view.size = _view.size
	_soft_canvas.size = _canvas.size
	_display.position = Vector2(_area.position)
	# The layers built once see the static solids and assets; the buffer and the moving layer, drawn
	# every frame, also the moving ones (set_moving).
	var solids: ImageTexture = ImageTexture.create_from_image(description.solid_data())
	var receivers: ImageTexture = ImageTexture.create_from_image(description.receiver_data())
	_silhouettes = ImageTexture.create_from_image(description.silhouette_data())
	_set_param(&"silhouettes", _silhouettes)
	_set_param(&"receivers", receivers)
	_set_param(&"receiver_count", description.receivers.size())
	_set_param(&"area_origin_px", Vector2(_area.position))
	_set_param(&"px_per_m", projection.px_per_m)
	_set_param(&"depth_factor", projection.depth_factor)
	var assets: ImageTexture = ImageTexture.create_from_image(description.asset_data())
	_assets.build(description)
	_assets_all.build(description)
	_sky.set_silhouettes(_silhouettes)
	_sky.build(_area, solids, description.solids.size(), receivers, description.receivers.size(), _assets.texture(),
			assets, projection)
	_sources.build(description, solids, receivers, assets, _assets.texture(), projection, maxf(_modelling, 0.0),
			_silhouettes)
	var sources: ImageTexture = ImageTexture.create_from_image(description.source_data())
	_moving.build(description, receivers, sources, projection, _sources, _sky.texture())
	_moving.set_sky_scale(_sky.share_scale())
	_moving.set_modelling(maxf(_modelling, 0.0))
	if _penumbra.x >= 0.0:
		_moving.set_penumbra(_penumbra.x > 0.5, _penumbra.y, _penumbra.z)
	_all_solids = null
	_all_assets = null
	_windows = []
	set_moving(description, [])
	_set_param(&"has_natural_sources", _sources.has_channel(SourceProfile.Channel.NATURAL))
	var has_artificial: bool = _sources.has_channel(SourceProfile.Channel.ARTIFICIAL)
	var artificial: Texture2D = _moving.texture(SourceProfile.Channel.ARTIFICIAL)
	_style.set_input(_soft_view.get_texture(), artificial if has_artificial else null, _view.size, _area.position)
	_redraw()


## Takes where the moving Occluders are now (the description's moving solids and assets, refreshed)
## and the buffer pixels to compute around them (SceneDescription.moving_windows).
func set_moving(description: SceneDescription, windows: Array[Rect2i]) -> void:
	_all_solids = _updated(_all_solids, description.all_solid_data())
	_all_assets = _updated(_all_assets, description.all_asset_data())
	_set_param(&"solids", _all_solids)
	_set_param(&"solid_count", description.solids.size() + description.moving_solids.size())
	_set_param(&"assets", _all_assets)
	_assets_all.place_moving(description)
	_windows = windows
	_moving.set_moving(_all_solids, description.solids.size() + description.moving_solids.size(), _all_assets,
			_assets_all.texture(), _silhouettes, windows)
	_redraw()


## The windows last set (buffer pixels the moving layer computes).
func moving_windows() -> Array[Rect2i]:
	return _windows


## Takes the day state of this frame.
func set_state(state: DayState) -> void:
	_set_param(&"sun_direction", state.sun_direction)
	_set_param(&"sun_tan_disc", tan(deg_to_rad(state.sun_disc)))
	_set_param(&"sun_light", _rgb(state.sun_color) * state.sun_intensity)
	_set_param(&"sky_light", _rgb(state.sky_color) * state.sky_intensity)
	_set_param(&"ambient_light", _rgb(state.ambient_color) * state.ambient_intensity)
	_style.set_exposure(state.exposure, state.level_anchor)
	_style.set_sun(_rgb(state.sun_color) * state.sun_intensity)
	_sources.set_state(state)
	_moving.set_state(state)
	_redraw()


## Takes the Location's tuning set (receivers, A′ in `style_mode`, penumbra unless `penumbra_on` is
## off: the F1 comparison); a new modelling or penumbra rebuilds the source layers.
func set_tuning(tuning: TuningSet, style_mode: TuningSet.StyleMode, penumbra_on: bool = true) -> void:
	_style.set_tuning(tuning, style_mode)
	_set_param(&"modelling", tuning.receiver_modelling)
	_set_param(&"rim", tuning.receiver_rim)
	_set_param(&"fill", tuning.receiver_fill)
	_set_param(&"penumbra_on", penumbra_on)
	_set_param(&"penumbra_gain", tuning.penumbra_gain)
	_set_param(&"penumbra_max_px", tuning.penumbra_max_px)
	var penumbra: Vector3 = Vector3(1.0 if penumbra_on else 0.0, tuning.penumbra_gain, tuning.penumbra_max_px)
	if penumbra != _penumbra:
		_penumbra = penumbra
		_sources.set_penumbra(penumbra_on, tuning.penumbra_gain, tuning.penumbra_max_px)
		_moving.set_penumbra(penumbra_on, tuning.penumbra_gain, tuning.penumbra_max_px)
	if tuning.receiver_modelling != _modelling:
		_modelling = tuning.receiver_modelling
		_sky.set_modelling(_modelling)
		_sky.restart()
		_sources.set_modelling(_modelling)
		_moving.set_modelling(_modelling)
	_redraw()


func set_view(view: View) -> void:
	_set_param(&"debug_view", SHADER_VIEWS[view])
	_display.material = _display_material if view == View.LIGHT else _debug_material
	_display.texture = _style.texture() if view == View.LIGHT else _soft_view.get_texture()
	_redraw()


## Screen pixels the buffer covers, relative to the Location's origin.
func area() -> Rect2i:
	return _area


## The buffer as last rendered (lux per pixel, HDR).
func image() -> Image:
	return _soft_view.get_texture().get_image()


## The artificial channel as last rendered (lux per pixel, HDR; with the moving Occluders; alpha is
## the sky share).
func artificial_image() -> Image:
	return _moving.texture(SourceProfile.Channel.ARTIFICIAL).get_image()


## The styled light as last rendered (after A′ and exposure, HDR).
func styled_image() -> Image:
	return _style.image()


## Whether the sky layer of the current scene is complete (it takes a few frames after `set_scene`).
func is_sky_complete() -> bool:
	return _sky.is_complete()


## Whether the sky layer and every source layer are complete.
func is_complete() -> bool:
	return _sky.is_complete() and _sources.is_complete()


## The source layers (one per source group).
func sources() -> SourceLight:
	return _sources


func _on_sky_pass(_passes_done: int) -> void:
	_moving.set_sky_scale(_sky.share_scale())
	_redraw()


func _redraw() -> void:
	_moving.redraw()
	_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	_soft_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	_style.redraw()


## Sets a parameter of the buffer and of its penumbra pass alike.
func _set_param(param: StringName, value: Variant) -> void:
	_material.set_shader_parameter(param, value)
	_soft_material.set_shader_parameter(param, value)


## `texture` holding `image`: updated in place when the size is the same, else a new one.
static func _updated(texture: ImageTexture, image: Image) -> ImageTexture:
	if texture != null and texture.get_size() == Vector2(image.get_size()):
		texture.update(image)
		return texture
	return ImageTexture.create_from_image(image)


static func _rgb(color: Color) -> Vector3:
	return Vector3(color.r, color.g, color.b)
