// The one visibility function of the light engine: every source (sun, sky, lamps) asks it whether
// a point sees the source along a direction. Occluders are the scene description's solids, two
// texels each: (min, kind), (max, eave). Kinds: 0 box, 1 roof with slopes along x, 2 roof with slopes
// along d, 3 upright cylinder, 4 silhouette (SolidShape.Kind). Every solid lies inside its box; all but
// the silhouette are convex. A silhouette's max.w is its frame's row in `silhouettes`
// (SilhouetteStack.data_of): texel 0 the anchor's x from the box's left edge, then per sprite pixel
// row (1 / px_per_m tall, from the box's bottom) two elliptic spans (centre x from the anchor, half
// width) and the row's half depth about the box's middle d.
// Include after receivers.gdshaderinc (px_per_m).

uniform sampler2D solids : filter_nearest;
uniform int solid_count = 0;
uniform sampler2D silhouettes : filter_nearest;

// Rays start this far off the face along its normal, so they do not begin inside the solid; and
// reach this far when nothing nearer stops them (sun, sky).
const float RAY_OFFSET_M = 0.02;
const float FAR_M = 1000.0;

const int SOLID_ROOF_X = 1;
const int SOLID_ROOF_D = 2;
const int SOLID_CYLINDER = 3;
const int SOLID_SILHOUETTE = 4;
// The most sprite rows a ray crosses in one silhouette (the loop's bound; taller ones are cut).
const int SILHOUETTE_MAX_ROWS = 160;

// The span within `range` where the ray's footprint (xy) is inside the ellipse (centre, radius);
// enter > leave: it misses.
vec2 ellipse_span(vec2 point, vec2 direction, vec2 centre, vec2 radius, vec2 range) {
	vec2 from_axis = (point - centre) / radius;
	vec2 along = direction / radius;
	float a = dot(along, along);
	float b = dot(from_axis, along);
	float c = dot(from_axis, from_axis) - 1.0;
	if (a < 1e-12) {
		return c > 0.0 ? vec2(1.0, 0.0) : range;
	}
	float discriminant = b * b - a * c;
	if (discriminant < 0.0) {
		return vec2(1.0, 0.0);
	}
	float root = sqrt(discriminant);
	return vec2(max(range.x, (-b - root) / a), min(range.y, (-b + root) / a));
}

