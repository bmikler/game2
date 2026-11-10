# Spójne cienie: jedna mapa światła dla postaci, mebli, smug i drzwi

Data: **2026-11-10**. Kontekst: ticket 35 (jeden model cienia), uwagi człowieka „cienie zbugowane od fundamentów”, w tym nowy objaw: „światło czasem błędnie zakrywa cień, patrz drzwi wejściowe”. Tylko research i rekomendacja; kodu nie ruszano, nic nie generowano.

Oznaczenia: **[zweryfikowane]** = przeczytane w dokumentacji/źródle pierwotnym albo w naszym kodzie i ticketach; **[wtórne]** = z wyniku wyszukiwarki, nie z pierwszej ręki; **[z pamięci]** = nie sprawdzone teraz; **[wniosek]** = moje rozumowanie, godziny zawsze [wniosek].

## TL;DR

1. **Wymaganie twarde (od człowieka i koordynatora):** każde światło, także smugi w powietrzu, wstęgi na podłodze, „język” światła przy drzwiach i kurz, musi pochodzić z **tego samego rozwiązania z przesłanianiem**. Dziś te warstwy są rysowane **na wierzchu**, poza mapą światła, więc cień nie ma jak ich przyciemnić. To wystarcza, by wyjaśnić objaw z drzwiami bez żadnej złożonej fizyki [wniosek, na podstawie opisu koordynatora; kodu `dom_bryly.gd` nie czytałem].
2. **Nie zmieniać technologii, zmienić architekturę.** Rekomendacja: zostać przy analitycznej mapie (decyzja z ticketu 32: makieta 3D odrzucona, człowiekowi mapa się podoba), ale zrobić z niej **jedną funkcję `light_at(P, N)` i jeden bufor**, z której korzystają podłoga, ściany, meble, **postać (jako zwykły odbiorca w tych samych punktach)**, smugi (raymarch po tej samej funkcji), wstęgi, kurz i drzwi. Koszt ok. **50–80 h** [wniosek].
3. **Ukryta makieta 3D (HD-2D) nie jest lepsza dla naszego problemu.** Rozwiązuje przesłanianie silnikiem, ale (a) nie rozwiązuje przypisania światła do pikseli sprite'ów (ten sam problem co dziś), (b) nasz rzut ukośny nie jest obrotem kamery ortogonalnej, (c) miękkie cienie Godota 3D to filtr z ditherem (ziarno na płaskiej grafice), a `AreaLight3D` (nowość 4.7) liczy cień „jak z punktu”. Szacunek 40–70 h z wyższym ryzykiem [wniosek].
4. **Miękkie cienie z niewielu próbek bez bandingu:** albo analitycznie (rzut pudełka na prostokąt szyby, kapsuła/walec stożkiem), albo próbki z **per-pikselowym jitterem opartym o ten sam Bayer co wygląd gry**, tak by banding stał się ditherem artystycznym. Źródła dla pixel artu są słabe (patrz §6).

## 1. Dlaczego dziś jest niespójnie (diagnoza z kodu i ticketów)

[zweryfikowane w tickecie 35, README/ticket 33, `lit.gdshader`, nagłówku `sun_map.gdshader`; wnioski o przyczynach: [wniosek]]

