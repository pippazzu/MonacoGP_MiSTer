# Sheet M compare: Pro page 17 against the original (Pro Monaco GP)

Date: 2026-11-06. Issue #86. Function-by-function and net-by-net comparison
of Pro sheet M (manual 420-0525, PDF page 17, 96823-P D-5/5) with the
original sheet M (420-0358 page 33, 96578-P D-5/5) as transcribed in
`docs/trace/SHEET_M_TRACE.md`. Every block of the original trace (rescue car,
rescue timing, lives and GAME OVER, signs, dummy cars, bridge) was looked
up on the Pro scan and its parts, values and connections compared. The +200
path (PR-54 IC130, IC129, their enable gating and the V-④ route) is left
out: it is in `SHEET_M_C_PLUS200_TRACE.md`. IC numbers differ between the
boards and are not used as evidence.

**Main results**

1. **The rescue car, rescue timing, lives counter, GAME OVER, signs, dummy
   cars and bridge PROM logic are wired as on the original**, gate for gate,
   with the same tie patterns and the same one-shot values (1.5 µF, 47 kΩ
   probable). Only IC numbers and pin numerals of equivalent gate sections
   change.
2. **The side-collision outputs are combined on M.** /L1-SIDE and /R1-SIDE
   now come into M from sheet D, and two added AND gates give
   /L2-SIDE (F4) = /L1-SIDE AND /(bridge · EXT. 500 · V7), and
   /R2-SIDE (F5) = /R1-SIDE AND /R-L-SIDE AND /(bridge · EXT. 500 · /V7).
   On the original these ANDs are on sheet H (its IC85, pins 4, 5 → 6 and
   9, 10, 11 → 8). /R-L-SIDE no longer leaves the sheet: there is no pad FE.
   The function seen by H's direction latch is the same, if Pro sheet H takes
   F4 and F5 alone (to check in the sheet H compare).
3. **/RESCUE (Y) and /BRIDGE (W) go to sheet D instead of sheet F.** Both
   are marked (C) and (D), with no inter-board pad (the original had pads
   EB and EH to F). Pro sheet D has matching input arrows at its lower edge.
   Probable.
4. **Added capacitors:** C39 3300 pF, C38 1000 pF and C37 1000 pF on three
   outputs of the rescue colour multiplexer; C30 220 pF, marked `*` and
   `ADJ.`, on /SIG. (Y); a second 470 pF on the rescue counter's carry.
   None of these is on the original.
