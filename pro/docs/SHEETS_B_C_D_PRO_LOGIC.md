# Pro sheets B, C and D: the display timer, SLOW, BELT and D-EXTEND

Issue #109, 6 November 2026. What the new logic on Pro sheets B, C and D
does, worked out from the comparisons
[`trace/SHEETS_B_E_COMPARE.md`](trace/SHEETS_B_E_COMPARE.md),
[`trace/SHEET_C_COMPARE.md`](trace/SHEET_C_COMPARE.md) and
[`trace/SHEET_D_COMPARE.md`](trace/SHEET_D_COMPARE.md), with the scan of
`schematics/promonacogp420-0525_1.pdf` reread where a reading decides the
behaviour. Every statement follows from the drawn wiring and the data-sheet
functions of the parts unless it says otherwise. Aldo's description of a real
cabinet's attract mode ([`OBSERVATIONS.md`](OBSERVATIONS.md)) is used only as
a check, at the end.

Renders: PyMuPDF at `Matrix(1, 1)`, upright, as in `pro/README.md`. Boxes are
(left, top, right, bottom) on that render.

## Summary

- **/DISPLAY** (sheet B, IC72) is low in a *display mode* that starts
  without a coin: a 7474 pair clocked by the frame counter's Vs/512 and
  cleared by /COIN IN. A coin ends it at once. As drawn, IC72a cannot toggle
  (U1 below), so the mode could never start; the toggling reading is a
  correction, not a reading, and the Verilog makes it a parameter.
- **While /DISPLAY is low** (wiring settles all of this):
  - the road speed word to sheet B's MH counter is {SLOW, 0, 0, 0} instead of
    sheet H's SP: the road scrolls at the top speed (SP = 0, 24 pixels a
    frame) and at a third of it (SP = 8) while SLOW is high;
  - sheet D's scenery-event decoder is driven by a new counter on the
    distance clock instead of the score's hundreds digit, so gravel, slip,
    pool, tunnel, bridge and EXT. 500 sections come round on their own;
  - D-EXTEND, which replaces A's EXTEND on sheets C, D and M, is D-TIME, the
    top bit of that counter: the extended-play picture is switched on and off
    every 128 distance steps (about 40 s at the top speed);
  - /D-GAME is low, so sheet D's state flip-flops are not held clear.
- **SLOW** (sheet D) is high while any of the four scenery states GRAVEL,
  SLIP, TUNNEL and BRIDGE is set. The comparison read it as the
  inverted SLIP flip-flop; the scan shows it is the inverted IC128 NOR
  (below, "Rereadings").
- **BELT** (sheet D) is the PR-137 tree-and-grass term (the original IC58
  pin 11); on sheet C it removes those pixels from the new blue-only
  dimming.
- **D-EXTEND on sheet C** replaces 7M in the extended-play blue term and
  enables a new 470 Ω pull-down on the blue gun only. In extended play the
  original made that term flicker at the pixel clock; Pro holds it steady and
  dims blue in the analogue stage instead.
- **In a game** (/DISPLAY high) the picture logic is the original's, with
  three changes on sheet D that are not about the display mode: decoder
  output 1 is unused, output 6 clears EXT. 500, and the pre-stage flip-flop
  is clocked as S-100-D falls; the state flip-flops are released by /GAME
  instead of /COIN IN.
- **Is it an attract mode?** The wiring gives a self-running road with no
  input from the player's controls, entered only without a coin, left at
  once by a coin. That is a demonstration (attract) mode by its gates. It
  agrees with Aldo's description in every point the wiring reaches (last
  section).

## Rereadings

### Sheet B, IC72a (U-B1)

Boxes (1250, 2250, 2100, 2850) and (1560, 2560, 1680, 2680) on page 13.

- 72a: /CLR 1 and 72b /CLR 13 on the /COIN IN row (pad E1), D 12 of 72b on
  the same row, by drawn dots. CK 3 = Vs/512 (pad E8, from H). 72b CK 11 is
  the one output drawn on 72a. Q̄ 8 of 72b is /DISPLAY. **Clear.**
- 72a's D (pin 2) is drawn as a loop from pin 2, left, down under the
  package and up to a dot on the output wire between 72a and 72b. The Vs/512
  row crosses the left leg of the loop without a dot. **Clear: D is the drawn
  output.**
- The output's numeral: a diagonal stroke from upper right, a belly to the
  right and down, its foot on the output wire. It has no top bar; the
  drafter's 5 on IC70 (box (1910, 3040, 2010, 3300)) has one, and the
  drafter's 6 there starts with the same diagonal. A 6's loop would close on
  the wire, where it cannot be seen. **Reads 5; 6 is not excluded.**

