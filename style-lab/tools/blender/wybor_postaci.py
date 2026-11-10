# PROTOTYP (ticket „Przepis postaci”): scena w Blenderze Z INTERFEJSEM do ręcznego wyboru postaci, ubrań i chodu.
#   "C:/Program Files/Blender Foundation/Blender 5.2/blender.exe" -P tools/blender/wybor_postaci.py -- [--df 0.6]
#
# Startuje z mężczyzną MPFB z rigiem „CMU MB” (nazwy kości jak w BVH z CMU). Człowiek w GUI:
#   * postać: panel MPFB (N → MPFB → Model / Apply assets → Library: skóra, oczy, brwi, włosy, broda, ubrania),
#   * chód: N → zakładka „Chód”: lista nagrań z tools/mocap/cmu, „Wczytaj chód”, widok kamery gry przód/bok/tył,
#   * „Zapisz wybór” → proby/postac3d/wybor.blend (wejście dla następnych kroków: projekcja, render, pikselizacja).
# Przeniesienie ruchu: obrót każdej kości względem jej pozy spoczynkowej w BVH (T-poza), nałożony na kość MPFB
# wyprostowaną wcześniej do kierunków T-pozy BVH; biodra: wysokość skalowana do wzrostu, opcjonalnie chód w miejscu.
import bpy
import math
import os
import sys
from mathutils import Matrix, Quaternion, Vector

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
args = {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv) - 1, 2)}
DF = float(args.get("df", "0.6"))
THETA = math.atan(DF)
ROOT_DIR = os.getcwd()
BVH_DIR = os.path.join(ROOT_DIR, "tools", "mocap", "cmu")
SAVE_PATH = os.path.join(ROOT_DIR, "proby", "postac3d", "wybor.blend")
SAMPLE_STEP = 4  # BVH z CMU ma 120 kl./s; co 4. klatka = 30 kl./s

CLIPS = {  # opisy z indeksu CMU (cmu-mocap-index-text.txt)
    "02_01": "walk", "07_01": "walk", "07_04": "slow walk", "07_12": "brisk walk",
    "08_01": "walk", "08_04": "slow walk", "08_05": "walk/stride", "16_15": "walk",
    "17_01": "walk with anger, frustration", "17_08": "muscular, heavyset person's walk",
    "35_01": "walk", "37_01": "slow walk", "77_02": "standing", "81_04": "walk at a brisk pace",
    "82_08": "stand still; casual walk forward", "82_09": "confident walk forward", "82_10": "sad walk forward",
    "91_10": "SlowWalk", "91_13": "SadWalk", "91_14": "DepressedWalk", "91_22": "CasualQuickWalk",
    "91_23": "CoolWalk", "93_07": "Casual Walk", "104_19": "CasualWalk",
}
# kość → dziecko wyznaczające kierunek kości (staw do stawu), wspólne dla BVH i rigu CMU MB
DIR_CHILD = {
    "Hips": "LowerBack", "LowerBack": "Spine", "Spine": "Spine1", "Spine1": "Neck", "Neck": "Neck1", "Neck1": "Head",
    "LHipJoint": "LeftUpLeg", "LeftUpLeg": "LeftLeg", "LeftLeg": "LeftFoot", "LeftFoot": "LeftToeBase",
    "RHipJoint": "RightUpLeg", "RightUpLeg": "RightLeg", "RightLeg": "RightFoot", "RightFoot": "RightToeBase",
    "LeftShoulder": "LeftArm", "LeftArm": "LeftForeArm", "LeftForeArm": "LeftHand", "LeftHand": "LeftFingerBase",
    "RightShoulder": "RightArm", "RightArm": "RightForeArm", "RightForeArm": "RightHand",
    "RightHand": "RightFingerBase",
}


def clip_items(_self, _context):
    items = []
    for f in sorted(os.listdir(BVH_DIR)) if os.path.isdir(BVH_DIR) else []:
        if f.lower().endswith(".bvh"):
            key = f[:-4]
            items.append((key, f"{key}  {CLIPS.get(key, '')}", CLIPS.get(key, "")))
    return items or [("NONE", "brak plików BVH", "")]


def find_rig(context):
    obs = [context.active_object] + list(context.selected_objects) + list(bpy.data.objects)
    for ob in obs:
        if ob is not None and ob.type == "ARMATURE" and "LeftUpLeg" in ob.data.bones and not ob.get("bvh_src"):
            return ob
    return None


