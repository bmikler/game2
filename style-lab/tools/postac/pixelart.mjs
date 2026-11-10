// PROTOTYP (ticket „Przepis postaci”): Pixellab image-to-pixelart, 1 generacja na plik.
// Zewnętrzna generacja: wywoływać tylko za zgodą człowieka (Notes mapy).
//   node tools/postac/pixelart.mjs <in.png> <out.png> [rozmiar_wyj=80] [siła=200]
// Klucz: PIXELLAB_API_KEY z C:\Users\bartl\.secrets\game2\keys.env (nie w repo).
import { readFileSync, writeFileSync, appendFileSync } from "node:fs";
import { dirname, join } from "node:path";

const [inp, out, outSize = "80", strength = "200"] = process.argv.slice(2);
const env = readFileSync("C:/Users/bartl/.secrets/game2/keys.env", "utf8");
const key = env.match(/PIXELLAB_API_KEY=(.*)/)[1].trim().replace(/^"|"$/g, "");
const png = readFileSync(inp);
// Rozmiar wejścia z nagłówka PNG (IHDR).
const w = png.readUInt32BE(16), h = png.readUInt32BE(20);
const body = {
  image: { type: "base64", base64: `data:image/png;base64,${png.toString("base64")}` },
  image_size: { width: w, height: h },
  output_size: { width: Number(outSize), height: Number(outSize) },
  fixer: true,
  init_image_strength: Number(strength),
  seed: 1,
};
const t0 = Date.now();
const res = await fetch("https://api.pixellab.ai/v2/image-to-pixelart", {
  method: "POST",
  headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
  body: JSON.stringify(body),
});
const j = await res.json();
if (!res.ok) { console.error(res.status, JSON.stringify(j).slice(0, 500)); process.exit(1); }
writeFileSync(out, Buffer.from(j.image.base64.replace(/^data:image\/png;base64,/, ""), "base64"));
const secs = Math.round((Date.now() - t0) / 1000);
appendFileSync(join(dirname(out), "log.jsonl"), JSON.stringify({ in: inp, out, w, h, outSize, strength, usage: j.usage, secs }) + "\n");
console.log(out, `${secs}s`, JSON.stringify(j.usage));
