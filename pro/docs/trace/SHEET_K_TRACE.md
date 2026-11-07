# Pro sheet K: rank latches, SUPER RACER SCORE and scores above 9999

Date: 2026-11-05. Issue #37. Pin-level trace of Sega 420-0525 (Pro Monaco GP),
PDF page 20, circled **K**, board **96824-P SCORE DISPLAY IC BOARD ASS'Y
(D-3/3)**, issue stamp 1980-7-16, with the stamp `ジャンパー線無し` ("no
jumper wires") under the title and again under the bottom-right title.
Sheets I (D-1/3, page 18) and J (D-2/3, page 19) are the other two thirds of
the same board, so the signals between I, J and K are board traces and carry
no connector pads.

## Sources and method

- Pro: `pro/schematics/promonacogp420-0525_1.pdf` (SHA-256 `9473d6dd…32f2`).
  Page 20 rendered with PyMuPDF at `Matrix(1, 1)`, upright: **10200 × 6617**
  pixels. Pages 18 (I) and 19 (J) at the same scale, only at the interface
  points listed below. Every box is (left, top, right, bottom) on the scale-1
  render of its page. Crops were made with a page-coordinate ruler drawn in
  the margin, so every coordinate below is read off the ruler. Crop names are
  local identifiers; the crops are not in the repository.
- Original: `schematics/pages/page24-sheet-K-score.png` was not read again;
  the original is cited from `docs/trace/SHEET_K_TRACE.md`.
- Sheet I context: `pro/docs/trace/SHEET_I_TRACE.md`. Its K interface points
  (T.R.S, LATCH CL., V2, D bus, 1ST–5TH) were re-read on page 18 for this
  trace; see "Interface checks on I and J".
- Reading rules from `pro/README.md`: a drawn dot is a junction, a crossing
  is not, even where the scan thickens it (compared with real dots nearby).
  Gate function comes from the drawn symbol. Pin numbers are checked against
  standard pinouts; where they disagree both are recorded.
- Confidence: **clear** (read directly, no competing reading), **probable**
  (one reading fits much better, but the scan or the route is not clean),
  **uncertain**.
- No MAME, emulator, other core, fan remake, footage, gameplay description
  or PROM contents were used. stonedDiscord's KiCad redraw covers the
  original board only and was not used.

Notation: `nn.p` is the part drawn with designator nn, pin p, on this sheet.
`/` transcribes an overbar.

### Crops (page 20 unless noted)

| Crop | Box | Contents |
|---|---|---|
| ov | (0, 0, 10200, 6617) at 0.15 | Navigation only |
| title | (1500, 300, 4500, 1300) | Title, board number, stamp |
| dbus | (1550, 1150, 3200, 2250) | D-1A…D-4D labels and the 16 staggered taps |
| c1-drops | (2050, 2150, 2900, 3450) | Column 1 data drops into 40/39/38 |
| c1 | (2700, 2250, 3700, 3650) | Column 1 packages, pin numerals, 1ST-xx outputs |
| c1-left | (2450, 2600, 2900, 3700); zooms (2650, 2580, 2880, 2730), (2600, 3380, 2900, 3620) | Column 1 /MR and CP risers, `Vcc` |
| col2 … col5 | (3550, 2250, 4950, 4050), (5050, 2250, 6450, 4050), (6550, 2250, 7950, 4050), (8050, 2250, 9550, 4050) | Columns 2–5 |
| rank-in | (1550, 3550, 3000, 3980) | 1ST–5TH inputs |
| in-left | (1550, 4050, 3500, 6150) | P bus, /LATCH CL, T.R.S labels, comparator Vcc |
| pbus | (3300, 4050, 7000, 5100) at 0.4 | P bus taps to comparators and 174s |
| cmp-taps | (3450, 4120, 4750, 4980) | Comparator A-input taps |
| cmp1 | (3350, 4950, 4250, 5450); casc (3380, 5100, 3560, 5320); vcc (2400, 5150, 3450, 5330) | 44, cascade inputs |
| cmp23 | (3650, 5080, 4250, 5290); (4250, 5080, 4850, 5290) | 50, 58, 67 cascade |
| g66 | (4550, 5050, 5500, 5550) | 66 and the clock row |
| l174-top | (5400, 4800, 5760, 5130), (5750, 4800, 6160, 5130), (6150, 4850, 6560, 5130) | 43, 49, 57 inputs, /MR |
| l174-taps | (5400, 4120, 5750, 4500), (5800, 4450, 6150, 4800), (6150, 4750, 6450, 4880) | P bus corners into 43, 49, 57 |
| l174-bot | (5400, 4950, 6900, 5450); (6050, 5080, 6260, 5360); (6230, 5180, 6750, 5360) | Outputs, CP |
| matrix | (3450, 5250, 4850, 6060); (4700, 5250, 5500, 6060); (5400, 5200, 6500, 6060); (6900, 5280, 7850, 6060) | Stored-value rows S1A…S4D |
| flag | (6600, 4300, 6800, 5350); (6620, 5050, 6800, 5340) | 57.12 riser to 37.9 |
| sel | (6400, 4450, 7100, 5200); zoom (6750, 5100, 6980, 5230) | *a, *b to 153 A/B |
| mux | (6930, 5050, 7400, 5300); (7380, 5050, 7850, 5300); (6900, 4700, 8050, 5130) | 42, 48 pins and outputs |
| dec | (6250, 4100, 6950, 4500); (6900, 4100, 7600, 4500); (7550, 4150, 7980, 4500); (7400, 4280, 8000, 4760) | *a, *b, V2', 37, 36 |
| 9374 | (7900, 4700, 8450, 5150); pads (8250, 4740, 8470, 5080); low (7550, 5050, 8250, 5700); j3 (8030, 5420, 8150, 5540) | 41, segment pads, pin 3 |
| ret | (7950, 4550, 8300, 4800); (9200, 5650, 9900, 5950) | LAMP RET arrows |
| drv | (8000, 4050, 9400, 4700); 07 zoom (7950, 4080, 8150, 4500) | 07, R37–R40, TR9–TR12 |
| disp | (8400, 4750, 9400, 5150); labels (8450, 4760, 9150, 4860); commons (8450, 4500, 9350, 4800) | Display unit |
| lamp | (7750, 5050, 9500, 6000); 17 zoom (8500, 5380, 9050, 5560) | 17, TR15, TODAY'S HIGH SCORE lamp |
| trs | (1550, 5980, 4850, 6100) | T.R.S row to 66.10 |
| I-tenk | page 18: (2400, 4900, 3900, 6200) | 56, 65, T.R.S arrow |
| I-lcl | page 18: (1900, 5500, 2500, 6150) | LATCH CL. arrow |
| I-hu | page 18: (1600, 4600, 2400, 4900) | HU V2 arrow to K and J |
| I-d4 | page 18: (6850, 3350, 7500, 3800) | D-4x arrows |
| I-rank | page 18: (8500, 3800, 9400, 4400) | 4TH, 5TH arrows to K |
| J-cnt | page 19: (2800, 500, 4300, 1450); (3500, 300, 3900, 700) | J's V2' counter, 7442 `45`, the two buffers rising to K |

## Summary

- **Upper half: rank latches.** Fifteen 74174s in five columns of three, as
  on the original. They store D-1A…D-4D on the rank strobes 1ST…5TH and
  drive 1ST-1A…5TH-4D to J. **Changed: every /MR (pin 1) is tied to Vcc.**
  There is no LATCH CL input and no inverter for them: the Pro rank latches
  are never cleared.
- **Lower half: SUPER RACER SCORE.** A new circuit stores and shows one
  four-digit number:
  - three 74174s (43, 49, 57) latch the live score P-1A…P-4D (not the D bus)
    plus one constant 1 (57.13 = Vcc → 57.12, here called **FLAG**);
  - four cascaded 7485s (44, 50, 58, 67) compare the live score P (A inputs)
    with the stored value S (B inputs);
  - AND 66: CP of all three 174s = T.R.S · (67.5, A>B out);
  - /MR of all three 174s = **/LATCH CL** (from I, = /INI. RESET ·
    /RAM RESET);
  - two 74153s (42, 48) select one stored digit with *a, *b from J; a 9374
    (41) decodes it to seven segments; a 7442 (36) and four PNP drivers
    (TR11, TR12, TR9, TR10) pick the digit; the display is a 4-digit
    multiplexed LED unit, `SUPER RACER SCORE`, off-board (pads G…);
  - FLAG enables the digit decoder (through inverter 37) and lights a lamp
    `TODAY'S HIGH SCORE 10000PT.` (through 17 and TR15, pad Ge).
- **Corrections to the issue.** The counters are **74153 multiplexers**
  (printed `153`, 74153 pinout), not 74163s: nothing on K counts. The
  decoder/driver is a 9374 plus a 7442 digit decoder. The "TODAY'S HIGH
  SCORE lamp output" is captioned `TODAY'S HIGH SCORE 10000PT.`.

## Answer: how a score above 9999 is shown and kept

From the wiring of K, with sheet I's 56 and 65 as read in
`SHEET_I_TRACE.md` and re-checked here (I-tenk):

1. **What it compares.** The live score P (four decades, P-1 units … P-4
   thousands) against the stored value S on the outputs of 43/49/57. The
   comparison chain runs units (44) → tens (50) → hundreds (58) → thousands
   (67), so 67.5 is the four-digit result.
2. **What clocks it.** 66.8 = T.R.S AND 67.5, a rising edge on CP of all three
   174s. T.R.S is 65.Q (74123, non-inverted output, so a positive pulse) on
   sheet I. 65 fires on the falling edge of /GAME END only while 56, the
   10,000-point flip-flop, is set (B input = 56.Q). So the store happens once
   per game, at game end after the bonus payout, and only for a game whose
   thousands decade carried out, that is, a game that passed 9999.
3. **What it stores.** P-1…P-4 at that moment, that is, the score's four low
   digits (the counter wraps; the carry is what set 56), and FLAG = 1.
   Because of the comparator term, it stores only when the new four digits
   are at least the stored ones (see K-U1 for "at least" against "greater
   than"). The result is the best over-10,000 score since the last clear.
4. **What clears it.** /LATCH CL, on /MR of all three: S = 0000 and
   FLAG = 0. On I that is 73.11 = /INI. RESET · /RAM RESET, so power-up and
   the RAM RESET switch clear it. The 174s are on the ordinary supply, not on
   sheet I's battery rail: the value is lost at power-off, which matches the
   word "TODAY'S" in the lamp caption.
5. **The fifth digit.** **There is none on K.** Nothing stores or displays a
   ten-thousands digit. The display has four digit positions, fed with S4,
   S3, S2, S1. The 10,000 is carried by FLAG: FLAG = 1 enables the digit
   decoder and lights the `TODAY'S HIGH SCORE 10000PT.` lamp; FLAG = 0 blanks
   the display and the lamp. On I the same role is played for the live score
   by 56 and the `YOUR SCORE 10000POINT LAMP`. So as drawn the board shows a
   score above 9999 as "lamp lit + four digits", and keeps only the best such
   score of the day, in volatile 174s. It is not written to the 5101s
   (sheet I: 56 holds the after-game sequencer reset).
6. **Limits of the answer.** 56 is set-only until RST, so a game that passed
   19,999 would carry a second time without any new record of it: the four
   digits would show the score less 20,000, and the comparison would treat it
   like any other over-10,000 game. Whether such a score is reachable is not a
   wiring question. Whether the digit labels on the display unit mean what
   the wiring does is K-U4. The width of the T.R.S pulse (65's capacitor is
   unreadable on I) does not change the reading: only its rising edge
   matters. A second edge could occur only if P changed while T.R.S is high;
   whether anything can change P after /GAME END was not checked.

## Upper half: rank latches

### Column map

| Column / rank | Top | Middle | Bottom | CP, all pin 9 | /MR, all pin 1 | Box | Confidence |
|---|---|---|---|---|---|---|---|
| 1 / 1ST | 40 | 39 | 38 | riser x ≈ 2770 ← 1ST (row y ≈ 3650) | riser x ≈ 2690 → `Vcc` (ends y ≈ 3535) | c1; c1-left; rank-in | clear |
| 2 / 2ND | 47 | 46 | 45 | riser x ≈ 4265 ← 2ND (y ≈ 3745) | riser x ≈ 4180 → `Vcc` | col2 | clear; designators probable |
| 3 / 3RD | 53 | 52 | 51 | riser x ≈ 5765 ← 3RD (y ≈ 3830) | riser x ≈ 5680 → `Vcc` | col3 | clear; designators probable |
| 4 / 4TH | 61 | 60 | 59 | riser x ≈ 7285 ← 4TH (y ≈ 3920) | riser x ≈ 7190 → `Vcc` | col4 | clear; 61 probable |
| 5 / 5TH | 70 | 69 | 68 | riser x ≈ 8790 ← 5TH (y ≈ 4005) | riser x ≈ 8700 → `Vcc` | col5 | clear |

In column 1, 40.1, 39.1 and 38.1 leave the x ≈ 2690 riser at its top corner
(y ≈ 2655) and at T-junctions with dots (y ≈ 3045, 3445). The riser ends at
y ≈ 3535 above the word `Vcc`. The same arrangement, with `Vcc` under the
riser, is drawn in every column. The data rows cross both risers with
thickened crossings, not dots (a junction there would short a data input to
Vcc). The 40.1 row has a blot at x ≈ 2845 where the other packages show an
open bubble; it is read as the bubble.

### Pin table (every column; pin numerals drawn on column 1 only)

`r` = the column's rank prefix. Columns 2–5 have no pin numerals; their pins
are taken by position, the same as column 1.

| Position | D pin | From (I) | Q pin | To (J) | Confidence |
|---|---|---|---|---|---|
| top | 3 | D-1A | 2 | r-1A | clear |
| top | 4 | D-1B | 5 | r-1B | clear |
| top | 6 | D-1C | 7 | r-1C | clear |
| top | 11 | D-1D | 10 | r-1D | clear |
| top | 13 | D-2A | 12 | r-2A | clear |
| top | 14 | D-2B | 15 | r-2B | clear |
| middle | 3 | D-2C | 2 | r-2C | clear |
| middle | 4 | D-2D | 5 | r-2D | clear |
| middle | 6 | D-3A | 7 | r-3A | clear |
| middle | 11 | D-3B | 10 | r-3B | clear |
| middle | 13 | D-3C | 12 | r-3C | clear |
| middle | 14 | D-3D | 15 | r-3D | clear |
| bottom | 3 | D-4A | 2 | r-4A | clear |
| bottom | 4 | D-4B | 5 | r-4B | clear |
| bottom | 6 | D-4C | 7 | r-4C | clear |
| bottom | 11 | D-4D | 10 | r-4D | clear |
| bottom | 13, 14 | short stubs, open | 12, 15 | short stubs, open | probable (column 1 at full zoom; others at 0.62) |

Evidence: dbus and c1-drops. The sixteen taps on the D bus are staggered
from x ≈ 2775 (D-1A) to x ≈ 2120 (D-4D), each a rounded corner, and come down
in nested L-routes to 40.3, 40.4, 40.6, 40.11, 40.13, 40.14, 39.3 … 39.14,
38.3, 38.4, 38.6, 38.11, in that order, without any route crossing another.
Columns 2–5 repeat the staircase (col2…col5). Output routes: in column 1
the upper package's 12 and 15 jog down to 1ST-2A, 1ST-2B and the middle
package's 2 and 5 jog up to 1ST-2C, 1ST-2D, crossing without dots, exactly
as on the original. The output labels in columns 2–5 are ditto marks; the
column-5 labels (`5TH-1A` … `-4D`) are written out.

**Datasheet check (74174).** /MR 1, Q1 2, D1 3, D2 4, Q2 5, D3 6, Q3 7,
GND 8, CP 9, Q4 10, D4 11, Q5 12, D5 13, D6 14, Q6 15, Vcc 16. Every drawn
pin agrees. Pins 8 and 16 are not drawn.

## Lower half: SUPER RACER SCORE

### Net names used below

Rows read off the rulers (page 20):

| Net | Row y | Source |
|---|---|---|
| P-1A, B, C, D | 4185, 4230, 4272, 4316 | I (P bus, circled I) |
| P-2A, B, C, D | 4402, 4447, 4492, 4535 | I |
| P-3A, B, C, D | 4620, 4665, 4705, 4750 | I |
| P-4A, B, C, D | 4838, 4880, 4925, 4968 | I |
| /LATCH CL | 5010 | I (label overbarred on K and on I) |
| CLK (66.8) | 5318 | 66.8 |
| S1A, S1B, S1C, S1D | 5360, 5405, 5448, 5490 | 43.2, 43.5, 43.7, 43.10 |
| S2A, S2B, S2C, S2D | 5535, 5578, 5620, 5662 | 43.12, 43.15, 49.2, 49.5 |
| S3A, S3B, S3C, S3D | 5705, 5748, 5792, 5835 | 49.7, 49.10, 49.12, 49.15 |
| S4A, S4B, S4C, S4D | 5878, 5920, 5965, 6008 | 57.2, 57.5, 57.7, 57.10 |
| T.R.S | ≈ 6045 | I |
| FLAG | riser x ≈ 6688 | 57.12 |

### Comparators 44, 50, 58, 67 (printed `85`)

| Pin | 44 (units) | 50 (tens) | 58 (hundreds) | 67 (thousands) | Box | Confidence |
|---|---|---|---|---|---|---|
| 10 (A0) | P-1A (dot x ≈ 3545) | P-2A (3890) | P-3A (4225) | P-4A (4570) | cmp-taps | clear |
| 12 (A1) | P-1B (3590) | P-2B (3935) | P-3B (4268) | P-4B (4612) | cmp-taps | clear |
| 13 (A2) | P-1C (3630) | P-2C (3975) | P-3C (4310) | P-4C (4652) | cmp-taps | clear |
| 15 (A3) | P-1D (3675) | P-2D (4015) | P-3D (4350) | P-4D (4695) | cmp-taps | clear; 50.15 riser has a scan gap at y ≈ 4560–4770, probable |
| 9 (B0) | S1A | S2A | S3A | S4A | matrix (3450, 5250, 4850, 6060) | clear |
| 11 (B1) | S1B | S2B | S3B | S4B | matrix | clear |
| 14 (B2) | S1C | S2C | S3C | S4C | matrix | clear |
| 1 (B3) | S1D | S2D | S3D | S4D | matrix | clear |
| 2 (in A<B) | ground | 44.7 | 50.7 | 58.7 | casc; cmp23 | 44: probable (K-U1); others clear |
| 3 (in A=B) | ground | 44.6 | 50.6 | 58.6 | casc; cmp23 | 44: probable (K-U1); others clear |
| 4 (in A>B) | Vcc | 44.5 | 50.5 | 58.5 | casc; vcc; cmp23 | 44: probable; others clear |
| 5 (out A>B) | 50.4 | 58.4 | 67.4 | **66.9** | cmp23; g66 | clear |
| 6 (out A=B) | 50.3 | 58.3 | 67.3 | not drawn | cmp23 | clear |
| 7 (out A<B) | 50.2 | 58.2 | 67.2 | not drawn | cmp23 | clear |

Each B-input riser drops to its row and turns with a rounded corner; the
risers of the next comparators cross the rows without dots (matrix).

**Cascade inputs of 44 (casc, at 4× zoom).** A vertical at x ≈ 3428 starts
at a corner on the pin-2 row (y ≈ 5135), has a large dot on the pin-3 row
(y ≈ 5178), crosses the pin-4 row (y ≈ 5225) with a small thickening and ends
on a ground symbol. The pin-4 row runs left to the word `Vcc` (vcc). Read as:
2 and 3 to ground, 4 to Vcc. The reading with a junction at y ≈ 5225 would
short Vcc to ground, so it is rejected.

**Datasheet check (7485).** A0 10, A1 12, A2 13, A3 15, B0 9, B1 11, B2 14,
B3 1, cascade in A<B 2, A=B 3, A>B 4, out A>B 5, A=B 6, A<B 7. The drawn
pins agree. 44 has the internal labels `A 1 2 3` and `B0 1 2 3` written in.
With cascade inputs (A>B, A=B, A<B) = (H, L, L), the 7485 function table
gives out A>B = H when the four-bit words are equal. So 67.5 = **P ≥ S** as
read (K-U1). With the usual tie (A=B input high) it would be P > S. The
difference matters only when the new score equals the stored one.

### AND 66

| Pin | Connection | Box | Confidence |
|---|---|---|---|
| 9 | 67.5 | g66 | clear |
| 10 | Riser x ≈ 4795 from 66.10 down to y ≈ 6045, corner onto **T.R.S**. It crosses all sixteen S rows without dots | g66; matrix (4700, 5250, 5500, 6060); trs | clear |
| 8 | Row y ≈ 5318 → 43.9 (dot x ≈ 5735), 49.9 (dot x ≈ 6125), 57.9 (row ends in a corner at x ≈ 6520 and rises to pin 9) | g66; l174-bot | clear |

Symbol: D-shaped AND body, no bubbles. No type printed. 9, 10 → 8 fits
section 3 of a 7408.

### Latches 43, 49, 57 (printed `174`)

| Pin | 43 | 49 | 57 | Box | Confidence |
|---|---|---|---|---|---|
| 3 (D1) | P-1A (corner x ≈ 5478) | P-2C (5860) | P-4A (6258) | l174-taps | clear |
| 4 (D2) | P-1B (5520) | P-2D (5905) | P-4B (6305) | l174-taps | clear |
| 6 (D3) | P-1C (5565) | P-3A (5948) | P-4C (6345) | l174-taps | clear |
| 11 (D4) | P-1D (5608) | P-3B (5990) | P-4D (6385) | l174-taps | clear |
| 13 (D5) | P-2A (5650) | P-3C (6035) | **Vcc** (riser x ≈ 6430 from the vertical word `Vcc`) | l174-taps; l174-top | 43, 49 clear; 57 probable |
| 14 (D6) | P-2B (5692) | P-3D (6078) | not drawn | l174-taps | clear |
| 2 (Q1) | S1A | S2C | S4A | l174-bot; matrix | clear |
| 5 (Q2) | S1B | S2D | S4B | matrix | clear |
| 7 (Q3) | S1C | S3A | S4C | matrix | clear |
| 10 (Q4) | S1D | S3B | S4D | matrix | clear |
| 12 (Q5) | S2A | S3C | **FLAG**: down to y ≈ 5300, right across the pin-9 riser (no dot), to x ≈ 6688, then up | l174-bot; flag | 43, 49 clear; 57 probable |
| 15 (Q6) | S2B | S3D | not drawn | matrix | clear |
| 9 (CP) | CLK (dot) | CLK (dot) | CLK (corner) | l174-bot | clear |
| 1 (/MR, bubble) | /LATCH CL (dot x ≈ 5745) | /LATCH CL (dot x ≈ 6128) | /LATCH CL (end of the row, corner x ≈ 6515) | l174-top | clear |

The /LATCH CL row (y ≈ 5010) is the one that leaves the `/LATCH CL` arrow on
the left and rises to y ≈ 5007 (in-left). The 57.13 Vcc riser crosses it at
x ≈ 6430 with a thickening the size of the neighbouring crossings, not a dot
(K-U8). Pin numerals of all three are printed `3 4 6 11 13 14` on top and
`2 5 7 10 12 15 9` below (57: `3 4 6 11 13` and `2 5 7 10 12 9`). The 74174
pinout agrees with every drawn pin.

So S1 = units, S2 = tens, S3 = hundreds, S4 = thousands of the stored
value; P-1x feeds S1x, …, P-4x feeds S4x, bit for bit.

### Digit multiplexers 42, 48 (printed `153`)

| Pin | 42 | 48 | Box | Confidence |
|---|---|---|---|---|
| 14 (A select) | *a (riser x ≈ 6772, corner y ≈ 5145) | not drawn; the A and B rows cross the shared box edge at x ≈ 7380 with dot-like marks | sel zoom; mux | 42 clear; 48 probable |
| 2 (B select) | *b (riser x ≈ 6860, corner y ≈ 5187) | as above | sel zoom | 42 clear; 48 probable |
| 6 (1C0) | S1A (corner y ≈ 5357) | S1C | matrix (6900, 5280, 7850, 6060) | clear |
| 5 (1C1) | S2A | S2C | matrix | clear |
| 4 (1C2) | S3A | S3C | matrix | clear |
| 3 (1C3) | S4A | S4C | matrix | clear |
| 10 (2C0) | S1B | S1D | matrix | clear |
| 11 (2C1) | S2B | S2D | matrix | clear |
| 12 (2C2) | S3B | S3D | matrix | clear |
| 13 (2C3) | S4B | S4D | matrix | clear |
| 7 (1Y) | 41.7 (row y ≈ 4795) | 41.2 (y ≈ 4965) | mux (6900, 4700, 8050, 5130) | clear |
| 9 (2Y) | 41.1 (y ≈ 4880) | 41.6 (y ≈ 5050) | mux | 42 clear; 48 probable (K-U6) |
| 1, 15 (/G, bubbles) | not drawn | joined and grounded | ov; (6600, 4900, 8000, 5650) | 48 clear |

The two packages are drawn as one long box split by a vertical line at
x ≈ 7380: select pins on 42's left end, enables on 48's right end. The
crossing of the *a row with the *b riser at (6860, 5145) is a crossing
(sel zoom, 5×). **Datasheet check (74153):** /1G 1, B 2, 1C3 3, 1C2 4, 1C1 5,
1C0 6, 1Y 7, GND 8, 2Y 9, 2C0 10, 2C1 11, 2C2 12, 2C3 13, A 14, /2G 15,
Vcc 16. The drawn pins agree.

**Function.** With select (B, A) = (*b, *a) = n, the four outputs carry
stored digit n+1: 00 → S1 (units), 01 → S2, 10 → S3, 11 → S4 (thousands).
Bit order into the decoder: 42.7 = bit A, 42.9 = bit B, 48.7 = bit C,
48.9 = bit D.

### Seven-segment decoder 41 (printed `9374`)

| Pin | Connection | Box | Confidence |
|---|---|---|---|
| 7 | 42.7 (bit A) | 9374; mux | clear |
| 1 | 42.9 (bit B) | 9374; mux | clear |
| 2 | 48.7 (bit C) | 9374; mux | clear |
| 6 | 48.9 (bit D) | 9374; mux | clear (row); source probable |
| 13, 12, 11, 10, 9, 15, 14 | Through a column of eight drawn rounded boxes and pads to display inputs a, b, c, d, e, f, g, in that order | 9374; pads; disp | routing clear; box column and pad labels uncertain (K-U4) |
| 8 | Up to an arrow `LAMP RET.` (circled J) | ret (7950, 4550, 8300, 4800) | clear |
| 3 (bubble) | Down (x ≈ 8090) to y ≈ 5790, right to a second arrow `LAMP RET.` (circled J). It crosses the 37.8 → 17 row at (8090, 5480) with no dot | 9374 low; j3 (6× zoom); ret (9200, 5650, 9900, 5950) | clear |
| 4, 5, 16 | Not drawn | 9374 | |

**Datasheet check.** The 9374 datasheet was not available for this trace.
The drawn inputs (7, 1, 2, 6 = A0–A3), segment outputs (13 a … 9 e, 15 f,
14 g) and ground (8) match the common 7447/9368-family pinout. In that
family pin 3 is 7447's /LT or 9368's /LE (latch enable, active low). Tied to
LAMP RET (a ground return), /LT would light every segment all the time; /LE
would leave the latch transparent. Only the second gives a working display,
so pin 3 is probably the latch enable. Recorded, not settled (K-U2). LAMP
RET on J goes to the `LAMP RETURN` pad group (page 19, overview at 0.15 near
(1200, 1480); read at overview scale only), so 41 has
its ground on the lamp return, not on logic ground.

### Digit decoder 36 (printed `42 36`: type 7442, designator 36) and inverter 37

| Pin | Connection | Box | Confidence |
|---|---|---|---|
| 36.15 (A) | *a (dot on the *a row at x ≈ 6772) | dec | clear |
| 36.14 (B) | *b (dot at x ≈ 6858) | dec | clear |
| 36.13 (C) | 37.8 (dot at x ≈ 7495) | dec | clear |
| 36.12 (D) | V2' (circled I) | dec | clear |
| 36.1 (/0) | 07.1 | dec; drv | clear |
| 36.2 (/1) | 07.9 | dec; drv | clear |
| 36.3 (/2) | 07.5 | dec; drv | clear |
| 36.4 (/3) | 07.13 | dec; drv | clear |
| 37.9 | FLAG: row y ≈ 4362 from the corner at x ≈ 6688; the riser crosses V2' at y ≈ 4450 with no dot | flag; dec | probable (K-U8) |
| 37.8 | 36.13, and from the dot at x ≈ 7495 down (crossing V2' without a dot), along y ≈ 4615 to x ≈ 7930, down across 41's four input rows without dots, to y ≈ 5480 and right to 17's input | dec; 9374; 9374 low; lamp | probable (several crossings, K-U8) |

37 is drawn as an inverter (triangle, output bubble), `37` written inside, no
type. **Datasheet check (7442):** outputs 0–3 on 1–4, A 15, B 14, C 13, D 12.
The drawn pins agree. Outputs 4–9 are not drawn.

**Function.** 36 decodes 0–3 only when C = 0 and D = 0, that is, FLAG = 1
and V2' = 0. So the display is dark until something has been stored since
the last /LATCH CL, and lit only in the V2'-low half of each V2' period.

### Digit drivers

| Part | Reading | Box | Confidence |
|---|---|---|---|
| 07, four sections | Triangles with a bubble on the input and on the output; `07` above the group; an illegible glyph inside each. Sections 1 → 2, 9 → 8, 5 → 6, 13 → 12 | drv; 07 zoom | pins clear; type uncertain (K-U3) |
| R38, R37, R40, R39 | `560` each: 07.2 → R38, 07.8 → R37, 07.6 → R40, 07.12 → R39 | drv | values clear; names probable |
| TR10, TR9, TR12, TR11 | `A684`, PNP (emitter arrow). Bases ← R38, R37, R40, R39. Emitters on the `LAMP V` row (circled J), dots at x ≈ 8870, 9100, 9340 and the TR11 riser from x ≈ 8635 | drv | clear |
| Collectors | TR10 → pad **G23**, TR9 → **Gb**, TR12 → **G24**, TR11 → **Gc** → the top of the display unit | drv; commons | clear; G-labels probable |
| Crossings | The R38, R37 and R40 rows cross the TR11 emitter riser (x ≈ 8635) with thickenings smaller than the LAMP V dots. Read as crossings | drv | probable (K-U8) |

The pin numbers fit a hex buffer of the 7406/7407/7416/7417 family. With
bubbles on both sides the drawn function is non-inverting: an active-low 7442
output pulls its PNP base low and turns that digit on. An inverting reading
would turn three digits on at once, so non-inverting fits.

### Display unit

| Item | Reading | Box | Confidence |
|---|---|---|---|
| Outline | Box with seven segment inputs a–g on the left, four digit outlines, a dashed surround and a diagonal dashed line (the same drawing style as sheet I's lamp unit), caption `SUPER RACER SCORE` | disp; lamp | clear |
| Segments | Inside the box, segment lines run across all four digits (tick marks on the digit separators): the digits share a–g | disp | probable |
| Commons, left to right | Gc (TR11), G24 (TR12), Gb (TR9), G23 (TR10) | commons | probable (position in one outline) |
| Digit labels, left to right | `×1000`, `×1000`, `×10`, `×1`. The first is blotted (a fourth zero is possible); the second clearly has three zeros | labels | uncertain (K-U4) |
| Segment pads | Labels beside the seven rows, top to bottom, read approximately `G27`, `G?`, `G28`, `G29`, `G?`, `G30?`, `G?` | pads | uncertain |
| Rounded-box column between 41 and the pads | Eight rounded boxes stacked in one outline, no type or value | pads | uncertain: series resistors or a connector symbol |

**Digit to data, from the wiring.** (*b, *a) = 00: 153 inputs C0 = S1, 7442
/0 → 07.1 → TR10 → G23 → rightmost digit `×1`. 01: S2 → TR9 → Gb → `×10`.
10: S3 → TR12 → G24 → second digit. 11: S4 → TR11 → Gc → leftmost digit.
So the display reads S4 S3 S2 S1 from left to right. The second digit,
labelled `×1000`, carries the hundreds by wiring. This mapping does not depend
on the polarity of *a and *b, because the select and the decoder take the same
two lines.

### TODAY'S HIGH SCORE lamp

| Part | Reading | Box | Confidence |
|---|---|---|---|
| 17 | Triangle with input and output bubbles, `17` above, output pin `2`; the input numeral is not legible. Input ← 37.8 | lamp; 17 zoom | probable |
| Resistor | `1K`, name read `R44` (blotted) | 17 zoom | value probable; name uncertain |
| TR15 | `A684`, PNP. Base ← 1 kΩ; emitter → row y ≈ 5450 → riser at x ≈ 9525 up to the LAMP V row; collector → pad `Ge` | lamp | probable |
| Lamp | Lamp symbol from Ge to a ground symbol. Caption `TODAY'S HIGH SCORE 10000PT.` | lamp | clear |

17.2 is low when 37.8 is low, that is, when FLAG = 1. The lamp is lit
exactly while the SUPER RACER SCORE display is enabled.

## Off-sheet signals

All from or to circled letters (no pads) unless a pad is given. Direction is
relative to K.

| Signal (as written on K) | Pad | Dir. | Other sheet | Loads or source on K | Confidence |
|---|---|---|---|---|---|
| D-1A … D-4D | none | in | I | Rank latch D inputs, all five columns | clear |
| 1ST, 2ND, 3RD, 4TH, 5TH | none | in | I (259 drawn `10`, I-rank) | Rank latch CP risers | clear |
| 1ST-1A … 5TH-4D (80 lines) | none | out | J | Rank latch Q outputs | clear |
| P-1A … P-4D | none | in | I | 7485 A inputs; 43/49/57 D inputs | clear |
| /LATCH CL | none | in | I (73.11) | 43.1, 49.1, 57.1 | clear |
| T.R.S | none | in | I (65.13) | 66.10 | clear |
| *a, *b | none | in | J | 42.14, 42.2 (and 48 by the shared box); 36.15, 36.14 | clear on K; J side probable |
| V2' | none | in | I (from pad HU, E) | 36.12 | clear |
| LAMP V | none | in (supply) | J | TR9–TR12 and TR15 emitters | clear |
| LAMP RET. (two arrows) | none | out (return) | J | 41.8 and 41.3 | clear |
| Display commons | Gc, G24, Gb, G23 | out | off-board SUPER RACER SCORE unit | TR11, TR12, TR9, TR10 collectors | probable |
| Display segments a–g | seven G pads, labels uncertain | out | same unit | 41 outputs | uncertain labels |
| TODAY'S HIGH SCORE lamp | Ge | out | cabinet lamp | TR15 collector | probable |
| Vcc | label only | supply | | 174 /MRs (15), 57.13, 44.4 | clear |

Not on Pro K: the original's **LATCH CL to the rank latches** (11D inverters).

## Interface checks on I and J

| Point | What was seen | Box | Confidence |
|---|---|---|---|
| T.R.S on I | 65 (`123/2`): /A 1 ← the /GAME END row (dot), B 2 ← 56.Q (riser, then the 72.4 row), /CLR 3 ← Vcc, **Q 13** → arrow `T.R.S` (circled K). Q is the non-inverted output: T.R.S is a positive pulse | I-tenk | clear |
| 56 on I | `74/2`, D 12 = Vcc, CK 11 ← an inverter (1 → 2) with C6 680 pF, Q 9 → 72.4, 65.2 and lamp inverter 06 → R42 1 kΩ → TR14 → G25 → `YOUR SCORE 10000POINT LAMP`. /CL 13 from above. The CK source (P-4D) and /CL source (RST) were not re-traced here | I-tenk | as in the I trace |
| LATCH CL. on I | Arrow labelled `LATCH CL.` with an overbar, circled K, at x ≈ 2215 | I-lcl | clear |
| V2' | Pad HU `V2` on I; arrow to circled K and J (I-hu). K labels it `V2'`, J's counter clock input is also `V2'` (J-cnt) | I-hu; J-cnt | clear |
| 1ST–5TH | Arrows to circled K, bracketed (I-rank) | I-rank | clear |
| D-4A…D-4D on I | Four arrows to circled K, tapped with dots at x ≈ 7160–7300 from rows y ≈ 3615–3750 | I-d4 | clear for the taps |
| D bus source | Which row family on I those taps belong to (5101 DO rows or the 192 / comparator-B rows) was **not** re-traced. On K the D bus feeds only the rank latches, so this question (I trace U7) does not touch SUPER RACER SCORE | | not checked |
| *a, *b on J | Two upward arrows above two triangles drawn with a bubble on the input side, at x ≈ 3645 and 3705, near J's 393/2 counter (CP ← V2') and 7442 `45`. The arrow labels are blotted | J-cnt | probable; polarity and sources not traced |

**Correction to the premises.** The issue and the sheet I trace say K
"possibly receives a D bus tapped from the 192 counter rows". That is true of
the rank latches only. **SUPER RACER SCORE takes the live score P directly,
not the D bus.** And LATCH CL no longer clears the rank latches at all: on
Pro it clears only the SUPER RACER SCORE latches.

## Comparison with the original by function and net

| Function | Original (420-0358 p24, 96597-P D-3/3) | Pro (420-0525 p20, 96824-P D-3/3) | Confidence |
|---|---|---|---|
| Rank storage | 15 × 74174, five columns, D-1A…D-4D → r-1A…r-4D, pins as in the table | The same, same pins and output jogs | clear |
| Rank clocks | 1ST…5TH from I on pin 9 | The same | clear |
| Rank clear | LATCH CL (I) → 11D inverters (two sections) → /MR | **/MR tied to Vcc**, no inverters: never cleared | clear |
| Unused 174 pins | bottom package 13, 14, 12, 15 open stubs | The same | probable |
| LATCH CL use | Rank latch clear, active high on K | `/LATCH CL`, active low, clears 43/49/57 only | clear |
| T.R.S | none | New input from I (65) | clear |
| P bus on K | none | New: comparators and SUPER RACER SCORE latches | clear |
| Comparator 4 × 7485 | none | New | clear |
| Latches 43/49/57, AND 66 | none | New | clear |
| 74153 × 2, 9374, 7442, 37, 07, TR9–TR12 | none | New: multiplexed 4-digit display | clear |
| 17, TR15, TODAY'S HIGH SCORE lamp | none | New | probable |
| *a, *b, V2', LAMP V, LAMP RET | none on K | New inputs/returns from J and I | clear |
| Designators | 9A…7E (grid) | Numbers (40…68 for the rank latches) | clear; no functional meaning |

## Uncertainties and what would settle them

| ID | Uncertain | What would settle it |
|---|---|---|
| K-U1 | 44's cascade inputs read as 2, 3 → ground and 4 → Vcc (casc, (3380, 5100, 3560, 5320)), which makes 67.5 = P ≥ S. The usual tie (3 high) would give P > S. Only equal scores are affected | A sharper scan of that corner, or continuity |
| K-U2 | 41 is printed `9374`; its pin 3 is tied to LAMP RET. Read as a latch enable (9368-family), not lamp test | The 9374 datasheet |
| K-U3 | Type of 07 and 17 (glyph inside illegible); drawn non-inverting | Parts list of 96824-P, or the board |
| K-U4 | Display digit labels (`×1000`, `×1000`, `×10`, `×1` as read; the wiring makes the second digit the hundreds); segment pad labels; the rounded-box column type | A sharper scan, the display unit, or the cabinet wiring for connector G |
| K-U5 | Designators 44, 58 (second digit blotted), 43, 37, 07, 17, R44; column 3 and 4 designators (53/52/51, 61/60/59) | A sharper scan or the board silkscreen |
| K-U6 | 48.9: the pin-9 stub ends short; the line to 41.6 leaves the box edge at x ≈ 7650 (mux (7380, 5050, 7850, 5300)). Read as 48.9 because the route runs along the box edge | Continuity |
| K-U7 | The 50.15 riser (P-2D) has a scan gap at y ≈ 4560–4770 (cmp-taps) | A sharper scan |
| K-U8 | Crossings read as crossings although thickened: FLAG riser × V2' (6688, 4450); 37.8 route × V2' (7495, 4450) and × 41's input rows (x ≈ 7930); 57.13 Vcc riser × /LATCH CL (6430, 5010); TR11 emitter riser × R38/R37/R40 rows (x ≈ 8635). Every junction reading would short two drivers or a driver to a rail | Continuity |
| K-U9 | Polarity and source of *a and *b on J (blotted labels, input-bubbled buffers) | A trace of sheet J. It does not change K's digit-to-data mapping |
| K-U10 | Timing: T.R.S width (65's capacitor unreadable on I) and whether P can change while T.R.S is high | A timing model with sheets F and N; not a reading problem |
| K-U11 | A game passing 19,999 would wrap a second time with 56 already set | Not a reading problem; whether such scores occur is outside the schematic |

## Short report

**Established** (from the drawn wiring, not measured):

- Rank latches: 15 × 74174, D bus → 1ST…5TH outputs to J, same pins as the
  original; **/MR tied to Vcc** on Pro (no LATCH CL, no inverters).
- SUPER RACER SCORE: 43/49/57 (74174) latch P-1…P-4 plus a constant 1
  (FLAG) on 66.8 = T.R.S · 67.5; four cascaded 7485s compare P (A) with the
  stored S (B); /LATCH CL clears S and FLAG.
- Display: two 74153s (not 74163s) select S1…S4 by *a/*b from J; 9374 drives
  segments; 7442 36 (C = NOT FLAG via 37, D = V2') and 07/TR9–TR12 drive four
  digit commons; the display reads S4 S3 S2 S1 left to right.
- FLAG lights `TODAY'S HIGH SCORE 10000PT.` (17, TR15, Ge) and enables the
  display.
- **Above 9999:** with 56 (I) set, /GAME END fires T.R.S and K stores the
  four low digits if they are at least the stored ones. The ten-thousands
  digit is not stored or displayed; the FLAG lamp stands for it. The value is
  the day's best over-10,000 score, lost at power-off, cleared by RAM RESET.

**Still uncertain:** K-U1 (≥ against >), K-U2 (9374 pin 3), K-U3 (buffer
type), K-U4 (digit labels, segment pads), K-U5 (designators), K-U6, K-U7,
K-U8 (thickened crossings), K-U9 (*a/*b on J), K-U10, K-U11.

**Not checked:** sheet J beyond the *a/*b/V2' origin; the D bus source on I
(I trace U7); 56's clock and clear sources on I; supply pins (not drawn);
the timing of T.R.S against the comparators. No HDL, test or other document
was changed.
