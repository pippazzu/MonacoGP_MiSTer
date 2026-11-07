# Sheet F logic (jtmonacogp_control)

`cores/monacogp/hdl/jtmonacogp_control.v` implements every gate, latch,
counter and one-shot of sheet F (96577-P, manual 420-0358, PDF page 26) from
the pin tables in [trace/SHEET_F_TRACE.md](trace/SHEET_F_TRACE.md). It is a
standalone module: it is **not instantiated in the core yet**, because the
sheets that drive most of its inputs (A, D, H, M and the rest of G) are not
built. Integration replaces the matching outputs of `jtmonacogp_ptest.v`
(PL-H-ST, PL-V-ST, /HOME POS., EXPLO. ST., /ACC1 and the others listed in
the sheet G trace).

## What the sheet does

- **Accelerator.** IC15 (74193) counts toward the pedal position (ACCE.
  CONT. A/B through IC6, compared by IC7) at a rate set by Vs/16 or Vs/64
  (IC60), and down on Vs/8. Its count is ACCE. A–D. IC27 latch 4 and the
  gear latch IC32 pick the rate.
  Read from the logic (not from a note on the drawing): IC32 Q high lets
  IC7's target reach 8 and above, so it is high gear; in low gear IC15
  climbs no higher than 6, and IC27 latch 4 is reset (its /S, IC15 = 7, wins only while IC15 passes 7 on the way down). Changing up below 7 leaves the
  rate at Vs/64 until IC15 passes 7 and sets latch 4, which brings back
  Vs/16. ACCE. D (IC15 ≥ 8) also enables the slip and pool one-shots
  (IC43/IC49 /CLR).
- **Start position.** IC24/IC25 (horizontal) and IC35/IC36 (vertical) hold
  the player car's position targets. /COIN & TEST loads 0x70 and 0x0F. IC19
  and IC40 count pixels and lines, and IC17/IC18 and IC41/IC42 give PL-H-ST
  and PL-V-ST to sheet G when the counts meet the targets.
- **Steering and zones.** IC1 (handle one-shots), IC43 (slip and pool
  one-shots), IC49, IC3 and IC9 move the targets with the handle, in slips
  and in pools.
- **Crash.** IC14, IC80 and IC34 set IC27 latch 2 when the car touches the
  rescue car, a bridge, the road edge or another body. The crash clears IC15,
  starts the explosion (IC33, IC39, IC69) and walks the car back to its start
  position; /HOME POS. (IC23 pin 8) ends the crash when it is reached.
- **Score clock.** IC5, IC4 and IC8 give /SCORE CP at a rate set by the speed.

## Timing model

Two parts, described in the module header:

- **Position counters** (IC19, IC40 and the PL comparators) work on the
  current pixel, like the sheet G counters.
- **Control logic** is evaluated one pixel late: inputs are captured at
  edge 3 of the 7 MHz enable, five or six settling steps of the 48 MHz clock
  follow, and the settled outputs are registered at the next edge 3. The
  design check fails if the logic has not settled by then; it settles in
  three steps in every test run so far.

**Settled layers.** In one step, gates, latches and the asynchronous load,
clear and reset inputs are combinational. Each edge-triggered part (74193,
74393, 7474, 74123) compares its clock and trigger nets with the previous
step and changes its state for the next step. All parts clocked by the same
settled change act together and see each other's new outputs one step
later. Gate hazards do not exist in this model.

Three loops of gates and latches are cut by reading a net from the previous
step:

1. IC27 pin 1 (latch 1 /R) reads IC23 pin 3 from the previous step (loop
   IC27.7 → IC23.3 → IC27.1 → IC27.4 → IC44.2 → IC23.8 → IC27.5).
2. IC39's MR reads IC33's stored state (loop IC33.6 → IC39.2 → IC68.6 →
   IC23.11 → IC33.1). It differs from /Q only in the step in which /CLR
   empties IC33, and nothing reads the difference there.
3. IC1's two halves clear each other one step late.

