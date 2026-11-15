extends GutTest
## The day state as a pure function of the hour (day curves + sky profile → day state).

const CITY: String = "res://addons/swiatlo/tuning/sky_city.tres"
const VILLAGE: String = "res://addons/swiatlo/tuning/sky_village.tres"

var _curves: DayCurves
var _sky: SkyProfile


func before_each() -> void:
	_curves = load(DayCurves.DEFAULT_PATH) as DayCurves
	_sky = load(CITY) as SkyProfile


func _state(hour: float, curves: DayCurves = _curves, sky: SkyProfile = _sky) -> DayState:
	return DayState.from_hour(curves, sky, hour)


func test_day_curves_have_every_curve() -> void:
	assert_not_null(_curves)
	for field: StringName in [&"sun_elevation", &"sun_azimuth", &"sun_intensity", &"sky_intensity",
			&"ambient_intensity", &"sun_disc", &"cloud_cover", &"exposure"]:
		assert_true(_curves.get(field) is Curve, "curve %s" % field)
	for field: StringName in [&"sun_color", &"sky_color", &"ambient_color"]:
		assert_true(_curves.get(field) is Gradient, "gradient %s" % field)


func test_sun_rises_on_the_left() -> void:
	var morning: DayState = _state(8.0)
	assert_gt(morning.sun_elevation, 0.0)
	assert_lt(morning.sun_direction.x, 0.0, "morning sun on the left (east)")


func test_sun_sets_on_the_right() -> void:
	var evening: DayState = _state(17.0)
	assert_gt(evening.sun_elevation, 0.0)
	assert_gt(evening.sun_direction.x, 0.0, "evening sun on the right (west)")


func test_noon_sun_is_at_the_top() -> void:
	var noon: DayState = _state(12.5)
	assert_lt(noon.sun_direction.y, 0.0, "sun in the south, deep in the scene (−d)")
	assert_almost_eq(noon.sun_direction.x, 0.0, 0.05)
	assert_almost_eq(noon.sun_azimuth, 180.0, 1.0)


func test_sun_is_highest_at_noon() -> void:
	assert_gt(_state(12.5).sun_elevation, _state(9.0).sun_elevation)
	assert_gt(_state(12.5).sun_elevation, _state(16.0).sun_elevation)


func test_at_night_the_sun_is_below_the_horizon_and_dark() -> void:
	var night: DayState = _state(0.0)
	assert_lt(night.sun_elevation, 0.0)
	assert_almost_eq(night.sun_intensity, 0.0, 0.001)
	assert_gt(_state(12.5).sun_intensity, 0.0)


func test_sun_direction_is_unit_and_matches_elevation() -> void:
	var state: DayState = _state(10.0)
	assert_almost_eq(state.sun_direction.length(), 1.0, 0.0001)
	assert_almost_eq(state.sun_direction.z, sin(deg_to_rad(state.sun_elevation)), 0.0001)


func test_hour_wraps_around_the_day() -> void:
	assert_almost_eq(_state(24.0).hour, 0.0, 0.0001)
	assert_almost_eq(_state(25.5).hour, 1.5, 0.0001)
	assert_almost_eq(_state(-1.0).hour, 23.0, 0.0001)


func test_noon_sky_colour_comes_from_the_curve() -> void:
	var color: Color = _state(11.5).sky_color
	assert_almost_eq(color.r, Color("#cce0ff").r, 0.02)
	assert_almost_eq(color.b, Color("#cce0ff").b, 0.02)


func test_scrolling_the_day_has_no_jumps() -> void:
	var previous: DayState = _state(0.0)
	for minute: int in range(1, 24 * 60):
		var state: DayState = _state(minute / 60.0)
		assert_almost_eq(state.floor_light().r, previous.floor_light().r, 0.05, "minute %d" % minute)
		previous = state


func test_day_is_brighter_than_night() -> void:
	assert_gt(_state(12.5).floor_light().get_luminance(), _state(0.0).floor_light().get_luminance())


func test_night_is_not_black() -> void:
	assert_gt(_state(0.0).floor_light().get_luminance(), 0.02)


func _curves_with_cover(cover: float) -> DayCurves:
	var curves: DayCurves = _curves.duplicate(true) as DayCurves
	var curve: Curve = Curve.new()
	curve.max_domain = 24.0
	curve.add_point(Vector2(0.0, cover))
	curve.add_point(Vector2(24.0, cover))
	curves.cloud_cover = curve
	return curves


func test_cloud_cover_weakens_the_sun() -> void:
	var clear: DayState = _state(12.5, _curves_with_cover(0.0))
	var cloudy: DayState = _state(12.5, _curves_with_cover(0.5))
	assert_almost_eq(cloudy.cloud_cover, 0.5, 0.001)
	assert_almost_eq(cloudy.sun_intensity, clear.sun_intensity * 0.5, 0.01)


func test_cloud_cover_brightens_and_whitens_the_sky_and_widens_the_disc() -> void:
	var clear: DayState = _state(12.5, _curves_with_cover(0.0))
	var overcast: DayState = _state(12.5, _curves_with_cover(1.0))
	assert_gt(overcast.sky_intensity, clear.sky_intensity)
	assert_lt(overcast.sky_color.s, clear.sky_color.s, "whiter = less saturated")
	assert_gt(overcast.sun_disc, clear.sun_disc)


func test_sky_profile_changes_the_night_not_the_day() -> void:
	var village: SkyProfile = load(VILLAGE) as SkyProfile
	assert_gt(_state(0.0).sky_intensity, _state(0.0, _curves, village).sky_intensity, "the city glows")
	assert_almost_eq(_state(12.5).sky_intensity, _state(12.5, _curves, village).sky_intensity, 0.001)


func test_exposure_is_positive_and_higher_at_night() -> void:
	assert_gt(_state(12.5).exposure, 0.0)
	assert_gt(_state(0.0).exposure, _state(12.5).exposure)


func test_state_recomputes_in_place() -> void:
	var state: DayState = DayState.new()
	state.compute(_curves, _sky, 8.0)
	var morning_x: float = state.sun_direction.x
	state.compute(_curves, _sky, 17.0)
	assert_lt(morning_x, 0.0)
	assert_gt(state.sun_direction.x, 0.0)
