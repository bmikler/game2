// The asset layer: where each asset's sprite is opaque, its number (from 1) and the normal map's
// normal in the engine's axes (x right, d towards the camera, z up). Alpha stays 1 (the 2D renderer
// does not keep data in it): red = ±(number + ½ with a normal), the sign the normal's d; green and
// blue its x and z (d follows from them). Sprites are drawn far ones first, so a nearer one wins.
shader_type canvas_item;
render_mode unshaded, blend_disabled;

// The normal map's encoding and its empty pixel (AssetSprite.NORMAL_*).
const float NORMAL_ZERO = 128.0;
const float NORMAL_SCALE = 127.0;
const float NORMAL_MIN_LENGTH = 0.5;
// Added to the asset number when the pixel has a normal (surfaces.gdshaderinc reads it back).
const float HAS_NORMAL_TAG = 0.5;

uniform float asset_number = 0.0;
uniform bool has_normal_map = false;
uniform sampler2D normal_map : filter_nearest;

void fragment() {
	if (texture(TEXTURE, UV).a < 0.5) {
		discard;
	}
	vec3 normal = vec3(0.0);
	if (has_normal_map) {
		// Prowadnice v2: colour = 128 + 127·(nx, nz, −ny), R right, G up, B towards the camera.
		vec3 encoded = (round(texture(normal_map, UV).rgb * 255.0) - NORMAL_ZERO) / NORMAL_SCALE;
		normal = vec3(encoded.r, encoded.b, encoded.g);
	}
	if (length(normal) > NORMAL_MIN_LENGTH) {
		normal = normalize(normal);
		COLOR = vec4((normal.y < 0.0 ? -1.0 : 1.0) * (asset_number + HAS_NORMAL_TAG), normal.x, normal.z, 1.0);
	} else {
		COLOR = vec4(asset_number, 0.0, 0.0, 1.0);
	}
}
