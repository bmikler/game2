# 88. C++ (GDExtension) czy shadery i GDScript dla Silnika światła

Ticket: `docs/wayfinder-silnik/tickets/04-cpp-czy-shadery-research.md`. Data: 2026-11-15. Kod mierzony: `style-lab/lighting/` na gałęzi `silnik-mapa` (kod silnika jak w `135ec42`), Godot 4.7.2, Vulkan Forward+, **NVIDIA GeForce RTX 4060 Laptop GPU** (to wypisuje Godot przy starcie; to sprzęt, na którym działa projekt).

**Odpowiedź w skrócie:** koszt jest prawie w całości na GPU, w shaderze bufora światła (pętle po pikselach × źródłach × próbkach × przesłonach). CPU (GDScript) to 0,06–1,5 ms na klatkę. Przeniesienie GDScriptu do C++ zaoszczędzi najwyżej ok. 1–1,5 ms we wnętrzu i ok. 0,1–0,2 ms na ulicy, a nie rusza tego, co dziś zabiera 9–24 ms. 60 fps przy wszystkich źródłach i dużych Lokacjach zapewni algorytm na GPU (mniej pracy na piksel, mniej pikseli przeliczanych na klatkę), nie język.

---

## 1. Jak działa obecny silnik (fakty z kodu)

- **GPU:** bufor światła to `SubViewport` z `ColorRect` z shaderem `canvas_item` (`street_map.gdshader`, `light_map.gdshader`), nigdy nie czyszczony (`CLEAR_MODE_NEVER`), renderowany tylko przy zmianie (`UPDATE_ONCE` albo `UPDATE_DISABLED`) (`street_map.gd:113-131`, `:362-367`; `sun_map.gd:549-576`).
- Każdy piksel bufora woła funkcję światła (`street_parts` / `light_fn`), która dla **każdego źródła** rzuca **wiązkę próbek** i dla każdej sprawdza **każdą przesłonę**:
  - słońce: `sun_samples = 16` próbek tarczy × pudła (`street_fn.gdshaderinc:242-285`, `light_fn.gdshaderinc:65`, `:97`, `:466`);
  - niebo wnętrza: każda szyba (`sash_count`) × siatka `sky_grid² = 16` próbek × pudła (`bundle_hits`) plus analityczne zasłanianie obiektami (`light_fn.gdshaderinc:351-412`, `:311`);
  - niebo ulicy: wielokąty ścian każdej bryły przycinane płaszczyznami (`clip_plane`, `POLY_MAX = 16`) dla każdego z `box_count + 1` pudeł (`street_fn.gdshaderinc:150-220`);
  - lampy: każda lampa × `lamp_samples = 16` × pudła (`light_common.gdshaderinc:191-230`);
  - świecące okna ulicy: każde okno × `win_grid² = 9` × pudła (`street_fn.gdshaderinc:288-330`);
  - kontakt (B): pętla po pudłach (`light_common.gdshaderinc:90`).
  Koszt piksela rośnie więc jak **źródła × próbki × przesłony** (do 128 pudeł: `MAX_BOXES = 127` + postać).
- **Przeliczanie:** całość po zmianie (ulica: rozłożona na `BANDS = 16` klatek co `REPAINT_MINUTES = 5` minut gry), potem w ruchu tylko **okno wokół postaci** (prostokąt, w którym cienie postaci od wszystkich źródeł mogą się zmienić) (`street_map.gd:336-367`, `:404-456`).
- **CPU (GDScript) na klatkę:** `_set_boxes()` (tablice uniformów: pudła, postać) i `_actor_window()` (promienie od narożników postaci do ścian: `AABB.intersects_segment`, we wnętrzu dodatkowo płaszczyzny ścian i drzwi) (`street_map.gd:370-456`, `sun_map.gd:579-860`). Raz na minutę gry: `apply()` (słońce, lampy, okna).

## 2. Pomiary

### 2.1 Metoda i komendy

