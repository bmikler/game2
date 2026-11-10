---
id: 22
title: Mapy normalnych postaci: Pixellab, Laigter czy własny skrypt
labels: [wayfinder:prototype]
status: open
assignee:
blocked_by: [36]
---

## Question

Postać z Przepisu postaci (`docs/grafika/przepis-postaci.md`, detektyw: stanie `style-lab/proby/wejscie_anim/opcja{1,2}/sprite_*.png`, chód `style-lab/proby/pixellab_chod_D/{przod,bokc,tyl}_*.png`) nie ma jeszcze map normalnych, więc światła 2D w Poligonie jej nie cieniują. Jak je robić, żeby postać dobrze wyglądała pod światłem (latarnia, okno, TV, noc w mieście i poza nim), także w ruchu (bez migotania między klatkami)?

Porównać na tej samej postaci, w Poligonie w dzień i w nocy, przełączane na żywo (F1):
1. **Pixellab `/normal-map`** (`kind: character`, `convention: opengl`; lite 0,1 gen./obraz lub pasek do 32 klatek, pro 0,5): koszt i spójność klatek chodu. Każda generacja za zgodą człowieka z kosztem (trial: 10,5/40).
2. **Własny skrypt z game1-proto** (`C:/Users/bartl/Desktop/repo/game1-proto/prototype/lighting/pipeline/normals.gd`: wiersze sylwetki jako pionowe walce, pochylenie jak w 3/4, wypukłość z jasności; w game1-proto ostatecznie użyty zamiast AI), dostosowany do rzutu 0,60 i postaci 72 px; 0 zł.
3. **Laigter** (darmowy, rekomendacja researchu game1-proto `docs/research/02-pixel-art-oswietlenie.md`, `08-assety-ai.md`): czy da się go wołać wsadowo.
4. Bez map normalnych (punkt odniesienia).

Mierzyć: wygląd pod światłem (ocena człowieka), migotanie w chodzie, koszt na postać (generacje / czas), konwencję osi (Godot: `CanvasTexture.normal_texture`, Y). Wynik: krok 9 Przepisu postaci (i wskazówka dla Przepisu mebli).

**Stan (2026-11-10):** postać jest już oświetlana mapą światła jako bryła (ticket [31](31-dynamiczne-slonce-okien-prototyp.md), sesja 13), ale mapy nie niosą kierunku światła, więc normalne nie miałyby czego użyć. Najpierw [Przebudowa światła wnętrza na jeden bufor z cieniami](36-przebudowa-swiatla-jeden-bufor.md): czy jedna funkcja światła `light_parts(p, n, …)` daje postaci kierunek światła (uwaga B inżyniera w `docs/research/80-ocena-oswietlenia-inzynier.md`: mapa kierunkowa, N·L w `lit`); bez tego ten ticket nie ma sensu.
