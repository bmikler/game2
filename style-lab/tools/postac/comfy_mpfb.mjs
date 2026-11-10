// PROTOTYP (ticket „Przepis postaci”): ilustracja postaci z renderu MPFB (tools/blender/postac_mpfb.py),
// tak żeby generator trzymał kąt rzutu. Lokalnie w ComfyUI (0 zł):
//   depth: SDXL + ControlNet depth z postac_przod_depth.png (geometria piksel po pikselu)
//   img2img: FLUX.2 klein startuje od postac_przod_tlo.png z odszumianiem < 1 (geometria z renderu)
//   node tools/postac/comfy_mpfb.mjs <depth|img2img> <kąt: 036|060|070> [--seeds 2] [--denoise 0.7] [--cn 0.9]
import { readFileSync, writeFileSync, mkdirSync, appendFileSync } from "node:fs";
import { join, basename } from "node:path";

const COMFY = "http://127.0.0.1:8188";
const [mode, angle] = process.argv.slice(2);
const arg = (name, def) => { const i = process.argv.indexOf(`--${name}`); return i > 0 ? process.argv[i + 1] : def; };
const SEEDS = Number(arg("seeds", "2"));
const DENOISE = Number(arg("denoise", "0.7"));
const CN = Number(arg("cn", "0.9"));
const OUT = "proby/koncept5";
const CHARACTER = "one adult man about 40, slim realistic adult proportions, dark navy wool winter coat to the knees, " +
  "muted brick red scarf, light grey knit sweater at the collar, charcoal grey trousers, brown leather winter boots, " +
  "short dark hair, stubble, tired serious face, standing still, arms at his sides";
const STYLE = "video game character concept illustration, clean dark outline around every shape, flat colour areas " +
  "with simple cel shading, clearly separated colours, plain flat light grey background, no cast shadow, no text";
const NEGATIVE = "photo, 3d render, realistic skin, blurry, text, watermark, chibi, cartoon kid, cute, multiple people, cropped, naked";

async function upload(path) {
  const form = new FormData();
  form.append("image", new Blob([readFileSync(path)], { type: "image/png" }), `${angle}_${basename(path)}`);
  form.append("overwrite", "true");
  const res = await fetch(`${COMFY}/upload/image`, { method: "POST", body: form });
  if (!res.ok) throw new Error(`upload ${path}: ${res.status}`);
  return (await res.json()).name;
}

function depthGraph(depth, seed) {
  return {
    1: { class_type: "CheckpointLoaderSimple", inputs: { ckpt_name: "sd_xl_base_1.0.safetensors" } },
    3: { class_type: "VAELoader", inputs: { vae_name: "sdxl_vae_fp16_fix.safetensors" } },
    4: { class_type: "CLIPTextEncode", inputs: { clip: ["1", 1], text: `${STYLE}, ${CHARACTER}` } },
    5: { class_type: "CLIPTextEncode", inputs: { clip: ["1", 1], text: NEGATIVE } },
    6: { class_type: "LoadImage", inputs: { image: depth } },
    7: { class_type: "ControlNetLoader", inputs: { control_net_name: "controlnet-depth-sdxl-1.0.fp16.safetensors" } },
    8: { class_type: "ControlNetApplyAdvanced", inputs: { positive: ["4", 0], negative: ["5", 0], control_net: ["7", 0], image: ["6", 0], strength: CN, start_percent: 0.0, end_percent: 0.85 } },
    9: { class_type: "EmptyLatentImage", inputs: { width: 1024, height: 1024, batch_size: 1 } },
    10: { class_type: "KSampler", inputs: { model: ["1", 0], positive: ["8", 0], negative: ["8", 1], latent_image: ["9", 0], seed, steps: 28, cfg: 6.5, sampler_name: "dpmpp_2m", scheduler: "karras", denoise: 1.0 } },
    11: { class_type: "VAEDecode", inputs: { samples: ["10", 0], vae: ["3", 0] } },
    12: { class_type: "SaveImage", inputs: { images: ["11", 0], filename_prefix: "mpfb_depth" } },
  };
}

