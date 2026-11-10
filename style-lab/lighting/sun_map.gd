class_name SunMap
extends Node2D
## PROTOTYPE (ticket 36, „Przebudowa światła wnętrza na jeden bufor z cieniami”): all the light inside
## the house from one function (light_fn.gdshaderinc: the sun through the sashes and the side windows'
## ribbons, the sky through every sash and the street door, the night through the windows, the rooms'
## lamps) tested against one set of occluders (boxes and the actor alike), into one buffer
## (light_map.gdshader in a SubViewport never cleared). The house is painted whole when something
## changes; every frame only a window round the actor (its shadows' reach, from the geometry), in the
## same texture. The actor's light: a strip right of the house, the same function on its body. The
## back windows' beams in the air (polygons of ticket 27) and the dust take the same visibility.
## The Poligon calls down: setup() once, apply() each game minute.

## The actor as an occluder: none, a cylinder, a box (the swap test).
enum ActorShadow { NONE, CYLINDER, BOX }
## Quality gate (F1 „Test”): the actor as a box; a box in its place (the actor casting nothing): both
## must cast the same; a box in front of the street door or a back window: nothing lit behind it.
enum Test { NONE, ACTOR_BOX, BOX_AT_ACTOR, BOX_AT_DOOR, BOX_AT_WINDOW }
## The back windows' beams: the polygons narrowing into the patch (ticket 27), or the volume.
enum TopBeams { POLYGON, VOLUME }

const MAP_SHADER: Shader = preload("res://lighting/light_map.gdshader")
const BEAM_SHADER: Shader = preload("res://lighting/sun_beam.gdshader")
const AIR_SHADER: Shader = preload("res://lighting/sun_air.gdshader")
const DUST_SHADER: Shader = preload("res://lighting/sun_dust.gdshader")
## A flat light this high reads the buffer in lit.gdshader (also above 5000: no N·L).
const LIGHT_MAP_HEIGHT: float = 7000.0
const STRIP: Vector2i = Vector2i(32, 96) ## The actor strip right of the house in the buffer (px).
const MAX_ROOMS: int = 4
const MAX_LAMPS: int = 16
const MAX_RIBBONS: int = 16
const ACTOR_RADIUS_M: float = 0.26 ## The actor's cylinder (the human's pick by a lamp, ticket 33).
const TEST_BOX_M: Vector3 = Vector3(1.2, 0.3, 2.1) ## In front of the door or a window.
const WINDOW_PAD_PX: float = 8.0 ## Round the actor's window: a doorway's floor blends its neighbours.
const SIDE_FACING_FULL: float = 0.6 ## Side ribbons start later than the back beams (lower sun).
const RIBBON_WIDEN: float = 0.25
const STREET_C: float = 0.75 ## The night light: metres in per metre of fall...
const NIGHT_SIDE_DEG: float = 15.0 ## ... a little off straight (the human: straight on looked flat).
const NIGHT_COOL_LUX: float = 10.0 ## Through the back windows: snow and sky (WindowLight.night_lux).
const SKY_REF: float = 0.25 ## The form factor that gets the room's full sky light (by a window).
const FACING_FULL: float = 0.35 ## Light through a wall the sun only grazes fades out.
const AIR_FADE_M: float = 6.0
const AIR_DENSITY: float = 0.08
const DUST_GAIN: float = 2.0
const DUST_AMOUNT_K: float = 3.0 ## More motes: they hang over the back wall too and only the lit ones show.
const LOOK_LEVELS: PackedInt32Array = [0, 3, 2] ## smooth, 3 levels dithered, 2 hard

