# Sheet G headlight, explosion and splash (jtmonacogp_effects)

`cores/monacogp/hdl/jtmonacogp_effects.v` implements the part of sheet G
(96577-P, manual 420-0358, PDF page 27) that is not the player car: PR-125
with its comparators (headlight), PR-126 with IC64 (explosion) and PR-131
with IC70 (splash), from the pin tables in
[trace/SHEET_G_TRACE.md](trace/SHEET_G_TRACE.md). The player-car path is
`jtmonacogp_player.v` ([trace](trace/SHEET_G_PLAYER.md)); this module uses
its counters HC and VC and its windows. Its five outputs go to sheet C in
the *Connected sheets* display ([CONNECTED.md](CONNECTED.md)).

## What the paths do

As wired; HC and VC are the player car's pixel and line counters (the car
is at HC 0x80..0x9F, VC 0x30..0x4F).

- **Headlight (/LIGHT).** PR-125 holds a start column and an end column for
  each of the lines VC 0..127. Two 7485s compare HC with the selected column
  (IC46's /W picks start or end). In the tunnel (/TUNNEL low) a match in
  HC 0..31 switches IC51's latch 3 on and a later match switches it off; out
  of the tunnel it never switches on. The latch is also forced off while the
  player PROM PR-127 is off (an accident or a slide), and PR-125 itself is off
  during an accident. Drawn, the table is a cone in front of the car.
- **Explosion (/EXPLO AREA, /EXPLO (Y), /EXPLO (R)).** While sheet F's
  EXPLO.ST is high and EXPLO.SEL D low, IC64 draws PR-126 in the car's
  32 × 32 window, one of four frames picked by EXPLO.SEL A and B. The pixels
  are yellow while SEL A and SEL C are both low, red otherwise.
- **Splash (/SPLAY).** While sheet F's IC49 pulse (SPLAY B) runs, IC70 draws
  PR-131 in two 32 × 32 areas beside the car (VC 0x10..0x2F and 0x50..0x6F,
  IC51's latch 4, in the car's columns). /SPLAY A picks blobs or streaks.

On sheet C (SHEET_C_LOGIC.md), /LIGHT lifts the tunnel's black plane (IC19)
and joins /ROAD at IC15, /SPLAY joins /POOL and /SLIP at IC14 (the cyan
plane), /EXPLO (Y) and (R) are in the yellow and red planes, and /EXPLO AREA
joins /PLAYER and /DUMMY AREA at IC66, the mask the car's own area uses.

## Timing model

- The module follows the player path's settled-state model: the counters
  step one host clock after the pixel enable and the PROM data follow a
  clock later. From the third clock on the nets are settled.
- IC51's latches 3 and 4 take their inputs at the settled clocks only. On the
  board the comparator output and the latch's reset line carry 470 pF, which
  filter the counters' ripple states; at the first two clocks of a pixel the
  model's nets mix two pixels.
- The outputs are combinational on the settled nets and the latches; the game
  module holds them one pixel, like the player car's lines, for sheet C.
- A disabled 7641 (PR-125 during an accident, PR-126 without EXPLO.ST) reads
  0xFF, as for the player PROMs.

## Tests

`tests/tb_effects.v` (`effects` in `scripts/run_tests.py`) drives the module
and a pin-wired reference (`tests/sheet_g_effects_reference.v`: 7485, 74151
and 7427 models added to the gate, 74279 and 7641 models of
`tests/sheet_g_reference.v`, wired by IC and pin from the trace) with the
player path's counters and windows, the counter-start pulses at random
places each frame, and sheet F's lines changing at random (mostly once a
frame). It compares the five outputs and the internal EQ, W and window
nets at every pixel after the first frame, and requires the headlight to
switch on and off by the comparators and off by /S1, yellow and red explosion
pixels, splash pixels from both /SPLAY A pages and both window states.

Results: see [reports/sheet-g-effects-2026-10-31/README.md](../reports/sheet-g-effects-2026-10-31/README.md).

## Open items

- The trace's unresolved items: an inverter's designator (IC44 or IC46), a
  capacitor value read as 470 pF, the overbar on SPLAY B.
- The 470 pF filters are modelled by evaluating the latches on settled nets;
  their delays (tens of ns) are not reproduced.
