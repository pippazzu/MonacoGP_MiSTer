# Sound sheet D-4/7 — noise source, mixer and control gates

Source: Sega **Monaco GP (420-0358)**, PDF page **18**, board **96598-P**,
sheet **D-4/7**. Drawn titles: "Ⓢ - MONACO GP" (top left), circled "MIXER"
(top middle), "96598-P (D-4/7) OSCILLATOR" (bottom right). Transcribed from
the supplied `sheets/page18-sound-D4.png`, **10176 × 6624** pixels, 600 dpi,
**stored upright** (the extra 180° turn named in START_HERE was already
applied to the supplied file). Source PNG SHA-256:
`8e1b357587ca29350be97e01a37d82bffd86cadc82540ead398ad3d16f2734df`.

**Status: whole-page transcription.** The S2688 noise source, the mixer
with SOUND OUT and the control gates were traced first; the 31 October
continuation (Claude, "Continuation, 31 October" at the end) traced the
explosion filters, MC3340 chains and 74123 envelopes, the skid-tone 555 and
EXTEND CP, and settled the control gates and the output mute. Where the
continuation corrects an earlier table row, the row is updated and the
continuation gives the evidence. Read visually from 1.25–1.6× crops (D1 methodology); the
netx extractor was not used. Values are transcribed as printed.

A top-right handwritten note reads: "AMI S2688 NOISE OSC は 周辺回路は
AUDIO 回路 から はなすこと" (keep the S2688 and its surroundings separated
from the audio circuitry) — a layout instruction, recorded as drawn.

## Crops used

| Box | Contents |
|---|---|
| (0,0,10176,6624) ×0.14 | overview |
| (1700,850,2900,1900) ×1.4 | S2688, C79/C80, R385 |
| (2200,750,3500,1500) ×1.6 | noise amp IC63, R361/R362, C93 |
| (5250,1850,6500,2500) ×1.5 | mixer amp a (IC66), R400, C100, EXTEND CP entry |
| (6300,1850,7900,2550) ×1.25 | mixer amp b (IC66), R414, C103, R413/R406/R407 |
| (6700,2450,8300,3350) ×1.15 | summing bank labels, DIP switch, C114 |
| (7900,1800,9400,2500) ×1.3 | SOUND OUT pad 13 |
| (5300,3350,6700,4900) ×1.1 | IC60 NOR gates, IC68 inverters |
| (6500,3300,8200,4900) ×1.0 | MY CAR SOUND ON / SHIFT A labels |
| (6700,4800,8700,5700) ×1.0 | IC57 inverters, BACK SOUND STB |
| (4750,3300,5600,4900) ×1.3 | control pads 8/K/9/L/10 |
| (1300,5850,3900,6400) ×1.2 | EX.CP pad 14, R425 |

## Block 1 — S2688 noise source

### IC62 (printed "S2688", caption "AM1 S2688")

| Pin | Connection | Confidence |
|---|---|---|
| 4 (VSS) | 12V | clear |
| 2 (VGG), 1 (VDD) | tied together → GND | clear |
| 3 (out) | noise node, three branches below | clear |

Noise node branches:

| Branch | Connection | Confidence |
|---|---|---|
| up | arrow "SLIP ZONE SOUNDヘ (D-1/7)" — the noise feed to sheet D-1/7 | clear |
| right | C79 1µ (ケミ) → R361 150K? → IC63 pin 9 (−) | value glyph "150Ʀ" (U1) |
| down | C80 1µ (ケミ) → R385 100K → continues down (to the lower band-pass chain, not traced) | clear |

**This settles sheet D-1's Unresolved 1**: the S2688 lives here on D-4/7
and its noise goes *to* D-1/7; on both pages the arrow points at the other
end's name with ヘ ("to"). SOUND_D1_TRACE.md's noise input is confirmed as
an input.

### Noise amplifier — IC63 (LM324, pins 9−, 10+, out 8)

| Item | Connection | Confidence |
|---|---|---|
| R362 51K | pin 9 → out 8 (feedback) | clear |
| pin 10 (+) | bias node → arrow "6Ʋヘ (D-5/7)" (the 6 V rail, generated on D-5/7) | clear |
| out 8 | → east: joins the vertical distribution run at ≈(3105,1215); → C93 4.7µ (ケミ) → R… "21?" → the lower chain | run partly untraced (U2) |