## Decided (tickets 31, 33: the critic's C, the human's picks); the Poligon may set them.
static var enabled: bool = false
static var sun_scale: float = 0.25 ## Sun and sky (with the side windows' sky the frame matches game1, measured).
static var front_glow: float = 2.0 ## Sky through every sash, × this.
static var front_gamma: float = 0.7 ## < 1: the far floor gains, by the glass it stays.
static var sky_dir_k: float = 0.4 ## The sky brighter on the sun's side: × (1 + k·cos).
static var sky_other_k: float = 0.0 ## Sky through a doorway from another room's window.
static var door_k: float = 0.5 ## The street door, an opening, × a window's sky of its size.
static var side_ribbon_k: float = 0.2
static var side_reach: float = 1.0
static var side_width: float = 2.0
static var air_k: float = 1.0
static var room_lamp_k: float = 1.0
static var night_window_k: float = 1.0
static var actor_k: float = 1.6 ## The light on the body (four sides averaged) × this, as the floor beside it.
## Variants (F1).
static var shadow_look: int = 1 ## 0 smooth, 1 three levels dithered, 2 two levels hard.
static var sun_disc_deg: float = 2.4 ## The sun's disc (radius, degrees): its shadows' softness.
static var bulb_m: float = 0.1 ## A lamp's bulb across (m).
static var top_beams: TopBeams = TopBeams.POLYGON
static var actor_shadow: ActorShadow = ActorShadow.CYLINDER
static var test: Test = Test.NONE
static var debug_view: int = 0 ## light_map.gdshader: 0 the light, 1 sun, 2 sky, 3 night, 4 lamps, 5 shadow shares.
static var whole_every_frame: bool = false ## The bench's reference: no window, the whole house every frame.

var geometry: SunGeometry
var rooms: Array[RoomLighting] = []
var actor: Node2D
var profile: WindowLightProfile
var door_sash: int = -1 ## The street door as an opening in the bottom wall, or none.

var _rect: Rect2i ## The house in world px.
var _view: SubViewport
var _map: ShaderMaterial
var _whole: ColorRect
var _window: ColorRect
var _strip: ColorRect
var _light: PointLight2D
var _debug: Sprite2D
var _materials: Array[ShaderMaterial] = []
var _air: ColorRect
var _air_material: ShaderMaterial
var _dust_material: ShaderMaterial
var _dust_on: bool = false
var _back_beams: Array[BeamCanvas] = []
var _back_sashes: PackedInt32Array = PackedInt32Array()
var _side_sashes: PackedInt32Array = PackedInt32Array()
var _side_spans: Array[Vector4] = [] ## A pane column: u from, u to, z from, z to.
var _fixtures: Array[LightFixture] = []
var _tops: PackedFloat32Array = PackedFloat32Array()
var _dirty: bool = true
var _last_window: Rect2 = Rect2()
## The sources the actor's shadow reaches from (metres): far directions (away from the light) and points.
var _away: Array[Vector3] = []
var _points: Array[Vector3] = []
var _actor_middle: Vector2 = Vector2.ZERO


func setup(data: SunGeometry, lit_rooms: Array[RoomLighting], player: Node2D, windows: WindowLightProfile) -> void:
	profile = windows
	geometry = data
	rooms = lit_rooms
	actor = player
	var config: ProjectionConfig = ProjectionConfig.current()
	var low: Vector2 = Vector2(data.shell_min.x * config.px_per_m, data.floor_y - data.shell_max.z * config.px_per_m)
	var high: Vector2 = Vector2(data.shell_max.x * config.px_per_m,
			data.floor_y + data.shell_max.y * config.px_per_m * config.depth_factor)
	_rect = Rect2i(Vector2i(floori(low.x), floori(low.y)), Vector2i(ceili(high.x - low.x), ceili(high.y - low.y)))
	_build_buffer()
	_build_air()
	for room: RoomLighting in rooms:
		for fixture: LightFixture in room.fixtures():
			if fixture.def.map_source:
				_fixtures.append(fixture)
	_set_geometry()


