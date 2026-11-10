> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/45-przejscie-przez-drzwi-w-scianie.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

---
id: 45
title: Przejście przez drzwi w ścianie (góra–dół)
labels: [wayfinder:prototype]
status: closed
assignee:
blocked_by: []
---

## Question

Jak Badacz (i Krogg) przechodzi przez drzwi w licu ściany między pomieszczeniem wyżej a niżej (wzorzec „pełna ściana” ze Ścian i podziału wnętrz w widoku 3/4), żeby przejście było płynne i bez błędów? Stan z Układu posterunku i mebli wycinka (`game1-proto`, gałąź `prototype/oswietlenie`, `kit/room_shell.gd`, `station_kit.gd`): przejście na piechotę przez pas ściany; ściana wokół drzwi rysowana drugi raz, y-sortowana u stóp lica (futryna i nadproże zasłaniają postać); w przejściu postać dostaje światło obu pomieszczeń; od strony pokoju wyżej trapez tolerancji przy drzwiach i zsuwanie do środka; od dołu zwykła ściana. Człowiek akceptuje płynne przejście, odrzucił: przyspieszanie w przejściu, obcinanie postaci na wierzchu ściany, przejście jako przeskok z przyciemnieniem. Do dopracowania: mignięcie głowy nad wierzchem ściany (drzwi przy ścianie 1,9 m mają ok. 1,55 m), strojenie trapezu i zsuwania, przejście Krogga (Rutyna z trasą przez drzwi), drzwi w licu przy kilku drzwiach w jednej ścianie.

## Poza zakresem (2026-11-01)

Decyzja człowieka: pominięte. Obecne podejście (płynne przejście na piechotę, opisane w pytaniu) zostaje, błędy naprawiamy przy implementacji.
