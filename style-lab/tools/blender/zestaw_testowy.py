# Prowadnice v2 (ticket silnika 01): z jednej sceny Blendera z meblem powstaje komplet zgodny co do piksela.
#
#   Scena mebla ma dwie kolekcje:
#     Model  - model do prowadnic (dowolnie szczegółowy, modyfikatory dozwolone);
#     Bryly  - uproszczone Bryły dla Silnika światła: pudełka wyrównane do osi (uniesione, gdy spód nad
#              podłogą); walec = obiekt z własnością "bryla" = "walec" (oś pionowa, promień z szerokości).
#   Punkt zaczepienia = środek przedniej dolnej krawędzi obrysu Brył (x środka, najbliższe y, z = 0).
#
#   blender -b mebel.blend -P tools/blender/zestaw_testowy.py -- --out shots/prowadnice_v2
#   blender -b -P tools/blender/zestaw_testowy.py -- --out shots/prowadnice_v2 [--tylko lada]
#       (bez pliku .blend: trzy meble testowe lada, stol, fotel; ich sceny zapisuje jako <mebel>.blend)
#   Opcje: --df 0.6 (kąt gry), --ppm 40 (px/m gry), --k 8 (prowadnice w k × ppm px/m),
#          --plotno N (płótno N×N px gry, domyślnie 128 albo więcej, gdy mebel się nie mieści).
#
# Rzut gry (niskie 3/4 oblique): ekran x = x, ekran w górę = z + df·y. Zamiast rozciągać obraz w pionie
# (resampling) geometria jest ścinana (z += df·y) i renderowana kamerą ortho z przodu; widoczność jest ta
# sama co z kamery pochylonej o atan(df). Normalne, cieniowanie i głębia liczone z geometrii przed ścięciem.
#
# Wynik w <out>/<mebel>/ (płótno wielokrotnością siatki pikseli gry, punkt zaczepienia na rogu piksela):
#   prowadnica_szary.png  szary render na jasnoszarym tle z konturem (wejście Qwen-Image-Edit, jak manekin MPFB)
#   prowadnica_depth.png  głębia dla ControlNet (bliżej jaśniej, tło czarne)
#   maska.png, normalne.png             w k × ppm px/m (jak prowadnice)
#   maska_gra.png, normalne_gra.png     w ppm px/m (płótno / k)
#   bryly.json            Bryły w metrach względem punktu zaczepienia, płótno i punkt zaczepienia w px
#   kontrola.png          maska i normalne z konturem Brył (renderowanych z bryly.json)
# Normalne świata: kolor = 128 + 127·(nx, nz, −ny), tj. R w prawo, G w górę, B do kamery (front).
import json
import math
import os
import sys

import bpy
import numpy as np
from bpy_extras.object_utils import world_to_camera_view
from mathutils import Vector

MODEL = "Model"
BRYLY = "Bryly"
DF = 0.6
PPM_GRA = 40
K = 10  # 400 px/m, ta sama skala co manekin MPFB w Przepisie postaci
PLOTNO_MIN = 96  # px gry; × k = 960 px prowadnic
MARGINES = 4  # px gry wokół mebla
TLO_SZARE = (0.807, 0.82, 0.84)  # jasnoszare tło manekina MPFB (sRGB)
ZRODLO_SZAREGO = Vector((-0.45, -0.55, 0.7)).normalized()  # światło szarego renderu: lewo, przód, góra
KOLOR_MASKI = (150, 150, 150)
KOLOR_TLA_KONTROLI = (36, 36, 44)


# --- scena ---------------------------------------------------------------------------------------------

def nowa_scena():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def kolekcja(nazwa):
    col = bpy.data.collections.get(nazwa)
    if col is None:
        col = bpy.data.collections.new(nazwa)
        bpy.context.scene.collection.children.link(col)
    return col


def geometria_pudelka(lo, hi):
    # Wierzchołki i ściany (normalne na zewnątrz) pudełka od lo do hi; ściany: spód, wierzch, przód, tył, lewo, prawo.
    v = [(x, y, z) for z in (lo[2], hi[2]) for y in (lo[1], hi[1]) for x in (lo[0], hi[0])]
    return v, [(0, 2, 3, 1), (4, 5, 7, 6), (0, 1, 5, 4), (2, 6, 7, 3), (0, 4, 6, 2), (1, 3, 7, 5)]


