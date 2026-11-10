class_name WindowLight
extends Node2D
## Everything a back-wall window brings into a room: the view outside (day, golden, night images),
## beams and dust in the air, warm bounce, sun on the reveals and sill, the cool sky pillow, and the
## rim light test for actors standing in the beam. Place the node at the top-left of the wall image;
## all rects are in wall pixels. The window knows nothing about lamps: the room's exposure sets the
## balance.

const RIM_Z: Array[float] = [0.1, 1.0, 1.7] ## Feet, waist, head (m).
const RIM_X: Array[float] = [-0.25, 0.0, 0.25] ## Left, middle, right of the body (m).
const MIN_LIGHT_ENERGY: float = 0.01
const AIR_TEXTURE_SIZE: float = 64.0 ## The AIR shape's size, for its transform.
const BOUNCE_HEIGHT: float = 90.0
const SKY_HEIGHT: float = 70.0
const SKY_OFFSET: Vector2 = Vector2(0, 64) ## Puts the pillow's top edge (the wall) at the node.
const SNOW_Z: int = -37 ## Above the views outside (-40..-38), below the wall: seen through the glass.
const PATCH_HEIGHT: float = 50.0
## Without a patch the beam reaches this far past its landing and fades (critic 2: ~4.5 m, not half way).
const LONG_EXTEND: float = 2.4

## style-lab (ticket 27), set by the Poligon before it builds: the window-shaped sun patch on the floor
## (game1 chose none for back windows) and the window's shape by night (0 none, else cool snow and sky
## light: a back window looks onto the back of the plot, no street lamp; on for 2 and 3, see
## SideWindowLight.night_patch).
static var day_patch: bool = false
static var night_patch: int = 1

@export var profile: WindowLightProfile
@export var opening: Rect2i = Rect2i(96, 14, 96, 56) ## With the reveal.
@export var glass: Rect2i = Rect2i(100, 18, 88, 50) ## Inside the sash frame.
@export var panes: Array[Rect2i] = []
@export var wall_height_px: int = 104
@export var wall_azimuth_deg: float = 180.0 ## Outward normal: 180 = the window faces south.
@export var view_day: Texture2D
@export var view_gold: Texture2D
@export var view_night: Texture2D
@export var night_lux: float = 10.0 ## style-lab: the night patch at its brightest, lx on the floor.
@export var view_anchor: Vector2i = Vector2i(118, 12) ## View pixel behind the top centre of the opening.

var sun_k: float = 0.0
var sun_color: Color = Color.WHITE
var snow: CPUParticles2D ## Falling behind the glass.

var _phi: float = 0.0
var _c: float = 1.3
var _outside_day: Sprite2D
var _outside_gold: Sprite2D
var _outside_night: Sprite2D
var _air: PointLight2D
var _bounce: PointLight2D
var _sky: PointLight2D
var _bounce_actor: PointLight2D ## ActorLight twins.
var _sky_actor: PointLight2D
var _beams: Array[BeamCanvas] = []
var _reveals: Array[Sprite2D] = []
var _patch: PointLight2D
var _night: PointLight2D


## Pixels per metre, from the current ProjectionConfig (was the constant PX_M in game1).
static func px_m() -> float:
	return ProjectionConfig.current().px_per_m


func _ready() -> void:
	_build_view()
	var foot: Vector2 = Vector2(glass.get_center().x, wall_height_px)
	_air = _light(LightTextures.get_shape(LightTextures.Shape.AIR), foot, 0.0)
	_air.range_item_cull_mask = LightMasks.DUST
	_bounce = _light(LightTextures.get_shape(LightTextures.Shape.RADIAL), foot, BOUNCE_HEIGHT)
	_bounce.texture_scale = profile.bounce_scale
	_sky = _light(LightTextures.get_shape(LightTextures.Shape.SKY_PILLOW), foot, SKY_HEIGHT)
	_sky.offset = SKY_OFFSET
	_bounce_actor = ActorLight.twin(_bounce)
	_sky_actor = ActorLight.twin(_sky)
	var cookie: ImageTexture = _cookie()
	_patch = _light(SideWindowLight.soften(cookie, SideWindowLight.SOFT_DAY), foot, PATCH_HEIGHT)
	_night = _light(SideWindowLight.soften(cookie, SideWindowLight.SOFT_DAY), foot, PATCH_HEIGHT)
	for _pane: Rect2i in panes:
		var beam: BeamCanvas = BeamCanvas.new()
		beam.profile = profile
		add_child(beam)
		_beams.append(beam)
	# Sun on the reveals and the sill: additive strips.
	var strips: Array[Rect2i] = [
		Rect2i(opening.position.x, opening.position.y, 2, opening.size.y),
		Rect2i(opening.end.x - 2, opening.position.y, 2, opening.size.y),
		Rect2i(opening.position.x - 4, opening.end.y, opening.size.x + 8, 2),
	]
	for strip: Rect2i in strips:
		var image: Image = Image.create_empty(strip.size.x, strip.size.y, false, Image.FORMAT_RGBA8)
		image.fill(Color.WHITE)
		var texture: ImageTexture = ImageTexture.create_from_image(image)
		_reveals.append(_unshaded(texture, Vector2(strip.position), -19, CanvasItemMaterial.BLEND_MODE_ADD))


