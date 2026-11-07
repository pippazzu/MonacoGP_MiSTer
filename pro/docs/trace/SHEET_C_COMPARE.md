# Sheet C compare: Pro page 14 against the original (Pro Monaco GP)

Date 2026-11-06, issue #86. Pin- and net-level comparison of Pro sheet C
(96823-P D-2/5, PDF page 14) with the original sheet C (96578-P D-2/5,
420-0358 page 30), function by function: the AREA register, the eight colour
collectors into the 74147 priority encoder, the two 74157 multiplexers
(extended play and bridge), the brightness (pull-down) control and the RGB,
blanking and sync output stage. The /+200 input into the red collector, and
the red line's path to the encoder and to the brightness collector, are
already traced in `SHEET_M_C_PLUS200_TRACE.md` and are only cited.

**Main results**

1. **New blue-only dimming path.** A fourth 7417 section (11 → 10, R8 470 Ω)
   pulls the BLUE output node down whenever the blue term of the extended-play
   multiplexer (the original's IC14 output, Pro 57.6) is low. The original
   has only the three common pull-downs (R2, R4, R6), all driven together.
   This is the only change in the output stage. Clear.
2. **That blue term is gated differently.** On the original it is
   NAND(7M, AND(/RESCUE (BL), /GRAVEL), IC8.12, IC5.4). On Pro, 7M is gone
   from it, and its inputs are D-EXTEND (in place of 7M) and
   NOR(NOT AND(/RESCUE (BL), /GRAVEL), BELT, splash term) (in place of the
   plain AND), with the same IC8.12 and bridge-mux 1Y terms. Three new parts
   make the second input: inverter 92 (1 → 2), NOR 51 (4, 3, 5 → 6) and a
   new input **BELT (D)**. On Pro, 7M only clocks the AREA latch. Clear.
3. **The extended-play control comes from sheet B, not from pads.** EXTEND
   (pad EB, from A) is replaced by **D-EXTEND (B)** and /EXTEND (pad E3,
   from A) by **/D-EXTEND** (an arrow; circled letter not legible). Neither
   is a pad, and sheet C no longer passes EXTEND or /EXTEND on to M and D.
   Each one still drives the same pins. The M and D comparisons agree: both
   sheets take D-EXTEND from B directly. Clear.
4. **Everything else is the same function and net.** All eight collectors
   have the same inputs. The AREA register, both 74157 multiplexers, the
   74147 and the RGB, blanking and sync stages have the same connections
   and values (470 Ω ×3, 470 Ω pull-downs, 10 kΩ ×3, RA1 560 Ω, MA150,
   C458). The original's open questions U1 to U4 (the cyan label, IC8's
   type, the POOL/HOUSE suffixes and IC8.4 left open) look the same on Pro,
   which settles none of them.
