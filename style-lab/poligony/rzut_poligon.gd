class_name RzutPoligon
extends Poligon
## PROTOTYPE (ticket Rzut, skala i rozdzielczość): base of the two Rzut Poligons, built in code so
## the angle (ProjectionConfig.depth_factor), px/m and the frame can be switched. Layout is given on
## the ground: x across, z into the depth from a room's back edge, both in metres. Options that change
## the layout ask Main to build the scene again (reload_requested); the registry keeps their values.

const GRID_COLOR: Color = Color(0.0, 0.0, 0.0, 0.18)
const MANNEQUIN_GAP_M: float = 0.8
## Generated trial assets (tools/comfy_proba.mjs) from Blender guides (tools/blender/zestaw_testowy.py
## --df 0.6 --ppm 320 --canvas 1024): image, the guide's alpha as mask, scaled to px/m. Only right at
## angle 0.60.
const TRIALS: PackedStringArray = ["bryly", "comfy s1000", "comfy s1001"]
const TRIAL_FILES: PackedStringArray = ["", "res://proby/comfy_060/%s_s1000.png", "res://proby/comfy_060/%s_s1001.png"]
const TRIAL_MASK: String = "res://shots/zestaw_060/%s_szary.png"
const TRIAL_PPM: float = 320.0
## PROTOTYPE (ticket Przepis postaci): one front view per angle from Pixellab image-to-pixelart
## (tools/postac/), to choose the angle the characters are made in. The player is the sprite made for
## the angle nearest to the current one (F2), so switching the angle switches the character too.
const CHARACTER_ANGLES: PackedFloat32Array = [0.0, 0.36, 0.6, 0.7]
## Qwen-Image-Edit + LoRA Multiple Angles, local pixelisation (tools/postac/). %s = view (CHARACTER_VIEWS
## in Figure.View order); the side view faces left.
const CHARACTER_FILES: PackedStringArray = ["", "res://proby/postac_kat5/%s_036.png",
		"res://proby/postac_kurtka/%s_060.png", "res://proby/postac_kat5/%s_070.png"]
const CHARACTER_VIEWS: PackedStringArray = ["przod", "bok", "tyl"]
## Candidates for the chosen character at 0.60 (F1 „Postać 0,60”); the row shows all of them.
const CANDIDATES: PackedStringArray = ["A", "B", "C", "Cp"] ## Cp: C on the palette of its Pixellab walk (tools/postac/paleta_z_klatek.gd)
const CANDIDATE_FILES: String = "res://proby/postac_kurtka/%s_060_%s.png"
## Walk cycle from Pixellab (tools/postac/pixellab_anim.mjs) on candidate C's side view, F1 „Chód”:
## %s = mode, %d = frame (0 is the input sprite, the cycle is 1..WALK_FRAMES); angle 0.60 only
## (CHARACTER_ANGLES index WALK_ANGLE). Other candidates and views stay still.
const CHARACTER_WALK: String = "res://proby/pixellab_chod_C/%s_%d.png"
## Front and back walk (pixminimax loop from an auto-picked mid-stride frame, tools/postac/rozkrok.gd), used with pmC.
const CHARACTER_WALK_FRONT_BACK: String = "res://proby/pixellab_chod_C3/%s_%d.png"
const WALK_FRONT_BACK: PackedStringArray = ["dol", "", "gora"] ## per Figure.View: front, side (unused), back
const WALK_FRONT_BACK_LAST: int = 7
const WALK_MODES: PackedStringArray = ["D", "Dc", "pmC", "pmB", "pmA", "przemal", "szkielet07", "szablon", "pixminimax16", "pixminimax", "text-v3", "3dA", "3dB", "3dC"]
## D: animation input with parallel feet (proby/wejscie_anim/opcja1, straight legs), pixminimax chain
## 16 standing→standing → rozkrok.gd → 8-frame loop (proby/pixellab_chod_D/<view>_<frame>, frame 8 = frame 0).
## Standing: front from opcja2 (wider feet), side and back from opcja1. Views without a walk yet stay still.
const D_STAND: PackedStringArray = ["res://proby/wejscie_anim/opcja2/sprite_przod.png",
		"res://proby/wejscie_anim/opcja1/sprite_bok.png", "res://proby/wejscie_anim/opcja1/sprite_tyl.png"]
