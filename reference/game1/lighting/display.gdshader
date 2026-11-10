// Shows the HDR 2D view (a linear texture) as sRGB, with the screen-space overlays: fatigue stages,
// nightmare transition, sanity-check framing, nordic colour grade. Warps and blurs read the linear
// view; the grade, grain, vignette and eyelids act after the sRGB conversion, on what the eye sees.
shader_type canvas_item;

uniform float vignette = 0.0;
uniform float desat = 0.0;
uniform float blink = 0.0;
uniform float blur = 0.0;
uniform float nightmare = 0.0;
uniform float sanity = 0.0;
uniform float grade = 0.5;          // nordic grade: cool shadows, lifted blacks (chosen: P2, shots/cmp/kalibracja_post.png)
uniform float grain = 0.015;        // film grain amplitude
uniform float base_vignette = 0.0;  // always-on vignette, added to the fatigue one

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 to_srgb(vec3 c) {
	c = clamp(c, 0.0, 1.0);
	return mix(c * 12.92, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055, step(vec3(0.0031308), c));
}

vec3 sample_blur(sampler2D tex, vec2 uv, float r, vec2 texel) {
	vec2 px = r * texel;
	vec3 c = texture(tex, uv).rgb * 4.0;
	c += texture(tex, uv + vec2(px.x, 0.0)).rgb * 2.0;
	c += texture(tex, uv - vec2(px.x, 0.0)).rgb * 2.0;
	c += texture(tex, uv + vec2(0.0, px.y)).rgb * 2.0;
	c += texture(tex, uv - vec2(0.0, px.y)).rgb * 2.0;
	c += texture(tex, uv + px).rgb;
	c += texture(tex, uv - px).rgb;
	c += texture(tex, uv + vec2(px.x, -px.y)).rgb;
	c += texture(tex, uv + vec2(-px.x, px.y)).rgb;
	return c / 16.0;
}

void fragment() {
	float t = TIME;
	vec2 uv = UV;
	vec2 cuv = uv - 0.5;
	float edge = dot(cuv, cuv) * 4.0;

	// Nightmare: slow liquid warp, stronger towards the edges.
	uv += nightmare * vec2(sin(uv.y * 24.0 + t * 1.3), cos(uv.x * 18.0 + t * 1.1)) * 0.006 * (0.4 + edge);

	// Sanity check: heartbeat zoom and a little shake.
	float beat = pow(abs(sin(t * 3.2)), 12.0);
	uv = (uv - 0.5) * (1.0 - 0.025 * sanity * beat) + 0.5;
	uv += sanity * 0.002 * vec2(hash(vec2(t, 1.0)) - 0.5, hash(vec2(1.0, t)) - 0.5);

	float ca = 0.004 * nightmare + 0.006 * sanity * beat + 0.002 * blur;
	float r = blur * 2.5 + sanity * beat;
	vec3 col;
	if (r > 0.01) {
		col.r = sample_blur(TEXTURE, uv + vec2(ca, 0.0), r, TEXTURE_PIXEL_SIZE).r;
		col.g = sample_blur(TEXTURE, uv, r, TEXTURE_PIXEL_SIZE).g;
		col.b = sample_blur(TEXTURE, uv - vec2(ca, 0.0), r, TEXTURE_PIXEL_SIZE).b;
	} else {
		col.r = texture(TEXTURE, uv + vec2(ca, 0.0)).r;
		col.g = texture(TEXTURE, uv).g;
		col.b = texture(TEXTURE, uv - vec2(ca, 0.0)).b;
	}
	col = to_srgb(col);

	// Nordic grade: cooler shadows, lifted blacks, film grain (one grain per view pixel).
	vec3 cold = col * vec3(0.92, 0.98, 1.08) + vec3(0.012, 0.016, 0.026);
	col = mix(col, cold, grade);
	col += (hash(floor(UV / TEXTURE_PIXEL_SIZE) + fract(t) * 13.0) - 0.5) * grain;

	float lum = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, vec3(lum), clamp(desat + sanity * 0.5, 0.0, 1.0));

	// Nightmare grade: sickly red highlights, teal shadows.
	vec3 nm = vec3(lum * 1.25, lum * 0.55, lum * 0.6) + vec3(0.0, 0.05, 0.06) * (1.0 - lum);
	col = mix(col, nm, nightmare * 0.75);

	float v = smoothstep(0.25, 0.85, length(cuv * vec2(1.0, 0.8)) * 1.25);
	col *= 1.0 - clamp(base_vignette + vignette + nightmare * 0.5 + sanity * (0.3 + 0.4 * beat), 0.0, 1.0) * v;

	// Eyelids closing from top and bottom.
	if (blink > 0.001) {
		float lid = 0.56 * (1.0 - blink);
		col *= 1.0 - smoothstep(lid - 0.06, lid, abs(UV.y - 0.5));
	}

	COLOR = vec4(col, 1.0);
}
