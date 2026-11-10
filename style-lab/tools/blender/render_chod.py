# PROTOTYP (ticket „Przepis postaci”): render chodu postaci 3D do sprite'ów w kamerze gry.
#   blender -b -P tools/blender/wybor_postaci.py --python tools/blender/render_chod.py -- --wariant A
#   blender -b -P tools/blender/wybor_postaci.py --python tools/blender/render_chod.py -- --wariant B
# A: detektyw MPFB (wybor_postaci.py) + chód CMU 82_09 (jedna pętla, w miejscu).
# B: Quaternius Superhero_Male + Walk_Formal_Loop / Idle_Loop (CC0, wspólny szkielet, bez retargetu).
# Kamera: ortho pochylona o atan(df), obraz rozciągany w pionie 1/cos (pion ekranu = wysokość w metrach),
# SS-krotnie większy niż sprite: 1 m = 40·SS px, płótno 80·SS, stopy 7 px nad dołem płótna.
# Wynik: proby/postac3d/render/<wariant>/{przod,bok,tyl}_{stoi,0..N-1}.png (duże) + info.txt (kl./s).
import bpy
import math
import os
import sys
from mathutils import Matrix, Vector

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
opts = {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv) - 1, 2)}
VARIANT = opts.get("wariant", "A")
FRAMES = int(opts.get("klatki", "10"))
SS = int(opts.get("ss", "8"))
DF = float(opts.get("df", "0.6"))
THETA = math.atan(DF)
PPM = 40 * SS
CANVAS = 80 * SS
GROUND_ROW = 73  # wiersz stóp w sprite'cie 80 px (7 px nad dołem)
ROOT = os.getcwd()
OUT = os.path.join(ROOT, opts["out"]) if "out" in opts else os.path.join(ROOT, "proby", "postac3d", "render", VARIANT)
Q = os.path.join(os.path.dirname(ROOT), "zasoby", "quaternius")
Q_CHAR = os.path.join(Q, "ubc", "Universal Base Characters[Standard]", "Base Characters", "Godot - UE",
                      "Superhero_Male_FullBody.gltf")
Q_ANIM = os.path.join(Q, "ual", "Universal Animation Library[Standard]", "Unreal-Godot", "UAL1_Standard.glb")
VIEWS = {"przod": 0, "bok": 90, "tyl": 180}  # bok: postać patrzy w lewo (Poligon lustruje)
os.makedirs(OUT, exist_ok=True)
scene = bpy.context.scene


def set_action(arm, name):
    act = bpy.data.actions[name]
    ad = arm.animation_data or arm.animation_data_create()
    ad.action = act
    if len(act.slots):
        ad.action_slot = act.slots[0]
    f0, f1 = act.frame_range
    return f0, f1


def setup_a():
    """Detektyw jest już zbudowany przez wybor_postaci.py; wczytaj chód i znajdź klatkę „stania”."""
    rig = next(o for o in bpy.data.objects if o.type == "ARMATURE")
    # wzrost: od podeszwy (najniższa siatka, stopy ciała są ukryte pod butami) do czubka głowy ciała (bez włosów)
    dg = bpy.context.evaluated_depsgraph_get()
    tops, bottoms = [], []
    for ob in [o for o in bpy.data.objects if o.type == "MESH"]:
        ev = ob.evaluated_get(dg)
        m = ev.to_mesh()
        zs = [(ev.matrix_world @ v.co).z for v in m.vertices]
        ev.to_mesh_clear()
        if zs:
            bottoms.append(min(zs))
            if ob.name == "Human":
                tops.append(max(zs))
    rig.scale = rig.scale * (1.8 / (max(tops) - min(bottoms)))  # wzrost dokładnie 1,8 m = 72 px
    bpy.context.view_layer.update()
    if opts.get("stoi") == "1":  # sama poza spoczynkowa MPFB, bez chodu (wzorzec kąta)
        f = scene.frame_current
        return lambda: scene.frame_set(f), f, f, 30.0
    scene.chod.clip = opts.get("chod", "82_09")
    bpy.ops.chod.load()
    f0, f1 = scene.frame_start, scene.frame_end + 1  # pętla: klatka f1 = f0
    # stanie: klatka mijania, gdy stopy są najbliżej siebie w poziomie
    best = None
    for f in range(scene.frame_start, scene.frame_end + 1):
        scene.frame_set(f)
        a = rig.matrix_world @ rig.pose.bones["LeftFoot"].head
        b = rig.matrix_world @ rig.pose.bones["RightFoot"].head
        d = Vector((a.x - b.x, a.y - b.y)).length
        if best is None or d < best[0]:
            best = (d, f)
    return lambda: scene.frame_set(best[1]), f0, f1, 30.0


