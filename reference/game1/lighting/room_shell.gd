class_name RoomShell
extends Node2D
## A room's geometry: floor, back wall (with openings cut for its WindowLights), wall tops and contact
## shadows, drawn from @export values so a new room is a scene, not code. Origin: top-left of the back
## wall; the floor starts at wall_height_px. Wall tops are y-sorted with actors (the front one hides
## their feet).

enum FloorStyle { SPECKLE, LINO }
enum WallStyle { BOARDS, PLAIN }

const BASEBOARD: Color = Color("585b5b")
const BASEBOARD_ROWS: int = 4
const BOARD_WIDTH: int = 9
const REVEAL: Color = Color("cbb894")
const FRAME: Color = Color("eef2f4")
const SILL: Color = Color("c0cacc")
const DOOR_FRAME: int = 3
const DOOR_SIDE: int = 28 ## Wall top drawn over actors in a door passage (hides the head).
## Face drawn over actors in a door passage and the zone beside it: the zone's side (40, door_zone.tres)
## plus half a body (about 18), so whoever stands at its edge is hidden below the wall top as well.
const DOOR_FACE_SIDE: int = 58
const SIDE_CLEARANCE: int = 11 ## Px off a side wall top; + half the foot box (7) = half the parka.
const NORMAL_UP: Vector3 = Vector3(0.0, -0.45, 0.89) ## Top surfaces seen in 3/4.
const NORMAL_SOUTH: Vector3 = Vector3(0.0, 0.8, 0.6) ## Front faces.
const NORMAL_BOARD_GAP: Vector3 = Vector3(-0.3, 0.75, 0.6)
## Windows in a wall top seen from above: palette colours (STYLE.md).
const WIN_FRAME: Color = Color("e6dccb") ## Old painted sash and sill nose.
const WIN_FRAME_SHADE: Color = Color("a8978e")
const WIN_BOARD: Color = Color("c1b6a3") ## Sill board.
const WIN_SHADOW: Color = Color("756357") ## Under the inner frame.
const WIN_EDGE: Color = Color("1e1a17") ## The wall's outer edge.
## Glass from the room side to the sky side, per time of day (day, low sun, night).
const GLASS: Array[Array] = [ ## Not Array[PackedColorArray]: in this const its colours read back transparent.
	[Color("798e9f"), Color("9fb8d0"), Color("c0cacc")],
	[Color("a0836f"), Color("c9a96a"), Color("e8c27a")],
	[Color("232839"), Color("262e47"), Color("415d7a")],
]
const GLASS_GLINT: PackedColorArray = [Color("eef2f4"), Color("f6e7b8"), Color("547188")]
## Contact shadow at the foot of the back wall: darkest multiplier and width.
const WALL_SHADOW: float = 0.68
const SHADOW_PX: int = 10
## Procedural surface texture.
const SPECKLE_LIGHT_BELOW: float = 0.04 ## A floor pixel's roll below this is lighter...
const SPECKLE_DARK_BELOW: float = 0.08 ## ... and below this darker.
const SPECKLE_SHADE: float = 0.07
const LINO_SEAM_EVERY: int = 40
const LINO_SEAM_SHADE: float = 0.12
const LINO_FLECK_CHANCE: float = 0.06
const LINO_FLECK_SHADE: float = 0.06
const BOARD_FLECK_EVERY: int = 23
const BOARD_FLECK_SHADE: float = 0.05
const PLAIN_FLECK_EVERY: int = 29
const PLAIN_FLECK_SHADE: float = 0.04
const DOOR_EDGE_SHADE: float = 0.3
const DOOR_FRAME_SHADE: float = 0.12
const PASSAGE_NEAR_SHADE: float = 0.55 ## At the top of the passage...
const PASSAGE_FAR_SHADE: float = 0.2 ## ... and at this room's floor.
const SILL_SHADE: float = 0.25
const THRESHOLD_SHADE: float = 0.25
const THRESHOLD_POST_SHADE: float = 0.1
const SIDE_DOOR_SHADE: float = 0.3
const SIDE_DOOR_POST_SHADE: float = 0.08
const MULLION_MIN_LENGTH: int = 40 ## A wall-top window this long or shorter has one pane.
const NO_MULLION: int = -10
const WALL_Z: int = -20
const TOP_Z: int = -19
const FLOOR_Z: int = -30
const SHADOW_Z: int = -29
const DOOR_POST_Z: int = -18

