# Sheet D — scenery PROM paths and state-network continuation

Source: Sega **Monaco GP (420-0358)**, PDF page **31**, drawing **D**, board **96578-P**, sheet **D3/5**, IC BOARD ASSY. B. Source image: `sheets/page31-sheet-D.png`, **10160 × 6624** pixels, as supplied in the handover archive. Updated: 29 October 2026.

**Status: transcription reviewed on 22 October and consolidated into one pin list on 29 October (next section); the two gates the scan leaves ambiguous, IC66 and IC90, are settled by the real game.** The rest of this paragraph describes the original transcription, a partial sheet transcription updated through continuation 5: This section covers the address-selection path through IC92/IC67, PR134–PR137 and their output multiplexers, IC97, the right-edge pixel-output gates, and the immediate `/SLIDE` circuit. It also identifies control-driver endpoints needed by these blocks. Continuations 2–5 add the input/state and counter blocks, IC96, the upper address-decode gates, central enable paths, lower IC80/IC87/IC73/IC94 gates, the ROAD flip-flop and the remaining peripheral control-output routes. Several long-wire junctions, additional fanouts and damaged readings remain **unresolved**. A `clear` downstream connection does not certify an untraced upstream circuit. The exact stopping boundary and continuation work are listed at the end.

This is a transcription, not an implementation or a hardware validation. No PROM contents, emulator, other core, or expected game behaviour were used to fill gaps. The layout of `reference/docs/trace/SHEET_G_PLAYER.md` is the model; its claims of independent review and simulation do not apply here.

Source PNG SHA-256: `f49fd4a73ffeada946d68be33a23b47706dbd28470c57c8319aa791e264f1856`.

## Consolidated netlist, 29 October 2026

The tables further down are spread over five continuations and the 22
October review. This section gathers the result in one place. It is the
netlist that `cores/monacogp/hdl/jtmonacogp_scenery.v` and
`tests/sheet_d_reference.v` implement ([SHEET_D_LOGIC.md](../SHEET_D_LOGIC.md)).

### How it was made

1. Every connection in the tables below, with the 22 October corrections
   applied, was taken into one pin list of the 51 packages drawn on the
   sheet.
2. That list was compared, pin by pin, with the pad nets of stonedDiscord's
   KiCad redraw of board 96578 (`Video.kicad_pcb`). The redraw was used only
   for the comparison, as before. After the review's corrections the two
   agree on every connection except the ones listed under "Found on 29
   October" below. Each of those was checked on the scan.
3. Pin numerals were not all re-read. Where a numeral is faded (IC105,
   IC106, the PROM pads, IC90 and IC94), the tables give the pad position.
   The standard pinout of the drawn part agrees with that position and with
   the redraw.

The off-sheet nets are the same as the redraw's: /MHL0 is sheet B's /MHLD
(IC55 pin 8); /HS is pad FJ; /V8 is pad FN (sheet E IC114 pin 2); V7 is pad
EN (sheet E IC100 pin 11); /COIN IN is pad ED; /M1VL0 and /M2VL0 are sheet
B's R1 and R2 (IC62 pins 4 and 8).

### Found on 29 October

- **IC34 pin 4 is /TUNNEL & BRIDGE to sheet B**, and it is a separate net
  from IC31 pin 8 (/TUNNEL, pad EF). The label under the IC34 pin 4 wire
  reads `/TUNNEL &` over `BRIDGE` (faint), with a circled B: it is sheet B's
  IC95 pin 9 input. The redraw puts IC34 pin 4, IC31 pin 8, IC38 pin 12, IC80
  pin 11 and pad EF on one net, which would join two outputs. On the scan
  the IC34 pin 4 wire runs down near x=3270 to its own label. The IC31 pin 8
  rail runs near x=3840 to EF. Box (3100,5500,3950,6400).
- **/0-AREA goes to sheet M**, not H: the circled letter under the label is
  M. Box (5750,5900,5900,6300).
- **IC94 pin 8 is /GREEN BELT (C)**, not a label ending in SLIP. The /SLIP
  (C) arrow beside it is a branch of IC59 pin 12 (dot at (5740,5820)).
  **IC87 pin 11 is /Y-LINE (C).** Box (4950,5650,5950,6350).
- **IC66 is an AND (7411), settled by the real game.** On the scan the gate
  is ambiguous. The 22 October review (correction 10) read a NAND whose
  output bubble is overwritten by the numeral 6, and the redraw has a
  74LS10. Read again at 7×:
  - the upper arc of the body ends at (5560,3215); the lower arc is eroded
    and stops near (5545,3255);
  - the numeral 6 sits above the tip;
  - the output wire starts at x≈5572, about 10 px after the body. A NAND on
    this sheet (IC94 pin 8) has its wire start a full bubble, about 30 px,
    after the body. A plain AND (IC87 pin 6, labelled WALL) has its wire
    start at the tip;
  - the output net is labelled GRAVEL without a bar, as IC87's WALL is.
  The two readings give different pictures:
  - NAND: /GRAVEL is active wherever PR-137's first selected bit is set,
    except in the GRAVEL flip-flop's zone, so PR-137's speckle covers the
    road;
  - AND: /GRAVEL is active only inside that zone, and the road is plain.
  On 29 October the maintainer compared the simulated pictures with the real game: it
  shows the AND picture. Correction 10 is withdrawn. The RTL and the
  reference keep a parameter (IC66_NAND, default 0 = AND) so that the other
  reading can still be simulated. The pictures are in
  the working notes (not published).
- **IC90 is a 7425 (both sections NOR), settled by the real game.** The
  drawing shows one section as an AND and the other as a NOR (see the
  review); the photo of the 97092-P board pointed to 7425. Read as drawn,
  IC81 pin 11 (/R-SIDE) is low at M1V = 0xFF and IC81 pin 3 (/L-SIDE) at
  M2V = 0xEC. With 7425: 0x1B and 0xEC. With 7421: 0xFF and 0xFB. In the
  simulated pictures the readings differ in the green verge (/GREEN BELT)
  beside the road: as drawn, left side only; 7425, both sides; 7421, right
  side only (the working notes (not published)). On 29 October
  the maintainer compared them with the real game, which has verges on both sides.
  The RTL and the reference keep the parameter (IC90_TYPE, default 1 =
  7425) so that the other readings can still be simulated.
- **IC32**: the redraw's 74LS21 (AND) is wrong, as the review says. The
  drawing is an OR body with an output bubble. Read as a 7425 section, its
  strobe pin 3 is not drawn and floats high.
- **IC94's middle input** is pin 3 (IC96 pin 1), as the 7410 pinout and the
  redraw have it.
- Parts whose /PR, /CLR or strobe pins are not drawn are taken as having
  them inactive (an open TTL input reads high): IC40 lower half (/PR, /CLR),
  IC38 POOL half (/PR, /CLR), the /PR of every other 7474 half, IC32's strobe
  and IC90's strobes (7425 reading).

### Pin list

`ICn.p` is pin p of IC n. A net named by a label carries that label;
other nets are named by their driving pin.

| IC | Part (as drawn) | Connections |
|---|---|---|
| 24 | 7442 | 15 S-100-A, 14 S-100-B, 13 S-100-C (also 100-C to (M)), 12 S-100-D (each with a 560 Ω pull-up in RA1); outputs 1 → 40.3; 2 → 47.4; 3 → 31.3; 5 → 25.11; 6 → 25.3, /CAR NO CONT (F3, (H), (M)); 7 → 47.5; 9 → 31.11 |
| 47 | 7408 | 1 Vcc, 2 /HS → 3 (HSB) → 40.12, 48.4, 48.12, 41.3, 41.2, 41.1, 41.15, 41.14, 41.13; 4 24.2, 5 24.7 → 6 → 38.11; 12 49.9, 13 49.8 → 11 → 34.8 |
| 34 | 7402 | 8 47.11, 9 /COIN IN (470 pF to ground) → 10 → 40.1, 31.1, 31.13, 25.1; 6 31.9, 5 25.5 → 4 /TUNNEL & BRIDGE (B); 11 112.7, 12 105.9 → 13 /TREE & GRASS (BL) (C) |
| 40 | 7474 | upper: 1 34.10, 2 EXTEND, 3 24.1, 5 → 32.1, 6 → 73.4; lower: 12 HSB, 11 /MHL0, 9 → 38.3, 8 → 49.13, 45.1 (470 pF to ground) |
| 38 | 7474 | POOL: 2 38.9, 3 40.9, 5 → 45.2, 6 → 31.2, 89.4; other: 12 /TUNNEL (31.8), 11 47.6, 13 45.3, 9 → 38.2 (8 not drawn) |
| 31 | 7474 | SLIP: 1 34.10, 2 38.6, 3 24.3, 5 → 32.5, 6 → 31.12, 73.1; TUNNEL: 13 34.10, 12 31.6, 11 24.9, 9 → 32.2, 34.6, 8 → /TUNNEL (EF, (F), (G)), 80.11, 38.12 |
| 25 | 7474 | lower: 1 34.10, 2 25.9, 3 24.6, 5 → 32.4, 34.5, 6 → 80.2; upper: 13 45.3, 12 EXTEND, 11 24.5, 9 → 25.2, EXT. 500 (H), 8 → /EXT. 500 (M), EJ (F) |
| 45 | 7400 | 1 40.8, 2 38.5 → 3 → 38.13, 25.13 |
| 32 | 7425 section | 5 31.5, 2 31.9, 4 25.5, 1 40.5 → 6 → 49.12 |
| 49 | 74393 half | 13 40.8, 12 32.6; QA 11 → 48.11, 41.11; QB 10 → 39.12; QC 9 → 39.13, 47.12; QD 8 → 47.13, 48.9, 41.9 |
| 39 | 7432 | 12 49.10, 13 49.9 → 11 → 48.10, 41.10 |
| 48 | 74151 | D0 4 HSB, D1 3 /MHL0, D2–D6 (2, 1, 15, 14, 13) Vcc, D7 12 HSB; 7 GND; 5 → 68 /S |
| 41 | 74151 | D0 4 Vcc, D1–D6 (3, 2, 1, 15, 14, 13) HSB, D7 12 /MHL0; 7 GND; 5 → 68 /R |
| 68 | 74279 latch | /S 48.5, /R 41.5 (pins not drawn; the redraw has latch 2, pins 6, 5, 7); Q → 56.1, 73.3, 73.13, 80.3, 80.12 |
| 78 | 7420 | 1 M1V0, 2 M1V1, 5 M1V3, 4 M1V4 → 6 → 82.13; 13 M2V3, 9 M2V5, 10 M2V6, 12 M2V7 → 8 → 82.1 |
| 90 | open (see above) | 13 M1V2, 12 M1V5, 10 M1V6, 9 M1V7 → 8 → 81.12; 2 M2V0, 1 M2V1, 4 117.4, 5 M2V4 → 6 → 81.2 |
| 117 | 7404 | 3 M2V2 → 4 → 90.4; 1 87.6 → 2 → PR-137 pin 23 |
| 82 | 7404 | 1 78.8 → 2 → 81.1; 3 M2V6 → 4 → 75.11; 5 M2V5 → 6 → 75.5; 9 96.1 → 8 → 81.9, 65.11; 11 89.12 → 10 → 66.4, /0-AREA (M); 13 78.6 → 12 → 81.13 |
| 81 | 7400 | 13 82.12, 12 90.8 → 11 /R-SIDE (FD, (H)) → 87.13, 88.11; 1 82.2, 2 90.6 → 3 /L-SIDE (FC, (H)) → 87.12, 88.13; 4 65.13, 5 87.8 → 6 → 112.1, 112.15; 9 82.8, 10 87.8 → 8 /HOUSE ST (C) → 98.15 |
| 88 | 7474 | upper: 2 MH6, 3 MH5, 1 95.11, 6 → 89.3 (Q not drawn); lower: 12 /V8, 11 81.11, 13 81.3, 9 → 96.12, 104.2, 8 /M-ROAD → 58.2, 73.2, 73.5, 94.10 |
| 74 | 7474 half (pins not numbered) | D /V8, CK /M1VL0, /CLR /M2VL0; Q ROAD ((C), E7 (F)) → 94.11; /Q /ROAD (C) → 87.4, 87.10 |
| 96 | 7442 | 15 MH5, 14 MH6, 13 MH7, 12 88.9; outputs 1 → 82.9, 94.3; 3 → 110.4; 5 → 110.5; 6 → 95.5; 7 → 95.4 |
| 89 | 7427 | 1 MH5, 2 MH6, 13 MH7 → 12 → 82.11; 3 88.6, 4 38.6, 5 75.8 → 6 → 89.9, 72.10; 9 89.6, 10 87.6, 11 104.6 → 8 → 119.1, 119.15 |
| 95 | 7408 | 4 96.7, 5 96.6 → 6 → 104.12; 12 MH8, 13 MH7 → 11 → 88.1 |
| 104 | 7432 | 1 V7, 2 88.9 → 3 → 92.1, 67.1; 4 80.10, 5 66.6 → 6 → 89.11; 9 MH4, 10 67.7 → 8 /SIDE LINE (C); 13 MH8, 12 95.6 → 11 → 56.2 |
| 56 | 7400 | 2 104.11, 1 68 Q → 3 → 65.12, 56.12; 12 56.3, 13 87.8 → 11 /GRASS AREA (C) → 105.1, 105.15 |
| 65 | 7402 | 12 56.3, 11 82.8 → 13 → 81.4; 5 58.3, 6 58.6 (470 pF to ground) → 4 /SLIDE (FR, (G)) |
| 110 | 7400 | 4 96.3, 5 96.5 → 6 → 110.9; 9 110.6, 10 MH8 → 8 → PR-134 pin 23 |
| 80 | 7402 | 2 25.6, 3 68 Q → 1 BRIDGE AP ((C), F18) → 80.6, 22.5, 58.5; 11 31.8, 12 68 Q → 13 TUNNEL AP (C) → 80.5, 87.5; 6 80.1, 5 80.13 → 4 → 87.9, 94.5, 94.9; 9 94.6, 8 94.8 → 10 → 104.4, 58.12 |
| 22 | 7404 | 3 105.9 → 4 /GRASS (W) (C); 5 80.1 → 6 /BRIDGE AP → 58.1 |
| 87 | 7408 | 4 /ROAD, 5 80.13 → 6 WALL → 72.1, 117.1, 89.10; 10 /ROAD, 9 80.4 → 8 → 81.5, 81.10, 56.13; 13 81.11, 12 81.3 → 11 /Y-LINE (C) → 94.4 |
| 94 | 7410 | 4 87.11, 3 96.1, 5 80.4 → 6 → 80.9; 9 80.4, 11 ROAD, 10 /M-ROAD → 8 /GREEN BELT (C) → 80.8 |
| 73 | 7427 | 4 40.6, 3 68 Q, 5 /M-ROAD → 6 → 66.5; 1 31.6, 13 68 Q, 2 /M-ROAD → 12 SLIP → 59.13 |
| 59 | 7404 | 13 SLIP → 12 /SLIP ((C), FA (F)) |
| 75 | 7410 | 3 M2V6, 4 M2V7, 5 82.6 → 6 → 66.3; 9 M2V5, 11 82.4, 10 M2V7 → 8 → 89.5 |
| 66 | 7410 or 7411 (see above) | 3 75.6, 4 82.10, 5 73.6 → 6 GRAVEL → 72.12, 104.5 |
| 92 | 74157 | 1 104.3, 15 GND; 2 M1V0, 3 M2V0 → 4 AV0; 5 M1V1, 6 M2V1 → 7 AV1; 11 M1V2, 10 M2V2 → 9 AV2; 14 M1V3, 13 M2V3 → 12 AV3 |
| 67 | 74157 | 1 104.3, 15 GND; 2 M1V4, 3 M2V4 → 4 AV4; 5 /M1VL0, 6 /M2VL0 → 7 → 104.10 |
| 113 | PR-134 | 8..4 AV0..AV4, 3 MH2, 2 MH3, 1 MH4, 23 110.8; 18, 19 Vcc, 20, 21 GND; 9, 10, 11, 13 → 112.6, 5, 4, 3; 14..17 → 112.10..13 |
| 112 | 74153 | 14 MH0, 2 MH1, 1 and 15 81.6; 7 → 34.11; 9 → 60.9 |
| 106 | PR-135 | 8..4 AV0..AV4, 3 MH2, 2 MH3, 1 MH4, 23 GND; enables as PR-134; 9, 10, 11, 13 → 105.6, 5, 4, 3; 14..17 → 105.10..13 |
| 105 | 74153 | 14 MH0, 2 MH1, 1 and 15 56.11; 7 → 60.10; 9 → 34.12, 22.3 |
| 99 | PR-136 | 8..4 AV0..AV4, 3 MH1, 2 MH2, 1 MH3, 23 MH4; enables as PR-134; 9, 10 → 98.2, 3; 11, 13 → 98.5, 6; 14, 15 → 98.11, 10; 16, 17 → 98.14, 13 |
| 98 | 74157 | 1 MH0, 15 81.8; 4 → 97.15; 7 → 97.14; 9 → 97.13; 12 not drawn |
| 97 | 7442 | 15, 14, 13 as above, 12 GND; 2 /HOUSE (R), 3 /HOUSE (Mu), 4 /HOUSE (St), 5 /HOUSE (W), all (C) |
| 120 | PR-137 | 8..4 AV0..AV4, 3 MH2, 2 MH3, 1 MH4, 23 117.2; enables as PR-134; 9, 10, 11, 13 → 119.6, 5, 4, 3; 14..17 → 119.10..13 |
| 119 | 74153 | 14 MH0, 2 MH1, 1 and 15 89.8; 7 → 72.2, 72.13, 58.13; 9 → 72.9 |
| 60 | 7427 | 9 112.9, 10 105.7, 11 58.11 → 8 /TREE & GRASS (G) (C) |
| 58 | 7408 | 2 /M-ROAD, 1 /BRIDGE AP → 3 → 65.5; 5 BRIDGE AP, 4 V-(4) → 6 → 65.6; 13 119.7, 12 80.10 → 11 → 60.11 |
| 72 | 7400 | 9 119.9, 10 89.6 → 8 /POOL ((C), FM (F)); 2 119.7, 1 87.6 → 3 /WALL (C); 13 119.7, 12 66.6 → 11 /GRAVEL ((C), F14 (G)) |

## Review by Claude, 22 October 2026

This trace was written by ChatGPT from the handover package and reviewed by
Claude against the same image (manual 420-0358, PDF page 31, same
SHA-256). Every pin-to-pin link was first compared with stonedDiscord's KiCad
redraw of board 96578 (github.com/stonedDiscord/MonacoGP, no licence, used
only for comparison): 356 links agreed and 50 differed, and the bus labels
on 61 pins were compared the same way. Each difference, the gate bodies whose
function the trace left open, and the open junctions C1, C5, L1, N1 and N5
were then checked on the scan. Junctions were
measured as the largest inked disc at the point: drawn dots on this sheet
measure 16 to 21 px, plain crossings 8 to 15 px (the upper end where the
ink is smeared). The redraw was wrong where
noted below; it is not an authority. Pin numerals were not all re-read.
Corrections, each marked "[Review 22 Oct: ...]" in place:

1. **The four-input gate drawn as "IC70" is IC90.** Its designator reads 90,
   like its neighbour (IC70 is a 7432 on sheet B). Pins 2,1,4,5→6 are
   M2V0, M2V1, IC117.4 and M2V4, output to IC81.2.
2. **IC45.1 is IC40.8** (lower-section /Q, also IC49.13 and the 470p), by the
   vertical near x=2208, not IC24.6. Decoded 5 (IC24.6) runs on a separate
   vertical near x=2253 to IC25.3 and CAR NO CONT only.
3. **IC38.12 is on the /TUNNEL rail** (IC31.8 /Q, IC80.11, connector EF), by
   the corner at (3852,2362) and the vertical near x=3842, not IC40.6.
   IC40.6 goes to IC73.4.
4. **IC105's outputs go the other way round.** Pin 9 (2Y) feeds IC22.3 and,
   by the dot at (8056,3211), IC34.12. Pin 7 (1Y) feeds IC60.10. The
   IC34.12 wire's other crossings measure 10 to 11 px.
5. **The common rail at IC56.1, IC73.3 and IC80.3 is IC68 Q**, the same net
   as IC73.13 and IC80.12 (dots at (4773,4041) and (3758,4803)). It is not
   IC81.11: the crossing at (4476,4041) measures 11.3 px. IC81.11 is a
   separate net: connector FD (R-SIDE, H), IC87.13 and the lower IC88 clock
   (pin 11).
6. **IC66.3 is IC75.6**, by the horizontal near y=2846 and the drop near
   x=5327, not MH7. The MH7 vertical ends at IC89.13.
7. **IC110.10 is on MH8**, the bottom bus row (labelled at the left edge),
   with IC104.13 at the dot at (5886,2036). It is not on the IC65.13 return.
   IC81.4 is IC65.13 alone; the crossing at (6380,2036) measures 12.6 px with
   no dot. Settles C5 and U9.
