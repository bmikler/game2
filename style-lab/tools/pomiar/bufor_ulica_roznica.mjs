// PROTOTYP (ticket 14): różnica dwóch buforów ulicy (StreetMap, RGBA half = 8 B/px), bez paska postaci.
// node bufor_ulica_roznica.mjs a.bufor b.bufor szerokosc_ulicy szerokosc_bufora
import { readFileSync } from "node:fs";
const [a, b, ws, wb] = process.argv.slice(2);
const A = readFileSync(a), B = readFileSync(b);
const street = Number(ws), width = Number(wb), bpp = 8, height = A.length / bpp / width;
let count = 0, x0 = 1e9, y0 = 1e9, x1 = -1, y1 = -1, maxd = 0;
const half = (buf, i) => { const h = buf.readUInt16LE(i); const e = (h >> 10) & 31, m = h & 1023;
  return (e === 0 ? m / 1024 * 2 ** -14 : (1 + m / 1024) * 2 ** (e - 15)) * (h >> 15 ? -1 : 1); };
for (let y = 0; y < height; y++) for (let x = 0; x < street; x++) {
  const i = (y * width + x) * bpp;
  let differs = false;
  for (let k = 0; k < 6; k += 2) { const d = Math.abs(half(A, i + k) - half(B, i + k)); if (d > 0) differs = true; maxd = Math.max(maxd, d); }
  if (differs) { count++; x0 = Math.min(x0, x); y0 = Math.min(y0, y); x1 = Math.max(x1, x); y1 = Math.max(y1, y); }
}
console.log(`${street}x${height}: rozne px ${count}` + (count ? `, obwiednia x ${x0}-${x1}, y ${y0}-${y1}, max roznica ${maxd.toFixed(4)}` : ""));
