class_name LightTextures
extends RefCounted
## Shared light textures, generated once and cached. Each new light texture rebuilds the engine's
## light atlas, so never one per light.

enum Shape { TUBE, RADIAL, DOOR_SPILL, SKY_PILLOW, FLAT, AIR, SCREEN, DOOR_GLOW, DOOR_SOFT_SPILL }

## Brightest linear value each shape gives a white floor (normal map UP) at energy 1, as measured on
## the prototype's calibration scene. Below 1: the floor normal tilts away.
const PEAK_FLOOR: Dictionary[Shape, float] = {
	Shape.TUBE: 0.967,
	Shape.RADIAL: 0.889,
	Shape.DOOR_SPILL: 1.0,
	Shape.SKY_PILLOW: 0.896,
	Shape.FLAT: 1.0,
	Shape.AIR: 1.0,
	Shape.SCREEN: 0.93,
	Shape.DOOR_GLOW: 1.0,
	Shape.DOOR_SOFT_SPILL: 1.0,
}

static var _cache: Dictionary[Shape, ImageTexture] = {}


static func peak(shape: Shape) -> float:
	return PEAK_FLOOR[shape]


static func get_shape(shape: Shape) -> ImageTexture:
	if not _cache.has(shape):
		_cache[shape] = _make(shape)
	return _cache[shape]


static func gradient(width: int, height: int, value_at: Callable) -> ImageTexture:
	var image: Image = Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	for y: int in height:
		for x: int in width:
			var value: float = value_at.call(float(x) / (width - 1), float(y) / (height - 1))
			image.set_pixel(x, y, Color(value, value, value))
	return ImageTexture.create_from_image(image)


static func soft_rect(width: int, height: int, inner: float) -> ImageTexture:
	return gradient(width, height, func(u: float, v: float) -> float:
		var across: float = absf(u * 2.0 - 1.0)
		var along: float = absf(v * 2.0 - 1.0)
		return (1.0 - smoothstep(inner, 1.0, across)) * (1.0 - smoothstep(inner, 1.0, along)))


static func _make(shape: Shape) -> ImageTexture:
	match shape:
		Shape.TUBE:
			return soft_rect(128, 64, 0.45)
		Shape.AIR:
			return soft_rect(64, 64, 0.4)
		Shape.RADIAL:
			return gradient(256, 256, func(u: float, v: float) -> float:
				var distance: float = Vector2(u * 2.0 - 1.0, v * 2.0 - 1.0).length()
				var value: float = clampf(1.0 - distance, 0.0, 1.0)
				return value * value)
		Shape.DOOR_SPILL:
			# Light through a door gap, widening into the room; the door is at the bottom edge.
			return gradient(64, 64, func(u: float, v: float) -> float:
				var along: float = 1.0 - v
				var half: float = 0.4 + 0.5 * along
				return (1.0 - smoothstep(half - 0.15, half, absf(u * 2.0 - 1.0))) * pow(1.0 - along, 1.5))
		Shape.DOOR_SOFT_SPILL:
			# PROTOTYPE (ticket 31): DOOR_SPILL's trapezium with soft sides, shorter, fading smoothly to
			# nothing (the human: the spill's shape, not its hard edges).
			return gradient(64, 64, func(u: float, v: float) -> float:
				var along: float = 1.0 - v
				var half: float = 0.4 + 0.5 * along
				var side: float = 1.0 - smoothstep(half - 0.35, half + 0.05, absf(u * 2.0 - 1.0))
				var fade: float = 1.0 - smoothstep(0.0, 0.8, along)
				return side * pow(fade, 1.4))
		Shape.DOOR_GLOW:
			# PROTOTYPE (ticket 31): a soft steady glow at a door (bottom edge), no hard sides: gaussian
			# across, widening a little and fading into the room.
			return gradient(96, 64, func(u: float, v: float) -> float:
				var along: float = 1.0 - v
				var across: float = (u * 2.0 - 1.0) / (0.3 + 0.25 * along)
				return exp(-across * across) * pow(1.0 - along, 2.2))
		Shape.SCREEN:
			# A screen facing down the screen: bright at the top edge (the screen), widening and fading
			# away from it. Offset (0, 32 × texture_scale) puts the screen at the node (a light's offset
			# is not scaled by texture_scale).
			return gradient(64, 64, func(u: float, v: float) -> float:
				var half: float = 0.5 + 0.5 * v
				var across: float = absf(u * 2.0 - 1.0)
				return (1.0 - smoothstep(half * 0.35, half, across)) * pow(1.0 - v, 1.6))
		Shape.SKY_PILLOW:
			# Wide soft pillow at the foot of a window, fading into the room (top edge = wall).
			return gradient(192, 128, func(u: float, v: float) -> float:
				var across: float = (u * 2.0 - 1.0) / 0.6
				return exp(-across * across) * pow(1.0 - v, 2.0))
		_:
			var image: Image = Image.create_empty(64, 64, false, Image.FORMAT_RGBA8)
			image.fill(Color.WHITE)
			return ImageTexture.create_from_image(image)
