// PROTOTYPE (ticket 31): the window sun from geometry (SunGeometry). Metres: x across, y = d into the
// depth from the back wall, z up. World px: x = ppm·x, y = floor_y + ppm·(kd·d − z).

uniform float ppm = 40.0;
uniform float kd = 0.6;
uniform float floor_y = 88.0;
uniform vec3 shell_min;
uniform vec3 shell_max;
uniform int sash_count = 0;
uniform vec4 sashes[64];
uniform int sash_wall[64]; // 0 back (d min), 1 front (d max), 2 left (x min), 3 right (x max)
uniform int box_count = 0;
uniform vec3 box_min[64];
uniform vec3 box_max[64];
uniform float box_top[64]; // shown top (receivers), < 0: not a receiver
// The actor as an occluder (ticket 33, „Cień postaci z mapy światła”): its shape, feet (x, d m),
// half width and height. actor_in_map 1: blocked() counts it (the whole map repainted every frame, or
// the beams in the air); 0: only the shadow window (SunMap) tests it, through hit_actor().
uniform int actor_shape = 0; // 0 none, 1 cylinder, 2 box, 3 flat rectangle facing the light, 4 flat figure facing the light
uniform vec4 actor_body = vec4(0.0, 0.0, 0.22, 1.8); // feet x, feet d, half width, height
uniform float actor_half_depth = 0.15; // the box and the cylinder: their middle this far behind the feet line
uniform int actor_in_map = 0;
uniform int room_count = 0;
uniform vec4 room_rect[4]; // x0, d0, x1, d1
uniform vec3 room_light[4]; // colour × energy at that room's exposure
// Light through a wall the source only grazes fades out (artistic, as the hand-tuned windows'
// top_facing_full): full when the source's horizontal direction is this cos off the wall's normal.
uniform float facing_full = 0.0;
uniform int front_back = 1; // 0: back and front windows light nothing here (their beams: SunMap polygons)
uniform float side_k = 1.0; // light through the side walls, × this (the air: their beams must read)
uniform int side_walls = 1; // 0: side windows light nothing here (their beams: SunMap ribbons, as game1-proto)

const float EPS = 0.003;

// Where the ray o + t·dir leaves the shell, and through which face (4: the ceiling or never).
float shell_exit(vec3 o, vec3 dir, out int face) {
	float t = 1e9;
	face = 4;
	if (dir.z > 1e-5) { t = (shell_max.z - o.z) / dir.z; }
	if (dir.y < -1e-5) { float s = (shell_min.y - o.y) / dir.y; if (s < t) { t = s; face = 0; } }
	if (dir.y > 1e-5) { float s = (shell_max.y - o.y) / dir.y; if (s < t) { t = s; face = 1; } }
	if (dir.x < -1e-5) { float s = (shell_min.x - o.x) / dir.x; if (s < t) { t = s; face = 2; } }
	if (dir.x > 1e-5) { float s = (shell_max.x - o.x) / dir.x; if (s < t) { t = s; face = 3; } }
	return t;
}

bool through_sash(vec3 q, int face) {
	if (face == 4) {
		return false;
	}
	float u = face < 2 ? q.x : q.y;
	for (int i = 0; i < sash_count; i++) {
		vec4 s = sashes[i];
		if (sash_wall[i] == face && u >= s.x && u <= s.y && q.z >= s.z && q.z <= s.w) {
			return true;
		}
	}
	return false;
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

bool hit_cylinder(vec3 o, vec3 dir, float t_max, vec4 actor_cyl) {
	vec2 oc = o.xy - actor_cyl.xy;
	float r = actor_cyl.z;
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
		float tb = (actor_cyl.w - o.z) / dir.z;
		z0 = min(ta, tb);
		z1 = max(ta, tb);
	} else if (o.z < 0.0 || o.z > actor_cyl.w) {
		return false;
	}
	float tn = max(t0, z0);
	float tf = min(t1, z1);
	return tf >= max(tn, 0.0) && tn < t_max;
}

// The flat figure's half width at height z (m, of 1.8): legs, hips, torso and arms, neck, head.
float figure_half(float z, float h) {
	float k = z / h * 1.8;
	if (k < 0.85) { return 0.14; }
	if (k < 1.0) { return 0.18; }
	if (k < 1.45) { return 0.24; }
	if (k < 1.52) { return 0.06; }
	if (k < 1.78) { return 0.1; }
	return 0.0;
}

