class_name SideWindowLight
extends Node2D
## A window in a side or front wall, which the 3/4 view does not draw. A soft pillow of sky light
## along the wall and, while the sun stands in front of this wall, sun beams parallel to every other
## beam, one per sash, from the glass as projected on screen (height drawn up) to where its light lands
## on the floor, so they narrow towards the window (as game1-proto's back windows). Place the node on
## the inner edge of the wall where the window starts (side wall: at the floor y of its first px; front
## wall: at the floor's bottom edge).
## style-lab (ticket 27): the window-shaped patch on the floor by day and by night, and the variants
## below, set by the Poligon before it builds.

const PILLOW_TEXTURE_LENGTH: float = 192.0 ## The SKY_PILLOW shape's width, for its scale.
const PATCH_HEIGHT: float = 50.0
const COOL_NIGHT: Color = Color(0.45, 0.55, 0.95) ## Moon and snow (22c §4.2).
const SODIUM: Color = Color(1.0, 0.7, 0.28) ## #FFB347 (critic 2: warmer).
const NIGHT_TURN_DEG: float = 0.0 ## The night light comes straight in (the human: not off to the side).
const NIGHT_C: float = 1.1 ## Its length per metre of height (game1-proto street lamp).
const TRANSOM_AT: float = 0.55 ## Of the glass height, from the sill: four panes, as game1-proto's window.

const BEAM_K: float = 0.6 ## Bottom windows' beams, times the profile's, when they are on.
const SIDE_BEAM_K: float = 1.0 ## Side windows' beams: they must be seen (the human), and draw no patch.
## The night patch as game1-proto's street lamp: the same window as by day (same cookie, same size),
## crisp, in another place and another light (the human: the soft wide one looked bad).
const NIGHT_WIDEN: float = 0.7 ## Critic 2: 30% smaller than the window, so it does not swamp the actor.
const NIGHT_LONG_C: float = 1.1
const SOFT_DAY: int = 2 ## Softening: the cookie shrunk this many times and scaled back up (day)...
const SOFT_NIGHT: int = 4 ## ... and by night.
const SOFT_MARGIN: float = 0.25 ## Dark border added first, per side, so the edges fade too.

## Variants (F1 on the Poligon).
static var beams: int = 2 ## Sun beams in the air: 0 none, 1 side windows, 2 side and bottom.
static var day_patch: bool = true ## The window-shaped sun patch on the floor.
## By night only bottom (street: a sodium street lamp) and/or back windows show their shape on the
## floor: 0 none, 1 bottom, 2 back (WindowLight), 3 both. Side windows never.
static var night_patch: int = 1
static var night_pillow_k: float = 1.0 ## The sky pillow by night, times this.

@export var profile: WindowLightProfile
@export var wall_height_px: int = 104
@export var wall_azimuth_deg: float = 180.0 ## Outward normal, as on a WindowLight.
@export var span: int = 48 ## Px along the wall.
@export var into_right: bool = true ## Left wall: the light goes right (+x).
@export var into_up: bool = false ## Front wall: the light goes up (-y); span runs along x.
@export var beam_k: float = 1.0
@export var patch_k: float = 1.0
@export var panes: int = 2 ## Sashes side by side along the wall, a mullion between them.
@export var mullion_px: int = 1 ## Thin bars, as game1-proto's cookie.
@export var street_side: bool = false ## Faces the street: a street lamp may shine in by night.
@export var night_lux: float = 10.0 ## The night patch at its brightest, lx on the floor.
@export var street_lux: float = 30.0

var _pillow: PointLight2D
var _beams: Array[BeamCanvas] = []
var _patch: PointLight2D
var _night: PointLight2D
var _cookie_texture: ImageTexture


func _ready() -> void:
	_pillow = PointLight2D.new()
	_pillow.texture = LightTextures.get_shape(LightTextures.Shape.SKY_PILLOW)
	_pillow.offset = WindowLight.SKY_OFFSET
	_pillow.height = WindowLight.SKY_HEIGHT
	_pillow.scale = Vector2(profile.top_pillow_along * span / PILLOW_TEXTURE_LENGTH, 1.0)
	if into_up:
		_pillow.position = Vector2(span / 2.0, 0)
		_pillow.rotation = PI
	else:
		_pillow.position = Vector2(0, span / 2.0)
		_pillow.rotation = -PI / 2.0 if into_right else PI / 2.0
	add_child(_pillow)
	for _pane: int in maxi(panes, 1):
		var beam: BeamCanvas = BeamCanvas.new()
		beam.profile = profile
		add_child(beam)
		_beams.append(beam)
	_cookie_texture = _cookie(span, _glass_rows(), maxi(panes, 1), mullion_px)
	_patch = _patch_light(soften(_cookie_texture, SOFT_DAY))
	_night = _patch_light(soften(_cookie_texture, SOFT_DAY))


