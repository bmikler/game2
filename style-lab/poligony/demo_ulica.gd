extends Poligon
## Skeleton demo, outside: a snowy street with a house to enter, two other blocks and street lamps.
## Not Poligon Ulica (its own ticket); it shows the mechanisms: lamps on a schedule, the sky behind the
## facades, a toggle and a variant in the debug panel.

const SNOW_COLORS: Dictionary[String, Color] = {
	"biały": Color("e8ecf2"),
	"szary": Color("b9bcc2"),
	"niebieskawy": Color("c6d2e6"),
}

@onready var _street: RoomBox = %Ground
@onready var _lamps: Node2D = %Lamps
@onready var _sky: Polygon2D = %Sky


func apply_time(hour: float) -> void:
	super.apply_time(hour)
	var sky: Color = director.sun.sky_color
	var bright: float = lerpf(0.25, 1.0, director.sun.day)
	_sky.color = Color(sky.r * bright, sky.g * bright, sky.b * bright)


func _register_options() -> void:
	DebugRegistry.add_toggle(self, &"latarnie", "Latarnie", true, func(on: bool) -> void:
		_lamps.visible = on)
	var names: PackedStringArray = PackedStringArray(SNOW_COLORS.keys())
	DebugRegistry.add_variant(self, &"snieg", "Śnieg na ziemi", names, 0, func(index: int) -> void:
		_street.floor_color = SNOW_COLORS[names[index]]
		_street.repaint())
