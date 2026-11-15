class_name SolidsOverlay
extends Node2D
## Debug view "Bryły": the edges of every solid the engine sees, over the picture.

const COLOR: Color = Color(1.0, 0.2, 0.9)

var shapes: Array[SolidShape] = []:
	set(value):
		shapes = value
		queue_redraw()


func _init() -> void:
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX


func _draw() -> void:
	for shape: SolidShape in shapes:
		SolidWireframe.draw(self, shape, COLOR)