1. Benchmark projektu (bez zmian w kodzie):
   ```
   cd style-lab
   Godot_v4.7.2-stable_win64_console.exe --path . -- --scene=res://poligony/ulica_bryly.tscn --bench=12
   ```
   wynik: `BENCH 12: 476 fps`.
2. Skrypt pomiarowy **poza repo** (`%TEMP%\...\scratchpad\bench\measure.gd`, `extends SceneTree`), uruchamiany zamiast pętli głównej; wczytuje `res://main/main.tscn` (więc `--bench`, `--ruch`, `--set=` działają jak zwykle) i przez 2–3 s zbiera na klatkę:
   - `RenderingServer.viewport_set_measure_render_time()` + `viewport_get_measured_render_time_gpu/cpu()` dla **bufora światła** (`_view` w `StreetMap`/`SunMap`) i dla okna głównego: czas GPU i CPU renderowania danego viewportu;
   - `scripts` = czas od `SceneTree.process_frame` do `RenderingServer.frame_pre_draw` (cała logika skryptów w klatce);
   - `draw` = od `frame_pre_draw` do `frame_post_draw` (wysłanie rysowania + czekanie na GPU/prezentację);
   - na końcu: 1000 wywołań `_set_boxes()`, `_actor_window()`, `_process()` mapy (µs na wywołanie) i czas `_process` każdego węzła ze skryptem.
   ```
   Godot_v4.7.2-stable_win64_console.exe --path . --script <scratchpad>/bench/measure.gd -- --scene=<scena> --bench=<godzina> [--ruch] [--okno] [--set=liczenie=1]
   ```
   `--ruch` = okno postaci przeliczane co klatkę (jak w marszu), `--set=liczenie=1` = cały bufor co klatkę (najgorszy przypadek, np. pełna doba na żywo albo przesuwane źródło).
3. Powtórzenia: scenariusze ruchu uruchomione 2×; rozrzut na laptopie jest duży (np. `dom 9:30 stoi` raz 226, raz 422 kl./s), więc liczby traktować jako rząd wielkości.

### 2.2 Wyniki

Bufor ulicy 1812×1442 px (1780×1442 ulicy + pasek postaci), 48 pudeł, 4 lampy, 19 okien. Bufor domu (`dom_parter`) 652×281 px (620×281 domu).

| Scenariusz | kl./s | klatka ms | GPU bufora ms (średnio) | skrypty ms | `_process` mapy µs | okno postaci px |
|---|---|---|---|---|---|---|
| ulica 12:00, stoi | 517–603 | 1,7–1,9 | 0 (nie renderowany) | ~0,16 | 64 | – |
| ulica 12:00, `--ruch` | 328–489 | 2,0–3,0 | 0,35–0,37 | 0,16 | 64 | 118×127 |
| ulica 8:00, `--ruch` | 453 | 2,2 | 0,47 | – | 113 | 159×174 |
| ulica 22:00, `--ruch` | 288–348 | 2,9–3,5 | 1,27–1,63 | 0,38–0,40 | 163–171 | 385×169 |
| ulica 12:00, całość co klatkę | 54–63 | 18,5 | **16,8** | – | 110 | 1780×1442 |
| ulica 22:00, całość co klatkę | 39–43 | 25,6 | **23,9** | – | 222 | 1780×1442 |
| ulica „stare” (bez bufora, `swiatlo_ulicy=1`) | 818 | 1,2 | 0 | – | 1 | – |
| dom 9:30, stoi | 226–422 | 2,4–4,4 | 0 | **1,3** | **1030–1090** | – |
| dom 9:30, `--ruch` | 66–86 | 11,6–15,2 | **9,1–12,4** | **1,9–2,1** | 1040 | 305×281 |
| dom 22:00, `--ruch` | 61–82 | 12,2–16,3 | **10,4–13,7** | 2,1–2,2 | 1420–1540 | 305×281 |
| dom 9:30, całość co klatkę | 40 | 24,8 | **21,8** | – | 1060 | 620×281 |
| dom 22:00, całość co klatkę | 43 | 23,2 | **21,6** | – | 1480 | 620×281 |

