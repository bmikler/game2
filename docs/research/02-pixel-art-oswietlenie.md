> Kopia z game1 (`repo/game1/docs/research/02-pixel-art-oswietlenie.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Pixel art z dynamicznym oświetleniem: techniki, trudność, wymagania wobec assetów (Godot 4)

Ticket: `docs/wayfinder/tickets/02-pixel-art-oswietlenie.md`. Dokumentacja Godota cytowana w wersji „stable" (4.7 w dniu researchu).

## Zastrzeżenia co do źródeł

- Dokumentacja Godota: źródło pierwotne, zweryfikowane (strony pobrane i streszczone).
- **Octopath Traveler / HD-2D:** nie udało się otworzyć wywiadu deweloperskiego Epic/Unreal (wymaga logowania). Z wyszukiwania wynika tylko, że Square Enix i Acquire opisują HD-2D jako sprite'y 2D w środowisku 3D z dynamicznym oświetleniem, głębią ostrości i tilt-shift, na Unreal Engine 4 (zob. [Wikipedia HD-2D](https://en.wikipedia.org/wiki/HD-2D), źródło wtórne; wywiad pierwotny: [Unreal Engine, Octopath Traveler II](https://www.unrealengine.com/developer-interviews/octopath-traveler-ii-builds-a-bigger-bolder-world-in-its-stunning-hd-2d-style), niezweryfikowany treściowo). Techniczne szczegóły implementacji traktuj jako niepotwierdzone.
- **Replaced (Sad Cat Studios):** wywiad [GamingBolt](https://gamingbolt.com/replaced-interview-inspirations-for-art-style-ranged-and-melee-combat-exploration-and-more) mówi tylko, że studio eksperymentowało z „2.5D pixel-art" i inspirowało się Limbo, Inside, Deadlight; według relacji [GCORES](https://www.gcores.com/articles/213576) pixel art jest rysowany ręcznie, animacja klatka po klatce. Metody oświetlenia nie znaleziono w źródłach pierwotnych (możliwy trop: podcast Game Maker's Notebook z reżyserem i kompozytorem).
- **Soulbound:** nie znaleziono wiarygodnego źródła o jego technice oświetlenia. Pominięty jako referencja techniczna.
- **Disco Elysium i Fahrenheit** to nie pixel art (malarskie 3D / klasyczne 3D); są referencją nastroju (paleta, światło, mgła), nie techniki.

## Kontekst projektu

Solo dev bez doświadczenia, 5–10 h/tydz., Godot 4 (wg map.md silnik wybierany osobnym ticketem), PC, widok jeszcze nie rozstrzygnięty. Zima i noc, nastrój nordic-noir.

## Techniki

### 1. Światła 2D + normal mapy (natywne w Godocie)

Co Godot daje ([2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)):
- `CanvasModulate` ustawia ciemne światło otoczenia (noc), `PointLight2D` (lampa, latarka, okno), `DirectionalLight2D` (księżyc), `LightOccluder2D` (cienie, można generować z Sprite2D).
- Tryby światła: Add, Subtract, Mix. Cienie z filtrem PCF5/PCF13 (PCF13 najdroższy).
- Normal i specular mapy przez zasób `CanvasTexture`; po włączeniu normal map zwykle trzeba podnieść `Height` światła.
- Światła addytywne (sprite'y) jako tania alternatywa dla krótkich efektów (bez cieni i normal map).
- Wszystkie trzy renderery obsługują 2D ([renderers](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html)).

Ograniczenia (z dokumentacji):
- Oświetlenie liczone jest w rozdzielczości viewportu, więc samo filtrowanie Nearest nie daje „spikselowanego" światła; potrzebny własny shader snapujący do siatki albo renderowanie sceny w niskiej rozdzielczości.
- Cienie kierunkowe są zawsze nieskończenie długie (obejście: shader z SDF).
- Tło musi być węzłem widzialnym (np. Sprite2D), żeby dostawało światło.

Trudność dla początkującego: **niska-średnia**. Działa od ręki, dużo samouczków. Pułapka: rozmyte, gładkie światło na pixel arcie wygląda „nie pixel-artowo", trzeba je świadomie stylizować (niska rozdzielczość viewportu, kwantyzacja/posteryzacja w shaderze).

Wymagania assetów: sprite'y + **normal mapy** (każdy sprite i tło potrzebuje wariantu normalnego, ręcznie lub generowanego; tooling to temat ticketu o pipeline'ie assetów). Bez normal map światła nadal działają, ale płasko (jak kolorowy filtr z cieniami od okluderów). Okludery wymagają dopasowanych poligonów na ścianach.

### 2. HD-2D: sprite'y 2D w scenie 3D

Idea: środowisko 3D (mesh lub kafelki 3D, tu można użyć `Sprite3D`), postacie jako billboardowe sprite'y, prawdziwe światła 3D (omni, spot, kierunkowe) z cieniami, do tego głębia ostrości, bloom, tilt-shift. Tak opisywany jest styl Octopath Traveler (źródła wyżej, wtórne).

W Godocie 4:
- Prawdziwe światła 3D, cienie, `WorldEnvironment` (glow, mgła, tonemapping, ekspozycja), DOF w `CameraAttributes`. Ważne: Forward+ ma pełną obsługę świateł i efektów ([renderers](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html)); Compatibility ma m.in. limit 8 świateł omni/spot na mesh.
- `Sprite3D` wyświetla teksturę 2D w świecie 3D, obsługuje sprite sheety (`hframes`, `vframes`) ([Sprite3D](https://docs.godotengine.org/en/stable/classes/class_sprite3d.html)). Szczegółów billboard / shaded / filtrowanie nie zweryfikowano (leżą w SpriteBase3D).
- Tilt-shift nie jest gotowym efektem; wymaga własnego shadera post-process ([advanced post-processing](https://docs.godotengine.org/en/stable/tutorials/shaders/advanced_postprocessing.html): pełnoekranowy quad z dostępem do depth buffera).

Trudność: **wysoka** dla początkującego (kamera 3D, modelowanie lub budowanie scen z brył, materiały, cienie, shadery). Zysk: najbogatszy efekt wizualny: realne cienie, mgła, dynamiczne światła w przestrzeni, parallax za darmo.

Wymagania assetów: sprite'y postaci (2D) + modele/kafle 3D otoczenia albo tła rysowane jako płaszczyzny w głębi (tańsze: „pudełko" z warstw sprite'ów). Normal mapy sprite'ów są opcjonalne. Dla widoku z góry/izometrycznego pasuje naturalnie; dla widoku bocznego jest przerostem formy.

### 3. 3D renderowane do niskiej rozdzielczości + pixel shader

Idea: cała scena 3D (lub jej część) renderowana do małego `SubViewport` / viewportu o niskiej rozdzielczości i powiększana filtrem Nearest, opcjonalnie z outline'em i kwantyzacją palety w shaderze.
- Godot: stretch mode `viewport` renderuje scenę w rozdzielczości bazowej i skaluje ([Multiple resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html)); `integer` scale mode (od 4.2) zapobiega nierównym pikselom; docs polecają 640x360 jako rozsądną bazę. `SubViewport` pozwala na własny rozmiar i stretch ([Viewports](https://docs.godotengine.org/en/stable/tutorials/rendering/viewports.html)).
- Zastrzeżenie z dokumentacji: tryb `viewport` jest gorszy, gdy sprite'y potrzebują ruchu subpikselowego; wtedy `canvas_items`.
- Ten sam mechanizm niskiej rozdzielczości rozwiązuje też problem „gładkiego" światła z techniki 1 (światła liczone są wtedy w niskiej rozdzielczości).

Trudność: **średnia-wysoka**. Sama pikselizacja jest prosta (ustawienia projektu); trudne jest wyglądać dobrze: modele 3D w niskiej rozdzielczości migoczą/„pływają" bez dopracowanego shadera, outline'ów i snapowania kamery do piksela.

Wymagania assetów: modele 3D (nie rysujesz pixel artu), tekstury niskorozdzielcze. Uwaga: gra „pixel artowa" w sensie rysowanych sprite'ów (jak Replaced) tego nie uzyskuje; to inny styl.

### 4. Światło wolumetryczne i mgła

- **Wolumetryczna mgła Godota** (oddziałuje ze światłami i cieniami, god rays): tylko 3D, **tylko Forward+** (nie Mobile ani Compatibility); ma ograniczony zasięg; kosztowna (ustawienia Volume Size/Depth); `FogVolume` dla lokalnych stref ([Volumetric fog](https://docs.godotengine.org/en/stable/tutorials/3d/volumetric_fog.html)). Dostępna więc w technikach 2 i 3, **nie w czystym 2D**.
- **Fałszywa mgła** quadami działa we wszystkich rendererach i jest tańsza, ale mniej realistyczna (ta sama strona).
- **W czystym 2D** mgła i promienie światła robi się ręcznie: półprzezroczyste sprite'y/gradienty, warstwy parallax, `PointLight2D` z teksturą stożka, tryb Add (docs: światła addytywne jako tani trik), shadery szumu na `ColorRect`. Wymaga to „oka", ale jest tanie i dobrze wygląda w pixel arcie.

Trudność: 2D-fake **niska-średnia**; wolumetryka 3D **średnia** (suwaki, ale strojenie wydajności i migotania).

### 5. Śnieg i cząsteczki

- `GPUParticles2D` (zalecane domyślnie) lub `CPUParticles2D` (podobne możliwości, lepszy na słabych GPU lub przy GPU-bound) ([Particle systems 2D](https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html)). Strona nie opisuje wprost śniegu/deszczu; konfiguracja (emisja w prostokącie, prędkość, rozrzut) to standardowe ustawienia ParticleProcessMaterial.
- W 3D analogicznie `GPUParticles3D`.
- Śnieg wygląda dobrze, gdy cząsteczki są małymi kwadratami pikseli w 2–3 warstwach głębi (parallax), a przy aktywnych światłach 2D mogą być oświetlane.

Trudność: **niska**. Assety: 1–2 małe sprite'y (lub zwykły kwadrat 1–2 px).

### 6. Post-processing

- W 3D: `WorldEnvironment` (glow/bloom, tonemapping, korekcja kolorów, mgła, DOF) działa we wszystkich rendererach (glow: tak) ([renderers](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html)). Własne efekty przez pełnoekranowy quad ze shaderem ([advanced post-processing](https://docs.godotengine.org/en/stable/tutorials/shaders/advanced_postprocessing.html)).
- W 2D: własne shadery na pełnoekranowym `ColorRect` w `CanvasLayer` (czytanie ekranu przez `hint_screen_texture`); `CanvasLayer` sam w sobie to tylko warstwa rysowania ([Canvas layers](https://docs.godotengine.org/en/stable/tutorials/2d/canvas_layers.html)). Dokładnego opisu tego wzorca w pobranych stronach nie znaleziono; weryfikować w tutorialu „Custom post-processing".
- Typowy zestaw dla klimatu: winieta, ziarno, lekka aberracja chromatyczna, korekcja kolorów (zimna paleta z ciepłymi plamami światła), kwantyzacja palety, bloom na źródłach światła.

Trudność: **niska-średnia** (gotowe shadery są powszechne; pisanie własnych wymaga nauki GLSL-podobnego języka Godota).

## Porównanie

| Technika | Trudność (początkujący) | Co wymaga od assetów | Renderer | Klimat / ryzyko |
|---|---|---|---|---|
| 1. Światła 2D + normal mapy | niska-średnia | sprite'y + normal mapy, okludery | wszystkie | dobre, spójne z ręcznym pixel artem; światło trzeba stylizować |
| 2. HD-2D (sprite'y w 3D) | wysoka | sprite'y + modele/kafle 3D otoczenia | Forward+ dla pełni efektów | najbogatsze; największy koszt pracy, dwa warsztaty (2D i 3D) |
| 3. 3D w niskiej rozdzielczości | średnia-wysoka | modele 3D, nie rysowane sprite'y | wszystkie | inny styl niż „rysowany pixel art"; ryzyko migotania |
| 4. Wolumetryka / mgła | 2D-fake: niska-średnia; 3D: średnia | sprite'y mgły, gradienty lub nic | wolumetryka tylko Forward+ | duży wpływ na nastrój przy małym koszcie, jeśli fake |
| 5. Śnieg (cząsteczki) | niska | 1–2 małe sprite'y | wszystkie | niski koszt, wysoki efekt dla „zimy" |
| 6. Post-processing | niska-średnia | brak | wszystkie | spaja obraz; łatwo przesadzić |

Techniki 4–6 są dodatkami, które można łączyć z 1, 2 lub 3.

## Wnioski do decyzji

- Wybór między 1, 2 i 3 zależy od decyzji o **widoku** (ticket o widoku) i od **pipeline'u assetów** (czy normal mapy są realne do wytworzenia; ticket o AI/ręcznym pixel arcie). Ten research nie rozstrzyga tych kwestii.
- Technika 1 jest jedyną, która wymaga normal map dla pełnego efektu i jednocześnie nie wymaga umiejętności 3D.
- Ograniczenie „światło w rozdzielczości ekranu" z dokumentacji oznacza, że bez niskorozdzielczego viewportu lub własnego shadera światło 2D nie będzie wyglądać „pixel-artowo".
- Wolumetryka tylko w Forward+ oznacza wymóg nowszego GPU (Vulkan/D3D12/Metal) i brak wsparcia dla webu/starych kart; dla PC (Win/Mac/Linux) zwykle akceptowalne, ale warto świadomie zapisać.
- Luki: brak zweryfikowanych pierwotnych szczegółów implementacji Octopath/Replaced/Soulbound; warto w prototypie oświetlenia (wspomniany w map.md) sprawdzić technikę 1 z viewportem niskiej rozdzielczości oraz prosty wariant 2 na jednej scenie.

## Rekomendacja

Na start (decyzja należy do ticketu grilling z człowiekiem): najtańszy sensowny punkt wyjścia to **technika 1 (światła 2D + normal mapy) w niskorozdzielczym viewporcie (stretch `viewport`, scale `integer`, baza np. 640x360), plus śnieg cząsteczkami, fałszywa mgła/promienie sprite'ami i lekki post-processing** (winieta, ziarno, korekcja kolorów). Daje zimowy, nocny nastrój w stylu referencji przy najniższej barierze wejścia i jest zgodna z 5–10 h/tydz. HD-2D (technika 2) warto potraktować jako opcję „upgrade'u" lub osobny prototyp, jeśli widok okaże się izometryczny/z góry i pipeline assetów udźwignie modele 3D. Technika 3 pasuje tylko, jeśli gra miałaby być w całości 3D, co zmienia charakter projektu. Najpierw prototyp oświetlenia na jednej scenie, potem decyzja.
