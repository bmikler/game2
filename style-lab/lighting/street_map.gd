class_name StreetMap
extends Node2D
## PROTOTYPE (ticket 14, „Światło w Poligonach”): the street's light from one function (street_fn: the
## sun, the sky less what the occluders hide, the street lamps, the lit windows by night) tested against
## one set of occluders (buildings with their roofs, the terrace, every Block, trees, the car, the actor as
## a cylinder), into one buffer (street_map.gdshader in a SubViewport never cleared), as the house's SunMap:
## painted whole when something changes, then a window round the actor every frame; the actor's body in a
## strip right of the street. The Poligon fills the geometry, then calls setup() once and apply() each
## game minute.

const MAP_SHADER: Shader = preload("res://lighting/street_map.gdshader")
const STRIP: Vector2i = Vector2i(32, 96)
const MAX_BOXES: int = 127 ## One more slot is the actor's (the shader's arrays: 128).
const MAX_WINDOWS: int = 64
const MAX_LAMPS: int = 16
const ACTOR_RADIUS_M: float = 0.26
const LAMP_REACH_M: float = 14.0
const SKY_REACH_M: float = 3.0 ## Round the actor: its sky shadow (and contact shadow) fades out by here.
const WINDOW_PAD_PX: float = 8.0
const BUILDING_SPAN_M: float = 60.0 ## The farthest a sun ray from the actor is followed.

## Variants and knobs (F1 on the street; the critic's sliders, ticket 38).
static var enabled: bool = true
static var sun_k: float = 0.5 ## The sun on open ground: × its lux at the street's exposure (was the facades' light).
static var sky_share: float = 0.75 ## The sky's share the map draws (with its shadows); the rest stays flat (bounce).
static var window_k: float = 1.0 ## The lit windows' light on the snow.
static var window_lux: float = 1100.0 ## A lit pane's light per form factor (lux on a face it fills).
static var lamp_k: float = 1.0
static var building_shadows: bool = true
static var debug_view: int = 0
static var actor_shadow: bool = true
## The quality gate (as the house's): 1 the actor as a box, 2 a box in its place (the actor casting nothing):
## 1 and 2 must give the same buffer outside the actor's strip.
static var test: int = 0

## Filled by the Poligon (metres: x across, d into the depth from the street's back edge, z up).
var boxes: Array[AABB] = []
var box_tops: PackedFloat32Array = PackedFloat32Array() ## The shown top (a receiver), -1: only an occluder.
var box_arch: PackedInt32Array = PackedInt32Array()
var box_roofs: PackedVector2Array = PackedVector2Array() ## Type (0 none, 1 ridge along x, 2 along d), rise.
var windows: Array[Vector4] = [] ## x0, x1, z0, z1 on a facade...
var window_ds: PackedFloat32Array = PackedFloat32Array() ## ... at this d, facing +d...
var window_colors: PackedColorArray = PackedColorArray() ## ... glowing this colour...
var window_by_day: PackedByteArray = PackedByteArray() ## ... also by day (a lamp on in it).
var window_day_k: float = 0.0 ## The Poligon's: the lamps in windows by day (0 off).
var window_night_k: float = 1.0 ## The Poligon's: 0 when the windows stay dark at night.
var fixtures: Array[LightFixture] = []

var room: RoomLighting
var actor: Node2D
var _rect: Rect2i
var _extent: Vector3 ## The street's ground: x, d (metres).
var _view: SubViewport
var _map: ShaderMaterial
var _whole: ColorRect
var _window: ColorRect
var _light: PointLight2D
var _debug: Sprite2D
var _dirty: bool = true
var _last_window: Rect2 = Rect2()
var _away: Array[Vector3] = [] ## Directions away from the sun (its disc's rim too).
var _points: Array[Vector3] = [] ## Lamp bulbs and lit windows' corners: the actor's shadow from them.
var _actor_middle: Vector2 = Vector2.ZERO
static var _current: StreetMap


## A box and how it takes part: receives (its top shown), architecture (B keeps its sky shadow exact).
func add_box(box: AABB, receives: bool, arch: bool, roof: Vector2 = Vector2.ZERO) -> void:
	if boxes.size() >= MAX_BOXES:
		push_warning("StreetMap: too many boxes")
		return
	boxes.append(box)
	box_tops.append(box.end.z if receives else -1.0)
	box_arch.append(1 if arch else 0)
	box_roofs.append(roof)


