# Sound sheet D-6/7 — OTHER CAR sound generators

Source: Sega **Monaco GP (420-0358)**, PDF page **20**,
manual 420-0358, PDF page 20, **10176 × 6624**, 600 dpi, stored **upright**
(no rotation needed). Title block: "96598-P (D-6/7) OSCILLATOR"; circled
page caption "OTHER CAR SOUND"; top-left sheet mark "Ⓢ - MONACO GP".
Printed notes: "OP AMP は LM324" (op-amps are LM324), "NS製の用"-like note
beside it (reads as "use NS-made"; U1), part tally "LM324 ×3, MC3340 ×2".
Source PNG SHA-256:
`1b99be419071c3a1abb1e7f447387b3d87a2d4baaeba3f096b8a7050120b3ae4`.

**Status: consolidated trace, 1 November 2026; spot-checked against the scan
by Claude the same day with no changes (see the end).** This document folds the
recorded review of 31 October and the user's confirmed answers into the
main tables. It replaces the baseline plus appended recovery continuation;
it is not a byte-identical restoration of the lost working file. No new
schematic reading, simulation or measurement is claimed by this consolidation.

The recorded full-page pass covers both OTHER CAR banks and the shared
6 V half-rail. Circuit-review questions are closed; two resistor designators
are confirmed absent. The manufacturer note and corner stamp remain
unreadable. Confidence below refers to the baseline visual trace as corrected
by the recorded review, with direct user confirmations identified separately.
Coordinates refer to the upright source PNG. The original pass used native
source crops at 1.0–2.6×; no net-extractor validation was claimed.

## Crops used

| Box | Contents |
|---|---|
| (0,0,10176,6624) ×0.14 | overview, orientation, annotations |
| (1400,850,3300,2100) | NO1 cell 1 and CV input |
| (1900,1950,3500,3050) / (1900,3000,3500,4150) | NO1 cells 2, 3 |
| (3100,800,4600,1900) / (3680,900,4120,1400) / (3650,1250,4400,2400) | NO1 output chain, IC12 MC3340, IN network |
| (2700,1000,3450,1750) | NO1 cell-1 output routing |
| (2650,3950,3700,4800) | 6 V half-rail (R82/R83) |
| (4350,900,5900,2150) / (4400,2150,6000,3200) / (4400,3200,6000,4450) | NO2 cells 1, 2, 3 |
| (5850,850,7300,2000) / (5700,1900,7300,3700) / (5180,1050,5480,3550) | NO2 output chain, diode bus, 6 V riser |

## Structure (identical in both banks)

Each bank is three two-amp relaxation oscillators ("cells"), one MC3340
attenuator and an output arrow to sheet D-7/7. Cell topology (all six cells
identical except values/designators):

