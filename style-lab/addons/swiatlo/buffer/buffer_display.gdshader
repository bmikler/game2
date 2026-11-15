// Shows the light buffer over the Location's picture: albedo × light after exposure.
shader_type canvas_item;
render_mode unshaded, blend_mul;

uniform float exposure = 1.0;

void fragment() {
	COLOR = vec4(texture(TEXTURE, UV).rgb * exposure, 1.0);
}
