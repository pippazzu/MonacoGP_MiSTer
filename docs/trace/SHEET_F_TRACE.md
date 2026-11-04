# Sheet F — accelerator, steering, gear shift, player position and collision control

Source: Sega **Monaco GP (420-0358)**, PDF page **26**, drawing **F**, board
**96577-P**, sheet **D-2/4**, "IC BOARD ASS'Y, A" (Japanese caption:
プレイヤー（アクセル・ハンドル・シフトレバー）コントロール, player
(accelerator, handle, shift lever) control). Image:
manual 420-0358, PDF page 26, **10176 × 6624** pixels, SHA-256
`c632f2ce8c5fbb369b307036510d8b2662598b4a0b6f27cba8149c0420c2a056`.

**Status: complete pin-level trace, every row checked on the scan
(25–26 October 2026).** This file replaces the pass-by-pass working log,
which is kept unchanged in the working notes (not published).
That log holds the evidence and the human reviews behind the F1–F45 items
cited below.

## How this trace was made

1. Codex and the maintainer transcribed the sheet in 15 passes (23–25 October). They
   settled about 45 doubtful crossings, designators and glyphs with the maintainer's
   own readings (F1–F45 in the log).
2. On 25 October the maintainer asked for every reading to be compared with
   stonedDiscord's KiCad redraw of board 96577, treating the redraw as
   reliable unless the scan clearly contradicts it.
3. Claude then took every pin the redraw places on this sheet and followed
   it on the scan, wire by wire, to both ends:
   - 539 rows were checked: 472 confirmed, 24 that differ from the redraw,
     27 not drawn on this sheet, and 16 drawn as open stubs.
   - Doubtful crossings were measured with a dot-size measuring script.
     Junction dots measure 16–23 px; plain crossings measure 8–16 px.
   - Every place where the scan and the redraw differ is listed under
     "Differences from the redraw". The scan reading is used in the tables.

The redraw has no licence. It was used only to predict which pins to follow.
Every row here is a reading of the scan. Signal names are the labels drawn
on the scan; pad names are the letters printed next to the pads.

## Conventions

- **Frame R.** The stored PNG is upside down. All coordinates here are in
  its 180°-rotated, upright view (frame R).
  - A box `(x0,y0,x1,y1)` in frame R is
    `(10176-x1, 6624-y1, 10176-x0, 6624-y0)` in the stored image.
  - Evidence boxes give both frames.
- **Notation.** `/NAME` is an overbar. `(G)` is a circled sheet letter.
  `ICn.p` is pin p of IC n.
- **Gate function** is taken from the drawn body:
  - AND body with input bubbles: NOR.
  - OR body with input bubbles: NAND.
  - Bubbles on every input and on the output: AND becomes OR, and OR
    becomes AND.
- **Pin numbers** are the printed ones. Where the drawing prints none
  (IC27's third latch, IC47 outputs, IC49, IC74, IC80's second section),
  the table uses the standard pinout and the redraw's assignment. This is
  said in each case.
- **Supply pins** (7/8/14/16) are not listed. Inputs tied to Vcc or GND are.
- **"Connection"** lists the label of the net (pad or arrow, as drawn) and
  every other pin on that net on this sheet.
  - "Redraw continues to" names the pins on other sheets that the redraw
    puts on the same net. These have not been checked here. They are given
    to help the reviews of those sheets.
- **"Check"** values:
  - "scan": the row was followed on the scan and agrees with the redraw.
  - "scan; differs from redraw": the scan reading is given, and the
    redraw's reading follows.
  - "not drawn": the redraw has the pin, but this sheet does not draw it.
  - "scan: open stub": a short unconnected lead.

## Evidence boxes for the 25–26 October check

| What | Frame R | Stored |
|---|---|---|
| IC47 (both sections), IC68, IC74 and the sheet E pads | (1700,4100,3300,5150) | (6876,1474,8476,2524) |
| IC63 body shape (U1, closed) | (3930,4280,4110,4440) | (6066,2184,6246,2344) |
| IC13 "17×6" buffer bank and its pads | (6500,1950,8800,2600) | (1376,4024,3676,4674) |
| IC60 inputs from the Vs arrows | (1500,2050,4000,2900) | (6176,3724,8676,4574) |
| IC72 5,6→4 and IC66 9,10→8 | (2950,5300,3350,5620) | (6826,1004,7226,1324) |
| IC16 1,2→3 and the /ACC1. arrow | (7000,2700,8800,3000) | (1376,3624,3176,3924) |
| /EXT. 500, 8000, EXT. CAR CONT. group | (7380,300,7900,1100) | (2276,5524,2796,6324) |
| SHIFT, /SLIPZONE, /NON ROAD & POOL SLIP pads | (2600,330,3420,920) | (6756,5704,7576,6294) |
| V7, V6 labels on pads BN, B12 | (5050,700,5400,900) | (4776,5724,5126,5924) |
| Handle unit pads A8, AH, A7, AJ | (1400,3350,2300,4250) | (7876,2374,8776,3274) |
| IC49 and its Q route to IC48.10 | (2150,3150,2950,3700) | (7226,2924,8026,3474) |
| IC62, IC80 second section, /SP. IRREG. | (7300,1000,7950,3600) | (2226,3024,2876,5624) |
| IC2.4/10 route to the V6 pad row | (2000,3900,3150,5550) | (7026,1074,8176,2724) |
| F40/F41 crossings on the IC72.11 vertical | (4640,1830,4740,2540) | (5436,4084,5536,4794) |
| Shift lever inputs | (1500,1600,2800,2150) | (7376,4474,8676,5024) |
| IC3 select-pin note (U9) | (3100,3260,3480,3460) | (6696,3164,7076,3364) |
| Handwritten legend, bottom edge (U10) | (3450,5880,5000,6200) | (5176,424,6726,744) |

## Off-sheet inputs

| Label as drawn | Pad or arrow | From | Goes to on this sheet |
|---|---|---|---|
| /SP DOWN | arrow, left edge (≈1600,1010) | (G) | IC2.2, IC2.12 |
| SP. DOWN | arrow, top edge (≈4690,600–900) | (G) | IC72.12 |
| ACCE. CONT. A, ACCE. CONT. B | pads A11, AM; pad AL = Vcc, pad A10 = GND (accelerator unit, dashed box) | cabinet | IC6.9, IC6.11 |
| SHIFT LEVER SW. NO (L), NC (H), COM | pads A25 (NO; inferred, see U4), AC (NC), AY (COM = GND) | cabinet | RA1 560Ω pull-ups, RA2 100Ω, C10/C7 0.1µF → IC32.14, IC32.15 |
| /COIN & TEST | arrow (≈2060,2210) | (A) | /LOAD of IC24, IC25, IC35, IC36; IC28.11 |
| /GAME | arrow (≈2060,2345) | (A) | IC15.14 (CLR), IC5.2 (MR) |
| Vs/16, Vs/64, Vs/2, Vs/8 | four arrows (≈2050,2450–2630) | (H) | IC60.2, IC60.3, IC60.5, IC60.6; Vs/8 also IC8.1, IC34.10 |
| /SLIP | pad CA | (D) | IC43.1 |
| /POOL(2) | pad CM | (D) | IC43.9, IC49 A |
| HAN.-L-CP, HAN.-R-CP | pads A8, AJ; pad AH = Vcc, pad A7 = GND (handle unit, dashed box) | cabinet | IC1.2, IC3.3; IC1.10, IC3.13 |
| H4, H6 | pads C8, CH | (E) | IC68.12, IC68.13 |
| 7MHz | pad C13; re-exported by arrows to (G) and (H) | (E) | IC63.12 |
| H5, H8 | pads C7, CF | (E) | IC74 inputs |
| /HS | pad CJ; re-exported by an arrow to (H) | (E) | IC40.1 |
| V4, /V5, /V6, /V7 | pads BT, BU, B17, B18 (first letter hidden by the brace; B from the redraw) | (E) | IC47.12, .9, .10, .13; /V5 also IC69.3/13; /V6 also IC2.4/10, IC69.10/11 |
| V7, V6 | pads BN, B12 (braced, (E)) | (E) | IC67.4/9; IC67.1/2 |
| Vs/32 | arrow (≈1900,5400) | (H) | IC72.6, IC66.10 |
| /RESCUE (Y) | pad B8 | (M) | IC14.9 |
| /BRIDGE (W) | pad BH | (M) | IC14.10 |
| ROAD | pad B7 | (D) | IC14.12 |
| /OTHER BODY | arrow (≈2020,5760) | (H) | IC14.13 |
| /ACC1. ST | arrow (≈2050,5830) | (G) | IC80.3 |
| PLAYER | arrow (≈2050,5880) | (G) | IC80.5, IC43.2, IC43.10, IC49 B |
| /ACC1. PULSE | arrow (≈2050,6010) | (G) | IC34.2 |
| /SCORE ST. | arrow, top edge (≈6330,600–950) | (G) | IC8.9 |
| /TUNNEL | pad BF | (D) | IC8.13; the same net also leaves as an arrow /TUNNEL to (J) |
| /EXT. 500 | pad BJ | (D) | IC62.2; the same net also leaves as an arrow /EXT. 500 to (H) |
| 8000 | arrow, top edge (≈7700,600–900) | (A) | IC62.1 |
| EXT. CAR CONT. | pad BZ | (M) | IC80.13 |
| EXTEND | arrow, bottom edge (≈6510,5700) | (A) | IC33.2 |

