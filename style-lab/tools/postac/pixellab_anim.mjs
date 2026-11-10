// PROTOTYP (ticket „Przepis postaci”): animacja naszego sprite'a w Pixellab (zadanie w tle + odpytywanie).
// Zewnętrzna generacja: tylko za zgodą człowieka (co, po co, koszt).
//   node tools/postac/pixellab_anim.mjs <pixminimax|text-v3> <klatka0.png> <katalog_wyj> "<opis ruchu>" [klatki=8] [seed=1] [ostatnia_klatka.png] [prefiks=tryb]
// Klucz: PIXELLAB_API_KEY z C:\Users\bartl\.secrets\game2\keys.env (nie w repo).
// Wynik: <katalog>/<tryb>_<i>.png (klatki), log.jsonl (usage, czas).
import { readFileSync, writeFileSync, appendFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const [mode, framePath, outDir, motion, frames = "8", seed = "1", lastPath = "", prefixArg = ""] = process.argv.slice(2);
const prefix = prefixArg || mode;
const env = readFileSync("C:/Users/bartl/.secrets/game2/keys.env", "utf8");
const key = env.match(/PIXELLAB_API_KEY=(.*)/)[1].trim().replace(/^"|"$/g, "");
const API = "https://api.pixellab.ai/v2";
const auth = { Authorization: `Bearer ${key}`, "Content-Type": "application/json" };
const b64img = (p) => ({ type: "base64", base64: `data:image/png;base64,${readFileSync(p).toString("base64")}` });
const first = b64img(framePath);
// Ostatnia klatka (opcjonalna): ruch generowany między pierwszą a ostatnią, np. ta sama poza = domknięta pętla.
const last = lastPath ? b64img(lastPath) : null;

let endpoint, body;
if (mode === "pixminimax") {
  endpoint = "/animate-pixminimax";
  body = {
    first_frame: first, description: motion, frame_count: Number(frames), seed: Number(seed), no_background: true,
    // Opisy podane wprost, żeby model niczego nie dopisywał (bez enhance_prompt).
    // PIXELLAB_SUBJECT: opis postaci (wygląd i strój); domyślnie detektyw.
    subject_description: process.env.PIXELLAB_SUBJECT || "a middle-aged man with a short grey beard in a dark navy winter jacket, charcoal trousers and brown boots",
    // PIXELLAB_POSE nadpisuje pozę klatki 0 (np. pętla od rozkroku); PIXELLAB_ENHANCE=1 → enhance_prompt (+0,05 gen.).
    initial_pose: process.env.PIXELLAB_POSE || "standing upright in side profile, arms at his sides",
    enhance_prompt: process.env.PIXELLAB_ENHANCE === "1",
    view: process.env.PIXELLAB_VIEW || "side", direction: process.env.PIXELLAB_DIR || "west",
  };
  if (last) body.last_frame = last;
} else if (mode === "text-v3") {
  endpoint = "/animate-with-text-v3";
  body = { first_frame: first, action: motion, frame_count: Number(frames), seed: Number(seed), no_background: true };
  if (last) body.last_frame = last;
} else {
  throw new Error(`nieznany tryb ${mode}`);
}

mkdirSync(outDir, { recursive: true });
const t0 = Date.now();
const res = await fetch(API + endpoint, { method: "POST", headers: auth, body: JSON.stringify(body) });
const job = await res.json();
if (!res.ok) { console.error(res.status, JSON.stringify(job).slice(0, 800)); process.exit(1); }
const id = job.background_job_id;
console.log("zadanie", id, JSON.stringify(job.usage ?? {}));
for (;;) {
  await new Promise((r) => setTimeout(r, 4000));
  const st = await (await fetch(`${API}/background-jobs/${id}`, { headers: auth })).json();
  if (st.status === "failed") { console.error("błąd", JSON.stringify(st).slice(0, 800)); process.exit(1); }
  if (st.status !== "completed") continue;
  const images = st.last_response.images;
  images.forEach((img, i) => {
    const b64 = (img.base64 ?? "").replace(/^data:image\/png;base64,/, "");
    writeFileSync(join(outDir, `${prefix}_${i}.png`), Buffer.from(b64, "base64"));
  });
  const secs = Math.round((Date.now() - t0) / 1000);
  if (st.last_response.enhanced_prompt) console.log("enhanced_prompt:", st.last_response.enhanced_prompt);
  appendFileSync(join(outDir, "log.jsonl"), JSON.stringify({ mode, prefix, last: lastPath || undefined, input: framePath, motion, pose: body.initial_pose, enhance: body.enhance_prompt, enhanced: st.last_response.enhanced_prompt, frames, seed, usage: st.usage ?? job.usage, images: images.length, secs }) + "\n");
  console.log(`${images.length} klatek, ${secs}s`, JSON.stringify(st.usage ?? job.usage ?? {}));
  break;
}
