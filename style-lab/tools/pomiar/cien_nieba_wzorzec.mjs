// PROTOTYP (ticket 36): cień nieba okna tylnego korytarza od walca postaci, na siatce podłogi.
// Porównuje: wzorzec (gęsta siatka na szybie, promień do każdego punktu, waga cos·cos/r²),
// obecne objects_hide (udział powierzchni prostokąta), propozycję (współczynnik kształtu części zakrytej / całej szyby).
// node cien_nieba_wzorzec.mjs
const body={x:8.45,y:0.26,r:0.26,h:1.8};
const sashes=[[7.575,8.3,1.375,1.9],[7.575,8.3,0.65,1.325],[8.35,9.075,1.375,1.9],[8.35,9.075,0.65,1.325]];
const N=[0,0,1];
const sub=(a,b)=>[a[0]-b[0],a[1]-b[1],a[2]-b[2]],dot=(a,b)=>a[0]*b[0]+a[1]*b[1]+a[2]*b[2];
const cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]];
const len=a=>Math.hypot(...a),nrm=a=>{const l=len(a);return[a[0]/l,a[1]/l,a[2]/l];};
// form factor of rectangle [u0,u1]×[z0,z1] on wall y=0 from o with normal n (as in sky_light)
function ff(o,n,u0,u1,z0,z1){if(u1<=u0||z1<=z0)return 0;const c=[[u0,0,z0],[u1,0,z0],[u1,0,z1],[u0,0,z1]];
 const mid=[(u0+u1)/2,0,(z0+z1)/2],tg=nrm(sub(mid,o));let f=0,w=0;
 for(let k=0;k<4;k++){const a=nrm(sub(c[k],o)),b=nrm(sub(c[(k+1)%4],o));const g=cross(a,b),l=len(g);if(l>1e-9){const ang=Math.acos(Math.max(-1,Math.min(1,dot(a,b))));f+=ang*dot(n,g)/l;w+=ang*dot(tg,g)/l;}}
 return Math.max(f*Math.sign(w),0)/(2*Math.PI);}
// bbox of the cylinder's silhouette on the wall (port of objects_hide); null = no overlap, 'in' = inside
function bbox(o){const plane=0,on=o[1],ou=o[0],span=plane-on;const to=[body.x-o[0],body.y-o[1]],dist=Math.hypot(...to),cn=body.y;
 if(dist<=body.r)return o[2]<=body.h?'in':null;
 if((cn-on)*span<=0||Math.abs(cn-on)>=Math.abs(span))return null;
 const ha=Math.asin(body.r/dist),mid=[to[0]/dist,to[1]/dist];let u0=1e9,u1=-1e9,os=0;
 for(const k of[-1,1]){const a=k*ha;const d=[mid[0]*Math.cos(a)-mid[1]*Math.sin(a),mid[0]*Math.sin(a)+mid[1]*Math.cos(a)];
  if(d[1]*span<=0){os=d[0]>=0?1:-1;continue;}const u=ou+d[0]*span/d[1];u0=Math.min(u0,u);u1=Math.max(u1,u);}
 if(os>0)u1=1e9;else if(os<0)u0=-1e9;
 const tw=span/mid[1];let z0=1e9,z1=-1e9;
 for(const k of[-1,1]){const at=Math.max(dist+k*body.r,0.02);z0=Math.min(z0,o[2]+(0-o[2])*tw/at);z1=Math.max(z1,o[2]+(body.h-o[2])*tw/at);}
 return[u0,u1,z0,z1];}
const share=(b,s)=>Math.max(0,Math.min(b[1],s[1])-Math.max(b[0],s[0]))*Math.max(0,Math.min(b[3],s[3])-Math.max(b[2],s[2]))/((s[1]-s[0])*(s[3]-s[2]));
// ray o→q hits the cylinder?
function hits(o,q){const d=sub(q,o);const fx=o[0]-body.x,fy=o[1]-body.y;const A=d[0]*d[0]+d[1]*d[1],B=2*(fx*d[0]+fy*d[1]),C=fx*fx+fy*fy-body.r*body.r;
 if(C<=0&&o[2]<=body.h)return true;if(A<1e-12)return false;const D=B*B-4*A*C;if(D<0)return false;const s=Math.sqrt(D);
 let t0=(-B-s)/(2*A),t1=(-B+s)/(2*A);t0=Math.max(t0,0);t1=Math.min(t1,1);if(t0>t1)return false;
 const z0=o[2]+d[2]*t0,z1=o[2]+d[2]*t1;return Math.min(z0,z1)<=body.h&&Math.max(z0,z1)>=0;}
