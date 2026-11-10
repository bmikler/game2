// PROTOTYP (bryla ubrana): restyl renderu ubranej bryly (tools/blender/postac_ubrana.py) w ComfyUI, lokalnie (0 zl).
//   node tools/postac/ubrana_gen.mjs <tryb> <render.png> <wyjscie_prefiks> [--concept <koncept.png>] [--denoise 0.7] [--seed 9000]
//        [--prompt "..."]
// Tryby:
//   qwen2   Qwen-Image-Edit: image1 = koncept (tozsamosc/styl), image2 = render (struktura); latent z renderu (denoise < 1 trzyma geometrie)
//   qwen1   Qwen-Image-Edit: image1 = render; latent z renderu (denoise)
//   flux    FLUX.2 klein img2img z renderu (opcjonalnie koncept jako druga referencja), odszumianie --denoise
import { readFileSync, writeFileSync, appendFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";

const COMFY = "http://127.0.0.1:8188";
const [mode, render, outPrefix] = process.argv.slice(2);
const arg = (n, d) => { const i = process.argv.indexOf(`--${n}`); return i > 0 ? process.argv[i + 1] : d; };
const CONCEPT = arg("concept", "");
const DENOISE = Number(arg("denoise", "0.7"));
const SEED = Number(arg("seed", "9000"));
const PROMPT = arg("prompt", "");
const W = Number(arg("w", "768")), H = Number(arg("h", "1024"));

async function upload(path) {
  const form = new FormData();
  form.append("image", new Blob([readFileSync(path)], { type: "image/png" }), `ubr_${basename(path)}`);
  form.append("overwrite", "true");
  const res = await fetch(`${COMFY}/upload/image`, { method: "POST", body: form });
  if (!res.ok) throw new Error(`upload ${path}: ${res.status}`);
  return (await res.json()).name;
}

function qwenGraph(img1, img2, latentFrom) {
  const g = {
    unet: { class_type: "UnetLoaderGGUF", inputs: { unet_name: "qwen-image-edit-2511-Q4_K_M.gguf" } },
    fast: { class_type: "LoraLoaderModelOnly", inputs: { model: ["unet", 0], lora_name: "Qwen-Image-Edit-2511-Lightning-4steps-V1.0-bf16.safetensors", strength_model: 1.0 } },
    shift: { class_type: "ModelSamplingAuraFlow", inputs: { model: ["fast", 0], shift: 3.1 } },
    norm: { class_type: "CFGNorm", inputs: { model: ["shift", 0], strength: 1.0 } },
    clip: { class_type: "CLIPLoader", inputs: { clip_name: "qwen_2.5_vl_7b_fp8_scaled.safetensors", type: "qwen_image", device: "default" } },
    vae: { class_type: "VAELoader", inputs: { vae_name: "qwen_image_vae.safetensors" } },
    l1: { class_type: "LoadImage", inputs: { image: img1 } },
    s1: { class_type: "FluxKontextImageScale", inputs: { image: ["l1", 0] } },
    lr: { class_type: "LoadImage", inputs: { image: latentFrom } },
    sr: { class_type: "FluxKontextImageScale", inputs: { image: ["lr", 0] } },
    pos0: { class_type: "TextEncodeQwenImageEditPlus", inputs: { clip: ["clip", 0], prompt: PROMPT, vae: ["vae", 0], image1: ["s1", 0] } },
    neg0: { class_type: "TextEncodeQwenImageEditPlus", inputs: { clip: ["clip", 0], prompt: "", vae: ["vae", 0], image1: ["s1", 0] } },
    pos: { class_type: "FluxKontextMultiReferenceLatentMethod", inputs: { conditioning: ["pos0", 0], reference_latents_method: "index_timestep_zero" } },
    neg: { class_type: "FluxKontextMultiReferenceLatentMethod", inputs: { conditioning: ["neg0", 0], reference_latents_method: "index_timestep_zero" } },
    lat: { class_type: "VAEEncode", inputs: { pixels: ["sr", 0], vae: ["vae", 0] } },
    sample: { class_type: "KSampler", inputs: { model: ["norm", 0], positive: ["pos", 0], negative: ["neg", 0], latent_image: ["lat", 0], seed: SEED, steps: 4, cfg: 1.0, sampler_name: "euler", scheduler: "simple", denoise: DENOISE } },
    decode: { class_type: "VAEDecode", inputs: { samples: ["sample", 0], vae: ["vae", 0] } },
    save: { class_type: "SaveImage", inputs: { images: ["decode", 0], filename_prefix: "ubrana" } },
  };
  if (img2) {
    g.l2 = { class_type: "LoadImage", inputs: { image: img2 } };
    g.s2 = { class_type: "FluxKontextImageScale", inputs: { image: ["l2", 0] } };
    g.pos0.inputs.image2 = ["s2", 0];
    g.neg0.inputs.image2 = ["s2", 0];
  }
  return g;
}

function fluxGraph(img, ref) {
  const g = {
    unet: { class_type: "UNETLoader", inputs: { unet_name: "flux-2-klein-4b-fp8.safetensors", weight_dtype: "default" } },
    clip: { class_type: "CLIPLoader", inputs: { clip_name: "qwen_3_4b_fp8_mixed.safetensors", type: "flux2", device: "default" } },
    vae: { class_type: "VAELoader", inputs: { vae_name: "flux2-vae.safetensors" } },
    pos0: { class_type: "CLIPTextEncode", inputs: { clip: ["clip", 0], text: PROMPT } },
    neg0: { class_type: "ConditioningZeroOut", inputs: { conditioning: ["pos0", 0] } },
    load: { class_type: "LoadImage", inputs: { image: img } },
    scale: { class_type: "ImageScale", inputs: { image: ["load", 0], upscale_method: "lanczos", width: W, height: H, crop: "center" } },
    lat: { class_type: "VAEEncode", inputs: { pixels: ["scale", 0], vae: ["vae", 0] } },
    pos: { class_type: "ReferenceLatent", inputs: { conditioning: ["pos0", 0], latent: ["lat", 0] } },
    neg: { class_type: "ReferenceLatent", inputs: { conditioning: ["neg0", 0], latent: ["lat", 0] } },
    sigmas: { class_type: "Flux2Scheduler", inputs: { steps: 8, width: W, height: H } },
    split: { class_type: "SplitSigmasDenoise", inputs: { sigmas: ["sigmas", 0], denoise: DENOISE } },
    sampler: { class_type: "KSamplerSelect", inputs: { sampler_name: "euler" } },
    noise: { class_type: "RandomNoise", inputs: { noise_seed: SEED } },
    sample: { class_type: "SamplerCustomAdvanced", inputs: { noise: ["noise", 0], guider: ["guider", 0], sampler: ["sampler", 0], sigmas: ["split", 1], latent_image: ["lat", 0] } },
    decode: { class_type: "VAEDecode", inputs: { samples: ["sample", 0], vae: ["vae", 0] } },
    save: { class_type: "SaveImage", inputs: { images: ["decode", 0], filename_prefix: "ubrana" } },
  };
  let posNode = "pos", negNode = "neg";
  if (ref) {
    g.lref = { class_type: "LoadImage", inputs: { image: ref } };
    g.sref = { class_type: "ImageScale", inputs: { image: ["lref", 0], upscale_method: "lanczos", width: W, height: H, crop: "center" } };
    g.latr = { class_type: "VAEEncode", inputs: { pixels: ["sref", 0], vae: ["vae", 0] } };
    g.pos2 = { class_type: "ReferenceLatent", inputs: { conditioning: ["pos", 0], latent: ["latr", 0] } };
    g.neg2 = { class_type: "ReferenceLatent", inputs: { conditioning: ["neg", 0], latent: ["latr", 0] } };
    posNode = "pos2"; negNode = "neg2";
  }
  g.guider = { class_type: "CFGGuider", inputs: { model: ["unet", 0], positive: [posNode, 0], negative: [negNode, 0], cfg: 1 } };
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

const r = await upload(render);
const c = CONCEPT ? await upload(CONCEPT) : "";
let graph;
if (mode === "qwen2") graph = qwenGraph(c, r, r);
else if (mode === "qwen1") graph = qwenGraph(r, "", r);
else if (mode === "flux") graph = fluxGraph(r, c);
else throw new Error("tryb: qwen2|qwen1|flux");
const t0 = Date.now();
const img = await run(graph);
const data = await (await fetch(`${COMFY}/view?filename=${encodeURIComponent(img.filename)}&subfolder=${encodeURIComponent(img.subfolder)}&type=${img.type}`)).arrayBuffer();
const file = `${outPrefix}.png`;
writeFileSync(file, Buffer.from(data));
const secs = Math.round((Date.now() - t0) / 1000);
appendFileSync(join(dirname(file), "prompts.jsonl"), JSON.stringify({ file, mode, render, concept: CONCEPT || undefined, denoise: DENOISE, seed: SEED, prompt: PROMPT, secs }) + "\n");
console.log(file, `${secs}s`);
