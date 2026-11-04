# Sheet E — crystal, H/V counters, sync and blanking

Source: Sega **Monaco GP (420-0358)**, PDF page **32**, drawing **E**, board
**96578-P**, sheet **D-4/5**, "IC BOARD ASS'Y, B". The title block also reads
同期信号 (sync signals). Image: manual 420-0358, PDF page 32,
**10160 × 6624** pixels, SHA-256
`bc4924463a0dd6ac99575c0a12f0046962a161a4bffa972dfdb42065b882162e`.

**Status:** complete pin-level trace, every drawn pin followed on the scan
(26 October 2026). It extends [`../TIMING.md`](../TIMING.md), which
transcribed the counter, sync and blanking logic in October and holds the
implemented timing. This file adds:

- every pin and pad;
- the clock and test-point buffers;
- the outputs to other sheets, with their pad names.

It corrects one line of TIMING.md (IC95, see "Corrections to TIMING.md").

## How this trace was made

- Every IC section, pad and arrow on the sheet was followed on zoomed crops
  of the scan, wire by wire.
- Doubtful junctions were measured with a dot-size measuring script. A
  junction dot measures 18–24 px; a plain crossing 14–16 px.
- stonedDiscord's KiCad redraw of board 96578 was used only to predict
  which pins to follow. That board is drawn but not routed, so it is another
  reading of the same scan, not independent evidence. It is also of the
  later revision, and adds an IC1 test-point buffer and a 14MHz_EXT path.
  Differences from it are listed below.
- Nothing from the redraw is copied.

## Conventions

- **Frame R.** The stored PNG is upside down, like pages 26, 28 and 30. All
  coordinates here are in its 180°-rotated, upright view (frame R). A box
  `(x0,y0,x1,y1)` in frame R is `(10160-x1, 6624-y1, 10160-x0, 6624-y0)` in
  the stored image.
- **Notation.** `/NAME` is an overbar. `(B)` is a circled sheet letter.
  `ICn.p` is pin p of IC n.
- **Gate function** is taken from the drawn body, with De Morgan forms read
  as in the sheet F trace.
- **Supply pins** (7/8/14/16) are not drawn and not listed.
- **Pads.**
  - Plain squares are board-edge pads to the main board: E-row pads to
    sheet F, F-row pads to sheets F, G and H.
  - Squares with an X (D6, D7, D8) are test or indicator pads to sheet I.
  - Pad names are as printed. On the main board the same signals arrive on
    C-row pads with the same number or letter: FJ arrives as CJ, F13 as C13,
    FF as CF, FH as CH, F7 as C7.
- **Check:** "clear" means read without doubt on the scan. "Uncertain" rows
  point to the Unresolved list.

## Evidence boxes

| What | Frame R box |
|---|---|
| Oscillator, IC117 9→8, 11→10, 13→12, X1, R17, R18, C16, C17 | (1350,2350,2450,3550) |
| 14MHz and 7MHz pads, D6 driver, IC117 5→6 | (2200,1050,3300,2050) |
| IC109 second half (clock divider) | (2350,2000,3150,3450); Vcc node (2300,2450,2560,3060) |
| IC108 | (3000,2350,4200,3250) |
| H4–H7 pads and arrows, IC114 10/11 and 8/9, D8 driver | (4100,1000,5600,2450) |
| IC107 and IC115 9,10,11→8 | (4100,2350,5600,3450) |
| IC107 output routes | (4600,1950,5100,2600) |
| IC116 both halves | (5550,2300,7100,3500) |
| H8, /H8 pads | (6300,1000,7300,1800) |
| IC115 3,4,5→6, C19, IC95, /HS pads | (6950,1050,8000,3550) |
| IC28 /SYNCRO | (7650,3350,9100,3700) |
| IC101 1,2,4,5→6 /TV-BLANKING | (6950,4850,9300,5900) |
| V0–V3 arrows, F6, D7 driver, IC114 13→12 | (3050,3500,4300,4700) |
| IC102 | (2950,4600,4500,5800) |
| V4–V7 pads and arrows, IC93 1→2, 3→4, 5→6, 9→8 | (4100,3500,5450,4950) |
| V4–V7 rows to IC101.9–13 | (4650,4550,5550,5000) |
| IC110, IC114 1→2, 3→4, IC115 13,1,2→12, C8 | (5400,4050,7100,5000) |
| IC100, IC93 13→12, C13, IC109 first half | (4300,4800,6450,5800) |
| IC101 9,10,12,13→8 | (5250,5650,6400,6050) |

