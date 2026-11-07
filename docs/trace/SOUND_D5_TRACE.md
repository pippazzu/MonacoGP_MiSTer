# Sound sheet D-5/7 — fanfare, hi-score oscillators and 6 V bias

Source: Sega Monaco GP manual **420-0358**, PDF page **19**, board
**96598-P**, `schematics/pages/page19-sound-D5.png` (upright,
10160 × 6624 pixels, 600 dpi). Drawing stamp: AUG 30 1979.
PNG SHA-256: `93493de60d22176f7e527f03888ffedc8495960aca59bca94dd6ef4d94106f92`.

**Status: consolidated pin-level trace, 1 November 2026, checked against the
scan by Claude the same day.** That check made three corrections (the two
outputs to D-4 were swapped, the PROM bit order of the note labels A/B/C was
reversed, and the H buffer is IC48), already applied in the tables below and
explained in "Review against the scan, 1 November" at the end.
This file incorporates the recovered October review and the user's recorded
visual confirmations. Targeted source checks made during consolidation are
identified below. It replaces the earlier partial narrative and conflicting
tables; it is not a byte-identical restoration of the lost working file.
Remaining source ambiguities are listed explicitly under Unresolved.

Coordinates refer to the upright source PNG. A crossing without a dot is
unjoined. Signal names introduced for local nodes are descriptive, not new
off-sheet labels. `ICn.p` means package n, pin p. Values are transcribed;
no frequency measurement or waveform simulation is claimed.

## Sequencer clock, reset and address map

| Item | Reviewed pin route | Confidence |
|---|---|---|
| IC27.12 | R114 1K from output 11; C106 47µ tantalum and R113 22K to GND | clear |
| IC27.13 | Common with IC26 /CLR1 and IC38.11 | clear |
| IC27.11 | Both IC27.9/.10; output 8 → R427 220Ω → IC27.2; C116 .001µ ceramic from pin 2 to GND | clear |
| IC27.1 | Vcc; output 3 → both pins 4/5; output 6 → IC26 clock 2 and IC46.1 | clear |
| IC46.2 | IC37.13 first latch | clear |
| IC38.12/.13 | IC21 address 10(A0) / address 14(A4) respectively | clear |
| IC38.11 NAND | IC46.13, IC27.13, IC26 /CLR1 | clear |
| IC46.12 | IC35.9 and IC46.11 | clear |
| IC46.10 | R267/C46 pulse-shaper source and parallel inverter input | clear upstream route; physical pins of the local inverter/NAND remain uncertain |
| IC35.8 | IC26 carry 15, also IC35.12 | clear |
| IC35.10 | IC22 clock 13 | clear |
| IC37.8 | IC22 resets 2/12 and IC35.11 | clear |
| IC35.13 NOR(.11,.12) | IC26 /LOAD9 and 74123 A 1 | clear |
| IC26 load 3/4/5/6 | PROM IC21 outputs 1/2/3/4 respectively; Q outputs not drawn | clear |
| IC26 enables 7/10 | Vcc | clear |

IC27 Schmitt-NAND symbols and tally 132 are consistent with 74132; do not
claim a part number printed inside the symbol. IC35 NORs match 7402 pinout.
IC37/38 symbols give NAND; exact suffixes unprinted. Address bit sources
were corrected: IC38 reads two counter-driven address bits; it does not
drive the PROM address bus.

| IC22 output pin | IC21 PROM address pin | Other destination | Confidence |
|---|---|---|---|
| 11 | 10(A0) | IC38.12 | clear |
| 10 | 11(A1) | — | clear |
| 9 | 12(A2) | — | clear |
| 8 | 13(A3) | Other half clock 1 | clear |
| 3 | 14(A4) | IC38.13 | clear |

Clock 13 drives the first listed half; output 8 clocks the other half at 1.
Printed 1A/2A half labels are reversed relative to 74393 physical pin mapping;
use physical pins. Outputs 4/5/6 are not drawn, no tie-offs invented.

