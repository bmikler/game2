class_name GuidesImport
extends RefCounted
## Reads the export of the Blender guides tool (Prowadnice v2, `bryly.json`) into contract nodes: the
## asset's solids in metres relative to its anchor and the anchor's pixel in the sprite. The export's
## keys are Polish (its file format); its y grows away from the camera, the engine's d towards it.

## Solid types of the export.
const TYPE_BOX: String = "pudelko"
const TYPE_RAISED: String = "uniesione"
const TYPE_CYLINDER: String = "walec"


## The export's solids as Solid nodes (not yet in a tree).
static func solids(json_text: String) -> Array[Solid]:
	var found: Array[Solid] = []
	var data: Dictionary = _parse(json_text)
	var items: Array = data.get("bryly", [])
	for item: Variant in items:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = item
		var low: Vector3 = _vector(entry.get("min", []))
		var high: Vector3 = _vector(entry.get("max", []))
		var solid_name: String = str(entry.get("nazwa", "Solid"))
		var solid_type: String = str(entry.get("typ", ""))
		var solid: Solid = Solid.new()
		solid.name = solid_name.validate_node_name()
		solid.position_m = Vector3((low.x + high.x) * 0.5, -low.y, 0.0)
		solid.size_m = Vector3(high.x - low.x, high.y - low.y, high.z)
		match solid_type:
			TYPE_BOX:
				solid.shape = Solid.Shape.BOX
			TYPE_RAISED:
				solid.shape = Solid.Shape.RAISED_BOX
				solid.clearance_m = low.z
			TYPE_CYLINDER:
				solid.shape = Solid.Shape.CYLINDER
			var unknown:
				push_warning("Guides import: unknown solid type %s, skipped" % unknown)
				solid.free()
				continue
		found.append(solid)
	return found


## The anchor in the sprite (pixels from its top-left, a pixel's corner).
static func anchor_px(json_text: String) -> Vector2i:
	var anchor: Array = _parse(json_text).get("zaczepienie_gra", [0, 0])
	if anchor.size() != 2:
		return Vector2i.ZERO
	return Vector2i(str(anchor[0]).to_int(), str(anchor[1]).to_int())


## An asset: an Occluder with the export's solids and an AssetSprite (normal map optional).
static func build(json_text: String, sprite: Texture2D, normal_map: Texture2D) -> Occluder:
	var asset: Occluder = Occluder.new()
	for solid: Solid in solids(json_text):
		asset.add_child(solid)
	var asset_sprite: AssetSprite = AssetSprite.new()
	asset_sprite.name = "Sprite"
	asset_sprite.texture = sprite
	asset_sprite.normal_map = normal_map
	asset_sprite.anchor_px = anchor_px(json_text)
	asset.add_child(asset_sprite)
	return asset


static func _parse(json_text: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(json_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Guides import: not a guides export")
		return {}
	var data: Dictionary = parsed
	return data


static func _vector(raw: Variant) -> Vector3:
	if typeof(raw) != TYPE_ARRAY:
		return Vector3.ZERO
	var values: Array = raw
	if values.size() != 3:
		return Vector3.ZERO
	return Vector3(str(values[0]).to_float(), str(values[1]).to_float(), str(values[2]).to_float())