func _build_buffer() -> void:
	_map = _material(MAP_SHADER)
	_view = SubViewport.new()
	_view.size = Vector2i(_rect.size.x + STRIP.x, maxi(_rect.size.y, STRIP.y))
	_view.disable_3d = true
	_view.use_hdr_2d = true
	_view.transparent_bg = false
	_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_view.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_whole = _rect_in(_view, Vector2.ZERO, Vector2(_rect.size))
	_window = _rect_in(_view, Vector2.ZERO, Vector2.ONE)
	_strip = _rect_in(_view, Vector2(_rect.size.x, 0.0), Vector2(STRIP))
	add_child(_view)
	_map.set_shader_parameter(&"origin_px", Vector2(_rect.position))
	_map.set_shader_parameter(&"house_w", float(_rect.size.x))
	_map.set_shader_parameter(&"strip_size", Vector2(STRIP))
	var mask: int = 0
	for slot: int in LightMasks.SLOTS:
		mask |= LightMasks.of(slot, LightMasks.Receiver.FLOOR | LightMasks.Receiver.SOLID | LightMasks.Receiver.ACTOR)
	_light = PointLight2D.new()
	var texture: ImageTexture = LightTextures.get_shape(LightTextures.Shape.FLAT)
	_light.texture = texture
	_light.transform = Transform2D(0.0, Vector2(_rect.size) / Vector2(texture.get_size()), 0.0,
			Vector2(_rect.position) + Vector2(_rect.size) / 2.0)
	_light.height = LIGHT_MAP_HEIGHT
	_light.range_item_cull_mask = mask
	_light.color = Color.WHITE
	_light.energy = 1.0
	add_child(_light)
	Lit.set_all(&"light_map", _view.get_texture())
	Lit.set_all(&"map_origin", Vector2(_rect.position))
	Lit.set_all(&"map_size", Vector2(_view.size))
	Lit.set_all(&"house_w", float(_rect.size.x))
	# The debug views: the buffer itself over the house, unlit.
	_debug = Sprite2D.new()
	_debug.texture = _view.get_texture()
	_debug.centered = false
	_debug.region_enabled = true
	_debug.region_rect = Rect2(Vector2.ZERO, Vector2(_rect.size))
	_debug.position = Vector2(_rect.position)
	_debug.z_index = 200
	var unlit: CanvasItemMaterial = CanvasItemMaterial.new()
	unlit.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	_debug.material = unlit
	add_child(_debug)


func _rect_in(view: SubViewport, at: Vector2, size: Vector2) -> ColorRect:
	var rect: ColorRect = ColorRect.new()
	rect.position = at
	rect.size = size
	rect.material = _map
	view.add_child(rect)
	return rect


func _build_air() -> void:
	_air_material = _material(AIR_SHADER)
	_air = ColorRect.new()
	_air.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_air.position = Vector2(_rect.position)
	_air.size = Vector2(_rect.size)
	_air.z_index = BeamCanvas.AIR_Z
	_air.material = _air_material
	add_child(_air)
	_air_material.set_shader_parameter(&"origin_px", Vector2(_rect.position))
	_air_material.set_shader_parameter(&"fade_m", AIR_FADE_M)
	_dust_material = _material(DUST_SHADER)
	_dust_material.set_shader_parameter(&"fade_m", AIR_FADE_M)
	_dust_material.set_shader_parameter(&"gain", DUST_GAIN)
	_dust_material.set_shader_parameter(&"high_m", geometry.shell_max.z - 0.1)
	for index: int in geometry.sashes.size():
		var wall: int = geometry.sash_walls[index]
		if wall == SunGeometry.Wall.BACK:
			var beam: BeamCanvas = BeamCanvas.new()
			beam.profile = profile
			beam.interior = _back_room_area(index)
			# Under furniture, partitions and stairs: they hide the beam (it crossed them, the human).
			beam.z_index = RoomBox.WALL_Z + 5
			var material: ShaderMaterial = _material(BEAM_SHADER)
			material.set_shader_parameter(&"beam_sash", index)
			beam.material = material
			add_child(beam)
			_back_beams.append(beam)
			_back_sashes.append(index)
		elif wall >= SunGeometry.Wall.LEFT and index != door_sash:
			_add_ribbon_column(index)


## One ribbon per column of panes: the upper pane of a column joins its lower one.
func _add_ribbon_column(index: int) -> void:
	var sash: Vector4 = geometry.sashes[index]
	for other: int in _side_sashes.size():
		var known: Vector4 = _side_spans[other]
		if geometry.sash_walls[_side_sashes[other]] == geometry.sash_walls[index] \
				and is_equal_approx(known.x, sash.x) and is_equal_approx(known.y, sash.y):
			_side_spans[other] = Vector4(known.x, known.y, minf(known.z, sash.z), maxf(known.w, sash.w))
			return
	_side_spans.append(sash)
	_side_sashes.append(index)


