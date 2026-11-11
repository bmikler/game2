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
uniform float light_res = 1.0; // ticket 37: buffer px per world px

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
		LIGHT = vec4(map * COLOR.rgb * LIGHT_ENERGY, LIGHT_COLOR.a);
	} else {
		float ndl = h > 5000.0 ? 1.0 : max(0.0, dot(NORMAL, LIGHT_DIRECTION));
		LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * ndl, LIGHT_COLOR.a);
	}
}
