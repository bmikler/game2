# 85 - Światło i cienie w Project Shadowglass

Data: 2026-11-15. Ticket: [01 mapy silnika](../wayfinder-silnik/tickets/01-project-shadowglass-research.md).
Kontekst: [mapa silnika](../wayfinder-silnik/map.md), research [82](82-stylizacja-swiatla-pixel-art.md),
[83](83-stylizacja-swiatla-plener.md), [84](84-stylizacja-swiatla-plener-opus.md).

Pytanie: jak Project Shadowglass liczy i rysuje światło i cienie w pixel arcie (model źródeł, przesłony, półcień,
nakładanie wielu źródeł, stylizacja do pikseli, wydajność, narzędzia edytora) i co z tego da się przenieść do jednego
Silnika światła game2.

## Oznaczenia źródeł

Oznaczenia są te same co w 84, z jednym dodatkiem (**[W]**):

- **[P]**: źródło pierwotne od twórcy (strona gry, press kit, strona Steam, dokumentacja silnika), przeczytane w tej sesji.
- **[W]**: dosłowne słowa autora w wywiadzie, przeczytane w tej sesji. To jego własne słowa, ale wybrane i zredagowane przez redakcję.
- **[S]**: źródło wtórne (prasa, agregatory, streszczenie z wyszukiwarki).
- **[N]**: szukane, ale nie znalezione albo nieczytelne.
- **[Wn]**: mój wniosek, a nie twierdzenie o grze.

## Najkrótsza odpowiedź

Projekt da się jednoznacznie zidentyfikować. **Autor nie opublikował jednak, jak liczy światło i cienie.** W jedynym
technicznym wywiadzie świadomie wstrzymał „pełne rozbicie” techniki. Nie ma devlogu, kodu ani artykułu technicznego.
Z publicznych źródeł wiadomo tylko tyle: Godot ze zmienionym rendererem, własne shadery, point filtering, LUT-y,
ograniczona paleta, twarde cienie, toon lighting i „stabilizacja pikseli”, której nie opisano. Do tego dochodzi kilka
praktycznych uwag autora o ambiencie, krzywych zaniku i świetle skierowanym w kamerę. Na pytania ticketu o model
źródeł, przesłony, półcień, nakładanie wielu źródeł, wydajność i narzędzia edytora **źródła nie odpowiadają [N]**.

Do game2 da się przenieść kilka zasad strojenia i kryteriów testowych, ale żadnego algorytmu (sekcja 5).

## 1. Czym jest Project Shadowglass (identyfikacja)

Fakty ze źródeł:

- **Gra:** Project Shadowglass, skradanka typu immersive sim w mrocznym fantasy. Gracz jest złodziejem, który za dnia
  planuje skoki, a nocą zakrada się do strzeżonych miejsc. Inspiracje: Thief, Deus Ex, System Shock. Kamera jest
  pierwszoosobowa, 3D, z pełną swobodą ruchu 360° (wspinanie, obchodzenie obiektów).
  [P] [Steam](https://store.steampowered.com/app/3970690/Project_Shadowglass/),
  [strona gry](https://shadowglassgame.com/), [press kit](https://shadowglassgame.com/presskit.html)
- **Autor:** Dominick John, studio Starhelm Studios (Starhelm, LLC), praca solo, finansowana samodzielnie, w wolnym
  czasie. [P] [press kit](https://shadowglassgame.com/presskit.html),
  [strona gry](https://shadowglassgame.com/); kanały autora: [X @dominickjohn](https://x.com/dominickjohn),
  [YouTube](https://www.youtube.com/channel/UCRN5dXi-Ym4IvQi-Uwl3f9Q)
- **Stan:** wczesna produkcja. Mapa drogowa na stronie: Alpha Demo 2026, Early Access 2027. Press kit podaje ponad
  225 000 wishlist (marzec 2026). Pierwszy publiczny pokaz techniki: „Early Alpha Teaser” z września 2025. [P] press kit
- **Technologia:** sama strona i Steam mówią tylko o „unikalnej technologii 3D pixel art” i nie nazywają silnika [P].
  Silnik **Godot** podaje autor w wywiadzie: „For me, it was the Godot engine, hands down.” Dodaje: „I could tweak the
  renderer's code however I needed” oraz „Everything you're seeing was assembled and optimized within Godot.” Wersji
  Godota nie podaje. [W] [80.lv, 19.05.2026](https://80.lv/articles/interview-how-project-shadowglass-creates-its-impossible-fully-3d-pixel-art-look)
- **Światło w rozgrywce:** światło jest mechaniką skradania. Gracz chowa się w ciemności i gasi pochodnie, a strażnicy
  używają świateł i pochodni, gdy coś podejrzewają. Press kit wymienia „shadow/light detection”. [P] Steam, press kit

**Kandydaci na inne znaczenie nazwy:** nie znalazłem innej gry ani technologii o nazwie „Shadowglass”. Wyszukiwanie
zwraca jeszcze **ShaderGlass** (mausimus, itch.io), czyli nakładkę z shaderami ekranowymi (np. CRT) na okna Windows
[S, strona nieczytana]. To narzędzie post-process, a nie silnik światła, i nie ma związku z pytaniem. Identyfikację
uważam za jednoznaczną [Wn].

## 2. Co autor mówi o technice

Wszystkie cytaty poniżej pochodzą z jedynego wywiadu technicznego:
[80.lv, „How Project Shadowglass Creates Its 'Impossible' 3D Pixel Art Look”, 19.05.2026](https://80.lv/articles/interview-how-project-shadowglass-creates-its-impossible-fully-3d-pixel-art-look) [W].

**Ogólna metoda renderowania**
- Gra nie używa wokseli ani billboardów: „It doesn't use voxels, and authored 2D pixel pushing is optional.” Obraz
  daje stabilna kamera perspektywiczna 3D.
- „The heavy lifting comes from a set of custom shaders and rendering code.”
- Wygląd nie pochodzi z jednej techniki, tylko z wielu działających razem. Niektóre są oczywiste: „like
  point-filtering and LUTs”, ale „those are just the surface layers of deeper pixel stabilization work.” Na czym ta
  stabilizacja polega, autor **nie mówi**.
- Proponuje nazwę stylu „Pixerly”.

**Światło (odpowiedź na pytanie o workflow oświetlenia)**
- „Lighting is the biggest challenge, because a sense of depth doesn't come easy in low-fi 2D.”
- „the dynamic lighting and shadows need to look right AND play right.”
- Kiedy wiadomo już, gdzie ma stać każde światło („Once you've worked out where every light needs to go”), sam
  workflow w silniku jest według autora „pretty basic”.
- **Ambient:** „in a limited palette, the wrong ambient levels can destroy key details, like the lines in the brick.”
- **Zanik:** „Default light attenuation curves can muddy where shadows begin.”
- **Światło skierowane w kamerę:** „Directional light pointing toward the camera flattens out depth if you don't have
  a secondary light to preserve form.”

**Stylizacja i produkcja**
- „Palette restrictions, hard shadows, toon lighting, and stepped animation can all drastically help or hurt the look.”
- Ograniczona paleta daje spójność i czytelność. Mgła może zostać „full spectrum for a subtle atmosphere”. Poświata i
  god rays są jeszcze w testach („how much glow and god rays fit the vibe, if at all”).
- Obiekty mają wersje na bliską i daleką odległość. Animacja jest skokowa: daleko mniej klatek, blisko więcej.
- Narzędzia: Blender, Affinity, Aseprite i Godot. Własnego narzędzia edytora autor nie wymienia.
- W wywiadzie są porównania z siatką (wireframe) w osadzonym wideo, ale bez opisu w tekście [N].

## 3. Czego źródła nie mówią (punkty z ticketu)

| Punkt ticketu | Stan źródeł |
|---|---|
| Model źródeł (jakie typy świateł, słońce, niebo) | [N] Wiadomo tylko, że są pochodnie (do gaszenia) i światło kierunkowe (cytat wyżej). |
| Przesłony / technika cieni (shadow mapy, rozdzielczość) | [N] Wiadomo tylko, że cienie są „hard shadows”. |
| Półcień | [N] |
| Nakładanie wielu źródeł | [N] |
| Stylizacja do pikseli: dither, poziomy | [N] Ditheru autor nie wspomina. Wymienia paletę, LUT-y, point filtering i toon lighting. |
| Wydajność | [N] |
| Narzędzia edytora | Tylko „pretty basic” i lista programów; [N] co do narzędzi własnych. |

Czego szukałem bez skutku: devlogu (strona gry nie linkuje żadnego [P]), postów autora na X (strony X zwracają 402
[N]), listy filmów na YouTube (przekierowanie na stronę zgody [N]), artykułów TechSpot, GamesRadar i Rock Paper
Shotgun (403, ucięta treść albo brak dostępu [N]). Według streszczeń wyszukiwarki prasa powtarza tylko ogólniki z
wywiadu 80.lv („silnik zamienia geometrię 3D w stylizowaną siatkę pikseli”) [S]. Starszy tekst
[80.lv z 06.10.2025](https://80.lv/articles/take-on-the-role-of-stealthy-loner-in-this-dark-fantasy-pixel-art-sim)
linkuje dwa posty autora z nagraniami WIP
([1](https://twitter.com/dominickjohn/status/1975021746475737163),
[2](https://twitter.com/dominickjohn/status/1973075079865962526)), ale treści technicznej w nim brak [S/N].

**Do obejrzenia ręcznie** (sam obraz i dźwięk, agent ich nie przeczyta): wideo z wywiadu 80.lv z porównaniem z
siatką oraz film „100K Wishlist Milestone + Q&A” z października 2025, który według press kitu zawiera „graphics demo,
developer walkthrough” [P, wideo nieobejrzane].

## 4. Tło: co daje sam Godot w 3D (żeby oddzielić Godota od techniki autora)

Według [dokumentacji Godot 4.7, „3D lights and shadows”](https://docs.godotengine.org/en/4.7/tutorials/3d/lights_and_shadows.html) [P]:
- światło kierunkowe używa PSSM (2 albo 4 podziały frustum);
- omni używa cube albo dual paraboloid, a spot jednej mapy;
- miękkie cienie z rozmiaru źródła to PCSS, opisane jako „high performance cost, especially for directional lights”;
- domyślne filtrowanie cieni ma wzór ditheru, który przy prostych teksturach może być widoczny.

Wnioski [Wn]:
- Twarde cienie w Shadowglass prawdopodobnie biorą się z wbudowanych shadow map Godota z wyłączonym albo słabym
  filtrowaniem, poprawionych w zmodyfikowanym rendererze. To przypuszczenie, a nie fakt.
- „Stabilizacja pikseli” przy kamerze 3D, która się obraca i przesuwa, to problem innej klasy niż w game2: chodzi o to,
  żeby piksele tekstur i cieni nie migotały przy ruchu kamery. game2 ma stały rzut 0,60 i stałą skalę 40 px/m, więc
  tego problemu w tej postaci nie ma.

## 5. Co z tego dla Silnika światła game2

Wszystko w tej sekcji to moje wnioski [Wn]. Odnoszę je do zasad z mapy, a nie do decyzji, których w mapie nie ma.

**Czego nie przenosić**
- **Algorytmu nie ma czego przenieść.** Shadowglass nie opublikował modelu źródeł, przesłon, półcienia, nakładania ani
  stylizacji. Nie warto na nim opierać żadnej decyzji ticketów 07 („Jeden model światła”) ani 09 (prototyp nakładania).
  Ticket 02 (nakładanie cieni z wielu źródeł) musi szukać gdzie indziej.
- **Stabilizacja pikseli kamery 3D** i wersje assetów na blisko i daleko nie dotyczą stałego rzutu game2.
- **Twarde cienie i toon lighting jako wzór:** autor sam pisze, że mogą „drastically help or hurt”. Mapa i 84 wybrały
  półcień i szew ditheru A′, więc Shadowglass nie jest argumentem ani za, ani przeciw. To inny gatunek (FPP w ciemnych
  wnętrzach), a nie Kotwica ani Referencja z mapy.

**Co przenieść jako zasady strojenia i przypadki testowe** (zgodne z zasadą mapy „oprawa ponad realizm, nastrój w danych”)
1. **Ambient a detal tekstury.** Uwaga autora o zbyt wysokim albo zbyt niskim ambiencie, który przy ograniczonej
   palecie niszczy linie cegieł, przekłada się na kryterium oceny. Poziom nieba i ambientu w cieniu, po stylizacji A′,
   nie może zlewać detalu tekstury ściany w jeden poziom. Proponuję to jako punkt listy oceny na żywo w Poligonie i jako
   powód, żeby siła nieba i ambientu była parametrem w `.tres` (mapa już tego wymaga), a nie stałą.
2. **Krzywa zaniku jako dana artystyczna.** Według autora domyślne krzywe zaniku zamazują granicę, gdzie zaczyna się
   cień. Dla game2 wynika z tego, że zanik lamp i latarni powinien być krzywą w `.tres` (np. `Curve`), a nie wzorem
   fizycznym wpisanym w shader. To pasuje do zasady mapy „fizyka daje punkt startu, krzywe mogą ją wygiąć” i do wymogu,
   że strojenie nie może wymagać zmian w shaderach.
3. **Słońce „pod światło”.** Światło kierunkowe skierowane w kamerę spłaszcza głębię, jeśli nic nie podtrzymuje formy.
   W game2 odpowiada to porom dnia, gdy azymut słońca wypada od strony widza albo naprzeciw niego w rzucie 0,60. Wtedy
   formę muszą trzymać niebo i odbite światło. Proponuję dodać takie godziny do trudnych scen testowych w strategii
   testów (ticket 11) i sprawdzić, czy krzywa siły nieba w ciągu doby wystarcza bez osobnego światła „fill”, które byłoby
   specjalnym przypadkiem.
4. **Kwantyzacja tak, atmosfera gładko.** Autor kwantyzuje paletą i LUT-em, a mgłę zostawia w pełnym spektrum. Dla game2
   to opcja do rozważenia przy stylizacji A′: efekty atmosferyczne (mgła, poświata, ewentualnie niebo nocą) mogłyby
   omijać szew ditheru. **To wymagałoby jednak drugiej ścieżki w stylizacji.** Musiałaby być ona określona przez rodzaj
   składnika światła w kontrakcie, a nie przez scenę, żeby nie złamać zasady „bez ifów”. Decyzja należy do ticketu 07
   albo 12, nie do tego researchu.
5. **LUT jako osobny etap koloru.** Shadowglass trzyma kolor (LUT, paleta) oddzielnie od liczenia światła. Dla game2
   wspiera to podział: silnik liczy światło w buforze, a kolor i nastrój pochodzą z zasobów (gradienty doby, ewentualnie
   LUT jako tekstura w `.tres`). Strojenie kolorów zostaje poza mapą (ticket 38 mapy grafiki). Kontrakt powinien tylko
   zostawić miejsce na taki etap.
6. **Światło jako zapytanie z gry.** W Shadowglass poziom światła jest mechaniką (wykrywanie). Mapa game2 nie mówi, czy
   gra będzie potrzebować poziomu światła w punkcie po stronie logiki (CPU). Zostawiam to jako pytanie do kontraktu danych
   sceny (ticket 08), a nie jako wymaganie.

**Ocena przydatności:** niska dla modelu i algorytmu, umiarkowana dla listy kryteriów oceny i zasad strojenia. Jeśli
człowiek chce iść dalej tym tropem, jedyna droga to obejrzeć dwa filmy z sekcji 3 albo zapytać autora na jego
Discordzie. Oba kroki są poza zasięgiem agenta.
