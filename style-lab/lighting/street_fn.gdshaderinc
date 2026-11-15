// PROTOTYPE (ticket 14, „Światło w Poligonach”): the street's light, the house's model in the open (one
// function, one set of occluders, the actor as a cylinder like any object). Sources: the sun (its disc's
// samples past every occluder: buildings with their roofs, trees, lamps, the car, snowbanks, the actor),
// the sky (the upper hemisphere less what the occluders' faces cover: the polygon form factor, as the sky
// through a sash), the street lamps (points, the house's lamp_light), the lit windows by night (a pane on a
// facade glowing outwards: its form factor, the sky through a sash turned round; occluders by samples on
// it). Buildings, the terrace and walls are architecture (box_arch 1), the rest objects: the look (ticket
// 37) treats them as in the house.

#include "res://lighting/light_common.gdshaderinc"

uniform vec3 street_sun = vec3(0.0); // colour × energy (lux at the room's exposure) on open ground
uniform vec3 street_sky = vec3(0.0); // the whole sky's light on open ground
uniform vec3 sun_dir = vec3(0.0, -1.0, 1.0);
uniform int sun_on = 0;
uniform float sun_soft = 0.04;
uniform int sun_samples = 12;
uniform float wall_max = 1.5;
uniform int building_shadows = 1; // 0: the architecture casts no sun shadow (variant, ticket 27)
uniform int sky_on = 1;
uniform float sky_cull = 0.0015; // an occluder whose (radius / distance)² is under this hides no sky
// An object's sky shadow (the actor's as any other's) fades out by this far from its footprint (m): the
// actor's buffer window reaches as far. Architecture keeps its whole sky shadow.
uniform float object_sky_reach = 4.0;
// Lit windows: x0, x1, z0, z1 on a facade at d = win_d facing +d; colour × energy per form factor.
uniform int win_count = 0;
uniform vec4 win_rect[64];
uniform float win_d[64];
uniform vec3 win_color[64];
uniform float win_reach = 6.0;
uniform int win_grid = 2;

