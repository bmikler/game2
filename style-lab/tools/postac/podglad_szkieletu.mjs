// PROTOTYP (ticket „Przepis postaci”): podgląd szkieletów chodu przed wysłaniem do Pixellab skeleton-v3.
//   node tools/postac/podglad_szkieletu.mjs <katalog z szkielet.json> [wzór_klatki_glob_prefix]
// Zapisuje <katalog>/podglad.html (obrazy wbudowane jako base64, działa z dysku).
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { join } from "node:path";

const [dir, refPrefix = "proby/pixellab_postac_C/walking-8-frames_west_"] = process.argv.slice(2);
const sk = JSON.parse(readFileSync(join(dir, "szkielet.json"), "utf8"));
const b64 = (p) => `data:image/png;base64,${readFileSync(p).toString("base64")}`;
const ref = [];
for (let i = 0; existsSync(`${refPrefix}${i}.png`); i++) ref.push(b64(`${refPrefix}${i}.png`));
const data = { sprite: b64(sk.sprite), size: sk.size, rest: sk.first_frame_keypoints, chody: sk.chody, ref };

const html = `<!doctype html><html lang="pl"><head><meta charset="utf-8"><title>Szkielety chodu</title>
<style>body{background:#1d2026;color:#ddd;font:14px system-ui;margin:16px}h2{margin:18px 0 6px;font-size:16px}
.row{display:flex;gap:18px;flex-wrap:wrap;align-items:flex-start}.box{text-align:center}canvas{background:#3a3f48;image-rendering:pixelated}
label{margin-right:12px}.strip canvas{margin-right:2px}</style></head><body>
<h1 style="font-size:18px">Szkielety chodu dla skeleton-v3: bok C, kąt 0,60</h1>
<p>Lewa strona ciała (bliżej kamery) <span style="color:#ffb347">pomarańczowa</span>, prawa <span style="color:#6ec6ff">niebieska</span>.
Poza stojąca = szkielet sprite'a z Pixellab estimate-skeleton. Chody: mocap CMU (BVH), jeden cykl, 8 klatek; ze sprite'a długości i położenie kości, z mocapu obrót kości i ruch miednicy.
<label><input type="checkbox" id="spr" checked> sprite pod szkieletem</label> <label>kl./s <input type="number" id="fps" value="8" min="1" max="24" style="width:50px"></label></p>
<div class="row" id="top"></div><div id="chody"></div>
<script>
const D=${JSON.stringify(data)};
const S=6,[W,H]=D.size;
const img=new Image();img.src=D.sprite;
const BONES=[["NECK","NOSE"],["LEFT EYE","RIGHT EYE"],["NOSE","LEFT EYE"],["NOSE","RIGHT EYE"],["LEFT EYE","LEFT EAR"],["RIGHT EYE","RIGHT EAR"],
["NECK","LEFT SHOULDER"],["LEFT SHOULDER","LEFT ELBOW"],["LEFT ELBOW","LEFT ARM"],["NECK","RIGHT SHOULDER"],["RIGHT SHOULDER","RIGHT ELBOW"],["RIGHT ELBOW","RIGHT ARM"],
["NECK","LEFT HIP"],["LEFT HIP","LEFT KNEE"],["LEFT KNEE","LEFT LEG"],["NECK","RIGHT HIP"],["RIGHT HIP","RIGHT KNEE"],["RIGHT KNEE","RIGHT LEG"],["LEFT HIP","RIGHT HIP"]];
function cv(parent,label){const b=document.createElement("div");b.className="box";const c=document.createElement("canvas");c.width=W*S;c.height=H*S;b.append(c);const t=document.createElement("div");t.textContent=label;b.append(t);parent.append(b);return c;}
function draw(c,kps,withSprite=document.getElementById("spr").checked){const g=c.getContext("2d");g.imageSmoothingEnabled=false;g.clearRect(0,0,c.width,c.height);
 if(withSprite&&img.complete){g.globalAlpha=0.55;g.drawImage(img,0,0,W*S,H*S);g.globalAlpha=1;}
 const P={};for(const k of kps)P[k.label]=k;
 const segs=BONES.map(([a,b])=>({a,b,z:Math.min(P[a].z_index,P[b].z_index)})).sort((p,q)=>p.z-q.z);
 for(const s of segs){const A=P[s.a],B=P[s.b];const left=s.a.startsWith("LEFT")||s.b.startsWith("LEFT")&&!s.a.startsWith("RIGHT");
  const right=s.a.startsWith("RIGHT")||s.b.startsWith("RIGHT")&&!s.a.startsWith("LEFT");
  g.strokeStyle=left&&!right?"#ffb347":right&&!left?"#6ec6ff":"#e8e8e8";g.lineWidth=3;g.beginPath();g.moveTo(A.x*W*S,A.y*H*S);g.lineTo(B.x*W*S,B.y*H*S);g.stroke();}
 for(const k of kps){g.fillStyle="#fff";g.fillRect(k.x*W*S-2,k.y*H*S-2,4,4);}}
const topRow=document.getElementById("top");
const restC=cv(topRow,"poza stojąca (first_frame_keypoints)");
const refImgs=D.ref.map(s=>{const i=new Image();i.src=s;return i;});
const refC=D.ref.length?cv(topRow,"wzór ruchu: szablon Pixellab walking-8-frames"):null;
const anims=[];
for(const [name,ch] of Object.entries(D.chody)){
 const h=document.createElement("h2");h.textContent="CMU "+name+" (cykl "+(ch.cykl_kl_120fps/120).toFixed(2)+" s)";document.getElementById("chody").append(h);
 const row=document.createElement("div");row.className="row";document.getElementById("chody").append(row);
 const a=cv(row,"animacja");anims.push([a,ch.keypoints]);
 const strip=document.createElement("div");strip.className="strip";row.append(strip);
 ch.keypoints.forEach((kp,i)=>{const c=document.createElement("canvas");c.width=W*3;c.height=H*3;c.style.width=W*3+"px";strip.append(c);
  const big=document.createElement("canvas");big.width=W*S;big.height=H*S;draw(big,kp,false);c.getContext("2d").drawImage(big,0,0,W*3,H*3);});
}
let f=0;
function tick(){draw(restC,D.rest);
 if(refC){const g=refC.getContext("2d");g.imageSmoothingEnabled=false;g.clearRect(0,0,refC.width,refC.height);const im=refImgs[f%refImgs.length];if(im.complete)g.drawImage(im,0,0,W*S,H*S);}
 for(const [c,k] of anims)draw(c,k[f%k.length]);
 f++;setTimeout(tick,1000/Math.max(1,+document.getElementById("fps").value||8));}
img.onload=tick;
</script></body></html>`;
writeFileSync(join(dir, "podglad.html"), html);
console.log("zapisano", join(dir, "podglad.html"));
