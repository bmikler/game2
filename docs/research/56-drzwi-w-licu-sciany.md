> Kopia z game1 (`repo/game1/docs/research/56-drzwi-w-licu-sciany.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Drzwi w licu ściany: strefa "za ścianą" przy wejściu z pokoju wyżej

Powiązane: 43 (ściany wnętrz 3/4), 35b (wierzch ściany), ticket 45 (przejście przez drzwi). Data researchu i dostępu do źródeł: **2026-11-02**. Czas pracy krótki (szybki przegląd), więc wiele twierdzeń o grach jest tylko drugorzędnych. Zaznaczam to przy każdym.

Oznaczenia:
- **[docs]**: oficjalna dokumentacja (Godot, RPG Maker, wiki Stardew), czytana dziś.
- **[forum]**: wątek na forum lub wynik wyszukiwania, poziom praktyków. Nie jest to źródło twórców gier.
- **[z pamięci]**: wiedza ogólna, dziś niesprawdzona.
- **[kod]**: czytałem pliki projektu.
- **[wniosek]**: moja interpretacja lub propozycja.

## 1. Pytanie

Ściana pozioma dzieli pokój wyżej i pokój niżej. Z dołu postać podchodzi do lica ściany i widzi otwór. Z góry podchodzi przez wierzch ściany. Jak gry 3/4 pozwalają przejść z góry na dół przez drzwi w licu, żeby nie trzeba było trafiać stopami w wąski otwór? Użytkownik czuje, że z góry przejście jest za ciasne. Chce strefy wokół drzwi, gdzie postać może wejść "za ścianę", i szerszego stożka.

## 2. Streszczenie

- **Nie znalazłem żadnej wypowiedzi twórców** (Stardew, Eastward, Chef RPG, Graveyard Keeper, Moonlighter, Pokémon, Zelda) o tym, jak szeroka jest strefa przy drzwiach w licu. Gry te prawie wszystkie unikają problemu: drzwi są **zdarzeniem** (kafel z warpem), a nie przejściem przez grubą ścianę (43 §3). Dlatego nie ma wzorca do skopiowania. To, co mamy, to wzorce cząstkowe: hitbox węższy niż drzwi, warp na kaflu, korekta narożników z platformówek.
- **Najlepiej udokumentowane techniki** to: stopy węższe od otworu (zapas po obu stronach), korekta narożnika w stylu Celeste (próg kilku pikseli, tylko na korzyść gracza) i kolizja tylko u podstawy ściany (Godot, Stardew). Wszystkie trzy mamy już w projekcie albo da się je dodać tanio.
- **Godot nie ma wbudowanej korekty narożników** w `move_and_slide`. Trzeba ją napisać (`test_move`). Nasz `WalkArea` jest własną, kwadratową symulacją, więc korekta to zwykła zmiana w `step()`.
- **Rekomendacja:** zastąpić schodkowy stożek **prostokątną strefą "za ścianą"** obok drzwi (po 24 px z każdej strony, głębokość równa wierzchowi ściany plus kilka pikseli lica) i przedłużyć zsuwanie do środka na całą głębokość przejścia. Od dołu centrować tylko minimalnie (do 8 px). Liczby w §7.

## 3. Strefa wokół drzwi (punkt 1)

### Co jest w źródłach

- **Stopy węższe niż otwór.** To najprostsza i najczęstsza metoda. Wątek Stack Exchange (przez mirror) i wyniki wyszukiwania sugerują sprawdzanie o 2–4 px mniej z każdej strony hitboxa albo powiększony obszar wyzwalacza drzwi [forum, drugorzędne]. U nas stopy mają 14 px, otwór 36 px, czyli po 11 px zapasu na stronę [kod].
- **Zsuwanie wzdłuż przeszkody do szczeliny.** Opisane jako klasyka Zeldy: gdy ruch jest zablokowany, liczy się wektor korekty w stronę szczeliny i postać się zsuwa [forum, drugorzędne; "Zelda-style" nie jest potwierdzone u twórców]. Wariant z Love2D: koryguj tylko gdy gracz naciska na ścianę i obok jest otwór, nie przy ruchu po przekątnej, i przesuwaj po 1 px na klatkę [forum].
- **Celeste (korekta narożnika).** Sprawdza kilka wysokości (w opisie forum: 4) po obu stronach postaci i wybiera pierwszą wolną. Działa tylko na korzyść gracza, w kierunku ruchu. Autor wątku zaleca zapamiętać prędkość sprzed `move_and_slide` i przywrócić ją po korekcie, żeby nie tracić tempa [forum: [Corner Correction (like in Celeste)](https://forum.godotengine.org/t/corner-correction-like-in-celeste/15784), opis z kodu Celeste, bez liczby pikseli]. Artykuł bugnet.io o korekcie narożników sufitu zaleca limit kilku pikseli na klatkę, bo duże przesunięcie pozwala przejść przez ściany, które powinny blokować [forum/blog, drugorzędne].
- **Wada nudgingu:** deweloperzy zgłaszają, że niechciane przesuwanie przy puszczeniu klawisza koło ściany jest nieprzyjemne [forum]. [wniosek] Korekta powinna działać tylko, gdy gracz **naciska** w stronę ściany.
- **Kafelek-drzwi jako wyzwalacz.** Stardew: kafel w warstwie Buildings jest ścianą, dopóki nie ma właściwości `Passable T` [docs: [Modding:Maps](https://stardewvalleywiki.com/Modding:Maps), przeczytane przez wyszukiwarkę, bezpośrednia strona zwróciła 403]. Warpy są osobnymi kaflami. Pokémon: drzwi to jeden kafel 16×16 z warpem, postać ma tę samą siatkę, więc nie trafia "obok" [z pamięci].
- **Czego nie znalazłem:** żadnej liczby (px lub kafle) dla "stożka" ani "lejka" w tych grach. Eastward, Chef RPG, Moonlighter, Zelda ALttP/Minish Cap: brak źródeł. Stardew (hitbox gracza ok. 48 px w kafelku 64 px, czyli ok. 8 px zapasu po stronie) [z pamięci, niesprawdzone].

### Wniosek [wniosek]

Gry w ogóle nie mają problemu "trafić w otwór w licu z góry", bo nie pozwalają wejść za ścianę. My pozwalamy, więc musimy sami zdecydować, jak głęboko. Najbliższy znany wzorzec to korekta narożnika: szerokie, tanie wejście, które sprowadza postać do osi.

## 4. Rysowanie ściany, nadproża i ościeża (punkt 2)

- **Stardew:** warstwy Back, Buildings, Front, AlwaysFront. Front rysuje się nad graczem, gdy ten stoi na północ od kafla, i pod graczem, gdy stoi na południe. AlwaysFront zawsze nad wszystkim. Dodatkowe warstwy przez przyrostek (`Back-1`, `Back2`) zmieniają kolejność rysowania, ale kolizje liczą się tylko z oryginalnych warstw [docs: [Modding:Maps](https://stardewvalleywiki.com/Modding:Maps), przez wyszukiwarkę]. Czyli rysowanie i kolizja są rozdzielone.
- **RPG Maker:** warstwa A to dolna, B–E to górne [docs: [MZ help, A4 Walls](https://rpgmakerofficial.com/product/MZ_help-en/01_11_01.html)]. Ta strona nie mówi nic o gwiazdkach (kafle nad postacią) ani o przechodności. Zasada "★ rysuje się nad postacią" to wiedza ogólna [z pamięci].
- **Godot, y-sort:** `y_sort_enabled` na węźle i jego dzieciach sortuje po Y (większe Y z przodu). Sortowanie działa tylko wśród węzłów o **tym samym `z_index`**; inny `z_index` ma pierwszeństwo [docs: [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html)]. Dziecko bez y-sortu jest sortowane po swoim Y, a jego dzieci rysują się razem na jego Y. Dla `TileMapLayer` ustawia się `Y Sort Enabled` i `Y Sort Origin` (przesunięcie pionowe w pikselach, działa tylko przy włączonym y-sorcie) [docs: [Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html)].
- **Praktyki z forum Godota** [forum, drugorzędne]: (1) pochodzenie y-sortu kafla ściany często leży w środku kafla, a nie u dołu, i stąd błędy kolejności; (2) żeby warstwa była "piętro wyżej", podnosi się jej `y_sort_origin` o wysokość ściany; (3) rodzic musi mieć y-sort, żeby kafle i obiekty sortowały się względem siebie; (4) twarde `z_index` ściany nad graczem sprawia, że gracz nigdy nie może przejść za ścianą; (5) kafel mieszany (przód i tył) rozwiązuje się czasem przełączaniem `z_index` gracza według pozycji w kafelku.
- **Przezroczystość ściany przy graczu:** gry 3/4 z naszego zestawu jej nie używają dla ścian wnętrz (43 §6). Odrzucone przez człowieka w tickecie 45 jako przyciemnienie/fade.
- **Nasz stan [kod]:** `_build_door_overlay` rysuje lico wokół drzwi drugi raz, y-sortowane u stóp ściany, na szerokości drzwi plus `DOOR_SIDE` = 28 px z każdej strony. Futryna i nadproże zakrywają więc postać w przejściu. To jest zgodne ze wzorcem "rysowanie osobno od kolizji" ze Stardew.

[wniosek] Jedyna reguła kolejności potrzebna dla strefy "za ścianą": postać ma być zasłaniana przez lico **wtedy i tylko wtedy, gdy jej stopy są niżej na ekranie niż górna krawędź lica** (czyli w pasie przejścia lub w strefie za ścianą). Y-sort u stóp lica to robi samo, jeśli overlay obejmuje całą szerokość strefy.

## 5. Rozmiar otworu i tolerancje (punkt 3)

- **Nasze liczby [kod, zadanie]:** postać 75 px wysokości (1,9 m), stopy 14×6 px, drzwi 36 px (0,9 m), lico 76 px (1,9 m), drzwi ok. 1,55 m, więc głowa wystaje ok. 0,35 m (14 px) ponad wierzch ściany.
- **Stosunek drzwi do stóp:** 36 / 14 = 2,6. Zapas 11 px po stronie. Do przejścia stopy muszą mieścić się w paśmie 22 px wokół osi drzwi.
- **Zalecenia ogólne w źródłach:** hitbox węższy niż sprite o kilka pikseli z każdej strony [forum]. Stardew: ok. 8 px zapasu na kafelek 64 px, czyli 12% [z pamięci, niesprawdzone]. U nas zapas to 11 / 36 = 30% szerokości otworu na stronę, więcej niż w typowych grach. Samo przejście przez otwór nie jest więc ciasne. Ciasne jest **trafienie** w pas 22 px z góry, gdzie stopy są odcięte ścianą.
- **Brak twardych liczb od twórców.** Nie podaję "standardowego" rozmiaru otworu z żadnej gry.

## 6. Godot 4 (punkt 4)

- **`CharacterBody2D`:** w `MOTION_MODE_FLOATING` (widok z góry) wszystkie kolizje są raportowane jako ściany, prędkość ślizgu jest stała, `wall_min_slide_angle` działa tylko w tym trybie. `safe_margin` to odległość uznawana za kolizję: wyższa daje stabilniejsze wykrywanie, niższa dokładniejsze. `max_slides` ogranicza liczbę zmian kierunku [docs: [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)]. Dokumentacja **nic nie mówi o narożnikach** ani o korekcie. Zaokrąglone stopy (kapsuła) pomagają ślizgać się po narożniku, ale to wiedza ogólna [z pamięci], nie z dokumentacji.
- **Korekta narożnika w Godot** robi się ręcznie: `test_move` (albo własne testy prostokątów) po zablokowanym ruchu, próba przesunięć o 1..N px w osi poprzecznej, przyjęcie pierwszego wolnego [forum, opis z Celeste]. Nie ma wbudowanej opcji.
- **Nasz `WalkArea` [kod]:** nie używa fizyki Godota. Ruch jest osiami (najpierw x, potem y), blokowany ruch w dół w lejku zsuwa o `distance` px w stronę środka drzwi. To już jest korekta narożnika w pełnym sensie, tylko bez limitu głębokości poza obszarem lejka.
- **Kolizja u podstawy ściany, rysowanie osobno:** zalecenie z forum (kształt kolizji tylko u podstawy kafla ściany, żeby postać mogła stać przed i za) [forum, brak bezpośredniego wyniku, wniosek z rozmowy o y-sorcie]. U nas równoważne jest to, że ściana jest "blokerem" tylko na pasie lica.

## 7. Rekomendacja dla projektu [wniosek]

Stan [kod]: `walkable()` buduje prostokąt przejścia przez lico i schodkowy stożek od strony pokoju wyżej: 26 px z boku, 30 px głębokości, 10 stopni. Lejek zsuwania: 32 px z boku, 24 px nad drzwiami (+32 px w głąb). Stożek jest więc schodkowy i wąski, a lejek ma inny zasięg niż stożek. Dwa różne kształty dla jednej rzeczy to źródło odczucia "ciasno i niejasno".

### 7.1 Zastąp stożek prostokątem "za ścianą"

- Jeden prostokąt chodzony obok drzwi, po obu stronach, **po 24 px szerokości** (łącznie z przejściem 36 + 2 × 24 = 84 px), **głębokości = grubość wierzchu ściany (`cap`, 8–10 px) + 6 px lica** (razem ok. 14–16 px).
- Dlaczego tak płytko: stopy w tej strefie leżą poniżej górnej krawędzi lica, więc lico zasłania ich dolną część. Przy 6 px lica zasłania się tylko 6 px z 75 (okolice stóp, ok. 8%), czyli efekt jest trudny do zauważenia. Głębiej, np. 24+ px, postać zaczyna wyglądać jak obcięta (odrzucone przez człowieka w tickecie 45) [wniosek].
- Dlaczego prostokąt: zsuwanie do środka jest wtedy przewidywalne (zawsze w tym samym pasie), a schodki nie dają nierównego czucia.
- Alternatywa, jeśli człowiek woli większą strefę: 32 px po stronie (jak obecny lejek), głębokość bez zmian. Dłuższe boczne ramiona mogą wyglądać dziwnie (postać "wisi" na wierzchu ściany daleko od drzwi).

### 7.2 Zasięg automatycznego centrowania

- Zsuwanie ma działać **w całej strefie 7.1 oraz wzdłuż całego przejścia przez lico**, nie tylko w lejku.
- Zsuwanie 1:1 (ruch boczny = ruch w dół) wymaga głębokości co najmniej: odległość środka stóp od osi drzwi minus zapas 11 px. Dla krańca strefy (18 + 24 = 42 px od osi) to **31 px** zsuwania, więcej niż 15 px głębokości strefy. Więc:
  - albo zsuwać **2:1 bocznie** do pierwszych 15 px głębokości (limit 1,5 × `distance` na klatkę, żeby nie odbierać kontroli; prędkość w dół nie rośnie, więc nie jest to "przyspieszenie w przejściu" odrzucone w tickecie 45),
  - albo zawęzić strefę 7.1 do 16 px po stronie (wtedy 1:1 wystarczy: 34 − 11 = 23 px, wciąż więcej niż 15, więc i tak 1,5:1).
  - [wniosek] Liczby do dostrojenia na prototypie. Początek: strefa 24 px, zsuwanie 1,5:1.
- Zsuwanie tylko gdy gracz **naciska w dół** (jak w `step()` dziś). Zgodne z ostrzeżeniem o nudgingu bez wejścia [forum].

### 7.3 Ruch z dołu w górę

- Postać widzi otwór i wiele gier nie centruje od dołu. Zapas 11 px po stronie wystarcza [wniosek].
- Dodać **tylko niewielką korektę**: gdy stopy są w obszarze 8 px poza pasem 22 px i gracz naciska w górę, przesuń do pasa (max 1 px/klatkę, zgodnie z limitem kilku pikseli z §3). Jeśli człowiek tego nie odczuwa jako problemu, pomiń.

### 7.4 Zmiana overlayu i rysowania

- Overlay lica (`_build_door_overlay`) musi pokrywać **całą szerokość strefy 7.1** (84 px), nie tylko 36 + 2 × 28. Dziś `DOOR_SIDE` = 28 px, więc strefa 24 px mieści się, ale ramy ościeża (3 px) trzeba narysować tak, by postać stojąca obok drzwi nie "wchodziła" w ościeże. [wniosek] Przy strefie 24 px stopy mogą być do 24 − 7 = 17 px od krawędzi otworu, czyli pod licem poza ościeżem. Overlay musi tam być zwykłym licem bez ościeża.
- Y-sort u stóp lica: postać z y stóp ≥ górna krawędź lica + 0 jest zasłonięta od dołu aż do tej krawędzi. Dla stopy 6 px głęboko w licu zasłonięte jest 6 px postaci. Głowa nad wierzchem pozostaje widoczna (i ona jest w pokoju wyżej, więc to zgodne).
- Postać w otworze drzwi: bez zmian (nadproże zasłania głowę, jak dziś).
- Nie wprowadzać przezroczystości lica (odrzucone).

### 7.5 Maski oświetlenia nad wierzchem ściany

- Gdy stopy stoją na wierzchu ściany lub w strefie 7.1, postać znajduje się **fizycznie w granicy dwóch pomieszczeń**. W prototypie światło jest liczone maską pokoju; trzeba sprawdzić, którą maskę dostaje postać stojąca na wierzchu: pokoju wyżej, niżej, obu? [kod nieczytany w tym researchu; wniosek z 43 §3.1, ticket 45: w przejściu postać dostaje światło obu pomieszczeń]. Zalecenie: maska pokoju wyżej obejmuje strefę 7.1 w całości, żeby postać nie migała przy zsuwaniu.
- Cień postaci na wierzchu ściany: sprawdzić, czy nie jest obcięty licem. [wniosek] Cień (okrągły u stóp) w strefie 6 px lica może się ukryć pod licem; zaakceptować.

### 7.6 Plan wdrożenia [wniosek]

1. `walkable()`: zamiast 10 schodków dodaj 2 prostokąty (lewy i prawy) obok drzwi, 24 × (`cap` + 6) px.
2. `station_routes.door_funnels()`: lejek = prostokąt 7.1 plus przejście, ta sama szerokość.
3. `WalkArea.step()`: zsuwanie 1,5:1 przy ruchu w dół w lejku.
4. `_build_door_overlay`: lico bez ościeża na całej szerokości strefy.
5. Test w prototypie: krok po kroku od 5 różnych pozycji x nad drzwiami, na 3 drzwiach w jednej ścianie (ticket 45, "kilka drzwi w jednej ścianie"). Zwrócić uwagę, czy strefy dwóch sąsiednich drzwi się nie nakładają.

## 8. Pytania otwarte do człowieka

1. **Strefa za ścianą, głębokość.** Wolisz płytką (8–16 px, postać prawie nie jest obcięta) czy głębszą (do 24 px, postać wyraźnie "za ścianą", ale obcięta)? Ticket 45 odrzucał obcinanie.
2. **Szerokość.** 24 px z każdej strony (84 px łącznie) wystarczy, czy chcesz 32 px (jak obecny lejek)?
3. **Zsuwanie.** Czy jest dopuszczalne, że postać zsuwa się w bok szybciej niż idzie w dół (1,5:1), jeśli prędkość w dół się nie zmienia?
4. **Od dołu.** Czy centrowanie od dołu ma się pojawić, czy tylko od góry?
5. **Kilka drzwi blisko siebie.** Ile px między drzwiami w jednej ścianie? Przy 84 px na strefę minimalny odstęp to 84 px (bez nakładania).
6. **Światło na wierzchu.** Którą maską oświetlenia ma być zalana postać stojąca w strefie (pokoju wyżej, czy mieszanką)?

## 9. Czego nie sprawdzono

- Żadnej gry z listy (Stardew, Eastward, Chef RPG, Graveyard Keeper, Moonlighter, Pokémon, Zelda ALttP/Minish Cap) nie obejrzałem pod kątem mechaniki drzwi. Wszystko o tych grach to wiedza ogólna albo wnioski z 43.
- Kodu Stardew (zdekompilowanego) nie czytałem. Wyszukiwanie nie zwróciło materiałów o `Farmer` ani kolizji. Liczba 48 px dla hitboxa jest z pamięci.
- Wiki Stardew (bezpośrednio) zwróciła 403. Informacje o warstwach są z podsumowania wyszukiwarki, nie z przeczytanej strony.
- Strona RPG Maker MZ, którą otworzyłem (A4 Walls), nie opisuje przechodności ani kafli "nad postacią".
- Liczby w §7 to propozycje do strojenia, nieuruchomione w grze. Nie czytałem `room_shell.gd` w całości, tylko stałe i `walkable()` do linii 145.

## 10. Źródła

- Godot: [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html), [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html), [Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html) (dokumentacja, przeczytane 2026-11-02).
- Stardew Valley Wiki: [Modding:Maps](https://stardewvalleywiki.com/Modding:Maps) (przez podsumowanie wyszukiwarki; bezpośrednio 403).
- RPG Maker MZ: [Help, A4 Walls](https://rpgmakerofficial.com/product/MZ_help-en/01_11_01.html) (nie zawiera informacji o przechodności).
- Forum Godota: [Corner Correction (like in Celeste)](https://forum.godotengine.org/t/corner-correction-like-in-celeste/15784), [Best practice for stacking TileMapLayer nodes with YSort](https://forum.godotengine.org/t/best-practice-for-stacking-tilemaplayer-nodes-with-ysort-in-godot-4-4/120306), [How to Y-sort player with 3/4 view TileMapLayer?](https://forum.godotengine.org/t/how-to-y-sort-player-with-3-4-view-tilemaplayer/83392), [Make part of a tile Y sorted](https://forum.godotengine.org/t/make-part-of-a-tile-y-sorted/137112) (wszystkie przez wyszukiwarkę, poziom forum).
- Korekta narożników top-down (wyniki wyszukiwania, poziom forum): wątek Unity, wątek Love2D (SpaceNinja), Game Development Stack Exchange (mirror), bugnet.io o korekcie narożników.
- Projekt: `docs/research/43-sciany-wnetrz-3-4.md`, `docs/research/35b-okna-w-wierzchu-sciany.md`, `docs/wayfinder/tickets/45-przejscie-przez-drzwi-w-scianie.md`, `game/world/actors/walk_area.gd`, `game/world/lighting/room_shell.gd`, `game/world/station/station_routes.gd`.
