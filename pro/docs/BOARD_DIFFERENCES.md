# Original Monaco GP vs Pro Monaco GP: board differences

Date: 4 November 2026. **Structural schematic comparison, not a complete pin-by-pin netlist diff.** This document distinguishes directly visible changes from behavioural claims that still require tracing. No HDL was changed and no electrical equivalence tests were run.

**Refreshed 6 November 2026 (issue #74).** Entries that later pin-level traces corrected or settled are marked "corrected on 2026-11-06 by <trace>"; 4 November text that they contradict is kept, struck through, so the change can be seen. Everything not so marked is still the 4 November comparison. Traces still open for review are cited as "per PR #n, under review": their findings may change. Paths are relative to `pro/docs/` unless they start with `docs/`.

## Evidence and scope

Original source: Sega 420-0358, supplied original sheet PNGs and their existing traces. Pro source: Sega 420-0525, supplied 20-page PDF. Page numbers below are PDF page numbers, not the circled sheet numbers. Pro schematics generally carry the issue date 1980-07-16.

The fan remake and MAME were not used to establish circuit changes. Photographs/user descriptions identify intended behaviour but do not establish a net connection, threshold or ROM content.

## Board and sheet cross-reference

| Function / sheet | Original manual | Pro manual | Finding |
|---|---|---|---|
| Main board A | 96577-P, four sheets | 96822-P, five sheets | Additional sheet N for bonus logic; connections added to existing sheets |
| Start/timer A | p25 | p8 | Bonus sound input and additional links to N |
| Player/control F | p26 | p9 | BONUS POINT from N enters scoring/control area; ACC1 and other signals also feed N |
| Player graphics G | p27 | p10 | Familiar graphics/PROM structure retained at overview level; individual equality not established |
| Other cars H | p28 | p11 | Existing PR132, PR38, PR39 appear; PR38 output connections extend to N |
| Bonus N | No corresponding fifth A-board sheet | p12 | New counter/control subsystem |
| Main board B | 96578-P | 96823-P | Five sheets retained; extra bonus graphics on M and colour input on C |
| Text/road B | p29 | p13 | Same four-message text architecture visible; IC positions differ |
| Colour C | p30 | p14 | +200 input added to red combining path |
| Scenery D | p31 | p15 | Broad structure retained; not a component-value or pin-equivalence certification |
| Timing E | p32 | p16 | Broad counter/sync architecture retained; no new clock frequency is established by this audit |
| Rescue/sign/bridge M | p33 | p17 | PR54/IC130 and IC129 pixel selection plus bonus enable gating added |
| Score memory/ranking I | 96597-P, p23 | 96824-P, p18 | RAM architecture/power and bonus interfaces change |
| Score LEDs J | p22 | p19 | Core four-digit rows retained in drawing; connector identities/layout differ |
| Rank latches K | p24 | p20 | Five-rank latch structure retained, additional SUPER RACER SCORE circuitry |
| Cabinet wiring | Original cabinet drawings | p7 | Battery, meters, revised board/cabinet connections |

**Do not confuse D-4 as a drawing number with the separate sound-board D-4 mixer sheet.** Main-board sheet H is also marked D-4/5 in this manual.

## Confirmed substantial differences

### 1. Added bonus subsystem: sheet N, 96822-P D-5/5 (Pro p12)

This is the largest discrete addition outside the score board. The drawing includes a 74161 (IC132), 74191 (IC100), 74157 (IC133), 74390 counter sections (IC80), flip-flops, 74123 monostables and gating.

Visible inputs include PLAYER ST from G, OTHER CAR and PR38 outputs from H, ACC1 from F, GAME and reset/coin signals from A, and raster/divider signals. Outputs include:

| Output | Destination | Consequence for implementation |
|---|---|---|
| BONUS SOUND | A | Additional trigger mixed into existing sound control |
| /BONUS POINT | F | Bonus affects the existing score-pulse path; cannot model solely as decorative text |
| GAME END | I, pad M5 | Score-board sequencing has an extra game-end interface. *Corrected on 2026-11-06 by `trace/SHEET_I_TRACE.md`:* /GAME END (I pad HP) takes the place of the original GAME input of sheet I's after-game sequencer, so the score is written and ranked only after the bonus payout; it also triggers the 74123 (65) that sends T.R.S to K |
| BONUS A..D | I, pads M1..M4 | Four-bit bonus state goes to the cabinet score/indicator board. *Corrected on 2026-11-06 by `trace/SHEET_N_TRACE.md` and `trace/SHEET_I_TRACE.md`:* IC133 (74157, select V2) sends IC132's car count while V2 is low and IC140's stored bonuses while V2 is high; on I they address the lamp PROMs (section 5) |
| BONUS CP and complement | M and A | Couples graphic display timing and control |

The drawing also has an instruction by M8 to cut or remove pin 8; the precise harness applicability needs review before reproducing physical wiring.

~~**Not yet established:** counter thresholds, whether every passed car qualifies, collision/reset rules, bonus accumulation limit, and the exact arithmetic at game over. User-described multiplication must not be substituted for tracing the 74191/74157 and score-pulse network.~~

**Corrected on 2026-11-06 by `trace/SHEET_N_TRACE.md`, `SHEET_N_LOGIC.md`, `trace/BONUS_INPUTS_TRACE.md` and `trace/SHEET_F_BONUS_TRACE.md`** (a reading of the drawn logic, not a measurement):

- **Threshold.** IC132 (74161) counts overlap episodes: each time an other-car pixel (/OTHER CAR) crosses the player's PLAYER ST span, IC100's first half (about 44 ms) runs and IC132 counts at its end. The 16th episode (IC132 RCO) fires IC107's second half and adds one bonus to IC140. On the bridge (IC100's second half running), one overlap gives a bonus directly, without the 16-count.
- **Clears and inhibits.** IC132 is cleared outside GAME, by coin/test or initial reset, by /ACC1 (accident), and by an overlap while PR-38 D6 AND D7 = 1. /SCORE ST low (slick or explosion) holds IC100's overlap half and IC107 clear: no count and no bonus.
- **Bridge rule.** The bridge one-shot's /CLR is NAND(PR-38-7, PR-38-9): it is held clear while D6 AND D7 = 1 and can run only while D6 AND D7 = 0 (per PR #75, under review, which corrects the merged `BONUS_INPUTS_TRACE.md` prose that had it the other way round; the gates and `cores/monacogp/hdl/jtmonacogp_bonus.v` already agree with PR #75). PR #75 calls D6 AND D7 = 1 the *slow-player bits*, after Monaco GP's PR-38 dump, where they are set only at low player speed (`OBSERVATIONS.md`). Pro's own PR-38 contents were not read.
- **Accumulation limit.** IC140 (74191) counts up during the game and holds at 15 (MAX/MIN blocks further clocks).
- **Arithmetic at game over.** /GAME rising opens the payout: IC94 gates V5 into /BONUS POINT, and IC81 (÷2) and IC80 (÷10, ÷10) step IC140 down once every 200 pulses. Each pulse is one point on sheet I's ones decade (F), so the payout is **stored bonuses × 200 points**, delivered as individual score clocks, not a multiplier. The cabinet's instruction card agrees: 16 successive cars overtaken, or one car overtaken on the bridge, is one bonus of 200 points, paid at the end of the game (`OBSERVATIONS.md`).
- **Still open:** the order at game over with exactly 0 or 15 stored bonuses (U5: a 15-bonus payout may be skipped, `SHEET_N_LOGIC.md` `DU_LAG`); IC132's undrawn /LOAD (pin 9, taken high); the count-versus-clear race at the end of an episode with D6 AND D7 = 1; the 74123 family (pulse widths); the IR/IP/GPR package labels; the M8 cut note's destination.

