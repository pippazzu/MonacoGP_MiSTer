# Sheet C — colour mixing, priority encoder and video output

Source: Sega **Monaco GP (420-0358)**, PDF page **30**, drawing **C**, board
**96578-P**, sheet **D-2/5**, "IC BOARD ASS'Y, B". Japanese caption:
映像,色出し統合 (picture, colour output, combination). Image:
manual 420-0358, PDF page 30, **10160 × 6624** pixels, SHA-256
`30a9b08093ddcb65b8cc07c0b7e517e782fbb36008d095f80fe9e576d7ac216f`.

**Status: complete pin-level trace, every connection followed on the scan
(30 October 2026).** This file replaces the partial transcription of 23
October, which is kept unchanged in
the working notes (not published). That pass read the input
labels and the large blocks but left the gate network between them
untraced (its U1). Every row below is a reading of the scan; the few that
remain uncertain are marked and listed under "Unresolved".

## How this trace was made

As for sheet M ([SHEET_M_TRACE.md](SHEET_M_TRACE.md)):
1. The KiCad redraw (`Video/Video.kicad_sch`) was netlisted; its parts on
   this sheet gave the list of pins to follow. Nothing was taken from it.
2. Long wires were followed with the stroke walker (perpendicular strokes
   and ink-disc sizes along one wire); gate bodies, bubbles, pin numbers,
   labels and every doubtful meeting point were read by eye at 1–3×.
3. Junction dots measure 15.5–21 px on this page; crossings 6–14 px, up to
   16 px where thick lines cross (several such points, all crossings by eye).
4. Inter-board pads were checked against sheets A, G, H and M and the 1999
   cable table (E to B straight except E17–E22 and ET–EZ; F to C straight).

## Conventions

- **Frame R.** The stored PNG is upside down, like pages 26, 28 and 32. All
  coordinates here are in its 180°-rotated, upright view (frame R); a box
  `(x0,y0,x1,y1)` in frame R is `(10160-x1, 6624-y1, 10160-x0, 6624-y0)` in
  the stored image. The first pass gave stored-image coordinates.
- `/NAME` is an overbar, `(D)` a circled sheet letter, `ICn.p` pin p of IC n.
  Colour suffixes as drawn: (BL) black, (Bu) blue, (DBu) dark blue, (W)
  white, (Y) yellow, (R) red, (G) green, (Mu) magenta.
- Gate function from the drawn body: OR body with input bubbles is NAND; AND
  body with input bubbles is NOR; bubbles on every input and on the output
  turn AND into OR and OR into AND. All sections of each package agree.
- **Part types printed over triangles.** "16" above each inverter of IC7
  and "17" above each buffer of IC1 are the types (7416 open-collector
  inverter, 7417 open-collector buffer), with the designator below. Sheet
  M's "16 / 7" inverter (IC7, /RESCUE CP) reads the same way.
- Supply pins are not listed. "Not drawn" means the pin does not appear
  (a TTL input then floats high).

## Off-sheet signals

### Inputs (left margin, top to bottom, frame R y)

