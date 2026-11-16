---
id: 12
title: Warianty strojenia
labels: [ready-for-agent]
status: open
assignee:
blocked_by: [11, 19]
---

Przesunięty za Skwer (19), jak w kolejności specyfikacji (człowiek, 2026-11-16): to mechanizm do strojenia na
końcu, a do tego czasu tickety mają własne przełączniki w F1.

## Co zbudować

Strojenie wyłącznie Wariantami krytyków: katalog z kopiami dowolnych plików strojenia (brakujący = bazowy) i opisem w jednym zdaniu. Przełącznik Wariantów w panelu silnika, nowe Warianty wczytywane bez restartu. `--set=<zasób>.<pole>=<wartość>` po nazwie i `--wariant=nazwa`.

## Kryteria akceptacji

- [ ] Nakładanie Wariantu na bazę (testy).
- [ ] Przełączenie na żywo przelicza tylko to, co trzeba.
- [ ] Nowy katalog Wariantu widoczny bez restartu.
- [ ] `--set=` i `--wariant=` (testy parsowania); Wariant w opisie zrzutu.
- [ ] Bez suwaków i zapisu z F1.
- [ ] Dwa Warianty testowe, usuwane po „ok”.

## Jak sprawdzić

Uliczka o 16:30: przełączaj bazowy / testowy A / testowy B, obraz zmienia się od razu. Skopiuj katalog Wariantu przy uruchomionej grze: pojawia się w F1.

## Wzorce wyglądu dla krytyków

Inspiracje człowieka (pixel art, GIF-y): `C:\Users\bartl\Desktop\pixel art\` (poza repo; człowiek może dorzucać obrazy, więc
przy strojeniu przejrzeć folder na nowo). Krytycy biorą je za wzorzec przy Wariantach.

Wnioski z pierwszego przeglądu (14 obrazów, 2026-11-16, ticket 11):
- Prawie bez ostrego słońca: zmierzch, noc, pochmurno. Płaskie, chłodne niebo; ciepłe plamy lamp i okien.
- Schodki (poziomy) głównie w plamach lamp: 3–4 płaskie pasy z brzegiem poszarpanym fakturą (śnieg, ślady), nie
  geometryczne elipsy. Pomysł na Wariant przy lampach (ticket 13): „organiczna” granica poziomu sterowana szumem świata
  lub fakturą podłoża.
- Cień od nieba to wąski ciemny pas przy przedmiocie (pod autem, u stóp ściany), dalej nic: zgodne z gładkim niebem
  (`sky_style` B, wybór człowieka w ticketcie 11).
- Bryły cieniowane płaszczyznami (góra jaśniej, bok ciemniej, w obrębie płaszczyzny prawie płasko).
- Cień różni się barwą (chłodny wobec ciepłego światła), nie jest czarny: kolory nieba i ambientu w krzywych doby.
- Porównanie A′ na niebie (A) z gładkim (B) powtórzyć na teksturowanej ziemi: plamy A kłuły na gładkiej szarej ulicy.
