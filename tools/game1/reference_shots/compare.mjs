// Compares a set of frames with the reference set and names the rooms and hours that differ.
// Usage: node compare.mjs <reference-dir> <candidate-dir> [--out=<dir>] [--rooms=<id,id>]
// Exit code: 0 no visible differences, 1 differences found, 2 wrong usage or unreadable reference.
import { existsSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { parseArgs } from "node:util";
import { compareFrames, renderDifference } from "./comparison.mjs";
import { decodePng, encodePng } from "./png.mjs";

const USAGE = "Usage: node compare.mjs <reference-dir> <candidate-dir> [--out=<dir>] [--rooms=<id,id>]";

function main(argv) {
  const { referenceDir, candidateDir, outDir, roomIds } = parseArguments(argv);
  const manifest = JSON.parse(readFileSync(join(referenceDir, "manifest.json"), "utf8"));
  const rooms = selectRooms(manifest.rooms, roomIds);
  mkdirSync(outDir, { recursive: true });

  const problems = [];
  for (const frame of manifest.frames) {
    const diffPath = join(outDir, frame.file);
    rmSync(diffPath, { force: true });
    const label = `${clock(frame.hour)} ${frame.id}`;
    const candidatePath = join(candidateDir, frame.file);
    if (!existsSync(candidatePath)) {
      problems.push(`${label}: missing ${frame.file}`);
      continue;
    }
    const reference = decodePng(readFileSync(join(referenceDir, frame.file)));
    const candidate = decodePng(readFileSync(candidatePath));
    if (candidate.width !== reference.width || candidate.height !== reference.height) {
      problems.push(`${label}: size ${candidate.width}x${candidate.height}, expected ${reference.width}x${reference.height}`);
      continue;
    }
    const comparison = compareFrames(reference, candidate, rooms);
    const different = comparison.rooms.filter((room) => room.different);
    if (different.length === 0) continue;
    writeFileSync(diffPath, encodePng(renderDifference(reference, candidate, comparison, rooms)));
    const names = different.map((room) => `${room.id} (${room.differentBlocks} blocks)`).join(", ");
    problems.push(`${label}: ${names} -> ${diffPath}`);
  }

  if (problems.length === 0) {
    console.log(`No visible differences in ${manifest.frames.length} frames (${rooms.map((room) => room.id).join(", ")}).`);
    return 0;
  }
  console.log(problems.join("\n"));
  return 1;
}

function parseArguments(argv) {
  let parsed;
  try {
    parsed = parseArgs({
      args: argv,
      allowPositionals: true,
      options: { out: { type: "string" }, rooms: { type: "string" } },
    });
  } catch (error) {
    throw new UsageError(`${error.message}\n${USAGE}`);
  }
  if (parsed.positionals.length !== 2) throw new UsageError(USAGE);
  const [referenceDir, candidateDir] = parsed.positionals;
  const outDir = parsed.values.out ?? join(candidateDir, "_diff");
  // Old difference images are deleted from the output, which must never be an input set.
  if ([referenceDir, candidateDir].some((dir) => resolve(dir) === resolve(outDir))) {
    throw new UsageError("--out must not be the reference or the candidate directory.");
  }
  return { referenceDir, candidateDir, outDir, roomIds: parsed.values.rooms?.split(",") };
}

function selectRooms(rooms, roomIds) {
  if (!roomIds) return rooms;
  const unknown = roomIds.filter((id) => !rooms.some((room) => room.id === id));
  if (unknown.length > 0) throw new UsageError(`Unknown rooms: ${unknown.join(", ")}`);
  return rooms.filter((room) => roomIds.includes(room.id));
}

function clock(hour) {
  const minutes = Math.round(hour * 60);
  const pad = (value) => String(value).padStart(2, "0");
  return `${pad(Math.floor(minutes / 60))}:${pad(minutes % 60)}`;
}

class UsageError extends Error {}

try {
  process.exitCode = main(process.argv.slice(2));
} catch (error) {
  console.error(error instanceof UsageError ? error.message : `Cannot compare: ${error.message}`);
  process.exitCode = 2;
}
