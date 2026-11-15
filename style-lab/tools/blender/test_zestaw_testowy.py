# Testy prowadnic v2 (zestaw_testowy.py). Uruchamiane w Blenderze, z style-lab/:
#
#   blender -b --factory-startup -P tools/blender/test_zestaw_testowy.py --python-exit-code 1
#
# Kod wyjścia 1 = któryś test nie przeszedł.
import json
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import zestaw_testowy as zt  # noqa: E402

OUT = os.path.join(tempfile.gettempdir(), "test_prowadnice_v2")


def pudelko_jako_model_i_bryla(size, at=(0, 0, 0)):
    zt.nowa_scena()
    zt.pudelko("model", size, at, zt.kolekcja(zt.MODEL))
    zt.pudelko("bryla", size, at, zt.kolekcja(zt.BRYLY))


class PrzetworzenieSceny(unittest.TestCase):
    def test_lada_2x06x1_daje_maske_80x54_nad_punktem_zaczepienia(self):
        # 40 px/m, kąt 0,60: front 2 m × 1 m = 80 × 40 px, wierzch 0,6 m × 0,60 = 0,36 m = 14 px.
        pudelko_jako_model_i_bryla((2, 0.6, 1))
        w = zt.przetworz("pudelko", OUT)
        maska = w["maska_gra"]
        rows, cols = maska.nonzero()
        ax, ay = w["zaczepienie_gra"]
        self.assertEqual(cols.max() - cols.min() + 1, 80)
        self.assertEqual(rows.max() - rows.min() + 1, 54)
        self.assertEqual(cols.min(), ax - 40)
        self.assertEqual(rows.max() + 1, ay)
        self.assertEqual(maska.sum(), 80 * 54)

    def test_normalne_wierzch_i_front(self):
        # Kodowanie normalnych świata: R = +x (prawo), G = +z (góra), B = −y (do kamery).
        pudelko_jako_model_i_bryla((1, 1, 1))
        w = zt.przetworz("pudelko_bok", OUT)
        n = w["normalne_gra"]
        ax, ay = w["zaczepienie_gra"]
        front = n[ay - 20, ax - 4][:3]
        wierzch = n[ay - 52, ax - 4][:3]
        self.assertEqual(tuple(front), (128, 128, 255))
        self.assertEqual(tuple(wierzch), (128, 255, 128))

    def test_kontur_bryl_pokrywa_sylwetke(self):
        pudelko_jako_model_i_bryla((1.2, 0.8, 0.76))
        w = zt.przetworz("pudelko_iou", OUT)
        self.assertEqual(w["zgodnosc_bryl"], 1.0)
        self.assertTrue(os.path.isfile(os.path.join(OUT, "pudelko_iou", "kontrola.png")))


class EksportBryl(unittest.TestCase):
    def test_stol_blat_uniesiony_nogi_pudelka_w_metrach_od_zaczepienia(self):
        zt.nowa_scena()
        zt.stol()
        w = zt.przetworz("stol_eksport", OUT)
        bryly = {b["nazwa"]: b for b in w["bryly"]}
        self.assertEqual(bryly["blat"]["typ"], "uniesione")
        self.assertEqual(bryly["blat"]["min"], [-0.6, 0.0, 0.64])
        self.assertEqual(bryly["blat"]["max"], [0.6, 0.8, 0.76])
        self.assertEqual(bryly["noga_0"]["typ"], "pudelko")
        self.assertEqual(bryly["noga_0"]["min"], [-0.555, 0.04, 0.0])
        with open(os.path.join(w["katalog"], "bryly.json"), encoding="utf-8") as fh:
            self.assertEqual(json.load(fh)["bryly"], w["bryly"])

    def test_walec_z_wlasnosci_bryla(self):
        zt.nowa_scena()
        zt.pudelko("model", (0.4, 0.4, 1), (2, 1, 0), zt.kolekcja(zt.MODEL))
        ob = zt.walec("pien", 0.2, 0, 1, (2, 1.2), zt.kolekcja(zt.BRYLY))
        ob["bryla"] = "walec"
        w = zt.przetworz("walec", OUT)
        b = w["bryly"][0]
        self.assertEqual((b["typ"], b["promien"], b["z"]), ("walec", 0.2, [0.0, 1.0]))
        self.assertEqual(b["srodek"], [0.0, 0.2])

    def test_obrocona_bryla_odrzucona(self):
        pudelko_jako_model_i_bryla((1, 1, 1))
        zt.bpy.data.objects["bryla"].rotation_euler = (0, 0, 0.3)
        with self.assertRaises(ValueError):
            zt.przetworz("obrocona", OUT)


class UkladPlotna(unittest.TestCase):
    def test_zaczepienie_na_srodku_i_mebel_wysrodkowany_w_pionie(self):
        # Lada: 1 m w lewo i w prawo, 1,36 m w górę → 55 px treści (zaokrąglone w górę) na płótnie 96.
        self.assertEqual(zt.uklad_plotna((-1, 1, 0, 1.36), 40), (96, 96, 48, 75))

    def test_duzy_mebel_powieksza_plotno_do_wielokrotnosci_8(self):
        w, h, ax, ay = zt.uklad_plotna((-2, 2, 0, 1), 40)
        self.assertEqual((w, h, ax), (168, 168, 84))

    def test_za_male_plotno_to_blad(self):
        with self.assertRaises(ValueError):
            zt.uklad_plotna((-2, 2, 0, 1), 40, plotno=64)


if __name__ == "__main__":
    wynik = unittest.main(argv=["test"], exit=False).result
    sys.exit(0 if wynik.wasSuccessful() else 1)
