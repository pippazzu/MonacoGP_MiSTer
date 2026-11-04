# Sheet G player-car pixel path

Source: Sega **Monaco GP (420-0358)** manual, PDF page **27**: board 96577-P,
drawing G, sheet D3/4. All positions are given in pixels of the rendered sheet
image (10160 x 6624, rotated upright). The excerpts below were cropped from that
image.

| Excerpt | Contents |
|---|---|
| line counter | IC63, IC54, IC48/IC45/IC46, IC51 window latch |
| pixel counter | IC63, IC52, IC34, IC57 window gates |
| PROMs and enables | PR127..PR130, IC95, IC73, /EXPLO.ST |
| mux and decoder | IC56, IC62, IC76, IC83, IC61, IC44, IC68, connectors |
| select state | IC38, IC80, IC72, IC62, IC66, IC119, IC51, IC19, bottom-edge outputs |

How the drawing was read:

- A dot means a junction.
- A crossing without a dot, including a four-way crossing, is not a junction.
- Gate functions are taken from the symbol:
  - AND body with an output bubble: NAND.
  - AND body with bubbles on every input: NOR.
  - AND or OR body with bubbles on its inputs and its output: OR or AND, by De Morgan.
  - OR body with bubbles on its inputs only: NAND.
- Chip pin functions come from the standard 74xx pinouts. Each pin number written on the drawing was checked against that pinout.
- Every claim below was re-read independently from fresh crops by six reviewers, one per group:
  - All 31 connection claims were confirmed.
  - Four were confirmed with a labelling detail. Those details are recorded in the notes and under "Unresolved".
  - The reviewers found IC19 and IC68, which an earlier draft of this trace had listed as unknown sources.
- The page extraction, the 31 claims, the crop boxes, the probe points and the net-extraction tools are in work/.

## Signal path in brief

1. **Counters.** IC52 counts 7 MHz pixels after PL-H-ST and stops at 0xA0. IC54 counts the ends of HS pulses after PL-V-ST and stops at 0x80. These counts are written HC and VC below.
2. **Window.** IC57 opens the horizontal window for HC 0x80..0x9F, and only while /COIN IN is low. The IC51 latch opens the vertical window from VC 0x30 to 0x4F. Their NAND, ORed with EXPLO.ST, is the active-low strobe.
3. **PROM address.** Each PROM is addressed by A0..A4 = VC0..VC4, A5..A7 = HC2..HC4, and A8 = a frame-counter bit. One of PR127..PR130 is enabled at a time.
4. **Mux and decoder.** HC0/HC1 select one of D0..D3 (1Y) and one of D4..D7 (2Y) in the 74153. The 7442 decodes {2Y,1Y} into three active-low outputs: /PLAYER BODY, /PLAYER TIRE and /PLAYER (BL).
5. **No shift register.** The path is combinational from the counters to the outputs, within the same pixel period.

## Pin tables

### Line counter and vertical window

| Part / pin | Net | Connection |
|---|---|---|
| IC63 (7402) pins 5, 6 -> 4 | | NOR(/HS (F), IC54 pin 8 = VC7) -> IC54 pin 1 |
| IC54 (74393) pins 2, 12 | PL-V-ST (F) | 680 pF to ground on the line |
| IC54 pin 1, pin 6 -> pin 13 | | Clock; the first half's QD clocks the second half |
| IC54 pins 3, 4, 5, 6 | VC0..VC3 | |
| IC54 pins 11, 10, 9, 8 | VC4..VC7 | |
| IC48 (NAND; pins not drawn) | | NAND(VC6, VC4) -> IC51 pin 1 (/R) |
| IC46 (7404) pins 3 -> 4 | /VC6 | |
| IC45 (7410) pins 1, 2, "3" -> 12 | | NAND(/VC6, VC5, VC4) -> IC51 pin 2 (/S1). The third input is written "3"; the 7410 pin is 13. |
| IC51 (74279) pin 4 (Q) | VWIN | Pin 3 (/S2) is not drawn |

