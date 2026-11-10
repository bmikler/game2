// PROTOTYP (ticket 36): różnica dwóch surowych buforów światła (SunMap.dump_buffer, RGBH = 6 B/px):
// node bufor_roznica.mjs a.bufor b.bufor szerokosc [wy.png]
// Wypisuje liczbę różnych pikseli i ich obwiednię; z wy.png zapisuje mapę różnic (biały: różne).
import { readFileSync, writeFileSync } from "node:fs";
import { encodePng } from "./png.mjs";
const [a, b, w, dst] = process.argv.slice(2);
const A = readFileSync(a), B = readFileSync(b);
const width = Number(w), bpp = 6, height = A.length / bpp / width;
const out = new Uint8Array(width * height * 4);
let count = 0, x0 = 1e9, y0 = 1e9, x1 = -1, y1 = -1;
for (let i = 0; i < width * height; i++) {
  let differs = false;
  for (let k = 0; k < 6; k++) if (A[i * bpp + k] !== B[i * bpp + k]) differs = true;
  const x = i % width, y = Math.floor(i / width);
  const v = differs ? 255 : 40;
  out.set([v, v, v, 255], i * 4);
  if (differs) { count++; x0 = Math.min(x0, x); y0 = Math.min(y0, y); x1 = Math.max(x1, x); y1 = Math.max(y1, y); }
}
console.log(`${width}x${height}: rozne px ${count}` + (count ? `, obwiednia x ${x0}-${x1}, y ${y0}-${y1}` : ""));
if (dst) writeFileSync(dst, encodePng({ width, height, data: out }));
