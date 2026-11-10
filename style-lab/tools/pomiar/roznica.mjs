// PROTOTYP (ticket 33): różnica dwóch zrzutów (a − b), wzmocniona ×k na szarym tle: node roznica.mjs a.png b.png wy.png [k]
import { readFileSync, writeFileSync } from "node:fs";
import { decodePng, encodePng } from "./png.mjs";
const [a, b, dst, k = 6] = process.argv.slice(2).map((v, i) => (i < 3 ? v : Number(v)));
const A = decodePng(readFileSync(a)), B = decodePng(readFileSync(b));
const out = new Uint8Array(A.data.length);
let max = 0;
for (let i = 0; i < A.data.length; i += 4) {
  for (let c = 0; c < 3; c++) {
    const d = A.data[i + c] - B.data[i + c];
    max = Math.max(max, Math.abs(d));
    out[i + c] = Math.max(0, Math.min(255, 128 + d * k));
  }
  out[i + 3] = 255;
}
writeFileSync(dst, encodePng({ width: A.width, height: A.height, data: out }));
console.log("max |a-b| =", max);