### 2. Existing start and scoring paths are modified (Pro A p8, F p9)

Sheet A receives BONUS SOUND from N in the area of the EX.CP sound output. It also exports coin/reset/game timing signals to N. The original start/timer architecture is recognisable, but these are additional connections, not a replacement sound synthesizer.

Sheet F explicitly receives /BONUS POINT from N near its score-control network. Its normal speed/accelerator and score-pulse circuits remain present. This is evidence for integrating bonus awards through the original score circuitry. ~~The exact pulse timing and added gate truth table still need pin-level transcription.~~

**Corrected on 2026-11-06 by `trace/SHEET_A_BONUS_TRACE.md` (with `docs/SHEET_A_LOGIC.md`, Pro board section) and `trace/SHEET_F_BONUS_TRACE.md` (with `docs/SHEET_F_LOGIC.md`, Pro board section):**

- **A, EX. CP (pad A29).** An added OR (IC59) combines the original extended-play term with BONUS SOUND: `EX. CP = (V2 AND Vs/16 AND Q) OR BONUS SOUND`. The bonus uses the sound board's existing extended-play input.
- **A, /COIN IN to the sound board (pad A28).** New: a NAND (IC35) of /COIN IN and /BONUS CP, then an inverting buffer: `A28 = /COIN IN AND /BONUS CP`. On the original, A28 is /COIN IN through a 7407. The game logic on A still takes the plain /COIN IN. What the sound board does while A28 is low after a game comes from the original sound board's trace; the Pro manual has no sound sheets.
- **F, /SCORE CP (pad A14).** The normal score NAND goes into an added AND (Pro IC8, OR body with bubbled inputs and output) with /BONUS POINT, then buffer B17 to A14: `/SCORE CP = /BONUS POINT AND NOT(/SCORE ST AND Y)`. Each /BONUS POINT low pulse is one falling edge, one point; there is no queue. During the payout IC32 is held clear by /GAME, so normal pulses cannot merge with bonus pulses. The score divider's clear is /GAME on both boards.
- **Other F differences seen on that path:** C54 470 pF on the V6/V7 selector control (none drawn on the original) and the pool one-shot's C32 22 uF (original 15 uF).
- **Still open:** IC53's third input numeral and the A28 buffer's package caption (A); the combining gate's upper pin numeral, the normal NAND's package and B17's label, and short faded stretches of the /BONUS POINT route (F, U1/U2). None changes the logic. The rest of Pro A and F was not compared.

