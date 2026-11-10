// PROTOTYP (ticket „Przepis postaci”): porównanie opcji wejścia do animacji (przód/bok/tył) ze szkieletem Blendera.
//   node tools/postac/porownanie_wejsc.mjs <katalog>   (z style-lab/)
// Czyta <katalog>/opcje.json:
//   { "ref": {"przod": "...png", ...},                       // manekin MPFB wyrównany (wyrownaj.gd)
//     "opcje": [{ "nazwa": "1", "opis": "...", "widoki": {"przod": {"duzy": "...", "sprite": "...", "zrodlo": "...", "pomiar": "..."}, ...}}] }
// Ścieżki względem <katalog>. Wynik: <katalog>/porownanie.html (lokalnie, nie publikować: prywatna adaptacja).
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const dir = process.argv[2];
const cfg = JSON.parse(readFileSync(join(dir, "opcje.json"), "utf8"));
const VIEWS = [["przod", "Przód"], ["bok", "Bok (w grze lustrzany)"], ["tyl", "Tył"]];
const esc = (s) => String(s ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;");

let rows = "";
for (const [v, label] of VIEWS) {
  let cells = `<figure class="ref"><div class="stage"><img src="${cfg.ref[v]}" alt=""></div><figcaption>Blender MPFB 0,60<small>proste nogi, wzorzec pozy i kąta</small></figcaption></figure>`;
  for (const o of cfg.opcje) {
    const w = o.widoki[v];
    cells += `<figure class="opt" data-opt="${esc(o.nazwa)}">
      <div class="stage"><img class="fig" src="${w.duzy}" alt=""><img class="ghost" src="${cfg.ref[v]}" alt=""></div>
      <div class="sprite"><img src="${w.sprite}" alt=""></div>
      <figcaption>Opcja ${esc(o.nazwa)}<small>${esc(w.zrodlo)}</small><small class="kat">${esc(w.pomiar)}</small></figcaption></figure>`;
  }
  rows += `<h2>${label}</h2><div class="row${v === "bok" ? " flip" : ""}">${cells}</div>`;
}
let sets = "";
for (const o of cfg.opcje) {
  sets += `<div class="set"><h3>Opcja ${esc(o.nazwa)}</h3><p>${esc(o.opis)}</p><div class="trio">${VIEWS.map(([v]) => `<img src="${o.widoki[v].sprite}" alt="">`).join("")}</div></div>`;
}

const html = `<!doctype html><html lang="pl"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Wejście do animacji</title>
<style>
:root{--bg:#1d2026;--card:#2a2e36;--fg:#e6e8ec;--dim:#9aa1ad;--acc:#7fb0ff}
body{margin:0;padding:16px;background:var(--bg);color:var(--fg);font:14px/1.45 system-ui,sans-serif}
h1{font-size:20px;margin:0 0 4px}h2{font-size:16px;margin:24px 0 8px}p{color:var(--dim);margin:4px 0}
.ctl{position:sticky;top:0;background:var(--bg);padding:8px 0;z-index:2;display:flex;gap:16px;align-items:center;flex-wrap:wrap}
.row{display:flex;gap:12px;flex-wrap:wrap}
figure{margin:0;background:var(--card);border-radius:8px;padding:8px;width:260px}
figure.ref{outline:1px dashed #555}
.stage{position:relative;height:360px;display:flex;justify-content:center;align-items:flex-end;background:#c9cbcf;border-radius:4px;overflow:hidden}
.stage img{height:340px;position:absolute;bottom:8px;left:50%;transform:translateX(-50%)}
.stage img.ghost{opacity:0;mix-blend-mode:multiply}
.flip .ref .stage img,.flip .ghost{transform:translateX(-50%) scaleX(-1)}
.sprite{display:flex;justify-content:center;background:#3a3f48;margin-top:8px;border-radius:4px}
.sprite img{width:240px;height:240px;image-rendering:pixelated}
figcaption{margin-top:6px;font-weight:600}figcaption small{display:block;font-weight:400;color:var(--dim);word-break:break-all}
figcaption small.kat{color:var(--acc)}
.sets{display:flex;gap:16px;flex-wrap:wrap}.set{background:var(--card);border-radius:8px;padding:12px}
.trio{display:flex;gap:4px;background:#3a3f48;padding:8px;border-radius:4px}.trio img{width:160px;height:160px;image-rendering:pixelated}
</style></head><body>
<h1>Wejście do animacji chodu: detektyw, proste nogi</h1>
<p>Kąt gry 0,60. Pomiary: przód i tył = Orient (polar, krzywa wyprostowanego detektywa MPFB, ±0,1); bok = uskok podeszew ÷ rozstaw stóp z przodu (dokładność ok. ±0,01 na renderach).</p>
<div class="ctl"><label>Nakładka szkieletu Blendera <input id="ghost" type="range" min="0" max="100" value="0"></label>
<label><input id="tlo" type="checkbox"> ciemne tło sprite'ów</label></div>
${rows}
<h2>Gotowe zestawy (sprite 80×80, wejście do Pixellab)</h2><div class="sets">${sets}</div>
<script>
const g=document.getElementById("ghost");g.oninput=()=>document.querySelectorAll(".ghost").forEach(e=>e.style.opacity=g.value/100);
const t=document.getElementById("tlo");t.onchange=()=>document.querySelectorAll(".sprite,.trio").forEach(e=>e.style.background=t.checked?"#111":"#3a3f48");
</script></body></html>`;
writeFileSync(join(dir, "porownanie.html"), html);
console.log(join(dir, "porownanie.html"));
