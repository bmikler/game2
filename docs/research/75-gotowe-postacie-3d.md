# 75. Gotowe zestawy 3D: postać realistyczna + ubrania + animacje na jednym szkielecie

Data: 2026-11-09. Kontekst: research 74 (3D do pixel artu 72 px), ticket 12. Pytanie: czy istnieje gotowy zestaw do Blendera (dorosły mężczyzna ~50 lat, realistyczne proporcje; kurtka do bioder, sweter, spodnie, botki, szalik; chód w 3 kierunkach, idle, najlepiej wyciąganie broni/łuku), w którym wszystko działa razem na jednym szkielecie bez ręcznego retargetu. Nic nie pobrano, nie założono kont, nic nie kupiono. Tylko odczyt stron i wyszukiwanie.

Oznaczenia jak w 74: **[pierwotne: URL]** źródło będące właścicielem faktu; **[wtórne: URL]** blog, forum, agregator, wyszukiwarka; **[wniosek]** moja inferencja; **[brak]** nie sprawdzone. Kursy orientacyjne: 1 USD ≈ 4 zł (przyjęte, nie sprawdzane).

Już sprawdzone wcześniej i nie powtarzane: MPFB2 + paczki ubrań MakeHuman + mocap CMU przez własny retarget (zniekształcenia, odrzucone); Quaternius UBC + UAL Standard (działa od kopa, ale ciało superbohatera, brak ubrań, chód „średni”).

## Odpowiedź w skrócie

1. **Nie znalazłem gotowego, darmowego zestawu spełniającego wszystkie kryteria naraz** (realistyczny dorosły + zimowe ubrania + animacje z łukiem na jednym rigu). Każdy kandydat ma co najmniej jedną lukę. **[wniosek z całego przeglądu]**
2. **Najbliżej „od kopa” jest ekosystem Quaternius** (UBC + UAL + Modular Outfits, wszystko CC0, wspólny „universal humanoid rig”), ale ubrania są fantasy, a proporcje stylizowane. Realistyczne „Regular” z UBC nie było dotąd oceniane osobno (patrz niepotwierdzone).
3. **Najciekawsza nowa droga: MPFB (CC0, realistyczny dorosły, ubrania MakeHuman) → eksport GLB → Mesh2Motion** (MIT, animacje CC0, szkielet „Human”, część animacji od Quaternius). Eliminuje własny retarget CMU, ale jakość auto-skinningu i dopasowania szkieletu do ubranej siatki jest nieznana bez próby.
4. **Płatne zestawy z gotowym „wszystko na jednym rigu”** (Character Creator 5 + ActorCore, Human Generator) przekraczają budżet ~100 zł albo mają niejasną licencję. Mixamo jest darmowe, ale wymaga konta Adobe ID (w tej sesji nie wolno zakładać).
5. **VRoid/VRM odpada** (styl anime, potwierdzone niżej). Synty odpada (low-poly stylizowane, subskrypcja/zakup, nie realistyczne).

## 1. Tabela kandydatów

Skala ubrań/animacji: jest / częściowo / brak. Koszt w USD wg źródeł, w nawiasie orientacyjnie zł.

