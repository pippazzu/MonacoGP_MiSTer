# Sheet G: headlight, explosion and splash paths

Source: Sega **Monaco GP (420-0358)** manual, PDF page **27**,
`schematics/pages/page27-sheet-G.png` (10160 × 6624, stored upright): board
96577-P, drawing G, sheet D3/4. The title reads マイカー、ヘッドライト、爆発、オイル
スリップ絵出し: the pictures of the player's car, the headlight, the explosion
and the oil-slip splash.

The player-car path (PR-127..PR-130, the line and pixel counters, the
windows, IC38/IC119/IC19/IC51 latches 1–2) is in
[SHEET_G_PLAYER.md](SHEET_G_PLAYER.md). This file covers the rest of the
sheet: PR-125 with IC53/IC58 (headlight), PR-126 with IC64 (explosion),
PR-131 with IC70 (splash), IC51 latches 3 and 4, IC74 and the gates around
them. Positions are pixels of the stored image. HC0..HC7 and VC0..VC7 are
the player's pixel and line counters (IC52, IC54), HWIN is IC57a pin 6 and
IC56 pin 6 is NAND(VWIN, HWIN), all as in SHEET_G_PLAYER.md.

How it was read: the KiCad redraw (stonedDiscord) was netlisted only to list
pins to follow. Every connection below was followed on the scan with a
stroke walker (it follows one wire and reports each crossing with the size
of the ink disc there: junction dots measure 16–22 px, plain crossings 8–14
px) and checked by eye on zoomed crops. Gate functions follow the symbols,
read as in SHEET_G_PLAYER.md.

## Inputs used by these paths

| Signal | From | Where it enters | Goes to |
|---|---|---|---|
| /ACC1 | (F) | top-left input row, y ≈ 1064 | PR-125 pins 18, 19 (dot at 4662,1078) |
| EXPLO.ST | (F) | arrow from the top, x ≈ 5921 | PR-126 pins 18, 19; IC62 pin 10 (dot at 5912,2598) |
| /EXPLO.ST | (F) | arrow from the top, x ≈ 8257 | IC74 pin 3 (dot at 8257,1267) |
| EXPLO.SEL A, B, C, D | (F) | four arrows from the top, x ≈ 6137, 6180, 6223, 6266 | A: PR-126 pin 1, IC63 pin 9; B: PR-126 pin 23; C: IC63 pin 8; D: IC74 pin 4 |
| /SPLAY A | (F) | bottom-left arrow, y ≈ 5605 | PR-131 pin 1 |
| SPLAY B | (F) | bottom-left arrow, y ≈ 5645 (no overbar legible; sheet F labels its source /SPLAY B, U3) | IC45 pin 11 |
| /TUNNEL | (F) | bottom-left arrow, y ≈ 5440 | IC57b pin 13 |
| /COIN IN | (A) | bottom-left arrow | IC57a (HWIN), as in SHEET_G_PLAYER.md |

## Headlight (PR-125, "LIGHT")

| Part / pin | Connection |
|---|---|
| PR-125 (IC59, 7641) pins 20, 21 (/CE1, /CE2) | ground |
| PR-125 pins 18, 19 (CE4, CE3) | /ACC1 (F) |
| PR-125 pins 8, 7, 6, 5, 4 (A0..A4) | VC0..VC4: verticals at x ≈ 4315, 4273, 4231, 4188, 4144 to the bus rows y ≈ 1514, 1559, 1601, 1643, 1687 that also feed PR-127 pins 8..4 |
| PR-125 pin 3 (A5) | VC5 (vertical x ≈ 4102 to the row y ≈ 1901, which also feeds IC45 pin 2) |
| PR-125 pin 2 (A6) | VC6 (vertical x ≈ 4059 to the row y ≈ 1945, which also feeds IC48 and IC46 pin 3) |
| PR-125 pin 1 (A7) | IC46 pin 8 (vertical x ≈ 4001) |
| PR-125 pin 23 (A8) | ground |
| PR-125 pins 9, 10, 11, 13 (D0..D3) | IC53 pins 9, 11, 14, 1 (B0..B3) |
| PR-125 pins 14, 15, 16, 17 (D4..D7) | IC58 pins 9, 11, 14, 1 (B0..B3) |
| IC53 (7485) pins 10, 12, 13, 15 (A0..A3) | HC0..HC3 (IC52 pins 3, 4, 5, 6; dots on the HC rows at y ≈ 4731..4861) |
| IC58 (7485) pins 10, 12, 13, 15 (A0..A3) | HC4..HC7 (IC52 pins 11, 10, 9, 8) |
| IC53 pins 2, 4 (A<B, A>B in) | Vcc |
| IC53 pin 3 (A=B in) | IC46 pin 10 |
| IC53 pin 6 (A=B out) | IC58 pin 3 (A=B in) |
| IC58 pins 2, 4 | Vcc |
| IC58 pin 6 (A=B out), "EQ" below | 470 pF to ground (label rotated, partly legible); IC56 pins 12 and 10 |
| IC46 (7404) pins 11 -> 10 | NOT VC7 (row y ≈ 1981) |
| IC57b (7425) pins 12, 10, 9, 13 -> output (pin number not drawn) | NOR(HC5, HC6, HC7, /TUNNEL), "W" below; the strobe (pin 11) is not drawn |
| IC46 pins 9 -> 8 | NOT W -> PR-125 A7, IC56 pin 13 |
| IC56 (7400) pins 13, 12 -> 11 | NAND(/W, EQ) -> IC51 pin 12 (/S2) |
| IC56 pins 10, 9 -> 8 | NAND(EQ, W) -> IC51 pin 10 (/R); 470 pF to ground on the line |
| IC66 pin 3 | AND(/ACC1, IC119 /Q) (SHEET_G_PLAYER.md) -> IC51 pin 11 (/S1) |
| IC51 (74279) latch 3, pin 9 (Q) | /LIGHT: C22 470 pF to ground, pad BC to (C) |

