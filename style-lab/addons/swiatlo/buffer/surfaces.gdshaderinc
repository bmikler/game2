// What a buffer pixel shows: an asset's sprite pixel (solid receivers: the asset layer says which
// asset) or else a scene receiver. Include after receivers.gdshaderinc and visibility.gdshaderinc.
// Shared by every layer of the light buffer, so they agree pixel by pixel.

// The asset layer (asset_layer.gdshader): red ±(asset number from 1, + ½ with a normal, the sign the
// normal's d), green and blue the normal's x and z; 0 where no sprite is.
uniform sampler2D asset_layer : filter_nearest;
// Assets, one texel each: (first solid, solid count, front d, 0).
uniform sampler2D assets : filter_nearest;
// Receivers' modelling (tuning set): 0 the solid face's normal, 1 the normal map's.
uniform float modelling = 1.0;

// The surface at the buffer pixel `local_px`: −1 none, 0 a scene receiver, n > 0 the sprite of asset
// n. `point` is where it lies (metres: x right, d towards the camera, z up), `normal` the normal light
// falls on, `face_normal` the normal of the solid's face (or plane) under it: rays start off that.
int find_surface(vec2 local_px, out vec3 point, out vec3 normal, out vec3 face_normal) {
	vec4 layer = texelFetch(asset_layer, ivec2(local_px), 0);
	// Red is ±(number + ½ with a normal): the whole part is the asset, a half the normal's tag.
	float tagged = abs(layer.r);
	int asset = int(floor(tagged + 0.01));
	bool has_map_normal = fract(tagged + 0.01) > 0.25;
	if (asset <= 0) {
		int found = find_receiver(local_px, point, normal);
		face_normal = normal;
		return found < 0 ? -1 : 0;
	}
	vec4 entry = texelFetch(assets, ivec2(asset - 1, 0), 0);
	int first = int(round(entry.x));
	int last = first + int(round(entry.y));
	vec2 screen_m = (area_origin_px + floor(local_px) + 0.5) / px_per_m;
	// The pixel's line of sight: origin + t·sight is (x, t, t·depth − y); it leaves the solid nearest
	// the camera at the largest t.
	vec3 origin = vec3(screen_m.x, 0.0, -screen_m.y);
	vec3 sight = vec3(0.0, 1.0, depth_factor);
	float best = -1e9;
	face_normal = vec3(0.0, 1.0, 0.0);
	for (int index = first; index < last; index++) {
		vec3 n;
		vec2 span = solid_span_exit(index, origin, sight, n);
		if (span.y >= span.x && span.y > best) {
			best = span.y;
			face_normal = n;
		}
	}
	if (best > -1e8) {
		point = origin + sight * best;
	} else {
		// No face beneath (AssetEntry.rest_point): above a top, the upright plane halfway through the
		// highest such top; anything else, the front plane of the outline of all the asset's solids.
		float plane_d = entry.z;
		float best_top = -1e9;
		for (int index = first; index < last; index++) {
			vec4 low = texelFetch(solids, ivec2(index * 2, 0), 0);
			vec4 high = texelFetch(solids, ivec2(index * 2 + 1, 0), 0);
			if (screen_m.x < low.x || screen_m.x > high.x) {
				continue;
			}
			float middle_d = (low.y + high.y) * 0.5;
			if (middle_d * depth_factor - screen_m.y >= high.z && high.z > best_top) {
				best_top = high.z;
				plane_d = middle_d;
			}
		}
		point = vec3(screen_m.x, plane_d, plane_d * depth_factor - screen_m.y);
	}
	normal = face_normal;
	if (has_map_normal) {
		float across = sqrt(max(1.0 - layer.g * layer.g - layer.b * layer.b, 0.0));
		vec3 mapped = vec3(layer.g, layer.r < 0.0 ? -across : across, layer.b);
		vec3 mixed = mix(face_normal, mapped, modelling);
		if (dot(mixed, mixed) > 1e-6) {
			normal = normalize(mixed);
		}
	}
	return asset;
}

// The asset's solids (first, count) for rays that should pass them (its own rim light).
ivec2 asset_solids(int asset) {
	vec4 entry = texelFetch(assets, ivec2(asset - 1, 0), 0);
	return ivec2(int(round(entry.x)), int(round(entry.y)));
}