The amplified noise feeds the two MC3340 chains (not traced, see below).

## Block 2 — mixer and SOUND OUT

Two cascaded LM324 inverting stages, both drawn as triangles marked "66"
(IC66).

### IC66 amp a (pins 2−, 3+, out 1*)

| Item | Connection | Confidence |
|---|---|---|
| pin 2 (−) | ← summing rail from the west (first input bank; the 爆発音 "explosion sound" caption sits over this region) | bank membership untraced (U3) |
| pin 3 (+) | → arrow "6Ʋヘ (D-5/7)" (6 V bias) | clear |
| R400 1M | pin 2 → out (feedback) | clear |
| out | numeral smudged (pin 1 by LM324 pinout) → C100 10µ → R401 220K → amp b pin 6 | numeral U4 |

### IC66 amp b (pins 6−, 5+, out 7)

| Item | Connection | Confidence |
|---|---|---|
| pin 6 (−) | summing bus (the y≈2640 rail with junction dots) | clear |
| pin 5 (+) | ← west rail (6 V bias region) | clear |
| R414 (value above, reads 22K) | pin 6 → out 7 | value U4 |
| out 7 | → C103 10µ (ケミ) → R413 1K → node → R407 1K → **pad 13 "SOUND OUT (GND 近くに出す)"**; R406 100Ω from the node to IC57 pin 4 (the mute) | clear |

"GND 近くに出す" = "bring it out close to GND" (wiring note). The
10 MΩ-looking "10M ケ≡" captions by C100/C103 read **10µ ケミ**
(electrolytic), not 10 MΩ.

### Summing bank into amp b (left to right)

| Series element(s) | Input label (as written) | Confidence |
|---|---|---|
| R402 220K | "EXTEND CP" (arrives on the y≈2340 run from the west) | clear |
| R403 220K | (from the first bank region / amp a path) | partly traced (U3) |
| 100K | — | label not located (U3) |
| "59K"-ish | — | value glyph uncertain (U3) |
| R408 39K | "HI SCORE SOUND OUT (D-5/7)" | value read 2 Nov (see below); label partly read (U5) |
| R412 51K? | "SLIP ZONE SOUND (D-1/7)" — **sheet D-1's output arrives here** | clear |
| R410 220K? | "RESCUE (D-2/7)" | clear |
| R409 82K | "PRINT OTHER CAR (D-7/7)" (first word uncertain) | value read 2 Nov (see below); label U5 |
| R424 100K + DIP SW. 2 (4P) contact + C114 2.2µ | "BACK SOUND (D-2/7)" | clear |

The L-shaped run from this region ((7640,3060) → (8115,3060) → south) is
R406's foot, going to IC57 pin 4 (see Block 3).

## Block 3 — control gates (game-logic interface)

Five inputs on hatched pads, each with a 470 Ω pull-up to Vcc:

| Pad | Label (as written) | Pull-up | First consumer | Confidence |
|---|---|---|---|---|
| 8 | "S̄-ĀC̄C̄1̄" (/S-ACC1) | R378 470Ω | IC60 pin 3 | clear |
| K | "/COIN IN" ("−C̄ŌĪN̄ ĪN̄") | R379 470Ω | rail → IC60 pin 5 | clear |
| 9 | "NON ROAD & POOL SLIP" (overbar presumed under the wire) | R380 470Ω | IC68 pin 1 → 2 | clear |
| L | "/GAME" (lower-case "game" under an overbar) | R381 470Ω | IC68 pin 3 → 4; riser to IC60 pin 2 | clear |
| 10 | "SHIFT" | R382 470Ω | IC68 pin 5 → 6 | clear |
| 14 (bottom edge) | "EX , CP" | R425 470Ω | run east + north into the bottom-left oscillator block | clear |

Cross-sheet: /COIN IN matches sheet A's pad A28 "/COIN IN (S)"; EX.CP
matches sheet A's pad A29 "EX.CP (S)"; /S-ACC1 relates to sheet F's
accelerator signals (naming not assumed).

### IC60 (caption "7402", quad NOR; sections as drawn)

