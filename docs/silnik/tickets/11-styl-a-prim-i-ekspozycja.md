---
id: 11
title: Stylizacja A′ i ekspozycja automatyczna
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [08]
---

## Co zbudować

A′ (poziomy EV, szew ditheru o stałej szerokości w px, kotwica `Y_ref`) kwantyzuje oświetlenie powierzchni. Dwa tryby w Zestawie (A′ na luminancji sumy z ciągłą barwą; A′ osobno na kanale naturalnym i sztucznym, potem suma), przełączane na żywo w F1. Ekspozycja automatyczna z jasności odniesienia Lokacji i Stanu doby. Zestawy `plener.tres` i `wnetrza.tres` z punktami startowymi ze Ściągi.

## Kryteria akceptacji

- [ ] Zestaw strojenia ze wszystkimi polami ze specyfikacji, dwa pliki domyślne.
- [ ] Obraz = albedo × stylizowane światło; rozproszenie dodawane po A′.
- [ ] Przełącznik trybu A′ w F1.
- [ ] Bramka: liczba poziomów zgodna z Zestawem; szerokość szwu w px stała.
- [ ] Brak ręcznej ekspozycji na Lokację.

## Jak sprawdzić

Uliczka, przewiń dobę: wyraźne poziomy z wąskim szwem ditheru, noc ciemna, ale czytelna; mebel z ComfyUI nie gryzie się z ditherem.

## Stan (2026-11-16, Claude, trzecia runda) — do sprawdzenia przez człowieka

**Problem znaleziony przez człowieka (zrzuty 9:41 i 12:01):** w cieniu kamienic i w słońcu przy narożnikach widać duże
łukowate „plamy” z krawędzią. Przyczyna: A′ tnie na poziomy także światło nieba, które zmienia się łagodnie na
metrach (mniej nieba przy ścianie). Granica poziomu na takim spadku (100–300 px) to płaskie pole z wąskim szwem, czyli
krawędź w kształcie linii równego udziału nieba. `full_dither_px` tego nie łapie (to długie kroki). Fizyka jest dobra.

**Zmiana modelu (decyzja człowieka: „go”, warianty do porównania):**
- Bufor zapisuje w alfie udział słońca (cosinus × widoczność, z rim light), więc A′ odróżnia światło słońca od reszty
  (niebo, ambient).
- Nowe pole Zestawu `sky_style` i przełącznik F1 „Światło nieba”: **A** poziomy na sumie (jak dotąd, domyślnie),
  **B** poziomy tylko dla słońca, niebo gładkie, **C** poziomy tylko dla słońca, niebo zawsze w ditherze (bez pól).
- Testy: B przepuszcza światło bez słońca bez zmian, dodaje słońce na jego poziomie z ostrą krawędzią; C śledzi długi
  spadek nieba bez pola i krawędzi (A go nie śledzi); krawędź cienia słońca 1 px w B i C; alfa bufora = cosinus słońca.
  `node tools/test.mjs`: 164 zielone. Sprawdzone odtworzeniem zrzutów człowieka: w B i C plamy znikają.
- Czarne prostokąty na zrzutach to obszar poza Lokacją (brak ziemi za d = −40 m), nie błąd światła.

- Sprzątanie F1 (człowiek: panel za długi, przełącznik nieba był pod krawędzią okna): usunięty „Tryb A′” (bez kanału
  sztucznego oba tryby dają ten sam obraz; przełącznik wraca w tickecie 13, pole `style_mode` w Zestawie zostaje) i
  długie opisy pod przełącznikami. Kryterium „Przełącznik trybu A′ w F1” przechodzi więc do ticketu 13.

**Ocena człowieka (2026-11-16):** domyślnie **B: gładkie** („jedyne, co wygląda normalnie”). C (dither) „wygląda mega
słabo”. A′ na niebie „wygląda nawet ładnie artystycznie, ale cienie nie mają sensu logicznego”. Możliwy powrót
później: ręczne globalne metody nadpisujące fizykę dla ładniejszego wyglądu. `sky_style = SMOOTH` w `outdoor.tres` i
`interior.tres` (generator `start_values.gd`); A i C zostają w F1 do porównań.

**Wariant D odrzucony i usunięty (2026-11-16):** niebo wszędzie jak na otwartym terenie, A′ na sumie (każdy cień
słońca jednym kolorem). Człowiek: „to po prostu bardziej płaska opcja gładka”.

**Do oceny w grze (przed decyzją):** te same miejsca, F1 „Światło nieba” A / B / C. Ryzyko B: gładki cień jak „HD” (t37). Ryzyko C:
drobny dither na całym cieniu jak faktura. Wybrany wariant wpiszę jako domyślny w `outdoor.tres`.

## Stan (2026-11-16, Claude, druga sesja)

Plan z research 92 zrobiony (pkt 1–4 niżej):
- **A′:** krok krótszy niż `full_dither_px` cały w ditherze, dłuższy niż 2× zostaje polem z wąskim szwem, między nimi
  `smoothstep` (`light_style.gdshader`). Nowe pole Zestawu `full_dither_px` (start 24, zakres 0–48; ostrzeżenie silnika,
  gdy > 0 i < 2 × `seam_px`).
