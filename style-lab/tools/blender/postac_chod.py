# PROTOTYP (ticket „Przepis postaci”): klatki chodu manekina MPFB2 w rzucie gry, jako wzór pozy
# dla Qwen-Image-Edit (postać z konceptu przyjmuje pozę manekina). Człowiek i kamera jak w postac_mpfb.py.
# Chód proceduralny: uda, łydki, ramiona i przedramiona obracane wokół osi bocznej (świat x).
#
#   blender -b -P tools/blender/postac_chod.py -- --df 0.6 --ppm 400 --canvas 1024 --out shots/chod_060
#       [--frames 8] [--views bok,przod,tyl]
#
# Wynik: chod_<widok>_<i>.png na jasnoszarym tle, postać 1,8 m, stopy na ziemi w każdej klatce.
import bpy
import math
import os
import sys
from mathutils import Matrix, Vector

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
args = {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv) - 1, 2)}
DF = float(args.get("df", "0.6"))
PPM = int(args.get("ppm", "400"))
CANVAS = int(args.get("canvas", "1024"))
OUT = os.path.abspath(args.get("out", "shots/chod"))
FRAMES = int(args.get("frames", "8"))
VIEWS = args.get("views", "bok,przod,tyl").split(",")
ARMS = math.radians(float(args.get("arms", "28")))
HEIGHT_M = 1.8
THETA = math.atan(DF)
# Amplitudy chodu (stopnie).
THIGH = float(args.get("thigh", "24"))
KNEE = float(args.get("knee", "42"))
ARM = float(args.get("arm", "18"))
ELBOW = float(args.get("elbow", "14"))
ELBOW_REST = float(args.get("elbow-rest", "0"))  # MPFB ma w spoczynku przedramiona wysunięte do przodu
os.makedirs(OUT, exist_ok=True)

from bl_ext.blender_org.mpfb.services.humanservice import HumanService  # noqa: E402
from bl_ext.blender_org.mpfb.services.targetservice import TargetService  # noqa: E402

for ob in list(bpy.data.objects):
    bpy.data.objects.remove(ob)

macro = TargetService.get_default_macro_info_dict()
macro.update({"gender": 1.0, "age": 0.6, "muscle": 0.55, "weight": 0.5, "proportions": 0.8,
              "height": 0.7, "race": {"asian": 0.0, "caucasian": 1.0, "african": 0.0}})
body = HumanService.create_human(macro_detail_dict=macro)
rig = HumanService.add_builtin_rig(body, "default")
bpy.context.view_layer.update()
print("kości:", [b.name for b in rig.pose.bones if any(s in b.name for s in ("leg", "arm", "foot"))])


def world_axis(v):
    return (rig.matrix_world.inverted().to_3x3() @ Vector(v)).normalized()


def turn(name, deg, axis):
    pb = rig.pose.bones.get(name)
    if pb is None:
        print("brak kości", name)
        return
    head = pb.matrix.translation.copy()
    m = Matrix.Translation(head) @ Matrix.Rotation(math.radians(deg), 4, axis) @ Matrix.Translation(-head)
    pb.matrix = m @ pb.matrix
    bpy.context.view_layer.update()


def points():
    dg = bpy.context.evaluated_depsgraph_get()
    mesh = body.evaluated_get(dg).to_mesh()
    pts = [body.matrix_world @ v.co for v in mesh.vertices]
    body.evaluated_get(dg).to_mesh_clear()
    return pts


bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode="POSE")
# Skala do 1,8 m w pozie spoczynkowej.
pts = points()
k = HEIGHT_M / (max(p.z for p in pts) - min(p.z for p in pts))
rig.scale = rig.scale * k
bpy.context.view_layer.update()
pts = points()
base = Vector(((min(p.x for p in pts) + max(p.x for p in pts)) / 2,
               (min(p.y for p in pts) + max(p.y for p in pts)) / 2, 0))
rig.location = rig.location - base


def pose(phase):
    """Faza 0..1. Przód postaci to -y; obrót o kąt dodatni wokół +x przesuwa dół kości do tyłu (+y)."""
    for pb in rig.pose.bones:
        pb.matrix_basis = Matrix.Identity(4)
    bpy.context.view_layer.update()
    side = world_axis((1, 0, 0))
    depth = world_axis((0, 1, 0))
    for name, sign in (("upperarm01.L", 1.0), ("upperarm01.R", -1.0)):
        turn(name, math.degrees(sign * ARMS), depth)
    p = phase * math.tau
    for leg, q in (("L", p), ("R", p + math.pi)):
        thigh = -THIGH * math.sin(q)  # ujemny = noga do przodu
        knee = 4.0 + KNEE * max(0.0, math.cos(q)) ** 1.5  # zgięcie w fazie przenoszenia
        turn(f"upperleg01.{leg}", thigh, side)
        turn(f"lowerleg01.{leg}", knee, side)
        turn(f"foot.{leg}", -knee * 0.35, side)
        swing = ARM * math.sin(q)  # ramię naprzeciw nogi: noga L do przodu → ramię L do tyłu
        turn(f"upperarm01.{leg}", swing, side)
        turn(f"lowerarm01.{leg}", ELBOW_REST - ELBOW * (0.6 + 0.4 * max(0.0, -math.sin(q))), side)
    # Stopy na ziemi.
    pts = points()
    rig.location.z -= min(pt.z for pt in pts)
    bpy.context.view_layer.update()


scene = bpy.context.scene
cam_data = bpy.data.cameras.new("cam")
cam_data.type = "ORTHO"
cam = bpy.data.objects.new("cam", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam
cam.rotation_euler = (math.pi / 2 - THETA, 0, 0)
fwd = -cam.rotation_euler.to_matrix().col[2]
cam.location = Vector((0, 0, HEIGHT_M / 2)) - fwd * 20
cam_data.ortho_scale = CANVAS / PPM
cam_data.clip_end = 100
scene.render.resolution_x = CANVAS
scene.render.resolution_y = round(CANVAS * math.cos(THETA))
scene.render.image_settings.file_format = "PNG"
scene.view_settings.view_transform = "Standard"
scene.render.engine = "BLENDER_WORKBENCH"
shading = scene.display.shading
shading.light = "STUDIO"
shading.color_type = "SINGLE"
shading.single_color = (0.6, 0.6, 0.6)
shading.show_object_outline = True
shading.object_outline_color = (0.05, 0.05, 0.05)
shading.show_cavity = True
shading.background_type = "WORLD"
world = bpy.data.worlds.new("tlo")
scene.world = world
world.color = (0.72, 0.73, 0.75)
rig.hide_render = True

YAW = {"przod": 0, "bok": 90, "bokL": -90, "tyl": 180}
for i in range(FRAMES):
    pose(i / FRAMES)
    for view in VIEWS:
        rig.rotation_euler = (rig.rotation_euler.x, rig.rotation_euler.y, math.radians(YAW[view]))
        bpy.context.view_layer.update()
        path = os.path.join(OUT, f"chod_{view}_{i}.png")
        scene.render.filepath = path
        bpy.ops.render.render(write_still=True)
        img = bpy.data.images.load(path)
        w, h = img.size
        img.scale(w, round(h / math.cos(THETA)))
        img.filepath_raw = path
        img.save()
        bpy.data.images.remove(img)
    rig.rotation_euler = (rig.rotation_euler.x, rig.rotation_euler.y, 0)
    print("klatka", i)
print("gotowe:", OUT)
