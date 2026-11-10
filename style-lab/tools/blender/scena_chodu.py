# PROTOTYP (ticket „Przepis postaci”): scena w Blenderze (z interfejsem) do oglądania chodu z mocapu
# na manekinie MPFB z kolorowymi strefami ubrania, w kamerze gry (ortho, kąt atan(0,60), kadr 72 px postaci).
#   blender -P tools/blender/scena_chodu.py -- [--bvh tools/mocap/cmu] [--df 0.6]
# Panel: widok 3D → N → zakładka „Chód”: wybór nagrania (każde BVH z katalogu), kierunek kamery, start/stop.
# Retarget: kości MPFB celują (Damped Track) w stawy szkieletu z BVH, więc pozy spoczynkowe nie muszą się zgadzać.
import bpy
import glob
import math
import os
import sys
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
args = {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv) - 1, 2)}
BVH_DIR = os.path.abspath(args.get("bvh", "tools/mocap/cmu"))
DF = float(args.get("df", "0.6"))
HEIGHT_M = 1.8

ZONES = {  # strefa: (kolor, fragmenty nazw grup wierzchołków)
    "Kurtka": ((0.075, 0.09, 0.14), ("upperarm", "lowerarm", "clavicle", "shoulder", "spine", "breast")),
    "Spodnie": ((0.2, 0.21, 0.23), ("pelvis", "upperleg", "lowerleg", "root")),
    "Buty": ((0.3, 0.18, 0.11), ("foot", "toe")),
    "Skora": ((0.78, 0.6, 0.5), ("wrist", "finger", "thumb", "metacarpal", "neck", "head", "jaw", "eye", "oculi",
                                 "tongue", "levator", "oris", "temporalis", "risorius", "special", "orbicularis")),
}
# kość MPFB → kość BVH, której POCZĄTEK (staw) jest celem (końce kości BVH importer ustawia umownie)
TRACK = {
    "spine05": "Spine", "spine03": "Spine1", "spine01": "Neck", "neck01": "Head",
    "clavicle.L": "LeftArm", "upperarm01.L": "LeftForeArm", "lowerarm01.L": "LeftHand", "wrist.L": "LeftFingerBase",
    "clavicle.R": "RightArm", "upperarm01.R": "RightForeArm", "lowerarm01.R": "RightHand", "wrist.R": "RightFingerBase",
    "upperleg01.L": "LeftLeg", "lowerleg01.L": "LeftFoot", "foot.L": "LeftToeBase",
    "upperleg01.R": "RightLeg", "lowerleg01.R": "RightFoot", "foot.R": "RightToeBase",
}

from bl_ext.blender_org.mpfb.services.humanservice import HumanService  # noqa: E402
from bl_ext.blender_org.mpfb.services.targetservice import TargetService  # noqa: E402

for ob in list(bpy.data.objects):
    bpy.data.objects.remove(ob)
scene = bpy.context.scene

# --- manekin ---
macro = TargetService.get_default_macro_info_dict()
macro.update({"gender": 1.0, "age": 0.6, "muscle": 0.55, "weight": 0.5, "proportions": 0.8,
              "height": 0.7, "race": {"asian": 0.0, "caucasian": 1.0, "african": 0.0}})
body = HumanService.create_human(macro_detail_dict=macro)
rig = HumanService.add_builtin_rig(body, "default")
rig.name = "Postac"
body.name = "Postac_cialo"
bpy.context.view_layer.update()
dg = bpy.context.evaluated_depsgraph_get()
zs = [(body.matrix_world @ v.co).z for v in body.evaluated_get(dg).data.vertices]
k = HEIGHT_M / (max(zs) - min(zs))
rig.scale = rig.scale * k
bpy.context.view_layer.update()

# strefy kolorów wg dominującej grupy wierzchołków
mats = {}
for name, (col, _) in ZONES.items():
    m = bpy.data.materials.new(name)
    m.diffuse_color = (*col, 1.0)
    body.data.materials.append(m)
    mats[name] = len(body.data.materials) - 1
group_zone = {}
bone_names = {b.name for b in rig.data.bones}  # MPFB ma też grupy pomocnicze („body”, „helper-…”): pomijamy
for g in [g for g in body.vertex_groups if g.name in bone_names]:
    for name, (_, keys) in ZONES.items():
        if any(key in g.name for key in keys):
            group_zone[g.index] = name
            break
vzone = []
for v in body.data.vertices:
    best = max((e for e in v.groups if e.group in group_zone), key=lambda e: e.weight, default=None)
    vzone.append(group_zone[best.group] if best else "Skora")
for poly in body.data.polygons:
    votes = {}
    for vi in poly.vertices:
        votes[vzone[vi]] = votes.get(vzone[vi], 0) + 1
    poly.material_index = mats[max(votes, key=votes.get)]

rest_pelvis_z = (rig.matrix_world @ rig.pose.bones["upperleg01.L"].head).z
rest_leg = ((rig.pose.bones["upperleg01.L"].head - rig.pose.bones["foot.L"].head).length * rig.scale.z)

