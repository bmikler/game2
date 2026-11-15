// PROTOTYPE (ticket 36, „Przebudowa światła wnętrza na jeden bufor z cieniami”): the house in metres
// (SunGeometry) and the one set of occluders every light is tested against. x across, y = d into the
// depth from the back wall, z up. World px: x = ppm·x, y = floor_y + ppm·(kd·d − z).
// Architecture: the shell and its sashes (glass only). Occluders: boxes (furniture, partitions,
// lintels, stairs) and the actor (a cylinder, or a box for the swap test), all alike.

uniform float ppm = 40.0;
uniform float kd = 0.6;
uniform float floor_y = 88.0;
uniform vec3 shell_min;
uniform vec3 shell_max;
uniform int sash_count = 0;
uniform vec4 sashes[128]; // u from, u to (x for back and front walls, d for side walls), z from, z to
uniform int sash_wall[128]; // 0 back (d min), 1 front (d max), 2 left (x min), 3 right (x max)
uniform int sash_window[128]; // the window a sash (a pane) belongs to: its panes are one source
uniform int box_count = 0;
uniform vec3 box_min[128];
uniform vec3 box_max[128];
uniform float box_top[128]; // shown top (a receiver), < 0: only an occluder
uniform int box_arch[128]; // 1: architecture (walls, lintels, partitions): its shadow is not drawn in the look
// Ticket 14: a box with a roof (the street's buildings): x the type (0 none, 1 ridge along x: slopes to
// -d and +d, 2 ridge along d: slopes to -x and +x), y the rise; the box's top is the ridge, the eaves rise lower.
uniform vec2 box_roof[128];
uniform int actor_shape = 0; // 0 none, 1 cylinder, 2 box
uniform vec4 actor_body = vec4(0.0, 0.0, 0.26, 1.8); // middle x, middle d, radius (half width), height
uniform int room_count = 0;
uniform vec4 room_rect[4]; // x0, d0, x1, d1

const float EPS = 0.003;

// Where the ray o + t·dir leaves the shell, and through which face (4: the ceiling or the floor).
float shell_exit(vec3 o, vec3 dir, out int face) {
	float t = 1e9;
	face = 4;
	if (dir.z > 1e-5) { t = (shell_max.z - o.z) / dir.z; }
	if (dir.z < -1e-5) { t = (shell_min.z - o.z) / dir.z; }
	if (dir.y < -1e-5) { float s = (shell_min.y - o.y) / dir.y; if (s < t) { t = s; face = 0; } }
	if (dir.y > 1e-5) { float s = (shell_max.y - o.y) / dir.y; if (s < t) { t = s; face = 1; } }
	if (dir.x < -1e-5) { float s = (shell_min.x - o.x) / dir.x; if (s < t) { t = s; face = 2; } }
	if (dir.x > 1e-5) { float s = (shell_max.x - o.x) / dir.x; if (s < t) { t = s; face = 3; } }
	return t;
}

// The sash at shell point q on face `face`, or -1.
int sash_at(vec3 q, int face) {
	if (face == 4) {
		return -1;
	}
	float u = face < 2 ? q.x : q.y;
	for (int i = 0; i < sash_count; i++) {
		vec4 s = sashes[i];
		if (sash_wall[i] == face && u >= s.x && u <= s.y && q.z >= s.z && q.z <= s.w) {
			return i;
		}
	}
	return -1;
}

vec3 inverse_dir(vec3 dir) {
	return vec3(
			abs(dir.x) > 1e-8 ? 1.0 / dir.x : 1e8,
			abs(dir.y) > 1e-8 ? 1.0 / dir.y : 1e8,
			abs(dir.z) > 1e-8 ? 1.0 / dir.z : 1e8);
}

bool hit_box(vec3 o, vec3 inv, vec3 lo, vec3 hi, float t_max) {
	vec3 a = (lo - o) * inv;
	vec3 b = (hi - o) * inv;
	vec3 near = min(a, b);
	vec3 far = max(a, b);
	float tn = max(max(near.x, near.y), near.z);
	float tf = min(min(far.x, far.y), far.z);
	return tf >= max(tn, 0.0) && tn < t_max;
}

// The two roof planes of box i (n · p <= c), when it has a roof.
void roof_planes(int i, out vec4 a, out vec4 b) {
	vec3 lo = box_min[i];
	vec3 hi = box_max[i];
	float rise = box_roof[i].y;
	float h = hi.z - rise;
	int axis = box_roof[i].x > 1.5 ? 0 : 1;
	float half_span = max((hi[axis] - lo[axis]) * 0.5, 1e-4);
	float k = rise / half_span;
	vec3 n = vec3(0.0, 0.0, 1.0);
	n[axis] = -k;
	a = vec4(n, h - k * lo[axis]);
	n[axis] = k;
	b = vec4(n, h + k * hi[axis]);
}

