---
id: 43
title: Ściany i podział wnętrz w widoku 3/4
labels: [wayfinder:research]
status: closed
assignee: bmikler
blocked_by: []
---

> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/43-sciany-wnetrz-3-4.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

## Question

Jak gry 2D w widoku 3/4 z góry (pixel art, wnętrza z kilkoma pomieszczeniami w jednej ciągłej scenie) rysują ściany? W prototypie z Układu posterunku i mebli wycinka widać tylko ściany tylne z oknami u góry każdego pomieszczenia, a ściany między pomieszczeniami (sala główna pod gabinetem i pokojem socjalnym) to płaska linia, co wygląda dziwnie. Zbadać: ściany przednie i działowe (pełne, obcięte do wysokości, przezroczyste przy graczu, sam „wierzch” ściany o grubości), ściany boczne, drzwi w ścianach działowych i bocznych, jak sąsiednie pomieszczenia są pokazywane albo ukrywane (kamera w granicach Pomieszczenia, przyciemnianie, przekrój), skąd w takim widoku wpada światło okien z boku i z dołu. Przykłady: Stardew Valley, Eastward, Replaced, Moonlighter, To the Moon, Pokémon/RPG Maker, Graveyard Keeper, Unpacking, Children of Morta i inne trafne. Wynik: 2–3 wzorce z kosztem dla solo deva (kod ścian w RoomShell, assety z ComfyUI/Pixellab) i rekomendacja dla posterunku. Wyniki w `docs/research/43-sciany-wnetrz-3-4.md`.

## Resolution

Wyniki: `docs/research/43-sciany-wnetrz-3-4.md` (zrzuty ze Steama, przy każdej tezie oznaczenie: zweryfikowane / z pamięci / wniosek).

- Gry 3/4 (Stardew Valley, Graveyard Keeper, To the Moon, Children of Morta) dają wysokość tylko ścianom zwróconym do kamery, ale **wszędzie tam, gdzie pod ścianą jest podłoga**: ściana między pokojem górnym a dolnym to wierzch ściany plus pełna ściana tylna pokoju dolnego. Ściany boczne i przednie to tylko wierzch. „Płaska linia” w prototypie wynika z `wall_height_px = 0` w sali.
- Plany nieregularne (L, schodki, wnęki): każdy fragment ma ścianę tylną na własnej wysokości w kadrze, krawędzie pionowe tylko wierzch. Geometria jest oszukana: lico ściany zajmuje w kadrze swoje miejsce, więc nic niczego nie zasłania.
- Okna w ścianach bocznych i przednich: gry z samym wierzchem ich nie rysują; propozycja: sama smuga światła wchodząca spod wierzchu ściany, ewentualnie parapet.
- Sąsiednie pomieszczenia zostają widoczne i oświetlone własnym światłem, oddzielone czernią i wierzchem ściany; żadna z badanych gier 2D nie przyciemnia pokoju, z którego wyszedł gracz.
- Pomysł człowieka (pełne ściany, przyciemnianie sąsiadów, wygaszanie zasłaniającej ściany) robią gry 3D/izometryczne (Project Zomboid, The Sims, Death Trash), nie 2D 3/4. Odradzony jako podstawa: lico zakryłoby ~104 z 144 px podłogi gabinetu, stan zależny od gracza (jak odrzucona adaptacja oka, ADR 0007), problemy ze światłem w drzwiach. Do zachowania wąska wersja: półprzezroczystość tylko, gdy postać stoi tuż za licem, jeśli test pokaże, że znika w drzwiach.
- Wzorce: A „pełna ściana” (1–2 dni, assety proceduralne), B wygaszanie/przekrój (~tydzień + strojenie), C jedno pomieszczenie na kadr (najtańsze, łamie ciągłą scenę).
- **Rekomendacja dla posterunku: A.** Sala dostaje ścianę tylną (tablice, grafik dyżurów, bez okien) z otworami drzwi do gabinetu i pokoju socjalnego; podłoga sali ok. 220 px; cela obok sali przez przerwę w wierzchu ściany bocznej (albo pod salą z kratami jako ścianą tylną); wyjście jako przerwa w wierzchu ściany przedniej z zimną smugą; wierzchy ścian grubsze (8–10 px) i prawie czarne.
- Niezweryfikowane: jak grają drzwi w licu ściany (tylko zrzuty), wnętrza Eastward, Hyper Light Drifter, CrossCode; wygląd półprzezroczystej ściany w naszym oświetleniu HDR.
- Uzupełnienie: `docs/research/43b-chef-rpg-wnetrza.md` (krótki research). Chef RPG rysuje wnętrza tak samo jak wzorzec A, a ciekawe układy daje łamaniem ściany tylnej na segmenty na różnych wysokościach (łączone skosami 45° albo uskokiem), pokojami różnej głębokości obok siebie połączonymi szerokim otworem, strefowaniem meblami i zmianą podłogi zamiast ścian; lico ściany niesie treść (okna, drzwi, regały, kominek). 8 technik do wzięcia w §5.
