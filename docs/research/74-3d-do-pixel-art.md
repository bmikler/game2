# 74. Postacie w całości z Blendera do pixel artu 72 px: zasoby, render, tekstura, hybrydy

Data: 2026-11-08. Kontekst: ticket 12 (Przepis postaci), research 71 (animacja chodu), ticket 09 (rzut 0,60; 40 px/m; postać 72 px; kadr 960×540; 3 kierunki + lustro). Nic nie zostało wygenerowane, zainstalowane ani założone; pobrane tylko pliki licencji/README do scratchpada (poza repo). Odczyt lokalny: `style-lab/tools/mocap/cmu/`, `tools/blender/` (MPFB, `postac_chod.py`, `szkielet_chodu.py`).

Oznaczenia: **[pierwotne: URL]** = źródło, które jest właścicielem faktu (repo, karta modelu, strona autora, manual); **[wtórne: URL]** = blog, forum, agregator, wyszukiwarka; **[wniosek]** = moja inferencja; **[brak]** = nie znalazłem / nie zweryfikowałem.

## Odpowiedź w skrócie

1. **Tak, da się w całości w Blenderze** i istnieje komplet darmowych, komercyjnie czystych klocków: model MPFB (CC0) + rig „CMU MB” + mocap CMU (już lokalnie) albo Quaternius UBC + UAL (CC0, jeden wspólny rig, bez retargetingu). Render do 72 px bez antyaliasingu jest standardową techniką (Dead Cells robił tak z postaciami ~50 px).
2. **Wąskie gardło to „wygląd malarski”, nie ruch.** Ruch i spójność klatek 3D daje „za darmo” (to dokładnie to, czego nie dał Pixellab i Qwen na klatkach). Styl NORCO/REPLACED trzeba wnieść teksturą (projekcja naszego konceptu) i shadingiem (kilka stopni + kontur); model MPFB ma ~6–7 głów i dorosłe proporcje, ale jest „manekinem”, więc wygląd ubrań zależy od tekstury/proxy ubrań.
3. **AI image-to-3D nie jest potrzebne i nie pasuje do 8 GB**: TRELLIS.2 wymaga 24 GB (README), TRELLIS v1 16 GB; Hunyuan3D 2.x odpada przez wyłączenie UE. Do postaci rigowanej wystarczy MPFB lub Quaternius.
4. **Mixamo odpada praktycznie** (wymaga konta Adobe ID, które zakładać nie wolno; serwis w trybie „maintenance”). Bandai Namco Motion Dataset **odpada** (CC BY-NC).
5. **Rekomendacja:** dwa testy w style-lab (§7): (A) MPFB + rig CMU MB + BVH CMU → render 72 px z projekcją konceptu; (B) Quaternius UBC+UAL Standard jako szybki test „jakości ruchu i pipeline'u renderu” (inny styl modelu, ale zero pracy z riggiem). Oba renderowane tym samym skryptem Blendera (Shader-to-RGB + posteryzacja + kontur).

## 1. Zasoby gotowe

### 1.1 Postacie i ubrania

