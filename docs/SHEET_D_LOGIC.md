# Sheet D logic (jtmonacogp_scenery)

`cores/monacogp/hdl/jtmonacogp_scenery.v` implements every gate, latch,
flip-flop, counter and PROM path of sheet D (96578-P, manual 420-0358, PDF
page 31) from the consolidated pin list in
[trace/SHEET_D_TRACE.md](trace/SHEET_D_TRACE.md). Since 29 October it is in
the core behind the development *Display* option "Road and scenery", with
sheet B and a test stimulus (see "In the core" below); no other sheet uses
its outputs yet. Its inputs come from
sheets B (MH, M1V, M2V and their load lines, V-(4)), E (/HS, V7, /V8), A
(/COIN IN), C (EXTEND) and I (S-100-A..D). Its outputs go to sheets B, C,
F, G, H and M. PR-134 to PR-137 are banks 9 to 12 of `jtmonacogp_proms.v`
(offsets 4608, 5120, 5632, 6144).

## What the sheet does

All statements here follow from the wiring and the data-sheet functions of
the parts. None comes from gameplay knowledge. Signal names are the drawn
labels.

- **PROM addressing.** IC92 and IC67 pass the low five bits of M1V or M2V
  (AV0–AV4) to all four PROMs. M2V is selected while V7 is high or IC88's
  lower half is set, M1V otherwise. MH2–MH4 are A5–A7: PR-136 takes MH1–MH3
  and MH4 on A8 instead. The 74153s (IC112, IC105, IC119) pick bit MH0 +
  2·MH1 of each nibble. So each PROM byte covers four pixels along MH, and
  each nibble feeds one output. IC98 picks the even or odd bit of each pair
  by MH0, and IC97 decodes the three bits to /HOUSE (R), (Mu), (St) and (W).
  A8 of PR-134 is IC110 pin 8 (MH8 with IC96's codes 2 and 4). A8 of PR-137
  is /WALL. PR-135's A8 is grounded.
- **Road sides.** IC78, IC82, IC90 and IC81 decode one value of M1V
  (/R-SIDE, pad FD) and one of M2V (/L-SIDE, pad FC): M1V = 0x1B and
  M2V = 0xEC with IC90 a 7425 (the reading the real game shows). IC88's lower half (/M-ROAD on its
  /Q) is set to /V8 as /R-SIDE ends and cleared while /L-SIDE is low. IC74
  (ROAD) does the same with sheet B's load lines: set as /M1VL0 ends,
  cleared while /M2VL0 is low. /Y-LINE (IC87) is low on either side line.
- **MH windows.** IC96 decodes MH5–MH7 with IC88's lower half as D. IC89
  and IC82 give /0-AREA (MH5–MH7 not all low). IC88's upper half takes MH6
  at each rise of MH5 while MH7 and MH8 are high. Its /Q enters the POOL
  control (IC89 pin 6) with POOL's /Q and an M2V window (IC75 pin 8, M2V =
  A0–BF).
- **State network.** IC24 decodes the S-100 code from sheet I. Each
  flip-flop below is clocked as its decoder output rises, that is, as the
  code leaves that value:
  - 0: GRAVEL (IC40 upper half) takes EXTEND.
  - 1 or 6: IC38's other half (through IC47) takes /TUNNEL.
  - 2: SLIP (IC31) takes POOL's /Q.
  - 4: EXT. 500 (IC25 upper half) takes EXTEND.
  - 5: IC25's lower half takes EXT. 500. /CAR NO CONT is low while the code
    is 5.
  - 7: TUNNEL (IC31) takes SLIP's /Q.
- **Distance counter.** IC40's lower half samples /HS each time MH reloads
  (/MHL0 rises), so it turns each time MH's reload drifts across the HS
  pulse. In sheet B's settled model that is once every 456 pixels of drift,
  about every 19 frames at SP = 0. IC49 counts its turns while GRAVEL, SLIP,
  TUNNEL or IC25's lower half is set (IC32). At 12 (QC and QD), IC34 clears
  those four, which clears IC49. /COIN IN high clears them too. POOL (IC38)
  takes IC38's other half at each rise of IC40's lower half. IC45 clears
  that half and EXT. 500 while POOL is set and IC40's lower half is clear.
