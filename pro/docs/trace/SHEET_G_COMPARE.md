# Sheet G compare: Pro page 10 against the original (Pro Monaco GP)

Date 2026-11-06, issue #86. Pin- and net-level comparison of Pro sheet G
(96822-P D-3/5, PDF page 10) with the original sheet G (96577-P D-3/4,
420-0358 page 27), function by function: the line and pixel counters and
windows, the player PROMs and their enables, the select-state logic, the
headlight, the explosion and the splash. PLAYER ST and /SCORE ST into sheet
N are already traced in `BONUS_INPUTS_TRACE.md` and are only cited. The
section "Known values (sheet F)" also confirms two values on Pro sheet F
(page 9) that the issue lists.

**Main results**

1. **New circuit on Pro G: INI.AP in, /L3-SIDE and /R3-SIDE out, all to
   sheet H.** Five gates at the top of the sheet that the original does not
   have: IC23 (4-input AND) = AND(INI.AP, VC7, /SP.DOWN, /EXTEND); IC31
   12,13→11 = AND(VC6, VC5); IC24 11,12→13 = NOR(VC6, VC5); IC17 9,10→8 =
   NAND(IC23.6, IC31.11) → /L3-SIDE; IC17 12,13→11 = NAND(IC23.6, IC24.13) →
   /R3-SIDE. The readings are clear or probable. What the outputs do is not
   settled here: as read, VC7 = 1 only once the line counter has stopped at
   0x80, where VC5 = VC6 = 0, so /L3-SIDE could never go low on settled
   counts. Either something in this reading is wrong or the signals work in
   a way this sheet does not show; it needs the sheet H end and a second
   reader.
2. **Two capacitor differences.** C6 470 pF to ground on NOT W (the
   headlight window, IC25 8), where the original draws none. The PL-H-ST
   capacitor C11 is marked `* 680P ~ 470P ADJ.`, a select-on-test value,
   where the original has C23 470 pF fixed.
3. **Everything else is the same function and net.** The rest of the sheet
   matches the original part for part: the same gate functions and the same
   PROMs (PR-125 to PR-131), with every value that could be read the same
   (680 pF, 470 pF, 10 µF, 47 kΩ). Only IC numbers, gate positions within
   packages and 74279 latch sections differ. One of those settles an
   original-board question for Pro: the window latch uses a 279 section
   with a single /S input, so there is no undrawn /S2 (original
   `SHEET_G_PLAYER.md` unresolved item 1).
4. **Sheet F values (issue's list):** C54 470 pF is confirmed (on the V6/V7
   selector control; nothing on the original net). C32 22 µF on the pool
   one-shot is confirmed (original C18 15 µF).

## Sources and method

- Pro: `pro/schematics/promonacogp420-0525_1.pdf`, page 10 rendered with
  PyMuPDF at `Matrix(1, 1)`, upright, 10192 × 6617; page 9 (sheet F),
  10175 × 6617. Every Pro box below is (left, top, right, bottom) on that
  render. Crops were read at 0.5× to 4×.
- Original: `schematics/pages/page27-sheet-G.png` (10160 × 6624, upright)
  with `docs/trace/SHEET_G_TRACE.md` and `docs/trace/SHEET_G_PLAYER.md`;
  for F, `schematics/pages/page26-sheet-F.png` (stored upside down, read
  rotated 180°) with `docs/trace/SHEET_F_TRACE.md`. The Pro layout
  follows the original closely, shifted about 500 px to the right in the
  middle of the sheet, so each Pro crop was compared with the matching
  original crop.
- Reading rules are those of `pro/README.md`. A drawn dot is a junction
  (about 28–35 px here); a crossing is not, even where the scan thickens it.
  Gate function is taken from the symbol. Pin numbers were checked against
  standard 74xx pinouts.
- Confidence: **clear**: read directly, with no competing reading.
  **Probable**: one reading fits much better, but the scan is not clean,
  or the pins were compared only at block level. **Uncertain**: the scan
  does not settle it.
- Excluded: PLAYER ST and /SCORE ST, with the gates that make them (IC31
  1,2→3, IC32 HWIN, IC38 HC counter, IC121 second half, IC95), which are in
  `BONUS_INPUTS_TRACE.md`. Their comparison there is cited, not redone.
- No MAME, emulator, other core, KiCad redraw, footage or gameplay
  description was used.

## Comparison by function

