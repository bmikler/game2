class_name Exposure
extends RefCounted
## The exposure rule (ADR 0007). Each space gets a fixed exposure from its own light level, and
## nothing follows the player. White point: a surface under L_REF lx at exposure 1 shows its albedo
## (the Pixellab colours 1:1), so every light's energy comes from its lux with no per-light constant.

const L_REF: float = 250.0 ## Lux shown as albedo at exposure 1.
const X_MIN: float = 0.25
const X_MAX: float = 8.0
const KNEE: float = 1.5 ## Energies above this are compressed (at most 2 × KNEE).


static func target(lux: float, alpha: float) -> float:
	return clampf(pow(L_REF / lux, alpha), X_MIN, X_MAX)


## Energy for a light giving `lux` at its brightest spot on the floor, at exposure `x`. `peak` is
## what its texture gives a white floor at energy 1 (LightTextures.peak()).
static func energy(lux: float, x: float, peak: float, knee_at: float = KNEE) -> float:
	return knee(lux * x / (L_REF * peak), knee_at)


## Above `knee_at` an energy grows more and more slowly, up to 2 × `knee_at`.
static func knee(value: float, knee_at: float = KNEE) -> float:
	if value <= knee_at:
		return value
	var over: float = value - knee_at
	return knee_at + over / (1.0 + over / knee_at)
