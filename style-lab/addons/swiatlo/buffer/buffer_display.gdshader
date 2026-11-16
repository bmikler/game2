// Shows the light over the Location's picture: albedo × the styled light (A′ and exposure already
// applied). Scatter (light shafts, dust) will be added after this, unstyled (engine ticket 22).
shader_type canvas_item;
render_mode unshaded, blend_mul;

void fragment() {
	COLOR = vec4(texture(TEXTURE, UV).rgb, 1.0);
}