With pin 5 (Q) on D, 72a keeps its state for ever: after a clear Q stays
low, 72b is never clocked and /DISPLAY stays high. The display mode, and so
the whole of D-TIME, SLOW's use on B and IC70's A inputs, would be dead
logic. Two single corrections make 72a a divider by two:

| Reading | 72a D | 72b CK | /DISPLAY falls, after /COIN IN goes high |
|---|---|---|---|
| 0, as drawn | Q (5) | Q (5) | never (holds its power-up state) |
| 1, the numeral is 6 | Q̄ (6) | Q̄ (6) | at the 2nd rise of Vs/512: 512 to 1024 frames, 8.6 to 17.2 s |
| 2, a D wire to 6 is missing | Q̄ (6) | Q (5) | at the 1st rise of Vs/512: 0 to 512 frames, up to 8.6 s |

Frame rate: 7.1525 MHz / (456 × 264) = 59.4 Hz (sheet E). **Not settled:**
the scan cannot choose between the three; only the board can. Reading 1
changes one doubtful numeral and keeps every drawn wire, so the Verilog uses
it by default (parameter `IC72A`); 0 and 2 are selectable.

### Sheet B, /COIN IN on pad E1

Box (600, 900, 2800, 2400) on page 13; box (5800, 3500, 7900, 4500) and
(3500, 3300, 6500, 4500) on page 8.

On the original, pad E1 is labelled /COIN IN on sheet B but carries COIN IN
(`docs/CONNECTED.md`). On Pro the question is settled the other way: Pro
sheet A has a single coin pad towards B, BD `/COIN IN (B)`, and it is IC54's
Q̄ (pin 6), the coin flip-flop whose Q feeds the GAME flip-flop IC47's D, as
on the original. So Pro's E1 is **/COIN IN**: low from a coin to the end of
the game. It drives PR-133's A8 (the original's pad ED net) and IC72.
**Clear.** (BD against E1 is the caption mismatch of the pad pairing, not a
second net.)

### Sheet D, SLOW

Boxes (1900, 5000, 3600, 6500) and (2150, 3440, 2750, 4120) on page 15;
column x ≈ 2300 walked from y = 3486 to 5690 (wire 6 to 9 px wide, every
crossing checked at 3–4× for a dot: none).

The SLOW inverter (pins 5 → 6, bubble on the input) takes the vertical at
x ≈ 2300, not the SLIP flip-flop's Q at x ≈ 3371, which goes only to pad EH
(SLIP). At y ≈ 3490 the x ≈ 2300 vertical turns right along a row to the dot
at x ≈ 2640 on IC104's CL (pin 12), and on to IC128 pin 6. So
**SLOW = NOT IC128.6 = OR(GRAVEL Q, TUNNEL Q, SLIP Q, BRIDGE Q)**, the
four flip-flops whose NOR clears the distance counter IC104 (the original's
IC32 → IC49). **Clear.** This corrects `SHEET_D_COMPARE.md` (row "SLOW",
"SLOW, an inverter of the same Q"). The destination letter is still
illegible on D; sheet B's IC29 pin 14 takes `(D) SLOW`.

### Sheet B, IC29 and IC70

Boxes (3300, 1900, 6000, 3300) and (750, 2050, 3300, 3600) on page 13.
As the comparison: IC29 S = /DISPLAY, /G and A inputs 2, 5, 11 at ground,
A 14 = SLOW, B 3, 6, 10, 13 = SP.A–D; outputs to IC22 2, 5, 11, 14 and
9, 12 to IC30 13, 12. IC70 S = /DISPLAY, /G ground: 2 D-TIME, 3 EXTEND
(pad EB; Pro sheet A drives it on pad BB, so the letter is B), 5 NOT D-TIME
(IC57 9 → 8), 6 /EXTEND, 11 /DISPLAY, 10 /GAME. **Clear.**

### Sheet D, the new input stage

Box (600, 2250, 2500, 3800) on page 15. As the comparison: 74157 IC34 (S =
/DISPLAY), 393 halves IC41 (both CLR = /DISPLAY; first CLK = Q (9) of the
HSB flip-flop, second CLK = first QD), XOR 113 (designator read 13 in the
comparison) of first QC and QD with C13, inverter 36 1 → 2 to IC34 pin 14,
D-TIME = second QD (pin 8). **Clear.**

## Sheet B

