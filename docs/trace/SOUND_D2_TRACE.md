# Sound sheet D-2/7 — rescue-car siren and back-car sound oscillators

Source: Sega **Monaco GP (420-0358)**, PDF page **16**, board **96598-P**,
sheet **D-2/7**, titled on the page "Ⓢ - MONACO GP", "96598-P (D-2/7)
OSCILLATOR", with a circled "RESCUE CAR" note and "OP AMP LM324".
Transcribed from `sheets/page16-sound-D2.png`, **10176 × 6624**, 600 dpi,
stored **upright** (START_HERE's 180° note does not apply to the stored
file). Source PNG SHA-256:
`56b9a4a820137e3ddc3604be68bae7c874136b0a80bd71cb23499547f033a56e`.

A parts inventory is printed on the sheet itself (bottom centre):
**LM324 ×4, 555 ×1, MC3340 ×2** (the attenuator ICs read **MC3340**, not
MC3390). Supply rails drawn: 12V, Vcc (only at the /RESCUE input pull-up),
GND, and a **6V reference arriving from sheet D-5/7** (two arrows marked
"6V (D-5/7)").

**Status: whole-page transcription.** Reviewed against the scan on
31 October (Claude): the steering sub-network, both MC3340 audio inputs,
the VCO around IC40 and the wail comparators are now pin-traced, and most
unresolved items are closed; see "Review, 31 October" at the end, which
takes precedence over the earlier tables where they differ. As on sheet D-1, the netx
extractor was not used — analog pages trace reliably by eye from 1.2–3×
crops; junction calls here are visual only.

## Reading conventions

- Coordinates `(x, y)` in the stored PNG. `ICn.p` = IC n pin p.
- Op-amp sections are named by their drawn pin triples (LM324: out/−/+ =
  1/2/3, 7/6/5, 8/9/10, 14/13/12).
- Values are copied as printed ("µ" is written M/µ; ケミ = electrolytic,
  タンタル/タン = tantalum).

## Crops used

| Box | Contents |
|---|---|
| (0,0,10176,6624) ×0.14 | overview |
| (1700,1450,3100,2550) | comparator IC42 (9,10→8), 12V divider |
| (2950,1450,4000,2600) | IC42 latch pair (13,12→14 / 2,3→1) |
| (1550,2400,3200,3000) | /RESCUE input, R278, R280, TR15 |
| (2950,2550,4300,3700) | TR15 type, rails, IC43.13/12 entry, R252/R255 |
| (1550,2850,3000,3600) | D17/D18 steering, C53/C54, integrator IC42 (6,5→7) |
| (4200,2550,5600,3350) | R257/R256 divider, IC43 (6,5→7), R288/R259 |
| (5500,2550,7000,3400) | D19/D20, R291/R290, C56/C57, IC44 integrator |
| (3850,3280,4800,3900) | C55, R253, steering node Q |
| (3050,3500,4150,4200) | IC40 (9,10→8), MC3340 #1 (IC41), C52 |
| (5600,3300,7050,4000) | R264/R263/R260 divider, y≈3790 audio rail |
| (6350,3750,8000,4450) | IC44 follower (9,10→8), R262, MC3340 #2 (IC45) |
| (7950,3950,9200,4500) | C58, R292/R293, IC44 (6,5→7), C60, FRONT RESCUE |
| (1500,4350,3100,5400) | 555 (IC39) astable, D15, R230 |
| (3000,4350,4800,5400) | IC40 integrator + Schmitt, TR16, 6V arrows |
| (4600,4350,6400,5450) | IC40 output amp, C50, back-sound outputs |

## Block 1 — rescue enable (TR15)