## Front standing sprite for D/Dc (F1 „Stanie przodem (D)”): wide feet (opcja2) or parallel (opcja1, = walk input).
const D_STAND_FRONT: PackedStringArray = ["res://proby/wejscie_anim/opcja2/sprite_przod.png",
		"res://proby/wejscie_anim/opcja1/sprite_przod.png"]
const D_STAND_FRONT_NAMES: PackedStringArray = ["szeroko", "równolegle"]
const D_WALK: String = "res://proby/pixellab_chod_D/%s_%d.png"
## Dc: D with the walk frames fixed by tools/postac/zamaluj_tors.gd (slits and stray colours in the torso): <view>c_<frame>.
## 3dA / 3dB / 3dC: rendered from 3D in all views (CHARACTER_3D): A = MPFB detective + CMU 82_09,
## B = Quaternius Walk_Formal_Loop, C = MPFB detective on the Mesh2Motion skeleton + M2M walk (head lifted 25°).
const CHARACTER_3D: String = "res://proby/postac3d/sprite/%s/%s_%s.png"
## pmC / pmB: pixminimax, loop from a mid-stride frame (pixminimax16_4) back to itself, 8 frames (C with enhance_prompt).
## pmA: pixminimax 16 frames standing→standing with a both-knees prompt (proby/pixellab_chod_C2).
## przemal: szablon scaled to 72 px and recoloured to the C palette (tools/postac/przemaluj.gd), frames 0..7.
## szkielet07: skeleton-v3 on our sprite, CMU mocap 07_01 skeletons (proby/szkielet_C), frames 0..7.
## szablon: Characters tab, template walking-8-frames on the imported character (a full cycle, frames 0..7).
## Frames that close into a loop (frame-difference matrix): pixminimax16 was generated with the input
## as last_frame (two steps, frame 16 = frame 0); the 8-frame ones are one step, trimmed 6→0 / 5→0.
const WALK_LAST: PackedInt32Array = [7, 7, 7, 7, 15, 7, 7, 7, 15, 6, 5, 9, 9, 9]
const WALK_FPS: PackedFloat32Array = [8.0, 8.0, 8.0, 8.0, 12.0, 10.0, 8.0, 10.0, 12.0, 8.0, 8.0, 7.5, 9.4, 7.7]
const WALK_CANDIDATE: int = 2
const WALK_ANGLE: int = 2
const READOUT_COLOR: Color = Color(1.0, 0.95, 0.75)

## The street the house (rzut_dom) leads back to: the last street Poligon built sets it.
static var street_scene: String = "res://poligony/rzut_ulica.tscn"

var _built: bool = false
var _values: Dictionary[StringName, int] = {}
var _grids: Array[ShapePainter] = []
var _readout: Label
## Back wall height above the ground origin (0 for a street): ground() of the whole map uses it.
var _ground_wall_m: float = 0.0


func _build() -> void:
	LightingDirector.top_azimuth_deg = 180.0 # game1 convention unless the Poligon turns it
	_add_layout_options()
	if _character_options():
		_layout_option(&"proby", "Rząd wzorców", TRIALS, 0)
		_layout_option(&"postac", "Postać 0,60", CANDIDATES, WALK_CANDIDATE)
		_layout_option(&"chod", "Chód", WALK_MODES, 0)
		_layout_option(&"stanie_przod", "Stanie przodem (D)", D_STAND_FRONT_NAMES, 0)
	_build_world()
	_build_overlay()
	DebugRegistry.add_toggle(self, &"siatka", "Siatka 1 m", false, func(on: bool) -> void:
		for grid: ShapePainter in _grids:
			grid.visible = on)
	DebugRegistry.add_toggle(self, &"odczyt", "Odczyt wymiarów", true, func(on: bool) -> void:
		_readout.visible = on)
	_built = true


## Override: false hides the character and trial-row variants (the defaults stay: walk D).
func _character_options() -> bool:
	return true


## Override: the layout variants (add them with _layout_option).
func _add_layout_options() -> void:
	pass


## Override: rooms, blocks, doors, spawns.
func _build_world() -> void:
	pass


## A variant whose change builds the scene again.
func _layout_option(id: StringName, label: String, choices: PackedStringArray, index: int) -> void:
	DebugRegistry.add_variant(self, id, label, choices, index, func(chosen: int) -> void:
		var changed: bool = _values.has(id) and _values[id] != chosen
		_values[id] = chosen
		if _built and changed:
			reload_requested.emit())