## `interior`: the room's back wall and floor in this node's pixels (beams are clipped to it).
func setup(slot: int, interior: Rect2) -> void:
	for beam: BeamCanvas in _beams:
		beam.interior = interior
	var floor_and_solid: int = LightMasks.Receiver.FLOOR | LightMasks.Receiver.SOLID
	_bounce.range_item_cull_mask = LightMasks.of(slot, LightMasks.Receiver.SOLID)
	_patch.range_item_cull_mask = LightMasks.of(slot, LightMasks.Receiver.FLOOR)
	_night.range_item_cull_mask = LightMasks.of(slot, LightMasks.Receiver.FLOOR)
	_sky.range_item_cull_mask = LightMasks.of(slot, floor_and_solid)
	_bounce_actor.range_item_cull_mask = LightMasks.of(slot, LightMasks.Receiver.ACTOR)
	_sky_actor.range_item_cull_mask = LightMasks.of(slot, LightMasks.Receiver.ACTOR)


## Daylight this window adds to its room, lux × m²: x = sky, y = sun.
func flux(sun: SunSample) -> Vector2:
	var glass_m2: float = glass.get_area() / (px_m() * px_m())
	return Vector2(sun.out_lux * profile.sky_flux_coef,
			sun.sun_lux * profile.sun_flux_coef * _facing(sun)) * glass_m2


func apply(sun: SunSample, exposure: float) -> void:
	_phi = deg_to_rad(sun.sun_azimuth_deg - wall_azimuth_deg)
	_c = sun.sun_c
	sun_color = sun.sun_color
	var flat_peak: float = LightTextures.peak(LightTextures.Shape.FLAT)
	# style-lab: no sun while it stands behind this wall (the map can be turned, LightingDirector).
	sun_k = Exposure.energy(sun.sun_lux, exposure, flat_peak, sun.sun_knee) * smoothstep(
			0.0, profile.top_facing_full, _facing(sun))

	# The images only choose what the outside looks like; how bright it is comes from the outside
	# light (with the night mood floor) at the room's exposure.
	var view_k: float = minf(profile.view_energy(sun, exposure), profile.view_max)
	var view_color: Color = Color(view_k, view_k, view_k)
	_outside_day.modulate = view_color
	_outside_gold.modulate.a = sun.gold
	_outside_gold.self_modulate = view_color
	_outside_night.modulate.a = sun.night
	_outside_night.self_modulate = view_color
	var flakes: Color = profile.snow_day.lerp(profile.snow_gold, sun.gold).lerp(profile.snow_night, sun.night)
	snow.modulate = Color(flakes.r * view_k, flakes.g * view_k, flakes.b * view_k)

	# Beams, dust, bounce, reveals.
	var lit: bool = sun_k > profile.min_lit_energy
	var centre: Vector2 = _beam_centre()
	var middle: Vector2 = Vector2(glass.get_center())
	_air.transform = Transform2D(
			Vector2(glass.size.x / AIR_TEXTURE_SIZE, 0.0),
			(centre - middle) * profile.air_stretch / AIR_TEXTURE_SIZE,
			(middle + centre) / 2.0)
	_air.color = sun_color
	_air.energy = profile.air_energy * sun_k
	_air.enabled = lit and not SunMap.enabled # ticket 31: the map draws the sun instead
	_bounce.position = centre
	_bounce.color = sun_color * profile.floor_albedo * profile.bounce_tint
	_bounce.energy = profile.bounce_energy * sun_k
	_bounce.enabled = lit
	_update_beams(lit)
	var side: float = clampf(absf(_phi) / deg_to_rad(profile.reveal_full_phi_deg), 0.0, 1.0) \
			* sun_k * profile.reveal_side_energy
	_reveals[0].modulate = sun_color * (side if _phi > 0.0 else 0.0)
	_reveals[1].modulate = sun_color * (side if _phi < 0.0 else 0.0)
	_reveals[2].modulate = sun_color * sun_k * profile.reveal_sill_energy

	_shear(_patch, _sun_travel())
	_patch.color = sun_color
	_patch.energy = sun_k
	_patch.enabled = day_patch and lit and not SunMap.enabled
	_shear(_night, SideWindowLight._travel(wall_azimuth_deg + SideWindowLight.NIGHT_TURN_DEG, SideWindowLight.NIGHT_LONG_C),
			SideWindowLight.NIGHT_WIDEN)
	_night.color = SideWindowLight.COOL_NIGHT
	_night.energy = Exposure.energy(night_lux * sun.night, exposure, flat_peak)
	_night.enabled = night_patch in [2, 3] and _night.energy > MIN_LIGHT_ENERGY and not SunMap.enabled

	_sky.color = profile.sky_glow_color(sun)
	_sky.energy = Exposure.energy(
			profile.sky_glow_lux(sun), exposure, LightTextures.peak(LightTextures.Shape.SKY_PILLOW))
	_sky.enabled = _sky.energy > MIN_LIGHT_ENERGY
	ActorLight.sync(_bounce, _bounce_actor)
	ActorLight.sync(_sky, _sky_actor)
	# Ticket 31: the map lights floor and walls with sky from the geometry; actors keep the pillow's twin.
	if SunMap.replaces_sky():
		_sky.enabled = false
	# Ticket 31: the map lights the actor too (its strip): the twins step aside.
	if SunMap.enabled and SunMap.actor_map != SunMap.ActorMap.TWINS:
		_sky_actor.enabled = false
		_bounce_actor.enabled = false