| Kandydat | Licencja (skrót) | Koszt | Proporcje | Ubrania | Animacje | Wspólny szkielet bez retargetu | Konto |
|---|---|---|---|---|---|---|---|
| **Mixamo** (Adobe) | royalty-free, w tym gry; nie wolno dystrybuować surowych plików; nie do trenowania ML | 0 | postacie realistyczne-ogólne [wniosek]; dowolny model po auto-rigu | tylko ubrane postacie z biblioteki; Fuse (ubrania) nie potwierdzone | ~2500 klipów, w tym chód, idle, łuk/broń [wtórne] | tak, w obrębie rigu Mixamo; MPFB ma rig „Mixamo” i skrypt „snap to mixamo” | **tak, Adobe ID** |
| **MPFB2** (już mamy) | assety CC0, wynik bez roszczeń | 0 | realistyczne, dorosły męski | paczki MakeHuman, każda z własną licencją | **brak własnych** | rigi: Default, GameEngine, CMU MB, Mixamo; animacji nie dostarcza | nie |
| **Mesh2Motion** (web, open source) | kod MIT; modele, rigi i animacje CC0 | 0 | dowolny własny GLB | własny model | „170+”, szkielet Human, część od Quaternius | tak: szkielet dopasowywany do modelu, animacje dołączone | nie podano |
| **Quaternius UBC** | CC0 | 0 (Standard) | Superhero / Regular / Teen, M/K, stylizowane | brak (20 fryzur) | brak | rig „universal humanoid”, zgodny z UAL | nie podano |
| **Quaternius UAL 1** | CC0 | Standard 0 (45 klipów); Pro $9,99 (~40 zł, 120+); Source $14,99 | n/d | n/d | lokomocja 8 kierunków, jog, sprint, walka/broń, emotki; nazw klipów brak | tak, z UBC | nie podano |
| **Quaternius UAL 2** | CC0 | „60–70% darmowe”, ceny tylko w obrazkach | n/d | n/d | 130+; walka, parkour, farming, zombie | tak | nie podano |
| **Quaternius Modular Character Outfits – Fantasy** | CC0 | cena tylko w obrazkach | stylizowane | 12 strojów, 62 części, fantasy (nie zimowe codzienne) | brak | rig humanoid, działa z UAL i głowami UBC | nie podano |
| **Quaternius Ultimate Modular Men** | CC0 | 0 | stylizowane low-poly [wniosek] | 11 postaci po 4 części | 24 klipy | niepotwierdzone | nie |
| **KayKit Character Animations** | CC0 | „name your own price” (0); Source $14,99 | stylizowane, kreskówkowe | n/d | chód, idle, strzelanie z łuku/celowanie/przeładowanie; „draw” nie wymieniony | Rig_Medium (100+ klipów), Rig_Large (25+) | nie podano |
| **Human Generator** (Superhive) | tag „GPL”, tiery: Commercial $128 / Personal $68; treść licencji tierów niejasna | $68–128 (~270–510 zł) | realistyczne, generator | ubrania, fryzury, mimika | **tylko biblioteka póz**, nie animacje | rig (Rigify w tagach), animacji brak | konto sklepu |
| **MB-Lab** | repo AGPL/GPL, zarchiwizowane 21.07.2024; „BVH import is buggy” | 0 | realistyczne | brak w opisie | brak | rigi do poprawy według autora | nie |
| **Character Creator 5 + ActorCore** (Reallusion) | EULA Reallusion; eksport FBX wymaga licencji eksportu | CC5 perpetual ok. $299 (~1200 zł) lub 365: $29/mies., $99/rok | realistyczne, regulowane | ubrania + autodopasowanie, biznesowe bazy | tysiące klipów ActorCore, płatne osobno | tak, wspólny rig CC | konto Reallusion |
| **Rokoko Motion Library** | „including for commercial use” (strona Rokoko) | 0 (263 klipów) | n/d (tylko animacje) | n/d | tak, wiele; lista nieznana | **nie**, wymaga retargetu | formularz z e-mailem |
| **Auto-Rig Pro** (Superhive) | GPL (dodatek); wyniki własne | Full $50 (~200 zł), Lite $25 bez Remap | n/d | n/d | n/d | to narzędzie do retargetu (plan B) | konto sklepu |
| **Daz 3D** | sprite ze stosu renderów nie wymaga Interactive License | postacie i ubrania płatne per produkt | realistyczne | ubrania dopasowane do figury | aniBlocki płatne | wspólny szkielet figury [wniosek, nie sprawdzone] | konto Daz |
| **100 Avatars** (Polygonal Mind) | „use them in any project” (repo); CC0 wg wtórnego | 0 | low-poly humanoidy | brak potwierdzenia | brak własnych | rig pod Mixamo wg wtórnego | nie |
| **Kenney Mini Characters** | CC0, bez atrybucji | 0 | chibi | n/d | n/d | n/d | nie |
| **Synty** | One-time lub Standard Subscription | płatne | low-poly stylizowane | tak | tak | tak (Unity/Unreal) | konto sklepu |
| **VRoid / VRM** | warunki per model (VRM 0.0 ma „Non-profit only”) | 0 | anime | tak (w VRoid) | brak własnych | VRM humanoid | nie |

## 2. Źródła i dokładne brzmienie licencji

