class_name LightingDirector
extends Node
## Lighting for one scene (a building or the outside). The scene above calls down: apply_time() when
## the game minute changes, set_view() when the camera moves, actor_mask()/rim() for actors. It owns
## the scene's CanvasModulate, kept black: every room lights its own ambient. Only rooms in view are
## active and recomputed.

@export var profile: TimeOfDayProfile
@export var view_margin: float = 64.0
## An actor takes the lights of the one room it stands in; in a door gap the border runs this far past
## the floor (half a wall). Summing two rooms' lights made a bright bump in doorways, and reaching
## further let corridor lamps shine through walls.
@export var threshold_px: float = 3.0

var sun: SunSample

var _rooms: Array[RoomLighting] = []
var _modulate: CanvasModulate


func _ready() -> void:
	_modulate = CanvasModulate.new()
	_modulate.color = Color.BLACK
	add_child(_modulate)


func setup(rooms: Array[RoomLighting]) -> void:
	_rooms = rooms
	# No wall inside a space: each room's lamps reach the other rooms' floors (not their walls).
	for room: RoomLighting in rooms:
		if room.space.is_empty():
			continue
		var floors: int = 0
		for other: RoomLighting in rooms:
			if other != room and other.space == room.space:
				floors |= LightMasks.of(other.slot, LightMasks.Receiver.FLOOR)
		room.light_floors(floors)


func apply_time(hour: float) -> void:
	sun = profile.sample(hour)
	for room: RoomLighting in _rooms:
		if room.active:
			_apply(room)


## Rooms outside the view (with a margin) switch off; a room switching on catches up once.
func set_view(view: Rect2) -> void:
	var grown: Rect2 = view.grow(view_margin)
	for room: RoomLighting in _rooms:
		var on: bool = grown.intersects(room.global_ambient_rect())
		if on == room.active:
			continue
		room.set_active(on)
		if on and sun != null:
			_apply(room)


## Light mask bits for an actor at `feet`: the actor bit of the room it stands in (0 outside).
func actor_mask(feet: Vector2) -> int:
	for room: RoomLighting in _rooms:
		if room.global_floor_rect().grow(threshold_px).has_point(feet):
			return LightMasks.of(room.slot, LightMasks.Receiver.ACTOR)
	return 0


## For feet on no floor, in a door through a wall face: the actor bits of the nearest floor above and
## the nearest below in the same column, each within `reach` px (0 when there is none).
func passage_mask(feet: Vector2, reach: float) -> int:
	var above: RoomLighting = null
	var below: RoomLighting = null
	var above_gap: float = reach
	var below_gap: float = reach
	for room: RoomLighting in _rooms:
		var floor_rect: Rect2 = room.global_floor_rect()
		if feet.x < floor_rect.position.x or feet.x > floor_rect.end.x:
			continue
		var gap_up: float = feet.y - floor_rect.end.y
		var gap_down: float = floor_rect.position.y - feet.y
		if gap_up >= 0.0 and gap_up <= above_gap:
			above = room
			above_gap = gap_up
		if gap_down >= 0.0 and gap_down <= below_gap:
			below = room
			below_gap = gap_down
	var mask: int = 0
	for room: RoomLighting in [above, below]:
		if room != null:
			mask |= LightMasks.of(room.slot, LightMasks.Receiver.ACTOR)
	return mask


## A room in a shared space (RoomLighting.space) takes the light of every room in it, also those out of
## view: the space has one level wherever the camera is.
func _apply(room: RoomLighting) -> void:
	if room.space.is_empty():
		room.apply(sun)
		return
	var flux: Vector3 = Vector3.ZERO
	var area: float = 0.0
	for other: RoomLighting in _rooms:
		if other.space == room.space:
			flux += other.light_flux(sun)
			area += other.floor_area_m2()
	room.apply_in_space(sun, flux, area)


func rim(feet: Vector2) -> Color:
	for room: RoomLighting in _rooms:
		if room.global_floor_rect().has_point(feet):
			return room.rim(feet)
	return Color(0, 0, 0, 0)
