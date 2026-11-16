extends SceneTree
## Builds an asset scene (.tscn) from a Blender guides export (`bryly.json`): an Occluder with the
## export's solids and an AssetSprite with the sprite, the optional normal map and the anchor. The
## textures must already be imported (run the project's --import first). Run from style-lab:
##   Godot_..._console.exe --headless --path . -s res://tools/light_engine/build_asset_scene.gd -- \
##       <bryly.json> <res:// sprite> <res:// normal map or -> <res:// output .tscn>


func _init() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() != 4:
		push_error("Usage: -- <bryly.json> <sprite> <normal map or -> <output .tscn>")
		quit(1)
		return
	var sprite: Texture2D = load(args[1])
	var normal_map: Texture2D = null if args[2] == "-" else load(args[2])
	var asset: Occluder = GuidesImport.build(FileAccess.get_file_as_string(args[0]), sprite, normal_map)
	asset.name = args[3].get_file().get_basename().to_pascal_case()
	for child: Node in asset.get_children():
		child.owner = asset
	var sprite_node: AssetSprite = asset.asset_sprite()
	for warning: String in sprite_node.warnings():
		push_warning("%s: %s" % [args[3], warning])
	var scene: PackedScene = PackedScene.new()
	var error: Error = scene.pack(asset)
	if error == OK:
		error = ResourceSaver.save(scene, args[3])
	asset.free()
	if error != OK:
		push_error("Cannot save %s: %s" % [args[3], error_string(error)])
		quit(1)
		return
	print("asset scene: %s" % args[3])
	quit()
