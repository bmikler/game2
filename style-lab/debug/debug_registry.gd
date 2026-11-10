extends Node
## Autoload "DebugRegistry": the toggles and variants shown in the debug panel. Each Poligon adds its
## own in _ready; they go away with it. The panel lists them and sets values through here.

signal options_changed

var _options: Array[DebugOption] = []
## Options kept (and still in screenshot names) but not listed in the panel: a Poligon trims the
## panel to what its question needs (sets it on build, clears it on leaving).
var hidden: Array[StringName] = []
## The panel shows only the clock and the listed options (no rate, pixel perfect, screenshot button).
var minimal: bool = false
## Last value of every option, also after its owner left: a Poligon reloaded with another scale gets
## its choices back. Seeded from the command line (`--set=id=index,...`).
var _remembered: Dictionary[StringName, int] = {}


## Adds an on/off switch; `apply(on: bool)` runs now and on every change.
func add_toggle(owner: Node, id: StringName, label: String, on: bool, apply: Callable) -> void:
	_add(owner, id, label, PackedStringArray(), 1 if on else 0, apply)


## Adds a choice between variants; `apply(index: int)` runs now and on every change.
func add_variant(
		owner: Node, id: StringName, label: String, choices: PackedStringArray, index: int,
		apply: Callable) -> void:
	_add(owner, id, label, choices, index, apply)


## A variant shown as a slider over its choices (ordered values, e.g. "x0,5" … "x1,5").
func add_slider(
		owner: Node, id: StringName, label: String, choices: PackedStringArray, index: int,
		apply: Callable) -> void:
	_add(owner, id, label, choices, index, apply)
	_options[-1].slider = true
	options_changed.emit()


func options() -> Array[DebugOption]:
	return _options


## Sets the value an option takes when it is (next) added, e.g. from the command line.
func remember(id: StringName, value: int) -> void:
	_remembered[id] = value


func set_value(id: StringName, value: int) -> void:
	_remembered[id] = value
	for option: DebugOption in _options:
		if option.id == id:
			option.value = value
			option.call_apply()
			return


## Moves a variant to its next choice (wrapping); false when there is no such option now.
func cycle(id: StringName) -> bool:
	for option: DebugOption in _options:
		if option.id == id and not option.is_toggle():
			set_value(id, (option.value + 1) % option.choices.size())
			return true
	return false


## The current values, for screenshot names: "latarnie-on_sciany-zielone".
func describe() -> String:
	var parts: PackedStringArray = PackedStringArray()
	for option: DebugOption in _options:
		parts.append(option.describe())
	return "_".join(parts)


func _add(
		owner: Node, id: StringName, label: String, choices: PackedStringArray, value: int,
		apply: Callable) -> void:
	_remove(id)
	var option: DebugOption = DebugOption.new()
	option.id = id
	option.label = label
	option.choices = choices
	option.value = _remembered[id] if _remembered.has(id) else value
	if not choices.is_empty():
		option.value = clampi(option.value, 0, choices.size() - 1)
	_remembered[id] = option.value
	option.apply = apply
	option.owner = owner
	_options.append(option)
	if not owner.tree_exiting.is_connected(_on_owner_exiting):
		owner.tree_exiting.connect(_on_owner_exiting.bind(owner))
	option.call_apply()
	options_changed.emit()


func _remove(id: StringName) -> void:
	for index: int in range(_options.size() - 1, -1, -1):
		if _options[index].id == id:
			_options.remove_at(index)


func _on_owner_exiting(owner: Node) -> void:
	for index: int in range(_options.size() - 1, -1, -1):
		if _options[index].owner == owner:
			_options.remove_at(index)
	options_changed.emit()
