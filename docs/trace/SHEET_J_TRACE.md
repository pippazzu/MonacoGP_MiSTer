# Sheet J — score display scan, data selection and LED wiring

Source: Sega **Monaco GP (420-0358)**, PDF page **22**,
manual 420-0358, PDF page 22, **10160 × 6624**.
SHA-256: `df8272b942f0271e5a1849a965b6f037cff82ba3c64a4a8877f651df5f50bf14`.

**The stored PNG is upside down.** Coordinates below use upright frame
**R**, obtained by rotating the stored PNG 180°. An R box `(x0,y0,x1,y1)`
is stored box `(10160−x1,6624−y1,10160−x0,6624−y0)`.

Assemblies, left to right: **MO-4202 DISPLAY LED BOARD ASS'Y**,
**96620-P SCORE DISPLAY MOTHER BOARD ASS'Y**, **96597-P SCORE DISPLAY IC
BOARD ASS'Y (D-1/3)**. The fraction is readable on the new title crop.
The connector table gives **G 44P, H 12P, J 80P, K 44P**. Circled J is the
sheet identifier, not a connector-pin label.

**Status, 1 November 2026:** consolidated detailed visual pass covering the
scan/address routes, eight row drivers, sixteen mux data sets, four
7448/75468 chains, all 28 segment resistors and their connector routes,
LED column mapping, timer branch, lamps and power. Remaining glyphs and
source omissions are explicit below. This replaces contradictory tentative
statements in the earlier pass; it is not a claim that every source label
is settled. No HDL was changed.

## Reading conventions

A separate dot, including an oval/slanted one, denotes a junction. Plain
crossings do not. Endpoint corners and branches are read separately from
crossings. Inputs with inversion circles and an AND-shaped body implement
NOR on this sheet; no input circles are discarded when describing them.

`part.pin` means a physical IC pin. `D0…D7` and `a…g` are signal/segment
names. Pinouts help identify the printed devices but do not create supply
connections or omitted pins. Circled **I/K/A** are off-sheet references;
**connector K** is a different object. An off-sheet signal does not acquire
a physical connector-K pin merely because its source circle says K.

**Clear** means directly readable or traceable in the source; **uncertain**
means a qualified candidate; **not drawn** means no connection can be
transcribed from this sheet. Source errors are retained literally.

## Source crop register (upright R)

| Box | Evidence |
|---|---|
| (3320,360,4770,1120) | counter, 2H gates, 2F decoder |
| (3620,340,5400,560), (5300,350,7250,640) | overlapping QA/QB/QC select buses |
| (2930,500,3610,3930) | circled-I V2, lamp supply, collectors, H common branches |
| (2900,1160,4690,2350), (2920,2300,4730,3740) | all NOR/inverter/row drivers |
| (4180,930,4720,3670) | eight separate 2F output descents and leftward corners |
| (6500,550,8550,1600), (6500,1850,8550,3230) | mux groups 1 and 2 |
| (6500,3310,8550,4560), (6500,4660,8550,5970) | mux groups 3 and 4 |
| (5740,570,6700,1720), (5670,1920,6700,3200) | decoder/driver groups 1 and 2 |
| (5650,3280,6700,4580), (5650,4720,6700,5960) | decoder/driver groups 3 and 4 |
| (4400,620,5830,3300), (4400,3150,5830,4600) | segment verticals, turns, driver supply rails |
| (1680,3800,4950,4820), (1680,4770,4950,5740) | 28 segment routes through K/J connectors |
| (1630,1310,2940,1720), (1630,2870,2940,3810) | upper/lower LED pin sets, missing positions |
| (2770,3370,4100,3870), (3500,3650,4170,4140) | H row commons and seven segment branches |
| (8300,570,9600,1840) | eight timer inputs and G/boundary pads |
| (1050,570,3100,1330) | lamp rails, six lamps, damaged pad labels |
| (8500,1870,9700,3910) | Vcc/GND pads and decoupling |
| (4400,5990,6750,6210) | 96597-P title and D-1/3 fraction |

All pin decisions were made on source-resolution crops, not the reduced
navigation image. The earlier extractor merged dense bundles; it was not
rerun or used as validation in this pass.