VC advances at the end of each HS pulse (/HS rising). When VC7 sets, IC63 holds the clock low, so VC stops at 0x80. The latch has three conditions:

- **Set:** VC 0x30..0x3F.
- **Reset:** VC6 & VC4, which is VC 0x50..0x5F and 0x70..0x7F.
- **Hold:** everything else.

So VWIN is high for VC = 0x30..0x4F, 32 lines. The 74393 ripple states that occur between settled counts were enumerated. None of them sets or resets the latch spuriously, because they only pass through lower counts.

### Pixel counter and horizontal window

| Part / pin | Net | Connection |
|---|---|---|
| IC63 (7402) pins 3, 2 -> 1 | | NOR(7MHz (F), IC34 pin 11) -> IC52 pin 1 |
| IC34 (7408) pins 13, 12 -> 11 | | AND(HC5, HC7) |
| IC52 (74393) pins 2, 12 | PL-H-ST (F) | C23 470 pF to ground |
| IC52 pins 3, 4, 5, 6 / 11, 10, 9, 8 | HC0..HC3 / HC4..HC7 | Pin 6 -> pin 13 |
| IC46 pins 5 -> 6 | /HC7 | |
| IC57 (7425) pins 1, "4", "3", 2 -> 6 | HWIN | NOR(/COIN IN (A), HC5, HC6, /HC7) -> IC56 pin 5 |
| IC56 (7400) pins 4, 5 -> 6 | | NAND(VWIN, HWIN) |
| IC62 (7432) pins 9, 10 -> 8 | STROBE (active low) | OR(IC56 pin 6, EXPLO.ST (F)) -> IC76 pins 1, 15 and IC83 pins 13, 12 |

HC counts 7 MHz rising edges, which are falling edges of IC63 pin 1. It stops at 0xA0. HWIN covers HC = 0x80..0x9F (HC7=1, HC6=0, HC5=0), 32 pixels.

### PROM address (identical on PR127, PR128, PR129, PR130)

| 7641 pin | Address bit | Net | Source |
|---|---|---|---|
| 8 | A0 | VC0 | IC54 pin 3 |
| 7 | A1 | VC1 | IC54 pin 4 |
| 6 | A2 | VC2 | IC54 pin 5 |
| 5 | A3 | VC3 | IC54 pin 6 |
| 4 | A4 | VC4 | IC54 pin 11 |
| 3 | A5 | HC2 | IC52 pin 5 |
| 2 | A6 | HC3 | IC52 pin 6 |
| 1 | A7 | HC4 | IC52 pin 11 |
| 23 | A8 | Vs/4 on PR127; Vs/8 on PR128, PR129, PR130 | sheet H frame counter |

The IC numbers are PR127 = IC77, PR128 = IC84, PR129 = IC91, PR130 = IC98. They agree with the file names in the PROM set.

Rows of the image come from VC0..VC4. The window starts at VC 0x30, so displayed rows 0..15 read addresses 0x10..0x1F and rows 16..31 read 0x00..0x0F. The independent artwork check below supports this.

### Data, multiplexer and decoder