5. **EXTEND is now `D-EXTEND` from sheet B.** The same two pins (the
   rescue timer's clear and the dummy-area NAND) take /D-EXTEND and
   D-EXTEND (B), where the original takes /EXTEND and EXTEND from (C).
   Whether D-EXTEND is the same signal is not settled on this sheet.
6. None of the three known values named in the issue (PR-38's SP. CONT.
   capacitor, sheet F's C54, the pool one-shot's 22 µF) is on sheet M.

## Sources and method

- Pro: `pro/schematics/promonacogp420-0525_1.pdf`, PDF page 17, rendered
  with PyMuPDF at `Matrix(1, 1)`, upright, 10159 × 6617 pixels. Every box
  below is (left, top, right, bottom) on that render. Crops were read at
  0.5× to 4×.
- Original: `docs/trace/SHEET_M_TRACE.md` (complete pin-level trace, cited
  by its IC numbers), with `schematics/pages/page33-sheet-M.png` looked at
  directly for the rescue counter's carry capacitors and for the EXTEND,
  Vs/16 and /GAME labels. Original IC numbers below are the original
  trace's. Sheet H's side ANDs are from `docs/trace/SHEET_H_TRACE.md`
  (IC85).
- Reading rules are those of `pro/README.md`: a dot is a junction, a
  crossing is not. Gate function comes from the drawn body (OR body with
  bubbles on inputs and output is AND; AND body with bubbles on inputs and
  output is OR; AND body with input bubbles is NOR).
- The Pro scan has a blank vertical strip at about x 2930–3050 over the
  PR-138 and PR-139 address risers (y about 750–1300 and 3800–4250). Wires
  that enter it cannot be followed through it.
- Confidence: **clear** (read directly, no competing reading), **probable**
  (one reading fits much better, but the scan is not clean), **uncertain**.
- Verdicts: **same**, **differs**, **can't settle**.
- No MAME, emulator, other core or KiCad redraw was used.

## Comparison by function

Gate functions and nets only; pin numerals of Pro gate sections are given
where read, and a different section of the same package type is not a
difference.

### Rescue car counter and loading

| Function / net | Original (trace ref) | Pro reading | Pro box | Verdict | Confidence |
|---|---|---|---|---|---|
| Low counter | IC36 74161: /CLR, P, T Vcc; CP 7M; A–D from IC43; QB → mux S; QC, QD → PR-138 | IC119 `(161)`: 1, 7, 10 Vcc; 2 ← 7M; 3–6 ← IC118; 9 /LOAD; 15 → IC112.10 | (1100, 1300, 2500, 2200) | same | clear |
| High counter | IC37 74161: A, B Vcc; C, D GND; T ← IC36.15; QA, QB → PR-138; QC, QD → IC44 | IC112 `(161)`: 3, 4 Vcc; 5, 6 GND; 10 ← IC119.15; 1, 7 Vcc | (1900, 1300, 3000, 2200) | same | clear |
| Load value mux | IC43 74157: 1A, 3A GND; 2A, 4A Vcc; 1B–3B GND; 4B Vcc; /G GND; S ← IC42.6 | IC118 `(157)`: 2, 11 GND; 5, 14 Vcc; 3, 6, 10 GND; 13 Vcc; 15 GND; 1 ← IC111.12 | (1400, 1650, 2050, 2050) | same | probable (two tie rails cross; dots read at 1×) |
| S-line NAND | IC42 3,4,5→6 = /(V-CA · V8 · IC35upper.Q), C9 470 pF | IC111 13, 2, 1 → 12: V-CA, V8, IC105upper.Q; 470 pF to GND | (1100, 1550, 1500, 2000) | same | clear; value probable (`47?`) |
| /LOAD NAND | IC44 9,10,11→8 = /(IC36.CO · IC37.CO · IC57.Q) → IC36.9, IC37.9; 470 pF on /LOAD | IC111 (drawn pointing up): IC119.15, IC57-equivalent Q, IC112.15 → IC119.9, IC112.9; C26 470 pF | (1900, 1700, 2600, 2200) | same | clear |
| Toggle FF | IC57 74107 half: J, K, /CLR Vcc; CLK ← IC37.15; Q → IC44 | `(107/2)`: 8 J, 11 K, 10 /CLR Vcc; 9 CLK ← IC112.15; 5 Q → IC111 (both NANDs) | (2450, 1450, 2800, 1800) | same | clear |
| Carry-net capacitors | one 470 pF, IC37.15 to GND | C27 470 pF and a second 470 pF (crossed-plate symbol, value under it) on IC112.15 | (2350, 1500, 2550, 1950) | differs | probable |
| Strobe NAND | IC44 3,4,5→6 = /(IC57.Q · IC37.QC · IC37.QD); C7 470 pF | IC111 9, 11, 10 → 8: IC112.12, IC112.11, Q (riser x ≈ 2728); C25 470 pF | (2700, 500, 3300, 900) | same | probable (input order not separated) |
| Strobe NAND loads | IC44.6 → IC10.5, IC35upper.CK | 8 → IC68 (mux strobe OR) and IC105upper.11 (CK) | (2700, 500, 4300, 2300) | same | probable |

### Rescue PROM and colour outputs

| Function / net | Original | Pro reading | Pro box | Verdict | Confidence |
|---|---|---|---|---|---|
| PR-138 type and enables | µPB425; /CE1, /CE2 GND; CE3, CE4 Vcc | `MPB-425`, `PR-138 121`, `(救急車) RESCUE CAR`; 20, 21 GND; 18, 19 Vcc | (3150, 750, 3700, 1300) | same | clear |
| PR-138 A0–A3 | V0–V3 | Risers from the V bus; they enter the blank strip | (2650, 750, 3200, 1350) | can't settle | uncertain (scan gap) |
| PR-138 A4–A7, A8 | IC36 QC, QD, IC37 QA, QB; A8 Vs/4 (B) | Rows from the counter outputs; A8 row from `(B) Vs/4` | (1100, 600, 3200, 1350) | same | probable (rows followed at 0.7×; individual order not re-read) |
| Smudge at (2293, 1171) | none | Irregular blot, offset from the crossing of IC112.11's riser and a PR-138 address row; not round | (2150, 1050, 2450, 1300) | same (read as crossing) | probable |
| Rescue nibble mux | IC29 74157: data straight from PR-138; S ← IC36.QB; /G ← IC10.6 | IC120 `157`: data straight; 1 S ← counter; 15 /G ← IC68 | (3000, 1350, 4100, 2200) | same | probable for S |
| Mux strobe OR | IC10 5,4→6: OR of IC44.6, /R-L-SIDE | IC68 (AND body, bubbles on inputs and output = OR): 12 ← IC111.8, 13 ← /R-L-SIDE; 11 → IC120.15 | (3600, 1400, 4100, 1700) | same | clear |
| /RESCUE (Y) | 1Y → IC22 (7406) → /RESCUE (Y) (C) and pad EB (F) | 1Y → inverter IC99 → /RESCUE (Y), marked (C) (D); no pad | (3000, 1350, 4800, 2000) | differs | probable (circled D; no pad drawn) |
| /RESCUE (W) | 2Y → IC22 → (C) | 2Y → IC99 9 → 8 → (C) | same box | same | clear |
| /RESCUE (R) | 3Y NAND Vs/32 (IC16) → (C) | 3Y → IC85 2; 1 ← Vs/32 (riser x ≈ 2854); 3 → (C) | same box | same | probable (Vs/32 riser) |
| /RESCUE (BL) | 4Y → IC22 → (C) | 4Y (12) → inverter `79?` → (C) | same box | same | clear (package numeral uncertain) |
| Mux output capacitors | none | C39 `3300P` on 1Y; C38 `1000P` on 2Y; C37 `1000P` `セラ` (ceramic) on 3Y; all to GND | (3000, 1650, 3700, 2150) | differs | C38 clear; C39 and C37 probable |
| Vs/32 pad | E18 (H) | `E18` (last digit 8 or 9) (H) | (1050, 1200, 1300, 1400) | same | probable |

### Rescue timing and /R-L-SIDE

| Function / net | Original | Pro reading | Pro box | Verdict | Confidence |
|---|---|---|---|---|---|
| Upper 7474 half | IC35: D /HS; CK IC44.6; PR IC42.8; Q → IC42.5; /Q → IC60 | IC105 `74/2`: 12 D ← /HS; 11 CK ← strobe NAND; 10 PR ← IC124.6; 9 Q → IC111.1; 8 /Q → IC55 | (1400, 2150, 2400, 2500) | same | clear |
| Preset NAND and capacitor | IC42 9,10,11→8 = /(IC35lower./Q · IC49.QB · IC49.QA); C6 470 pF | IC124 4, 5, 3 → 6: IC105lower./Q, IC104.QB, IC104.QA; C29 470 pF | (1500, 2150, 2700, 3400) | same | clear |
| Divider | IC49 74393 half: CP Vs/64 (pad EV, H); CL /EXTEND (C) | IC104 `393/2`: 1 CP ← Vs/64 (H, pad label not legible); 2 CL ← /D-EXTEND (B) | (600, 2600, 1800, 3200) | differs (label, see EXTEND) | clear wiring; pad label uncertain |
| EXT. CAR CONT | IC49.QB → pad EX → (F) | IC104.4 → pad EX → (F) | (4000, 2800, 4600, 2950) | same | clear |
| Clock gating | IC45 NAND (QD, ACCE. D pad E14); IC47 AND with Vs/64 → IC35lower.CK | IC103 NAND (6, ACCE. D); IC110 AND (pointing down) with Vs/64 → IC105lower.3 | (1200, 2800, 2200, 3500) | same | clear |
| Lower 7474 half | IC35: D 100-C (D); PR ← IC49.QC; Q → IC18; /Q → IC42 | IC105: 2 D ← 100-C (D); 4 PR ← IC104.5; 5 Q → IC3; 6 /Q → IC124 | (1800, 3200, 2400, 3600) | same | clear |
| Rescue one-shot | IC18 74123 half: A ← Q; B, /CLR Vcc; C4 1.5 µF; R16 ?7 kΩ; Q → IC7 | IC3 `123/2`: 1 A ← IC105.5; 2 B, 3 /CLR Vcc; C1 `1.5μ`; R1 `47K` (middle digit faint); 13 Q → IC7.13; 4 /Q open | (2300, 3050, 2800, 3700) | same | clear; R1 probable |
| /RESCUE CP | IC7 inverter → pad D9 (S) | IC7 13 → 12 → pad (label not legible) → /RESCUE CP (S) | (3800, 3300, 4700, 3550) | same | clear; pad label uncertain |
| /R-L-SIDE NOR | IC60 = NOR(V-③, IC35upper./Q, /V4) → IC59 inverter | IC55 (3 bubbled inputs): V-③, IC105.8, /V4 → IC99 → 10 | (2700, 2100, 3300, 2350) | same | clear |
| /R-L-SIDE destination | IC10.4 and pad FE → (H) | IC68.13 and, through a long route (x ≈ 4833), IC106.11 on the side-output AND; no pad, no off-sheet arrow | (3900, 2000, 5400, 3500) | differs | probable (route followed at 0.6×) |

### Lives counter and GAME OVER

| Function / net | Original | Pro reading | Pro box | Verdict | Confidence |
|---|---|---|---|---|---|
| Up/down counter | IC46 74193: CLR ← /COIN IN (B); A–D GND; UP ← IC39.6; DOWN ← IC59.2; QA, QB out; /BO → IC59 | IC117 `193`: 14 CL ← /COIN IN (B); 15, 1, 10, 9 GND; 5 UP ← IC98.5; 4 DOWN ← IC89.10; 3, 2 out; 13 /BO → IC89.9 | (600, 5400, 2700, 6100) | same | clear |
| Up-input OR and hold at 3 | IC39 4,5→6 OR(IC52.3, /EX. SIGNAL CP); IC52 = QA · QB | IC98 (AND body, all bubbles = OR) 4 ← IC110.11, 5 ← /EX. SIGNAL CP; IC110 12, 13 ← QA, QB | same box | same | clear |
| Pads | E2 (/EX. SIGNAL CP, A), EM (EXPLO. SEL. D, F), E16 GAME OVER (A) | `EZ` (2 or Z), `EM`, `E16` | same box | same | probable (E2) |
| GAME OVER | /BO → IC59 inverter → E16 | 13 → IC89 9 → 8 → E16 → GAME OVER (A) | same box | same | clear |
| Spare-car selector | IC53 74153: 1C0 GND, 1C1 H5, 1C2–3 Vcc, 2C0 GND, 2C1–2 H6, 2C3 IC39.8 = H5 + H6; A, B ← QA, QB; /1G H8; /2G V-① | IC123 `153`: 6 GND, 5 H5, 4, 3 Vcc, 10 GND, 11, 12 H6, 13 ← IC88 OR (H5, H6); 14, 2 ← QA, QB; 1 ← H8, 15 ← V-① | (1400, 4850, 2400, 5600) | same | clear |
| /DUMMY AREA | IC26 NAND(EXTEND, V4, IC53.7, IC53.9); C5 470 pF | IC62 1, 2 ← D-EXTEND (riser x ≈ 2210), V4; 4, 5 ← IC123.7, .9; 6 → /DUMMY AREA; C15 470 pF | (1900, 3600, 2800, 5300) | same (apart from the EXTEND label) | clear |

### Signs and dummy cars

| Function / net | Original | Pro reading | Pro box | Verdict | Confidence |
|---|---|---|---|---|---|
| PR-139 | µPB425; V0–V4, H1–H4; enables as PR-138 | `PR-139 127 DUMMY CAR - BRIDGE SIGNAL`; same enables; A4–A8 rows read; A1, A2 rows pass the blank strip | (2700, 3700, 3600, 4300) | same | probable (A1, A2 in the gap) |
| Sign/dummy nibble mux | IC50 74157, S ← H0? (U1), /G GND, 1Y, 2Y, 4Y used | IC126 `157`: 1 S ← last bus row (label damaged as on the original), 15 /G GND, 4, 7, 12 used | (2700, 4300, 3600, 4700) | same | probable (H0 label, as the original's U1) |
| H5 · H6 · /H8 NAND | IC42 1,2,13→12 | IC81 13 ← /H8, 2, 1 ← H5, H6 → 12 | (1200, 3400, 1800, 3600) | same | clear |
| Sign NOR | IC73 = NOR(IC42.12, Vs/16, /GAME) | IC55 10, 9, 11 → 8 | (1600, 3600, 2200, 3800) | same | clear |
| /EXT. 500 NOR V-④ | IC65 | IC53 3, 2 → 1 (AND body, input bubbles) | (1100, 4500, 1700, 4800) | same | clear |
| CAR NO CONT inverter | IC59 9→8, input bubble; label without overbar (U3) | IC89 13 → 12, input bubble; label drawn with an overbar | (600, 4500, 2100, 4700) | same (label only) | probable (overbar) |
| Sign AND | IC66 7411 = AND(IC59.8, IC73.8, IC65.1) | IC96 (AND, no bubble) 2 ← IC89.12, 3 ← IC55.8, 1 ← IC53.1 → 12 | (1700, 3600, 3200, 4900) | same | clear |
| /SIG. (Y), /SIG. (BL) | IC9 NANDs | IC125 13, 12 → 11 /SIG. (Y); 10, 9 → 8 /SIG. (BL) | (3300, 4250, 4500, 4800) | same | clear |
| /SIG. (Y) capacitor | none | C30 `220P *` `ADJ.` to GND on IC125.11 | (3800, 4100, 4300, 4400) | differs | clear (value); `*` meaning not stated on the sheet |
| Dummy-area gating | IC59 3→4 inverter; IC52 9,10→8 AND with Vs/16 | IC89 5 → 6; IC69 9 ← Vs/16, 10 ← IC89.6 → 8 | (2600, 4900, 4500, 6000) | same | clear |
| /DUMMY (W), (R), (BL) | IC56 NANDs with 2Y, 1Y; IC55 3-input NAND with IC59.4 | IC125 (2, 1 → 3) with 2Y; (4, 5 → 6) with 1Y; IC124 2, 1, 13 → 12 | same box | same | clear |

### Bridge

| Function / net | Original | Pro reading | Pro box | Verdict | Confidence |
|---|---|---|---|---|---|
| PROM bank select | IC10 13,12→11 = /0-AREA OR IC15.11; IC15.11 = V-⑤ AND V-③ | IC98 (OR form) 2 ← /0-AREA (D), 1 ← IC50.8; IC50 (AND form) 9 ← V-⑤, 10 ← V-③ riser | (5200, 500, 7100, 1400) | same | clear |
| PR-140 / PR-141 | µPB425 ×2; shared address and data; PR-140 enabled when select high, PR-141 when low | `MPB-425 ×2`, `PR-140 BRIDGE No1 100`, `PR-141 BRIDGE No2 107`; same enable pattern; shared rows | (6900, 400, 8300, 2200) | same | clear |
| A0–A3 XORs | IC23: V0–V3 XOR mirror | IC114 four XORs, common second input | (5200, 500, 7100, 1400) | same | clear |
| Mirror line source | IC52 13,12→11 = AND(Vcc, V7), on the left of the sheet | AND (designator `34` or `54`) 4 ← Vcc, other ← V7 (E), drawn beside the side gates; output → XOR common line and the /L2-SIDE NAND | (5200, 2900, 6300, 3300) | same | clear (designator uncertain) |
| A4 | IC21.8 = AND(V4 ⊕ V7, V-②, V6 ⊕ V7) | IC106 13 ← IC113.11, 1 ← V-②, 2 ← IC113.3 → 12; IC113 = V4 ⊕ V7 and V6 ⊕ V7 | (5900, 1000, 6900, 1300) | same | probable (V6 label) |
| A5–A8 | MH1–MH4 (B) | MH1–MH4 (B) | (5100, 1900, 7000, 2300) | same | clear |
| Colour mux | IC11 74157: data D0–D7 straight; S MH0; /G ← NOT V-④ | IC93 `157`: data straight; 1 ← MH0; 15 ← IC79.12 (NOT V-④, shared with PR-54's enable, see the +200 trace) | (7200, 1900, 8100, 2400) | same | clear |
| Decoder D input | IC16 = NAND(BRIDGE AP, IC21.12); IC21.12 = AND(V-④, /DUMMY AREA, /OTHER CAR) | IC85 12 ← BRIDGE AP (D), 13 ← IC106.6; IC106 3, 4, 5 (OR body, all bubbles = AND) ← V-④ riser, /DUMMY AREA riser, /OTHER CAR (C) | (6000, 1950, 7200, 2500) | same | probable (V-④ riser identity) |
| 7442 decoder | IC6: 1Y, 2Y, 3Y, IC16 → A–D; outputs 0, 1, 2, 4, 5 used | `42 81`: 15, 14, 13, 12 ← IC93.4, .7, .9, IC85.11; 1 (Bu), 2 (R), 3 (Y), 5 (DBu), 6 (W) | (7900, 2000, 9100, 3000) | same | clear |
| /BRIDGE (Bu), (R), (Y), (DBu) | → (C) | → (C) | (7900, 2500, 9100, 3000) | same | clear |
| /BRIDGE (W) | → (C) and pad EH → (F) | → (C) (D); no pad | (7900, 2500, 9100, 2600) | differs | probable (circled D) |

### Side outputs

| Function / net | Original | Pro reading | Pro box | Verdict | Confidence |
|---|---|---|---|---|---|
| Bridge side term | IC15 9,10→8 = EXT. 500 · IC11.4 | IC84 12 ← EXT. 500 (D), 13 ← IC93.4 → 11 (AND, pointing down) | (7300, 2000, 8100, 2700) | same | clear |
| Left NAND | IC16 2,1→3 = NAND(IC15.8, V7) → pad F4 | IC85 5 ← IC84.11, 4 ← V7 (buffered) → 6 | (7300, 3000, 8100, 3300) | same | clear |
| Right NAND | IC16 13,12→11 = NAND(IC15.8, /V7) → pad F5 | IC85 10 ← IC84.11, 9 ← /V7 (E) → 8 | (7300, 3150, 8100, 3450) | same | clear |
| /L1-SIDE, /R1-SIDE inputs | not on sheet M (sheet D → sheet H pads CC, CD) | `(D) /L1-SIDE`, `(D) /R1-SIDE` arrows | (5100, 2950, 5800, 3450) | differs | clear |
| /L2-SIDE (F4) | IC16.3 alone | IC84 (OR body, all bubbles = AND) 9 ← /L1-SIDE, 10 ← IC85.6 → 8 → pad F4 (H) | (7300, 2950, 8300, 3150) | differs | clear |
| /R2-SIDE (F5) | IC16.11 alone | IC106 (OR body, all bubbles = AND) 9 ← IC85.8, 10 ← /R1-SIDE, 11 ← /R-L-SIDE → 8 → pad F5 (H) | (7300, 3150, 8300, 3450) | differs | clear gates; /R-L-SIDE route probable |

### Off-sheet labels

| Function / net | Original | Pro reading | Pro box | Verdict | Confidence |
|---|---|---|---|---|---|
| EXTEND pair | /EXTEND (C) → IC49 CL; EXTEND (C) → IC26 | `(B) /D-EXTEND` → IC104 CL; `(B) D-EXTEND` → IC62 | (600, 2850, 1400, 3700) | can't settle (renamed, other source sheet) | clear label reading |
| Vs/16, /GAME | trace: Vs/16 (B), /GAME (B) | both circled `E`; on the original scan the glyph is similar | (600, 3600, 1300, 3900) | can't settle (label only) | probable |
| Other inputs | 7M, V-CA, V8, /V4, /HS, V bus, H bus, V-①…⑤, MH0–4, Vs/4, /COIN IN, 100-C, /H8, /EXT. 500, EXT. 500, /0-AREA, BRIDGE AP, /OTHER CAR, ACCE. D, EXPLO. SEL. D, /EX. SIGNAL CP | all present on the same functions | whole sheet | same | clear |
| Power pads | D1–D5, DA–DE GND; D19–D22, DW–DZ Vcc; F20–F23, F25–F28 | GND `D1~D5`, `DA~DE`; Vcc `DA~DZZ`(?), `DW~DZ`; `F20~F23`, `Fx~Fa`; `F25~F28`, `Fc~Fg`; bypass capacitors with `μPB425用` | (4800, 5250, 8200, 6000) | can't settle (labels faint; carry no logic) | uncertain |

## Differences

1. **Side outputs combined on M.** Boxes (5100, 2900, 8300, 3500) and
   (3900, 2000, 5400, 3500). /L1-SIDE and /R1-SIDE come in from sheet D;
   IC84 (9, 10 → 8) and IC106 (9, 10, 11 → 8) AND them with the bridge-side
   NANDs, and IC106 also takes /R-L-SIDE. Pads F4 and F5 therefore carry
   what the original computes on sheet H at IC85.6 and IC85.8. Clear for
   the gates and inputs, probable for the /R-L-SIDE route. For reuse: the
   Monaco M module's /L2-SIDE and /R2-SIDE outputs must be ANDed with the
   D-side signals (and /R2-SIDE with /R-L-SIDE) inside M, and sheet H must
   not AND them a second time; the logic function is unchanged.
2. **/R-L-SIDE stays on M.** No pad FE, no off-sheet arrow. Probable. For
   reuse: the module no longer exports it.
3. **/RESCUE (Y) to sheet D, not F.** Box (4100, 1550, 4800, 2000). No pad;
   circled (C) and (D). Probable. For reuse: the consumer moves from the
   F module to the D module (Pro sheet D's lower edge shows a RESCUE (Y)
   input arrow; its use is for the sheet D compare).
4. **/BRIDGE (W) to sheet D, not F.** Box (7900, 2500, 9100, 2600). Same
   remarks as 3. Probable.
5. **Capacitors on the rescue colour multiplexer outputs.** Box
   (3000, 1650, 3700, 2150). C39 3300 pF (1Y, rescue yellow), C38 1000 pF
   (2Y, white), C37 1000 pF ceramic (3Y, red, before the Vs/32 NAND).
   C38 clear; C39 (3300 or 330) and C37 probable. For reuse: edge filtering
   on the video only; no logic change in a synchronous model.
6. **C30 220 pF `*` `ADJ.` on /SIG. (Y).** Box (3800, 4100, 4300, 4400).
   Clear. The asterisk and `ADJ.` suggest a value chosen on test; the sheet
   does not say. For reuse: no logic change.
7. **Second 470 pF on the rescue counter's high carry (IC112.15).** Box
   (2350, 1500, 2550, 1950). Probable. No logic change.
8. **EXTEND renamed D-EXTEND, from sheet B.** Box (600, 2850, 1400, 3700).
   Clear reading; whether D-EXTEND equals the original's EXTEND (from A
   through C) is for the sheet B and C comparisons. For reuse: the module's
   EXTEND inputs must be fed from whatever D-EXTEND turns out to be.

## Still uncertain

- **PR-138 A0–A3 and PR-139 A1, A2:** the risers enter the blank strip at
  x 2930–3050. The original has V0–V3 on both; the visible ends agree.
  Settled only by a better scan of page 17.
- **The blot at (2293, 1171):** read as a crossing (irregular, offset from
  the wire crossing). A clean copy of the page would settle it.
- **C39's value** (3300 or 330 pF) and **C37's** (`1000` with a damaged
  last character): crop (3000, 1900, 3500, 2150) at 4×.
- **The circled (D) on /RESCUE (Y) and /BRIDGE (W):** settled by the
  matching inputs on Pro sheet D (lower edge, about x 2600–2900 on the
  page 15 render).
- **Pad labels:** Vs/64, ACCE. D and /RESCUE CP pads are illegible; E18 may
  be E19; E2 reads `EZ`.
- **R1** `47K`: middle digit faint, as on the original.
- **The mirror-line AND's designator** (`34` or `54`) and the 4Y inverter's
  package (`79?`).

## Not checked

- The +200 path (PR-54, IC129, IC128, the V-④ inverter's PR-54 branch):
  see `SHEET_M_C_PLUS200_TRACE.md`.
- PROM contents (PR-138 to PR-141): the schematic does not give them.
- The bypass-capacitor values and the power-pad suffixes.
- What sheets B, C, D and H do with D-EXTEND, /RESCUE (Y), /BRIDGE (W),
  /L1-SIDE, /R1-SIDE, F4 and F5 beyond the label cross-check above.
- Gate package types where the sheet prints only a designator.

## Short report

- Rows compared: 69. **Same: 55. Differs: 10. Can't settle: 4.** (The
  divider row counts as differs only for its /D-EXTEND label.)
- Differences: side ANDs moved from H to M (/L1-SIDE, /R1-SIDE inputs,
  /L2-SIDE and /R2-SIDE as ANDs); /R-L-SIDE no longer exported;
  /RESCUE (Y) and /BRIDGE (W) to D instead of F; C39, C38, C37 on the
  rescue mux outputs; C30 220 pF ADJ on /SIG. (Y); a second 470 pF on the
  rescue carry; EXTEND renamed D-EXTEND from B (whether it is the same
  signal is counted under can't settle).
- None of the three known values in the issue is on sheet M.