def geometria_walca(srodek, r, z0, z1, segmenty=24):
    # Wierzchołki i ściany walca o osi pionowej; ściany: spód, wierzch, potem boki.
    v = [(srodek[0] + r * math.cos(2 * math.pi * i / segmenty), srodek[1] + r * math.sin(2 * math.pi * i / segmenty), z)
         for z in (z0, z1) for i in range(segmenty)]
    f = [tuple(reversed(range(segmenty))), tuple(range(segmenty, 2 * segmenty))]
    f += [(i, (i + 1) % segmenty, segmenty + (i + 1) % segmenty, segmenty + i) for i in range(segmenty)]
    return v, f


def pudelko(name, size, at, col, faza=0.0, segmenty=1):
    # size: szerokość (x), głębokość (y, od kamery w głąb), wysokość (z); at: środek przedniej dolnej krawędzi.
    lo = (at[0] - size[0] / 2, at[1], at[2])
    v, f = geometria_pudelka(lo, [lo[i] + size[i] for i in range(3)])
    me = bpy.data.meshes.new(name)
    me.from_pydata(v, [], f)
    me.update()
    ob = bpy.data.objects.new(name, me)
    col.objects.link(ob)
    if faza > 0:
        for p in me.polygons:
            p.use_smooth = True
        mod = ob.modifiers.new("faza", "BEVEL")
        mod.width = faza
        mod.segments = segmenty
        mod.harden_normals = True
    return ob


def walec(name, r, z0, z1, srodek, col, segmenty=24):
    v, f = geometria_walca(srodek, r, z0, z1, segmenty)
    me = bpy.data.meshes.new(name)
    me.from_pydata(v, [], f)
    me.update()
    for p in me.polygons[2:]:
        p.use_smooth = True
    ob = bpy.data.objects.new(name, me)
    col.objects.link(ob)
    return ob


# --- meble testowe -------------------------------------------------------------------------------------

def lada():
    m, b = kolekcja(MODEL), kolekcja(BRYLY)
    pudelko("cokol", (1.94, 0.5, 0.08), (0, 0.07, 0), m)
    pudelko("korpus", (2.0, 0.57, 0.88), (0, 0.03, 0.08), m)
    for x in (-0.5, 0.5):
        pudelko(f"drzwiczki_{x}", (0.92, 0.02, 0.78), (x, 0.01, 0.13), m, faza=0.01, segmenty=2)
    pudelko("blat", (2.04, 0.64, 0.04), (0, -0.01, 0.96), m, faza=0.008, segmenty=2)
    pudelko("lada", (2.0, 0.6, 1.0), (0, 0, 0), b)


def stol():
    m, b = kolekcja(MODEL), kolekcja(BRYLY)
    pudelko("plyta", (1.2, 0.8, 0.04), (0, 0, 0.72), m, faza=0.012, segmenty=3)
    pudelko("oskrzynia", (1.06, 0.66, 0.08), (0, 0.07, 0.64), m)
    pudelko("blat", (1.2, 0.8, 0.12), (0, 0, 0.64), b)
    for i, (x, y) in enumerate(((-0.53, 0.04), (0.53, 0.04), (-0.53, 0.71), (0.53, 0.71))):
        pudelko(f"toczona_noga_{i}", (0.05, 0.05, 0.64), (x, y, 0), m, faza=0.006, segmenty=2)
        pudelko(f"noga_{i}", (0.05, 0.05, 0.64), (x, y, 0), b)