| Net | While /DISPLAY is high (a game, or no coin before the timer) | While /DISPLAY is low |
|---|---|---|
| MH speed word (IC29 → IC22, IC30) | SP.D–SP.A from H | {SLOW, 0, 0, 0} |
| D-EXTEND (IC70.4) → C, D, M | EXTEND (A) | D-TIME (D) |
| /D-EXTEND (IC70.7) → C, M | /EXTEND (A) | NOT D-TIME |
| /D-GAME (IC70.9) → D | /GAME (A) | low |

- **IC72**, with reading 1. While /COIN IN is low (a coin until the end of
  the game) both halves are clear and /DISPLAY is high. When /COIN IN goes
  high, 72a divides Vs/512 by two; its Q̄ rises at the second Vs/512 rise,
  clocks 72b with D = /COIN IN = 1, and /DISPLAY goes low. It stays low
  (72b keeps taking 1) until the next coin clears it. Power-up: the board has
  no reset for IC72, so /DISPLAY may start either way. On the original, sheet
  A's power-up one-shot clears COIN IN (`docs/SHEET_A_LOGIC.md`); if Pro's
  sheet A does the same (not checked), the display mode starts within 17 s of
  power-up without a coin.
- **Speed.** MH reloads with 0x20 + 2·SP on line 1FF, so the road moves by
  24 − 2·SP pixels a frame (`docs/SHEET_B_LOGIC.md`). {SLOW, 0, 0, 0} gives
  SP = 0 (24 pixels, the top speed: PR-38 gives SP = 0 at the highest ACCE.)
  or SP = 8 (8 pixels) while SLOW is high. Without the display mode and
  without a game, the original board shows PR-38's SP at ACCE. 0, which in
  Monaco GP's dump is 12: no movement.
- **Road width.** VSEL (IC87) lets M1V and M2V move one line a frame in
  frames where Vs/2 and Vs/4 are high, unless /TUNNEL & BRIDGE is low or
  SP.C and SP.D are both high. In the display mode SP.C is 0, so the road's
  edges swing between the IC69 windows, one step every fourth frame, outside
  tunnels and bridges. (With SP = 12, as at a standstill, they do not.)
- **Text.** Unchanged by IC72: /COIN IN is high, so PR-133 shows GAME OVER
  and DEPOSIT COIN where the window gates allow. The window's EX. SIGNAL
  input now comes from sheet A (U-B2 of the B comparison); it is not part of
  this logic.

## Sheet D

### The decoder input

IC34 passes S-100-A..D to the 7442 (IC35) while /DISPLAY is high, and
{X, 2QC, 2QB, 2QA} while it is low, where X = NOT(1QC XOR 1QD) (IC113,
IC36). 100-C to M is taken after IC34.

- **The counters.** IC41's first half counts the falls of the HSB
  flip-flop's Q (pin 9). That flip-flop samples /HS at each MH reload, so it
  turns once each time the reload drifts once round the line (456 pixels of
  drift): one *distance step*, every 19 frames at SP = 0 and 57 frames at
  SP = 8. The original's IC49 (Pro IC104) counts the same turns on the
  opposite edge. The second half counts the falls of the first half's QD:
  one every 16 steps. Both are held clear while /DISPLAY is high.
- **The decode.** With c1 the first count and c2 the second: X = 0 for
  c1 = 4–11 and 1 for c1 = 0–3 and 12–15. So for 8 of every 16 steps the
  7442 sees code c2 mod 8 (output n low), and for the other 8 it sees 8–15
  (no drawn output). Each state flip-flop is clocked as its output rises,
  which is when c1 goes from 11 to 12. The sequence repeats every 128 steps:

  | c2 mod 8 | Output | Clocks (as on the original) |
  |---|---|---|
  | 0 | 0 | GRAVEL takes D-EXTEND |
  | 1 | 1 | nothing (not connected on Pro) |
  | 2 | 2 | SLIP takes POOL's /Q |
  | 3 | 3 | nothing (not drawn) |
  | 4 | 4 | EXT. 500 takes D-EXTEND |
  | 5 | 5 | BRIDGE (Pro 56, pins 8–13) takes EXT. 500; /CAR NO CONT low for the 8 steps |
  | 6 | 6 | none; EXT. 500 is held clear for the 8 steps (new on Pro) |
  | 7 | 7 | TUNNEL takes SLIP's /Q |

- **D-TIME** is c2's QD: low for c2 = 0–7, high for 8–15. With D-EXTEND =
  D-TIME, GRAVEL and EXT. 500 (and through it the bridge) can only be set in
  the second half of the 256-step cycle, when the picture is in its
  extended-play colours. In the first half the sections are slip (with
  pool) and tunnel.