@export_range(0, 3) var slot: int = 0 ## Light mask colour, as its RoomLighting.
@export var floor_size: Vector2i = Vector2i(280, 176)
@export var wall_height_px: int = 104 ## 0: no back wall.
@export var cap: int = 6
@export var top_strip: Texture2D ## Wall-top strip, cap px high, tiled along every wall top.
@export var floor_style: FloorStyle = FloorStyle.SPECKLE
@export var floor_color: Color = Color("8a8276")
@export var floor_seed: int = 9002
@export var wall_style: WallStyle = WallStyle.BOARDS
@export var wall_color_a: Color = Color("d6c09a")
@export var wall_color_b: Color = Color("c1b6a3") ## BOARDS: every other board.
@export var wall_gap_color: Color = Color("b09c84") ## BOARDS: the gap between boards.
@export var cap_back: bool = true
@export var cap_left: bool = true
@export var cap_right: bool = true
@export var cap_front: bool = true
@export var door: Vector2i = Vector2i(-1, -1) ## Gap in the front wall, floor x from..to.
@export var front_neighbour_slot: int = -1 ## The room behind the front wall (threshold).
## Door openings through the back wall face: x from..to; the face is cut to a passage floor, walkable
## from the room above down to this floor.
@export var wall_doors: Array[Vector2i] = []
@export var wall_door_height: int = 80
## Passages through the front wall top besides door (x from..to), to a door in the face of the room
## below: walkable, but the top stays whole over them.
@export var front_gaps: Array[Vector2i] = []
## How far below its top the front wall top around front_gaps is y-sorted: 1 px above the foot of the
## face of the room below (its cap + wall height - 1), so that face's own wall top over the door stays
## on top. 0: sorted at its top, like the rest.
@export var front_gap_sort: int = 0
## Gaps in the side wall tops, y from..to in shell px: doors (walkable, with a threshold) and windows
## (glass; their light is a SideWindowLight).
@export var side_doors_left: Array[Vector2i] = []
@export var side_doors_right: Array[Vector2i] = []
@export var side_windows_left: Array[Vector2i] = []
@export var side_windows_right: Array[Vector2i] = []
## Windows in the front wall top (x from..to): glass only, their light is a SideWindowLight with
## into_up.
@export var front_windows: Array[Vector2i] = []
@export var windows: Array[NodePath] = [] ## WindowLights on the back wall.

var _glass: Dictionary[String, Array] = {} ## "kind gap" -> glass layers, see glass_for().
var _strip: Image


func _ready() -> void:
	y_sort_enabled = true
	_strip = top_strip.get_image()
	_build_floor()
	if wall_height_px > 0:
		_build_wall()
	_build_caps()
	_build_shadows()


## Where actors can stand, in global pixels: the floor and the door gaps. The zones beside doors through
## a wall face, coming from the room above, are the station's (DoorZone).
func walkable() -> Array[Rect2]:
	var origin: Vector2 = global_position
	var left: int = _side_clearance(cap_left)
	var right: int = _side_clearance(cap_right)
	var rects: Array[Rect2] = [walkable_floor()]
	for gap: Vector2i in _front_gaps():
		rects.append(Rect2(
				origin + Vector2(gap.x + 1, wall_height_px + floor_size.y - 1),
				Vector2(gap.y - gap.x - 2, cap + 2)))
	for gap: Vector2i in wall_doors:
		rects.append(Rect2(origin + Vector2(gap.x + 1, -cap - 1), Vector2(gap.y - gap.x - 2, wall_height_px + cap + 2)))
	# Side doors span their whole gap: the room beyond is often exactly as deep as the gap (the corridor
	# behind the hall), so feet walking along its wall have to fit through at the same height.
	for gap: Vector2i in side_doors_left:
		rects.append(Rect2(origin + Vector2(-cap - 1, gap.x), Vector2(cap + 1 + left, gap.y - gap.x)))
	for gap: Vector2i in side_doors_right:
		rects.append(Rect2(origin + Vector2(floor_size.x - right, gap.x), Vector2(cap + 1 + right, gap.y - gap.x)))
	return rects