**Behaviour.** PR-125 holds, for each of the 128 lines VC 0..127 (A0..A6),
a start column (A7 = 0) and an end column (A7 = 1). The comparator pair
gives EQ while HC equals the selected byte and VC7 is low. W is high for
HC 0..31 only while /TUNNEL is low. Inside W a match resets the latch
(/LIGHT low: light on); outside W a match sets it (light off). /S1 sets it
whenever the player PROM PR-127 is off (an accident or a slide). Outside the
tunnel W never rises, so the light never switches on. The start columns are
1..30 and the end columns 33..122; drawn, the table is a cone, widest
(columns 1..122) at VC ≈ 56..72, the car's own lines.

## Explosion (PR-126, 爆発)

| Part / pin | Connection |
|---|---|
| PR-126 (IC65, 7641) pins 20, 21 | ground |
| PR-126 pins 18, 19 | EXPLO.ST (F) |
| PR-126 pins 8, 7, 6, 5, 4 (A0..A4) | VC0..VC4 (the rows that run on to PR-130 pins 8..4) |
| PR-126 pin 3 (A5) | HC3 (its row ends at the dot on the vertical x ≈ 6677, which feeds PR-130 pin 2) |
| PR-126 pin 2 (A6) | HC4 (row ends at the vertical x ≈ 6635, upper segment, which feeds PR-127..PR-129 pin 1; that vertical is broken at y ≈ 3085) |
| PR-126 pin 1 (A7) | EXPLO.SEL A (dot at 6121,3113 on the vertical x ≈ 6125) |
| PR-126 pin 23 (A8) | EXPLO.SEL B (vertical x ≈ 6169) |
| PR-126 pins 9, 10, 11, 13, 14, 15, 16, 17 (D0..D7) | IC64 pins 4, 3, 2, 1, 15, 14, 13, 12 (D0..D7) |
| IC64 (74151) pins 11, 10, 9 (A, B, C) | HC0, HC1, HC2 (the rows that also reach IC76 pins 14 and 2, and the vertical x ≈ 6717 that feeds PR-130 pin 3) |
| IC74 (7427) pins 5, 4, 3 -> 6 | NOR(IC56 pin 6, EXPLO.SEL D, /EXPLO.ST) |
| IC44 (7404) pins 3 -> 4 | NOT IC74 pin 6 -> IC64 pin 7 (/G) |
| IC64 pin 5 (Y) | IC56 pin 2 |
| IC64 pin 6 (/W) | /EXPLO AREA, pad C15 to (C); IC62 pin 12 |
| IC63 (7402) pins 9, 8 -> 10 | NOR(EXPLO.SEL A, EXPLO.SEL C) -> IC56 pin 1, IC62 pin 13 |
| IC56 pins 1, 2 -> 3 | NAND(IC63 pin 10, Y) -> /EXPLO (Y), pad B4 to (C) |
| IC62 (7432) pins 12, 13 -> 11 | OR(/W, IC63 pin 10) -> /EXPLO (R), pad BK to (C) |

**Behaviour.** While EXPLO.ST is high and EXPLO.SEL D low, inside the
player's 32 × 32 window, IC64 picks bit HC0..HC2 of the PR-126 byte at
{SEL B, SEL A, HC4, HC3, VC4..VC0}: four 32 × 32 frames. /EXPLO AREA is low
on a set pixel. The pixel is yellow (/EXPLO (Y)) while SEL A and SEL C are
both low and red (/EXPLO (R)) otherwise. Drawn with the player window's line
order (VC 0x30..0x4F, rows 16..31 first), the frames are a small burst, a
larger burst, a cloud and scattered debris.

## Splash (PR-131)

