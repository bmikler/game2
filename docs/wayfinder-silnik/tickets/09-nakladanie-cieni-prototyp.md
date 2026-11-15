---
id: 09
title: Nakładanie cieni z kilku źródeł
labels: [wayfinder:prototype]
status: closed
assignee: claude
blocked_by: [07]
---

## Question

Jak ma wyglądać scena, w której jednocześnie świecą słońce, niebo i dwie lampy, a cienie z różnych źródeł się nakładają? Prototyp z 2–3 wariantami łączenia źródeł (wynikającymi z modelu z „Jeden model światła i cienia dla wszystkich źródeł”), przeklikiwanymi na żywo w Poligonie; człowiek wybiera. W tym: czy kwantyzować tylko luminancję (A′), czy osobno kanał chłodny i ciepły z kolorem z palety 2D; sceny testowe w `docs/research/86-nakladanie-swiatla-wielu-zrodel.md`.

## Prototyp

2026-11-15. Gałąź `proto-09-nakladanie`, `style-lab/proby/nakladanie/` (kod do wyrzucenia, niezależny od `lighting/`), start `style-lab/nakladanie.bat`. Dwie sceny (1 ulica nocą z dwiema latarniami i świecącymi oknami, 2 wnętrze z lampą, oknami i latarnią za oknem), pełna doba klawiszami `[` `]`, warianty klawiszem V:

- 0 gładko (odniesienie bez kwantyzacji),
- 1 A′ na luminancji sumy, barwa ciągła,
- 2 A′ + udział ciepła w stopniach (H: 2/3/4 stopnie),
- 3 kanał naturalny (słońce, niebo) i sztuczny (lampy, okna) kwantyzowane osobno, jak paleta 2D.

Do oceny przez człowieka: (1) który wariant barwy przy nakładaniu ciepłego i chłodnego światła; (2) czy cienie z kilku źródeł czytają się dobrze (postać między latarniami, latarnia w dzień: L, zmierzch ok. 16:30, wnętrze nocą). Nie oceniamy: krzywych doby, jasności, kolorów, smug ani prążków od próbek nieba we wnętrzu (to koszt i strojenie, inne tickety).

## Resolution

2026-11-15. Człowiek ocenił na żywo: warianty 1 i 3 się podobają, cienie z kilku źródeł (przecięcie cieni latarni, latarnia w dzień, zmierzch, wnętrze nocą) wyglądają dobrze. Wariant 2 (udział ciepła w stopniach) odpada.

1. **Bufor niesie dwa kanały światła:** naturalny i sztuczny. Kanał to pole w danych Źródła (np. słońce i niebo naturalne, lampy i świecące okna sztuczne), nie typ w kodzie. Ambient należy do kanału naturalnego.
2. **Stylizacja ma dwa tryby wybierane w `.tres`, oba z tych samych dwóch kanałów, bez gałęzi pod scenę:** (1) A′ na luminancji sumy, barwa ciągła; (3) A′ osobno na każdym kanale, potem suma (jak paleta 2D). Przełącznik działa na żywo w F1; jeden tryb wybiera się przy globalnym strojeniu (ticket 38 mapy grafiki). Decyzja Claude'a: dwa kanały kosztują mało, a zostawiają otwarte oba wyglądy, które się podobają.
3. **Potwierdzone na żywo:** suma w HDR i cień bez własnego koloru (z „Jeden model światła i cienia dla wszystkich źródeł”) dają czytelne nakładanie; nie potrzeba kolejności źródeł ani koloru cienia.
4. **Uwaga dla „Bufor i przeliczanie”:** niebo próbkowane stałym wzorem kierunków daje prążki i duchy okien przy małej liczbie próbek (128 to wciąż za mało we wnętrzu); potrzebne niebo liczone statycznie z dużą liczbą próbek albo inna metoda.

Prototyp: gałąź `proto-09-nakladanie`, `style-lab/proby/nakladanie/`.
