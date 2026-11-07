# Bonus lamp PROMs PR-01 and PR-02: reconstruction

**This is a reconstruction, not original data.** No dumps of PR-01 (IC55) or
PR-02 (IC54) are known. The wiring below is read from the schematic; the
contents in `lamp-proms.txt` are inferred from that wiring and from the
cabinet panel as described in `../docs/OBSERVATIONS.md`, under the
assumptions listed here. Issue #69, 6 November 2026.

## Sources

- `pro/schematics/promonacogp420-0525_1.pdf`: page 18 (sheet I), page 16
  (sheet E), page 8 (sheet A), glanced at page 7 (cabinet wiring). Rendered
  with PyMuPDF at scale 1 (page 18: 10184 × 6617; the scan's native
  resolution, larger zooms only interpolate). Boxes are (left, top, right,
  bottom) on that render. Crops are not stored.
- `pro/docs/trace/SHEET_I_TRACE.md` ("Bonus lamps"),
  `pro/docs/trace/SHEET_N_TRACE.md` (IC133 / IC126, interface),
  `pro/docs/SHEET_N_LOGIC.md`, `pro/docs/trace/SHEET_K_TRACE.md` (V2').
- Cabinet panel: `pro/docs/OBSERVATIONS.md`, "Bonus lamp panel" (Aldo's
  video screenshot, not stored).
- Datasheet: National Semiconductor, *DM54/74S188 (32 × 8) 256-Bit TTL
  PROM* (Jameco copy, https://www.rigpix.com/components/74s188.pdf). DIP
  pinout Q0–Q6 = pins 1–7, GND 8, Q7 = 9, A0–A4 = 10–14, /G = 15, Vcc 16.
  Open-collector outputs; "shipped from the factory with lows in all
  locations"; VOL ≤ 0.45 V at IOL = 16 mA; output voltage abs. max 5.5 V.
  "3188" is not a part number I could find; the drawn pins match this
  family (74S188, Signetics 82S23 open-collector / 82S123 three-state), so it
  is taken as a 74S188-type open-collector part. That is an inference.

Not used: MAME, remakes, other cores, footage beyond the panel description.

## 1. The lamp drive, re-read (page 18)

| Item | Reading | Box | Confidence |
|---|---|---|---|
| Address | BONUS A, B, C, D → pin 10, 11, 12, 13 of both PROMs; pin 14 of both ← pad HH `V2 (E)`, RA2 1 kΩ pull-up | (2700, 150, 4300, 1300); V2 row (1350, 650, 4100, 1200) | clear |
| Count bit order | BONUS A = IC133 pin 4, the 74157 output of 132.14 (QA) / 140.3 (QA): BONUS A is the LSB, so address = 16·V2 + count | N trace, IC133 | clear |
| PR-01 outputs | pins 1, 2, 3, 4, 5, 6, 7, 9 → R60, R59, R58, R57, R56, R55, R54, R53 (220 Ω) → G37, 36, 35, 34, 33, 32, 31, 30 → lamp-unit pins 3, 4, 5, 6, 7, 8, 9, 10 | (4100, 250, 5300, 1300) | pins and order clear; G30 probable (numeral overwritten) |
| PR-02 outputs | pins 1–7 → R52 … R46 → G l, m, n, p, r, s, t → lamp-unit pins 11–17 | same | order clear; letters p, r, s, t probable |
| PR-02 pin 9 (O8) | Runs below the lamp unit to a vertical at x ≈ 5915 with dots at R45 and at inverter 37's input 5; top end goes to R43 1 kΩ to LAMP V | (5150, 300, 6050, 1350) | clear |
| Commons | O8 node → R45 330 Ω → base TR16 (A684, PNP, emitter LAMP V) → collector → G26. O8 node → inverter 37 (5 → 6) → R41 330 Ω → base TR13 (A684) → Gd | same | clear |
| /G (pin 15) | Both to `LAMP RET.` arrows | (4050, 250, 4350, 1300) | clear; LAMP RET's source not traced |
| Lamp unit | Dashed box, 15 element inputs (pins 3–17), two commons on the right (G26 upper, Gd lower), a lamp/LED symbol at the top that the scan does not resolve, caption `(TM8132-9G)` | (4980, 330, 5160, 470) | outline clear; symbol and caption probable |

### Polarity

- **Element lines.** Each PROM output is open collector. A **0** makes the
  output sink current through its 220 Ω resistor and lamp element from the
  active common: the lamp is **on**. A **1** leaves the output off: the lamp
  is **off**. An unprogrammed 74S188 reads 0 everywhere, so a blank part
  would light every element.
- **Commons.** O8 = 0 pulls the O8 node low: TR16's base is pulled down
  through R45, TR16 conducts and powers **G26**; inverter 37's input is low,
  its output high. O8 = 1 (off): R43 pulls the node to LAMP V, TR16 is off,
  inverter 37's output goes low and TR13 conducts, powering **Gd**. So bit 7
  of PR-02 picks the common: **0 = G26 (TR16), 1 = Gd (TR13)**, one at a
  time.
- **Two conditions this relies on (inference, not read):**
  - TR13 is fully off only if inverter 37's high output does not pull its
    base below LAMP V. That needs an open-collector inverter (7406/7416
    type) or LAMP V no higher than a TTL high. 37's type is not printed at
    the gate. The 10,000-point lamp driver on the same sheet uses the same
    pattern (inverter marked `06`, 1 kΩ, PNP A684 from LAMP V), which
    suggests a 7406.
  - When O8 is off, R43 holds O8 and inverter 37's input at LAMP V. The
    74S188's output and a TTL input are rated 5.5 V maximum, so LAMP V is
    probably the 5 V rail or close to it. LAMP V's source was not traced.
- **Current.** With LAMP V at 5 V and LED elements, each lit element draws
  about (5 − 0.2 − 2 − 0.45) / 220 ≈ 11 mA, within the 16 mA IOL. A 5 V
  incandescent lamp in series with 220 Ω would be very dim, so the elements
  are probably LEDs. Inference only.
- **/G.** The PROMs only drive outputs while /G (pin 15) is low. LAMP RET is
  taken as the lamp ground return, so /G is low and the PROMs are always
  enabled. If LAMP RET were a switched signal, it would blank the panel.

### Multiplexing

V2 is address A4 here and the select of sheet N's 74157 (IC133): V2 low
sends IC132 (car count) to BONUS A–D, V2 high sends IC140 (stored bonuses).
So in the V2-low phase the PROMs see the car count with A4 = 0, in the
V2-high phase the bonus count with A4 = 1. V2 is bit 2 of the vertical
count: 4 lines in each phase, a period of 8 lines, about 0.51 ms at the
provisional 15.69 kHz line rate (`docs/TIMING.md`), so each section is lit
half the time at about 2 kHz. 15 element lines × 2 commons = 30 positions,
15 per section, which is exactly enough for a count of 0–15 with 0 dark.

### The two V2s are the same signal

| Where | Reading | Box | Confidence |
|---|---|---|---|
| Sheet E (p16) | One V2 net. At a junction near (4160, 3950) it splits three ways: up through buffer `20` pins 5 → 6 (triangle, no bubble: non-inverting) to pad **D7** `V2 (I)`; to pad **F6** `V2 (A)`; and an arrow `V2 (B)(M)` | (3950, 3200, 4400, 4000); (3500, 3150, 7000, 4400) | clear |
| Sheet A (p8) | Pad **C6** `V2 (E)`; a dot just below it at about (8550, 1142) sends a branch up to an arrow `V2 (N)`; the main line goes on to IC53 pin 1 | (8400, 700, 8900, 1450) | clear |
| Sheet N (p12) | `V2 (A)` arrow, no pad → 133.1 and 21.13 | N trace W19 | clear |
| Sheet I (p18) | Pad **HH** `V2 (E)` → RA2 1 kΩ pull-up → PROM A4 | (1350, 650, 4100, 1200) | clear |

So N's V2 is E's V2 passed through board A unchanged (F6 → C6 → N, no
gate), and I's V2 at HH is E's V2 through the non-inverting buffer 20 (the
1 kΩ pull-up on I suggests an open-collector 7407-type buffer; type not
printed). **Same signal, same polarity**; the one buffer and the cable add
some tens of nanoseconds against a 0.51 ms period, so at each V2 edge the
PROM address and the mux select disagree only for a moment no lamp can
show. The pad pairings F6–C6 and D7–HH are by label; the harness on page 7
was not traced. Probable.

**Correction to `SHEET_I_TRACE.md`.** Pad **HU** is not plain V2: its label
is `V2'` (the "raised mark" is a prime), the same V2' that sheet K and J
use. On sheet E, V2' is a different signal: AND gate 96 (3, 4, 5 → 6) →
buffer 9 → 8 → pad **DP** `V2' (I)`. Box (2100, 3150, 3300, 4500) on page
16. It does not reach the lamp PROMs. Its inputs were not traced.

## 2. Proposed contents

### Assumptions

1. **Bar graph** (the reading so far, issue #69): for a count n = 0–15,
   lamps 1 … n of that section are lit, the rest off. The panel's
   green-yellow-red bar under "NUMBER OF CARS SUCCESSIVELY OVERTAKEN" fits a
   bar; a single moving lamp would fit the wiring equally well. The bonus
   section is taken to work the same way.
2. **Lamp order**: lamp-unit pins 3 … 17 are the bar positions 1 … 15 in
   order, pin 3 lighting first (the green end). So position k is PR-01 O(k)
   for k = 1–8 and PR-02 O(k − 8) for k = 9–15. The unit's internal layout
   is not drawn; the order could be reversed or interleaved.
3. **Common per section**: O8 = V2. The car-count phase (A4 = 0) uses G26
   (TR16, the upper common as drawn), the bonus phase (A4 = 1) uses Gd
   (TR13). Nothing on the schematic says which common feeds which section;
   this choice is **arbitrary** (it only follows the drawn order top to
   bottom). Swapping it means inverting bit 7 of PR-02.
4. **Bit order in a byte**: O1 (pin 1, the datasheet's Q0) = bit 0, O8
   (pin 9, Q7) = bit 7, the convention of `plus200-glyph.txt`. A programmer
   or dump may read them the other way round.
5. **Count range**: IC132 shows 0–15 (it rolls over to 0 at the 16th
   count, which gives a bonus); IC140 holds 0–15 and stops at 15. Every
   address is therefore used. During the payout IC140 counts down, so the
   bonus bar would shrink by one lamp per 200 points.
6. /G enabled (LAMP RET is ground), PROMs open-collector, inverter 37
   effectively open-collector (section 1).

### Layout

Address = 16 · V2 + count. Bytes as stored (1 = output off = lamp off).

| Addresses | V2 | Count (source) | Common (PR-02 O8) | PR-01 | PR-02 |
|---|---|---|---|---|---|
| 0–15 | 0 | cars overtaken, IC132 | 0 → TR16 → G26 | lamps 1–8 | lamps 9–15, bit 7 = 0 |
| 16–31 | 1 | stored bonuses, IC140 | 1 → TR13 → Gd | lamps 1–8 | lamps 9–15, bit 7 = 1 |

| n | PR-01 (lamps 1–8) | PR-02, V2 = 0 | PR-02, V2 = 1 | lit |
|---|---|---|---|---|
| 0 | ff | 7f | ff | none |
| 1 | fe | 7f | ff | 1 |
| 2 | fc | 7f | ff | 1–2 |
| 3 | f8 | 7f | ff | 1–3 |
| 4 | f0 | 7f | ff | 1–4 |
| 5 | e0 | 7f | ff | 1–5 |
| 6 | c0 | 7f | ff | 1–6 |
| 7 | 80 | 7f | ff | 1–7 |
| 8 | 00 | 7f | ff | 1–8 |
| 9 | 00 | 7e | fe | 1–9 |
| 10 | 00 | 7c | fc | 1–10 |
| 11 | 00 | 78 | f8 | 1–11 |
| 12 | 00 | 70 | f0 | 1–12 |
| 13 | 00 | 60 | e0 | 1–13 |
| 14 | 00 | 40 | c0 | 1–14 |
| 15 | 00 | 40 | c0 | 1–14 (14 lamps a bar; see below) |

PR-01's two halves are the same; only PR-02 bit 7 differs between them.
The 32 bytes of each PROM are in `lamp-proms.txt`.

Variants, if a later finding requires them: other common assignment →
invert PR-02 bit 7 in every byte; reversed lamp order → lamp k becomes
lamp 16 − k; single lamp instead of a bar → only lamp n lit (n ≥ 1).

### 14 lamps a bar (Aldo, 6 November 2026, #112)

Aldo's description of a working cabinet (`pro/docs/OBSERVATIONS.md`) gives
14 lamps a bar: 9 green and 5 red on top, 14 red on the bottom. On the top
bar, n cars light lamps 1 to n for n = 1–14, **15 cars still light 14**, and
the 16th car turns the bar off and adds a bottom lamp (sheet N's IC132
wrapping, as drawn). So count 15 is stored here as lamps 1–14, and element
line 15 (unit pin 17, PR-02 O7) is never lit: the unit has no 15th lamp, or
its 15th line is unused. The top-bar mapping is Aldo's observation. The
bottom bar's mapping (15 stored bonuses = 14 lit) was not observed and
follows the same rule: **uncertain**.

What clears the car count is sheet N's logic, not these PROMs
(`pro/docs/SHEET_N_LOGIC.md`): IC132 is cleared by IC53 = AND(IC143.6, GAME,
W02), IC143.6 = NAND(PR-38-7, PR-38-9, IC100.13) · /ACC1. So the top bar
goes to 0 on a crash (/ACC1, as Aldo saw), at a coin or reset (W02), and when
the car-count one-shot (IC100.13) runs while PR-38's D6 · D7 = 1 (the
slow-player bits of `trace/BONUS_INPUTS_TRACE.md`). Whether going off the road also clears it depends
on whether it produces /ACC1, which these notes do not settle: Aldo is not
sure either. **Uncertain.** The bottom bar (IC140) keeps its count until the
payout after game over.

## 3. What would settle it

- **Dumps of PR-01 and PR-02.** They settle everything above at once.
- **A closer photo of the panel** with known counts: how many lamps each
  section has (15 expected), whether a count lights a bar or one lamp, and
  which end lights first. A photo of the bonus section during the payout
  (when IC140 counts down) would show the order directly.
- **The lamp unit or LED board** (TM8132-9G, or the score display LED board
  named on page 7): which unit pin is which lamp, and which common is the
  top section.
- **Continuity on a board**: G26/Gd to the panel sections; inverter 37's
  type; LAMP V and LAMP RET.

## Not checked

- The cabinet harness on page 7: which LED board pins connector G reaches
  (the score board connector runs to "MO-4221 SCORE DISPLAY LED BOARD
  ASS'Y", 64 pins; the pin labels were not read), so the D7–HH and F6–C6
  pairings rest on labels.
- LAMP V and LAMP RET sources and voltages; inverter 37's package type;
  buffer 20's type.
- The inputs of gate 96 (V2') on sheet E.
- Nothing was simulated; no HDL or test was changed.