## A back sash's room: its back wall and floor (the beam's polygon is clipped to it).
func _back_room_area(index: int) -> Rect2:
	var middle: float = (geometry.sashes[index].x + geometry.sashes[index].y) / 2.0
	for room: RoomLighting in rooms:
		var area: Rect2 = room.global_floor_rect()
		var low: Vector2 = geometry.ground_m(area.position)
		var high: Vector2 = geometry.ground_m(area.end)
		if absf(low.y) < 0.05 and middle >= low.x and middle <= high.x:
			return area.grow_side(SIDE_TOP, geometry.shell_max.z * ProjectionConfig.current().px_per_m)
	return Rect2(_rect)


func _material(shader: Shader) -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	_materials.append(material)
	return material


func _set_all(param: StringName, value: Variant) -> void:
	for material: ShaderMaterial in _materials:
		material.set_shader_parameter(param, value)


## The hand-made sky pillows step aside for the buffer's sky.
static func replaces_sky() -> bool:
	return enabled


func apply(sun: SunSample) -> void:
	if geometry == null:
		return
	visible = enabled
	LightFixture.map_lamps = enabled
	LightFixture.map_actor = enabled
	var flat_peak: float = LightTextures.peak(LightTextures.Shape.FLAT)
	var rects: PackedVector4Array = PackedVector4Array()
	var suns: PackedVector3Array = PackedVector3Array()
	var nights: PackedVector3Array = PackedVector3Array()
	var skies: PackedVector3Array = PackedVector3Array()
	var sky_glow: Color = profile.sky_glow_color(sun)
	var outside: Color = sky_glow / maxf(sky_glow.r, maxf(sky_glow.g, sky_glow.b))
	var sun_max: float = 0.0
	var night_max: float = 0.0
	for room: RoomLighting in rooms.slice(0, MAX_ROOMS):
		var area: Rect2 = room.global_floor_rect()
		var low: Vector2 = geometry.ground_m(area.position)
		var high: Vector2 = geometry.ground_m(area.end)
		rects.append(Vector4(low.x, low.y, high.x, high.y))
		var sun_k: float = Exposure.energy(sun.sun_lux, room.exposure, flat_peak, sun.sun_knee) * sun_scale
		var night_k: float = Exposure.energy(NIGHT_COOL_LUX * sun.night, room.exposure, flat_peak) * night_window_k
		sun_max = maxf(sun_max, sun_k)
		night_max = maxf(night_max, night_k)
		suns.append(Vector3(sun.sun_color.r, sun.sun_color.g, sun.sun_color.b) * sun_k)
		nights.append(Vector3(outside.r, outside.g, outside.b) * night_k)
		var sky_k: float = Exposure.energy(profile.sky_glow_lux(sun), room.exposure, flat_peak)
		skies.append(Vector3(sky_glow.r, sky_glow.g, sky_glow.b) * sky_k * sun_scale / 0.5 * lerpf(1.0, night_window_k, sun.night))
	var toward: Vector3 = _toward_sun(sun)
	var sun_on: bool = enabled and toward.z > 0.0 and sun_max > WindowLight.MIN_LIGHT_ENERGY
	var night_on: bool = enabled and night_max > WindowLight.MIN_LIGHT_ENERGY
	var side: float = STREET_C * tan(deg_to_rad(NIGHT_SIDE_DEG))
	var night_dir: Vector3 = Vector3(side, -STREET_C, 1.0)
	_set_all(&"room_count", rects.size())
	_set_all(&"room_rect", rects)
	_set_all(&"room_sun", suns)
	_set_all(&"room_night", nights)
	_set_all(&"room_sky", skies)
	_set_all(&"sun_dir", toward)
	_set_all(&"sun_on", 1 if sun_on else 0)
	_set_all(&"night_dir", night_dir)
	_set_all(&"night_on", 1 if night_on else 0)
	_set_all(&"sun_soft", tan(deg_to_rad(sun_disc_deg)))
	_set_all(&"facing_full", FACING_FULL)
	_set_all(&"sky_ref", SKY_REF)
	_set_all(&"front_glow", front_glow)
	_set_all(&"front_gamma", front_gamma)
	_set_all(&"sky_other_k", sky_other_k)
	var flat: Vector2 = Vector2(toward.x, toward.y)
	_set_all(&"sky_sun", flat.normalized() * sky_dir_k * sun.day if flat.length() > 0.001 else Vector2.ZERO)
	_set_all(&"door_sash", door_sash)
	_set_all(&"door_k", door_k)
	_set_all(&"lamp_size", bulb_m)
	_set_all(&"shadow_levels", LOOK_LEVELS[shadow_look])
	_set_all(&"shadow_dither", 1 if shadow_look == 1 else 0)
	_map.set_shader_parameter(&"debug_view", debug_view)
	_map.set_shader_parameter(&"actor_k", actor_k)
	_set_lamps()
	_set_ribbons(sun_on)
	_paint_back_beams(sun, sun_on)
	_air.visible = sun_on and top_beams == TopBeams.VOLUME
	_air_material.set_shader_parameter(&"density", AIR_DENSITY * air_k)
	_set_dust(enabled)
	_dust_material.set_shader_parameter(&"dust_color", rooms[0].profile.dust_color if not rooms.is_empty() else Color.WHITE)
	_debug.visible = debug_view > 0
	_set_sources(toward, night_dir, sun_on, night_on)
	_dirty = true


