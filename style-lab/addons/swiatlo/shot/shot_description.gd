class_name ShotDescription
extends RefCounted
## What a shot shows: the scene, the hour, the Variant, the character's position and the Location's
## switches. Saved as JSON next to the PNG (same name, `.json`); `--z-zrzutu=<png or json>` reads it
## back to replay the same frame.

const REPLAY_ARGUMENT: String = "--z-zrzutu="

## The scene file the shot was taken in.
var scene: String = ""
## Hour of the day, 0–24, at full precision.
var hour: float = 0.0
## Game minutes per real second when the shot was taken (a replay freezes time).
var rate: float = 0.0
## The tuning Variant (empty: the defaults).
var variant: String = ""
## Whether the Location has a character, and its position.
var has_character: bool = false
var character: Vector2 = Vector2.ZERO
## The Location's own switches: name → shown value.
var switches: Dictionary[String, String] = {}


## The `--z-zrzutu=` path among user arguments, or "" without one.
static func replay_path(arguments: PackedStringArray) -> String:
	for argument: String in arguments:
		if argument.begins_with(REPLAY_ARGUMENT):
			return argument.trim_prefix(REPLAY_ARGUMENT)
	return ""


## The description saved next to `image_path` (a `.png` or the `.json` itself), or null.
static func load_next_to(image_path: String) -> ShotDescription:
	var text: String = FileAccess.get_file_as_string(_json_path(image_path))
	if text.is_empty():
		return null
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return null
	var data: Dictionary = parsed
	return from_data(data)


static func from_data(data: Dictionary) -> ShotDescription:
	var description: ShotDescription = ShotDescription.new()
	description.scene = str(data.get("scene", ""))
	description.hour = _number(data.get("hour"))
	description.rate = _number(data.get("rate"))
	description.variant = str(data.get("variant", ""))
	var position: Variant = data.get("character")
	if typeof(position) == TYPE_ARRAY:
		var pair: Array = position
		if pair.size() == 2:
			description.has_character = true
			description.character = Vector2(_number(pair[0]), _number(pair[1]))
	var switches: Variant = data.get("switches")
	if typeof(switches) == TYPE_DICTIONARY:
		var named: Dictionary = switches
		for key: Variant in named:
			description.switches[str(key)] = str(named[key])
	return description


func save_next_to(image_path: String) -> Error:
	var file: FileAccess = FileAccess.open(_json_path(image_path), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(to_json())
	return OK


## The hour as a clock, e.g. "07:30" (`separator` "" gives "0730" for file names).
func clock(separator: String = ":") -> String:
	var minutes: int = int(hour * 60.0)
	return "%02d%s%02d" % [minutes / 60, separator, minutes % 60]


func to_json() -> String:
	var position: Variant = null
	if has_character:
		position = [character.x, character.y]
	var data: Dictionary = {
		"scene": scene,
		"hour": hour,
		"time": clock(),
		"rate": rate,
		"variant": variant,
		"character": position,
		"switches": switches,
	}
	return JSON.stringify(data, "\t", false, true)


## The same frame: scene, hour, Variant, character and switches (not the time rate).
func matches(other: ShotDescription) -> bool:
	var same_character: bool = has_character == other.has_character \
			and (not has_character or character.is_equal_approx(other.character))
	return scene == other.scene and is_equal_approx(hour, other.hour) and variant == other.variant \
			and same_character and switches == other.switches


static func _number(value: Variant) -> float:
	return value if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT else 0.0


static func _json_path(image_path: String) -> String:
	return image_path.get_basename() + ".json"
