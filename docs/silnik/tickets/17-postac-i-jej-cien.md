---
id: 17
title: Postać i jej cień
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [09, 13]
---

## Co zbudować

Chodząca postać jako ruchoma Przesłona (walec): cień od wszystkich Źródeł, cień kontaktowy, zasłanianie nieba wzorem. Liczone co klatkę w oknie wokół postaci i dla Źródeł w zasięgu; cień mnoży gotowe warstwy. Postać oświetlona jak Odbiornik bryłowy co klatkę (modelowanie, kontrświatło), z mapą normalnych, jeśli jest.

## Kryteria akceptacji

- [ ] Flaga „ruchoma”, ścieżka ruchomych w Opisie sceny (testy).
- [ ] Sterowanie postacią w Poligonie (Input Map), poza addonem.
- [ ] Ten sam Stan doby dla okna postaci i reszty Bufora.
- [ ] Bramka: cień ruchomej Bryły = cień tej samej Bryły nieruchomej.
- [ ] Okno liczone tylko w kadrze.

## Jak sprawdzić

Sklep o 22:00: przejdź między latarniami, kilka cieni obraca się i wydłuża, bok postaci jaśniejszy od latarni. W południe jeden cień i ciemniejsza plamka pod stopami.

## Plan (2026-11-18, czeka na „ruszamy” człowieka)

Pomysł człowieka: zamiast walca uproszczona bryła postaci z klatek jej animacji chodu, żeby cień miał osobne nogi i
krok, a podłoga między nogami nie ciemniała (wada walca z wayfindera 33; płaska sylwetka odpadła tam, bo przy lampie
wyglądała dziwnie). **Najpierw próba, potem decyzja:** bryła z sylwetki to wariant do porównania z walcem na żywo w F1;
spec (kontrakt assetu, rodzaje Brył) zmieniamy dopiero, gdy człowiek ją przyjmie. Gałąź z `main`.

1. **Ruchoma Przesłona z walcem** (zakres ticketu jak wyżej): flaga „ruchoma” i ścieżka ruchomych w Opisie sceny,
   okno wokół postaci liczone co klatkę dla Źródeł w zasięgu, cień mnoży gotowe warstwy, plamka kontaktowa, niebo
   wzorem analitycznym, postać jako Odbiornik bryłowy, sterowanie w Poligonie (Input Map). Bramka: cień ruchomej
   Bryły = cień tej samej Bryły nieruchomej.
2. **Narzędzie „bryła z sylwetki”** (offline, 0 zł, bez nowych generacji): z każdej klatki chodu
   (`proby/pixellab_chod_D`, przód / bok / tył) po rzędach pikseli odcinki sylwetki (w rzucie 0,60 przeliczone na
   wysokość w metrach); grubość w drugą stronę z sylwetki stania z widoku prostopadłego; każdy odcinek = eliptyczny
   plaster. Wynik: stos plastrów na klatkę jako dane assetu (Resource), nie kod.
3. **Próbny rodzaj Bryły w silniku**: stos plastrów z numerem klatki zmienianym z animacją; ta sama funkcja widoczności
   dla słońca, lamp i okien. Ta sama bryła daje pozycję pikseli postaci przy oświetlaniu jej samej (nogi na właściwej
   głębi). Niebo i plamka kontaktowa zostają na obrysie (miękkie, szczegół nóg i tak znika).
4. **Porównanie w F1**: przełącznik kształtu cienia walec / bryła z sylwetki. Ocena człowieka na żywo: Sklep 22:00
   (kilka latarni), południe (słońce 30°, długi cień z krokiem), chód bokiem i do kamery.
5. **Po ocenie**: przyjęta → dopisanie „bryły z sylwetki” do spec jako reguły ogólnej dla każdej ruchomej postaci
   (NPC, zwierzę), walec zostaje jako Bryła ogólna; odrzucona → zostaje walec, narzędzie i kod próby usunięte.

Znane ograniczenie: przy chodzie do kamery / od kamery krok jest w głąb ekranu, sylwetka przodu go nie pokazuje, więc
cień z boku pokaże nogi obok siebie, nie krok. Wydajność (8 postaci na Skwerze) dopiero w tickecie 19.

## Przekazanie (2026-11-19, koniec sesji 1) — AKTUALNE

Gałąź `silnik-17-postac` (od `silnik-14-polcien`, nie od `main`: gałęzie silnika idą łańcuchem), commit `ca41bd6`.
201/201 testów zielonych. Niezacommitowane zmiany spoza ticketu (GLOSSARY, mapa wayfindera, `project.godot`, ticket
wayfindera 40, `reference/nastroj/`) zostały nietknięte — nie dołączać do commitów tego ticketu.

**Zrobione (kroki 1–4 planu):**
- `Occluder.moving`; Opis sceny trzyma ruchome osobno (`moving_solids`, `moving_assets`, `refresh_moving()`,
  `moving_windows()`), w shaderach idą po nieruchomych (`all_solid_data`, `all_asset_data`).
