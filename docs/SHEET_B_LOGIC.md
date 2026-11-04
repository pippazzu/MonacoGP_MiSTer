# Sheet B logic (jtmonacogp_motion)

`cores/monacogp/hdl/jtmonacogp_motion.v` implements every gate, latch,
counter and the text PROM path of sheet B (96578-P, manual 420-0358, PDF
page 29) from the pin tables in [trace/SHEET_B_TRACE.md](trace/SHEET_B_TRACE.md).
Since 29 October it is in the core, with sheet D, behind the development
*Display* option "Road and scenery" (see [SHEET_D_LOGIC.md](SHEET_D_LOGIC.md),
"In the core"). Its
outputs go to sheets D (MH, M1V, M2V and their load nets), M (V-(1) to
V-(5), MH0–MH4) and C (the two text outputs), none of which is built.
PR-133 is bank 8 of `jtmonacogp_proms.v` (offset 4096).

## What the sheet does

All statements here follow from the wiring and the data-sheet functions of
the parts; none comes from gameplay knowledge.

- **MH** (IC118, IC103, IC57) counts 7 MHz pixels and reloads at 1FF. The
  load word is `{0, 0, 1, IC111 pins 12, 9, 7, 4, 0}`. IC111 selects the
  fixed value 1100 (load 0x38, a period of 456 clocks, exactly one line) on
  every line except line 1FF, where /(V-CA × V8) is low and it takes
  SP.D–SP.A (load 0x20 + 2·SP, a period of 480 − 2·SP, 450 to 480 clocks).
  So once a frame, MH's pattern moves against the raster by 24 − 2·SP
  pixels toward later H (earlier for SP above 12; none for SP = 12). The
  21 October reading of this, inferred from the wiring, now holds in
  simulation of both models. When
  SP is above 12 and the load falls in the first few pixels of line 1FF,
  the shorter period can bring a second SP load on the same line; the
  random run counts these.
- **M1V and M2V** (IC85/IC76, IC91/IC77) count the rises of /HS while /V8
  is high, so 248 lines a frame, and reload at FF (R1, R2 low on that
  line). The high nibble loads 0; the low nibble loads 8 while VSEL is high
  (period 248: the FF line stays where it is) or, while VSEL is low, 7 when
  the IC69 half is set (period 249: the FF line moves one line later each
  frame) and 9 when it is clear (period 247: one line earlier).
- **IC69** has no drawn D or clock; each half is a latch on its preset and
  clear. The M1V half is set when M1V is at FF on lines 20–2F and cleared on
  lines 50–5F; the M2V half is set on lines A0–BF and cleared on F0–FF. A
  counter that moves therefore swings: M1V's FF line between 2F and 50, M2V's
  between BF and F0, turning one frame after it enters a window. The drawing
  labels the M1V pair "right side" and the M2V pair "left side" (in
  Japanese, see the trace).
- **VSEL** (IC87) is low, so the counters move, while /IN RESET is low, and
  in frames where Vs/2 and Vs/4 are both high while /TUNNEL & BRIDGE is high
  and SP.C and SP.D are not both high.
- **IC54** decodes V7–V5. Outputs 1–5 leave as V-(1)–V-(5); 2 and 6 set
  and reset IC68, whose Q is high on lines 40–BF.
- **Text.** IC63 shifts one bit of PR-133 per pixel. The address is V1–V6
  (A0–A5), H3 (A6), H8 (A7) and /COIN IN (A8); H0–H2 pick the bit. The
  strobe opens in two 16-pixel windows on lines 40–BF:
  - H 0F0–0FF, while Vs/16 is high and /EX. SIGNAL or /COIN IN (pad E1) is
    low: /EX. & GAME OVER;
  - H 1D0–1DF, while /GAME is high: /COIN & START. This window also opens
    in the blanking pass of H 1D0–1DF, where the picture is blanked.
  /COIN IN high selects GAME OVER and DEPOSIT COIN, low selects EXTENDED
  PLAY and START. The address order is confirmed by the PROM itself: with
  it, all four messages read correctly, upright when the raster is turned
  90° clockwise (H growing downward, V growing to the left). The test run
  writes the simulated outputs of both pairs as pictures.

