> Kopia z game1 (`repo/game1/docs/research/24c-skrypty-i-cli.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Assety przez Claude: edytory 2D, skrypty i CLI (koncept → czysty sprite → normal mapa)

Ticket: `docs/wayfinder/tickets/24-assety-przez-claude.md` (część C: skrypty, CLI, MCP). Data researchu i dostępu do wszystkich źródeł: **2026-10-28**. Źródła pierwotne (dokumentacja, README, GitHub API, strony sklepów). Gdzie ich zabrakło, piszę to wprost.

Założenia: człowiek nie rysuje i nie poprawia pikseli ręcznie. Workflow: koncept z tekstu i referencji (inny agent), wybór wyglądu, a potem **zamiana konceptu na spójne assety gry**. Ten dokument opisuje drugą połowę: paletę, pikselizację, sprzątanie, eksport i normal mapy. Skala: 640×360, kafel 32 px, postać ok. 60 px, 4 kierunki, światła 2D z normal mapami (ADR 0002, szczebel 1). Windows 11, Node 22, Godot 4.7.2, **brak Pythona**.

## Streszczenie i rekomendacja

- **„Ręce” Claude: Aseprite.** Ma pełny tryb wsadowy (`aseprite -b`), API Lua z dostępem do pikseli, palet, konturu i eksportu arkuszy oraz aktywny serwer MCP (diivi/aseprite-mcp, 836★, MIT). Koszt to 84,99 zł na Steam albo darmowa kompilacja ze źródeł (ok. 1–2 h z VS 2022). GIMP, Krita, Pixelorama i LibreSprite są słabsze jako narzędzie do pixel artu sterowane skryptem (tabela w §1).
- **Pikselizacja i paleta: unfake (CLI w Rust, gotowe `.exe` na Windows, MIT).** Wykrywa siatkę „pseudo-pikseli” w obrazie AI, zmniejsza go bez nowych kolorów i mapuje na **stałą paletę projektu** (`--palette plik.hex`). Działa bez Pythona.
- **Granica jakości:** automat dobrze czyści obraz, który już jest pixel artem na nierównej siatce (wynik generatora pixel art). **Malowanego konceptu w wysokiej rozdzielczości nie da się automatycznie zmniejszyć do czytelnej postaci 60 px.** Autor unfake pisze wprost, że zbyt „malarskie” wyniki nie poddają się automatycznemu sprzątaniu. Krok koncept → pixel art musi więc zrobić generator pixel art z konceptem jako referencją (Pixellab, Retro Diffusion; zob. 08 i inne części ticketu 24). Skrypty z tego dokumentu robią resztę.
- **Normal mapy:** Laigter ma tryb bez GUI (`-g -d plik -n -r preset`). Generuje jednak „poduszkę” z kanału alfa, która nie wie, co jest blatem, a co frontem w 3/4. Prototyp pokazał, że czytelny wolumen dają normalne autorowane w przestrzeni widoku. Rekomendacja: własny skrypt (Node albo Godot headless), który łączy **maskę ścian** (góra, front, lewo, prawo; Claude maluje ją prostokątami jak w `art.gd`) z wypukłością z alfy i jasności. Laigter służy jako punkt odniesienia i szybki start.
- **Pixel art rysowany kodem** i **gotowe paczki** zostają tylko jako placeholdery lub awaryjne wypełnienie (§4, §5).

## 1. Edytory 2D, którymi Claude może sterować na Windows

| Edytor | Sterowanie z Claude Code | Narzędzia pixel art | Koszt, licencja | Ocena |
|---|---|---|---|---|
| **Aseprite** | CLI `-b`, skrypty Lua (`--script`, `--script-param`), kilka serwerów MCP | indeksowana paleta, Outline, eksport arkuszy z JSON, tagi animacji, RotSprite | 84,99 zł na Steam; EULA; własna kompilacja ze źródeł do własnego użytku, także do gier komercyjnych | **Wybór** |
| LibreSprite | skrypty JavaScript (API: Sprite, palette, resize, saveAs); CLI wsadowe niepotwierdzone | fork Aseprite sprzed 2016 r., starszy zestaw funkcji | darmowy, GPL-2.0, wydanie v1.3 (2026-10-02) | zapas, jeśli Aseprite odpada |
| Pixelorama | CLI tylko do eksportu (`-e`, `-s`, `--scale`, `--json`, `--split-layers`, `--headless`); rozszerzenia w Godot | dobry edytor pixel art, ale bez API do automatycznej edycji z zewnątrz | darmowy, MIT, v1.2.3 (2026-09-15) | eksport tak, sprzątanie nie |
| GIMP 3 | MCP: maorcc/gimp-mcp (280★, GPL-3.0, 56 narzędzi, wtyczka w GIMP i TCP :9877, Windows testowany); wsad `--batch-interpreter`/`-b`/`--quit` | ogólna grafika (pixelate, skalowanie, zaznaczenia); brak tagów animacji i arkuszy pod gry | darmowy | dobre do zdjęć, przerost do sprite'ów |
| Krita | CLI tylko `--export`/`--export-sequence`; Python wbudowany w Kritę; MCP `krita-codex-mcp` znane tylko z katalogów (Windows-first, Krita 5.3.2.1; repo niezweryfikowane) | malarski; pixel art możliwy, ale nie jest głównym celem | darmowy | nie |
| Photopea | niezbadane (wiadomo tylko o skryptach w przeglądarce) | — | — | nie badano |

Szczegóły Aseprite:
- **CLI:** `--batch`, `--script`, `--script-param`, `--palette`, `--color-mode indexed`, `--dithering-algorithm none|ordered|old`, `--scale`, `--trim`, `--split-layers`, `--tag`, `--sheet`, `--sheet-type rows|packed…`, `--data` z `--format json-array`, `--list-tags`. [aseprite.org/docs/cli](https://www.aseprite.org/docs/cli/)
- **Lua:** `Image:getPixel/drawPixel/pixels()`, `app.open`, `app.params` (z `--script-param`), `app.isUIAvailable` (w trybie `-b` jest false). [api/app](https://www.aseprite.org/api/app), [api/image](https://www.aseprite.org/api/image). `app.command.*` obejmuje m.in. `Outline` (`color`, `place='outside'`, `matrix='circle'|'square'…`, `ui=false`), `ChangePixelFormat`, `ColorQuantization`, `LoadPalette`, `SpriteSize`, `CanvasSize`, `ExportSpriteSheet`. [api/app_command](https://www.aseprite.org/api/app_command), [api/command/Outline](https://www.aseprite.org/api/command/Outline). `os.execute` i `io.open` pytają o zgodę (dotyczy GUI; zachowanie w `-b` do sprawdzenia).
- **Cena i licencja:** w FAQ minimum 19,99 USD; na Steam 84,99 zł, wersja 1.x wspierana do 1.9, DRM-free. Kompilacja ze źródeł do użytku osobistego jest dozwolona i można nią robić assety do gier komercyjnych, ale skompilowanej wersji nie wolno rozpowszechniać. [FAQ](https://www.aseprite.org/faq/), [Steam](https://store.steampowered.com/app/431730/Aseprite/). Najnowsze wydanie to v1.3.18.6 (2026-09-22, GitHub API).
- **Kompilacja na Windows:** VS 2022 Community z „Desktop development with C++” i SDK 10.0.26100, CMake, Ninja, prekompilowana Skia `aseprite-m124`; jest skrypt `build.cmd`. MinGW nie jest wspierany. [INSTALL.md](https://github.com/aseprite/aseprite/blob/main/INSTALL.md). Wniosek: przy cenie ok. 85 zł kompilacja ma sens tylko dla zasady.
- **Serwery MCP:**
  - **diivi/aseprite-mcp**: MIT, 836★, ostatni push 2026-10-21. Python 3.13 + `uv`, `ASEPRITE_PATH`. Ok. 123 narzędzia, m.in. `quantize_to_palette`, `extract_palette`, `outline_cel`/`outline_native`, `export_spritesheet`, `export_tag`, `view_sprite`, `compare_frames`, `lint_sprite`, `audit_animation`, `run_lua_script`. Wygląda na to, że każde wywołanie uruchamia Aseprite w trybie wsadowym (wniosek z README). Natywny setup na Windows nie jest opisany, a przykłady są pod macOS i Dockera. [repo](https://github.com/diivi/aseprite-mcp)
  - willibrandon/pixel-mcp: Go, MIT, 155★, ostatni push 2025-10-18. Ma `downsample_image` (filtr pudełkowy), kwantyzację (median cut, k-means, octree), `apply_outline`, `export_spritesheet`. [repo](https://github.com/willibrandon/pixel-mcp)
  - ext-sakamoro/AsepriteMCP i rkdfx/aseprite-mcp: małe lub nieaktywne (27★, ostatni push 2025-06).
  - **Uwaga:** `uv` sam pobiera Pythona, więc systemowy Python nie jest potrzebny. [uv docs](https://docs.astral.sh/uv/guides/install-python/). Instalacja `uv` to jednak nowe narzędzie w profilu użytkownika, więc trzeba o nią zapytać.
- **MCP czy CLI?** Claude Code ma Bash i PowerShell, więc `aseprite -b --script x.lua` wystarcza. Skrypty Lua leżą w repo, są wersjonowane i powtarzalne. MCP przydaje się do interaktywnego „oglądania” (`view_sprite`), ale Claude i tak może czytać PNG narzędziem Read (np. eksport `--scale 4`). Rekomendacja: **najpierw CLI + Lua w repo**, a diivi MCP opcjonalnie.
- **Godot:** wtyczka Aseprite Wizard (MIT, gałąź Godot 4) importuje tagi jako animacje (SpriteFrames, AnimationPlayer). [repo](https://github.com/viniciusgerevini/godot-aseprite-wizard)

## 2. Koncept → czysty pixel art: paleta, pikselizacja, sprzątanie

### 2.1 Paleta projektu („zamrożona”)
- **Wyciągnięcie z konceptu:** `unfake quantize -c 24 --manifest m.json` zapisuje paletę do JSON. Alternatywy: Aseprite `ColorQuantization` (z Lua) albo `extract_palette` w MCP. W Node: biblioteka image-q (MIT, kwantyzatory Wu, NeuQuant i RGBQuant, dithering FS, Atkinson, Riemersma). [image-q](https://github.com/ibezkrovnyi/image-quantization). Ostatnia aktywność repo to 2023, więc biblioteka jest stabilna, ale nierozwijana.
- **Albo gotowa paleta z Lospec** (formaty HEX, GPL, PAL, ASE, PNG; licencje palet nie są podane na stronie listy). [lospec.com/palette-list](https://lospec.com/palette-list)
- **Wymuszanie:** każdy asset przechodzi przez `unfake quantize --palette paleta.hex` (stała paleta; alfa jest kopiowana bez zmian; `--reserve-color` chroni kolor-klucz) albo przez Aseprite `--palette paleta.gpl --color-mode indexed --dithering-algorithm none`. Kolejność opcji w Aseprite i to, czy konwersja na pewno użyje wczytanej palety, trzeba sprawdzić na próbce.
- sharp (Node) umie tylko `png({palette, colours, dither})`, czyli dobiera własną paletę. **Nie przyjmuje stałej palety**, więc do jej zamrożenia się nie nadaje. [sharp output](https://sharp.pixelplumbing.com/api-output)

### 2.2 Pikselizacja wyników AI
- **unfake.js / unfake-cli** (jenissimo, MIT, 938★, v1.4.0 z 2026-09-29, **gotowy `unfake-cli-…-x86_64-pc-windows-msvc.zip`**). Podkomendy: `detect` (skala siatki, także ułamkowa, np. 10,24 px), `snap` (przycięcie do siatki), `downscale` (`dominant`/`median`/`mode`/`mean`/`qvote`, siatka elastyczna lub stała), `quantize` (libimagequant, `--palette`, `--reserve-color`), a każdy krok może zapisać manifest JSON. [README](https://github.com/jenissimo/unfake.js), [main.rs CLI](https://github.com/jenissimo/unfake.js/blob/master/crates/unfake-cli/src/main.rs), [release](https://github.com/jenissimo/unfake.js/releases)
  - Ograniczenia według autora: siatka AI „pływa”, piksele krwawią, a „niektóre wyniki są zbyt chaotyczne albo zbyt malarskie na pełną automatyzację”. Wykrycie skali nie jest gwarantowane. [dev.to](https://dev.to/jenissimo/how-to-tame-your-ai-pixel-art-3pk5)
- perfectPixel (2258★; FFT + krawędzie Sobela, próbkowanie center/median/majority) i Astropulse/pixeldetector (MIT) są tylko w **Pythonie**, więc odpadają albo wymagają `uv`. [perfectPixel](https://github.com/theamusing/perfectPixel), [pixeldetector](https://github.com/Astropulse/pixeldetector). Licencji perfectPixel nie potwierdziłem (badge MIT, brak pliku LICENSE w API).
- Sieci „pixelization” (np. WuZongWei6/Pixelization) według relacji na itch.io mają licencję **niekomercyjną**, więc ich nie używamy. [itch.io](https://itch.io/post/8313282)
- Zwykłe skalowanie sharp `kernel: 'nearest'` [sharp resize](https://sharp.pixelplumbing.com/api-resize) i Godot `Image.resize(..., INTERPOLATE_NEAREST)` [Image](https://docs.godotengine.org/en/stable/classes/class_image.html) nadają się tylko do obrazów, które już leżą na równej siatce (podglądy ×4, skalowanie całkowite).

### 2.3 Sprzątanie i eksport, które Claude może wykonać (Aseprite `-b` + Lua)
1. Dopasowanie do kadru: `CanvasSize` lub `SpriteSize` do stałej klatki (np. 48×64 dla postaci, wielokrotności 32 dla mebli), punkt zakotwiczenia przy stopach.
2. Konwersja do palety projektu bez ditheringu.
3. Kontur: `Outline` na zewnątrz w ciemnym kolorze z palety (lub wewnętrzny).
4. Twarde krawędzie alfy (alfa 0 albo 255; w unfake binaryzacja jest w bibliotece JS, a w CLI to założenie do sprawdzenia). W Lua wystarczy prosta pętla `pixels()`.
5. Lint (skrypt Lua lub MCP `lint_sprite`): liczba kolorów, kolory spoza palety, osierocone piksele, rozmiar klatki, pivot.
6. Eksport: `--split-layers`/`--tag` → `--sheet … --sheet-type rows --data x.json --format json-array`. Podgląd `--scale 4` do oceny przez Claude (Read obrazu) i człowieka.

Tego automat **nie** zrobi: nie naprawi anatomii, czytelności twarzy w 60 px, spójności proporcji między kierunkami i klatkami chodu. To musi dać generator (Pixellab ma rotacje i animacje; zob. `08-assety-ai.md`). Skrypty zapewniają spójność palety, konturu, rozmiaru i formatu, ale nie spójność rysunku.

## 3. Normal mapy bez ręcznego malowania

| Narzędzie | Tryb wsadowy | Koszt | Uwagi |
|---|---|---|---|
| **Laigter** | tak: `-g/--no-gui`, `-d plik`, `-n` (normal), `-c`, `-o`, `-p`, `-r preset`, `-s` (programowy OpenGL); jeden plik na wywołanie, pętla w PowerShell | darmowy, GPL-3.0; v1.14.0 (2026-08-07), instalator i zip na Windows; ostatni push 2026-10-19 | wypukłość z transformaty odległości od alfy (Soft albo Abrupt) i szczegół „Enhance”; Invert X/Y; według dokumentacji Godot wymaga odwrócenia Y. Godot sam poleca Laigtera. [repo](https://github.com/azagaya/laigter), [normal-map-generation](https://laigter.readthedocs.io/en/latest/HowTo/normal-map-generation.html), [releases](https://github.com/azagaya/laigter/releases/tag/1.14.0), [Godot 2D lights](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html) |
| SpriteIlluminator | CLI nieudokumentowane (znalazłem tylko GUI; wsad przez zaznaczenie wielu plików) | 49,99 USD, licencja wieczysta, 1 rok aktualizacji, **zakaz użycia na serwerze, CI i w Dockerze**; −50% dla indie | emboss z jasności, bevel z alfy, pędzle wysokości. [strona](https://www.codeandweb.com/spriteilluminator), [sklep](https://www.codeandweb.com/store/spriteilluminator-perpetual) |
| Sprite DLight | — | — | ostatnie wiarygodne informacje z lat 2014–2015 (Kickstarter, early access); uznaję za porzucony. [gamedev.net](https://gamedev.net/forums/topic/663463-sprite-dlight-instant-normal-maps-for-2d-graphics-final-week33/) |
| npm `height-to-normal-map` | CLI | — | zależy od three.js i Puppeteera (przeglądarka headless), więc to przerost. [repo](https://github.com/lachoseparis/height-to-normal-map) |
| **Godot** | `Image.bump_map_to_normal_map(bump_scale)` w skrypcie headless; w shaderze `canvas_item` można zapisać `NORMAL` lub `NORMAL_MAP` (np. Sobel z `TEXTURE` przez `TEXTURE_PIXEL_SIZE`) | w zestawie | [Image](https://docs.godotengine.org/en/stable/classes/class_image.html), [canvas_item shader](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html) |

**Jakość w 3/4 (wniosek, nie źródło):** generatory z alfy i jasności traktują sprite jak płaskorzeźbę widzianą z przodu. Każdy brzeg „opada”, a jasne miejsca są „wyżej”. W 3/4 blat biurka i front szuflad dostają wtedy podobne normalne, a ciemne detale (szczeliny, guziki) robią się wklęsłe niezależnie od kształtu. Prototyp (ticket 19) pokazał, że czytelny wolumen dają normalne **autorowane w przestrzeni widoku**: fronty „na południe”, blaty „do góry” (`art.gd`: `SOUTH`, `UP`, `WEST`, `EAST` plus wypukłość z mapy wysokości, `_normal_at`).

**Rekomendacja:** jeden skrypt `normals` (Node z `sharp` do I/O PNG albo GDScript uruchamiany przez `godot --headless --script`) z dwoma wejściami:
1. **maska ścian** (PNG w 4–5 płaskich kolorach: góra, front, lewo, prawo, płasko). Dla mebli i kafli Claude rysuje ją prostokątami i wielokątami w kodzie (to samo, co już robi `sprites.gd`). Dla postaci wystarczy „walec/poduszka” z alfy, bo ciało jest obłe.
2. **wypukłość** z alfy (odległość od krawędzi) plus słaby szczegół z jasności, dodana do bazowej normalnej ściany (jak `_normal_at`).

Laigter warto mieć do porównania A/B w zatoce assetów prototypu (`assets.gd`, klawisz V). Konwencję osi Y sprawdzić trybem z odwróconą zieloną w `Art.set_normal_mode(2)`: Laigter twierdzi, że Godot wymaga odwrócenia Y, a prototyp domyślnie zapisuje „green up”.

## 4. Pixel art rysowany kodem (tylko placeholdery)
- Prototyp (`sprites.gd`, `art.gd`) pokazuje rzeczywisty sufit: bryły mebli, budynków i kafli z prymitywów są czytelne, a normalne wychodzą „za darmo”. Postacie z elips i prostokątów są tylko sylwetkami.
- Nie znalazłem żadnego benchmarku LLM dla pixel artu. Benchmarki SVG mówią, że modele lepiej radzą sobie z semantyką niż z niskopoziomową geometrią. [VGBench](https://arxiv.org/pdf/2407.10972), [S. Willison](https://simonwillison.net/2025/Nov/25/llm-svg-generation-benchmark/). Wniosek: kod nadaje się do kafli, prostych propsów, masek normalnych i placeholderów, ale nie do docelowych postaci.

## 5. Gotowe paczki (awaryjnie)
- **LimeZu Modern Interiors** (16/32/48 px, top-down w stylu RPG Maker, postacie 1×2 kafle, czyli 32×64 przy 32 px, generator postaci w pełnej wersji). Od 1,50 USD, użycie komercyjne, edycja dozwolona, **wymagane uznanie autorstwa**, zakaz redystrybucji. Ma m.in. więzienie, szpital i kostnicę; posterunku nie ma. [itch.io](https://limezu.itch.io/moderninteriors). Modern Exteriors (2,50–5 USD) ma ulice, auta i wóz policyjny, ale bez śniegu. [itch.io](https://limezu.itch.io/modernexteriors)
- **Kenney:** CC0, bez obowiązku uznania autorstwa. [kenney.nl/support](https://kenney.nl/support). Nie sprawdzałem, czy jest paczka 3/4 w skali 32 px z postacią ok. 60 px (raczej nie).
- **OpenGameArt:** licencje mieszane (CC0, CC-BY, CC-BY-SA, OGA-BY, GPL); każdą trzeba sprawdzić osobno. [FAQ](https://opengameart.org/content/faq). Zimowe kafle 32 px istnieją, ale są małe i proste (np. pebonius „Wintery”, CC0).
- **Ryzyko:** paczki mają jasną, „przytulną” estetykę i nie mają normal map. Mieszanie z assetami z generatora rozjedzie styl. Częściowo ratuje to wspólna paleta (§2.1), wspólny kontur i nocne oświetlenie, ale proporcje i rysunek zostają obce. Najlepiej używać ich tylko jako placeholderów do szkieletu gry.

## 6. Konkretny setup na Windows (bez Pythona)
1. **Aseprite** ze Steam (84,99 zł) i ścieżka do exe w zmiennej projektu, np. `ASEPRITE=C:\Program Files (x86)\Steam\steamapps\common\Aseprite\Aseprite.exe` (ścieżkę sprawdzić). Alternatywa: kompilacja (VS 2022 + CMake + Ninja + Skia m124).
2. **unfake-cli**: zip z GitHub Releases rozpakowany do `tools/unfake/` w repo lub poza nim (bez zmian w PATH).
3. **Laigter** 1.14.0 `laigter-windows.zip` do `tools/laigter/`; preset zapisany raz z GUI i trzymany w repo.
4. **Node 22** (już jest): `npm i -D sharp` lokalnie w projekcie narzędzi; skrypty `pipeline/*.mjs` łączą kroki i piszą manifest.
5. **Godot 4.7.2 headless** jako alternatywa dla kroku normal map i do importu (ścieżkę exe podaje człowiek).
6. Opcjonalnie: `uv` + diivi/aseprite-mcp, po zgodzie człowieka na instalację.

Przepływ jednego assetu: `wejście.png` (z generatora pixel art) → `unfake detect` → `unfake downscale` → `unfake quantize --palette projekt.hex` → `aseprite -b --script cleanup.lua` (kadr, kontur, lint, arkusz + JSON, podgląd ×4) → `normals` (maska ścian + alfa) lub Laigter → PNG `x.png` i `x_n.png` → Godot (CanvasTexture; zatoka assetów w prototypie).

## 7. Niepewności
- Nie testowałem żadnego narzędzia lokalnie. Jakość unfake na wynikach Pixellab i Retro Diffusion, zachowanie Laigtera `-g` bez GPU i działanie diivi MCP na natywnym Windows są niezweryfikowane.
- Aseprite: czy `--palette` przed `--color-mode indexed` mapuje na wczytaną paletę oraz czy w `-b` skrypt może pisać pliki bez pytania o zgodę.
- Krita MCP, GIMP batch w 3.x (przykład `plug-in-script-fu-eval` może pochodzić ze starszej dokumentacji) i Photopea nie są potwierdzone źródłowo.
- Ocena jakości normalnych w 3/4 to wniosek z prototypu i z opisu algorytmów, nie z porównania na prawdziwych assetach.
- Licencje palet Lospec i perfectPixel nie są potwierdzone.
