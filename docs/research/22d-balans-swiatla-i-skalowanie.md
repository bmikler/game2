> Kopia z game1 (`repo/game1/docs/research/22d-balans-swiatla-i-skalowanie.md`, stan 2026-11-03). Ścieżki i numery notatek odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Nic z §6 nie zostało tam uruchomione w całości. Wnioski dla game2 są w `docs/grafika.md`.

# Balans światła dziennego i sztucznego, koszt świateł 2D i zestaw do oświetlania pokoi (Godot 4.7 2D)

Ticket: `docs/wayfinder/tickets/22-pipeline-assetow.md` (pokój socjalny w docelowej grafice). Data researchu i dostępu do źródeł: **2026-10-28**. Wejście: `prototype/lighting/room.gd` (repo `game1-proto`, gałąź `prototype/oswietlenie`), `project.godot` (4.7, Forward+), ADR 0003 (wolny zegar, Przeskok) i ADR 0006 (zegar jako dziecko `Main`, jeden autoload `GameState`). Kolory (22a), układ pokoju (22b) i przepis na grę światła (22c) zakładam jako znane i nie powtarzam. Odwołania typu „22c §6.4” wskazują tamte dokumenty.

Źródła pierwotne: kod źródłowy Godota (`master`, renderer RD), dokumentacja klas w `doc/classes/*.xml`, PR i zgłoszenia na GitHubie, tabele EN 12464-1 / EN 13201-2 (z odpisów DIALux i producentów, bo norma jest płatna), wytyczne BRE/CIBSE o współczynniku światła dziennego, dokumentacja Unreal Engine o auto-ekspozycji. O tym, jak studia organizują oświetlenie (Eastward, Children of Morta, Hyper Light Drifter, Sea of Stars, Octopath), twórcy mówią mało. Cytuję to, co da się im przypisać, a resztę oznaczam jako własną obserwację albo wniosek. Liczby luksów dla Trondheim w lutym są moim szacunkiem (§1.1) i służą do proporcji, nie do pomiaru.

## Streszczenie i rekomendacja

