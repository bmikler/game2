// PROTOTYP (ticket 36): cień nieba od walca postaci dla okien każdej ściany (tylne, przednie, boczne, drzwi wejściowe).
// Układ lokalny ściany: u wzdłuż ściany, n odległość od ściany w głąb pokoju (ściana w n = 0), z w górę.
// Porównuje z wzorcem (gęsta siatka na szybie, waga cos·cos/r²): obecne objects_hide (udział powierzchni prostokąta)
// i kolumny (dokładny rzut walca, współczynnik kształtu). node cien_nieba_sciany.mjs
const SHELL={x:15.5,y:8};
const RAW=`0 0 1.75 2.475 1.375 1.9|0 0 1.75 2.475 0.65 1.325|0 0 2.525 3.25 1.375 1.9|0 0 2.525 3.25 0.65 1.325
1 1 1.75 2.47 0.65 1.3075|1 1 1.75 2.47 1.3675 1.9|1 1 2.53 3.25 0.65 1.3075|1 1 2.53 3.25 1.3675 1.9
2 2 3.25 3.97 0.65 1.3075|2 2 3.25 3.97 1.3675 1.9|2 2 4.03 4.75 0.65 1.3075|2 2 4.03 4.75 1.3675 1.9
0 3 7.575 8.3 1.375 1.9|0 3 7.575 8.3 0.65 1.325|0 3 8.35 9.075 1.375 1.9|0 3 8.35 9.075 0.65 1.325
3 5 1.041667 1.761667 0.65 1.3075|3 5 1.041667 1.761667 1.3675 1.9|3 5 1.821667 2.541667 0.65 1.3075|3 5 1.821667 2.541667 1.3675 1.9
1 8 7.3 8.2 0.0 1.9`;
const WINDOWS={};for(const t of RAW.split(/[|\n]/)){const [w,k,...s]=t.trim().split(/\s+/).map(Number);(WINDOWS[k]??={wall:w,sashes:[]}).sashes.push(s);}
const NAMES={0:'tylne salon',1:'przednie (dolne) salon',2:'boczne lewe',3:'tylne korytarz',5:'boczne prawe',8:'drzwi wejściowe'};
const N=[0,0,1];
const sub=(a,b)=>[a[0]-b[0],a[1]-b[1],a[2]-b[2]],dot=(a,b)=>a[0]*b[0]+a[1]*b[1]+a[2]*b[2];
const cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]];
const len=a=>Math.hypot(...a),nrm=a=>{const l=len(a);return[a[0]/l,a[1]/l,a[2]/l];};
// lokalnie: punkt (u, n, z), ściana n = 0, pokój n > 0
function ffPoly(o,P){const m=P.reduce((a,p)=>[a[0]+p[0]/P.length,a[1]+p[1]/P.length,a[2]+p[2]/P.length],[0,0,0]);const tg=nrm(sub(m,o));let f=0,w=0;
 for(let k=0;k<P.length;k++){const a=nrm(sub(P[k],o)),b=nrm(sub(P[(k+1)%P.length],o));const g=cross(a,b),l=len(g);if(l>1e-9){const ang=Math.acos(Math.max(-1,Math.min(1,dot(a,b))));f+=ang*dot(N,g)/l;w+=ang*dot(tg,g)/l;}}
 return Math.max(f*Math.sign(w),0)/(2*Math.PI);}
const ffRect=(o,u0,u1,z0,z1)=>u1>u0&&z1>z0?ffPoly(o,[[u0,0,z0],[u1,0,z0],[u1,0,z1],[u0,0,z1]]):0;
function hits(o,q,B){const d=sub(q,o);const fx=o[0]-B.u,fy=o[1]-B.n;const A=d[0]*d[0]+d[1]*d[1],b=2*(fx*d[0]+fy*d[1]),C=fx*fx+fy*fy-B.r*B.r;
 if(C<=0&&o[2]<=B.h)return true;if(A<1e-12)return false;const D=b*b-4*A*C;if(D<0)return false;const s=Math.sqrt(D);
 let t0=Math.max((-b-s)/(2*A),0),t1=Math.min((-b+s)/(2*A),1);if(t0>t1)return false;const z0=o[2]+d[2]*t0,z1=o[2]+d[2]*t1;return Math.min(z0,z1)<=B.h&&Math.max(z0,z1)>=0;}
const G=48;
function refSash(o,s,B){let st=0,sh=0;for(let i=0;i<G;i++)for(let j=0;j<G;j++){const q=[s[0]+(s[1]-s[0])*(i+.5)/G,0,s[2]+(s[3]-s[2])*(j+.5)/G];
 const d=sub(q,o),r2=dot(d,d),dn=nrm(d);const w=Math.max(0,dn[2])*Math.max(0,-dn[1])/r2;st+=w;if(hits(o,q,B))sh+=w;}return st>0?sh/st:0;}