| Item | Connection | Confidence |
|---|---|---|
| pad P "/RESCUE CP" | left edge (≈1560,2700), square pad lettered P; the label matches the logic sheets' /RESCUE CP | clear |
| R278 4.7K | from the input line up to **Vcc** (the page's only Vcc symbol) | clear |
| R280 2.2K | input line → TR15 base | clear |
| TR15 | type **C458** (2SC458), emitter → GND | clear |
| TR15 collector | → R281 10K → the latch reference node (IC42.3 node, which also carries R243 10K to 12V) | clear |

With the input high TR15 pulls the latch reference low and the siren
generator is held; the divider R243/R281 (10K/10K to 12V) gives ≈6V when
TR15 is off.

## Block 2 — rescue siren function generator (IC42 = LM324)

| Section | Connection | Confidence |
|---|---|---|
| Comparator 9−,10+→8 | +10 ← R247 1K ← node of 12V divider R249 1.2K / 3.3K (lower designator not readable); R246 100K positive feedback 8→10; −9 ← triangle rail (y≈2985); out 8 → R248 10K → node X | clear |
| Node X | R242 10K pull-up to 12V; → +12 of latch A | clear |
| Latch A 13−,12+→14 | −13 ← R241 1K ← latch B out 1 (cross-coupled); feedback R240 100K (13→14) | clear |
| Latch B 2−,3+→1 | −2 ← R245 1K ← latch A out 14 (cross-coupled); feedback R244 100K (2→1); +3 ← node {R243 10K→12V, R281 10K→TR15.c} | clear |
| Integrator 6−,5+→7 | −6 ← node M; +5 ← 6V rail (arrow "6V"); feedback from out 7 to node M through **C53 + C54 in series, back-to-back, 33µ ×2** (caption "⟨…⟩ 33M X2", first word unreadable) | caps clear, caption word uncertain (U3) |
| Steering | node L ← y≈3105 rail ← latch A out 14 (vertical x≈3790); L → D18 (MA150) → **R283 51K** → M; L ← D17 (MA150) ← **R282 82K** ← M ("MA150 ×2" printed) | clear |
| Output | out 7 → y≈2985 rail → comparator −9 and east → IC43.13 | clear |

Asymmetric 51K/82K charge paths give the two siren slopes; the latch pair
(gain −100 each) flips the steering node between rails.

## Block 3 — wail (slow) generator (IC43 latch + IC44 integrator)

| Section | Connection | Confidence |
|---|---|---|
| IC43 13−,12+→14 | −13 ← siren triangle rail; +12 ← R251 1K ← 12V divider R252 6.8K / R255 4.7K (oval mark near the node reads "(6V)"?); out 14 → R253 100K and **C55 0.68µ タン(tantalum)** into the steering node Q region | R251/R254 designators partly uncertain (U4) |
| Node Q region | C55 bottom → node with R251? 10K (down), D32? diode (down), R284 10K (down) — pin-level routing not finished | uncertain (U4) |
| IC43 6−,5+→7 | −6 ← R288 1K ← node N; feedback R259 100K (6→7); +5 ← node N (R257 10K to 12V / R256 10K down = 6V divider) | clear |
| IC43 9−,10+→8 | the cross-coupled partner below: −9 ← R257 1K ← IC43.7 (the X crossing); feedback 100K (9→8); +10 ← node {R258 10K to 12V, R259 10K to IC44.14}; out 8 → R288 1K → −6 (other leg of the X) | clear (review) |
| IC44 2−,3+→1 | integrator: −2 ← P′ rail; +3 ← arrow "**6V (D-5/7)**"; feedback **C57 + C56, タンタル 47µ ×2** back-to-back from out 1 to node P | clear |
| Steering | out-7 node → D20 (MA150) → **R291 10K** → P; → D19 (MA150? type glyph could read MA50/MA80) ← **R290 220K** ← P′; P–P′ joined | D19 type uncertain (U6) |
| Post-divider | out 1 → R264 8.2K → node → R263 3.3K → GND; node → R260 1K → east toward R258 (untraced) | tail uncertain (U7) |

Fast-rise/slow-fall wail ramp: 10K vs 220K steering into 23.5µ effective
integration.

## Block 4 — attenuator chain to FRONT RESCUE (IC41, IC45 = MC3340; IC40, IC44 sections)

| Item | Connection | Confidence |
|---|---|---|
| IC40 9?,10?→8 | buffer/amp near MC3340 #1; inputs carry R237 100K / R236 51K from the wail-ramp region (not pin-traced); out 8 → vertical → **MC3340 #1 (IC41) pin 2 "CON"** | inputs uncertain (U8) |
| MC3340 #1 (IC41) | box marked "MC3340", pins used: 2=CON, 7=OUT, bottom "IN" (riser not traced); OUT 7 → **C52 2.2µ ケミ** → audio rail y≈3790 east | IN source untraced (U9) |
| Audio rail | y≈3790 across the sheet; at (7075,3800) → R2⟨6⟩9? 1K? → riser x≈7355 (digit and value partly unread) | uncertain (U10) |
| IC44 9−,10+→8 | voltage follower (direct 8→9 feedback); +10 ← R262 100K ← riser from the audio-rail region, plus 51K (R265?) to GND | tap point unverified (U10) |
| MC3340 #2 (IC45) | 2=CON ← IC44.8; 7=OUT → C58; bottom IN ← riser from below (untraced) | IN source untraced (U9) |
| Output amp IC44 6−,5+→7 | C58 2.2µ ケミ → R292 10K → −6; feedback R293 100K; +5 ← "6V"; out 7 → **C60 2.2µ ケミ** → "**(D-4/7) FRONT RESCUE**" (with a "MIXへ" note) | clear |

## Block 5 — back/other-car sound (IC39 = 555, IC40 sections, TR16)

| Item | Connection | Confidence |
|---|---|---|
| 555 (IC39) astable | 12V → R268 10K → pin 7; R269 680K → pins 6+2; **C47 0.68** pins 6/2 → GND; pin 5 → C48 0.01 → GND; pin 4 riser up, label unread (likely 12V) | pin-4 tie uncertain (U11) |
| Out 3 | → D15 (MA150, cathode toward pin 3) → R230 22K → node W (≈3050,4800) | clear |
| Node W network | R233 (value unread) from 12V; R232 30K → IC40.13; R234 51K → IC40.12; chain at right: "8.2+680 K" (annotated with an unread word), 2.7K R238 → GND, 3.9K, R235 12K — interconnection not fully pinned | values partly uncertain (U12) |
| IC40 13−,12+→14 | integrator, feedback **C49 0.033** (13→14); pin-12 node also has R416 51K → GND and R231 680Ω → TR16 (type C458) collector; TR16 gating network below (D16 MA150?, R270 21K, R271 10K — from the overview; not re-verified) | TR16 network uncertain (U13) |
| IC40 2−,3+→1 | Schmitt: −2 ← out 14; +3 ← R272 51K ← arrow "**6V (D-5/7)**", with R273 100K positive feedback (3→1); the former out-1 → BACK OTHER CAR assignment is withdrawn (that line joins input 6 of the next section) | local feedback as traced; corrected inter-sheet assignment |
| IC40 6−,5+→7 | output amp: −6 receives the **BACK OTHER CAR (D-7/7)** line at the junction shared with R276 and feedback R277; R276 18K? (could read 10K) comes from the local signal region; feedback R277 22K; +5 ← "6V (D-5/7)"; out 7 → **C50 10µ ケミ** → R274 1K → node Z | R276 18K (written over a struck-out value) |
| Node Z | → R279 1K → square edge pad lettered "**R**" → "**BACK SOUND OUT** (GND近くに出す — 'bring out close to GND')"; → **R275 50Ω** → arrow "**BACK SOUND STB. (D-4/7)**"; → diagonal → "**MIX AMP BACK SOUND (D-4/7)**" | clear |

## Off-sheet interface

| Label (as written) | Form | Direction | Net here |
|---|---|---|---|
| /RESCUE C⟨P⟩ | square pad, left edge | in | R278/R280 → TR15 (U1) |
| 6V (D-5/7) | arrows ×3 | in | op-amp references (IC44.3, IC40.3 via R272, IC40.5) and the IC42.5 "6V" rail |
| (D-4/7) FRONT RESCUE | arrow after C60 | out | IC44.7 via C60 2.2µ |
| BACK OTHER CAR (D-7/7) | arrow | in | junction at IC40.6 (inverting amplifier input), shared with R276/R277; user-reviewed |
| BACK SOUND OUT (GND近くに出す) | edge pad "R" | out | node Z via R279 1K |
| BACK SOUND STB. (D-4/7) | arrow | out | node Z via R275 50Ω |
| MIX AMP BACK SOUND (D-4/7) | arrow | out | node Z |
| MIXへ | note at FRONT RESCUE | — | same output |
| 12V, Vcc, GND | rails | — | as drawn |

## Component list (as printed)

ICs: IC39 555; IC40, IC42, IC43, IC44 LM324; IC41, IC45 MC3340.
Transistors: TR15, TR16 C458 (2SC458). Diodes: D15, D17, D18, D20 MA150;
D19 MA150?; D32 type unread; D16 MA150? (overview only).
R: R230 22K, R231 680Ω, R232 30K, R233 ?, R234 51K, R235 12K, R236 51K,
R237 100K, R238 2.7K, R240 100K, R241 1K, R242 10K, R243 10K, R244 100K,
R245 1K, R246 100K, R247 1K, R248 10K, R249 1.2K, (R250?) 3.3K, R251 1K
and/or 10K (U4), R252 6.8K, R253 100K, R254 1K? (U4), R255 4.7K, R256 10K,
R257 10K, R258 ? , R259 100K, R260 1K, R262 100K, R263 3.3K, R264 8.2K,
(R265?) 51K, R268 10K, R269 680K, R269?/R2?9 1K? (audio rail, U10),
R270 21K?, R271 10K?, R272 51K, R273 100K, R274 1K, R275 50Ω, R276 18K?,
R277 22K, R278 4.7K, R279 1K, R280 2.2K?, R281 10K, R282 82K, R283 51K,
R284 10K, R288 1K, R290 220K, R291 10K, R292 10K, R293 100K, R416 51K,
plus "8.2+680 K" pair and 3.9K near node W (U12).
C: C47 0.68, C48 0.01, C49 0.033, C50 10µ, C52 2.2µ, C53/C54 33µ ×2,
C55 0.68µ tantalum, C56/C57 47µ ×2 tantalum, C58 2.2µ, C60 2.2µ.

## Block description (wiring only)

Two identical-topology function generators: a fast one (IC42) producing the
siren tone, frequency steered by 51K/82K diode paths; a slow one (IC43/IC44,
10K/220K into 47µ×2) producing the wail ramp. The ramp reaches the MC3340
attenuators' control pins (IC41 via the IC40 buffer, IC45 via the IC44
follower), shaping the siren into front/rear rescue-car sounds; the chain
ends at FRONT RESCUE to the D-4/7 mixer. Independently, the 555 (IC39) chugs
at a rate set by 10K/680K/0.68µ; IC40 smooths (C49 integrator, gated by
TR16) and squares it through the Schmitt section. The output amplifier
also receives **BACK OTHER CAR from D-7/7 at input 6** and feeds the BACK
SOUND outputs toward D-4/7 and an edge pad. The earlier claim that the
Schmitt output drives BACK OTHER CAR is withdrawn; remaining local routes
retain their unresolved qualifications.

