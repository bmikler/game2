// A′ stylisation: light in lux per pixel (natural, and artificial when there is any) → styled light
// after exposure, which multiplies the albedo. Levels in EV anchored to `anchor` (open sky); at
// each level boundary a dither seam `seam_px` pixels wide whatever the slope (research 84, §6); a
// short step (a thing's soft halo) is dithered over its whole length instead (research 92, §4b).
// The slope comes from the gentler one-sided difference per axis, so a jump between two surfaces
// (a sprite's edge, a hard shadow edge) is not a slope and spreads no seam.
shader_type canvas_item;
render_mode unshaded, blend_disabled;

const int MODE_PER_CHANNEL = 1;
const int SKY_LEVELS = 0;
const int SKY_SMOOTH = 1;
const int PATTERN_CHECKER = 1;
// What `levels` styles.
const int NATURAL = 0;
const int ARTIFICIAL = 1;
const int BOTH = 2;
// The natural light's sun part (alpha × `sun_light`), and the rest of it (sky, ambient); the
// light with hard shadow edges: the sun and the artificial channel.
const int SUN = 3;
const int SOFT = 4;
const int HARD = 5;
// Below this (lux after exposure) a pixel has no light to style.
const float NO_LIGHT = 1e-6;

uniform sampler2D natural : filter_nearest;
uniform sampler2D artificial : filter_nearest;
uniform bool has_artificial = false;
uniform ivec2 size = ivec2(1);
// The Location pixel of the input's first pixel: the pattern sticks to Location pixels.
uniform vec2 origin_px = vec2(0.0);
uniform int mode = 0;
// 0: the light without a hard edge (sky, ambient) in levels with the sun's, 1: smooth, 2: always
// dithered; in 1 and 2 only the sun gets levels.
uniform int sky_style = 0;
uniform vec3 sun_light = vec3(0.0);
uniform float level_stops = 0.5;
uniform float seam_px = 3.0;
// A step between levels shorter than this (pixels) is dithered over its whole length; 0: never.
uniform float full_dither_px = 24.0;
uniform int seam_pattern = 0;
uniform float exposure = 1.0;
// `Y_ref` in lux before exposure.
uniform float anchor = 1.0;

float luma(vec3 light) {
	return dot(light, vec3(0.2126, 0.7152, 0.0722));
}

// Light after exposure of the natural channel, the artificial one, both summed, the natural
// channel's sun or soft part, or the sun with the artificial channel.
vec3 fetch(int which, ivec2 px) {
	if (which == SUN || which == SOFT || which == HARD) {
		vec4 natural_light = texelFetch(natural, px, 0);
		vec3 sun = sun_light * natural_light.a;
		if (which == SOFT) {
			return max(natural_light.rgb - sun, vec3(0.0)) * exposure;
		}
		if (which == HARD && has_artificial) {
			sun += texelFetch(artificial, px, 0).rgb;
		}
		return sun * exposure;
	}
	vec3 light = vec3(0.0);
	if (which != ARTIFICIAL) {
		light += texelFetch(natural, px, 0).rgb;
	}
	if (which != NATURAL && has_artificial) {
		light += texelFetch(artificial, px, 0).rgb;
	}
	return light * exposure;
}

// Level coordinate of an exposed luma: whole numbers are boundaries, the anchor sits at ½.
float steps_of(float y) {
	return log2(max(y, NO_LIGHT) / (anchor * exposure)) / level_stops + 0.5;
}

// The gentler one-sided slope along `axis` (level steps per pixel); lit neighbours only.
float slope(int which, ivec2 px, ivec2 axis, float s) {
	float best = -1.0;
	for (int side = -1; side <= 1; side += 2) {
		ivec2 other = px + axis * side;
		if (other.x < 0 || other.y < 0 || other.x >= size.x || other.y >= size.y) {
			continue;
		}
		float y = luma(fetch(which, other));
		if (y < NO_LIGHT) {
			continue;
		}
		float d = abs(steps_of(y) - s);
		best = best < 0.0 ? d : min(best, d);
	}
	return max(best, 0.0);
}

// Threshold of the ordered pattern at a Location pixel, in (0, 1).
float pattern(ivec2 px) {
	ivec2 p = px & ivec2(3);
	if (seam_pattern == PATTERN_CHECKER) {
		return ((p.x + p.y) & 1) == 0 ? 0.25 : 0.75;
	}
	int a = p.x ^ p.y;
	int v = ((a & 1) << 3) | ((p.y & 1) << 2) | (a & 2) | ((p.y >> 1) & 1);
	return (float(v) + 0.5) / 16.0;
}

// The light at `px`, styled: its luma moves to the middle of a level, its colour stays. `dithered`:
// a dither between the two nearest levels however gentle the slope (no flat field).
vec3 levels(int which, ivec2 px, float threshold, bool dithered) {
	vec3 light = fetch(which, px);
	float y = luma(light);
	if (y < NO_LIGHT) {
		return light;
	}
	float s = steps_of(y);
	float g = length(vec2(slope(which, px, ivec2(1, 0), s), slope(which, px, ivec2(0, 1), s)));
	// A step shorter than `full_dither_px` (1/g pixels) is dithered all along, one longer than twice
	// that keeps the narrow seam (research 92 §4b).
	float w = clamp(seam_px * g, 0.0, 1.0);
	if (dithered) {
		w = 1.0;
	} else if (full_dither_px > 0.0) {
		w = mix(w, 1.0, smoothstep(0.5 / full_dither_px, 1.0 / full_dither_px, g));
	}
	float k = floor(s + w * (threshold - 0.5));
	return light * (anchor * exposure * exp2(k * level_stops)) / y;
}

varying vec2 local_px;

void vertex() {
	local_px = VERTEX;
}

void fragment() {
	ivec2 px = ivec2(floor(local_px));
	float threshold = pattern(px + ivec2(origin_px));
	vec3 result;
	if (sky_style != SKY_LEVELS) {
		// Levels only for the light with hard shadow edges (the sun, the artificial channel): on
		// their sum, or on each apart (mode); the rest is smooth or dithered.
		if (mode == MODE_PER_CHANNEL) {
			result = levels(SUN, px, threshold, false);
			if (has_artificial) {
				result += levels(ARTIFICIAL, px, threshold, false);
			}
		} else {
			result = levels(HARD, px, threshold, false);
		}
		result += sky_style == SKY_SMOOTH ? fetch(SOFT, px) : levels(SOFT, px, threshold, true);
	} else if (mode == MODE_PER_CHANNEL) {
		result = levels(NATURAL, px, threshold, false);
		if (has_artificial) {
			result += levels(ARTIFICIAL, px, threshold, false);
		}
	} else {
		result = levels(BOTH, px, threshold, false);
	}
	COLOR = vec4(result, 1.0);
}