## The room's own floor where actors can stand, in global pixels, kept off the side wall tops.
func walkable_floor() -> Rect2:
	var left: int = _side_clearance(cap_left)
	var right: int = _side_clearance(cap_right)
	return Rect2(global_position + Vector2(left, wall_height_px), Vector2(floor_size.x - left - right, floor_size.y))


## The glass layers (day, golden hour, night) of a window in a wall top: kind is "front", "left" or
## "right", gap the window's from..to as in front_windows / side_windows_*.
func glass_for(kind: String, gap: Vector2i) -> Array[Sprite2D]:
	var layers: Array[Sprite2D] = []
	var stored: Array = _glass.get(_glass_key(kind, gap), [])
	layers.assign(stored)
	return layers


func _build_floor() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = floor_seed
	var image: Image = Image.create_empty(floor_size.x, floor_size.y, false, Image.FORMAT_RGBA8)
	var normals: Image = Image.create_empty(floor_size.x, floor_size.y, false, Image.FORMAT_RGBA8)
	normals.fill(_normal_color(NORMAL_UP))
	for y: int in floor_size.y:
		for x: int in floor_size.x:
			var color: Color = floor_color
			match floor_style:
				FloorStyle.SPECKLE:
					var roll: float = rng.randf()
					if roll < SPECKLE_LIGHT_BELOW:
						color = color.lightened(SPECKLE_SHADE)
					elif roll < SPECKLE_DARK_BELOW:
						color = color.darkened(SPECKLE_SHADE)
				FloorStyle.LINO:
					if (x + 3) % LINO_SEAM_EVERY == 0:
						color = color.darkened(LINO_SEAM_SHADE) # Sheet seams.
					elif rng.randf() < LINO_FLECK_CHANCE:
						color = color.lightened(LINO_FLECK_SHADE)
			image.set_pixel(x, y, color)
	_lit(image, normals, Vector2(0, wall_height_px), FLOOR_Z, LightMasks.of(slot, LightMasks.Receiver.FLOOR))


func _build_wall() -> void:
	var width: int = floor_size.x
	var height: int = wall_height_px
	var image: Image = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	var normals: Image = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	for y: int in height:
		for x: int in width:
			var color: Color = wall_color_a
			var normal: Vector3 = NORMAL_SOUTH
			if wall_style == WallStyle.BOARDS:
				@warning_ignore("integer_division")
				var board: int = x / BOARD_WIDTH
				color = wall_color_a if board % 2 == 0 else wall_color_b
				if x % BOARD_WIDTH == 0:
					color = wall_gap_color
					normal = NORMAL_BOARD_GAP.normalized()
				elif (x * 7 + y * 3 + board * 11) % BOARD_FLECK_EVERY == 0:
					color = color.darkened(BOARD_FLECK_SHADE)
			elif (x * 7 + y * 3) % PLAIN_FLECK_EVERY == 0:
				color = color.darkened(PLAIN_FLECK_SHADE)
			if y >= height - BASEBOARD_ROWS:
				color = BASEBOARD
				normal = NORMAL_SOUTH
			image.set_pixel(x, y, color)
			normals.set_pixel(x, y, _normal_color(normal))
	var top: int = height - wall_door_height
	for gap: Vector2i in wall_doors:
		# Painted frame (jambs and head) around the opening, on the wall face.
		for y: int in range(maxi(top - DOOR_FRAME, 0), height):
			for x: int in range(maxi(gap.x - DOOR_FRAME, 0), mini(gap.y + DOOR_FRAME, width)):
				var edge: bool = x == gap.x - DOOR_FRAME or x == gap.y + DOOR_FRAME - 1 or y == top - DOOR_FRAME
				image.set_pixel(x, y, FRAME.darkened(DOOR_EDGE_SHADE if edge else DOOR_FRAME_SHADE))
				normals.set_pixel(x, y, _normal_color(NORMAL_SOUTH))
		# The passage through the wall: floor, darker towards the far room.
		for y: int in range(top, height):
			for x: int in range(gap.x, gap.y):
				var dark: float = lerpf(PASSAGE_NEAR_SHADE, PASSAGE_FAR_SHADE, float(y - top) / float(wall_door_height))
				image.set_pixel(x, y, floor_color.darkened(dark))
				normals.set_pixel(x, y, _normal_color(NORMAL_UP))
	for path: NodePath in windows:
		var window: WindowLight = get_node(path) as WindowLight
		_cut_window(image, normals, window, Vector2i((window.global_position - global_position).round()))
	_lit(image, normals, Vector2.ZERO, WALL_Z, LightMasks.of(slot, LightMasks.Receiver.SOLID))
	# The face around each door drawn again, y-sorted at the foot of the wall: whoever walks through
	# the passage is behind the jambs and lintel, whoever stands in this room in front of the wall is
	# in front of it.
	for gap: Vector2i in wall_doors:
		_build_door_overlay(image, normals, gap, top)