### Line counter and vertical window

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| VC clock gate NOR(/HS, VC7) | IC63 5,6→4 (`SHEET_G_PLAYER.md`) | IC24 6,5→4; pin 5 down to a dot on VC7 | (3300, 1000, 4000, 2100) | same | clear |
| VC counter, 74393 | IC54: pins 1–6 VC0..VC3, pins 13–8 VC4..VC7 | IC18: upper half (A 13, CL 12) gives VC0..VC3, its QD clocks the lower half (A 1, CL 2, outputs 3–6 = VC4..VC7). The two halves have swapped pin numbers; same function | (3300, 1000, 4000, 2100) | same | clear for the structure; the upper half's output numerals are faint (probable) |
| PL-V-ST capacitor | 680 pF, unnamed | C5 `680P` | (2800, 1450, 3150, 1800) | same | clear |
| VWIN reset NAND(VC6, VC4) | IC48 (pins not drawn) | IC17 1,2→3 | (3450, 1300, 4800, 2350) | same | clear |
| /VC6 | IC46 3→4 | IC25 3→4 | same box | same | clear |
| VWIN set NAND(/VC6, VC5, VC4) | IC45 1, 2, "3"→12 | IC29 13, 2, 1→12 (13 drawn, as a 7410 requires) | same box | same | clear |
| VWIN latch | IC51 section 1: /R 1, /S1 2, Q 4; /S2 pin 3 not drawn (U1) | IC37 section 2 (`279/4`): /R 5, /S 6, Q 7; this section has only one /S | (3700, 2250, 4600, 2850) | same function; the undrawn-pin question does not arise on Pro | clear |
| NAND(VWIN, HWIN) | IC56 4,5→6 | IC30 9,10→8 | same box | same | clear |
| STROBE = OR(IC56.6, EXPLO.ST) → 74153, 7442 | IC62 9,10→8 | IC73 13,12→11 (bubbled inputs and output) | (5400, 2550, 6900, 4050) | same | probable (inputs followed near the gate only) |

### Pixel counter and horizontal window

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| HC counter, 7 MHz NOR, AND(HC5, HC7), HWIN NOR, /HC7 | IC52, IC63, IC34, IC57, IC46 | IC38, IC24 2,3→1, IC31 9,10→8, IC32 5,4,2,1→6, IC25 1→2 | `BONUS_INPUTS_TRACE.md`, PLAYER ST section | same (cited) | clear (per that trace) |
| PL-H-ST capacitor | C23 470 pF | C11, marked `* 680P ~ 470P ADJ.` | (3050, 4400, 3600, 4800) | **differs** | clear |

### Player PROMs, multiplexer, decoder

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| PR-127..PR-130 address bus (VC0..VC4, HC2..HC4, Vs/4 or Vs/8 on A8) | IC77, IC84, IC91, IC98 | PR-127..PR-130 at IC58 (numeral faint), IC64, IC70, IC77; the same riser and dot pattern on pins 8..1, 23 | (6900, 1350, 7800, 3450) | same | probable (pattern compared at 0.5×, not pin by pin) |
| Enables: PR-127 pins 18, 19 = AND(/ACC1, IC119 /Q); PR-128 /CE = select NOR; PR-129, PR-130 /CE = OR(/ACC1, ±Vs/16); CE3/CE4 of 128–130 = /EXPLO.ST | IC66.3, IC72.1, IC95 4,5→6 and 9,10→8, IC73 11→10 | IC31 4,5→6, IC24 8,9→10, IC76 12,13→11 and 10,9→8, IC88 13→12 | (7600, 1350, 9200, 3450) | same | clear |
| 74153 data mux, select HC0/HC1 | IC76 | IC57 (`153`) | (7600, 3300, 9500, 4500) | same | clear |
| 7442 decoder → /PLAYER BODY, /PLAYER TIAR, /PLAYER (BL) | IC83 | `42` caption, designator read as 86 | same box | same | clear; designator probable |
| /PLAYER = NOR(1Y, 2Y) | IC61 9,8→10 | IC72 11,12→13 | same box | same | clear |
| PLAYER → (F) | IC44 11→10 | IC88 3→4 | (6600, 4500, 9000, 5700) | same | clear |
| Pads to C: BV, B19, BW, B9, BK, B4 | as listed | same pads; drawn filled instead of open (style) | (7600, 3300, 9500, 4500) | same | clear |

