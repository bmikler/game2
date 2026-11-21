// The day sweep's sample (engine ticket 29): every `stride`-th pixel of the light buffer → red the
// levelled light (what A′ put on levels, lux before exposure), green the artificial light, blue the
// sun's light, alpha the whole styled light (lux before exposure). One small readback per hour
// instead of three whole buffers.
shader_type canvas_item;
render_mode unshaded, blend_disabled;

uniform sampler2D natural : filter_nearest;
uniform sampler2D artificial : filter_nearest;
uniform sampler2D styled : filter_nearest;
uniform bool has_artificial = false;
uniform int stride = 1;
uniform vec3 sun_light = vec3(0.0);
uniform float to_lux = 1.0;
// The smooth sky is added after the levels, unstyled (sky style B): subtracted, what is left is on levels.
uniform bool smooth_sky = true;

varying vec2 local_px;

float luma(vec3 light) {
	return dot(light, vec3(0.2126, 0.7152, 0.0722));
}

void vertex() {
	local_px = VERTEX;
}

void fragment() {
	ivec2 px = ivec2(floor(local_px)) * stride;
	vec4 natural_light = texelFetch(natural, px, 0);
	vec3 sun = sun_light * natural_light.a;
	float total = luma(texelFetch(styled, px, 0).rgb) * to_lux;
	float levelled = total;
	if (smooth_sky) {
		levelled -= luma(max(natural_light.rgb - sun, vec3(0.0)));
	}
	float lamps = has_artificial ? luma(texelFetch(artificial, px, 0).rgb) : 0.0;
	COLOR = vec4(levelled, lamps, luma(sun), total);
}
