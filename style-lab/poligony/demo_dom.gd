extends Poligon
## Skeleton demo, inside: one room behind the house's door, with a back window (sun beams, the view
## outside, snow behind the glass), a floor lamp, a desk lamp and the cold spill at the door.

const WALL_COLORS: Dictionary[String, Color] = {
	"beż": Color("8c8a80"),
	"zieleń": Color("6f7d68"),
	"bordo": Color("7a4a48"),
}

@onready var _room: RoomBox = %Room
@onready var _floor_lamp: LightFixture = %FloorLamp


func _register_options() -> void:
	DebugRegistry.add_toggle(self, &"lampa", "Lampa stojąca", true, func(on: bool) -> void:
		_floor_lamp.visible = on)
	var names: PackedStringArray = PackedStringArray(WALL_COLORS.keys())
	DebugRegistry.add_variant(self, &"sciany", "Ściany", names, 0, func(index: int) -> void:
		_room.wall_color = WALL_COLORS[names[index]]
		_room.repaint())
