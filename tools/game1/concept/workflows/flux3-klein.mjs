// FLUX 3 Image Klein distilled (int8): text -> image, optionally conditioned on
// reference images (<ref_image_0>, <ref_image_1>, ... in the prompt). Mirrors the
// ComfyUI template image_flux3_klein_distilled_image_edit, flattened to API
// format, without the prompt upsampler.

export const model = "flux3-image-klein-int8-convrot";

export const defaults = { width: 1024, height: 1024, steps: 16 };

// refs: uploaded image names in ComfyUI's input dir.
export function build({ prompt, seed, refs, width, height, steps }) {
  const g = {
    unet: { class_type: "UNETLoader", inputs: { unet_name: "flux3-image-klein-int8-convrot.safetensors", weight_dtype: "default" } },
    clip: { class_type: "CLIPLoader", inputs: { clip_name: "qwen3vl_4b_int8_convrot.safetensors", type: "flux3", device: "default" } },
    vae: { class_type: "VAELoader", inputs: { vae_name: "flux2-vae.safetensors" } },
    pos0: { class_type: "CLIPTextEncode", inputs: { clip: ["clip", 0], text: prompt } },
    neg0: { class_type: "CLIPTextEncode", inputs: { clip: ["clip", 0], text: "" } },
    latent: { class_type: "EmptyFlux2LatentImage", inputs: { width, height, batch_size: 1 } },
  };

  let pos = ["pos0", 0];
  let neg = ["neg0", 0];
  if (refs.length) {
    const ref = {
      class_type: "ReferenceMultiLatent",
      inputs: { positive: pos, negative: neg, vae: ["vae", 0], resolution: "resize", "resolution.megapixels": 1 },
    };
    refs.forEach((name, i) => {
      g[`ref${i}_load`] = { class_type: "LoadImage", inputs: { image: name } };
      ref.inputs[`images.image${i}`] = [`ref${i}_load`, 0];
    });
    g.ref = ref;
    pos = ["ref", 0];
    neg = ["ref", 1];
  }

  Object.assign(g, {
    sample: {
      class_type: "KSampler",
      inputs: {
        model: ["unet", 0], positive: pos, negative: neg, latent_image: ["latent", 0],
        seed, steps, cfg: 1, sampler_name: "euler", scheduler: "simple", denoise: 1,
      },
    },
    decode: { class_type: "VAEDecode", inputs: { samples: ["sample", 0], vae: ["vae", 0] } },
    save: { class_type: "SaveImage", inputs: { images: ["decode", 0], filename_prefix: "concept" } },
  });
  return g;
}