### 2.1 Quaternius (CC0)
- UBC: „Free to use in personal, educational and commercial projects. (CC0 License)”; sześć modeli (męski i żeński) w trzech zestawach proporcji: Superhero, Regular, Teen; 20 fryzur; rig humanoidalny z retargetingiem; zgodny z UAL; ubrań nie wymieniono **[pierwotne: quaternius.com/packs/universalbasecharacters.html]**.
- UAL 1 na itch.io: licencja „Creative Commons Zero v1.0 Universal”; Standard (15 MB, 45 klipów) bez ceny, Pro ≥ $9,99 (120+ klipów, FBX i GLB, 41 MB), Source ≥ $14,99 (.blend); przycisk „Name your own price”; kategorie: lokomocja 8 kierunków, jog, sprint, push, crawl, swim, sit, walka i gun, miecz, emotki, death; nazw pojedynczych klipów strona nie podaje, więc „walk”, „idle”, „bow” niepotwierdzone **[pierwotne: quaternius.itch.io/universal-animation-library]**. Czy pobranie wymaga konta: strona nie mówi **[brak]**.
- UAL 2: „Free to use in personal, educational and commercial projects. (CC0 License)”; „130+ Animations”; „60-70% of my pack is completely free”; rig „universal humanoid rig”, „ready for retargeting”; kategorie: walka melee i uzbrojona, parkour, farming, fishing, zombie **[pierwotne: quaternius.com/packs/universalanimationlibrary2.html]**. Zgodność z UBC na tej stronie nie jest zapisana **[brak]**.
- Modular Character Outfits – Fantasy: CC0; 12 strojów z 62 modułowych części, po 3 warianty tekstury; „Works with the Universal Animation Library”; zgodny z głowami UBC; nazw strojów strona nie podaje; **fantasy**, nie zimowe codzienne **[pierwotne: quaternius.com/packs/modularcharacteroutfitsfantasy.html]**.
- Ultimate Modular Men: CC0, 11 postaci po 4 wymienne modele, 24 animacje, FBX/OBJ/Blend/glTF; proporcji i rigu strona nie opisuje **[pierwotne: quaternius.com/packs/ultimatemodularcharacters.html]**.
- Inne paczki z indeksu: Animated Men/Women/Man/Woman, Ultimate Animated Character, RPG Character Pack (prawdopodobnie stylizowane) **[pierwotne: quaternius.com, tylko nazwy i tagi]**.

### 2.2 Mesh2Motion
- „Animations are CC0, ‘Free for personal or commercial use.’”; kod MIT; „Some human animations come from Quaternius”; „Over 170 animations”; typy szkieletów: ptaki, smoki, pająki, kaiju, lisy, konie, ryby, węże, **ludzie**; import GLB, GLTF, DAE, FBX; eksport wielu animacji w jednym GLB lub FBX; trzy ścieżki: przeglądanie animacji, własny model z auto-rigiem, własny już zrigowany model **[pierwotne: mesh2motion.org]**.
- Repo: „licensed under the very permissive MIT license”, assety 3D (modele, rigi, animacje) CC0; własny model: tylko GLB/GLTF, wybór typu szkieletu, ręczne dopasowanie szkieletu do siatki, podgląd, wybór animacji, eksport GLB/GLTF **[pierwotne: github.com/scottpetrovic/mesh2motion-app (README)]**.
- Czy jest konto, jakie klipy (chód, idle, łuk) i jaka jakość skinningu: **[brak]**.

### 2.3 Mixamo
- FAQ (kopia na forum Adobe, post z 2022 o okresie technology preview): „for unlimited commercial or non commercial use”; „the only thing you can't do is distribute the raw character and animation files”; „The only research application Mixamo content can't be used in is training machine-learning models.” **[wtórne: community.adobe.com/t5/mixamo-discussions/mixamo-faq-licensing-royalties-ownership-eula-and-tos/td-p/13234775]**. Oficjalne FAQ helpx.adobe.com/creative-cloud/faq/mixamo-faq.html nie przeczytane (403 w poprzednim badaniu).
- Wtórnie cytowane: „free for anyone with an Adobe ID”, lista dozwolonych zastosowań z pozycją „Create video games” **[wtórne: wyszukiwanie; Unity forum]**.
- Status: strona operacyjna wg agregatora na 2026-07-01, określana przez bloga jako „maintenance mode”, brak komunikatu Adobe **[wtórne: statusfield.com; app.cinevva.com]**. Dodatek Blendera „mixamo-rig” ma wersję z kwietnia 2026 oznaczoną dla Blendera 5.5+ **[wtórne: extensions.blender.org/add-ons/mixamo-rig/versions/ (wynik wyszukiwania)]**.
- MPFB: oficjalna ścieżka istnieje: rig „Mixamo”, operacja „Reduced doll” (usuwa assety, wypieka shapekeys, usuwa helpery), eksport FBX, upload do Mixamo, pobranie animacji „without skin”, import FBX, „Map Mixamo > snap to mixamo”. Strona zaznacza: domyślny rig i basemesh mylą Mixamo, rozpoznanie „with some luck”, animacje najlepiej pobierać dla dokładnie tej wgranej postaci; **MPFB nie dostarcza własnych animacji**; o koncie nie mówi **[pierwotne: static.makehumancommunity.org/mpfb/docs/rigging_posing/mixamo.html]**.
- Opis rigów MPFB: Default, GameEngine („suitable when exporting to external applications”, w Unity „100% compatibility between GameEngine (without breasts) and Mechanim”), CMU MB, Mixamo; żaden nie ma przypisanej biblioteki animacji **[pierwotne: static.makehumancommunity.org/mpfb/docs/characters/rig.html]**.

