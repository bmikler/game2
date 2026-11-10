// PROTOTYPE (ticket 31): the side windows' sun as a ribbon on the floor, computed from SunGeometry.
// A floor point is lit when the sun's horizontal direction, traced back from it, meets its wall
// inside a pane column (widened along the wall as the human set it, and growing on the column's own
// side with the distance, so the mullion's gap stays clean), no box (furniture, partition, stairs)
// stands in between, and it is nearer the wall than where light through the head lands (× reach_k),
// fading on the way. Under furniture and actors (z), additive.
shader_type canvas_item;
render_mode unshaded, blend_add;

#include "res://lighting/sun_geometry.gdshaderinc"

uniform vec2 origin_px;
uniform vec3 source = vec3(0.0, 1.0, 1.0); // towards the sun
uniform int ribbon_count = 0;
uniform vec4 ribbons[16]; // a pane column: u from, u to, z from, z to
uniform int ribbon_wall[16]; // 2 left, 3 right
uniform float ribbon_mid[16]; // u of the middle of its window
uniform float gain = 1.0;
uniform float reach_k = 1.0;
uniform float span_k = 1.0; // along the wall, × this round the window's middle
uniform float widen = 0.5; // extra width per metre of travel, × the column's width
uniform float edge_m = 0.12; // soft edges along the wall
uniform float side_facing_full = 0.6;
uniform float fade_power = 1.4;
// Furniture casts a short contact shadow in the ribbon, gone this far behind it (the flat ribbon made
// every box a wall: a floor lamp cut a long wedge at a low sun, the human: the ribbon breaks).
// A full-height box (a partition) still stops the ribbon.
uniform float shadow_m = 1.0;

varying vec2 world_v;

// 0 lit .. 1 dark: the strongest shadow on the floor ray o + s·dir, s in (0, t_max).
float ribbon_shadow(vec3 o, vec3 dir, float t_max) {
	vec3 inv = vec3(abs(dir.x) > 1e-8 ? 1.0 / dir.x : 1e8, abs(dir.y) > 1e-8 ? 1.0 / dir.y : 1e8, 1e8);
	float shade = 0.0;
	for (int i = 0; i < box_count; i++) {
		vec3 lo = box_min[i];
		vec3 hi = box_max[i];
		if (o.z < lo.z || o.z > hi.z) {
			continue;
		}
		vec2 t0 = (lo.xy - o.xy) * inv.xy;
		vec2 t1 = (hi.xy - o.xy) * inv.xy;
		float near = max(min(t0.x, t1.x), min(t0.y, t1.y));
		float far = min(max(t0.x, t1.x), max(t0.y, t1.y));
		if (far < max(near, 0.0) || near > t_max) {
			continue;
		}
		if (hi.z >= shell_max.z - 0.05) {
			return 1.0;
		}
		shade = max(shade, 1.0 - smoothstep(0.0, shadow_m, max(near, 0.0)));
	}
	// The actor (ticket 33, the critic: side windows cast no actor shadow, their ribbons passed through
	// it): its cylinder seen along the ribbon, a soft edge, fading over ~2 m behind it.
	if (actor_shape > 0) {
		vec2 along_dir = dir.xy / max(length(dir.xy), 1e-6);
		vec2 rel = actor_middle() - o.xy;
		float along = dot(rel, along_dir);
		if (along > 0.0 && along < t_max * length(dir.xy)) {
			float across = abs(rel.x * along_dir.y - rel.y * along_dir.x);
			float body = 1.0 - smoothstep(actor_body.z * 0.7, actor_body.z * 1.3, across);
			shade = max(shade, body * (1.0 - smoothstep(0.8, 2.2, along)));
		}
	}
	return shade;
}

void vertex() {
	world_v = origin_px + VERTEX;
}

void fragment() {
	vec2 world = floor(world_v) + 0.5;
	vec3 p;
	vec3 n;
	vec3 sum = vec3(0.0);
	float c = length(source.xy);
	if (c > 1e-4 && surface_at(world, p, n) && p.z < 0.01 && n.z > 0.5) {
		vec2 h = source.xy / c;
		for (int i = 0; i < ribbon_count; i++) {
			float nx = ribbon_wall[i] == 2 ? -1.0 : 1.0;
			float facing = h.x * nx;
			if (facing <= 0.0) {
				continue;
			}
			float wx = ribbon_wall[i] == 2 ? shell_min.x : shell_max.x;
			float t = (wx - p.x) / h.x;
			vec4 s = ribbons[i];
			float reach = s.w * c * reach_k;
			if (t <= 0.0 || t >= reach) {
				continue;
			}
			float mid = ribbon_mid[i];
			float lo = mid + (s.x - mid) * span_k;
			float hi = mid + (s.y - mid) * span_k;
			float grow = (hi - lo) * widen * t;
			if ((lo + hi) * 0.5 < mid - 0.01) {
				lo -= grow;
			} else if ((lo + hi) * 0.5 > mid + 0.01) {
				hi += grow;
			} else {
				lo -= grow * 0.5;
				hi += grow * 0.5;
			}
			float u = p.y + h.y * t;
			// A constant soft edge: one growing with t bent the edges as the ribbon faded (the human).
			float inside = smoothstep(lo - edge_m, lo + edge_m, u) * (1.0 - smoothstep(hi - edge_m, hi + edge_m, u));
			if (inside <= 0.0) {
				continue;
			}
			float shade = ribbon_shadow(vec3(p.x, p.y, 0.05), vec3(h, 0.0), t);
			float fade = pow(1.0 - t / reach, fade_power);
			sum += room_at(p.xy) * inside * fade * (1.0 - shade) * smoothstep(0.0, side_facing_full, facing);
		}
	}
	COLOR = vec4(sum * gain, 1.0);
}
