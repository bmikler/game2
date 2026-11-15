# PROTOTYP (ticket silnika 02): mebel z ComfyUI do gry, jeden skrypt dla wszystkich mebli.
# Obraz z generatora (płótno prowadnic przeskalowane przez ComfyUI) wraca na płótno prowadnic,
# przechodzi sito (podstawa z Blendera pokryta, dół na linii podłogi; dodatki jak narzuta, obrus czy lampka
# mogą wychodzić poza nią), pikselizację do siatki gry (40 px/m) z alfą z generatora i paletę KOLORY.
# Uruchomienie z style-lab/:
#   "$G" --headless --path . --script tools/meble/mebel_piksele.gd -- <katalog prowadnic> <katalog wyjścia> <obraz.png>...
# Na każdy obraz: <nazwa>.png (sprite gry), <nazwa>_duzy.png (płótno prowadnic z alfą generatora),
# <nazwa>_kontrola.png (obraz, kontur Blendera czerwony, kontur generatora turkusowy) i linia JSON
# w <katalog wyjścia>/sito.jsonl. Testy: tools/meble/test_mebel_piksele.gd.
extends SceneTree

## Sito: najmniejsze pokrycie podstawy z Blendera, największy nadmiar (dodatki, ułamek podstawy)
## i odchyłka dolnej krawędzi od linii podłogi (10 px prowadnic = 1 px gry).
const MIN_POKRYCIE := 0.95
const MAX_NADMIAR := 0.3
const MAX_SHIFT_PX := 10
## Kolory sprite'a: jak klatki chodu z Pixellab (32–46), na które przenosimy też stanie postaci.
const KOLORY := 40
## Background tolerance (max channel distance to the corner colour), as in the Przepis postaci chain (crop_ref 0.08).
const BG_TOL := 0.08
## Kroki k-średnich po podziale median cut w paleta().
const KMEANS_STEPS := 8


## Agreement of the generator's silhouette with the Blender mask (same canvas size). The Blender
## model is the bare base; the painted object may add things beyond it (blanket, tablecloth, lamp).
## pokrycie: share of the base covered; nadmiar: generator pixels outside the base / base area;
## dol: generator bottom row minus Blender bottom row (the floor line), negative = higher.
class Sito:
	var iou: float = 0.0
	var pokrycie: float = 0.0
	var nadmiar: float = 0.0
	var dol: int = 0


func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var guide_dir: String = a[0]
	var out_dir: String = a[1]
	DirAccess.make_dir_recursive_absolute(out_dir)
	var mask := Image.load_from_file(guide_dir.path_join("maska.png"))
	var floor_row := _bottom_row(mask)
	var log := FileAccess.open(out_dir.path_join("sito.jsonl"), FileAccess.WRITE)
	var info: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(guide_dir.path_join("bryly.json")))
	var plotno: Array = info.plotno_gra
	var w: float = plotno[0]
	var h: float = plotno[1]
	var game_size := Vector2i(roundi(w), roundi(h))
	for path: String in a.slice(2):
		var img := Image.load_from_file(path)
		img.convert(Image.FORMAT_RGBA8)
		img.resize(mask.get_width(), mask.get_height(), Image.INTERPOLATE_LANCZOS)
		var gen_mask := maska_generatora(img)
		# Poniżej linii podłogi (z zapasem 1 px gry) nie ma mebla, tylko cień generatora.
		gen_mask.fill_rect(Rect2i(0, floor_row + MAX_SHIFT_PX + 1, gen_mask.get_width(), gen_mask.get_height()), Color.BLACK)
		var r := sito(gen_mask, mask)
		var ok := zgodny(r)
		var name := path.get_file().get_basename()
		paleta(piksele(img, gen_mask, game_size), KOLORY).save_png(out_dir.path_join(name + ".png"))
		_with_alpha(img, gen_mask).save_png(out_dir.path_join(name + "_duzy.png"))
		_overlay(img, mask, gen_mask).save_png(out_dir.path_join(name + "_kontrola.png"))
		var line := JSON.stringify({ "obraz": path, "nazwa": name, "iou": snappedf(r.iou, 0.001),
				"pokrycie": snappedf(r.pokrycie, 0.001), "nadmiar": snappedf(r.nadmiar, 0.001), "dol": r.dol, "zgodny": ok })
		log.store_line(line)
		print(line)
	quit()


static func sito(gen: Image, blender: Image) -> Sito:
	var both := 0
	var only_gen := 0
	var base := 0
	for y in gen.get_height():
		for x in gen.get_width():
			var g := _inside(gen, x, y)
			var b := _inside(blender, x, y)
			if b:
				base += 1
				if g:
					both += 1
			elif g:
				only_gen += 1
	var r := Sito.new()
	r.iou = float(both) / maxf(1.0, float(base + only_gen))
	r.pokrycie = float(both) / maxf(1.0, float(base))
	r.nadmiar = float(only_gen) / maxf(1.0, float(base))
	r.dol = _bottom_row(gen) - _bottom_row(blender)
	return r


