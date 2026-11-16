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

**Poprawka po ocenie (2026-11-16):** człowiek: latarnie „zapalają się skokowo” i ich światło zmienia się po
zapaleniu. Pomiar co 5 min: lampa stała (25 lx), a obraz skakał 0,30 → 0,58 → 0,45, bo siatka poziomów A′ stała na
kotwicy otwartego nieba, które po zachodzie ciemnieje ok. 30×. Przy gładkim (B) i ditherowanym (C) niebie siatka
słońca i lamp stoi teraz na stałych luksach (1 lx × 2^`anchor_ev`): pasy plamy lampy nie ruszają się przez cały
wieczór (bramka w `test_light_style_gpu.gd`). Zostaje płynne rozjaśnianie z ekspozycją automatyczną 18:00–18:50 i
lekkie zblednięcie (ok. 9 %) do 19:15: dzienna krzywa nieba schodzi do 6 lx, noc miasta ma 20 lx (strojenie krzywych).
Człowiek: piksele (poziomy) na świetle lamp „nawet spoko”; niebo zostaje gładkie (B).

**Błąd modelu nieba (2026-11-16):** człowiek: lampa nad drzwiami od 5 rano „dziwnie falowo się rozjaśnia”. Pomiar:
lampa stała, a ekspozycja najpierw rosła (5:50–6:12, niebo spadało z 20 do 16 lx), potem spadała 11× w 45 min.
Przyczyna: noc opisana dwa razy (krzywa dziennego nieba 6 lx w nocy i profil nieba miasta 20 lx), przejście między nimi
według wysokości słońca dawało dołek o świcie i garb o zmierzchu (to też te 9 % zblednięcia lamp o 19:00). Teraz:
dzienna krzywa nieba ma w nocy 0 i rusza łagodnie godzinę przed wschodem; profil nieba dodaje swoje światło zawsze
(nocą to całe niebo, w dzień ginie). Pola `night_from_elevation` i `night_full_at` usunięte. Nowy test
(`test_day_state.gd`): ekspozycja tylko maleje do najjaśniejszej minuty i tylko rośnie po niej, dla miasta i wsi.
Tego błędu nie łapał żaden test: sprawdzały tylko brak skoków między minutami, nie kierunek zmian.

**Okna (2026-11-16):** człowiek: fale na ścianie 5:30–6:00, „okna w ogóle nie świecą”. Okna zapalały się stopniowo
pół godziny (pasy A′ przesuwały się po chodniku), a szara zastępcza szyba pod ciepłym światłem wyglądała jak brązowa
płyta. Teraz okna włączają się i gaszą nagle (5:45, 7:45, 17:15, 23:15), 60 lx, szyba jasna (`source_glass.gd`).
**Środkowa latarnia** ma jasną plamkę pod sobą, boczne nie: szczyt 38,8 lx (światło obu sąsiadek) wobec 38,0 lx przy
granicy poziomu ok. 38 lx. Fizyka poprawna, A′ zamienia 2 % różnicy w cały poziom; zostaje do strojenia (`anchor_ev`).

## Do zrobienia w nowej sesji (człowiek, 2026-11-16)

- **Okna z ulicy do poprawy:** „okna były o wiele lepsze w game2” (stary Poligon Ulica: `style-lab/ulica.bat`,
  `poligony/ulica_bryly.*`, poświata okien w `street_fn.gdshaderinc`, Ściąga 4.4 i sekcja 1: „zapalone okna z poświatą
  na śniegu”). Żaden inny ticket silnika nie obejmuje świecących okien od strony ulicy: należy to zrobić tutaj. Najpierw
  porównać na żywo stary i nowy wygląd okna (zrzuty tej samej pory), nazwać różnice, potem poprawić model lub dane
  (bez łatek pod scenę).
- Lampa nad drzwiami zostaje na całą dobę (człowiek: „niech świeci”).
- Ticket zamknąć dopiero po ocenie okien przez człowieka.
