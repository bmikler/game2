# PROTOTYP (ticket „Przepis postaci”): szkielety chodu dla Pixellab animate-with-skeleton-v3.
# Poza stojąca = manekin MPFB (z jego profilu powstał sprite), chód = mocap CMU (BVH), przeniesiony na
# długości kości MPFB (kierunki segmentów z mocapu). Rzut kamery gry: ekran x = świat x,
# ekran w górę = z + DF * y (y = głębia od kamery), 40 px/m; dopasowanie do konturu sprite'a.
#
#   blender -b -P tools/blender/szkielet_chodu.py -- --sprite proby/pixellab_postac_C/west.png
#       --bvh tools/mocap/cmu/02_01.bvh,tools/mocap/cmu/07_01.bvh --out proby/szkielet_C [--frames 8] [--df 0.6]
#
# Wynik: <out>/szkielet.json {sprite, size, first_frame_keypoints, chody: {nazwa: {keypoints: [[...]]}}}.
# Postać patrzy w lewo (-x), lewa strona ciała bliżej kamery (z_index wyżej).
import bpy
import json
import math
import os
import sys
from mathutils import Matrix, Vector

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
args = {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv) - 1, 2)}
DF = float(args.get("df", "0.6"))
FRAMES = int(args.get("frames", "8"))
SPRITE = os.path.abspath(args["sprite"])
BVHS = [os.path.abspath(p) for p in args["bvh"].split(",")]
OUT = os.path.abspath(args.get("out", "proby/szkielet"))
ARMS = math.radians(float(args.get("arms", "28")))  # jak w postac_mpfb.py
HEIGHT_M = 1.8
os.makedirs(OUT, exist_ok=True)

LABELS = ["NOSE", "NECK", "RIGHT SHOULDER", "RIGHT ELBOW", "RIGHT ARM", "LEFT SHOULDER", "LEFT ELBOW", "LEFT ARM",
          "RIGHT HIP", "RIGHT KNEE", "RIGHT LEG", "LEFT HIP", "LEFT KNEE", "LEFT LEG",
          "RIGHT EYE", "LEFT EYE", "RIGHT EAR", "LEFT EAR"]