| Section | Connection | Confidence |
|---|---|---|
| 3,2 → 1 | 3 ← pad-8 node; 2 ← pad L (/GAME) by the dotted run; out 1 → node: 60b pin 6, the 7432 pin 4, and the explosion trigger line T | clear |
| 6,5 → 4 | 6 ← 60a.1; 5 ← /COIN IN rail; out 4 → long run east → "(D-3/7) MY CAR SOUND ON" (the glyph reads "CAN") | clear; label glyph U9 |
| 12,11 → 13 | 12 ← the /COIN IN vertical (x ≈ 5690, dots at the rail and at pin 12; continues down to IC68 13); 11 ← IC68.4 (GAME); out 13 → 60d pin 8 | clear |
| 8,9 → 10 | 8 ← 60c.13; 9 ← IC68.6 (pad 10/SHIFT inverted) via the x≈6050 riser; out 10 → long run east → "(D-3/7) SHIFT A". Drawn as an OR body with a bubble **only at output 10**, consistent with NOR on a 7402 | body/polarity clear, user-reviewed; source qualifications as above |

### 7432 section (caption "7432", pins 4,5 → 6)

| Pin | Connection | Confidence |
|---|---|---|
| 4 | ← IC60a output | clear |
| 5 | ← IC68.2 (pad 9 inverted) | clear |
| 6 | → long run east, then south at ≈x6615 and west along y ≈ 6000 → the 555's RES (pin 4) | clear |

### IC67 and IC57 (output mute, back-sound strobe)

| Element | Connection | Confidence |
|---|---|---|
| IC68 13 → 12 | 13 ← the /COIN IN vertical's foot; 12 = COIN IN → IC67 9 | clear |
| IC67 (OR body) 9,10 → 8 | 9 ← IC68 12; 10 ← "アラーム (D-5/7)" (alarm); 8 → y≈5010 east → dot (7040,5010) → IC57 3 and 5 | clear |
| IC57 3 → 4 (7417) | out → north x≈8115, west y≈3060, north to R406's foot: pulls the SOUND OUT node low through R406 | clear |
| IC57 5 → 6 (7417) | out → arrow east "BACK SOUND STB. (D-2/7)" | clear |
| pencil "17" below pin 5 | the part type, 7417 (open-collector buffer; output slash, no bubbles) | clear |

## Components and values (traced blocks)

| Ref | Value / type | Role |
|---|---|---|
| IC62 | S2688 | noise generator (VSS=12V, VGG=VDD=GND) |
| C79, C80 | 1µ ケミ each | noise couplings |
| R361 | 150K? ("150Ʀ") | noise amp input |
| R362 | 51K | noise amp feedback |
| R385 | 100K | lower noise path |
| C93 | 4.7µ ケミ | distribution coupling |
| IC63, IC66 ×2 | LM324 sections | noise amp; mixer a, b |
| R400 | 1M | amp a feedback |
| C100, C103 | 10µ ケミ | interstage/output couplings |
| R401 | 220K | a → b |
| R414 | 22K? | amp b feedback |
| R402, R403 | 220K each | EXTEND CP; bank |
| R408 | 39K | hi-score sound (D-5) |
| R412 | 51K | slip-zone (D-1) |
| R410 | 220K? | rescue |
| R409 | 82K | other car (D-7) |
| R424 | 100K | back sound (through DIP SW. 2 and C114 2.2µ) |
| R413, R407 | 1K each | output attenuator series |
| R406 | 100Ω | output mute shunt, to IC57 pin 4 |
| R378–R382, R425 | 470Ω each | pad pull-ups |
| IC60 | 7402 (caption) | control NORs |
| IC68 | inverter sections 1→2, 3→4, 5→6 (no type printed) | pad inverters |
| IC57 | 7417 (pencilled "17"), sections 3→4, 5→6 | output mute, back-sound strobe |
| IC67 | OR section 9,10 → 8 | mute / strobe gate |

## Off-sheet labels (traced blocks)