- **IC68**, set and reset through IC48 and IC41 by IC49's count k = QA +
  2·(QB or QC) + 4·QD:
  - k = 0 (counter idle): set during HS;
  - k = 1 (count 1): set at the MH reload and reset during HS;
  - k = 2–6 (counts 2–10): reset during HS;
  - k = 7 (count 11): set during HS and reset at the MH reload.
  Its Q is low while a state is in progress, and it moves in and out
  across the line at the first and last counts. It gates BRIDGE AP (IC25's
  lower half), TUNNEL AP (TUNNEL), SLIP and the GRAVEL control (IC73), and
  the HOUSE and GRASS enables (IC56).
- **Outputs.**
  - /TREE & GRASS (G) and (BL), /GRASS (W): PR-134 and PR-135.
  - /HOUSE (R), (Mu), (St), (W): PR-136.
  - /POOL, /WALL, /GRAVEL: PR-137, each gated by its control.
  - /SIDE LINE: MH4 with the selected load line.
  - /SLIDE: /M-ROAD and /BRIDGE AP, or BRIDGE AP and V-(4).
  - /SLIP, /GREEN BELT, /Y-LINE, ROAD, /ROAD, BRIDGE AP, TUNNEL AP,
    /TUNNEL, /TUNNEL & BRIDGE (to sheet B's VSEL), EXT. 500 and /EXT. 500,
    /CAR NO CONT, /R-SIDE, /L-SIDE, /0-AREA.

## Timing model

Host clocks are counted from the pxl_cen edge (edge 0). Sheet E's H and V
lines change at edge 0, sheet B's counters at edge 1. Like the sheet F
control logic, the whole sheet is evaluated one pixel late:

- Edge 2: the inputs of the pixel are captured, and the outputs of the pixel
  before are registered.
- Each later host clock up to edge 1 of the next pixel is one settling step:
  four or five steps.
- The PROMs are synchronous memories, so their addresses must have settled
  by edge 0. The design check (`busy`) fails if the step at edge 1 would
  still change the state. The longest chain takes four steps:
  1. IC40's lower half turns;
  2. IC49 counts to 12;
  3. IC34 clears the four flip-flops;
  4. IC32 clears IC49.
  Four steps is exactly what a six-clock pixel allows before edge 0. Every
  run settled in time.

So every output is valid for the pixel before the current one. When the
sheet is connected in the core, the video outputs need the same one-pixel
alignment as the other sheets' video paths (sheet G's player car is valid
for the current pixel).

**Settled layers**, as for sheets B, F and G: gates, the latch and the
asynchronous clears are combinational on the state. Each flip-flop and
IC49 compare their clock nets with the previous step and change state for
the next step. A flip-flop clocked through gates by another sheet's counter
therefore samples its D input after that counter has changed:

- IC88's lower half and IC74 take the new /V8;
- IC40's lower half takes the new /HS.

One loop is cut. IC32 reads the stored state of the four flip-flops it
watches, so in the step in which IC34 pin 10 clears them, IC49 still shows
12. The loop is IC49 → IC47 → IC34 → clears → IC32 → IC49 MR.

**Races on the real board**, which the settled model decides one way:

- IC40's lower half: /HS and /MHL0 both come from counters clocked by the
  same 7 MHz edge, through a few gates each. If /MHL0 rises before /HS has
  changed, IC40 takes the old value. That would move its turn by one MH
  reload, which is one line of drift.
- IC88's lower half and IC74: /V8 changes at the same /HS edge as M1V and
  M2V. Their clocks come later, through IC81 or sheet B's IC62 and C12/C10,
  so the new /V8 is the likely value on the board too. The model takes the
  new value.
- IC68 with /S and /R released together. At count 1, /S is /MHL0 and /R
  is HSB. When MH reloads in the last pixel of HS, both are low in one pixel
  and both rise at the next edge. The settled model holds the latch (Q stays
  high). On the board the input released later decides: if /R (through IC47
  and IC41) lags /S (through IC48), the latch resets. The run logs count
  these pixels. The latch is set again at the next MH reload or HS, so the
  difference lasts at most one line.
- IC49 at 12: on the board the pulse that clears the four flip-flops lasts
  about four gate delays (some 40–60 ns). IC68 sees IC49 at 12 during that
  pulse, in both models. IC49 is a ripple counter: the brief codes it passes
  through when it counts (11 → 10 → 8 → 12) are not modelled. They could
  reach IC68 through IC48 and IC41.
