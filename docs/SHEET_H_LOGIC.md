# Sheet H logic (jtmonacogp_cars)

`cores/monacogp/hdl/jtmonacogp_cars.v` implements every gate, latch,
flip-flop, counter, one-shot and PROM path of sheet H (96577-P, manual
420-0358, PDF page 28). It follows the pin tables in
[trace/SHEET_H_TRACE.md](trace/SHEET_H_TRACE.md). It is a standalone module:
it is **not instantiated in the core yet**.
- PR-132 is bank 7 of `jtmonacogp_proms.v` (offset 3584).
- PR-38 and PR-39 are its 32-byte banks 17 and 18 (offsets 8704, 8736).

## What the sheet does

All statements here follow from the wiring and the data-sheet functions of
the parts. Signal names are the drawn labels.

- **Frame counter.** IC79's second half and both halves of IC78 count the
  falls of /VS: Vs/2 to Vs/1K, for sheets A, B, F, G and M and for this sheet.
- **Divider.** IC102 (low) and IC101 (high) count 7 MHz. IC80 loads them
  (IC101 with 3, IC102 with IC108's nibble) when they reach FF while IC87 is
  set. IC87 toggles each time they leave FF, so they load on every second
  pass. The nibble is 8, or PR-38's D7..D4 on line 1FF (/(V-CA × V8) low).
  - One period is 464 − L pixels: 456, exactly one line, with L = 8.
  - On line 1FF, IC86 holds IC112's second half clear and IC81c reset during
    the load, so IC102 then waits for IC112 to count 14 MHz edges up to IC113's
    word {ACCE. D, ACCE. C · /SP. IRREG., ACCE. B, 1}. That adds m = 4·D +
    2·(C · /SP. IRREG.) + B pixels.
  - So once a frame the divider's phase moves against the raster by
    8 − L + m pixels, with L from PR-38 at the accelerator position and
    SP. CONT.
  - PR-38's D3..D0 leave on pads CU, C17, CT, C16; sheet B receives them as
    SP.D..SP.A.
- **Three position channels.** Each is two 74161s clocked once per divider
  period, counting while /V8 is high, so once per visible line. When the
  high half wraps, the low half loads:
  - 9 or 7 from its direction latch (IC81a, d, b): with 8 the count would
    stay put, with 7 or 9 it moves a line a frame;
  - or 8 while channel 1's select is low (IC107: one frame in four, "0.25
    speed") or channel 2's (one frame in two, "0.5 speed");
  - channel 3 always moves ("1 speed").
  The high half at 1010 opens the channel's 16-line window (IC122, IC123).
  Inside its window, the latch is set by a low /L-SIDE and reset by a low
  /R-SIDE: the note reads 0 → left, 1 → right.
- **One-shots.** Each turn of the latch of channels 1 and 2 starts an IC121
  (channel 1, 1.34 s) or IC120 (channel 2, 2.94 s) half, which holds the
  select low while it runs. BRIDGE AP. low clears them.
- **AREA and which channel shows.**
  - IC94 decodes IC101 Q3..Q1 while IC87 is set: AREA 1, 2, 3, 5. IC107/IC106
    decode AREA 4 in the other pass. They are windows along the line.
  - During VS, at each HS inside an AREA window, IC92, IC99 and IC75's first
    half take bits of PR-39. PR-39 is addressed by Vs/256..Vs/1K and by
    IC112's first half (the car-pulse count, up to 3, cleared by CAR CONT.
    CL.).
  - IC100 and IC68 then enable at most one 367 buffer per AREA. The enabled
    channel's low half addresses PR-132 with IC102 Q1..Q3, IC101 Q0 and
    Vs/4, and its window is the strobe line.
- **Image.** IC118 picks the even or odd bits of PR-132 by IC102 Q0 while
  the strobe line is low; IC114 inverts them into /OTHER TIAR (D2/D3),
  /OTHER BODY (D4/D5) and /OTHER CAR (D6/D7).
- **/F-SOUND.** IC75's second half takes /H6 each time the strobe line rises,
  cleared by /H8; its /Q leaves through IC29.

## Timing model

Host clocks are counted from the pxl_cen edge (edge 0). Like sheet D, the
sheet is evaluated one pixel late. Edge 2 is the 7 MHz edge that ends a
pixel. In order:
1. the pixel's outputs are registered;
2. IC112's second half and IC81c take that pixel's two 14 MHz edges;
3. IC101 and IC102 step on the pixel's settled nets;
4. the one-shots count the pixel;
5. the next pixel's inputs are captured.
Every later host clock up to edge 1 is one settling step. In every run the
state settled within four steps.

