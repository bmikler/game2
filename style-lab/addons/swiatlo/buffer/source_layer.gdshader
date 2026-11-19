// A source layer: the light of one group of light sources (one profile) at intensity 1, without
// colour: falloff × the cosine at the receiver × visibility, averaged over each source's area (a
// rectangle also × its own cosine), summed over the group's sources. The same visibility function
// as the sun and the sky; the penumbra follows from the sources' size through the one penumbra
// formula (visibility.gdshaderinc). Pixels that show a source
// itself (its sphere or its rectangle before the surface) glow with the falloff at 0. A rectangle's
// pixels (a lit pane) take no light from other groups: glass reflects other light as a mirror, not
// diffusely, and its own glow outshines that reflection.
// Built once per scene, a pass per frame: each pass adds the average of its samples (a fixed
// low-discrepancy set over the area, the same for every pixel and load: no noise) into a target
// never cleared in between; passes take turns in red, green and blue. The buffer divides the sum
// of the three by the passes done.
shader_type canvas_item;
render_mode unshaded, blend_add;

#include "res://addons/swiatlo/buffer/receivers.gdshaderinc"
#include "res://addons/swiatlo/buffer/visibility.gdshaderinc"
#include "res://addons/swiatlo/buffer/surfaces.gdshaderinc"
#include "res://addons/swiatlo/buffer/sources.gdshaderinc"

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

// Whether the pixel shows the rectangle of a source outside this layer's group.
bool shows_other_groups_pane(vec3 origin, vec3 sight, float surface_t) {
	for (int index = 0; index < source_count; index++) {
		vec4 a = texelFetch(sources, ivec2(index * 4, 0), 0);
		vec4 c = texelFetch(sources, ivec2(index * 4 + 2, 0), 0);
		if (int(round(a.w)) != SOURCE_RECTANGLE || int(round(c.w)) == group) {
			continue;
		}
		vec4 b = texelFetch(sources, ivec2(index * 4 + 1, 0), 0);
		vec3 n = texelFetch(sources, ivec2(index * 4 + 3, 0), 0).xyz;
		if (shows_source(a.xyz, SOURCE_RECTANGLE, b.xyz, c.xyz, b.w, n, origin, sight, surface_t)) {
			return true;
		}
	}
	return false;
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
	bool on_glass = shows_other_groups_pane(origin, sight, surface_t);
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
		// On another group's pane only this group's own surfaces (a lamp before the window) show.
		if (!found || on_glass) {
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
		// Penumbra: occluders over the widest area the penumbra can take give the distances of the one
		// formula; the source's area is scaled so its own penumbra takes the formula's width.
		float scale = source_penumbra_scale(kind, centre, b, c, across_u, across_v, extent, start);
		float sum = 0.0;
		for (int k = 0; k < samples_per_pass; k++) {
			// Passes interleave, so each one spreads over the whole area (a usable picture early).
			int i = k * pass_count + pass_index;
			vec3 at = source_point(kind, centre, b, c, across_u, across_v, scale, fract(0.5 + float(i) * R2));
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
