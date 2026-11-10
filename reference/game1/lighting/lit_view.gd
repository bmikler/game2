class_name LitView
extends Node
## Shows a world scene through the lighting pipeline (ADR 0007). The world is rendered linear in an HDR
## viewport; a plain viewport at the base size converts it to sRGB with the post-process (what
## screenshots read); the window scales that up.

const BASE_SIZE: Vector2 = Vector2(960, 540)

@export var world_scene: PackedScene

var world: Node

@onready var display: SubViewport = %Display
@onready var _view: SubViewport = %View
@onready var _shown: TextureRect = %Shown
@onready var _screen: TextureRect = %Screen


func _ready() -> void:
	_shown.texture = _view.get_texture()
	_screen.texture = display.get_texture()
	world = world_scene.instantiate()
	_view.add_child(world)
	get_viewport().size_changed.connect(_fit_to_window)
	_fit_to_window()


func _fit_to_window() -> void:
	var window: Vector2 = get_viewport().get_visible_rect().size
	var fit: float = minf(window.x / BASE_SIZE.x, window.y / BASE_SIZE.y)
	_screen.size = BASE_SIZE * fit
	_screen.position = ((window - _screen.size) / 2.0).floor()


## A point in the window (as the mouse reports it) in world pixels.
func to_world(window_point: Vector2) -> Vector2:
	var base: Vector2 = (window_point - _screen.position) * BASE_SIZE / _screen.size
	return _view.get_canvas_transform().affine_inverse() * base


## A world point in the window.
func to_window(world_point: Vector2) -> Vector2:
	return _screen.position + _view.get_canvas_transform() * world_point * _screen.size / BASE_SIZE
