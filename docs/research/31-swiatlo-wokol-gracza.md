> Kopia z game1 (`repo/game1/docs/research/31-swiatlo-wokol-gracza.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Światło wokół gracza nocą w plenerze

Ticket: `docs/wayfinder/tickets/31-swiatlo-wokol-gracza.md`. Data researchu i dostępu do źródeł: **2026-10-29**. Słownictwo (reguła ekspozycji `X`, maski przestrzeni, `LightFixture`, rim, `floor_lux`) jak w `22c-gra-swiatla.md` i `22d-balans-swiatla-i-skalowanie.md` §3.7.

**Jakość źródeł.** O „świetle wokół gracza” twórcy prawie nie piszą. Godot ma dokumentację pierwotną. O grach mam głównie wiki fanów, recenzje i fora. Oznaczenia: **[dok]** dokumentacja silnika, **[twórca]**, **[wiki]**, **[recenzja]**, **[gracze]**, **[wniosek]** (moje). Strony wiki Diablo, Stardew i Spelunky zwracały 403/402, więc cytuję je z wyciągów wyszukiwarki i oznaczam to.

## Streszczenie

- **Gotowego wzorca „subtelna poświata bez uzasadnienia” u znanych gier śledczych i horrorów nie znalazłem.** Gry z ciemnością jako mechaniką (Don't Starve, Darkwood, Hollow Knight, Project Zomboid) celowo **nie** dają graczowi światła. Gracz musi je zdobyć (latarka, lampion, pierścień). Gry, które dają światło „za darmo”, robią to jako statystykę postaci (Diablo I/II: promień światła) albo przez ogólnie jaśniejszą noc.
- **Najbliższa analogia to kino:** „Obie light”, czyli mała lampa przy obiektywie, która dodaje życia twarzy. Widz jej nie zauważa, jeśli jest słaba i nieregularna. To jest dokładnie nasz przypadek: światło bez źródła w świecie, akceptowane, bo niewidoczne jako źródło.
- **Odbiór:** zbyt ciemna noc to częsta skarga (Project Zomboid: „night is too dark… very unrealistic”). Ciemność jako mechanika jest chwalona tylko wtedy, gdy jest zagrożeniem (Darkwood). U nas noc nie jest mechaniką strachu, więc czytelność ma pierwszeństwo **[wniosek]**.
- **Rekomendacja dla Godota:** `PointLight2D` jako dziecko gracza, energia z reguły ekspozycji (np. 0,5–1 lx „własnego” światła), maska = bit postaci gracza (+ ewentualnie bit podłogi bieżącej przestrzeni). Reguła sama gasi to światło we wnętrzach (1 lx przy 250 lx to ~0,4%), a w nocnym plenerze daje ~10–15% ambientu. Do tego rim z 22c §6.7. Winieta ekranowa tylko jako dodatek nastrojowy, nie jako źródło czytelności.

## 1. Jak robią to gry

| Gra | Widok | Co dostaje gracz nocą bez źródła | Uzasadnienie w świecie | Źródło |
|---|---|---|---|---|
| Don't Starve | 3/4 z góry | Nic. Całkowita ciemność = atak Charlie (100 HP) po 5–10 s, −50 poczytalności/min; bez światła nie można podnosić przedmiotów. | Ciemność jest potworem | **[wiki]** [Charlie](https://dontstarve.wiki.gg/wiki/Charlie), [All About Night](https://dontstarve.wiki.gg/wiki/Guides/All_About_Night) |
| Darkwood | z góry | Stożek widzenia; poza nim obraz odbarwiony i zaciemniony, nocą „inky blackness”. | Horror; rzeczy poza światłem są niewidoczne | **[recenzja]** [Destructoid](https://www.destructoid.com/review-in-progress-darkwood/), [Critical Hit](https://criticalhit.net/gaming/darkwood-review-strangers-in-the-night) |
| Hollow Knight | z boku | W ciemnych strefach (Deepnest) bez lampionu prawie czarny ekran; lampion rozjaśnia otoczenie Rycerza. | Lampion z robaczkami (przedmiot) | **[wiki]** [Lumafly Lantern](https://hollowknight.wiki/w/Lumafly_Lantern). Czy Rycerz ma własną słabą poświatę: **nie potwierdziłem** |
| Project Zomboid | izometria | Ciemność ustawiana w opcjach sandbox („Darkness during night”); cecha Cat's Eyes; latarki. | Brak, ustawienie trudności | **[wiki/poradnik]** [PZFans](https://pzfans.com/how-to-turn-on-night-vision-in-project-zomboid/); **[gracze]** [Steam](https://steamcommunity.com/app/108600/discussions/0/2806204040002544776) |
| Stardew Valley | 3/4 z góry | Noc w plenerze jest przyciemniona, ale nie czarna. Światło wokół gracza dają pierścienie: Small Glow Ring (promień 5 pól), Glow Ring (10 pól), sumują się. | Przedmiot (pierścień) | **[wiki, z wyciągu wyszukiwarki]** [Glow Ring](https://stardewvalleywiki.com/Glow_Ring), [Small Glow Ring](https://www.stardewvalleywiki.com/Small_Glow_Ring) |
| Diablo I/II | izometria | **Każda postać ma bazowy promień światła** (D2: 13, maks. 18), zmieniany przedmiotami; w D1 promień wpływał na to, które potwory się budzą. W D3 mechanikę usunięto. | Brak; po prostu statystyka postaci | **[wiki, z wyciągu]** [Diablo Wiki: Light radius](https://di.diablowiki.net/Light_radius), [Lurker Lounge](https://lurkerlounge.com/forums/thread-11298.html) |
| Core Keeper | z góry | Brak darmowego światła; latarnia w slocie „light” daje „weak passive glow”. „Visibility is an element of gameplay, you don't get it for free.” | Przedmiot | **[gracze]** [Steam](https://steamcommunity.com/app/1621690/discussions/0/3271311587255803043) |
| Octopath Traveler II | HD-2D | Noc w miastach niosą latarnie i okna; lampion (merch i w grze) dotyczy jaskiń. Poświaty gracza w miastach **nie potwierdziłem**. | Praktyczne źródła w scenie | **[recenzja]** [QuestDaily](https://questdaily.com.au/review/octopath-traveller-2-modern-nostalgia/), [Siliconera](https://www.siliconera.com/new-octopath-traveler-2-merchandise-will-light-your-way/) |

Nie sprawdziłem, bo nie znalazłem źródeł: Eastward, Children of Morta, Death Trash, Sea of Stars, Kentucky Route Zero (22c §7–8 też nie znalazł źródeł o technice dla większości z nich). Nie przypisuję im tej techniki.

Mniejsze przykłady od twórców:
- **Dev Log #10 (Medium):** pierwsza wersja to stałe koliste wycięcie w ciemności na środku ekranu jako „torchlight around the player”. Potem zastąpione warstwą ciemności z „dziurami” dla wielu świateł. **[twórca, z wyciągu; strona 403]** [Medium](https://medium.com/@aleechuan/dev-log-10-lighting-c3d0c5d3ebb1)
- **xDasher (Unity):** shader rim, który znajduje skrajne piksele sprite'a i barwi je według światła, które do nich dociera: „a little outline of light around him, that gives him even more depth”. **[twórca]** [itch.io devlog](https://pixel-beef.itch.io/xdasher/devlog/192949/4-things-we-did-to-add-light-and-depth-to-our-pixel-art-game)
- **Lumiflip:** aktualizacja „brighter nights” rozjaśnia noc i jaskinie, żeby gracz zawsze widział drogę, a pochodnie dalej świecą. **[twórca, z wyciągu]** [itch.io devlog](https://d-sz.itch.io/lumiflip/devlog/1730769/update-a-bigger-hero-wall-flips-momentum-and-brighter-nights)

### 1.1 Wzorce

1. **Ciemność jako mechanika** (Don't Starve, Darkwood, Hollow Knight, Core Keeper): światło jest zasobem, gracz go nie ma za darmo.
2. **Światło jako statystyka postaci** (Diablo I/II): okrąg światła wokół bohatera bez uzasadnienia. Gracze go nie kwestionowali; w D2R narzekają raczej, że nic nie robi ([forum Blizzarda](https://us.forums.blizzard.com/en/d2r/t/light-radius-is-absolutly-useless/80273)).
3. **Jasna noc + praktyczne źródła** (Stardew, Octopath II, Lumiflip): noc czytelna dzięki ambientowi i latarniom, a dodatkowe światło gracza jest nagrodą (pierścień).
4. **Rim / obrys** (xDasher, nasz prototyp 22c §6.7): sylwetka czytelna bez oświetlania otoczenia.

## 2. Uzasadnienie w świecie i odbiór

- **Kino: Obie light.** Mała lampa przy obiektywie, nazwana od Merle Oberon (*The Lodger*, 1944, operator Lucien Ballard). Dziś „many cinematographers still refer to any on-camera light as an Obie”. Ma dawać blask w oczach, a nie oświetlać twarz. Słaba, poza osią, o nieregularnym kształcie jest odbierana jako naturalna i „largely doesn't notice[d]”. Förderer celowo pomijał ją u części postaci, żeby wyróżnić jedną. **[ASC]** [American Society of Cinematographers: Eye Lights](https://theasc.com/blog/shot-craft/eye-lights), [Wikipedia: Lucien Ballard](https://en.wikipedia.org/wiki/Lucien_Ballard). Legenda o pochodzeniu jest niepewna (ASC nazywa ją „cinema legend”).
- **Wniosek dla nas [wniosek]:** światło gracza nie potrzebuje uzasadnienia, jeśli nie widać go jako źródła. Widać je wtedy, gdy na śniegu pod graczem pojawia się wyraźny okrąg, który chodzi za nim. Dlatego światło powinno padać głównie na postać, a na podłogę słabo, szeroko i bez ostrej krawędzi. Śnieg (albedo ~0,8–0,9, 22d §3.7) zdradza okrąg najszybciej.
- **Uzasadnienia, gdyby było potrzebne [wniosek]:** odbicie łuny i latarń od śniegu (fizycznie śnieg doświetla postać od dołu, więc lekkie doświetlenie dołu sylwetki jest wiarygodne), odblask kurtki albo papieros i ekran telefonu jako chwilowe praktyczne źródło. W noir to klasyka, ale to już decyzja artystyczna.
- **Odbiór przez graczy:** zbyt ciemna noc jest częstą skargą, nawet w grze o przetrwaniu: „night is too dark. To the point that its very unrealistic”, „I can't see well not even the dang rope to climb”. Gracze piszą też o problemie dostępności: obraz żony „nearly black”. **[gracze]** [Steam, PZ](https://steamcommunity.com/app/108600/discussions/0/2806204040002544776). Recenzje Darkwood chwalą ciemność jako źródło grozy, ale krytykują nawigację w ciemnym lesie jako „much more frustrating… than it really needs to be” **[recenzja]** [Nintendo World Report](https://nintendoworldreport.com/review/50565/darkwood-switch-review). Recenzji, która krytykowałaby poświatę gracza jako psującą klimat, **nie znalazłem**.

## 3. Godot 4: fakty z dokumentacji

- `Light2D.range_item_cull_mask`: światło działa tylko na elementy z pasującym `CanvasItem.light_mask`. `DirectionalLight2D` maskę ignoruje. `range_z_min/max` filtruje po z. **[dok]** [Light2D](https://docs.godotengine.org/en/stable/classes/class_light2d.html)
- `blend_mode`: `ADD` (domyślny), `SUB`, `MIX` (interpolacja liniowa z tym, co pod spodem). **[dok]** jw.
- `height` działa tylko na normal mapy; przy domyślnej niskiej wysokości powierzchnie z normal mapą są prawie nieoświetlone, trzeba ją podnieść. Rozmiar światła = tekstura × `texture_scale`; większe światło kosztuje więcej, bo obejmuje więcej pikseli. Własny spadek przez radialny `GradientTexture2D`. **[dok]** [2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)
- Shader `canvas_item`: własna funkcja `light()` zastępuje wbudowaną, ma `LIGHT_COLOR`, `LIGHT_ENERGY`, `LIGHT_POSITION`, `LIGHT_DIRECTION`, `NORMAL`, wyjście `LIGHT`. **Nie ma wbudowanej informacji, które to światło** (brak id ani maski), więc rim w shaderze nie odróżni „światła gracza” od latarni inaczej niż przez maskę. `render_mode unshaded` wyłącza `light()`. **[dok]** [CanvasItem shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html)
- Limit **16 świateł na element canvas** (`MAX_LIGHTS_PER_ITEM`, 22c §5.6). Światło gracza zajmuje jedno miejsce na każdym elemencie, którego dotyka. Na zatłoczonej ulicy z latarniami trzeba to wliczyć **[wniosek]**.

## 4. Opcje implementacji przy naszym zestawie

**Liczby z reguły (moje obliczenia, wzór z ticketu 30):** `X = clamp((250 / L)^0,7; 0,25; 8)`. Noc na ulicy: `L ≈ 5–10 lx` → `(250/7)^0,7 ≈ 12` → `X = 8` (górny próg). Światło gracza `lux_p = 1 lx` daje ~1/7 ≈ 14% oświetlenia przestrzeni, czyli subtelne, ale widoczne. We wnętrzu (`L ≈ 250`, `X ≈ 1`) to samo 1 lx to ~0,4%, czyli niewidoczne. **Reguła ekspozycji sama wyłącza „oszustwo” tam, gdzie jest jasno**, bez osobnej logiki pory dnia.

### A. `PointLight2D` jako dziecko gracza, maska tylko na postać gracza (zalecane na start)

- Węzeł `PlayerGlow` (`PointLight2D`) w scenie gracza, tekstura radialna współdzielona (22c §5.6), `height` 30–60 (żeby normal mapa postaci dała modelowanie), kolor chłodny jak ambient „śnieg i łuna” albo lekko cieplejszy, jeśli ma pomóc oddzielić postać od tła.
- `range_item_cull_mask` = osobny bit `PLAYER` (sprite gracza ma ten bit w `light_mask`). Nie świeci na podłogę ani na sąsiednie przestrzenie, więc **nie koliduje z kolorowaniem masek przestrzeni** (22c §5.6 pkt 3).
- `energy = lux_p × X_przestrzeni × K_GLOW`; `X` podaje dyrektor światła przy zmianie przestrzeni lub godziny (call down: dyrektor → gracz → `PlayerGlow`). Bez liczenia co klatkę.
- Plusy: tanie, nie zdradza się okręgiem na śniegu, działa z normal mapami. Minusy: postać lekko „odkleja się” od otoczenia (świeci, a podłoga pod nią nie). Łagodzi to cień kontaktowy i mała energia.

### B. Jak A, plus słabe szerokie światło na podłogę bieżącej przestrzeni

- Drugi `PointLight2D` (jedno światło ma jedną energię, więc „ten sam z dwoma bitami maski” dałby podłodze tyle samo co postaci): duży, bardzo miękki radialny spadek, `lux` 3–5× niższy niż na postaci, maska = bit podłogi **przestrzeni, w której stoi gracz**. Dyrektor przestawia maskę przy zmianie przestrzeni (próg drzwi ma oba bity, 22c §5.6 pkt 3).
- Plusy: gracz widzi najbliższe otoczenie (ślady na śniegu, przedmioty). Minusy: ryzyko widocznego okręgu na śniegu; przy przejściu dom/ulica zmiana maski może błysnąć. Kontrola: podgląd porównawczy (pamięć „decyzje wyglądu przez porównanie”).

### C. Rim / obrys bez oświetlania otoczenia

- Rim z 22c §6.7 (mały `PointLight2D` nad postacią, maska = postacie, normal mapy dają krawędź) lub shader obrysu jak w xDasher. W Godocie obrys nieoświetlany najprościej jako osobny sprite-dziecko z `unshaded` i `ADD`, z siłą od tego samego `X` **[wniosek]**, bo `light()` nie wie, które światło jest które.
- Plusy: sylwetka czytelna na każdym tle, zgodne z noir (kontrświatło). Minusy: sam obrys nie pokaże twarzy ani otoczenia; za mocny wygląda jak efekt wyboru postaci.

### D. Winieta ekranowa wokół gracza

- `CanvasLayer` z `ColorRect` i shaderem: przyciemnienie krawędzi ekranu (MUL) albo rozjaśnienie wokół pozycji gracza na ekranie.
- Plusy: jeden przebieg, zero świateł w limicie 16. Minusy: **ignoruje maski i przestrzenie** (rozjaśnia też ściany, okna i wnętrza w kadrze), nie zna normal map, przy kamerze śledzącej gracza to zwykła winieta. Jako przyciemnienie krawędzi podnosi względny kontrast środka, ale samo nie czyni gracza czytelnym. Nadaje się na nastrój, nie na rozwiązanie.

### E. Bez światła gracza: jaśniejszy ambient nocy

- Podnieść `floor_lux` i udział ambientu w plenerze (22d §3.7), jak Stardew i Lumiflip. Plusy: zero nowych węzłów. Minusy: cała noc traci kontrast i plamy latarń słabną względnie, co uderza w klimat noir.

## Opcje do decyzji

1. **A (światło tylko na postać, z reguły ekspozycji) + rim z C.** Najtańsze i bez ryzyka okręgu na śniegu. Moja rekomendacja na pierwszą próbę.
2. **A + B (dodatkowo słaba plama na podłogę bieżącej przestrzeni).** Lepsza czytelność otoczenia kosztem ryzyka widocznego okręgu i przełączania maski.
3. **E (jaśniejsza noc, bez światła gracza).** Najprostsze, ale płaszczy noc.
4. **D (winieta)** tylko jako dodatek nastrojowy do 1–3.

Do ustalenia przez człowieka: `lux_p` (proponuję zacząć od 0,5 / 1 / 2 lx na arkuszu porównawczym), barwa (ambient vs cieplejsza) i czy NPC też dostają poświatę (Förderer: brak u innych wyróżnia jedną postać).
