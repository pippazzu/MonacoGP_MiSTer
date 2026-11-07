# Sheet A — coin, start, game timer and extended-play control

Source: Sega **Monaco GP (420-0358)**, PDF page **25**, drawing **A**, board
**96577-P**, sheet **D-1/4**, "IC BOARD ASS'Y, A" (title also carries the
Japanese caption スタート・タイマー・コントロール, start/timer control).
Transcribed from the supplied `sheets/page25-sheet-A.png`, **10160 × 6624**
pixels, upright. Source PNG SHA-256:
`be4bf1a576d1e4e611462c8f28bde27ff0aeb204d9c5ea5aed08f2fad81f0c2c`.

**Status: whole-sheet transcription, consolidated into one scan-checked pin
list on 29 October 2026 (next section).** Every pin-to-pin claim below was made by following the ink on
full-resolution crops, assisted by the net-extraction tools in
`reference/tools/schematic/` (netx/q/near/dotsize); long-wire junctions were
measured with `dotsize.py` (on this sheet a drawn junction dot measures about
22–34 px, a plain crossing 8–19 px; everything in the 15–19 px band was also
checked by eye). Rows marked **uncertain** must not be used as settled facts;
each is listed under "Unresolved". No ROM contents, emulator, other core or
remembered gameplay was used to fill gaps.

The comparison with stonedDiscord's KiCad redraw (board 96577) prescribed by
START_HERE has **not** been performed for this sheet yet; it is left for the
review pass (see Unresolved, last item).

## Consolidated netlist, 29 October 2026

This section supersedes the pin tables further down where they differ.

### How it was made

1. The pad nets of stonedDiscord's redraw of board 96577 (`Main.kicad_pcb`)
   were listed for every package drawn on this sheet. The redraw was used
   only to predict connections, as before.
2. Every net of that list was followed on the scan, region by region. These
   are the boxes, in the stored image:
   - timer: (950,950,3650,2450), loads (2300,2050,3300,2250), 555 parts
     (950,1150,1450,1950);
   - coin inputs: (1200,2350,3700,4400), switches (1550,3150,2000,4300),
     changeover switch (2750,2950,3750,3400);
   - clear nets: (3350,2850,4250,5700), (3550,4950,4400,5650),
     (3900,2550,4250,3300);
   - tilt: (1150,4950,3950,6000);
   - game and master clear: (3400,2700,6700,5300);
   - extend: (3400,850,6300,3200), (5900,850,8900,3900);
   - lower outputs: (2550,4600,7400,6100).
   Doubtful crossings were measured with `dotsize.py`: dots on this sheet
   measure 22–34 px, crossings 8–19 px.
3. The redraw agrees with the scan everywhere except IC32 pins 11 and 12
   (below). Where the trace tables below disagree with the scan, the scan
   reading is given here. Pin numerals were not all re-read; standard
   pinouts were assumed where the drawn function agrees.

### Corrections to the tables below

- **Switch contacts (U7).** On the CREDIT, TEST and COIN switches the arm
  is drawn resting on the upper contact. On the COIN switch it is a long
  slanted line from the common bar to that contact; on the other two it is
  a short stroke at it. So the upper contacts (pads AQ?, Ab, Aa, to the
  latches' /S inputs) are closed at rest, and the lower ones (A32, A24, A23,
  to /R) close when the switch is pressed. Each latch is set at rest and
  reset while its switch is pressed. This replaces the 23 October reading
  ("make contact on /S"). The printed 5 and 6 on the coin latch stay a
  numeral slip; the function does not depend on it.
- **IC33 /Q (8) goes to IC72 pin 9 only, not to the timer CLEAR.** From pin
  8 the wire runs east to x≈4120 and up x≈4120 to the corner (4120,2700),
  then west along y≈2700 to IC72.9. It crosses the y≈5088 line (12.8 px) and
  the y≈3190 line without a dot. The dots (4004,5085) and (4035,3192) are on
  the separate x≈4000 vertical.
- **The timer CLEAR (TCLR) is driven by the tilt one-shot's Q (13) alone.**
  The net is IC21.14, IC20.14, the x≈4000 vertical, the MUTE buffer
  (y≈5085), IC74.9 and, at the corner (4000,5490), the y≈5490 line from the
  tilt Q. The changeover switch's 1-play contact carries only the 1 kΩ
  pull-up and does not join it.
- **The tilt one-shot is IC38's first half** (as the redraw has it). Its
  /Q (4) runs along y≈5590 to IC33 /CLR (dot (3833,5600)). From there it
  goes on east, up x≈4830 and east along y≈5020 to pads AR "/INI. RESET
  (I)" and BA "/INI RESET (B)". The IC33 /CLR vertical crosses the Q line at
  (3830,5482): 15.2 px, a crossing (a join would tie Q to /Q).
- **IC12 is a two-input NAND**: 10 ← Vs/16, 9 ← IC72.10. Its output 8
  drives 220 Ω and the LED.
- **IC32 pin 11 (credit latch /S1) ← IC72.10**, through the dot (2290,2680)
  and the x≈2290 drop. Pin 12 (/S2) is the CREDIT switch's own input. The
  redraw puts pins 11 and 12 on one net; the scan has them separate.
- **The changeover switch** (SW1 in the redraw): its common goes to IC33
  CK (11) and IC125.3. The 1-play contact is the 1 kΩ pull-up; the 2-play
  contact is the credit latch Q (IC32.9).
- **IC50 (pins 8–13, EXTEND)**: pin 11 (CK) is a bare stub. The flip-flop
  is set only through /PR (10), from IC55b.6.
- **ACCE. ST. is an input from sheet F** (sheet F IC34 pin 6) to IC37b CK
  (11), the GAME flip-flop's clock.
- The /EX. SIGNAL CP label at pad B2 carries an overbar.

### Pin list

