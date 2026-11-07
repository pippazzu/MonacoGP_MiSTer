# Sheet I — score display board 96597-P, sheet 2: score memory, comparison and rank

Source: Sega **Monaco GP (420-0358)**, PDF page **23**, circled sheet letter
**I** (top left), board **96597-P**, title block "96597-P SCORE DISPLAY IC
BOARD ASS'Y (D-?/3)" (sheet number digit not legible). Transcribed from the
supplied `sheets/page23-sheet-I-score.png`, **10176 × 6624** pixels. Source
PNG SHA-256:
`838ba997ec0109c8c6dd4a996521eec6ac69eb7232ec2c3a2c971d76f310b119`.

**Orientation checked: the image is upright as supplied** (this page is not
one of the 180°-stored pages).

**Status (1 November 2026): the memory and ranking part is now read pin by
pin; see "Memory and ranking — pin-level reading" at the end, which
supersedes the structural reading below where they differ.** Original
status: **structural transcription with partial pin-level detail — not an
implementation-ready netlist.** This sheet is the densest of the set
(≈55–60 packages, two 16-line bus matrices). All blocks were identified and
their roles established from the wiring; the control, input and output
blocks are transcribed pin by pin; the repetitive bus matrix (comparators,
bus drivers, RAM) is transcribed at package level with pin numbers as
printed, but **individual bus-line crossings in the matrix were not
adjudicated junction by junction**, and the net-extraction tooling used for
sheet A was **not** run on this page (visual reading only). Rows marked
uncertain, and the matrix wiring as a whole, must be verified before
implementation. No ROM/RAM contents, emulator or gameplay knowledge was used.

Drawing conventions on this board differ from boards 96577/96578: designators
are grid positions (11C, 12D, 3E…), part types are written as bare numbers
(00, 02, 04, 08, 32, 85, 107/2, 192, 259, 390/2, 393/2, 2111, 8216), and
connector pads come in two shapes, keyed by the note at (6100,500)-(7300,900):
"CONNECTOR 記号及びP数": **crossed/open square = connector G, 44 pins; solid
square = connector J, 80 pins.** Small lower-case letters (a, b, c … f, h)
tag individual pad wires. Short arrowheads drawn mid-wire mark signal
direction on long runs.

## Crops used

Overview `(0,0,10176,6624)` at 0.14. Main reading crops:

| Crop box | Contents |
|---|---|
| (1200,600,3200,1900) | 14 MHz input, 12F, 12C/12D (393), 259 "J2" |
| (1100,2100,2600,3000) | G5–G7 input pads, 13H gates |
| (1100,4400,3300,5900) | V2/H5/GAME inputs, 2E, 12C second half, 12A decoder, 11B/13F/2H, 11A |
| (2600,1300,4900,2600) | 9F (393), 13D, 12B (107/2), 2111 RAM block |
| (2700,2600,5000,4200) | 7F/8F score counters, P-bus heads, 8216s 6E–3E |
| (5600,1300,7600,2600) | comparator row 6H–3H, P-bus brace, 11C/11D |
| (5000,2600,7200,4200) | comparator stack 6F–3F, D-bus arrows |
| (7300,1200,9200,2300) | output drivers 2E-1/11C/11D, S-100 pads |
| (7200,2600,8800,4300) | 192 counters 7H–10H, 1ST–5TH lines |
| (7800,4300,9300,5300) | 10A (259), 11A (390/2), 11B/11D |
| (3300,4300,5300,5900) | 10B/10C/10D first halves, D-1..D-3 buses, 何人中 caption |
| (5300,4300,7800,5900) | 14H (259), 12E, 13E (279/4), 13F, 10B/C/D second halves, R-buses |
| Label zooms | (6050,450,7600,1150), (8400,3350,9300,4250), (8900,1150,9700,1800), (1900,650,2450,1250), (2550,5650,3500,6300), (4300,5600,5900,6400), (6050,1450,7000,1900) |

## Signal path in brief (wiring-derived)