- **Dlaczego chłodna poświata okna przy włączonych świetlówkach wygląda źle:** w rzeczywistości po zachodzie słońca okno daje na podłodze najwyżej kilka luksów, a świetlówki 200–300 lx. To 1–5% sztucznego światła, czyli o 4–7 stopni przysłony ciemniej. Oko przystosowane do świetlówek widzi to jako czerń. Szyba nadal świeci na niebiesko (patrzymy na niebo), ale **światła z okna na podłodze nie widać**. W `room.gd` energia nieba (`SKY_ENERGY` ok. 0,5) jest gaszona dopiero przez czynnik `night`, który zależy od słońca, a nie od tego, ile świateł pali się w pokoju. Z kodu wychodzi, że przy świetlówkach na pełnej mocy poduszka nieba ma ok. 25% ich energii o 17:00 i ok. 14% o 17:36 (preset „niebieska godzina”). Fizycznie powinna mieć ok. 10% o 17:00 i 1–2% pół godziny później (§1.1, §1.4).
- **Reguła (do wdrożenia w kilku linijkach):** każde źródło ma w zasobie wartość w „luksach” (świetlówka 250, niebo przy oknie = luksy na zewnątrz × współczynnik światła dziennego). Pokój, w którym stoi gracz, daje **poziom adaptacji** `L = Σ sztuczne + średnie dzienne + podłoga nocna`. Z niego liczymy **ekspozycję** `X = clamp((250 / L)^0,7; 0,25; 8)`, wygładzaną asymetrycznie: ciemniej→jaśniej szybko, jaśniej→ciemniej wolno. Wtedy `energy_i = lux_i × X × K_typu` dla każdego światła, a `CanvasModulate` i emisyjne szyby skalują się tym samym `X`. Strojenie robi się raz na typ źródła (`K_typu`), a nie dla każdej pory dnia i pokoju. Wykładnik 0,7 zostawia ciemne pokoje ciemniejszymi, czego potrzebuje noir (§1.4).
- **Godot 4.7 nie ma auto-ekspozycji dla 2D w sensie, który by nam pomógł.** `CameraAttributes.auto_exposure_*` działa tylko w Forward+ i mierzy średnią jasność ekranu. Dla noir to źle, bo ciemny z założenia pokój zostałby rozjaśniony do szarości. `Environment.tonemap_exposure` jest pojedynczym mnożnikiem przed tonemapperem. Z kodu `renderer_viewport.cpp` wynika, że w trybie tła `BG_CANVAS` warstwy do `background_canvas_max_layer` przechodzą przez pusty przebieg 3D z tonemapem, więc ten mnożnik prawdopodobnie działa na nasze 2D. To trzeba sprawdzić w prototypie (§1.5). Rekomendacja: ekspozycja liczona w skrypcie, a `tonemap_exposure` co najwyżej jako sposób jej podania.
- **Koszt świateł 2D w naszej skali jest mały na GPU i zależy głównie od tego, co robi skrypt.** Renderer dla każdego elementu canvas sprawdza na CPU wszystkie światła na ekranie (maska, zakres Z, przecięcie prostokątów), przypisuje mu do 16 świateł, a shader wykonuje pętlę po tych światłach dla każdego piksela elementu (jedno pobranie z atlasu, opcjonalnie N·L z normal mapy, cień). W 960×540 pokój socjalny to poniżej ~1 mln obliczeń światła na klatkę, czyli pomijalnie. Drogie są: **cienie** (osobny przebieg okluderów na każde światło z cieniem, PCF13 to 13 odczytów `textureGather` na piksel), **glow HDR**, **przebudowa atlasu tekstur świateł** przy każdej nowej lub podmienionej teksturze oraz `_apply_hour()` wywoływane w `room.gd` **co klatkę** z alokacjami (§2).
- **Posterunek 10–15 pokoi plus korytarz** to ok. 150–220 świateł łącznie, ale na ekranie 24 × 13,5 m mieszczą się 2–4 pokoje, czyli 30–60 świateł. Limit 256 na render i 16 na element się nie zapali, jeśli podłogi i ściany są podzielone na pokoje (22c §5.6). Ryzyka: światła z cieniem (po poprawce z PR #100302 w 4.4 jest lepiej) i skrypty pokoi poza ekranem. Pomiar: Profiler, Visual Profiler i `RenderingServer.viewport_get_measured_render_time_gpu()` na naszym `SubViewport`, przy wyłączonym V-Sync (§2.5).
- **Zestaw (kit):** `TimeOfDayProfile` (Resource z `Curve`/`Gradient` od godziny), `SunSample` (wynik na daną chwilę), `FixtureDef` + scena `LightFixture` (świetlówka, lampka, latarnia sodowa i rtęciowa), scena `WindowLight` parametryzowana prostokątem otworu i azymutem ściany, `RoomLightingProfile` (współczynnik światła dziennego, bit maski, nocna podłoga, harmonogram świetlówek) + węzeł `RoomLighting` oraz `LightingDirector` w scenie posterunku (ekspozycja, `CanvasModulate`, włączanie pokoi). Zegar w `Main` wywołuje w dół (ADR 0006). Nowy pokój to wtedy ustawienie kilku pól, bez osobnej sesji strojenia (§3, §5).
- **Maski:** test w silniku to `item.light_mask & light.range_item_cull_mask != 0`, czyli **LUB**, a nie I. „Podłoga pokoju A” wymaga więc osobnego bitu na parę (kolor pokoju, typ odbiorcy). Plan: 4 kolory pokoi × {bryły i podłoga, tylko podłoga, postacie} + kurz + rezerwa, co daje ok. 14 z 20 bitów. Postać zmienia swój bit przy przejściu przez drzwi (§3.5).
- **Na zewnątrz** `DirectionalLight2D` ignoruje `range_item_cull_mask` i oświetla wszystko na swoich warstwach canvas. Nadaje się tylko do scen, w których na ekranie nie ma wnętrz. Cienie budynków przy niskim słońcu robić jako rzutowane wielokąty MUL (jak 22c §3), latarnie jako `LightFixture`, a ekspozycja na zewnątrz wynika z tej samej reguły (pochmurny dzień ok. 5 800 lx, noc przy latarni 2–15 lx). Okna domów wieczorem świecą „same” z reguły ekspozycji (§3.7).

## 1. Światło dzienne a sztuczne we wnętrzu

### 1.1 Liczby: ile światła daje okno, a ile świetlówki

**Normy i punkty odniesienia:**
- EN 12464-1 (wartości utrzymywane na płaszczyźnie roboczej): pokoje wypoczynku („rest rooms”) **100 lx**, stołówki i aneksy kuchenne („canteens, pantries”) **200 lx**, korytarze i ciągi komunikacyjne **100 lx** (na poziomie podłogi), kopiowanie i archiwum **300 lx**, praca biurowa (pisanie, czytanie) **500 lx**. [DIALux: wnętrza biurowe](https://dialux4.support-en.dial.de/support/solutions/articles/9000080374-standard-values-for-office-interiors), [DIALux: pomieszczenia socjalne i sanitarne](https://dialux4.support-en.dial.de/support/solutions/articles/9000080379-standard-values-for-restrooms-sanitary-areas-and-first-aid-points-). Norma była nowelizowana (2011, 2021, 2023). Wartości dla tych pomieszczeń się nie zmieniły w tabelach, które widziałem, ale oryginału nie czytałem.
- Typowe wartości z tabeli Wikipedii (z podanymi tam źródłami): oświetlenie biura 320–500 lx, dzień pochmurny ok. 1 000 lx, pełne światło dzienne bez słońca 10 000–25 000 lx, bezpośrednie słońce 32 000–100 000 lx, ciemna granica zmierzchu cywilnego **3,4 lx**, pełnia księżyca 0,05–0,3 lx. [Wikipedia: Lux](https://en.wikipedia.org/wiki/Lux)
- Oświetlenie ulic w klasach P (osiedla, drogi lokalne) według EN 13201-2:2015: średnio **15 / 10 / 7,5 / 5 / 3 / 2 lx** dla P1–P6. [Performance in Lighting, EN 13201-2:2015](https://www.performanceinlighting.com/be/en/en-13201-2-2015), [Light Zoom Lumière](https://www.lightzoomlumiere.fr/article/nf-en-13201-une-nouvelle-jeunesse-en-eclairage-public/)
- **Współczynnik światła dziennego (DF)** to średnie natężenie we wnętrzu jako procent natężenia na zewnątrz pod niebem pochmurnym. Według BRE wnętrze wygląda na oświetlone dziennie przy DF ≥ 5% bez sztucznego światła albo ≥ 2% ze sztucznym. Według CIBSE LG10 poniżej 2% pokój wygląda ponuro i sztuczne światło jest w częstym użyciu. [Camden, raport daylight z cytatami BRE/CIBSE](https://camdocs.camden.gov.uk/CMWebDrawer/Record/9125363/file/document)

**Szacunek dla pokoju socjalnego, 20 lutego, Trondheim** (wysokości słońca z 22c §1.1; natężenie pod niebem pochmurnym ze wzoru empirycznego `E ≈ 300 + 21 000·sin(e)` lx, zob. §6; DF przy oknie ok. 8%, średnio ok. 2%, bo okno 2,4 × 1,4 m to ok. 11% powierzchni podłogi 7 × 4,4 m, w obu przypadkach to założenie):

| Godzina | Wysokość słońca | Na zewnątrz (poziomo, pochmurno) | Podłoga przy oknie (8%) | Średnio w pokoju (2%) | Świetlówki | Okno : świetlówki przy oknie |
|---|---|---|---|---|---|---|
| 9:00 | 5,1° | ~2 200 lx | ~175 lx | ~45 lx | 250 lx | 0,7 : 1 |
| 12:00 | 15,1° | ~5 800 lx | ~460 lx | ~115 lx | 250 lx (60 lx przy 25%) | 1,8 : 1 (7,7 : 1) |
| 16:00 | 5,6° | ~2 400 lx | ~190 lx | ~50 lx | 250 lx | 0,8 : 1 |
| ~17:00 (zachód) | 0° | ~300 lx | ~24 lx | ~6 lx | 250 lx | 0,1 : 1 |
| ~17:45 (koniec zmierzchu cywilnego) | −6° | 3,4 lx | ~0,3 lx | <0,1 lx | 250 lx | 0,001 : 1 |
| noc, latarnia przed oknem | — | 2–15 lx na ulicy | <1 lx | <0,3 lx | 250 lx | <0,004 : 1 |

Bezpośrednie słońce w plamie z okna (przy przejaśnieniu) to inny rząd wielkości. Natężenie na podłodze to `E_n · sin(e)`, gdzie `E_n` jest natężeniem prostopadłym do promieni. Przy niskim słońcu i nawet kilkunastu tysiącach luksów `E_n` daje to na podłodze **tysiące luksów**, czyli kilka do kilkunastu razy więcej niż świetlówki (szacunek, §6). **Plama słońca przebija świetlówki, a poświata nieba nie.** Tak to wygląda w rzeczywistości i tak powinno wyglądać w grze.

### 1.2 Jak działa adaptacja oka

- W danym stanie adaptacji oko rozróżnia kontrast ok. **1 000 : 1**. Cały zakres (od gwiazd do słońca) to ok. 9 rzędów wielkości, osiągany przez przesuwanie „punktu czerni”. Ciemnienie trwa długo: pełna adaptacja od słońca do ciemności to ok. 20–30 minut, czopki odzyskują czułość po ok. 10 minutach, pręciki później. Jaśnienie działa w sekundach (artykuł podaje też 5 minut, niekonsekwentnie). Źrenica zmienia ilość światła tylko ok. 10×. [Wikipedia: Adaptation (eye)](https://en.wikipedia.org/wiki/Adaptation_(eye)) (z odwołaniami do Britanniki 1987 i Jackson i in. 1999)
- Postrzegana jasność jest w przybliżeniu logarytmiczna: jeden stopień przysłony (×2) to podobny skok niezależnie od poziomu. Dlatego stosunek 1 : 25 (okno o zmierzchu do świetlówek) to ok. −4,6 EV. Dla oka przystosowanego do świetlówek jest to głęboki cień na granicy czerni, a nie „trochę słabsza niebieska poświata”.
- **Wniosek:** kiedy pali się sztuczne światło, poziom adaptacji wyznaczają świetlówki. Udział okna w oświetleniu pokoju wynosi wtedy `E_okna / E_adaptacji` i od tego (a nie od pory dnia) powinna zależeć jego energia w grze. Szyba to co innego: patrzymy na jasność nieba, nie na światło w pokoju. O 17:30 niebo wciąż ma luminancję porównywalną z oświetloną ścianą, więc szyba zostaje widocznie niebieska, a podłoga pod oknem już nie.

### 1.3 Jak to rozwiązują malarze, filmowcy i gry

- **Malarstwo:** Gurney (cytowany w 22c §1.4–1.5) maluje pokój ciemniej, a widok za oknem jaśniej, niż widzi oko, i zestawia chłodne okno z ciepłymi lampami. To jest ręczna „ekspozycja na wnętrze”. Nic nowego ponad 22c.
- **Film: okno w zakresie ekspozycji wnętrza.** Na planie nie podkręca się okna, tylko je przyciemnia. Rolki ND na szyby (np. Rosco N.3 = 1 stopień, 50% transmisji; N.6 = 2 stopnie, 25%), łączone z konwersją barwy (Sun 85N.6: konwersja dzień→3200 K plus 2 stopnie ND). Ich cel to sprowadzenie światła zewnętrznego do zakresu ekspozycji wnętrza. Wariant regulowany to polaryzator na szybie plus polaryzator na obiektywie. [Rosco N.6 (sklep)](https://amp.filmandvideolighting.com/rosco-cinegel-3403-nd-6-neutral-density-window-gel-roll-extra-wide.html), [Rosco N.3](https://www.adorama.com/ro3402.html), [Rosco VIEW](https://www.filmandvideolighting.com/roviadwinede.html). To odpowiednik naszego `X`: ekspozycja ustawiona na wnętrze, a okno ląduje w niej tam, gdzie wynika z proporcji.
- **Film: „practical” a motywowany key.** Konwencja zdjęciowa (wiedza ogólna, bez pierwotnego źródła): w nocnym wnętrzu praktyczne źródła (lampy w kadrze) są motywacją i często kluczem, a okno jest chłodnym konturem albo tłem. Za dnia okno motywuje klucz, a praktyczne lampy są ciepłym akcentem. Kluczem jest to źródło, które dominuje poziom adaptacji. To samo pytanie zadaje nasza reguła.
- **Gry: auto-ekspozycja (eye adaptation).** Unreal mierzy średnią luminancję ekranu (histogram 64 przedziały albo średnia z downsamplingu), trzyma ją w zakresie `Min/Max EV100`, ma osobne prędkości adaptacji **Speed Up** (z ciemnego do jasnego) i **Speed Down** (z jasnego do ciemnego), kompensację w stopniach i maskę pomiaru, która waży np. środek ekranu. [Unreal Engine: Auto Exposure](https://dev.epicgames.com/documentation/en-us/unreal-engine/auto-exposure-in-unreal-engine). Klasyczny operator Reinharda mapuje średnią logarytmiczną luminancję sceny na „klucz” (domyślnie 0,18, szarość średnia), niższy klucz dla scen ciemnych, wyższy dla jasnych. [Reinhard i in., Photographic Tone Reproduction for Digital Images (2002)](https://www-old.cs.utah.edu/docs/techreports/2002/pdf/UUCS-02-001.pdf). Frostbite przeszedł na jednostki fizyczne (luksy, EV100), żeby artyści nie stroili każdej sceny osobno. [Lagarde, de Rousiers: Moving Frostbite to PBR](https://seblagarde.wordpress.com/wp-content/uploads/2015/07/course_notes_moving_frostbite_to_pbr_v32.pdf)
- **Dlaczego nie pełna auto-ekspozycja z ekranu:** pomiar z ekranu „naprawia” ciemność, a w noir ciemność jest zamierzona. Do tego okno pełne nieba albo latarnia w kadrze zaniżają ekspozycję całego wnętrza. Lepiej liczyć adaptację z **wiedzy o pokoju** (co się pali i ile wpada z okien) niż z pikseli. Wynik jest deterministyczny i daje powtarzalne zrzuty do strojenia (wniosek własny).

### 1.4 Reguła dla naszej gry 2D

**Jednostki.** Każde źródło dostaje w zasobie wartość w umownych luksach (`lux`), czyli natężenie w swoim najjaśniejszym miejscu na podłodze:

| Źródło | `lux` | Skąd |
|---|---|---|
| Świetlówka (rząd pod oprawą) | 250 (auto w dzień: 60) | §1.1, 200 lx stołówka/aneks w EN 12464-1, trochę zapasu |
| Korytarz | 100–150 | EN 12464-1: 100 lx |
| Lampka biurkowa (pod kloszem) | 300–500 lokalnie | wiedza ogólna; mały zasięg |
| Poduszka nieba pod oknem | `E_out(t) × DF_near` (DF_near ≈ 0,08) | §1.1 |
| Plama słońca | `E_sun(t) × sin(e) × CLEAR` (tysiące lx) | §1.1 |
| Odbicie od plamy | 0,2–0,3 × plama × albedo podłogi | 22c §6.5 |
| Latarnia uliczna przez okno | 2–15 na ulicy × DF_near | EN 13201-2 |
| Przelew z korytarza przez drzwi | ok. 0,5 × korytarz | geometria drzwi |
| Ambient (`CanvasModulate`) | `E_day_avg + 0,3 × E_art + E_floor` | wypełnienie odbiciami |

**Adaptacja i ekspozycja** (dla pokoju, w którym stoi gracz):

```
E_art     = Σ lux_i · on_i · share_i       (share_i: jaka część pokoju dostaje to źródło, ~0,5–1)
E_day     = E_out(t) · DF_avg               (DF_avg ≈ 0,02; plus słońce · udział plamy w podłodze)
L         = E_art + E_day + E_floor         (E_floor ≈ 1–3 lx: „noc nie jest czarna”, 22a)
X_target  = clamp((L_ref / L)^α, X_min, X_max)      L_ref = 250, α = 0,6–0,75, X ∈ [0,25; 8]
energy_i  = lux_i · X · K_typu
```

- `α < 1` to **częściowa adaptacja**. Przy `α = 1` każdy pokój miałby tę samą średnią jasność, a ciemny areszt wyglądałby jak biuro. Przy `α = 0,7` pokój 10× ciemniejszy wygląda ok. 2× ciemniej (−1 EV zamiast −3,3 EV). `X_max = 8` (+3 EV) ogranicza „widzenie w ciemności”.
- `K_typu` stroi się **raz** na kształt tekstury (radialna, prostokąt świetlówki, poduszka nieba, ciasteczko okna), bo energia `PointLight2D` mnoży teksturę, a różne tekstury mają różną „masę”. Kalibracja startowa z dzisiejszego `room.gd`: świetlówka 250 lx przy `X = 1` → `energy 1,4`, więc `K_fluo ≈ 0,0056`.
- **Wygładzanie (adaptacja oka):** w logarytmie, asymetrycznie. Gdy scena jaśnieje (włączenie świetlówek, wyjście na śnieg), `X` spada szybko (τ ≈ 0,3–0,5 s). Gdy ciemnieje (zgaszenie, wejście do ciemnego pokoju), `X` rośnie wolno (τ ≈ 2–4 s). Fizjologia daje minuty, ale gra nie może tyle czekać. To ta sama asymetria co Speed Up/Speed Down w Unrealu. Przy Przeskoku (ADR 0003), teleporcie i presetach debugowych przyjąć `X = X_target` od razu.
- **Kolor ambientu:** ton mieszać według udziału, `w_art = E_art / (E_art + E_day)`: `ambient = sky_tint.lerp(art_tint, w_art) × (ambient_lux · X · K_amb)`, z nasyceniem ograniczonym jak w 22a (ambient chłodny i mało nasycony). Dziś nocą ze świetlówkami ambient jest wyraźnie niebieski `(0,24; 0,26; 0,42)`, choć pokój wypełnia światło świetlówek.
- **Szyby i widok za oknem** (`outside_*`, unshaded) skalują się tym samym `X`, ze słabszym wykładnikiem albo z dolnym progiem (np. `max(L_sky · X; 0,25)`), żeby szyba o zmierzchu przy włączonych świetlówkach została widocznie niebieska, ale ciemniejsza niż dziś. Za dnia wychodzi > 1 (glow), a nocą przy zgaszonych lampach jest jaśniejsza od wnętrza.

**Sprawdzenie na trzech przypadkach** (`α = 0,7`):
- **Południe, świetlówki auto 60 lx:** `L ≈ 60 + 115 + 2 ≈ 177` → `X ≈ 1,27`. Poduszka nieba 460 lx dominuje nad świetlówkami (7,7 : 1). Pokój jest „dzienny”, okna są najjaśniejsze (zgodnie z 22a).
- **17:00, świetlówki 250 lx:** `L ≈ 250 + 6 + 2` → `X ≈ 0,98`. Poduszka nieba 24 lx × 0,98 to ~10% świetlówki, 30 minut później ~2%. Na podłodze **znika**, szyba zostaje niebieska. To naprawia zgłoszony problem.
- **17:00, świetlówki wyłączone:** `L ≈ 6 + 2 = 8` → `X = min(11; 8) = 8`. Poduszka nieba 24 × 8 = 192 „lx efektywnych”, czyli ok. 0,8 dzisiejszej świetlówki. Pokój jest niebieski i przyciemniony, a okno staje się kluczem. To nastrój „po godzinach” z 22c §6.8, uzyskany bez osobnego strojenia.

**Plama słońca a skala:** przy `lux ≈ 2 000–5 000` i `X ≈ 0,7–1` energia wychodzi ~10–20× większa niż świetlówki, a dzisiejszy `SUN_E = 2,4` to ok. 1,7×. Nie trzeba odwzorowywać tego 1 : 1. Wystarczy łagodne kolano: `e' = e / (1 + e / e_max)` z `e_max ≈ 3–4`, albo tonemapper (§1.5). Ważne jest, żeby plama **nie gasła** przy włączeniu świetlówek. Dziś nie gaśnie, i to jest poprawne.

### 1.5 Godot 4.7: auto-ekspozycja, tonemap i HDR 2D

- **Shader 2D nie ma ekspozycji ani tonemapu.** W `canvas.glsl` jedyne globalne skalowanie koloru to `color *= canvas_data.canvas_modulation`. [canvas.glsl](https://github.com/godotengine/godot/blob/master/servers/rendering/renderer_rd/shaders/canvas.glsl)
- **Przebieg tła `BG_CANVAS`:** w `RendererViewport::_draw_viewport` warstwy canvas do `background_canvas_max_layer` są rysowane, potem (bez sceny 3D) woła się `render_empty_scene(...)`, czyli przebieg 3D z post-processingiem. Dopiero potem rysują się wyższe warstwy. [renderer_viewport.cpp](https://github.com/godotengine/godot/blob/master/servers/rendering/renderer_viewport.cpp). Dokumentacja potwierdza, że glow i blur działają na 2D tylko w trybie Canvas i że `background_canvas_max_layer` wybiera warstwy. [Environment and post-processing](https://docs.godotengine.org/en/latest/tutorials/3d/environment_and_post_processing.html). Wniosek (do sprawdzenia): `tonemap_mode`, `tonemap_exposure` i `adjustment_*` obejmują wtedy też nasze 2D. Forum zgłasza, że po włączeniu HDR 2D obraz jaśnieje, a obniżenie `tonemap_exposure` z 1 do 0,5 to korygowało, co pośrednio potwierdza działanie. U nas `post.gdshader` leży na warstwie 10 (> 0), więc nie podlega ekspozycji. To dobrze.
- **`tonemap_exposure`:** „przed tonemapperem”, mnożnik jasności. `adjustment_brightness` działa po tonemapie, a dokumentacja odradza go do jasności sceny. `adjustment_color_correction` (LUT) nie wspiera wartości > 1. [Environment.xml](https://github.com/godotengine/godot/blob/master/doc/classes/Environment.xml)
- **Auto-ekspozycja:** `CameraAttributes.auto_exposure_enabled` („tonemapping auto exposure mode of the scene renderer”), tylko w Forward+. Zasób podpina się do `Camera3D` albo `WorldEnvironment`. Prędkość i skala są parametrami, a luminancja to średnia ze wszystkich pikseli ekranu. [CameraAttributes.xml](https://github.com/godotengine/godot/blob/master/doc/classes/CameraAttributes.xml), [Environment and post-processing](https://docs.godotengine.org/en/latest/tutorials/3d/environment_and_post_processing.html). Dokumentacja nie mówi, czy działa przy tle Canvas bez kamery 3D. Nawet jeśli działa, ma wady z §1.3: mierzy piksele, a nie pokój, nie ma asymetrii prędkości i nie daje deterministycznych zrzutów.
- **Rekomendacja:** `X` liczy skrypt (`Exposure.target()` + wygładzanie). Są dwie drogi podania:
  1. **Mnożenie w skrypcie** (pewne, działa w każdym rendererze): `energy` każdego aktywnego światła, kolor `CanvasModulate` i `modulate` emiterów unshaded (szyby, smugi, kurz, śnieg za oknem). Sprite'y AO w trybie MUL **nie** skalować (to proporcje).
  2. **`Environment.tonemap_exposure = X`** (jedna linijka, obejmuje wszystko poniżej warstwy 0, łącznie z unshaded). Wymaga testu z §6. Daje wtedy za darmo tonemapper (np. AgX albo Reinhard) jako kolano dla plamy słońca.
  Zacząć od 1. Jeśli test 2 przejdzie, przenieść skalowanie globalne na `tonemap_exposure`, a w skrypcie zostawić tylko proporcje między źródłami (`lux_i · K_typu`).

## 2. Koszt i skalowanie świateł 2D w Godot 4.7

### 2.1 Jak renderer liczy światła 2D (źródło)

1. **Zbieranie świateł na klatkę (CPU, `renderer_viewport.cpp`):** dla każdego canvas brane są światła `enabled`, z ważną teksturą i z prostokątem przecinającym ekran (`clip_rect.intersects(cl->rect_cache)`). Te z `shadow_enabled` trafiają też na listę cieni, a `DirectionalLight2D` na osobne listy. Potem światła filtruje się po zakresie warstw canvas (`layer_min/max`). [renderer_viewport.cpp](https://github.com/godotengine/godot/blob/master/servers/rendering/renderer_viewport.cpp)
2. **Cienie (CPU+GPU):** jeśli jest choć jedno światło z cieniem, renderer zbiera wszystkie włączone `LightOccluder2D` przecinające obszar cieni i dla **każdego** takiego światła woła `light_update_shadow(...)`, czyli renderuje okludery do wiersza atlasu cieni. Atlas ma `rendering/2d/shadow_atlas/size` (domyślnie 2048) × `MAX_LIGHTS_PER_RENDER·2` tekseli R32F plus bufor głębi. [renderer_canvas_render_rd.cpp](https://github.com/godotengine/godot/blob/master/servers/rendering/renderer_rd/renderer_canvas_render_rd.cpp) (`_update_shadow_atlas`), [ProjectSettings](https://docs.godotengine.org/en/latest/classes/class_projectsettings.html)
3. **Limit na render:** w `canvas_render_items` światła powyżej `MAX_LIGHTS_PER_RENDER = 256` dostają `render_index_cache = -1`, czyli nie świecą. Dane świateł idą jednym `buffer_update` do bufora storage.
4. **Przypisanie świateł do elementu (CPU, `_record_item_commands`):** dla każdego rysowanego elementu canvas pętla po wszystkich światłach na ekranie z warunkiem `p_item->light_mask & light->item_mask`, `z_min ≤ z ≤ z_max` i `p_item->global_rect_cache.intersects(light->rect_cache)`. Indeksy świateł pakowane są po 8 bitów do danych instancji, a po `MAX_LIGHTS_PER_ITEM − 1` pętla przerywa (`break`). **Nadmiarowe światła są pomijane po cichu, w kolejności listy.** Zmiana zestawu świateł nie łamie batcha, ale przejście między elementem oświetlonym a nieoświetlonym (`use_lighting`) już tak. Koszt CPU to O(elementy na ekranie × światła na ekranie): przy 500 elementach i 60 światłach to 30 000 tanich testów, czyli ułamek milisekundy (szacunek).
5. **Shader (GPU, `canvas.glsl`):** najpierw pętla po światłach kierunkowych, potem `for (i < MAX_LIGHTS_PER_ITEM) { if (i >= light_count) break; ... }`. Na każde światło przypada transformacja `LIGHT_VERTEX` do UV tekstury (poza [0,1) światło jest pomijane), **jedno** `textureLod` z atlasu, przy normal mapach `N·L` z `height` jako składową z, a przy cieniu `light_shadow_compute`: Nearest = 1 odczyt, PCF5 = 5 × `textureGather`, PCF13 = 13 × `textureGather`. [canvas.glsl](https://github.com/godotengine/godot/blob/master/servers/rendering/renderer_rd/shaders/canvas.glsl)
6. **Atlas tekstur świateł:** tekstura światła jest dodawana do współdzielonego atlasu dekali (`texture_add_to_decal_atlas` w `light_set_texture`), a shader czyta ją przez `atlas_rect`. Gdy atlas jest „dirty” (nowa tekstura, usunięcie albo `texture_replace` przy `ImageTexture.set_image()`), `update_decal_atlas()` **zwalnia atlas i pakuje od nowa wszystkie tekstury** (z mipmapami i ramką). [texture_storage.cpp](https://github.com/godotengine/godot/blob/master/servers/rendering/renderer_rd/storage_rd/texture_storage.cpp). To jednorazowy koszt przy ładowaniu, ale **nie wolno** podmieniać tekstur świateł co zmianę godziny. Uwaga: w kodzie `texture_2d_update` (czyli `ImageTexture.update()`) nie oznacza atlasu jako dirty, więc zaktualizowana w miejscu tekstura światła **może się nie odświeżyć** w atlasie (§6). Dotyczy to wypiekanej plamy z 22c §6.9.
7. **Limity (`renderer_canvas_render_rd.h`):** `MAX_LIGHTS_PER_ITEM = 16`, `MAX_LIGHTS_PER_RENDER = 256`, `MAX_LIGHT_TEXTURES = 1024`, `MAX_RENDER_ITEMS = 256·1024`. [renderer_canvas_render_rd.h](https://github.com/godotengine/godot/blob/master/servers/rendering/renderer_rd/renderer_canvas_render_rd.h)

### 2.2 Co naprawdę kosztuje

| Pozycja | Koszt | Od czego zależy | Uwagi |
|---|---|---|---|
| Światło bez cienia | GPU: piksele elementów w jego prostokącie × 1 odczyt; CPU: test na element | **rozmiar prostokąta światła** (tekstura × `texture_scale`) i liczba elementów, które przecina | duże światła „wypełniające” zajmują sloty z 16 na wielu elementach |
| Normal mapy | +1 odczyt normalnej na piksel elementu (raz, nie na światło) + `N·L` na światło | rozmiar elementów | tanie |
| Światło z cieniem | + przebieg okluderów na każde światło + 1/5/13 odczytów na piksel | liczba okluderów × liczba świateł z cieniem | po PR #100302 (4.4) okludery są odrzucane per światło, a transformacje trzymane w SSBO. Autor: 330 → 430 FPS (RX), Pixel 4: 17 → 60 FPS. [PR #100302](https://github.com/godotengine/godot/pull/100302) |
| SDF (okludery z `sdf_collision`, `texture_sdf()` w shaderach) | osobny przebieg `render_sdf` | liczba okluderów | u nas nieużywane |
| Atlas świateł | przebudowa przy zmianie zestawu tekstur | liczba i rozmiar tekstur | robić raz, tekstury współdzielone |
| Glow HDR | kilka przebiegów rozmycia RGBA16 w 960×540 | `glow_levels` | prawdopodobnie największy stały koszt GPU w kadrze (szacunek) |
| `post.gdshader` z `hint_screen_texture` | kopia ekranu + pełnoekranowy shader | rozdzielczość | stały |
| Addytywne sprite'y / `Polygon2D` (smugi) | zwykły overdraw | powierzchnia | tańsze od świateł, potwierdza też forum ([forum: PointLight2D performance](https://forum.godotengine.org/t/pointlight2d-performance-and-optimization/137342)) |
| `CPUParticles2D` (kurz, śnieg) | symulacja na CPU | liczba cząstek | 60–150 to drobiazg |
| **Skrypt** (`_apply_hour` co klatkę) | GDScript + wywołania RenderingServer | liczba świateł × klatki | u nas realnie największy koszt CPU (§2.3) |

Zgłoszenia z forów są trudne do porównania: na 4.5.2 pierwsze światło miało kosztować ok. 30 FPS ze 115, kolejne po 2–3 FPS (bez opisu sprzętu i rozmiarów świateł). Odpowiedź na forum brzmiała „sprofiluj, koszt zależy od rozmiaru tekstur”. [forum](https://forum.godotengine.org/t/pointlight2d-performance-and-optimization/137342). Na Androidzie (4.1) jedno `PointLight2D` dawało spadek z 60 do 42 FPS. [#81152](https://github.com/godotengine/godot/issues/81152). Są też regresje cieni 4.2 → 4.3 (ok. 8,5 ms według jednego dewelopera), naprawione w 4.4. [itch.io](https://itch.io/post/11483622), [#99420](https://github.com/godotengine/godot/issues/99420). Szkic tych liczb: liczy się fill rate i cienie, a nie sama liczba świateł.

### 2.3 Jeden pokój (`room.gd` dziś)

Światła: `patch`, `street`, `air`, `bounce`, `sky_light`, 4 świetlówki + 2 „wash”, 2 świetlówki korytarza, `spill`, `rim`, razem **15** `PointLight2D`, bez cieni.

Przypisanie do elementów (z masek i prostokątów, szacunek):
- podłoga pokoju (280×176 px, `M_FLOOR`): `patch` albo `street`, `sky_light`, 4 świetlówki, `spill` → **~7**;
- tylna ściana (280×104 px, `M_SOLID`): `bounce`, `sky_light` (styk na krawędzi), 2 świetlówki z tylnego rzędu, 2 „wash” → **~6**;
- Badacz (`M_ACTOR`): `bounce`, `sky_light`, do 4 świetlówek, `spill`, `rim`, korytarz → **do ~10**;
- podłoga korytarza (`M_HALL`): 2 świetlówki korytarza → 2.

**GPU:** ok. 49 tys. px × 7 + 29 tys. px × 6 + reszta to poniżej 1 mln obliczeń światła na klatkę, przy jednym odczycie tekstury każde. Na dowolnym GPU z ostatniej dekady to setne części milisekundy. Glow, kopia ekranu dla `post.gdshader` i skalowanie `SubViewport` kosztują więcej niż wszystkie światła razem (szacunek do potwierdzenia pomiarem, §2.5).

**CPU (tu jest problem):** `_process()` co klatkę woła `_apply_hour()`. To ok. 40 setterów świateł i sprite'ów, interpolacje tabel, `_shear()` i `_update_beams()`, które **alokuje** `PackedVector2Array`, `Dictionary` i `PackedColorArray` na każdą z 4 szyb, liczy `convex_hull` i ustawia `Polygon2D.polygon` (ponowna triangulacja). Do tego co klatkę formatowany jest tekst HUD. Przy stojącym czasie wszystko to liczy się bez potrzeby, a w grze zegar jest wolny (ADR 0003). To łamie zasadę „nie alokować co klatkę” i przy 15 pokojach mnoży się × 15. Poprawka w §4 (punkt 2).

### 2.4 Posterunek: 10–15 pokoi plus korytarz

- **Na ekranie:** 960×540 przy 40 px/m to 24 × 13,5 m, czyli zwykle pokój gracza, 1–3 sąsiednie i odcinek korytarza. Przy ~15 światłach na pokój z oknem, ~8 na pokój bez okien i ~1 na 4 m korytarza daje to **30–60 świateł na render** (limit 256). Pozostałe ~150 świateł posterunku silnik odrzuca testem prostokąta (tani), pod warunkiem że skrypty ich pokoi nie pracują.
- **Na element:** dopóki podłoga i ściany są osobnymi elementami per pokój (albo kwadrantami `TileMapLayer`), żaden element nie zobaczy więcej niż ~10 świateł. Ryzyko to **jeden sprite podłogi na cały posterunek** i **wielkie światła wypełniające**. Ich prostokąt przecina wiele elementów, a nadmiar powyżej 16 znika po cichu.
- **Cienie:** jeśli dodamy latarkę i 2–3 lampy korytarza z okluderami, to 3–4 przebiegi okluderów na klatkę plus PCF. Dla pixel artu filtr `None` albo PCF5, i tylko na światłach, które naprawdę tego potrzebują (22c §3).
- **CPU skryptów:** pokoje poza ekranem mają `process_mode = PROCESS_MODE_DISABLED`, światła `enabled = false`, a cząsteczki `emitting = false`. Zmiana godziny trafia tylko do aktywnych pokoi. Pokoje uśpione odświeżają się przy wybudzeniu, raz.
- **Pamięć:** tekstury świateł są współdzielone (jedna na typ: radialna, świetlówka, poduszka nieba, ciasteczko na typ okna, przelew z drzwi). To kilkanaście tekstur ≤ 256 px, czyli atlas rzędu kilku MB.
- **Szacunek końcowy:** posterunek z tym przepisem powinien mieścić się w budżecie z dużym zapasem. Wymaga to dwóch dyscyplin: per-pokojowego włączania i braku per-klatkowych alokacji w skryptach. Liczby trzeba potwierdzić benchmarkiem z §2.5.

### 2.5 Jak mierzyć w naszym projekcie

- **Debugger → Profiler:** czas funkcji skryptów (`_process`, `_apply_hour`, `_update_beams`). Najpierw tu, bo CPU skryptu jest kandydatem nr 1.
- **Debugger → Visual Profiler:** czasy CPU/GPU etapów renderowania. Etapy 2D mają znaczniki `RENDER_TIMESTAMP` z kodu: „Render PointLight2D Shadows”, „Cull LightOccluder2Ds”, „Render Canvas N”, glow i tonemap w przebiegu 3D. Mierzyć z wyłączonym V-Sync (opcja `--disable-vsync` albo ustawienie projektu `display/window/vsync/vsync_mode`).
- **Debugger → Monitors** albo klasa `Performance`: czas klatki, pamięć wideo. Uwaga: `RenderingServer.get_rendering_info()` według dokumentacji „bierze pod uwagę tylko 3D” przy niektórych wartościach, np. liczbie draw calli. Dla 2D trzeba użyć wersji per viewport. [RenderingServer.xml](https://github.com/godotengine/godot/blob/master/doc/classes/RenderingServer.xml)
- **W kodzie** (nasz obraz renderuje się w `SubViewport`, więc mierzymy oba viewporty i sumujemy, jak zaleca dokumentacja):

```gdscript
func _enable_measure() -> void:
	RenderingServer.viewport_set_measure_render_time(vp.get_viewport_rid(), true)
	RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), true)


func _bench_text() -> String:
	var sub := vp.get_viewport_rid()
	var root := get_viewport().get_viewport_rid()
	var gpu := RenderingServer.viewport_get_measured_render_time_gpu(sub) + RenderingServer.viewport_get_measured_render_time_gpu(root)
	var cpu := RenderingServer.viewport_get_measured_render_time_cpu(sub) + RenderingServer.viewport_get_measured_render_time_cpu(root)
	var draws := RenderingServer.viewport_get_render_info(sub, RenderingServer.VIEWPORT_RENDER_INFO_TYPE_CANVAS, RenderingServer.VIEWPORT_RENDER_INFO_DRAW_CALLS_IN_FRAME)
	return "GPU %.2f ms  CPU %.2f ms  canvas draw calls %d" % [gpu, cpu, draws]
```

  Dokumentacja ostrzega, że przy niskim obciążeniu GPU obniża zegary i raportuje dłuższe czasy. Benchmark robić bez limitu FPS albo z wymuszonym trybem wydajności w sterowniku. [RenderingServer.xml](https://github.com/godotengine/godot/blob/master/doc/classes/RenderingServer.xml)
- **Benchmark do dopisania** (`--bench` w `room.gd` albo osobna `bench.tscn`): siatka N kopii pokoju (1, 4, 15), kamera nad jedną z nich, 300 klatek bez V-Sync, średnia i 95. percentyl GPU/CPU w wariantach: (a) wszystkie pokoje włączone, (b) tylko widoczne, (c) normal mapy wyłączone (klawisz N już jest), (d) 4 światła z cieniem PCF5/PCF13, (e) glow wyłączony. Wynik jako CSV do `shots/`.

## 3. Zestaw do oświetlania (kit): jak to poukładać

### 3.1 Jak to robią inni (co da się przypisać twórcom)

- **Eastward (Pixpil):** „zwykłe deferred shading”, które pozwala level designerowi wstawić dużo świateł i stroić ambient pod nastrój, w silniku własnym na MOAI (szczegóły i źródła w 22c §7). Wzór organizacji: wiele małych praktycznych źródeł plus ambient per lokacja.
- **Children of Morta (Dead Mage, Unity):** według wywiadu sprite'y są skalowane ok. 4× do rozdzielczości HD, a oświetlenie liczy się w tej wyższej rozdzielczości. Twórcy porównują to do teatru lalek: lalki są pikselowe, ale oświetlone prawdziwym światłem. [TechRaptor (strona zwróciła 403, treść z wyciągu wyszukiwarki)](https://techraptor.net/content/how-dead-mage-created-the-art-for-children-of-morta). Nie znalazłem źródła o tym, jak budowali światła na poziomach.
- **Sea of Stars (Sabotage, Unity):** przedpremierowa lista cech z Kickstartera mówi o w pełni dynamicznym oświetleniu sprite'ów z normal mapami, zapisie głębi pikseli i przyjmowaniu cieni oraz świetle wolumetrycznym. [Niche Gamer (2020)](https://nichegamer.com/2020/03/19/the-messenger-prequel-rpg-sea-of-stars-enters-kickstarter-launches-2022-for-pc/). Studio mówi o dynamicznym świetle i cyklu dnia i nocy wpływającym na świat. [Sabotage, komunikat](https://sabotagestudio.com/press-release/highly-anticipated-turn-based-rpg-sea-of-stars-equips-august-release-date-as-first-playable-demo-drops-today-on-nintendo-eshop/). Brak breakdownu technicznego.
- **Octopath Traveler (Acquire/Square Enix, UE4):** do efektów w walce dodano światło punktowe, żeby rzucały cienie postaci na otoczenie. [Unreal Engine spotlight](https://www.unrealengine.com/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true). Wzór: efekt = sprite + światło.
- **Hyper Light Drifter (Heart Machine, GameMaker):** nie znalazłem żadnego źródła o technice oświetlenia.
- **Społeczność Godota, Usagi Shima (devlog):** cykl dnia to trzy składniki. `CanvasModulate`, którego kolor skrypt interpoluje co minutę między kolorami dnia, nocy, wschodu i zachodu, osobny zegar UI oraz źródła światła, z których **każde ma `Light2D` samo dostosowujące energię do pory dnia** (0 w dzień, 0,5 o zachodzie, 1 nocą). [Usagi Shima, Devlog #2](https://usagishima.net/2021/04/13/devlog-2-real-time-day-night-cycle/). To typowy wzór „światło czyta zegar”. Działa, ale każde źródło ma własną krzywą, a relacji między źródłami (nasz problem z §1) nikt nie pilnuje.

**Wniosek (własny):** wszędzie powtarza się trójka globalny zegar → krzywe ambientu i nieba, źródła reagujące na harmonogram, ambient strojony per lokacja. Nasza zmiana to wstawienie między nie **ekspozycji z poziomu adaptacji**. Wtedy „strojenie per lokacja” sprowadza się do fizycznie sensownych liczb (DF, luksy opraw), a nie do ręcznie dobranych energii na każdą porę.

### 3.2 Czas i słońce: `TimeOfDayProfile` (Resource) + `SunSample`

- Pozycję słońca liczy czysta funkcja (algorytm NOAA z 22c, do testów w GUT/gdUnit4): `SunModel.position(day_of_year, hour, lat, lon) -> Vector2(azimuth, elevation)`.
- To, czego fizyka nie da (pogoda, nastrój), trzyma zasób z krzywymi od godziny (dziedzina `Curve` 0–24 albo 0–1 i mnożenie przez 24):
  - `clear: Curve` (przejaśnienie, 22c §1.1),
  - `sky_lux_scale: Curve` (mnożnik wzoru z §1.1, np. gęstsze chmury w południe),
  - `sun_color: Gradient`, `sky_tint: Gradient`, `ambient_tint: Gradient`,
  - `moon_lux: Curve`, `street_lamps: Curve` (0/1 z rozbiegiem, sód najpierw różowawy),
  - `outside_gold: Curve`, `outside_night: Curve` (przenikanie trzech obrazów widoku),
  - `c_max: float` (kompresja długości smug, 22c §1.3), `max_phi: float`.
- `SunSample` (`RefCounted`, bez referencji do węzłów, zgodnie z ADR 0006) to wynik dla danej chwili: `hour`, `azimuth`, `elevation`, `clear`, `sun_lux`, `sun_color`, `sky_lux`, `sky_tint`, `ambient_tint`, `moon_lux`, `street_on`, `night`. Liczony raz na minutę gry (albo przy Przeskoku) i przekazywany w dół.

### 3.3 `WindowLight` (scena)

Parametry (`@export`): `opening: Rect2i` i `panes: Array[Rect2i]` w pikselach ściany, `sill_m`, `top_m`, `wall_azimuth_deg` (normalna zewnętrzna; dla ściany na S 180°), `facing: Facing` (tylna, lewa lub prawa ściana; na razie tylko tylna), `df_near: float = 0.08`, `cookie: Texture2D` (współdzielona na typ okna, generowana z `panes` w narzędziu edytora albo przy ładowaniu, nigdy co klatkę), `beams_enabled: bool`.

Węzły: `Patch` (PointLight2D, ciasteczko ze ścięciem, 22c §6.1), `Air` (światło kurzu), `SkyPillow`, `Bounce`, `Beams` (4 × `Polygon2D` ADD z wektorami przygotowanymi raz), `Reveals` (3 paski ADD).

API: `apply(sun: SunSample, exposure: float) -> void` (liczy `φ = A_s − A_w`, ścięcie i energie z `lux · X · K`), `daylight_lux(sun: SunSample) -> float` (do adaptacji pokoju), `rim_amount(feet: Vector2) -> float` (przeniesione `_rim_amount`), `set_active(on: bool) -> void`. Okno nie wie nic o świetlówkach. Relację robi ekspozycja.

### 3.4 `FixtureDef` + `LightFixture` (sceny opraw)

`FixtureDef` (Resource, `.tres` na typ): `lux: float`, `color: Color` (22c §4.2), `texture: Texture2D`, `texture_scale: float`, `height: float`, `receivers: int` (typy odbiorców: FLOOR | SOLID | ACTOR, przeliczane na bity pokoju w §3.5), `wall_wash: bool` + `wash_offset: Vector2`, `emitter_hdr: float` (sprite oprawy > 1 dla glow), `warmup: Curve` (zapalanie świetlówki, 22c §6.8), `flicker: float`, `k_type: float` (kalibracja z §1.4).

Sceny: `fluorescent_2x120.tscn`, `desk_lamp.tscn`, `hall_tube.tscn`, `street_lamp_sodium.tscn`, `street_lamp_mercury.tscn`, `exit_sign.tscn`. Każda to `LightFixture` (Node2D) z dziećmi `Light` (PointLight2D), opcjonalnie `Wash` i `Emitter` (Sprite2D unshaded). API: `set_on(on: bool)` (z rozbiegiem `warmup`, przez `await` i Tween, bez flag w `_process`), `apply(exposure: float)`, `lit_lux() -> float` (0, gdy zgaszona; wkład do `E_art`).

### 3.5 Przydział masek światła

Test w `_record_item_commands` to `item.light_mask & light.item_mask`, czyli wystarczy **jeden** wspólny bit. Nie da się więc wyrazić „podłoga **i** pokój A” dwoma bitami. Każda para (kolor pokoju, typ odbiorcy) potrzebuje własnego bitu. Propozycja (`light_masks.gd`, stałe):

| Bity | Znaczenie |
|---|---|
| 1–4 | `ROOM_A..D`: podłoga i bryły pokoju koloru A..D (cztery kolory wystarczą dla grafu sąsiedztwa planu, 22c §5.6) |
| 5–8 | `FLOOR_A..D`: tylko podłoga (plama słońca, przelew z drzwi, sód przez okno) |
| 9–12 | `ACTOR_A..D`: postacie stojące w pokoju koloru A..D |
| 13 | `DUST`: cząsteczki `LIGHT_ONLY` |
| 14 | `EXTERIOR`: zewnętrze i widok za oknami (gdyby kiedyś był oświetlany) |
| 15–20 | rezerwa |

- Podłoga pokoju A ma `ROOM_A | FLOOR_A`, a ściany i meble `ROOM_A`. Świetlówka pokoju A ma `ROOM_A | ACTOR_A`, plama słońca `FLOOR_A`.
- **Progi drzwi i korytarz** dostają bity obu pokoi.
- **Postać** zmienia `light_mask` na `ACTOR_<kolor>` pokoju, w którym stoi (`RoomLighting` emituje sygnał, a scena posterunku ustawia maskę dzieciom). W progu dostaje oba bity, a rim i AO są jej własnymi dziećmi.
- Kolory pokoi przydziela się w `RoomLightingProfile.color_slot` ręcznie (jednorazowo na plan) albo narzędziem kolorowania grafu w edytorze.

### 3.6 `RoomLightingProfile` + `RoomLighting` + `LightingDirector`

`RoomLightingProfile` (Resource): `color_slot: int` (0–3), `bounds: Rect2` (albo z `RoomLighting` jako `@export`), `df_avg: float = 0.02`, `floor_lux: float = 2.0` (nocne minimum), `ambient_art_share: float = 0.3`, `fluo_schedule: Curve` (0–1 od godziny, np. auto 25% w dzień, 100% od zmierzchu, 0 po 21:00) albo `fluo_mode: FluoMode`, `exposure_alpha: float = 0.7` (pozwala zrobić areszt „ciemniejszym, niż oko by chciało”), `dust_amount: int`, `ambient_tint_override: Color` (alfa 0 = brak).

`RoomLighting` (Node2D w scenie pokoju): zbiera dzieci `WindowLight` i `LightFixture`. API: `adaptation_lux(sun: SunSample) -> float`, `apply(sun: SunSample, exposure: float) -> void`, `set_active(on: bool) -> void`, sygnał `actor_entered(actor: Node2D)`.

`LightingDirector` (węzeł w scenie posterunku lub zewnętrza, właściciel `CanvasModulate` i `WorldEnvironment`):
- dostaje `apply_time(sun: SunSample)` z góry (zegar w `Main` → scena świata → reżyser, „call down”);
- co klatkę (tanio) śledzi pokój gracza i wygładza `X` (asymetrycznie, w logarytmie). Gdy `X` zmieni się o > 1%, woła `apply()` na aktywnych pokojach. Bez zmian nic nie liczy;
- co ok. 0,25 s porównuje prostokąt kamery (z marginesem) z `bounds` pokoi i włącza lub wyłącza pokoje. Prostsza alternatywa to `VisibleOnScreenNotifier2D` na pokój;
- ustawia ambient z §1.4.

### 3.7 Zewnętrza: co inaczej

- **Słońce i księżyc:** `DirectionalLight2D` modeluje równoległe promienie i daje kierunek tylko przez normal mapy (`height` 0–1) oraz nieskończone cienie z okluderów. **Ignoruje maski odbiorców** i świeci na wszystko na swoich warstwach canvas (filtr `range_layer_min/max` działa, co widać w `renderer_viewport.cpp`). [DirectionalLight2D.xml](https://github.com/godotengine/godot/blob/master/doc/classes/DirectionalLight2D.xml). Wniosek: używać tylko tam, gdzie na ekranie nie ma wnętrz (rynek, ulice). Przy wejściu do budynku bez ekranu ładowania wnętrze musiałoby leżeć na innej warstwie canvas, co psuje Y-sort, więc lepiej słońce zewnętrza zrobić jako `CanvasModulate` + kolor nieba + duże światła wypełniające z maską `EXTERIOR` i `DirectionalLight2D` tylko dla N·L budynków z normal mapami.
- **Cienie budynków:** w lutym w południe `cot(15°) ≈ 3,7`, więc 8-metrowy budynek rzuca cień ~30 m = 1 200 px. Kompresja jak we wnętrzu (`c_max` ok. 1,5–2 dla czytelności ulicy), cień jako `Polygon2D` MUL z rzutu bryły (2 czworoboki na prostopadłościan, 22c §3), przeliczany co zmianę słońca o > 0,5°, tylko przy `clear > 0,3`. W pochmurne południe brak cieni rzucanych, tylko AO u podstaw ścian.
- **Śnieg:** bardzo jasne podłoże (świeży śnieg ma albedo ok. 0,8–0,9, wiedza ogólna). Daje mocne odbicie w górę (jaśniejsze dolne partie fasad, chłodne cienie od nieba), a nocą ambient od księżyca i latarni jest wyraźnie jaśniejszy niż nad asfaltem. W regule z §1.4 zewnętrze ma `floor_lux` wyższy niż wnętrza i `ambient_art_share` ~0,6 przy latarniach.
- **Latarnie:** `street_lamp_sodium` (2000 K) i `street_lamp_mercury` (4200 K) z 22c §4.2, `lux` 10–20 pod oprawą (średnio P2–P4 = 5–10 lx na ulicy), plama na śniegu większa i jaśniejsza niż na asfalcie, plus emisyjna oprawa > 1 dla glow. Zapalanie według `street_lamps` w profilu czasu.
- **Ekspozycja przy przejściach:** pochmurny dzień na zewnątrz ~5 800 lx, wnętrze ~250 lx, więc `X` skacze ok. 9× (przy `α = 0,7`). Wejście do budynku: przez 2–4 s wnętrze jest ciemne i się „otwiera”. Wyjście: krótkie prześwietlenie. To samo zjawisko co Speed Up/Down w Unrealu, za darmo z reguły. Nocą odwrotnie: z ulicy (~5 lx) okna posterunku świecą jasno, bo emisyjne okna budynków to `interior_lux · X_out`. W dzień te same okna z zewnątrz są ciemne, jak w rzeczywistości.
- **Zewnętrze jako osobna scena czy ciągłość?** Brief mówi o posterunku bez ekranów ładowania. Jeśli miasteczko też ma być ciągłe, `LightingDirector` jest jeden, a zewnętrze to po prostu „pokój” z `df_avg = 1` i własnym kolorem maski.

## 4. Zmiany w `room.gd` (w kolejności priorytetu)

1. **Ekspozycja z poziomu adaptacji (naprawia zgłoszony problem).** Dodać stałe `LUX_REF := 250.0`, `FLUO_LUX := 250.0`, `DF_NEAR := 0.08`, `DF_AVG := 0.02`, `FLOOR_LUX := 2.0`, `ALPHA := 0.7`, `X_MIN := 0.25`, `X_MAX := 8.0`, funkcję `_outside_lux(h)` (wzór z §1.1 × `_daylight` × krzywa chmur) i `_target_exposure()`. Zastąpić `sky_light.energy = sky_e * (1.0 - 0.85 * fluo * night)` przez `sky_light.energy = _outside_lux(hour) * DF_NEAR * exposure * K_SKY`, a energię świetlówek przez `FLUO_LUX * fluo * exposure * K_FLUO`. To samo zrobić z `patch`/`air`/`bounce`/`street`/`spill`. `K_*` dobrać tak, żeby w południe wyszły dzisiejsze wartości. Test: preset 16:15 i 17:36, klawisz L wł./wył.; poduszka nieba ma znikać przy włączonych świetlówkach i wracać przy zgaszonych.
2. **Nie liczyć co klatkę.** W `_process` wołać `_apply_hour()` tylko gdy `hour`, `fluo_mode` albo `exposure` zmieniły się ponad próg (np. 1/60 h lub 1%). W `_update_beams` trzymać prealokowane `PackedVector2Array`/`PackedColorArray` na szybę zamiast `Dictionary` i nowych tablic. HUD odświeżać tylko przy zmianie stanu. Zgodne z CLAUDE.md (bez alokacji w gorących pętlach).
3. **Wygładzanie ekspozycji** z asymetrią (τ ok. 0,4 s przy jaśnieniu, ok. 3 s przy ciemnieniu), w logarytmie. Natychmiastowe przy klawiszach T, `[`, `]` i przy `--shots`, żeby zrzuty były powtarzalne. Klawisz L pokaże adaptację oka „na żywo”.
4. **Ambient i szyby od ekspozycji:** kolor `CanvasModulate` z §1.4 (ton według `w_art`, jasność z `X`) zamiast tabeli `AMBIENT` niezależnej od świetlówek. Szyby i `outside_*` przemnożyć przez `X` z dolnym progiem.
5. **Pomiar w HUD** (klawisz F3 przez akcję w Input Map, nie surowy keycode): GPU/CPU ms z §2.5, liczba włączonych świateł, `X`, `L`. Wtedy kolejne kroki od razu pokazują koszt.
6. **Tryb `--bench`** z §2.5 (N kopii pokoju, CSV).
7. **Test `tonemap_exposure`** (§6, punkt 1). Jeśli działa, przenieść globalne `X` do `Environment` i dodać tonemapper (AgX lub Reinhard) jako kolano dla plamy.
8. **Wydzielić tabelę pór do `TimeOfDayProfile.tres`** (pierwszy kawałek zestawu), potem `WindowLight` i `LightFixture` (§5). Prototyp zostaje prototypem; wydzielenie ma sens dopiero po potwierdzeniu reguły na zrzutach.
9. Drobne: `Art.light_radial(0)` jest wołane dla `bounce` i `rim` osobno. Jeśli tworzy nową teksturę, to dwa wpisy w atlasie. Tekstury świateł trzymać w jednym słowniku współdzielonym.

Niezwiązane, zauważone przy okazji (nie poprawiam): `post.gdshader` ma na sztywno `vec2(640.0, 360.0)` w `sample_blur`, a pokój działa w 960×540, więc promień rozmycia jest o 1,5× za duży względem zamierzenia; komentarz w nagłówku też mówi o 640×360. `_apply_hour` ustawia `sky_light.color` z tabeli `SKY_COL`, w której noc ma jasny błękit `(0,35; 0,45; 0,85)` przy energii 0,55, takiej samej jak w dzień.

## 5. Szkic zestawu do wydzielenia z `room.gd`

```
res://lighting/
  sun_model.gd               # static: NOAA position(day, hour, lat, lon) -> Vector2(az, el); testy GUT
  exposure.gd                # static: target(l_lux, alpha, x_min, x_max), smooth(x, target, delta, tau_up, tau_down)
  light_masks.gd             # const ROOM_A..D, FLOOR_A..D, ACTOR_A..D, DUST, EXTERIOR; static room_bits(slot)
  sun_sample.gd              # class_name SunSample extends RefCounted
  time_of_day_profile.gd     # class_name TimeOfDayProfile extends Resource
  profiles/norway_feb.tres
  fixture_def.gd             # class_name FixtureDef extends Resource
  fixtures/fluorescent_2x120.tres, desk_lamp.tres, hall_tube.tres, sodium.tres, mercury.tres
  light_fixture.gd/.tscn     # class_name LightFixture extends Node2D
  window_light.gd/.tscn      # class_name WindowLight extends Node2D
  room_lighting_profile.gd   # class_name RoomLightingProfile extends Resource
  room_lighting.gd/.tscn     # class_name RoomLighting extends Node2D
  lighting_director.gd       # class_name LightingDirector extends Node
  textures/                  # współdzielone: radial.png, tube.png, sky_pillow.png, door_spill.png, cookie_double.png
```

Zasoby (typowane, kolejność jak w style guide):

```gdscript
class_name TimeOfDayProfile
extends Resource

@export var latitude_deg: float = 63.43
@export var longitude_deg: float = 10.40
@export var day_of_year: int = 51
@export var clear: Curve                  # 0..24 h -> 0..1
@export var sky_lux_scale: Curve
@export var sun_color: Gradient           # offset = h / 24
@export var sky_tint: Gradient
@export var ambient_tint: Gradient
@export var moon_lux: Curve
@export var street_lamps: Curve
@export var outside_gold: Curve
@export var outside_night: Curve
@export var c_max: float = 2.2
@export var max_phi: float = 0.96         # ~55°


func sample(hour: float) -> SunSample:
	# SunModel + krzywe -> SunSample; bez stanu, bez węzłów.
	...
```

```gdscript
class_name RoomLightingProfile
extends Resource

@export_range(0, 3) var color_slot: int = 0
@export var df_avg: float = 0.02
@export var floor_lux: float = 2.0
@export var ambient_art_share: float = 0.3
@export var exposure_alpha: float = 0.7
@export var fluo_schedule: Curve          # 0..24 h -> 0..1 (auto); null = sterowane fabułą
@export var dust_amount: int = 60
@export var ambient_tint_override: Color = Color(0, 0, 0, 0)
```

```gdscript
class_name FixtureDef
extends Resource

@export var lux: float = 250.0
@export var color: Color = Color(0.86, 0.95, 0.88)
@export var texture: Texture2D
@export var texture_scale: float = 2.6
@export var height: float = 120.0
@export_flags("Floor", "Solid", "Actor") var receivers: int = 7
@export var wall_wash: bool = false
@export var wash_offset: Vector2 = Vector2(0, -44)
@export var emitter_hdr: float = 2.0
@export var warmup: Curve
@export var k_type: float = 0.0056
```

Drzewo sceny pokoju (przykład, pokój socjalny):

```
BreakRoom (Node2D, y_sort)
├─ Floor (Sprite2D / TileMapLayer, light_mask = ROOM_A | FLOOR_A)
├─ Walls (Sprite2D, ROOM_A)
├─ Props (Node2D, y_sort)  …kanapa, lodówka (ROOM_A)
├─ AO (Node2D)            …sprite'y MUL z 22c §6.6
└─ RoomLighting (profile = break_room.tres, bounds = Rect2(…))
   ├─ WindowSouth (WindowLight: opening, panes, wall_azimuth_deg = 180)
   │   ├─ Patch, Air, SkyPillow, Bounce (PointLight2D)
   │   ├─ Beams (Node2D → 4 × Polygon2D)
   │   └─ Reveals (Node2D → 3 × Sprite2D ADD)
   ├─ Fixtures (Node2D)
   │   ├─ Fluo1..4 (LightFixture: fluorescent_2x120.tres)
   │   └─ DoorSpill (LightFixture: door_spill.tres, receivers = Floor)
   └─ Dust (CPUParticles2D, LIGHT_ONLY, light_mask = DUST)
```

Scena posterunku:

```
Station (Node2D)
├─ LightingDirector     (CanvasModulate, WorldEnvironment jako dzieci; apply_time(SunSample) z góry)
├─ Rooms (Node2D)       …BreakRoom, Office, Cells, …, Corridor (każdy z RoomLighting)
└─ Actors (Node2D, y_sort) …Badacz, NPC (light_mask ustawiane przez Station przy actor_entered)
```

Przepływ: zegar (`Main`) → `world.apply_time(sample)` → `LightingDirector.apply_time` → aktywne `RoomLighting.apply(sample, X)` → `WindowLight.apply` / `LightFixture.apply`. W górę płyną tylko sygnały (`actor_entered`, `exposure_changed` dla debug HUD).

## 6. Niezweryfikowane

- **Nic z tej reguły nie zostało uruchomione.** Do sprawdzenia w prototypie: (1) czy `Environment.tonemap_exposure` i tonemapper działają na warstwy 2D przy `BG_CANVAS` + `use_hdr_2d` (test: `tonemap_exposure = 0,5` i porównanie zrzutów; potem to samo z `CameraAttributesPractical.auto_exposure_enabled`). Wniosek z kodu `render_empty_scene` i z wątku na forum jest pośredni. (2) Czy wartości `α = 0,7`, `X_max = 8` i τ dają czytelny noir (strojenie na zrzutach).
- **Wzór na natężenie pod niebem pochmurnym** `E ≈ 300 + 21 000·sin(e)` lx podaję z pamięci (przypisywany Krochmannowi i stosowany w literaturze daylightingowej). Nie znalazłem pierwotnego źródła z tymi współczynnikami. Rzędy wielkości zgadzają się z tabelą Wikipedii (dzień pochmurny ~1 000 lx przy grubych chmurach, do ~10 000 lx), ale zimowe chmury w Norwegii mogą dawać mniej. Natężenie bezpośredniego słońca przy niskiej wysokości (`E_n` rzędu 10–30 tys. lx) to też szacunek.
- **DF 8% przy oknie i 2% średnio** to założenie z proporcji okna do podłogi, nie obliczenie (pełny wzór BRE wymaga transmisji szkła, kąta nieba i odbić).
- **Normy:** wartości EN 12464-1 i EN 13201-2 pochodzą z odpisów (DIALux, katalogi producentów), nie z tekstu norm. Nie sprawdzałem edycji 2021/2023 EN 12464-1.
- **Cytaty z Reinharda (klucz 0,18) i z kursu Frostbite** znam z literatury. PDF-ów nie udało się odczytać narzędziem (Frostbite > 10 MB, Reinhard jako skompresowany PDF). Linki prowadzą do oryginałów.
- **Adaptacja oka:** czasy podaje Wikipedia (z Britanniki 1987) i są w niej niekonsekwentne (jaśnienie „sekundy” albo „5 minut”, pręciki „30–45 min” albo „2 h”). Do gry wystarczy kierunek asymetrii.
- **Konwencje filmowe** („okno w zakresie ekspozycji wnętrza”, practical jako klucz nocą) to wiedza ogólna. Jako źródło mam tylko opisy produktów Rosco ze sklepów, nie karty producenta ani podręcznik operatorski.
- **Atlas świateł i `ImageTexture.update()`:** z kodu `texture_storage.cpp` wynika, że `texture_2d_update` nie oznacza atlasu jako dirty, więc tekstura światła aktualizowana w miejscu może się nie odświeżyć. Nie testowałem i nie znalazłem zgłoszenia. Jeśli tak jest, wypiekana plama (22c §6.9) potrzebuje `set_image()` (pełna przebudowa atlasu) albo innego nośnika (sprite `LIGHT_ONLY`/ADD).
- **Koszty z §2.2–§2.4** to szacunki z kodu, bez pomiaru. Zgłoszenia z forów dotyczą innych wersji i sprzętu. Pierwszy realny pomiar da tryb `--bench`.
- **Przypisanie świateł do elementów w §2.3** wynika z masek i prostokątów odczytanych z kodu `room.gd` (rozmiar tekstury × `texture_scale`, transformacje ścięcia). Silnik liczy `rect_cache` sam i mógł policzyć je inaczej. Nie sprawdzałem też, czy `Rect2.intersects` liczy styk krawędzi jako przecięcie.
- **`Curve` z dziedziną 0–24:** właściwości `min_domain`/`max_domain` w `Curve` pamiętam z nowszych wersji 4.x, nie sprawdzałem w 4.7. W razie braku: dziedzina 0–1 i `hour / 24`.
- **`--disable-vsync`** jako opcja wiersza poleceń: z pamięci, nie sprawdzałem w dokumentacji 4.7.
- **Gry:** Children of Morta (TechRaptor 403, treść z wyciągu wyszukiwarki), Sea of Stars (lista cech przed premierą, z relacji prasy), Octopath (wyciąg ze strony Unreal), Hyper Light Drifter (brak źródeł). Nie znalazłem prelekcji GDC o organizacji świateł w żadnej z tych gier.