| Zasób | Licencja (cytat) | Skryptowe pobranie / bez konta | Uwagi |
|---|---|---|---|
| **MPFB2** (MakeHuman dla Blendera; już zainstalowany) | Kod GPLv3, **assety CC0**: „These assets have been released under CC0 1.0 Universal. In summary this means that to the fullest extent possible, it is the intention of the MakeHuman team that anyone can do whatever they want with it.” Wynik: „the MakeHuman team makes no claim whatsoever over output such as: Exports to files (FBX, OBJ, DAE, MHX2...), Graphical data generated via scripting or plugins, Renderings…” **[pierwotne: raw.githubusercontent.com/makehumancommunity/mpfb2/master/LICENSE.md]** | Instalacja z extensions.blender.org już zrobiona (ticket 12). Wymaga Blendera ≥ 4.2 **[pierwotne: github.com/makehumancommunity/mpfb2]**; u nas działa na 5.2 **[log: ticket 12]**. | Rigi: Default (z/bez palców stóp), GameEngine, **CMU MB** („mostly useful if you want to use CMU mocap animations”), Mixamo, Rigify **[pierwotne: static.makehumancommunity.org/mpfb/docs/characters/rig.html]**. Dodatkowe ubrania/assety z repozytorium społeczności mają **własne** licencje, bundlowane są CC0 **[brak: nie sprawdzałem licencji pojedynczych paczek ubrań; sprawdzić przed użyciem każdej]**. |
| **Quaternius Universal Base Characters (UBC)** | „Free to use in personal, educational and commercial projects. (CC0 License)”; Standard (FBX/glTF/OBJ) darmowe, Source (.blend, płatne) **[pierwotne: quaternius.com/packs/universalbasecharacters.html]** | Strona nie mówi o koncie; linki „Download here”/Itch.io **[pierwotne]**. Bezpośredniego URL pliku nie ma w HTML strony **[brak]**; pobranie ręcznie z przeglądarki (jednorazowo) **[wniosek]**. | 6 modeli (Superhero, Regular, Teen; M/K), humanoidalny rig, ~13k trójkątów, 20 fryzur; ubrań nie wymieniono **[pierwotne]**. Styl niskopoligonowy/stylizowany **[wniosek: ~13k tri, kategoria „Teen/Superhero”]**, nie 6–7 głów realistycznie. |
| **Mixamo (postacie i auto-rig)** | Wspólnota/Adobe: „You can use the auto-rigger, characters and animations in any type of creative project”, „The only thing you can't do is distribute the raw character and animation files”, dane Mixamo „can't be used” do trenowania modeli ML **[wtórne: community.adobe.com/…/mixamo-faq-licensing-royalties-ownership-eula-and-tos/td-p/13234775 (post z 2022, nie oficjalna FAQ)]**. Oficjalna FAQ helpx.adobe.com zwraca nam 403 **[brak: nie przeczytałem oficjalnego tekstu]**. | **Wymaga konta Adobe ID** (darmowego) **[wtórne: wyniki wyszukiwania cytujące FAQ Adobe]**; brak API/skryptu **[wniosek]**; serwis „w trybie maintenance”, awarie od czerwca 2025 **[wtórne: app.cinevva.com/guides/free-character-animations-rigging; community.adobe.com]**. | Odpada: konta nie zakładamy, a sprite'y (nie surowe pliki) i tak byłyby dozwolone. Poza tym MPFB ma gotowy rig Mixamo i skrypt „map mixamo” **[pierwotne: static.makehumancommunity.org/mpfb/docs/rigging_posing/mixamo.html]**, więc to opcja na później, jeśli człowiek sam zdecyduje o koncie. |

### 1.2 Biblioteki animacji