## Unresolved

1. **U1 — closed (review)**: /RESCUE CP. Earlier notes: — the input pad's label spelling (left edge ≈(1560,2690)): read
   "…RESCUE C⟨P/1⟩" with overbar; first glyphs unclear.
2. **U2 — closed (review)**: 2.2K. Earlier notes: — R280 value: 2.2K or 8.2K. Crop (1550,2400,3200,3000).
3. **U3** — the word before "33M X2" over C53/C54 (dielectric/type note).
4. **U4 — closed (review)**: see Review. Earlier notes: — the steering node between C55/R253 and the siren generator:
   R251 appears with value 1K near IC43.12 and 10K below node Q — one of
   the two designators is misread (R254 1K is printed in this area); D32's
   type and the R284 10K / D32 / R251? net endpoints not pin-traced.
   Crops (3850,3280,4800,3900), (4200,2550,5600,3350).
5. **U5 — closed (review)**: 9,10 → 8. Earlier notes: — the lower IC43 latch section's pin numerals (taken as 2,3→1 by
   symmetry; its designator numeral not separately readable).
6. **U6 — narrowed (review)**: D19 and D32 are both written "MA80" (four glyphs, unlike D20's "MA150"). Earlier notes: — D19's printed type: MA150/MA80/MA50 ambiguous.
7. **U7 — closed (review)**: see Review. Earlier notes: — R258 and the R260 1K line's destination (east of the wail
   divider); R261 (12V) region not traced. Crop (5600,3300,7050,4000).