## Timing model

Host clocks are counted from the pxl_cen edge (edge 0):

- Edge 0 ends a pixel. The counters' inputs are kept as they were in that
  pixel, and IC68 and IC69 store the state they settled to in it.
- Edge 1: MH steps (every pixel); M1V and M2V step where HS fell between the
  two pixels, which is where /HS rises. The sheet E V counters are clocked by
  that same edge, so M1V and M2V see the /V8 of the line that ends.
- From edge 1 on, all outputs are valid for the pixel. PR-133 is a
  synchronous memory: its data follow the address one host clock after
  edge 0.

**Settled layers**, as for sheets F and G: gates and latches are
combinational on settled nets, and parts clocked by the same edge act
together. No loop of gates and latches needs cutting on this sheet.

**Races on the real board.** On the board, the V lines, the decoder
outputs and the counters' R1/R2 all change after the same /HS edge, at
different times. With typical data-sheet delays: the V counter outputs after
about 15 ns, the IC54 outputs about 20 ns later, R1 and R2 only after the
74161 carry, IC62 and the 470 pF of C12 (C10), probably 60 ns or more. When a counter is at FF on the
line before one of these boundaries, R1 (R2) is still low while the latch
inputs pass through the next line's values or a mix of both:

| Counter at FF on line | Transition | Effect the settled model does not make |
|---|---|---|
| M1V, 1F | 1F → 20: D1 falls with V4 low | set |
| M1V, 3F | 3F → 40: V4 falls about 20 ns before D1 rises | set |
| M1V, 4F | 4F → 50: /V4 falls with D2 low | clear |
| M2V, 9F | 9F → A0: D5 falls | set |
| M2V, EF | EF → F0: /V4 falls with D7 low | clear |

Whether the board's latch acts depends on pulse widths near the 7474's
minimum (about 25 ns guaranteed), so it is not decided here. The
consequence for the swing: M1V's FF line could turn at 3F instead of 2F
(3F is reached first when it moves up) and at 4F instead of 50, so its
swing would be 16 to 33 lines instead of 33; M2V's could turn at EF
instead of F0, 48 lines instead of 49. A recording of the real game, where
the road edges' swing can be measured in lines, would decide it.

