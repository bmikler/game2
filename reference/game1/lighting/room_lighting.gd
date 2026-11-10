class_name RoomLighting
extends Node2D
## One room's (or corridor's) light. Collects its WindowLight, SideWindowLight and LightFixture children, fixes the
## room's exposure from its own light level (ADR 0007), and lights the room's ambient with one flat
## light over ambient_rect (Lit: no N·L) instead of the scene-wide CanvasModulate, so rooms side by
## side keep their own ambient.

@export var profile: RoomLightingProfile
@export_range(0, 3) var slot: int = 0 ## Mask colour; neighbouring rooms differ.
@export var floor_rect: Rect2 = Rect2() ## Walkable floor: light level and who stands here.
@export var ambient_rect: Rect2 = Rect2() ## Everything drawn for this room (floor, walls, props).
@export var dust_rect: Rect2 = Rect2() ## Where dust hangs in the beams.
## Rooms with no wall between them (the hall and the corridor) name the same space: they are lit as
## one, with one exposure and ambient from their light together (LightingDirector), so there is no
## cut where their floors meet. Empty: the room is a space of its own.
@export var space: StringName = &""

var exposure: float = 1.0
var light_lux: float = 0.0 ## The room's light level, including floor_lux.
var fixture_level: float = 0.0
var active: bool = true

var _windows: Array[WindowLight] = []
var _top_windows: Array[SideWindowLight] = []
var _fixtures: Array[LightFixture] = []
var _ambient: PointLight2D
var _dust: CPUParticles2D


func _ready() -> void:
	_collect(self)
	# Back wall and floor: the wall starts at y 0 (RoomShell), the floor ends at floor_rect.
	var interior: Rect2 = Rect2(Vector2(floor_rect.position.x, 0.0), Vector2(floor_rect.size.x, floor_rect.end.y))
	for window: WindowLight in _windows:
		window.setup(slot, Rect2(interior.position - window.position, interior.size))
	for window: SideWindowLight in _top_windows:
		window.setup(slot, Rect2(interior.position - window.position, interior.size))
	for fixture: LightFixture in _fixtures:
		fixture.setup(slot)
	# Actors standing at the far edge of the floor stick out above it by their height.
	var lit_rect: Rect2 = ambient_rect.merge(
			Rect2(floor_rect.position - Vector2(0, ActorLight.HEIGHT_PX), floor_rect.size))
	_ambient = _flat_light(lit_rect, LightMasks.of(slot, LightMasks.ALL))
	if profile.dust_amount > 0 and not (_windows.is_empty() and _top_windows.is_empty()):
		_build_dust()


func global_floor_rect() -> Rect2:
	return Rect2(global_position + floor_rect.position, floor_rect.size)


func global_ambient_rect() -> Rect2:
	return Rect2(global_position + ambient_rect.position, ambient_rect.size)


func set_active(on: bool) -> void:
	active = on
	visible = on
	if _dust != null:
		_dust.emitting = on


func apply(sun: SunSample) -> void:
	apply_in_space(sun, light_flux(sun), floor_area_m2())


## The light this room adds to its space, lux × m²: x = lamps, y = sky, z = sun.
func light_flux(sun: SunSample) -> Vector3:
	var level: float = _scheduled_level(sun)
	var art: float = 0.0
	for fixture: LightFixture in _fixtures:
		art += fixture.flux(level if fixture.def.scheduled else 1.0)
	var day: Vector2 = Vector2.ZERO
	for window: WindowLight in _windows:
		day += window.flux(sun)
	for window: SideWindowLight in _top_windows:
		day += window.flux(sun)
	return Vector3(art, day.x, day.y)


func floor_area_m2() -> float:
	return floor_rect.get_area() / (WindowLight.PX_M * WindowLight.PX_M)


