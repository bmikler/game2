# Kolory światła z game1

Stan: 2026-11-03. Kolory światła z game1 bardzo odpowiadają użytkownikowi i są punktem wyjścia dla game2. Wartości przepisane z plików `repo/game1/game/world/lighting/data/*.tres` (kopia w `reference/game1/lighting/data/`) i przeliczone na hex (wartości > 1 obcięte do 1). To wartości po strojeniu w game1: ostatni zapis panelu strojenia (2026-11-02 11:49: lampka 50 lx, monitor 100 lx, okna nocą widok ×1,35, poświata 25 lx, widok maks. 1,6) jest już w plikach `.tres` (commit `44214b3`). Nie używać wartości z `repo/game1-proto`, który ma błędy w świetle. Mechanizm, który ich używa (ekspozycja, luksy, sRGB), opisuje ADR 0007 game1 (`docs/game1/adr/0007-*.md`) i notatki `22a`, `22c`, `22d`.

## Pora dnia: `norway_feb.tres` (luty, Norwegia)

Wschód słońca 6,9 h, zachód 18,1 h. Gradienty `sky_color` (niebo za oknem i światło nieba z okna) oraz `ambient` (wypełnienie pomieszczeń), punkty kontrolne:

| Godzina | Niebo (`sky_color`) | Ambient |
|---|---|---|
| 00:00 | `#475cbd` | `#3d426b` |
| 05:42 | `#4d5ebf` | `#40426b` |
| 06:54 | `#d999b3` | `#6b5766` |
| 07:48 | `#d9cce0` | `#a89494` |
| 10:30 | `#cce0ff` | `#f2f5fa` |
| 12:30 | `#cce0ff` | `#ffffff` |
| 14:30 | `#d9d9f2` | `#e6dedb` |
| 17:06 | `#e69e9e` | `#f29e6b` |
| 18:06 | `#8073cc` | `#61577a` |
| 19:06 | `#4a5cbd` | `#424570` |
| 24:00 | `#475cbd` | `#3d426b` |

Krzywa `clear` (pogoda): bezchmurnie do ok. 9:30, zachmurzenie ok. 11:00–13:30, potem znowu bezchmurnie od ok. 15:00.

## Źródła sztuczne (`FixtureDef`)

| Oprawa | Kolor | Uwagi |
|---|---|---|
| domyślny `FixtureDef` | `#faf2d6` | ciepła biel, np. świetlówki (`hall_tube`, `corridor` bez własnego koloru) |
| `cell_bulb` (żarówka w celi) | `#ffd999` | |
| `desk_lamp`, `office_desk_lamp` | `#ffb36b` | |
| `floor_lamp` | `#ff994d` | najcieplejsza |
| `wall_sconce` (kinkiet) | `#ffa357` | |
| `entrance_spill` (światło z zewnątrz w drzwiach) | `#b3ccff` | zimne |
| `monitor` | `#386bff` | |
| `window_light` nocna poświata okna | `#b1b6df` | |

Pozostałe parametry (luksy, kształt, `texture_scale`, harmonogram włączania `evening_lamps`) są w plikach `.tres` i skryptach w `reference/game1/lighting/`.