func add_block(block: Block, arch: bool = false) -> void:
	var foot: Vector2 = ground_m(block.global_position)
	var size: Vector3 = block.size_m
	add_box(AABB(Vector3(foot.x - size.x / 2.0, foot.y - size.y, block.lift_m), Vector3(size.x, size.y, size.z - block.lift_m)),
			true, arch)


func add_window(rect: Vector4, d: float, color: Color, by_day: bool) -> void:
	if windows.size() >= MAX_WINDOWS:
		return
	windows.append(rect)
	window_ds.append(d)
	window_colors.append(color)
	window_by_day.append(1 if by_day else 0)


static func ground_m(world: Vector2) -> Vector2:
	var config: ProjectionConfig = ProjectionConfig.current()
	return Vector2(world.x / config.px_per_m, world.y / (config.px_per_m * config.depth_factor))


## `area`: the street in world px (everything drawn); `ground`: its walkable ground (x, d metres).
func setup(street: RoomLighting, player: Node2D, area: Rect2, ground: Vector2) -> void:
	_current = self
	room = street
	actor = player
	room.sky_in_map = sky_share if enabled else 0.0
	_extent = Vector3(ground.x, ground.y, 0.0)
	_rect = Rect2i(Vector2i(floori(area.position.x), floori(area.position.y)),
			Vector2i(ceili(area.size.x), ceili(area.size.y)))
	_map = ShaderMaterial.new()
	_map.shader = MAP_SHADER
	_view = SubViewport.new()
	_view.size = Vector2i(_rect.size.x + STRIP.x, maxi(_rect.size.y, STRIP.y))
	_view.disable_3d = true
	# Its own 2D world: the street's glow (WorldEnvironment) bloomed into the buffer and piled up where
	# the actor's window did not repaint.
	_view.world_2d = World2D.new()
	_view.own_world_3d = true # the environment (glow) lives in the 3D world
	_view.use_hdr_2d = true
	_view.transparent_bg = true
	_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_view.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_whole = _rect_in(Vector2.ZERO, Vector2(_rect.size))
	_window = _rect_in(Vector2.ZERO, Vector2.ONE)
	_rect_in(Vector2(_rect.size.x, 0.0), Vector2(STRIP))
	add_child(_view)
	_map.set_shader_parameter(&"origin_px", Vector2(_rect.position))
	_map.set_shader_parameter(&"house_w", float(_rect.size.x))
	_map.set_shader_parameter(&"strip_size", Vector2(STRIP))
	var mask: int = 0
	for slot: int in LightMasks.SLOTS:
		mask |= LightMasks.of(slot, LightMasks.ALL)
	_light = PointLight2D.new()
	var texture: ImageTexture = LightTextures.get_shape(LightTextures.Shape.FLAT)
	_light.texture = texture
	_light.transform = Transform2D(0.0, Vector2(_rect.size) / Vector2(texture.get_size()), 0.0,
			Vector2(_rect.position) + Vector2(_rect.size) / 2.0)
	_light.height = SunMap.LIGHT_MAP_HEIGHT
	_light.range_item_cull_mask = mask
	add_child(_light)
	Lit.set_all(&"light_map", _view.get_texture())
	Lit.set_all(&"light_map_smooth", _view.get_texture())
	Lit.set_all(&"map_origin", Vector2(_rect.position))
	Lit.set_all(&"map_size", Vector2(_view.size))
	Lit.set_all(&"house_w", float(_rect.size.x))
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
	_set_geometry()


func _rect_in(at: Vector2, size: Vector2) -> ColorRect:
	var rect: ColorRect = ColorRect.new()
	rect.position = at
	rect.size = size
	rect.material = _map
	_view.add_child(rect)
	return rect


func _set_geometry() -> void:
	var config: ProjectionConfig = ProjectionConfig.current()
	var p: ShaderMaterial = _map
	p.set_shader_parameter(&"ppm", config.px_per_m)
	p.set_shader_parameter(&"kd", config.depth_factor)
	p.set_shader_parameter(&"floor_y", 0.0)
	p.set_shader_parameter(&"shell_min", Vector3.ZERO)
	p.set_shader_parameter(&"shell_max", Vector3(_extent.x, _extent.y, 100.0))
	p.set_shader_parameter(&"room_count", 1)
	p.set_shader_parameter(&"room_rect", PackedVector4Array([Vector4(0.0, 0.0, _extent.x, _extent.y)]))
	_set_boxes()


