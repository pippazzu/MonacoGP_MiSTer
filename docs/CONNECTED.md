# Connected sheets (display 5)

`cores/monacogp/hdl/jtmonacogp_game.v` connects the sheet modules to each
other behind the OSD *Display* options **Connected sheets** (the picture in
sheet C's colours, `jtmonacogp_colour.v`, [SHEET_C_LOGIC.md](SHEET_C_LOGIC.md))
and **Connected false colour** (the same in development colours): sheets A
(`jtmonacogp_coin.v`), B (`jtmonacogp_motion.v`), D
(`jtmonacogp_scenery.v`), E (`jtmonacogp_timing.v`), F
(`jtmonacogp_control.v`), G (`jtmonacogp_player.v`), H
(`jtmonacogp_cars.v`) and, since 30 October, M (`jtmonacogp_rescue.v`:
rescue car, signs, lives, bridge; [SHEET_M_LOGIC.md](SHEET_M_LOGIC.md)).
This is the first time the sheets drive each other instead of test
stimulus. It is not the complete game:
- the picture is sheet C's; the second display keeps `jtmonacogp_gview.v`'s
  false colours, in an order of its own, for development;
- sheet I's score counter is in (31 October, `jtmonacogp_score.v`): the
  score from sheet F's /SCORE CP, stopping at 9999, gives S-100-A..D (D),
  S-100-D' (A, pad A30) and SP. CONT. (H, set at 6000). Since 1 November
  the rest of sheet I (high-score memory, search, ranks, N, R, flashing),
  the rank latches (K) and the display scan (J) are in too
  ([SHEET_I_LOGIC.md](SHEET_I_LOGIC.md)), with one correction (7H's DOWN
  clock, from the maintainer's photo of the panel); the panel is drawn on screen
  only while button 3 (Scoreboard) is held (`jtmonacogp_panel.v`, not
  original circuitry);
- the handle board (96599) is in (31 October, `jtmonacogp_handle.v`): its
  two optical sensors come from JTFRAME's dial, which a spinner, the mouse
  or the joystick's left/right turn (STEERING_TRACE.md);
- sheet G draws the player car, the headlight, the explosion and the
  splash (31 October, SHEET_G_LOGIC.md);
- the sound board is in as far as sheets D-3 and D-4 (1 November,
  SOUND_LOGIC.md): D-4's gates, D-3's MY CAR SOUND, D-4's explosion, skid
  tone and EXTEND beep (EX.CP from sheet A), the mixer and SOUND OUT, on
  JTFRAME's audio output; D-6 and D-7's other cars (2 November), whose
  pad C takes sheet H's /F-SOUND; D-2's rescue siren and back sound
  (2 November), whose pad P takes sheet M's /RESCUE CP; pad R (BACK SOUND
  OUT) as a second channel; D-1's slip zone (2 November), whose pad J
  takes sheet F's /SLIPZONE; D-5's hi-score tune (2 November), started by
  sheet A's /HISCORE, its alarm line un-muting SOUND OUT while it plays
  and sheet A's MUTE pad stopping that. Every sheet of the sound board is
  in.

## Nets between the sheets

The two boards meet through two cables, E to B (44 pins) and F to C (56
pins). The logic sheets do not draw them. A table of both cables is in an
owner's notes from 1999 (supplied by the maintainer, 30 October; not part of the
manual):
- F to C is straight: F*x* to C*x*;
- E to B is straight for E1–E16 and EA–ES, except that EN is printed "EN";
  then E17–E22 go to B19, B20, B21, B22, BT, B17 and ET–EZ to BV, BW, BX,
  BY, BZ, BU, B18.

The traces agree with it wherever both ends are drawn: sheet H's Vs/2,
Vs/4 and Vs/16 leave on pads B22, BY and B21, and sheet B takes them on
E20, EW and E19. The table settles the nets whose names are smeared or
differ on the two sheets (marked †).

Two labels disagree with it:
- Sheet B reads SP.B on pad F7. Sheet H sends it on pad CT (cable FT), and
  on board 96577 pad C7 is H5. Sheet B's "F7" is taken as FT; SP.B is
  connected by name.
- Pad E1 is the one that matters. Sheet A's pad B1 is COIN IN (IC37 pin 5,
  Q, no bar); sheet B's pad E1, the same wire, is labelled /COIN IN. Sheet B opens its top