8. **IC82.3, IC82.5 and IC75 pins 9 and 10 are on M2V rows, not MH rows.**
   Each vertical ends in a dot on an M2V row (16 to 20 px) and only crosses
   the MH rows (8 to 14 px): IC82.3 = M2V6, IC82.5 = M2V5, IC75.9 = M2V5, and
   the third input of the output-8 section = M2V7 (pin 10 in a 7410). So
   `IC75.6 = NAND(/M2V5, M2V6, M2V7)` and `IC75.8 = NAND(M2V5, /M2V6, M2V7)`,
   one low for M2V = 0xC0..0xDF (GRAVEL, via IC66) and the other for
   0xA0..0xBF (POOL, via IC89). The upper IC88 and IC95.12/13 are on MH5..MH8
   as the trace says.
9. **IC95 is an AND package.** Both sections have OR bodies with bubbles on
   the inputs and the output (eroded at pins 4 and 5), as IC95 9,10→8 on
   sheet B. So `IC95.6 = AND(IC96.7, IC96.6)` and
   `IC95.11 = AND(MH8, MH7)`, not the NAND candidates.
10. **IC66 is a NAND** [29 Oct: withdrawn, IC66 is an AND; see "Found on 29 October"] (6 = NAND of pins 4,3,5). Its output bubble is partly
    overwritten by the numeral 6; the output wire starts a bubble's width from
    the body.
11. **The D input of the lower IC88 and of IC74 is /V8 (E), not /VB.** The
    drafter's subscript 8 looks like B, as on sheet B. Sheet E sends IC114.2,
    the inverted V8, out on an arrow labelled `/V8` for sheets B and D (and on
    connector FN); no /VB signal leaves sheet E. The redraw has the same net.
12. **The `100-C` arrow below IC24 goes to sheet M** (circled M, clear in the
    scan), not H. The redraw has sheet M IC35.12 on that net.

Open items the review settles:

- C1: the selector wire (IC104.3 to IC92.1/IC67.1) **does not join** the
  /M2VL0 line at (5280,1435). The ink there is a smear along the horizontal
  (15 px, not round), and a join would tie the IC104.3 output to the /M2VL0
  driver (sheet B IC62.8).
- L1 (4485,2840) and N5 (5240,2845) are crossings (11.3 px each). N1
  (3680,4247) is a crossing (14.1 px, no dot). The redraw agrees on all three.
- U10: IC56.11 is an AND body with an output bubble (NAND); IC56.3 is an OR
  body with input bubbles (NAND). IC56 is a NAND package.
- C4: the central IC110 gate (4,5→6) is an OR body with faint input bubbles,
  a NAND as IC110 on sheet B; IC95.6 is settled by correction 9.
- IC106's lowest left pad (numeral reads 23) goes by a short stub to a ground
  symbol, as the trace says. The redraw leaves it open.
- IC32 is a NOR (OR body, output bubble), as the trace says; the redraw's
  74LS21 is wrong.
- S2: RA1 reads 560.
- IC104.1 is V7 (E) as traced. The redraw names that net EN, but it is sheet
  E IC100.11, the V7 counter output. IC34.9 (/COIN IN with its 470p) also
  agrees; the redraw names that net ED.
- The IC24 inputs are A, B, C, D on pins 15, 14, 13, 12 as traced; the redraw
  swaps the C and D labels but has the same wires.

Still open:

