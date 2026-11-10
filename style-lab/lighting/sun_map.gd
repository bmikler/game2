class_name SunMap
extends Node2D
## PROTOTYPE (ticket 31, „Słońce okien liczone mapą światła”): the window sun computed from SunGeometry
## instead of hand-tuned beams and patches. Two light maps rendered per pixel in SubViewports over the
## house (the sun by day; a sodium street lamp by night, a point source in front of the bottom wall)
## light the floors, walls and boxes through PointLight2Ds, at each room's exposure; the beams in the
## air are a ray-marched overlay from the same data. The Poligon calls down: setup() once, apply()
## each game minute; the actor's box follows the player every frame.

## The actor's shadow (ticket 33): its shape as an occluder; flat ones turn to face each light (a sprite).
enum ActorShadow { NONE, CYLINDER, BOX, FLAT, FIGURE }
## Where the actor's shadow is computed: a small window round it every frame (the light it takes away,
## subtracted from the maps), or the whole house maps repainted every frame with the actor in them.
enum ShadowCompute { WINDOW, FULL }
## Which lights the actor shadows (bits).
const SHADOW_SUN: int = 1
const SHADOW_SKY: int = 2
const SHADOW_LAMPS: int = 4
const SHADOW_NIGHT: int = 8
const SHADOW_WIN: Vector2i = Vector2i(320, 320) ## The shadow window (px): 8 m across round the feet...
const SHADOW_ABOVE: int = 220 ## ... most of it above the feet: the floor behind and the back wall (2.2 m = 88 px).
## Night through the bottom windows: none; the street evenly (a far light straight in, every window
## the same); a street lamp in front of each window; one lamp in front of the middle of the house.
enum Night { NONE, STREET, EACH, CENTRE }
## Side windows' beams: ribbons from the wall's floor line as game1-proto (flat, read as from the
## wall: long, widening on the pane's side as SideWindowLight; or short, ending where they land), or
## the map's beams from the glass at its real height (steeper). All from the same data.
## RIBBON: the map's ribbon on the floor from the wall line (furniture and partitions shadow it).
enum SideBeams { RIBBON, WALL_LINE, WALL_LINE_SHORT, GEOMETRY }
## Back windows' beams: a polygon per sash from the glass narrowing exactly into its patch (as ticket
## 27 with the patch on), or the ray-marched volume (the prism: on screen wider than the patch).
enum TopBeams { POLYGON, VOLUME }
## Sky light through the windows: the old hand-made pillow under each window, from the geometry (the
## share of sky each point sees through glass), or none.
enum SkyLight { PILLOW, GEOMETRY, NONE }
## How the map lights the actor: not at all (the old pillows' ActorLight twins), the floor's light at
## its feet on the whole body, or the body: the sun at each body point, the sky round it, the floor bounce.
enum ActorMap { TWINS, FEET, BODY }

const MAP_SHADER: Shader = preload("res://lighting/sun_map.gdshader")
const AIR_SHADER: Shader = preload("res://lighting/sun_air.gdshader")
const DUST_SHADER: Shader = preload("res://lighting/sun_dust.gdshader")
const RIBBON_SHADER: Shader = preload("res://lighting/sun_ribbon.gdshader")
const RIBBON_WIDEN: float = 0.25 ## Extra width per metre of travel, × a column's width (0.5 fanned out: the edges looked broken).
const MAX_RIBBONS: int = 16
const DUST_GAIN: float = 2.0 ## The motes in the beam, × the sun there.
const DUST_AMOUNT_K: float = 3.0 ## More motes: they hang over the back wall too and only the lit ones show.
const ACTOR_SIZE_M: Vector2 = Vector2(0.45, 0.3) ## The actor's box: width, depth (height: ProjectionConfig).
const ACTOR_RADIUS_M: float = 0.22
const FLAT_HALF_M: float = 0.2 ## The flat rectangle's half width (the figure's outline: in the shader).
## The actor's strip right of the house in the light maps (px): wider and taller than the figure.
const ACTOR_STRIP: Vector2i = Vector2i(32, 96)
const ACTOR_SUN_K: float = 0.7 ## The sun on the body, × this (part of a round body faces away).
const ACTOR_BOUNCE: float = 0.3 ## The floor's light bounced up the body, × this.
const MAX_ROOMS: int = 4
const LAMP_COLOR: Color = SideWindowLight.SODIUM
const LAMP_OUT_M: float = 3.0 ## The street lamp in front of the bottom wall...
const LAMP_UP_M: float = 4.0 ## ... this high.
const LAMP_LUX: float = 30.0 ## As SideWindowLight.street_lux.
const STREET_C: float = 0.75 ## The even night light: metres in per metre of fall (the human: too long).
const NIGHT_SIDE_DEG: float = 15.0 ## ... a little off straight (the human: straight on looked flat).
const NIGHT_COOL_LUX: float = 10.0 ## Through the back windows: snow and sky (WindowLight.night_lux).
## Softness: the sun's disc × this (the night lamps stand ~3 m out: both blur alike, the human).
const SOFT_SCALE: float = 3.0
const SIDE_FACING_FULL: float = 0.6 ## Side ribbons start later than the back beams (lower sun).
## Side ribbons: the far end this many times as wide (the window lies along the depth, shortened ×0.6
## on screen; the human: narrower than the back windows, should widen).
const SIDE_WIDEN: float = 2.4
const SIDE_BEAM_K: float = 1.8 ## One ribbon per column of panes; as bright as the back beams (the human).
const SIDE_LONG_K: float = 1.0 / SIDE_BEAM_K ## Long ribbons: game1-proto's brightness (SideWindowLight.SIDE_BEAM_K 1).
const SIDE_AIR_K: float = 2.5 ## Side windows' beams from the geometry, × this (thin seen edge-on: too faint).
const SIDE_REACH: float = 1.0 ## Ends where its light lands and fades on the way (the human: across the room looked weak).
const SKY_COUNT: int = 1 ## On (the sky is a formula, not samples).
const SKY_REF: float = 0.25 ## The form factor that gets the room's full sky light (by a window).
const FACING_FULL: float = 0.35 ## Light through a wall the sun only grazes fades out (as top_facing_full).
const AIR_FADE_M: float = 6.0 ## Long enough that a beam reaches its patch (the human).
const AIR_DENSITY: float = 0.08

