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
// Ticket 35: the same maps with the actor in them, every frame, in a window round it (SunMap); the
// house maps there give way to it, faded in over its edges. Size 0: none.
uniform sampler2D shadow_sun_map : filter_nearest, repeat_disable;
uniform sampler2D shadow_lamp_map : filter_nearest, repeat_disable;
uniform sampler2D shadow_room_map : filter_nearest, repeat_disable;
uniform vec4 shadow_rect = vec4(0.0); // world px: x, y, width, height
const float SHADOW_EDGE = 24.0;

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
			map = h < 7250.0 ? texture(sun_map, uv).rgb : (h < 7600.0 ? texture(lamp_map, uv).rgb : texture(room_lamp_map, uv).rgb);
			vec2 sp = floor(world_pos) + 0.5 - shadow_rect.xy;
			if (shadow_rect.z > 0.0 && all(greaterThanEqual(sp, vec2(0.0))) && all(lessThan(sp, shadow_rect.zw))) {
				vec2 suv = sp / shadow_rect.zw;
				vec3 near = h < 7250.0 ? texture(shadow_sun_map, suv).rgb : (h < 7600.0 ? texture(shadow_lamp_map, suv).rgb : texture(shadow_room_map, suv).rgb);
				vec2 edge = min(sp, shadow_rect.zw - sp);
				map = mix(map, near, smoothstep(0.0, SHADOW_EDGE, min(edge.x, edge.y)));
			}
		}
		LIGHT = vec4(map * COLOR.rgb * LIGHT_ENERGY, LIGHT_COLOR.a);
	} else {
		float ndl = h > 5000.0 ? 1.0 : max(0.0, dot(NORMAL, LIGHT_DIRECTION));
		LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * ndl, LIGHT_COLOR.a);
	}
}
