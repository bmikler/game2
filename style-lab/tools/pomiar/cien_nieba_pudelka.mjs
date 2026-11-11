// PROTOTYP (ticket 36): jedna funkcja zasłonięcia szyby (bryła = walec albo pudełko w rzucie, z od lo do hi) metodą kolumn,
// w układzie lokalnym ściany (u wzdłuż, n w głąb pokoju, ściana n = 0). Wzorzec: gęsta siatka na szybie.
// node cien_nieba_pudelka.mjs
const N=[0,0,1];
const sub=(a,b)=>[a[0]-b[0],a[1]-b[1],a[2]-b[2]],dot=(a,b)=>a[0]*b[0]+a[1]*b[1]+a[2]*b[2];
const cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]];
const len=a=>Math.hypot(...a),nrm=a=>{const l=len(a);return[a[0]/l,a[1]/l,a[2]/l];};
function ffPoly(o,P){const m=P.reduce((a,p)=>[a[0]+p[0]/P.length,a[1]+p[1]/P.length,a[2]+p[2]/P.length],[0,0,0]);const tg=nrm(sub(m,o));let f=0,w=0;
 for(let k=0;k<P.length;k++){const a=nrm(sub(P[k],o)),b=nrm(sub(P[(k+1)%P.length],o));const g=cross(a,b),l=len(g);if(l>1e-9){const ang=Math.acos(Math.max(-1,Math.min(1,dot(a,b))));f+=ang*dot(N,g)/l;w+=ang*dot(tg,g)/l;}}
 return Math.max(f*Math.sign(w),0)/(2*Math.PI);}
const ffRect=(o,s)=>ffPoly(o,[[s[0],0,s[2]],[s[1],0,s[2]],[s[1],0,s[3]],[s[0],0,s[3]]]);
// chord of the plan ray from o (direction dir, unit) through the shape: [t_in, t_out] or null
function chord(o,dir,B){if(B.r){const to=[B.u-o[0],B.n-o[1]];const pr=dir[0]*to[0]+dir[1]*to[1],q=B.r*B.r-(to[0]*to[0]+to[1]*to[1]-pr*pr);
  if(q<-1e-9)return null;const sq=Math.sqrt(Math.max(q,0));return pr+sq<=0?null:[Math.max(pr-sq,0),pr+sq];}
 let t0=0,t1=1e9;for(const [a,lo,hi] of[[0,B.u0,B.u1],[1,B.n0,B.n1]]){if(Math.abs(dir[a])<1e-12){if(o[a]<lo||o[a]>hi)return null;continue;}
  let x=(lo-o[a])/dir[a],y=(hi-o[a])/dir[a];if(x>y)[x,y]=[y,x];t0=Math.max(t0,x);t1=Math.min(t1,y);}return t0<=t1+1e-9?[t0,t1]:null;}
function inside(o,B){return B.r?Math.hypot(o[0]-B.u,o[1]-B.n)<=B.r:o[0]>=B.u0&&o[0]<=B.u1&&o[1]>=B.n0&&o[1]<=B.n1;}
// u range on the wall hidden by the shape (rays from o toward the wall): [a, b] and the columns' u
function columns(o,B,K){const span=-o[1];
 if(B.r){const to=[B.u-o[0],B.n-o[1]],dist=Math.hypot(...to);const ha=Math.asin(B.r/dist),mid=[to[0]/dist,to[1]/dist];let u0=1e9,u1=-1e9,os=0;
  for(const k of[-1,1]){const a=k*ha;const d=[mid[0]*Math.cos(a)-mid[1]*Math.sin(a),mid[0]*Math.sin(a)+mid[1]*Math.cos(a)];
   if(d[1]*span<=0){os=mid[0]>=0?1:-1;continue;}const u=o[0]+d[0]*span/d[1];u0=Math.min(u0,u);u1=Math.max(u1,u);}
  if(u0>u1&&os===0)return null;if(os>0)u1=1e9;else if(os<0)u0=-1e9;return{u0,u1,breaks:[]};}
 // box: its part between o and the wall; its corners projected
 const n0=Math.max(B.n0,0),n1=Math.min(B.n1,o[1]-0.001);if(n0>=n1)return null;let u0=1e9,u1=-1e9;const br=[];
 for(const n of[n0,n1])for(const u of[B.u0,B.u1]){const x=o[0]+(u-o[0])*o[1]/(o[1]-n);u0=Math.min(u0,x);u1=Math.max(u1,x);br.push(x);}return{u0,u1,breaks:br};}
