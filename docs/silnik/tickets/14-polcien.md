---
id: 14
title: Półcień z geometrii
labels: [ready-for-agent]
status: closed
assignee:
blocked_by: [06]
---

## Co zbudować

Jeden półcień dla każdego Źródła i Przesłony: rozmiar Źródła × (przesłona→odbiornik) / (źródło→przesłona), × mnożnik z Zestawu, przycięty do maksimum w px. Tarcza słońca z Krzywych doby. Wysoki komin lub słup w półcieniu, słońce w kamerę nad dachami.

## Kryteria akceptacji

- [x] Jedna formuła w funkcji widoczności (`penumbra_width` / `penumbra_scale` w `visibility.gdshaderinc`, słońce i lampy).
- [x] Mnożnik i maksimum w px w Zestawie (`penumbra_gain`, `penumbra_max_px`).
- [x] Bramka: półcień szerszy dalej od Przesłony i przy większej tarczy (`test_light_buffer_gpu.gd`, też maksimum i wyłączenie).

## Jak sprawdzić

Uliczka, 8:00 i 13:00: cień komina ostry przy podstawie, miękki dalej. Rano słońce nad dachami w stronę kamery: cienie idą do widza i są czytelne.

## Stan (2026-11-17)

Zrobione na gałęzi `silnik-14-polcien`. F1 „Półcień”: „z geometrii (t14)” / „bez (przed t14)” (ostre cienie słońca, lampy z samego rozmiaru); przełącznik trafia do opisu zrzutu. Półcień liczony tylko przy krawędziach ostrego cienia (przebieg półcienia po buforze z ostrymi cieniami): 14,6 ms na klatkę wobec 10,7 ms bez. Lampa nad drzwiami sklepu świeci tylko nocą (jej krąg na słonecznym chodniku przeskakiwał poziom A′). Zamknięty 2026-11-17 po sprawdzeniu człowieka: „ładnie to wygląda, jest 60 fps”.
