// PROTOTYP (ticket „Rzut, skala i rozdzielczość”): seria zrzutów Poligonów Rzutu w wariantach i
// arkusz porównawczy HTML (lokalny, nie publikować). Uruchomienie z katalogu style-lab:
//   node tools/arkusz_rzutu.mjs            -> siatka kąt × px/m (ulica i dom, 12:00) + kadry
//   node tools/arkusz_rzutu.mjs --bez-zrzutow   -> tylko złożenie arkusza z istniejących zrzutów
import { execFileSync } from "node:child_process";
import { mkdirSync, readdirSync, rmSync, renameSync, writeFileSync, existsSync } from "node:fs";
import { join } from "node:path";

const GODOT = "C:/Users/bartl/Desktop/repo/game1/tools/godot/Godot_v4.7.2-stable_win64.exe";
const OUT = "shots/arkusz_rzut";
const KATY = ["1.00", "0.75", "0.70", "0.60", "0.50", "0.36"];
const PXM = ["32", "36", "40"];
const KADRY = ["960x540", "800x450", "640x360", "480x270"];
const SCENY = {
  ulica: { scene: "res://poligony/rzut_ulica.tscn", spawn: "start" },
  dom: { scene: "res://poligony/rzut_dom.tscn", spawn: "z_ulicy" },
};

function shoot(id, scena, set, hours = "12") {
  const file = join(OUT, `${id}.png`);
  if (existsSync(file)) return file;
  const before = new Set(readdirSync("shots"));
  const { scene, spawn } = SCENY[scena];
  execFileSync(GODOT, ["--path", ".", "--", `--scene=${scene}`, `--spawn=${spawn}`,
    `--set=${set}`, `--shots=${hours}`], { stdio: "ignore" });
  const made = readdirSync("shots").filter((f) => f.endsWith(".png") && !before.has(f));
  if (made.length !== 1) throw new Error(`${id}: oczekiwano 1 zrzutu, jest ${made.length}`);
  renameSync(join("shots", made[0]), file);
  console.log("zrzut", id);
  return file;
}

const rows = [];
if (!process.argv.includes("--bez-zrzutow")) {
  if (process.argv.includes("--od-nowa")) rmSync(OUT, { recursive: true, force: true });
  mkdirSync(OUT, { recursive: true });
}
for (const scena of ["ulica", "dom"]) {
  const cells = [];
  for (let k = 0; k < KATY.length; k++) {
    for (let p = 0; p < PXM.length; p++) {
      const id = `${scena}_kat${KATY[k]}_pxm${PXM[p]}`;
      if (!process.argv.includes("--bez-zrzutow")) shoot(id, scena, `kat=${k},pxm=${p},kadr=0,kadr_wn=0,siatka=1`);
      cells.push({ id, opis: `kąt ${KATY[k]} · ${PXM[p]} px/m (postać ${Math.round(PXM[p] * 1.8)} px)` });
    }
  }
  rows.push({ tytul: `${scena === "ulica" ? "Ulica" : "Pokój"}: kąt (wiersze) × px/m (kolumny), kadr 960×540, siatka 1 m, 12:00`, cols: PXM.length, cells });
}
for (const scena of ["ulica", "dom"]) {
  const cells = [];
  for (let f = 0; f < KADRY.length; f++) {
    const id = `${scena}_kadr${KADRY[f]}`;
    if (!process.argv.includes("--bez-zrzutow")) shoot(id, scena, `kat=3,pxm=1,kadr=${f},kadr_wn=${f}`, "21");
    cells.push({ id, opis: `kadr ${KADRY[f]} · kąt 0.60 · 36 px/m · 21:00` });
  }
  rows.push({ tytul: `${scena === "ulica" ? "Ulica" : "Pokój"}: kadr (bliżej kamery) przy kącie 0.60 i 36 px/m, noc`, cols: 2, cells });
}

// Zbliżenie zależne od miejsca: ta sama skala (px/m), ulica w kadrze 640×360, wnętrze 480×270.
{
  const cells = [];
  for (const [scena, set, opis] of [
    ["ulica", "kat=3,pxm=1,kadr=2,kadr_wn=3", "ulica: kadr 640×360 (×3 na 1080p)"],
    ["dom", "kat=3,pxm=1,kadr=2,kadr_wn=3", "wnętrze: kadr 480×270 (×4 na 1080p)"],
  ]) {
    const id = `zblizenie_${scena}`;
    if (!process.argv.includes("--bez-zrzutow")) shoot(id, scena, set, "17");
    cells.push({ id, opis: opis + " · kąt 0.60 · 36 px/m · 17:00" });
  }
  rows.push({ tytul: "Różne zbliżenie na zewnątrz i we wnętrzu (ta sama skala assetów, inny kadr)", cols: 2, cells, wspolna: true });
}
// Prowadnice z Blendera (jeśli są): zestaw testowy w tym samym rzucie.
const ZESTAW = "shots/zestaw_test";
if (existsSync(ZESTAW)) {
  const cells = readdirSync(ZESTAW).filter((f) => f.endsWith(".png")).sort()
    .map((f) => ({ id: "../zestaw_test/" + f.replace(/.png$/, ""), opis: f.replace(/.png$/, "").replace(/_/g, " ") }));
  rows.push({ tytul: "Prowadnice z Blendera dla generatorów (kąt 0.60, 128 px/m): szary box i depth", cols: 6, cells });
}

const html = `<!doctype html><meta charset="utf-8"><title>Arkusz rzutu</title>
<style>body{background:#111;color:#ddd;font:14px system-ui;margin:16px}h2{font-weight:500;margin:28px 0 8px}
.g{display:grid;gap:10px}figure{margin:0}img{width:100%;max-height:70vh;object-fit:contain;image-rendering:pixelated;display:block;background:#000}
figcaption{padding:4px 0;color:#aaa}</style>
<h1>Rzut, skala i rozdzielczość: arkusz porównawczy (prototyp, lokalnie)</h1>
<p>Kąt = głębia podłogi : szerokość (1.00 to rzut game1). Obrazy w rozdzielczości bazowej, skalowane w przeglądarce bez wygładzania.</p>
${rows.map((r) => `<h2>${r.tytul}</h2><div class="g" style="grid-template-columns:repeat(${r.cols},1fr)">
${r.cells.map((c) => `<figure><img src="${c.id}.png" loading="lazy"><figcaption>${c.opis}</figcaption></figure>`).join("\n")}</div>`).join("\n")}`;
writeFileSync(join(OUT, "arkusz.html"), html);
console.log("arkusz:", join(OUT, "arkusz.html"));