def world_rot(ob, m):
    return (ob.matrix_world @ m).to_quaternion()


def world_pos(ob, m):
    return (ob.matrix_world @ m).translation.copy()


# Dłonie i palce w CMU mają zerowe długości i szumiące obroty: trzymane sztywno względem przedramienia.
SIGN = -1.0  # kierunek zgięcia palców w rigu CMU MB (sprawdzony renderem)
CURL_AXIS = (0, 0, 1)  # oś Z kości = zginanie palców (oś X wyginała dłoń na boki)
RIGID_BONES = {"LeftHand", "RightHand", "LThumb", "RThumb", "LeftFingerBase", "RightFingerBase",
               "LeftHandFinger1", "RightHandFinger1"}
CURL = {"LeftFingerBase": SIGN * 0.5, "RightFingerBase": SIGN * 0.5, "LeftHandFinger1": SIGN * 0.7,
        "RightHandFinger1": SIGN * 0.7}  # luźno zgięte palce (rad, wokół CURL_AXIS)
THUMB_FORWARD = {"LeftForeArm": ("LeftHand", "LThumb"), "RightForeArm": ("RightHand", "RThumb")}
LOOP_JOINTS = ("LeftFoot", "RightFoot", "LeftLeg", "RightLeg", "LeftHand", "RightHand", "Head")


def thumb_forward(rot_w, rest_rot, rest_pos, bone, child, thumb, fwd):
    """Obraca kość wokół jej osi tak, by kciuk wskazywał przód postaci (im bardziej ręka opuszczona, tym pełniej)."""
    m = rot_w @ rest_rot.inverted()
    d = (m @ (rest_pos[child] - rest_pos[bone])).normalized()
    t = m @ (rest_pos[thumb[1]] - rest_pos[thumb[0]])
    t = t - d * t.dot(d)
    f = fwd - d * fwd.dot(d)
    if t.length < 1e-6 or f.length < 1e-6:
        return rot_w
    angle = math.atan2(d.dot(t.cross(f)), t.dot(f)) * min(1.0, f.length)
    return Quaternion(d, angle) @ rot_w


def find_loop(samples, feats, size, p_min=24, p_max=48):
    """Najlepszy jeden cykl chodu (dwa kroki): klatki i oraz i+p o najbardziej podobnej pozie,
    tylko na odcinkach, gdzie aktor idzie (prędkość bioder ≥ 40% najszybszego odcinka)."""
    n = len(samples)
    hips = [s[1] for s in samples]

    def speed(i, p):
        d = hips[i + p] - hips[i]
        return Vector((d.x, d.y, 0)).length / p

    cands = [(i, p) for p in range(p_min, p_max + 1) for i in range(5, n - p)]
    if not cands:
        return 0, n
    vmax = max(speed(i, p) for i, p in cands)
    best = None
    for i, p in cands:
        if speed(i, p) < 0.4 * vmax:
            continue
        a, b = feats[i], feats[i + p]
        cost = sum((x - y) ** 2 for x, y in zip(a, b))
        # sąsiednie klatki też mają się zgadzać (ciągłość ruchu przez szew)
        a1, b1 = feats[i + 1], feats[min(i + p + 1, n - 1)]
        cost += sum((x - y) ** 2 for x, y in zip(a1, b1))
        if best is None or cost < best[0]:
            best = (cost, i, p)
    return (best[1], best[2]) if best else (0, n)


