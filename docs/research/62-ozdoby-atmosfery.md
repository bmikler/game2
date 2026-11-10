# Tanie ozdoby atmosfery w 2D (Godot 4): para, dym, wiatr, odblaski, TV, kurz, śnieg, ślady, latarnie

Ticket: `docs/wayfinder/tickets/03-ozdoby-atmosfery-research.md`. Data researchu: 2026-11-08. Nie powtarzam `22c-gra-swiatla.md` (smugi z okna, kurz w smudze `LIGHT_ONLY`, limity świateł 16/256) ani `31-swiatlo-wokol-gracza.md` (światło gracza w plenerze). Odwołuję się do nich tam, gdzie ozdoba dotyka światła.

Znaczniki: [zweryfikowane] = w dokumentacji Godota (docs.godotengine.org/en/stable, odczyt 2026-11-08) lub w kodzie/stronie autora; [wtórne] = opis dewlogu/wyszukiwarki, nie sprawdzony w pełnym źródle; [niezweryfikowane] = nie znalazłem źródła; [wniosek] = moja rekomendacja.

## Uczciwe zastrzeżenie o źródłach

Twórcy gier (Eastward, Hyper Light Drifter, Octopath itd.) niemal nie opisują publicznie tanich ozdób atmosfery. Wywiad z Pixpil w Game Developer (Road to the IGF) nie zawiera nic o oświetleniu, pogodzie ani cząsteczkach [zweryfikowane: odczyt strony]. Przykłady „z gry" poniżej to dlatego **obserwacje tego, co widać w grach**, oznaczone [niezweryfikowane] jako technika danej gry, albo dewlogi małych twórców. Techniki silnikowe są natomiast w pełni potwierdzone dokumentacją.

## 1. Fakty z Godota 4 potrzebne do wszystkiego poniżej

- **GPUParticles2D** jest domyślnym wyborem; `CPUParticles2D` bywa lepsze na słabym sprzęcie lub gdy GPU jest wąskim gardłem, a jego funkcje są stopniowo wygaszane na rzecz GPU [zweryfikowane, Particle systems 2D].
- **`fixed_fps`** (GPU domyślnie 30) ogranicza częstotliwość renderu cząsteczek, nie symulacji; np. 2 daje „schodkowy" ruch. **`interpolate`** (domyślnie true) wygładza ruch przy niskim `fixed_fps`: dla pixel artu często trzeba je **wyłączyć**, żeby zachować stopniowany ruch [zweryfikowane: opis własności; wniosek co do wyłączenia = [wniosek]].
- **Tekstura cząsteczki:** brak tekstury = kwadraty 1x1 px (GPU) [zweryfikowane]. Cząsteczka 1x1 px lub 2x2 px w kolorze palety to najtańszy i najbardziej spójny z siatką pikseli kształt. `color_ramp` mnoży kolor tekstury [zweryfikowane].
- **Flipbook** (smuga dymu z klatek): `CanvasItemMaterial` z `particles_animation = true`, `particles_anim_h_frames`, `v_frames`, `loop`; wymaga dodatniego `anim_speed_max` [zweryfikowane]. Czarne tło flipbooka: blend Add albo kanał alfa [zweryfikowane].
- **`light_mode` w `CanvasItemMaterial`:** Normal / Unshaded / **Light Only** [zweryfikowane]. Blend: Mix, Add, Sub, Mul, PremultAlpha [zweryfikowane].
- **Sprite'y addytywne** (materiał blend Add) renderują się szybciej niż światła, ale nie rzucają cieni, nie rozjaśniają całkiem ciemnych miejsc poprawnie i ignorują normal/specular innych sprite'ów [zweryfikowane, 2D lights and shadows]. Dla ozdób typu odblask, halo, smuga to wystarcza.
- `PointLight2D`: `blend_mode` Add/Sub/Mix, `range_item_cull_mask` filtruje, które obiekty światło oświetla; `energy`; większa tekstura/skala = więcej pikseli = większy koszt [zweryfikowane].
- `CanvasModulate` ustawia ambient całej sceny [zweryfikowane]; ozdoby `unshaded` (para, halo) ignorują go, więc nocą trzeba je ściemniać ręcznie (modulate z krzywej pory dnia) [wniosek].
- `hint_screen_texture` zastępuje `SCREEN_TEXTURE`; `TIME` zawija się po 3600 s [zweryfikowane].
- GPUParticles2D: `visibility_rect` trzeba powiększyć, inaczej cząsteczki znikają na krawędzi; `preprocess` bywa bardzo drogi; zmiana `amount` restartuje system (użyj `amount_ratio`, który jednak nie zmniejsza kosztu) [zweryfikowane]. W Godot 4.3 cząsteczki 2D nie wspierają physics interpolation; wyłączyć na węźle [zweryfikowane]. Ponieważ używamy 4.7, ten punkt do sprawdzenia w Poligonie [niezweryfikowane dla 4.7].
- Cząsteczki mogą kolidować z `LightOccluder2D`, nie z ciałami fizycznymi [zweryfikowane]. Ma to sens np. dla śniegu, który ma nie padać „do wnętrza" pod okapem [wniosek].

