# Sound sheet D-7/7 — other-car control and sound selection

Source: Sega Monaco GP manual **420-0358**, PDF page **21**, board
**96598-P**, manual 420-0358, PDF page 21 (upright,
10160 × 6624 pixels, 600 dpi). Drawing stamp: AUG 30 1979.
PNG SHA-256: `38e1750788015872c29eff4c9c00dd6720de756fdd68e243f6f2f45a0d09a2ff`.

**Status: consolidated pin-level trace, 1 November 2026, checked against the
scan by Claude the same day.** That check made one correction (decoder
outputs O6/O7 and R124, applied below and explained in "Review against the
scan, 1 November" at the end).
This file incorporates the recovered October review and the user's recorded
visual confirmations. Targeted source checks made during consolidation are
identified below. It replaces the earlier partial narrative and conflicting
tables; it is not a byte-identical restoration of the lost working file.
Remaining source ambiguities are listed explicitly under Unresolved.

Coordinates refer to the upright source PNG. A crossing without a dot is
unjoined. Signal names introduced for local nodes are descriptive, not new
off-sheet labels. `ICn.p` means package n, pin p. Values are transcribed;
no frequency measurement or waveform simulation is claimed.

## Inventory, decoder and supply note

There are **four MC3340s: IC20,19,34,33**, not two. The old tally cannot
override four drawn blocks. Each has CON 2/IN 1/OUT 7. The top-right supply
note lists 4016/3340/339/324/**081** at 12V; the old 04(?) reading is withdrawn.
Undrawn supply pins remain not drawn; the note does not specify every pin.

| Item | Reviewed route | Confidence |
|---|---|---|
| IC36 inputs | A 15 S-ACCE B, B 14 S-ACCE C, C13 S-ACCE D, D12 GND | clear |
| O0–O3 | Pins1/2/3/4 tied; R225 4.7K to Vcc; IC38.10 and IC56.13 | clear |
| O4–O5 | Pins5/6 tied;47K to Vcc; IC38.9 | clear |
| O6, O7 | Pins 7 and 9 tied at R124's lower end; **R124 1.5K** → common analog feed | clear; corrected 1 November (was O6 via 15K, O7 direct) |
| IC38.8 | IC47 input 9 → output 8 → R169 1.2K → common feed; R125 1K to 12V also joins feed | clear |
| Decoded-group inverter | **IC56 input 13 → output 12**, drives IC55.13 and .3 | clear, user D7-V03=56 |

IC38 symbol is NAND and agrees with its D5 sections. Exact type suffix is
unprinted/unresolved. Page tally alone does not invalidate that function.
The user confirmed IC56's designator, not a new chip type.

## Generators and reference nodes

| Stage | Reviewed route | Confidence |
|---|---|---|
| TL081 IC14 | R126 33K feed → −2; C28/C29 back-to-back **22µ×2** between 2/6; R151 10K to 12V and R127 10K to GND at+3 | clear; old 2.2M×2 withdrawn |
| TL081 IC28 | R150 33K feed → −2; C32/C31 back-to-back22µ×2 between 2/6; +3 joins IC14.3 and C30 22µ to GND | clear |
| TR12 reset | Collector → R173 100Ω → IC14.2; emitter GND; IC59 Q 13 → R228 10K → base, 10K base → GND | clear route; base-ground designator not established |
| TR13 reset | Collector → R172 100Ω → IC28.2; emitter GND; IC59 Q 5 → R227 10K → base; R226 10K base → GND | clear |
| IC15 upper | IC14.6 → R132 100K → −6; R133 47K feedback 7 → 6; +5 at R130 5.1K to 12V/R131 6.8K to GND midpoint | clear |
| IC15 lower | IC28.6 → R128 100K → −2; R129 47K feedback 1 → 2; +3 from same R130/R131 reference | clear, user D7-V01 |

**D7-V01:** IC28.6/R128 horizontal crosses the IC15.3 reference vertical
without joining at~(3158,2711). User answered no dot. The former direct
IC28.6 → IC15.3 claim is withdrawn. Review crop(3020,2580,3420,2880).

References: A=R161 10K to 12V/R157 5.1K to GND; B=R147 6.8K to 12V/R122 2.7K
to GND; C=R140 5.6K+R144 330Ω from 12V/R119 3.3K to GND; D=R141 5.1K
to 12V/R116 1K to GND. All are midpoint nodes, recorded clear.
IC15.7 feeds the upper IC17/IC16 shaping pairs and R176. IC15.1 feeds
lower pairs and R154. Long verticals were followed to these endpoints.

| Shaper section | Input and feedback | Output | Confidence |
|---|---|---|---|
| IC17 6−,5+,7 out | IC15.7 → R162 10K → 6; R163 5.1K feedback 7 → 6; +5=A | IC24.8 | clear |
| IC17 2−,3+,1 out | B → R148 51K → 2; R158 51K feedback 1 → 2; IC15.7 → R159 3.3K → 3; R160 6.8K 3 → GND | IC24.11 | clear |
| IC17 9−,10+,8 out | IC15.1 → R138 10K → 9; R139 5.1K feedback 8 → 9; +10=A | IC24.4 | clear |
| IC17 13−,12+,14 out | B → R123 51K → 13; R134 51K feedback 14 → 13; IC15.1 → R135 3.3K → 12; R136 6.8K 12 → GND | IC24.1 | clear route; apparent R136 duplicate below |
| IC16 6−,5+,7 out | IC15.7 → R145 10K → 6; R146 10K feedback 7 → 6; +5=C | IC23.8 | clear |
| IC16 2−,3+,1 out | IC15.7 → R143 51K → 3; R136 51K 3 → D; −2 loops 1 | IC23.11 | clear topology/value; R136 apparent duplicate, identity uncertain |
| IC16 9−,10+,8 out | IC15.1 → R120 10K → 9; R121 10K feedback 8 → 9; +10=C | IC23.4 | clear |
| IC16 13−,12+,14 out | IC15.1 → R118 51K → 12; R117 51K 12 → D; −13 loops 14 | IC23.1 | clear |

## Comparator and eight selection-switch paths

HREF is an editorial local name: R208 10K to 12V/R209 10K to GND midpoint,
C33 10µF to GND. It reaches IC31.11/.5 and IC30.11/.5. Crossings with
signal wires do not make extra reference connections.

| Comparator | + input | − input | Output/feedback/pull-up and destination | Confidence |
|---|---|---|---|---|
| IC31 9+,8−,14 out | IC17.7 via R171 2.2K | IC17.1 | R170 100K feedback 14 → 9;2.2K to 12V; output 14 → IC24 ctl 6 and IC31.10 | clear routes; pull-up designator uncertain |
| IC31 11+,10−,13 out | HREF | IC31.14 | 2.2K to 12V; output 13 → IC24 ctl 12 | clear routes/value and R169 label; duplicate of 1.2K feed unresolved |
| IC30 9+,8−,14 out | IC16.7 via R167 2.2K | IC16.1 | R166 100K feedback 14 → 9; R164 2.2K to 12V; output 14 → IC23 ctl 6 and IC30.10 | clear |
| IC30 11+,10−,13 out | HREF | IC30.14 | R165 2.2K to 12V; output 13 → IC23 ctl 12 | clear |
| IC31 7+,6−,1 out | IC17.8 via R185 2.2K | IC17.14 | R184 100K feedback 1 → 7; R183 2.2K to 12V; output 1 → IC24 ctl 5 and IC31.4 | clear |
| IC31 5+,4−,2 out | HREF | IC31.1 | R186 2.2K to 12V; output 2 → IC24 ctl 13 | clear |
| IC30 7+,6−,1 out | IC16.8 via R181 2.2K | IC16.14 | R182 100K feedback 1 → 7; R180 2.2K to 12V; output 1 → IC23 ctl 5 and IC30.4 | clear |
| IC30 5+,4−,2 out | HREF | IC30.1 | R179 2.2K to 12V; output 2 → IC23 ctl 13 | clear |

| 4016 section | Input | Output path | Control | Confidence |
|---|---|---|---|---|
| IC24 8↔9 | IC17.7 → 8 | 9 → R196 10K → IC18.5 | 6 ← IC31.14 | clear |
| IC24 11↔10 | IC17.1 → 11 | 10 → R195 10K → same sum | 12 ← IC31.13 | clear |
| IC23 8↔9 | IC16.7 → 8 | 9 → R194 10K → IC18.3 | 6 ← IC30.14 | clear |
| IC23 11↔10 | IC16.1 → 11 | 10 → R193 10K → same sum | 12 ← IC30.13 | clear |
| IC24 4↔3 | IC17.8 → 4 | 3 → R212 10K → IC32.10 | 5 ← IC31.1 | clear |
| IC24 1↔2 | IC17.14 → 1 | 2 → R213 10K → same sum | 13 ← IC31.2 | clear |
| IC23 4↔3 | IC16.8 → 4 | 3 → R210 10K → IC32.12 | 5 ← IC30.1 | clear |
| IC23 1↔2 | IC16.14 → 1 | 2 → R211 10K → same sum | 13 ← IC30.2 | clear |

**D7-V02:** IC24 ctl 6 horizontal and R196/R195 sum vertical cross unjoined
near(5115,1640), user no dot. Review crop(4870,1370,5370,1870).
Followers IC18 +5/−6/out7 and +3/−2/out1 drive IC20 CON 2 and IC19 CON 2;
IC32 +10/−9/out8 and +12/−13/out14 drive IC34 CON 2 and IC33 CON 2.
All follower negative inputs loop to their own output.

## Trigger feedback and reset pulses

IC29 second-stage +5/+11 reference=R152/R153 10K each,12V/GND midpoint.
First-stage −6/−8 reference is separate 3.3K/3.3K divider; upper label
R157-like uncertain (potential duplicate of reference A), lower R156. Do not join R176/R154 input crossings.

| Stage | Reviewed route | Confidence |
|---|---|---|
| First LM339 7+,6−,1 out | IC15.7 → R176 2.2K → +7; −6 at 3.3K divider; R177 100K feedback 1 → 7; R178 2.2K output 1 → 12V | clear; assigning unnumbered triangle to IC29 fits adjacent sections but is not printed inside it |
| IC29 5+,4−,2 out | +5 R152/R153; −4 preceding output 1; output 2 → IC55.2 and IC46.3; R174 4.7K to Vcc | clear; R174 read in fresh crop |
| IC29 9+,8−,14 out | IC15.1 → R154 2.2K → +9; −8 at 3.3K divider;100K feedback 14 → 9 (no visible reference); R415 2.2K output 14 → 12V | clear |
| IC29 11+,10−,13 out | +11 R152/R153; −10 IC29.14; output 13 → IC55.5; R175 4.7K to Vcc | clear |
| IC55 1/2/13 → 12 | Pad C with R311 2.2K to Vcc; IC29.2; IC56.12; output 12 → IC59 B 2 and IC58 B 10 | clear, NOR |
| IC55 4/5/3 → 6 | Pad C; IC29.13; IC56.12; output 6 → IC46.5 | clear, NOR |
| IC46 5 → 6 | IC55.6 inverted → IC55.9 | clear |
| IC46 3 → 4 | IC29.2 inverted → IC55.11 | clear |
| IC55 9/11/10 → 8 | IC46.6; IC46.4; IC58 Q 5; output 8 → IC59 B 10 | clear, NOR |
| IC59 first half | A 1 GND, B 2 IC55.12, /CLR3 Vcc; C75 2.2µ pins 14/15; R259 10K pin 15 → Vcc; Q 13 → R228/TR12 and bottom route → R215/TR11 | clear |
| IC59 second half | A 9 GND, B 10 IC55.8, /CLR11 Vcc; **C85 2.2µ** pins 6/7; **R371 10K** pin 7 → 5V; Q 5 → R227/TR13 and bottom route → R200/TR10 | clear; user D7-V05 confirms C85/R371 |
| IC58 drawn half | A 9 GND, B 10 IC55.12, /CLR11 Vcc;47µ pins 6/7; R320 47K pin 7 → Vcc (label reads R320, the same as D-3's cell-3 51K; duplicate recorded, not renumbered); Q 5 → IC55.10 | clear topology/values; C84-like designator uncertain |

Unused complementary outputs have no external wires drawn; the other half
of IC58 is not drawn here. Do not invent tie-offs. The old 6 ms estimate was
withdrawn: no measured timing or established device-specific timing law.
IC55 NOR sections match 7427 pinout/tally.

## Four MC3340 branches and car-control outputs

| Stage | Reviewed route | Confidence |
|---|---|---|
| CAR CON NO1 | IC18.7 → R197 100K → IC18.9; R198 100K feedback 8 → 9; +10 at R192 5.1K to 12V/R191 5.6K to GND midpoint; out8 → D6 CAR CON NO1 | clear |
| CAR CON NO2 | IC32.8 → R188 100K → IC18.13; R187 100K feedback 14 → 13; +12 R189 5.6K to 12V/R190 **68K as written** to GND; out14 → D6 CAR CON NO2 | clear route; no decimal inserted |
| NO1 front | NO1 CAR SOUND → C37 2.2µ → IC20 IN 1; OUT 7 → C35 2.2µ → IC25.8; .9 → R202/R205 10K each 12V/GND midpoint → C39 2.2µ → R207 10K → IC32.6 | clear |
| NO1 back | NO1 CAR SOUND → C36 2.2µ → IC19 IN 1; OUT 7 → C38 2.2µ → IC25.11; .10 → R203/R206 10K each 12V/GND midpoint → C41 2.2µ → R220 51K → BACK OTHER CAR(D2) | clear |
| TR11 enable | IC59 Q 13 → R215 10K → base; 10K base → GND (label not legible); emitter GND; collector → R216 10K to 12V and IC25 ctl 6/12 | clear |
| NO2 front | NO2 CAR SOUND → C45 2.2µ → IC34 IN 1; OUT 7 → C43 2.2µ → IC25.4; .3 → R218/R221 10K each 12V/GND midpoint → 2.2µ → R204 10K → IC32.6 | clear route; coupling cap after switch also labelled C38; duplicate identity unresolved |
| NO2 back | NO2 CAR SOUND → separate 2.2µ → IC33 IN 1; OUT 7 → 2.2µ → IC25.1; .2 → R219/R222 10K each 12V/GND midpoint → C40 2.2µ → R217 51K → same BACK OTHER CAR bus | clear route; input/output capacitors have no visible designators in the inspected crop |
| TR10 enable | IC59 Q 5 → R200 10K → base; R201 10K base → GND; emitter GND; collector → R199 10K to 12V and IC25 ctl 5/13 | clear |
| Front mixer | R207/R204 sum → IC32.6; +5 at 6V; **R426 33K feedback 7 → 6**; output 7 → C15-labelled 2.2µ → FRONT OTHER CAR MIXへ(D4) | clear; R426 confirmed user D7-V04 |

R426 is not R226: R226 10K at TR13 base is separate. Back resistor sum is
separate from TR11 base and collector wires at crossings. No incoming-gate
interpretation of BACK OTHER CAR survives. Direction of CAR CON and CAR
SOUND follows driven outputs/receiving pins, not unread arrowheads alone.

## Recorded source crops

Decoder: (1100,650,2500,2900). Generator/reference: (2350,850,4600,2250),
(2350,2100,4600,3500), (2250,1000,2850,3050), (2950,2350,3550,3050),
(3400,2650,4100,4450), (3400,4350,4100,6050), (3600,4700,4650,5850).
Shapers/comparators: (2400,3500,4400,5100), (4200,3300,6300,5050),
(2400,4900,6300,6150), (4300,1300,5900,2900), (4300,2900,5900,4500),
(4300,4500,5900,6100), (5500,1800,6800,3500), (5750,2850,7100,3850).
Trigger/reset: (1100,2600,2600,4500), (1100,3950,2700,5250),
(2100,3650,3600,5000), (2100,4900,3600,6000), (2150,2850,3900,3450),
(2100,5500,4000,6250), (3900,5500,5800,6250), (5700,5500,7600,6250).
Outputs: (6200,1850,8800,3150), (6000,3500,8800,5350),
(5750,1100,7000,2050), (6150,400,7050,1100), (6200,3150,7600,4050),
(7100,1550,7800,3200), (7600,900,9000,1800), (5900,5350,7800,6250).
D7-V03 (1490,1570,1840,1820), V04 (8150,1090,8580,1410),
V05 (1980,3000,2500,3360): user 56,426,C85/R371. Questions closed.

## Fresh source checks and component identity limits

| Item | Reading and disposition | Source box | Confidence |
|---|---|---|---|
| Decoder-feed bias resistor | **R125 1K**, 12 V → common feed; replaces the recovered “R12 51K” transcription | (1800,600,2600,1160) | clear |
| R136 at IC16.3 | 51K between +3 and reference D; label visibly R136 | (4100,3030,4550,3470) | clear reading; duplicate identity unresolved |
| IC31.13 pull-up | 2.2K, label R169, to 12 V; distinct from decoder's R169 1.2K | (5200,1720,6000,2950) | clear reading; duplicate identity unresolved |
| IC31.14 pull-up | 2.2K to 12 V; R168-like reference remains uncertain | (5200,1720,6000,2950) | clear value/route; uncertain reference |
| IC29.2 pull-up | R174 4.7K to Vcc | (2850,4170,3600,4830) | clear |
| First-stage reference upper resistor | 3.3K to 12 V, R157-like reference; do not force R155 by sequence | (2050,3450,3450,5050) | clear value/route; uncertain reference |
| First-stage reference lower resistor | R156 3.3K to GND | (2380,4850,2830,5550) | clear |
| IC58 timing capacitor | 47µ, C84-like label | (1250,3880,2520,4700) | clear value/pins; uncertain reference |
| NO2 front coupling after IC25.3 | 2.2µ, label C38; route to R204 10K | (6800,3500,8650,4650) | clear reading; duplicate with NO1-back C38 unresolved |
| NO2 back IC33 input/output capacitors | Both 2.2µ electrolytic; no individual designators visible | (6200,4400,7500,5340) | clear values/routes; labels absent in inspected area |

The fresh R125 check is a substantive correction to the recovered file.
The repeated R136, R169 and C38 references identify distinct drawn parts;
they are not permission to merge their nets or silently renumber components.

## Package inventory and undrawn pins

| Package | Used sections / pins on this sheet | Other pins / sections | Confidence |
|---|---|---|---|
| IC36 `145` | Inputs15/14/13/12; outputs 1/2/3/4/5/6/7/9 | Outputs 8/9 by logical name (physical10/11) and supply pins not drawn | clear |
| IC38 NAND | 9/10→8 | Other sections shared with D5; exact suffix unprinted | clear function/route; type suffix unresolved |
| IC47 | 9→8 inverter | Other sections on D3; supplies not drawn | clear |
| IC56 | 13→12 inverter | Other sections/supplies not drawn here | clear; user D7-V03 |
| IC55 NOR | 1/2/13→12, 3/4/5→6, 9/10/11→8 | Supply pins not drawn; matches 7427 pinout/tally | clear |
| IC46 | 3→4, 5→6 inverters | Other sections on D5; supply pins not drawn | clear |
| IC58 `123` | A 9, B 10, /CLR11, Q 5, timing6/7 | First half and complementary output not drawn here; no tie-offs inferred | clear |
| IC59 `123` | A 1/B 2/CLR3/Q 13/timing14/15; A 9/B 10/CLR11/Q 5/timing6/7 | Complementary outputs and supply pins not drawn | clear |
| IC14, IC28 TL081 | 2−/3+/6 each | Other pins not drawn | clear |
| IC15 LM324 | 6−/5+/7 and 2−/3+/1 | 9−/10+/8 on D5; fourth section and supplies not drawn here | clear |
| IC16, IC17 LM324 | All four sections, pins 1/2/3/5/6/7/8/9/10/12/13/14 | Supply pins not drawn | clear |
| IC18 LM324 | All four sections, pins 1/2/3/5/6/7/8/9/10/12/13/14 | Supply pins not drawn | clear |
| IC32 LM324 | 6−/5+/7, 9−/10+/8, 13−/12+/14 | 2−/3+/1 section and supply pins not drawn here | clear |
| IC29 LM339 | 5+/4−/2, 9+/8−/14, 11+/10−/13 | Adjacent 7+/6−/1 section lacks a package numeral; assignment to IC29 qualified | uncertain package allocation for that one triangle |
| IC30, IC31 LM339 | All four sections, detailed comparator table above | Supply pins not drawn | clear |
| IC23, IC24, IC25 4016 | 8↔9 ctl 6; 11↔10 ctl 12; 4↔3 ctl 5; 1↔2 ctl 13 | Supply pins not drawn | clear |
| IC19, IC20, IC33, IC34 MC3340 | 1 IN, 2 CON, 7 OUT | All other pins not drawn here | clear |

The original parts tally reads `74145 ×1, 123 ×2, 27 ×1, 04 ×1,
TL081 ×2, 4016 ×3, 3340 ×2, LM339 ×3, LM324 ×4`. Four MC3340 blocks
are drawn. Preserve the tally/drawing discrepancy. The supply note says
4016/3340/339/324/081 use 12 V, but does not explicitly draw their supply
pin numbers. Do not turn that note into invented pin connections.

## Off-sheet endpoints and function

| Label | Direction | Local route | Confidence |
|---|---|---|---|
| S-ACCE B/C/D (D-3/7) | input | IC36 pins 15/14/13 | clear |
| Trg / F SOUND, pad C | input | R311 2.2K to Vcc; IC55.1 and .4 | clear local route; external connector identity unresolved |
| CAR CON NO1 (D-6/7) | output | IC18.8 | clear |
| CAR CON NO2 (D-6/7) | output | IC18.14 | clear |
| NO1 CAR SOUND (D-6/7) | input | C37→IC20.1 and C36→IC19.1 | clear |
| NO2 CAR SOUND (D-6/7) | input | C45→IC34.1 and unlabelled 2.2µ→IC33.1 | clear |
| FRONT OTHER CAR MIXへ (D-4/7) | output | IC32.7 through C15-labelled 2.2µ | clear |
| 後 BACK OTHER CAR (D-2/7) | output | R220/R217 sum; receiving D2 IC40.6 confirmed earlier | clear |
| 6 V reference | input reference | IC32.5 at front mixer | clear local node; source of shared rail not re-invented here |

Accelerator decoding changes the common feed to two TL081 integrators.
Their reset pulses and comparator feedback drive the shaping and selection
array. The selected control signals modulate four MC3340 paths carrying
the two D6 audio sources. IC25 gates the front/back paths, and the front
pair sums at IC32.6. The separate CAR CON outputs return to D6.
No measured sweep time, pitch or passing-car trajectory is claimed.

## Unresolved

| ID | Issue | Source box / evidence | Effect |
|---|---|---|---|
| D7-U1 | Apparent duplicate R136 at 6.8K and 51K | (3400,4350,4100,6050); (4100,3030,4550,3470) | Keep distinct parts and routes; intended numbering unresolved |
| D7-U2 | Upper 3.3K divider reference R157-like; possible duplicate of A-reference 5.1K | (2050,3450,3450,5050) | Value/net known; reference uncertain |
| D7-U3 | IC31.14 pull-up reference R168-like; IC31.13 pull-up R169 duplicates decoder R169 | (5200,1720,6000,2950); (1800,600,2600,1160) | Preserve literal glyphs and separate nets |
| D7-U4 | Unnumbered LM339 section at pins 7+/6−/1 | (2050,3450,3450,5050) | IC29 assignment compatible with pins but not printed |
| D7-U5 | IC58 capacitor reference C84-like | (1250,3880,2520,4700) | Value47µ and pins 6/7 known |
| D7-U6 | C38 used at both NO1-back output and NO2-front post-switch coupling | (6200,1850,8800,3150); (6800,3500,8650,4650) | Distinct 2.2µ parts; intended numbering unresolved |
| D7-U7 | TR12 and TR11 base-to-ground 10K reference labels not established | (2350,850,4600,2250); (6200,1850,8800,3150) | Values/routes known; do not supply guessed reference numbers |
| D7-U8 | IC38 exact type/suffix, pad C's external connector identity | Decoder and trigger crops above | Local functions/routes known; installed variant/external mapping unresolved |

User questions D7-V01/V02 are closed as unjoined crossings. D7-V03/V04/V05
are closed as **IC56, R426, C85/R371**. None has been reopened. The old
“central array inventoried only” boundary is replaced by the pin tables
above. Some printed identities still require checking; physical hardware
resolution is not claimed.

## Source comparison and limits

The prior KiCad sound-board comparison reported only 19 components and no
wired multi-pin nets in the available export. It cannot adjudicate these
sound routes. That absence is not evidence that the hardware is disconnected.
The scan and recorded human confirmations remain the evidence for this file.
No emulator or other implementation has been used to fill a gap.

## Review against the scan, 1 November (Claude)

Checked on fresh crops of the stored PNG: the IC36 decoder outputs and
pull-ups, the IC38 gate (OR body with input bubbles: NAND, 10/9 → 8) and
the IC47 9→8 inverter (bubble and OC mark), R169 1.2K, R125 1K, R126/R150,
the IC55 gates (AND bodies with input bubbles: 3-input NOR, 7427), pad C
with R311, IC46 3→4 and 5→6, IC59 both halves (C75/R259, C85/R371, A
inputs grounded, /CLR to Vcc), IC58 (C84-like 47µ, R320 47K), the IC17
upper shaper pair with references A and B, IC24 8↔9/11↔10 and the IC31
9/8→14 comparator, the IC18 9/10→8 CAR CON NO1 stage (R197, R198), the
IC18 3/2→1 follower, IC20/IC19 front and back NO1 paths through IC25,
R202/R205, R203/R206, C39/R207, C41/R220, TR11 with R215/R216, and the
IC32 front mixer (R426 33K, +5 at 6 V). These agree with the tables, with
one correction.

**Correction — decoder outputs O6 and O7 share R124, which is 1.5K.**
At (2150,1150,2450,1800) the pin-7 riser turns east at y≈1460 into a dot
at R124's lower end, and the pin-9 riser rises straight into the same dot.
Nothing else reaches pin 9. The long vertical just to the right
(x≈2420) is the common feed itself running down to R150/IC28, and is not
connected to pin 9. The value is written "1.5" with a clear decimal
point, then K (crop (2200,1220,2450,1440)), so R124 is 1.5K, not 15K.
Decoded states 6 and 7 therefore pull the feed down through 1.5K, and
states 0–5 through the IC47 inverter and R169 1.2K, both against R125 1K
to 12 V.

**Noted, not changed:** the IC58 timing resistor's label reads R320, which
D-3 also uses for its cell-3 51K. It is recorded as drawn.

## R190 on the board photo, 2 November (Claude)

The schematic writes R190 as 68K. With 68K the CAR CON NO2 stage
(IC18 14/13, R187/R188 100K, +12 from R189 5.6K / R190) puts its
reference near 11.1 V and its output stays pinned at the 10.5 V rail
whatever IC32.8 does, so car 2's pitch would never move. The parts-side
photo of a 96598-P board (stonedDiscord/MonacoGP, `Pictures/Sound Board
(Parts Side).JPG`, crop (1950,660,2160,810) of the 3264×2448 image)
shows R190 above IC18 with bands blue, grey, red, gold: **6.8K**. The
third upright resistor after R187 and R188 (its label is hidden) reads
bottom to top green, blue, red, 5.6K, which matches R189 as drawn. With 6.8K the reference is 6.58 V and the stage works like the
NO1 stage. The model uses 6.8K; the schematic value is kept above as
written.
