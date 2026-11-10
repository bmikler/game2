// PROTOTYP (ticket „Przepis postaci”): zmiana kamery gotowego konceptu lokalnie w ComfyUI (0 zł):
// Qwen-Image-Edit-2511 (GGUF Q4_K_M) + LoRA Multiple Angles (fal, Apache 2.0) + Lightning 4 kroki.
// Wzór workflow: comfyui-workflow-multiple-angles.json z repo LoRA.
//   node tools/postac/qwen_kat.mjs <wejście.png> <wyjście_prefiks> "<sks> front view elevated shot full shot" [--seeds 1] [--angles 0.9]
//       [--pose <manekin.png>] [--seed0 9000]
// --pose: druga referencja (image2), np. klatka chodu z tools/blender/postac_chod.py; prompt mówi, co z niej wziąć.
// Wysokości kamery w LoRA: eye-level 0°, elevated shot 30°, high-angle shot 60°.
import { readFileSync, writeFileSync, appendFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";

const COMFY = "http://127.0.0.1:8188";
const [input, outPrefix, prompt] = process.argv.slice(2);
const arg = (name, def) => { const i = process.argv.indexOf(`--${name}`); return i > 0 ? process.argv[i + 1] : def; };
const SEEDS = Number(arg("seeds", "1"));
const ANGLES = Number(arg("angles", "0.9"));
const POSE = arg("pose", "");
const SEED0 = Number(arg("seed0", "9000"));

async function upload(path) {
  const form = new FormData();
  form.append("image", new Blob([readFileSync(path)], { type: "image/png" }), `qwen_${basename(path)}`);
  form.append("overwrite", "true");
  const res = await fetch(`${COMFY}/upload/image`, { method: "POST", body: form });
  if (!res.ok) throw new Error(`upload ${path}: ${res.status}`);
  return (await res.json()).name;
}

function graph(image, seed, pose) {
  const g = {
    unet: { class_type: "UnetLoaderGGUF", inputs: { unet_name: "qwen-image-edit-2511-Q4_K_M.gguf" } },
    fast: { class_type: "LoraLoaderModelOnly", inputs: { model: ["unet", 0], lora_name: "Qwen-Image-Edit-2511-Lightning-4steps-V1.0-bf16.safetensors", strength_model: 1.0 } },
    angles: { class_type: "LoraLoaderModelOnly", inputs: { model: ["fast", 0], lora_name: "qwen-image-edit-2511-multiple-angles-lora.safetensors", strength_model: ANGLES } },
    shift: { class_type: "ModelSamplingAuraFlow", inputs: { model: ["angles", 0], shift: 3.1 } },
    norm: { class_type: "CFGNorm", inputs: { model: ["shift", 0], strength: 1.0 } },
    clip: { class_type: "CLIPLoader", inputs: { clip_name: "qwen_2.5_vl_7b_fp8_scaled.safetensors", type: "qwen_image", device: "default" } },
    vae: { class_type: "VAELoader", inputs: { vae_name: "qwen_image_vae.safetensors" } },
    load: { class_type: "LoadImage", inputs: { image } },
    scale: { class_type: "FluxKontextImageScale", inputs: { image: ["load", 0] } },
    pos0: { class_type: "TextEncodeQwenImageEditPlus", inputs: { clip: ["clip", 0], prompt, vae: ["vae", 0], image1: ["scale", 0] } },
    neg0: { class_type: "TextEncodeQwenImageEditPlus", inputs: { clip: ["clip", 0], prompt: "", vae: ["vae", 0], image1: ["scale", 0] } },
    pos: { class_type: "FluxKontextMultiReferenceLatentMethod", inputs: { conditioning: ["pos0", 0], reference_latents_method: "index_timestep_zero" } },
    neg: { class_type: "FluxKontextMultiReferenceLatentMethod", inputs: { conditioning: ["neg0", 0], reference_latents_method: "index_timestep_zero" } },
    lat: { class_type: "VAEEncode", inputs: { pixels: ["scale", 0], vae: ["vae", 0] } },
    sample: { class_type: "KSampler", inputs: { model: ["norm", 0], positive: ["pos", 0], negative: ["neg", 0], latent_image: ["lat", 0], seed, steps: 4, cfg: 1.0, sampler_name: "euler", scheduler: "simple", denoise: 1.0 } },
    decode: { class_type: "VAEDecode", inputs: { samples: ["sample", 0], vae: ["vae", 0] } },
    save: { class_type: "SaveImage", inputs: { images: ["decode", 0], filename_prefix: "qwen_kat" } },
  };
  if (pose) {
    g.load2 = { class_type: "LoadImage", inputs: { image: pose } };
    g.scale2 = { class_type: "FluxKontextImageScale", inputs: { image: ["load2", 0] } };
    g.pos0.inputs.image2 = ["scale2", 0];
    g.neg0.inputs.image2 = ["scale2", 0];
  }
  return g;
}

async function run(p) {
  const res = await fetch(`${COMFY}/prompt`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ prompt: p }) });
  const body = await res.json();
  if (!body.prompt_id) throw new Error(JSON.stringify(body).slice(0, 1500));
  for (;;) {
    await new Promise((r) => setTimeout(r, 2000));
    const entry = (await (await fetch(`${COMFY}/history/${body.prompt_id}`)).json())[body.prompt_id];
    if (!entry) continue;
    if (entry.status?.status_str === "error") throw new Error(JSON.stringify(entry.status.messages).slice(0, 1500));
    const images = entry.outputs?.save?.images;
    if (images) return images[0];
  }
}

const name = await upload(input);
const poseName = POSE ? await upload(POSE) : "";
for (let s = 0; s < SEEDS; s++) {
  const seed = SEED0 + s;
  const t0 = Date.now();
  const img = await run(graph(name, seed, poseName));
  const data = await (await fetch(`${COMFY}/view?filename=${encodeURIComponent(img.filename)}&subfolder=${encodeURIComponent(img.subfolder)}&type=${img.type}`)).arrayBuffer();
  const file = `${outPrefix}_s${seed}.png`;
  writeFileSync(file, Buffer.from(data));
  const secs = Math.round((Date.now() - t0) / 1000);
  appendFileSync(join(dirname(file), "prompts.jsonl"), JSON.stringify({ file, input, pose: POSE || undefined, prompt, seed, angles: ANGLES, secs }) + "\n");
  console.log(file, `${secs}s`);
}