- **IC90's type.** Section 13,12,(10/11),(9/7)→8 is a plain AND body. Section
  2,1,4,5→6 is an AND body with a bubble on each input, Sega's way of drawing
  a 7425 NOR (as sheet E IC101 and sheet G IC57). One package cannot be both.
  Read as drawn, IC81.11 pulses at M1V = 0xFF and IC81.3 at M2V = 0xEC. With
  both sections AND: 0xFF and 0xFB. With both NOR: 0x1B and 0xEC. A photo of
  the later 97092-P board in stonedDiscord's repository shows IC90 as a TI
  part with the same lot code (El Salvador 7127) as IC101, which reads
  SN7425N, but IC90's own type number is too faded to read beyond SN742?N.
  That points to 7425, without proving it. The redraw's 74LS20 matches
  neither drawing. [29 Oct: settled as 7425 by the real game; see "Found on
  29 October".]
- The faded numerals and label suffixes in S1, S3, U1 to U8, L4, L5 and N2 to
  N4. Where a package type is fixed by another section, the standard pinout
  gives IC94's middle input as 3 and IC75's third input as 10.

Everything else checked agrees with the scan.

## Reading conventions

- `/NAME` transcribes an overbar. Circled sheet letters are shown as `(B)`, `(C)`, etc. A circled **D** beside an input is a reference within this sheet, not an independently traced off-sheet source.
- A junction requires a dot. Undotted crossings of the address, data, enable and long vertical output wires are not connections.
- Gate functions follow the body and bubbles. Part suffixes such as `157`, `153`, and `42` are recorded as printed. The `74` prefix used in a pinout comparison is explanatory, not an additional printed reading.
- `ICn.p` means IC n, pin p. `AV0..AV4`, `LV`, and names beginning `U_` below are **local transcription aliases**, not printed net labels.
- `not drawn` does not mean grounded, unused in the physical board, or an assured no-connect. Unnumbered short stubs are not assigned conventional pin numbers.
- `clear` means the stated observation is readable. `uncertain` means a reading or endpoint remains unresolved; each such issue is collected in the final section. Some unresolved items are untraced work, rather than illegible ink.
- Package-wide pin tables are provided for the multiplexers, PROM symbols and IC97 within scope. Tables for distributed gate packages explicitly identify the sections included here; other gates in those packages remain outside this section.

## Crops used

Boxes are `(left, top, right, bottom)` in the original supplied PNG, with the right/bottom coordinates exclusive. Files are lossless crops, without resampling. The whole-sheet overview was used only for orientation. Crop names are identifiers; for example, `side_road` actually contains the printed **SIDE LINE** label, and `bridge_ff` contains the ROAD flip-flop.

| Crop | Pixel box | Use | Confidence |
| --- | --- | --- | --- |
| prom134.png | (6850, 950, 8820, 2180) | PR134 / IC113, IC112, upper output gates | clear |
| bus_muxes.png | (5710, 590, 6850, 1710) | IC92 and IC67 | clear |
| prom135.png | (6750, 2120, 8860, 3340) | PR135 / IC106, IC105, IC22 | clear |
| prom136.png | (6760, 3540, 8840, 4860) | PR136 / IC99, IC98 and IC97 | clear |
| prom137.png | (6750, 4800, 8870, 6230) | PR137 / IC120, IC119 and lower output gates | clear |
| input_bus_labels.png | (900, 590, 2160, 2100) | B-sheet input labels | clear |
| upper_bus_mid.png | (4000, 580, 5900, 1740) | Input-bus branches and selector route | clear |
| top_output_paths.png | (5870, 590, 7820, 1730) | Selected vertical rails and IC104 side-line gate | clear |
| bus_fanout.png | (6050, 1500, 7460, 2130) | MH0..MH4 rail order and mux-select branches | clear |
| prom134_enables.png | (6300, 1270, 7100, 1910) | IC110.8 and IC81.6 driver sections | clear |
| lower_bus_outputs.png | (7770, 5480, 8820, 6240) | POOL, WALL and GRAVEL labels / connectors | clear |
| slide_output.png | (7950, 1060, 8920, 1550) | IC58, IC65, 470p capacitor, FR | clear |
| house_decode.png | (7570, 4380, 8790, 4820) | IC97 output labels | clear |
| road_outputs.png | (7490, 1780, 8890, 2240) | IC60 and IC34 tree/grass output gates | clear |
| right_middle.png | (7390, 3060, 8630, 3690) | IC105 outputs and separate right-hand vertical wires | clear |
| upper_selects.png | (4550, 580, 5780, 1700) | Common IC92/IC67 select junction | clear |
| side_road.png | (7410, 600, 8870, 960) | IC104.8 /SIDE LINE (C) | clear |
| house_enable.png | (6200, 3580, 6940, 4240) | IC81.8 driver and IC82.8 / IC87.8 endpoints | clear |
| grass_enable.png | (5950, 2490, 6930, 3040) | IC56.11 driver and preceding gate endpoint | clear |
| bottom_control_right.png | (5590, 4950, 7580, 6230) | IC117.2, IC89.8, IC104.6 and lower gating routes | clear |
| bottom_control_mid.png | (3780, 4900, 5770, 6210) | IC87.6 WALL driver and IC88 /M-ROAD output reference | clear |
| lower_signal_sources.png | (4950, 5070, 6450, 6210) | IC80.10 route and GRAVEL-control rail | clear |
| gravel_route_upper.png | (5650, 3150, 6100, 4870) | IC66.6 GRAVEL-control route, upper continuation | clear |
| gravel_route_lower.png | (5650, 4800, 6330, 6230) | Same rail to IC104.5 and IC72.12 | clear |
| center_decoder.png | (5090, 2080, 6900, 3330) | Context for IC56 control and IC66.6 GRAVEL driver | clear |
| upper_controls.png | (3750, 2020, 5630, 3350) | Control-network context only; not a completed pin trace | clear |
| left_state.png | (1330, 2080, 3310, 3580) | Left state-network context only; not a completed pin trace | clear |
| middle_state.png | (2910, 2420, 4580, 3520) | State-network context only; not a completed pin trace | clear |
| bottom_control_left.png | (1320, 5030, 3310, 6220) | Lower left context only; not a completed pin trace | clear |
| bridge_ff.png | (1290, 5290, 2430, 6220) | ROAD flip-flop context only; not a completed pin trace | clear |
| top_bus_left.png | (1150, 570, 3350, 1770) | Left-to-middle continuity of the B-sheet input buses | clear |
| middle_bus_link.png | (3260, 650, 4080, 1920) | Middle continuity of the B-sheet input buses | clear |
| mixed_enable_detail.png | (6180, 5180, 6860, 5680) | IC117 output / POOL-control undotted crossing and IC89 inputs | clear |

## Signal path in brief

IC92 selects four vertical bits from the two B-sheet input groups. IC67 selects the fifth vertical bit and an accompanying barred load-labelled signal. These feed the four PROM paths. The common select wire is driven by IC104.3. A possible junction with the IC67.6 load-labelled wire is unresolved; continuation 3 revises the earlier definite-connection claim. The B-sheet load label remains `/M2VL[0/O/D?]`.

PR134, PR135 and PR137 feed separate `153` dual four-to-one multiplexers. MH0 and MH1 select one of the four inputs in each half. PR136 instead feeds a `157`; MH0 selects one of each input pair, and three selected bits enter IC97 (`42`). The PROM symbols show high and low enable ties; window control is applied to the downstream multiplexers.

The right-edge gates form barred scenery outputs. `/GRAVEL` is generated by IC72 pin 11 from IC119 pin 7 and the GRAVEL control generated at IC66 pin 6. `/SLIDE` is generated separately by IC65 pin 4 from two IC58 AND outputs; it is not a PR137 output. The state logic creating the control signals has not all been traced.

## Shared input and address wiring

The following table records the input terminals used by this section. Ditto marks in the drawing are expanded only within their visibly labelled group. It is not the inventory of every input on the whole sheet.

| Printed input | Sheet | Destination in this section | Confidence |
| --- | --- | --- | --- |
| M1V0 | B | IC92.2 | clear |
| M1V1 | B | IC92.5 | clear |
| M1V2 | B | IC92.11 | clear |
| M1V3 | B | IC92.14 | clear |
| M2V0 | B | IC92.3 | clear |
| M2V1 | B | IC92.6 | clear |
| M2V2 | B | IC92.10 | clear |
| M2V3 | B | IC92.13 | clear |
| M1V4 | B | IC67.2 | clear |
| /M1VL[0/O/D?] | B | IC67.5; final round character unresolved | uncertain |
| M2V4 | B | IC67.3 | clear |
| /M2VL[0/O/D?] | B | IC67.6; final character unresolved. Possible join to the selector route is uncertain (C1). | uncertain |
| MH0 | B | IC112.14, IC105.14 (number faint), IC119.14; IC98.1 | clear |
| MH1 | B | IC112.2, IC105.2, IC119.2; IC99.3  — PROM numeral is a candidate; see its positional pad table | uncertain |
| MH2 | B | IC113.3, IC106 third-from-bottom address input (candidate pin 3), IC120.3, IC99.2 | uncertain |
| MH3 | B | IC113.2, IC106 second-from-bottom address input above grounded pad (candidate pin 2), IC120.2, IC99.1 | clear |
| MH4 | B | IC113.1, IC106 lowest bus-connected address input (candidate pin 1), IC120.1, IC99.23; IC104.9 | clear |
| V-④ (4 enclosed in circle) | B | IC58.4 in the /SLIDE circuit; distinct from a silently substituted name V4 | clear |

The MH rows certify the visible rail routes, not the faded numerical candidates on IC106. Those pin-number readings are uncertain in IC106’s table. The input bus also has branches into the untranscribed state network; that fanout is not exhaustively listed here.

### IC92 — printed `157`

Crops: `bus_muxes`, `upper_bus_mid`, `upper_selects`, `top_output_paths`. Standard 74157 comparison: the drawn select, enable, eight data inputs and four outputs agree.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 1 | Select S | Same wire as IC67.1, driven by IC104.3. Junction between the select branches near (5280,1115) is clear; possible load-line join near (5280,1435) is uncertain (C1). [Review 22 Oct: no join; see the review, C1.] | clear |
| 2 | 1A | M1V0 (B) | clear |
| 3 | 1B | M2V0 (B) | clear |
| 4 | 1Y = AV0 | IC113.8, IC99.8, IC120.8; IC106 top address pad (number faint) | uncertain |
| 5 | 2A | M1V1 (B) | clear |
| 6 | 2B | M2V1 (B) | clear |
| 7 | 2Y = AV1 | IC113.7, IC99.7, IC120.7; IC106 second address pad | clear |
| 11 | 3A | M1V2 (B) | clear |
| 10 | 3B | M2V2 (B) | clear |
| 9 | 3Y = AV2 | IC113.6, IC99.6, IC120.6; IC106 third address pad  — PROM numeral is a candidate; see its positional pad table | uncertain |
| 14 | 4A | M1V3 (B) | clear |
| 13 | 4B | M2V3 (B) | clear |
| 12 | 4Y = AV3 | IC113.5, IC99.5, IC120.5; IC106 fourth address pad  — PROM numeral is a candidate; see its positional pad table | uncertain |
| 15 | /G | Ground symbol directly below the bubble | clear |
| 8, 16 | Package power | Not drawn; no power-pin wiring inferred | clear |

### IC67 — printed `157`

Crops: `bus_muxes`, `upper_bus_mid`, `upper_selects`, `top_output_paths`. Only the first two data channels are wired in this symbol. Drawn numbered pins agree with 74157.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 1 | Select S | Same wire as IC92.1, driven by IC104.3; possible additional join to the IC67.6 load line uncertain (C1). [Review 22 Oct: no join; see the review, C1.] | clear |
| 2 | 1A | M1V4 (B) | clear |
| 3 | 1B | M2V4 (B) | clear |
| 4 | 1Y = AV4 | IC113.4, IC99.4, IC120.4; IC106 fifth address pad | clear |
| 5 | 2A | /M1VL[0/O/D?] (B); last character unresolved | uncertain |
| 6 | 2B | /M2VL[0/O/D?] (B); possible join to both select inputs is unresolved (C1). | uncertain |
| 7 | 2Y = LV | Loops above IC92 outputs to IC104.10; undotted crossings are not junctions | clear |
| 15 | /G | Ground symbol below bubble | clear |
| Other input stubs | Unused-channel representation | Four short unnumbered stubs; their ties are not drawn. Do not assign a high/low level. | clear |
| Other outputs | Unused-channel representation | No numbered output connections for the remaining channels are drawn | clear |
| 8, 16 | Package power | Not drawn | clear |

For the numbered 157 channels, the standard function selects the A input for S=0 and B for S=1 while /G=0. This statement does not resolve the spelling or semantic meaning of either load label.

### IC104 — side-line gate section only; part number not printed beside this gate

Crops: `top_output_paths`, `side_road`. AND-shaped body, bubbles on both inputs and output: positive OR by De Morgan. The numbering 9,10 → 8 is compatible with a 7432 OR section; this is not a printed device identification.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 10 | Input | LV = IC67.7 | clear |
| 9 | Input | MH4 (B), also the rail reaching IC113.1 | clear |
| 8 | Output | /SIDE LINE (C) | clear |
| Other package pins | Outside this gate section | Other IC104 sections exist elsewhere on D; package power is not drawn here | clear |

## PROM and pixel-multiplexer pin tables

The PROM labels are `PR-134`, `PR-135`, `PR-136`, `PR-137`. A manufacturer/device part number is not legible/printed beside these symbols. They are therefore **not asserted to be a printed 7641**. The pin arrangement resembles the PROM arrangement in the G-sheet model, but that resemblance is not used to repair unreadable numbers. `Address` and `data` below describe the connected buses; no ROM contents or artwork interpretation are supplied.

### IC113 — PR-134

Crops: `prom134` and shared bus crops. Bus routing is recorded without assigning contents to the PROM.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 8 | AV0 | IC92.4 | clear |
| 7 | AV1 | IC92.7 | clear |
| Left pad 3 from top; number uncertain (candidate 6) | AV2 | IC92.9 | uncertain |
| Left pad 4 from top; number uncertain (candidate 5) | AV3 | IC92.12 | uncertain |
| 4 | AV4 | IC67.4 | clear |
| 3 | MH2 | B input | clear |
| 2 | MH3 | B input | clear |
| 1 | MH4 | B input | clear |
| 23 | U_TREE_BANK | IC110.8; upstream inputs not fully traced | clear |
| 9 | Data wire 1 | IC112 input pin 6 | clear |
| 10 | Data wire 2 | IC112 input pin 5 | clear |
| Bottom pad 3 from left; number uncertain (candidate 11) | Data wire 3 | IC112 input pin 4 | uncertain |
| 13 | Data wire 4 | IC112 input pin 3 | clear |
| 14 | Data wire 5 | IC112 input pin 10 | clear |
| Bottom pad 6 from left; number uncertain (candidate 15) | Data wire 6 | IC112 input pin 11 | uncertain |
| Bottom pad 7 from left; number uncertain (candidate 16) | Data wire 7 | IC112 input pin 12 | uncertain |
| 17 | Data wire 8 | IC112 input pin 13 | clear |
| 18, 19 | High ties | Both tied to the labelled Vcc node | clear |
| 20, 21 | Low ties | Joined to ground symbol | clear |
| Other package pins | Not drawn | No additional supply-pin or other pin connections are drawn; no implicit 12/22/24 wiring is added | clear |

The upper annotation inside IC113 reads `3-TREE`. The lower annotation is damaged; `2-TREE` is a candidate, not a resolved reading. Neither annotation is used to infer the PROM data.

### IC112 — printed `153`

Crop: `prom134`. The written data/select/enable/output numbering agrees with 74153.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 6 | 1C0 | IC113 data pin 9 | clear |
| 5 | 1C1 | IC113 data pin 10 | clear |
| 4 | 1C2 | IC113 bottom data pad 3; numeral uncertain (candidate pin 11) | uncertain |
| 3 | 1C3 | IC113 data pin 13 | clear |
| 10 | 2C0 | IC113 data pin 14 | clear |
| 11 | 2C1 | IC113 bottom data pad 6; numeral uncertain (candidate pin 15) | uncertain |
| 12 | 2C2 | IC113 bottom data pad 7; numeral uncertain (candidate pin 16) | uncertain |
| 13 | 2C3 | IC113 data pin 17 | clear |
| 14 | A select | MH0 (B) | clear |
| 2 | B select | MH1 (B) | clear |
| 1, 15 | /G1, /G2 | Tied together to IC81.6 (U_TREE_STROBE) | clear |
| 7 | 1Y | IC34.11 | clear |
| 9 | 2Y | IC60.9 | clear |
| 8, 16 | Package power | Not drawn | clear |

### IC106 — PR-135

Crops: `prom135` and shared bus crops. The pin text is badly eroded: positional pad descriptions are authoritative; candidate numbers are not confirmed readings.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| Left pad 1 from top; number uncertain (candidate 8) | AV0 | IC92.4 | uncertain |
| Left pad 2 from top; number uncertain (candidate 7) | AV1 | IC92.7 | uncertain |
| Left pad 3 from top; number uncertain (candidate 6) | AV2 | IC92.9 | uncertain |
| Left pad 4 from top; number uncertain (candidate 5) | AV3 | IC92.12 | uncertain |
| Left pad 5 from top; number uncertain (candidate 4) | AV4 | IC67.4 | uncertain |
| Left pad 6 from top; number uncertain (candidate 3) | MH2 | B input | uncertain |
| Left pad 7 from top; number uncertain (candidate 2) | MH3 | B input | uncertain |
| Left pad 8 from top; number uncertain (candidate 1) | MH4 | B input | uncertain |
| Left pad 9 from top; number uncertain (candidate 23) | Ground | Separate short ground connection at lowest left pad | uncertain |
| Bottom pad 1 from left; number uncertain (candidate 9) | Data wire 1 | IC105 input pin 6 (some input numbers also faded; see its table) | uncertain |
| Bottom pad 2 from left; number uncertain (candidate 10) | Data wire 2 | IC105 input pin 5 (some input numbers also faded; see its table) | uncertain |
| Bottom pad 3 from left; number uncertain (candidate 11) | Data wire 3 | IC105 input pin 4 (some input numbers also faded; see its table) | uncertain |
| Bottom pad 4 from left; number uncertain (candidate 13) | Data wire 4 | IC105 input pin 3 (some input numbers also faded; see its table) | uncertain |
| Bottom pad 5 from left; number uncertain (candidate 14) | Data wire 5 | IC105 input pin 10 (some input numbers also faded; see its table) | uncertain |
| Bottom pad 6 from left; number uncertain (candidate 15) | Data wire 6 | IC105 input pin 11 (some input numbers also faded; see its table) | uncertain |
| Bottom pad 7 from left; number uncertain (candidate 16) | Data wire 7 | IC105 input pin 12 (some input numbers also faded; see its table) | uncertain |
| Bottom pad 8 from left; number uncertain (candidate 17) | Data wire 8 | IC105 input pin 13 (some input numbers also faded; see its table) | uncertain |
| Upper right pair; numbers uncertain (candidates 18,19) | High ties | Both tied to the labelled Vcc node; tie ink faded | uncertain |
| Lower right bubbled pair; numbers faded (candidates 20,21) | Low ties | Joined to ground symbol | uncertain |
| Other package pins | Not drawn | No additional supply-pin or other pin connections are drawn; no implicit 12/22/24 wiring is added | clear |

### IC105 — printed `153`

Crop: `prom135`. Faded pin numbers prevent an unconditional pinout check; candidates are compatible with 74153.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| Top pad 1; candidate pin 6 | 1C0 | IC106 bottom data pad 1; both numeric readings need confirmation | uncertain |
| Top pad 2; candidate pin 5 | 1C1 | IC106 bottom data pad 2; both numeric readings need confirmation | uncertain |
| Top pad 3; candidate pin 4 | 1C2 | IC106 bottom data pad 3; both numeric readings need confirmation | uncertain |
| Top pad 4; candidate pin 3 | 1C3 | IC106 bottom data pad 4; both numeric readings need confirmation | uncertain |
| Top pad 5; candidate pin 10 | 2C0 | IC106 bottom data pad 5; both numeric readings need confirmation | uncertain |
| Top pad 6; candidate pin 11 | 2C1 | IC106 bottom data pad 6; both numeric readings need confirmation | uncertain |
| Top pad 7; candidate pin 12 | 2C2 | IC106 bottom data pad 7; both numeric readings need confirmation | uncertain |
| Top pad 8; candidate pin 13 | 2C3 | IC106 bottom data pad 8; both numeric readings need confirmation | uncertain |
| Upper left select; candidate 14 | A select | MH0 (B) | uncertain |
| 2 | B select | MH1 (B) | clear |
| Two right bubbled controls; candidates 1,15 | /G1, /G2 | Tied together to IC56.11, /GRASS AREA (C) | uncertain |
| Left bottom output; candidate 7 | 1Y | Upward vertical return to IC34.12 [Review 22 Oct: wrong. Pin 7 goes to IC60.10; IC34.12 is on pin 9, correction 4.] | uncertain |
| Right bottom output; candidate 9 | 2Y | IC22.3 and upward branch to IC60.10 [Review 22 Oct: the upward branch goes to IC34.12, by the dot at (8056,3211); IC60.10 is on pin 7. Correction 4.] | uncertain |
| 8, 16 | Package power | Not drawn | clear |

The two IC105 output wires remain distinct. The right-hand output has a dot where it branches to IC22.3 and the upward wire; the left-hand output turns right below the IC and then upward on the adjacent wire. Neither is joined merely by crossing the separate IC58.11 vertical return. See `right_middle` and `road_outputs`.

### IC99 — PR-136

Crops: `prom136` and shared bus crops. Bus routing is recorded without assigning contents to the PROM.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| Left pad 1 from top; number uncertain (candidate 8) | AV0 | IC92.4 | uncertain |
| 7 | AV1 | IC92.7 | clear |
| Left pad 3 from top; number uncertain (candidate 6) | AV2 | IC92.9 | uncertain |
| Left pad 4 from top; number uncertain (candidate 5) | AV3 | IC92.12 | uncertain |
| 4 | AV4 | IC67.4 | clear |
| Left pad 6 from top; number uncertain (candidate 3) | MH1 | B input | uncertain |
| Left pad 7 from top; number uncertain (candidate 2) | MH2 | B input | uncertain |
| 1 | MH3 | B input | clear |
| 23 | MH4 | B input | clear |
| Bottom pad 1 from left; number uncertain (candidate 9) | Data wire 1 | IC98 input pin 2 | uncertain |
| Bottom pad 2 from left; number uncertain (candidate 10) | Data wire 2 | IC98 input pin 3 | uncertain |
| Bottom pad 3 from left; number uncertain (candidate 11) | Data wire 3 | IC98 input pin 5 | uncertain |
| Bottom pad 4 from left; number uncertain (candidate 13) | Data wire 4 | IC98 input pin 6 | uncertain |
| 14 | Data wire 5 | IC98 input pin 11 | clear |
| Bottom pad 6 from left; number uncertain (candidate 15) | Data wire 6 | IC98 input pin 10 | uncertain |
| Bottom pad 7 from left; number uncertain (candidate 16) | Data wire 7 | IC98 input pin 14 | uncertain |
| Bottom pad 8 from left; number uncertain (candidate 17) | Data wire 8 | IC98 input pin 13 | uncertain |
| 18, 19 | High ties | Both tied to the labelled Vcc node | clear |
| 20, 21 | Low ties | Joined to ground symbol | clear |
| Other package pins | Not drawn | No additional supply-pin or other pin connections are drawn; no implicit 12/22/24 wiring is added | clear |

### IC98 — printed `157`

Crops: `prom136`, `house_decode`. The data pairing differs from the three 153 paths. Drawn numbered pins agree with 74157.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 2 | 1A | IC99.9  — PROM numeral is a candidate; see its positional pad table | uncertain |
| 3 | 1B | IC99.10  — PROM numeral is a candidate; see its positional pad table | uncertain |
| 5 | 2A | IC99.11  — PROM numeral is a candidate; see its positional pad table | uncertain |
| 6 | 2B | IC99.13  — PROM numeral is a candidate; see its positional pad table | uncertain |
| 11 | 3A | IC99.14 | clear |
| 10 | 3B | IC99.15  — PROM numeral is a candidate; see its positional pad table | uncertain |
| 14 | 4A | IC99.16  — PROM numeral is a candidate; see its positional pad table | uncertain |
| 13 | 4B | IC99.17  — PROM numeral is a candidate; see its positional pad table | uncertain |
| 1 | Select | MH0 (B) | clear |
| 15 | /G | IC81.8, with branch labelled /HOUSE ST (C) | clear |
| 4 | 1Y | IC97.15 (A) | clear |
| 7 | 2Y | IC97.14 (B) | clear |
| 9 | 3Y | IC97.13 (C) | clear |
| 12 | 4Y | Number is drawn, but no continuing output wire is drawn | clear |
| 8, 16 | Package power | Not drawn | clear |

### IC97 — printed `42`

Crops: `prom136`, `house_decode`. A four-bit decoder with inverted outputs. Drawn numbers agree with 7442. Extra small strokes beside inputs are not treated as additional nets.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 15 | A | IC98.4 | clear |
| 14 | B | IC98.7 | clear |
| 13 | C | IC98.9 | clear |
| 12 | D | Ground | clear |
| 2 | Decoded output 1 | /HOUSE(R) (C) | clear |
| 3 | Decoded output 2 | Ditto HOUSE label with suffix resembling (ML) or (MW); barred, destination C | uncertain |
| 4 | Decoded output 3 | Ditto HOUSE label with damaged suffix, possibly (BL) or (DL); barred, destination C | uncertain |
| 5 | Decoded output 4 | /HOUSE(W) (C); HOUSE is a ditto mark on this line | clear |
| Remaining decoded outputs | Not drawn | No wiring drawn for outputs 0 and 5..9 in this symbol | clear |
| 8, 16 | Package power | Not drawn | clear |

### IC120 — PR-137

Crops: `prom137` and shared bus crops. Bus routing is recorded without assigning contents to the PROM.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 8 | AV0 | IC92.4 | clear |
| 7 | AV1 | IC92.7 | clear |
| 6 | AV2 | IC92.9 | clear |
| 5 | AV3 | IC92.12 | clear |
| 4 | AV4 | IC67.4 | clear |
| 3 | MH2 | B input | clear |
| 2 | MH3 | B input | clear |
| 1 | MH4 | B input | clear |
| Lowest left address pad; glyph may read 13 or 23 (unresolved) | U_MIX_BANK | IC117.2; crosses the separate POOL-control rail without a dot | uncertain |
| 9 | Data wire 1 | IC119 input pin 6 | clear |
| 10 | Data wire 2 | IC119 input pin 5 | clear |
| 11 | Data wire 3 | IC119 input pin 4 | clear |
| 13 | Data wire 4 | IC119 input pin 3 | clear |
| 14 | Data wire 5 | IC119 input pin 10 | clear |
| 15 | Data wire 6 | IC119 input pin 11 | clear |
| 16 | Data wire 7 | IC119 input pin 12 | clear |
| 17 | Data wire 8 | IC119 input pin 13 | clear |
| 18, 19 | High ties | Both tied to the labelled Vcc node | clear |
| 20, 21 | Low ties | Joined to ground symbol | clear |
| Other package pins | Not drawn | No additional supply-pin or other pin connections are drawn; no implicit 12/22/24 wiring is added | clear |

IC120 contains readable words including `WALL`, `GREEN`, and `POOL`, with damaged text and dividing lines. These annotations are not a transcription of the stored data. Other words/numbers in the PROM body remain unresolved.

### IC119 — printed `153`

Crop: `prom137`. The written data/select/enable/output numbering agrees with 74153.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 6 | 1C0 | IC120 data pin 9 | clear |
| 5 | 1C1 | IC120 data pin 10 | clear |
| 4 | 1C2 | IC120 data pin 11 | clear |
| 3 | 1C3 | IC120 data pin 13 | clear |
| 10 | 2C0 | IC120 data pin 14 | clear |
| 11 | 2C1 | IC120 data pin 15 | clear |
| 12 | 2C2 | IC120 data pin 16 | clear |
| 13 | 2C3 | IC120 data pin 17 | clear |
| 14 | A select | MH0 (B) | clear |
| 2 | B select | MH1 (B) | clear |
| 1, 15 | /G1, /G2 | Tied together to IC89.8 (U_MIX_STROBE) | clear |
| 7 | 1Y | IC72.2, IC58.13 and IC72.13; two visible junction dots on this fanout | clear |
| 9 | 2Y | IC72.9 | clear |
| 8, 16 | Package power | Not drawn | clear |

## Output gates and immediate control interfaces

These are gate-section tables, not a claim that every gate of each shared IC package has been transcribed. A driver pin recorded at the section boundary is usable as a physical endpoint; a functional state equation requires the unfinished upstream trace.

### IC60 — upper output gate section; device type not printed here

Crop: `road_outputs`. OR body with output bubble: three-input NOR. Pins 9,10,11 → 8 are compatible with 7427.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 9 | Input | IC112.9 | clear |
| 10 | Input | IC105 right bottom output (candidate pin 9), same net as IC22.3 [Review 22 Oct: IC105 pin 7 (left bottom output); correction 4.] | uncertain |
| 11 | Input | IC58.11, long right-hand vertical return from lower outputs | clear |
| 8 | Output | Barred TREE…GRASS… label, destination C; full wording/suffix unresolved | uncertain |
| Other package pins | Outside section / not drawn here | Other sections not inventoried; package power not drawn here | clear |

### IC34 — upper output gate section; device type not printed here

Crop: `road_outputs`. OR body with output bubble: two-input NOR. Pins 11,12 → 13 are compatible with 7402; pin 13 is not treated as a transcription error.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 11 | Input | IC112.7 | clear |
| 12 | Input | IC105 left bottom output (candidate pin 7) [Review 22 Oct: IC105 pin 9, with IC22.3; correction 4.] | uncertain |
| 13 | Output | Barred TREE…GRASS…(BL) label, destination C; intervening letters unresolved | uncertain |
| Other package pins | Outside section / not drawn here | Other sections not inventoried; package power not drawn here | clear |

### IC22 — inverter section; device type not printed here

Crops: `prom135`, `right_middle`. Triangle with output bubble; pins 3 → 4 are compatible with 7404.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 3 | Input | IC105 right bottom output (candidate pin 9), also IC60.10 [Review 22 Oct: also IC34.12, not IC60.10; correction 4.] | uncertain |
| 4 | Output | Barred GRASS… label (candidate /GRASS(W)), destination C; damaged suffix | uncertain |
| Other package pins | Outside section / not drawn here | Other inverter sections not inventoried; package power not drawn here | clear |

### IC72 — three lower NAND sections; device type not printed here

Crops: `prom137`, `lower_bus_outputs`, `bottom_control_right`, `bottom_control_mid`, `gravel_route_upper`, `gravel_route_lower`. AND bodies with output bubbles. Written pin groups agree with 7400 NAND sections.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 9 | POOL pixel input | IC119.9 | clear |
| 10 | POOL control input | Same vertical control rail as IC89.9; continuation 5 follows its driver to upper IC89.6. Not connected to the crossing IC117.2 output. | uncertain |
| 8 | POOL output | Barred POOL(suffix unresolved) (C), and connector FM to barred POOL(suffix unresolved) (F) | uncertain |
| 2 | WALL pixel input | IC119.7 | clear |
| 1 | WALL control input | IC87.6, wire annotated WALL in bottom_control_mid | clear |
| 3 | WALL output | Barred WALL(suffix unreadable) (C) | uncertain |
| 13 | GRAVEL pixel input | IC119.7; same fanout as IC72.2 and IC58.13 | clear |
| 12 | GRAVEL control input | IC66.6; continuous rail also branches to IC104.5 | clear |
| 11 | GRAVEL output | /GRAVEL (C); same net through connector F14 to /GRAVEL (G) | clear |
| Fourth gate / power | Outside this section | Remaining section not inventoried; power pins not drawn here | clear |

### IC58 — three AND sections; device type not printed here

Crops: `slide_output`, `prom137`, `lower_bus_outputs`, `bottom_control_right`. Plain AND bodies, without output bubbles. Pins agree with the corresponding 7408 sections.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 2 | First /SLIDE branch input | /M-ROAD (D), local reference; labelled source established at IC88.8 /Q in continuation 3. Its data/clock circuit remains unfinished. | uncertain |
| 1 | First /SLIDE branch input | /BRIDGE AP (D); continuation 5 traces the labelled source to IC22.6 | clear |
| 3 | First branch output | IC65.5 | clear |
| 5 | Second /SLIDE branch input | BRIDGE AP (D), unbarred; continuation 5 traces the labelled source to IC80.1 | clear |
| 4 | Second /SLIDE branch input | V-④ (B), written V- followed by a circled 4 | clear |
| 6 | Second branch output | IC65.6 and unnumbered 470p capacitor to ground | clear |
| 13 | Lower pixel-combining input | IC119.7, also IC72.2 and IC72.13 | clear |
| 12 | Lower control input | IC80.10; same control net also enters IC104.4 | clear |
| 11 | Lower output | Long vertical return to IC60.11; not joined to crossed POOL/WALL/HOUSE output wires | clear |
| Fourth gate / power | Outside this section | Remaining section not inventoried; package power not drawn here | clear |

### IC65 — /SLIDE NOR section; device type not printed here

Crop: `slide_output`. OR body with output bubble. Pins 5,6 → 4 agree with a 7402 NOR section.

| Pin / pad | Net / function | Connection or observation | Confidence |
| --- | --- | --- | --- |
| 5 | Input | IC58.3 | clear |
| 6 | Input | IC58.6; capacitor at this node | clear |
| 4 | Output | Connector FR, /SLIDE (G) | clear |
| Other package pins | Outside section / not drawn here | Other IC65 sections occur in the central state network; package power not drawn here | clear |

### Control-driver boundary ledger

This ledger records where the PROM/mux/output section meets the unfinished state network. It deliberately does not present incomplete driver packages as fully transcribed ICs. `U_` names are local aliases. Untraced upstream endpoints remain in the unresolved list.

| Driver / local alias | Observed gate or connection | Loads established here / upstream boundary | Confidence |
| --- | --- | --- | --- |
| IC110.8 / U_TREE_BANK | Two-input NAND; inputs 10 and 9 visible | IC113.23. Input 9 is now traced to IC110.6; input 10 return/crossings remain unresolved (C5). [Review 22 Oct: input 10 is MH8; correction 7.] | clear |
| IC81.6 / U_TREE_STROBE | Two-input NAND; inputs 4 and 5 visible | IC112.1 and .15. Input 5 is IC87.8. Candidate shared input-4 / IC110.10 return toward IC65.13 remains unresolved (C5). [Review 22 Oct: input 4 is IC65.13 only; correction 7.] | clear |
| IC56.11 / U_GRASS_STROBE | Output bubble clear, inputs 12 and 13; body contour eroded, NAND versus NOR unresolved | IC105 two bubbled enables; /GRASS AREA (C). Pin 12 comes from IC56.3; input 13 is now traced to IC87.8. Do not decide the function solely from the pin group. | uncertain |
| IC81.8 / U_HOUSE_STROBE | NAND, inputs 9 and 10 | IC98.15; /HOUSE ST (C). Pin 9 is IC82.8 (inversion of IC96.1); pin 10 is IC87.8, whose preceding input sources remain unfinished. | uncertain |
| IC117.2 / U_MIX_BANK | Inverter, input 1 | IC120 lowest left address pad (13/23 unresolved). Input 1 also reaches IC89.10; continuation 4 follows the driver to IC87.6 (WALL). Output 2 crosses the independent POOL-control rail without a dot. | uncertain |
| IC89.8 / U_MIX_STROBE | Three-input NOR, inputs 9,10,11 | IC119.1 and .15. Inputs: .9 = IC89.6 POOL-control rail also entering IC72.10 (continuation 5); .10 = IC117.1 net; .11 = IC104.6. The input-driver endpoints are followed in continuations 4–5. | uncertain |
| IC104.6 | Plain OR, inputs 4 and 5 | IC89.11. Pin 4 = IC80.10; pin 5 = IC66.6. Other IC104 sections remain outside scope. | clear |
| IC80.10 | AND body with input bubbles at 9 and 8, no output bubble: NOR | IC58.12 and IC104.4. Inputs are completed at the IC94/IC80 boundary in continuation 4. | uncertain |
| IC87.6 / WALL | Plain AND, inputs 5 and 4 | IC72.1. Continuation 4 adds /ROAD at pin 4 and IC80.13 at pin 5. | uncertain |
| IC66.6 / GRAVEL control | Plain three-input AND, numbered inputs 4,3,5 [Review 22 Oct: NAND; the output bubble is partly overwritten by the numeral 6. Correction 10.] | IC72.12 and IC104.5. Input 4 connects to IC82.10; input 3 to the rail also entering IC96.13 [Review 22 Oct: input 3 is IC75.6, not MH7; correction 6]. Input 5 is now traced to IC73.6 in continuation 2; the preceding state logic remains unfinished. | uncertain |

In `mixed_enable_detail`, the horizontal IC117.2 output crosses the POOL-control vertical rail near (6510,5265) without a dot. Farther down that rail, a clear dot feeds IC89.9. These are separate nets. IC104.6 also crosses that rail without a dot before turning upward to IC89.11. No timing assumption or functional repair is made to the control network.

## Passive components in this section

| Designator as drawn | Value as drawn | Endpoints | Notes | Confidence |
| --- | --- | --- | --- | --- |
| Not drawn | 470p | IC58.6 / IC65.6 node → ground | Capacitor in /SLIDE circuit; interpret unit as pF, not a resistor. No reference number is visible. | clear |

No resistor is drawn in the first PROM/output section. Continuation 2 adds RA1 and two state-network capacitors; their rows are separate below. No RC delay, threshold, or waveform is inferred from the 470p capacitor alone.

## Outputs and local references

This inventory covers the completed pixel-path section and its immediate driver outputs. Additional sheet-D outputs in the untraced state network are not silently treated as absent. Barred labels are written with `/`; damaged text is kept bracketed.

| Printed output / visible text | Source | Sheet / connector | Reading note | Confidence |
| --- | --- | --- | --- | --- |
| /SIDE LINE | IC104.8 | C | SIDE LINE, not SIDE ROAD | clear |
| /TREE…GRASS…[suffix unresolved] | IC60.8 | C | Faded upper label; no completed spelling supplied | uncertain |
| /TREE…GRASS…(BL) | IC34.13 | C | End suffix BL readable; intervening letters unresolved | uncertain |
| /GRASS AREA | IC56.11 | C | Also controls both IC105 enables | clear |
| /GRASS[likely (W)] | IC22.4 | C | Suffix damaged; candidate only | uncertain |
| /HOUSE ST | IC81.8 | C | Also IC98.15 | clear |
| /HOUSE(R) | IC97.2 | C | First decoder output line | clear |
| /HOUSE([ML/MW?]) | IC97.3 | C | HOUSE represented by ditto marks | uncertain |
| /HOUSE([BL/DL?]) | IC97.4 | C | HOUSE represented by ditto marks; suffix not resolved | uncertain |
| /HOUSE(W) | IC97.5 | C | HOUSE represented by ditto marks | clear |
| /POOL([suffix unreadable]) | IC72.8 | C; F through FM | Both branches have POOL and an indistinct parenthesized suffix; do not assume identical suffix letters | uncertain |
| /WALL([suffix unreadable]) | IC72.3 | C | Bar and destination clear | uncertain |
| /GRAVEL | IC72.11 | C; G through F14 | One source node feeds both destinations | clear |
| /SLIDE | IC65.4 | G through FR | Local D references and B input shown in IC58 table | clear |

### Signals required by the existing sheet G player trace

**`/GRAVEL (D)`** in the G trace is generated here at **IC72 pin 11**, taken to G through **F14**. The same node also goes to C. Its immediate logic is:

`/GRAVEL = NOT(IC119.7 AND IC66.6)`.

IC119.7 is the first selected PR137 bit; IC66.6 is the separately generated GRAVEL control. The IC66.6 route was followed down the rail near x=5915 through `gravel_route_upper` and `gravel_route_lower`, to the lower horizontal run into IC72.12. The upstream state logic feeding IC66 is unfinished.

**`/SLIDE (D)`** in the G trace is generated here at **IC65 pin 4**, taken to G through **FR**. From the printed local input labels and the drawn gate shapes:

`/SLIDE = NOT((/M-ROAD AND /BRIDGE AP) OR (BRIDGE AP AND V-④))`.

The first product is IC58.3; the second is IC58.6. The second node also has **470p to ground**. This is a Boolean description of the drawn gates, not a model of the capacitor or gate delays. `/M-ROAD`, `/BRIDGE AP`, and `BRIDGE AP` have local D references; their full generating state circuits are not resolved by this equation. The B input is copied as `V-④`, without guessing that it means an ordinary V4 counter bit.

### Combinational selection implied by the numbered parts

For IC112 and IC119, MH0 goes to A (pin 14) and MH1 to B (pin 2). With both enables low, each output chooses input `Ck`, where `k = MH0 + 2×MH1`; a high enable forces that half’s output low. This follows the printed 153 and checked pin numbering. Applying the same statement to IC105 is **conditional on confirmation of its faded pin numbers**.

For IC98, MH0 selects the first or second wire of each adjacent PROM-data pair. The first three outputs enter IC97 A, B and C, with D grounded. IC97 outputs 1..4 are the four drawn barred HOUSE outputs. IC98 pin 12 has no continuing wire drawn. No colour value is deduced from the damaged suffixes or PROM body notes.

## Continuation 2 — input decoder, state flip-flops and counter/multiplexer block

This continuation adds IC24 and RA1; the seven state flip-flop sections marked `74½ ×7`; the other IC40 half; IC49, IC48, IC41 and the drawn IC68 latch section; and the associated IC45/IC47/IC32/IC34/IC39 gate sections. It also establishes IC73.6 as the third input to the GRAVEL-control gate IC66. Some long-wire fanouts remain unresolved. This is still a **partial sheet trace**, not a completed state-machine specification.

The first section’s incomplete-control ledger remains useful, with the explicit updates below. The original section boundaries are superseded by the revised stopping point at the end of this file. `S_*` and `U_*` below are local aliases only. Candidate output numerals are not silently replaced by standard 7474 pin numbers.

### Additional crops

These boxes use the same original PNG coordinates and exclusive right/bottom convention as the first crop table.

| Crop | Pixel box | Use | Confidence |
| --- | --- | --- | --- |
| state_inputs.png | (880, 2430, 2320, 3410) | IC24, RA1, EXTEND and 100-C reference | clear |
| full_decoder_inputs.png | (720, 2630, 1310, 3180) | Connector labels and circled I beside the four decoder inputs | clear |
| state_38.png | (2250, 2370, 3370, 3280) | Both IC38 halves and adjacent feedback gates | clear |
| state_40_25.png | (3270, 2370, 4570, 3480) | GRAVEL, TUNNEL and HOUSE state sections | clear |
| state_clock.png | (1990, 3140, 3370, 3940) | IC40-to-IC49 clock and upper counter-reset gate | clear |
| state_bus_right.png | (4190, 2700, 5650, 3910) | IC73.6 to IC66.5; IC25 lower /Q to IC80.2 | clear |
| lower_counters.png | (1280, 3440, 3120, 5070) | IC40, IC49, IC48, IC41 and IC68 | clear |
| decoder_top_routes.png | (2010, 2280, 4270, 2800) | Orientation of decoder and state feedback routes | clear |
| decoder_top_left.png | (2020, 2290, 3170, 2830) | Native-resolution left half of those routes | clear |
| decoder_top_right.png | (3120, 2290, 4270, 2830) | Native-resolution right half of those routes | clear |
| decoder_bottom_routes.png | (2030, 2820, 3150, 3430) | IC24 outputs 2..7 and crossings | clear |
| counter_inputs.png | (880, 3350, 2280, 4500) | /HS (E), /MHL… (E), IC47 and IC40 | clear |
| counter_logic.png | (2550, 3480, 3780, 4410) | IC49 outputs, IC39, IC47 and IC34 | clear |
| state_lower_gates.png | (2370, 3520, 3750, 4350) | Counter/reset-gate context | clear |
| decoder_controls.png | (2260, 2130, 4110, 2490) | IC89 input-4 route and state-wire crossings | clear |
| bottom_left_signals.png | (2980, 4670, 4690, 6220) | Bottom-edge state labels and connectors, context only where unresolved | clear |
| state_reset_inputs.png | (870, 4850, 3330, 5420) | /COIN IN (B), V7 (E) and /VB (E) labels [Review 22 Oct: the last label is /V8; correction 11.] | clear |
| state_mid_lower.png | (3030, 3890, 4530, 5060) | Long vertical control routes, context only where unresolved | clear |
| state_bus_mid.png | (3600, 3340, 4590, 5080) | State-output fanout routes | clear |
| state_small_junctions.png | (2910, 2650, 3080, 3070) | Uncertain IC38 clock-route crossings | clear |
| state_counter_joins.png | (3150, 2920, 4000, 3630) | State-output returns to IC32 inputs | clear |
| reset_cap_route.png | (3070, 3570, 3260, 5140) | IC34.9 capacitor and /COIN IN route | clear |

### Wiring-derived description

Four externally supplied lines enter the `42` decoder IC24. Each has a pull-up resistor in RA1. IC24’s selected outputs feed clocks or feedback gates in the nearby flip-flop group. The drawing labels several stages POOL, GRAVEL, SLIP, TUNNEL and HOUSE; these annotations do not by themselves specify how the game changes scenery.

The lower half of IC40 samples a buffered `/HS` signal on the input labelled `/MHL…`. Its complementary output clocks the drawn half of IC49 (`393½`). IC49 outputs and the OR of two of its bits address two `151` multiplexers. Their outputs reach the drawn `/S` and `/R` terminals of IC68 (`279¼`). No timing period or latch pin number is inferred.

A NOR section of IC34 drives a shared active-low clear line for four state sections. One input to this NOR is `/COIN IN (B)`, with 470p to ground; the other comes from a two-bit AND of the counter. The clear/output distinction matters: this capacitor is on **IC34 input 9**, not its output 10.

### Additional input/reference inventory

| Visible label | Direction / sheet | Destination or observation | Confidence |
| --- | --- | --- | --- |
| J/3-100-A | Input, circled I beside the group | IC24.15 and RA1 branch A; first character is uncertain. Margin resembles D7. | uncertain |
| Ditto -B | Input, same I group | IC24.14 and RA1 branch B; margin resembles D16. | uncertain |
| Ditto -C | Input, same I group | IC24.13 and RA1 branch C; margin resembles D15. | uncertain |
| Ditto -D | Input, same I group | IC24.12 and RA1 branch D; margin resembles D14. | uncertain |
| 100-C (candidate reading) | Output / reference, H [Review 22 Oct: M (circled M); correction 12.] | Same net as IC24.13 and input C; left-pointing arrow. Do not silently substitute ICC-C. | uncertain |
| EXTEND | Input, C | Upper data-input route to IC40.2 and IC25.12; label is not barred at this terminal. | clear |
| /HS | Input, E | IC47.2; IC47.1 is Vcc. Original lettering uses a small s. | clear |
| /MHL[0/O?] | Input, E | IC40.11, IC48.3 and IC41.12. Last round glyph uncertain; retain the E sheet letter as drawn. | uncertain |
| /COIN IN | Input, B | IC34.9 and 470p to ground; other fanout not exhaustively traced. | clear |

### IC24 — printed `42`

Crops: state_inputs, full_decoder_inputs, decoder_top_left/right, decoder_bottom_routes. Inverted decoder outputs are numbered by decoded value inside the symbol and package pin outside it. The readable input and output numbers agree with 7442.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 15 | A | Input A of the I-reference group; RA1 branch A to Vcc | clear |
| 14 | B | Input B of that group; RA1 branch B to Vcc | clear |
| 13 | C | Input C, RA1 branch C, and left-pointing 100-C candidate label (H) [Review 22 Oct: (M) 100-C; correction 12.] | clear |
| 12 | D | Input D of that group; RA1 branch D to Vcc | clear |
| 1 | Decoded 0, active low | Upward route then right to IC40.3, the GRAVEL-section clock | clear |
| 2 | Decoded 1, active low | IC47.4 | clear |
| 3 | Decoded 2, active low | Rightward/downward route to IC31.3 (SLIP clock); crossing the IC47.5 route is not a confirmed junction | clear |
| 4 | Decoded 3, active low | Short output stub only; no continuing wire drawn | clear |
| 5 | Decoded 4, active low | Route to IC25.11. Near IC38.3, the crossing with the separate clock return needs confirmation; no extra connection asserted. | uncertain |
| 6 | Decoded 5, active low | Branch up to IC45.1; long rightward route to IC25.3 [Review 22 Oct: not IC45.1; IC25.3 and CAR NO CONT only. Correction 2.] | clear |
| 7 | Decoded 6, active low | IC47.5; do not short it to the crossing decoded-2 line | clear |
| 9 | Decoded 7, active low | Rightward route, stepped upward, then into IC31.11 (TUNNEL-section clock) | clear |
| Decoded 8,9 | Not drawn | No output connections drawn for these decoded values | clear |
| 8,16 | Package power | Not drawn | clear |

### RA1 and added capacitors

| Part / location | Value as drawn | Endpoints | Reading limitation | Confidence |
| --- | --- | --- | --- | --- |
| RA1, branch A | …60; first digit uncertain [Review 22 Oct: reads 560.] | Vcc common → IC24.15 / input A | Four-resistor common-top array; first digit resembles 6 or 5. Do not settle on 660 or 560 ohms from expectation. | uncertain |
| RA1, branch B | Same array marking | Vcc common → IC24.14 / input B | No separate branch value or array pin numbers drawn | uncertain |
| RA1, branch C | Same array marking | Vcc common → IC24.13 / input C / 100-C reference | A damaged/crossed annotation is above the value; not used as an alternative component value | uncertain |
| RA1, branch D | Same array marking | Vcc common → IC24.12 / input D | Value needs a clearer source | uncertain |
| Unnumbered capacitor beside IC49 clock | 470p | IC40.8 / IC49.13 node → ground | Value and node clear; designator not drawn | clear |
| Unnumbered capacitor below IC34 | 470p | IC34.9 / /COIN IN (B) node → ground | On the NOR input wire; not IC34.10 | clear |

### Flip-flop group: notation and pin comparison

The annotation next to the POOL pair reads `74½ ×7`; the lower IC40 section has its own `74½` annotation. The seven grouped halves are the two IC38 sections, upper IC40 section, two IC31 sections and two IC25 sections. They have D, clock, Q, /Q and, where drawn, bubbled CL terminals. The readable numbered pins match the corresponding 7474 half. The second-half Q numeral is repeatedly damaged/open-loop and can look like **7 or 9**. It is therefore recorded as a candidate 9, with the port name Q retained. No confirmed pin-7 Q output is asserted.

The drawing omits preset terminals and some clear/output terminals; no high ties are supplied to make these into a complete simulation model. For each complete package table below, power pins 7/14 are not drawn. A candidate Q numeral resembling 7 must not be interpreted as a power-pin connection.

### IC38 — two sections in the `74½ ×7` group

Crops: state_38, decoder_top_left/right, decoder_controls, state_small_junctions. Local alias S38Q is the Q terminal of the left/first-drawn section; this is the second half by its D12/clock11/clear13 numbering.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 12 | D, first-drawn section | IC40.6, the GRAVEL-section /Q, by the upper return wire [Review 22 Oct: the /TUNNEL rail (IC31.8 /Q, IC80.11, EF); correction 3.] | clear |
| 11 | Clock, first-drawn section | IC47.6 | clear |
| 13 | /CLR, first-drawn section | IC45.3; same net as IC25.13 | clear |
| Q; numeral 9/7 ambiguous | S38Q | Direct wire to IC38.2. The crossing with the vertical wire nearby is not taken as a new junction. | uncertain |
| /Q, first-drawn section | Output label only | No continuing numbered output connection drawn; do not invent pin 8 wiring | clear |
| 2 | D, POOL section | S38Q from first-drawn IC38 section | clear |
| 3 | Clock, POOL section | Candidate source IC40 lower-section Q via the return near x=3010. Junction/crossing with decoded-4 route needs confirmation. | uncertain |
| 5 | Q, POOL section | Feedback loop to IC45.2 | clear |
| 6 | /Q, POOL section | Upper/left return to IC31.2 and IC89.4; other continuing fanout not certified here | clear |
| POOL clear/preset; first-drawn preset | Not drawn | No tied levels inferred. POOL clear is not supplied from the other half merely because it shares the package. | clear |
| 7,14 | Package power | Not drawn | clear |

### IC45 — feedback gate section; device type not printed beside it

Crops: state_38 and decoder_top_left. AND-like body with output bubble; lower/back contour partly eroded. NAND is the reading of the visible symbol, with the damaged outline retained as an uncertainty. Pins 1,2→3 fit a 7400 section.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 1 | Input | IC24.6 (decoded 5) [Review 22 Oct: IC40.8, lower-section /Q (also IC49.13 and the 470p); correction 2.] | clear |
| 2 | Input | IC38.5 feedback | clear |
| 3 | Bubbled output | IC38.13 and IC25.13. Gate body needs confirmation before treating the NAND equation as final. | uncertain |
| Other sections / power | Outside this continuation | Not inventoried; power not drawn here | clear |

### IC40 — upper GRAVEL and lower sampling sections; `74½` annotations

Crops: state_40_25, decoder_top_left/right, counter_inputs, lower_counters, state_counter_joins. The package has one state half and the lower timing/sample half.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 2 | D, GRAVEL section | EXTEND (C) | clear |
| 3 | Clock, GRAVEL section | IC24.1 (decoded 0) | clear |
| 1 | /CLR, GRAVEL section | Shared clear line from IC34.10 | clear |
| 5 | Q, GRAVEL section | Downward return near x=3770 to IC32.1; crossed IC31 Q wires are not joined | clear |
| 6 | /Q, GRAVEL section | IC38.12 by the upper loop; additional rightward fanout remains unresolved [Review 22 Oct: IC73.4, not IC38.12; correction 3.] | clear |
| 12 | D, lower section | IC47.3, the buffered /HS input; also data inputs on IC48/IC41 | clear |
| 11 | Clock, lower section | /MHL[0/O?] (E), also IC48.3 and IC41.12 | uncertain |
| Q; numeral 9/7 ambiguous | Lower section Q | Upward return toward IC38.3; clock-line crossing ambiguity recorded under S4 | uncertain |
| 8 | /Q, lower section | IC49.13 clock and unnumbered 470p to ground. Upward branch exists; its full additional fanout remains unresolved. | uncertain |
| Upper preset; lower clear/preset | Not drawn | No tied levels inferred | clear |
| 7,14 | Package power | Not drawn | clear |

### IC31 — SLIP and TUNNEL sections in `74½ ×7` group

Crops: middle_state, state_40_25, state_clock, state_counter_joins. Local S31TQ denotes the TUNNEL section Q port whose numerical label is uncertain.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 2 | D, SLIP section | IC38.6 /Q from the POOL section | clear |
| 3 | Clock, SLIP section | IC24.3 (decoded 2) | clear |
| 1 | /CLR, SLIP section | IC34.10 common clear | clear |
| 5 | Q, SLIP section | IC32.5 by the down-and-left return | clear |
| 6 | /Q, SLIP section | IC31.12 and, through the downward branch near x=3380, IC73.1 (continuation 4); complete further fanout not certified | uncertain |
| 12 | D, TUNNEL section | IC31.6 | clear |
| 11 | Clock, TUNNEL section | IC24.9 (decoded 7) | clear |
| 13 | /CLR, TUNNEL section | IC34.10 common clear | clear |
| Q; numeral 9/7 ambiguous | S31TQ | Return to IC32.2; branch to IC34.6 | uncertain |
| 8 | /Q, TUNNEL section | Dotted vertical fanout near x=3840 to IC80.11 and /TUNNEL (F), connector EF, followed in continuation 4; complete further fanout not certified. | uncertain |
| Preset terminals | Not drawn | No tied levels inferred | clear |
| 7,14 | Package power | Not drawn | clear |

### IC25 — two HOUSE-related sections in `74½ ×7` group

Crops: state_40_25, decoder_top_right, decoder_bottom_routes, state_bus_right. Upper section uses D12/clock11/clear13; lower section uses D2/clock3/clear1. The annotation above the lower symbol resembles HOUSE but is damaged.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 12 | D, upper section | EXTEND (C), same input-data route as IC40.2 | clear |
| 11 | Clock, upper section | IC24.5 (decoded 4); route subject to the nearby IC38 clock crossing check | uncertain |
| 13 | /CLR, upper section | IC45.3, also IC38.13 | clear |
| Q; numeral 9/7 ambiguous | Upper section Q | IC25.2 via visible dotted branch; rightward/downward return to /EXT.500 (H), traced in continuation 5; Q numeral remains uncertain | uncertain |
| 8 | /Q, upper section | Rightward/downward return to the EJ /EXT.[5/6]00 (F) and /EXT.500 (M) output rail, traced in continuation 5 | uncertain |
| 2 | D, lower section | Upper IC25 Q port; its numeric label is uncertain | clear |
| 3 | Clock, lower section | IC24.6 (decoded 5), shared with IC45.1 [Review 22 Oct: not shared with IC45.1; correction 2.] | clear |
| 1 | /CLR, lower section | IC34.10 common clear | clear |
| 5 | Q, lower section | Down/right then left to IC32.4 and IC34.5, traced in continuation 5 | uncertain |
| 6 | /Q, lower section | IC80.2 via the down-and-right route visible in state_bus_right | clear |
| Preset terminals | Not drawn | No tied levels inferred | clear |
| 7,14 | Package power | Not drawn | clear |

### Counter, two multiplexers and latch

### IC47 — three gate sections; device type not printed beside these gates

Crops: counter_inputs, state_38, counter_logic. The first and third gates have plain AND bodies. The middle gate’s bubbles/body are damaged; its function is conditional. Pin groups 1,2→3; 4,5→6; 12,13→11 are compatible with 7408 sections, but compatibility does not resolve faded bubbles.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 1 | Input to first section | Vcc | clear |
| 2 | Input to first section | /HS (E) | clear |
| 3 | AND output; local HS_BUF | IC40.12; IC48.4 and .12; IC41.3/.2/.1/.15/.14/.13 | clear |
| 4 | Input to middle section | IC24.2 (decoded 1); input bubble visible | clear |
| 5 | Input to middle section | IC24.7 (decoded 6); bubble/outline damaged | uncertain |
| 6 | Middle output | IC38.11. OR-body/input-bubbles/output-bubble reading would implement AND; do not certify that function until the faint lower input/outline is resolved. | uncertain |
| 12 | Input to lower section | IC49.9 (QC) | clear |
| 13 | Input to lower section | IC49.8 (QD) | clear |
| 11 | Lower AND output | IC34.8 | clear |
| Fourth section / power | Outside continuation | Remaining section not inventoried; supply pins not drawn here | clear |

### IC49 — printed `393½`

Crops: state_clock, lower_counters, counter_logic. Clock 13, clear 12, QA/QB/QC/QD at 11/10/9/8 agree with the second half of 74393. The other half is outside this drawn block.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 13 | Clock | IC40.8 /Q; 470p to ground on this node | clear |
| 12 | Clear | IC32.6 | clear |
| 11 | QA | IC48.11 and IC41.11 (select A) | clear |
| 10 | QB | IC39.12 | clear |
| 9 | QC | IC39.13 and IC47.12; dotted branch near the counter | clear |
| 8 | QD | IC47.13; IC48.9 and IC41.9 (select C) | clear |
| First half | Not drawn in this block | No connections assigned to its pins | clear |
| 7,14 | Package power | Not drawn | clear |

### IC39 — OR section; device type not printed here

Crops: lower_counters, counter_logic. Plain OR body, inputs 12/13 and output 11, compatible with 7432.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 12 | Input | IC49.10 (QB) | clear |
| 13 | Input | IC49.9 (QC) | clear |
| 11 | OR output | IC48.10 and IC41.10 (select B) | clear |
| Other sections / power | Outside continuation | Not inventoried; package power not drawn here | clear |

### IC48 — printed `151`

Crops: counter_inputs and lower_counters. Written data, select, enable and output numbers agree with 74151. The right-hand bubbled pin 7 is the enable tied low, not an inverted output.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 4 | D0 | HS_BUF = IC47.3 | clear |
| 3 | D1 | /MHL[0/O?] (E), also IC40.11 and IC41.12 | uncertain |
| 2 | D2 | Vcc | clear |
| 1 | D3 | Vcc | clear |
| 15 | D4 | Vcc | clear |
| 14 | D5 | Vcc | clear |
| 13 | D6 | Vcc | clear |
| 12 | D7 | HS_BUF = IC47.3 | clear |
| 11 | Select A | IC49.11 (QA) | clear |
| 10 | Select B | IC39.11 = OR(IC49.10, IC49.9) | clear |
| 9 | Select C | IC49.8 (QD) | clear |
| 7 | /Enable | Ground | clear |
| 5 | Output | IC68 /S terminal; IC68 pin number not drawn | clear |
| 6 | Complementary output | Not drawn | clear |
| 8,16 | Package power | Not drawn | clear |

### IC41 — printed `151`

Crop: lower_counters. Numbering agrees with 74151. All the explicitly drawn ties are listed; a connection crossing the select bus without a dot is not a tie.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 4 | D0 | Vcc | clear |
| 3 | D1 | HS_BUF = IC47.3 | clear |
| 2 | D2 | HS_BUF = IC47.3 | clear |
| 1 | D3 | HS_BUF = IC47.3 | clear |
| 15 | D4 | HS_BUF = IC47.3 | clear |
| 14 | D5 | HS_BUF = IC47.3 | clear |
| 13 | D6 | HS_BUF = IC47.3 | clear |
| 12 | D7 | /MHL[0/O?] (E) | uncertain |
| 11 | Select A | IC49.11 (QA) | clear |
| 10 | Select B | IC39.11 | clear |
| 9 | Select C | IC49.8 (QD) | clear |
| 7 | /Enable | Ground | clear |
| 5 | Output | IC68 /R terminal; IC68 pin number not drawn | clear |
| 6 | Complementary output | Not drawn | clear |
| 8,16 | Package power | Not drawn | clear |

### IC68 — printed `279¼`

Crop: lower_counters. One latch section is shown, with bubbled /S and /R and an unbubbled Q. There are no drawn terminal numbers. A 74279 package has noninterchangeable latch pin groups; none is selected by guess.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| Number not drawn; /S | Active-low set terminal | IC48.5 | clear |
| Number not drawn; /R | Active-low reset terminal | IC41.5 | clear |
| Number not drawn; Q | Latch output | Wire runs right near y=4790, branching to IC80.12 and IC73.13; see continuation 4 | clear |
| Other inputs/latches; supply | Not drawn in this section | No second set input, package pin assignment, or supply tie inferred | clear |

### Counter reset and shared state clear

### IC32 — four-input NOR section; device type not printed here

Crops: state_clock, counter_logic, state_counter_joins. OR body with output bubble. Written inputs 5,2,4,1 and output 6 are compatible with the input/output group of 7425; that does not establish an unprinted type or unshown strobe connection.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 5 | Top input | IC31.5 (SLIP Q) | clear |
| 2 | Second input | TUNNEL Q port of IC31 (numeral 9/7 unresolved); same net as IC34.6 | uncertain |
| 4 | Third input | IC25.5; also IC34.5, via the return near y=3560 (continuation 5). | uncertain |
| 1 | Bottom input | IC40.5 (GRAVEL Q), downward return near x=3770 | clear |
| 6 | NOR output | IC49.12 clear | clear |
| Other pins / other section | Not drawn or outside scope | No strobe tie supplied from a conventional 7425 pinout; power not drawn here | clear |

### IC34 — two additional NOR sections; device type not printed here

Crops: state_clock, counter_logic, state_counter_joins, reset_cap_route, state_reset_inputs. Both bodies are OR with output bubbles; numbering 8,9→10 and 5,6→4 agrees with 7402. The upper scenery gate 11,12→13 remains in the first section.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 8 | Input to shared-clear section | IC47.11 = AND(IC49.9, IC49.8) | clear |
| 9 | Other clear-section input | /COIN IN (B), with unnumbered 470p to ground | clear |
| 10 | Shared clear output | IC31.1, IC31.13, IC40.1 and IC25.1; dotted branches on the horizontal clear line | clear |
| 6 | Input to other section | IC31 TUNNEL Q port; same net as IC32.2; numerical Q label unresolved | uncertain |
| 5 | Other input | IC25.5, same control net as IC32.4 (continuation 5) | uncertain |
| 4 | Output | Downward wire toward bottom label beginning TUNNEL; exact destination wording/sheet and intervening fanout not fully traced | uncertain |
| Remaining section / power | Outside continuation | No package-wide completeness claim; power not drawn here | clear |

### Limited derived behaviour

Let QA..QD denote IC49 pins 11,10,9,8. The mux select code, from the checked 151 pin assignments, is `k = QA + 2×(QB OR QC) + 4×QD`. With both enables tied to ground:

- IC48 selects HS_BUF for k=0 or 7, the `/MHL…` input for k=1, and Vcc for k=2..6.
- IC41 selects Vcc for k=0, HS_BUF for k=1..6, and the `/MHL…` input for k=7.

These are two mux truth tables derived from the wiring, not a prediction of the latch waveform. IC68’s unnumbered /S and /R receive the respective mux outputs. The pin-level model is incomplete until the unresolved clock/reset routes and omitted latch terminals are reviewed.

For the clearly drawn IC34 clear section, `IC34.10 = NOT((QC AND QD) OR /COIN IN)`. This output reaches the four bubbled CL terminals listed above. No state sequence or pulse duration is deduced from the game names or the capacitors.

### Update to the GRAVEL-control boundary

| IC / pin | Newly established connection | Limit | Confidence |
| --- | --- | --- | --- |
| IC73.6 | IC66.5 | Wire directly between the two gates in state_bus_right | clear |
| IC73.4/.3/.5 → .6 | AND body with three input bubbles and no output bubble: NOR | Input 5 is now traced to IC88.8 in continuation 3. Continuation 4 follows input 3 to IC81.11 (additional crossing L1 uncertain) and input 4 to IC40.6. Pin group is compatible with 7427 | uncertain |
| IC66.3 and .4 | Earlier connections remain: .3 on IC96.13 rail, .4 from IC82.10 | These predecessor circuits are still not fully transcribed | uncertain |

### Continuation pinout review

| Part / gate group | Result | Confidence |
| --- | --- | --- |
| IC24, printed 42 | Readable input/output numbers agree with 7442; omitted outputs stay omitted | clear |
| Grouped 74 halves and lower IC40 | D/clock/clear and first-half Q,/Q numbers agree with 7474; second-half Q numerals remain 9/7 ambiguities, not confirmed disagreements | uncertain |
| IC49, printed 393½ | Drawn second-half numbers agree with 74393 | clear |
| IC48 and IC41, printed 151 | Drawn numbers agree with 74151; pin 7 is grounded enable; pin 6 is not drawn | clear |
| IC68, printed 279¼ | Functional terminal labels read; numbered package-pin comparison impossible because terminal numbers are not drawn | uncertain |
| IC47 middle gate and IC45 feedback gate | Faded contours/bubbles require confirmation; compatible conventional pin groups do not establish a missing symbol feature | uncertain |
| IC32 four-input gate | Visible NOR function; numbering compatible with 7425 input/output group, but no part type or strobe tie is established | clear |

### Continuation unresolved register

| ID | Crop box(es) | Uncertainty / continuation needed | Confidence |
| --- | --- | --- | --- |
| S1 | (720, 2630, 1310, 3180); (880, 2430, 2320, 3410) | Input-group prefix J versus 3, marginal connector marks (D7/D16/D15/D14 candidates), and 100-C versus another damaged reading. Circled I group and H reference are retained. | uncertain |
| S2 | (880, 2430, 2320, 3410) | RA1 value: trailing 60 readable, leading digit resembles 6 or 5. The crossed/faded text above is not a resolved alternative. Four common-to-Vcc branches are clear. | uncertain |
| S3 | (2250, 2370, 3370, 3280); (3270, 2370, 4570, 3480); (880, 3350, 2280, 4500) | Second-half Q numerals on IC38/31/25/40 look like 9 or 7. D12/clock11/clear13 and Q labels suggest standard second-half placement, but this does not settle the ink. Some HOUSE/TUNNEL annotations are faded. | uncertain |
| S4 | (2910, 2650, 3080, 3070); (2030, 2820, 3150, 3430); (1990, 3140, 3370, 3940) | Confirm the IC38.3 clock return, candidate IC40 lower Q, against the nearby decoded-4 crossing. Do not short a decoder output to a flip-flop output based on thick crossing ink. IC25.11 route is retained with this caveat. | uncertain |
| S5 | (2250, 2370, 3370, 3280); (2020, 2290, 3170, 2830) | IC47 middle-gate lower input bubble/body and IC45 body are eroded. AND for IC47.6 and NAND for IC45.3 are provisional symbol readings, not established by device expectations. | uncertain |
| S6 | (880, 3350, 2280, 4500) | Exact /MHL… suffix is 0 or O, unresolved; E reference is readable. The route to IC40.11, IC48.3, IC41.12 is traced. | uncertain |
| S7 | (3270, 2370, 4570, 3480); (4190, 2700, 5650, 3910); (3600, 3340, 4590, 5080) | Finish fanout of IC40.6, IC40.8, IC31.6, IC25 upper Q and /Q, and IC25.5. Known immediate endpoints remain listed; additional control loads are not assumed. | uncertain |
| S8 | (3150, 2920, 4000, 3630); (2550, 3480, 3780, 4410) | Continuation 5 traces the shared IC32.4 / IC34.5 net to IC25.5. Other reset-gate inputs are listed separately, so this does not erase the confirmed counter-clear connection. | uncertain |
| S9 | (1280, 3440, 3120, 5070) | Continuation 4 traces IC68 Q to IC80.12 and IC73.13. All IC68 latch terminal numbers are not drawn. Do not invent a 74279 latch index or a second /S tie. | uncertain |
| S10 | (2980, 4670, 4690, 6220); (3030, 3890, 4530, 5060) | Continuation 4 follows IC31.8 to EF /TUNNEL (F,G) and IC80.11. Finish IC34.4 bottom-edge output label/fanout. Nearby EXT, BRIDGE and TUNNEL labels are not assigned by proximity. | uncertain |
| S11 | (4190, 2700, 5650, 3910) | IC73.6→IC66.5 established; IC88.8→IC73.5. Continuation 4 follows IC73.3 to IC81.11 and IC73.4 to IC40.6. Additional crossing L1 remains uncertain. IC66.4 traces through IC82/IC89 to MH5..MH7. | uncertain |

## Continuation 3 — central decoder and address/control gates

This section adds IC96, the upper input-decode gates, all six drawn IC82 inverter sections, the additional IC81/IC89/IC104 sections, the central IC95/IC56/IC65/IC110 connections, and the drawn IC88 halves. Some gate outlines and long-wire junctions remain uncertain. Lower IC88 input origins and the remaining lower controller are not complete.

**Revision to the first section:** the common IC92.1/IC67.1 select wire is driven by **IC104.3**. Its crossing with the load-labelled wire to IC67.6 near **(5280,1435)** has unusually thick ink. The earlier assertion that the load wire is definitely joined to both selectors is withdrawn; a junction there remains **uncertain**. This does not remove the clearly drawn connection between the two select inputs or the traced IC104.3 driver. No schematic connection is “repaired” because of its expected function.

### Additional crops

| Crop | Pixel box | Use | Confidence |
| --- | --- | --- | --- |
| upper_gate_inputs.png | (4030, 1640, 5680, 2250) | Upper gate terminals and horizontal MH bus | clear |
| upper_left_gates.png | (1450, 1870, 4040, 2350) | Upper IC88 and IC95/82/75/89 context | clear |
| decoder_outputs_detail.png | (5460, 2110, 6830, 2920) | IC96 outputs and central IC95/104/56/65/110 gates | clear |
| decoder_address_routes.png | (4850, 940, 5510, 2180) | High-address rail turns and inverter context | clear |
| control_right_upper.png | (5740, 1920, 6850, 3030) | IC110 output route and IC65 control path | clear |
| decoder_d_gate.png | (5150, 1950, 5520, 2920) | IC104.1/.2/.3, IC96 input D, IC89.12 and IC82.10 | clear |
| high_address_labels.png | (990, 1580, 1860, 2070) | MH0..MH8 label/branch origins | clear |
| upper_bank_gates.png | (4000, 2080, 5190, 2880) | IC75/78/90/70 outputs through IC82 and IC81 | clear |
| mux_select_crossing_check.png | (5180, 1340, 5400, 1570) | Thick load-line/select-wire crossing requiring review | clear |
| decoder_mh8_route.png | (4850, 1950, 5520, 2870) | IC104 and IC96 input neighbourhood; name is positional, not proof of a MH8 tie | clear |
| mux_select_upper_check.png | (5200, 550, 6090, 1220) | Common IC92.1 and IC67.1 route | clear |
| select_d_route_top.png | (4610, 2700, 5390, 4220) | IC96 D and nearby control routes, upper continuation | clear |
| select_d_route_bottom.png | (4610, 4150, 5390, 6100) | IC88.9 to decoder-D return and /M-ROAD label | clear |
| address_input_groups.png | (4150, 580, 5220, 1710) | B-sheet vertical-bit branches feeding upper gates | clear |
| tree_control_routes.png | (5730, 1500, 6840, 2290) | IC110/IC81 tree-control returns and MH-row crossings | clear |
| right_control_returns.png | (6110, 2800, 6780, 3960) | IC96 decoded-zero return through IC82.9/.8 | clear |
| grass_control_returns.png | (6030, 2780, 6800, 4140) | IC56 inputs and IC82.8 return to IC65.11 | clear |
| lower_control_handoff.png | (5730, 3410, 6860, 4250) | IC87.8 common control and IC81.8 HOUSE gate | clear |
| middle_control_handoff.png | (4510, 3390, 6150, 4350) | IC56.1/IC73.3/IC80.3 common-control route | clear |
| address_gate_numbers.png | (4360, 2040, 5230, 2330) | Close reading of IC78, IC90 and IC70 pin numerals/bubbles | clear |
| address_inverter_117.png | (4790, 1320, 5030, 1720) | IC117.3/.4 address-bit inverter | clear |

### Wiring-derived description

MH5, MH6 and MH7 enter IC96 A, B and C. Its D input is the lower IC88 Q output, not an assumed next horizontal counter bit. Selected IC96 outputs enter the central logic and the HOUSE-enable path. The same three horizontal bits also enter a bubbled-input gate, IC89, followed by IC82. Continuation 5 revises the asserted connection from that result to the selector OR gate: IC104.1 is traced directly to V7 (E), and its crossing with IC82.10 remains uncertain (N5).

Separate upper gate groups combine the two sets of vertical inputs. IC78 sections have output bubbles; IC90 has no output bubble; IC70 has bubbles on its inputs. [Review 22 Oct: the second gate is also IC90; correction 1.] These distinctions are retained rather than assigning every U-shaped symbol the same function. Several numerals are damaged and are recorded by input-pad position as well as candidate pin number.

Part numbers are not printed beside most individual gates here. Conventional 74xx numbers mentioned below are pin-group comparisons only. No gate package type is supplied solely because it would make the circuit work.

### IC96 — printed `42`

Crops: high_address_labels, upper_gate_inputs, decoder_d_gate, decoder_outputs_detail, select_d_route_top/bottom. Readable pin numbering agrees with 7442. The numerical output values inside the symbol are distinct from external pin numbers.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 15 | A | MH5 (B); also IC89.1 | clear |
| 14 | B | MH6 (B); also IC89.2 | clear |
| 13 | C | MH7 (B); also IC89.13 and IC66.3 [Review 22 Oct: not IC66.3; correction 6.] | clear |
| 12 | D | IC88.9 (lower Q), also IC104.2. Return bends near (5280,4215) and (4940,4215). | clear |
| 1 | Decoded 0, active low | Rightward then downward route to IC82.9. It crosses the decoded-4 route without a confirmed junction. | clear |
| 2 | Decoded 1 | Short stub / no continuing wire drawn | clear |
| 3 | Decoded 2, active low | IC110.4 | clear |
| 4 | Decoded 3 | Short stub / no continuing wire drawn | clear |
| 5 | Decoded 4, active low | IC110.5 | clear |
| 6 | Decoded 5, active low | IC95.5 | clear |
| 7 | Decoded 6, active low | IC95.4; numeral is faint but readable as 7 in this route | clear |
| 9 / decoded 7 position | No established continuing wire | Lower output-number text is damaged; no destination assigned | uncertain |
| Decoded 8 and 9 | Not drawn | No connections supplied from a conventional pinout | clear |
| 8,16 | Package power | Not drawn | clear |

### IC89 — upper high-address NOR section; type not printed here

Crops: decoder_d_gate and decoder_mh8_route. AND body with three input bubbles, no output bubble: NOR. Pins 1,2,13→12 are compatible with 7427.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 1 | Input | MH5, shared with IC96.15 | clear |
| 2 | Input | MH6, shared with IC96.14 | clear |
| 13 | Input | MH7, shared with IC96.13 | clear |
| 12 | NOR output | IC82.11 | clear |
| Other sections / power | See other sections | IC89.6 is below; IC89.8 is in the first-section boundary ledger. Power not drawn. | clear |

### IC104 — selector OR section and central gate section; type not printed here

Crops: decoder_d_gate, decoder_outputs_detail, mux_select_upper_check, mux_select_crossing_check. The selector gate is drawn with an OR body and no output bubble. The central gate uses the bubbled-AND representation; one input contour is faded.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 1 | Selector-gate input | V7 (E), traced in continuation 5. Earlier definite IC82.10 connection withdrawn; crossing N5 remains uncertain. | uncertain |
| 2 | Selector-gate input | IC88.9 / IC96.12 D net | clear |
| 3 | Selector OR output | IC92.1 and IC67.1 through the long upward route. Possible additional join to IC67.6 at (5280,1435) unresolved. [Review 22 Oct: no join; see the review, C1.] | clear |
| 13 | Central-gate input | Upper horizontal route near y=2035, candidate MH8; final bus/junction assignment needs confirmation [Review 22 Oct: MH8 confirmed, dot at (5886,2036).] | clear |
| 12 | Central-gate input | IC95.6; input bubble/contour damaged | uncertain |
| 11 | Central-gate output | IC56.2. Output bubble and upper input bubble are visible. OR is the reading if both input bubbles are present; do not restore the faded lower bubble by pinout alone. | uncertain |
| Other sections / power | Recorded elsewhere / not drawn | IC104.8 side-line and IC104.6 lower OR sections remain as previously recorded; package power not drawn | clear |

### IC95 — central two-input gate section; type not printed here

Crop: decoder_outputs_detail. Output bubble is visible; the AND-versus-OR body contour is eroded. Candidate NAND reading, with pins 4,5→6 compatible with 7400, remains provisional. [Review 22 Oct: OR body with bubbles on the inputs and the output: AND, as IC95 on sheet B. Correction 9.]

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 4 | Input | IC96.7 (decoded 6) | clear |
| 5 | Input | IC96.6 (decoded 5) | clear |
| 6 | Bubbled output | IC104.12; exact gate function awaits contour confirmation | uncertain |
| Other section / power | See upper IC88 reset gate below | Power not drawn; other package sections not inventoried | clear |

### IC56 — central input gate and GRASS-enable gate; type not printed here

Crops: decoder_outputs_detail, grass_control_returns, middle_control_handoff, lower_control_handoff. The input gate is OR-shaped with input bubbles only, hence NAND. The output gate’s contour remains eroded as recorded in the first section.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 2 | Input to first gate | IC104.11 | clear |
| 1 | Other input | Common-control route also reaching IC73.3 and IC80.3; continuation 4 follows it to IC81.11, with an uncertain additional crossing at IC75.6 (L1) [Review 22 Oct: the rail is IC68 Q, not IC81.11; correction 5.] | clear |
| 3 | NAND output | IC65.12 and IC56.12, with a visible branch dot | clear |
| 12 | Input to output gate | IC56.3 | clear |
| 13 | Other output-gate input | IC87.8, same vertical route as IC81.5 and IC81.10 | clear |
| 11 | Output | Both IC105 enables and /GRASS AREA (C). Output bubble clear; NAND-versus-NOR body uncertainty retained. | uncertain |
| Other sections / power | Outside these sections | Not inventoried; power not drawn | clear |

### IC65 — central NOR section; type not printed here

Crops: decoder_outputs_detail, right_control_returns, grass_control_returns, tree_control_routes. OR body with output bubble; pins 11,12→13 agree with a 7402 NOR group.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 12 | Input | IC56.3 | clear |
| 11 | Input | IC82.8, via the left-hand return from the inverter output; also IC81.9 | clear |
| 13 | NOR output | Vertical route toward IC81.4 and the IC110.10 return. Shared-row crossings near y=2035 remain uncertain; see C5. [Review 22 Oct: IC81.4 only; no junction at (6380,2036). Correction 7.] | clear |
| Other sections / power | See first section | /SLIDE gate at pins 5,6→4 is already recorded; remaining sections/power not inventoried | clear |

### IC110 — central and tree-bank sections; type not printed here

Crops: control_right_upper, tree_control_routes and prom134_enables. The central symbol looks OR-shaped without a readable output bubble. Its input contours are faded; possible lost input bubbles must not be supplied to make it agree with another section.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 4 | Input to central gate | IC96.3 (decoded 2) | clear |
| 5 | Input to central gate | IC96.5 (decoded 4) | clear |
| 6 | Central output | Upward wire to IC110.9. Visible OR-like body; an unqualified OR equation is withheld because input-bubble ink is damaged. | uncertain |
| 9 | Input to tree-bank gate | IC110.6 | clear |
| 10 | Other tree-bank input | Return toward the IC65.13 / IC81.4 route, crossing the MH-row area; junctions not fully resolved [Review 22 Oct: MH8, the bottom bus row, shared with IC104.13. Correction 7.] | clear |
| 8 | Tree-bank NAND output | IC113.23, as recorded in the PROM table | clear |
| Remaining sections / power | Not fully inventoried | The apparent difference between the two body styles is not resolved by assigning a package type; power not drawn | uncertain |

### IC81 — four NAND sections; type not printed here

Crops: upper_bank_gates, tree_control_routes, prom134_enables, lower_control_handoff and house_enable. Visible AND bodies with output bubbles. The four written input/output groups are compatible with 7400.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 13 | Upper-left gate input | IC82.12 | clear |
| 12 | Other upper-left input | IC90.8 | clear |
| 11 | Upper-left NAND output | Downward control route near x=4480; downstream fanout not fully traced [Review 22 Oct: connector FD (R-SIDE, H), IC87.13 and lower IC88.11; correction 5.] | clear |
| 1 | Upper-right gate input | IC82.2 | clear |
| 2 | Other upper-right input | IC70.6 [Review 22 Oct: IC90.6; correction 1.] | clear |
| 3 | Upper-right NAND output | Leftward then downward route near x=4690; reaches lower IC88.13 clear and IC87.12. Additional branches not exhaustively recorded. | clear |
| 4 | Tree-gate input | Candidate IC65.13 route; crossings with the upper horizontal row remain unresolved | uncertain |
| 5 | Other tree-gate input | IC87.8, also IC56.13 and IC81.10 | clear |
| 6 | Tree NAND output | IC112.1 and .15 | clear |
| 9 | HOUSE-gate input | IC82.8, the inversion of IC96 decoded zero | clear |
| 10 | Other HOUSE-gate input | IC87.8 | clear |
| 8 | HOUSE NAND output | IC98.15 and /HOUSE ST (C) | clear |
| Power terminals | Not drawn | No implicit package supply wiring added | clear |

### IC82 — six inverter sections; type not printed beside symbols

Crops: upper_bank_gates, upper_left_gates, decoder_d_gate, lower_control_handoff and right_control_returns. Some symbols have an input bubble and others an output bubble; both invert. All six readable pin pairs match 7404.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 1 | Input | IC78.8 | clear |
| 2 | Inverted output | IC81.1 | clear |
| 3 | Input | MH6 (B), upper-left horizontal-bit gate group [Review 22 Oct: M2V6; correction 8.] | clear |
| 4 | Inverted output | IC75.11 | clear |
| 5 | Input | MH8 (B) [Review 22 Oct: M2V5; correction 8.] | clear |
| 6 | Inverted output | IC75.5 | clear |
| 9 | Input | IC96.1, decoded-zero output | clear |
| 8 | Inverted output | IC81.9 and IC65.11 | clear |
| 11 | Input | IC89.12, high-address NOR output | clear |
| 10 | Inverted output | IC66.4 and bottom /[0/O]-AREA (H). Earlier definite IC104.1 fanout withdrawn; see crossing N5. | clear |
| 13 | Input | IC78.6 | clear |
| 12 | Inverted output | IC81.13 | clear |
| Power terminals | Not drawn | No supply ties inferred | clear |

### Upper vertical-input gate groups

### IC78 — two four-input NAND sections; type not printed here

Crops: address_input_groups, upper_gate_inputs, address_gate_numbers, upper_bank_gates. Bodies are AND-shaped with output bubbles. Some second-section numerals are faded; positional descriptions prevent silently normalizing them.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 1 | First NAND input | M1V0 (B) | clear |
| 2 | Second input | M1V1 (B) | clear |
| 5 | Third input as drawn | M1V3 (B) | clear |
| 4 | Fourth input as drawn | M1V4 (B) | clear |
| 6 | First NAND output | IC82.13 | clear |
| 13 | Second-section leftmost input | M2V3 (B) | clear |
| Second pad; candidate 9 | Second-section input | M2V5 (B); pin numeral eroded | uncertain |
| Third pad; candidate 10 | Second-section input | M2V6 (B); pin numeral eroded | uncertain |
| 12 | Second-section rightmost input | M2V7 (B) | clear |
| 8 | Second NAND output | IC82.1 | clear |
| Other package pins | Not drawn | No power/unused-pin ties inferred. Candidate numbers fit 7420 but are not certified by that fit. | clear |

### IC90 — four-input AND section; type not printed here

Crops: address_input_groups, upper_gate_inputs, address_gate_numbers, upper_bank_gates. No output bubble is drawn. Two input numerals are damaged.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 13 | Leftmost input | M1V2 (B) | clear |
| 12 | Second input | M1V5 (B) | clear |
| Third pad; 10/11 ambiguous | Third input | M1V6 (B) | uncertain |
| Fourth pad; 9/7 ambiguous | Fourth input | M1V7 (B) | uncertain |
| 8 | AND output | IC81.12 | clear |
| Other package pins | Not drawn | A 7421 comparison would expect 13,12,10,9→8. If the ambiguous text is actually 11 or 7 it disagrees with that candidate group; no printed type settles the issue. | uncertain |

### IC117 — additional address-bit inverter section; type not printed here

Crops: address_input_groups, address_inverter_117, upper_gate_inputs. Triangle with output bubble, pin pair 3→4 compatible with 7404. This is separate from the lower pin-1→2 inverter used by PR137.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 3 | Input | M2V2 (B), branching downward from the third M2V low-bit line | clear |
| 4 | Inverted output | IC70.4 [Review 22 Oct: IC90.4; correction 1.] | clear |
| Other sections / power | See earlier section / untraced | Lower pins 1→2 are recorded in the PR137 boundary ledger; other inverter sections and power remain untraced | clear |

### IC70 — four-input NOR section; type not printed here

[Review 22 Oct: this gate is **IC90**, not IC70 (correction 1). Its drawing conflicts with the other IC90 section; see "Still open" in the review.]

Crops: address_gate_numbers, address_input_groups, address_inverter_117, upper_bank_gates. AND body with input bubbles, no output bubble: NOR. Written 1,2,4,5→6 is compatible with a 7425 input/output group, without establishing an unshown strobe tie.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 2 | Leftmost input | M2V0 (B) | clear |
| 1 | Second input | M2V1 (B) | clear |
| 4 | Third input | IC117.4, inverted M2V2 | clear |
| 5 | Rightmost input | M2V4 (B) | clear |
| 6 | NOR output | IC81.2 | clear |
| Other terminals | Not drawn | No additional strobe, unused-input, or power tie is inferred | clear |

### Upper horizontal-bit gates and IC88

### IC75 — two upper three-input NAND-like sections; type not printed here

Crops: upper_left_gates, upper_gate_inputs and upper_bank_gates. The section at output 6 has a clear output bubble. The other section is more eroded; compatible numbering is not used to replace damaged numerals or bubbles.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 5 | Input to output-6 section | IC82.6, inverted MH8 [Review 22 Oct: inverted M2V5; correction 8.] | clear |
| 4 | Other input | M2V7 (B) | clear |
| 3 | Other input | M2V6 (B) | clear |
| 6 | NAND output | Down/right route through the central wire bundle; final downstream endpoint unresolved | uncertain |
| 9 | Input to output-8 section | MH7 (B) [Review 22 Oct: M2V5; correction 8.] | clear |
| 11 | Middle input | IC82.4, inverted MH6 [Review 22 Oct: inverted M2V6; correction 8.] | clear |
| Third input; 10/13 ambiguous | Other input | MH5 (B); printed-looking final stroke may be 0 or 3 [Review 22 Oct: M2V7; pin 10 in a 7410. Correction 8.] | uncertain |
| 8 | Output of eroded section | IC89.5; output bubble/body contour needs confirmation before a final NAND equation | uncertain |
| Other terminals | Not fully inventoried | A 7410 comparison expects 9,10,11→8. Candidate 13 would disagree with that group, but device type is unprinted. Power not drawn. | uncertain |

### IC95 — upper IC88 clear gate section; type not printed here

Crop: upper_left_gates. Two inputs, output bubble, damaged body contour. NAND is a candidate reading; the output connection is readable. [Review 22 Oct: OR body with input and output bubbles: AND. Correction 9.]

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 12 | Input | MH8 (B) | clear |
| 13 | Input | MH7 (B) | clear |
| 11 | Bubbled output | Upper IC88.1 clear; body contour damaged, so NAND equation remains provisional | uncertain |
| Other sections / power | See central section | Central pins 4,5→6 recorded above; remaining sections and power not inventoried | clear |

### IC88 — two flip-flop sections, `74½` notation

Crops: upper_left_gates, select_d_route_bottom, bottom_control_mid. Upper part annotation is damaged; the lower 74½ notation is clearer. The drawn D/clock/clear and lower Q,/Q numbering agrees with 7474. Missing preset/clear terminals are not filled in.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 2 | D, upper half | MH6 (B) | clear |
| 3 | Clock, upper half | MH5 (B) | clear |
| 1 | /CLR, upper half | IC95.11 | clear |
| 6 | /Q, upper half | IC89.3 | clear |
| Upper Q | Not drawn as a connected terminal | Q is labelled in the symbol, but no output wire/pin number is supplied | clear |
| 12 | D, lower half | /VB (E), traced in continuation 4 [Review 22 Oct: /V8 (E); correction 11.] | clear |
| 11 | Clock, lower half | IC81.11 rail, followed in continuation 4; additional crossing L1 remains uncertain | uncertain |
| 13 | /CLR, lower half | IC81.3 by the route near x=4690; also reaches IC87.12 | clear |
| 9 | Q, lower half | IC96.12 and IC104.2 via the return near x=4940 and x=5280 | clear |
| 8 | /Q, lower half | /M-ROAD (D) local reference; also IC73.5 and other lower-gate branches not exhaustively traced | clear |
| Preset terminals; supply | Not drawn | No supply or inactive preset levels inferred | clear |

### IC89 — upper state/horizontal NOR section; type not printed here

Crops: upper_left_gates and decoder_controls. AND body with bubbles on three inputs and no output bubble: NOR. Pins 3,4,5→6 are compatible with 7427.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 5 | Input | IC75.8 | clear |
| 3 | Input | IC88.6, upper /Q | clear |
| 4 | Input | IC38.6, POOL /Q return, as traced in continuation 2 | clear |
| 6 | NOR output | Downward rail near x=3935, then right near y=4680 to IC89.9 and IC72.10 (continuation 5) | uncertain |
| Other sections / power | See other tables | Pins 1,2,13→12 recorded above; 9,10,11→8 in PR137 boundary ledger. Supply not drawn. | clear |

### Established control-boundary updates

| Earlier boundary | Current result | Remaining limitation | Confidence |
| --- | --- | --- | --- |
| IC96.12 / IC104.2 | IC88 lower Q pin 9 | Lower IC88 data/clock origin still pending | clear |
| /M-ROAD (D) at IC58.2 | Local labelled source IC88.8 /Q established | Full generating state logic remains incomplete | clear |
| IC66.4 | IC82.10, inverse of IC89.12 NOR(MH5,MH6,MH7) | Other IC66 inputs retain their separate traced endpoints | clear |
| IC73.5 | IC88.8 /M-ROAD | Continuation 4 traces .4 to IC40.6 and .3 to the IC81.11 shared rail; L1 remains uncertain | clear |
| IC56.13 / IC81.5 / IC81.10 | Common driver IC87.8 | Continuation 4 adds IC87 inputs; see its tables and L1/L2 | clear |
| IC81.9 / IC65.11 | IC82.8, inversion of IC96.1 decoded zero | Route established, including the dotted branch at inverter output | clear |
| IC110.9 | IC110.6 | Central IC110 gate’s input-bubble contour still uncertain | clear |
| IC81.4 / IC110.10 | Candidate common IC65.13 return | Shared-row crossing/junction issue remains; no final equation supplied [Review 22 Oct: IC81.4 = IC65.13; IC110.10 = MH8. Correction 7.] | clear |

### Limited derived function

For the checked `42` decoder inputs, the input code is `MH5 + 2×MH6 + 4×MH7 + 8×IC88.Q(lower)`. The drawn output-zero wire goes through IC82 to produce its complement at IC82.8. The HOUSE gate then combines IC82.8 with IC87.8 at IC81 pins 9 and 10. This describes the actual named pins; it does not identify a gameplay region from a decoder value.

IC89.12 is `NOT(MH5 OR MH6 OR MH7)`, and IC82.10 inverts it. IC104.3 combines the directly traced V7 (E) input and IC88 lower Q through an OR symbol; the possible additional IC82.10 crossing is N5. The possible additional load-line junction on its upward route remains unresolved, so no complete electrical model of the mux-select net is claimed.

No new passive component was found in these cropped gate/decoder sections. This does not finish the passive inventory of the remaining lower controller.

### Continuation 3 unresolved register

| ID | Crop box(es) | Uncertainty / required continuation | Confidence |
| --- | --- | --- | --- |
| C1 | (5180, 1340, 5400, 1570); (5200, 550, 6090, 1220); (5150, 1950, 5520, 2920) | Common selector driver IC104.3 is established. Thick ink near (5280,1435) could represent a join to the load line or a blot at a crossing. Earlier definite IC67.6→select tie withdrawn; do not assert either connection or isolation until reviewed. [Review 22 Oct: no join; see the review.] | clear |
| C2 | (4360, 2040, 5230, 2330) | IC90 third/fourth input glyphs: 10 versus 11, 9 versus 7. IC78 second-section middle inputs: candidates 9 and 10. Candidate conventional pin groups are comparisons, not substituted readings. | uncertain |
| C3 | (1450, 1870, 4040, 2350) | IC75 output-8 section third-input glyph: 10 versus 13, and faded output bubble/body. Upper IC95 body contour and upper IC88 part annotation are also damaged. | uncertain |
| C4 | (5460, 2110, 6830, 2920); (5740, 1920, 6850, 3030) | Confirm IC95.6 gate body, IC104.12 bubble, IC56.11 body, and IC110.6 input contours. Apparent OR versus NAND representations in IC110 are not resolved by assuming a package type. IC96 lower decoded-7 pin/stub text also damaged. [Review 22 Oct: IC95.6 is AND (correction 9); IC110.6 is NAND; IC56.11 is NAND.] | uncertain |
| C5 | (5730, 1500, 6840, 2290); (5740, 1920, 6850, 3030); (6300, 1270, 7100, 1910) | Finish junction review of IC65.13 route toward IC81.4 / IC110.10, including the horizontal row near y=2035. IC104.13 candidate MH8 route needs confirmation. Do not connect every crossing simply because the ink thickens. [Review 22 Oct: resolved, correction 7.] | clear |
| C6 | (4000, 2080, 5190, 2880); (3750, 2020, 5630, 3350); (4610, 2700, 5390, 4220) | Continuation 4 traces IC81.11 into the common-control and lower IC88 clock rail; its possible crossing/join with IC75.6 remains L1. Complete fanout of IC75.6 is unresolved. IC81.3→lower IC88 clear is established; other branches are not exhaustively inventoried. | uncertain |
| C7 | (4510, 3390, 6150, 4350); (6030, 2780, 6800, 4140); (5730, 3410, 6860, 4250) | Continued in section 4: shared net reaches IC81.11, IC73.4 reaches IC40.6, and IC87.8 takes /ROAD and IC80.4. See L1 for the unresolved IC75.6 crossing and L2 for remaining fanout checks. | uncertain |
| C8 | (4610, 4150, 5390, 6100); (3780, 4900, 5770, 6210); (1450, 1870, 4040, 2350) | Continuation 4 adds IC88 D12=/VB (E) and clock11 from the IC81.11 rail, subject to L1. Continuation 5 follows upper IC89.6 to IC89.9/IC72.10; complete additional Q,/Q fanout still needs review. | uncertain |

## Continuation 4 — lower gates, ROAD and SLIP boundaries

This continuation records the four drawn IC80 gate sections, three IC87 sections, two IC73 sections, two IC94 sections, the lower inverter marked IC59, IC74's ROAD half and additional IC117 wiring. It follows IC68 Q into this network. It does **not** close every long-wire branch, certify the BRIDGE AP source, or resolve earlier damaged pin readings. Where an earlier section says an endpoint is unfinished, the explicit endpoint updates here supersede that limited scope.

### Additional crops

All boxes refer to the original source PNG. Long or wide context strips were supplemented by overlapping native-size crops for terminal and junction readings.

| Crop | Pixel box | Use | Confidence |
| --- | --- | --- | --- |
| clear_route.png | (3030, 3350, 3320, 5150) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_gate_bank.png | (4350, 3880, 6800, 4950) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_gate_inputs.png | (3200, 3890, 4600, 5400) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_bank_right.png | (5000, 4810, 6850, 5900) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_left_routes.png | (1260, 4690, 3120, 5500) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_mid_routes.png | (2980, 4670, 4650, 5510) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_bank_left_native.png | (4350, 3880, 5580, 4940) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_bank_right_native.png | (5520, 3880, 6790, 4940) | Lower-control source, terminal or wire-continuity inspection | clear |
| state_source_routes.png | (3720, 2720, 4910, 3970) | Lower-control source, terminal or wire-continuity inspection | clear |
| state_common_driver.png | (4200, 2350, 4780, 3550) | Lower-control source, terminal or wire-continuity inspection | clear |
| road_inputs_left.png | (900, 4780, 1460, 5710) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_bus_origins.png | (2950, 3380, 4070, 3950) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_94_route.png | (5240, 3500, 5480, 5500) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_88_inputs.png | (4320, 4880, 5000, 5880) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_94_symbols.png | (5180, 4900, 5810, 5900) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_slip_labels.png | (5140, 5760, 6560, 6220) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_route_returns.png | (3650, 3520, 4970, 4350) | Lower-control source, terminal or wire-continuity inspection | clear |
| pool_control_origin.png | (6370, 3880, 6700, 5780) | Lower-control source, terminal or wire-continuity inspection | clear |
| middle_horizontal_routes.png | (5290, 3260, 6790, 3720) | Lower-control source, terminal or wire-continuity inspection | clear |
| road_ff_native.png | (1250, 5260, 2320, 6220) | Lower-control source, terminal or wire-continuity inspection | clear |
| state_bottom_sources.png | (3150, 3400, 4380, 3870) | Lower-control source, terminal or wire-continuity inspection | clear |
| road_to_wall.png | (1700, 5240, 4420, 5450) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_bus_strip.png | (3250, 3600, 3980, 5460) | Lower-control source, terminal or wire-continuity inspection | clear |
| lower_gate_bus_strip.png | (4400, 3390, 4900, 5720) | Lower-control source, terminal or wire-continuity inspection | clear |
| road_inputs_upper.png | (1210, 2370, 1610, 5330) | Lower-control source, terminal or wire-continuity inspection | clear |
| road_input_origins.png | (880, 650, 1660, 2510) | Lower-control source, terminal or wire-continuity inspection | clear |
| slip_input_return.png | (3190, 2980, 3460, 4840) | Lower-control source, terminal or wire-continuity inspection | clear |
| gate_87_first.png | (2500, 1870, 4040, 2350) | Lower-control source, terminal or wire-continuity inspection | clear |
| road_input_vertical_a.png | (1290, 2280, 1410, 3900) | Lower-control source, terminal or wire-continuity inspection | clear |
| road_input_vertical_b.png | (1290, 3850, 1410, 5380) | Lower-control source, terminal or wire-continuity inspection | clear |
| road_wall_left_native.png | (1700, 5250, 3100, 5460) | Lower-control source, terminal or wire-continuity inspection | clear |
| road_wall_right_native.png | (3060, 5250, 4420, 5460) | Lower-control source, terminal or wire-continuity inspection | clear |

### IC80 — four drawn two-input gate sections; type not printed beside them

Crops: middle_control_handoff, state_bus_right, lower_bank_left_native, lower_bank_right_native, lower_gate_inputs, lower_mid_routes, lower_bank_right and lower_94_symbols. The 2,3→1 and 8,9→10 sections have AND bodies with input bubbles and no output bubble: NOR. The 5,6→4 section has an OR body and a damaged output bubble: NOR is a candidate, not a repaired reading. The 11,12→13 section has an AND body, a clear input-11 bubble and a damaged input-12 bubble: candidate NOR. The four numbered groups are compatible with 7402, but no printed type has been established.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 2 | Upper NOR input | IC25.6, lower-section /Q, via the down-and-right return | clear |
| 3 | Upper NOR input | Shared rail with IC73.3 and IC56.1; followed upward to IC81.11. Possible additional IC75.6 junction remains L1. [Review 22 Oct: IC68 Q, not IC81.11; correction 5.] | clear |
| 1 | Upper NOR output | Downward run near x=5195 to the horizontal line near y=4260, reaching IC80.6. Leftward branches still need the L2 review. | clear |
| 6 | Middle OR-body input | IC80.1 | clear |
| 5 | Middle OR-body input | IC80.13, by the upward return near x=4140 and rightward run near y=4300 | clear |
| 4 | Middle output | IC87.9; downward return then left to IC94.5 and IC94.9. Output-bubble erosion prevents an unconditional NOR equation. | uncertain |
| 11 | Lower-left bubbled input | IC31.8, TUNNEL-section /Q, on the vertical rail near x=3840; also EF /TUNNEL (F,G) | clear |
| 12 | Lower-left input; bubble damaged | IC68 Q, unnumbered terminal, by the rightward line near y=4800 and dotted branch near x=3760 | clear |
| 13 | Lower-left output | IC87.5; upward return to IC80.5; bottom output TUNNEL AP (C). Candidate NOR because input-12 bubble is damaged. | uncertain |
| 9 | Lower-right NOR input | IC94.6 | clear |
| 8 | Lower-right NOR input | IC94.8 | clear |
| 10 | Lower-right NOR output | IC104.4 and IC58.12, as already recorded at the PR137 output boundary | clear |
| Supply pins | Not drawn | No power or unused-pin ties inferred from the compatible 7402 pinout | clear |

### IC87 — three drawn sections in this continuation; type not printed here

Crops: lower_bank_right_native, lower_gate_inputs, lower_88_inputs, bottom_control_mid, road_wall_left_native and road_wall_right_native. Pins 4,5→6 and 9,10→8 have plain AND bodies. Pins 12,13→11 have an OR body with input and output bubbles, also implementing AND. These groups are compatible with 7408. The complete package has not been certified from a printed part number.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 4 | WALL-gate input | IC74 /Q, labelled /ROAD (C). Follow its upper return near y=5300 into this input; this is the complementary output, not IC74 Q. | clear |
| 5 | WALL-gate input | IC80.13 | clear |
| 6 | AND output; WALL annotation | IC72.1 and IC117.1. The horizontal wire continues to the inverter-input branch near x=6300. | clear |
| 10 | Common-enable AND input | Same IC74 /Q (/ROAD) wire as IC87.4, through the upward return near x=3680 and rightward row near y=4120 | clear |
| 9 | Common-enable AND input | IC80.4 | clear |
| 8 | Common-enable AND output | IC81.5, IC81.10 and IC56.13, by the established vertical return | clear |
| 13 | Bubbled-input/output AND section | IC81.11 rail, also the IC88 lower clock rail. L1 retains a possible additional junction with IC75.6. [Review 22 Oct: IC81.11, FD and IC88.11 only; L1 is a crossing.] | clear |
| 12 | Other bubbled input | IC81.3 rail, shared with lower IC88.13 clear | clear |
| 11 | AND output | IC94.4 and bottom-edge barred …-LINE label (C); first character resembles M or Y, not certain | uncertain |
| Remaining section; supply | Not established in this continuation | No additional gate connections or supply ties inferred | clear |

### IC73 — two three-input NOR sections; type not printed here

Crops: state_bus_right, state_common_driver, lower_bank_left_native, slip_input_return, lower_mid_routes, lower_94_symbols. Both have AND bodies with input bubbles and no output bubble. The top bubble of the lower section is damaged, so its complete NOR reading is conditional. Groups 3,4,5→6 and 1,2,13→12 are compatible with 7427.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 4 | Upper-section input | IC40.6, GRAVEL-section /Q, via the upper return and stepped-down wire | clear |
| 3 | Upper-section input | IC81.11 shared rail; also IC56.1 and IC80.3. Possible additional IC75.6 junction remains L1. [Review 22 Oct: IC68 Q rail, not IC81.11; correction 5.] | clear |
| 5 | Upper-section input | IC88.8, local /M-ROAD source | clear |
| 6 | Upper NOR output | IC66.5, GRAVEL-control input | clear |
| 1 | Lower-section top input | IC31.6, SLIP-section /Q, down the rail near x=3380, then right near y=4770 | clear |
| 13 | Lower-section middle input | IC68 Q unnumbered terminal, on the horizontal row near y=4800 | clear |
| 2 | Lower-section bottom input | IC88.8 (/M-ROAD), by the dot on its vertical rail near x=4860 | clear |
| 12 | Lower output, SLIP annotation | IC59.13 inverter input. Candidate NOR of the three recorded inputs; top input-bubble contour is damaged. | uncertain |
| Other section; supply | Not established here | No unshown terminals or ties inferred | clear |

### IC94 — two three-input NAND sections; type not printed here

Crops: lower_94_route, middle_horizontal_routes, lower_94_symbols, lower_bank_right and pool_control_origin. The upper body is OR with bubbles on all three inputs and no output bubble: NAND. The lower body is AND with an output bubble: NAND. The upper middle-input numeral is damaged and resembles **1 or 3**. A 7410 comparison expects 3 in the 3,4,5→6 group; that comparison must not substitute for the printed reading. The lower group 9,10,11→8 is compatible with 7410.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 4 | Upper NAND top input | IC87.11 | clear |
| Middle input; numeral 1/3 unresolved | Upper NAND middle input | IC96.1 decoded-zero wire, also IC82.9, followed left near y=3570 then down near x=5320 | uncertain |
| 5 | Upper NAND bottom input | IC80.4; same node as IC94.9, by the dot near (5315,5235) | clear |
| 6 | Upper NAND output | IC80.9 | clear |
| 9 | Lower NAND top input | IC80.4; same node as IC94.5 | clear |
| 11 | Lower NAND middle input | IC74 Q, ROAD, by the lower of the ROAD output return wires | clear |
| 10 | Lower NAND bottom input | IC88.8 (/M-ROAD), dotted branch from that rail | clear |
| 8 | Lower NAND output | IC80.8; separate downward branch to a barred bottom-edge label ending SLIP, exact prefix unreadable (C) | uncertain |
| Remaining section; supply | Not established here | No additional pin connections inferred | clear |

### IC59 — lower inverter section; type not printed here

Crops: lower_94_symbols and lower_slip_labels. The designator reads 59, with a dark/blotted first digit; it is **not silently identified with the IC39 OR gate** recorded beside IC49. If the first digit is disputed on independent review, retain the position and the 13→12 terminal pair. The visible symbol is a triangle with output bubble. Pins 13→12 are compatible with 7404.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 13 | Inverter input | IC73.12, SLIP-annotated local wire | clear |
| 12 | Inverter output | /SLIP (C) and connector FA beside the second /SLIP label; sheet F is visible below the label in the extended continuation-5 crop | clear |
| Other sections; supply | Not established here | No package-wide inventory or ties inferred | clear |

### IC74 — ROAD flip-flop, printed `74½`; terminals unnumbered

Crops: road_input_origins, road_input_vertical_a/b, road_inputs_left, road_ff_native, road_wall_left_native/right_native. D, CK, Q, /Q and bubbled CL are drawn. **None has a printed pin number beside this symbol.** The 7474 half and package pins cannot be assigned from these labels alone.

The two long vertical load-reference wires originate at the B-sheet labels /M1VL… and /M2VL…. Their crossings with /HS, /MHL…, /COIN IN and V7 are not assumed to be junctions. Their final spelling retains U1's 0/O/D uncertainty.

| Drawn terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| D; number not drawn | Data | /VB (E), from the dotted branch near (1410,5390); also continues right to IC88.12 [Review 22 Oct: /V8 (E); correction 11.] | clear |
| CK; number not drawn | Clock | /M1VL[0/O/D?] (B), followed down the right-hand load-reference rail near x=1365 | uncertain |
| CL; number not drawn | Active-low clear | /M2VL[0/O/D?] (B), left-hand rail near x=1325, turning right near y=5300 into CL | uncertain |
| Q; number not drawn | ROAD | ROAD (C); ROAD (F), connector E7; rightward return to IC94.11. Other crossing branches not exhaustively certified. | clear |
| /Q; number not drawn | /ROAD | /ROAD (C); IC87.4 and IC87.10 | clear |
| Preset; supply; other half | Not drawn in this symbol | No inactive preset tie, half index or package pin numbers invented | clear |

### IC88 — additions to the lower-half table

Crops: lower_88_inputs, lower_gate_bus_strip, road_to_wall, road_wall_left_native/right_native, lower_mid_routes and state_common_driver. These update the earlier input boundary; the earlier clear/Q output trace remains applicable.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 12 | Lower D | /VB (E), on the third horizontal wire below the ROAD return pair, turning down/right into D [Review 22 Oct: /V8 (E); correction 11.] | clear |
| 11 | Lower clock | IC81.11 vertical rail; also IC87.13 and common control. The possible extra IC75.6 junction at the upper crossing is L1. [Review 22 Oct: IC81.11, IC87.13 and FD only, not the common rail; L1 is a crossing.] | clear |
| 13 | Lower /CLR | IC81.3; also IC87.12 | clear |
| 8 | Lower /Q | /M-ROAD (D); now additionally followed to IC73.2, IC73.5 and IC94.10 | clear |
| 9 | Lower Q | Earlier IC96.12 / IC104.2 connections remain; other complete fanout not claimed | clear |

### IC117 — lower inverter input now followed

Crops: lower_bank_right, lower_bus_outputs, mixed_enable_detail. This supplements the existing 1→2 section and the separate address section 3→4. Part number is not printed beside these gates.

| Drawn pin / pad | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 1 | Lower inverter input | IC87.6, WALL; same input net as IC72.1 and IC89.10 | clear |
| 2 | Lower inverter output | IC120 lowest left address pad (glyph 13/23 uncertain), as recorded in the original PR137 table. IC89.8 drives the IC119 enables; the continuation-4 enable assignment to IC117.2 is withdrawn. | clear |
| Crossing with POOL-control rail | No junction | The crossing near (6510,5265) remains undotted. IC117.2 does not drive IC89.9 or IC72.10. | clear |
| Other sections; supply | See address section; remainder not established | No additional connections inferred | clear |

### Additional off-sheet and local-reference ledger

Labels here are transcribed only as far as readable. This does not replace the earlier PROM-output ledger or finish all bottom-edge labels.

| Label as read | Named sheet / connector | Source or destination on D | Confidence |
| --- | --- | --- | --- |
| /VB [Review 22 Oct: /V8; correction 11.] | (E) | IC74 D, unnumbered; IC88.12 | clear |
| V7 | (E) | Direct route to IC104.1, traced in continuation 5; possible additional crossing N5 remains uncertain | uncertain |
| /ROAD | (C) | IC74 /Q, unnumbered | clear |
| ROAD | (C) | IC74 Q, unnumbered | clear |
| ROAD | (F), E7 | Same IC74 Q net | clear |
| /TUNNEL | (F,G), EF | IC31.8; also IC80.11 | clear |
| TUNNEL AP | (C) | IC80.13; gate's eroded input-12 bubble remains unresolved | uncertain |
| /…-LINE; first character M/Y unresolved | (C) | IC87.11 | uncertain |
| /SLIP | (C) | IC59.12 | clear |
| /SLIP | (F), FA; confirmed by the extended continuation-5 crop | Same IC59.12; continuation 5 extends the crop and reads the F reference below this label | clear |
| Barred label ending SLIP, prefix unreadable | (C) | IC94.8, on a separate wire from IC59.12 | uncertain |
| BRIDGE AP and /BRIDGE AP local references | (D), as used at IC58 | Continuation 5 follows IC80.1 to BRIDGE AP and IC22.5, then IC22.6 to /BRIDGE AP; extra crossing N1 remains uncertain | uncertain |

### Limited block description

IC74 samples /VB through its drawn D and CK terminals, with the two B-sheet load-labelled wires connected to CK and active-low CL. Its Q and /Q supply the drawn ROAD and /ROAD outputs. Exact pin assignment is absent from the symbol.

The two plain IC87 AND gates establish `WALL = /ROAD AND IC80.13` and `IC87.8 = /ROAD AND IC80.4`. IC87.8 reaches the TREE, HOUSE and GRASS enable circuitry already recorded. Because the relevant IC80 bubbles and the extra upstream crossing are unresolved, this does not yield an unconditional state equation for those enables.

The lower IC73 section takes IC31.6, IC68 Q and /M-ROAD; its output passes through the inverter marked IC59 to /SLIP. The drawing labels the wire before that inverter SLIP. Its worn input bubble prevents certifying the complete preceding NOR equation. The separate IC94.8 bottom output is retained separately; the damaged label is not merged with /SLIP merely because its last letters match.

No new resistor or capacitor is drawn in these gate/ROAD sections. Existing RA1 and the recorded 470p capacitors remain in their earlier tables. Omitted power/preset connections have not been supplied from a conventional pinout.

### Continuation 4 unresolved register

| ID | Crop box(es) | Uncertainty / required continuation | Confidence |
| --- | --- | --- | --- |
| L1 | (4200, 2350, 4780, 3550); (4000, 2080, 5190, 2880); (4510, 3390, 6150, 4350) | IC81.11 can be followed down to the common-control and lower IC88 clock rail. Its crossing with the IC75.6 return near (4485,2840) is thickened but not a confidently distinct junction dot. Record possible join or crossing; do not resolve it from expected output behaviour. Upper IC25 Q is not substituted as the source of this rail. [Review 22 Oct: crossing, 11.3 px. The common rail is IC68 Q, correction 5.] | clear |
| L2 | (4350, 3880, 5580, 4940); (3200, 3890, 4600, 5400); (3250, 3600, 3980, 5460) | IC80.1→IC80.6 and IC80.13→IC80.5 are followed. Additional leftward fanout and dense crossings around the return rows near y=4120–4300 need review before assigning all BRIDGE/EXT labels or merging adjacent rails. | uncertain |
| L3 | (5520, 3880, 6790, 4940); (2980, 4670, 4650, 5510); (4350, 3880, 5580, 4940) | IC80.4 output bubble, IC80.12 input bubble and IC73.1 input bubble are eroded. Candidate NOR functions fit the visible remnants and compatible pin groups, but pinout compatibility is not a replacement for those readings. | uncertain |
| L4 | (5180, 4900, 5810, 5900); (5240, 3500, 5480, 5500) | IC94 upper middle-input numeral reads 1 or 3. Compatible 7410 would require 3 in the 3,4,5→6 group. Type is not printed here; do not rewrite the numeral. IC59's first designator digit is dark/blotted; preserve position and pins 13→12 if independent review disputes 59. | uncertain |
| L5 | (5140, 5760, 6560, 6220); (3780, 4900, 5770, 6210) | IC87.11 barred …-LINE first letter M/Y uncertain. IC94.8 barred output label ends SLIP but its prefix cannot be read confidently. Additional letters/sheet reference beside the far-right bottom output remain unfinished. | uncertain |
| L6 | (2980, 4670, 4690, 6220); (3250, 3600, 3980, 5460); (6370, 3880, 6700, 5780) | Continuation 5 follows BRIDGE AP, IC22.5→6, both EXT routes and POOL-control origin. IC34.4 bottom text remains N3; BRIDGE crossing and lower reference/connector details remain N1/N2. | uncertain |
| L7 | (880, 650, 1660, 2510); (1290, 2280, 1410, 3900); (1290, 3850, 1410, 5380); (1250, 5260, 2320, 6220) | IC74 clock/clear wiring follows the B-sheet load-reference rails, but their final characters remain U1. All IC74 terminal numbers and its half selection are absent. Complete unused-section/power inventory across distributed gate packages still needs a whole-sheet review. | uncertain |

## Continuation 5 — peripheral routes and source corrections

This section closes several previously untraced routes. It also corrects a definite connection asserted earlier: **IC104.1 has a continuous route to V7 (E); its crossing with IC82.10 is not a certified junction.** Earlier tables and the derived description have been updated. No expected circuit behaviour was used to decide the crossing.

### Additional inspection crops

The extended bottom-edge crops include sheet letters below y=6220 that were outside some earlier crops. Original-image coordinates remain authoritative.

| Crop | Pixel box | Use | Confidence |
| --- | --- | --- | --- |
| final_bottom_labels_a.png | (3150, 5510, 3980, 6230) | Peripheral route, junction or extended label inspection | clear |
| final_bridge_routes.png | (3400, 3910, 5300, 4340) | Peripheral route, junction or extended label inspection | clear |
| final_pool_route_a.png | (3850, 3370, 4400, 4780) | Peripheral route, junction or extended label inspection | clear |
| final_pool_route_b.png | (3890, 4580, 5350, 4760) | Peripheral route, junction or extended label inspection | clear |
| final_pool_route_c.png | (5270, 4590, 6600, 4790) | Peripheral route, junction or extended label inspection | clear |
| final_ext_route_a.png | (3350, 3600, 4600, 3820) | Peripheral route, junction or extended label inspection | clear |
| final_control_sources.png | (3200, 3040, 4490, 3630) | Peripheral route, junction or extended label inspection | clear |
| final_pool_source_top.png | (3510, 2110, 4020, 3440) | Peripheral route, junction or extended label inspection | clear |
| final_bridge_source.png | (4780, 3660, 5270, 4340) | Peripheral route, junction or extended label inspection | clear |
| final_bridge_junction.png | (3570, 4150, 3740, 4340) | Peripheral route, junction or extended label inspection | clear |
| final_bottom_right_labels.png | (5210, 5750, 6190, 6310) | Peripheral route, junction or extended label inspection | clear |
| final_car_control_upper.png | (2080, 2720, 2340, 4320) | Peripheral route, junction or extended label inspection | clear |
| final_car_control_lower.png | (2130, 4220, 2440, 6100) | Peripheral route, junction or extended label inspection | clear |
| final_left_bus_return.png | (2100, 2350, 3240, 2800) | Peripheral route, junction or extended label inspection | clear |
| final_car_decoder.png | (1960, 2770, 2430, 3100) | Peripheral route, junction or extended label inspection | clear |
| final_zero_area_a.png | (5300, 2770, 5920, 3510) | Peripheral route, junction or extended label inspection | clear |
| final_zero_area_b.png | (5740, 3400, 5960, 5040) | Peripheral route, junction or extended label inspection | clear |
| final_zero_area_c.png | (5740, 4950, 6000, 6310) | Peripheral route, junction or extended label inspection | clear |
| final_bottom_tunnel_label.png | (3190, 5870, 3410, 6320) | Peripheral route, junction or extended label inspection | clear |
| final_bottom_ext_letters.png | (3300, 5870, 3860, 6340) | Peripheral route, junction or extended label inspection | clear |
| final_bottom_refs_left.png | (2900, 6100, 4100, 6550) | Peripheral route, junction or extended label inspection | clear |
| final_bottom_refs_mid.png | (4000, 6100, 6000, 6540) | Peripheral route, junction or extended label inspection | clear |
| final_bottom_refs_right.png | (5950, 6100, 8900, 6510) | Peripheral route, junction or extended label inspection | clear |
| final_car_labels.png | (2130, 5820, 2510, 6340) | Peripheral route, junction or extended label inspection | clear |
| final_side_connectors.png | (7750, 3340, 8890, 3640) | Peripheral route, junction or extended label inspection | clear |
| final_side_source_left.png | (1950, 4950, 3650, 5230) | Peripheral route, junction or extended label inspection | clear |
| final_side_source_mid.png | (3570, 3880, 5320, 4110) | Peripheral route, junction or extended label inspection | clear |
| final_side_source_right.png | (5170, 3300, 6780, 4100) | Peripheral route, junction or extended label inspection | clear |
| final_side_wires_mid.png | (6590, 3380, 7870, 3560) | Peripheral route, junction or extended label inspection | clear |
| final_side_wires_left.png | (4400, 3380, 5350, 3550) | Peripheral route, junction or extended label inspection | clear |
| final_tunnel_return.png | (3180, 3870, 3340, 5960) | Peripheral route, junction or extended label inspection | clear |
| final_v7_route.png | (1110, 5070, 3650, 5240) | Peripheral route, junction or extended label inspection | clear |
| final_v7_left.png | (1090, 5090, 2370, 5230) | Peripheral route, junction or extended label inspection | clear |
| final_v7_mid.png | (2310, 5090, 3650, 5250) | Peripheral route, junction or extended label inspection | clear |
| final_v7_vertical.png | (3520, 3900, 3650, 5230) | Peripheral route, junction or extended label inspection | clear |
| final_v7_crossing.png | (5160, 2770, 5440, 2920) | Peripheral route, junction or extended label inspection | clear |
| final_v7_upper.png | (5180, 2250, 5310, 4020) | Peripheral route, junction or extended label inspection | clear |

### IC22 — BRIDGE AP inverter section; no type printed beside it

Crops: final_bottom_labels_a, final_bottom_ext_letters and final_bottom_refs_left. The symbol is an inverter, input 5 to bubbled output 6. This group is compatible with 7404; the comparison does not establish an unprinted part number. The other drawn section 3→4 is already in the PR135 output trace.

| Drawn pin / terminal | Net / function | Endpoint or observation | Confidence |
| --- | --- | --- | --- |
| 5 | Inverter input | IC80.1, BRIDGE AP, via the vertical rail near x=3630 and dotted branch near y=5530 | clear |
| 6 | Inverted output | /BRIDGE AP (D), the matching local reference at IC58.1 | clear |
| Other sections / supply | No additional connection established in this review | No unused-input or power ties inferred | clear |

### BRIDGE AP source and local-reference closure

Crops: final_bridge_source, final_bridge_routes, lower_bus_strip, final_bottom_labels_a and final_bridge_junction. IC80.1 runs down near x=5195, branches right toward IC80.6, and runs left near y=4260 to the BRIDGE AP vertical rail near x=3630. That rail reaches IC22.5, the positive BRIDGE AP label and the adjacent connector. The crossing with the /ROAD return near (3680,4247) remains a junction-reading uncertainty; no extra /ROAD tie is asserted.

| Endpoint | Connection now followed | Limitation | Confidence |
| --- | --- | --- | --- |
| IC80.1 | IC80.6; BRIDGE AP output rail; IC22.5 | The additional crossing near (3680,4247) is N1 | clear |
| IC58.5, BRIDGE AP (D) | Matching labelled local source IC80.1 | This is a label/reference association, not a continuous drawn wire from the lower block to IC58 | clear |
| IC58.1, /BRIDGE AP (D) | Matching labelled local source IC22.6 | Same local-reference convention | clear |
| Positive BRIDGE AP output | C; nearby lower D, M, H reference group; connector F1[8/B] | C is clear. Lower letters D/M/H are visible, but their exact grouping and final connector glyph require review (N2). | uncertain |
| Negative /BRIDGE AP output | D | Label and local sheet reference clear | clear |

From the drawn two-input NOR at IC80, `BRIDGE AP = NOT(IC25.6 OR IC80.3)`, and IC22 inverts that labelled output. This is conditional on the unresolved additional joins on the common-control and BRIDGE rails (L1/N1). It is not a certified complete netlist.

### POOL-control route and the lower IC25 feedback

Crops: final_pool_source_top, final_pool_route_a/b/c, pool_control_origin, state_source_routes and final_control_sources. The upper IC89.6 wire runs down near x=3935, turns right near y=4680, and then down near x=6510. It reaches IC89.9 and the already recorded IC72.10. It crosses the IC117.2 wire without a dot. The separate IC25.5 return goes left near y=3560 to IC32.4 and IC34.5; the crossing with the POOL-control vertical wire is not used as a new junction.

| IC / pin | Net / endpoint update | Remaining limitation | Confidence |
| --- | --- | --- | --- |
| IC89.6, upper NOR output | IC89.9 and IC72.10, common POOL control | Previously untraced destination is now followed | clear |
| IC89.9, lower NOR input | IC89.6 | Separate from IC117.2 and from IC89.10's WALL input | clear |
| IC72.10, POOL-output NAND input | IC89.6 | Other input IC72.9 remains IC119.9 | clear |
| IC25.5, lower Q | IC32.4 and IC34.5 | No additional crossing joins inferred | clear |
| IC32.4 | IC25.5 | Replaces S8's untraced source | clear |
| IC34.5 | IC25.5 | Its other input remains IC31 TUNNEL Q, with uncertain numerical Q glyph | clear |

The upper IC89 section is the previously traced NOR of IC75.8, IC88 upper /Q and IC38.6. Its output is now followed to the POOL-control input of IC72. This names the actual connected gates without interpreting a game region or PROM contents.

### Upper IC25 EXT outputs and bottom-edge labels

Crops: state_source_routes, final_ext_route_a, lower_bus_strip, final_bottom_labels_a, final_bottom_ext_letters and final_bottom_refs_left. The upper IC25 /Q at pin 8 follows the route near x=4525 to y=3690, then left and down near x=3460. Upper Q, whose numeral remains 9/7 uncertain, takes the separate route near x=4570 to y=3730 and down near x=3505. They are not joined by their intervening crossings.

| Terminal / output | Route / source | Printed destination / exact-reading limit | Confidence |
| --- | --- | --- | --- |
| IC25.8, upper /Q | Lower vertical output rail near x=3460 | /EXT.500 (M); branched EJ output with /EXT.[5/6]00 (F) | uncertain |
| IC25 upper Q; numeral 9/7 uncertain | Separate rail near x=3505 | /EXT.500 (H); also already connected to IC25.2 | uncertain |
| /EXT.500 (M) | IC25.8 | Dot branches from the same rail as EJ | clear |
| /EXT.[5/6]00 (F), EJ | IC25.8 | Leading numeral looks different from the neighbouring 500 labels; do not normalize it. 600 versus 500 unresolved. | uncertain |
| /EXT.500 (H) | IC25 upper Q port | The output label is readable; the source pin numeral is not certain | uncertain |
| IC34.4 bottom output | Continuous rail near x=3270 | (D); barred text begins TUNNEL C, second line resembles APTUNE / AP…UNE. Exact combined label unresolved. | uncertain |

The repeated or similar EXT labels are retained as printed, including their bars. No complementary name is invented for Q versus /Q.

### IC24 decoded-output branch to CAR.NO.CONT

Crops: final_car_decoder, final_car_control_upper/lower and final_car_labels. The dotted branch near (2250,2995) comes from **IC24 pin 6, decoded output 5**. It descends to connector F3 and the paired CAR.NO.CONT labels. It is not assigned to the adjacent decoded-6/pin-7 row. The branch crosses IC48.5 and other horizontal wires without a separately identified junction dot.

| Endpoint | Connection / label | Observation | Confidence |
| --- | --- | --- | --- |
| IC24.6, decoded 5 | Existing IC45.1 and IC25.3; added F3 output rail | The vertical output branch is on this decoded row | clear |
| F3 | /CAR.NO.CONT (H) | Bar is visible in the enlarged label crop | clear |
| Second arrow on F3 rail | /CAR NO.CONT (M) | Same electrical node; punctuation differs slightly between the two written labels | clear |

### Side-control outputs at FD and FC

Crops: final_side_wires_left/mid, final_side_source_right, final_side_connectors. Two separate horizontal wires cross the PROM bus near y=3450 and y=3490. They originate at the dotted branches from the IC81.11 and IC81.3 rails respectively, and terminate at FD and FC. They are not outputs of IC105 simply because they pass below that PROM path.

| Connector / label | Source / route | Reading limit | Confidence |
| --- | --- | --- | --- |
| FD, /R[1/I]-SIDE (H) | IC81.11 rail, upper horizontal wire | The small character after R resembles 1 or I; common-control crossing L1 remains unresolved | uncertain |
| FC, /L[1/I]-SIDE (H) | IC81.3 rail, lower horizontal wire | The small character after L resembles 1 or I | uncertain |
| Separate R and L marks nearby | Margin annotations | No electrical connection inferred from the isolated letters | clear |

### V7 route and revision of IC104.1

Crops: final_v7_left/mid/vertical, final_bridge_routes, middle_control_handoff, final_v7_upper and final_v7_crossing. Starting at V7 (E), follow the lower horizontal input near y=5170, turn up near x=3590, turn right near y=3950, then up near x=5240 into IC104.1. The adjacent x=5280 route belongs to IC104.2 / IC96 D and the lower IC88 Q return.

The crossing of the IC104.1 vertical wire with the IC82.10 horizontal wire near (5240,2845) has thickened ink, but a distinct junction dot cannot be certified. The earlier definite IC82.10→IC104.1 connection is withdrawn. Both the direct V7 route and the crossing uncertainty must be preserved; expected electrical behaviour is not a reason to choose a join or isolation.

| Pin / output | Updated connection | Confidence |
| --- | --- | --- |
| IC104.1 | Direct V7 (E) route; possible additional IC82.10 join is N5 | uncertain |
| IC104.2 | Lower IC88 Q, as already traced; not the neighbouring V7 vertical wire | clear |
| IC82.10 | IC66.4 and the downward return to /[0/O]-AREA (H); possible selector-input crossing N5 retained | uncertain |
| /[0/O]-AREA (H) | IC82.10 through the return near x=5830; initial rounded glyph 0/O and punctuation uncertain, H readable | uncertain |

### Extended bottom-edge reference corrections

| Output | Updated sheet / connector reading | Evidence / limitation | Confidence |
| --- | --- | --- | --- |
| /TUNNEL, IC31.8 | F and G; EF | G is below the earlier crop boundary; final_bottom_refs_left includes it | clear |
| /SLIP, IC59.12 | C and F; FA on F branch | F is visible in final_bottom_right_labels and final_bottom_refs_mid | clear |
| BRIDGE AP, IC80.1 | C plus lower D/M/H reference group; F1[8/B] | Association of the extra lower group and connector glyph remains N2 | uncertain |
| IC87.11 barred …-LINE | C | Initial letter still M/Y uncertain; not silently renamed | uncertain |
| IC94.8 barred …SLIP | C | Exact prefix remains unreadable; distinct from IC59.12 /SLIP | uncertain |

### Coverage and passive review

The page-edge review adds the side connectors, CAR.NO.CONT, EXT, BRIDGE AP, /[0/O]-AREA and extra bottom sheet references. The visible PROM, mux, decoder, latch, flip-flop and gate blocks now have entries in this file. Distributed sections remain grouped across continuations; their unprinted types and omitted terminals have not been supplied by convention. This is a coverage review, not independent verification of every previously recorded junction.

| Area / component group | Coverage / passive result | Limitation | Confidence |
| --- | --- | --- | --- |
| PR134–PR137, IC92/67 and output selectors/decoder | Earlier per-pad and per-pin tables retained | Faded numerals and the selector/load crossing remain unresolved | uncertain |
| IC24 and grouped state flip-flops | Tables plus EXT/CAR/POOL endpoint updates | Clock crossing S4 and several numerical Q glyphs remain uncertain | uncertain |
| IC40/49/48/41/68 timing/latch chain | Tables and IC68 Q fanout recorded | Missing latch terminal numbers and unshown ties remain absent | uncertain |
| Central/lower control gates and IC74/88 | Tables plus BRIDGE, ROAD, SLIP, side and POOL routes | C1/C5/L1/N1/N5 crossings and damaged symbols prevent a complete certified netlist | uncertain |
| RA1 | Four Vcc pull-up branches recorded in continuation 2 | Printed resistance remains …60; leading digit uncertain | uncertain |
| Capacitor on IC40.8 / IC49.13 | 470p to ground, already recorded | No drawn designator | clear |
| Capacitor on /COIN IN / IC34.9 | 470p to ground, already recorded | No drawn designator | clear |
| Capacitor on IC58.6 / IC65.6 | 470p to ground, already recorded | No drawn designator | clear |
| Newly traced peripheral routes | No additional resistor or capacitor identified in these crops | No hidden power-pin or inactive-input ties inferred | clear |

### Continuation 5 unresolved register

| ID | Crop box(es) | Uncertainty / required review | Confidence |
| --- | --- | --- | --- |
| N1 | (3570, 4150, 3740, 4340); (3400, 3910, 5300, 4340) | BRIDGE AP horizontal route crosses the /ROAD return near (3680,4247). IC80.1→BRIDGE AP/IC22.5 is followed, but an additional tie at the thickened crossing is not certified. [Review 22 Oct: crossing, 14.1 px, no dot.] | clear |
| N2 | (3150, 5510, 3980, 6230); (3300, 5870, 3860, 6340); (2900, 6100, 4100, 6550) | BRIDGE AP connector final glyph 8/B uncertain. Lower circled D/M/H group is visible beneath the positive-output region; exact association/grouping needs review. EJ EXT suffix 600 versus 500 is unresolved and must not be normalized to nearby labels. | uncertain |
| N3 | (3190, 5870, 3410, 6320); (5210, 5750, 6190, 6310) | IC34.4 bottom label begins barred TUNNEL C with second-line APTUNE / AP…UNE-like text. IC87.11 first letter and IC94.8 SLIP prefix remain unresolved. | uncertain |
| N4 | (7750, 3340, 8890, 3640); (5740, 4950, 6000, 6310) | FD/FC labels R1/L1 versus RI/LI; /0-AREA versus /O-AREA and separator punctuation. Sheet letters H are readable. | uncertain |
| N5 | (5160, 2770, 5440, 2920); (5180, 2250, 5310, 4020); (3520, 3900, 3650, 5230) | IC104.1 is directly traced to V7. The previous definite IC82.10 tie is withdrawn: thickened crossing near (5240,2845) could be a join or crossing blemish. Do not assert either without stronger evidence. [Review 22 Oct: crossing, 11.3 px.] | clear |

## Pinout comparison and unresolved readings

All findings here are restricted to the sections above. A compatible standard pin group does not prove an unprinted package type. The PROM part number is unavailable, so a device-specific pinout certification is not possible.

| Item | Comparison / result | Confidence |
| --- | --- | --- |
| IC92, IC67, IC98; printed 157 | Drawn numbered pins agree with 74157; no confirmed disagreement in these symbols. Unnumbered unused stubs remain unnumbered. | clear |
| IC112, IC119; printed 153 | Drawn numbered pins agree with 74153. | clear |
| IC105; printed 153 | Candidate numbers fit 74153, but erosion prevents confirmation of several labels; no mismatch is repaired by assumption. | uncertain |
| IC97; printed 42 | Drawn pins agree with 7442: A/B/C/D = 15/14/13/12 and outputs 1..4 at pins 2..5. | clear |
| PR134–PR137 | No printed device number established. PR135 has especially faded pin numbers. No unconditional device-specific pinout check claimed. | uncertain |
| IC58, IC72, IC65, IC34, IC60, IC22 gate sections | Visible groups match respectively 7408, 7400, 7402, 7402, 7427, 7404. These are comparisons only; types are not printed beside these sections. | clear |
| IC104 side-line section | Bubbled AND symbol implements OR; 9,10 → 8 is compatible with 7432. Other IC104 sections have not been certified package-wide. | clear |

### Unresolved register

| ID | Crop box(es) | Unresolved reading / alternatives / required continuation | Confidence |
| --- | --- | --- | --- |
| U1 | (900, 590, 2160, 2100); (4550, 580, 5780, 1700) | Final character of /M1VL… and /M2VL…: round 0/O or possibly D. Input and selector wiring are recorded separately from this spelling uncertainty. Do not substitute a preferred net name without source confirmation. | uncertain |
| U2 | (6750, 2120, 8860, 3340) | IC106 address, data and enable pin numerals are eroded. Tables give pad positions and candidate numbers 8..1,23; 9,10,11,13..17; 18..21. Confirm from a better scan. The exact Vcc-pair tie ink is also faded. | uncertain |
| U3 | (6750, 2120, 8860, 3340); (7390, 3060, 8630, 3690) | IC105 input/select/enable/output numbers are partly eroded. Candidate numbering matches 153 but is not a substitute for reading. Positional output routes are traced. | uncertain |
| U4 | (7490, 1780, 8890, 2240) | IC60.8 and IC34.13 labels: TREE and GRASS-like fragments visible; exact separators/letters and upper suffix unreadable. Lower suffix appears BL. Retain incomplete labels. | uncertain |
| U5 | (6750, 2120, 8860, 3340); (7390, 3060, 8630, 3690) | IC22.4 label resembles /GRASS(W), but suffix/text erosion prevents certain exact transcription. | uncertain |
| U6 | (7570, 4380, 8790, 4820) | IC97.3 HOUSE colour suffix: ML versus MW or another damaged reading; IC97.4 suffix BL versus DL or another reading. Output numbers and C destinations are readable. | uncertain |
| U7 | (7770, 5480, 8820, 6240) | POOL output suffixes on C/F branches are damaged (S-like and L-like strokes). WALL suffix also damaged. Do not infer colours from PROM annotations. FM is readable. | uncertain |
| U8 | (6850, 950, 8820, 2180); (6760, 3540, 8840, 4860); (6750, 4800, 8870, 6230) | PROM body annotations: PR134 lower text candidate 2-TREE; PR136 body text faded; PR137 contains additional damaged words/numbers. These are not functional-net claims. Device part numbers not established for any PROM. | uncertain |
| U9 | (6300, 1270, 7100, 1910); (6050, 1500, 7460, 2130) | Continuation 3 establishes IC110.9 from IC110.6 and IC81.5 from IC87.8. The IC65.13 / IC81.4 / IC110.10 return and crossing issue remains C5. Preserve established output endpoints. [Review 22 Oct: resolved, correction 7.] | clear |
| U10 | (5950, 2490, 6930, 3040); (5090, 2080, 6900, 3330) | IC56.11 upstream control remains incomplete, but continuation 3 establishes input 13 from IC87.8. Pin 12 is IC56.3; IC56.1 reaches IC81.11; the possible extra IC75.6 junction remains L1. Body contour is eroded: NAND versus NOR unresolved. Pin group 12,13→11 fits 7400 NAND, but that does not repair the body by assumption. [Review 22 Oct: AND body with an output bubble: NAND. IC56.1 is on the IC68 Q rail, correction 5.] | clear |
| U11 | (6200, 3580, 6940, 4240) | IC81.8 comes from IC82.8 and IC87.8. Continuation 3 traces IC82.9 to IC96.1 and its inverted output to IC81.9. Continuation 4 records IC87.10=/ROAD and .9=IC80.4; remaining upstream ambiguities are L1/L2. | uncertain |
| U12 | (5590, 4950, 7580, 6230); (3780, 4900, 5770, 6210); (4950, 5070, 6450, 6210); (6180, 5180, 6860, 5680) | Continuation 4 resolves IC117.1=IC87.6, IC80.8/.9=IC94.8/.6, and IC87.4/.5=/ROAD and IC80.13. Continuation 5 traces the POOL-control rail to upper IC89.6. The IC117.2 crossing near (6510,5265) has no dot and is not a source for that control. IC89/IC104 package-wide type/pin certification remains pending. | uncertain |
| U13 | (5090, 2080, 6900, 3330); (5650, 3150, 6100, 4870); (5650, 4800, 6330, 6230) | GRAVEL control: IC66.6 downstream route is established. IC66.5 is now traced to IC73.6. IC66.3 is MH7 [Review 22 Oct: IC75.6; correction 6]; .4 is IC82.10. Continuation 4 adds the IC73 input endpoints; L1 still affects the shared control rail. | uncertain |
| U14 | (7950, 1060, 8920, 1550); (3780, 4900, 5770, 6210) | /M-ROAD labelled source is now established at IC88.8 /Q; lower IC88 input circuit remains incomplete. Continuation 5 traces BRIDGE AP to IC80.1 and /BRIDGE AP to IC22.6; additional crossings L1/N1 remain unresolved. Immediate IC58/IC65 connections remain established. | uncertain |
| U15 | (1330, 2080, 3310, 3580); (2910, 2420, 4580, 3520); (3750, 2020, 5630, 3350); (1320, 5030, 3310, 6220) | Revised scope boundary: continuation 2 now covers IC24, grouped state flip-flops, IC40/49, IC48/41/68, RA1 and two capacitors. Continuations 3–4 add the central decoder and lower gates. Remaining off-sheet terminals and uncertain crossings still need review; see S1–S11, C1–C8 and L1–L7. No whole-sheet completeness claim is made. | uncertain |
| U16 | (6850, 950, 8820, 2180); (6760, 3540, 8840, 4860); (6750, 4800, 8870, 6230) | Additional faded PROM numerals: PR134 candidate pins 6,5,11,15,16; PR136 candidate pins 8,6,5,3,2 and most data numerals. Physical pad routes are recorded, but numeric identities need confirmation. PR137 lowest left address-pad glyph may read 13 or 23; it is not silently corrected to the usual PROM pin 23. No device-specific disagreement can be certified without the device type. | uncertain |

## Exact stopping boundary and remaining work

Continuation 5 closes the BRIDGE AP / IC22 inverter, EXT, POOL-control, CAR.NO.CONT, side-control and /[0/O]-AREA routes, adds lower sheet references, and identifies IC25.5 as the shared IC32.4/IC34.5 source. It revises IC104.1 to the directly traced V7 input and withdraws the earlier definite IC82.10 tie at their uncertain crossing.

Stopped after the **peripheral-output trace and page-edge/passive review**. The visible functional blocks and peripheral outputs have entries. Remaining work is a consistency and junction review of C1/C5/S4/L1/N1/N5, unresolved symbol and numeral readings, exact damaged labels, and complete additional fanout/package certification. These are documented uncertainties, not inferred connections or omitted blocks assumed absent. No complete electrical-model certification is claimed.

This remains a sheet-D transcription with explicit unresolved readings. No sheet-B trace, game code, RTL or repository source was changed. Continue this same `SHEET_D_TRACE.md` file if further review is requested.
