# Dynamiczne oświetlenie zamiast ręcznie strojonych smug: jak i za ile

Ticket: `docs/wayfinder/tickets/30-dynamiczne-oswietlenie-research.md`. Data researchu: **2026-11-09**. Tylko techniki; nic z fabuły gry nie jest publikowane, nic nie generowano na zewnętrznych platformach, kodu nie ruszano.

Oznaczenia (jak w 78):
- **[zweryfikowane]**: przeczytałem w źródle pierwotnym (dokumentacja Godota, tekst twórcy, abstrakt pracy) albo w naszym kodzie. Przy źródłach z devlogów oznacza „twórca tak pisze”, nie „sprawdziłem działanie”.
- **[wtórne]**: z artykułu lub streszczenia wyszukiwarki, nie z pierwszej ręki.
- **[z pamięci]**: pamiętam, tu nie sprawdzone.
- **[wniosek]**: moje rozumowanie, rachunek albo szacunek (godziny i milisekundy są zawsze [wniosek]).

## TL;DR

- **Tak, da się, ale nie „światłami 2D Godota”.** To, co nam się nie udaje ręcznie, to nie jest trudna fizyka. Plama okna na podłodze to rzut równoległy płaszczyzny okna na płaszczyznę podłogi, czyli afiniczne ścięcie, które nasz kod już liczy (`WindowLight._shear`, 22c §1.3) [zweryfikowane w kodzie i w 22c]. Dynamiczne podejście zmienia dwie rzeczy: (1) **dane okna są jednym źródłem prawdy** (otwór w metrach, skrzydła, ściana), z którego wychodzi i smuga, i plama, i widok z ulicy; (2) **cienie i przesłony wychodzą z geometrii** (meble, ościeża, ściany, budynek na ulicy), zamiast być dorysowywane.
- **Najlepszy stosunek jakości do kosztu: „analityczna mapa światła w płaszczyźnie”** (wariant F, mój, hybryda 2 i 4): shader liczy dla każdego piksela podłogi (i ściany), czy promień do słońca przechodzi przez skrzydło okna i omija pudełka mebli. Daje plamę z ramą okna i cieniem kanapy, ruch przez dzień bez klatek kluczowych, ten sam wektor słońca na zewnątrz. Bez 3D, bez nowych assetów graficznych, 0 generacji, ok. 25–35 h kodu na prototyp [wniosek].
- **Drugi do porównania: ukryta makieta 3D z prawdziwym słońcem** (podejście 2): jedyna droga, która da **prawdziwą smugę w powietrzu** (mgła wolumetryczna) spójną z plamą i z rzutem 3/4. Droższa (ok. 35–55 h), z ryzykiem: mgła wolumetryczna Godota tylko Forward+, miga i bandinguje [zweryfikowane w dokumentacji].
- **Odpadają:** pełne 3D / HD-2D (przepisuje cały Przepis mebli i postaci, a człowiek już odrzucił 3D dla postaci), radiance cascades / SDF GI (przerost dla jednego słońca, plama ma mieć twarde brzegi 1 px, a RC robi półcienie; mało gotowego kodu w Godocie), 2–3 klatki kluczowe (plama przesuwa się o setki px w ciągu dnia, więc krzyżowe mieszanie daje „ducha”).
- **Czego dynamika NIE rozwiąże:** (a) smugi z okien dolnych i bocznych „nie zdradzają okna”, bo **okna tam nie widać**; poprawna geometria da poprawną, ale nadal nieczytelną plamę, trzeba dać sygnał (ościeże, rama przy krawędzi, lity pasek światła) [wniosek]; (b) brzeg domu w czerni (ticket 29) to sprawa zasięgu ambientu i HDR→sRGB, nie słońca; mapa światła w płaszczyźnie daje tylko dogodne miejsce na gładkie wygaszenie w przestrzeni liniowej.
- **Cena w Miesiącu produkcji:** ok. 0 generacji i 0 USD; ok. 10–15 h przeglądu metadanych (wysokość i obrys mebla, otwory okien w pomieszczeniach i fasadach), głównie skryptem z domyślnymi wartościami [wniosek]. Mapy normalnych (ticket 22) są niezależne i potrzebne tylko do cieniowania sprite'ów.

## 1. Co mamy dziś i dlaczego jest trudno

[zweryfikowane w kodzie `style-lab/lighting/`]