| IC | Part | Connections |
|---|---|---|
| 26 | 555 | 4 RESET ← GAME; 7 DIS between VR1 + R5 3.3 kΩ (from Vcc) and R4 (12 kΩ in the redraw, faint on the scan) to 6 and 2; 6, 2 ← C5 47 µF to GND; 5 ← C4 0.1 µF; 3 → 22.4 |
| 22 | 7408 | 4 555.3, 5 20.13 (/BO) → 6 → 21.4; 12 CT, 13 MCLR → 11 → 50.1, 50.13 |
| 21 | 74192 | 5 Vcc, 4 22.6, 13 → 20.4; 11 /LOAD = CT; 14 CLR = TCLR; A–D (15, 1, 10, 9) GND; QA–QD (3, 2, 6, 7) → switch block → pads (J), T1 |
| 20 | 74192 | 5 Vcc, 4 21.13, 13 /BO → 22.5, 55.5, 61.11; 11 CT; 14 TCLR; A 15 Vcc, B 1 GND, C 10 GND, D 9 Vcc (9); QA–QD → pads (J), T2 |
| 32 | 74279 | credit: /S1 11 ← 72.10, /S2 12 ← CREDIT upper (CR), /R 10 ← CREDIT lower (CR), Q 9 → SW1 2-play contact; test: /S1 3 + /S2 2 ← TEST upper (CR), /R 1 ← TEST lower (CR), Q 4 → 125.4; coin: /S (drawn 5) ← COIN upper (CR), /R (drawn 6) ← COIN lower (CR), Q 7 → 125.5, 33.10, 44.5 |
| 125 | 7411 | 3 SW1 common, 4 32.4, 5 32.7 → 6 CT (/COIN & TEST) → 37.3, 21.11, 20.11, 22.12, 31.3 → Ad (I), 73.1 |
| 73 | 7404 | 1 CT → 2 → 79.2, 73.3, 55.9; 3 → 4 /COIN & TEST (F); 13 79.3 → 12 → R15 220 Ω → C25 1000 pF → 55.1 |
| 37 | 7474 | a: PR 4, D 2 Vcc, CK 3 CT, CL 1 MCLR, Q 5 COIN IN (B1 (B)) → 37.12, 72.8; /Q 6 /COIN IN (BD (B), (G)) → 31.11 → A28 (S). b: D 12 COIN IN, CK 11 ACCE. ST. (F), CL 13 MCLR, Q 9 GAME → 26.4, 31.5 → A27 (I); /Q 8 /GAME (B6 (B), (F)) → 55.13, 31.9 → AE (S) |
| 72 | 7402 | 9 33.8, 8 37.5 → 10 → 12.9, 32.11 |
| 12 | 7400 | 10 Vs/16, 9 72.10 → 8 → 220 Ω → LED → Vcc |
| 33 | 7474 | PR 10 32.7, D 12 GND, CK 11 SW1 common, CL 13 tilt /Q, /Q 8 → 72.9 (Q 9 not drawn) |
| 38 | 74123 | tilt: A 1 ← tilt input (D1 SiB01-02 from pad AJ, RA1 560 Ω pull-up, RA2 100 Ω, C12 0.01 µF, R7 100 kΩ pull-up, C14 "47"), B 2 and CL 3 Vcc, R9 47 kΩ, C19 470 µF, Q 13 → TCLR, /Q 4 → 33.13, /INI RESET (AR (I), BA (B)); hiscore: A 9 MCLR, B 10 EXTEND, CL 11 Vcc, R8 47 kΩ, C15 0.1 µF, /Q 12 → 31.13 → AF /HISCORE (S) (Q 5 not drawn) |
| 74 | 7427 | 11 GAME OVER (B16 (M)), 9 TCLR, 10 61.13 → 8 MCLR → 37.1, 37.13, 38.9, 22.13 |
| 61 | 7402 | 11 20.13, 12 50.5 → 13 → 74.10; 5 55.6, 6 (R14/C27 node) → 4 → 55.10 |
| 50 | 7474 | earned: D 2 Vcc, CK 3 /EX. SIGNAL CP, CL 1 22.11, Q 5 → 61.12, /Q 6 → 55.4 (PR 4 not drawn); EXTEND: D 12 Vcc, CK 11 stub, PR 10 55.6, CL 13 22.11, Q 9 EXTEND ((F), BB (C), 38.10), /Q 8 /EXTEND ((G), B3 (C)) |
| 55 | 7432 | b: 4 50.6, 5 20.13 → 6 → 50.10, 61.5, 44.9; a: 10 61.4, 9 73.2 → 8 CAR CONT. CL (H); c: 12 79.3, 13 /GAME → 11 → 55.2; d: 2 55.11, 1 R15/C25 node → 3 /EX. SIGNAL CP (B2 (M)) → 49.1, 50.3 |
| 44 | 7404 | 9 55.6 → 8 → R14 220 Ω → C27 1000 pF → 61.6; 5 32.7 → 6 → R1 560 Ω → TR1 C1384 → A9 coin meter |
| 49 | 74123 | A 1 /EX. SIGNAL CP, B 2 and CL 3 Vcc, R13 47 kΩ, C24 100 µF, Q 13 → 85.2, /Q 4 → C1 /EX. SIGNAL (B) |
| 85 | 7411 | 13 V2 (pad C6, (E)), 1 Vs/16 ((H)), 2 49.13 → 12 → 29 13→12 → A29 EX. CP (S) |
| 79 | 74393 half | CP 1 ← A30 (R6 1 kΩ pull-up, 470 pF), MR 2 ← 73.2, QA 3 → 55.12, 73.13; QD 6 → 8000 (F) |
| 31 | 7407 | 1 TCLR → 2 MUTE (A26 (S)); 3 CT → 4 Ad (I); 5 GAME → 6 A27 (I); 9 /GAME → 8 AE (S); 11 /COIN IN → 10 A28 (S); 13 38.12 → 12 AF (S) |

## Reading conventions

- Coordinates are `(x, y)` or boxes `(x0, y0, x1, y1)` in pixels of the
  supplied PNG, origin top left.
- `/NAME` transcribes an overbar. Circled sheet letters are `(B)`, `(C)` etc.
- A dot is a junction; crossings without a dot are separate. The scan is
  skewed by roughly 1 px in 70 px (left to right, downward), so long rows
  drift; wires were followed, not counted by position.
- Gate functions are taken from the drawn body and bubbles, not the designator.
  Small gates carry only an IC number, no part type; a compatible standard
  74xx pinout is named as a comparison, not a recovered marking.
- `ICn.p` is pin p of IC n. Net names in capitals (`SEC`, `GAME`, `MCLR`,
  `TCLR`, `CP`, `CT`) are **local transcription aliases**, not printed labels.
- `not drawn` is distinct from tied or proven unconnected.
- Edge pads are drawn two ways (noted by Andrea, 23 Oct): squares with an X
  (the A-prefixed pads — cabinet/harness side) and plain squares (the B/C
  prefixed pads — board-to-board).

## Crops used

The whole-sheet overview `(0,0,10160,6624)` at 0.14 was used only to locate
blocks. Main reading crops (all on `sheets/page25-sheet-A.png`):

| Crop box | Contents |
|---|---|
| (950,950,2250,2700) | 555 block IC26, LED column |
| (2100,900,3700,2500) | IC21/IC20 timer counters, preset switches |
| (2250,1020,3250,1560) | switch blocks, pads A15–A18, T1-A/T2-A |
| (3600,850,5200,2300) | IC50 both halves |
| (5200,850,7100,1800) | CAR CONT CL pulse chain (IC73a, IC61a, IC55a) |
| (6900,950,8600,2300) | IC49, IC85, C6, C1, EX outputs |
| (8060,1040,8620,1720), (8540,1380,9150,1750) | C6/V2, IC85 pins, IC29 buffer, A29 |
| (5600,1900,7300,2700), (7300,1900,8600,3000), (8400,1900,9000,3250) | EXTEND outputs, right-edge labels |
| (4000,1900,5400,3000), (2020,2380,2520,2820), (2200,2620,2800,2880) | IC55b, IC22b, IC12, IC72 |
| (5700,2900,7300,4000) | IC79, IC55c/d, IC73b/c, GAME(B), /COIN&TEST(F) |
| (4600,2800,6000,4600) | IC61b, IC74, IC37b |
| (7200,3200,8600,4100) | IC38, IC31b, AF |
| (1300,2900,3000,4600), (1550,3050,2500,4350) | switches, CR networks, IC32 latches |
| (2900,3300,4600,4600), (3040,3600,3430,3810), (3180,4180,3450,4820) | IC37a, IC125 |
| (3050,3020,3750,3340) | 1 coin 1 play / 2 play changeover switch |
| (3550,4900,4750,5700) | IC33 and surrounding rails |
| (1300,4400,2700,5300) | CR definition |
| (1300,5000,3200,6200) | ANT/TILT, D1, tilt 74123 |
| (5200,4900,7000,6100), (5800,3900,7300,5300) | output buffers/pads, coin meter |
| (3420,5560,3760,6350), (4450,5800,4850,6420) | bottom-edge ACC.ST, B16 GAME OVER |

Narrow verification strips (junction adjudication): (3000,2300,3230,4150),
(3400,1500,3640,3350), (3930,2550,4260,5400), (4520,3180,4720,4450),
(4540,3330,4740,3740), (5450,2900,5890,3480), (5400,4650,5800,5150),
(5180,3650,5700,4150), (5800,4080,6080,4500), (6350,4120,6780,4420).

## Signal path in brief

Derived only from the transcribed wiring; no gameplay knowledge added.

1. **Coin/credit/test inputs.** Three cabinet switches arrive through edge
   pads and identical CR filter networks (560 Ω pull-up, 100 Ω series,
   0.1 µF to ground) into three latches of IC32 (279/4, 74279): CREDIT
   (latch 3), TEST (latch 1), COIN (latch 2).
2. **Coin acceptance.** IC125 (7411 AND, section 3,4,5→6) combines latch
   outputs and clocks IC37a (74/2, 7474 half; D = PR = Vcc). IC37a.Q (pin 5)
   is the **COIN IN** level (pad B1 to sheet B); /Q (pin 6) is **/COIN IN**
   (pad BD to B, buffered to A28 "(S)" and an arrow to (G)).