1. **Inputs** (left edge, each through a G-pad, most with an RA1 1 kΩ
   pull-up): 14 MHz (circled E) via pad tag "a"; /SCORE CP (F) via G5/pad 23;
   /COIN&TEST (A) via G6/pad tag "b"; /INI.RESET (A) via pad 24 (G7 adjacent);
   V2 (E) via G8/pad "c"; H5 (E) via G9/pad "d"; GAME (A) via G10?/pad "e".
   Bottom edge: SP.CONT (H) via G12/J-pad "h"; Vs/16 (H) via G11/J-pad "f".
2. **Reset trunk.** 13H (7400 drawn as OR-with-input-bubbles) NANDs
   /COIN&TEST with /INI.RESET; the output (= COIN&TEST + INI.RESET active
   high) runs as a long vertical trunk and clears the score counters and
   address/sequencer counters.
3. **Sequencer.** 14 MHz → 12F (7402, 5,6→4) → 12C (74393 half, CP=1) →
   12D (74393, both halves) — a divider chain; 12C/12D outputs drive the
   74259 "J2" (addressable latch: address A=1,B=2 from the chain, C=3
   grounded, D=13 serial data, /E=14, /CL=15 grounded) and the long
   horizontal timing lines east. 12A (7442, inputs A,B,C = pins 15,14,13,
   D-input pin 12) decodes the sequence into the four phases printed
   vertically under a small timing diagram at (2700,5650)-(3200,6150):
   **ADR INC. / 192 LD. / RAM R/W / 256 CL.** (fourth label uncertain), with
   waveform rows A–D and phase marks 1,2,3.
4. **High-score RAM.** 2111 (256×4) SRAM block drawn as one outline with
   column designators **10F, 11F, 11E, 11H** and the caption "2111 × 6"
   (count/designator mismatch unresolved). Address A0–A7 from 9F (74393,
   both halves; its MR from the reset side, its CP from the sequencer);
   address pin numbers as printed on the RAM edge: 4,3,2,1 (low) and
   17?,16?,15?,5,6,7 (high, partly illegible). Controls: /OD pin 1? ← 13D
   (04); R/W pin 16? ← write-control line from 12B (107/2 J-K flip-flop,
   designator reading "RB" taken as 12B) and 13D sections. Data pins
   11,12,13,14 per column ↔ 8216 bus drivers.
5. **Bus drivers.** 8216s at **6E, 5E, 4E, 3E** (one per digit): bus side
   (top pins 3,6,10,13) to the RAM data columns; device side (left pins
   4,7,9,12) to the score-digit rows; right pins 2,5,11,14 to the P-bus
   columns; /CS (pin 1) grounded on all four; /DIEN (pin 15) on a common
   direction line from the RAM R/W phase.
6. **Current score.** "（SCORE）" caption beside 7F and 8F (74390 dual
   decade, both halves each = 4 decades). Clock: /SCORE CP chain (13H
   section 12,13→11 gating the pad-23 line) into 7F half-1 CP (pin 1);
   internal cascades 7F.7→7F.15, 7F.9→8F.1, 8F.7→8F.15 (QD→next CP, with
   QA(3) strapped to /CPB(4) in each half — "3,4" drawn on one stub). MRs
   (2/14) on a common vertical from the reset trunk. Outputs QA–QD of the
   four decades run east as the four digit rows.
7. **High-score compare.** Comparator row **6H, 5H, 4H, 3H** (7485 each):
   A inputs (pins 10,12,13,15) from the **P-bus** (P-1A..D, P-2A..D,
   P-3A..D, P-4A..D — printed names; the stored high score read from RAM
   via the 8216s; bus group brace carries a vertical Japanese caption
   reading "ハイスコア…" (high score …) with a circled mark read as I),
   B inputs (pins 9,11,14,1) from the current-score digit rows; cascade
   A=B out (6) → A=B in (3) right-to-left; the final result gates the
   RAM write (new high score) through the 12B/13D write logic.
8. **Rank compare.** Comparator stack **6F, 5F, 4F, 3F** (7485 each):
   A inputs from the current-score rows (west), B inputs (east) from the
   **192 counters 7H, 8H, 9H, 10H** (74192, one per digit; presets
   A=Vcc, B=C=GND, D=Vcc = BCD 9 on each — same tie pattern as sheet A's
   IC20; CLR pin 14 grounded; /LOAD pin 11 on the common "192 LD." phase
   line; count inputs chained vertically). Equality cascade 3→6 runs down
   the stack; the result drives the rank sequencer.