- `WindowLight` (okna tylne) dla każdej szyby składa wielokąt z jej rogów i ich rzutów (`BeamCanvas.paint`: otoczka wypukła, 8 pasm jasności, `beam_extend`, `beam_widen`), do tego światło `PointLight2D` z teksturą „cookie” z szyb ścięte `_shear` na podłogę (plama), poduszka nieba, odbicie. Bramka `_facing(sun)`.
- `SideWindowLight` robi to samo dla ścian bocznych i dolnej, z osobnymi parametrami (`panes`, `beam_k`, `patch`, `patch_k`), czyli drugi zestaw ręcznych strojeń. Ticket 27 notuje: smugi dolne marne, plama z krzyżem zła.
- Światło to `PointLight2D` w HDR 2D, ambient to „płaska lampa wysoko”, `lit.gdshader` pomija N·L dla ambientu [zweryfikowane].
- Sama geometria jest poprawna w jednym wzorze (22c §1.3): punkt okna na wysokości `z` ląduje na podłodze `z·cot(e)` dalej, na ekranie `dx = −40·z·cot(e)·sin φ`, `dy = +40·z·cot(e)·cos φ` [zweryfikowane w 22c, własny rachunek].

**Dlaczego wychodzi źle (wniosek):**
1. Dwie ścieżki kodu (tylne vs boczne/dolne) z różnymi kompromisami, więc wygląd się rozjeżdża.
2. Smuga w powietrzu jest rysowana jako otoczka wypukła z jasnością zależną od odległości, a nie jako bryła (pryzmat między szybą a plamą). Dlatego zwęża się i gubi mullion (47 §1).
3. Okno dolne i boczne **nie ma rysowanej szyby**, więc nie ma czego rzutować wizualnie poza geometrią; to problem czytelności, nie matematyki.
4. Zgodność z ulicą wymaga tego samego wektora słońca i tych samych otworów po obu stronach; dziś otwory fasady i otwory pokoju są osobnymi danymi (Poligon Ulica vs Dom).

## 2. Co robią inne gry: przegląd źródeł

