# Sound sheet D-1/7 — slip-zone sound oscillator

Source: Sega **Monaco GP (420-0358)**, PDF page **15**, board **96598-P**,
sheet **D-1/7**. Drawn titles: "SLIP ZONE SOUND" (top), "96598-P (D-1/7)
OSCILLATOR" (bottom). Transcribed from the supplied
manual 420-0358, PDF page 15, **3328 × 2560** pixels, **300 dpi** (half the
resolution of the logic sheets), stored upright. Source PNG SHA-256:
`12a8b3cddf641a3193074c3721b3eaa7f373acaaf8d07b5b3b7c08ca7e0b282c`.

**Status: complete whole-page transcription.** Reviewed against the scan
on 31 October (Claude, full-resolution crops (1760,860)-(2300,1480) and
(2060,440)-(2420,880)): every route below is confirmed, and the two items
the transcription left open are settled (see "Review, 31 October" at the
end): C63 is the timing capacitor from IC53 pin 9 to ground, so the lower
block is an op-amp relaxation oscillator; IC56 is a 7416 section.
Read **visually from zoomed crops only** — the netx extractor and the
600-dpi dot calibration were not used on this 300 dpi page; junctions were
judged by eye on 2× crops, which these sparse analog nets allow. Component
values are transcribed as printed; uncertain glyphs are marked and listed
under Unresolved. The latest available stonedDiscord sound schematic was
checked on31 October:19 placed components,107 single-node unconnected nets,
and no connected nets. It cannot verify this circuit; see the comparison
record at the end. The user-authorized policy of trusting KiCad unless
strong contrary evidence exists applies where KiCad actually supplies wiring.

## Reading conventions

- Coordinates are pixels of the supplied PNG.
- The quad op-amp is drawn as four separate triangles each marked "53"
  (IC53), with "LM324" written beside each; pin numbers follow the LM324
  pinout and are printed on the drawing.
- Japanese dielectric notes: ケミ (electrolytic), マイラ (mylar), タン
  (tantalum), セラ (ceramic). Readings of these small glyphs are best-effort
  and flagged when doubtful.
- `node A` is a local alias for the filter's input summing node.

## Crops used

| Box | Contents |
|---|---|
| (0,0,3328,2560) ×0.42 | overview |
| (100,250,1250,900) ×2 | noise input, C68, R345/C105/R350, R349 |
| (950,250,1750,900) ×2 | IC53 amp 1, C70/C71/R348, 6V note |
| (1600,350,2520,850) ×2 | IC53 amp 2, R346/R347, 4016, R352 |
| (2350,330,3328,850) ×2 | R353/R354/C73, output arrow |
| (750,850,2100,1400) ×1.6 | TR (2SC458), R343/R308, IC53 amps 3 and 4 |
| (1850,850,2750,1450) ×2 | R309/R307/R351/C63, VR7 |
| (200,1350,2300,1850) ×1.5 | J pad, R312, IC56 driver, control run |

## Blocks and connections

### Noise input

| Item | Connection | Confidence |
|---|---|---|
| Off-sheet line, left edge | Arrow pointing off-left, labelled "S2688ヘ / noise OSC / (D-4/7)" | clear |
| C68 1µ (ケミ) | couples that line into R34510K (designator user-confirmed D1-V04) | clear route |
| R34510K | → node with C1050.1µ to GND, note マイラ (mylar) | clear; designator user-confirmed D1-V04 |
| R350 10K | → **node A** | clear |

