// The one visibility function of the light engine: every source (sun, sky, lamps) asks it whether
// a point sees the source along a direction. Occluders are the scene description's solids
// (boxes in metres, two texels each: min, max).

uniform sampler2D solids : filter_nearest;
uniform int solid_count = 0;

// 1 when nothing blocks the ray from `point` along the unit `direction` within `reach` metres,
// 0 when a solid does.
float visibility(vec3 point, vec3 direction, float reach) {
	vec3 inverse = 1.0 / direction;
	for (int index = 0; index < solid_count; index++) {
		vec3 low = texelFetch(solids, ivec2(index * 2, 0), 0).xyz;
		vec3 high = texelFetch(solids, ivec2(index * 2 + 1, 0), 0).xyz;
		vec3 t0 = (low - point) * inverse;
		vec3 t1 = (high - point) * inverse;
		vec3 near = min(t0, t1);
		vec3 far = max(t0, t1);
		float enter = max(max(near.x, near.y), near.z);
		float leave = min(min(far.x, far.y), far.z);
		if (leave > max(enter, 0.0) && enter < reach) {
			return 0.0;
		}
	}
	return 1.0;
}
