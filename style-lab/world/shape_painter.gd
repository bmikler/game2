class_name ShapePainter
extends Node2D
## Flat rectangles and polygons drawn in code, in the order added, lit by the game1 lighting (Lit
## material) as one light-mask receiver. Placeholder geometry only: walls, floors, blocks, roofs.

var _rects: Array[Rect2] = []
var _polygons: Array[PackedVector2Array] = []
## Drawing order: an index into _rects, or -1 - an index into _polygons.
var _order: PackedInt32Array = PackedInt32Array()
var _colors: PackedColorArray = PackedColorArray()


func _init(mask: int = 1, z: int = 0) -> void:
	light_mask = mask
	z_index = z
	material = Lit.material()


func add_rect(rect: Rect2, color: Color) -> void:
	_order.append(_rects.size())
	_rects.append(rect)
	_colors.append(color)
	queue_redraw()


func add_polygon(points: PackedVector2Array, color: Color) -> void:
	_order.append(-1 - _polygons.size())
	_polygons.append(points)
	_colors.append(color)
	queue_redraw()


func clear() -> void:
	_rects.clear()
	_polygons.clear()
	_order.clear()
	_colors.clear()
	queue_redraw()


func _draw() -> void:
	for index: int in _order.size():
		var shape: int = _order[index]
		if shape >= 0:
			draw_rect(_rects[shape], _colors[index])
		else:
			draw_colored_polygon(_polygons[-1 - shape], _colors[index])