### Select-state logic

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| Vs/32 counter (393 half), 470 pF on Vs/32 | IC38 (13, 12, 11..8), 470 pF unnamed | IC20 (A 1, CL 2, outputs 3..6), C7 `47?P` | (1700, 1800, 3600, 3400); value (1850, 2400, 2100, 2620) | same | clear structure; value probable 470 pF (the 0 is faint) |
| /ACC1.PULSE = NAND(QB, QC, QD) | IC80 3,4,5→6 | IC29 5,4,3→6 | (1700, 1800, 3600, 3400) | same | clear |
| Select NOR(QD, IC119 Q) → PR-128 /CE and /SP.DOWN (F) | IC72 3,2→1 | IC24 8,9→10 | same box | same | clear |
| 393 clear = OR(/EXTEND, /ACC1.ST latch Q) | IC62 4,5→6 | IC76 4,5→6 | same box | same | clear |
| AND(/GRAVEL, /SLIDE) → slide one-shot A | IC66 12,13→11 | IC122 9,10→8; pads C14 (/GRAVEL) and CR (/SLIDE) captioned | (1500, 3250, 3500, 4300) | same | clear |
| Slide one-shot (A, B, /CLR, Q, /Q) | IC119: A 9, B 10, /CLR 11, Q 5, /Q 12 | IC121 first half, same pins | same box | same | clear |
| Slide one-shot timing | C30 10 µF, R16 47 kΩ | C43 `10µ`, R25 `47K`; an extra handwritten mark above-left of the capacitor (like `R:9K`) is not read | (2950, 3270, 3400, 3570) | same values | probable; the extra mark is uncertain |
| Slick one-shot → /SCORE ST, and its B gate | IC19, IC68 | IC121 second half, IC95 | `BONUS_INPUTS_TRACE.md`, /SCORE ST section | same (cited) | clear (per that trace) |
| /ACC1.ST latch (/R = /HOME POS., /S = slick Q) | IC51 section 2: 5, 6 → 7 | IC37 section 4: /R 14, /S 15, Q 13 | (1500, 3250, 3500, 4300) | same | clear |

