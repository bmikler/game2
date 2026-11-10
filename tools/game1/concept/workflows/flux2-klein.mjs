// FLUX.2 [klein] 4B distilled (Apache 2.0): text -> image, optionally conditioned
// on reference images. Mirrors the ComfyUI template
// image_flux2_klein_image_edit_4b_distilled, flattened to API format.

export const model = "flux-2-klein-4b-fp8";

export const defaults = { width: 1024, height: 1024, steps: 4 };

// refs: uploaded image names in ComfyUI's input dir.
export function build({ prompt, seed, refs, width, height, steps }) {
  const g = {
    unet: { class_type: "UNETLoader", inputs: { unet_name: "flux-2-klein-4b-fp8.safetensors", weight_dtype: "default" } },
    clip: { class_type: "CLIPLoader", inputs: { clip_name: "qwen_3_4b_fp8_mixed.safetensors", type: "flux2", device: "default" } },
    vae: { class_type: "VAELoader", inputs: { vae_name: "flux2-vae.safetensors" } },
    pos0: { class_type: "CLIPTextEncode", inputs: { clip: ["clip", 0], text: prompt } },
    neg0: { class_type: "ConditioningZeroOut", inputs: { conditioning: ["pos0", 0] } },
  };

  let pos = "pos0";
  let neg = "neg0";
  refs.forEach((name, i) => {
    g[`ref${i}_load`] = { class_type: "LoadImage", inputs: { image: name } };
    g[`ref${i}_scale`] = { class_type: "ImageScaleToTotalPixels", inputs: { image: [`ref${i}_load`, 0], upscale_method: "lanczos", megapixels: 1, resolution_steps: 1 } };
    g[`ref${i}_lat`] = { class_type: "VAEEncode", inputs: { pixels: [`ref${i}_scale`, 0], vae: ["vae", 0] } };
    g[`ref${i}_pos`] = { class_type: "ReferenceLatent", inputs: { conditioning: [pos, 0], latent: [`ref${i}_lat`, 0] } };
    g[`ref${i}_neg`] = { class_type: "ReferenceLatent", inputs: { conditioning: [neg, 0], latent: [`ref${i}_lat`, 0] } };
    pos = `ref${i}_pos`;
    neg = `ref${i}_neg`;
  });

  Object.assign(g, {
    latent: { class_type: "EmptyFlux2LatentImage", inputs: { width, height, batch_size: 1 } },
    sigmas: { class_type: "Flux2Scheduler", inputs: { steps, width, height } },
    sampler: { class_type: "KSamplerSelect", inputs: { sampler_name: "euler" } },
    noise: { class_type: "RandomNoise", inputs: { noise_seed: seed } },
    guider: { class_type: "CFGGuider", inputs: { model: ["unet", 0], positive: [pos, 0], negative: [neg, 0], cfg: 1 } },
    sample: { class_type: "SamplerCustomAdvanced", inputs: { noise: ["noise", 0], guider: ["guider", 0], sampler: ["sampler", 0], sigmas: ["sigmas", 0], latent_image: ["latent", 0] } },
    decode: { class_type: "VAEDecode", inputs: { samples: ["sample", 0], vae: ["vae", 0] } },
    save: { class_type: "SaveImage", inputs: { images: ["decode", 0], filename_prefix: "concept" } },
  });
  return g;
}