## PROTOTYPE: the street buffer's raw data (as SunMap.dump_buffer), if a street is shown.
static func dump_current(path: String) -> void:
	if _current == null or not is_instance_valid(_current) or _current._view == null or not enabled:
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_buffer(_current._view.get_texture().get_image().get_data())


func apply(sun: SunSample) -> void:
	if room == null:
		return
	visible = enabled
	_light.visible = enabled
	LightFixture.map_lamps = enabled
	LightFixture.map_actor = enabled
	room.sky_in_map = sky_share if enabled else 0.0
	var p: ShaderMaterial = _map
	var exposure: float = room.exposure
	var toward: Vector3 = _toward_sun(sun)
	var sun_energy: float = Exposure.energy(sun.sun_lux, exposure, 1.0, sun.sun_knee) * sun_k
	var sun_on: bool = enabled and toward.z > 0.0 and sun_energy > WindowLight.MIN_LIGHT_ENERGY
	p.set_shader_parameter(&"street_sun", _rgb(sun.sun_color) * sun_energy)
	p.set_shader_parameter(&"street_sky", _rgb(room.sky_tint) * room.sky_energy * sky_share)
	p.set_shader_parameter(&"sun_dir", toward)
	p.set_shader_parameter(&"sun_on", 1 if sun_on else 0)
	p.set_shader_parameter(&"sun_soft", tan(deg_to_rad(SunMap.sun_disc_deg)))
	p.set_shader_parameter(&"building_shadows", 1 if building_shadows else 0)
	p.set_shader_parameter(&"lamp_size", SunMap.bulb_m)
	var amb: Color = room.ambient_color() * room.ambient_energy()
	p.set_shader_parameter(&"room_ambient", PackedVector3Array([_rgb(amb), Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]))
	p.set_shader_parameter(&"look", SunMap.look)
	var view_levels: bool = SunMap.light_res > 1 and (SunMap.look == 1 or SunMap.look == 3)
	p.set_shader_parameter(&"light_res", 1.0)
	p.set_shader_parameter(&"view_levels", view_levels)
	Lit.set_all(&"light_res", float(SunMap.light_res))
	Lit.set_all(&"view_levels", view_levels)
	Lit.set_all(&"level_stops", SunMap.level_stops)
	Lit.set_all(&"level_band", SunMap.level_band)
	p.set_shader_parameter(&"level_stops", SunMap.level_stops)
	p.set_shader_parameter(&"level_band", SunMap.level_band)
	p.set_shader_parameter(&"key_cut", SunMap.key_cut)
	p.set_shader_parameter(&"key_band", SunMap.key_band)
	p.set_shader_parameter(&"key_min", SunMap.key_min)
	p.set_shader_parameter(&"contact_m", SunMap.contact_m)
	p.set_shader_parameter(&"contact_k", SunMap.contact_k)
	p.set_shader_parameter(&"debug_view", debug_view)
	p.set_shader_parameter(&"actor_k", SunMap.actor_k)
	_debug.visible = enabled and debug_view > 0
	_set_lamps()
	_set_windows(sun, exposure)
	_set_sources(toward if sun_on else Vector3.ZERO)
	_dirty = true


static func _rgb(color: Color) -> Vector3:
	return Vector3(color.r, color.g, color.b)


## The street lamps (FixtureDef.map_source) as point sources at the street's exposure.
func _set_lamps() -> void:
	var bulbs: PackedVector3Array = PackedVector3Array()
	var colors: PackedVector3Array = PackedVector3Array()
	var reaches: PackedFloat32Array = PackedFloat32Array()
	_points.clear()
	for fixture: LightFixture in fixtures:
		if not enabled or not is_instance_valid(fixture) or fixture.last_level <= 0.01 or bulbs.size() >= MAX_LAMPS:
			continue
		var foot: Vector2 = ground_m(fixture.global_position)
		var bulb: Vector3 = Vector3(foot.x, foot.y - fixture.def.source_back_m, fixture.def.source_height_m)
		bulbs.append(bulb)
		var energy: float = Exposure.energy(fixture.def.lux * fixture.last_level, fixture.last_exposure, 1.0) * lamp_k
		colors.append(_rgb(fixture.def.color) * energy)
		reaches.append(LAMP_REACH_M)
		_points.append(bulb)
	var count: int = bulbs.size()
	bulbs.resize(MAX_LAMPS)
	colors.resize(MAX_LAMPS)
	reaches.resize(MAX_LAMPS)
	_map.set_shader_parameter(&"lamp_count", count)
	_map.set_shader_parameter(&"lamps", bulbs)
	_map.set_shader_parameter(&"lamp_color", colors)
	_map.set_shader_parameter(&"lamp_reach", reaches)


