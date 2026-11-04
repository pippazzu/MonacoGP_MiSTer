# Sheet M — rescue car, dummy cars, signs, bridge, lives (PR-138…PR-141)

Source: Sega **Monaco GP (420-0358)**, PDF page **33**, drawing **M**, board
**96578-P**, sheet **D-5/5**, "IC BOARD ASS'Y, B". Japanese caption:
レスキュー車、持車、橋の絵かしとコントロール (rescue car, spare cars, bridge:
drawing and control). Image: manual 420-0358, PDF page 33,
**10144 × 6624** pixels, upright, SHA-256
`ba27ee679eac5d156d7efb483fed5711280bea69a1cd8e96829f94944e625fed`.

**Status: complete pin-level trace, every connection followed on the scan
(30 October 2026).** This file replaces the partial transcription of 23
October, which is kept unchanged in
the working notes (not published). That pass located every block
and settled the PROM enables, the output labels and IC43's tie pattern, but
left the PROM address maps and the gate clusters open (its U1–U13). They
are traced here. Every row below is a reading of the scan; the few readings
that remain uncertain are marked and listed under "Unresolved".

## How this trace was made

1. The KiCad redraw (stonedDiscord, `Video/Video.kicad_sch`) was netlisted
   with a small S-expression reader. Its parts placed in the sheet M area
   gave the list of pins to follow. Nothing was taken from it: every
   connection was followed on the scan, and where the two differ the scan
   is used ("Differences from the redraw").
2. Long wires were followed with a stroke walker that tracks one wire
   through the scan, lists every perpendicular stroke it meets and measures
   the largest ink disc at each meeting point. Short stubs, gate bodies,
   bubbles, pin numbers and labels were read by eye on crops at 1.5–3×.
3. Junctions: on this page a drawn dot measures 15.5–21 px. A crossing
   measures 6–13 px, and up to 16 px where two thick lines cross (the V/H
   bus rows near x≈1620–1670 and the bridge data bus over the IC22 line).
   Every crossing measuring 14 px or more was looked at on an enlarged crop;
   all were crossings.
4. The inter-board pads were checked against the traces of sheets A, F and
   H and the 1999 owner's cable table (E to B straight except E17–E22 →
   B19, B20, B21, B22, BT, B17 and ET–EZ → BV, BW, BX, BY, BZ, BU, B18;
   F to C straight). All of them agree (see "Off-sheet signals").

## Conventions

- Coordinates are pixels of the image above. `/NAME` is an overbar. `(B)`
  is a circled sheet letter. `ICn.p` is pin p of IC n.
- Gate function is taken from the drawn body: AND body with input bubbles
  is NOR; bubbles on every input and on the output turn AND into OR and OR
  into AND. Several packages are drawn in both forms on this sheet (IC39,
  IC15, IC21); every section of each package gives the same function.
- Package types: printed where the sheet prints them ("161", "157", "153",
  "193", "393/2", "74/2", "123/2", "107/2", "42", the PROMs); otherwise the
  type that the drawn function and pin numbers fit, checked against the
  same designator on sheets B and D (same board).
- Supply pins are not listed; inputs tied to Vcc or GND are. "Not drawn"
  means the pin does not appear on the sheet (floating on a TTL input reads
  high); "open stub" means a short drawn stub that goes nowhere.

## Off-sheet signals

### Inputs

