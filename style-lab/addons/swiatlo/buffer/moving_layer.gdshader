// The moving layer: the light buffer's source channel (natural or artificial, lux) and sky share
// with the moving Occluders in them, drawn over the rect round the moving windows (MovingLayer).
// Outside the moving windows it copies the layers built once (SourceLight's channel, the sky layer). Inside them:
// - a pixel of a moving asset's sprite (it moves, the layers built once never saw it) takes the light
//   of every source in the channel the way a source layer computes it, and the sky share from a
//   fixed set of directions, with every solid blocking;
// - any other pixel loses what the moving solids block: per source the light that reaches it past the
//   static solids but not past the moving ones (the same samples and penumbra formula as a source
//   layer), and its sky share × the share of the sky the moving solids leave open (each an upright
//   cylinder round its box, analytically: no samples).
// Shadows of the sun come from the buffer itself (its solids include the moving ones).
shader_type canvas_item;
render_mode unshaded, blend_disabled;

#include "res://addons/swiatlo/buffer/receivers.gdshaderinc"
#include "res://addons/swiatlo/buffer/visibility.gdshaderinc"
#include "res://addons/swiatlo/buffer/surfaces.gdshaderinc"
#include "res://addons/swiatlo/buffer/sources.gdshaderinc"

const int MAX_GROUPS = 16;
const int MAX_WINDOWS = 8;
const float GOLDEN_ANGLE = 2.39996323;

// The channel this pass holds (SourceProfile.Channel: 0 natural, 1 artificial) and its layers built
// once (lux, black without any).
uniform int channel = 1;
uniform sampler2D channel_in : filter_nearest;
uniform bool has_channel_in = false;
// Whether this pass also holds the sky share (in alpha): the sky layer's counts × their scale.
uniform bool with_sky = false;
uniform sampler2D sky_counts : filter_nearest;
uniform float sky_share_scale = 0.0;
// Per source group: colour × lux at the hour, channel, reach; falloffs one row per group
// (SourceProfile.falloff_data).
uniform vec3 group_light[MAX_GROUPS];
uniform int group_channel[MAX_GROUPS];
uniform float group_reach[MAX_GROUPS];
uniform sampler2D falloffs : filter_linear, repeat_disable;
// Solids from `static_solid_count` on and assets above `static_asset_count` are moving.
uniform int static_solid_count = 0;
uniform int static_asset_count = 0;
// Buffer pixels (x0, y0, x1, y1) where the moving solids can change the light.
uniform vec4 windows[MAX_WINDOWS];
uniform int window_count = 0;
// Samples of each source's area and of the sky for a moving sprite's pixel, every frame (engine
// constants, not tuning).
uniform int samples = 32;
uniform int sky_samples = 64;

varying vec2 local_px;

