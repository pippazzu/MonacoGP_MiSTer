# Sound sheet D-3/7 — MY CAR SOUND engine oscillator

Source: Sega Monaco GP manual **420-0358**, PDF page **17**, board
**96598-P**, `schematics/pages/page17-sound-D3.png` (upright,
10160 × 6624 pixels, 600 dpi). Drawing stamp: AUG 30 1979.
PNG SHA-256: `526d786ee7ba3fa9a9b6f35b3a200565afc7a17753d66c1683d23b911c0bdfac`.

**Status: consolidated pin-level trace, 1 November 2026, checked against the
scan by Claude the same day.** That check made one correction (the S-ACCE C
buffer is IC48, see "Review against the scan, 1 November" at the end); where
the two differ, the review section takes precedence.
This file incorporates the recovered October review and the user's recorded
visual confirmations. Targeted source checks made during consolidation are
identified below. It replaces the earlier partial narrative and conflicting
tables; it is not a byte-identical restoration of the lost working file.
Remaining source ambiguities are listed explicitly under Unresolved.

Coordinates refer to the upright source PNG. A crossing without a dot is
unjoined. Signal names introduced for local nodes are descriptive, not new
off-sheet labels. `ICn.p` means package n, pin p. Values are transcribed;
no frequency measurement or waveform simulation is claimed.

## Crops used

| Source box | Purpose |
|---|---|
| (1300,1300,2700,2370); (1670,960,2650,1420) | DAC buffer identities, weights and pull-ups; fresh check |
| (2600,650,4550,2200) | DAC follower, diode polarity and switched lag path; fresh check |
| (4250,900,6200,2050); (5100,1950,6250,3550); (4400,3500,6200,4660) | Complete CV distribution, overlapping fresh crops |
| (5700,2000,6950,2570); (5620,3420,6270,3920) | Repeated R339 labels and unlabelled cell-2 transistor; fresh check |
| (5350,1300,7250,2700); (5250,2650,7250,3750); (4400,3850,7250,5150) | Three oscillator cells; prior review |
| (4200,650,7200,2700); (5100,2600,7300,3900); (6900,1250,9000,3450) | Control processor and audio bus; prior review |
| (6950,1400,7500,2100) | D3-V01, closed by user: unjoined crossing |
| (1250,2280,3610,2800); (7680,1580,8870,2450) | Inverter annotations, output switch and attenuator; fresh check |
| (1800,3800,8200,5500); (4400,5250,8700,6200) | Bottom control routes, tachometer and page notes; prior review |

## Function derived from the wiring

The accelerator inputs form a weighted DAC. A switched lag network and
SHIFT-controlled scaling feed three oscillator cells. Cells 2 and 3 feed
the audio diode bus; cell 1 feeds the attenuation-control processor.
An MC3340 and a 4016 gate deliver MY CAR SOUND MIX to D4. The scaled
control voltage also drives the tachometer follower.

## Accelerator DAC and digital sections

Each DAC input has a 470 Ω pull-up to Vcc. Each buffer output has a 1K,
½W pull-up to 12 V and a separate weighted resistor to the common DAC
node. R298 390K connects that DAC node to 12 V.

| Input / pad | Vcc pull-up | Buffer input → output | 12 V pull-up | DAC weight | Confidence |
|---|---|---|---|---|---|
| S-ACCE A / E | R420 470 Ω | IC57.11 → .10 | R316 1K | R297 390K | clear |
| S-ACCE B / 5 | R422 470 Ω | IC57.9 → .8 | R315 1K | R296-like 220K | clear route/value; weight designator uncertain |
| S-ACCE C / F | R421 470 Ω | IC48.3 → .4 | R314-like 1K | R295 100K | clear pins/route/value; numeral glyph reads 45-like (user D3-V02: 45), package is IC48 by allocation (see review); pull-up glyph uncertain |
| S-ACCE D / 6 | R418 470 Ω | IC48.5 → .6 | R313 1K | R294 51K | clear |

The non-inverting triangles carry slash/open-collector marks. The page tally
says `07 ×2`; this supports a buffer family. The C-input numeral glyph was
read as **45** in D3-V02 and the glyph does look 45-like, but the package is
**IC48**: see the review section at the end for the three checks.

