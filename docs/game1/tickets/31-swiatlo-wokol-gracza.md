---
id: 31
title: Światło wokół gracza nocą w plenerze
labels: [wayfinder:research]
status: closed
assignee: claude-research
blocked_by: []
---

> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/31-swiatlo-wokol-gracza.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

## Question

Jak gry 2D i 2.5D z ciemnymi nocnymi plenerami (widok z góry lub 3/4, pixel art z dynamicznym światłem, gry śledcze i horrory) utrzymują czytelność postaci gracza i najbliższego otoczenia bez latarki? Szukamy „lekkiego światła wokół gracza”: kto to robi (przykłady gier, zrzuty lub opisy), jak to jest uzasadnione w świecie gry (żadne, poświata, odbicie od śniegu) i jak gracze to odbierają (czy psuje klimat lub realizm). Jak to zrobić w Godot 4 przy naszym zestawie oświetlenia: reguła ekspozycji na przestrzeń, światło 2D z maską, normal mapy, HDR 2D?

Wejście: Zestaw oświetlenia pomieszczeń i plenerów (ticket 30, krok 5): noc w plenerze bez księżyca, chłodny ambient „śnieg i łuna”, latarnie sodowe i rtęciowe. Latarka jest osobnym tematem we mgle mapy.

## Resolution

Znane gry z ciemnymi nocami (Don't Starve, Darkwood, Hollow Knight, Project Zomboid, Core Keeper) nie dają graczowi darmowej poświaty. Ciemność jest tam mechaniką, a światło zasobem (latarka, lampion, pierścień w Stardew). Darmowe światło wokół postaci ma Diablo I/II jako statystykę bez uzasadnienia, a najbliższą analogią jest kinowe „Obie light”: słabe, niewidoczne jako źródło, akceptowane przez widza. Gracze częściej narzekają na zbyt ciemną noc niż na sztuczne doświetlenie. W Godot 4 zalecany start to `PointLight2D` jako dziecko gracza z maską tylko na postać gracza (bez kolizji z maskami przestrzeni) i energią z reguły ekspozycji (`lux_p` ok. 0,5–2 lx × `X`). Reguła sama gasi to światło we wnętrzach i daje ok. 10–15% ambientu nocą na ulicy. Do tego rim z 22c §6.7. Opcje do decyzji: słaba plama na podłogę bieżącej przestrzeni (ryzyko widocznego okręgu na śniegu), jaśniejsza noc bez światła gracza, winieta tylko jako dodatek.

Szczegóły: docs/research/31-swiatlo-wokol-gracza.md