## Flat lights at these heights read the light maps in lit.gdshader (also above 5000: no N·L).
const SUN_MAP_HEIGHT: float = 7000.0
const LAMP_MAP_HEIGHT: float = 7500.0
const ROOM_LAMP_MAP_HEIGHT: float = 7700.0
const MAX_ROOM_LAMPS: int = 16
const LAMP_SIZE_M: float = 0.1 ## A bulb this wide: the furniture's shadows a little soft.
const LAMP_SOFT: int = 6

## Variants (F1 on the Poligon).
static var enabled: bool = false ## Off: the hand-tuned WindowLight / SideWindowLight shapes.
static var actor_shadow: ActorShadow = ActorShadow.CYLINDER
static var shadow_compute: ShadowCompute = ShadowCompute.WINDOW
static var shadow_sources: int = SHADOW_SUN | SHADOW_LAMPS | SHADOW_NIGHT ## No sky: a smudge behind the actor (the human).
static var shadow_radius: float = 0.26 ## The cylinder's radius for the actor's shadow (m; the human's pick by a lamp).
static var shadow_sun_point: float = 4.0 ## The window's light as a point this far for the actor's shadow (0: parallel).
static var shadow_lamp_length: float = 1.0 ## Lamps' shadows this many times longer, not wider.
static var shadow_angle: float = 0.03 ## Every source's radius for the actor's shadow, tan (between the window's and the lamp's, the human).
static var shadow_stretch: float = 1.5 ## Lamps count this many times farther from the feet: their shadow widens slower and ends.
static var shadow_gradient: float = 0.0 ## 0 even, 1 darker by the feet and fading away (shader).
## The sky's shadow, its own settings (sun_map.gdshader: sky_shadow_*).
static var sky_shadow_k: float = 0.6
static var sky_shadow_soft: float = 0.05
static var sky_shadow_gradient: float = 0.5
static var sky_shadow_reach: float = 3.0
static var sky_shadow_contact: float = 0.5
static var shadow_look: int = 0 ## 0 smooth, 1 three levels dithered, 2 two levels hard (per source, in the maps).
## Ticket 35: furniture shadows from lamps longer too (shadow_lamp_length), or that only for the actor.
static var object_length: bool = true
static var shadow_gradient_soft: bool = true ## The gradient by softness, not strength (window bars showed through).
static var shadow_k: float = 0.75 ## The light it takes, × this.
static var soft_deg: float = 0.8 ## Decided (the human, 2026-11-09).
static var night_wall: int = 1 ## Night patch: 0 bottom windows (street), 1 back windows (decided: only these, in the colour outside), 2 none.
static var sky_other_k: float = 0.0 ## Sky through a doorway from another room's window, × this.
static var air_on: bool = true
static var air_k: float = 1.0
static var night: Night = Night.STREET
static var sun_scale: float = 0.25 ## Sun and sky from the map (×0.25: with the side windows' sky the frame matches game1, measured).
static var sky: SkyLight = SkyLight.GEOMETRY
static var side_beams: SideBeams = SideBeams.RIBBON ## The human: new beams from the map, flat and wide (not the steep volume).
static var top_beams: TopBeams = TopBeams.POLYGON
## Side ribbons along the wall, × px_per_m (0.6: shortened as depth; the human: as the top windows).
static var side_ribbon_k: float = 0.2 ## Measured: at ×0.75 a ribbon added ~33 by the wall, a back beam ~8 (the human: as the back beams).
static var side_reach: float = 1.0 ## The map's ribbons: as far as light through the head lands, × this.
static var side_width: float = 2.0
static var front_gamma: float = 0.7 ## The bottom windows' glow into the room (< 1 deeper; the human: a little deeper).
static var door_k: float = 0.5 ## The street door's glow from the map, × a window's of the same size.
static var sky_dir_k: float = 0.4 ## Sky light through a wall × (1 + k·cos(sun off its normal)): the sun's side brighter.
static var side_sky: bool = true ## Sky through the side windows by day too, as the bottom ones (the human).
static var front_glow: float = 2.0 ## Sky from the bottom wall's windows, × this: shows they are there.
static var side_patch: bool = false ## Side windows never light a patch on the floor (decided, tickets 27 and 31): only beams.
static var furniture_shadows: bool = true
static var actor_map: ActorMap = ActorMap.BODY
static var actor_gain: float = 1.0
## The rooms' lamps from the map (point sources: furniture shadows, stopped by walls) or by hand.
static var room_lamps: bool = true
static var room_lamp_k: float = 1.0
static var actor_sky_k: float = 0.5 ## The sky through the glass on the actor, × this (×1: a pale face by a bottom window).
## The cold light through the windows by night (snow, street lamps): the night patch and the sky's glow
## × this, by night only (the critic: the windows lit nothing by night, no cold against the warm lamps).
static var night_window_k: float = 1.0
static var actor_lamp_k: float = 0.7 ## The rooms' lamps on the actor (from the map), × this.

var geometry: SunGeometry
var rooms: Array[RoomLighting] = []
var actor: Node2D
var profile: WindowLightProfile ## The windows' sky light (sky_glow_lux, sky_glow_color).

var _rect: Rect2i
var _sun_view: SubViewport
var _lamp_view: SubViewport
var _sun_material: ShaderMaterial
var _lamp_material: ShaderMaterial
var _room_lamp_view: SubViewport
var _room_lamp_material: ShaderMaterial
var _room_lamp_light: PointLight2D
var _fixtures: Array[LightFixture] = [] ## The map's point sources (def.map_source).
var _shown_tops: PackedFloat32Array = PackedFloat32Array() ## Repaint the lamps when the shown walls change.
var _air_material: ShaderMaterial
var _sun_light: PointLight2D
var _lamp_light: PointLight2D
var _air: ColorRect
var _dust_material: ShaderMaterial
var _ribbon_material: ShaderMaterial
var _ribbon: ColorRect
var _dust_on: bool = false
var _materials: Array[ShaderMaterial] = []
var _side_beams: Array[BeamCanvas] = [] ## One per side-window sash.
var _side_sashes: PackedInt32Array = PackedInt32Array()
var _side_spans: Array[Vector4] = [] ## A side ribbon's column: u from, u to, z from, z to.
var _back_beams: Array[BeamCanvas] = [] ## One per back-window sash (TopBeams.POLYGON).
var _back_sashes: PackedInt32Array = PackedInt32Array()
var _sun: SunSample
var _map_size: Vector2i ## The house's light maps (painted when something changes).
var _sun_actor_view: SubViewport ## The actor strip of the sun map (painted every frame).
var _lamp_actor_view: SubViewport
var _shadow_views: Array[SubViewport] = [] ## The shadow window per map: sun, night, rooms' lamps.
var _room_lamp_up: bool = false
var _shadow_origin: Vector2 = Vector2.ZERO
var _sun_up: bool = false
var _lamp_up: bool = false
var _actor_mask: int = 0 ## Every room's actor bit.
var door_sash: int = -1 ## The street door as an opening in the bottom wall (its glow from the map), or none.


