# 82 - Stylizacja obliczanego światła i cieni jako pixel art

Data: 2026-11-11. Pytanie: jak gry pixel-art i shader artyści stylizują miękkie, liczone światło/cienie
(mało poziomów, uporządkowany dither, bez gradientów i losowego szumu), zachowując stabilne i wiarygodne cienie.

## Uczciwe zastrzeżenie o źródłach

Wyszukiwarka nie zwróciła prawie żadnych źródeł pierwotnych z poziomu shadera dla gier z listy.
Większość znanych materiałów (filmy t3ssel8r, Aarthificial, talki o Sea of Stars) to wideo, którego tu nie dało się
odczytać. Poniżej każde twierdzenie ma ocenę: **[P]** = źródło pierwotne/oficjalne przeczytane,
**[S]** = wtórne/wywiad/marketing, **[W]** = wiedza ogólna z zawodu, niezweryfikowana tu źródłem
(do sprawdzenia w grze). Sekcja "Kandydaci" to nasze wnioski inżynierskie, nie cytat z gier.

## 1. Co faktycznie ustalono, per gra

| Gra / źródło | Co wiadomo | Ocena |
|---|---|---|
| Octopath Traveler (HD-2D) | UE4; sprite 2D w środowisku 3D oświetlanym normalnie; dodano światło punktowe, by postacie rzucały cienie na otoczenie. Brak szczegółów shadera. [Unreal Spotlight](https://www.unrealengine.com/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true), [Wikipedia HD-2D](https://en.wikipedia.org/wiki/HD-2D) | [S], słabe. HD-2D NIE kwantyzuje światła; to nowoczesne, gładkie światło + bloom/DoF. Nie jest wzorem dla naszego problemu. |
| Sea of Stars | Jedna osoba (Jeakim Hamel) od 2018 robiła dynamiczne światło w własnym pipeline; światło związane z mechaniką dnia/nocy. [MobileSyrup](https://mobilesyrup.com/2023/09/11/sea-of-stars-level-design-sabotage-studio-thierry-boulanger-interview/). Nie znaleziono talku z detalami. | [S], brak szczegółów techniki |
| Dead Cells | Postacie: pipeline 3D->sprite. Tła/dekoracje: pixel-art + ręczne normal mapy, "dynamiczny system światła 3D daje odcienie i reliefy". [80.lv wywiad](https://80.lv/articles/interview-with-the-developers-of-dead-cells). Artykuł Game Developer o pipeline niedostępny. | [S]. Światło sprite'ów to normal-map shading, nie cienie rzucane. |
| Children of Morta | Animacje pikselowe rozciągnięte ~4x do HD; światło ma rozdzielczość HD (gładkie), nie pikselowe - "efekt teatrzyku". [TechRaptor](https://techraptor.net/content/how-dead-mage-created-the-art-for-children-of-morta) | [S]. Przykład podejścia przeciwnego: NIE stylizują światła. |
| Eastward (Pixpil) | Własny silnik, "general deferred shading", wiele świateł, ambient per nastrój. [Red Bull](https://www.redbull.com/my-en/eastward-interview), [Game Developer](https://www.gamedeveloper.com/art/eastward-s-creators-share-insights-on-making-pixel-art-adventures) | [S]. Brak informacji o kwantyzacji. |
| REPLACED | 2.5D: świat 3D oświetlony/ocieniony wokół ręcznie rysowanych sprite'ów, DoF, efekty. [Bonus Action](https://bonus-action.com/feature/replaceds-director-taught-himself-everything-from-scratch-to-make-the-most-beautiful-pixel-art-game-of-the-year-i-just-got-a-keen-eye-on-things/) | [S]. Brak szczegółów shadera. |
| Hyper Light Drifter | Nie znaleziono opisu technicznego. Jedyny trop to wskazówka gracza z forum o blendzie warstwy światła. | brak źródła |
| NORCO, Blasphemous, KRZ, Gemini Rue | Nic nie znaleziono. Z natury to głównie światło malowane ręcznie/baked, nie liczone. | brak źródła; [W] |
| t3ssel8r | Wideo (nieczytelne tu). Pośrednio: deweloper Godot inspirowany nim mówi, że oświetlenie to zwykłe toon lighting, "nic szczególnego"; kluczowe są kontury i pikselizacja renderu 3D. [David Holland](https://davidholland.netlify.app/articles/3d-pixel-art-rendering), [Cascadeur wywiad](https://cascadeur.com/blog/general/making-an-animation-for-a-3d-pixel-art-game) | [S], słabe |
| Aarthificial | Nie znaleziono tekstu; wideo niedostępne. | brak źródła |

Wniosek: rynek dzieli się na (a) światło gładkie, HD, a pikselowe tylko sprite'y (Children of Morta, HD-2D),
(b) światło malowane/baked (większość klasyki), (c) mało opisanych, naprawdę kwantyzowanych shaderów (głównie hobbyści).
Nie ma publicznie opisanej "gry-wzoru" dla naszego przypadku (fizyczne miękkie cienie z okien -> pixel art).

## 2. Techniki - co jest potwierdzone

### Dither uporządkowany i stabilność
- Dither uporządkowany = porównanie wartości piksela z wcześniej policzoną macierzą progów; wynik deterministyczny
  i równoległy per piksel. Bayer: bardziej strukturalny; blue noise: bardziej organiczny. W gammie sRGB dither
  daje zbyt jasne gradienty - progować w przestrzeni liniowej. [P] [Surma, Ditherpunk](https://surma.dev/things/ditherpunk/)
- Return of the Obra Dinn: 8x8 Bayer + 128x128 blue noise; dither mapowany na sferę zamiast na ekran, aby nie "pływał"
  przy ruchu kamery (devlog Lucas Pope na TIGSource, temat 40832; strona zwróciła 403, więc pośrednio przez
  [PlayStation Blog](https://blog.playstation.com/archive/2019/10/17/lucas-pope-on-return-of-the-obra-dinns-art-style)
  i [setsideb](https://setsideb.com/?p=5672)). [S]
- Wniosek dla nas [W]: kamera jest prawie statyczna (widok 3/4, 960x540), więc wzór dithera w **przestrzeni ekranu
  z przyciągnięciem do pikseli** jest stabilny; pływa tylko to, co się rusza (postać, ruchome cienie), a to jest
  akceptowalne i wręcz pożądane (cień "krystalizuje" się na pikselach). Wzór zakotwiczony w świecie (po `world_pos`)
  potrzebny tylko, jeśli kamera się przesuwa.
- Praktyka z devlogu Rain World 3D: za mało kolorów -> ciemno i dziwnie, za dużo -> dither przestaje działać
  na złożonych teksturach; liczbę poziomów trzeba stroić. [S] [itch devlog](https://itch.io/devlog/964856/graphics.amp)

### Światło pikselowe w Godot
- Blessings of the Forge (Godot): światło zapisywane do tekstury 640x360 w compute shaderze, żeby samo światło było
  pikselowe; cienie z okien jako rzutowane równoległoboki na zewnątrz, ambient ważony kierunkiem. Brak kwantyzacji
  i ditheringu w poście. [S] [devlog](https://darredevyll.itch.io/blessings-of-the-forge/devlog/1009729/update-on-shaders-and-lighting)
  Dla nas: już mamy jeden bufor światła; rozdzielczość natywna (960x540) jest odpowiednia.
- Graveyard Keeper: cienie jako obracane sprite'y (do 4 na obiekt: słońce + 3 najbliższe światła); kolor przez ~10 LUT
  na porę dnia (LUT 3D z filtrów Photoshopa). [P/S] [blog dewelopera](https://slava.lazybeargames.com/graveyard-keeper-how-the-graphics-effects-are-made)
  Uwaga: to pokazuje, że gra z miękkim światłem też ogranicza się do "jeden cień na źródło" i LUT-owego koloru, a nie poziomów.
- Bad Pixels (dadako): cienie twarde z natury (stencil/rzut), "binarne" bez gradientów - spójne z pixel-art, ale to cienie
  geometryczne, nie liczone miękko. [S] [devlog](https://dadako.itch.io/bad-pixels/devlog/715210/lighting-part-2-shadows)

## 3. Techniki - wiedza ogólna [W], do weryfikacji w Poligonie

- **Posteryzacja całkowitej luminancji (cel ramp)**: jedna krzywa progowa na SUMIE światła w pikselu, 3-5 poziomów.
  Jeden konturek na poziom, niezależnie od liczby źródeł. Standard w toon shadingu 3D (t3ssel8r: "zwykłe toon").
- **Dither tylko w wąskim pasie na progu poziomu**: zamiast `floor(L*N)`, liczyć `t = clamp((L - prog)/w + 0.5, 0, 1)`
  i porównywać z Bayerem. Szerokość pasa `w` ustawiać przez `fwidth(L)` tak, by pas miał stałe ~2-4 px na ekranie
  niezależnie od stromości gradientu (inaczej płytki gradient = szeroki, brzydki dither; stromy = twardy skok).
- **Paleta zamiast kwantyzacji RGB**: poziom światła -> indeks na rampie palety (zimna -> ciepła), dither między sąsiednimi
  stopniami rampy; albo LUT (jak Graveyard Keeper) po kwantyzacji luminancji. Daje pewność, że wyjście to kolory z palety.
- **Rozdzielenie cieni**: miękki cień kontaktowy/AO (1-2 poziomy, szeroki dither, pod obiektem) vs twardy cień rzucany
  od światła kluczowego (ostre krawędzie, bez dithera lub wąski). Typowy układ "ambient płaski + key twardy".
- **Histereza/stabilność**: progować wartości zmieniające się płynnie w czasie (ruch postaci) i nie dodawać szumu zależnego
  od czasu; unikać `fwidth` z wartości skaczących; ewentualnie kwantyzować pozycję postaci do piksela przed obliczeniem cienia.
- **Niebo/ambient**: w grach stylizowanych zwykle płaski ambient + twarde światło kluczowe; niebo bywa 1-2 poziomy lub w ogóle bez cienia.

## 4. Dlaczego nasze podejście z progowaniem per źródło zawiodło

Próg 50% udziału cienia każdego źródła osobno łamie się, bo udział cienia zależy od geometrii źródła względem piksela:
blisko dużego okna penumbra jest wąska (cień krótki i twardy), daleko szeroka (cień długi, rozmyty), a daleko od postaci
prawie każdy piksel ma ułamkowy udział (losowe konturki). Do tego każde źródło dawało własny twardy cień, więc nakładały się.
Problem leży w progowaniu **względnego** udziału źródła bez uwzględnienia, ile to źródło w ogóle daje światła w tym punkcie.

## 5. Kandydaci dla nas

Oznaczenia: DL = stała długość cienia niezależna od odległości od okna; BK = brak konturów daleko od postaci;
BN = brak nakładających się twardych cieni.

### A. Posteryzacja sumy światła + wąski dither na progach (cel ramp na całości)
- Jak: `L = suma wszystkich źródeł z cieniami`, 3-5 poziomów, pas ditherowy stałej szerokości px (sekcja 3).
- Plusy: najprostsze; jeden zestaw konturów -> BN spełnione automatycznie; paleta/ramp łatwe.
- Minusy: DL NIE: długość cienia zależy od tego, gdzie `L` przecina próg, więc nadal krótki przy oknie, długi daleko.
  BK częściowo: daleko od okna gradient jest płytki, próg trafia w przypadkowe miejsce.
- Werdykt: dobra baza koloru, ale sama nie rozwiązuje cienia.

### B. Znormalizowana widoczność: próg na stosunku (z cieniem / bez cienia), mnożenie przez gładką/ramp bazę
- Jak: `V = sum(Li * vi) / sum(Li)` (po wszystkich źródłach, `Li` = wkład bez przeszkód, `vi` = widoczność), próg V na 2-3 poziomy
  (np. pełne / półcień / cień), potem `wynik = ramp(L_bez_cieni) * poziom(V)`. Gdzie `sum(Li) < eps`, wymusić V=1.
- Plusy: DL TAK (próg względem tego, ile światła brakuje, nie ile go jest; długość cienia zależy od geometrii przeszkody,
  nie od odległości od okna). BK TAK dzięki fade V->1 przy braku światła. BN TAK: jedna zagregowana maska V zamiast N masek.
- Minusy: nowy kanał w buforze (suma bez cieni), trzeba strojenia progów V; dwa źródła o różnych kierunkach dają jeden
  "średni" cień (może wyglądać mniej wiarygodnie niż dwa wyraźne).
- Werdykt: najlepiej odpowiada na wszystkie trzy objawy. Rekomendowany do pierwszego prototypu.

### C. Cień tylko od światła kluczowego, reszta gładka/płaska
- Jak: w pikselu wybrać dominujące źródło (największe `Li`, albo na sztywno słońce/okno); jego cień -> twardy (1 próg + wąski
  dither); lampy i niebo -> płaskie lub 2 poziomy bez własnych cieni rzucanych; cień kontaktowy AO osobno (1-2 poziomy).
- Plusy: BN TAK (jeden twardy cień); DL TAK dla klucza; czytelne ("ambient płaski + key twardy" jak w stylizowanych grach).
- Minusy: zmiana dominującego źródła w pikselu daje szew (trzeba histerezy lub wag); lampy "tracą" cienie - mniej fizycznie;
  przy nocy (tylko lampy) klucz się zmienia często.
- Werdykt: dobry dzień; w nocy wymaga reguły wyboru klucza. Można łączyć z B (V liczone tylko z grupy "klucz").

### D. Cień jako osobna warstwa kwantyzowana: pikselowy "shadow mask" z dithera na pasie penumbry
- Jak: z `V` (jak w B) zbudować maskę 0/1 z progiem ~0.5 + dither w pasie o stałej szerokości px; maska mnoży/odejmuje na rampie
  palety. Penumbra z dużej szczeliny okna zostaje, ale jako 2-4 px dithera, nie jako gradient.
- Plusy: najwierniejszy wygląd pixel-art z "miękkością" zachowaną jako dither; stabilne przy ruchu, jeśli pas stały w px.
- Minusy: wymaga B (czyli V); wygląd dithera trzeba wybrać (Bayer 4x4 vs 8x8; blue noise wygląda mniej "pixel-artowo" [W]).

### E. Niebo i ambient: bez kwantyzowanych cieni, tylko AO
- Jak: niebo przez szyby -> płaski ambient + 1-2 poziomy "przy ścianie/pod meblem" (AO) z szerokim ditherem; żadnych twardych cieni.
- Plusy: BK i BN dla nieba; usuwa najbardziej "szumiący" składnik (bardzo miękka penumbra).
- Minusy: tracimy fizyczne cienie od nieba (ale i tak są prawie niewidoczne w gładkiej wersji).

### Sugerowana kombinacja
B (znormalizowana widoczność V) + D (dither w pasie stałej szerokości) + E (niebo jako AO) + paleta rampą z A.
Kolejność prób w Poligonie: (1) sam A na obecnym buforze jako punkt odniesienia, (2) B+D, (3) dodać E, (4) C tylko jeśli
w B kierunki z wielu źródeł wyglądają nienaturalnie. Oceniać na 2 trudnych poziomach, żywo w grze (nie na zrzutach).

## 6. Otwarte pytania / do zbadania dalej
- Obejrzeć ręcznie (wideo, nieczytelne dla agenta): t3ssel8r (pixel art 3D), Aarthificial (oświetlenie pixel-art), talk Sea of Stars,
  devlog Obra Dinn (TIGSource 40832) - ewentualnie dopisać do tego pliku.
- Zmierzyć w Poligonie, jaka szerokość pasa dithera (2/3/4 px) i jaka macierz Bayera (4x4 vs 8x8) wygląda najlepiej przy 72 px postaci.
- Czy V liczone po sumie źródeł nie rozmywa wiarygodności przy dwóch silnych źródłach o różnych kierunkach (punkt C jako plan B).