| Section | Input and output route | Confidence |
|---|---|---|
| IC47.13 → .12 | S-ACCE D → inverter → IC54 control 12; R310 4.7K control → 12 V | clear |
| SHIFT inverter, `06 OR 16` | SHIFT A with R419 470 Ω to Vcc → east-pointing inverter → lower end R301 | clear route; package/section pins not printed |
| IC47.5 → .6 | MY CAR SOUND ON → inverter → pad 7 | clear |
| IC57.13 → .12 | Same SOUND ON input → non-inverting buffer → long bottom run → far-right riser → IC54 control 5/R357 | clear |
| SOUND ON input | R417 470 Ω to Vcc; joins IC47.5 and IC57.13 | clear |

IC47 is annotated `06 OR 16`; no exact installed choice is established.
The two SOUND ON outputs have different destinations. Pad 7 is not the
audio-switch control. The note reads `HでON` (ON when high).

## DAC follower, lag and scaling

`LAG` and `CV` below are editorial names for C62's upper node and the
scaled output IC50.8 respectively.

| Part / pins | Connection | Confidence |
|---|---|---|
| IC49 LM324, +10 / −9 / out 8 | +10 = DAC node; −9 loops to 8 | clear |
| R299 33K and D21 MA150 | IC49.8 → R299 → D21 cathode; D21 anode → LAG | clear; polarity checked on fresh crop |
| R300 150K | IC49.8 ↔ LAG | clear |
| IC54 4016, 11↔10 / ctl 12 | 11 = IC49.8; 10 → R302 68K → LAG; ctl 12 = IC47.12/R310 | clear |
| C62 47µ tantalum | LAG → GND | clear; タン is material, not a voltage rating |
| IC50 LM324, +12 / −13 / out 14 | +12 = LAG; −13 loops 14 | clear |
| R303 220K | IC50.14 → IC50.10 | clear |
| R301 470K | IC50.10 → SHIFT inverter output | clear; not a ground resistor |
| IC50 LM324, +10 / −9 / out 8 | +10 = R303/R301 junction; −9 loops 8; output = CV | clear |
| IC49 LM324, +12 / −13 / out 14 | +12 = CV; −13 loops 14; output → tachometer pad H | clear |
| IC51 LM324, +12 / −13 / out 14 | +12 = CV; −13 loops 14; output → R305 10K → IC51.10 | clear |

### Complete CV distribution — former U15 closed

Overlapping full-resolution crops now follow the entire route. Approximate
pixel waypoints (line-centre guides, not exact junction measurements):
IC50.8 near (5220,1140) → (5445,1140), with the horizontal continuing east
to IC51.12. The same dot at (5445,1140) starts a nearly straight, slightly
skewed vertical through the following taps:

| CV tap / approximate coordinate | Destination | Confidence |
|---|---|---|
| (5435,1835) | R334 150K → IC51.2 | clear |
| (5435,1975) | R335 51K → IC51.3 | clear |
| (5420,3175) | R327 270K → IC50.2 | clear |
| (5420,3305) | R328 51K → IC50.3 | clear |
| (5415,4250) | East through R318 220K → IC49.2; west to IC49.12 tachometer follower | clear |
| (5415,4380), lower end | R319 51K → IC49.3 | clear |

The 6 V horizontal crosses this CV vertical near (5425,2835) without a
dot. It continues to the separate comparator-reference column east of CV.
There is no missing snake-shaped connection between the three cells.

## Three oscillator cells — LM324 pins and passive endpoints

For each row: the integrator has −2, +3, out 1; its comparator has −6,
+5, out 7. Integrator output 1 connects directly to comparator input 6.
The feedback capacitors connect pins 2↔1. The collector resistor connects
the transistor collector to pin 2. Emitters go to GND. Comparator output
7 drives the series 10K and diode, with diode cathode at the transistor
base; the base also has a 2.2K resistor to GND.

