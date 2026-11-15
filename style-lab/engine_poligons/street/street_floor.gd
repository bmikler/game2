@tool
extends Node2D
## Albedo of the flat ground of the new street Poligon (strips in metres through the engine's
## projection): pavement on the south side, roadway, pavement on the camera side. Poligon content,
## not the engine's; the engine gives the light.

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")

## Strips along x: d from, d to (metres, d grows towards the camera), with their albedo below.
const STRIPS_D: Array[Vector2] = [
	Vector2(-24.0, -8.0), # south pavement, under snow (and under the houses)
	Vector2(-8.0, -7.8), # kerb
	Vector2(-7.8, 0.0), # roadway
	Vector2(0.0, 0.2), # kerb
	Vector2(0.2, 8.0), # camera-side pavement
]
const STRIPS_COLOR: PackedColorArray = [
	Color("#c3c8d1"), Color("#8e939c"), Color("#7c818b"), Color("#8e939c"), Color("#c3c8d1"),
]
const FROM_X: float = -40.0
const TO_X: float = 40.0
## Dashed centre line, so the scale shows.
const LINE_D: float = -3.9
const LINE_DASH_M: float = 2.0
const LINE_COLOR: Color = Color("#b9b6a8")


func _draw() -> void:
	for index: int in STRIPS_D.size():
		_rect(FROM_X, TO_X, STRIPS_D[index].x, STRIPS_D[index].y, STRIPS_COLOR[index])
	var x: float = FROM_X
	while x < TO_X:
		_rect(x, x + LINE_DASH_M, LINE_D - 0.1, LINE_D + 0.1, LINE_COLOR)
		x += LINE_DASH_M * 2.0


func _rect(from_x: float, to_x: float, from_d: float, to_d: float, color: Color) -> void:
	var top_left: Vector2 = PROJECTION.to_screen(Vector3(from_x, from_d, 0.0))
	var bottom_right: Vector2 = PROJECTION.to_screen(Vector3(to_x, to_d, 0.0))
	draw_rect(Rect2(top_left, bottom_right - top_left), color)