9. **Rank outputs.** 11A (74390 half 2: CP=15 ← 11B (08) = AND(11D(04)
   output, …); MR=14) counts ranks; its QA–QC (13,12,11) address the
   74259 **10A** (A,B,C = pins 1,2,3; D=13; /E=14 ← enable line from the
   13E latch region; /CL=15 grounded): outputs Q0–Q4 (pins 4,5,6,7,9) are
   the five lines **1ST, 2ND, 3RD, 4TH, 5TH → circled K** (sheet K).
10. **Rank-number display.** 10B, 10C, 10D (74390 duals): first halves
    (pins 1–7) → buses **…-1A..D, -2A..D, -3A..D with circled J marks**
    (to sheet J), caption "（何人中）" ("out of how many") — the
    rank-denominator display digits; second halves (pins 15,14,13–9) →
    buses **R-1A..D, R-2A..D, R-3A..D** with circled marks read H?/H?/J?
    (uncertain). MRs on common rails.
11. **Flash/latch.** 14H (74259: D=13 ← 12E (7402 NOR, inputs 12,11),
    /E=14, /CL=15, A,B,C=1,2,3 ← R-1 group risers; outputs Q0–Q4 = pins
    4?,5,6,7,9,10? dropping to the bottom edge) with 13E (74279 quarter,
    pins 1,2?,5?→4) and 13F (04) — the blink/latch logic clocked from the
    Vs/16 (H) input; **LATCH CL. → circled K** leaves at the bottom
    (arrow down at x≈4700).
12. **Serial score out.** 11C (7432, two sections: 12,13→11 and one
    unnumbered), 11D (04) and 2E-1 ("16", three buffer sections 9→8?,
    1→2, 11→10, drawn as plain triangles) drive five output lines through
    J-pads **27, 26, 29, 25, 28** and G-pads **GP?, G13, GR, GN, GB?** to
    **S-100-A, -B, -C, -D (brace → circled D)** and **S-100-D' (circled
    A)**. (Sheet A receives a line marked S-100-D at its pad A30.)

## Pin tables (control and I/O blocks)

Confidence **clear** unless noted.

### Inputs

| Item | Connection | Confidence |
|---|---|---|
| "Ⓔ 14M Hz" → pad "a" (G4 above) | → node with 1K pull-up (Vcc) → 12F.6 | clear; which of G4/"a" is the G-pin uncertain |
| 12F (02, NOR 5,6→4) | 5 ← (loop from below, not traced); 6 ← 14 MHz node; 4 → 12C.1 | pin-5 source uncertain |
| "Ⓕ /SCORE CP" → G5 → pad 23 | → RA1 1K pull-up → 13H.12 | clear |
| 13H section 12,13→11 (00; AND body) | 12 ← pad-23 line; 13 ← riser from 13Hb output trunk; 11 → score-clock line (to 7F.1 region) | clear |
| "Ⓐ /COIN&TEST" → G6 → pad "b" | → RA1 1K → 13Hb bubbled input | clear |
| "Ⓐ /INI.RESET" → pad 24 (G7 adjacent) | → 13Hb second bubbled input; branch south | clear |
| 13Hb (00; OR body, input bubbles = NAND; pins not drawn) | out → **reset trunk** (long vertical ≈x1990) north to 12C/12D MR line and south | pins not drawn |
| "Ⓔ V2" → G8 → pad "c" | → 1K RA1 → 2E.2 | clear |
| 2E (02 NOR, 3,2→1) | 3 ← loop from 12A region (y≈4570); 2 ← V2 line; 1 → 12C(half-2).13 CP | clear |
| "Ⓔ H5" → G9 → pad "d" | → 1K RA1 → 13F.2 (02 NOR at (2560,5345)) | clear |
| 13F (02 NOR, 3,2→11?) | 3 ← 11B.11; 2 ← H5 line; out → 11A(half-1?) clock | output pin numeral uncertain |
| "Ⓐ GAME" → pad "e" (G10 below) | → 1K RA1 → 2H.9 | clear |
| 2H (08 AND; De Morgan OR body, 10,9→8) | 10 ← trunk line; 9 ← GAME; 8 → 11A.2 (MR) | clear |
| "SP. CONT. Ⓗ" → G12 + J-pad "h" | → north into 13E/12E latch-clock region | destination pin untraced |
| "Vs/16 Ⓗ" → G11 + J-pad "f" | → 1K RA1 → north into 12E/13E region | destination pin untraced |

