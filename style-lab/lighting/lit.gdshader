// The material of every lit sprite (floors, walls, props, actors), see Lit. A room's ambient is a
// flat light far above it (Lit.AMBIENT_HEIGHT): it skips N·L, so it lights every surface evenly and
// normal maps shape sprites only through real lamps and windows. Other lights: Godot's default.
// style-lab (ticket 36): a flat light at LIGHT_MAP_HEIGHT (SunMap) takes its light per pixel from the
// one light buffer (a SubViewport: a PointLight2D cannot take a ViewportTexture). An actor
// (Lit.actor_material(): is_actor) reads the buffer's actor strip instead of the house pixel it covers.
shader_type canvas_item;

uniform sampler2D light_map : filter_nearest, repeat_disable;
uniform vec2 map_origin = vec2(0.0); // world px of the buffer's top left (the house)
uniform vec2 map_size = vec2(1.0); // the buffer's px (the house, then the actor strip)
uniform bool is_actor = false;
uniform vec4 actor_rect = vec4(0.0); // world px of the actor strip's top left, its size
uniform float house_w = 0.0; // the strip starts here in the buffer
uniform float light_res = 1.0; // ticket 37: view px per world px
// Ticket 37: A's levels drawn here, in the finer view, from the smooth buffer read between its pixels
// (its alpha: the room's ambient), so only the cheap part runs at the view's resolution.
uniform sampler2D light_map_smooth : filter_linear, repeat_disable;
uniform bool view_levels = false;
uniform float level_stops = 0.5;
uniform float level_band = 0.3;

float bayer4(vec2 px) {
	int x = int(mod(floor(px.x), 4.0));
	int y = int(mod(floor(px.y), 4.0));
	int m[16] = int[](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
	return (float(m[y * 4 + x]) + 0.5) / 16.0;
}

// The buffer's light (rgb) over the ambient (a, luma) on one of A's levels (as light_fn: light_levels).
vec3 view_level(vec4 m, vec2 px) {
	float own = dot(m.rgb, vec3(0.2126, 0.7152, 0.0722));
	float l = own + m.a;
	if (l < 1e-5 || own < 1e-6) {
		return m.rgb;
	}
	float e = log2(l) / level_stops;
	float k = floor(e);
	float t = clamp((e - k - (1.0 - level_band)) / max(level_band, 1e-4), 0.0, 1.0);
	if (bayer4(px) < t) {
		k += 1.0;
	}
	float q = max(exp2((k + 0.5) * level_stops), m.a);
	return m.rgb * (q - m.a) / own;
}

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void light() {
	float h = LIGHT_POSITION.z / light_res; // the view light_res times finer scales the height too
	if (h > 6900.0 && h < 7100.0) {
		vec2 at;
		if (is_actor) {
			vec2 s = clamp((floor(world_pos * light_res) + 0.5) / light_res - actor_rect.xy, vec2(0.5 / light_res), actor_rect.zw - 0.5 / light_res);
			at = vec2(house_w, 0.0) + s;
		} else {
			at = (floor(world_pos * light_res) + 0.5) / light_res - map_origin;
		}
		vec3 map = texture(light_map, at / map_size).rgb;
		if (view_levels) {
			vec2 fine = is_actor
					? vec2(house_w, 0.0) + clamp(world_pos - actor_rect.xy, vec2(0.5), actor_rect.zw - 0.5)
					: world_pos - map_origin;
			vec2 dither_px = floor((is_actor ? world_pos - actor_rect.xy : world_pos) * light_res);
			map = view_level(texture(light_map_smooth, fine / map_size), dither_px);
		}
		LIGHT = vec4(map * COLOR.rgb * LIGHT_ENERGY, LIGHT_COLOR.a);
	} else {
		float ndl = h > 5000.0 ? 1.0 : max(0.0, dot(NORMAL, LIGHT_DIRECTION));
		LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * ndl, LIGHT_COLOR.a);
	}
}