def fotel():
    m, b = kolekcja(MODEL), kolekcja(BRYLY)
    pudelko("podstawa", (0.62, 0.62, 0.34), (0, 0.06, 0.08), m, faza=0.04, segmenty=4)
    pudelko("poduszka", (0.6, 0.58, 0.12), (0, 0.05, 0.4), m, faza=0.05, segmenty=5)
    pudelko("rama_oparcia", (0.86, 0.22, 0.78), (0, 0.63, 0.08), m, faza=0.08, segmenty=6)
    for x in (-0.36, 0.36):
        pudelko(f"boczek_{x}", (0.14, 0.8, 0.56), (x, 0.05, 0.08), m, faza=0.065, segmenty=6)
    for x, y in ((-0.36, 0.1), (0.36, 0.1), (-0.36, 0.78), (0.36, 0.78)):
        walec(f"nozka_{x}_{y}", 0.025, 0, 0.08, (x, y), m, segmenty=12)
    pudelko("siedzisko", (0.58, 0.58, 0.52), (0, 0.05, 0), b)
    pudelko("oparcie", (0.86, 0.22, 0.86), (0, 0.63, 0), b)
    for x in (-0.36, 0.36):
        pudelko(f"podlokietnik_{x}", (0.14, 0.58, 0.64), (x, 0.05, 0), b)


MEBLE = {"lada": lada, "stol": stol, "fotel": fotel}


# --- rzut i układ płótna (czysta logika) ------------------------------------------------------------------

def rzut(p, df):
    # Punkt świata (m) → ekran (m): x w prawo, u w górę.
    return p[0], p[2] + df * p[1]


def kierunek_kamery(df):
    t = math.atan(df)
    return Vector((0.0, math.cos(t), -math.sin(t)))


def _w_gore(v, krok):
    return int(math.ceil(v / krok - 1e-9) * krok)


def uklad_plotna(zakres, ppm, plotno=None, margines=MARGINES, krok=8):
    # zakres: (lewo, prawo, dol, gora) w m ekranu względem punktu zaczepienia (lewo, dol ≤ 0).
    # Wynik: (w, h, ax, ay) w px gry; punkt zaczepienia na rogu piksela (ax, ay od lewego górnego rogu).
    lewo, prawo, dol, gora = zakres
    pol = max(math.ceil(-lewo * ppm - 1e-6), math.ceil(prawo * ppm - 1e-6)) + margines
    U = max(0, math.ceil(gora * ppm - 1e-6))
    D = max(0, math.ceil(-dol * ppm - 1e-6))
    if plotno is None:
        w = h = max(PLOTNO_MIN, _w_gore(2 * pol, krok), _w_gore(U + D + 2 * margines, krok))
    else:
        w = h = int(plotno)
    if w % 2:
        raise ValueError(f"płótno {w} px: potrzebna parzysta szerokość (punkt zaczepienia na środku)")
    ax = w // 2
    ay = (h - (U + D)) // 2 + U
    if pol > ax or ay - U < margines or ay + D > h - margines:
        raise ValueError(f"mebel nie mieści się w płótnie {w}×{h} px; podaj większe --plotno")
    return w, h, ax, ay


def bryly_z_obrysow(obrysy):
    # obrysy: [(nazwa, typ lub None, lo, hi)] w m świata. Wynik: (punkt zaczepienia w świecie, lista Brył
    # w m względem punktu zaczepienia).
    if not obrysy:
        raise ValueError("kolekcja Bryly jest pusta")
    lo = [min(o[2][i] for o in obrysy) for i in range(3)]
    hi = [max(o[3][i] for o in obrysy) for i in range(3)]
    zacz = ((lo[0] + hi[0]) / 2, lo[1], 0.0)
    wynik = []
    for nazwa, typ, a, b in obrysy:
        a = [round(a[i] - zacz[i], 5) for i in range(3)]
        b = [round(b[i] - zacz[i], 5) for i in range(3)]
        if min(b[i] - a[i] for i in range(3)) <= 1e-6:
            raise ValueError(f"Bryła {nazwa} ma zerowy wymiar")
        if typ == "walec":
            wynik.append({"nazwa": nazwa, "typ": "walec", "srodek": [round((a[0] + b[0]) / 2, 5),
                          round((a[1] + b[1]) / 2, 5)], "promien": round((b[0] - a[0]) / 2, 5), "z": [a[2], b[2]]})
        elif typ in (None, "pudelko", "uniesione"):
            wynik.append({"nazwa": nazwa, "typ": "uniesione" if a[2] > 1e-6 else "pudelko", "min": a, "max": b})
        else:
            raise ValueError(f"Bryła {nazwa}: nieznany typ {typ!r} (pudelko, uniesione, walec)")
    return zacz, wynik