### Sequencer and RAM control

| Item | Connection | Confidence |
|---|---|---|
| 12C (393): half-1 CP=1 ← 12F.4; Q=3,4,5,6; MR=2 | Q risers → 259 "J2" A(1),B(2) and east lines; MR → common reset line y≈1790 | clear |
| 12D (393): half-2 (13 CP, 11,10,9,8 Q, 12 MR) in the top chain; half-1 (1 CP, 3,4,5,6 Q, 2 MR) at (2640,1540) | cascade from 12C; Q outputs → east address/timing lines (y≈1420–1460) | clear |
| 259 "J2" (74259) | /E=14 ← west line; /CL=15 → GND; D=13 ← west line; A,B = 1,2 ← 12C risers; C=3 → GND; Q0–Q7 = 4,5,6,7,9,10,11,12, Q2(6) and Q3(7) long lines east, others short | designator reads "J2" (uncertain; possibly 12); D source untraced |
| 9F (393, both halves) | half-1: CP=1?(top), MR=2, Q=3,4,5,6 → RAM A0–A3 (RAM pins printed 4,3,2,1); half-2: CP=13, MR=12, Q=11,10,9,8 → RAM A4–A7 (RAM pins printed 17?,5?,6,7); MRs ← "256 CL." phase | RAM pin numerals partly illegible |
| 12A (7442 "42") | A,B,C = 15,14,13 ← sequencer bits; input 12 (D) ← west; outputs 1,2,3,4,5,6… east/south; phase names (timing diagram, bottom left): **ADR INC., 192 LD., RAM R/W, 256 CL.?** | clear; 4th label uncertain |
| 12B (107/2 J-K; designator drawn "RB") | J/K/CK from write-compare logic; Q/Q̄ → RAM R/W gating via 13D (04) sections | partial — pins not individually read |
| 13D (04) sections | one inverts write line → RAM /OD (pin 1?); one at (3250,1735) 5→6 on the sequencer; one at (4740,5300) 1→2 in the latch chain | sections/pins partly uncertain |
| 2111 RAM (block "10F, 11F, 11E, 11H", caption "2111 × 6") | A0–A7 left (pins as above); /CE1, /CE2 right (bubbled, pins 10?/15?) tied low/controlled; /OD and R/W bottom left (pins 1?, 16?); data 11,12,13,14 per column ↔ 8216 bus pins | **count vs columns unresolved**; control pin numbers uncertain |
| 8216 ×4 (6E, 5E, 4E, 3E) | per package: bus pins (top) 3,6,10,13 ↔ RAM data; left 4,7,9,12 ↔ digit rows; right 2,5,11,14 → P-bus; /CS=1 → GND; /DIEN=15 ← common direction line | clear at package level |

### Score, comparison, rank (array)