## Off-sheet outputs

Sheet E has no signal inputs: everything starts at the crystal.

| Label as drawn | Pad or arrow | To | Driven by |
|---|---|---|---|
| 14MHz | pad CV | (H) | IC117.12 |
| 14MHz | pad D6 (X), 470Ω pull-up to Vcc | (I) | gate "1" 9→8 (see U4) |
| 7MHz | arrow | (M) | IC117.6 |
| 7MHz | pad F13 | (F)(G)(H) | IC117.6 |
| 7MHz | arrow | (B)(C) | IC109.6 (/Q) |
| H0, H1, H2, H3 | four arrows | (B)(M) | IC108.14, .13, .12, .11 |
| H4 | arrow | (B)(M) | IC107.14 |
| H4 | pad printed "F3" (read F8, see U3) | (F) | IC107.14 |
| H5 | arrow | (B)(M) | IC107.13 |
| H5 | pad F7 | (F) | IC107.13 |
| H5 (to the LED pad) | pad D8 (X) | (I) | gate "1" 13→12 |
| /H5 | arrow (subscript see U2) | (B) | IC114.10 |
| H6 | pad FH | (F) | IC107.12 |
| /H6 | pad F2 | (H) | IC114.8 |
| H7 | arrow | (B) | IC107.11 |
| H6 | arrow | (B)(M) | IC107.12 |
| H8 | arrow | (B)(M) | IC116.3 |
| H8 | pad FF | (F) | IC116.3 |
| /H8 | pad FB | (H) | IC116.2 |
| /H8 | arrow | (B)(M) | IC116.2 |
| /HS | arrow | (B)(D)(M) | IC95.3 |
| /HS | pad FJ | (F)(G)(H) | IC95.3 |
| /SYNCRO | arrow | (C) | IC28.8 |
| /TV-BLANKING | arrow | (C) | IC101.6 |
| V0 | arrow | (M) | IC102.14 |
| V1 | arrow | (B)(M) | IC102.13 |
| V2 | pad F6 | (A) | IC102.12 |
| V2 | arrow | (B)(M) | IC102.12 |
| V2 (to the LED pad) | pad D7 (X) | (I) | gate "1" 11→10 |
| V3 | arrow | (B)(M) | IC102.11 |
| V4 | arrow | (B)(M) | IC100.14 |
| V4 | pad E21 | (F) | IC100.14 |
| /V4 | arrow | (B)(M) | IC93.2 |
| V5 | arrow | (B) | IC100.13 |
| /V5 | pad EY | (F) | IC93.4 |
| V6 | arrow | (B)(M) | IC100.12 |
| V6 | pad E12 | (F) | IC100.12 |
| /V6 | pad E22 | (F) | IC93.6 |
| V7 | arrow | (B)(D)(M) | IC100.11 |
| V7 | pad EN | (F) | IC100.11 |
| /V7 | pad EZ | (F) | IC93.8 |
| /V7 | arrow | (M) | IC93.8 |
| /(V-CA × V8) | arrow | (B) | IC110.3 |
| /(V-CA × V8) | pad FS | (H) | IC110.3 |
| V-CA | arrow | (M) | IC100.15 |
| /V8 | arrow | (B)(D) | IC114.2 |
| /V8 | pad FN | (H) | IC114.2 |
| V8 | arrow | (M) | IC114.4 |
| /VS | pad F12 | (H) | IC115.12 |

## Pin tables

