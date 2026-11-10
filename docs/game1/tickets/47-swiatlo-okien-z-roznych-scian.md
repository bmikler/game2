---
id: 47
title: Światło z okien w różnych ścianach w widoku 3/4
labels: [wayfinder:research]
status: closed
assignee: bmikler
blocked_by: []
---

> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/47-swiatlo-okien-z-roznych-scian.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

## Question

Jak zgrać światło z okien w ścianie tylnej (z widokiem, szybą w licu i promieniami w powietrzu) z oknami w ścianach bocznych i przedniej, które w widoku 3/4 są tylko szybką w wierzchu ściany? Stan z Układu posterunku i mebli wycinka (`game1-proto`, `kit/window_light.gd`, `kit/side_window_light.gd`): okna boczne i przednie dają smugę w kształcie światła z drzwi (DOOR_SPILL), która jest za mocna i wygląda „jakby lampa świeciła prosto w okno”; kolor i siła nie zgadzają się z promieniami okien tylnych; promienie okien tylnych zwężają się w głąb pokoju (człowiek chce, żeby się rozszerzały; próby z rozszerzaniem w `shots/spread_*`). Zebrać wnioski z wcześniejszych researchów (22a–22d, Zestaw oświetlenia pomieszczeń i plenerów / ADR 0007, Ściany i podział wnętrz w widoku 3/4) i z gier 2D w rzucie 3/4 / pixel art z dynamicznym światłem: jak pokazują światło z okien w ścianach niewidocznych lub widocznych tylko jako wierzch, jak ono pada (kształt, kierunek, zanik, kolor nieba vs słońca), jak zgrać siłę i kolor okien z różnych stron i pór dnia w jednej regule. Wynik: 1–2 wzorce z kosztem w naszym zestawie i konkretne parametry do prototypu. Wyniki w `docs/research/47-swiatlo-okien-z-roznych-scian.md`.

## Resolution

Wyniki: `docs/research/47-swiatlo-okien-z-roznych-scian.md` (tagi zweryfikowane / z pamięci / wniosek; liczby zwężenia z rachunku, nie ze zrzutów).

- Promienie okien tylnych zwężają się przez geometrię: otoczka wypukła rogów szyby i ich rzutów jest przy szybie szeroka w poprzek osi (w·cosθ + h·sinθ), na końcu zostają tylko rzuty górnych rogów (w·cosθ); przy φ ≈ ±50° okno gabinetu traci ok. 40% szerokości, szczelina celi ok. 4,5× („igły”). `Polygon2D` triangulowany po przekątnych i liniowy zanik do 0 pogarszają kształt; `beam_spread` proporcjonalny do długości rozmywał smugi w poświatę.
- Rozszerzanie: jawna wstęga zamiast otoczki: rdzeń o szerokości szyby + pióra po bokach (do 0,45·szerokości, 3–16 px), daleki koniec ok. 1,9×, 6 odcinków wzdłuż osi z indeksami `polygons`, zanik tylko wzdłuż osi (płasko do 12%, potem (1−v)^1,4), bez zmniejszania jasności przy rozszerzeniu.
- Okno boczne „jak lampa”: tekstura DOOR_SPILL (maksimum przy ścianie, klin z punktu), energia ok. 4× większa niż promieni tylnych, kolor nieba = kolor słońca, kierunek zawsze prostopadły do ściany.
- Jedna reguła dla wszystkich ścian: wspólny wektor słońca na ekranie, okno daje tylko krawędź startu i bramkę facing = smoothstep(0, 0,25, cos(A_słońca − A_ściany)), więc smugi w pokoju są równoległe; siła k = 0,13·sun_k·clamp(sqrt(A_szkła/1,42), 0,6, 1)·facing (okna boczne ×0,6–0,8); słońce w `sun_color`, niebo zawsze `sky_color` z energią jak u okien tylnych.
- **Rekomendacja, wzorzec A:** jeden budowniczy wstęgi dla okien tylnych i bocznych; okno boczne zaczyna smugę od odcinka na linii ściany podniesionego o 1,6 m i dostaje obróconą poduszkę nieba (SKY_PILLOW) zamiast DOOR_SPILL. Wzorzec B (bez smugi w powietrzu, tylko poduszka nieba i miękka plama słońca) na arkusz porównawczy. Okna północne (przednie) nie dostają słońca w lutym: tylko chłodna poduszka nieba.
- Gry 3/4 zwykle unikają okien w niewidocznych ścianach; Moonlighter daje pod nimi miękkie plamy; źródeł o technice Eastward, Octopath, Sea of Stars i Replaced brak.
- Arkusz do prototypu: sala, gabinet, cela × 9:00, 12:30, 15:30, niebieska godzina, noc; wiersze: stan obecny, A z rozszerzeniem 1,5× / 1,9× / 2,4×, B.
