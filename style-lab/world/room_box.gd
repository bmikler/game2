class_name RoomBox
extends Node2D
## A room (or a stretch of street) drawn in code, sized in metres (ProjectionConfig). Local layout as
## the game1 lighting expects: the back wall from y 0 down to the floor, then the floor. Thin wall tops
## on the sides and in front (with a door gap), edges that stop walking, and back-wall windows built as
## WindowLights. With no wall height it is open ground (a street): only the floor and the edges.
## Place it at its RoomLighting's origin and point RoomLighting.box at it.

const WALL_Z: int = -30
const WALL_TOP_M: float = 0.25 ## Thickness of the wall tops drawn on the sides and in front.
const FRAME_PX: int = 4 ## Reveal between the opening and the glass.
const MULLION_PX: int = 2

@export var width_m: float = 9.0
@export var depth_m: float = 5.0
@export var wall_height_m: float = 2.6 ## 0: open ground.
@export var above_m: float = 0.0 ## How high things stand above the back edge (facades): lit by the ambient.
@export_range(0, 3) var slot: int = 0 ## Same as its RoomLighting.
@export var floor_color: Color = Color("6b5d4f")
@export var wall_color: Color = Color("8c8a80")
@export var wall_top_color: Color = Color("2b2a2e")
@export var frame_color: Color = Color("d8d2c4")
@export var door_x_m: float = -1.0 ## Gap in the front edge from here (m from the left); below 0: none.
@export var door_width_m: float = 1.0
@export var bounded: bool = true ## Edges that stop walking.
## No back wall but still a room (side wall tops, front edge): the room in front of another, whose back
## wall is a partition drawn as y-sorted blocks (it must hide actors standing behind it).
@export var open_back: bool = false
@export var back_door_x_m: float = -1.0 ## Gap in the back edge (passage to the room behind); below 0: none.
@export var back_door_width_m: float = 1.0
## Side wall tops: drawn or not (the room beside draws the shared wall), and a doorway in each (z from
## the back edge of the floor, m; below 0: none).
@export var left_wall: bool = true
@export var right_wall: bool = true
@export var front_wall: bool = true ## Drawn or not; its edge stops walking either way.
@export var left_door_z_m: float = -1.0
@export var right_door_z_m: float = -1.0
@export var side_door_m: float = 1.0

@export_group("Windows")
## Back-wall windows: x from the left, y the sill above the floor, size (m).
@export var windows: Array[Rect2] = []
@export var panes_per_window: int = 2
## style-lab (ticket 31): 2 adds a transom (a window cross with two sashes), as SideWindowLight.TRANSOM_AT.
@export var pane_rows: int = 1
@export var window_profile: WindowLightProfile
@export var view_day: Texture2D
@export var view_gold: Texture2D
@export var view_night: Texture2D

var floor_painter: ShapePainter
var wall_painter: ShapePainter


func _ready() -> void:
	floor_painter = ShapePainter.new(LightMasks.of(slot, LightMasks.Receiver.FLOOR), WALL_Z)
	wall_painter = ShapePainter.new(LightMasks.of(slot, LightMasks.Receiver.SOLID), WALL_Z)
	add_child(floor_painter)
	add_child(wall_painter)
	repaint()
	if wall_height_m > 0.0:
		for window: Rect2 in windows:
			add_child(_make_window(window))
	if bounded:
		_build_edges()


## Walkable floor, local px.
func floor_rect() -> Rect2:
	var config: ProjectionConfig = ProjectionConfig.current()
	return Rect2(0.0, _wall_px(), config.px(width_m), config.depth_px(depth_m))


## Everything drawn for this room, local px.
func ambient_rect() -> Rect2:
	var config: ProjectionConfig = ProjectionConfig.current()
	var top: float = config.px(WALL_TOP_M)
	var above: float = config.px(above_m)
	var area: Rect2 = floor_rect()
	return Rect2(-top, -above, area.size.x + 2.0 * top, area.end.y + top + above)


