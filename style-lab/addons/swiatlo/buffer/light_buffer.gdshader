// The light buffer: one pixel per game pixel over the whole Location. Each pixel finds the receiver
// the projection shows there (the face nearest the camera), then sums the natural light reaching
// that point in lux (HDR): ambient + sky + sun × visibility.
shader_type canvas_item;
render_mode unshaded, blend_disabled;

#include "res://addons/swiatlo/buffer/visibility.gdshaderinc"

// Rays start this far off the face along its normal, so they do not begin inside the solid.
const float RAY_OFFSET_M = 0.02;
const float EDGE_TOLERANCE = 1e-4;
const float FAR_M = 1000.0;

// Receivers, three texels each: (origin, normal.x), (edge_u, normal.y), (edge_v, normal.z).
uniform sampler2D receivers : filter_nearest;
uniform int receiver_count = 0;
uniform vec2 area_origin_px = vec2(0.0);
uniform float px_per_m = 40.0;
uniform float depth_factor = 0.6;

uniform vec3 sun_direction = vec3(0.0, 0.0, 1.0);
// Colour × lux.
uniform vec3 sun_light = vec3(0.0);
uniform vec3 sky_light = vec3(0.0);
uniform vec3 ambient_light = vec3(0.0);
// 0: light, 2: receivers (debug view).
uniform int debug_view = 0;

varying vec2 local_px;

void vertex() {
	local_px = VERTEX;
}

void fragment() {
	vec2 screen_m = (area_origin_px + floor(local_px) + 0.5) / px_per_m;
	float best_d = -1e9;
	int found = -1;
	vec3 point = vec3(0.0);
	vec3 normal = vec3(0.0, 0.0, 1.0);
	for (int index = 0; index < receiver_count; index++) {
		vec4 a = texelFetch(receivers, ivec2(index * 3, 0), 0);
		vec4 b = texelFetch(receivers, ivec2(index * 3 + 1, 0), 0);
		vec4 c = texelFetch(receivers, ivec2(index * 3 + 2, 0), 0);
		vec3 n = vec3(a.w, b.w, c.w);
		// The pixel's line of sight: (x, d, d·depth − y); where does it cross the face's plane?
		float facing = n.y + depth_factor * n.z;
		if (facing <= 0.0) {
			continue;
		}
		float d = (dot(n, a.xyz) - n.x * screen_m.x + n.z * screen_m.y) / facing;
		if (d <= best_d) {
			continue;
		}
		vec3 p = vec3(screen_m.x, d, d * depth_factor - screen_m.y);
		vec3 w = p - a.xyz;
		float u = dot(w, b.xyz) / dot(b.xyz, b.xyz);
		float v = dot(w, c.xyz) / dot(c.xyz, c.xyz);
		if (u < -EDGE_TOLERANCE || u > 1.0 + EDGE_TOLERANCE || v < -EDGE_TOLERANCE || v > 1.0 + EDGE_TOLERANCE) {
			continue;
		}
		best_d = d;
		found = index;
		point = p;
		normal = n;
	}
	if (found < 0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else if (debug_view == 2) {
		vec3 hue = normal.z > 0.5 ? vec3(0.35, 0.55, 1.0) : (normal.y > 0.5 ? vec3(1.0, 0.6, 0.2) : vec3(0.4, 0.9, 0.4));
		COLOR = vec4(hue * (found % 2 == 0 ? 1.0 : 0.7), 1.0);
	} else {
		// Sky without occlusion yet: the open part of the dome a face sees (1 on top, ½ on a wall).
		vec3 light = ambient_light + sky_light * (1.0 + normal.z) * 0.5;
		float facing_sun = dot(normal, sun_direction);
		if (facing_sun > 0.0) {
			light += sun_light * facing_sun * visibility(point + normal * RAY_OFFSET_M, sun_direction, FAR_M);
		}
		COLOR = vec4(light, 1.0);
	}
}
