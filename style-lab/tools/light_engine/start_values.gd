extends SceneTree
## Writes the light engine's default tuning files with starting values from the look cheat sheet
## (docs/silnik/sciaga-wygladu.md, section 4; the old `norway_feb.tres` profile). Only a start for
## the critics' variants, not a target. Run from style-lab:
##   Godot_..._console.exe --headless --path . -s res://tools/light_engine/start_values.gd

const FOLDER: String = "res://addons/swiatlo/tuning/"
const SUNRISE_H: float = 6.9
const SUNSET_H: float = 18.1
## The sun clears the roofs half an hour after sunrise and hides behind them half an hour before sunset.
const ROOF_DELAY_H: float = 0.5
## !!! CHANGED SUN ANGLE, NOT SCANDINAVIAN !!! (human, 2026-11-15)
## Noon elevation 30° = southern Poland (49° N) at the end of October / end of February, picked
## from the October–March range there (17.5° on 21 December … 45° at the end of March), not summer.
## (38° was tried first; the human found it too high.)
## The cheat sheet's February Norway sun was 0.26 (about 15°): with it the tenement houses shaded
## the whole street all day. If the game is set in Scandinavia and should be realistic, put the
## Scandinavian value back (0.26) and solve readable shadows another way.
const NOON_SIN_ELEVATION: float = 0.5
const SUNRISE_AZIMUTH_FROM_SOUTH: float = 43.0


func _init() -> void:
	_save(_day_curves(), "day_curves.tres")
	_save(_sky(Color("#4b5590"), 20.0), "sky_city.tres") # city glow, `outdoor_night_lux`
	_save(_sky(Color("#26305c"), 3.0), "sky_village.tres") # dark and cold
	_save(_tuning_set("outdoor"), "outdoor.tres")
	_save(_tuning_set("interior"), "interior.tres")
	DirAccess.make_dir_recursive_absolute(FOLDER + "sources")
	_save(_street_lamp(), "sources/street_lamp.tres")
	_save(_wall_lamp(), "sources/wall_lamp.tres")
	_save(_lit_window(), "sources/lit_window.tres")
	quit()


func _save(resource: Resource, file: String) -> void:
	var error: Error = ResourceSaver.save(resource, FOLDER + file)
	print("%s: %s" % [file, error_string(error)])