## 1. Scan counter and address distribution

The **V2** input is explicitly marked **circled I**, visible to the left of
the counter at approximately R(3300,920). This closes the old “unmarked,
perhaps sheet E” reading: the immediate reference is **I**.

| Device / section | Input connection | Output connection | Confidence |
|---|---|---|---|
| half 74393, printed `393/2`, designator **K9** | CP pin 1 ← V2 (I); reset pin 2 → ground | QA, QB, QC → 2H and select buses; QD not drawn | clear |
| 2H, 7408, 1/2 → 3 | 1 → Vcc; 2 ← QA | 3 → 2F.A pin 15 | clear |
| 2H, 7408, 13/12 → 11 | 13 → Vcc; 12 ← QB | 11 → 2F.B pin 14 | clear |
| 2H, 7408, 4/5 → 6 | 4 → Vcc; 5 ← QC | 6 → 2F.C pin 13 | clear |
| 2F, 7445 | A15/B14/C13 as above; D12 → ground | outputs 0…7 → row routes below | clear |

`K9` is retained literally, not transposed to `9K`. Counter output labels
QA/QB/QC are printed; their physical output pin numbers are not printed
beside those wires. The remaining counter half, 2H section, unused 2F
outputs and IC supply pins are not shown here.

QA/QB/QC also rise separately into the three eastward select buses:

| Counter net | Top bus, approximate R y | Mux select |
|---|---:|---|
| QA | 485, lowest | A, pin 11 |
| QB | 450, middle | B, pin 10 |
| QC | 420, highest | C, pin 9 |

These routes were followed across overlapping crops to the mux select
labels. The stacked mux drawing uses shared bus notation; it does not
separately repeat a complete set of select-pin wires at every interior
section. The bus-to-A/B/C pairing is clear; the drawing convention is not
an independently drawn set of 48 pin wires.

## 2. Eight row drivers and flash inputs

The eight 2F output wires descend separately and turn left in order. This
was followed visually for all eight, closing the former pattern-only
assignment. The two thick/thin supply rails crossed by these wires are
not row-strobe connections.

The NOR packages are **2E-2** (literal label, four sections here) and
**12E** (one section here), not five sections of a single 7402. The 7406
package is read as **1E**, also written outside the third-row triangle;
doubled strokes inside other triangles are not enough to rename it 11E.

In the NOR column below, the first input receives the strobe and the
second receives that row's `nTH FLASH` from **I**. All NOR symbols have
input circles; inverter outputs have circles.

| Row | 2F output / pin | NOR, input pins → output | 1E inverter input → output | Base resistor | Transistor | J collector pad | K row pads |
|---|---|---|---|---|---|---|---|
| 1ST | 0 / 1 | 2E-2, 2/3 → 1 | 3 → 4 | R29, 560Ω | TR1, TIP-125 | 30 | 22 / Z |
| 2ND | 1 / 2 | 2E-2, 5/6 → 4 | 1 → 2 | R30, 560Ω | TR2, TIP-125 | j | 21 / Y |
| 3RD | 2 / 3 | 2E-2, 11/12 → 13 | 5 → 6 | R31, 560Ω | TR3, TIP-125 | k | 20 / X |
| 4TH | 3 / 4 | 12E, 8/9 → 10 | 9 → 8 | R32, 560Ω | TR4, TIP-125 | l | 19 / W |
| 5TH | 4 / 5 | 2E-2, 8/9 → 10 | 13 → 12 | R35, 560Ω | TR5, TIP-125 | m | 18 / V |
| YOUR SCORE | 5 / 6 | none drawn | none drawn | R36, 560Ω | TR6, TIP-125 | 33 | 17 / U |
| 人中 | 6 / 7 | none drawn | none drawn | R33, 560Ω | TR7, **TIP-128** | 32 | 16 / T |
| 位 | 7 / 9 | none drawn | none drawn | R34, 560Ω | TR8, TIP-125 | 31 | 15 / S |

All routes and listed pin numbers are clear. The user confirmed TR7's
final type glyph as **8**, giving **TIP-128** (**J-V01**, 1 November 2026). Lowercase `j/k/l/m` are preserved as pad labels.
Each row-1…5 strobe has a separately drawn **RA 1K** pull-up to Vcc before
the NOR input. **Five** such elements are drawn; no corresponding RA
pull-up is drawn for rows 6–8. No individual RA section numbers are given.

