// The one visibility function of the light engine: every source (sun, sky, lamps) asks it whether
// a point sees the source along a direction. Occluders are the scene description's solids, two
// texels each: (min, kind), (max, eave). Kinds: 0 box, 1 roof with slopes along x, 2 roof with slopes
// along d, 3 upright cylinder (SolidShape.Kind). Every solid is convex and lies inside its box.

uniform sampler2D solids : filter_nearest;
uniform int solid_count = 0;

// Rays start this far off the face along its normal, so they do not begin inside the solid; and
// reach this far when nothing nearer stops them (sun, sky).
const float RAY_OFFSET_M = 0.02;
const float FAR_M = 1000.0;

const int SOLID_ROOF_X = 1;
const int SOLID_ROOF_D = 2;
const int SOLID_CYLINDER = 3;

// Cuts the ray's span [enter, leave] to the half-space dot(n, p) <= k; when the plane cuts the
// leaving end, `exit_normal` becomes the plane's.
vec2 clip_to_plane(vec2 span, vec3 point, vec3 direction, vec3 n, float k, inout vec3 exit_normal) {
	float denom = dot(n, direction);
	float room = k - dot(n, point);
	if (abs(denom) < 1e-9) {
		return room < 0.0 ? vec2(1.0, 0.0) : span;
	}
	float t = room / denom;
	if (denom > 0.0) {
		if (t < span.y) {
			exit_normal = normalize(n);
		}
		return vec2(span.x, min(span.y, t));
	}
	return vec2(max(span.x, t), span.y);
}

// Distances along the ray where it enters and leaves the solid (enter > leave: it misses), and the
// outward normal of the face where it leaves.
vec2 solid_span_exit(int index, vec3 point, vec3 direction, out vec3 exit_normal) {
	vec4 low = texelFetch(solids, ivec2(index * 2, 0), 0);
	vec4 high = texelFetch(solids, ivec2(index * 2 + 1, 0), 0);
	// Axis-parallel rays: a tiny component instead of zero (1 / 0 is not reliably infinite on GPUs).
	vec3 inverse = 1.0 / mix(direction, vec3(1e-9), lessThan(abs(direction), vec3(1e-9)));
	vec3 t0 = (low.xyz - point) * inverse;
	vec3 t1 = (high.xyz - point) * inverse;
	vec3 near = min(t0, t1);
	vec3 far = max(t0, t1);
	vec2 span = vec2(max(max(near.x, near.y), near.z), min(min(far.x, far.y), far.z));
	exit_normal = far.x == span.y ? vec3(sign(direction.x), 0.0, 0.0)
			: (far.y == span.y ? vec3(0.0, sign(direction.y), 0.0) : vec3(0.0, 0.0, sign(direction.z)));
	int kind = int(round(low.w));
	if (kind == SOLID_ROOF_X || kind == SOLID_ROOF_D) {
		// Two slopes from the eave (high.w) at the walls up to the ridge at the top of the box.
		int a = kind == SOLID_ROOF_X ? 0 : 1;
		float gradient = (high.z - high.w) / ((high[a] - low[a]) * 0.5);
		vec3 n = vec3(0.0, 0.0, 1.0);
		n[a] = -gradient;
		span = clip_to_plane(span, point, direction, n, high.w - low[a] * gradient, exit_normal);
		n[a] = gradient;
		span = clip_to_plane(span, point, direction, n, high.w + high[a] * gradient, exit_normal);
	} else if (kind == SOLID_CYLINDER) {
		vec2 radius = (high.xy - low.xy) * 0.5;
		vec2 from_axis = (point.xy - (low.xy + radius)) / radius;
		vec2 along = direction.xy / radius;
		float a = dot(along, along);
		float b = dot(from_axis, along);
		float c = dot(from_axis, from_axis) - 1.0;
		if (a < 1e-12) {
			if (c > 0.0) {
				span = vec2(1.0, 0.0);
			}
		} else {
			float discriminant = b * b - a * c;
			if (discriminant < 0.0) {
				span = vec2(1.0, 0.0);
			} else {
				float root = sqrt(discriminant);
				float leave = (-b + root) / a;
				if (leave < span.y) {
					vec2 at = from_axis + along * leave;
					exit_normal = normalize(vec3(at / radius, 0.0));
				}
				span = vec2(max(span.x, (-b - root) / a), min(span.y, leave));
			}
		}
	}
	return span;
}

vec2 solid_span(int index, vec3 point, vec3 direction) {
	vec3 unused;
	return solid_span_exit(index, point, direction, unused);
}

// 1 when nothing blocks the ray from `point` along the unit `direction` within `reach` metres,
// 0 when a solid does; the solids `skip_first` … `skip_first + skip_count − 1` do not block.
float visibility_skipping(vec3 point, vec3 direction, float reach, int skip_first, int skip_count) {
	for (int index = 0; index < solid_count; index++) {
		if (index >= skip_first && index < skip_first + skip_count) {
			continue;
		}
		vec2 span = solid_span(index, point, direction);
		if (span.y > max(span.x, 0.0) && span.x < reach) {
			return 0.0;
		}
	}
	return 1.0;
}

// The same with every solid blocking.
float visibility(vec3 point, vec3 direction, float reach) {
	return visibility_skipping(point, direction, reach, 0, 0);
}
