// PROTOTYP (ticket 31): wycinek PNG powiększony nearest: node kadr.mjs we.png wy.png x y w h [skala]
import { readFileSync, writeFileSync } from "node:fs";
import { decodePng, encodePng } from "./png.mjs";
const [src, dst, x, y, w, h, k = 3] = process.argv.slice(2).map((v, i) => (i < 2 ? v : Number(v)));
const im = decodePng(readFileSync(src));
const out = new Uint8Array(w * k * h * k * 4);
for (let j = 0; j < h * k; j++) for (let i = 0; i < w * k; i++) {
  const s = ((y + Math.floor(j / k)) * im.width + x + Math.floor(i / k)) * 4, d = (j * w * k + i) * 4;
  for (let c = 0; c < 4; c++) out[d + c] = im.data[s + c];
}
writeFileSync(dst, encodePng({ width: w * k, height: h * k, data: out }));
