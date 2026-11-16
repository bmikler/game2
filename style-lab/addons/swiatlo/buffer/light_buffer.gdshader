// The light buffer: one pixel per game pixel over the whole Location. Each pixel finds the receiver
// the projection shows there (the face nearest the camera), then sums the natural light reaching
// that point in lux (HDR): ambient + sky × sky share + sun × visibility.
shader_type canvas_item;
render_mode unshaded, blend_disabled;

#include "res://addons/swiatlo/buffer/receivers.gdshaderinc"
#include "res://addons/swiatlo/buffer/visibility.gdshaderinc"

const int VIEW_RECEIVERS = 2;
const int VIEW_CHANNELS = 3;

// The sky layer (counts of open dome directions in red + green + blue) and one over the directions
// counted so far.
uniform sampler2D sky_share : filter_nearest;
uniform float sky_share_scale = 0.0;

uniform vec3 sun_direction = vec3(0.0, 0.0, 1.0);
// Colour × lux.
uniform vec3 sun_light = vec3(0.0);
uniform vec3 sky_light = vec3(0.0);
uniform vec3 ambient_light = vec3(0.0);
// 0: light, 2: receivers, 3: channels (debug views).
uniform int debug_view = 0;

varying vec2 local_px;

void vertex() {
	local_px = VERTEX;
}

void fragment() {
	vec3 point;
	vec3 normal;
	int found = find_receiver(local_px, point, normal);
	if (found < 0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else if (debug_view == VIEW_RECEIVERS) {
		vec3 hue = normal.z > 0.5 ? vec3(0.35, 0.55, 1.0) : (normal.y > 0.5 ? vec3(1.0, 0.6, 0.2) : vec3(0.4, 0.9, 0.4));
		COLOR = vec4(hue * (found % 2 == 0 ? 1.0 : 0.7), 1.0);
	} else {
		vec3 counts = texelFetch(sky_share, ivec2(local_px), 0).rgb;
		float sky = (counts.r + counts.g + counts.b) * sky_share_scale;
		float sun = max(dot(normal, sun_direction), 0.0);
		if (sun > 0.0) {
			sun *= visibility(point + normal * RAY_OFFSET_M, sun_direction, FAR_M);
		}
		if (debug_view == VIEW_CHANNELS) {
			// Geometry of the natural channel, without colours: red the sun (its cosine on the face
			// × visibility), blue the sky share; green is kept for the artificial channel.
			COLOR = vec4(sun, 0.0, sky, 1.0);
		} else {
			COLOR = vec4(ambient_light + sky_light * sky + sun_light * sun, 1.0);
		}
	}
}
