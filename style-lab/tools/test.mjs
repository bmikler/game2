// One command for the light engine tests: `node tools/test.mjs [-gselect=part_of_name]` (from style-lab).
// 1. Import the project (new class_names reach the class cache), 2. GUT in a window off screen:
// logic tests and GPU tests in one run (--headless does not render, research 89).
// Exit code 0 = all green.
import { spawnSync } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const GODOT = 'C:/Users/bartl/Desktop/repo/game1/tools/godot/Godot_v4.7.2-stable_win64_console.exe';
const PROJECT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const extra = process.argv.slice(2);

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

const gut = run([
  '--resolution', '64x64', '--position', '-3000,-3000',
  '-s', 'addons/gut/gut_cmdln.gd',
  '-gdir=res://test', '-ginclude_subdirs', '-gexit', '-gdisable_colors',
  ...extra,
]);
process.stdout.write(gut.stdout);
process.stderr.write(gut.stderr);
process.exit(gut.status ?? 2);