| Technika | Gra / autor | Co dokładnie | Źródło | Status |
|---|---|---|---|---|
| Malowane tła na ukrytej geometrii 3D + słońce z mapą cieni | **Elsinore** (Golden Glitch) | Słońce to światło kierunkowe z kolorem i obrotem z zegara gry; mapa cienia mówi, które piksele są oświetlone; każda malowana tekstura ma wersję „światło” i „cień”, shader miesza je według cienia; modele mają tylko zgrubnie pasować do płaszczyzny obrazka; bez modelu obiekty, które nie rzucają i nie odbierają cienia; drugie, słabe światło kierunkowe z góry ciemni styki; nie opisuje smug | [Game Developer: Walking in a Painting](https://gamedeveloper.com/programming/walking-in-a-painting-interior-daytime-lighting-in-elsinore) | [zweryfikowane] |
| Okno + słońce w shaderze, bez 3D | **Blessings of the Forge** (Godot, devlog) | Compute shader rysuje nakładkę 640×360; wierzchołki okna przekształcane od środka dolnej krawędzi (rozciągnięcie, obrót, rzut) według kierunku słońca; bramka, gdy kąt słońca > 90° od normalnej okna; wnętrza jako prostokątne maski, cień jako równoległoboki wytłoczone wzdłuż wektora cienia; CPU co klatkę podaje kierunek i kolor słońca; okna uproszczone do pudełek, cienie okien i tekstury jeszcze niezrobione | [devlog](https://darredevyll.itch.io/blessings-of-the-forge/devlog/1009729/update-on-shaders-and-lighting) | [zweryfikowane] (twórca opisuje, nie sprawdzałem działania) |
| Cookie (maska światła) z ramą okna | **xDasher** (Unity) | Szara tekstura nałożona na światło daje cień ramy okna na podłodze | [devlog](https://pixel-beef.itch.io/xdasher/devlog/192949/4-things-we-did-to-add-light-and-depth-to-our-pixel-art-game) | [zweryfikowane] cookie; czy dynamiczne: nie podano |
| Ukryta bryła pod sprite'em | **Xenosis** (devlog) | Skrzynia to sprite na ukrytym sześcianie, który rzuca realny cień; własny shader odbiera cienie | wyszukiwarka, strony nie pobrałem | [wtórne] |
| Ukryta geometria cieni + ręcznie malowane normalne | M. Vicente (eksperymenty pixel art) | „malowanie normalnych ręcznie i ukryta geometria dla cieni”; sam autor pisze o większym obciążeniu niż klasyczne 2D; brak smug | [80.lv](https://80.lv/articles/exploring-next-gen-pixel-art-with-real-time-dynamic-lighting) | [zweryfikowane] |
| Mapa światła jako obraz z ukrytego viewportu | wątek na forum Godota | „mesh cieni przeniesione do subviewportu, który renderuje stały obraz jako lightmapę” w grze top-down 2D; propozycja: biała kopia kafli w 3D, światło 3D, wynik jako maska nad 2D | [forum Godot](https://forum.godotengine.org/t/including-a-3d-background-in-a-subviewport-2d-cameras-render-image/127162), wyszukiwarka | [wtórne] |
| Gra 3D z perspektywą 2D | **Eastward** (Pixpil, własny silnik Maoi) | „3D game with a 2D perspective”; zasoby odbudowane w 3D i malowane w bump mapie; mgła i promienie słońca o świcie i zmierzchu; brak szczegółów techniki | [Game Developer](https://www.gamedeveloper.com/art/eastward-s-creators-share-insights-on-making-pixel-art-adventures) | [zweryfikowane] zdania, technika nieujawniona |
| Normalne na tłach i rekwizytach | **Dead Cells** (Motion Twin) | tła i dekoracje rysowane w pixel arcie, potem „przerysowane w normalnych”, co daje dynamiczne światło i inne tinty na biom; nie podano kosztu | [80.lv](https://80.lv/articles/interview-with-the-developers-of-dead-cells) | [zweryfikowane] |
| Niskie 3D + shader pikseli | rekonstrukcja stylu t3ssel8r (David Holland, Godot) | render 640×360, kamera przyciągana do siatki tekseli i przesunięcie z powrotem po błędzie; toon-światło; billboardy; god rays jako jeden pełnoekranowy raymarch w post-procesie ok. **1,7 ms na GTX 1060 laptop** (wariant per-instancja za drogi); własna kompilacja Godota 4.3; **nie czytałem materiałów samego t3ssel8r** | [Holland](https://davidholland.netlify.app/articles/3d-pixel-art-rendering) | [zweryfikowane] (to rekonstrukcja, nie oryginał) |
| HD-2D | **Octopath Traveler** (Acquire/Square Enix, Unreal) | sprite'y w świecie 3D, tilt-shift, DOF, punktowe światła; mały zespół | [Unreal: Octopath II](https://www.unrealengine.com/developer-interviews/octopath-traveler-ii-builds-a-bigger-bolder-world-in-its-stunning-hd-2d-style), Wikipedia | [wtórne] |
| Radiance cascades | A. Sannikov (Grinding Gear Games); HRC, praca arXiv 2505.02041 | stały koszt niezależny od złożoności sceny; **1,85 ms przy 512×512, 7,67 ms przy 1024×1024 na RTX 3080 Laptop**; w Godocie: demo S. Bigosa „nie plug-and-play, jako referencja”, brak licencji w opisie, komentarz, że może nie działać na nowych wersjach | [arXiv](https://arxiv.org/abs/2505.02041), [80.lv](https://80.lv/articles/radiance-cascades-new-approach-to-calculating-global-illumination), [Bigos](https://sambigos.itch.io/2d-global-illumination-in-godot) | [zweryfikowane] |
| Gry-kotwice REPLACED, NORCO | — | nie znalazłem żadnego opisu ich techniki oświetlenia; REPLACED chyba w Unreal z 3D-owym światłem | — | [z pamięci], nie sprawdzone |

**Luka:** nie znalazłem żadnej gry ani devlogu pokazującego **smugi słońca przez okno w pixel arcie liczone dynamicznie**. Najbliżej są Elsinore (plamy i cienie z mapy cieni, bez smug), Blessings of the Forge (plama z okna w shaderze) i Eastward (smugi o świcie, technika nieujawniona). Rekomendacja jest więc oparta na mechanizmach, nie na wzorcu do skopiowania.

## 3. Fakty o Godocie 4.7, które decydują

[zweryfikowane w dokumentacji: [2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html), [canvas_item shader](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html), [Camera3D](https://docs.godotengine.org/en/stable/classes/class_camera3d.html), [Volumetric fog](https://docs.godotengine.org/en/stable/tutorials/3d/volumetric_fog.html)]

- Cienie `DirectionalLight2D` są zawsze nieskończenie długie i `height` ich nie zmienia; dokumentacja odsyła do własnego shadera czytającego **SDF** (generowany z `LightOccluder2D` z włączonym „SDF Collision”, domyślnie; `texture_sdf`, `texture_sdf_normal`, `sdf_to_screen_uv`, `screen_uv_to_sdf` dostępne w `fragment()` i `light()`).
- Normalne: `CanvasTexture` z diffuse + normal; `height` świateł działa tylko na normalne.
- Światło 2D liczy się w rozdzielczości viewportu; do „pikselowego” światła dokumentacja podaje przyciąganie `LIGHT_VERTEX` i `SHADOW_VERTEX` do siatki. U nas viewport to 960×540, więc to już jest piksel sztuki [zweryfikowane, 22c §5].
- Filtr cienia None jest najszybszy i pasuje do pixel artu; PCF13 „tylko dla kilku świateł” [zweryfikowane].
- Kamera ortogonalna 3D: `frustum_offset` (ścięcie Y) działa **tylko w trybie `PROJECTION_FRUSTUM`**, czyli perspektywicznym; nie da przez nią rzutu ukośnego ortogonalnego [zweryfikowane]. Nasz rzut 3/4 z głębią ×0,60 odtwarza się więc **pochyloną kamerą ortogonalną**: tan θ = 0,60 ⇒ θ ≈ 31°, skala `s·sin θ = 24 px/m` ⇒ `s ≈ 46,6 px/m`, wysokości `s·cos θ = 40 px/m` (zgadza się), ale poziomo wychodzi 46,6, nie 40, więc trzeba ściągnąć oś X o 0,858 (np. viewport 824×540 rozciągnięty do 960) [wniosek, własny rachunek]. Do sprawdzenia na prototypie.
- Mgła wolumetryczna: **tylko Forward+** (mamy Forward+, `project.godot`); skończony zasięg; cienkie bryły migoczą (trzeba zwiększać głębię kosztem wydajności); temporal reprojection zostawia smugi na ruchomych światłach; banding przy większej gęstości. Dla szybkich zmian zaleca się zerowanie energii mgły [zweryfikowane]. Dokumentacja nie wspomina o smugach przez okna.
- Godot 4.7 (czerwiec 2026): z wyszukiwarki widać tylko wyjście HDR i `AreaLight3D` (tylko 3D); żadnej nowej funkcji światła 2D nie znalazłem [wtórne, nie czytałem oficjalnych notatek wydania].

## 4. Analiza pięciu podejść (plus jedno)

Wspólne dane wejściowe wszystkich podejść poza 5: **otwór okna w metrach** (ściana, pozycja, rozmiar, lista skrzydeł, głębokość ościeża), **sun_direction** (już w `LightingDirector` / `SunSample`), a dla cieni **pudełka** (ściany, meble: obrys + wysokość). Okna wnętrz są już „rysowane kodem”, nie generowane (64 §wnioski, wiersz 4) [zweryfikowane w 64], więc dane okna są za darmo.

### 4.1 Światła 2D Godota (PointLight2D / DirectionalLight2D / okludery / normalne)

- **Smuga i plama:** `PointLight2D` z teksturą (nasz „cookie”) już działa; ścięcie tekstury `Transform2D` jest dozwolone (22c §5) [zweryfikowane]. `DirectionalLight2D` z okluderami: ściana jako okluder z lukami na okna dałaby równoległe pasma światła z ramą, ale (a) cień jest nieskończony i nie zna wysokości okna, więc plama nie ma bliskiej i dalekiej krawędzi, tylko pas bez końca; (b) nie obsługuje `range_item_cull_mask` (dokumentacja 4.4), więc oświetla też ściany z obrazków; (c) okluder na sprycie ma problem z samocieniem [zweryfikowane/22c §3]. To model „latarka nad mapą, ściana nieskończenie wysoka” [zweryfikowane, 22c].
- **Rzut 3/4:** brak wsparcia, trzeba ręcznie ścinać.
- **Normalne:** dają kształt sprite'om pod lampą i oknem, ale **nie dają smug ani plam**.
- **Koszt per asset:** mapa normalnych, Pixellab `/normal-map` lite 0,1 gen./obraz (ticket 22). Dla 120–660 mebli w 3 kierunkach: ok. 36–200 gen. [wniosek, z inwentarza 05]; własny skrypt z game1-proto 0 zł.
- **Kod:** mały (większość już jest), ok. 4–6 h na próbę okluderów dla słońca; prawdopodobny wynik: odrzucenie [wniosek].
- **Wydajność:** dobra; limit 16 świateł na obiekt, 256 na render [zweryfikowane, 22c §5].
- **Ocena:** to zostaje dla lamp, latarki, TV; **nie dla słońca przez okno**.

### 4.2 Ukryta makieta 3D jako bufor światła

- **Pomysł:** niewidoczna scena 3D (ściany z otworami, meble jako pudełka), `DirectionalLight3D` jako słońce, ewentualnie `FogVolume`; kamera ortogonalna pochylona o 31° (p. wyżej); wynik w `SubViewport` 960×540 (albo 824×540 + rozciągnięcie), kwantyzacja (posteryzacja) i nałożenie na świat 2D trybem MUL (cień) i ADD (smuga). Wariant „tylko podłoga”: kamera z góry, tekstura w metrach, skalowana y×0,60 przy rysowaniu, bez dopasowywania kamery.
- **Precedensy:** Elsinore (mapa cieni słońca na zgrubnej geometrii pod malowanymi tłami, [zweryfikowane]), Xenosis (ukryty sześcian [wtórne]), wątek forum o lightmapie ze subviewportu [wtórne]. Nikt z nich nie pokazuje wolumetrycznej smugi.
- **Wygląd:** prawdziwa plama z ramą, cień kanapy, cień ościeży, cienie budynków na ulicy (te same pudełka), smuga w powietrzu z mgły: spójna geometrycznie z plamą i z kamerą; pod warunkiem dobrego strojenia migotania i bandingu [zweryfikowane w dokumentacji]. Ostrość krawędzi: mapa cieni ma rozdzielczość i filtry; w ortografii znane są problemy z cieniami (LOD cieni) [wtórne, wątki forum].
- **Pixel perfect:** wynik w 960×540 jest już w siatce pikseli; trzeba posteryzować i uniknąć „pływania” krawędzi cienia przy ruchu słońca (podobne problemy opisuje Holland: przyciąganie do siatki, wygładzanie cieni) [zweryfikowane]. Plamy mają mieć twarde brzegi (22c §1.3: półcień ok. 1 cm/m) [zweryfikowane w 22c].
- **Koszt per asset:** obrys + wysokość mebla (pudełko); opcjonalnie lepsza bryła tylko tam, gdzie cień ma śledzić kształt (Elsinore: tylko zasłony). Okna i ściany pokoju: z kodu. Kto: skrypt z domyślnych wymiarów sprite'a i tabeli „wysokość typu mebla”, człowiek poprawia wyjątki [wniosek]. Generacje: 0.
- **Kod:** warstwa danych (wspólna z F) 6–8 h; budowa makiety z definicji pokoju 8–12 h; kalibracja kamery i zgranie z 0,60 4–6 h; strojenie słońca i cieni 6–10 h; mgła wolumetryczna + kwantyzacja smugi 8–16 h; kompozycja 4 h. Razem ok. **35–55 h** [wniosek].
- **Wydajność:** jedno światło kierunkowe z cieniem i jedna mgła w 960×540: oczekuję 1–3 ms na RTX 4060 Laptop [wniosek, bez pomiaru]; na słabszym sprzęcie (Steam Deck, zintegrowane GPU) mgła wolumetryczna jest ryzykiem; zapas: wyłączyć mgłę i zostawić plamę + smugę rysowaną wielokątem z danych.
- **Ryzyko:** średnie-wysokie (dwa światy 2D/3D, kalibracja, mgła). Mieszanie świateł: nasz świat jest w HDR 2D; wynik 3D jest osobnym viewportem, więc trzeba świadomie zgrać jednostki ekspozycji z `Exposure` [wniosek].
- **Przepisy:** dopisek do Przepisu mebli (obrys + wysokość), do Przepisu pomieszczeń (otwory jako dane). Bez zmiany grafiki.

### 4.3 Pełne 3D z shaderem pixel art / billboardami (t3ssel8r, HD-2D)

- **Co to zmienia:** kamera i świat w 3D; sprite'y jako billboardy; światło, cienie, mgła z silnika; wygląd: Octopath / Eastward [zweryfikowane/wtórne w §2].
- **Problem naszego rzutu:** nasze sprite'y są rysowane w stałym kącie 3/4 (głębia ×0,60); billboard w kamerze perspektywicznej łamie spójność kąta, a obrót kamery (zaletą HD-2D) w ogóle niczego nam nie daje [wniosek]. W Octopath II kamera obracana mocno stawia pytanie o limit wierności płaskich sprite'ów [wtórne].
- **Koszt:** cały świat (budynki, wnętrza, meble) w 3D albo płaszczyznach; wszystkie Przepisy do przepisania; dodatkowo przyjęta wcześniej decyzja (pamięć projektu: „Blender/3D dla chodu postaci odrzucone”) mówi o postaciach, ale wskazuje kierunek [wniosek]. 200–400 h+ [wniosek].
- **Wydajność:** dobra (silnik 3D robi to, do czego jest), t3ssel8r-owskie god rays 1,7 ms na GTX 1060 laptop [zweryfikowane, Holland].
- **Ocena:** odpada. Wszystko, co daje, da się wziąć z 4.2 na małym kawałku.

### 4.4 Mapy wysokości / głębi na sprite'ach, SDF, raymarching, radiance cascades

- **SDF Godota:** z `LightOccluder2D` powstaje 2D SDF; w shaderze `texture_sdf` itd. [zweryfikowane]. To SDF **płaski** (kontur w ekranie), bez wysokości: da cień słońca „jak z góry”, nie plamę z okna o skończonej wysokości, więc dla nas ma ograniczoną wartość [wniosek].
- **Cienie z mapy wysokości w przestrzeni ekranu (SSS):** bufor wysokości sceny (z pudełek meble + ściany, nie z głębi każdego sprite'a), raymarch z piksela do słońca. W rzucie ukośnym relacja jest liniowa, więc raymarch jest prosty: punkt na wysokości h przesuwa się na ekranie o `40·h` w górę [wniosek]. To jest w istocie wariant F poniżej, bez potrzeby głębi per sprite.
- **Głębia per sprite (np. lokalne Depth Anything w ComfyUI):** koszt: 1 plik na sprite, generowane lokalnie (0 USD; licencja modelu: wersja Small kiedyś Apache-2.0, większe CC-BY-NC [z pamięci], sprawdzić przed użyciem, wymóg Steam z Notes). Jakość głębi z pixel artu niepewna, a nie daje nic ponad pudełka dla plamy i smugi [wniosek].
- **Radiance cascades / 2D GI:** daje odbicie ciepła od plamy, światło odbite, miękkie cienie wielu źródeł naraz. Koszt stały: HRC 1,85 ms @ 512², 7,67 ms @ 1024² na RTX 3080 Laptop [zweryfikowane, abstrakt]; dla 960×540 (ok. 2× pikseli niż 512²) oczekuję ok. 3,5 ms na 3080 Laptop i 5–6 ms na 4060 Laptop [wniosek]. Dla jednego słońca to przerost; dla nas ważne: **ma robić twarde brzegi plamy (1 px)**, a RC naturalnie daje półcienie [wniosek]. Gotowego kodu pod Godot 4.7 brak (demo Bigosa „jako referencja”) [zweryfikowane]. 40–80 h + ryzyko [wniosek].
- **Ocena:** SDF/RC odpadają dla słońca. Raymarch po buforze wysokości z pudełek wchodzi do F.

### 4.5 Wypiekanie klatek kluczowych dnia i mieszanie

- **Dla nas to nie 2–3 klatki:** słońce zimą na ok. 63°N wędruje po azymucie od ok. 120° do ok. 240° między 8:30 a 16:30, a długość cienia na metr zmienia się od 24 do 3,6 (22c §1.1) [zweryfikowane w 22c]. Plama przesuwa się o dziesiątki–setki px, więc krzyżowe mieszanie dwóch klatek daje dwie półprzezroczyste plamy zamiast jednej ruchomej [wniosek].
- **Ile klatek:** żeby ghosting był < 3 px, trzeba ok. 8–16 klatek na dzień na okno [wniosek]. Przy 21–50 pomieszczeniach: 50 × 12 × tekstura plamy 256×128 px, 8 bitów = ok. 20 MB surowo [wniosek]; da się, ale i tak trzeba mieć program, który je policzy (F offline).
- **Plusy:** zerowy koszt wykonania, pełna kontrola artystyczna (można retuszować klatki), pewne na słabym sprzęcie. **Minusy:** każda zmiana okna, mebla lub kierunku mapy (F1 „Góra ekranu” z ticketu 27: 4 orientacje!) wymaga przepiekania.
- **Elsinore robi odmianę:** pary tekstur „światło” i „cień” na malowany obiekt, mieszane mapą cienia [zweryfikowane]. U nas to podwojenie assetów graficznych (×2 generacji), więc nie.
- **Ocena:** nie jako system, ale jako **zapasowy wariant wydajnościowy** dla F (pieczemy wynik tylko wtedy, gdy telemetria pokaże problem) [wniosek].

### 4.6 Lepsze podejście: wariant F, analityczna mapa światła w płaszczyźnie (hybryda 2 i 4)

- **Idea [wniosek, spokrewniona z Blessings of the Forge i z 22c §6.9]:** nie renderujemy sceny 3D. Dla każdego piksela **podłogi** (i osobno każdej ściany) shader liczy punkt `P` w metrach z odwrócenia naszego rzutu `(x, d, 0)`, rzuca promień do słońca i sprawdza: (1) przecina płaszczyznę ściany okna w prostokącie któregoś **skrzydła** (nie ramy, nie mullionu), (2) omija **pudełka** (meble, ścianki działowe) przez test przecięcia promienia z AABB. Wynik 0/1 + 1 px wygładzenia; rysowane jako plama o twardych brzegach w trybie ADD w kolorze słońca. Ta sama funkcja z innym `P` na ścianach (ściana w słońcu lub w cieniu mebla).
- **Uniformy:** do ~8 okien × ≤6 skrzydeł, ≤16–32 pudełek w oglądanym pokoju: tablica uniformów, jedno przejście na pokój w pole widzenia.
- **Smuga w powietrzu:** to pryzmat między szybą a plamą; rysowany dalej wielokątem (jak `BeamCanvas`) **z tych samych danych**, ale per skrzydło i przycinany blokerami; zanik z odległością i szerokość zgodna z plamą (ten sam rzut), więc smuga nie zwęża się i nie gubi mullionu (47 §1) [wniosek].
- **Okna dolne i boczne:** ta sama funkcja; różni się tylko ściana (parametr), brak drugiej ścieżki kodu. Czytelność: trzeba sygnału okna (ościeże światła na podłodze przy krawędzi, pas światła na ścianie obok), czego F nie wymyśli sam [wniosek].
- **Ruch przez dzień:** ciągły, bo to funkcja `sun_direction`; pełny, bez klatek. Zalecane: przeliczać plamę co 2–5 minut gry, żeby mullion nie „migotał” krokiem 1 px [wniosek].
- **Zgodność z ulicą:** ten sam `SunSample`; fasada w słońcu lub w cieniu = ta sama bramka `facing`; cienie budynków na ulicy jako wariant: pudełka budynków wytłoczone wektorem słońca (dokładnie to robi Blessings of the Forge dla masek) [zweryfikowane]. Smugi powietrza nie widać z zewnątrz (okno to mała plama); widać światło szyby i ewentualnie plamę przez otwarte drzwi (ADR 0007: stała ekspozycja) [wniosek].
- **Brzeg domu w czerni (ticket 29):** F nie rozwiązuje, ale daje jedną mapę światła w przestrzeni liniowej, gdzie można pomnożyć światło przez gładką funkcję odległości od krawędzi pokoju zamiast pasów alfa na wierzchu [wniosek].
- **Koszt:** warstwa danych (wspólna z 4.2) 6–8 h; shader podłogi 8–12 h; ściany 4–6 h; podpięcie skrzydeł z istniejącego `panes` 2 h; smuga z danych 6–8 h. Razem **25–35 h** [wniosek]. Generacje 0, USD 0.
- **Wydajność:** 960×540 px × (≤8 skrzydeł + ≤32 pudełek) ≈ 2·10⁷ prostych operacji na klatkę, poniżej 1 ms na 4060 Laptop, rząd wielkości mniej niż RC [wniosek, bez pomiaru]; ma sens jako przejście tylko dla pokoi w kadrze (jak `RoomLighting`).
- **Ryzyka:** (1) integracja z istniejącym stosem `PointLight2D` (kolejność, ekspozycja) [wniosek]; (2) pokój w widoku z kilkoma sąsiadami; (3) pikselowe przesuwanie krawędzi, jak wyżej; (4) brak prawdziwej mgły (smuga zostaje rysowana).

## 5. Tabela porównawcza

Skala: ++ bardzo dobrze, + dobrze, 0 neutralnie, − źle, −− bardzo źle. Godziny to prototyp [wniosek].

| Podejście | Wygląd smugi i plamy z ramą | Pixel perfect | Wydajność 4060 / słabszy sprzęt | Koszt per asset | Koszt kodu | Ryzyko | Wpływ na Przepisy |
|---|---|---|---|---|---|---|---|
| 1. Światła 2D Godota | smuga/plama: ścięty cookie jak dziś (0); okluder słońca: −− (nieskończone cienie) | + (viewport 960×540) | ++ / ++ | normalne 36–200 gen. (nieobowiązkowe dla słońca) | 4–6 h | niskie | mapy normalnych mebli (ticket 22) |
| 2. Ukryta makieta 3D | + prawdziwa plama, cień mebla, mgła wolumetryczna: ++ | 0 (kwantyzacja, migotanie cienia) | + / − (mgła) | obrys + wysokość mebla, 0 gen. | 35–55 h | średnie-wysokie | dopisek do mebli i pomieszczeń |
| 3. Pełne 3D / HD-2D | ++ | − | + / + | modele lub płaszczyzny wszystkiego | 200–400+ h | wysokie | przepisanie wszystkich |
| 4. Głębia / SDF / RC | SDF: 0; RC: miękkie, ++ GI | 0 | 0 / −− (5–6 ms RC) | głębia per sprite lub pudełka | RC 40–80 h | wysokie | głębia per asset (RC) |
| 5. Klatki kluczowe | + z 10+ klatkami, −− z 2–3 | ++ | ++ / ++ | brak, ale ponowne pieczenie | 10–15 h + program pieczący | niskie | brak, ale każda zmiana = przepieczenie |
| **F. Analityczna mapa światła** | **+ plama z ramą i cieniem mebla, smuga z danych** | **+** | **++ / +** | **obrys + wysokość mebla, otwory okien (0 gen.)** | **25–35 h** | **niskie-średnie** | **dopisek do mebli, pomieszczeń i fasad** |

## 6. Wpływ na Przepisy i Miesiąc produkcji

[wniosek, na podstawie inwentarza 05/64: 120–660 mebli, 21–50 pomieszczeń, 16–34 fasady]

- **Meble (Przepis mebli):** dwa pola metadanych `footprint_m` (obrys) i `height_m`; domyślne z rozmiaru sprite'a i tabeli typów (stół, szafa, łóżko, krzesło), człowiek poprawia wyjątki. 660 × ~0,5 min ≈ 5–6 h przeglądu; zwykle mniej.
- **Pomieszczenia:** lista otworów okien w metrach i skrzydła (z konfiguracji kodu); 50 × ~5 min ≈ 4 h.
- **Fasady:** te same otwory co w pomieszczeniu (kolumny okien zgodne, ticket 11); 34 × ~5 min ≈ 3 h.
- **Generacje i USD:** 0 (poza opcjonalnymi mapami normalnych z ticketu 22).
- **Postacie:** bez zmian; mapa normalnych pozostaje osobną sprawą (ticket 22). Cień postaci w plamie: postać jako pudełko lub kapsuła w tej samej funkcji [wniosek].
- **Miesiąc produkcji:** nie zmienia limitu subskrypcji; dodaje ok. 10–15 h pracy człowieka i Claude'a na metadane, głównie skryptem [wniosek].

## 7. Rekomendacja: co prototypować na Poligonie Dom obok obecnego

1. **Wariant F (analityczna mapa światła w płaszczyźnie)** jako przełącznik F1 „Słońce okien: ręczne / dynamiczne”. Najpierw tylko podłoga, plama z ramą, wszystkie ściany, cień jednego mebla; potem smuga z danych. To odpowiada na pytanie człowieka najtaniej i daje warstwę danych (`SunGeometry`: okna, skrzydła, pudełka) potrzebną każdemu innemu wariantowi.
2. **Wariant 2 (ukryta makieta 3D z prawdziwym słońcem i mgłą)** jako drugi przełącznik, korzystający z tej samej warstwy danych: ocena „czy smuga z mgły jest warta kosztu i migotania”. Najpierw kamera pochylona 31° i kwantyzacja, mgła na końcu. Kryterium odrzucenia: migotanie lub banding bez ładnego strojenia po jednej sesji.
3. **Nie robić** pełnego 3D, RC/GI i 2–3 klatek kluczowych. Wariant 5 zostawić jako zapas wydajnościowy (pieczenie F offline), jeśli pomiar na słabszym sprzęcie pokaże problem.
4. **Zakres oceny przez człowieka (na żywo w Poligonie, nie na zrzutach):** plama z ramą dla okna tylnego, bocznego i dolnego przy 4 orientacjach mapy; ruch 8:30–16:30; cień mebla; porównanie z `game1-proto` (zwężające się smugi, nocny rzut okna) jako wzorzec jakości.
5. **Osobno, nie z tego researchu:** sygnał okna w ścianach dolnej i bocznej (ościeże, rama przy krawędzi kadru) i wygaszenie brzegu (ticket 29) to decyzje wizualne człowieka; dynamika im tylko dostarcza dane.

## 8. Czego nie zweryfikowałem

- Nie znalazłem devlogu ani talku pokazującego **dynamiczne smugi słońca przez okno w pixel arcie**; Eastward ma je opisane tylko jednym zdaniem, bez techniki.
- Nie czytałem materiałów samego t3ssel8r (YouTube); opieram się na rekonstrukcji w Godocie (Holland).
- Strony Xenosis nie pobrałem (wynik wyszukiwarki); Blessings of the Forge i xDasher czytałem, ale nie uruchamiałem.
- Liczby wydajności 2, F i RC dla RTX 4060 Laptop to szacunki, bez pomiaru; jedyne twarde liczby to 1,7 ms (god rays, GTX 1060 laptop) i 1,85/7,67 ms (HRC, RTX 3080 Laptop).
- Nie czytałem oficjalnych notatek wydania Godota 4.7; „brak nowych funkcji światła 2D” oparte na streszczeniach.
- Nie sprawdziłem w praktyce, czy pochylona kamera ortogonalna 31° z korektą osi X wiernie odtwarza nasz rzut 0,60 (rachunek poprawny na papierze).
- Licencje modeli głębi (Depth Anything) z pamięci, do sprawdzenia przed użyciem.
- Wiarygodność cen Pixellab: z ticketów 17/22 (map), nie sprawdzano ponownie; żadna generacja nie została uruchomiona.
