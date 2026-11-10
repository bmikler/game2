// PROTOTYP (ticket 31): jasność postaci i podłogi obok niej w zrzucie Poligonu Dom.
// node postac.mjs plik.png x_m d_m  (miejsce stóp jak --at; dom szukany po lewym brzegu i górze tylnej ściany)
import { readFileSync } from "node:fs";
import { decodePng } from "./png.mjs";
const [file, xm, dm] = process.argv.slice(2);
const im = decodePng(readFileSync(file));
const lum = (x, y) => { const i = (y * im.width + x) * 4; return 0.299 * im.data[i] + 0.587 * im.data[i + 1] + 0.114 * im.data[i + 2]; };
let x0 = 0; for (let x = 0; x < im.width; x++) if (lum(x, 300) > 30) { x0 = x; break; }
let y0 = 0; for (let y = 0; y < im.height; y++) if (lum(x0 + 20, y) > 30) { y0 = y; break; }
const fx = Math.round(x0 + Number(xm) * 40), fy = Math.round(y0 + 88 + Number(dm) * 24);
const mean = (x, y, w, h) => { let s = 0; for (let j = 0; j < h; j++) for (let i = 0; i < w; i++) s += lum(x + i, y + j); return (s / (w * h)).toFixed(1); };
console.log(`${file}\tstopy ${fx},${fy}\tgłowa ${mean(fx - 6, fy - 70, 12, 14)}\ttułów ${mean(fx - 10, fy - 55, 20, 25)}\tnogi ${mean(fx - 8, fy - 28, 16, 24)}\tpodłoga obok ${mean(fx + 18, fy - 10, 20, 10)}`);