| Part / pin | Connection |
|---|---|
| PROM data pins 9, 10, 11, 13, 14, 15, 16, 17 (D0..D7) | One bus shared by the four PROMs -> IC76 pins 6, 5, 4, 3, 10, 11, 12, 13 (1C0..1C3, 2C0..2C3) |
| IC76 (74153) pin 14 (A), pin 2 (B) | HC0 (IC52 pin 3), HC1 (IC52 pin 4) |
| IC76 pins 7 (1Y), 9 (2Y) | 1Y = D[HC1:HC0], 2Y = D[4 + HC1:HC0]; both 0 while the strobe is high |
| IC83 (7442) pins 15 (A), 14 (B), 13 (C), 12 (D) | 1Y, 2Y, STROBE, STROBE |
| IC83 output 1 (pin 2) | /PLAYER BODY -> (C) BV; also IC44 pin 11 and IC68 pin 2 |
| IC83 output 2 (pin 3) | "/PLAYER TIAR" (tyre) -> (C) B19 |
| IC83 output 3 (pin 4) | /PLAYER (BL) -> (C) BW |
| IC83 output 0 | not connected; codes 12..15 (strobe high) select no output |
| IC61 (7402) pins 8, 9 -> 10 | NOR(1Y, 2Y) = /PLAYER -> (C) B9 |
| IC44 (7404) pins 11 -> 10 | PLAYER -> (F) |

**Pixel order.** Within each group of four pixels (A5..A7 constant), the pixel at HC[1:0] = k shows bit k (1Y) and bit k+4 (2Y) of the byte:

- D0/D4 are shown first, at the lowest HC, and D3/D7 last.
- There is no shift register and no load/shift edge. The 74153 selects the bit directly from the counter.

### Chip enables (7641: /CE1 pin 20, /CE2 pin 21, CE3 pin 19, CE4 pin 18)

| PROM | Pins 20, 21 (active low) | Pins 18, 19 (active high) | Enabled when |
|---|---|---|---|
| PR127 | ground | IC66 pin 3 = AND(/ACC1 (F), IC119 pin 12 /Q) | /ACC1 high and IC119 idle |
| PR128 | IC72 pin 1 = NOR(IC38 pin 8 QD, IC119 pin 5 Q), routed over the top of the sheet | /EXPLO.ST (F) | (QD or IC119 Q) and /EXPLO.ST high |
| PR129 | IC95 pin 6 = OR(/ACC1, Vs/16) | /EXPLO.ST | /ACC1 low, Vs/16 low, /EXPLO.ST high |
| PR130 | IC95 pin 8 = OR(/ACC1, IC73 pin 10 = /Vs/16) | /EXPLO.ST | /ACC1 low, Vs/16 high, /EXPLO.ST high |

The three (H) inputs at the top left are read top to bottom as Vs/4, Vs/8 and Vs/16. The middle label's 8 was confirmed on sheet H. IC66 pin 3 also drives IC51 pin 11, the third latch, which is not traced here.

### Select-state logic

| Part / pin | Connection |
|---|---|
| IC38 (74393 half) pin 13 | Vs/32 (H), 470 pF to ground |
| IC38 pin 12 | IC62 pin 6 = OR(/EXTEND (A), IC51 pin 7) |
| IC38 pins 10, 9, 8 (QB, QC, QD) | IC80 pins 3, 4, 5. Pin 8 also goes to IC72 pin 3. Pin 11 (QA) is not connected. |
| IC80 (7410) pin 6 | /ACC1.PULSE -> (F) |
| IC72 (7402) pins 3, 2 -> 1 | NOR(QD, IC119 Q) -> PR128 pins 20, 21 and /SP.DOWN (F) |
| IC66 (7408) pins 12, 13 -> 11 | AND(/GRAVEL (D), /SLIDE (D)) -> IC119 pin 9 (A) |
| IC68 pins 1, 2 -> 3 (OR body, inverted inputs = NAND) | NAND(/EXPLO.ST, /PLAYER BODY) -> IC119 pin 10 (B) and IC19 pin 2 (B) |
| IC119 (74123 half) pins 9 A, 10 B, 11 /CLR | IC66 pin 11, IC68 pin 3, IC51 pin 7 |
| IC119 pins 5 Q, 12 /Q | SP.DOWN (F), IC72 pin 2; IC66 pin 2 |
| IC119 timing | C30 "10µ" between pins 6 and 7; R16 "47K" from Vcc to pin 7 |
| IC19 (74123 half) pins 1 A, 2 B, 3 /CLR | /SLIDE (dot at 1598,3622), IC68 pin 3, Vcc |
| IC19 pins 13 Q, 4 /Q | IC51 pin 6 (/S); /SCORE.ST (F) |
| IC19 timing | C33 "10µ", R19 "47K" |
| IC51 (74279) latch pins 5 /R, 6 /S, 7 Q | /HOME POS. (F), IC19 pin 13, /ACC1.ST (F); Q also drives IC62 pin 4 and IC119 pin 11 |

