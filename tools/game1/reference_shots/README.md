# Zrzuty referencyjne i porównywarka

Wygląd prototypu jest wymaganiem (`docs/spec-wycinka.md`, §14). Referencja leży w `art/reference/prototype/`, a `compare.mjs` pokazuje, czym różni się od niej inny zestaw zrzutów.

## Co jest w zestawie

Cały posterunek mieści się w jednej klatce 960×540, a ekspozycja nie zależy od pozycji gracza (ADR 0007). Zestaw to więc jedna klatka na godzinę i `manifest.json` z prostokątami Pomieszczeń:

| Pole | Znaczenie |
|---|---|
| `frames` | identyfikator, godzina i plik każdej klatki |
| `rooms` | `hall`, `corridor`, `office`, `break_room`, `cells`: `rect` to Pomieszczenie ze ścianami |
| `source` | gałąź i commit prototypu, niezacommitowane zmiany, wersja Godota, argumenty |

Godziny: świt 7:30, wschód 8:15, ranek 10:00, dzień 12:00, popołudnie 15:00, zachód 16:15, złota godzina 17:00, niebieska godzina 17:36, noc 22:00.

Sala jest w wariancie „same lampy” (§11). Skrypt przerywa pracę bez `--hall=lampy`.

Na zrzutach nie ma Badacza ani Krogga, bo Pomieszczenia porównujemy, zanim postacie trafią do gry. **Światło na postaciach nie jest więc mierzone.**

Nie ma też śniegu, bo płatki są losowe i dwie klatki nigdy nie byłyby zgodne w szybach. Zrzuty gry też go ukrywają (śnieg doszedł w tickecie 27, opis w `26-snieg-za-oknami.md`).

## Odtworzenie referencji

Referencji nie nadpisujemy w ramach strojenia. Skrypt leży w `game1` i steruje sceną prototypu z zewnątrz, więc kod prototypu się nie zmienia. Otwiera okno na kilka sekund, bo renderowanie wymaga GPU i nie działa z `--headless`.

W PowerShellu, z katalogu `game1`, przy prototypie na gałęzi `prototype/oswietlenie`:

```powershell
.\tools\godot\Godot_v4.7.2-stable_win64_console.exe `
  --path ..\game1-proto\prototype\lighting `
  --script "$PWD\tools\reference_shots\capture_prototype.gd" `
  -- --hall=lampy "--out=$PWD\art\reference\prototype"
```

Kurz i ziarno są losowe, więc pliki PNG nigdy nie będą identyczne bajt w bajt. Nowy zestaw powinien przejść porównanie ze starym bez różnic.

## Zrzuty gry

Skrypt `capture_game.gd` leży poza grą i steruje sceną `Main` z zewnątrz, bo gra nie ma flag zrzutów (§14). Godziny i nazwy plików bierze z manifestu referencji. Otwiera okno na kilka sekund. Ukrywa Badacza, bo w referencji nie ma postaci. Ukrywa też śnieg. Ticket 07 musi dopisać ukrywanie Krogga.

W PowerShellu, z katalogu `game1`:

```powershell
.\tools\godot\Godot_v4.7.2-stable_win64_console.exe `
  --path game `
  --script "$PWD\tools\reference_shots\capture_game.gd" `
  -- "--out=<katalog-zrzutow>"
```

## Baza gry

Ticket 27 celowo zmienił wygląd względem prototypu (gabinet, sala z korytarzem jako jedna przestrzeń, cień tylko pod tylną ścianą, okna nocą). Od tego momentu wzorcem dla kolejnych ticketów jest zestaw zrzutów gry w `art/reference/game/`, z tym samym manifestem godzin i Pomieszczeń. Referencja prototypu zostaje bez zmian jako źródło. Bazę gry odtwarza się skryptem `capture_game.gd` z `"--out=$PWD\art\reference\game"`, tylko po zaakceptowanej przez człowieka zmianie wyglądu.

## Porównanie

```powershell
node tools\reference_shots\compare.mjs art\reference\prototype <katalog-zrzutow> [--out=<katalog>] [--rooms=break_room,office]
```

- Zestaw do porównania musi mieć pliki PNG o tych samych nazwach. Odczytywany jest tylko manifest referencji.
- `--rooms` ogranicza porównanie do Pomieszczeń już przeniesionych do gry.
- Raport wypisuje godzinę, Pomieszczenia i liczbę różniących się bloków. Brakująca klatka lub inny rozmiar też są różnicą.
- Obrazy różnicy trafiają domyślnie do `<katalog-zrzutow>/_diff/`, po jednym na klatkę z różnicą. Czerń oznacza brak zmiany, szarość zmianę wzmocnioną 8×, czerwień bloki ponad progiem, a żółta ramka Pomieszczenie z różnicą.
- Kod wyjścia: `0` brak różnic, `1` różnice, `2` błędne wywołanie lub nieczytelny zestaw.

## Progi

Klatka jest dzielona na bloki 8×8, a dla każdego liczone są dwie średnie kanału (w skali 0–255). Blok liczy się jako różnica, gdy przekroczy którykolwiek próg:

- **przesunięcie** (średnia ze znakiem) wykrywa zmianę światła lub koloru,
- **rozbieżność** (średnia bezwzględna) wykrywa teksturę przesuniętą o piksel, której różnice ze znakiem się znoszą.

| Miara | Próg | Największy szum |
|---|---|---|
| przesunięcie | 6 | 4,08 |
| rozbieżność | 8 | 5,25 |

Szum zmierzono na trzech przebiegach tej samej sceny, porównanych parami (9 klatek). Pochodzi głównie z kurzu w smugach i z ziarna. Progi leżą w `comparison.mjs`.

Ograniczenia:

- Równomierna zmiana o mniej niż 6/255 przechodzi niezauważona, choć tak mała różnica jest ledwo widoczna.
- Porównywane są tylko prostokąty Pomieszczeń. Sąsiednie prostokąty dzielą pas wierzchu ściany, więc różnica w nim może wskazać oba Pomieszczenia.
- Lampy w sali zmienią się w tickecie 23. Od tego momentu sala będzie zgłaszana jako różnica i tę część raportu ocenia człowiek.

Porównywarka mierzy, gdzie obraz się zmienił. Ostateczną ocenę „widoczne gołym okiem” daje człowiek (§14 punkt 4).

## Testy

```powershell
node --test "tools/reference_shots/*.test.mjs"
```