func setup(data: SunGeometry, lit_rooms: Array[RoomLighting], player: Node2D, windows: WindowLightProfile) -> void:
	profile = windows
	geometry = data
	rooms = lit_rooms
	actor = player
	var config: ProjectionConfig = ProjectionConfig.current()
	var low: Vector2 = Vector2(data.shell_min.x * config.px_per_m,
			data.floor_y - data.shell_max.z * config.px_per_m)
	var high: Vector2 = Vector2(data.shell_max.x * config.px_per_m,
			data.floor_y + data.shell_max.y * config.px_per_m * config.depth_factor)
	_rect = Rect2i(Vector2i(floori(low.x), floori(low.y)), Vector2i(ceili(high.x - low.x), ceili(high.y - low.y)))
	_map_size = _rect.size
	var mask: int = 0
	for slot: int in LightMasks.SLOTS:
		mask |= LightMasks.of(slot, LightMasks.Receiver.FLOOR | LightMasks.Receiver.SOLID)
		_actor_mask |= LightMasks.of(slot, LightMasks.Receiver.ACTOR)
	_sun_material = _map_material()
	_lamp_material = _map_material()
	_sun_view = _viewport(_sun_material)
	_lamp_view = _viewport(_lamp_material)
	_sun_actor_view = _viewport(_sun_material, true)
	_lamp_actor_view = _viewport(_lamp_material, true)
	_room_lamp_material = _map_material()
	_room_lamp_material.set_shader_parameter(&"point_source", 3)
	_room_lamp_material.set_shader_parameter(&"lamp_size", LAMP_SIZE_M)
	_room_lamp_material.set_shader_parameter(&"lamp_soft", LAMP_SOFT)
	_room_lamp_view = _viewport(_room_lamp_material)
	_room_lamp_view.render_target_update_mode = SubViewport.UPDATE_ONCE
	var shadow_params: Array[StringName] = [&"shadow_sun_map", &"shadow_lamp_map", &"shadow_room_map"]
	var maps: Array[ShaderMaterial] = [_sun_material, _lamp_material, _room_lamp_material]
	for index: int in maps.size():
		var view: SubViewport = _viewport(maps[index], false, true)
		_shadow_views.append(view)
		Lit.set_all(shadow_params[index], view.get_texture())
		maps[index].set_shader_parameter(&"shadow_size", Vector2(SHADOW_WIN))
	for room: RoomLighting in rooms:
		for fixture: LightFixture in room.fixtures():
			if fixture.def.map_source:
				_fixtures.append(fixture)
	_sun_light = _light(SUN_MAP_HEIGHT, mask)
	_lamp_light = _light(LAMP_MAP_HEIGHT, mask)
	_room_lamp_light = _light(ROOM_LAMP_MAP_HEIGHT, mask)
	Lit.set_all(&"sun_map", _sun_view.get_texture())
	Lit.set_all(&"lamp_map", _lamp_view.get_texture())
	Lit.set_all(&"room_lamp_map", _room_lamp_view.get_texture())
	Lit.set_all(&"actor_sun_map", _sun_actor_view.get_texture())
	Lit.set_all(&"actor_lamp_map", _lamp_actor_view.get_texture())
	Lit.set_all(&"map_rect", Vector4(_rect.position.x, _rect.position.y, _rect.size.x, _rect.size.y))
	Lit.set_all(&"map_size", Vector2(_map_size))
	for material: ShaderMaterial in [_sun_material, _lamp_material, _room_lamp_material]:
		material.set_shader_parameter(&"house_w", float(_rect.size.x))
		material.set_shader_parameter(&"actor_strip", Vector2(ACTOR_STRIP))
		material.set_shader_parameter(&"actor_radius", ACTOR_RADIUS_M)
		material.set_shader_parameter(&"actor_sun_k", ACTOR_SUN_K)
		material.set_shader_parameter(&"actor_bounce", ACTOR_BOUNCE)
	_air_material = ShaderMaterial.new()
	_air_material.shader = AIR_SHADER
	_materials.append(_air_material)
	_air = ColorRect.new()
	_air.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_air.position = Vector2(_rect.position)
	_air.size = Vector2(_rect.size)
	_air.z_index = BeamCanvas.AIR_Z
	_air.material = _air_material
	add_child(_air)
	_air_material.set_shader_parameter(&"origin_px", Vector2(_rect.position))
	_air_material.set_shader_parameter(&"fade_m", AIR_FADE_M)
	_ribbon_material = ShaderMaterial.new()
	_ribbon_material.shader = RIBBON_SHADER
	_materials.append(_ribbon_material)
	_ribbon = ColorRect.new()
	_ribbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ribbon.position = Vector2(_rect.position)
	_ribbon.size = Vector2(_rect.size)
	# On the floor: under furniture, partitions and actors, as the old side ribbons.
	_ribbon.z_index = RoomBox.WALL_Z + 5
	_ribbon.material = _ribbon_material
	add_child(_ribbon)
	_ribbon_material.set_shader_parameter(&"origin_px", Vector2(_rect.position))
	_ribbon_material.set_shader_parameter(&"widen", RIBBON_WIDEN)
	_ribbon_material.set_shader_parameter(&"side_facing_full", SIDE_FACING_FULL)
	_dust_material = ShaderMaterial.new()
	_dust_material.shader = DUST_SHADER
	_materials.append(_dust_material)
	_dust_material.set_shader_parameter(&"fade_m", AIR_FADE_M)
	_dust_material.set_shader_parameter(&"gain", DUST_GAIN)
	_dust_material.set_shader_parameter(&"high_m", data.shell_max.z - 0.1)
	_set_geometry()
	for index: int in data.sashes.size():
		if data.sash_walls[index] == SunGeometry.Wall.BACK:
			var back: BeamCanvas = BeamCanvas.new()
			back.profile = profile
			back.interior = _sash_room_floor(data, index)
			# Under furniture, partitions and stairs: they hide the beam (it crossed them, the human).
			back.z_index = RoomBox.WALL_Z + 5
			add_child(back)
			_back_beams.append(back)
			_back_sashes.append(index)
			continue
		if data.sash_walls[index] < SunGeometry.Wall.LEFT:
			continue
		# One ribbon per column of panes: the upper pane of a column joins its lower one.
		var merged: bool = false
		for other: int in _side_sashes.size():
			var known: Vector4 = _side_spans[other]
			var sash: Vector4 = data.sashes[index]
			if data.sash_walls[_side_sashes[other]] == data.sash_walls[index] and is_equal_approx(known.x, sash.x) and is_equal_approx(known.y, sash.y):
				_side_spans[other] = Vector4(known.x, known.y, minf(known.z, sash.z), maxf(known.w, sash.w))
				merged = true
		if merged:
			continue
		_side_spans.append(data.sashes[index])
		var beam: BeamCanvas = BeamCanvas.new()
		beam.profile = profile
		beam.interior = _sash_room_floor(data, index)
		# On the floor: under furniture, partitions and actors (they hide it), over the floor.
		beam.z_index = RoomBox.WALL_Z + 5
		add_child(beam)
		_side_beams.append(beam)
		_side_sashes.append(index)


