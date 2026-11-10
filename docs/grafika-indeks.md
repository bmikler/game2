# Grafika: indeks materiałów

Stan: 2026-11-03. Punkt wejścia dla pracy nad wyborem grafiki i pipeline'em jej generowania w game2. **Nic tu nie jest decyzją dla game2**: ustalenia game1 (`repo/game1`) i notatki to materiał wejściowy, a pomysły z `grafika.md` są do sprawdzenia.

## Źródło referencji: game1, nie game1-proto

Referencją jest zawsze `repo/game1` (gra po strojeniu świateł). Osobny prototyp oświetlenia `repo/game1-proto` ma błędy w świetle i nie jest referencją. Część skopiowanych notatek i ticketów (np. `22c`, `22d`, `35b`, `43`, `46`, `47`, tickety 19, 30, 47) odwołuje się do kodu w `game1-proto/prototype/lighting/`. Ten sam zestaw został przeniesiony do game1 i tam dostrojony, więc aktualną wersję ma `reference/game1/lighting/`. Zrzutów z game1-proto nie kopiowano.

## Zacznij od

1. `docs/grafika.md`: streszczenie wniosków z game1 i pomysły do sprawdzenia (rzut, narzędzia, pipeline, obroty i układ mebli, ściany, drzwi, okna, światło, Chef RPG, otwarte pytania).
2. `input-fixed.txt` (sekcja „Grafika”): założenia użytkownika dla game2.
3. `docs/swiatlo-kolory-game1.md`: kolory światła z game1, które się sprawdziły.

## Research napisany dla game2 (2026-11-03)

| Plik | Temat |
|---|---|
| `research/51-spojna-grafika-3-4.md` | spójny rzut i styl: przyczyny niespójności w game1, narzędzia, pipeline z geometrią jako wejściem, guardrails (pisane jeszcze w game1) |
| `research/51b-obroty-i-uklad-obiektow-3-4.md` | tył, bok i ukos mebli, układ pokoju, zasłanianie, kolizje, werdykt o fotelu |
| `research/52-narzedzia-pixel-art.md` | porównanie narzędzi poza Pixellab, licencje, ceny, shortlista i protokół testu |
| `research/53-okna-boczne-i-dolne.md` | okna w ścianach bocznych i dolnych: 13 technik, zestawy S0/S1/K, test czytelności |
| `research/54-chef-rpg-styl.md` | Chef RPG jako wzorzec: rzut, skala, meble, okna, kontur, paleta (kolorystyki nie przenosimy) |

Uwaga: numery 52–54 w game2 to inne tematy niż notatki 52–54 w game1 (dziennik, poszlaki, HUD), których tu nie kopiowano.

## Research z game1 (kopie w `docs/research/`)

| Plik | Temat |
|---|---|
| `02-pixel-art-oswietlenie.md` | pixel art z dynamicznym światłem, normal mapy, wymagania wobec assetów |
| `06-widok-i-swiat.md` | widok i struktura świata w grach śledczych 2D |
| `08-assety-ai.md` | generowanie pixel artu przez AI (przegląd z początku game1) |
| `11b-widok-top-down.md` | widok 3/4, rozmiary kafli i postaci, precedensy (Graveyard Keeper 2 w 3D) |
| `22a-kolory-wnetrz.md` | kolory wnętrz, światło pory dnia, struktura palety |
| `22b-uklad-pokoju-socjalnego.md` | układ pokoju: wymiary, okna, ogrzewanie, słońce |
| `22c-gra-swiatla.md` | smugi z okna, plama w kształcie okna, odbicia, cienie mebli w plamie, kurz |
| `22d-balans-swiatla-i-skalowanie.md` | balans światła dziennego i sztucznego, maski świateł, koszt |
| `24a-generatory-mcp.md` | generatory pixel artu sterowane przez Claude (MCP/API) |
| `24b-blender-mcp.md` | Blender sterowany przez Claude: koncept → 3D → sprite z normal mapą |
| `24c-skrypty-i-cli.md` | edytory 2D, skrypty i CLI: czysty sprite, normal mapa |
| `24d-concept-art.md` | concept art przez AI (ideacja) |
| `27b-czcionki-pikselowe.md` | czcionki pikselowe UI |
| `27c-portrety-w-kolumnie.md` | portrety mówcy w dialogach |
| `31-swiatlo-wokol-gracza.md` | światło wokół gracza nocą w plenerze |
| `35b-okna-w-wierzchu-sciany.md` (+ 2 PNG) | próby okien w wierzchu ściany, przegląd gier |
| `43-sciany-wnetrz-3-4.md` | ściany i podział wnętrz w 3/4 (wzorzec A) |
| `43b-chef-rpg-wnetrza.md` | Chef RPG: ściany, wnęki, pokoje różnej głębokości |
| `46-generowanie-mebli-3-4.md` | meble w spójnym rzucie, rachunek kamery 45° + √2, drogi A/B/C |
| `47-swiatlo-okien-z-roznych-scian.md` | światło okien z różnych ścian |
| `56-drzwi-w-licu-sciany.md` | drzwi w licu ściany, strefa „za ścianą” |
| `57-pixellab-meble.md` | Pixellab: meble i drobiazgi w rzucie gry, wnioski z prób |

## Decyzje i tickety game1 (`docs/game1/`)

- `adr/0002-widok-3-4-i-drabinka-swiatla.md`: widok 3/4, skala 1 m = 40 px, baza 960×540, wysokość ścian, postać ok. 75 px.
- `adr/0007-zestaw-oswietlenia-ekspozycja-na-przestrzen.md`: system światła (luksy, ekspozycja, sRGB).
- `tickets/`: zamknięte tickety graficzne z wynikami: 02, 06, 08, 11, 19, 22, 24–31, 35, 43–48. Ticket 48 (meble z Blendera) został pominięty: game1 używał mebli z Pixellab, bez Blendera.
- `wayfinder-map.md`: mapa całego wayfindera game1 (kontekst).

## Grafika z game1 (`art/game1/`)

- `concept/_style/`: `STYLE.md` (styl, paleta, wymiary, zasady), `palette.hex/.gpl/.png` (32 kolory), `pixel_ref.png` (wzorzec stylu: Badacz, Krogg, lada, prycza).
- `concept/_refs/`: referencje (buty, cela).
- `concept/picks.md`, `concept/prompts.jsonl`: wybrane koncepty i pełna historia promptów z ustawieniami.
- `reference/game/`: zrzuty game1 o 9 porach dnia (7:30–22:00), po strojeniu świateł.
- `game-sprites/world/`: gotowe sprite'y z gry z normal mapami (`*_n.png`): Badacz i Krogg (idle i chód w 4 kierunkach), meble posterunku.
- Nie skopiowane ze względu na rozmiar (ok. 130 MB): koncepty `repo/game1/art/concept/characters`, `locations`, `props`, `ui`.

## Narzędzia i kod z game1

- `tools/game1/concept/`: `comfy.mjs` i workflowy FLUX.2 klein dla ComfyUI.
- `tools/game1/unfake/`: `unfake.exe` (pikselizacja, kwantyzacja do palety).
- `tools/game1/variant_sheets/`, `tools/game1/reference_shots/`: arkusze porównawcze wariantów i porównywanie zrzutów (skrypty zależne od projektu game1).
- `reference/game1/lighting/`: system światła game1 (skrypty GDScript, shadery, profile `.tres`), źródło kolorów z `swiatlo-kolory-game1.md`. Tylko do wglądu, nie jest częścią projektu game2.
