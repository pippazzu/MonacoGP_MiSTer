# Sheet C logic (jtmonacogp_colour)

`cores/monacogp/hdl/jtmonacogp_colour.v` implements the gates, the AREA
register and the priority encoder of sheet C (96578-P, manual 420-0358, PDF
page 30), from the pin tables in
[trace/SHEET_C_TRACE.md](trace/SHEET_C_TRACE.md). It gives the picture of
the *Connected sheets* display ([CONNECTED.md](CONNECTED.md)).

## What the sheet does

As wired; the colour names are the drawn suffixes.

- **Planes.** Eight collectors gather the active-low picture lines of
  sheets B, D, G, H and M by colour, and the 74147 IC2 picks the highest:
  red (9), black (8), white (7), cyan (6), yellow (5), green (4), magenta
  (3), blue (2). Its code drives RED (bit 0), BLUE (bit 1) and GREEN
  (bit 2) through the open-collector inverters IC7 (7416). No active line
  gives black.
- **Other cars.** IC86 and IC79 pass AREA 1..5 into the blue, magenta,
  green, yellow and cyan planes while /OTHER BODY is low, one pixel late
  (IC79 is clocked by 7M). So an other car's body takes its channel's
  colour.
- **Brightness.** IC1 (7417) pulls the three outputs to a dim level
  (0.51 of full with the drawn 470 Ω and 10 kΩ; the monitor's input load
  is not drawn) while IC3.12 is low: when /ROAD or /LIGHT is active, none of
  IC13's lines is (the tree, house, line, red and cyan sources), and EXTEND
  is low. The bare road is therefore dim white (grey).
- **Extended play.** EXTEND gives full brightness everywhere and IC20
  re-routes: /TREE & GRASS (G) to white, /TREE & GRASS (BL) to yellow, and
  the blue plane takes IC14.6. IC5 passes ROAD (sheet D's active-high line,
  the second input arrow) to IC14 and to IC10's upright section:
  - on the road, IC14.6 carries 7M, so the blue plane is active for half of
    each pixel, except where IC8.12 is low: other cars, the rescue car's
    black, the player's, dummy's and explosion's areas keep no colour (black
    outlines), and rescue/gravel areas (IC15.6);
  - off the road, IC10.8 = OR(/EXTEND, ROAD) is low, so the blue plane is
    active for the whole pixel: blue verges, under the higher planes.
- **Bridge.** While BRIDGE AP is high IC5 takes the bridge's colour lines
  instead of ROAD, /Y-LINE and /SIDE LINE.

## Timing model

- The gates are combinational on the module's inputs, which the game module
  gives for the same pixel as the false-colour view: sheets D, H and M
  registered at edge 2, sheet B's text and V-(4) and sheet G's lines held
  one pixel.
- IC79 steps at edge 2 (`cen7`), where sheet H registers the next pixel's
  AREA; it takes the value before, so it holds AREA one pixel late, as on
  the board.
- 7M enters IC14: the module evaluates the gates for 7M high and for 7M low
  and outputs both, and their average as the 4-bit colour (MiSTer's pixel is
  the 7 MHz one). Levels: 0, 8 (dim) and 15 (full).
- /TV-BLANKING (TR1's clamp) and /SYNCRO are left to the video timing; the
  game module blanks outside the active area as before.

## Sheet G's other lines

/LIGHT, /SPLAY, /EXPLO. (Y), /EXPLO (R) and /EXPLO. AREA come from
`jtmonacogp_effects.v` since 31 October (SHEET_G_LOGIC.md), held one pixel
like the player car's lines. Before that they were held inactive.

## Tests

`tests/tb_colour.v` drives the module and a pin-wired reference
(`tests/sheet_c_reference.v`, its own part models, wired by IC and pin from
the trace) with random lines (each active with probability 1/q, q drawn
per pixel from 2 to 61) and compares IC2's code, the three colour bits and
the brightness line in both halves of every pixel; it requires every code
to win and the dim level, a mid-pixel colour change and IC79 holding an
AREA to occur. `tests/tb_play.v` checks that sheet B's top text is red on
the screen and reports the colours of the bottom text and the road.


## Open items

- 31 October: IC5's A inputs were first read as /ROAD; the arrow has no
  overbar (ROAD). With /ROAD, extended play drew the blue road over the
  other cars' and the rescue car's black outlines (seen on a MiSTer; a
  real board keeps them black).

- IC8's type (the drawing shows AND gates; the redraw lists 74LS12) and the
  label of the cyan plane (trace U1, U2).
- The dim level depends on the monitor's input load.
- DEPOSIT COIN (/COIN & START) lands in the cyan plane; the maintainer describes it as
  blue on the real game. To compare on a screen or a capture.
