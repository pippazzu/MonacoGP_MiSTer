# Second reading of the Pro bonus path (sheets N, F, A, G)

Date: 2026-11-06. Issue #80. A second, independent reading of the scan for the
items listed in the issue, compared with:

- `pro/docs/trace/SHEET_N_TRACE.md` (second pass)
- `pro/docs/trace/SHEET_F_BONUS_TRACE.md`
- `pro/docs/trace/SHEET_A_BONUS_TRACE.md`
- `pro/docs/trace/BONUS_INPUTS_TRACE.md`

## Method

1. Each page was rendered with PyMuPDF from
   `pro/schematics/promonacogp420-0525_1.pdf` at scale 1, upright
   (N: 10200 x 6617, F: 10175 x 6617, A: 10184 x 6617, G: 10192 x 6617).
   Crops are given as (left, top, right, bottom) on that render, with the zoom
   used to view them. They are not saved in the repository.
2. The whole of sheet N and the F, A and G items were read from these crops,
   and the readings written down, **before** any of the four traces was
   opened. The traces were opened only for the comparison.
3. The RTL (#71, PR #93) was not read. No emulator, other core, the KiCad
   redraw, footage or gameplay accounts were used.
4. Nothing in the traces or the RTL was changed.

Notation: `nn.p` is ICnn pin p; `/` is an overbar. The trace's local names are
used where they exist: **GPR** (the two-input NAND left of IC143), **IR**/**IP**
(the reset and point inverters, label like 88), **IC81** (the 107/2 J-K),
**GB** (F's combining gate, "gate 8"), **GS** (F's normal-score NAND),
**M151** (F's 74151).

## Result

**46 items: 46 agree, 0 disagree, 0 can't settle.** No misread wire was found
in the listed items. Three of the agreements carry a scan caveat that the
trace already records or that is noted below (F gate 8's upper pin numeral,
the F IC32 clear wire's gap across the ACCE C row, a faint stretch of A
IC35's input 10). Four observations outside the item list are at the end.

## Sheet N (PDF page 12)

Main crops: N-tl (2100, 800, 4300, 2200) x0.6; N-tm (3800, 800, 6000, 2200)
x0.6; N-tr (5800, 800, 8000, 2200) x0.6; N-ml (2100, 2400, 4300, 3800) x0.6;
N-mm (3800, 2400, 6000, 3800) x0.6; N-bl (2100, 3900, 4300, 5600) x0.6;
N-bm (3800, 3900, 6000, 5600) x0.6; N-left-trunks (2600, 2100, 3700, 4500)
x0.5; N-control (5400, 2300, 7300, 3700) x0.7; N-centre (4300, 3300, 6000,
4400) x0.8; N-cp (5900, 3600, 7600, 5000) x0.7; N-sound (6400, 850, 7600,
3300) x0.5.

### Gate types and bubbles

| # | Item | Second reading | Trace | Verdict | Crops |
|---|---|---|---|---|---|
| 1 | GPR | AND body, output bubble, inputs 10, 9 -> 8: NAND. 10 = PR-38-7, 9 = PR-38-9 (separate dots on the two rows). Out -> 100.11 and C54. Body label read as 113 with a dashed grid rule through the first digit | Upright two-input NAND, 10/9 -> 8, label resembles 113 but crossed by a scan rule; identity left uncertain | agree | (2850, 4800, 3100, 5050) x3; N-bl |
| 2 | IC143 9, 10, 11 -> 8 | AND body, output bubble: three-input NAND. 11 = 100.13 (W10), 9 = PR-38-7, 10 = PR-38-9. The "9" numeral is a blob; order from the row heights | NAND; 143.9 PR-38-7, 143.10 PR-38-9, 143.11 100.13 | agree | (3100, 5150, 3450, 5350) x4; (2950, 5150, 3700, 5450) x2 |
| 3 | IC143 1, 2, 13 -> 12 | OR body, bubbles on all three inputs, no output bubble: NAND. 13 = 143.8; 1 and 2 tied, from /ACC1 (dot at pin 1) | OR body/input bubbles = NAND; 143.8, /ACC1, /ACC1 | agree | (2950, 5150, 3700, 5450) x2 |
| 4 | IC143 3, 4, 5 -> 6 | AND body, output bubble, three inputs tied to 143.12: inverter. Out -> C57 (1000p) and 53.9 | All inputs tied 143.12; NAND output W12 | agree | N-bl; N-bm |
| 5 | IC53 9, 10, 11 -> 8 | OR body (concave input edge, bullet tip), bubbles on all three inputs and on the output: AND of the pin levels. 9 = 143.6, 10 = upper GAME row, 11 = IR.8. Out -> 132.1 | OR body, bubbles at every input and the output: AND, compatible with 7411 | agree | (4450, 3650, 4900, 4100) x2.5 |
| 6 | IC95 (both) | 5, 4 -> 6: OR body, input bubbles = NAND of /COIN & TEST (5), /INI. RESET (4). 10, 9 -> 8: AND body, output bubble = NAND of 94.8 (10) and the lower GAME row (9) | Same for both sections | agree | N-tl; (4000, 2150, 4600, 2450) x2.5 |
| 7 | IC102 | Drawn facing left. OR body, bubble on output 10 only: NOR. 9 = 95.6, 8 = 140.12 (MAX/MIN). Out 10 -> 94.13 | Left-facing NOR, 102.9 W01, 102.8 W05 -> 94.13 | agree | (3050, 1950, 4200, 2550) x1.5; (3700, 2100, 5700, 2800) x0.75 |
| 8 | IC72 | OR body, output bubble: NOR. 2 = 80.9, 3 = 107.5. Out 1 -> 108.2. Label 72 | NOR, 80.9 and 107.5 -> 108.2; IC72, not 172 | agree | (5250, 3400, 6100, 3750) x2 |
| 9 | IC108 | 4, 5 -> 6: plain OR. 1, 2 -> 3: AND body with bubbles on both inputs and the output = OR. 1 = 140.12, 2 = 72.1. Out 3 -> 140.14, 107.2 | Plain OR; bubbled AND with output bubble = OR | agree | (5250, 3400, 6100, 3750) x2; N-bm |
| 10 | IC101 (three ANDs) | 12, 13 -> 11: V5 (pad CC), 94.9. 9, 10 -> 8: 100.13, 132.15. 4, 5 -> 6: 100.5, PLAYER ST. All plain AND bodies | Same | agree | N-tl; N-bm |
| 11 | IC113 (two sections) | 1, 2 -> 3: AND body, output bubble = NAND of 107.13 (1) and V4 (2). 12, 13 -> 11: OR body, input bubbles = NAND of 113.3 (12) and 21.8 (13) -> BONUS SOUND (A) | Same | agree | N-tr; N-sound |
| 12 | IC21 | Four-input NAND 9, 12, 10, 13 -> 8. 9 = 100.13, 12 = 132.12 (QC), 10 = 132.11 (QD), 13 = V2. Out -> 113.13 | Same | agree | N-sound; N-control |

### Control nets and junctions (ledger W01-W07, W10-W13)

| # | Item | Second reading | Trace | Verdict | Crops |
|---|---|---|---|---|---|
| 13 | W01 | 95.6 -> 80.2 and 80.14 (dots on the clear drops), IR.9, 102.9 (vertical near x3892) | 95.6 -> 80.2, 80.14, IR.9, 102.9 | agree | N-tl; N-tm; (3050, 1950, 4200, 2550) x1.5 |
| 14 | W02 | IR.8 -> 81.13 (dot), row right to x≈5267, down to y≈4104, then left to 53.11 and right to 140.11 | IR.8 -> 81.13, 53.11, 140.11; turn near x5270, join near (5270, 4100) | agree | N-tm; N-centre; N-cp |
| 15 | W03 | 80.9 -> down near x≈5378 -> 72.2 only | 80.9 -> 72.2, separate vertical near x5380 | agree | N-tm; N-mm; N-centre |
| 16 | W04 | 107.5 -> dot -> C38 (680p) and riser near x≈5395 -> 72.3 | 107.5 -> 72.3 and C38, riser near x5390 | agree | N-bm; N-centre |
| 17 | W05 | 140.12 loops right/up, left along y≈3283 to a dot at x≈5730; down to 108.1, up and left along y≈2449 to 102.8 | 140.12 -> 108.1 and 102.8, dot near (5730, 3280), row near y2450 | agree | N-control; (3700, 2100, 5700, 2800) x0.75 |
| 18 | W06 | 108.3 -> dot near x≈6131 -> 140.14; drop to 107.2 | 108.3 -> 140.14 and 107.2, dot near (6130, 3580) | agree | N-control; N-cp |
| 19 | W07 | 95.8 -> row y≈2271 -> 126.1. Crosses the W02 (x≈5267) and W03 (x≈5377) verticals: thickened crossings, no dots | 95.8 -> 126.1 only; crosses W02/W03 with no dot | agree | (5150, 2180, 5500, 2360) x3; (5500, 1700, 7600, 2500) x0.65 |
| 20 | W10 | 100.13 -> dot near (3725, 3517). Up via x≈3904 to the row y≈2650 -> riser x≈6650 -> 21.9. Down via x≈3738 to the row y≈4808 -> 101.9, and on to 143.11 | 100.13 -> 21.9, 101.9, 143.11; split near (3730, 3520) | agree | (3500, 2850, 4500, 3900) x1.2; N-bl; N-bm; N-sound |
| 21 | W11 | GPR.8 -> vertical x≈2958 with C54 (1000p) dot -> up, right along y≈3196 -> 100.11 | GPR.8 -> 100.11 and C54, rise near x2950 | agree | N-bl; N-left-trunks |
| 22 | W12 | 143.6 -> dot with C57 -> up x≈4067 -> row y≈4100 -> 53.9. No branch to 101.4 | 143.6 -> 53.9 and C57 | agree | N-bm; N-centre |
| 23 | W13 | 132.15 -> right, down near x≈4819, left along y≈4337, down -> 101.10. Crosses the /GAME row (y≈4281) with no dot | 132.15 -> 101.10, drop near x4820, row near y4340 | agree | N-centre; N-bm |

### Counters

| # | Item | Second reading | Trace | Verdict | Crops |
|---|---|---|---|---|---|
| 24 | IC80 7 -> 15 | First 390/2 pin 7 runs up, over and down into the second half's left input 15 | 80.7 -> 80.15 | agree | (4500, 1250, 5450, 1550) x1.8 |
| 25 | IC80 13 -> 12 | Second half: loop from 13 to 12 (first half 3 -> 4 likewise). Output 9 | 80.13 -> 80.12 | agree | (4500, 1250, 5450, 1550) x1.8 |
| 26 | IC132 pin roles | 74161. CLK 2 = 100.4 (680p to ground); ENP 7 and ENT 10 tied, from 100.12; /CLR 1 = 53.8; data 3, 4, 5, 6 ground; QA 14, QB 13, QC 12, QD 11 -> 133.2, 5, 11, 14 (QC, QD also to IC21); RCO 15 -> 101.10. No pin 9 lead drawn | Same, including the undrawn /LOAD 9 | agree | (3500, 2850, 4500, 3900) x1.2; N-mm; N-control |
| 27 | IC140 pin roles | 74191. CLK 14 = 108.3; D/U 5 = lower GAME row through R34 220 ohm, C55 0.1u to ground on the GAME side; /CTEN 4 and data 15, 1, 10, 9 on the ground bar; /LOAD 11 = IR.8; MAX/MIN 12 = W05; QA 3, QB 2, QC 6, QD 7 -> 133.3, 6, 10, 13. Pin 13 not drawn | Same | agree | N-control; N-cp; N-centre |
| 28 | IC94 clock | 94.11 = the lower GAME row: trunk x≈3090 with a dot on that row near y≈4280, and a dot near y≈2580 to 95.9 | 94.11 = /GAME (W21) | agree | N-left-trunks; (2400, 4100, 3300, 4300) x1.5 |
| 29 | IC94 clear | 94.13 = 102.10 | 94.13 = 102.10 | agree | (3050, 1950, 4200, 2550) x1.5 |
| 30 | IC94 D | D 12 = Vcc (and /PRE 10 = Vcc). Q 9 -> 101.13, /Q 8 -> 95.10 | Same | agree | (3050, 1950, 4200, 2550) x1.5 |

### One-shot timing parts

| # | Item | Second reading | Trace | Verdict | Crops |
|---|---|---|---|---|---|
| 31 | C33 | 1 u, tantalum ("タンタル"), between 100.6 and 100.7 | 1u tantalum, 100.6/7 | agree | (3300, 2600, 3900, 2800) x2 |
| 32 | C39 | 3.3 u, tantalum, 100.14/15 | 3.3u tantalum | agree | (3300, 3150, 3900, 3350) x2 |
| 33 | C40 | 3.3 u, tantalum, 107.6/7 | 3.3u tantalum | agree | (4900, 4750, 5500, 4950) x2; (5050, 4850, 5450, 5050) x2.5 |
| 34 | C41 | 22 u, tantalum, 107.14/15 | 22u tantalum | agree | (6400, 4400, 6800, 4650) x2.5 |
| 35 | R20 | 47K, 100.15 to Vcc | 47K | agree | (3300, 3150, 3900, 3350) x2 |
| 36 | R22 | 47K, 100.7 to Vcc | 47K | agree | (3500, 2620, 3900, 2780) x2.5 |
| 37 | R23 | 47K, 107.7 to Vcc | 47K | agree | (5050, 4850, 5450, 5050) x2.5 |
| 38 | R24 | 47K, 107.15 to Vcc. Second digit of the designator read as 4 (probable); a stray mark sits above it | 47K | agree | (6550, 4250, 6900, 4450) x3 |

R21 is not on sheet N; the N trace does not place it there either. (F's trace
has an R21 on the /SLIP one-shot.)

## Sheet F (PDF page 9)

| # | Item | Second reading | Trace | Verdict | Crops |
|---|---|---|---|---|---|
| 39 | Gate 8, body | Bubbles on both inputs and on output 8. Pointed tip: OR body (probable, the drawing is faint). OR body with all bubbles = AND of the two pin levels. Output 8 -> the 5 -> 6 element (no output bubble visible, so non-inverting) -> pad A14 `/SCORE CP (I)` | OR body, two input bubbles, output bubble: AND of the two active-low streams; 8 -> B17 5 -> 6 -> A14 | agree | (6150, 2350, 7150, 2700) x1.6 |
| 40 | Gate 8, inputs | Upper input (numeral read as 10, damaged) = /BONUS POINT (N), a thin wire running down along a grid line near x≈6330. Lower input 9 = output of the two-input NAND (GS) at about (5850, 2400) | F01 /BONUS POINT -> upper input (numeral 10 vs 11 uncertain); lower = GS output | agree | (5700, 1900, 7700, 2750) x0.8; (5550, 2250, 6050, 2550) x2.4 |
| 41 | F14a, IC32 clear 2 | IC32 is a 393/2 ("32" faint), CP from pin 6 of the AOI block marked 79 (type caption 50/2 or 59/2, faint). Clear 2 goes up, right to x≈5577, down across the ACCE rows to y≈2032, left to x≈4767, down to the `/GAME (A)` row at y≈2310. So clear 2 = /GAME. **Caveat:** the vertical at x≈5580 has a gap in the ink from y≈1827 to y≈1882, across the ACCE C row; read as a scan dropout because both pieces sit on the same x and line up. If it were a real break, the upper piece would end on the ACCE D row and the lower piece would start under ACCE C with no source, so the continuous reading is the only one that gives both pieces two ends. Probable, not clear; a sharper scan of (5500, 1780, 5650, 1920) would settle it | /GAME -> IC32 clear 2, same route; crosses the four ACCE rows with no dots | agree | (4800, 1250, 5800, 1700) x1.3; (5350, 1300, 5800, 2400) x1; (5150, 1700, 5700, 2100) x2; (2000, 1950, 5400, 2400) x0.45; (900, 2200, 1700, 2400) x1.5 |
| 42 | F14b, M151 selectors | Three downward 7414 inverters. ACCE D row (y≈1820) -> 3 -> 4 -> M151 C 9; 4 also feeds a second inverter 5 -> 6 that drives the ACCE D arrows. ACCE C row (y≈1866) -> 13 -> 12 -> B 10. ACCE B row (y≈1912) -> 1 -> 2 -> A 11. ACCE A not tapped. Rows run parallel from there to the named arrows | Same | agree | (4700, 1750, 5250, 2450) x1.6; (4400, 1700, 7100, 2000) x0.55; (7000, 1650, 8200, 2100) x1 |

## Sheet A (PDF page 8)

| # | Item | Second reading | Trace | Verdict | Crops |
|---|---|---|---|---|---|
| 43 | IC59 and A29 | Plain OR body, no bubbles. 2 = IC53.12 (three-input AND), 1 = `BONUS SOUND (N)`. Out 3 -> 46 (1 -> 2, triangle, no bubble) -> pad A29 `EX. CP (S)` | A03, A04: same | agree | (8600, 1050, 9700, 1750) x1.1 |
| 44 | IC35 | OR body, bubbles on 9 and 10, no output bubble: NAND. 9 = /COIN IN row (dot near (6519, 4115)); 10 = `/BONUS CP (N)`, rising at x≈5754 to y≈4318 then right. A stretch of the input-10 row between x≈6080 and 6380 is faint; the crossings on it have no dots | A05-A07: same | agree | (5600, 4000, 7400, 4450) x0.8; (5600, 4100, 6700, 4500) x1.2; (5550, 4000, 6200, 6100) x0.4 |
| 45 | Buffer to A28 | Input 13, output bubble at 12: inverting. Out -> pad A28 `/COIN IN (S)`. Package caption unclear | A08: inverting buffer 13 -> 12 -> A28; caption "74" or "34" uncertain | agree | (6700, 4150, 7400, 4400) x2 |

## Sheet G (PDF page 10)

| # | Item | Second reading | Trace | Verdict | Crops |
|---|---|---|---|---|---|
| 46 | PLAYER ST = IC31 | IC31 1, 2 -> 3: AND body facing left, no bubbles. 1 = IC32.6 (dot at the corner). 2 = down to a dot on IC38 pin 11, the QA of the second 393 half (HC4 if pins 3-6 are HC0-HC3). Out 3 -> left along y≈4277 to x≈2840 -> down to `PLAYER ST (N)`. IC32 (AND body, four input bubbles = NOR): 4 = 38.10, 2 = 38.9, 1 = IC25 inverter of 38.8, 5 = a row near y≈5371 not followed further | IC31.3 = AND(IC32.6, IC38.11 = HC4) -> PLAYER ST; IC32 = NOR(/COIN IN, HC5, HC6, /HC7) | agree | (2600, 4050, 4500, 5000) x0.7; (3500, 4150, 4400, 5200) x1.1; (3500, 5000, 4400, 5400) x1.4; (2650, 4200, 3000, 4400) x2 |

## Other observations (not in the item list)

1. **GAME pair caption on N.** On N alone, the overbar between the two
   `GAME` captions sits about midway between them; I could not tell from N
   which caption it belongs to. Crop (2400, 4100, 3300, 4300) x1.5. The trace
   settles it with sheet A (IC47 /Q 8 labelled `/GAME`, arrows `GAME (N)` and
   `/GAME (N)(F)`); I confirmed those A labels exist,
   (6900, 2200, 7500, 2380) x2, (6900, 3650, 7700, 3850) x2,
   (5300, 3350, 6200, 3950) x1, but did not follow the A wires to the arrows.
   Not a disagreement, but the N reading on its own does not settle it.
2. **PLAYER ST waypoint.** `BONUS_INPUTS_TRACE.md` puts the turn of the
   IC31.3 wire at x≈2735; I read the corner at about (2840, 4277),
   crop (2650, 4200, 3000, 4400) x2. Only a navigation waypoint; the
   connection is the same.
3. **F output element 5 -> 6.** No output bubble is visible, so it is
   non-inverting, as the trace says. The digits above it read as "19" or
   "14"; the trace has "probable 19".
4. **F GS lower input.** The vertical that feeds the lower input of the
   normal-score NAND shows thickened blobs where it crosses two rows near
   y≈2475 and y≈2515 at x≈5755, crop (5550, 2250, 6050, 2550) x2.4. The F
   trace (F03) already warns against reading these as joins; I agree they
   look like crossings, but the scan does not settle it.

## Not checked

- Everything outside the 46 items: IC133 and IC126 on N, the F normal-score
  source chain (GS inputs, M151 data and strobe, the IC79 AOI clock select), the
  rest of A and G, sheets I, K and M.
- The behaviour derived in the traces (payout count, U5 race, pulse widths).
  Only the drawn wiring was compared.
- Package identities that the traces leave uncertain (IR/IP, GPR, IC81's
  body label, B17, the A28 buffer).
- The RTL from #71 was deliberately not read.