First latch: IC37.11 → .10, .8 → .12; HI SCORE → .9; IC46.2 → .13.
Second latch: IC37.3 → .4, .6 → .2; HI SCORE → .5; IC38 pulse output (3/8 annotations unresolved) → .1.
The sequencer is coupled to HI SCORE through the first latch. No separate
external FANFARE-trigger net found or invented.

## Note banks and fanfare output

All six buffers bear designator 13, with slash/OC output marks and no
inversion bubbles. A/B/C are wire labels on the three PROM note bits:
**C = PROM 5 (E), B = PROM 6 (F), A = PROM 7 (G)** (corrected 1 November;
the earlier 5=A order was reversed).

| PROM output | Upper bank | Lower bank | Confidence |
|---|---|---|---|
| 7 (G) = A | IC13.11 → .10 → VR4 1K → upper common | IC13.1 → .2 → VR1 1K → lower common | clear |
| 6 (F) = B | IC13.5 → .6 → VR5 1K → R41 220Ω → upper common | IC13.13 → .12 → VR2 2K → R2 220Ω → lower common | clear |
| 5 (E) = C | IC13.9 → .8 → VR6 2K → R45 680Ω → upper common | IC13.3 → .4 → VR3 2K → R21 680Ω → lower common | clear |

Upper common: R23 ADJ 1K to 12V, R4 39K → IC1.9. Lower common: R1 ADJ 1K
to 12V, R3 39K → IC1.13. Printed do/mi/so=C/B/A,262/330/392Hz are
nominal targets, not measured frequencies.
DIP SW 1 (4P), three note-ground poles 14–3, 15–2, 16–1. Fourth normally-closed pole4–13:
IC21 /CE15 + R112 1K pull-up → contact 4; contact 13 GND.
PROM 9 H → IC48.1 → .2 (numeral reads 48; the remaining section of the D-3
hex buffer IC48) → R55 68K → IC6.3/C14.

74123 B 2 Vcc, /CLR3 from IC38.11/reset run, A 1 from IC35.13. Q 13 → D4 →
R49 1K → C14 6.8µ/R52 470K to GND/IC6.3. Package designator is not printed in the inspected block.
IC6.2 loops 1; output 1 → R48 33K → IC6.6; R57 15K feedback 7 → 6.
IC6.5 at R50 2.7K/R47 5.1K (5V/GND) midpoint, with C9 47µ.
IC6.7 → east to x≈4245, south to y≈5290, east along the lower horizontal →
**IC7 CON 2** (the envelope that shapes the hi-score sound; corrected
1 November, it does not go to the fanfare arrow).

## Oscillators and reference endpoints

- IC1.9 receives R4 39K from upper note common; R9 10K feedback 8 → 9.
 IC1.10 and .12 share R20 33K to 12V / R10 corrected 1K to GND midpoint.
 Reference vertical crosses IC1.14 and 6V without dots.
- Slow IC1 first section: R14 100K → −2; C3 .47µ5% nonpolar feedback 2↔1.
 R15/R16 each 51K form +3 input divider. Feed to R14/R15 comes from
 R13 15K to 12V / R12 47K to GND midpoint.