The S2688 oscillator on sheet D-4/7 supplies this input: the existing
[D-4 trace](SOUND_D4_TRACE.md#block-1--s2688-noise-source) follows IC62
output3 to the SLIP ZONE SOUND feed. The off-page arrow and ヘ caption name
the other end, not an electrical output driver on D-1. This closes U1.

### Band-pass filter — IC53 amp 1 (pins 2−, 3+, out 1)

| Item | Connection | Confidence |
|---|---|---|
| C71 0.022µ (マイラ) | node A → pin 2 | clear |
| C70 0.022µ (マイラ) | node A → output node (via the top run) | clear |
| R348 220K | pin-2 node → output node | clear |
| R349 100Ω | node A → TR collector (see servo block) | clear |
| pin 3 (+) | → rail marked "6Ʋヘ" (to 6 V), shared with amp 2 pin 5 | clear |
| out (pin 1) | → C69 2.2µ → R347 33K → amp 2 pin 6 | clear |

A multiple-feedback band-pass on the noise; R349+TR shunt node A, varying
the response under servo control.

### Gain stage — IC53 amp 2 (pins 6−, 5+, out 7)

| Item | Connection | Confidence |
|---|---|---|
| R347 33K | C69 → pin 6 | clear |
| R346 100K | pin 6 → out 7 | clear |
| pin 5 (+) | 6 V rail | clear |
| out 7 | → 4016 (IC54) pin 1 | clear |

### Gate and output — IC54 (printed "4016", box marked "54", in=1, out=2, ctl=13)

| Item | Connection | Confidence |
|---|---|---|
| pin 1 (in) | ← amp 2 out 7 | clear |
| pin 13 (ctl) | ← node: R352 10K up to 12V (the 12V leg is drawn dashed), and the control run from IC56.6 | clear |
| pin 2 (out) | → node: R353 51K → 12V, R354 51K → GND, C73 2.2µ (ケミ) → arrow "SLIP ZONE SOUND (D-4/7)" | clear |

### Enable input — bottom edge

| Item | Connection | Confidence |
|---|---|---|
| Pad J (hatched square), label "SLIP ZONE" | ← off-board; R312 470Ω pull-up to **Vcc** (5 V rail symbol, distinct from the 12V marks) | clear |
| IC56 section 5 → 6 (7416: "16" printed below is the type) | Pin 5 ← J-pad line; pin 6 → IC54.13 / R352. Open-collector inverter (the input circle is the inversion mark, the output mark is the numeral 6); R352 is its pull-up to 12 V | clear |

R352 connects the control node to12V. A small “16”-like caption is visible
below IC56, contrary to the earlier statement that no type mark exists.
The user says output mark B “looks more like a6”; this supports reading
it as a pin numeral, leaving the input circle as the inversion mark.
Retain that qualified reading under U5 rather than declaring two active
circles. The full part type and final output-glyph interpretation remain
qualified; no unwired KiCad placeholder resolves them.

### Level/modulation servo — IC53 amps 3 (9−, 10+, out 8) and 4 (13−, 12+, out 14), TR

| Item | Connection | Confidence |
|---|---|---|
| TR, type **2SC458** (label "C458", designator mark reads "TRA") | collector ← R349 (node A); emitter → GND; base ← node {R343 10K → GND, R308 10K ← amp 4 out 14} | clear |
| VR7 "20K VR" | across 12V (top) and GND (bottom); wiper → R351 1K → amp 3 pin 10 (+) | clear |
| C63 22µ (タン) | Top plate ← the pin 9 / R309 / follower pin 12 vertical; bottom plate → GND. The plate tips brush the separate pin 10 / R307 riser without dots; they are drafting overlaps (see Review) | clear |
| R307 100K | Left end ← amp 3 output 8; right end → riser → pin 10 node (dot), with R351 | clear |
| R309 10K | Left end ← amp 3 output 8; right end → vertical: pin 9 (dot), the upper loop to amp 4 pin 12, and down (crossing the pin 10 wire without a dot) to C63's top plate | clear |
| amp 4 | pin 13 (−) looped directly to out 14 (unity follower); out 14 → R308 | clear |
| Annotations | "1.8∼" at the wiper area; "2.2Ʋ"/"1.8Ʋ" voltage notes right of VR7; a faint note near the control run reads like "12Hᴢ 小" | as drawn (U4) |

**Behaviour.** Amp 3 is an op-amp relaxation oscillator: R309 charges and
discharges C63 (10 kΩ × 22 µF) on the inverting input, and R307 with R351
gives hysteresis around VR7's wiper on the non-inverting input (the
"1.8~", "2.2V", "1.8V" notes are the wiper's range). Amp 4 buffers C63's
ramp; through R308 and the 2SC458 it periodically shunts the band-pass
filter's input node through R349, so the filtered noise warbles. The rate
depends on VR7; the faint note near the control run, read like "12 Hz",
may be the design target and is not used.

## Components and values

| Ref | Value / type | Role |
|---|---|---|
| C68 | 1µ ケミ | noise input coupling |
| R345 | 10K | input series; corrected from R315 by user D1-V04 |
| C105 | 0.1µ マイラ (mylar), re-read31 October | input shunt to GND |
| R350 | 10K | into node A |
| C71, C70 | 0.022µ マイラ each | band-pass |
| R348 | 220K | band-pass feedback |
| R349 | 100Ω | node A → TR |
| C69 | 2.2µ | interstage coupling |
| R347 | 33K | amp 2 input |
| R346 | 100K | amp 2 feedback |
| IC53 | LM324 (printed) | four amps as above |
| IC54 | 4016 (printed) | analog switch |
| R352 | 10K | ctl pull to 12V |
| R353, R354 | 51K each | output re-bias divider |
| C73 | 2.2µ ケミ | output coupling |
| R312 | 470Ω | J-pad pull-up to Vcc |
| IC56 | 7416, section 5 → 6 | switch-control driver (open collector, R352 pull-up to 12 V) |
| TR | 2SC458 ("TRA") | node-A shunt |
| R343 | 10K | base–GND |
| R308 | 10K | base drive |
| VR7 | 20K VR | level/threshold trimmer |
| R351 | 1K | wiper series |
| C63 | 22µ タン | oscillator timing capacitor, pin 9 to GND |
| R307 | 100K | servo feedback |
| R309 | 10K | servo feedback |

## Off-sheet labels

| Label | Where | Direction |
|---|---|---|
| "S2688ヘ noise OSC (D-4/7)" | left edge arrow | noise input from D-4 IC62.3; U1 closed by existing D-4 trace |
| "SLIP ZONE SOUND (D-4/7)" | right edge arrow | out, to the mixer sheet |
| "SLIP ZONE" | pad J, bottom left | in, from the game logic (sheet A area signal /SLIDE-related naming not assumed) |
| "6Ʋヘ" | amp bias rail | to the 6 V rail (generated off-page) |
| 12Ʋ marks ×4, Vcc mark ×1, GND symbols | supplies | |

## Unresolved

1. **Noise-line direction — closed.** The existing D-4 trace establishes
   IC62 output3 as this input's source. No new user check required.
2. **C105 dielectric — re-read.** The note reads マイラ (mylar) in source
   box(620,430,980,780). Value0.1µ and designatorC105 retained.
3. **Servo feedback topology — closed (31 October review).** C63 is from
   the pin 9 node to ground, R307 from output 8 to pin 10: an op-amp
   relaxation oscillator. Earlier notes: R307 and R309 both start at output8.
   R309's far-end vertical has a dotted branch at pin9 and an upper loop
   into follower input12. D1-V02 confirms no junction dot where this
   vertical crosses pin10's horizontal wire; that crossing is unjoined. The contacts/overlaps near the C63 plates and R307
   right end remain unresolved separately; do not let one crossing answer
   settle the entire capacitor circuit. Previous C63=pin10-to-ground
   assignment is no longer a clear reading.
4. **Faint annotation and voltage notes.** The “12Hz”-like note and
   2.2V/1.8V-like annotations remain qualified; no frequency inferred.
5. **IC56 symbol/type — closed (31 October review).** "16" is the part
   type (7416), the drafter's convention on the other sheets; the input
   circle is the inversion mark. Earlier notes: Small caption below the gate reads16-like.
   Input5 has a circle. For the ring-like output mark B, the user says
   “looks more like a6.” Adopt this as the favoured glyph reading: a pin
   numeral rather than an active output circle. The input circle then
   indicates inversion. Preserve the user's qualification; the16-like
   caption supports but does not independently prove the output reading.
6. **Transistor designator.** TypeC458 is clear; the designator is TRA-like,
   with TR9 retained as an alternative. No guessed physical pin numbers.
7. **Undrawn pins.** IC53 supplies4/11 and IC54/IC56 supplies and unused
   sections are not drawn here; no power connection or unused status is
   invented from the conventional package pinout.
8. **KiCad comparison — inspected, coverage absent.** See below.
9. **Input resistor designator — closed.** User D1-V04 confirms **R345**.
   Corrected the earlier R315 reading throughout the current tables.
   Value10K and the C68-to-C105/R350 route are retained.

## Continuation and source audit — 31 October 2026

Work starts from current repository main d9eb3b8, after fetching all
GitHub branches. This is a continuation of the existing D-1 trace.
Original page15 has3328×2560 pixels, stored upright; the source hash
above was verified. All new boxes use that stored frame, no rotation.
Nearest-neighbour enlargement is for inspection only. No image-generation
reconstruction, threshold changes or inferred line repair was used.

### KiCad availability

Latest remote HEAD of stonedDiscord/MonacoGP checked31 October:
`12e879b3f63b57536b461df947efa8aa86e69157`. Exported
`Sound/Sound.kicad_sch` with kicad-cli outside this repository. The XML
contains19 components and107 one-node nets named unconnected; zero nets
have more than one node. IC53/54/56 and this page's resistor/capacitor
network are absent. Thus it supplies no circuit comparison for D-1.
This is missing redraw coverage, not evidence that the sound-board pins
are physically open. No placeholder value or unwired symbol is adopted.

### Pin summary for the unresolved lower stages

| IC / pin | Reading | Confidence |
|---|---|---|
| IC53.8 | Output; branches to R309 left and R307 left | clear |
| IC53.9 | Inverting input; dotted branch into R309 far-end vertical / follower12 loop | clear local branch; U3 additional joins uncertain |
| IC53.10 | Non-inverting input; horizontal to R351, dotted south branch to R307 right end, passing C63 plate edges | clear wire route; D1-V03 extra contacts uncertain |
| IC53.12 | Non-inverting follower input; upper loop to R309 far-end vertical | clear local route; U3 crossed nets uncertain |
| IC53.13 | Inverting follower input; loop to output14 | clear |
| IC53.14 | Output; loop to13 and wire to R308→transistor base network | clear |
| IC56.5 | J-pad line, via the drawn input circle | clear endpoint; polarity U5 |
| IC56.6 | IC54 control13/R352 lower end | clear endpoint; polarity U5 |

### Human review queue

**D1-V01 (answered; qualified glyph reading):** user: **“B looks more
like a6.”** Record B as a likely output-pin numeral rather than a second
active circle. Input A remains the visible inversion circle. This supports
inversion; it is not a definitive user claim about the full device type.

**D1-V02 (closed):** user: **“no junction dot on red A.”** The pin10
horizontal and pin9 vertical are unjoined at A, near(2087,1182). The green
reference is a separate known dot. This does not classify the capacitor-plate
contacts below A or settle the entire lower-stage topology.

| Evidence | Stored PNG crop |
|---|---|
| D1-V01, IC56 symbol and small caption | (1150,1680,1390,1880) |
| D1-V02, lower-stage crossing and C63 context | (1920,1010,2230,1380) |
| D1-feedback, full lower amplifier context | (1400,820,2460,1490) |
| D1-input-cap, C105 note | (620,430,980,780) |
| D1-input-resistor, designator U9 | (480,420,760,650) |
| D1-transistor, designator U6 | (770,980,1210,1260) |

**Boundary:** D1-V01 is answered with a qualified numeral reading and
D1-V02 is closed. D1-V03/V04 below address the separate C63 plate contacts
and input resistor designator. Retain the existing established
filter/gain/switch/output routes. Other sound sheets retain their existing progress;
this continuation does not assert they have been re-audited.

Compared KiCad file SHA-256: `7b42c8c28edfaf56ebb738a23d5477372f823f622d5e515e462b3f76dcfcb1e8`.

### Next bounded reading — C63 contacts and input resistor

Followed the R307 right-end wire along the left riser to the dotted
pin10/R351 branch. It remains continuous through the region of both C63
plate edges. Independently, the capacitor's central upper lead follows
the pin9/R309 vertical and its lower lead reaches the ground symbol.
Those route observations are recorded above. The extra connections at the
plate edges remain unresolved, so no short between the two amplifier inputs
or across the capacitor is inferred from overlapping ink.

**D1-V03 (closed as a dot observation):** A≈(2048,1265), B≈(2045,1310),
where the C63 plate shapes meet the left riser. User: **“no dots”** —
no distinct filled junction mark at either A or B. The green reference
is the known pin10 branch dot near(2051,1180). D1-V02's separate crossing
above A remains unjoined; it was not re-asked.
A dot observation at these plate-edge contacts must be recorded separately
from the interpretation of whether a capacitor plate is electrically joined.
If the scan remains ambiguous, leave the extra connections unresolved.

**D1-V04 (closed):** user reads **R345**. Correct the former R315
designator. The10K value and C68→R345→C105/R350 node route are retained.

| Evidence | Stored PNG crop |
|---|---|
| D1-V03, C63 edge contacts and known dot | (1990,1150,2200,1410) |
| D1-V04, input resistor numeral | (540,450,780,630) |

The source hash remains unchanged. Unannotated source crops and coordinate
metadata are saved with the working evidence; enlarged question images
use nearest-neighbour scaling and outlines around the inspected points.
D1-V03 and D1-V04 are answered. The absence of dots at the plate-edge
contacts is recorded; no extra electrical tie or short is adopted from
the overlapping capacitor shapes. Exact interpretation of this drafting
overlap remains qualified under U3; do not repeat the answered dot checks.

## Review, 31 October 2026 (Claude)

Checked against manual 420-0358, PDF page 15 (hash as above) on
full-resolution crops. All routes in the tables are confirmed, including
R345 (10 kΩ), the 12 V leg of R352 (its dashed line crosses the 4016 input
wire without a dot and ends on R352), and the 2SC458 with R343 and R308.

- **C63 (U3).** C63's top plate hangs from the vertical that joins pin 9,
  R309's right end and follower pin 12; its bottom plate goes to ground.
  R307's right end rises on a separate wire to the pin 10 dot. The plate
  tips brush that riser with no dots (D1-V03). Read as joins, the top plate
  would tie pins 9 and 10 together and the bottom plate would ground pin 10,
  which would disable the stage; they are drafting overlaps. Result: the
  standard op-amp relaxation oscillator described under the servo block.
- **IC56 (U5).** "16" below the gate is the type, as on sheets C and M
  ("16" over a triangle = 7416). With R352 as the open-collector pull-up to
  12 V the 5 V gate drives the 4016's control at 12 V. The SLIP ZONE pad
  idles high through R312 (switch off); when the logic pulls it low, the
  7416's output lets go, R352 lifts IC54.13 and the slip-zone sound passes:
  the pad's signal is active low.
- **"S2688へ".** へ ("to") names the other end; the line is the noise input
  from the S2688 on D-4, as the transcription concludes.
