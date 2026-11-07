# Second reading: Pro sheets I and K (scores over 9999, score memory)

Date: 2026-11-06. Issue #81. An independent second reading of the items the
issue lists from `pro/docs/trace/SHEET_I_TRACE.md` and
`pro/docs/trace/SHEET_K_TRACE.md`.

## Method

- Source: `pro/schematics/promonacogp420-0525_1.pdf` only. Page 18
  (sheet I, 10184 × 6617) and page 20 (sheet K, 10200 × 6617), rendered
  with PyMuPDF at `Matrix(1, 1)`, upright. Every box is
  (left, top, right, bottom) on that render; a multiplier after a box is
  the zoom it was viewed at.
- Order: I read every item from my own crops and wrote the readings down
  **before** opening either trace. Only then did I read the traces and
  compare. I did not open the Verilog from #73 / PR #94.
- Junctions: only drawn dots count. Thickened crossings were compared with
  real dots nearby.
- Pinouts used only as a check: 7474 (second half: /CLR 13, D 12, CK 11,
  /PR 10, Q 9, /Q 8), 74123 (/A 1, B 2, /CLR 3, Q 13, Cext 14, Rext/Cext 15),
  74390 (second half: CKA 15, CLR 14, QA..QD 13, 11, 10, 9; GND 8),
  74393, 7442, 5101/2101A (CE2 17, OD 18, /CE1 19, R/W 20, Vcc 22, GND 8),
  7485 (cascade in A<B 2, A=B 3, A>B 4; out A>B 5, A=B 6, A<B 7),
  74174 (/MR 1, CP 9, D 3, 4, 6, 11, 13, 14; Q 2, 5, 7, 10, 12, 15),
  74153 (/1G 1, B 2, 1C3..1C0 3..6, 1Y 7, 2Y 9, 2C0..2C3 10..13, A 14,
  /2G 15). No drawn numeral on the items below disagreed with them.

## Results

