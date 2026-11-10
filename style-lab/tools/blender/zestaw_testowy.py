# PROTOTYP (ticket „Rzut, skala i rozdzielczość”): zestaw testowy w rzucie gry, jako prowadnice dla
# generatorów (ComfyUI ControlNet depth, Pixellab/RD jako obraz wejściowy).
# Rzut gry: niskie 3/4 oblique, front w pełnej wysokości, głębia podłogi × df. Odpowiada to kamerze
# ortogonalnej pochylonej o kąt θ = atan(df) od poziomu, z obrazem rozciągniętym w pionie o 1/cos θ.
#
#   blender -b -P tools/blender/zestaw_testowy.py -- --df 0.6 --ppm 256 --out shots/zestaw [--canvas 1024]
#
# --canvas N: stałe płótno N×N (po rozciągnięciu), obiekt na środku; tło depth czarne (dla ControlNet).
#
# Wynik dla każdego obiektu: <nazwa>_szary.png (cieniowany szary box), <nazwa>_depth.png (bliżej =
# jaśniej), oba z kanałem alfa, w skali ppm px/m (po rozciągnięciu w pionie).
import bpy
import math
import os
import sys
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
args = {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv) - 1, 2)}
DF = float(args.get("df", "0.6"))
PPM = int(args.get("ppm", "256"))
OUT = os.path.abspath(args.get("out", "shots/zestaw"))
CANVAS = int(args.get("canvas", "0"))
THETA = math.atan(DF)  # kąt kamery od poziomu
os.makedirs(OUT, exist_ok=True)


def clear():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def box(name, size, at=(0, 0, 0)):
    # size: szerokość (x), głębokość (y, od kamery w głąb), wysokość (z); at: środek dolnej podstawy.
    bpy.ops.mesh.primitive_cube_add(size=1)
    ob = bpy.context.active_object
    ob.name = name
    ob.scale = size
    ob.location = (at[0], at[1] + size[1] / 2, at[2] + size[2] / 2)
    return ob


def mannequin(rot_deg):
    # Dorosły 1,8 m, ok. 7 głów (głowa ~0,257 m), w płaszczu do kolan. Przód patrzy na kamerę (-y).
    u = 1.8 / 7
    parts = []
    parts.append(box("but_l", (0.13, 0.26, 0.06), (-0.1, -0.04, 0)))
    parts.append(box("but_p", (0.13, 0.26, 0.06), (0.1, -0.04, 0)))
    parts.append(box("noga_l", (0.13, 0.15, 2.7 * u), (-0.09, 0.0, 0.06)))
    parts.append(box("noga_p", (0.13, 0.15, 2.7 * u), (0.09, 0.0, 0.06)))
    parts.append(box("plaszcz", (0.48, 0.28, 3.4 * u), (0, -0.02, 2.5 * u)))
    parts.append(box("reka_l", (0.1, 0.12, 2.5 * u), (-0.3, 0.0, 3.2 * u)))
    parts.append(box("reka_p", (0.1, 0.12, 2.5 * u), (0.3, 0.0, 3.2 * u)))
    parts.append(box("szyja", (0.12, 0.12, 0.2 * u), (0, 0.04, 5.85 * u)))
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.5 * u, location=(0, 0.05, 6.5 * u))
    head = bpy.context.active_object
    head.scale = (0.75, 0.85, 1.0)
    parts.append(head)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -0.07, 6.45 * u))
    nose = bpy.context.active_object
    nose.scale = (0.03, 0.06, 0.06)
    parts.append(nose)
    bpy.ops.object.select_all(action="DESELECT")
    for p in parts:
        p.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join()
    ob = bpy.context.active_object
    ob.name = "manekin"
    bpy.context.scene.cursor.location = (0, 0.05, 0)
    bpy.ops.object.origin_set(type="ORIGIN_CURSOR")
    ob.rotation_euler = (0, 0, math.radians(rot_deg))
    return ob