static func zgodny(r: Sito) -> bool:
	return r.pokrycie >= MIN_POKRYCIE and r.nadmiar <= MAX_NADMIAR and absi(r.dol) <= MAX_SHIFT_PX


static func _bottom_row(mask: Image) -> int:
	for y in range(mask.get_height() - 1, -1, -1):
		for x in mask.get_width():
			if _inside(mask, x, y):
				return y
	return -1


## A mask pixel is inside when it is bright (white mask) and opaque.
static func _inside(mask: Image, x: int, y: int) -> bool:
	var c := mask.get_pixel(x, y)
	return c.v > 0.5 and c.a > 0.5


## Generator silhouette: background flooded from the canvas edges (colour of the top-left corner
## within BG_TOL), everything else inside. White = object.
static func maska_generatora(img: Image) -> Image:
	var w := img.get_width()
	var h := img.get_height()
	var bg := img.get_pixel(0, 0)
	var outside := PackedByteArray()
	outside.resize(w * h)
	var stack := PackedInt32Array()
	for x in w:
		stack.append(x)
		stack.append((h - 1) * w + x)
	for y in h:
		stack.append(y * w)
		stack.append(y * w + w - 1)
	while not stack.is_empty():
		var i: int = stack[stack.size() - 1]
		stack.resize(stack.size() - 1)
		if outside[i]:
			continue
		var c := img.get_pixel(i % w, i / w)
		if maxf(maxf(absf(c.r - bg.r), absf(c.g - bg.g)), absf(c.b - bg.b)) > BG_TOL:
			continue
		outside[i] = 1
		var x := i % w
		if x > 0:
			stack.append(i - 1)
		if x < w - 1:
			stack.append(i + 1)
		if i >= w:
			stack.append(i - w)
		if i < (h - 1) * w:
			stack.append(i + w)
	var mask := Image.create(w, h, false, Image.FORMAT_L8)
	for i in w * h:
		if not outside[i]:
			mask.set_pixel(i % w, i / w, Color.WHITE)
	return mask


## Game sprite, the same chain as Przepis postaci (Lanczos down, hard alpha): the canvas is shrunk
## exactly to the game grid (the generator canvas is a multiple of it, aligned to the anchor). Alpha:
## share of object pixels in each game pixel > 0.5. Before shrinking, pixels outside the object take
## the colour of the nearest object pixel, so the generator background never bleeds into the edge.
static func piksele(img: Image, mask: Image, size: Vector2i) -> Image:
	var src := img.duplicate() as Image
	src.convert(Image.FORMAT_RGBA8)
	_bleed(src, mask)
	src.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
	var k := mask.get_width() / size.x
	for y in size.y:
		for x in size.x:
			var inside := 0
			for yy in k:
				for xx in k:
					if _inside(mask, x * k + xx, y * k + yy):
						inside += 1
			var c := src.get_pixel(x, y)
			c.a = 1.0 if inside * 2 > k * k else 0.0
			src.set_pixel(x, y, c)
	return src


## Fills pixels outside the mask with the nearest object colour: along the row, then (rows without
## any object pixel) along the column.
static func _bleed(img: Image, mask: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var filled := PackedByteArray()
	filled.resize(w * h)
	for y in h:
		var xs := PackedInt32Array()
		for x in w:
			if _inside(mask, x, y):
				xs.append(x)
				filled[y * w + x] = 1
		if xs.is_empty():
			continue
		var k := 0
		for x in w:
			while k + 1 < xs.size() and absi(xs[k + 1] - x) <= absi(xs[k] - x):
				k += 1
			if not filled[y * w + x]:
				img.set_pixel(x, y, img.get_pixel(xs[k], y))
		for x in w:
			filled[y * w + x] = 1
	for x in w:
		var ys := PackedInt32Array()
		for y in h:
			if filled[y * w + x]:
				ys.append(y)
		if ys.is_empty() or ys.size() == h:
			continue
		var k := 0
		for y in h:
			while k + 1 < ys.size() and absi(ys[k + 1] - y) <= absi(ys[k] - y):
				k += 1
			if not filled[y * w + x]:
				img.set_pixel(x, y, img.get_pixel(x, ys[k]))


static func _with_alpha(img: Image, mask: Image) -> Image:
	var out := img.duplicate() as Image
	for y in out.get_height():
		for x in out.get_width():
			if not _inside(mask, x, y):
				out.set_pixel(x, y, Color(0, 0, 0, 0))
	return out


## Generator image with both outlines: Blender red, generator cyan (2 px).
static func _overlay(img: Image, mask: Image, gen_mask: Image) -> Image:
	var out := img.duplicate() as Image
	for y in range(2, out.get_height() - 2):
		for x in range(2, out.get_width() - 2):
			if _edge(gen_mask, x, y):
				out.set_pixel(x, y, Color(0.1, 0.9, 0.9))
			if _edge(mask, x, y):
				out.set_pixel(x, y, Color(1.0, 0.15, 0.15))
	return out


static func _edge(mask: Image, x: int, y: int) -> bool:
	var inside := _inside(mask, x, y)
	for d: Vector2i in [Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2)]:
		if _inside(mask, x + d.x, y + d.y) != inside:
			return true
	return false


