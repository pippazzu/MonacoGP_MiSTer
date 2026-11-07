# Second reading: the +200 path (Pro sheets M and C)

Date: 2026-11-06. Issue #82. An independent second reading of the items
the issue lists from `pro/docs/trace/SHEET_M_C_PLUS200_TRACE.md`.

## Method

- Source: `pro/schematics/promonacogp420-0525_1.pdf` only. Page 17
  (sheet M) and page 14 (sheet C), rendered with PyMuPDF at `Matrix(1, 1)`,
  upright (10159 × 6617 and 10200 × 6617). Every box is
  (left, top, right, bottom) on that render; a multiplier after a box is
  the zoom it was viewed at.
- Order: I read every item from my own crops and wrote the readings down
  **before** opening the trace. Only then did I read the trace and
  compare. I did not open the Verilog from #72 / PR #92 or the
  reconstruction files.
- Junctions: only drawn dots count. Thickened crossings were compared with
  real dots nearby.
- Pinouts were used only as a check: 6331 (A0..A4 = 10..14, O1..O7 = 1..7,
  O8 = 9, /E = 15), 74151 (D0..D7 = 4, 3, 2, 1, 15, 14, 13, 12; A, B, C =
  11, 10, 9; /G = 7; W = 6), 7410 (9, 10, 11 → 8), 7430 (1–6, 11, 12 → 8),
  74147 (input 9 = pin 10). No drawn numeral disagreed with them.

## Results

| # | Item | My reading (before the trace) | Trace's reading | Verdict | Crop boxes (page) |
|---|---|---|---|---|---|
| 1 | PR-54 pin 10 (A0) | **V0.** Pin 10 is the top drop, x≈7157, from the top long row y≈2646. That row turns down at a corner dot at x≈3025; the riser x≈3025 taps the bus row next to PR-139 pin 8 with a dot at (3025, 3915). That bus row is labelled `V0` at the `Ⓔ` bracket (the 0 is an inked blob, but it sits above V1..V4) | V0, clear | **agree** | (6700, 3550, 8100, 4450); (6700, 2000, 8100, 3600); (2600, 2500, 3900, 2950); (2750, 3750, 3250, 4250) ×2; (820, 3880, 1020, 4120) ×3 (p17) |
| 2 | PR-54 pin 11 (A1) | **V1, probable.** Row y≈2691 to the riser x≈2981 (teardrop dot at about (2981, 2691)). The riser goes dashed and is lost at y≈3865, in the band where the scan has dropped its ink; no tap is visible. V1 only by the staircase order of the other four taps | V1, probable (same dropout, same box) | **agree** (at probable; the scan cannot do better) | (2600, 2500, 3900, 2950); (2880, 3780, 3060, 4120) ×4 (p17) |
| 3 | PR-54 pin 12 (A2) | **V2, probable.** Row y≈2733 to the riser x≈2939. It crosses the V0 row as a plain cross (no dot) and leaves specks below it, then the dropout band; no tap visible. V2 by the staircase | V2, probable (specks reach the V2 row) | **agree** (at probable) | same as 2 |
| 4 | PR-54 pin 13 (A3) | **V3.** Row y≈2778, riser x≈2897, dot at (2897, 4045) on the V3 row (PR-139 pin 5) | V3, clear | **agree** | (2750, 3750, 3250, 4250) ×2; (2600, 3600, 3300, 4700) (p17) |
| 5 | PR-54 pin 14 (A4) | **V4.** Row y≈2822, corner at x≈2853, riser down to a dot at (2855, 4089) on the V4 row (PR-139 pin 4) | V4, clear | **agree** | same as 4 |
| 6 | IC129 select inputs | Pin 11 (A) = **H1**, pin 10 (B) = **H2**, pin 9 (C) = **H3**: straight rows from the right-hand `Ⓔ` bracket (label rows y≈4129, 4175, 4218). They cross the trunks near x 6336, 6380 and 6767 without dots. The blob on the H1 row near (5850, 4125) has no branch | H1, H2, H3; the same blob noted as no branch | **agree** | (5300, 3700, 6000, 4400) ×1.2; (5900, 2550, 6900, 4700); (6700, 3550, 8100, 4450) (p17) |
| 7 | IC129 data inputs | PR-54 pins 1, 2, 3, 4, 5, 6, 7, 9 (O1..O8) go straight down to IC129 pins 4, 3, 2, 1, 15, 14, 13, 12, i.e. O1..O8 → D0..D7 in order. They cross the IC124.8 → 129.7 row without dots. PR-54 /E (pin 15) to ground. W (pin 6) → `/+200 (R) Ⓒ` (bar clear); Y (pin 5) not drawn | Same | **agree** | (6700, 3550, 8100, 4450); (7900, 4250, 8700, 4450) ×1.5 (p17) |
| 8 | Strobe: BONUS CP | IC124 (AND body, output bubble, pins 9, 10, 11 → 8: 3-input NAND) pin 10 = `Ⓝ BONUS CP`, pad FE, no bar | Same | **agree** | (5800, 3350, 7300, 4400) (p17) |
| 9 | Strobe: NOR(H4..H7) | IC124 pin 9 = IC128 pin 8. IC128 is an AND body with four bubbled inputs and no output bubble = 4-input NOR; 13 = H4, 9 = H5, 10 = H6, 12 = H7. Type not printed | Same; type uncertain (7425 fits) | **agree** | (5300, 3700, 6000, 4400) ×1.2; (5800, 3350, 7300, 4400) (p17) |
| 10 | Strobe: V-④ through IC79 | IC124 pin 11 = riser x≈6767, up without a break to a dot at about (6767, 1775) on IC79's output row (inverter, 13 → 12). IC79 pin 13 = trunk x≈6380 down to y≈5050, left along y≈5050 to x≈2731, up to row y≈4744 = `Ⓑ V-④`. So 124.11 = NOT V-④. The address rows cross the 6767 riser as thickened crossings. V-④ is a sheet B signal, not the `Ⓔ` bus V4 that feeds PR-54 pin 14 | 124.11 = IC79.12 = NOT V-④; same route | **agree** | (6500, 400, 7300, 2700); (5300, 1150, 6900, 1900); (5200, 1750, 6900, 2650); (5900, 2550, 6900, 4700); (5900, 4600, 6700, 5300); (1800, 4300, 3300, 5150); (600, 4550, 2400, 5250) (p17) |
| 11 | Sheet C: where /+200 enters the 74147 | The `Ⓜ /+200 (R)` arrow rises at x≈3245 into the **seventh input from the top** of IC74 (OR body, all inputs bubbled, `30`: 8-input NAND). I read that numeral as **5** (overwritten by the wire end; the fifth row reads 3). IC74.8 → IC2 13 → 12 → row y≈5514 right to x≈6212, up, crossing the row y≈1770 (thickened, smaller than real dots: a crossing) → **74147 (IC1) pin 10, input 9**, the highest priority | Same route; numeral "5 or 3", uncertain; y≈1770 read as a crossing | **agree** | (2000, 5200, 4300, 6500); (3050, 5300, 3700, 5750) ×2; (3800, 1500, 6500, 5700); (5900, 4600, 6400, 5650); (5950, 1550, 6400, 1900) ×2; (6130, 1720, 6280, 1820) ×6; (6000, 900, 8300, 2400) (p14) |
| 12 | Sheet C: the dimming pull-downs | /+200 does **not** drive the pull-downs directly. They are four non-inverting buffers of IC14 (`14 17`, bubbled in and out), each through 470 Ω: inputs 5, 3, 9 (joined) → red, blue and green nodes; input 11 → the blue node only (R8). Inputs 5, 3, 9 come from IC2 11 → 10, whose input is the row y≈1767 from IC53.13 (AND body, bubbled inputs = NOR). /+200 reaches that row indirectly: IC2.12 also has a dot at (4094, 5514); that branch rises, turns left at y≈3866 into pin 2 of the upward 8-input NAND (`30`, designator unclear), whose output 8 goes to IC47 pin 1 (drawn as OR), and IC47.3 goes to IC53 pin 11. So an active /+200 turns the three pull-downs off (full brightness) | Same chain: branch (b) → upward NAND pin 2 → IC47.1 → IC53.11 → IC2 11 → 10 → 7417 pull-downs off; fourth to blue only | **agree** | (6000, 1600, 8300, 3000); (3600, 3900, 4500, 5600); (2800, 3500, 4200, 4000) ×0.8; (2700, 1600, 4400, 3600) ×0.45; (3800, 1500, 6300, 1900) (p14) |