- **How long.** At SP = 0 a step is 19 frames, so 128 steps is about 2,430
  frames, 41 s; the 8-step event windows are about 2.6 s. While SLOW is high
  a step takes three times as long. At entry both counters are 0, so the
  first window (code 0) opens after 4 steps.

### The state flip-flops

- **Clear.** The NOR (Pro 63) takes /D-GAME where the original took
  /COIN IN. In the display mode /D-GAME is low, so the four flip-flops GRAVEL,
  SLIP, TUNNEL and BRIDGE clear only through the distance counter
  IC104 (QC · QD, or QD alone; gate 57's upper input is open on the scan,
  U in `SHEET_D_COMPARE.md`), as in a game. Outside the display mode they are
  held clear while /GAME is high: from the coin to the start of the game,
  where the original held them clear only until the coin.
- **Rewiring, in every mode.** On the original, the pre-stage flip-flop (D =
  /TUNNEL) was clocked as the code left 1 or 6, and EXT. 500 was cleared by
  NAND(HSB /Q, POOL Q) with the pre-stage. On Pro:
  - the pre-stage is clocked by NOT(IC34 4Y) (IC36 5 → 6), as the decoder's
    D input falls: in a game when S-100-D falls (the hundreds digit 9 → 0),
    in the display mode when c1 goes from 3 to 4 (the start of each event
    window);
  - EXT. 500 is cleared by output 6 instead of the NAND, which now clears
    only the pre-stage.
  What this changes in a game was not worked out beyond these edges.
- **SLOW** = NOT IC128.6, high while any of the four is set. So in the
  display mode the road slows to SP = 8 through each gravel, slip, tunnel or
  bridge section and runs at SP = 0 between them. SLOW also changes how fast
  the counters step through the section.
- **New outputs.** SLIP (pad EH, to H) is the SLIP flip-flop's Q. BELT (to
  C) is the PR-137 term AND(IC119 1Y, IC80 10) that also feeds TREE & GRASS
  (G).
- **/ACCI. AREA** on pad E7 is AND(ROAD, /BRIDGE (W), /RESCUE (Y)). The
  original sent the three to sheet F separately (pads B7, B8, BH), where
  they meet in one NAND (IC14, with /OTHER BODY). If Pro sheet F's IC14
  takes /ACCI. AREA on its ROAD input with the other two tied high, the
  function is unchanged; Pro sheet F was not traced for this.

## Sheet C

- **The blue term** (Pro 57, the original IC14 1, 2, 4, 5 → 6) is
  NAND(D-EXTEND, 51.6, 68.8, E3.4), with 51.6 = AND(/RESCUE (BL), /GRAVEL)
  AND NOT BELT AND NOT the splash term (62.8: splay, pool, slip or house).
  The original had 7M in place of D-EXTEND and the plain AND in place of
  51.6.
- **The extended-play multiplexer** selects that term (3B) only while
  D-EXTEND is high, so D-EXTEND on its input changes nothing there. With
  D-EXTEND low the term is high and nothing below acts.
- **The blue-only pull-down.** 7417 (11 → 10) and R8 470 Ω pull the BLUE
  node down while the term is low. With R9 470 Ω up and 10 kΩ down
  (normalised to the full level, as `jtmonacogp_colour.v` does):

  | Blue gun on, and | Level (of 15) |
  |---|---|
  | no pull-down | 15 |
  | R8 or the common dim alone | 0.51 → 8 |
  | R8 and the common dim | 0.34 → 5 |

  The monitor's input load is not drawn, as for the existing levels.
- **What it does.** In extended play the original's term chopped the blue
  plane at 7 MHz on the road (the bridge mux 1Y is ROAD there), half of every
  pixel. Pro keeps that pixel blue for the whole pixel and dims the blue gun
  to about half through R8: the same average, without the flicker. BELT and
  the splash term take the tree-and-grass and the splay, pool, slip and house
  pixels out of it. R8 acts whatever plane wins the 74147, so a blue-gun
  colour from a higher plane on the same pixel is dimmed too.
- **Where it shows.** Only while D-EXTEND is high: extended play in a game,
  and the second half of each D-TIME cycle in the display mode.

## Sheet M

D-EXTEND and /D-EXTEND reach the same two pins as the original's EXTEND
pair: the rescue timer's clear (IC104 CL, /D-EXTEND) and the dummy-area NAND
(IC62, D-EXTEND) (`SHEET_M_COMPARE.md`). In the display mode they follow
D-TIME. What sheet M then draws was not worked out here.

