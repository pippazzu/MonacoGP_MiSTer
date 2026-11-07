# Sheet H compare: Pro page 11 against the original (Pro Monaco GP)

Date 2026-11-06, issue #86. This compares Pro sheet H (PDF page 11, 96822-P
D-4/5, "OTHER CAR の絵出しとコントロール") with the original sheet H as
transcribed in `docs/trace/SHEET_H_TRACE.md`. The comparison goes by function
and net, not by IC number. It covers every block of the original trace: the
inputs and outputs, the frame counter, the divider, the restart delay, the
three position channels with their one-shots, the AREA decode, PR-39, PR-132
and /F-SOUND. Three things were already traced for Pro and are left out:
/OTHER CAR into sheet N, and PR-38-7 and PR-38-9 into sheet N
(`BONUS_INPUTS_TRACE.md`). This is a comparison, not a full pin-level
transcription: rows marked "same" were matched by structure and by the pin
numbers that show at 0.6 to 1x, not walked wire by wire.

**Main results**

1. Most of the sheet is unchanged: the frame counter, the 7 MHz divider and
   the PR-38 load path, the restart delay, the counters and load
   multiplexers of all three channels, the enables of channels 1 and 2, the
   PR-39 counter, the AREA decoder, PR-132 with its output multiplexer and
   inverters, and the /F-SOUND flip-flop.
2. **Channel 3's image enable is redesigned.** On the original, the enable
   of the third 367 buffer is a NAND of AREA 1 and the IC75 flip-flop (with
   470p). On Pro it is a NOR (43) of two ANDs: one (145) with the
   replacement of the IC75 flip-flop (137), and a new one (115) fed by a new
   flip-flop (177) and a three-input gate (67). The 367's strobe input (A6,
   pin 14) is tied to its own enable, not to the 1010 compare. The high
   counter of channel 3 has two decodes (125 and 96) plus a combining gate
   (138), where the original has one. Much of the new wiring is drawn in
   faint dash-dot strokes and was only partly followed.
3. **Three new off-sheet signals:** SLIP from (D) on pad BH (probably into
   177's D input; the circled letter is written sideways and reads as D,
   probable, and sheet D sends SLIP on pad EH, which faces BH on the
   straight E-to-B cable; see `SHEET_D_COMPARE.md`), EXTEND from (A) (an arrow at the bottom, a dash-dot wire
   up into the new block), and an output arrow to (G) whose label reads like
   "NI. AP" or "W1. AP" (uncertain). Pro sheet G has an input
   INI.AP from H (`SHEET_G_COMPARE.md`), which fits "NI. AP" with a lost
   first letter (cross-sheet match, not a reading of this label).
4. **The direction latches' side inputs change.** The original ANDs
   /L1-SIDE (D) with /L2-SIDE (M), and /R1-SIDE (D), /R2-SIDE (M) and
   /R-L-SIDE (M). Pro has two 2-input gates (115) taking /L2-SIDE (M, pad
   CC) with /L3-SIDE (G), and /R2-SIDE (M, pad C5) with /R3-SIDE (G). The
   gates are drawn as NOR, where the original is drawn as AND. Nothing from
   sheet D enters here any more.
5. **One-shot capacitors are smaller.** Channel 2's two one-shots have
   47 µF (originally 220 µF), and channel 1's second one-shot has 10 µF
   (originally 100 µF). Channel 1's first one-shot has the same "10?µ"
   glyphs as the original's C35.
6. **The SP. CONT. capacitor is 1000p** (original C36 470p). Its designator
   reads C44 and the pad AR (original AL).
7. A new frame-counter output: Vs/512 on pad B8 to sheet B.

## Sources and method

- Pro: `pro/schematics/promonacogp420-0525_1.pdf`, SHA-256
  `9473d6dd84418129f389e7c5becc0f6f7d105611e1d508ff60bbc062a27432f2`,
  PDF page 11, rendered with PyMuPDF at `Matrix(1, 1)`, upright,
  10167 × 6617 pixels. Every Pro box is (left, top, right, bottom) on that
  render.