# --- obrazy (numpy) ---------------------------------------------------------------------------------------

def pomniejsz(a, k):
    h, w = a.shape[0] // k, a.shape[1] // k
    return a.reshape(h, k, w, k, *a.shape[2:]).mean(axis=(1, 3))


def koduj_normalne(n):
    return np.clip(np.round(128 + 127 * n), 0, 255).astype(np.uint8)


def normalne_z_atrybutu(rgb):
    # Atrybut renderu: (nx, nz, −ny) zakodowane 0,5 + 0,5·n; wynik: wektor (R, G, B) do kodowania, długość 1.
    n = rgb * 2 - 1
    d = np.linalg.norm(n, axis=-1, keepdims=True)
    return n / np.maximum(d, 1e-8)


def kontur(ids):
    # ids: -1 poza Bryłami. Piksel konturu = inny identyfikator u sąsiada w prawo albo w dół.
    k = np.zeros(ids.shape, bool)
    r = ids[:, 1:] != ids[:, :-1]
    d = ids[1:, :] != ids[:-1, :]
    k[:, 1:] |= r
    k[:, :-1] |= r
    k[1:, :] |= d
    k[:-1, :] |= d
    return k


def zapisz_png(path, a):
    # a: uint8 (h, w, 3|4), wiersz 0 na górze.
    h, w = a.shape[:2]
    if a.shape[2] == 3:
        a = np.concatenate([a, np.full((h, w, 1), 255, np.uint8)], axis=2)
    img = bpy.data.images.new(os.path.basename(path), w, h, alpha=True)
    img.colorspace_settings.name = "Non-Color"
    img.pixels.foreach_set((a[::-1].astype(np.float32) / 255).ravel())
    img.filepath_raw = path
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)


# --- render ---------------------------------------------------------------------------------------------

def _siatka_obiektu(ob, dg):
    # Wierzchołki w świecie, ściany i normalne narożników (świat) z modyfikatorami.
    ev = ob.evaluated_get(dg)
    me = ev.to_mesh()
    mw = ob.matrix_world
    nm = mw.to_3x3().inverted().transposed()
    v = [mw @ p.co for p in me.vertices]
    f = [tuple(p.vertices) for p in me.polygons]
    n = [(nm @ c.vector).normalized() for c in me.corner_normals]
    ev.to_mesh_clear()
    return v, f, n


def _kopia_scieta(name, v, f, atrybuty, df, col):
    # Siatka ścięta do rzutu gry (z += df·y) z atrybutami narożników {nazwa: [(r, g, b)]}.
    me = bpy.data.meshes.new(name)
    me.from_pydata([(p.x, p.y, p.z + df * p.y) for p in v], [], f)
    me.update()
    for nazwa, wartosci in atrybuty.items():
        a = me.color_attributes.new(nazwa, "FLOAT_COLOR", "CORNER")
        a.data.foreach_set("color", np.array([(*c, 1.0) for c in wartosci], np.float32).ravel())
    ob = bpy.data.objects.new(name, me)
    col.objects.link(ob)
    return ob


def _bryly_do_siatek(bryly, zacz):
    # Siatki Brył odtworzone z eksportu (m względem punktu zaczepienia) z identyfikatorem ściany.
    wynik = []
    for i, b in enumerate(bryly):
        if b["typ"] == "walec":
            v, f = geometria_walca(b["srodek"], b["promien"], *b["z"])
            sciany = [0, 1] + [2] * (len(f) - 2)
        else:
            v, f = geometria_pudelka(b["min"], b["max"])
            sciany = list(range(6))
        v = [Vector(p) + Vector(zacz) for p in v]
        ids = [float(i * 8 + s) for s, sciana in zip(sciany, f) for _ in sciana]
        wynik.append((b["nazwa"], v, f, ids))
    return wynik


def _kamera(srodek, w, h, ppm, col):
    cam_data = bpy.data.cameras.new("kamera_prowadnic")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = max(w, h) / ppm
    cam_data.sensor_fit = "HORIZONTAL" if w >= h else "VERTICAL"
    cam_data.clip_start = 0.01
    cam_data.clip_end = 500
    cam = bpy.data.objects.new("kamera_prowadnic", cam_data)
    col.objects.link(cam)
    cam.rotation_euler = (math.pi / 2, 0, 0)
    cam.location = (srodek[0], -100, srodek[1])
    return cam