| Label as drawn | Pad / arrow | Feeds | Cross-check |
|---|---|---|---|
| AREA 1..5 (H) | pads FL, EK, F9, F10, E11 (≈700–1080) | IC86 2, 4, 6, 10, 12 | sheet H sends AREA 1..5 on CL, CK, C9, C10, C11; F to C is straight, so the pads are FL, FK, F9, F10, F11 ("EK", "E11" are misdrawn or misread F's) |
| /OTHER BODY (H) | pad ER (≈1300) | IC86 1, 15 | |
| 7M (E) | arrow (≈1385) | IC79.9; IC14.4 (riser x≈2215) | |
| /HOUSE (Mu) (D) | arrow (≈1455) | IC58.9 | the first pass read (W) |
| EXTEND (A) | pad EB (≈1600) | IC20.1, IC34.2; arrow EXTEND to (M)(D) | sheet A sends EXTEND on BB (cable straight) |
| /GRASS (BL) (D) | arrow (≈1690) | IC20.11 | |
| /ROAD (D) | arrow (≈1810) | IC19.9, IC15.1 | |
| /TREE & GRASS (G) (D) | arrow (≈2020) | IC21.5, IC20.2, IC20.6 | |
| /HOUSE ST (D) | arrow (≈2190) | IC21.3 | |
| /GRASS AREA (D) | arrow (≈2235) | IC21.4 | |
| /TREE & GRASS (BL) (D) | arrow (≈2300) | IC19.11, IC20.13, IC13.2 (riser x≈2304) | |
| /LIGHT (G) | pad EC (≈2550) | IC15.2, IC19.3 | |
| TUNNEL AP (D) | arrow (≈2620) | IC19.4 | |
| /COIN & START (B) | arrow (≈2700) | IC8.10 | |
| /SIG. (BL) (M) | arrow (≈2900) | IC26.1 | sheet M IC9.11 |
| /DUMMY (BL) (M) | arrow (≈2945) | IC26.2 | sheet M IC55.12 |
| /PLAYER (BL) (G) | pad EU (≈3000) | IC26.4 | |
| /PLAYER TIAR (G) | pad E17 (≈3150) | IC27.5 | |
| /OTHER TIAR (H) | pad ES (≈3190) | IC27.11 | |
| /HOUSE (W) (D) | arrow (≈3260) | IC27.12 | |
| /RESCUE (W) (M) | arrow (≈3340) | IC27.2 | |
| /DUMMY (W) (M) | arrow (≈3380) | IC27.1 | |
| /SIG. (Y) (M) | arrow (≈3480) | IC4.12 | |
| /EXPLO. (Y) (G) | pad E4 (≈3540) | IC4.5 | |
| /RESCUE (Y) (M) | arrow (≈3600) | IC4.1 | |
| /GREEN BELT (D) | arrow (≈4005) | IC13.11 | |
| /Y-LINE (D) | arrow (≈4095) | IC13.4, IC5.11 | |
| /RESCUE (BL) (M) | arrow (≈4190) | IC15.4, IC8.13 | |
| /GRAVEL (D) | arrow (≈4245) | IC15.5 | |
| /SPLAY (G) | pad E10 (≈4460) | IC14.10 | |
| /POOL (S?) (D) | arrow (≈4510) | IC14.12 | suffix unread (U3) |
| /SLIP (D) | arrow (≈4560) | IC14.9 | |
| /HOUSE (S?) (D) | arrow (≈4600) | IC14.13 | suffix unread, St likely (U3) |
| /OTHER CAR (H) | pad E15 (≈4650) | IC8.1; arrow /OTHER CAR to (M) | |
| /EXTEND (A) | pad E3 (≈4740) | IC10.10; arrow /EXTEND to (M) | sheet A sends /EXTEND on B3 |
| BRIDGE AP (D) | arrow (≈4780) | IC5.1 | |
| ROAD (D) | arrow (≈4920) | IC5.2, IC5.5 | no overbar, unlike the /ROAD arrow at ≈1810 (corrected 31 October; the first pass read /ROAD) |
| /SIDE LINE (D) | arrow (≈5020) | IC5.14 | |
| V-④ (B) | arrow (≈5080) | IC9.4 | |
| /BRIDGE (DBu), (Bu), (Y), (W) (M) | arrows (≈5125, 5160, 5225, 5270) | IC9.5, IC5.6, IC5.10, IC5.13 | sheet M IC6 |
| /HOUSE (R) (D), /WALL (R) (D), /BRIDGE (R) (M) | arrows (≈5390, 5430, 5475) | IC44.13, .2, .1 | |
| /PLAYER (G) | pad E9 (≈5650) | IC66.2 | |
| /DUMMY AREA (M) | arrow (≈5690) | IC66.1 | |
| /EXPLO. AREA (G) | pad F15 (≈5720) | IC66.13 | |
| /PLAYER BODY (G) | pad E7 (≈5810) | IC33.6 | |
| EX & GAME OVER (B) | arrow (≈5860) | IC33.12 | sheet B IC70.11 (/EX. & GAME OVER) |
| /DUMMY (R) (M), /RESCUE (R) (M) | arrows (≈5900, 5940) | IC33.2, IC33.1 | |
| /EXPLO (R) (G) | pad EK (≈5990) | IC33.5 | |
| /TV-BLANKING (E) | arrow (≈2730, right half) | IC7 (blanking section) | |
| /SYNCRO (E) | arrow (≈3330, right half) | IC7.5 | |

### Outputs

| Label | Pad / arrow | Driver |
|---|---|---|
| EXTEND (M)(D) | arrow (≈1630) | pad EB net |
| /OTHER CAR (M) | arrow (≈4820) | pad E15 net |
| /EXTEND (M) | arrow (≈4855) | pad E3 net |
| TV-RED | pad D11 | IC7.8 node |
| TV-BLUE | pad D12 | IC7.10 node |
| TV-GREEN | pad D13 | IC7.12 node |
| TV-SYNCRO | pad D10 | IC7.6 node |
| TV-GND | pad DL | ground |

## Signal path in brief

Described as wired.
- **AREA register.** IC86 (74368) buffers AREA 1..5 while /OTHER BODY is
  low; IC79 (74174) registers them on 7M.
- **Colour planes.** Each colour has a collector whose output is active low
  into the priority encoder IC2 (74147, input 9 highest):

  | IC2 input | Plane | Collector | Inputs (active low unless stated) |
  |---|---|---|---|
  | 9 (pin 10) | (R) red | IC33 (7430) → IC3 11→10 | /RESCUE (R), /DUMMY (R), /EXPLO (R), /PLAYER BODY, EX & GAME OVER, IC45.11, T.P. |
  | 8 (pin 5) | (BL) black | IC26 (7420) → IC3 1→2 | /SIG. (BL), /DUMMY (BL), /PLAYER (BL), IC19.6 |
  | 7 (pin 4) | (W) white | IC27 (7430) → IC3 3→4 | /PLAYER TIAR, /OTHER TIAR, /HOUSE (W), /RESCUE (W), /DUMMY (W), IC20.7, IC5.12 |
  | 6 (pin 3) | label unread (U1); IC2 gives green + blue | IC8 9,10,11→8 | IC79 Q5 (AREA 5), /COIN & START, IC9.8 |
  | 5 (pin 2) | (Y) yellow | IC4 (7430) → IC3 5→6 | /SIG. (Y), /EXPLO. (Y), /RESCUE (Y), IC79 Q4 (AREA 4), IC20.12, IC5.9 |
  | 4 (pin 1) | (G) green | IC8 3,4,5→6 | IC79 Q3 (AREA 3), IC20.4 |
  | 3 (pin 13) | (Mu) magenta | IC58 9,10→8 | /HOUSE (Mu), IC79 Q2 (AREA 2) |
  | 2 (pin 12) | (Bu) blue | IC19 1,2,13→12 → IC3 9→8 | IC79 Q1 (AREA 1), IC20.9, IC10.8 |

- **Extended play.** IC20 (74157) re-routes four lines while EXTEND is
  high: /TREE & GRASS (G) leaves the green plane (1Y open) for the white
  one (2Y, which otherwise carries IC10.3); the blue plane (3Y) takes IC14.6
  instead of /GRASS (BL); the yellow plane (4Y) takes /TREE & GRASS (BL)
  instead of IC19.8.
- **Bridge.** IC5 (74157), switched by BRIDGE AP, puts the bridge's colour
  lines (Bu, Y, W, and DBu with V-④) in place of ROAD, /Y-LINE and /SIDE
  LINE.
- **Output.** IC2's A, B, C (active low) go through the open-collector
  inverters IC7 (7416) to the RED, BLUE and GREEN nodes, each pulled up
  through a 470 Ω section of R1/R3/R5 and down by 10 kΩ (R13..R15). IC1
  (7417), driven by IC3.12 = NOT IC34 = NOT NOR(IC10.3, EXTEND), pulls all
  three nodes down through 470 Ω (R2, R4, R6). TR1 (C458), turned on by
  /TV-BLANKING through IC7 and RA1, clamps the three nodes low through the
  diodes D1..D3 (MA150). So the code on IC2's inputs gives: 9 red, 8 black,
  7 white, 6 cyan, 5 yellow, 4 green, 3 magenta, 2 blue, none black.

## Pin tables

### IC86 — 74368, printed "368 86"

| Pin | Connection |
|---|---|
| 1, 15 (/G1, /G2) | /OTHER BODY, pad ER (dot 2480,1305) |
| 2→3, 4→5, 6→7, 10→9, 12→11 | AREA 1..5 → IC79.3, .4, .6, .11, .13 |
| 14→13 | not drawn (13's bubble drawn, no wire) |

### IC79 — 74174, printed "174 79"

| Pin | Connection |
|---|---|
| 9 (CP) | 7M |
| 1 (/MR) | not drawn |
| 3, 4, 6, 11, 13 (D1..D5) | IC86.3, .5, .7, .9, .11 |
| 2 (Q1) | IC19.2 |
| 5 (Q2) | IC58.10 (x≈3060) |
| 7 (Q3) | IC8.5 (riser x≈5920) |
| 10 (Q4) | IC4.6 (x≈4510) |
| 12 (Q5) | IC8.9 (x≈3670) |
| 14, 15 | not drawn |

Q1..Q5 are drawn with output bubbles; the 74174 has true outputs only.

### IC20 — 74157, printed "157 20"

| Pin | Connection |
|---|---|
| 1 (S) | EXTEND (pad EB; dot 4046,1874 also to IC34.2) |
| 15 (/G) | GND |
| 2 (1A), 6 (2B) | /TREE & GRASS (G) |
| 5 (2A) | IC10.3 (riser x≈3320) |
| 11 (3A) | /GRASS (BL) |
| 14 (4A) | IC19.8 |
| 3 (1B) | not drawn (bubble only) |
| 10 (3B) | IC14.6 (riser x≈3740) |
| 13 (4B) | /TREE & GRASS (BL) |
| 4 (1Y) | IC8.3 (x≈4435) |
| 7 (2Y) | IC27.6 (x≈4334) |
| 9 (3Y) | IC19.13 (x≈4400) |
| 12 (4Y) | IC4.3 (x≈4467) |

### IC5 — 74157, printed "5 157"

| Pin | Connection |
|---|---|
| 1 (S) | BRIDGE AP (row ≈4780 → riser x≈4416) |
| 15 (/G) | GND |
| 2 (1A), 5 (2A) | ROAD (second arrow, no overbar; dot 4230,4925) |
| 11 (3A) | /Y-LINE (riser x≈4110; it crosses the /ROAD row at 14.4 px) |
| 14 (4A) | /SIDE LINE (riser x≈3859) |
| 3 (1B) | IC9.6 |
| 6 (2B) | /BRIDGE (Bu) |
| 10 (3B) | /BRIDGE (Y) |
| 13 (4B) | /BRIDGE (W) |
| 4 (1Y) | IC14.2 (riser x≈4580) |
| 7 (2Y) | IC10.9 (riser x≈5065) |
| 9 (3Y) | IC4.11 |
| 12 (4Y) | IC27.3 (riser x≈4660 → row ≈4350 → x≈4292) |

### Gates

| Package | Section | Drawn | Pins |
|---|---|---|---|
| IC58 (7408) | 9,10→8 | OR body, all bubbles = AND | 10 IC79.5; 9 /HOUSE (Mu); 8 → IC2.13 |
| IC19 (7412) | 1,2,13→12 | OR body, input bubbles = NAND | 2 IC79.2; 13 IC20.9; 1 IC10.8; 12 → IC3.9 |
| IC19 | 9,10,11→8 | AND body, output bubble | 9 /ROAD; 10 IC21.6; 11 /TREE & GRASS (BL); 8 → IC20.14 |
| IC19 | 3,4,5→6 | AND body, output bubble | 3 /LIGHT; 4 TUNNEL AP; 5 IC66.12; 6 → IC26.5 |
| IC21 (7411) | 3,4,5→6 | OR body, all bubbles = AND | 5 /TREE & GRASS (G); 3 /HOUSE ST; 4 /GRASS AREA; 6 → IC19.10, IC13.12 |
| IC15 (7409) | 1,2→3 | OR body, all bubbles = AND | 1 /ROAD; 2 /LIGHT; 3 → IC10.2 |
| IC15 | 4,5→6 | OR body, all bubbles = AND | 4 /RESCUE (BL); 5 /GRAVEL; 6 → IC14.1 |
| IC10 (7432) | 1,2→3 | AND body, all bubbles = OR | 1 IC13.8; 2 IC15.3; 3 → IC20.5, IC34.3 |
| IC10 | 9,10→8 (drawn upright) | AND body, all bubbles = OR | 10 /EXTEND (pad E3); 9 IC5.7; 8 → IC19.1 |
| IC34 (7402) | 2,3→1 | AND body, input bubbles = NOR | 3 IC10.3; 2 EXTEND; 1 → IC3.13 |
| IC8 (U2) | 3,4,5→6 | OR body, all bubbles = AND | 5 IC79.7; 3 IC20.4; 4 open (U4); 6 → IC2.1 |
| IC8 | 9,10,11→8 | OR body, all bubbles = AND | 9 IC79.12; 10 /COIN & START; 11 IC9.8; 8 → IC2.3, IC13.6 (dot 4215,2740) |
| IC8 | 1,2,13→12 | OR body, all bubbles = AND | 13 /RESCUE (BL); 1 /OTHER CAR; 2 IC66.12 (riser x≈2410, dot 2412,4706); 12 → IC13.3, IC14.5, IC9.10 |
| IC9 (7400) | 9,10→8 | AND body, output bubble | 9 IC14.8; 10 IC8.12; 8 → IC8.11 (riser x≈3855) |
| IC9 | 4,5→6 | OR body, input bubbles = NAND | 4 V-④; 5 /BRIDGE (DBu); 6 → IC5.3 |
| IC14 (7420) | 1,2,4,5→6 | AND body, output bubble | 4 7M; 1 IC15.6; 5 IC8.12; 2 IC5.4; 6 → IC20.10 |
| IC14 | 9,10,12,13→8 | OR body, input bubbles = NAND | 10 /SPLAY; 12 /POOL; 9 /SLIP; 13 /HOUSE (S?); 8 → IC9.9 |
| IC26 (7420) | 1,2,4,5→6 | OR body, input bubbles = NAND | 5 IC19.6; 1 /SIG. (BL); 2 /DUMMY (BL); 4 /PLAYER (BL); 6 → IC3.1 |
| IC44 (7410) | 1,2,13→12 | OR body, input bubbles = NAND | 13 /HOUSE (R); 2 /WALL (R); 1 /BRIDGE (R); 12 → IC45.12 |
| IC66 (7411) | 1,2,13→12 | OR body, all bubbles = AND | 2 /PLAYER; 1 /DUMMY AREA; 13 /EXPLO. AREA; 12 → IC45.13, IC8.2, IC19.5 |
| IC45 (7400) | 12,13→11 | AND body, output bubble | 12 IC44.12; 13 IC66.12; 11 → IC33.11 |
| IC13 (7430) | 8-input | OR body, input bubbles = NAND | 2 /TREE & GRASS (BL); 3 IC8.12; 4 /Y-LINE; 5 IC3.10; 6 IC8.8; 11 /GREEN BELT; 12 IC21.6; 1 not drawn; 8 → IC10.1 (crosses the /RESCUE (Y) row at 12.8 px) |
| IC4 (7430) | 8-input | OR body, input bubbles = NAND | 1 /RESCUE (Y); 3 IC20.12; 5 /EXPLO. (Y); 6 IC79.10; 11 IC5.9; 12 /SIG. (Y); 2, 4 not drawn; 8 → IC3.5 |
| IC27 (7430) | 8-input | OR body, input bubbles = NAND | 1 /DUMMY (W); 2 /RESCUE (W); 3 IC5.12; 5 /PLAYER TIAR; 6 IC20.7; 11 /OTHER TIAR; 12 /HOUSE (W); 4 not drawn; 8 → IC3.3 |
| IC33 (7430) | 8-input | OR body, input bubbles = NAND | 1 /RESCUE (R); 2 /DUMMY (R); 4 T.P.; 5 /EXPLO (R); 6 /PLAYER BODY; 11 IC45.11; 12 EX & GAME OVER; 3 not drawn; 8 → IC3.11 |
| IC3 (7404) | 9→8, 5→6, 3→4, 1→2, 11→10, 13→12 | inverters | 8 → IC2.12; 6 → IC2.2 "(Ȳ)"; 4 → IC2.4 "(W̄)"; 2 → IC2.5 "(BL)"; 10 → IC2.10, IC13.5; 12 → IC1.1, .3, .5 |

### IC2 — 74147, printed "147 2"

| Pin (input) | Connection |
|---|---|
| 12 (2) | IC3.8 |
| 13 (3) | IC58.8 |
| 1 (4) | IC8.6 |
| 2 (5) | IC3.6 |
| 3 (6) | IC8.8 |
| 4 (7) | IC3.4 |
| 5 (8) | IC3.2 (riser x≈5995) |
| 10 (9) | IC3.10 (riser x≈6040) |
| 11 (1) | not drawn |
| 9 (A) | IC7.9 |
| 7 (B) | IC7.11 |
| 6 (C) | IC7.13 |
| 14 (D) | not drawn |

### Output stage

| Part | Connection |
|---|---|
| IC7 (7416, "16") 9→8, 11→10, 13→12 | IC2 A, B, C → RED, BLUE, GREEN nodes |
| IC7 blanking section (pins not printed; 1→2 by elimination: the package's other five sections are 3→4 on sheet M and 5, 9, 11, 13 here) | /TV-BLANKING → TR1 base, with RA1 560 Ω to Vcc |
| IC7 5→6 | /SYNCRO → TV-SYNCRO node, RA1 560 Ω to Vcc → pad D10 |
| IC1 (7417, "17") 5→6, 3→4, 1→2 | IC3.12 → 470 Ω (R2, R4, R6) → RED, BLUE, GREEN nodes |
| R1, R3, R5 | "470 ×3", node to Vcc |
| R13, R14, R15 | "10K ×3", node to GND |
| D1, D2, D3 | "MA150", from each node to the clamp node |
| clamp node | RA1 560 Ω to Vcc; TR1 collector |
| TR1 | "C458" (2SC458 likely), emitter to GND |
| pads | D11 TV-RED, D12 TV-BLUE, D13 TV-GREEN, D10 TV-SYNCRO, DL TV-GND (GND) |

## Differences from the redraw

The scan is used in every case.

| Item | Redraw | Scan |
|---|---|---|
| IC8 | 74LS12 (NAND) | all three sections drawn as AND (OR body, bubbles on inputs and output) |
| IC8.11 / IC9.8 | both unconnected | joined (IC9.8 → IC8.11) |
| IC5.1, .2, .5, .6, .10, .11, .13, .14, .7 | unconnected | BRIDGE AP; ROAD ×2; /BRIDGE (Bu), (Y), (W); /Y-LINE; /SIDE LINE; → IC10.9 |
| IC10 upright section | pin 9 tied to IC19.1, 8 and 10 open | 10 /EXTEND, 9 IC5.7, output 8 → IC19.1 |
| IC7 | 74LS06 | printed type "16" (7416); same function |
| IC1 | 74LS07 | printed type "17" (7417); same function |

## Corrections to the first pass (23 October)

- The gate network (its U1) is traced in full; the yellow collector is IC4
  (designator 4, type 7430), as the redraw has it.
- "5M" is 7M (old U3); the AREA pads are FL, FK, F9, F10, F11 (old U2).
- The two /EXTEND pads (old U5) are EXTEND on EB and /EXTEND on E3.
- "/HOUSE (W)" at the top is /HOUSE (Mu).
- IC86's enables are /OTHER BODY and IC79 is clocked by 7M (old U10).
- IC20's select is EXTEND; IC5's is BRIDGE AP; IC34 is a 7402 NOR (old U11).
- The drivers' printed numbers are their types (old U13): IC7 = 7416,
  IC1 = 7417.

## Unresolved

1. **U1 — the label on IC8's 9,10,11→8 output** reads "(S?)": the second
   character is not legible. Through IC2 the plane gives green + blue
   (cyan). Crop (4120,2690,4320,2735).
2. **U2 — IC8's type.** All three sections are drawn as AND gates; the
   redraw lists a 74LS12 (NAND). The drawing is used; a 3-input AND with
   open-collector outputs (7415) or a 7411 would fit.
3. **U3 — label suffixes** of /POOL (S?) and /HOUSE (S?) (≈4510, 4600); St
   likely for the house. Crop (1500,4480,2000,4620).
4. **U4 — IC8.4**: a short heavy dash in front of the bubble, joined to no
   wire. Read as open (floats high). Crop (5800,1370,6000,1420).
5. **U5 — IC7's blanking section pin numbers** are not printed (1→2 by
   elimination); TR1's type reads "C458".
6. **U6 — resistor and capacitor values** on the output stage beyond those
   listed (the "470 ×3" pack on R1/R3/R5).