- `MovingLayer` (`buffer/moving_layer.gd/.gdshader`): co klatkę, tylko w oknach (w kadrze), kanał sztuczny + udział
  nieba w alfie i kanał naturalny. Piksel podłogi: odjęte światło każdego Źródła, które przechodzi obok nieruchomych,
  a zasłania je ruchoma (te same próbki i półcień co warstwa Źródła, wspólny `sources.gdshaderinc`); niebo × część
  otwarta (analitycznie, walec wokół pudełka). Piksel sprite'a ruchomego: pełne światło Źródeł (32 próbki) i niebo
  (64 kierunki). Słońce: bufor sam (jego Bryły obejmują ruchome). Druga warstwa assetów `AssetLayer.new(true)`.
- `SilhouetteStack` (`scene/silhouette_stack.gd`) + `Solid.Shape.SILHOUETTE` / `SolidShape.Kind.SILHOUETTE`
  (`visibility.gdshaderinc`: `silhouette_span`, plaster na rząd pikseli sprite'a, ≤ 2 elipsy na rząd). Stos liczony
  przy wczytaniu z klatek (nie offline, nie `.tres`).
- Poligon Ulica: `PoligonWalker` (`engine_poligons/street/walker.gd`) — detektyw „Dc”, 8 kierunków, F1 „Cień postaci
  (ticket 17)”: walec / bryła z sylwetki (domyślna), przełącznik w zrzutach; kamera za postacią; postać sortowana
  przed assetami bliżej kamery (stragan zasłania nogi).
- Bramki (`test/engine/test_moving_gpu.gd`): ruchoma = nieruchoma (lampa, słońce, niebo; sprite ruchomy oświetlony
  jak nieruchomy), cień sylwetki ma prześwit między nogami, przesunięta postać zabiera cień.

**Uwagi człowieka po pierwszym obejrzeniu (2026-11-19) — do zrobienia w następnej sesji:**
1. **Wydajność spadła.** Zmierzyć (`--bench` jeszcze nie ma; licznik FPS w F1) i wskazać przyczynę. Podejrzenia:
   warstwa ruchoma to dwa przebiegi po CAŁYM obszarze co klatkę (kopia poza oknami) — liczyć tylko okna albo
   kopiować tylko przy zmianie; kanał naturalny rysowany także bez naturalnych Źródeł; pętla sylwetki
   (`silhouette_span`) wkompilowana w każdą `visibility` także w warstwach budowanych raz; bufor (słońce) i tak
   liczy cały obszar co klatkę.
2. **Test wydajności: 3 postacie chodzące naraz** (scena z 2 NPC na rutynie ruchu + gracz). Chodząca postać kosztuje
   więcej niż stojąca (stojąca nie odświeża okna) — zmierzyć oba.
3. **Uproszczone cienie do porównania** (nogi nie muszą być widoczne, jeśli to poprawi wydajność): np. stos z 1 elipsą
   na rząd, rzędy co 4–8 px, albo kilka walców (nogi razem / tułów / głowa). Warianty w F1 obok walca i pełnej
   sylwetki, z FPS.
4. **Chód bokiem: postać „chodzi nad cieniem”** (zrzut `shots/engine/poligon_street__0453__2026-11-19T065327-942`):
   cień nie zaczyna się pod stopami. Sprawdzić kotwicę klatek bocznych (klatki kotwiczone sprite'em stania z
   `get_used_rect`; stopy w klatkach chodu mogą być wyżej / przesunięte) i grubość bryły bokiem (głębia z sylwetki
   przodu).
5. **Jasna obwódka wokół cienia postaci przy lampie po prawej** (ten sam zrzut). Podejrzenia: odejmowanie z innym
   półcieniem niż warstwa Źródła (skala półcienia liczona z ruchomymi, 32 vs 128 próbek) albo szew A′ na krawędzi
   cienia. Sprawdzić kanał sztuczny z ruchomą i bez (różnica nie może być dodatnia nigdzie).
6. **Cień postaci poniżej cienia budynku** (zrzut `poligon_street__1218__2026-11-19T065104-854`): postać stoi w cieniu
   kamienicy blisko jego krawędzi, a cień jej głowy wychodzi poza cień budynku. Wstępnie to fizycznie poprawne
   (głowa wystaje ponad linię słońce–krawędź dachu: 1,7 m od krawędzi cienia przy słońcu 30° linia jest ok. 1 m nad
   ziemią, postać ma 1,8 m), ale sprawdzić liczbami i pokazać człowiekowi; jeśli przeszkadza — decyzja wyglądu.
7. Wcześniej zauważone: przy walcu najwyższe piksele włosów trafiają w wierzch walca (jasna „czapka”); latarnie nie
   są sortowane z postacią; nocą przód postaci odwróconej od lampy jest bardzo ciemny (fizycznie poprawne).

**Po zatwierdzeniu cienia przez człowieka:** dopisać krok do Przepisu postaci (`docs/grafika/przepis-postaci.md`):
każda postać dostaje cień (bryłę z sylwetki z klatek chodu albo wybrany wariant uproszczony) — wejścia (klatki
każdego kierunku, sprite stania z przodu i z boku), sprawdzenie; dopisać rodzaj Bryły do spec (krok 5 planu);
`/code-review` na całość ticketu.
