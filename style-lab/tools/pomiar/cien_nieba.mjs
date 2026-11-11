// PROTOTYP (ticket 36): objects_hide (gałąź walca) z light_fn.gdshaderinc przepisane do JS: udział szyb okna tylnego korytarza
// zasłonięty przez walec postaci, na siatce punktów podłogi. node cien_nieba.mjs (dane okna i walca wpisane niżej, z wydruku SunMap).
// port of objects_hide (cylinder branch) for back-wall sashes
const body={x:8.45,y:0.26,r:0.26,h:1.8};
const sashes=[[7.575,8.3,1.375,1.9],[7.575,8.3,0.65,1.325],[8.35,9.075,1.375,1.9],[8.35,9.075,0.65,1.325]];
function rect_share(a0,a1,b0,b1,s){const area=(s[1]-s[0])*(s[3]-s[2]);return Math.max(0,Math.min(a1,s[1])-Math.max(a0,s[0]))*Math.max(0,Math.min(b1,s[3])-Math.max(b0,s[2]))/area;}
function hide(o,s){const plane=0,on=o.y,ou=o.x,span=plane-on;const c={x:body.x,y:body.y},r=body.r;
 const to={x:c.x-o.x,y:c.y-o.y},dist=Math.hypot(to.x,to.y),cn=c.y;
 if(dist<=r)return o.z<=body.h?1:0;
 if((cn-on)*span<=0||Math.abs(cn-on)>=Math.abs(span))return 0;
 const ha=Math.asin(r/dist),mid={x:to.x/dist,y:to.y/dist};let u0=1e9,u1=-1e9,open_side=0;
 for(const k of[-1,1]){const a=k*ha;const d={x:mid.x*Math.cos(a)-mid.y*Math.sin(a),y:mid.x*Math.sin(a)+mid.y*Math.cos(a)};
  const dn=d.y,du=d.x;if(dn*span<=0){open_side=du>=0?1:-1;continue;}const u=ou+du*span/dn;u0=Math.min(u0,u);u1=Math.max(u1,u);}
 if(open_side>0)u1=1e9;else if(open_side<0)u0=-1e9;
 const mn=mid.y,to_wall=span/mn;let z0=1e9,z1=-1e9;
 for(const k of[-1,1]){const at=Math.max(dist+k*r,0.02);z0=Math.min(z0,o.z+(0-o.z)*to_wall/at);z1=Math.max(z1,o.z+(body.h-o.z)*to_wall/at);}
 return Math.min(1,Math.max(0,rect_share(u0,u1,z0,z1,s)));}
let out='d|x ';for(let x=7.0;x<=9.91;x+=0.25)out+=x.toFixed(2).padStart(5);console.log(out);
for(let d=0.6;d<=3.01;d+=0.2){let line=d.toFixed(1).padStart(4)+' ';for(let x=7.0;x<=9.91;x+=0.25){const o={x,y:d,z:0.003};let h=0;for(const s of sashes)h+=hide(o,s);line+=(h/4).toFixed(2).padStart(5);}console.log(line);}