## Off-sheet outputs

| Label as drawn | Pad or arrow | To | Driven by |
|---|---|---|---|
| SHIFT | pad AW | (S) | IC29.8 (buffer of IC32.13, the gear latch) |
| /SLIPZONE | pad AX | (S) | IC29.4 (buffer of IC43.4, the /SLIP one-shot's /Q) |
| /NON ROAD & POOL SLIP | pad A20 | (S) | IC29.2 (buffer of IC2.3) |
| /TUNNEL | arrow, top edge (≈3655,600–900) | (J) | pad BF net (see inputs) |
| ACCE. ST. | arrow, top edge (≈4130,600–1000) | (A) | IC34.6 |
| /EXT. 500 | arrow, top edge (≈7440,600–900) | (H) | pad BJ net (see inputs) |
| ACCE. D | pad B14 | (M) | IC6.12 |
| ACCE. D, C, B, A | four arrows (≈8150,1850–1990) | (H) | IC6.12, IC15.6, IC15.2, IC15.3 |
| S-ACCE D, C, B, A | pads A12, AN, A13, AP | (S) | IC13.2, .4, .6, .8 |
| /SCORE CP. | pad A14 | (I) | IC13.10 |
| /S-ACC1. | pad AR | (S) | IC13.12 |
| /ACC1. | arrow (≈8150,2850) | (G) | IC16.3 |
| /SPLAY A, /SPLAY B | two arrows (≈8150,3140/3220) | (G) | IC48.8; IC49 Q (also IC48.10) |
| /SP. IRREG. | arrow (≈8150,3440) | (H) | IC80.12 |
| PL-H-ST. | arrow (≈8150,3620) | (G) | IC17.6 |
| /HOME POS. | arrow (≈8150,3705) | (G) | IC23.8 |
| EXPLO. SEL. A, B, C | arrows (≈8150,3920–4100) | (G) | IC39.3, .4, .5 |
| EXPLO. SEL. D | pad BM and an arrow | (M) and (G) | IC39.6 |
| EXPLO. ST. | arrow (≈8150,4935) | (G) | IC33.5 |
| /EXPLO. ST. | arrow (≈8150,5015) | (G) | IC33.6 |
| PL-V-ST. | arrow, bottom edge (≈6120,5700–6050) | (G) | IC41.6 |

C23 and C40, on the PL-H-ST. and PL-V-ST. lines, are drawn on sheet G.

## Pin tables

### IC1 — 74123 dual one-shot, printed "123/2" twice

Pin numbers printed on both halves. First half 1, 2, 3, 13, 4, 14, 15; second half 9, 10, 11, 5, 12, 6, 7.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | A | IC1.9, IC3.2, IC29.3, IC43.4 | scan |
| 2 | B | pad A8, HAN.-L-CP (handle unit); IC3.3 | scan |
| 3 | /CLR | IC1.12 | scan |
| 4 | /Q | IC1.11 | scan |
| 5 | Q | IC2.5 | scan |
| 6 | Cext | C1 4.7µ | scan |
| 7 | RCext | C1 4.7µ, R2 47K to Vcc | scan |
| 9 | A | IC1.1, IC3.2, IC29.3, IC43.4 | scan |
| 10 | B | pad AJ, HAN.-R-CP (handle unit); IC3.13 | scan |
| 11 | /CLR | IC1.4 | scan |
| 12 | /Q | IC1.3 | scan |
| 13 | Q | IC2.9 | scan |
| 14 | Cext | C2 4.7µ | scan |
| 15 | RCext | C2 4.7µ, R3 47K to Vcc | scan |

### IC2 — 7408 AND (redraw 74LS08)

Section 1,2→3 is drawn as an OR body with bubbles on both inputs and the output (AND by De Morgan); 4,5→6, 9,10→8 and 12,13→11 are plain AND bodies.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC3.14, IC43.12 | scan |
| 2 |  | /SP DOWN, arrow from (G) (left edge); IC2.12 — redraw continues to G IC72.1, G IC84.20, G IC84.21 | scan |
| 3 |  | IC29.1 | scan |
| 4 |  | pad B17, /V6 (E); IC2.10, IC47.10, IC69.10, IC69.11 | scan |
| 5 |  | IC1.5 | scan |
| 6 |  | IC3.11 | scan |
| 8 |  | IC3.5 | scan |
| 9 |  | IC1.13 | scan |
| 10 |  | pad B17, /V6 (E); IC2.4, IC47.10, IC69.10, IC69.11 | scan |
| 11 |  | IC7.14 | scan |
| 12 |  | /SP DOWN, arrow from (G) (left edge); IC2.2 — redraw continues to G IC72.1, G IC84.20, G IC84.21 | scan |
| 13 |  | IC6.10, IC16.4, IC23.4 | scan |

### IC3 — 74153 dual 4-to-1 mux, printed "153"

A handwritten cloud next to the select pins reads roughly "A B / GRAVEL SLIP 1 0 / POOL 0 1 / NORMAL 1 1" (uncertain, see U9).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | Ea | GND | scan |
| 2 | S1 | IC1.1, IC1.9, IC29.3, IC43.4 | scan |
| 3 | I3a | pad A8, HAN.-L-CP (handle unit); IC1.2 | scan |
| 4 | I2a | IC9.4, IC72.4 | scan |
| 5 | I1a | IC2.8 | scan |
| 6 | I0a | GND | scan |
| 7 | Za | IC9.3, IC9.5 | scan |
| 9 | Zb | IC9.11, IC9.13 | scan |
| 10 | I0b | GND | scan |
| 11 | I1b | IC2.6 | scan |
| 12 | I2b | IC9.12, IC66.8 | scan |
| 13 | I3b | pad AJ, HAN.-R-CP (handle unit); IC1.10 | scan |
| 14 | S0 | IC2.1, IC43.12 | scan |
| 15 | Eb | GND | scan |

### IC4 — 74151 8-to-1 mux, printed "151"

W (pin 6) is an open stub.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | I3 | IC4.2, IC5.4 | scan |
| 2 | I2 | IC4.1, IC5.4 | scan |
| 3 | I1 | IC4.4, IC5.3 | scan |
| 4 | I0 | IC4.3, IC5.3 | scan |
| 5 | Z | IC8.10 | scan |
| 6 | /Z | open stub | scan |
| 7 | /E | IC16.2, IC16.12, IC23.3, IC27.1, IC72.11 | scan |
| 9 | S2 | IC6.2, IC6.13, IC10.14, IC14.5, IC80.1 | scan |
| 10 | S1 | IC6.4, IC10.11 | scan |
| 11 | S0 | IC6.6, IC10.9 | scan |
| 12 | I7 | IC4.13, IC5.6 | scan |
| 13 | I6 | IC4.12, IC5.6 | scan |
| 14 | I5 | IC4.15, IC5.5 | scan |
| 15 | I4 | IC4.14, IC5.5 | scan |

### IC5 — 74393, printed "393/2"

Only the first half (pins 1–6) is drawn.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | CP | IC67.6 | scan |
| 2 | MR | /GAME, arrow from (A); IC15.14 — redraw continues to A IC31.9, A IC37.8, A IC55.13 | scan |
| 3 | Q0 | IC4.3, IC4.4 | scan |
| 4 | Q1 | IC4.1, IC4.2 | scan |
| 5 | Q2 | IC4.14, IC4.15 | scan |
| 6 | Q3 | IC4.12, IC4.13 | scan |
| 8 | Q3 | not drawn on sheet F | not drawn |
| 9 | Q2 | not drawn on sheet F | not drawn |
| 10 | Q1 | not drawn on sheet F | not drawn |
| 11 | Q0 | not drawn on sheet F | not drawn |
| 12 | MR | not drawn on sheet F | not drawn |
| 13 | CP | not drawn on sheet F | not drawn |

### IC6 — hex inverter, drawn with a hysteresis mark (7414-type Schmitt); redraw 74LS04

Sections 1→2, 3→4, 5→6, 9→8, 11→10 and 13→12 (the last drawn pointing up, input bubble at 13).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC7.15, IC15.7, IC43.3, IC43.11, IC49.11 | scan |
| 2 |  | IC4.9, IC6.13, IC10.14, IC14.5, IC80.1 | scan |
| 3 |  | ACCE. C, arrow to (H); IC7.13, IC13.3, IC14.1, IC15.6 — redraw continues to H IC106.13, H IC115.12 | scan |
| 4 |  | IC4.10, IC10.11 | scan |
| 5 |  | ACCE. B, arrow to (H); IC7.12, IC13.5, IC14.4, IC15.2 — redraw continues to H IC113.12, H IC115.11 | scan |
| 6 |  | IC4.11, IC10.9 | scan |
| 8 |  | IC16.5 | scan |
| 9 |  | pad A11, ACCE. CONT. A (accelerator unit) | scan |
| 10 |  | IC2.13, IC16.4, IC23.4 | scan |
| 11 |  | pad AM, ACCE. CONT. B (accelerator unit) | scan |
| 12 |  | ACCE. D, arrow to (H) and pad B14 ACCE. D (M); IC13.1 — redraw continues to H IC113.15, H IC115.13 | scan |
| 13 |  | IC4.9, IC6.2, IC10.14, IC14.5, IC80.1 | scan |

### IC7 — 7485 4-bit comparator, printed "85"

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | B3 | IC22.3 | scan |
| 2 | Ia<b | Vcc | scan |
| 3 | Ia=b | Vcc | scan |
| 4 | Ia>b | Vcc | scan |
| 5 | Oa>b | IC8.2 | scan |
| 6 | Oa=b | open stub | scan: open stub |
| 7 | Oa<b | IC8.5 | scan |
| 9 | B0 | Vcc | scan |
| 10 | A0 | Vcc | scan; differs from redraw. Drawn tied to Vcc (F43 era, IC7 pin10 human review); redraw has ACCE. A |
| 11 | B1 | IC16.6, IC23.5 | scan |
| 12 | A1 | ACCE. B, arrow to (H); IC6.5, IC13.5, IC14.4, IC15.2 — redraw continues to H IC113.12, H IC115.11 | scan |
| 13 | A2 | ACCE. C, arrow to (H); IC6.3, IC13.3, IC14.1, IC15.6 — redraw continues to H IC106.13, H IC115.12 | scan |
| 14 | B2 | IC2.11 | scan |
| 15 | A3 | IC6.1, IC15.7, IC43.3, IC43.11, IC49.11 | scan |

### IC8 — 7400 NAND (redraw 74LS00)

Sections 1,2→3, 4,5→6 and 9,10→8 are AND bodies with output bubbles; 12,13→11 is an OR body with input bubbles (NAND by De Morgan).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | Vs/8, arrow from (H); IC34.10, IC60.6 — redraw continues to G IC84.23, G IC91.23, G IC98.23, H IC79.9 | scan |
| 2 |  | IC7.5 | scan |
| 3 |  | IC15.4 | scan |
| 4 |  | IC60.4 | scan |
| 5 |  | IC7.7 | scan |
| 6 |  | IC15.5 | scan |
| 8 |  | IC13.11 | scan |
| 9 |  | /SCORE ST., arrow from (G) (top edge) — redraw continues to G IC119.4 | scan |
| 10 |  | IC4.5 | scan |
| 11 |  | IC67.3, IC73.5 | scan |
| 12 |  | IC61.1 | scan |
| 13 |  | pad BF, /TUNNEL (D); also arrow /TUNNEL to (J) — redraw continues to G IC57.13 | scan |

### IC9 — 74153 dual 4-to-1 mux, printed "153"

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | Ea | GND | scan |
| 2 | S1 | IC23.10, IC44.2 | scan |
| 3 | I3a | IC3.7, IC9.5 | scan |
| 4 | I2a | IC3.4, IC72.4 | scan |
| 5 | I1a | IC3.7, IC9.3 | scan |
| 6 | I0a | GND | scan |
| 7 | Za | IC30.9 | scan |
| 9 | Zb | IC30.1 | scan |
| 10 | I0b | IC66.9, IC69.9, IC72.5 | scan |
| 11 | I1b | IC3.9, IC9.13 | scan |
| 12 | I2b | IC3.12, IC66.8 | scan |
| 13 | I3b | IC3.9, IC9.11 | scan |
| 14 | S0 | IC13.13, IC15.11, IC16.11, IC28.10 | scan |
| 15 | Eb | GND | scan |

### IC10 — 7485 4-bit comparator

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | B3 | Vcc | scan |
| 2 | Ia<b | IC11.7 | scan |
| 3 | Ia=b | IC11.6 | scan |
| 4 | Ia>b | IC11.5 | scan |
| 5 | Oa>b | IC12.5 | scan |
| 6 | Oa=b | open stub | scan: open stub |
| 7 | Oa<b | IC12.2 | scan |
| 9 | B0 | IC4.11, IC6.6 | scan |
| 10 | A0 | IC17.9, IC24.3, IC28.4 | scan |
| 11 | B1 | IC4.10, IC6.4 | scan |
| 12 | A1 | IC17.11, IC24.2, IC28.3 | scan |
| 13 | A2 | IC17.14, IC24.6, IC28.5 | scan |
| 14 | B2 | IC4.9, IC6.2, IC6.13, IC14.5, IC80.1 | scan |
| 15 | A3 | Vcc | scan |

### IC11 — 7485 4-bit comparator

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | B3 | GND | scan |
| 2 | Ia<b | Vcc | scan |
| 3 | Ia=b | Vcc | scan |
| 4 | Ia>b | Vcc | scan |
| 5 | Oa>b | IC10.4 | scan |
| 6 | Oa=b | IC10.3 | scan |
| 7 | Oa<b | IC10.2 | scan |
| 9 | B0 | GND | scan |
| 10 | A0 | IC18.9, IC25.3 | scan |
| 11 | B1 | GND | scan |
| 12 | A1 | IC18.11, IC25.2 | scan |
| 13 | A2 | IC18.14, IC25.6 | scan |
| 14 | B2 | GND | scan |
| 15 | A3 | IC18.1, IC25.7 | scan |

### IC12 — 7400 NAND, designator confirmed by the maintainer (F8)

Only sections 1,2→3 and 4,5→6 are on this sheet.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC69.7 | scan |
| 2 |  | IC10.7 | scan |
| 3 |  | IC25.5 | scan |
| 4 |  | IC34.5, IC60.7 | scan |
| 5 |  | IC10.5 | scan |
| 6 |  | IC25.4 | scan |

### IC13 — 7417 hex buffer, printed "17×6"; redraw 74LS07

Sections 11→10 and 13→12 are drawn with a bubble on the input and the output (non-inverting).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | ACCE. D, arrow to (H) and pad B14 ACCE. D (M); IC6.12 — redraw continues to H IC113.15, H IC115.13 | scan |
| 2 |  | pad A12, S-ACCE D (S) | scan |
| 3 |  | ACCE. C, arrow to (H); IC6.3, IC7.13, IC14.1, IC15.6 — redraw continues to H IC106.13, H IC115.12 | scan |
| 4 |  | pad AN, S-ACCE C (S) | scan |
| 5 |  | ACCE. B, arrow to (H); IC6.5, IC7.12, IC14.4, IC15.2 — redraw continues to H IC113.12, H IC115.11 | scan |
| 6 |  | pad A13, S-ACCE B (S) | scan |
| 8 |  | pad AP, S-ACCE A (S) | scan |
| 9 |  | ACCE. A, arrow to (H); IC14.2, IC15.3 — redraw continues to H IC115.10 | scan |
| 10 |  | pad A14, /SCORE CP. (I) | scan |
| 11 |  | IC8.8 | scan |
| 12 |  | pad AR, /S-ACC1. (S) | scan |
| 13 |  | IC9.14, IC15.11, IC16.11, IC28.10 | scan |

### IC14 — 7420 dual 4-input NAND (redraw 74LS20)

Both sections drawn as OR bodies with input bubbles. Section 1,2,4,5→6: pin numbers 1, 4, 2, 5 from top to bottom; the "1" is a short stroke above the top input.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | ACCE. C, arrow to (H); IC6.3, IC7.13, IC13.3, IC15.6 — redraw continues to H IC106.13, H IC115.12 | scan |
| 2 |  | ACCE. A, arrow to (H); IC13.9, IC15.3 — redraw continues to H IC115.10 | scan |
| 4 |  | ACCE. B, arrow to (H); IC6.5, IC7.12, IC13.5, IC15.2 — redraw continues to H IC113.12, H IC115.11 | scan |
| 5 |  | IC4.9, IC6.2, IC6.13, IC10.14, IC80.1 | scan |
| 6 |  | IC27.15 | scan |
| 8 |  | IC80.4 | scan |
| 9 |  | pad B8, /RESCUE (Y) (M) | scan |
| 10 |  | pad BH, /BRIDGE (W) (M) | scan |
| 12 |  | pad B7, ROAD (D) | scan |
| 13 |  | /OTHER BODY, arrow from (H) — redraw continues to H IC114.12 | scan |

### IC15 — 74193 up/down counter, printed "193"

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | B | GND | scan |
| 2 | QB | ACCE. B, arrow to (H); IC6.5, IC7.12, IC13.5, IC14.4 — redraw continues to H IC113.12, H IC115.11 | scan |
| 3 | QA | ACCE. A, arrow to (H); IC13.9, IC14.2 — redraw continues to H IC115.10 | scan |
| 4 | DOWN | IC8.3 | scan |
| 5 | UP | IC8.6 | scan |
| 6 | QC | ACCE. C, arrow to (H); IC6.3, IC7.13, IC13.3, IC14.1 — redraw continues to H IC106.13, H IC115.12 | scan |
| 7 | QD | IC6.1, IC7.15, IC43.3, IC43.11, IC49.11 | scan |
| 9 | D | GND | scan |
| 10 | C | GND | scan |
| 11 | /LOAD | IC9.14, IC13.13, IC16.11, IC28.10 | scan |
| 12 | /CO | open stub | scan: open stub |
| 13 | /BO | open stub | scan: open stub |
| 14 | CLR | /GAME, arrow from (A); IC5.2 — redraw continues to A IC31.9, A IC37.8, A IC55.13 | scan |
| 15 | A | GND | scan |

### IC16 — 7486 XOR (redraw 74LS86)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | Vcc | scan |
| 2 |  | IC4.7, IC16.12, IC23.3, IC27.1, IC72.11 | scan |
| 3 |  | /ACC1., arrow to (G) — redraw continues to G IC59.18, G IC59.19, G IC66.1, G IC95.5, G IC95.9 | scan |
| 4 |  | IC2.13, IC6.10, IC23.4 | scan |
| 5 |  | IC6.8 | scan |
| 6 |  | IC7.11, IC23.5 | scan |
| 8 |  | IC60.1 | scan |
| 9 |  | IC22.2, IC28.9, IC29.9, IC32.13 | scan |
| 10 |  | IC27.13 | scan |
| 11 |  | IC9.14, IC13.13, IC15.11, IC28.10 | scan |
| 12 |  | IC4.7, IC16.2, IC23.3, IC27.1, IC72.11 | scan |
| 13 |  | Vcc | scan |

### IC17 — 7485 4-bit comparator

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | B3 | Vcc | scan |
| 2 | Ia<b | Vcc | scan |
| 3 | Ia=b | IC18.6 | scan |
| 4 | Ia>b | Vcc | scan |
| 5 | Oa>b | open stub | scan: open stub |
| 6 | Oa=b | PL-H-ST., arrow to (G); C23 (drawn on sheet G) — redraw continues to G IC52.12, G IC52.2 | scan |
| 7 | Oa<b | open stub | scan: open stub |
| 9 | B0 | IC10.10, IC24.3, IC28.4 | scan |
| 10 | A0 | IC19.11 | scan; differs from redraw. IC19 pin as printed (F45) |
| 11 | B1 | IC10.12, IC24.2, IC28.3 | scan |
| 12 | A1 | IC19.10 | scan; differs from redraw. IC19 pin as printed (F45) |
| 13 | A2 | IC19.9 | scan; differs from redraw. IC19 pin as printed (F45) |
| 14 | B2 | IC10.13, IC24.6, IC28.5 | scan |
| 15 | A3 | Vcc | scan |

### IC18 — 7485 4-bit comparator

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | B3 | IC11.15, IC25.7 | scan |
| 2 | Ia<b | Vcc | scan |
| 3 | Ia=b | IC19.1, IC63.13 | scan; differs from redraw. IC19 pin as printed (F45) |
| 4 | Ia>b | Vcc | scan |
| 5 | Oa>b | open stub | scan: open stub |
| 6 | Oa=b | IC17.3 | scan |
| 7 | Oa<b | open stub | scan: open stub |
| 9 | B0 | IC11.10, IC25.3 | scan |
| 10 | A0 | IC19.3 | scan; differs from redraw. IC19 pin as printed (F45) |
| 11 | B1 | IC11.12, IC25.2 | scan |
| 12 | A1 | IC19.4 | scan; differs from redraw. IC19 pin as printed (F45) |
| 13 | A2 | IC19.5 | scan; differs from redraw. IC19 pin as printed (F45) |
| 14 | B2 | IC11.13, IC25.6 | scan |
| 15 | A3 | IC19.6, IC19.13 | scan; differs from redraw. IC19 pin as printed (F45) |

### IC19 — 74393 dual 4-bit counter, printed "393"

Pin numbers below are the printed ones: first half CP 1, CL 2, QA–QD 3, 4, 5, 6 (under IC18); second half CP 13, CL 12, QA–QD 11, 10, 9, 8 (under IC17). The redraw numbers the halves the other way round (F45).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | CP | IC18.3, IC63.13 | scan; differs from redraw. printed pin number; redraw numbers the halves the other way (F45) |
| 2 | MR | IC19.12, IC74.12; C3 470p to GND | scan |
| 3 | Q0 | IC18.10 | scan; differs from redraw. printed pin number; redraw numbers the halves the other way (F45) |
| 4 | Q1 | IC18.12 | scan; differs from redraw. printed pin number; redraw numbers the halves the other way (F45) |
| 5 | Q2 | IC18.13 | scan; differs from redraw. printed pin number; redraw numbers the halves the other way (F45) |
| 6 | Q3 | IC18.15, IC19.13 | scan; differs from redraw. printed pin number; redraw numbers the halves the other way (F45) |
| 8 | Q3 | IC63.11 | scan; differs from redraw. printed pin number; redraw numbers the halves the other way (F45) |
| 9 | Q2 | IC17.13 | scan; differs from redraw. printed pin number; redraw numbers the halves the other way (F45) |
| 10 | Q1 | IC17.12 | scan; differs from redraw. printed pin number; redraw numbers the halves the other way (F45) |
| 11 | Q0 | IC17.10 | scan; differs from redraw. printed pin number; redraw numbers the halves the other way (F45) |
| 12 | MR | IC19.2, IC74.12; C3 470p to GND | scan |
| 13 | CP | IC18.15, IC19.6 | scan; differs from redraw. printed pin number; redraw numbers the halves the other way (F45) |

### IC22 — 7408 AND

Only section 1,2→3 is drawn on this sheet.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC23.6, IC34.4 | scan |
| 2 |  | IC16.9, IC28.9, IC29.9, IC32.13 | scan |
| 3 |  | IC7.1 | scan |
| 8 |  | not drawn on sheet F | not drawn |
| 9 |  | not drawn on sheet F | not drawn |
| 10 |  | not drawn on sheet F | not drawn |

### IC23 — 7432 OR (redraw 74LS32)

Sections drawn in both OR and De Morgan (AND body, all bubbles) forms; all four are OR.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | EXPLO. ST., arrow to (G); IC33.5, IC69.2 — redraw continues to G IC62.10, G IC65.18, G IC65.19 | scan |
| 2 |  | IC23.13, IC27.7, IC33.3 | scan |
| 3 |  | IC4.7, IC16.2, IC16.12, IC27.1, IC72.11 | scan |
| 4 |  | IC2.13, IC6.10, IC16.4 | scan |
| 5 |  | IC7.11, IC16.6 | scan |
| 6 |  | IC22.1, IC34.4 | scan |
| 8 |  | /HOME POS., arrow to (G); IC27.5 — redraw continues to G IC51.5 | scan |
| 9 |  | IC30.2, IC46.2 | scan |
| 10 |  | IC9.2, IC44.2 | scan |
| 11 |  | IC33.1 | scan |
| 12 |  | IC34.9, IC68.6 | scan |
| 13 |  | IC23.2, IC27.7, IC33.3 | scan |

### IC24 — 74193 up/down counter

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | B | Vcc | scan |
| 2 | QB | IC10.12, IC17.11, IC28.3 | scan |
| 3 | QA | IC10.10, IC17.9, IC28.4 | scan |
| 4 | DOWN | IC25.13 | scan |
| 5 | UP | IC25.12 | scan |
| 6 | QC | IC10.13, IC17.14, IC28.5 | scan |
| 7 | QD | Vcc | scan. QD output drawn to Vcc (F44, confirmed by the maintainer) |
| 9 | D | Vcc | scan |
| 10 | C | Vcc | scan |
| 11 | /LOAD | /COIN & TEST, arrow from (A); IC25.11, IC28.11, IC35.11, IC36.11 — redraw continues to A IC73.4 | scan |
| 12 | /CO | open stub | scan: open stub |
| 13 | /BO | open stub | scan: open stub |
| 14 | CLR | GND | scan |
| 15 | A | Vcc | scan |

### IC25 — 74193 up/down counter

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | B | GND | scan |
| 2 | QB | IC11.12, IC18.11 | scan |
| 3 | QA | IC11.10, IC18.9 | scan |
| 4 | DOWN | IC12.6 | scan |
| 5 | UP | IC12.3 | scan |
| 6 | QC | IC11.13, IC18.14 | scan |
| 7 | QD | IC11.15, IC18.1 | scan |
| 9 | D | GND | scan |
| 10 | C | GND | scan |
| 11 | /LOAD | /COIN & TEST, arrow from (A); IC24.11, IC28.11, IC35.11, IC36.11 — redraw continues to A IC73.4 | scan |
| 12 | /CO | IC24.5 | scan |
| 13 | /BO | IC24.4 | scan |
| 14 | CLR | GND | scan |
| 15 | A | GND | scan |

### IC27 — 74279 quad /S-/R latch, printed "279/4"

Three latches on this sheet: /R 1, /S1 2, Q 4 (pin 3 not drawn); /R 5, /S 6, Q 7; and a third latch with no pin numbers printed (redraw pins 13, 14, 15).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /R | IC4.7, IC16.2, IC16.12, IC23.3, IC72.11 | scan |
| 2 | /S1 | IC28.6 | scan |
| 3 | /S2 | not drawn on sheet F | not drawn |
| 4 | Q | IC44.1 | scan |
| 5 | /R | /HOME POS., arrow to (G); IC23.8 — redraw continues to G IC51.5 | scan |
| 6 | /S | IC34.3 | scan |
| 7 | Q | IC23.2, IC23.13, IC33.3 | scan |
| 9 | Q | not drawn on sheet F | not drawn |
| 10 | /R | not drawn on sheet F | not drawn |
| 11 | /S1 | not drawn on sheet F | not drawn |
| 12 | /S2 | not drawn on sheet F | not drawn |
| 13 | Q | IC16.10 | scan |
| 14 | /R | IC44.12 | scan |
| 15 | /S | IC14.6 | scan |

### IC28 — 7410 triple 3-input NAND (redraw 74LS10)

Section 3,4,5→6 is an AND body with an output bubble (F32); 9,10,11→8 is an OR body with input bubbles.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | not drawn on sheet F | not drawn |
| 2 |  | not drawn on sheet F | not drawn |
| 3 |  | IC10.12, IC17.11, IC24.2 | scan |
| 4 |  | IC10.10, IC17.9, IC24.3 | scan |
| 5 |  | IC10.13, IC17.14, IC24.6 | scan |
| 6 |  | IC27.2 | scan |
| 8 |  | IC44.13 | scan |
| 9 |  | IC16.9, IC22.2, IC29.9, IC32.13 | scan |
| 10 |  | IC9.14, IC13.13, IC15.11, IC16.11 | scan |
| 11 |  | /COIN & TEST, arrow from (A); IC24.11, IC25.11, IC35.11, IC36.11 — redraw continues to A IC73.4 | scan |
| 12 |  | not drawn on sheet F | not drawn |
| 13 |  | not drawn on sheet F | not drawn |

### IC29 — 7417 buffer, printed "17"

Three sections on this sheet.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC2.3 | scan |
| 2 |  | pad A20, /NON ROAD & POOL SLIP (S) | scan |
| 3 |  | IC1.1, IC1.9, IC3.2, IC43.4 | scan |
| 4 |  | pad AX, /SLIPZONE (S) | scan |
| 8 |  | pad AW, SHIFT (S) | scan |
| 9 |  | IC16.9, IC22.2, IC28.9, IC32.13 | scan |

### IC30 — 7400 NAND

Four sections drawn on this sheet; the redraw places 1,2→3 and 9,10→8 on its sheet G page.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC9.9 | scan |
| 2 |  | IC23.9, IC46.2 | scan |
| 3 |  | IC36.4 | scan |
| 8 |  | IC36.5 | scan |
| 9 |  | IC9.7 | scan |
| 10 |  | IC30.11 | scan |
| 11 |  | IC30.10 | scan |
| 12 |  | IC35.7, IC41.15, IC47.1 | scan |
| 13 |  | IC35.6, IC41.13, IC47.2 | scan |

### IC32 — 74279 latch 4, printed "279/4"

Q numeral reads like "3"; pin 13 by the 74279 pinout. /R 14 and /S 15 are fed from the shift lever through RA2 100Ω, with C10 and C7 0.1µF to GND.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 13 | Q | IC16.9, IC22.2, IC28.9, IC29.9 | scan |
| 14 | /R | C10 0.1µ to GND, RA2 100Ω | scan |
| 15 | /S | C7 0.1µ to GND, RA2 100Ω | scan |

### IC33 — 7474 D flip-flop, printed "74/2" (first half)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /CLR | IC23.11 | scan |
| 2 | D | EXTEND, arrow from (A) — redraw continues to A IC38.10, A IC50.9 | scan |
| 3 | CK | IC23.2, IC23.13, IC27.7 | scan |
| 4 | /PR | Vcc | scan; differs from redraw. /PR drawn tied to Vcc (F43); redraw leaves it open |
| 5 | Q | EXPLO. ST., arrow to (G); IC23.1, IC69.2 — redraw continues to G IC62.10, G IC65.18, G IC65.19 | scan |
| 6 | /Q | /EXPLO. ST., arrow to (G); IC39.2 — redraw continues to G IC68.1, G IC74.3, G IC84.18, G IC84.19, G IC91.18, G IC91.19, G IC98.18, G IC98.19 | scan |

### IC34 — 7408 AND

Section 1,2→3 is drawn as an OR body with bubbles on inputs and output (AND).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC80.6 | scan |
| 2 |  | /ACC1. PULSE, arrow from (G) — redraw continues to G IC45.6 | scan |
| 3 |  | IC27.6 | scan |
| 4 |  | IC22.1, IC23.6 | scan |
| 5 |  | IC12.4, IC60.7 | scan |
| 6 |  | ACCE. ST., arrow to (A) — redraw continues to A IC37.11 | scan |
| 8 |  | IC39.1; C16 330p to GND | scan |
| 9 |  | IC23.12, IC68.6 | scan |
| 10 |  | Vs/8, arrow from (H); IC8.1, IC60.6 — redraw continues to G IC84.23, G IC91.23, G IC98.23, H IC79.9 | scan |

### IC35 — 74193 up/down counter

The lowest right-hand pin reads "12" a second time; by pinout it is 13 (/BO), an open stub.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | B | GND | scan |
| 2 | QB | IC41.12, IC47.4 | scan |
| 3 | QA | IC41.10, IC47.5 | scan |
| 4 | DOWN | IC36.13 | scan |
| 5 | UP | IC36.12 | scan |
| 6 | QC | IC30.13, IC41.13, IC47.2 | scan |
| 7 | QD | IC30.12, IC41.15, IC47.1 | scan |
| 9 | D | GND | scan |
| 10 | C | GND | scan |
| 11 | /LOAD | /COIN & TEST, arrow from (A); IC24.11, IC25.11, IC28.11, IC36.11 — redraw continues to A IC73.4 | scan |
| 12 | /CO | open stub | scan: open stub |
| 13 | /BO | open stub | scan: open stub |
| 14 | CLR | GND | scan |
| 15 | A | GND | scan |

### IC36 — 74193 up/down counter

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | B | Vcc | scan |
| 2 | QB | IC42.12 | scan |
| 3 | QA | IC42.10 | scan |
| 4 | DOWN | IC30.3 | scan |
| 5 | UP | IC30.8 | scan |
| 6 | QC | IC42.13 | scan |
| 7 | QD | IC42.15 | scan |
| 9 | D | Vcc | scan |
| 10 | C | Vcc | scan |
| 11 | /LOAD | /COIN & TEST, arrow from (A); IC24.11, IC25.11, IC28.11, IC35.11 — redraw continues to A IC73.4 | scan |
| 12 | /CO | IC35.5 | scan |
| 13 | /BO | IC35.4 | scan |
| 14 | CLR | GND | scan |
| 15 | A | Vcc | scan |

### IC39 — 74393, printed "393/2" (first half)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | CP | IC34.8; C16 330p to GND | scan |
| 2 | MR | /EXPLO. ST., arrow to (G); IC33.6 — redraw continues to G IC68.1, G IC74.3, G IC84.18, G IC84.19, G IC91.18, G IC91.19, G IC98.18, G IC98.19 | scan |
| 3 | Q0 | EXPLO. SEL. A, arrow to (G) — redraw continues to G IC63.9, G IC65.1 | scan |
| 4 | Q1 | EXPLO. SEL. B, arrow to (G) — redraw continues to G IC65.23 | scan |
| 5 | Q2 | EXPLO. SEL. C, arrow to (G); IC68.4 — redraw continues to G IC63.8 | scan |
| 6 | Q3 | pad BM, EXPLO. SEL. D (M); also arrow (G); IC68.5, IC69.14 — redraw continues to G IC74.4 | scan |

### IC40 — 74393 dual 4-bit counter, printed "393"

Numbered the same way in the redraw and on the scan.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | CP | pad CJ, /HS (E); also arrow to (H) — redraw continues to G IC63.5, H IC86.11 | scan |
| 2 | MR | IC40.12, IC47.8; C17 470p to GND | scan |
| 3 | Q0 | IC42.9 | scan |
| 4 | Q1 | IC42.11 | scan |
| 5 | Q2 | IC42.14 | scan |
| 6 | Q3 | IC40.13, IC42.1 | scan |
| 8 | Q3 | IC41.1 | scan |
| 9 | Q2 | IC41.14 | scan |
| 10 | Q1 | IC41.11 | scan |
| 11 | Q0 | IC41.9 | scan |
| 12 | MR | IC40.2, IC47.8; C17 470p to GND | scan |
| 13 | CP | IC40.6, IC42.1 | scan |

### IC41 — 7485 4-bit comparator

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | B3 | IC40.8 | scan |
| 2 | Ia<b | Vcc | scan |
| 3 | Ia=b | IC42.6 | scan |
| 4 | Ia>b | Vcc | scan |
| 5 | Oa>b | open stub | scan: open stub |
| 6 | Oa=b | PL-V-ST., arrow to (G); C40 (drawn on sheet G) — redraw continues to G IC54.12, G IC54.2 | scan |
| 7 | Oa<b | open stub | scan: open stub |
| 9 | B0 | IC40.11 | scan |
| 10 | A0 | IC35.3, IC47.5 | scan |
| 11 | B1 | IC40.10 | scan |
| 12 | A1 | IC35.2, IC47.4 | scan |
| 13 | A2 | IC30.13, IC35.6, IC47.2 | scan |
| 14 | B2 | IC40.9 | scan |
| 15 | A3 | IC30.12, IC35.7, IC47.1 | scan |

### IC42 — 7485 4-bit comparator

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | B3 | IC40.6, IC40.13 | scan |
| 2 | Ia<b | Vcc | scan |
| 3 | Ia=b | Vcc | scan |
| 4 | Ia>b | Vcc | scan |
| 5 | Oa>b | open stub | scan: open stub |
| 6 | Oa=b | IC41.3 | scan |
| 7 | Oa<b | open stub | scan: open stub |
| 9 | B0 | IC40.3 | scan |
| 10 | A0 | IC36.3 | scan |
| 11 | B1 | IC40.4 | scan |
| 12 | A1 | IC36.2 | scan |
| 13 | A2 | IC36.6 | scan |
| 14 | B2 | IC40.5 | scan |
| 15 | A3 | IC36.7 | scan |

### IC43 — 74123 dual one-shot, printed "123/2" twice

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | A | pad CA, /SLIP (D) | scan |
| 2 | B | PLAYER, arrow from (G); IC43.10, IC49.10, IC80.5 — redraw continues to G IC44.10 | scan |
| 3 | /CLR | IC6.1, IC7.15, IC15.7, IC43.11, IC49.11 | scan |
| 4 | /Q | IC1.1, IC1.9, IC3.2, IC29.3 | scan |
| 5 | Q | IC48.9, IC61.2 | scan |
| 6 | Cext | C18 15µ | scan |
| 7 | RCext | C18 15µ, R10 47K to Vcc | scan |
| 9 | A | pad CM, /POOL(2) (D); IC49.9 | scan |
| 10 | B | PLAYER, arrow from (G); IC43.2, IC49.10, IC80.5 — redraw continues to G IC44.10 | scan |
| 11 | /CLR | IC6.1, IC7.15, IC15.7, IC43.3, IC49.11 | scan |
| 12 | /Q | IC2.1, IC3.14 | scan |
| 13 | Q | IC61.3 | scan |
| 14 | Cext | C20 10µ | scan |
| 15 | RCext | C20 10µ, R11 47K to Vcc | scan |

### IC44 — 7404 inverter

Two sections on this sheet.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC27.4 | scan |
| 2 |  | IC9.2, IC23.10 | scan |
| 12 |  | IC27.14 | scan |
| 13 |  | IC28.8 | scan |

### IC46 — 7404 inverter

One section on this sheet.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC47.6 | scan |
| 2 |  | IC23.9, IC30.2 | scan |

### IC47 — dual 4-input NOR (7425-type); redraw 74LS20

Both sections drawn as AND bodies with a bubble on every input and no output bubble, which is NOR. Output pin numbers are not printed.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC30.12, IC35.7, IC41.15 | scan |
| 2 |  | IC30.13, IC35.6, IC41.13 | scan |
| 4 |  | IC35.2, IC41.12 | scan |
| 5 |  | IC35.3, IC41.10 | scan |
| 6 |  | IC46.1 | scan |
| 8 |  | IC40.2, IC40.12; C17 470p to GND | scan |
| 9 |  | pad BU, /V5 (E); IC69.3, IC69.13 | scan |
| 10 |  | pad B17, /V6 (E); IC2.4, IC2.10, IC69.10, IC69.11 | scan |
| 12 |  | pad BT, V4 (E) | scan |
| 13 |  | pad B18, /V7 (E) | scan |

### IC48 — 7400 NAND

One section on this sheet.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 8 |  | /SPLAY A, arrow to (G) — redraw continues to G IC71.1 | scan |
| 9 |  | IC43.5, IC61.2 | scan |
| 10 |  | /SPLAY B, arrow to (G); IC49.5 — redraw continues to G IC45.11 | scan |

### IC49 — 74123 one-shot (second half)

No pin numbers printed; pins below follow the redraw's assignment, which agrees with the drawn A/B/CL/Q labels.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 5 | Q | /SPLAY B, arrow to (G); IC48.10 — redraw continues to G IC45.11 | scan |
| 6 | Cext | C21 22µ | scan |
| 7 | RCext | C21 22µ, 47K to Vcc (R12 in the redraw; number not read) | scan |
| 9 | A | pad CM, /POOL(2) (D); IC43.9 | scan |
| 10 | B | PLAYER, arrow from (G); IC43.2, IC43.10, IC80.5 — redraw continues to G IC44.10 | scan |
| 11 | /CLR | IC6.1, IC7.15, IC15.7, IC43.3, IC43.11 | scan |
| 12 | /Q | not drawn on sheet F | not drawn |

### IC60 — 74157 quad 2-to-1 mux, printed "157"

Channels a and b drawn; c and d not drawn.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | S | IC16.8 | scan |
| 2 | I0a | Vs/16, arrow from (H) — redraw continues to A IC12.10, A IC29.5, A IC85.1, G IC73.11, G IC95.4, H IC78.1, H IC79.8 | scan |
| 3 | I1a | Vs/64, arrow from (H) — redraw continues to H IC78.4 | scan |
| 4 | Za | IC8.4 | scan |
| 5 | I0b | Vs/2, arrow from (H) — redraw continues to H IC107.11, H IC30.5, H IC79.11 | scan |
| 6 | I1b | Vs/8, arrow from (H); IC8.1, IC34.10 — redraw continues to G IC84.23, G IC91.23, G IC98.23, H IC79.9 | scan |
| 7 | Zb | IC12.4, IC34.5 | scan |
| 9 | Zc | not drawn on sheet F | not drawn |
| 10 | I1c | not drawn on sheet F | not drawn |
| 11 | I0c | not drawn on sheet F | not drawn |
| 12 | Zd | not drawn on sheet F | not drawn |
| 13 | I1d | not drawn on sheet F | not drawn |
| 14 | I0d | not drawn on sheet F | not drawn |
| 15 | E | GND | scan |

### IC61 — 7402 NOR

Drawn pointing up: OR body with an output bubble.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC8.12 | scan |
| 2 |  | IC43.5, IC48.9 | scan |
| 3 |  | IC43.13 | scan |

### IC62 — 7432 OR

Drawn pointing down, OR body.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | 8000, arrow from (A) — redraw continues to A IC79.6 | scan |
| 2 |  | pad BJ, /EXT. 500 (D); also arrow /EXT. 500 to (H) — redraw continues to H IC106.4 | scan |
| 3 |  | IC80.2 | scan |

### IC63 — 7402 NOR (redraw 74LS02; sheet G uses it as NOR)

Section 11,12→13 is drawn with a pointed (OR-like) body and bubbles on both inputs, which would read as NAND. It is taken as NOR: see U1 (closed).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 11 |  | IC19.8 | scan. IC19.8 as printed (F45) |
| 12 |  | 7MHz, pad C13 from (E); also arrows to (G) and (H) — redraw continues to G IC63.3, H IC101.2, H IC102.2 | scan |
| 13 |  | IC18.3, IC19.1 | scan. IC19.1 as printed (F45) |

### IC66 — 7408 AND

One section on this sheet.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 8 |  | IC3.12, IC9.12 | scan |
| 9 |  | IC9.10, IC69.9, IC72.5 | scan |
| 10 |  | Vs/32, arrow from (H); IC72.6; C38 in the redraw (not drawn on sheet F) — redraw continues to G IC39.13, H IC78.3 | scan |

### IC67 — 7450 dual 2-wide 2-input AOI, printed "50/2" twice

Expander pins 11, 12 not drawn.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | 1A | pad B12, V6 (E); IC67.2 | scan |
| 2 | 2A | pad B12, V6 (E); IC67.1 | scan |
| 3 | 2B | IC8.11, IC73.5 | scan |
| 4 | 2C | pad BN, V7 (E); IC67.9 | scan |
| 5 | 2D | IC73.6 | scan |
| 6 | 2Y | IC5.1 | scan |
| 8 | 1Y | IC69.5, IC69.6 | scan |
| 9 | 1C | pad BN, V7 (E); IC67.4 | scan |
| 10 | 1D | IC72.13, IC73.9 | scan |
| 11 | 1X | not drawn on sheet F | not drawn |
| 12 | 1/X | not drawn on sheet F | not drawn |
| 13 | 1B | IC73.8 | scan |

### IC68 — 7400 NAND

Section 12,13→11 is an AND body with output bubble.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 4 |  | EXPLO. SEL. C, arrow to (G); IC39.5 — redraw continues to G IC63.8 | scan |
| 5 |  | pad BM, EXPLO. SEL. D (M); also arrow (G); IC39.6, IC69.14 — redraw continues to G IC74.4 | scan |
| 6 |  | IC23.12, IC34.9 | scan |
| 11 |  | IC74.2 | scan |
| 12 |  | pad C8, H4 (E) | scan; differs from redraw. redraw swaps pins 12 and 13; same function |
| 13 |  | pad CH, H6 (E) | scan; differs from redraw. redraw swaps pins 12 and 13; same function |

### IC69 — 74153 dual 4-to-1 mux, printed "153"

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | Ea | GND | scan |
| 2 | S1 | EXPLO. ST., arrow to (G); IC23.1, IC33.5 — redraw continues to G IC62.10, G IC65.18, G IC65.19 | scan |
| 3 | I3a | pad BU, /V5 (E); IC47.9, IC69.13 | scan |
| 4 | I2a | GND | scan |
| 5 | I1a | IC67.8, IC69.6 | scan |
| 6 | I0a | IC67.8, IC69.5 | scan |
| 7 | Za | IC12.1 | scan |
| 9 | Zb | IC9.10, IC66.9, IC72.5 | scan |
| 10 | I0b | pad B17, /V6 (E); IC2.4, IC2.10, IC47.10, IC69.11 | scan |
| 11 | I1b | pad B17, /V6 (E); IC2.4, IC2.10, IC47.10, IC69.10 | scan |
| 12 | I2b | GND | scan |
| 13 | I3b | pad BU, /V5 (E); IC47.9, IC69.3 | scan |
| 14 | S0 | pad BM, EXPLO. SEL. D (M); also arrow (G); IC39.6, IC68.5 — redraw continues to G IC74.4 | scan |
| 15 | Eb | GND | scan |

### IC72 — 7402 NOR, designator confirmed by the maintainer (F11)

Section 11,12→13 drawn OR body with output bubble; 5,6→4 drawn AND body with input bubbles (F19).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 4 |  | IC3.4, IC9.4 | scan |
| 5 |  | IC9.10, IC66.9, IC69.9 | scan; differs from redraw. redraw swaps pins 5 and 6; same function |
| 6 |  | Vs/32, arrow from (H); IC66.10; C38 in the redraw (not drawn on sheet F) — redraw continues to G IC39.13, H IC78.3 | scan; differs from redraw. redraw swaps pins 5 and 6; same function |
| 11 |  | IC4.7, IC16.2, IC16.12, IC23.3, IC27.1 | scan |
| 12 |  | SP. DOWN, arrow from (G) (top edge) — redraw continues to G IC119.5, G IC72.2 | scan |
| 13 |  | IC67.10, IC73.9 | scan |

### IC73 — 7404 inverter

Two sections on this sheet.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 5 |  | IC8.11, IC67.3 | scan |
| 6 |  | IC67.5 | scan |
| 8 |  | IC67.13 | scan |
| 9 |  | IC67.10, IC72.13 | scan |

### IC74 — 7427 triple 3-input NOR

AND body with bubbles on all three inputs, no output bubble; pin numbers not printed (pins below are the redraw's).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | pad C7, H5 (E) | scan |
| 2 |  | IC68.11 | scan |
| 12 |  | IC19.2, IC19.12; C3 470p to GND | scan |
| 13 |  | pad CF, H8 (E) | scan |

### IC80 — 7410 triple 3-input NAND

Section 3,4,5→6 (pins printed) and a second section driving /SP. IRREG.; only its output number 12 is printed, so its input pins 1, 2, 13 are the redraw's numbering.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC4.9, IC6.2, IC6.13, IC10.14, IC14.5 | scan |
| 2 |  | IC62.3 | scan |
| 3 |  | /ACC1. ST, arrow from (G) — redraw continues to G IC119.11, G IC51.7, G IC62.4 | scan |
| 4 |  | IC14.8 | scan |
| 5 |  | PLAYER, arrow from (G); IC43.2, IC43.10, IC49.10 — redraw continues to G IC44.10 | scan |
| 6 |  | IC34.1 | scan |
| 12 |  | /SP. IRREG., arrow to (H) — redraw continues to H IC106.12 | scan |
| 13 |  | pad BZ, EXT. CAR CONT. (M) | scan |

## Resistors, capacitors and other parts

| Ref | Value as read | Connected to | Note |
|---|---|---|---|
| C1, R2 | 4.7µ, 47K to Vcc | IC1 pins 6, 7 | |
| C2, R3 | 4.7µ, 47K to Vcc | IC1 pins 14, 15 | |
| C20, R11 | 10µ, 47K to Vcc | IC43 pins 14, 15 (the /SLIP half) | |
| C18, R10 | 15µ, 47K to Vcc | IC43 pins 6, 7 (the /POOL(2) half) | The old log doubted 15µ against 1.5µ; the scan reads 15µ and the redraw agrees. |
| C21 and a 47K | 22µ, 47K to Vcc | IC49 pins 6, 7 | The resistor's number is not readable (the redraw calls it R12). |
| C3 | 470p to GND | IC19 MR (pins 2, 12) and IC74 output | |
| C17 | 470p to GND | IC40 MR (pins 2, 12) and IC47 output 8 | |
| C16 | **330p** to GND | IC34.8 and IC39.1 (CP) | The redraw has 470p. The maintainer read the last glyph as "p" (F42). |
| RA1 | 560Ω ×2 (inferred, see U4), pull-ups to Vcc | the shift lever's NO and NC lines | |
| RA2 | 100Ω ×2 | in series from the shift lever lines to IC32.14 and IC32.15 | |
| C10, C7 | 0.1µF ×2 to GND | IC32.14 (/R), IC32.15 (/S) | |
| C23, C40 | — | PL-H-ST. and PL-V-ST. | Drawn on sheet G, not here. |
| C38 | — | Vs/32 line in the redraw | Not drawn on sheet F. |

The handle unit's pads A8 and AJ go straight to the logic; no series
resistor or capacitor is drawn on them. The old log listed a second
"100Ω×2" group there; the scan does not show one.

## Block description (wiring-derived)

This section reads the function from the wiring in the tables above. It has
not been simulated and should not be taken as verified behaviour.

- **Accelerator.** The pedal unit returns two lines, ACCE. CONT. A and B
  (pads A11, AM). They pass through Schmitt inverters IC6 9→8 and 11→10, and
  IC16 4,5→6 (XOR) combines them. IC15 (74193) holds a 4-bit value whose
  outputs are ACCE. A–D (QA–QD; D through two IC6 inverters). IC7 compares
  (QD, QC, QB, Vcc) with (IC22.3, IC2.11, IC16.6, Vcc). IC8 4,5→6 steps IC15
  up when A<B, gated by IC60's selected timing line. IC8 1,2→3 steps it down
  when A>B, gated by Vs/8. IC60 chooses between Vs/16 and Vs/64 (channel a)
  and between Vs/2 and Vs/8 (channel b); its select is IC16 9,10→8. IC15
  loads zero on its /LOAD net and clears while /GAME is high. ACCE. A–D go
  to (H); IC13 (17×6) buffers them to pads S-ACCE A–D for (S). IC34 4,5→6
  forms ACCE. ST. for (A).
- **Gear shift.** IC32, a 74279 latch fed through RA2 and debounced by C10
  and C7, latches the lever position. Q (IC32.13) feeds IC16.9, IC22.2 and
  IC28.9, and IC29 9→8 buffers it to pad AW, SHIFT (S).
- **Slip and pool.** IC43 is two one-shots triggered by /SLIP (pad CA) and
  /POOL(2) (pad CM), with PLAYER on the B inputs. Their /Q outputs select
  IC3's input (S1 and S0), and IC29 buffers the /SLIP half to pad AX,
  /SLIPZONE (S). IC2 1,2→3 combines the /POOL(2) half's /Q with /SP DOWN;
  IC29 1→2 buffers the result to pad A20, /NON ROAD & POOL SLIP (S). IC49 is
  a third one-shot on /POOL(2) whose Q is /SPLAY B. IC48 9,10→8, a NAND of
  that Q and the /POOL(2) half's Q, gives /SPLAY A. IC61 NORs the two IC43
  Q outputs.
- **Handle position.** The handle's left and right pulses (pads A8, AJ) go
  directly to IC3's I3 inputs and to the IC1 one-shots; IC1's Q outputs,
  gated with /V6 in IC2, are IC3's I1 inputs. IC3 and IC9 (74153) choose the pulse
  source. IC30's NAND pairs then step the IC36/IC35 up/down counter pair.
  IC41/IC42 compare that 8-bit value with IC40, a counter clocked by /HS and
  cleared by IC47 9,10,12,13→8 (a NOR of V4, /V5, /V6, /V7) with C17. Equality gives PL-V-ST. for (G). IC47's
  other section, through IC46, detects IC35 = 0 and feeds /HOME POS.
  (IC23 9,10→8) and the IC30 gates.
- **Second position counter.** IC24/IC25 (74193 pair) are stepped by IC12,
  which gates IC69 and IC60 outputs with IC10/IC11's comparison of IC24/IC25
  (IC24 against the inverted accelerator bits, IC25 against zero). IC17/IC18 compare IC24/IC25 with IC19, a
  counter clocked from 7MHz through IC63, a NOR that stops the count once
  IC19.8 goes high (see U1). Equality gives PL-H-ST.
  for (G). Both counter pairs load on /COIN & TEST.
- **Collision and explosion.** IC14 9,10,12,13→8 is a NAND of /RESCUE,
  /BRIDGE, ROAD and /OTHER BODY. IC80 3,4,5→6 combines it with /ACC1. ST and
  PLAYER. IC34 1,2→3 combines that with /ACC1. PULSE and drives /S of latch
  IC27 (/S 6, Q 7), which /HOME POS. resets. IC27.7 clocks IC33 (D = EXTEND), whose Q and /Q
  are EXPLO. ST. and /EXPLO. ST. IC39 counts IC34's 9,10→8 output while
  /EXPLO. ST. is low and gives EXPLO. SEL. A–D. IC23 1,2→3 ORs EXPLO. ST.
  with IC27.7. That net enables IC4, resets IC27's first latch (/R 1) and
  feeds IC72.11. IC16 1,2→3 (XOR with Vcc) inverts it to /ACC1. for (G),
  and IC16 12,13→11 inverts it again for the IC15/IC9 /LOAD net.
- **Score clock.** IC67 is a 7450 AND-OR-invert. Its section 2 selects V6
  or V7 (pads B12, BN), inverted, by IC8 12,13→11 (/TUNNEL with IC61) and
  clocks IC5 (74393). Its section 1 makes the same choice by IC72 11,12→13
  (SP. DOWN with the IC23.3 net) and feeds IC69's data inputs. IC4 (74151) picks one IC5 output using the
  inverted accelerator bits. IC8 9,10→8 gates the result with /SCORE ST.,
  and IC13 11→10 buffers it to pad A14, /SCORE CP. (I).
- **Extended play.** IC62 ORs 8000 (A) and /EXT. 500 (pad BJ). IC80's
  second section combines it with EXT. CAR CONT. (pad BZ) and the inverted
  accelerator D bit, giving /SP. IRREG. for (H).

## Differences from the redraw

The tables follow the scan in every case below.

| Item | Scan | Redraw |
|---|---|---|
| IC19 pin numbers (F45) | First half CP 1, MR 2, Q 3–6 under IC18; second half CP 13, MR 12, Q 11–8 under IC17 | The halves numbered the other way (printed pin = 14 − redraw pin). Affects the IC17, IC18, IC19 and IC63 rows. |
| IC7.10 (A0) | Tied to Vcc | ACCE. A |
| IC33.4 (/PR) | Tied to Vcc (F43) | Not connected |
| IC68 12, 13 | 12 ← H4 (pad C8), 13 ← H6 (pad CH) | Swapped; same function |
| IC72 5, 6 | 5 ← IC69.9 net, 6 ← Vs/32 | Swapped; same function |
| C16 | 330p (F42) | 470p |
| IC47 | NOR (AND body, all inputs bubbled), 7425-type | 74LS20 (NAND) |
| IC13 | Printed "17×6" (7417) | 74LS07 |
| IC6 | Drawn with a hysteresis mark (7414-type) | 74LS04 |
| IC63 section 11,12→13 | Drawn shape reads as NAND; taken as NOR (U1, closed) | 74LS02 (NOR); same function |
| RA1 shift-lever pull-ups | Drawn | Absent |
| IC30 1,2→3 and 9,10→8 | Drawn on sheet F | Placed on the redraw's sheet G page |

## Unresolved

1. **U1 — IC63 drawn form: closed 26 October 2026, NOR.** Section
   11,12→13 has a pointed, OR-like body with bubbles on both inputs, which
   would read as NAND. Box R(3930,4280,4110,4440), stored
   (6066,2184,6246,2344). It is taken as NOR for two reasons:
   - **Function.** IC74 resets both halves of IC19 to zero, so IC19.8 starts
     low. As a NAND the gate's output would stay high while IC19.8 is low;
     IC19 could never leave zero and PL-H-ST. would never move. As a NOR it
     passes inverted 7MHz until IC19.8 goes high, then stops the count.
     That is a working start-position counter.
   - **Board photo.** On the 97091-P CPU board photographed in
     stonedDiscord/MonacoGP (`Pictures/CPU Board (Parts Side).JPG`, about
     (1640,850,1760,1010) in the 3264 × 2448 image), the package beside the
     IC63 silkscreen is marked SN7402N, a quad NOR. The next package down,
     at IC62, is a 7432, which agrees with sheet F's IC62 OR. This is a later
     board revision, so it supports the reading but does not prove the
     96577-P wiring.

   The drawn body is therefore a drafting slip, probably an AND body drawn
   with a pointed end.
2. **U2 — IC24.7 drawn to Vcc: closed 26 October 2026, no effect on
   behaviour.** QD is an output, and the drawing ties it to Vcc (F44,
   confirmed by the maintainer as drawn). The wiring shows the designers treat this
   bit as a constant 1:
   - IC24 loads 1111 on /COIN & TEST, so QD starts at 1.
   - Every comparator that would read QD uses Vcc instead: IC10.15 (A3) and
     IC17.1 (B3).
   - IC12 steps the 8-bit IC24/IC25 count one at a time toward the target
     IC10/IC11 set, and stops at equality. That target is
     {1, /ACCE. D, /ACCE. C, /ACCE. B, 0000}, so it is always between 128
     and 240.

   The count therefore never drops below 128, and QD stays 1 whether or not
   the board ties it to Vcc. The only exception is a random count at power-up
   before the first /COIN & TEST load. An implementation can treat IC24 QD
   as constant 1. The board photo was not used: the solder-side view of
   IC24 is too far out of register with the parts side to follow pin 7
   reliably.
3. **U3 — IC35 duplicate "12": closed 26 October 2026.** The lowest
   right-hand pin is labelled "12" a second time. The 74193 pinout makes it
   13 (/BO), and pin 12 (/CO) is already printed above it. Both are open
   stubs, so the slip has no effect.
4. **U4 — Shift-lever labels: closed 26 October 2026 by inference.** The
   scan glyphs cannot be read alone; the maintainer read them as "AR5? A2.5? A5?" and
   "S60 N2?". Both are inferred from context:
   - **RA1 = 560Ω.** RA1 is a resistor pack on this board. Sheet A draws
     the same RA1 as a 560Ω pull-up, with RA2 100Ω in series, in the same
     input filter used here. The maintainer's "S60" reads as 560, and the drawing
     shows two pull-ups, so the label is most likely "560Ω×2". The later
     97091-P redraw also has RA1 = 560Ω pulling up both shift-lever lines.
   - **NO pad = A25.** Sheet A uses pads A23, A24 and A26–A32 but not A25,
     so A25 is free on this board. In the later redraw, the NO line (to
     IC32.14 through the 100Ω pack) is pad A25 and the NC line is pad "Ac",
     matching this sheet's AC. "A2.5" is A25 with a stray mark.
5. **U5 — V6 and V7 on two pads: closed 26 October 2026, /V6 and /V7.**
   Sheet E sends six V lines to sheet F: V4 (pad E21), /V5 (EY), V6 (E12),
   /V6 (E22), V7 (EN) and /V7 (EZ). See
   [SHEET_E_TRACE.md](SHEET_E_TRACE.md). Sheet F receives V6 and V7 on
   pads B12 and BN (IC67). The four braced pads carry V4, /V5 and the two
   lines labelled "V6" and "V7". On the scan, at R(1830,4800,2120,5060), a
   line runs directly above each of those two labels, like the overbar on
   "/V5" (F21); the "V4" label has none. The only remaining sheet E outputs
   to (F) are /V6 and /V7, so pads B17 and B18 are /V6 and /V7. This
   changes the B17 and B18 rows: IC47.10 and .13, IC2.4 and .10, and
   IC69.10 and .11. IC47's NOR now fires when V4 = 0, V5 = 1, V6 = 1 and
   V7 = 1. The rack backplane wiring between the E and B pad rows is not
   drawn on either sheet.
6. **U6 — /TUNNEL second arrow.** The arrow leaving the pad BF net reads
   (J) on this scan; the old log read (H). The redraw continues the net to
   sheet G IC57.13. Check on sheets G, H and J.
7. **U7 — Stub on the BJ column.** A short stub with a blob at about
   R(7560,1345) sits on the /EXT. 500 column. It does not reach a pin.
8. **U8 — ACCE. and S-ACCE. versus sheet B.** Sheet B receives speed bits
   SP.A–D from sheet F. Which of the (H)-bound ACCE. arrows and (S)-bound
   S-ACCE. pads these are is a cross-sheet question for the sheet B, H and S
   checks.
9. **U9 — IC3 select note.** A handwritten cloud by IC3's select pins reads
   roughly "A B / GRAVEL SLIP 1 0 / POOL 0 1 / NORMAL 1 1" (uncertain).
   Box R(3100,3260,3480,3460).
10. **U10 — Bottom-edge legend.** Reads roughly "0 1 (Japanese) / 1 1
    NORMAL / 0 0 START POS.(…)に SET / 1 0 NORMAL … ACCE '0'" (uncertain).
    Box R(3450,5880,5000,6200).
11. **U11 — Accelerator phase table.** A handwritten table left of the
    accelerator unit, about R(1300,1330,1650,1530), reads roughly "1 0 0 1
    / AC 1 1 0 0 / ↓ 0 1 1 0 / BC 0 0 1 1" (uncertain; probably the A/B
    phase sequence).

## Closed items from the working log

- **F40, F41.** Both B points on the IC72.11 vertical measure 11.7–12.8 px,
  which is a plain crossing. Closed as not joined.
- **F42, F43, F44, F45.** Closed by the maintainer; carried into the tables (C16 330p,
  IC33.4 Vcc, IC24.7 as drawn, IC19 numbering).
- **Old U1–U18.** Resolved by the pin tables:
  - U1: /SP DOWN (left edge) → IC2.2, IC2.12; SP. DOWN (top edge) → IC72.12.
  - U2: pad CM is /POOL(2); C18 is 15µ.
  - U3: handle pads A8, AH (Vcc), A7 (GND), AJ.
  - U4: sheet E pads C7 H5, C8 H4, CF H8, CH H6, CJ /HS, C13 7MHz; the
    "74" composite is IC74, a NOR; the two west arrows re-export 7MHz to
    (G)(H) and /HS to (H).
  - U5: V4 BT, /V5 BU, /V6 B17, /V7 B18 (polarity of the last two corrected 26 October 2026, new U5).
  - U7: pad A20 is /NON ROAD & POOL SLIP (S).
  - U8: /RESCUE (Y) pad B8, /BRIDGE (W) pad BH, ROAD pad B7, /OTHER BODY
    arrow from (H).
  - U9: SHIFT goes to (S).
  - U10: 8000 (A), /EXT. 500 pad BJ, EXT. CAR CONT. pad BZ, IC62 and IC80.
  - U12: carried forward as the new U8.
  - U14–U17: the IC14, IC80, IC34, IC27, IC33 and IC23 rows.
  - U18: carried forward as the new U10.
- **Old U19–U43.** Every block they name now has a full pin table, and
  every row was followed on the scan.

## History

- 23–25 October 2026: Codex, with the maintainer's crossing decisions F1–F45,
  transcribed the sheet in 15 passes. The full log is
  the working notes (not published).
- 25 October 2026: The maintainer set the policy to treat the KiCad redraw as reliable
  unless the scan clearly contradicts it (commit b8e8725).
- 25–26 October 2026: Claude checked every pin on the scan and wrote this
  consolidated trace.
