extends GutTest
## The furniture recipe's normals for add-ons (sprite pixels the generator painted outside the Blender
## model): inflated from the add-on's own silhouette, or one flat normal towards the camera.

const AddonNormals := preload("res://tools/meble/addon_normals.gd")
const SIZE: Vector2i = Vector2i(24, 24)
## Blender's normal of the model's front face (towards the camera's side, d).
const FRONT: Color = Color8(128, 128, 255)


## An RGBA image, transparent except `rect` in `color`.
func _image(rect: Rect2i, color: Color) -> Image:
	var image: Image = Image.create_empty(SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill_rect(rect, color)
	return image


func _normal(image: Image, x: int, y: int) -> Vector3:
	return AssetSprite.decode_normal(image.get_pixel(x, y))


func test_model_pixels_keep_blender_normals() -> void:
	var model: Rect2i = Rect2i(4, 10, 16, 10)
	var result: Image = AddonNormals.fill(_image(model, Color.WHITE), _image(model, Color.WHITE),
			_image(model, FRONT), AddonNormals.Mode.INFLATED)
	assert_eq(result.get_pixel(10, 15), FRONT)
	assert_eq(result.get_pixel(1, 1).a, 0.0, "transparent pixels stay empty")


func test_flat_addons_face_the_camera() -> void:
	var model: Rect2i = Rect2i(4, 14, 16, 8)
	var sprite: Image = _image(model, Color.WHITE)
	sprite.fill_rect(Rect2i(6, 6, 6, 8), Color.WHITE)  # a jar standing on the top
	var result: Image = AddonNormals.fill(sprite, _image(model, Color.WHITE), _image(model, FRONT),
			AddonNormals.Mode.FLAT)
	# The camera looks along (0, −1, −0.6) in the engine's axes (x, d towards the camera, z up).
	var camera: Vector3 = Vector3(0.0, 0.857, 0.514)
	for at: Vector2i in [Vector2i(6, 6), Vector2i(9, 10), Vector2i(11, 13)]:
		assert_almost_eq(_normal(result, at.x, at.y), camera, Vector3.ONE * 0.01, "add-on pixel %s" % at)
	assert_eq(result.get_pixel(9, 18), FRONT, "model pixel below the jar")


func test_inflated_addon_faces_the_camera_inside_and_outwards_at_its_edge() -> void:
	var cloth: Rect2i = Rect2i(4, 6, 16, 12)  # an add-on with no model behind it
	var empty: Image = _image(Rect2i(), Color.WHITE)
	var result: Image = AddonNormals.fill(_image(cloth, Color.WHITE), empty, empty, AddonNormals.Mode.INFLATED)
	var camera: Vector3 = Vector3(0.0, 0.857, 0.514)
	# Screen up, across the line of sight, in the engine's axes.
	var screen_up: Vector3 = Vector3(0.0, -0.514, 0.857)
	assert_almost_eq(_normal(result, 12, 12), camera, Vector3.ONE * 0.01, "middle")
	assert_lt(_normal(result, 4, 12).x, -0.4, "left edge leans left")
	assert_gt(_normal(result, 19, 12).x, 0.4, "right edge leans right")
	assert_gt(_normal(result, 12, 6).dot(screen_up), 0.4, "top edge leans up")
	assert_lt(_normal(result, 12, 17).dot(screen_up), -0.4, "bottom edge leans down")
	for x: int in range(4, 20):
		assert_gt(_normal(result, x, 9).dot(camera), 0.0, "every pixel faces the camera's side (%d, 9)" % x)
