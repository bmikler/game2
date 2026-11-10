> Kopia z game1 (`repo/game1/docs/research/27c-portrety-w-kolumnie.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

# Portrety mówcy w kolumnie rozmowy

Ticket: `docs/wayfinder/tickets/27-generowanie-ui.md` (punkt „Układ rozmowy”), uzupełnienie `27-uklady-dialogow.md` §B2/P2. Data researchu i dostępu do źródeł: **2026-10-29**. Kontekst: kolumna w stylu Disco Elysium po prawej (~30% szerokości, pełna wysokość), transkrypt rośnie w górę, opcje na dole. Portrety: pixel art ~208×256 px, popiersia w trzech czwartych, w skali całkowitej. Zawsze widać jeden portret, bieżącego mówcy.

**Jakość źródeł.** Słaba. O portretach w oknie rozmowy twórcy prawie nie mówią. Game UI Database i fora Obsidian zwracają 403 dla narzędzi. Mam jedno studium przypadku UI Disco Elysium, wtórne streszczenia wywiadu z Kurvitzem, wtórną odpowiedź dewelopera Pillars o rozmiarach portretów i recenzje. Większość opisów układów pochodzi z mojej pamięci. Oznaczenia: **[twórca]**, **[analiza]** (studium/recenzja), **[gracze]**, **[pamięć]** (niezweryfikowane w tej sesji, sprawdzić na zrzutach), **[wniosek]** (moje). **Przed prototypem warto ręcznie przejrzeć zrzuty** z gameuidatabase.com dla Disco, Pillars, Pathfinder i Citizen Sleeper.

## Streszczenie

- **Disco Elysium nie daje graczowi portretu w rozmowie.** Portret ma bieżący mówca: NPC albo umiejętność („głos”). Portret siedzi przy kolumnie, lekko wchodzi na scenę i jest podmieniany przy zmianie mówcy **[analiza]**. Linie gracza mają tylko prefiks „TY –” **[pamięć]**.
- **Wzorzec „portret NPC, gracz bez portretu” dominuje** w CRPG z oknem rozmowy (Pillars, Tyranny, Pathfinder, Shadowrun) **[pamięć]**. Pomysł „portret gracza też, ale tylko gdy mówi” jest rzadszy. Znam go raczej z VN i JRPG (lewa/prawa strona) niż z kolumny.
- **Wpisy w transkrypcie nie mają miniatur w żadnej z gier, które pamiętam.** Mówcę rozróżnia imię KAPITALIKAMI i jego kolor **[pamięć]**.
- **Rekomendacja (§3):** jedno stałe gniazdo portretu u góry pola „teraz mówi”, tuż nad najnowszą linią. Gracz po lewej, rozmówca po prawej, każdy patrzy do środka. Przejście: krótki crossfade 120–150 ms z przesunięciem 4–8 px od zewnętrznej krawędzi. Gdy mówi ten sam mówca, nic się nie dzieje. Narracja: portret wygaszony albo pusta rama. Telefon: portret w ramce „głośnika” albo sylwetka. W transkrypcie imię i kolor, bez miniatur.

## 1. Disco Elysium

| Pytanie | Odpowiedź | Źródło |
|---|---|---|
| Gdzie kolumna | Pionowo rozciągnięta, zawsze po prawej. Uzasadnienie: kolumna jak na Twitterze, prawy dolny róg to miejsce, gdzie patrzy użytkownik komputera. | **[analiza]** [studium UI, T. Martin](https://tommartin.myblog.arts.ac.uk/?p=168); **[twórca, wtórnie]** [80.lv](https://80.lv/articles/disco-elysium-working-on-ui-design), [GamerMatters](https://gamermatters.com/disco-elysiums-text-box-design-is-inspired-by-how-we-use-computers-and-twitter/) |
| Gdzie portret | „Alongside the dialogue box, slightly intruding on the in-game mise-en-scene”. Z pamięci: lewy górny róg kolumny, na granicy ze sceną. Mały, około 1/4–1/5 szerokości kolumny, malarski. | **[analiza]** jw.; położenie i rozmiar **[pamięć]** |
| Zmiana mówcy | Portrety „are replaced when a new character or voice speaks”. Nowa linia wjeżdża „with a swift swiping animation and a typewriter whirr”. Jak dokładnie przechodzi portret (cięcie czy przenikanie), **nie potwierdziłem**. | **[analiza]** jw. |
| Portret gracza | W rozmowie brak. Linie gracza mają prefiks „TY –”/„YOU –”. Portrety Harry'ego i Kima są w HUD (lewy dół), nie w kolumnie. | HUD: **[analiza]** [GamePressure](https://www.gamepressure.com/disco-elysium/user-interface/z5e3e8); brak w kolumnie **[pamięć]** |
| Głosy umiejętności | Pasywne testy wtrącają się do transkryptu jako mówcy. Imię umiejętności KAPITALIKAMI w kolorze atrybutu, przy udanym/nieudanym teście dopisek [Medium: Sukces]. Gdy mówi umiejętność, portret mówcy zmienia się na jej kartę. | Wtrącenia **[analiza]** [Awkward Mixture](https://awkwardmixture.blogspot.com/2020/03/disco-elysium-skill-checks.html); kolory opcji **[analiza]** Martin; reszta **[pamięć]** |
| Miniatury w transkrypcie | Brak. Tylko imię i kolor. | **[pamięć]** |

**Wniosek:** w Disco portret mówi „kto teraz mówi”, a transkrypt „kto co powiedział”. Gracz bez portretu to też decyzja fabularna, bo Harry nie wie, kim jest i jak wygląda (lustro to osobna scena) **[wniosek]**. U nas detektyw ma tożsamość, więc portret gracza jest uzasadniony.

## 2. Inne gry (krótko)

| Gra | Układ rozmowy | Portret gracza, gdy mówi | Przełączanie / transkrypt | Źródło |
|---|---|---|---|---|
| Pillars of Eternity (1, 2) | Okno rozmowy z portretem rozmówcy po lewej stronie tekstu, przewijany log. W PoE1 log w prawym dolnym rogu. | Nie (gracz to tylko opcje) **[pamięć]** | Portret zmienia się z mówcą; brak miniatur w logu **[pamięć]**. Dwa rozmiary portretów: duży 210×330 (jak w BG/IWD) na ekranie postaci i rozmowy, mały w HUD. | Rozmiar: **[twórca, wtórnie, Q&A 2013]** [forum Obsidian](https://forums.obsidian.net/topic/64399-update-64-developer-qa-with-kaz/page/6); log: **[gracze]** [Steam](https://steamcommunity.com/app/291650/discussions/0/1646544244468970663) |
| Tyranny | Jak Pillars (ten sam silnik/UI) | Nie **[pamięć]** | jw. | **[pamięć]** |
| Pathfinder: Kingmaker / WotR | Panel na dole, duży portret rozmówcy po lewej, imię nad tekstem, opcje numerowane | Nie **[pamięć, niepewne]** | Podmiana portretu przy zmianie mówcy (np. towarzysz się wtrąca) **[pamięć, niepewne]** | **[pamięć]** |
| Shadowrun Returns / Dragonfall / HK | Okno rozmowy z portretem ważnego NPC u góry/po lewej. Postacie poboczne bez portretu. | Nie **[pamięć]** | Gracze chwalą portret przy każdym ważnym NPC; mod do Dragonfall dodaje portrety 117 mówcom, którzy ich nie mieli. | **[gracze, z wyciągu wyszukiwarki, prawdopodobnie wątek** [forum Obsidian](https://forums.obsidian.net/topic/65219-dialog-tree-portraits-in-poe)**; strona 403, nie zweryfikowałem]**, [Nexus](https://www.nexusmods.com/shadowrundragonfall/mods/44) |
| Torment: Tides of Numenera | Okno rozmowy z dużą ilością tekstu i opisu. Czy ma portret rozmówcy, **nie potwierdziłem**. | ? | ? | — |
| Planescape: Torment | Panel tekstu na dole, z pamięci bez portretu w rozmowie (portrety drużyny w HUD) | Nie | Log rozmowy przewijany, bez miniatur | **[pamięć, niepewne]** |
| Citizen Sleeper | Okna rozmowy z portretem rozmówcy (rysowane popiersie) przy tekście. Czy Sleeper ma portret w rozmowie, **nie potwierdziłem**. | ? | — | **[pamięć, niepewne]**; recenzje nie opisują układu |
| Sunless Sea / Skies | Okno „storyletu” z jedną ilustracją sceny lub postaci, bez portretu per linia | Nie | Brak przełączania | **[pamięć]** |
| Roadwarden | Panele, opisy i wybory w dużym oknie tekstowym. Portretów mówców w opisach nie znalazłem. | — | — | **[recenzja]** [Edge UK](https://www.magzter.com/en/stories/puzzle-gaming/Edge-UK/ROADWARDEN) |
| Esoteric Ebb | Kolumna à la Disco, statystyki mówią jak głosy. Układu portretów **nie potwierdziłem**. | ? | — | **[recenzja]** [You Don't Have To](https://youdonthaveto.substack.com/p/esoteric-ebb), [PC Gamer przez Yahoo](https://tech.yahoo.com/general/articles/already-intrigued-disco-elysium-inspired-002923387.html) |
| Pentiment, Norco, Hard West | Pentiment: tekst w dymkach nad postaciami, bez portretów (patrz 27 §D). Norco i Hard West: **nie sprawdziłem**. | — | — | **[pamięć]** |

**Wzorce z narzędzi.** W Adventure Creator portret siedzi obok napisów i pokazuje się tylko, gdy mówi jego postać. Portret poza menu napisów zostaje na ostatnim mówcy **[dok/forum]** [Adventure Creator](https://adventurecreator.org/node/150). W dyskusji na forum Beamdog proponowano trzymać portret **poza** ramką tekstu, żeby układ tekstu nie skakał z portretem i bez niego, a przy braku portretu pokazywać neutralny placeholder **[gracze]** [Beamdog](https://forums.beamdog.com/discussion/comment/806121/). Oba wnioski pasują do nas.

## 3. Rekomendacja dla nas [wniosek]

### 3.1 Gdzie gniazdo portretu

Kolumna ~30% z 960 px to ~288 px logicznych. Portret 208×256 w skali 1 zajmuje ~72% szerokości i ~47% wysokości ekranu 540. To dużo, więc gniazdo musi mieć stałe miejsce, a transkrypt musi je omijać.

**O1. Portret nad paskiem „teraz mówi”, tuż nad opcjami (polecam)**
```
|  scena  |   ...starsze wpisy   |
|         |   (rosną w górę)     |
|         |----------------------|
|         | [GRACZ]  KOWALSKI    |  <- gracz: portret z lewej
|         |  lub   KOWALSKI [NPC]|  <- NPC: portret z prawej
|         |  najnowsza linia     |
|         |----------------------|
|         |  1. opcja  2. opcja  |
```
Oko jest już przy najnowszej linii i opcjach (to sedno argumentu Kurvitza), więc portret jest tam, gdzie patrzymy. Minus: zabiera wysokość transkryptowi, a przy wielu opcjach robi się ciasno. Wtedy portret może się chować lub zmniejszać tylko w fazie wyboru (do sprawdzenia).

**O2. Portret u góry kolumny, wchodzący na scenę (jak Disco)**
```
| scena [NPC]|  KOWALSKI           |
|      ^     |  ...transkrypt      |
|  wystaje   |  najnowsza linia    |
|  na scenę  |  1. opcja           |
```
Transkrypt dostaje pełną wysokość, a scena ładnie „spotyka” kolumnę. Minus: portret jest daleko od najnowszej linii, a gracz z lewej i NPC z prawej przy krawędzi ekranu tracą symetrię (prawy wyjeżdża poza ekran). Lepiej działa, gdy portret jest zawsze w jednym miejscu.

**O3. Portret jako tło/wycinek za transkryptem** (przyciemniony). Klimatyczne, ale walczy z czytelnością tekstu pikselowego. Odradzam.

### 3.2 Lewo/prawo

Pomysł z zadania (gracz z lewej od imienia, rozmówca z prawej, każdy patrzy do środka) jest spójny z konwencją VN/JRPG „my z lewej, oni z prawej” i daje drugi kanał informacji obok koloru imienia. Strona sama mówi „to ja” lub „to on”, nawet kątem oka. Warunki:
- **Imię wyrównane do strony mówcy** (do lewej przy graczu, do prawej przy NPC), żeby portret, imię i tekst tworzyły jedną grupę. Tekst linii zawsze wyrównany do lewej (czytelność).
- **Stała wysokość gniazda** niezależnie od strony, żeby transkrypt nie skakał przy zmianie mówcy (wniosek Beamdog).
- Portret odbity lustrzanie (`flip_h`) dla jednej strony **tylko jeśli** postać jest symetryczna. Blizny, przedziałek i odznaka „przeskakują”, więc dla ważnych postaci lepiej rysować w docelowym kierunku.

### 3.3 Przełączanie

- **Ten sam mówca w kolejnej linii:** portret stoi. Ruch tylko przy zmianie mówcy, bo wtedy niesie informację.
- **Zmiana mówcy:** stary portret wygasa w ~80 ms, nowy wchodzi w 120–150 ms (alfa 0→1) z przesunięciem 4–8 px od zewnętrznej krawędzi do środka, w pełnych pikselach (skala całkowita, bez subpikseli). Łącznie ≤ 200 ms, żeby nie opóźniać czytania. Jeśli gracz przewija szybko (spacją), od razu cięcie bez animacji.
- Opcja w ustawieniach „ogranicz ruch”: samo cięcie.
- Mikroakcent mówienia (opcjonalnie): 1-px „bob” portretu albo podświetlenie ramki, gdy pisze się tekst. Tańsze niż animacja ust.

### 3.4 Narracja, głosy, telefon

- **Narracja / opis:** bez portretu. Gniazdo puste (sama ramka) albo ostatni portret wygaszony do ~30% i odbarwiony. Polecam pustą ramkę, żeby było jasne, że „nikt nie mówi”. Tekst narracji kursywą lub w innym kolorze, bez imienia.
- **Głosy wewnętrzne (jeśli będą):** po stronie gracza, ikona/karta umiejętności zamiast twarzy (jak Disco) albo portret gracza w filtrze (monochrom). Imię umiejętności w jej kolorze.
- **Telefon:** rozmówca po prawej w ramce „głośnika” (szum, pikselowa ramka słuchawki, monochrom) albo sylwetka, gdy nie znamy dzwoniącego. Nieznany numer = sylwetka + „???”, zgodnie z noir.
- **3+ mówców:** dalej jedno gniazdo po prawej. Rozróżniają imię i kolor. Bez kolejki portretów.

### 3.5 Znaczniki w transkrypcie

**Imię KAPITALIKAMI w kolorze mówcy przy każdym wpisie** (jak Disco), także przy kolejnych liniach tego samego mówcy. Ewentualnie przy kolejnych liniach tylko kolorowy pasek 2 px po lewej. **Bez miniatur portretów**: w kolumnie 288 px zjadają szerokość linii, a przy 208×256 nie da się ich zmniejszyć w skali całkowitej bez osobnych assetów 32–48 px. Kolor plus imię wystarcza i zgadza się z XAG 104 („imię przy każdej zmianie mówcy”, `27-uklady-dialogow.md`).

## Do decyzji człowieka

1. O1 (portret przy najnowszej linii) czy O2 (u góry, jak Disco). Najlepiej prototyp obu w P2 i arkusz porównawczy zrzutów.
2. Czy portret 208×256 w skali 1 nie jest za duży na 288 px kolumny. Alternatywa: kadr głowy i barków ~160×160 w gnieździe.
3. Narracja: pusta ramka czy wygaszony ostatni portret.
