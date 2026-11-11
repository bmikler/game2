// PROTOTYPE (ticket 36): the one light buffer. A SubViewport over the house (world px from origin_px)
// with the actor's strip right of it; every pixel is light_parts() of the surface it shows, the strip
// the light on the actor's body (the same function at body points, round: four sides). The house is
// painted whole when something changes, then only a window round the actor every frame, in this same
// texture (the viewport is never cleared): outside the window nothing differs, so there is no seam.
shader_type canvas_item;
render_mode unshaded, blend_disabled;

#include "res://lighting/light_fn.gdshaderinc"

uniform vec2 origin_px; // world px of the house's top left (buffer px 0, 0)
uniform float house_w = 1e9; // buffer px: the house, then the actor strip
uniform vec2 strip_size = vec2(32.0, 96.0);
uniform vec2 actor_feet_px = vec2(0.0); // world px of the feet (the strip's bottom middle)
uniform float actor_k = 1.0; // the light on the body, × this
uniform float actor_bounce = 0.3; // the floor's light at the feet bounced up the body, × this
// 0 the light; 1 the sun (and ribbons), 2 the sky, 3 the night, 4 the lamps; 5 the shadow share per
// source (red the sun and ribbons, green the sky, blue the night).
uniform int debug_view = 0;
// Ticket 37: A's levels drawn in a finer view (lit.gdshader): the buffer stays smooth, its alpha the
// room's ambient (luma) they need.
uniform bool view_levels = false;

varying vec2 buffer_px;

void vertex() {
	buffer_px = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

vec3 pick(Light l) {
	if (debug_view == 1) { return l.sun; }
	if (debug_view == 2) { return l.sky; }
	if (debug_view == 3) { return l.night; }
	if (debug_view == 4) { return l.lamps; }
	if (debug_view == 5) { return vec3(max(l.shadow.x, l.shadow.w), l.shadow.y, l.shadow.z); }
	return l.sun + l.sky + l.night + l.lamps;
}

// The floor in a doorway lies inside a partition's thickness (x between its faces): true with them.
bool in_doorway(vec3 p, out float x0, out float x1) {
	for (int i = 0; i < box_count; i++) {
		vec3 size = box_max[i] - box_min[i];
		bool across_x = size.x <= 0.5 && size.y > size.x;
		if (across_x && box_max[i].z >= shell_max.z - 0.05 && p.x > box_min[i].x && p.x < box_max[i].x) {
			x0 = box_min[i].x;
			x1 = box_max[i].x;
			return true;
		}
	}
	return false;
}

vec3 surface_light(vec3 p, vec3 n, vec2 px) {
	float x0;
	float x1;
	if (n.z > 0.5 && p.z < 0.01 && in_doorway(p, x0, x1)) {
		// Blend the floors on both sides (the wall shades the doorway's own floor: a seam, the human).
		vec3 a = pick(light_parts(vec3(x0 - 0.03, p.y, 0.0), n, px, true));
		vec3 b = pick(light_parts(vec3(x1 + 0.03, p.y, 0.0), n, px, true));
		return mix(a, b, clamp((p.x - x0) / max(x1 - x0, 1e-3), 0.0, 1.0));
	}
	return pick(light_parts(p, n, px, true));
}

// The light on the actor's body at strip pixel s: the camera sees the body's front (towards +d), a
// cylinder: each column's normal turns from the front in the middle to the sides at the edges (a back
// window lights only the rim, the human); it does not shadow itself; the floor's light bounced up.
vec3 body_light(vec2 s, vec2 world) {
	float ppm_d = ppm * kd;
	vec2 feet = vec2(actor_feet_px.x / ppm, (actor_feet_px.y - floor_y) / ppm_d);
	float z = (strip_size.y - s.y) / ppm;
	float dx = (s.x - strip_size.x * 0.5) / ppm;
	vec3 o = vec3(actor_body.x + dx, actor_body.y + actor_body.z * 0.5, max(z, EPS));
	float across = clamp(dx / actor_body.z, -1.0, 1.0);
	vec3 normal = vec3(across, sqrt(max(1.0 - across * across, 0.0)), 0.0);
	vec3 lit = pick(light_parts(o, normal, world, false));
	vec3 below = pick(light_parts(vec3(feet, 0.0), vec3(0.0, 0.0, 1.0), world, false));
	float up = clamp(z / 1.8, 0.0, 1.0);
	return (lit + below * actor_bounce * (1.0 - 0.6 * up)) * actor_k;
}

void fragment() {
	vec2 px = light_px_mid(buffer_px);
	vec3 lit = vec3(0.0);
	vec3 amb = vec3(0.0);
	if (px.x >= house_w) {
		vec2 s = px - vec2(house_w, 0.0);
		if (s.x < strip_size.x && s.y < strip_size.y) {
			vec2 world = actor_feet_px + s - vec2(strip_size.x * 0.5, strip_size.y);
			lit = body_light(s, light_px(world));
			vec2 feet = vec2(actor_feet_px.x / ppm, (actor_feet_px.y - floor_y) / (ppm * kd));
			amb = room_ambient[room_index(feet)];
			if (look_levels() && debug_view == 0 && !view_levels) {
				// Dithered in the strip's own px: the pattern stays on the body as it walks.
				lit = light_levels(lit, amb, light_px(s));
			}
		}
	} else {
		vec2 world = origin_px + px;
		vec3 p;
		vec3 n;
		if (surface_at(world, p, n)) {
			lit = surface_light(p, n, light_px(world));
			amb = room_ambient[room_index(p.xy)];
			if (look_levels() && debug_view == 0 && !view_levels) {
				lit = light_levels(lit, amb, light_px(world));
			}
		}
	}
	COLOR = vec4(lit, view_levels && debug_view == 0 ? luma(amb) : 1.0);
}