| Label (as written) | Where | Direction |
|---|---|---|
| SLIP ZONE SOUNDヘ (D-1/7) | noise node arrow | out, noise to D-1/7 |
| SLIP ZONE SOUND (D-1/7) | summing bank | in, from D-1/7 |
| 6Ʋヘ (D-5/7) ×2 | amp bias nodes | the 6 V rail, from D-5/7 |
| EXTEND CP | west run into R402 | in (from sheet A's EXTEND via the sound connector; path on this board not traced) |
| …SOUND OUT (D-5/7) | bank label (left edge) | in, from D-5/7 |
| RESCUE (D-2/7) | bank | in |
| PRINT? OTHER CAR (D-7/7) | bank | in |
| BACK SOUND (D-2/7) | bank, via DIP SW. 2 (4P) + C114 | in |
| SOUND OUT (GND 近くに出す) | pad 13, right edge | out (the board's audio output) |
| (D-3/7) MY CAR SOUND ON | gate output run | out |
| (D-3/7) SHIFT A | gate output run | out |
| BACK SOUND STB. (D-2/7) | arrow, bottom right | out |
| アラーム (D-5/7) | arrow into IC67 10 | in |
| /S-ACC1, /COIN IN, NON ROAD & POOL SLIP, /GAME, SHIFT, EX.CP | pads 8, K, 9, L, 10, 14 | in, from the game boards |
| 12V, Vcc, GND | supply marks | |

## Formerly untraced blocks

The MC3340 chains, the 74123 envelopes, the bottom-left oscillator (a 555
skid tone, not an EX.CP chime: EX.CP has its own path into R402) and the gate
driving IC57 are traced in "Continuation, 31 October" below.

## Unresolved

1. **R361's value** reads "150Ʀ" — 150K or 150Ω (the K-glyph is malformed).
2. **The noise-amp output run**: the junction at ≈(3105,1215) with the
   vertical frame run, and which MC3340 chain gets C93's path vs the top
   path, were not pinned.
3. **First summing bank membership** (amp a's inputs, 爆発音 label) and the
   unlabeled bank resistors (100K, "59K") are untraced/unread.
4. **Amp a's output numeral** is smudged (taken as 1 by LM324 pinout);
   R414's value read as 22K from the overview only. (R406's lower end is
   IC57 pin 4, closed 31 October.)
5. **Label fragments**: the left-edge bank label "…SOUND OUT (D-5/7)" is cut
   by the crop (likely MY CAR SOUND OUT); "PRINT OTHER CAR" first word
   uncertain.
6. **BACK SOUND topology — closed (31 October)**: the label belongs to the C114/DIP-SW column; the IC57.4 run is R406's foot (the output mute). Earlier notes:: whether the label "BACK SOUND (D-2/7)" belongs
   to the C114/DIP-SW column (arriving from D-2/7) or to the IC57.4
   north-run that ends in the same region — both meet there. As recorded:
   C114 column = the arriving sound, IC57.4 = a derived gate/strobe going
   north; needs one more look.
7. **Closed (31 October)**: pin 2 ← /GAME, pin 12 ← /COIN IN, 7432 pin 4 ← 60a. Earlier notes: **IC60 pin-2 tie**, the 60c pin-12 source vertical, and the 7432 pin-4
   source were not followed to their ends.
8. **Closed (31 October)**: pad L is /GAME. Earlier notes: **Pad L's label** ("gans̄"-like) unread; a gear-state signal by position
   between /COIN IN and SHIFT (sheet F has the shift logic).
9. **"MY CAR SOUND ON"**: the second word's glyph reads "CAN".
10. **IC60 section 8,9→10 — resolved by user visual review.** There is
    a bubble only at output 10 and none at inputs 8/9. The OR body therefore
    represents NOR, consistent with the 7402 caption. The former claimed
    input bubbles and package-function conflict are withdrawn.
11. **Closed (31 October)**: the 555's RES. Earlier notes: **The 7432.6 run's destination** (east then south at ≈x6615).
12. **Closed (31 October)**: "17" near IC57.5 is the type, 7417.
13. IC57 is a 7417 (closed); IC68's type is still not printed. Earlier notes: **IC57/IC68 package types** are not printed (inverter sections only).
14. The stonedDiscord redraw's sound schematic (19 parts) was not used.

## Visual review corrections — 23 October 2026

The user confirmed **circle only at 10** on the original page-18 crop
(5940,4360,6490,4650). The IC60 gate table and unresolved item 10 are
corrected; other control-source wires remain subject to their open items.

## Continuation, 31 October 2026 (Claude)

Crops are given per block; coordinates are stored-image pixels.

### Explosion sound: band-pass filters and MC3340 chains

Crops (2900,650,4400,1500), (4100,650,5600,1500), (2900,1500,4300,2300),
(4200,1550,5900,2350), (5150,1300,6400,2200), (2950,1150,3250,1350).

- The noise amp output (IC63 pin 8) joins the vertical distribution wire
  at ≈ (2995,1239) (dot). The bias vertical at x ≈ 3125 (IC63 pins 5 and 3)
  crosses that wire without a dot.
- **Upper band-pass, IC63 b** (pins 5 +, 6 −, 7 out), multiple feedback:
  noise → C93 4.7 µF (ケミ) → R395 4.7 kΩ → node; R396 27 kΩ node → GND
  (corrected 1 November: printed "27K" with no point; was read 2.7 kΩ);
  C95 0.01 µF (マイラ) node → pin 6; C96 0.01 µF (マイラ) node → pin 7;
  R391 220 kΩ pin 6 → pin 7; pin 5 → bias vertical (6 V).
- pin 7 → C82 1 µF (ケミ) → R397 33 kΩ → MC3340 **IC65** pin 1 (in);
  pin 6 → 680 pF → GND; pin 2 (CO, control) → down (to trace); pin 7 (out)
  → C83 1 µF (ケミ) → R365 150 kΩ → down x ≈ 5375 → IC66 pin 2.
- **Lower band-pass, IC63 a** (pins 3 +, 2 −, 1 out): distribution wire →
  C92 4.7 µF (マイラ as written) → R388 4.7 kΩ → node; 8.2 kΩ (R389)
  node → GND; C91 0.047 µF node → pin 2; C90 0.047 µF (マイラ) node →
  pin 1; R387 220 kΩ pin 2 → pin 1; pin 3 → bias vertical.
- pin 1 → C98 1 µF (ケミ) → R398 33 kΩ → MC3340 **IC71** pin 1; pin 6 →
  680 pF → GND; pin 2 (CON) → down (to trace); pin 7 → C99 1 µF (ケミ) →
  100 kΩ (labelled "R397" like the upper chain's 33 kΩ: one is misread, U)
  → IC66 pin 2.
- **IC66 a** (pins 2 −, 3 +, 1 out), "爆発音" (explosion sound) beside it:
  pin 2 sums R365 (150 kΩ, IC65) and the 100 kΩ (IC71); R400 1 MΩ pin 2 →
  pin 1; in parallel R423 2 MΩ in series with DIP SW. 2 (4P) contacts 2–15
  (closed: feedback 667 kΩ, the explosion louder by about 3.5 dB); pin 3 →
  "6V → (D-5/7)" and on to IC66 pin 5; pin 1 → C100 10 µF (ケミ) → R401
  220 kΩ → IC66 b (the mixer, as traced).

### Explosion envelopes: 74123 one-shots

Crops (1650,2150,3150,3500), (2950,2350,4200,3550), (1450,2100,2600,4400).

- **IC61 a** (74123): A 1 → GND; B 2 ← trigger line T; CL 3 → Vcc; C76
  4.7 µF (タン) 14–15, R360 47 kΩ 15 → Vcc (about 63 ms); Q 13 → R377
  330 Ω up to Vcc and D30 (MA150) → node: 10 µF to GND, R374(?) 330 kΩ to
  GND → IC66 d pin 12 (follower 13–14).
- **IC61 b**: A 9 ← IC69 Q 13 (fires as IC69's pulse ends); B 10 and CL 11
  → Vcc; C86 4.7 µF (タン), R372(?) 47 kΩ; Q 5 → R376 330 Ω up and D31
  (MA150) → node: C78 10 µF to GND, 1 MΩ (R375?) to GND → IC64 follower
  (pins 12, 13, 14; the designator reads 64 or 6d).
- **IC69 a** (74123): A 1 → GND; B 2 ← T (dot ≈ (1442,4007) joins the two
  B lines); CL 3 → Vcc; C87 4.7 µF (タン), R373 47 kΩ; Q 13 → IC61 b A.
- So T fires IC61 a and IC69 together, and IC61 b about 63 ms later. Each
  Q charges its 10 µF in a few ms through 330 Ω and a diode; the charge
  decays through 330 kΩ (about 3.3 s) and 1 MΩ (about 10 s).
- The followers feed inverting stages (gain −1, 10 kΩ / 10 kΩ): R367 →
  IC66 c (9 −, 10 +, 8 out, R369 feedback) and R363 → IC64 c (R364); both
  + inputs (pin 10) on one vertical to the 12 V divider R368 8.2 kΩ (12 V
  side) / R366 3.9 kΩ (GND side), 3.87 V (checked 1 November).
  Their outputs rise on the right to the MC3340 control pins (IC65 pin 2,
  IC71 pin 2): low control (loud) at the trigger, rising as it decays.
  Which goes where is in the 1 November check below.
- **T** (the trigger line): from the B pins west to x ≈ 1449, down to
  y ≈ 4287, east to x ≈ 2611, up to y ≈ 4168, east to x ≈ 4283, up to
  y ≈ 3007, east to x ≈ 6435, down to IC60 a pin 1 (output). So the
  explosion fires as IC60 a's output rises: NOR(/S-ACC1 on pad 8, pin 2).

### Skid / off-road tone (bottom left) and EXTEND CP

Crops (1400,4300,3300,5800), (2800,4300,4700,5800), (4300,2250,7000,3050),
(1300,5650,4900,6200), (3500,4200,4700,5300).

- **IC64 b** (5 +, 6 −, 7 out): pin 5 ← R392 51 kΩ from the 6 V rail and
  R393 100 kΩ from pin 7; pin 6 ← R394 6.8 kΩ from pin 7 and C94 10 µF
  (タン) to GND: a slow relaxation oscillator (triangle on C94).
- **IC64 a** (3 +, 2 −, 1 out) follows C94; pin 1 → R390 68 kΩ → IC63 d
  pin 13.
- **IC63 d** (12 +, 13 −, 14 out): pin 13 also ← R385 100 kΩ ← C80 1 µF ←
  the S2688 noise (the vertical x ≈ 1655 rises to y ≈ 2117); R386 10 kΩ
  pin 13 → pin 14; pin 12 → the 6 V rail; pin 14 → C81 33 µF (タン) → the
  555's CON (5): the 555 is frequency-modulated by noise and the triangle.
- **555 ("555 (5V)")**: RES 4 ← a line along y ≈ 6000 east to x ≈ 6619,
  the 7432 pin 6 run (so it sounds while the 7432's output is high); DIS 7
  ← R383 47 kΩ from Vcc; R384 47 kΩ DIS → TH/TR (6, 2); C89 4700 pF
  (マイラ) to GND (about 2.2 kHz); OUT 3 → R405 10 kΩ / R404 10 kΩ to GND
  → C101 10 µF (ケミ) → the vertical x ≈ 4487 up to y ≈ 2585 → R403
  220 kΩ into the mixer ("SLIP" / "NON ROAD GRAVEL" written there).
- **EX.CP** (pad 14, R425 470 Ω pull-up) → east to x ≈ 3626, up to
  y ≈ 5141, east to x ≈ 4400 → a 2.2 µF (ケミ) in series → up x ≈ 4401 →
  R402 220 kΩ into the mixer ("EXTEND CP"). Sheet A's EX.CP is the extend
  lamp's blink (V2 gated by Vs/16), so the extend beep is that pulse
  train itself.
- Mixer bank seen in this crop: R402 220 kΩ (EXTEND CP), R403 220 kΩ
  (SLIP / NON ROAD GRAVEL), R411 100 kΩ (CAR SOUND OUT, D-3), R408 39 kΩ
  (HI SCORE SOUND OUT, D-5; read 2 November, below), R412 51 kΩ (SLIP ZONE SOUND, D-1).

### Control gates, settled

Crops (4300,3300,6600,4500), (4300,3900,5700,4900), (5400,4350,5900,5050),
(5100,4450,7000,5450), (6000,4300,8000,5400), (7000,4800,9600,5800),
(7300,3000,10176,5100), (6900,1700,8200,2800), (7000,2500,8500,3300).

- **Pad L is "/GAME"** (overbar, lower-case "game"): sheet A's pad AE
  "/GAME (S)", low during play.
- **IC60 a** (3, 2 → 1): 3 ← pad 8 (/S-ACC1); 2 ← pad L: from pin 2 a short
  wire down and east to x ≈ 5610, then a dotted run down to y ≈ 4087,
  where it meets the pad-L riser (x ≈ 5508, up from the IC68 pin 3 dot). So
  60a = NOR(/S-ACC1, /GAME): high while /S-ACC1 is low in play. Its rising
  edge is the explosion trigger T, so "S-ACC1" reads as an accident
  (crash) signal, not the accelerator.
- **IC60 b** (6, 5 → 4) = NOR(60a, /COIN IN) → MY CAR SOUND ON (D-3).
- **7432** (4, 5 → 6): 4 ← 60a's output vertical; 5 ← IC68 2 (pad 9
  inverted: NON ROAD & POOL SLIP is active low). 6 → the 555's RES. So the
  skid tone sounds on a crash in play or while pad 9 is low.
- **IC60 c** (12, 11 → 13): 12 ← the vertical at x ≈ 5683, which drops from
  the /COIN IN rail (dot at its top, ≈ (5698,3751)) through a dot at pin 12
  ((5686,4437), a full ink disc) and on down; 11 ← IC68 4 (GAME). The
  vertical crosses the IC68 4 and IC68 6 lines without dots (ink 182 and
  191 of 253 in a 9-pixel disc, against 244 at the pin-12 dot).
  60c = NOR(/COIN IN, GAME).
- **IC60 d** (8, 9 → 10) = NOR(60c, IC68 6 = NOT SHIFT) → SHIFT A (D-3).
- **IC68 13 → 12**: 13 ← the same /COIN IN vertical (its foot). So 12 =
  COIN IN.
- **IC67** (9, 10 → 8, OR body): 9 ← IC68 12 (COIN IN); 10 ← "アラーム
  (D-5/7)" (alarm) arrow. 8 → east along y ≈ 5010 to a dot at (7040,5010)
  → IC57 3, and down to IC57 5.
- **IC57** is a **7417** (open-collector buffer): no bubbles, the output
  slash, "17" pencilled below section 5 (the drafter's type convention).
  - 3 → 4: out north along x ≈ 8115 to y ≈ 3060, west to x ≈ 7640, north
    along the wire written "DIP SW. 2 (4P)" to **R406** (100 Ω), whose top
    is the output node between R413 1K and R407 (pad 13 SOUND OUT). So R406
    does not go to ground: IC57 4 pulls it low. With IC67 low (no COIN IN
    and no alarm: attract) the output is shunted, so attract mode is
    silent except for the D-5 alarm.
  - 5 → 6: → "BACK SOUND STB. (D-2/7)", the same gate signal.
- The "DIP SW. 2 (4P)" label is written along R406's wire, beside the
  switch drawn between R424 100K and C114 2.2 µF in the BACK SOUND column;
  read as naming that switch (another contact of the 4-pole DIP SW. 2,
  whose contact 2–15 sets the explosion gain), not a contact in R406's
  wire (no switch symbol there).
- The back-sound column's resistor is **R424** 100K (the earlier "R420"
  misread). Mixer bus dots: R410 220K (RESCUE, D-2), R409 82K (PRINT
  OTHER CAR, D-7; read 2 November, below), R424 (via the switch and C114, BACK SOUND, D-2).

## Check before the logic, 1 November 2026 (Claude)

Every value and wire of the explosion, skid and EXTEND paths was read again
on the scan before modelling them. Crops (stored-image pixels):
(2900,650,4400,1500), (3600,1250,3900,1550), (4300,650,5400,1300),
(2900,1500,4300,2300), (4200,1550,5900,2350), (1550,2150,2750,3750),
(1500,3600,2400,4400), (2600,2400,3900,3400), (2900,3300,3700,4500),
(3500,1300,5300,3400), (1300,4250,2900,6100), (2600,4100,4800,6300),
(1700,800,3300,2100).

Corrections and closures:

- **R396 is 27 kΩ**, printed "27K" without a decimal point (R395 next to
  it is printed "4.7K" with one). The upper band-pass (R395 4.7K, R396 27K,
  C95/C96 0.01 µF, R391 220K) is centred near 540 Hz, Q about 3.7; the lower
  one (R388 4.7K, R389 8.2K, C90/C91 0.047 µF, R387 220K) near 130 Hz.
- **Envelope to MC3340**: IC61 a's envelope (C77? 10 µF, R374 330K, about
  3.3 s) goes through the follower **IC66 d** (12 +, 13 −, 14 out) and the
  inverter IC66 c; IC66 c pin 8 runs right, up to the top run and down to
  **IC65 pin 2** (the upper, 540 Hz chain). IC61 b's envelope (C78 10 µF,
  R375 1M, about 10 s) goes through the follower **IC64 d** (12, 13, 14) and
  the inverter IC64 c; IC64 c pin 8 runs right and up to **IC71 pin 2**
  (the lower, 130 Hz chain). So the 540 Hz band fires at the crash and the
  130 Hz rumble about 63 ms later and lasts longer.
- The inverters' + inputs: R368 8.2K from 12 V and R366 3.9K to GND, 3.87 V:
  control = 7.74 V − envelope.
- 74123 parts: IC61 a C76 4.7 µF (タン) / R360 47K; IC61 b C86 4.7 µF /
  R372 47K; IC69 a C87 4.7 µF / R373 47K. IC61 b's A (pin 9, active low)
  comes from IC69 Q (pin 13); its B (10) and CL (11) go to Vcc. Each Q has
  a 330 Ω pull-up (R377, R376) and an MA150 (D30, D31) into its 10 µF.
- MC3340 coupling: IC65 in ← R397 33K ← C82 1 µF ← IC63 b pin 7; out 7 →
  C83 1 µF → R365 150K → IC66 a pin 2. IC71 in ← R398 33K ← C98 1 µF ←
  IC63 a pin 1; out 7 → C99 1 µF → 100K (also labelled "R397") → IC66 a
  pin 2. Pin 6 of each: 680 pF to GND.
- **R390 is 68K** (the 6 looks written over another digit; reads 68K).
- Skid triangle: IC64 b + (5) ← R392 51K from the 6 V rail and R393 100K
  from out 7; − (6) ← C94 10 µF (タン) to GND, R394 6.8K from out 7. IC64 a
  (3 +, 2 − tied to out 1) follows C94; out 1 → R390 → IC63 d pin 13.
- 555: RES 4 ← the 7432 pin 6 run; DIS 7: R383 47K from Vcc, R384 47K to
  TH 6 / TR 2; C89 4700 pF (マイラ); CON 5 ← C81 33 µF (タン) ← IC63 d 14;
  OUT 3 → R405 10K → node → R404 10K to GND; node → C101 10 µF (ケミ) →
  R403 220K (mixer). The 555 runs on 5 V ("555 (5V)").
- EX.CP pad 14 (R425 470 Ω to Vcc) → 2.2 µF (ケミ) → R402 220K (mixer).
- The S2688 (VSS pin 4 at 12 V, VGG and VDD to GND): R361 is still read
  150K (the last glyph is malformed; the drafter writes ohms as a
  different glyph, e.g. R377 "330Ω"), giving the noise amplifier a gain of
  −0.34. Not closed.

Still open: R361's glyph; R423's DIP switch position (it is set on the
board, not in the drawing); the MC3340 supply pins are not drawn (taken as
12 V, like D-3's IC52).

## R408 and R409, 2 November 2026 (Claude)

Read again before the other cars (D-7) were connected to the mixer. Crops
(stored-image pixels): the bank (6200,1800,8000,3400); the four values
(6640,2380,7400,2600); each glyph turned to read left to right, R408
(6650,2380,6710,2560) and R409 (7210,2380,7270,2560), at three times.

- **R408 39K** (HI SCORE SOUND OUT, D-5): the first glyph is open on the
  left, a 3 like the drafter's other 3s, not a 5 (no upright stroke on
  top) and not an 8.
- **R409 82K** (PRINT OTHER CAR, D-7): the first glyph is a closed double
  loop, an 8; the 3 beside it on R408 is open. The earlier "32K" was the
  same glyph at the overview's scale.
- In order along the bus in that crop: 39K (R408), 51K (R412, SLIP ZONE),
  220K (R410, RESCUE), 82K (R409, OTHER CAR).

The other cars' model uses R409 = 82K (tests/sound/d67_model.py).

## R414 and R361 against the other scans, 4 November 2026 (Claude)

Read at full resolution in this page's scan, in
`ArcadeGameManualMonacogp_1.pdf` page 18 and in
`MonacoGPStandModel4200445.pdf` page 24. The three are copies of one drawing,
not independent sources: they settle what is written, not what a board has.

- **R414: 22K.** Clear in the manual and the stand-model scan. Item U4's value
  question is closed.
- **R361: 150K, by reasoning.** All three show the same glyph after "150", shaped
  like an R. The drafter writes ohms with a different sign (R406's 100 Ω, the
  470 Ω pull-ups). With R362 51K, 150 Ω would give the stage a gain of 340 and
  clip it on the S2688's swing; 150K gives 0.34. Only a board can confirm it.
