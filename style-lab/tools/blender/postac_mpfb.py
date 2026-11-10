# PROTOTYP (ticket „Przepis postaci”): postać z MPFB2 (MakeHuman dla Blendera, wynik CC0) w rzucie gry,
# jako referencja kąta i proporcji dla FLUX.2 klein (ilustracja), potem lokalna pikselizacja.
# Rzut jak w zestaw_testowy.py: kamera ortho pochylona o atan(df), obraz rozciągnięty w pionie o 1/cos.
#
#   blender -b -P tools/blender/postac_mpfb.py -- --df 0.6 --ppm 400 --canvas 1024 --out shots/mpfb_060
#       [--arms 28] [--legs 0] [--gender 1.0 (0 = kobieta)] [--age 0.6] [--muscle 0.55] [--weight 0.5] [--proportions 0.8]
#
# Wynik: postac_{przod,bok,tyl}.png (szara bryła z konturem, alfa), postać 1,8 m = 1,8 × ppm px.
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
OUT = os.path.abspath(args.get("out", "shots/mpfb"))
ARMS = math.radians(float(args.get("arms", "28")))  # dodatkowe opuszczenie ramion z A-pozy MPFB (~50° w dół)
HEIGHT_M = 1.8
THETA = math.atan(DF)
os.makedirs(OUT, exist_ok=True)

from bl_ext.blender_org.mpfb.services.humanservice import HumanService  # noqa: E402
from bl_ext.blender_org.mpfb.services.targetservice import TargetService  # noqa: E402

for ob in list(bpy.data.objects):
    bpy.data.objects.remove(ob)

macro = TargetService.get_default_macro_info_dict()
macro.update({"gender": float(args.get("gender", "1.0")), "age": float(args.get("age", "0.6")), "muscle": float(args.get("muscle", "0.55")),
              "weight": float(args.get("weight", "0.5")), "proportions": float(args.get("proportions", "0.8")),
              "height": 0.7, "race": {"asian": 0.0, "caucasian": 1.0, "african": 0.0}})
body = HumanService.create_human(macro_detail_dict=macro)
rig = HumanService.add_builtin_rig(body, "default")
bpy.context.view_layer.update()

# Ramiona w dół: obrót kości ramienia wokół osi patrzenia (+y w głąb) w przestrzeni szkieletu.
bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode="POSE")
for name, sign in (("upperarm01.L", 1.0), ("upperarm01.R", -1.0)):
    pb = rig.pose.bones.get(name)
    if pb is None:
        print("brak kości", name)
        continue
    head = pb.matrix.translation.copy()
    # Oś głębi świata (+y) w przestrzeni szkieletu (szkielet MPFB bywa obrócony względem świata).
    axis = (rig.matrix_world.inverted().to_3x3() @ Vector((0, 1, 0))).normalized()
    turn = Matrix.Translation(head) @ Matrix.Rotation(sign * ARMS, 4, axis) @ Matrix.Translation(-head)
    pb.matrix = turn @ pb.matrix
    bpy.context.view_layer.update()
# Nogi do środka (--legs, stopnie): prosto w dół zamiast lekkiego rozkroku spoczynkowego MPFB.
LEGS = math.radians(float(args.get("legs", "0")))
for name, sign in (("upperleg01.L", 1.0), ("upperleg01.R", -1.0)):
    pb = rig.pose.bones.get(name)
    if pb is None or LEGS == 0:
        continue
    head = pb.matrix.translation.copy()
    axis = (rig.matrix_world.inverted().to_3x3() @ Vector((0, 1, 0))).normalized()
    pb.matrix = Matrix.Translation(head) @ Matrix.Rotation(sign * LEGS, 4, axis) @ Matrix.Translation(-head) @ pb.matrix
    bpy.context.view_layer.update()
bpy.ops.object.mode_set(mode="OBJECT")

# Skala do dokładnie 1,8 m (stopy na ziemi), środek stóp w (0, 0).
bpy.context.view_layer.update()
dg = bpy.context.evaluated_depsgraph_get()
mesh = body.evaluated_get(dg).to_mesh()
pts = [body.matrix_world @ v.co for v in mesh.vertices]
body.evaluated_get(dg).to_mesh_clear()
zmin, zmax = min(p.z for p in pts), max(p.z for p in pts)
k = HEIGHT_M / (zmax - zmin)
root = rig if rig is not None else body
root.scale = root.scale * k
bpy.context.view_layer.update()
dg = bpy.context.evaluated_depsgraph_get()
mesh = body.evaluated_get(dg).to_mesh()
pts = [body.matrix_world @ v.co for v in mesh.vertices]
body.evaluated_get(dg).to_mesh_clear()
cx = (min(p.x for p in pts) + max(p.x for p in pts)) / 2
cy = (min(p.y for p in pts) + max(p.y for p in pts)) / 2
root.location = root.location - Vector((cx, cy, min(p.z for p in pts)))
bpy.context.view_layer.update()
print("wzrost", round(HEIGHT_M, 3), "skala", round(k, 4))