text window (GAME OVER / EXTENDED PLAY) while Vs/16 is high and pad E1 or
/EX. SIGNAL is low. With COIN IN on E1, the window opens before a game,
showing GAME OVER, and during a game only while an extend is signalled,
showing EXTENDED PLAY. With /COIN IN it would never show GAME OVER and would
show EXTENDED PLAY in every game. The real game (30 October) shows red
GAME OVER above blue DEPOSIT COIN before a game, and the 1999 notes describe
the same, so pad E1 carries COIN IN.

| Net | From | To |
|---|---|---|
| ROAD | D pad E7 | F pad B7 |
| /TUNNEL | D pad EF | F pad BF |
| /EXT. 500 | D pad EJ (IC25 /Q) | F pad BJ; on to H, whose arrow comes from (F) |
| /SLIP | D pad FA | F pad CA |
| /POOL | D pad FM | F pad CM, /POOL(2) |
| BRIDGE AP. | D pad F18 | H pad C18 (no bar on sheet H) † |
| /CAR NO CONT | D pad F3 | H pad C3, /CAR SP. CONT. ("SP" smeared) † |
| /R-SIDE, /L-SIDE | D pads FD, FC | H pads CD, CC (/R1-SIDE, /L1-SIDE) |
| /TUNNEL & BRIDGE, /SLIDE, /GRAVEL | D | B IC95; G |
| /INI RESET | A pad BA | B pad EA, /IN RESET |
| COIN IN (IC37 Q) | A pad B1 | B pad E1, labelled /COIN IN on sheet B † |
| /COIN IN (IC37 /Q) | A pad BD | B pad ED; D, G |
| /GAME, /EX. SIGNAL | A | B, F |
| EXTEND | A | D, F; /EXTEND to G |
| /COIN & TEST, 8000 | A | F |
| CAR CONT. CL. | A | H |
| ACCE. ST. | F | A |
| ACCE. A..D, /SP. IRREG. | F | H |
| PL-H-ST., PL-V-ST., /ACC1, /HOME POS., EXPLO. ST. | F | G |
| PLAYER, /SP DOWN, SP. DOWN, /SCORE ST., /ACC1. ST, /ACC1. PULSE | G | F |
| Vs/2..Vs/64 | H | A (Vs/16), B, F, G |
| SP.A..D (PR-38 D0..D3) | H pads C16, CT, C17, CU | B |
| /OTHER BODY | H | F |
| /OTHER CAR | H (through C) | M |
| GAME OVER | M pad E16 | A pad B16 |
| /EX. SIGNAL CP | A pad B2 | M pad E2 |
| /RESCUE (Y), /BRIDGE (W), EXT. CAR CONT | M pads EB, EH, EX | F pads B8, BH, BZ |
| ACCE. D, EXPLO. SEL. D | F pads B14, BM | M pads E14, EM |
| /L2-SIDE, /R2-SIDE, /R-L-SIDE | M pads F4, F5, FE | H pads C4, C5, CE |
| Vs/4, Vs/16, Vs/32, Vs/64 | H | M (Vs/32 on E18, Vs/64 on EV) |
| V-(1)..V-(5), MH0..MH4 | B | M |
| /0-AREA, BRIDGE AP, EXT. 500, /EXT. 500, /CAR NO CONT, 100-C | D | M |
| EXTEND, /EXTEND, /GAME, /COIN IN | A | M |
| H and V lines, /HS, /VS | E | all |

## Timing between the sheets

Each sheet module evaluates its logic one pixel late (see the sheet notes),
so a net from one module reaches the next with a delay. Where two nets must
meet on the same raster position, the game module lines them up:
- **Collisions (sheet F).** ROAD, /SLIP, /POOL(2) (sheet D) and /OTHER BODY
  (sheet H) are registered for the previous pixel at edge 2; sheet F
  captures at edge 3. PLAYER (sheet G) is for the current pixel, so it is
  held for one pixel (taken at edge 3) and all four meet on the same raster
  position, as on the board.
- **The picture.** Sheets D and H give the previous pixel; sheet G's three
  outputs and sheet B's two text outputs are held for one pixel to match.
  The whole picture sits one pixel to the right of the raster position.
- **Not lined up**, because a pixel or two cannot matter there:
  - the slow control lines (coin, game, timer, Vs/n, ACCE., SP, the
    one-shots);
  - the side lines from sheet D to the direction latches of sheet H, which
    act inside 16-line windows; they reach H two pixels late;
  - sheet F's own raster inputs (H4..H8, V4..V7, /HS), which it uses for
    timing, not for collisions.

## Stand-ins (not original circuitry)

`jtmonacogp_gtest.v`, active only in the connected view:

| Line | Stand-in |
|---|---|
| COIN SW, TEST SW, CREDIT SW, TILT | MiSTer coin, service (test), start and tilt |
| changeover switch | DIP menu "Coin, play": 1 COIN 1 PLAY by default |
| ACCE. CONT. A, B | button 1: floored (A high, B low); released: both high (the pedal codes of `tests/tb_control.v`) |
| shift lever | up: high gear (NC closed), down: low gear (NO closed), button 2 changes over |
| IC27 pin 3, IC51 pin 3 (not drawn) | high |

The handle board's pulses come from the dial. JTFRAME's joystick emulation
steps the dial 16 times a frame at its highest sensitivity (12, 8 and 4 at
the others; `JTFRAME_DIAL_EMUSENS=16`, twice JTFRAME's default on request, 3 November 2026), four handle pulses a frame; the real rate depends on how fast the wheel turns and on the
slotted disc, which is not drawn.

## Tests

`tests/tb_play.v` (`play` in `scripts/run_tests.py`) runs the game module
with `FAST = 1` (one-shot capacitors / 1000, the 555's / 100). See its
header for the checks.

Results, 30 October 2026:
79 frames from power-up, every sheet module settled before its next
capture, no unknown video. Before the coin the timer read 00, sheet B
showed GAME OVER (4 758 pixels) and DEPOSIT COIN (23 052). The coin held
the timer at 90; the pedal started the game one frame later, and the timer
read 89 one pixel after GAME rose. The timer counted down 90 times, one at
a time, and the game ended at 00 (no extend earned: the S-100 stand-in
stayed at none). No EXTENDED PLAY during the game. SP
equalled PR-38's low nibble throughout. The handle moved the target 15 →
16 → 15 (the shake beside the road, see the open items); ACCE. reached 0
in low gear and 1 in high gear in the frames driven; 0 crashes.

Quartus 17.0 Lite compiles the whole game module for Cyclone V (virtual
pins): 2 197 ALMs (5 %), 876 registers, setup slack +10.68 ns at 48 MHz.

`tests/tb_game.v` still checks the other five displays; their pictures are
unchanged (pixel for pixel against the working notes (not published) and
the previous run).

The whole `scripts/run_tests.py` passes on this source (24 checks, about
2½ hours; `full-suite.txt` in the report): every sheet module against its
pin-wired reference, as before the connection. That run needed one line of
`tests/sheet_g_reference.v` (the 74393 outputs) written with `output reg`
before each port: the Icarus 12 development build on that machine rejects
several initialised outputs after one `output reg`. Same meaning.

## The real game, for comparison

Observations of real machines, to check the connected sheets against as
they fill in. Sources: The maintainer's videos and play (30 October), and an owner's
notes from 1999 that the maintainer supplied (play on a cockpit cabinet, the manual's
game description). None of this is used to build the circuits.
- **House rows (frames from several recordings, 30 October):** the
  left house row ends with a dark block on its right and the right row has
  its dark block on its left. In the simulated picture the left row's house
  starts one line (one pixel on the turned screen) out of step with its
  window, so the house's first line shows at the far end after a one-line
  gap; the recordings show the same layout, so this is the board's, not a
  fault of the core's sheet B or D timing. Do not "correct" it.
- **Start of a game (photo from a recording, 30 October):** the red player car at the
  lower right, on the green belt right of the road. Colours on that screen,
  for comparing sheet C: road dark grey with a purple cast, green belts
  along both road edges, yellow sand verges with green bushes, magenta and
  pink houses with a dark band between them, a blue-and-green area at the
  top left; other cars yellow, pink/magenta and green.
- **Extended play (photo, 30 October; score 6473, timer 00):** the
  road is bright blue; the verges blue with orange/peach speckles, the
  bushes orange star shapes; the green belts grey/white speckle; no dim
  (grey) road. Sheet C's wiring gives the blue road (IC14 with 7M, masked
  by the cars), the blue verges (IC10's upright section ORs /EXTEND with
  ROAD) and full brightness (EXTEND into IC34); the rest depends on the
  scenery data and is to be compared with a simulated frame. The other cars
  and the rescue car keep their black outlines on the blue road (photo of a
  real cabinet, 31 October); the bridge warning sign too.
- **Car outline missing in an accident on the green belt (30
  October):** first seen on the MiSTer build (photos of the CRT): the red
  player car, spinning after hitting another car, loses most of its black
  outline in the frames where it is on the green belt; on the road the spin
  images are whole. The maintainer confirmed that the real board does the same. As
  drawn on sheet G, the slide one-shot IC119 (fired by the car body on
  /GRAVEL or /SLIDE, held 0.13 s) enables the slide images PR128 while the
  accident enables PR129/PR130, on the same bus; the core takes the low
  level when two PROMs drive it (SHEET_G_PLAYER.md, item 6). Do not
  "correct" it.
- **Before a game:** the terrain stands still, other cars run up the
  screen (two at most), the player's car is not shown; red GAME OVER near
  the top, blue DEPOSIT COIN near the bottom; the timer reads 00.
- **Start:** after the coin and start, the timer shows 90 for 4 frames;
  the red car appears in the lower right and the timer turns to 89.
- **Timer:** 89 shows for 1 s 28 frames, later counts about 1.04 s; about
  93 s to 00 (SHEET_A_LOGIC.md).
- **End of a game:** at 00 the game ends unless extended play has been
  earned; then it goes on, with no time limit, until the lives run out, so
  in principle it can last indefinitely (30 October). Sheet A wires
  exactly this: at 00 with an extend earned it sets EXTEND instead of
  clearing the game, and GAME OVER from sheet M clears it.
- **Driving:** the pedal has off and three levels; the car moves up the
  screen as it accelerates, further in high gear. Each pulse of the
  wheel's sensor moves the car one step; the slip zone changes the step.
  The wheel turns freely.
- **Off the road** the car skids, shakes and slows a little; it does not
  crash. **Hitting another car** in timed play spins the car out back to
  its start position, losing its acceleration; in extended play it
  explodes. The other cars never crash.
- **Zones** follow the score's hundreds (the S-100 code; on sheet I it is
  the hundreds digit with S-100-D = P-3D OR NOT P-2C, so the code leaves
  0..7 at x80 of each hundred; sheet D starts a zone as the code leaves a
  value, which gives the table below once the screen finishes):
  in timed play
  smooth 000–295, slip 295–450, smooth 450–795, tunnel 795–000; in extended
  play smooth, gravel 095–150, smooth, slip 295–475, smooth, bridge
  595–635, smooth, tunnel 795–000 (each zone ends with a whole screen).
  Pools come at x185 and x685 (two in a row after 8,000). The rescue car
  comes only in extended play, near x000, x075, x125, x250 or x500, not
  every time.