### IC117 — hex inverter (type not printed; redraw 74LS06)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 9 | in | oscillator node A: R17, X1 | clear |
| 8 | out | oscillator node B: R17, C17, IC117.13 | clear |
| 11 | in | oscillator node C: R18, C17 (through the crossed leads) | clear |
| 10 | out | oscillator node D: R18, C16 | clear |
| 13 | in (drawn with input bubble) | node B | clear |
| 12 | out | 14MHz: pad CV (H), gate "1".9, IC109.9 | clear |
| 5 | in (drawn with input bubble) | IC109.5 (Q) | clear |
| 6 | out | 7MHz: pad F13 (F)(G)(H), arrow (M) | clear |

The crystal X1 runs from node A to C16, and C16 to node D. C17 runs from
node B to node C. R17 (330) bridges 9→8 and R18 (330) bridges 11→10.

### IC109 — 74107 dual JK flip-flop, printed "(107/2)" twice, "cp 109"

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | 1J | Vcc | clear |
| 12 | 1CP | V-CA (IC100.15) | clear |
| 4 | 1K | Vcc; printed "11" (pinout 4, see U1) | uncertain |
| 13 | 1/CLR | Vcc (loop from the J/K Vcc rail) | clear |
| 3 | 1Q | V8: IC102.6, IC101.1, IC115.2, IC110.2, IC114.1 | clear |
| 2 | 1/Q | /V8: IC100.3, .4, .5, .6, IC114.3 | clear |
| 8 | 2J | Vcc; printed "9" or "8" (pinout 8, see U1) | uncertain |
| 9 | 2CP | 14MHz (IC117.12); the Vcc rail meets this row with a dot (U1) | uncertain |
| 11 | 2K | Vcc | clear |
| 10 | 2/CLR | Vcc | clear |
| 5 | 2Q | IC117.5 | clear |
| 6 | 2/Q | 7MHz: arrow (B)(C), IC108.2, IC107.2 | clear |

### IC108 — 74161 counter, printed "(161)"

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /CLR | Vcc | clear |
| 2 | CP | 7MHz (IC109.6) | clear |
| 3, 4, 5 | A, B, C | GND | clear |
| 6 | D | blank (IC116.5) | clear |
| 7 | P | Vcc | clear |
| 10 | T | Vcc | clear |
| 9 | /LOAD | load net: IC107.9, IC115.8, C14 | clear |
| 14, 13, 12, 11 | QA–QD | H0, H1, H2, H3 arrows (B)(M) | clear |
| 15 | CA | IC107.7 (P); loop over the top to IC115.11 | clear |

### IC107 — 74161 counter, printed "(161)"

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /CLR | Vcc | clear |
| 2 | CP | 7MHz (IC109.6) | clear |
| 3 | A | blank (IC116.5) | clear |
| 4 | B | /blank (IC116.6) | clear |
| 5 | C | GND | clear |
| 6 | D | Vcc | clear |
| 7 | P | IC108.15 (CA) | clear |
| 10 | T | Vcc | clear |
| 9 | /LOAD | load net | clear |
| 14 | QA | H4: arrow (B)(M), pad F8 (printed "F3", U3) | clear |
| 13 | QB | H5: arrow (B)(M), pad F7, gate "1".13, IC114.11 | clear |
| 12 | QC | H6: pad FH, arrow (B)(M), IC114.9, IC115.4 | clear |
| 11 | QD | H7: arrow (B) | clear |
| 15 | CA | IC115.9, IC116.12, IC116.9 | clear |

At (5552,2745), the IC108 CA loop crosses the IC107 CA line without a
dot (15.6 px). The IC107 CA dot is at (5605,2745).

