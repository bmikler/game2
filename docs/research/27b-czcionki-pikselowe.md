> Kopia z game1 (`repo/game1/docs/research/27b-czcionki-pikselowe.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Czcionki pikselowe do dialogów (UI w natywnej rozdzielczości)

Ticket: `docs/wayfinder/tickets/27-generowanie-ui.md` (uzupełnienie do `27-uklady-dialogow.md`). Data researchu i dostępu do źródeł: **2026-10-29**. Pobrane pliki: `game1-proto/prototype/lighting/ui/fonts/` (każdy font z `<nazwa>.LICENSE.txt` obok).

**Jakość źródeł.** Licencje sprawdzałem u źródła: strona autora na itch.io, repozytorium GitHub autora, repozytorium `google/fonts` (katalog `ofl/` + plik `OFL.txt`). Metryki (siatka, wysokość wersalików, x-height, pokrycie znaków) **zmierzyłem sam** na pobranych plikach (opentype.js: największy wspólny dzielnik współrzędnych konturów = 1 piksel projektu, `H`/`x`/`g` = wersaliki/x-height/descender, mapa `cmap` = pokrycie). Oznaczenia: **[autor]** strona/repo autora, **[GF]** repozytorium Google Fonts, **[dok]** dokumentacja Godota, **[pomiar]** moje pomiary pliku, **[lustro]** serwis pośredni (DaFont, AUR), **[wniosek]** (moje).

## Streszczenie

- **Do testów tekstu ciągłego polecam trzy fonty:** **Ark Pixel 12px proportional** (OFL, wersaliki 9 px, pełna łacina, najczytelniejszy przy długim tekście), **m5x7** (CC0, wersaliki 7 px, proporcjonalny, zwarty, „indie” klasyk) i **Departure Mono** (OFL, wersaliki 8 px, monospace, ton raportu/terminala, pasuje do śledztwa). Wszystkie mają æ ø å.
- **Nagłówki / imiona:** **m6x11plus** (grubszy, wersaliki 11 px, licencja „free to use with attribution”, ma æ ø å) albo **Silkscreen** (OFL, tylko wersaliki 5 px, ma æ ø å). Silkscreen jest ostrzejszy i bardziej „techniczny”, m6x11plus cieplejszy.
- **Font gładki do porównania:** **IBM Plex Sans** (OFL, zmienna grubość i szerokość). Trzeźwy, „skandynawsko-korporacyjny”, dobra kontrola, czy piksel w ogóle wygrywa z gładkim tekstem.
- **Odrzucone tonem:** Press Start 2P (arkadowy, same wersaliki o szerokich literach), Alagard/Romulus (fantasy), Jersey/Micro 5/Tiny5 (display / bardzo małe), VT323 (CRT-terminal, wąski, ok do jednego ekranu komputera, nie do dialogów). **Odrzucone licencją lub źródłem:** Pixel Operator (repo autora na NotABug zwraca 404, licencja CC0 tylko z lustra), Habbo i Born2bSportyV2 (brak pierwotnego źródła licencji).
- **Godot 4:** rozmiar czcionki musi być całkowitą wielokrotnością rozmiaru projektu fontu, a Control też skalowany całkowicie. Subpixel positioning = Disabled, filtr tekstur Nearest **[dok]** [Using Fonts](https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_fonts.html). Do tego w imporcie FontFile: Antialiasing = None, Hinting = None, bez mipmap i MSDF **[wniosek]** (dokumentacja nie podaje tego wprost dla fontów pikselowych).

## 1. Kandydaci

„Siatka” = rozmiar fontu (px), przy którym 1 piksel projektu = 1 piksel ekranu, czyli wartość `font_size` dla skali ×1. Wysokości w pikselach projektu **[pomiar]**.

| Font | Autor | Licencja (zweryfikowana) | Siatka (em) | Wersaliki / x-height / descender | Mono? | æøå | Latin-1 / Latin Ext-A | Formaty | Wygląd, ton | Źródło |
|---|---|---|---|---|---|---|---|---|---|---|
| **Ark Pixel 12px proportional (latin)** | TakWolf | OFL 1.1 (plik `OFL.txt` w paczce) | 12 | 9 / 6 / 2 | nie (jest też wariant monospaced) | tak | pełne / 128/128 | TTF, OTF, BDF, PCF, OTB, WOFF | Sans, wysoki x-height, równy, neutralny; najbliżej „zwykłego” fontu systemowego | **[autor]** [GitHub](https://github.com/TakWolf/ark-pixel-font), wydanie 2026.10.25 |
| Ark Pixel 10px proportional | TakWolf | OFL 1.1 | 10 | 7 / 5 / 2 | nie | tak | pełne / 128/128 | jw. | Jak 12px, ciaśniej | **[autor]** jw. |
| Fusion Pixel 10/12px | TakWolf | OFL 1.1 | 8/10/12 | jak Ark (łacina z Ark) | oba warianty | tak | pan-latin | jw. | Ark + CJK; dla gry tylko po łacinie nic nie dodaje | **[autor]** [GitHub](https://github.com/TakWolf/fusion-pixel-font) |
| **m5x7** | Daniel Linssen | CC0 1.0 („free to use but attribution appreciated”) | 16 (autor: „16, 32, 48…”) | 7 / 5 / 2 | nie | tak | pełne / 127/128 | TTF | Sans, zwarty, miękki, bardzo popularny w indie | **[autor]** [itch.io](https://managore.itch.io/m5x7) |
| **monogram (extended)** | Vinícius Menézio (datagoblin) | CC0 1.0 (`credits.txt`: „free and Creative Commons Zero”) | 16 | 7 / 5 / 2 | tak (6 px na znak) | tylko `monogram-extended.ttf`; zwykły `monogram.ttf` nie ma Latin-1 | pełne / 127/128 (extended) | TTF, PNG+JSON, PICO-8; jest kursywa | Jak m5x7, ale monospace; nieco „gierkowy” | **[autor]** [itch.io](https://datagoblin.itch.io/monogram) |
| **Departure Mono** | Helena Zhang | OFL 1.1 (plik `LICENSE`) | 11 (autor: „increments of 11px”) | 8 / 6 / 2 | tak (7 px) | tak | pełne / 127/128 | OTF, WOFF, WOFF2 | Sans, monospace, „raport/terminal/lotnisko”; 1186 glifów | **[autor]** [GitHub](https://github.com/rektdeckard/departure-mono), v1.500 |
| **m6x11plus** (nagłówki) | Daniel Linssen | „free to use with attribution” (bez formalnej licencji) | 18 (autor: „18, 36, 54…”) | 11 / 8 / 3 | nie | tak | prawie pełne (brak m.in. ð, ², ³) / 47/128 | TTF | Grubszy, okrągły sans; czytelny, lekko „przytulny” | **[autor]** [itch.io](https://managore.itch.io/m6x11) |
| m6x11 (bez plus) | Daniel Linssen | jw. | 16 | 11 / 8 / 3 | nie | **nie** | brak / 0 | TTF | jw. | **[autor]** jw. |
| **Silkscreen** (nagłówki) | Jason Kottke / Google Fonts | OFL 1.1 | 8 | 5 / 5 (małe litery = kapitaliki) | nie | tak | pełne / 7/128 | TTF (Regular, Bold) | Same wersaliki, techniczny, „etykieta” | **[GF]** [ofl/silkscreen](https://github.com/google/fonts/tree/main/ofl/silkscreen) |
| Pixelify Sans | Stefie Justprince | OFL 1.1 | brak stałej siatki (font zmienny, wght) | 631 / 450 jednostek z 1000 | nie | tak | prawie pełne / 126/128 | TTF (zmienny) | Pikselopodobny, ale nie na siatce; nie da się trafić 1:1 w piksele | **[GF]** [ofl/pixelifysans](https://github.com/google/fonts/tree/main/ofl/pixelifysans) |
| Cozette | the-moonwitch (slavfox) | MIT | 13 (6×13, wersaliki 8) | 8 / ? / 3 | tak | nie sprawdziłem | „glify terminalowe” | BDF, OTB, PSF; TTF tylko jako wektor | Terminal; autor sam pisze, że wersja wektorowa renderuje się „terrible” | **[autor]** [GitHub](https://github.com/the-moonwitch/Cozette) |
| Ultimate Oldschool PC Font Pack (Ac437/Px437) | VileR | CC BY-SA 4.0 („for any purpose”, uznanie „VileR” + link) | zależnie od fontu (8×8, 8×14, 8×16…) | — | tak | 437: częściowo (Æ æ Å å jest w CP437, Ø ø nie); Plus: ~780 znaków | — | TTF, FON | Autentyczny DOS/BIOS; za „komputerowy” na dialogi | **[autor]** [int10h.org readme](https://int10h.org/oldschool-pc-fonts/readme/) |
| Kenney Fonts | Kenney | CC0 | nie mierzyłem | — | — | nie sprawdziłem | nie sprawdziłem | — | Strona nie wymienia nazw ani pokrycia | **[autor]** [kenney.nl](https://kenney.nl/assets/kenney-fonts) |
| Pixel Operator | Jayvee Enaguas | CC0 wg lustra; **repo autora (NotABug) 404** | 16 (wg opisu, nie mierzyłem) | — | jest wariant Mono | nie sprawdziłem | — | TTF | Neutralny sans, dobry kandydat, gdyby znalazło się pierwotne źródło | **[lustro]** [DaFont](https://www.dafont.com/pixel-operator.font), [AUR](https://aur.archlinux.org/packages/ttf-pixeloperator) |
| VT323, Press Start 2P, Tiny5, Micro 5, Jersey 10/15 | różni | OFL 1.1 (katalog `ofl/` + `OFL.txt` w `google/fonts`) | nie mierzyłem | — | — | — | — | TTF | Terminal CRT / arkada / display | **[GF]** [google/fonts](https://github.com/google/fonts/tree/main/ofl) |
| IBM Plex Sans (porównawczy, gładki) | IBM / Mike Abbink, Bold Monday | OFL 1.1, Reserved Font Name „Plex” | — (wektorowy) | 698 / 516 jednostek z 1000 | nie | tak | pełne / 128/128 | TTF (zmienny: wdth, wght) | Trzeźwy grotesk, „skandynawsko-biurowy” | **[GF]** [ofl/ibmplexsans](https://github.com/google/fonts/tree/main/ofl/ibmplexsans) |

Nie sprawdzałem: Terminus i Unifont (bitmapowe fonty systemowe, wersje TTF to konwersje osób trzecich; ton „konsola Linuksa”), Alagard/Romulus (fantasy, poza tonem), Habbo i Born2bSportyV2 (nie znalazłem pierwotnej strony z licencją, więc nie przypisuję im żadnej).

### 1.1 Uwagi o licencjach

- **CC0 (m5x7, monogram, Kenney):** bez warunków. Uznanie autora w napisach i tak warto dać **[wniosek]**.
- **OFL 1.1 (Ark Pixel, Departure Mono, Silkscreen, IBM Plex Sans):** wolno osadzać w grze i sprzedawać grę. Nie wolno sprzedawać samego fontu. Zmodyfikowana wersja (np. podzbiór znaków) nie może nosić Reserved Font Name. Dotyczy to Plex („Plex”). Ark Pixel ma 5,3 MB, bo zawiera wszystkie glify CJK; na wydanie warto go przyciąć do łaciny i nazwać inaczej **[wniosek]**.
- **m6x11/m6x11plus:** „free to use with attribution”, bez formalnego tekstu licencji. Do gry komercyjnej wystarczy, ale trzeba dać uznanie „m6x11 by Daniel Linssen”. Treść zapisałem w `m6x11plus.LICENSE.txt`.
- **m5x7:** paczka nie zawiera pliku licencji. Licencję ze strony autora (CC0) zapisałem w `m5x7.LICENSE.txt`.
- **Ac437 (CC BY-SA 4.0):** share-alike dotyczy samego fontu i jego przeróbek, nie gry. Mimo to warunki są cięższe niż przy OFL/CC0, więc to tylko zapas.

## 2. Rozmiary w pikselach

Rozmiar czcionki = siatka × skala całkowita. Cel: wersaliki ~16–24 px na 1080p. Na 1440p skala o jeden stopień wyżej daje ten sam rozmiar kątowy (1440/1080 = 1,33).

| Font | Siatka | 1080p: `font_size` (wersaliki) | 1440p: `font_size` (wersaliki) | Uwagi |
|---|---|---|---|---|
| Ark Pixel 12px | 12 | **24** (18 px) | **36** (27 px) | ×2 / ×3; przy ×2 i średnio ~6 px na znak 80 znaków to ~960 px, czyli pół szerokości 1080p **[wniosek]** |
| m5x7 | 16 | **48** (21 px) | **64** (28 px) | ×3 / ×4; ×2 (wersaliki 14 px) za mały do ciągłego tekstu |
| Departure Mono | 11 | **22** (16 px) lub **33** (24 px) | **33** (24 px) lub **44** (32 px) | 7 px na znak: przy ×3 to 21 px/znak, czyli ~60 znaków w 1260 px |
| monogram-extended | 16 | 48 (21 px) | 64 (28 px) | jak m5x7, ale monospace |
| m6x11plus (nagłówki) | 18 | **36** (22 px) | **54** (33 px) | ×2 / ×3 |
| Silkscreen (nagłówki) | 8 | **32** (20 px) lub 40 (25 px) | **48** (30 px) | ×4–5 / ×6; tylko krótkie etykiety, same wersaliki |
| IBM Plex Sans | — | **20–22** | **26–28** | gładki, Antialiasing = Grayscale, zwykłe ustawienia |

Wymóg Godota: rozmiar czcionki musi być całkowitą wielokrotnością rozmiaru projektu, a Control musi być skalowany całkowitą wielokrotnością. Inaczej font może się rozmywać. Subpixel positioning = Disabled, inaczej piksele wychodzą nierównej szerokości. Filtr tekstur Nearest **[dok]** [Using Fonts](https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_fonts.html). Właściwości importu (`antialiasing`, `hinting`, `subpixel_positioning`, `generate_mipmaps`, `multichannel_signed_distance_field`, `fixed_size`): **[dok]** [FontFile](https://docs.godotengine.org/en/stable/classes/class_fontfile.html).

**Odstęp linii [wniosek]:** fonty pikselowe mają w metrykach ascender/descender niekoniecznie na siatce (m5x7 i monogram: ascender 10,66 px). Przy skali ×3 daje to ułamkowe linie, więc wysokość linii lepiej ustawić ręcznie (`line_spacing` w `Theme`/`LabelSettings`) na całkowitą wielokrotność skali, np. 3 × 11 = 33 px dla m5x7.

## Rekomendacja do testu

Arkusz porównawczy (zgodnie z pamięcią „decyzje wyglądu przez porównanie”): ten sam akapit dialogu (z imionami Ø/Å, np. „Søren Ødegård: …”), na tym samym panelu, w 1080p i 1440p:

1. **Ark Pixel 12px proportional:** 24 px (1080p) / 36 px (1440p). Najczytelniejszy, najbardziej neutralny; mój faworyt do długiego tekstu.
2. **m5x7:** 48 px / 64 px. Najbardziej „pikselowy”, zwarty, ale niski x-height (5 px) męczy przy długich blokach.
3. **Departure Mono:** 22 lub 33 px / 33 lub 44 px. Monospace z tonem akt i terminala. Pasuje do notatek, raportów i dokumentów śledztwa nawet, jeśli dialog dostanie inny font.
4. **Porównawczy gładki: IBM Plex Sans:** 20–22 px / 26–28 px.

Nagłówki/imiona: **m6x11plus** 36 / 54 px albo **Silkscreen** 32 / 48 px (oba pobrane).

Do ustalenia przez człowieka: czy dialog i dokumenty (notatnik, akta) mają osobne fonty (np. Ark Pixel + Departure Mono) oraz czy piksel w ogóle wygrywa z Plex Sans przy dłuższym czytaniu.