- **Score:** by distance; one point a frame at full speed, sometimes after
  two; 4 frames a point while slipping at full speed; 6 to 10 points a
  screen. Extended play from 2,000 points, an extra car every 2,000;
  harder after 6,000 (the player's car faster), other cars faster at
  8,000; the score stops at 9999.

## Open items

- **Sound, reported on a MiSTer (2 November, build 20261102d):**
  passing cars sound bad about one time in two, the slip zone is too low,
  the rescue siren's pitch is about 30 % high against a board recording,
  and the siren is sometimes missing until the rescue car is halfway down
  the screen. Measurements and next steps: SOUND_LOGIC.md, "Open issues
  reported on the MiSTer".
- **Extended play colours (a MiSTer, 30 October build, 31 October):**
  - the other cars and the rescue car showed no black outline on the blue
    road (the blue showed through), while the bridge warning sign kept its
    black. Fixed on 31 October: IC5's A inputs are ROAD, not /ROAD (the
    arrow has no overbar), so the road's blue comes through IC14, which the
    cars mask (SHEET_C_LOGIC.md). Confirmed on a MiSTer with the
    31 October build: the cars have the right colours. Screens changing in
    mid-game (the tunnel turning into the slip screen) came from the score
    stand-in;
  - the bridge looks right at first; after more points the colours change
    again, and then the bridge looks wrong. Probably the old sheet I
    stand-in going past the real game's 9,999 (each wrap of its digit
    counted as 1,000 points more); the real score counter (31 October)
    stops at 9999. To check again on the MiSTer;
  - the gravel zone has never appeared in several games: the stand-in's
    codes were the plain hundreds digit, not sheet I's S-100 code. To check
    again with the real score counter.
- **Extends every 2,000 points** (recordings from several machines, the maintainer,
  31 October). With sheet I's 2E-1 drivers taken as inverters ("16" is
  printed above them) S-100-D' would fall at x800 and give extends at
  1,800; as non-inverting buffers (the triangles have no bubbles) it falls
  at each thousand, giving 2,000, 4,000, ... and "8000" at the eighth. The
  same choice makes sheet D's zone starts match the owner's table exactly
  (pools x185/x685, slip 295, bridge 595, tunnel 795, gravel 095), so the
  core takes 2E-1 as buffers.
