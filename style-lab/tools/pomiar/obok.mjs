// PROTOTYP (ticket 36): wycinki kilku PNG obok siebie (nearest ×k): node obok.mjs wy.png x y w h k a.png b.png …
import { readFileSync, writeFileSync } from "node:fs";
import { decodePng, encodePng } from "./png.mjs";
const [dst, x, y, w, h, k, ...srcs] = process.argv.slice(2).map((v, i) => (i >= 1 && i <= 5 ? Number(v) : v));
const gap = 4, W = srcs.length * (w * k + gap) - gap, H = h * k;
const out = new Uint8Array(W * H * 4).fill(255);
srcs.forEach((s, n) => { const im = decodePng(readFileSync(s));
	for (let j = 0; j < H; j++) for (let i = 0; i < w * k; i++) {
		const sx = x + Math.floor(i / k), sy = y + Math.floor(j / k), si = (sy * im.width + sx) * 4, di = (j * W + n * (w * k + gap) + i) * 4;
		for (let c = 0; c < 4; c++) out[di + c] = im.data[si + c]; } });
writeFileSync(dst, encodePng({ width: W, height: H, data: out }));