void vertex() {
	// The rect drawn this frame may be a part of the area: its pixels in the whole area's.
	local_px = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

float falloff_of(int group, float distance) {
	float reach = group_reach[group];
	if (distance >= reach) {
		return 0.0;
	}
	vec2 size = vec2(textureSize(falloffs, 0));
	return texture(falloffs, vec2((distance / reach * (size.x - 1.0) + 0.5) / size.x, (float(group) + 0.5) / size.y)).r;
}

bool in_window(vec2 px) {
	for (int index = 0; index < MAX_WINDOWS; index++) {
		if (index >= window_count) {
			break;
		}
		vec4 w = windows[index];
		if (px.x >= w.x && px.y >= w.y && px.x < w.z && px.y < w.w) {
			return true;
		}
	}
	return false;
}

// Whether the segment from `start` along `direction` (unit) for `length_m` metres passes within
// `margin` metres of a moving solid's box.
bool passes_moving(vec3 start, vec3 direction, float length_m, float margin) {
	vec3 inverse = 1.0 / mix(direction, vec3(1e-9), lessThan(abs(direction), vec3(1e-9)));
	for (int index = static_solid_count; index < solid_count; index++) {
		vec3 low = texelFetch(solids, ivec2(index * 2, 0), 0).xyz - vec3(margin);
		vec3 high = texelFetch(solids, ivec2(index * 2 + 1, 0), 0).xyz + vec3(margin);
		vec3 t0 = (low - start) * inverse;
		vec3 t1 = (high - start) * inverse;
		vec3 near = min(t0, t1);
		vec3 far = max(t0, t1);
		float enter = max(max(near.x, near.y), near.z);
		float leave = min(min(far.x, far.y), far.z);
		if (leave >= max(enter, 0.0) && enter <= length_m) {
			return true;
		}
	}
	return false;
}

// The light of the channel's sources at a point (lux): all of it (`blocked_only` false), or only what
// the moving solids block of what passes the static ones.
vec3 source_light(vec3 point, vec3 normal, vec3 face_normal, vec3 origin, vec3 sight, float surface_t,
		bool blocked_only) {
	vec3 start = point + face_normal * RAY_OFFSET_M;
	vec3 total = vec3(0.0);
	for (int index = 0; index < source_count; index++) {
		vec4 a = texelFetch(sources, ivec2(index * 4, 0), 0);
		vec4 b = texelFetch(sources, ivec2(index * 4 + 1, 0), 0);
		vec4 c = texelFetch(sources, ivec2(index * 4 + 2, 0), 0);
		int group = int(round(c.w));
		// Groups off at this hour add nothing.
		if (group >= MAX_GROUPS || group_channel[group] != channel || group_light[group] == vec3(0.0)) {
			continue;
		}
		vec3 n = texelFetch(sources, ivec2(index * 4 + 3, 0), 0).xyz;
		vec3 centre = a.xyz;
		int kind = int(round(a.w));
		if (shows_source(centre, kind, b.xyz, c.xyz, b.w, n, origin, sight, surface_t)) {
			if (!blocked_only) {
				total += group_light[group] * falloff_of(group, 0.0);
			}
			continue;
		}
		float extent = kind == SOURCE_RECTANGLE ? length(b.xyz + c.xyz) : b.w;
		if (distance(point, centre) - extent >= group_reach[group]) {
			continue;
		}
		if (kind == SOURCE_RECTANGLE && dot(n, point - centre) <= 0.0) {
			continue;
		}
		if (blocked_only) {
			vec3 way = centre - start;
			float length_m = length(way);
			if (!passes_moving(start, way / length_m, length_m, extent * max(penumbra_gain, 1.0))) {
				continue;
			}
		}
		vec3 toward = normalize(centre - point);
		vec3 helper = abs(toward.z) < 0.9 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
		vec3 across_u = normalize(cross(helper, toward));
		vec3 across_v = cross(toward, across_u);
		float scale = source_penumbra_scale(kind, centre, b, c, across_u, across_v, extent, start);
		float sum = 0.0;
		for (int k = 0; k < samples; k++) {
			vec3 at = source_point(kind, centre, b, c, across_u, across_v, scale, fract(0.5 + float(k) * R2));
			vec3 way = at - start;
			float length_m = length(way);
			vec3 direction = way / length_m;
			float cosine = dot(normal, direction);
			if (cosine <= 0.0) {
				continue;
			}
			float value = cosine * falloff_of(group, distance(point, at));
			if (kind == SOURCE_RECTANGLE) {
				value *= max(-dot(n, direction), 0.0);
			}
			if (value <= 0.0) {
				continue;
			}
			float reach = length_m - RAY_OFFSET_M;
			if (blocked_only) {
				value *= (1.0 - visibility_between(start, direction, reach, static_solid_count, solid_count))
						* visibility_between(start, direction, reach, 0, static_solid_count);
			} else {
				value *= visibility(start, direction, reach);
			}
			sum += value;
		}
		total += group_light[group] * (sum / float(samples));
	}
	return total;
}

// The sky share of a moving sprite's pixel (1: the whole sky), from a fixed set of cosine-weighted
// directions as the sky layer's.
float sampled_sky(vec3 point, vec3 normal, vec3 face_normal) {
	vec3 helper = abs(normal.z) < 0.9 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
	vec3 tangent = normalize(cross(helper, normal));
	vec3 bitangent = cross(normal, tangent);
	vec3 start = point + face_normal * RAY_OFFSET_M;
	float seen = 0.0;
	for (int i = 0; i < sky_samples; i++) {
		float r = sqrt((float(i) + 0.5) / float(sky_samples));
		float angle = float(i) * GOLDEN_ANGLE;
		vec3 direction = tangent * (r * cos(angle)) + bitangent * (r * sin(angle)) + normal * sqrt(max(1.0 - r * r, 0.0));
		if (direction.z > 0.0) {
			seen += visibility(start, direction, FAR_M);
		}
	}
	return seen / float(sky_samples);
}

// ∫ (n_h cos e + n_z sin e) cos e de from 0 to e: the cosine-weighted sky of a vertical strip.
float strip_integral(float n_h, float n_z, float e) {
	return n_h * (e * 0.5 + sin(2.0 * e) * 0.25) + n_z * sin(e) * sin(e) * 0.5;
}

// The share of the sky (of what the normal sees above the horizon) the moving solids leave open,
// each an upright cylinder round its box (radius: the mean of its half width and half depth).
float moving_sky_open(vec3 point, vec3 normal) {
	float upper = (1.0 + normal.z) * 0.5;
	if (upper <= 1e-4) {
		return 1.0;
	}
	float hidden = 0.0;
	for (int index = static_solid_count; index < solid_count; index++) {
		vec3 low = texelFetch(solids, ivec2(index * 2, 0), 0).xyz;
		vec3 high = texelFetch(solids, ivec2(index * 2 + 1, 0), 0).xyz;
		float radius = ((high.x - low.x) + (high.y - low.y)) * 0.25;
		vec2 to_axis = (low.xy + high.xy) * 0.5 - point.xy;
		float distance_m = max(length(to_axis), radius * 1.001);
		vec2 h = length(to_axis) > 1e-6 ? to_axis / length(to_axis) : vec2(0.0, 1.0);
		float width = 2.0 * asin(radius / distance_m);
		float e0 = max(atan(low.z - point.z, distance_m), 0.0);
		float e1 = max(atan(high.z - point.z, distance_m), e0);
		float n_h = dot(normal.xy, h);
		float strip = strip_integral(n_h, normal.z, e1) - strip_integral(n_h, normal.z, e0);
		hidden += max(strip, 0.0) * width / PI;
	}
	return clamp(1.0 - hidden / upper, 0.0, 1.0);
}

void fragment() {
	ivec2 at = ivec2(local_px);
	vec3 light = has_channel_in ? texelFetch(channel_in, at, 0).rgb : vec3(0.0);
	float sky = 0.0;
	if (with_sky) {
		vec3 counts = texelFetch(sky_counts, at, 0).rgb;
		sky = (counts.r + counts.g + counts.b) * sky_share_scale;
	}
	if (in_window(local_px)) {
		vec3 point;
		vec3 normal;
		vec3 face_normal;
		int found = find_surface(local_px, point, normal, face_normal);
		if (found >= 0) {
			vec2 screen_m = (area_origin_px + floor(local_px) + 0.5) / px_per_m;
			vec3 origin = vec3(screen_m.x, 0.0, -screen_m.y);
			vec3 sight = vec3(0.0, 1.0, depth_factor);
			if (found > static_asset_count) {
				light = source_light(point, normal, face_normal, origin, sight, point.y, false);
				if (with_sky) {
					sky = sampled_sky(point, normal, face_normal);
				}
			} else {
				light = max(light - source_light(point, normal, face_normal, origin, sight, point.y, true), vec3(0.0));
				if (with_sky) {
					sky *= moving_sky_open(point, normal);
				}
			}
		}
	}
	COLOR = vec4(light, sky);
}