def setup_b():
    for ob in list(bpy.data.objects):
        bpy.data.objects.remove(ob)
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=Q_CHAR, bone_heuristic="BLENDER")
    arm = next(o for o in bpy.data.objects if o not in before and o.type == "ARMATURE")
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=Q_ANIM, bone_heuristic="BLENDER")
    for ob in bpy.data.objects:  # renderuje się tylko siatka postaci (bez manekina i kul kości)
        ob.hide_render = not (ob.type == "MESH" and ob.parent is arm and not ob.name.startswith("Ico kula"))
    walk = opts.get("chod", "Walk_Formal_Loop")

    def stand():
        set_action(arm, "Idle_Loop")
        scene.frame_set(int(bpy.data.actions["Idle_Loop"].frame_range[0]))
        set_action(arm, walk)

    f0, f1 = set_action(arm, walk)
    return stand, f0, f1, 30.0


def setup_render():
    for ob in [o for o in bpy.data.objects if o.type in ("CAMERA", "LIGHT") or o.name == "kamera_obrot"]:
        bpy.data.objects.remove(ob)
    pivot = bpy.data.objects.new("obrot", None)
    scene.collection.objects.link(pivot)
    cam = bpy.data.objects.new("kamera", bpy.data.cameras.new("kamera"))
    scene.collection.objects.link(cam)
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = CANVAS / PPM
    cam.data.sensor_fit = "HORIZONTAL"
    cam.data.clip_end = 100
    cam.parent = pivot
    cam.rotation_euler = (math.pi / 2 - THETA, 0, 0)
    fwd = -cam.rotation_euler.to_matrix().col[2]
    center_h = (GROUND_ROW - 40) / 40.0  # m nad ziemią, które wypadają na środku płótna
    cam.location = Vector((0, 0, center_h)) - fwd * 20
    scene.camera = cam
    for name, rot, energy in (("klucz", (math.radians(45), 0, math.radians(-35)), 3.0),
                              ("kontra", (math.radians(60), 0, math.radians(150)), 1.0)):
        light = bpy.data.objects.new(name, bpy.data.lights.new(name, "SUN"))
        light.data.energy = energy
        light.rotation_euler = rot
        scene.collection.objects.link(light)
    world = scene.world or bpy.data.worlds.new("tlo")
    scene.world = world
    world.color = (0.25, 0.26, 0.28)
    scene.render.engine = "BLENDER_EEVEE"
    scene.eevee.taa_render_samples = 16
    scene.render.film_transparent = True
    scene.render.resolution_x = CANVAS
    scene.render.resolution_y = round(CANVAS * math.cos(THETA))
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.view_settings.view_transform = "Standard"
    return pivot


NECK_FIX = math.radians(float(opts.get("glowa", "25" if VARIANT == "C" else "0")))