Pozostałe składniki w każdym scenariuszu: GPU okna głównego 0,16–0,27 ms, CPU renderowania okna głównego 0,08–0,16 ms, `get_frame_setup_time_cpu` 0,04–0,55 ms. Pomiar węzłów: we wnętrzu `SunMap._process` ≈ 1030–1540 µs, wszystko inne < 10 µs (`placeholder_actor` 7,6 µs, `dom_bryly` 4,1 µs); na ulicy `StreetMap._process` ≈ 64–170 µs, reszta < 4 µs. Prawie cały `_process` mapy to `_actor_window()` (dom: 1000–1460 µs, ulica: 52–275 µs); `_set_boxes()` 6–60 µs.

### 2.3 Koszt na piksel (wyliczone z tabeli)

| Bufor | piksele | GPU ms | ns/px |
|---|---|---|---|
| ulica całość 12:00 | 2,57 mln | 16,8 | ~6,5 |
| ulica całość 22:00 | 2,57 mln | 23,9 | ~9,3 |
| ulica okno 22:00 | 65 tys. | 1,4 | ~22 (z narzutem przebiegu) |
| dom całość | 174 tys. | 21,7 | **~125** |
| dom okno | 86 tys. | 9–12 | **~105–145** |

Piksel wnętrza jest ok. 15–20× droższy od piksela ulicy: wnętrze liczy niebo każdej szyby wiązką 16 próbek przez wszystkie pudła, lampy wiązkami 16 próbek, wstęgi okien bocznych i słońce 16 próbkami. Okno postaci we wnętrzu obejmuje połowę domu (305 z 620 px szerokości), bo cień postaci od szyb i lamp może sięgać daleko.

## 3. Fakty z dokumentacji i API (źródła pierwotne)

Sprawdzone w tej sesji na samym silniku 4.7.2 (`Godot_v4.7.2-stable_win64_console.exe --headless --doctool <katalog>`, zrzut referencji klas): istnieją `RenderingDevice` z `compute_list_begin`, `compute_list_dispatch`, `shader_create_from_spirv`, `texture_update`; `RenderingServer.call_on_render_thread`, `get_rendering_device`, `viewport_set_measure_render_time`; `Texture2DRD` z właściwością `texture_rd_rid` (tekstura RD do użycia w 2D); `RDShaderFile`; `CompositorEffect`; `GDExtensionManager`. (Zrzut z tej wersji nie zawiera opisów, tylko sygnatury.)

Poniższe strony dokumentacji to źródła pierwotne dla zdań w tym rozdziale. **Uwaga:** w tej sesji pobieranie stron było zablokowane (limit narzędzia WWW), więc treść podaję z wiedzy o tych stronach, bez ponownego odczytu; przed decyzją w specyfikacji warto je otworzyć.

- GDExtension C++ (godot-cpp): budowanie wymaga kompilatora C++ (na Windows: Visual Studio / MSVC albo MinGW), Pythona i SCons; rozszerzenie to biblioteka DLL + plik `.gdextension`, osobna kompilacja dla każdej platformy i konfiguracji (debug/release). https://docs.godotengine.org/en/stable/tutorials/scripting/cpp/gdextension_cpp_example.html , https://github.com/godotengine/godot-cpp
- Zgodność: rozszerzenie zbudowane dla 4.x działa w późniejszych 4.y (zgodność w przód od 4.1), nie odwrotnie; godot-cpp ma gałęzie/wersje pod wersje silnika. https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/what_is_gdextension.html
- Compute shadery: pisane w GLSL (nie w języku shaderów Godota), uruchamiane przez `RenderingDevice`; dostępne w rendererach Forward+ i Mobile, **nie** w Compatibility; lokalne `RenderingDevice` (`create_local_rendering_device`) wymaga ręcznego `submit()`/`sync()`, praca na głównym urządzeniu przez `RenderingServer.call_on_render_thread`. https://docs.godotengine.org/en/stable/tutorials/shaders/compute_shaders.html
- Optymalizacja CPU: najpierw profilować; GDScript jest wolniejszy od kodu natywnego w ciasnych pętlach obliczeniowych, a przeniesienie gorących fragmentów do C++ ma sens dopiero, gdy profil pokaże, że to one ograniczają klatkę. https://docs.godotengine.org/en/stable/tutorials/performance/cpu_optimization.html , https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html