## The hand-made sky pillows step aside for the map's sky (or none).
static func replaces_sky() -> bool:
	return enabled and sky != SkyLight.PILLOW


func apply(sun: SunSample) -> void:
	_sun = sun
	if geometry == null:
		return
	visible = enabled
	var on: bool = enabled
	var flat_peak: float = LightTextures.peak(LightTextures.Shape.FLAT)
	var rects: PackedVector4Array = PackedVector4Array()
	var sun_colors: PackedVector3Array = PackedVector3Array()
	var lamp_colors: PackedVector3Array = PackedVector3Array()
	var sky_colors: PackedVector3Array = PackedVector3Array()
	var sky_glow: Color = profile.sky_glow_color(sun)
	var sun_max: float = 0.0
	var lamp_max: float = 0.0
	for room: RoomLighting in rooms.slice(0, MAX_ROOMS):
		var area: Rect2 = room.global_floor_rect()
		var low: Vector2 = geometry.ground_m(area.position)
		var high: Vector2 = geometry.ground_m(area.end)
		rects.append(Vector4(low.x, low.y, high.x, high.y))
		var sun_k: float = Exposure.energy(sun.sun_lux, room.exposure, flat_peak, sun.sun_knee)
		var night_lux: float = NIGHT_COOL_LUX if night_wall == 1 else LAMP_LUX
		var lamp_k: float = Exposure.energy(night_lux * sun.night, room.exposure, flat_peak) if night != Night.NONE and night_wall < 2 else 0.0
		sun_max = maxf(sun_max, sun_k)
		lamp_max = maxf(lamp_max, lamp_k)
		sun_colors.append(Vector3(sun.sun_color.r, sun.sun_color.g, sun.sun_color.b) * sun_k * sun_scale)
		var night_color: Color = _outside_color(sun) if night_wall == 1 else LAMP_COLOR
		lamp_colors.append(Vector3(night_color.r, night_color.g, night_color.b) * lamp_k * night_window_k)
		var sky_k: float = Exposure.energy(profile.sky_glow_lux(sun), room.exposure, flat_peak)
		sky_colors.append(Vector3(sky_glow.r, sky_glow.g, sky_glow.b) * sky_k * sun_scale / 0.5 * lerpf(1.0, night_window_k, sun.night))
	for material: ShaderMaterial in _materials:
		material.set_shader_parameter(&"room_count", rects.size())
		material.set_shader_parameter(&"room_rect", rects)
	_sun_material.set_shader_parameter(&"room_light", sun_colors)
	_air_material.set_shader_parameter(&"room_light", sun_colors)
	_ribbon_material.set_shader_parameter(&"room_light", sun_colors)
	_lamp_material.set_shader_parameter(&"room_light", lamp_colors)
	_sun_material.set_shader_parameter(&"room_sky", sky_colors)
	_sun_material.set_shader_parameter(&"sky_count", SKY_COUNT if sky == SkyLight.GEOMETRY else 0)
	_sun_material.set_shader_parameter(&"sky_ref", SKY_REF)
	_sun_material.set_shader_parameter(&"front_glow", front_glow)
	_sun_material.set_shader_parameter(&"sky_other_k", sky_other_k)
	_sun_material.set_shader_parameter(&"front_gamma", front_gamma)
	_sun_material.set_shader_parameter(&"sky_side", 1 if side_sky else 0)
	var to_sun: Vector3 = _toward_sun(sun)
	var flat: Vector2 = Vector2(to_sun.x, to_sun.y)
	_sun_material.set_shader_parameter(&"sky_sun", flat.normalized() * sky_dir_k * sun.day if flat.length() > 0.001 else Vector2.ZERO)
	_sun_material.set_shader_parameter(&"door_sash", door_sash)
	_sun_material.set_shader_parameter(&"door_k", door_k)

	var toward: Vector3 = _toward_sun(sun)
	_sun_material.set_shader_parameter(&"source", toward)
	_air_material.set_shader_parameter(&"source", toward)
	_dust_material.set_shader_parameter(&"source", toward)
	_dust_material.set_shader_parameter(&"room_light", sun_colors)
	_dust_material.set_shader_parameter(&"facing_full", FACING_FULL)
	_set_dust(on and air_on)
	var soft: int = 12 if soft_deg > 0.0 else 1
	_sun_material.set_shader_parameter(&"soft_count", soft)
	_sun_material.set_shader_parameter(&"soft_radius", tan(deg_to_rad(soft_deg)) * SOFT_SCALE)
	_sun_material.set_shader_parameter(&"facing_full", FACING_FULL)
	_air_material.set_shader_parameter(&"side_walls", 1 if side_beams == SideBeams.GEOMETRY else 0)
	_air_material.set_shader_parameter(&"side_k", SIDE_AIR_K)
	_paint_side_beams(sun)
	_set_ribbons(sun, toward)
	_paint_back_beams(sun)
	_air_material.set_shader_parameter(&"front_back", 1 if top_beams == TopBeams.VOLUME else 0)
	_air_material.set_shader_parameter(&"facing_full", FACING_FULL)
	_sun_material.set_shader_parameter(&"side_walls", 1 if side_patch else 0)
	_set_night()
	_lamp_material.set_shader_parameter(&"soft_count", soft)
	_lamp_material.set_shader_parameter(&"soft_radius", tan(deg_to_rad(soft_deg)) * SOFT_SCALE)
	_lamp_material.set_shader_parameter(&"side_walls", 0)
	_air_material.set_shader_parameter(&"density", AIR_DENSITY * air_k)

	for material: ShaderMaterial in [_sun_material, _lamp_material]:
		material.set_shader_parameter(&"actor_mode", int(actor_map))
		material.set_shader_parameter(&"actor_gain", actor_gain)
	var actor_bits: int = _actor_mask if actor_map != ActorMap.TWINS else 0
	_sun_light.range_item_cull_mask = (_sun_light.range_item_cull_mask & ~_actor_mask) | actor_bits
	_lamp_light.range_item_cull_mask = (_lamp_light.range_item_cull_mask & ~_actor_mask) | actor_bits
	_set_actor()

	_set_room_lamps(on)
	_set_shadow_sources()

	var sun_up: bool = on and sun_max > WindowLight.MIN_LIGHT_ENERGY and toward.z > 0.0
	var lamp_up: bool = on and lamp_max > WindowLight.MIN_LIGHT_ENERGY
	var map_up: bool = sun_up or (on and sky == SkyLight.GEOMETRY) or (on and actor_map != ActorMap.TWINS)
	_sun_light.enabled = map_up
	_lamp_light.enabled = lamp_up
	_sun_up = map_up
	_lamp_up = lamp_up
	_repaint_house()
	var actor_on: bool = actor_map != ActorMap.TWINS
	_sun_actor_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS if map_up and actor_on else SubViewport.UPDATE_DISABLED
	_lamp_actor_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS if lamp_up and actor_on else SubViewport.UPDATE_DISABLED
	_air.visible = sun_up and air_on and (top_beams == TopBeams.VOLUME or side_beams == SideBeams.GEOMETRY)
	_set_shadow_views()