| Label as drawn | Pad / arrow | Feeds | Cross-check |
|---|---|---|---|
| 7M (E) | arrow, y≈1835 | IC36.2, IC37.2 | sheet E: 7MHz arrow (M) |
| V-CA (E) | arrow, y≈1935 | IC42.3 | sheet E: V-CA (M) |
| V8 (E) | arrow, y≈1975 | IC42.4 | sheet E: V8 (M) |
| /V4 (E) | arrow, y≈2390 | IC60.13 | sheet E: /V4 (B)(M) |
| /HS (E) | arrow, y≈2655 | IC35.2 | sheet E: /HS (B)(D)(M) |
| V0–V4, H1–H6, H8 (E) | arrows, bus y≈3969–4483 | PR-139 address, PR-138 A0–A3, IC23, IC28, IC26, IC42, IC53, IC39 (tables) | sheet E sends all of these to (M) |
| H0 (E)? | arrow, y≈4595 | IC50.1 | subscript damaged (U1); sheet E sends H0 to (M) and no other row here carries it |
| V6 (E) | arrow, y≈1440 | IC28.4 | sheet E: V6 (B)(M) |
| V7 (E) | arrow, y≈3290 | IC52.12 | sheet E: V7 (B)(D)(M) |
| /V7 (E) | arrow, y≈3390 | IC16.12 | sheet E: /V7 (M) |
| V-① (B) | arrow, y≈4850 | IC53.15 | sheet B: IC54 decoder rows to (M) |
| V-② (B) | arrow, y≈1545 | IC21.10 | 〃 |
| V-③ (B) | arrow, y≈2330 | IC60.2, IC15.12 | 〃 |
| V-④ (B) | arrow, y≈4775 | IC65.3, IC21.1, IC22.1 | 〃 |
| V-⑤ (B) | arrow, y≈800 | IC15.13 | 〃 |
| MH0, MH1–MH4 (B) | arrows, y≈2080 and 1665–1790 | IC11.1; PR-140/141 A5–A8 | sheet B motion counter |
| Vs/4 (B)? | arrow, y≈1320 | PR-138.23 | glyph "V?/4" (U2); sheet H sends Vs/4 on BY (cable EW) |
| Vs/16 (B) | arrow, y≈3830 | IC73.9, IC52.9 | sheet B: Vs/16 on E19 "same node forwarded to (M)" |
| Vs/32 (H) | pad **E18** | IC16.4 | sheet H: Vs/32 on pad B20; cable E18 → B20 |
| Vs/64 (H) | pad **EV** | IC49.1, IC47.10 | sheet H: Vs/64 on pad BX; cable EV → BX |
| /EXTEND (C) | arrow, y≈2945 | IC49.2 | |
| EXTEND (C) | arrow, y≈3770 | IC26.12 | |
| /GAME (B) | arrow, y≈3870 | IC73.10 | |
| /COIN IN (B) | arrow, y≈6000 | IC46.14 | |
| 100-C (D) | arrow, y≈3470 | IC35.12 | sheet D: 100-C to (M) |
| /H8 (E) | arrow, y≈3510 | IC42.13 | sheet E: /H8 (B)(M) |
| CAR. NO. CONT (D) | arrow, y≈4650 | IC59.9 | sheet D: /CAR NO CONT to (M) (U3: no overbar seen here) |
| /EXT. 500 (D) | arrow, y≈4700 | IC65.2 | sheet D: IC25.8 /EXT. 500 (M) |
| EXT. 500 (D) | arrow, y≈2495 | IC15.9 | sheet D lists its unbarred EXT. 500 as (H) only (U4) |
| /0-AREA (D) | arrow, y≈750 | IC10.13 | sheet D: IC82.10 /0-AREA (M) |
| BRIDGE AP (D) | arrow, y≈2205 | IC16.10 | sheet D: IC80.1 BRIDGE AP |
| /OTHER CAR (C) | arrow, y≈2365 | IC21.13 | |
| ACCE. D (F) | pad **E14** | IC45.9 | sheet F: ACCE. D on pad B14 (M) |
| EXPLO. SEL. D (F) | pad **EM** | IC59.1 | sheet F: EXPLO. SEL. D on pad BM (M) |
| /EX. SIGNAL CP (A) | pad **E2** | IC39.5 | sheet A: IC55d.3 on pad B2 (M) |

### Outputs

| Label as drawn | Pad / arrow | Driver | Cross-check |
|---|---|---|---|
| /RESCUE (BL) (C) | arrow | IC22.10 | |
| /RESCUE (R) (C) | arrow | IC16.6 | |
| /RESCUE (W) (C) | arrow | IC22.8 | |
| /RESCUE (Y) (F) | pad **EB** | IC22.12 | sheet F: /RESCUE (Y) on pad B8 (M) |
| /RESCUE (Y) (C) | arrow | IC22.12 (same net) | |
| /R-L-SIDE (H) | pad **FE** | IC59.10 | sheet H: /R-L-SIDE on pad CE (M) |
| EXT. CAR CONT (F) | pad **EX** | IC49.4 | sheet F: EXT. CAR CONT. on pad BZ (M); cable EX → BZ |
| /RESCUE CP (S) | pad **D9** | IC7.4 | |
| /SIG. (Y) (C) | arrow | IC9.3 | |
| /SIG. (BL) (C) | arrow | IC9.11 | |
| /DUMMY AREA (C) | arrow | IC26.8 | |
| /DUMMY (W) (C) | arrow | IC56.6 | |
| /DUMMY (R) (C) | arrow | IC56.8 | |
| /DUMMY (BL) (C) | arrow | IC55.12 | |
| GAME OVER (A) | pad **E16** | IC59.6 | sheet A: pad B16 GAME OVER (M) |
| /BRIDGE (W) (C) | arrow | IC6.6 | |
| /BRIDGE (W) (F) | pad **EH** | IC6.6 (same net) | sheet F: /BRIDGE (W) on pad BH (M); the redraw's "EG" is wrong |
| /BRIDGE (DBu) (C) | arrow | IC6.5 | |
| /BRIDGE (Y) (C) | arrow | IC6.3 | |
| /BRIDGE (R) (C) | arrow | IC6.2 | |
| /BRIDGE (Bu) (C) | arrow | IC6.1 | |
| /L2-SIDE (H) | pad **F4** | IC16.3 | sheet H: /L2-SIDE on pad C4 (M) |
| /R2-SIDE (H) | pad **F5** | IC16.11 | sheet H: /R2-SIDE on pad C5 (M) |

Sheet H's trace left the circled letter of its Vs/32 and Vs/64 pads open
("N-like, probably (M)", its U1). Sheet M receives both (E18, EV): the
letter is M.

## Signal path in brief

Described as wired; what the signals mean in play is not inferred here.

1. **Rescue car.** IC36 and IC37 (74161) count 7M as an 8-bit counter. IC44
   (9,10,11→8) reloads both when IC36's carry, IC37's carry and IC57's Q
   are all high; IC57 (74107 half) toggles on IC37's carry. The load value
   is IC43's A or B pattern into IC36 (A 1010, B 1000, D..A) and 0011 into
   IC37; IC43 is selected by IC42.6 = /(V-CA · V8 · IC35.Q upper). IC44
   (3,4,5→6) = /(IC57.Q · IC37.QC · IC37.QD) clocks IC35's upper half and
   strobes the rescue mux through IC10. PR-138 is addressed by V0–V3,
   IC36 QC/QD, IC37 QA/QB and Vs/4; IC29 (selected by IC36 QB) picks one
   nibble of its byte, and IC22/IC16 drive the four rescue colour lines.
   IC16 gates the red line with Vs/32.
