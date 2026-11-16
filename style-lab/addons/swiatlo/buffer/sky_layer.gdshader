// The sky layer: how much of the sky dome each buffer pixel's receiver sees, weighted by the cosine
// to its normal (1: open ground under the whole sky, ½: an open wall). Geometry only, no colour.
// Built once per scene, a pass per frame: each pass adds its share of a fixed set of directions
// (spherical Fibonacci, cosine-weighted about the normal) into a target that is never cleared in
// between. A fixed set is the same for every pixel and every load: no noise, no flicker.
// The target holds counts of open directions, not fractions: whole numbers up to 2048 add exactly
// in half floats (fractions lost up to 3 % to rounding). Passes take turns in red, green and blue,
// so the three together hold up to 6144 directions; the buffer divides their sum by the directions
// done.
shader_type canvas_item;
render_mode unshaded, blend_add;

#include "res://addons/swiatlo/buffer/receivers.gdshaderinc"
#include "res://addons/swiatlo/buffer/visibility.gdshaderinc"

const float GOLDEN_ANGLE = 2.39996323;

// Directions in each pass, how many passes and which one this is.
uniform int samples_per_pass = 64;
uniform int pass_count = 32;
uniform int pass_index = 0;

varying vec2 local_px;

void vertex() {
	local_px = VERTEX;
}

void fragment() {
	vec3 point;
	vec3 normal;
	float seen = 0.0;
	int sample_count = samples_per_pass * pass_count;
	if (find_receiver(local_px, point, normal) >= 0) {
		vec3 helper = abs(normal.z) < 0.9 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
		vec3 tangent = normalize(cross(helper, normal));
		vec3 bitangent = cross(normal, tangent);
		vec3 start = point + normal * RAY_OFFSET_M;
		for (int k = 0; k < samples_per_pass; k++) {
			// Passes interleave, so each one spreads over the whole dome (a usable picture early).
			int i = k * pass_count + pass_index;
			// Even area on the unit disc, lifted onto the hemisphere: cosine-weighted directions.
			float r = sqrt((float(i) + 0.5) / float(sample_count));
			float angle = float(i) * GOLDEN_ANGLE;
			vec3 direction = tangent * (r * cos(angle)) + bitangent * (r * sin(angle))
					+ normal * sqrt(max(1.0 - r * r, 0.0));
			// The sky is the dome above the horizon; below it lies the ground.
			if (direction.z > 0.0) {
				seen += visibility(start, direction, FAR_M);
			}
		}
	}
	vec3 channel = vec3(equal(ivec3(pass_index % 3), ivec3(0, 1, 2)));
	COLOR = vec4(channel * seen, 1.0);
}
