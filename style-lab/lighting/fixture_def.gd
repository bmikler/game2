class_name FixtureDef
extends Resource
## One type of light fixture, shared by every instance.

@export var lux: float = 250.0 ## Nominal lux on the floor under the fixture.
@export var color: Color = Color(0.98, 0.95, 0.84)
@export var shape: LightTextures.Shape = LightTextures.Shape.TUBE
@export var texture_scale: float = 2.6
@export var offset: Vector2 = Vector2.ZERO ## Texture offset, e.g. a door spill grows away from the door.
@export var height: float = 120.0 ## For normal maps.
@export_flags("Floor", "Solid", "Actor") var receivers: int = 7
## Floor area one fixture lights at its rated lux. The room's light level is
## Σ lux × level × footprint / floor area, so adding fixtures brightens it. 0: not counted.
@export var footprint_m2: float = 7.7
@export var scheduled: bool = true ## Follows the room's schedule; false: always on.
## Light actors through an ActorLight twin (the light at their feet). Off for a light that only exists
## near the floor, e.g. a door spill: stretched up it would burn the whole body.
@export var actor_twin: bool = true
@export_group("Light map")
## style-lab (ticket 31): a point source of the light map (SunMap: shadows of furniture, stopped by
## walls) instead of its hand-made pool, when the map lights the lamps.
@export var map_source: bool = false
@export var source_height_m: float = 1.6 ## The bulb above the floor.
@export var source_back_m: float = 0.0 ## The bulb this far behind the fixture point (a lamp block's middle).