def _render(path, atrybut, obiekty, aa, tlo=None, kontur_obiektu=False):
    sc = bpy.context.scene
    for ob in obiekty:
        ob.data.color_attributes.active_color = ob.data.color_attributes[atrybut]
    sc.display.render_aa = aa
    sh = sc.display.shading
    sh.show_object_outline = kontur_obiektu
    sc.render.film_transparent = tlo is None
    if tlo is not None:
        sc.world.color = tlo
    sc.render.filepath = path
    bpy.ops.render.render(write_still=True)
    img = bpy.data.images.load(path)
    w, h = img.size
    a = np.empty(w * h * 4, np.float32)
    img.pixels.foreach_get(a)
    bpy.data.images.remove(img)
    os.remove(path)
    return a.reshape(h, w, 4)[::-1]


def _ustaw_render(w, h):
    sc = bpy.context.scene
    sc.render.engine = "BLENDER_WORKBENCH"
    sc.render.resolution_x = w
    sc.render.resolution_y = h
    sc.render.resolution_percentage = 100
    sc.render.dither_intensity = 0
    sc.view_settings.view_transform = "Raw"
    sc.render.image_settings.file_format = "OPEN_EXR"
    sc.render.image_settings.color_depth = "32"
    sc.render.image_settings.color_mode = "RGBA"
    if sc.world is None:
        sc.world = bpy.data.worlds.new("tlo")
    sh = sc.display.shading
    sh.light = "FLAT"
    sh.color_type = "VERTEX"
    sh.background_type = "WORLD"
    sh.show_cavity = False
    sh.object_outline_color = (0.05, 0.05, 0.05)


def _obiekty(col):
    return [o for o in col.all_objects if o.type in {"MESH", "CURVE", "SURFACE", "META", "FONT"}]


def _obrys_bryly(ob):
    m = ob.matrix_world.to_3x3()
    for j in range(3):
        if sum(abs(m[i][j]) > 1e-6 for i in range(3)) != 1:
            raise ValueError(f"Bryła {ob.name} jest obrócona poza osie świata")
    pts = [ob.matrix_world @ Vector(c) for c in ob.bound_box]
    lo = [min(p[i] for p in pts) for i in range(3)]
    hi = [max(p[i] for p in pts) for i in range(3)]
    return ob.name, ob.get("bryla"), lo, hi


