---
id: 27
title: Generowanie UI, czcionek i portretów
labels: [wayfinder:prototype]
status: closed
assignee: bmikler
blocked_by: [25, 26]
---

> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/27-generowanie-ui.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

## Question

Jak wygląda i z czego powstaje UI gry bez ręcznego rysowania: okno rozmowy, portrety, przyciski, ikony Przedmiotów, czcionka? UI jest natywne (osobna warstwa w rozdzielczości ekranu; Rozdzielczość bazowa: 640×360 czy większa), ale stylizowane na pixel art: ramki, przyciski, ikony i czcionka wyglądają pikselowo, tylko nie są powiększane razem ze światem.

Restart (2026-10-29, z człowiekiem). Próbka w prototypie (`game1-proto`, gałąź `prototype/oswietlenie`), okno nad sceną posterunku z zestawu oświetlenia, dzień i noc, na 1080p i 1440p:

- **UI niezależne od światła:** warstwa nad światem, bez świateł 2D i post-processu, w dzień i w nocy wygląda tak samo. Dotyczy obu układów rozmowy.
- **Układ rozmowy, 2 warianty:** dymki nad postaciami w scenie albo nakładka dialogowa na dole ekranu (w stylu Baldur's Gate 3).
- **Wielkość piksela UI:** piksel UI równy pikselowi świata (×2 na 1080p, na 1440p świat ma ×2,67) czy większy, stały (np. ×3), i jak to wygląda obok siebie.
- **Motyw okna rozmowy, 2 warianty w pixel arcie:** papier/teczka (nawiązanie do dokumentów śledztwa) oraz ciemny panel z ramką.
- **Portrety:** malarski z ComfyUI (`badacz-portret-6003`) i pikselowy wyprowadzony z malarskiego (FLUX 3 Klein w ComfyUI, potem `unfake` z paletą projektu). Pixellab odpada: zostało 2,2 generacji triala, a `create_portrait_character` potrzebuje 10–15. Tylko Badacz: portret Krogga z ComfyUI zostaje, nie generujemy go od nowa. W oknie mogą być widoczne 2 portrety (gracz i rozmówca); na próbce Badacz rozmawia sam ze sobą.
- **Czcionka:** 2–3 darmowe czcionki pikselowe (OFL/CC0, TTF) w długim dialogu; æ ø å mile widziane, ale nie konieczne (czcionkę można zmienić później), w rozmiarach będących wielokrotnością siatki kroju; dla porównania jedna zwykła, gładka czcionka w pikselowej ramce.
- **Przycisk w 3 stanach** (normalny, hover, wciśnięty) i **jedna ikona Przedmiotu** (amulet z wycinka) jako wzorzec serii. Grafika z ComfyUI (FLUX 3) albo rysowana kodem, bez Pixellab.

Do rozstrzygnięcia: układ rozmowy (dymki czy nakładka), wielkość piksela UI, motyw, rodzaj portretu i liczba portretów w oknie (1 czy 2), czcionka i jej rozmiar, sposób wytwarzania.

## Postęp

**Workflow FLUX 3 w ComfyUI (2026-10-29).** W Comfy Desktop jest destylowany FLUX 3 Image Klein (`flux3-image-klein-int8-convrot`, enkoder `qwen3vl_4b_int8_convrot`, VAE z FLUX.2). Nowy workflow `tools/concept/workflows/flux3-klein.mjs` (`node tools/concept/comfy.mjs --workflow flux3-klein --ref <png> "..."`): 16 kroków, cfg 1, euler/simple, referencje przez `ReferenceMultiLatent` (`<ref_image_0>` w prompcie), bez upsamplera promptu. ok. 35–40 s na obraz 1024×1024 z referencją (RTX 4060).

**Portret pikselowy z malarskiego.** FLUX 3 z `badacz-portret-6003` jako referencją (`art/concept/ui/portret/badacz-px-f3-100.png`, seed 100) zachowuje twarz, fryzurę i ubranie, ale daje udawany pixel art (wysoka rozdzielczość, nierówne piksele). `unfake detect` znajduje siatkę 4 px; `unfake downscale` + `quantize --palette art/concept/_style/palette.hex` daje prawdziwy portret w palecie projektu: 256, 170 i 128 px (`-s4/-s6/-s8`). Twarz czytelna we wszystkich trzech; wybór rozmiaru w próbce okna.

**Układy rozmowy (2026-10-29, z człowiekiem).** Zamiast 2 wariantów próbka porównuje 4 sposoby prowadzenia rozmowy: 3 z portretami (m.in. duże popiersia jak w visual novelach i RPG Makerze: portret mówiącego po jego stronie ekranu, opcje Badacza pod jego portretem) i 1 z samymi dymkami (jak Broken Sword i stare Indiana Jones). Research: docs/research/27-uklady-dialogow.md. Na próbce jedna mina na postać; kolejne miny w produkcji mają być łatwe i tanie z ComfyUI (edycja portretu z referencją), co próbka powinna potwierdzić jedną dodatkową miną.

**Prototyp porównawczy (2026-10-29).** `game1-proto`, gałąź `prototype/oswietlenie`, scena `prototype/lighting/ui/ui_compare.tscn` (`run_ui.bat`; zrzuty `-- --uishots=<katalog>`, pełny ekran, 4 układy × 4 motywy × linia/wybór × dzień/noc → `shots/<katalog>/`). Posterunek z zestawu oświetlenia pod spodem, UI na `CanvasLayer` w rozdzielczości okna, więc światło i post-process go nie dotykają. Badacz rozmawia z drugim Badaczem; rozmowa ~20 kwestii: długa kwestia, test Psychologii, forsowanie z jawną konsekwencją, opcja z ikoną amuletu, Wpis z ikoną, telefon (Ingrid), mina podejrzliwa.

- Przełączniki: F1–F4 układ (P1 popiersia, P2 kolumna akt, P3 listwa z portretem, P4 dymki), F5 portret (malarski, pikselowy 256/170/128 px), F6 czcionka, F7 piksel UI ×2/×3/×4, F8 motyw (ciemny i papier rysowane kodem, ciemny i papier z FLUX), F9 popiersia oba/tylko mówiący, F10 tempo tekstu (natychmiast/szybko/wolno, blokada 0,25 s po końcu kwestii).
- Assety (FLUX 3 + `unfake` + paleta; źródła w `art/concept/ui/`, poza gitem): popiersie Badacza `badacz-biust-201` i mina podejrzliwa `badacz-biust-podejrzliwy-301` (twarz zgodna, kolejna mina to jedna generacja ~40 s), malarskie popiersia bez tła `badacz-malarski-tlo-700` i `badacz-malarski-podejrzliwy-800`, amulet `amulet-400` (48 px; w 32 px wzór znika), panele `panel-ciemny-601` i `panel-papier-501`. Tło zielone kluczowane przed paletą (`unfake quantize` przypisałby zieleń do koloru palety).
- Czcionki (docs/research/27b-czcionki-pikselowe.md, pliki z licencjami w `ui/fonts/`): Ark Pixel 12 px (domyślna), m5x7, Departure Mono, monogram, m6x11plus, Silkscreen, IBM Plex Sans jako gładka; rozmiar zawsze wielokrotnością siatki kroju.
- Pierwsze obserwacje ze zrzutów 1080p: wszystkie 4 układy czytelne w dzień i w nocy; panele FLUX mają szum w środku, który przy rozciąganiu 9-slice przeszkadza w czytaniu (papier w dymku najgorzej); P4 dzieli długie kwestie na dymki po ≤110 znaków na końcach zdań. 1440p nie da się sprawdzić na monitorze 1080p (okno przycinane do ekranu).

**Przegląd człowieka i zawężenie (2026-10-29).**

- Pierwsze portrety pikselowe (FLUX + `unfake` + paleta 32 kolorów projektu) odrzucone: „wyglądają jak g…”. Paleta projektu robiła twarze pomarańczowe i płaskie. Nowe: zmniejszenie malarskiego popiersia bez tła (`unfake downscale -m median`, siatka 4 lub 5 px → 208×256 lub 166×204) i własna paleta 64 kolorów obrazu (`unfake quantize -c 64`, bez palety projektu). Kolory i rysunek zostają jak w malarskim; człowiek wybrał **pikselowe 208 px**. Wariant „FLUX z promptem o wierność, potem `unfake`” też trzyma kolory, ale zmienia kadr; zostaje w przełączniku.
- Krogg jako rozmówca: portret malarski bez tła z `krogg-portret-b-801` (edycja FLUX 3 usunęła też napis z plakietki), z niego wersje pikselowe tym samym łańcuchem; w scenie nowy sprite Krogga z konceptu w wysokiej kamerze (`pipeline/out/krogg_gora_*` → `assets/krogg_gora/`).
- Portrety zwrócone do środka ekranu: oba źródła patrzą w lewo, więc postać stojąca po lewej jest odbita.
- Dymki (P4) usunięte: na pewno rozmowa z portretami. Listwa (P3) usunięta. Zostają do przełączania **P1 popiersia** (Krogg po lewej, Badacz po prawej, mówiący jasny) i **P2 kolumna akt** jak w Disco Elysium; ostateczny wybór w finalnej grze. W kolumnie zawsze jeden portret, mówiącego: Badacz po lewej od imienia, rozmówca po prawej (research: docs/research/27c-portrety-w-kolumnie.md).
- Testy w rozmowie bez oprawy (opcje to zwykły tekst, wynik rozstrzyga się po cichu); prezentacja testów to osobny ticket z researchem: Prezentacja testów: animacja rzutu i wynik.
- Kolumna według researchu: po obu stronach imienia stałe miejsce na portret (tekst nie skacze), wypełnione tylko u mówiącego; przy zmianie mówcy stary portret gaśnie, a nowy pojawia się w 0,15 s z przesunięciem o 3 piksele UI w stronę imienia (bez animacji przy tempie „natychmiast”). F3 przełącza położenie: góra kolumny (wzór Disco Elysium) albo nad ostatnią kwestią (wcześniejsze kwestie wyżej, przygaszone). Narracja: puste miejsca bez imienia. Zrzuty: `P2gora` i `P2nad`.
- Kolumna, dalsze uwagi człowieka: portret na dole, nad bieżącą kwestią, na pasie oddzielającym wcześniejsze kwestie (przewijane kółkiem i PgUp/PgDn) od bieżącej kwestii w osobnej ramce; imię obok portretu w jednej linii (ramka z imieniem nad ramką z portretem odrzucona, polaroid odrzucony, przycięcie do ramion odrzucone). Schematy kolorów zamiast papieru i paneli FLUX: granat, ciepły grafit, zieleń sosny; tła kolumny z FLUX (stal, drewno, szron) czekają na ocenę po ustaleniu portretu. Skala UI automatyczna z wysokości ekranu (1080p ×2, 1440p ×3, 4K ×4).
- **Wybrane:** portret pikselowy 166 px (pozostałe style usunięte z prototypu), czcionka **Ark Pixel 12 px** (pozostałe usunięte), tło kolumny **stal** z FLUX (`kolumna-stal-1100`, pikselizowane; drewno i szron usunięte), kolory granat albo ciepły grafit (zieleń sosny usunięta).
- Blok portretu w kolumnie (2026-10-29): wąska belka z imieniem przez całą szerokość, portret w osobnej ramce (jasne obramowanie, ciemne tło, jak w Disco Elysium) stoi na belce i wystaje ponad nią; portret przycięty do 80% wysokości popiersia (166×163 px). Arkusz: `shots/cmp/kolumna_stal.png` w `game1-proto`.
- Przy okazji (prośba człowieka): przełącznik normal map `N` w zestawie oświetlenia usunięty, zostają normal mapy z własnego skryptu.

- Telefon (2026-10-29): zamiast słuchawki rysowanej kodem rozmówca przy telefonie ma obrazek beżowego telefonu biurowego z FLUX 3 (`telefon-1400`), pikselizowany jak portrety, w tej samej ramce.

## Resolution

- **Układ rozmowy:** kolumna z prawej (~30% szerokości, jak w Disco Elysium). Na dole blok mówiącego: wąska belka z imieniem (metalowa tabliczka rysowana kodem) przez całą szerokość i portret w ramce (jasne obramowanie, gładki gradient w tle), który stoi na belce i wystaje ponad nią. Badacz po lewej, rozmówca po prawej, zawsze jeden portret; zmiana mówcy to przenikanie 0,15 s z przesunięciem o 3 piksele UI. Pod blokiem bieżąca kwestia albo opcje we własnej ramce (min. 3 linie), pod nią wolne miejsce; nad blokiem przewijane wcześniejsze kwestie (kółko, PgUp/PgDn). Narracja bez portretu i imienia; telefon jako obrazek telefonu. Lewy przycisk myszy i spacja przewijają dialog. Duże popiersia (Krogg po lewej, Badacz po prawej, mówiący jasny) zostają jako alternatywa do wyboru w finalnej grze. Dymki, listwa z portretem i polaroid odrzucone.
- **Oprawa:** UI natywne, niezależne od światła i post-processu, stylizowane na pixel art; skala UI automatyczna z wysokości ekranu (1080p ×2, 1440p ×3, 4K ×4). Kolory ciepły grafit (domyślnie) albo granat z palety projektu; tło kolumny: stal z FLUX 3 (`kolumna-stal-1100`, pikselizowana, bez rozciągania). Ramki i przyciski rysowane kodem w skali UI; panele 9-slice z FLUX odrzucone (szum przy rozciąganiu), papier odrzucony.
- **Portrety:** pikselowe 166 px, ok. 1:1 w skali UI ×2, w kolumnie przycięte do 80% wysokości popiersia. Łańcuch: portret malarski z ComfyUI → edycja FLUX 3 na tle #00FF00 (ta sama postać, nowe tło lub mina) → `unfake downscale -s 5 -m median` → kluczowanie zieleni → `unfake quantize -c 64` (własna paleta obrazu; paleta projektu 32 kolory dawała płaskie, pomarańczowe twarze). Kolejna mina to jedna generacja FLUX (~10–40 s). Postać po lewej stronie ekranu jest odbijana, żeby patrzyła do środka.
- **Czcionka:** Ark Pixel 12 px (OFL 1.1), rozmiar zawsze 12 × skala UI; do wydania przyciąć do łaciny (5,3 MB z CJK).
- **Ikony:** FLUX 3 na zielonym tle → `unfake`, co najmniej 48 px (w 32 px wzór amuletu znika).
- **Narzędzia:** ComfyUI z FLUX 3 Image Klein (`tools/concept/workflows/flux3-klein.mjs`) i `unfake`; Pixellab do UI niepotrzebny.
- **Do dopracowania przy budowie:** kontrast imienia na belce, 1440p niesprawdzone na żywo, przeciąganie paska przewijania może przewinąć dialog. Testy w rozmowie bez oprawy: Prezentacja testów: animacja rzutu i wynik.

Prototyp: `game1-proto`, gałąź `prototype/oswietlenie`, `prototype/lighting/ui/ui_compare.tscn` (`run_ui.bat`), arkusze `shots/cmp/kolumna_*.png`. Research: docs/research/27-uklady-dialogow.md, docs/research/27b-czcionki-pikselowe.md, docs/research/27c-portrety-w-kolumnie.md.