func _build_door_overlay(image: Image, normals: Image, gap: Vector2i, top: int) -> void:
	var width: int = floor_size.x
	var height: int = wall_height_px
	var from_x: int = maxi(gap.x - DOOR_FACE_SIDE, 0)
	var rect: Rect2i = Rect2i(from_x, 0, mini(gap.y + DOOR_FACE_SIDE, width) - from_x, height)
	var face: Image = image.get_region(rect)
	var face_normals: Image = normals.get_region(rect)
	for y: int in range(maxi(top, 0), height):
		for x: int in range(gap.x - rect.position.x, gap.y - rect.position.x):
			face.set_pixel(x, y, Color(0, 0, 0, 0))
	# The wall top above (the front wall of the room behind) hides the head as well. Here only around the
	# door; beside it, the room above sorts its own wall top with this face (front_gap_sort).
	var tall: Image = Image.create_empty(rect.size.x, height + cap, false, Image.FORMAT_RGBA8)
	var tall_normals: Image = Image.create_empty(rect.size.x, height + cap, false, Image.FORMAT_RGBA8)
	var top_from: int = maxi(gap.x - DOOR_SIDE, 0)
	var top_rect: Rect2i = Rect2i(top_from - from_x, 0, mini(gap.y + DOOR_SIDE, width) - top_from, cap)
	tall.blit_rect(_top_image(top_rect.size), Rect2i(Vector2i.ZERO, top_rect.size), top_rect.position)
	tall_normals.fill_rect(top_rect, _normal_color(NORMAL_UP))
	tall.blit_rect(face, Rect2i(Vector2i.ZERO, face.get_size()), Vector2i(0, cap))
	tall_normals.blit_rect(face_normals, Rect2i(Vector2i.ZERO, face_normals.get_size()), Vector2i(0, cap))
	var other_slot: int = front_neighbour_slot if front_neighbour_slot >= 0 else slot
	var mask: int = LightMasks.of(slot, LightMasks.Receiver.SOLID) | LightMasks.of(other_slot, LightMasks.Receiver.SOLID)
	var sprite: Sprite2D = _lit(tall, tall_normals, Vector2(rect.position.x, height), 0, mask)
	sprite.offset = Vector2(0, -height - cap)