def fix_action(f0, f1):
    """Głowa odchylona do tyłu o NECK_FIX w kluczach animacji (chody M2M/Quaternius mają wysuniętą,
    opuszczoną głowę). Klucze, bo render przelicza animację i nadpisałby ręczną zmianę pozy."""
    if NECK_FIX == 0:
        return
    arm = next(o for o in bpy.data.objects if o.type == "ARMATURE")
    pb = arm.pose.bones.get("head")  # tylko głowa: kołnierz ważony do szyi zostaje na miejscu
    if pb is None:
        return
    pb.rotation_mode = "QUATERNION"
    axis = (arm.matrix_world.inverted().to_3x3() @ Vector((1, 0, 0))).normalized()  # oś boczna (postać patrzy w -Y)
    for f in range(int(f0), int(f1) + 1):
        scene.frame_set(f)
        head = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(head) @ Matrix.Rotation(-NECK_FIX, 4, axis) @ Matrix.Translation(-head) @ pb.matrix
        bpy.context.view_layer.update()
        pb.keyframe_insert("rotation_quaternion", frame=f)


def render(path):
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    img = bpy.data.images.load(path)
    img.scale(CANVAS, CANVAS)  # rozciągnięcie w pionie 1/cos
    img.filepath_raw = path
    img.save()
    bpy.data.images.remove(img)


def ground(f0, f1):
    """Najniższy punkt postaci w cyklu chodu na z = 0 (stała poprawka całej postaci, podskok zostaje)."""
    arm = next(o for o in bpy.data.objects if o.type == "ARMATURE" and any(
        c.type == "MESH" and not c.hide_render for c in o.children))
    meshes = [c for c in arm.children if c.type == "MESH" and not c.hide_render]
    low = None
    high = None
    for k in range(FRAMES):
        scene.frame_set(int(f0 + (f1 - f0) * k / FRAMES))
        dg = bpy.context.evaluated_depsgraph_get()
        for ob in meshes:
            ev = ob.evaluated_get(dg)
            m = ev.to_mesh()
            zs = [(ev.matrix_world @ v.co).z for v in m.vertices]
            z = min(zs) if zs else None
            if zs and (high is None or max(zs) > high):
                high = max(zs)
            ev.to_mesh_clear()
            if z is not None and (low is None or z < low):
                low = z
    arm.location.z -= low
    bpy.context.view_layer.update()
    print("grunt: przesunięcie", round(-low, 3), "m, wysokość w cyklu", round(high - low, 3), "m")


def plant(f0, f1):
    """W każdej klatce najniższy punkt postaci (podeszwa) na z = 0: klucz wysokości całej postaci."""
    arm = next(o for o in bpy.data.objects if o.type == "ARMATURE")
    meshes = [c for c in arm.children if c.type == "MESH" and not c.hide_render]
    heads = []
    for f in range(int(f0), int(f1) + 1):
        arm.location.z = 0.0
        scene.frame_set(f)
        arm.location.z = 0.0
        bpy.context.view_layer.update()
        dg = bpy.context.evaluated_depsgraph_get()
        low, head = None, None
        for ob in meshes:
            ev = ob.evaluated_get(dg)
            m = ev.to_mesh()
            zs = [(ev.matrix_world @ v.co).z for v in m.vertices]
            ev.to_mesh_clear()
            if zs:
                low = min(zs) if low is None else min(low, min(zs))
                if ob.name == "Human":
                    head = max(zs)
        arm.location.z = -low
        arm.keyframe_insert("location", index=2, frame=f)
        heads.append(head - low)
    print("wzrost w cyklu (podeszwa→czubek głowy): min", round(min(heads), 3), "max", round(max(heads), 3), "m")
    return sum(heads) / len(heads)


M2M = os.path.join(os.path.dirname(ROOT), "zasoby", "mesh2motion", "human", "animations")
M2M_PRIORITY = ("spine_01", "neck_01", "middle_01_l", "middle_01_r")