- **F1:** „Dither krótkich kroków” 0 / 16 / 24 / 40 px (0 = A′ sprzed zmiany), także w zrzutach. Start z Zestawu.
- **Bramki stylizacji** (`test_light_style_gpu.gd`, dla każdego Wariantu z F1): brak krawędzi z krótkiego kroku (rampa
  1-D zamiast promienistej, amplituda 0,5–2 kroków, krok 8 px…`full_dither_px`; średnia 4 px śledzi wejście ±0,35 kroku,
  bez własnego skoku; Wariant 0 = stare A′ pominięty z założenia, osobny test pokazuje, że go oblewa), ostra krawędź ≤ szew
  + 1 px, ulica (krok 85–285 px) z płaskimi polami i szwem, kotwica (jaśniejsze niebo nie przesuwa granic poziomów).
- **Bramki fizyki** (`test_light_buffer_gpu.gd`): wyrocznia CPU nieba przy skrzyni 0,6 m (2/10/30/60 cm, przód i bok,
  ±0,1 EV) i skrzynia 1 m od ściany 15 m (strona ulicy 30 cm > −0,05 EV, szczelina 10 cm < −0,8 EV). Przechodzą: warstwa
  nieba liczy dobrze.
- **Kontrakt assetu:** silnik ostrzega, gdy Bryła wychodzi > 1 px poza sylwetkę sprite'a (`AssetSprite.solid_pixels_outside`,
  `Occluder.asset_warnings`). Ławka, stragan i skrzynia przechodzą; prześwity pod siedziskiem i blatem są puste
  (`RAISED_BOX` + osobne nogi; sprawdzone w danych `.tscn`, reguła 92 §5b.6 bez testu automatycznego, widok
  debug „Bryły” w F1 już jest). Plama przy meblach nie pochodzi więc z danych, tylko z A′, którą naprawia pkt 1.
- `node tools/test.mjs`: 158 zielonych.

**Do oceny w grze:** Poligon Ulica o 9:00 (skrzynia, ławka, stragan w cieniu kamienic), F1 „Dither krótkich kroków”
0 / 16 / 24 / 40. Pytanie: czy aureola przy meblach jest miękka bez pierścienia i czy pełny dither nie czyta się jak
faktura (92 §8). Do tego reszta „Jak sprawdzić” (przewinięcie doby, noc).

## Stan (2026-11-16, Claude, pierwsza sesja)

**Zrobione (commit na gałęzi `silnik-11-styl`):**
- Zestaw strojenia ze wszystkimi polami ze specyfikacji (`tuning_set.gd`; pola jeszcze nieużywane opisują numer ticketu, który ich użyje). `outdoor.tres` / `interior.tres` z generatora `tools/light_engine/start_values.gd` (poziom 0,5 EV, szew 3 px Bayer, kotwica 0).
- Osobny przebieg A′ (`buffer/light_style.gd`, `light_style.gdshader`): bufor → poziomy EV wg research 84 §6, szew ze skończonych różnic (łagodniejsza jednostronna na oś, więc skok między powierzchniami nie rozlewa szwu), wzór przypięty do pikseli Lokacji, oba tryby (na sumie / na kanałach; kanał sztuczny pusty do ticketu 13). Obraz = albedo × stylizowane światło (rozproszenie dojdzie po A′ w tickecie 22).
- Ekspozycja: jasność sceny = światło otwartego terenu × jasność odniesienia Lokacji (`exposure_reference`, teraz udział 0–1, ulica 1); kotwica `Y_ref` = niebo + ambient otwartego terenu × odniesienie (`DayState.level_anchor`).
- F1: „Tryb A′” (+ w zrzutach „tryb A′”), odczyt kotwicy w panelu.
- Testy: bramki A′ (`test/engine/test_light_style_gpu.gd`), Stan doby, Otoczenie, Poligon; `node tools/test.mjs` 145 zielone.

**Problem znaleziony przez człowieka:** meble w cieniu kamienic mają wokół siebie płaską ciemniejszą plamę z ostrą krawędzią („cień w cieniu”). Research 91 (fizyka) i 92 (silnik):
- Fizyka silnika jest dobra: zmierzone przy skrzyni w cieniu o 9:00 (odległość od ściany skrzyni): styk −0,5 EV, 20 cm −0,2, 60 cm −0,1 (rzeczywistość wg 91: −0,6…−0,8 / ok. −0,3 / ok. −0,1, miękki gradient bez krawędzi).
- Plamę z krawędzią robi A′: szew ma stałe 3 px, a krótki spadek (krok 0,5 EV na 8–28 px) zamienia się w 1–2 płaskie pierścienie.

**Do zrobienia (decyzja: plan z research 92, człowiek zdał się na Claude'a):**
1. A′: krok krótszy niż `full_dither_px` idzie w całości w dither; krok dłuższy niż 2× zostaje polem z wąskim szwem; między nimi `smoothstep` (92 §rekomendacja). Nowe pole Zestawu `full_dither_px` (start 24).
2. Warianty do porównania w F1: `full_dither_px` = 0 / 16 / 24 / 40 (bez suwaków; ticket 12 przejmie mechanizm Wariantów).
3. Bramki (92): wyrocznia CPU dla pudełka w cieniu (±0,1 EV), nakładanie przesłon przy ścianie, brak krawędzi z gradientu, ostra krawędź zostaje ostra, regresja pasów ulicy i kotwicy; puszczane też dla każdego Wariantu.
4. Kontrakt assetu: Bryła mieści się w sylwetce sprite'a, prześwity (pod blatem, siedziskiem) puste; sprawdzić ławkę i stragan.
5. Odrzucone: wariant (a) „poziomy tylko dla światła kierunkowego” (cała ulica w cieniu gładka, odrzucone w t37), „krótki zasięg zasłaniania” (sumuje przesłony). Odłożone: multi-bounce Jimeneza (0,1–0,2 EV, ew. osobny ticket, albedo jako dana Lokacji).
