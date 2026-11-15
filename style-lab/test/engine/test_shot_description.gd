extends GutTest
## The shot description: the state behind a PNG, saved next to it and read back for a replay.

const FOLDER: String = "user://test_shot_description"


func _description() -> ShotDescription:
	var description: ShotDescription = ShotDescription.new()
	description.scene = "res://somewhere/location.tscn"
	description.hour = 7.5123456789
	description.rate = 2.0
	description.variant = ""
	description.has_character = true
	description.character = Vector2(12.5, -40.0)
	description.switches = {"kadr": "640×360", "niebo": "wieś"}
	return description


func test_saved_description_reads_back_the_same() -> void:
	DirAccess.make_dir_recursive_absolute(FOLDER)
	var png: String = FOLDER.path_join("shot.png")
	assert_eq(_description().save_next_to(png), OK)
	var read: ShotDescription = ShotDescription.load_next_to(png)
	assert_not_null(read)
	assert_eq(read.scene, "res://somewhere/location.tscn")
	assert_eq(read.hour, 7.5123456789, "the hour keeps full precision")
	assert_eq(read.rate, 2.0)
	assert_true(read.has_character)
	assert_eq(read.character, Vector2(12.5, -40.0))
	assert_eq(read.switches, {"kadr": "640×360", "niebo": "wieś"})
	assert_true(read.matches(_description()))


func test_description_without_a_character_reads_back_without_one() -> void:
	DirAccess.make_dir_recursive_absolute(FOLDER)
	var png: String = FOLDER.path_join("no_character.png")
	var description: ShotDescription = _description()
	description.has_character = false
	description.save_next_to(png)
	assert_false(ShotDescription.load_next_to(png).has_character)


func test_description_text_shows_the_time_for_people() -> void:
	assert_string_contains(_description().to_json(), "\"time\": \"07:30\"")


func test_missing_description_reads_as_null() -> void:
	assert_null(ShotDescription.load_next_to(FOLDER.path_join("nothing_here.png")))


func test_replay_argument_is_found_among_user_arguments() -> void:
	assert_eq(ShotDescription.replay_path(PackedStringArray(["--wyjdz", "--z-zrzutu=C:/shots/a.png"])), "C:/shots/a.png")
	assert_eq(ShotDescription.replay_path(PackedStringArray(["--wyjdz"])), "")