- The three 470 pF capacitors (/COIN IN at IC34 pin 9, IC40 pin 8, IC58
  pin 6) slow their nets by a few tens of nanoseconds. They are sampled long
  after they settle, except IC40 pin 8, which is IC49's clock. IC49 still
  counts once per turn.

## Tests

`tests/tb_scenery.v` drives the RTL and `tests/sheet_d_reference.v` with
the same stimulus:

- Raster: the real sheet E raster.
- M1V, M2V and their load lines: from the sheet B RTL (`jtmonacogp_motion.v`)
  with /IN RESET low, so they move a line every frame.
- Sheet B's VSEL input /TUNNEL & BRIDGE: sheet D's own output.
- The reference is wired IC by IC and pin by pin from the pin list, with
  its own part models (data-sheet functions, no shared code with the RTL):
  - gates, decoders, multiplexers and the PROMs take 0.01 ns, latches and
    asynchronous inputs 0.02 ns;
  - every clock, clear and latch input has a 3 ns inertial filter, which
    absorbs and counts hazards;
  - flip-flops change 1 ns after the filtered clock edge;
  - IC68 looks at both of its filtered inputs 0.02 ns after either
    changes, so that /S and /R released in the same layer hold it whatever
    order the simulator takes the two events in (the settled rule). A first
    model reset it when it happened to take /S first; the fast run found
    that.
  Its inputs are the RTL's captured inputs, all changing at once at
  edge 2.
- Checked for every pixel: all 28 outputs (31 bits) and 24 bits of internal
  state; the RTL settled before edge 1.
- Directed checks, written in the testbench from the trace:
  - ROAD set to /V8 as /M1VL0 rises and cleared while /M2VL0 is low;
  - /SIDE LINE low only with MH4 low;
  - IC49 never settling at 12 or above;
  - the four flip-flops of IC34's clear staying clear while /COIN IN is
    high;
  - at most one /HOUSE output low, and only with /HOUSE ST low;
  - /GRASS (W) low only inside /GRASS AREA.
- Stimulus, not gameplay: the S-100 code changes at random pixels (to
  0–9 or 15), EXTEND changes at random frame starts, /COIN IN is high one
  frame in twelve, and SP is mostly 0.
- Five runs in `scripts/run_tests.py`:
  - `scenery` (`tb_scenery`, 40 frames): MH from sheet B, with its real
    drift. Frames 21–24 are written as pictures `scenery-1.ppm` to
    `scenery-4.ppm`, in false colours (one per output; the game's colours
    are mixed on sheet C), turned upright as the text pictures of sheet B.
  - `scenery_fast` (40 frames): MH reloads a random value on every line, as
    if SP changed every line. IC40 turns every few dozen lines, so IC49
    reaches 12 and the POOL sequence runs.
  - `scenery_ic66nand` (26 frames, pictures `scenery-ic66nand-1.ppm` to
    `-4.ppm`): IC66 read as a NAND, the reading the real game rules out.
  - `scenery_ic90a` and `scenery_ic90b` (12 frames each, fast stimulus):
    IC90 read as drawn, and as two AND sections.

Results on 29 October 2026 (logs and pictures in
the working notes (not published)), with the original PROM set:

| Run | Frames | Pixels compared | Notes |
|---|---|---|---|
| `scenery` | 40 | 4 806 248 | every flip-flop set and cleared at least once (POOL once each way: it needs IC40's slow turns); IC49 counted to 1, not further, in 40 frames; settled within 2 steps; four pictures written |
| `scenery_fast` | 40 | 4 806 248 | IC49 reached 12 and cleared the state 11 times; POOL set and cleared 50 times; every output active; 5 pixels where IC68's /S and /R were released together; settled within 4 steps |
| `scenery_ic66nand` | 26 | 3 120 872 | IC66 as a NAND, same stimulus as `scenery`: /GRAVEL active in 1 489 521 pixels (`scenery`, AND: 16 660 in 40 frames); /WALL and TUNNEL AP never active in these 26 frames |
| `scenery_ic90a` | 12 | 1 435 496 | IC90 as drawn (AND and NOR sections); IC49 reached 12 three times |
| `scenery_ic90b` | 12 | 1 435 496 | IC90 as two AND sections; IC49 reached 12 three times |

The reference absorbed 12 to 16 short pulses on IC88's lower clock (/R-SIDE
glitching while M1V steps through several bits at once), none on IC68,
IC49 or IC40.

