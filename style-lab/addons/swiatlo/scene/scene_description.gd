class_name SceneDescription
extends RefCounted
## The scene description: what the light buffer needs from a Location's contract nodes, in metres.
## Pure logic (no GPU): the solids, the receivers (every solid face the projection shows, except the
## faces of assets' solids: those are invisible, their sprites take the light), the assets and the
## buffer area (screen pixels covering every solid and sprite).

## Solids in metres (x right, d towards the camera, z up).
var solids: Array[SolidShape] = []
var receivers: Array[Receiver] = []
## Assets, far ones first (smaller anchor d), as their sprites overlap.
var assets: Array[AssetEntry] = []
## Screen pixels relative to the Location's origin; empty without solids.
var area: Rect2i = Rect2i()
## Light sources with a profile, each in its group.
var sources: Array[SourceEntry] = []
## One group per profile, in the order profiles first appear: one light buffer layer each.
var source_groups: Array[SourceProfile] = []
## Moving Occluders' solids and assets as of the last `refresh_moving` (every frame). In the shaders
## they follow the static ones: solids from `solids.size()`, assets from `assets.size() + 1`.
var moving_solids: Array[SolidShape] = []
var moving_assets: Array[AssetEntry] = []
## The silhouette stacks of every solid, static and moving, in the order of `silhouette_data`.
var silhouettes: Array[SilhouetteStack] = []

var _moving_nodes: Array[Occluder] = []
## What the moving solids and assets were at the last refresh (to tell a change).
var _moving_key: PackedFloat32Array = PackedFloat32Array()


## `assets` name their ranges in `shapes`; those solids get no receivers.
static func from_shapes(shapes: Array[SolidShape], projection: LightProjection,
		asset_entries: Array[AssetEntry] = []) -> SceneDescription:
	var description: SceneDescription = SceneDescription.new()
	description.solids = shapes.duplicate()
	description.assets = asset_entries.duplicate()
	description.assets.sort_custom(func(a: AssetEntry, b: AssetEntry) -> bool: return a.anchor_m.y < b.anchor_m.y)
	var invisible: Dictionary[int, bool] = {}
	for entry: AssetEntry in asset_entries:
		for index: int in range(entry.first_solid, entry.first_solid + entry.solid_count):
			invisible[index] = true
	var toward_camera: Vector3 = projection.toward_camera()
	if shapes.is_empty():
		return description
	var bounds: Rect2 = Rect2(projection.to_screen(shapes[0].box.position), Vector2.ZERO)
	for index: int in shapes.size():
		var shape: SolidShape = shapes[index]
		if not invisible.has(index):
			for receiver: Receiver in shape.faces(index):
				if receiver.normal.dot(toward_camera) > 0.0:
					description.receivers.append(receiver)
		for corner: int in 8:
			var point: Vector2 = projection.to_screen(shape.box.get_endpoint(corner))
			bounds = bounds.expand(point)
	for entry: AssetEntry in asset_entries:
		bounds = bounds.merge(Rect2(Vector2(entry.top_left_px), Vector2(entry.sprite.get_size())))
	var top_left: Vector2i = Vector2i(bounds.position.floor())
	description.area = Rect2i(top_left, Vector2i(bounds.end.ceil()) - top_left)
	return description


## Plain boxes (tests and stand-in drawings).
static func from_boxes(boxes: Array[AABB], projection: LightProjection) -> SceneDescription:
	var shapes: Array[SolidShape] = []
	for box: AABB in boxes:
		shapes.append(SolidShape.make_box(box))
	return from_shapes(shapes, projection)


