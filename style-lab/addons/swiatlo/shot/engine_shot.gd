class_name EngineShot
extends Node
## Shots with a state description, one per Location. The `screenshot` action (F12) or `take()` (the
## engine panel's „Zrzut”) saves the frame before scaling as PNG with a ShotDescription next to it
## and puts the PNG's path on the clipboard. The Location adds its own switches with `add_switch`.
##
## Replay: started with `-- --z-zrzutu=<png or json>` in the shot's scene (or through `replay.tscn`,
## which opens that scene), it applies the hour, switches and character, stops time and saves
## `<shot>__odtworzenie.png` next to the original; with `--wyjdz` it then quits.

signal taken(path: String)

const QUIT_ARGUMENT: String = "--wyjdz"
const REPLAY_SUFFIX: String = "__odtworzenie"

## The Location's frame (the picture before scaling to the window).
@export var frame: SubViewport
@export var engine: LightEngine
## The character whose position goes into the description (optional).
@export var character: Node2D
## Where shots go (a project or user folder); the saved path is always absolute.
@export var folder: String = "user://shots"
## The Input Map action that takes a shot.
@export var action: StringName = &"screenshot"

var _switch_readers: Dictionary[String, Callable] = {}
var _switch_appliers: Dictionary[String, Callable] = {}


func _ready() -> void:
	if not InputMap.has_action(action):
		push_warning("Light engine: no input action '%s' for shots" % action)
	_replay_if_asked.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if InputMap.has_action(action) and event.is_action_pressed(action):
		take()
		get_viewport().set_input_as_handled()


## A Location switch: `read` returns its shown value, `apply` sets it from that value.
func add_switch(switch_name: String, read: Callable, apply_value: Callable) -> void:
	_switch_readers[switch_name] = read
	_switch_appliers[switch_name] = apply_value


func describe() -> ShotDescription:
	var description: ShotDescription = ShotDescription.new()
	description.scene = owner.scene_file_path if owner != null else ""
	description.hour = engine.hour
	description.rate = engine.rate
	if is_instance_valid(character):
		description.has_character = true
		description.character = character.position
	for switch_name: String in _switch_readers:
		description.switches[switch_name] = str(_switch_readers[switch_name].call())
	return description


## Saves the shot and returns the PNG's absolute path ("" on failure). Without `path` the name is
## `<scene>__<HHMM>__<date and time>.png` in `folder`.
func take(path: String = "") -> String:
	var description: ShotDescription = describe()
	if path.is_empty():
		path = _new_path(description)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var error: Error = frame.get_texture().get_image().save_png(path)
	if error == OK:
		error = description.save_next_to(path)
	if error != OK:
		push_error("Zrzut nieudany (%s): %s" % [error_string(error), path])
		return ""
	DisplayServer.clipboard_set(path)
	print("Zrzut: ", path)
	taken.emit(path)
	return path


## Sets the described frame: hour (time stopped), switches and character.
func apply(description: ShotDescription) -> void:
	if not description.variant.is_empty():
		push_warning("Light engine: Variants are not supported yet, '%s' ignored" % description.variant)
	for switch_name: String in description.switches:
		if _switch_appliers.has(switch_name):
			_switch_appliers[switch_name].call(description.switches[switch_name])
		else:
			push_warning("Light engine: the shot's switch '%s' is unknown here" % switch_name)
	if description.has_character and is_instance_valid(character):
		character.position = description.character
	engine.rate = 0.0
	engine.set_hour(description.hour)


func _replay_if_asked() -> void:
	var source: String = ShotDescription.replay_path(OS.get_cmdline_user_args())
	if source.is_empty():
		return
	var description: ShotDescription = ShotDescription.load_next_to(source)
	if description == null:
		push_error("Brak opisu zrzutu obok: %s" % source)
		_quit_if_asked(1)
		return
	var scene: String = owner.scene_file_path if owner != null else ""
	if scene != description.scene:
		push_error("Zrzut jest ze sceny %s, nie z %s" % [description.scene, scene])
		_quit_if_asked(1)
		return
	apply(description)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	take(source.get_basename() + REPLAY_SUFFIX + ".png")
	_quit_if_asked(0)


func _quit_if_asked(exit_code: int) -> void:
	if OS.get_cmdline_user_args().has(QUIT_ARGUMENT):
		get_tree().quit(exit_code)


func _new_path(description: ShotDescription) -> String:
	var scene_name: String = description.scene.get_file().get_basename()
	if scene_name.is_empty():
		scene_name = "lokacja"
	var stamp: String = Time.get_datetime_string_from_system().replace(":", "")
	var file_name: String = "%s__%s__%s-%03d.png" % [
			scene_name, description.clock(""), stamp, Time.get_ticks_msec() % 1000]
	return ProjectSettings.globalize_path(folder).path_join(file_name.validate_filename())
