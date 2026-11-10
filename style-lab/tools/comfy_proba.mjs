// PROTOTYP (ticket „Rzut, skala i rozdzielczość”): lokalna próba w ComfyUI, czy SDXL + ControlNet
// depth + LoRA pixel-art-xl trzyma rzut gry z prowadnic Blendera (tools/blender/zestaw_testowy.py
// --canvas 1024). Generacja lokalna: bez kosztów i bez zgody na zewnętrzną platformę.
//   node tools/comfy_proba.mjs [--in shots/zestaw_060] [--out proby/comfy_060] [--seeds 2]
import { readFileSync, writeFileSync, mkdirSync, appendFileSync } from "node:fs";
import { join, basename } from "node:path";

const COMFY = "http://127.0.0.1:8188";
const arg = (name, def) => { const i = process.argv.indexOf(`--${name}`); return i > 0 ? process.argv[i + 1] : def; };
const IN = arg("in", "shots/zestaw_060");
const OUT = arg("out", "proby/comfy_060");
const SEEDS = Number(arg("seeds", "2"));
const STYLE = "pixel art, game asset, single object centered, plain black background, three-quarter front view from slightly above, muted cold winter palette, noir, clean outlines";
const NEGATIVE = "blurry, photo, 3d render, text, watermark, frame, chibi, cartoon, cute, isometric, multiple objects, cropped";
const ITEMS = {
  szescian: "a wooden crate, 1 metre cube",
  lada: "a long wooden shop counter with drawers",
  manekin_przod: "full body adult man in a dark winter coat and scarf, standing, facing the viewer, realistic proportions",
  manekin_bok: "full body adult man in a dark winter coat and scarf, standing, side view facing right, realistic proportions",
  manekin_tyl: "full body adult man in a dark winter coat and scarf, standing, seen from behind, realistic proportions",
};

async function upload(path) {
  const form = new FormData();
  form.append("image", new Blob([readFileSync(path)], { type: "image/png" }), basename(path));
  form.append("overwrite", "true");
  const res = await fetch(`${COMFY}/upload/image`, { method: "POST", body: form });
  if (!res.ok) throw new Error(`upload ${path}: ${res.status}`);
  return (await res.json()).name;
}

function graph(depthName, text, seed, prefix) {
  return {
    1: { class_type: "CheckpointLoaderSimple", inputs: { ckpt_name: "sd_xl_base_1.0.safetensors" } },
    2: { class_type: "LoraLoader", inputs: { model: ["1", 0], clip: ["1", 1], lora_name: "pixel-art-xl.safetensors", strength_model: 1.0, strength_clip: 1.0 } },
    3: { class_type: "VAELoader", inputs: { vae_name: "sdxl_vae_fp16_fix.safetensors" } },
    4: { class_type: "CLIPTextEncode", inputs: { clip: ["2", 1], text: `${STYLE}, ${text}` } },
    5: { class_type: "CLIPTextEncode", inputs: { clip: ["2", 1], text: NEGATIVE } },
    6: { class_type: "LoadImage", inputs: { image: depthName } },
    7: { class_type: "ControlNetLoader", inputs: { control_net_name: "controlnet-depth-sdxl-1.0.fp16.safetensors" } },
    8: { class_type: "ControlNetApplyAdvanced", inputs: { positive: ["4", 0], negative: ["5", 0], control_net: ["7", 0], image: ["6", 0], strength: 0.85, start_percent: 0.0, end_percent: 0.8 } },
    9: { class_type: "EmptyLatentImage", inputs: { width: 1024, height: 1024, batch_size: 1 } },
    10: { class_type: "KSampler", inputs: { model: ["2", 0], positive: ["8", 0], negative: ["8", 1], latent_image: ["9", 0], seed, steps: 25, cfg: 6.0, sampler_name: "dpmpp_2m", scheduler: "karras", denoise: 1.0 } },
    11: { class_type: "VAEDecode", inputs: { samples: ["10", 0], vae: ["3", 0] } },
    12: { class_type: "SaveImage", inputs: { images: ["11", 0], filename_prefix: prefix } },
  };
}

async function run(prompt) {
  const res = await fetch(`${COMFY}/prompt`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ prompt }) });
  const { prompt_id, node_errors } = await res.json();
  if (!prompt_id) throw new Error(JSON.stringify(node_errors));
  for (;;) {
    await new Promise((r) => setTimeout(r, 2000));
    const hist = await (await fetch(`${COMFY}/history/${prompt_id}`)).json();
    const entry = hist[prompt_id];
    if (!entry) continue;
    if (entry.status?.status_str === "error") throw new Error(JSON.stringify(entry.status.messages).slice(0, 800));
    const images = entry.outputs?.["12"]?.images;
    if (images) return images[0];
  }
}

mkdirSync(OUT, { recursive: true });
for (const [name, text] of Object.entries(ITEMS)) {
  const depth = await upload(join(IN, `${name}_depth.png`));
  for (let s = 0; s < SEEDS; s++) {
    const seed = 1000 + s;
    const t0 = Date.now();
    const img = await run(graph(depth, text, seed, `proba_${name}`));
    const data = await (await fetch(`${COMFY}/view?filename=${encodeURIComponent(img.filename)}&subfolder=${encodeURIComponent(img.subfolder)}&type=${img.type}`)).arrayBuffer();
    const file = join(OUT, `${name}_s${seed}.png`);
    writeFileSync(file, Buffer.from(data));
    const secs = Math.round((Date.now() - t0) / 1000);
    appendFileSync(join(OUT, "prompts.jsonl"), JSON.stringify({ file, model: "sd_xl_base_1.0 + controlnet-depth-sdxl-1.0 + pixel-art-xl", prompt: `${STYLE}, ${text}`, negative: NEGATIVE, seed, secs }) + "\n");
    console.log(file, `${secs}s`);
  }
}
