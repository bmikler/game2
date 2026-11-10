# Captures the game once per variant and hour, for a variant sheet (compose.mjs puts them in a grid).
# A variant is a set of tweaks applied to a fresh Main from outside, the way capture_game.gd drives it:
# the game has no variant flags (spec §14). Opens a window for a few seconds (rendering needs the GPU).
# Usage: see README.md next to this file.
extends SceneTree

const SCENE: String = "res://main/main.tscn"
const SETTLE_FRAMES: int = 10
## Sheets: hours (columns) and variants (rows) by name. Each variant is a list of tweaks:
## ["lux", <fixture path>, lux], ["windows", <WindowLightProfile property>, value] (every back window),
## ["shadows", "none"] (no contact shadow at the foot of the back wall).
const SHEETS: Dictionary = {
	"office": { # Desk lamp (L) and monitor (M) lux; the tube is gone.
		"hours": [8.25, 12.0, 17.0, 22.0],
		"variants": {
			"L400_M120": [],
			"L200_M120": [["lux", "Office/Lighting/DeskLamp", 200.0]],
			"L0_M120": [["lux", "Office/Lighting/DeskLamp", 0.0]],
			"L400_M240": [["lux", "Office/Lighting/Monitor", 240.0]],
			"L200_M240": [["lux", "Office/Lighting/DeskLamp", 200.0], ["lux", "Office/Lighting/Monitor", 240.0]],
			"L0_M240": [["lux", "Office/Lighting/DeskLamp", 0.0], ["lux", "Office/Lighting/Monitor", 240.0]],
		},
	},
	"night_windows": { # Back windows by night: view gain (W) and glow at the window (G, lux).
		"hours": [17.6, 22.0],
		"variants": {
			"W1_G0": [],
			"W1.5_G0": [["windows", "night_view_gain", 1.5]],
			"W2_G0": [["windows", "night_view_gain", 2.0]],
			"W1.5_G40": [["windows", "night_view_gain", 1.5], ["windows", "night_glow_lux", 40.0]],
			"W1.5_G80": [["windows", "night_view_gain", 1.5], ["windows", "night_glow_lux", 80.0]],
		},
	},
	"shadows": {
		"hours": [12.0, 22.0],
		"variants": {
			"obecne": [],
			"bez_cieni": [["shadows", "none"]],
		},
	},
}


func _initialize() -> void:
	_capture()


func _capture() -> void:
	var out_dir: String = _arg("out")
	var sheet_name: String = _arg("sheet")
	if out_dir.is_empty() or not SHEETS.has(sheet_name):
		_fail("Usage: -- --sheet=<%s> --out=<directory>" % "|".join(SHEETS.keys()))
		return
	var only: String = _arg("variants")
	DirAccess.make_dir_recursive_absolute(out_dir)
	var sheet: Dictionary = SHEETS[sheet_name]
	for variant: String in sheet["variants"]:
		if not only.is_empty() and not variant in only.split(","):
			continue
		var main: Node = (load(SCENE) as PackedScene).instantiate()
		root.add_child(main)
		await process_frame # _ready runs only once the main loop has started
		var game_mode: GameMode = main.get("game_mode")
		game_mode.set_mode(GameMode.Mode.MENU) # a running clock would overwrite the hour set below
		var view: LitView = main.get_node("World/LitView") as LitView
		var station: Station = view.world as Station
		station.investigator.visible = false
		for window: Node in station.find_children("*", "WindowLight", true, false):
			(window as WindowLight).snow.visible = false
		for tweak: Array in sheet["variants"][variant]:
			_apply(station, tweak)
		for hour: float in sheet["hours"]:
			station.set_hour(hour)
			for _i: int in SETTLE_FRAMES:
				await process_frame
			await RenderingServer.frame_post_draw
			var minutes: int = roundi(hour * 60.0)
			var file_name: String = "%s_%02d%02d.png" % [variant, floori(minutes / 60.0), minutes % 60]
			view.display.get_texture().get_image().save_png(out_dir.path_join(file_name))
			print(file_name)
		main.queue_free()
		await process_frame
	quit(0)


func _apply(station: Station, tweak: Array) -> void:
	match tweak[0]:
		"lux":
			var fixture: LightFixture = station.get_node(NodePath(str(tweak[1]))) as LightFixture
			fixture.def = fixture.def.duplicate() as FixtureDef # shared .tres stays untouched
			fixture.def.lux = tweak[2]
		"windows": # the shared profile, in memory only (the .tres file is not saved)
			var window: WindowLight = station.get_node("Office/Lighting/Window") as WindowLight
			window.profile.set(str(tweak[1]), tweak[2])
		"shadows":
			for shell: Node in station.find_children("*", "RoomShell", true, false):
				for child: Node in shell.get_children():
					var sprite: Sprite2D = child as Sprite2D
					if sprite == null or sprite.z_index != RoomShell.SHADOW_Z:
						continue
					sprite.visible = tweak[1] != "none"
		_:
			push_error("Unknown tweak %s" % [tweak])


func _arg(name: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return ""


func _fail(message: String) -> void:
	printerr(message)
	quit(1)
