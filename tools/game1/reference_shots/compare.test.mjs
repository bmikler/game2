import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { existsSync, mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { after, test } from "node:test";
import { fileURLToPath } from "node:url";
import { decodePng, encodePng } from "./png.mjs";

const COMPARE = join(dirname(fileURLToPath(import.meta.url)), "compare.mjs");
const workspace = mkdtempSync(join(tmpdir(), "reference-shots-"));
after(() => rmSync(workspace, { recursive: true, force: true }));

const MANIFEST = {
  size: [64, 32],
  rooms: [
    { id: "hall", rect: [0, 0, 32, 32] },
    { id: "cells", rect: [32, 0, 32, 32] },
  ],
  frames: [
    { id: "dzien", hour: 12, file: "1200_dzien.png" },
    { id: "noc", hour: 22, file: "2200_noc.png" },
  ],
};

let setNumber = 0;

function image(paintRect) {
  const data = new Uint8Array(64 * 32 * 4).fill(100);
  for (let at = 3; at < data.length; at += 4) data[at] = 255;
  if (paintRect) {
    const [x, y, width, height] = paintRect;
    for (let row = y; row < y + height; row++) {
      for (let column = x; column < x + width; column++) {
        data.fill(200, (row * 64 + column) * 4, (row * 64 + column) * 4 + 3);
      }
    }
  }
  return encodePng({ width: 64, height: 32, data });
}

function makeSet(frames) {
  const dir = join(workspace, `set${setNumber++}`);
  mkdirSync(dir);
  for (const [file, png] of Object.entries(frames)) writeFileSync(join(dir, file), png);
  return dir;
}

function makeReference() {
  const dir = makeSet({ "1200_dzien.png": image(), "2200_noc.png": image() });
  writeFileSync(join(dir, "manifest.json"), JSON.stringify(MANIFEST));
  return dir;
}

function compare(...args) {
  return spawnSync(process.execPath, [COMPARE, ...args], { encoding: "utf8" });
}

test("matching sets pass and leave no difference images", () => {
  const out = join(workspace, "out-match");
  const run = compare(makeReference(), makeSet({ "1200_dzien.png": image(), "2200_noc.png": image() }), `--out=${out}`);
  assert.equal(run.status, 0, run.stderr);
  assert.match(run.stdout, /no visible differences/i);
  assert.equal(existsSync(join(out, "1200_dzien.png")), false);
});

test("a difference is named by room and hour and comes with a difference image", () => {
  const out = join(workspace, "out-diff");
  const candidate = makeSet({ "1200_dzien.png": image(), "2200_noc.png": image([40, 8, 16, 16]) });
  const run = compare(makeReference(), candidate, `--out=${out}`);
  assert.equal(run.status, 1, run.stderr);
  assert.match(run.stdout, /22:00 noc: cells/);
  assert.doesNotMatch(run.stdout, /hall/);
  assert.doesNotMatch(run.stdout, /12:00/);
  const diff = decodePng(readFileSync(join(out, "2200_noc.png")));
  assert.equal(diff.width, 64);
  assert.equal(diff.height, 32);
  const inChange = (16 * 64 + 48) * 4;
  const outsideChange = (16 * 64 + 8) * 4;
  assert.ok(diff.data[inChange] > 0, "the changed area is marked");
  assert.equal(diff.data[outsideChange], 0, "the unchanged room stays black");
  assert.equal(existsSync(join(out, "1200_dzien.png")), false);
});

test("--rooms limits the comparison to the named rooms", () => {
  const candidate = makeSet({ "1200_dzien.png": image(), "2200_noc.png": image([40, 8, 16, 16]) });
  const run = compare(makeReference(), candidate, `--out=${join(workspace, "out-rooms")}`, "--rooms=hall");
  assert.equal(run.status, 0, run.stdout);
});

test("an unknown room in --rooms is a usage error", () => {
  const run = compare(makeReference(), makeReference(), "--rooms=kitchen");
  assert.equal(run.status, 2);
  assert.match(run.stderr, /kitchen/);
});

test("a missing candidate frame fails and is named", () => {
  const run = compare(makeReference(), makeSet({ "1200_dzien.png": image() }), `--out=${join(workspace, "out-missing")}`);
  assert.equal(run.status, 1);
  assert.match(run.stdout, /22:00 noc: missing/);
});

test("a candidate frame of another size fails and is named", () => {
  const small = encodePng({ width: 8, height: 8, data: new Uint8Array(8 * 8 * 4).fill(255) });
  const run = compare(makeReference(), makeSet({ "1200_dzien.png": small, "2200_noc.png": image() }), `--out=${join(workspace, "out-size")}`);
  assert.equal(run.status, 1);
  assert.match(run.stdout, /12:00 dzien: size 8x8/);
});

test("a stale difference image is removed once the frame matches", () => {
  const out = join(workspace, "out-stale");
  const reference = makeReference();
  compare(reference, makeSet({ "1200_dzien.png": image([40, 8, 16, 16]), "2200_noc.png": image() }), `--out=${out}`);
  assert.equal(existsSync(join(out, "1200_dzien.png")), true);
  compare(reference, makeSet({ "1200_dzien.png": image(), "2200_noc.png": image() }), `--out=${out}`);
  assert.equal(existsSync(join(out, "1200_dzien.png")), false);
});

test("--out pointing at an input set is refused and deletes nothing", () => {
  const reference = makeReference();
  const candidate = makeSet({ "1200_dzien.png": image(), "2200_noc.png": image() });
  for (const out of [reference, candidate, join(candidate, ".")]) {
    const run = compare(reference, candidate, `--out=${out}`);
    assert.equal(run.status, 2);
    assert.match(run.stderr, /--out/);
  }
  assert.equal(existsSync(join(reference, "1200_dzien.png")), true);
  assert.equal(existsSync(join(candidate, "1200_dzien.png")), true);
});

test("an unknown option is a usage error", () => {
  const run = compare(makeReference(), makeReference(), "--room=hall");
  assert.equal(run.status, 2);
});

test("no arguments print usage", () => {
  const run = compare();
  assert.equal(run.status, 2);
  assert.match(run.stderr, /usage/i);
});