| Node | Connection |
|---|---|
| CV input line | from the bank's "OTHER CAR CON" arrow (D-7/7); a vertical distributes it to all three cells of the bank |
| integrator −in | R_in from the CV line; timing cap C from −in to the integrator output |
| integrator +in | R_a from the CV line, R_b to GND (both 51K: input divider) |
| integrator out | → Schmitt −in; → (via the cell's riser) one destination: cell 1 → the bank's CON coupling cap; cells 2, 3 → MA150 diode → the bank's audio bus |
| Schmitt +in | R_h1 51K to the **6 V rail**, R_h2 100K to Schmitt out (hysteresis) |
| Schmitt out | → R_f 10K → MA150 (cathode at the base node) → transistor base; base also has 2.2K to GND |
| transistor (2SC458) | emitter GND; collector → R_c → the integrator −in node (current switch that reverses the ramp) |

Amp sections (LM324, printed pin numbers all match the standard pinout):
left bank uses sections A (2,3→1) and B (6,5→7); right bank uses D
(13,12→14) and C (9,10→8) of the **same three packages**: cell 1 = IC10,
cell 2 = IC9, cell 3 = IC8 (left/right = A·B / D·C respectively), matching
the printed tally LM324×3.

### Per-cell parts

| Bank/cell | R_in | R_a/R_b | C (±5%) | R_c | R_f / diode | base R | TR | Schmitt R_h1/R_h2 |
|---|---|---|---|---|---|---|---|---|
| NO1 c1 (IC10 A/B) | R103 150K | R104 51K / R102 51K | C21 6800P ∥ ※ADJ 470P adjustment capacitor | 68K (no label; user-confirmed) | R107 10K / D14 | R101 2.2K | TR9 C458 | R105 51K / R106 100K |
| NO1 c2 (IC9 A/B) | R95 270K | R96 51K / R94 51K | C19 4700P | R92 120K | R99 10K / D13 | R93 2.2K | TR8 C458 | R97 51K / R98 100K |
| NO1 c3 (IC8 A/B) | R87 220K | R88 51K / R86 51K | C17 0.022 | R84 100K (user D6-V03) | R91 10K / D12 | R85 2.2K | TR7 C458 | R89 51K / R90 100K |
| NO2 c1 (IC10 D/C) | R75 150K | R76 51K / R74 51K | C20 6800P ∥ ※ADJ 470P adjustment capacitor | R72 68K | R79 10K / D7 | R73 2.2K | TR6 C458 | R77 51K / R78 100K |
| NO2 c2 (IC9 D/C) | R67 270K | R68 51K / R66 51K | C18 4700P | R64 120K | R71 10K / D6 | R65 2.2K | TR5 C458 | R69 51K / R70 100K |
| NO2 c3 (IC8 D/C) | R59 220K | R60 51K / 51K (no label; user-confirmed) | C16 0.022 | R56 100K | R63 10K / D5 | R57 2.2K | TR4 C458 | R61 51K / R62 100K |

All six rows above are clear in the recorded corrected trace. The two
470P adjustment capacitors have no variable-capacitor arrow; they are not
identified as trimmers. The absent labels are settled observations, not
missing numbers to infer from sequence:

| Resistor | Recorded endpoints | Confidence |
|---|---|---|
| NO1 cell-1, 68K, no label | TR9 collector → IC10.2 | user-confirmed absence and value |
| NO1 cell-3, R84 100K | TR7 collector → IC8.2 | user-confirmed designator, D6-V03 |
| NO2 cell-1, R74 51K | IC10.12 → GND | clear in recorded review |
| NO2 cell-3, 51K, no label | IC8.12 → GND | user-confirmed absence and value |

R60 labels the horizontal 51K, and R56 the separate 100K, in NO2 cell 3.
Neither supplies a designator for its lower vertical 51K resistor.

All diodes on the page are MA150. The feedback diodes (D14/D13/D12,
D7/D6/D5) are drawn with the **cathode at the transistor-base node**; the
bus diodes (D11/D10 left, D9/D8 right) with the **anode at the cell side**,
cathode on the bus.

### Output chains

| Item | NO1 (left) | NO2 (right) |
|---|---|---|
| CON source | cell-1 integrator output | cell-1 integrator output |
| CON coupling | C26 22µ | C24 22µ |
| CON bias | R108 10K to 12V, R109 **.33 K = 330Ω** to GND (user D6-V01) | R80 10K to 12V, R81 3.3K to GND |
| MC3340 | IC12: CON2, IN1, OUT7 (recorded review) | IC11: CON2, IN1, OUT7 (recorded review) |
| audio bus | cell-2 → D11, cell-3 → D10 | cell-2 → D9, cell-3 → D8 |
| bus load | R11 10K to GND | R150 10K to GND |
| bus → IN | C27 10µ in series | C25 10µ in series |
| output | arrow "OTHER CAR SOUND NO1 (D-7/7)" | arrow "OTHER CAR SOUND NO2 (D-7/7)" |

The output-chain rows are clear in the corrected review. **R109 is 330Ω**;
the earlier symmetry-based 3.3K assignment is withdrawn. The other bank's
**R81 remains 3.3K**. Unlisted MC3340 pins are not supplied by this recovery;
no new package-power connections are inferred.

### 6 V half-rail (shared)

12V → R82 1K → midpoint → R83 1K → GND. **C22 100µ** is across the upper
12V-to-midpoint branch; **C23 100µ** is across midpoint-to-GND. These routes
were settled in the recorded review. The equal-resistor divider is the
nominal 6 V reference; no measured voltage is claimed.

The reference feeds Schmitt resistors R105/R97/R89 in NO1 and R77/R69/R61
in NO2. The vertical columns end at R105/R77 below the cell-1 outputs.
The previously cited cell-1 output dots are on output/coupling paths, not
reference-column junctions. The six actual lower crossings were reviewed
as D6-V02; the user answered **“none”**, so all six are unjoined:

| Point | Crossing wires | Source coordinate | Confidence |
|---|---|---|---|
| 1 | NO1 cell-2 C19 output-side feedback / reference vertical | (2727,2209) | user-confirmed no dot |
| 2 | NO1 cell-2 IC9.1→.6 output / reference vertical | (2726,2365) | user-confirmed no dot |
| 3 | NO1 cell-3 C17 output-side feedback / reference vertical | (2723,3283) | user-confirmed no dot |
| 4 | NO1 cell-3 IC8.1→.6 output / reference vertical | (2723,3426) | user-confirmed no dot |
| 5 | NO2 cell-2 IC9.14→.9 output / reference vertical | (5364,2388) | user-confirmed no dot |
| 6 | NO2 cell-3 IC8.14→.9 output / reference vertical | (5358,3447) | user-confirmed no dot |

Historical D6-V02 panels extended 110px left, 230px right, 65px above and
80px below each point, enlarged 1.5× without smoothing. Comparison markers
were described in the recovered review; those original annotated panels
are not claimed to have been recovered here.

## Off-sheet connections

No edge pads on this page; all four links are inter-sheet arrows:

| Label | Direction | Net here |
|---|---|---|
| OTHER CAR CON NO1 (D-7/7) | in | NO1 CV line (R103/R104, R95/R96, R87/R88) |
| OTHER CAR CON NO2 (D-7/7) | in | NO2 CV line |
| OTHER CAR SOUND NO1 (D-7/7) | out | IC12.7 OUT |
| OTHER CAR SOUND NO2 (D-7/7) | out | IC11.7 OUT |

Plus 12V (R108, R80, R82 tops) and GND symbols.

## What the page does (wiring-derived)

Each bank has three two-amplifier oscillator cells driven by its OTHER CAR
CON input. The cell-1 integrator output couples to the MC3340 CON2 node;
cell-2 and cell-3 outputs reach the audio bus through diodes, then couple
to MC3340 IN1. OUT7 returns to D-7/7. The different resistor/capacitor values
are recorded without claiming measured pitches, waveforms or gameplay
behavior. Both banks use the same three LM324 packages, with different
sections, and share the nominal 6 V reference network.

## Review evidence and closure record

The recorded continuation is the provenance for the corrected routes below;
only entries explicitly identified as user answers are attributed to the
user. This consolidation does not constitute a fresh visual inspection.

| Check | Recorded outcome | Status |
|---|---|---|
| D6-V01, R109 | User: `.33 K`; 330Ω, not R81's 3.3K | closed |
| D6-V02, six reference crossings | User: `none`; all six unjoined | closed |
| D6-V03, NO1 cell-3 collector resistor | User: `R84`; value 100K in trace | closed |
| NO1 cell-1 collector resistor | User: `no label, 68k` | closed; no designator invented |
| NO2 cell-3 lower divider | User: `no label, 51k` | closed; no designator invented |
| MC3340 pins, IC11 and IC12 | Recorded review: CON2, IN1, OUT7 | closed |
| Both cell-1 adjustment capacitors | Recorded review: 470P parallel to 6800P; no variable arrow | closed |
| NO2 cell-1 lower divider | Recorded review: R74 51K, IC10.12→GND | closed |
| Half-rail network | Recorded review: R82/R83 each 1K; C22 upper branch, C23 lower branch, both 100µ | closed |

Additional recorded crop locations:

| Box | Review subject |
|---|---|
| (1400,800,4300,2000) | NO1 output/control chain |
| (4350,700,7300,2050) | NO2 output/control chain |
| (2650,3950,3700,4800) | shared divider and C22/C23 |
| (4400,3250,5800,4100) | NO2 cell-3 input network |
| (2300,3450,2850,3850) | NO1 cell-3 resistor lettering |
| (3400,1150,3750,1500) | D6-V01, R109 |
| (2340,3520,2610,3760) | D6-V03, R84 |
| (2240,1320,2670,1910) | absent NO1 cell-1 resistor label |
| (4500,3390,5200,3910) | absent NO2 cell-3 resistor label |
| (2600,1100,3100,1650), (5150,1100,5650,1650) | upper reference-column endpoints |

## Remaining source limitations

1. **Manufacturer note**, `NS製の用`-like text: middle glyphs remain
   uncertain. Crop (4800,50,6100,250).
2. **Bottom-right corner stamp**, drawing number/date: unreadable in the
   recorded review. Approximate crop (8700,6050,9000,6150).

The two absent resistor labels are confirmed absences, not open visual
questions. All recorded D6 circuit-review questions above are closed.
Package supply or other pins not covered by the retained trace are not
newly inferred here. No waveform simulation or frequency measurement was
performed.

## KiCad comparison coverage

The comparison checkout used in the 1 November session was
`stonedDiscord/MonacoGP` at commit
`12e879b3f63b57536b461df947efa8aa86e69157`. The inspected Sound schematic
had 24 placed symbol instances and **zero wire objects**. It cannot provide
a connected-net comparison for these oscillator banks. This consolidation
makes no claim of a new export or a successful D6 netlist validation; the
missing connectivity does not override the recorded source readings.

## Spot check against the scan, 1 November (Claude)

Fresh crops (1400,700,4200,2000) and (4300,700,7200,2000) were compared with
the tables: both cell-1 oscillators (R103/R104/R102, C21 with the ADJ 470P,
the unlabelled 68K, TR9, D14, R105/R106/R107, R101; R75/R76/R74, C20, R72,
R77/R78), both output chains (C26, R108 10K, R109 .33K, IC12 CON 2/IN 1/OUT 7,
C27; C24, R80 10K, R81 3.3K, IC11, C25) and the arrows. All agree. The
whole-page structure at ×0.18 (three cells per bank, IC10/IC9/IC8 sections,
the diode buses, the R82/R83/C22/C23 half-rail and its two reference
columns) also agrees. No reading changed.