## The shadow windows run every frame while their map is lit and the actor casts a shadow there.
func _set_shadow_views() -> void:
	if _shadow_views.is_empty():
		return
	var ups: Array[bool] = [_sun_up, _lamp_up, _room_lamp_up]
	for index: int in _shadow_views.size():
		# The window holds the whole map there (ticket 35), so it runs whenever its map is lit.
		var on: bool = _window_on() and ups[index]
		_shadow_views[index].render_target_update_mode = SubViewport.UPDATE_ALWAYS if on else SubViewport.UPDATE_DISABLED
	_set_shadow_rect()


func _window_on() -> bool:
	return enabled and actor_shadow != ActorShadow.NONE and shadow_compute == ShadowCompute.WINDOW


func _set_shadow_rect() -> void:
	Lit.set_all(&"shadow_rect", Vector4(_shadow_origin.x, _shadow_origin.y, SHADOW_WIN.x, SHADOW_WIN.y) if _window_on() else Vector4.ZERO)


## Which of each map's lights the actor shadows (the shader's bits: 1 direct, 2 sky, 4 rooms' lamps).
func _set_shadow_sources() -> void:
	var sun_bits: int = (1 if shadow_sources & SHADOW_SUN != 0 else 0) | (2 if shadow_sources & SHADOW_SKY != 0 else 0)
	_sun_material.set_shader_parameter(&"shadow_sources", sun_bits)
	_lamp_material.set_shader_parameter(&"shadow_sources", 1 if shadow_sources & SHADOW_NIGHT != 0 else 0)
	_room_lamp_material.set_shader_parameter(&"shadow_sources", 4 if shadow_sources & SHADOW_LAMPS != 0 else 0)
	for material: ShaderMaterial in [_sun_material, _lamp_material, _room_lamp_material]:
		material.set_shader_parameter(&"shadow_angle", shadow_angle)
		material.set_shader_parameter(&"shadow_stretch", shadow_stretch)
		material.set_shader_parameter(&"shadow_sun_point", shadow_sun_point)
		material.set_shader_parameter(&"shadow_lamp_length", shadow_lamp_length)
		material.set_shader_parameter(&"shadow_gradient", shadow_gradient)
		material.set_shader_parameter(&"shadow_gradient_soft", 1 if shadow_gradient_soft else 0)
		material.set_shader_parameter(&"sky_shadow_k", sky_shadow_k)
		material.set_shader_parameter(&"sky_shadow_soft", sky_shadow_soft)
		material.set_shader_parameter(&"sky_shadow_gradient", sky_shadow_gradient)
		material.set_shader_parameter(&"sky_shadow_reach", sky_shadow_reach)
		material.set_shader_parameter(&"sky_shadow_contact", sky_shadow_contact)
		material.set_shader_parameter(&"shadow_k", shadow_k)
		material.set_shader_parameter(&"shadow_look", shadow_look)
		material.set_shader_parameter(&"object_length", 1 if object_length else 0)