The pictures `scenery-1.png` to `-4.png` (frames 21–24 of the `scenery`
run) show, in false colours, what the outputs draw from the original PROMs
with the default readings:
- along the road edges (the grey band is ROAD): the yellow /Y-LINE, the
  white /SIDE LINE dashes and the /GREEN BELT verges;
- beyond the verges: rows of trees and palms (the two /TREE & GRASS outputs
  and /GRASS (W));
- near the lower edge: houses with red and magenta roofs (/HOUSE (R) and
  (Mu)) and brown walls ((St));
- a plain road with a /POOL patch on it.
The four frames are a few frames apart, so the M1V and M2V side lines and
the scenery have moved between them. `scenery-ic66nand-1.png` to `-4.png`
show frames 21–24 of the `scenery_ic66nand` run, with the same stimulus:
the same scenery with PR-137's /GRAVEL speckle, in tan, over the road and
the verges. `ic66-nand-and.png` sets the first picture of each run side by
side (left NAND, right AND). On 29 October the maintainer compared them with the real
game, which shows the AND picture (in its own colours, which sheet C sets).

Quartus 17.0 Lite Analysis & Synthesis of the module alone (Cyclone V
5CSEBA6U23I7) passes with no errors: 137 ALUTs and 120 registers. The only
warnings are the grounded PR-135 A8 output and the unused PR-136 O7 and O8
inputs (IC98's fourth output is not drawn). Verilator and Yosys were not
available on the machine used. The full `scripts/run_tests.py` stopped at
the existing sheet G test there: that machine's Icarus (a 12.0 development
build) rejects one line of `tests/sheet_g_reference.v`. The cases before
it passed, including `game`, which compiles the new module with the rest of
the core. The line was rewritten in the same meaning on 30 October and the
full suite passed ([CONNECTED.md](CONNECTED.md#tests)). This is a simulation result: no hardware run includes this module
yet.

## In the core

`jtmonacogp_game.v` instantiates sheets B and D. `jtmonacogp_stest.v` is a
test stimulus for the sheets they need that are not built (A, C, H, I). It
is not original circuitry:
- /COIN IN low, /GAME low, /EX. SIGNAL high, EXTEND high: a game in
  progress, so the state flip-flops are not held clear;
- a VS-driven frame counter for Vs/2, Vs/4 and Vs/16;
- the S-100 code, SP and /IN RESET from the buttons (README, "Development
  controls"). The code changes at the end of VS.

M1V and M2V start at D0 and 40 after reset, as in the tests, so that the
road is on screen.

`jtmonacogp_sview.v` draws the outputs in the false colours of the test
pictures, with sheet B's two text outputs over them. The raster is not
rotated: the road runs along H. Sheet D's picture sits one pixel to the
right of the raster position (its outputs are for the previous pixel); in
this view nothing is aligned to it.

A second copy of the module with IC66 as a NAND reads the same PROM data.
IC66 changes no state and no PROM address. The OSD option "IC66 reading"
(default AND) switches /GRAVEL, /POOL, /WALL and /TREE & GRASS (G) to it, so
the two readings can be compared on a monitor.

`tests/tb_game.v` captures the view twice, with each IC66 reading. At every
clock it checks the data that PR-133 to PR-137 return against the PROM
image, and that both copies give the same addresses. Quartus 17.0 Lite
compiles the whole game module for Cyclone V (virtual pins): 1 395 ALMs,
and setup slack of at least 9.5 ns at 48 MHz. No MiSTer build includes the
view yet: the RBF needs the JTFRAME Docker flow.

## Open items

- **IC66** is settled as an AND (trace, "Found on 29 October"): the scan
  is ambiguous, and the real game shows the AND picture. The parameter
  IC66_NAND (default 0) keeps the NAND reading available for simulation.
- **IC90** is settled as a 7425 (trace, "Found on 29 October"): the
  drawing is inconsistent, and the real game shows green verges on both
  sides of the road, which only the 7425 reading gives
  (`ic90-readings.png`). The parameter IC90_TYPE (default 1) keeps the other
  readings (as drawn: M1V = 0xFF, M2V = 0xEC; 7421: 0xFF, 0xFB) for
  simulation.
- The board races above.
- The S-100 inputs come from sheet I (score board), which is not
  traced. In the tests they change at random.
- Power-up: the board has no reset. The reset clears every flip-flop, IC49
  and IC68.
