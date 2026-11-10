// PROTOTYPE (ticket 36): the back windows' sun beams as a volume (the variant to compare with the
// polygons): each pixel's line of sight runs from the surface it shows up towards the viewer; samples
// on it the sun reaches through a back sash past the occluders add light, fading with the distance
// from the window. The same visibility as the floor (light_fn), additive over the house.
shader_type canvas_item;
render_mode unshaded, blend_add;

#include "res://lighting/light_fn.gdshaderinc"

uniform vec2 origin_px; // world px of this rect's top left
uniform int steps = 24;
uniform float density = 0.08; // light per metre of beam at the window
uniform float fade_m = 6.0; // the beam fades over this distance from the window

varying vec2 world_v;

void vertex() {
	world_v = origin_px + VERTEX;
}

void fragment() {
	vec2 world = floor(world_v) + 0.5;
	vec3 p;
	vec3 n;
	vec3 sum = vec3(0.0);
	if (sun_on == 1 && surface_at(world, p, n)) {
		float d0 = (world.y - floor_y) / (ppm * kd);
		float z_end = min(shell_max.z, (shell_max.y - d0) * kd);
		if (z_end > p.z) {
			vec3 dir = normalize(sun_dir);
			float dz = (z_end - p.z) / float(steps);
			float metres = dz * sqrt(1.0 + 1.0 / (kd * kd));
			float jitter = bayer4(world);
			for (int i = 0; i < steps; i++) {
				float z = p.z + (float(i) + jitter) * dz;
				vec3 q = vec3(p.x, d0 + z / kd, z);
				int face;
				float t = shell_exit(q, dir, face);
				if (face != 0 || sash_at(q + dir * t, face) < 0 || blocked(q, dir, t, true)) {
					continue;
				}
				sum += room_sun[room_index(q.xy)] * exp(-t / fade_m) * metres;
			}
		}
	}
	COLOR = vec4(sum * density, 1.0);
}
