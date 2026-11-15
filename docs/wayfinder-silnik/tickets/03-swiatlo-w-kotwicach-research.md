---
id: 03
title: Światło i cienie w Kotwicach i Referencjach
labels: [wayfinder:research]
status: closed
assignee: claude
blocked_by: []
---

## Question

Jak rysują światło i cienie Kotwice i Referencje z mapy grafiki: REPLACED, NORCO, Octopath Traveler (HD-2D), Kentucky Route Zero, Beat Cop, Disco Elysium, Gemini Rue? Dla każdej: krawędzie cieni (twarde, miękkie, dither), kolor cienia, nakładanie wielu źródeł, noc i lampy, wnętrza a plener, co jest liczone dynamicznie, a co namalowane, gdzie gra nagina fizykę dla nastroju. Wniosek: co z tego jest wymaganiem dla modelu Silnika światła game2 (oprawa artystyczna ponad realizm, logika cieni sztywna).

Model: Opus. Wynik: `docs/research/87-*.md`.

## Resolution

2026-11-15. Research: `docs/research/87-swiatlo-w-kotwicach.md` (Opus). Opisy Beat Cop, NORCO i Gemini Rue tylko z oficjalnych zrzutów (oznaczone [Oko]); część źródeł do doczytania ręcznie (lista w sekcji 10 pliku).

- **Brak gotowego wzoru technicznego:** żadna z siedmiu gier nie liczy światła z wielu źródeł w pixel arcie (NORCO, Gemini Rue, Beat Cop malowane ręcznie; Disco maluje na renderze; KRZ płaskie 3D; REPLACED i Octopath pełne światło 3D pod sprite'ami). Są reguły wyglądu do zapisania jako dane.
- **Cienie równoległe, jeden kierunek na scenę** we wszystkich Kotwicach z cieniami rzucanymi; **kolor cienia to dana zależna od pory dnia**, nie czerń (Disco: zmienne koloru słońca i cienia na każdą porę).
- **Disco potwierdza zasady mapy:** wnętrze i plener jednym pipeline'em, różnią się danymi; noc to ten sam model.
- **Fizykę nagina się w oświetleniu postaci, czasie i pogodzie, nie w kierunku cieni** (Octopath: stały reflektor na postaci; Disco: 3 stany słońca, przeskoki ukryte pogodą; KRZ: chmury). REPLACED: postać bez cienia wygląda na nieważką, więc w game2 cień kontaktowy i rzucany postaci.
- **Kandydaci na parametry `.tres`:** siła modelowania sprite'a światłem, kontrświatło na postaci, krzywa zachmurzenia. Stały reflektor z Octopath łamie „cień zawsze od źródła”: pytanie do człowieka w „Jeden model światła i cienia dla wszystkich źródeł”.
- **Żadna Kotwica nie pokazuje nakładania cieni z wielu źródeł**, więc prototyp „Nakładanie cieni z kilku źródeł” jest niezbędny. Na później: maska nieba jako maska śniegu (Disco).