# --- kontur sprite'a ---
img = bpy.data.images.load(SPRITE)
W, H = img.size
px = list(img.pixels)
opaque = [(i % W, H - 1 - i // W) for i in range(W * H) if px[i * 4 + 3] > 0.5]  # y od góry
img_top = min(p[1] for p in opaque)
img_bot = max(p[1] for p in opaque) + 1
img_l = min(p[0] for p in opaque)
img_r = max(p[0] for p in opaque) + 1
print("sprite", W, H, "bbox x", img_l, img_r, "y", img_top, img_bot)

# --- MPFB w pozie stojącej (twarzą w -y) ---
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


def mesh_points():
    dg = bpy.context.evaluated_depsgraph_get()
    ev = body.evaluated_get(dg)
    mesh = ev.to_mesh()
    pts = [body.matrix_world @ v.co for v in mesh.vertices]
    ev.to_mesh_clear()
    return pts


def turn(name, rad, axis_world):
    pb = rig.pose.bones[name]
    axis = (rig.matrix_world.inverted().to_3x3() @ Vector(axis_world)).normalized()
    head = pb.matrix.translation.copy()
    pb.matrix = Matrix.Translation(head) @ Matrix.Rotation(rad, 4, axis) @ Matrix.Translation(-head) @ pb.matrix
    bpy.context.view_layer.update()


turn("upperarm01.L", ARMS, (0, 1, 0))
turn("upperarm01.R", -ARMS, (0, 1, 0))
pts = mesh_points()
k = HEIGHT_M / (max(p.z for p in pts) - min(p.z for p in pts))
rig.scale = rig.scale * k
bpy.context.view_layer.update()
pts = mesh_points()
rig.location = rig.location - Vector(((min(p.x for p in pts) + max(p.x for p in pts)) / 2,
                                      (min(p.y for p in pts) + max(p.y for p in pts)) / 2, min(p.z for p in pts)))
bpy.context.view_layer.update()
pts = mesh_points()


def bh(name):
    return rig.matrix_world @ rig.pose.bones[name].head


def bt(name):
    return rig.matrix_world @ rig.pose.bones[name].tail


M = {
    "LHIP": bh("upperleg01.L"), "RHIP": bh("upperleg01.R"),
    "LKNEE": bh("lowerleg01.L"), "RKNEE": bh("lowerleg01.R"),
    "LANK": bh("foot.L"), "RANK": bh("foot.R"),
    "LSH": bh("upperarm01.L"), "RSH": bh("upperarm01.R"),
    "LELB": bh("lowerarm01.L"), "RELB": bh("lowerarm01.R"),
    "LWR": bh("wrist.L"), "RWR": bh("wrist.R"),
    "NECK": bh("neck01"), "HEAD": bh("head"),
    "LEYE": bh("eye.L"), "REYE": bh("eye.R"),
}
print("MPFB: oko L x", round(M["LEYE"].x, 3), "(lewa strona ciała ma x>0 przy twarzy w -y)")
PELVIS = (M["LHIP"] + M["RHIP"]) / 2


def face_points(J, fwd, side_l):
    """Nos, oczy, uszy z pozycji oczu (przesunięte jak głowa); fwd = przód, side_l = w lewo ciała."""
    up = Vector((0, 0, 1))
    em = (J["LEYE"] + J["REYE"]) / 2
    J["NOSE"] = em + fwd * 0.025 - up * 0.04
    J["LEAR"] = em - fwd * 0.09 + side_l * 0.075 - up * 0.01
    J["REAR"] = em - fwd * 0.09 - side_l * 0.075 - up * 0.01


def to_profile_left(v):
    """Obrót o -90° wokół z: przód -y → -x."""
    return Matrix.Rotation(math.radians(-90), 3, "Z") @ v


REST = {n: to_profile_left(v) for n, v in M.items()}
# MPFB ma w spoczynku przedramiona wysunięte do przodu; sprite stoi z rękami wzdłuż ciała → prostujemy.
for s in ("L", "R"):
    sh, el, wr = REST[s + "SH"], REST[s + "ELB"], REST[s + "WR"]
    REST[s + "WR"] = el + (el - sh).normalized() * (wr - el).length
face_points(REST, Vector((-1, 0, 0)), to_profile_left(Vector((1, 0, 0))))
mesh_prof = [to_profile_left(p) for p in pts]


def scr(v):
    return v.x, v.z + DF * v.y  # (x, w górę) w metrach


sx = [scr(p)[0] for p in mesh_prof]
sy = [scr(p)[1] for p in mesh_prof]
scale = (img_bot - img_top) / (max(sy) - min(sy))  # px/m
ox = (img_l + img_r) / 2 - scale * (min(sx) + max(sx)) / 2
oy = img_bot + scale * min(sy)
# Poziomo: środek tułowia sprite'a (wiersze między barkami a biodrami) = środek barków i bioder szkieletu.
_trunk = [REST[n] for n in ("LSH", "RSH", "LHIP", "RHIP")]
_y0 = round(oy - scale * max(scr(v)[1] for v in _trunk))
_y1 = round(oy - scale * min(scr(v)[1] for v in _trunk))
_rows = {}
for x, y in opaque:
    if _y0 <= y <= _y1:
        lo, hi = _rows.get(y, (x, x))
        _rows[y] = (min(lo, x), max(hi, x + 1))
_cx_img = sum((lo + hi) / 2 for lo, hi in _rows.values()) / len(_rows)
_cx_sk = ox + scale * sum(scr(v)[0] for v in _trunk) / 4
ox += _cx_img - _cx_sk
print("skala px/m", round(scale, 2), "przesunięcie do tułowia px", round(_cx_img - _cx_sk, 1))

NAMES = {"NOSE": "NOSE", "NECK": "NECK", "RSH": "RIGHT SHOULDER", "RELB": "RIGHT ELBOW", "RWR": "RIGHT ARM",
         "LSH": "LEFT SHOULDER", "LELB": "LEFT ELBOW", "LWR": "LEFT ARM", "RHIP": "RIGHT HIP", "RKNEE": "RIGHT KNEE",
         "RANK": "RIGHT LEG", "LHIP": "LEFT HIP", "LKNEE": "LEFT KNEE", "LANK": "LEFT LEG", "REYE": "RIGHT EYE",
         "LEYE": "LEFT EYE", "REAR": "RIGHT EAR", "LEAR": "LEFT EAR"}


def keypoints(J):
    order = sorted(NAMES, key=lambda n: -J[n].y)  # dalej od kamery (większe y) = niżej
    zi = {n: i for i, n in enumerate(order)}
    out = []
    for n, label in NAMES.items():
        x, u = scr(J[n])
        out.append({"label": label, "x": round((ox + scale * x) / W, 4), "y": round((oy - scale * u) / H, 4),
                    "z_index": zi[n]})
    out.sort(key=lambda kp: LABELS.index(kp["label"]))
    return out


result = {"sprite": SPRITE, "size": [W, H], "df": DF, "px_per_m": round(scale, 2),
          "first_frame_keypoints": keypoints(REST), "chody": {}}

# --- mocap ---
SEG = [("LHIP", "LKNEE"), ("LKNEE", "LANK"), ("RHIP", "RKNEE"), ("RKNEE", "RANK"),
       ("NECK", "LSH"), ("LSH", "LELB"), ("LELB", "LWR"), ("NECK", "RSH"), ("RSH", "RELB"), ("RELB", "RWR")]
LEN = {s: (M[s[1]] - M[s[0]]).length for s in SEG}
TORSO = (M["NECK"] - PELVIS).length
HEADOFF = {n: M[n] - M["NECK"] for n in ("LEYE", "REYE", "HEAD")}
LEG_M = LEN[("LHIP", "LKNEE")] + LEN[("LKNEE", "LANK")]
HIPW = (M["LHIP"] - M["RHIP"]).length / 2
BV = {"LHIP": "LeftUpLeg", "RHIP": "RightUpLeg", "LKNEE": "LeftLeg", "RKNEE": "RightLeg", "LANK": "LeftFoot",
      "RANK": "RightFoot", "LSH": "LeftArm", "RSH": "RightArm", "LELB": "LeftForeArm", "RELB": "RightForeArm",
      "LWR": "LeftHand", "RWR": "RightHand", "NECK": "Neck1", "HEAD": "Head"}

for path in BVHS:
    name = os.path.splitext(os.path.basename(path))[0]
    if bpy.context.object is not None and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.import_anim.bvh(filepath=path, axis_forward="-Z", axis_up="Y", update_scene_fps=False,
                            update_scene_duration=True)
    arm = bpy.context.active_object
    f0, f1 = (int(v) for v in arm.animation_data.action.frame_range)
    scene = bpy.context.scene
    seq = []
    for f in range(f0, f1 + 1):
        scene.frame_set(f)
        seq.append({n: arm.matrix_world @ arm.pose.bones[b].head for n, b in BV.items()})
    # Kierunek marszu z całego nagrania.
    p_a = (seq[0]["LHIP"] + seq[0]["RHIP"]) / 2
    p_b = (seq[-1]["LHIP"] + seq[-1]["RHIP"]) / 2
    walk = Vector((p_b.x - p_a.x, p_b.y - p_a.y, 0)).normalized()
    side_l = Vector((0, 0, 1)).cross(walk)  # lewo przy patrzeniu w kierunku marszu
    # Faza: różnica stóp wzdłuż marszu; cykl = od maksimum (lewa noga z przodu) do następnego.
    d = [(s["LANK"] - s["RANK"]).dot(walk) for s in seq]
    peaks = [i for i in range(2, len(d) - 2) if d[i] == max(d[i - 2:i + 3]) and d[i] > 0.3 * max(d)]
    # Para kolejnych pików odległych o 0,5–1,7 s przy 120 kl./s (bliżej to szum), najbliżej środka nagrania.
    pairs = [(i, min(j for j in peaks if j > i + 60)) for i in peaks if any(j > i + 60 for j in peaks)]
    pairs = [(i, j) for i, j in pairs if j - i < 200]
    a, b = min(pairs, key=lambda ij: abs((ij[0] + ij[1]) / 2 - len(d) / 2))
    print(name, "klatek", len(seq), "cykl", a, b, "=", b - a, "kl. (", round((b - a) / 120, 2), "s)")
    leg_c = sum(((seq[a][s[1]] - seq[a][s[0]]).length for s in SEG[:2]))
    sc = LEG_M / leg_c
    pa = (seq[a]["LHIP"] + seq[a]["RHIP"]) / 2
    pb_ = (seq[b]["LHIP"] + seq[b]["RHIP"]) / 2
    frames = []
    for j in range(FRAMES):
        t = a + (b - a) * j / FRAMES
        i0 = int(t)
        u = t - i0
        S = {n: seq[i0][n].lerp(seq[min(i0 + 1, b)][n], u) for n in BV}
        pel = (S["LHIP"] + S["RHIP"]) / 2
        trend = pa.lerp(pb_, (t - a) / (b - a))
        # Układ ciała mocapu → układ MPFB twarzą w -y: oś marszu → -y, lewo → +x.
        def body(v):
            return Vector((v.dot(side_l), -v.dot(walk), v.z))
        J = {}
        p = body(pel - trend) * sc
        p.z = PELVIS.z + (pel.z - pa.z) * sc
        p.x += PELVIS.x
        p.y += PELVIS.y
        hipdir = body(S["LHIP"] - S["RHIP"]).normalized()
        J["LHIP"] = p + hipdir * HIPW
        J["RHIP"] = p - hipdir * HIPW
        J["NECK"] = p + body(S["NECK"] - pel).normalized() * TORSO
        for s in SEG:
            if s[0] in J:
                J[s[1]] = J[s[0]] + body(S[s[1]] - S[s[0]]).normalized() * LEN[s]
        for n, off in HEADOFF.items():
            J[n] = J["NECK"] + off
        frames.append(J)
    # Stopy na ziemi: najniższa kostka w cyklu = kostka MPFB w spoczynku.
    dz = M["LANK"].z - min(min(J["LANK"].z, J["RANK"].z) for J in frames)
    kps = []
    for J in frames:
        for n in J:
            J[n] = J[n] + Vector((0, 0, dz))
        face_points(J, Vector((0, -1, 0)), Vector((1, 0, 0)))
        kps.append(keypoints({n: to_profile_left(v) for n, v in J.items()}))
    result["chody"][name] = {"keypoints": kps, "cykl_kl_120fps": b - a}
    bpy.data.objects.remove(arm)

with open(os.path.join(OUT, "szkielet.json"), "w", encoding="utf-8") as fh:
    json.dump(result, fh, indent=1)
print("gotowe:", OUT)