def retarget(context, rig, bvh_path, in_place, loop=True):
    scene = context.scene
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    for ob in [o for o in bpy.data.objects if o.get("bvh_src")]:
        bpy.data.objects.remove(ob)
    before = set(bpy.data.objects)
    bpy.ops.import_anim.bvh(filepath=bvh_path, rotate_mode="QUATERNION", update_scene_fps=False,
                            update_scene_duration=False)
    src = next(o for o in bpy.data.objects if o not in before and o.type == "ARMATURE")
    src["bvh_src"] = True
    act = src.animation_data.action
    f0, f1 = (int(v) for v in act.frame_range)

    names = [b.name for b in rig.data.bones if b.name in src.data.bones]
    # Spoczynek BVH (T-poza) i rigu, w świecie.
    s_rest_rot = {n: world_rot(src, src.data.bones[n].matrix_local) for n in names}
    s_rest_pos = {n: world_pos(src, src.data.bones[n].matrix_local) for n in names}
    t_rest_rot = {b.name: world_rot(rig, b.matrix_local) for b in rig.data.bones}
    t_rest_pos = {b.name: world_pos(rig, b.matrix_local) for b in rig.data.bones}

    # Obrót wokół pionu, który ustawia BVH przodem tak jak rig (oś bioder lewe-prawe).
    def lateral(pos):
        v = pos["LeftUpLeg"] - pos["RightUpLeg"]
        return Vector((v.x, v.y, 0)).normalized()
    yaw = lateral(s_rest_pos).rotation_difference(lateral(t_rest_pos))
    yaw_inv = yaw.inverted()

    # Rig wyprostowany do kierunków T-pozy BVH (tylko kierunek kości, bez skrętu).
    # Stawy BVH z zerowym przesunięciem (np. Hips→LowerBack, Spine1→Neck): kierunek do dalszego stawu łańcucha.
    s_size = max((p - s_rest_pos["Hips"]).length for p in s_rest_pos.values())
    # Kość bez kierunku (dłoń, palce, głowa: zerowa długość w BVH) dziedziczy wyrównanie rodzica.
    t_tpose = {}
    align = {}
    for n in names:  # kolejność kości rigu: rodzic przed dzieckiem
        c = DIR_CHILD.get(n)
        while c and c in s_rest_pos and (s_rest_pos[c] - s_rest_pos[n]).length < 1e-3 * s_size:
            c = DIR_CHILD.get(c)
        if c and c in s_rest_pos and c in t_rest_pos and (t_rest_pos[c] - t_rest_pos[n]).length > 1e-6:
            ds = yaw @ (s_rest_pos[c] - s_rest_pos[n])
            dt = t_rest_pos[c] - t_rest_pos[n]
            align[n] = dt.rotation_difference(ds)
        else:
            parent = rig.data.bones[n].parent
            align[n] = align.get(parent.name, Quaternion()) if parent else Quaternion()
        t_tpose[n] = align[n] @ t_rest_rot[n]

    s_ankle = min(s_rest_pos["LeftFoot"].z, s_rest_pos["RightFoot"].z)
    t_ankle = min(t_rest_pos["LeftFoot"].z, t_rest_pos["RightFoot"].z)
    hip_scale = (t_rest_pos["Hips"].z - t_ankle) / max(1e-6, s_rest_pos["Hips"].z - s_ankle)
    rig_rot_inv = rig.matrix_world.to_quaternion().inverted()
    rig_mw_inv = rig.matrix_world.inverted()
    forward_w = rig.matrix_world.to_quaternion() @ Vector((0, -1, 0))  # postać MPFB patrzy w -Y

    if rig.animation_data is None:
        rig.animation_data_create()
    if rig.animation_data.action is not None:
        old = rig.animation_data.action
        rig.animation_data.action = None
        if old.users == 0:
            bpy.data.actions.remove(old)
    for pb in rig.pose.bones:
        pb.rotation_mode = "QUATERNION"
        pb.matrix_basis = Matrix()

    roots = [b for b in rig.data.bones if b.parent is None]
    order = []

    def walk(b):
        order.append(b)
        for ch in b.children:
            walk(ch)
    for r in roots:
        walk(r)

    # Próbki nagrania; kierunek marszu aktora (średnia oś bioder) obracany na przód postaci.
    samples = []
    lats = []
    feats = []
    for f in range(f0, f1 + 1, SAMPLE_STEP):
        scene.frame_set(f)
        rots = {n: world_rot(src, src.pose.bones[n].matrix) for n in names}
        pos = {n: world_pos(src, src.pose.bones[n].matrix) for n in ("Hips", "LeftUpLeg", "RightUpLeg") + LOOP_JOINTS}
        lat = lateral(pos)
        lats.append(lat)
        samples.append((rots, pos["Hips"], min(pos["LeftFoot"].z, pos["RightFoot"].z)))
        local = lat.rotation_difference(Vector((1, 0, 0)))  # cecha pozy niezależna od kierunku marszu
        feats.append([c for j in LOOP_JOINTS for c in (local @ (pos[j] - pos["Hips"])) / s_size])

    if loop:
        i, p = find_loop(samples, feats, s_size)
        samples, lats = samples[i:i + p], lats[i:i + p]
        print(f"pętla: próbki {i}..{i + p} ({p} kl.)")
    lat_sum = sum(lats, Vector((0, 0, 0)))
    heading = Vector((lat_sum.x, lat_sum.y, 0)).normalized().rotation_difference(lateral(s_rest_pos))
    fix = yaw @ heading  # nagranie → układ rigu

    start_hips = fix @ samples[0][1]
    out_frame = 1
    for s_pose_rot, hips_src, ankle_src in samples:
        hips_w = fix @ hips_src - start_hips
        # wysokość bioder nad niższą kostką w tej klatce (stopa podporowa na ziemi), przeskalowana do postaci
        hips_w.z = ((hips_src.z - ankle_src) * hip_scale + t_ankle - t_rest_pos["Hips"].z) / hip_scale
        if in_place:
            hips_w = Vector((0, 0, hips_w.z))
        desired = {}  # przestrzeń szkieletu rigu
        for b in order:
            n = b.name
            if n in s_pose_rot and n not in RIGID_BONES:
                delta = fix @ s_pose_rot[n] @ s_rest_rot[n].inverted() @ yaw_inv
                rot_w = delta @ t_tpose[n]
                thumb = THUMB_FORWARD.get(n)
                if thumb:  # skręt przedramienia: kciuk do przodu postaci (dłoń zwrócona do uda)
                    rot_w = thumb_forward(rot_w, t_rest_rot[n], t_rest_pos, n, DIR_CHILD[n], thumb, forward_w)
            else:
                rot_w = None
            if b.parent is None:
                head_w = t_rest_pos[n] + hips_w * hip_scale if n == "Hips" else t_rest_pos[n]
                head = rig_mw_inv @ head_w
                rot = (rig_rot_inv @ rot_w) if rot_w is not None else b.matrix_local.to_quaternion()
                desired[n] = Matrix.Translation(head) @ rot.to_matrix().to_4x4()
                basis = b.matrix_local.inverted() @ desired[n]
            else:
                rel = b.parent.matrix_local.inverted() @ b.matrix_local
                pd = desired[b.parent.name]
                if rot_w is None:
                    basis = Quaternion(CURL_AXIS, CURL.get(n, 0.0)).to_matrix().to_4x4()
                    desired[n] = pd @ rel @ basis
                else:
                    head = (pd @ rel).translation
                    rot = rig_rot_inv @ rot_w
                    desired[n] = Matrix.Translation(head) @ rot.to_matrix().to_4x4()
                    basis = rel.inverted() @ pd.inverted() @ desired[n]
            pb = rig.pose.bones[n]
            loc, q, _sc = basis.decompose()
            pb.rotation_quaternion = q
            pb.keyframe_insert("rotation_quaternion", frame=out_frame)
            if b.parent is None:
                pb.location = loc
                pb.keyframe_insert("location", frame=out_frame)
        out_frame += 1

    bpy.data.objects.remove(src)
    if act.users == 0:
        bpy.data.actions.remove(act)
    rig.animation_data.action.name = os.path.basename(bvh_path)[:-4]
    scene.frame_start, scene.frame_end = 1, out_frame - 1
    scene.render.fps = 30
    scene.frame_set(1)
    return out_frame - 1


