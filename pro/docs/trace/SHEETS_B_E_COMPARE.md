# Pro sheets B and E compared with the original

Date: 2026-11-06. Issue #85. Sega 420-0525 (Pro Monaco GP), sheet B (PDF
page 13, board 96823-P D-1/5) and sheet E (PDF page 16, 96823-P D-4/5),
compared with the original's sheet B (420-0358 page 29, 96578-P D-1/5) and
sheet E (page 32, 96578-P D-4/5), by function and net. IC numbers differ
between the boards and prove nothing; a cross-reference is given.

**Scope.** Every section of both Pro sheets was compared with the original
traces (`docs/trace/SHEET_B_TRACE.md`, `docs/trace/SHEET_E_TRACE.md`) and the
original scans. Sheet E and the text section of sheet B were compared pin by
pin. The road (MH, M1V, M2V) part of sheet B was compared section by section,
with the inputs that changed followed to their source; its unchanged
counters and feedback gates were spot-checked, not read pin by pin (see "Not
checked"). No HDL was changed. MAME, the remake, footage and gameplay
descriptions were not used.

## Answers to the issue's three questions

### 1. Is the GAME OVER / DEPOSIT COIN window the same?

**Yes, in H, in V and in the PROM addressing. One input of the window gate
now comes from a different place.** Confidence: **clear** for the address
and the H and V terms. The /H8 input is **probable**, because its subscript
is hidden by a wire, as on the original. The changed input is **clear** as
drawn; what it carries is **not settled**.

- **PROM addressing: the same.** PROM IC80 (original IC64) gets V1..V6 on
  pins 8..3, H3 on pin 2, H8 on pin 1 and /COIN IN on pin 23. Pins 18 and 19
  go to Vcc and pins 20 and 21 to GND. Data pins 9, 10, 11, 13..17 go to the
  151 (IC79, original IC63) pins 4, 3, 2, 1, 15..12, and H0, H1, H2 go to its
  selects 11, 10, 9. The four messages are drawn in the same order (EXTENDED
  PLAY, START, GAME OVER, DEPOSIT COIN). The marking `µPB-425D` is the same.
  **The PR number is illegible on Pro** (`PR-` followed by faint marks), so
  the drawing does not show whether the Pro PROM is PR-133 or a different
  part with different contents.
- **H window: the same.** T_H = NAND(H4, H6, H7, latch Q) (IC77 upper,
  original IC71). T_COIN = NAND(/H5, H8, /GAME) (IC81, original IC55). /GAME
  still comes from pad E6. T_MSG = NAND(H5, /H?, X, Vs/16) (IC77 lower), where
  X is the changed input below. The strobe gate IC24 (AND, drawn as an OR body
  with bubbles everywhere, like the original's IC52) and IC78 1,2→3 (OR, an
  AND body with bubbles everywhere, like the original's IC70 4,5→6) are the
  same functions. So the GAME OVER / EXTENDED PLAY window is **H 0F0–0FF**,
  and the DEPOSIT COIN / START window is **H 1D0–1DF**, on both boards. These
  values use the sheet E ranges, which are also the same (question 2).
- **V window: the same.** 7442 IC71 (original IC54) decodes A=V5, B=V6, C=V7,
  D=GND. 279 latch IC91 (original IC68) is set by output 2 (pin 3) and reset
  by output 6 (pin 7), with C20 470p on /R (an unnumbered 470p on the
  original). Its Q runs to T_H. So the window is lines **40–BF** on both
  boards.
- **/H? on T_MSG.** The subscript is again covered by the wire that crosses
  it. Sheet E sends only /H5 and /H8 to B. /H5 would make T_MSG = NAND(H5,
  /H5, …), which is always high, and GAME OVER would never show. So it is
  /H8, as on the original. **Probable**, forced by logic, not read.
- **Changed: X, the message qualifier.** On the original, sheet B's IC72
  forms X = NAND(/EX.SIGNAL (pad F1), /COIN IN (pad E1)), that is EX.SIGNAL
  OR COIN IN. **On Pro, IC72 is not there.** Pad F1 is captioned
  `EX.SIGNAL (A)` with **no overbar**, and its wire goes straight to the IC77
  input. On Pro sheet A, pad C1 `EX.SIGNAL (B)` is driven by NAND IC35
  (12, 13 → 11: an OR body with bubbles on both inputs). Input 13 is the
  74123 IC60 /Q, the original's /EX.SIGNAL. Input 12 comes from a row that
  runs left across sheet A, and its source was **not traced**. So the gate
  appears to have moved from B to A. Whether its second input is still
  /COIN IN is **not settled here**.
- **Changed: pads.** /COIN IN reaches the PROM on pad **E1** (the original
  used ED, and its E1 fed IC72). It is forwarded to (M) only (the original
  went to (M)(D)), and it now also feeds the new IC72 flip-flops (see
  "Differences, sheet B").
- **New: C18 on the text output.** IC79.6 (TXT, the 151's /W) has a capacitor
  to GND, `C18 470P  1000P ※ ADJ.`, a value chosen on test. The original has
  no capacitor on that net. It does not move the window, but it slows the
  edges of the text video by an amount the drawing does not give.
- **Output gates: the same.** IC78 4,5→6 = OR(TXT, T_MSG) → `/EX.& GAME OVER
  (C)` and IC78 9,10→8 = OR(TXT, T_COIN) → `/COIN & START (C)`. Their input
  bubbles are faint, as on the original (U4). The OR reading is probable: it
  rests on IC78 1,2→3 in the same package, which is drawn clearly with OR
  bubbles.

**For the +200 trace (`SHEET_M_C_PLUS200_TRACE.md`):** its assumption that
"Pro sheet B keeps that window" holds. GAME OVER is H 0F0–0FF on lines
40–BF, so the +200 band at H 100–10F is the 16 clocks right after GAME OVER.
GAME OVER's 64 columns again come from V1..V6.

### 2. Are the H and V counter ranges and the V-④ decode the same?

**Yes.** Confidence: **clear**. Every counter, flip-flop, load and decode
connection on Pro sheet E matches the original net for net; only IC and pin
numbers differ (cross-reference below). So H runs 098–1FF and then 1A0–1FF
(456 clocks a line), and V runs 008–0FF and then 1F0–1FF (264 lines). The
/HS, /VS, blanking and /SYNCRO decodes are the same, and so is the 14.305
crystal (X1 printed `?4.305` on Pro, first digit cut).

- **H.** 161s IC108 (A,B,C = GND, D = blank) and IC115 (A = blank, B =
  /blank, C = GND, D = Vcc; P = IC108 CA). IC109 first half: J = /blank,
  K = blank, CP = IC115 CA, Q = H8. Second half: J, K and /CLR on H8, CP =
  IC115 CA, Q = blank. Load = NAND(IC108 CA, IC115 CA, H8) (IC102 10,9,11→8,
  C23 470p). /HS = NAND(/H5, H6, blank) (IC102 3,4,5→6, C22 1000P). The
  buffer IC110 (AND with pin 4 at Vcc) drives pad FJ and the (B)(D)(M) arrow.
  All as on the original.
- **V.** 161s IC101 (A,B,C = GND, D = V8; CP = /HS) and IC94 (A..D = /V8,
  T = IC101 CA, CP = /HS). The load is V-CA inverted (IC87 1→2, C21 470p).
  IC116 has J, K and /CLR at Vcc, CP = V-CA, Q = V8. /VS = NAND(/V3, V2, V8)
  (IC102 1,13,2→12, C24 470p). Blanking: NOR(V4..V7) (IC95 9,10,12,13→8),
  then NOR(GND, V8, blank, that) (IC95 1,2,4,5→6) → /TV-BLANKING (C).
  /SYNCRO = XOR(/HS, /VS) (IC113 5,4→6). All as on the original.
- **V-④.** 7442 IC71: A = V5, B = V6, C = V7, D = GND. Output 4 (pin 5) is
  low only for V7..V5 = 100, so lines **080–09F**. With V8 = 1 (lines
  1F0–1FF) the decoder sees 111 and V-④ does not fire. This is the same as
  the original's IC54 output 4. The arrow caption **adds (C)**: Pro reads
  `Ⓜ Ⓓ Ⓒ` where the original reads `Ⓜ Ⓓ`, crops b-arr and o-arr. The other
  four arrows, V-①, ②, ③ and ⑤, are `Ⓜ` on both. On Pro, V-②'s letter
  reads clearly as M (original U2 note).

**For the +200 trace:** its use of the original ranges (H 100–10F,
V 080–09F) is confirmed for Pro.

### 3. Is V2 one signal on both boards?

**Yes: V2 is one net on both boards. But the second "V2" that sheet I
receives on pad HU is a different signal, V2′, which is new on Pro.**
Confidence: **clear** for the sheet E wiring. The pad pairings across the
harness (F6–C6, D7–HH, DP–HU) are **probable**: they go by caption, and the
harness on page 7 was not traced.

- **V2.** IC101 QC (pin 12), the counter bit, is one net. It goes to:
  - pad **F6** `V2 (A)`;
  - the arrow `V2 (B)(M)`;
  - buffer IC20 5→6 (a triangle with no bubble, so non-inverting) to pad
    **D7** `V2 (I)`;
  - /VS gate IC102.13;
  - new gate IC96.4.

  On the original, IC102 QC goes to the same places (F6, the B/M arrow, gate
  "1" 11→10 to D7, and IC115.1), except IC96.
- On Pro sheet A, pad C6 `V2 (E)` branches at a dot to the arrow `V2 (N)` and
  to IC53.1 (crop A-v2). So sheet N's `V2 (A)` is E's V2 through board A with
  no gate. Sheet I's `V2 (E)` on pad HH is E's V2 through the non-inverting
  buffer. This agrees with `pro/reconstruction/LAMP_PROMS.md`, "The two V2s
  are the same signal".
- **V2′ (new on Pro).** IC96 is a plain AND body, no bubbles, with pins 5, 3,
  4 → 6, which fits a 7411 section. Its inputs are:
  - 96.5 = IC101 QA (**V0**);
  - 96.3 = IC101 QB (**V1**);
  - 96.4 = IC101 QC (**V2**).

  Each is a drawn dot on the counter's output risers (crop e-v2p).
  96.6 → buffer IC20 9→8 → pad **DP**, caption `V2' (I)`. A Japanese note
  points at DP: 端子番号指示なし 空き端子に接続のこと, "no terminal number
  given; connect to a free terminal". So **V2′ = V0 · V1 · V2**. It is high
  on one line in eight (V mod 8 = 7), with the same 8-line period as V2. Its
  falling edge comes at the same moment as V2's (7 → 0), and its rising edge
  three lines after V2's.
- **Consequence for the Pro traces.** `SHEET_I_TRACE.md` reads pad HU as V2
  "with a raised mark". The correction in `pro/reconstruction/LAMP_PROMS.md`
  (PR #77) already calls it V2′ and leaves its inputs untraced; this sheet E
  reading adds them. `SHEET_K_TRACE.md`
  (36.12) says the display is "lit only in the V2′-low half of each V2′
  period". With V2′ = V0·V1·V2, V2′ is low on seven lines of every eight, not
  half of them. The K trace's wiring is not affected; its wording should be
  read with that in mind. Neither trace was changed here.

## Differences, sheet E

| # | Item | Original (p32) | Pro (p16) | Confidence |
|---|---|---|---|---|
| E1 | V2′ | Not present | IC96 AND(V0, V1, V2) → IC20 9→8 → pad DP `V2' (I)`, with the "connect to a free terminal" note | clear |
| E2 | V5 to sheet N | V5: arrow (B) only | Also pad **FC** `V5 (N)`; the V5 (B) arrow is moved up beside it. Sheet N's trace has V5 arriving on pad CC from E, which fits the F→C pad convention | clear (the N letter is drawn sideways) |
| E3 | H7 arrow | `H7 (B)` | `H7 (B)(M)` | clear |
| E4 | 14MHz pad to H | Pad printed `CV` | Pad printed `FV` | clear as printed |
| E5 | H4 pad | Printed `F3` (read as F8, U3) | Printed `F8` clearly: settles the original's U3 | clear |
| E6 | /H6 pad to H | Printed `F2` | Printed `FZ`. The drafter's 2 and Z look alike, so this may be the same pad | uncertain |
| E7 | Divider CP node | 21.3 px dot where the Vcc rail meets the 14MHz row at CP (U1, taken as a slip) | The same crossing at about (2907, 2502) has **no dot**; J8 and K11 have dots. Supports the original's U1 reading as a drafting slip | clear |
| E8 | D-pad buffers | Gate "1", marks beside it unread (U4) | Designator `20`, with `17` written beside the buffer sections (read 7417, open collector) | probable (the type is a mark, not a printed part number) |
| E9 | C19 on /HS | `1000P` beside a struck-out value (U5) | C22 `1000P`, clean | clear |
| E10 | V-CA capacitor | 470P, unnumbered | C19 470P | clear |
| E11 | /V8 inverter for FN | IC114 1→2 | 1→2, designator unread (looks like `99`) | uncertain (designator only) |

Everything else on sheet E matches: the oscillator (R17, R16 330; C32 0.1µ;
C31 100p), the 7MHz outputs (pad F13 (F)(G)(H), the (M) arrow, the (B)(C)
arrow from the divider /Q), H0–H3 (B)(M), H4 (B)(M) and pad F8, H5 (B)(M)
and pad F7 with the D8 buffer, /H5 (B), H6 pad FH and the (B)(M) arrow, H8
(B)(M) and pad FF, /H8 pad FB and the (B)(M) arrow, /HS pad FJ, V0 (M), V1,
V3, V4 (B)(M) and pad E21, /V4 (B)(M), /V5 pad EY, V6 (B)(M) and pads E12,
E22, V7 (D)(B)(M) and pads EN, EZ, /V7 (M), `/V-CA×V8` (B) and pad FS (H)
(IC103 10,9→8, NAND), V-CA (M), /V8 (B)(D) and pad FN (H), V8 (M), /VS
pad F12 (H), 14MHz pad D6 (I) with 470Ω pull-up, and V2 pad D7 (I). The V1
arrow's lower letter is the same glyph on both boards and is read as (B).

### IC cross-reference, sheet E

| Function | Original | Pro |
|---|---|---|
| Oscillator inverters, 14MHz buffer | IC117 9→8, 11→10, 13→12 | IC122 11→10, 9→8, 5→6 |
| 7MHz inverter (2nd 7MHz) | IC117 5→6 | IC122 13→12 |
| ÷2 (J8 CP9 K11 CL10 Q5 /Q6) | IC109 2nd half | IC116 |
| H0–H3, H4–H7 | IC108, IC107 | IC108, IC115 |
| H8 / blank flip-flops | IC116 halves | IC109 halves |
| H load, /HS, /VS (7410) | IC115 11,9,10→8; 3,4,5→6; 13,1,2→12 | IC102 10,9,11→8; 3,4,5→6; 1,13,2→12 |
| /HS buffer | IC95 1,2→3 | IC110 4,5→6 |
| /H5, /H6 | IC114 11→10, 9→8 | IC12 1→2, 3→4 |
| D-pad buffers | gate "1" 9→8, 13→12, 11→10 | IC20 1→2, 3→4, 5→6 (+ 9→8 for DP) |
| /SYNCRO XOR | IC28 9,10→8 | IC113 5,4→6 |
| V0–V3, V4–V7 | IC102, IC100 | IC101, IC94 |
| V8 flip-flop | IC109 1st half | IC116 (J1 CP12 K4 CL13 Q3 /Q2) |
| /V4../V7, V-CA→load | IC93 1→2, 3→4, 5→6, 9→8, 13→12 | IC87 3→4, 11→10, 5→6, 9→8, 1→2 |
| /V3; V8 (M); /V8 (FN) | IC114 13→12, 3→4, 1→2 | IC42 9→8, IC87 13→12, unread 1→2 |
| /(V-CA × V8) | IC110 1,2→3 | IC103 10,9→8 |
| Blanking NORs | IC101 9,10,12,13→8; 1,2,4,5→6 | IC95 the same pins (1 = GND, 2 = V8 on Pro; 1 = V8, 2 = GND on the original) |
| V2′ AND | none | IC96 3,4,5→6 |

## Differences, sheet B

| # | Item | Original (p29) | Pro (p13) | Confidence |
|---|---|---|---|---|
| B1 | Message qualifier X | IC72 NAND(/EX.SIGNAL F1, /COIN IN E1) on B | No IC72. Pad F1 `EX.SIGNAL (A)`, no overbar, straight to IC77. On A, IC35 12,13→11 NAND drives pad C1: 13 = IC60 /Q, 12 not traced | clear as drawn; the meaning of A's 35.12 is open |
| B2 | /COIN IN pad | ED → PROM A8, forwarded (M)(D); E1 → IC72 | E1 → PROM A8, forwarded (M); also IC72 /CLR and D (B5) | clear |
| B3 | PROM number | `PR-133`, `µPB-425D` | `PR-` + illegible, `µPB-425D` | the number is unread |
| B4 | TXT capacitor | none | C18 `470P  1000P ※ ADJ.` from IC79.6 to GND | clear |
| B5 | Display timer (new) | none | IC72, two 7474 halves, both /CLR (1, 13) on /COIN IN. 72a: CK 3 = `Vs/512 (H)` pad **E8**; D 2 looped to the output numbered **5**; 5 → 72b CK 11. 72b: D 12 = /COIN IN; output **8** (/Q) → `/DISPLAY (D)`, IC70.1, IC70.11 and IC29.1 | wiring clear. **U-B1:** 72a's D is drawn to pin 5 (Q in the 7474 pinout); a divider would need /Q (6). Not corrected |
| B6 | Demo selector (new) | none | 157 IC70, select 1 = /DISPLAY, /G 15 = GND. Ch1 A2 = `D-TIME (D)`, B3 = `EXTEND (A)` pad **EB** → 4 `D-EXTEND (D)(M)`. Ch2 A5 = NOT D-TIME (IC57 9→8), B6 = `/EXTEND (A)` pad **E3** → 7 `/D-EXTEND (M)(C)`. Ch3 A11 = /DISPLAY, B10 = /GAME (pad E6) → 9 `/D-GAME (D)`, so /D-GAME = /DISPLAY AND /GAME | clear (the pad letter EB reads B or 8: probable) |
| B7 | MH speed source | SP.A–D pads go straight to IC111 and to IC110 NAND(SP.C, SP.D) | New 157 IC29, select 1 = /DISPLAY, /G 15 = GND. B inputs 3, 6, 10, 13 = SP.A–D (pads F16, F7, F17, FU). A inputs 2, 5, 11 = GND, 14 = `SLOW (D)`. Outputs 4, 7, 9, 12 → IC22 (load mux) 2, 5, 11, 14, and 9, 12 → IC30 NAND 13, 12 → 11. So with /DISPLAY low, the speed word is {SLOW, 0, 0, 0} (SP.D slot = SLOW) | clear |
| B8 | V-④ arrow | `Ⓜ Ⓓ` | `Ⓜ Ⓓ Ⓒ` | clear |
| B9 | /M1V latch half | IC69 2nd half (PR 10, CL 13, Q 9, /Q 8) | IC53 1st half (PR 4, CL 1, Q 5, /Q 6); M2V uses IC58 2nd half (the original's IC69 1st half) | clear; the function is the same |
| B10 | UG1 (unnumbered OR, original U12) | no designator | `88` 9,10→8 (OR: AND body, all bubbles) | clear |
| B11 | MH8 flip-flop | IC57, no pin numbers | IC4, J1 CK12 K4 CL13 Q3 (first half of a 74107) | clear |
| B12 | MH load gate | IC55: 11, 10, and a third input read `1` (U3) | IC81: 11, 10, and the same doubtful glyph (`·1`/9) | uncertain, as on the original |

Unchanged in function (same nets, new IC numbers): the PROM and 151 text
path; T_H, T_MSG (apart from X), T_COIN and the strobe; the 7442 decoder
and the 279 latch; the MH counters IC16/IC10 (original IC118/IC103), clocked
by `7M (E)`, with load mux IC22 (original IC111; 3 and 6 GND, 10 and 13
Vcc; select `/(V-CA × V8) (E)` with C9 220p) and C2/C3 470p (original
unnumbered and C15); the VSEL chain IC50 1,2→3 AND (TUNNEL & BRIDGE, IC30.11),
IC43 NAND (Vs/2, Vs/4, IC50.3), IC50 12,13→11 AND (/INI RESET pad EA, IC43.12);
the M1V and M2V counter pairs IC52/IC59 and IC66/IC73 (original IC85/IC76,
IC91/IC77) on /HS with ENT on /V8, their load muxes IC51 and IC65 (original
IC83, IC84), the carry inverters IC57 5→6 and 11→10 with C14 and C17 470p,
the 7427 NOR IC64 (original IC61) and the inverters IC57 (original IC62).

**What the new sheet B logic does (wiring-derived, not tested).** /DISPLAY
is a state held by IC72. A coin (/COIN IN low) clears it, and Vs/512 sets it
after two edges if 72a toggles (U-B1). While /DISPLAY is low:

- the road's MH speed word becomes SLOW on its top bit;
- the EXTEND lines to D, M and C are replaced by D-TIME and its inverse;
- /D-GAME is held low.

This looks like an attract-mode demonstration that drives the road without a
player. That is a description of the gates, not a confirmed behaviour:
sheet D, where D-TIME, SLOW and /DISPLAY meet, was not compared.

## Evidence

Renders: PyMuPDF at `Matrix(1, 1)`, upright.
- Pro page 13: 10167 × 6617.
- Pro page 16: 10167 × 6617.
- Pro page 8: 10184 × 6617.
- PDF SHA-256: `9473d6dd84418129f389e7c5becc0f6f7d105611e1d508ff60bbc062a27432f2`.

Original boxes: on page 29 as stored; on page 32 in frame R (rotated 180°),
as in `SHEET_E_TRACE.md`. Boxes are (left, top, right, bottom). Crops are not
in the repository.

| Crop | Page | Box | Shows |
|---|---|---|---|
| e-osc | 16 | (2000, 950, 3700, 3300) | Oscillator, IC122, IC116 divider, 14MHz/7MHz pads, FV, D6 |
| e-cp | 16 | (2700, 2350, 3100, 2700) | Divider CP row crossing the Vcc rail without a dot |
| e-h | 16 | (3600, 950, 6000, 3100) | IC108, IC115, H pads and arrows, IC12, D8 buffer |
| e-hcap | 16 | (4600, 950, 6000, 1500) | H captions: F8, F7, FH, FZ, H7 (B)(M) |
| e-h8 | 16 | (5300, 2250, 8000, 3300); (6000, 950, 8600, 3200) | IC109 halves, IC102 load and /HS, C22, IC110, FJ |
| e-load | 16 | (3400, 2550, 7700, 3250) | Blank and /blank rows to IC108.6, IC115.3/4, IC109 J/K |
| e-v03 | 16 | (2900, 3200, 5200, 5400) | IC101, V0–V3, F6, D7, IC42, IC96, DP |
| e-v2p | 16 | (2950, 3450, 3250, 4250); (3000, 4050, 4700, 4700) | IC96 body and pins; its three taps on IC101 QA, QB, QC |
| e-v47 | 16 | (4950, 3250, 5900, 4200) | V4–V7 pads, FC (N), EY, E12, E22, EN, EZ, IC87 |
| e-vs | 16 | (4200, 3800, 7200, 4500); (6500, 4250, 7150, 4480) | /VS gate IC102 1, 13, 2 and their rows |
| e-vcnt | 16 | (3400, 4350, 7000, 5650) | IC101, IC94, IC116, IC87 1→2, C19, C21, IC95 NOR |
| e-fn | 16 | (6350, 3350, 6850, 4200) | /V8 pad FN inverter, V8 (M) inverter |
| e-out | 16 | (6700, 3000, 9800, 5800) | IC113 /SYNCRO, F12, C24, IC95 /TV-BLANKING |
| b-prom | 13 | (2000, 600, 3600, 1500); (2550, 520, 3400, 760) | IC80 address and data pins, PR number, IC79 |
| b-text | 13 | (700, 950, 2700, 2200); (1550, 1450, 2250, 1850) | E1, F1, E19, IC77, IC81, IC24 |
| b-ex | 13 | (680, 1690, 1260, 1800) | `EX.SIGNAL` caption without overbar |
| b-out | 13 | (1700, 1150, 3600, 2200); (3050, 1250, 3500, 1450); (3150, 1820, 3500, 2120) | C18, IC78 sections |
| b-disp | 13 | (750, 2050, 3300, 3600); (1300, 2300, 2000, 2780); (1550, 2850, 2200, 3350) | IC72, IC70, E8, EB, E3, E6, D-TIME |
| b-dout | 13 | (2700, 2550, 3300, 3300) | /DISPLAY, D-EXTEND, /D-EXTEND, /D-GAME captions |
| b-mh | 13 | (4900, 1400, 7300, 2450); (5100, 720, 7100, 1150) | IC16, IC10, IC4, IC81 load, C2, C3, MH captions |
| b-sp | 13 | (3800, 2050, 6000, 3150) | IC29, IC22, IC30, C9, SLOW |
| b-42 | 13 | (2000, 4700, 4300, 6200) | IC71 7442, IC91 279, C20 |
| b-arr | 13 | (3550, 4250, 4200, 4800) | V-① to V-⑤ captions |
| b-vsel | 13 | (4100, 3500, 5300, 5400) | IC50, IC43, IC50 |
| b-road | 13 | (4900, 4300, 7600, 5500); (4700, 5350, 6300, 6100); (6500, 5350, 8300, 6100) | M1V/M2V counters, IC51, IC65, IC53, IC58, IC64, IC88, IC57 |
| A-v2 | 8 | (8300, 650, 9000, 1500) | Pad C6 V2 (E), branch to V2 (N), IC53.1 |
| A-ex | 8 | (7650, 1150, 9500, 2300) | IC60 74123, IC35 12,13→11, pad C1 EX.SIGNAL (B) |
| o-v03 | 32 R | (3100, 3450, 3900, 4000) | Original V0–V3 captions, D7 |
| o-v47 | 32 R | (4150, 3450, 5500, 4250) | Original V4–V7 pads (no V5 pad) |
| o-hcap | 32 R | (4100, 1000, 5600, 1800) | Original H captions, H7 (B) |
| o-text | 29 | (950, 1000, 2900, 2300) | Original IC72, ED, E1, E6, IC71, IC55, IC52 |
| o-arr | 29 | (3750, 4350, 4400, 4900) | Original V-① to V-⑤ captions |
| o-mh | 29 | (5300, 750, 7300, 1250) | Original MH captions |

## Uncertain

| ID | What | What would settle it |
|---|---|---|
| U-B1 | IC72a D (pin 2) is drawn to the output numbered 5 (Q). A toggle needs /Q (6). As drawn, 72a never changes after a clear, and /DISPLAY would never fall | A sharper scan, or the board |
| U-B2 | Sheet A IC35 pin 12, the second input of the EX.SIGNAL gate | A trace of Pro sheet A's IC35 row |
| U-B3 | The Pro PROM's PR number (illegible), so whether its contents equal PR-133 | The parts list (pages 4–5), or the chip |
| U-B4 | IC78 4,5→6 and 9,10→8 input bubbles are faint; OR is read from the package's clear 1,2→3 section | A sharper scan |
| U-B5 | IC81's third MH-load input numeral (`·1` or 9), as on the original (U3) | The board |
| U-E1 | /H6 pad `FZ` or `F2`; FN inverter designator | A sharper scan |
| U-E2 | Pad pairings F6–C6, D7–HH, DP–HU, FC–CC go by caption only | The harness on page 7 |

## Not checked

- Pin by pin: the road counters IC52, IC59, IC66 and IC73, the muxes IC51 and
  IC65, and the feedback gates IC64, IC88, IC57 and IC53/IC58. They were
  compared by section and their changed latch halves read. Each input of the
  7427 sections was not re-followed.
- Pro sheet D: where /DISPLAY, D-TIME, SLOW, D-EXTEND and /D-GAME go, and
  what the demonstration mode does.
- Pro sheet A beyond IC35, IC60 and pad C6.
- The cabinet harness (page 7) for the pad pairings.
- C18's value as fitted, and its effect on the text edges.
- Pro sheet I and sheet K were not changed. The V2′ consequence is noted
  above for whoever revisits them.
