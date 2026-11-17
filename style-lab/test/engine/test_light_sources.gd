extends GutTest
## Area light sources (headless): the source profile, the LightSource node and the source groups of
## the scene description (one layer per group), the day state's light of each profile.

const PROJECTION: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")
const STREET_LAMP: String = "res://addons/swiatlo/tuning/sources/street_lamp.tres"
const WALL_LAMP: String = "res://addons/swiatlo/tuning/sources/wall_lamp.tres"
const LIT_WINDOW: String = "res://addons/swiatlo/tuning/sources/lit_window.tres"


## A profile lit 18–6 h (off by day) with a falloff reaching `reach` metres.
func _profile(reach: float = 10.0) -> SourceProfile:
	var profile: SourceProfile = SourceProfile.new()
	profile.color = Gradient.new()
	profile.color.set_color(0, Color(1.0, 0.5, 0.25))
	profile.color.set_color(1, Color(1.0, 0.5, 0.25))
	profile.intensity = Curve.new()
	profile.intensity.max_value = 1000.0
	profile.intensity.max_domain = 24.0
	for point: Vector2 in [Vector2(0.0, 50.0), Vector2(6.0, 50.0), Vector2(7.0, 0.0), Vector2(17.0, 0.0),
			Vector2(18.0, 50.0), Vector2(24.0, 50.0)]:
		profile.intensity.add_point(point, 0.0, 0.0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	profile.falloff = Curve.new()
	profile.falloff.max_domain = reach
	profile.falloff.add_point(Vector2(0.0, 1.0))
	profile.falloff.add_point(Vector2(reach, 0.0))
	return profile


func _source(at: Vector3, profile: SourceProfile) -> LightSource:
	var source: LightSource = LightSource.new()
	source.position_m = at
	source.profile = profile
	add_child_autofree(source)
	return source


func test_a_profile_lights_in_its_hours_in_its_colour() -> void:
	var profile: SourceProfile = _profile()
	assert_eq(profile.light_at(12.0), Color(0, 0, 0, 1), "off by day")
	var night: Color = profile.light_at(22.0)
	assert_almost_eq(night.r, 50.0, 0.01)
	assert_almost_eq(night.g, 25.0, 0.01)
	assert_almost_eq(profile.light_at(17.5).r, 25.0, 0.5, "half way through switching on")


func test_a_profile_reaches_as_far_as_its_falloff() -> void:
	assert_eq(_profile(6.0).reach_m(), 6.0)


func test_the_start_profiles_light_at_night_and_the_street_lamps_switch_on_at_dusk() -> void:
	for path: String in [STREET_LAMP, WALL_LAMP, LIT_WINDOW]:
		var profile: SourceProfile = load(path) as SourceProfile
		assert_not_null(profile, path)
		assert_eq(profile.channel, SourceProfile.Channel.ARTIFICIAL, path)
		assert_gt(profile.light_at(22.0).get_luminance(), 0.0, path)
		assert_gt(profile.reach_m(), 0.0, path)
	var lamp: SourceProfile = load(STREET_LAMP) as SourceProfile
	assert_eq(lamp.light_at(12.0).get_luminance(), 0.0, "street lamps are off by day")
	assert_eq(lamp.light_at(17.8).get_luminance(), 0.0, "still off just before ten to six")
	assert_almost_eq(lamp.light_at(17.85).get_luminance(), lamp.light_at(19.0).get_luminance(), 0.001,
			"fully on a minute later: lamps switch, they do not fade")
	var wall_lamp: SourceProfile = load(WALL_LAMP) as SourceProfile
	assert_eq(wall_lamp.light_at(12.0).get_luminance(), 0.0, "the shop's lamp is off by day, as the street lamps")
	assert_gt(wall_lamp.light_at(22.0).get_luminance(), 0.0, "and on at night")


func test_a_rectangle_facing_the_camera_lies_across_x_and_up() -> void:
	var source: LightSource = _source(Vector3(2.0, -5.0, 1.5), _profile())
	source.shape = LightSource.Shape.RECTANGLE
	source.size_m = Vector2(4.0, 2.0)
	source.facing = LightSource.Facing.TOWARD_CAMERA
	var entry: SourceEntry = source.entry()
	assert_eq(entry.centre, Vector3(2.0, -5.0, 1.5))
	assert_eq(entry.normal, Vector3(0, 1, 0))
	assert_eq(entry.half_u, Vector3(2.0, 0.0, 0.0))
	assert_eq(entry.half_v, Vector3(0.0, 0.0, 1.0))


func test_a_rectangle_facing_down_lies_across_x_and_d() -> void:
	var source: LightSource = _source(Vector3.ZERO, _profile())
	source.shape = LightSource.Shape.RECTANGLE
	source.size_m = Vector2(1.0, 3.0)
	source.facing = LightSource.Facing.DOWN
	var entry: SourceEntry = source.entry()
	assert_eq(entry.normal, Vector3(0, 0, -1))
	assert_eq(entry.half_u.abs(), Vector3(0.5, 0.0, 0.0))
	assert_eq(entry.half_v.abs(), Vector3(0.0, 1.5, 0.0))


func test_a_sphere_has_the_radius_of_half_its_width() -> void:
	var source: LightSource = _source(Vector3(1.0, 2.0, 4.0), _profile())
	source.size_m = Vector2(0.3, 0.3)
	var entry: SourceEntry = source.entry()
	assert_eq(entry.kind, LightSource.Shape.SPHERE)
	assert_almost_eq(entry.radius, 0.15, 1e-6)


func test_the_node_sits_on_screen_where_the_projection_puts_it() -> void:
	var source: LightSource = _source(Vector3(3.0, -4.0, 2.0), _profile())
	assert_eq(source.position, PROJECTION.to_screen(Vector3(3.0, -4.0, 2.0)))


func test_sources_of_one_profile_share_a_group_other_profiles_get_their_own() -> void:
	var lamp: SourceProfile = _profile()
	var window: SourceProfile = _profile(6.0)
	_source(Vector3(0.0, 0.0, 4.0), lamp)
	_source(Vector3(10.0, 0.0, 4.0), window)
	_source(Vector3(20.0, 0.0, 4.0), lamp)
	var description: SceneDescription = SceneDescription.from_tree(get_tree(), PROJECTION)
	assert_eq(description.sources.size(), 3)
	assert_eq(description.source_groups.size(), 2)
	assert_eq(description.source_groups[0], lamp, "groups in the order their profiles first appear")
	assert_eq(description.source_groups[1], window)
	var groups: Array[int] = []
	for entry: SourceEntry in description.sources:
		groups.append(entry.group)
	assert_eq(groups, [0, 1, 0] as Array[int])


func test_a_source_without_a_profile_is_left_out_and_warns() -> void:
	var source: LightSource = _source(Vector3.ZERO, null)
	assert_true(SceneDescription.from_tree(get_tree(), PROJECTION).sources.is_empty())
	assert_eq(source._get_configuration_warnings().size(), 1)


func test_sources_go_to_the_shaders_four_texels_each() -> void:
	_source(Vector3(1.0, 2.0, 3.0), _profile())
	var image: Image = SceneDescription.from_tree(get_tree(), PROJECTION).source_data()
	assert_eq(image.get_width(), 4)
	var first: Color = image.get_pixel(0, 0)
	assert_eq(Vector3(first.r, first.g, first.b), Vector3(1.0, 2.0, 3.0), "centre")
	assert_eq(first.a, float(LightSource.Shape.SPHERE), "kind")


func test_the_day_state_holds_each_groups_light_at_the_hour() -> void:
	var curves: DayCurves = load(DayCurves.DEFAULT_PATH) as DayCurves
	var sky: SkyProfile = SkyProfile.new()
	var profiles: Array[SourceProfile] = [_profile()]
	var night: DayState = DayState.from_hour(curves, sky, 22.0, false, 1.0, profiles)
	assert_eq(night.source_lights.size(), 1)
	assert_almost_eq(night.source_lights[0].r, 50.0, 0.01)
	var noon: DayState = DayState.from_hour(curves, sky, 12.0, false, 1.0, profiles)
	assert_eq(noon.source_lights[0].get_luminance(), 0.0)


func test_a_falloff_samples_into_a_row_for_the_shaders() -> void:
	var image: Image = _profile(8.0).falloff_data()
	assert_eq(image.get_width(), SourceProfile.FALLOFF_TEXELS)
	assert_almost_eq(image.get_pixel(0, 0).r, 1.0, 0.01, "full at the source")
	assert_almost_eq(image.get_pixel(SourceProfile.FALLOFF_TEXELS - 1, 0).r, 0.0, 0.01, "none at the reach")