// The ray through a silhouette inside its box span `box_span`, slab by slab in the order the ray
// meets them. `last` false: the first span the ray is still in or meets ahead (leave > 0), for
// visibility; true: from the first enter to the last leave, with the outward normal where it
// leaves (the side of that slab's ellipse), for the surface a sprite pixel lies on.
vec2 silhouette_span(vec4 low, vec4 high, vec2 box_span, vec3 point, vec3 direction, bool last,
		inout vec3 exit_normal) {
	int frame = int(round(high.w));
	int rows = (textureSize(silhouettes, 0).x - 1) / 2;
	float row_m = 1.0 / px_per_m;
	float anchor_x = low.x + texelFetch(silhouettes, ivec2(0, frame), 0).x;
	float middle_d = (low.y + high.y) * 0.5;
	float z_a = point.z + direction.z * box_span.x;
	float z_b = point.z + direction.z * box_span.y;
	int row_a = clamp(int(floor((z_a - low.z) / row_m)), 0, rows - 1);
	int row_b = clamp(int(floor((z_b - low.z) / row_m)), 0, rows - 1);
	int step_row = row_b >= row_a ? 1 : -1;
	int count = min(abs(row_b - row_a) + 1, SILHOUETTE_MAX_ROWS);
	vec2 result = vec2(1.0, 0.0);
	for (int k = 0; k < SILHOUETTE_MAX_ROWS; k++) {
		if (k >= count) {
			break;
		}
		int row = row_a + k * step_row;
		vec2 range = box_span;
		if (abs(direction.z) > 1e-9) {
			float t0 = (low.z + float(row) * row_m - point.z) / direction.z;
			float t1 = (low.z + float(row + 1) * row_m - point.z) / direction.z;
			range = vec2(max(range.x, min(t0, t1)), min(range.y, max(t0, t1)));
		}
		if (range.y < range.x) {
			continue;
		}
		vec4 spans = texelFetch(silhouettes, ivec2(1 + row * 2, frame), 0);
		float depth = texelFetch(silhouettes, ivec2(2 + row * 2, frame), 0).x;
		if (depth <= 0.0) {
			continue;
		}
		for (int s = 0; s < 2; s++) {
			vec2 span_x = s == 0 ? spans.xy : spans.zw;
			if (span_x.y <= 0.0) {
				continue;
			}
			vec2 centre = vec2(anchor_x + span_x.x, middle_d);
			vec2 radius = vec2(span_x.y, depth);
			vec2 hit = ellipse_span(point.xy, direction.xy, centre, radius, range);
			if (hit.y < hit.x) {
				continue;
			}
			if (!last) {
				if (hit.y > 0.0 && (result.y < result.x || hit.x < result.x)) {
					result = hit;
				}
			} else {
				if (result.y < result.x || hit.y > result.y) {
					vec2 at = point.xy + direction.xy * hit.y - centre;
					exit_normal = normalize(vec3(at / (radius * radius) + vec2(0.0, 1e-6), 0.0));
				}
				result = result.y < result.x ? hit : vec2(min(result.x, hit.x), max(result.y, hit.y));
			}
		}
		if (!last && result.y >= result.x) {
			break;
		}
	}
	return result;
}

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
// outward normal of the face where it leaves. A silhouette (not convex): `last` picks which span
// (silhouette_span).
vec2 solid_span_of(int index, vec3 point, vec3 direction, bool last, out vec3 exit_normal) {
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
	if (kind == SOLID_SILHOUETTE) {
		if (span.y >= span.x) {
			span = silhouette_span(low, high, span, point, direction, last, exit_normal);
		}
	} else if (kind == SOLID_ROOF_X || kind == SOLID_ROOF_D) {
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

// The surface a line of sight shows: the whole way through the solid, leaving nearest the camera.
vec2 solid_span_exit(int index, vec3 point, vec3 direction, out vec3 exit_normal) {
	return solid_span_of(index, point, direction, true, exit_normal);
}

// For visibility: the first span the ray is in or meets ahead.
vec2 solid_span(int index, vec3 point, vec3 direction) {
	vec3 unused;
	return solid_span_of(index, point, direction, false, unused);
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

// The same with only the solids `first` … `last − 1` blocking.
float visibility_between(vec3 point, vec3 direction, float reach, int first, int last) {
	for (int index = first; index < last; index++) {
		vec2 span = solid_span(index, point, direction);
		if (span.y > max(span.x, 0.0) && span.x < reach) {
			return 0.0;
		}
	}
	return 1.0;
}

// Distance along the ray to the nearest solid that blocks it within `reach` metres (−1: none).
float occluder_distance(vec3 point, vec3 direction, float reach) {
	float nearest = -1.0;
	for (int index = 0; index < solid_count; index++) {
		vec2 span = solid_span(index, point, direction);
		if (span.y > max(span.x, 0.0) && span.x < reach) {
			float t = max(span.x, 0.0);
			nearest = nearest < 0.0 ? t : min(nearest, t);
		}
	}
	return nearest;
}

// Penumbra (engine ticket 14): the tuning set's gain and widest penumbra in screen pixels. Off (the
// F1 comparison): the sun casts hard shadows and a source's penumbra follows its size alone.
uniform bool penumbra_on = true;
uniform float penumbra_gain = 1.0;
uniform float penumbra_max_px = 8.0;

// Rays sent to find the occluders a source's penumbra starts from (besides the central one).
const int PENUMBRA_SEARCH = 4;
// The R2 sequence (plastic number): evenly covers the unit area for any count.
const vec2 R2 = vec2(0.7548776662, 0.5698402910);

// The one penumbra formula: its width at the receiver (metres) from the source's size and the
// distances source → occluder → receiver, × the gain, at most the widest penumbra.
float penumbra_width(float source_size, float source_to_occluder, float occluder_to_receiver) {
	float width = source_size * occluder_to_receiver / max(source_to_occluder, 1e-4) * penumbra_gain;
	return min(width, penumbra_max_px / px_per_m);
}

// What a source's size is multiplied by so that its own penumbra (sampled over its area) takes the
// formula's width; 1 when the penumbra is off.
float penumbra_scale(float source_size, float source_to_occluder, float occluder_to_receiver) {
	float physical = source_size * occluder_to_receiver / max(source_to_occluder, 1e-4);
	if (!penumbra_on || physical < 1e-6) {
		return 1.0;
	}
	return penumbra_width(source_size, source_to_occluder, occluder_to_receiver) / physical;
}

// Sample `i` of a fixed even set over the unit disc.
vec2 disc_sample(int i, int count) {
	vec2 u = fract(0.5 + float(i) * R2);
	float r = sqrt((float(i) + 0.5) / float(count));
	return vec2(cos(TAU * u.y), sin(TAU * u.y)) * r;
}

// As many as the widest penumbra's pixels by default: A′ steps show no finer sampling.
const int SUN_SAMPLES = 8;

// The share of the sun's disc (radius `tan_disc`, as a tangent) seen from `point` around the unit
// `direction`. The disc is scaled so its penumbra takes the formula's width at the occluders found;
// hard (one ray) when the penumbra is off.
float sun_visibility(vec3 point, vec3 direction, float tan_disc) {
	if (!penumbra_on || tan_disc <= 0.0) {
		return visibility(point, direction, FAR_M);
	}
	vec3 helper = abs(direction.z) < 0.9 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
	vec3 u = normalize(cross(helper, direction));
	vec3 v = cross(direction, u);
	// Occluders over the widest disc the penumbra can take.
	float search = tan_disc * max(penumbra_gain, 1.0);
	float total = 0.0;
	int hits = 0;
	for (int k = -1; k < PENUMBRA_SEARCH; k++) {
		vec2 s = k < 0 ? vec2(0.0) : disc_sample(k, PENUMBRA_SEARCH);
		float t = occluder_distance(point, normalize(direction + (u * s.x + v * s.y) * search), FAR_M);
		if (t >= 0.0) {
			total += t;
			hits++;
		}
	}
	// None blocked: the whole disc is seen; all blocked: the umbra (the final disc lies inside the
	// searched one). Only pixels near a shadow's edge sample the disc.
	if (hits == 0) {
		return 1.0;
	}
	if (hits == PENUMBRA_SEARCH + 1) {
		return 0.0;
	}
	// The sun as a disc FAR_M away: size 2 · tan_disc · FAR_M.
	float radius = tan_disc * penumbra_scale(2.0 * tan_disc * FAR_M, FAR_M, total / float(hits));
	float seen = 0.0;
	for (int k = 0; k < SUN_SAMPLES; k++) {
		vec2 s = disc_sample(k, SUN_SAMPLES);
		seen += visibility(point, normalize(direction + (u * s.x + v * s.y) * radius), FAR_M);
	}
	return seen / float(SUN_SAMPLES);
}