## Reveal (wall depth), white sash frame, glass cut out, and the sill below.
func _cut_window(image: Image, normals: Image, window: WindowLight, at: Vector2i) -> void:
	var opening: Rect2i = Rect2i(window.opening.position + at, window.opening.size)
	var glass: Rect2i = Rect2i(window.glass.position + at, window.glass.size)
	for y: int in range(opening.position.y, opening.end.y):
		for x: int in range(opening.position.x, opening.end.x):
			var inner: bool = x >= glass.position.x - 2 and x < glass.end.x + 2 and y >= glass.position.y - 2
			var is_glass: bool = false
			for pane: Rect2i in window.panes:
				if Rect2i(pane.position + at, pane.size).has_point(Vector2i(x, y)):
					is_glass = true
			image.set_pixel(x, y, Color(FRAME if inner else REVEAL, 0.0 if is_glass else 1.0))
			normals.set_pixel(x, y, Color(0, 0, 0, 0) if is_glass else _normal_color(NORMAL_SOUTH))
	for y: int in range(opening.end.y, opening.end.y + 4):
		for x: int in range(opening.position.x - 4, opening.end.x + 4):
			image.set_pixel(x, y, SILL if y < opening.end.y + 2 else SILL.darkened(SILL_SHADE))
			normals.set_pixel(x, y, _normal_color(NORMAL_UP if y < opening.end.y + 2 else NORMAL_SOUTH))


func _build_caps() -> void:
	var solid: int = LightMasks.of(slot, LightMasks.Receiver.SOLID)
	var width: int = floor_size.x
	var front_y: int = wall_height_px + floor_size.y
	if cap_back:
		_cap(Rect2i(-cap, -cap, width + cap * 2, cap), solid, TOP_Z)
	if cap_left:
		_side_cap(-cap, front_y, side_doors_left, side_windows_left, solid)
	if cap_right:
		_side_cap(width, front_y, side_doors_right, side_windows_right, solid)
	if cap_front:
		_build_front_cap(front_y, solid)


## The front wall is a threshold: lit by this room and the one behind it.
func _build_front_cap(front_y: int, solid: int) -> void:
	var width: int = floor_size.x
	var both: int = solid
	var floors: int = LightMasks.of(slot, LightMasks.Receiver.FLOOR)
	if front_neighbour_slot >= 0:
		both |= LightMasks.of(front_neighbour_slot, LightMasks.Receiver.SOLID)
		floors |= LightMasks.of(front_neighbour_slot, LightMasks.Receiver.FLOOR)
	var left: int = -cap if cap_left else 0
	var right: int = width + cap if cap_right else width
	var gaps: Array[Vector2i] = []
	if door.x >= 0:
		gaps.append(door)
	gaps.append_array(front_windows)
	gaps.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x < b.x)
	var x: int = left
	for gap: Vector2i in gaps:
		if gap.x > x:
			_front_cap_piece(Rect2i(x, front_y, gap.x - x, cap), both)
		if gap in front_windows:
			# The room is above: inside on top, the jamb posts stick up 1 px onto the floor.
			_top_window("front", gap, -1, Vector2(gap.x, front_y - 1), 0, both)
			x = gap.y
			continue
		# Threshold in the gap: floor, not black void, with frame posts.
		var length: int = gap.y - gap.x
		var sill: Image = Image.create_empty(length, cap, false, Image.FORMAT_RGBA8)
		sill.fill(floor_color.darkened(THRESHOLD_SHADE))
		var post_columns: Array[int] = [0, 1, length - 2, length - 1]
		for y: int in cap:
			for column: int in post_columns:
				sill.set_pixel(column, y, FRAME.darkened(THRESHOLD_POST_SHADE))
		var sill_normals: Image = Image.create_empty(length, cap, false, Image.FORMAT_RGBA8)
		sill_normals.fill(_normal_color(NORMAL_UP))
		_lit(sill, sill_normals, Vector2(gap.x, front_y), FLOOR_Z, floors)
		x = gap.y
	if right > x:
		_front_cap_piece(Rect2i(x, front_y, right - x, cap), both)