### 3. Extra +200 graphics PROM and red-video connection (Pro M p17, C p14)

PR54 at IC130 is marked 6331; eight outputs feed a 74151 at IC129. Its output is labelled +200 and enters sheet C alongside EX & GAME OVER in the red combining network. Colour is selected by circuitry, not extra colour bits in PR54.

This is a separate graphic path, not a new general-purpose character font. See ../reconstruction/PR54_MAPPING.md for data wiring and open questions. ~~The proposed enable polarity inconsistency remains an unresolved reading; it is not evidence of a defective original design.~~ The user-created bitmap is reconstruction material, not an original dump.

**Corrected on 2026-11-06 by `trace/SHEET_M_C_PLUS200_TRACE.md`:**

- **Enable polarity resolved.** IC124 pin 11 is NOT V-④, through inverter IC79 (13 -> 12), which the earlier reading missed. IC129's strobe is `/G = NAND(BONUS CP, NOR(H4..H7), NOT V-④)`, so the window opens as expected.
- **Address order.** PR-54 A0..A4 = V0..V4 in straight order (A1/A2 probable), correcting the bit-reversed order in `PR54_MAPPING.md`.
- **Window.** Fixed: 16 H clocks (H4..H7 = 0) by 32 lines (V7..V5 = 100), using the original board's counter ranges; shown only while BONUS CP is high; no car or score position enters it.
- **Colour.** /+200 is one input of the 8-input red NAND IC74 beside EX & GAME OVER: pure red at full brightness, overriding what is underneath.
- **Still open:** which of R1/R2 carries V1 and V2; IC128's type; a few numerals; whether the 6331's open-collector outputs have pull-ups. Pro sheet E's counter ranges and Pro sheet B's GAME OVER alignment were not checked. Cabinet footage (`OBSERVATIONS.md`) agrees on the colour and the position below GAME OVER, but its apparent width is still to be compared with the finished core.

### 4. Score memory changes from 2111/8216 arrangement to 5101 RAM (original I p23; Pro I p18)

The original drawing groups 2111 RAM with 8216 bus drivers. The Pro drawing instead shows four separately drawn 5101 devices (~~IC59, IC66, IC65, IC74~~ IC97, IC96, IC95, IC74; corrected on 2026-11-06 by `trace/SHEET_I_TRACE.md`, below), with revised surrounding wiring. The comparator/counter-based ranking architecture remains recognisable.