| Item | Connection | Confidence |
|---|---|---|
| 7F, 8F (390 duals, "（SCORE）") | 4-decade cascade; clock ← 13H.11; MRs ← reset vertical; outputs QA–QD × 4 → digit rows east | clear |
| 85 row (6H, 5H, 4H, 3H) | A = P-bus (10,12,13,15); B = score rows (9,11,14,1); A=B cascade 6→3 right-to-left; end result → write logic | bus-line/pin pairing not individually verified |
| 85 stack (6F, 5F, 4F, 3F) | A (10,12,13,15) ← score rows; B (9,11,14,1) ← 192 outputs; cascade 3(top)/6(bottom) downward; final → rank logic | same caveat |
| 192 ×4 (7H, 8H, 9H, 10H) | QA–QD = 3,2,6,7 (west, into matrix); presets 15=Vcc, 1=GND, 10=GND, 9=Vcc (= 9); CLR 14 → GND; /LOAD 11 ← "192 LD." common; CPU/CPD (5/4) chained vertically; /BO/(CO) 13/12 at bottom | count direction (up/down pin use) not settled |
| 10A (259) | D=13; A,B,C=1,2,3 ← 11A Q risers; /E=14 ← enable from latch logic; /CL=15 → GND; Q0–Q4 (4,5,6,7,9) → **1ST…5TH → Ⓚ** | clear |
| 11A (390): half-2 at (8335,4630) | CP=15 ← 11B.6; MR=14; QA–QC (13,12,11) → 10A address | clear |
| 11B (08) at (8000,4620) | 4 ← 11D(04) out; 5 ← line from west; 6 → 11A.15 and 10A.13 riser | clear |
| 10B, 10C, 10D (390 duals) | half-1 (1 CP, 2 MR, 3,4-5,6,7 Q): cascade 10B→10C→10D; clock ← 11D(04); outputs → **…-1/-2/-3 A–D buses → Ⓙ** ("（何人中）"); half-2 (15 CP, 14 MR, 13,12-11,10,9 Q): outputs → **R-1/R-2/R-3 A–D buses** (circled letters H?, H?, J? — uncertain); MRs on common rails y≈5020/y≈5800 | clear at package level; R-bus destination letters uncertain |
| 14H (259) | D=13 ← 12E.13; /CL=15, /E=14 (top); A,B,C = 1,2,3 ← east risers (R-1 group); Q outputs (bottom pins read 5,6,7,9,10) → south to bottom edge (per-rank flash lines) | bottom destinations off-sheet/pads not traced |
| 12E (02 NOR, 12,11→13) | 12,11 ← two verticals (latch-timing lines, one from Vs/16 region); 13 → 14H.D | input sources partly traced |
| 13E (279/4 quarter) | pins read 1, 2?, 5? → Q=4; Q loops to the 10A /E region | pin set uncertain |
| 13F at (6710,5290) (drawn as 04 triangle 12→13) | in the R-1 riser region | **designator collides with the 02 at (2560,5345) also marked 13F — one is misread** |

### Outputs (top right)

| Item | Connection | Confidence |
|---|---|---|
| 11C (32, section 12,13→11) | inputs ← comparator-row result lines; 11 → driver chain | clear |
| 2E-1 ("16"; sections 9→8?, 1→2, 11→10, plain triangles) | buffer each S-100 line | section pin sets partly uncertain |
| 11D (04) sections (y≈1215, y≈2400 region, (7790,4600), (3310,4790)) | inverters in the result/driver/clock chains | sections not exhaustively mapped |
| J-pads 27, 26, 29, 25, 28 → G-pads GP?, G13, GR, GN, GB? | → **S-100-A, S-100-B, S-100-C, S-100-D** (brace → **Ⓓ**) and **S-100-D' → Ⓐ** | pad letter names partly uncertain (GP/GB) |
| "LATCH CL." arrow down at x≈4700, bottom edge | → **Ⓚ** | clear |

## R/C and discrete components

| Ref | Value | Where |
|---|---|---|
| RA1 (several) | 1K | pull-ups on pads 23, "b", "c", "d", "e", "f"/"h" lines, 14 MHz node |
| C1 | reads 470p? | near (4850,4950), latch-clock chain (value uncertain) |
| 777 ground symbols | — | 259 "J2" C+/CL, 10A.15, 192 CLRs, 8216 /CS, 9F region, RAM block |

No other discrete values were read on this sheet.

## Off-sheet table

| Label (as written) | Pads | Direction | Sheet |
|---|---|---|---|
| 14M Hz | "a"/G4 | in | Ⓔ |
| /SCORE CP | G5 + 23 | in | Ⓕ |
| /COIN&TEST | G6 + "b" | in | Ⓐ |
| /INI.RESET | 24 (G7) | in | Ⓐ |
| V2 | G8 + "c" | in | Ⓔ |
| H5 | G9 + "d" | in | Ⓔ |
| GAME | "e" (G10) | in | Ⓐ |
| SP. CONT. | G12 + J"h" | in (assumed) | Ⓗ |
| Vs/16 | G11 + J"f" | in | Ⓗ |
| S-100-A/B/C/D | J27/26/29/25 + GP?/G13/GR/GN | out | brace → Ⓓ |
| S-100-D' | J28 + GB? | out | Ⓐ |
| 1ST, 2ND, 3RD, 4TH, 5TH | arrows | out | Ⓚ |
| LATCH CL. | arrow, bottom | out | Ⓚ |
| 14H Q lines | bottom edge | out | not traced |