class CHOD_OT_load(bpy.types.Operator):
    bl_idname = "chod.load"
    bl_label = "Wczytaj chód"
    bl_description = "Przenieś wybrane nagranie BVH na rig postaci (rig CMU MB z MPFB)"

    def execute(self, context):
        p = context.scene.chod
        rig = find_rig(context)
        if rig is None:
            self.report({"ERROR"}, "Brak szkieletu z kośćmi CMU (MPFB: Rigging → Add rig → CMU MB)")
            return {"CANCELLED"}
        path = os.path.join(BVH_DIR, p.clip + ".bvh")
        n = retarget(context, rig, path, p.in_place, p.loop)
        self.report({"INFO"}, f"{p.clip}: {n} klatek (30 kl./s)")
        return {"FINISHED"}


class CHOD_OT_view(bpy.types.Operator):
    bl_idname = "chod.view"
    bl_label = "Widok"
    view: bpy.props.StringProperty()

    def execute(self, context):
        pivot = bpy.data.objects.get("kamera_obrot")
        if pivot is not None:
            pivot.rotation_euler = (0, 0, math.radians({"przod": 0, "bok": 90, "tyl": 180}[self.view]))
        for area in context.screen.areas:
            if area.type == "VIEW_3D":
                area.spaces[0].region_3d.view_perspective = "CAMERA"
        return {"FINISHED"}


