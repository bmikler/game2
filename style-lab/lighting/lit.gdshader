// The material of every lit sprite (floors, walls, props, actors), see Lit. A room's ambient is a
// flat light far above it (Lit.AMBIENT_HEIGHT): it skips N·L, so it lights every surface evenly and
// normal maps shape sprites only through real lamps and windows. Other lights: Godot's default.
// style-lab (ticket 31): a flat light at SUN_MAP_HEIGHT, LAMP_MAP_HEIGHT or ROOM_LAMP_MAP_HEIGHT (SunMap) takes its light per
// pixel from the light maps (SubViewports: a PointLight2D cannot take a ViewportTexture). An actor
// (Lit.actor_material(): is_actor) reads the maps' actor strip instead of the house pixel it covers.
shader_type canvas_item;

uniform sampler2D sun_map : filter_nearest, repeat_disable;
uniform sampler2D lamp_map : filter_nearest, repeat_disable;
uniform sampler2D room_lamp_map : filter_nearest, repeat_disable;
uniform sampler2D actor_sun_map : filter_nearest, repeat_disable; // the actor strip (SunMap: its own viewports)
uniform sampler2D actor_lamp_map : filter_nearest, repeat_disable;
uniform vec4 map_rect = vec4(0.0, 0.0, 1.0, 1.0); // world px: x, y, width, height (the house)
uniform vec2 map_size = vec2(1.0); // the house maps' px
uniform bool is_actor = false;
uniform vec4 actor_rect = vec4(0.0); // world px of the actor strip's top left, its size
// Ticket 33: the light the actor takes away, per map, in a window round it (SunMap); size 0: none.
uniform sampler2D shadow_sun_map : filter_nearest, repeat_disable;
uniform sampler2D shadow_lamp_map : filter_nearest, repeat_disable;
uniform sampler2D shadow_room_map : filter_nearest, repeat_disable;
uniform vec4 shadow_rect = vec4(0.0); // world px: x, y, width, height
// The actor's shadow as pixel art (the critic): 0 smooth; else the share of light it takes in this
// many levels (2: hard; 3: none, half, full), dithered Bayer 4×4 on the world's pixels (dither 1).
uniform int shadow_levels = 0;
uniform int shadow_dither = 1;
// Ticket 35 (one shadow model): the house maps' alpha holds the share of light the objects take; the
// look (levels, dither) quantizes it together with the actor's, so every shadow looks alike.
uniform int objects_look = 0;
// The dither band round each step, shared model (0.6: the actor alone; every faint sky shadow of the
// furniture became sparse dots over the floor, so narrower: faint shadows drop out).
uniform float dither_band = 0.35;

float bayer4(vec2 p) {
	int x = int(mod(p.x, 4.0));
	int y = int(mod(p.y, 4.0));
	int i = y * 4 + x;
	int m[16] = int[](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
	return (float(m[i]) + 0.5) / 16.0;
}

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void light() {
	float h = LIGHT_POSITION.z;
	if (h > 6900.0 && h < 7800.0) {
		vec3 map;
		if (is_actor) {
			vec2 s = clamp(floor(world_pos) + 0.5 - actor_rect.xy, vec2(0.5), actor_rect.zw - 0.5);
			vec2 uv = s / actor_rect.zw;
			map = h < 7250.0 ? texture(actor_sun_map, uv).rgb : texture(actor_lamp_map, uv).rgb;
		} else {
			vec2 uv = (floor(world_pos) + 0.5 - map_rect.xy) / map_size;
			vec4 house = h < 7250.0 ? texture(sun_map, uv) : (h < 7600.0 ? texture(lamp_map, uv) : texture(room_lamp_map, uv));
			map = house.rgb;
			float objects = objects_look == 1 ? clamp(house.a, 0.0, 1.0) : 0.0;
			vec2 sp = floor(world_pos) + 0.5 - shadow_rect.xy;
			bool in_window = shadow_rect.z > 0.0 && all(greaterThanEqual(sp, vec2(0.0))) && all(lessThan(sp, shadow_rect.zw));
			if (objects_look == 1) {
				vec3 lost = vec3(0.0);
				if (in_window) {
					vec2 suv = sp / shadow_rect.zw;
					lost = h < 7250.0 ? texture(shadow_sun_map, suv).rgb : (h < 7600.0 ? texture(shadow_lamp_map, suv).rgb : texture(shadow_room_map, suv).rgb);
				}
				if (shadow_levels >= 2 && objects < 0.995) {
					// The light before any object or the actor, and the share all of them take.
					vec3 free = map / (1.0 - objects);
					float free_l = max(dot(free, vec3(0.333)), 1e-5);
					float share = clamp(objects + dot(lost, vec3(0.333)) / free_l, 0.0, 1.0);
					float steps = float(shadow_levels - 1);
					float t = shadow_dither == 1 ? 0.5 + (bayer4(floor(world_pos)) - 0.5) * dither_band : 0.5;
					share = clamp(floor(share * steps + t), 0.0, steps) / steps;
					map = free * (1.0 - share);
				} else if (shadow_levels < 2) {
					map = max(map - lost, vec3(0.0));
				}
			} else if (in_window) {
				vec2 suv = sp / shadow_rect.zw;
				vec3 lost = h < 7250.0 ? texture(shadow_sun_map, suv).rgb : (h < 7600.0 ? texture(shadow_lamp_map, suv).rgb : texture(shadow_room_map, suv).rgb);
				if (shadow_levels >= 2) {
					float lit_l = max(dot(map, vec3(0.333)), 1e-5);
					float share = clamp(dot(lost, vec3(0.333)) / lit_l, 0.0, 1.0);
					float steps = float(shadow_levels - 1);
					// Dithered only in a band round each step (a full-range dither turned a faint shadow into
					// sparse dots over a wide area).
					float t = shadow_dither == 1 ? 0.5 + (bayer4(floor(world_pos)) - 0.5) * 0.6 : 0.5;
					share = clamp(floor(share * steps + t), 0.0, steps) / steps;
					map *= 1.0 - share;
				} else {
					map = max(map - lost, vec3(0.0));
				}
			}
		}
		LIGHT = vec4(map * COLOR.rgb * LIGHT_ENERGY, LIGHT_COLOR.a);
	} else {
		float ndl = h > 5000.0 ? 1.0 : max(0.0, dot(NORMAL, LIGHT_DIRECTION));
		LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * ndl, LIGHT_COLOR.a);
	}
}