Each 74123 pulse lasts tw = 0.28 · R · C · (1 + 0.7/R) ≈ 0.1336 s, with R = 47 kΩ and C = 10 µF. That is about 7.9 frames.

**Behaviour.** B on both monostables is high while a car body pixel is being drawn, or while EXPLO.ST is high.

- **IC119** fires when gravel or an oil slick meets the car body on the raster. This takes PR127 off the bus and enables PR128, the yawed slide images. It also raises SP.DOWN and holds both until 0.1336 s after the last overlap.
- **IC19** fires on a slick alone. It pulses /SCORE.ST and, for its duration, releases the set input of the /ACC1.ST latch, so that /HOME POS. can clear it.
- **An accident** is /ACC1 low, driven from sheet F. It enables PR129 and PR130 in turn by Vs/16, with A8 = Vs/8, a four-image spin.

## Position and latency

The PROM, the 74153, the 7442 and the gates are asynchronous. The output follows the counters within the same 7 MHz period. The settled positions are:

- **Horizontal.** PL-H-ST holds HC at 0 while it is high. The model assumes that the clear is released just after the 7 MHz edge that ends the pulse, so the same edge does not count. HC is then 0 in the pulse pixel and the next pixel, and HC = n in pixel PLH + 1 + n. The car occupies the 32 pixels **PLH + 129 .. PLH + 160**.
- **Vertical.** PL-V-ST clears VC, and each later end of HS advances it by one. The car occupies the 32 lines **PLV + 48 .. PLV + 79**. If PL-V-ST were released on the same edge that ends HS, the model would let the clear win, giving one line later. The test position does not use that case.

The core's test generator puts PL-H-ST at x = 35 and PL-V-ST at x = 0 on line y = 56. That places the window at **x = 164..195, y = 104..135**. Both the RTL and the pin-level reference produce exactly that window, and the testbench asserts it on every pixel.

The model does not reproduce delays within the pixel: the 74393 ripple, PROM access and decoder delays. At group boundaries (HC2 changing) these can take up a large part of the 140 ns pixel. Whether sheet C re-times these outputs is not known yet.

## Implementation

- `cores/monacogp/hdl/jtmonacogp_player.v` holds the circuit above, in a settled-state model. Host clocks are counted from the `pxl_cen` edge:
  - Counters step one host clock after `pxl_cen`, on edges detected against their inputs at the end of the previous pixel.
  - The PROM data follow one host clock later (block-RAM latency).
  - From the third host clock until the next `pxl_cen`, every net has settled. The monostables compare their A, B and /CLR inputs at each of these clocks with the values at the previous one. Their periods count down once per pixel.
  - So an edge caused by a monostable's own output within a pixel is still seen, one host clock later. Two such loops exist: IC19 Q -> IC51 -> /ACC1.ST -> IC119 /CLR, and IC119 Q -> PROM enables -> body pixel -> IC68 -> B.
  - When a 74123's A and B inputs change at the same pixel boundary, A is applied first, then B, then /CLR.
- `jtmonacogp_ptest.v` is **test stimulus, not original circuitry**. It provides:
  - Fixed PL-H-ST and PL-V-ST positions.
  - A VS-driven frame counter for the Vs/n taps, standing in for sheet H IC79/IC78: Vs/4 = bit 1 ... Vs/32 = bit 4, counting at the end of VS.
  - /COIN IN low.
  - Four states selected with buttons 1 and 2:
    - **Normal.**
    - **Slide:** a /SLIDE patch at x = 166..171, y = 116..121 across the car body.
    - **Accident:** /ACC1 low.
    - **Explosion:** EXPLO.ST high.