class CHOD_OT_save(bpy.types.Operator):
    bl_idname = "chod.save"
    bl_label = "Zapisz wybór"
    bl_description = "Zapisz scenę do proby/postac3d/wybor.blend"

    def execute(self, context):
        os.makedirs(os.path.dirname(SAVE_PATH), exist_ok=True)
        bpy.ops.wm.save_as_mainfile(filepath=SAVE_PATH, copy=True)
        self.report({"INFO"}, "Zapisano " + SAVE_PATH)
        return {"FINISHED"}


class ChodProps(bpy.types.PropertyGroup):
    clip: bpy.props.EnumProperty(name="Nagranie", items=clip_items)
    in_place: bpy.props.BoolProperty(name="W miejscu", default=True,
                                     description="Usuń przesuwanie bioder w poziomie (sprite chodzi w miejscu)")
    loop: bpy.props.BoolProperty(name="Jedna pętla", default=True,
                                 description="Wytnij z nagrania jeden cykl chodu (dwa kroki), który się zapętla")


class CHOD_PT_panel(bpy.types.Panel):
    bl_label = "Chód (CMU)"
    bl_space_type = "VIEW_3D"
    bl_region_type = "UI"
    bl_category = "Chód"

    def draw(self, context):
        p = context.scene.chod
        col = self.layout.column()
        col.prop(p, "clip")
        col.prop(p, "in_place")
        col.prop(p, "loop")
        col.operator("chod.load", icon="ARMATURE_DATA")
        col.separator()
        col.label(text="Kamera gry (kąt %.2f):" % DF)
        row = col.row(align=True)
        for v, label in (("przod", "Przód"), ("bok", "Bok"), ("tyl", "Tył")):
            row.operator("chod.view", text=label).view = v
        col.separator()
        col.operator("screen.animation_play", text="Odtwórz / stop", icon="PLAY")
        col.separator()
        col.operator("chod.save", icon="FILE_TICK")


CLASSES = (ChodProps, CHOD_OT_load, CHOD_OT_view, CHOD_OT_save, CHOD_PT_panel)


DETECTIVE = args.get("detektyw", "1") == "1"
# Detektyw wg konceptu proby/koncept9/edit_kurtka_s9000.png: (typ zasobu, katalog, kolor sRGB albo None = materiał MPFB)
DETECTIVE_ASSETS = [
    ("eyes", "low-poly", None),
    ("eyebrows", "eyebrow001", (0.30, 0.29, 0.28)),
    ("eyelashes", "eyelashes01", None),
    ("hair", "short02", (0.27, 0.26, 0.25)),
    ("clothes", "wdg_scruffy_beard", (0.48, 0.46, 0.44)),
    ("clothes", "toigo_ankle_boots_male", (0.43, 0.25, 0.14)),
    ("clothes", "male_casualsuit05", "recolor"),  # kurtka + koszula + dżinsy, przemalowane wg odcienia tekstury
]
DETECTIVE_SKIN = "middleage_caucasian_male"
# male_casualsuit05: obszar tekstury → kolor sRGB (kurtka szarozielona, koszula w czerwone paski, dżinsy niebieskie)
RECOLOR = {"kurtka": (0.13, 0.15, 0.23), "koszula": (0.58, 0.58, 0.58), "spodnie": (0.30, 0.31, 0.33)}
TEX_DIR = os.path.join(ROOT_DIR, "proby", "postac3d", "tekstury")