## A piece of the front wall top, y-sorted with actors. Around each of front_gaps, as wide as the face
## drawn over actors at the door below (DOOR_FACE_SIDE), it is sorted front_gap_sort px lower, with that
## face: whoever is in the door or in the zone beside it is behind both, from the wall top's top down.
## One image for the whole piece, cut where the sorting changes, so the strip's tiling stays the same.
func _front_cap_piece(rect: Rect2i, mask: int) -> void:
	if front_gap_sort <= 0 or front_gaps.is_empty():
		_cap(rect, mask, 0)
		return
	var image: Image = _top_image(rect.size)
	var normals: Image = Image.create_empty(rect.size.x, rect.size.y, false, Image.FORMAT_RGBA8)
	normals.fill(_normal_color(NORMAL_UP))
	var cuts: Array[int] = [rect.position.x, rect.end.x]
	for gap: Vector2i in front_gaps:
		var around: Vector2i = _around_front_gap(gap)
		cuts.append(clampi(around.x, rect.position.x, rect.end.x))
		cuts.append(clampi(around.y, rect.position.x, rect.end.x))
	cuts.sort()
	for index: int in cuts.size() - 1:
		var from_x: int = cuts[index]
		var to_x: int = cuts[index + 1]
		if to_x <= from_x:
			continue
		var region: Rect2i = Rect2i(from_x - rect.position.x, 0, to_x - from_x, rect.size.y)
		var sprite: Sprite2D = _lit(image.get_region(region), normals.get_region(region),
				Vector2(from_x, rect.position.y), 0, mask)
		if _by_front_gap(from_x, to_x):
			sprite.position.y += front_gap_sort
			sprite.offset = Vector2(0, -front_gap_sort)


## Whether x from..to lies around one of front_gaps (within DOOR_FACE_SIDE).
func _by_front_gap(from_x: int, to_x: int) -> bool:
	for gap: Vector2i in front_gaps:
		var around: Vector2i = _around_front_gap(gap)
		if from_x >= around.x and to_x <= around.y:
			return true
	return false


## x from..to of the wall top sorted with the face below, around one of front_gaps.
static func _around_front_gap(gap: Vector2i) -> Vector2i:
	return Vector2i(gap.x - DOOR_FACE_SIDE, gap.y + DOOR_FACE_SIDE)


func _front_gaps() -> Array[Vector2i]:
	var gaps: Array[Vector2i] = []
	if door.x >= 0:
		gaps.append(door)
	gaps.append_array(front_gaps)
	gaps.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x < b.x)
	return gaps


## A side wall top from y 0 to the front wall, split at its door and window gaps.
func _side_cap(x: int, to: int, doors: Array[Vector2i], side_windows: Array[Vector2i], mask: int) -> void:
	var gaps: Array[Vector2i] = []
	gaps.append_array(doors)
	gaps.append_array(side_windows)
	gaps.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x < b.x)
	var y: int = 0
	for gap: Vector2i in gaps:
		if gap.x > y:
			_cap(Rect2i(x, y, cap, gap.x - y), mask, TOP_Z)
		if gap in side_windows:
			# The inside (row 0) turned to face the room: right on the left wall.
			if x < 0:
				_top_window("left", gap, CLOCKWISE, Vector2(x, gap.x), TOP_Z, mask)
			else:
				_top_window("right", gap, COUNTERCLOCKWISE, Vector2(x - 1, gap.x), TOP_Z, mask)
		else:
			_side_door(x, gap, mask)
		y = gap.y
	if to > y:
		_cap(Rect2i(x, y, cap, to - y), mask, TOP_Z)


## A side door: threshold with white frame posts at both ends, plain to see.
func _side_door(x: int, gap: Vector2i, mask: int) -> void:
	var length: int = gap.y - gap.x
	var image: Image = Image.create_empty(cap, length, false, Image.FORMAT_RGBA8)
	var normals: Image = Image.create_empty(cap, length, false, Image.FORMAT_RGBA8)
	normals.fill(_normal_color(NORMAL_UP))
	image.fill(floor_color.darkened(SIDE_DOOR_SHADE))
	var post_rows: Array[int] = [0, 1, 2, length - 3, length - 2, length - 1]
	for y: int in post_rows:
		for column: int in cap:
			image.set_pixel(column, y, FRAME)
	_lit(image, normals, Vector2(x, gap.x), FLOOR_Z, LightMasks.of(slot, LightMasks.Receiver.FLOOR))
	var post_ys: Array[int] = [gap.x - 3, gap.y]
	for post_y: int in post_ys: # Posts stick out of the wall top a little.
		var post: Image = Image.create_empty(cap + 4, 3, false, Image.FORMAT_RGBA8)
		post.fill(FRAME.darkened(SIDE_DOOR_POST_SHADE))
		var post_normals: Image = Image.create_empty(cap + 4, 3, false, Image.FORMAT_RGBA8)
		post_normals.fill(_normal_color(NORMAL_UP))
		_lit(post, post_normals, Vector2(x - 2, post_y), DOOR_POST_Z, mask)


