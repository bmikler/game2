// Which receiver a buffer pixel shows: the face its line of sight (projection with depth factor)
// meets nearest the camera. Shared by every layer of the light buffer, so they agree pixel by pixel.

const float EDGE_TOLERANCE = 1e-4;
const int RECEIVER_TRIANGLE = 1;
const int RECEIVER_DISK = 2;
const int RECEIVER_CYLINDER = 3;

// Receivers, four texels each: (origin, normal.x), (edge_u, normal.y), (edge_v, normal.z),
// (kind, height, 0, 0). Kinds: 0 parallelogram, 1 triangle, 2 disk, 3 upright cylinder's side
// (Receiver.Kind).
uniform sampler2D receivers : filter_nearest;
uniform int receiver_count = 0;
uniform vec2 area_origin_px = vec2(0.0);
uniform float px_per_m = 40.0;
uniform float depth_factor = 0.6;

// The receiver at the buffer pixel `local_px` (−1: none), with the point it shows and its normal
// there (metres: x right, d towards the camera, z up).
int find_receiver(vec2 local_px, out vec3 point, out vec3 normal) {
	vec2 screen_m = (area_origin_px + floor(local_px) + 0.5) / px_per_m;
	float best_d = -1e9;
	int found = -1;
	point = vec3(0.0);
	normal = vec3(0.0, 0.0, 1.0);
	for (int index = 0; index < receiver_count; index++) {
		vec4 a = texelFetch(receivers, ivec2(index * 4, 0), 0);
		vec4 b = texelFetch(receivers, ivec2(index * 4 + 1, 0), 0);
		vec4 c = texelFetch(receivers, ivec2(index * 4 + 2, 0), 0);
		vec4 shape = texelFetch(receivers, ivec2(index * 4 + 3, 0), 0);
		int kind = int(round(shape.x));
		vec3 n = vec3(a.w, b.w, c.w);
		float d;
		if (kind == RECEIVER_CYLINDER) {
			// The pixel's line of sight is the vertical plane x = screen x; it meets the side's
			// front half (the half nearer the camera) where the ellipse is.
			float across = (screen_m.x - a.x) / b.x;
			if (abs(across) > 1.0) {
				continue;
			}
			float out_d = sqrt(1.0 - across * across);
			d = a.y + c.y * out_d;
			float z = d * depth_factor - screen_m.y;
			if (d <= best_d || z < a.z - EDGE_TOLERANCE || z > a.z + shape.y + EDGE_TOLERANCE) {
				continue;
			}
			n = normalize(vec3(across / b.x, out_d / c.y, 0.0));
		} else {
			// The pixel's line of sight: (x, d, d·depth − y); where does it cross the face's plane?
			float facing = n.y + depth_factor * n.z;
			if (facing <= 0.0) {
				continue;
			}
			d = (dot(n, a.xyz) - n.x * screen_m.x + n.z * screen_m.y) / facing;
			if (d <= best_d) {
				continue;
			}
			// The point in the face's edges: w = u·edge_u + v·edge_v (edges need not be at right angles).
			vec3 w = vec3(screen_m.x, d, d * depth_factor - screen_m.y) - a.xyz;
			float uu = dot(b.xyz, b.xyz);
			float uv = dot(b.xyz, c.xyz);
			float vv = dot(c.xyz, c.xyz);
			float wu = dot(w, b.xyz);
			float wv = dot(w, c.xyz);
			float det = uu * vv - uv * uv;
			float u = (wu * vv - wv * uv) / det;
			float v = (wv * uu - wu * uv) / det;
			bool inside;
			if (kind == RECEIVER_TRIANGLE) {
				inside = u >= -EDGE_TOLERANCE && v >= -EDGE_TOLERANCE && u + v <= 1.0 + EDGE_TOLERANCE;
			} else if (kind == RECEIVER_DISK) {
				inside = u * u + v * v <= 1.0 + EDGE_TOLERANCE;
			} else {
				inside = u >= -EDGE_TOLERANCE && u <= 1.0 + EDGE_TOLERANCE && v >= -EDGE_TOLERANCE && v <= 1.0 + EDGE_TOLERANCE;
			}
			if (!inside) {
				continue;
			}
		}
		best_d = d;
		found = index;
		point = vec3(screen_m.x, d, d * depth_factor - screen_m.y);
		normal = n;
	}
	return found;
}
