// PROTOTYP (ticket 14): bufor ulicy (RGBA half) jako PNG: node bufor_ulica_png.mjs a.bufor szerokosc wy.png [skala]
import { readFileSync, writeFileSync } from "node:fs";
import { encodePng } from "./png.mjs";
const [a, w, dst, k] = process.argv.slice(2);
const A = readFileSync(a), width = Number(w), bpp = 8, height = A.length / bpp / width, scale = Number(k || 1);
const half = (i) => { const h = A.readUInt16LE(i); const e = (h >> 10) & 31, m = h & 1023;
  return (e === 0 ? m / 1024 * 2 ** -14 : (1 + m / 1024) * 2 ** (e - 15)) * (h >> 15 ? -1 : 1); };
const out = new Uint8Array(width * height * 4);
for (let i = 0; i < width * height; i++) {
  for (let c = 0; c < 3; c++) out[i * 4 + c] = Math.min(255, Math.round(Math.sqrt(Math.max(0, half(i * bpp + c * 2) * scale)) * 255));
  out[i * 4 + 3] = 255;
}
writeFileSync(dst, encodePng({ width, height, data: out }));
