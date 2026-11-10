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
// point (Lambert's polygon formula: smooth, no noise), each sash dimmed by how many of SKY_RAYS rays to
// its glass a box cuts; over sky_ref (the factor by a window gives the room's sky light).
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
// The actor's shadow window (ticket 33): right of the actor strip (x from house_w + actor_strip.x), a
// window of shadow_size px whose top left is shadow_origin (world px) holds the light the actor takes
// away from each surface point (lit.gdshader subtracts it from this map). Which of this map's lights
// it takes: bit 1 the direct light (the sun; the night map: its light), 2 the sky, 4 the rooms' lamps.
uniform vec2 shadow_origin = vec2(0.0);
uniform vec2 shadow_size = vec2(0.0);
uniform int shadow_sources = 0;
// One softness for every source (the human: the window's shadow blurred, the lamp's sharp): the
// source's radius as seen from the shadowed point, tan of its angle.
uniform float shadow_angle = 0.03;
// A lamp counts this many times farther (and higher) from the actor's feet along the same line: its
// shadow widens slower and ends (a bulb below the head cast an endless fan, the human).
uniform float shadow_stretch = 3.0;
uniform int shadow_samples = 16;
// The window's (far) light for the actor's shadow as a point this far from the feet along its
// direction (0: parallel): its shadow widens like a lamp's (the human: that looks better).
uniform float shadow_sun_point = 0.0;
// A lamp's shadow this many times longer, not wider: the shadowed point drawn back towards the feet
// along the lamp's direction before the test.
uniform float shadow_lamp_length = 1.0;
// Gradient (the critic): 0 even; 1 darker by the feet (× 1 + 0.4·g) fading to × (1 − 0.8·g) at
// shadow_fade_m from the feet (on the floor; up a wall its height counts too).
uniform float shadow_gradient = 0.0;
uniform float shadow_fade_m = 2.5;
// 0: the gradient fades the strength (a window bar's full shadow showed through the faded part, the
// human); 1: the shadow keeps its strength and grows softer away from the feet (the source's angle up
// to × 1 + 4·gradient at shadow_fade_m), as a big source's shadow does.
uniform int shadow_gradient_soft = 1;
// The sky's shadow, its own settings (the human: a separate preset): strength, softness (radians on
// the glass's angular edges), its gradient by softness, a reach (fading out by then, m from the feet)
// and the contact: the sky taken in an oval under the feet (× this), as ambient occlusion.
uniform float sky_shadow_k = 0.6;
uniform float sky_shadow_soft = 0.05;
uniform float sky_shadow_gradient = 0.5;
uniform float sky_shadow_reach = 3.0;
uniform float sky_shadow_contact = 0.5;

// The source's angle for the actor's shadow at o (see shadow_gradient_soft).
float shadow_angle_at(vec3 o) {
	if (shadow_gradient_soft == 0) {
		return shadow_angle;
	}
	float from_feet = length(o.xy - actor_middle()) + o.z;
	return shadow_angle * (1.0 + 4.0 * shadow_gradient * smoothstep(0.0, shadow_fade_m, from_feet));
}

// o for an occluder's test, its distance from the occluder's foot away from the light (flat dir
// towards it) ÷ k.
vec3 shadow_pull_at(vec3 o, vec2 towards, float k, vec2 foot) {
	if (k <= 1.0 || length(towards) < 1e-5) {
		return o;
	}
	vec2 away = -normalize(towards);
	float along = dot(o.xy - foot, away);
	if (along <= 0.0) {
		return o;
	}
	return vec3(o.xy + away * (along / k - along), o.z);
}

vec3 shadow_pull(vec3 o, vec2 towards, float k) {
	return shadow_pull_at(o, towards, k, actor_middle());
}
uniform float shadow_k = 1.0;

// The overlap of [a0, a1] with [b0, b1].
float span_overlap(float a0, float a1, float b0, float b1) {
	return max(0.0, min(a1, b1) - max(a0, b0));
}

// As span_overlap with [b0, b1]'s edges ramped over s (the mean of it shrunk, as is and grown).
float soft_overlap(float a0, float a1, float b0, float b1, float s) {
	float h = s * 0.5;
	float inner = b1 - b0 > s ? span_overlap(a0, a1, b0 + h, b1 - h) : 0.0;
	return (inner + span_overlap(a0, a1, b0, b1) + span_overlap(a0, a1, b0 - h, b1 + h)) / 3.0;
}

