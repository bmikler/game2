// PROTOTYP (ticket „Przepis postaci”): przeniesienie chodu z szkielet.json (mocap rzutowany na MPFB)
// na szkielet sprite'a z Pixellab estimate-skeleton. Ze sprite'a: położenie i długość kości.
// Z mocapu: obrót każdej kości względem pozy stojącej (w 2D), skrót długości, ruch miednicy.
//   node tools/postac/retarget_szkieletu.mjs <szkielet.json> <estimate.json> <wynik.json>
import { readFileSync, writeFileSync } from "node:fs";

const [skPath, estPath, outPath] = process.argv.slice(2);
const sk = JSON.parse(readFileSync(skPath, "utf8"));
const est = JSON.parse(readFileSync(estPath, "utf8"));
const [W, H] = sk.size;
const toPx = (kps) => Object.fromEntries(kps.map((k) => [k.label, { x: k.x * W, y: k.y * H, z: k.z_index ?? 0 }]));
const E = toPx(est.keypoints);
const R = toPx(sk.first_frame_keypoints);

// Łańcuchy od korzenia (miednica = środek bioder). Kości: [rodzic, dziecko].
const CHAIN = [
  ["PELVIS", "LEFT HIP"], ["PELVIS", "RIGHT HIP"], ["PELVIS", "NECK"],
  ["LEFT HIP", "LEFT KNEE"], ["LEFT KNEE", "LEFT LEG"], ["RIGHT HIP", "RIGHT KNEE"], ["RIGHT KNEE", "RIGHT LEG"],
  ["NECK", "LEFT SHOULDER"], ["NECK", "RIGHT SHOULDER"],
  ["LEFT SHOULDER", "LEFT ELBOW"], ["LEFT ELBOW", "LEFT ARM"], ["RIGHT SHOULDER", "RIGHT ELBOW"], ["RIGHT ELBOW", "RIGHT ARM"],
  ["NECK", "NOSE"], ["NECK", "LEFT EYE"], ["NECK", "RIGHT EYE"], ["NECK", "LEFT EAR"], ["NECK", "RIGHT EAR"],
];
const RIGID = new Set(["PELVIS>LEFT HIP", "PELVIS>RIGHT HIP", "NECK>LEFT SHOULDER", "NECK>RIGHT SHOULDER",
  "NECK>NOSE", "NECK>LEFT EYE", "NECK>RIGHT EYE", "NECK>LEFT EAR", "NECK>RIGHT EAR"]);
const pelvis = (P) => ({ x: (P["LEFT HIP"].x + P["RIGHT HIP"].x) / 2, y: (P["LEFT HIP"].y + P["RIGHT HIP"].y) / 2 });
E.PELVIS = pelvis(E);
R.PELVIS = pelvis(R);
const sub = (a, b) => ({ x: a.x - b.x, y: a.y - b.y });
const ang = (v) => Math.atan2(v.y, v.x);
const len = (v) => Math.hypot(v.x, v.y);
const rot = (v, a, s = 1) => ({ x: s * (v.x * Math.cos(a) - v.y * Math.sin(a)), y: s * (v.x * Math.sin(a) + v.y * Math.cos(a)) });

function retarget(F) {
  F.PELVIS = pelvis(F);
  const d = sub(F.PELVIS, R.PELVIS);
  const O = { PELVIS: { x: E.PELVIS.x + d.x, y: E.PELVIS.y + d.y } };
  // Obrót tułowia (miednica→szyja) dla kości sztywnych (biodra, barki, głowa).
  const torso = ang(sub(F.NECK, F.PELVIS)) - ang(sub(R.NECK, R.PELVIS));
  for (const [p, c] of CHAIN) {
    const e = sub(E[c], E[p]);
    let v;
    if (RIGID.has(`${p}>${c}`)) {
      // Sztywne: kształt ze sprite'a, przesunięcie jak w mocapie (bez obrotu, żeby nie rozjechać barków).
      v = { x: e.x + (sub(F[c], F[p]).x - sub(R[c], R[p]).x), y: e.y + (sub(F[c], F[p]).y - sub(R[c], R[p]).y) };
      if (p === "PELVIS") v = rot(e, torso * 0.5);
    } else {
      const fr = sub(F[c], F[p]);
      const rr = sub(R[c], R[p]);
      const s = Math.min(1.25, Math.max(0.6, len(fr) / Math.max(1e-6, len(rr))));
      v = rot(e, ang(fr) - ang(rr), s);
    }
    O[c] = { x: O[p].x + v.x, y: O[p].y + v.y };
  }
  return O;
}

const LABELS = est.keypoints.map((k) => k.label);
const pack = (O, zsrc) => LABELS.map((l) => ({
  label: l, x: +Math.min(1, Math.max(0, O[l].x / W)).toFixed(4), y: +Math.min(1, Math.max(0, O[l].y / H)).toFixed(4),
  z_index: Math.round(zsrc[l].z),
}));

const out = { ...sk, zrodlo_pozy_stojacej: estPath, first_frame_keypoints: pack(E, E), chody: {} };
for (const [name, ch] of Object.entries(sk.chody)) {
  out.chody[name] = { ...ch, keypoints: ch.keypoints.map((kps) => { const F = toPx(kps); return pack(retarget(F), F); }) };
}
writeFileSync(outPath, JSON.stringify(out, null, 1));
console.log("zapisano", outPath);
