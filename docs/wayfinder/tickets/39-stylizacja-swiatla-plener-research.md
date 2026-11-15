---
id: 39
title: Stylizacja światła i cieni w plenerze w pixel arcie
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Jakim algorytmem zamieniać dokładnie policzone światło (bufor z ticketów 36 i 14) na pixel art tak, żeby w **plenerze** wyglądało dobrze: duże, bardzo łagodne przejścia (niebo zasłaniane przez budynki na całej ulicy, zachmurzenie bez słońca) i długie, ostre cienie słońca od budynków? Obecny wygląd A (poziomy całego światła w krokach EV z pasem ditheru Bayer 4×4 pod każdą granicą, ticket [37](37-stylizacja-cieni-pixel-art.md), research `docs/research/82-stylizacja-swiatla-pixel-art.md`) dobrze działa we wnętrzu (strome przejścia przy oknach i lampach), ale na ulicy łagodne przejście nieba daje pola szachownicy na pół kadru („siatkowaty cień”, człowiek, zrzut `style-lab/shots/t14/user/siatka.png`), a bufor w pikselu świata przy widoku ×2 daje schodki 2 px obok ditheru 1 px.

Do sprawdzenia (źródła pierwotne: devlogi, GDC, posty autorów; gry pixel art z dynamicznym światłem w plenerze: Eastward, Octopath Traveler / HD-2D, Sea of Stars, Children of Morta, The Last Night, Kingdom, Hyper Light Drifter, Return of the Obra Dinn jako dither, inne):
- czy gry w ogóle pokazują w plenerze miękkie zasłanianie nieba, czy tylko twarde cienie kierunkowe i stały ambient; jak oddają pochmurny dzień;
- pas ditheru w pikselach ekranu (szew stałej szerokości przy granicy poziomu, np. z pochodnych) zamiast części kroku jasności; posteryzacja bez ditheru; dither tylko w półcieniu źródeł kierunkowych; inne wzory (niebieski szum, linie);
- rozdzielczość bufora światła względem widoku (bufor ×2 tylko na ulicy, upsampling z zachowaniem krawędzi);
- czy jeden algorytm dla wnętrza i pleneru jest możliwy, czy wnętrze i ulica powinny mieć osobne parametry.

Wynik: rekomendacja 1–2 wariantów do prototypu w Poligonie Ulica (i sprawdzenia w Domu) z kosztem.

## Resolution

2026-11-15. Research: `docs/research/84-stylizacja-swiatla-plener-opus.md` (Opus, wiodący); `docs/research/83-stylizacja-swiatla-plener.md` (Sonnet, tylko tropy; jego akapit o dwóch zestawach stałych nie pochodzi od człowieka i jest odrzucony).

- **Przyczyna siatki:** pas ditheru w A ma stałą szerokość w EV (30% kroku 0,5 EV), nie w pikselach; na łagodnym przejściu nieba (ściany i ulica w cieniu budynków) rozlewa się na dziesiątki px.
- **Rekomendacja A′, jedna dla domu i ulicy** (wymaganie człowieka: jedna stylizacja, bez osobnych stałych): poziomy `s = log2(Y/Y_ref)/level_stops + 0.5`, szew ditheru o stałej szerokości w px ekranu `W = clamp(seam_px·|∇s|, 0, 1)`, kotwica `Y_ref` (jasność otwartego nieba przy ekspozycji przestrzeni). Płaska ściana w równym cieniu = jeden ton, łagodne przejście = płaskie pasma z wąskim szwem, dither tylko na stromych przejściach. Warianty: szew Bayer 4×4 3 px, szachownica 50%, `seam_px = 0`.
- B/C (próg na źródło) i bufor ×2 tylko na ulicy odpadają.
- **Wdrożenie:** dopiero na jednym silniku światła, nowa mapa `docs/wayfinder-silnik/map.md` (dom i ulica to dziś dwie kopie silnika; poprawki w jednej omijały drugą).