## 2. Ryzyko dla siatki pikseli: zasady ogólne [wniosek]

Siatkę łamią: obroty sprite'ów o kąty niebędące wielokrotnością 90 stopni, skalowanie niecałkowite, pozycje podpikselowe przy ruchu, filtr liniowy i ścinanie. Reguły dla wszystkich ozdób:

1. Cząsteczki: tekstury 1x1 – 3x3 px, `angle_*` i `angular_velocity` = 0 (obrót kwadratu 2x2 daje rozmyte krawędzie), `scale` stały lub całkowity, filtr Nearest.
2. Ruch szybki (śnieg, iskry) jest mało groźny; ruch wolny (para, dym) jest najgroźniejszy, bo pozycja podpikselowa zamienia się w migotanie. Rozwiązanie: niski `fixed_fps` (8–15) i `interpolate = off`, albo przyciąganie pozycji do siatki w shaderze.
3. Ustawienia projektu `rendering/2d/snap/snap_2d_transforms_to_pixel` i `snap_2d_vertices_to_pixel` [niezweryfikowane w tej sesji: strona ProjectSettings zbyt długa do odczytu; nazwy znane z Godota, opis do sprawdzenia w Poligonie]. Alternatywa: rendering do niskorozdzielczego `SubViewport` i skalowanie całkowite, wtedy wszystko jest z natury na siatce.
4. Shadery deformujące UV (wiatr, odbicie w szybie) muszą kwantyzować UV do teksela (patrz §3.3), inaczej tworzą „pół-piksele".

## 3. Katalog ozdób

Skróty: [A] = czy wymaga assetu z generatora; „Ryzyko siatki" patrz §2.

### 3.1 Para z ust na mrozie
- **Technika:** `GPUParticles2D` lub `CPUParticles2D` jako dziecko postaci, emisja impulsowa (`one_shot` wyzwalany z animacji albo timer oddechu co ok. 2–3 s przy chodzie/stój), 3–6 cząsteczek, lifetime 0,6–1 s, ruch w górę i lekko do przodu, `color_ramp` biały, alfa od 0,7 do 0. `local_coords = false`, żeby chmurka została za idącą postacią [zweryfikowane: opis własności].
- **Kierunek:** w widoku 3/4 emiter trzeba przesuwać względem kierunku patrzenia (4 lub 8 offsetów) [wniosek].
- **[A]:** nie. Wystarczy kwadrat 1–2 px lub 3 klatki chmurki w palecie. Generator niepotrzebny.
- **Aktywacja:** tylko gdy temperatura < 0 i postać na zewnątrz lub w nieogrzanym pokoju (parametr z Poligonu: przełącznik on/off).
- **Ryzyko siatki:** średnie (wolny ruch); `fixed_fps` 8–12, bez obrotu.
- **Przykład:** [niezweryfikowane] widoczne w wielu grach zimowych; nie znalazłem opisu techniki od twórców.

### 3.2 Dym z papierosa i komina
- **Komin:** `GPUParticles2D` ciągły, 6–12 cząsteczek, lifetime 3–5 s, lekki dryf poziomy zależny od wiatru (wspólny uniform), skala rośnie całkowicie w krokach (2 → 3 → 4 px zamiast płynnego `scale_curve`) lub flipbook 4–6 klatek [zweryfikowane: obsługa flipbooka]. Wspólny wiatr: ten sam wektor co w §3.3 [wniosek].
- **Papieros:** żarzące się 1 px jako sprite z krótką pętlą 2 klatek plus emiter 1–2 cząsteczek co sekundę; albo wprost klatki w animacji postaci (palenie to animacja, nie efekt) [wniosek].
- **[A]:** komin: opcjonalnie flipbook z generatora, ale 3 ręcznie sprawdzone kształty z koda wystarczą. Papieros: klatki w Przepisie postaci.
- **Ryzyko siatki:** wysokie przy płynnym skalowaniu; flipbook jest bezpieczniejszy niż skalowanie.
- **Światło:** komin w mieście nocą dostaje słabe ciepłe halo (sprite addytywny) tylko jeśli palenisko jest widoczne [wniosek].

