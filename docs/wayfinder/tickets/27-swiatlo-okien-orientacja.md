---
id: 27
title: Światło okien ze wszystkich ścian i orientacja mapy
labels: [wayfinder:prototype]
status: closed
assignee:
blocked_by: [31]
---

## Question

Którą stronę świata dajemy na górę ekranu i jak wygląda światło okna w każdej ścianie (tylnej z licem, dolnej i bocznych bez rysowanego okna), w dzień i w nocy? Na Poligonie Dom (`style-lab/dom.bat`) człowiek przełącza w F1 „Góra ekranu” (północ / wschód / południe jak w game1 / zachód) i ocenia, czy smugi i plamy okien czytają się jako okna i czy ruch słońca przez dzień wygląda naturalnie. Decyzja człowieka: orientacja mapy i Przepis światła okien dla wszystkich ścian.

**Uwagi człowieka (2026-11-09) z Poligonu Dom:**
- Klimat okien robi ich rama: smuga z każdego okna ma być podzielona na skrzydła (jak u okien tylnych), nie jedna.
- Wersja z `game1-proto` była lepsza: smugi zwężały się do okna, a nocą był ładny rzut okna na podłogę. Obecna plama z krzyżem (przeniesiona do `SideWindowLight`) jest zła. Punkt wyjścia: `C:/Users/bartl/Desktop/repo/game1-proto/prototype/lighting/kit/window_light.gd` (`_cookie`, `_shear`, `_street`, `_update_beams`, `_beam`).
- Smugi z okien bocznych były za mocne. Nocą poduszki nieba z niewidocznych okien dają jasne, chłodne plamy, do sprawdzenia, czy nie czytają się jak lampy.
- Przy północy na górze słońce wpada oknami dolnymi i bocznymi; smugi z dolnych okien wyglądały marnie i nie zdradzały okna.

**Zgranie wnętrza z ulicą (człowiek, 2026-11-09):** w tym tickecie. Światło w środku ma się zgadzać ze światłem na zewnątrz: kierunek słońca (fasady w słońcu lub w cieniu, cienie budynków tylko jako wariant, bo we wnętrzach cieni nie ma), okna widziane z ulicy (dzień, noc), przejście przez drzwi (ADR 0007 z game1: stała ekspozycja na przestrzeń, bez adaptacji oka). Pytanie człowieka: czy smugi słońca wpadające do okna da się jakoś pokazać na zewnątrz, czy tylko kolor.

**Stan w style-lab (punkt startu, nie decyzja):** `LightingDirector.top_azimuth_deg` obraca słońce (ściany opisane względem ekranu: tylna 180, dolna 0, lewa 90, prawa 270); `WindowLight` ma bramkę słońca (`_facing`), więc nie świeci, gdy słońce jest za ścianą; `SideWindowLight` ma `panes`, `beam_k`, `patch`, `patch_k`. Research: 47 (wstęga i poduszka, wzorzec A/B), 22c §1.3 i §6.1 (rzut plamy), 53 (sygnały okna, T2 krata).

Odcina od ticketu „Światło w Poligonach” sprawę okien i orientacji; tamten zostaje dla ulicy, latarni i nocy w mieście i poza nim.

## Stan (zaparkowane 2026-11-09)

Zaparkowane do prototypu [Dynamiczne słońce okien na Poligonie Dom: mapa światła i makieta 3D](31-dynamiczne-slonce-okien-prototyp.md): orientację sprawdzimy jeszcze w wariancie z dynamicznym światłem. Prototyp ręcznego światła działa (`style-lab/dom.bat`, drzwiami na ulicę; README style-lab, sekcja „Prototyp światła okien i orientacji mapy”; zrzuty `style-lab/shots/t27/`).

Ustalone z człowiekiem w tej sesji (nie zamknięte):
- **Orientacje tylko dwie:** północ albo południe na górze (wschód i zachód odpadły). Człowiek skłania się ku południu, nie jest pewien. Dwaj krytycy (artysta i game designer, subagenci) za południem: wnętrza to ok. 60–70% czasu i tylko okno tylne daje czytelną smugę; okna boczne jako zegar dnia (rano wschodnie, wieczorem zachodnie).
- **Geometria:** smuga z okna dolnego jest widziana prawie od czoła (szyba i miejsce lądowania w tym samym miejscu ekranu), więc przy północy we wnętrzach słońce pokazuje głównie plama.
- **Smuga a plama:** z plamą na podłodze smuga zwęża się i kończy na niej; bez plamy rozszerza się i wygasa (ok. 4,5 m). Plama w dzień: przy północy tylko z okien dolnych, przy południu tylko z tylnych; okna boczne nigdy, tylko smugi przy wschodzie i zachodzie. Plama miękka, cztery szyby jak w game1-proto.
- **Noc:** rzut okna ostry jak w game1-proto (ten sam układ szyb, inne miejsce i światło), sodowy z okien dolnych od ulicy; boczne nic; z tylnych chłodny tylko jako opcja.
- **Ulica:** bez cieni budynków (gryzą się z wnętrzem); przy północy słońce na fasadach; błysk w ok. co trzecim oknie; poświata zapalonych okien na śniegu; kompensacje fasad w cieniu (ciepła krawędź śniegu na dachach i parapetach, lampy w części okien w dzień); przejście przez drzwi z wygaszeniem (ADR 0007 z game1).

Do decyzji człowieka po prototypie dynamicznym: orientacja, Przepis światła okien (czy plama w dzień, które dodatki na ulicy).

## Resolution

Rozstrzygnięte przy [Słońce okien liczone mapą światła na makiecie pokoju](31-dynamiczne-slonce-okien-prototyp.md) (decyzje człowieka 2026-11-09): **południe na górze ekranu**; światło okien wszystkich ścian i drzwi liczy mapa z geometrii (`SunMap`), bez strojenia okien pojedynczo; okna tylne: plama z ramą i skrzydłami + smuga zwężająca się do plamy; okna boczne: tylko wstęgi z mapy od linii ściany, bez plamy; okna dolne i boczne oraz drzwi: poświata nieba z geometrii (jedna reguła, jaśniej od strony słońca); noc: plama tylko z okien górnych w kolorze tego, co na zewnątrz, ulica oświetlona równo. Szczegóły i konfiguracja: ticket 31 i README style-lab.
