// Light sources' geometry, shared by the source layers (built once) and the moving layer (every
// frame), so both light a point the same way. Include after visibility.gdshaderinc.

const int SOURCE_RECTANGLE = 1;
// A source's surface glows where it lies at most this far behind the surface the pixel shows (a
// window's rectangle on its wall).
const float GLOW_TOLERANCE_M = 0.05;

// Sources, four texels each: (centre, kind), (half_u, radius), (half_v, group), (normal, 0).
uniform sampler2D sources : filter_nearest;
uniform int source_count = 0;

// Where the pixel's line of sight (origin + t·sight, larger t nearer the camera) shows the source
// in front of the surface at `surface_t`.
bool shows_source(vec3 centre, int kind, vec3 half_u, vec3 half_v, float radius, vec3 n, vec3 origin,
		vec3 sight, float surface_t) {
	if (kind == SOURCE_RECTANGLE) {
		float facing = dot(n, sight);
		if (facing <= 0.0) {
			return false;
		}
		float t = dot(n, centre - origin) / facing;
		vec3 local = origin + sight * t - centre;
		return t >= surface_t - GLOW_TOLERANCE_M && abs(dot(local, half_u)) <= dot(half_u, half_u)
				&& abs(dot(local, half_v)) <= dot(half_v, half_v);
	}
	vec3 from_centre = origin - centre;
	float a = dot(sight, sight);
	float b = dot(from_centre, sight);
	float c = dot(from_centre, from_centre) - radius * radius;
	float discriminant = b * b - a * c;
	return discriminant >= 0.0 && (-b + sqrt(discriminant)) / a >= surface_t - GLOW_TOLERANCE_M;
}

// A point of the source's area at `u` (0 … 1 each), the area scaled by `scale` about its centre:
// over a rectangle, or over a sphere's outline seen from the point (the disc across the way to it).
vec3 source_point(int kind, vec3 centre, vec4 b, vec4 c, vec3 across_u, vec3 across_v, float scale, vec2 u) {
	if (kind == SOURCE_RECTANGLE) {
		return centre + (b.xyz * (u.x * 2.0 - 1.0) + c.xyz * (u.y * 2.0 - 1.0)) * scale;
	}
	float r = b.w * sqrt(u.x) * scale;
	float angle = TAU * u.y;
	return centre + (across_u * cos(angle) + across_v * sin(angle)) * r;
}

// What the source's area is scaled by for the one penumbra formula (visibility.gdshaderinc): the
// occluders over the widest area the penumbra can take give its distances. 1 when the penumbra is
// off or nothing blocks.
float source_penumbra_scale(int kind, vec3 centre, vec4 b, vec4 c, vec3 across_u, vec3 across_v, float extent,
		vec3 start) {
	if (!penumbra_on) {
		return 1.0;
	}
	float search = max(penumbra_gain, 1.0);
	float to_receiver = 0.0;
	float to_source = 0.0;
	int hits = 0;
	for (int k = -1; k < PENUMBRA_SEARCH; k++) {
		vec3 at = k < 0 ? centre
				: source_point(kind, centre, b, c, across_u, across_v, search, fract(0.5 + float(k) * R2));
		vec3 way = at - start;
		float length_m = length(way);
		float t = occluder_distance(start, way / length_m, length_m - RAY_OFFSET_M);
		if (t >= 0.0) {
			to_receiver += t;
			to_source += length_m - t;
			hits++;
		}
	}
	if (hits == 0) {
		return 1.0;
	}
	return penumbra_scale(2.0 * extent, to_source / float(hits), to_receiver / float(hits));
}