2. **Rescue timing.** IC49 (74393 half) counts Vs/64, cleared by /EXTEND.
   IC45 and IC47 gate Vs/64 with IC49 QD and ACCE. D into the clock of
   IC35's lower half (D = 100-C, preset = IC49 QC). Its Q fires IC18
   (74123, C4 1.5 µF, R16 ≈47 kΩ), whose Q drives /RESCUE CP through IC7.
   IC42 (9,10,11→8) = /(IC35lower./Q · IC49.QB · IC49.QA) presets IC35's
   upper half; IC49 QB also leaves as EXT. CAR CONT (F). IC60 NORs V-③,
   IC35upper./Q and /V4, and IC59 turns it into /R-L-SIDE (H), which also
   gates the rescue mux strobe (IC10).
3. **Lives (spare cars) and GAME OVER.** IC46 (74193) is cleared while
   /COIN IN is high. It counts up on /EX. SIGNAL CP (through IC39, an OR
   with IC52 = QA·QB, so the up input is held high at count 3) and down on
   EXPLO. SEL. D (inverted by IC59). Its borrow, through IC59, is
   **GAME OVER (A)**. Its QA/QB select IC53's inputs (Vcc, GND, H5, H6,
   H5+H6), so the number of spare cars shown follows the count; IC26
   combines them with EXTEND and V4 into /DUMMY AREA. IC52 gates DUMMY AREA
   with Vs/16, and IC56/IC55 combine it with PR-139's nibbles (IC50) into
   the three /DUMMY colour lines.
4. **Signs.** PR-139 (V0–V4, H1–H4) through IC50 (select H0?) gives the
   sign data; IC66 (3-input AND of /CAR NO CONT, IC73 and IC65) and IC9
   produce /SIG. (Y) and /SIG. (BL). IC73 = NOR(IC42 = /(H5·H6·/H8),
   Vs/16, /GAME); IC65 = NOR(/EXT. 500, V-④).
5. **Bridge.** IC10.11 = /0-AREA OR (V-③ AND V-⑤) enables PR-140 when high
   and PR-141 when low; the two share every address and data line. A0–A3
   are V0–V3 XORed with V7 (IC23, the shared line buffered by IC52), A4 is
   IC21.8 = AND(V4⊕V7, V-②, V6⊕V7) (IC28, IC21), A5–A8 are MH1–MH4. IC11
   (select MH0, strobe /V-④ through IC22) and IC6 (7442, D from IC16 =
   /(BRIDGE AP · IC21.12)) decode the colour. IC21.12 = /(V-④ · /DUMMY
   AREA · /OTHER CAR). IC15.8 = EXT. 500 · IC11.4 gates /L2-SIDE (with V7)
   and /R2-SIDE (with /V7).

## Pin tables

### IC36 — 74161, printed "(161) 36"

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 1 | /CLR | Vcc (dot 2275,1625 on the Vcc riser) | scan |
| 2 | CP | 7M (E), row y≈1835, dot (1765,1835) | scan |
| 3, 4, 5, 6 | A–D | IC43.4, .7, .9, .12 | scan |
| 7, 10 | P, T | Vcc | scan |
| 9 | /PE | /LOAD net: IC37.9, IC44.8, 470 pF to GND (unlabelled) | scan |
| 11 | QD | PR-138.3 (x≈2150, row y≈1216) | scan |
| 12 | QC | PR-138.4 (x≈2066, row y≈1174) | scan |
| 13 | QB | IC29.1 (x≈1983 → y≈1459 → x≈3415) | scan |
| 14 | QA | open stub (ends y≈1523) | scan |
| 15 | CO | IC37.10; IC44.9 (x≈2315 → y≈1500 → x≈3105); T at (2315,1680), 15.6 px | scan |

### IC37 — 74161, printed "(161) 37"

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 1 | /CLR | Vcc, through the IC57 J/K riser x≈2820 to the Vcc dot (2920,1860) | scan |
| 2 | CP | 7M (x≈2275 → y≈1845 → the 7M row) | scan |
| 3, 4 | A, B | Vcc | scan |
| 5, 6 | C, D | GND | scan |
| 7 | P | Vcc (row y≈1625 crosses x≈2315 at 12.8 px: crossing) | scan |
| 9 | /PE | /LOAD net | scan |
| 10 | T | IC36.15 | scan |
| 11 | QD | IC44.5 (x≈2652 → y≈803) | scan |
| 12 | QC | IC44.4 (x≈2568 → y≈755) | scan |
| 13 | QB | PR-138.1 (x≈2487) | scan |
| 14 | QA | PR-138.2 (x≈2400) | scan |
| 15 | CO | IC57.9; IC44.10 (dot 2735,1685); 470 pF to GND (dot 2735,1995, unlabelled) | scan |

### IC43 — 74157, printed "(157) 43"

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 1 | S | IC42.6; C9 470 pF to GND | scan |
| 2, 11 | 1A, 3A | GND | scan, confirmed by the maintainer 23 Oct |
| 5, 14 | 2A, 4A | Vcc | 〃 |
| 3, 6, 10 | 1B, 2B, 3B | GND | 〃 |
| 13 | 4B | Vcc | 〃 |
| 4, 7, 9, 12 | Y | IC36.3, .4, .5, .6 | scan |
| 15 | /G | GND | scan |