scene = bpy.context.scene
cam_data = bpy.data.cameras.new("cam")
cam_data.type = "ORTHO"
cam = bpy.data.objects.new("cam", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam
cam.rotation_euler = (math.pi / 2 - THETA, 0, 0)
view = cam.rotation_euler.to_matrix()
up, fwd = view.col[1], -view.col[2]
# Kadr CANVAS×CANVAS po rozciągnięciu; środek postaci (0,9 m nad ziemią) na środku.
cam.location = Vector((0, 0, HEIGHT_M / 2)) - fwd * 20
cam_data.ortho_scale = CANVAS / PPM
cam_data.sensor_fit = "HORIZONTAL"
cam_data.clip_end = 100
scene.render.resolution_x = CANVAS
scene.render.resolution_y = round(CANVAS * math.cos(THETA))
scene.render.film_transparent = True
scene.render.image_settings.file_format = "PNG"
scene.render.image_settings.color_mode = "RGBA"
scene.view_settings.view_transform = "Standard"
scene.render.engine = "BLENDER_WORKBENCH"
shading = scene.display.shading
shading.light = "STUDIO"
shading.color_type = "SINGLE"
shading.single_color = (0.6, 0.6, 0.6)
shading.show_object_outline = True
shading.object_outline_color = (0.05, 0.05, 0.05)
shading.show_cavity = True
# Szkielet niewidoczny w renderze.
rig.hide_render = True

for name, deg in (("przod", 0), ("bok", 90), ("tyl", 180)):
    root.rotation_euler = (0, 0, math.radians(deg))
    bpy.context.view_layer.update()
    path = os.path.join(OUT, f"postac_{name}.png")
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    img = bpy.data.images.load(path)
    w, h = img.size
    img.scale(w, round(h / math.cos(THETA)))
    img.filepath_raw = path
    img.save()
    bpy.data.images.remove(img)
    print("render", path)


def stretch(path):
    img = bpy.data.images.load(path)
    w, h = img.size
    img.scale(w, round(h / math.cos(THETA)))
    img.filepath_raw = path
    img.save()
    bpy.data.images.remove(img)


# Przód na jasnoszarym tle (wejście img2img) i mapa głębi (ControlNet depth: bliżej jaśniej, tło czarne).
root.rotation_euler = (0, 0, 0)
bpy.context.view_layer.update()
world = bpy.data.worlds.new("tlo")
scene.world = world
world.color = (0.62, 0.64, 0.67)
scene.render.film_transparent = False
shading.background_type = "WORLD"
path = os.path.join(OUT, "postac_przod_tlo.png")
scene.render.filepath = path
bpy.ops.render.render(write_still=True)
stretch(path)

dg = bpy.context.evaluated_depsgraph_get()
mesh = body.evaluated_get(dg).to_mesh()
depths = [(body.matrix_world @ v.co).dot(fwd) for v in mesh.vertices]
body.evaluated_get(dg).to_mesh_clear()
scene.render.engine = "BLENDER_EEVEE"
mat = bpy.data.materials.new("depth")
mat.use_nodes = True
nodes, links = mat.node_tree.nodes, mat.node_tree.links
nodes.clear()
geo = nodes.new("ShaderNodeNewGeometry")
dot = nodes.new("ShaderNodeVectorMath")
dot.operation = "DOT_PRODUCT"
dot.inputs[1].default_value = fwd
rng = nodes.new("ShaderNodeMapRange")
rng.inputs["From Min"].default_value = min(depths)
rng.inputs["From Max"].default_value = max(depths)
rng.inputs["To Min"].default_value = 1.0
rng.inputs["To Max"].default_value = 0.15
emit = nodes.new("ShaderNodeEmission")
out = nodes.new("ShaderNodeOutputMaterial")
links.new(geo.outputs["Position"], dot.inputs[0])
links.new(dot.outputs["Value"], rng.inputs["Value"])
links.new(rng.outputs["Result"], emit.inputs["Color"])
links.new(emit.outputs["Emission"], out.inputs["Surface"])
body.data.materials.clear()
body.data.materials.append(mat)
for slot in body.material_slots:
    slot.material = mat
world.use_nodes = True
bg_nodes = [n for n in world.node_tree.nodes if n.type == "BACKGROUND"]
bg = bg_nodes[0] if bg_nodes else world.node_tree.nodes.new("ShaderNodeBackground")
bg.inputs["Color"].default_value = (0, 0, 0, 1)
bg.inputs["Strength"].default_value = 0.0
world.color = (0, 0, 0)
path = os.path.join(OUT, "postac_przod_depth.png")
scene.render.filepath = path
bpy.ops.render.render(write_still=True)
stretch(path)
print("render", path)
print("gotowe:", OUT, "df", DF, "theta", round(math.degrees(THETA), 1))
