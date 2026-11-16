class_name AssetLayer
extends Node
## The light buffer's asset layer: which asset's sprite covers each buffer pixel, and the normal its
## normal map gives there. Drawn when the scene description changes. A helper of the LightBuffer; it
## has no owner, so it is never saved into a scene.

const SHADER: Shader = preload("res://addons/swiatlo/buffer/asset_layer.gdshader")

var _view: SubViewport


func _init() -> void:
	_view = SubViewport.new()
	_view.use_hdr_2d = true
	_view.disable_3d = true
	_view.transparent_bg = true
	_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_view.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_view.size = Vector2i.ONE
	add_child(_view)


## Draws the sprites of the description's assets over its buffer area.
func build(description: SceneDescription) -> void:
	for child: Node in _view.get_children():
		_view.remove_child(child)
		child.queue_free()
	var area: Rect2i = description.area
	_view.size = area.size if area.has_area() else Vector2i.ONE
	for index: int in description.assets.size():
		var entry: AssetEntry = description.assets[index]
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = SHADER
		material.set_shader_parameter(&"asset_number", float(index + 1))
		material.set_shader_parameter(&"has_normal_map", entry.normal_map != null)
		material.set_shader_parameter(&"normal_map", entry.normal_map)
		var sprite: Sprite2D = Sprite2D.new()
		sprite.centered = false
		sprite.texture = entry.sprite
		sprite.position = Vector2(entry.top_left_px - area.position)
		sprite.material = material
		_view.add_child(sprite)
	_view.render_target_update_mode = SubViewport.UPDATE_ONCE


func texture() -> Texture2D:
	return _view.get_texture()
