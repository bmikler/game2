> Kopia z game1 (`repo/game1/docs/research/24b-blender-mcp.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# 24b Blender sterowany przez Claude: koncept → model 3D → sprite pixel art z normal mapą

Ticket: `docs/wayfinder/tickets/24-assety-przez-claude.md` (ścieżka „Blender przez MCP”). Data researchu i dostępu do wszystkich źródeł: **2026-10-28**. Źródła pierwotne tam, gdzie się dało; źródła wtórne i rzeczy niezweryfikowane są oznaczone.

Założenie przepływu (od zleceniodawcy): koncept (obraz z generatora + referencje) → wybór wyglądu → **image-to-3D z tego konceptu** → Blender renderuje sprite'y w stylu konceptu. Etap generowania konceptu opisuje osobny research.

## Streszczenie

- Ścieżka jest **technicznie realna** i ma precedens: Dead Cells renderuje postacie 3D do pixel artu ~50 px bez antyaliasingu, z normal mapą na każdą klatkę. Autor przyznaje jednak, że problemu migoczących pikseli nie rozwiązali, a detal jest ograniczony ([Vasseur, Game Developer](https://www.gamedeveloper.com/production/art-design-deep-dive-using-a-3d-pipeline-for-2d-animation-in-i-dead-cells-i-)).
- **MCP nie jest potrzebny do produkcji.** Do masowego renderu lepszy jest `blender --background --python skrypt.py`: powtarzalny, wersjonowany w git, bez otwartego gniazda wykonującego dowolny kod. MCP przydaje się do interaktywnego ustawiania sceny (kamera, światło, materiał) z podglądem.
- **Normal mapa nie jest „za darmo” z passu Normal:** pass Normal w Blenderze jest w przestrzeni świata ([manual 5.2](https://docs.blender.org/manual/en/latest/render/layers/passes.html)). Godot wymaga mapy w konwencji X+/Y+/Z+ (OpenGL, zielony w górę) ([CanvasTexture](https://docs.godotengine.org/en/stable/classes/class_canvastexture.html)). Trzeba osobnego renderu z materiałem, który przelicza normalne do przestrzeni kamery. To kilka węzłów i w pełni skryptowalne.
- **Image-to-3D z konceptu:** Meshy (API: 1–4 obrazy wejściowe, osobne obrazy sterujące teksturą, wymuszenie A/T-pose) i Tripo (multi-view w Pro) są najsensowniejsze. Hunyuan3D jest **wykluczony prawnie w UE** (licencja wag nie obowiązuje w UE, UK ani Korei Płd.). Wierności konceptowi nie potwierdza żaden benchmark pierwotny, trzeba ją sprawdzić testem.
- **Koszt:** Blender, Mixamo i skrypty są darmowe. Generator 3D kosztuje ok. 20 USD/mies. przez 1–3 miesiące produkcji. Razem szacunkowo **20–60 USD**.

## 1. Serwery MCP dla Blendera

### 1a. Społecznościowy: ahujasid/blender-mcp (pakiet `mcp-for-blender`)

Źródło: https://github.com/ahujasid/blender-mcp
- Pakiet PyPI zmienił nazwę z `blender-mcp` na `mcp-for-blender`. Licencja MIT, ok. 32,5 tys. gwiazdek.
- Wymagania: Blender ≥ 3.0, Python ≥ 3.10 i **uv**. README każe instalować uv oficjalnym instalatorem, a nie przez `pip`.
- Windows bez skryptu instalacyjnego: `winget install --id=astral-sh.uv -e`, potem `uvx mcp-for-blender setup`. Ręcznie: `uvx mcp-for-blender install-addon`, a następnie włączenie addonu w Edit → Preferences → Add-ons.
- Claude Code według README: `claude mcp add blender uvx mcp-for-blender`. Według [dokumentacji Claude Code](https://code.claude.com/docs/en/mcp) poprawna forma ma separator `--`: `claude mcp add --transport stdio blender -- uvx mcp-for-blender`. Na Windows README podaje obejście dla błędu `spawn uvx ENOENT`: pełna ścieżka do `uvx` albo `cmd /c uvx mcp-for-blender`.
- Narzędzia (9): `execute_blender_code` (dowolny Python w żywym Blenderze), `look` (zrzut viewportu, kamery, wielu kątów, paska animacji lub renderu), `get_scene_info`, `generate_3d`, `search_assets`, `import_asset`, `get_addon_status`, `disable_telemetry`, `record_trajectory_feedback`.
- Integracje:
  - Hyper3D Rodin: klucz API.
  - Hunyuan3D przez Tencent Cloud: SecretId/SecretKey.
  - Sketchfab: klucz API.
  - Poly Haven: CC0, bez klucza.
  - Poly Pizza: low-poly, często CC-BY.
  - Meshy: Premium albo płatny klucz.
- Znane problemy według README:
  - pobieranie z Poly Haven zamraża UI;
  - złożone polecenia przekraczają limit czasu, więc trzeba je dzielić na mniejsze kroki;
  - może działać tylko jedna instancja serwera;
  - częsty „fix” to restart klienta i Blendera.
- Otwarte issues (31 otwartych, stan z 2026-10-28, https://github.com/ahujasid/blender-mcp/issues):
  - #401: Defender oznacza instalator PowerShell jako trojana;
  - #387: błąd `claude mcp add`;
  - #391, #339: problemy z połączeniem;
  - **zgłoszenia bezpieczeństwa z 21.10.2026**: #404 (nieuwierzytelnione gniazdo wykonuje Pythona), #405 (narzędzie Hyper3D czyta pliki spoza workspace), #406 (Hunyuan3D pobiera z adresów sieci wewnętrznej).
- Bezpieczeństwo i telemetria (README): gniazdo addonu nie ma uwierzytelniania ani szyfrowania. Tryb `BLENDER_MCP_SAFE_MODE=1` blokuje dostęp do plików, sieci i procesów. **Telemetria jest domyślnie włączona** (anonimowy rekord użycia). Wyłącza ją `DISABLE_TELEMETRY=true`. Dane z opt-in mogą posłużyć do trenowania modeli.

### 1b. Oficjalny: Blender Lab MCP Server

Źródło: https://www.blender.org/lab/mcp-server/ (repo projects.blender.org/lab/blender_mcp zwróciło 403).
- Wymaga **Blendera 5.1+**. Addon ma wersję 1.0.3 i instaluje się z repozytorium Blender Lab (z powiadomieniami o aktualizacjach). Serwer instaluje się jako bundle `.mcpb` albo ze źródeł.
- Strona nie opisuje Claude Code ani nie wymienia listy narzędzi. Ostrzega, że wykonuje kod z LLM bez zabezpieczeń przed usunięciem lub wysłaniem danych, i zaleca VM albo system bez wrażliwych danych.
- Według źródła wtórnego ([StraySpark](https://www.strayspark.studio/blog/official-blender-mcp-server-comparison-2026), niezweryfikowane) używa tego samego portu 9876 co serwer społecznościowy, więc obu nie da się uruchomić naraz.
- Aktualna wersja manuala to Blender 5.2 LTS.

**Wniosek:** do pracy w tym projekcie wystarczy jeden z nich, i to tylko na etapie ustawiania sceny. Oficjalny ma mniej ruchomych części (bez integracji z chmurą), ale jego setup z Claude Code nie jest udokumentowany: **niepewne**.

## 2. Image-to-3D z konceptu (postacie i propsy)

| Narzędzie | Wejście z konceptu | Rig/animacja | Koszt | Licencja komercyjna |
|---|---|---|---|---|
| **Meshy** | Image-to-3D; API multi-image: 1–4 obrazy (np. turnaround z konceptu); `texture_image_urls` 1–4 widoki sterujące **tylko teksturą** (pierwszy = przód); remesh do `target_polycount` 100–300 000, quad/tri ([API](https://docs.meshy.ai/en/api/multi-image-to-3d)) | Auto-rig (humanoid, czworonóg) za 0 kredytów, >600 presetów animacji (kategoria Walk & Run), eksport FBX/GLB ze szkieletem w szablonie Mixamo; część presetów wymaga płatnego planu ([Animate](https://docs.meshy.ai/en/webapp/guides/animate)) | Free: 100 kr./mies.; image-to-3D 20–25 kr., tekstura +10, remesh i rig 0 ([pricing](https://docs.meshy.ai/en/webapp/pricing)); Pro 20 USD/mies. ([meshy.ai/pricing](https://meshy.ai/pricing), wg wyszukiwarki) | Free: **CC BY 4.0** (atrybucja). Płatne: licencja prywatna, pełne prawa komercyjne |
| **Tripo** | Image-to-3D; Multi-view to 3D, Smart Low Poly, Smart Segmentation w Pro ([pricing](https://www.tripo3d.ai/pricing)) | „Rigging & Animation” i „DCC Bridge Blender” w tabeli planów; szczegółów rigu nie zweryfikowałem | Free: 200 kr. (≈13 modeli); Pro 20 USD/mies. (rocznie) za 3000 kr. (≈200 modeli) | Free: **niekomercyjna**, modele publiczne. Pro: modele prywatne, użycie komercyjne |
| **Hyper3D Rodin** | Image-to-3D; obsługi wielu obrazów **nie zweryfikowałem** (strona API się nie wczytała) | brak danych | Creator 30 USD/mies., ok. 60 modeli; płatność za wynik 1,50 USD/kredyt ([hyper3d.ai/pricing](https://hyper3d.ai/pricing), przez wyszukiwarkę) | „any use” w płatnych planach; dokładny zakres **niepewny** |
| **Hunyuan3D 2.x** | Wariant `2mv` przyjmuje wiele widoków; lokalnie potrzeba 6 GB VRAM na kształt i 16 GB z teksturą ([README](https://github.com/Tencent-Hunyuan/Hunyuan3D-2)) | brak | darmowy lokalnie | **Licencja nie obowiązuje w UE, UK i Korei Płd.** ([LICENSE 2.1](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1/blob/main/LICENSE)). Dla dewelopera z Polski i gry na Steamie: **odpada**. Warunków API Tencent Cloud nie sprawdzałem |

Wierność konceptowi i spójność:
- Nie znalazłem pierwotnego, niezależnego porównania wierności image-to-3D dla stylizowanych postaci. Ocena musi przyjść z własnego testu: 2–3 postacie z tego samego konceptu w Meshy i Tripo na darmowych kredytach.
- Co według dokumentacji podnosi trafność:
  - koncept w **A-pose lub T-pose** na neutralnym tle, bo daje najlepszy rig ([Meshy Animate](https://docs.meshy.ai/en/webapp/guides/animate));
  - **turnaround** (przód, bok, tył) zamiast jednego ujęcia (multi-image w Meshy, multi-view w Tripo);
  - dla Meshy: osobne widoki sterujące teksturą.
- Wniosek wyprowadzony (nie ze źródła): przy 60 px drobny detal twarzy i tekstury i tak znika. Liczą się sylwetka, proporcje i duże plamy koloru. Koncept powinien mieć wyraźne bryły i ograniczoną paletę, bo wtedy niedokładność modelu 3D jest mniej widoczna.

## 3. Animacja bez umiejętności

- **Mixamo:** według FAQ Adobe jest darmowe z kontem Adobe ID, bez subskrypcji Creative Cloud. Licencja royalty-free obejmuje gry komercyjne. Auto-rig działa **tylko dla dwunożnych humanoidów** ([FAQ](https://helpx.adobe.com/ca/creative-cloud/faq/mixamo-faq.html); strona zwraca 403 dla botów, więc treść potwierdziłem tylko przez wyszukiwarkę). Mixamo nie jest rozwijane („maintenance mode”, źródło wtórne [Cinevva](https://app.cinevva.com/guides/free-character-animations-rigging)). Jest to ryzyko, ale nie blokada.
- **Meshy:** rig i walk w jednym miejscu, eksport FBX/GLB ze szkieletem Mixamo. Jest to najprostsza ścieżka: jeden plik z gotowymi klipami, import do Blendera przez `bpy.ops.import_scene.gltf`/`fbx`.
- Ważne dla 4 kierunków: postać **chodzi w miejscu**. W Mixamo jest opcja „In Place” (z mojej wiedzy, niezweryfikowane w źródle). Kierunki uzyskuje się obrotem modelu o 0/90/180/270° przed kamerą, a nie ruchem kamery.

## 4. Render do pixel artu w Blenderze

Precedens (Dead Cells, [Vasseur](https://www.gamedeveloper.com/production/art-design-deep-dive-using-a-3d-pipeline-for-2d-animation-in-i-dead-cells-i-)): model 3D, render w małej rozdzielczości **bez antyaliasingu**, PNG plus normal mapa na klatkę, toon shader, postać 50 px. Znane wady: **migoczące piksele** (nierozwiązane), mniej detalu. Ręcznie tego nie poprawiali.

Ustawienia (do zapisania w skrypcie):
- **Kamera:** ortograficzna, nachylona do widoku 3/4. Kąt dobrać do kafla 32 px i istniejących teł. `ortho_scale` dobrać tak, żeby postać 1,8 m miała ok. 60 px, i zablokować go dla wszystkich assetów. Ta sama skala dla wszystkich obiektów to warunek spójności. „Lock sprite scale against pixel crawl” wymienia też [True Pixel Art Generator](https://superhivemarket.com/products/true-pixel-art-generator-v2/docs).
- **Rozdzielczość:** bezpośrednio docelowa (np. 64×64 na klatkę), bez skalowania w dół z dużego renderu. Antyaliasing wyłączony: w EEVEE filter size bliski 0, w Workbench „No Anti-Aliasing”. Film → Transparent. Dokładne nazwy opcji w 5.2: **do sprawdzenia**.
- **Shading w stylu konceptu:** materiał toon (Shader to RGB → Color Ramp „Constant” z 2–3 stopniami) albo prawie unlit (emisja koloru bazowego) z cieniowaniem zostawionym Godotowi. Przy świetle z Godota rozsądniej jest renderować **albedo z płaskim, lekkim cieniowaniem**, a bryłę oddać normal mapie. To wniosek własny, do weryfikacji w prototypie oświetlenia.
- **Paleta z konceptu:** kwantyzacja do palety (np. 16–32 kolorów) wyciętej z wybranego konceptu, w postprocessie PNG. Blender ma własny Python z numpy, więc da się to zrobić w tym samym skrypcie, bez systemowego Pythona (który na tej maszynie jest tylko stubem). Alternatywnie Node lub shader w Godocie. Ta sama paleta dla wszystkich assetów daje spójność między postaciami, propsami i kaflami.
- **Kontur:** Freestyle przy 64 px jest niestabilny (wniosek, niezweryfikowany). Pewniejszy jest kontur 1 px dorysowany w postprocessie z kanału alfa (piksel tła sąsiadujący z sylwetką dostaje kolor konturu) albo shader w Godocie.
- **Klatki:** 4 kierunki × (walk ok. 8 + idle ok. 4) ≈ 48 klatek na postać. Render obrazu `-a` z `--render-output`, potem sklejenie w sheet.
- **Normal mapa dla Godota:**
  - Pass Normal jest w **przestrzeni świata** ([manual](https://docs.blender.org/manual/en/latest/render/layers/passes.html)), a Godot oczekuje X+/Y+/Z+ ([CanvasTexture](https://docs.godotengine.org/en/stable/classes/class_canvastexture.html), [import obrazów: OpenGL-style, opcja „Normal Map Invert Y” dla DirectX](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html)).
  - Rozwiązanie: drugi render z override materiału: Geometry Normal → Vector Transform (World → Camera, typ Normal) → ×0,5 + 0,5 → Emission. W przestrzeni kamery Blendera X jest w prawo, Y w górę, a normalna skierowana do kamery ma Z+. To daje układ OpenGL. Wyprowadzenie własne, **do weryfikacji jednym testowym sprite'em w Godocie**.
  - Transformacja widoku musi być „Raw”/„Standard” bez AgX, bo inaczej wartości zostaną przekłamane. Zapis PNG 8-bit.
  - Normal mapa nie może być kwantyzowana do palety. Jej alfa musi odpowiadać sprite'owi.
- **Gotowe narzędzia:**
  - [SpriteAtlasAddon](https://github.com/Mattline1/SpriteAtlasAddon): N kątów + atlas, darmowy;
  - [BlenderSpriteSheetImporter](https://godotengine.org/asset-library/asset/edit/10634): skrypt Blendera i import do Godot SpriteFrames, MIT, 8 kierunków;
  - płatne: True Pixel Art Generator (Blender 4.0–4.5), Render 8 Directions;
  - [GodotPixelStudio](https://bukkbeek.itch.io/pixel-renderer/devlog/991346/pixel-renderer-released): render 3D→pixel w samym Godocie z kwantyzacją, konturem i ditheringiem; normal map nie potwierdziłem.

  Żadne z tych narzędzi nie robi normal map pod Godota 2D „z pudełka” (nie znalazłem). Własny skrypt ok. 200–300 linii jest prostszy niż dopasowywanie addonu.
- **Jakość bez ręcznej poprawki (ocena):** przy ok. 60 px wychodzi czytelna, „miękka” sylwetka w stylu Dead Cells, a nie ręczny pixel art. Typowe wady:
  - migotanie pojedynczych pikseli między klatkami;
  - poszarpane cienkie elementy (ręce, nogi przy chodzie bokiem);
  - zlewające się twarze;
  - przy obrocie 3/4 szum na krawędziach.

  Częściowo łagodzą to: grubsze bryły w modelu, mniej klatek, kwantyzacja do palety i kontur. Nie znalazłem źródła, które mierzy to dla 60 px. Trzeba to ocenić okiem na teście.

## 5. MCP czy zwykłe skrypty headless

- Blender 5.2 CLI ([arguments](https://docs.blender.org/manual/en/latest/advanced/command_line/arguments.html)): `-b/--background`, `-P/--python <plik>`, `-a`, `-f <klatka>`, `-o/--render-output`, `--python-exit-code <kod>` (błąd skryptu zwraca kod ≠ 0, więc Claude Code widzi porażkę), `--` przekazuje argumenty do `sys.argv`.
- **Skrypty:** powtarzalne, w git, uruchamiane z Claude Code przez Bash/PowerShell, bez uv, MCP, otwartego portu i telemetrii. Wady: Claude nie „widzi” sceny. Obejście: skrypt renderuje podgląd PNG, który Claude czyta narzędziem Read.
- **MCP:** szybkie iteracje na żywej scenie (`look`, `get_scene_info`) i wygodne importy z generatorów. Wady: niestabilne połączenia (issues), limity czasu przy długich renderach, ryzyko bezpieczeństwa, stan sceny poza git.
- **Rekomendacja:** produkcja przez skrypty headless. MCP opcjonalnie, tylko do jednorazowego strojenia kamery i materiału, a wynik i tak zapisać jako skrypt lub `.blend` w repo.

## Werdykt: kiedy 3D→pixel się opłaca, a kiedy to przesada

Blender był tylko przykładem. Uczciwa ocena dla początkującego (wnioski własne na podstawie źródeł powyżej):

- **Opłaca się dla animowanych postaci w 4 kierunkach.** Jeden model daje wszystkie kierunki i klatki ze spójnymi proporcjami. Normal mapy dla każdej klatki wychodzą z tego samego renderu, a nowa animacja to kolejny klip z biblioteki zamiast nowej serii rysunków. Właśnie ten problem rozwiązywało Dead Cells. Przy ok. 5–10 postaciach × 4 kierunki × ~12 klatek (~500 klatek plus tyle samo normal map) trudno o spójność inną drogą bez ręcznej poprawki.
- **Przesada dla propsów, kafli i teł.** Są statyczne i widoczne z jednego kąta. Generowanie modelu 3D tylko po to, żeby zrobić z niego jeden obrazek, dokłada koszt, skrypty i ryzyko rozjazdu stylu. Prostsze narzędzia 2D z generowaniem normal map z obrazu wystarczą (osobny research). Wyjątek: duże propsy z wyraźną bryłą (np. biurko, radiowóz), gdzie normal mapa z 3D wyraźnie poprawia światło. Tylko jeśli pipeline postaci już i tak działa.
- **Próg wejścia:** Blender, skrypt renderu i API generatora to najwięcej ruchomych części ze wszystkich ścieżek. Ma to sens dopiero, gdy ścieżka 2D zawiedzie na animacji postaci, czyli na spójności między kierunkami i klatkami albo na normal mapach animowanych klatek. Rozsądna kolejność: najpierw tani spike ścieżki 2D na postaci, a 3D→pixel jako plan B lub hybryda (3D tylko dla postaci).

## Rekomendacja

1. Zacznij **bez MCP**: Blender 5.2 LTS, skrypt `render_sprites.py` uruchamiany headless przez Claude Code.
2. Generator 3D: **Meshy** (image/multi-image-to-3D, auto-rig i walk w jednym, szkielet Mixamo, API). Na start Free do testów; licencja CC BY wymaga atrybucji. Na produkcję 1–2 miesiące Pro. Tripo Pro jako alternatywa do porównania. **Nie Hunyuan3D** (UE).
3. Najpierw spike (1 postać + 1 props): koncept → Meshy → walk → render 4 kierunków + normal mapa → test w Godocie przy PointLight2D. Dopiero potem decyzja w tickecie 22.

## Setup na Windows 11 (skrót)

1. Blender 5.2 LTS z blender.org. Ścieżkę do `blender.exe` podać Claude, bo nie ma go w PATH.
2. Konto Meshy (Free, potem ewentualnie Pro). Klucz API w zmiennej środowiskowej, nie w repo.
3. Skrypty Claude: Node do API Meshy, `render_sprites.py` uruchamiany przez `blender.exe -b -P render_sprites.py --python-exit-code 1 -- <argumenty>`.
4. Opcjonalnie MCP: uv przez winget (instalacja globalna, **za zgodą użytkownika**), potem `uvx mcp-for-blender install-addon` i `claude mcp add --transport stdio blender -- cmd /c uvx mcp-for-blender`. Do tego `DISABLE_TELEMETRY=true`.

## Koszt (szacunek)

- Blender, Mixamo, skrypty, Godot: 0 USD.
- Meshy Pro 20 USD/mies. To 1000 kredytów (wg strony cennika, przez wyszukiwarkę), czyli ok. 35–40 modeli z teksturą przy 25+10 kr., a rig i animacja kosztują 0. Przy wielu iteracjach na postać realnie 1–3 miesiące, czyli **20–60 USD**. Tripo Pro 20 USD/mies. przy 3000 kr. (≈200 modeli) może wyjść taniej na iteracje.
- Ceny pochodzą ze stron producentów z 2026-10-28 i zmieniają się często.

## Ile pracy ręcznej zostaje

- **Zerowa praca plastyczna** jest realna tylko przy akceptacji wad renderu (migotanie, uproszczony detal), tak jak w Dead Cells.
- Zostaje praca **decyzyjna, wykonywana okiem** (szacunek, bez źródła):
  - wybór najlepszego z kilku modeli;
  - ocena sprite'u w grze;
  - dobór kąta kamery i palety raz na projekt;
  - odrzucanie złych generacji.

  Szacuję ok. 1–2 h na postać po ustawieniu pipeline'u, a sam pipeline to kilka sesji z Claude.
- Rzeczy, których nie da się zautomatyzować bez ręcznej edycji: poprawki pojedynczych pikseli, twarze czytelne w 60 px, nietypowe animacje spoza bibliotek (przeszukiwanie, interakcje z obiektami).

## Niepewności

- Wierność image-to-3D wobec konkretnego konceptu i stylu: brak źródła, potrzebny test.
- Dokładne nazwy opcji AA i color management w Blenderze 5.2 oraz poprawność wyprowadzenia normal mapy: test w Godocie.
- Mixamo: FAQ Adobe potwierdzone tylko przez wyszukiwarkę; status „maintenance” ze źródła wtórnego.
- Rodin: obsługa wielu obrazów i zakres licencji niezweryfikowane. Warunki API Tencent Cloud dla Hunyuan3D niesprawdzone.
- Oficjalny Blender Lab MCP: setup z Claude Code nieudokumentowany.
- Cena i liczba kredytów Meshy Pro: dokumentacja nie podaje kwot, a strony trzecie są sprzeczne.