func _value(id: StringName) -> int:
	return _values[id] if _values.has(id) else 0


## A point on the ground of a room whose RoomBox has `wall_m` of back wall: x across, z from the back
## edge, in metres; local px of the room.
static func ground(x_m: float, z_m: float, wall_m: float = 0.0) -> Vector2:
	var config: ProjectionConfig = ProjectionConfig.current()
	return Vector2(config.px(x_m), config.px(wall_m) + config.depth_px(z_m))


## A room (or street) with its lighting, added to the world at `origin` (px).
func _room(origin: Vector2, box: RoomBox, profile: RoomLightingProfile) -> RoomLighting:
	var room: RoomLighting = RoomLighting.new()
	room.profile = profile
	room.position = origin
	room.box = box
	room.add_child(box)
	return room


## A box standing with its front bottom edge's middle at `foot` (px, in `parent`'s space).
func _block(parent: Node, foot: Vector2, size_m: Vector3, front: Color, top: Color,
		details: Array[Rect2] = [], solid: bool = true, lift_m: float = 0.0, slot: int = 0) -> Block:
	var block: Block = Block.new()
	block.at_m = foot / ProjectionConfig.current().px_per_m
	block.size_m = size_m
	block.front_color = front
	block.top_color = top
	block.details = details
	block.solid = solid
	block.lift_m = lift_m
	block.slot = slot
	parent.add_child(block)
	return block


## The comparison row: a 1 m cube, a counter 2 × 0.6 × 1 m and three standing figures (front, side,
## back), from `foot` (px) to the right.
func _comparison_row(parent: Node, foot: Vector2, slot: int = 0) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var trial: int = _value(&"proby")
	if trial > 0:
		var names: PackedStringArray = ["szescian", "lada", "manekin_przod", "manekin_bok", "manekin_tyl"]
		var at_m: PackedFloat32Array = [0.5, 2.5, 4.3, 4.3 + MANNEQUIN_GAP_M, 4.3 + 2.0 * MANNEQUIN_GAP_M]
		for index: int in names.size():
			var actor: bool = index >= 2
			var at: Vector2 = foot + Vector2(config.px(at_m[index]), -config.depth_px(0.3) if actor else 0.0)
			_trial_sprite(parent, at, TRIAL_FILES[trial] % names[index], TRIAL_MASK % names[index], slot, actor)
		return
	_block(parent, foot + Vector2(config.px(0.5), 0.0), Vector3(1.0, 1.0, 1.0),
			Color("8a7f70"), Color("b3a996"), [], true, 0.0, slot)
	_block(parent, foot + Vector2(config.px(2.5), 0.0), Vector3(2.0, 0.6, 1.0),
			Color("5e4a3a"), Color("8b6f55"), [], true, 0.0, slot)
	var views: Array[Figure.View] = [Figure.View.FRONT, Figure.View.SIDE, Figure.View.BACK]
	for index: int in views.size():
		var mannequin: Mannequin = Mannequin.new()
		mannequin.view = views[index]
		mannequin.slot = slot
		mannequin.position = foot + Vector2(config.px(4.3 + index * MANNEQUIN_GAP_M), -config.depth_px(0.3))
		parent.add_child(mannequin)
	# One group per candidate: front, side, back, then a gap.
	for candidate: int in CANDIDATES.size():
		for view: int in CHARACTER_VIEWS.size():
			var standing: CharacterSprite = CharacterSprite.new()
			standing.texture = _candidate_texture(candidate, view)
			standing.slot = slot
			var step: float = 3.5 + candidate * 3.5 + view
			standing.position = foot + Vector2(config.px(4.3 + step * MANNEQUIN_GAP_M), -config.depth_px(0.3))
			parent.add_child(standing)


