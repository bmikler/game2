class_name GameClock
extends RefCounted
## Game time of day. `rate`: game seconds per real second (60 = a game minute per second; 0 stops).

const DAY_H: float = 24.0

var hour: float = 12.0
var rate: float = 60.0

var _last_minute: int = -1


## Moves time on; true when the game minute changed (and the world needs new light).
func advance(delta: float) -> bool:
	hour = fposmod(hour + delta * rate / 3600.0, DAY_H)
	return _minute_changed()


func set_hour(value: float) -> void:
	hour = fposmod(value, DAY_H)
	_last_minute = -1


## "HH:MM", or "HHMM" for file names.
func label(separator: String = ":") -> String:
	var minutes: int = int(hour * 60.0)
	return "%02d%s%02d" % [minutes / 60, separator, minutes % 60]


func _minute_changed() -> bool:
	var minute: int = int(hour * 60.0)
	if minute == _last_minute:
		return false
	_last_minute = minute
	return true
