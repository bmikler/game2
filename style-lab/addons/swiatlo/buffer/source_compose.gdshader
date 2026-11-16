// Adds one source group's layer to its channel: the layer (light at intensity 1, the sum of red,
// green and blue × scale) × the group's colour × lux at the hour.
shader_type canvas_item;
render_mode unshaded, blend_add;

uniform sampler2D layer : filter_nearest;
uniform vec3 light = vec3(0.0);
uniform float scale = 0.0;

void fragment() {
	vec3 sums = texture(layer, UV).rgb;
	COLOR = vec4(light * (sums.r + sums.g + sums.b) * scale, 1.0);
}