3. **Game flip-flop.** IC37b (second half of IC37): D (12) ← IC37a.Q,
   Q (9) = **GAME** (pad-less rail; buffered to A27 "GAME (I)"; also resets
   the 555 and the EXTEND logic), /Q (8) = **/GAME** (labelled /GAME on the
   sheet; to B6 "(B)", an arrow "(F)", and buffered to AE "(S)").
4. **Master clear.** IC74 (7427-type NOR, 9,10,11→8) output clears IC37a,
   IC37b and IC33 and triggers IC38. Its inputs: 9 ← IC61b output, 10 ← the
   timer-clear net, 11 ← "GAME OVER" net (pad B16, circled M).
5. **Game timer.** IC26 (555) free-runs only while its reset (4) is released
   by GAME; its output (SEC alias) feeds the down-count chain IC21 → IC20
   (192 = 74192, CPD cascade through /BO). Presets: IC21 = 0, IC20 = 9
   (load value 90). Counter outputs QA–QD of both packages leave through
   4+4 switches (AS–AT, AU–AV) to pads A15/A16 (tag T1-A) and A17/A18
   (tag T2-A) — the external time display. The shared CLEAR (both pin 14)
   is the **TCLR** net driven by IC33./Q.
6. **Credit memory / 2-play.** IC33 (74/2 second half, pins 8–13; D (12) =
   GND, PR (10) ← coin-pulse rail, CK (11) ← 2-play line, CL (13) ← master
   clear rail). Its /Q (8) is the TCLR net (holds the timer cleared) and the
   MUTE line (A26 "(S)" through a buffer).
7. **Coin pulse rail (CP).** Pad A30 (R6 1 kΩ pull-up; cabinet wire marked
   "S-100-D", uncertain) joins IC79's clock (pin 1, 393/2 = 74393 half,
   470 pF on the pin), rises to a top rail feeding IC55c.12, and drives the
   COIN METER transistor TR1 (C1384) through inverter "44".5→6 and R1 560 Ω.
   The meter coil hangs from Vcc at pad A9.
8. **Extended play.** IC79 (coin counter, MR ← inverted /COIN&TEST) counts
   coin pulses; gates IC55c/IC55d with IC73b + R15 220/C25 1000p make an
   edge pulse that fires IC49 (123/2 = 74123 half, 100 µF/47 kΩ ≈ 1.3 s)
   and leaves as "EX.SIGNAL CP" (pad B2, circled M). IC49.Q qualifies
   IC85 = AND(V2 via pad C6, Vs/16 arrow, Q) → buffer ("29", 13→12) →
   pad A29 "EX.CP (S)"; IC49./Q leaves as "/EX.SIGNAL" (pad C1, to B).
   IC50a (74/2) is the EXTEND flip-flop: Q (9) = EXTEND (arrow "(F)", pad
   B8 "EXTEND (C)", and IC38.B), /Q (8) = /EXTEND (arrow "(G)", pad B3
   "/EXTEND (C)"). IC38 (123/2, 0.1 µF/47 kΩ ≈ 1.3 ms) is triggered by the
   master clear on A and EXTEND on B; its /Q (12) is buffered (IC31, 13→12)
   to pad AF "/HISCORE (S)".
9. **Start pulse.** The CAR CONT CL chain: IC55b (OR) output feeds IC50a.PR
   and, through IC73a (9→8) + R14 220/C27 1000p and IC61a (NOR 5,6→4) and
   IC55a (OR 10,9→8), produces the "CAR CONT CL (H)" arrow — an edge pulse.
10. **Tilt.** ANT (antenna/pendulum) and TILT SW arrive at pads AJ/A31;
    D1 (SB01-02), RA1 560/RA2 100/C12 0.01 µ filter and R7 100k/C14 feed a
    74123 half (designator not readable; C19 470 µF/R9 47 kΩ ≈ 6 s pulse).
    Its outputs join the clear/mute region (exact taps uncertain).
11. **Housekeeping outputs.** INI.RESET (pads AR "/INI.RESET (I)" and BA
    "INI RESET (B)"), MUTE (S) at A26, ACC.ST arrow down to (F), GAME OVER
    pad B16 marked (M), δOCC-like arrow to (F) (label unresolved).

## Pin tables

Confidence: **clear** = legible and followed on the scan; **uncertain** = see
Unresolved.

### IC26 — 555 timer (printed "555", designator 26)