## How squarely the sun stands in front of this wall (0 behind it).
func _facing(sun: SunSample) -> float:
	return clampf(cos(deg_to_rad(sun.sun_azimuth_deg - wall_azimuth_deg)), 0.0, 1.0)


## Rim light for an actor (rgb: sun colour, a: energy) whose feet are at `feet` (global): how much of
## them is in the beam, testing feet, waist and head, each across the body's width, against the glass.
## The width matters: a thin mullion shadow must not cover the body.
func rim(feet: Vector2) -> Color:
	var local: Vector2 = feet - global_position
	var depth: float = (local.y - wall_height_px) / (px_m() * ProjectionConfig.current().depth_factor)
	if sun_k < profile.min_lit_energy or depth <= 0.0:
		return Color(0, 0, 0, 0)
	var hits: int = 0
	for height: float in RIM_Z:
		var wall_z: float = height + depth / (_c * cos(_phi))
		for side: float in RIM_X:
			var wall_x: float = local.x / px_m() + side + depth * tan(_phi)
			if _is_glass(int(wall_x * px_m()), int(wall_height_px - wall_z * px_m())):
				hits += 1
	return Color(sun_color, profile.rim_energy * sun_k * hits / float(RIM_Z.size() * RIM_X.size()))


func _build_view() -> void:
	var at: Vector2 = Vector2(opening.get_center().x - view_anchor.x, opening.position.y - view_anchor.y)
	_outside_day = _unshaded(view_day, at, -40)
	_outside_gold = _unshaded(view_gold, at, -39)
	_outside_night = _unshaded(view_night, at, -38)
	_build_snow()


func _build_snow() -> void:
	snow = CPUParticles2D.new()
	snow.position = Vector2(opening.get_center().x, opening.position.y - profile.snow_emit_above)
	snow.z_index = SNOW_Z
	snow.amount = profile.snow_amount
	snow.lifetime = profile.snow_lifetime
	snow.preprocess = profile.snow_preprocess
	snow.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	snow.emission_rect_extents = Vector2(opening.size.x * profile.snow_emit_width, profile.snow_emit_half_height)
	snow.direction = profile.snow_direction
	snow.spread = profile.snow_spread
	snow.gravity = profile.snow_gravity
	snow.initial_velocity_min = profile.snow_velocity_min
	snow.initial_velocity_max = profile.snow_velocity_max
	snow.scale_amount_min = profile.snow_scale_min
	snow.scale_amount_max = profile.snow_scale_max
	snow.material = _material(CanvasItemMaterial.BLEND_MODE_MIX)
	add_child(snow)


## How far light travels across the floor per metre of fall, in screen pixels (style-lab: depth on
## the floor shortened by ProjectionConfig.depth_factor).
func _sun_travel() -> Vector2:
	var depth: float = ProjectionConfig.current().depth_factor
	return Vector2(-sin(_phi), cos(_phi) * depth) * px_m() * _c