## Side windows as game1-proto (SideWindowLight, research 47 pattern A): a ribbon per sash from the
## glass on the wall's floor line, as far as light through that sash falls, parallel to the back
## windows' light and gated by how squarely the sun faces the wall. The cross shows as gaps.
func _paint_side_beams(sun: SunSample) -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var ppm: float = config.px_per_m
	var travel: Vector2 = SideWindowLight._travel(sun.sun_azimuth_deg, sun.sun_c)
	var sun_k: float = Exposure.energy(sun.sun_lux, _brightest_exposure(), LightTextures.peak(LightTextures.Shape.FLAT), sun.sun_knee)
	for index: int in _side_beams.size():
		var sash: Vector4 = _side_spans[index]
		var left: bool = geometry.sash_walls[_side_sashes[index]] == SunGeometry.Wall.LEFT
		var wall_azimuth: float = 90.0 if left else 270.0
		var facing: float = smoothstep(0.0, SIDE_FACING_FULL,
				clampf(cos(deg_to_rad(sun.sun_azimuth_deg - wall_azimuth)), 0.0, 1.0))
		var x: float = (geometry.shell_min.x if left else geometry.shell_max.x) * ppm
		var into: Vector2 = Vector2(2.0 if left else -2.0, 0.0)
		# Along the wall at side_width × px_per_m round the window's middle (which stays in place).
		var middle: float = geometry.sash_middles[_side_sashes[index]]
		var centre: float = geometry.floor_y + middle * ppm * config.depth_factor
		var from: Vector2 = Vector2(x, centre + (sash.x - middle) * ppm * side_width)
		var to: Vector2 = Vector2(x, centre + (sash.y - middle) * ppm * side_width)
		var near: PackedVector2Array = PackedVector2Array([from, to, to + into, from + into])
		var fall: PackedFloat32Array = PackedFloat32Array([sash.z * ppm, sash.z * ppm, sash.w * ppm, sash.w * ppm])
		var energy: float = profile.beam_energy * sun_k * facing * profile.top_beam_k * SIDE_BEAM_K * air_k * sun_scale / 0.5
		if not (enabled and air_on and side_beams in [SideBeams.WALL_LINE, SideBeams.WALL_LINE_SHORT]):
			energy = 0.0
		if side_beams == SideBeams.WALL_LINE_SHORT:
			_side_beams[index].paint(near, fall, travel, energy, sun.sun_color, Vector2.ZERO, 0.0, SIDE_REACH, SIDE_WIDEN)
		else:
			# As SideWindowLight._paint_beams: past the landing, the profile's widening on the pane's side
			# only (the mullion's gap stays clean down the beam).
			var away: Vector2 = (from + to) / 2.0 - Vector2(x, centre)
			_side_beams[index].paint(near, fall, travel, energy * SIDE_LONG_K, sun.sun_color, away, 0.0, WindowLight.LONG_EXTEND)


## Back windows (TopBeams.POLYGON): a beam per sash from the glass (height drawn up) exactly into
## where light through it lands, narrowing into the patch (WindowLight with day_patch, ticket 27).
func _paint_back_beams(sun: SunSample) -> void:
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
		if not (enabled and air_on and top_beams == TopBeams.POLYGON):
			energy = 0.0
		var away: Vector2 = Vector2((sash.x + sash.y) / 2.0 - geometry.sash_middles[_back_sashes[index]], 0.0) * ppm
		_back_beams[index].paint(near, fall, travel, energy, sun.sun_color, away, 1.0, 1.0, 1.0)


## The floor of the room a side-window sash lights (the ribbon lies on it and must not cross a
## partition, the human); the whole house when none is found.
func _sash_room_floor(data: SunGeometry, index: int) -> Rect2:
	var sash: Vector4 = data.sashes[index]
	var middle: float = (sash.x + sash.y) / 2.0
	var left: bool = data.sash_walls[index] == SunGeometry.Wall.LEFT
	if data.sash_walls[index] == SunGeometry.Wall.BACK:
		# Its room's back wall and floor.
		for room: RoomLighting in rooms:
			var area: Rect2 = room.global_floor_rect()
			var low: Vector2 = data.ground_m(area.position)
			var high: Vector2 = data.ground_m(area.end)
			if absf(low.y) < 0.05 and middle >= low.x and middle <= high.x:
				return area.grow_side(SIDE_TOP, data.shell_max.z * ProjectionConfig.current().px_per_m)
		return Rect2(_rect)
	for room: RoomLighting in rooms:
		var area: Rect2 = room.global_floor_rect()
		var low: Vector2 = data.ground_m(area.position)
		var high: Vector2 = data.ground_m(area.end)
		var at_wall: bool = absf((low.x if left else high.x) - (data.shell_min.x if left else data.shell_max.x)) < 0.05
		if at_wall and middle >= low.y and middle <= high.y:
			return area
	return Rect2(_rect)


## The map's side ribbons (SideBeams.RIBBON): one per pane column, as the old ones.
func _set_ribbons(sun: SunSample, toward: Vector3) -> void:
	var on: bool = enabled and air_on and side_beams == SideBeams.RIBBON and toward.z > 0.0 and sun.sun_lux > 0.0
	_ribbon.visible = on
	if not on:
		return
	var spans: PackedVector4Array = PackedVector4Array()
	var walls: PackedInt32Array = PackedInt32Array()
	var middles: PackedFloat32Array = PackedFloat32Array()
	for index: int in mini(_side_spans.size(), MAX_RIBBONS):
		spans.append(_side_spans[index])
		walls.append(geometry.sash_walls[_side_sashes[index]])
		middles.append(geometry.sash_middles[_side_sashes[index]])
	var count: int = spans.size()
	spans.resize(MAX_RIBBONS)
	walls.resize(MAX_RIBBONS)
	middles.resize(MAX_RIBBONS)
	_ribbon_material.set_shader_parameter(&"ribbon_count", count)
	_ribbon_material.set_shader_parameter(&"ribbons", spans)
	_ribbon_material.set_shader_parameter(&"ribbon_wall", walls)
	_ribbon_material.set_shader_parameter(&"ribbon_mid", middles)
	_ribbon_material.set_shader_parameter(&"source", toward)
	_ribbon_material.set_shader_parameter(&"reach_k", side_reach)
	# Along the wall at side_width × px_per_m on screen: the depth is drawn × depth_factor.
	_ribbon_material.set_shader_parameter(&"span_k", side_width / ProjectionConfig.current().depth_factor)
	# As bright as the back windows' beams (room_light already holds sun_k × sun_scale).
	_ribbon_material.set_shader_parameter(&"gain", profile.beam_energy * profile.beam_area_k(2.5) * profile.beam_gain * air_k / 0.5 * side_ribbon_k)


## The light outside the back windows by night (snow and sky, as their glow and the door's), at full value.
func _outside_color(sun: SunSample) -> Color:
	var outside: Color = profile.sky_glow_color(sun)
	return outside / maxf(outside.r, maxf(outside.g, outside.b))


