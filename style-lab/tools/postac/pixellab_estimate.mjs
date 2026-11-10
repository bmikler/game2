// PROTOTYP (ticket „Przepis postaci”): Pixellab estimate-skeleton (0,1 gen.) — szkielet 18 stawów sprite'a.
// Zewnętrzne wywołanie płatne: tylko za zgodą człowieka.
//   node tools/postac/pixellab_estimate.mjs <sprite.png> <wynik.json>
import { readFileSync, writeFileSync } from "node:fs";
const [src, out] = process.argv.slice(2);
const env = readFileSync("C:/Users/bartl/.secrets/game2/keys.env", "utf8");
const key = env.match(/PIXELLAB_API_KEY=(.*)/)[1].trim().replace(/^"|"$/g, "");
const res = await fetch("https://api.pixellab.ai/v2/estimate-skeleton", {
  method: "POST", headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
  body: JSON.stringify({ image: { type: "base64", base64: `data:image/png;base64,${readFileSync(src).toString("base64")}` } }),
});
const j = await res.json();
if (!res.ok) { console.error(res.status, JSON.stringify(j).slice(0, 1200)); process.exit(1); }
writeFileSync(out, JSON.stringify({ sprite: src, time: new Date().toISOString(), ...j }, null, 1));
console.log(JSON.stringify(j.usage ?? {}), (j.keypoints ?? []).map((k) => `${k.label} ${(k.x * 80).toFixed(1)},${(k.y * 80).toFixed(1)}`).join(" | "));