## Unresolved

1. **Methodology**: net extraction and junction dot-measurement were not run;
   all joins were read visually. The two bus matrices (score rows × P-bus ×
   comparator pins; score rows × 192 outputs) in (3200,2600)-(7200,4200)
   were followed as buses, not wire by wire. Every pin-to-line pairing
   inside the matrices needs verification.
2. **RAM count**: caption "2111 × 6" vs four drawn columns (10F, 11F, 11E,
   11H). Six packages would store 6 digit-nibbles; which designators the
   other two carry is not shown. Crop (2600,1300,4900,2600).
3. **RAM pin numerals**: address pins printed 4,3,2,1 / 17?,…,5,6,7; /OD,
   R/W, /CE1, /CE2 pin numbers partly illegible.
4. **Designator "J2"** on the top 74259 (breaks the grid-letter pattern);
   possibly 12-something. Crop (1900,650,2450,1250).
5. **Designator collision "13F"**: an 02 section at (2560,5345) and an 04
   triangle at (6710,5290) both read 13F.
6. **2E-1** ("16"): drawn as plain (non-inverting) triangles though 7416 is
   inverting; section pin sets partly unread; "-1" suffix meaning unknown.
7. **Pad names**: GP?/GB? on the S-100 lines; G4 vs "a" pairing; G10 vs "e";
   G13 reading (a number pin among letter pins is odd).
8. **R-bus destination letters** (circled, above R-1/R-2/R-3 braces) read
   H?, H?, J? — all uncertain; the P-bus brace's vertical Japanese caption
   reads "ハイスコア…" with a circled mark read I.
9. **何人中 caption** at (4080,5080): translated here only as "out of how
   many (players)" to name the D-bus block; the net names on this sheet are
   the printed "…-1A" style tags, which lack the leading letter on the
   10B–10D group (D- prefix assumed from the r07 arrows).
10. **12B ("RB") 107/2 write logic**: J, K, CK sources and the full RAM
    write-enable path (including the 85-row result) were not traced pin by
    pin.
11. **192 LD. / ADR INC. / RAM R/W / 256 CL.** phase assignment to 12A
    output pins 1–6 not individually confirmed; the fourth label's first
    digit is uncertain ("256 CL." assumed for the 256-location address
    counter clear).
12. **14H bottom outputs**: five lines drop to the bottom edge (expected
    per-rank flash outputs; overview shows pad-like marks below) — pads and
    labels not read.
13. **12F.5**, **259 "J2" D (13)**, **12E inputs**, **13E pin set**,
    **11B.5**, and the east ends of the long sequencer lines from 259
    Q2/Q3 were not traced to their destinations.
14. **Redraw comparison** (stonedDiscord has no 96597 board drawing as far
    as known) — not performed.
15. The bottom-right corner shows only faint specks (no legible table);
    the overview's apparent glyphs there were noise.

## Comparison with stonedDiscord's redraw (23 October 2026)

Attempted 23 October: the redraw repository holds KiCad projects for
Main (96577), Video (96578), Sound (96598) and an LED display module only.
The LED project contains 22 LED digit packages and three 12-pin connectors
— **none of this sheet's logic (RAM, counters, comparators, latches,
drivers) is redrawn anywhere in the repository**, so no pin-level
comparison is possible for sheet I. Unresolved item 14 stands, with this
explanation.

## Memory and ranking — pin-level reading (1 November 2026)

Read pin by pin on source-resolution crops of the stored (upright) page,
with junction dots measured (dots 16–21 px, plain crossings ≤ 15 px).
Coordinates are stored-image pixels. This section **supersedes** the
structural reading above for the sequencer, memory, comparators and rank
logic (items 3–5 and 7–11 of the signal path and the corresponding pin
tables); the earlier text is kept as written. The score counter and the
S-100 / SP. CONT. outputs are in `work/SHEET_I_LOG.md` (31 October), which
this section continues. Logic and tests: [../SHEET_I_LOGIC.md](../SHEET_I_LOGIC.md).

### Reset, power-up delay, sequencer

