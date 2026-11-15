---
id: 11
title: Strategia testów i sceny testowe
labels: [wayfinder:grilling]
status: open
assignee:
blocked_by: [05, 08]
---

## Question

Co sprawdzają testy jednostkowe, co bramki buforów, a co ocena człowieka na żywo? Jaki jest zestaw scen testowych z trudnymi przypadkami (np. kilka lamp na słońcu, wąska uliczka, okno dachowe, wysoki obiekt w półcieniu)? Jak dokładnie wygląda test końcowy z nową Lokacją wnętrza i nową Lokacją w plenerze?

Z „Jeden model światła i cienia dla wszystkich źródeł”: do trudnych scen dodać plamy i smugi z okien bocznych (zakaz plamy uchylony, wygląd do oceny), słońce skierowane w kamerę (research 85), promienie słońca między budynkami w plenerze.

**Z „Kontrakt danych sceny” (08):** sceny z żaluzjami (paski w pikselach), papierosem przy twarzy, nocą wieś vs miasto przez okno, oknami przedniej (niewidocznej) ściany; ostrzeżenia walidacji w edytorze.

**Z „Bufor i przeliczanie” (10):** bramka wydajności (kadr z 8 postaciami, samochodem i 4 kołyszącymi się drzewami; ≤ 4 ms GPU, ≤ 1 ms CPU na RTX 4060 Laptop; wczytanie ≤ 2 s), scena porównania wiatru A (cień stały) i B (cień z koroną), przewijanie doby (płynne doganianie cieni słońca), niebo bez prążków we wnętrzu.