8. **U8 — closed (review)**: see Review. Earlier notes: — IC40 (9,10→8) control-buffer input network (R236 51K,
   R237 100K) source node not pin-traced.
9. **U9 — closed (review)**: both IN pins take IC40.14, see Review. Earlier notes: — both MC3340 "IN" pins: the risers leave the boxes downward and
   were not followed; the audio sources (siren square/triangle for IC41;
   rail for IC45) are inferred-looking but **not traced** — do not rely on
   them.
10. **U10 — closed (review)**: there is no audio rail; the resistor is R260 1K. Earlier notes: — the audio rail's resistor at (7100,3800): designator reads
    R2⟨5/6⟩9, value 1K?; the R262 follower tap's junction with the rail
    unverified.
11. **U11 — closed (review)**: pin 4 (RS, drawn with a bubble) → 12V. Earlier notes: — 555 pin 4's riser label (likely 12V; glyphs unread).
12. **U12 — closed (review)**: see Review. Earlier notes: — node W network around the 555 output: R233's value, the
    "8.2+680 K" pair's annotation word, 3.9K's designator, and the exact
    interconnection of R235/R238/3.9K were not settled.
13. **U13 — closed (review)**: TR16 is driven by IC40.1, see Review. Earlier notes: — TR16's base network (D16, R270 21K, R271 10K from the
    overview) and what control signal gates it (candidate: a back-sound
    enable from another sound sheet) — untraced.
