# Sheet D compare: Pro page 15 against the original (Pro Monaco GP)

Date: 2026-11-06. Issue #86. Comparison by function and net of Pro sheet D
(96823-P D-3/5, PDF page 15, scenery PROMs and the scenery-event control)
with the original sheet D (96578-P D-3/5) as transcribed in
`docs/trace/SHEET_D_TRACE.md` (consolidated pin list of 29 October 2026).
Every block of the original pin list was located on the Pro page and
compared. Wiring that looked different was followed on the scan, pin by pin.
Wiring that looked the same at block level was compared by its drawn
geometry and pin numerals, not walked wire by wire; those rows say so.
/BRIDGE AP into sheet N is left out: it is traced in
`pro/docs/trace/BONUS_INPUTS_TRACE.md` ("/BRIDGE AP (sheet D, Pro page 15)").

**Main results**

1. **The scenery-event decoder has a new input stage.** On the original,
   pads S-100-A..D go straight to the 7442 (IC24). On Pro they go through a
   new 74157 (IC34). Its other inputs come from a new 74393 (IC41, both
   halves) and an XOR (IC13), with one inverter section (IC36 1→2). The new
   input **/DISPLAY (B)** drives the 74157 select and clears both counters.
   The second counter's QD leaves as a new output, **D-TIME (B)**. While
   /DISPLAY is high, the pads pass to the decoder as on the original. While
   it is low, the counters drive the decoder. 100-C to M is taken after the
   multiplexer.