| Part / pin | Connection |
|---|---|
| PR-131 (IC71, 7641) pins 20, 21 | ground |
| PR-131 pins 18, 19 | Vcc |
| PR-131 pins 8, 7, 6, 5, 4 (A0..A4) | VC0..VC4 (verticals x ≈ 7008, 6968, 6926, 6884, 6843 to the PR-127 bus rows) |
| PR-131 pin 3 (A5) | HC3 (vertical x ≈ 6677) |
| PR-131 pin 2 (A6) | HC4 (lower segment of the vertical x ≈ 6635, which also feeds PR-130 pin 1) |
| PR-131 pin 1 (A7) | /SPLAY A (F), straight along y ≈ 5605 |
| PR-131 pin 23 (A8) | VC6 (vertical x ≈ 6540 to the row y ≈ 1945) |
| PR-131 pins 9, 10, 11, 13, 14, 15, 16, 17 | IC70 pins 4, 3, 2, 1, 15, 14, 13, 12 (D0..D7) |
| IC70 (74151) pins 11, 10, 9 | HC0 (vertical x ≈ 6800, dot at 6800,3404), HC1 (x ≈ 6756, dot at 6754,3452), HC2 (row ends on x ≈ 6717) |
| IC48 (7400) pins 12, 13 -> 11 | NAND(VC4, VC5) -> IC51 pin 14 (/R) |
| IC44 pins 13 -> 12 | NOT VC5 (the label reads 44; the redraw has IC46 pins 13 -> 12, U1) |
| IC48 pins 5, 4 -> 6 | NAND(/VC5, VC4) -> IC51 pin 15 (/S) |
| IC51 latch 4, pin 13 (Q) | IC45 pin 10 |
| IC45 (7410) pins 10, 9, 11 -> 8 | NAND(IC51 pin 13, HWIN, SPLAY B) -> IC70 pin 7 (/G) |
| IC70 pin 6 (/W) | /SPLAY, pad B10 to (C) |

**Behaviour.** Latch 4 is set at VC4 & /VC5 and reset at VC4 & VC5; VC
stops at 0x80, so it is high for VC 0x10..0x2F and 0x50..0x6F, the 32 lines
on each side of the car's own (VC 0x30..0x4F). With HWIN, IC70 is enabled in
those two 32 × 32 areas while SPLAY B is high, and /SPLAY is low on a set bit
of the PR-131 byte at {VC6, /SPLAY A, HC4, HC3, VC4..VC0}. VC6 picks the
page for each side; /SPLAY A picks blobs (low) or thin streaks (high).

## Outputs to sheet C

| Pad | Signal | Sheet C pad (E–B and F–C straight here) |
|---|---|---|
| BC | /LIGHT | EC |
| BK | /EXPLO (R) | EK |
| B4 | /EXPLO (Y) | E4 |
| C15 | /EXPLO AREA | F15 |
| B10 | /SPLAY | E10 (the sheet C log's reading "SPLAY"/"SPRAY" is SPLAY here) |

## Differences from the redraw

- PR-125 pins 18, 19 (/ACC1) and pin 23 (ground) agree; the redraw's PROM
  symbol numbers the other pins differently, so its PROM pin numbers were
  not used.
- IC70 pin 7 is IC45 pin 8 in both; IC45 pin 9 (HWIN) and pin 10 (IC51
  pin 13) agree.
- IC57b pin 9: the redraw leaves it open; the scan has HC7 (dot at
  4011,5195).
- The inverter on the splash latch's set side reads IC44 (13 -> 12) on the
  scan, IC46 in the redraw (U1).
- The redraw lists C46 (470 pF) on the IC46 pin 8 net; the scan shows no
  capacitor there.

## Unresolved

1. **U1:** the designator of the inverter VC5 -> IC48 pin 5 (44 on the scan,
   46 in the redraw). Its function is not in doubt.
2. **U2:** the value of the capacitor on IC58 pin 6 is rotated and partly
   legible (470 pF, as the others on the sheet).
3. **U3:** the overbar on "SPLAY B". Sheet F names its source /SPLAY B
   (IC49 Q, high during IC49's pulse); IC45 needs it high to enable the
   splash, which matches the pulse.
4. **Timing:** the comparators see the ripple states of the 74393 counters;
   the 470 pF capacitors on EQ and on the latch's /R filter them. A model
   should act on settled counts.
5. IC57b's output pin number and strobe are not drawn (pin 8 and an open
   pin 11 on a 7425).

## Artwork check

With the address and data mapping above, the PROM contents draw coherent
pictures: PR-125 a symmetric cone (start columns 30 → 1 → 18, end columns
33 → 122 → 45 over VC 0..127); PR-126 four explosion frames; PR-131 two
splash pages (blobs) and two streak pages. The rows 0..15 / 16..31 swap that
the player window causes for PR-127..PR-130 shows the same way here.