14. **U14 — closed (review)**: 18K. Earlier notes: — R276 value 18K/10K.
15. The stonedDiscord redraw's Sound schematic (19 components) covers none
    of this page's circuitry; no comparison was possible.

## Visual review corrections — 23 October 2026

The user followed BACK OTHER CAR to the solid junction at **IC40 pin 6**
on page-16 crop (4450,4590,5370,5170). It is an incoming contribution at the
amplifier input, not IC40.1 sent to D-7/7. The pin table, interface and block
description are corrected; this does not complete the remaining analog nets.

## Review, 31 October 2026 (Claude)

Checked on full-resolution crops of manual 420-0358, PDF page 16:
(2900,3300,4900,4500), (2900,4100,5400,4800), (5300,3700,8300,4900),
(2400,4100,4400,5600), (4100,4400,6100,5500), (1500,4100,2900,5300),
(4300,2500,6900,4000), (6600,2900,8000,3900), (3900,3300,5300,4300),
(1700,2700,4200,3900), (1150,2450,3400,2950), (5600,2750,6300,3250).
The two long horizontals at y ≈ 4480–4535 and 4525–4575 (they slope
with the scan) were separated by sampling ink rows every 400 px.

**Siren tone: a VCO keyed by the 555.**
- 555 (IC39): RS 4 → 12V (free running); R268 10K, R269 680K, C47 0.68 µF:
  about 0.33 s high and 0.32 s low (≈ 1.5 Hz).
- Out 3 → D15 (MA150, cathode toward pin 3) → R230 22K → node W. Node W:
  R233 3.9K to 12V, R235 12K to GND, R232 30K → IC40.13, R234 51K →
  IC40.12. While the 555 output is low, D15 pulls node W down: two node
  voltages, so two tones (hi–lo siren).
- IC40 13−,12+ → 14: C49 0.033 µF from 13 to 14; pin 12 also has R416 51K
  to GND and R231 680 Ω to TR16's collector (2SC458, emitter GND).
