// PROTOTYP (ticket silnika 02): strona wyboru mebli. Z style-lab/: node proby/meble/wybor.mjs [mebel ...]
// (bez argumentów wszystkie meble; ticket silnika 10: node proby/meble/wybor.mjs stall)
// Czyta proby/meble/<mebel>/wynik/sito.jsonl (tools/meble/mebel_piksele.gd), pokazuje tylko wersje zgodne
// z rzutem z Blendera (podstawa pokryta, dół na linii podłogi; dodatki wolno): duży obraz z konturami, sprite gry ×1 i ×4 obok bibliotekarki w tej samej skali.
import { existsSync, readFileSync, writeFileSync } from "node:fs";

const WSZYSTKIE = { lada: "Lada", stol: "Stół z nogami", fotel: "Fotel", stall: "Stragan (ticket silnika 10)" };
const wybrane = process.argv.slice(2);
const MEBLE = Object.fromEntries(Object.entries(WSZYSTKIE).filter(([m]) => wybrane.length === 0 || wybrane.includes(m)));
const OPIS = { a: "opis A", b: "opis B" };
// Postać 72 px, stopy 7 px nad dołem płótna 80 px; mebel: punkt zaczepienia w wierszu z bryly.json.
const POSTAC = "../bibliotekarka/sprite/przod_A.png";
const POSTAC_STOPY = 7;

const prompts = (m) => Object.fromEntries(readFileSync(`proby/meble/${m}/qwen/prompts.jsonl`, "utf8").trim().split("\n")
  .map((l) => JSON.parse(l)).map((p) => [p.file.split("/").pop().replace(".png", ""), p.prompt.match(/^Create (.*?)\. The grey/)[1]]));

function scena(m, nazwa, skala, zaczepienie, plotno) {
  const pod = (plotno[1] - zaczepienie[1]) * skala;
  return `<div class="scena" style="--s:${skala}">
    <img src="${POSTAC}" style="width:${80 * skala}px;margin-bottom:${-POSTAC_STOPY * skala}px">
    <img src="${m}/wynik/${nazwa}.png" style="width:${plotno[0] * skala}px;margin-bottom:${-pod}px">
  </div>`;
}

let html = `<!doctype html><html lang="pl"><meta charset="utf-8"><title>Wybór mebli</title>
<style>
body{font:15px/1.4 system-ui,sans-serif;background:#1d1f24;color:#e6e6e6;margin:24px}
h1{font-size:22px} h2{font-size:19px;margin-top:40px;border-bottom:1px solid #444}
.wersje{display:flex;flex-wrap:wrap;gap:20px}
.karta{background:#2a2d33;padding:12px;border-radius:6px;min-width:500px}
.karta>img{width:480px;display:block}
.karta b{font-size:17px}
.scena{display:flex;align-items:flex-end;gap:calc(var(--s)*8px);background:#5c5f68;padding:calc(var(--s)*6px) calc(var(--s)*8px) calc(var(--s)*24px);margin-top:8px;width:max-content}
.scena img{image-rendering:pixelated;display:block}
.male{font-size:13px;color:#aaa}
</style>
<h1>Wybór mebli</h1>
<p>Każda wersja przeszła sito: stoi dokładnie na podstawie z Blendera (ten sam kąt, wielkość i linia podłogi), dodatki mogą wychodzić poza nią (czerwony kontur = Blender, turkusowy = obraz z generatora). Sprite ma 40 kolorów, jak klatki chodu z Pixellab.
Pod obrazem sprite gry (40 px/m) obok bibliotekarki w tej samej skali: ×1 i ×4. Wybierz po jednej wersji każdego mebla (np. „lada b_s9000”).</p>`;

for (const [m, tytul] of Object.entries(MEBLE)) {
  if (!existsSync(`proby/meble/${m}/wynik/sito.jsonl`)) continue;
  const info = JSON.parse(readFileSync(`shots/prowadnice_v2/${m}/bryly.json`, "utf8"));
  const wyniki = readFileSync(`proby/meble/${m}/wynik/sito.jsonl`, "utf8").trim().split("\n").map((l) => JSON.parse(l));
  const ostatnie = Object.values(Object.fromEntries(wyniki.map((w) => [w.nazwa, w]))).filter((w) => w.zgodny);
  const opisy = prompts(m);
  html += `<h2>${tytul}</h2><div class="wersje">`;
  for (const w of ostatnie) {
    html += `<div class="karta"><b>${m} ${w.nazwa}</b> <span class="male">(${OPIS[w.nazwa[0]]}: ${opisy[w.nazwa]})</span>
      <img src="${m}/wynik/${w.nazwa}_kontrola.png">
      <div class="male">podstawa pokryta ${(w.pokrycie * 100).toFixed(1)}% · dodatki poza podstawą ${(w.nadmiar * 100).toFixed(1)}% · dół względem podłogi ${w.dol} px (1 px gry = 10)</div>
      ${scena(m, w.nazwa, 1, info.zaczepienie_gra, info.plotno_gra)}
      ${scena(m, w.nazwa, 4, info.zaczepienie_gra, info.plotno_gra)}
    </div>`;
  }
  html += `</div>`;
}
writeFileSync("proby/meble/wybor.html", html + "\n");
console.log("proby/meble/wybor.html");
