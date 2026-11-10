class_name Door
extends Area2D
## A passage to another Poligon: when the player walks in, it reports which scene to load and at which
## spawn point (a MetricAnchor under the target's Spawns node).

signal used(target_scene: String, spawn: StringName)

@export_file("*.tscn") var target_scene: String = ""
@export var spawn: StringName = &""
@export var size_m: Vector2 = Vector2(1.0, 0.4)
@export var at_m: Vector2 = Vector2.ZERO ## Centre, in metres (ProjectionConfig.px_per_m).


func _ready() -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	position = at_m * config.px_per_m
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(config.px(size_m.x), config.depth_px(size_m.y))
	shape.shape = rect
	add_child(shape)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is PlaceholderActor:
		used.emit(target_scene, spawn)