| Cell / package | CV → −2 | CV → +3 / +3 → GND | Timing capacitance 2↔1 | +5 → 6 V / +5 → out 7 | Confidence |
|---|---|---|---|---|---|
| 1 / IC51 | R334 150K | R335 51K / R336 51K | C67 6800P ±5%, parallel C113 470P marked ADJ | R339-labelled 51K / R339-labelled 100K | clear routes/values; duplicate identity unresolved |
| 2 / IC50 | R327 270K | R328 51K / R330 51K | C65 4700P ±5% | R331 51K / R332 100K | clear |
| 3 / IC49 | R318 220K | R319 51K / R320 51K | C61 .022µ ±5% | R322 51K / R323 100K | clear |

| Cell | Transistor / collector resistor | Out 7 → series resistor → diode → base | Base → GND | Integrator out 1 destination | Confidence |
|---|---|---|---|---|---|
| 1 | TR18 C458 / R344 68K | R340 10K → D26 MA150 | R337 2.2K | C66 22µ → R304 10K → IC51.9 | clear |
| 2 | Unlabelled C458 / R326 120K | R333 10K → D25 MA150 | R329 2.2K | D24 MA150 anode | clear topology/values; no TR number visible |
| 3 | TR16 C458 / R317 100K | R324 10K → D23 MA150 | R321 2.2K | D22 MA150 anode | clear |

The close crop around the cell-2 transistor shows `C458`, but no `TR17`
reference. Keep it unlabelled rather than supplying the missing number.
The cell-1 51K and 100K labels both visibly read R339; neither is silently
renumbered R338. C113 has an adjustment note, not a variable-capacitor arrow.

## Attenuation processor, audio bus and output

| Part / pins | Connection | Confidence |
|---|---|---|
| IC51 −9 / +10 / out 8 | −9 from C66 through R304 10K; R306 10K feedback 8→9; +10 from R305 and clamp pair | clear |
| R305 10K | IC51.14 → IC51.10; crosses C66/R304 wire unjoined | clear; user D3-V01 |
| D27/D28 MA150 | Antiparallel between IC51.10 and R341/R342 midpoint | clear |
| R341 680 Ω ½W / R342 330 Ω ½W | 12 V → R341 → clamp-reference midpoint → R342 → GND | clear |
| D24 and D22 cathodes | Join audio bus; R325 10K bus → GND | clear |
| C64 10µ tantalum | Audio bus → series capacitor → IC52.1 IN | clear |
| IC52 MC3340, pin 2 CO | From IC51.8 | clear; user confirmed IN1/CO2 |
| IC52 pin 7 OUT | IC54.4 | clear |
| IC54 4016, 4↔3 / ctl 5 | 4 from IC52.7; 3 → output bias node; 5 from IC57.12 with R357 4.7K to 12 V | clear |
| R356 51K / R355 51K | 12 V → R356 → IC54.3 node → R355 → GND | clear |
| C72 22µ electrolytic | IC54.3 node → MY CAR SOUND MIX (D-4/7) | clear |

C66 is 22µ tantalum. The タン marks at C62/C66/C64 do not establish a
voltage rating. IC51.1 contributes to control processing, not a third
audio-OR diode. The audio bus does not connect to IC51.10.

## Off-sheet endpoints and undrawn pins

| Label / pad | Direction | Local endpoint | Confidence |
|---|---|---|---|
| S-ACCE A/B/C/D, E/5/F/6 | input | DAC table above | clear |
| SHIFT A (D-4/7) | input | R419 / unnumbered inverter → R301 | clear |
| MY CAR SOUND ON (D-4/7) | input | R417 / IC47.5 / IC57.13 | clear |
| 6Vへ (D-5/7) | reference connection from D5 | Comparator +5 bias resistors; separate from CV and audio | clear; former “68A” reading withdrawn |
| MY CAR SOUND MIX (D-4/7) | output | C72 | clear |
| H, 回転計へ | output | IC49.14 | clear |
| 7 | output | IC47.6 | clear |