- IC40 2−,3+ → 1 (Schmitt): −2 ← IC40.14; +3 ← R272 51K from "6V (D-5/7)"
  and R273 100K from out 1. Out 1 → R271 10K → D16 (MA150) → TR16 base,
  with R270 2.2K base to GND.
- So IC40.14 ramps one way while TR16 is off and the other way while
  TR16 shunts pin 12 through 680 Ω; the Schmitt flips TR16 at each end. It
  is a triangle VCO whose rate follows node W.
- **IC40.14 is the audio**: it runs up to the lower horizontal (dot
  ≈ (3915,4525)) → C51 2.2 µF → MC3340 IC41 IN (pin 1), and east along
  that horizontal to x ≈ 6455, down to y ≈ 4880, east → C59 1 µF → MC3340
  IC45 IN (pin 1).

**Envelopes on the MC3340 controls.**
- **The 2.8 V rail** (upper horizontal): R239 written "8.8K" with the
  note "8.2+680Ω" (8.2K + 680 Ω in series) from 12V, R238 2.7K to GND:
  12 × 2.7 / 11.58 = 2.80 V, matching the printed "2.8V".
- **IC40 9,10 → 8** (follower): +10 ← R237 100K ← IC42.7 (the 33 µF × 2
  integrator), R236 51K to the 2.8 V rail; out 8 → IC41 CON (2).
- **IC44 9,10 → 8** (follower): +10 ← R262 100K ← IC44.1 (the 47 µF × 2
  integrator), R265 51K to the 2.8 V rail; out 8 → IC45 CON (2).
- IC42 and IC44 are slow integrators (16.5 µF with 51K/82K, 23.5 µF with
  10K/220K), so they are envelopes, not tones (the earlier block
  description called IC42 the siren tone).
- IC41's output is written "後" (rear): OUT 7 → C52 2.2 µF → down at
  x ≈ 4130 → y ≈ 4745 → R276 18K → IC40.6, the back-sound amplifier.
  IC45's output is written "前" (front, as read): OUT 7 → C58 → IC44 6,5 → 7 → C60
  → FRONT RESCUE (D-4). A front and a rear rescue siren, each with its
  own envelope.

**Steering between the generators (U4, U7).**
- IC43 13−,12+ → 14: −13 ← IC42.7; +12 ← R254 1K ← R252 6.8K / R255 4.7K
  divider (12V; a circled mark by the node). Out 14 → R253 100K and C55
  0.68 µF (タン) down to node Q.
- Node Q: R251 10K to GND, D32 (MA80 as written; anode GND, cathode Q),
  R284 10K → IC43.3.
- IC43 2−,3+ → 1: Schmitt, −2 ← "6V (D-5/7)", R285 100K from out 1 to
  pin 3. Out 1 → up to y ≈ 3810, west to x ≈ 4775, up: the foot of the
  upper divider (10K from 12V, 10K down; designators read R287/R286 here,
  R257/R256 in the first transcription), whose node feeds IC43.5.
- IC43 6,5 → 7 and 9,10 → 8: the cross-coupled pair (1K in, 100K
  feedback each): −6 ← R288 1K ← IC43.8; −9 ← R257 1K ← IC43.7. +5 ← the
  divider above; +10 ← node {R258 10K to 12V, R259 10K to IC44.14}.
- IC44 13−,12+ → 14: −13 ← IC44.1; +12 ← R260 1K from the R264 8.2K /
  R263 3.3K divider on IC44.1, and R261 100K from out 14. Out 14 →
  R259.
- IC43.7 → D20/R291 10K and D19/R290 220K → IC44's integrator (as in
  Block 3).

**Back sound (U13, U14).**
- IC40 6−,5+ → 7: −6 sums R276 18K (rear rescue) and the BACK OTHER CAR
  (D-7/7) line; R277 22K feedback; +5 ← 6V. Out 7 → C50 10 µF → R274 1K
  → node Z.
- Node Z: R279 1K → pad R "BACK SOUND OUT"; R275 50 Ω → "BACK SOUND
  STB. (D-4/7)"; "MIX. AMP BACK SOUND (D-4/7)".
