---
id: 10
title: Poligon Ulica w bryłach: układ, głębia, skala budynków
labels: [wayfinder:prototype]
status: closed
assignee: claude
blocked_by: [04, 09]
---

## Question

Zbudować Poligon Ulica z brył rysowanych kodem w przyjętym rzucie: krótka ulica, 3 budynki różnej skali (dom jednorodzinny piętrowy do wejścia, budynek usługowy z witrynami, budynek tylko jako fasada w głębi), chodnik, latarnie, drzewa, auto, śnieg. Warianty głębi i wysokości fasad wg researchu Miasto i budynki w 3/4. Decyzja człowieka: układ i skala budynków z zewnątrz, ile ulicy w kadrze.

Z Wyboru Kotwic stylu: niskie 3/4 (Beat Cop); główna ulica w poziomie, w głąb krótka przecznica/brama/schody, przenikanie budynków z przodu. Śnieg bez wzorca: pierwsze podejście tutaj.

**Z Rzutu, skali i rozdzielczości:** przenikania budynków **nie ma** (decyzja człowieka); głębię ogrywa układ miasta, a teren w pasie wysokość ÷ 0,60 za budynkiem jest niedostępny. Stałe: kąt 0,60, 40 px/m, postać 72 px, kadr 960×540, piętro fasady 1,6 × postać. Punkt startu: kwartał `style-lab/poligony/rzut_ulica` (dwie ulice, podwórka, przecznica, furtka, murek od kamery). Do sprawdzenia: chód w pionie przy 0,60 wygląda na wolniejszy.

## Notatki z oceny (2026-11-09)

Prototyp: `style-lab/poligony/ulica_bryly.gd`, `style-lab/ulica.bat`.

- Zakres zawężony: układ miasta (taras, przecznica, cofnięcia) i szerokość ulicy to projektowanie poziomów w grze, nie decyzja stylu; tu tylko to, co wchodzi do Przepisu budynków: proporcje budynku, reguła dachu, zmiana poziomu.
- Zdecydowane: piętro fasady roboczo 1,6 × postać (możliwe 1,3; ostatecznie rozmiar fasady i rozdzielczość po makiecie ulicy i wnętrza z teksturami); dachy mieszane, spadek różny w różnych budynkach; głębia budynków na zewnątrz 50% prawdziwej (do ogrania z rozmiarem wnętrza: budynek z zewnątrz mniejszy niż mapa wnętrza i dodatkowo zwężony w głąb; nie do każdego budynku da się wejść) (dom szczytem do ulicy, sklep płaski, kamienica kalenicą wzdłuż); chód w pionie ×1 (bez kompensacji).
- Schody (research „Jak pokazać wchodzenie po schodach i progach w rzucie 3/4”): warianty A czołowe i B boczne przyjęte; pojedynczych stopni na progach raczej nie robimy.

## Resolution

Prototyp: `style-lab/poligony/ulica_bryly.gd` (`style-lab/ulica.bat`), README style-lab, sekcja „Prototyp Poligonu Ulica w bryłach”.

- **Poza mapą (do gry):** układ głębi (taras, przecznica T, cofnięcia) różny w różnych miejscach miasta; szerokość ulicy wybierana przy budowie całego miasta.
- **Fasada:** piętro roboczo 1,6 × postać (2,9 m), możliwe 1,3; ostatecznie po makiecie z teksturami (ticket „Makieta ulicy i wnętrza z teksturami”).
- **Dachy:** mieszane (szczytem do ulicy, płaskie, kalenicą wzdłuż); spadek różny w różnych budynkach.
- **Głębia budynków na zewnątrz: 50% prawdziwej** (dach i obrys). Budynek z zewnątrz jest mniejszy niż mapa wnętrza i dodatkowo ściśnięty w głąb; do ogrania na Poligonie Dom.
- **Chód w pionie:** ×1 na ekranie (bez kompensacji kąta).
- **Schody:** pozycja stóp płynna, postać rysowana ze schodkowym przesunięciem 8 px (0,2 m) na stopień, wygładzenie 0,08 s, wolniej na biegu (×0,6 w górę, ×0,7 w dół; boczne ×0,75); bieg czołowy z policzkami (A) i boczny wzdłuż muru z podestem u góry i przemapowaniem lewo/prawo na skos 1:2 (B), oba OK. Bez nowych klatek animacji. Pojedynczych stopni na progach drzwi raczej nie robimy.
- Zmiany we wspólnym kodzie style-lab: `ShapePainter` z wielokątami, `PlaceholderActor` z `visual_offset`, `zone_speed`, `stair_slope`, `vertical_speed`; dom wraca na ostatnią ulicę (`RzutPoligon.street_scene`); skracanie długich nazw zrzutów (limit ścieżki Windows).
