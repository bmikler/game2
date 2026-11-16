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

## Stan (2026-11-16, Claude) — w toku, nie do sprawdzenia

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