5. **Known values (issue's list).** None of the three is on sheet C. See
   `SHEET_H_COMPARE.md` (SP. CONT. 1000 pF) and `SHEET_G_COMPARE.md`
   ("Known values (sheet F)": C54 470 pF, C32 22 µF).

## Sources and method

- Pro: `pro/schematics/promonacogp420-0525_1.pdf`, page 14, rendered with
  PyMuPDF at `Matrix(1, 1)`, upright, 10200 × 6617. Every Pro box below is
  (left, top, right, bottom) on that render. Crops were read at 0.6× to 4×.
  A column walker (dark-pixel runs on the grey render) was used to check
  that the long risers at x ≈ 2338 (D-EXTEND to 57.5) and x ≈ 6250 (57.6 to
  the R8 buffer) are continuous.
- Original: `docs/trace/SHEET_C_TRACE.md` (complete pin-level trace of
  `schematics/pages/page30-sheet-C.png`). Original IC and pin names below
  are that trace's. The Pro layout follows the original closely, so each
  Pro net was compared with the original net in the same place.
- Reading rules are those of `pro/README.md`. A drawn dot is a junction (on
  this page about 28–35 px); a crossing is not, even where the scan
  thickens it. Gate function comes from the symbol: OR body with input
  bubbles = NAND, AND body with input bubbles = NOR, bubbles on every input
  and the output turn AND into OR and OR into AND.
- IC numbers differ between the boards and prove nothing. Pro designators
  are given as printed. The two 74157s read `E1` and `E3`, which are
  probably `61` and `63` drawn loosely. They are called E1 and E3 here.
- Confidence: **clear**: read directly, with no competing reading.
  **Probable**: one reading fits much better, but the scan is not clean.
  **Uncertain**: the scan does not settle it.
- Excluded: /+200 (M) into the red collector 74, and the red line 2.12's
  branches to the 74147 and to the brightness collector 48, all in
  `SHEET_M_C_PLUS200_TRACE.md`.
- No MAME, emulator, other core, KiCad redraw, footage or gameplay
  description was used.

## Comparison by function

### Off-sheet inputs and outputs

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| AREA 1..5 (H) | pads FL, FK, F9, F10, F11 → IC86 2, 4, 6, 10, 12 | five pads → 33 (`368`) 2, 4, 6, 10, 12. Pad captions faded; AREA 2 reads `FK` | (1900, 600, 2400, 1300) | same | clear for the wiring; pad captions not readable |
| /OTHER BODY (H) | pad ER → IC86 1, 15 | pad (caption faded) → 33 1, 15, with a dot | (1900, 1150, 2900, 1350) | same | clear |
| 7M (E) | arrow → IC79.9 and IC14.4 | arrow → 26 (`174`) 9 only. No other branch | (2050, 1250, 2950, 1600) | **differs** (see D2) | clear |
| /HOUSE (Mu) (D) | → IC58.9 | → 27.4 | (1500, 1300, 3500, 1450) | same | clear |
| EXTEND | (A) pad EB → IC20.1, IC34.2; arrow EXTEND to (M)(D) | **(B) D-EXTEND**, arrow, no pad → E1.1, 53.12, and down to 57.5 (dot at (2340, 1495)). No output arrow | (1550, 1450, 4300, 1850) | **differs** (D3, D2) | clear |
| /GRASS (BL) (D) | → IC20.11 | `GRASS(Bu)`-like suffix → E1.11 | (1500, 1600, 4000, 1700) | same net (suffix reading differs, no circuit effect) | clear for the net; suffix uncertain |
| /ROAD (D) | → IC19.9, IC15.1 | → 63.13, 67.5 (riser x ≈ 2850) | (2300, 1700, 3500, 2700) | same | clear |
| /TREE & GRASS (G) (D) | → IC21.5, IC20.2, IC20.6 | → 76.5, E1.2, E1.6 | (2300, 2000, 4300, 2350) | same | clear |
| /HOUSE ST, /GRASS AREA (D) | → IC21.3, IC21.4 | → 76.4, 76.3 | (2300, 2050, 2700, 2250) | same | clear |
| /TREE & GRASS (BL) (D) | → IC19.11, IC20.13, IC13.2 | → 63.1, E1.13, 48 (riser x ≈ 2425) | (2300, 2050, 4300, 2350) | same | clear |
| /LIGHT (G) | pad EC → IC15.2, IC19.3 | pad → 67 lower input, 37.9 | (2300, 2450, 3500, 2700) | same | clear |
| TUNNEL AP (D) | → IC19.4 | → 37 middle input | (2300, 2550, 3500, 2700) | same | clear |
| /COIN & START (B) | → IC8.10 | → 76.11 | (1700, 2650, 4200, 2750) | same | clear |
| /SIG. (BL), /DUMMY (BL) (M), /PLAYER (BL) (G, pad) | → IC26.1, .2, .4 | → 54 inputs | (2300, 2850, 3600, 3050) | same | clear |
| /PLAYER TIAR (G, pad), /OTHER TIAR (H, pad), /HOUSE (W) (D), /RESCUE (W), /DUMMY (W) (M) | → IC27 5, 11, 12, 2, 1 | → five inputs of the white NAND (`30`, designator like `80`) | (1700, 3050, 4700, 3400) | same | clear |
| /SIG. (Y) (M), /EXPLO. (Y) (G, pad E4), /RESCUE (Y) (M) | → IC4 12, 5, 1 | → three inputs of the yellow NAND (`30`, designator not legible) by rows y ≈ 3475, 3520, 3562 | (1700, 3400, 5900, 3600); (5300, 2250, 6400, 2700) | same | clear |
| /GREEN BELT, /Y-LINE (D) | → IC13.11; IC13.4, IC5.11 | → 48; /Y-LINE → 48 (dot (3713, 4085)) and E3.11 | (1700, 3900, 4600, 4300) | same | clear |
| /RESCUE (BL) (M), /GRAVEL (D) | → IC15.4, IC8.13; IC15.5 | → 69.12 and 68.11; 69.13 | (1700, 4050, 3300, 4350) | same | clear |
| **BELT (D)** | none | new arrow, no overbar → 51.3 | (1700, 4300, 3000, 4420) | **differs** (D2) | clear |
| /SPLAY (G, pad E10), /POOL, /SLIP, /HOUSE (D) | → IC14 10, 12, 9, 13 | → 62 (4-input NAND) 10, 9, 12, 13 | (1500, 4400, 2800, 4650) | same | clear; suffixes of /POOL, /HOUSE read like `(St)` / `(Si)`, as unsettled as the original's U3 |
| /OTHER CAR (H) | pad E15 → IC8.1; arrow to (M) | pad E15 → 68.9; dot, then arrow `/OTHER CAR` to (M) | (2380, 4610, 2620, 4730) at 4× | same | clear |
| /EXTEND | (A) pad E3 → IC10.10; arrow to (M) | **/D-EXTEND**, arrow, no pad; circled letter like C or E → 47.13. No output arrow | (1550, 4580, 5250, 4760) | **differs** (D3) | clear for the net; circled letter uncertain |
| BRIDGE AP, ROAD, /SIDE LINE (D) | → IC5.1; IC5.2, .5; IC5.14 | → E3.1; E3.2, .5 (dot); E3.14 | (4200, 4300, 5000, 5100) | same | clear |
| V-④ (B), /BRIDGE (DBu) (M) | → IC9.4, IC9.5 | → 103 4, 5 (NAND) → E3.3 | (1500, 4950, 2600, 5150) | same | clear |
| /BRIDGE (Bu), (Y), (W) (M) | → IC5.6, .10, .13 | → E3.6, .10, .13 | (1500, 5050, 5000, 5250) | same | clear |
| /HOUSE (R), /WALL (R) (D), /BRIDGE (R) (M) | → IC44 13, 2, 1 | → 60 11, 10, 9 | (1500, 5350, 2600, 5550) | same | clear |
| /PLAYER (G, pad E9), /DUMMY AREA (M), /EXPLO. AREA (G, pad F15) | → IC66 2, 1, 13 | → 68 1, 13, 2 | (1500, 5550, 2600, 5800) | same | clear |
| /PLAYER BODY (G, pad E7), EX & GAME OVER (B), /DUMMY (R), /RESCUE (R) (M), /EXPLO (R) (G, pad EK) | → IC33 6, 12, 2, 1, 5 | → 74 inputs (routes in `SHEET_M_C_PLUS200_TRACE.md`) | (1500, 5800, 2500, 6100) | same | clear |
| /TV-BLANKING, /SYNCRO (E) | → IC7 blanking section; IC7 5 → 6 | → 7416 `7` 11 → 10; 7416 `7` 9 → (8) | (6000, 2900, 9000, 3600) | same | clear (Pro sync output numeral faint) |
| TV-RED, -BLUE, -GREEN, -SYNCRO, -GND | pads D11, D12, D13, D10, DL | pads D11, D12, D13, D10 (`1)10`), DL | (8700, 700, 9700, 3500) | same | probable (captions faint) |

### AREA register

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| 74368 buffer | IC86: 2→3, 4→5, 6→7, 10→9, 12→11; 14→13 not drawn | 33: the same five sections; one more output bubble, unwired | (2400, 600, 3100, 1300) | same | clear |
| 74174 latch | IC79: D 3, 4, 6, 11, 13; CP 9 = 7M; /MR not drawn | 26: same pins; CP 9 = 7M; /MR not drawn | (2650, 550, 3300, 1300) | same | clear |
| Q1 → blue NAND | IC79.2 → IC19.2 | 26.2 → 60.5 (top row) | (3300, 600, 7000, 750) | same | clear |
| Q2 → magenta AND | IC79.5 → IC58.10 | 26.5 → 27.5 | (3300, 700, 3900, 1200) | same | clear |
| Q3 → green AND | IC79.7 → IC8.5 | 26.7 → 68.5 (green section) | (3300, 800, 6200, 1000) | same | clear |
| Q4 → yellow NAND | IC79.10 → IC4.6 | 26.10 → riser x ≈ 4658 → yellow NAND | (3300, 900, 6000, 2600) | same | clear |
| Q5 → cyan AND | IC79.12 → IC8.9 | 26.12 → riser x ≈ 3808 → 76.10 | (3300, 1000, 4100, 2750) | same | clear |

### Colour collectors into the 74147

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| Input 9, red | IC33 (7430) → IC3 11→10 → IC2.10 | 74 (`30`) → 2 13→12 → `147` pin 10; inputs as original plus /+200 | see `SHEET_M_C_PLUS200_TRACE.md` | same, plus /+200 (excluded) | clear |
| Red NAND helper | IC45 12,13→11 = NAND(IC44.12, IC66.12) → IC33.11 | 75 4,5→6 = NAND(60.8, 68.12) → 74.1 | (2400, 5350, 3300, 5600) | same | clear |
| IC44 / IC66 equivalents | NAND(/HOUSE (R), /WALL (R), /BRIDGE (R)); AND(/PLAYER, /DUMMY AREA, /EXPLO. AREA) | 60 (11,10,9→8) NAND; 68 (1,13,2→12) AND (OR body, all bubbles) | (2400, 5350, 3300, 5800) | same | clear |
| 68.12 fan-out | IC66.12 → IC45.13, IC8.2, IC19.5 | 68.12 → riser x ≈ 2550 → 75.5, 68.13 (dot (2550, 4690)), 37.1 | (2450, 2600, 2650, 5700) | same | clear |
| Input 8, black | IC26 (7420 NAND) → IC3 1→2 → IC2.5; inputs /SIG. (BL), /DUMMY (BL), /PLAYER (BL), IC19.6 | 54 (NAND, 9, 13, 12, 10 → 8; two numerals read "2") → 2 1→2 `(BL)` → pin 5 | (3500, 2650, 6300, 3050) | same | clear; two pin numerals probable |
| IC19 3,4,5→6 (NAND /LIGHT, TUNNEL AP, IC66.12) | → IC26.5 | 37 (AND body, output bubble) → 54.9 | (2700, 2550, 3300, 2750) | same | clear |
| Input 7, white | IC27 (7430) → IC3 3→4 → IC2.4; 7 inputs, pin 4 open | 8-input NAND (`30`) → 2 3→4 `(W̄)` → pin 4; the five off-sheet inputs, E1.7 (2Y) and E3.12 (4Y); one input bubble unwired | (4300, 2950, 5100, 3500) | same | clear |
| Input 6, cyan | IC8 9,10,11→8 (AND) → IC2.3, IC13.6; inputs Q5, /COIN & START, IC9.8 | 76 10,11,9→8 (OR body, all bubbles = AND) `(S?)` → dot (4355, 2690) → pin 3 and down to 48 | (3800, 2300, 5300, 3100) | same | clear; label as unreadable as the original's U1 |
| IC9 9,10→8 (cyan third input) | NAND(IC14.8, IC8.12) → IC8.11 | 75 10,9→(8) = NAND(62.8, 68.8) → riser x ≈ 4010 → 76.9 | (2500, 3950, 4200, 4800) | same | clear; output numeral reads 3 or 8 |
| Input 5, yellow | IC4 (7430) → IC3 5→6 → IC2.2; inputs /SIG. (Y), /EXPLO. (Y), /RESCUE (Y), Q4, IC20.12, IC5.9; two open | 8-input NAND (`30`, rotated) → 2 5→6 `(Ȳ)` → pin 2; inputs the same six (Q4, E1.12, E3.9 and the three off-sheet); two bubbles unwired | (5300, 2250, 6400, 2700); (4000, 2400, 7000, 4300) | same | clear |
| Input 4, green | IC8 3,4,5→6 (AND): Q3, IC20.4, pin 4 open | 68 5,4,(3)→6 (AND): Q3, E1.4; third input unwired | (4000, 500, 7000, 1300) | same | clear |
| Input 3, magenta | IC58 9,10→8 (AND): /HOUSE (Mu), Q2 | 27 4,5→6 (AND) → `(Mu)` → pin 13 | (3300, 1100, 4300, 1300) | same | clear |
| Input 2, blue | IC19 1,2,13→12 (NAND): Q1, IC20.9, IC10.8 → IC3 9→8 → IC2.12 | 60 5,4,3→6 (NAND) `(B̄u)`: Q1, E1.9, 47.11 → 2 9→8 → pin 12 | (4000, 500, 7000, 2500) | same | clear |
| /EXTEND OR | IC10 9,10→8 (OR): /EXTEND, IC5.7 → IC19.1 | 47 13,12→11 (OR, upright): /D-EXTEND, E3.7 → riser x ≈ 5217 → 60.3 | (4000, 4100, 7000, 6200) | same gate; input renamed (D3) | clear |
| 74147 | IC2: inputs 1..9, outputs A 9, B 7, C 6; input 1 and D not drawn | `147 1`: the same pins | (7200, 1000, 7800, 1800) | same | clear |

### Extended-play and bridge multiplexers

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| Extended-play 74157, select and enable | IC20: S = EXTEND, /G = GND | E1: S 1 = D-EXTEND (dot (4183, 1793)), 15 = GND | (3700, 1550, 4600, 2350) | same function, select renamed (D3) | clear |
| E1 A inputs | 2 /T&G (G); 5 IC10.3; 11 /GRASS (BL); 14 IC19.8 | 2 /T&G (G); 5 47.3; 11 /GRASS; 14 63.12 | same box | same | clear |
| E1 B inputs | 3 open; 6 /T&G (G); 10 IC14.6; 13 /T&G (BL) | 3 open; 6 /T&G (G); 10 **57.6**; 13 /T&G (BL) | same box | same pin; 57.6 is gated differently (D2) | clear |
| E1 outputs | 4 → green; 7 → white; 9 → blue; 12 → yellow | the same | same box | same | clear |
| IC19 9,10,11→8 | NAND(/ROAD, IC21.6, /T&G (BL)) → IC20.14 | 63 2,13,1→12 NAND(76.6, /ROAD, /T&G (BL)) → E1.14 | (2300, 2050, 3500, 2600) | same | clear |
| IC21 3,4,5→6 | AND(/HOUSE ST, /GRASS AREA, /T&G (G)) → IC19.10, IC13.12 | 76 5,4,3→6 AND → 63.2 and down (x ≈ 2465) to 48 | same box | same | clear |
| IC15 1,2→3 | AND(/ROAD, /LIGHT) → IC10.2 | 67 5,(4)→6 AND → 47.2 | (2300, 2050, 3500, 2600) | same | clear |
| IC10 1,2→3 | OR(IC13.8, IC15.3) → IC20.5, IC34.3 | 47 1,2→3 OR(48.8, 67.6) → E1.5, 53.11 | (3300, 1550, 3600, 2700) | same | clear |
| IC34 / IC3 13→12 (common dim) | NOR(IC10.3, EXTEND) → NOT → IC1 three buffers | 53 11,12→13 NOR(47.3, D-EXTEND) → 2 11→(10) → 7417 5→6, 3→4, 9→8 | (4200, 1650, 7700, 2000) | same | clear |
| Brightness collector IC13 (7430) | 2 /T&G (BL); 3 IC8.12; 4 /Y-LINE; 5 red; 6 cyan; 11 /GREEN BELT; 12 IC21.6; 1 open → IC10.1 | 48 (`30`, upward): /T&G (BL), 76.6, 68.8, red (pin 2), cyan 76.8, /GREEN BELT, /Y-LINE; one bubble unwired → 47.1 | (3300, 3500, 4600, 4300) | same | clear (designator reads 43 or 48) |
| Bridge 74157 | IC5: S BRIDGE AP; 2, 5 ROAD; 11 /Y-LINE; 14 /SIDE LINE; 3 IC9.6; 6, 10, 13 /BRIDGE (Bu), (Y), (W) | E3: the same | (4200, 4300, 5000, 5100) | same | clear |
| Bridge outputs | 4 → IC14.2; 7 → IC10.9; 9 → IC4.11; 12 → IC27.3 | 4 → 57.4 (riser x ≈ 4748, row y ≈ 4390); 7 → 47.12; 9 → yellow NAND (riser x ≈ 5847); 12 → white NAND (riser x ≈ 4440) | (4000, 4100, 7000, 6200) | same | clear |
| IC8 1,2,13→12 | AND(/RESCUE (BL), /OTHER CAR, IC66.12) → IC13.3, IC14.5, IC9.10 | 68 11,9,13→8 AND → 48 (riser x ≈ 3495), 57.2 (dot), 75.9 | (2500, 3950, 4200, 4800) | same | clear |
| IC14 9,10,12,13→8 (splash term) | NAND(/SPLAY, /POOL, /SLIP, /HOUSE) → IC9.9 | 62 NAND → 75.10 **and 51.5** (dot (2980, 4540)) | same box | **differs** (new branch, D2) | clear |
| **IC14 1,2,4,5→6 (blue term)** | NAND(7M, IC15.6, IC8.12, IC5.4) → IC20.10 | 57 (5,1,2,4→6) NAND(**D-EXTEND**, **51.6**, 68.8, E3.4) → E1.10 **and the R8 buffer** | (3300, 3950, 4300, 4500) | **differs** (D1, D2) | clear |
| IC15 4,5→6 | AND(/RESCUE (BL), /GRAVEL) → IC14.1 | 69 12,13→11 AND → **92 1→2 (inverter) → 51.4** | (2150, 4120, 3400, 4330) | **differs** (D2) | clear |
| 51 (new) | none | 3-input NOR (OR body, output bubble, no input bubbles), 4, 3, 5 → 6: 92.2, BELT, 62.8 → 57.1 | same box | **differs** (D2) | clear |

### Output stage

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| RGB drivers | 7416 IC7 9→8, 11→10, 13→12 from IC2 A, B, C | 7416 `7` 1→2 (A, RED), 5→6 (B, BLUE), 3→4 (C, GREEN) | (7350, 800, 8300, 1700) | same | clear |
| Pull-ups | R1, R3, R5 `470 ×3` to Vcc | R5 `470×3` (RED), R9 (BLUE), R12 (GREEN) to Vcc | (7700, 800, 8300, 1700) | same | clear (R12 numeral probable) |
| Common pull-downs | IC1 (7417) 5→6, 3→4, 1→2 → 470 Ω R2, R4, R6 → R, B, G | 7417 `14` 5→6 → R4 470 → RED; 3→4 → R3 470 → BLUE; 9→8 → R11 470 → GREEN (crosses BLUE without a dot) | (7350, 1650, 8200, 2650) | same | clear (R3 numeral probable) |
| **Blue-only pull-down** | none | 7417 `14` 11→10 → R8 470 → dot on the BLUE node; input from 57.6 by row y ≈ 4240, riser x ≈ 6250, row y ≈ 2165 | (7350, 1650, 8200, 2650); (5900, 2000, 7300, 2500); (5900, 3850, 6600, 4300) | **differs** (D1) | clear |
| 10 kΩ to ground | R13, R14, R15 `10K ×3` | R3(?), R7, R10 `10K×3` | (7300, 2550, 8400, 2900) | same | clear (first numeral faint) |
| Blanking clamp | IC7 → TR1 (C458) base, RA1 560 to Vcc; collector RA1 560 to Vcc, D1..D3 MA150 to the nodes | 7416 11→10 → TR1 `C458` base, RA1 560 to Vcc; collector RA1 560 to Vcc; D2 → RED, D1 → BLUE, D3 → GREEN, `MA150` | (7300, 2550, 8400, 3500) | same | clear |
| Sync | IC7 5→6, RA1 560 to Vcc → D10 | 7416 9→(8), RA1 560 to Vcc → pad D10 | (6000, 3100, 9000, 3600) | same | clear |

## Differences

### D1. A blue-only pull-down (new)

A fourth 7417 section (`14`, type `17`, pins 11 → 10) takes 57.6 and
pulls the BLUE node to ground through R8 (470 Ω). Route: 57.6 dot at
(3880, 4240), row y ≈ 4240 right to x ≈ 6260, riser up to y ≈ 2165, row
right into pin 11. The walker shows the riser continuous from y ≈ 2405 to
3920, with short scan dropouts at both ends, and no other wire joins it.
R8 ends on a drawn dot on the BLUE vertical (x ≈ 7935 on the render); it
crosses RED without a dot. Clear.

On the original, the only pull-downs are the three common ones from
IC34/IC3, which dim all three guns together. On Pro, 57.6 low also dims
the blue gun on its own, through a 470 Ω pull-up against a 470 Ω pull-down.
That happens even when a higher-priority plane wins the 74147 on that pixel.
The analogue level was not worked out.

**For reuse:** the Monaco module's output stage needs one more term, a blue
dim enable = NOT 57.6, beside the common dim.

### D2. The blue term of the extended-play multiplexer is regated

| | Original (IC14, 1,2,4,5 → 6) | Pro (57, 5,1,2,4 → 6) |
|---|---|---|
| input 1 | 7M | **D-EXTEND** (riser x ≈ 2338 from the dot (2340, 1495); walker: continuous 1489–4176) |
| input 2 | IC15.6 = AND(/RESCUE (BL), /GRAVEL) | **51.6 = NOR(NOT 69.11, BELT, 62.8)**, where 69.11 = AND(/RESCUE (BL), /GRAVEL) and 62.8 = NAND(/SPLAY, /POOL, /SLIP, /HOUSE) |
| input 3 | IC8.12 | 68.8 (same net) |
| input 4 | IC5.4 (bridge mux 1Y) | E3.4 (same net) |
| output | → IC20.10 (3B) | → E1.10 (3B) and → R8 buffer (D1) |

So 51.6 = AND(/RESCUE (BL), /GRAVEL) AND NOT BELT AND NOT 62.8. It is the
original term with two extra conditions: no BELT, and no splay, pool, slip
or house pixel. On the original, 7M chops this term at the pixel clock. On
Pro the term is steady and is enabled by D-EXTEND. The extended-play mux
selects 3B only while D-EXTEND is high, so for the mux the D-EXTEND input
changes nothing. It matters for D1: the blue-only dim acts only in extended
play.

New parts: inverter 92 (drawn as a buffer with a bubbled input, 1 → 2), NOR
51 (3-input, pins 4, 3, 5 → 6, which fit a 7427), and the BELT input from
sheet D (`SHEET_D_COMPARE.md`: BELT (C) is a new output of D). The 62.8 → 51.5
branch is a dot at (2980, 4540) on the existing 62.8 → 75.10 row. All
clear.

**For reuse:** in the Monaco module, replace 7M in the IC14 term with
D-EXTEND and AND in NOT BELT and NOT splash term. The 7M input to sheet C
is then needed only for the AREA latch.

### D3. EXTEND and /EXTEND come from sheet B, without pads

The original takes EXTEND (pad EB) and /EXTEND (pad E3) from sheet A and
passes both on to M (and EXTEND to D) by arrows. Pro draws `Ⓑ D-EXTEND`
and `/D-EXTEND` as plain arrows with no pad, and draws no output arrow to
M or D. Each one drives the same pins as before: D-EXTEND the
extended-play mux select, the common-dim NOR and (new) 57.5; /D-EXTEND the
OR in front of the blue NAND. The M and D comparisons read D-EXTEND and
/D-EXTEND as arriving there from B directly, which agrees. /D-EXTEND's
circled letter is broken and reads like C or E, so its source sheet is
uncertain on this page. That D-EXTEND matches the original EXTEND in timing
and polarity is a question for sheet B; it was not checked.

**For reuse:** the input is renamed and comes from sheet B's logic; see the
sheet B comparison when it is done.

## Still uncertain

| Item | Where | What would settle it |
|---|---|---|
| /D-EXTEND's circled source letter (C or E shapes; B expected) | (1550, 4580, 2700, 4850) | Pro sheet B's output list |
| The `GRASS` and `TREE & GRASS` suffixes read `(Bu)`; the original trace reads `(BL)` | (1500, 1600, 2300, 2350) | Pro sheet D's output labels (net unchanged either way) |
| Designators: the 157s read `E1`, `E3` (61, 63?); the brightness NAND `43` or `48`; white NAND `80`-like; yellow NAND not legible; 75's output numeral 3 or 8 | as in the tables | the parts list or a cleaner print; no net depends on them |
| Pad captions for AREA 1..5, /OTHER BODY, /LIGHT, /PLAYER (BL), the TIAR pads | (1900, 600, 2450, 3150) | a cleaner print; wiring is clear |
| The original's U1 (cyan label), U2 (IC8 drawn as AND), U3 (POOL/HOUSE suffixes) and U4 (IC8.4 open) | the same places on Pro | Pro draws them the same way, so it does not settle them |
| The analogue level of blue with R8 active | output stage | a calculation with the monitor input impedance, not part of this comparison |

## Not checked

- Where BELT, D-EXTEND and /D-EXTEND come from on sheets D and B (the D
  comparison covers BELT; sheet B is outside this issue).
- Supply pins and bypass capacitors.
- The /+200 path (excluded, `SHEET_M_C_PLUS200_TRACE.md`).
- The other end of each off-sheet input whose label matched the original.
- Gameplay meaning of the blue-term changes. The logic is given as drawn.

## Short report

- **Established:** Pro sheet C is the original circuit with three changes:
  a blue-only 470 Ω pull-down driven by the extended-play blue term (D1);
  that term regated with D-EXTEND in place of 7M and with BELT and the
  splash term added through new parts 92 and 51 (D2); and EXTEND and
  /EXTEND taken from sheet B as D-EXTEND and /D-EXTEND, with no pads and no
  pass-through to M and D (D3). All collectors, both multiplexers, the
  encoder and the RGB, blanking and sync stages otherwise match by net and
  value.
- **Counts:** 76 rows: 67 same, 9 differ, 0 can't settle. The 9 rows
  cover the three differences D1–D3.
- **Still uncertain:** /D-EXTEND's circled letter, the label suffixes,
  some designators and pad captions. None of them changes a net.
- **Not checked:** the B and D ends of the new and renamed signals, power,
  and the excluded +200 path.