## `interior`: the room's back wall and floor in this node's pixels (the beam is clipped to it).
func setup(slot: int, interior: Rect2) -> void:
	for beam: BeamCanvas in _beams:
		beam.interior = interior
	_pillow.range_item_cull_mask = LightMasks.of(slot, LightMasks.Receiver.FLOOR | LightMasks.Receiver.SOLID)
	_patch.range_item_cull_mask = LightMasks.of(slot, LightMasks.Receiver.FLOOR)
	_night.range_item_cull_mask = LightMasks.of(slot, LightMasks.Receiver.FLOOR)


## Daylight this window adds to its room, lux × m²: x = sky, y = sun.
func flux(sun: SunSample) -> Vector2:
	return Vector2(
			sun.out_lux * profile.sky_flux_coef,
			sun.sun_lux * profile.sun_flux_coef * _facing(sun.sun_azimuth_deg)) * _glass_m2()


func apply(sun: SunSample, exposure: float) -> void:
	var area_k: float = profile.beam_area_k(_glass_m2())
	# Sky: always the sky's colour, as strong as a back window's pillow (ADR 0007: lux only).
	_pillow.color = sun.sky_color
	_pillow.energy = Exposure.energy(
			sun.sky_lux * profile.df_near, exposure, LightTextures.peak(LightTextures.Shape.SKY_PILLOW)) \
			* area_k * lerpf(1.0, night_pillow_k, sun.night)
	_pillow.enabled = _pillow.energy > WindowLight.MIN_LIGHT_ENERGY and not SunMap.replaces_sky()
	# Sun: one rule for every wall: the same screen direction as the back windows, gated by how
	# squarely the sun faces this wall.
	var travel: Vector2 = _travel(sun.sun_azimuth_deg, sun.sun_c)
	var facing: float = smoothstep(0.0, profile.top_facing_full, _facing(sun.sun_azimuth_deg))
	var sun_k: float = Exposure.energy(
			sun.sun_lux, exposure, LightTextures.peak(LightTextures.Shape.FLAT), sun.sun_knee)
	var beams_on: bool = beams == 2 or (beams == 1 and not into_up)
	var kind_k: float = BEAM_K if into_up else SIDE_BEAM_K
	var energy: float = profile.beam_energy * sun_k * area_k * facing * profile.top_beam_k * beam_k * kind_k 			* (1.0 if beams_on else 0.0)
	_shear(_patch, travel)
	_patch.color = sun.sun_color
	_patch.energy = sun_k * facing * patch_k
	# Side windows draw no patch (the human): their beams widen and fade instead.
	_patch.enabled = day_patch and into_up and _patch.energy > WindowLight.MIN_LIGHT_ENERGY and not SunMap.enabled
	_paint_beams(travel, 0.0 if SunMap.enabled else energy, sun.sun_color) # ticket 31: the map draws the sun instead
	# Night: only a bottom window shows its shape on the floor, a street lamp's sodium when it faces
	# the street, else the cold light of snow and sky.
	var sodium: bool = street_side
	_shear(_night, _travel(wall_azimuth_deg + NIGHT_TURN_DEG, NIGHT_LONG_C), NIGHT_WIDEN)
	_night.color = SODIUM if sodium else COOL_NIGHT
	_night.energy = Exposure.energy((street_lux if sodium else night_lux) * sun.night, exposure,
			LightTextures.peak(LightTextures.Shape.FLAT)) * patch_k
	_night.enabled = into_up and night_patch in [1, 3] and _night.energy > WindowLight.MIN_LIGHT_ENERGY and not SunMap.enabled


## One beam per sash, from the window (the sash on the wall line) to where light through its sill
## and head lands on the floor. With the window patch on, the beam ends exactly on it, narrowing into
## it; without it, it widens and fades on past the landing (the human).
func _paint_beams(travel: Vector2, energy: float, color: Color) -> void:
	var px_m: float = WindowLight.px_m()
	var along: Vector2 = Vector2(1, 0) if into_up else Vector2(0, 1)
	var into: Vector2 = Vector2(0, -1) if into_up else Vector2(1 if into_right else -1, 0)
	var sill: float = profile.top_sill_m * px_m
	var head: float = wall_height_px - profile.top_head_m * px_m
	var count: int = _beams.size()
	var pane: float = (span - mullion_px * (count - 1)) / float(count)
	var fall: PackedFloat32Array = PackedFloat32Array([sill, sill, head, head])
	var middle: Vector2 = along * span / 2.0
	var to_patch: float = 1.0 if day_patch and into_up else -1.0
	var reach: float = 1.0 if to_patch > 0.0 else WindowLight.LONG_EXTEND
	for index: int in count:
		var from: Vector2 = along * index * (pane + mullion_px)
		var to: Vector2 = from + along * pane
		var near: PackedVector2Array = PackedVector2Array([from, to, to + into, from + into])
		_beams[index].paint(near, fall, travel, energy, color, (from + to) / 2.0 - middle, 0.0, reach, to_patch)


