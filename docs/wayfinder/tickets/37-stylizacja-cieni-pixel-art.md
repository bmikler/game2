---
id: 37
title: Stylizacja cieni i światła w pixel arcie
labels: [wayfinder:prototype]
status: closed
assignee: claude
blocked_by: [36]
---

## Question

Jak narysować poprawnie policzone, miękkie światło i cienie (bufor z ticketu [36](36-przebudowa-swiatla-jeden-bufor.md)) tak, żeby wyglądały jak pixel art (kilka poziomów, dither tym samym wzorem co w grze, bez rozmytych gradientów i losowego ziarna), a przy tym nie psuły cieni: bez krótkiego cienia przy oknie i długiego dalej, bez przypadkowych konturów daleko od postaci, bez kilku twardych cieni naraz z różnych źródeł?

Co nie działało (ticket 36): próg na udziale cienia **osobno dla każdego źródła** (każde okno, każda lampa). Postać przy dużym oknie zasłania 35–60% okna z prawie całego pokoju, czyli wokół progu 50%, więc próg rysował kontury w przypadkowych miejscach; każde źródło dawało osobny twardy cień.

Kierunki do sprawdzenia (warianty w F1, ocena na żywo w Poligonie Dom, w wyglądzie gładkim jako odniesieniu):
- poziomy z **całego światła piksela** (suma źródeł), nie z udziału każdego źródła;
- niebo z okien tylko jako miękki cień kontaktowy (krótki, pod postacią i meblami), twarde poziomy tylko od słońca i lamp;
- kwantyzacja jasności (posteryzacja z ditherem) zamiast cienia;
- inne, jeśli research znajdzie (najpierw krótki research, jak gry pixel art stylizują miękkie światło i cienie: Eastward, REPLACED, NORCO, Kotwice z ticketu 08).

Wymagania: ten sam wygląd dla postaci i mebli; plamy i smugi okien w tym samym języku co cienie (spójny język świateł i cieni); działa także na ulicy (ten sam mechanizm). Parametry stylizacji (poziomy, progi, wzór ditheru, szerokość pasa ditheru) jako pokrętła dla krytyka ([38](38-krytyk-strojenia-swiatla.md)).

Bramka (Claude sprawdza sam, zanim pokaże): postać przy oknie tylnym, bocznym i w drzwiach wejściowych, 1 m i 2 m od okna, przy lampie; brak przeskoków i konturów daleko od postaci; postać i pudełko tej samej wielkości dają ten sam obraz; w ruchu bez migotania i szwów.

Decyzja człowieka: sposób stylizacji (jeden wariant do strojenia).

## Resolution

**Decyzja człowieka (2026-11-11):** wygląd gładki odpada jako wariant docelowy (zostaje w F1 tylko jako odniesienie do sprawdzania poprawności cieni). Finalny wariant spośród A, B, C i rozdzielczości ×1–×3 wybieramy na teksturach (makieta z teksturami, [25](25-makieta-z-teksturami.md)), a pokrętła stroi krytyk ([38](38-krytyk-strojenia-swiatla.md)). Domyślnie w Poligonie (człowiek): **A z rozdzielczością ×2**.

Prototyp: gałąź `t37-stylizacja` (od `t36-cien-nieba-kolumny`), research `docs/research/82-stylizacja-swiatla-pixel-art.md`, zrzuty `style-lab/shots/t37/`. Stylizacja to warstwa nad dokładnym liczeniem z ticketu 36 (funkcja `light_parts` i wyjście bufora), więc przeniesie się na ulicę bez zmian.

Warianty w F1 („Cienie i światło: wygląd”):
- **A: poziomy całego światła.** Suma światła piksela (bufor + ambient pokoju) kwantyzowana w krokach EV z pasem ditheru Bayer 4×4 pod każdą granicą; plamy, smugi, pierścienie lamp i cienie jednym językiem; niebo dalej rzuca dokładny cień (kształt V spod postaci).
- **B: niebo kontaktowo, twardy cień klucza.** Niebo z okien bez rzucanego cienia obiektów, tylko cień kontaktowy przy podstawie (zasięg i siła); słońce ze wstęgami, noc i lampy (lampy razem jako jedno źródło) dostają każde osobny próg z pasem ditheru; cień źródła, które daje mniej niż `key_min` światła piksela, zostaje gładki. Smugi okien górnych w tym samym progu. Jeden wspólny próg na wszystkie źródła odrzucony (człowiek: cień lampy znikał pod plamą okna o 17:15).
- **C: B + A.**
- **Rozdzielczość ×1 / ×2 / ×3** („Światło i cienie: rozdzielczość”): widok renderowany gęściej, sprite'y bez zmian; poziomy i dither A liczone w shaderze sprite'ów z interpolowanego bufora (alfa bufora = ambient), bufor zostaje w pikselu świata. Bufor ×k odrzucony: zabijał wydajność (człowiek). B zostaje w pikselu świata (interpolacja wygładziłaby twarde krawędzie).

Pokrętła dla krytyka (ukryte, `--set=`): `poziom_ev` (krok, EV), `poziom_pas` (pas ditheru, część kroku), `klucz_prog`, `klucz_pas`, `klucz_min`, `kontakt_m`, `kontakt_k`.

Bramka (sprawdzone): okno wokół postaci = cały dom bajt w bajt po spacerze przez pokoje (9:30, 22:00; B i C; także ×2); postać jako pudełko = pudełko w miejscu postaci (dom identyczny, różni się tylko pasek ciała); wpływ postaci na bufor w B/C ok. 6 tys. px wobec ok. 55 tys. w gładkim i A. Koszt (`--bench` 22:00 przy lampie): ×1 76, ×2 75, ×3 72 kl./s.

Otwarte do strojenia/wyboru: dwie lampy w jednym pokoju dają jeden wspólny cień w B; cień kontaktowy w B słabo widoczny przy domyślnych wartościach; A w drobnym widoku interpoluje bufor, więc na krawędziach powierzchni możliwa półpikselowa poświata.
