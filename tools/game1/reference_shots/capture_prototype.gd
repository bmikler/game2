# Captures the visual reference (spec §14) from the lighting prototype without changing its code:
# this script stays in game1 and only drives the prototype's station_kit scene from outside.
# The whole station fits one 960x540 frame and exposure does not depend on the player (ADR 0007),
# so a set is one frame per fixed hour plus each room's rectangle in manifest.json.
# Actors are hidden: rooms are compared before Badacz and Krogg exist in the game. Snow is hidden
# too, so a capture of the game has to hide both.
# Usage: see README.md next to this file.
extends SceneTree

const SCENE := "res://station_kit.tscn"
const REQUIRED_HALL_VARIANT := "lampy"
const SETTLE_FRAMES := 10
const OFF_MAP := Vector2(-4000.0, -4000.0)
const ROOM_IDS: Dictionary[String, String] = {
	"Hall": "hall",
	"Corridor": "corridor",
	"Office": "office",
	"BreakRoom": "break_room",
	"Cells": "cells",
}
# Each hour shows a different state of the sun, the sky and the lamp schedule.
const HOURS: Array[Dictionary] = [
	{"id": "swit", "hour": 7.5},
	{"id": "wschod", "hour": 8.25},
	{"id": "ranek", "hour": 10.0},
	{"id": "dzien", "hour": 12.0},
	{"id": "popoludnie", "hour": 15.0},
	{"id": "zachod", "hour": 16.25},
	{"id": "zlota_godzina", "hour": 17.0},
	{"id": "niebieska_godzina", "hour": 17.6},
	{"id": "noc", "hour": 22.0},
]


func _initialize() -> void:
	_capture()


func _capture() -> void:
	var out_dir := _out_dir()
	if out_dir.is_empty():
		_fail("Missing --out=<directory> after --.")
		return
	var error := DirAccess.make_dir_recursive_absolute(out_dir)
	if error != OK:
		_fail("Cannot create %s: %s" % [out_dir, error_string(error)])
		return

	var kit: Node = (load(SCENE) as PackedScene).instantiate()
	root.add_child(kit)
	await process_frame	# _ready runs only once the main loop has started
	var layout: RefCounted = kit.get("layout")
	if layout.get("hall_variant") != REQUIRED_HALL_VARIANT:
		_fail("The reference needs --hall=%s after --." % REQUIRED_HALL_VARIANT)
		return

	var rooms := _rooms(kit)
	if rooms.is_empty():
		_fail("A room in the prototype has no id in ROOM_IDS.")
		return

	_hide_actors(kit)
	_hide_snow(kit)
	var display: SubViewport = kit.get("display")
	var frames: Array[Dictionary] = []
	for entry: Dictionary in HOURS:
		var hour: float = entry["hour"]
		var file_name := "%s_%s.png" % [_clock(hour), entry["id"]]
		kit.set("hour", hour)
		kit.set("light_dirty", true)
		for _i: int in SETTLE_FRAMES:
			await process_frame
		await RenderingServer.frame_post_draw
		error = display.get_texture().get_image().save_png(out_dir.path_join(file_name))
		if error != OK:
			_fail("Cannot save %s: %s" % [file_name, error_string(error)])
			return
		frames.append({"id": entry["id"], "hour": hour, "file": file_name})
		print(file_name)

	var manifest := {
		"source": _source(),
		"size": [display.size.x, display.size.y],
		"rooms": rooms,
		"frames": frames,
	}
	var file := FileAccess.open(out_dir.path_join("manifest.json"), FileAccess.WRITE)
	if file == null:
		_fail("Cannot write manifest.json: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(manifest, "  ") + "\n")
	file.close()
	quit(0)


func _out_dir() -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--out="):
			return argument.trim_prefix("--out=")
	return ""


func _hide_actors(kit: Node) -> void:
	# The kit shows and hides Krogg's node by the hour, but never touches his sprite.
	(kit.get("krogg_spr") as CanvasItem).visible = false
	kit.set("krogg_walks", false)
	# Off every floor, so Badacz's rim light stays off; the camera limits keep the frame in place.
	var player: Node2D = kit.get("player")
	player.visible = false
	player.position = OFF_MAP


func _rooms(kit: Node) -> Array[Dictionary]:
	var rooms: Array[Dictionary] = []
	var lightings: Array[Node] = []
	lightings.assign(kit.get("rooms"))
	for lighting: Node in lightings:
		var room_name := String(lighting.get_parent().name)
		if not ROOM_IDS.has(room_name):
			return []
		var rect: Rect2 = lighting.call("global_ambient_rect")
		rooms.append({
			"id": ROOM_IDS[room_name],
			"rect": [int(rect.position.x), int(rect.position.y), int(rect.size.x), int(rect.size.y)],
		})
	return rooms


# Flakes are sharp and random, so two frames would never match behind the glass. Only back windows
# have snow; side and front windows extend WindowLight without it.
func _hide_snow(kit: Node) -> void:
	var windows: Array[Node] = []
	windows.assign(kit.get("windows"))
	for window: Node in windows:
		var snow: CanvasItem = window.get("_snow")
		if snow != null:
			snow.visible = false


func _source() -> Dictionary:
	return {
		"project": "game1-proto",
		"branch": _git(["branch", "--show-current"]),
		"commit": _git(["rev-parse", "HEAD"]),
		# Shot folders in the prototype are untracked, so only changes to tracked files count.
		"uncommitted_changes": not _git(["status", "--porcelain", "--untracked-files=no"]).is_empty(),
		"godot": Engine.get_version_info()["string"],
		"args": " ".join(_variant_args()),
	}


func _variant_args() -> PackedStringArray:
	var args := PackedStringArray()
	for argument: String in OS.get_cmdline_user_args():
		if not argument.begins_with("--out="):
			args.append(argument)
	return args


func _git(args: PackedStringArray) -> String:
	var full_args := PackedStringArray(["-C", ProjectSettings.globalize_path("res://")])
	full_args.append_array(args)
	var output: Array[String] = []
	if OS.execute("git", full_args, output) != 0:
		return "unknown"
	return String(output[0]).strip_edges()


func _clock(hour: float) -> String:
	var minutes := roundi(hour * 60.0)
	return "%02d%02d" % [minutes / 60, minutes % 60]


func _fail(message: String) -> void:
	printerr(message)
	quit(1)