### 3.3 Drzewa i krzewy na wietrze: shader czy klatki
- **Shader (zalecany dla koron i krzewów):** kwantyzacja UV do teksela + przesunięcie poziome rosnące z wysokością sprite'a. Gotowy wzorzec: shader „2D Pixel perfect wind & sway effect" autora kaeylos, **CC0**, Godot 4.x, wymaga `REGION_RECT` dodanego w 4.5; szum + sway od wysokości, `floor(local_uv * region_size_px) / region_size_px`, clamp do regionu atlasu, filtr Nearest [zweryfikowane: odczyt kodu i opisu strony godotshaders.com]. Działa na pojedynczym sprite'cie i na atlasie.
- **Klatki:** 2–4 klatki „kołysania" dla drzew pierwszego planu; wyższa kontrola nad kształtem, koszt = produkcja assetów (mnoży się przez liczbę gatunków) [wniosek].
- **Rekomendacja [wniosek]:** shader dla masy drzew i krzewów (zero dodatkowych assetów, jeden materiał), klatki tylko dla 1–2 „bohaterskich" drzew. Zimą liści brak, więc ruch dotyczy iglaków (igły) i śniegu zsypującego się z gałęzi; amplituda 1 px wystarcza. Przy iglakach z ciężkim śniegiem lepsze jest prawie-statyczne drzewo z rzadkim, losowym „strząśnięciem" (jednorazowy emiter śniegu) niż stałe kołysanie.
- **Wspólny uniform wiatru** (`global uniform` w shaderach, siła i kierunek) steruje drzewami, dymem, śniegiem i flagami naraz [wniosek]; nie `TIME` samo, bo `TIME` zawija się po 3600 s [zweryfikowane].
- **[A]:** nie.
- **Ryzyko siatki:** niskie przy kwantyzacji UV; wysokie przy ruchu wierzchołków (`vertex()` z obrotem lub ścinaniem bez kwantyzacji).

### 3.4 Odblaski i refleksy na szybach budynków z zewnątrz
- **Dzień:** sprite addytywny (Add) w kształcie skośnych pasów na szybie, przesuwany o 1 px wolno lub zmieniający alfa z czasem; maska = kształt okna z tej samej tekstury [wniosek].
- **Noc:** zamiast refleksu szyba świeci (ciepły prostokąt `unshaded`) albo jest ciemna z lekkim chłodnym gradientem nieba; odbicie latarni jako 1–2 piksele jasnego koloru [wniosek].
- **Szkło z „widokiem":** statyczne odbicie nieba jako gradient paletowy 2–3 odcienie, zależny od pory dnia (modulate z krzywej) [wniosek].
- **[A]:** nie wymaga; pasy są prostym sprite'em kodem. Ewentualnie okna jako osobne warstwy w Przepisie fasad (wspólne z biletem 35b/53).
- **Ryzyko siatki:** pasy ukośne rysowane po pikselach są bezpieczne; przesuwanie o ułamek piksela nie.
- **Kolizja z istniejącą pracą:** okna w wierzchu ściany i światło okien: `35b`, `47`, `53`.

