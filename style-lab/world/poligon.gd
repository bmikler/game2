class_name Poligon
extends Node2D
## Base of every Poligon scene: %Lighting (LightingDirector), %World (y-sorted: rooms, blocks, doors,
## the player), %Spawns (Marker2D points). Main calls down: start() once, apply_time() each game
## minute. Doors report up through door_used. Subclasses add their debug options in _register_options()
## and may build their content in code in _build() (before the world is collected); a change that needs
## the scene built again goes up through reload_requested.

signal door_used(target_scene: String, spawn: StringName)
signal reload_requested

@export var title: String = "poligon" ## Used in screenshot names.
@export var interior: bool = false ## Takes the interior frame (Main: "Kadr wnętrza").

var player: PlaceholderActor
var rooms: Array[RoomLighting] = []

var _view_size: Vector2 = Vector2.ZERO

@onready var director: LightingDirector = %Lighting
@onready var world: Node2D = %World
@onready var spawns: Node2D = %Spawns


func _ready() -> void:
	_build()
	_collect(world)
	director.setup(rooms)
	_register_options()


func _physics_process(_delta: float) -> void:
	if player == null:
		return
	player.set_light_bits(director.actor_mask(player.global_position))
	var size: Vector2 = get_viewport().get_visible_rect().size
	if size != _view_size:
		_view_size = size
		player.set_camera_limits(_fit_to_view(_bounds(), size))
	var view: Rect2 = get_viewport().get_canvas_transform().affine_inverse() \
			* Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size)
	director.set_view(view)


## Puts the player at the spawn point (the first one when the name is unknown).
func start(spawn: StringName) -> void:
	player = PlaceholderActor.new()
	var marker: Node2D = spawns.get_node_or_null(NodePath(String(spawn))) as Node2D
	if marker == null:
		marker = spawns.get_child(0) as Node2D
	player.position = marker.position
	world.add_child(player)
	_view_size = get_viewport().get_visible_rect().size
	player.set_camera_limits(_fit_to_view(_bounds(), _view_size))
	player.camera.reset_smoothing()


func apply_time(hour: float) -> void:
	director.apply_time(hour)


## Where the player stands on the ground in metres (x across, z into the depth), so a reload at
## another scale can put them back. Vector2.INF: not kept (override to keep it).
func player_spot() -> Vector2:
	return Vector2.INF


## Puts the player at a spot from player_spot().
func move_player(_spot: Vector2) -> void:
	pass


## Override: build content in code (rooms, blocks, doors, spawns) before the world is collected.
func _build() -> void:
	pass


## Override: add this Poligon's toggles and variants to DebugRegistry (owner: self).
func _register_options() -> void:
	pass


## Everything the rooms draw, for the camera limits.
func _bounds() -> Rect2:
	var area: Rect2 = Rect2()
	for room: RoomLighting in rooms:
		var drawn: Rect2 = room.global_ambient_rect()
		area = area.merge(drawn) if area.has_area() else drawn
	return area


## A map smaller than the view sits in the middle of it instead of at its top left corner.
static func _fit_to_view(area: Rect2, view: Vector2) -> Rect2:
	var grow: Vector2 = (view - area.size).max(Vector2.ZERO) / 2.0
	return area.grow_individual(grow.x, grow.y, grow.x, grow.y)


func _collect(node: Node) -> void:
	for child: Node in node.get_children():
		if child is RoomLighting:
			rooms.append(child as RoomLighting)
		elif child is Door:
			(child as Door).used.connect(func(target: String, spawn: StringName) -> void:
				door_used.emit(target, spawn))
		_collect(child)