- **An other car drawn split** (a MiSTer screenshot, 31 October, timed
  play): the cyan car's lower half is shifted sideways from its upper half.
  Not yet examined (sheet H's position counters reloading within the car,
  or the board's own behaviour?).


- **Extended play** ends through sheet M since 30 October: IC46 counts
  the extends earned (up to 3) and the falls of EXPLO. SEL. D, and GAME
  OVER rises at an EXPLO. SEL. D with none left (SHEET_M_LOGIC.md). Not yet
  run through a whole extended game in `tests/tb_play.v`.

- **The car starts beside the road, as on the real game.** At the coin,
  sheet F loads the player car's targets with 0x70 and 0x0F: the lower
  right of the upright screen. A photo of the real game at the start of a
  game (30 October) shows the red car there, on the right-hand green
  belt beside the road, so this is the board's behaviour, not a fault of the
  core's start values for sheet B's road counters (M1V, M2V at D0 and 40;
  the board has no reset for them). Off the road sheet F's slip and pool
  one-shots (IC43) fire and the vertical target swings a step back and
  forth every frame, while the handle is switched out: the real game's
  "shake" off the road. The road's swing needs speed: sheet B moves M1V and
  M2V only in frames allowed by SP (PR-38 at ACCE.), and with ACCE. at 0
  SP.C and SP.D are both high, which holds it. tests/tb_play.v drives for
  about 30 frames at ACCE. 0–1, so the road never moves under the car there,
  and it reports 0 crashes. A longer run at full speed, with the road
  swinging, is the next check.
- ACCE. climbs as sheet F times it: one step every 16 frames in low gear
  and every 64 in high gear below 7 (SHEET_F_LOGIC.md), so about 2 s to
  reach 6 in low gear.
- Sheet C (30 October): its colours are in the picture. Compare with the
  real game: sheet C puts DEPOSIT COIN in the cyan plane, which the maintainer
  describes as blue, and the bare road is dim white (grey).
- Sheets I, J, K (1 November): checked against their pin-wired references
  only. Not yet seen on the MiSTer; compare the panel with the real one
  (which row flashes, the ranks after several games). Which part makes the
  DOWN inversion is not known (SHEET_I_LOGIC.md).
- Sheet G's headlight, explosion and splash (31 October): in the picture,
  not yet compared with the real game or seen in a whole simulated game.
- The first timer count. By sheet A the timer holds 90 while /COIN & TEST
  is low and turns to 89 as GAME rises: the 555's output rises when GAME
  releases its reset, and IC21 counts on that rise (tests/tb_play.v checks
  it). On a 59.94 fps video of the real game (30 October) the timer
  reads 00 until start is pressed, then shows 90 for 4 frames, and 89 as
  the car appears. Those 4 frames are the time from the switch to GAME:
  the pedal sets GAME through ACCE. ST., which waits for a timing step on
  sheet F. The video's later seconds set the 555 timings
  (SHEET_A_LOGIC.md).
- BRIDGE AP.: sheet D's net is high during a bridge, and it clears sheet
  H's one-shots while low, so as wired here they can run only during a
  bridge. Sheet H draws the pad without a bar and sheet C reads /BRIDGE
  AP.; one of the labels, or the wire, may be wrong (SHEET_H_LOGIC.md).
- Sheet D's IC25 upper Q leaves with the label "/EXT.500 (H)" (pin numeral
  uncertain in the sheet D trace). Sheet H has no input from (D) for it: its
  /EXT. 500 comes from sheet F's pad BJ, which is D's IC25 /Q. The Q line is
  left unconnected here.
- The picture is not rotated; the road runs along H, as in the other
  development views.
- **Sound** (1 and 2 November, [SOUND_LOGIC.md](SOUND_LOGIC.md)): MY CAR
  SOUND, the explosion, the skid tone, the EXTEND beep, the other cars, the
  rescue siren, the back sound, the slip zone (pad J from sheet F's
  /SLIPZONE) and the hi-score tune (pad 3 from sheet A's /HISCORE, MUTE
  from sheet A's pad A26, its alarm line to D-4's mute gate) are built.
  The output gain is provisional (16,384 per volt at pad 13)
  until all sounds are built and the balance is compared with the maintainer's
  recordings of a real board. R414 (22K?) sets every sound's level in the
  mix and is read from the overview only. The hi-score tune's notes and
  tempo are settings (the printed notes, 42 ms a clock; SOUND_LOGIC.md,
  D-5), and so far it has been checked from its own scenario and
  tests/tb_sound.v's HI SCORE pulse, not from a game that ends with a new
  best score. The board's setting
  switches are in the MRA's DIP menu, 0 by default: the changeover switch
  (1 COIN 1 PLAY), DIP SW. 2's back-sound contact (closed: the back sound
  in the front speaker's mix) and its R423 contact (open). OSD "Back
  speaker" (not original circuitry) puts pad R on the right channel.