Each 560Ω resistor lies between the logic output and the transistor base.
All eight emitters join the common **LAMP V** rail. Each collector goes
through its J pad to both listed K contacts and the corresponding LED
row common. Crossing the emitter rail does not short a collector to it.

Two additional branches are explicit:
**TR7 collector / J32 / K16,T → H.A**;
**TR8 collector / J31 / K15,S → H.1**.
These are row-common outputs, not additional transistor stages.

## 3. Sixteen 74151 data muxes

Each printed `151` uses D0…D7 pins **4,3,2,1,15,14,13,12**,
Y **5**, active-low ST **7**. The drawing grounds each ST. The
complementary output pin 6 and package supply pins are not drawn.
Y feeds the associated 7448 BCD input. Select buses are described above.

| Group | Bit A mux → decoder A7 | Bit B mux → B1 | Bit C mux → C2 | Bit D mux → D6 | Decoder |
|---|---|---|---|---|---|
| 1 | 6A.5 | 5A.5 | 4A.5 | 3A.5 | 2A |
| 2 | 6B.5 | 5B.5 | 4B.5 | 3B.5 | 2B |
| 3 | 6C.5 | 5C.5 | 4C.5 | 3C.5 | 2C |
| 4 | 6D.5 | 5D.5 | **printed 4A**, .5 | 3D.5 | 2D |

The user confirmed the group-4 bit-C label as **4A** (**J-V02**,
1 November 2026), duplicating group 1. Its location and route are
unambiguous. The literal reading is closed; an intended correction to
4D is not established. “Group-4 C mux, printed 4A” identifies this symbol
without conflating it with group 1.

The following table specifies all 128 data-input routes by substitution:
for each group g = 1…4 and each bit b = A/B/C/D, the four muxes above receive:

| Mux input | Physical pin | Group 1 | Group 2 | Group 3 | Group 4 | Immediate source |
|---|---:|---|---|---|---|---|
| D0 | 4 | 1ST-1b | 1ST-2b | 1ST-3b | 1ST-4b | K |
| D1 | 3 | 2ND-1b | 2ND-2b | 2ND-3b | 2ND-4b | K |
| D2 | 2 | 3RD-1b | 3RD-2b | 3RD-3b | 3RD-4b | K |
| D3 | 1 | 4TH-1b | 4TH-2b | 4TH-3b | 4TH-4b | K |
| D4 | 15 | 5TH-1b | 5TH-2b | 5TH-3b | 5TH-4b | K |
| D5 | 14 | P-1b | P-2b | P-3b | P-4b | I |
| D6 | 13 | T2-b | N-1b | N-2b | N-3b | A for T2; I for N |
| D7 | 12 | T1-b | R-1b | R-2b | R-3b | A for T1; I for R |

The K braces terminate after the fifth rank input. **P inputs belong to I
in all four groups**, correcting the old K/I-bracket ambiguity. This also
agrees with K carrying the five rank stores, not the player-score input.

### Timer input pads

All eight timer arrows carry circled **A**. The intermediate X-marked pads
are the J boundary contacts shown in the G-to-IC routes:

| Signal | G contact | J boundary contact | Destination |
|---|---|---|---|
| T2-A | D | 4 | 6A.13 |
| T1-A | E | D | 6A.12 |
| T2-B | F | 5 | 5A.13 |
| T1-B | H | E | 5A.12 |
| T2-C | M | H | 4A.13 |
| T1-C | L | 7 | 4A.12 |
| T2-D | K | F | 3A.13 |
| T1-D | J | 6 | 3A.12 |

For example G contact D is the source marking `GD`; J contact D is a
different pad. These are distinct from the circled sheet letters.

## 4. Four decoder/segment-driver chains

Each `48` (7448), 2A/2B/2C/2D, drives its matching `75468`,
1A/1B/1C/1D, as follows. All seven connections were inspected in each group.

