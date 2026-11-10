extends Node
## style-lab root: shows the current Poligon through the LitView, runs the game clock, swaps Poligons
## when a door is used, and acts on the debug panel (time, pixel perfect, screenshots).

const START_SCENE: String = "res://poligony/demo_ulica.tscn"
const SHOTS_DIR: String = "res://shots"
## Projection variants (ticket Rzut): same px/m, smaller base resolution is a closer camera.
const FRAMES: Array[Vector2i] = [Vector2i(960, 540), Vector2i(800, 450), Vector2i(640, 360), Vector2i(480, 270)]
const START_FRAME: Vector2i = Vector2i(800, 450)
# Ticket Przepis postaci: only the three camera angles that have a character made for them
# (was [1.0, 0.75, 0.7, 0.6, 0.5, 0.36]; tools/arkusz_rzutu.mjs indexes the old list).
const DEPTH_FACTORS: Array[float] = [0.36, 0.6, 0.7] # float64: find() must match the config
const PX_PER_M: Array[float] = [32.0, 36.0, 40.0]
## Ticket 27: the screen fades to black through a door (ADR 0007: each space keeps its own exposure,
## the fade hides the jump), out and in, seconds each way.
const DOOR_FADES: PackedStringArray = ["brak", "0,3 s", "0,6 s"]
const DOOR_FADE_S: PackedFloat32Array = [0.0, 0.3, 0.6]

var _clock: GameClock = GameClock.new()
var _poligon: Poligon
var _scene_path: String = ""
var _spawn: StringName = &""
var _projection: ProjectionConfig ## The config the projection variants change.
var _frames: Vector2i = Vector2i.ZERO ## Chosen frame index: x outside, y inside.
## Where the player stood before a projection change, read at the old scale (the reload reads it).
var _kept_spot: Vector2 = Vector2.INF
var _door_fade_s: float = 0.0
var _fade: ColorRect

@onready var _view: LitView = %LitView
@onready var _panel: DebugPanel = %DebugPanel


func _ready() -> void:
	_panel.hour_changed.connect(_on_hour_changed)
	_panel.rate_changed.connect(func(minutes_per_second: float) -> void:
		_clock.rate = minutes_per_second * 60.0)
	_panel.pixel_perfect_changed.connect(func(on: bool) -> void: _view.pixel_perfect = on)
	_panel.screenshot_requested.connect(_save_shot)
	_panel.cycle_requested.connect(func(action: StringName) -> void:
		var id: StringName = &"kat"
		if action == &"cycle_scale":
			id = &"pxm"
		elif action == &"cycle_frame":
			id = &"kadr_wn" if is_instance_valid(_poligon) and _poligon.interior else &"kadr"
		if DebugRegistry.cycle(id):
			_panel.refresh())
	var args: Dictionary[String, String] = _user_args()
	# `--set=kat=2,pxm=0`: variant indices (or 0/1 for toggles) before anything is built.
	var preset: String = args.get("set", "")
	for pair: String in preset.split(",", false):
		var parts: PackedStringArray = pair.split("=")
		if parts.size() == 2:
			DebugRegistry.remember(StringName(parts[0]), parts[1].to_int())
	_register_options()
	var scene: String = args.get("scene", START_SCENE)
	var spawn: String = args.get("spawn", "")
	load_poligon(scene, StringName(spawn))
	# `--at=x,z`: the player at this ground spot (metres, as player_spot()), e.g. in a sun patch for shots.
	var at_arg: String = args.get("at", "")
	var at: PackedFloat64Array = at_arg.split_floats(",")
	if at.size() == 2:
		_poligon.move_player(Vector2(at[0], at[1]))
	if args.has("shots"):
		_shoot_hours.call_deferred(args["shots"])
	if args.has("bench"):
		_bench.call_deferred(args["bench"])


func _process(delta: float) -> void:
	if _clock.advance(delta):
		_apply_time()


## Loads a Poligon scene and puts the player at `spawn`.
func load_poligon(path: String, spawn: StringName) -> void:
	var scene: PackedScene = load(path) as PackedScene
	_scene_path = path
	_spawn = spawn
	_poligon = scene.instantiate() as Poligon
	_projection.base_size = FRAMES[_frames.y if _poligon.interior else _frames.x]
	_view.apply_base_size()
	_view.set_world(_poligon)
	_poligon.door_used.connect(func(target: String, next_spawn: StringName) -> void:
		_through_door.call_deferred(target, next_spawn))
	_poligon.reload_requested.connect(reload_world, CONNECT_DEFERRED)
	_poligon.start(spawn)
	_apply_time()


## A door: fade out, load the next Poligon, fade in (none when the fade is off).
func _through_door(target: String, spawn: StringName) -> void:
	if _door_fade_s <= 0.0:
		load_poligon(target, spawn)
		return
	var out: Tween = create_tween()
	out.tween_property(_fade, "color:a", 1.0, _door_fade_s)
	await out.finished
	load_poligon(target, spawn)
	var back: Tween = create_tween()
	back.tween_property(_fade, "color:a", 0.0, _door_fade_s)


## Loads the current Poligon again, e.g. after ProjectionConfig.use() with another scale.
func reload_world() -> void:
	var spot: Vector2 = _kept_spot
	_kept_spot = Vector2.INF
	if not spot.is_finite() and is_instance_valid(_poligon):
		spot = _poligon.player_spot()
	load_poligon(_scene_path, _spawn)
	if spot.is_finite():
		_poligon.move_player(spot)


func _apply_time() -> void:
	if is_instance_valid(_poligon):
		_poligon.apply_time(_clock.hour)
	_panel.show_time(_clock.hour, _clock.label())


func _on_hour_changed(hour: float) -> void:
	_clock.set_hour(hour)
	_apply_time()


