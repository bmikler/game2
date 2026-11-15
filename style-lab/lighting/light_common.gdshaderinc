// PROTOTYPE (ticket 14): what the house (light_fn) and the street (street_fn) share: the lamps, the
// pixel-art look (ticket 37), the polygon form factor, the Light struct. Moved from light_fn unchanged.

#include "res://lighting/sun_geometry.gdshaderinc"

// The rooms' lamps: bulbs (x, d, z), colour × energy (lux on the floor right under them at their
// room's exposure), reach (m); 1/d² × cos, a shade, a bulb lamp_size across.
uniform int lamp_count = 0;
uniform vec3 lamps[16];
uniform vec3 lamp_color[16];
uniform float lamp_reach[16];
uniform float lamp_size = 0.1;
uniform int lamp_samples = 16;
uniform float shade_up = 0.25;

// The share kept: lit / arch, smooth (1 where the architecture lets nothing through). The levels and
// dither per source are gone (the human: thresholds on each source's soft share drew short, long and
// several hard shadows; the pixel-art look is to be done again, properly).
float kept(vec2 al, vec2 px) {
	return al.x > 1e-6 ? clamp(al.y / al.x, 0.0, 1.0) : 1.0;
}

// PROTOTYPE (ticket 37): the pixel-art look, applied to the exact light above (research 82).
// look: 0 smooth; 1 A, levels of the pixel's whole light (log steps, a Bayer band under each step);
// 2 B, the sky casts only a contact shadow, one hard shadow from the key light (sun, ribbons, night,
// lamps together: their light-weighted visibility past one threshold); 3 C, B and A.
uniform int look = 0;
uniform float level_stops = 0.5; // A: one level, in stops (log2 of the light)
uniform float level_band = 0.3; // A: the share of each step dithered under its upper edge
uniform float key_cut = 0.5; // B: the key's visibility where its shadow begins
uniform float key_band = 0.25; // B: the dithered band round key_cut (visibility units)
uniform float key_min = 0.2; // B: under this share of the pixel's light the key's shadow stays smooth
uniform float contact_m = 0.45; // B: how far the contact shadow reaches from an object's base (m)
uniform float contact_k = 0.6; // B: how dark it gets right at the base (of the sky)
uniform vec3 room_ambient[4]; // each room's flat ambient (its RoomLighting light), for A's levels
// Light pixels per world pixel (the view and the buffer rendered this much finer; sprites stay as they are).
uniform float light_res = 1.0;

// The light pixel holding world point w: its middle (world px), and its index (for the dither).
vec2 light_px_mid(vec2 w) {
	return (floor(w * light_res) + 0.5) / light_res;
}

vec2 light_px(vec2 w) {
	return floor(w * light_res);
}

bool look_levels() {
	return look == 1 || look == 3;
}

bool look_key() {
	return look >= 2;
}

