class_name MovingLayer
extends Node
## The light buffer's moving layer: the two source channels (natural, artificial; lux) and the sky
## share with the moving Occluders in them, drawn every frame they move (moving_layer.gdshader). Only
## the moving windows are computed; elsewhere it copies the layers built once. The targets are never
## cleared: when only the Occluders move, just the rect round this frame's and the last drawn frame's
## windows is drawn again (the rest already holds the copy); when an input changes (the layers built
## once, the lights, the tuning), the whole area. The natural channel is drawn only when the scene has
## natural sources (the buffer reads it only then). The artificial channel's viewport carries the sky
## share in alpha. A helper of the LightBuffer; it has no owner, so it is never saved into a scene.

const SHADER: Shader = preload("res://addons/swiatlo/buffer/moving_layer.gdshader")
## As in the shader.
const MAX_GROUPS: int = 16
const MAX_WINDOWS: int = 8

## Per SourceProfile.Channel: the viewport and its material.
var _views: Array[SubViewport] = []
var _materials: Array[ShaderMaterial] = []
var _canvases: Array[ColorRect] = []
## Per channel: whether it is drawn at all (the artificial one always: it holds the sky share).
var _drawn: Array[bool] = [false, true]
var _area_size: Vector2i = Vector2i.ONE
## The windows of the last frame drawn, and the rect to draw this frame (none: nothing to draw).
var _last_windows: Rect2i = Rect2i()
var _pending: Rect2i = Rect2i()
## Each group's light last set (a change redraws the whole area).
var _lights: PackedVector3Array = PackedVector3Array()


func _init() -> void:
	for channel: int in [SourceProfile.Channel.NATURAL, SourceProfile.Channel.ARTIFICIAL]:
		var view: SubViewport = SubViewport.new()
		view.use_hdr_2d = true
		view.disable_3d = true
		# Alpha carries the sky share, not coverage.
		view.transparent_bg = true
		view.render_target_update_mode = SubViewport.UPDATE_DISABLED
		# Outside the rect drawn this frame the target keeps what it holds.
		view.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
		view.size = Vector2i.ONE
		add_child(view)
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = SHADER
		material.set_shader_parameter(&"channel", channel)
		material.set_shader_parameter(&"with_sky", channel == SourceProfile.Channel.ARTIFICIAL)
		var canvas: ColorRect = ColorRect.new()
		canvas.material = material
		view.add_child(canvas)
		_canvases.append(canvas)
		_views.append(view)
		_materials.append(material)


func _enter_tree() -> void:
	if not RenderingServer.frame_pre_draw.is_connected(_on_frame_starts_drawing):
		RenderingServer.frame_pre_draw.connect(_on_frame_starts_drawing)


func _exit_tree() -> void:
	if RenderingServer.frame_pre_draw.is_connected(_on_frame_starts_drawing):
		RenderingServer.frame_pre_draw.disconnect(_on_frame_starts_drawing)


## Takes a new scene description: its area and data, the layers built once it adds the moving
## Occluders to, and the source groups' channels, reaches and falloffs.
func build(description: SceneDescription, receivers: Texture2D, sources: Texture2D, projection: LightProjection,
		source_light: SourceLight, sky_counts: Texture2D) -> void:
	var size: Vector2i = description.area.size if description.area.has_area() else Vector2i.ONE
	_area_size = size
	_last_windows = Rect2i()
	_lights = PackedVector3Array()
	for index: int in _views.size():
		_views[index].size = size
		var channel: SourceProfile.Channel = index as SourceProfile.Channel
		_materials[index].set_shader_parameter(&"channel_in", source_light.texture(channel))
		_materials[index].set_shader_parameter(&"has_channel_in", source_light.has_channel(channel))
		_drawn[index] = channel == SourceProfile.Channel.ARTIFICIAL or source_light.has_channel(channel)
	_set_param(&"receivers", receivers)
	_set_param(&"receiver_count", description.receivers.size())
	_set_param(&"area_origin_px", Vector2(description.area.position))
	_set_param(&"px_per_m", projection.px_per_m)
	_set_param(&"depth_factor", projection.depth_factor)
	_set_param(&"sources", sources)
	_set_param(&"source_count", description.sources.size())
	_set_param(&"sky_counts", sky_counts)
	_set_param(&"static_solid_count", description.solids.size())
	_set_param(&"static_asset_count", description.assets.size())
	var channels: PackedInt32Array = PackedInt32Array()
	var reaches: PackedFloat32Array = PackedFloat32Array()
	channels.resize(MAX_GROUPS)
	reaches.resize(MAX_GROUPS)
	channels.fill(-1)
	reaches.fill(0.001)
	var falloffs: Image = Image.create_empty(SourceProfile.FALLOFF_TEXELS, maxi(description.source_groups.size(), 1), false,
			Image.FORMAT_RF)
	for group: int in mini(description.source_groups.size(), MAX_GROUPS):
		var profile: SourceProfile = description.source_groups[group]
		channels[group] = profile.channel
		reaches[group] = maxf(profile.reach_m(), 0.001)
		falloffs.blit_rect(profile.falloff_data(), Rect2i(0, 0, SourceProfile.FALLOFF_TEXELS, 1), Vector2i(0, group))
	if description.source_groups.size() > MAX_GROUPS:
		push_warning("Light engine: over %d source groups; the moving layer ignores the rest." % MAX_GROUPS)
	_set_param(&"group_channel", channels)
	_set_param(&"group_reach", reaches)
	_set_param(&"falloffs", ImageTexture.create_from_image(falloffs))
	redraw()