## Limited palette like the Pixellab animations (their frames have 32–46 colours; characters stand
## on the palette of their walk, Przepis postaci): median cut in Lab, refined by a few k-means steps;
## each opaque pixel takes the mean colour of its cluster. Alpha unchanged.
static func paleta(img: Image, n: int) -> Image:
	var out := img.duplicate() as Image
	out.convert(Image.FORMAT_RGBA8)
	var idx := PackedInt32Array()
	var lab := PackedVector3Array()
	var seen := {}
	for y in out.get_height():
		for x in out.get_width():
			var c := out.get_pixel(x, y)
			if c.a > 0.5:
				idx.append(y * out.get_width() + x)
				lab.append(_lab(c))
				seen[c.to_rgba32()] = true
	if seen.size() <= n:
		return out
	var centres := _median_cut(lab, n)
	var member := PackedInt32Array()
	member.resize(lab.size())
	for _step in KMEANS_STEPS:
		for i in lab.size():
			member[i] = _nearest(centres, lab[i])
		var sums := PackedVector3Array()
		sums.resize(centres.size())
		var counts := PackedInt32Array()
		counts.resize(centres.size())
		for i in lab.size():
			sums[member[i]] += lab[i]
			counts[member[i]] += 1
		for k in centres.size():
			if counts[k] > 0:
				centres[k] = sums[k] / float(counts[k])
	# Output colour: mean RGB of the cluster's pixels (no Lab → RGB needed).
	var rgb := PackedVector3Array()
	rgb.resize(centres.size())
	var counts := PackedInt32Array()
	counts.resize(centres.size())
	for i in lab.size():
		var c := out.get_pixel(idx[i] % out.get_width(), idx[i] / out.get_width())
		rgb[member[i]] += Vector3(c.r, c.g, c.b)
		counts[member[i]] += 1
	for i in lab.size():
		var k := member[i]
		var m := rgb[k] / float(counts[k])
		out.set_pixel(idx[i] % out.get_width(), idx[i] / out.get_width(), Color(m.x, m.y, m.z, 1.0))
	return out


## Splits the box with the widest Lab range × pixel count at the median of that axis, n times.
static func _median_cut(lab: PackedVector3Array, n: int) -> PackedVector3Array:
	var boxes: Array[PackedVector3Array] = [lab]
	while boxes.size() < n:
		var best := -1
		var best_score := 0.0
		var best_axis := 0
		for b in boxes.size():
			if boxes[b].size() < 2:
				continue
			var lo := boxes[b][0]
			var hi := boxes[b][0]
			for p in boxes[b]:
				lo = lo.min(p)
				hi = hi.max(p)
			var span := hi - lo
			var axis := span.max_axis_index()
			var score := span[axis] * float(boxes[b].size())
			if score > best_score:
				best = b
				best_score = score
				best_axis = axis
		if best < 0:
			break
		var pts: Array[Vector3] = []
		pts.assign(boxes[best])
		var axis_i := best_axis
		pts.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a[axis_i] < b[axis_i])
		var half := pts.size() / 2
		boxes[best] = PackedVector3Array(pts.slice(0, half))
		boxes.append(PackedVector3Array(pts.slice(half)))
	var centres := PackedVector3Array()
	for box in boxes:
		var sum := Vector3.ZERO
		for p in box:
			sum += p
		centres.append(sum / float(box.size()))
	return centres


static func _nearest(centres: PackedVector3Array, p: Vector3) -> int:
	var best := 0
	var best_d := INF
	for k in centres.size():
		var d := centres[k].distance_squared_to(p)
		if d < best_d:
			best_d = d
			best = k
	return best


## sRGB colour to CIE Lab (D65), as tools/postac/paleta_z_klatek.gd.
static func _lab(c: Color) -> Vector3:
	var r := _lin(c.r)
	var g := _lin(c.g)
	var b := _lin(c.b)
	var x := (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
	var y := 0.2126 * r + 0.7152 * g + 0.0722 * b
	var z := (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
	return Vector3(116.0 * _f(y) - 16.0, 500.0 * (_f(x) - _f(y)), 200.0 * (_f(y) - _f(z)))


static func _lin(v: float) -> float:
	return v / 12.92 if v <= 0.04045 else pow((v + 0.055) / 1.055, 2.4)


static func _f(t: float) -> float:
	return pow(t, 1.0 / 3.0) if t > 0.008856 else 7.787 * t + 16.0 / 116.0