const G=60;
function point(o){let tot=0,hid=0;const wsum={a:0,cur:0,prop:0};
 for(const s of sashes){let st=0,sh=0;for(let i=0;i<G;i++)for(let j=0;j<G;j++){const q=[s[0]+(s[1]-s[0])*(i+.5)/G,0,s[2]+(s[3]-s[2])*(j+.5)/G];
   const d=sub(q,o),r2=dot(d,d),dn=nrm(d);const w=Math.max(0,dot(N,dn))*Math.max(0,-dn[1])/r2;st+=w;if(hits(o,q))sh+=w;}
  tot+=st;hid+=sh;
  const f=ff(o,N,s[0],s[1],s[2],s[3]);const W=0.25*Math.pow(f/0.25,0.7);
  const b=bbox(o);let cur=0,prop=0;
  if(b==='in'){cur=prop=1;}else if(b){cur=Math.min(1,share(b,s));prop=f>1e-9?ff(o,N,Math.max(b[0],s[0]),Math.min(b[1],s[1]),Math.max(b[2],s[2]),Math.min(b[3],s[3]))/f:0;}
  wsum.a+=W;wsum.cur+=W*cur;wsum.prop+=W*prop;}
 return{ref:tot>0?hid/tot:0,cur:wsum.cur/wsum.a,prop:wsum.prop/wsum.a};}
const xs=[];for(let x=7.0;x<=9.91;x+=0.25)xs.push(x);
for(const k of['ref','cur','prop']){console.log('\n'+k+(k==='ref'?' (wzorzec)':k==='cur'?' (obecne)':' (propozycja)'));
 console.log('d|x '+xs.map(x=>x.toFixed(2).padStart(5)).join(''));
 for(let d=0.6;d<=3.01;d+=0.2)console.log(d.toFixed(1).padStart(4)+' '+xs.map(x=>point([x,d,0.003])[k].toFixed(2).padStart(5)).join(''));}
// max |błąd| względem wzorca na gęstszej siatce (także tuż przy postaci)
let me={cur:0,prop:0},at={};for(let d=0.05;d<=3.0;d+=0.05)for(let x=6.5;x<=10.5;x+=0.05){const p=point([x,d,0.003]);if(p.ref>=0.999)continue;
 for(const k of['cur','prop']){const e=Math.abs(p[k]-p.ref);if(e>me[k]){me[k]=e;at[k]=[x.toFixed(2),d.toFixed(2),p.ref.toFixed(2),p[k].toFixed(2)];}}}
console.log('\nmaks. błąd',JSON.stringify(me),JSON.stringify(at));
{let me={cur:0,prop:0},at={};for(let d=0.55;d<=3.0;d+=0.05)for(let x=6.5;x<=10.5;x+=0.05){const p=point([x,d,0.003]);
 for(const k of['cur','prop']){const e=Math.abs(p[k]-p.ref);if(e>me[k]){me[k]=e;at[k]=[x.toFixed(2),d.toFixed(2),p.ref.toFixed(2),p[k].toFixed(2)];}}}
console.log('maks. błąd d>=0.55',JSON.stringify(me),JSON.stringify(at));
console.log('mapa błędu prop-ref, d 0.05..0.6');const X=[];for(let x=7.5;x<=9.6;x+=0.15)X.push(x);
console.log('d|x '+X.map(x=>x.toFixed(2).padStart(6)).join(''));
for(let d=0.05;d<=0.61;d+=0.05)console.log(d.toFixed(2)+' '+X.map(x=>{const p=point([x,d,0.003]);return (p.prop-p.ref).toFixed(2).padStart(6);}).join(''));}
// KOLUMNY: dokładny rzut walca na ścianę (dla każdej kolumny u szyby: cięciwa promienia w rzucie przez koło,
// wysokość wierzchu i spodu z wejścia / wyjścia), wielokąt K+1 kolumn, współczynnik kształtu wielokąta / szyby.
function ffPoly(o,n,P){const mid=P.reduce((a,p)=>[a[0]+p[0]/P.length,a[1]+p[1]/P.length,a[2]+p[2]/P.length],[0,0,0]);const tg=nrm(sub(mid,o));let f=0,w=0;
 for(let k=0;k<P.length;k++){const a=nrm(sub(P[k],o)),b=nrm(sub(P[(k+1)%P.length],o));const g=cross(a,b),l=len(g);if(l>1e-9){const ang=Math.acos(Math.max(-1,Math.min(1,dot(a,b))));f+=ang*dot(n,g)/l;w+=ang*dot(tg,g)/l;}}
 return Math.max(f*Math.sign(w),0)/(2*Math.PI);}