**Every element takes one step.** Gates are combinational on the state.
Every flip-flop, latch, counter and one-shot, and every asynchronous clear,
changes state for the next step from the nets of the current one. On sheets
A, B and D, latches and clears were combinational instead. That does not
work here: the direction latches feed the load inputs of counters clocked in
the same layer, and the pin-wired reference, where a latch takes a filter
and 0.02 ns, has them change after those counters have sampled. The PROMs
also take a step, as synchronous memories in the RTL and a 3.02 ns delay in
the reference. A flip-flop's clock acts only if its /CLR was released at the
step before as well. This matters for IC75's second half, whose clock (the
strobe line, from the divider) and /CLR (/H8, from sheet E) can change at
the same 7 MHz edge: the clock then sees the clear as it was. The 40-frame
run found this case at pixel 3 083 473, before the rule was added.

**14 MHz.** On sheet E, IC109 divides 14 MHz by two on its rising edge, so
the 14 MHz falls (IC112's clock) come once in each half of the pixel. The RTL
counts two per pixel and checks IC113's equality at each. The testbench
drives the reference's f14 with falls 30 and 90 ns after the 7 MHz edge.

**Inputs.** The reference sees the other sheets' nets 5 ns after the 7 MHz
edge, after IC101 and IC102 have sampled theirs (3 ns filter). So the
divider steps on the old values and everything else sees the new ones, as in
the RTL.

Races on the real board, which this model decides one way:
- Several elements are clocked through gates by the 7 MHz divider (IC87,
  the position counters via IC80) or by sheet E's counters (IC75's second
  half via the strobe line and /H6). Whether the position counters see a
  side-line pulse or a new /V8 that arrives in the same 7 MHz period depends
  on real delays; the model gives every element one layer.
- C41, C42 and C29 slow the divider's load line, IC101's TC and IC112's
  clock. The reference absorbed about 500 short pulses a frame on IC87's
  clock (IC101's TC glitching while both halves step), as C42 would on the
  board.

Not reproduced: the 470 pF capacitors (C28, C29, C36, C41, C42, C43, the one
on IC66.6) and RA3, the pull-ups of the 367 bus (modelled as a high level
with no buffer enabled).

## Tests

`tests/tb_cars.v` drives the RTL and `tests/sheet_h_reference.v` with the
same stimulus on the real sheet E raster.
- The reference is wired IC by IC and pin by pin from the trace tables, with
  its own part models (no shared code with the RTL), including the 74161,
  74107, 74259 (as a decoder), 7485, 74367 bus with pull-ups, 7450 and 74123.
- Checked for every pixel: all outputs (19 bits) and 69 bits of internal
  state; that the RTL settled before edge 1.
- Directed checks, written from the trace:
  - every divider period is 456 pixels, or 464 − L + m for a cycle loaded on
    line 1FF (not predicted when L = 15, where IC101 counts during the
    pause);
  - the frame counter counts every fall of /VS;
  - at most one AREA line and one 367 enable are active;
  - with none enabled the strobe line is high, and with it high the /OTHER
    outputs are high.
- Stimulus, not gameplay:
  - ACCE., SP. CONT., /SP. IRREG. and /EXT. 500 change at frame starts;
  - side-line pulses one line long at random lines;
  - random BRIDGE AP., car pulses and their clear.
- Two runs in `scripts/run_tests.py`:
  - `cars` (one-shot capacitors / 1000, 40 frames, pictures of frames 31–33);
  - `cars_full` (as drawn, 200 frames).

Results, 29 October 2026 (logs in
[reports/sheet-h-2026-10-29](../reports/sheet-h-2026-10-29/README.md)):

| Run | Pixels | Divider periods | Settled within |
|---|---|---|---|
| `cars` (40 frames, capacitors / 1000) | 4 806 248 | 10 500 of 456; 38 from line 1FF, all 464 − L + m | 4 steps |
| `cars_full` (200 frames, as drawn) | 24 067 688 | 52 586 of 456; 192 from line 1FF, all 464 − L + m | 3 steps |

In the 40-frame run the direction latches changed 44 times, the IC121 and
IC120 halves ran 25/24 and 26/25 pulses, and /OTHER CAR, /OTHER BODY and
/OTHER TIAR were low for 12 028, 3 700 and 3 330 pixels. No L = 15 cycle
came up, so that case is checked only pixel by pixel against the reference.

Quartus 17.0 Lite Analysis & Synthesis of the module alone (Cyclone V):
0 errors, 432 ALUTs, 279 registers. The warnings are the open PR-39 D5–D7 and
PR-132 D0/D1 (IC118's Za is not drawn), and one debug bit always low. This is
a simulation result: no hardware run includes this module yet.

## Open items

- BRIDGE AP. (pad C18) is drawn without a bar here. Sheet D's BRIDGE AP is
  high during a bridge; sheet C reads /BRIDGE AP. The connected core
  (30 October, [CONNECTED.md](CONNECTED.md)) joins pad C18 to sheet D's pad
  F18 as one wire, by the pad rule there, so the one-shots are held clear
  outside bridges. Whether a label or the wire is wrong is still open.
- /CAR SP. CONT. (pad C3, "SP" smeared) is sheet D's /CAR NO CONT (pad
  F3), by the same pad rule.
- The inputs from sheet M (/L2-SIDE, /R2-SIDE, /R-L-SIDE) come from a sheet
  that is not built.
