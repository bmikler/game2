"""Orient Anything V1 Large: azymut / polar / rotacja / pewnosc dla obrazow (CSV na stdout).

Uruchamiac venv-em tools/orient/venv (dziedziczy torcha z ComfyUI, tylko do odczytu). CPU domyslnie.

  venv\\Scripts\\python.exe measure.py obraz1.png obraz2.png ...
  venv\\Scripts\\python.exe measure.py --aug 8 --sim koncept.png katalog\\*.png

Jednostki: azymut 0..360 (0 = przodem do kamery wg modelu), polar -90..90 (dodatni = kamera z gory,
potwierdzone empirycznie w docs/research/73), rotacja -90..90 (180 binow w tym checkpoincie), pewnosc 0..1.
Przetwarzanie: tlo -> jasnoszare (alfa kompozytowana na to samo szare; obrazy generowane: maska z
odleglosci od koloru tla), kadr do bbox pierwszego planu, kwadrat, pierwszy plan = 85% boku.
--aug N: N deterministycznych wariantow (przesuniecie/skala/odbicie nie; tylko kadr+przesuniecie),
raportuje srednia (azymut kolowo) i odchylenie std.
"""
import argparse
import csv
import glob
import math
import os
import sys

import numpy as np
import torch
import torch.nn as nn
from PIL import Image
from scipy import ndimage
from transformers import Dinov2Config, Dinov2Model

HERE = os.path.dirname(os.path.abspath(__file__))
GREY = (193, 193, 193)
FILL = 0.85
MEAN = np.array([0.485, 0.456, 0.406], dtype=np.float32)
STD = np.array([0.229, 0.224, 0.225], dtype=np.float32)


def find_file(root, name):
    for dp, _, fs in os.walk(root):
        if name in fs and "snapshots" in dp:
            return os.path.join(dp, name)
    return None


class OrientNet(nn.Module):
    """DINOv2-Large + MLP (1024 -> 722 = 360+180+180+2), jak DINOv2_MLP w repo (bez pobierania wag DINOv2-L:
    wagi sa w checkpoincie Orient Anything, konfiguracja wpisana recznie)."""

    def __init__(self):
        super().__init__()
        cfg = Dinov2Config(hidden_size=1024, num_hidden_layers=24, num_attention_heads=16,
                           patch_size=14, image_size=518, layerscale_value=1.0, mlp_ratio=4,
                           use_swiglu_ffn=False, qkv_bias=True, drop_path_rate=0.0)
        self.dinov2 = Dinov2Model(cfg)
        self.down_sampler = nn.Sequential()
        self.down_sampler.net1 = nn.Sequential(nn.Linear(1024, 722), nn.BatchNorm1d(722), nn.ReLU())
        self.down_sampler.net2 = nn.Sequential(nn.Linear(722, 722), nn.BatchNorm1d(722))

    def forward(self, x):
        h = self.dinov2(pixel_values=x).last_hidden_state[:, 0, :]
        return self.down_sampler.net2(self.down_sampler.net1(h))


def load_orient(device):
    ck = find_file(os.path.join(HERE, "weights", "models--Viglong--Orient-Anything"), "dino_weight.pt")
    if ck is None:
        sys.exit("brak wag Orient Anything w weights/ (uruchom dl.py)")
    sd = torch.load(ck, map_location="cpu")
    sd = {k.replace("attention.attention.query", "attention.q_proj").replace("attention.attention.key", "attention.k_proj").replace("attention.attention.value", "attention.v_proj").replace("attention.output.dense", "attention.o_proj"): v for k, v in sd.items()}  # transformers 5 zmienilo nazwy
    net = OrientNet()
    # klucze checkpointu: dinov2.*, down_sampler.net1.*, down_sampler.net2.*
    missing, unexpected = net.load_state_dict(sd, strict=False)
    real_missing = [k for k in missing if "position_ids" not in k]
    if real_missing or unexpected:
        sys.exit(f"niezgodne klucze: missing={real_missing[:5]} unexpected={unexpected[:5]}")
    return net.eval().to(device)


def load_dino_base(device):
    d = os.path.join(HERE, "weights", "models--facebook--dinov2-base", "snapshots")
    snap = os.path.join(d, os.listdir(d)[0])
    return Dinov2Model.from_pretrained(snap).eval().to(device)


def foreground_mask(im):
    """Zwraca (rgb uint8 HxWx3 skomponowany na szare tlo, maska bool)."""
    if im.mode in ("RGBA", "LA", "P"):
        im = im.convert("RGBA")
        a = np.array(im)
        mask = a[..., 3] > 8
        al = a[..., 3:4].astype(np.float32) / 255.0
        rgb = (a[..., :3] * al + np.array(GREY, np.float32) * (1 - al)).round().astype(np.uint8)
        return rgb, mask
    rgb = np.array(im.convert("RGB"))
    border = np.concatenate([rgb[:6].reshape(-1, 3), rgb[-6:].reshape(-1, 3),
                             rgb[:, :6].reshape(-1, 3), rgb[:, -6:].reshape(-1, 3)])
    bg = np.median(border, axis=0)
    dist = np.abs(rgb.astype(np.float32) - bg).max(axis=2)
    mask = dist > 20
    mask = ndimage.binary_opening(mask, iterations=2)
    mask = ndimage.binary_closing(mask, iterations=3)
    lab, n = ndimage.label(mask)
    if n > 1:
        sizes = ndimage.sum(mask, lab, range(1, n + 1))
        mask = lab == (1 + int(np.argmax(sizes)))
    mask = ndimage.binary_fill_holes(mask)
    # tlo -> to samo szare (usuwa gradient/winiete)
    out = rgb.copy()
    out[~ndimage.binary_dilation(mask, iterations=2)] = GREY
    return out, mask


