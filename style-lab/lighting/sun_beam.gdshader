// PROTOTYPE (ticket 36): a back window's sun beam in the air. Its shape is the hand-drawn polygon of
// ticket 27 (BeamCanvas: from the glass narrowing into its patch, vertex colours fading along it); its
// brightness inside is the visibility of the sun along the pixel's line of sight, from the same
// function as the floor: of the line's points the sun reaches through this beam's sash, the share no
// occluder (furniture, partitions, the actor) stands in front of, in the shadows' look.
shader_type canvas_item;
render_mode unshaded, blend_add;

#include "res://lighting/light_fn.gdshaderinc"

uniform int beam_sash = -1;
uniform int steps = 16;

varying vec2 world_v;

void vertex() {
	world_v = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 world = floor(world_v) + 0.5;
	vec3 p;
	vec3 n;
	vec2 al = vec2(0.0);
	if (surface_at(world, p, n)) {
		float d0 = (world.y - floor_y) / (ppm * kd);
		float z_end = min(shell_max.z, (shell_max.y - d0) * kd);
		vec3 dir = normalize(sun_dir);
		float jitter = bayer4(world);
		for (int i = 0; i < steps; i++) {
			float z = mix(p.z, z_end, (float(i) + jitter) / float(steps));
			vec3 q = vec3(p.x, d0 + z / kd, z);
			int face;
			float t = shell_exit(q, dir, face);
			if (sash_at(q + dir * t, face) != beam_sash) {
				continue;
			}
			al += ray_al(occlusion(q, dir, t, true, false, vec3(0.0)));
		}
	}
	COLOR = vec4(COLOR.rgb * kept(al, world), 1.0);
}
