// PROTOTYPE (ticket 36): the one light function. Every source (the sun through the sashes, the side
// windows' ribbons, the sky through every sash and the street door, the night through the windows, the
// rooms' lamps) is a sum of samples tested against the same occluders (sun_geometry: blocked_by). Per
// source: arch = what the architecture lets through (shell, sashes), lit = what is left past the
// occluders; the occluders' share (lit / arch) is the source's visibility, drawn in the look
// (smooth, 3 levels dithered, 2 hard) before it scales the source's light. Samples turn per world
// pixel by the game's Bayer 4×4: the penumbra is the game's dither, fixed in the world.

#include "res://lighting/sun_geometry.gdshaderinc"

// Light per room (colour × energy at that room's exposure).
uniform vec3 room_sun[4];
uniform vec3 room_night[4];
uniform vec3 room_sky[4];
// Far sources: towards them (x, d, z; z 1), off when 0.
uniform vec3 sun_dir = vec3(0.0, 1.0, 1.0);
uniform int sun_on = 0;
uniform vec3 night_dir = vec3(0.0, -1.0, 1.0);
uniform int night_on = 0;
uniform float sun_soft = 0.04; // tan of the sun disc's radius (the night light: the same)
uniform int sun_samples = 12;
uniform float facing_full = 0.35; // light through a wall the source only grazes fades out
uniform float wall_max = 1.5; // a wall facing a low sun gets at most this × the floor's light
uniform int side_patch = 0; // side windows light no patch (decided, tickets 27 and 31): only ribbons
// Sky through every sash (Lambert's polygon form factor, smooth) × the share of its glass seen past the
// occluders (sky_grid² samples on the glass).
uniform int sky_on = 1;
uniform float sky_ref = 0.25;
uniform float front_glow = 2.0;
uniform float front_gamma = 0.7;
uniform float sky_other_k = 0.0;
uniform vec2 sky_sun = vec2(0.0);
uniform int door_sash = -1;
uniform float door_k = 0.5;
uniform int sky_grid = 3;
// The rooms' lamps: bulbs (x, d, z), colour × energy (lux on the floor right under them at their
// room's exposure), reach (m); 1/d² × cos, a shade, a bulb lamp_size across.
uniform int lamp_count = 0;
uniform vec3 lamps[16];
uniform vec3 lamp_color[16];
uniform float lamp_reach[16];
uniform float lamp_size = 0.1;
uniform int lamp_samples = 8;
uniform float shade_up = 0.25;
// Side windows' ribbons on the floor (game1-proto's look, ticket 31): a pane column traced back along
// the sun's horizontal direction, widened along the wall; lit as far as light through the head lands.
// Their visibility: the real sun rays from the floor point to the wall, past the occluders.
uniform int ribbon_count = 0;
uniform vec4 ribbons[16];
uniform int ribbon_wall[16];
uniform float ribbon_mid[16];
uniform float ribbon_gain = 1.0;
uniform float ribbon_reach = 1.0;
uniform float ribbon_span = 1.0;
uniform float ribbon_widen = 0.25;
uniform float ribbon_edge = 0.12;
uniform float ribbon_facing_full = 0.6;
uniform float ribbon_fade = 1.4;
// The look: 0 smooth; else the visibility in this many levels (3 dithered, 2 hard).
uniform int shadow_levels = 0;
uniform int shadow_dither = 1;

float look(float vis, vec2 px) {
	if (shadow_levels < 2) {
		return vis;
	}
	float steps = float(shadow_levels - 1);
	// Dithered only in a band round each step (a full-range dither turned a faint shadow into sparse dots).
	float t = shadow_dither == 1 ? 0.5 + (bayer4(px) - 0.5) * 0.6 : 0.5;
	return clamp(floor(vis * steps + t), 0.0, steps) / steps;
}

// The share kept: lit / arch in the look (1 where the architecture lets nothing through).
float kept(vec2 al, vec2 px) {
	return al.x > 1e-6 ? look(clamp(al.y / al.x, 0.0, 1.0), px) : 1.0;
}