# --- mocap: pierwsze BVH = szkielet „Mocap”, akcje pozostałych przepięte na niego ---
files = sorted(glob.glob(os.path.join(BVH_DIR, "*.bvh")))
moc = None
WALKS = {}  # nazwa akcji → (kąt obrotu wokół z, klatka startu, klatka końca)
for path in files:
    bpy.ops.import_anim.bvh(filepath=path, axis_forward="-Z", axis_up="Y", update_scene_fps=False,
                            update_scene_duration=False)
    arm = bpy.context.active_object
    act = arm.animation_data.action
    act.name = os.path.splitext(os.path.basename(path))[0]
    act.use_fake_user = True
    f0, f1 = (int(x) for x in act.frame_range)
    scene.frame_set(f0)
    a = arm.matrix_world @ arm.pose.bones["Hips"].head
    scene.frame_set(f1)
    b = arm.matrix_world @ arm.pose.bones["Hips"].head
    d = Vector((b.x - a.x, b.y - a.y))
    yaw = -math.pi / 2 - math.atan2(d.y, d.x)  # obrót, po którym marsz idzie w -y (twarzą do kamery)
    WALKS[act.name] = (yaw, f0, f1)
    if moc is None:
        moc = arm
        moc.name = "Mocap"
        leg = (arm.data.bones["LeftUpLeg"].head_local - arm.data.bones["LeftFoot"].head_local).length
        moc.scale = moc.scale * (rest_leg / leg)
    else:
        bpy.data.objects.remove(arm)
moc.show_in_front = True
moc.data.display_type = "STICK"

# --- retarget ---
bpy.context.view_layer.objects.active = rig
bpy.ops.object.mode_set(mode="POSE")
for mb, bb in TRACK.items():
    pb = rig.pose.bones.get(mb)
    if pb is None:
        print("brak kości", mb)
        continue
    c = pb.constraints.new("DAMPED_TRACK")
    c.target = moc
    c.subtarget = bb
    c.head_tail = 0.0
bpy.ops.object.mode_set(mode="OBJECT")
c = rig.constraints.new("COPY_LOCATION")
c.target = moc
c.subtarget = "Hips"
c.use_offset = True
rig.location = (0.0, 0.0, -rest_pelvis_z)

# --- kamera gry ---
THETA = math.atan(DF)
cam = bpy.data.objects.new("Kamera_gry", bpy.data.cameras.new("Kamera_gry"))
scene.collection.objects.link(cam)
cam.data.type = "ORTHO"
cam.data.ortho_scale = 4.0
cam.rotation_euler = (math.pi / 2 - THETA, 0.0, 0.0)
fwd = -cam.rotation_euler.to_matrix().col[2]
cam.location = Vector((0.0, 0.0, 0.9)) - fwd * 20.0
cam.data.clip_end = 100.0
c = cam.constraints.new("COPY_LOCATION")
c.target = moc
c.subtarget = "Hips"
c.use_offset = True
c.use_z = False
scene.camera = cam
scene.render.resolution_x = 160
scene.render.resolution_y = 160
light = bpy.data.objects.new("Slonce", bpy.data.lights.new("Slonce", "SUN"))
scene.collection.objects.link(light)
light.rotation_euler = (math.radians(50), 0.0, math.radians(30))
bpy.ops.mesh.primitive_plane_add(size=200.0, location=(0.0, 0.0, 0.0))
floor = bpy.context.active_object
floor.name = "Podloga"
fm = bpy.data.materials.new("Snieg")
fm.diffuse_color = (0.72, 0.75, 0.8, 1.0)
floor.data.materials.append(fm)
scene.render.fps = 120


def set_walk(name: str, view: str) -> None:
    yaw, f0, f1 = WALKS[name]
    moc.animation_data.action = bpy.data.actions[name]
    extra = {"przod": 0.0, "bok": -90.0, "tyl": 180.0}[view]
    moc.rotation_euler = (moc.rotation_euler.x, moc.rotation_euler.y, yaw + math.radians(extra))
    rig.rotation_euler = (0.0, 0.0, math.radians(extra))  # MPFB patrzy w -y; ten sam obrót co marsz
    scene.frame_start, scene.frame_end = f0, f1
    scene.frame_set(f0)


class CHOD_PG(bpy.types.PropertyGroup):
    walk: bpy.props.EnumProperty(name="Nagranie", items=[(n, n, "") for n in WALKS],
                                 update=lambda s, c: set_walk(s.walk, s.view))
    view: bpy.props.EnumProperty(name="Widok", items=[("bok", "bok (w lewo)", ""), ("przod", "przód (w dół)", ""),
                                                      ("tyl", "tył (w górę)", "")],
                                 update=lambda s, c: set_walk(s.walk, s.view))


class CHOD_PT(bpy.types.Panel):
    bl_label = "Chód (style-lab)"
    bl_space_type = "VIEW_3D"
    bl_region_type = "UI"
    bl_category = "Chód"

    def draw(self, context):
        p = context.scene.chod
        self.layout.prop(p, "walk")
        self.layout.prop(p, "view")
        self.layout.operator("screen.animation_play", text="Start / stop")
        self.layout.label(text="Kamera gry: Numpad 0")


bpy.utils.register_class(CHOD_PG)
bpy.utils.register_class(CHOD_PT)
bpy.types.Scene.chod = bpy.props.PointerProperty(type=CHOD_PG)
first = next(iter(WALKS))
set_walk(first, "bok")


def setup_view():
    for window in bpy.context.window_manager.windows:
        for area in window.screen.areas:
            if area.type == "VIEW_3D":
                space = area.spaces.active
                space.shading.type = "SOLID"
                space.shading.color_type = "MATERIAL"
                space.region_3d.view_perspective = "CAMERA"
                space.show_region_ui = True
    return None


bpy.app.timers.register(setup_view, first_interval=1.0)
print("scena gotowa, nagrania:", list(WALKS))
