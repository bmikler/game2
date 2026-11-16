extends GutTest
## The LocationEnvironment contract node and how the engine reads it.


func test_environment_joins_the_contract_group() -> void:
	var environment: LocationEnvironment = LocationEnvironment.new()
	add_child_autofree(environment)
	assert_true(environment.is_in_group(LocationEnvironment.GROUP))


func test_environment_has_a_default_tuning_set_and_sky() -> void:
	var environment: LocationEnvironment = LocationEnvironment.new()
	autofree(environment)
	assert_not_null(environment.tuning_set)
	assert_not_null(environment.sky)
	assert_eq(environment.air_density, 0.0)
	assert_gt(environment.exposure_reference, 0.0)


func test_changing_a_field_emits_changed() -> void:
	var environment: LocationEnvironment = LocationEnvironment.new()
	autofree(environment)
	watch_signals(environment)
	environment.air_density = 0.3
	assert_signal_emitted(environment, "changed")


func test_engine_warns_without_an_environment() -> void:
	var engine: LightEngine = LightEngine.new()
	add_child_autofree(engine)
	assert_false(engine.warnings().is_empty())


func test_engine_reads_the_sky_from_the_environment() -> void:
	var environment: LocationEnvironment = LocationEnvironment.new()
	environment.sky = load("res://addons/swiatlo/tuning/sky_village.tres") as SkyProfile
	add_child_autofree(environment)
	var engine: LightEngine = LightEngine.new()
	add_child_autofree(engine)
	assert_true(engine.warnings().is_empty())
	assert_eq(engine.sky(), environment.sky)


func test_hour_and_rate_move_time_on() -> void:
	var engine: LightEngine = LightEngine.new()
	add_child_autofree(engine)
	engine.set_hour(10.0)
	engine.rate = 1.0 # a game minute per second: 30 s is half an hour
	engine.advance(30.0)
	assert_almost_eq(engine.hour, 10.5, 0.0001)
	assert_almost_eq(engine.state().hour, 10.5, 0.0001)


func test_engine_takes_the_exposure_reference_from_the_environment() -> void:
	var environment: LocationEnvironment = LocationEnvironment.new()
	add_child_autofree(environment)
	var engine: LightEngine = LightEngine.new()
	add_child_autofree(engine)
	engine.set_hour(12.5)
	var outside: float = engine.state().exposure
	environment.exposure_reference = 0.1
	assert_gt(engine.state().exposure, outside)


func test_style_mode_comes_from_the_tuning_set_until_switched() -> void:
	var environment: LocationEnvironment = LocationEnvironment.new()
	environment.tuning_set = TuningSet.new()
	environment.tuning_set.style_mode = TuningSet.StyleMode.PER_CHANNEL
	add_child_autofree(environment)
	var engine: LightEngine = LightEngine.new()
	add_child_autofree(engine)
	assert_eq(engine.style_mode(), TuningSet.StyleMode.PER_CHANNEL)
	engine.set_style_mode(TuningSet.StyleMode.SUM)
	assert_eq(engine.style_mode(), TuningSet.StyleMode.SUM)
	assert_eq(environment.tuning_set.style_mode, TuningSet.StyleMode.PER_CHANNEL, "the set itself stays")
