// PROTOTYPE (ticket 31): the window light on the floor, the back wall and the boxes, per pixel, from
// SunGeometry. Rendered in a SubViewport over the house; a PointLight2D lights the scene with it.
shader_type canvas_item;
render_mode unshaded, blend_disabled;

#include "res://lighting/sun_geometry.gdshaderinc"

uniform vec2 origin_px; // world px of this viewport's top left

// Pixel in the map: the house from 0, the actor strip from house_w. The rect, not the viewport: the
// actor's own small viewport shows only the strip (its rect starts at -house_w).
varying vec2 local;

void vertex() {
	local = VERTEX;
}
uniform int point_source = 0; // 0 the sun or a far light (source: towards it), 1 a lamp (source: where it is), 2 the lamps below, 3 the rooms' lamps
// The rooms' lamps (point_source 3): bulbs (x, d, z m), colour × energy giving their lux on the floor
// right under them at their room's exposure, reach (m: fading out by then); 1/d² × cos, soft shadows
// from a bulb lamp_size m across.
uniform int room_lamp_count = 0;
uniform vec3 room_lamps[16];
uniform vec3 room_lamp_color[16];
uniform float room_lamp_reach[16];
uniform float lamp_size = 0.1;
uniform int lamp_soft = 6;
uniform float shade_up = 0.25; // a lamp's light sideways and up, × this (its shade)
uniform int lamp_count = 0;
uniform vec3 lamps[8];
uniform vec3 source = vec3(0.0, 1.0, 1.0);
uniform int soft_count = 1;
uniform float soft_radius = 0.0; // sun: tan of the disc's angle; lamp: metres
uniform float wall_max = 1.5; // a wall facing a low sun gets at most this × the floor's light
// Sky light through the windows (the sun map only): the form factor of every sash's glass seen from the
// point (Lambert's polygon formula: smooth, no noise), each sash dimmed by how many of 4 rays to its
// glass architecture cuts; over sky_ref (the factor by a window gives the room's sky light).
uniform int sky_count = 0; // > 0: on
uniform float sky_ref = 0.25;
uniform vec3 room_sky[4];
// The bottom wall's windows, not drawn, show by a steady glow of sky in front of them (the human).
uniform float front_glow = 1.0;
// Sky through a window of another room (seen through a doorway), × this: from both sides alike, as a
// slanted wedge cut by the doorway (the human: odd), so mostly the window's own room.
uniform float sky_other_k = 0.0;
// The bottom wall's glow reaches deeper: its form factor f → sky_ref·(f/sky_ref)^front_gamma (< 1:
// the far floor gains, by the glass it stays). The street door, an opening in that wall, × door_k.
uniform float front_gamma = 1.0;
// Sky through the side windows (their sun patch stays off: side_walls); the windows of every wall and
// the door share one rule: front_glow and front_gamma (the human: every side in sync).
uniform int sky_side = 1;
// Towards the sun, flat, × the direction gain (zero by night): the sky is brighter on the sun's side.
uniform vec2 sky_sun = vec2(0.0);
uniform int door_sash = -1;
uniform float door_k = 0.35;
// The actor's light (ticket 31): a strip right of the house (x from house_w, actor_strip px) holds the
// light on the actor standing at actor_feet (x, d metres), feet at the strip's bottom middle.
// actor_mode 0 none, 1 the floor's light at the feet on the whole body, 2 the body: the sun at each
// body point through the glass, the sky round it (4 sides) and the floor's light bounced up.
uniform float house_w = 1e9;
uniform vec2 actor_strip = vec2(32.0, 96.0);
uniform vec2 actor_feet = vec2(0.0);
uniform int actor_mode = 0;
uniform float actor_radius = 0.22;
uniform float actor_sun_k = 0.7; // the sun on the body × this (a round body: part of it faces away)
uniform float actor_bounce = 0.3; // the floor's light at the feet bounced up, × this (fading up the body)
uniform float actor_gain = 1.0;
uniform float actor_sky_k = 1.0; // the sky through the glass on the body, × this (by a bottom window: too bright, the human)
uniform float actor_lamp_k = 0.7; // the rooms' lamps on the body, × this (a round body: part faces away)