### Headlight (PR-125)

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| PR-125 enables, address, data | IC59: /CE ground, CE /ACC1, A0..A6 = VC0..VC6, A7 = NOT W, A8 ground | IC45, the same pins; A7 riser from IC25 8 enters pin 1, pin 23 to ground | (4700, 2850, 5800, 4200); (4150, 2950, 4900, 3450) | same | clear |
| Comparator pair, 7485 | IC53, IC58 | IC44, IC39 (the 39 is written over an `85`) | (4700, 2850, 5800, 4200) | same | clear |
| EQ capacitor | 470 pF, rotated, partly legible (U2) | C12, rotated, `47?` | (5500, 3800, 5750, 4050) | same | probable 470 pF |
| W = NOR(HC5, HC6, HC7, /TUNNEL) | IC57b, inputs 12, 10, 9, 13; strobe 11 not drawn | IC32 second half: 10 = HC5, 12 = HC6, 13 = HC7, 9 runs down toward /TUNNEL; → 8 | (3500, 4250, 4700, 5500) | same | clear for HC5..HC7; pin 9 = /TUNNEL probable (followed at 0.5×) |
| NOT W → PR-125 A7, latch NAND | IC46 9→8 | IC25 9→8 | (4380, 3250, 4650, 4450) | same | clear |
| Capacitor on NOT W | none drawn (the original trace notes the redraw's C46 is not on the scan) | **C6 `470P`** to ground, joined by a dot on the IC25 8 riser | (4300, 4050, 4700, 4400) | **differs** | clear |
| NOT VC7 → comparator A=B in | IC46 11→10 | IC25 5→6 | (4250, 1950, 4900, 3500) | same | clear |
| NAND(/W, EQ) → /S2; NAND(EQ, W) → /R, 470 pF on /R | IC56 13,12→11 and 10,9→8 | IC30 1,2→3 and 12,13→11; C10 `470P` | (5300, 3950, 6600, 4800) | same | clear |
| AND(/ACC1, IC119 /Q) → /S1 | IC66 1,2→3 | IC31 4,5→6 | same box | same | clear |
| /LIGHT latch and output capacitor | IC51 section 3 (/S1 11, /S2 12, /R 10, Q 9), C22 470 pF; pad BC | 279 section 1 (/S1 2, /S2 3, /R 1, Q 4), designator illegible; `470P C?`; pad BC | same box; (6250, 4150, 6600, 4320) | same | clear; capacitor designator uncertain |

### Explosion (PR-126)

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| PR-126 and its 74151 | IC65, IC64 | IC51, IC50; the same enable, address and data pattern | (5400, 2550, 6900, 4050) | same | probable (pins compared at 0.7×) |
| Strobe NOR(IC56.6, SEL D, /EXPLO.ST), inverted to the 151 /G | IC74 5,4,3→6; IC44 3→4 | IC63 2,1,13→12; IC25 13→12 | same box | same | pin 2 clear; pins 1 and 13 probable |
| NOR(SEL A, SEL C) | IC63 9,8→10 | IC102 4,5→6 | same box | same | probable |
| /EXPLO (Y) = NAND(IC63.10, Y) | IC56 1,2→3 | IC71 1,2→3 | same box | same | clear |
| /EXPLO (R) = OR(/W, IC63.10) | IC62 12,13→11 | IC72 1?,2→3 | same box | same | clear function; one pin numeral faint |
| EXPLO.ST, EXPLO.SEL A..D, /EXPLO.ST arrows from F | as listed | the same arrows and riser routing | (5700, 300, 7100, 1500) | same | clear |
| /EXPLO AREA pad C15 | IC64 /W | IC50 /W, pad C15 | overview | same | clear |

### Splash (PR-131)

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| PR-131 and its 74151 | IC71, IC70; CE3/CE4 Vcc | IC84, IC83; Vcc on 18, 19 | (6600, 4500, 9000, 5700) | same | probable (pins compared at 0.45×) |
| Splash latch: /R = NAND(VC4, VC5), /S = NAND(/VC5, VC4) | IC48 12,13→11; IC44 13→12 (U1: 44 or 46); IC48 5,4→6; IC51 section 4 | IC17 4,5→6; IC25 11→10; IC30 4,5→6; IC36 section 3 (/R 10, /S1 11 with /S2 12) | (5050, 1800, 5800, 2700) | same | clear |
| PR-131 /G = NAND(latch Q, HWIN, SPLAY B) | IC45 10, 9, 11→8 | IC29 9, 11, 10→8 | (6600, 4500, 9000, 5700) | same function; which net is on which pin was not followed | probable |
| /SPLAY pad B10 | IC70 /W | IC83 /W | same box | same | clear |

### Inputs and outputs

| Function / net | Original (trace ref) | Pro reading | Pro box (L,T,R,B) | Verdict | Confidence |
|---|---|---|---|---|---|
| Left inputs: Vs/4, Vs/8, Vs/16 (H); /ACC1 (F); /H5 (E); PL-V-ST, Vs/32, /EXTEND, /GRAVEL, /SLIDE, /HOME POS., 7MHz, PL-H-ST, /COIN IN, /TUNNEL, /SPLAY A, SPLAY B | as listed | the same labels and sources | overview (0, 0, 10192, 6617) | same | clear |
| Bottom outputs to F | /SCORE ST, /ACC1.PULSE, /ACC1.ST, /SP.DOWN, SP.DOWN, PLAYER | the same; PLAYER ST (N) and the N branch of /SCORE ST are new (cited) | overview | same, apart from the N branches | clear |
| INI.AP (H) in; /L3-SIDE (H), /R3-SIDE (H) out | none | new; see "Differences" | (4350, 350, 5700, 1550) | **differs** | see below |
| Title-block note `ジャンパー線無し` ("no jumper wires") | none | next to the title and the drawing number | (1500, 700, 3600, 1300) | not circuit | clear |

## Differences

### D1. New INI.AP, /L3-SIDE, /R3-SIDE circuit (top of the sheet)

Pro box (4350, 350, 5700, 1550), with risers in (4380, 1050, 4850, 2050),
(4150, 2950, 4900, 3450) and (2900, 3900, 4550, 4600).

| Element | Reading | Confidence |
|---|---|---|
| INI.AP | Arrow from circled H at the top, no overbar, down to IC23 pin 5. It crosses the top rows (Vs/4..Vs/16, /ACC1, /H5) without dots | clear |
| IC23 | 4-input AND body, **no output bubble** (4× zoom), pins 5, 4, 2, 1 → 6: a 7421 section | clear |
| IC23 pin 4 | Riser x ≈ 4440, down to a dot where the VC7 row ends (4440, 1966); the same vertical continues to IC25 pin 5 (NOT VC7) | clear |
| IC23 pin 2 | Riser x ≈ 4485, down to y ≈ 4150, then left to a dot at (3445, 4145) on the /SP.DOWN vertical (IC24 8,9→10 output down to the /SP DOWN (F) arrow) | clear |
| IC23 pin 1 | Riser x ≈ 4521, down to y ≈ 3181, then left along the /EXTEND (A) row; crossings at x ≈ 3500–4500 have no dots; the row is faint right of x ≈ 3800 | probable |
| IC31 12,13→11 | AND body, no bubble (4× zoom): AND(VC6, VC5). Pin 12 riser x ≈ 4570 has its dot on VC6 (4570, 1922); pin 13 riser x ≈ 4614 has its dot on VC5 (4614, 1878) | clear |
| IC24 11,12→13 | AND body, both inputs bubbled: NOR. Pins 11 and 12 join the IC31 pin 12 and 13 risers with dots | clear |
| IC17 9,10→8 | Pin 10 = IC23.6 (dot), pin 9 = IC31.11. Output 8 runs right and up to `/L3-SIDE` (H), with an overbar | connections clear; function probable NAND (see below) |
| IC17 12,13→11 | Pin 12 = IC23.6 (dot on the same branch), pin 13 = IC24.13. Output 11 runs up to `/R3-SIDE` (H), with an overbar | connections clear; function probable NAND |

**Gate type of IC17 9,10→8 and 12,13→11.** The bodies are faded at the
output end. There is a gap of about one bubble's width before each
output wire, but no bubble outline. IC17 1,2→3 and 4,5→6 on the same sheet
are drawn as NANDs with clear bubbles, and the overbars on both labels
fit active-low outputs, so a 7400 is probable. An AND is not excluded.

**Package bookkeeping (consistency only).** With these gates, every section
of IC17 (7400), IC24 (7402), IC25 (7404: 1, 3, 5, 9, 11, 13) and IC31
(7408) is used once. No two gates claim the same pins.

**Function as read.** IC23.6 = INI.AP · VC7 · /SP.DOWN · /EXTEND.
/L3-SIDE = NOT(IC23.6 · VC6 · VC5). /R3-SIDE = NOT(IC23.6 · /VC6 · /VC5).
The line counter stops at 0x80 (IC24 6,5→4 = NOR(/HS, VC7), as on the
original). So VC7 = 1 only at the stopped count 0x80, where VC5 = VC6 = 0.
On settled counts, /R3-SIDE is then low whenever INI.AP, /SP.DOWN and
/EXTEND are all high, and VC is past the player's 128 lines. /L3-SIDE
is never low. The 74393's ripple from 0x7F to 0x80 also passes through no
state with VC7 and VC5 or VC6 set. A signal that can never assert is
unlikely to be drawn on purpose, so either one of the readings above is
wrong (the riser dots were each checked at 2.5×, which makes that less
likely), or VC7 is not at its stopped value when these signals are used.
**Can't settle from this sheet.** It needs the sheet H end (the source of
INI.AP and the loads of /L3-SIDE and /R3-SIDE) and an independent second
reading of the three riser dots.