float wrap_angle(float a) {
	return a - 6.2832 * floor((a + 3.1416) / 6.2832);
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

// ---- Ticket 35: one shadow model for the furniture and the actor ----
// shared_model 1: the objects (box_object) and the actor shade alike, per source sample: the source's
// angle (shadow_angle) grows with the distance from the occluder (the gradient by softness), and the
// artistic rules (a lamp counted farther, its shadow longer, the sun as a near point) are anchored at
// each occluder's foot. The sky: every object as an angular rectangle over the glass (as the actor),
// with the sky shadow's own strength, softness, gradient and reach. Walls (architecture) stay hard.
// 0: the old split (the furniture hard in blocked(), the actor apart in its window).
uniform int shared_model = 0;
uniform int map_samples = 12; // a source's samples for the objects in the house maps (the actor's window: shadow_samples)
// The sky's shadow fades out from sky_shadow_low to sky_shadow_high above the floor (a sharp rectangle
// on a bed's front behind the actor, the human); 0, 0: no fade.
uniform float sky_shadow_low = 0.5;
uniform float sky_shadow_high = 1.5;

vec3 any_side(vec3 axis) {
	return normalize(abs(axis.z) < 0.99 ? cross(axis, vec3(0.0, 0.0, 1.0)) : cross(axis, vec3(1.0, 0.0, 0.0)));
}

// How far o is from a box and from the actor's cylinder (the softness and the sky's reach grow with it).
float box_gap(vec3 o, vec3 lo, vec3 hi) {
	return distance(o, clamp(o, lo, hi));
}

float actor_gap(vec3 o) {
	float across = max(distance(o.xy, actor_middle()) - actor_body.z, 0.0);
	return length(vec2(across, max(o.z - actor_body.w, 0.0)));
}

float angle_at_gap(float gap) {
	if (shadow_gradient_soft == 0) {
		return shadow_angle;
	}
	return shadow_angle * (1.0 + 4.0 * shadow_gradient * smoothstep(0.0, shadow_fade_m, gap));
}

// The light left after occluders took `seen` of it (the strength: shadow_k).
float shade_k(float seen) {
	return 1.0 - min(shadow_k, 1.0) * (1.0 - seen);
}

// One sample's ray from o past an occluder whose foot stands at `foot` (x, d), towards the source
// (point 1: a bulb at src; 0: towards src, a far light); jit: the sample on the unit disc.
void shadow_ray(vec3 o, vec3 src, int point, vec2 foot, float gap, vec2 jit, out vec3 ro, out vec3 rd, out float reach) {
	vec3 base = vec3(foot, 0.0);
	vec3 to;
	ro = o;
	reach = 1.0;
	bool parallel = false;
	if (point == 1) {
		ro = shadow_pull_at(o, src.xy - foot, shadow_lamp_length, foot);
		to = base + (src - base) * shadow_stretch - ro;
	} else if (shadow_sun_point > 0.0) {
		to = base + normalize(src) * shadow_sun_point - o;
	} else {
		to = normalize(src);
		reach = 1e8;
		parallel = true;
	}
	float d = length(to);
	vec3 axis = to / max(d, 1e-5);
	vec3 u = any_side(axis);
	vec3 v = cross(axis, u);
	rd = to + (u * jit.x + v * jit.y) * angle_at_gap(gap) * (parallel ? 1.0 : d);
}

// An object between o and the source for sample jit (a lamp's own pole and shade cast nothing).
bool objects_block(vec3 o, vec3 src, int point, vec2 jit) {
	vec2 toward = point == 1 ? src.xy - o.xy : src.xy;
	float level = length(toward);
	vec2 dir = level > 1e-4 ? toward / level : vec2(0.0);
	for (int i = 0; i < box_count; i++) {
		if (box_object[i] == 0) {
			continue;
		}
		vec3 lo = box_min[i];
		vec3 hi = box_max[i];
		if (point == 1 && all(greaterThanEqual(src, lo - 0.02)) && all(lessThanEqual(src, hi + vec3(0.02, 0.02, 0.15)))) {
			continue;
		}
		vec2 middle = (lo.xy + hi.xy) * 0.5;
		// Behind o (away from the light) or below it with the light above: no shadow here.
		if (dot(middle - o.xy, dir) < -length(hi.xy - middle) - 0.05) {
			continue;
		}
		if (o.z >= hi.z - 1e-4 && (point == 0 || src.z * shadow_stretch >= hi.z)) {
			continue;
		}
		float gap = box_gap(o, lo, hi);
		if (gap > 0.0 && gap < 0.02 && o.z > 0.01) {
			continue; // its own face (the facing holds it); inside it (a touching neighbour): blocked
		}
		vec3 ro;
		vec3 rd;
		float reach;
		shadow_ray(o, src, point, middle, gap, jit, ro, rd, reach);
		vec3 inv = vec3(
				abs(rd.x) > 1e-8 ? 1.0 / rd.x : 1e8,
				abs(rd.y) > 1e-8 ? 1.0 / rd.y : 1e8,
				abs(rd.z) > 1e-8 ? 1.0 / rd.z : 1e8);
		if (hit_box(ro, inv, lo, hi, reach)) {
			return true;
		}
	}
	return false;
}

bool actor_blocks(vec3 o, vec3 src, int point, vec2 jit) {
	if (actor_shape == 0) {
		return false;
	}
	vec3 ro;
	vec3 rd;
	float reach;
	shadow_ray(o, src, point, actor_middle(), actor_gap(o), jit, ro, rd, reach);
	return hit_actor(ro, rd, reach);
}

// The share of a source's samples the objects (with_actor: and the actor) leave lit at o.
float objects_seen(vec3 o, vec3 src, int point, int count, bool with_actor) {
	float seen = 0.0;
	for (int i = 0; i < count; i++) {
		vec2 jit = vogel(i, count);
		if (!objects_block(o, src, point, jit) && !(with_actor && actor_blocks(o, src, point, jit))) {
			seen += 1.0;
		}
	}
	return seen / float(count);
}

// The share the actor takes at o on top of what the objects take (the shadow window).
float actor_takes(vec3 o, vec3 src, int point, int count) {
	float taken = 0.0;
	for (int i = 0; i < count; i++) {
		vec2 jit = vogel(i, count);
		if (actor_blocks(o, src, point, jit) && !objects_block(o, src, point, jit)) {
			taken += 1.0;
		}
	}
	return taken / float(count);
}

// The share of the glass (corners c, seen from o) an occluder covers: both as rectangles of azimuth
// (round ref) × elevation; the occluder's edges soften by s (radians).
float glass_hidden(vec3 o, vec3 c[4], float ref, vec2 az, vec2 el, float s) {
	float az0 = 1e9;
	float az1 = -1e9;
	float el0 = 1e9;
	float el1 = -1e9;
	for (int k = 0; k < 4; k++) {
		vec3 d = c[k] - o;
		float a = wrap_angle(atan(d.y, d.x) - ref);
		float e = atan(d.z, length(d.xy));
		az0 = min(az0, a);
		az1 = max(az1, a);
		el0 = min(el0, e);
		el1 = max(el1, e);
	}
	float area = (az1 - az0) * (el1 - el0);
	if (area < 1e-6) {
		return 0.0;
	}
	return min(soft_overlap(az0, az1, az.x, az.y, s) * soft_overlap(el0, el1, el.x, el.y, s) / area, 1.0);
}

// A box's angular rectangle seen from o (azimuth round ref, its middle's); inside its footprint (under
// a table) every azimuth up to its top edge. False: o is on it or above it (it hides no glass).
bool box_rect(vec3 o, vec3 lo, vec3 hi, out float ref, out vec2 az, out vec2 el) {
	ref = 0.0;
	az = vec2(0.0);
	el = vec2(0.0);
	if (o.z >= hi.z - 1e-4) {
		return false;
	}
	vec2 middle = (lo.xy + hi.xy) * 0.5;
	if (all(greaterThan(o.xy, lo.xy)) && all(lessThan(o.xy, hi.xy))) {
		float edge = min(min(o.x - lo.x, hi.x - o.x), min(o.y - lo.y, hi.y - o.y));
		az = vec2(-3.1416, 3.1416);
		el = vec2(-1.6, atan(hi.z - o.z, max(edge, 0.02)));
		return true;
	}
	ref = atan(middle.y - o.y, middle.x - o.x);
	az = vec2(1e9, -1e9);
	float far_d = 0.0;
	for (int k = 0; k < 4; k++) {
		vec2 corner = vec2(k == 1 || k == 2 ? hi.x : lo.x, k >= 2 ? hi.y : lo.y);
		vec2 d = corner - o.xy;
		float a = wrap_angle(atan(d.y, d.x) - ref);
		az = vec2(min(az.x, a), max(az.y, a));
		far_d = max(far_d, length(d));
	}
	float near = max(distance(o.xy, clamp(o.xy, lo.xy, hi.xy)), 0.02);
	el = vec2(atan(lo.z - o.z, lo.z < o.z ? near : far_d), atan(hi.z - o.z, hi.z > o.z ? near : far_d));
	return true;
}

// How much of the sky's shadow an occluder gap m away casts at height z (strength, reach, height).
float sky_shadow_at(float gap, float z) {
	float fade = sky_shadow_high > sky_shadow_low ? 1.0 - smoothstep(sky_shadow_low, sky_shadow_high, z) : 1.0;
	return min(sky_shadow_k, 1.0) * (1.0 - smoothstep(0.5 * sky_shadow_reach, sky_shadow_reach, gap)) * fade;
}

float sky_soft_at(float gap) {
	return sky_shadow_soft * (1.0 + 4.0 * sky_shadow_gradient * smoothstep(0.0, shadow_fade_m, gap));
}

// The sky a sash's glass (corners c; to_s, glass_d: to its middle) keeps past the objects at o: each
// an angular rectangle over the glass (ticket 35), its cover × the sky shadow's strength there.
float objects_keep(vec3 o, vec3 c[4], vec2 to_s, float glass_d) {
	float keep = 1.0;
	for (int b = 0; b < box_count; b++) {
		if (box_object[b] == 0) {
			continue;
		}
		float ref;
		vec2 az;
		vec2 el;
		if (!box_rect(o, box_min[b], box_max[b], ref, az, el)) {
			continue;
		}
		vec2 to_b = (box_min[b].xy + box_max[b].xy) * 0.5 - o.xy;
		float gap = box_gap(o, box_min[b], box_max[b]);
		// Its own faces: their facing (the form factor) already holds it; as a rectangle it hid the
		// windows grazing the face (a dithered block on a bed's front).
		if (gap > 0.0 && gap < 0.02 && o.z > 0.01) {
			continue;
		}
		bool inside = az.y - az.x > 6.0;
		if (!inside && (dot(to_s, to_b) <= 0.0 || gap >= glass_d)) {
			continue;
		}
		float k_b = sky_shadow_at(gap, o.z);
		if (k_b > 0.0) {
			keep *= 1.0 - glass_hidden(o, c, ref, az, el, sky_soft_at(gap)) * k_b;
		}
	}
	return keep;
}

// The sky through the glass at o (normal n), over sky_ref: x free (walls only), y past the objects
// (with_actor: and the actor), z what the actor takes on top of the objects.
// lost_only: only z (the shadow window): a sash the actor hides nothing of costs nothing more.
vec3 sky_parts(vec3 o, vec3 n, bool with_actor, bool lost_only) {
	vec3 total = vec3(0.0);
	int own = room_index(o.xy);
	bool actor_on = actor_shape > 0;
	vec2 middle_a = actor_middle();
	vec2 to_a = middle_a - o.xy;
	float da = max(length(to_a), actor_body.z + 0.02);
	float a_gap = actor_gap(o);
	float a_ref = atan(to_a.y, to_a.x);
	vec2 a_az = vec2(-1.0, 1.0) * asin(clamp(actor_body.z / da, 0.0, 1.0));
	vec2 a_el = vec2(atan(-o.z, da), atan(actor_body.w - o.z, da));
	float a_k = sky_shadow_at(a_gap, o.z);
	float a_s = sky_soft_at(a_gap);
	for (int i = 0; i < sash_count; i++) {
		if (sky_side == 0 && sash_wall[i] >= 2) {
			continue;
		}
		vec3 c[4];
		for (int k = 0; k < 4; k++) {
			c[k] = sash_corner(i, k);
		}
		vec3 middle = (c[0] + c[2]) / 2.0;
		vec2 to_s = middle.xy - o.xy;
		float glass_d = length(to_s);
		float taken = 0.0;
		if (actor_on && a_k > 0.0 && glass_d > da && dot(to_s, to_a) > 0.0) {
			taken = glass_hidden(o, c, a_ref, a_az, a_el, a_s) * a_k;
		}
		if (lost_only && taken <= 0.0) {
			continue;
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
		f = sky_ref * pow(f / sky_ref, front_gamma);
		if (f < 1e-4) {
			continue;
		}
		float open = 0.0;
		for (int k = 0; k < 4; k++) {
			open += blocked(o, mix(middle, c[k], 0.6) - o, 0.999) ? 0.0 : 0.25;
		}
		float other = room_index(middle.xy) == own ? 1.0 : sky_other_k;
		int w = sash_wall[i];
		vec2 normal = w == 0 ? vec2(0.0, -1.0) : (w == 1 ? vec2(0.0, 1.0) : (w == 2 ? vec2(-1.0, 0.0) : vec2(1.0, 0.0)));
		float towards = max(0.2, 1.0 + dot(normal, sky_sun));
		float base = f * open * other * towards * front_glow * (i == door_sash ? door_k : 1.0);
		if (base <= 0.0) {
			continue;
		}
		float keep = objects_keep(o, c, to_s, glass_d);
		total += base * vec3(1.0, keep * (with_actor ? 1.0 - taken : 1.0), keep * taken);
	}
	return total;
}

// The sky on a body point (the actor's light): the mean of four sides, the objects' cover counted once
// per sash (it does not depend on the side).
float sky_body(vec3 o) {
	float total = 0.0;
	int own = room_index(o.xy);
	for (int i = 0; i < sash_count; i++) {
		if (sky_side == 0 && sash_wall[i] >= 2) {
			continue;
		}
		vec3 c[4];
		for (int k = 0; k < 4; k++) {
			c[k] = sash_corner(i, k);
		}
		vec3 middle = (c[0] + c[2]) / 2.0;
		float f_all = 0.0;
		for (int side = 0; side < 4; side++) {
			vec3 n = side == 0 ? vec3(1.0, 0.0, 0.0) : (side == 1 ? vec3(-1.0, 0.0, 0.0) : (side == 2 ? vec3(0.0, 1.0, 0.0) : vec3(0.0, -1.0, 0.0)));
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
			f_all += sky_ref * pow(f / sky_ref, front_gamma);
		}
		if (f_all < 4e-4) {
			continue;
		}
		float open = 0.0;
		for (int k = 0; k < 4; k++) {
			open += blocked(o, mix(middle, c[k], 0.6) - o, 0.999) ? 0.0 : 0.25;
		}
		float other = room_index(middle.xy) == own ? 1.0 : sky_other_k;
		int w = sash_wall[i];
		vec2 normal = w == 0 ? vec2(0.0, -1.0) : (w == 1 ? vec2(0.0, 1.0) : (w == 2 ? vec2(-1.0, 0.0) : vec2(1.0, 0.0)));
		float towards = max(0.2, 1.0 + dot(normal, sky_sun));
		float base = f_all * open * other * towards * front_glow * (i == door_sash ? door_k : 1.0);
		if (base > 0.0) {
			vec2 to_s = middle.xy - o.xy;
			total += base * objects_keep(o, c, to_s, length(to_s));
		}
	}
	return total / 4.0;
}

float sky_share(vec3 o, vec3 n) {
	float total = 0.0;
	int own = room_index(o.xy);
	for (int i = 0; i < sash_count; i++) {
		if (sky_side == 0 && sash_wall[i] >= 2) {
			continue;
		}
		float f = 0.0;
		vec3 c[4];
		for (int k = 0; k < 4; k++) {
			c[k] = sash_corner(i, k);
		}
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
			continue;
		}
		vec3 middle = (c[0] + c[2]) / 2.0;
		float open = 0.0;
		for (int k = 0; k < 4; k++) {
			vec3 to = mix(middle, c[k], 0.6) - o;
			open += blocked(o, to, 0.999) ? 0.0 : 0.25;
		}
		float other = room_index(middle.xy) == own ? 1.0 : sky_other_k;
		int w = sash_wall[i];
		vec2 normal = w == 0 ? vec2(0.0, -1.0) : (w == 1 ? vec2(0.0, 1.0) : (w == 2 ? vec2(-1.0, 0.0) : vec2(1.0, 0.0)));
		float towards = max(0.2, 1.0 + dot(normal, sky_sun));
		total += f * open * other * towards * front_glow * (i == door_sash ? door_k : 1.0);
	}
	return total;
}

// Blocked between o and the bulb at o + dir (t 0..1), past boxes holding the bulb (its lamp's own).
bool blocked_lamp(vec3 o, vec3 dir, vec3 bulb) {
	vec3 inv = vec3(
			abs(dir.x) > 1e-8 ? 1.0 / dir.x : 1e8,
			abs(dir.y) > 1e-8 ? 1.0 / dir.y : 1e8,
			abs(dir.z) > 1e-8 ? 1.0 / dir.z : 1e8);
	for (int i = 0; i < box_count; i++) {
		if (objects_apart == 1 && box_object[i] == 1) {
			continue;
		}
		// The lamp's own pole and shade (the bulb inside or just above it) cast nothing.
		if (all(greaterThanEqual(bulb, box_min[i] - 0.02)) && all(lessThanEqual(bulb, box_max[i] + vec3(0.02, 0.02, 0.15)))) {
			continue;
		}
		if (hit_box(o, inv, box_min[i], box_max[i], 0.999)) {
			return true;
		}
	}
	if (objects_apart == 0 && actor_in_map == 1 && actor_shape > 0 && distance(o.xy, actor_middle()) > actor_body.z + 0.05 && hit_actor(o, dir, 0.999)) {
		return true;
	}
	return false;
}

// A room lamp's light at o past the walls (free) and past the objects too (returned); shared_model:
// the objects (with_actor: and the actor) by the shared rules, else blocked_lamp already holds them.
vec3 room_lamp_both(int i, vec3 o, vec3 n, bool with_actor, bool free_only, out vec3 free) {
	free = vec3(0.0);
	{
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
		vec3 u = normalize(abs(axis.z) < 0.99 ? cross(axis, vec3(0.0, 0.0, 1.0)) : cross(axis, vec3(1.0, 0.0, 0.0)));
		vec3 v = cross(axis, u);
		float seen = 0.0;
		for (int k = 0; k < lamp_soft; k++) {
			vec2 j = vogel(k, lamp_soft) * lamp_size * 0.5;
			vec3 spot = bulb + u * j.x + v * j.y;
			seen += blocked_lamp(o, spot - o, bulb) ? 0.0 : 1.0;
		}
		free = room_lamp_color[i] * e * seen / float(lamp_soft);
		if (shared_model == 1 && !free_only && seen > 0.0) {
			return free * shade_k(objects_seen(o, bulb, 1, map_samples, with_actor));
		}
		return free;
	}
}

vec3 room_lamp_one(int i, vec3 o, vec3 n) {
	vec3 free;
	return room_lamp_both(i, o, n, false, false, free);
}

vec3 room_lamps_light(vec3 o, vec3 n) {
	vec3 total = vec3(0.0);
	for (int i = 0; i < room_lamp_count; i++) {
		total += room_lamp_one(i, o, n);
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
		total += room_lamp_one(i, o, n);
	}
	return total;
}

// The light on surface point p (normal n).
vec3 light_at(vec3 p, vec3 n) {
	vec3 o = p + n * EPS;
	if (point_source == 3) {
		return room_lamps_light(o, n);
	}
	if (point_source == 2) {
		float sum = 0.0;
		for (int i = 0; i < lamp_count; i++) {
			float t;
			sum += visible_through(o, lamps[i] - o, 1.0, t);
		}
		return room_at(p.xy) * min(sum, 1.0);
	}
	vec3 centre = point_source == 1 ? source - o : source;
	vec3 axis = normalize(centre);
	vec3 u = normalize(abs(axis.z) < 0.99 ? cross(axis, vec3(0.0, 0.0, 1.0)) : cross(axis, vec3(1.0, 0.0, 0.0)));
	vec3 v = cross(axis, u);
	float sum = 0.0;
	for (int i = 0; i < soft_count; i++) {
		vec2 j = soft_count > 1 ? vogel(i, soft_count) * soft_radius : vec2(0.0);
		vec3 dir = point_source == 1 ? centre + u * j.x + v * j.y : axis + u * j.x + v * j.y;
		float t;
		sum += visible_through(o, dir, point_source == 1 ? 1.0 : 1e8, t);
	}
	float facing = dot(n, axis) / max(axis.z, 0.05);
	float lambert = n.z > 0.5 ? 1.0 : clamp(facing, 0.0, wall_max);
	vec3 lit = room_at(p.xy) * lambert * sum / float(soft_count);
	if (sky_count > 0 && room_count > 0) {
		lit += room_sky[room_index(p.xy)] * sky_share(o, n) / sky_ref;
	}
	return lit;
}

// The sash's share of a source at o (its disc samples, walls only when objects_apart): as light_at.
float sash_seen(vec3 o) {
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
	return sum / float(soft_count);
}

float lambert_at(vec3 o, vec3 n) {
	vec3 axis = normalize(point_source == 1 ? source - o : source);
	float facing = dot(n, axis) / max(axis.z, 0.05);
	return n.z > 0.5 ? 1.0 : clamp(facing, 0.0, wall_max);
}

// Ticket 35: the light on surface point p (normal n) past the objects (returned) and past the walls
// only (free): the house maps keep both (the look quantizes the objects' share, lit.gdshader).
vec3 light_shared(vec3 p, vec3 n, out vec3 free) {
	vec3 o = p + n * EPS;
	bool with_actor = actor_in_map == 1 && actor_shape > 0;
	free = vec3(0.0);
	vec3 lit = vec3(0.0);
	if (point_source == 3) {
		for (int i = 0; i < room_lamp_count; i++) {
			vec3 one_free;
			lit += room_lamp_both(i, o, n, with_actor, false, one_free);
			free += one_free;
		}
		return lit;
	}
	if (point_source == 2) {
		float sum = 0.0;
		float sum_free = 0.0;
		for (int i = 0; i < lamp_count; i++) {
			float t;
			float seen = visible_through(o, lamps[i] - o, 1.0, t);
			if (seen > 0.0) {
				sum_free += seen;
				sum += seen * shade_k(objects_seen(o, lamps[i], 1, map_samples, with_actor));
			}
		}
		free = room_at(p.xy) * min(sum_free, 1.0);
		return room_at(p.xy) * min(sum, 1.0);
	}
	float sash = sash_seen(o);
	if (sash > 0.0) {
		free = room_at(p.xy) * lambert_at(o, n) * sash;
		lit = free * shade_k(objects_seen(o, source, point_source, map_samples, with_actor));
	}
	if (sky_count > 0 && room_count > 0) {
		vec3 sky = sky_parts(o, n, with_actor, false) / sky_ref;
		free += room_sky[room_index(p.xy)] * sky.x;
		lit += room_sky[room_index(p.xy)] * sky.y;
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

// The floor's light at floor point p (blending the floors on both sides in a doorway).
vec3 floor_light(vec3 p) {
	vec3 n = vec3(0.0, 0.0, 1.0);
	float x0;
	float x1;
	if (in_doorway(p, x0, x1)) {
		// Blend the floors on both sides (the wall shades the doorway's own floor: a seam, the human).
		vec3 a = light_at(vec3(x0 - 0.03, p.y, 0.0), n);
		vec3 b = light_at(vec3(x1 + 0.03, p.y, 0.0), n);
		return mix(a, b, clamp((p.x - x0) / max(x1 - x0, 1e-3), 0.0, 1.0));
	}
	return light_at(p, n);
}

// As floor_light, shared: both lights (see light_shared).
vec3 floor_shared(vec3 p, out vec3 free) {
	vec3 n = vec3(0.0, 0.0, 1.0);
	float x0;
	float x1;
	if (in_doorway(p, x0, x1)) {
		vec3 fa;
		vec3 fb;
		vec3 a = light_shared(vec3(x0 - 0.03, p.y, 0.0), n, fa);
		vec3 b = light_shared(vec3(x1 + 0.03, p.y, 0.0), n, fb);
		float k = clamp((p.x - x0) / max(x1 - x0, 1e-3), 0.0, 1.0);
		free = mix(fa, fb, k);
		return mix(a, b, k);
	}
	return light_shared(p, n, free);
}

// The light on the actor at strip pixel s (x across, y down; feet at the bottom middle).
vec3 actor_light(vec2 s) {
	vec3 feet = vec3(actor_feet, 0.0);
	vec3 below_free;
	vec3 below = shared_model == 1 ? floor_shared(feet, below_free) : floor_light(feet);
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
			float seen = visible_through(o, lamps[i] - o, 1.0, t);
			if (shared_model == 1 && seen > 0.0) {
				seen *= shade_k(objects_seen(o, lamps[i], 1, 6, false));
			}
			sum += seen;
		}
		lit = room_at(o.xy) * min(sum, 1.0) * actor_sun_k;
	} else {
		vec3 centre = point_source == 1 ? source - o : source;
		vec3 axis = normalize(centre);
		vec3 u = normalize(abs(axis.z) < 0.99 ? cross(axis, vec3(0.0, 0.0, 1.0)) : cross(axis, vec3(1.0, 0.0, 0.0)));
		vec3 v = cross(axis, u);
		float sum = 0.0;
		for (int i = 0; i < soft_count; i++) {
			vec2 j = soft_count > 1 ? vogel(i, soft_count) * soft_radius : vec2(0.0);
			vec3 dir = point_source == 1 ? centre + u * j.x + v * j.y : axis + u * j.x + v * j.y;
			float t;
			sum += visible_through(o, dir, point_source == 1 ? 1.0 : 1e8, t);
		}
		if (shared_model == 1 && sum > 0.0) {
			sum *= shade_k(objects_seen(o, source, point_source, 6, false));
		}
		lit = room_at(o.xy) * sum / float(soft_count) * actor_sun_k;
		if (sky_count > 0 && room_count > 0 && shared_model == 1) {
			lit += room_sky[room_index(o.xy)] * sky_body(o) / sky_ref * actor_sky_k;
		} else if (sky_count > 0 && room_count > 0) {
			float share = sky_share(o, vec3(1.0, 0.0, 0.0)) + sky_share(o, vec3(-1.0, 0.0, 0.0))
					+ sky_share(o, vec3(0.0, 1.0, 0.0)) + sky_share(o, vec3(0.0, -1.0, 0.0));
			lit += room_sky[room_index(o.xy)] * share / 4.0 / sky_ref * actor_sky_k; // the mean of the four sides
		}
	}
	// The rooms' lamps (their map holds no strip: it is painted once): facing them sideways.
	vec3 lamps_below = vec3(0.0);
	if (room_lamp_count > 0) {
		lit += room_lamps_body(o) * actor_lamp_k;
		lamps_below = room_lamps_light(feet + vec3(0.0, 0.0, EPS), vec3(0.0, 0.0, 1.0));
	}
	float up = clamp(z / 1.8, 0.0, 1.0);
	lit += (below + lamps_below) * actor_bounce * (1.0 - 0.6 * up);
	return lit * actor_gain;
}

// The direct light (the sun, the night light) the actor takes from o (normal n).
vec3 direct_lost(vec3 p, vec3 o, vec3 n) {
	if (point_source == 2) {
		float lost = 0.0;
		for (int i = 0; i < lamp_count; i++) {
			vec3 to = lamps[i] - o;
			float t;
			if (hit_actor(o, to, 1.0) && visible_through(o, to, 1.0, t) > 0.0) {
				lost += 1.0;
			}
		}
		return room_at(p.xy) * min(lost, 1.0);
	}
	vec3 centre = point_source == 1 ? source - o : source;
	vec3 axis = normalize(centre);
	vec3 u = normalize(abs(axis.z) < 0.99 ? cross(axis, vec3(0.0, 0.0, 1.0)) : cross(axis, vec3(1.0, 0.0, 0.0)));
	vec3 v = cross(axis, u);
	float sum = 0.0;
	int count = shadow_samples;
	if (point_source == 0 && shadow_sun_point > 0.0) {
		// A point shadow_sun_point m from the feet towards the light.
		vec3 point = vec3(actor_middle(), 0.0) + axis * shadow_sun_point;
		vec3 to = point - o;
		float dist = length(to);
		vec3 ax = to / max(dist, 1e-4);
		vec3 pu = normalize(abs(ax.z) < 0.99 ? cross(ax, vec3(0.0, 0.0, 1.0)) : cross(ax, vec3(1.0, 0.0, 0.0)));
		vec3 pv = cross(ax, pu);
		float hits = 0.0;
		for (int i = 0; i < count; i++) {
			vec2 j = vogel(i, count) * shadow_angle_at(o) * dist;
			if (hit_actor(o, to + pu * j.x + pv * j.y, 1.0)) {
				hits += 1.0;
			}
		}
		if (hits <= 0.0) {
			return vec3(0.0);
		}
		// The window's visibility exactly as the patch has it (its disc samples): by a bar the patch
		// is half lit, and the shadow takes that half (one ray left the bar's line lit, the human).
		float seen = 0.0;
		for (int i = 0; i < soft_count; i++) {
			vec2 j = soft_count > 1 ? vogel(i, soft_count) * soft_radius : vec2(0.0);
			float t;
			seen += visible_through(o, axis + u * j.x + v * j.y, 1e8, t);
		}
		sum = hits / float(count) * seen / float(soft_count) * float(count);
	} else {
	for (int i = 0; i < count; i++) {
		vec2 j = vogel(i, count) * shadow_angle_at(o) * (point_source == 1 ? length(centre) : 1.0);
		vec3 dir = point_source == 1 ? centre + u * j.x + v * j.y : axis + u * j.x + v * j.y;
		float reach = point_source == 1 ? 1.0 : 1e8;
		if (!hit_actor(o, dir, reach)) {
			continue;
		}
		float t;
		sum += visible_through(o, dir, reach, t);
	}
	}
	float facing = dot(n, axis) / max(axis.z, 0.05);
	float lambert = n.z > 0.5 ? 1.0 : clamp(facing, 0.0, wall_max);
	return room_at(p.xy) * lambert * sum / float(count);
}

// The sky the actor takes from o (ticket 33, second take): per sash, the part of its glass the actor
// covers seen from o, as the overlap of two angular rectangles (azimuth × elevation: the glass and the
// actor's cylinder), smooth: 3×3 rays per sash drew a fan of faint sharp cylinders, one per ray (the
// human). The edges soften by sky_shadow_soft (radians), growing away from the feet by sky_shadow_gradient.
float sky_lost(vec3 o, vec3 n) {
	float total = 0.0;
	int own = room_index(o.xy);
	vec2 middle_a = actor_middle();
	vec2 to_a = middle_a - o.xy;
	float radius = actor_body.z;
	float da = max(length(to_a), radius + 0.02);
	float half_az = asin(clamp(radius / da, 0.0, 1.0));
	float az_a = atan(to_a.y, to_a.x);
	float el_lo = atan(-o.z, da);
	float el_hi = atan(actor_body.w - o.z, da);
	float from_feet = length(o.xy - middle_a) + o.z;
	float s = sky_shadow_soft * (1.0 + 4.0 * sky_shadow_gradient * smoothstep(0.0, shadow_fade_m, from_feet));
	for (int i = 0; i < sash_count; i++) {
		if (sky_side == 0 && sash_wall[i] >= 2) {
			continue;
		}
		vec3 c[4];
		for (int k = 0; k < 4; k++) {
			c[k] = sash_corner(i, k);
		}
		vec3 middle = (c[0] + c[2]) / 2.0;
		vec2 to_s = middle.xy - o.xy;
		// The actor must stand between the point and the glass.
		if (length(to_s) <= da || dot(to_s, to_a) <= 0.0) {
			continue;
		}
		float az0 = 1e9;
		float az1 = -1e9;
		float el0 = 1e9;
		float el1 = -1e9;
		for (int k = 0; k < 4; k++) {
			vec3 d = c[k] - o;
			float az = wrap_angle(atan(d.y, d.x) - az_a);
			float el = atan(d.z, length(d.xy));
			az0 = min(az0, az);
			az1 = max(az1, az);
			el0 = min(el0, el);
			el1 = max(el1, el);
		}
		float area = (az1 - az0) * (el1 - el0);
		if (area < 1e-6) {
			continue;
		}
		float hidden = soft_overlap(az0, az1, -half_az, half_az, s) * soft_overlap(el0, el1, el_lo, el_hi, s) / area;
		if (hidden <= 0.0) {
			continue;
		}
		// The glass the furniture already hides gives no sky to take (as sky_share: 4 rays).
		float open = 0.0;
		for (int k = 0; k < 4; k++) {
			open += blocked(o, mix(middle, c[k], 0.6) - o, 0.999) ? 0.0 : 0.25;
		}
		hidden = min(hidden, 1.0) * open;
		if (hidden <= 0.0) {
			continue;
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
		f = sky_ref * pow(f / sky_ref, front_gamma);
		float other = room_index(middle.xy) == own ? 1.0 : sky_other_k;
		int w = sash_wall[i];
		vec2 normal = w == 0 ? vec2(0.0, -1.0) : (w == 1 ? vec2(0.0, 1.0) : (w == 2 ? vec2(-1.0, 0.0) : vec2(1.0, 0.0)));
		float towards = max(0.2, 1.0 + dot(normal, sky_sun));
		total += f * hidden * other * towards * front_glow * (i == door_sash ? door_k : 1.0);
	}
	return total;
}

// The rooms' lamps' light the actor takes from o: as room_lamp_one, only the bulb's spots behind it.
vec3 room_lamps_lost(vec3 o, vec3 n) {
	vec3 total = vec3(0.0);
	for (int i = 0; i < room_lamp_count; i++) {
		vec3 bulb = room_lamps[i];
		vec3 to = bulb - o;
		float d = length(to);
		float reach = room_lamp_reach[i];
		float facing = dot(n, to / max(d, 1e-4));
		if (d > reach || facing <= 0.0) {
			continue;
		}
		// The bulb for the actor's shadow: shifted away from the feet along the same line.
		vec3 feet = vec3(actor_middle(), 0.0);
		vec3 far_bulb = feet + (bulb - feet) * shadow_stretch;
		vec3 o_test = shadow_pull(o, bulb.xy - feet.xy, shadow_lamp_length);
		vec3 far_to = far_bulb - o_test;
		float far_d = length(far_to);
		vec3 far_axis = far_to / max(far_d, 1e-4);
		vec3 fu = normalize(abs(far_axis.z) < 0.99 ? cross(far_axis, vec3(0.0, 0.0, 1.0)) : cross(far_axis, vec3(1.0, 0.0, 0.0)));
		vec3 fv = cross(far_axis, fu);
		float hits = 0.0;
		for (int k = 0; k < shadow_samples; k++) {
			vec2 j = vogel(k, shadow_samples) * shadow_angle_at(o) * far_d;
			if (hit_actor(o_test, far_to + fu * j.x + fv * j.y, 1.0)) {
				hits += 1.0;
			}
		}
		if (hits <= 0.0) {
			continue;
		}
		// The bulb's visibility as the lamp map has it (its spots), so the shadow takes no more than lit.
		vec3 la = to / max(d, 1e-4);
		vec3 lu = normalize(abs(la.z) < 0.99 ? cross(la, vec3(0.0, 0.0, 1.0)) : cross(la, vec3(1.0, 0.0, 0.0)));
		vec3 lv = cross(la, lu);
		float seen = 0.0;
		for (int k = 0; k < lamp_soft; k++) {
			vec2 j = vogel(k, lamp_soft) * lamp_size * 0.5;
			vec3 spot = bulb + lu * j.x + lv * j.y;
			seen += blocked_lamp(o, spot - o, bulb) ? 0.0 : 1.0;
		}
		hits *= seen / float(lamp_soft);
		float h = bulb.z;
		float down = (bulb.z - o.z) / max(d, 1e-4);
		float shade = mix(shade_up, 1.0, smoothstep(-0.3, 0.7, down));
		float e = h * h / max(d * d, h * h * 0.5) * facing * shade * (1.0 - smoothstep(0.55 * reach, reach, d));
		total += room_lamp_color[i] * e * hits / float(shadow_samples);
	}
	return total;
}

// The light the actor takes from surface point p (normal n), of this map's shadow_sources.
vec3 lost_at(vec3 p, vec3 n) {
	vec3 o = p + n * EPS;
	vec3 lost = vec3(0.0);
	if ((shadow_sources & 4) != 0 && point_source == 3) {
		lost += room_lamps_lost(o, n);
	}
	if ((shadow_sources & 1) != 0 && point_source != 3) {
		lost += direct_lost(p, o, n);
	}
	float from_feet = length(o.xy - actor_middle()) + o.z;
	float strength_gradient = shadow_gradient_soft == 0 ? shadow_gradient : 0.0;
	float k = shadow_k * mix(1.0 + 0.4 * strength_gradient, 1.0 - 0.8 * strength_gradient, smoothstep(0.0, shadow_fade_m, from_feet));
	lost *= min(k, 1.0);
	if ((shadow_sources & 2) != 0 && sky_count > 0 && room_count > 0 && point_source != 3) {
		float sky_k = sky_shadow_k * (1.0 - smoothstep(0.5 * sky_shadow_reach, sky_shadow_reach, from_feet));
		float sky_taken = sky_lost(o, n) / sky_ref * min(sky_k, 1.0);
		// Contact (the critic): an oval of sky taken right under the feet, whatever the window's side
		// (it used to weaken the shadow there, where it is strongest, and the oval sat on its axis).
		float flat_feet = length((o.xy - actor_middle()) * vec2(1.0, 1.6));
		float ao = sky_shadow_contact * (1.0 - smoothstep(actor_body.z * 0.8, actor_body.z * 2.2, flat_feet)) * step(o.z, 0.05);
		if (ao > 0.0) {
			sky_taken = max(sky_taken, sky_share(o, n) / sky_ref * ao);
		}
		lost += room_sky[room_index(p.xy)] * sky_taken;
	}
	return lost;
}

// Ticket 35: the light the actor takes from p (normal n) by the shared rules, past what the objects
// already take (the shadow window, subtracted from the house maps).
vec3 lost_shared(vec3 p, vec3 n) {
	vec3 o = p + n * EPS;
	vec3 lost = vec3(0.0);
	float k = min(shadow_k, 1.0);
	if ((shadow_sources & 4) != 0 && point_source == 3) {
		for (int i = 0; i < room_lamp_count; i++) {
			if (distance(o, room_lamps[i]) > room_lamp_reach[i]) {
				continue;
			}
			float taken = actor_takes(o, room_lamps[i], 1, shadow_samples);
			if (taken > 0.0) {
				vec3 free;
				room_lamp_both(i, o, n, false, true, free);
				lost += free * taken * k;
			}
		}
	}
	if ((shadow_sources & 1) != 0 && point_source == 2) {
		for (int i = 0; i < lamp_count; i++) {
			float taken = actor_takes(o, lamps[i], 1, shadow_samples);
			if (taken > 0.0) {
				float t;
				lost += room_at(p.xy) * visible_through(o, lamps[i] - o, 1.0, t) * taken * k;
			}
		}
	} else if ((shadow_sources & 1) != 0 && point_source < 2) {
		float taken = actor_takes(o, source, point_source, shadow_samples);
		if (taken > 0.0) {
			lost += room_at(p.xy) * lambert_at(o, n) * sash_seen(o) * taken * k;
		}
	}
	if ((shadow_sources & 2) != 0 && sky_count > 0 && room_count > 0 && point_source != 3) {
		// Ambient occlusion under the feet (the critic): an oval of the sky left there, × the contact.
		float flat_feet = length((o.xy - actor_middle()) * vec2(1.0, 1.6));
		float ao = sky_shadow_contact * (1.0 - smoothstep(actor_body.z * 0.8, actor_body.z * 2.2, flat_feet)) * step(o.z, 0.05);
		vec3 sky = sky_parts(o, n, false, ao <= 0.0) / sky_ref;
		float taken = max(sky.z, sky.y * ao);
		lost += room_sky[room_index(p.xy)] * taken;
	}
	return lost;
}

void fragment() {
	vec2 world = origin_px + local;
	vec3 p;
	vec3 n;
	vec3 lit = vec3(0.0);
	// The house maps' alpha (ticket 35, shared_model): the share of the light the objects take there.
	float objects_share = 0.0;
	if (local.x >= house_w + actor_strip.x) {
		vec2 s = local - vec2(house_w + actor_strip.x, 0.0);
		vec2 at = shadow_origin + s;
		if (shadow_sources != 0 && actor_shape > 0 && s.x < shadow_size.x && s.y < shadow_size.y && surface_at(at, p, n)) {
			// Fading out by the window's edges (a soft sky shadow cut there showed a hard line).
			vec2 edge = min(s, shadow_size - s);
			lit = (shared_model == 1 ? lost_shared(p, n) : lost_at(p, n)) * smoothstep(0.0, 24.0, min(edge.x, edge.y));
		}
	} else if (local.x >= house_w) {
		vec2 s = local - vec2(house_w, 0.0);
		lit = actor_mode > 0 && s.y < actor_strip.y && s.x < actor_strip.x ? actor_light(s) : vec3(0.0);
	} else if (surface_at(world, p, n)) {
		if (shared_model == 1) {
			vec3 free;
			lit = n.z > 0.5 && p.z < 0.01 ? floor_shared(p, free) : light_shared(p, n, free);
			float free_l = dot(free, vec3(0.333));
			objects_share = free_l > 1e-5 ? clamp(1.0 - dot(lit, vec3(0.333)) / free_l, 0.0, 1.0) : 0.0;
		} else if (n.z > 0.5 && p.z < 0.01) {
			lit = floor_light(p);
		} else {
			lit = light_at(p, n);
		}
	}
	COLOR = vec4(lit, objects_share);
}