Load values (D..A): A = 1010, B = 1000.

### IC57 — 74107, second half, printed "(107/2) 57"

The first half is sheet B's MH8 stage (sheet B trace). The first pass read
this designator as "52".

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 8 | J | Vcc (riser x≈2820, dot 2820,1640) | scan |
| 11 | K | Vcc (same riser, dot 2820,1730) | scan |
| 10 | /CLR | Vcc (dot 2920,1860) | scan |
| 9 | CLK | IC37.15 (crosses the riser at 11.3 px) | scan |
| 5 | Q | dot (3069,1641): up to IC44.3, down to IC44.11 | scan |
| 6 | /Q | not drawn | scan |

### IC44 — 7410 3-input NAND, two sections, printed "44"

| Section | Pins | Connection | Evidence |
|---|---|---|---|
| 3,4,5→6 (top, x≈3150) | 3 IC57.Q; 4 IC37.12; 5 IC37.11; 6 → C7 470 pF to GND (dot 3379,811), IC10.5 (x≈4205), IC35.3 (y≈2682 → x≈2095) | scan |
| 9,10,11→8 (drawn pointing up, x≈2600) | 9 IC36.15; 10 IC37.15; 11 IC57.Q; 8 → /LOAD (IC36.9, IC37.9) | scan |

### IC42 — 7410 3-input NAND, three sections, printed "42"

| Section | Pins | Connection | Evidence |
|---|---|---|---|
| 3,4,5→6 (x≈1750, y≈1990) | 3 V-CA (E); 4 V8 (E); 5 IC35.5 (y≈2358 → x≈1511 → y≈2027); 6 → IC43.1, C9 | scan |
| 9,10,11→8 (drawn facing left, x≈2330, y≈2500) | 9 IC35.8 (x≈2640 → y≈3565); 10 IC49.4 (x≈2556, dot 2553,3009); 11 IC49.3 (x≈2515 → y≈2918); 8 → IC35.4, C6 470 pF to GND. The three input risers cross the IC44 row y≈2663 at 10–11 px | scan |
| 1,2,13→12 (x≈1780, y≈3550) | 13 /H8 (E); 1 H6 (riser x≈1622, dot 1622,4405); 2 H5 (riser x≈1660, dot 1660,4365); 12 → IC73.11 | scan; the risers cross the V3 row at 16 px, crossings by eye |

### IC35 — 7474, both halves, each printed "74/2"

| Half | Pin | Connection | Evidence |
|---|---|---|---|
| upper (x≈2050, y≈2500) | 2 D | /HS (E), row y≈2655 | scan |
| | 3 CK | IC44.6 net | scan |
| | 4 PR | IC42.8 (C6 470 pF on the net) | scan |
| | 5 Q | IC42.5 | scan |
| | 6 /Q | IC60.1 (row y≈2361) | scan |
| | 1 /CLR | not drawn | scan |
| lower (x≈2480, y≈3510) | 12 D | 100-C (D), row y≈3472 (the IC47.8 riser crosses it at 12.6 px) | scan |
| | 11 CK | IC47.8 | scan |
| | 10 PR | IC49.5 (y≈3085 → x≈2580) | scan |
| | 9 Q | IC18.9 (row y≈3480, crosses x≈2633 at 10 px) | scan |
| | 8 /Q | IC42.9 | scan |
| | 13 /CLR | not drawn | scan |

### IC49 — 74393, one half, printed "393/2 49"

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 1 | CP | Vs/64: pad EV row y≈2780, dot (1740,2780); same row → IC47.10 | scan |
| 2 | CL | /EXTEND (C), row y≈2945 | scan |
| 3 | QA | IC42.11 | scan |
| 4 | QB | row y≈3010: IC42.10 (dot) and pad EX → EXT. CAR CONT (F) | scan |
| 5 | QC | IC35.10 | scan |
| 6 | QD | IC45.10 | scan |

### IC45 — 7400 NAND, one section, printed "45"

| Pins | Connection | Evidence |
|---|---|---|
| 10, 9 → 8 | 10 IC49.6; 9 pad E14 ACCE. D (F); 8 → IC47.9 | scan |

### IC47 — 7408 AND, one section (drawn pointing down), printed "47"

| Pins | Connection | Evidence |
|---|---|---|
| 9, 10 → 8 | 9 IC45.8; 10 Vs/64 (row y≈2785 → riser x≈2240, crossing the IC49 rows at 10–11 px); 8 → IC35.11 | scan |

### IC18 — 74123, second half, printed "123/2 18"

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 9 | A (bubble) | IC35.9 | scan |
| 10 | B | Vcc (loop to the dot 2925,3690) | scan |
| 11 | /CLR | Vcc (same dot) | scan |
| 6, 7 | Cext, Rext/Cext | C4 1.5 µF between them; R16 from 7 to Vcc | scan; R16's first digit blotted ("?7K", 47 kΩ likely, U5) |
| 5 | Q | row y≈3490 → IC7.3 | scan |
| 12 | /Q | open stub | scan |

### IC7 — inverter (open-collector mark), one section

| Pins | Connection | Evidence |
|---|---|---|
| 3 → 4 | 3 IC18.5; 4 → pad D9, /RESCUE CP (S) | scan. "16" is written above the triangle and "7" below; IC16 is a 7400 on this sheet, so 7 is taken (redraw: 74LS06) |

### IC60 — 7427 3-input NOR, one section, printed "60"

