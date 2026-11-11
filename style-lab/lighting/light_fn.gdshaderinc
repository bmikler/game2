// PROTOTYPE (ticket 36): the one light function. Every source (the sun through the sashes, the side
// windows' ribbons, the sky through every sash and the street door, the night through the windows, the
// rooms' lamps) is a sum of samples tested against the same occluders (sun_geometry: blocked_by). Per
// source: arch = what the architecture lets through (shell, sashes, walls, partitions, lintels), lit =
// what is left past the objects (furniture, stairs, the actor); the occluders' share (lit / arch) is the source's visibility (smooth),
// which scales the source's light. Samples turn per world
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
// The share kept: lit / arch, smooth (1 where the architecture lets nothing through). The levels and
// dither per source are gone (the human: thresholds on each source's soft share drew short, long and
// several hard shadows; the pixel-art look is to be done again, properly).
float kept(vec2 al, vec2 px) {
	return al.x > 1e-6 ? clamp(al.y / al.x, 0.0, 1.0) : 1.0;
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
		al += gain * ray_al(occlusion(o, dir, t, with_actor, false, vec3(0.0)));
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

// The objects' share of a sash's sky, exactly (the human: an actor under a window cast two crossed arms of
// shadow and left a lit patch straight behind it: the share of the glass's area hidden by a rectangle is_round
// the silhouette weighed the middle of the glass like its near edge, and lost the shadow beside the body).
// In the frame of the sash's wall: u along it, n from it into the room (the wall at n = 0), z up.
const int POLY_MAX = 16;

vec3 wall_local(vec3 p, int wall) {
	if (wall == 0) { return vec3(p.x, p.y - shell_min.y, p.z); }
	if (wall == 1) { return vec3(p.x, shell_max.y - p.y, p.z); }
	if (wall == 2) { return vec3(p.y, p.x - shell_min.x, p.z); }
	return vec3(p.y, shell_max.x - p.x, p.z);
}

vec3 wall_local_dir(vec3 v, int wall) {
	if (wall == 0) { return v; }
	if (wall == 1) { return vec3(v.x, -v.y, v.z); }
	if (wall == 2) { return vec3(v.y, v.x, v.z); }
	return vec3(v.y, -v.x, v.z);
}

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

// The plan ray from o (unit dir) through the shape (is_round: middle c, radius r; else lo to hi): x in, y out;
// y < 0 missed.
vec2 shape_chord(vec2 o, vec2 dir, bool is_round, vec2 c, float r, vec2 lo, vec2 hi) {
	if (is_round) {
		vec2 to = c - o;
		float along = dot(dir, to);
		float q = r * r - (dot(to, to) - along * along);
		if (q < 0.0 || along + sqrt(q) <= 0.0) {
			return vec2(0.0, -1.0);
		}
		return vec2(max(along - sqrt(q), 0.0), along + sqrt(q));
	}
	float t0 = 0.0;
	float t1 = 1e9;
	for (int a = 0; a < 2; a++) {
		if (abs(dir[a]) < 1e-7) {
			if (o[a] < lo[a] || o[a] > hi[a]) {
				return vec2(0.0, -1.0);
			}
			continue;
		}
		float x = (lo[a] - o[a]) / dir[a];
		float y = (hi[a] - o[a]) / dir[a];
		t0 = max(t0, min(x, y));
		t1 = min(t1, max(x, y));
	}
	return t0 <= t1 ? vec2(t0, t1) : vec2(0.0, -1.0);
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

// The share of sash s's sky (glass: its form factor from o) one shape hides, all in the wall's frame. Its
// silhouette on the wall by columns: the plan ray to each column through the shape, the column's top and
// bottom from where the ray enters and leaves it (exact between a box's corners; a cylinder: 4 spans), the
// polygon clipped to the glass, its form factor over the glass's.
float shape_hide(vec3 o, vec3 n, vec4 s, float glass, bool is_round, vec2 c, float r, vec2 lo, vec2 hi, float z_lo, float z_hi) {
	float u0 = 1e9;
	float u1 = -1e9;
	float breaks[4];
	int break_count = 0;
	if (is_round) {
		vec2 to = c - o.xy;
		float dist = length(to);
		if (dist <= r) {
			// Inside the body (the floor under it); above its top (a wall or a box front the cylinder
			// touches, kept r behind the feet) the rays to a window pass over it.
			return o.z <= z_hi ? 1.0 : 0.0;
		}
		if (to.y >= r) {
			return 0.0; // all of it farther from the wall than o
		}
		float half_angle = asin(r / dist);
		vec2 mid = to / dist;
		float open_side = 0.0;
		for (int k = -1; k <= 1; k += 2) {
			float a = float(k) * half_angle;
			vec2 d = vec2(mid.x * cos(a) - mid.y * sin(a), mid.x * sin(a) + mid.y * cos(a));
			if (d.y >= 0.0) {
				// Running away from the wall: the rays reaching it pass the body on its middle's side
				// (this tangent's own side put the shadow on the wrong side of an actor beside o).
				open_side = mid.x >= 0.0 ? 1.0 : -1.0;
				continue;
			}
			float u = o.x - d.x * o.y / d.y;
			u0 = min(u0, u);
			u1 = max(u1, u);
		}
		if (open_side > 0.0) {
			u1 = 1e9;
		} else if (open_side < 0.0) {
			u0 = -1e9;
		}
	} else {
		// The box's part between o and the wall (2 cm off o: o on its face sees past it).
		lo.y = max(lo.y, 0.0);
		hi.y = min(hi.y, o.y - 0.02);
		if (lo.y >= hi.y) {
			return 0.0;
		}
		for (int k = 0; k < 4; k++) {
			float bu = (k & 1) == 0 ? lo.x : hi.x;
			float bn = k < 2 ? lo.y : hi.y;
			float u = o.x + (bu - o.x) * o.y / (o.y - bn);
			u0 = min(u0, u);
			u1 = max(u1, u);
			breaks[k] = u;
		}
		break_count = 4;
	}
	float a = max(u0, s.x);
	float b = min(u1, s.y);
	if (b <= a) {
		return 0.0;
	}
	// The columns (sorted): the ends, a box's corners between them, a cylinder's even spans.
	float cols[6];
	int count = 0;
	cols[count] = a;
	count++;
	if (is_round) {
		for (int k = 1; k < 4; k++) {
			cols[count] = mix(a, b, float(k) / 4.0);
			count++;
		}
	} else {
		for (int k = 0; k < break_count; k++) {
			if (breaks[k] > a && breaks[k] < b) {
				cols[count] = breaks[k];
				count++;
			}
		}
	}
	cols[count] = b;
	count++;
	for (int k = 1; k < count; k++) {
		float v = cols[k];
		int j = k - 1;
		while (j >= 0 && cols[j] > v) {
			cols[j + 1] = cols[j];
			j--;
		}
		cols[j + 1] = v;
	}
	vec3 p[POLY_MAX];
	float nudge = (b - a) * 1e-3; // the ends' rays only touch the shape: taken just inside
	for (int k = 0; k < count; k++) {
		float u = cols[k];
		vec2 w = vec2(clamp(u, a + nudge, b - nudge) - o.x, -o.y);
		float span = length(w);
		vec2 ch = shape_chord(o.xy, w / span, is_round, c, r, lo, hi);
		float top = s.z;
		float bottom = s.z;
		if (ch.y >= 0.0) {
			float t_in = max(ch.x / span, 1e-4);
			float t_out = clamp(ch.y / span, 1e-4, 1.0);
			top = o.z + (z_hi - o.z) / (o.z <= z_hi ? t_in : t_out);
			bottom = o.z + (z_lo - o.z) / (o.z >= z_lo ? t_in : t_out);
		}
		p[k] = vec3(u, 0.0, clamp(bottom, -100.0, 100.0));
		p[2 * count - 1 - k] = vec3(u, 0.0, clamp(top, -100.0, 100.0));
	}
	int corners = clip_z(p, 2 * count, s.z, 1.0);
	corners = clip_z(p, corners, s.w, -1.0);
	if (corners < 3) {
		return 0.0;
	}
	return clamp(polygon_factor(o, n, p, corners) / glass, 0.0, 1.0);
}

// The share of sash i's sky (weighed by the form factor, as its light) the objects (furniture, stairs, the
// actor) hide from o with normal n; several objects as independent (1 − Π).
float objects_hide(vec3 o, vec3 n, int i, bool with_actor) {
	int wall = sash_wall[i];
	vec4 s = sashes[i];
	vec3 ol = wall_local(o, wall);
	if (ol.y < 1e-3) {
		return 0.0;
	}
	vec3 nl = wall_local_dir(n, wall);
	vec3 glass_p[POLY_MAX];
	glass_p[0] = vec3(s.x, 0.0, s.z);
	glass_p[1] = vec3(s.y, 0.0, s.z);
	glass_p[2] = vec3(s.y, 0.0, s.w);
	glass_p[3] = vec3(s.x, 0.0, s.w);
	float glass = polygon_factor(ol, nl, glass_p, 4);
	if (glass < 1e-7) {
		return 0.0;
	}
	float open = 1.0;
	for (int b = 0; b < box_count + 1; b++) {
		vec3 lo;
		vec3 hi;
		if (b < box_count) {
			if (box_arch[b] == 1) {
				continue;
			}
			lo = box_min[b];
			hi = box_max[b];
		} else {
			if (!with_actor || actor_shape == 0) {
				continue;
			}
			vec3 c = wall_local(vec3(actor_body.xy, 0.0), wall);
			if (actor_shape == 1) {
				open *= 1.0 - shape_hide(ol, nl, s, glass, true, c.xy, actor_body.z, vec2(0.0), vec2(0.0), 0.0, actor_body.w);
				continue;
			}
			lo = vec3(actor_body.xy - vec2(actor_body.z), 0.0);
			hi = vec3(actor_body.xy + vec2(actor_body.z), actor_body.w);
		}
		vec3 l = wall_local(lo, wall);
		vec3 h = wall_local(hi, wall);
		open *= 1.0 - shape_hide(ol, nl, s, glass, false, vec2(0.0), 0.0, min(l, h).xy, max(l, h).xy, lo.z, hi.z);
	}
	return 1.0 - open;
}

// The sky from o (normal n): x arch, y lit, each sash in the look (over sky_ref: the room's full sky
// light by a window).
vec2 sky_light(vec3 o, vec3 n, vec2 px, bool with_actor) {
	vec2 al = vec2(0.0);
	int own = room_index(o.xy);
	float jx = bayer4(px);
	float jz = bayer4(px + vec2(2.0, 1.0));
	float cells = float(sky_grid * sky_grid);
	// Each window (its panes together) one source in the look: per pane, an actor in front of the
	// mullion hid under half of each pane and a lit wedge showed straight behind it (the human).
	vec2 pane_sum = vec2(0.0); // the window so far: arch, lit (smooth)
	int window = -1;
	for (int i = 0; i < sash_count; i++) {
		if (sash_window[i] != window) {
			al += vec2(pane_sum.x, pane_sum.x * kept(pane_sum, px));
			pane_sum = vec2(0.0);
			window = sash_window[i];
		}
		vec3 c[4];
		for (int k = 0; k < 4; k++) {
			c[k] = sash_corner(i, k);
		}
		vec3 middle = (c[0] + c[2]) / 2.0;
		float other = room_index(middle.xy) == own ? 1.0 : sky_other_k;
		if (other <= 0.0) {
			continue;
		}
		// Signed by the winding as seen from o (abs() lit a surface facing away from the glass as one
		// facing it: the front of the actor under a back window, the human); not clipped to the
		// surface's half space, so a sash half behind it counts in part.
		float f = 0.0;
		float winding = 0.0;
		vec3 towards_glass = normalize(middle - o);
		for (int k = 0; k < 4; k++) {
			vec3 a = normalize(c[k] - o);
			vec3 b = normalize(c[(k + 1) % 4] - o);
			vec3 g = cross(a, b);
			float len = length(g);
			if (len > 1e-6) {
				float angle = acos(clamp(dot(a, b), -1.0, 1.0));
				f += angle * dot(n, g / len);
				winding += angle * dot(towards_glass, g / len);
			}
		}
		f = max(f * sign(winding), 0.0) / 6.2832;
		// Every wall alike (the human: the back windows lit the floor less than the others).
		f = sky_ref * pow(f / sky_ref, front_gamma);
		if (f < 1e-4) {
			continue;
		}
		float towards = max(0.2, 1.0 + dot(wall_normal(sash_wall[i]), sky_sun));
		float w = f * other * towards * front_glow * (i == door_sash ? door_k : 1.0);
		// The architecture by samples on the glass (smooth: not in the look); the objects analytically.
		float open = 0.0;
		for (int a = 0; a < sky_grid; a++) {
			for (int b = 0; b < sky_grid; b++) {
				vec2 at = (vec2(float(a), float(b)) + vec2(jx, jz)) / float(sky_grid);
				vec3 q = c[0] + (c[1] - c[0]) * at.x + (c[3] - c[0]) * at.y;
				open += arch_blocked(o, q - o, 0.999) ? 0.0 : 1.0;
			}
		}
		open /= cells;
		if (open <= 0.0) {
			continue;
		}
		// Each window its own source in the look: the actor hiding only the faint light through a
		// doorway took a hard bite out of the whole sky there (the human).
		pane_sum += w * open * vec2(1.0, 1.0 - objects_hide(o, n, i, with_actor));
	}
	al += vec2(pane_sum.x, pane_sum.x * kept(pane_sum, px));
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
		vec2 seen = vec2(0.0);
		for (int k = 0; k < lamp_samples; k++) {
			vec2 j = vogel(k, lamp_samples, turn) * lamp_size * 0.5;
			vec3 spot = bulb + u * j.x + v * j.y;
			seen += ray_al(occlusion(o, spot - o, 1.0, with_actor, true, bulb));
		}
		total += lamp_color[i] * e * seen.x / float(lamp_samples) * kept(seen, px);
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
		vec2 seen = vec2(0.0);
		for (int k = 0; k < sun_samples; k++) {
			vec2 j = vogel(k, sun_samples, turn) * sun_soft;
			vec3 dir = axis + u * j.x + v * j.y;
			float to_wall = (wx - o.x) / dir.x;
			seen += to_wall > 0.0 ? ray_al(occlusion(o, dir, to_wall, with_actor, false, vec3(0.0))) : vec2(1.0);
		}
		al += w * seen / float(sun_samples);
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
		l.sky = room_sky[room] * al.y;
		l.shadow.y = al.x > 1e-6 ? 1.0 - al.y / al.x : 0.0;
	}
	if (lamp_count > 0) {
		l.lamps = lamp_light(o, n, px, with_actor);
	}
	return l;
}
