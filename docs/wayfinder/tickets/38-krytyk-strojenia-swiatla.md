---
id: 38
title: "Krytyk strojenia światła i cieni: wnętrze i ulica"
labels: [wayfinder:prototype]
status: open
assignee:
blocked_by: [14, 37]
---

## Question

Jakie jedno, globalne strojenie światła i cieni (wspólne dla wnętrza i ulicy, dla postaci i obiektów) daje najlepszy klimat? Krytyk gamedev, mając wszystkie pokrętła, ocenia światło na Poligonie Dom i Poligonie Ulica i proponuje 2–3 zestawy strojenia do porównania na żywo; wybiera człowiek.

**Zanim zacznie stroić, krytyk sprawdza błędy** (niesprawdzone w ticketcie 36): piętro i schody, wieczorne słońce we wstęgach okien bocznych, jasność postaci względem `main`, ślad cienia w rogu salonu, gdy postać stoi w jadalni (okno przeliczania nie sięga przez dwa przejścia). Błędy idą do naprawy przed strojeniem.

**Pokrętła (wszystkie w F1, jawne, z zapisem zestawu):**
- cienie: miękkość (tarcza słońca, żarówka), gradient i długość, siła cienia każdego rodzaju źródła, parametry stylizacji pixel art z [37](37-stylizacja-cieni-pixel-art.md): wygląd A / B / C (gładki odpadł), rozdzielczość ×1–×3 (start: A ×2), `poziom_ev`, `poziom_pas`, `klucz_prog`, `klucz_pas`, `klucz_min`, `kontakt_m`, `kontakt_k`; krytyk proponuje wariant, ostateczny wybór na teksturach ([25](25-makieta-z-teksturami.md));
- niebo z okien i drzwi: `front_glow`, `front_gamma`, `sky_dir_k`, `sky_other_k`, `door_k`, `SKY_REF`;
- słońce, plamy, wstęgi i smugi: `sun_scale`, `side_ribbon_k`, `side_reach`, `side_width`, `FACING_FULL`, `SIDE_FACING_FULL`, `RIBBON_WIDEN`, kurz i powietrze (`air_k`, `AIR_DENSITY`, `AIR_FADE_M`, `DUST_GAIN`, `DUST_AMOUNT_K`);
- lampy: jasność (`room_lamp_k`), zasięg i odległość (zanik), abażur (`shade_up`), wielkość żarówki;
- noc: `night_window_k`, `NIGHT_COOL_LUX`, `STREET_C`, `NIGHT_SIDE_DEG`, latarnie na ulicy;
- ambient i ekspozycja (dziś ukryte suwaki), ekspozycja wnętrze ↔ ulica;
- **kolory oświetlenia:** kolor słońca, nieba, nocy i lamp w ciągu doby (start: `docs/swiatlo-kolory-game1.md`; zasada z ticketu 08: baza chłodna, ciepło tylko przy źródłach).

**Jedno strojenie globalne:** te same wartości dla postaci i obiektów (bez pokręteł tylko dla postaci; `actor_k`, jasność światła na ciele postaci, do ustalenia na 1 albo do usunięcia), te same dla wnętrza i ulicy.

**Życzenia człowieka do strojenia (2026-11-11):**
- **złota godzina:** wschód i zachód mają trwać dłużej i mieć więcej koloru, ma być czuć złotą godzinę;
- **smugi światła** (ulubione, z okien górnych, ticket 27) do poprawy: klimat i kolor, zwłaszcza w złotej godzinie.

Warunek: [Światło w Poligonach](14-swiatlo-poligony.md) (nowe cienie i światło na ulicy) i [Stylizacja cieni i światła w pixel arcie](37-stylizacja-cieni-pixel-art.md) zamknięte, żeby stroić raz, wnętrze i ulicę razem.

Decyzja człowieka: wybrany zestaw strojenia (zapis w `config/`, wartości do `STYLE.md` / Przepisu światła).
