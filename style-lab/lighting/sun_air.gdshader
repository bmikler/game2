// PROTOTYPE (ticket 31): the sun beams in the air from SunGeometry. Each pixel's line of sight runs
// from the surface it shows up towards the viewer (more z, more d); samples on it that the sun reaches
// through a sash add light, fading with the distance from the window. Bars, furniture and the actor
// cut the beam because they cut the ray. Drawn additive over the house.
shader_type canvas_item;
render_mode unshaded, blend_add;

#include "res://lighting/sun_geometry.gdshaderinc"

uniform vec2 origin_px; // world px of this rect's top left
uniform vec3 source = vec3(0.0, 1.0, 1.0); // towards the sun
uniform int steps = 24;
uniform float density = 0.12; // light per metre of beam at the window
uniform float fade_m = 2.5; // the beam fades over this distance from the window

varying vec2 world_v;

const float BAYER[16] = float[](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);

void vertex() {
	world_v = origin_px + VERTEX;
}

void fragment() {
	vec2 world = floor(world_v) + 0.5;
	vec3 p;
	vec3 n;
	vec3 sum = vec3(0.0);
	if (surface_at(world, p, n)) {
		float d0 = (world.y - floor_y) / (ppm * kd);
		float z_end = min(shell_max.z, (shell_max.y - d0) * kd);
		if (z_end > p.z) {
			vec3 dir = normalize(source);
			float dz = (z_end - p.z) / float(steps);
			float metres = dz * sqrt(1.0 + 1.0 / (kd * kd));
			ivec2 cell = ivec2(world) % 4;
			float jitter = (BAYER[cell.y * 4 + cell.x] + 0.5) / 16.0;
			for (int i = 0; i < steps; i++) {
				float z = p.z + (float(i) + jitter) * dz;
				vec3 q = vec3(p.x, d0 + z / kd, z);
				float t;
				float lit = visible_through(q, dir, 1e8, t);
				if (lit > 0.0) {
					sum += room_at(q.xy) * exp(-t / fade_m) * metres;
				}
			}
		}
	}
	COLOR = vec4(sum * density, 1.0);
}