| Objaw człowieka | Prawdopodobna przyczyna strukturalna |
|---|---|
| Postać inaczej niż meble | Postać ma **osobny model**: pasek światła postaci (`actor_mode` 2: słońce w punktach ciała, niebo z 4 stron, odbicie od podłogi), osobne reguły A4 (lampa ×1,4, długość ×1,6, punkt 10 m), kwantyzacja tylko dla niej; meble: pudełka w mapie z innymi przybliżeniami nieba (4 promienie binarnie). Dwa modele nie dadzą tego samego wyniku nawet przy identycznych parametrach. |
| Cień postaci „dziwnie ucięty” przy oknie | Cień postaci jest w **osobnym oknie 320×320** podmienianym na mapę domu z wygładzeniem krawędzi `SHADOW_EDGE = 24` px (`lit.gdshader`). Dwie mapy różnią się nie tylko postacią (inne próbkowanie, inne limity), więc na brzegu okna widać szew; ucięcie jest też możliwe, gdy cień/niebo sięga dalej niż okno. Sprite postaci czyta dodatkowo **pasek** (`actor_sun_map`), a nie piksel domu, więc jej światło jest liczone innym wzorem niż światło podłogi obok. |
| „Jakby dziwne światło z góry” | Ten sam pasek: „niebo wokół ciała z 4 stron + odbite światło podłogi” dodaje światło bez przesłaniania przez meble i bez związku z oknem po jednej stronie. |
| Palce/banding od świateł powierzchniowych | Niebo = 4 promienie (lub siatka `sky_grid`×`sky_grid`) o stałych pozycjach na szybie: mało próbek bez jittera daje stopnie i „palce” zamiast gładkiego lub ditherowanego półcienia. |
| Brak cieni przy drzwiach i oknach, „światło zakrywa cień” | Warstwy rysowane **na wierzchu** poza mapą: malowany „język” zimnego światła drzwi (`ShapePainter`, `poligony/dom_bryly.gd` ok. l. 1230–1250), wielokąty smug okien tylnych (`BeamCanvas`, z `WALL_Z+5`), wstęgi podłogi okien bocznych (`sun_ribbon.gdshader`), kurz. Cień mebla/postaci zmniejsza światło w mapie, ale ta warstwa dodaje swoje bez względu na nią. [wniosek; wskazane przez koordynatora] |
| Niespójność mebel kontra mapa | Odtwarzanie powierzchni z piksela y (`surface_at`, uwaga A inżyniera z 80): sprite nieregularny dostaje światło pudełka lub podłogi za nim. |
| „Wyglądy” (2 poziomy twarde) czernieją | Wersja 1 ticketu 35 kwantyzowała jeden wspólny udział cienia dla słońca, lamp i nieba (ticket 35, notatka). |

Wniosek ogólny: to nie jest jeden błąd, tylko **wiele równoległych modeli tego samego zjawiska**. Dodawanie kolejnych łatek (ticket 35 v1) pogarszało stan.

## 2. Co robią inne gry i silniki (pytanie 1)