- `jtmonacogp_pview.v` shows the outputs in **false colours** with captions. Sheet C, which gives them their real colours, is not traced.
- The OSD option *Display* selects Player car test (the default), PROM bits or Timing grid.

## Checks

| Check | What it compares | Independent of |
|---|---|---|
| `scripts/player_image_checks.py` | Artwork read with the traced mapping vs. alternatives: no empty band through the object, fewer colour changes when read D0 first | RTL, reference |
| `tests/tb_player.v` + `tests/sheet_g_reference.v` | Every settled pixel of 22 internal and output nets and buses (50 signal bits), RTL against a reference wired by IC and pin number from the tables above. The reference uses data-sheet chip functions, ripple counters, three-state PROMs and real-time 74123 timing. | RTL implementation (not the transcription) |
| `tb_player.v` geometry and function-table cases | Window position on every pixel; 74123/74279 cases (A falling with B high, /CLR low, clear held, /CLR rising) | RTL |
| `scripts/player_raster_check.py` | Each dumped pixel vs. the PROM bytes; PROM choice per state; slide start at the first body/slick overlap; slide end 0.1336 s after the last; Vs/4 changes only tyre pixels; accident images turn monotonically in about 45° steps (swapping Vs/8 and Vs/16 would not) | RTL, reference |
| `tests/tb_game.v` | The JTFRAME-level player view: PR127 car pixels at the predicted window, in the documented false colours | |

The reference shares the transcription with the RTL. Agreement can expose implementation errors, but it cannot prove the reading of a wire. The artwork checks are the evidence that bears on the reading itself.

### Results, 16 October 2026

All checks pass with the verified original PROM set.

- **RTL against the reference:** 5,898,816 settled pixels over 49 frames. The sequence is normal, slide, normal, accident, explosion, then the override cases. The monostables switch at 5 edges, each within 2 pixels of the reference, and 4 pixels are masked at those edges.
- **Window:** x = 164..195, y = 104..135 in every frame.
- **74123 and 74279 function-table cases:** all four pass:
  - /SLIDE falling with B high;
  - /HOME POS. clearing /ACC1.ST;
  - IC119 held clear;
  - IC119 triggered by its /CLR rising when IC19 expires.
- **Raster check:** 78,400 dumped pixels match the PROM bytes. Each state selects the expected PROM. The slide image starts at the first body/slick overlap and ends 0.1336 s after the last one.
- **Artwork:**
  - Vs/4 changes 74 PR127 pixels, none of them body pixels.
  - The accident images turn by +44.8°, +50.3°, +38.6° and +46.3° per step.
  - The PR128 images are yawed −11.6° and +12.6°.
- The frame sheet shows the car region of every dumped frame.

## Unresolved

1. **IC51 pin 3** (/S2 of the window latch) is not drawn. It is modelled as an open TTL input, which reads high. Wired low, the window would be held open.
2. **IC57 pin labels.**
   - The gate's label reads like "59", but PR125 is IC59, so it is taken as IC57's other half.
   - Its inputs are written 1, 4, 3, 2. On a 7425, pin 3 is the strobe G.
   - Read literally, HC6 drives the strobe and pin 5 floats high. HWIN would then be /HC6: a 64-pixel window that repeats HC2..HC4 and draws the image twice.
   - The implementation takes "3" to be the D input (pin 5), with the strobe open. One of the "3" or "4" labels is a drafting error either way.
   - IC57b's output pin number is not drawn.