- IC1.1 → IC1.6; +5 has R17 100K to 6V and R19 180K feedback from 7 (corrected 5 November 2026 from 100K: the scan's second digit is solid beside R17's open zero, and Monza GP's redraw of this sheet shows a clear 180K).
 IC1.7 → R18 10K → D1 (MA15x, final digit uncertain) → TR1 base; R11 2.2K base → GND, emitter GND;
 collector → R5 51K → IC1.2.
- IC1.1 also feeds C2 4.7µ/R8 1M → IC1.9 and C1 4.7µ/R7 1M → IC1.13.
 C1 is distinct from fanfare C14. The 6V rail crosses R7-to 13 without dot.
- IC1.13 receives lower note common via R3 39K; R6 10K feedback 14 → 13;
 +12 at the shared reference above.
- IC1.8 → R26 51K → TL081 IC2.2; C4 .022µ5% feedback 6 → 2.
 IC1.8 → R27 51K → IC2.3; R29 to GND has an overwritten value. User D5-V01
 confirms that it begins with 5 and suggests 51K; the full value remains uncertain.
- IC2.6 → TL081 IC4.2. IC4.3 has R25 100K feedback from 6 and R32 47K
 to 6V. **R32 crosses the R24/D2 drive wire without a dot**; the first
 pass's assignment to the R24/D2 node was wrong.
- IC4.6 → R24 10K → D2 → TR2 base; R30 2.2K base → GND, emitter GND;
 collector → R22 560Ω → IC2.2. R22 is not a base resistor.
 D2 MA156-like type glyph remains uncertain.
- IC1.14 → R35 51K → TL081 IC3.2, and R36 51K → IC3.3; R37 51K
 +3 → GND; C5 .022µ5% feedback 6 → 2.
- IC3.6 → IC5.2 comparator; IC5.3 has R40 47K to 6V and R34 100K
 feedback from 6. IC5.6 → R33 10K → D3 MA150 → TR3 base; R38 2.2K base → GND,
 emitter GND, collector → R28 560Ω → IC3.2.

## Hi-score mixer, filtering and mute

| Stage | Reviewed route | Confidence |
|---|---|---|
| Summing source1 | IC2.6 → R31 100K → IC15.9 | clear |
| Summing source2 | IC3.6 → R39 220K → same IC15.9 | clear |
| IC15 section | R115 100K feedback 8 → 9; +10 at 6V; this is IC15 shared with D7, not IC6 | clear |
| IC15.8 | R43 4.7K → node: C13 .033µ to IC6.8, R46 4.7K to IC6.10 | clear |
| IC6 first filter | C12 6800P pin 10 → GND; −9 loops 8 | clear |
| IC6.8 to second filter | C11 6800P → node; node → C10 6800P → IC6.12 and R44 12K → IC6.14 | clear |
| IC6 second follower | −13 loops 14; +12 as above; R42 22K +12 → 6V | clear; user-confirmed pin mapping retained |
| Audio output | IC6.14 → C8 1µ → IC7 IN 1; IC7 OUT 7 → C15 2.2µ → HI SCORE SOUND OUT(D4); pin 6 → C100 680P → GND | clear |
| MUTE | Pad with R223 2.2K to Vcc → IC35.6 | clear |
| IC35 mute gate | Input 5 ← IC37.3, input 6 ← MUTE; input-bubbled AND=NOR; output 4 → east to x≈3955, south to y≈5910 → **ファンファーレ (D-4/7) arrow** | clear; corrected 1 November (was given as IC7 CON 2) |

## Recorded source crops

Clock/address/reset: (1100,300,2800,1800), (2250,500,3100,1500),
(1650,1500,2700,2800), (1650,2600,2800,3650), (2350,1750,3350,2700),
(2400,2350,2950,3400). Note/fanfare: (3100,650,4400,1550),
(4300,300,6000,1800), (4450,3800,5800,4950), (3200,2500,4700,4200).
Analog/reference/filter: (5650,1400,7950,3300), (5750,1550,6450,3300),
(5700,2750,8100,4250), (7650,2100,8600,4900), (5500,4100,7900,5800),
(5500,3500,8200,4750), (1300,4300,6800,5600).

## User-provided tuning context

The user supplied an account of factory-adjusted hi-score notes, played
immediately after a top-five game result, and tones becoming detuned if
adjustments are moved. This is contextual testimony, not independent proof
of playback/tuning rules. The count “7 of 'em I believe” is tentative.
The drawing identifies VR1–VR6 in two banks of three, plus R1/R23 marked
ADJ. ADJ alone does not establish an additional potentiometer. Physical
count, any seventh control, factory settings and tuning procedure remain
unresolved. No VR7 or missing connection invented from the account.

## Fresh source checks — bias, power and one-shot timing

These checks were made from the original PNG on 1 November, not inferred
from the recovered text. R53/C6 are the upper divider branch; R54/C7 are
the lower branch. The page does not contain a second cascaded RC node here.

| Part / net | Value and endpoints | Confidence |
|---|---|---|
| R53 | 1K, 12 V → 6 V midpoint | clear |
| C6 | 100µ electrolytic, 12 V → same midpoint | clear; user-confirmed endpoints retained |
| R54 | 1K, midpoint → GND | clear; former D5-U1 closed |
| C7 | 100µ electrolytic, midpoint → GND | clear |
| 12 V pads | 17, 18, U, V tied together | clear |
| 5 V / Vcc pads | 1, 2, A, B tied together | clear |
| GND pads | 15, 16, S, T tied together | clear |
| 5 V decoupling note | 0.1 ceramic ×10 and 47µ ×2, rail → GND | clear; individual designators not given |
| 12 V decoupling note | 47µ ×2 and 0.1 ceramic ×5, rail → GND; “especially near the TL081s” | clear; individual designators not given |
| R358 | 47K, Vcc → timing RC node | clear |
| C74 | 3.3µ tantalum, timing RC node → one-shot pin 14 | clear |
| D29 | MA150; anode at timing RC node, cathode at one-shot pin 15 | clear |
| One-shot pin 15 | Reached through D29; not directly wired to the R358/C74 node | clear; earlier “D29 across” inventory withdrawn |
| One-shot package reference | `123` part marking present, no separate IC designator visible in the block | clear absence in inspected block; package identity unresolved |
| R38 and D3 | R38 2.2K TR3 base → GND; D3 MA150, cathode at base | clear; fresh crop (6500,4120,7900,4660) |
| D4 | One-shot Q 13 → diode → R49; cathode downstream toward R49 | clear route/polarity; type glyph MA15x uncertain |

The external timing arrangement is recorded literally. Do not replace D29
with a presumed standard application circuit. The page shows only this
half of the one-shot; no unused-half tie-offs can be inferred.

| Fresh crop box | Contents |
|---|---|
| (6950,1750,8200,2600) | Both arms of the 6 V divider |
| (900,4700,2250,5770); (1200,4750,3400,5750) | Full pad groups and decoupling notes |
| (3200,1050,4100,1730); (3650,1100,4750,2200) | R358, C74, D29, one-shot and D4 |
| (1380,3250,2100,3900); (1800,3100,3300,4300) | Overwritten pulse-shaper annotations and latch context |
| (6250,900,7800,2050) | R29 overwritten value and D2 type |

## Package and unused-pin inventory

This records what is drawn, not a suggested wiring of unshown pins.

| Package | Used sections / pins captured in this trace | Not drawn here / qualification | Confidence |
|---|---|---|---|
| IC1 LM324 | 2−/3+/1, 6−/5+/7, 9−/10+/8, 13−/12+/14 | Supply pins not drawn | clear |
| IC2, IC3, IC4, IC5 TL081 | 2−/3+/6 each | Supply, offset and remaining pins not drawn | clear |
| IC6 LM324 | 2−/3+/1, 6−/5+/7, 9−/10+/8, 13−/12+/14 | Supply pins not drawn | clear; user confirmed left-pointing 14/12/13 section |
| IC15 LM324 | 9−/10+/8 | Other sections appear on D7; supply pins not drawn | clear |
| IC7 MC3340 | 1 IN, 2 CON, 7 OUT, 6 with C100 to GND | Other pins not drawn | clear |
| IC13 buffers | 1→2, 3→4, 5→6, 9→8, 11→10, 13→12 | Exact type not printed at symbols; supply pins not drawn | clear pin routes; type uncertain |
| IC48 (7407-type buffer) | 1→2 (PROM H) | 3→4 and 5→6 are on D-3; numeral reads 48 | clear |
| IC21 `188` PROM | Outputs 1/2/3/4/5/6/7/9; addresses 10–14; /CE15 | Supply pins not drawn; note TAA ≤40 ns | clear |
| IC22 `393` | CP13, outputs 11/10/9/8; CP1, output 3; resets 2/12 | Outputs 4/5/6 and supplies not drawn; printed half names disagree with standard pin numbering | clear physical routes |
| IC26 `161` | /CLR1, CP2, load 3/4/5/6, enables 7/10, /LOAD9, carry 15 | Q outputs and supply pins not drawn | clear |
| IC27 Schmitt NAND | 12/13→11, 9/10→8, 1/2→3, 4/5→6 | Symbols/tally consistent with 74132; suffix not established | clear route; type qualified |
| IC35 NOR | 8/9→10, 11/12→13, 5/6→4 | Remaining section/supplies not drawn | clear |
| IC37 NAND | 12/13→11, 9/10→8, 1/2→3, 4/5→6 | Supply pins and exact type not printed | clear |
| IC38 NAND | 12/13→11 plus local pulse gate | Pulse gate has conflicting 1/2/3 and 10/9/8 annotations | uncertain physical pulse-gate pin allocation |
| IC46 inverters | 1→2, 13→12, 11→10 plus pulse inverter | Pulse inverter annotations overlap; user D5-V02 tentatively reads input/output 12/13; supply pins not drawn | clear listed routes; tentative pulse section pins not adopted as settled |
| One-shot `123` | A 1, B 2, /CLR3, Q 13, timing14/15 | Package designator, other half, complementary output and supply pins not drawn | clear printed pins; identity unresolved |

## Off-sheet endpoints

| Label / pad | Direction | Local endpoint | Confidence |
|---|---|---|---|
| HI SCORE, pad 3 | input | 470 Ω pull-up to Vcc; IC37.9 and .5 | clear; pull-up reference not established |
| MUTE, pad | input | R223 2.2K to Vcc; IC35.6 | clear; connector pad number not established |
| ファンファーレ (D-4/7) | output (logic) | IC35.4; D-4 receives it as "アラーム (D-5/7)" at IC67.10 | clear |
| HI SCORE SOUND out (D-4/7) | output | IC7.7 through C15 2.2µ | clear |
| 各6Vへ (D-1/7, D-2/7, D-3/7, D-4/7) | reference output | R53/R54 and C6/C7 midpoint | clear |
| 12 V / 5 V / GND | power input | Pad groups above | clear |

HI SCORE controls the cross-coupled logic and sequencer. PROM outputs load
the duration counter and operate the two note banks. The two TL081
oscillators feed the mixer/filter chain into the MC3340 IC7, whose CON 2
receives the one-shot/PROM-H envelope from IC6.7. The latch-and-MUTE gate
IC35.4 leaves as the logic line to D-4. This is a description of the traced routes, not a claim about
measured pitch, timing or game-score thresholds.

## Unresolved

| ID | Remaining issue | Source box / evidence | Effect |
|---|---|---|---|
| D5-U1 | R29 value overwritten; user D5-V01: “could be 51k, certainly begins with a 5” | (6250,900,7800,2050), resistor IC2.3→GND | Leading 5 confirmed by user; 51K is a candidate, not a settled value |
| D5-U2 | Pulse inverter and IC38 gate have multiple pin annotations; user D5-V02: “12 and 13, maybe” for the inverter input/output | (1380,3250,2100,3900) | Tentative 12→13 reading retained as uncertain; IC38 gate annotations still unresolved |
| D5-U3 | D2 reads MA156-like; D1 and D4 final type digits unclear | (6250,900,7800,2050); (4700,2900,5800,3900); (3650,1100,4750,2200) | Preserve literal uncertainty; no automatic MA150 substitution |
| D5-U4 | Closed 1 November: H buffer is IC48.1→2 | (3200,1050,4100,1730) | See review section |
| D5-U5 | One-shot package reference absent; digital exact types/suffixes unprinted at several symbols | One-shot crop above and recorded digital crops | Do not infer installed variants from circuit function |
| D5-U6 | Parts-tally glyphs remain ambiguous | (3850,4300,4300,5000) | Not used to override drawn devices or allocate gates |

The D5-V02 answer is recorded in the requested input/output order, with the
user's “maybe” intact. A 12→13 assignment would reverse the usual 13→12
section of a standard 74xx hex inverter. This is a pinout conflict to resolve,
not grounds to reverse the user's reading or adopt it as certain. It does
not change the separately traced IC46.13→.12 section in the reset path.

The old open route list is superseded: clock/reset/address map, DIP fourth
pole, note banks, fanfare output, filter connections, mute source and 6 V
divider now have named endpoints. Undrawn pins and missing references
remain explicitly distinct from uncertain visible glyphs.

## Source comparison and limits

The prior KiCad sound-board comparison reported only 19 components and no
wired multi-pin nets in the available export. It cannot adjudicate these
sound routes. That absence is not evidence that the hardware is disconnected.
The scan and recorded human confirmations remain the evidence for this file.
No emulator or other implementation has been used to fill a gap.

## Review against the scan, 1 November (Claude)

Checked on fresh crops of the stored PNG: the IC27 Schmitt clock and its
gating (R114, R113, C106, R427, C116), IC26 /CLR1, CK2, load and enables,
the IC38.12/.13 address taps (pin 13's line runs right to the dot on the
IC22.3/A4 riser at (≈2990,2110); pin 12 dots on the A0 riser), IC22 clock
and reset wiring, IC35 13 and 10 gate shapes (OR body with output bubble,
AND body with input bubbles: both NOR), both IC37 latches (OR bodies with
input bubbles: NAND) and their pins, the IC38 pulse NAND, the 74123
timing parts (R358, C74, D29), D4/R49/R55, the IC6 fanfare-envelope
section, the 6 V divider (R53/R54 1K, C6/C7 100µ), the IC1/IC2/IC4
oscillator around TR2 (R22 enters IC2.2: the riser dots on pin 2 and
crosses pin 3's line without a dot) and R32's crossing of the D2 drive
wire. These agree with the tables, apart from three corrections.

**1. The two outputs to D-4 were swapped.** IC6.7 runs east to x≈4245,
south to y≈5290 and east along the lower horizontal into **IC7 CON 2**.
The IC35 mute gate's output 4 runs east to x≈3955, south to y≈5910 and east
to the **ファンファーレ (D-4/7)** arrow. The two verticals are about 290 px
apart and never cross (crops (2400,2700,4600,6100) at ×0.35 and
(3800,5000,7000,6150) at ×0.4). This also agrees with D-4: that sheet
receives the D-5 line as a logic input, "アラーム (D-5/7)" into the OR gate
IC67.10 that drives its output-mute buffer IC57, which fits a gate output
and not an op-amp envelope. So the 74123/PROM-H envelope shapes the
hi-score tune through the MC3340. The latch state and MUTE leave as a
logic line that D-4 uses to un-mute the amplifier. (D-5 writes the label
ファンファーレ and D-4 writes アラーム; the two names are recorded as drawn.)

**2. The A/B/C note labels map to PROM bits in the opposite order.** The
four PROM output risers (pins 5, 6, 7, 9 at x≈3080, 3135, 3205, 3265,
crop (2900,1700,3400,2000)) turn east at y≈875, 960, 1045 and 1130 to the
buffer inputs IC13.9, IC13.5, IC13.11 and IC48.1 respectively, with no
crossings (crop (3000,700,4000,1300)). The A, B and C verticals have their
dots on the IC13.11, IC13.5 and IC13.9 lines. So **C = PROM 5, B = PROM 6,
A = PROM 7**, and H (PROM 9) drives IC48.1. The buffer-to-VR routes in the
table were right; only the PROM bit numbers change. This matters for the
HDL, which must index the PROM data by bit.

**3. The H buffer is IC48** (closes D5-U4). Its numeral reads 48, and
IC48.1→2 is the one section of the D-3 hex buffer IC48 not used on D-3
(3→4, 5→6). See the D-3 review for why the C-input buffer there is also
IC48.