## The rooms' lamps (FixtureDef.map_source) as the function's point sources, at their room's exposure.
func _set_lamps() -> void:
	var bulbs: PackedVector3Array = PackedVector3Array()
	var colors: PackedVector3Array = PackedVector3Array()
	var reaches: PackedFloat32Array = PackedFloat32Array()
	var ppm: float = ProjectionConfig.current().px_per_m
	for fixture: LightFixture in _fixtures:
		if not enabled or not is_instance_valid(fixture) or fixture.last_level <= 0.01 or bulbs.size() >= MAX_LAMPS:
			continue
		var foot: Vector2 = geometry.ground_m(fixture.global_position)
		bulbs.append(Vector3(foot.x, foot.y - fixture.def.source_back_m, fixture.def.source_height_m))
		var energy: float = Exposure.energy(fixture.def.lux * fixture.last_level, fixture.last_exposure, 1.0) * room_lamp_k
		colors.append(Vector3(fixture.def.color.r, fixture.def.color.g, fixture.def.color.b) * energy)
		reaches.append(fixture.reach_px() / ppm)
	var count: int = bulbs.size()
	bulbs.resize(MAX_LAMPS)
	colors.resize(MAX_LAMPS)
	reaches.resize(MAX_LAMPS)
	_map.set_shader_parameter(&"lamp_count", count)
	_map.set_shader_parameter(&"lamps", bulbs)
	_map.set_shader_parameter(&"lamp_color", colors)
	_map.set_shader_parameter(&"lamp_reach", reaches)
	_points.clear()
	for index: int in count:
		var half: float = bulb_m / 2.0
		for offset: Vector3 in [Vector3.ZERO, Vector3(half, 0, 0), Vector3(-half, 0, 0), Vector3(0, half, 0), Vector3(0, -half, 0), Vector3(0, 0, half), Vector3(0, 0, -half)]:
			_points.append(bulbs[index] + offset)


## The side windows' ribbons (game1-proto's look) as a floor term of the sun.
func _set_ribbons(sun_on: bool) -> void:
	var spans: PackedVector4Array = PackedVector4Array()
	var walls: PackedInt32Array = PackedInt32Array()
	var middles: PackedFloat32Array = PackedFloat32Array()
	for index: int in mini(_side_spans.size(), MAX_RIBBONS):
		spans.append(_side_spans[index])
		walls.append(geometry.sash_walls[_side_sashes[index]])
		middles.append(geometry.sash_middles[_side_sashes[index]])
	var count: int = spans.size() if sun_on and air_k > 0.0 else 0
	spans.resize(MAX_RIBBONS)
	walls.resize(MAX_RIBBONS)
	middles.resize(MAX_RIBBONS)
	_map.set_shader_parameter(&"ribbon_count", count)
	_map.set_shader_parameter(&"ribbons", spans)
	_map.set_shader_parameter(&"ribbon_wall", walls)
	_map.set_shader_parameter(&"ribbon_mid", middles)
	_map.set_shader_parameter(&"ribbon_reach", side_reach)
	_map.set_shader_parameter(&"ribbon_span", side_width / ProjectionConfig.current().depth_factor)
	_map.set_shader_parameter(&"ribbon_widen", RIBBON_WIDEN)
	_map.set_shader_parameter(&"ribbon_facing_full", SIDE_FACING_FULL)
	# As bright as the back windows' beams (room_sun already holds sun_k × sun_scale).
	_map.set_shader_parameter(&"ribbon_gain", profile.beam_energy * profile.beam_area_k(2.5) * profile.beam_gain * air_k / 0.5 * side_ribbon_k)