### 2.4 Reallusion (Character Creator, ActorCore)
- Content EULA, §2.1(B): „the Content is fully integrated, compiled, or packaged into the final application” „such that the underlying Content cannot be accessed, extracted, or used as standalone assets by end-users.”; §1.13: eksport iContent do FBX/OBJ „is restricted” i wymaga licencji; §2.2: „Any use of the Content not expressly permitted under the Standard License requires an Enterprise License.”; §3.2: po końcu One-Year Plan pliki w formacie własnym „will revert to Trial Content”, „will display watermarks in the 3D viewer and cannot be exported.”; §6.5 i §2.1(C)(1): zakaz sprzedaży/dystrybucji treści jako oddzielnych pakietów **[pierwotne: reallusion.com/Content/EULA/EULA.htm]**. Odnośnik do „Reallusion Licensing FAQ for Game Developers” nie był w odczytanym tekście **[brak]**.
- Wniosek dla nas: sprite'y z renderów to nie „rozpakowywalna treść”, więc ryzyko jest małe, ale wymaga potwierdzenia aneksu dla developerów gier **[wniosek]**; zakończenie planu rocznego/365 blokuje eksport plików w formacie własnym, więc **tylko licencja perpetual** wchodzi w grę.
- Cena CC5: spójnie $299 perpetual, subskrypcja CC 365 $29/mies. lub $99/rok, CC5 Deluxe $499, starter pack $329 **[wtórne: cgchannel.com/2026/01/reallusion-switches-up-iclone-and-character-creator-licensing/; digitalproduction.com]**; oficjalna strona nie pokazała ceny **[brak]**. 30-dniowy trial, bezpłatny „Auto Setup for Blender” **[pierwotne: reallusion.com/character-creator/]**. Poza budżetem 100 zł.
- Cena pojedynczych motionów ActorCore: **[brak]**.

### 2.5 Rokoko
- Strona darmowych assetów: można używać „in any animation, VFX, game, 3D project you want, including for commercial use”; pobranie przez formularz (imię, e-mail, rola, firma); 263 klipy; formaty i kategorie niewymienione **[pierwotne: rokoko.com/mocap/free-mocap-assets]**. Pełnych ToS nie czytałem **[brak]**. Dodatek retarget do Blendera istnieje (2020) **[wtórne: blendernation.com/2020/07/22/blender-secrets-free-retargeting-add-on/]**; to retarget, więc „od kopa” nie spełnia.

### 2.6 Human Generator
- Superhive: Commercial $128 „For commercial use. Includes all features and content.”; Personal/Portfolio $68; w tabeli szczegółów licencja „GPL” (niespójne z tierami); Blender 3.6–5.2; zawiera fryzury, ubrania, mimikę, **bibliotekę póz**; animacji nie opisano **[pierwotne: superhivemarket.com/products/humgen3d]**. Dokumentacja/FAQ (help.humgen3d.com) nie przeczytana **[brak]**. Poza budżetem i bez animacji.

### 2.7 MB-Lab
- Repo zarchiwizowane (read-only) 21.07.2024, wersja 1.8.1 „Final”, rozwój przeszedł do Charmorph; Blender ≥ 4.0; „Importing BVH animation files is buggy.”; pliki licencji AGPL-3.0 i GPL-3.0 **[pierwotne: github.com/animate1978/MB-Lab]**. Odpada (martwy, brak animacji).