// The actor's middle (x, d): a body point there is inside it.
vec2 actor_middle() {
	return vec2(actor_body.x, actor_body.y - actor_half_depth);
}

// The ray o + t·dir (t < t_max) hits the actor.
bool hit_actor(vec3 o, vec3 dir, float t_max) {
	vec2 middle = actor_middle();
	float half_w = actor_body.z;
	float h = actor_body.w;
	if (actor_shape == 1) {
		return hit_cylinder(o, dir, t_max, vec4(middle, half_w, h));
	}
	if (actor_shape == 2) {
		vec3 inv = vec3(
				abs(dir.x) > 1e-8 ? 1.0 / dir.x : 1e8,
				abs(dir.y) > 1e-8 ? 1.0 / dir.y : 1e8,
				abs(dir.z) > 1e-8 ? 1.0 / dir.z : 1e8);
		return hit_box(o, inv, vec3(middle.x - half_w, middle.y - actor_half_depth, 0.0),
				vec3(middle.x + half_w, middle.y + actor_half_depth, h), t_max);
	}
	if (actor_shape >= 3) {
		// A card standing at its middle, turned to face the light horizontally (a sprite's shadow).
		float level = length(dir.xy);
		if (level < 1e-5) {
			return false;
		}
		vec2 along = dir.xy / level;
		float t = dot(middle - o.xy, along) / level;
		if (t <= 0.0 || t >= t_max) {
			return false;
		}
		vec3 q = o + dir * t;
		if (q.z < 0.0 || q.z > h) {
			return false;
		}
		float across = abs(dot(q.xy - middle, vec2(-along.y, along.x)));
		return across < (actor_shape == 3 ? half_w : figure_half(q.z, h));
	}
	return false;
}

bool blocked(vec3 o, vec3 dir, float t_max) {
	vec3 inv = vec3(
			abs(dir.x) > 1e-8 ? 1.0 / dir.x : 1e8,
			abs(dir.y) > 1e-8 ? 1.0 / dir.y : 1e8,
			abs(dir.z) > 1e-8 ? 1.0 / dir.z : 1e8);
	for (int i = 0; i < box_count; i++) {
		if (hit_box(o, inv, box_min[i], box_max[i], t_max)) {
			return true;
		}
	}
	// A point on the actor's body (the actor's light) is not shadowed by the actor itself.
	if (actor_in_map == 1 && actor_shape > 0 && distance(o.xy, actor_middle()) > actor_body.z + 0.05 && hit_actor(o, dir, t_max)) {
		return true;
	}
	return false;
}

// 1 when light from direction `dir` (towards the source) reaches p through a sash; `reach`: the ray
// stops there (a point source: 1), else the shell exit.
float visible_through(vec3 p, vec3 dir, float reach, out float t_exit) {
	int face;
	t_exit = shell_exit(p, dir, face);
	if (t_exit > reach || (side_walls == 0 && face >= 2) || (front_back == 0 && face < 2) || !through_sash(p + dir * t_exit, face)) {
		return 0.0;
	}
	if (blocked(p, dir, t_exit)) {
		return 0.0;
	}
	float gain = face >= 2 ? side_k : 1.0;
	if (facing_full <= 0.0 || length(dir.xy) < 1e-4) {
		return gain;
	}
	vec2 normal = face == 0 ? vec2(0.0, -1.0) : (face == 1 ? vec2(0.0, 1.0) : (face == 2 ? vec2(-1.0, 0.0) : vec2(1.0, 0.0)));
	return gain * smoothstep(0.0, facing_full, dot(normalize(dir.xy), normal));
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

vec3 room_at(vec2 xd) {
	return room_count > 0 ? room_light[room_index(xd)] : vec3(0.0);
}

// Sky through the windows: no grazing fade.
bool sky_through(vec3 p, vec3 dir) {
	int face;
	float t = shell_exit(p, dir, face);
	return !(side_walls == 0 && face >= 2) && through_sash(p + dir * t, face) && !blocked(p, dir, t);
}

vec2 vogel(int i, int count) {
	float r = sqrt((float(i) + 0.5) / float(count));
	float a = float(i) * 2.39996;
	return r * vec2(cos(a), sin(a));
}
