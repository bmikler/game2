extends GutTest
## The engine knows neither the rest of style-lab nor any scene: it moves into the game by copying
## its folder.

const ENGINE: String = "res://addons/swiatlo"
const EXTENSIONS: PackedStringArray = ["gd", "gdshader", "gdshaderinc", "tres", "tscn", "cfg", "md"]
## Names of Poligons, their sections and rooms (GLOSSARY, spec "Nowe Poligony"), Polish and English.
const SCENE_NAMES: String = "\\b(poligon\\w*|ulic\\w*|uliczk\\w*|sklep\\w*|skwer\\w*|dom|salon\\w*" \
		+ "|kuchni\\w*|pracowni\\w*|street\\w*|alley\\w*|shop\\w*|square\\w*|house\\w*|living_room" \
		+ "|kitchen\\w*|studio\\w*)\\b"


func _collect(folder: String, found: PackedStringArray) -> void:
	for file: String in DirAccess.get_files_at(folder):
		if file.get_extension() in EXTENSIONS:
			found.append(folder.path_join(file))
	for subfolder: String in DirAccess.get_directories_at(folder):
		_collect(folder.path_join(subfolder), found)


func _engine_files() -> PackedStringArray:
	var found: PackedStringArray = PackedStringArray()
	_collect(ENGINE, found)
	return found


func test_engine_has_files() -> void:
	assert_gt(_engine_files().size(), 5)


func test_res_paths_point_only_into_the_engine() -> void:
	var path: RegEx = RegEx.create_from_string("res://[^\"'\\s)]*")
	for file: String in _engine_files():
		var text: String = FileAccess.get_file_as_string(file)
		for hit: RegExMatch in path.search_all(text):
			assert_true(hit.get_string().begins_with(ENGINE + "/"), "%s refers to %s" % [file, hit.get_string()])


func test_no_style_lab_and_no_scene_names() -> void:
	var scenes: RegEx = RegEx.create_from_string("(?i)" + SCENE_NAMES)
	for file: String in _engine_files():
		var text: String = FileAccess.get_file_as_string(file)
		assert_false(text.containsn("style-lab"), "%s mentions style-lab" % file)
		var hit: RegExMatch = scenes.search(text)
		assert_null(hit, "%s knows a scene: %s" % [file, hit.get_string() if hit else ""])