### 2.8 Auto-Rig Pro (plan B)
- Full $50 z narzędziem Remap, Lite $25 bez Remap (Lite wg wtórnych); zgodność wg FAQ Superhive 2.93–5.1, inna strona podaje 5.2; licencja „GPL” **[wtórne-pierwotne: superhivemarket.com/products/auto-rig-pro/faq (wynik wyszukiwania)]**. Retarget płatny, nie „od kopa”.

### 2.9 Daz 3D
- „An Interactive License is required when using or distributing 3D content from the Daz 3D store.”; „Any 2D artwork you produce and render out is completely owned by you”; sprite ze stosu renderów jest wprost wyłączony z wymogu Interactive License **[pierwotne: daz3d.com/interactive-license-info]**. Dla nas licencyjnie przychylne (sprite to render 2D). Ceny postaci/ubrań/animacji i wspólny rig: **[brak]**; Daz Studio działa poza Blenderem (eksport FBX/Blender Bridge nie sprawdzany) **[brak]**.

### 2.10 VRoid / VRM
- Domyślnie meshe, tekstury i itemy VRoid Studio można sprzedawać/komercyjnie używać, o ile model nie ma specjalnych klauzul; modele innych twórców podlegają ich warunkom; VRM 0.0 ma pole „Non-profit activities only” **[pierwotne: vroid.com/en/studio/guidelines; developer.vroid.com/en/guidelines/conditions_of_use.html (treść z wyszukiwarki)]**. Styl anime i proporcje nie pasują do realistycznego 50-latka **[wniosek]**: odpada, potwierdzone co do stylu, nie badałem szczegółów warunków.

### 2.11 Kenney, Synty, KayKit, 100 Avatars
- Kenney: zasoby na stronach „public domain licensed (CC0)”, atrybucja niewymagana **[pierwotne: kenney.nl/support]**; postacie to chibi/low-poly.
- Synty: licencje „One Time Purchase Licence” i „Standard Subscription Licence”; zakaz m.in. metaverse; szczegółów modyfikacji nie przeczytałem (tylko wtórne) **[pierwotne: syntystore.com/pages/licences-overview (tytuł); wtórne: cinevva.com/guides/game-asset-licenses]**. Stylizowane low-poly.
- KayKit Character Animations: CC0, „Name your own price”; chód i idle są; bow: „shooting, aiming, and reloading”; Rig_Medium 100+ klipów, Rig_Large 25+; postacie kreskówkowe; Source $14,99 **[pierwotne: kaylousberg.itch.io/kaykit-character-animations]**. Dobre źródło *animacji łuku*, ale na własnym rigu KayKit.
- 100 Avatars: repo zaprasza do użycia „on any project” **[pierwotne: github.com/gfodor/100avatars (opis z wyszukiwania)]**; CC0, 73+94 modeli, FBX/glTF i „realistyczne proporcje” wg bloga, ubrań nie potwierdzono **[wtórne: app.cinevva.com/guides/free-rigged-3d-character-models]**.

## 3. Ocena naturalności ruchu

Bez pobrania i obejrzenia klipów nie da się rzetelnie ocenić wymachu rąk i postawy głowy. Co wiadomo:
- UAL Standard: oceniony wcześniej przez użytkownika jako „średni” (ręce prawie się nie ruszają, przygarbiona głowa). To dotyczy też UAL 2, jeśli klipy chodu są wspólne **[wniosek, niepotwierdzone]**.
- Mixamo: ogólnie uznawane za dobrej jakości ruch, ale nie mam źródła pierwotnego ani podglądu; opis na MPFB zaznacza, że animacja pobrana dla innej budowy ciała „can look strange” **[pierwotne: MPFB mixamo doc]**.
- Rokoko, ActorCore, KayKit: brak podglądów w tej sesji **[brak]**.
- Ruch przy 72 px: wymach rąk jest widoczny tylko przy wyraźnym amplitudzie; przed decyzją obejrzeć klip w Blenderze lub Mesh2Motion (podgląd na sampel modelu bez pobierania jest możliwy na stronie, ale tego nie robiłem).

## 4. Rekomendacja

Żadna droga nie jest w pełni „od kopa” dla realistycznego 50-latka w zimowych ubraniach. Dwie najsensowniejsze:

### Droga 1 (0 zł): MPFB + Mesh2Motion
Cel: zachować realistyczną anatomię i ubrania MPFB, a animacje i rig brać z gotowej, wspólnej biblioteki CC0 zamiast własnego retargetu CMU.
1. W MPFB zbudować mężczyznę (już mamy), ubrać w ubrania MakeHuman (kurtka, sweter, spodnie, botki, szalik); **sprawdzić licencję każdej paczki** (CC0 / CC-BY) przed użyciem.
2. Wyeksportować do GLB z rigiem GameEngine (bez piersi), w T-/A-pozie, siatka ubrań jako osobne obiekty lub połączona.
3. Wgrać do mesh2motion.org, wybrać szkielet „Human”, dopasować kości do siatki, sprawdzić skinning na kurtce i szaliku.
4. Przejrzeć animacje (chód, idle, walka/broń), wyeksportować wybrane klipy jako GLB (CC0).
5. Zaimportować do Blendera 5.2, renderować wg 74 (toon + kontur, 72 px).
Ryzyka: jakość auto-skinningu przy ubraniach i szaliku; zgodność nazw kości z animacjami; czy w bibliotece Human jest chód o dobrym wymachu rąk i klip łuku **[wszystko niepotwierdzone]**.

### Droga 2 (0–40 zł): Quaternius UBC „Regular” + Modular Outfits + UAL
1. Użyć UBC w proporcjach „Regular” (męski) zamiast „Superhero”; ocenić w Blenderze, czy czyta się jako dorosły przy 72 px.
2. Ubrania: Modular Character Outfits (fantasy, 12 strojów) jako baza; zimowe elementy (szalik, sweter) doprojektować przez zmianę tekstur 3 wariantów lub przez ubrania MPFB przeskinowane na rig Quaternius (to już ręczna praca, **poza „od kopa”**).
3. Animacje: UAL Standard (0) lub Pro $9,99 (~40 zł, 120+ klipów, w tym zapewne walka/broń); dla łuku dodatkowo KayKit (CC0), ale to inny rig, więc wymaga retargetu.
4. Render jak w 74.
Ryzyka: stylizacja proporcji „Regular” (niezbadana), brak zimowych ubrań, klip łuku niepotwierdzony, ruch UAL „średni” według dotychczasowego testu.

### Plan B (płatny): Mixamo + Auto-Rig Pro
Ścieżka oficjalna dla MPFB istnieje (sekcja 2.3), ale wymaga konta Adobe ID (decyzja człowieka) i obchodzi się z „reduced doll”; Auto-Rig Pro Full $50 (~200 zł, powyżej limitu) ułatwia Remap. Character Creator 5 ($299) to jedyna pozycja z prawdziwym „wszystko na jednym rigu” z ubraniami, ale ponad trzykrotnie przekracza budżet i ma EULA z klauzulą pakowania.

## 5. Lista niepotwierdzonych

- Czy UBC „Regular” przy 72 px czyta się jako dorosły 50-latek, a nie stylizowany model; nie oglądałem podglądów.
- Nazwy klipów UAL 1/2, KayKit i Mesh2Motion (chód, idle, wyciąganie łuku/broni); czy w Mesh2Motion jest łuk/draw.
- Jakość auto-skinningu Mesh2Motion na ubranym modelu MPFB i czy eksport GLB z MPFB (GameEngine) jest przez niego akceptowany; czy wymaga konta.
- Zgodność UAL 2 z UBC (strona UAL 2 tego nie mówi); czy pobranie z itch.io wymaga konta.
- Licencje poszczególnych paczek ubrań MakeHuman/MPFB.
- Oficjalny tekst FAQ Mixamo (helpx), obecny status serwisu, czy ubrania Fuse są dostępne.
- Licencja i FAQ Human Generator (sprzeczne „GPL” vs „Commercial”); czy wolno używać renderów w grze komercyjnej.
- Reallusion: „Licensing FAQ for Game Developers”, aktualna cena CC5, ceny motionów ActorCore, kompatybilność eksportu z Blenderem 5.2.
- Rokoko: pełne ToS, formaty (BVH/FBX), lista klipów.
- Daz: ceny, rig wspólny dla ubrań/animacji, jakość eksportu do Blendera.
- Synty: pełny tekst EULA o modyfikacjach.
- Naturalność ruchu wszystkich kandydatów (wymaga podglądu klipów).