## How far light travels across the floor per metre of fall, in screen px, from a source at `azimuth`
## (screen terms) with `c` m of travel per metre of height.
static func _travel(azimuth_deg: float, c: float) -> Vector2:
	var azimuth: float = deg_to_rad(azimuth_deg)
	return Vector2(sin(azimuth), -cos(azimuth) * ProjectionConfig.current().depth_factor) * WindowLight.px_m() * c


## Puts a patch between where light through the sill and through the head lands (`travel`: px on the
## floor per metre of height), the cookie's first row at the sill end.
## `widen`: the patch this many times as wide and long; the soft cookie's dark border is added round it.
func _shear(light: PointLight2D, travel: Vector2, widen: float = 1.0) -> void:
	var along: Vector2 = Vector2(1.0, 0.0) if into_up else Vector2(0.0, 1.0)
	var near: Vector2 = travel * profile.top_sill_m
	var far: Vector2 = travel * (wall_height_px / WindowLight.px_m() - profile.top_head_m)
	var texture: Vector2 = Vector2(light.texture.get_size())
	var scale: float = widen * (1.0 + 2.0 * SOFT_MARGIN)
	light.transform = Transform2D(along * span * scale / texture.x,
			(far - near) * scale / texture.y, along * span / 2.0 + (near + far) / 2.0)


func _patch_light(texture: ImageTexture) -> PointLight2D:
	var light: PointLight2D = PointLight2D.new()
	light.texture = texture
	light.height = PATCH_HEIGHT
	add_child(light)
	return light


func _glass_rows() -> int:
	return maxi(roundi(wall_height_px - (profile.top_sill_m + profile.top_head_m) * WindowLight.px_m()), 4)


## The glass as light, row 0 at the sill: `count` sashes side by side with a mullion between them, a
## transom across, the frame dark.
static func _cookie(width: int, rows: int, count: int, mullion: int) -> ImageTexture:
	var image: Image = Image.create_empty(maxi(width, 4), rows, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var bar: Color = Color(0.0, 0.0, 0.0, 1.0)
	var w: int = image.get_width()
	image.fill_rect(Rect2i(0, 0, w, 1), bar)
	image.fill_rect(Rect2i(0, rows - 1, w, 1), bar)
	image.fill_rect(Rect2i(0, 0, 1, rows), bar)
	image.fill_rect(Rect2i(w - 1, 0, 1, rows), bar)
	var pane: float = (w - mullion * (count - 1)) / float(count)
	for index: int in range(1, count):
		image.fill_rect(Rect2i(roundi(index * pane + (index - 1) * mullion), 0, mullion, rows), bar)
	image.fill_rect(Rect2i(0, roundi(rows * TRANSOM_AT), w, maxi(mullion, 1)), bar)
	return ImageTexture.create_from_image(image)


## A soft copy of a window cookie: a dark border round it, shrunk and scaled back up, so the bars
## and the edges blur (the night patch; the human: wider and softer).
static func soften(cookie: ImageTexture, shrink: int) -> ImageTexture:
	var source: Image = cookie.get_image()
	var size: Vector2i = source.get_size()
	var margin: Vector2i = Vector2i(roundi(size.x * SOFT_MARGIN), roundi(size.y * SOFT_MARGIN))
	var image: Image = Image.create_empty(size.x + 2 * margin.x, size.y + 2 * margin.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.BLACK)
	image.blit_rect(source, Rect2i(Vector2i.ZERO, size), margin)
	var full: Vector2i = image.get_size()
	image.resize(maxi(full.x / shrink, 2), maxi(full.y / shrink, 2), Image.INTERPOLATE_BILINEAR)
	image.resize(full.x, full.y, Image.INTERPOLATE_CUBIC)
	return ImageTexture.create_from_image(image)


## Glass seen edge-on: span along the wall × the opening's height.
func _glass_m2() -> float:
	return span / WindowLight.px_m() * (wall_height_px / WindowLight.px_m() - profile.top_sill_m - profile.top_head_m)


## How squarely a source at `azimuth_deg` stands in front of this wall (0 behind it).
func _facing(azimuth_deg: float) -> float:
	return clampf(cos(deg_to_rad(azimuth_deg - wall_azimuth_deg)), 0.0, 1.0)