// Keeps the part of polygon p with dot(nrm, q - at) >= 0 (Sutherland–Hodgman, one plane).
int clip_plane(inout vec3 p[POLY_MAX], int count, vec3 nrm, vec3 at) {
	vec3 kept_p[POLY_MAX];
	int kept_count = 0;
	for (int k = 0; k < count; k++) {
		vec3 a = p[k];
		vec3 b = p[(k + 1) % count];
		float da = dot(nrm, a - at);
		float db = dot(nrm, b - at);
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

// The lowest and highest corner of occluder i (the actor: index box_count).
void occluder_bounds(int i, out vec3 lo, out vec3 hi) {
	if (i < box_count) {
		lo = box_min[i];
		hi = box_max[i];
	} else {
		lo = vec3(actor_body.xy - vec2(actor_body.z), 0.0);
		hi = vec3(actor_body.xy + vec2(actor_body.z), actor_body.w);
	}
}

// Face k of occluder i as a polygon (its outward normal in nrm); 0 corners: no such face. A plain box (and
// the actor, as its box for the sky): 0 top, 1 front (+d), 2 back, 3 left, 4 right. A roofed box: 0 and 1
// the slopes, 2 and 3 the walls across the ridge, 4 and 5 the walls along it (gables when the ridge runs
// along d: pentagons up to the ridge).
int occluder_face(int i, int k, out vec3 p[POLY_MAX], out vec3 nrm) {
	vec3 lo;
	vec3 hi;
	occluder_bounds(i, lo, hi);
	int roof = i < box_count ? int(box_roof[i].x + 0.5) : 0;
	if (roof == 0) {
		if (k == 0) {
			nrm = vec3(0.0, 0.0, 1.0);
			p[0] = vec3(lo.x, lo.y, hi.z); p[1] = vec3(hi.x, lo.y, hi.z); p[2] = vec3(hi.x, hi.y, hi.z); p[3] = vec3(lo.x, hi.y, hi.z);
			return 4;
		}
		if (k == 1 || k == 2) {
			float d = k == 1 ? hi.y : lo.y;
			nrm = vec3(0.0, k == 1 ? 1.0 : -1.0, 0.0);
			p[0] = vec3(lo.x, d, lo.z); p[1] = vec3(hi.x, d, lo.z); p[2] = vec3(hi.x, d, hi.z); p[3] = vec3(lo.x, d, hi.z);
			return 4;
		}
		if (k == 3 || k == 4) {
			float x = k == 4 ? hi.x : lo.x;
			nrm = vec3(k == 4 ? 1.0 : -1.0, 0.0, 0.0);
			p[0] = vec3(x, lo.y, lo.z); p[1] = vec3(x, hi.y, lo.z); p[2] = vec3(x, hi.y, hi.z); p[3] = vec3(x, lo.y, hi.z);
			return 4;
		}
		return 0;
	}
	// Roofed: `a` the ridge's axis's other (the slopes fall along it), `r` the ridge's axis.
	int a = roof == 1 ? 1 : 0;
	int r = 1 - a;
	float h = hi.z - box_roof[i].y;
	float mid = (lo[a] + hi[a]) * 0.5;
	// Builds a point from (along the slope axis, along the ridge axis, z).
	if (k == 0 || k == 1) {
		float edge = k == 0 ? lo[a] : hi[a];
		vec4 pa;
		vec4 pb;
		roof_planes(i, pa, pb);
		nrm = normalize(k == 0 ? pa.xyz : pb.xyz);
		vec3 q0 = vec3(0.0); q0[a] = edge; q0[r] = lo[r]; q0.z = h;
		vec3 q1 = q0; q1[r] = hi[r];
		vec3 q2 = q1; q2[a] = mid; q2.z = hi.z;
		vec3 q3 = q0; q3[a] = mid; q3.z = hi.z;
		p[0] = q0; p[1] = q1; p[2] = q2; p[3] = q3;
		return 4;
	}
	if (k == 2 || k == 3) {
		// The walls under the eaves, across the slope axis (at lo[a] and hi[a]).
		float edge = k == 2 ? lo[a] : hi[a];
		nrm = vec3(0.0);
		nrm[a] = k == 2 ? -1.0 : 1.0;
		vec3 q0 = vec3(0.0); q0[a] = edge; q0[r] = lo[r]; q0.z = lo.z;
		vec3 q1 = q0; q1[r] = hi[r];
		vec3 q2 = q1; q2.z = h;
		vec3 q3 = q0; q3.z = h;
		p[0] = q0; p[1] = q1; p[2] = q2; p[3] = q3;
		return 4;
	}
	if (k == 4 || k == 5) {
		// The gables at the ridge's ends (pentagons).
		float end = k == 4 ? lo[r] : hi[r];
		nrm = vec3(0.0);
		nrm[r] = k == 4 ? -1.0 : 1.0;
		vec3 q0 = vec3(0.0); q0[r] = end; q0[a] = lo[a]; q0.z = lo.z;
		vec3 q1 = q0; q1[a] = hi[a];
		vec3 q2 = q1; q2.z = h;
		vec3 q3 = q0; q3[a] = mid; q3.z = hi.z;
		vec3 q4 = q0; q4.z = h;
		p[0] = q0; p[1] = q1; p[2] = q2; p[3] = q3; p[4] = q4;
		return 5;
	}
	return 0;
}

// The sky over o (normal n): x arch, y lit, over the open ground's sky (1 under an open sky on the ground;
// an upright face: a half). Each occluder's faces facing o, clipped to above o's horizon and in front of
// its surface, hide their form factor; several occluders as independent (1 − Π).
vec2 street_sky_light(vec3 o, vec3 n, bool with_actor, bool with_objects) {
	float open = (1.0 + n.z) * 0.5;
	if (open < 1e-4) {
		return vec2(0.0);
	}
	float keep_arch = 1.0;
	float keep_obj = 1.0;
	for (int i = 0; i < box_count + 1; i++) {
		bool actor = i == box_count;
		if (actor && (!with_actor || actor_shape == 0)) {
			continue;
		}
		bool arch = !actor && box_arch[i] == 1;
		if (!arch && !with_objects) {
			continue;
		}
		vec3 lo;
		vec3 hi;
		occluder_bounds(i, lo, hi);
		if (hi.z <= o.z + 1e-3) {
			continue;
		}
		vec3 c = (lo + hi) * 0.5;
		vec3 to = c - o;
		float radius2 = dot(hi - lo, hi - lo) * 0.25;
		float dist2 = dot(to, to);
		if (dist2 > radius2 && radius2 < sky_cull * dist2) {
			continue;
		}
		float f = 0.0;
		int faces = !actor && box_roof[i].x > 0.5 ? 6 : 5;
		for (int k = 0; k < faces; k++) {
			vec3 p[POLY_MAX];
			vec3 nrm;
			int count = occluder_face(i, k, p, nrm);
			if (count < 3 || dot(nrm, o - p[0]) <= 1e-4) {
				continue; // facing away from o (or o on it)
			}
			count = clip_z(p, count, o.z, 1.0);
			if (count >= 3) {
				count = clip_plane(p, count, n, o);
			}
			if (count >= 3) {
				f += polygon_factor(o, n, p, count);
			}
		}
		float hide = clamp(f / open, 0.0, 1.0);
		if (!arch) {
			float away = distance(o.xy, clamp(o.xy, lo.xy, hi.xy));
			hide *= 1.0 - smoothstep(object_sky_reach * 0.6, object_sky_reach, away);
		}
		if (arch) {
			keep_arch *= 1.0 - hide;
		} else {
			keep_obj *= 1.0 - hide;
		}
	}
	return vec2(open * keep_arch, open * keep_arch * keep_obj);
}

// Lambert of a far source on normal n, over open ground's (1 on the ground).
float street_lambert(vec3 n, vec3 toward) {
	vec3 axis = normalize(toward);
	return clamp(dot(n, axis) / max(axis.z, 0.05), 0.0, wall_max);
}

// The sun from o: x arch, y lit (means over the disc's samples).
vec2 street_sun_light(vec3 o, vec2 px, bool with_actor) {
	vec3 axis = normalize(sun_dir);
	vec3 u;
	vec3 v;
	basis(axis, u, v);
	float turn = bayer4(px) * 6.2832;
	vec2 al = vec2(0.0);
	for (int i = 0; i < sun_samples; i++) {
		vec2 j = vogel(i, sun_samples, turn) * sun_soft;
		int occ = occlusion(o, axis + u * j.x + v * j.y, 1e4, with_actor, false, vec3(0.0));
		if (occ == 2 && building_shadows == 0) {
			occ = 0;
		}
		al += ray_al(occ);
	}
	return al / float(sun_samples);
}

// The lit windows from o (normal n); arch what the architecture lets through.
vec3 window_light(vec3 o, vec3 n, vec2 px, bool with_actor, out vec3 arch) {
	vec3 total = vec3(0.0);
	arch = vec3(0.0);
	float jx = bayer4(px);
	float jz = bayer4(px + vec2(2.0, 1.0));
	for (int i = 0; i < win_count; i++) {
		vec4 w = win_rect[i];
		float d = win_d[i];
		if (o.y <= d + 1e-3) {
			continue; // behind the facade
		}
		vec3 near = vec3(clamp(o.x, w.x, w.y), d, clamp(o.z, w.z, w.w));
		float gap = distance(near, o);
		if (gap > win_reach) {
			continue;
		}
		// Faded out towards the reach (a hard cut drew arcs on the snow).
		float fade = 1.0 - smoothstep(win_reach * 0.5, win_reach, gap);
		vec3 p[POLY_MAX];
		p[0] = vec3(w.x, d, w.z); p[1] = vec3(w.y, d, w.z); p[2] = vec3(w.y, d, w.w); p[3] = vec3(w.x, d, w.w);
		int count = clip_plane(p, 4, n, o);
		if (count < 3) {
			continue;
		}
		float f = polygon_factor(o, n, p, count);
		if (f < 1e-5) {
			continue;
		}
		vec2 seen = vec2(0.0);
		for (int a = 0; a < win_grid; a++) {
			for (int b = 0; b < win_grid; b++) {
				vec2 at = (vec2(float(a), float(b)) + vec2(jx, jz)) / float(win_grid);
				vec3 q = vec3(mix(w.x, w.y, at.x), d + 0.01, mix(w.z, w.w, at.y));
				seen += ray_al(occlusion(o, q - o, 0.999, with_actor, false, vec3(0.0)));
			}
		}
		seen /= float(win_grid * win_grid);
		vec3 through = win_color[i] * f * fade * seen.x;
		arch += through;
		total += through * kept(seen, px);
	}
	return total;
}

// The light on surface point p (normal n), by source (night: the lit windows). with_actor false: p is
// on the actor.
Light street_parts(vec3 p, vec3 n, vec2 px, bool with_actor) {
	Light l;
	l.sun = vec3(0.0);
	l.sky = vec3(0.0);
	l.night = vec3(0.0);
	l.lamps = vec3(0.0);
	l.shadow = vec4(0.0);
	vec3 o = p + n * EPS;
	vec3 sun_arch = vec3(0.0);
	vec3 win_arch = vec3(0.0);
	vec3 lamp_arch = vec3(0.0);
	if (sun_on == 1) {
		vec2 al = street_sun_light(o, px, with_actor);
		sun_arch = street_sun * street_lambert(n, sun_dir) * al.x;
		l.sun = sun_arch * kept(al, px);
		l.shadow.x = al.x > 1e-6 ? 1.0 - al.y / al.x : 0.0;
	}
	if (sky_on == 1) {
		if (look_key()) {
			vec2 al = street_sky_light(o, n, with_actor, false);
			float c = contact_shade(o, n, with_actor);
			l.sky = street_sky * al.y * (1.0 - c);
			l.shadow.y = c;
		} else {
			vec2 al = street_sky_light(o, n, with_actor, true);
			l.sky = street_sky * al.y;
			l.shadow.y = al.x > 1e-6 ? 1.0 - al.y / al.x : 0.0;
		}
	}
	if (win_count > 0) {
		l.night = window_light(o, n, px, with_actor, win_arch);
	}
	if (lamp_count > 0) {
		l.lamps = lamp_light(o, n, px, with_actor, lamp_arch);
	}
	if (look_key()) {
		float rest = luma(l.sky + room_ambient[0]);
		float sun_t = luma(sun_arch);
		float win_t = luma(win_arch);
		float lamp_t = luma(lamp_arch);
		float key = sun_t + win_t + lamp_t;
		l.sun = key_style(sun_arch, l.sun, rest + key - sun_t, px);
		l.night = key_style(win_arch, l.night, rest + key - win_t, px);
		l.lamps = key_style(lamp_arch, l.lamps, rest + key - lamp_t, px);
		l.shadow.x = sun_t > 1e-6 ? 1.0 - luma(l.sun) / sun_t : 0.0;
		l.shadow.z = win_t > 1e-6 ? 1.0 - luma(l.night) / win_t : 0.0;
	}
	return l;
}

// The surface a world pixel shows on the street: the nearest to the viewer (more z) of the ground and the
// receiving occluders' fronts, tops and roof slopes. False: none (the sky above everything).
bool street_surface_at(vec2 world, out vec3 p, out vec3 n) {
	float x = world.x / ppm;
	float d0 = (world.y - floor_y) / (ppm * kd); // the line: d = d0 + z / kd
	float best = -1.0;
	if (x >= shell_min.x && x <= shell_max.x && d0 >= shell_min.y && d0 <= shell_max.y) {
		best = 0.0;
		p = vec3(x, d0, 0.0);
		n = vec3(0.0, 0.0, 1.0);
	}
	for (int i = 0; i < box_count; i++) {
		float top = box_top[i];
		vec3 lo = box_min[i];
		vec3 hi = box_max[i];
		if (top < 0.0 || x < lo.x || x > hi.x || top <= best) {
			continue;
		}
		int roof = int(box_roof[i].x + 0.5);
		float rise = box_roof[i].y;
		float h = hi.z - rise;
		// The front's top at this x: the eaves, or up a gable.
		float front_top = top;
		if (roof == 1) {
			front_top = h;
		} else if (roof == 2) {
			float half_w = (hi.x - lo.x) * 0.5;
			front_top = h + rise * (1.0 - abs(x - (lo.x + hi.x) * 0.5) / max(half_w, 1e-4));
		}
		float zf = (hi.y - d0) * kd;
		if (zf >= lo.z && zf <= front_top && zf > best) {
			best = zf;
			p = vec3(x, hi.y, zf);
			n = vec3(0.0, 1.0, 0.0);
		}
		if (roof == 0) {
			float dt = d0 + top / kd;
			if (dt >= lo.y && dt <= hi.y && top > best) {
				best = top;
				p = vec3(x, dt, top);
				n = vec3(0.0, 0.0, 1.0);
			}
		} else if (roof == 1) {
			// The front slope: z = h + k (hi.y − d) for d from the ridge to the eaves.
			float k = rise / max((hi.y - lo.y) * 0.5, 1e-4);
			float z = (h + k * (hi.y - d0)) / (1.0 + k / kd);
			float d = d0 + z / kd;
			if (d >= (lo.y + hi.y) * 0.5 && d <= hi.y && z > best) {
				best = z;
				p = vec3(x, d, z);
				n = normalize(vec3(0.0, k, 1.0));
			}
		} else {
			// A slope falling to the side: its height depends on x only.
			float half_w = max((hi.x - lo.x) * 0.5, 1e-4);
			float k = rise / half_w;
			float side = x < (lo.x + hi.x) * 0.5 ? -1.0 : 1.0;
			float z = h + rise * (1.0 - abs(x - (lo.x + hi.x) * 0.5) / half_w);
			float d = d0 + z / kd;
			if (d >= lo.y && d <= hi.y && z > best) {
				best = z;
				p = vec3(x, d, z);
				n = normalize(vec3(side * k, 0.0, 1.0));
			}
		}
	}
	return best >= 0.0;
}
