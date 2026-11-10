// Puts captures from capture_variants.gd (and optionally reference frames) in one grid: rows are
// variants, columns are hours, each cell the same rectangle cut from its frame and scaled up.
// Usage: node tools/variant_sheets/compose.mjs --in=<dir> --out=<file.png> --rows=a,b --hours=0825,1200
//          [--rect=x,y,w,h] [--scale=2] [--reference=<dir with manifest.json>]
// A row named "referencja" takes its frames from --reference, matched by the hour in their file names.
import { readFileSync, readdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { decodePng, encodePng } from "../reference_shots/png.mjs";

const GAP = 6;
const BACKGROUND = [24, 24, 28, 255];
const REFERENCE_ROW = "referencja";

function args() {
  const parsed = {};
  for (const argument of process.argv.slice(2)) {
    const [key, value] = argument.replace(/^--/, "").split("=");
    parsed[key] = value;
  }
  for (const required of ["in", "out", "rows", "hours"]) {
    if (!parsed[required]) {
      console.error(`Missing --${required}=`);
      process.exit(2);
    }
  }
  return parsed;
}

function framePath(options, row, hour) {
  if (row !== REFERENCE_ROW) return join(options.in, `${row}_${hour}.png`);
  const file = readdirSync(options.reference).find((name) => name.startsWith(`${hour}_`));
  if (!file) throw new Error(`no reference frame for ${hour}`);
  return join(options.reference, file);
}

function main() {
  const options = args();
  const rows = options.rows.split(",");
  const hours = options.hours.split(",");
  const scale = Number(options.scale ?? 2);
  const first = decodePng(readFileSync(framePath(options, rows[0], hours[0])));
  const [rx, ry, rw, rh] = options.rect
    ? options.rect.split(",").map(Number)
    : [0, 0, first.width, first.height];
  const cellW = rw * scale;
  const cellH = rh * scale;
  const width = hours.length * cellW + (hours.length + 1) * GAP;
  const height = rows.length * cellH + (rows.length + 1) * GAP;
  const data = new Uint8Array(width * height * 4);
  for (let i = 0; i < width * height; i++) data.set(BACKGROUND, i * 4);
  rows.forEach((row, r) => {
    hours.forEach((hour, c) => {
      const frame = decodePng(readFileSync(framePath(options, row, hour)));
      const left = GAP + c * (cellW + GAP);
      const top = GAP + r * (cellH + GAP);
      for (let y = 0; y < cellH; y++) {
        for (let x = 0; x < cellW; x++) {
          const source = ((ry + Math.floor(y / scale)) * frame.width + rx + Math.floor(x / scale)) * 4;
          data.set(frame.data.subarray(source, source + 4), ((top + y) * width + left + x) * 4);
        }
      }
    });
  });
  writeFileSync(options.out, encodePng({ width, height, data }));
  console.log(`${options.out}: ${rows.length} rows × ${hours.length} hours`);
}

main();
