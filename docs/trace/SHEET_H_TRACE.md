# Sheet H — other cars, frame counter, PR-132, PR-38 and PR-39

Source: Sega **Monaco GP (420-0358)**, PDF page **28**, drawing **H**, board
**96577-P**, sheet **D-4/4**, "IC BOARD ASS'Y, A" (Japanese caption:
OTHER CAR の絵出しとコントロール, drawing and control of the other cars).
Image: `schematics/pages/page28-sheet-H.png`, **10176 × 6624** pixels,
SHA-256 `d7e7528cc95c330d6adf8c1de0fa6d40d3cb55b641634e12f97a10949490c239`.

**Status: complete pin-level trace, every row checked on the scan
(26 October 2026).** This file replaces the partial transcription of 23
October, which is kept unchanged in
[`work/SHEET_H_LOG.md`](work/SHEET_H_LOG.md). That file inventoried the
position counters and the AREA logic without pin tables; they are traced
here.

## How this trace was made

1. On 23 October a first pass (PR #1, corrected by Codex in PR #2) traced
   the frame counter, the PR-132 output path, the PR-38 speed PROM and the
   off-sheet labels at pin level, and compared them with stonedDiscord's
   KiCad redraw of board 96577.
2. On 26 October Claude took every pin the redraw places on this sheet and
   followed it on the scan, wire by wire, to both ends:
   - 557 rows were checked: 491 confirmed, 17 that differ from the redraw,
     21 not drawn on this sheet, and 28 drawn as open stubs.
   - Doubtful crossings were measured: junction dots measure 16 px or more;
     plain crossings measure 8–15 px, and up to 17 px where two thick lines
     cross. The two borderline cases (17 and 19.8 px) were settled by eye
     on enlarged crops; both are crossings.
   - Every place where the scan and the redraw differ is listed under
     "Differences from the redraw". The scan reading is used in the tables.

The redraw has no licence. It was used only to predict which pins to follow.
Every row here is a reading of the scan. Signal names are the labels drawn
on the scan; pad names are the letters printed next to the pads.

## Conventions

- **Frame R.** The stored PNG is upside down, like pages 26, 30 and 32. All
  coordinates here are in its 180°-rotated, upright view (frame R). The old
  trace called the file upright, but its coordinates were already in
  frame R.
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
- **Pin numbers** are the printed ones. Three printed numbers disagree with
  the standard pinout (IC82.10, IC85.3, IC85.10); the tables use the
  standard pin and say so. IC75's second-half /Q carries no number.
- **Supply pins** are not listed. Inputs tied to Vcc or GND are.
- **"Connection"** lists the label of the net (pad or arrow, as drawn) and
  every other pin on that net on this sheet.
  - "Redraw continues to" names the pins on other sheets that the redraw
    puts on the same net. These have not been checked here. They are given
    to help the reviews of those sheets. (One is already known to be
    wrong: the sheet F trace found IC7.10 tied to Vcc, not to ACCE. A.)
- **"Check"** values:
  - "scan": the row was followed on the scan and agrees with the redraw.
  - "scan; differs from redraw": the scan reading is given, and the
    redraw's reading follows.
  - "not drawn": the redraw has the pin, but this sheet does not draw it.
  - "scan: open stub": a short unconnected lead.
- **Channels 1, 2 and 3** are local names for the three copies of the
  position circuit, numbered by their output buffers IC97, IC110 and IC124.

## Evidence boxes for the 26 October check

| What | Frame R | Stored |
|---|---|---|
| Sheet E input pads CB, C2, CN, C12 and the /HS arrow | (1300,650,2500,1300) | (7676,5324,8876,5974) |
| SIDE pads CC, C4, CD, C5, CE and IC85 | (900,1100,1700,1750) | (8476,4874,9276,5524) |
| BRIDGE AP. pad C18 | (1300,1650,2200,1900) | (7976,4724,8876,4974) |
| IC95, IC81a, the first IC121 half | (2050,1280,2650,1900) | (7526,4724,8126,5344) |
| IC107 1,2,13→12 (OR body, output bubble) | (2300,980,2800,1250) | (7376,5374,7876,5644) |
| IC107 9,10,11→8 | (2600,1990,2800,2120) | (7376,4504,7576,4634) |
| IC107 3,4,5→6 (AND body, bubbled inputs) | (4250,5330,4430,5530) | (5746,1094,5926,1294) |
| IC30 and the Vs/2 (H) re-entry arrow | (1300,1780,2300,2100) | (7876,4524,8876,4844) |
| Channel 1: IC89, IC90, IC96, IC122, IC123 | (2850,1150,4300,1950) | (5876,4674,7326,5474) |
| Channel 2: IC103, IC104, IC109, IC88, IC120 | (1950,1950,4300,2950) | (5876,3674,8226,4674) |
| Channel 3: IC81b, IC88, IC117, IC116 | (2000,2850,4300,3750) | (5876,2874,8176,3774) |
| Notes "0→左, 1→右" and "0.25速" | (2600,1200,3150,1880) | (7026,4744,7576,5424) |
| IC97 and RA3 | (5350,1000,6250,1700) | (3926,4924,4826,5624) |
| IC93, IC99, IC100 section 1 | (4450,1450,5350,2150) | (4826,4474,5726,5174) |
| IC93, IC92, IC100 section 2 (the IC92 swap) | (4550,2350,5450,2950) | (4726,3674,5626,4274) |
| IC110 | (5350,2050,5700,2500) | (4476,4124,4826,4574) |
| IC124 | (5350,2900,6350,3600) | (3826,3024,4826,3724) |
| PR-132 (IC111) | (6150,2920,6800,3450) | (3376,3174,4026,3704) |
| IC118, IC114 and the /OTHER pads | (6100,3330,7450,4200) | (2726,2424,4076,3294) |
| IC75 second half, IC29, pad A19 | (6650,3300,7450,3800) | (2726,2824,3526,3324) |
| Frame counter outputs and the Vs pads | (7400,850,8900,2650) | (1276,3974,2776,5774) |
| Bottom-left inputs (C3, CAR CONT. CL., CV, CS, 7MHz, ACCE., AL) | (1200,4300,2500,5600) | (7676,1024,8976,2324) |
| IC112, IC113, IC81c, IC114 3→4 and 5→6, IC86 sections 2 and 3 | (1650,4100,3300,4950) | (6876,1674,8526,2524) |
| PR-38 (IC115), IC108, pads C16, CT, C17, CU | (2200,5050,3200,6300) | (6976,324,7976,1574) |
| PR-39 (IC105), IC106, IC75 first half, IC66, IC68 | (3300,3600,5700,4300) | (4476,2324,6876,3024) |
| IC94, IC102, IC101, IC80, IC87 | (3100,4800,4600,6150) | (5576,474,7076,1824) |
| AREA 1–5 pads | (6800,4500,7400,5050) | (2776,1574,3376,2124) |

## Off-sheet inputs

| Label as drawn | Pad or arrow | From | Goes to on this sheet |
|---|---|---|---|
| /H8 | pad CB, printed "C8" (≈1880,820) | (E) | IC75.13 (/CLR) |
| /H6 | pad C2 (≈1880,870) | (E) | IC75.12 (D) |
| /V8 | pad CN (≈1880,1000); the subscript is drawn like "B" | (E) | CET of IC90, IC104, IC117 |
| /VS | pad C12 (≈1880,1090) | (E) | IC79.13 (CP), IC86.12 |
| /HS | arrow (≈1830,1200) | (F); sheet F re-exports its pad CJ | IC86.11 |
| /L1-SIDE, /L2-SIDE | pads CC, C4 (≈1660,1270–1330) | (D), (M) | IC85.4, IC85.5 |
| /R1-SIDE, /R2-SIDE, /R-L-SIDE | pads CD, C5, CE (≈1640,1470–1590) | (D), (M), (M) | IC85.9, IC85.10, IC85.11 |
| BRIDGE AP. | pad C18 (≈1740,1750) | (D) | /CLR of IC120 and IC121 (pins 3, 11) |
| Vs/2 | arrow (≈1450,1990), note 同ページより ("from the same page") | (H) | IC107.11, IC30.5 |
| /EXT. 500 | arrow (≈1580,3600) | (F); sheet F re-exports its pad BJ | IC106.4 |
| Vs/4 | arrow (≈1600,3700) | (H) | IC30.4, IC111.23 (PR-132 A8) |
| Vs/256, Vs/512, Vs/1K | arrows (≈1650,3950–4050), braced, note 同ページより | (H) | IC105.10, .11, .12 |
| /SP. IRREG. | arrow (≈1600,4220) | (F) | IC106.12 |
| /CAR SP. CONT. | pad C3 (≈1650,4380); "SP" smeared | (D) | IC86.5 |
| CAR CONT. CL. | arrow (≈1800,4610) | (A) | IC112.2 (MR) |
| 14MHz | pad CV (≈1890,4690) | (E) | IC112.13 (CP) |
| /(V-CA × V8) | pad CS (≈1890,4960) | (E) | IC108.1 (S), IC86.9 |
| 7MHz | arrow (≈1850,5040) | (F); sheet F re-exports its pad C13 | IC101.2, IC102.2 (CP) |
| ACCE. A, B, C, D | four braced arrows (≈1850,5250–5370) | (F) | IC115.10–13; ACCE. B also IC113.12, ACCE. C also IC106.13, ACCE. D also IC113.15 |
| SP. CONT. | pad AL, crossed box (≈1870,5420); C36 470p to GND | (I) | IC115.14 |

## Off-sheet outputs

| Label as drawn | Pad or arrow | To | Driven by |
|---|---|---|---|
| Vs/4 | arrow, top right (≈8250,880) | (G) | IC79.10 |
| Vs/2 | arrow (≈8250,960) | (F) | IC79.11 |
| Vs/2 | pad B22 | circled letter e-like (U1) | IC79.11 |
| Vs/4 | pad BY | circled letter e-like (U1) | IC79.10 |
| Vs/8 | arrow (≈8250,1250) | (F), (G) | IC79.9 |
| Vs/16 | pad B21 | (B) | IC79.8 |
| Vs/16 | pad A21, crossed box, through IC29 (designator drawn "19") | (I) | IC79.8 |
| Vs/16 | arrow (≈8300,1560) | (A), (F), (G) | IC79.8 |
| Vs/32, Vs/64 | pads B20, BX | circled letter N-like, probably (M) (U1) | IC78.3, IC78.4 |
| Vs/32 | arrow (≈8250,1810) | (F), (G) | IC78.3 |
| Vs/64 | arrow (≈8250,1880) | (F) | IC78.4 |
| Vs/2, Vs/4, Vs/256, Vs/512, Vs/1K | five braced arrows (≈8250,1950–2300), note 同ページへ ("to the same page") | (H) | IC79.11, IC79.10, IC78.6, IC78.11, IC78.10 |
| /OTHER CAR | pad B15 | (C) | IC114.10 |
| /OTHER BODY | pad BR, and an arrow /OTHER BODY (≈7100,4250) | (C); the arrow to (F) | IC114.12 |
| /OTHER TIAR | pad BS (ditto marks under OTHER) | (C) | IC114.2 |
| /F-SOUND | pad A19, crossed box | circled letter not read (U1) | IC29.10 (buffer of IC75.8) |
| AREA 1, 2, 3, 4, 5 | pads CL, CK, C9, C10, C11 (≈7120,4580–5020), braced | (C) | IC94.10, IC94.4, IC94.9, IC106.3, IC94.12 |
| (Japanese labels, not read) | pads C16, CT, C17, CU (≈2600–2750,5950), braced, ending in a circled symbol that is not read (U4) | — | IC115.1, .2, .3, .4 (PR-38 D0–D3) |

Supply pad groups at the right edge (A33–A36 and AM–AR to Vcc, A1–A5 and
AA–AE to GND, and the E and C rows) were not re-checked pad by pad (U6).

## Pin tables

### IC29 — 7407 buffer, one section (11→10), designator 29 (redraw 74LS07)

Drawn as a triangle with a bubble at each end. The Vs/16 (I) buffer to pad A21, designator drawn "19"-like, is also IC29 (the redraw places that section on sheet A); it carries no pin numbers here.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 10 |  | pad A19, /F-SOUND (circled letter unclear) | scan. drawn with bubbles at both ends (7407 buffer) |
| 11 |  | IC75.8 | scan. drawn with bubbles at both ends (7407 buffer) |

### IC30 — 7400 NAND, one section (4,5→6), printed "30" (redraw 74LS00)

AND body with an output bubble, drawn pointing up.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 4 |  | Vs/4: pad BY Vs/4 (circled letter unclear), arrow Vs/4 (G), and arrow Vs/4 (H) "same page", which re-enters at the bottom left; IC79.10, IC111.23 — redraw continues to G IC77.23 | scan |
| 5 |  | Vs/2: pad B22 Vs/2 (circled letter unclear), arrow Vs/2 (F), and arrow Vs/2 (H) "same page", which re-enters at the left edge; IC79.11, IC107.11 — redraw continues to F IC60.5 | scan |
| 6 |  | IC107.2 | scan |

### IC66 — 7408 AND, one section (4,5→6), printed "66" (redraw 74LS08)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 4 |  | IC86.13, IC93.2, IC93.4, IC93.10, IC93.13 | scan |
| 5 |  | pad CL, AREA 1 (C); IC68.10, IC94.10 | scan |
| 6 |  | IC75.3; 470p to GND (number not read; C66 in the redraw) | scan |

### IC68 — 7400 NAND, one section (9,10→8), printed "68" (redraw 74LS00)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 8 |  | IC124.1, IC124.15; C43 470p to GND | scan |
| 9 |  | IC75.5 | scan |
| 10 |  | pad CL, AREA 1 (C); IC66.5, IC94.10 | scan |

### IC75 — 7474 dual D flip-flop, both halves, each printed "74/2" (redraw 74LS74)

First half beside IC66 (all pins printed). Second half beside the /OTHER pads, drawing D, CK, CL and /Q; its designator reads 75 (the old trace's "IC25" was a misread). Pins 9 and 10 of the second half are not drawn.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /CLR | Vcc | scan |
| 2 | D | IC106.6 | scan |
| 3 | CK | IC66.6; 470p to GND (number not read; C66 in the redraw) | scan |
| 4 | /PR | Vcc | scan |
| 5 | Q | IC68.9 | scan |
| 6 | /Q | open stub | scan: open stub |
| 8 | /Q | IC29.11 | scan. /Q pin number not printed |
| 9 | Q | not drawn on sheet H | not drawn |
| 10 | /PR | not drawn on sheet H | not drawn |
| 11 | CK | strobe line (bit 6 of the three 367 buffers); IC97.13, IC110.13, IC118.15, IC124.13; RA3 5.6K to Vcc | scan |
| 12 | D | pad C2, /H6 (E) | scan |
| 13 | /CLR | pad CB (printed "C8"), /H8 (E) | scan |

### IC78 — 74393 dual 4-bit counter, both halves, printed "393/2" (redraw 74LS393)

Counts on the falling edge of CP.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | CP | Vs/16: pad B21 Vs/16 (B), arrow Vs/16 (A)(F)(G), and a buffer (IC29, designator drawn "19") to pad A21 Vs/16 (I); IC79.8 — redraw continues to A IC12.10, A IC29.5, A IC85.1, F IC60.2, G IC73.11, G IC95.4 | scan |
| 2 | MR | GND | scan |
| 3 | Q0 | Vs/32: pad B20 Vs/32 (M, drawn N-like), arrow Vs/32 (F)(G); C38 in the redraw (not drawn on sheet H) — redraw continues to F IC66.10, F IC72.5, G IC39.13 | scan |
| 4 | Q1 | Vs/64: pad BX Vs/64 (M, drawn N-like), arrow Vs/64 (F) — redraw continues to F IC60.3 | scan |
| 5 | Q2 | open stub | scan: open stub |
| 6 | Q3 | Vs/256, arrow to (H) "same page", re-entering at the bottom left; IC78.13, IC105.10 | scan |
| 8 | Q3 | not drawn on sheet H | not drawn |
| 9 | Q2 | open stub | scan: open stub |
| 10 | Q1 | Vs/1K, arrow to (H) "same page", re-entering at the bottom left; IC105.12 | scan |
| 11 | Q0 | Vs/512, arrow to (H) "same page", re-entering at the bottom left; IC105.11 | scan |
| 12 | MR | GND | scan |
| 13 | CP | Vs/256, arrow to (H) "same page", re-entering at the bottom left; IC78.6, IC105.10 | scan |

### IC79 — 74393, second half only (the first half is on sheet A), printed "393/2" (redraw 74LS393)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 8 | Q3 | Vs/16: pad B21 Vs/16 (B), arrow Vs/16 (A)(F)(G), and a buffer (IC29, designator drawn "19") to pad A21 Vs/16 (I); IC78.1 — redraw continues to A IC12.10, A IC29.5, A IC85.1, F IC60.2, G IC73.11, G IC95.4 | scan |
| 9 | Q2 | Vs/8, arrow to (F)(G) — redraw continues to F IC8.1, F IC34.10, F IC60.6, G IC84.23, G IC91.23, G IC98.23 | scan |
| 10 | Q1 | Vs/4: pad BY Vs/4 (circled letter unclear), arrow Vs/4 (G), and arrow Vs/4 (H) "same page", which re-enters at the bottom left; IC30.4, IC111.23 — redraw continues to G IC77.23 | scan |
| 11 | Q0 | Vs/2: pad B22 Vs/2 (circled letter unclear), arrow Vs/2 (F), and arrow Vs/2 (H) "same page", which re-enters at the left edge; IC30.5, IC107.11 — redraw continues to F IC60.5 | scan |
| 12 | MR | GND | scan |
| 13 | CP | pad C12, /VS (E); IC86.12; C44 in the redraw (not drawn on sheet H) | scan |

### IC80 — 7410 3-input NAND, third section (9,10,11→8), printed "80" (redraw 74LS10)

The other two sections are on sheet F.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 8 |  | IC86.8, IC90.2, IC96.2, IC101.9, IC102.9, IC104.2, IC109.2, IC116.2, IC117.2; C41 470p to GND | scan |
| 9 |  | IC101.10, IC102.15 | scan |
| 10 |  | IC87.9, IC101.15; C42 470p to GND | scan |
| 11 |  | IC87.5, IC107.3 | scan |

### IC81 — 74279 quad /S-/R latch, all four sections, printed "279/4" (redraw 74LS279)

Sections a (1, 2, 3 → 4) and d (15, 14 → 13) near the one-shots, b (6, 5 → 7) under them, c (11, 12, 10 → 9) in the speed block.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /R | IC95.3 | scan |
| 2 | /S1 | IC81.3, IC95.11 | scan |
| 3 | /S2 | IC81.2, IC95.11 | scan |
| 4 | Q | IC82.5, IC89.13, IC121.2, IC121.9 | scan |
| 5 | /R | IC88.8 | scan |
| 6 | /S | IC88.6 | scan |
| 7 | Q | IC82.1, IC117.6 | scan |
| 9 | Q | IC102.7 | scan |
| 10 | /R | IC114.4 | scan |
| 11 | /S1 | IC81.12, IC114.6 | scan |
| 12 | /S2 | IC81.11, IC114.6 | scan |
| 13 | Q | IC82.9, IC103.13, IC120.2, IC120.9 | scan |
| 14 | /R | IC88.11 | scan |
| 15 | /S | IC88.3 | scan |

### IC82 — 7404 inverter, six sections, printed "82" (redraw 74LS04)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC81.7, IC117.6 | scan |
| 2 |  | IC117.4, IC117.5 | scan |
| 3 |  | IC109.15 | scan |
| 4 |  | IC104.9, IC109.9 | scan |
| 5 |  | IC81.4, IC89.13, IC121.2, IC121.9 | scan |
| 6 |  | IC89.6, IC89.10 | scan |
| 8 |  | IC103.6, IC103.10 | scan |
| 9 |  | IC81.13, IC103.13, IC120.2, IC120.9 | scan |
| 10 |  | IC90.9, IC96.9 | scan; differs from redraw. output printed "12" (input 11); a 7404 pairs 11 with 10. Same net as the redraw |
| 11 |  | IC96.15 | scan |
| 12 |  | IC116.9, IC117.9 | scan |
| 13 |  | IC116.15 | scan |

### IC85 — 7411 3-input AND, two sections (3,4,5→6 and 9,10,11→8), printed "85" (redraw 74LS11)

Drawn as OR bodies with bubbles on every input and on the output (AND). Section 1,2,13→12 is on sheet A.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 3 |  | drawn OPEN | scan: open stub. input drawn OPEN, pin number printed like "1"; pin 3 on a 7411 |
| 4 |  | pad CC, /L1-SIDE (D) | scan |
| 5 |  | pad C4, /L2-SIDE (M) | scan |
| 6 |  | IC88.1, IC88.4, IC95.12 | scan |
| 8 |  | IC88.10, IC88.13, IC95.2 | scan |
| 9 |  | pad CD, /R1-SIDE (D) | scan |
| 10 |  | pad C5, /R2-SIDE (M) | scan; differs from redraw. pin number printed "12"; pin 10 on a 7411. Same net as the redraw |
| 11 |  | pad CE, /R-L-SIDE (M) | scan |

### IC86 — 7402 NOR, three sections, printed "86" (redraw 74LS02)

Drawn as AND bodies with bubbled inputs (NOR). Section 2,3→1 is not drawn.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | not drawn on sheet H | not drawn |
| 2 |  | not drawn on sheet H | not drawn |
| 3 |  | not drawn on sheet H | not drawn |
| 4 |  | IC112.1; C29 470p to GND | scan |
| 5 |  | pad C3, /CAR SP. CONT. (D) | scan |
| 6 |  | IC106.8 | scan |
| 8 |  | IC80.8, IC90.2, IC96.2, IC101.9, IC102.9, IC104.2, IC109.2, IC116.2, IC117.2; C41 470p to GND | scan |
| 9 |  | pad CS, /(V-CA × V8) (E); IC108.1 | scan |
| 10 |  | IC112.12, IC114.3 | scan |
| 11 |  | /HS, arrow from (F) (sheet F pad CJ) — redraw continues to F IC40.1, G IC63.5 | scan |
| 12 |  | pad C12, /VS (E); IC79.13; C44 in the redraw (not drawn on sheet H) | scan |
| 13 |  | IC66.4, IC93.2, IC93.4, IC93.10, IC93.13 | scan |

### IC87 — 74107 JK flip-flop, second half, printed "107/2" (redraw 74LS107)

J, K and /CLR drawn to Vcc. Toggles on the falling edge of CK. The first half is not drawn.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | J | not drawn on sheet H | not drawn |
| 2 | /Q | not drawn on sheet H | not drawn |
| 3 | Q | not drawn on sheet H | not drawn |
| 4 | K | not drawn on sheet H | not drawn |
| 5 | Q | IC80.11, IC107.3 | scan |
| 6 | /Q | IC94.14 | scan |
| 8 | J | Vcc | scan |
| 9 | CK | IC80.10, IC101.15; C42 470p to GND | scan |
| 10 | /CLR | Vcc | scan |
| 11 | K | Vcc | scan |
| 12 | CK | not drawn on sheet H | not drawn |
| 13 | /CLR | not drawn on sheet H | not drawn |

### IC88 — 7432 OR, four sections, printed "88" (redraw 74LS32)

Drawn as AND bodies with bubbles on every input and on the output (OR).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC85.6, IC88.4, IC95.12 | scan |
| 2 |  | IC88.12, IC110.14, IC123.6 | scan |
| 3 |  | IC81.15 | scan |
| 4 |  | IC85.6, IC88.1, IC95.12 | scan |
| 5 |  | IC88.9, IC123.8, IC124.14 | scan |
| 6 |  | IC81.6 | scan |
| 8 |  | IC81.5 | scan |
| 9 |  | IC88.5, IC123.8, IC124.14 | scan |
| 10 |  | IC85.8, IC88.13, IC95.2 | scan |
| 11 |  | IC81.14 | scan |
| 12 |  | IC88.2, IC110.14, IC123.6 | scan |
| 13 |  | IC85.8, IC88.10, IC95.2 | scan |

### IC89 — 74157 2-to-1 multiplexer, printed "157" (redraw 74LS157)

Load value for IC90.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | S | IC107.12 | scan |
| 2 | I0a | GND | scan |
| 3 | I1a | Vcc | scan |
| 4 | Za | IC90.3 | scan |
| 5 | I0b | GND | scan |
| 6 | I1b | IC82.6, IC89.10 | scan |
| 7 | Zb | IC90.4 | scan |
| 9 | Zc | IC90.5 | scan |
| 10 | I1c | IC82.6, IC89.6 | scan |
| 11 | I0c | GND | scan |
| 12 | Zd | IC90.6 | scan |
| 13 | I1d | IC81.4, IC82.5, IC121.2, IC121.9 | scan |
| 14 | I0d | Vcc | scan |
| 15 | /E | GND | scan |

### IC90 — 74161 4-bit counter, printed "161" (redraw 74LS161)

Low half of the first 8-bit position counter.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /MR | Vcc | scan |
| 2 | CP | IC80.8, IC86.8, IC96.2, IC101.9, IC102.9, IC104.2, IC109.2, IC116.2, IC117.2; C41 470p to GND | scan |
| 3 | D0 | IC89.4 | scan |
| 4 | D1 | IC89.7 | scan |
| 5 | D2 | IC89.9 | scan |
| 6 | D3 | IC89.12 | scan |
| 7 | CEP | Vcc | scan |
| 9 | /PE | IC82.10, IC96.9 | scan |
| 10 | CET | pad CN, /V8 (E); IC104.10, IC117.10 | scan |
| 11 | Q3 | IC97.10 | scan |
| 12 | Q2 | IC97.6 | scan |
| 13 | Q1 | IC97.4 | scan |
| 14 | Q0 | IC97.2 | scan |
| 15 | TC | IC96.10 | scan |

### IC92 — 7474 dual D flip-flop, printed "74" (redraw 74LS74)

Both halves drawn as one box, with "92" inside.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /CLR | Vcc | scan |
| 2 | D | IC105.1 | scan; differs from redraw. redraw swaps the two halves of IC92 (see "Differences"); same function; redraw: IC105.3 |
| 3 | CK | IC93.8 | scan; differs from redraw. redraw swaps the two halves of IC92 (see "Differences"); same function; redraw: IC93.6 |
| 4 | /PR | Vcc | scan |
| 5 | Q | IC100.2 | scan; differs from redraw. redraw swaps the two halves of IC92 (see "Differences"); same function; redraw: IC100.4 |
| 6 | /Q | open stub | scan: open stub |
| 8 | /Q | open stub | scan: open stub |
| 9 | Q | IC100.4 | scan; differs from redraw. redraw swaps the two halves of IC92 (see "Differences"); same function; redraw: IC100.2 |
| 10 | /PR | Vcc | scan |
| 11 | CK | IC93.6 | scan; differs from redraw. redraw swaps the two halves of IC92 (see "Differences"); same function; redraw: IC93.8 |
| 12 | D | IC105.3 | scan; differs from redraw. redraw swaps the two halves of IC92 (see "Differences"); same function; redraw: IC105.1 |
| 13 | /CLR | Vcc | scan |

### IC93 — 7408 AND, four sections, printed "93" (redraw 74LS08)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | pad C9, AREA 3 (C); IC94.9, IC100.13; C28 470p to GND | scan |
| 2 |  | IC66.4, IC86.13, IC93.4, IC93.10, IC93.13 | scan |
| 3 |  | IC99.3 | scan |
| 4 |  | IC66.4, IC86.13, IC93.2, IC93.10, IC93.13 | scan |
| 5 |  | pad CK, AREA 2 (C); IC94.4, IC100.5 | scan |
| 6 |  | IC92.11 | scan; differs from redraw. redraw swaps the two halves of IC92 (see "Differences"); same function; redraw: IC92.3 |
| 8 |  | IC92.3 | scan; differs from redraw. redraw swaps the two halves of IC92 (see "Differences"); same function; redraw: IC92.11 |
| 9 |  | pad C11, AREA 5 (C); IC94.12, IC100.3 | scan |
| 10 |  | IC66.4, IC86.13, IC93.2, IC93.4, IC93.13 | scan |
| 11 |  | IC99.11 | scan |
| 12 |  | pad C10, AREA 4 (C); IC100.10, IC106.3 | scan |
| 13 |  | IC66.4, IC86.13, IC93.2, IC93.4, IC93.10 | scan |

### IC94 — 74259 8-bit addressable latch, printed "259" (redraw 74LS259)

/CLR (15) drawn to GND and D (13) to Vcc: with /CLR low the part is a 1-of-8 decoder, the addressed output high while /E is low and every output low while /E is high.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | A0 | IC101.13, IC107.4 | scan |
| 2 | A1 | IC101.12, IC107.5 | scan |
| 3 | A2 | IC101.11, IC106.2 | scan |
| 4 | Q0 | pad CK, AREA 2 (C); IC93.5, IC100.5 | scan |
| 5 | Q1 | open stub | scan: open stub |
| 6 | Q2 | open stub | scan: open stub |
| 7 | Q3 | open stub | scan: open stub |
| 9 | Q4 | pad C9, AREA 3 (C); IC93.1, IC100.13; C28 470p to GND | scan |
| 10 | Q5 | pad CL, AREA 1 (C); IC66.5, IC68.10 | scan |
| 11 | Q6 | open stub | scan: open stub |
| 12 | Q7 | pad C11, AREA 5 (C); IC93.9, IC100.3 | scan |
| 13 | D | Vcc | scan |
| 14 | /E | IC87.6 | scan |
| 15 | /CLR | GND | scan |

### IC95 — 7432 OR, two sections, printed "95" (redraw 74LS32)

Drawn as AND bodies with bubbles on every input and on the output (OR). The lower section's designator reads 95; the upper one's is smudged ("93"-like).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC95.13, IC97.14, IC123.12 | scan |
| 2 |  | IC85.8, IC88.10, IC88.13 | scan |
| 3 |  | IC81.1 | scan |
| 11 |  | IC81.2, IC81.3 | scan |
| 12 |  | IC85.6, IC88.1, IC88.4 | scan |
| 13 |  | IC95.1, IC97.14, IC123.12 | scan |

### IC96 — 74161 4-bit counter, printed "161" (redraw 74LS161)

High half of the first 8-bit position counter.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /MR | Vcc | scan |
| 2 | CP | IC80.8, IC86.8, IC90.2, IC101.9, IC102.9, IC104.2, IC109.2, IC116.2, IC117.2; C41 470p to GND | scan |
| 3 | D0 | GND | scan |
| 4 | D1 | GND | scan |
| 5 | D2 | GND | scan |
| 6 | D3 | GND | scan |
| 7 | CEP | Vcc | scan |
| 9 | /PE | IC82.10, IC90.9 | scan |
| 10 | CET | IC90.15 | scan |
| 11 | Q3 | IC123.2 | scan |
| 12 | Q2 | IC122.9 | scan |
| 13 | Q1 | IC123.1 | scan |
| 14 | Q0 | IC122.8 | scan |
| 15 | TC | IC82.11 | scan |

### IC97 — 74367 hex buffer, printed "367" (redraw 74LS367)

Designator read 97 (the old trace had 99).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /G1 | IC97.15, IC100.8 | scan |
| 2 | A1 | IC90.14 | scan |
| 3 | Y1 | IC110.3, IC111.8, IC124.3; RA3 5.6K to Vcc | scan |
| 4 | A2 | IC90.13 | scan |
| 5 | Y2 | IC110.5, IC111.7, IC124.5; RA3 5.6K to Vcc | scan |
| 6 | A3 | IC90.12 | scan |
| 7 | Y3 | IC110.7, IC111.6, IC124.7; RA3 5.6K to Vcc | scan |
| 9 | Y4 | IC110.9, IC111.5, IC124.9; RA3 5.6K to Vcc | scan |
| 10 | A4 | IC90.11 | scan |
| 11 | Y5 | open stub | scan: open stub |
| 12 | A5 | open stub | scan: open stub |
| 13 | Y6 | strobe line (bit 6 of the three 367 buffers); IC75.11, IC110.13, IC118.15, IC124.13; RA3 5.6K to Vcc | scan |
| 14 | A6 | IC95.1, IC95.13, IC123.12 | scan |
| 15 | /G2 | IC97.1, IC100.8 | scan |

### IC99 — 7474 dual D flip-flop, printed "74" (redraw 74LS74)

Both halves drawn as one box, with "99" inside.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /CLR | Vcc | scan |
| 2 | D | IC105.2 | scan |
| 3 | CK | IC93.3 | scan |
| 4 | /PR | Vcc | scan |
| 5 | Q | IC100.1 | scan |
| 6 | /Q | open stub | scan: open stub |
| 8 | /Q | open stub | scan: open stub |
| 9 | Q | IC100.9 | scan |
| 10 | /PR | Vcc | scan |
| 11 | CK | IC93.11 | scan |
| 12 | D | IC105.4 | scan |
| 13 | /CLR | Vcc | scan |

### IC100 — 7450 dual AND-OR-invert, printed "50/2" twice, designator 100 (redraw 7450)

Section 1's output 8 has a handwritten arrow and a note that reads "HI47"-like (U5).

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | 1A | IC99.5 | scan |
| 2 | 2A | IC92.5 | scan; differs from redraw. redraw swaps the two halves of IC92 (see "Differences"); same function; redraw: IC92.9 |
| 3 | 2B | pad C11, AREA 5 (C); IC93.9, IC94.12 | scan |
| 4 | 2C | IC92.9 | scan; differs from redraw. redraw swaps the two halves of IC92 (see "Differences"); same function; redraw: IC92.5 |
| 5 | 2D | pad CK, AREA 2 (C); IC93.5, IC94.4 | scan |
| 6 | 2Y | IC110.1, IC110.15 | scan |
| 8 | 1Y | IC97.1, IC97.15 | scan |
| 9 | 1C | IC99.9 | scan |
| 10 | 1D | pad C10, AREA 4 (C); IC93.12, IC106.3 | scan |
| 11 | 1X (expander) | not drawn on sheet H | not drawn |
| 12 | 1/X (expander) | not drawn on sheet H | not drawn |
| 13 | 1B | pad C9, AREA 3 (C); IC93.1, IC94.9; C28 470p to GND | scan |

### IC101 — 74161 4-bit counter, printed "161" (redraw 74LS161)

High half of the 7MHz divider.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /MR | Vcc | scan |
| 2 | CP | 7MHz, arrow from (F) (sheet F pad C13); IC102.2 — redraw continues to F IC63.12, G IC63.3 | scan |
| 3 | D0 | Vcc | scan |
| 4 | D1 | Vcc | scan |
| 5 | D2 | GND | scan |
| 6 | D3 | GND | scan |
| 7 | CEP | Vcc | scan |
| 9 | /PE | IC80.8, IC86.8, IC90.2, IC96.2, IC102.9, IC104.2, IC109.2, IC116.2, IC117.2; C41 470p to GND | scan |
| 10 | CET | IC80.9, IC102.15 | scan |
| 11 | Q3 | IC94.3, IC106.2 | scan |
| 12 | Q2 | IC94.2, IC107.5 | scan |
| 13 | Q1 | IC94.1, IC107.4 | scan |
| 14 | Q0 | IC111.1 | scan |
| 15 | TC | IC80.10, IC87.9; C42 470p to GND | scan |

### IC102 — 74161 4-bit counter, printed "161" (redraw 74LS161)

Low half of the 7MHz divider.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /MR | Vcc | scan |
| 2 | CP | 7MHz, arrow from (F) (sheet F pad C13); IC101.2 — redraw continues to F IC63.12, G IC63.3 | scan |
| 3 | D0 | IC108.4 | scan |
| 4 | D1 | IC108.7 | scan |
| 5 | D2 | IC108.9 | scan |
| 6 | D3 | IC108.12 | scan |
| 7 | CEP | IC81.9 | scan |
| 9 | /PE | IC80.8, IC86.8, IC90.2, IC96.2, IC101.9, IC104.2, IC109.2, IC116.2, IC117.2; C41 470p to GND | scan |
| 10 | CET | Vcc | scan |
| 11 | Q3 | IC111.2 | scan |
| 12 | Q2 | IC111.3 | scan |
| 13 | Q1 | IC111.4 | scan |
| 14 | Q0 | IC118.1 | scan |
| 15 | TC | IC80.9, IC101.10 | scan |

### IC103 — 74157 2-to-1 multiplexer, printed "157" (redraw 74LS157)

Load value for IC104.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | S | IC107.8 | scan |
| 2 | I0a | GND | scan |
| 3 | I1a | Vcc | scan |
| 4 | Za | IC104.3 | scan |
| 5 | I0b | GND | scan |
| 6 | I1b | IC82.8, IC103.10 | scan |
| 7 | Zb | IC104.4 | scan |
| 9 | Zc | IC104.5 | scan |
| 10 | I1c | IC82.8, IC103.6 | scan |
| 11 | I0c | GND | scan |
| 12 | Zd | IC104.6 | scan |
| 13 | I1d | IC81.13, IC82.9, IC120.2, IC120.9 | scan |
| 14 | I0d | Vcc | scan |
| 15 | /E | GND | scan |

### IC104 — 74161 4-bit counter, printed "161" (redraw 74LS161)

Low half of the second 8-bit position counter.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /MR | Vcc | scan |
| 2 | CP | IC80.8, IC86.8, IC90.2, IC96.2, IC101.9, IC102.9, IC109.2, IC116.2, IC117.2; C41 470p to GND | scan |
| 3 | D0 | IC103.4 | scan |
| 4 | D1 | IC103.7 | scan |
| 5 | D2 | IC103.9 | scan |
| 6 | D3 | IC103.12 | scan |
| 7 | CEP | Vcc | scan |
| 9 | /PE | IC82.4, IC109.9 | scan |
| 10 | CET | pad CN, /V8 (E); IC90.10, IC117.10 | scan |
| 11 | Q3 | IC110.10 | scan |
| 12 | Q2 | IC110.6 | scan |
| 13 | Q1 | IC110.4 | scan |
| 14 | Q0 | IC110.2 | scan |
| 15 | TC | IC109.10 | scan |

### IC105 — PR-39, printed "288" and "PR-39", designator 105 (redraw 74S288)

32 × 8 PROM.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | D0 | IC92.2 | scan; differs from redraw. redraw swaps the two halves of IC92 (see "Differences"); same function; redraw: IC92.12 |
| 2 | D1 | IC99.2 | scan |
| 3 | D2 | IC92.12 | scan; differs from redraw. redraw swaps the two halves of IC92 (see "Differences"); same function; redraw: IC92.2 |
| 4 | D3 | IC99.12 | scan |
| 5 | D4 | IC106.5 | scan |
| 6 | D5 | open stub | scan: open stub |
| 7 | D6 | open stub | scan: open stub |
| 9 | D7 | open stub | scan: open stub |
| 10 | A0 | Vs/256, arrow to (H) "same page", re-entering at the bottom left; IC78.6, IC78.13 | scan |
| 11 | A1 | Vs/512, arrow to (H) "same page", re-entering at the bottom left; IC78.11 | scan |
| 12 | A2 | Vs/1K, arrow to (H) "same page", re-entering at the bottom left; IC78.10 | scan |
| 13 | A3 | IC106.10, IC112.3 | scan |
| 14 | A4 | IC106.9, IC112.4 | scan |
| 15 | /CE | GND | scan |

### IC106 — 7408 AND, four sections, printed "106" (redraw 74LS08)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC107.6 | scan |
| 2 |  | IC94.3, IC101.11 | scan |
| 3 |  | pad C10, AREA 4 (C); IC93.12, IC100.10 | scan |
| 4 |  | /EXT. 500, arrow from (F) (sheet F pad BJ) — redraw continues to F IC62.2 | scan |
| 5 |  | IC105.5 | scan |
| 6 |  | IC75.2 | scan |
| 8 |  | IC86.6 | scan |
| 9 |  | IC105.14, IC112.4 | scan |
| 10 |  | IC105.13, IC112.3 | scan |
| 11 |  | IC113.13 | scan |
| 12 |  | /SP. IRREG., arrow from (F) — redraw continues to F IC80.12 | scan |
| 13 |  | ACCE. C, arrow from (F); IC115.12 — redraw continues to F IC6.3, F IC7.13, F IC13.3, F IC14.1, F IC15.6 | scan |

### IC107 — 7427 3-input NOR, three sections, printed "107" (redraw 74LS10 NAND)

Sections 1,2,13→12 and 9,10,11→8: OR bodies with an output bubble. Section 3,4,5→6: AND body with bubbled inputs. All three read as NOR; the 97091-P board photo shows an SN7427N at IC107.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC121.13 | scan |
| 2 |  | IC30.6 | scan |
| 3 |  | IC80.11, IC87.5 | scan |
| 4 |  | IC94.1, IC101.13 | scan |
| 5 |  | IC94.2, IC101.12 | scan |
| 6 |  | IC106.1 | scan; differs from redraw. NOR (7427) on the scan and on the board photo; the redraw has a 74LS10 NAND. Same net |
| 8 |  | IC103.1 | scan; differs from redraw. NOR (7427) on the scan and on the board photo; the redraw has a 74LS10 NAND. Same net |
| 9 |  | IC120.13 | scan |
| 10 |  | IC120.1, IC120.5 | scan |
| 11 |  | Vs/2: pad B22 Vs/2 (circled letter unclear), arrow Vs/2 (F), and arrow Vs/2 (H) "same page", which re-enters at the left edge; IC30.5, IC79.11 — redraw continues to F IC60.5 | scan |
| 12 |  | IC89.1 | scan; differs from redraw. NOR (7427) on the scan and on the board photo; the redraw has a 74LS10 NAND. Same net |
| 13 |  | IC121.1, IC121.5 | scan |

### IC108 — 74157 2-to-1 multiplexer, printed "157", designator 108 (redraw 74LS157)

Load value for IC102.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | S | pad CS, /(V-CA × V8) (E); IC86.9 | scan |
| 2 | I0a | IC115.5 | scan |
| 3 | I1a | GND | scan |
| 4 | Za | IC102.3 | scan |
| 5 | I0b | IC115.6 | scan |
| 6 | I1b | GND | scan |
| 7 | Zb | IC102.4 | scan |
| 9 | Zc | IC102.5 | scan |
| 10 | I1c | GND | scan |
| 11 | I0c | IC115.7 | scan |
| 12 | Zd | IC102.6 | scan |
| 13 | I1d | Vcc | scan |
| 14 | I0d | IC115.9 | scan |
| 15 | /E | GND | scan |

### IC109 — 74161 4-bit counter, printed "161" (redraw 74LS161)

High half of the second 8-bit position counter.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /MR | Vcc | scan |
| 2 | CP | IC80.8, IC86.8, IC90.2, IC96.2, IC101.9, IC102.9, IC104.2, IC116.2, IC117.2; C41 470p to GND | scan |
| 3 | D0 | GND | scan |
| 4 | D1 | GND | scan |
| 5 | D2 | GND | scan |
| 6 | D3 | GND | scan |
| 7 | CEP | Vcc | scan |
| 9 | /PE | IC82.4, IC104.9 | scan |
| 10 | CET | IC104.15 | scan |
| 11 | Q3 | IC123.5 | scan |
| 12 | Q2 | IC122.2 | scan |
| 13 | Q1 | IC123.3 | scan |
| 14 | Q0 | IC122.3 | scan |
| 15 | TC | IC82.3 | scan |

### IC110 — 74367 hex buffer, printed "367", designator 110 (redraw 74LS367)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /G1 | IC100.6, IC110.15 | scan |
| 2 | A1 | IC104.14 | scan |
| 3 | Y1 | IC97.3, IC111.8, IC124.3; RA3 5.6K to Vcc | scan |
| 4 | A2 | IC104.13 | scan |
| 5 | Y2 | IC97.5, IC111.7, IC124.5; RA3 5.6K to Vcc | scan |
| 6 | A3 | IC104.12 | scan |
| 7 | Y3 | IC97.7, IC111.6, IC124.7; RA3 5.6K to Vcc | scan |
| 9 | Y4 | IC97.9, IC111.5, IC124.9; RA3 5.6K to Vcc | scan |
| 10 | A4 | IC104.11 | scan |
| 11 | Y5 | open stub | scan: open stub |
| 12 | A5 | open stub | scan: open stub |
| 13 | Y6 | strobe line (bit 6 of the three 367 buffers); IC75.11, IC97.13, IC118.15, IC124.13; RA3 5.6K to Vcc | scan |
| 14 | A6 | IC88.2, IC88.12, IC123.6 | scan |
| 15 | /G2 | IC100.6, IC110.1 | scan |

### IC111 — PR-132, printed "PR-132" and "µPB425"-like, 512 × 8 PROM (redraw MB7137, 1K × 8)

The manifest's `pra132.ic111` is 512 bytes, so A0–A8 are all the address lines.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | A7 | IC101.14 | scan |
| 2 | A6 | IC102.11 | scan |
| 3 | A5 | IC102.12 | scan |
| 4 | A4 | IC102.13 | scan |
| 5 | A3 | IC97.9, IC110.9, IC124.9; RA3 5.6K to Vcc | scan |
| 6 | A2 | IC97.7, IC110.7, IC124.7; RA3 5.6K to Vcc | scan |
| 7 | A1 | IC97.5, IC110.5, IC124.5; RA3 5.6K to Vcc | scan |
| 8 | A0 | IC97.3, IC110.3, IC124.3; RA3 5.6K to Vcc | scan |
| 9 | D0 | IC118.2 | scan |
| 10 | D1 | IC118.3 | scan |
| 11 | D2 | IC118.5 | scan |
| 13 | D3 | IC118.6 | scan |
| 14 | D4 | IC118.11 | scan |
| 15 | D5 | IC118.10 | scan |
| 16 | D6 | IC118.14 | scan |
| 17 | D7 | IC118.13 | scan |
| 18 | CE (active high) | Vcc | scan |
| 19 | CE (active high) | Vcc | scan |
| 20 | /CE | GND | scan |
| 21 | /CE | GND | scan. drawn as an active-low enable tied to GND with pin 20; the redraw's MB7137 uses pin 21 as A10, also GND |
| 22 | — | not drawn on sheet H | not drawn. the redraw's A9; a 512 × 8 part has no pin-22 address |
| 23 | A8 | Vs/4: pad BY Vs/4 (circled letter unclear), arrow Vs/4 (G), and arrow Vs/4 (H) "same page", which re-enters at the bottom left; IC30.4, IC79.10 — redraw continues to G IC77.23 | scan |

### IC112 — 74393 dual 4-bit counter, both halves, printed "393/2" and "CL 112" (redraw 74LS393)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | CP | IC86.4; C29 470p to GND | scan |
| 2 | MR | CAR CONT. CL., arrow from (A) — redraw continues to A IC55.8 | scan |
| 3 | Q0 | IC105.13, IC106.10 | scan |
| 4 | Q1 | IC105.14, IC106.9 | scan |
| 5 | Q2 | open stub | scan: open stub |
| 6 | Q3 | open stub | scan: open stub |
| 8 | Q3 | IC113.1 | scan |
| 9 | Q2 | IC113.14 | scan |
| 10 | Q1 | IC113.11 | scan |
| 11 | Q0 | IC113.9 | scan |
| 12 | MR | IC86.10, IC114.3 | scan |
| 13 | CP | pad CV, 14MHz (E) | scan |

### IC113 — 7485 4-bit comparator, printed "85" and "113" (redraw 74LS85)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | B3 | IC112.8 | scan |
| 2 | A<B in | GND | scan |
| 3 | A=B in | Vcc | scan |
| 4 | A>B in | GND | scan |
| 5 | A>B out | open stub | scan: open stub |
| 6 | A=B out | IC114.5 | scan |
| 7 | A<B out | open stub | scan: open stub |
| 9 | B0 | IC112.11 | scan |
| 10 | A0 | open stub | scan: open stub. open TTL input, reads as 1 |
| 11 | B1 | IC112.10 | scan |
| 12 | A1 | ACCE. B, arrow from (F); IC115.11 — redraw continues to F IC6.5, F IC7.12, F IC13.5, F IC14.4, F IC15.2 | scan |
| 13 | A2 | IC106.11 | scan |
| 14 | B2 | IC112.9 | scan |
| 15 | A3 | ACCE. D, arrow from (F); IC115.13 — redraw continues to F IC6.12, F IC13.1 | scan |

### IC114 — 7404 inverter, five sections, printed "114" (redraw 74LS04)

Section 9→8 is not drawn.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC118.7; C45 in the redraw (not drawn on sheet H) | scan |
| 2 |  | pad BS, /OTHER TIAR (C) | scan |
| 3 |  | IC86.10, IC112.12 | scan |
| 4 |  | IC81.10 | scan |
| 5 |  | IC113.6 | scan |
| 6 |  | IC81.11, IC81.12 | scan |
| 8 |  | not drawn on sheet H | not drawn |
| 9 |  | not drawn on sheet H | not drawn |
| 10 |  | pad B15, /OTHER CAR (C) | scan |
| 11 |  | IC118.12 | scan |
| 12 |  | pad BR, /OTHER BODY (C); also arrow /OTHER BODY to (F) — redraw continues to F IC14.13 | scan |
| 13 |  | IC118.9 | scan |

### IC115 — PR-38, printed "288" and "PR-38", designator 115 (redraw 74S288)

32 × 8 PROM.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | D0 | pad C16 (Japanese label, not read; to the sound board) | scan |
| 2 | D1 | pad CT (Japanese label, not read; to the sound board) | scan |
| 3 | D2 | pad C17 (Japanese label, not read; to the sound board) | scan |
| 4 | D3 | pad CU (Japanese label, not read; to the sound board) | scan |
| 5 | D4 | IC108.2 | scan |
| 6 | D5 | IC108.5 | scan |
| 7 | D6 | IC108.11 | scan |
| 9 | D7 | IC108.14 | scan |
| 10 | A0 | ACCE. A, arrow from (F) — redraw continues to F IC7.10, F IC13.9, F IC14.2, F IC15.3 | scan |
| 11 | A1 | ACCE. B, arrow from (F); IC113.12 — redraw continues to F IC6.5, F IC7.12, F IC13.5, F IC14.4, F IC15.2 | scan |
| 12 | A2 | ACCE. C, arrow from (F); IC106.13 — redraw continues to F IC6.3, F IC7.13, F IC13.3, F IC14.1, F IC15.6 | scan |
| 13 | A3 | ACCE. D, arrow from (F); IC113.15 — redraw continues to F IC6.12, F IC13.1 | scan |
| 14 | A4 | pad AL (redraw "Ah"), SP. CONT. (I); C36 470p to GND (C86 in the redraw) | scan |
| 15 | /CE | GND | scan |

### IC116 — 74161 4-bit counter, printed "161" (redraw 74LS161)

High half of the third 8-bit position counter.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /MR | Vcc | scan |
| 2 | CP | IC80.8, IC86.8, IC90.2, IC96.2, IC101.9, IC102.9, IC104.2, IC109.2, IC117.2; C41 470p to GND | scan |
| 3 | D0 | GND | scan |
| 4 | D1 | GND | scan |
| 5 | D2 | GND | scan |
| 6 | D3 | GND | scan |
| 7 | CEP | Vcc | scan |
| 9 | /PE | IC82.12, IC117.9 | scan |
| 10 | CET | IC117.15 | scan |
| 11 | Q3 | IC123.9 | scan |
| 12 | Q2 | IC122.12 | scan |
| 13 | Q1 | IC123.11 | scan |
| 14 | Q0 | IC122.11 | scan |
| 15 | TC | IC82.13 | scan |

### IC117 — 74161 4-bit counter, printed "161" (redraw 74LS161)

Low half of the third 8-bit position counter.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /MR | Vcc | scan |
| 2 | CP | IC80.8, IC86.8, IC90.2, IC96.2, IC101.9, IC102.9, IC104.2, IC109.2, IC116.2; C41 470p to GND | scan |
| 3 | D0 | Vcc | scan |
| 4 | D1 | IC82.2, IC117.5 | scan |
| 5 | D2 | IC82.2, IC117.4 | scan |
| 6 | D3 | IC81.7, IC82.1 | scan |
| 7 | CEP | Vcc | scan |
| 9 | /PE | IC82.12, IC116.9 | scan |
| 10 | CET | pad CN, /V8 (E); IC90.10, IC104.10 | scan |
| 11 | Q3 | IC124.10 | scan |
| 12 | Q2 | IC124.6 | scan |
| 13 | Q1 | IC124.4 | scan |
| 14 | Q0 | IC124.2 | scan |
| 15 | TC | IC116.10 | scan |

### IC118 — 74157 2-to-1 multiplexer, printed "157", designator 118 (redraw 74LS157)

Output Za (4) is not drawn.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | S | IC102.14 | scan |
| 2 | I0a | IC111.9 | scan |
| 3 | I1a | IC111.10 | scan |
| 4 | Za | not drawn on sheet H | not drawn |
| 5 | I0b | IC111.11 | scan |
| 6 | I1b | IC111.13 | scan |
| 7 | Zb | IC114.1; C45 in the redraw (not drawn on sheet H) | scan |
| 9 | Zc | IC114.13 | scan |
| 10 | I1c | IC111.15 | scan |
| 11 | I0c | IC111.14 | scan |
| 12 | Zd | IC114.11 | scan |
| 13 | I1d | IC111.17 | scan |
| 14 | I0d | IC111.16 | scan |
| 15 | /E | strobe line (bit 6 of the three 367 buffers); IC75.11, IC97.13, IC110.13, IC124.13; RA3 5.6K to Vcc | scan |

### IC120 — 74123 dual retriggerable one-shot, printed "123", designator drawn "20"-like (redraw 74LS123)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | A | IC107.10, IC120.5 | scan |
| 2 | B | IC81.13, IC82.9, IC103.13, IC120.9 | scan |
| 3 | /CLR | pad C18, BRIDGE AP. (D); IC120.11, IC121.3, IC121.11 | scan |
| 4 | /Q | IC120.10 | scan |
| 5 | Q | IC107.10, IC120.1 | scan |
| 6 | Cext | C31 220µ | scan |
| 7 | RCext | C31 220µ, R17 47K to Vcc | scan |
| 9 | A | IC81.13, IC82.9, IC103.13, IC120.2 | scan |
| 10 | B | IC120.4 | scan |
| 11 | /CLR | pad C18, BRIDGE AP. (D); IC120.3, IC121.3, IC121.11 | scan |
| 12 | /Q | open stub | scan: open stub |
| 13 | Q | IC107.9 | scan |
| 14 | Cext | C34 220µ | scan |
| 15 | RCext | C34 220µ, R20 47K to Vcc | scan |

### IC121 — 74123 dual retriggerable one-shot, printed "123", designator 121 (redraw 74LS123)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | A | IC107.13, IC121.5 | scan |
| 2 | B | IC81.4, IC82.5, IC89.13, IC121.9 | scan |
| 3 | /CLR | pad C18, BRIDGE AP. (D); IC120.3, IC120.11, IC121.11 | scan |
| 4 | /Q | IC121.10 | scan |
| 5 | Q | IC107.13, IC121.1 | scan |
| 6 | Cext | C32 100µ | scan |
| 7 | RCext | C32 100µ, R18 47K to Vcc | scan |
| 9 | A | IC81.4, IC82.5, IC89.13, IC121.2 | scan |
| 10 | B | IC121.4 | scan |
| 11 | /CLR | pad C18, BRIDGE AP. (D); IC120.3, IC120.11, IC121.3 | scan |
| 12 | /Q | open stub | scan: open stub |
| 13 | Q | IC107.1 | scan |
| 14 | Cext | C35 100µ (third digit unclear; settled as 100µ, U2) | scan |
| 15 | RCext | C35 100µ (third digit unclear; settled as 100µ, U2), R21 47K to Vcc | scan |

### IC122 — 7402 NOR, three sections, printed "122" (redraw 74LS02)

Drawn as AND bodies with bubbled inputs (NOR). Section 5,6→4 is not drawn.

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC123.4 | scan |
| 2 |  | IC109.12 | scan |
| 3 |  | IC109.14 | scan |
| 4 |  | not drawn on sheet H | not drawn |
| 5 |  | not drawn on sheet H | not drawn |
| 6 |  | not drawn on sheet H | not drawn |
| 8 |  | IC96.14 | scan |
| 9 |  | IC96.12 | scan |
| 10 |  | IC123.13 | scan |
| 11 |  | IC116.14 | scan |
| 12 |  | IC116.12 | scan |
| 13 |  | IC123.10 | scan |

### IC123 — 7410 3-input NAND, three sections, printed "123" (redraw 74LS10)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 |  | IC96.13 | scan |
| 2 |  | IC96.11 | scan |
| 3 |  | IC109.13 | scan |
| 4 |  | IC122.1 | scan |
| 5 |  | IC109.11 | scan |
| 6 |  | IC88.2, IC88.12, IC110.14 | scan |
| 8 |  | IC88.5, IC88.9, IC124.14 | scan |
| 9 |  | IC116.11 | scan |
| 10 |  | IC122.13 | scan |
| 11 |  | IC116.13 | scan |
| 12 |  | IC95.1, IC95.13, IC97.14 | scan |
| 13 |  | IC122.10 | scan |

### IC124 — 74367 hex buffer, printed "367", designator 124 (redraw 74LS367)

| Pin | Function | Connection | Check |
|---|---|---|---|
| 1 | /G1 | IC68.8, IC124.15; C43 470p to GND | scan |
| 2 | A1 | IC117.14 | scan |
| 3 | Y1 | IC97.3, IC110.3, IC111.8; RA3 5.6K to Vcc | scan |
| 4 | A2 | IC117.13 | scan |
| 5 | Y2 | IC97.5, IC110.5, IC111.7; RA3 5.6K to Vcc | scan |
| 6 | A3 | IC117.12 | scan |
| 7 | Y3 | IC97.7, IC110.7, IC111.6; RA3 5.6K to Vcc | scan |
| 9 | Y4 | IC97.9, IC110.9, IC111.5; RA3 5.6K to Vcc | scan |
| 10 | A4 | IC117.11 | scan |
| 11 | Y5 | open stub | scan: open stub |
| 12 | A5 | open stub | scan: open stub |
| 13 | Y6 | strobe line (bit 6 of the three 367 buffers); IC75.11, IC97.13, IC110.13, IC118.15; RA3 5.6K to Vcc | scan |
| 14 | A6 | IC88.5, IC88.9, IC123.8 | scan |
| 15 | /G2 | IC68.8, IC124.1; C43 470p to GND | scan |
## Resistors, capacitors and other parts

| Ref | Value as read | Connected to | Note |
|---|---|---|---|
| C41 | 470p to GND | IC80.8 net: CP of the six position counters, /PE of IC101 and IC102, IC86.8 | |
| C42 | 470p to GND | IC101.15 (TC), IC87.9, IC80.10 | |
| C29 | 470p to GND | IC86.4 → IC112.1 | |
| C36 | 470p to GND | pad AL, SP. CONT., IC115.14 | The redraw calls it C86. |
| C43 | 470p to GND | IC68.8 → IC124 /G1, /G2 | |
| C28 | 470p to GND | AREA 3 | |
| (number not read) | 470p to GND | IC66.6 → IC75.3 | The redraw calls it C66 (U3). |
| C35, R21 | 100µ (settled, U2), 47K to Vcc | IC121 pins 14, 15 | U2 |
| C32, R18 | 100µ, 47K to Vcc | IC121 pins 6, 7 | |
| C34, R20 | 220µ, 47K to Vcc | IC120 pins 14, 15 | |
| C31, R17 | 220µ, 47K to Vcc | IC120 pins 6, 7 | |
| RA3 | 5.6K network, common pin 16 to Vcc, drawn pins 10, 12, 13, 14, 15 | pull-ups on the strobe line and on PR-132 A0–A3 | The redraw numbers the pins RA3.2–RA3.6; which drawn pin goes to which line was not needed and not read. |
| C44, C45, C38 | — | /VS (C12), IC118.7, Vs/32 in the redraw | Not drawn on sheet H. |

## Block description (wiring-derived)

This section reads the function from the wiring in the tables above. It has
not been simulated and should not be taken as verified behaviour. Words in
quotes are notes drawn on the sheet.

- **Frame counter.** /VS (pad C12) clocks the second half of IC79. Its QD
  clocks IC78's first half, and that half's QD clocks the second. The
  outputs are Vs/2 to Vs/1K; a 74393 counts on the falling edge of CP, so
  the count advances when /VS goes low. Vs/128 and IC78's last two outputs
  are not used. Vs/2, Vs/4, Vs/256, Vs/512 and Vs/1K leave by arrows marked
  "to the same page" and come back in on the left.
- **Divider and position clock.** IC102 (low) and IC101 (high) form an
  8-bit counter on 7MHz. IC102 counts while IC81c's Q (its CEP) is high;
  IC101 counts on IC102's carry. IC80 9,10,11→8 is a NAND of IC102's TC,
  IC101's TC and IC87's Q. Its output (with C41) loads both counters on the
  next 7MHz edge, IC101 with 0011 and IC102 with IC108's output, and its
  rising edge clocks all six position counters. IC87 toggles on each
  falling edge of IC101's TC (with C42), so the load happens on every second
  pass through 255. IC108 gives IC102 the PR-38 nibble (D4–D7) while
  /(V-CA × V8) (pad CS) is low, and 1000 otherwise.
  - PR-38 is addressed by ACCE. A–D from sheet F and SP. CONT. (pad AL).
    Its D0–D3 leave on pads C16, CT, C17 and CU.
  - IC101 and IC102 also address PR-132: A4–A6 are IC102 Q1–Q3, A7 is
    IC101 Q0, and IC102 Q0 selects IC118's input.
- **Restart delay.** IC112's second half counts 14MHz (pad CV). IC86
  8,9→10, a NOR of the IC80.8 net and CS, resets it during the load pulse on
  the CS line. The same output, through IC114 3→4, resets IC81c, which stops
  IC102. IC113 compares the count with {ACCE. D, ACCE. C AND /SP. IRREG.
  (IC106 12,13→11), ACCE. B, 1}; its A0 input is an open stub, which a TTL
  input reads as 1. At equality IC114 5→6 sets IC81c and IC102 counts
  again. So, as read, the load on the CS line is followed by a pause of a
  few 14MHz cycles set by the accelerator bits.
- **Three position channels.** Each channel is an 8-bit counter made of two
  74161s, clocked by the IC80.8 net and enabled (CET) by /V8 (pad CN). The
  low half loads a value and the high half loads 0000 when the high half's
  TC, inverted by IC82, pulls /PE low.
  - IC122 and IC123 compare each high half with 1010: IC122 NORs Q0 and
    Q2, IC123 NANDs that with Q1 and Q3, so the output is low while the
    high half is 1010. That output goes to its 367 buffer's A6 (the strobe
    bit) and to the OR gates in front of the channel's direction latch.
  - Direction latch. IC85 6 is an AND of /L1-SIDE and /L2-SIDE, and IC85 8
    an AND of /R1-SIDE, /R2-SIDE and /R-L-SIDE. The latch's /S goes low
    when the compare output is low and either L input is low; its /R goes
    low when the compare output is low and an R input is low. The note
    beside channel 1's latch output reads "0→左, 1→右" (0 → left,
    1 → right).
  - Load values: Q = 1 gives 1001 (9), Q = 0 gives 0111 (7). Channels 1
    and 2 load 1000 (8) instead when their 74157's select is low.
  - Channel 1: counter IC90 (low) / IC96 (high), load mux IC89, compare
    IC122 8,9→10 and IC123 1,2,13→12, latch IC81a through IC95, buffer
    IC97. IC89's select is IC107 1,2,13→12, a NOR of both IC121 Q outputs
    and IC30 4,5→6 (NAND of Vs/4 and Vs/2): high in one frame in four while
    neither one-shot runs. Note "0.25速" (0.25 speed).
  - Channel 2: counter IC104 / IC109, load mux IC103, compare IC122 2,3→1
    and IC123 3,4,5→6, latch IC81d through IC88 1,2→3 and 12,13→11,
    buffer IC110. IC103's select is IC107 9,10,11→8, a NOR of both IC120 Q
    outputs and Vs/2: one frame in two. Note "0.5速".
  - Channel 3: counter IC117 / IC116, loaded straight from latch IC81b (Q
    and, through IC82 1→2, /Q), compare IC122 11,12→13 and IC123 9,10,11→8,
    latch inputs through IC88 4,5→6 and 9,10→8, buffer IC124. No select
    and no one-shots. Note "1速".
  - The 1 : 2 : 4 frame rates match the notes 1, 0.5 and 0.25 only with
    IC107 read as NOR. With the redraw's NAND, both selects would be high
    in every frame while the one-shots are idle.
  - One-shots. In each pair (IC121 for channel 1, IC120 for channel 2) the
    first half fires when the latch's Q rises while the second half is idle
    (A = the second half's Q), and the second half fires when Q falls while
    the first is idle (B = the first half's /Q). Either running holds the
    select low. BRIDGE AP. (pad C18) clears all four halves when low. With
    the values as read, the 74123 formula 0.28·R·C gives about 1.3 s for
    47K with 100µ and 2.9 s for 47K with 220µ (a 74LS123's 0.45·R·C would
    give about 2.1 s and 4.7 s).
- **Which channel drives PR-132 (AREA).** IC94, a 74259 with /CLR at GND
  and D at Vcc, decodes IC101 Q1–Q3 while IC87's /Q is low: address 5 is
  AREA 1, 0 is AREA 2, 4 is AREA 3 and 7 is AREA 5. AREA 4 is IC106 1,2→3,
  IC101 Q3 AND IC107 3,4,5→6 (a NOR of IC87 Q, IC101 Q1 and IC101 Q2), so
  address 4 while IC87's Q is low. The five AREA lines also go to sheet C.
  - PR-39 (IC105) is addressed by Vs/256, Vs/512, Vs/1K and IC112's first
    half (Q0, Q1). That half counts the falling edges of IC86 5,6→4, a NOR
    of /CAR SP. CONT. (pad C3) and IC106 9,10→8 (its own Q0 AND Q1), so it
    stops at 3; CAR CONT. CL. (A) clears it.
  - IC86 11,12→13 is a NOR of /HS and /VS: high during each /HS pulse
    inside /VS. IC93 ANDs it with AREA 3, AREA 4, AREA 5 and AREA 2 to clock
    IC99 (D = PR-39 D1, D3) and IC92 (D = PR-39 D0, D2). IC66 4,5→6 ANDs it
    with AREA 1 to clock IC75's first half, whose D is IC106 4,5→6, /EXT.
    500 AND PR-39 D4.
  - IC100 section 1 (output 8) is NOR(IC99.5 · AREA 3, IC99.9 · AREA 4) and
    enables IC97 (channel 1). Section 2 (output 6) is NOR(IC92.5 · AREA 5,
    IC92.9 · AREA 2) and enables IC110 (channel 2). IC68 9,10→8, NAND of
    IC75.5 and AREA 1, enables IC124 (channel 3).
- **Image PROM and outputs.** The enabled 367 puts its channel's low
  counter half on PR-132 A0–A3 and its compare output on the strobe line;
  with no buffer enabled, RA3 pulls all five lines high. IC118's /E is the
  strobe line, so it passes PR-132 data only while the enabled channel's
  high half is 1010. IC102 Q0 picks D0/D2/D4/D6 or D1/D3/D5/D7. Zb, Zc and
  Zd, inverted by IC114, are /OTHER TIAR (pad BS), /OTHER BODY (pad BR, and
  the arrow to sheet F's collision gate IC14.13) and /OTHER CAR (pad B15).
  Za (D0/D1) is not used. PR-132 A8 is Vs/4.
- **/F-SOUND.** IC75's second half takes D = /H6 (pad C2) and /CLR = /H8
  (pad CB), and is clocked by the strobe line, so it clocks each time the
  strobe line returns high. Its /Q, buffered by IC29 11→10, is /F-SOUND on
  pad A19.

## Differences from the redraw

The tables follow the scan in every case below.

| Item | Scan | Redraw |
|---|---|---|
| IC107, all three sections | NOR: two OR bodies with an output bubble, one AND body with bubbled inputs. The 97091-P board photo shows an SN7427N at IC107. | 74LS10 NAND, same pins |
| IC92 halves | 2 ← IC105.1, 3 ← IC93.8 (AREA 5 gate), 5 → IC100.2; 12 ← IC105.3, 11 ← IC93.6 (AREA 2 gate), 9 → IC100.4 | The two halves swapped. Same function: in both, PR-39 D0 goes with AREA 5 and D2 with AREA 2. |
| PR-132 (IC111) | Printed "µPB425"-like, a 512 × 8 PROM; pins 18, 19 enables to Vcc, 20, 21 enables to GND; pin 22 not drawn | MB7137 (1K × 8): pin 21 is A10 at GND, pin 22 (A9) open. Same connections. |
| IC82 section 11→10 | Output printed "12" | Pin 10 |
| IC85.3 | Drawn OPEN, number printed like "1" | Pin 3, open |
| IC85.10 | Number printed "12" | Pin 10 |
| SP. CONT. pad and capacitor | Pad AL, C36 | "Ah", C86 |
| Capacitor on IC66.6 | 470p, number not read | C66 |
| C44 (/VS), C45 (IC118.7), C38 (Vs/32) | Not drawn | Present |
| Vs/16 buffer to pad A21 | Drawn on sheet H (designator "19"-like) | IC29 5→6 placed on sheet A |

## Unresolved

1. **U1 — circled sheet letters on some pads.** B22 (Vs/2) and BY (Vs/4)
   carry an "e"-like letter; B21 (Vs/16) has a clear (B). B20 (Vs/32) and
   BX (Vs/64) carry an N-like letter, probably (M) given the drafter's M,
   N and H. A21 reads (I). A19 (/F-SOUND) has a letter that does not read.
   Box R(7900,850,8900,2550). None of this changes the wiring.
2. **U2 — C35's value.** 100µ with a doubtful third digit (100µ or 10µ).
   It sets the width of IC121's first half. Aldo read the label on an
   enlarged crop on 30 October; its third character looks like a 6. The
   drafter writes plain values with µ (C34 and C31 "220µ", not the code
   227), so "106" as a code for 10 µF does not fit, and 106 µF is not a
   standard value. **Settled as 100 µF** (Aldo, 30 October), the value of
   C32 on IC121's other half.
3. **U3 — the 470p on IC66.6** has no readable number.
4. **U4 — pads C16, CT, C17, CU.** Their four Japanese labels and the
   circled symbol at the end of the brace were not read. The redraw sends
   them to the board connector (J3). Box R(2300,5800,2800,6300).
5. **U5 — note on IC100.8.** A handwritten arrow points at IC100's output 8
   with a note that reads "HI47"-like. Box R(5400,1760,5700,1920).
6. **U6 — supply pad groups** at the right edge were not checked pad by
   pad. The redraw's sheet H list has no supply pads to compare.
7. **U7 — BRIDGE AP.** is drawn here without an overbar; the sheet C trace
   reads a /BRIDGE AP arrow. To be settled when sheet D's driver is
   checked. The circuit here only needs the level: low clears the one-shots.

## Closed items from the old trace

The numbers are those of [`work/SHEET_H_LOG.md`](work/SHEET_H_LOG.md).

- **1 (core untraced), 7, 8, 10, 14, 15, 19, 21:** the position counters,
  PR-132's address, IC118's select and /E, IC114's fourth section (3→4,
  to IC81c /R), PR-39, the AREA sources, IC121 and the bottom-left inputs
  are all in the pin tables.
- **2:** CN is /V8, C12 is /VS, C2 is /H6, and the pad drawn "C8" above
  them is CB, /H8. Sheet E sends /H8 on FB, /H6 on F2, /V8 on FN and /VS
  on F12.
- **11:** IC75's second half: D ← C2, /CLR ← CB, CK ← the strobe line,
  confirmed on the scan.
- **13:** PR-38's /CE is at GND; IC108's select is pad CS, its /E is at
  GND, and its 4B input is at Vcc.
- **17:** IC86 is drawn with AND bodies and bubbled inputs: NOR.
- **20:** pad C18 is BRIDGE AP. (D).
- **21 (part):** both clocks exist: 7MHz arrives by an arrow from (F) and
  clocks IC101/IC102; 14MHz arrives on pad CV and clocks IC112's second
  half.
- **The old trace's IC97 was "IC99"**; the designator reads 97.

## History

- 23 October 2026: first partial transcription and redraw comparison
  (Andrea Bogazzi, PR #1; corrections by Codex, PR #2). Kept unchanged as
  [`work/SHEET_H_LOG.md`](work/SHEET_H_LOG.md).
- 26 October 2026: Claude checked every pin of the sheet on the scan and
  wrote this consolidated trace.
