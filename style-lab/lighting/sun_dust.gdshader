// PROTOTYPE (ticket 31): dust in the window sun from SunGeometry. Each mote (a RoomLighting dust
// particle) hangs at a height picked by its random seed (its colour's red, from the initial ramp);
// it glows when that 3D point sees the sun through a sash past the boxes, so it shows only inside the
// real beam (the same prism as the patch), and bars, furniture and the actor cut it out. A mote that
// a box (a partition, furniture: as drawn, cut down) hides from the viewer shows nothing.
shader_type canvas_item;
render_mode unshaded, blend_add, world_vertex_coords;

#include "res://lighting/sun_geometry.gdshaderinc"

uniform vec3 source = vec3(0.0, 1.0, 1.0); // towards the sun
uniform float fade_m = 6.0; // as the beams: fading with the distance from the window
uniform vec4 dust_color = vec4(1.0, 0.92, 0.8, 0.22);
uniform float gain = 1.0;
uniform float low_m = 0.1; // motes hang between these heights
uniform float high_m = 2.1;

varying vec3 light_v;

// Something drawn stands between q and the viewer (the line of sight: d + s / kd, z + s).
bool hidden(vec3 q) {
	vec3 dir = vec3(0.0, 1.0 / kd, 1.0);
	vec3 inv = vec3(1e8, kd, 1.0);
	for (int i = 0; i < box_count; i++) {
		float top = box_top[i];
		if (top < 0.0) {
			continue;
		}
		vec3 hi = vec3(box_max[i].xy, top);
		if (q.x < box_min[i].x || q.x > hi.x) {
			continue;
		}
		vec3 t0 = (box_min[i] - q) * inv;
		vec3 t1 = (hi - q) * inv;
		float near = max(min(t0.y, t1.y), min(t0.z, t1.z));
		float far = min(max(t0.y, t1.y), max(t0.z, t1.z));
		if (far >= max(near, 0.0)) {
			return true;
		}
	}
	return false;
}

void vertex() {
	float h = mix(low_m, high_m, COLOR.r);
	vec3 q = vec3(VERTEX.x / ppm, (VERTEX.y - floor_y + h * ppm) / (ppm * kd), h);
	light_v = vec3(0.0);
	if (all(greaterThan(q, shell_min)) && all(lessThan(q, shell_max)) && !hidden(q)) {
		float t;
		float lit = visible_through(q, normalize(source), 1e8, t);
		if (lit > 0.0) {
			light_v = room_at(q.xy) * lit * exp(-t / fade_m);
		}
	}
}

void fragment() {
	COLOR = vec4(dust_color.rgb * light_v * gain, dust_color.a);
}