| Segment | 7448 output | 75468 input | 75468 output |
|---|---:|---:|---:|
| a | 13 | 1 | 16 |
| b | 12 | 2 | 15 |
| c | 11 | 3 | 14 |
| d | 10 | 4 | 13 |
| e | 9 | 5 | 12 |
| f | 15 | 6 | 11 |
| g | 14 | 7 | 10 |

**2A RBI pin 5** is drawn as a bubble ending at the body, with no external
wire. RBI is **not drawn** on 2B/2C/2D. LT3 and BI/RBO4 are not drawn on
any of the four. There is no visible ripple-blanking chain to transcribe.
Package supply pins are also omitted on the 7448 symbols.

On all four 75468 symbols, the common emitter line exits **pin 8** and
joins the **LAMP RETURN** distribution rail. **Pin 9** joins the separate
**LAMP V** rail. These two rails can be followed back to the lamp block;
they are not relabelled logic GND/Vcc merely from standard device practice.

### All 28 series resistors and segment connector paths

Every resistor below is explicitly covered by **68Ω ×7, 1W** at its driver
bank. Path direction is driver output → resistor → connector **J** contact
→ connector **K** contact → LED segment column. Columns are physical
left/right positions in the source drawing, not inferred from net names.

| Group / physical column | Segment | Resistor | J contact | K contact |
|---|---|---|---|---|
| 1 / rightmost | a | R1 | 8 | A |
| 1 | b | R2 | J | 1 |
| 1 | c | R16 | 9 | B |
| 1 | d | R3 | K | 2 |
| 1 | e | R17 | 10 | C |
| 1 | f | R4 | L | 3 |
| 1 | g | R18 | 11 | D |
| 2 / second from right | a | R5 | M | E |
| 2 | b | R19 | 12 | 4 |
| 2 | c | R6 | N | 5 |
| 2 | d | R20 | 13 | F |
| 2 | e | R7 | P | 6 |
| 2 | f | R21 | 14 | H |
| 2 | g | R8 | R | 7 |
| 3 / second from left | a | R22 | 15 | J |
| 3 | b | R9 | S | 8 |
| 3 | c | R23 | 16 | K |
| 3 | d | R10 | T | 9 |
| 3 | e | R24 | 17 | L |
| 3 | f | R11 | U | 10 |
| 3 | g | R25 | 18 | M |
| 4 / leftmost | a | R12 | V | 11 |
| 4 | b | R26 | 19 | N |
| 4 | c | R13 | W | 12 |
| 4 | d | R27 | 20 | P |
| 4 | e | R14 | X | 13 |
| 4 | f | R28 | 21 | R |
| 4 | g | R15 | Y | 14 |

The last two paths, **R28/R15**, are **1D channels f/g**. The earlier
interpretation as two additional lamp-switch transistors is withdrawn.
The 75468 symbol encloses them with its other five channels.

## 5. LED matrix and H connector

The upper headings read **×1000, ×100, ×10, ×1** from left to right.
The segment routes establish, respectively, **group 4, group 3, group 2,
group 1**. The earlier group-1=×1000 assignment was reversed.

The first five rows use two drawn dual-digit packages per row. The
segment wires are ordered **g,f,e,d,c,b,a** from left to right in each
seven-wire vertical bundle. Pins in that order are:

| Package/position | g, f, e, d, c, b, a |
|---|---|
| left digit of each upper dual package | 17, 15, 2, 3, 1, 14, 16 |
| right digit of each upper dual package | 10, 12, 7, 6, 8, 13, 11 |
| lower single-digit notation | 8, 9, 1, 2, 3, 6, 7 |

Upper row commons are marked **4 and 5**, tied to the row contact pair.
The lower rows carry **5** with **(10)** beside the common; this alternative
printed notation is preserved without identifying an undrawn part model.
The lower pin numbering differs from the upper dual packages.

Rows 1ST…5TH and YOUR SCORE have four digits each. The **人中** and **位**
rows each have the leftmost three drawn positions and omit the rightmost,
as confirmed by the user on 23 October. This gives **30 on-sheet digits**.
Their left-to-right mux sources are now traceable:

| Row selection | Leftmost | Second | Third | Rightmost on LED board |
|---|---|---|---|---|
| 1ST…5TH | rank-4b | rank-3b | rank-2b | rank-1b |
| YOUR SCORE | P-4b | P-3b | P-2b | P-1b |
| 人中 / 2F output 6 | N-3b | N-2b | N-1b | no digit |
| 位 / 2F output 7 | R-3b | R-2b | R-1b | no digit |

`b` denotes the four BCD bits, not a segment letter here. The lower rows'
physical alignment is established; no separate numerical-weight labels
for those rows are invented.

The group-1 seven-segment bus also branches, at seven explicit dots, to
**connector H**. These are complete parallel branches, not a replacement
for the rightmost LED-board column:

| H contact | Connection |
|---|---|
| 2 | group-1 segment a, J8 / K.A |
| B | group-1 segment b, J.J / K1 |
| 3 | group-1 segment c, J9 / K.B |
| C | group-1 segment d, J.K / K2 |
| 4 | group-1 segment e, J10 / K.C |
| D | group-1 segment f, J.L / K3 |
| 5 | group-1 segment g, J11 / K.D |
| A | TR7 row common, selected alongside T2 inputs |
| 1 | TR8 row common, selected alongside T1 inputs |

Thus the two timer codes reach **H's segment/common interface** at scan
positions 6 and 7. The receiving display beyond H is not drawn on J; its
physical module layout is not claimed. This resolves the old contradiction
between timer mux inputs and the missing rightmost digits on the LED board.
H's other three contacts appear in the lamp block: **E** (user-confirmed
in J-V04), **6** and **F**, described below.

## 6. Lamps, power and passive inventory

**LAMP V**: G16, GT, G17, GU join a common rail feeding the six drawn
lamp symbols, the eight row-transistor emitters, and 75468 pin-9 rail.
**LAMP RETURN**: G18, GV, G19, GW join the other lamp rail and 75468 pin-8
rail. The lamp symbols bridge these rails in parallel. The caption is
`LAMPのPIN 12本`-like: twelve pins/terminals are indicated next to six
lamp symbols. It is not evidence of twelve lamp symbols.

Between G and those lamp rails are four parallel J contacts on each rail.
The user reviewed their labels in **J-V04**, 1 November 2026, and supplied
the following partial readings, preserved exactly. Question marks denote
unreadable text; they are not completed from connector-number patterns.

| Rail / group | Position, top to bottom | User reading | Status |
|---|---:|---|---|
| LAMP V / upper | 1 | `??4` | partial; full label unresolved |
| LAMP V / upper | 2 | `??` | unreadable |
| LAMP V / upper | 3 | `?35` | partial; full label unresolved |
| LAMP V / upper | 4 | `??` | unreadable |
| LAMP RETURN / lower | 1 | `?36` | partial; full label unresolved |
| LAMP RETURN / lower | 2 | `??` | unreadable |
| LAMP RETURN / lower | 3 | `?37` | partial; full label unresolved |
| LAMP RETURN / lower | 4 | `?8` | partial; full label unresolved |

These readings supersede the earlier tentative full-label candidates;
none of the eight is promoted to a settled connector assignment. Their
rail connections are clear despite the damaged lettering.

The user also confirmed **HE**, closing the separate H-contact reading:
**H.E → LAMP V**. **H6 and HF** clearly join LAMP RETURN. The unresolved
part of J-U4 is now limited to the eight intermediate J-pad labels.

Logic power is a separate drawn block:

| Net | G contacts | J contacts | Confidence |
|---|---|---|---|
| Vcc | 1, A, 2, B, 3, C | 1, A, 2, B, 3, C | clear, each group common |
| GND | 20, X, additional dashed contacts | 38, X, additional dashed contacts | named contacts clear; dashed continuation not fully labelled |

The second GND label on both connectors reads like **X** (GX, JX).
GX is free on G, but **J.X is already the group-4 segment-e contact**
(R14 → J.X → K13, read clearly at the J connector), so the GND label on J
is probably a different glyph (lowercase x, or a damaged numeral). It is
kept as printed and flagged; it does not affect the logic.

No wire on J establishes that the separately named LAMP RETURN is the
same node as this logic-GND block. That identity is not assumed.

