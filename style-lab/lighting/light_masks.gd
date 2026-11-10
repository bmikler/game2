class_name LightMasks
extends RefCounted
## Light mask bits. The engine lights an item when item.light_mask & light.range_item_cull_mask != 0,
## so a light cannot ask for "floor AND room A". Every (room colour slot, receiver kind) pair gets its
## own bit: receivers carry one kind, lights carry the kinds they reach in their room.

enum Receiver { FLOOR = 1, SOLID = 2, ACTOR = 4 }

const SLOTS: int = 4
const ALL: int = Receiver.FLOOR | Receiver.SOLID | Receiver.ACTOR
const DUST: int = 1 << 12 ## LIGHT_ONLY particles, lit only by window air lights.


static func of(slot: int, receivers: int) -> int:
	var mask: int = 0
	if receivers & Receiver.FLOOR:
		mask |= 1 << slot
	if receivers & Receiver.SOLID:
		mask |= 1 << (SLOTS + slot)
	if receivers & Receiver.ACTOR:
		mask |= 1 << (SLOTS * 2 + slot)
	return mask