## Where a light from the glass lands on the floor, at azimuth _phi off the window normal.
func _beam_centre() -> Vector2:
	var travel: Vector2 = _sun_travel()
	var base: Vector2 = Vector2(glass.get_center().x, wall_height_px)
	var near: Vector2 = base + travel * (float(wall_height_px - glass.end.y) / px_m())
	var far: Vector2 = base + travel * (float(wall_height_px - glass.position.y) / px_m())
	return (near + far) / 2.0


## One additive beam per pane, from the glass towards its landing on the floor, widening: the far end
## is beam_widen × the pane's width across the beam instead of only the top corners' projection.
func _update_beams(lit: bool) -> void:
	var travel: Vector2 = _sun_travel()
	var energy: float = profile.beam_energy * sun_k * profile.beam_area_k(glass.get_area() / (px_m() * px_m()))
	for index: int in _beams.size():
		var beam: BeamCanvas = _beams[index]
		beam.visible = lit and not SunMap.enabled
		if not lit or SunMap.enabled: # paint() would show it again
			continue
		var pane: Rect2i = panes[index]
		var corners: Array[Vector2i] = [
			pane.position,
			Vector2i(pane.end.x, pane.position.y),
			pane.end,
			Vector2i(pane.position.x, pane.end.y),
		]
		var near: PackedVector2Array = PackedVector2Array()
		var fall: PackedFloat32Array = PackedFloat32Array() # Height above the floor, px.
		for corner: Vector2i in corners:
			near.append(Vector2(corner))
			fall.append(float(wall_height_px - corner.y))
		var away: Vector2 = Vector2(pane.get_center() - glass.get_center())
		# With the patch on, the beam runs from the glass (height drawn up: rise 1) exactly into it,
		# narrowing; without it, as game1-proto: shorter, widening and fading past the landing.
		if day_patch:
			beam.paint(near, fall, travel, energy, sun_color, away, 1.0, 1.0, 1.0)
		else:
			beam.paint(near, fall, travel, energy, sun_color, away, 0.0, LONG_EXTEND)


## style-lab (ticket 27, from game1-proto): shears a window-cookie light onto the floor, between where
## light through the bottom and the top of the glass lands (`travel`: px on the floor per metre of fall).
## `widen`: this many times as wide and long; the soft cookie's dark border is added round it.
func _shear(light: PointLight2D, travel: Vector2, widen: float = 1.0) -> void:
	var base: Vector2 = Vector2(glass.get_center().x, wall_height_px)
	var near: Vector2 = base + travel * (float(wall_height_px - glass.end.y) / px_m())
	var far: Vector2 = base + travel * (float(wall_height_px - glass.position.y) / px_m())
	var texture: Vector2 = Vector2(light.texture.get_size())
	var scale: float = widen * (1.0 + 2.0 * SideWindowLight.SOFT_MARGIN)
	light.transform = Transform2D(Vector2(glass.size.x * scale / texture.x, 0.0), (far - near) * scale / texture.y,
			(near + far) / 2.0)


## The panes as light, flipped so row 0 is the bottom of the glass (the near edge on the floor).
func _cookie() -> ImageTexture:
	var image: Image = Image.create_empty(glass.size.x, glass.size.y, false, Image.FORMAT_RGBA8)
	for row: int in glass.size.y:
		for x: int in glass.size.x:
			var on: bool = _is_glass(glass.position.x + x, glass.end.y - 1 - row)
			image.set_pixel(x, row, Color.WHITE if on else Color.BLACK)
	return ImageTexture.create_from_image(image)


func _is_glass(x: int, y: int) -> bool:
	for pane: Rect2i in panes:
		if pane.has_point(Vector2i(x, y)):
			return true
	return false


func _light(texture: Texture2D, at: Vector2, height: float) -> PointLight2D:
	var light: PointLight2D = PointLight2D.new()
	light.texture = texture
	light.position = at
	light.height = height
	add_child(light)
	return light


func _unshaded(
		texture: Texture2D, at: Vector2, z: int,
		blend: CanvasItemMaterial.BlendMode = CanvasItemMaterial.BLEND_MODE_MIX) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.position = at
	sprite.z_index = z
	sprite.material = _material(blend)
	add_child(sprite)
	return sprite


static func _material(blend: CanvasItemMaterial.BlendMode) -> CanvasItemMaterial:
	var material: CanvasItemMaterial = CanvasItemMaterial.new()
	material.blend_mode = blend
	material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	return material
