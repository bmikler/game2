// PROTOTYP (ticket „Przepis postaci”): postać w Pixellab (zakładka Characters) z naszych sprite'ów
// i animacje szablonami na szkielecie. Zewnętrzna generacja: tylko za zgodą człowieka (co, po co, koszt).
//   node tools/postac/pixellab_postac.mjs create <katalog z south/east/north/west.png> "<opis>" [view=high top-down]
//       → import 4 kierunków (nic nie generuje, 0,25 gen.), zapisuje character_id w <katalog>/postac.json
//   node tools/postac/pixellab_postac.mjs animate <katalog> <szablon> <kierunek,kierunek,...>
//       → animacja szablonem (1 gen./kierunek przy ≤96 px), klatki <katalog>/<szablon>_<kierunek>_<i>.png
// Klucz: PIXELLAB_API_KEY z C:\Users\bartl\.secrets\game2\keys.env (nie w repo).
import { readFileSync, writeFileSync, appendFileSync, existsSync } from "node:fs";
import { join } from "node:path";

const [cmd, dir, ...rest] = process.argv.slice(2);
const env = readFileSync("C:/Users/bartl/.secrets/game2/keys.env", "utf8");
const key = env.match(/PIXELLAB_API_KEY=(.*)/)[1].trim().replace(/^"|"$/g, "");
const API = "https://api.pixellab.ai/v2";
const auth = { Authorization: `Bearer ${key}`, "Content-Type": "application/json" };
const img = (p) => ({ type: "base64", base64: `data:image/png;base64,${readFileSync(p).toString("base64")}` });
const log = (o) => appendFileSync(join(dir, "log.jsonl"), JSON.stringify({ time: new Date().toISOString(), ...o }) + "\n");
const strip = (o) => JSON.parse(JSON.stringify(o, (k, v) => (typeof v === "string" && v.length > 300 ? `<${v.length} zn.>` : v)));

async function post(path, body) {
  const res = await fetch(API + path, { method: "POST", headers: auth, body: JSON.stringify(body) });
  const j = await res.json();
  if (!res.ok) { console.error(res.status, JSON.stringify(j).slice(0, 1200)); process.exit(1); }
  return j;
}

async function waitJob(id) {
  for (;;) {
    await new Promise((r) => setTimeout(r, 5000));
    const st = await (await fetch(`${API}/background-jobs/${id}`, { headers: auth })).json();
    if (st.status === "failed") { console.error("błąd", JSON.stringify(strip(st)).slice(0, 1200)); process.exit(1); }
    if (st.status === "completed") return st;
  }
}

const t0 = Date.now();
if (cmd === "create") {
  const [description, view = "high top-down"] = rest;
  const j = await post("/create-character-v3", {
    description, reference_image: img(join(dir, "south.png")), n_directions: 4, view, template_id: "mannequin",
    direction_images: { east: img(join(dir, "east.png")), north: img(join(dir, "north.png")), west: img(join(dir, "west.png")) },
    no_background: true,
  });
  console.log("postać", j.character_id, "zadanie", j.background_job_id, JSON.stringify(j.usage ?? {}));
  writeFileSync(join(dir, "postac.json"), JSON.stringify({ character_id: j.character_id, view }, null, 2));
  const st = j.background_job_id ? await waitJob(j.background_job_id) : j;
  log({ cmd, character_id: j.character_id, view, usage: st.usage ?? j.usage, secs: Math.round((Date.now() - t0) / 1000), job: strip(st) });
  console.log("gotowe", Math.round((Date.now() - t0) / 1000) + "s", JSON.stringify(st.usage ?? j.usage ?? {}));
} else if (cmd === "animate") {
  const [template, dirs] = rest;
  const { character_id } = JSON.parse(readFileSync(join(dir, "postac.json"), "utf8"));
  const directions = dirs.split(",");
  // Trial: jeden kierunek naraz, kolejne dokładane do tej samej animacji (animation_group_id).
  let group;
  const usage = [];
  for (const direction of directions) {
    const body = { character_id, mode: "template", template_animation_id: template, directions: [direction] };
    if (group) body.animation_group_id = group;
    const j = await post("/characters/animations", body);
    group = j.animation_group_id;
    const st = await waitJob(j.background_job_ids[0]);
    usage.push(st.usage);
    const images = st.last_response?.images ?? [];
    images.forEach((im, i) => {
      const b64 = (im.base64 ?? "").replace(/^data:image\/png;base64,/, "");
      if (b64) writeFileSync(join(dir, `${template}_${direction}_${i}.png`), Buffer.from(b64, "base64"));
    });
    console.log(direction, images.length, "klatek", JSON.stringify(st.usage ?? {}));
    if (!images.length) writeFileSync(join(dir, `job_${direction}.json`), JSON.stringify(strip(st), null, 2));
  }
  log({ cmd, template, directions, animation_group_id: group, usage, secs: Math.round((Date.now() - t0) / 1000) });
  console.log("gotowe", Math.round((Date.now() - t0) / 1000) + "s");
} else if (cmd === "zip") {
  const { character_id } = JSON.parse(readFileSync(join(dir, "postac.json"), "utf8"));
  const res = await fetch(`${API}/characters/${character_id}/zip`, { headers: auth });
  if (!res.ok) { console.error(res.status, (await res.text()).slice(0, 600)); process.exit(1); }
  writeFileSync(join(dir, "postac.zip"), Buffer.from(await res.arrayBuffer()));
  console.log("zapisano postac.zip");
} else {
  throw new Error("polecenie: create | animate | zip");
}