## The solids, assets (static ones followed by the moving ones) and their silhouettes, the asset layer
## with the moving sprites, and the windows to compute (buffer pixels).
func set_moving(solids: Texture2D, solid_count: int, assets: Texture2D, asset_layer: Texture2D, silhouettes: Texture2D,
		windows: Array[Rect2i]) -> void:
	_set_param(&"solids", solids)
	_set_param(&"solid_count", solid_count)
	_set_param(&"assets", assets)
	_set_param(&"asset_layer", asset_layer)
	_set_param(&"silhouettes", silhouettes)
	var packed: PackedVector4Array = PackedVector4Array()
	packed.resize(MAX_WINDOWS)
	for index: int in mini(windows.size(), MAX_WINDOWS):
		var window: Rect2i = windows[index]
		packed[index] = Vector4(window.position.x, window.position.y, window.end.x, window.end.y)
	_set_param(&"windows", packed)
	_set_param(&"window_count", mini(windows.size(), MAX_WINDOWS))
	var bounds: Rect2i = Rect2i()
	for index: int in mini(windows.size(), MAX_WINDOWS):
		bounds = windows[index] if not bounds.has_area() else bounds.merge(windows[index])
	_request(bounds.merge(_last_windows) if _last_windows.has_area() else bounds)
	_last_windows = bounds


## Each group's colour × lux at this hour (the day state's `source_lights`).
func set_state(state: DayState) -> void:
	var lights: PackedVector3Array = PackedVector3Array()
	lights.resize(MAX_GROUPS)
	for group: int in mini(state.source_lights.size(), MAX_GROUPS):
		var light: Color = state.source_lights[group]
		lights[group] = Vector3(light.r, light.g, light.b)
	if lights == _lights:
		return
	_lights = lights
	_set_param(&"group_light", lights)
	redraw()


## One over the sky directions the sky layer has counted so far.
func set_sky_scale(scale: float) -> void:
	_set_param(&"sky_share_scale", scale)
	redraw()


func set_modelling(value: float) -> void:
	_set_param(&"modelling", value)
	redraw()


func set_penumbra(on: bool, gain: float, max_px: float) -> void:
	_set_param(&"penumbra_on", on)
	_set_param(&"penumbra_gain", gain)
	_set_param(&"penumbra_max_px", max_px)
	redraw()


## The channel's light in lux; the artificial one carries the sky share in alpha.
func texture(channel: SourceProfile.Channel) -> Texture2D:
	return _views[channel].get_texture()


## Draws the whole area again (an input changed).
func redraw() -> void:
	_request(Rect2i(Vector2i.ZERO, _area_size))


## Adds `rect` (buffer pixels) to what this frame draws.
func _request(rect: Rect2i) -> void:
	rect = rect.intersection(Rect2i(Vector2i.ZERO, _area_size))
	if not rect.has_area():
		return
	_pending = rect if not _pending.has_area() else _pending.merge(rect)
	for index: int in _views.size():
		_canvases[index].position = Vector2(_pending.position)
		_canvases[index].size = Vector2(_pending.size)
		if _drawn[index]:
			_views[index].render_target_update_mode = SubViewport.UPDATE_ONCE


## The canvases already hold this frame's rect: requests from now on start the next frame's. Reset
## before drawing, not after: a request made after a frame is drawn (a source layer's pass) must
## still reach the next frame.
func _on_frame_starts_drawing() -> void:
	_pending = Rect2i()


func _set_param(param: StringName, value: Variant) -> void:
	for material: ShaderMaterial in _materials:
		material.set_shader_parameter(param, value)