**Count: 12 agree, 0 disagree, 0 can't settle.** Rows 2 and 3 agree at the
trace's own level, *probable*: my reading rests on the same staircase
argument, because the taps for V1 and V2 sit in the band
(2880, 3860, 3060, 4120) on page 17 where the scan has lost its ink. The
trace's remedy stands: a cleaner scan of that box, or a continuity check
from PR-54 pins 11 and 12 to PR-139 pins 7 and 6.

## Other notes (seen in passing, not searched for)

- **Gate on the V-④ trunk (sheet M, near (6380, 2126)).** The trace calls
  its inputs "3, 1, 5 → 6". I read the middle numeral as **4**
  (3, 4, 5 → 6 is the second section of a 7427). The numeral is crude and
  could be either. It has no effect on the +200 path. Box
  (6250, 2000, 6700, 2250) ×2.5, page 17.
- On sheet C I followed branch (b) at 0.45–0.8× only, not at the 2–4× the
  trace used; the scan gaps near x 3350–3380 that it notes were not
  re-examined.

## Not checked

- The trace's sheet B reading of V-④ (IC71, 7442), the window arithmetic,
  the screen orientation, the placement of Aldo's artwork and the
  corrections table: outside this issue's list.
- The other IC74 inputs and the 74147 inputs 1..8.
- IC79.12's second load (the bridge 157 strobe).

## Short report

- **Established:** an independent reading of all twelve items agrees with
  the trace. PR-54 A0, A3, A4 = V0, V3, V4 (clear); A1, A2 = V1, V2
  (probable, same scan dropout). IC129 selects H1, H2, H3; data O1..O8 →
  D0..D7; output W = /+200 (R). /G = NAND(BONUS CP, NOR(H4..H7),
  NOT V-④ via IC79 13 → 12). On sheet C, /+200 enters the 7430 IC74
  (seventh input, numeral read as 5) and reaches 74147 input 9 through
  IC2 13 → 12; it reaches the dimming pull-downs only indirectly, through
  the upward NAND, IC47 and IC53, and turns them off.
- **Ran:** PyMuPDF renders and crops of pages 14 and 17. No code, no tests.
- **Still uncertain:** the V1/V2 order on PR-54 pins 11 and 12; the IC74
  numeral (I read 5); IC128's type; the middle numeral of the gate at
  (6380, 2126).
- **Not checked:** see above.