All twelve LM324 sections are represented above. Their package supply pins
are not drawn here. IC52 pins other than 1/2/7 are not drawn. IC54's other
sections and supply pins are not drawn on this sheet; do not label them
unused, since the package is shared. Unlisted digital sections/supply pins
are also not drawn. Tally as written: `LM324 ×3, 04 ×1, 07 ×2, 3340 ×1`;
it does not list the two drawn sections of IC54.

The tachometer note shows a 750 µA meter with 15 kΩ in series. Its lamp
note specifies 12 V AC or DC. These are annotations, not extra audio nets.

## Unresolved

| ID | Remaining issue | Source box / evidence | Consequence |
|---|---|---|---|
| D3-U1 | C-input buffer numeral glyph is 45-like; package recorded as IC48 | (1500,1900,1800,2160) | Route unchanged either way; designator only |
| D3-U2 | R296-like weight and R314-like pull-up have overwritten glyphs | (1670,960,2650,1420) | Values 220K and 1K and endpoints known; identities uncertain |
| D3-U3 | Two distinct cell-1 resistors carry R339 | (5700,2000,6950,2570) | Preserve duplicate; intended numbering not established |
| D3-U4 | SHIFT inverter package/section pins not printed | (1250,2280,3610,2800) | Endpoints known; no physical section allocation invented |

Former U2/U5–U15 route, label and material questions are resolved by the
recorded review and the CV trace above. Former U4's base network is traced;
the transistor reference is absent in the inspected area, not a confirmed TR17.
The historical user answer D3-V01 (“only overlapping lines”) is preserved.
D3-V02's answer (45) is kept as the reading of the glyph; the package
allocation (IC48) is explained in the review section below.

## Source comparison and limits

The prior KiCad sound-board comparison reported only 19 components and no
wired multi-pin nets in the available export. It cannot adjudicate these
sound routes. That absence is not evidence that the hardware is disconnected.
The scan and recorded human confirmations remain the evidence for this file.
No emulator or other implementation has been used to fill a gap.

## Review against the scan, 1 November (Claude)

The consolidated tables were checked on fresh crops of the stored PNG:
the DAC (pads E/5/F/6, R420/R422/R421/R418 470 Ω, R316/R315/R314/R313 1K
to 12 V, R297/R296/R295/R294, R298 390K), the IC47/SHIFT inverters, D21
polarity and the lag/scaling chain (R299, R300, IC54 11↔10/ctl 12, R302,
C62, R303, R301), all three oscillator cells, the IC51 attenuation
processor and clamp (R305, D27/D28, R341/R342), the MC3340 (IC52 CO 2,
IN 1, OUT 7), IC54 4↔3/ctl 5 with R357, R356/R355, C72, and the bottom
SOUND ON routes (IC47.5→.6 with bubble and OC mark to pad 7; IC57.13→.12
buffer to the long run). All agree with the tables above, with one
correction.

**Correction — the S-ACCE C buffer is IC48, not IC45.** The numeral inside
the triangle at (1500,1900,1800,2160) is drawn like "4S": a 45 or the
drafter's open-topped 8. The package is IC48 because:

1. **D-2 already uses IC45** for its second MC3340 (SOUND_D2_TRACE.md,
   block 4); a 7407 section cannot carry the same designator.
2. **The pins fit IC48 exactly.** The D input buffer directly below is
   clearly 48, pins 5→6; the C buffer's pins 3→4 are the adjacent section
   of the same hex buffer, and D-5 uses the remaining 1→2 section for the
   PROM H output (its triangle also reads 48-like). IC48 then carries 1→2
   (D-5), 3→4 and 5→6 (D-3).
3. **The tally** `07 ×2` matches IC57 + IC48 with no third package.

The glyph reading 45 (D3-V02) is kept on record as what the drawing shows;
only the package designator in the tables changes.

**Added observation — 6 V column crossings.** The 6 V comparator-reference
column (x≈6165) passes immediately right of the cell-2 and cell-3
integrator-output junctions at (≈6140,3250) and (≈6140,4327). The dots there
belong to the C65/C61 feedback-cap corners; the thinner 6 V vertical passes
through without its own dot (crops (6020,3150,6320,3420),
(6020,4230,6320,4500)). Joining them would short each integrator output to
6 V, so they are crossings, as the tables already assume.
