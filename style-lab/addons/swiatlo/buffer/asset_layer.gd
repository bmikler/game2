class_name AssetLayer
extends Node
## The light buffer's asset layer: which asset's sprite covers each buffer pixel, and the normal its
## normal map gives there. Drawn when the scene description changes; with moving assets also when they
## move (`place_moving`). A helper of the LightBuffer; it has no owner, so it is never saved into a
## scene.

const SHADER: Shader = preload("res://addons/swiatlo/buffer/asset_layer.gdshader")

var _view: SubViewport
## Whether this layer holds the moving assets too (the layers drawn every frame) or not (built once).
var _with_moving: bool = false
var _moving_sprites: Array[Sprite2D] = []
## Each sprite's anchor d (its drawing order: far ones first, a nearer one wins).
var _anchor_d: Dictionary[Sprite2D, float] = {}
var _area: Rect2i = Rect2i()


func _init(with_moving: bool = false) -> void:
	_with_moving = with_moving
	_view = SubViewport.new()
	_view.use_hdr_2d = true
	_view.disable_3d = true
	_view.transparent_bg = true
	_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_view.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_view.size = Vector2i.ONE
	add_child(_view)


## Draws the sprites of the description's assets over its buffer area (and its moving assets, when
## this layer holds them).
func build(description: SceneDescription) -> void:
	for child: Node in _view.get_children():
		_view.remove_child(child)
		child.queue_free()
	_moving_sprites.clear()
	_anchor_d.clear()
	_area = description.area
	_view.size = _area.size if _area.has_area() else Vector2i.ONE
	for index: int in description.assets.size():
		var sprite: Sprite2D = _sprite()
		_show(sprite, description.assets[index], index + 1)
	if _with_moving:
		place_moving(description)
	_view.render_target_update_mode = SubViewport.UPDATE_ONCE


## Places the moving assets where they are now (numbers after the static ones) and draws again.
func place_moving(description: SceneDescription) -> void:
	while _moving_sprites.size() < description.moving_assets.size():
		_moving_sprites.append(_sprite())
	while _moving_sprites.size() > description.moving_assets.size():
		var extra: Sprite2D = _moving_sprites.pop_back()
		_anchor_d.erase(extra)
		_view.remove_child(extra)
		extra.queue_free()
	for index: int in description.moving_assets.size():
		_show(_moving_sprites[index], description.moving_assets[index], description.assets.size() + index + 1)
	var order: Array[Sprite2D] = []
	order.assign(_anchor_d.keys())
	order.sort_custom(func(a: Sprite2D, b: Sprite2D) -> bool: return _anchor_d[a] < _anchor_d[b])
	for index: int in order.size():
		_view.move_child(order[index], index)
	_view.render_target_update_mode = SubViewport.UPDATE_ONCE


func texture() -> Texture2D:
	return _view.get_texture()


func _sprite() -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.centered = false
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = SHADER
	sprite.material = material
	_view.add_child(sprite)
	return sprite


func _show(sprite: Sprite2D, entry: AssetEntry, number: int) -> void:
	var material: ShaderMaterial = sprite.material as ShaderMaterial
	material.set_shader_parameter(&"asset_number", float(number))
	material.set_shader_parameter(&"has_normal_map", entry.normal_map != null)
	material.set_shader_parameter(&"normal_map", entry.normal_map)
	sprite.texture = entry.sprite
	sprite.position = Vector2(entry.top_left_px - _area.position)
	_anchor_d[sprite] = entry.anchor_m.y
