# PROTOTYP (bryła ubrana): mężczyzna MPFB2 + proste ubranie (kurtka, sweter, spodnie, buty, szalik, włosy, broda)
# zrobione z napompowanych kopii regionów siatki ciała, w płaskich kolorach konceptu `koncept9/edit_kurtka_s9000.png`.
# Kamera i rzut jak w postac_mpfb.py (ortho pochylona o atan(df), obraz rozciągnięty w pionie o 1/cos).
#
#   blender -b -P tools/blender/postac_ubrana.py -- --df 0.6 --ppm 400 --canvas 1024 --out proby/bryla_ubrana/render
#       [--views przod,bok,tyl] [--bg 1]
#
# Wynik: ubrana_{widok}.png (na szarym tle jak koncept) i ubrana_{widok}_alfa.png.
import bpy
import bmesh
import math
import os
import sys
from mathutils import Matrix, Vector

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
args = {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv) - 1, 2)}
DF = float(args.get("df", "0.6"))
PPM = int(args.get("ppm", "400"))
CANVAS = int(args.get("canvas", "1024"))
CANVAS_H = int(args.get("canvash", str(CANVAS)))  # wysokość po rozciągnięciu (np. 768x1024 jak koncept)
OUT = os.path.abspath(args.get("out", "proby/bryla_ubrana/render"))
VIEWS = args.get("views", "przod").split(",")
ARMS = math.radians(float(args.get("arms", "28")))
HEIGHT_M = 1.8
THETA = math.atan(DF)
os.makedirs(OUT, exist_ok=True)

from bl_ext.blender_org.mpfb.services.humanservice import HumanService  # noqa: E402
from bl_ext.blender_org.mpfb.services.targetservice import TargetService  # noqa: E402

for ob in list(bpy.data.objects):
    bpy.data.objects.remove(ob)

macro = TargetService.get_default_macro_info_dict()
macro.update({"gender": 1.0, "age": float(args.get("age", "0.6")), "muscle": float(args.get("muscle", "0.5")),
              "weight": float(args.get("weight", "0.45")), "proportions": float(args.get("proportions", "0.8")),
              "height": 0.7, "race": {"asian": 0.0, "caucasian": 1.0, "african": 0.0}})
body = HumanService.create_human(macro_detail_dict=macro)
rig = HumanService.add_builtin_rig(body, "default")
bpy.context.view_layer.update()

bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode="POSE")
for name, sign in (("upperarm01.L", 1.0), ("upperarm01.R", -1.0)):
    pb = rig.pose.bones.get(name)
    head = pb.matrix.translation.copy()
    axis = (rig.matrix_world.inverted().to_3x3() @ Vector((0, 1, 0))).normalized()
    pb.matrix = Matrix.Translation(head) @ Matrix.Rotation(sign * ARMS, 4, axis) @ Matrix.Translation(-head) @ pb.matrix
    bpy.context.view_layer.update()
# Przedramiona w MPFB w spoczynku wysunięte do przodu: lekko prostujemy (jak w postac_chod.py --elbow-rest)
bpy.ops.object.mode_set(mode="OBJECT")

# Skala do 1,8 m, stopy na ziemi, środek w (0,0).
def points():
    dg = bpy.context.evaluated_depsgraph_get()
    m = body.evaluated_get(dg).to_mesh()
    p = [body.matrix_world @ v.co for v in m.vertices]
    body.evaluated_get(dg).to_mesh_clear()
    return p

pts = points()
k = HEIGHT_M / (max(p.z for p in pts) - min(p.z for p in pts))
rig.scale = rig.scale * k
bpy.context.view_layer.update()
pts = points()
cx = (min(p.x for p in pts) + max(p.x for p in pts)) / 2
cy = (min(p.y for p in pts) + max(p.y for p in pts)) / 2
rig.location = rig.location - Vector((cx, cy, min(p.z for p in pts)))
bpy.context.view_layer.update()

# Statyczna kopia ciała w pozie (po masce helperów) z grupami wierzchołków.
dg = bpy.context.evaluated_depsgraph_get()
ev = body.evaluated_get(dg)
mesh = bpy.data.meshes.new_from_object(ev, depsgraph=dg)
mesh.transform(body.matrix_world)
gnames = [g.name for g in body.vertex_groups]
dom = []  # dominująca kość (nazwa) na wierzchołek
for v in mesh.vertices:
    best, bw = "", 0.0
    for g in v.groups:
        n = gnames[g.group]
        if n.startswith(("joint-", "helper")) or n in ("Left", "Mid", "Right", "body", "HelperGeometry", "JointCubes"):
            continue
        if g.weight > bw:
            best, bw = n, g.weight
    dom.append(best)
co = [v.co.copy() for v in mesh.vertices]
print("grupy:", sorted(set(dom)))
print("z min/max", min(c.z for c in co), max(c.z for c in co))