## A generated image cut out with its guide's alpha and scaled to px/m (nearest), standing with the
## bottom middle of the guide's shape at `at`; lit like a block (or an actor).
func _trial_sprite(parent: Node, at: Vector2, path: String, mask_path: String, slot: int, actor: bool) -> void:
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	var mask: Image = Image.load_from_file(ProjectSettings.globalize_path(mask_path))
	if image == null or mask == null:
		push_warning("Brak próby: %s" % path)
		return
	image.convert(Image.FORMAT_RGBA8)
	mask.convert(Image.FORMAT_RGBA8)
	mask.resize(image.get_width(), image.get_height(), Image.INTERPOLATE_NEAREST)
	for y: int in image.get_height():
		for x: int in image.get_width():
			var color: Color = image.get_pixel(x, y)
			color.a = 1.0 if mask.get_pixel(x, y).a > 0.5 else 0.0
			image.set_pixel(x, y, color)
	var used: Rect2i = image.get_used_rect()
	var factor: float = ProjectionConfig.current().px_per_m / TRIAL_PPM
	var size: Vector2i = Vector2i(roundi(image.get_width() * factor), roundi(image.get_height() * factor))
	image.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.centered = false
	sprite.offset = -Vector2(roundf((used.position.x + used.size.x / 2.0) * factor), roundf(used.end.y * factor))
	sprite.position = at
	sprite.material = Lit.material()
	sprite.light_mask = LightMasks.of(slot, LightMasks.Receiver.ACTOR if actor else LightMasks.Receiver.SOLID)
	parent.add_child(sprite)


## Lines every metre on a floor (px rect), drawn as part of that floor.
func _grid(parent: Node, area: Rect2, slot: int) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var grid: ShapePainter = ShapePainter.new(LightMasks.of(slot, LightMasks.Receiver.FLOOR), RoomBox.WALL_Z + 2)
	var x: float = area.position.x
	while x <= area.end.x:
		grid.add_rect(Rect2(roundf(x), area.position.y, 1.0, area.size.y), GRID_COLOR)
		x += config.px(1.0)
	var y: float = area.position.y
	while y <= area.end.y:
		grid.add_rect(Rect2(area.position.x, roundf(y), area.size.x, 1.0), GRID_COLOR)
		y += config.depth_px(1.0)
	grid.visible = false
	parent.add_child(grid)
	_grids.append(grid)


## The measurements, drawn over the scene in base pixels (they land in shots).
func _build_overlay() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 1
	add_child(layer)
	var view: Vector2 = get_viewport().get_visible_rect().size
	var config: ProjectionConfig = ProjectionConfig.current()
	var height: int = roundi(config.px(config.actor_height_m))
	_readout = Label.new()
	_readout.position = Vector2(4, 2)
	_readout.add_theme_font_size_override(&"font_size", maxi(8, roundi(view.y / 40.0)))
	_readout.add_theme_color_override(&"font_color", READOUT_COLOR)
	_readout.add_theme_color_override(&"font_outline_color", Color.BLACK)
	_readout.add_theme_constant_override(&"outline_size", 2)
	_readout.text = "kąt %.2f · %d px/m · kadr %d×%d px = %.1f m szer.\npostać %d px (głowa %d px) · sześcian 1 m: front %d px, wierzch %d px" % [
		config.depth_factor, roundi(config.px_per_m), roundi(view.x), roundi(view.y),
		view.x / config.px_per_m, height, roundi(height / Figure.HEADS),
		roundi(config.px(1.0)), roundi(config.depth_px(1.0))] + _readout_extra()
	layer.add_child(_readout)


## Override: more lines for the readout (start with a newline).
func _readout_extra() -> String:
	return ""


## Metres of ground hidden behind something `height_m` tall (wall, facade): height / angle.
static func hidden_m(height_m: float) -> float:
	return height_m / ProjectionConfig.current().depth_factor


func start(spawn: StringName) -> void:
	super.start(spawn)
	var views: Array[Texture2D] = []
	for view: int in CHARACTER_VIEWS.size():
		if _player_angle() == WALK_ANGLE:
			views.append(_candidate_texture(_value(&"postac"), view))
		else:
			views.append(_character_texture(_player_angle(), view))
	player.views = views
	var walks: Array[Array] = [[], [], []]
	var mode_3d: int = _value(&"chod")
	if WALK_MODES[mode_3d].begins_with("3d"):
		_start_3d(WALK_MODES[mode_3d].substr(2), mode_3d)
		return
	if WALK_MODES[mode_3d] in ["D", "Dc"]:
		_start_d(mode_3d, "c" if WALK_MODES[mode_3d] == "Dc" else "")
		return
	if _player_angle() == WALK_ANGLE and _value(&"postac") in [WALK_CANDIDATE, WALK_CANDIDATE + 1]:
		var side: int = Figure.View.SIDE
		var mode: int = _value(&"chod")
		player.walk_fps = WALK_FPS[mode]
		for frame: int in range(0, WALK_LAST[mode] + 1):
			var texture: Texture2D = _load_texture(CHARACTER_WALK % [WALK_MODES[mode], frame])
			if texture == null:
				walks[side].clear()
				break
			walks[side].append(texture)
		if WALK_MODES[mode] == "pmC":
			for view: int in [Figure.View.FRONT, Figure.View.BACK]:
				for frame: int in range(0, WALK_FRONT_BACK_LAST + 1):
					var texture: Texture2D = _load_texture(CHARACTER_WALK_FRONT_BACK % [WALK_FRONT_BACK[view], frame])
					if texture == null:
						walks[view].clear()
						break
					walks[view].append(texture)
	player.walks = walks


