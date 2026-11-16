---
id: 13
title: Sklep z lampami i latarniami
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [08]
---

## Co zbudować

Źródła powierzchniowe (prostokąt albo kula w metrach) z profilami: kanał, kolor i natężenie od godziny (godziny świecenia), zanik. Odcinek Sklep: witryna i okna świecące nocą, trzy latarnie i lampa nad drzwiami, także w słońcu. Nieruchome Źródła liczone raz przy wczytaniu, jedna warstwa na grupę. Cienie wielu Źródeł nakładają się przez sumę w HDR.

## Kryteria akceptacji

- [ ] Węzeł Źródła i profil Źródła; profile lampy, latarni, świecącego okna z punktami startowymi ze Ściągi.
- [ ] Grupowanie Źródeł w warstwy w Opisie sceny (testy).
- [ ] Ta sama funkcja widoczności i półcienia co dla słońca.
- [ ] Bramka: dwa Źródła razem = suma osobno.
- [ ] Włączanie o godzinach z profilu bez przeliczania warstwy.
- [ ] Przełącznik trybu A′ (na sumie / na kanałach) z powrotem w F1, gdy jest kanał sztuczny (przeniesione z ticketu 11; pole `style_mode` w Zestawie już jest).

## Jak sprawdzić

Sklep o 22:00: cienie słupów od trzech latarń krzyżują się, przecięcie ciemniejsze, kolor cienia to światło pozostałych Źródeł. O 16:30 latarnie zapalają się stopniowo. Przełącz tryb A′: różnica ciepłego i chłodnego światła.
