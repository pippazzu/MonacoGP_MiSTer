# Pro sheet A — the two signals from sheet N

Date: 2026-11-05. Sega 420-0525, Pro Monaco GP, sheet A (PDF page 8),
board 96822-P, D-1/5, "スタート, タイマー, コントロール" (start, timer, control).

**Scope:** only where `BONUS SOUND (N)` and `/BONUS CP (N)` go on A, and the
gates they join. The rest of Pro sheet A has not been compared with the
original. No HDL was changed. MAME, the remake, footage and gameplay
descriptions were not used.

## Result

1. **BONUS SOUND joins EX. CP.** An added OR gate combines the original
   extended-play tone with BONUS SOUND, and the result leaves on pad A29,
   `EX. CP (S)`, to the sound board. The bonus therefore uses the sound
   board's existing extended-play input: no new sound circuit is needed for it.
2. **/BONUS CP joins /COIN IN for the sound board.** On the original,
   pad A28 `/COIN IN (S)` is /COIN IN through a 7407 buffer. On the Pro board,
   a NAND combines /COIN IN with /BONUS CP and an inverting buffer drives A28.
   So A28 is low while a coin is in **or** while BONUS CP is active. The
   sound board's own wiring (traced on the original: its output stage is
   muted unless COIN IN or the alarm is active) then lets sound through
   during each BONUS CP pulse, even after the game has ended. This is a
   reading of the logic, not tested.

Neither signal reaches the game logic on sheet A: both only feed sound-board
outputs.

## Evidence

Render: PyMuPDF at scale 1, page 8 (index 7), 10184 x 6617 pixels, upright,
origin top left. Boxes are (left, top, right, bottom) on that render. The
crops are not saved in the repository; they can be made again from these
boxes.

| Crop | Box | Shows |
|---|---|---|
| A-excp | (7600, 1150, 9500, 2000) | IC60, IC53, IC59, buffer 46, pad A29, BONUS SOUND arrow |
| A-bonuscp-col | (5300, 2300, 6300, 6100) | /BONUS CP arrow at the bottom and its vertical up to y≈4325 |
| A-cp-turn | (5500, 4150, 7300, 4500) | The turn at (5760, 4325), IC35 9/10 -> 8, buffer to pad A28 |
| A-cp-route | (5700, 2300, 8300, 4500) | /COIN IN rows, arrows (B), (G), (S) and pad A28 |

Source: `C:/Users/kakyo/Downloads/promonacogp420-0525_1.pdf`, SHA-256
`9473d6dd84418129f389e7c5becc0f6f7d105611e1d508ff60bbc062a27432f2`.

## Wire and gate rows

| Row | Reading | Evidence | Confidence |
|---|---|---|---|
| A01 | IC60 (printed 123/2) Q 13 -> IC53 third input | A-excp | Clear. IC60 is the extended-play one-shot: A 1 bubbled, B 2 tied to Vcc, CL 3 tied to B, C 100 µ and R17 47K on 14/15 |
| A02 | IC53, AND body, inputs 1 and 2 from the two verticals arriving from `Vs/16 (H)` and `V2 (E)` (pad C6), third input from A01, output 12 | A-excp; overview of the top right corner | Clear function. The third input's numeral reads like 12, the same as the output; a 7411 section 1, 2, 13 -> 12 gives 13. Recorded as uncertain, not corrected |
| A03 | IC59, plain OR body (no bubbles), input 2 = IC53.12, input 1 = `BONUS SOUND (N)`, output 3 | A-excp | Clear. Matches a 7432 section 1, 2 -> 3 |
| A04 | IC59.3 -> buffer 46 (1 -> 2, no bubble) -> pad A29 `EX. CP (S)` | A-excp | Clear |
| A05 | `/BONUS CP (N)` arrow at the bottom (x≈5760) rises without junction dots to y≈4325, then runs right to IC35 input 10 | A-bonuscp-col, A-cp-turn | Clear. Crossings on the way have no dots |
| A06 | IC35 input 9 = the /COIN IN row (dot at about (6520, 4175)); the same row ends at the arrow `/COIN IN (G)`, next to pad BD `/COIN IN (B)` | A-cp-turn, A-cp-route | Clear |
| A07 | IC35: OR body with bubbles on both inputs, no output bubble = NAND. Output 8 | A-cp-turn | Clear |
| A08 | IC35.8 -> buffer (input 13, output bubble at 12) -> pad A28 `/COIN IN (S)` | A-cp-turn | Clear connection and inversion. Package caption reads like "74" or "34": uncertain |

## Logic

With levels as drawn (`/` is the overbar):

- `EX. CP = (V2 AND Vs/16 AND Q60) OR BONUS SOUND`
- `A28 = NOT(NAND(/COIN IN, /BONUS CP)) = /COIN IN AND /BONUS CP`,
  so A28 is low when COIN IN is high or /BONUS CP is low.

From the sheet N trace: `BONUS SOUND = (V4 AND BONUS CP) OR (IC100 Q13 AND
IC132 QC AND IC132 QD AND V2)`, and BONUS CP is the second IC107 one-shot
(22 µ, 47K), fired once per bonus earned and once per bonus paid out.

## Comparison with the original sheet A

Original references: `docs/trace/SHEET_A_TRACE.md` in the Monaco repository
(rows for IC85, IC31 and pads A28/A29).

| Function | Original | Pro |
|---|---|---|
| EX. CP | IC85 (7411) V2, Vs/16, IC49 Q -> buffer "29" -> A29 | Same three-input AND (IC53, one-shot IC60), then an added OR with BONUS SOUND (IC59), then buffer 46 -> A29 |
| /COIN IN to the sound board | IC37 /Q -> IC31 (7407) 11 -> 10 -> A28 | /COIN IN NAND /BONUS CP (IC35), inverting buffer -> A28 |

IC numbers differ between the boards and were not used to match parts.

## Not established

- **What the sound board does during payout.** The sound board's response to
  A28 low after a game (output stage un-muted, and possibly MY CAR SOUND ON,
  which the original's D-3 logic also gates with /COIN IN) comes from the
  original sound board's trace. The Pro manual has no sound sheets. Whether
  the engine sound is heard during each BONUS CP pulse is not settled.
- The IC53 third input numeral and the A28 buffer's package caption (A02, A08).
- Everything else on Pro sheet A: no general comparison was made.
