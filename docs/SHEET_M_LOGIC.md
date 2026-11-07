# Sheet M logic (jtmonacogp_rescue)

`cores/monacogp/hdl/jtmonacogp_rescue.v` implements every gate, flip-flop,
counter, one-shot and PROM path of sheet M (96578-P, manual 420-0358, PDF
page 33). It follows the pin tables in
[trace/SHEET_M_TRACE.md](trace/SHEET_M_TRACE.md). It is connected in the
core with sheets A, B, D, F, G and H ([CONNECTED.md](CONNECTED.md)).
- PR-138, PR-139, PR-140 and PR-141 are banks 13 to 16 of
  `jtmonacogp_proms.v` (offsets 6656, 7168, 7680, 8192).

## What the sheet does

All statements here follow from the wiring and the data-sheet functions of
the parts. Signal names are the drawn labels. What the pictures look like
and what the real game does with them is not inferred.

- **Rescue-car position.** IC36 (low) and IC37 (high) count 7M. IC44 loads
  them when both reach F while IC57 is set; IC57 toggles each time IC37's
  carry falls, so they load on every second pass, as sheet H's divider.
  IC37 loads 3, IC36 IC43's nibble: 8 (B), or 10 (A) while IC42.6 is low,
  which is on line 1FF (V-CA · V8) with IC35's upper Q set.
  - One period is 464 − L pixels: 456, one line, with L = 8, and 454 on the
    line where L = 10. So while IC35's upper Q is set, the counter's phase
    moves two pixels against the raster once a frame.
  - PR-138 reads V0..V3, IC36 QC, QD, IC37 QA, QB and Vs/4 (A8, label
    uncertain). IC29 picks its even or odd bits by IC36 QB and drives the
    four rescue lines (BL, W, Y through IC22; R through IC16 with Vs/32)
    while IC10's output is low: IC44.6 low (IC57, IC37 QC and QD all set)
    and /R-L-SIDE low.