// tangenty walca na ścianie (wspólne): [u0,u1] albo null / 'in'
function tangents(o,B){const span=-o[1];const to=[B.u-o[0],B.n-o[1]],dist=Math.hypot(...to);
 if(dist<=B.r)return o[2]<=B.h?'in':null;
 const ha=Math.asin(B.r/dist),mid=[to[0]/dist,to[1]/dist];let u0=1e9,u1=-1e9,os=0;
 for(const k of[-1,1]){const a=k*ha;const d=[mid[0]*Math.cos(a)-mid[1]*Math.sin(a),mid[0]*Math.sin(a)+mid[1]*Math.cos(a)];
  if(d[1]*span<=0){os=mid[0]>=0?1:-1;continue;}const u=o[0]+d[0]*span/d[1];u0=Math.min(u0,u);u1=Math.max(u1,u);}
 if(os>0)u1=1e9;else if(os<0)u0=-1e9;return{u0,u1,dist,mid,to};}
function curSash(o,s,B){const span=-o[1];if((B.n-o[1])*span<=0||Math.abs(B.n-o[1])>=Math.abs(span)){const t=Math.hypot(B.u-o[0],B.n-o[1]);return t<=B.r&&o[2]<=B.h?1:0;}
 const T=tangents(o,B);if(T==='in')return 1;if(!T)return 0;const tw=span/T.mid[1];let z0=1e9,z1=-1e9;
 for(const k of[-1,1]){const at=Math.max(T.dist+k*B.r,0.02);z0=Math.min(z0,o[2]+(0-o[2])*tw/at);z1=Math.max(z1,o[2]+(B.h-o[2])*tw/at);}
 const area=(s[1]-s[0])*(s[3]-s[2]);return Math.min(1,Math.max(0,Math.min(T.u1,s[1])-Math.max(T.u0,s[0]))*Math.max(0,Math.min(z1,s[3])-Math.max(z0,s[2]))/area);}
const K=4;
function colSash(o,s,B){
 if(B.n-o[1]>=B.r)return 0; // walec cały za punktem (dalej od ściany)
 const T=tangents(o,B);if(T==='in')return 1;if(!T)return 0;const a=Math.max(T.u0,s[0]),b=Math.min(T.u1,s[1]);if(b<=a)return 0;
 const span=-o[1],top=[],bot=[],cl=v=>Math.min(Math.max(v,s[2]),s[3]);
 for(let j=0;j<=K;j++){const u=a+(b-a)*j/K;const L=Math.hypot(u-o[0],span),dir=[(u-o[0])/L,span/L];
  const pr=dir[0]*T.to[0]+dir[1]*T.to[1],q=B.r*B.r-(T.dist*T.dist-pr*pr),sq=Math.sqrt(Math.max(q,0));if(pr+sq<=0){top.push([u,0,s[2]]);bot.push([u,0,s[2]]);continue;}
  const ti=Math.max(pr-sq,1e-4)/L,tO=Math.min(Math.max(pr+sq,1e-4)/L,1),z=o[2];
  const zt=z<=B.h?z+(B.h-z)/ti:z+(B.h-z)/tO,zb=z>=0?z-z/ti:z-z/tO;top.push([u,0,cl(zt)]);bot.push([u,0,cl(zb)]);}
 const f=ffRect(o,...s);return f>1e-9?Math.min(1,ffPoly(o,[...bot,...top.reverse()])/f):0;}
function windowHide(o,W,B,fn){let wa=0,wh=0;for(const s of W.sashes){const f=ffRect(o,...s);if(f<1e-4)continue;const w=0.25*Math.pow(f/0.25,0.7);wa+=w;wh+=w*fn(o,s,B);}return wa>0?wh/wa:0;}
const r=0.26,h=1.8;
console.log('okno | postać (u, n) | maks. |obecne-wzorzec| | maks. |kolumny-wzorzec| (punkty podłogi nie pod stopami, n>=0.05)');
for(const [k,W] of Object.entries(WINDOWS)){const us=W.sashes.flatMap(s=>[s[0],s[1]]),umin=Math.min(...us),umax=Math.max(...us),mid=(umin+umax)/2;
 for(const B of[{u:mid,n:r},{u:mid-0.4,n:r},{u:umax+0.1,n:r},{u:mid,n:r+0.4},{u:mid,n:1.2}]){B.r=r;B.h=h;let ec=0,eq=0,ac,aq;
  for(let n=0.05;n<=3.0;n+=0.07)for(let u=umin-2;u<=umax+2;u+=0.09){const o=[u,n,0.003];if(Math.hypot(u-B.u,n-B.n)<=r+0.05)continue;
   const R=windowHide(o,W,B,refSash),c=windowHide(o,W,B,curSash),q=windowHide(o,W,B,colSash);
   if(Math.abs(c-R)>ec){ec=Math.abs(c-R);ac=`(${u.toFixed(2)};${n.toFixed(2)}) ${R.toFixed(2)}→${c.toFixed(2)}`;}
   if(Math.abs(q-R)>eq){eq=Math.abs(q-R);aq=`(${u.toFixed(2)};${n.toFixed(2)}) ${R.toFixed(2)}→${q.toFixed(2)}`;}}
  console.log(`${NAMES[k].padEnd(22)} (${B.u.toFixed(2)};${B.n.toFixed(2)}) | ${ec.toFixed(2)} ${ac} | ${eq.toFixed(2)} ${aq}`);}}
