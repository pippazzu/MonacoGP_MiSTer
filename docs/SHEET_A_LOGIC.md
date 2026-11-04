# Sheet A logic (jtmonacogp_coin)

`cores/monacogp/hdl/jtmonacogp_coin.v` implements every gate, latch,
flip-flop, counter, timer and one-shot of sheet A (96577-P, manual
420-0358, PDF page 25). It follows the consolidated pin list in
[trace/SHEET_A_TRACE.md](trace/SHEET_A_TRACE.md). It is a standalone module:
it is **not instantiated in the core yet**.

## What the sheet does

All statements here follow from the wiring and the data-sheet functions of
the parts. Signal names are the drawn labels.

- **Switches.** COIN, TEST and CREDIT each set an IC32 latch at rest; the
  latch resets while its switch is pressed. The changeover switch's common
  is the 1 kΩ pull-up (1 COIN 1 PLAY) or the credit latch (1 COIN 2 PLAY).
  IC125 ANDs the common with the TEST and COIN latches into /COIN & TEST:
  - it is low while a switch is pressed (in 2-play mode also CREDIT);
  - it loads the timer with 90 (/LOAD of IC21 and IC20);
  - it clears IC79 and IC50 (through IC73 and IC22b).
- **Coin and game.** IC37a sets COIN IN when /COIN & TEST rises, that is,
  when the switch is released. IC37b takes COIN IN at the rise of ACCE. ST.
  from sheet F: GAME.
- **Timer.** The 555 runs while GAME is high. IC22a passes its output to
  IC21 while IC20's /BO is high, so IC21 counts at each rise, the first one
  as GAME releases the reset: 90 turns to 89 at once. IC21 and IC20 count
  down from 90. The module's 555 timings come from a 59.94 fps video of a
  real game (30 October): 89 shows for 1 s 28 frames (the first high
  phase and a low one), 23 for 64 frames, 01 for 1 s 1 frame, and a game
  takes about 93 s. The single seconds differ by a few frames (frame
  edges), so a later count is taken from the whole game: 1.039 s. With the
  first interval 1.467 s, the first high phase is 1.159 s, then 0.731 s
  high and 0.308 s low; 89 to 00 takes 92.9 s. With C5 = 47 µF that is
  R4 ≈ 9.5 kΩ and VR1 ≈ 9.7 kΩ. The tests below use the redraw's values
  (R4 12 kΩ, VR1 at zero); the logic does not depend on them. At 00, as the 555
  goes low, both /BO go low. IC22a then holds IC21's CPD low, so /BO stays
  low until the next load. The counters' BCD outputs go to the display (J).
- **End of time and extended play.**
  - IC79 counts the falling edges on pad A30 (from sheet I). Each time its
    QA falls during a game, IC55c/d and R15/C25 make a short low pulse,
    /EX. SIGNAL CP (to sheet M). The pulse sets IC50's first half (an extend
    is earned) and starts IC49: 1.34 s of /EX. SIGNAL and of the EX. CP lamp
    blink (V2 and Vs/16).
  - When /BO falls with IC50's first half set, IC55b presets EXTEND (IC50's
    other half, whose clock is not connected), and IC61a/R14/C27 pulse CAR
    CONT. CL (to sheet H).
  - When /BO falls without it, IC61b and IC74 pull MCLR low. That clears
    COIN IN, GAME and IC50: the game ends.
  - MCLR falling with EXTEND set starts IC38's second half: a 1.3 ms
    /HISCORE pulse.
  - GAME OVER from sheet M also pulls MCLR low.
- **Tilt and power-up.** IC38's first half runs for 6.28 s, started by the
  TILT switch (pad AJ) or, at power-up, by its B input rising with the
  supply while R7/C14 hold A low. Its Q:
  - clears the timer and drives MUTE;
  - pulls MCLR low through IC74.
  Its /Q clears the credit memory IC33 and leaves as /INI RESET (to sheets
  B and I).
- **Credit memory and lamp.** IC33 is preset while COIN is pressed. In 2-play
  mode the credit latch clocks it clear. With COIN IN low and a credit
  stored, IC72 sets the credit latch's second /S and IC12 blinks the LED with
  Vs/16.
- **Meter.** IC44 and TR1 drive the coin meter while COIN is pressed.

## Timing model

Like the sheet F control logic, the sheet is evaluated one pixel late.
Host clocks are counted from the pxl_cen edge (edge 0):

- Edge 3: the inputs of the pixel are captured, and the outputs of the pixel
  before are registered.