| Pins | Connection | Evidence |
|---|---|---|
| 2, 1, 13 → 12 | 2 V-③ (B) (dot 3440,2328); 1 IC35.6; 13 /V4 (E); 12 → IC59.11 | scan; AND body with input bubbles |

### IC10 — 7432 OR, two sections, printed "10"

| Section | Pins | Connection | Evidence |
|---|---|---|---|
| 5,4→6 (x≈4100, y≈1630) | 5 IC44.6 (dot 4194,1609); 4 /R-L-SIDE (riser x≈4163, T on the FE row at 14.1 px); 6 → IC29.15 | scan; AND body, bubbles on inputs and output |
| 13,12→11 (x≈7050, y≈780) | 13 /0-AREA (D); 12 IC15.11; 11 → PR-140.18/19 and PR-141.20/21 (x≈8275) | scan; same form |

### PR-138 — µPB425 (MPB-425), designator 30, caption 救急車 RESCUE CAR

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 8 | A0 | V0: riser x≈3375 to the PR-139 pin 8 row, dot (3350,3995); branch at y≈2756 (dot) → IC23.10 | scan |
| 7 | A1 | V1: riser x≈3330 to the PR-139 pin 7 row, dot (3302,4045); branch y≈2796 → IC23.4 | scan |
| 6 | A2 | V2: riser x≈3275, dot (3264,4088); branch y≈2840 → IC23.13 | scan |
| 5 | A3 | V3: riser x≈3248, dot (3218,4130); branch y≈2882 → IC23.1 | scan |
| 4 | A4 | IC36.12 | scan |
| 3 | A5 | IC36.11 | scan |
| 2 | A6 | IC37.14 | scan |
| 1 | A7 | IC37.13 | scan |
| 23 | A8 | Vs/4 (B)?, row y≈1336 | scan; label glyph U2 |
| 20, 21 | /CE1, /CE2 | GND | scan |
| 18, 19 | CE3, CE4 | Vcc | scan |
| 9, 10, 11, 13, 14, 15, 16, 17 | D0–D7 | IC29.2, .3, .5, .6, .11, .10, .14, .13 (straight risers) | scan |

### IC29 — 74157, printed "29 157"

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 1 | S | IC36.13 | scan |
| 2, 3 / 5, 6 / 11, 10 / 14, 13 | 1A, 1B / 2A, 2B / 3A, 3B / 4A, 4B | PR-138 D0, D1 / D2, D3 / D4, D5 / D6, D7 | scan |
| 15 | /G | IC10.6 | scan |
| 4 | 1Y | IC22.13 | scan |
| 7 | 2Y | IC22.9 | scan |
| 9 | 3Y | IC16.5 | scan |
| 12 | 4Y | IC22.11 | scan |

### IC22 — 7406 inverter (open collector), four sections, printed "22"

| Section | Connection | Evidence |
|---|---|---|
| 11→10 | 11 IC29.12; 10 → /RESCUE (BL) (C) | scan |
| 9→8 | 9 IC29.7; 8 → /RESCUE (W) (C) | scan |
| 13→12 | 13 IC29.4; 12 → pad EB /RESCUE (Y) (F), and dot (4350,2080) → /RESCUE (Y) (C) | scan |
| 1→2 (bridge, x≈6850, y≈1945) | 1 V-④ (riser x≈6650); 2 → IC11.15 (y≈1945 → x≈8220) | scan |

### IC16 — 7400 NAND, four sections, printed "16"

| Section | Connection | Evidence |
|---|---|---|
| 5,4→6 | 5 IC29.9; 4 Vs/32 (pad E18 row → x≈3190 → y≈1900); 6 → /RESCUE (R) (C) | scan |
| 10,9→8 | 10 BRIDGE AP (D); 9 IC21.12; 8 → IC6.12 | scan |
| 2,1→3 | 2 IC15.8; 1 V7 (IC52.11 net); 3 → pad F4 /L2-SIDE (H) | scan |
| 13,12→11 | 13 IC15.8; 12 /V7 (E); 11 → pad F5 /R2-SIDE (H) | scan |

### IC59 — hex inverter, five sections, printed "59"

Sheet D's trace uses the sixth section (13→12, as a 7404); the redraw has
74LS06. The type is not printed on this sheet.

| Section | Connection | Evidence |
|---|---|---|
| 11→10 | 11 IC60.12; 10 → pad FE /R-L-SIDE (H), IC10.4 | scan |
| 9→8 (input bubble) | 9 CAR. NO. CONT (D); 8 → IC66.10 | scan |
| 3→4 (input bubble, drawn pointing down) | 3 /DUMMY AREA; 4 → IC52.10 (dot 3011,5434), IC55.2 (y≈5797) | scan |
| 1→2 | 1 pad EM EXPLO. SEL. D (F); 2 → IC46.4 | scan |
| 5→6 | 5 IC46.13; 6 → pad E16 GAME OVER (A) | scan |

### PR-139 — µPB425, designator 51, caption DUMMY CAR / BRIDGE SIGNAL

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 8, 7, 6, 5 | A0–A3 | V0, V1, V2, V3 (each row ends on its bus label; dots for PR-138 A0–A3) | scan |
| 4 | A4 | V4 (dot 3182,4170 → riser to y≈2924 → IC28.2; dot 2510,4165 → IC26.13) | scan |
| 3, 2, 1, 23 | A5–A8 | H1, H2, H3, H4 | scan |
| 20, 21 | /CE1, /CE2 | GND | scan |
| 18, 19 | CE3, CE4 | Vcc | scan |
| 9–17 | D0–D7 | IC50.2, .3, .5, .6, .11, .10, .14, .13 | scan |

