---
id: 02
title: Sprawdzian assetu w prototypie
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [01]
---

## Co zbudować

Odpowiedź na pytanie człowieka, zanim powstanie silnik: czy sprite z ComfyUI na uproszczonej Bryle, oświetlony i cieniowany z Bryły, wygląda dobrze. Prototyp do wyrzucenia na gałęzi od `proto-09-nakladanie` (istniejący raycast pudełek, słońce, niebo, lampy, A′): sprite jako albedo na Bryle (pozycja z trafienia w ścianę Bryły, normalna ze ściany albo z mapy normalnych), cień z Brył. Trzy meble z „Prowadnice v2”. Warianty w F1:

- sprite z wypalonym światłem (dzisiejszy prompt) / płaskie światło („flat lighting, no shadows”, cień i podłoga w negatywnym, albedo w średnich jasnościach);
- normalne ze ścian Bryły / z Blendera;
- siła modelowania 0 / średnia / pełna;
- piksele bez ściany Bryły pod spodem (nogi, oparcie): rzut na najbliższą ścianę / mapa wysokości z Blendera.

Sceny: dzień przy oknie lub w słońcu, noc z lampą z boku i z tyłu.

**Spójność z postaciami (człowiek, 2026-11-15):** cała grafika ma być jednym stylem, więc meble generujemy tak jak postacie z Przepisu postaci (`docs/grafika/przepis-postaci.md`: malarski, lekko rysunkowy styl, stały prompt stylu, Qwen-Image-Edit, lokalna pikselizacja), a nie starą drogą SDXL + pixel-art-xl. Do porównania w F1 2–3 drogi generacji, np.:

- Qwen-Image-Edit: prowadnica mebla jako wzór kształtu i kąta + sprite detektywa lub bibliotekarki jako wzór stylu („same drawing style as image 2”);
- FLUX.2 klein ze stałym promptem stylu z Przepisu postaci (z prowadnicą, jeśli FLUX ją przyjmie);
- stara droga SDXL + ControlNet depth + pixel-art-xl tylko jako odniesienie.

Pikselizacja tym samym łańcuchem co postacie (ta sama gęstość pikseli i obrys), ewentualnie z kwantyzacją palety jako wariant. W scenie obok mebli stoi detektyw albo bibliotekarka, żeby oceniać spójność stylu, nie sam mebel.

## Kryteria akceptacji

- [ ] Przed generacją pytanie do człowieka (co, po co, koszt: kilkanaście–kilkadziesiąt obrazów lokalnie w ComfyUI, 0 zł); odrzucone obrazy usuwane od razu.
- [ ] Meble wygenerowane w stylu postaci; detektyw lub bibliotekarka w scenie obok; ocena człowieka: czy mebel i postać wyglądają jak z jednej gry.
- [ ] Wycięcie maską z renderu (bez tła i cienia generatora).
- [ ] Pikselowanie obrazu z ComfyUI do 40 px/m: zmniejszenie wyrównane do siatki pikseli i punktu zaczepienia (bez podwójnych i poszarpanych pikseli) z kwantyzacją palety, nie samym nearest; jeden skrypt dla wszystkich mebli, porównanie 2–3 sposobów zmniejszania w F1.
- [ ] Wszystkie warianty przełączane na żywo w F1.
- [ ] Kod prototypu poza `lighting/` i poza przyszłym addonem; nie trafia do silnika.
- [ ] Zapis oceny człowieka w tickecie.

## Jak sprawdzić

Uruchom prototyp, przełączaj meble i warianty w dzień i w nocy. Pytania: czy mebel wygląda jak część sceny, czy cień zgadza się z obrazem, czy lampa z boku daje wiarygodne światło, który wariant sprite'a i normalnych wygląda najlepiej.