**For reuse of the Monaco G module.** Add the five gates. Bring INI.AP
in from H, and send /L3-SIDE and /R3-SIDE out to H. This adds loads on
VC5, VC6, VC7, /SP.DOWN and /EXTEND but changes none of them. Nothing else
on G uses the new outputs.

### D2. C6 470 pF on NOT W (headlight window)

Pro box (4300, 4050, 4700, 4400). On the IC25 9→8 output (NOT W, to
PR-125 A7 and the headlight latch NAND) a dot leads left to C6 `470P` to
ground. The original draws no capacitor on this net (`SHEET_G_TRACE.md`
records only the redraw's C46, absent from the scan). Clear. For reuse:
a filter on a combinational net. A settled-state model like
`jtmonacogp_player.v` needs no change. It matters only in a model of
glitches.

### D3. PL-H-ST capacitor is select-on-test

Pro box (3050, 4400, 3600, 4800). C11 reads `* 680P ~ 470P ADJ.` (an
asterisk, then 680P, a tilde, then 470P, then ADJ.) on the PL-H-ST line
to ground, against the original's C23 470 pF. Clear. So the value was
chosen on the board, between 470 and 680 pF. For reuse: PL-H-ST shaping
is not modelled in the Monaco core (original unresolved item 8), so this
changes nothing in the RTL. It shows only that the pulse on this line was
tuned on the board.

### Not counted here: PLAYER ST and the N branch of /SCORE ST

These are in `BONUS_INPUTS_TRACE.md`: PLAYER ST is new, built from
existing nets, and /SCORE ST is the same net with an added destination.

## Known values (sheet F)

| Item | Pro reading (page 9) | Pro box (L,T,R,B) | Original | Verdict | Confidence |
|---|---|---|---|---|---|
| C54 | **C54, 470 pF** (`C54`, `470P`) to ground, joined by a dot to the output row (pin 6) of the gate with /TUNNEL (pad BF) on pin 5 and pin 4 as the other input (OR body, bubbled inputs: NAND). That row runs right to the V6/V7 selector, with pads BN (V7) and B12 (V6) | (2800, 850, 4800, 1250) | The equivalent net (IC8 12,13→11 output to the V6/V7 selector IC67) has no capacitor (`SHEET_F_TRACE.md`; original page 26, upright box (2800, 650, 6500, 1950)) | **Confirmed**: 470 pF added on Pro | clear |
| Pool one-shot timing | **C32, 22 µF** (`22µ`, the µ written like an r) between the timing pins of the /POOL(2) half of IC99 (pins 6, 7 drawn), positive toward 7; resistor `47K` to Vcc (designator washed out, `R?5?`). A faint `9.9?` mark above-left is not read | (1300, 2930, 1900, 3150); context (850, 2500, 2750, 3800) | C18 15 µF, R10 47 kΩ, IC43 pins 6, 7 (`SHEET_F_TRACE.md`; upright box (1000, 2450, 3050, 3400)) | **Confirmed**: 22 µF against 15 µF; resistor unchanged | 22 µF clear; resistor designator and the faint mark uncertain |

Also seen on the same crop (not in the issue's list, recorded only):
the /SLIP half's C35 reads `10µ` and its R21 `47K`, as on the original
(C20 10 µF, R11 47 kΩ), with an extra handwritten mark (`9.9?K`-like) above
the resistor that was not read. The trigger, clear and output pins of both
IC99 halves match the original IC43 (/SLIP: 1, 2, 3 → 13, 4; /POOL(2):
9, 10, 11 → 5, 12).

## Still uncertain

1. **D1 behaviour.** As read, /L3-SIDE can never go low (see D1). To
   settle: trace INI.AP, /L3-SIDE and /R3-SIDE on Pro sheet H. Then have
   a second reader check the IC23 pin 4 dot (4440, 1966) and the IC31/IC24
   dots (4570, 1922), (4614, 1878) against the VC row assignment (rows at
   y ≈ 1834, 1878, 1922, 1967 = VC4..VC7).
2. **IC17 9,10→8 and 12,13→11 gate type** (probable NAND, faded output).
   To settle: a cleaner scan, or the H end showing the expected polarity.
3. **IC23 pin 1 = /EXTEND.** The row is faint across x ≈ 3800–4500. To
   settle: a continuity walk along y ≈ 3181.
4. **Handwritten extra marks** beside R25 on G (slide one-shot) and beside
   C32 and R21 on F. They may be measured values or value changes. Not
   read.
5. **Capacitor values read as `47?`** (C7 on Vs/32, C12 on EQ) are probably
   470 pF, as on the original. Their last digit is faint or rotated.
6. **W gate pin 9 = /TUNNEL**, and the pin order on the splash NAND IC29
   9, 11, 10: these were followed only at low zoom. Neither affects the
   function if the nets are as on the original.
7. Designators that are faint: PR-127's IC number, the /LIGHT latch's 279,
   the /LIGHT capacitor, the 7442 (86).

## Not checked

- Pin-by-pin address and data wiring of PR-125..PR-131 and the two 74151s
  (compared as a pattern only).
- PROM contents. Pro's PR-125..PR-131 were not dumped or compared; equal
  part numbers do not prove equal contents.
- The sheet H end of INI.AP, /L3-SIDE and /R3-SIDE. That belongs to the H
  comparison.
- The rest of Pro sheet F, beyond the two listed values and the one-shot
  pins next to them.
- Timing of the 74123s and the 470/680 pF filters; no electrical model was
  run.

## Short report

Sheet G was compared function by function with `SHEET_G_TRACE.md` and
`SHEET_G_PLAYER.md`. 52 rows in all: **48 same**, **3 differ**, **0 can't
settle**, plus 1 row that is not circuit (the title note). The three
differences are D1, the new INI.AP → /L3-SIDE, /R3-SIDE gates to sheet H
(readings clear or probable, behaviour unresolved), D2, C6 470 pF added
on NOT W, and D3, PL-H-ST capacitor C11 `680P ~ 470P ADJ.` instead of
470 pF. PLAYER ST and the N branch of /SCORE ST are excluded and cited.
On sheet F, C54 470 pF and C32 22 µF (original 15 µF) are confirmed.
Nothing was run. This document was the only file written.