**Races on the real board.** When the crash latch sets, IC33 clocks while
IC15 is being loaded, and both paths reach IC12 (IC25's clocks) and IC9
(IC36's). Whether IC25 and IC36 count one more step at that moment depends
on real TTL delays (roughly 40 ns against 60 ns, both under a pixel). Both
models follow the settled-layer rule, so they agree, but the board might
differ by one count of the start-position target at the crash. This is
recorded as an open point, not as a measured fact.

## Tests

`tests/tb_control.v` drives the RTL and `tests/sheet_f_reference.v` with the
same pseudo-random stimulus on the real sheet E raster:

- The reference is wired IC by IC and pin by pin from the trace tables,
  with its own part models (data sheet functions, no shared code with the
  RTL). Its delays make it settle in the same layers: gates 0.01 ns, latches
  and asynchronous inputs 0.02 ns, a 3 ns inertial filter on every clock
  and trigger input (it absorbs and counts gate hazards), 1 ns clock to
  output. The two loop cuts above are mirrored (a one-layer element on IC27
  pin 1, IC1 cleared one layer late).
- Checked every pixel: IC19, IC40, PL-H-ST and PL-V-ST (current pixel); all
  outputs, both targets and 37 internal state bits (previous pixel); RTL
  settling before each edge 3.
- Directed: PL-H-ST at H = 0x150 and PL-V-ST from the HS of line 0xFE after
  /COIN & TEST; every IC1, IC43 and IC49 pulse that runs out does so exactly
  the data sheet's 0.28·R·C·(1 + 0.7/R) after its last trigger (IC43 slip
  955 288 pixels, FAST 955).
- Each run starts with directed stages, then random play:
  0. pedal floored from rest in low gear, change up at ACCE. = 6, until
     ACCE. D (IC15 ≥ 8) is high;
  1. four frames of slip with the handle turned left and right in turn,
     then enough frames for the IC43 slip and IC1 pulses to run out;
  2. one pool, then enough frames for IC43's pool half and IC49;
  3. pedal floored until the car leaves its start position, one collision
     with EXTEND high, then calm until /HOME POS. ends the crash.
  Each stage that runs must reach its part of the circuit (IC27 latch 4,
  the one-shot pulses running out, the crash, the explosion reaching
  EXPLO. SEL = 12, the return to the start position).
- Three runs in `scripts/run_tests.py`:
  - `control_fast` (`tb_control_fast`): one-shot capacitors / 1000 and the
    Vs/n lines stepping every line; all four stages and 30 frames of
    random play.
  - `control` (`tb_control`): the circuit as drawn, Vs/n stepping once per
    frame; stages 0–2 (about 220 frames) and 30 frames of random play.
  - `control_crash` (`tb_control_crash`): the circuit as drawn; stage 3 and
    60 frames of random play.
  The full-length stages are split in two runs so that each stays well
  under the suite's one-hour limit per simulation. The short run
  supplements the full-length ones and does not replace them.
- The stimulus is not gameplay. Sheets A, D, G, H and M are replaced by
  random nets with plausible rates, quiet stretches without collisions,
  and a pedal that moves one position at a time. The pedal order (released
  {A, B} = 11, 01, 00, 10 full) is inferred from IC7's comparison word, not
  read from the drawing.

Results on 26 October 2026 (logs in `reports/sheet-f-2026-10-26/`):

| Run | Frames | Pixels compared | Notes |
|---|---|---|---|
| `control_fast` | 106 | 12 639 960 | all stages; every IC1, IC43, IC49 pulse that ran out did so at its exact width |
| `control` | 218 | 26 122 968 | ACCE. D by frame 188, from rest; IC43 slip 955 288, pool 1 432 932, IC49 2 101 633 and IC1 448 985 pixels, exact |
| `control_crash` | 137 | 16 371 864 | crash, explosion, return to the start position and end of the explosion within 97 frames |

The RTL settled within three of its five or six steps in every pixel.
Verilator 5.020 `--lint-only -Wall` and Yosys 0.33 `synth; check -assert`
pass on the module (1400 cells, no combinational loops). This is a
simulation result: no hardware run includes this module yet.

## Open items

- Sheet F U6–U11 (trace) do not change this module's logic: U6 and U8 are
  cross-sheet destinations, U7 a stub that reaches no pin, U9–U11
  handwritten notes. U9's IC3 table (slip = A 1 B 0, pool = A 0 B 1, normal
  = 1 1) agrees with the wiring (A = IC43 pin 12, B = IC43 pin 4).
