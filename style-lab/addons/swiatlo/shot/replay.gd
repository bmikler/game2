extends Node
## Opens the scene of the shot given with `-- --z-zrzutu=<png or json>`; the EngineShot in that scene
## replays it. Run: `godot --path <project> res://addons/swiatlo/shot/replay.tscn -- --z-zrzutu=<file>`
## (add `--wyjdz` to quit after the replayed shot is saved).


func _ready() -> void:
	var source: String = ShotDescription.replay_path(OS.get_cmdline_user_args())
	var description: ShotDescription = ShotDescription.load_next_to(source) if not source.is_empty() else null
	if description == null or description.scene.is_empty():
		push_error("Odtwarzanie: brak opisu zrzutu (--z-zrzutu=%s)" % source)
		get_tree().quit(1)
		return
	get_tree().change_scene_to_file.call_deferred(description.scene)
