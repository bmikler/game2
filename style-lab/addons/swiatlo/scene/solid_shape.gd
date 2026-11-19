class_name SolidShape
extends RefCounted
## One solid in the Location's metres, as the light engine sees it (pure data, no node): a box, a box
## with a gable roof whose slopes fall along x or along d, an upright cylinder, or a silhouette (a
## stack of elliptic slabs from a sprite frame, SilhouetteStack). A raised box is a box that starts
## above the floor. Every shape but the silhouette is convex and fills its bounding box's footprint.

## The numbers go to the shaders as they are (`visibility.gdshaderinc`, SOLID_*).
enum Kind { BOX, ROOF_X, ROOF_D, CYLINDER, SILHOUETTE }

## Segments of a cylinder's outline in the wireframe and the stand-in drawing (a half circle).
const OUTLINE_SEGMENTS: int = 12

var kind: Kind = Kind.BOX
## The bounding box (x right, d towards the camera, z up); a roof's ridge is at its top.
var box: AABB = AABB()
## Roofs: the height where the walls end and the slopes start (absolute z).
var eave: float = 0.0
## Silhouette only: its stack and the frame shown.
var silhouette: SilhouetteStack
var frame: int = 0


static func make_box(bounds: AABB) -> SolidShape:
	return _make(Kind.BOX, bounds, bounds.end.z)


## A box with a gable roof: walls up to `eave_z`, slopes falling along x (ROOF_X, ridge along d) or
## along d (ROOF_D, ridge along x) from the ridge at the top of `bounds`. Without a rise it is a box.
static func make_roof(along_d: bool, bounds: AABB, eave_z: float) -> SolidShape:
	if eave_z >= bounds.end.z or eave_z <= bounds.position.z:
		return make_box(bounds)
	return _make(Kind.ROOF_D if along_d else Kind.ROOF_X, bounds, eave_z)


## An upright cylinder (elliptic when width and depth differ) filling `bounds`.
static func make_cylinder(bounds: AABB) -> SolidShape:
	return _make(Kind.CYLINDER, bounds, bounds.end.z)


## The stack's frame standing on `anchor` (the middle of the feet, metres).
static func make_silhouette(stack: SilhouetteStack, stack_frame: int, anchor: Vector3) -> SolidShape:
	var bounds: AABB = stack.frame_bounds(stack_frame)
	var shape: SolidShape = _make(Kind.SILHOUETTE, AABB(bounds.position + anchor, bounds.size), bounds.end.z + anchor.z)
	shape.silhouette = stack
	shape.frame = stack_frame
	return shape


func moved(offset: Vector3) -> SolidShape:
	var shape: SolidShape = _make(kind, AABB(box.position + offset, box.size), eave + offset.z)
	shape.silhouette = silhouette
	shape.frame = frame
	return shape


## Every flat or curved face, normals outwards (the scene description keeps those the camera sees).
func faces(solid: int) -> Array[Receiver]:
	match kind:
		Kind.SILHOUETTE:
			# Only an asset's (invisible) solid: its sprite takes the light.
			return []
		Kind.CYLINDER:
			return _cylinder_faces(solid)
		Kind.ROOF_X, Kind.ROOF_D:
			return _roof_faces(solid)
	return _box_faces(box, solid)


## Edges as pairs of points, for the wireframe.
func edges() -> PackedVector3Array:
	var points: PackedVector3Array = PackedVector3Array()
	if kind == Kind.CYLINDER:
		# Both rims, and the silhouette's sides as the camera sees them (the ellipse's x extremes).
		var faces_now: Array[Receiver] = _cylinder_faces(0)
		for rim: Receiver in [faces_now[1], faces_now[2]]:
			var ring: Array[Vector3] = rim.outline()
			for index: int in ring.size():
				points.append_array([ring[index], ring[(index + 1) % ring.size()]])
		var lift: Vector3 = Vector3(0.0, 0.0, box.size.z)
		var side: Receiver = faces_now[0]
		for x_sign: float in [-1.0, 1.0]:
			var foot: Vector3 = side.origin + side.edge_u * x_sign
			points.append_array([foot, foot + lift])
		return points
	for face: Receiver in (_box_faces(box, 0) if kind == Kind.SILHOUETTE else faces(0)):
		var outline: Array[Vector3] = face.outline()
		for index: int in outline.size():
			points.append_array([outline[index], outline[(index + 1) % outline.size()]])
	return points


