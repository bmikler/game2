class_name SceneDescription
extends RefCounted
## The scene description: what the light buffer needs from a Location's contract nodes, in metres.
## Pure logic (no GPU): the solids, the receivers (every solid face the projection shows) and the
## buffer area (screen pixels covering every solid).

## Solids in metres (x right, d towards the camera, z up).
var solids: Array[SolidShape] = []
var receivers: Array[Receiver] = []
## Screen pixels relative to the Location's origin; empty without solids.
var area: Rect2i = Rect2i()


static func from_shapes(shapes: Array[SolidShape], projection: LightProjection) -> SceneDescription:
	var description: SceneDescription = SceneDescription.new()
	description.solids = shapes.duplicate()
	var toward_camera: Vector3 = projection.toward_camera()
	if shapes.is_empty():
		return description
	var bounds: Rect2 = Rect2(projection.to_screen(shapes[0].box.position), Vector2.ZERO)
	for index: int in shapes.size():
		var shape: SolidShape = shapes[index]
		for receiver: Receiver in shape.faces(index):
			if receiver.normal.dot(toward_camera) > 0.0:
				description.receivers.append(receiver)
		for corner: int in 8:
			var point: Vector2 = projection.to_screen(shape.box.get_endpoint(corner))
			bounds = bounds.expand(point)
	var top_left: Vector2i = Vector2i(bounds.position.floor())
	description.area = Rect2i(top_left, Vector2i(bounds.end.ceil()) - top_left)
	return description


## Plain boxes (tests and stand-in drawings).
static func from_boxes(boxes: Array[AABB], projection: LightProjection) -> SceneDescription:
	var shapes: Array[SolidShape] = []
	for box: AABB in boxes:
		shapes.append(SolidShape.make_box(box))
	return from_shapes(shapes, projection)


## Collects the solids of every Occluder in the tree.
static func from_tree(tree: SceneTree, projection: LightProjection) -> SceneDescription:
	var shapes: Array[SolidShape] = []
	for node: Node in tree.get_nodes_in_group(Occluder.GROUP):
		shapes.append_array((node as Occluder).world_shapes())
	return from_shapes(shapes, projection)


## Solids for the shaders: two RGBAF texels each, (min, kind) and (max, eave); one texel when
## there are none.
func solid_data() -> Image:
	var texels: PackedColorArray = PackedColorArray()
	for shape: SolidShape in solids:
		texels.append(_texel(shape.box.position, shape.kind))
		texels.append(_texel(shape.box.end, shape.eave))
	return _row(texels)


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


static func _texel(value: Vector3, alpha: float) -> Color:
	return Color(value.x, value.y, value.z, alpha)


static func _row(texels: PackedColorArray) -> Image:
	var image: Image = Image.create_empty(maxi(texels.size(), 1), 1, false, Image.FORMAT_RGBAF)
	for index: int in texels.size():
		image.set_pixel(index, 0, texels[index])
	return image