const K=+(process.env.K||4);
function hideCol(o,s){const span=0-o[1];const to=[body.x-o[0],body.y-o[1]],dist=Math.hypot(...to),r=body.r,h=body.h,zl=0;
 if(dist<=r)return o[2]<=h?1:0;
 // część koła przed punktem (w stronę ściany)
 if((body.y-o[1])*Math.sign(span)<=-r)return 0;
 const ha=Math.asin(r/dist),mid=[to[0]/dist,to[1]/dist];let u0=1e9,u1=-1e9,os=0;
 for(const k of[-1,1]){const a=k*ha;const d=[mid[0]*Math.cos(a)-mid[1]*Math.sin(a),mid[0]*Math.sin(a)+mid[1]*Math.cos(a)];
  if(d[1]*span<=0){os=d[0]>=0?1:-1;continue;}const u=o[0]+d[0]*span/d[1];u0=Math.min(u0,u);u1=Math.max(u1,u);}
 if(os>0)u1=1e9;else if(os<0)u0=-1e9;
 const a=Math.max(u0,s[0]),b=Math.min(u1,s[1]);if(b<=a)return 0;
 const top=[],bot=[];
 for(let j=0;j<=K;j++){const u=a+(b-a)*j/K;const w=[u-o[0],span],L=Math.hypot(...w),dir=[w[0]/L,w[1]/L];
  const pr=dir[0]*to[0]+dir[1]*to[1],q=r*r-(dist*dist-pr*pr);const sq=Math.sqrt(Math.max(q,0));
  const ti=Math.max(pr-sq,1e-4)/L,to_=Math.min(Math.max(pr+sq,1e-4)/L,1);
  const z=o[2];let zt,zb;
  if(z<=h)zt=z+(h-z)/ti;else zt=z+(h-z)/to_;
  if(z>=zl)zb=z+(zl-z)/ti;else zb=z+(zl-z)/to_;
  const cl=v=>Math.min(Math.max(v,s[2]),s[3]);top.push([u,0,cl(zt)]);bot.push([u,0,cl(zb)]);}
 const P=[...bot,...top.reverse()];const f=ff(o,N,s[0],s[1],s[2],s[3]);return f>1e-9?Math.min(1,ffPoly(o,N,P)/f):0;}
function pointCol(o){let wa=0,wc=0;for(const s of sashes){const f=ff(o,N,s[0],s[1],s[2],s[3]);const W=0.25*Math.pow(f/0.25,0.7);wa+=W;wc+=W*hideCol(o,s);}return wc/wa;}
{let me=0,at;const hist=[0,0,0,0];for(let d=0.02;d<=3.0;d+=0.04)for(let x=6.5;x<=10.5;x+=0.05){const p=point([x,d,0.003]);const c=pointCol([x,d,0.003]);const e=Math.abs(c-p.ref);
 hist[e<0.02?0:e<0.04?1:e<0.08?2:3]++;if(e>me){me=e;at=[x.toFixed(2),d.toFixed(2),p.ref.toFixed(3),c.toFixed(3)];}}
console.log('KOLUMNY K='+K+' maks. błąd',me.toFixed(3),JSON.stringify(at),'rozkład <.02/<.04/<.08/więcej',hist.join('/'));}
// wzorzec z tą samą wagą szyb co shader (W = pow współczynnika kształtu), żeby porównać tylko zasłonięcie
function refW(o){let wa=0,wh=0;for(const s of sashes){let st=0,sh=0;for(let i=0;i<G;i++)for(let j=0;j<G;j++){const q=[s[0]+(s[1]-s[0])*(i+.5)/G,0,s[2]+(s[3]-s[2])*(j+.5)/G];
 const d=sub(q,o),r2=dot(d,d),dn=nrm(d);const w=Math.max(0,dot(N,dn))*Math.max(0,-dn[1])/r2;st+=w;if(hits(o,q))sh+=w;}
 const f=ff(o,N,s[0],s[1],s[2],s[3]);const W=0.25*Math.pow(f/0.25,0.7);wa+=W;wh+=W*(st>0?sh/st:0);}return wh/wa;}
{let me=0,at;const hist=[0,0,0,0];for(let d=0.02;d<=3.0;d+=0.04)for(let x=6.5;x<=10.5;x+=0.05){const r=refW([x,d,0.003]);const c=pointCol([x,d,0.003]);const e=Math.abs(c-r);
 hist[e<0.02?0:e<0.04?1:e<0.08?2:3]++;if(e>me){me=e;at=[x.toFixed(2),d.toFixed(2),r.toFixed(3),c.toFixed(3)];}}
console.log('KOLUMNY vs wzorzec W, K='+K+' maks. błąd',me.toFixed(3),JSON.stringify(at),'rozkład',hist.join('/'));}