### IC50 — 74157, printed "157" (no designator printed; 50 from the redraw)

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 1 | S | H0? (E), row y≈4600 | scan; label U1 |
| 15 | /G | GND | scan |
| 4 | 1Y | IC56.9 (x≈3511 → y≈5589) | scan |
| 7 | 2Y | IC56.5 (x≈3595 → y≈5461) | scan |
| 12 | 4Y | IC9.1 | scan |
| 9 | 3Y | not drawn | scan |

### IC66 — 7411 3-input AND, one section, printed "66"

Drawn with no output bubble. Sheet D's IC66 (same board) is the 7411 the
real game settled; this section agrees. The redraw has 74LS10.

| Pins | Connection | Evidence |
|---|---|---|
| 10, 9, 11 → 8 | 10 IC59.8; 9 IC73.8; 11 IC65.1; 8 → IC9.2, and IC9.13 (dot) | scan |

### IC73 — 7427 3-input NOR, one section, printed "73"

| Pins | Connection | Evidence |
|---|---|---|
| 11, 9, 10 → 8 | 11 IC42.12; 9 Vs/16 (dot 2045,3840); 10 /GAME (B); 8 → IC66.9 | scan |

### IC65 — 7402 NOR, one section, printed "65"

| Pins | Connection | Evidence |
|---|---|---|
| 2, 3 → 1 | 2 /EXT. 500 (D); 3 V-④ (B) (dot 1531,4795); 1 → IC66.11 | scan |

### IC9 — 7400 NAND, two sections, printed "9"

| Section | Connection | Evidence |
|---|---|---|
| 1,2→3 | 1 IC50.12; 2 IC66.8; 3 → /SIG. (Y), and IC9.12 (dot 4245,4790) | scan |
| 12,13→11 | 12 IC9.3; 13 IC66.8; 11 → /SIG. (BL) | scan |

### IC53 — 74153, printed "53 (153)"

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 1 | /1G | H8 (E) (riser x≈2250 → row y≈4500) | scan |
| 15 | /2G | V-① (B) (riser x≈2330) | scan |
| 14 | A | IC46.3 | scan |
| 2 | B | IC46.2 | scan |
| 6 | 1C0 | GND (vertical x≈2123 to the GND dot at y≈5270; crosses the pin 5, 4, 3 rows at 11–13 px) | scan |
| 5 | 1C1 | H5 (riser x≈1828, dot 1828,5103) | scan |
| 4, 3 | 1C2, 1C3 | Vcc | scan |
| 10 | 2C0 | GND | scan |
| 11, 12 | 2C1, 2C2 | H6 (riser x≈1786, dot 1786,5307) | scan |
| 13 | 2C3 | IC39.8 | scan |
| 7 | 1Y | IC26.10 | scan |
| 9 | 2Y | IC26.9 | scan |

### IC39 — 7432 OR, two sections, printed "39"

| Section | Connection | Evidence |
|---|---|---|
| 10,9→8 (OR body) | 10 H5; 9 H6; 8 → IC53.13 | scan |
| 4,5→6 (AND body, bubbles on inputs and output) | 4 IC52.3; 5 pad E2 /EX. SIGNAL CP (A); 6 → IC46.5 | scan; numeral reads "37" or "39", the function and pins fit IC39 (U6) |

### IC52 — 7408 AND, three sections, printed "52"

The fourth section is on sheet B.

| Section | Connection | Evidence |
|---|---|---|
| 2,1→3 (drawn facing left) | 2 IC46.3; 1 IC46.2; 3 → IC39.4 | scan |
| 9,10→8 | 9 Vs/16 (row y≈4420 → riser x≈3260); 10 IC59.4; 8 → IC56.4, IC56.10 | scan |
| 13,12→11 | 13 Vcc; 12 V7 (E); 11 → the bridge mirror line (IC23.9, .5, .12, .2; IC28.1, .5; riser x≈6490) and IC16.1 | scan |

### IC46 — 74193, printed "(193) 46"

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 5 | UP | IC39.6 | scan |
| 4 | DOWN | IC59.2 | scan |
| 14 | CLR | /COIN IN (B), row y≈6000. Drawn with a bubble; the 74193 clear is active high | scan |
| 15, 1, 10, 9 | A–D | GND (joined at y≈5915) | scan |
| 11 | /LOAD | not drawn | scan |
| 3 | QA | IC53.14, IC52.2 | scan |
| 2 | QB | IC53.2, IC52.1 | scan |
| 6, 7 | QC, QD | not drawn | scan |
| 13 | /BO | IC59.5 | scan |
| 12 | /CO | not drawn | scan |

### IC26 — 7420 4-input NAND, one section, printed "26"

| Pins | Connection | Evidence |
|---|---|---|
| 12, 13, 10, 9 → 8 | 12 EXTEND (C) (riser x≈2551); 13 V4; 10 IC53.7; 9 IC53.9; 8 → /DUMMY AREA rail: C5 470 pF to GND (dot 2800,5205), IC59.3, IC21.2 (riser x≈6584, dot 6584,5233), arrow /DUMMY AREA (C) | scan |

### IC56 — 7400 NAND, two sections, printed "56"

