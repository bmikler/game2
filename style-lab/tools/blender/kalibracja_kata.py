# PROTOTYP (ticket „Przepis postaci”): kalibracja pomiaru kąta kamery na obrazach postaci.
# Manekin MPFB (jak postac_mpfb.py) z prostymi brązowymi butami (prostopadłościany na stopach),
# renderowany w rzucie gry dla wielu kątów. tools/postac/kat.gd mierzy na tych renderach wysokość
# butów względem wzrostu; ta sama miara na obrazach z generatora daje ich kąt (interpolacja).
#
#   blender -b -P tools/blender/kalibracja_kata.py -- --out shots/kalibracja [--from 0.3 --to 0.8 --step 0.05]
#
# Wynik: <out>/<widok>_<df*100>.png (przod, bok, tyl), alfa, buty brązowe, ciało szare.
import bpy
import math
import os
import sys
from mathutils import Matrix, Vector

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
args = {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv) - 1, 2)}
OUT = os.path.abspath(args.get("out", "shots/kalibracja"))
DF_FROM = float(args.get("from", "0.3"))
DF_TO = float(args.get("to", "0.8"))
DF_STEP = float(args.get("step", "0.05"))
PPM = 400
CANVAS = 1024
HEIGHT_M = 1.8
ARMS = math.radians(28)
BOOT_H = 0.13  # wysokość cholewki buta (m)
BOOT_PAD = 0.012  # but szerszy od stopy o tyle z każdej strony (m)
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

bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode="POSE")
for name, sign in (("upperarm01.L", 1.0), ("upperarm01.R", -1.0)):
    pb = rig.pose.bones.get(name)
    head = pb.matrix.translation.copy()
    axis = (rig.matrix_world.inverted().to_3x3() @ Vector((0, 1, 0))).normalized()
    pb.matrix = Matrix.Translation(head) @ Matrix.Rotation(sign * ARMS, 4, axis) @ Matrix.Translation(-head) @ pb.matrix
    bpy.context.view_layer.update()
bpy.ops.object.mode_set(mode="OBJECT")


def points():
    dg = bpy.context.evaluated_depsgraph_get()
    mesh = body.evaluated_get(dg).to_mesh()
    pts = [body.matrix_world @ v.co for v in mesh.vertices]
    body.evaluated_get(dg).to_mesh_clear()
    return pts


pts = points()
k = HEIGHT_M / (max(p.z for p in pts) - min(p.z for p in pts))
rig.scale = rig.scale * k
bpy.context.view_layer.update()
pts = points()
rig.location = rig.location - Vector(((min(p.x for p in pts) + max(p.x for p in pts)) / 2,
                                      (min(p.y for p in pts) + max(p.y for p in pts)) / 2, min(p.z for p in pts)))
bpy.context.view_layer.update()

# Buty: prostopadłościan wokół stóp (wierzchołki poniżej 8 cm), każda strona osobno.
pts = points()
grey = bpy.data.materials.new("cialo")
grey.diffuse_color = (0.6, 0.6, 0.6, 1)
brown = bpy.data.materials.new("but")
brown.diffuse_color = (0.42, 0.2, 0.08, 1)
body.data.materials.clear()
body.data.materials.append(grey)
for side in (1, -1):
    foot = [p for p in pts if p.z < 0.08 and p.x * side > 0]
    x0, x1 = min(p.x for p in foot) - BOOT_PAD, max(p.x for p in foot) + BOOT_PAD
    y0, y1 = min(p.y for p in foot) - BOOT_PAD, max(p.y for p in foot) + BOOT_PAD
    bpy.ops.mesh.primitive_cube_add(size=1, location=((x0 + x1) / 2, (y0 + y1) / 2, BOOT_H / 2))
    boot = bpy.context.active_object
    boot.scale = (x1 - x0, y1 - y0, BOOT_H)
    boot.data.materials.append(brown)
    boot.parent = rig
    boot.matrix_parent_inverse = rig.matrix_world.inverted()
    print("but", side, "dł.", round(y1 - y0, 3), "szer.", round(x1 - x0, 3))

scene = bpy.context.scene
cam_data = bpy.data.cameras.new("cam")
cam_data.type = "ORTHO"
cam = bpy.data.objects.new("cam", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam
cam_data.ortho_scale = CANVAS / PPM
cam_data.clip_end = 100
scene.render.resolution_x = CANVAS
scene.render.film_transparent = True
scene.render.image_settings.file_format = "PNG"
scene.render.image_settings.color_mode = "RGBA"
scene.view_settings.view_transform = "Standard"
scene.render.engine = "BLENDER_WORKBENCH"
shading = scene.display.shading
shading.light = "FLAT"
shading.color_type = "MATERIAL"
rig.hide_render = True

YAW = {"przod": 0, "bok": -90, "tyl": 180}  # bok patrzy w lewo, jak profile z generatora
n = int(round((DF_TO - DF_FROM) / DF_STEP)) + 1
for i in range(n):
    df = DF_FROM + i * DF_STEP
    theta = math.atan(df)
    cam.rotation_euler = (math.pi / 2 - theta, 0, 0)
    fwd = -cam.rotation_euler.to_matrix().col[2]
    cam.location = Vector((0, 0, HEIGHT_M / 2)) - fwd * 20
    scene.render.resolution_y = round(CANVAS * math.cos(theta))
    for view, yaw in YAW.items():
        rig.rotation_euler = (rig.rotation_euler.x, rig.rotation_euler.y, math.radians(yaw))
        bpy.context.view_layer.update()
        path = os.path.join(OUT, f"{view}_{round(df * 100):03d}.png")
        scene.render.filepath = path
        bpy.ops.render.render(write_still=True)
        img = bpy.data.images.load(path)
        w, h = img.size
        img.scale(w, round(h / math.cos(theta)))
        img.filepath_raw = path
        img.save()
        bpy.data.images.remove(img)
    print("kąt", round(df, 2))
print("gotowe:", OUT)
