class_name MetricAnchor
extends Node2D
## Places itself in metres (ProjectionConfig.px_per_m), so a layout survives a change of scale. For
## spawn points and for light fixtures, which are its children at its origin.

@export var at_m: Vector2 = Vector2.ZERO


func _ready() -> void:
	position = at_m * ProjectionConfig.current().px_per_m