// ---- Ticket 35: one shadow model for every object (box_object 1) and the actor ----
// Every occluder casts by the same rules (ticket 33's preset A4, first made for the actor), each
// measured from the occluder's base point nearest to the shadowed point (no anchor in its middle: a
// wide box's shadow stays parallel along it and widens past its corners):
// - a lamp counts shadow_stretch times farther from that point (a shorter, slower-widening shadow),
//   its shadow shadow_lamp_length times longer (the point drawn back towards the occluder);
// - the sun counts as a point shadow_sun_point m from it (0: parallel), so its shadow widens;
// - the source's angle shadow_angle grows away from the occluder (shadow_gradient: × 1 + 4·g at
//   shadow_fade_m), a soft far end;
// - the sky: rays to a grid over each glass, every occluder taking sky_shadow_k of what it covers,
//   fading out by sky_shadow_reach m from it, plus a contact oval of sky taken round its base.
// Architecture (partitions, lintels, the shell, the window bars) stays hard as it was.
// The map holds the light left per source; the look (smooth, 3 levels dithered, 2 hard) quantizes each
// source's share taken (the sun, the sky, each lamp) apart, on the world's pixels.
// The actor's shadow window (ticket 33): right of the actor strip (x from house_w + actor_strip.x), a
// window of shadow_size px whose top left is shadow_origin (world px) holds the same map with the
// actor in it, every frame (lit.gdshader takes it there instead of the house map). shadow_sources:
// which of this map's lights the actor shadows: bit 1 the direct light, 2 the sky, 4 the rooms' lamps.
uniform vec2 shadow_origin = vec2(0.0);
uniform vec2 shadow_size = vec2(0.0);
uniform int shadow_sources = 0;
uniform float shadow_angle = 0.03;
uniform float shadow_stretch = 3.0;
uniform int shadow_samples = 16;
uniform float shadow_sun_point = 0.0;
uniform float shadow_lamp_length = 1.0;
uniform float shadow_gradient = 0.0;
uniform float shadow_fade_m = 2.5;
uniform float shadow_k = 1.0; // the share an occluder takes, × this
uniform int object_length = 1; // 0: the lamp's longer shadow (shadow_lamp_length) for the actor only
uniform float sky_shadow_k = 0.6;
uniform float sky_shadow_reach = 3.0;
uniform float sky_shadow_contact = 0.5;
uniform int sky_grid = 4; // rays per glass: sky_grid × sky_grid
uniform int shadow_look = 0; // 0 smooth, 1 three levels dithered, 2 two levels hard