## Character rendered from 3D (tools/blender/render_chod.py → tools/postac/zmniejsz.gd): standing sprite
## and walk cycle in all three views, any candidate and angle.
func _start_3d(variant: String, mode: int) -> void:
	var views: Array[Texture2D] = []
	var walks: Array[Array] = [[], [], []]
	for view: int in CHARACTER_VIEWS.size():
		views.append(_load_texture(CHARACTER_3D % [variant, CHARACTER_VIEWS[view], "stoi"]))
		for frame: int in range(0, WALK_LAST[mode] + 1):
			var texture: Texture2D = _load_texture(CHARACTER_3D % [variant, CHARACTER_VIEWS[view], str(frame)])
			if texture == null:
				walks[view].clear()
				break
			walks[view].append(texture)
	player.views = views
	player.walk_fps = WALK_FPS[mode]
	player.walks = walks


## Variant D (see D_STAND / D_WALK), any candidate and angle.
func _start_d(mode: int, suffix: String) -> void:
	var views: Array[Texture2D] = []
	var walks: Array[Array] = [[], [], []]
	for view: int in CHARACTER_VIEWS.size():
		var stand: String = D_STAND_FRONT[_value(&"stanie_przod")] if view == Figure.View.FRONT else D_STAND[view]
		views.append(_load_texture(stand))
		for frame: int in range(0, WALK_LAST[mode] + 1):
			var texture: Texture2D = _load_texture(D_WALK % [CHARACTER_VIEWS[view] + suffix, frame])
			if texture == null and suffix != "":
				texture = _load_texture(D_WALK % [CHARACTER_VIEWS[view], frame])
			if texture == null:
				walks[view].clear()
				break
			walks[view].append(texture)
	player.views = views
	player.walk_fps = WALK_FPS[mode]
	player.walks = walks


## The character made for the angle nearest to the current one.
func _player_angle() -> int:
	var depth: float = ProjectionConfig.current().depth_factor
	var best: int = 1
	for index: int in range(1, CHARACTER_ANGLES.size()):
		if absf(CHARACTER_ANGLES[index] - depth) < absf(CHARACTER_ANGLES[best] - depth):
			best = index
	return best


static func _character_texture(index: int, view: int) -> Texture2D:
	if CHARACTER_FILES[index].is_empty():
		return null
	return _load_texture(CHARACTER_FILES[index] % CHARACTER_VIEWS[view])


static func _candidate_texture(candidate: int, view: int) -> Texture2D:
	return _load_texture(CANDIDATE_FILES % [CHARACTER_VIEWS[view], CANDIDATES[candidate].to_lower()])


## A PNG loaded straight from disk (trial files are not imported); null when missing.
static func _load_texture(res_path: String) -> Texture2D:
	var path: String = ProjectSettings.globalize_path(res_path)
	if not FileAccess.file_exists(path):
		return null
	var image: Image = Image.load_from_file(path)
	return ImageTexture.create_from_image(image) if image != null else null


func player_spot() -> Vector2:
	if player == null:
		return Vector2.INF
	var config: ProjectionConfig = ProjectionConfig.current()
	return Vector2(player.position.x / config.px_per_m,
			(player.position.y - config.px(_ground_wall_m)) / config.depth_px(1.0))


func move_player(spot: Vector2) -> void:
	player.position = ground(spot.x, spot.y, _ground_wall_m)
	player.camera.reset_smoothing()


func _spawn(spawn_name: String, at: Vector2) -> void:
	var marker: Node2D = Node2D.new()
	marker.name = spawn_name
	marker.position = at
	spawns.add_child(marker)