def camera_for(ob):
    # Kamera ortogonalna patrząca w głąb (+y) i w dół o THETA; kadr obejmuje obiekt z marginesem.
    scene = bpy.context.scene
    bpy.context.view_layer.update()  # matrix_world po zmianie skali i położenia
    cam_data = bpy.data.cameras.new("cam")
    cam_data.type = "ORTHO"
    cam = bpy.data.objects.new("cam", cam_data)
    scene.collection.objects.link(cam)
    scene.camera = cam
    cam.rotation_euler = (math.pi / 2 - THETA, 0, 0)
    corners = [ob.matrix_world @ Vector(c) for c in ob.bound_box]
    view = cam.rotation_euler.to_matrix()
    right, up, fwd = view.col[0], view.col[1], -view.col[2]
    xs = [c.dot(right) for c in corners]
    ys = [c.dot(up) for c in corners]
    margin = 0.15
    w = max(xs) - min(xs) + 2 * margin
    h = max(ys) - min(ys) + 2 * margin
    centre = right * (max(xs) + min(xs)) / 2 + up * (max(ys) + min(ys)) / 2
    cam.location = centre - fwd * 20
    cam_data.ortho_scale = max(w, h)
    cam_data.clip_end = 100
    scene.render.resolution_x = max(8, round(w * PPM))
    scene.render.resolution_y = max(8, round(h * PPM))
    if CANVAS:
        # Before the vertical stretch the canvas is shorter by cos θ.
        w, h = CANVAS / PPM, CANVAS * math.cos(THETA) / PPM
        scene.render.resolution_x = CANVAS
        scene.render.resolution_y = round(CANVAS * math.cos(THETA))
        cam_data.ortho_scale = w
    if w < h:
        cam_data.sensor_fit = "VERTICAL"
    else:
        cam_data.sensor_fit = "HORIZONTAL"
    depths = [c.dot(fwd) for c in corners]
    return cam, fwd, min(depths), max(depths)


def stretch(path):
    # Ortho skraca pion o cos θ; gra trzyma front w pełnej wysokości.
    img = bpy.data.images.load(path)
    w, h = img.size
    img.scale(w, round(h / math.cos(THETA)))
    img.filepath_raw = path
    img.save()
    bpy.data.images.remove(img)


def render(name, ob):
    scene = bpy.context.scene
    cam, fwd, near, far = camera_for(ob)
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.view_settings.view_transform = "Standard"
    # 1) szary box: Workbench, płaskie studio, kontur obiektu.
    scene.render.engine = "BLENDER_WORKBENCH"
    shading = scene.display.shading
    shading.light = "STUDIO"
    shading.color_type = "SINGLE"
    shading.single_color = (0.6, 0.6, 0.6)
    shading.show_object_outline = True
    shading.object_outline_color = (0.05, 0.05, 0.05)
    shading.show_cavity = True
    path = os.path.join(OUT, f"{name}_szary.png")
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    stretch(path)
    # 2) depth: EEVEE, emisja = odległość od kamery (bliżej jaśniej).
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
    rng.inputs["From Min"].default_value = near
    rng.inputs["From Max"].default_value = far
    rng.inputs["To Min"].default_value = 1.0
    rng.inputs["To Max"].default_value = 0.15
    emit = nodes.new("ShaderNodeEmission")
    out = nodes.new("ShaderNodeOutputMaterial")
    links.new(geo.outputs["Position"], dot.inputs[0])
    links.new(dot.outputs["Value"], rng.inputs["Value"])
    links.new(rng.outputs["Result"], emit.inputs["Color"])
    links.new(emit.outputs["Emission"], out.inputs["Surface"])
    ob.data.materials.clear()
    ob.data.materials.append(mat)
    if CANVAS:
        scene.render.film_transparent = False
        world = bpy.data.worlds.new("black")
        world.use_nodes = True
        world.node_tree.nodes["Background"].inputs["Color"].default_value = (0, 0, 0, 1)
        world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.0
        scene.world = world
    path = os.path.join(OUT, f"{name}_depth.png")
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    stretch(path)


ITEMS = [
    ("szescian", lambda: box("szescian", (1, 1, 1))),
    ("lada", lambda: box("lada", (2, 0.6, 1))),
    ("manekin_przod", lambda: mannequin(0)),
    ("manekin_bok", lambda: mannequin(90)),
    ("manekin_tyl", lambda: mannequin(180)),
    ("manekin_skos", lambda: mannequin(45)),
]

for name, make in ITEMS:
    clear()
    render(name, make())
    print("render", name)
print("gotowe:", OUT, "df", DF, "theta", round(math.degrees(THETA), 1))