Stan środowiska (sprawdzone): na komputerze nie ma MSVC (`vswhere.exe` brak, `cl`, `gcc`, `clang`, `scons` poza PATH). GDExtension wymagałoby instalacji Visual Studio Build Tools (lub MinGW) i SCons, czyli zgody człowieka (CLAUDE.md: pytać przed globalną instalacją).

## 4. Wnioski (interpretacja pomiarów)

1. **Wąskie gardło to GPU, nie CPU.** We wnętrzu w ruchu GPU bufora zabiera 9–14 ms z 12–16 ms klatki (≈80%); skrypty ≈2 ms. Na ulicy w ruchu oba są małe (GPU 0,4–1,6 ms, skrypty 0,2–0,4 ms). Najgorszy przypadek (cały bufor co klatkę) to 17–24 ms czystego GPU w obu scenach: poniżej 60 fps niezależnie od tego, w czym napisany jest CPU.
2. **Co zostaje na GPU niezależnie od języka:** cała funkcja światła na piksel (słońce, niebo, lampy, okna, kontakt, wygląd/dither). C++ (GDExtension) wykonuje się na CPU; nie przyspiesza shadera. Przepisanie funkcji światła na CPU w C++ byłoby wolniejsze (miliony pikseli × setki testów przesłon na klatkę).
3. **Co realnie da C++:** `_actor_window()` i `_set_boxes()` w natywnym kodzie skróciłyby się prawdopodobnie kilkanaście–kilkadziesiąt razy (szacunek, typowa różnica GDScript vs C++ w ciasnej pętli z wektorami; nie mierzone tu). Zysk: ≤1,5 ms/klatkę we wnętrzu, ≤0,3 ms na ulicy. To ok. 10% budżetu 16,7 ms we wnętrzu, a ten sam zysk można uzyskać w GDScripcie: liczyć okno postaci tylko przy zmianie pozycji postaci lub źródeł (dziś liczone co klatkę także, gdy postać stoi: dom 9:30 stoi = 1 ms CPU bez żadnego renderowania), uprościć je do ograniczenia analitycznego (zasięg źródeł) albo przenieść na GPU.
4. **Duże Lokacje:** koszt całości rośnie liniowo z liczbą pikseli bufora i liniowo z liczbą przesłon (każdy piksel przechodzi pętlą przez wszystkie `box_count` pudła) oraz ze źródłami w zasięgu. Ulica 1780×1442 przy 48 pudłach to już 17–24 ms na całość; podwojenie powierzchni i pudeł daje ok. 4× (szacunek z liniowości). Przy rozłożeniu na 16 pasów to 1–1,5 ms/klatkę, ale przy pełnej dobie na żywo (godzina zmienia się ciągle, mapa: „Pełna doba (24 h) ze zmianą na żywo”) przeliczenia całości mogą być częste. Okno postaci nie zależy od powierzchni Lokacji, ale zależy od zasięgu źródeł (dom: pół bufora) i od liczby przesłon.
5. **Dźwignie na GPU, które rozwiązują problem przez konstrukcję (bez ifów pod scenę):**
   - *Statyczne i dynamiczne osobno:* światło od statycznych przesłon (architektura, meble) liczone raz na zmianę godziny/źródeł i trzymane w buforze; postać (jedyna ruchoma przesłona) jako osobny, tani składnik: jej cień od każdego źródła w zasięgu (jedno pudło/walec zamiast 128 pudeł na próbkę). Dziś okno postaci przelicza w swoim prostokącie **wszystkie** źródła × **wszystkie** przesłony, choć zmienia się tylko udział postaci.
   - *Przycinanie przesłon:* siatka lub lista pudeł na kafel (tile) przekazana teksturą/buforem, żeby piksel testował tylko pudła na drodze do źródła, nie wszystkie 128; to samo dla źródeł (lampa poza zasięgiem nie wchodzi do pętli kafla).
   - *Rozkład w czasie i rozdzielczość:* całość w pasach (już jest na ulicy), bufor w niższej rozdzielczości dla miękkich składników (niebo, odbicie), pełna tylko dla krawędzi cieni słońca i lamp.
   - *Compute shader (RenderingDevice):* daje kontrolę nad kaflami, pamięcią współdzieloną (lista przesłon kafla w `shared`) i przebiegami wieloetapowymi (np. najpierw widoczność źródeł per kafel, potem światło), czego `canvas_item` w `SubViewport` nie daje. Koszt: GLSL obok języka shaderów Godota, ręczne zarządzanie zasobami RD, tylko Forward+/Mobile (projekt jest na Forward+), wynik do 2D przez `Texture2DRD`. Nie trzeba do tego C++: RenderingDevice jest dostępne z GDScriptu.
