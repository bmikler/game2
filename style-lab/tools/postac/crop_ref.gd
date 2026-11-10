# PROTOTYP (ticket „Przepis postaci”, kopia z game1-proto): wycięcie postaci z konceptu pod referencję Pixellab.
# Zmiana: tło usuwane po odległości koloru od tła (arg 8, domyślnie 0.12), nie po jasności i nasyceniu.
# godot --headless --script crop_ref.gd -- <in.png> <out.png> <x> <y> <w> <h> <size> <figure_px>
# Flood-fills the flat sheet background from the crop edges to transparency, then fits
# the figure into a <size>x<size> square, feet at the bottom.
extends SceneTree

const FOOT_MARGIN := 7.0



func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var img := Image.load_from_file(a[0])
	img.convert(Image.FORMAT_RGBA8)
	img = img.get_region(Rect2i(int(a[2]), int(a[3]), int(a[4]), int(a[5])))
	var bg := img.get_pixel(0, 0)
	var tol := float(a[8]) if a.size() > 8 else 0.12
	var w := img.get_width()
	var h := img.get_height()
	var seen := PackedByteArray()
	seen.resize(w * h)
	var stack: Array[Vector2i] = []
	for x in w:
		stack.append(Vector2i(x, 0))
		stack.append(Vector2i(x, h - 1))
	for y in h:
		stack.append(Vector2i(0, y))
		stack.append(Vector2i(w - 1, y))
	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h or seen[p.y * w + p.x]:
			continue
		seen[p.y * w + p.x] = 1
		var c := img.get_pixelv(p)
		if maxf(maxf(absf(c.r - bg.r), absf(c.g - bg.g)), absf(c.b - bg.b)) > tol:
			continue
		img.set_pixelv(p, Color(0, 0, 0, 0))
		stack.append(p + Vector2i.LEFT)
		stack.append(p + Vector2i.RIGHT)
		stack.append(p + Vector2i.UP)
		stack.append(p + Vector2i.DOWN)
	# Arg 9 (opcjonalny): od tego ułamka wysokości w dół tło usuwane także w zamkniętych polach
	# (prześwit między nogami) i cień pod stopami (ciemniejszy, mało nasycony).
	if a.size() > 9:
		var from_y := roundi(h * float(a[9]))
		# Arg 10 (opcjonalny): od tego ułamka wysokości usuwany cień (Qwen rzuca długi cień w bok).
		var shadow_from := float(a[10]) if a.size() > 10 else 0.9
		# Arg 11 (opcjonalny): maks. nasycenie cienia (niebieskawe cienie Qwen mają > 0,2).
		var shadow_sat := float(a[11]) if a.size() > 11 else 0.2
		for y in range(from_y, h):
			for x in w:
				var c := img.get_pixel(x, y)
				if c.a == 0.0:
					continue
				var near_bg := maxf(maxf(absf(c.r - bg.r), absf(c.g - bg.g)), absf(c.b - bg.b)) < tol
				# Przy szarym tle odcień tła jest przypadkowy: liczy się tylko jasność i nasycenie.
				var shadow := c.s < shadow_sat and c.v > bg.v - 0.3 and c.v < bg.v + 0.05 \
						and (bg.s < 0.03 or absf(c.h - bg.h) < 0.08)
				if near_bg or (shadow and y > h * shadow_from):
					img.set_pixel(x, y, Color(0, 0, 0, 0))
	_drop_specks(img)
	var used := img.get_used_rect()
	img = img.get_region(used)
	var size := int(a[6])
	# Figure height relative to an 80 px sprite canvas (height in m × 40 px), arg 7.
	var s := size * float(a[7]) / 80.0 / maxf(img.get_width(), img.get_height())
	img.resize(maxi(1, roundi(img.get_width() * s)), maxi(1, roundi(img.get_height() * s)), Image.INTERPOLATE_LANCZOS)
	var out := Image.create(size, size, false, Image.FORMAT_RGBA8)
	# Feet FOOT_MARGIN px (on the 80 px canvas) above the bottom: generators pull a figure
	# that touches the edge down to it, and the walk template then cuts the soles off.
	var margin := roundi(size * FOOT_MARGIN / 80.0)
	out.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i((size - img.get_width()) / 2, size - margin - img.get_height()))
	out.save_png(a[1])
	print("ok ", used, " -> ", img.get_size())
	quit()


## Clears opaque islands smaller than SPECK_SHARE of the largest one (leftover shadow flecks
## under the feet); the figure itself is one connected island.
const SPECK_SHARE := 0.02


func _drop_specks(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var label := PackedInt32Array()
	label.resize(w * h)
	var sizes: Array[int] = [0]
	var stack: Array[int] = []
	for start in w * h:
		if label[start] != 0 or img.get_pixel(start % w, start / w).a == 0.0:
			continue
		var id := sizes.size()
		var count := 0
		label[start] = id
		stack.append(start)
		while not stack.is_empty():
			var i: int = stack.pop_back()
			count += 1
			var x := i % w
			var y := i / w
			for n: int in [i - 1 if x > 0 else -1, i + 1 if x < w - 1 else -1, i - w if y > 0 else -1, i + w if y < h - 1 else -1]:
				if n >= 0 and label[n] == 0 and img.get_pixel(n % w, n / w).a > 0.0:
					label[n] = id
					stack.append(n)
		sizes.append(count)
	var largest := 0
	for s in sizes:
		largest = maxi(largest, s)
	for i in w * h:
		if label[i] != 0 and sizes[label[i]] < largest * SPECK_SHARE:
			img.set_pixel(i % w, i / w, Color(0, 0, 0, 0))