3. **IC45 third input** is written "3". It is taken as pin 13.
4. **IC48 pin numbers** are not drawn.
5. **R16/C30 and R19/C33** read 47K and 10µ. The pulse length follows from the data-sheet formula and the electrolytic capacitors' tolerance, so it is approximate.
6. **PROM output type.** The 7641 outputs are taken as three-state. An undriven bus is modelled as reading high, and two enabled PROMs as a wired AND (low wins). Two PROMs are enabled at once when PR128 is enabled (IC38 QD or IC119 Q high) together with another:
   - QD high with /ACC1 high: PR127 + PR128.
   - QD or IC119 Q high with /ACC1 low: PR128 + PR129 or PR130. (Corrected 30 October: an earlier version of this note listed QD only.) IC119 is not cleared by /ACC1, so an accident within 0.1336 s of the car body meeting /GRAVEL or /SLIDE enables the slide and the spin images together.
   - Neither case is reached by the four test states. The override segment of `tb_player.v` does exercise it.
   - Seen on a MiSTer (30 October, first build with sheets M and C): one frame of a car hitting another beside the road shows the car without most of its black outline. With both PROMs ANDed the outline (code 3) keeps 16 to 73 of the 111 to 161 pixels it has in one image, and body and tyre pixels drop too. The maintainer confirmed the same on a real board (30 October), so the wired-AND model matches the board at least in this case.
7. **7 MHz phase.** It is assumed that sheet F's "7MHz" rises at the same edge that advances the sheet E counters. A half-period offset would move the car by half a pixel relative to H.
8. **PL-H-ST and PL-V-ST** are generated on sheet F, which is not traced: their pulse width, their timing against the clock edges, and the C23/680 pF shaping. Only the fixed test positions are used.
9. **Inputs from untraced sheets:**
   - Sheet A: /COIN IN, /EXTEND.
   - Sheet F: /ACC1, EXPLO.ST, /EXPLO.ST (complementary in the test), /HOME POS.
   - Sheet D: /GRAVEL, /SLIDE.
   - Sheet H: Vs/4..Vs/32. Their counter's chip and clock edge are not traced.
10. **Sheet C** decides the colours and priority of /PLAYER BODY, /PLAYER TIAR, /PLAYER (BL) and /PLAYER, and whether they are re-timed.
11. **Monitor orientation.**
    - The car's nose is at low HC, the start of the line.
    - In a vertically scrolling game, that suggests the raster is turned so that the start of each line is at the top of the screen.
    - The direction of the rotation, and whether the picture is mirrored, need an asymmetric reference. Text in PR133 (sheet B) could provide one.
    - The MRA still declares a horizontal screen.
12. **Not traced in this milestone.** These lie on the same nets but outside the player-car path:
    - IC51 latch 3 (pin 11 = IC66 pin 3).
    - IC74.
    - The headlight path (IC57b, IC46 9->8, PR125/PR126).
    - The second loads of the IC57 outputs.
13. **Comparison with an independent redraw (22 October 2026).** stonedDiscord's
    KiCad redraw of board 96577 (github.com/stonedDiscord/MonacoGP, no licence,
    used only for comparison) agrees with 92 of 118 pin links checked from this
    trace. The other 26 differ only in which package or half carries a function:
    - IC52's two counter halves are swapped: HC0..HC3 on pins 11..8 and
      HC4..HC7 on pins 3..6. The function is the same.
    - The 74393 half read here as IC38 is IC39 there, and the NAND read as IC80
      (pins 3, 4, 5 -> 6, /ACC1.PULSE) is IC45 there.
    - The monostable read here as IC19 is the other half of IC119 there
      (IC19 is a 74393 in the redraw).
    - It ties IC51 pin 3 to pin 2, which behaves the same as the open input
      modelled here (item 1).
    - It uses a 74LS20 (NAND) for IC57, where this sheet draws a NOR (7425).
      The 32-pixel window in this trace depends on the NOR. KiCad's standard
      library has no 7425, which may explain the substitution.
    None of these changes the implemented behaviour. The designators could be
    settled from a photo of a real board.
