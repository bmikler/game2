extends GutTest
## The day sweep gate (engine ticket 29): the street Poligon's day every 10 minutes, checked in
## numbers by DaySweep (monotonic day, standing source bands, local changes, no pulsing). Red with
## the hour, the place (Location pixels) and what happened. Takes about half a minute.

const SCENE: String = "res://engine_poligons/street/poligon_street.tscn"
## 144 frames a day.
const STEP_MIN: int = 10
## Every 4th buffer pixel each way: a lamp's band is tens of pixels wide and a shadow's seam runs
## along a long edge, so both are still sampled.
const STRIDE: int = 4
## Findings known and ticketed: reported, not failing. A rule leaves this list with its ticket.
const KNOWN: Dictionary[String, String] = {}
## The last sweep, to try the rules again without sweeping the day (DaySweep.load_from).
const SAVED_SWEEP: String = "user://day_sweep_street.bin"


func test_gate_the_street_day_has_no_waves_jumps_or_pulsing() -> void:
	var started: int = Time.get_ticks_msec()
	var poligon: Node = (load(SCENE) as PackedScene).instantiate()
	add_child_autofree(poligon)
	var engine: LightEngine = poligon.get_node("%Engine") as LightEngine
	engine.rate = 0.0
	assert_eq(engine.tuning_set().sky_style, TuningSet.SkyStyle.SMOOTH,
			"the sweep reads the levels under a smooth sky (B); other sky styles put the sky on levels too")
	while not engine.is_complete():
		await RenderingServer.frame_post_draw
	var sampler: DaySweepSampler = DaySweepSampler.new()
	add_child_autofree(sampler)
	var sweep: DaySweep = DaySweep.new()
	sweep.prepare(engine.buffer_area().size, engine.buffer_area().position, STRIDE)
	for minute: int in range(0, 24 * 60, STEP_MIN):
		engine.set_hour(minute / 60.0)
		await RenderingServer.frame_post_draw
		await sampler.sample(engine, sweep)
	sweep.save(SAVED_SWEEP)
	var report: PackedStringArray = PackedStringArray()
	var known: Dictionary[String, int] = {}
	for finding: DaySweep.Finding in sweep.check():
		if KNOWN.has(finding.rule):
			known[finding.rule] = known.get(finding.rule, 0) + 1
		else:
			report.append(str(finding))
	for rule: String in known:
		gut.p("known: %d × %s, %s" % [known[rule], rule, KNOWN[rule]])
	gut.p("day sweep: %d frames in %d s" % [sweep.frames.size(), (Time.get_ticks_msec() - started) / 1000])
	assert_eq(report.size(), 0, "\n".join(report))