The Pro cabinet parts list (p5) includes a Ni-Cd battery, and wiring sheet p7 shows a 2.4 V battery connection at the score board. ~~Sheet I also shows a separate memory-supply connection marked 3.6 V and a diode/capacitor network. Those are distinct labels in the drawings; do not equate the battery rating and that rail without tracing the power circuit.~~ (Corrected on 2026-11-06 by `trace/SHEET_I_TRACE.md`: 3.6 V is the battery's own caption on sheet I, not a rail; see below.)

**Confirmed change:** provision for retained score-board memory. ~~**Still open:** exactly which locations survive power-off, write protection during power failure, erase/reset-switch behaviour, and whether all ranking data or only selected records are retained.~~ MiSTer persistence should follow those findings rather than saving arbitrary game state.

**Corrected on 2026-11-06 by `trace/SHEET_I_TRACE.md`** (and, for the RAM type and select pins, per PR #76, under review):

- **Designators.** The four RAMs are **IC97, IC96, IC95, IC74** (units, tens, hundreds, thousands), not IC59, IC66, IC65, IC74; on this sheet 65 is a 74123 and 66 an AND gate. 97 and 95 are probable (malformed first numeral).
- **Type.** All four bodies read `5101` (per PR #76, under review: rechecked at high zoom, no body reads `2101`; two bodies clear, two probable). The 5101 and 2101A share one pinout, so the pins cannot tell them apart.
- **Selects.** Pin 17 (no bubble) is on a power-good node (R43 4.7k, C4 22 uF, D10 to Vcc) and pin 19 (bubble) is grounded with pin 8. Per PR #76, under review, the 5101 datasheet has 17 = CE2 and 19 = /CE1, so the drawing is consistent; the merged trace's "17/19 conflict" (its U2) came from a swapped pinout.
- **3.6 V.** `Ni-CA 3.6V NR-AA` is the battery's caption on sheet I, not a rail name. The RAM rail is unlabelled: Vcc through D9, and the Ni-Cd battery through R62 56 ohm (pads HX +, H20 -). The cabinet wiring (p7) captions the same battery 2.4 V. Which is right is still open (U3).
- **What survives power-off.** All four 5101s, that is, all 256 four-digit score slots. Nothing else on I is on the battery rail: the address counter, the score counter and K's latches are not retained.
- **Protection.** CE2 follows the power-good node and falls with Vcc; R/W is held high by R64 1k to the battery rail; the write decoder (7442, 82) is blocked until eight periods of the signal at pad HU after /INI. RESET ends (the trace reads HU as V2; per PR #77, under review, it is V2').
- **Erase.** Power-up no longer writes 0000 into every slot as the original did. A new RAM RESET switch (SW.1) does that instead, and also asserts LATCH CL. How long it must be held to clear all 256 slots was not worked out.
- **Write and search.** Started by /GAME END instead of the original GAME input. A game that passed 9999 is neither written nor searched (the 10,000-point flip-flop 56 holds the sequencer reset; section 6).
- **Still open:** the battery voltage and R62 wattage (U3); whether the D bus to K is taken from the 192 rows rather than the RAM outputs (U7, probable); the search, compare and rank logic, which was compared with the original only at block level.

### 5. Bonus indicator drive added on score board I (Pro p18)

~~At the top of sheet I, BONUS A..D enter a pair of devices marked 138 (IC35/34), resistor networks and transistor lamp drivers.~~ This is a decoded lamp/LED indicator drive, not another sprite ROM. It is the electrical destination of N's four-bit bonus bus. Exact indicator sequence and board artwork labels remain to be matched to each output.

**Corrected on 2026-11-06 by `trace/SHEET_I_TRACE.md`** (drive, polarity and V2 per PR #77, under review):

- **PROMs, not 138 decoders.** The two parts are **PR-01 (IC55) and PR-02 (IC54)**, printed `3188`, with the pinout of a 32 x 8 open-collector PROM (74S188 / 82S23 family), not a 74138. Designators 55 and 54 are probable. These are two more PROMs that the original board does not have.
- **Address.** BONUS A..D -> A0..A3, V2 (pad HH) -> A4. Since IC133 on N switches BONUS A..D with V2, the panel is time-multiplexed: car count with A4 = 0, stored bonuses with A4 = 1. Per PR #77, under review, HH's V2 and N's V2 are the same signal in the same polarity (E's V2, through a non-inverting buffer to I and unchanged through A to N; pad pairings by label).
- **Drive.** Fifteen outputs sink lamp-element lines through 220 ohm to connector G and an off-board lamp unit `(TM8132-9G)`. The sixteenth, PR-02 pin 9 (O8), picks one of two PNP commons, TR16 (G26) or TR13 (Gd, through inverter 37). Per PR #77, under review: an output at 0 lights its element, a 1 leaves it dark (a blank PROM would light everything); O8 = 0 selects G26 (TR16), O8 = 1 selects Gd (TR13).
- **Pad HU.** Per PR #77, under review, pad HU (the clock of I's power-up counter 92a, which `SHEET_I_TRACE.md` reads as V2 with a raised mark) is `V2'`, a different signal from sheet E's gate 96, not V2. It does not reach the lamp PROMs.
- **Panel labels.** Per PR #77, under review (cabinet footage, `OBSERVATIONS.md` on that branch): the top section reads "NUMBER OF CARS SUCCESSIVELY OVERTAKEN", the one below it "BONUS POINTS (x200 PT.)".
- **Still open:** which lamp lights for which value is set by the PROM contents, which the schematic does not give. No dumps are known; PR #77's `reconstruction/LAMP_PROMS.md` proposes a bar graph as a reconstruction, not as data. Also open: which common feeds which panel section, which of pads HK, HQ, HJ, H8 is BONUS A..D, the LAMP V and LAMP RET sources, and inverter 37's type.

### 6. Separate SUPER RACER SCORE display (Pro K p20)

The five columns of score/rank latches are still present. Pro adds a lower circuit with a comparator chain, 74174 latches, ~~74163 counters~~ 74153 multiplexers (corrected on 2026-11-06 by `trace/SHEET_K_TRACE.md`), decoder/driver circuitry and a display explicitly labelled SUPER RACER SCORE. A TODAY'S HIGH SCORE lamp output is also drawn.

**Correction to earlier shorthand:** the manual does not simply show every score row widened to five digits. On Pro J (p19), the five rank rows and YOUR SCORE are still drawn as four-digit groups. K has a separate extra display. ~~How these displays jointly represent a score above 9999 needs tracing before implementing a flat fifth digit in every row.~~ The user reports five-digit scoring; the documented circuit organisation is more specific than that description.

**Corrected on 2026-11-06 by `trace/SHEET_K_TRACE.md`** (with `trace/SHEET_I_TRACE.md` for the 10,000-point flip-flop):

- **No fifth digit.** Nothing on K stores or displays a ten-thousands digit. SUPER RACER SCORE is a four-digit display; the 10,000 is carried by a flag bit (FLAG) that enables the display and lights the lamp captioned `TODAY'S HIGH SCORE 10000PT.`. On I, the live score's 10,000 is likewise a flip-flop (56, set when the thousands decade carries out, cleared by RST) and the `YOUR SCORE 10000POINT LAMP`.
- **What it holds.** The best score over 10,000 since the last clear. At /GAME END (after the payout), only if 56 is set, T.R.S from I clocks three 74174s (43, 49, 57) that latch the score's four low digits and FLAG, provided four cascaded 7485s find them at least the stored ones (K-U1: "at least" or "greater than" is uncertain; only equal scores are affected).
- **Volatile.** The latches are cleared by /LATCH CL (power-up and RAM RESET) and are not on the battery rail: lost at power-off, as "TODAY'S" says. Such a game is not written to the 5101s.
- **Parts.** The two parts read as 74163 counters are **74153 multiplexers** (printed `153`); nothing on K counts. The decoder/driver is a 9374 segment decoder with a 7442 digit decoder and four PNP digit drivers.
- **Rank latches.** The fifteen 74174s are as on the original, except that every /MR is tied to Vcc: the Pro rank latches are never cleared.
- **Still open:** a game passing 19,999 would carry a second time with 56 already set (K-U11); the display's digit labels (K-U4); the 9374's pin 3 (K-U2); the *a/*b select polarity on J (K-U9). The cabinet panel's "BEST SCORE OVER 10000" (`OBSERVATIONS.md`) agrees.

### 7. Cabinet instruments and harness (Pro pp4,7)

The front-panel list names both a Driving Meter (S-96636) and a Tacho Meter (S-96635). Cabinet wiring p7 includes their connections alongside the revised board harness. This is not just a single new on-screen speed readout. Existing internal speed/accelerator signals are plausible sources, but transfer functions, output pins and meter scaling are not yet traced.

### 8. Sound-board identity retained, new control supplied externally

The Pro parts list and cabinet wiring identify the oscillator assembly as 96598-P, the same assembly designation used for original Monaco sound. N generates BONUS SOUND and sends it via A. Thus a new audible event does not by itself establish new oscillator circuitry or a new sound PROM. *Corrected on 2026-11-06 by `trace/SHEET_A_BONUS_TRACE.md`:* on A, BONUS SOUND is ORed into the existing EX. CP (extended-play) output, and /BONUS CP is combined with /COIN IN on the sound board's A28 input (section 2). No new sound-board input is used.

The supplied Pro PDF does not contain the oscillator board's detailed D-1..D-7 sound sheets. It therefore cannot prove every resistor value is identical. R414=22k and R361=150k remain provisional readings from the original source; no confirmation from this revision has been found.

## PROM and reuse limits

PR54 is a confirmed additional device. *Corrected on 2026-11-06 by `trace/SHEET_I_TRACE.md`:* so are the bonus lamp PROMs PR-01 (IC55) and PR-02 (IC54) on sheet I (section 5), for which no dumps are known. Familiar PROM identifiers remain visible on G/H/M, but this is not proof that every Pro ROM is bit-identical to the available original dumps. PR133's four-message organisation is visible on B, but its identification in the scan is faint. No new message set or general font has been established.

Board numbering and IC locations change. Reuse must be by function and nets, not matching IC numbers. In particular, the original 97091/97092 alternate-ROM-board discussion is not evidence about these 96822/96823 Pro boards.

## Unresolved audit work, in priority order

*Status corrected on 2026-11-06 by the traces named in each item; items 6 and 7 are unchanged.*

1. Fully transcribe N, including the bonus count thresholds, reset conditions and end-of-game sequence. *Done: `trace/SHEET_N_TRACE.md`, `trace/BONUS_INPUTS_TRACE.md` (section 1). Open: U5, IC132 /LOAD, Pro's PR-38 contents, the bridge wording (PR #75, under review).*
2. Trace /BONUS POINT through F to SCORE CP; determine actual arithmetic rather than assuming multiplication. *Done: `trace/SHEET_F_BONUS_TRACE.md`, stored bonuses × 200 points (section 2).*
3. Complete I/K memory, SUPER RACER SCORE and power-fail/reset behaviour. *Done at the level of the issues traced: `trace/SHEET_I_TRACE.md`, `trace/SHEET_K_TRACE.md` (sections 4 and 6). Open: battery voltage, the search/rank logic at pin level, sheet J, the lamp PROM contents.*
4. Resolve PR54 display-enable wiring, and then map the reconstructed graphic without guessing placement. *Done: `trace/SHEET_M_C_PLUS200_TRACE.md` (section 3). Open: R1/R2, Pro sheet E ranges.*
5. Trace BONUS SOUND through A and compare its electrical trigger with the original sound interface. *Done on A: `trace/SHEET_A_BONUS_TRACE.md` (sections 2 and 8). The sound board's response rests on the original sound board's trace.*
6. Trace both physical meter drives.
7. Complete remaining pin/value comparisons of A/F/G/H/B/D/E/M. Their recognisable overall structure is not an assertion of identical behaviour.

## Practical implementation assessment

The likely reusable base is the original driving/video/sound circuitry. The largest work is the new N state machine and revised score/retention/display system, with smaller but mandatory integration edits in A, F, C and M. This is a bounded extension, but not just a font/ROM swap or a one-line score multiplier. No timing/resource prediction is justified until those changes are implemented and compiled.

## Source hashes

- Pro PDF SHA-256: `9473d6dd84418129f389e7c5becc0f6f7d105611e1d508ff60bbc062a27432f2`
- Original PDF SHA-256: `9dee6f2f023ee00427d3bf1689ae341a72c955f8efb9d71441bdc57684bce846`