## Back windows: a beam per sash from the glass (height drawn up) exactly into where light through it
## lands, narrowing into the patch (ticket 27); its brightness inside from the visibility (sun_beam).
func _paint_back_beams(sun: SunSample, sun_on: bool) -> void:
	var ppm: float = ProjectionConfig.current().px_per_m
	var travel: Vector2 = SideWindowLight._travel(sun.sun_azimuth_deg, sun.sun_c)
	var sun_k: float = Exposure.energy(sun.sun_lux, _brightest_exposure(), LightTextures.peak(LightTextures.Shape.FLAT), sun.sun_knee)
	var facing: float = smoothstep(0.0, profile.top_facing_full, clampf(cos(deg_to_rad(sun.sun_azimuth_deg - 180.0)), 0.0, 1.0))
	for index: int in _back_beams.size():
		var sash: Vector4 = geometry.sashes[_back_sashes[index]]
		var top: float = geometry.floor_y - sash.w * ppm
		var bottom: float = geometry.floor_y - sash.z * ppm
		var near: PackedVector2Array = PackedVector2Array([Vector2(sash.x * ppm, top), Vector2(sash.y * ppm, top),
				Vector2(sash.y * ppm, bottom), Vector2(sash.x * ppm, bottom)])
		var fall: PackedFloat32Array = PackedFloat32Array([sash.w * ppm, sash.w * ppm, sash.z * ppm, sash.z * ppm])
		var energy: float = profile.beam_energy * sun_k * profile.beam_area_k(2.5) * facing * air_k * sun_scale / 0.5
		if not (sun_on and top_beams == TopBeams.POLYGON):
			energy = 0.0
		var away: Vector2 = Vector2((sash.x + sash.y) / 2.0 - geometry.sash_middles[_back_sashes[index]], 0.0) * ppm
		_back_beams[index].paint(near, fall, travel, energy, sun.sun_color, away, 1.0, 1.0, 1.0)


func _set_dust(on: bool) -> void:
	if on == _dust_on:
		return
	_dust_on = on
	var up: float = geometry.shell_max.z * ProjectionConfig.current().px_per_m
	for room: RoomLighting in rooms:
		room.set_dust_map(_dust_material if on else null, up, DUST_AMOUNT_K)


func _brightest_exposure() -> float:
	var best: float = 0.0
	for room: RoomLighting in rooms:
		best = maxf(best, room.exposure)
	return best if best > 0.0 else 1.0