- On D-4, BACK SOUND STB. is IC57.6 (7417, open collector) driven by
  OR(COIN IN, alarm): node Z is pulled to ground through R275 in
  attract, the same mute as D-4's R406 on SOUND OUT. MIX. AMP BACK SOUND
  reaches the D-4 mixer through C114, a DIP SW. 2 contact and R424 100K.

Still open:
- U3, the word before "33M X2";
- the "MA80" reading (U6);
- what the D-5 6 V reference and the comparator chain do in time. That is
  behaviour, for the model, not wiring.

## Check before the logic, 2 November 2026 (Claude)

Read again on the scan before modelling. Crops (stored-image pixels):
(1500,2400,8300,5600) overview, (2000,1450,2700,2250) R249,
(2600,1500,4200,3100) and (3200,1850,3900,2500) the IC42 latch,
(1500,2300,4100,3300) the steering, (3550,3150,4100,4200) R252/R255,
(3800,2800,5600,4300) IC43, (2700,4500,4600,5650) the VCO. These take
precedence over the tables above where they differ.

- **R249 is 8.2K** (the first glyph is closed like the drafter's 8s, unlike
  the plain 1 of R247's "1K"): the comparator reference is
  12 × 3.3 / 11.5 = 3.44 V.
- **The IC42 latch**: pin 13 takes R241 1K from **out 1** and pin 2 takes
  R245 1K from **out 14** (the two lines cross in the drawn X; followed
  end to end at 3×). R240/R244 100K are each section's own feedback.
- **The steering node L hangs off IC42 pin 1**: out 1's vertical runs on
  down past the pin to y ≈ 3110, west along it to x ≈ 1930 and down to the
  D18/D17 node. (Block 2 and the 31 October review had pin 14.)
- **TR15 off (pad P low) puts IC42.3 at 12 V** through R243 (R281 then
  carries no current); TR15 on gives 6 V. The Block 1 note had these the
  other way round.
- **R255 is 4.7K** ("4.7K" with the decimal point): the IC43.12 reference
  is 12 × 4.7 / 11.5 = 4.90 V.
- **R231 680 Ω hangs on IC40 pin 13** (the − input, the dot on R232's line),
  not on pin 12; R416 51K is the one on pin 12. With TR16 on, C49 is
  discharged through 680 Ω: the VCO is a sawtooth (slow fall through R232
  30K, fast rise), about 700 Hz in the SPICE reference.
- **D16** points toward TR16's base (anode at R271).
- **R264 8.2K hangs from 12 V**, not from IC44.1: its top end stops short
  of the output line and carries a small "12V" (crop (6560,3200,6800,3450)
  at 4×). IC44 d therefore compares the front envelope with
  12 × 3.3 / 11.5 = 3.44 V (through R260 1K, R261 100K hysteresis), the
  same reference as IC42's comparator. (The 31 October review had the
  divider on IC44.1, which in SPICE left the front envelope stuck at the
  bottom after the first rescue.)
- The MC3340s' pin 6 is not drawn (left open, as on D-6); "MA80" (D19,
  D32) is modelled as a small-signal silicon diode like the MA150.

What it does, from these readings (checked in SPICE,
`tests/sound/spice/d2_rescue.cir`):
- Out of rescue the IC42 latch holds pin 1 low: the rear envelope (IC42.7)
  sits at its top and IC41's CONTROL at 5.4 V (attenuated).
- A /RESCUE CP pulse (pad P low, 20 ms from sheet M) forces pin 1 high:
  the envelope falls through 51K until the comparator (3.44 V) flips the
  latch, then rises again through 82K: one fall-and-rise of the rear
  siren's loudness per pulse.
- As the rear envelope falls below 4.90 V, IC43's comparator rises; C55
  passes the edge to the IC43 Schmitt, whose short pulse sets the front
  latch: the front envelope (IC44.1) falls fast through R291 10K to
  3.44 V, where IC44 d resets the latch, and then rises slowly through
  R290 220K.