## Redraws with the current colours (debug variants change them).
func repaint() -> void:
	floor_painter.clear()
	wall_painter.clear()
	var area: Rect2 = floor_rect()
	floor_painter.add_rect(area, floor_color)
	if wall_height_m <= 0.0 and not open_back:
		return
	var top: float = ProjectionConfig.current().px(WALL_TOP_M)
	for piece: Rect2 in _wall_around_windows(Rect2(0.0, 0.0, area.size.x, _wall_px())):
		wall_painter.add_rect(piece, wall_color)
	for window: Rect2 in windows:
		_paint_frame(_opening(window))
	if left_wall:
		for piece: Rect2 in _side_pieces(Rect2(-top, 0.0, top, area.end.y + top), left_door_z_m):
			wall_painter.add_rect(piece, wall_top_color)
	if right_wall:
		for piece: Rect2 in _side_pieces(Rect2(area.size.x, 0.0, top, area.end.y + top), right_door_z_m):
			wall_painter.add_rect(piece, wall_top_color)
	if front_wall:
		for piece: Rect2 in _front_pieces(area, top):
			wall_painter.add_rect(piece, wall_top_color)


func _wall_px() -> float:
	return ProjectionConfig.current().px(maxf(wall_height_m, 0.0))


## A window's opening in wall px (with the reveal).
func _opening(window: Rect2) -> Rect2i:
	var config: ProjectionConfig = ProjectionConfig.current()
	var wall: float = _wall_px()
	return Rect2i(
			roundi(config.px(window.position.x)),
			roundi(wall - config.px(window.position.y + window.size.y)),
			roundi(config.px(window.size.x)),
			roundi(config.px(window.size.y)))


func _glass(opening: Rect2i) -> Rect2i:
	return opening.grow(-FRAME_PX)


func _panes(glass: Rect2i) -> Array[Rect2i]:
	var columns: Array[Rect2i] = _columns(glass)
	if pane_rows < 2:
		return columns
	var transom: int = _transom_y(glass)
	var panes: Array[Rect2i] = []
	for column: Rect2i in columns:
		panes.append(Rect2i(column.position.x, column.position.y, column.size.x, transom - column.position.y))
		panes.append(Rect2i(column.position.x, transom + MULLION_PX, column.size.x, column.end.y - transom - MULLION_PX))
	return panes


## Top of the transom bar, wall px.
func _transom_y(glass: Rect2i) -> int:
	return glass.end.y - roundi(glass.size.y * SideWindowLight.TRANSOM_AT) - MULLION_PX / 2


func _columns(glass: Rect2i) -> Array[Rect2i]:
	var panes: Array[Rect2i] = []
	var count: int = maxi(panes_per_window, 1)
	var width: int = (glass.size.x - MULLION_PX * (count - 1)) / count
	for index: int in count:
		var x: int = glass.position.x + index * (width + MULLION_PX)
		var last: bool = index == count - 1
		panes.append(Rect2i(x, glass.position.y, glass.end.x - x if last else width, glass.size.y))
	return panes


func _paint_frame(opening: Rect2i) -> void:
	var glass: Rect2i = _glass(opening)
	var panes: Array[Rect2i] = _columns(glass)
	var left: float = opening.position.x
	wall_painter.add_rect(Rect2(left, opening.position.y, opening.size.x, FRAME_PX), frame_color)
	wall_painter.add_rect(Rect2(left, glass.end.y, opening.size.x, FRAME_PX), frame_color)
	wall_painter.add_rect(Rect2(left, glass.position.y, FRAME_PX, glass.size.y), frame_color)
	wall_painter.add_rect(Rect2(glass.end.x, glass.position.y, FRAME_PX, glass.size.y), frame_color)
	for index: int in range(1, panes.size()):
		var x: int = panes[index].position.x - MULLION_PX
		wall_painter.add_rect(Rect2(x, glass.position.y, MULLION_PX, glass.size.y), frame_color)
	if pane_rows >= 2:
		wall_painter.add_rect(Rect2(glass.position.x, _transom_y(glass), glass.size.x, MULLION_PX), frame_color)


