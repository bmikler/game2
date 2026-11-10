class_name PlaceholderActor
extends CharacterBody2D
## The player as a figure drawn in code (Figure: 3 views + mirror): walks with WASD in 8 directions, its height and speed from
## the ProjectionConfig. Origin at the feet. The scene above sets which lights reach it
## (set_light_bits) and the camera limits.

const DIRECTIONS: int = 8
const FEET_M: Vector2 = Vector2(0.4, 0.2)

var facing: int = 2 ## 0 right, then clockwise in 45° steps (2 down, 6 up).
var camera: Camera2D
## PROTOTYPE (ticket Przepis postaci): when set, drawn instead of the Figure, front view only, feet
## at the bottom of its used rect, scaled to the actor height (nearest).
var sprite: Texture2D:
	set(value):
		sprite = value
		queue_redraw()
## PROTOTYPE (ticket Przepis postaci): when set (front, side, back as Figure.View), drawn instead of
## `sprite`, the view chosen by `facing`; a null view falls back to the front.
var views: Array[Texture2D] = []:
	set(value):
		views = value
		queue_redraw()
## The side view in `views` faces left (generated that way), so it is mirrored when walking right.
var side_faces_left: bool = true
## PROTOTYPE: walk cycle frames per view (Figure.View order), played while moving; empty = still.
var walks: Array[Array] = [[], [], []]
var walk_fps: float = 8.0
## PROTOTYPE (ticket Poligon Ulica w bryłach): screen speed up and down × this (0.6 = metres on the
## ground as fast as across).
var vertical_speed: float = 1.0
## PROTOTYPE (ticket Poligon Ulica w bryłach, stairs): the figure drawn this far from the feet
## (collision and y-sort stay at the origin), speed × zone_speed, and on side stairs left/right also
## move up the screen by `stair_slope` px per px.
var visual_offset: Vector2 = Vector2.ZERO:
	set(value):
		if value != visual_offset:
			visual_offset = value
			queue_redraw()
var zone_speed: float = 1.0
var stair_slope: float = 0.0

var _speed_px: float = 64.0
var _height_px: float = 72.0
var _width_px: float = 18.0
var _walk_time: float = 0.0
var _walk_frame: int = -1 ## -1 while standing.


func _ready() -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	_speed_px = config.px(config.walk_speed_m_s)
	_height_px = config.px(config.actor_height_m)
	_width_px = config.px(0.45)
	material = Lit.actor_material()
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(config.px(FEET_M.x), config.depth_px(FEET_M.y))
	shape.shape = rect
	shape.position = Vector2(0.0, -rect.size.y / 2.0)
	add_child(shape)
	camera = Camera2D.new()
	camera.position = Vector2(0.0, -_height_px / 2.0)
	add_child(camera)


func _physics_process(delta: float) -> void:
	var input: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = input * _speed_px
	velocity.y *= vertical_speed
	velocity.y -= input.x * _speed_px * stair_slope
	velocity *= zone_speed
	if input != Vector2.ZERO:
		var turned: int = posmod(roundi(input.angle() / (TAU / DIRECTIONS)), DIRECTIONS)
		if turned != facing:
			facing = turned
			queue_redraw()
	move_and_slide()
	_advance_walk(delta if input != Vector2.ZERO else -1.0)


## `delta` < 0 stops the cycle (standing frame).
func _advance_walk(delta: float) -> void:
	var view: int = Figure.view_for(facing)
	var frames: Array = walks[view]
	var frame: int = -1
	if delta >= 0.0 and not frames.is_empty():
		_walk_time += delta
		frame = floori(_walk_time * walk_fps) % frames.size()
	else:
		_walk_time = 0.0
	if frame != _walk_frame:
		_walk_frame = frame
		queue_redraw()


func set_light_bits(mask: int) -> void:
	if light_mask != mask:
		light_mask = mask


func set_camera_limits(area: Rect2) -> void:
	camera.limit_left = floori(area.position.x)
	camera.limit_top = floori(area.position.y)
	camera.limit_right = ceili(area.end.x)
	camera.limit_bottom = ceili(area.end.y)


func _draw() -> void:
	draw_set_transform(visual_offset.round())
	if views.size() == 3:
		var view: Figure.View = Figure.view_for(facing)
		var standing: Texture2D = views[view] if views[view] != null else views[Figure.View.FRONT]
		var texture: Texture2D = standing
		var frames: Array = walks[view]
		if _walk_frame >= 0 and _walk_frame < frames.size():
			texture = frames[_walk_frame]
		var mirrored: bool = view == Figure.View.SIDE and Figure.mirrored_for(facing) != side_faces_left
		# Walk frames share the standing sprite's canvas: anchor them like it, so they do not jump.
		draw_sprite(self, texture, _height_px, mirrored, standing if texture != standing else null, visual_offset.round())
		return
	if sprite != null:
		draw_sprite(self, sprite, _height_px, false, null, visual_offset.round())
		return
	Figure.draw(self, Vector2.ZERO, _height_px, Figure.view_for(facing), Figure.mirrored_for(facing),
			ProjectionConfig.current().depth_factor)


## PROTOTYPE (ticket Przepis postaci): `texture` standing with the bottom middle of its opaque
## pixels at the origin of `canvas`, scaled so the figure is `height` px tall, with a floor shadow.
## `reference` (same canvas size): scale, anchor and shadow taken from its opaque pixels instead
## (animation frames placed exactly like the standing sprite).
static func draw_sprite(canvas: CanvasItem, texture: Texture2D, height: float, mirrored: bool = false,
		reference: Texture2D = null, origin: Vector2 = Vector2.ZERO) -> void:
	var used: Rect2i = (reference if reference != null else texture).get_image().get_used_rect()
	var k: float = height / maxf(1.0, used.size.y)
	if absf(k - 1.0) < 0.1:
		k = 1.0 # Keep the pixels 1:1 when the sprite is already about the actor height.
	else:
		k = maxf(1.0, roundf(k)) if k > 1.0 else k
	var depth: float = ProjectionConfig.current().depth_factor
	var shadow: Vector2 = Vector2(used.size.x * k * 0.8, maxf(2.0, height * 0.1 * depth))
	Figure.draw_blob(canvas, Vector2.ZERO, shadow.round())
	var size: Vector2 = Vector2(texture.get_size()) * k
	var top_left: Vector2 = -Vector2((used.position.x + used.size.x / 2.0) * k, used.end.y * k)
	if mirrored:
		canvas.draw_set_transform(origin, 0.0, Vector2(-1.0, 1.0))
	canvas.draw_texture_rect(texture, Rect2(top_left.round(), size.round()), false)
	canvas.draw_set_transform(Vector2.ZERO)