// A box cut by its roof planes (a convex body) on o + t·dir, t in (0, t_max).
bool hit_roofed(int i, vec3 o, vec3 dir, vec3 inv, float t_max) {
	vec3 a = (box_min[i] - o) * inv;
	vec3 b = (box_max[i] - o) * inv;
	vec3 near = min(a, b);
	vec3 far = max(a, b);
	float tn = max(max(near.x, near.y), near.z);
	float tf = min(min(far.x, far.y), far.z);
	vec4 planes[2];
	roof_planes(i, planes[0], planes[1]);
	for (int k = 0; k < 2; k++) {
		float den = dot(planes[k].xyz, dir);
		float num = planes[k].w - dot(planes[k].xyz, o);
		if (abs(den) < 1e-8) {
			if (num < 0.0) {
				return false;
			}
			continue;
		}
		float t = num / den;
		if (den > 0.0) {
			tf = min(tf, t);
		} else {
			tn = max(tn, t);
		}
	}
	return tf >= max(tn, 0.0) && tn < t_max;
}

// Occluder i (a box, or a roofed box) on o + t·dir.
bool hit_occluder(int i, vec3 o, vec3 dir, vec3 inv, float t_max) {
	if (box_roof[i].x > 0.5) {
		return hit_roofed(i, o, dir, inv, t_max);
	}
	return hit_box(o, inv, box_min[i], box_max[i], t_max);
}

bool hit_cylinder(vec3 o, vec3 dir, float t_max, vec4 cyl) {
	vec2 oc = o.xy - cyl.xy;
	float r = cyl.z;
	float a = dot(dir.xy, dir.xy);
	float b = dot(oc, dir.xy);
	float c = dot(oc, oc) - r * r;
	float t0 = -1e9;
	float t1 = 1e9;
	if (a > 1e-8) {
		float disc = b * b - a * c;
		if (disc < 0.0) { return false; }
		float s = sqrt(disc);
		t0 = (-b - s) / a;
		t1 = (-b + s) / a;
	} else if (c > 0.0) {
		return false;
	}
	float z0 = -1e9;
	float z1 = 1e9;
	if (abs(dir.z) > 1e-6) {
		float ta = -o.z / dir.z;
		float tb = (cyl.w - o.z) / dir.z;
		z0 = min(ta, tb);
		z1 = max(ta, tb);
	} else if (o.z < 0.0 || o.z > cyl.w) {
		return false;
	}
	float tn = max(t0, z0);
	float tf = min(t1, z1);
	return tf >= max(tn, 0.0) && tn < t_max;
}

bool hit_actor(vec3 o, vec3 dir, vec3 inv, float t_max) {
	if (actor_shape == 1) {
		return hit_cylinder(o, dir, t_max, actor_body);
	}
	if (actor_shape == 2) {
		vec3 half_size = vec3(actor_body.z, actor_body.z, 0.0);
		return hit_box(o, inv, vec3(actor_body.xy, 0.0) - half_size, vec3(actor_body.xy + half_size.xy, actor_body.w), t_max);
	}
	return false;
}

// Any occluder on o + t·dir, t in (0, t_max). with_actor false: a point on the actor itself.
// skip_bulb: a lamp's own pole and shade (the bulb inside or just above a box) cast nothing.
bool blocked_by(vec3 o, vec3 dir, float t_max, bool with_actor, bool skip_own, vec3 bulb) {
	vec3 inv = inverse_dir(dir);
	for (int i = 0; i < box_count; i++) {
		if (skip_own && all(greaterThanEqual(bulb, box_min[i] - 0.02)) && all(lessThanEqual(bulb, box_max[i] + vec3(0.02, 0.02, 0.15)))) {
			continue;
		}
		if (hit_occluder(i, o, dir, inv, t_max)) {
			return true;
		}
	}
	return with_actor && hit_actor(o, dir, inv, t_max);
}

bool blocked(vec3 o, vec3 dir, float t_max, bool with_actor) {
	return blocked_by(o, dir, t_max, with_actor, false, vec3(0.0));
}

