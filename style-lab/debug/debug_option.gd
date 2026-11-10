class_name DebugOption
extends RefCounted
## One switch in the debug panel: an on/off toggle (no choices) or a variant picked from choices.
## `apply` gets the new value: a bool for a toggle, the chosen index (int) for a variant.

var id: StringName
var label: String
var choices: PackedStringArray = PackedStringArray()
var value: int = 0 ## Toggle: 0 off, 1 on. Variant: index into choices.
var apply: Callable
var owner: Node ## Removed from the registry when its owner leaves the tree.
var slider: bool = false ## A variant shown as a slider over its choices (in order).


func is_toggle() -> bool:
	return choices.is_empty()


## Short text for screenshot names, e.g. "latarnie-on" or "sciany-zielone".
func describe() -> String:
	var shown: String = ("on" if value == 1 else "off") if is_toggle() else choices[value]
	return "%s-%s" % [id, shown]


func call_apply() -> void:
	if not apply.is_valid():
		return
	if is_toggle():
		apply.call(value == 1)
	else:
		apply.call(value)