## The lit windows: by night (sun.night), and those with a lamp by day.
func _set_windows(sun: SunSample, exposure: float) -> void:
	var rects: PackedVector4Array = PackedVector4Array()
	var ds: PackedFloat32Array = PackedFloat32Array()
	var colors: PackedVector3Array = PackedVector3Array()
	var night: float = clampf(1.0 - sun.day * 1.6, 0.0, 1.0) * window_night_k
	for index: int in windows.size():
		var level: float = night
		if window_by_day[index] == 1:
			level = maxf(level, window_day_k * sun.day)
		if not enabled or level <= 0.0 or window_k <= 0.0:
			continue
		var energy: float = Exposure.energy(window_lux * level, exposure, 1.0) * window_k
		rects.append(windows[index])
		ds.append(window_ds[index])
		colors.append(_rgb(window_colors[index]) * energy)
		var rect: Vector4 = windows[index]
		for corner: Vector2 in [Vector2(rect.x, rect.z), Vector2(rect.y, rect.z), Vector2(rect.x, rect.w), Vector2(rect.y, rect.w)]:
			_points.append(Vector3(corner.x, window_ds[index], corner.y))
	var count: int = rects.size()
	rects.resize(MAX_WINDOWS)
	ds.resize(MAX_WINDOWS)
	colors.resize(MAX_WINDOWS)
	_map.set_shader_parameter(&"win_count", count)
	_map.set_shader_parameter(&"win_rect", rects)
	_map.set_shader_parameter(&"win_d", ds)
	_map.set_shader_parameter(&"win_color", colors)