## Exposure and ambient from the space's light (`flux` over `area` m²; for a room alone, its own),
## then this room's windows and lamps at that exposure.
func apply_in_space(sun: SunSample, flux: Vector3, area: float) -> void:
	fixture_level = _scheduled_level(sun)
	var art: float = flux.x / area
	var day: Vector2 = Vector2(flux.y, flux.z) / area
	light_lux = art + day.x + day.y + profile.floor_lux
	exposure = Exposure.target(light_lux, profile.exposure_alpha)

	var grey: float = sun.ambient_tint.get_luminance()
	var sky_tint: Color = Color(grey, grey, grey).lerp(sun.ambient_tint, profile.tint_saturation)
	var day_lux: float = day.x + profile.sun_ambient_share * day.y
	var art_weight: float = art / maxf(art + day_lux, 0.001)
	# Flat light (Lit: no N·L), so no peak: L_REF lx at exposure 1 shows the albedo.
	var filled_lux: float = day_lux + profile.art_ambient_share * art + profile.floor_lux
	_ambient.color = sky_tint.lerp(profile.art_tint, art_weight)
	_ambient.energy = minf(filled_lux * exposure / Exposure.L_REF, profile.ambient_max)

	for window: WindowLight in _windows:
		window.apply(sun, exposure)
	for window: SideWindowLight in _top_windows:
		window.apply(sun, exposure)
	for fixture: LightFixture in _fixtures:
		fixture.apply(fixture_level if fixture.def.scheduled else 1.0, exposure)


## Lamps that light this room's floor light `floors` too (other floors of its space, open to it).
func light_floors(floors: int) -> void:
	for fixture: LightFixture in _fixtures:
		if fixture.def.receivers & LightMasks.Receiver.FLOOR:
			fixture.add_receivers(floors)


func ambient_energy() -> float:
	return _ambient.energy


func ambient_color() -> Color:
	return _ambient.color


## Rim light for an actor standing at `feet` in this room (rgb: colour, a: energy), from the window
## that lights it most.
func rim(feet: Vector2) -> Color:
	var best: Color = Color(0, 0, 0, 0)
	for window: WindowLight in _windows:
		var color: Color = window.rim(feet)
		if color.a > best.a:
			best = color
	return best


## Level of the scheduled lamps at this hour (1 without a schedule).
func _scheduled_level(sun: SunSample) -> float:
	var schedule: Curve = profile.fixture_schedule
	return schedule.sample(sun.hour / 24.0) if schedule != null else 1.0


func _collect(node: Node) -> void:
	for child: Node in node.get_children():
		if child is WindowLight:
			_windows.append(child as WindowLight)
		elif child is SideWindowLight:
			_top_windows.append(child as SideWindowLight)
		elif child is LightFixture:
			_fixtures.append(child as LightFixture)
		else:
			_collect(child)


func _flat_light(rect: Rect2, mask: int) -> PointLight2D:
	var light: PointLight2D = PointLight2D.new()
	var texture: ImageTexture = LightTextures.get_shape(LightTextures.Shape.FLAT)
	light.texture = texture
	light.transform = Transform2D(0.0, rect.size / Vector2(texture.get_size()), 0.0, rect.get_center())
	light.height = Lit.AMBIENT_HEIGHT
	light.range_item_cull_mask = mask
	add_child(light)
	return light


func _build_dust() -> void:
	_dust = CPUParticles2D.new()
	_dust.position = dust_rect.get_center()
	_dust.z_index = 4
	_dust.light_mask = LightMasks.DUST
	var material: CanvasItemMaterial = CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY
	_dust.material = material
	_dust.amount = profile.dust_amount
	_dust.lifetime = profile.dust_lifetime
	_dust.preprocess = profile.dust_lifetime
	_dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_dust.emission_rect_extents = dust_rect.size / 2.0
	_dust.spread = 180.0
	_dust.gravity = Vector2.ZERO
	_dust.initial_velocity_min = profile.dust_velocity_min
	_dust.initial_velocity_max = profile.dust_velocity_max
	_dust.color = profile.dust_color
	add_child(_dust)
