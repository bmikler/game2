class_name LitView
extends Node
## Shows a world scene through the lighting pipeline (ADR 0007 game1). The world is rendered linear in
## an HDR viewport; a plain viewport of the same size converts it to sRGB with the post-process (what
## screenshots read); the window scales that up. The base size (ProjectionConfig) sets the scale: the
## window is filled edge to edge, no black bars, so the view shows a little more or less than the base
## size along one axis. Pixel perfect: nearest filter, transforms snapped to pixels (style-lab: the
## scale need not be whole, see _fit_to_window); off: linear filter, no snap.

var world: Node
var pixel_perfect: bool = true:
	set(value):
		pixel_perfect = value
		_apply_pixel_mode()

var _base_size: Vector2 = Vector2(960, 540) ## What the scale aims to show.
var _shown_size: Vector2 = Vector2(960, 540) ## What is rendered: the window divided by the scale.

@onready var display: SubViewport = %Display
@onready var _view: SubViewport = %View
@onready var _shown: TextureRect = %Shown
@onready var _screen: TextureRect = %Screen


func _ready() -> void:
	_shown.texture = _view.get_texture()
	_screen.texture = display.get_texture()
	get_viewport().size_changed.connect(_fit_to_window)
	apply_base_size()


## Takes the base resolution from the current ProjectionConfig.
func apply_base_size() -> void:
	_base_size = Vector2(ProjectionConfig.current().base_size)
	_apply_pixel_mode()


## Replaces the shown world (the old one is freed).
func set_world(node: Node) -> void:
	if is_instance_valid(world):
		_view.remove_child(world)
		world.queue_free()
	world = node
	_view.add_child(world)


## The post-process material (display.gdshader), for debug switches.
func display_material() -> ShaderMaterial:
	return _shown.material as ShaderMaterial


## The picture as shown before scaling to the window (sRGB, about the base size).
func capture() -> Image:
	return display.get_texture().get_image()


## A point in the window (as the mouse reports it) in world pixels.
func to_world(window_point: Vector2) -> Vector2:
	var base: Vector2 = (window_point - _screen.position) * _shown_size / _screen.size
	return _view.get_canvas_transform().affine_inverse() * base


func _apply_pixel_mode() -> void:
	if not is_node_ready():
		return
	_view.snap_2d_transforms_to_pixel = pixel_perfect
	_view.snap_2d_vertices_to_pixel = pixel_perfect
	_screen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if pixel_perfect \
			else CanvasItem.TEXTURE_FILTER_LINEAR
	_fit_to_window()


func _fit_to_window() -> void:
	var window: Vector2 = get_viewport().get_visible_rect().size
	# style-lab: the view shows exactly the base height (the frame being judged), scaled to the window
	# even when the scale is not whole: on a window about 990 px tall whole scales cannot tell
	# 960×540, 800×450 and 640×360 apart. Pixel perfect keeps the nearest filter and pixel snapping.
	var fit: float = window.y / _base_size.y
	var size: Vector2i = Vector2i((window / fit).ceil())
	_shown_size = Vector2(size)
	_view.size = size
	display.size = size
	_shown.size = _shown_size
	_screen.size = _shown_size * fit
	_screen.position = ((window - _screen.size) / 2.0).floor()