mesh.calc_loop_triangles()
mesh.update()
# Normalne wierzchołków (wygładzone) do pompowania.
nrm = [v.normal.copy() for v in mesh.vertices]

# Front: y najmniejsze (kamera patrzy z -y); środek klatki piersiowej.
FRONT = -1.0


def zone_of(i):
    n, c = dom[i], co[i]
    z = c.z
    if n.startswith(("toe", "foot")):
        return "boty"
    if n.startswith("lowerleg"):
        return "boty" if z < 0.23 else "spodnie"
    if n.startswith("upperleg"):
        return "spodnie"
    if n.startswith(("upperarm", "lowerarm", "shoulder", "clavicle")):
        return "kurtka"
    if n.startswith(("wrist", "finger", "metacarpal")):
        return "skora"
    if n.startswith(("spine", "pelvis", "root", "breast")) or n == "":
        if z < 0.86:
            return "spodnie"
        return "tors"
    if n.startswith("neck"):
        return "szyja"
    if z < 0.86:
        return "spodnie"
    if z < 1.53 and n not in ("head", "jaw", "ears"):
        return "tors"  # mięśnie obręczy barkowej, sutki itp.
    return "glowa"


zone = [zone_of(i) for i in range(len(co))]
from collections import Counter
print("strefy:", Counter(zone))

SKIN = (0.72, 0.55, 0.45)
COL = {
    "skora": SKIN,
    "glowa": SKIN,
    "szyja": SKIN,
    "kurtka": (0.075, 0.105, 0.20),
    "spodnie": (0.18, 0.18, 0.20),
    "boty": (0.30, 0.15, 0.07),
    "sweter": (0.55, 0.57, 0.60),
    "szalik": (0.33, 0.10, 0.08),
    "wlosy": (0.07, 0.07, 0.08),
    "broda": (0.45, 0.45, 0.46),
}
mats = {}
for name, c in COL.items():
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*c, 1.0)
    mats[name] = m


def shell(name, pred, thick, mat, frac=1.0, smooth=0):
    """Kopia ścian, których wszystkie wierzchołki spełniają pred(i); wierzchołki przesunięte po normalnej."""
    bm = bmesh.new()
    vmap = {}
    for p in mesh.polygons:
        if sum(1 for i in p.vertices if pred(i)) >= max(1, math.ceil(frac * len(p.vertices))):
            vs = []
            for i in p.vertices:
                if i not in vmap:
                    t = thick(i) if callable(thick) else thick
                    vmap[i] = bm.verts.new(co[i] + nrm[i] * t)
                vs.append(vmap[i])
            try:
                bm.faces.new(vs)
            except ValueError:
                pass
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob)
    me.materials.append(mat)
    for p in me.polygons:
        p.use_smooth = True
    if smooth:
        sm = ob.modifiers.new("gladko", "SMOOTH")
        sm.factor = 0.8
        sm.iterations = smooth
    return ob


# Ciało: skóra (głowa, szyja, dłonie); reszta ukryta pod ubraniem, ale zostaje, żeby nie było dziur.
body_me = bpy.data.meshes.new("cialo")
body_me.from_pydata([tuple(c) for c in co], [], [tuple(p.vertices) for p in mesh.polygons])
body_ob = bpy.data.objects.new("cialo", body_me)
bpy.context.scene.collection.objects.link(body_ob)
body_me.materials.append(mats["glowa"])
for p in body_me.polygons:
    p.use_smooth = True

front_y = min(c.y for i, c in enumerate(co) if zone[i] == "tors" and abs(c.x) < 0.05)
print("front_y", front_y)

# Kurtka: tors do bioder + rękawy; z przodu środek (otwarty zamek) zostawiony na sweter.
def in_open(i):
    c = co[i]
    return zone[i] == "tors" and c.z > 0.93 and abs(c.x) < 0.075 and c.y < (front_y + 0.12)


def jacket_thick(i):
    return 0.042 if zone[i] == "tors" else 0.032


def trunk(i):
    return zone[i] == "tors" or (zone[i] == "spodnie" and (co[i].z > 0.84 or not dom[i].startswith(("upperleg", "lowerleg"))))


shell("kurtka", lambda i: (zone[i] == "kurtka" or trunk(i)) and not in_open(i) and co[i].z > 0.91, jacket_thick, mats["kurtka"], frac=0.6, smooth=6)
shell("sweter", lambda i: trunk(i) and co[i].z > 0.88, 0.020, mats["sweter"], frac=0.6)
shell("spodnie", lambda i: zone[i] == "spodnie" or (zone[i] == "boty" and co[i].z > 0.15 and dom[i].startswith("lowerleg")),
      lambda i: 0.024 if co[i].z > 0.5 else 0.018, mats["spodnie"])