def przetworz(nazwa, out, df=DF, ppm=PPM_GRA, k=K, plotno=None):
    # Bieżąca scena (kolekcje Model i Bryly) → komplet w <out>/<nazwa>/. Zwraca obrazy gry i miary zgodności.
    for c in (MODEL, BRYLY):
        if c not in bpy.data.collections:
            raise ValueError(f"brak kolekcji {c}")
    bpy.context.view_layer.update()
    katalog = os.path.abspath(os.path.join(out, nazwa))
    os.makedirs(katalog, exist_ok=True)
    model_col, bryly_col = bpy.data.collections[MODEL], bpy.data.collections[BRYLY]
    zacz, bryly = bryly_z_obrysow([_obrys_bryly(o) for o in _obiekty(bryly_col)])

    dg = bpy.context.evaluated_depsgraph_get()
    siatki = [(o.name, *_siatka_obiektu(o, dg)) for o in _obiekty(model_col)]
    if not siatki:
        raise ValueError("kolekcja Model jest pusta")
    bryly_siatki = _bryly_do_siatek(bryly, zacz)
    wszystkie = [p for s in siatki for p in s[1]] + [p for s in bryly_siatki for p in s[1]]
    ekran = [rzut(p - Vector(zacz), df) for p in wszystkie]
    zakres = (min(e[0] for e in ekran), max(e[0] for e in ekran), min(e[1] for e in ekran), max(e[1] for e in ekran))
    w, h, ax, ay = uklad_plotna(zakres, ppm, plotno)
    W, H, AX, AY = w * k, h * k, ax * k, ay * k
    ppm_hi = ppm * k

    fwd = kierunek_kamery(df)
    glebie = [p.dot(fwd) for s in siatki for p in s[1]]
    blisko, daleko = min(glebie), max(glebie)
    rozpietosc = max(daleko - blisko, 1e-6)

    ukryte = (model_col.hide_render, bryly_col.hide_render)
    model_col.hide_render = bryly_col.hide_render = True
    robocza = kolekcja("_prowadnice")
    sc = bpy.context.scene
    try:
        modele = []
        for name, v, f, n in siatki:
            rogi = [v[i] for sciana in f for i in sciana]
            normalne = [(0.5 + 0.5 * c.x, 0.5 + 0.5 * c.z, 0.5 - 0.5 * c.y) for c in n]
            szary = [(min(1.0, 0.6 * (0.35 + 0.75 * max(0.0, c.dot(ZRODLO_SZAREGO)))),) * 3 for c in n]
            g = [1.0 - 0.85 * (p.dot(fwd) - blisko) / rozpietosc for p in rogi]
            modele.append(_kopia_scieta(f"_{name}", v, f, {"normalne": normalne, "szary": szary,
                                                           "glebia": [(x, x, x) for x in g]}, df, robocza))
        bryly_ob = [_kopia_scieta(f"_bryla_{name}", v, f, {"id": [(x, x, x) for x in ids]}, df, robocza)
                    for name, v, f, ids in bryly_siatki]

        _ustaw_render(W, H)
        zacz_ekran = rzut(zacz, df)
        srodek = (zacz_ekran[0] + (W / 2 - AX) / ppm_hi, zacz_ekran[1] + (AY - H / 2) / ppm_hi)
        cam = _kamera(srodek, W, H, ppm_hi, robocza)
        sc.camera = cam
        bpy.context.view_layer.update()
        # Punkt zaczepienia z kamery: musi wypaść na rogu piksela gry.
        pz = world_to_camera_view(sc, cam, Vector((zacz[0], zacz[1], zacz[2] + df * zacz[1])))
        zacz_px = (pz.x * W, (1 - pz.y) * H)
        if abs(zacz_px[0] - AX) > 1e-2 or abs(zacz_px[1] - AY) > 1e-2:
            raise RuntimeError(f"punkt zaczepienia z kamery {zacz_px} ≠ ({AX}, {AY})")

        tmp = os.path.join(katalog, "_pass.exr")
        for o in bryly_ob:
            o.hide_render = True
        n_hi = _render(tmp, "normalne", modele, "OFF")
        szary = _render(tmp, "szary", modele, "8", TLO_SZARE, kontur_obiektu=True)
        depth = _render(tmp, "glebia", modele, "8", (0, 0, 0))
        for o in modele:
            o.hide_render = True
        for o in bryly_ob:
            o.hide_render = False
        id_hi = _render(tmp, "id", bryly_ob, "OFF")
    finally:
        model_col.hide_render, bryly_col.hide_render = ukryte
        for o in list(robocza.objects):
            dane = o.data
            bpy.data.objects.remove(o)
            if isinstance(dane, bpy.types.Mesh):
                bpy.data.meshes.remove(dane)
            elif isinstance(dane, bpy.types.Camera):
                bpy.data.cameras.remove(dane)
        bpy.data.collections.remove(robocza)

    maska_hi = n_hi[..., 3] > 0.5
    nv = normalne_z_atrybutu(n_hi[..., :3])
    maska_gra = pomniejsz(maska_hi.astype(np.float32), k) >= 0.5
    suma = pomniejsz(nv * maska_hi[..., None], k)
    n_gra = suma / np.maximum(np.linalg.norm(suma, axis=-1, keepdims=True), 1e-8)
    bryly_hi = id_hi[..., 3] > 0.5
    bryly_gra = pomniejsz(bryly_hi.astype(np.float32), k) >= 0.5
    ids = np.where(bryly_hi, np.round(id_hi[..., 0]), -1)
    zgodnosc = float((maska_gra & bryly_gra).sum()) / max(1, float((maska_gra | bryly_gra).sum()))

    def rgba(n, m):
        return np.concatenate([koduj_normalne(n), (m * 255).astype(np.uint8)[..., None]], axis=2)

    def bajty(a):
        return np.clip(np.round(a[..., :3] * 255), 0, 255).astype(np.uint8)

    biel = np.full(maska_hi.shape + (3,), 255, np.uint8)
    normalne_gra = rgba(n_gra, maska_gra)
    zapisz_png(os.path.join(katalog, "prowadnica_szary.png"), bajty(szary))
    zapisz_png(os.path.join(katalog, "prowadnica_depth.png"), bajty(depth))
    zapisz_png(os.path.join(katalog, "maska.png"), np.concatenate([biel, (maska_hi * 255).astype(np.uint8)[..., None]], 2))
    zapisz_png(os.path.join(katalog, "maska_gra.png"), np.concatenate(
        [biel[:h, :w], (maska_gra * 255).astype(np.uint8)[..., None]], 2))
    zapisz_png(os.path.join(katalog, "normalne.png"), rgba(nv, maska_hi))
    zapisz_png(os.path.join(katalog, "normalne_gra.png"), normalne_gra)

    # Kontrola: maska | normalne, oba z konturem Brył (pogrubionym do 2 px).
    kt = kontur(ids)
    kt[1:, :] |= kt[:-1, :]
    kt[:, 1:] |= kt[:, :-1]
    tlo = np.empty(maska_hi.shape + (3,), np.uint8)
    tlo[:] = KOLOR_TLA_KONTROLI
    lewy = tlo.copy()
    lewy[maska_hi] = KOLOR_MASKI
    lewy[kt] = (255, 60, 60)
    prawy = tlo.copy()
    prawy[maska_hi] = koduj_normalne(nv)[maska_hi]
    prawy[kt] = (255, 0, 255)
    odstep = np.full((H, 8, 3), 255, np.uint8)
    zapisz_png(os.path.join(katalog, "kontrola.png"), np.concatenate([lewy, odstep, prawy], axis=1))

    dane = {
        "mebel": nazwa,
        "jednostki": "m",
        "osie": "x w prawo, y w głąb (od kamery), z w górę; początek = punkt zaczepienia "
                "(środek przedniej dolnej krawędzi obrysu Brył)",
        "kat": df,
        "ppm_gra": ppm,
        "k": k,
        "plotno_gra": [w, h],
        "zaczepienie_gra": [ax, ay],
        "plotno_prowadnic": [W, H],
        "zaczepienie_prowadnic": [AX, AY],
        "normalne": "kolor = 128 + 127·(nx, nz, −ny): R w prawo, G w górę, B do kamery",
        "zgodnosc_bryl": round(zgodnosc, 4),
        "bryly": bryly,
    }
    with open(os.path.join(katalog, "bryly.json"), "w", encoding="utf-8") as fh:
        json.dump(dane, fh, ensure_ascii=False, indent=2)

    print(f"prowadnice {nazwa}: płótno {w}×{h} px gry, zaczepienie ({ax}, {ay}), zgodność Brył {zgodnosc:.3f}")
    return {"maska_gra": maska_gra, "normalne_gra": normalne_gra, "zaczepienie_gra": (ax, ay),
            "zgodnosc_bryl": round(zgodnosc, 4), "bryly": bryly, "katalog": katalog}


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    args = {argv[i].lstrip("-"): argv[i + 1] for i in range(0, len(argv) - 1, 2)}
    out = os.path.abspath(args.get("out", "shots/prowadnice_v2"))
    opcje = {"df": float(args.get("df", DF)), "ppm": int(args.get("ppm", PPM_GRA)), "k": int(args.get("k", K)),
             "plotno": int(args["plotno"]) if "plotno" in args else None}
    if bpy.data.filepath and MODEL in bpy.data.collections:
        przetworz(os.path.splitext(os.path.basename(bpy.data.filepath))[0], out, **opcje)
        return
    for nazwa, zbuduj in MEBLE.items():
        if args.get("tylko", nazwa) != nazwa:
            continue
        nowa_scena()
        zbuduj()
        os.makedirs(os.path.join(out, nazwa), exist_ok=True)
        bpy.ops.wm.save_as_mainfile(filepath=os.path.join(out, nazwa, f"{nazwa}.blend"))
        przetworz(nazwa, out, **opcje)
    print("gotowe:", out)


if __name__ == "__main__":
    main()