def to_square(rgb, mask, scale=1.0, dx=0.0, dy=0.0):
    ys, xs = np.where(mask)
    if len(ys) == 0:
        raise ValueError("pusta maska")
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    fg = Image.fromarray(rgb[y0:y1, x0:x1])
    side = max(fg.width, fg.height)
    canvas_side = 1000
    k = canvas_side * FILL * scale / side
    fg = fg.resize((max(1, round(fg.width * k)), max(1, round(fg.height * k))), Image.BICUBIC)
    canvas = Image.new("RGB", (canvas_side, canvas_side), GREY)
    ox = (canvas_side - fg.width) // 2 + round(dx * canvas_side)
    oy = (canvas_side - fg.height) // 2 + round(dy * canvas_side)
    canvas.paste(fg, (ox, oy))
    return canvas


def preprocess(canvas):
    im = canvas.resize((256, 256), Image.BICUBIC).crop((16, 16, 240, 240))
    a = (np.asarray(im, np.float32) / 255.0 - MEAN) / STD
    return torch.from_numpy(a.transpose(2, 0, 1).copy())


def variants(n):
    """n deterministycznych (scale, dx, dy); pierwszy = bez zmian."""
    out = [(1.0, 0.0, 0.0)]
    pat = [(0.95, 0.02, 0.0), (1.05, -0.02, 0.01), (0.97, 0.0, -0.02), (1.03, 0.03, 0.02),
           (0.92, -0.03, 0.0), (1.0, 0.0, 0.03), (0.98, 0.02, -0.02), (1.04, -0.01, -0.01)]
    return out + pat[: max(0, n - 1)]


def circ_mean(deg):
    r = np.radians(deg)
    return float((math.degrees(math.atan2(np.sin(r).mean(), np.cos(r).mean())) + 360) % 360)


def circ_std(deg):
    r = np.radians(deg)
    R = math.hypot(np.cos(r).mean(), np.sin(r).mean())
    return float(math.degrees(math.sqrt(max(0.0, -2 * math.log(max(R, 1e-9))))))


@torch.no_grad()
def angles_of(net, batch):
    p = net(batch)
    az = p[:, 0:360].argmax(-1).float()
    po = p[:, 360:540].argmax(-1).float() - 90
    ro = p[:, 540:720].argmax(-1).float() - 90
    conf = torch.softmax(p[:, -2:], dim=-1)[:, 0]
    return az.numpy(), po.numpy(), ro.numpy(), conf.numpy()


@torch.no_grad()
def cls_feat(dino, batch):
    f = dino(pixel_values=batch).last_hidden_state[:, 0, :]
    return nn.functional.normalize(f, dim=-1)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("images", nargs="+")
    ap.add_argument("--aug", type=int, default=1, help="liczba wariantow kadru (1 = bez)")
    ap.add_argument("--sim", help="obraz konceptu: dodaje kolumne cosinus DINOv2-base")
    ap.add_argument("--device", default="cpu")
    ap.add_argument("--save-prep", help="katalog na podglad przetworzonych kadrow")
    ap.add_argument("--bg", type=int, default=193, help="jasnosc tla (domyslnie 193 = szare tlo generatora)")
    a = ap.parse_args()
    global GREY
    GREY = (a.bg, a.bg, a.bg)
    torch.set_num_threads(max(1, os.cpu_count() or 1))
    files = []
    for p in a.images:
        files += sorted(glob.glob(p)) or [p]
    net = load_orient(a.device)
    dino = load_dino_base(a.device) if a.sim else None
    ref = None
    if a.sim:
        rgb, m = foreground_mask(Image.open(a.sim))
        ref = cls_feat(dino, preprocess(to_square(rgb, m)).unsqueeze(0))
    w = csv.writer(sys.stdout, lineterminator="\n")
    w.writerow(["file", "azimuth", "polar", "rotation", "confidence", "az_std", "polar_std", "sim"])
    for f in files:
        rgb, m = foreground_mask(Image.open(f))
        canv = [to_square(rgb, m, s, dx, dy) for s, dx, dy in variants(a.aug)]
        if a.save_prep:
            os.makedirs(a.save_prep, exist_ok=True)
            canv[0].save(os.path.join(a.save_prep, os.path.basename(f).rsplit(".", 1)[0] + ".png"))
        batch = torch.stack([preprocess(c) for c in canv])
        az, po, ro, cf = angles_of(net, batch)
        sim = ""
        if ref is not None:
            sim = f"{float((cls_feat(dino, batch[:1]) @ ref.T)[0, 0]):.4f}"
        w.writerow([f, f"{circ_mean(az):.1f}", f"{po.mean():.1f}", f"{ro.mean():.1f}", f"{cf.mean():.3f}",
                    f"{circ_std(az):.1f}", f"{po.std():.1f}", sim])
        sys.stdout.flush()


if __name__ == "__main__":
    main()
