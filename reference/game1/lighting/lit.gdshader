// The material of every lit sprite (floors, walls, props, actors), see Lit. A room's ambient is a
// flat light far above it (Lit.AMBIENT_HEIGHT): it skips N·L, so it lights every surface evenly and
// normal maps shape sprites only through real lamps and windows. Other lights: Godot's default.
shader_type canvas_item;

void light() {
	float ndl = LIGHT_POSITION.z > 5000.0 ? 1.0 : max(0.0, dot(NORMAL, LIGHT_DIRECTION));
	LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * ndl, LIGHT_COLOR.a);
}
