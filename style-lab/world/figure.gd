class_name Figure
extends RefCounted
## PROTOTYPE (ticket Rzut, skala i rozdzielczość): an adult in a winter coat drawn in code, about 7
## heads tall, in the three drawn views of the game (front, side, back) plus the mirror for the other
## side. Only to judge proportions and scale; not an asset. Origin: the feet.

enum View { FRONT, SIDE, BACK }
## The dark spot under the feet (ticket 33): fixed as before, a small soft contact spot (the shadow from
## the light map does the rest), or none.
enum Blob { FIXED, SOFT, NONE }

const HEADS: float = 7.0
const COAT: Color = Color("3d4452")
const COAT_SHADE: Color = Color("2f3541")
const SCARF: Color = Color("6b3a3a")
const TROUSERS: Color = Color("272a31")
const BOOTS: Color = Color("17171a")
const SKIN: Color = Color("c9a68a")
const HAIR: Color = Color("3a2a22")
const EYES: Color = Color("1a1414")

const SOFT_BLOB_SIZE: Vector2i = Vector2i(38, 11)
const SOFT_BLOB_OFFSET: Vector2 = Vector2(0.0, -4.0)
const SOFT_BLOB_DARKEST: float = 0.45 ## The light left under the middle of the feet.
const SOFT_BLOB_FADE_FROM: float = 0.1 ## Of the way out, where it starts to fade.

static var blob: Blob = Blob.FIXED
static var _soft_blob_texture: ImageTexture


## The view for a facing in 45° steps (0 right, 2 down, 4 left, 6 up): diagonals use the side view.
static func view_for(facing: int) -> View:
	match facing:
		2:
			return View.FRONT
		6:
			return View.BACK
		_:
			return View.SIDE


## Facing left (3, 4, 5) is the side view mirrored.
static func mirrored_for(facing: int) -> bool:
	return facing >= 3 and facing <= 5


## The spot under the feet, `size` px across and deep, centred on `at` (see Blob).
static func draw_blob(canvas: CanvasItem, at: Vector2, size: Vector2) -> void:
	match blob:
		Blob.FIXED:
			canvas.draw_rect(_snap(Rect2(at - size / 2.0, size)), Color(0.0, 0.0, 0.0, 0.45))
		Blob.SOFT:
			# As game1 (Actor._contact_shadow): a soft oval 38×11 px, darkest ×0.45 under the middle,
			# 4 px up so the feet stand in its front half (centred on them, the figure floated).
			canvas.draw_texture(_soft_blob(), (at + SOFT_BLOB_OFFSET - Vector2(SOFT_BLOB_SIZE) / 2.0).round())


## game1's contact shadow as black with alpha (the actor's canvas is lit: black stays black).
static func _soft_blob() -> ImageTexture:
	if _soft_blob_texture == null:
		var image: Image = Image.create_empty(SOFT_BLOB_SIZE.x, SOFT_BLOB_SIZE.y, false, Image.FORMAT_RGBA8)
		for y: int in SOFT_BLOB_SIZE.y:
			for x: int in SOFT_BLOB_SIZE.x:
				var u: float = float(x) / (SOFT_BLOB_SIZE.x - 1) * 2.0 - 1.0
				var v: float = float(y) / (SOFT_BLOB_SIZE.y - 1) * 2.0 - 1.0
				var left: float = lerpf(SOFT_BLOB_DARKEST, 1.0, smoothstep(SOFT_BLOB_FADE_FROM, 1.0, Vector2(u, v).length()))
				image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 1.0 - left))
		_soft_blob_texture = ImageTexture.create_from_image(image)
	return _soft_blob_texture


## Draws the figure `height` px tall on `canvas` (in its _draw), feet at `at`. `depth` shortens the
## shadow like the floor.
static func draw(canvas: CanvasItem, at: Vector2, height: float, view: View, mirrored: bool, depth: float) -> void:
	var u: float = height / HEADS
	var flip: float = -1.0 if mirrored else 1.0
	var shadow_w: float = 2.2 * u
	draw_blob(canvas, at, Vector2(shadow_w, maxf(2.0, 0.7 * u * depth)))
	# Bars in head units: x from the middle (positive: the facing side in the side view), y up from
	# the feet.
	var bar: Callable = func(x0: float, x1: float, y0: float, y1: float, color: Color) -> void:
		var left: float = minf(x0 * flip, x1 * flip) * u
		canvas.draw_rect(_snap(Rect2(at.x + left, at.y - y1 * u, absf(x1 - x0) * u, (y1 - y0) * u)), color)
	match view:
		View.FRONT, View.BACK:
			var back: bool = view == View.BACK
			bar.call(-0.62, 0.62, 0.0, 0.25, BOOTS)
			bar.call(-0.55, -0.08, 0.25, 2.7, TROUSERS)
			bar.call(0.08, 0.55, 0.25, 2.7, TROUSERS)
			bar.call(-0.95, 0.95, 2.5, 5.85, COAT_SHADE if back else COAT)
			bar.call(-1.05, -0.7, 3.2, 5.75, COAT_SHADE)
			bar.call(0.7, 1.05, 3.2, 5.75, COAT_SHADE)
			bar.call(-1.02, -0.73, 2.95, 3.2, SKIN)
			bar.call(0.73, 1.02, 2.95, 3.2, SKIN)
			bar.call(-0.45, 0.45, 5.6, 6.0, SCARF)
			bar.call(-0.38, 0.38, 6.0, 7.0, HAIR if back else SKIN)
			if back:
				bar.call(-0.45, 0.45, 5.75, 5.95, COAT)
			else:
				bar.call(-0.4, 0.4, 6.7, 7.0, HAIR)
				bar.call(-0.4, -0.3, 6.25, 6.85, HAIR)
				bar.call(0.3, 0.4, 6.25, 6.85, HAIR)
				bar.call(-0.2, -0.08, 6.42, 6.52, EYES)
				bar.call(0.08, 0.2, 6.42, 6.52, EYES)
		View.SIDE:
			bar.call(-0.5, 0.15, 0.0, 0.25, BOOTS)
			bar.call(-0.05, 0.6, 0.0, 0.25, BOOTS)
			bar.call(-0.4, 0.05, 0.25, 2.7, Color("1f2228"))
			bar.call(0.0, 0.45, 0.25, 2.7, TROUSERS)
			bar.call(-0.6, 0.55, 2.5, 5.85, COAT)
			bar.call(-0.2, 0.2, 3.2, 5.7, COAT_SHADE)
			bar.call(-0.15, 0.15, 2.95, 3.2, SKIN)
			bar.call(-0.35, 0.4, 5.6, 6.0, SCARF)
			bar.call(-0.38, 0.32, 6.0, 7.0, SKIN)
			bar.call(-0.42, 0.25, 6.65, 7.05, HAIR)
			bar.call(-0.42, -0.1, 6.1, 6.65, HAIR)
			bar.call(0.32, 0.42, 6.3, 6.5, SKIN)
			bar.call(0.12, 0.22, 6.42, 6.52, EYES)


## Whole pixels, at least one wide and tall.
static func _snap(rect: Rect2) -> Rect2:
	var from: Vector2 = rect.position.round()
	var to: Vector2 = rect.end.round()
	return Rect2(from, (to - from).max(Vector2.ONE))