bo = shell("boty", lambda i: zone[i] == "boty", lambda i: 0.034 if co[i].z > 0.08 else 0.040, mats["boty"], smooth=8)
# Kołnierz kurtki + szalik wokół szyi: pasek szyi napompowany.
neck_zs = [c.z for i, c in enumerate(co) if zone[i] == "szyja"]
nz0, nz1 = min(neck_zs), max(neck_zs)
print("szyja z", nz0, nz1)
shell("szalik_szyja", lambda i: zone[i] == "szyja" or (zone[i] == "tors" and co[i].z > nz0 - 0.07 and co[i].y < front_y + 0.2),
      0.046, mats["szalik"])
# Kołnierz kurtki stojący


# Wiszące końce szalika: dwa płaskie pudełka na piersi.
tors_front = [c for i, c in enumerate(co) if zone[i] == "tors"]
neck_c = Vector((0, front_y, nz0))
for sx in (-1, 1):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    me = bpy.data.meshes.new("koniec")
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new("szalik_koniec", me)
    bpy.context.scene.collection.objects.link(ob)
    ob.scale = (0.065, 0.018, 0.40)
    ob.location = Vector((sx * 0.065, front_y - 0.012, nz0 - 0.20))
    ob.rotation_euler = (0, math.radians(sx * -4), 0)
    me.materials.append(mats["szalik"])

# Włosy: grupa 'scalp' (czapka) lub górna część głowy; broda: dolna przednia część twarzy.
head_idx = [i for i in range(len(co)) if zone[i] == "glowa"]
hz = [co[i].z for i in head_idx]
hz0, hz1 = min(hz), max(hz)
hy = [co[i].y for i in head_idx]
print("glowa z", hz0, hz1)
HH = hz1 - hz0
hcy = (min(hy) + max(hy)) / 2


def is_hair(i):
    if zone[i] != "glowa":
        return False
    c = co[i]
    t = (c.z - hz0) / HH
    # góra głowy + boki i tył aż do linii uszu; z przodu tylko nad czołem
    if t > 0.86:
        return True
    if t > 0.62 and c.y > hcy:
        return True
    if t > 0.66 and dom[i] != "ears":
        return abs(c.x) > 0.055 or c.y > hcy
    return False


def is_beard(i):
    if zone[i] != "glowa":
        return False
    c = co[i]
    t = (c.z - hz0) / HH
    return t < 0.29 and c.y < hcy - 0.015 and t > 0.06 and dom[i] != "ears"


shell("wlosy", is_hair, 0.018, mats["wlosy"])
shell("broda", is_beard, 0.012, mats["broda"])

# Scena i kamera (jak w postac_mpfb.py).
scene = bpy.context.scene
cam_data = bpy.data.cameras.new("cam")
cam_data.type = "ORTHO"
cam = bpy.data.objects.new("cam", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam
cam.rotation_euler = (math.pi / 2 - THETA, 0, 0)
view = cam.rotation_euler.to_matrix()
fwd = -view.col[2]
cam.location = Vector((0, 0, HEIGHT_M / 2)) - fwd * 20
cam_data.ortho_scale = CANVAS / PPM
cam_data.sensor_fit = "HORIZONTAL"
cam_data.clip_end = 100
scene.render.resolution_x = CANVAS
scene.render.resolution_y = round(CANVAS_H * math.cos(THETA))
scene.render.image_settings.file_format = "PNG"
scene.render.image_settings.color_mode = "RGBA"
scene.view_settings.view_transform = "Standard"
scene.render.engine = "BLENDER_WORKBENCH"
sh = scene.display.shading
sh.light = "STUDIO"
sh.color_type = "MATERIAL"
sh.show_object_outline = True
sh.object_outline_color = (0.02, 0.02, 0.03)
sh.show_cavity = True
sh.cavity_type = "BOTH"
sh.cavity_ridge_factor = 0.6
sh.cavity_valley_factor = 1.0
scene.display.render_aa = "8"
world = bpy.data.worlds.new("tlo")
scene.world = world
world.color = (0.62, 0.64, 0.67)
rig.hide_render = True
body.hide_render = True

root_objs = [o for o in scene.objects if o.type == "MESH" and o is not body]
pivot = bpy.data.objects.new("pivot", None)
scene.collection.objects.link(pivot)
for o in root_objs:
    o.parent = pivot


def stretch(path):
    img = bpy.data.images.load(path)
    w, h = img.size
    img.scale(w, round(h / math.cos(THETA)))
    img.filepath_raw = path
    img.save()
    bpy.data.images.remove(img)


for name in VIEWS:
    deg = {"przod": 0, "bok": 90, "tyl": 180}[name]
    pivot.rotation_euler = (0, 0, math.radians(deg))
    bpy.context.view_layer.update()
    for bg in (True, False):
        scene.render.film_transparent = not bg
        sh.background_type = "WORLD" if bg else "WORLD"
        path = os.path.join(OUT, f"ubrana_{name}{'' if bg else '_alfa'}.png")
        scene.render.filepath = path
        bpy.ops.render.render(write_still=True)
        stretch(path)
        print("render", path)
print("gotowe", OUT)
