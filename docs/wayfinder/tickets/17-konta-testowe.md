---
id: 17
title: Konta testowe: Pixellab trial i Retro Diffusion
labels: [wayfinder:task]
status: closed
assignee: claude
blocked_by: []
---

## Question

HITL. Człowiek zatwierdza i zakłada konta testowe wg `docs/research/61-narzedzia-limity-koszty.md`: (1) nowe konto Pixellab (bez karty, ok. 40 generacji) — sprawdzić realny limit na postać z animacją i czy API/MCP działa na tym planie; (2) Retro Diffusion — czy darmowy start wymaga karty, odczytać regulamin (prawa do wyników, UE); (3) opcjonalnie pisemne pytanie do supportu Pixellab o prawa do wyników po anulowaniu subskrypcji. Scenario tylko do ewaluacji (darmowy plan zabrania użycia w grze), Aseprite/rozszerzenie RD — decyzja, czy kupować. Wynik: gdzie są dane dostępowe (nie w repo), limity triali, odpowiedzi regulaminowe. Generacji triala nie zużywać przed prototypami Rzutu i Przepisu postaci.

## Wyniki w toku (2026-11-08)

- Konta założone przez człowieka (Pixellab trial, Retro Diffusion). Klucze: `C:\Users\bartl\.secrets\game2\keys.env` (`PIXELLAB_API_KEY`, `RD_API_KEY`), poza repo. Pytanie do supportu Pixellab: człowiek załatwia poza sesją.
- **Pixellab, `GET /v2/balance`** (bez zużycia): `subscription: {status: trial, generations: 40, total: 40}`, `credits: {usd: 0}`. API działa na trialu i liczy w generacjach z puli planu, nie w USD; osobne saldo USD istnieje obok (do potwierdzenia przy planie płatnym).
- **Koszty Pixellab wg OpenAPI** (`api.pixellab.ai/v2/openapi.json`): postać v3 8 kierunków od zera = 1 + ceil(s²·8/65536) gen. (64 px: 2, 96–128 px: 3); `create-character-with-8-directions` standard 1 gen., pro 10–25; animacja szablonowa 1 gen./kierunek (≤ ~100 px); animacja v3/pixminimax: jedno zadanie na kierunek (koszt nie podany); pro: 10–25 gen./kierunek. Szacunek: postać 64 px z chodem szablonowym w 8 kierunkach ≈ 10 gen.; trial (40) starczy na ~2–3 próby postaci.
- **Retro Diffusion, `GET /v2/inferences/credits`:** 50 darmowych jednostek (bank odnawialny, najbliższe odnowienie 2026-11-11), saldo USD 0, `plans_enabled: true` (RD ma już plany, cen nie widać w API). **Darmowe jednostki nie działają przez API:** `check_cost` zwraca `would_use: blocked`, `remaining_credits: 0`; API płaci tylko saldem USD (poza zasadą mapy). Trial RD = interfejs webowy.
- **Ceny RD API (`check_cost`, darmowe):** RD Fast 64 px 0,03 USD; RD Plus 64 px 0,06; RD Pro 64 px 0,18; chód w 4 kierunkach 48 px 0,07; turnaround postaci 128 px (Plus) 0,06. Rotacja 8 kierunków i chód „advanced” wymagają obrazu wejściowego.
- **ComfyUI lokalnie** (dodatkowo): Comfy Desktop 0.43.1 działa, API pod `http://127.0.0.1:8188` odpowiada (Claude może nim sterować skryptem); CUDA, RTX 4060 Laptop 8 GB VRAM (7,4 GB wolne), 32 GB RAM, PyTorch 2.12.1+cu130. **Brak zainstalowanych checkpointów** (lista modeli pusta).

## Resolution

Zrobione (2026-11-08). Konta założył człowiek, klucze w `C:\Users\bartl\.secrets\game2\keys.env` (poza repo). Pytanie do supportu Pixellab człowiek załatwia poza sesją. Scenario, Aseprite i rozszerzenie RD: nie teraz. Żadnej generacji nie zużyto. Od teraz każda generacja na zewnętrznej platformie wymaga zgody człowieka (Notes mapy). Poprawia `docs/research/61-*` w punktach niżej.

**Pixellab** (ceny z `api.pixellab.ai/get-subscriptions`, limity z kodu strony, saldo z API):
- Trial: 40 generacji, API działa i liczy z puli planu (`subscription.generations`), osobne saldo USD = 0.
- Plany miesięczne: Apprentice (Tier 1) 12 USD / 2000 obrazów, **Artisan (Tier 2) 24 USD / 5000**, Architect (Tier 3) 50 USD / 10 000; rocznie 99 / 220 / 500 USD. Strona: „Some tools use more than one image from your monthly limit”. Komercyjnie na każdym planie.
- Koszt postaci (OpenAPI): v3 8 kierunków od zera 2–3 gen. (64–128 px); animacja szablonowa 1 gen./kierunek; tryby pro 10–25 gen. Postać 64 px + chód 8 kierunków ≈ 10 gen.; Artisan ≈ 500 takich postaci bez prób.
- Limity rozmiaru zależą od tieru (np. płótno 320×320 w Tier 1, 400×400 w Tier 2+); część narzędzi wymaga Tier 1 lub 2.

**Retro Diffusion** (regulamin z 2026-09-28 odczytany z kodu strony `retrodiffusion.ai/terms`; plany z `api.retrodiffusion.ai/plans`):
- Karta niepotrzebna. Darmowe 50 jednostek działa tylko w przeglądarce (przez API `would_use: blocked`); wyniki z darmowego użycia RD może pokazywać publicznie.
- **Wyniki należą do generującego** („we assign to you any rights we have in them”), z każdej drogi (web, API, MCP, plan, saldo, darmowe), bez zapisu o utracie po końcu planu; bez ograniczeń terytorialnych; prawo New Hampshire, arbitraż. RD może trenować na naszych wynikach (nie na wejściach); **my nie możemy trenować na wynikach** (LoRA na wynikach RD odpada, jak w Pixellab).
- Automatyzacja dozwolona tylko przez oficjalne API/MCP. Jedna osoba = jedno konto.
- **Nowe: plany subskrypcyjne**, działają też przez API (najpierw plan, potem saldo): Starter 10 USD (≈800 obrazów RD Fast lub 112 RD Pro), **Creator 25 USD (≈2385 Fast / 334 Pro)**, Studio 60 USD. Niewykorzystane nie przechodzą. Ceny pojedyncze: Fast 0,03, Plus 0,06, Pro 0,18 USD/obraz; chód 4 kierunki 48 px 0,07 USD.

**ComfyUI lokalnie:** działa, API `127.0.0.1:8188`, RTX 4060 8 GB, 32 GB RAM; brak checkpointów.

Wniosek dla subskrypcji: w budżecie ~100 zł mieszczą się teraz dwa plany z API: Pixellab Artisan (24 USD) i RD Creator (25 USD). Wybór po prototypach Przepisu postaci.