| Section | Connection | Evidence |
|---|---|---|
| 4,5→6 | 4 IC52.8; 5 IC50.7; 6 → /DUMMY (W) (C), IC55.1 | scan |
| 10,9→8 | 10 IC52.8; 9 IC50.4; 8 → /DUMMY (R) (C), IC55.13 | scan |

### IC55 — 7410 3-input NAND, one section, printed "55"

| Pins | Connection | Evidence |
|---|---|---|
| 1, 13, 2 → 12 | 1 IC56.6; 13 IC56.8; 2 IC59.4; 12 → /DUMMY (BL) (C) | scan |

### IC15 — 7409 AND, two sections, printed "15"

| Section | Connection | Evidence |
|---|---|---|
| 13,12→11 (OR body, bubbles on inputs and output) | 13 V-⑤ (B); 12 V-③ (riser x≈6112 to the V-③ line y≈2260); 11 → IC10.12 | scan |
| 9,10→8 (AND body, pointing down) | 9 EXT. 500 (D); 10 IC11.4 (y≈2300); 8 → IC16.2, IC16.13 (riser x≈7545) | scan |

### PR-140, PR-141 — µPB425 (MPB-425 ×2), designators 12 and 17, captions BRIDGE No.1, No.2

| Pin | Function | Connection (both PROMs, pin for pin) | Evidence |
|---|---|---|---|
| 8 | A0 | IC23.8 (PR-140 row; riser x≈7257 to PR-141) | scan |
| 7 | A1 | IC23.6 (T at 7296,1122 on riser x≈7297) | scan |
| 6 | A2 | IC23.11 (T at 7336,1208) | scan |
| 5 | A3 | IC23.3 (T at 7379,1296) | scan |
| 4 | A4 | IC21.8 (T at 7421,1425) | scan |
| 3, 2, 1, 23 | A5–A8 | MH1, MH2, MH3, MH4 (B) (PR-141 rows to the labels; dots 7629,1687 / 7587,1729 / 7544,1771 / 7503,1812 to the PR-140 risers) | scan |
| 20, 21 | /CE1, /CE2 | PR-140: GND. PR-141: IC10.11 | scan |
| 18, 19 | CE3, CE4 | PR-140: IC10.11. PR-141: Vcc | scan |
| 9–17 | D0–D7 | shared; IC11.2, .5, .11, .14, .3, .6, .10, .13 (the risers cross the IC22 line y≈1941 at 8–10 px) | scan |

### IC23 — 7486 XOR, four sections, printed "23"

| Section | Connection | Evidence |
|---|---|---|
| 10,9→8 | 10 V0 (riser x≈6198); 9 mirror; 8 → A0 | scan |
| 4,5→6 | 4 V1 (x≈6238); 5 mirror (dot 6917,1138); 6 → A1 | scan |
| 13,12→11 | 13 V2 (x≈6281); 12 mirror (dot 6918,1220); 11 → A2 | scan |
| 1,2→3 | 1 V3 (x≈6321); 2 mirror (dot 6910,1307); 3 → A3 | scan |

The mirror line runs x≈6915 (y 1048–1307) → y≈1303 → x≈6617 → dot
(6617,1480) → x≈6490 → down to IC52.11 (dot 6475,3268).

### IC28 — 7486 XOR, two sections, printed "28"

| Section | Connection | Evidence |
|---|---|---|
| 2,1→3 | 2 V4 (riser x≈6364 to the V4 line y≈2938); 1 mirror (dot 6619,1395); 3 → IC21.11 | scan |
| 4,5→6 | 4 V6 (E); 5 mirror (dot 6617,1480); 6 → IC21.9 | scan |
| 9,10→8 and 12,13→11 | not drawn on this sheet | |

### IC21 — 7411 3-input AND, two sections, printed "21"

| Section | Connection | Evidence |
|---|---|---|
| 11,10,9→8 (OR body, bubbles on inputs and output) | 11 IC28.3; 10 V-② (B); 9 IC28.6; 8 → bridge A4 | scan |
| 1,2,13→12 (same form) | 1 V-④ (riser x≈6650, dot 6650,2270); 2 /DUMMY AREA; 13 /OTHER CAR (C); 12 → IC16.9 | scan |

### IC11 — 74157, printed "157 11"

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 1 | S | MH0 (B) | scan |
| 2, 5, 11, 14 | 1A–4A | bridge D0, D1, D2, D3 | scan |
| 3, 6, 10, 13 | 1B–4B | bridge D4, D5, D6, D7 | scan |
| 15 | /G | IC22.2 | scan |
| 4 | 1Y | IC6.15, IC15.10 (dot 7720,2300) | scan |
| 7 | 2Y | IC6.14 | scan |
| 9 | 3Y | IC6.13 | scan |
| 12 | 4Y | not drawn | scan |

### IC6 — 7442 BCD decoder, printed "42 6"

| Pin | Function | Connection | Evidence |
|---|---|---|---|
| 15, 14, 13 | A, B, C | IC11.4, .7, .9 | scan |
| 12 | D | IC16.8 | scan |
| 1 | 0 | /BRIDGE (Bu) (C) | scan |
| 2 | 1 | /BRIDGE (R) (C) | scan |
| 3 | 2 | /BRIDGE (Y) (C) | scan |
| 4 | 3 | open stub | scan |
| 5 | 4 | /BRIDGE (DBu) (C) | scan |
| 6 | 5 | /BRIDGE (W) (C), pad EH /BRIDGE (W) (F) (dot 8150,2700) | scan |
| 7, 9 | 6, 7 | open stubs | scan |
| 10, 11 | 8, 9 | not drawn | scan |

