// PROTOTYP (ticket „Przepis postaci”): Pixellab create-image-bitforge: jedna postać z przodu, kąt ustawia
// Pixellab (view), styl z naszego sprite'a (style_image). Zewnętrzna generacja: tylko za zgodą człowieka.
//   node tools/postac/bitforge.mjs <styl.png> <out.png> <low|high> [oblique=0|1] [siła_stylu=60]
// Klucz: PIXELLAB_API_KEY z C:\Users\bartl\.secrets\game2\keys.env (nie w repo).
import { readFileSync, writeFileSync, appendFileSync } from "node:fs";
import { dirname, join } from "node:path";

const [stylePath, out, view, oblique = "0", strength = "60"] = process.argv.slice(2);
const env = readFileSync("C:/Users/bartl/.secrets/game2/keys.env", "utf8");
const key = env.match(/PIXELLAB_API_KEY=(.*)/)[1].trim().replace(/^"|"$/g, "");
const png = readFileSync(stylePath);
const DESCRIPTION = "adult man about 40, realistic proportions 7 heads tall, dark navy wool winter coat to the knees, " +
  "muted brick red scarf, light grey knit sweater at the collar, charcoal grey trousers, brown leather winter boots, " +
  "short dark hair, stubble, standing still, arms at his sides, facing the viewer";
const body = {
  description: DESCRIPTION,
  image_size: { width: 80, height: 80 },
  view: `${view} top-down`,
  direction: "south",
  oblique_projection: oblique === "1",
  no_background: true,
  style_image: { type: "base64", base64: `data:image/png;base64,${png.toString("base64")}` },
  style_strength: Number(strength),
  seed: 1,
};
const t0 = Date.now();
const res = await fetch("https://api.pixellab.ai/v2/create-image-bitforge", {
  method: "POST",
  headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
  body: JSON.stringify(body),
});
const j = await res.json();
if (!res.ok) { console.error(res.status, JSON.stringify(j).slice(0, 600)); process.exit(1); }
writeFileSync(out, Buffer.from(j.image.base64.replace(/^data:image\/png;base64,/, ""), "base64"));
const secs = Math.round((Date.now() - t0) / 1000);
appendFileSync(join(dirname(out), "log.jsonl"), JSON.stringify({ endpoint: "bitforge", style: stylePath, out, view, oblique, strength, usage: j.usage, secs }) + "\n");
console.log(out, `${secs}s`, JSON.stringify(j.usage));
