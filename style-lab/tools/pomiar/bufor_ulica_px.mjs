// PROTOTYP (ticket 14): wartości bufora ulicy w pikselach: node bufor_ulica_px.mjs a.bufor szerokosc x,y [x,y ...]
import { readFileSync } from "node:fs";
const [a, w, ...pts] = process.argv.slice(2);
const A = readFileSync(a), width = Number(w);
const half = (i) => { const h = A.readUInt16LE(i); const e = (h >> 10) & 31, m = h & 1023;
  return (e === 31 ? (m ? NaN : Infinity) : e === 0 ? m / 1024 * 2 ** -14 : (1 + m / 1024) * 2 ** (e - 15)) * (h >> 15 ? -1 : 1); };
for (const p of pts) { const [x, y] = p.split(",").map(Number); const i = (y * width + x) * 8;
  console.log(p, [0, 2, 4, 6].map((k) => half(i + k).toFixed(3)).join(" ")); }
