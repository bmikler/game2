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

- [x] Węzeł Źródła i profil Źródła; profile lampy, latarni, świecącego okna z punktami startowymi ze Ściągi.
- [x] Grupowanie Źródeł w warstwy w Opisie sceny (testy).
- [x] Ta sama funkcja widoczności i półcienia co dla słońca.
- [x] Bramka: dwa Źródła razem = suma osobno.
- [x] Włączanie o godzinach z profilu bez przeliczania warstwy.
- [x] Przełącznik trybu A′ (na sumie / na kanałach) z powrotem w F1, gdy jest kanał sztuczny (przeniesione z ticketu 11; pole `style_mode` w Zestawie już jest).

## Jak sprawdzić

Sklep o 22:00: cienie słupów od trzech latarń krzyżują się, przecięcie ciemniejsze, kolor cienia to światło pozostałych Źródeł. O 16:30 latarnie zapalają się stopniowo. Przełącz tryb A′: różnica ciepłego i chłodnego światła.

## Stan (2026-11-16, Claude) — do sprawdzenia przez człowieka

**Zmiana godziny sprawdzenia:** przy obecnej krzywej słońce chowa się za dachy o 17:36 i zachodzi o 18:06, więc o
16:30 niebo jest jeszcze jasne i latarnie nie byłoby widać. Latarnie zapalają się nagle o 17:50 i gasną o 7:40 (profil
`street_lamp.tres`; człowiek: „powinny zapalić się nagle”), okna stopniowo 16:48–17:36. Po zapaleniu lampy jaśnieją
jeszcze do ok. 19:00: to ekspozycja automatyczna otwiera się, gdy niebo ciemnieje. Sprawdzać o 17:50 i o 22:00.

- **Węzeł `LightSource`** (kula albo prostokąt świecący jedną stroną, metry) i **`SourceProfile`** (kanał, kolor i
  natężenie od godziny, zanik jako krzywa od odległości, koniec krzywej = zasięg). Profile startowe ze Ściągi w
  `tuning/sources/` (generator `start_values.gd`): latarnia 60 lx pod żarówką na 4 m, zasięg 14 m; kinkiet nad
  drzwiami 100 lx 2,5 m pod nim, świeci też w dzień; świecące okno 40 lx 1 m przed szybą, zasięg 6 m, wieczorem i rano.
- **Warstwa na grupę** (grupa = profil, Opis sceny): liczona przy wczytaniu przez 16 klatek jak niebo, przy natężeniu
  1; co klatkę tylko mnożnik z godziny (Stan doby ma światło każdej grupy). Powierzchnię Źródła próbkuje stały zestaw
  128 punktów, tą samą funkcją widoczności co słońce i niebo, więc półcień wynika z rozmiaru Źródła. Mnożnik i
  maksimum półcienia z Zestawu dojdą z półcieniem słońca (ticket 14).
- **Samo Źródło świeci:** piksele, przez które widać kulę albo prostokąt, dostają światło z zaniku w 0 (szyba, lampa).
- **Kanał sztuczny** osobno (widok debug „Kanały”: zielony = udział lamp wobec otwartego nieba).
- **Tryb A′ w F1** („na sumie” / „na kanałach”, też w zrzucie). Przy gładkim niebie (B) poziomy mają tylko słońce i
  lampy: na ich sumie albo osobno.
- **Odcinek Sklep** na kamienicy środkowej Ulicy: witryna, sześć okien pięter, drzwi z kinkietem, trzy latarnie na
  chodniku od strony kamery (słup, ramię, żarówka). Szyby i żarówki to zastępczy kolor w Poligonie (`source_glass.gd`).
- Bramki GPU (`test_source_light_gpu.gd`): dwa Źródła razem = suma osobno (jedna i dwie grupy, ±1 %), cień słupa od
  lampy, większe Źródło = szerszy półcień, włączanie bez przeliczania warstwy, świecenie Źródła, prostokąt świeci tylko
  przodem, tryb A′ zmienia obraz przy słońcu i lampie, zielony kanał w debug. `node tools/test.mjs`: 182 zielone.

**Znane ograniczenia (przegląd kodu):** Źródło z kanałem naturalnym przy gładkim niebie idzie jak niebo (bez poziomów);
żaden profil dziś go nie używa. Ostrzeżenie „Źródło w Bryle” i pomiar czasu wczytania (≤ 2 s) to tickety 25 i 19.
Kinkiet świeci całą dobę (ticket: „także w słońcu”), Ściąga miała dla kinkietu harmonogram wieczorny. Przełącznik
„Tryb A′” widać tylko w Lokacji z kanałem sztucznym.