- Every later host clock up to edge 2 of the next pixel is one settling step.

The 555, the one-shots and the two RC pulse shapers are counted in pixels
at each edge 3. Their widths come from the drawn R and C values: 74123
tw = 0.28·R·C·(1 + 0.7/R); 555 ln 3, ln 2 (Ra + Rb)·C and ln 2·Rb·C;
R14/C27 and R15/C25 about 235 ns to the gate threshold, taken as two
pixels.

**Settled layers**, as for the other sheets. Three loops are cut by reading
a net of the previous step:
1. IC22a reads IC20's /BO (the borrow latch at 00);
2. IC61b reads IC50's stored Q;
3. the 555's reset takes effect at the next pixel.

IC38's second half reads EXTEND at the previous step for its A trigger: on
the board MCLR reaches IC38 before it has cleared EXTEND through IC22b and
IC50, so a game cleared with EXTEND set gives /HISCORE. A first version
applied the clear in the same step and missed that pulse; the comparison
with the reference found it.

Not reproduced:
- the CR switch filters, RA1/RA2/C12/C14/D1 on the tilt input, and the
  470 pF capacitors;
- switch bounce and the moment when both contacts are open, which the IC32
  latches ride over;
- the trimmer VR1 (taken at zero);
- the 555's supply dependence.

## Tests

`tests/tb_coin.v` drives the RTL and `tests/sheet_a_reference.v` with the
same stimulus. The reference is wired IC by IC and pin by pin from the pin
list, with its own part models (no shared code with the RTL):
- gates 0.01 ns, latches and asynchronous inputs 0.02 ns, and 3 ns
  inertial filters on every clock, trigger, clear, preset, load and latch
  input;
- a 74192 counter, a 555, the 74123 and an RC shaper that count 7 MHz
  periods.

Checked for every pixel: all outputs (25 bits), 28 bits of internal state,
and that the RTL settled in time. Directed checks, written from the trace:
- /COIN & TEST loads 90;
- the timer only steps down, by one, at a 555 rise;
- every 555 phase has its exact length;
- every IC49 and tilt pulse ends exactly its width after its last trigger;
- /INI RESET is the tilt /Q;
- GAME rises only with COIN IN;
- EXTEND sets only at 00;
- a game cleared without GAME OVER or tilt is at 00 with the 555 low.

The stimulus is not gameplay. The cabinet and sheets E, F, H, I and M are
replaced by scripted and random inputs.

| Run | Frames | Pixels compared | Notes |
|---|---|---|---|
| `coin` (capacitors / 1000) | 41 | 4 926 632 | the power-up pulse, a coin and a start, four A30 pulses (an extend earned), the timer to 00 (EXTEND, CAR CONT. CL), GAME OVER (/HISCORE), a second game ended at 00, a 2-play credit, TEST, a tilt in a game, then 30 frames of random inputs: 17 games, 69 loads, 303 timer counts, 47 IC49 and 7 tilt pulses at their exact widths |
| `coin_full` (as drawn, tilt C19 / 1000) | 100 | 12 029 288 | a coin, a start and four A30 pulses: the first 555 high phase (5 650 562 pixels), a low and a high phase, and one IC49 pulse of 9 552 879 pixels, all exact |

Quartus 17.0 Lite Analysis & Synthesis of the module alone (Cyclone V):
0 errors, 0 warnings, 311 ALUTs, 184 registers. This is a simulation
result: no hardware run includes this module yet.

## Open items

- The switch contacts' reading (each switch resting on its upper contact)
  decides the latch polarity. If the drawing meant the opposite, the latches
  would be set while pressed. /COIN & TEST would then be low at rest, and
  the coin flip-flop would be clocked on the press instead of the release.
- R4 is faint on the scan ("?2K"; the redraw has 12 kΩ) and VR1's value is
  not legible. The game time is taken from the real game's video instead
  (above); VR1 is a trimmer, so other machines may run at other speeds.
- C14 reads "47" (µF?) or 2.2 µF. It only shapes the tilt input and the
  power-up hold of A.
- A30 comes from sheet I (score board, "S-100-D'"); which score step it
  marks, and so how many points earn an extend, is for sheet I. On the real
  game extended play is earned with points and lasts until the lives
  run out, which matches the wiring here: A30 earns it, and GAME OVER from
  sheet M ends it.
- The CREDIT switch's upper pad letter (AQ?) and the two time-digit pad
  names remain as in the trace's open items.