## A wall top. At z 0 it is y-sorted with actors and hides the feet of whoever stands behind it.
func _cap(rect: Rect2i, mask: int, z: int) -> void:
	var normals: Image = Image.create_empty(rect.size.x, rect.size.y, false, Image.FORMAT_RGBA8)
	normals.fill(_normal_color(NORMAL_UP))
	_lit(_top_image(rect.size), normals, Vector2(rect.position), z, mask) # Y-sorted by its top edge.


## A wall top of the given size: the strip tiled along its length (turned for a side wall), shifted by
## the cross position so the tiles do not line up in step.
func _top_image(size: Vector2i) -> Image:
	var image: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	var strip_width: int = _strip.get_width()
	var strip_height: int = _strip.get_height()
	var vertical: bool = size.y > size.x
	for y: int in size.y:
		for x: int in size.x:
			if vertical: # Strip rows run across the wall: x, along: y.
				image.set_pixel(x, y, _strip.get_pixel((y + x * 7) % strip_width, strip_height - 1 - x % strip_height))
			else:
				image.set_pixel(x, y, _strip.get_pixel((x + y * 7) % strip_width, y % strip_height))
	return image


## A window in a wall top seen from above: the jamb posts, the sill and the frames are lit like the
## wall top; the glass between them is the brightest band, the sky and snow outside, an unshaded layer
## per time of day (day, golden hour, night) that the window's SideWindowLight brightens with the sky.
## `kind` and `gap` name it for glass_for(); `turn` turns the room side (row 0, plus 1 px of jamb posts
## sticking out onto the floor) towards the room, -1: not turned; `at` is where that image goes.
func _top_window(kind: String, gap: Vector2i, turn: int, at: Vector2, z: int, mask: int) -> void:
	var parts: Array[Image] = _window_parts(gap.y - gap.x)
	var normals: Image = Image.create_empty(gap.y - gap.x, cap + 1, false, Image.FORMAT_RGBA8)
	normals.fill(_normal_color(NORMAL_UP))
	for x: int in gap.y - gap.x:
		normals.set_pixel(x, 1, _normal_color(NORMAL_SOUTH)) # The sill's nose faces the room.
	parts.append(normals)
	if turn != -1:
		for part: Image in parts:
			part.rotate_90(turn as ClockDirection)
	var frame: Sprite2D = _lit(parts[0], parts[4], at, z, mask)
	var layers: Array[Sprite2D] = []
	for index: int in range(1, 4):
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = ImageTexture.create_from_image(parts[index])
		sprite.centered = false
		var material_unshaded: CanvasItemMaterial = CanvasItemMaterial.new()
		material_unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		sprite.material = material_unshaded
		frame.add_child(sprite)
		layers.append(sprite)
	_glass[_glass_key(kind, gap)] = layers