// What stands on o + t·dir, t in (0, t_max): 2 architecture, 1 an object only (furniture, stairs, the
// actor), 0 nothing. The look quantizes only the objects' share; the architecture's shadow stays as is.
int occlusion(vec3 o, vec3 dir, float t_max, bool with_actor, bool skip_own, vec3 bulb) {
	vec3 inv = inverse_dir(dir);
	int found = 0;
	for (int i = 0; i < box_count; i++) {
		if (skip_own && all(greaterThanEqual(bulb, box_min[i] - 0.02)) && all(lessThanEqual(bulb, box_max[i] + vec3(0.02, 0.02, 0.15)))) {
			continue;
		}
		if ((box_arch[i] == 1 || found == 0) && hit_occluder(i, o, dir, inv, t_max)) {
			if (box_arch[i] == 1) {
				return 2;
			}
			found = 1;
		}
	}
	if (found == 0 && with_actor && hit_actor(o, dir, inv, t_max)) {
		found = 1;
	}
	return found;
}

// Architecture only on o + t·dir, t in (0, t_max) (the sky's samples: objects are analytic there).
bool arch_blocked(vec3 o, vec3 dir, float t_max) {
	vec3 inv = inverse_dir(dir);
	for (int i = 0; i < box_count; i++) {
		if (box_arch[i] == 1 && hit_occluder(i, o, dir, inv, t_max)) {
			return true;
		}
	}
	return false;
}

// arch, lit for one ray: (1, 1) open, (1, 0) an object, (0, 0) architecture.
vec2 ray_al(int occ) {
	return occ == 0 ? vec2(1.0) : (occ == 1 ? vec2(1.0, 0.0) : vec2(0.0));
}

// The surface a world pixel shows: the nearest to the viewer of the floor, the back wall and the
// boxes' fronts and tops (on one pixel's line, more z is nearer). False: none (outside the house).
bool surface_at(vec2 world, out vec3 p, out vec3 n) {
	float x = world.x / ppm;
	if (x < shell_min.x || x > shell_max.x) {
		return false;
	}
	float d0 = (world.y - floor_y) / (ppm * kd); // the line: d = d0 + z / kd
	float best = -1.0;
	if (d0 >= shell_min.y && d0 <= shell_max.y) {
		best = 0.0;
		p = vec3(x, d0, 0.0);
		n = vec3(0.0, 0.0, 1.0);
	}
	float zw = (shell_min.y - d0) * kd;
	if (zw >= 0.0 && zw <= shell_max.z && zw > best) {
		best = zw;
		p = vec3(x, shell_min.y, zw);
		n = vec3(0.0, 1.0, 0.0);
	}
	for (int i = 0; i < box_count; i++) {
		float top = box_top[i];
		vec3 lo = box_min[i];
		vec3 hi = box_max[i];
		if (top < 0.0 || x < lo.x || x > hi.x || top <= best) {
			continue;
		}
		float dt = d0 + top / kd;
		if (dt >= lo.y && dt <= hi.y) {
			best = top;
			p = vec3(x, dt, top);
			n = vec3(0.0, 0.0, 1.0);
			continue;
		}
		float zf = (hi.y - d0) * kd;
		if (zf >= lo.z && zf <= top && zf > best) {
			best = zf;
			p = vec3(x, hi.y, zf);
			n = vec3(0.0, 1.0, 0.0);
		}
	}
	return best >= 0.0;
}

// The room the point (x, d) is in (or nearest to).
int room_index(vec2 xd) {
	int index = 0;
	float best = 1e9;
	for (int i = 0; i < room_count; i++) {
		vec4 r = room_rect[i];
		float gap = distance(clamp(xd, r.xy, r.zw), xd);
		if (gap < best) {
			best = gap;
			index = i;
		}
	}
	return index;
}

// The game's ordered dither (Bayer 4×4) on a world pixel, 0..1.
float bayer4(vec2 px) {
	int x = int(mod(floor(px.x), 4.0));
	int y = int(mod(floor(px.y), 4.0));
	int m[16] = int[](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
	return (float(m[y * 4 + x]) + 0.5) / 16.0;
}

// Sample i of count on a unit disc, the pattern turned by `turn` (radians).
vec2 vogel(int i, int count, float turn) {
	float r = sqrt((float(i) + 0.5) / float(count));
	float a = float(i) * 2.39996 + turn;
	return r * vec2(cos(a), sin(a));
}

void basis(vec3 axis, out vec3 u, out vec3 v) {
	u = normalize(abs(axis.z) < 0.99 ? cross(axis, vec3(0.0, 0.0, 1.0)) : cross(axis, vec3(1.0, 0.0, 0.0)));
	v = cross(axis, u);
}

vec2 wall_normal(int wall) {
	return wall == 0 ? vec2(0.0, -1.0) : (wall == 1 ? vec2(0.0, 1.0) : (wall == 2 ? vec2(-1.0, 0.0) : vec2(1.0, 0.0)));
}