| Part | Pins | Connection |
|---|---|---|
| 13H (7400, OR body with bubbles) | /COIN&TEST, /INI.RESET → RST | trunk x ≈ 1990 (dots y 1753, 2746): 12C and 12D MRs |
| 7404 at (2210,4285), designator not read | RST → /RST | line y ≈ 4285–4320 east: 12B-left CL, 13E latch 4 /R (x 5145), 13D (5160) 1 → 2 (= RST again → 11A second half MR and 10B..10D second halves' MR along y ≈ 5810), 13E latch 1 /R (x 6780), 12B-right CL (x 7570) |
| 2E (7402) | 3 = 12C.8, 2 = V2 → 1 | 12C second half CP 13 |
| 12C second half | MR 12 = 13A.10 = NOT /INI.RESET; QD 8 | → 2E.3 and 11D (left, (2700,5005)) 5 → 6 = **pwr** |
| pwr (11D left 6) | | 13F'.6; 10B/10C/10D first-half MRs (2); **LATCH CL.** (dot on 10D.2, down x ≈ 4600 → K) |
| 11B (7408) | 12 = 11A.QD, 13 = /INI.RESET → 11 | 13F.3 |
| 13F (7402) | 3 = 11B.11, 2 = H5 → 1 | 11A first half CP 1 |
| 2H (7408, OR body with bubbles) | 10 = /INI.RESET, 9 = GAME → 8 | 11A first half MR 2 |
| 11A first half (74390) | QA 3 = CPB 4 → 13A.9; QB 5 → 12A.15 (A); QC 6 → 12A.14 (B) and 11D (right, (3330,4830)) 5; QD 7 → 12A.13 (C) and 11B.12 | |
| 13A (7404) 9 → 8 | | 12A.12 (D) |
| 12A (7442) | 0 (pin 1) **ADR INC.** (count 1); 1 (2) **192 LD.** (count 3); 2 (3) **RAM R/W** (count 5); 3 (4) → 13F'.5 (count 7) | |
| 13F' (7402) 5, 6 → 4 | 5 = 12A.4, 6 = pwr | **256 CL.**: 10B.1 (N clock, via y ≈ 4555 and x ≈ 3770) and 11C.1 |
| 11D (right) 5 → 6 | NOT 11A.QC | vertical x ≈ 3620 → /DIEN (15) of 6E, 5E, 4E, 3E (dots y 2925, 3309, 3692, 4079). Its crossing with the 192 LD. line (y ≈ 4465) is plain: the earlier log's dot there is withdrawn. |

### Search clock and address

| Part | Pins | Connection |
|---|---|---|
| 12F (7402) | 5 = 12B-left /Q (line y ≈ 2095), 6 = 14 MHz → 4 | 12C first half CP 1 |
| 12C first half | QA 3 → J2.13 (D); QB 4 → J2.1 (A); QC 5 → J2.2 (B), dot (2025,1262) → 12D.13 and 11C.4; QD 6 stub | MR = RST |
| 12D | half 2: CP 13, QD 8 → 12D.1; half 1: QD 6 → line y ≈ 1450 → x ≈ 7839 → **7H DOWN (4)** | MRs = RST |
| J2 (74259) | /E 14, /CL 15, C 3 grounded (demultiplexer) | Q2 (6, count 5) → y ≈ 845 → x ≈ 5780 → 6F A=B in (3); Q3 (7, count 7) → y ≈ 885 → x ≈ 5995 → 6H A=B in (3); other Q stubs |
| 13D (top) 5 → 6 | NOT ADR INC. | 11C.5 |
| 11C (7432) 4, 5 → 6 | 4 = 12C.QC | 9F.1 |
| 9F (74393, both halves) | MRs grounded; half 1 QD → half 2 CP | RAM A0..A7 = pins 4, 3, 2, 1, 17, 5, 6, 7 |
| 13D (3530,2230) | input RAM R/W (12A.3 via x ≈ 3330) | 2111 OD; R/W (16) = RAM R/W |
| 2111 × 4 (10F, 11F, 11E, 11H) | /CE1 10, /CE2 15 grounded | data ↔ 8216 DB |
| 8216 × 4 (6E..3E) | DI 4, 7, 9, 12 = P-1..P-4; DO 2, 5, 11, 14 = D-1..D-4 (D bus to K, labels D-1A.. at x 5190–5300); /CS grounded | |

### Down-counter and comparators

| Part | Pins | Connection |
|---|---|---|
| 7H..10H (74192) | data = 9 (A, D Vcc; B, C ground); CLR 14 ground; /LOAD 11 = 192 LD. (y ≈ 4465 → x ≈ 7610); UP 5 open; 7H DOWN 4 = 12D.6; /BO 13 → next DOWN | 10H /BO → y ≈ 4255 west → 13D 9 → 8 → 11C.2 |
| 11C (7432) 1, 2 → 3 | 1 = 13F'.4, 2 = NOT /BO | x ≈ 2790 → 12B-left (74107, J = K = Vcc) CK; its /Q → 12F.5; Q stub |
| 6H..3H (7485) | A = P-1..P-4, B = 7H..10H (QA..QD pins 3, 2, 6, 7); cascade 6H → 3H | 3H.6 → 12B-right CK (9) |
| 12B-right (74107) | J 8 = Vcc, K 11 = ground, CL 10 = /RST | /Q 6 = **F** → y ≈ 2400 → x ≈ 8120 → y ≈ 4205–4250 west → 11B (5790).10 and 12E.12 |
| 6F..3F (7485) | A = D bus, B = 7H..10H; cascade 6F → 3F | 3F.6 → x ≈ 5765 → 11B (5790).9, and (junction 5765,4677) y ≈ 4677 east → 11B (8000).5 |

### Rank count, R, N, flashing

| Part | Pins | Connection |
|---|---|---|
| 11B (5790) 9, 10 → 8 | match AND F | y ≈ 5697 → 10B second half CP 15 (R) |
| 10B/10C/10D second halves | cascade QD → CP; MR = RST | R-1, R-2, R-3 (to J); 10B.9 (R-1D) → 10C.15 and 13F (6710, 7404) 13 → 12 → 13E (74279 latch 1) /S 2 |
| 13E latch 1 | /R 1 = /RST; Q 4 | y ≈ 4800 → 14H /E (14) |
| 10B/10C/10D first halves | CP 10B.1 = 256 CL.; cascade; MR = pwr | N-1..N-3 (to J, "（何人中）") |
| 11D (7900) 11 → 10 | NOT 11A second half QD (junction 7700,4570 on the line y ≈ 4545 from 11A.9) | 11B (8000).4; the same line → 14H /CL (15) at x ≈ 6230 |
| 11B (8000) 4, 5 → 6 | NOT QD AND match | 11A second half CP 15 and 10A D (13) |
| 11A second half (74390) | QA 13 = CPB 12 → 10A A (1); QB 11 → B (2); QC 10 → C (3); QD 9 → stop line; MR 14 = RST | |
| 10A (74259) | /E, /CL grounded (demultiplexer) | Q0..Q4 (4, 5, 6, 7, 9) = **1ST..5TH** → K |
| 12E (7402) 12, 11 → 13 | 12 = F, 11 = Vs/16 (pad f, 1 kΩ) | 14H D (13) |
| 14H (74259) | A, B, C = R-1A, B, C (dots x 6535, 6580, 6620) | Q1..Q5 (5, 6, 7, 9, 10) = **1ST..5TH FLASH** → J |

### Closed by this reading

Unresolved items 2 (four 2111s; the caption's digit is a 4 or a badly
drawn 6, four columns are drawn and 16 bits are used), 3 (address pins),
10 (12B), 11 (12A phases: 256 CL. confirmed by its function), 12 (14H
outputs → J), 13 (12F.5, J2 D, 12E inputs, 13E pins, 11B.5, J2 Q2/Q3 east
ends) and the R-bus destination (J, under the circled-I brace on sheet J).
Item 5: the 7404 at (6710,5290) is the section 13 → 12 named 13F above;
its designator still collides with the 7402s named 13F.

### Correction

7H's DOWN (pin 4) is drawn on 12D's QD. The real board behaves as if it
were the inverse (Aldo's photo of the panel, 1 November 2026: 1ST flashes
for a new best score). See [../SHEET_I_LOGIC.md](../SHEET_I_LOGIC.md),
"The correction: 7H's DOWN clock".