## Where the actor's shadow can fall from: away from the far lights (their disc's rim too), from each
## lamp's bulb (its points) and from every sash's corners (the sky).
func _set_sources(toward: Vector3, night_dir: Vector3, sun_on: bool, night_on: bool) -> void:
	_away.clear()
	var soft: float = tan(deg_to_rad(sun_disc_deg))
	var lights: Array[Vector3] = []
	if sun_on:
		lights.append(toward)
	if night_on:
		lights.append(night_dir)
	for light: Vector3 in lights:
		var axis: Vector3 = light.normalized()
		var u: Vector3 = axis.cross(Vector3.BACK if absf(axis.z) < 0.99 else Vector3.RIGHT).normalized()
		var v: Vector3 = axis.cross(u)
		for j: Vector2 in [Vector2.ZERO, Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
			_away.append(-(axis + (u * j.x + v * j.y) * soft))
	for index: int in geometry.sashes.size():
		for corner: int in 4:
			_points.append(_sash_corner(index, corner))


func _sash_corner(index: int, corner: int) -> Vector3:
	var sash: Vector4 = geometry.sashes[index]
	var u: float = sash.y if corner == 1 or corner == 2 else sash.x
	var z: float = sash.w if corner >= 2 else sash.z
	match geometry.sash_walls[index]:
		SunGeometry.Wall.BACK:
			return Vector3(u, geometry.shell_min.y, z)
		SunGeometry.Wall.FRONT:
			return Vector3(u, geometry.shell_max.y, z)
		SunGeometry.Wall.LEFT:
			return Vector3(geometry.shell_min.x, u, z)
	return Vector3(geometry.shell_max.x, u, z)


func _process(_delta: float) -> void:
	if geometry == null or not enabled:
		return
	_set_boxes()
	if not is_instance_valid(actor):
		return
	var feet_px: Vector2 = actor.global_position.floor()
	_map.set_shader_parameter(&"actor_feet_px", feet_px)
	var corner: Vector2 = feet_px - Vector2(STRIP.x / 2.0, STRIP.y)
	Lit.actor_material().set_shader_parameter(&"actor_rect", Vector4(corner.x, corner.y, STRIP.x, STRIP.y))
	var window: Rect2 = _actor_window()
	var both: Rect2 = window.merge(_last_window) if _last_window.has_area() else window
	_last_window = window
	var whole: bool = _dirty or whole_every_frame
	_dirty = false
	_whole.visible = whole
	_window.visible = not whole and both.has_area()
	both = both.intersection(Rect2(Vector2.ZERO, Vector2(_rect.size)))
	_window.position = both.position
	_window.size = both.size


## Boxes with their shown tops (partitions cut down), the test boxes, and the actor.
func _set_boxes() -> void:
	var lows: PackedVector3Array = PackedVector3Array()
	var highs: PackedVector3Array = PackedVector3Array()
	var tops: PackedFloat32Array = geometry.shown_tops()
	if tops != _tops:
		_tops = tops.duplicate()
		_dirty = true
	tops = tops.duplicate()
	for box: AABB in geometry.boxes:
		lows.append(box.position)
		highs.append(box.end)
	var shape: int = int(actor_shadow) if is_instance_valid(actor) else 0
	var feet: Vector2 = geometry.ground_m(actor.global_position) if is_instance_valid(actor) else Vector2.ZERO
	var height: float = ProjectionConfig.current().actor_height_m
	_actor_middle = Vector2(feet.x, feet.y - ACTOR_RADIUS_M)
	var r: float = ACTOR_RADIUS_M
	match test:
		Test.ACTOR_BOX:
			shape = int(ActorShadow.BOX)
		Test.BOX_AT_ACTOR:
			shape = 0
			_test_box(lows, highs, tops, Vector3(_actor_middle.x - r, _actor_middle.y - r, 0.0), Vector3(_actor_middle.x + r, _actor_middle.y + r, height))
		Test.BOX_AT_DOOR:
			if door_sash >= 0:
				var sash: Vector4 = geometry.sashes[door_sash]
				var middle: float = (sash.x + sash.y) / 2.0
				var front: float = geometry.shell_max.y - 0.2
				_test_box(lows, highs, tops, Vector3(middle - TEST_BOX_M.x / 2.0, front - TEST_BOX_M.y, 0.0), Vector3(middle + TEST_BOX_M.x / 2.0, front, TEST_BOX_M.z))
		Test.BOX_AT_WINDOW:
			for index: int in geometry.sashes.size():
				if geometry.sash_walls[index] == SunGeometry.Wall.BACK:
					var middle: float = geometry.sash_middles[index]
					var back: float = geometry.shell_min.y + 0.3
					_test_box(lows, highs, tops, Vector3(middle - TEST_BOX_M.x / 2.0, back, 0.0), Vector3(middle + TEST_BOX_M.x / 2.0, back + TEST_BOX_M.y, TEST_BOX_M.z))
					break
	var count: int = lows.size()
	lows.resize(SunGeometry.MAX_BOXES + 1)
	highs.resize(SunGeometry.MAX_BOXES + 1)
	tops.resize(SunGeometry.MAX_BOXES + 1)
	_set_all(&"box_count", count)
	_set_all(&"box_min", lows)
	_set_all(&"box_max", highs)
	_set_all(&"box_top", tops)
	_set_all(&"actor_shape", shape)
	_set_all(&"actor_body", Vector4(_actor_middle.x, _actor_middle.y, r, height))


## An occluder only (not drawn, no receiver).
func _test_box(lows: PackedVector3Array, highs: PackedVector3Array, tops: PackedFloat32Array, low: Vector3, high: Vector3) -> void:
	lows.append(low)
	highs.append(high)
	tops.append(-1.0)


## The buffer px the actor's shadow can change: its cylinder's corners and where rays from every source
## through them leave the shell, projected (the screen is linear in metres: a shadow lies between them).
func _actor_window() -> Rect2:
	if actor_shadow == ActorShadow.NONE and test == Test.NONE:
		return Rect2()
	var r: float = ACTOR_RADIUS_M
	var h: float = ProjectionConfig.current().actor_height_m
	var corners: Array[Vector3] = []
	for x: float in [-r, r]:
		for y: float in [-r, r]:
			for z: float in [0.0, h]:
				corners.append(Vector3(_actor_middle.x + x, _actor_middle.y + y, z))
	var low: Vector2 = Vector2(INF, INF)
	var high: Vector2 = Vector2(-INF, -INF)
	for corner: Vector3 in corners:
		var at: Vector2 = _screen(corner)
		low = low.min(at)
		high = high.max(at)
		for away: Vector3 in _away:
			at = _screen(_shell_exit(corner, away))
			low = low.min(at)
			high = high.max(at)
		for point: Vector3 in _points:
			var away: Vector3 = corner - point
			if away.length_squared() < 1e-6:
				continue
			at = _screen(_shell_exit(corner, away))
			low = low.min(at)
			high = high.max(at)
	var pad: Vector2 = Vector2(WINDOW_PAD_PX, WINDOW_PAD_PX)
	return Rect2(low - pad, high - low + pad * 2.0)


## Buffer px of a point (x, d, z) in metres.
func _screen(point: Vector3) -> Vector2:
	var config: ProjectionConfig = ProjectionConfig.current()
	var world: Vector2 = Vector2(point.x * config.px_per_m,
			geometry.floor_y + config.px_per_m * (config.depth_factor * point.y - point.z))
	return world - Vector2(_rect.position)


## Where o + t·dir (t > 0) leaves the shell (o inside it).
func _shell_exit(o: Vector3, dir: Vector3) -> Vector3:
	var t: float = INF
	for axis: int in 3:
		if absf(dir[axis]) < 1e-6:
			continue
		var bound: float = geometry.shell_max[axis] if dir[axis] > 0.0 else geometry.shell_min[axis]
		t = minf(t, maxf((bound - o[axis]) / dir[axis], 0.0))
	return o + dir * (t if t < INF else 0.0)


## Towards the sun in (x, d, z): its light travels sun_c metres across the floor per metre of fall, in
## the screen direction the hand-tuned windows use (SideWindowLight._travel).
func _toward_sun(sun: SunSample) -> Vector3:
	var azimuth: float = deg_to_rad(sun.sun_azimuth_deg)
	return Vector3(-sin(azimuth) * sun.sun_c, cos(azimuth) * sun.sun_c, 1.0)


func _set_geometry() -> void:
	var walls: PackedInt32Array = geometry.sash_walls.duplicate()
	walls.resize(SunGeometry.MAX_SASHES)
	var config: ProjectionConfig = ProjectionConfig.current()
	_set_all(&"ppm", config.px_per_m)
	_set_all(&"kd", config.depth_factor)
	_set_all(&"floor_y", geometry.floor_y)
	_set_all(&"shell_min", geometry.shell_min)
	_set_all(&"shell_max", geometry.shell_max)
	_set_all(&"sash_count", geometry.sashes.size())
	_set_all(&"sashes", PackedVector4Array(geometry.sashes))
	_set_all(&"sash_wall", walls)
	_set_boxes()
