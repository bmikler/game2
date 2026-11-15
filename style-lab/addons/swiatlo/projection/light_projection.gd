@tool
class_name LightProjection
extends Resource
## The game's projection: world metres → screen pixels. World axes: x to the right (west), d towards
## the camera (north, down the screen), z up. South is always at the top of the screen, east on the left.

const DEFAULT_PATH: String = "res://addons/swiatlo/projection/projection.tres"

## Depth pixels per pixel of width (the 3/4 view).
@export var depth_factor: float = 0.6
## Screen pixels per metre along x.
@export var px_per_m: float = 40.0


## A point (x, d, z) in metres → screen pixels relative to the Location's origin.
func to_screen(point: Vector3) -> Vector2:
	return Vector2(point.x, point.y * depth_factor - point.z) * px_per_m


## A world direction → a unit direction on screen (zero when it points straight into the camera).
func direction_on_screen(direction: Vector3) -> Vector2:
	return Vector2(direction.x, direction.y * depth_factor - direction.z).normalized()