function img2imgGraph(image, seed) {
  const steps = 8;
  return {
    unet: { class_type: "UNETLoader", inputs: { unet_name: "flux-2-klein-4b-fp8.safetensors", weight_dtype: "default" } },
    clip: { class_type: "CLIPLoader", inputs: { clip_name: "qwen_3_4b_fp8_mixed.safetensors", type: "flux2", device: "default" } },
    vae: { class_type: "VAELoader", inputs: { vae_name: "flux2-vae.safetensors" } },
    pos0: { class_type: "CLIPTextEncode", inputs: { clip: ["clip", 0], text: `Repaint the grey 3D figure as ${CHARACTER}. Keep the exact camera angle, outline of the body, proportions and pose. ${STYLE}.` } },
    neg0: { class_type: "ConditioningZeroOut", inputs: { conditioning: ["pos0", 0] } },
    load: { class_type: "LoadImage", inputs: { image } },
    scale: { class_type: "ImageScale", inputs: { image: ["load", 0], upscale_method: "lanczos", width: 1024, height: 1024, crop: "center" } },
    lat: { class_type: "VAEEncode", inputs: { pixels: ["scale", 0], vae: ["vae", 0] } },
    pos: { class_type: "ReferenceLatent", inputs: { conditioning: ["pos0", 0], latent: ["lat", 0] } },
    neg: { class_type: "ReferenceLatent", inputs: { conditioning: ["neg0", 0], latent: ["lat", 0] } },
    sigmas: { class_type: "Flux2Scheduler", inputs: { steps, width: 1024, height: 1024 } },
    split: { class_type: "SplitSigmasDenoise", inputs: { sigmas: ["sigmas", 0], denoise: DENOISE } },
    sampler: { class_type: "KSamplerSelect", inputs: { sampler_name: "euler" } },
    noise: { class_type: "RandomNoise", inputs: { noise_seed: seed } },
    guider: { class_type: "CFGGuider", inputs: { model: ["unet", 0], positive: ["pos", 0], negative: ["neg", 0], cfg: 1 } },
    sample: { class_type: "SamplerCustomAdvanced", inputs: { noise: ["noise", 0], guider: ["guider", 0], sampler: ["sampler", 0], sigmas: ["split", 1], latent_image: ["lat", 0] } },
    decode: { class_type: "VAEDecode", inputs: { samples: ["sample", 0], vae: ["vae", 0] } },
    save: { class_type: "SaveImage", inputs: { images: ["decode", 0], filename_prefix: "mpfb_img2img" } },
  };
}

async function run(prompt, saveNode) {
  const res = await fetch(`${COMFY}/prompt`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ prompt }) });
  const body = await res.json();
  if (!body.prompt_id) throw new Error(JSON.stringify(body).slice(0, 1200));
  for (;;) {
    await new Promise((r) => setTimeout(r, 1500));
    const entry = (await (await fetch(`${COMFY}/history/${body.prompt_id}`)).json())[body.prompt_id];
    if (!entry) continue;
    if (entry.status?.status_str === "error") throw new Error(JSON.stringify(entry.status.messages).slice(0, 1200));
    const images = entry.outputs?.[saveNode]?.images;
    if (images) return images[0];
  }
}

mkdirSync(OUT, { recursive: true });
const dir = `shots/mpfb_${angle}`;
const input = await upload(join(dir, mode === "depth" ? "postac_przod_depth.png" : "postac_przod_tlo.png"));
for (let s = 0; s < SEEDS; s++) {
  const seed = 7000 + s;
  const t0 = Date.now();
  const img = mode === "depth" ? await run(depthGraph(input, seed), "12") : await run(img2imgGraph(input, seed), "save");
  const data = await (await fetch(`${COMFY}/view?filename=${encodeURIComponent(img.filename)}&subfolder=${encodeURIComponent(img.subfolder)}&type=${img.type}`)).arrayBuffer();
  const tag = mode === "depth" ? `depth_cn${CN}` : `i2i_d${DENOISE}`;
  const file = join(OUT, `${tag}_${angle}_s${seed}.png`);
  writeFileSync(file, Buffer.from(data));
  appendFileSync(join(OUT, "prompts.jsonl"), JSON.stringify({ file, mode, angle, seed, denoise: DENOISE, cn: CN, secs: Math.round((Date.now() - t0) / 1000) }) + "\n");
  console.log(file, `${Math.round((Date.now() - t0) / 1000)}s`);
}
