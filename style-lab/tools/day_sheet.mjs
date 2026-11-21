// The day sheet of a Poligon (engine ticket 29): `node tools/day_sheet.mjs [count] [output.png] [scene]`
// (from style-lab). Thumbnails of `count` evenly spaced hours (default 24) with their clock times in
// one PNG (default shots/day_sheet.png). The numbers gate of the same day runs in `node tools/test.mjs`.
import { spawnSync } from 'node:child_process';
import { mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const GODOT = 'C:/Users/bartl/Desktop/repo/game1/tools/godot/Godot_v4.7.2-stable_win64_console.exe';
const PROJECT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const [count = '24', output = 'shots/day_sheet.png', scene] = process.argv.slice(2);
const outputPath = resolve(PROJECT, output);
mkdirSync(dirname(outputPath), { recursive: true });

function run(args) {
  const result = spawnSync(GODOT, ['--path', PROJECT, ...args], { stdio: ['ignore', 'pipe', 'pipe'], encoding: 'utf8' });
  if (result.error) {
    console.error(`Cannot start Godot: ${result.error.message}`);
    process.exit(2);
  }
  return result;
}

const imported = run(['--headless', '--import']);
if (imported.status !== 0) {
  process.stdout.write(imported.stdout);
  process.stderr.write(imported.stderr);
  console.error('Project import failed.');
  process.exit(imported.status ?? 2);
}

const sheet = run([
  '--resolution', '64x64', '--position', '-3000,-3000',
  '-s', 'res://tools/light_engine/day_sheet.gd', '--', count, outputPath, ...(scene ? [scene] : []),
]);
process.stdout.write(sheet.stdout.split('\n').filter((line) => line.startsWith('Day sheet') || /error/i.test(line)).join('\n') + '\n');
process.stderr.write(sheet.stderr);
process.exit(sheet.status ?? 2);