def setup_c():
    """Detektyw MPFB (rig game_engine, nazwy kości jak w Mesh2Motion) na szkielecie Mesh2Motion „Human”:
    detektyw ustawiony w T-pozie M2M i „zamrożony”, stawy szkieletu M2M przesunięte na stawy detektywa
    (kierunki i skręt kości M2M bez zmian), siatki podpięte pod M2M z wagami z MPFB. Animacja M2M działa
    jak na oryginalnym manekinie (ten sam szkielet, inne proporcje)."""
    rig = next(o for o in bpy.data.objects if o.type == "ARMATURE")
    meshes = [o for o in bpy.data.objects if o.type == "MESH" and o.find_armature() == rig]
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=os.path.join(M2M, opts.get("chod", "walk") + ".glb"), bone_heuristic="BLENDER")
    w = next(o for o in bpy.data.objects if o not in before and o.type == "ARMATURE")
    for o in bpy.data.objects:
        if o not in before and o is not w:
            o.hide_render = True
            o.hide_viewport = True
    wb = w.data.bones

    def name_r(n):
        return "Root" if n == "root" else n

    def child_of(b):
        kids = [c for c in b.children if name_r(c.name) in rig.data.bones]
        if not kids:
            return None
        for p in M2M_PRIORITY:
            for c in kids:
                if c.name == p:
                    return c
        return kids[0]

    def w_dir(b):
        c = child_of(b)
        v = (c.head_local - b.head_local) if c else (b.tail_local - b.head_local)
        return (w.matrix_world.to_3x3() @ v).normalized()

    # 1) detektyw w T-pozie M2M: kierunek każdej kości (staw → staw dziecka) jak w spoczynku M2M
    bpy.context.view_layer.objects.active = rig
    bpy.ops.object.mode_set(mode="POSE")
    order = []
    leaves = []

    def walk(b):
        order.append(b)
        for c in b.children:
            walk(c)
    for b in wb:
        if b.parent is None:
            walk(b)
    for b in order:
        n = name_r(b.name)
        if n not in rig.pose.bones or b.parent is None:
            continue
        pb = rig.pose.bones[n]
        c = child_of(b)
        if c is None:  # głowa, czubki palców, palce stóp: ułożenie z MPFB (oś kości MPFB bywa pochylona)
            leaves.append(n)
            continue
        head = rig.matrix_world @ pb.head
        cur = (rig.matrix_world @ rig.pose.bones[name_r(c.name)].head) - head
        if cur.length < 1e-6:
            continue
        q = cur.normalized().rotation_difference(w_dir(b))
        mw = rig.matrix_world
        turn = mw.inverted() @ Matrix.Translation(head) @ q.to_matrix().to_4x4() @ Matrix.Translation(-head) @ mw
        pb.matrix = turn @ pb.matrix
        bpy.context.view_layer.update()
    for n in leaves:  # przywrócone ułożenie spoczynkowe MPFB (w miejscu, gdzie kość jest po wyrównaniu rodziców)
        pb = rig.pose.bones[n]
        rest = rig.data.bones[n].matrix_local
        pb.matrix = Matrix.Translation(pb.matrix.translation) @ rest.to_3x3().to_4x4()
        bpy.context.view_layer.update()
    bpy.ops.object.mode_set(mode="OBJECT")
    joints = {b.name: rig.matrix_world @ rig.pose.bones[b.name].head for b in rig.data.bones}

    # 2) zamrożenie siatek w tej pozie (maski MPFB też zastosowane), wagi kości zostają
    for ob in meshes:
        bpy.ops.object.select_all(action="DESELECT")
        bpy.context.view_layer.objects.active = ob
        ob.select_set(True)
        if ob.data.shape_keys:
            bpy.ops.object.shape_key_remove(all=True, apply_mix=True)
        for mod in list(ob.modifiers):  # armatura (T-poza) i maski MPFB (siatki pomocnicze, części pod ubraniem)
            bpy.ops.object.modifier_apply(modifier=mod.name)
        mw = ob.matrix_world.copy()
        ob.parent = None
        ob.matrix_world = mw
        if "Root" in ob.vertex_groups:
            ob.vertex_groups["Root"].name = "root"

    # 3) stawy M2M na stawy detektywa (kierunek i skręt kości M2M bez zmian, długość wg proporcji)
    bpy.context.view_layer.objects.active = w
    bpy.ops.object.mode_set(mode="EDIT")
    inv = w.matrix_world.inverted()
    eb = w.data.edit_bones
    old = {b.name: (b.head.copy(), b.tail.copy(), b.roll) for b in eb}
    ratio = {}
    for b in order:
        e = eb[b.name]
        h0, t0, roll = old[b.name]
        n = name_r(b.name)
        p = b.parent
        if n in joints and p is not None:
            head = inv @ joints[n]
        elif p is not None:
            head = eb[p.name].head + (h0 - old[p.name][0]) * ratio.get(p.name, 1.0)
        else:
            head = h0
        c = child_of(b)
        if c is not None and n in joints and name_r(c.name) in joints:
            ratio[b.name] = (joints[name_r(c.name)] - joints[n]).length / max(1e-6, (w.matrix_world.to_3x3() @ (
                old[c.name][0] - h0)).length)
        else:
            ratio[b.name] = ratio.get(p.name, 1.0) if p is not None else 1.0
        e.use_connect = False
        e.head = head
        e.tail = head + (t0 - h0) * ratio[b.name]
        e.roll = roll
    bpy.ops.object.mode_set(mode="OBJECT")

    # 4) siatki pod szkielet M2M
    for ob in meshes:
        mw = ob.matrix_world.copy()
        ob.parent = w
        ob.matrix_world = mw
        mod = ob.modifiers.new("M2M", "ARMATURE")
        mod.object = w
    bpy.data.objects.remove(rig)
    act = next(a for a in bpy.data.actions if w.animation_data and a == w.animation_data.action) \
        if w.animation_data and w.animation_data.action else bpy.data.actions[-1]
    f0, f1 = act.frame_range
    # wzrost: od podeszwy do czubka głowy ciała, w spoczynku M2M (T-poza) przed animacją
    rest_low = min((ob.matrix_world @ v.co).z for ob in meshes for v in ob.data.vertices)
    body = next(o for o in meshes if o.name == "Human")
    rest_top = max((body.matrix_world @ v.co).z for v in body.data.vertices)
    w.scale = w.scale * (1.8 / (rest_top - rest_low))

    def stand():
        best = None
        for f in range(int(f0), int(f1)):
            scene.frame_set(f)
            a = w.matrix_world @ w.pose.bones["foot_l"].head
            b = w.matrix_world @ w.pose.bones["foot_r"].head
            d = Vector((a.x - b.x, a.y - b.y)).length
            if best is None or d < best[0]:
                best = (d, f)
        scene.frame_set(best[1])

    return stand, f0, f1, 30.0


