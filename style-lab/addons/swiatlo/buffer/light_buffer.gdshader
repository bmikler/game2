// The light buffer: one pixel per game pixel over the whole Location. Each pixel finds the surface
// the projection shows there (an asset's sprite pixel on its solids, or the scene receiver nearest the
// camera), then sums the natural light reaching that point in lux (HDR):
// ambient + sky × sky share + sun × visibility (+ natural sources); sprite pixels add rim light and
// keep a fill minimum.
// Alpha holds the sun's share (its cosine × visibility, with rim light): × the sun's light it is the
// sun's part of the pixel's lux (the A′ pass tells the sun from the sky by it). No surface: all 0.
shader_type canvas_item;
render_mode unshaded, blend_disabled;

#include "res://addons/swiatlo/buffer/receivers.gdshaderinc"
#include "res://addons/swiatlo/buffer/visibility.gdshaderinc"
#include "res://addons/swiatlo/buffer/surfaces.gdshaderinc"

const int VIEW_RECEIVERS = 2;
const int VIEW_CHANNELS = 3;

// The sky layer (counts of open dome directions in red + green + blue) and one over the directions
// counted so far.
uniform sampler2D sky_share : filter_nearest;
uniform float sky_share_scale = 0.0;
// The light sources' channels in lux (SourceLight): natural ones join this buffer's light; the
// artificial one is only read for the channels view.
uniform sampler2D natural_sources : filter_nearest;
uniform bool has_natural_sources = false;
uniform sampler2D artificial_sources : filter_nearest;

uniform vec3 sun_direction = vec3(0.0, 0.0, 1.0);
// Colour × lux.
uniform vec3 sun_light = vec3(0.0);
uniform vec3 sky_light = vec3(0.0);
uniform vec3 ambient_light = vec3(0.0);
// Solid receivers (tuning set): rim light from a sun behind them (× sun), and the least light they
// keep (× ambient + sky of open ground).
uniform float rim = 0.0;
uniform float fill = 0.0;
// 0: light, 2: receivers, 3: channels (debug views).
uniform int debug_view = 0;

varying vec2 local_px;

void vertex() {
	local_px = VERTEX;
}

void fragment() {
	vec3 point;
	vec3 normal;
	vec3 face_normal;
	int found = find_surface(local_px, point, normal, face_normal);
	if (found < 0) {
		COLOR = vec4(0.0);
	} else if (debug_view == VIEW_RECEIVERS) {
		vec3 hue = face_normal.z > 0.5 ? vec3(0.35, 0.55, 1.0) : (face_normal.y > 0.5 ? vec3(1.0, 0.6, 0.2) : vec3(0.4, 0.9, 0.4));
		if (found > 0) {
			// Sprite pixels: the light falls on the normal map's normal, shown as its colour.
			hue = normal * 0.5 + 0.5;
		}
		COLOR = vec4(hue * (found % 2 == 0 ? 1.0 : 0.7), 1.0);
	} else {
		vec3 counts = texelFetch(sky_share, ivec2(local_px), 0).rgb;
		float sky = (counts.r + counts.g + counts.b) * sky_share_scale;
		vec3 start = point + face_normal * RAY_OFFSET_M;
		float sun = max(dot(normal, sun_direction), 0.0);
		if (sun > 0.0) {
			sun *= visibility(start, sun_direction, FAR_M);
		}
		float back = 0.0;
		if (found > 0 && rim > 0.0 && sun_direction.z > 0.0) {
			// Rim light: a sun behind the solid lights the edges turned from the camera; the asset's
			// own solids do not shade it (the edge is where the sun passes them).
			vec3 toward_camera = normalize(vec3(0.0, 1.0, depth_factor));
			float edge = 1.0 - max(dot(normal, toward_camera), 0.0);
			back = rim * max(-dot(sun_direction, toward_camera), 0.0) * edge * edge;
			if (back > 0.0) {
				ivec2 own = asset_solids(found);
				back *= visibility_skipping(start, sun_direction, FAR_M, own.x, own.y);
			}
		}
		if (debug_view == VIEW_CHANNELS) {
			// Geometry of the natural channel, without colours: red the sun (its cosine on the face
			// × visibility), blue the sky share; green the artificial channel's share of it and of
			// the open sky's light.
			float artificial = dot(texelFetch(artificial_sources, ivec2(local_px), 0).rgb, vec3(0.2126, 0.7152, 0.0722));
			float open_sky = dot(ambient_light + sky_light, vec3(0.2126, 0.7152, 0.0722));
			COLOR = vec4(sun, artificial / max(artificial + open_sky, 1e-6), sky, 1.0);
		} else {
			vec3 light = ambient_light + sky_light * sky + sun_light * (sun + back);
			if (found > 0) {
				light = max(light, fill * (ambient_light + sky_light));
			}
			if (has_natural_sources) {
				light += texelFetch(natural_sources, ivec2(local_px), 0).rgb;
			}
			COLOR = vec4(light, sun + back);
		}
	}
}
