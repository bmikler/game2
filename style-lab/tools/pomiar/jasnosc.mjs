// PROTOTYP (ticket 31): jasność kadru do porównania style-lab z game1.
// node jasnosc.mjs plik.png [nazwa=x,y,w,h ...]
// Bez prostokątów: „dom” = wszystkie piksele jaśniejsze od czerni tła (lum > 6).
// Wypisuje średnią luminancję, medianę, p95 i odsetek pikseli prześwietlonych (> 235) na 0–255.
import { readFileSync } from "node:fs";
import { decodePng } from "./png.mjs";

const [file, ...specs] = process.argv.slice(2);
const image = decodePng(readFileSync(file));
const lum = (i) => 0.2126 * image.data[i] + 0.7152 * image.data[i + 1] + 0.0722 * image.data[i + 2];
const regions = specs.length
  ? specs.map((s) => { const [n, r] = s.split("="); const [x, y, w, h] = r.split(",").map(Number); return { n, x, y, w, h, all: true }; })
  : [{ n: "dom", x: 0, y: 0, w: image.width, h: image.height, all: false }];
for (const r of regions) {
  const v = [];
  for (let y = r.y; y < r.y + r.h; y++) for (let x = r.x; x < r.x + r.w; x++) {
    const l = lum((y * image.width + x) * 4);
    if (r.all || l > 6) v.push(l);
  }
  v.sort((a, b) => a - b);
  const mean = v.reduce((a, b) => a + b, 0) / v.length;
  const q = (p) => v[Math.floor(p * (v.length - 1))];
  const blown = v.filter((l) => l > 235).length / v.length;
  console.log(`${r.n}\tśr ${mean.toFixed(1)}\tmed ${q(0.5).toFixed(0)}\tp95 ${q(0.95).toFixed(0)}\tp99 ${q(0.99).toFixed(0)}\t>235 ${(blown * 100).toFixed(2)}%\tpx ${v.length}`);
}