### IC116 — 74107 dual JK flip-flop, printed "(107/2)" twice

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | 1J | /blank (IC116.6) | clear |
| 12 | 1CP | IC107.15 | clear |
| 4 | 1K | blank (IC116.5) | clear |
| 13 | 1/CLR | Vcc | clear |
| 3 | 1Q | H8: arrow (B)(M), pad FF (F), IC116.8, .10, .11, IC115.10 | clear |
| 2 | 1/Q | /H8: pad FB (H), arrow (B)(M) | clear |
| 8 | 2J | H8 | clear |
| 9 | 2CP | IC107.15 | clear |
| 11 | 2K | H8 (loop) | clear |
| 10 | 2/CLR | H8 (loop) | clear |
| 5 | 2Q | blank (labelled "H_B"): IC115.5, IC116.4, IC107.3, IC108.6, IC101.4 | clear |
| 6 | 2/Q | /blank: IC116.1, IC107.4 | clear |

### IC115 — 7410 triple 3-input NAND (type not printed)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 11 | in | IC108.15 | clear |
| 9 | in | IC107.15 | clear |
| 10 | in | H8 | clear |
| 8 | out | load net: IC108.9, IC107.9, C14 470p to GND | clear |
| 3 | in | /H5 (IC114.10) | clear |
| 4 | in | H6 | clear |
| 5 | in | blank (IC116.5) | clear |
| 6 | out | /HS: IC95.2, C19 to GND, IC102.2, IC100.2, IC28.9 | clear |
| 13 | in | /V3 (IC114.12) | clear |
| 1 | in | V2 | clear |
| 2 | in | V8 | clear |
| 12 | out | /VS: pad F12 (H), C8 470p to GND, IC28.10 | clear |

### IC95 — 7408 AND section (type not printed; redraw 74LS08)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | in | Vcc | clear |
| 2 | in | /HS (IC115.6) | clear |
| 3 | out | /HS: pad FJ (F)(G)(H), arrow (B)(D)(M) | clear |

The body is a plain AND with no bubble, so this is a buffer: both outputs
are labelled /HS.

### IC114 — hex inverter (type not printed; redraw 74LS06)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 11 | in | H5 | clear |
| 10 | out | /H5: arrow (B), IC115.3 | clear |
| 9 | in | H6 | clear |
| 8 | out | /H6: pad F2 (H) | clear |
| 13 | in | V3 | clear |
| 12 | out | /V3: IC115.13 | clear |
| 1 | in | V8 | clear |
| 2 | out | /V8: pad FN (H), arrow (B)(D) | clear |
| 3 | in (input-bubble form) | /V8 (IC109.2) | clear |
| 4 | out | V8: arrow (M) | clear |

### IC102 — 74161 counter, printed "(161)"

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /CLR | Vcc | clear |
| 2 | CP | /HS | clear |
| 3, 4, 5 | A, B, C | GND | clear |
| 6 | D | V8 (IC109.3) | clear |
| 7 | P | Vcc | clear |
| 10 | T | Vcc | clear |
| 9 | /LOAD | IC93.12, IC100.9, C13 | clear |
| 14 | QA | V0: arrow (M) | clear |
| 13 | QB | V1: arrow (B)(M) | clear |
| 12 | QC | V2: pad F6 (A), arrow (B)(M), gate "1".11, IC115.1 | clear |
| 11 | QD | V3: arrow (B)(M), IC114.13 | clear |
| 15 | CA | IC100.10 (T) | clear |

### IC100 — 74161 counter, printed "(161)"

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /CLR | Vcc | clear |
| 2 | CP | /HS | clear |
| 3, 4, 5, 6 | A–D | /V8 (IC109.2) | clear |
| 7 | P | Vcc | clear |
| 10 | T | IC102.15 | clear |
| 9 | /LOAD | IC93.12, IC102.9, C13 | clear |
| 14 | QA | V4: arrow (B)(M), pad E21 (F), IC93.1, IC101.9 | clear |
| 13 | QB | V5: arrow (B), IC93.3, IC101.10 | clear |
| 12 | QC | V6: arrow (B)(M), pad E12 (F), IC93.5, IC101.12 | clear |
| 11 | QD | V7: arrow (B)(D)(M), pad EN (F), IC93.9, IC101.13 | clear |
| 15 | CA | V-CA: arrow (M), IC93.13, IC109.12, IC110.1, 470P to GND | clear |