## Collects the solids of every Occluder in the tree, the assets among them (Occluders with an
## AssetSprite holding a texture) and the light sources with a profile. Moving Occluders stay apart
## (`moving_solids`, `moving_assets`).
static func from_tree(tree: SceneTree, projection: LightProjection) -> SceneDescription:
	var shapes: Array[SolidShape] = []
	var asset_entries: Array[AssetEntry] = []
	var moving_nodes: Array[Occluder] = []
	for node: Node in tree.get_nodes_in_group(Occluder.GROUP):
		var occluder: Occluder = node as Occluder
		if occluder.moving:
			moving_nodes.append(occluder)
			continue
		var own: Array[SolidShape] = occluder.world_shapes()
		var sprite: AssetSprite = occluder.asset_sprite()
		if sprite != null and sprite.texture != null and not own.is_empty():
			asset_entries.append(AssetEntry.from_occluder(occluder, sprite, own, shapes.size()))
		shapes.append_array(own)
	var description: SceneDescription = from_shapes(shapes, projection, asset_entries)
	description._moving_nodes = moving_nodes
	for shape: SolidShape in shapes:
		description._add_silhouette(shape.silhouette)
	for occluder: Occluder in moving_nodes:
		for child: Node in occluder.get_children():
			var solid: Solid = child as Solid
			if solid != null and solid.shape == Solid.Shape.SILHOUETTE:
				description._add_silhouette(solid.silhouette)
	description.refresh_moving()
	for node: Node in tree.get_nodes_in_group(LightSource.GROUP):
		var source: LightSource = node as LightSource
		if source.profile != null:
			description.add_source(source.entry())
	return description


## Reads the moving Occluders again (where they stand, which frame); true when anything changed.
func refresh_moving() -> bool:
	moving_solids.clear()
	moving_assets.clear()
	var key: PackedFloat32Array = PackedFloat32Array()
	for occluder: Occluder in _moving_nodes:
		if not is_instance_valid(occluder) or not occluder.is_inside_tree():
			continue
		var own: Array[SolidShape] = occluder.world_shapes()
		var sprite: AssetSprite = occluder.asset_sprite()
		if sprite != null and sprite.texture != null and not own.is_empty():
			var entry: AssetEntry = AssetEntry.from_occluder(occluder, sprite, own, solids.size() + moving_solids.size())
			moving_assets.append(entry)
			key.append_array([entry.top_left_px.x, entry.top_left_px.y, sprite.texture.get_instance_id()])
		for shape: SolidShape in own:
			key.append_array([shape.kind, shape.frame, shape.box.position.x, shape.box.position.y, shape.box.position.z,
					shape.box.size.x, shape.box.size.y, shape.box.size.z])
		moving_solids.append_array(own)
	var changed: bool = key != _moving_key
	_moving_key = key
	return changed


func has_moving() -> bool:
	return not _moving_nodes.is_empty()


## Buffer pixels (relative to the buffer area) where a moving solid can change the light: its sprite
## and solids, the sky it hides (within `sky_reach_m`) and the shadows the sources in reach cast
## (projected from each source over the solid's top down to its feet' level), widened by `margin_px`,
## inside `view` (screen pixels of the Location; an empty rect: no limit). One rect per moving solid
## that touches the view.
func moving_windows(projection: LightProjection, sky_reach_m: float, margin_px: float, view: Rect2) -> Array[Rect2i]:
	var windows: Array[Rect2i] = []
	for shape: SolidShape in moving_solids:
		var box: AABB = shape.box
		var points: PackedVector3Array = PackedVector3Array()
		var wide: AABB = box.grow(sky_reach_m)
		wide.position.z = box.position.z
		wide.size.z = box.size.z
		for corner: int in 8:
			points.append(wide.get_endpoint(corner))
		for source: SourceEntry in sources:
			var reach: float = source.profile.reach_m()
			var extent: float = source.radius if source.kind == LightSource.Shape.SPHERE else (source.half_u + source.half_v).length()
			var nearest: Vector3 = source.centre.clamp(box.position, box.end)
			if source.centre.distance_to(nearest) - extent >= reach:
				continue
			for corner: int in 8:
				var top: Vector3 = box.get_endpoint(corner)
				if top.z < box.end.z:
					continue
				var way: Vector3 = top - source.centre
				var floor_at: Vector3
				if source.centre.z > top.z + 0.01:
					floor_at = source.centre + way * ((source.centre.z - box.position.z) / (source.centre.z - top.z))
				else:
					floor_at = top + Vector3(way.x, way.y, 0.0).normalized() * reach
				var flat: Vector3 = floor_at - source.centre
				flat.z = 0.0
				if flat.length() > reach + extent:
					floor_at = source.centre + flat.normalized() * (reach + extent)
					floor_at.z = box.position.z
				points.append(floor_at)
		var screen: Rect2 = Rect2(projection.to_screen(points[0]), Vector2.ZERO)
		for point: Vector3 in points:
			screen = screen.expand(projection.to_screen(point))
		screen = screen.grow(margin_px)
		if view.has_area():
			screen = screen.intersection(view)
		screen = screen.intersection(Rect2(area))
		if not screen.has_area():
			continue
		var top_left: Vector2i = Vector2i(screen.position.floor())
		windows.append(Rect2i(top_left - area.position, Vector2i(screen.end.ceil()) - top_left))
	return windows