### 3.5 Telewizor nocą oświetlający pokój (wiele ekranów, światło zależne od obrazu)
- **Warstwy [wniosek, zgodne z opisem wtórnym poniżej]:** (1) ekran jako sprite `unshaded` z animacją 2–4 klatek lub shaderem szumu; (2) `PointLight2D` w chłodnym niebieskawym kolorze z teksturą miękkiego stożka przed ekranem; (3) opcjonalnie słabe, niecieniujące światło przed telewizorem jako „odbite"; (4) sprite addytywny halo przed ekranem.
- **Światło zależne od obrazu:** próbkowanie koloru z tekstury ekranu (viewport/klatka) zmniejszonej do ok. 8x8 px i uśrednionej w jeden kolor światła. Znalazłem opis tego podejścia w wynikach wyszukiwania (dewlog małego twórcy, Unity: cieniowane światło z kolorem uśrednionym z ekranu + niecieniowane „odbite" + radialny sprite jako blask) [wtórne: z fragmentu wyszukiwarki, źródło nie otwarte w całości, nie przypisuję go konkretnej grze]. Wiarygodny dewlog z innej gry (Bloodlust: Santa Monica, Emanuel Montero) potwierdza tylko, że „TV i lodówka dodają własne migoczące światła" w dynamicznym oświetleniu [zweryfikowane: odczyt strony]; nie opisuje metody.
- **Tania wersja [wniosek]:** zamiast próbkowania viewportu, tablica 4–8 kolorów „kanałów" (zimny niebieski, biały, zielonkawy, ciepły) przełączana losowo co 0,3–2 s z płynnym przejściem energii; wygląda jak zmieniający się obraz i kosztuje jeden `Tween`. Prawdziwe próbkowanie opłaca się tylko, gdy ekran pokazuje sensowną treść (np. scena z fabuły).
- **Wiele ekranów:** osobny `PointLight2D` na ekran liczy się do limitu 16 świateł na canvas item i 256 na render (patrz `22c`). W pokoju z wieloma telewizorami: jedno wspólne światło o większym zasięgu plus sprite'y halo przy każdym ekranie (halo nie liczy się do limitu świateł) [wniosek; limity z `22c`].
- **Poprawka niepewna:** „kolor TV niebieski" to konwencja filmowa [wniosek], nie reguła; paleta pokoju decyduje.
- **[A]:** nie. Klatki ekranu 2–4 szt. rysowane kodem (pasy szumu, linia skanowania). Opcjonalnie generator dla treści ekranu, jeśli ma być czytelny obraz.
- **Ryzyko siatki:** niskie (światło jest miękkie z założenia; nie mieszać tekstury światła z ostrą krawędzią pikseli).
- **Cień:** `shadow_enabled` na świetle TV tylko jeśli koszt ok; filtr None jest najtańszy [zweryfikowane].

### 3.6 Kurz w smugach światła
Szczegóły smug i kurzu `LIGHT_ONLY` są w `22c` §6. Tu tylko dodatki: cząsteczki 1 px, bardzo wolne (`fixed_fps` 6–10), `light_mode = Light Only` w `CanvasItemMaterial` ogranicza je do obszaru świateł [zweryfikowane: opis trybu]; dla uproszczenia, kurz poza smugą po prostu nie istnieje (maska = obszar plamy). Dla TV: kurz w świetle ekranu to zbędny koszt [wniosek].

### 3.7 Padający śnieg
- **Technika:** jeden `GPUParticles2D` z `emission_shape` prostokątnym nad ekranem (szerokość widoku), `visibility_rect` powiększony do całego widoku, 2 lub 3 warstwy (różna prędkość i rozmiar 1/2 px) dla głębi; poziomy dryf z globalnego uniformu wiatru [zweryfikowane: opis własności; wniosek co do warstw]. Alternatywa najtańsza: pojedynczy, tilowalny sprite przewijany shaderem (UV + `TIME`) z kwantyzacją do piksela.
- **Śnieg „na kamerze":** emiter jako dziecko kamery z `local_coords = false`, żeby płatki nie jechały razem z ruchem gracza [zweryfikowane: opis własności].
- **Wnętrza:** wyłączyć lub ograniczyć do okien; za oknem paralaksa śniegu dla widoku „za oknem" (osobna Klasa assetów). Kolizja z `LightOccluder2D` może zatrzymać płatki pod okapem [zweryfikowane: możliwość kolizji z okluderem; użycie = [wniosek]].
- **Noc:** płatki `unshaded` wymagają ściemnienia modulate; ewentualnie `light_mode = Normal`, wtedy gaśnie w ciemności i rozświetla się w stożkach latarni, co wygląda dobrze i jest darmowe [wniosek].
- **[A]:** nie. Płatek = 1–2 px.
- **Ryzyko siatki:** wysokie przy dryfie podpikselowym: `interpolate` off, `fixed_fps` 15–30, brak obrotu.

### 3.8 Ślady na śniegu
Trzy opcje, od najtańszej:
1. **Decale (stempel sprite'a):** po każdym kroku `Sprite2D` śladu (2–3 piksele ciemniejszego koloru, wariant lewy/prawy, obrócony tylko o wielokrotności 90°) w warstwie pod postaciami; pula 200–400 węzłów, najstarsze znikają (alfa/`queue_free()`). Najprostsze i w pełni na siatce [wniosek].
2. **Tekstura ślady w `SubViewport`:** narysuj ślady do viewportu o rozdzielczości świata, wyświetl go jako nakładkę na terenie; pozwala na dowolną liczbę śladów za stały koszt i na zanikanie przy opadach (przyciemnianie/rozjaśnianie). Wzorzec „ślady opon na śniegu przez viewport" istnieje (godotshaders.com, „Car Tracks On Snow Or Sand") jako 3D/top-down z kamerą ortogonalną; zgłaszany problem to brak akumulacji między klatkami wymagający `clear_mode = never` [wtórne: streszczenie wyszukiwarki; w Godot 4 `SubViewport.render_target_clear_mode` do sprawdzenia]. Zalecane tylko jeśli śladów ma być bardzo dużo (ciągłe ścieżki) [wniosek].
3. **Shader normal/światło tylko** nie nadaje się do śniegu według wątku na godotforums (śnieg wymaga prawdziwej zmiany kształtu) [wtórne].
- **Zanikanie:** nowy śnieg zasypuje ślady po czasie (po grze: 60–180 s), co daje też „informację" (ślady NPC świeże/stare) bez kosztu [wniosek].
- **[A]:** nie. Śladów kilka wariantów rysowanych kodem. Ślady zwierząt/psa: dodatkowe sprite'y.
- **Ryzyko siatki:** niskie przy opcji 1; ślady muszą być przyciągane do siatki (pozycja zaokrąglona), inaczej sąsiadują „pół-piksele".

### 3.9 Latarnie; różnica nocnego światła w mieście i poza nim
Światło gracza w plenerze: `31`. Tu uzupełnienie dla latarni i kontrastu miasto/pole:
- **Latarnia miejska:** `PointLight2D` (ciepły sodowy, ok. 2000–2700 K, wartości z `docs/swiatlo-kolory-game1.md` trzeba zgrać) + sprite addytywny halo na lampie + elipsa plamy na śniegu (sprite Mul/Add na ziemi) zamiast pełnego światła tam, gdzie liczba świateł rośnie [wniosek]. Płatki śniegu w stożku światła (patrz §3.7) mocno budują klimat.
- **Koszt:** wiele latarni w kadrze szybko dochodzi do limitu świateł per item (16, patrz `22c`); rozwiązanie: tylko 2–4 prawdziwe światła w pobliżu gracza, reszta jako **fałszywe plamy** (sprite Add/Mul na terenie) [wniosek].
- **Różnica miasto vs poza miastem [wniosek]:** w mieście ambient wyższy i cieplejszy (sodowy odbity od śniegu), wiele małych źródeł (okna, neony, latarnie), brak „czerni"; poza miastem ambient niski i chłodny niebieski, śnieg odbija księżyc/gwiazdy, światło gracza i okna jedynych budynków dominują, a ciemność między nimi daje nastrój. Technicznie: dwie wartości `CanvasModulate` i profil per strefa z płynnym przejściem na granicy (`Tween` przy wejściu w strefę `Area2D`); nie dwie sceny [wniosek]. Ograniczenie: `CanvasModulate` jest jeden na canvas [zweryfikowane w `22c`].
- **[A]:** tekstury halo i plam to proste gradienty kodem.

## 4. Inne tanie ozdoby o podobnym klimacie [wniosek, lista pomysłów; przykłady z gier = [niezweryfikowane]]

| Ozdoba | Technika | [A] | Ryzyko siatki |
|---|---|---|---|
| Migotanie okien w oddali (losowo włączane żółte prostokąty) | shader/sprite, timer | nie | niskie |
| Mgła przy ziemi / zimowa mgiełka | 1–2 warstwy przewijanej, rozmytej tekstury o niskiej alfa; lub cząsteczki duże o niskiej alfa | opcjonalnie | średnie (rozmycie łamie styl, trzymać do 3 poziomów alfa) |
| Szron na szybie (okno od wewnątrz) | nakładka tekstury na rogi szyby, stopień zależny od temperatury | tak/nie | niskie |
| Para z włazów, kratek, rur | cząsteczki jak §3.1, ciągłe | nie | średnie |
| Wiszące sople i skapywanie | pojedyncze klatki + rzadka kropla | nie | niskie |
| Neon / szyld z migotaniem i odbiciem na śniegu | sprite addytywny + plama Add na ziemi; flicker losowy | tak (szyld) | niskie |
| Światło reflektorów samochodu przejeżdżającego za oknem | przesuwający się pas Add na ścianie wnętrza (kierunek stały) | nie | niskie |
| Wiatr na flagach, szyldach, praniu | ten sam shader co §3.3 lub 2–3 klatki | nie | niskie |
| Dym/para z samochodu, spaliny przy pracy silnika | cząsteczki §3.2 | nie | średnie |
| Kurz i płatki unoszące się w pokoju | §3.6 | nie | niskie |
| Ptaki (kruki) przelatujące lub siedzące, odlatujące przy zbliżeniu | 3–4 klatki + ruch liniowy | tak | niskie |
| Oddech zwierząt (pies), ślady psa | §3.1 i §3.8 | nie | średnie |
| Odbicie w kałuży/lodzie (lustro) | shader z odwróconym UV, kwantyzowany | nie | wysokie (jeśli bez kwantyzacji) |
| Grzejnik / kominek / piec: warstwa ciepłego światła z fluktuacją | `PointLight2D` + losowa energia (flicker przez `Tween`/szum), sprite ognia 3–4 klatki | tak (ogień) | niskie |
| Delikatna winieta, ziarno filmowe (noir) | post-process `hint_screen_texture` | nie | niskie, ale uwaga: filtruje cały ekran, nie w niskiej rozdzielczości |

Fluktuacje świateł ognia (poruszanie pozycją i energią światła): dewlog Catacombs of Venice opisuje losowe przesuwanie `Light2D` jako sposób na migotanie ognia [wtórne: fragment wyszukiwarki].

## 5. Rekomendowany zestaw na Poligony [wniosek]

1. Wspólny **globalny uniform wiatru** (kierunek, siła) i wspólne **profile pory dnia** (modulate dla ozdób `unshaded`).
2. **Poligon Ulica:** śnieg (2 warstwy), para z ust (przełącznik), dym z komina, drzewa na shaderze kaeylos (CC0) z kwantyzacją, ślady (decale), 2–4 latarnie (prawdziwe + fałszywe plamy), okna: dzień odblask Add, noc świecące prostokąty.
3. **Poligon Dom:** TV z tanią tablicą kolorów (jedno światło + halo), kurz w smudze (z `22c`), szron na szybach, kominek z flickerem.
4. Do pomiaru w Poligonie: koszt przy 4 latarniach i 2 TV w jednym kadrze, zachowanie `interpolate`/`fixed_fps` w Godot 4.7, wygląd `snap_2d_*` na ruchu cząsteczek.

## 6. Co zostało niezweryfikowane

- Konkretne techniki ozdób w Eastward, Hyper Light Drifter, Octopath i podobnych: brak wypowiedzi twórców. Gdyby ocena miała zależeć od „jak zrobiono to w grze X", trzeba obejrzeć GDC/dewlogi osobno.
- Ustawienia `snap_2d_*` i `SubViewport.render_target_clear_mode` w 4.7: do sprawdzenia w edytorze.
- Metoda TV z próbkowaniem viewportu do 8x8: tylko opis wtórny.

## Źródła

- Godot Docs (stable): GPUParticles2D, CPUParticles2D, CanvasItemMaterial, Light2D, „2D lights and shadows", „Particle systems (2D)", „CanvasItem shaders" (odczyt 2026-11-08), `https://docs.godotengine.org/en/stable/`.
- godotshaders.com: „2D Pixel perfect wind & sway effect" (kaeylos, CC0), `https://godotshaders.com/shader/2d-pixel-perfect-wind-sway-effect/`; „Car Tracks On Snow Or Sand" `https://godotshaders.com/shader/car-tracks-on-snow-or-sand-using-viewport-textures-and-particles/` [wtórne].
- Game Developer, wywiad Pixpil (Eastward), `https://www.gamedeveloper.com/disciplines/road-to-the-igf-pixpil-s-i-eastward-i-` (brak informacji o efektach).
- Dewlog Bloodlust: Santa Monica, `https://emontero.itch.io/bloodlust-santa-monica/devlog/62603/dynamic-lighting`.
- Wcześniejsze notatki: `22c-gra-swiatla.md`, `31-swiatlo-wokol-gracza.md`.
