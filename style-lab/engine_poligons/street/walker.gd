class_name PoligonWalker
extends Node2D
## The character of the engine Poligons (engine ticket 17): the detective of the Przepis postaci
## (walk "Dc", Pixellab), walked with the move actions in 8 directions. A moving asset of the light
## engine: an Occluder with its sprite and one Solid, an upright cylinder or the silhouette of the
## frame shown (SilhouetteStack, built here from the frames), switched in F1 to compare. This node
## stays at the Location's origin; the Occluder (`body()`) stands at the feet, its `position` on
## screen (shots record and restore it).

enum ShadowShape { CYLINDER, SILHOUETTE }
enum View { FRONT, SIDE, BACK }

## The frames (proby/ is ignored by Godot's import: read as images). Front walk from opcja1's
## parallel feet, the torso fixed (suffix c); the back walk has no fixed version.
const WALK: String = "res://proby/pixellab_chod_D/%s_%d.png"
const WALK_VIEWS: PackedStringArray = ["przodc", "bokc", "tyl"]
const STAND: PackedStringArray = ["res://proby/wejscie_anim/opcja2/sprite_przod.png",
		"res://proby/wejscie_anim/opcja1/sprite_bok.png", "res://proby/wejscie_anim/opcja1/sprite_tyl.png"]
## Frames of the walk loop (frame 8 = frame 0) and their rate (as in the old Poligon's D modes).
const WALK_FRAMES: int = 8
const WALK_FPS: float = 8.0
## Shadow shape names in F1 and shots, in ShadowShape order.
const SHADOW_SHAPES: PackedStringArray = ["walec", "bryła z sylwetki"]
## A person as an upright cylinder (wayfinder 33, preset A4: radius 0.27 m, 1.8 m).
const CYLINDER_SIZE_M: Vector3 = Vector3(0.54, 0.54, 1.8)

## Walking speed in metres per second along x and along d.
@export var speed_m_s: float = 1.6
## Where the character starts (metres, feet on the floor).
@export var start_m: Vector3 = Vector3.ZERO
## Where it may walk: x and d (metres).
@export var walk_area_m: Rect2 = Rect2(-50.0, -9.6, 100.0, 24.6)
## A routine instead of the move actions (an NPC): it walks from point to point (x, d in metres) and
## round again. Empty: the player walks it.
@export var route_m: PackedVector2Array = PackedVector2Array()

var shadow_shape: ShadowShape = ShadowShape.SILHOUETTE:
	set(value):
		shadow_shape = value
		_show()
## Where it faces: 0 right, then clockwise in 45° steps (2 down: front, 6 up: back). Shots record it.
var facing: int:
	get:
		return _facing
	set(value):
		_facing = posmod(value, 8)
		_show()

var _occluder: Occluder
var _solid: Solid
var _sprite: AssetSprite
var _stack: SilhouetteStack
## Per view and mirror (index view * 2 + mirrored): the standing texture, its anchor, the walk frames,
## and per frame (standing first) its anchor's y and stack frame.
var _stand: Array[Texture2D] = []
var _anchors: Array[Vector2i] = []
var _anchor_ys: Array[PackedInt32Array] = []
var _walks: Array[Array] = []
var _stack_frames: Array[PackedInt32Array] = []
var _position_m: Vector3 = Vector3.ZERO
## 0 right, then clockwise in 45° steps (2 down: front, 6 up: back).
var _facing: int = 2
var _walk_time: float = 0.0
var _walking: bool = false
var _route_next: int = 0
## The Occluder's screen position last set here (a shot may set it itself).
var _shown_at: Vector2 = Vector2.INF


func _ready() -> void:
	_load_frames()
	_occluder = Occluder.new()
	_occluder.name = "Occluder"
	_occluder.moving = true
	_solid = Solid.new()
	_solid.silhouette = _stack
	_occluder.add_child(_solid)
	_sprite = AssetSprite.new()
	_occluder.add_child(_sprite)
	add_child(_occluder)
	_position_m = start_m
	_show()


func _process(delta: float) -> void:
	if _occluder.position != _shown_at:
		# A shot placed the character: the feet on the floor under that screen point.
		var projection: LightProjection = Occluder.PROJECTION
		var at: Vector2 = _occluder.position
		_position_m = Vector3(at.x / projection.px_per_m, at.y / (projection.px_per_m * projection.depth_factor), 0.0)
	var input: Vector2 = _route_step(delta) if not route_m.is_empty() \
			else Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	_walking = input != Vector2.ZERO
	if _walking:
		_facing = posmod(roundi(input.angle() / (PI / 4.0)), 8)
		_position_m += Vector3(input.x, input.y, 0.0) * speed_m_s * delta
		_position_m.x = clampf(_position_m.x, walk_area_m.position.x, walk_area_m.end.x)
		_position_m.y = clampf(_position_m.y, walk_area_m.position.y, walk_area_m.end.y)
		_walk_time += delta
	else:
		_walk_time = 0.0
	_show()


