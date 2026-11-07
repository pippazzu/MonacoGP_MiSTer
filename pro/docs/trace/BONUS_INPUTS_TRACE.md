# Bonus inputs trace: sheets G, H and D into sheet N (Pro Monaco GP)

Date: 2026-11-05. Issue #36. Bounded trace. It covers the sources of the
seven sheet-N bonus inputs PLAYER ST, /SCORE ST, /OTHER CAR, PR-38-7,
PR-38-9 and /BRIDGE AP, compares each with the original board, and then
states what the traced wiring says a bonus needs.

**Correction, 2026-11-06 (issue #62).** The first version called PR-38
D6 · D7 = 1 the "fast bits" and said the bridge one-shot is held clear
*unless* they are set. The gates transcribed below say the opposite:
IC100.11 (/CLR) = GPR.8 = NAND(PR-38-7, PR-38-9), so the bridge one-shot is
held clear **while** D6 · D7 = 1 and can run only while D6 · D7 = 0. The
prose of "What a bonus requires" and of the short report is corrected, and
D6 · D7 = 1 is renamed the *slow-player bits*, after Monaco GP's PR-38 dump
(`../OBSERVATIONS.md`). No pin reading or connection was changed.

## Sources and method

- Pro: `pro/schematics/promonacogp420-0525_1.pdf` (SHA-256
  `9473d6dd…32f2`), PDF page 10 (sheet G, 96822-P D-3/5), page 11 (sheet H,
  96822-P D-4/5), page 15 (sheet D, 96823-P D-3/5). Each page was rendered
  with PyMuPDF at `Matrix(1, 1)`, upright: G 10192 × 6617, H 10167 × 6617,
  D 10175 × 6617 pixels. Every box below is (left, top, right, bottom) on
  that render and can be cropped again. Crop names are local identifiers
  only. The crops are not in the repository.
- Original: `schematics/pages/page27-sheet-G.png`, `page28-sheet-H.png`,
  `page31-sheet-D.png`, with `docs/trace/SHEET_G_PLAYER.md`,
  `docs/trace/SHEET_H_TRACE.md`, `docs/trace/SHEET_D_TRACE.md` and the
  `docs/SHEET_{G,H,D}_LOGIC.md` notes. Where those traces are cited, their
  boxes are in the coordinates of their own documents.
- Sheet N connections come from `pro/docs/trace/SHEET_N_TRACE.md` (second
  pass), and are cited by its IC.pin notation and wire IDs (W01–W27). They
  were not re-read here.
- Reading rules are those of `pro/README.md`: a drawn dot is a junction; a
  crossing is not, even when the scan thickens it. Gate function comes from
  the symbol. Pin numbers were checked against the standard pinouts, and
  differences are recorded below, not corrected.
- Confidence: **clear** (read directly, no competing reading), **probable**
  (one reading fits much better, but the scan is not clean), **uncertain**.
- No MAME, emulator, other core, fan remake, footage or gameplay
  description was used.

## Summary table

| Signal on N | Pro source | Original source | Same? |
|---|---|---|---|
| PLAYER ST | G: IC31 1,2→3 = AND(horizontal window, HC4) | **None.** No such signal on the original sheet G | **New on Pro**, built from two nets the original already has |
| /SCORE ST | G: IC121 second half, /Q pin 4 (slick one-shot) | G: IC19 /Q pin 4, to F only | **Same** source and function; Pro also sends it to N |
| /OTHER CAR | H: inverter (11→10, faint) from IC98 (157) pin 12, PR-132 D6/D7 | H: IC114 11→10 from IC118 pin 12, PR-132 D6/D7 | **Same** net as the video /OTHER CAR (pad B15); Pro adds a branch to N |
| PR-38-7 | H: PR-38 (IC127, 288) pin 7 = **D6** (drawn "7" inside: O7) | H: PR-38 (IC115) pin 7 = D6, to the 157 pin 11 only | **Same** PROM bit; Pro also sends it to N |
| PR-38-9 | H: PR-38 pin 9 = **D7** (drawn "8" inside: O8) | H: PR-38 pin 9 = D7, to the 157 pin 14 only | **Same** PROM bit; Pro also sends it to N |
| /BRIDGE AP | D: IC59 1→2 = NOT(BRIDGE AP), pad FD (read; "F8" not excluded) | D: IC22 5→6 = NOT(BRIDGE AP), used only on D | **Same** logic function (a bridge flip-flop NORed with a 279 latch, then inverted); the pad export to N is new |

## PLAYER ST (sheet G, Pro page 10)

PLAYER ST is generated on Pro sheet G by IC31 pins 1, 2 → 3, an AND gate
(AND body, no bubbles, 7408 section). Its inputs are the player car's
horizontal window and the counter bit HC4.

| Element | Reading | Box | Confidence |
|---|---|---|---|
| Output arrow | `PLAYER ST`, no bar, arrow pointing down (output), circled N | g-labels (2450, 5550, 3300, 6350) | clear |
| Route | IC31.3 left along y ≈ 4275 to x ≈ 2735, then down to the arrow. It crosses /SP DOWN (x ≈ 3445) and the 7MHz, PL-H-ST and bottom rows without dots. The nearby dot at (3445, 4140) is on a different row | g-pst (2700, 4200, 3950, 5900); g-dot2 (3350, 4050, 3550, 4350) | clear |
| IC31 pin 1 | IC32 pin 6. A dot at the corner; the same vertical continues up | g-ic31 (3500, 3900, 4700, 5400); g-ic31b (3780, 4150, 4180, 5300) | clear |
| IC31 pin 2 | Down to a dot on IC38 pin 11, the first output (QA) of the second 393 half | g-ic31b; g-rows (3500, 4900, 4400, 5300) | clear |
| IC38, two 393 halves | Upper half: A pin 1 = IC24.1, CL pin 2 = PL-H-ST (F), outputs 3, 4, 5, 6. Pin 6 clocks the lower half (A pin 13). Lower half CL pin 12 = PL-H-ST, outputs 11, 10, 9, 8. So pins 3–6 are HC0–HC3 and pins 11–8 are HC4–HC7 | g-left (1450, 4300, 4700, 5700); g-pst | clear |
| IC24 2,3→1 | Bubbled inputs, AND body, so a NOR: 7MHz (F) and IC31.8. It stops the clock while IC31.8 is high | g-left; g-ic31 | clear |
| IC31 9,10→8 | AND(IC38.8 = HC7, IC38.10 = HC5) → IC24.3 | g-rows | clear |
| IC32, 4-input | AND body with every input bubbled, so a NOR. Pin 5 = /COIN IN (A), dot at about (4000, 5375). Pin 4 = HC5 (dot on row 10). Pin 2 = HC6 (dot on row 9). Pin 1 = IC25 1→2 inverter of HC7 (dot on row 8). Output 6 | g-rows; g-left; g-ic31b | connections clear; the "4" numeral is probable (overwritten stroke) |

**Function, as wired.** IC32.6 = NOR(/COIN IN, HC5, HC6, /HC7) is high for
HC = 0x80–0x9F while /COIN IN is low. IC31.3 = IC32.6 · HC4 is therefore
high for **HC = 0x90–0x9F**: the second 16 pixels, in HC order, of the
player car's 32-pixel horizontal window. The counter stops at 0xA0
(IC24/IC31.8), so it is one 16-pixel span after each PL-H-ST.

**No vertical term.** No VC bit, vertical-window latch output or PROM output
enters IC31.3 or IC32.6. PLAYER ST is therefore not limited to the car's
32 lines. It repeats on every line on which the HC counter runs after
PL-H-ST. How often PL-H-ST fires is decided on sheet F and was not checked
here.

**Comparison with the original.** The original sheet G (page 27) has no
PLAYER ST arrow: its bottom-edge outputs are /SCORE ST, /ACC1.PULSE,
/ACC1.ST, /SP.DOWN and SP.DOWN, all to F (original page 27 PNG, box
(1500, 4500, 4000, 6200)). The two nets PLAYER ST is built from do exist on
the original:

| Pro | Original (`SHEET_G_PLAYER.md`) |
|---|---|
| IC38 two 393 halves, HC0–HC7 | IC52, HC0–HC7 |
| IC24 2,3→1 NOR(7MHz, IC31.8) | IC63 2,3→1 NOR(7MHz, IC34.11) |
| IC31 9,10→8 AND(HC5, HC7) | IC34 13,12→11 AND(HC5, HC7) |
| IC32 5,4,2,1→6 HWIN | IC57 HWIN (inputs drawn 1, 4, 3, 2; see the original's unresolved item 2) |
| **IC31 1,2→3 AND(HWIN, HC4) → PLAYER ST (N)** | no equivalent gate |

Pro draws IC32's inputs as 5, 4, 2, 1. Those are the four inputs of a
7425, with the strobe pin 3 not used. That is consistent with the reading
the original trace chose for its IC57 ("3" taken as pin 5). It is
evidence about the Pro drawing only, not a correction of the original.

## /SCORE ST (sheet G, Pro page 10)

| Element | Reading | Box | Confidence |
|---|---|---|---|
| Output arrow | `/SCORE ST` with bar, to circled F and, below it, a heavily inked circled N | g-labels | label and F clear; N probable (the second circle is overwritten, but it reads as N) |
| Source | IC121 second half (`123/2`): /Q pin 4 straight down to the arrow | g-bl (2000, 3400, 4500, 6300); g-121b (2050, 4750, 2650, 5100) | clear |
| A, pin 1 | /SLIDE (D), pad CR. Dot at about (2070, 3646) on the /SLIDE row; vertical down to pin 1 | g-slide (1500, 3450, 2800, 3800) | clear |
| B, pin 2 | Down to y ≈ 5575, right to the dot at (3065, 5575). That vertical goes up to B of the first IC121 half (pin numeral there illegible). The row continues right to x ≈ 8820 and up to IC95 pin 3 | g-bnode (2900, 5400, 3300, 5750); g-row1 (3000, 5300, 6500, 5800); g-row2 (6300, 5300, 9800, 5800); g-ic95 (8200, 3500, 9200, 5700) | clear |
| IC95 1,2→3 | OR body with bubbled inputs, so a NAND: pin 1 = /EXPLO ST (F), pin 2 = /PLAYER BODY (IC86 output 1, dot at (8796, 3700)). The output row crosses the PLAYER (F) vertical at (8540, 5575) without a dot | g-95src (8250, 3600, 9000, 4450); g-explo (8650, 300, 9100, 3700); g-95out (8150, 5450, 8950, 5750) | clear. The thickened crossings lower on the x ≈ 8796 vertical are smaller than the dot on the /PLAYER BODY row and are read as crossings |
| /CLR, pin 3 | Vcc | g-121b | clear |
| Q, pin 13 | Up and left to 279 latch IC37 /S pin 15 (the /ACC1.ST latch) | g-bl | clear |
| Timing | C45 between 14 and 15, R26 47K from Vcc to 15. C45 reads `10µ`, with a struck-out value above it | g-121b | 47K clear; 10µ probable (the struck-out value is not read) |

**Function.** IC121b fires when /SLIDE falls while B is high, or when B
rises while /SLIDE is low, with B = EXPLO ST + PLAYER BODY. That is, when
the slide area meets the car body on the raster, or while the explosion
runs. /SCORE ST is low for one pulse, about 0.13 s with the 74123 formula
(0.28·R·C·(1 + 0.7/R) for R = 47 kΩ, C = 10 µF), or about 0.21 s with the
74LS123's 0.45·R·C. The family is not printed.

**Comparison with the original.** This is the original IC19
(`SHEET_G_PLAYER.md`, "Select-state logic"): A = /SLIDE, B = IC68.3 =
NAND(/EXPLO.ST, /PLAYER BODY) shared with IC119's B, /CLR = Vcc, Q → IC51
/S (the /ACC1.ST latch), /Q → /SCORE.ST (F), C33 10µ and R19 47K.
Original page 27 PNG, box (1500, 4500, 4000, 6200), shows the arrow to (F)
only. **Same net and function.** Pro adds the second destination, N. The
designators differ (IC121 second half vs IC19, IC95 vs IC68, IC37 vs IC51).
That proves nothing either way.

## /OTHER CAR (sheet H, Pro page 11)

| Element | Reading | Box | Confidence |
|---|---|---|---|
| Output to N | `/OTHER CAR` with bar, arrow to circled N. It branches by a dot at about (6478, 3755) from the output row that ends at pad B15, `/OTHER CAR (C)`. The branch crosses the /OTHER BODY and TIAR rows without dots | h-out (5600, 3350, 7350, 4300); h-inv (6200, 3700, 6750, 4000) | clear |
| Inverter | Triangle with an output bubble, input from IC98 pin 12. The pin numerals read 11 → 10 at low zoom and are illegible at high zoom. The designator inside the triangle is blotted | h-inv; h-inv1 (6230, 3700, 6450, 3880) | function clear; pins probable; designator unread |
| IC98, `157` | Outputs 12, 9, 7 → the three inverters (/OTHER CAR, /OTHER BODY, TIAR). Inputs 2, 3, 5, 6, 11, 10, 14, 13 come from PR-132 (IC91, µPB425) data pins 9, 10, 11, 13, 14, 15, 16, 17, in that order. So pin 12 (4Y) selects D6 (pin 16 → 14) or D7 (pin 17 → 13). /G pin 15 is on the strobe row | h-pr132 (5550, 2850, 6250, 3700) | probable (eight parallel verticals followed by eye; no junction dots involved) |

**Comparison with the original.** Original IC118 (157): pin 12 Zd from
I0d = IC111.16 (D6) and I1d = IC111.17 (D7), then IC114 11→10 to pad B15
/OTHER CAR (C) (`SHEET_H_TRACE.md`, IC118 and IC114 tables; box "IC118,
IC114 and the /OTHER pads" (6100, 3330, 7450, 4200) in that trace's frame).
Pro has the same 157 pin assignment, the same inverter pins and the same
pad, B15. **Same net.** /OTHER CAR on N is the video signal sheet C
receives: low on the other-car colour code (PR-132 D6/D7 pair) of whichever
channel is enabled. Pro adds the branch to N. The upstream channel logic
(position counters, 367 buffers, AREA decode) was not re-traced. The
/OTHER BODY arrow to F is unchanged in kind and outside scope.

## PR-38-7 and PR-38-9 (sheet H, Pro page 11)

| Element | Reading | Box | Confidence |
|---|---|---|---|
| PROM | `288 PR-38`, designator 127 (written across the top-left pin labels) | h-pr38 (1000, 4950, 2650, 6250); h-pr38z (1820, 5000, 2300, 5500) | clear |
| Pin numerals, right side | Top to bottom: 5, 6, 7, 9, then 1, 2, 3, 4 | h-pr38zz (1900, 5030, 2100, 5280); h-pads (1950, 5250, 2900, 6150) | 6, 7, 9 and 1–4 clear; the first is probable 5 (an odd top stroke, could be taken for 6) |
| Bit labels inside the body | Facing pins 5, 6, 7, 9: `5`, `6`, `7`, `8` (the first partly hidden by "127"). Facing pins 1–4: `D1`, `2`, `3`, `4` | h-pr38zz; h-pr38z | 6, 7, 8 and D1–4 clear; first probable |
| Pin 7 | Right to IC134 (157) pin 11, with a dot at about (2216, 5193). From the dot, down to the upper arrow `PR-38-7`, to circled N | h-pr38z; h-pr38arr (1550, 5600, 2300, 5850) | clear |
| Pin 9 | Right to IC134 pin 14, with a dot at about (2249, 5238). From the dot, down to the lower arrow `PR-38-9`, to circled N. Both arrow rows cross the four pad verticals without dots | h-pr38z; h-pr38arr | clear |
| Pins 5, 6 | IC134 pins 2, 5 | h-pr38 | probable |
| Pins 1–4 | Pads C16, CT, C17, CU (braced, to a circled symbol not read) | h-pads | clear |
| Addresses | ACCE. A–D (F) → pins 10–13 (A–D). SP. CONT. → pin 14 (E), with a capacitor to ground. Pin 15 → ground | h-acce (1000, 5100, 1900, 5450) | clear |
| SP. CONT. pad and capacitor | Pad reads `AR`; capacitor `1000p`, designator `C88`-like | h-acce; h-cap (1250, 5300, 1800, 5500) | value probable; pad letters and designator uncertain |

**Which data bits.** The 74S288 is a 32 × 8 PROM. Outputs O1–O7 are on
pins 1–7, ground is pin 8, O8 is pin 9, addresses are pins 10–14, /G is
pin 15. The drawing's own bit labels number the outputs 1–8 (D1 at pin 1,
"8" at pin 9). So **PR-38-7 is output 7 = D6** and **PR-38-9 is output
8 = D7**, in the 0-based naming of `SHEET_H_TRACE.md` (D0 = pin 1). The
pinout and the drawing agree.

**Meaning on the original board.** D7–D4 are the nibble L that IC108 loads
into the divider's low counter on line 1FF (`SHEET_H_LOGIC.md`). The other
cars' divider phase then moves by 8 − L + m pixels a frame, with m = 0–7
from the restart delay. D6 · D7 = 1 means L = 12–15 (binary 11xx). On Pro,
pins 5, 6, 7, 9 likewise reach the 157 inputs 2, 5, 11, 14, so the same
nibble path holds as far as it was read here.

**Differences in PR-38's wiring on Pro sheet H:**
1. D6 and D7 are also exported to N (new).
2. Designators: PROM IC127 (original IC115), 157 IC134 (original IC108).
   Not meaningful in themselves.
3. The capacitor on the SP. CONT. line reads 1000p (original C36, 470p).
4. The SP. CONT. pad reads AR (the original trace reads AL; its redraw
   reads Ah). Uncertain letters. A sharper scan of box h-cap would settle
   them.

The PROM contents are not on the schematic. Which accelerator and
SP. CONT. states give D6 · D7 = 1, and whether Pro's PR-38 holds the same
data as the original's, are **not settled** here (`BOARD_DIFFERENCES.md`
also warns against assuming identical PROMs).

## /BRIDGE AP (sheet D, Pro page 15)

| Element | Reading | Box | Confidence |
|---|---|---|---|
| Output to N | `/BRIDGE AT`-like label with an overbar, to circled N, from a black pad labelled `FD` | d-bot (3050, 5300, 4100, 6400); d-inv (3550, 5450, 3950, 5950); d-lab (3550, 5900, 3950, 6350) | bar and N clear; pad reads FD (probable), with "F8" not excluded |
| Inverter | IC59, 1 → 2 (triangle, output bubble). The output dot also feeds the arrow `/BRIDGE AP` (D), local | d-inv | clear |
| Inverter input | The BRIDGE AP vertical at x ≈ 3672. It also feeds the arrow `BRIDGE AP` (C) at x ≈ 3600 through a dot at (3672, 5520), and an unlabelled pad marked `BRIDGE AP` with circled D, M, H beneath | d-inv; d-lab; d-bot | clear; the D/M/H grouping is probable |
| BRIDGE AP route | The vertical at x ≈ 3672 rises from the dot at y ≈ 5520 to a corner at y ≈ 4212. The crossings at y ≈ 5300, 5345 and 5388 have no dots. The row y ≈ 4212 runs right, with no dot at any crossing, to a dot at (5258, 4212); the row continues right to IC28 pin 12 | d-vdot (3400, 5200, 3900, 5560); d-v (3450, 3700, 4100, 5500); d-x3800 (3650, 3900, 3950, 4850); d-row1 (3600, 4100, 5300, 4350); d-row2 (5100, 3950, 7000, 4400) | clear |
| Source gate | From the dot at (5258, 4212) up to the output of a 2-input gate with an AND body and both inputs bubbled, so a NOR. Inputs 9, 8, output 10. Designator reads `63` ("83" not excluded). A blotted handwritten note above the output is not read | d-v2 (4900, 1900, 5700, 4300); d-g62 (4950, 3680, 5350, 4250); d-g62z (5050, 3680, 5300, 3850) | function and pins clear (they agree with a 7402 section 8, 9 → 10); designator probable |
| NOR pin 9 | IC56 pin 8, /Q of the 7474 half labelled `BRIDGE` above it (D pin 12, CK 11, CL 13, Q 9). Route: right to x ≈ 4446, down to y ≈ 3771, right to pin 9. No dots at its crossings | d-ffs (3300, 2350, 4500, 3500); d-p9 (4250, 3150, 5000, 3800); d-up (4250, 2300, 5100, 3850); d-up2 (4650, 3100, 5250, 3850) | clear |
| IC56 BRIDGE half, D | Pin 12 = IC56 other half Q pin 5 (dot at about (4360, 2685)) | d-ffs | clear |
| NOR pin 8 | Dot at (4836, 3820) on a vertical. Upward it goes to input 4 of a 3-input gate (not followed). Downward, a dot at (4835, 3997) on a row that runs left to x ≈ 3803, then down to a dot at (3803, 4783) on the Q row of IC91 | d-up2; d-dn (4600, 3700, 5000, 4600); d-x1 (1500, 3900, 4900, 4100); d-x3800; d-279 (2200, 4500, 4200, 5000) | clear |
| IC91 | `279/4`: /S pin 6, /R pin 5, Q pin 7 | d-279 | clear |

**Function.** BRIDGE AP = NOR(IC56.8, IC91.7) is high when the BRIDGE
flip-flop is set (its /Q low) and the IC91 latch's Q is low. /BRIDGE AP on
pad FD is its complement, so it is low under the same condition.

**Comparison with the original.** Original `SHEET_D_TRACE.md`,
"BRIDGE AP source and local-reference closure", and `SHEET_D_LOGIC.md`:
BRIDGE AP = IC80.1 = NOR(IC25.6, IC68 Q). IC25.6 is /Q of IC25's lower
half (the bridge state flip-flop, D = EXT. 500 from IC25's upper half), and
IC68 is a 74279 latch whose Q is low while a state is in progress. IC22 5→6
inverts it to /BRIDGE AP, which is used only on D (IC58.1). Pro has the same
structure: a NOR of a 7474 half's /Q, whose D comes from the other half's
Q, and a 279 latch Q. **Same function at this level, probable.** Not
re-traced on Pro:
- whether IC56's other half is the EXT. 500 flip-flop;
- what clocks the BRIDGE half;
- whether IC91's /S and /R come from the same count decode as the
  original IC68.

What is new: the inverted signal leaves the board on pad FD.

**Pad.** On N, /BRIDGE AP arrives on pad CD. D is on board 96823-P and N on
board 96822-P. On the original, D's pad F18 carries BRIDGE AP to H's pad
C18, the same F→C, same-suffix pattern as FD → CD. That pairing is an
inference from the pattern, not a drawn wire. The cabinet or interboard
wiring (Pro page 7) would settle it, and was not checked.

## What a bonus requires, from the traced wiring

The following uses the sheet N trace's connections with the meanings
established above. Durations use the 74123 formula 0.28·R·C·(1 + 0.7/R);
the 74LS123 value (0.45·R·C) is given in brackets. The family is not
printed. Nothing here was simulated or measured.

**Definitions**
- *Overlap*: a /OTHER CAR low pixel inside the PLAYER ST span, that is, an
  other-car pixel at HC 0x90–0x9F of the player's horizontal window, on any
  line.
- *Slow-player bits*: D6 · D7 = 1 on PR-38 (L = 12–15). The name comes
  from Monaco GP's PR-38 dump, where D6 · D7 = 1 only at low player speed
  (ACCE. 0–4, or 0–6 with SP. CONT.; `../OBSERVATIONS.md`). It is not a
  reading of the schematic, and Pro's PR-38 contents were not checked.
  (Called "fast bits" before 2026-11-06, which inverted the bridge rule.)
- *On the bridge*: BRIDGE AP high (/BRIDGE AP low) inside the PLAYER ST
  span.

**IC100, first half: the overlap one-shot.** A = /OTHER CAR,
B = PLAYER ST, /CLR = /SCORE ST, R20 47K, C39 3.3µ, about 44 ms [70 ms].
It fires on an overlap and is retriggered on every later one. So one
continuous run of overlaps, with gaps shorter than the pulse (a frame is
about 17 ms), gives one pulse. Its /Q (pin 4) clocks IC132 (74161) on the
rising edge, so **IC132 counts at the end of each overlap episode**.

**IC100, second half: the bridge one-shot.** A = /BRIDGE AP,
B = PLAYER ST, /CLR = NAND(PR-38-7, PR-38-9), R22 47K, C33 1µ, about 13 ms
[21 ms]. It is held clear while the slow-player bits are set (GPR.8 low).
With them clear (D6 · D7 = 0), it runs while the player is on the bridge.
Its /Q (pin 12) drives IC132's
ENP and ENT, so **counting is disabled while it runs**.

**IC132 is cleared** (/CLR = IC53.8 = AND(IC143.6, GAME, reset)) when any
of these holds:
- GAME is low (outside a game);
- coin/test or initial reset is active;
- /ACC1 is low (accident);
- an overlap pulse runs while the slow-player bits are set:
  IC143.6 = NAND(PR-38-7, PR-38-9, IC100.13) · /ACC1.

**IC107, half 9–11: the bonus one-shot.** A = /OTHER CAR, /CLR = /SCORE ST,
R23 47K, C40 3.3µ, about 44 ms [70 ms]. B = IC108.6 = (IC132 RCO ·
IC100.13) + (IC100.5 · PLAYER ST). Its Q goes through IC72 and IC108 to
clock IC140. IC140 counts up while /GAME is low and stops at 15. It counts
at the end of the IC107 pulse, provided the payout divider output IC80.9 is
low, which is the state it is left in after a payout or a reset (sheet N
and F traces).

**Bonus rule, as far as the wiring settles it**
1. **16 overlap episodes give one bonus (confirmed, with conditions).**
   Starting from 0, the first 15 episodes bring IC132 to 15. RCO is then
   high, because ENT is high while the bridge half is idle. The 16th
   episode's start raises IC100.13 while /OTHER CAR is low, so B rises and
   IC107 fires. If that edge is missed, the next other-car edge while B is
   high fires it. IC140 gains one at the end of IC107's pulse, and IC132
   wraps 15 → 0 at the end of the episode. This needs all of the following:
   - IC132's /LOAD (pin 9, not drawn on N) is inactive. If it were tied
     low, IC132 would load 0 on every clock and never reach 15.
   - The slow-player bits are not set during the counted episodes.
   - /SCORE ST stays high.
   - Neither /ACC1 nor the end of GAME clears IC132 in between.
2. **The count does not tell overtaking from being overtaken.** The
   episode detector is symmetrical. Any other car whose car-colour pixels
   cross the PLAYER ST span counts, whichever way it moves. The only
   speed-dependent term is the slow-player bits: with them set, an overlap
   **clears** IC132 instead of adding to it. At the end of that episode the
   clock edge and the clear's release coincide, and C57 (1000p) delays the
   release, so the count probably stays 0. The drawing does not settle that
   race. The earlier reading "IC132 counts 16 overtaken cars" is therefore
   **corrected to "16 overlap episodes, counted only while D6 · D7 ≠ 1, and
   cleared by any episode while D6 · D7 = 1"**. Whether D6 · D7 = 1
   corresponds to the player being slower than the traffic, which would
   make the rule mean "overtakes count, being overtaken resets", depends on
   PR-38's contents and on the screen orientation. Both are outside the
   wiring, so this stays **open** here. (2026-11-06: Monaco GP's PR-38 dump
   and the cabinet's instruction card, "overtaking 16 successive cars",
   both point to that meaning; see `../OBSERVATIONS.md`. Pro's PR-38 was
   not read.)
3. **Bridge path (wiring fact, meaning open).** With the slow-player bits
   clear (D6 · D7 = 0) and the bridge half running, B = IC100.5 · PLAYER ST
   is high within the PLAYER ST span. An other-car pixel there fires IC107
   directly, so one bonus is added without the 16-count. That overlap does
   not clear IC132, because IC143.8 needs D6 · D7 = 1. While the bridge
   half runs, IC132 cannot count (ENP/ENT low). With the slow-player bits
   set, the bridge half is held clear (GPR.8 low): the bridge gives no
   bonus, and an overlap there clears IC132 as anywhere else.
   (Corrected 2026-11-06: the first version had the bridge path running
   with D6 · D7 = 1.)
4. **Inhibits.** While /SCORE ST is low (about 0.13 s [0.21 s] after a
   slick meets the car body, or during an explosion), IC100's overlap half
   and IC107 are held clear: no count and no bonus. /ACC1 low clears the
   count. Bonuses stop at 15 stored (IC140 MAX/MIN). IC140 is not cleared
   at game start, only loaded with 0 at reset (W02). It is back at 0 after
   a payout.

## Still uncertain

| # | Item | Box | What would settle it |
|---|---|---|---|
| U1 | Pro G IC32 input numeral "4" (overwritten) | g-ic31b | Sharper scan. The connection itself is clear |
| U2 | C45 value 10µ, with a struck-out value above it | g-121b | Sharper scan or the parts list (Pro pages 4–5) |
| U3 | /SCORE ST second destination circle, read as N | g-labels | Already supported by N's input arrow; a sharper scan |
| U4 | /OTHER CAR inverter's pin numerals and designator | h-inv1 | Sharper scan or board photo |
| U5 | IC98 input order from PR-132, followed by eye | h-pr132 | Higher-resolution scan |
| U6 | PR-38's first right-side pin numeral (5 vs 6) | h-pr38zz | The 288 pinout and the inside label "5" agree on 5; a sharper scan |
| U7 | SP. CONT. pad letters (AR/AL) and capacitor designator | h-cap | Sharper scan; cabinet wiring page 7 |
| U8 | Pad FD vs F8 on D, and its pairing with N's CD | d-inv | Interboard wiring (page 7) |
| U9 | D gate designator 63/83 and the blotted note above its output | d-g62z | Sharper scan or board photo |
| U10 | Whether Pro D's BRIDGE flip-flop and IC91 latch are driven as on the original (EXT. 500 into D, the count decode into /S and /R) | d-ffs; d-279 | A full Pro sheet D trace of those inputs |
| U11 | IC132 /LOAD (pin 9) undrawn (sheet N trace item 3) | N `counter` | PCB continuity or a board photo |
| U12 | The count-versus-clear race at the end of an episode with the slow-player bits set | N `lowerleft` | Timing simulation with real part delays, or a board measurement |

## Not checked

- Sheet F: how often PL-H-ST fires, and where /SCORE ST and ACC1 go on F.
- Sheet H upstream of IC98: position channels, 367 buffers, AREA decode,
  the PR-132 select. Also the 157 IC134's fixed inputs.
- Sheet D upstream of IC56 and IC91: the S-100 decode, the clocks, and
  IC91's /S and /R sources. Also the other loads of the IC91 Q rail and of
  BRIDGE AP (IC28.12, the /SLIDE gates).
- PR-38's contents, and therefore which accelerator states set D6 · D7.
- Screen orientation (which raster direction is "up the road").
- Sheet N connections themselves: taken from `SHEET_N_TRACE.md` without
  re-reading.
- Pro page 7 interboard and cabinet wiring.

## Short report

**Established**
- PLAYER ST is new on Pro: G IC31.3 = AND(horizontal window, HC4), high
  at HC 0x90–0x9F of the player window with /COIN IN low. It has no
  vertical term.
- /SCORE ST is the original slick one-shot (IC19's equivalent, /Q), now
  also wired to N.
- /OTHER CAR on N is the same net as the video /OTHER CAR (pad B15,
  PR-132 D6/D7).
- PR-38-7 = D6 and PR-38-9 = D7, by the 288 pinout and the drawing's own
  bit labels. The nibble path to the 157 is unchanged.
- /BRIDGE AP on N is NOT(BRIDGE AP) from D's IC59, leaving on pad FD.
  BRIDGE AP is built as on the original (NOR of a bridge flip-flop's /Q and
  a 279 latch Q).
- One bonus = the 16th counted overlap episode, under the conditions in
  rule 1. With D6 · D7 = 1, an overlap clears the count instead.
- On the bridge, an overlap gives a bonus directly only while
  D6 · D7 = 0. With D6 · D7 = 1, GPR.8 holds the bridge one-shot clear and
  the bridge gives none (corrected 2026-11-06, issue #62).

**Still uncertain**
- U1–U12 above. The main ones: IC132 /LOAD; the PR-38 contents that decide
  when D6 · D7 = 1 (so whether the rule means "overtakes count"); the
  FD/CD pairing; the upstream drive of Pro's BRIDGE flip-flop and IC91.

**Not checked**
- Sheet F (PL-H-ST), H upstream of IC98, D upstream of IC56 and IC91,
  PR-38 data, screen orientation, and the cabinet wiring, as listed above.