The three V-row taps into IC101 were measured: V4 at (4750,4850) is 22.4 px,
V5 at (4810,4785) is 20.9 px and V6 at (4870,4725) is 21.6 px. The V7 row
crosses the V2 and /V3 rows at x≈5456 without dots (15.6 px each).

### IC93 — hex inverter (type not printed; redraw 74LS06)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | in | V4 | clear |
| 2 | out | /V4: arrow (B)(M) | clear |
| 3 | in | V5 | clear |
| 4 | out | /V5: pad EY (F) | clear |
| 5 | in | V6 | clear |
| 6 | out | /V6: pad E22 (F) | clear |
| 9 | in | V7 | clear |
| 8 | out | /V7: pad EZ (F), arrow (M) | clear |
| 13 | in | V-CA | clear |
| 12 | out | load net of IC102/IC100; C13 470p to GND | clear |

### IC110 — 7400 NAND section (type not printed)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | in | V-CA | clear |
| 2 | in | V8 | clear |
| 3 | out | /(V-CA × V8): pad FS (H), arrow (B) | clear |

### IC101 — dual 4-input NOR (7425-type; type not printed; redraw 74LS20)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 9 | in | V4 | clear |
| 10 | in | V5 | clear |
| 12 | in | V6 | clear |
| 13 | in | V7 | clear |
| 8 | out | IC101.5 | clear |
| 1 | in | V8 | clear |
| 2 | in | GND | clear |
| 4 | in | blank (IC116.5) | clear |
| 5 | in | IC101.8 | clear |
| 6 | out | /TV-BLANKING (C) | clear |

The section on pins 9, 10, 12 and 13 is drawn as an AND body with a bubble on
each input (NOR). The section on pins 1, 2, 4 and 5 is drawn as an OR body
with an output bubble (NOR). Both forms give the same function.

### IC28 — 7486 XOR section (type not printed)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 9 | in | /HS | clear |
| 10 | in | /VS | clear |
| 8 | out | /SYNCRO (C) | clear |

### Gate "1" — three buffer sections driving the D pads

The designator reads "1" beside each of the three triangles. Each has an
unread mark to its left (see U4). The pin numbers fit a hex buffer, and the
redraw uses IC1, a 74LS07.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 9 | in | 14MHz | clear |
| 8 | out | pad D6 "14MHz (I)", 470Ω to Vcc | clear |
| 13 | in | H5 | clear |
| 12 | out | pad D8 "(I)" | clear |
| 11 | in | V2 | clear |
| 10 | out | pad D7 "V2 (I)" | clear |

## Resistors and capacitors

| Ref | Value as read | Connected to |
|---|---|---|
| X1 | crystal, "14.305" | IC117 node A to C16 |
| R17, R18 | 330, 330 | across IC117 9→8 and 11→10 |
| C17 | 0.1µ | IC117.8 node to IC117.11 node |
| C16 | 100p | X1 to IC117.10 node |
| C14 | 470p to GND | horizontal load net (IC115.8) |
| C19 | 1000P to GND (written next to a struck-out value, U5) | /HS (IC115.6) |
| C13 | 470p to GND | vertical load net (IC93.12) |
| (unnumbered) | 470P to GND | V-CA (IC100.15) |
| C8 | 470p to GND | /VS (IC115.12) |
| (unnumbered) | 470Ω to Vcc | pad D6 output |

## Block description

[`../TIMING.md`](../TIMING.md) gives the counter sequences: 456 clocks a
line, 264 lines a frame. The tables above agree with it pin for pin, except
for the IC95 line corrected below. In brief:

- **Clock.** IC117 9→8 and 11→10 form a crystal oscillator. IC117 13→12
  buffers it as 14MHz. IC109's second half divides it by two: /Q is the 7MHz
  that clocks the H counters, and Q, inverted in IC117 5→6, is a second
  7MHz output of the same phase for other boards.