## The back wall minus the window openings: full-height strips between windows, and pieces above and
## below each window.
func _wall_around_windows(wall: Rect2) -> Array[Rect2]:
	var pieces: Array[Rect2] = []
	var openings: Array[Rect2i] = []
	for window: Rect2 in windows:
		openings.append(_opening(window))
	openings.sort_custom(func(a: Rect2i, b: Rect2i) -> bool: return a.position.x < b.position.x)
	var x: float = wall.position.x
	for opening: Rect2i in openings:
		if opening.position.x > x:
			pieces.append(Rect2(x, 0.0, opening.position.x - x, wall.size.y))
		pieces.append(Rect2(opening.position.x, 0.0, opening.size.x, opening.position.y))
		pieces.append(Rect2(
				opening.position.x, opening.end.y, opening.size.x, wall.size.y - opening.end.y))
		x = opening.end.x
	if wall.end.x > x:
		pieces.append(Rect2(x, 0.0, wall.end.x - x, wall.size.y))
	return pieces


## The front edge, `thick` px deep below the floor, split by the door gap.
func _front_pieces(area: Rect2, thick: float) -> Array[Rect2]:
	var front: Rect2 = Rect2(area.position.x - thick, area.end.y, area.size.x + 2.0 * thick, thick)
	if door_x_m < 0.0:
		return [front]
	var config: ProjectionConfig = ProjectionConfig.current()
	var door_from: float = area.position.x + config.px(door_x_m)
	var door_to: float = door_from + config.px(door_width_m)
	return [
		Rect2(front.position.x, front.position.y, door_from - front.position.x, thick),
		Rect2(door_to, front.position.y, front.end.x - door_to, thick),
	]


## A side wall strip (px) split by its doorway.
func _side_pieces(strip: Rect2, door_z_m: float) -> Array[Rect2]:
	if door_z_m < 0.0:
		return [strip]
	var config: ProjectionConfig = ProjectionConfig.current()
	var from: float = _wall_px() + config.depth_px(door_z_m)
	var to: float = from + config.depth_px(side_door_m)
	return [
		Rect2(strip.position.x, strip.position.y, strip.size.x, from - strip.position.y),
		Rect2(strip.position.x, to, strip.size.x, strip.end.y - to),
	]


func _make_window(window: Rect2) -> WindowLight:
	var light: WindowLight = WindowLight.new()
	var opening: Rect2i = _opening(window)
	light.profile = window_profile
	light.opening = opening
	light.glass = _glass(opening)
	light.panes = _panes(light.glass)
	light.wall_height_px = roundi(_wall_px())
	light.view_day = view_day
	light.view_gold = view_gold
	light.view_night = view_night
	# The view starts at the top of the wall, so nothing of it shows above.
	light.view_anchor = Vector2i(view_day.get_width() / 2, opening.position.y)
	return light


## Static bodies just outside the floor, the front one split by the door gap.
func _build_edges() -> void:
	var area: Rect2 = floor_rect()
	var thick: float = ProjectionConfig.current().px(1.0)
	var body: StaticBody2D = StaticBody2D.new()
	add_child(body)
	var edges: Array[Rect2] = []
	edges.append_array(_side_pieces(Rect2(area.position.x - thick, area.position.y, thick, area.size.y), left_door_z_m))
	edges.append_array(_side_pieces(Rect2(area.end.x, area.position.y, thick, area.size.y), right_door_z_m))
	var back: Rect2 = Rect2(area.position.x - thick, area.position.y - thick, area.size.x + 2.0 * thick, thick)
	if back_door_x_m < 0.0:
		edges.append(back)
	else:
		var config: ProjectionConfig = ProjectionConfig.current()
		var from: float = area.position.x + config.px(back_door_x_m)
		var to: float = from + config.px(back_door_width_m)
		edges.append(Rect2(back.position.x, back.position.y, from - back.position.x, thick))
		edges.append(Rect2(to, back.position.y, back.end.x - to, thick))
	edges.append_array(_front_pieces(area, thick))
	for edge: Rect2 in edges:
		var shape: CollisionShape2D = CollisionShape2D.new()
		var rect: RectangleShape2D = RectangleShape2D.new()
		rect.size = edge.size
		shape.shape = rect
		shape.position = edge.get_center()
		body.add_child(shape)
