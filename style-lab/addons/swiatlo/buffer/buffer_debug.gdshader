// Shows the light buffer's debug colours over the Location's picture as they are.
shader_type canvas_item;
render_mode unshaded;

void fragment() {
	COLOR = vec4(texture(TEXTURE, UV).rgb, 1.0);
}