def recolor_texture(src_path, out_path):
    """Kolor każdego piksela = kolor obszaru × (jasność piksela / średnia jasność obszaru)."""
    import numpy as np
    im = bpy.data.images.load(src_path)
    w, h = im.size
    px = np.array(im.pixels[:], np.float32).reshape(h, w, 4)
    bpy.data.images.remove(im)
    rgb = px[..., :3]
    mx, mn = rgb.max(-1), rgb.min(-1)
    sat = np.where(mx > 1e-4, (mx - mn) / np.maximum(mx, 1e-4), 0)
    lum = rgb @ np.array([0.2126, 0.7152, 0.0722], np.float32)
    blue = (rgb[..., 2] > rgb[..., 0] * 1.15) & (sat > 0.2)
    red = (rgb[..., 0] > rgb[..., 1] * 1.4) & (sat > 0.3)
    dark = lum < 0.03
    used = px[..., 3] > 0.01
    rows, cols = np.mgrid[0:h, 0:w]
    jeans = (cols < 0.6 * w) & (rows < 0.44 * h)  # dżinsy: lewy dolny obszar tekstury (wiersz 0 = dół)
    masks = {"spodnie": jeans & used, "koszula": (red | dark) & used & ~jeans}
    masks["kurtka"] = used & ~masks["spodnie"] & ~masks["koszula"]
    out = px.copy()
    for name, m in masks.items():
        if not m.any():
            continue
        rel = np.clip(lum[m] / max(1e-4, float(np.median(lum[m]))), 0.4, 1.6)
        if name in ("koszula", "spodnie"):  # paski koszuli i przetarcia dżinsów spłaszczone
            rel = 1.0 + (rel - 1.0) * 0.15
        out[..., :3][m] = np.array(RECOLOR[name], np.float32) * rel[:, None]  # piksele PNG są w sRGB
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    img = bpy.data.images.new("recolor", w, h, alpha=True)
    img.pixels = np.clip(out, 0, 1).ravel()
    img.filepath_raw = out_path
    img.file_format = "PNG"
    img.save()
    return img


def texture_material(name, image):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    nodes.clear()
    tex = nodes.new("ShaderNodeTexImage")
    tex.image = image
    bsdf = nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.inputs["Roughness"].default_value = 0.85
    out = nodes.new("ShaderNodeOutputMaterial")
    mat.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    mat.node_tree.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    mat.diffuse_color = (*srgb_to_linear(RECOLOR["kurtka"]), 1.0)
    return mat


def srgb_to_linear(c):
    return tuple(x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c)


def flat_material(name, color):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    nodes.clear()
    bsdf = nodes.new("ShaderNodeBsdfPrincipled")
    out = nodes.new("ShaderNodeOutputMaterial")
    mat.node_tree.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    mat.diffuse_color = (*srgb_to_linear(color), 1.0)  # kolor w podglądzie Workbench
    bsdf.inputs["Base Color"].default_value = (*srgb_to_linear(color), 1.0)
    bsdf.inputs["Roughness"].default_value = 0.85
    return mat


def dress_detective(body):
    from bl_ext.blender_org.mpfb.services.humanservice import HumanService
    from bl_ext.blender_org.mpfb.services.locationservice import LocationService

    data = LocationService.get_user_data()
    skin = os.path.join(data, "skins", DETECTIVE_SKIN, DETECTIVE_SKIN + ".mhmat")
    if os.path.isfile(skin):
        HumanService.set_character_skin(skin, body, skin_type="MAKESKIN")
    for kind, name, color in DETECTIVE_ASSETS:
        folder = os.path.join(data, kind, name)
        mhclo = next((os.path.join(folder, f) for f in os.listdir(folder) if f.endswith(".mhclo")), None) \
            if os.path.isdir(folder) else None
        if mhclo is None:
            print("brak zasobu", kind, name)
            continue
        bpy.ops.object.select_all(action="DESELECT")
        bpy.context.view_layer.objects.active = body
        ob = HumanService.add_mhclo_asset(mhclo, body, asset_type=kind, subdiv_levels=0, material_type="MAKESKIN")
        if ob is not None and color == "recolor":
            diffuse = next(os.path.join(folder, f) for f in os.listdir(folder) if f.endswith("_diffuse.png"))
            image = recolor_texture(diffuse, os.path.join(TEX_DIR, name + "_detektyw.png"))
            ob.data.materials.clear()
            ob.data.materials.append(texture_material(name, image))
        elif ob is not None and color is not None:
            ob.data.materials.clear()
            ob.data.materials.append(flat_material(name, color))


