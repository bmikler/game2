class_name SourceLight
extends Node
## The light of the Location's light sources in the buffer's two channels (natural, artificial), in
## lux: one SourceLayer per source group, built once per scene description; each frame only their
## sum × each group's colour × lux at the hour (from the day state). A helper of the LightBuffer; it
## has no owner, so it is never saved into a scene.

## Emitted when a layer pass reached its texture (the channels changed).
signal changed

const COMPOSE_SHADER: Shader = preload("res://addons/swiatlo/buffer/source_compose.gdshader")

var _natural: SubViewport
var _artificial: SubViewport
var _layers: Array[SourceLayer] = []
var _groups: Array[ShaderMaterial] = []
var _channels: Array[SourceProfile.Channel] = []


func _init() -> void:
	_natural = _channel_view()
	_artificial = _channel_view()


## Takes a new scene description: one layer per source group, built over the next frames.
func build(description: SceneDescription, solids: Texture2D, receivers: Texture2D, assets: Texture2D,
		asset_layer: Texture2D, projection: LightProjection, modelling: float) -> void:
	for layer: SourceLayer in _layers:
		remove_child(layer)
		layer.queue_free()
	for view: SubViewport in [_natural, _artificial]:
		for rect: Node in view.get_children():
			view.remove_child(rect)
			rect.queue_free()
		view.size = description.area.size if description.area.has_area() else Vector2i.ONE
	_layers.clear()
	_groups.clear()
	_channels.clear()
	var sources: ImageTexture = ImageTexture.create_from_image(description.source_data())
	for group: int in description.source_groups.size():
		var profile: SourceProfile = description.source_groups[group]
		var layer: SourceLayer = SourceLayer.new()
		# Layers before the channels' viewports: those read them.
		add_child(layer)
		move_child(layer, _layers.size())
		layer.set_group(group, profile, sources, description.sources.size())
		layer.set_modelling(modelling)
		layer.build(description.area, solids, description.solids.size(), receivers, description.receivers.size(),
				asset_layer, assets, projection)
		layer.pass_rendered.connect(_on_pass)
		_layers.append(layer)
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = COMPOSE_SHADER
		material.set_shader_parameter(&"layer", layer.texture())
		var rect: ColorRect = ColorRect.new()
		rect.material = material
		var view: SubViewport = _natural if profile.channel == SourceProfile.Channel.NATURAL else _artificial
		rect.size = Vector2(view.size)
		view.add_child(rect)
		_groups.append(material)
		_channels.append(profile.channel)
	redraw()


## Takes each group's colour × lux at this hour (the day state's `source_lights`).
func set_state(state: DayState) -> void:
	for group: int in mini(_groups.size(), state.source_lights.size()):
		var light: Color = state.source_lights[group]
		_groups[group].set_shader_parameter(&"light", Vector3(light.r, light.g, light.b))
	redraw()


## The receivers' modelling changed: sprite pixels take the light on other normals, build again.
func set_modelling(value: float) -> void:
	for layer: SourceLayer in _layers:
		layer.set_modelling(value)
		layer.restart()


func has_channel(channel: SourceProfile.Channel) -> bool:
	return _channels.has(channel)


## The channel's light in lux (black where no source of it shines).
func texture(channel: SourceProfile.Channel) -> Texture2D:
	return (_natural if channel == SourceProfile.Channel.NATURAL else _artificial).get_texture()


## Whether every layer is built.
func is_complete() -> bool:
	for layer: SourceLayer in _layers:
		if not layer.is_complete():
			return false
	return true


## How many layers there are (one per source group).
func layer_count() -> int:
	return _layers.size()


## Passes done by every layer so far (for checks that switching lights does not build them again).
func passes_done() -> int:
	var total: int = 0
	for layer: SourceLayer in _layers:
		total += layer.passes_done()
	return total


## Renders both channels once more (after the day state or a layer changed).
func redraw() -> void:
	for group: int in _groups.size():
		_groups[group].set_shader_parameter(&"scale", _layers[group].light_scale())
	_natural.render_target_update_mode = SubViewport.UPDATE_ONCE
	_artificial.render_target_update_mode = SubViewport.UPDATE_ONCE


func _on_pass(_passes_done: int) -> void:
	redraw()
	changed.emit()


func _channel_view() -> SubViewport:
	var view: SubViewport = SubViewport.new()
	view.use_hdr_2d = true
	view.disable_3d = true
	view.transparent_bg = true
	view.render_target_update_mode = SubViewport.UPDATE_ONCE
	view.size = Vector2i.ONE
	add_child(view)
	return view