- **Horizontal.** IC108/IC107 count H0–H7, and IC116's first half adds H8.
  IC116's second half is the blank latch. IC115 9,10,11→8 reloads both
  counters. IC115 3,4,5→6 decodes /HS, and IC95 buffers it to the other
  boards.
- **Vertical.** IC102/IC100 count V0–V7 on /HS, and IC109's first half adds
  V8. IC93 13→12 reloads both counters from V-CA. IC115 13,1,2→12 decodes
  /VS.
- **Outputs.** IC28 XORs /HS and /VS into /SYNCRO. IC101 NORs the V-zero
  decode, V8 and the H blank latch into /TV-BLANKING. Inverters IC93 and
  IC114 make the inverted H and V lines that other sheets use.

## Corrections to TIMING.md

- **IC95 is an AND buffer, not an inverter.** TIMING.md line 20 says "Inverts
  /HS to HS". The scan draws a plain AND body with pin 1 at Vcc, and both
  outputs are labelled /HS. The pads, sheet F (pad CJ, /HS) and the
  implementation are unaffected. Sheet F's IC40 counts on /HS.

## Differences from the redraw

| Item | Scan | Redraw |
|---|---|---|
| V8 | Its own net (IC109.3) | Merged with H8 (known redraw error) |
| IC101 | NOR in both drawn forms | 74LS20 (NAND) |
| IC117 5→6 output | 7MHz, same phase as IC109./Q | Named /7MHz |
| H4 pad | Printed "F3", read F8 | F8 |
| IC1 | Three buffer sections for D6, D7, D8 | Also has a 14MHz_EXT path and other sections (later revision) |
| V-CA capacitor | One 470P to GND, number not printed | C2 and C998 |

## Cross-sheet findings

- **Sheet F, U5.** Sheet E sends six V lines to sheet F, through pads E21
  (V4), EY (/V5), E12 (V6), E22 (/V6), EN (V7) and EZ (/V7). Sheet F
  receives them as follows:
  - V6 on pad B12 and V7 on pad BN.
  - Four further pads, whose first letter is hidden behind a brace: ?T (V4),
    ?U (/V5), ?17 and ?18.

  So pads ?17 and ?18 should carry /V6 and /V7. On sheet F, at
  R(1830,4800,2120,5060), a line runs directly above each of their "V6" and
  "V7" labels, like the overbar on "/V5". The sheet F trace has been
  changed to /V6 and /V7 (sheet F U5, closed).
- **Sheet H, U2.** Pad FN is /V8, so sheet H's pad CN is /V8. Pad F2 is /H6,
  so pad C2 is /H6. Pad F12 is /VS, which matches pad C12.
- **Sheet B** receives /H5 and /H8 on the arrows listed above. This agrees
  with the sheet B trace.

## Unresolved

1. **U1 — IC109 pin numbers and the second-half clock node.**
   - The first half's K is printed "11" (pinout 4).
   - The second half's J is printed with a glyph that reads 9 or 8 (pinout 8).
   - In the second half, the Vcc rail feeding J, K and /CLR meets the
     14MHz row at the CP input with a 21.3 px dot at (2383,2733). Read
     literally, this ties 14MHz to Vcc.
   - The first half's matching crossing at (5880,5150) measures 17.2 px and
     looks like a plain crossing.

   The divider can only work with CP on 14MHz, so the dot is taken as a
   drafting slip.
2. **U2 — /H5 arrow subscript.** The glyph looks like 4. The wire is IC114.10
   (/H5), and sheet B uses /H5 (E).
3. **U3 — H4 pad name.** It is printed "F3". The drafter's 8 is often read as
   3 or B, sheet F receives H4 on pad C8, and the redraw has F8.
4. **U4 — Marks beside the D-pad buffers.** Each buffer has a cross-like
   mark to its left, roughly "✗8", "✗" and "♀1", that was not read. Their
   type is not printed.
5. **U5 — C19 value.** "1000P" is written next to a struck-out earlier value.
6. **U6 — Crystal.** "14.305" (see TIMING.md); not a measured frequency.