| Zasób | Licencja | Pobranie | Uwagi |
|---|---|---|---|
| **CMU Mocap (BVH, Hahne)**: lokalnie `style-lab/tools/mocap/cmu/` | „This data is free for use in research and commercial projects worldwide” (cytat CMU w `READMEFIRST.txt`) **[pierwotne: raw.githubusercontent.com/una-dinosauria/cmu-mocap/master/READMEFIRST.txt]**. Uwaga: kopia FBX na 4TU ma w metadanych CC BY-NC (nie używać tej kopii) **[wtórne: data.4tu.nl/datasets/0448aab2-…]**; mirror CMU mówi też, że nie wolno sprzedawać danych jako takich **[wtórne: wyniki wyszukiwania, tekst z mirrora papers-with-code; oryginalnej strony mocap.cs.cmu.edu nie otworzyłem: błąd certyfikatu]**. | Mamy już. Skrypt: `git`/raw GitHub, bez konta. | 120 fps, szkielet MotionBuilder-style, T-poza w klatce 1 **[pierwotne: READMEFIRST]**. Sprite'y to nie odsprzedaż danych **[wniosek]**. Ruch „amatorski”/zróżnicowany jakościowo; spacer 02_01, 07_01, 35_01 już wybrane (ticket 12). |
| **Quaternius Universal Animation Library (UAL 1)** | CC0: „Free to use in personal, educational and commercial projects.” **[pierwotne: quaternius.com/packs/universalanimationlibrary.html]** | itch.io: **Standard (15 MB) darmowy, „45 completely free animations”**; Pro ($9,99+, 120+ klipów, FBX/GLB), Source ($14,99+, .blend) **[pierwotne: quaternius.itch.io/universal-animation-library]**. Czy pobranie wymaga konta: strona nie mówi **[brak]**; bezpośredni skrypt nie jest oczywisty (429 przy próbie curl) **[wniosek: pobrać ręcznie]**. | 120+ klipów: lokomocja w 8 kierunkach, jog, sprint, push, crawl, swim, sit, death, walka/broń, emotki **[pierwotne]**. Nazw klipów (czy jest „walk”, „idle”) strona nie podaje **[brak]**. UAL 2 ma wersję Standard (~70% darmowe) i rig dopasowany do UBC **[wtórne: wyniki wyszukiwania; pierwotne: quaternius.itch.io/universal-animation-library-2]**. Płatny Pro/Source to wydatek: tylko po zgodzie człowieka. |
| **Bandai Namco Research Motion Dataset** | **CC BY-NC 4.0** (Dataset-1 i 2), skrypt Blendera MIT; „© 2022 Bandai Namco Research Inc.” **[pierwotne: github.com/BandaiNamcoResearchInc/Bandai-Namco-Research-Motiondataset/blob/master/README.md]**; część źródeł podaje BY-NC-ND **[wtórne: automaton-media.com]**. | n/d | **Odpada** (komercyjne wydanie). |
| **Mixamo (animacje)** | jak w 1.1 | konto Adobe | odpada przez konto. |
| Inne (HumanML3D/AMASS, Rokoko, Truebones) | **[brak: nie badane]**; AMASS i dane SMPL mają znane licencje niekomercyjne **[wniosek, bez źródła w tym badaniu]**. | | pomijam. |

### 1.3 Retargeting w Blenderze 5.x

