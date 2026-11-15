extends GutTest
## The engine's projection: metres (x right, d towards the camera, z up) → screen pixels.

var _projection: LightProjection = preload("res://addons/swiatlo/projection/projection.tres")


func test_projection_resource_is_depth_0_60_and_40_px_per_metre() -> void:
	assert_almost_eq(_projection.depth_factor, 0.6, 0.0001)
	assert_almost_eq(_projection.px_per_m, 40.0, 0.0001)


func test_a_metre_right_is_40_px_right() -> void:
	assert_eq(_projection.to_screen(Vector3(1.0, 0.0, 0.0)), Vector2(40.0, 0.0))


func test_a_metre_towards_the_camera_is_24_px_down() -> void:
	assert_eq(_projection.to_screen(Vector3(0.0, 1.0, 0.0)), Vector2(0.0, 24.0))


func test_a_metre_up_is_40_px_up() -> void:
	assert_eq(_projection.to_screen(Vector3(0.0, 0.0, 1.0)), Vector2(0.0, -40.0))


func test_components_add_up() -> void:
	assert_eq(_projection.to_screen(Vector3(2.5, -5.0, 3.0)), Vector2(100.0, -240.0))


func test_south_points_up_the_screen() -> void:
	var direction: Vector2 = _projection.direction_on_screen(Vector3(0.0, -1.0, 0.0))
	assert_almost_eq(direction.x, 0.0, 0.0001)
	assert_lt(direction.y, 0.0)
	assert_almost_eq(direction.length(), 1.0, 0.0001)
