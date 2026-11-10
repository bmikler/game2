# STYLE: kierunek graficzny

Blokada stylu dla concept artów (ComfyUI, FLUX.2 [klein]) i assetów pixel art (Pixellab, unfake). Wybrane obrazy i uwagi człowieka są w `../picks.md`, a pełne prompty i seedy w `../prompts.jsonl`. To pierwsza iteracja: styl może się zmieniać, ale wszystkie zmiany wpisujemy tutaj.

## Klimat

- Mała norweska/skandynawska mieścina, luty, rok 2010. Nordic noir: Twin Peaks, Alan Wake, zimowa Skandynawia, nastrój Disco Elysium.
- Świat jest **zwyczajny, skromny i zmęczony, ale zadbany**: jasna boazeria, brzozowe meble, linoleum, kineskopowe monitory, beżowy telefon. Bałagan widać tylko w szczegółach: papiery, popielniczka, niedopita kawa, resztki jedzenia, kurz w archiwum.
- Postacie są zwyczajne i zmęczone, nie heroiczne: szczupłe sylwetki, wąskie ramiona, zarost, podkrążone oczy, rozczochrane włosy. Ubrania czyste, ale noszone.
- Światło: chłodne świetlówki, pojedyncza ciepła lampka, głęboki granat nocy, śnieg i las tylko za oknem. Nastrój stonowany, cichy i lekko niepokojący.
- **Nie chcemy:** rudery, „rosyjskiego” brudu, slumsów, pajęczyn, śniegu we wnętrzach, świątecznego ani cukierkowego ciepła, heroicznych i napakowanych postaci, komiksu, fotorealizmu.

## Technika concept artów (FLUX.2 [klein])

- Styl: malarska ilustracja concept artu z widocznymi pociągnięciami pędzla i cienkim konturem, stonowane, zdesaturowane kolory. Nie zdjęcie i nie komiks.
- **Model nie zna negacji.** Każde słowo z promptu pojawi się w obrazie („no cobwebs” daje pajęczyny), więc opisujemy tylko to, co ma być widoczne.
- Edycja z referencją trzyma kadr 1:1 i dobrze dodaje lub usuwa drobiazgi oraz zmienia kolory. Kamery, liczby krat ani ścian nie zmieni, więc do takich zmian generujemy obraz od nowa.
- Każdą edycję robimy z ostrego oryginału: łańcuch kolejnych edycji rozmywa obraz. Kilka referencji naraz miesza widoki, dlatego najlepiej używać jednej.
- Arkusz postaci pod sprite: stojąca, neutralna poza („standing still in a relaxed neutral pose, arms at his sides”). Słowa o pośpiechu („hurried”) dają pozę w kroku, więc pośpiech pokazujemy tylko twarzą i detalami.
- Portret robimy z arkusza jako jedynej referencji. Model pogrubia w portrecie kontur i postarza twarz, dlatego w prompcie piszemy „same fine linework as the reference” i podajemy wiek. Losowe napisy (plakietki, rogi kadru) usuwamy edycją albo przy pikselizacji.
- Wnętrza: kamera lekko podwyższona, patrzy na tylną ścianę, bez przedniej ściany. Wysoka kamera 3/4 psuje układ mebli. Concept art pokazuje klimat, nie układ: rozkład mebli projektujemy w skali gry przy budowie sceny.
- **Style frame'ów w kamerze gry nie robimy we FLUX** (próba 2026-10-28: kamera wychodzi, ale skala postaci i wygląd pikseli nie). Kadr gry powstaje z prawdziwych sprite'ów w Godot (ticket Pipeline assetów pixel art z normal mapami).

### Prompt bazowy: wnętrze

```
<pomieszczenie> of a small-town police station in a quiet snowy town in northern Scandinavia, dark February winter morning, year 2010. Tidy, well kept and modest building, clean dry floor, clean but not new, light wood panelling and plain birch office furniture. <meble i drobiazgi>. Lighting: cold fluorescent ceiling light mixed with a warm desk lamp, deep blue darkness and snow visible only outside the windows, a dark pine forest beyond. Restrained, sober and quietly uneasy, not festive. Mysterious small-town atmosphere like Twin Peaks and Alan Wake, Scandinavian winter. Empty room, no people. Wide shot from a slightly high camera, looking straight at the back wall, the front wall removed, the whole room visible from wall to wall, logical realistic furniture layout. Painterly concept art, realistic, muted desaturated colours.
```

### Prompt bazowy: arkusz postaci