## Dust: lit by the map (its motes inside the real beams) or by the window lights again.
func _set_dust(on: bool) -> void:
	if on == _dust_on:
		return
	_dust_on = on
	var up: float = geometry.shell_max.z * ProjectionConfig.current().px_per_m
	for room: RoomLighting in rooms:
		room.set_dust_map(_dust_material if on else null, up, DUST_AMOUNT_K)
		if on:
			_dust_material.set_shader_parameter(&"dust_color", room.profile.dust_color)


func _brightest_exposure() -> float:
	var best: float = 0.0
	for room: RoomLighting in rooms:
		best = maxf(best, room.exposure)
	return best if best > 0.0 else 1.0


func _set_night() -> void:
	var lamps: PackedVector3Array = PackedVector3Array()
	var out: float = geometry.shell_max.y + LAMP_OUT_M
	match night:
		Night.STREET:
			var side: float = STREET_C * tan(deg_to_rad(NIGHT_SIDE_DEG))
			_lamp_material.set_shader_parameter(&"point_source", 0)
			_lamp_material.set_shader_parameter(&"source", Vector3(side, -STREET_C if night_wall == 1 else STREET_C, 1.0))
			return
		Night.EACH:
			for x: float in geometry.front_windows:
				lamps.append(Vector3(x, out, LAMP_UP_M))
		_:
			lamps.append(Vector3((geometry.shell_min.x + geometry.shell_max.x) / 2.0, out, LAMP_UP_M))
	_lamp_material.set_shader_parameter(&"point_source", 2)
	_lamp_material.set_shader_parameter(&"lamp_count", lamps.size())
	lamps.resize(8)
	_lamp_material.set_shader_parameter(&"lamps", lamps)


func _process(_delta: float) -> void:
	if geometry == null or not enabled:
		return
	_set_boxes()
	_set_actor()


## The rooms' lamps as the map's point sources, at their room's exposure; painted once per change.
func _set_room_lamps(on: bool) -> void:
	var map_on: bool = on and room_lamps
	LightFixture.map_lamps = map_on
	var bulbs: PackedVector3Array = PackedVector3Array()
	var colors: PackedVector3Array = PackedVector3Array()
	var reaches: PackedFloat32Array = PackedFloat32Array()
	var ppm: float = ProjectionConfig.current().px_per_m
	for fixture: LightFixture in _fixtures:
		if not is_instance_valid(fixture) or fixture.last_level <= 0.01 or bulbs.size() >= MAX_ROOM_LAMPS:
			continue
		var foot: Vector2 = geometry.ground_m(fixture.global_position)
		bulbs.append(Vector3(foot.x, foot.y - fixture.def.source_back_m, fixture.def.source_height_m))
		var energy: float = Exposure.energy(fixture.def.lux * fixture.last_level, fixture.last_exposure, 1.0) * room_lamp_k
		colors.append(Vector3(fixture.def.color.r, fixture.def.color.g, fixture.def.color.b) * energy)
		reaches.append(fixture.reach_px() / ppm)
	var count: int = bulbs.size()
	bulbs.resize(MAX_ROOM_LAMPS)
	colors.resize(MAX_ROOM_LAMPS)
	reaches.resize(MAX_ROOM_LAMPS)
	_room_lamp_material.set_shader_parameter(&"room_lamp_count", count)
	_room_lamp_material.set_shader_parameter(&"room_lamps", bulbs)
	_room_lamp_material.set_shader_parameter(&"room_lamp_color", colors)
	_room_lamp_material.set_shader_parameter(&"room_lamp_reach", reaches)
	# The actor's strip lives in the sun map (painted every frame): the lamps go there too.
	var on_actor: bool = map_on and actor_map != ActorMap.TWINS
	LightFixture.map_actor = on_actor
	_sun_material.set_shader_parameter(&"room_lamp_count", count if on_actor else 0)
	_sun_material.set_shader_parameter(&"room_lamps", bulbs)
	_sun_material.set_shader_parameter(&"room_lamp_color", colors)
	_sun_material.set_shader_parameter(&"room_lamp_reach", reaches)
	_sun_material.set_shader_parameter(&"lamp_size", LAMP_SIZE_M)
	_sun_material.set_shader_parameter(&"lamp_soft", LAMP_SOFT)
	_sun_material.set_shader_parameter(&"actor_sky_k", actor_sky_k)
	_sun_material.set_shader_parameter(&"actor_lamp_k", actor_lamp_k)
	_room_lamp_light.enabled = map_on and count > 0
	_room_lamp_up = _room_lamp_light.enabled
	if _room_lamp_light.enabled:
		_room_lamp_view.render_target_update_mode = SubViewport.UPDATE_ONCE


## The actor's strip follows its feet (the maps compute its light there, lit.gdshader reads it).
func _set_actor() -> void:
	if not is_instance_valid(actor):
		return
	var feet: Vector2 = geometry.ground_m(actor.global_position)
	_sun_material.set_shader_parameter(&"actor_feet", feet)
	_lamp_material.set_shader_parameter(&"actor_feet", feet)
	var corner: Vector2 = actor.global_position - Vector2(ACTOR_STRIP.x / 2.0, ACTOR_STRIP.y)
	Lit.actor_material().set_shader_parameter(&"actor_rect", Vector4(corner.x, corner.y, ACTOR_STRIP.x, ACTOR_STRIP.y))
	_shadow_origin = (actor.global_position - Vector2(SHADOW_WIN.x / 2.0, SHADOW_ABOVE)).round()
	for material: ShaderMaterial in [_sun_material, _lamp_material, _room_lamp_material]:
		material.set_shader_parameter(&"shadow_origin", _shadow_origin)
	_set_shadow_rect()


## Towards the sun in (x, d, z): its light travels sun_c metres across the floor per metre of fall, in
## the screen direction the hand-tuned windows use (SideWindowLight._travel).
func _toward_sun(sun: SunSample) -> Vector3:
	var azimuth: float = deg_to_rad(sun.sun_azimuth_deg)
	return Vector3(-sin(azimuth) * sun.sun_c, cos(azimuth) * sun.sun_c, 1.0)