| # | Item | My reading (before the traces) | Trace's reading | Verdict | Crop boxes (page) |
|---|---|---|---|---|---|
| I-1 | 56: what sets it | 56 is a D flip-flop half (`74/2`). D 12 = Vcc. CK 11 = output 2 of an inverter (1 → 2, label blotted), with C6 680 pF (`セラ`) from CK to ground. The inverter input is the row y≈5311, east to a riser at x≈4222, which starts with a dot at (4221, 3750) on the P-4D row (IC84 pin 9, QD of the thousands 390 half; the same row carries the P-4D arrow at x≈3662). So 56 sets when the thousands QD falls, i.e. on the 9999 → 10000 carry. Q 9 → 06 (13 → 12) → R42 1 kΩ → TR14 (A684) → G25, `YOUR SCORE 10000POINT LAMP`; Q 9 also → 72.4 and 65.2 | D = Vcc, CK ← inverter of P-4D (dot at about (4221, 3750)), C6 680 pF; Q → 72.4, 65.2, 06 lamp; CK source probable | **agree** | (2450, 5100, 3600, 6150) ×1.4; (2700, 5440, 3250, 5800) ×3; (3900, 4200, 5600, 5400) ×0.9; (3550, 3350, 4950, 4500) ×1.2; (2600, 3200, 3700, 4150) ×1.4 (p18) |
| I-2 | 56: what clears it | /CL 13 = trunk x≈3064 from above. Up that trunk: a dot at 90 /CL 13 (y≈3900), then an inverter (3 → 4, label read `44` or `64`, blotted), whose input continues up to dots on the two IC84 CLR pins (14 and 2): the counter clear trunk x≈3060, which leaves 91.3 on the row y≈2343 = NAND(/COIN & TEST, 73.11) (OR body, input bubbles). So /CL = NOT(COIN & TEST + INI. RESET + RAM RESET). The trunk crosses the /GAME END, RAM RESET and 72/73 rows above 56 without dots (5×) | /CL = /RST through inverter 64 (3 → 4), RST = 91.3 = COIN & TEST + INI. RESET + RAM RESET; probable | **agree** | (2600, 3200, 3700, 4150) ×1.4; (2950, 3740, 3250, 3980) ×4; (1300, 1500, 3500, 3300) ×0.75; (2940, 5170, 3120, 5340) ×5 (p18) |
| I-3 | The gate that replaces GAME with /GAME END | 72 (5, 4 → 6) is drawn as an AND body with bubbles on both inputs and the output; 72's 8, 9, 10 section is a plain OR body, so 72 is an OR package and 72.6 = /GAME END + 56.Q. Pin 5 = `/GAME END` (pad HP, RA3 pin 7; the row has one dot at x≈2500, down to 65.1). Pin 4 (numeral partly hidden) = 56.Q. 72.6 → 73.5 | 72 OR: 5 = /GAME END, 4 = 56.Q; "4" numeral probable | **agree** | (1300, 4600, 4200, 6150) ×0.6; (2450, 5100, 3600, 6150) ×1.4; (2650, 3950, 3050, 4700) ×2 (p18) |
| I-4 | 65 and T.R.S | 65 (`123/2`): /A 1 (bubble) = /GAME END (dot at about (2500, 5221)); B 2 = 56.Q; /CLR 3 = Vcc; Q 13 → arrow `T.R.S` (circled K). Timing: a capacitor (`.01`/`1µ`, overwritten) between 14 and 15, and a resistor (`47K` probable, name blotted) from 15 to Vcc. So T.R.S is a positive pulse on /GAME END falling while 56 is set (or 56 rising while /GAME END is low) | Same pins; R57 47 kΩ; capacitor value uncertain; T.R.S positive pulse | **agree** (resistor name not readable here; the trace's `R57` is not confirmed or contradicted) | (2450, 5100, 3600, 6150) ×1.4; (2700, 5440, 3250, 5800) ×3 (p18) |
| I-5 | RAM RESET switch and gate 73 | SW.1 (`RAM RESET`) is a normally-open contact from a ground mark to a node; RA3 1 kΩ (pin 8) pulls the node to Vcc; a filled blot hangs below the node (illegible). The node row goes right to the trunk x≈2158. Dots on that trunk: 91.9 (y≈4850) and 73.4 (y≈5180); further up it is the pin-12 input of the 11-12-13 gate (label read `73` or `93`). 73 (4, 5 → 6): OR body with bubbles on inputs and output = AND. 73.6 = /RAM RESET · 72.6 → 92 second half MR 12, with C3 470 pF to ground. So the address/sequencer counter runs only while RAM RESET is pressed, or while /GAME END is low with 56 clear | Switch, RA3 pull-up, /RAM RESET trunk at x≈2160 to 73.12, 73.4, 91.9; 73 AND; 92b MR 12 ← 73.6 with C3 | **agree** | (1300, 5350, 2300, 5900) ×1.8; (2050, 4250, 2650, 5300) ×1.2; (2000, 3700, 4300, 5450) ×0.75; (2000, 2250, 2450, 2700) ×2.5 (p18) |
| I-6 | RAM chip select and R/W protection | Four 5101s (97, 96, 95, 74). /CE1 19 (bubble) tied to 8 and ground on each. CE2 17 of all four on one node: R43 4.7 kΩ from Vcc, C4 22 µ 16 V to ground, D10 (MA-150) anode on the node, cathode on the Vcc end of R43. R/W 20 (bubble) of all four on one line = 7442 (82) pin 3, with R64 1 kΩ from that line to the thick rail. Pin 22 of all four on the thick rail: Vcc → D9 (SiB01-02) → rail → R62 56 Ω → HX → Ni-Cd battery → H20. A blot above a crossing on the rail near (4050, 2727) is ink, not a dot (5×) | Same: /CE1 grounded, CE2 on PWR-OK (R43/C4/D10, D10 anode on the node), R/W = 82.3 with R64 to the battery rail, pin 22 on the D9/R62 rail | **agree** | (3750, 2400, 5550, 4250) ×0.85; (4400, 3750, 5800, 4700) ×1.2; (5330, 4130, 5750, 4420) ×3.5; (3550, 3350, 4950, 4500) ×1.2; (4000, 5300, 5500, 6150); (3950, 2650, 4150, 2800) ×5 (p18) |
| I-7 | 8-V2 write delay after /INI. RESET | 92 first half (`393/2`): CP 1 = 81.10; 81 (8, 9 → 10) is an AND body with input bubbles = NOR; 81.9 = HU `V2`, 81.8 = this half's QD 6 (dot at y≈4400). MR 2 = 83.12, 83.13 = /INI. RESET (the /INI. RESET trunk turns into 83.13). QD 6 also → 91.5. 91 (5, 4 → 6) NAND; 91.4 = 92 second half QA 11; 91.6 → 82 pin 12 (D). 82 A, B, C (15, 14, 13) = second half QB, QC, QD (10, 9, 8). So 82 is held off (D high) until the first half has counted eight V2 periods after /INI. RESET ends; R/W = 82.3 cannot go low before that | Same: 92a counts eight V2 periods after /INI. RESET and stops; 82.12 = NAND(92a QD, 92b QA) | **agree** | (2000, 3700, 4300, 5450) ×0.75; (2050, 4250, 2650, 5300) ×1.2; (2650, 3950, 3050, 4700) ×2; (3300, 3950, 4000, 4900) ×1.5 (p18) |
| K-1 | Gate 66 | 66 (9, 10 → 8): D-shaped AND body, no bubbles. 66.9 = 67.5 (A>B out of the last 7485). 66.10 = riser x≈4800 straight down to the T.R.S row (y≈6045), corner join (a blob of ink at the corner); it crosses the sixteen stored-value rows with thickened crossings, not dots (2×). 66.8 → row y≈5315 → CP of 43, 49, 57 | 66.8 = T.R.S · 67.5; 10 riser crosses the S rows without dots | **agree** | (4500, 5000, 5600, 6150) ×1.3; (4700, 5250, 4900, 6120) ×2; (3300, 4900, 5250, 5400) ×0.85 (p20) |
| K-2 | First comparator's cascade inputs (K-U1) | 44: pin 2 row → corner on a vertical at x≈3428; pin 3 row → a large dot on that vertical; the vertical ends on a ground symbol. Pin 4 row runs left to the word `Vcc` and crosses the ground vertical with a small thickening, much smaller than the pin-3 dot. So 2, 3 = ground, 4 = Vcc: with equal words 44.5 = H, and the chain (7 → 2, 6 → 3, 5 → 4 between stages) gives 67.5 = **P ≥ S** (A = P, B = stored) | 2, 3 → ground, 4 → Vcc, so P ≥ S; probable | **agree** (I would rate it clear: the pin-3 dot and the pin-4 crossing look plainly different at 3×, and the other reading shorts Vcc to ground) | (3300, 5050, 3800, 5350) ×3.2; (3050, 5100, 3500, 5320) ×3 (p20) |
| K-3 | Clocks and /MR of 43, 49, 57 | CP 9: 43.9 and 49.9 drop to dots on the row y≈5315; 57.9 drops to that row's end and joins it at a corner. The row leaves 66.8. /MR 1 (bubble): 43.1 and 49.1 rise to dots on the row y≈5007; 57.1 is that row's end (corner). That row is the one that leaves the `/LATCH CL` arrow on the left and steps up at x≈2220 (p20). The blot by 49's lower right corner is ink on the box corner, not a wire (4×) | CP ← 66.8 (dots on 43, 49; corner on 57); /MR ← /LATCH CL (dots on 43, 49; corner on 57) | **agree** | (5350, 4850, 6650, 5450) ×1.25; (5980, 5050, 6280, 5350) ×4; (6100, 4850, 6700, 5350) ×2.5; (1600, 4500, 5600, 5250) ×0.42 (p20) |
| K-4 | 57 pin 13 tied to Vcc | The vertical word `Vcc` sits above a riser at x≈6430 that comes down into the fifth top position of 57. Labels sit to the left of their stems (`3 4 6 11 13`), so that stem is pin 13 (D5). The riser crosses the /LATCH CL row with a thickening the size of the neighbouring crossings (pin 11's), not a dot (6×). Pin 14 is not drawn. Below, Q5 12 (stem right of `10 12`) goes down, right and up the box's right side: the constant 1 output | 57.13 = Vcc, 57.12 = FLAG; crossing with /LATCH CL is not a dot (K-U8); probable | **agree** | (6100, 4850, 6700, 5350) ×2.5; (6380, 4920, 6560, 5110) ×6 (p20) |
| K-5 | Rank latches' /MR tied to Vcc | Column 1: 40.1, 39.1 and 38.1 join a riser (dots) that ends above the word `Vcc`; CP 9 of all three on a separate riser down to 1ST. Columns 2–5: the same drawing, `Vcc` under the /MR riser, read on the middle and bottom packages | /MR tied to Vcc in all five columns; no LATCH CL on the rank latches | **agree** (top packages of columns 2–5 not re-read here) | (2450, 2250, 3300, 3600) ×0.9; (3600, 2900, 4400, 3650), (5080, 2900, 5880, 3650), (6600, 2900, 7400, 3650), (8100, 2900, 8900, 3650) ×0.7 (p20) |
| K-6 | /LATCH CL's sources | On K the `/LATCH CL` arrow (circled I) is the only source; its row goes only to 43.1, 49.1, 57.1. On I it is the trunk x≈2222 that leaves a dot at (2222, 2365) on the output 11 of the 11-12-13 gate (OR body, all bubbles = AND; label `73` or `93`). Inputs: 13 = /INI. RESET (dot), 12 = /RAM RESET (trunk x≈2158). The trunk runs down to the arrow with no dot between y 4250 and 5300 (1.2×). So /LATCH CL = /INI. RESET · /RAM RESET | 73.11 = /INI. RESET · /RAM RESET; probable on I, clear on K | **agree** | (2000, 2250, 2450, 2700) ×2.5; (2050, 4250, 2650, 5300) ×1.2; (1300, 4600, 4200, 6150) ×0.6 (p18); (1600, 4500, 5600, 5250) ×0.42 (p20) |
| K-7 | Display multiplexers read as 74153 | Two boxes printed `153`, designators 42 and 48, drawn as one long box split by a line. 42: A 14, B 2 on the left; inputs 6, 5, 4, 3 and 10, 11, 12, 13 below; outputs 7 and 9 above. 48: same inputs; 1 and 15 (bubbles) joined and grounded. All drawn numerals fit the 74153 pinout. Outputs: 42.7 → 41 (9374) pin 7, 42.9 → 41.1, 48.7 → 41.2, 48.9 → 41.6 | 74153, not 74163; same pins and outputs | **agree** | (6600, 4600, 8200, 5400) ×1.0 (p20) |

**Count:** 14 items. **Agree 14**, disagree 0, can't settle 0.

## Other things seen (not asked; no verdict)

- **A line from IC84 "pin 8" to 56.** From the bottom of the lower IC84
  (`390`) box a stem numbered `8` runs down to y≈3945, left to x≈3014 and
  down beside the 56 /CL trunk to the top-left corner of 56's box, where
  it stops with no pin numeral and no bubble. On a 74390, pin 8 is GND; on
  a 7474 the only undrawn pins of the second half are /PR 10 (and GND 7 for
  the package). Neither trace mentions this line. Read as a crossing-free
  route that ends on the box outline; I cannot say whether it is a ground
  drawn to 56's package or a /PR connection (the latter would hold 56's Q
  high with /CL inactive, which does not fit the rest of the circuit).
  What would settle it: a sharper scan of (2950, 3740, 3250, 3980) and
  (2900, 5330, 3150, 5500), or continuity on a board. Boxes: (2950, 3740,
  3250, 3980) ×4; (2900, 5330, 3150, 5500) ×4; (2000, 3700, 4300, 5450)
  ×0.75 (p18).
- **72.9 source.** Two lines reach the top of the 92 first half: one under
  the `3,4,5` label group (to 72.9), one under `6` (to 81.8 and 91.5). The
  I trace reads the first as QC 5 (numeral probable). I could not separate
  the `5` from the `6` label with confidence. Not one of the items; it
  does not touch the 8-V2 delay (91.5 is on the `6` line with a dot).
  Box (2650, 3950, 3050, 4700) ×2 (p18).
- **Gate labels.** The 11-12-13 gate feeding /LATCH CL reads `73` or `93`
  (first digit malformed); the 56 /CL inverter reads `44` or `64`. The
  traces use 73 and 64. Labels only; the functions agree.

## Short report

**Established:** an independent reading of all 14 items agrees with the I
and K traces: 56 sets on the P-4D fall and clears on RST; 72 (OR) puts
/GAME END where GAME was, with 56.Q; 65 fires T.R.S on /GAME END while 56
is set; RAM RESET (SW.1) and 73 (AND) free the sequencer; CE2 on the
R43/C4/D10 node, /CE1 grounded, R/W from 82.3 with R64 to the battery rail;
the 8-V2 delay through 92a, 91 and 82.12; on K, 66 = T.R.S · 67.5 clocks
43/49/57, /MR of those three is /LATCH CL (= /INI. RESET · /RAM RESET),
57.13 = Vcc, the rank latches' /MR = Vcc, the first 7485's cascade gives
P ≥ S, and 42/48 are 74153s.

**Ran:** PyMuPDF renders and crops of pages 18 and 20 only. No tests (no
code changed).

**Still uncertain:** the line from IC84 pin 8 ending on 56's corner (above);
72.9 from QC or QD; the 65 timing resistor's name; gate labels 73/93 and
44/64.

**Not checked:** anything outside the 14 items: the search clock, 192 and
comparator rows on I, the bonus lamp PROMs, the D-bus source (I trace U7),
the 9374, 7442 36, drivers and display on K, sheet J. No trace, HDL or
test was changed.