- **Wbudowanego retargetingu w Blenderze 5.x nie znalazłem** **[brak]**; standard to import BVH/FBX + constraints/„Copy Transforms”, bake.
- **Retarget** (KBS-DEV, fork Expy Kit + Animaide): darmowe, „GNU General Public License v3.0 or later”, „Blender 5.0 and newer”, presety Mixamo/Rigify/Unreal, „Import Fbx” (BVH nie wymieniony) **[pierwotne: extensions.blender.org/add-ons/retarget/]**. Dodatek jest GPL, ale **wyniki** (animacje, sprite'y) nie dziedziczą GPL **[wniosek]**.
- **Expy Kit** (pKrime): darmowy z płatnym premium **[wtórne: ballsandninjas.gumroad.com/l/xotibs]**; licencji repo nie sprawdziłem **[brak]**.
- **Bone Animation Copy Tool** (maylog), Blender ≥ 4.2 **[wtórne: wyniki wyszukiwania z extensions.blender.org/add-ons/bone-animation-copy-tool/]**.
- **Auto-Rig Pro**: płatny **[wtórne]**, nie bierzemy.
- **Najtańsza droga dla nas [wniosek]:** nie retargetować wcale. (a) MPFB z rigiem **CMU MB** + BVH CMU **[pierwotne: doc rigów MPFB, cytat wyżej]**; (b) Quaternius UBC + UAL na jednym rigu **[pierwotne: strona UBC „Compatible with the Universal Animation Library”]**. Retargeting (dodatek Retarget) potrzebny dopiero przy mieszaniu źródeł.
- **Rigify w MPFB**: generowany z metarig dwuetapowo **[wtórne: wyniki wyszukiwania z static.makehumancommunity.org/mpfb/docs/rigging_posing/rigify.html]**; do spaceru niepotrzebny.

### 1.4 Auto-rig i AccuRIG

AccuRIG (Reallusion): pracownik Reallusion pisze, że oprogramowanie można używać do projektów komercyjnych, a licencja zależy od pochodzenia postaci; własna postać = bez ograniczeń **[wtórne: forum.reallusion.com/Topic551972.aspx; discussions.reallusion.com/t/question-about-accurig-2s-eula/15034]**. Czy pobranie wymaga konta: **[brak]**. Nie potrzebne: MPFB i Quaternius są już zrigowane.

## 2. Render 3D → pixel art w Blenderze

### 2.1 Co mówią źródła

- **Dead Cells** (Motion Twin, Thomas Vasseur): model i szkielet w 3ds Max z arkusza pixel art, eksport FBX; „The 3D modeling is very basic”, sprite w grze ma ok. 50 px; własne narzędzie „renders the mesh in a very small size and without antialiasing”; każda klatka jako PNG + normal map, „a basic toon shader”; migotanie pikseli **nierozwiązane** („we could clean that by hand… but the point of this workflow is to go fast”); animacje kluczowane jak 2D, interpolacja dodawana potem **[pierwotne: gamedeveloper.com/production/art-design-deep-dive-using-a-3d-pipeline-for-2d-animation-in-i-dead-cells-i- (Gama Archive, 01.2018)]**. Motywacja: „a pipeline that could give us great looking pixel art, without having to hand draw each and every retake” **[wtórne: wyszukiwarka cytująca ten artykuł]**.
- **Blender, EEVEE, ustawienia** (BlenderNPR): niska rozdzielczość wyjścia (przykład 96×96), próbki = 1 („crispy aliased pixels”), View Transform = **Standard**, bloom off, materiały z ręcznie wybranych RGB zamiast BSDF; Freestyle łatwiejszy w niskiej rozdzielczości **[wtórne: bnpr.gitbook.io/bnpr/pixel-art/pixel-art-basics]**.
- **Shader to RGB**: węzeł tylko EEVEE; „evaluates the lighting of the BSDFs connected to it similarly to a Blended material”, psuje spójność z efektami PBR (AO, SSR) **[wtórne: wyniki wyszukiwania z docs.blender.org/manual/…/eevee/limitations/nodes_support.html; sama strona manuala dla 5.x niedostępna w moim odczycie: **[brak: pełny cytat]**]**. Typowe użycie: Color Ramp (stała interpolacja) na Diffuse → toon **[wtórne: blog.gskinner.com/archives/2020/05/shader-rgb-node.html; studio.blender.org/blog/3d-pixel-art-in-blender]**.
- **Kompozytor Pixelate ma antyaliasing**, co rozmywa piksele („developers plan to add an option to disable it”) **[wtórne: studio.blender.org/blog/3d-pixel-art-in-blender]**: renderować od razu w rozdzielczości docelowej, nie skalować.
- **Kontur**: Freestyle jest w Blenderze dostępny dla EEVEE/Cycles/Workbench **[pierwotne: docs.blender.org/manual/en/latest/render/freestyle/introduction.html (nagłówki silników)]**; kontur 1 px z detekcji krawędzi po głębi i normalnych (kernel tylko 4 sąsiadów, by linia miała 1 px), działa najlepiej na low-poly z wyraźnymi krawędziami **[wtórne: davidholland.netlify.app/articles/3d-pixel-art-rendering]**. Alternatywa: inverted hull (powłoka z odwróconymi normalnymi) i Grease Pencil Line Art **[wniosek, bez testu]**.
- **Kamera przyklejona do siatki pikseli**: dla animowanych sprite'ów (kamera statyczna) problem nie występuje; w grze 3D snap kamery do teksela + przesunięcie obrazu o błąd snapu usuwa „pixel creep” **[wtórne: davidholland.netlify.app/articles/3d-pixel-art-rendering]**. Dla naszych sprite'ów 2D wystarczy ortho, stała kamera, **stopy ustalone na stałym wierszu kadru** i render w 80×80 (jak teraz) **[wniosek]**.
- **Normal mapy dla światła 2D**: Dead Cells eksportuje PNG + normal map **[pierwotne: gamedeveloper.com, wyżej]**; Godot Pixel Renderer (MIT) eksportuje normal i specular map, kwantyzację 2–32 stopni, paletę 8 kolorów, kontur Sobela, Godot 4.4+ (main 4.6) **[pierwotne: github.com/bukkbeek/GodotPixelRenderer]**. Normal mapa z EEVEE (pass Normal w kompozytorze) jest zrobienia skryptem **[wniosek]**; nasz Poligon ma światło z game1 (ticket 07), więc normal mapa to opcja na później.
- **Gotowe dodatki Blendera**: Sprite Sheet Generator (GPL-3.0, Blender ≥ 4.2/3.6 — niespójnie) **[wtórne: extensions.blender.org/add-ons/sprite-sheet-generator/]**; Sprite Sheet Maker (Blender ≥ 5.1; licencja pusta) **[wtórne]**; Pixel Art Rendering (Lucas Roedel) i mod Tramshy (GPL-3.0, zalecany Blender 4.1) **[wtórne: awesome.ecosyste.ms/projects/github.com%2Ftramshy%2Fpixel-art-addon-mod]**; Pixel Kit i True Pixel Art Generator na Superhive (GPL, płatne) **[wtórne]**. **Nazw „Pixelator” i „SpriteGen” jako dodatków nie znalazłem [brak]**. Wniosek: własny skrypt (`bpy`, ~100 linii) daje większą kontrolę niż dodatek; wzorem mogą być ich shadery.
- **t3ssel8r**: jego materiałów (filmy) nie mogłem zweryfikować; znane tylko z cytowań (inspiracja dla kontur-shaderów depth+normal) **[wtórne: wyszukiwanie; pierwotne: brak]**.

### 2.2 Co działa przy 72 px, czego unikać [wniosek, oparty na źródłach powyżej i na logach z ticketu 12]

- Model **uproszczony**, silne bryły, kontur 1 px, 3–4 stopnie cienia na materiał; detale (zmarszczki, guziki) tylko z tekstury o niskiej częstotliwości. Dead Cells potwierdza: przy ~50 px model „very basic”.
- **Migotanie**: kluczowe są stałe kolory stref i palety zamiast tekstury o wysokiej częstotliwości; tekstura malarska przejdzie przez pikselizację jako szum klatka do klatki (to samo ryzyko, które Dead Cells uznał za cenę). Remedium: posteryzacja koloru w shaderze *przed* próbkowaniem, albo kwantyzacja do palety sprite'a (unfake `-c 24` mamy w narzędziach).
- **„Wygląd renderu”** (gładkie gradienty, miękkie cienie, specular) zabija malarskość: Principled BSDF wyłączyć; światło dla stylu robi Godot (ticket 07), render ma dawać **kolor własny** (albedo) i 2–3 stopnie, bez własnych cieni na ziemi.
- Rotacje kierunku: 3 kierunki + lustro to w 3D trywialne (obrót modelu), ale asymetria (kieszeń po jednej stronie) przy lustrze psuje; model symetryczny albo lustro tylko tam, gdzie można.
- Przy 72 px **głowa ma 10 px** (ticket 09): twarz musi być z tekstury kolorowanej ręcznie/projekcją; 3D nie da twarzy w pikselach.

## 3. Stylizacja i teksturowanie, by pasowało do konceptu

- **Projekcja konceptu na model**: Blender ma „Project from View” (UV) i malowanie projekcyjne z widoku; dla najlepszych wyników z ortho, bo minimalizuje zniekształcenia **[wtórne: bootcamp.uxdesign.cc …watercolor-painting…; yelzkizi.org; docs.blender.org/manual/…/texture_paint]**; operator `bpy.ops.uv.project_from_view` istnieje w API **[pierwotne: docs.blender.org/api/current/bpy.ops.uv.html]**. Ubrany model MPFB ma przód/bok/tył do dopasowania do naszych widoków konceptu (ticket 12: widoki C). **[wniosek]:** projekcja z jednego widoku daje rozmycie na przeciwnych ścianach; dla stałego rzutu 0,60 i 3 kierunków wystarczy projekcja osobno na przód/bok/tył (przełączane materiały) albo z dwóch widoków z maską kąta.
- **StableProjectorz**: „A free tool for making 3D and textures via StableDiffusion”; licencja **AGPL-3.0** (narzędzie; wyniki nie podlegają AGPL **[wniosek]**) **[pierwotne: github.com/IgorAherne/StableProjectorz, API GitHub]**. Gada z A1111/Forge przez JSON **[pierwotne: README]**, czyli **nie z ComfyUI wprost**; to dodatkowy stos poza tym, co mamy **[wniosek]**. Wymagania VRAM: **[brak]**. Nie na pierwszy test.
- **Ręcznie malowane tekstury**: człowiek nie maluje pikseli (zasada mapy). Skryptowa alternatywa: kolorowe strefy (kurtka/spodnie/buty/skóra) w materiałach MPFB (już mamy, `shots/mpfb_060`).
- **AI image-to-3D z konceptu**:

| Model | Licencja | VRAM | Ocena |
|---|---|---|---|
| TRELLIS (v1) | „TRELLIS models and the majority of the code are licensed under the MIT License”; submoduły mają własne licencje **[pierwotne: github.com/microsoft/TRELLIS README]** | „at least 16GB” **[pierwotne]**; port „8GB” istnieje (jaruizramon/LocalModelGen) **[wtórne: wyszukiwanie GitHub; jakość/licencja **[brak]**]** | licencja OK, 8 GB wątpliwe |
| TRELLIS.2 (4B) | MIT **[pierwotne: github.com/microsoft/TRELLIS.2]** | „at least 24GB… verified on A100 and H100”, testowane na Linuksie **[pierwotne]**; blogi o 6,5 GB w trybie low-VRAM 512³ są niespójne **[wtórne: trellis2.app, wątpliwa wiarygodność]**; Comfy ma natywny workflow z int8 **[pierwotne: docs.comfy.org/tutorials/3d/trellis2.md; VRAM nie podany]** | niepewne na 8 GB |
| TripoSR | MIT **[pierwotne: github.com/VAST-AI-Research/TripoSR]** | „about 6GB VRAM” **[pierwotne]** | mieści się; jakość niska, brak rigowalnej topologii **[wniosek]** |
| SF3D / SPAR3D | Stability AI Community License: komercyjnie dla < $1 mln rocznego przychodu **[wtórne: stability.ai/license, wyszukiwarka]**; model za bramką zgody na HF | ok. 7 GB (wtórne) **[brak: oficjalna specyfikacja]** | licencja warunkowa; ryzyko po przekroczeniu progu |
| Hunyuan3D 2.0/2.1 | licencja wyłącza UE, UK, Koreę: „Territory… excluding the territory of the European Union, United Kingdom and South Korea” **[pierwotne: raw.githubusercontent.com/Tencent-Hunyuan/Hunyuan3D-2/main/LICENSE]** | n/d | **odpada** |

  **[wniosek]:** modele image-to-3D dają bryłę z teksturą wypaloną w siatkę nie przystosowaną do rigowania (bez topologii pod zgięcia, bez szkieletu); trzeba by retopologii i auto-rigu, co mnoży pracę ponad MPFB. Przewaga: sylwetka dokładnie z konceptu. Dla postaci 72 px nieopłacalne.
- **Realność łańcucha „koncept → MPFB (+proxy ubrań) → tekstura z konceptu → rig CMU MB → mocap → render 72 px”**: wszystkie ogniwa mają źródło CC0/MIT/GPL-dodatek i są sterowalne z `bpy` **[wniosek]**; w repo już działają: MPFB z mężczyzną 1,8 m, render przód/bok/tył, chód procedularny, szkielet z BVH CMU (ticket 12). **Brakuje:** (1) rig CMU MB + podpięcie BVH w `bpy` (nasz `szkielet_chodu.py` używa BVH do kierunków kości na szkielecie Pixellab, nie do deformacji siatki), (2) ubranie (kurtka) jako geometria/proxy, (3) shader toon + kontur + paleta, (4) projekcja konceptu. Praca człowieka: ocena wyników w Poligonie i wybór (3 opcje na widok wg pamięci projektu); malowania i rigowania ręcznego brak **[wniosek]**.

## 4. Hybrydy: ruch z 3D + stylizacja AI

- Próby w ticket 12 pokazały: Qwen na klatkach manekina „wkleja gołą nogę”, ocena człowieka „dramat”, stylizacja ubranej bryły MPFB w ComfyUI porzucona **[log: ticket 12, sesja 2]**; osobny research 71 rozważał Wan VACE/Fun Control (poza + referencja) jako ciężki i nieudowodniony na 8 GB **[wniosek z research 71]**.
- Pixellab `animate-with-skeleton-v3` z keypointami z Blendera (szkielet z BVH CMU już wyeksportowany) pozostaje otwartą opcją **[log: ticket 12, sesja 3; research 71]**; wymaga zgody i kosztu generacji.
- **Ryzyko spójności** [wniosek]: stylizacja AI per klatka = migotanie palety/szczegółu, różna linia konturu, dryf proporcji (to był problem 1. próby); stylizacja AI na **teksturze** (raz) + render 3D wszystkich klatek zachowuje spójność klatek z konstrukcji. Dlatego rekomenduję AI **przed** renderem (tekstura/koncept), nie **po** nim (klatki).

## 5. Tabela opcji

Skala: ++ bardzo dobre, + dobre, 0 średnie, − słabe. Oceny jakości to **[wniosek]** do zweryfikowania testem.

| Opcja | Jakość przy 72 px | Spójność klatek | Praca / koszt | Sterowalność skryptem | Licencja |
|---|---|---|---|---|---|
| A. MPFB + rig CMU MB + BVH CMU + projekcja konceptu + render toon | + (zależy od tekstury i konturu) | ++ (3D) | niska: 0 zł, praca Claude na skryptach; człowiek ocenia | ++ (`bpy`, headless) | CC0 (MPFB), „free for commercial” (CMU), GPL tylko dla dodatku |
| B. Quaternius UBC + UAL (Standard/Pro) + render toon | 0/+ (stylizacja niskopoligonowa, inne proporcje) | ++ | najniższa dla ruchu (jeden rig, brak retargetu); Pro $9,99 po zgodzie | ++ | CC0 |
| C. Hybryda: render 3D → Pixellab/Qwen per klatka | 0/+ (styl AI) | − (migotanie) | koszt generacji Pixellab; poprzednie próby „dramat” | + | zależy od narzędzia; Pixellab wg ticketów 17/18 |
| D. AI image-to-3D (TRELLIS.2/TripoSR) + auto-rig | 0 (topologia, rig) | + | wysoka (retopologia, rig, instalacje), VRAM 24 GB dla TRELLIS.2 | + | MIT, ale Hunyuan odpada |
| E. Mixamo (rig + animacje) | + (ruch dobry) | ++ | wymaga konta Adobe ID; serwis niestabilny | − (brak API) | Adobe, ok. do gry; odpada przez konto |
| F. Godot Pixel Renderer (MIT) zamiast Blendera | + | ++ | pobranie repo; render w Godot z GLB | + | MIT |
| G. Cut-out 2D w Godot (z research 71) | 0 (kukiełka przy widocznych nogach) | ++ | 0 zł | ++ | n/d |

## 6. Niepewności techniczne do sprawdzenia na teście

- Czy model MPFB (ubrany w kurtkę z proxy lub mesh z Quaternius „Modular Outfits”) czyta się przy 72 px jako dorosły, 6–7 głów, a nie „manekin”.
- Czy projekcja konceptu daje czytelną twarz (10 px głowy) i jednolite plamy bez migotania po pikselizacji.
- Czy kontur 1 px z Freestyle/inverted hull trzyma styl NORCO/REPLACED (kontur kolorowy zamiast czarnego?).
- Czy chód CMU (02_01, 07_01, 35_01) przy rigu CMU MB w MPFB nie wymaga korekty kierunków kości (T-poza vs A-poza MPFB); w `szkielet_chodu.py` już obchodzimy to „kierunkami kości na długościach kości MPFB”.

## 7. Rekomendacja: dwa szybkie testy w style-lab

**Test A (główny, 0 zł): MPFB + CMU + render toon w 72 px.**
- Baza: już zainstalowane MPFB2 (CC0 assety) w Blenderze 5.2.
- Rig: dodać rig **CMU MB** w `tools/blender/postac_mpfb.py` (nowy skrypt np. `postac_cmu.py`), zaimportować BVH `style-lab/tools/mocap/cmu/` (02_01, 07_01, 35_01) i zbake'ować na rigu (constraints lub retarget dodatkiem Retarget, GPL-3.0+, Blender ≥ 5.0, extensions.blender.org/add-ons/retarget/).
- Render: EEVEE, ortho, 1 próbka, Standard, 80×80 → przycięcie do 72 px (jak `crop_ref.gd`), Shader-to-RGB + Color Ramp (3 stopnie), kontur Freestyle 1 px, kolorowe strefy materiałów z `shots/mpfb_060`, następnie projekcja konceptu `proby/koncept9/edit_kurtka_s9000.png` na boku.
- Kryterium: 8 klatek chodu bok (+ lustro) w Poligonie F1 obok chodu Pixellab C; ocena człowieka.

**Test B (kalibracja pipeline'u renderu i jakości ruchu): Quaternius UBC + UAL Standard.**
- Pliki (CC0, pobranie ręczne z przeglądarki, bez konta wg strony; potwierdzić na stronie): UBC Standard z `https://quaternius.com/packs/universalbasecharacters.html` (link „Download here”/Itch.io), UAL Standard (15 MB, 45 klipów, FBX/glTF) z `https://quaternius.itch.io/universal-animation-library`. Licencja na obu stronach: „Free to use in personal, educational and commercial projects. (CC0 License)”.
- Ten sam skrypt renderu co w teście A, żeby porównać „model + ruch” przy tym samym shaderze. Przy dobrym rezultacie ruchu rozważyć (za zgodą) Pro $9,99 dla pełnej biblioteki 120+ klipów.
- Uwaga: UBC to stylizacja, więc test oceni głównie ruch i render, nie proporcje.

**Opcjonalnie F:** Godot Pixel Renderer (MIT) `https://github.com/bukkbeek/GodotPixelRenderer` (Godot 4.4+/4.6; nasz Godot 4.7.2 **[brak: kompatybilność niesprawdzona]**), jeśli renderowanie w Godot da lepszy kontur/normal mapy niż Blender.

## 8. Lista niepotwierdzonych

- Oficjalny tekst FAQ/ToU Mixamo (helpx.adobe.com zwraca 403), a także czy pobrane pliki Mixamo pozostają używalne bezterminowo; nie badane głębiej, bo konto odpada.
- Oryginalny tekst licencji na mocap.cs.cmu.edu (błąd certyfikatu); mamy cytat z READMEFIRST Hahne i mirror.
- Nazwy klipów w UAL Standard (czy jest „walk”/„idle”) oraz które modele UBC są w wersji Standard; bezpośrednie URL-e plików; czy pobranie z itch.io działa bez konta.
- Licencje pojedynczych paczek ubrań MPFB/MakeHuman (każda może mieć własną).
- VRAM i jakość TRELLIS v1/TRELLIS.2 na 8 GB (źródła pierwotne podają 16/24 GB; blogi niespójne); licencja i VRAM SF3D z drugiej ręki.
- Licencja Expy Kit (repo pKrime); wymagania StableProjectorz; czy ma sens z ComfyUI.
- Dokładny tekst manuala Blendera 5.x o Shader to RGB (strona zwróciła 404/uciętą treść) i zachowanie w EEVEE „Next” przy 1 próbce.
- Materiały t3ssel8r (tylko cytowania), „Pixelator”/„SpriteGen” jako dodatki (nie znalezione).
- Czy kontur Freestyle w 80×80 daje linię 1 px bez artefaktów (wymaga testu).
- Ocena jakości wizualnej całej drogi przy 72 px: to hipoteza do testu A/B, nie fakt.