Across Vcc/GND are **0.1µ ceramic capacitors**, repeated with a dashed
continuation and no fixed total quantity, plus **two 470µ, 6.3V electrolytic
capacitors** with positive side on Vcc. No C designators are printed.

Inventory from the drawing: R1…R28 = 28 segment resistors, 68Ω/1W;
R29/R30/R31/R32/R35/R36/R33/R34 = eight 560Ω base resistors; five drawn
RA 1K pull-ups; ceramic decoupling of unspecified count; two 470µ capacitors.
No trimmer or additional lamp-switch resistor pair is drawn.

## 7. Off-sheet interface summary

| Signals | Direction | Immediate reference |
|---|---|---|
| V2 | input to K9.1 | I |
| 1ST…5TH FLASH | inputs to the five NOR second inputs | I |
| 1ST-gb…5TH-gb, g=1…4, b=A…D | 80 mux inputs | K |
| P-gb, g=1…4, b=A…D | 16 mux inputs | I |
| N-1b…N-3b, R-1b…R-3b | 24 mux inputs | I |
| T1-A…D, T2-A…D | eight mux inputs, via G/J pads | A |
| H segments a…g plus two row commons | output interface | H connector; remote module not drawn |
| LAMP V / RETURN | supply interface | G contacts listed above |
| Vcc / GND | logic-power interface | G/J contacts listed above |

## 8. Remaining uncertainties and closed items

- **J-V01 — closed, user review, 1 November 2026.** Final character is
  **8**: TR7 is transcribed **TIP-128**. Crop R(3060,3020,3500,3190).
- **J-V02 — literal reading closed, user review, 1 November 2026.**
  The letter is **A**, so the group-4 C mux is printed **4A**. Its route
  to 2D.C is clear. The duplicate designation remains a source discrepancy;
  no intended replacement designator is established. Crop
  R(6910,5350,7350,5590).
- **J-U4 / J-V04 — partial user review, 1 November 2026.** Upper labels:
  `??4`, `??`, `?35`, `??`; lower labels: `?36`, `??`, `?37`, `?8`.
  Full assignments remain unresolved. **HE is confirmed**, settling
  H.E → LAMP V. The table above preserves the partial readings without
  guessing missing characters. Crop R(1850,630,2180,1330).
- **J-U5 — lower LED common notation.** `5 (10)` is retained literally;
  its part-specific meaning is not established by J. No invented module
  part number or extra pin connection is added.
- Counter `K9`, NOR `2E-2` and duplicate mux label are literal source
  designations; their intended board identities are not normalized.
- Omitted package power pins, unused sections, non-drawn blanking pins
  and dashed contact/capacitor quantities remain **not drawn**, rather
  than guessed connections.

Closed from the earlier pass: immediate V2 source I; QA/QB/QC-to-select
pairing; all eight strobe routes; separate NOR package 12E; absence of a
drawn RBI chain; segment-group/physical-column map and H timer interface;
P inputs from I; timer pad pairings; title D-1/3. The user's confirmed
rightmost omissions are retained. The invented extra lamp-driver pair
has been removed.

## 9. KiCad comparison — refreshed 1 November 2026

Read-only reference: `stonedDiscord/MonacoGP`, commit
`12e879b3f63b57536b461df947efa8aa86e69157` (7 February 2026).
The repository contains Main, Video, Sound and LED projects. There is no
96597-P score logic or 96620-P motherboard project, so it cannot check
J's counter, muxes, NORs, row transistors or decoder/driver wiring.

`LED/LED.kicad_sch` has **25 placed symbol instances**: 22 digit packages
and three connectors, with 111 wire objects. Values are DA04-11CGKWA,
ELD-426SYGWA and Conn_01x12. This is a partial display-module redraw with
modern digit symbols, not a complete netlist of J. Wire counts do not
establish completion or connectivity equivalence.

The earlier 23 October exported-netlist review found dual-digit commons
on pins 4/5 and shared row commons in agreement with J, but an approximately
32-digit redraw arrangement versus the scan's 30 on-sheet digits, including
an extra two-digit group. That historical comparison is retained as such;
no new netlist export was performed in this pass. The source and the user's
visual confirmation are strong evidence for the 30-digit layout. Most
segment wiring is absent from the redraw, preventing a complete connector
or segment-pin cross-check. Modern substitute package pin numbers also
cannot establish the original module pinout without a part mapping.

