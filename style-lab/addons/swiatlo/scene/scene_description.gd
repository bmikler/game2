class_name SceneDescription
extends RefCounted
## The scene description: what the light buffer needs from a Location's contract nodes, in metres.
## Pure logic (no GPU): the solids, the receivers (every solid face the projection shows) and the
## buffer area (screen pixels covering every solid).

## Solids as boxes in metres (x right, d towards the camera, z up).
var solids: Array[AABB] = []
var receivers: Array[Receiver] = []
## Screen pixels relative to the Location's origin; empty without solids.
var area: Rect2i = Rect2i()


static func from_boxes(boxes: Array[AABB], projection: LightProjection) -> SceneDescription:
	var description: SceneDescription = SceneDescription.new()
	description.solids = boxes.duplicate()
	var toward_camera: Vector3 = projection.toward_camera()
	if boxes.is_empty():
		return description
	var bounds: Rect2 = Rect2(projection.to_screen(boxes[0].position), Vector2.ZERO)
	for index: int in boxes.size():
		var box: AABB = boxes[index]
		for receiver: Receiver in _faces(box, index):
			if receiver.normal.dot(toward_camera) > 0.0:
				description.receivers.append(receiver)
		for corner: int in 8:
			var point: Vector2 = projection.to_screen(box.get_endpoint(corner))
			bounds = bounds.expand(point)
	var top_left: Vector2i = Vector2i(bounds.position.floor())
	description.area = Rect2i(top_left, Vector2i(bounds.end.ceil()) - top_left)
	return description


## The six faces of a box, normals outwards.
static func _faces(box: AABB, solid: int) -> Array[Receiver]:
	var faces: Array[Receiver] = []
	for axis: int in 3:
		var u_axis: int = (axis + 1) % 3
		var v_axis: int = (axis + 2) % 3
		var u: Vector3 = Vector3.ZERO
		u[u_axis] = box.size[u_axis]
		var v: Vector3 = Vector3.ZERO
		v[v_axis] = box.size[v_axis]
		for side: int in 2:
			var origin: Vector3 = box.position
			origin[axis] += box.size[axis] * side
			var normal: Vector3 = Vector3.ZERO
			normal[axis] = 1.0 if side == 1 else -1.0
			faces.append(Receiver.new(origin, u, v, normal, solid))
	return faces


## Collects the solids of every Occluder in the tree.
static func from_tree(tree: SceneTree, projection: LightProjection) -> SceneDescription:
	var boxes: Array[AABB] = []
	for node: Node in tree.get_nodes_in_group(Occluder.GROUP):
		boxes.append_array((node as Occluder).world_boxes())
	return from_boxes(boxes, projection)


## Solids for the shaders: two RGBAF texels each (min, max); one texel when there are none.
func solid_data() -> Image:
	var texels: PackedColorArray = PackedColorArray()
	for box: AABB in solids:
		texels.append(_texel(box.position, 0.0))
		texels.append(_texel(box.end, 0.0))
	return _row(texels)


## Receivers for the shaders: three RGBAF texels each (origin, edge_u, edge_v; normal in alpha).
func receiver_data() -> Image:
	var texels: PackedColorArray = PackedColorArray()
	for receiver: Receiver in receivers:
		texels.append(_texel(receiver.origin, receiver.normal.x))
		texels.append(_texel(receiver.edge_u, receiver.normal.y))
		texels.append(_texel(receiver.edge_v, receiver.normal.z))
	return _row(texels)


static func _texel(value: Vector3, alpha: float) -> Color:
	return Color(value.x, value.y, value.z, alpha)


static func _row(texels: PackedColorArray) -> Image:
	var image: Image = Image.create_empty(maxi(texels.size(), 1), 1, false, Image.FORMAT_RGBAF)
	for index: int in texels.size():
		image.set_pixel(index, 0, texels[index])
	return image
