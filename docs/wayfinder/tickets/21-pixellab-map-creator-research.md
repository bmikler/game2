---
id: 21
title: Pixellab map creator: czy nada się do terenu, budynków i wnętrz w naszym rzucie
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Człowiek zauważył, że wyższe plany Pixellab mają narzędzie do tworzenia map („map creator”). Skoro na Miesiąc produkcji i tak planujemy subskrypcję Pixellab (ok. 2000 generacji, Przepis postaci: `docs/grafika/przepis-postaci.md`), sprawdzić, czy to narzędzie może zastąpić albo wspomóc Przepis budynków, fasad, terenu i mebli.

Do ustalenia (źródła pierwotne: dokumentacja Pixellab, API v2 / OpenAPI, regulamin, cennik):
1. Co dokładnie robi: kafle (tilesety, Wang/autotile), całe mapy, obiekty, budynki, wnętrza; jakie rzuty obsługuje (top-down, low/high top-down, izometria, side) i czy da się uzyskać nasze niskie 3/4 oblique z głębią × 0,60 (`style-lab/config/projection.tres`; ticket „Rzut, skala i rozdzielczość”); rozdzielczość i skala (40 px/m, postać 72 px).
2. Wejścia: czy przyjmuje referencję stylu (nasz sprite, ilustracja z FLUX), paletę, istniejące kafle; czy trzyma spójność między wywołaniami.
3. Dostęp: w którym planie (Apprentice / Artisan / inne), czy przez API/MCP czy tylko w webie; koszt w generacjach na typowy element (kafel terenu, fasada, pomieszczenie).
4. Licencja wyników do komercyjnego użycia na Steamie, także po zakończeniu subskrypcji.
5. Czy da się to sprawdzić na trialu (stan: 10,5/40 gen.) bez wydawania; jeśli tak, zaproponować jedną tanią próbę na Poligonie Ulica (każda generacja za zgodą człowieka z kosztem).

Wynik: notatka w `docs/research/` (numer od 76) i rekomendacja: wchodzi do Przepisu budynków/terenu/mebli, warto prototypować, czy odpada.

## Resolution

Notatka: `docs/research/76-pixellab-map-creator.md` (bez generacji; tylko OpenAPI, dokumentacja, ToS, saldo i darmowe `check_cost`).

- „Map creator” to zestaw narzędzi, nie jedno: edytor map w webie (top-down, kafle Wang), Create/Extend map, Create tiles (Pro) z zestawami terenu, dróg i budowlanym (podłoga, ściany, drzwi, schody), pokoje z meblami (`create_room`, tylko MCP) oraz map-objects.
- Rzut: `oblique` w Pixellab to ścięcie po przekątnej (45° / ~27°), nie nasze frontalne 3/4 × 0,60. Najbliżej `square_topdown` z ciągłym `tile_view_angle` (0,60 ≈ 37°, wniosek) i `building_wall_angle`. Kafle 16–128 px pasują do 40 px/m.
- Wejścia: `style_images` w tiles-pro to kafle, nie ilustracje; map-objects przyjmuje `background_image` (dopasowanie do sceny), `init_image` i paletę. Spójności między wywołaniami dokumentacja nie gwarantuje.
- Dostęp: tiles-pro, tileset Pro i pokoje od planu Apprentice (wpis „Artisan” w 61 nieaktualny); pokoje i mapy tylko przez MCP.
- Koszt: zestaw kafli Pro 10–15 gen., create-object 10–25, obiekt Pro Flash 64 px 5–6 (darmowe `check_cost`); tileset, map-objects i pokoje bez wyceny. Same meble przy 5–10 gen./szt.: 600–6600 gen.
- Licencja: ToS §1.3 wyniki nasze, komercyjnie; §1.2 zakaz trenowania; nic o utracie praw po anulowaniu.
- **Rekomendacja: warto prototypować** (ticket „Próba Pixellab map-objects i kafli w naszym rzucie”). Trial nie obejmuje tiles-pro ani pokoi.