## Post-process switches shared by every Poligon.
func _register_options() -> void:
	var display: ShaderMaterial = _view.display_material()
	var grade: float = display.get_shader_parameter(&"grade")
	# Ticket 33: the grain as a slider (the critic: it blurs the shadow's soft edge on a still shot).
	var grain_levels: PackedFloat32Array = [0.0, 0.005, 0.01, 0.015, 0.02, 0.03]
	var grain_names: PackedStringArray = ["brak", "0,005", "0,01", "0,015 (game1)", "0,02", "0,03"]
	DebugRegistry.add_toggle(self, &"grade", "Grading nordic (game1)", true, func(on: bool) -> void:
		display.set_shader_parameter(&"grade", grade if on else 0.0))
	DebugRegistry.add_slider(self, &"ziarno", "Ziarno (natężenie)", grain_names, 3, func(index: int) -> void:
		display.set_shader_parameter(&"grain", grain_levels[index]))
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 50
	_fade = ColorRect.new()
	_fade.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade)
	add_child(layer)
	DebugRegistry.add_variant(self, &"drzwi_fade", "Drzwi: wygaszenie", DOOR_FADES, 1, func(chosen: int) -> void:
		_door_fade_s = DOOR_FADE_S[chosen])
	_projection = ProjectionConfig.current().duplicate() as ProjectionConfig
	ProjectionConfig.use(_projection)
	var frame_names: PackedStringArray = PackedStringArray()
	for frame: Vector2i in FRAMES:
		frame_names.append("%dx%d" % [frame.x, frame.y])
	# The human (ticket 31): style-lab starts at 800×450 (the projection keeps 960×540 as its base).
	var start_frame: int = FRAMES.find(START_FRAME)
	_projection_variant(&"kadr", "Kadr ulicy", frame_names, start_frame,
			func(index: int) -> void: _frames.x = index)
	_projection_variant(&"kadr_wn", "Kadr wnętrza", frame_names, start_frame,
			func(index: int) -> void: _frames.y = index)
	var depth_names: PackedStringArray = PackedStringArray()
	for depth: float in DEPTH_FACTORS:
		depth_names.append("%.2f" % depth)
	_projection_variant(&"kat", "Kąt (głębia : szerokość)", depth_names,
			DEPTH_FACTORS.find(_projection.depth_factor),
			func(index: int) -> void: _projection.depth_factor = DEPTH_FACTORS[index])
	var px_names: PackedStringArray = PackedStringArray()
	for px: float in PX_PER_M:
		px_names.append("%d" % roundi(px))
	_projection_variant(&"pxm", "px/m (postać 1,8 m)", px_names, PX_PER_M.find(_projection.px_per_m),
			func(index: int) -> void: _projection.px_per_m = PX_PER_M[index])


## A variant of the projection: `change` sets the field, then the Poligon is built again at that scale.
func _projection_variant(id: StringName, label: String, names: PackedStringArray, index: int,
		change: Callable) -> void:
	DebugRegistry.add_variant(self, id, label, names, maxi(index, 0), func(chosen: int) -> void:
		# The spot in metres must be read before the scale changes.
		if is_instance_valid(_poligon) and not _kept_spot.is_finite():
			_kept_spot = _poligon.player_spot()
		change.call(chosen)
		if is_instance_valid(_poligon):
			reload_world.call_deferred())


## Batch mode (`-- --shots=8,12.5,17,22 [--scene=res://...] [--spawn=name]`): stops the clock, saves a
## screenshot at each hour and quits. For comparison sheets made without a human at the keyboard.
func _shoot_hours(hours: String) -> void:
	_clock.rate = 0.0
	for hour: String in hours.split(",", false):
		_on_hour_changed(hour.to_float())
		for _frame: int in 4:
			await RenderingServer.frame_post_draw
		_save_shot()
	get_tree().quit()


## PROTOTYPE (ticket 33): `--bench=22`: frames per second at that hour without vsync (3 s after 1 s of
## warm-up), printed as BENCH, then quit.
func _bench(hour: String) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	_clock.rate = 0.0
	_on_hour_changed(hour.to_float())
	await get_tree().create_timer(1.0).timeout
	var start: int = Time.get_ticks_usec()
	var frames: int = Engine.get_frames_drawn()
	await get_tree().create_timer(3.0).timeout
	var seconds: float = (Time.get_ticks_usec() - start) / 1e6
	print("BENCH %s: %.0f fps" % [hour, (Engine.get_frames_drawn() - frames) / seconds])
	get_tree().quit()


## `--key=value` pairs after `--` on the command line.
static func _user_args() -> Dictionary[String, String]:
	var found: Dictionary[String, String] = {}
	for arg: String in OS.get_cmdline_user_args():
		var pair: PackedStringArray = arg.trim_prefix("--").split("=", true, 1)
		found[pair[0]] = pair[1] if pair.size() > 1 else ""
	return found


## The picture before scaling, as `<poligon>__<options>__<HHMM>.png` in style-lab/shots/.
func _save_shot() -> void:
	var folder: String = ProjectSettings.globalize_path(SHOTS_DIR)
	DirAccess.make_dir_recursive_absolute(folder)
	var options: String = DebugRegistry.describe()
	# Windows paths stop at 260 characters: a long option list keeps its start and a hash of the rest.
	if options.length() > 150:
		options = "%s_%08x" % [options.left(140), options.hash()]
	var file_name: String = "%s__%s__%s.png" % [_poligon.title, options, _clock.label("")]
	var path: String = folder.path_join(file_name.validate_filename())
	var error: Error = _view.capture().save_png(path)
	if error == OK:
		print("Zrzut: ", path)
	else:
		push_error("Zrzut nieudany (%s): %s" % [error_string(error), path])