## Adds a source to the group of its profile (a new group for a new profile).
func add_source(source: SourceEntry) -> void:
	source.group = source_groups.find(source.profile)
	if source.group < 0:
		source.group = source_groups.size()
		source_groups.append(source.profile)
	sources.append(source)


## Solids for the shaders: two RGBAF texels each, (min, kind) and (max, eave; a silhouette: its row in
## `silhouette_data`); one texel when there are none. The static solids only (the layers built once).
func solid_data() -> Image:
	return _row(_solid_texels(solids))


## The static solids followed by the moving ones (the layers drawn every frame).
func all_solid_data() -> Image:
	var texels: PackedColorArray = _solid_texels(solids)
	texels.append_array(_solid_texels(moving_solids))
	return _row(texels)


## Every silhouette stack's frames, one texel row per frame (SilhouetteStack.data_of).
func silhouette_data() -> Image:
	return SilhouetteStack.data_of(silhouettes)


func _solid_texels(shapes: Array[SolidShape]) -> PackedColorArray:
	var texels: PackedColorArray = PackedColorArray()
	for shape: SolidShape in shapes:
		texels.append(_texel(shape.box.position, shape.kind))
		var alpha: float = float(_silhouette_row(shape)) if shape.kind == SolidShape.Kind.SILHOUETTE else shape.eave
		texels.append(_texel(shape.box.end, alpha))
	return texels


## The texel row of a silhouette's frame in `silhouette_data`.
func _silhouette_row(shape: SolidShape) -> int:
	var row: int = 0
	for stack: SilhouetteStack in silhouettes:
		if stack == shape.silhouette:
			return row + clampi(shape.frame, 0, stack.frame_count() - 1)
		row += stack.frame_count()
	return 0


func _add_silhouette(stack: SilhouetteStack) -> void:
	if stack != null and not silhouettes.has(stack):
		silhouettes.append(stack)


## Receivers for the shaders: four RGBAF texels each, (origin, normal.x), (edge_u, normal.y),
## (edge_v, normal.z), (kind, height, 0, 0).
func receiver_data() -> Image:
	var texels: PackedColorArray = PackedColorArray()
	for receiver: Receiver in receivers:
		texels.append(_texel(receiver.origin, receiver.normal.x))
		texels.append(_texel(receiver.edge_u, receiver.normal.y))
		texels.append(_texel(receiver.edge_v, receiver.normal.z))
		texels.append(Color(receiver.kind, receiver.height, 0.0, 0.0))
	return _row(texels)


## Assets for the shaders, one RGBAF texel each in the order of `assets` (the asset layer's numbers
## count from 1 in that order): (first solid, solid count, front d, 0).
func asset_data() -> Image:
	return _row(_asset_texels(assets))


## The static assets followed by the moving ones (numbers from `assets.size() + 1`).
func all_asset_data() -> Image:
	var texels: PackedColorArray = _asset_texels(assets)
	texels.append_array(_asset_texels(moving_assets))
	return _row(texels)


static func _asset_texels(entries: Array[AssetEntry]) -> PackedColorArray:
	var texels: PackedColorArray = PackedColorArray()
	for entry: AssetEntry in entries:
		texels.append(Color(entry.first_solid, entry.solid_count, entry.front_d, 0.0))
	return texels


## Light sources for the shaders: four RGBAF texels each, (centre, kind), (half_u, radius),
## (half_v, group), (normal, 0).
func source_data() -> Image:
	var texels: PackedColorArray = PackedColorArray()
	for source: SourceEntry in sources:
		texels.append(_texel(source.centre, source.kind))
		texels.append(_texel(source.half_u, source.radius))
		texels.append(_texel(source.half_v, source.group))
		texels.append(_texel(source.normal, 0.0))
	return _row(texels)


static func _texel(value: Vector3, alpha: float) -> Color:
	return Color(value.x, value.y, value.z, alpha)


static func _row(texels: PackedColorArray) -> Image:
	var image: Image = Image.create_empty(maxi(texels.size(), 1), 1, false, Image.FORMAT_RGBAF)
	for index: int in texels.size():
		image.set_pixel(index, 0, texels[index])
	return image