SETUP = {"A": lambda: setup_a(), "B": lambda: setup_b(), "C": lambda: setup_c()}
stand, f0, f1, fps = SETUP[VARIANT]()
if VARIANT in ("A", "C"):
    avg = plant(f0, f1)
    rig_a = next(o for o in bpy.data.objects if o.type == "ARMATURE")
    rig_a.scale = rig_a.scale * (1.8 / avg)  # średni wzrost w chodzie = 1,8 m
    plant(f0, f1)
else:
    ground(f0, f1)
fix_action(f0, f1)
pivot = setup_render()
for view, deg in VIEWS.items():
    pivot.rotation_euler = (0, 0, math.radians(deg))
    stand()
    render(os.path.join(OUT, f"{view}_stoi.png"))
    for k in range(FRAMES):
        f = f0 + (f1 - f0) * k / FRAMES
        scene.frame_set(int(f), subframe=f - int(f))
        render(os.path.join(OUT, f"{view}_{k}.png"))
walk_fps = FRAMES / ((f1 - f0) / fps)
with open(os.path.join(OUT, "info.txt"), "w") as fh:
    fh.write(f"wariant {VARIANT} klatki {FRAMES} kl_s {walk_fps:.2f} zakres {f0}-{f1}\n")
print("GOTOWE", OUT, f"{walk_fps:.2f} kl./s")
