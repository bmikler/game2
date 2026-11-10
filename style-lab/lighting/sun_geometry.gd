class_name SunGeometry
extends RefCounted
## PROTOTYPE (ticket 31, „Słońce okien liczone mapą światła”): the one set of data the window sun is
## computed from, in metres, whatever wall a window is in. A house floor is a shell (x across, d into
## the depth from the back wall, z up), sashes in its outer walls (only glass, not the frame or the
## bars), and boxes inside it (furniture, partitions, lintels, stairs, the actor). SunMap packs it into
## shader uniforms; the hidden 3D mock-up (ticket 32) is to read the same data.
## Screen ↔ metres: world y = floor_y + px_per_m × (depth_factor × d − z), world x = px_per_m × x.

enum Wall { BACK, FRONT, LEFT, RIGHT }

const MAX_SASHES: int = 64
const MAX_BOXES: int = 63 ## One more slot is the actor's.
const BAR_M: float = 0.06 ## Mullion and transom of a window the 3/4 view does not draw.

var floor_y: float = 0.0 ## World y (px) of the back wall's foot (d 0, z 0).
var shell_min: Vector3 = Vector3.ZERO
var shell_max: Vector3 = Vector3.ONE
var sashes: Array[Vector4] = [] ## u from, u to (x for back and front walls, d for side walls), z from, z to.
var sash_walls: PackedInt32Array = PackedInt32Array()
var sash_middles: PackedFloat32Array = PackedFloat32Array() ## u of the middle of the sash's window.
var boxes: Array[AABB] = [] ## Occluders (x, d, z), at full height.
var box_blocks: Array[Block] = [] ## The Block drawing each box (null: none); its shown height is the receiver.
var front_windows: PackedFloat32Array = PackedFloat32Array() ## Middles (x) of the bottom wall's windows.
var box_receives: Array[bool] = [] ## False: only an occluder (a lintel over a doorway drawn as floor).


static func ppm() -> float:
	return ProjectionConfig.current().px_per_m


static func depth_k() -> float:
	return ProjectionConfig.current().depth_factor


## A world point on the ground (px) as (x, d) in metres.
func ground_m(world: Vector2) -> Vector2:
	return Vector2(world.x / ppm(), (world.y - floor_y) / (ppm() * depth_k()))


## The shell round the rooms' floors, `height_m` high.
func fit_shell(rooms: Array[RoomLighting], height_m: float) -> void:
	var low: Vector2 = Vector2(INF, INF)
	var high: Vector2 = Vector2(-INF, -INF)
	for room: RoomLighting in rooms:
		var area: Rect2 = room.global_floor_rect()
		low = low.min(ground_m(area.position))
		high = high.max(ground_m(area.end))
	shell_min = Vector3(low.x, low.y, 0.0)
	shell_max = Vector3(high.x, high.y, height_m)


func add_sash(wall: Wall, u_from: float, u_to: float, z_from: float, z_to: float, middle: float = NAN) -> void:
	if sashes.size() >= MAX_SASHES:
		push_warning("SunGeometry: too many sashes")
		return
	sashes.append(Vector4(u_from, u_to, z_from, z_to))
	sash_walls.append(wall)
	sash_middles.append((u_from + u_to) / 2.0 if is_nan(middle) else middle)


## A drawn back-wall window: its panes, as drawn.
func add_window_light(window: WindowLight) -> void:
	var origin: Vector2 = window.global_position
	var middle: float = (origin.x + window.glass.get_center().x) / ppm()
	for pane: Rect2i in window.panes:
		add_sash(Wall.BACK, (origin.x + pane.position.x) / ppm(), (origin.x + pane.end.x) / ppm(),
				float(window.wall_height_px - pane.end.y) / ppm(), float(window.wall_height_px - pane.position.y) / ppm(), middle)


## A window in a side or the front wall (not drawn): its sashes side by side with a bar between them
## and, with rows 2, a transom across (SideWindowLight.TRANSOM_AT).
func add_side_window(window: SideWindowLight, rows: int = 2) -> void:
	var at: Vector2 = window.global_position
	var wall: Wall = Wall.FRONT
	var from: float = at.x / ppm()
	var length: float = window.span / ppm()
	if not window.into_up:
		wall = Wall.LEFT if window.into_right else Wall.RIGHT
		from = ground_m(at).y
		length = window.span / (ppm() * depth_k())
	if wall == Wall.FRONT:
		front_windows.append(from + length / 2.0)
	var sill: float = window.profile.top_sill_m
	var head: float = window.wall_height_px / ppm() - window.profile.top_head_m
	var transom: float = sill + (head - sill) * SideWindowLight.TRANSOM_AT
	var count: int = maxi(window.panes, 1)
	var pane: float = (length - BAR_M * (count - 1)) / count
	for index: int in count:
		var u: float = from + index * (pane + BAR_M)
		var middle: float = from + length / 2.0
		if rows < 2:
			add_sash(wall, u, u + pane, sill, head, middle)
		else:
			add_sash(wall, u, u + pane, sill, transom - BAR_M / 2.0, middle)
			add_sash(wall, u, u + pane, transom + BAR_M / 2.0, head, middle)


## A Block as a box; its front bottom edge's middle is its origin, its footprint behind it.
## `receives`: false for an occluder whose faces should not take the map (stairs: their steps cut a
## beam into stripes).
func add_block(block: Block, receives: bool = true) -> void:
	var foot: Vector2 = ground_m(block.global_position)
	var size: Vector3 = block.size_m
	add_box(AABB(Vector3(foot.x - size.x / 2.0, foot.y - size.y, block.lift_m),
			Vector3(size.x, size.y, size.z - block.lift_m)), block, receives)


func add_box(box: AABB, block: Block = null, receives: bool = true) -> void:
	if boxes.size() >= MAX_BOXES:
		push_warning("SunGeometry: too many boxes")
		return
	boxes.append(box)
	box_blocks.append(block)
	box_receives.append(receives)


## The receivers' tops: a Block's shown height (a partition cut down while the player is behind it),
## -1 for a hidden one (not a receiver, still an occluder).
func shown_tops() -> PackedFloat32Array:
	var tops: PackedFloat32Array = PackedFloat32Array()
	for index: int in boxes.size():
		var block: Block = box_blocks[index]
		if not box_receives[index]:
			tops.append(-1.0)
		elif block == null:
			tops.append(boxes[index].end.z)
		elif not block.visible:
			tops.append(-1.0)
		else:
			tops.append(block.size_m.z)
	return tops
