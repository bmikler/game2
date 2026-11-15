class_name SolidsOverlay
extends Node2D
## Debug view "Bryły": the edges of every solid the engine sees, over the picture.

const COLOR: Color = Color(1.0, 0.2, 0.9)

var boxes: Array[AABB] = []:
	set(value):
		boxes = value
		queue_redraw()


func _init() -> void:
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX


func _draw() -> void:
	for box: AABB in boxes:
		SolidWireframe.draw(self, box, COLOR)