// A far source through the sashes from o: x arch, y lit (means over the disc's samples).
vec2 far_source(vec3 o, vec3 toward, vec2 px, bool with_actor) {
	vec3 axis = normalize(toward);
	vec3 u;
	vec3 v;
	basis(axis, u, v);
	float turn = bayer4(px) * 6.2832;
	vec2 al = vec2(0.0);
	for (int i = 0; i < sun_samples; i++) {
		vec2 j = vogel(i, sun_samples, turn) * sun_soft;
		vec3 dir = axis + u * j.x + v * j.y;
		int face;
		float t = shell_exit(o, dir, face);
		if (face >= 2 && side_patch == 0) {
			continue;
		}
		if (sash_at(o + dir * t, face) < 0) {
			continue;
		}
		float gain = 1.0;
		if (facing_full > 0.0 && length(dir.xy) > 1e-4) {
			gain = smoothstep(0.0, facing_full, dot(normalize(dir.xy), wall_normal(face)));
		}
		al.x += gain;
		if (!blocked(o, dir, t, with_actor)) {
			al.y += gain;
		}
	}
	return al / float(sun_samples);
}

float far_lambert(vec3 n, vec3 toward) {
	vec3 axis = normalize(toward);
	return n.z > 0.5 ? 1.0 : clamp(dot(n, axis) / max(axis.z, 0.05), 0.0, wall_max);
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

// The sky from o (normal n): x arch, y lit (over sky_ref: the room's full sky light by a window).
vec2 sky_light(vec3 o, vec3 n, vec2 px, bool with_actor) {
	vec2 al = vec2(0.0);
	int own = room_index(o.xy);
	float jx = bayer4(px);
	float jz = bayer4(px + vec2(2.0, 1.0));
	float cells = float(sky_grid * sky_grid);
	for (int i = 0; i < sash_count; i++) {
		vec3 c[4];
		for (int k = 0; k < 4; k++) {
			c[k] = sash_corner(i, k);
		}
		vec3 middle = (c[0] + c[2]) / 2.0;
		float other = room_index(middle.xy) == own ? 1.0 : sky_other_k;
		if (other <= 0.0) {
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
		// Every wall alike (the human: the back windows lit the floor less than the others).
		f = sky_ref * pow(f / sky_ref, front_gamma);
		if (f < 1e-4) {
			continue;
		}
		float towards = max(0.2, 1.0 + dot(wall_normal(sash_wall[i]), sky_sun));
		float w = f * other * towards * front_glow * (i == door_sash ? door_k : 1.0);
		float seen = 0.0;
		for (int a = 0; a < sky_grid; a++) {
			for (int b = 0; b < sky_grid; b++) {
				vec2 at = (vec2(float(a), float(b)) + vec2(jx, jz)) / float(sky_grid);
				vec3 q = c[0] + (c[1] - c[0]) * at.x + (c[3] - c[0]) * at.y;
				seen += blocked(o, q - o, 0.999, with_actor) ? 0.0 : 1.0;
			}
		}
		al += vec2(w, w * seen / cells);
	}
	return al / sky_ref;
}

// The rooms' lamps from o (normal n), each in the look on its own.
vec3 lamp_light(vec3 o, vec3 n, vec2 px, bool with_actor) {
	vec3 total = vec3(0.0);
	float turn = bayer4(px) * 6.2832;
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
		float seen = 0.0;
		for (int k = 0; k < lamp_samples; k++) {
			vec2 j = vogel(k, lamp_samples, turn) * lamp_size * 0.5;
			vec3 spot = bulb + u * j.x + v * j.y;
			seen += blocked_by(o, spot - o, 1.0, with_actor, true, bulb) ? 0.0 : 1.0;
		}
		total += lamp_color[i] * e * look(seen / float(lamp_samples), px);
	}
	return total;
}

// The side windows' ribbons at floor point o: x arch, y lit (summed over the ribbons).
vec2 ribbon_light(vec3 o, vec2 px, bool with_actor) {
	vec2 al = vec2(0.0);
	float c = length(sun_dir.xy);
	if (sun_on == 0 || c < 1e-4) {
		return al;
	}
	vec2 h = sun_dir.xy / c;
	vec3 axis = normalize(sun_dir);
	vec3 u;
	vec3 v;
	basis(axis, u, v);
	float turn = bayer4(px) * 6.2832;
	for (int i = 0; i < ribbon_count; i++) {
		float nx = ribbon_wall[i] == 2 ? -1.0 : 1.0;
		float facing = h.x * nx;
		if (facing <= 0.0) {
			continue;
		}
		float wx = ribbon_wall[i] == 2 ? shell_min.x : shell_max.x;
		float t = (wx - o.x) / h.x;
		vec4 s = ribbons[i];
		float reach = s.w * c * ribbon_reach;
		if (t <= 0.0 || t >= reach) {
			continue;
		}
		float mid = ribbon_mid[i];
		float lo = mid + (s.x - mid) * ribbon_span;
		float hi = mid + (s.y - mid) * ribbon_span;
		float grow = (hi - lo) * ribbon_widen * t;
		if ((lo + hi) * 0.5 < mid - 0.01) {
			lo -= grow;
		} else if ((lo + hi) * 0.5 > mid + 0.01) {
			hi += grow;
		} else {
			lo -= grow * 0.5;
			hi += grow * 0.5;
		}
		float along = o.y + h.y * t;
		float inside = smoothstep(lo - ribbon_edge, lo + ribbon_edge, along) * (1.0 - smoothstep(hi - ribbon_edge, hi + ribbon_edge, along));
		if (inside <= 0.0) {
			continue;
		}
		float w = inside * pow(1.0 - t / reach, ribbon_fade) * smoothstep(0.0, ribbon_facing_full, facing);
		// The real sun rays from the point to the wall: the occluders standing in them.
		float seen = 0.0;
		for (int k = 0; k < sun_samples; k++) {
			vec2 j = vogel(k, sun_samples, turn) * sun_soft;
			vec3 dir = axis + u * j.x + v * j.y;
			float to_wall = (wx - o.x) / dir.x;
			seen += to_wall > 0.0 && blocked(o, dir, to_wall, with_actor) ? 0.0 : 1.0;
		}
		al += vec2(w, w * seen / float(sun_samples));
	}
	return al * ribbon_gain;
}

// What light_at() returns, by source (the debug views).
struct Light {
	vec3 sun;
	vec3 sky;
	vec3 night;
	vec3 lamps;
	vec4 shadow; // 1 − visibility: sun, sky, night, ribbons
};

// The light on surface point p (normal n), by source. with_actor false: p is on the actor.
Light light_parts(vec3 p, vec3 n, vec2 px, bool with_actor) {
	Light l;
	l.sun = vec3(0.0);
	l.sky = vec3(0.0);
	l.night = vec3(0.0);
	l.lamps = vec3(0.0);
	l.shadow = vec4(0.0);
	vec3 o = p + n * EPS;
	int room = room_index(p.xy);
	if (sun_on == 1) {
		vec2 al = far_source(o, sun_dir, px, with_actor);
		float k = kept(al, px);
		l.sun = room_sun[room] * far_lambert(n, sun_dir) * al.x * k;
		l.shadow.x = al.x > 1e-6 ? 1.0 - al.y / al.x : 0.0;
		if (ribbon_count > 0 && p.z < 0.01 && n.z > 0.5) {
			vec2 rl = ribbon_light(o, px, with_actor);
			l.sun += room_sun[room] * rl.x * kept(rl, px);
			l.shadow.w = rl.x > 1e-6 ? 1.0 - rl.y / rl.x : 0.0;
		}
	}
	if (night_on == 1) {
		vec2 al = far_source(o, night_dir, px, with_actor);
		l.night = room_night[room] * far_lambert(n, night_dir) * al.x * kept(al, px);
		l.shadow.z = al.x > 1e-6 ? 1.0 - al.y / al.x : 0.0;
	}
	if (sky_on == 1 && room_count > 0) {
		vec2 al = sky_light(o, n, px, with_actor);
		l.sky = room_sky[room] * al.x * kept(al, px);
		l.shadow.y = al.x > 1e-6 ? 1.0 - al.y / al.x : 0.0;
	}
	if (lamp_count > 0) {
		l.lamps = lamp_light(o, n, px, with_actor);
	}
	return l;
}