- IC27 pin 3 and the IC47 strobes are not drawn: pin 3 is a module input
  (`ic27_3`), the strobes are left open (high).
- The RC filters (C3, C16, C17, the shift-lever RA2/0.1 µF) are not
  reproduced; the reference represents C3, C16 and C17 by its clock
  filters.
- The crash-moment race above.

## Pro board

Pro Monaco GP (manual 420-0525, sheet F, PDF page 9) adds one gate to the
score output for the bonus circuit of sheet N, read in
`pro/docs/trace/SHEET_F_BONUS_TRACE.md` (rows F01–F06). The module takes it
behind a `pro` input (1 = Pro board); with `pro` = 0 `bonus_point_n` is
ignored and every output is as above.

- **/SCORE CP (pad A14).** The normal score NAND (IC8 pins 9, 10 -> 8 here)
  goes to the lower input 9 of a combining gate, the Pro board's IC8 (OR
  body, bubbled inputs and output: an AND). /BONUS POINT (N) is its other
  input. Its output 8 goes through the noninverting buffer B17 (5 -> 6) to
  A14: `/SCORE CP = /BONUS POINT AND NOT(/SCORE ST AND Y)`, Y being the
  IC4 (74151) output. Each /BONUS POINT low pulse while the normal NAND is
  high is one falling edge, one point on sheet I's ones decade. There is no
  queue: overlapping low intervals make one edge.
- The score divider's clear is /GAME on both boards: no change there.

Ports: `pro`, `bonus_point_n` in, captured with the other inputs. In
`jtmonacogp_game.v` they are tied inactive (`pro` = 0, `bonus_point_n` = 1)
until sheet N is connected (#36).

`tests/sheet_f_reference.v` has the gate (instances `pro_ic8`, a 7408
section, and `pro_ic19`, the 7417 buffer B17), selected by `f_pro`, and an
observation port `score_nand` for the normal NAND's output. `tests/tb_control.v`
drives /BONUS POINT in every run as short low pulses from a random sequence
of its own (the rest of the stimulus is unchanged) and checks, every
compared pixel, `/SCORE CP = score_nand AND (/BONUS POINT OR NOT pro)` on
the reference; /SCORE CP is already compared with the RTL. With `pro` = 1
some bonus pulses must make a falling edge of their own; with `pro` = 0
none may. `control`, `control_fast` and `control_crash` run with `pro` = 0,
the new `control_pro` (`tb_control_pro`, as `control_fast`) with `pro` = 1.

Results on 5 November 2026 (Icarus Verilog, run as `scripts/run_tests.py`
does):

| Run | `pro` | Frames | Pixels compared | Notes |
|---|---|---|---|---|
| `control_fast` | 0 | 106 | 12 639 960 | as in the table above; /BONUS POINT low 83 020 pixels (78 105 with the normal NAND high), 240 /SCORE CP falls, none from a bonus pulse |
| `control` | 0 | 218 | 26 122 968 | as above; /BONUS POINT low 167 827 pixels, 1 800 falls, none from a bonus pulse |
| `control_crash` | 0 | 137 | 16 371 864 | as above; /BONUS POINT low 106 094 pixels, 99 falls, none from a bonus pulse |
| `control_pro` | 1 | 106 | 12 639 960 | the stages of `control_fast`; 2 621 /SCORE CP falls, 2 384 of them bonus pulses, RTL and reference equal |

Open items (Pro):

- The upper input numeral of the combining gate (11, or a damaged 10), the
  normal NAND's package and pins, and B17's package label (probably 19) are
  uncertain (trace U1); the reference uses pin 10 of a 7408 section, which
  does not change the logic. Short faded stretches of the /BONUS POINT trunk
  and of the Y -> NAND -> combining-gate route (U2) are read as continuous.
- The other Pro differences found on sheet F (C54 470 pF on the clock
  selector control, the pool one-shot's C32 22 µF instead of 15 µF) and the
  game-over race with 0 or 15 stored bonuses (U5) are not part of this
  change.