function hideShape(o,s,B,K){if(inside(o,B))return o[2]>=B.lo&&o[2]<=B.hi?1:0;
 const C=columns(o,B,K);if(!C)return 0;const a=Math.max(C.u0,s[0]),b=Math.min(C.u1,s[1]);if(b<=a)return 0;
 let us=[];if(B.r){for(let j=0;j<=K;j++)us.push(a+(b-a)*j/K);}else{us=[a,b,...C.breaks.filter(x=>x>a&&x<b)].sort((x,y)=>x-y);}
 const span=-o[1],top=[],bot=[],cl=v=>v,z=o[2];
 const eps=(b-a)*1e-3;for(const u of us){const ue=Math.min(Math.max(u,a+eps),b-eps);const L=Math.hypot(u-o[0],span),Le=Math.hypot(ue-o[0],span),dir=[(ue-o[0])/Le,span/Le];const c=chord(o,dir,B);
  if(!c){top.push([u,0,s[2]]);bot.push([u,0,s[2]]);continue;}const ti=Math.max(c[0],1e-4)/L,tO=Math.min(Math.max(c[1],1e-4)/L,1);
  const zt=z<=B.hi?z+(B.hi-z)/ti:z+(B.hi-z)/tO,zb=z>=B.lo?z+(B.lo-z)/ti:z+(B.lo-z)/tO;top.push([u,0,cl(zt)]);bot.push([u,0,cl(zb)]);}
 const f=ffRect(o,s);const P=clipZ(clipZ([...bot,...top.reverse()],s[2],1),s[3],-1);return f>1e-9&&P.length>=3?Math.min(1,ffPoly(o,P)/f):0;}
// Sutherland–Hodgman: keep side*(z-limit) >= 0
function clipZ(P,lim,side){const out=[];for(let i=0;i<P.length;i++){const A=P[i],B=P[(i+1)%P.length];const da=side*(A[2]-lim),db=side*(B[2]-lim);
 if(da>=0)out.push(A);if((da>=0)!==(db>=0)){const t=da/(da-db);out.push([A[0]+(B[0]-A[0])*t,0,A[2]+(B[2]-A[2])*t]);}}return out;}
// brute force
function hits(o,q,B){const d=sub(q,o);const L=Math.hypot(d[0],d[1]);if(L<1e-12)return false;const dir=[d[0]/L,d[1]/L];
 if(inside(o,B)&&o[2]>=B.lo&&o[2]<=B.hi)return true;const c=chord(o,dir,B);if(!c)return false;const t0=c[0]/L,t1=Math.min(c[1]/L,1);if(t0>t1)return false;
 const z0=o[2]+d[2]*t0,z1=o[2]+d[2]*t1;return Math.min(z0,z1)<=B.hi&&Math.max(z0,z1)>=B.lo;}
const G=48;
function refSash(o,s,B){let st=0,sh=0;for(let i=0;i<G;i++)for(let j=0;j<G;j++){const q=[s[0]+(s[1]-s[0])*(i+.5)/G,0,s[2]+(s[3]-s[2])*(j+.5)/G];
 const d=sub(q,o),r2=dot(d,d),dn=nrm(d);const w=Math.max(0,dn[2])*Math.max(0,-dn[1])/r2;st+=w;if(hits(o,q,B))sh+=w;}return st>0?sh/st:0;}
const win=[[7.575,8.3,1.375,1.9],[7.575,8.3,0.65,1.325],[8.35,9.075,1.375,1.9],[8.35,9.075,0.65,1.325]];
const door=[[7.3,8.2,0.0,1.9]];
function wh(o,W,B,fn){let wa=0,wc=0;for(const s of W){const f=ffRect(o,s);if(f<1e-4)continue;const w=0.25*Math.pow(f/0.25,0.7);wa+=w;wc+=w*fn(o,s,B);}return wa>0?wc/wa:0;}
const cases=[['walec przy oknie',win,{u:8.32,n:0.26,r:0.26,lo:0,hi:1.8}],['walec z boku okna',win,{u:9.3,n:0.26,r:0.26,lo:0,hi:1.8}],
 ['pudełko jak postać przy oknie',win,{u0:8.06,u1:8.58,n0:0,n1:0.52,lo:0,hi:1.8}],['niska komoda pod oknem',win,{u0:7.6,u1:9.0,n0:0,n1:0.45,lo:0,hi:0.8}],
 ['szafa z boku okna',win,{u0:9.2,u1:10.2,n0:0,n1:0.6,lo:0,hi:2.0}],['stół 1 m od okna',win,{u0:7.8,u1:8.8,n0:1.0,n1:1.8,lo:0.7,hi:0.75}],
 ['krzesło 0,5 m od okna',win,{u0:8.0,u1:8.45,n0:0.5,n1:0.95,lo:0,hi:0.9}],['pudełko w drzwiach wejściowych',door,{u0:7.5,u1:8.0,n0:0.1,n1:0.6,lo:0,hi:1.8}],
 ['walec w drzwiach wejściowych',door,{u:7.75,n:0.26,r:0.26,lo:0,hi:1.8}]];
console.log('przypadek | maks. |kolumny-wzorzec| (gdzie: wzorzec→kolumny), podłoga i ściany boczne pomijane, punkty poza bryłą');
for(const [name,W,B] of cases){let e=0,at='',e2=0;for(let n=0.03;n<=3.0;n+=0.06)for(let u=6;u<=11;u+=0.08){const o=[u,n,0.003];if(inside(o,B))continue;
  const R=wh(o,W,B,refSash),Q=wh(o,W,B,(o,s,B)=>hideShape(o,s,B,4));if(Math.abs(Q-R)>e){e=Math.abs(Q-R);at=`(${u.toFixed(2)};${n.toFixed(2)}) ${R.toFixed(2)}→${Q.toFixed(2)}`;}}
 // punkt na ścianie nad meblem / blacie (z>0)
 console.log(name.padEnd(32),e.toFixed(3),at);}