float bayer4(vec2 p) {
	int x = int(mod(p.x, 4.0));
	int y = int(mod(p.y, 4.0));
	int i = y * 4 + x;
	int m[16] = int[](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
	return (float(m[i]) + 0.5) / 16.0;
}

// The share of a source the occluders take, as the look shows it (px: the world pixel).
float look_share(float share, vec2 px) {
	share = clamp(share, 0.0, 1.0);
	if (shadow_look == 0) {
		return share;
	}
	float steps = shadow_look == 1 ? 2.0 : 1.0;
	// Dithered only in a band round each step (a full-range dither turned a faint shadow into sparse
	// dots over a wide area).
	float t = shadow_look == 1 ? 0.5 + (bayer4(floor(px)) - 0.5) * 0.6 : 0.5;
	return clamp(floor(share * steps + t), 0.0, steps) / steps;
}

vec3 any_side(vec3 axis) {
	return normalize(abs(axis.z) < 0.99 ? cross(axis, vec3(0.0, 0.0, 1.0)) : cross(axis, vec3(1.0, 0.0, 0.0)));
}

// Occluder i (-1: the actor): its base point nearest to o (x, d, its base z); gap: how far o is from it.
vec3 occluder_anchor(int i, vec3 o, out float gap) {
	if (i < 0) {
		vec2 middle = actor_middle();
		vec2 rel = o.xy - middle;
		float len = length(rel);
		float r = actor_body.z;
		vec2 a = len > r ? middle + rel / len * r : o.xy;
		gap = length(vec2(max(len - r, 0.0), max(o.z, 0.0)));
		return vec3(a, 0.0);
	}
	vec3 lo = box_min[i];
	vec3 hi = box_max[i];
	vec2 a = clamp(o.xy, lo.xy, hi.xy);
	gap = length(vec2(distance(o.xy, a), max(o.z - lo.z, 0.0)));
	return vec3(a, lo.z);
}

bool occluder_hit(int i, vec3 ro, vec3 rd, float reach) {
	if (i < 0) {
		return hit_actor(ro, rd, reach);
	}
	vec3 inv = vec3(
			abs(rd.x) > 1e-8 ? 1.0 / rd.x : 1e8,
			abs(rd.y) > 1e-8 ? 1.0 / rd.y : 1e8,
			abs(rd.z) > 1e-8 ? 1.0 / rd.z : 1e8);
	return hit_box(ro, inv, box_min[i], box_max[i], reach);
}

// A lamp's own pole and shade (the bulb inside or just above it) cast nothing.
bool own_fixture(int i, vec3 bulb) {
	return all(greaterThanEqual(bulb, box_min[i] - 0.02)) && all(lessThanEqual(bulb, box_max[i] + vec3(0.02, 0.02, 0.15)));
}

// Which of shadow_samples samples of the source occluder i hides from o, as bits (point 1: a bulb at
// src; 0: a far light towards src).
int occluder_mask(int i, vec3 o, vec3 src, int point) {
	float gap;
	vec3 a = occluder_anchor(i, o, gap);
	vec3 ro = o;
	vec3 to;
	float reach = 1.0;
	bool parallel = false;
	if (point == 1) {
		if (i < 0 || object_length == 1) {
			// Drawn back towards the occluder along the lamp's direction: the shadow longer, not wider.
			vec2 away = src.xy - a.xy;
			float level = length(away);
			if (level > 1e-4 && shadow_lamp_length > 1.0) {
				away = -away / level;
				float along = dot(o.xy - a.xy, away);
				if (along > 0.0) {
					ro = vec3(o.xy + away * (along / shadow_lamp_length - along), o.z);
				}
			}
		}
		to = a + (src - a) * shadow_stretch - ro;
	} else if (shadow_sun_point > 0.0) {
		to = a + normalize(src) * shadow_sun_point - o;
	} else {
		to = normalize(src);
		reach = 1e8;
		parallel = true;
	}
	float d = length(to);
	vec3 axis = to / max(d, 1e-5);
	vec3 u = any_side(axis);
	vec3 v = cross(axis, u);
	float angle = shadow_angle * (1.0 + 4.0 * shadow_gradient * smoothstep(0.0, shadow_fade_m, gap));
	float spread = angle * (parallel ? 1.0 : d);
	int mask = 0;
	for (int s = 0; s < shadow_samples; s++) {
		vec2 j = vogel(s, shadow_samples) * spread;
		if (occluder_hit(i, ro, to + u * j.x + v * j.y, reach)) {
			mask |= 1 << s;
		}
	}
	return mask;
}

// The share of the source the occluders (with_actor: and the actor) hide from o.
float occluders_share(vec3 o, vec3 src, int point, bool with_actor) {
	int mask = 0;
	if (with_actor && actor_shape > 0) {
		mask = occluder_mask(-1, o, src, point);
	}
	for (int i = 0; i < box_count; i++) {
		if (box_object[i] == 0 || (point == 1 && own_fixture(i, src))) {
			continue;
		}
		mask |= occluder_mask(i, o, src, point);
	}
	int hits = 0;
	for (int s = 0; s < shadow_samples; s++) {
		hits += (mask >> s) & 1;
	}
	return float(hits) / float(shadow_samples);
}

vec3 sash_corner(int i, int k) {
	vec4 s = sashes[i];
	float u = (k == 1 || k == 2) ? s.y : s.x;
	float z = k >= 2 ? s.w : s.z;
	int wall = sash_wall[i];
	if (wall == 0) { return vec3(u, shell_min.y, z); }
	if (wall == 1) { return vec3(u, shell_max.y, z); }
	if (wall == 2) { return vec3(shell_min.x, u, z); }
	return vec3(shell_max.x, u, z);
}

// Sash i's sky at o (normal n) before any object: its form factor, the architecture's cut, the room,
// the sun's side, the glow.
float sash_sky(int i, vec3 o, vec3 n, int own, out vec3 c[4], out bool usable) {
	usable = false;
	for (int k = 0; k < 4; k++) {
		c[k] = sash_corner(i, k);
	}
	if (sky_side == 0 && sash_wall[i] >= 2) {
		return 0.0;
	}
	vec3 middle = (c[0] + c[2]) / 2.0;
	float other = room_index(middle.xy) == own ? 1.0 : sky_other_k;
	if (other <= 0.0) {
		return 0.0;
	}
	float f = 0.0;
	for (int k = 0; k < 4; k++) {
		vec3 a = normalize(c[k] - o);
		vec3 b = normalize(c[(k + 1) % 4] - o);
		vec3 g = cross(a, b);
		float len = length(g);
		if (len > 1e-6) {
			f += acos(clamp(dot(a, b), -1.0, 1.0)) * dot(n, g / len);
		}
	}
	f = abs(f) / 6.2832;
	// Every wall alike (the human: the back windows lit the floor less than the others).
	f = sky_ref * pow(f / sky_ref, front_gamma);
	if (f < 1e-4) {
		return 0.0;
	}
	float open = 0.0;
	for (int k = 0; k < 4; k++) {
		vec3 to = mix(middle, c[k], 0.6) - o;
		open += blocked_arch(o, to, 0.999) ? 0.0 : 0.25;
	}
	int w = sash_wall[i];
	vec2 normal = w == 0 ? vec2(0.0, -1.0) : (w == 1 ? vec2(0.0, 1.0) : (w == 2 ? vec2(-1.0, 0.0) : vec2(1.0, 0.0)));
	float towards = max(0.2, 1.0 + dot(normal, sky_sun));
	usable = open > 0.0;
	return f * open * other * towards * front_glow * (i == door_sash ? door_k : 1.0);
}

// Sky at o (normal n): x the sky with no object, y the share of it the occluders take (with the look).
vec2 sky_light(vec3 o, vec3 n, bool with_actor, vec2 px) {
	int own = room_index(o.xy);
	// Each occluder's weight (its reach) and whether it can stand between o and any glass at all.
	float weight[65];
	float total = 0.0;
	float taken = 0.0;
	float contact = 0.0;
	int count = box_count + 1;
	for (int i = 0; i < count; i++) {
		int id = i < box_count ? i : -1;
		weight[i] = 0.0;
		if ((id >= 0 && box_object[id] == 0) || (id < 0 && !(with_actor && actor_shape > 0))) {
			continue;
		}
		float gap;
		occluder_anchor(id, o, gap);
		weight[i] = sky_shadow_k * (1.0 - smoothstep(0.5 * sky_shadow_reach, sky_shadow_reach, gap));
		// Contact: an oval of sky taken round its base, on the floor (as ambient occlusion).
		if (o.z < 0.05) {
			float g;
			if (id < 0) {
				g = length((o.xy - actor_middle()) * vec2(1.0, 1.6)) - actor_body.z;
			} else {
				vec2 rel = o.xy - clamp(o.xy, box_min[id].xy, box_max[id].xy);
				g = box_min[id].z < 0.05 ? length(rel * vec2(1.0, 1.6)) : 1e3;
			}
			contact = max(contact, sky_shadow_contact * (1.0 - smoothstep(-0.05, 0.32, g)));
		}
	}
	float step_k = 1.0 / float(sky_grid);
	for (int i = 0; i < sash_count; i++) {
		vec3 c[4];
		bool usable;
		float s = sash_sky(i, o, n, own, c, usable);
		if (!usable || s <= 0.0) {
			continue;
		}
		total += s;
		// The glass's bounds with o: an occluder outside them cannot cut a ray to it.
		vec3 lo = min(min(o, c[0]), min(min(c[1], c[2]), c[3]));
		vec3 hi = max(max(o, c[0]), max(max(c[1], c[2]), c[3]));
		float hidden = 0.0;
		for (int gx = 0; gx < sky_grid; gx++) {
			for (int gy = 0; gy < sky_grid; gy++) {
				vec2 uv = (vec2(float(gx), float(gy)) + 0.5) * step_k;
				vec3 q = mix(mix(c[0], c[1], uv.x), mix(c[3], c[2], uv.x), uv.y);
				vec3 to = q - o;
				float ray = 0.0;
				for (int k = 0; k < count; k++) {
					if (weight[k] <= ray) {
						continue;
					}
					int id = k < box_count ? k : -1;
					if (id >= 0 && (any(greaterThan(box_min[id], hi)) || any(lessThan(box_max[id], lo)))) {
						continue;
					}
					if (occluder_hit(id, o, to, 0.999)) {
						ray = weight[k];
					}
				}
				hidden += ray;
			}
		}
		taken += s * hidden * step_k * step_k;
	}
	if (total <= 0.0) {
		return vec2(0.0);
	}
	float share = max(taken / total, contact);
	return vec2(total, look_share(min(share * shadow_k, 1.0), px));
}

// The old sky share (the actor's body: every box hard, no look).
float sky_share(vec3 o, vec3 n) {
	float total = 0.0;
	int own = room_index(o.xy);
	for (int i = 0; i < sash_count; i++) {
		vec3 c[4];
		bool usable;
		float s = sash_sky(i, o, n, own, c, usable);
		if (!usable || s <= 0.0) {
			continue;
		}
		vec3 middle = (c[0] + c[2]) / 2.0;
		float open = 0.0;
		for (int k = 0; k < 4; k++) {
			open += blocked(o, mix(middle, c[k], 0.6) - o, 0.999) ? 0.0 : 0.25;
		}
		total += s * open;
	}
	return total;
}

// Blocked between o and the bulb at o + dir (t 0..1), past boxes holding the bulb (its lamp's own).
// arch: architecture only (the shared model shades the rest).
bool blocked_lamp(vec3 o, vec3 dir, vec3 bulb, bool arch) {
	vec3 inv = vec3(
			abs(dir.x) > 1e-8 ? 1.0 / dir.x : 1e8,
			abs(dir.y) > 1e-8 ? 1.0 / dir.y : 1e8,
			abs(dir.z) > 1e-8 ? 1.0 / dir.z : 1e8);
	for (int i = 0; i < box_count; i++) {
		if ((arch && box_object[i] == 1) || own_fixture(i, bulb)) {
			continue;
		}
		if (hit_box(o, inv, box_min[i], box_max[i], 0.999)) {
			return true;
		}
	}
	if (!arch && actor_in_map == 1 && actor_shape > 0 && distance(o.xy, actor_middle()) > actor_body.z + 0.05 && hit_actor(o, dir, 0.999)) {
		return true;
	}
	return false;
}

// Lamp i on o (normal n). shared: the shared model (architecture hard, occluders soft, the look); else
// every box hard (the actor's body).
vec3 room_lamp_one(int i, vec3 o, vec3 n, bool shared, bool with_actor, vec2 px) {
	vec3 bulb = room_lamps[i];
	vec3 to = bulb - o;
	float d = length(to);
	float reach = room_lamp_reach[i];
	float facing = dot(n, to / max(d, 1e-4));
	if (d > reach || facing <= 0.0) {
		return vec3(0.0);
	}
	float h = bulb.z;
	// At most twice the floor under it (a bulb by a wall burnt a hot spot), a shade sending most
	// of it down (sideways shade_side, up a little).
	float down = (bulb.z - o.z) / max(d, 1e-4);
	float shade = mix(shade_up, 1.0, smoothstep(-0.3, 0.7, down));
	float e = h * h / max(d * d, h * h * 0.5) * facing * shade * (1.0 - smoothstep(0.55 * reach, reach, d));
	vec3 axis = to / d;
	vec3 u = any_side(axis);
	vec3 v = cross(axis, u);
	float seen = 0.0;
	for (int k = 0; k < lamp_soft; k++) {
		vec2 j = vogel(k, lamp_soft) * lamp_size * 0.5;
		vec3 spot = bulb + u * j.x + v * j.y;
		seen += blocked_lamp(o, spot - o, bulb, shared) ? 0.0 : 1.0;
	}
	if (seen <= 0.0) {
		return vec3(0.0);
	}
	float left = 1.0;
	if (shared) {
		left = 1.0 - look_share(min(occluders_share(o, bulb, 1, with_actor) * shadow_k, 1.0), px);
	}
	return room_lamp_color[i] * e * seen / float(lamp_soft) * left;
}

vec3 room_lamps_light(vec3 o, vec3 n, bool with_actor, vec2 px) {
	vec3 total = vec3(0.0);
	for (int i = 0; i < room_lamp_count; i++) {
		total += room_lamp_one(i, o, n, true, with_actor, px);
	}
	return total;
}

// The rooms' lamps on a body point: each as on a surface turned to it (a round body), no shade cut
// sideways beyond the lamp's.
vec3 room_lamps_body(vec3 o) {
	vec3 total = vec3(0.0);
	for (int i = 0; i < room_lamp_count; i++) {
		vec3 to = room_lamps[i] - o;
		vec2 across = to.xy;
		vec3 n = length(across) > 1e-3 ? vec3(normalize(across), 0.0) : vec3(0.0, 0.0, 1.0);
		total += room_lamp_one(i, o, n, false, false, vec2(0.0));
	}
	return total;
}

// The light on surface point p (normal n); with_actor: the actor casts here (by shadow_sources).
vec3 light_at(vec3 p, vec3 n, bool with_actor, vec2 px) {
	vec3 o = p + n * EPS;
	if (point_source == 3) {
		return room_lamps_light(o, n, with_actor && (shadow_sources & 4) != 0, px);
	}
	bool actor_direct = with_actor && (shadow_sources & 1) != 0;
	if (point_source == 2) {
		float sum = 0.0;
		for (int i = 0; i < lamp_count; i++) {
			float t;
			float seen = visible_through_k(o, lamps[i] - o, 1.0, t, true);
			if (seen > 0.0) {
				sum += seen * (1.0 - look_share(min(occluders_share(o, lamps[i], 1, actor_direct) * shadow_k, 1.0), px));
			}
		}
		return room_at(p.xy) * min(sum, 1.0);
	}
	vec3 centre = point_source == 1 ? source - o : source;
	vec3 axis = normalize(centre);
	vec3 u = any_side(axis);
	vec3 v = cross(axis, u);
	float sum = 0.0;
	for (int i = 0; i < soft_count; i++) {
		vec2 j = soft_count > 1 ? vogel(i, soft_count) * soft_radius : vec2(0.0);
		vec3 dir = point_source == 1 ? centre + u * j.x + v * j.y : axis + u * j.x + v * j.y;
		float t;
		sum += visible_through_k(o, dir, point_source == 1 ? 1.0 : 1e8, t, true);
	}
	vec3 lit = vec3(0.0);
	if (sum > 0.0) {
		float facing = dot(n, axis) / max(axis.z, 0.05);
		float lambert = n.z > 0.5 ? 1.0 : clamp(facing, 0.0, wall_max);
		float left = 1.0 - look_share(min(occluders_share(o, source, point_source == 1 ? 1 : 0, actor_direct) * shadow_k, 1.0), px);
		lit = room_at(p.xy) * lambert * sum / float(soft_count) * left;
	}
	if (sky_count > 0 && room_count > 0) {
		vec2 sky = sky_light(o, n, with_actor && (shadow_sources & 2) != 0, px);
		lit += room_sky[room_index(p.xy)] * sky.x * (1.0 - sky.y) / sky_ref;
	}
	return lit;
}

// The floor in a doorway lies inside a partition's thickness (x between its faces): true with them.
bool in_doorway(vec3 p, out float x0, out float x1) {
	for (int i = 0; i < box_count; i++) {
		vec3 size = box_max[i] - box_min[i];
		// A partition between columns: full height, thin across x, long in depth (not the walls across).
		bool across_x = size.x <= 0.5 && size.y > size.x;
		if (across_x && box_max[i].z >= shell_max.z - 0.05 && p.x > box_min[i].x && p.x < box_max[i].x) {
			x0 = box_min[i].x;
			x1 = box_max[i].x;
			return true;
		}
	}
	return false;
}

// The floor's light at floor point p (blending the floors on both sides in a doorway, the actor's
// shadow with them: it went on through the doorway, the human).
vec3 floor_light(vec3 p, bool with_actor, vec2 px) {
	vec3 n = vec3(0.0, 0.0, 1.0);
	float x0;
	float x1;
	if (in_doorway(p, x0, x1)) {
		// Blend the floors on both sides (the wall shades the doorway's own floor: a seam, the human).
		vec3 a = light_at(vec3(x0 - 0.03, p.y, 0.0), n, with_actor, px);
		vec3 b = light_at(vec3(x1 + 0.03, p.y, 0.0), n, with_actor, px);
		return mix(a, b, clamp((p.x - x0) / max(x1 - x0, 1e-3), 0.0, 1.0));
	}
	return light_at(p, n, with_actor, px);
}

// The light on the actor at strip pixel s (x across, y down; feet at the bottom middle).
vec3 actor_light(vec2 s) {
	vec3 feet = vec3(actor_feet, 0.0);
	vec3 below = floor_light(feet, false, vec2(0.0));
	if (actor_mode == 1) {
		return below * actor_gain;
	}
	float dx = (s.x - actor_strip.x * 0.5) / ppm;
	float z = (actor_strip.y - s.y) / ppm;
	// A point inside the body (its middle, a radius behind the feet line): lit from every side.
	vec3 o = vec3(actor_feet.x + dx, actor_feet.y - actor_radius, max(z, EPS));
	vec3 lit = vec3(0.0);
	if (point_source == 2) {
		float sum = 0.0;
		for (int i = 0; i < lamp_count; i++) {
			float t;
			sum += visible_through(o, lamps[i] - o, 1.0, t);
		}
		lit = room_at(o.xy) * min(sum, 1.0) * actor_sun_k;
	} else {
		vec3 centre = point_source == 1 ? source - o : source;
		vec3 axis = normalize(centre);
		vec3 u = any_side(axis);
		vec3 v = cross(axis, u);
		float sum = 0.0;
		for (int i = 0; i < soft_count; i++) {
			vec2 j = soft_count > 1 ? vogel(i, soft_count) * soft_radius : vec2(0.0);
			vec3 dir = point_source == 1 ? centre + u * j.x + v * j.y : axis + u * j.x + v * j.y;
			float t;
			sum += visible_through(o, dir, point_source == 1 ? 1.0 : 1e8, t);
		}
		lit = room_at(o.xy) * sum / float(soft_count) * actor_sun_k;
		if (sky_count > 0 && room_count > 0) {
			float share = sky_share(o, vec3(1.0, 0.0, 0.0)) + sky_share(o, vec3(-1.0, 0.0, 0.0))
					+ sky_share(o, vec3(0.0, 1.0, 0.0)) + sky_share(o, vec3(0.0, -1.0, 0.0));
			lit += room_sky[room_index(o.xy)] * share / 4.0 / sky_ref * actor_sky_k; // the mean of the four sides
		}
	}
	// The rooms' lamps (their map holds no strip: it is painted once): facing them sideways.
	vec3 lamps_below = vec3(0.0);
	if (room_lamp_count > 0) {
		lit += room_lamps_body(o) * actor_lamp_k;
		lamps_below = room_lamps_light(feet + vec3(0.0, 0.0, EPS), vec3(0.0, 0.0, 1.0), false, vec2(0.0));
	}
	float up = clamp(z / 1.8, 0.0, 1.0);
	lit += (below + lamps_below) * actor_bounce * (1.0 - 0.6 * up);
	return lit * actor_gain;
}

vec3 surface_light(vec3 p, vec3 n, bool with_actor, vec2 px) {
	if (n.z > 0.5 && p.z < 0.01) {
		return floor_light(p, with_actor, px);
	}
	return light_at(p, n, with_actor, px);
}

void fragment() {
	vec2 world = origin_px + local;
	vec3 p;
	vec3 n;
	vec3 lit = vec3(0.0);
	if (local.x >= house_w + actor_strip.x) {
		// The shadow window: the same map with the actor in it.
		vec2 s = local - vec2(house_w + actor_strip.x, 0.0);
		vec2 at = shadow_origin + s;
		if (s.x < shadow_size.x && s.y < shadow_size.y && surface_at(at, p, n)) {
			lit = surface_light(p, n, actor_shape > 0, at);
		}
	} else if (local.x >= house_w) {
		vec2 s = local - vec2(house_w, 0.0);
		lit = actor_mode > 0 && s.y < actor_strip.y && s.x < actor_strip.x ? actor_light(s) : vec3(0.0);
	} else if (surface_at(world, p, n)) {
		lit = surface_light(p, n, actor_in_map == 1 && actor_shape > 0, world);
	}
	COLOR = vec4(lit, 1.0);
}