| Technika | Źródło | Status |
|---|---|---|
| Malowane tła na zgrubnej geometrii 3D, słońce z mapą cieni, dwie wersje tekstur (światło/cień) mieszane maską | **Elsinore**, [Game Developer](https://gamedeveloper.com/programming/walking-in-a-painting-interior-daytime-lighting-in-elsinore) | [zweryfikowane] (czytane w researchu 79) |
| Okno i słońce w compute shaderze, cienie jako równoległoboki wytłoczone wzdłuż wektora cienia | **Blessings of the Forge**, [devlog](https://darredevyll.itch.io/blessings-of-the-forge/devlog/1009729/update-on-shaders-and-lighting) | [zweryfikowane] (twórca opisuje) |
| „Gra 3D z perspektywą 2D”, mgła i promienie słońca; technika nieujawniona | **Eastward**, [Game Developer](https://www.gamedeveloper.com/art/eastward-s-creators-share-insights-on-making-pixel-art-adventures) | [zweryfikowane] zdania, techniki brak |
| Sprite'y w świecie 3D, światła punktowe, cień w 3D | **Octopath Traveler** (UE4): [Unreal](https://www.unrealengine.com/developer-interviews/octopath-traveler-ii-builds-a-bigger-bolder-world-in-its-stunning-hd-2d-style); w tej sesji znalazłem tylko ogólniki („światło i cień padają jak w 3D”), **bez opisu techniki** | [wtórne] |
| Lightmapa z ukrytego SubViewportu w grze 2D top-down (meshe cieni przeniesione do subviewportu) | wątek [forum Godot](https://forum.godotengine.org/t/including-a-3d-background-in-a-subviewport-2d-cameras-render-image/127162) | [wtórne] |
| Radiance cascades | arXiv 2505.02041 (liczby w 79) | [zweryfikowane] w 79, odrzucone |
| Capsule shadows | Epic: [dokumentacja](https://dev.epicgames.com/documentation/unreal-engine/capsule-shadows-overview-in-unreal-engine): kapsuła zastępuje siatkę postaci, miękkość zależy od rozmiaru/kąta źródła, przy bardzo miękkich cieniach przechodzi w AO i może dać twardą linię; punktowe światła nie rzucają bezpośrednich cieni kapsuł | [zweryfikowane] (wyniki wyszukiwarki z oficjalnych dokumentów) |

**Czego nie znalazłem:** **Sea of Stars**, **Children of Morta**, **Rain World**: w tej sesji brak jakiegokolwiek opisu ich oświetlenia (jedno wyszukiwanie dla Sea of Stars i Rain World, żadne dla Children of Morta); nie opieram na nich żadnego wniosku. Artykuł Slembcke'a „2D Lighting Techniques” nie załadował się (strona pusta). **Nie ma w sieci wzorca „smugi słońca przez okna w pixel arcie z jednym spójnym przesłanianiem”**, który dałoby się skopiować; rekomendacja opiera się na mechanizmach, nie na precedensie.

**Wspólny wzorzec z tego, co jest pewne (Elsinore, Blessings, Epic):** jedno źródło prawdy o geometrii przesłon (ukryta geometria, pudełka, kapsuły) i **jedna** ocena widoczności źródła; różnice między postacią a rekwizytem pojawiają się tylko jako kształt przesłony (pudełko lub kapsuła), nie jako osobne reguły światła.

## 3. Ukryta makieta 3D w Godocie 4.7 (pytanie 2)

### 3.1 Co dokumentacja potwierdza

[zweryfikowane: [Using lights and shadows](https://docs.godotengine.org/en/stable/tutorials/3d/lights_and_shadows.html), [AreaLight3D 4.7](https://docs.godotengine.org/en/4.7/classes/class_arealight3d.html), [Volumetric fog](https://docs.godotengine.org/en/stable/tutorials/3d/volumetric_fog.html), [OmniLight3D](https://docs.godotengine.org/en/stable/classes/class_omnilight3d.html)]

- Cienie kierunkowe to mapa głębi renderowana z rzutu ortogonalnego; PSSM dzieli na 2–4 części. Zbyt niski **bias** daje „shadow acne”, zbyt wysoki **peter-panning**; **normal bias** zalecany przed zwykłym biasem (przy cienkich obiektach cień może się zwężać). Bias trzeba stroić na światło.
- Miękkie cienie: filtr jakości **Soft Very Low … Ultra** to próbkowanie z ditherem; dokumentacja wprost: **dither jest widoczniejszy na scenach o mało szczegółowych teksturach**, maskuje się go TAA/FSR2/FXAA lub wyższą jakością. Nasz pixel art jest właśnie płaski, a TAA/FSR w 960×540 nie wchodzi w grę [wniosek].
- **PCSS** (rozmiar półcienia rośnie z odległością od przesłony): `DirectionalLight3D.angular_distance`, `OmniLight3D/SpotLight3D.light_size`, `AreaLight3D.light_size`. Dokumentacja: PCSS jest **drogie**, na kilku dużych światłach.
- **AreaLight3D (nowość 4.7, czerwiec 2026):** prostokątne światło, `area_size`, `area_range`, `area_texture` (tylko Forward+/Mobile). **Cienie „liczone jak z punktu” (mapa cienia rysowana ze środka)** i miękkie przez PCSS; w Forward+ jedno takie światło w kadrze dodaje koszt każdemu obiektowi (klastrowanie); „najlepsze do cinematików i mocnych platform”. Wątek na forum zgłasza dziwny kształt cieni w 4.7.1 przy `size` 0 [wtórne]. Brak jakiejkolwiek informacji o stabilności produkcyjnej: **źródło słabe**.
- **Kamera ortogonalna:** w 79 ustalono, że `frustum_offset` działa tylko w trybie frustum; forum zgłasza gorszą jakość cieni w ortogonalnej (błędny LOD cieni) i że miękki filtr działa tylko przy `directional_shadow_mode = Orthogonal` [wtórne, forum/GitHub].
- **Mgła wolumetryczna:** tylko Forward+; cienie światła są widoczne w mgle („Enabling shadows on a light will also make those shadows visible on volumetric fog”), ale dokumentacja **nie wspomina o smugach przez okna**; ograniczenia: skończony zasięg, tylko single scattering (cienie ostre), **migotanie cienkich brył**, ghosting od reprojekcji, banding przy gęstej mgle [zweryfikowane].
- Pozytywny drobiazg: w 4.7 zgłoszono migotanie cieni, gdy tekstura z kamery 3D jest pokazywana jako Sprite/TextureRect w tej samej scenie [wtórne]; nasz bufor byłby w osobnym SubViewport, więc do sprawdzenia, nie założenia.

### 3.2 Kroki (gdyby budować)

1. Scena 3D w osobnym `SubViewport` (`own_world_3d = true`): ściany **z grubością** i otworami (cienka płaszczyzna przepuszcza światło na łączeniach: „light leaks”; ściana musi mieć przeciwległą ściankę lub `cast_shadow = DOUBLE_SIDED`), meble jako `BoxMesh`, postać jako `CylinderMesh`/kapsuła, materiał biały nieoświetlony (rejestrujemy tylko natężenie).
2. Źródła: `DirectionalLight3D` (słońce, `angular_distance` ≈ 0,5° z PCSS), niebo przez okno: **kilka** `SpotLight3D`/`OmniLight3D` z cieniem w płaszczyźnie szyby albo `AreaLight3D` (cienie jak z punktu, więc przybliżenie), lampy jako `OmniLight3D` z `light_size`; noc i drzwi jak okna.
3. Kamera: nasz rzut ukośny (x: 40 px/m, głębia 24 px/m, wysokość 40 px/m) **nie jest obrotem kamery ortogonalnej** (przy obrocie o θ głębia = s·sinθ, wysokość = s·cosθ, więc stosunek 24:40 wymusza s≈46,6, a x wychodzi 46,6 zamiast 40; 79 proponuje korektę osi X 0,858). Realnie wychodzą dwie ścieżki: (a) pochylona kamera + skalowanie X; (b) kamera z góry i mapa w metrach (x,d) dla podłogi, przeliczana przez nasz rzut przy próbkowaniu; ściany i boki mebli wymagają osobnych map [wniosek, wymaga prototypu; nie znalazłem źródła o ukośnym rzucie w Godocie 4].
4. Odczyt: sprite'y próbkują bufor natężenia w piksele ekranu, tak jak dziś próbkują mapy.

### 3.3 Co **nie** znika w wariancie 3D

- **Przypisanie światła do pikseli sprite'a** (uwaga A inżyniera): bufor z kamery da natężenie powierzchni **widocznej** w danym pikselu; nieregularny sprite (krzesło, stół na nogach) nadal dostaje światło pudełka za sobą. Ten sam problem, tylko rozwiązany geometrią proxy zamiast heurystyki `surface_at`.
- **Dwa światy:** jednostki HDR 2D vs bufor 3D, ekspozycja pokojów, tonemapping.
- **Ziarno ditheru** filtra cienia na płaskiej grafice (dokumentacja Godota) i potrzeba kwantyzacji/ditheru artystycznego nałożonego na to.
- **Stabilność AreaLight3D** w świeżym 4.7.

### 3.4 Jak wariant 3D obsłużyłby smugi w powietrzu i światło drzwi (wymaganie koordynatora)

- **Smugi:** jedyna droga „z silnika” to `FogVolume`/mgła wolumetryczna z `DirectionalLight3D` z cieniem: otwory okien robią kształt smugi automatycznie, **spójnie z cieniem na podłodze**, bo oba biorą tę samą mapę cienia. Cena: Forward+, ghosting, migotanie, banding, skończony zasięg, ostre cienie w mgle; w 960×540 trzeba to jeszcze kwantyzować [zweryfikowane w dokumentacji]. Wynik jest buforem 3D, który trzeba złożyć **addytywnie** nad sceną, więc nadal nie ma przesłaniania przez sprite'y (postać stojąca w smudze musi być odjęta osobnym przejściem: też sprite-w-3D).
- **Drzwi:** otwór w ścianie dostaje własne światło (`SpotLight3D`/`AreaLight3D` w płaszczyźnie drzwi, ze światłem ulicy) z cieniem; malowany „język” kasujemy. Zgodnie z dokumentacją AreaLight3D cień liczony jest ze środka prostokąta (przybliżenie).
- **Wniosek:** wariant 3D **też** wymaga skasowania wszystkich warstw rysowanych na wierzchu; sama technologia nie wymusza spójności, wymusza ją reguła „wszystko z bufora”, która da się wprowadzić **bez** zmiany technologii.

## 4. Miękkie cienie z niewielu próbek bez bandingu (pytanie 3)

| Metoda | Co mówi źródło | Dla nas |
|---|---|---|
| **Stratyfikacja + jitter/obrót per piksel + rozmycie** | Dokumentacja Godota (miękkie filtry = próbkowanie z ditherem, wyższa jakość = więcej próbek/rozmycia, rozmycie → stabilność kosztem ziarna) [zweryfikowane]. To standard dla map cieni; w pixel arcie rozmycia nie chcemy | Jitter pozycji próbki na szybie wg **tej samej macierzy Bayera 4×4**, której używa wygląd (`bayer4`, `look_share`): wtedy resztkowy szum jest wzorem ditheru gry i stoi w miejscu na świecie (kotwica `floor(px)`), nie „pełza” przy ruchu słońca. Stałe pozycje próbek (dziś) dają **stopnie**, nie ziarno |
| **PCSS** | Fernando 2005 (NVIDIA): wyszukanie przesłony, oszacowanie półcienia z płaskich równoległych płaszczyzn, potem PCF o zmiennym jądrze; w raporcie 36 próbek na wyszukiwanie i 64 na PCF [zweryfikowane w streszczeniach: [NVIDIA](https://developer.download.nvidia.com/shaderlibrary/docs/shadow_PCSS.pdf)]. Dla nas to **nie jest mapa cienia**, ale ta sama zasada (półcień ∝ odległość przesłony od odbiornika × rozmiar źródła) jest już zapisana w naszej regule `shadow_angle` + `shadow_gradient` | Zachować jako regułę geometryczną, wspólną dla wszystkich przesłon |
| **Analityczne zasłonięcie** | Epic capsule shadows: miękkość z rozmiaru/kąta źródła, kapsuła zamiast siatki [zweryfikowane]; Naughty Dog (uwaga D w 80): [z pamięci] | Dla **walca postaci** i **pudełek** względem **prostokątnej szyby**: rzut przesłony z punktu P na płaszczyznę szyby daje wielokąt; widoczność = pole szyby minus pole przekroju (dla AABB i prostokąta w płaszczyźnie osiowej: kilka operacji, bez szumu, bez bandingu). Kilka przesłon: suma z `min()` lub odejmowanie obwiedni (przybliżenie zakładające brak nakładania). **Przestroga:** wersja 1 ticketu 35 użyła „prostokątów kątowych nieba” tylko dla mebli i dała czarne plamy; to najpewniej wina **dwóch różnych przybliżeń** (meble vs postać), nie samej idei, ale wymaga testu w trybie „2 poziomy twarde” przed pokazaniem [wniosek] |
| **Raymarching miękkich cieni (Quilez)** | Strona `iquilezles.org/articles/rmshadows` zwróciła 404; **[z pamięci]**: oszacowanie półcienia z min(odległość/długość) wzdłuż promienia, znane artefakty | Nie dotyczy: nie mamy SDF scen, mamy pudełka |

**Rekomendacja metodologiczna [wniosek]:** niebo przez szybę = wzór Lamberta współczynnika kształtu (już jest, gładki) **pomnożony** przez widoczność szyby liczoną analitycznie (rzut przesłon na prostokąt szyby), z awaryjnym wariantem „próbki z jitterem Bayera 8–16”; słońce i lampy = tarcza/żarówka jako 8–16 próbek z jitterem Bayera. Każde źródło kwantyzowane osobno przy wyjściu funkcji.

## 5. Rekomendacja dla nas (pytanie 4)

### 5.1 Architektura docelowa

**Zasada:** nic nie rysuje światła; wszystko je **ocenia** jedna funkcja albo **mnoży przez widoczność z niej**.

1. **Jedna funkcja `light_at(P, N)`** (plik `.gdshaderinc`, wspólny): suma źródeł (słońce, niebo przez każdą szybę, noc, lampy, światło drzwi jako szyba ulicy), każde ze swoją widocznością przez **jedną** rodzinę przesłon: architektura (ściany, nadproża, skrzydła okien, ościeża), meble (pudełka), **postać (walec) na równi z meblami**. Reguły A4 (odległość lampy ×1,4, punkt słońca 10 m, rosnący półcień) obowiązują wszystkie przesłony, jako `shadow_*` w `LightingLook`.
2. **Jeden bufor** w pikselach świata (widok kamery z marginesem), liczony: w całości przy zmianie (godzina, lampy), **w miejscu** w oknie wokół ruchomych przesłon (patrz niżej).
3. **Postać jako odbiorca:** jej piksele wołają tę samą funkcję w swoich punktach ciała (P z kotwicy stóp i wysokości wiersza sprite'a; ok. 3 tys. pikseli, tanie), zamiast czytać pasek z innym wzorem. To usuwa „pasek światła” i „dziwne światło z góry”. Odbicie od podłogi jako człon funkcji (z buforu podłogi), nie osobny wzór.
4. **Okno cienia postaci przerysowywane w tej samej teksturze:** zamiast drugiej tekstury mieszanej wygładzeniem 24 px (`SHADOW_EDGE`), przerysować prostokąt tej samej tekstury (SubViewport bez czyszczenia, scissor). Obszar wpływu postaci jest **wyznaczalny**: jej podstawa wytłoczona wzdłuż każdego światła do maksymalnej długości cienia plus zasięg nieba; poza nim wynik jest bit-w-bit ten sam, więc **szwu nie ma i mieszanie jest zbędne** [wniosek]. Ustalenie człowieka z notatki 35: 100 kl./s wystarcza; zmierzone w ticketach: okno wokół postaci ≈ 1 ms, cała mapa ≈ 6 ms (143/113 kl./s), więc pełne przeliczenie co klatkę jest awaryjną opcją na granicy 100 kl./s.
5. **Smugi w powietrzu = raymarch po tej samej widoczności:** dla piksela smugi marsz kilkunastu kroków wzdłuż promienia widzenia (w naszym rzucie stały kierunek), w każdym kroku `sun_visibility(P)` (okna + meble + postać), zakres ograniczony do obwiedni smugi, połowa rozdzielczości, jitter kroku Bayerem. To jest dokładnie to, co robiłaby mgła wolumetryczna, ale **z tą samą funkcją co podłoga**, więc postać stojąca w smudze ją przerywa, a cień mebla przecina smugę tam, gdzie przecina plamę [wniosek]. Zastępuje `BeamCanvas`.
6. **Wstęgi okien bocznych, plama, „język” drzwi, kurz:**
   - wstęgi i plama = człon słońca w buforze podłogi (ustalenie „okna boczne: bez plamy słońca na podłodze” (pamięć projektu, tickety 27/31) zostaje **maską członu**, nie osobnym shaderem; `sun_ribbon.gdshader` do usunięcia);
   - „język” drzwi = drzwi jako otwór z własnym członem (szyba ulicy: współczynnik kształtu prostokąta drzwi, już mamy `door_sash`, `door_k`) z widocznością jak każde inne światło; malowany kształt kasujemy. Jeśli człowiek chce konkretnego rysunku języka, to rysunek staje się **maską wejściową** mnożoną przez widoczność, nie warstwą dodaną na wierzch;
   - kurz: alfa każdej drobiny × `sun_visibility(P_drobiny)` albo rysowanie w przejściu smugi.
7. **Wygląd:** kwantyzacja i dither osobno per źródło na wyjściu funkcji (ustalenie z 35, p. 3), w przestrzeni liniowej, jedna tonemapa.
8. **Test spójności (bramka jakości zamiast oceny „na oko”):** (a) *zamiana kształtu*: ta sama bryła jako rekwizyt i jako postać w tym samym miejscu daje ten sam cień (różnica ≤ 1 poziom; narzędzie `tools/pomiar/roznica.mjs`); (b) *test zasłonięcia*: nieprzezroczyste pudełko przed drzwiami/oknem ciemni **każdy** piksel, który inaczej dostałby światło od tego otworu (wykrywa warstwy narysowane na wierzchu); (c) tryb debug „tylko bufor”, w którym wyłączone są wszystkie warstwy poza nim: obraz ma się nie zmienić poza smugami.

### 5.2 Co porzucić

- Pasek światła postaci (`actor_mode`, `actor_sun_map`, `actor_lamp_map`, osobne wzory ciała) i osobne reguły postaci (`object_length`, `shadow_lamp_length` tylko dla niej).
- Okno cienia z mieszaniem krawędzi (`SHADOW_EDGE`) i trzy dodatkowe światła na sprite (wysokości 7000/7500/7700 jako identyfikator mapy; uwaga E z 80: globalne uniformy zamiast tego).
- `BeamCanvas`, `sun_ribbon.gdshader`, malowany „język” drzwi (`ShapePainter`), kurz jako warstwa niezależna od widoczności, plamka pod stopami (zastąpiona członem kontaktowym AO w tej samej funkcji).
- Osobne przybliżenia nieba dla mebli oraz wyjątki „własna ściana” (błędy wersji 1).
- Zostają: `sun_geometry` (dane w metrach), wzór Lamberta dla nieba, kwantyzacja per źródło, presety krytyka, pomiary względem game1.

### 5.3 Czego **nie** robić

- Nie wracać do ukrytej makiety 3D (ticket 32, decyzja człowieka) ani radiance cascades (79). Wariant 3D zostaje jako **narzędzie testowe** (referencyjny render „prawdziwym” cieniem do porównania z funkcją analityczną, ok. 10–15 h, opcjonalnie) [wniosek].
- Nie przechodzić na mapę wysokości (propozycja inżyniera, uwaga C) dla wnętrz: okno w ścianie z parapetem i nadprożem to „dziura”, której pole wysokości jednowartościowe nie reprezentuje. Mapa wysokości ma sens dopiero dla przesłon ulicznych [wniosek].

### 5.4 Szacunek godzin [wniosek]

| Krok | h |
|---|---|
| Jedna funkcja `light_at` ze scaleniem wzorów (postać = zwykła przesłona i odbiorca), reguły A4 dla wszystkich | 12–18 |
| Analityczna widoczność nieba (rzut przesłon na szybę) + wariant z jitterem Bayera | 6–10 |
| Przerysowanie okna w tej samej teksturze (bez szwu), obszar wpływu z geometrii | 4–6 |
| Smugi (raymarch po widoczności), kurz | 10–16 |
| Wstęgi, plama boczna jako maska członu, drzwi jako otwór, usunięcie warstw na wierzchu | 6–10 |
| Bufor pozycji sprite'ów (uwaga A; można odłożyć, zacząć od postaci, podłogi, ścian i pudełek) | 10–16 |
| Harness testów spójności (§5.1 p. 8) | 4–6 |
| **Razem** | **ok. 50–80** (bez bufora pozycji ok. 40–64) |

Wariant 3D dla porównania: 40–70 h z ryzykiem (kalibracja rzutu, mgła, AreaLight3D 4.7, ziarno) i **bez** usunięcia problemu przypisania do sprite'ów [wniosek].

## 6. Gdzie źródła są słabe

- Brak opisów oświetlenia Octopath, Eastward, Sea of Stars, Children of Morta, Rain World na poziomie techniki; jedyne konkretne mechanizmy: Elsinore, Blessings of the Forge.
- Slembcke (2D Lighting Techniques) i Quilez (miękkie cienie) nie załadowały się; PCSS tylko ze streszczeń NVIDIA.
- AreaLight3D w 4.7 (nowość z czerwca 2026): dokumentacja klas przeczytana, produkcyjnych raportów prawie brak.
- Zachowanie cieni w kamerze ortogonalnej i ukośny rzut w Godocie 4: tylko wątki forum, brak źródła oficjalnego; liczby z §3.2 p. 3 to rachunek własny (do prototypu).
- Diagnoza przyczyn w §1 opiera się na ticketach, nagłówkach shaderów i opisie koordynatora; **pełnego kodu `sun_map.gd` i `dom_bryly.gd` nie czytałem**, więc to hipotezy do potwierdzenia testem zasłonięcia (§5.1 p. 8b).
- Wszystkie godziny i milisekundy własne, bez pomiarów; twarde liczby: ticket 33 (okno ≈1 ms, cała mapa ≈6 ms, 143/113 kl./s).