## The window's images, `length` px long and cap + 1 px across, row 0 the posts sticking out into the
## room, row 1 the room side: [frame (lit), glass day, glass gold, glass night]. Rows from the room:
## sill nose, sill board (8 px: 1 row, 10 px: 2), shadow under the inner frame, glass (light towards
## the sky), the outer frame and the wall's outer edge.
func _window_parts(length: int) -> Array[Image]:
	var height: int = cap + 1
	var frame: Image = Image.create_empty(length, height, false, Image.FORMAT_RGBA8)
	var glass: Array[Image] = []
	for _layer: int in GLASS.size():
		glass.append(Image.create_empty(length, height, false, Image.FORMAT_RGBA8))
	var board: int = 2 if cap >= 10 else (1 if cap >= 8 else 0)
	var first_glass: int = 1 + 1 + board + 1
	var outer_frame: int = height - 2
	@warning_ignore("integer_division")
	var mullion: int = length / 2 - 1 if length > MULLION_MIN_LENGTH else NO_MULLION
	for x: int in length:
		var jamb: bool = x < 2 or x >= length - 2
		var post: bool = jamb or (x >= mullion and x < mullion + 2)
		var post_color: Color = WIN_FRAME if x % 2 == 0 else WIN_FRAME_SHADE
		for y: int in height:
			if y == 0:
				if jamb:
					frame.set_pixel(x, y, post_color)
			elif y == 1:
				frame.set_pixel(x, y, post_color if jamb else WIN_FRAME)
			elif y < first_glass - 1:
				frame.set_pixel(x, y, post_color if jamb else WIN_BOARD)
			elif y == first_glass - 1:
				frame.set_pixel(x, y, post_color if jamb else WIN_SHADOW)
			elif y < outer_frame:
				if post:
					frame.set_pixel(x, y, post_color)
					continue
				var depth: float = float(y - first_glass) / maxf(outer_frame - first_glass - 1, 1.0)
				var band: int = roundi(depth * 2.0)
				for layer: int in GLASS.size():
					var color: Color = GLASS[layer][band]
					# One glint per pane on the sky side, right after its post, and frost in the
					# room-side corner by the jamb.
					var after: int = x - 2 if x < mullion or mullion < 0 else x - mullion - 2
					if y == outer_frame - 1 and after >= 0 and after < 2:
						color = GLASS_GLINT[layer]
					elif y == first_glass and x == 2:
						color = GLASS_GLINT[layer]
					glass[layer].set_pixel(x, y, color)
			elif y == outer_frame:
				frame.set_pixel(x, y, WIN_FRAME)
			else:
				frame.set_pixel(x, y, WIN_EDGE)
	var parts: Array[Image] = [frame]
	parts.append_array(glass)
	return parts


func _build_shadows() -> void:
	# Only at the foot of the back wall, where the 3/4 view shows the corner. Side walls are seen from
	# above: a band along them read as a strange shadow, and cut across open side passages (ticket 27).
	if wall_height_px > 0:
		var wall_shadow: ImageTexture = LightTextures.gradient(floor_size.x, SHADOW_PX, func(_u: float, v: float) -> float:
			return lerpf(WALL_SHADOW, 1.0, v * v))
		_shadow(wall_shadow, Vector2(0, float(wall_height_px)))


func _shadow(texture: Texture2D, at: Vector2) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.position = at
	sprite.z_index = SHADOW_Z
	var multiply: CanvasItemMaterial = CanvasItemMaterial.new()
	multiply.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	multiply.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	sprite.material = multiply
	add_child(sprite)
	return sprite


func _lit(color: Image, normals: Image, at: Vector2, z: int, mask: int) -> Sprite2D:
	var canvas_texture: CanvasTexture = CanvasTexture.new()
	canvas_texture.diffuse_texture = ImageTexture.create_from_image(color)
	canvas_texture.normal_texture = ImageTexture.create_from_image(normals)
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = canvas_texture
	sprite.centered = false
	sprite.position = at
	sprite.z_index = z
	sprite.light_mask = mask
	sprite.material = Lit.material()
	add_child(sprite)
	return sprite


## Feet are a point; the sprite is about 35 px wide: keep the body off a side wall top.
static func _side_clearance(has_cap: bool) -> int:
	return SIDE_CLEARANCE if has_cap else 1


static func _glass_key(kind: String, gap: Vector2i) -> String:
	return "%s %s" % [kind, gap]


static func _normal_color(normal: Vector3) -> Color:
	return Color(normal.x * 0.5 + 0.5, -normal.y * 0.5 + 0.5, normal.z * 0.5 + 0.5)