func _set_geometry() -> void:
	var walls: PackedInt32Array = geometry.sash_walls.duplicate()
	walls.resize(SunGeometry.MAX_SASHES)
	var sashes: PackedVector4Array = PackedVector4Array(geometry.sashes)
	for material: ShaderMaterial in _materials:
		material.set_shader_parameter(&"ppm", ProjectionConfig.current().px_per_m)
		material.set_shader_parameter(&"kd", ProjectionConfig.current().depth_factor)
		material.set_shader_parameter(&"floor_y", geometry.floor_y)
		material.set_shader_parameter(&"shell_min", geometry.shell_min)
		material.set_shader_parameter(&"shell_max", geometry.shell_max)
		material.set_shader_parameter(&"sash_count", sashes.size())
		material.set_shader_parameter(&"sashes", sashes)
		material.set_shader_parameter(&"sash_wall", walls)
	_set_boxes()


## Boxes with their shown tops (partitions cut down), and the actor where the player stands.
func _set_boxes() -> void:
	var lows: PackedVector3Array = PackedVector3Array()
	var highs: PackedVector3Array = PackedVector3Array()
	var tops: PackedFloat32Array = PackedFloat32Array()
	var objects: PackedInt32Array = PackedInt32Array()
	var shown: PackedFloat32Array = geometry.shown_tops()
	if shown != _shown_tops:
		_shown_tops = shown
		if _room_lamp_view != null:
			_room_lamp_view.render_target_update_mode = SubViewport.UPDATE_ONCE
		_repaint_house()
	for index: int in geometry.boxes.size():
		var block: Block = geometry.box_blocks[index]
		var partition: bool = block == null or block.size_m.z >= geometry.shell_max.z - 0.01 \
				or block.lift_m > 0.0
		if not furniture_shadows and not partition:
			continue
		var box: AABB = geometry.boxes[index]
		lows.append(box.position)
		highs.append(box.end)
		tops.append(shown[index])
		objects.append(0 if partition else 1)
	var shape: int = int(actor_shadow) if is_instance_valid(actor) else 0
	var body: Vector4 = Vector4.ZERO
	var half_depth: float = ACTOR_SIZE_M.y / 2.0
	if shape != 0:
		var feet: Vector2 = geometry.ground_m(actor.global_position)
		var half_w: float = ACTOR_SIZE_M.x / 2.0
		if actor_shadow == ActorShadow.CYLINDER:
			half_w = shadow_radius
			half_depth = shadow_radius
		elif actor_shadow == ActorShadow.FLAT:
			half_w = FLAT_HALF_M
		body = Vector4(feet.x, feet.y, half_w, ProjectionConfig.current().actor_height_m)
	var count: int = lows.size()
	lows.resize(SunGeometry.MAX_BOXES + 1)
	highs.resize(SunGeometry.MAX_BOXES + 1)
	tops.resize(SunGeometry.MAX_BOXES + 1)
	objects.resize(SunGeometry.MAX_BOXES + 1)
	for material: ShaderMaterial in _materials:
		material.set_shader_parameter(&"box_count", count)
		material.set_shader_parameter(&"box_min", lows)
		material.set_shader_parameter(&"box_max", highs)
		material.set_shader_parameter(&"box_top", tops)
		material.set_shader_parameter(&"box_object", objects)
		material.set_shader_parameter(&"actor_shape", shape)
		material.set_shader_parameter(&"actor_body", body)
		material.set_shader_parameter(&"actor_half_depth", half_depth)
		# The maps hold the actor only when repainted whole; the beams in the air always.
		var a_map: bool = material == _sun_material or material == _lamp_material or material == _room_lamp_material
		material.set_shader_parameter(&"actor_in_map", 1 if (not a_map or shadow_compute == ShadowCompute.FULL) else 0)


func _map_material() -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = MAP_SHADER
	material.set_shader_parameter(&"origin_px", Vector2(_rect.position))
	_materials.append(material)
	return material


## The house maps change only with the time, an option or a wall cut down; the actor's shadow (when
## on) moves every frame.
func _repaint_house() -> void:
	if _sun_view == null:
		return
	var every_frame: bool = actor_shadow != ActorShadow.NONE and shadow_compute == ShadowCompute.FULL
	if _room_lamp_view != null and _room_lamp_up:
		_room_lamp_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS if every_frame else SubViewport.UPDATE_ONCE
	for pair: Array in [[_sun_view, _sun_up], [_lamp_view, _lamp_up]]:
		var view: SubViewport = pair[0]
		var up: bool = pair[1]
		if not up:
			view.render_target_update_mode = SubViewport.UPDATE_DISABLED
		elif every_frame:
			view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		else:
			view.render_target_update_mode = SubViewport.UPDATE_ONCE


## A map viewport over the house, or (actor) over the actor strip only: the same material, its rect
## shifted so the strip falls on the viewport.
## shadow (ticket 33): the actor's shadow window, right of the strip.
func _viewport(material: ShaderMaterial, actor_strip: bool = false, shadow: bool = false) -> SubViewport:
	var view: SubViewport = SubViewport.new()
	view.size = ACTOR_STRIP if actor_strip else _map_size
	if shadow:
		view.size = SHADOW_WIN
	view.disable_3d = true
	view.use_hdr_2d = true
	view.transparent_bg = false
	view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var rect: ColorRect = ColorRect.new()
	rect.size = Vector2(_map_size)
	if actor_strip:
		rect.position = Vector2(-_rect.size.x, 0.0)
		rect.size = Vector2(_rect.size.x + ACTOR_STRIP.x, ACTOR_STRIP.y)
	if shadow:
		var skip: float = _rect.size.x + ACTOR_STRIP.x
		rect.position = Vector2(-skip, 0.0)
		rect.size = Vector2(skip + SHADOW_WIN.x, maxf(SHADOW_WIN.y, _rect.size.y))
	rect.material = material
	view.add_child(rect)
	add_child(view)
	return view


func _light(height: float, mask: int) -> PointLight2D:
	var light: PointLight2D = PointLight2D.new()
	var texture: ImageTexture = LightTextures.get_shape(LightTextures.Shape.FLAT)
	light.texture = texture
	light.transform = Transform2D(0.0, Vector2(_rect.size) / Vector2(texture.get_size()), 0.0,
			Vector2(_rect.position) + Vector2(_rect.size) / 2.0)
	light.height = height
	light.range_item_cull_mask = mask
	light.color = Color.WHITE
	light.energy = 1.0
	add_child(light)
	return light