func _day_curves() -> DayCurves:
	var curves: DayCurves = DayCurves.new()
	var day_length: float = SUNSET_H - SUNRISE_H
	var noon: float = (SUNRISE_H + SUNSET_H) * 0.5
	var elevation: PackedVector2Array = PackedVector2Array()
	var azimuth: PackedVector2Array = PackedVector2Array()
	for step: int in 49:
		var h: float = step * 0.5
		var above: float
		if h >= SUNRISE_H and h <= SUNSET_H:
			above = asin(NOON_SIN_ELEVATION * sin(PI * (h - SUNRISE_H) / day_length))
		else:
			var night: float = fposmod(h - SUNSET_H, 24.0)
			above = -asin(NOON_SIN_ELEVATION * sin(PI * night / (24.0 - day_length)))
		elevation.append(Vector2(h, rad_to_deg(above)))
		azimuth.append(Vector2(h, 180.0 + SUNRISE_AZIMUTH_FROM_SOUTH * (h - noon) / (day_length * 0.5)))
	# The horizon exactly at sunrise and sunset (off the half-hour grid).
	elevation.append(Vector2(SUNRISE_H, 0.0))
	elevation.append(Vector2(SUNSET_H, 0.0))
	curves.sun_elevation = _curve(elevation, -90.0, 90.0)
	curves.sun_azimuth = _curve(azimuth, 0.0, 360.0)
	curves.sun_disc = _curve(PackedVector2Array([Vector2(0.0, 2.4), Vector2(24.0, 2.4)]), 0.0, 45.0)

	var sun_in: float = SUNRISE_H + ROOF_DELAY_H
	var sun_out: float = SUNSET_H - ROOF_DELAY_H
	curves.sun_intensity = _curve(PackedVector2Array([
			Vector2(0.0, 0.0), Vector2(sun_in, 0.0), Vector2(sun_in + 1.0, 3000.0),
			Vector2(sun_out - 1.0, 3000.0), Vector2(sun_out, 0.0), Vector2(24.0, 0.0)]), 0.0, 100000.0)
	curves.sun_color = _gradient({
			0.0: Color(1.0, 0.55, 0.38), sun_in: Color(1.0, 0.55, 0.38),
			9.5: Color(1.0, 0.9, 0.76), 15.0: Color(1.0, 0.9, 0.76),
			sun_out: Color(1.0, 0.45, 0.18), 24.0: Color(1.0, 0.45, 0.18)})

	curves.sky_color = _gradient({
			0.0: Color("#475cbd"), 5.7: Color("#4d5ebf"), 6.9: Color("#d999b3"),
			7.8: Color("#d9cce0"), 10.5: Color("#cce0ff"), 12.5: Color("#cce0ff"),
			14.5: Color("#d9d9f2"), 17.1: Color("#e69e9e"), 18.1: Color("#8073cc"),
			19.1: Color("#4a5cbd"), 24.0: Color("#475cbd")})
	curves.sky_intensity = _curve(PackedVector2Array([
			Vector2(0.0, 6.0), Vector2(SUNRISE_H - 0.7, 6.0), Vector2(SUNRISE_H, 300.0),
			Vector2(8.5, 1000.0), Vector2(noon, 1200.0), Vector2(16.5, 1000.0),
			Vector2(SUNSET_H, 300.0), Vector2(SUNSET_H + 0.7, 6.0), Vector2(24.0, 6.0)]), 0.0, 100000.0)

	curves.ambient_color = _gradient({
			0.0: Color("#3d426b"), 6.9: Color("#6b5766"), 7.8: Color("#a89494"),
			10.5: Color("#f2f5fa"), 12.5: Color("#ffffff"), 14.5: Color("#e6dedb"),
			17.1: Color("#f29e6b"), 18.1: Color("#61577a"), 19.1: Color("#424570"),
			24.0: Color("#3d426b")})
	curves.ambient_intensity = _curve(PackedVector2Array([
			Vector2(0.0, 3.0), Vector2(SUNRISE_H - 0.7, 3.0), Vector2(SUNRISE_H, 40.0),
			Vector2(noon, 150.0), Vector2(SUNSET_H, 40.0), Vector2(SUNSET_H + 0.7, 3.0),
			Vector2(24.0, 3.0)]), 0.0, 100000.0)

	# No game1 cloud hack (cheat sheet, section 5): clear all day, the pattern is up to a critic.
	curves.cloud_cover = _curve(PackedVector2Array([Vector2(0.0, 0.0), Vector2(24.0, 0.0)]), 0.0, 1.0)

	# Scene EV → white point EV: day about 0.85 albedo, dusk about 0.4, city night about 0.18.
	var exposure: Curve = _curve(PackedVector2Array([
			Vector2(0.0, 4.0), Vector2(4.5, 7.0), Vector2(8.0, 9.55), Vector2(11.0, 11.2),
			Vector2(16.0, 15.0)]), 0.0, 20.0)
	exposure.max_domain = 16.0
	curves.exposure = exposure
	return curves


