#!/usr/bin/env node
// Generates concept art through a local ComfyUI server (HTTP API).
//
//   node tools/concept/comfy.mjs [options] "prompt"
//
// Options:
//   --out <dir>        output dir (default art/concept)
//   --name <slug>      file name prefix (default: from prompt)
//   --ref <png>        reference image, repeatable
//   --workflow <name>  module in tools/concept/workflows (default flux2-klein)
//   --seed <n>         first seed (default random)
//   --count <n>        variants, seeds seed..seed+n-1 (default 1)
//   --w <px> --h <px>  size (default from workflow)
//   --steps <n>        sampler steps (default from workflow)
//
// Env: COMFY_URL (default http://127.0.0.1:8188).
// Each image is saved as <out>/<name>-<seed>.png and logged to art/concept/prompts.jsonl.

import { readFile, writeFile, mkdir, appendFile } from "node:fs/promises";
import { basename, dirname, join, relative, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { parseArgs } from "node:util";

const COMFY = process.env.COMFY_URL ?? "http://127.0.0.1:8188";
const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, "../..");
const LOG = join(REPO, "art/concept/prompts.jsonl");

const { values: opt, positionals } = parseArgs({
  allowPositionals: true,
  options: {
    out: { type: "string", default: "art/concept" },
    name: { type: "string" },
    ref: { type: "string", multiple: true, default: [] },
    workflow: { type: "string", default: "flux2-klein" },
    seed: { type: "string" },
    count: { type: "string", default: "1" },
    w: { type: "string" },
    h: { type: "string" },
    steps: { type: "string" },
  },
});

const prompt = positionals.join(" ").trim();
if (!prompt) {
  console.error('usage: node tools/concept/comfy.mjs [--ref img.png] [--out dir] [--count n] "prompt"');
  process.exit(2);
}

const wf = await import(pathToFileURL(join(HERE, "workflows", `${opt.workflow}.mjs`)).href);
const width = Number(opt.w ?? wf.defaults.width);
const height = Number(opt.h ?? wf.defaults.height);
const steps = Number(opt.steps ?? wf.defaults.steps);
const count = Number(opt.count);
const firstSeed = opt.seed !== undefined ? Number(opt.seed) : Math.floor(Math.random() * 2 ** 32);
const name = opt.name ?? slug(prompt);
const outDir = resolve(REPO, opt.out);

async function api(path, init) {
  const res = await fetch(`${COMFY}${path}`, init);
  if (!res.ok) throw new Error(`${init?.method ?? "GET"} ${path}: ${res.status} ${await res.text()}`);
  return res;
}

async function upload(file) {
  const form = new FormData();
  form.append("image", new Blob([await readFile(file)], { type: "image/png" }), basename(file));
  form.append("overwrite", "true");
  const body = await (await api("/upload/image", { method: "POST", body: form })).json();
  return body.subfolder ? `${body.subfolder}/${body.name}` : body.name;
}

async function waitFor(id) {
  for (;;) {
    const hist = await (await api(`/history/${id}`)).json();
    const entry = hist[id];
    if (entry?.status?.completed) return entry;
    if (entry?.status?.status_str === "error") {
      const msg = entry.status.messages?.find(([kind]) => kind === "execution_error")?.[1];
      throw new Error(`ComfyUI error: ${msg?.exception_message ?? JSON.stringify(entry.status)}`);
    }
    await new Promise((r) => setTimeout(r, 1000));
  }
}

function slug(text) {
  return text.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "").slice(0, 40) || "concept";
}

const refs = await Promise.all(opt.ref.map(upload));
await mkdir(outDir, { recursive: true });
await mkdir(dirname(LOG), { recursive: true });

for (let i = 0; i < count; i++) {
  const seed = firstSeed + i;
  const started = Date.now();
  const graph = wf.build({ prompt, seed, refs, width, height, steps });
  const { prompt_id, node_errors } = await (
    await api("/prompt", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: graph }),
    })
  ).json();
  if (node_errors && Object.keys(node_errors).length) throw new Error(JSON.stringify(node_errors));

  const entry = await waitFor(prompt_id);
  const images = Object.values(entry.outputs).flatMap((o) => o.images ?? []);
  for (const img of images) {
    const q = new URLSearchParams({ filename: img.filename, subfolder: img.subfolder, type: img.type });
    const png = Buffer.from(await (await api(`/view?${q}`)).arrayBuffer());
    const file = join(outDir, `${name}-${seed}.png`);
    await writeFile(file, png);
    const seconds = Math.round((Date.now() - started) / 100) / 10;
    const rel = relative(REPO, file).replaceAll("\\", "/");
    await appendFile(LOG, JSON.stringify({
      time: new Date().toISOString(),
      file: rel,
      workflow: opt.workflow,
      model: wf.model,
      prompt,
      refs: opt.ref.map((r) => relative(REPO, resolve(r)).replaceAll("\\", "/")),
      seed, width, height, steps, seconds,
    }) + "\n");
    console.log(`${rel}  (${seconds} s)`);
  }
}