func _set_sources(toward: Vector3) -> void:
	_away.clear()
	if toward == Vector3.ZERO:
		return
	var soft: float = tan(deg_to_rad(SunMap.sun_disc_deg))
	var axis: Vector3 = toward.normalized()
	var u: Vector3 = axis.cross(Vector3.BACK if absf(axis.z) < 0.99 else Vector3.RIGHT).normalized()
	var v: Vector3 = axis.cross(u)
	for j: Vector2 in [Vector2.ZERO, Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
		_away.append(-(axis + (u * j.x + v * j.y) * soft))


## Towards the sun in (x, d, z), as SunMap (the same sun inside and out).
func _toward_sun(sun: SunSample) -> Vector3:
	var azimuth: float = deg_to_rad(sun.sun_azimuth_deg)
	return Vector3(-sin(azimuth) * sun.sun_c, cos(azimuth) * sun.sun_c, 1.0)


func _process(_delta: float) -> void:
	if room == null or not enabled:
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
	var whole: bool = _dirty or SunMap.whole_every_frame
	_dirty = false
	_whole.visible = whole
	_window.visible = not whole and both.has_area()
	both = both.intersection(Rect2(Vector2.ZERO, Vector2(_rect.size)))
	both = Rect2(both.position.floor(), both.end.ceil() - both.position.floor())
	_window.position = both.position
	_window.size = both.size


## The boxes, the test box and the actor (its middle a radius behind the feet).
func _set_boxes() -> void:
	var lows: PackedVector3Array = PackedVector3Array()
	var highs: PackedVector3Array = PackedVector3Array()
	var tops: PackedFloat32Array = box_tops.duplicate()
	var arch: PackedInt32Array = box_arch.duplicate()
	var roofs: PackedVector2Array = box_roofs.duplicate()
	for box: AABB in boxes:
		lows.append(box.position)
		highs.append(box.end)
	var shape: int = 1 if actor_shadow and is_instance_valid(actor) else 0
	var height: float = ProjectionConfig.current().actor_height_m
	var r: float = ACTOR_RADIUS_M
	if is_instance_valid(actor):
		var feet: Vector2 = ground_m(actor.global_position)
		_actor_middle = Vector2(feet.x, feet.y - r)
	if test == 1:
		shape = 2
	elif test == 2:
		shape = 0
		lows.append(Vector3(_actor_middle.x - r, _actor_middle.y - r, 0.0))
		highs.append(Vector3(_actor_middle.x + r, _actor_middle.y + r, height))
		tops.append(-1.0)
		arch.append(0)
		roofs.append(Vector2.ZERO)
	var count: int = lows.size()
	lows.resize(MAX_BOXES + 1)
	highs.resize(MAX_BOXES + 1)
	tops.resize(MAX_BOXES + 1)
	arch.resize(MAX_BOXES + 1)
	roofs.resize(MAX_BOXES + 1)
	_map.set_shader_parameter(&"box_count", count)
	_map.set_shader_parameter(&"box_min", lows)
	_map.set_shader_parameter(&"box_max", highs)
	_map.set_shader_parameter(&"box_top", tops)
	_map.set_shader_parameter(&"box_arch", arch)
	_map.set_shader_parameter(&"box_roof", roofs)
	_map.set_shader_parameter(&"actor_shape", shape)
	_map.set_shader_parameter(&"actor_body", Vector4(_actor_middle.x, _actor_middle.y, r, height))


## The buffer px the actor's shadows can change: round it (sky and contact), and where rays from the sun,
## the lamps and the lit windows past its corners meet the ground or the first architecture.
func _actor_window() -> Rect2:
	if not actor_shadow and test == 0:
		return Rect2()
	var r: float = ACTOR_RADIUS_M
	var h: float = ProjectionConfig.current().actor_height_m
	var corners: Array[Vector3] = []
	for x: float in [-r, r]:
		for y: float in [-r, r]:
			for z: float in [0.0, h]:
				corners.append(Vector3(_actor_middle.x + x, _actor_middle.y + y, z))
	var ends: Array[Vector3] = []
	var reach: float = SKY_REACH_M
	for x: float in [-reach, reach]:
		for y: float in [-reach, reach]:
			ends.append(Vector3(_actor_middle.x + x, _actor_middle.y + y, 0.0))
	ends.append(Vector3(_actor_middle.x, _actor_middle.y, h + 0.3))
	var walls: Array[AABB] = []
	for index: int in boxes.size():
		if box_arch[index] == 1:
			walls.append(boxes[index])
	var middle: Vector2 = _actor_middle
	for dir: Vector3 in _away:
		for corner: Vector3 in corners:
			ends.append(_ray_end(corner, dir, walls))
	for point: Vector3 in _points:
		if Vector2(point.x, point.y).distance_to(middle) > LAMP_REACH_M:
			continue
		for corner: Vector3 in corners:
			ends.append(_ray_end(corner, corner - point, walls))
	var low: Vector2 = Vector2(INF, INF)
	var high: Vector2 = -low
	for end: Vector3 in ends:
		var at: Vector2 = _screen(end)
		low = low.min(at)
		high = high.max(at)
	var pad: Vector2 = Vector2(WINDOW_PAD_PX, WINDOW_PAD_PX)
	return Rect2(low - pad, high - low + pad * 2.0)


## Where o + t·dir meets the ground or the first piece of architecture (followed at most BUILDING_SPAN_M).
func _ray_end(o: Vector3, dir: Vector3, walls: Array[AABB]) -> Vector3:
	var length: float = dir.length()
	if length < 1e-6:
		return o
	var unit: Vector3 = dir / length
	var t: float = BUILDING_SPAN_M
	if unit.z < -1e-6:
		t = minf(t, o.z / -unit.z)
	var end: Vector3 = o + unit * t
	for wall: AABB in walls:
		var hit: Variant = wall.intersects_segment(o, end)
		if hit != null:
			end = hit
	return end


## Buffer px of a point (x, d, z) in metres.
func _screen(point: Vector3) -> Vector2:
	var config: ProjectionConfig = ProjectionConfig.current()
	var world: Vector2 = Vector2(point.x * config.px_per_m, config.px_per_m * (config.depth_factor * point.y - point.z))
	return world - Vector2(_rect.position)