## Against Aldo's description (check only)

Aldo (`OBSERVATIONS.md`, 6 November 2026): the road scrolls and gets wider
and narrower; there is no player car; other cars appear at random, at most 2
on screen at a time.

- *The road scrolls*: yes, at SP = 0 or 8, where the original board without
  a game stands still (SP = 12). **Agrees.**
- *Wider and narrower*: yes, VSEL runs because SP.C = 0. **Agrees.**
- *No player car*: not from this logic. The player car follows sheets F and
  G, which do not see /DISPLAY; with no coin and no game they behave as on
  the original. Not checked here.
- *Other cars, at most 2*: sheet H, which this logic reaches only through
  /CAR NO CONT (code 5) and EXT. 500. Not checked here.
- Nothing in the description contradicts the timer (an attract mode that
  starts some seconds after a game) or the colour switching, but it does not
  mention them either: whether the real attract alternates between the normal
  and the extended-play picture every 40 s or so is a question for the
  cabinet.

## In the core

Behind `pro` (the game's `PRO` parameter); with `pro` = 0 every output is as
before.

- `jtmonacogp_motion.v` (B): IC72, with the parameter `IC72A` (0 as drawn,
  1 the numeral read as 6, the default, 2 a missing D wire to pin 6); IC70;
  IC29 in front of IC111 and IC110. IC72 steps at the host clock after
  Vs/512 rises, since Vs/512 comes from sheet H's frame counter.
- `jtmonacogp_scenery.v` (D): Pro IC34, IC41, IC113 and IC36 in the settled
  model of the sheet; the rewired pre-stage clock and EXT. 500 clear;
  /D-GAME on the clear NOR; the new outputs D-TIME, SLOW, BELT, SLIP and
  100-C. /ACCI. AREA is not formed (U4: sheet F's model already ANDs the
  three nets). SLIP is not connected yet (sheet H).
- `jtmonacogp_colour.v` (C): the regated blue term and the R8 dimming
  (outputs `bdim_hi`, `bdim_lo`; blue levels 8 and 5 as above).
- `jtmonacogp_game.v`: Vs/512 is sheet H's frame counter bit (also PR-39's
  A1); D-EXTEND and /D-EXTEND go to sheets C, D and M; 100-C to M comes from
  D's multiplexer.
- Power-up: the core clears IC72 and IC41 at reset, so without a coin the
  display mode starts at the second rise of Vs/512.

Tests (`scripts/run_tests.py`): `motion_pro`, `scenery_pro` and
`colour_pro` compare the Pro paths with the pin-wired references
(`tests/sheet_b_reference.v`, `sheet_d_reference.v`, `sheet_c_reference.v`,
which now have the Pro parts); `play_attract` runs the connected sheets
with `PRO` = 1 and no coin for 40 frames, from IC72's other power-up state
(/DISPLAY low), and writes a picture every eighth frame. In that run the
road scrolls every frame and its edges move, GAME OVER and DEPOSIT COIN
show, there is no player car and other cars come by.

## Uncertain

| ID | What | What would settle it |
|---|---|---|
| U1 | IC72a's output numeral (5 or 6) and so whether the timer runs, and after one or two Vs/512 rises (readings 0, 1, 2) | The board; a timing of the real attract's start after a game over (8.6–17.2 s for reading 1, up to 8.6 s for reading 2) |
| U2 | Power-up state of IC72 and of the IC41 counters (no reset drawn) | The board |
| U3 | Gate 57's upper input on D (QC or open), which sets when IC104 ends a section | The board (from `SHEET_D_COMPARE.md`) |
| U4 | Whether Pro sheet F takes /ACCI. AREA in place of ROAD with /RESCUE (Y) and /BRIDGE (W) tied off | A trace of Pro sheet F's IC14 |
| U5 | The analogue blue levels with R8 (monitor load not drawn) | A measurement |
| U6 | SLOW's circled destination letter on D (illegible; B's caption reads D as its source) | A sharper scan |

## Not checked

- The 470 pF capacitors added on sheet D (C10–C13) and their effect on the
  event clocks.
- What sheets F, G, H and M draw in the display mode (player car, other
  cars, rescue car, signs).
- The bonus payout after a game over (sheet N) against the start of the
  display mode: with many stored bonuses the payout can outlast 8.6 s.
- The EX. SIGNAL text qualifier, now on sheet A (U-B2).
- SLIP on pad EH: its use on Pro sheet H (`SHEET_H_COMPARE.md`, pad BH).
- /L1-SIDE and /R1-SIDE to sheet M.
