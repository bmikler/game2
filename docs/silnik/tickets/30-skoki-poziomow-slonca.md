---
id: 30
title: Skoki poziomów A′ słońca na całej nasłonecznionej Lokacji
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [29]
---

## Co zbudować

Automat doby (ticket 29) znalazł na Ulicy skok, którego nikt nie zgłosił: około 15 razy na dobę (8:00, 8:10, 8:20,
8:30, 8:50, 9:30, 11:00, 14:10, 15:30, 16:10, 16:40–17:40 przy przebiegu co 10 min) 96–100 % pikseli oświetlonych
słońcem zmienia poziom A′ w jednym kroku, czyli cała nasłoneczniona część Lokacji robi się naraz o ok. 41 % jaśniejsza
albo ciemniejsza. Przy `rate` 1 rano to błysk co ok. 10 s.

Przyczyna: od poprawki z ticketu 13 (commit `cdb6fa1`) siatka poziomów słońca i lamp przy gładkim niebie stoi na
stałych luksach (`hard_anchor` w `light_style.gdshader`). Dzięki temu pasy plamy lampy stoją, ale natężenie słońca na
równej jezdni zmienia się w ciągu dnia jednocześnie wszędzie, więc cała jezdnia przechodzi przez granicę poziomu w tej
samej minucie. Ekspozycja tego nie zmienia: poziom zależy od luksów przed ekspozycją.

Do rozstrzygnięcia w tym tickecie: jak dać słońcu poziomy, które nie przeskakują całym polem (np. siatka słońca
zaczepiona o jego własne natężenie, a nie o stałe luksy), nie psując stojących pasów lamp (ticket 13).

## Kryteria akceptacji

- [ ] Reguła `sun jump` usunięta z listy `KNOWN` w `test/engine_poligons/test_day_sweep_gpu.gd`, a `node tools/test.mjs`
  jest zielony (pasy lamp dalej stoją, bez nowych zgłoszeń automatu).
- [ ] Bramka `test_gate_with_smooth_sky_a_lamps_levels_stay_while_the_sky_darkens` dalej zielona.
- [ ] Człowiek ogląda poranek i popołudnie na Ulicy (przewijanie doby) i nie widzi błysków całej jezdni.

## Jak sprawdzić

`node tools/test.mjs` (z `style-lab`): bramka doby bez znanych zgłoszeń. Plansza doby: `node tools/day_sheet.mjs 24`.
Człowiek: Poligon Ulica, godziny 7:30–9:30 i 16:00–18:00.