2. **Two decoder outputs are rewired.** Output 1 (pin 2) is not connected.
   Output 6 (pin 7) now drives the /CLR of the EXT. 500 flip-flop. On the
   original, both went to an AND (IC47 4, 5 → 6) that clocked the POOL
   pre-stage flip-flop. That flip-flop is now clocked by the inverted
   decoder D input (IC36 5 → 6 from the 74157's 4Y). The EXT. 500
   flip-flop's /CLR no longer comes from the NAND (original IC45, Pro 75),
   which now clears only the pre-stage.
3. **/COIN IN (B) is replaced by /D-GAME (B)** at the same point: the clear
   NOR of the four state flip-flops and the counter (original IC34 9, with
   470 pF; Pro 63.3 with C16 470 pF).
4. **EXTEND comes from B as `D-EXTEND`**, not from C as on the original.
   It goes to the same two flip-flop D inputs.
5. **New outputs:**
   - **SLIP (H)** on pad **EH**, from the SLIP flip-flop's Q.
   - **SLOW**, an inverter (IC9? 5 → 6) of the same Q. The destination
     letter is not legible.
   - **BELT (C)**, a branch of the AND (Pro 21, 1, 2 → 3; original IC58 13,
     12 → 11) that feeds the TREE & GRASS (G) NOR.
6. **Pad E7 now carries /ACCI. AREA (F)**, the output of a new 3-input gate
   (Pro 96, 9, 10, 11 → 8: OR body with all inputs and the output bubbled,
   so an AND of the drawn signals). Its inputs are ROAD (the ROAD
   flip-flop's Q), /BRIDGE (W) and /RESCUE (Y), both new inputs from M. On
   the original, E7 carried ROAD to F. ROAD (C) and /ROAD (C) are unchanged.
7. **/R1-SIDE and /L1-SIDE go to M**, with no pads. On the original they
   left on pads FD and FC to H. FD now carries /BRIDGE AP to N.
8. **Added capacitors:**
   - C10, C11, C12, 470 pF ×3, on 7442 outputs 7, 6, 5 (pins 9, 7, 6);
   - C13, 470 pF, on the new XOR output;
   - C5, C6, C7, 470 pF ×3, on /HOUSE (St), (Mu), (R) (none on /HOUSE (W));
   - C33, C35, C34, C36, 1000 pF, on the four PR-134/PR-135 153 outputs.
   The original drew none of these. The original's three 470 pF (on
   /COIN IN, on the HSB flip-flop's /Q at the counter clock, on SLIDE)
   are all present on Pro as C16, C4 and C8.
9. **Pull-ups:** RA1 (560 Ω ×4) becomes discrete R12–R15, 560 ×4. Same
   value and nets. The pad captions now read DI7, DI6, DI5, DI4.
10. **No difference found** in:
    - the M1V/M2V/MH bus inputs;
    - the PROM address multiplexers (157 ×2) and the four PROMs PR-134..137
      with their 153/157 output multiplexers;
    - the HOUSE 7442;
    - the side-wall decode (IC78/IC90/IC81/IC82 group) and the vertical
      decode 7442 (original IC96) with its gates;
    - the 151/151/279 HSB counter block;
    - the 393 state counter and its clear NOR;
    - the GRAVEL, POOL, SLIP, TUNNEL, BRIDGE and M-ROAD flip-flops (apart
      from the clocks and clears in items 2–3);
    - the ROAD flip-flop;
    - the SLIDE, WALL, GRAVEL, POOL, Y-LINE, GREEN BELT, GRASS and
      TREE & GRASS output gates.
    These were compared at block and pin-numeral level; see the tables for
    which were walked.

Two drawing questions the original left to the real game are drawn the
same way on Pro, so Pro does not settle them independently:
- The GRAVEL gate (original IC66, Pro "75") is drawn as an AND with no
  output bubble, like the settled AND reading.
- The two side-wall gates (original IC90, Pro "37") are drawn with the same
  mixed bubbles as the original.

## Sources and method

- Pro: `pro/schematics/promonacogp420-0525_1.pdf`, PDF page 15, rendered
  with PyMuPDF at `Matrix(1, 1)`, upright: 10175 × 6617 pixels. Every box
  below is (left, top, right, bottom) on that render.
- Original: `schematics/pages/page31-sheet-D.png` (10160 × 6624; the two
  pages line up within about 50 px, so most boxes are usable on both) and
  `docs/trace/SHEET_D_TRACE.md`, consolidated pin list. Original IC numbers
  are cited from that list. `docs/SHEET_D_LOGIC.md` was read for the
  function of the state block.
- Method:
  - The page was first compared in 16 tiles of 2300 × 1650 px at 0.6×, Pro
    beside original.
  - Areas that differed, and every net of the decoder and new input stage,
    were read at 1–3×.
  - Long wires were followed with a row/column walker on the grey render
    (threshold 160). It reports each place where a perpendicular wire
    touches. A touch on one side only is a T; a touch on both sides with
    the wire's own width is a crossing; a wide blob is a possible dot. The
    walker bridges the scan's white vertical band near x ≈ 2850–2870, which
    cuts every horizontal wire there.
  - Only drawn dots are junctions.
- Pro pin numerals were compared with the standard pinouts:
  - 74157: 1 S, 2/3 1A/1B → 4, 5/6 → 7, 11/10 3A/3B → 9, 14/13 4A/4B → 12,
    15 /G;
  - 74393: 1 1CLK, 2 1CLR, 3–6 1QA–QD, 13 2CLK, 12 2CLR, 11–8 2QA–QD;
  - 7442: outputs 0–7 on 1–7, 9;
  - 7474.
  Where a numeral disagrees, both are given.
- Confidence:
  - **clear**: read directly, no competing reading.
  - **probable**: one reading fits much better, but the scan is not clean,
    or the row was compared by drawn geometry and numerals rather than
    walked.
  - **uncertain**: the scan does not settle it.
- Excluded:
  - /BRIDGE AP to N (`BONUS_INPUTS_TRACE.md`);
  - the +200 path, which does not touch sheet D;
  - PROM contents.
- No MAME, emulator, other core, KiCad redraw, footage or gameplay
  description was used.

## Comparison by function

Pro designators are as read. Several are faint or reused (see "Still
uncertain"), so rows are identified by function and the original IC.

### Scenery-event input and decoder (original IC24, RA1, IC47)

| Function / net | Original (trace ref) | Pro reading | Pro box | Verdict | Confidence |
|---|---|---|---|---|---|
| Pads S-100-A..D from I | 4 pads, RA1 560 Ω pull-ups, to 24.15/14/13/12 | 4 pads captioned DI7, DI6, DI5, DI4 (S-100A..D, circled I); R12–R15 560 ×4 to Vcc | (750, 2350, 1500, 3000) | same nets, pull-ups now discrete | clear |
| Decoder input path | Pads direct to 7442 A..D | Pads to 74157 IC34 pins 3, 6, 10, 13 (all B inputs). Y outputs 4, 7, 9, 12 to 7442 IC35 pins 15, 14, 13, 12 | (1000, 2650, 2400, 3650) | **differs** (new 74157) | clear |
| 74157 A inputs | none | 2 (1A) ← IC41 2QA (11); 5 (2A) ← 2QB (10); 11 (3A) ← 2QC (9); 14 (4A) ← IC36 pin 2 | same | **differs** (new) | clear for routing; pins 11/14 numerals probable |
| 74157 select and strobe | none | Pin 1 S ← **/DISPLAY (B)**, the same net as IC41 pins 2 and 12 (both clears). Pin 15 /G grounded | (700, 3050, 1800, 3600) | **differs** (new) | clear; bar over DISPLAY probable |
| Counter IC41 (393, both halves) | none | 1CLK pin 1 ← Q (pin 9) of the HSB flip-flop (original IC40 lower). 1QC 5, 1QD 6 → XOR. 2CLK 13 ← 1QD (6). 2QD 8 → **D-TIME (B)**, a new output | same | **differs** (new) | clear; the 1CLK source is probable (one wire followed by eye through a dense area) |
| XOR IC13 and inverter | none | 13 (9 ← 41.6, 10 ← 41.5) → 8, C13 470 pF to ground, → IC36 1 → 2 → 74157 pin 14 | same | **differs** (new) | clear; the XOR shape is clear, the type is not printed |
| 100-C to M | 24.13 = pad S-100-C | 74157 pin 9 (3Y) = 7442 C input | (1000, 2650, 2400, 3650) | **differs** (taken after the mux; equal to the pad while /DISPLAY is high) | clear |
| 7442 out 0 (pin 1) | → 40.3 (GRAVEL CK) | Up at x ≈ 2172, row y ≈ 2380, down at x ≈ 3455 to GRAVEL flip-flop CK 3 | walker; (2400, 2250, 3800, 3300) | same | clear |
| 7442 out 1 (pin 2) | → 47.4 | Stub, ends at x ≈ 2162; no connection | (2050, 2650, 2600, 3100) | **differs** (unused) | clear |
| 7442 out 2 (pin 3) | → 31.3 (SLIP CK) | To SLIP flip-flop CK 3 | same; walker | same | clear |
| 7442 out 3 (pin 4) | not used | Stub | same | same | clear |
| 7442 out 4 (pin 5) | → 25.11 (EXT CK) | Row y ≈ 2904 to x ≈ 4015, up to the EXT flip-flop CK 3 | walker | same | clear |
| 7442 out 5 (pin 6) | → 25.3 (BRIDGE CK), /CAR NO CONT (F3, H, M) | Row y ≈ 2947 to x ≈ 4016, down to BRIDGE CK 11. T at x ≈ 2255, down to pad F3 /CAR NO CONT (H) and the /CAR NO CONT (M) arrow. C12 (probable designator) 470 pF | walker; (1950, 5050, 3000, 6400) | same; cap added | clear |
| 7442 out 6 (pin 7) | → 47.5 | Row y ≈ 2990, jog at x ≈ 2384 to row y ≈ 2925, to x ≈ 4190, up to the EXT flip-flop **/CLR (pin 1)**. C11 470 pF | walker; (3250, 2800, 4250, 3000) | **differs** | clear |
| 7442 out 7 (pin 9) | → 31.11 (TUNNEL CK) | Up at x ≈ 2513 to row y ≈ 2989, to x ≈ 3498, down to TUNNEL CK 11. C10 470 pF | walker | same; cap added | clear for the routing to x ≈ 3498; the last drop to CK probable |
| Pre-stage CK (original 38.11) | 47.6 = AND(24.2, 24.7) | IC36 5 → 6, input ← 74157 pin 12 (4Y, the 7442 D input) | (1900, 2350, 3300, 3400); walker | **differs** | clear for the routing; the IC36 designator is shared with two other inverters, probable |
| HSB gate (47.3) | AND, 1 Vcc, 2 /HS → 3 | AND "110", 10 Vcc, 9 /HS → 8 | (1000, 3500, 2400, 4600) | same | clear |

### State flip-flops and their clears (original IC40, IC38, IC31, IC25, IC45, IC34, IC32)

| Function / net | Original | Pro reading | Pro box | Verdict | Confidence |
|---|---|---|---|---|---|
| GRAVEL flip-flop | 40 upper: D EXTEND, CK 24.1, CL 34.10 | 42 upper: D 2 ← D-EXTEND, CK 3 ← out 0, CL 1 ← the clear bus | (2400, 2250, 3800, 3300) | same function; EXTEND source differs (row below) | probable |
| EXTEND source | (C) EXTEND | **(B) D-EXTEND** | (750, 2350, 1500, 3000) | **differs** (source sheet and name) | clear |
| HSB/MHL0 flip-flop | 40 lower: 12 HSB, 11 /MHL0, Q 9 → 38.3; /Q 8 → 49.13, 45.1, 470 pF | 5 (pins 12, 11, 9, 8): D HSB, CK /MHL0. Q 9 → POOL CK and IC41 1CLK. /Q 8 → 104 CP (C4 470 pF) and 75.1 | (1000, 3500, 2400, 4600); (2350, 3300, 3650, 4300) | same, plus the new IC41 load | probable |
| Pre-stage flip-flop | 38 (8–13): D /TUNNEL, CK 47.6, CL 45.3, Q → POOL D | Pins 1–6 (designator unclear, "7"?): D ← x ≈ 2515 riser (not followed to its source), CK ← IC36.6, CL 1 ← 75.3 (drawn dashed), Q 5 → POOL D 12 | (2350, 2380, 3300, 3000) | **differs** in CK (above); D same position; D source not walked | CK clear; D probable |
| POOL flip-flop | 38 (1–6): D 38.9, CK 40.9, Q 5 → 45.2, /Q 6 → 31.2, 89.4 | 49 (8–13): D 12 ← pre-stage Q, CK 11 ← HSB flip-flop Q, Q 9 → 75.2, /Q 8 up | (2400, 2250, 3800, 3300) | same (halves swapped) | probable |
| NAND 45 / Pro 75 | 1 ← 40.8, 2 ← 38.5 → 3 → 38.13 and 25.13 | 1 ← left row, 2 ← POOL Q → 3 → pre-stage CL **only** | (2650, 2400, 3000, 2560) | **differs** (no longer clears EXT) | probable: no second branch from 75.3 is drawn; the pin-1 source was not walked |
| EXT. 500 flip-flop | 25 upper: D EXTEND, CK 24.5, CL 45.3; Q → 25.2, EXT. 500 (H); /Q → /EXT. 500 (M), EJ (F) | 56 (1–6): D 2 ← D-EXTEND row, CK 3 ← out 4, **CL 1 ← out 6**; Q 5, /Q 6 to the same output group (EXT. 500 (H), (F), /EXT. 500 (M), pad EJ) | (3700, 2250, 5100, 3300); (3250, 5700, 3950, 6400) | **differs** in CL; outputs same | CL clear; the output bars are probable |
| BRIDGE flip-flop | 25 lower: D 25.9, CK 24.6, CL 34.10 | 56 (8–13): D 12 ← 56.5, CK 11 ← out 5, CL 13 | same | same | clear (also in `BONUS_INPUTS_TRACE.md`) |
| SLIP flip-flop | 31: D 38.6, CK 24.3, CL 34.10; Q → 32.5; /Q → 31.12, 73.1 | 49 (1–6): D 2, CK 3 ← out 2, CL 1. Q 5 → 128.2, and **also to pad EH SLIP (H) and the SLOW inverter** (x ≈ 3371, from y ≈ 3117 to 5478) | walker; (2950, 5300, 3450, 6350) | **differs** (new loads) | clear |
| TUNNEL flip-flop | 31 (8–13): D 31.6, CK 24.9; /Q → /TUNNEL (EF, F, G), 80.11, 38.12 | 42 (8–13): D 12, CK 11 ← out 7; /Q 8 to the same group, pad EF | (2400, 2250, 3800, 3300); (3250, 5700, 3950, 6400) | same | probable |
| Clear NOR (34.10) | 8 ← 47.11, 9 ← /COIN IN with 470 pF → 10 | 63: 2 ← 57.3, 3 ← **/D-GAME (B)** with C16 470 pF → 1, to the flip-flop clear bus | (2350, 3300, 3650, 4300); walker x ≈ 3214 to y ≈ 5082 | **differs** (input name and source) | clear |
| Counter IC49 / Pro 104 | 393½: CP 13 ← 40.8, CL 12 ← 32.6; QA..QD | 104, `393½`: CP 13 (C4 470 pF), CL 12 ← 128.6; QA 11, QB 10, QC 9, QD 8 | same | same | probable |
| OR 39 / Pro 98 | 12 QB, 13 QC → 11 | 98: 10 QB, 9 QC → 8 | same | same | probable |
| AND 47 (11) / Pro 57 | 12 QC, 13 QD → 11 → 34.8 | 57, faint body, → 3 → 63.2. Lower input ← QD (dot). The upper input stub has no visible wire; the QC branch ends at the QD wire with no dot | (2780, 3740, 3100, 3940) | can't settle the upper input | uncertain |
| 4-input NOR 32 / Pro 128 | 5 31.5, 2 31.9, 4 25.5, 1 40.5 → 6 → 49.12 | 128: 2, 4, 5, 1 → 6 → 104.12. Same four rows in the same order | same | same | probable (numerals renumbered) |
| /TUNNEL & BRIDGE NOR (34.4) | 6 31.9, 5 25.5 → 4 → (B) | 63: 6, 5 → 4 → `TUNNEL & BRIDGE`; the circled letter reads D or B | (3250, 5700, 3950, 6400) | same function; letter can't settle | uncertain (letter) |

### HSB counter, side walls, vertical decode, ROAD (original IC48, IC41, IC68, IC78, IC90, IC81, IC82, IC117, IC88, IC74, IC96, IC95, IC104, IC89, IC56, IC65, IC110)

| Function / net | Original | Pro reading | Pro box | Verdict | Confidence |
|---|---|---|---|---|---|
| 151 (orig 48) | D0 HSB, D1 /MHL0, D2–D6 Vcc, D7 HSB; 5 → 68 /S | 97: 4 HSB, 3 /MHL0, 2, 1, 15, 14, 13 Vcc, 12 HSB; 7 GND; 5 → 91 /S 6 | (1000, 3500, 2400, 4600) | same | clear |
| 151 (orig 41) | D0 Vcc, D1–D6 HSB, D7 /MHL0; 5 → 68 /R | 90: 4 Vcc, 3–13 HSB, 12 /MHL0; 5 → 91 /R 5 | (1000, 3500, 2400, 4600) | same | probable |
| 279 latch | 68, pins not drawn | 91, `279/4`: /S 6, /R 5, Q 7 | same | same (pins now drawn) | clear |
| Side-wall NAND4s (orig 78) | 1, 2, 5, 4 → 6 → 82.13; 13, 9, 10, 12 → 8 → 82.1 | 44: 2, 4, 5, 1 → 6 → 9 (13 → 12); 44: 3, ... → 8 → 9 (11 → 10) | (4500, 1850, 5600, 2650) | same | probable |
| Side-wall gates (orig 90) | 13, 12, 10, 9 → 8; 2, 1, 4, 5 → 6; drawn AND + NOR (settled 7425 by the game) | 37: 13, 12, 10, 9 → "3" (reads 3 or 8), bubble on 9 only; 37: inputs bubbled → 5/6. Same mixed drawing as the original | same | same drawing; does not settle the type | uncertain (type), probable (nets) |
| M2V2 inverter (orig 117 3 → 4) | → 90.4 | 36 13 → 12 → the second 37 | (3050, 450, 5350, 2100) tile | same | probable |
| /R-SIDE, /L-SIDE NANDs (orig 81) | 13, 12 → 11; 1, 2 → 3 | 15: 2, 1 → 3; 4, 5 → 6 | (4500, 1850, 5600, 2650) | same | probable |
| /R1-SIDE, /L1-SIDE outputs | pads FD, FC → (H) | Arrows to **(M)**, no pads | (8350, 3300, 9200, 3550) | **differs** (destination; pads removed) | clear |
| Upper-H flip-flop (orig 88 upper) and gate 95 | 95 AND (12 MH8, 13 MH7 → 11) → CL; D MH6, CK MH5; /Q 6 → 89.3 | 27, NOR body with bubbled inputs (= AND), 1, 2 → 3 → CL 1 of 5; D 2, CK 3; /Q drawn as pin "5" | (1350, 1900, 2400, 2650) | same function; /Q numeral 5 disagrees with the 7474 pinout (6) | clear; numeral recorded as drawn |
| M-ROAD flip-flop (orig 88 lower) | D /V8, CK 81.11, CL 81.3; Q → 96.12, 104.2; /Q /M-ROAD | 40 (1–6): D 2, CK 3, CL 1; Q 5, /Q 6 → /M-ROAD (D) | (5200, 4950, 7500, 6600) tile | same | probable |
| ROAD flip-flop (orig 74) | D /V8, CK /M1VL0, CL /M2VL0; Q ROAD → (C), E7 (F), 94.11; /Q /ROAD (C) | 40 (8–13): D 12 /V8, CK 11, CL from the /M2VL0 riser; Q 9 → ROAD (C) and up; /Q 8 → /ROAD (C) and up. **Q no longer reaches E7**: it goes to 96.9 | (900, 4950, 3200, 6600) | **differs** at E7 (below) | clear |
| Vertical decode 7442 (orig 96) and gates 110, 95, 104, 56, 65, 89, 82 | as pin list | 42 (15, 14, 13, 12); 50 (bubbled OR, 4, 5 → 6); 52; 58; 13; 33; 23; 17 (13, 2, 1) → 36 (3 → 4) /0-AREA (M) | (5200, 1950, 7500, 3600) tile | same | probable |
| GRAVEL gate (orig 66) | 3 75.6, 4 82.10, 5 73.6 → 6 GRAVEL; AND (settled by the game) | "75" (reads 75, possibly 73): 13, 1, 2 → 12 GRAVEL. AND body, no output bubble; the output wire starts just past the tip, as on the original | (5300, 3080, 5800, 3330) | same drawing; agrees with the AND reading | probable |

### PROM path and outputs (original IC92, IC67, PR-134..137, IC112, IC105, IC98, IC97, IC119, IC60, IC58, IC72, IC80, IC22, IC87, IC94, IC73, IC59)

| Function / net | Original | Pro reading | Pro box | Verdict | Confidence |
|---|---|---|---|---|---|
| Bus inputs | M1V0–3, M2V0–3, 5–7, M1V4, /M1VL0, M2V4, /M2VL0, M1V5–7, MH0–8 from B | Same labels in the same order | (900, 550, 1400, 2050) | same | clear |
| Bus taps | tap pattern | Same columns, same rows, same dots, compared tile by tile | (3050, 450, 5350, 2100) | same | probable (not walked tap by tap) |
| Address muxes (orig 92, 67) | 157 ×2, select 104.3, /G GND | 38 and 45, `157`; same pin numerals and output risers | (5200, 450, 7500, 2100) | same | probable |
| PR-134 + 153 (orig 113, 112) | as pin list | PR-134 IC32 (B-TREE/S-TREE), 153 IC31 | (7350, 450, 9650, 2100) | same | probable |
| PR-135 + 153 (orig 106, 105) | as pin list | PR-135 IC25, 153 IC24 | (7350, 1950, 9650, 3600) | same | probable |
| PR-136 + 157 + 7442 (orig 99, 98, 97) | HOUSE outputs 2, 3, 4, 5 → /HOUSE (R), (Mu), (St), (W) | PR-136 IC13, 157 IC12, 7442; same outputs | (7350, 3450, 9650, 5100) | same | probable |
| /HOUSE output caps | none | C7 on (R), C6 on (Mu), C5 on (St), 470 pF ×3, dots clear; none on (W) | (8000, 4300, 8700, 4950) | **differs** (added) | clear |
| PR-137 + 153 (orig 120, 119) | as pin list | PR-137 IC19, 153 IC18 | (7350, 4950, 9650, 6600) | same | probable |
| 153 output caps | none | C34 1000 pF on 31.9; C36 1000 pF on 31.7; C33 1000 pF on 24.7; C35 1000 pF on 24.9 | (7350, 450, 9650, 2100); (7350, 1950, 9650, 3600) | **differs** (added) | probable (dots read at tile scale) |
| TREE & GRASS (G) NOR3 (orig 60) | 9 112.9, 10 105.7, 11 58.11 → 8 | 17, 3 inputs → 8 | (7350, 450, 9650, 2100) | same | probable |
| /TREE & GRASS (BL) NOR (orig 34.13) | 11 112.7, 12 105.9 | 25 (2, 3 → 1) | same | same | probable |
| /GRASS (Bu) inverter (orig 22 3 → 4) | 105.9 | 9, 7 → 8 | (7350, 1950, 9650, 3600) | same | probable |
| /GRASS AREA, /HOUSE ST | 56.11; 81.8 | same drawn routes | same | same | probable |
| SLIDE (orig 58, 58, 65; 470 pF) | AND(/M-ROAD, /BRIDGE AP), AND(BRIDGE AP, V-④) → NOR → FR /SLIDE (G) | 21 (9, 10 → 8), 21 (→ 6, C8 470 pF), 28 (6, 5 → 4) → pad (FR, faint) SLIDE (G). First input label reads `-ROAD` with a long bar; the M is faint | (8000, 900, 9000, 1400) | same | probable (M-ROAD label) |
| BELT (new) | 58.11 → 60.11 only | 21 (1, 2 → 3) → riser x ≈ 8243 up to the TREE & GRASS (G) NOR, with a dot at y ≈ 5450 → **BELT (C)** | walker; (8150, 5100, 8750, 5550) | **differs** (new output) | clear |
| /POOL, /WALL, /GRAVEL outputs (orig 72) | NANDs → /POOL (C, FM F), /WALL (C), /GRAVEL (C, F14 G) | 15 → /POOL (C), pad FM (F); 23 → /WALL (R) (C); 23 → /GRAVEL (C), pad F14 (G) | (7350, 4950, 9650, 6600) | same | clear |
| WALL AND, /Y-LINE, GREEN BELT, AP gates (orig 87, 94, 80) | as pin list | 27 (9, 10 → 8 WALL), 27 (12, 13 → 11 /Y-LINE), 39 ×2, 63 (AP), 53, 47, 46 | (5200, 4950, 7500, 6600); (3050, 3450, 5350, 5100) | same | probable |
| SLIP NOR and /SLIP (orig 73, 59) | 73 → SLIP → 59 → /SLIP (C), FA (F) | 46 → SLIP → 9 (13 → 4) → /SLIP (C), pad FA (F) | (5200, 4950, 7500, 6600) | same | probable |
| BRIDGE AP outputs | BRIDGE AP (C), pad F18 BRIDGE AP (D/M/H), /BRIDGE AP local | Same, pad caption not legible; /BRIDGE AP to N on FD (excluded, see `BONUS_INPUTS_TRACE.md`) | (3250, 5700, 3950, 6400) | same | probable (pad caption) |
| /EXT. 500 (M), EXT. 500 (F/H), pad EJ | as pin list | same group, pad EJ | same | same | probable |
| /0-AREA (M), V-④ (B), /SIDE LINE (C), GREEN BELT (C), TUNNEL AP (C), /M-ROAD (D), /Y-LINE (C) | as pin list | same labels and circled letters | tiles 01–33 | same | probable |

### Bottom edge: E7 and new labels

| Function / net | Original | Pro reading | Pro box | Verdict | Confidence |
|---|---|---|---|---|---|
| Pad E7 | ROAD (F), from the ROAD flip-flop Q | **/ACCI. AREA (F)** from 96.8. Gate 96: OR body, bubbles on inputs 9, 10, 11 and output 8, so 96.8 = AND(9, 10, 11). 9 ← ROAD (flip-flop Q), 10 ← /BRIDGE (W) (M), 11 ← /RESCUE (Y) (M) | (1950, 5050, 3000, 6400) | **differs** | gate and wiring clear; the label `ACCI. AREA` probable; the pin-10/11 assignment of the two M inputs probable |
| /BRIDGE (W), /RESCUE (Y) | not on the original D | Two inputs from M (arrows into the sheet) | same | **differs** (new inputs) | probable (labels faint) |
| SLOW | none | 9? (5 → 6), input = SLIP flip-flop Q, output arrow `SLOW`, circled letter illegible | (2450, 5550, 2750, 6250) | **differs** (new) | wiring clear; destination uncertain |
| Pad EH, SLIP (H) | none | Pad EH, `SLIP` (no bar seen) to H, from SLIP flip-flop Q | (2950, 5300, 3450, 6350) | **differs** (new) | clear; bar absence probable |
| /CAR NO CONT pad | F3 → (H); arrow → (M) | pad F3 → (H); arrow → (M) | (1950, 5050, 3000, 6400) | same | probable (numeral 3/7) |

## Differences

1. **New decoder input stage: 74157, 74393, XOR; /DISPLAY in, D-TIME out.**
   - Box (700, 2350, 2700, 3700).
   - Clear for wiring. Bar on /DISPLAY and the XOR/inverter types are
     probable.
   - To reuse the Monaco module:
     - add a 4-bit multiplexer in front of the 7442;
     - when /DISPLAY is low, the decoder sees QA, QB, QC of a second 393
       half and NOT(1QC XOR 1QD) of the first;
     - the first half counts the HSB flip-flop's Q;
     - both halves are cleared while /DISPLAY is high;
     - add the D-TIME output (2QD);
     - feed 100-C from the multiplexer output.
   - Where /DISPLAY and D-TIME come from and go to on sheet B was not
     traced.
2. **Decoder out 1 unused; out 6 clears the EXT. 500 flip-flop; the
   pre-stage clocks on NOT(decoder D input).**
   - Walker routes are listed in the table. Clear.
   - In the module:
     - remove the IC47 4/5 AND;
     - clock the pre-stage from the inverted D input;
     - take the EXT. 500 /CLR from 7442 output 6;
     - the NAND of the HSB /Q and POOL Q clears only the pre-stage.
3. **/COIN IN replaced by /D-GAME (B)** on the clear NOR (C16 470 pF).
   Clear. Same gate; only the signal changes.
4. **EXTEND source: D-EXTEND from B** (was EXTEND from C). Clear label.
   Same function inside D, unless B's D-EXTEND differs from C's EXTEND (not
   checked).
5. **New outputs SLIP (pad EH, to H), SLOW (inverted SLIP Q), BELT (to C).**
   Clear wiring; SLOW's destination letter is uncertain. They only add
   outputs to the module.
6. **E7 carries /ACCI. AREA = AND(ROAD, /BRIDGE (W), /RESCUE (Y))** instead
   of ROAD. Two new inputs from M. Gate clear, labels probable. Sheet F's use
   of E7 must be rechecked against Pro F.
7. **/R1-SIDE, /L1-SIDE to M**, no pads FD/FC. Clear. No logic change on D.
8. **Capacitors added:** C5–C7, C10–C13 470 pF; C33–C36 1000 pF. Clear,
   except the C33–C36 dots (probable). No logic change. These are filters
   on decoder outputs, the XOR and the scenery pixel outputs.
9. **Pull-up network RA1 → R12–R15** (560 ×4). Clear. No logic change.

## Still uncertain

- **Gate 57's upper input** (original 47.12 = QC). No wire is visible to it.
  The QC branch ends at the QD wire without a dot. A cleaner scan or the
  board would settle it. If QC is not connected, the open input reads high
  and the counter clears at QD alone (8) instead of at 12. **Not settled;
  do not change the Monaco module's count on this reading alone.**
- **Designators.**
  - "75" is both the 2-input NAND (pins 1, 2 → 3) and the GRAVEL gate
    (13, 1, 2 → 12). Both use pins 1 and 2, so one numeral is misread or
    miswritten; the GRAVEL one may be 73.
  - The pre-stage flip-flop's designator is unread.
  - IC36 is printed beside three inverter sections.
  - The HOUSE 7442 shows "6" and "97", and 97 is also the 151.
  None of this changes a net.
- **/Q of the upper-H flip-flop drawn as pin 5.** The 7474 gives 6. The
  drawn output is the /Q side, as on the original.
- **The side-wall gates' type (original IC90)** is drawn as ambiguously as
  on the original. The Pro drawing does not settle it. The original's
  game-settled 7425 reading is not contradicted.
- **Circled letters:**
  - TUNNEL & BRIDGE: D or B (the original reads B);
  - SLOW: illegible.
  - pad captions FR (SLIDE), F3/F7 (CAR NO CONT), the BRIDGE AP pad (F18
    on the original).
- **/DISPLAY's bar, and the labels `ACCI. AREA`, `/BRIDGE (W)`,
  `/RESCUE (Y)`**: probable. Sheet B and M traces would confirm the
  names.
- **D input of the pre-stage flip-flop** (original /TUNNEL): same drawn
  position, not walked.

## Not checked

- Bus taps one by one. The pattern was compared tile by tile.
- PROM, 153 and 157 pin numerals beyond their drawn positions.
- Every pin numeral of the gates marked probable. Those rows were compared
  by drawn geometry and numeral position, not walked.
- Where /DISPLAY, D-TIME, D-EXTEND, /D-GAME, SLOW, BELT, SLIP (EH),
  /ACCI. AREA, /BRIDGE (W) and /RESCUE (Y) go or come from on sheets B, C,
  F, H and M.
- Whether 100-C's change matters on M.
- Timing or filter effects of the added capacitors.
- The M8/pin-8 and jumper notes (`ジャンパー線無し` boxes) on the page.

## Short report

- **Established (wiring read on the scan):**
  - Pro sheet D keeps the original scenery path unchanged at the level
    compared: bus, PROM address muxes, PR-134..137 and their output
    multiplexers, the HOUSE decoder, the side-wall and vertical decode, the
    HSB counter, the ROAD and M-ROAD flip-flops and the output gates.
  - It differs in the scenery-event control:
    - a new 74157/74393/XOR stage selects between the S-100 pads and a
      counter under /DISPLAY, with a D-TIME output;
    - decoder output 1 is unused and output 6 now clears the EXT. 500
      flip-flop;
    - the pre-stage flip-flop is clocked by the inverted decoder D input;
    - /COIN IN becomes /D-GAME;
    - EXTEND comes from B.
  - New outputs: SLIP (EH), SLOW, BELT.
  - E7 now carries /ACCI. AREA = AND(ROAD, /BRIDGE (W), /RESCUE (Y)).
  - /R1-SIDE and /L1-SIDE now go to M without pads.
  - Thirteen capacitors were added, and RA1 became discrete resistors.
- **Count, rows in the comparison tables:** 72 rows. **same 46**,
  **differs 24**, **can't settle 2** (gate 57's upper input; the TUNNEL &
  BRIDGE destination letter). Several "same" rows are probable rather than
  walked.
- **Still uncertain:**
  - gate 57's upper input, which would change the state counter's clear
    point;
  - designator clashes (75, 36, 97);
  - the side-wall gate type;
  - circled letters for SLOW and TUNNEL & BRIDGE;
  - the label readings ACCI. AREA, /BRIDGE (W), /RESCUE (Y).
- **Not checked:** the other sheets' ends of every new or renamed signal;
  bus taps individually; capacitor timing; the jumper notes.
