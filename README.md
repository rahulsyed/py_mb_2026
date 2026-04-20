# Pickle Yard Moneyball Throwdown

Standalone, zero-backend tournament site for the Pickle Yard (Mauldin, SC) Moneyball Throwdown, **May 16, 2026 · 1–5 PM**.

## Files

| File | Purpose |
|---|---|
| `index.html` | Public landing + registration + password-gated admin portal |
| `tournament.html` | Live tournament engine (pools, scores, standings, courts, bracket) |
| `data/teams.json` | Source-of-truth metadata: tournament config, test teams, RR schedule, court assignments, registration schema |
| `README.md` | This file |

## Branding

Colors pulled straight from the Pickle Yard logo SVG on thepickleyard.com:

| Token | Hex | Use |
|---|---|---|
| `--py-green` | `#009F67` | Monogram P · primary |
| `--py-teal` | `#004A5E` | Monogram Y · secondary |
| `--py-teal-deep` | `#005763` | Site chrome |
| `--py-ink` | `#141827` | Near-black navy background |
| `--py-accent` | `#F3BF45` | Warm yellow highlight |

The PY monogram SVG is embedded inline on both pages.

## Tournament Structure

- **12 teams** → Pool A (6), Pool B (6)
- **Pool play:** single round robin, 5 games per team (15 matches / pool, 30 total).
  Circle-method balanced schedule, 3 parallel matches per round = all 6 courts used every round.
- **Standings order:** Wins → Point differential → Points-for
- **Top 3 each pool advance** (6 playoff teams)
- **Playoffs:** single-elimination, 6 matches
  - QF1: A2 vs B3 (Court 1)
  - QF2: B2 vs A3 (Court 2)
  - SF1: A1 vs QF1 winner (Court 1)
  - SF2: B1 vs QF2 winner (Court 2)
  - 3rd: SF1 loser vs SF2 loser (Court 2)
  - F: SF1 winner vs SF2 winner (Court 1 — center / showcase)
- **Byes:** A1 and B1 skip QF and enter at SF.

## Court Plan (6 Courts)

| Round | Court 1 | Court 2 | Court 3 | Court 4 | Court 5 | Court 6 |
|---|---|---|---|---|---|---|
| Pool R1–R5 | Pool A M1 | Pool A M2 | Pool A M3 | Pool B M1 | Pool B M2 | Pool B M3 |
| QF | QF1 | QF2 | — | — | — | — |
| SF | SF1 | SF2 | — | — | — | — |
| Finals | **Final 🏆** | 3rd-place | — | — | — | — |

## Prize Pool

**$1,000** · 1st $500 · 2nd $300 · 3rd $200

## Registration (Fully Local — No Backend)

Registration stores in browser `localStorage` under key `py-registrations`. Nothing leaves the browser. No Google Apps Script, no Firebase, no API.

Captured fields per team:
`teamName`, `p1Name/Dupr/Email/Phone`, `p2Name/Dupr/Email/Phone`, `shirts`, `notes`, `pool`, `paid`, `registeredAt`, `id`.

## Admin Portal

Open `index.html`, click **🔒 Admin** in the nav, enter PIN.

- **Default PIN: `1987`** — change the `ADMIN_PIN` constant in the `<script>` block for production.
- Unlock persists for the browser session (auto-locks on close).
- Live stats (total / remaining / paid / unpaid / per-pool)
- Edit pool, toggle paid, delete rows
- Export CSV or JSON (downloads as file)
- Seed 12 test teams for demos
- Clear all registrations (with confirm)

## Tournament Engine (`tournament.html`)

1. Open `tournament.html`.
2. Admin tab → **Sync teams from Registrations** (pulls from `py-registrations`).
3. Enter scores in the **Pool Play** tab — standings auto-update, bracket auto-wires.
4. Use **Courts** tab for per-court timeline during the event.
5. **Simulate random pool results** button lets you preview the bracket end-to-end.

State persists in `localStorage` (`py-tournament-state`), so browser refreshes don't lose data.

## Validation

Admin tab of `tournament.html` has a built-in validator that checks:
- 6 teams per pool
- 15 unique pairings per pool
- Each team plays exactly 5 pool games
- 6 playoff matches (2 QF + 2 SF + 3P + F)

Schedule externally verified: 5 rounds × 3 matches × 2 pools = 30 pool matches, every pair plays once, every team plays 5 games.

## Test Data Flow (End-to-End)

1. Open `index.html` → **🔒 Admin** tab → PIN `1987` → **Seed 12 test teams**.
2. Teams appear in the **Teams** tab (public), split A/B.
3. Open `tournament.html` → **Admin** → **Sync teams from Registrations**.
4. Click **🎲 Simulate random pool results** → fills all 30 pool scores.
5. Flip to **Standings** (top 3 highlighted + byes marked) → **Courts** (per-court timeline) → **Playoff Bracket** (auto-wires A2/B3, B2/A3, then SF with A1/B1 byes).
6. Enter QF/SF/F scores — Final auto-computes.

## Next Steps (Phase 2)

- **Firebase Realtime DB sync** so multiple devices can enter scores concurrently on match day.
- **Payment integration** (Venmo deeplink / Stripe).
- **Bracket PDF export** for on-site posting.
- **Head-to-head tiebreaker UI** for pool-play W-L ties.