- **/R-L-SIDE** (pad FE, to sheet H's direction latches) is low while V-(3)
  is low, IC35's upper Q is set and V4 is high (IC60, IC59).
- **Rescue timing.** IC49 counts the falls of Vs/64 while /EXTEND is low,
  that is in extended play, and is held at 0 otherwise. Its QB leaves as
  EXT. CAR CONT (pad EX, sheet F).
  - IC35's lower half is preset while IC49 QC is low. While QC is high it
    is clocked as Vs/64 rises, unless IC49 QD and ACCE. D are both high
    (IC45, IC47), and takes 100-C. Each fall of its Q fires IC18
    (20.0 ms, 143 293 pixels with R16 = 47 kΩ, C4 = 1.5 µF), whose pulse is
    /RESCUE CP (pad D9, the score board).
  - IC35's upper half is preset while its lower /Q, IC49 QB and QA are all
    high (IC42.8); otherwise it takes /HS each time IC44.6 rises (once per
    rescue-counter period, at the counter's position). Its Q enables the
    phase step above and /R-L-SIDE.
- **Lives (IC46).** IC46 (74193) is held at 0 while /COIN IN is high. It
  counts up as /EX. SIGNAL CP (sheet A, an extend earned) rises, but not
  past 3 (IC52 holds the up input high at 3), and down as EXPLO. SEL. D
  (sheet F) falls. Its borrow is low while it is at 0 and EXPLO. SEL. D is
  high; IC59 makes that **GAME OVER** (pad E16), which clears the game on
  sheet A. So with no extend earned, the first EXPLO. SEL. D ends the game;
  each extend adds one more.
- **Spare cars.** IC53's two outputs, ANDed by IC26, open an H window that
  grows with IC46's count: none at 0, H5·H6 at 1, H6 at 2, H5 + H6 at 3
  (one, two and three quarters of each 128-pixel H5-H6 cycle), while H8 and
  V-(1) are low. IC26 adds EXTEND and V4 and gives /DUMMY AREA (sheet C).
  IC52 gates it with Vs/16, and IC56/IC55 combine it with PR-139's nibbles
  into /DUMMY (W), (R) and (BL).
- **Signs.** PR-139 reads V0..V4 and H1..H4; IC50 picks bits by H0. The dump has
  two stray bits under the bridge warning's outline (bit 6 at A8..A5 = 15,
  V = 22 and 26). They are drawn as stored: faintly visible in one cabinet
  recording, not in another (Aldo, 4 November).
  /SIG. (Y) and (BL) (IC9) are drawn while IC66 is high: CAR. NO. CONT low,
  /GAME low, Vs/16 low, H5 = H6 = 1 with H8 = 0, /EXT. 500 low and V-(4)
  low.
- **Bridge.** IC10's output (/0-AREA, or V-(5) with V-(3)) enables PR-140
  when high and PR-141 when low. Their address is V0..V3 XOR V7, A4 = AND(V4
  XOR V7, V-(2), V6 XOR V7), and MH1..MH4; V7 mirrors the picture. IC11
  (MH0, enabled while V-(4) is high) and the 7442 IC6 decode three data bits
  and IC16.8 (BRIDGE AP with V-(4), /DUMMY AREA and /OTHER CAR) into the five
  /BRIDGE colour lines; (W) also goes to sheet F (pad EH). IC15 and IC16 give
  /L2-SIDE (V7) and /R2-SIDE (/V7), to sheet H, while EXT. 500 and IC11's
  first output are high.

## Timing model

As sheet H ([SHEET_H_LOGIC.md](SHEET_H_LOGIC.md)): the module captures its
inputs at edge 2 (the 7 MHz edge that ends a pixel), settles that pixel in
the host clocks up to edge 1 of the next one, and registers its outputs at
the following edge 2.
- IC36 and IC37 step at edge 2 on the pixel's settled nets; IC18 counts the
  pixel there.
- Every flip-flop, counter and one-shot, and every asynchronous clear and
  preset, takes one settling step; gates are combinational on the state; a
  clock edge needs the clear or preset released at the step before.
- The capacitors on IC43's select (C9), the /LOAD net, IC37's carry, IC42.8
  (C6), IC44.6 (C7) and /DUMMY AREA (C5) are not reproduced.

In the core the raster nets and sheet B's lines are for the pixel the module
captures. Sheets D and H register theirs for the previous pixel at the same
edge, so /0-AREA, BRIDGE AP, EXT. 500, /EXT. 500, CAR. NO. CONT and /OTHER
CAR reach sheet M two pixels late. They gate whole areas (the bridge zone,
the sign window) or, for /OTHER CAR, the bridge colour under another car;
the shift is not lined up.

## Tests

`tests/tb_rescue.v` drives the module and a pin-wired reference
(`tests/sheet_m_reference.v`, its own part models, wired by IC and pin
number from the trace) with the same stimulus on the real sheet E raster,
and compares every output and 22 internal state bits at every pixel. It
also checks, from the trace: every rescue-counter period is 464 − L; IC46
is 0 while /COIN IN is high; GAME OVER is high exactly while IC46 is 0 and
EXPLO. SEL. D is high; at most one /BRIDGE line is low. `rescue` runs 30
frames with IC18's capacitor / 1000, `rescue_full` 60 frames as drawn.

Results: see [reports/sheet-m-2026-10-30](../reports/sheet-m-2026-10-30/README.md).

## Open items

- The trace's unresolved readings: the bus label at IC50's select (H0 or
  H8, H0 used), PR-138 A8's label (Vs/4 used), R16 (47 kΩ used).
- IC59's type (7404 or 7406) and IC7's are not printed; the logic is the
  same.

## Pro board: the +200 graphic

Pro Monaco GP (manual 420-0525, sheet M, PDF page 17) adds PR-54 and its
multiplexer, read in `pro/docs/trace/SHEET_M_C_PLUS200_TRACE.md`. The module
takes them behind a `pro` input (1 = Pro board); with `pro` = 0 the new input
is ignored, `plus200_n` stays high and every output is as above.

- **PR-54** (IC130, 6331, 32 × 8, /E1 at ground): A0..A4 = V0..V4 in
  straight order. A0, A3 and A4 are clear on the scan; A1 = V1 and A2 = V2
  are the trace's probable reading (risers R1/R2). A swap would exchange
  address bits 1 and 2.
- **IC129** (74151): D0..D7 = PR-54 O1..O8, select A, B, C = H1, H2, H3 (H0
  unused, so each bit lasts two H clocks), /G = IC124.8, W (pin 6) = /+200
  (R) to sheet C.
- **Strobe:** IC124 (7410, 11, 10, 9 → 8) = NAND(IC79.12 = NOT V-(4),
  BONUS CP, IC128.8 = NOR(H4, H5, H6, H7)). V-(4) is the same sheet B decoder
  output the original board uses (V7..V5 = 100).

So `/+200` is low where the selected PR-54 bit is 1, in the window
H 0x100–0x10F × V 0x080–0x09F while BONUS CP is high: one PROM word per line,
O1 at the top of the window on the upright screen, address 31 at its left.
It is registered with the other outputs (one pixel late). The 6331's open
collector outputs have no pull-up drawn; a released output reads high at the
74151, as stored.

**PR-54 data.** No dump is known. The table in the RTL (`pr54`) is Aldo's
reconstruction, `pro/reconstruction/plus200-glyph.txt` (6 November 2026,
O1 = bit 0), not original PROM data. It is built into the core.

Ports: `pro`, `bonus_cp` in, `plus200_n` out. In `jtmonacogp_game.v` sheet C
takes `plus200_n` (wire `m_plus200_n`), and `pro` and `bonus_cp` are tied
inactive (0) until sheet N is connected (#71).

`tests/sheet_m_reference.v` has the same parts, wired by the Pro trace's pin
numbers (instances `pro_ic128`, `pro_ic79`, `pro_ic124`, `pro_ic130`,
`pro_ic129`; models `rm_nor4`, `rm_74151`, `rm_6331` with the reconstruction
bytes typed from the file) and selected by `m_pro`. `tests/tb_rescue.v`
drives BONUS CP in every run from a random sequence of its own (the rest of
the stimulus is unchanged), compares `plus200_n` with the other outputs, and
checks every pixel against the drawing itself (read by
`tests/fixtures/plus200_glyph.vh`): /+200 low exactly when `pro`, BONUS CP,
V-(4) low, H4..H7 = 0 and the drawing's cell for (H0..H3, V0..V4) is lit.
`rescue` and `rescue_full` run with `pro` = 0, the new `rescue_pro`
(`tb_rescue_pro`, IC18's capacitor / 1000) with `pro` = 1. In `tb_rescue`
V-(4) is random, so the window is not at its place on the raster.
`tests/tb_plus200.v` (case `plus200`) puts it there: sheets M and C with
`pro` = 1 on the sheet E timing, V-(4) decoded from V7..V5, BONUS CP high for
two frames and low for one. It checks every pixel against the drawing and
sheet C's colour (below), and writes the upright screen as `plus200.ppm`.

![Simulated +200 window](../reports/pro-plus200-2026-11-06/plus200-sim.png)

Results on 6 November 2026 (Icarus Verilog, run as `scripts/run_tests.py`
does, with the original PROM image):

| Run | `pro` | Frames | Pixels compared | Notes |
|---|---|---|---|---|
| `rescue` | 0 | 30 | 3 602 408 | as before; BONUS CP high 1 977 594 pixels, 3 516 of them on drawn cells of the window: /+200 stays high |
| `rescue_full` | 0 | 60 | 7 213 928 | as before; BONUS CP high 3 121 007 pixels, 5 719 on drawn cells: /+200 stays high |
| `rescue_pro` | 1 | 30 | 3 602 408 | the stimulus of `rescue`; /+200 low on exactly the 3 516 drawn cells, RTL and reference equal |
| `plus200` | 1 | 3 | 353 856 | 184 lit pixels in each frame with BONUS CP high (the drawing's 184 cells), none with it low; pure red over white (144), yellow (112) and nothing (112) |

With `pro` = 0 the logs and pictures of `rescue`, `rescue_full`, `game`,
`play` and `play_sound` are identical to those of the branch point, apart
from the new +200 line in `tb_rescue`'s log.

Open items (Pro):

- The A1/A2 order (R1/R2 on the scan). A cleaner scan of box (2880, 3860,
  3060, 4120) on page 17, or a continuity check from PR-54 pins 11 and 12,
  would settle it.
- IC128's type (7425 fits; its strobe is not drawn) and the numerals noted
  in the trace; none changes the logic.
- Pro sheet E and Pro sheet B were not traced: the window uses the original
  board's counter ranges and V-(4) decoder. The footage suggests a wider
  +200 than 32 lines (`pro/docs/OBSERVATIONS.md`); to compare with a
  screenshot of the core before changing anything.
- BONUS CP's pulse length (R24/C41, sheet N) decides how long +200 shows; it
  comes with sheet N (#71).
