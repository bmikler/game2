// A source layer: the light of one group of light sources (one profile) at intensity 1, without
// colour: falloff × the cosine at the receiver × visibility, averaged over each source's area (a
// rectangle also × its own cosine), summed over the group's sources. The same visibility function
// as the sun and the sky; the penumbra follows from the sources' size. Pixels that show a source
// itself (its sphere or its rectangle before the surface) glow with the falloff at 0.
// Built once per scene, a pass per frame: each pass adds the average of its samples (a fixed
// low-discrepancy set over the area, the same for every pixel and load: no noise) into a target
// never cleared in between; passes take turns in red, green and blue. The buffer divides the sum
// of the three by the passes done.
shader_type canvas_item;
render_mode unshaded, blend_add;

#include "res://addons/swiatlo/buffer/receivers.gdshaderinc"
#include "res://addons/swiatlo/buffer/visibility.gdshaderinc"
#include "res://addons/swiatlo/buffer/surfaces.gdshaderinc"

const int SOURCE_RECTANGLE = 1;
// A source's surface glows where it lies at most this far behind the surface the pixel shows (a
// window's rectangle on its wall).
const float GLOW_TOLERANCE_M = 0.05;
// The R2 sequence (plastic number): evenly covers the unit area for any count.
const vec2 R2 = vec2(0.7548776662, 0.5698402910);

// Sources, four texels each: (centre, kind), (half_u, radius), (half_v, group), (normal, 0).
uniform sampler2D sources : filter_nearest;
uniform int source_count = 0;
// The group this layer holds.
uniform int group = 0;
// The group's falloff over 0 … reach metres (SourceProfile.falloff_data).
uniform sampler2D falloff : filter_linear, repeat_disable;
uniform float reach_m = 1.0;
uniform int samples_per_pass = 8;
uniform int pass_count = 16;
uniform int pass_index = 0;

varying vec2 local_px;

void vertex() {
	local_px = VERTEX;
}

float falloff_at(float distance) {
	if (distance >= reach_m) {
		return 0.0;
	}
	float texels = float(textureSize(falloff, 0).x);
	return texture(falloff, vec2((distance / reach_m * (texels - 1.0) + 0.5) / texels, 0.5)).r;
}

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

void fragment() {
	vec3 point;
	vec3 normal;
	vec3 face_normal;
	bool found = find_surface(local_px, point, normal, face_normal) >= 0;
	vec2 screen_m = (area_origin_px + floor(local_px) + 0.5) / px_per_m;
	vec3 origin = vec3(screen_m.x, 0.0, -screen_m.y);
	vec3 sight = vec3(0.0, 1.0, depth_factor);
	float surface_t = found ? point.y : -1e9;
	vec3 start = point + face_normal * RAY_OFFSET_M;
	float light = 0.0;
	for (int index = 0; index < source_count; index++) {
		vec4 a = texelFetch(sources, ivec2(index * 4, 0), 0);
		vec4 b = texelFetch(sources, ivec2(index * 4 + 1, 0), 0);
		vec4 c = texelFetch(sources, ivec2(index * 4 + 2, 0), 0);
		if (int(round(c.w)) != group) {
			continue;
		}
		vec3 n = texelFetch(sources, ivec2(index * 4 + 3, 0), 0).xyz;
		vec3 centre = a.xyz;
		int kind = int(round(a.w));
		if (shows_source(centre, kind, b.xyz, c.xyz, b.w, n, origin, sight, surface_t)) {
			light += falloff_at(0.0);
			continue;
		}
		if (!found) {
			continue;
		}
		float extent = kind == SOURCE_RECTANGLE ? length(b.xyz + c.xyz) : b.w;
		if (distance(point, centre) - extent >= reach_m) {
			continue;
		}
		if (kind == SOURCE_RECTANGLE && dot(n, point - centre) <= 0.0) {
			continue;
		}
		// Sphere samples lie on its outline seen from the point: the disc across the way to it.
		vec3 toward = normalize(centre - point);
		vec3 helper = abs(toward.z) < 0.9 ? vec3(0.0, 0.0, 1.0) : vec3(1.0, 0.0, 0.0);
		vec3 across_u = normalize(cross(helper, toward));
		vec3 across_v = cross(toward, across_u);
		float sum = 0.0;
		for (int k = 0; k < samples_per_pass; k++) {
			// Passes interleave, so each one spreads over the whole area (a usable picture early).
			int i = k * pass_count + pass_index;
			vec2 u = fract(0.5 + float(i) * R2);
			vec3 at;
			if (kind == SOURCE_RECTANGLE) {
				at = centre + b.xyz * (u.x * 2.0 - 1.0) + c.xyz * (u.y * 2.0 - 1.0);
			} else {
				float r = b.w * sqrt(u.x);
				float angle = TAU * u.y;
				at = centre + (across_u * cos(angle) + across_v * sin(angle)) * r;
			}
			vec3 way = at - start;
			float length_m = length(way);
			vec3 direction = way / length_m;
			float cosine = dot(normal, direction);
			if (cosine <= 0.0) {
				continue;
			}
			float value = cosine * falloff_at(distance(point, at));
			if (kind == SOURCE_RECTANGLE) {
				value *= max(-dot(n, direction), 0.0);
			}
			if (value > 0.0) {
				sum += value * visibility(start, direction, length_m - RAY_OFFSET_M);
			}
		}
		light += sum / float(samples_per_pass);
	}
	vec3 channel = vec3(equal(ivec3(pass_index % 3), ivec3(0, 1, 2)));
	COLOR = vec4(channel * light, 1.0);
}
