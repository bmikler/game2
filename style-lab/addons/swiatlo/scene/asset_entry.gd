class_name AssetEntry
extends RefCounted
## An asset in the scene description: its sprite on screen and the range of its (invisible) solids in
## the description's `solids`. A sprite pixel lies where its line of sight leaves the asset's solids
## nearest the camera; a pixel with no solid there rests by one rule (`rest_point`), the same in the
## light buffer's shaders (`surfaces.gdshaderinc`).

var sprite: Texture2D
## Null: the sprite's pixels take the normals of the solids' faces.
var normal_map: Texture2D
## The sprite's top-left pixel on screen, relative to the Location's origin.
var top_left_px: Vector2i
## The asset's anchor in the Location's metres.
var anchor_m: Vector3
var first_solid: int
var solid_count: int
## The front plane of the outline of all the asset's solids (the largest d).
var front_d: float


## The entry for an asset Occluder whose solids `own` start at `first` in the description's solids.
static func from_occluder(occluder: Occluder, sprite_node: AssetSprite, own: Array[SolidShape], first: int) -> AssetEntry:
	var entry: AssetEntry = AssetEntry.new()
	entry.sprite = sprite_node.texture
	entry.normal_map = sprite_node.normal_map
	entry.top_left_px = sprite_node.top_left_px()
	entry.anchor_m = occluder.position_m
	entry.first_solid = first
	entry.solid_count = own.size()
	entry.front_d = -INF
	for shape: SolidShape in own:
		entry.front_d = maxf(entry.front_d, shape.box.end.y)
	return entry


## Where a sprite pixel with no solid face beneath it rests (`screen_m`: the pixel's middle on screen
## in metres). Above the top of one of the asset's solids (the highest, when there are several): on
## the upright plane halfway through that top's depth (a jar on a counter). Anything else (a throw
## hanging beside, a gap between solids): on the front plane of the outline of all the solids.
func rest_point(screen_m: Vector2, solids: Array[SolidShape], depth_factor: float) -> Vector3:
	var best_top: float = -INF
	var plane_d: float = front_d
	for index: int in range(first_solid, first_solid + solid_count):
		var box: AABB = solids[index].box
		if screen_m.x < box.position.x or screen_m.x > box.end.x:
			continue
		var middle_d: float = box.position.y + box.size.y * 0.5
		if middle_d * depth_factor - screen_m.y >= box.end.z and box.end.z > best_top:
			best_top = box.end.z
			plane_d = middle_d
	return Vector3(screen_m.x, plane_d, plane_d * depth_factor - screen_m.y)