| Pin | Net | Connection | Confidence |
|---|---|---|---|
| 7 (discharge) | | on the Vcc-side divider: Vcc → trimmer (drawn with a diagonal arrow, label unclear; redraw has RV1) → R5 3.3K → R4 2K? → C5 47µ? → GND (chain read by Andrea, 23 Oct; which node carries pin 7 vs 6/2 still per this trace's reading: pin 7 above, pins 6/2 below) | values partly uncertain (U25) |
| 6 (threshold) | | tied with pin 2 and C5 (47µ?, electrolytic) to GND | clear (value uncertain) |
| 2 (trigger, bubble) | | tied to pin 6 node | clear |
| 5 (control) | | C4 0.1µ to GND | clear |
| 3 (output) | SEC | → IC22 pin 4 (AND section "IC22a"; settled by Andrea's reading on the scan, 23 Oct). The earlier reading of this trace — 555.3 running east as the y≈2330 rail — was wrong; that long rail is IC20./BO (see the comparison section) | clear |
| 4 (reset, bubble, top) | GAME | y≈1290 rail; joined at x≈1905 riser from the GAME rail (y≈2440) | uncertain (U1) |
| 1, 8 | | not drawn | clear |

### IC21, IC20 — game-time down counters (printed "192", 74192 pinout)

| Part / pin | Net | Connection | Confidence |
|---|---|---|---|
| IC21.5, IC20.5 (CPU) | Vcc | both tied high | clear |
| IC21.4 (CPD) | | ← IC22a pin 6 (AND output; enters straight on the left side — settled by Andrea's reading, 23 Oct). IC22a = AND(555.3 on pin 4, pin 5 source see U1) | clear |
| IC21.13 (/BO) | | → IC20.4 (CPD): cascade | clear |
| IC20.13 (/BO) | | (bubbled) → the long y≈2330 rail: IC22a.5, IC55b.5, IC61b.11 (settled by Andrea's reading, 23 Oct) | clear |
| IC21.11, IC20.11 (/LOAD) | | tied together through the y≈2410–2450 loop below the packages; loop continues west | uncertain (U2) |
| IC21.15,1,10,9 (A–D) | GND | all four to ground (preset 0) | clear |
| IC20.15 (A) | Vcc | preset 1 | clear |
| IC20.1, IC20.10 (B, C) | GND | shared ground tie (dot at ≈(3010,2155)) | clear |
| IC20.9 (D) | Vcc | preset 1 → IC20 loads BCD 9; the pair reloads 90 | clear |
| IC21.14 + IC20.14 (CLR) | TCLR | tied via the y≈1609 rail (dot at (3512,1854)) and the x≈3505 vertical down to the y≈3196 line: 1-coin-1-play switch throw, IC74.10, and IC33./Q8 via the x≈4015 vertical (dots (4035,3192), (4004,5085)) | clear |
| IC21.3,2,6,7 / IC20.3,2,6,7 (QA–QD) | | up through the 4-switch blocks AS…AT / AU…AV to pads: left block tag "T1-A", pads A15, A16 (+2 unlabelled); right block tag "T2-A", pads A17, A18 (+2 unlabelled); the brace over both blocks is marked circled **J** (Andrea, 23 Oct) — the time digits to the display board, matching sheet J's T1-A..D/T2-A..D inputs | clear; two pad labels still unread (U3) |
| IC21.12, IC20.12 (/CO) | | not drawn | clear |

The four switch-column crossings of the y≈1609 rail measure 15–20 px with no
round blob: crossings, not joins.

### IC22a — timer clock gate (AND body, round tip, flat base; package 7408 with IC22b)

| Pin | Net | Connection | Confidence |
|---|---|---|---|
| 4 | SEC | ← IC26 (555) pin 3 | clear (Andrea, 23 Oct) |
| 5 | /BO | ← IC20.13 rail (shared with IC55b.5, IC61b.11) | clear (Andrea, 23 Oct) |
| 6 (out) | | → IC21 pin 4 (CPD): the timer decrements on 555 pulses while /BO is high and stops when IC20 borrows | clear (Andrea, 23 Oct) |

### IC32 — input latches (printed "32" with "279/4", 74279)

| Latch / pin | Net | Connection | Confidence |
|---|---|---|---|
| L3 /S1 (11) | | wire west then up the x≈2385 vertical (destination not traced) | uncertain (U4) |
| L3 /S2 (12) | | ← CR ← pad "A?" (letter unreadable, perhaps AQ; Andrea could not read it either) ← CREDIT SW make contact | uncertain label (U5) |
| L3 /R (10) | | ← CR ← pad A32 ← CREDIT SW break contact | clear |
| L3 Q (9) | | east along y≈3280/3300 to the changeover-switch common (T at ≈(3215,3293)) | clear |
| L1 /S1+/S2 (3,2) | | tied; ← CR ← pad Ab (Andrea, 23 Oct; this trace's "A8" was wrong) ← TEST SW make | clear |
| L1 /R (1) | | ← CR ← pad A24 ← TEST SW break | clear |
| L1 Q (4) | | east to x≈2641, down to the y≈4865 rail (IC33.PR / A30 region) | uncertain (U6) |
| L2 /S (drawn pin 5) | | ← CR ← pad Aa (read by Andrea) ← COIN SW make | **drawn 5 = /R2 in the standard pinout** (U7) |
| L2 /R (drawn pin 6) | | ← CR ← pad A23 ← COIN SW break | **drawn 6 = /S2 standard** (U7) |
| L2 Q (7) | | → IC125.5 | clear |

Switch commons: CREDIT common → GND symbol directly; TEST common → unlabelled
pad → GND; COIN common → pad AZ → GND (letter pin, not "A2"; Andrea, 23 Oct). Each CR box is the network
defined at (1600,4620)-(2450,4980): Vcc —RA 560— node —RA 100— output,
0.1 µF from output to GND.

### IC125 — coin AND (printed "7411", designator 125; section 3,4,5→6)

OR body with bubbles on all three inputs and the output = AND (De Morgan).

| Pin | Net | Connection | Confidence |
|---|---|---|---|
| 3 | | ← the x≈3085 vertical (dots (3085,2390), (3083,2600)): branch of the SEC rail region and the y≈2600 line to IC22b.12; the same vertical ends at the gate | uncertain (U8) |
| 4 | | from the west (1-seg stub; source not traced) | uncertain (U8) |
| 5 | | ← IC32 L2 Q (7) | clear |
| 6 (out) | | → dot (3141,4035) → IC37a.CK (3) | clear |

### IC37 — coin and game flip-flops (printed "37", "74/2" twice; 7474)

| Half / pin | Net | Connection | Confidence |
|---|---|---|---|
| a: PR (4) | Vcc | via dot (3130,3715) | clear |
| a: D (2) | Vcc | same dot | clear |
| a: CK (3) | | ← IC125.6 | clear |
| a: CL (1) | MCLR | bubble → down x≈3310 → corner (3310,4660) → east, joining the x≈4800 branch of the IC74.8 net | clear |
| a: Q (5) | COIN.IN | dot (3545,3943): → IC37b.D (12) along y≈3850; → y≈4285 rail → pad B1 "COIN IN (B)"; → y≈2780 rail (x≈3793 riser, dot (3789,3847)) → IC72.8 | clear |
| a: /Q (6) | /COIN.IN | y≈4420 rail → pad BD "/COIN IN (B)"; branch x≈6460 (dots (6463,4432),(6459,4555)) → IC31d.11→10 → pad A28 "/COIN IN (S)"; arrow "/COIN IN (G)" | clear |
| b: CL (13) | MCLR | ← dot (5137,3660) on the IC74.8 line | clear |
| b: D (12) | COIN.IN | ← Q5 line | clear |
| b: CK (11) | | ← y≈3990 line from the west (source not traced) | uncertain (U9) |
| b: Q (9) | GAME | dot (5395,3878): → x≈5405 up to the y≈2440 GAME rail (west to the x≈1905 riser toward the 555 reset and the IC12 region); → y≈3880 → x≈6170 → IC31a.5→6 → pad A27 "GAME (I)" | clear |
| b: /Q (8) | /GAME | labelled "/GAME"; y≈4010 line → arrow "/GAME (F)"; x≈6476 riser (dots (6479,3464),(6469,4011)) → pad B6 "/GAME (B)" and IC55c.13; branch → IC31f.9→8 → pad AE "/GAME (S)" | clear |

### IC74 — master-clear NOR (designator 74; 3-input, 7427 pinout 9,10,11→8)

OR body, no input bubbles, bubble on output.

| Pin | Net | Connection | Confidence |
|---|---|---|---|
| 9 | | ← IC61b.13 (NOR output, from above) | clear |
| 10 | TCLR | ← y≈3196 line (timer CLEAR net) | clear |
| 11 | | ← y≈3285 line ← x≈4615 riser ← pad B16 "GAME OVER (M)" | clear |
| 8 (out) | MCLR | dot (5137,3660): y≈3660 line → IC38.A (9); x≈4800 branch (dot (4801,3651)) down to y≈4660/4700 → IC37a.CL; → IC37b.CL; rail y≈5600 (corner up at x≈4822) → IC33.CL (dot (3833,5600)); ACC.ST arrow hangs from this rail at x≈3545 | clear; ACC.ST tap uncertain (U10) |

### IC61 — NOR package (designator 61; two sections seen)

| Section | Form | Connection | Confidence |
|---|---|---|---|
| a: 5,6→4 | AND body, bubbles on inputs = NOR | 5 ← y≈1000 rail (IC55b.6 net); 6 ← R14/C27 node; 4 → IC55a.10 | clear |
| b: 11,12→13 | AND body (pointing down), bubbles on inputs = NOR | 11 ← IC20./BO rail (settled by Andrea, 23 Oct); 12 ← IC50b.Q5 drop (redraw-supported, scan check pending); 13 → IC74 | 11 clear; 12 uncertain (U11) |

### IC55 — OR package (designator 55; four sections)

Section a is a plain OR body; the other sections are AND bodies with bubbles
on every input (and, where visible, the output), i.e. the same OR function by
De Morgan. One output bubble (b) and the whole of section d are not cleanly
legible (U12).

| Section | Pins | Connection | Confidence |
|---|---|---|---|
| a | 10, 9 → 8 | 10 ← IC61a.4; 9 ← riser x≈6455 from the y≈1400 line (from the x≈5720 vertical); 8 → arrow "CAR CONT CL (H)" | clear; pin-9 source uncertain (U13) |
| b | 4, 5 → 6 | bubbles on both inputs and the output confirmed (Andrea, 23 Oct) = OR. 4 ← y≈2120 line east (redraw: IC50b./Q6; scan check pending); 5 ← IC20./BO rail (dot ≈(4642,2352); settled by Andrea); 6 → west/up x≈4346 to the y≈1000 rail: IC50a.PR (10), inverter .9 (see U19 note on 73-vs-44), IC61a.5 | 5 clear; 4 uncertain (U14) |
| c | 12, 13 → 11 | 12 ← CP top rail (y≈2955); 13 ← /GAME riser x≈6476; 11 → IC55d.2 | clear |
| d | 2, 1 → 3 | 2 ← IC55c.11; 1 ← R15/C25 node (IC73b.13→12 ← CP rail?, R15 220, C25 1000p to GND); 3 → x≈7435 vertical: IC49.A (1) and pad B2 "EX.SIGNAL CP (M)" (dot (7435,3085)) | uncertain (U12, U15) |

### IC22b — gate 12,13→11 (designator 22)

OR body, bubbles on inputs and output = AND.

| Pin | Net | Connection | Confidence |
|---|---|---|---|
| 12 | SEC | ← y≈2600 line from the x≈3085 vertical (SEC branch) | uncertain (U8) |
| 13 | | ← from below-left (not traced) | uncertain (U16) |
| 11 (out) | | → riser ≈x4755 → the y≈1690 CL rail: IC50a.CL (13) and IC50b.CL (1) (dots (3935,1676), (4826,1687)) | clear |

No other section of IC22 was found on this sheet (an earlier candidate at
(2200,2250)-(2350,2430) proved to be the IC21 ground tie).

### IC50 — extend flip-flops (printed "50" and "74/2" on both halves; 7474)

| Half / pin | Net | Connection | Confidence |
|---|---|---|---|
| a: D (12) | Vcc | | clear |
| a: PR (10) | | ← y≈1000 rail (IC55b.6 net) | clear |
| a: CK (11) | | ← from the west (y≈1455; source not traced) | uncertain (U14) |
| a: CL (13) | | ← y≈1690 CL rail (IC22b.11) | clear |
| a: Q (9) | EXTEND | riser x≈4170 down to (4166,2290), east rail → arrow "EXTEND (F)", pad B8 "EXTEND (C)", and x≈5527 riser (dot (5534,2304)) down to IC38.B (10) | clear |
| a: /Q (8) | /EXTEND | → arrow "/EXTEND (G)" and pad B3 "/EXTEND (C)" (both labels carry the overbar) | clear |
| b: D (2) | Vcc | "Vcc 2" | clear |
| b: CK (3) | | ← loop from below (drawn as a wire turning under the package); source not traced | uncertain (U17) |
| b: CL (1) | | ← y≈1690 CL rail | clear |
| b: Q (5) | | → east y≈1210, down x≈5240 to ≈(5240,3004) (consumer not identified) | uncertain (U17) |
| b: /Q (6) | | → east, down x≈5080, to the y≈2010 region (consumer not identified; possibly IC61b.11) | uncertain (U11, U17) |

### IC49 — extend one-shot (box with A/B/CL/Q//Q, printed "123/2"; 74123 half, pins A=1, B=2, /CLR=3, Q=13, /Q=4, Cext=14, RCext=15)

| Pin | Net | Connection | Confidence |
|---|---|---|---|
| 1 (A, bubble) | | ← corner from x≈7435 ← IC55d.3 | uncertain (U15) |
| 2 (B) | Vcc | tied; the same node loops to pin 3 | clear |
| 3 (/CLR, bubble) | Vcc | via the loop | clear |
| 14–15 | | C24 100µ between them; R13 47K from Vcc to 15 (tw ≈ 0.28·47k·100µ ≈ 1.3 s) | clear |
| 13 (Q) | | → y≈1620 → IC85.2 | clear |
| 4 (/Q) | | → right, down x≈8100, west to pad C1 → "/EX.SIGNAL (B)" | clear |

### IC85 — extend-lamp AND (designator 85; 3-input AND body, 7411-type)

| Pin | Net | Connection | Confidence |
|---|---|---|---|
| 13 | V2 | ← pad C6, label "V2" (vertical counter bit V2 from sheet E, board 96578) | uncertain (U18) |
| 1 | Vs/16 | ← arrow labelled "/Vs/16"-like; reads Vs/16 (from sheet H) | uncertain (U18) |
| 2 | | ← IC49.13 (Q) | clear |
| 12 (out) | | → buffer "29" (13→12, triangle with output bubble) → pad A29 → "EX.CP (S)" | clear; buffer designator uncertain (U19) |

### IC38 — hiscore one-shot (printed "123/2"; 74123 second half, A=9, B=10, /CLR=11, Q=5, /Q=12, Cext=6, RCext=7)

| Pin | Net | Connection | Confidence |
|---|---|---|---|
| 9 (A, bubble) | MCLR | ← y≈3660 line (IC74.8) | clear |
| 10 (B) | EXTEND | ← y≈3770 line ← x≈5527 ← EXTEND rail | clear |
| 11 (/CLR) | Vcc | | clear |
| 6–7 | | C15 0.1µ between them; R8 47K from Vcc to 7 (tw ≈ 1.3 ms) | clear |
| 5 (Q) | | short stub right; no connection found | uncertain (U20) |
| 12 (/Q) | | → IC31b (13→12, bubbles both sides) → pad AF → "/HISCORE (S)" | clear |

### IC79 — coin counter (box QA A B C D / CP / CL, printed "393/2"; 74393 half: CP=1, MR=2, QA..QD=3,4,5,6)

| Pin | Net | Connection | Confidence |
|---|---|---|---|
| 1 (CP) | CP | pin line west to x≈5705 riser and x≈5575: pad A30 (R6 1K pull-up to Vcc; cabinet wire marked "S-100-D"?), 470 pF to GND on the pin, and up to the y≈2955 rail → IC55c.12; the meter driver taps the same region (x≈5660, exact tap not re-verified) | clear; meter tap uncertain (U21) |
| 2 (MR) | | ← y≈3585 line = IC73d.2 (inverted /COIN&TEST) | clear |
| 3,4,5,6 (QA–QD) | | QD (pin 6) → the "8000 (F)" arrow line (Andrea, 23 Oct); QB/QC region reaches the y≈2955 rail area — which of them feeds the extend chain not settled | QD clear; others uncertain (U22) |

### IC73 — hex inverter (designator 73; sections drawn as triangles)

| Section | Connection | Confidence |
|---|---|---|
| 9→8 | 9 ← y≈1000 rail (dot (5430,1000)); 8 → R14 220 → node with C27 1000p to GND → IC61a.6 | clear |
| 13→12 | 13 ← CP rail region; 12 → R15 220 → node with C25 1000p → IC55d.1 | uncertain (U15) |
| 3→4 | 3 ← y≈3585 line; 4 (bubble) → arrow "/COIN&TEST (F)" | clear |
| 1→2 | triangle pointing up, bubble at input: 1 ← CT rail (y≈4767, dot ≈(5925,4800)); 2 → up x≈5935 → dot (5936,3579) on the y≈3585 line → IC79.MR, IC73c.3 | clear |
| 5→6 | drawn at the meter ("44" inside the triangle — see U21): 5 ← coin-pulse line; 6 → R1 560 → TR1 base | uncertain (U21) |

### IC72 — NOR section (designator 72; AND body pointing left, bubbles on inputs; 7402-type section 8,9→10)

| Pin | Net | Connection | Confidence |
|---|---|---|---|
| 9 (top input, bubble) | TCLR | ← y≈2705 line (seg of the timer-clear net) | uncertain (U23) |
| 8 (bottom input, bubble) | COIN.IN | ← y≈2780 line | uncertain (U23) |
| 10 (out) | | → west to dot (2265,2720) → IC12.11 (middle input) and a drop south at x≈2265 | clear; drop destination not traced (U23) |

### IC12 — lamp NAND (designator 12; AND body pointing left, output bubble; 7410-type section 9,10,11→8)

| Pin | Net | Connection | Confidence |
|---|---|---|---|
| 10 (top) | Vs/16 | ← arrow labelled Vs/16 (no sheet letter drawn) | clear |
| 11 (middle; numeral not drawn) | | ← IC72.10 | clear |
| 9 (bottom) | | ← dot (2305,2815), vertical dropping south (destination not traced) | uncertain (U24) |
| 8 (out, bubble) | | → west: 220 Ω → LED (circled LED symbol, no designator) → Vcc | clear |

### IC33 — credit memory (printed "33"; 7474 second half: PR=10, D=12, CK=11, CL=13, /Q=8)

| Pin | Net | Connection | Confidence |
|---|---|---|---|
| 10 (PR, bubble) | CP/A30 | riser to the y≈4865 rail → west to x≈2377 (COIN SW make-contact net) and east to x≈5575 (A30, R6) | uncertain (U6) |
| 12 (D) | GND | short stub west then down to ground | clear |
| 11 (CK) | | ← the x≈3632 vertical = 2-play line (from the changeover switch lower throw via dot (3669,3542)) | clear |
| 13 (CL, bubble) | MCLR | drop to the y≈5600 rail (dot (3833,5600)) | clear |
| 8 (/Q) | TCLR | riser to dot (4004,5085): y≈5100 line east → MUTE buffer → pad A26 "MUTE (S)"; x≈4015 vertical north to the y≈3196 line (timer CLEAR, IC74.10) | clear |
| 9 (Q) | | not drawn | clear |

### Tilt one-shot (box A/B/CL/Q//Q, printed "123/2"; designator not legible)

| Pin | Net | Connection | Confidence |
|---|---|---|---|
| 1 (A, bubble) | | ← node: D1 (marked SiB01-02) ← pad AJ ← ANT + TILT SW (common; TILT break → pad A31 → GND); RA1 560 pull-up, RA2 100 series, C12 0.01µ to GND, then R7 100K pull-up and C14 (value reads "47"/"2.2µ"?) | clear; C14 value uncertain (U25) |
| 2 (B), 3 (/CLR) | Vcc | tied through the drawn loop | clear |
| 14–15 | | C19 470µ, R9 47K (tw ≈ 6.2 s) | clear |
| 13 (Q) | | → east along y≈5480 toward the x≈4015 region (tap into the TCLR/clear area not settled) | uncertain (U26) |
| 4 (/Q) | | → east (destination not traced) | uncertain (U26) |

### Output buffers (triangles; designator "31" beside five of them, "29"/"44"/"14 or 17" elsewhere — see U19)

| Section | Connection | Confidence |
|---|---|---|
| 31: 5→6 | GAME → pad A27 "GAME (I)" | clear |
| 31: 3→4 | CT rail → pad Ad "/COIN&TEST (I)" | clear |
| 31: 9→8 (bubbles both sides) | /GAME → pad AE "/GAME (S)" | clear |
| 31: 11→10 (bubbles both sides) | /COIN.IN → pad A28 "/COIN IN (S)" | clear |
| 31: 13→12 (bubbles both sides) | IC38./Q → pad AF "/HISCORE (S)" | clear |
| "29": 13→12 | IC85.12 → pad A29 "EX.CP (S)" | uncertain designator (U19) |
| "14"/"17": 1→2 | y≈5100 line (IC33./Q) → pad A26 "MUTE (S)" | uncertain designator (U19) |
| "44": 5→6 (input bubble) | coin-pulse line → R1 560 → TR1 (C1384) → coin meter (coil to Vcc) at pad A9; emitter → "RET." | uncertain designator (U21) |

### INI RESET and changeover switch

| Item | Connection | Confidence |
|---|---|---|
| INI.RESET line (y≈5035) | from the west (x≈4825 riser / y≈4995 line); dot (6525,5040): → pad BA "INI RESET (B)" and corner up to pad AR "/INI.RESET (I)" | uncertain source (U27) |
| Changeover switch 切換SW | common: 1 kΩ to Vcc and T from the CREDIT-latch Q line (≈(3215,3293)); upper throw "1 COIN 1 PLAY" → east → joins the TCLR net (x≈3505 T); lower throw "1 COIN 2 PLAY" → east → dot (3669,3542): y≈3538 line west + drop to IC33.CK | clear; throw-to-label pairing uncertain (U28) |

## Resistors and capacitors on signal lines

| Ref | Value | Where |
|---|---|---|
| RV? (trimmer) | unreadable | top of the 555 divider, from Vcc (Andrea: diagonal-arrow symbol; U25) |
| R5 | 3.3K | 555 divider, second element |
| R4 | 2K? | 555 divider, third element (U25) |
| C5 | 47µ? | 555 pin 2/6 node → GND (U25; earlier guess 2.2µ superseded by Andrea's reading) |
| C4 | 0.1µ | 555 pin 5 → GND |
| R14 | 220 | IC73a.8 → IC61a.6 node |
| C27 | 1000p | that node → GND |
| R15 | 220 | IC73b.12 → IC55d.1 node |
| C25 | 1000p | that node → GND |
| C24/R13 | 100µ / 47K | IC49 timing |
| C15/R8 | 0.1µ / 47K | IC38 timing |
| C19/R9 | 470µ / 47K | tilt 123 timing |
| RA (CR def) | 560 + 100 + 0.1µ | each CR input filter |
| RA1/RA2/C12 | 560 / 100 / 0.01µ | tilt input filter |
| R7/C14 | 100K / "47"→2.2µ? | tilt 123 input (U25) |
| R6 | 1K | Vcc pull-up on pad A30 |
| R1 | 560 | meter driver base |
| TR1 | C1384 | coin-meter transistor |
| D1 | SiB01-02 | tilt input diode |
| 470p | 470p | IC79 pin 1 to GND |
| 220 + LED | 220 | IC12.8 → LED → Vcc |
| 1K | 1K | changeover-switch common pull-up |

## Off-sheet inputs and outputs

| Label (as written) | Pad/arrow | Direction | Net here | Confidence |
|---|---|---|---|---|
| CAR CONT CL (H) | arrow | out | IC55a.8 | clear |
| EX.CP (S) | pad A29 | out | buffered IC85.12 | clear ("EX" could read "EV", U19) |
| /EX.SIGNAL (B) | pad C1 | out | IC49./Q | clear |
| EX.SIGNAL CP (M) | pad B2 | out | IC55d.3 net | clear |
| EXTEND (F) | arrow | out | EXTEND | clear |
| EXTEND (C) | pad "B8"/"BB" | out | EXTEND | pad name uncertain: at 3.4x both glyphs are spineless loops; the redraw names it BB and gives B8 to a sheet-F pad, so BB is likelier (crop (7930,2370,8220,2580)) |
| /EXTEND (G) | arrow | out | /EXTEND | clear |
| /EXTEND (C) | pad B3 | out | /EXTEND | clear |
| 8000 (F) | arrow | out | line from ≈(6250,3119) (label read by Andrea, 23 Oct — this trace's "δOCC" was 8000; the 8000-point extend signal, see sheet F's EXT.500/8000 block) | label clear; source line still untraced (U29) |
| /GAME (B) | pad B6 | out | /GAME | clear |
| GAME (I) | pad A27 | out | GAME | clear |
| /GAME (F) | arrow | out | /GAME | clear |
| /GAME (S) | pad AE | out | /GAME | clear |
| COIN IN (B) | pad B1 | out | COIN.IN | clear |
| /COIN IN (B) | pad BD | out | /COIN.IN | clear |
| /COIN IN (S) | pad A28 | out | /COIN.IN buffered | clear |
| /COIN IN (G) | arrow | out | /COIN.IN | clear |
| /COIN&TEST (F) | arrow | out | IC73c.4 | clear |
| /COIN&TEST (I) | pad Ad | out | CT buffered | clear |
| /INI.RESET (I) | pad AR | out | INI.RESET net | clear |
| /INI.RESET (B) | pad BA | out | same net (overbar on both labels — read by Andrea, 23 Oct; this trace first missed the bar on BA's) | clear |
| MUTE (S) | pad A26 | out | IC33./Q buffered | clear |
| /HISCORE (S) | pad AF | out | IC38./Q buffered | clear |
| ACC.ST (F) | arrow down, bottom edge | out | MCLR rail region | uncertain (U10) |
| GAME OVER (M) | pad B16, bottom edge | **in** (as wired: only IC74.11 consumes it) | IC74.11 | uncertain (U30) |
| V2 (from E) | pad C6 | in | IC85.13 | uncertain (U18) |
| Vs/16 (from H) | arrow | in | IC85.1; also the arrow at IC12.10 | uncertain (U18) |
| T1-A / A15, A16 (+2) | pads | out | IC21 QA–QD via switches | uncertain (U3) |
| T2-A / A17, A18 (+2) | pads | out | IC20 QA–QD via switches | uncertain (U3) |
| CREDIT SW (A?/A32), TEST SW (Ab/A24 + unlabelled GND pad), COIN SW (Aa/A23, common AZ) | pads | in | IC32 latches (letter-pin readings by Andrea, 23 Oct) | clear except CREDIT make (U5) |
| AJ, A31 | pads | in | tilt | clear |
| A30 ("S-100-D"?) | pad | in | CP rail | uncertain (U21) |
| A9 + Vcc coil "COIN METER", RET. | pad | out | TR1 collector | clear |

Destination letters seen: (H), (S), (B), (C), (F), (G), (I), (M), (E-source
via C6). "(I)" is taken as the score-display board (sheets J/I/K); the
letters at B1/BD/B6/BA read B.

## Block descriptions (wiring-derived only)

- **Timer**: 555 oscillates only while GAME is high (reset released). Each
  pulse decrements IC21; IC21 borrows into IC20. Both reload 90 through
  /LOAD when IC20 borrows (loop partly untraced, U2). The counter value
  leaves through switches to the external display pads. CLEAR (both
  counters) is held by IC33./Q until a coin starts the game.
- **Coin chain**: switch → CR filter → IC32 latch → IC125 AND → IC37a
  (COIN.IN FF) → IC37b (GAME FF). IC74 NOR(IC61b, TCLR, GAME OVER) clears
  everything (MCLR) and retriggers IC38.
- **Extend**: IC79 counts coin pulses, reset by /COIN&TEST through IC73d;
  IC55c/d + IC73b RC make a pulse on a coin event; IC49 opens a ≈1.3 s
  window; IC85 gates V2/Vs/16 blink with that window to the score board;
  IC50a latches EXTEND; IC38 pulses /HISCORE on extend award.
- **2-play mode**: the changeover switch routes the CREDIT-latch output
  either into the TCLR net (1 play) or into IC33's clock (2 play, credit
  memory; D = GND).
- **Tilt**: a ≈6 s one-shot from the pendulum/tilt switch, feeding the
  clear/mute region.

## Unresolved

1. **U1 — RESOLVED (Andrea's reading + redraw, 23 Oct).** The 555 output
   (pin 3) feeds IC22a pin 4; IC22a = AND(555 out, /BO) → IC21 pin 4. The
   x≈2130 vertical into IC21.4 starts at a corner at (2113,1945), not on
   the 555 pin-4 rail; pin 4 (reset) stays on the GAME net. No
   contradiction remains. Only the gate's position on the page was not
   recorded.
2. **U2 — /LOAD loop.** IC21.11+IC20.11 tie through the loop below the
   packages; IC20./BO (13) appears to feed it (reload at borrow), and the
   loop continues west toward x≈2080. Not followed to its end.
   Crop (2100,900,3700,2500) bottom.
3. **U3 — largely settled.** Each QA–QD quad passes a 4-switch block to a
   row of four pad circles (two labelled per block: A15, A16 / A17, A18);
   vertical tags T1-A / T2-A; the brace over both blocks is marked circled
   **J** (Andrea, 23 Oct) — the time-digit feed to the display board (see
   SHEET_J_TRACE.md). Andrea confirms the remaining pad circles carry no
   labels at all; only the circle-to-name pairing of A15/A16 and A17/A18
   stays open. Crop (2250,1020,3250,1560).
   *[Partially settled by the sheet J trace, same session: the LED display
   board receives timer digits T1-A..D / T2-A..D through connector G pads,
   so these pads carry the counters' BCD outputs to the score display;
   the switches sit in series on that path. See SHEET_J_TRACE.md.]*
4. **U4 — IC32 L3 /S1 (pin 11).** Wire runs west then up x≈2385 beyond
   y≈3000; destination not traced (candidate: the IC20 borrow region).
5. **U5 — mostly settled (Andrea, 23 Oct).** The A-connector pads carry
   letter pins as well as numbers: TEST make = Ab, COIN make = Aa,
   COIN common = AZ, CREDIT break = A32, TEST break = A24, COIN break =
   A23. The CREDIT make pad's letter stayed unreadable to both readers
   (perhaps AQ). No clash with the coin-meter pad A9.
6. **U6 — y≈4865 rail.** Links IC33.PR, pad A30/R6 and (per the extractor)
   the x≈2377 vertical from the COIN SW make contact and IC32 L1.Q4's
   x≈2641 drop. The L1.Q4 (TEST latch) membership was not verified by eye
   and an output-onto-rail conflict with the switch line is suspicious;
   junctions near (2641,4865) and (2377,4865) unmeasured.
7. **U7 — numerals confirmed by Andrea (23 Oct): the drawing really has 5 on
   /S and 6 on /R**, contradicting the 74279 (where /R2=5, /S2=6). Taken as
   a drafting slip in the numerals, not the function: the package's other
   two latches are drawn with the make contact on /S and standard numbers,
   so the coin make contact is read as the SET input (real pin 6). This
   decides that the latch sets on coin insertion, not release.
8. **U8 — the x≈3085 vertical (IC125.3).** Real dots at (3085,2390) (y≈2390
   line off the SEC region) and (3083,2600) (y≈2600 line → IC22b.12), lower
   crossings false; the vertical ends at IC125's input region, and the y≈2390
   line's west end (x≈2608) and the short x≈2611 jog to the SEC rail were
   not settled. IC125.4's feed line was not traced either. Strip
   (3000,2300,3230,4150), crop (2550,2300,3300,2480).
9. **U9 — IC37b.CK (11).** Fed by the y≈3990 line from the west
   (x≈3597–4954); its driver was not identified.
10. **U10 — ACC.ST.** The arrow at the bottom edge (x≈3545, circled F) hangs
    from the y≈5590 region; whether it taps the MCLR rail (IC33.CL run) or
    the parallel y≈5565 line was not separated. Crop (3420,5560,3760,6350).
11. **U11 — IC61b.11.** Input from a long vertical ≈x5080 from the top area
    (candidate: IC50b./Q6); not verified.
12. **U12 — IC55 bodies.** Section a is a plain OR; b/c/d are bubbled
    AND-bodies (OR by De Morgan). The output bubble of b sits at the crop
    edge and was not confirmed; section d's output pin numeral (3) and
    bubble were not cleanly read. If any section were NOR instead, the
    package would be inconsistent. Crops (4380,2060,4700,2280),
    (6560,990,6780,1150), (6430,2910,6710,3080), (7010,2930,7300,3110).
13. **U13 — IC55a.9.** The riser from the y≈1400 line connects back to the
    x≈5720 vertical; the x≈5720 net's origin (region of IC50b) was not
    settled.
14. **U14 — IC55b.4 / IC50a.CK.** IC55b pin 4's line runs east along y≈2120
    (ends unresolved, candidates x≈5060 riser to IC61b.11 — see U11);
    IC50a.CK (11) comes from the west at y≈1455, source untraced.
15. **U15 — IC73b.13 input.** Taken as the CP rail (coin pulse) from
    position; the exact tap was not verified. The IC55d.3 output numeral and
    its bubble likewise (U12).
16. **U16 — IC22b.13.** Input arrives from below-left; untraced.
17. **U17 — IC50b.** CK (3) loop source, Q (5) destination (x≈5240 down to
    ≈(5240,3004)) and /Q (6) destination (x≈5080 down) all unresolved;
    these likely tie into IC61b/IC55 nets (U11/U13/U14).
18. **U18 — C6 "V2" and "Vs/16".** The two labels sit side by side over the
    C6 pad and the arrow; pairing taken as V2→C6 (from sheet E via the
    board-to-board pad) and Vs/16→arrow (sheet H). No sheet letters are
    drawn at either. Crop (8060,1040,8620,1720).
19. **U19 — buffer designators and marks.** The EX.CP driver reads "29", the
    MUTE driver "14" (or 17/19), the meter driver "44"; five others read
    "31". Short two-stroke marks ("+7", "+9", "+4") appear beside several
    triangles and were not deciphered (possibly part-type notes). The
    "EX.CP" label's second letter could read V. Buffers 9→8, 11→10, 13→12
    are drawn with bubbles on both input and output; 1→2, 3→4, 5→6 with none
    (inconsistent for one package if read as inverters; consistent if all
    are non-inverting drivers).
20. **U20 — IC38.Q (5).** Short stub, no destination found.
21. **U21 — A30 / meter region.** A30's cabinet-side wire label reads
    "S-100-D" vertically (meaning unknown). The meter driver's input tap
    (x≈5660 vertical) was placed on the CP region by proximity; its exact
    junction was not confirmed (crossings at (5678,4908), (5676,5027),
    (5675,5120) all measured as non-dots, leaving its top connection
    unlocated). Crop (5200,4900,7000,6100).
    *[Partially settled by the sheet I trace, same session: the score board
    (96597-P, sheet I) has serial lines S-100-A…D and sends "S-100-D'" to
    sheet A, matching this pad's cabinet-side marking — so A30 appears to
    come from the score board, not a coin switch. See SHEET_I_TRACE.md.]*
22. **U22 — IC79 outputs.** QA–QD stubs rise from the box; which output
    feeds the extend logic (via the y≈2955 rail region) was not pinned down.
23. **U23 — IC72.** Input assignment (9 ← y≈2705 TCLR seg, 8 ← y≈2780
    COIN.IN seg) rests on two end-joins at the gate edge; the drop at
    x≈2265 from its output dot was not followed. Crop (2200,2620,2800,2880).
24. **U24 — IC12.9.** The dot at (2305,2815) continues south; destination
    untraced (candidate: credit/latch region).
25. **U25 — component values.** 555: upper resistor designator/value
    unreadable, C5 reads 2.2µ with low confidence; tilt C14 reads
    "47"/"2.2µ" ambiguously. Crop (950,1130,1520,1900), (1300,5000,3200,6200).
26. **U26 — tilt 123 outputs.** Q (13) runs east along y≈5480; a T onto the
    x≈4015 TCLR vertical measured 18.4 px (borderline). /Q (4) untraced.
    The package designator is not legible.
27. **U27 — INI.RESET source.** The y≈5035 line comes from the west
    (x≈4825/y≈4995); its driver was not identified. A floating "31" caption
    sits over the line at ≈(6265,5000).
28. **U28 — changeover switch.** The common's T from the CREDIT-latch line
    measured as a T-join, and the upper/lower throw labels ("1 COIN 1 PLAY"
    above, "1 COIN 2 PLAY" below) were paired by position; arm drawing is
    ambiguous. Crop (3050,3020,3750,3340).
29. **U29 — RESOLVED (Andrea, 23 Oct).** The "8000 (F)" arrow is fed by
    IC79 pin 6 (QD of the 393/2 coin counter).
30. **U30 — GAME OVER (M), pad B16.** Only IC74.11 sits on this net on
    sheet A, which makes it an input from sheet M as wired; but "GAME OVER"
    reads like an A-sheet product. Direction needs sheet M. The circled
    letter is clearly M (crop (4450,5800,4850,6420)).
    *[Settled by the sheet M trace, same session: sheet M generates GAME
    OVER (IC46 borrow → IC59 buffer → pad E16, circled A), so B16 is an
    input here, as wired. See SHEET_M_TRACE.md.]*
31. **Pinout disagreements noticed:** IC32 L2 (U7); IC12's middle input
    numeral not drawn (taken as 11 of a 7410); the "123/2" tilt one-shot
    designator missing.
32. ~~Redraw comparison not yet done~~ Done — see the next section.

## Comparison with stonedDiscord's redraw (23 October 2026)

Netlist exported from `MonacoGP/Main/Main.kicad_sch` (board 96577, all four
sheets in one schematic) with kicad-cli. U numbers are the IC numbers. As
START_HERE requires, differences were settled on the scan where possible;
the redraw is a check, not a source.

**Package types all agree** with the drawn bodies: U26 NE555, U20/U21 74192,
U32 74279, U33/U37/U50 7474, U38/U49 74123, U55 7432 (OR — supports the
De Morgan reading of sections b/c/d, U12), U61/U72 7402 NOR, U73/U44 7404,
U74 7427, U85/U125 7411, U29/U31 7407 buffers (settles U19's buffer
polarity: all non-inverting; "29" designator confirmed).

**Settled on the scan after the comparison:**

- **U1 (the 555/IC21.4 contradiction) resolves.** The redraw has 555 pin 4
  on the GAME net (with U37.9 and U31.5) — agreeing with this trace — and
  IC21.4 fed separately from an AND "U22a" (inputs 555.3 and IC20./BO).
  Re-reading the scan: the x≈2130 vertical into IC21.4 starts at a corner
  at (2113,1945) from a horizontal running east at y≈1945 — it does NOT
  come from the 555 pin-4 rail. The trace's IC21.4 row is corrected to
  "from a y≈1945 line, source untraced (redraw: an IC22 AND of the 555
  output and IC20 borrow; that gate was not found on the scan — searched
  (2040,2240)-(2500,2680))". The electrical contradiction disappears.
- **The tilt one-shot is IC38's first half.** The redraw uses U38 pins
  1,2,3,13,4 for it; Q (13) joins the counters' CLEAR net and /Q (4) drives
  IC33./CLR (its net also carries a pad the redraw names Ak). This matches
  this trace's own probe grouping (the /Q4 run matched the y≈5565 rail that
  ends at IC33.CL's measured dot (3833,5600)) and replaces the speculative
  "y≈5600 rail → x≈4822 → IC74.8" reading: **IC33./CLR ← tilt /Q, not
  MCLR** (U10/U26 partly settled; the designator gap closes — no separate
  unnamed 74123 exists).
- **CT rail driver found: IC125.6.** The redraw puts U125.6, U20.11, U21.11
  (/LOAD), U22.12, U31.3, U37.3 (CK) and U73.1 on one net. The scan shows
  IC125.6's net dropping from the CK dot region (x≈3045) to the CT rail's
  west end (3037,4767) — previously misattributed. So /COIN&TEST = the
  IC125 AND output, and the counters' /LOAD and IC22b.12 sit on it
  (corrects IC22b.12 ← "SEC rail": the long y≈2330 rail is **IC20./BO**,
  not the 555 output — the /BO reading also matches IC55b.5 and IC61b.11
  per both the redraw and the measured dot (4642,2352)).
- **IC33.PR ← the COIN-latch Q (IC32.7) rail**, which also feeds IC125.5
  and the coin-meter driver input (U44.5) — the y≈4865 rail is that net
  (settles U6 and the meter-tap half of U21; A30 itself connects only to
  IC79.CP + R6 + a capacitor, as this trace found).
- **IC50b half:** CK (3) is on the EX.SIGNAL-CP net (with IC49.1 and
  IC55d.3); Q (5) → IC61b.12; /Q (6) → IC55b.4. Settles U13/U14/U17's
  destinations; scan spot-checks pending.
- **IC12 is a 2-input NAND (7400).** Pin 11 is unconnected in the redraw;
  the net I read into the "middle input" (IC72.10) joins pin 9's net, which
  also carries the CREDIT-latch /S line southward — matching the unexplained
  south drop at (2305,2815) (settles U23/U24's shape; the drawn gate still
  shows three contact points — one is the same net twice).
  The lamp line: the redraw sends U12.8 to a pad it names A6 (no LED); the
  scan shows an eroded symbol on that line at ≈(1790,2640)-(1980,2740)
  that may be that pad — LED vs pad unresolved (U5 note: if that pad is A6,
  the COIN-make pad glyph "A6?" is misread).
- **IC37b.CK (U9) is the ACCE.ST net** (redraw: from U34.6, a sheet-F
  gate). So ACC.ST at the bottom edge relates to the GAME FF clock; the
  direction question of U10 remains but the net identity is fixed.
- **IC74 input pins 9/10 are swapped** relative to this trace (same NOR,
  interchangeable inputs): redraw has U74.9 on the counters'-CLEAR net and
  U74.10 ← IC61b.13. Numerals to be re-read; function unchanged.

**Redraw errors found here (scan evidence against it):**

- It omits IC33./Q8 from the counters'-CLEAR net (scan: measured dots
  31.1 px at (4035,3192) and 26.9 px at (4004,5085) put it there) — its
  MUTE path agrees anyway via U31.1 on the CLEAR net.
- It omits the 220 Ω + LED drawn at (1440,2350)-(1575,2480).
- Its "B21" net merges the Vs/16 arrow at IC12.10/IC85.1 with a U79
  second-half output — plausible but unproven here (sheet H's chain, U18).

**Remaining open after comparison:** the U22a gate's location on the scan;
IC12's third drawn contact; the A6-vs-LED pad; U3 switch-block pad set;
U5 pad glyphs; U25 values; U28 arm; U29 label; the IC73a-vs-IC44 designator
at (5550,1080) (redraw: U44.9→8 sits on the IC55b.6 net where this trace
read "73"); δOCC source.