static func _box_faces(bounds: AABB, solid: int) -> Array[Receiver]:
	var found: Array[Receiver] = []
	for axis: int in 3:
		var u: Vector3 = Vector3.ZERO
		u[(axis + 1) % 3] = bounds.size[(axis + 1) % 3]
		var v: Vector3 = Vector3.ZERO
		v[(axis + 2) % 3] = bounds.size[(axis + 2) % 3]
		for side: int in 2:
			var origin: Vector3 = bounds.position
			origin[axis] += bounds.size[axis] * side
			var normal: Vector3 = Vector3.ZERO
			normal[axis] = 1.0 if side == 1 else -1.0
			found.append(Receiver.new(origin, u, v, normal, solid))
	return found


## Walls up to the eave, two triangular gables, two slopes. `a` is the axis the slopes fall along,
## `o` the ridge's axis.
func _roof_faces(solid: int) -> Array[Receiver]:
	var a: int = 0 if kind == Kind.ROOF_X else 1
	var o: int = 1 - a
	var walls: AABB = AABB(box.position, Vector3(box.size.x, box.size.y, eave - box.position.z))
	var found: Array[Receiver] = []
	for face: Receiver in _box_faces(walls, solid):
		if face.normal.z == 0.0:
			found.append(face)
	found.append(Receiver.new(box.position, Vector3(box.size.x, 0.0, 0.0), Vector3(0.0, box.size.y, 0.0),
			Vector3(0.0, 0.0, -1.0), solid))
	var rise: float = box.end.z - eave
	var half: float = box.size[a] * 0.5
	var along_o: Vector3 = Vector3.ZERO
	along_o[o] = box.size[o]
	var to_ridge: Vector3 = Vector3(0.0, 0.0, rise)
	to_ridge[a] = half
	var low: Vector3 = Vector3(box.position.x, box.position.y, eave)
	var high: Vector3 = low
	high[a] = box.end[a]
	var down_a: Vector3 = Vector3(0.0, 0.0, half)
	down_a[a] = -rise
	var up_a: Vector3 = Vector3(0.0, 0.0, half)
	up_a[a] = rise
	found.append(Receiver.new(low, along_o, to_ridge, down_a.normalized(), solid))
	var from_high: Vector3 = to_ridge
	from_high[a] = -half
	found.append(Receiver.new(high, along_o, from_high, up_a.normalized(), solid))
	# Gables: triangles on the two walls across the ridge.
	var across: Vector3 = Vector3.ZERO
	across[a] = box.size[a]
	for side: int in 2:
		var origin: Vector3 = low
		origin[o] += box.size[o] * side
		var normal: Vector3 = Vector3.ZERO
		normal[o] = 1.0 if side == 1 else -1.0
		found.append(Receiver.new(origin, across, to_ridge, normal, solid, Receiver.Kind.TRIANGLE))
	return found


func _cylinder_faces(solid: int) -> Array[Receiver]:
	var centre: Vector3 = Vector3(box.get_center().x, box.get_center().y, box.position.z)
	var radius_x: Vector3 = Vector3(box.size.x * 0.5, 0.0, 0.0)
	var radius_d: Vector3 = Vector3(0.0, box.size.y * 0.5, 0.0)
	var side: Receiver = Receiver.new(centre, radius_x, radius_d, Vector3(0.0, 1.0, 0.0), solid, Receiver.Kind.CYLINDER)
	side.height = box.size.z
	return [
		side,
		Receiver.new(centre + Vector3(0.0, 0.0, box.size.z), radius_x, radius_d, Vector3(0.0, 0.0, 1.0), solid, Receiver.Kind.DISK),
		Receiver.new(centre, radius_x, radius_d, Vector3(0.0, 0.0, -1.0), solid, Receiver.Kind.DISK),
	]


static func _make(shape_kind: Kind, bounds: AABB, eave_z: float) -> SolidShape:
	var shape: SolidShape = SolidShape.new()
	shape.kind = shape_kind
	shape.box = bounds
	shape.eave = eave_z
	return shape