def build_scene():
    from bl_ext.blender_org.mpfb.services.humanservice import HumanService
    from bl_ext.blender_org.mpfb.services.targetservice import TargetService

    for ob in list(bpy.data.objects):
        bpy.data.objects.remove(ob)
    macro = TargetService.get_default_macro_info_dict()
    macro.update({"gender": 1.0, "age": 0.6, "muscle": 0.5, "weight": 0.45, "proportions": 0.8, "height": 0.7,
                  "race": {"asian": 0.0, "caucasian": 1.0, "african": 0.0}})
    if DETECTIVE:
        macro.update({"age": 0.69, "muscle": 0.6, "weight": 0.42, "height": 0.75})  # ok. 50 lat, szczupły
    body = HumanService.create_human(macro_detail_dict=macro)
    rig = HumanService.add_builtin_rig(body, args.get("rig", "cmu_mb"))
    if rig is not None:
        rig.show_in_front = False
    if DETECTIVE:
        dress_detective(body)

    scene = bpy.context.scene
    pivot = bpy.data.objects.new("kamera_obrot", None)
    scene.collection.objects.link(pivot)
    cam_data = bpy.data.cameras.new("kamera_gry")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = 2.6
    cam_data.clip_end = 100
    cam = bpy.data.objects.new("kamera_gry", cam_data)
    scene.collection.objects.link(cam)
    cam.parent = pivot
    cam.rotation_euler = (math.pi / 2 - THETA, 0, 0)
    fwd = -cam.rotation_euler.to_matrix().col[2]
    cam.location = Vector((0, 0, 0.9)) - fwd * 20
    scene.camera = cam
    scene.render.resolution_x = 1000
    scene.render.resolution_y = 1000
    scene.render.engine = "BLENDER_EEVEE"

    world = bpy.data.worlds.new("tlo") if scene.world is None else scene.world
    scene.world = world
    world.color = (0.62, 0.64, 0.67)
    sun = bpy.data.objects.new("slonce", bpy.data.lights.new("slonce", "SUN"))
    sun.data.energy = 3.0
    sun.rotation_euler = (math.radians(50), 0, math.radians(30))
    scene.collection.objects.link(sun)


def setup_view():
    for window in bpy.context.window_manager.windows:
        for area in window.screen.areas:
            if area.type == "VIEW_3D":
                sp = area.spaces[0]
                sp.shading.type = "MATERIAL"
                sp.region_3d.view_perspective = "CAMERA"
                sp.show_region_ui = True
    return None


COMMAND_DIR = os.path.join(ROOT_DIR, "proby", "postac3d", "polecenia")
START_CLIP = args.get("chod", "82_09")


def listen():
    """Nasłuch: skrypty .py wrzucone do proby/postac3d/polecenia/ wykonują się w otwartym Blenderze
    (Claude steruje sceną na oczach człowieka); wynik w <nazwa>.log obok."""
    import glob
    import traceback
    for path in sorted(glob.glob(os.path.join(COMMAND_DIR, "*.py"))):
        with open(path, encoding="utf-8") as fh:
            code = fh.read()
        os.remove(path)
        log = path[:-3] + ".log"
        try:
            exec(compile(code, path, "exec"), dict(globals()))
            msg = "OK\n"
        except Exception:
            msg = traceback.format_exc()
        with open(log, "w", encoding="utf-8") as fh:
            fh.write(msg)
    return 0.5


def play():
    for window in bpy.context.window_manager.windows:
        for area in window.screen.areas:
            if area.type == "VIEW_3D":
                with bpy.context.temp_override(window=window, area=area):
                    if not bpy.context.screen.is_animation_playing:
                        bpy.ops.screen.animation_play()
                return None
    return None


def main():
    import addon_utils
    addon_utils.enable("io_anim_bvh", default_set=True)
    for c in CLASSES:
        bpy.utils.register_class(c)
    bpy.types.Scene.chod = bpy.props.PointerProperty(type=ChodProps)
    build_scene()
    if bpy.app.background:
        return
    rig = find_rig(bpy.context)
    if rig is not None and START_CLIP in [i[0] for i in clip_items(None, None)]:
        bpy.context.scene.chod.clip = START_CLIP
        retarget(bpy.context, rig, os.path.join(BVH_DIR, START_CLIP + ".bvh"), True, True)
    os.makedirs(COMMAND_DIR, exist_ok=True)
    bpy.app.timers.register(setup_view, first_interval=1.0)
    bpy.app.timers.register(play, first_interval=2.0)
    bpy.app.timers.register(listen, first_interval=2.0, persistent=True)


main()
