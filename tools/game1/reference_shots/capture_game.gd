# Captures the game the way capture_prototype.gd captures the prototype, so compare.mjs can put the two
# sets side by side. The hours and file names come from the reference's manifest. The game has no
# screenshot flags (spec §14): this script stays outside it and only drives Main from outside.
# Usage: see README.md next to this file.
extends SceneTree

const SCENE: String = "res://main/main.tscn"
const REFERENCE_MANIFEST: String = "res://../art/reference/prototype/manifest.json"
const SETTLE_FRAMES: int = 10


func _initialize() -> void:
	_capture()


func _capture() -> void:
	var out_dir: String = _out_dir()
	if out_dir.is_empty():
		_fail("Missing --out=<directory> after --.")
		return
	var error: Error = DirAccess.make_dir_recursive_absolute(out_dir)
	if error != OK:
		_fail("Cannot create %s: %s" % [out_dir, error_string(error)])
		return

	# Typed as Node: Main depends on the GameState autoload, which a --script file cannot compile against.
	var main: Node = (load(SCENE) as PackedScene).instantiate()
	root.add_child(main)
	await process_frame # _ready runs only once the main loop has started
	var game_mode: GameMode = main.get("game_mode")
	game_mode.set_mode(GameMode.Mode.MENU) # a running clock would overwrite the hour set below
	var view: LitView = main.get_node("World/LitView") as LitView
	var station: Station = view.world as Station
	station.investigator.visible = false # the reference has no actors
	for window: Node in station.find_children("*", "WindowLight", true, false):
		(window as WindowLight).snow.visible = false # random flakes never match between two runs

	for frame: Dictionary in _reference_frames():
		var file_name: String = frame["file"]
		var hour: float = frame["hour"]
		station.set_hour(hour)
		for _i: int in SETTLE_FRAMES:
			await process_frame
		await RenderingServer.frame_post_draw
		error = view.display.get_texture().get_image().save_png(out_dir.path_join(file_name))
		if error != OK:
			_fail("Cannot save %s: %s" % [file_name, error_string(error)])
			return
		print(file_name)
	quit(0)


func _reference_frames() -> Array[Dictionary]:
	var path: String = ProjectSettings.globalize_path(REFERENCE_MANIFEST)
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var listed: Array = manifest["frames"]
	var frames: Array[Dictionary] = []
	frames.assign(listed)
	return frames


func _out_dir() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--out="):
			return argument.trim_prefix("--out=")
	return ""


func _fail(message: String) -> void:
	printerr(message)
	quit(1)