- Original: `docs/trace/SHEET_H_TRACE.md` and
  `schematics/pages/page28-sheet-H.png`, rotated 180° into the trace's
  frame R. The two drawings share a layout: a point (x, y) on the Pro render
  sits at about ((x − 1500) × 1.019 + 1917, y + 111) in frame R. Pro and
  original crops of the same area were set side by side at 0.58 to 0.7× for
  a first pass. Every difference found was then read at 1 to 4×. Faint
  strokes were darkened (grey below 235 set to black) where noted.
- Reading rules as in `pro/README.md`: a drawn dot is a junction, and a
  crossing is not. Gate function comes from the drawn symbol, and pin
  numbers are the printed ones.
- Confidence: **clear** means read directly with no competing reading.
  **Probable** means one reading fits much better, but the scan is not
  clean. **Uncertain** means the scan does not settle it.
- Excluded, already traced for Pro: /OTHER CAR to (N), PR-38-7 and PR-38-9
  to (N) (`BONUS_INPUTS_TRACE.md`, sections "/OTHER CAR" and "PR-38-7 and
  PR-38-9").
- No MAME, emulator, other core, KiCad redraw or footage was used.

## Comparison by function

IC numbers are given as printed on each drawing. Pro designators are read
from the scan and several are faint. They identify parts here; they prove
nothing about equivalence.

### Off-sheet inputs

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| /H8, /H6 | pads CB, C2 → IC75 second half /CLR, D | pads CB, C2 → F-SOUND flip-flop (printed 47, `74/2`) /CLR, D | (700,600,1100,800); (6200,3250,6800,3700) | same | clear |
| /V8 | pad CN → CET of the three high counters | pad CN, same route across the top | (700,800,1100,900) | same | probable |
| /VS | pad C12 → IC79.13, IC86.12 | pad printed `C1`-like (second character not read) → frame counter CP 13 and the /HS NOR (pins 5, 6 → 4) | (700,850,1300,1050) | same function; pad name not settled | probable |
| /HS | arrow (F) → IC86.11 | arrow (F) → the same NOR | (700,950,1300,1050) | same | clear |
| Side inputs to the direction latches | /L1-SIDE (D, CC), /L2-SIDE (M, C4) → IC85 AND 4, 5 → 6; /R1-SIDE (D, CD), /R2-SIDE (M, C5), /R-L-SIDE (M, CE) → IC85 9, 10, 11 → 8 | /L2-SIDE (M, pad CC), /L3-SIDE (G, arrow) → 115 pins 2, 1 → 3; /R2-SIDE (M, pad C5), /R3-SIDE (G, arrow) → 115 pins 5, 4 → 6. Both gates are drawn as OR bodies with an output bubble and no input bubbles (NOR) | (750,1100,1550,1550) | differs | clear for the labels and pins; gate function probable (see U2) |
| BRIDGE AP | pad C18 → /CLR of the four one-shot halves | pad (label `C1?`, faint) → the same four /CLR pins | (700,1550,1300,1750) | same | probable |
| Vs/2 (same page) | arrow → IC107.11, IC30.5 | arrow → channel 2 select gate and the NAND 95 | (700,1850,1300,2000) | same | probable |
| /EXT. 500 | arrow (F) → IC106.4 (AND with PR-39 D4) | arrow (F) present at (1450,3536); where it ends was not settled (see channel 3 below) | (700,3450,2700,3600) | can't settle | uncertain |
| Vs/4, Vs/256, Vs/512, Vs/1K (same page) | Vs/4 → IC30.4, PR-132 A8; the others → PR-39 A0–A2 | the same arrows, Vs/4 with its junction | (700,3550,2000,3900) | same | probable |
| /SP. IRREG. | arrow (F) → IC106.12 (AND with ACCE. C) | arrow (F) → AND (pins 10, 9 → 8) beside the comparator | (700,4050,3000,4250) | same | probable |
| /CAR SP. CONT. | pad C3 → IC86.5; C29 470p | pad C3 → NOR 112 (6, 5 → 4); 470p printed C31 | (700,4150,1800,4450) | same; designator differs | clear |
| CAR CONT. CL. | arrow (A) → IC112.2 | arrow (A) → the PR-39 counter's CL (393 half printed 93) | (700,4400,1800,4550) | same | clear |
| 14MHz | pad CV → IC112.13 | pad CV → restart-delay counter (393 half printed 120) CP 13 | (700,4500,1900,4700) | same | clear |
| /(V-CA × V8) | pad CS → IC108.1, IC86.9 | pad CS → the PR-38 multiplexer select and the NOR (pins 13, 12) | (700,4800,2800,5000) | same | probable |
| 7MHz | arrow (F) → IC101.2, IC102.2 | arrow (F) → the two divider 161s | (700,4900,2800,5050) | same | probable |
| ACCE. A–D | arrows (F) → PR-38 A0–A3; B, C, D also to IC113 and IC106 | the same, with junction dots on B, C, D as on the original | (1300,4950,2100,5350) | same | clear |
| SP. CONT. | pad AL, C36 470p to GND → PR-38 A4 (14) | pad AR (probable), C44 1000p to GND → PR-38 (printed 127) A4 (14) | (1250,5230,1950,5520) | differs (value) | value clear; designator and pad probable |
| SLIP | none | new pad BH with "SLIP" and a sideways circled letter above it, read as (D) (probable; sheet D sends SLIP on pad EH, which faces BH on the straight E-to-B cable); a thin wire down at x ≈ 3780, turning right at y ≈ 3186, probably into 177's D (pin 2) | (3650,500,3900,3250) | differs (new) | probable for the route, uncertain for the end |
| EXTEND | none | new arrow "EXTEND" from (A) at the bottom (x ≈ 4465); a dash-dot wire runs up into the channel 3 block. Its end was not followed for certain: it reaches about y ≈ 3950 near 48's lower input, and 177's /CLR (pin 1) also drops on that line | (4200,3700,4900,6250) | differs (new) | arrow and label clear; ends uncertain |

### Off-sheet outputs

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| Vs/4 (G), Vs/2 (F), Vs/8 (F, G), Vs/16 (A, F, G), Vs/32 (F, G), Vs/64 (F) arrows | IC79, IC78 outputs | same arrows and destinations | (7000,650,8800,2450) | same | clear |
| Vs/2, Vs/4 pads | pads B22, BY, letter "e"-like (trace U1) | two filled pads, letter reads (B); pad names `B2?`, `B?` not read | (7000,650,8800,1100) | same net; circled letter differs or is better drawn | probable |
| Vs/16 pads | B21 (B); A21 (I) through a 7407-type buffer | B21 (B); A21 (I) through a buffer (pins `9 → 8`-like, designator not read) | (7000,1000,8800,1300) | same | probable |
| Vs/32, Vs/64 pads | B20, BX, letter N-like | B20 (N), BX (M) | (7000,1300,8800,1500) | same nets; letters read more clearly | probable |
| Vs/2, Vs/4, Vs/256, Vs/512, Vs/1K (to the same page) | five braced arrows | the same five | (7000,1650,8800,2350) | same | clear |
| Vs/512 to (B) | none | new pad B8, (B), branching from the Vs/512 output | (7300,2200,8000,2450) | differs (new) | probable |
| /OTHER BODY, /OTHER TIAR | pads BR, BS; arrow /OTHER BODY (F) | the same | (6800,3800,7600,4250) | same | clear |
| /F-SOUND | pad A19 from IC29 (buffer of IC75 second half /Q) | pad (name `A`, second character not read) from a buffer of the flip-flop printed 47 | (6200,3250,7400,3700) | same | probable |
| AREA 1–5 | pads CL, CK, C9, C10, C11 | the same pad names | (6800,4500,7400,5050) | same | probable |
| PR-38 D0–D3 | pads C16, CT, C17, CU, Japanese labels (U4) | the same four pads and labels | (2600,5800,3000,6300) | same | probable |
| Output to (G), "NI. AP" or "W1. AP" | none | new down-arrow to (G) at x ≈ 4690. Its dash-dot wire goes up to a horizontal at y ≈ 4370, which runs left to the junction at 108.12, probably from 125's output (see channel 3) | (4200,4300,4900,6250) | differs (new) | arrow clear; label and source uncertain |

### Internal blocks

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| Frame counter | IC79 second half and both halves of IC78, `393/2 ×3` | the same three 393 halves, `393/2 ×3`. Designators 92, 92, 93: the third stage is a separate package (pins 1, 2, 3, 4, 5) | (7000,650,8800,2450) | same function; packaging differs | clear |
| Divider and position clock | IC102, IC101, IC80 NAND, IC87 JK, C41 and C42 470p | 161s printed 142 and 141, 3-input NAND 179 (10, 9, 11 → 8), 107/2 JK printed 37, two 470p capacitors (designators faint) | (2300,4900,4000,6100) | same | probable |
| PR-38 nibble multiplexer | IC108 (157) | 157 printed 134 | (2300,4900,3000,5600) | same | probable |
| Restart delay | IC112b, IC113 (7485), IC81c, IC114 inverters, IC106 AND | 393 half 120, 7485 printed 128, 279 latch 129, inverters 125, the AND | (1300,4000,3300,4750) | same | probable |
| Channel 1 counters, load multiplexer, 1010 compare | IC90/IC96, IC89, IC122 NOR and IC123 NAND | 161s (designators faint, `104`- and `103`-like), 157 printed 97, NOR 122 (12, 11 → 13), NAND 95 (1, 2, 13 → 12) | (2300,550,4000,1700) | same | probable |
| Channel 1 select | IC107 NOR of both one-shot Qs and IC30 NAND(Vs/4, Vs/2) | 3-input NOR at the top and a NAND printed 95 (11; 13, 12) on Vs/4 and Vs/2 | (700,800,2400,2000) | same | probable |
| Channel 1 direction latch | IC95 OR gates into IC81a (279) | two gates drawn as AND bodies with bubbles on inputs and output (OR), into 279 printed 129 | (1450,1050,2350,1650) | same, apart from the side gates above | probable |
| Channel 1 one-shot A | C35 100µ (trace U2, settled 100µ), R21 47K | C53, value printed `10Cµ`-like (the same glyphs as on the original), R31 47K | (1750,1300,2150,1500) | can't settle; it may well be the same | uncertain |
| Channel 1 one-shot B | C32 100µ, R18 47K | C51 **10µ**, 47K (designator `R20`- or `220`-like) | (1700,1880,2050,2050) | differs | probable |
| Channel 2 counters, multiplexer, compare | IC104/IC109, IC103, IC122, IC123 | 161s 118 and 117, 157 printed 125, NOR 13? and NAND 39 (4, 3, 5 → 6) | (2300,1600,4000,2700) | same | probable |
| Channel 2 select | IC107 9, 10, 11 → 8, NOR of IC120 Qs and Vs/2 | gate drawn faint, output at the same place | (2400,1880,2700,2050) | can't settle | uncertain |
| Channel 2 one-shot A | C34 220µ, R20 47K | C52 **47µ**, R30 47K | (1600,2200,2100,2400) | differs | probable |
| Channel 2 one-shot B | C31 220µ, R17 47K | C50 **47µ**, R23 47K | (1500,2750,2200,2950) | differs | clear |
| Channel 3 counters and direction latch | IC117/IC116, latch IC81b with IC88 OR gates and IC82 inverter | 161s 111 and 110, 279 printed 129 with two gates (9, 10 → 8 and 4, 5 → 6), inverter 124 | (700,2700,3400,3550) | same | probable |
| Channel 3 high-counter decode | IC122 NOR(Q0, Q2) and IC123 NAND(that, Q1, Q3), low on 1010, to IC124 A6 and to the latch gates | NOR 102 into a 3-input **AND** 125 (no output bubble), plus a separate 3-input NAND 96 (11, 10, 9 → 8) on high-counter outputs, and a gate 138 drawn pointing left (inputs 8, 9 on the right, output 10 with bubble on the left). The output of 125 (pin 1-like) leaves by a dash-dot wire. Which counter bits feed 96, and where 96.8 and 138.10 go, were not settled | (3200,3000,4500,3800) | differs | gates clear; nets uncertain |
| Channel 3 image enable | IC68 NAND(IC75.Q, AREA 1) → IC124 /G1, /G2, with C43 470p; IC124 A6 ← compare | NOR 43 (11, 12 → 13; OR body, output bubble) → 367 (printed 112) pins 1 and 15 **and pin 14** (a dotted box joins A6 to the enable). 43.12 ← AND 145 (9, 10, 11 → 8), with 145.10 ← flip-flop 137's Q (9). 43.11 ← gate 115 (10, 9 → 8), with 115.10 ← 67.6, which also runs left at y ≈ 3635. 67 has three bubbled inputs (5, 4, 3 → 6), the top one from flip-flop 177 (`74/2`; D 2, CK 3, Q 5, /Q 6, /CLR 1). 177's CK is on the same net as 137's CK. 145.9, 145.11 and 115.9 come from dash-dot wires not followed. No capacitor is drawn on the enable | (4300,2950,5500,4300) | differs (new block) | clear for 43, 145.10, the A6 tie and 115.10; the rest uncertain |
| IC75 first half / its D gate | IC106 AND(/EXT. 500, PR-39 D4) → IC75.2; IC66 AND(clock, AREA 1) with 470p → IC75.3 | gate 108 (13, 12 → 11) drawn as **OR** (no bubbles), 13 ← PR-39 pin 5 (D4), 12 ← a junction on the dash-dot wire. 108.11 → gate 48 (drawn dashed, 12 and a second input → 11) → flip-flop 137 D (12). AND 130 with **C46 470p** → 137 CK (11) | (3700,3700,5000,4400) | differs (an OR and an added gate 48 in the D path; the clock is the same) | 108's body probable; 48's inputs uncertain |
| Channels 1 and 2 enables | IC93 ANDs, IC99 and IC92 (7474), IC100 (7450) | the same structure: ANDs (130-like and 13?), 7474s printed 116 and 127, 7450s printed 131. The "HI47"-like note is drawn at the same output | (3900,1100,5600,2700) | same | probable |
| PR-39 and its counter | IC105, IC112 first half, IC106 9, 10 → 8, IC86 5, 6 → 4 | PR-39 (288, designator `10?`), 393 half 93, AND (1, 2 → 3), NOR 112 | (700,3700,4100,4300) | same | probable |
| AREA decoder | IC94 (74259), C28 470p on AREA 3; AREA 4 = IC106 1, 2 → 3 AND IC107 3, 4, 5 → 6 | 259 printed 114, C42 470p on the same line; AREA 4 by gates 118 (13, 12 → 11) and 108-like 3-input (4, 5, 3 → 6) | (5000,4300,6300,5100); (3900,4900,5800,5600) | same | probable |
| PR-132 and output | IC111 (µPB425-like), IC118 (157), IC114 inverters, RA3 5.6K | PR-132 (µPB425-like, printed 91), 157 printed 98, inverters to the same pads, RA2 5.6K | (5500,2700,7200,4200); (5000,650,5900,1100) | same | clear |
| /F-SOUND flip-flop | IC75 second half: D /H6, CK the strobe line, /CLR /H8; /Q → IC29 → A19 | flip-flop 47 (`74/2`): the same pins and nets | (6200,3250,7400,3700) | same | probable |
| Decoupling | 10µ, 470µ, 0.1µ by "µPB425用" | the same three values and note | (7600,3500,8200,4300) | same | probable |
| Supply pad groups | Vcc A33–A36, AM–AR, F20–F23, Fm–Fr; GND A1–A5, AA–AE and a C group | Vcc A33–A36, Am–Ar, CZ0–CZ3, CX–Ca(?); GND A1–A5, AA–AE, CZ5–CZ8, Cc–Cf(?) | (8300,3500,9600,6100) | labels differ; not checked pad by pad | uncertain |

## Differences

1. **Side inputs (D1).** Pro takes /L2-SIDE (M) and /L3-SIDE (G), /R2-SIDE (M)
   and /R3-SIDE (G), each pair into a 2-input gate 115 drawn as NOR. The
   original takes /L1, /L2 and /R1, /R2, /R-L into ANDs (drawn as OR bodies
   with bubbles everywhere). Box (750,1100,1550,1550). Confidence: labels
   and pins clear, gate function probable. For reuse, the Monaco module's
   side-input AND cannot be used as is. The sources of /L3-SIDE and
   /R3-SIDE on Pro sheet G, and their polarity, decide whether the NOR is a
   real logic change or a redraw of the same function (U2).
2. **One-shot capacitors (D2).** C51 10 µF (original C32 100 µF), C52
   47 µF (original C34 220 µF), C50 47 µF (original C31 220 µF). The
   resistors stay 47K. Boxes (1700,1880,2050,2050), (1600,2200,2100,2400),
   (1500,2750,2200,2950). Confidence: C50 clear, C51 and C52 probable. For
   reuse: the speed-change one-shot widths of channels 1 and 2 become
   shorter. With 0.28·R·C, 47K and 47 µF give about 0.6 s, where the
   original's 220 µF gives 2.9 s. 47K and 10 µF give about 0.13 s, where
   100 µF gives 1.3 s.
3. **SP. CONT. capacitor (D3).** 1000p (C44), not 470p (C36). Box
   (1250,5230,1950,5520). Confidence: value clear. It only loads a static
   PROM address line, so it has no logic effect.
4. **Channel 3 decode and image enable (D4).** A redesigned block, described
   in the table. The parts that read clearly:
   - 367 A6 (strobe) is tied to its own /G.
   - /G = NOR(115.8, 145.8).
   - 145 is a 3-input AND that takes the replacement of the IC75 flip-flop
     (137's Q).
   - A second enable path runs through 115, from 67 and a new flip-flop 177
     whose clock is shared with 137.
   - The high counter has an AND decode (125) and a NAND decode (96).

   Box (3200,2950,5500,4400). Confidence: mixed, mostly uncertain on the
   dash-dot wires. For reuse: the Monaco channel 3 enable cannot be reused;
   this block needs its own pin-level trace (U1).
5. **IC106 replacement in the D path (D5).** Gate 108 is drawn as OR (no
   bubbles) where IC106 is an AND. A dashed gate 48 is added between it and
   137's D. Box (3700,3700,5000,4400). Confidence: 108's body probable, its
   pin 12 source and 48's second input uncertain. This is part of D4's trace.
6. **New signals (D6).** SLIP from (D) on pad BH, EXTEND from (A), and the
   "NI. AP"-like output to (G). Boxes (3650,500,3900,3250),
   (4200,3700,4900,6250). Confidence: arrows clear, routes uncertain.
7. **Vs/512 to (B) (D7).** A new pad B8 on the Vs/512 output. Box
   (7300,2200,8000,2450). Probable. It has no effect on sheet H.
8. **Packaging only (no logic effect).** The frame counter uses a third 393
   package. RA3 is now RA2, with other pin numbers on the network. The
   designators of nearly every IC differ. Pro pads are drawn filled.

## Known values

- **PR-38's SP. CONT. capacitor: confirmed 1000p.** At 2× on
  (1300,5250,1950,5520), the value reads `1000p` with no competing reading
  (clear). The designator reads **C44**, probable: the two characters after
  C are open-topped 4s. `BONUS_INPUTS_TRACE.md` had it as `C88`-like. The
  pad reads **AR** (probable), against AL on the original; the second
  letter has a closed loop with a tail. The capacitor is on the pad line
  between the pad and PR-38 pin 14, to ground, as on the original. The
  other two known values in issue #86 (sheet F's C54 and the pool
  one-shot's 22 µF) are not on sheet H and were not checked here.

## Still uncertain

- **U1: channel 3 block.** Not settled: the sources of 145.9, 145.11, 115.9,
  67.4 and 67.3; the second input of 48; where 96.8, 138.10 and 125's
  output go; where /EXT. 500 now goes; whether 177's /CLR is on the EXTEND
  wire; whether 177's Q or /Q drives 67 (both leads run down to the same
  height). Most of this wiring is dash-dot on the scan. What would settle
  it: a column and row walk of each dash-dot line on a darkened render at
  2×, as for the sheet N trace. A better scan would settle it faster.
- **U2: side-gate function.** 115 is drawn as an OR body with an output
  bubble and no input bubbles (NOR). Its pins 1, 2 → 3 and 4, 5 → 6 fit a
  7400, 7408 or 7432, not a 7402 (2, 3 → 1). The scan may have lost the
  input bubbles, which would make it a NAND. What would settle it: the
  polarity of /L3-SIDE and /R3-SIDE where Pro sheet G drives them, and a
  4× look for faint bubbles on (950,1150,1250,1500).
- **U3: C53.** It is drawn with the same glyphs (`10Cµ`) as the original's
  C35, settled there as 100 µF. Pro C51 next to it clearly reads `10µ`, so
  C53 may be 10 µF or 100 µF.
- **U4: the "NI. AP" label.** It is read upside the arrow. The first two
  characters could be N, W or M and 1 or I. Sheet G's matching input would
  settle it.
- **U5: channel 2 select gate.** It is drawn faint at (2400,1880,2700,2050).
  Its function and pins were not read.
- **U6: the /VS pad name** (`C1?`) and the BRIDGE AP pad name (`C1?`). They
  do not change the wiring.

## Not checked

- The supply pad groups were not checked pad by pad, nor their labels.
- RA2's pin-to-line assignment.
- Pin-level checks of the "same" rows beyond the structure and the pin
  numbers that show at 0.6 to 1×. These rows rest on the drawings being the
  same layout, compared crop by crop.
- /OTHER CAR, PR-38-7 and PR-38-9 into sheet N (excluded, see
  `BONUS_INPUTS_TRACE.md`).
- Where EXTEND and the "NI. AP" output come from or go to on sheets A
  and G. SLIP's source on D was matched by pad only (EH to BH).
- Pro's PR-38, PR-39 and PR-132 contents.

## Short report

54 rows compared: 38 same, 12 differ, 4 can't settle (/EXT. 500's
destination, C53, the channel 2 select gate, the supply pad labels).
Differences: the side-input gates and sources; three one-shot capacitors
(10 µF, 47 µF, 47 µF); the SP. CONT. capacitor (1000p); the channel 3
decode and image enable; the IC106 replacement (an OR and an added gate
48); the new SLIP input, EXTEND input and "NI. AP" output; and the new
Vs/512 pad to sheet B. The known value is confirmed: SP. CONT.
capacitor 1000p, designator C44 (probable), pad AR (probable). The channel 3
block needs its own trace before the Pro core can reuse the Monaco sheet H
module for that channel. The rest of the sheet can be reused, with the
one-shot widths and the side inputs changed.