## A polyline curve (linear tangents) over 0–24 h unless the points reach further.
func _curve(points: PackedVector2Array, low: float, high: float) -> Curve:
	var curve: Curve = Curve.new()
	curve.min_value = low
	curve.max_value = high
	curve.max_domain = maxf(24.0, points[points.size() - 1].x)
	for point: Vector2 in points:
		curve.add_point(point, 0.0, 0.0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	return curve


## A gradient over the day: hour → colour.
func _gradient(points: Dictionary[float, Color]) -> Gradient:
	var gradient: Gradient = Gradient.new()
	var offsets: PackedFloat32Array = PackedFloat32Array()
	var colors: PackedColorArray = PackedColorArray()
	for hour: float in points:
		offsets.append(hour / 24.0)
		colors.append(points[hour])
	gradient.offsets = offsets
	gradient.colors = colors
	return gradient


func _sky(color: Color, intensity: float) -> SkyProfile:
	var sky: SkyProfile = SkyProfile.new()
	sky.night_color = color
	sky.night_intensity = intensity
	return sky


## Cheat sheet 4.2 and 4.3: one A′ for both (half-stop levels, a 3 px Bayer seam, research 84; short
## steps dithered all along up to 24 px, research 92);
## interiors with half-bright window patches (t31) and dust, outdoors without dust.
func _tuning_set(label: String) -> TuningSet:
	var tuning_set: TuningSet = TuningSet.new()
	tuning_set.label = label
	tuning_set.style_mode = TuningSet.StyleMode.SUM
	tuning_set.level_stops = 0.5
	tuning_set.seam_px = 3.0
	tuning_set.full_dither_px = 24.0
	# Human, 2026-11-16: sky light smooth (B); levels on it (A) made rings without logic, dither (C) looked weak.
	tuning_set.sky_style = TuningSet.SkyStyle.SMOOTH
	tuning_set.seam_pattern = TuningSet.SeamPattern.BAYER
	tuning_set.anchor_ev = 0.0
	tuning_set.penumbra_gain = 1.0
	tuning_set.penumbra_max_px = 8.0
	tuning_set.shaft_strength = 1.0
	tuning_set.shaft_style = TuningSet.ScatterStyle.DITHER
	tuning_set.shaft_seam_px = 3.0
	tuning_set.dust_threshold = 1.0
	tuning_set.dust_motion = 0.05
	var interior: bool = label == "interior"
	tuning_set.window_patch_strength = 0.5 if interior else 1.0
	tuning_set.dust_density = 75.0 if interior else 0.0
	return tuning_set


## Cheat sheet 4.4, street lamp: #ffa357, 60 lx on the ground under a bulb 4 m up, reaching 14 m; off
## about 8:00, on gradually at dusk (the sun goes behind the roofs at 17:36, sets at 18:06).
func _street_lamp() -> SourceProfile:
	return _source_profile(Color("#ffa357"), _hours(60.0, [Vector2(7.6, 8.0), Vector2(17.3, 18.1)]),
			_inverse_square(4.0, 4.0, 14.0))


## Cheat sheet 4.4, wall sconce over the shop door: #ffa357, 100 lx 2.5 m below it; on all day (the
## shop is open, its light adds to the sun's).
func _wall_lamp() -> SourceProfile:
	return _source_profile(Color("#ffa357"), _hours(100.0, []), _inverse_square(2.5, 4.0, 8.0))


## Cheat sheet 4.4, a lit window seen from the street: warm, reaching 6 m; lit in the evening and
## early morning, dark after half past eleven. 40 lx 1 m in front of it and on its glass (brighter
## glass burnt out flat at night).
func _lit_window() -> SourceProfile:
	return _source_profile(Color("#ffb870"),
			_hours(40.0, [Vector2(5.5, 6.0), Vector2(7.5, 8.0), Vector2(16.8, 17.6), Vector2(23.0, 23.5)], false),
			_inverse_square(1.0, 1.0, 6.0))


func _source_profile(color: Color, intensity: Curve, falloff: Curve) -> SourceProfile:
	var profile: SourceProfile = SourceProfile.new()
	profile.channel = SourceProfile.Channel.ARTIFICIAL
	profile.color = _gradient({0.0: color, 24.0: color})
	profile.intensity = intensity
	profile.falloff = falloff
	return profile


## `lux` switched in turn over the given ramps (from, to hours), on at midnight or off; no ramps:
## always as at midnight.
func _hours(lux: float, ramps: Array[Vector2], on_at_midnight: bool = true) -> Curve:
	var on: bool = on_at_midnight
	var points: PackedVector2Array = PackedVector2Array([Vector2(0.0, lux if on else 0.0)])
	for ramp: Vector2 in ramps:
		points.append(Vector2(ramp.x, lux if on else 0.0))
		on = not on
		points.append(Vector2(ramp.y, lux if on else 0.0))
	points.append(Vector2(24.0, lux if on else 0.0))
	return _curve(points, 0.0, 100000.0)


## Light falling with the square of the distance, 1 at `reference_m`, at most `cap` near the source,
## eased to 0 at `reach_m` (so the layer can stop there).
func _inverse_square(reference_m: float, cap: float, reach_m: float) -> Curve:
	var points: PackedVector2Array = PackedVector2Array()
	for step: int in 33:
		var distance: float = reach_m * step / 32.0
		var square: float = minf(pow(reference_m / maxf(distance, 0.001), 2.0), cap)
		var ease: float = pow(1.0 - pow(distance / reach_m, 4.0), 2.0)
		points.append(Vector2(distance, square * ease))
	var curve: Curve = _curve(points, 0.0, cap)
	curve.max_domain = reach_m
	return curve
