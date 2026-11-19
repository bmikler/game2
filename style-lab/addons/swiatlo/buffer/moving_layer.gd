class_name MovingLayer
extends Node
## The light buffer's moving layer: the two source channels (natural, artificial; lux) and the sky
## share with the moving Occluders in them, drawn every frame they move (moving_layer.gdshader). Only
## the moving windows are computed; elsewhere it copies the layers built once. The artificial
## channel's viewport carries the sky share in alpha. A helper of the LightBuffer; it has no owner,
## so it is never saved into a scene.

const SHADER: Shader = preload("res://addons/swiatlo/buffer/moving_layer.gdshader")
## As in the shader.
const MAX_GROUPS: int = 16
const MAX_WINDOWS: int = 8

## Per SourceProfile.Channel: the viewport and its material.
var _views: Array[SubViewport] = []
var _materials: Array[ShaderMaterial] = []


func _init() -> void:
	for channel: int in [SourceProfile.Channel.NATURAL, SourceProfile.Channel.ARTIFICIAL]:
		var view: SubViewport = SubViewport.new()
		view.use_hdr_2d = true
		view.disable_3d = true
		# Alpha carries the sky share, not coverage.
		view.transparent_bg = true
		view.render_target_update_mode = SubViewport.UPDATE_ONCE
		view.size = Vector2i.ONE
		add_child(view)
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = SHADER
		material.set_shader_parameter(&"channel", channel)
		material.set_shader_parameter(&"with_sky", channel == SourceProfile.Channel.ARTIFICIAL)
		var canvas: ColorRect = ColorRect.new()
		canvas.material = material
		view.add_child(canvas)
		_views.append(view)
		_materials.append(material)


## Takes a new scene description: its area and data, the layers built once it adds the moving
## Occluders to, and the source groups' channels, reaches and falloffs.
func build(description: SceneDescription, receivers: Texture2D, sources: Texture2D, projection: LightProjection,
		source_light: SourceLight, sky_counts: Texture2D) -> void:
	var size: Vector2i = description.area.size if description.area.has_area() else Vector2i.ONE
	for index: int in _views.size():
		_views[index].size = size
		(_views[index].get_child(0) as ColorRect).size = Vector2(size)
		var channel: SourceProfile.Channel = index as SourceProfile.Channel
		_materials[index].set_shader_parameter(&"channel_in", source_light.texture(channel))
		_materials[index].set_shader_parameter(&"has_channel_in", source_light.has_channel(channel))
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
	redraw()


## Each group's colour × lux at this hour (the day state's `source_lights`).
func set_state(state: DayState) -> void:
	var lights: PackedVector3Array = PackedVector3Array()
	lights.resize(MAX_GROUPS)
	for group: int in mini(state.source_lights.size(), MAX_GROUPS):
		var light: Color = state.source_lights[group]
		lights[group] = Vector3(light.r, light.g, light.b)
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


func redraw() -> void:
	for view: SubViewport in _views:
		view.render_target_update_mode = SubViewport.UPDATE_ONCE


func _set_param(param: StringName, value: Variant) -> void:
	for material: ShaderMaterial in _materials:
		material.set_shader_parameter(param, value)
