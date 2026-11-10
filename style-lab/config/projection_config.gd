class_name ProjectionConfig
extends Resource
## Projection and scale as data, so the Rzut prototype can swap them. Everything drawn in code and the
## lighting read pixels per metre from the current config; the view reads the base resolution.
## Changing the config takes effect when the Poligon is loaded again (Main.reload_world()).

const DEFAULT_PATH: String = "res://config/projection.tres"

@export var base_size: Vector2i = Vector2i(960, 540) ## Render resolution before scaling to the window.
@export var px_per_m: float = 40.0 ## Pixels per metre across the screen.
## Pixels per metre of depth on the ground, per px_per_m (1: depth as long as width; below 1: a lower
## 3/4 view). The game1 lighting assumes 1.
@export var depth_factor: float = 1.0
@export var actor_height_m: float = 1.8
@export var walk_speed_m_s: float = 1.6

static var _current: ProjectionConfig


static func current() -> ProjectionConfig:
	if _current == null:
		_current = load(DEFAULT_PATH) as ProjectionConfig
	return _current


static func use(config: ProjectionConfig) -> void:
	_current = config


## Metres across the screen to pixels.
func px(metres: float) -> float:
	return metres * px_per_m


## Metres of depth on the ground to pixels.
func depth_px(metres: float) -> float:
	return metres * px_per_m * depth_factor