## The moving asset (its `position` is the feet on screen).
func body() -> Occluder:
	return _occluder


## The feet in metres.
func position_m() -> Vector3:
	return _position_m


## The routine's way this frame (unit, like the move actions; shorter on arrival at a point, which
## turns it to the next one).
func _route_step(delta: float) -> Vector2:
	var to_next: Vector2 = route_m[_route_next] - Vector2(_position_m.x, _position_m.y)
	var step: float = speed_m_s * delta
	if to_next.length() <= step:
		_route_next = (_route_next + 1) % route_m.size()
		return to_next / maxf(step, 1e-6)
	return to_next.normalized()


func _show() -> void:
	if _occluder == null:
		return
	var view: View = View.FRONT if _facing == 2 else (View.BACK if _facing == 6 else View.SIDE)
	# The side frames face left; walking right shows them mirrored.
	var mirrored: bool = view == View.SIDE and (_facing <= 1 or _facing == 7)
	var key: int = view * 2 + (1 if mirrored else 0)
	var walk: Array = _walks[key]
	var frame: int = -1
	if _walking and not walk.is_empty():
		frame = floori(_walk_time * WALK_FPS) % walk.size()
	_sprite.texture = walk[frame] if frame >= 0 else _stand[key]
	_sprite.anchor_px = Vector2i(_anchors[key].x, _anchor_ys[key][frame + 1])
	if shadow_shape == ShadowShape.SILHOUETTE:
		_solid.shape = Solid.Shape.SILHOUETTE
		_solid.position_m = Vector3.ZERO
		_solid.frame = _stack_frames[key][frame + 1]
	else:
		_solid.shape = Solid.Shape.CYLINDER
		_solid.size_m = CYLINDER_SIZE_M
		_solid.position_m = Vector3(0.0, CYLINDER_SIZE_M.y * 0.5, 0.0)
	_occluder.position_m = _position_m
	_shown_at = _occluder.position


## Reads every frame, mirrors the side view and builds the silhouette stack: side frames get their
## depth from the front standing sprite, front and back frames from the side one. A side walk frame
## stands on its own lowest pixel (both feet at the body's depth, the lower one on the floor; the
## walk frames end 2–4 px above the standing sprite); a front or back one on the standing sprite's
## (the foot stepping toward the camera reaches lower on screen because it is nearer).
func _load_frames() -> void:
	_stack = SilhouetteStack.new(1.0 / Occluder.PROJECTION.px_per_m)
	var stand_images: Array[Image] = []
	for path: String in STAND:
		stand_images.append(_image(path))
	var stand_anchors: Array[Vector2i] = []
	for image: Image in stand_images:
		var used: Rect2i = image.get_used_rect()
		stand_anchors.append(Vector2i(used.position.x + used.size.x / 2, used.end.y))
	for view: int in View.size():
		var across: int = View.FRONT if view == View.SIDE else View.SIDE
		for mirrored: bool in [false, true]:
			var anchor: Vector2i = stand_anchors[view]
			var stand: Image = stand_images[view].duplicate() as Image
			if mirrored:
				stand.flip_x()
				anchor.x = stand.get_width() - anchor.x
			var frames: PackedInt32Array = PackedInt32Array()
			var anchor_ys: PackedInt32Array = PackedInt32Array()
			frames.append(_stack.add_frame(stand, anchor, stand_images[across], stand_anchors[across]))
			anchor_ys.append(anchor.y)
			var walk: Array[Texture2D] = []
			for index: int in WALK_FRAMES:
				var path: String = WALK % [WALK_VIEWS[view], index]
				if not FileAccess.file_exists(ProjectSettings.globalize_path(path)):
					break
				var image: Image = _image(path)
				if mirrored:
					image.flip_x()
				walk.append(ImageTexture.create_from_image(image))
				var frame_anchor: Vector2i = anchor
				if view == View.SIDE:
					frame_anchor.y = image.get_used_rect().end.y
				frames.append(_stack.add_frame(image, frame_anchor, stand_images[across], stand_anchors[across]))
				anchor_ys.append(frame_anchor.y)
			_stand.append(ImageTexture.create_from_image(stand))
			_anchors.append(anchor)
			_walks.append(walk)
			_stack_frames.append(frames)
			_anchor_ys.append(anchor_ys)


static func _image(res_path: String) -> Image:
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(res_path))
	if image == null:
		push_error("Missing character frame: %s" % res_path)
		return Image.create_empty(1, 1, false, Image.FORMAT_RGBA8)
	image.convert(Image.FORMAT_RGBA8)
	return image
