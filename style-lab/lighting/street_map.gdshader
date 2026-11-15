// PROTOTYPE (ticket 14): the street's one light buffer, as the house's (light_map.gdshader): a SubViewport
// over the street (world px from origin_px) with the actor's strip right of it; every pixel is
// street_parts() of the surface it shows, the strip the light on the actor's body. Painted whole when
// something changes, then only a window round the actor every frame, in this same texture.
shader_type canvas_item;
render_mode unshaded, blend_disabled;

#include "res://lighting/street_fn.gdshaderinc"

uniform vec2 origin_px;
uniform float house_w = 1e9; // buffer px: the street, then the actor strip
uniform vec2 strip_size = vec2(32.0, 96.0);
uniform vec2 actor_feet_px = vec2(0.0);
uniform float actor_k = 1.0;
uniform float actor_bounce = 0.3;
uniform int debug_view = 0; // as light_map.gdshader; 3: the lit windows
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
	if (debug_view == 5) { return vec3(l.shadow.x, l.shadow.y, l.shadow.z); }
	return l.sun + l.sky + l.night + l.lamps;
}

// The light on the actor's body at strip pixel s (as light_map.gdshader: a cylinder facing the camera,
// not shadowing itself, the ground's light bounced up).
vec3 body_light(vec2 s, vec2 world) {
	vec2 feet = vec2(actor_feet_px.x / ppm, (actor_feet_px.y - floor_y) / (ppm * kd));
	float z = (strip_size.y - s.y) / ppm;
	float dx = (s.x - strip_size.x * 0.5) / ppm;
	vec3 o = vec3(actor_body.x + dx, actor_body.y + actor_body.z * 0.5, max(z, EPS));
	float across = clamp(dx / actor_body.z, -1.0, 1.0);
	vec3 normal = vec3(across, sqrt(max(1.0 - across * across, 0.0)), 0.0);
	vec3 lit = pick(street_parts(o, normal, world, false));
	vec3 below = pick(street_parts(vec3(feet, 0.0), vec3(0.0, 0.0, 1.0), world, false));
	float up = clamp(z / 1.8, 0.0, 1.0);
	return (lit + below * actor_bounce * (1.0 - 0.6 * up)) * actor_k;
}

void fragment() {
	vec2 px = light_px_mid(buffer_px);
	vec3 lit = vec3(0.0);
	vec3 amb = room_ambient[0];
	if (px.x >= house_w) {
		vec2 s = px - vec2(house_w, 0.0);
		if (s.x < strip_size.x && s.y < strip_size.y) {
			vec2 world = actor_feet_px + s - vec2(strip_size.x * 0.5, strip_size.y);
			lit = body_light(s, light_px(world));
			if (look_levels() && debug_view == 0 && !view_levels) {
				lit = light_levels(lit, amb, light_px(s));
			}
		}
	} else {
		vec2 world = origin_px + px;
		vec3 p;
		vec3 n;
		if (street_surface_at(world, p, n)) {
			lit = pick(street_parts(p, n, light_px(world), true));
			if (look_levels() && debug_view == 0 && !view_levels) {
				lit = light_levels(lit, amb, light_px(world));
			}
		}
	}
	COLOR = vec4(lit, view_levels && debug_view == 0 ? luma(amb) : 1.0);
}
