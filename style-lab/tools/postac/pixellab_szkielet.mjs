// PROTOTYP (ticket „Przepis postaci”): Pixellab animate-with-skeleton-v3 na naszym sprite'cie
// ze szkieletami z tools/blender/szkielet_chodu.py. Zewnętrzna generacja: tylko za zgodą człowieka.
//   node tools/postac/pixellab_szkielet.mjs <katalog z szkielet.json> <nazwa chodu, np. 02_01> "<opis wyglądu>"
//       [--direction west] [--view "high top-down"] [--seed 0]
// Koszt wg API: 8 klatek = 3 gen., 15 klatek = 4. Klatki: <katalog>/v3_<chód>_<i>.png, log w log.jsonl.
import { readFileSync, writeFileSync, appendFileSync } from "node:fs";
import { join } from "node:path";

const argv = process.argv.slice(2);
const opt = (k, d) => { const i = argv.indexOf(`--${k}`); return i >= 0 ? argv[i + 1] : d; };
const [dir, walk, description] = argv;
const env = readFileSync("C:/Users/bartl/.secrets/game2/keys.env", "utf8");
const key = env.match(/PIXELLAB_API_KEY=(.*)/)[1].trim().replace(/^"|"$/g, "");
const API = "https://api.pixellab.ai/v2";
const auth = { Authorization: `Bearer ${key}`, "Content-Type": "application/json" };
const sk = JSON.parse(readFileSync(join(dir, "szkielet.json"), "utf8"));
const keypoints = sk.chody[walk]?.keypoints;
if (!keypoints) throw new Error(`brak chodu ${walk}; są: ${Object.keys(sk.chody).join(", ")}`);
const strip = (o) => JSON.parse(JSON.stringify(o, (k, v) => (typeof v === "string" && v.length > 300 ? `<${v.length} zn.>` : v)));

const body = {
  description, action: "walk", direction: opt("direction", "west"), view: opt("view", "high top-down"),
  first_frame: { type: "base64", base64: `data:image/png;base64,${readFileSync(sk.sprite).toString("base64")}` },
  first_frame_keypoints: sk.first_frame_keypoints, keypoints, template_id: "mannequin",
  seed: Number(opt("seed", "0")), no_background: true,
};
const t0 = Date.now();
const res = await fetch(`${API}/animate-with-skeleton-v3`, { method: "POST", headers: auth, body: JSON.stringify(body) });
const j = await res.json();
if (!res.ok) { console.error(res.status, JSON.stringify(j).slice(0, 1500)); process.exit(1); }
console.log("zadanie", j.background_job_id);
let st;
for (;;) {
  await new Promise((r) => setTimeout(r, 8000));
  st = await (await fetch(`${API}/background-jobs/${j.background_job_id}`, { headers: auth })).json();
  if (st.status === "failed") { console.error("błąd", JSON.stringify(strip(st)).slice(0, 1500)); break; }
  if (st.status === "completed") break;
}
const images = st.last_response?.images ?? [];
images.forEach((im, i) => {
  const b64 = (im.base64 ?? "").replace(/^data:image\/png;base64,/, "");
  if (b64) writeFileSync(join(dir, `v3_${walk}_${i}.png`), Buffer.from(b64, "base64"));
});
const secs = Math.round((Date.now() - t0) / 1000);
appendFileSync(join(dir, "log.jsonl"), JSON.stringify({ time: new Date().toISOString(), walk, description,
  direction: body.direction, view: body.view, seed: body.seed, frames: images.length, usage: st.usage, secs,
  status: st.status }) + "\n");
console.log(images.length, "klatek", secs + "s", JSON.stringify(st.usage ?? {}));