The other capacitors fit the settled model: the 470 pF on IC103's carry
(IC57's clock) and on IC54 output 6 (IC68 /R) absorb the carry and decoder
glitches, C15 sits on /MHLD and 220 pF on IC111's select, all sampled long
after they settle. The reference's 3 ns filters stand in for them and count
the pulses they absorb.

## Tests

`tests/tb_motion.v` drives the RTL and `tests/sheet_b_reference.v` with the
same stimulus on the real sheet E raster:

- The reference is wired IC by IC and pin by pin from the trace tables,
  with its own part models (data-sheet functions, no shared code with the
  RTL): gates, the decoder, multiplexers and the PROM 0.01 ns, latches
  0.02 ns, a 3 ns inertial filter on every clock and every asynchronous
  latch input (it absorbs and counts hazards), 1 ns clock to output. The
  V lines change in the same layer as M1V and M2V, as sheet E's counters
  clocked by the same /HS would. UG1, drawn without a designator, is
  IC70's fourth gate (pins 1, 2 → 3, as in the KiCad redraw); a separate OR
  gate would be the same.
- Checked at the end of every pixel: MH, /MHLD, M1V, M2V, R1, R2,
  V-(1)–V-(5), both text outputs, IC69's two halves, IC68, VSEL, the IC63
  strobe and its output (41 bits).
- Directed, written in the testbench from the trace: every MH period (456,
  or 480 − 2·SP after a load on line 1FF); every M1V and M2V load value (8,
  7 or 9 from VSEL and IC69); every FF line at 256 minus the load value
  lines after the previous one; IC69 changing only on its counter's FF line
  and only inside its windows; both text outputs at every pixel against the
  PR-133 bit at the traced address, inside the traced windows only; IC68 high
  on lines 40–BF.
- Two runs in `scripts/run_tests.py`:
  - `motion` (`tb_motion`): three text frames (the second and third write
    `motion-text-1.ppm`, GAME OVER and DEPOSIT COIN, and `motion-text-2.ppm`,
    EXTENDED PLAY and START), 170 frames with /IN RESET low, eight with VSEL
    high. It must reach two sets and two clears of each IC69 half, all
    three load values, every SP value at line 1FF, and the swing above
    exactly (M1V 2F–50, M2V BF–F0).
  - `motion_random` (`tb_motion_random`): eight frames with VSEL high, then
    110 frames of random inputs changing at frame starts and at random
    pixels (SP often on line 1FF).
  M1V and M2V start at D0 and 40 (module parameters), which put their FF
  lines at 3F and CF, a few frames from the windows; the module's default
  is 0.
- The stimulus is not gameplay: sheets A, D and H are replaced by random
  nets.

Results on 28 October 2026 (logs in the working notes (not published)):

| Run | Frames | Pixels compared | Notes |
|---|---|---|---|
| `motion` | 181 | 21 780 393 | all 16 SP values loaded at line 1FF, every period 456 or 480 − 2·SP; loads 7/8/9: M1V 88/11/82, M2V 98/11/72; swing exactly 2F–50 and BF–F0; 13 M1V and 4 M2V loads on board-race lines, 8 and 2 of them where the board might flip IC69; 20 minutes |
| `motion_random` | 119 | 14 316 585 | all 16 SP values; one line 1FF with two SP loads; IC69 changed in both halves; 15 minutes |

The text pictures of the `motion` run read GAME OVER and DEPOSIT COIN,
EXTENDED PLAY and START. The reference absorbed carry glitches on IC57's
clock (95 520 in `motion`) and short pulses on IC69's inputs (172), as
expected from the paragraph on races; none on any counter clock or on
IC68.

Verilator 5.020 `--lint-only -Wall` and Yosys 0.33 `synth; check -assert`
pass on the module (211 cells, 37 flip-flops, no combinational loops). This
is a simulation result: no hardware run includes this module yet.

## Open items

- The board races above.
- IC69's D and clock pins are not drawn (the redraw leaves them unconnected
  too); the model gives them no clock. If the board clocked them, the
  behaviour would differ.
- The trace's open readings do not change the logic: U1 (PROM marking), U3
  (IC55 pin 9 printed like 1), U4 (IC70 lower output 8, standard), U5
  (caption separators), U6 (IC111 read as a 74157, the only reading that
  fits its pins), U8 (IC54 output 7 on pin 9), U9–U11 (captions), U12
  (UG1's designator).
- The two /COIN IN pads (ED to PR-133, E1 to IC72) are separate inputs.
  Sheet A answers it: pad ED is /COIN IN (sheet A's pad BD, IC37 /Q), but
  pad E1 is COIN IN without a bar (sheet A's pad B1, IC37 Q), against this
  sheet's label. The real game's GAME OVER before a game needs exactly that
  (docs/CONNECTED.md); the connected core wires E1 to COIN IN.
- SP.A–SP.D arrive on pads F16, F7, F17 and FU from sheet H, whose PR-38
  data pins leave on pads C16, CT, C17 and CU; the matching numbers suggest
  the same cable, but the link is not traced.
- Power-up: the board has no reset for these counters and latches. The
  reset gives MH 0, M1V and M2V their parameters (default 0) and all latches
  0; /IN RESET then moves the road counters every frame for as long as
  sheet A holds it low.