6. **Koszt GDExtension (poza wydajnością):** nowy łańcuch budowania (MSVC/MinGW + Python + SCons, instalacje globalne), DLL na każdą platformę i konfigurację, debugowanie poza edytorem Godota, kod nietestowalny przez GUT/gdUnit4 bezpośrednio (testy natywne osobno), więcej pracy przy przenoszeniu katalogu silnika do gry (mapa: „do gry przenoszony przez skopiowanie katalogu” – binarka musi iść razem i pasować do wersji). Dla jednoosobowego projektu na prototypie to duży stały koszt za ≤1,5 ms.

## 5. Ograniczenia pomiaru

- Jeden komputer (laptop, RTX 4060 Laptop), tryb zasilania nieznany; rozrzut między przebiegami do ~2×.
- `viewport_get_measured_render_time_gpu` mierzy przebieg viewportu; nie obejmuje prezentacji okna, dlatego `draw` (2–3 ms na ulicy) jest większy niż suma GPU.
- Monitor `Performance.TIME_PROCESS` dawał w tym trybie (`--script`) niewiarygodne wartości (20–60 ms przy klatce 2 ms), więc nie jest użyty; zamiast niego `scripts` i bezpośrednie czasy wywołań.
- Zysk C++ dla `_actor_window` to szacunek, nie pomiar (brak kompilatora).
- Strony dokumentacji z rozdziału 3 nie zostały w tej sesji ponownie otwarte (limit narzędzia WWW); fakty o API są potwierdzone zrzutem referencji z 4.7.2.

## Co z tego dla Silnika światła game2

**Rekomendacja: C++ (GDExtension) – nie, na teraz.** Silnik pisać w GDScripcie (logika, kontrakt sceny, strojenie `.tres`, testy GUT/gdUnit4) i shaderach; budżet 60 fps zdobywać architekturą obliczeń na GPU:

1. W specyfikacji zapisać **budżet**: bufor w ruchu ≤ ~4 ms GPU, CPU silnika ≤ ~1 ms na klatkę, przeliczenie całości rozkładane na klatki; pomiar jak w tym dokumencie (GPU viewportu bufora + czas skryptów) jako bramka w testach wydajności.
2. **Rozdzielić składnik statyczny i postać** (przez konstrukcję: postać to jedna ruchoma przesłona w kontrakcie), żeby ruch nie przeliczał wszystkich źródeł × wszystkich przesłon. To największa dźwignia dla wnętrza (dziś 9–14 ms).
3. **Przycinanie przesłon i źródeł per kafel**, żeby koszt piksela nie rósł z liczbą pudeł w całej Lokacji (warunek dla dużych Lokacji).
4. **Compute shader przez RenderingDevice** rozważyć w prototypie bufora (ticket „Bufor i przeliczanie”), jeśli `canvas_item` nie pozwoli na kafle i wieloetapowość; z GDScriptu, bez C++.
5. C++ wrócić tylko wtedy, gdy po tych zmianach profil pokaże CPU > ~2 ms na klatkę w konkretnej funkcji (np. przygotowanie list przesłon dla bardzo wielu obiektów) i nie da się tego przenieść na GPU; wtedy tylko ta jedna funkcja, za zgodą człowieka na instalację narzędzi.