KiCad remains a trusted comparison where it actually contains a circuit;
its missing score-board logic supplies no evidence to establish an intended
correction to the duplicate 4A designation or to override the literal source
routes above. J-V01 and the literal reading in J-V02 were settled by the
user's visual review, not by KiCad.

## Review against the scan — 1 November 2026

This consolidated trace (prepared with ChatGPT, user readings J-V01…J-V04)
was checked on fresh crops of the 180°-rotated `page22-sheet-J-score.png`
by a second reader. The first pass is kept unchanged as the working notes (not published);
the review crops and their coordinates are in the working notes (not published).

Confirmed on the scan:

- Scan core: V2 arrow from circled **I**; 2H 2→3 (QA), 12→11 (QB),
  5→6 (QC), other inputs on Vcc; 2F A15/B14/C13, D12 grounded.
- Select buses: the three buses were followed by pixel profile from the
  counter (R x 3900) to 6A (R x 7000) without crossing. QA is the lowest,
  QB the middle, QC the top; at 6A they land on pins 11, 10, 9, printed
  "A B C" in the drafter's hand (A looks like 9, B like 8).
- Strobes: the eight 2F output verticals (R x ≈ 4269…4488 in pin order
  1,2,3,4,5,6,7,9) end one by one from the left, top row first, with no
  crossing between them, so output n drives row n+1.
- Rows: NOR and 7406 pins as tabulated, including 1E 1→2 on row 2 (the
  "2" is written like a 3) and the separate **12E** on row 4; RA 1K only
  on rows 1–5; TR7's caption is written "TIP-12B" (the 8 in the
  drafter's B-like form). TIP-128 is not a type in the standard
  TIP120–127 Darlington family; TR7 has the same PNP symbol as the other
  seven, so the reading has no effect on the logic.
- Mux inputs: in group 2 the K brace covers 1ST…5TH only and the I brace
  covers P, N and R; group 1 has a separate circled I at P. Timer pads
  T2-A 4/GD, T1-A D/GE, T2-B 5/GF, T1-B E/GH, T2-C H/GM, T1-C 7/GL,
  T2-D F/GK, T1-D 6/GJ, all circled A.
- Decoder chains: groups 1–4 read in full (mux Y → 7448 A/B/C/D, 7448
  a–g → 75468 1–7, outputs 16–10 → the resistor names tabulated). Group
  4's bit-C mux is printed 4A. Only 2A shows the RBI bubble, unwired.
- 75468 rails: pin 8 joins the thick rail that comes from the LAMP RETURN
  lamp rail; pin 9 joins the thin rail that leaves the transistor-emitter
  (LAMP V) vertical at a dot. LAMP RETURN crosses that vertical without a dot.
- Segment routes: the J-connector groups lead to the driver banks in
  nested order (8…11 → group 1 R1…R18, M…R → group 2, 15…18 → group 3,
  V…Y → group 4), straight across to K, and the K groups lead to the LED
  columns right to left. Group 1 is therefore the **×1** column and
  group 4 the **×1000** column, as this trace says. Sheet I's RTL
  (`jtmonacogp_score.v`) independently takes P-1 as the units digit.
- H connector: dots H2/HB/H3/HC/H4/HD/H5 on group-1 segments a…g; H.A
  from TR7's collector, H.1 from TR8's.

Two counts support the contact readings. K (44P) uses 1–22 and the 22
letters A–Z without G, I, O, Q exactly once: 28 segment contacts
(1–14, A–R) and 16 row contacts (15–22, S–Z). H (12P) uses all twelve:
seven segments, two row commons, E (LAMP V), 6 and F (LAMP RETURN).

Consequences for the design (no HDL in this change): the timer digits
reach the separate display behind connector H at scan positions 6 (T2,
TR7, H.A) and 7 (T1, TR8, H.1). Sheet A's logic gives T2 = IC20 = tens
and T1 = IC21 = units, which matches the core's present `t_tens`/`t_units`
wiring. Sheet I's R-1…R-3 buses, whose destination letters were uncertain
in the sheet I trace, arrive here under the circled-I brace with N and P.