```
Character turnaround concept sheet of <kto> in a small town in northern Norway, year 2010. <wiek, sylwetka: ordinary and not heroic, narrow shoulders>, <twarz, włosy, zarost, zmęczenie>. <ubranie: clean but worn>. Standing still in a relaxed neutral pose, arms at his sides, feet slightly apart. Four views side by side on a plain light grey background: front, three-quarter, side profile, back. Full body, consistent design. Hand-painted digital illustration, video game concept art painting, visible brush strokes, slightly stylized drawn look like a graphic novel, not a photograph, muted cold palette with warm lamp accents, Nordic noir mood.
```

### Prompt bazowy: portret do rozmów (z arkuszem jako referencją)

```
Create a dialogue portrait of the same man as in the reference image (use the leftmost front view): exactly the same face, <wiek, włosy, zarost>, <wyraz twarzy: neutral, not smiling, tired>. Head and shoulders, three-quarter view, looking slightly past the viewer. Same clothes: <ubranie>. Plain muted dark grey-blue background with soft cold light from one side and a faint warm rim light. Same painterly illustration style and fine linework as the reference, more detailed. No text.
```

## Postacie

| Postać | Arkusz | Portret | Opis do promptów |
|---|---|---|---|
| Badacz | `characters/badacz/badacz-sheet-v14-5003.png` | `badacz-portret-6003.png` | szczupły mężczyzna w średnim wieku, zmęczony, ale budzący sympatię; krótkie rozczochrane ciemnobrązowe włosy siwiejące na skroniach, siwy zarost; granatowa parka policyjna z kapturem, kremowy sweter, ciemne jeansy, brązowe buty robocze |
| Krogg | `characters/krogg/krogg-sheet-f-602.png` | `krogg-portret-b-801.png` | pod trzydziestkę, wysoki i chudy, w ciągłym biegu; rozczochrane, lekko tłuste blond włosy spod granatowej czapki z daszkiem z logo policji, kilkudniowy zarost; czysty granatowy sweter mundurowy z naszywkami na jasnoniebieskiej koszuli, granatowe spodnie, czarne buty, pas |

Obaj noszą granat, więc odróżniają ich: u Krogga czapka, jasna koszula i blond włosy, u Badacza kremowy sweter i brązowe buty. Czy to wystarczy przy 75 px, sprawdzi Pipeline assetów.

## Pixel art (Pixellab i sprzątanie)

- Postać na płótnie 80×80, wzrost to rzeczywisty wzrost × 40 px (Krogg ok. 1,88 m = 75 px). Widok 3/4 z góry, sprite'y w 4 kierunkach.
- Opis zamiast domyślnej sylwetki. Sprawdzić `proportions` (np. `realistic_male` albo własne, z węższymi ramionami). Unikamy słów „heroic”, „muscular”, „clean” i „hero”; tam, gdzie generator przyjmuje negatyw, wpisujemy je jako negatyw.
- Sprite'y rysujemy w **neutralnym, równym świetle** (albedo, bez wpieczonych cieni rzucanych i nocy). Nastrój daje oświetlenie 2D z normal mapami w Godot (ADR 0002). Dzięki temu jeden asset działa rano i w nocy, a „wersja nastrojowa” to ustawienie świateł, nie osobna grafika.
- Kontur: ciemny kolor z palety (`15181f` albo `1e1a17`), nie czysta czerń.
- Każdy asset przechodzi przez paletę projektu bez ditheringu (`unfake quantize --palette palette.hex`).

### Meble i obiekty (lokalnie, bez Pixellab; ticket Układ posterunku i meble wycinka)

- **Spójność jest najważniejsza.** Wzorzec stylu to `pixel_ref.png`: Badacz (`badacz_gora_own`), nowy Krogg (`krogg_gora`) i zaakceptowane meble w tej samej skali, ×4. Każdy nowy obiekt oceniamy obok nich (arkusz ×4 i zrzut w grze), nie osobno. Stary Krogg z Pixellab nie jest wzorcem (usunięty z prototypu).
- Koncept w ComfyUI: 1. referencja to szara bryła w rzucie gry (szer. × głęb. × wys. w m, `art/concept/props/<lokacja>/_guides/`), 2. referencja to wybrany koncept pomieszczenia (materiał, klimat, nie 1:1). Tło #00FF00. Każdy koncept akceptuje człowiek przed pikselizacją.
- Pikselizacja (`game1-proto/.../pipeline/`): `prop_prep.gd` (klucz zieleni, kadr do obiektu, `rectify` prostuje lekką perspektywę) → `unfake downscale -m dominant` do wymiarów w px (40 px/m) → `unfake quantize -c 8` (własna paleta obrazu) → `prop_outline.gd` (ciemny kontur wewnętrzny 1 px) → `normals.gd prop <wysokość blatu w px>`. Mediana i 20 kolorów dają „zdjęciowe” ziarno, wygładzanie przed zmniejszeniem rwie szczeliny desek.
- Koncepty z gładkim, mało teksturowanym materiałem pikselizują się czyściej niż mocne słoje drewna.
- **Rzut jak w grze, wzorem jest `lada`:** front płasko do kamery, blat jako prosty prostokąt nad nim, bez widocznego boku. Obiekty z Pixellab (szafy, aneks, wieszak) wyszły pod kątem lub z przodu, więc każdy prompt musi podawać rzut, a kandydata oceniamy obok lady. Pixellab z samego opisu tego rzutu nie trzyma (ticket 22: sterta i szafka wyszły z przodu, bez blatu albo z cienkim paskiem). Trzyma go `create_image_pixflux` z obrazem startowym: prowadnica w rzucie gry (blat nad frontem, ×4), `init_image_strength` 50–70. Przy 150 i więcej wynik jest prawie kopią prowadnicy, więc prowadnica musi już nieść kształt i główne cechy obiektu. Drobne obiekty tracą czytelność przy pomniejszeniu ×1/4: sterta 20×26 px zlała się w klocek, więc w grze ma ×1/3 (26×34 px). Rozmiar w grze ustalamy na arkuszu obok kanapy.