## Power and discretes

| Item | Reading | Evidence |
|---|---|---|
| Vcc pads | D19 ~ D22, DW ~ DZ (8 pads) | scan |
| GND pads | D1 ~ D5, DA ~ DE (12 pads) | scan |
| Vcc pads | F20 ~ F23, FX ~ F? (8 pads; last suffix reads "a") | scan, U7 |
| GND pads | F25 ~ F28, Fc ~ F? (8 pads; last suffix reads "8" or "g") | scan, U7 |
| Vcc bypass | three capacitors to GND: "10µ 16V"(?), "470µ ×2"(?), "0.1µ ×?"; note "µPB425用" (for the µPB425s) with an arrow to them | scan, values partly legible (U7) |
| C4 | 1.5 µF, IC18 6–7 | scan |
| R16 | ?7 kΩ, IC18.7 to Vcc | scan, U5 |
| C5 | 470 pF, /DUMMY AREA to GND | scan |
| C6 | 470 pF, IC42.8 / IC35.4 to GND | scan |
| C7 | 470 pF, IC44.6 to GND | scan |
| C9 | 470 pF, IC43.1 to GND | scan |
| unlabelled | 470 pF, /LOAD (IC36.9, IC37.9) to GND | scan |
| unlabelled | 470 pF, IC37.15 / IC57.9 to GND | scan |

## Differences from the redraw

The scan is used in every case.

| Item | Redraw | Scan |
|---|---|---|
| PR-138.7 (A1) | not connected | V1 |
| IC66 | 74LS10 (NAND) | AND, no output bubble: 7411, as on sheet D |
| IC35.12 (lower D) | net "S-100-D" | 100-C (D) |
| IC35.6 (upper /Q) | not connected | IC60.1 |
| IC60.1 | not connected | IC35.6 |
| IC35.8 (lower /Q) | not connected | IC42.9 |
| IC42.9 | not connected | IC35.8 |
| IC42.1 | not connected | H6 |
| IC47.9, .10, .8 | not connected | IC45.8; Vs/64; IC35.11 |
| IC45.8, IC35.11 | not connected | IC47.9; IC47.8 |
| IC6 pad for /BRIDGE (W) | EG | EH (sheet F receives it on BH; cable straight) |
| IC7 | 74LS06 | type not printed |

## Corrections to the first pass (23 October)

- The "(107/2)" JK flip-flop is **IC57** (its other half is sheet B's MH8
  stage), not IC52.
- PR-139's five "drops" are the risers of PR-138 A0–A3 (and the V4 tap)
  joining the V-bus rows: PR-139 is V0–V4, H1–H4 throughout, and PR-138
  shares V0–V3 (old U1, U2 closed).
- The bridge PROMs share every address pin pair for pair; there is no
  offset between them (old U3 closed). A0–A3 are V0–V3 XOR V7, A4 is IC21.8,
  A5–A8 are MH1–MH4.
- IC15 is an AND drawn as an OR body with bubbles on the inputs and the
  output (old U8 closed); its inputs are V-⑤ and V-③, and the label read
  "B-AREA" is /0-AREA (D).
- The "155" multiplexer is printed "157" (designator not printed; IC50).
- EXT. CAR CONT on pad EX goes to (F) (old U10 closed); its driver is IC49 QB.
- IC46 DOWN is driven by EXPLO. SEL. D through IC59; UP by /EX. SIGNAL CP
  through IC39 (old U12 closed). IC53's tie pattern is read in full (old U11 closed).
- The bridge output column is read in full (old U9 closed); the pads are EH,
  F4 and F5.

## Unresolved

1. **U1 — the bus row at y≈4595** (IC50.1). Its subscript is damaged under
   the end of the (E) brace: H0 or H8. H8 already has its own row (y≈4483,
   to IC53.1), and sheet E sends H0 to (M); H0 is the likely reading.
   Crop (1180,4560,1340,4630).
2. **U2 — PR-138.23's label** (row y≈1320). Circled B, then a glyph like
   "V" with a small subscript, "/4". Read as Vs/4; sheet H sends Vs/4 on
   pad BY, which the cable table joins to EW, but no pad is drawn here.
   Crop (1150,1280,1400,1360).
3. **U3 — CAR. NO. CONT (D)**: no overbar is visible on this label, while
   sheet D names its output /CAR NO CONT. The wiring is unaffected.
   Crop (1050,4620,1380,4670).
4. **U4 — EXT. 500 (D)** at IC15.9, unbarred. Sheet D's trace sends its
   unbarred EXT. 500 (IC25 Q) to (H) only and /EXT. 500 (IC25 /Q) to (M);
   sheet M draws both. The circled letter on sheet D may be an M read as H
   (the guide's M/H warning); to be checked there. Crop (5560,2460,5960,2530).
5. **U5 — R16's value**: first digit blotted, "?7K"; 47 kΩ likely.
   Crop (2950,3220,3150,3330).
6. **U6 — IC39's lower section numeral** reads "37" or "39"; the drawn
   function (OR) and pins 4, 5, 6 fit IC39 (sheet D uses its 12,13→11).
   Crop (1820,5640,1960,5740).
7. **U7 — power-pad suffixes and capacitor values** (F-side last pads,
   the three bypass capacitors). They carry no logic.
