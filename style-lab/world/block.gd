class_name Block
extends Node2D
## A box drawn in code in the 3/4 view, sized in metres: a building, a piece of furniture, a lamp post.
## Origin: the middle of its front bottom edge, so it y-sorts with actors by where it meets the ground.
## The front face rises from there, the top face sits above it; the footprint behind the origin stops
## walking. Optional rectangles on the front face (door, windows) in metres from its bottom left.

@export var at_m: Vector2 = Vector2.ZERO ## Position in metres (ProjectionConfig.px_per_m).
@export var size_m: Vector3 = Vector3(2.0, 1.0, 1.0) ## Width, depth, height.
@export_range(0, 3) var slot: int = 0 ## Light-mask slot of the room it stands in.
@export var front_color: Color = Color("7a7468")
@export var top_color: Color = Color("a39d90")
@export var solid: bool = true
@export var details: Array[Rect2] = [] ## On the front face: x, y above the ground, size (m).
@export var detail_color: Color = Color("3a3530")
@export var lift_m: float = 0.0 ## The front face starts this high (a lintel over a door).

var _painter: ShapePainter


func _ready() -> void:
	position = at_m * ProjectionConfig.current().px_per_m
	_painter = ShapePainter.new(LightMasks.of(slot, LightMasks.Receiver.SOLID))
	add_child(_painter)
	repaint()
	if solid:
		_build_footprint()


func repaint() -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var width: float = config.px(size_m.x)
	var depth: float = config.depth_px(size_m.y)
	var height: float = config.px(size_m.z)
	_painter.clear()
	var lift: float = config.px(lift_m)
	if height > lift:
		_painter.add_rect(Rect2(-width / 2.0, -height, width, height - lift), front_color)
	_painter.add_rect(Rect2(-width / 2.0, -height - depth, width, depth), top_color)
	for detail: Rect2 in details:
		_painter.add_rect(Rect2(
				-width / 2.0 + config.px(detail.position.x),
				-config.px(detail.position.y + detail.size.y),
				config.px(detail.size.x), config.px(detail.size.y)), detail_color)


func _build_footprint() -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var body: StaticBody2D = StaticBody2D.new()
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(config.px(size_m.x), config.depth_px(size_m.y))
	shape.shape = rect
	shape.position = Vector2(0.0, -rect.size.y / 2.0)
	body.add_child(shape)
	add_child(body)