## Paleta

`palette.hex`, `palette.gpl`, podgląd `palette.png`. 32 kolory, wyciągnięte metodą median cut z wybranych concept artów (posterunek i arkusze bez tła) i uzupełnione o akcenty, których uśrednianie nie zachowuje (lampa, blond, brzoza, zieleń sosen, czerwień). Paleta wstępna: do sprawdzenia na pierwszych sprite'ach pod światłem w Pipeline assetów.

| Rampa | Kolory | Do czego |
|---|---|---|
| Chłodna (noc, granat, śnieg) | `08090b 15181f 232839 262e47 415d7a 547188 798e9f 9fb8d0 c0cacc eef2f4` | ciemności, mundury i parka, cienie na śniegu, koszula Krogga, śnieg, świetlówka |
| Ciepła (drewno, buty) | `1e1a17 2e2a25 3b3228 5a3e2b 756357 a0836f c1b6a3 d6c09a` | cienie drewna, buty Badacza, boazeria, brzozowe meble |
| Neutralna (szarości) | `3f3b38 585b5b 7a8181 a8978e 42525d` | krzesła, regały, sprzęt, linoleum |
| Skóra i włosy | `8d695e d4a88c c9a96a` | cień i światło skóry, blond |
| Akcenty | `e6dccb e8c27a f6e7b8 2f3f36 4b5e50 7a2e2a` | kremowy sweter, ciepła lampka (dwa tony), sosny, czerwień (dom za oknem, gaśnica) |

## Skala i wymiary odniesienia

1 m = 40 px we wszystkich osiach, bez skrótu głębokości (ADR 0002). Sprite mebla w 3/4 to góra (szerokość × głębokość) plus front (szerokość × wysokość). Kafel 32 px (0,8 m) to tylko siatka podłóg i ścian: meble, drzwi i postacie stoją poza nią. Baza 960×540 daje kadr ok. 24×13,5 m. Wartości są odniesieniem do strojenia przy budowie sceny.

| Obiekt | Wymiary (szer. × gł. × wys.) | Piksele (szer. × gł. / wys.) |
|---|---|---|
| Postać (Krogg / osoba 1,65 m) | wzrost 1,88 / 1,65 m | 75 / 66 px na płótnie 80×80 |
| Ściana (wysokość frontu) | 2,6 m | 104 px |
| Drzwi | 0,9 × 2,1 m | 36 × 84 px |
| Okno (od parapetu na 0,9 m) | 1,2 × 1,2 m | 48 × 48 px, parapet 36 px nad podłogą |
| Biurko | 1,6 × 0,8 × 0,75 m | 64 × 32 / 30 px |
| Krzesło biurowe, krzesło dla interesantów | 0,5 × 0,5, siedzisko 0,45 m, oparcie 0,9 m | 20 × 20 / 18–36 px |
| Monitor CRT | 0,4 × 0,4 × 0,4 m | 16 × 16 / 16 px |
| Szafka na akta | 0,5 × 0,6 × 1,3 m | 20 × 24 / 52 px |
| Regał archiwum | 1,0 × 0,4 × 2,0 m | 40 × 16 / 80 px |
| Prycza | 2,0 × 0,8 × 0,45 m | 80 × 32 / 18 px |
| Wersalka | 2,0 × 0,9 × 0,85 m | 80 × 36 / 34 px |
| Blat kuchenny | 0,6 m głęb., 0,9 m wys. | 24 / 36 px |
| Lodówka | 0,6 × 0,65 × 1,8 m | 24 × 26 / 72 px |

Zasięgi świateł (start do strojenia): lampa sufitowa ok. 3,5 m, lampka biurkowa ok. 1,5 m, monitor ok. 1 m, okno nocą tylko ambient.