float luma(vec3 c) {
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

// 0 or 1: v past `cut`, dithered by the game's Bayer 4×4 in a band `band` wide round it.
float dither_step(float v, float cut, float band, vec2 px) {
	float t = clamp((v - cut) / max(band, 1e-4) + 0.5, 0.0, 1.0);
	return bayer4(px) < t ? 1.0 : 0.0;
}

// A: `light` (on top of the flat `amb`) so that their sum takes one of the levels; never under amb.
vec3 light_levels(vec3 light, vec3 amb, vec2 px) {
	vec3 sum = light + amb;
	float l = luma(sum);
	if (l < 1e-5) {
		return light;
	}
	float e = log2(l) / level_stops;
	float k = floor(e);
	float f = e - k;
	float t = clamp((f - (1.0 - level_band)) / max(level_band, 1e-4), 0.0, 1.0);
	if (bayer4(px) < t) {
		k += 1.0;
	}
	float q = max(exp2((k + 0.5) * level_stops), luma(amb));
	return max(sum * (q / l) - amb, vec3(0.0));
}

// B: the contact shadow of the objects (furniture, stairs, the actor) on o, a share of the sky:
// strongest at an object's base, gone contact_m away (less for low objects); on an upright receiver
// only from objects in front of it and only near the floor; several as independent (1 − Π).
float contact_shade(vec3 o, vec3 n, bool with_actor) {
	float open = 1.0;
	bool upright = n.z < 0.5;
	for (int b = 0; b < box_count + 1; b++) {
		vec3 lo;
		vec3 hi;
		vec2 near;
		if (b < box_count) {
			if (box_arch[b] == 1) {
				continue;
			}
			lo = box_min[b];
			hi = box_max[b];
			near = clamp(o.xy, lo.xy, hi.xy);
		} else {
			if (!with_actor || actor_shape == 0) {
				continue;
			}
			lo = vec3(actor_body.xy - vec2(actor_body.z), 0.0);
			hi = vec3(actor_body.xy + vec2(actor_body.z), actor_body.w);
			if (actor_shape == 1) {
				vec2 off = o.xy - actor_body.xy;
				float len = length(off);
				near = len > actor_body.z ? actor_body.xy + off / len * actor_body.z : o.xy;
			} else {
				near = clamp(o.xy, lo.xy, hi.xy);
			}
		}
		vec2 to = near - o.xy;
		float flat_d = length(to);
		if (flat_d < 1e-3 && o.z >= hi.z - 0.02) {
			continue; // on its top
		}
		float up;
		if (upright) {
			if (flat_d < 1e-3 || dot(n.xy, to) <= 0.0) {
				continue; // its own face, or the object behind the face
			}
			up = max(o.z - lo.z, 0.0);
		} else {
			up = max(o.z - hi.z, 0.0);
		}
		float reach = contact_m * clamp((hi.z - lo.z) / 0.8, 0.25, 1.0);
		float a = 1.0 - clamp(length(vec2(flat_d, up)) / reach, 0.0, 1.0);
		open *= 1.0 - contact_k * a * a;
	}
	return 1.0 - open;
}

const int POLY_MAX = 16;

// Lambert's polygon form factor of p (on the wall, n = 0) from o with normal n, signed by the winding seen
// from o (as the sashes' in sky_light).
float polygon_factor(vec3 o, vec3 n, vec3 p[POLY_MAX], int count) {
	vec3 middle = vec3(0.0);
	for (int k = 0; k < count; k++) {
		middle += p[k];
	}
	vec3 towards = normalize(middle / float(count) - o);
	float f = 0.0;
	float winding = 0.0;
	for (int k = 0; k < count; k++) {
		vec3 a = normalize(p[k] - o);
		vec3 b = normalize(p[(k + 1) % count] - o);
		vec3 g = cross(a, b);
		float len = length(g);
		if (len > 1e-7) {
			float angle = acos(clamp(dot(a, b), -1.0, 1.0));
			f += angle * dot(n, g / len);
			winding += angle * dot(towards, g / len);
		}
	}
	return max(f * sign(winding), 0.0) / 6.2832;
}

// Keeps the part of polygon p with side × (z − limit) ≥ 0 (Sutherland–Hodgman, one edge).
int clip_z(inout vec3 p[POLY_MAX], int count, float limit, float side) {
	vec3 kept_p[POLY_MAX];
	int kept_count = 0;
	for (int k = 0; k < count; k++) {
		vec3 a = p[k];
		vec3 b = p[(k + 1) % count];
		float da = side * (a.z - limit);
		float db = side * (b.z - limit);
		if (da >= 0.0 && kept_count < POLY_MAX) {
			kept_p[kept_count] = a;
			kept_count++;
		}
		if ((da >= 0.0) != (db >= 0.0) && kept_count < POLY_MAX) {
			kept_p[kept_count] = mix(a, b, da / (da - db));
			kept_count++;
		}
	}
	for (int k = 0; k < kept_count; k++) {
		p[k] = kept_p[k];
	}
	return kept_count;
}

// The rooms' lamps from o (normal n), each in the look on its own.
vec3 lamp_light(vec3 o, vec3 n, vec2 px, bool with_actor, out vec3 arch) {
	vec3 total = vec3(0.0);
	arch = vec3(0.0);
	float turn = 0.0; // the same pattern in every pixel (turned per pixel: a 2×2 grain beside A's 1-px dither)
	for (int i = 0; i < lamp_count; i++) {
		vec3 bulb = lamps[i];
		vec3 to = bulb - o;
		float d = length(to);
		float reach = lamp_reach[i];
		float facing = dot(n, to / max(d, 1e-4));
		if (d > reach || facing <= 0.0) {
			continue;
		}
		float h = bulb.z;
		// At most twice the floor under it (a bulb by a wall burnt a hot spot), a shade sending most of
		// it down (sideways and up shade_up).
		float down = (bulb.z - o.z) / max(d, 1e-4);
		float shade = mix(shade_up, 1.0, smoothstep(-0.3, 0.7, down));
		float e = h * h / max(d * d, h * h * 0.5) * facing * shade * (1.0 - smoothstep(0.55 * reach, reach, d));
		vec3 axis = to / d;
		vec3 u;
		vec3 v;
		basis(axis, u, v);
		vec3 dirs[BUNDLE_MAX];
		float ends[BUNDLE_MAX];
		for (int k = 0; k < lamp_samples; k++) {
			vec2 j = vogel(k, lamp_samples, turn) * lamp_size * 0.5;
			dirs[k] = bulb + u * j.x + v * j.y - o;
			ends[k] = 1.0;
		}
		uint shut;
		uint hidden;
		bundle_hits(o, dirs, ends, lamp_samples, to, lamp_size * 0.5, with_actor, true, bulb, false, shut, hidden);
		float n_rays = float(lamp_samples);
		// ray_al per sample: architecture (0, 0), an object only (1, 0), open (1, 1).
		vec2 seen = vec2(n_rays - float(bitCount(shut)), n_rays - float(bitCount(shut | hidden)));
		vec3 through = lamp_color[i] * e * seen.x / float(lamp_samples);
		arch += through;
		total += through * kept(seen, px);
	}
	return total;
}

// B: a key source's light (`arch` what the architecture lets through, `lit` past the objects) with its
// visibility past key_cut, smooth where it is under key_min of the pixel's light (`rest` the others).
vec3 key_style(vec3 arch, vec3 lit, float rest, vec2 px) {
	float through = luma(arch);
	if (through < 1e-6) {
		return lit;
	}
	float v = clamp(luma(lit) / through, 0.0, 1.0);
	float share = through / (through + rest);
	return arch * mix(v, dither_step(v, key_cut, key_band, px), smoothstep(key_min * 0.5, key_min, share));
}

// What light_at() returns, by source (the debug views).
struct Light {
	vec3 sun;
	vec3 sky;
	vec3 night;
	vec3 lamps;
	vec4 shadow; // 1 − visibility: sun, sky, night, ribbons
};
