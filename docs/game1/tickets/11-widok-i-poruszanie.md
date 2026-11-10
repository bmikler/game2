> Kopia z game1 (`repo/game1/docs/wayfinder/tickets/11-widok-i-poruszanie.md`, stan 2026-11-03). Ścieżki, numery notatek i ticketów odnoszą się do repo game1 `C:/Users/bartl/Desktop/repo/game1`. Ustalenia game1 nie są decyzjami dla game2. Indeks: `docs/grafika-indeks.md`.

---
id: 11
title: Widok kamery, poruszanie i skala grafiki
labels: [wayfinder:grilling]
status: closed
assignee: bmikler
blocked_by: [02, 06]
---

## Question

Jaki widok (top-down, side-view, izometria, 2.5D), jaki sposób poruszania (point&click, WASD, hybryda) i jaka rozdzielczość bazowa i skala pixel artu?

## Resolution

- **Widok:** 3/4 z góry, widać całą postać, swobodny ruch we wszystkich kierunkach (sposób poruszania jak w Stardew Valley). Grafika bardziej szczegółowa i realistyczna niż w Stardew i Graveyard Keeper, bliżej detalu Replaced. Widok boczny 2.5D odrzucony, bo ogranicza immersję i wrażenie eksploracji żywego świata. Ten sam widok i ta sama skala we wnętrzach i plenerach.
- **Poruszanie:** WASD w 8 kierunkach, interakcja z obiektem w zasięgu (klawisz lub klik). Kliknięcie z dojściem można dodać później. Sprite'y w 4 kierunkach (lewo jako lustro prawa, gdy strój symetryczny).
- **Skala:** baza 640×360, skalowanie całkowite (stretch `viewport`, scale `integer`), UI na osobnej warstwie w natywnej rozdzielczości. Kafel 32 px (1 m), postać ok. 60 px wzrostu, kadr ok. 20×11 m.
- **Oświetlenie (tylko klimat, nie mechanika), drabinka „klimat za wysiłek”:**
  1. start: światła 2D bez dynamicznych cieni, ciemny ambient, color grading, bloom, winieta, ziarno, mgła ze sprite'ów, śnieg, blob shadows, normal mapy tylko na postaciach; latarka i reflektory jako stożki bez cieni;
  2. occludery tylko na meblach we wnętrzach;
  3. upgrade tylko gdy prototyp rozczaruje: sprite'y w scenie 3D z prawdziwymi cieniami (alpha scissor, kamera ortogonalna w pełnej rozdzielczości).
  Zastępuje wstępną rekomendację z ticketu Pixel art z dynamicznym oświetleniem („2D + niski viewport” bez zastrzeżeń dla 3/4).
- **Wejście do ticketu Model testów umiejętności:** Test okazjonalny może pojawić się bez podchodzenia do obiektu; co go wyzwala (strefa, widoczność, pora, rutyna NPC), rozstrzyga tamten ticket.

Szczegóły: docs/research/11b-widok-top-down.md. ADR: docs/adr/0002-widok-3-4-i-drabinka-swiatla.md.
