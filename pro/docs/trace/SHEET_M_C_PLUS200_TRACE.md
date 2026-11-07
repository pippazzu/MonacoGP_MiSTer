# +200 graphic trace: PR-54 on sheet M, colour on sheet C (Pro Monaco GP)

Date: 2026-11-05. Issue #39. Bounded pin-level trace of the +200 graphic
path. It starts at PR-54 (IC130) and its multiplexer IC129 on Pro sheet M
and ends at the RGB output on Pro sheet C. One decoder on Pro sheet B is
also traced, because it supplies the vertical window.

**Main results**

1. **PR-54 address is V0..V4 in straight order:** pin 10 (A0) = V0 through
   pin 14 (A4) = V4. This **corrects** `pro/reconstruction/PR54_MAPPING.md`,
   which read the order bit-reversed.
2. **The enable-polarity inconsistency comes from a missed inverter.**
   IC124 pin 11 is not V-④ itself. It is V-④ after inverter IC79
   (13→12). The window therefore opens on the lines V-④ selects
   (V7..V5 = 100), as it should.
3. **Window:** the graphic shows only while BONUS CP is high, in the
   16-clock H window where H4..H7 = 0 and on the 32 lines where
   V7..V5 = 100. Nothing depends on a car or score position.
4. **Colour:** pure red at full brightness. It overrides whatever is
   underneath; the colours do not mix.

## Sources and method

- Pro: `pro/schematics/promonacogp420-0525_1.pdf`, SHA-256
  `9473d6dd84418129f389e7c5becc0f6f7d105611e1d508ff60bbc062a27432f2`.
  Pages were rendered with PyMuPDF at `Matrix(1, 1)`, upright. The
  embedded scans are this size, so scale 1 is the native resolution.
  - Page 17, sheet M: 10159 × 6617.
  - Page 14, sheet C: 10200 × 6617.
  - Page 13, sheet B: 10167 × 6617, used for the V-④ decoder only.

  Every box below is (left, top, right, bottom) on the render of its
  page. Crop names are local identifiers. The crops are not in the
  repository.
- Long wires were followed in two ways. A column or row walker on the
  grey image (threshold 200 and 245) checked continuity and listed every
  place where a wire widens. Each such place was then examined by eye at
  2–4×.
  - A drawn dot on this scan measures about 28–35 px. Plain crossings
    widen the wire to about 15–22 px.
  - Only dots count as junctions. Where a reading rests on a T or on a
    scan gap, the table says so.
- Original-board material, for comparison only: `docs/trace/SHEET_M_TRACE.md`
  (V-bus risers to PR-138 and to the bridge XORs),
  `docs/trace/SHEET_C_TRACE.md`, `docs/SHEET_C_LOGIC.md`,
  `docs/SHEET_B_LOGIC.md` (text windows, screen rotation) and
  `docs/TIMING.md` (H/V counter ranges).
- Aldo's `PR54_MAPPING.md` was read for its questions only. Every reading
  in it was rechecked on the scan, and two of them are corrected here (see
  "Corrections to PR54_MAPPING.md").
- Confidence: **clear** means read directly with no competing reading.
  **Probable** means one reading fits much better, but the scan is not
  clean. **Uncertain** means the scan does not settle it.
- No MAME, emulator, other core, fan remake, footage or gameplay
  description was used. No PROM bytes are produced.

### Datasheets used (checks on pin numbers, not replacements for readings)

| Part | Source | What was checked |
|---|---|---|
| 6331 (MMI 53/6331-1, 32×8) | MMI *Bipolar LSI Databook*, 2nd ed., 1980, p. 3-5 "Pin Configurations" and p. 3-2 cross-reference, https://bitsavers.mirrorservice.org/components/mmi/_dataBooks/1980_MMI_Bipolar_LSI_Databook_2ed.pdf | O1–O7 = pins 1–7, GND 8, O8 = 9, A0–A4 = pins 10–14, /E1 = 15, Vcc 16. The cross-reference lists 6330-1 as three-state and **6331-1 as open-collector**. The family text says intact fuses store a logical high and programming takes a bit low |
| 74151 | TI SDLS054, https://www.ti.com/lit/ds/symlink/sn74ls151.pdf | D0..D7 = 4, 3, 2, 1, 15, 14, 13, 12. A, B, C = 11, 10, 9. /G = 7, Y = 5, W = 6. "A high level at the strobe forces the W output high" |
| 7442 | TI SDLS109, https://www.ti.com/lit/ds/symlink/sn74ls42.pdf | A, B, C, D = 15, 14, 13, 12. Outputs 0..9 = pins 1–7, 9–11, so output 4 is pin 5 |
| 74147 | onsemi SN74LS147/D, https://ece-classes.usc.edu/ee459/library/datasheets/SN74LS147-D.PDF | Inputs 1–9 = pins 11, 12, 13, 1, 2, 3, 4, 5, 10. Outputs A, B, C, D = 9, 7, 6, 14. From the function table, input 9 low gives D C B A = L H H L |
| 7425 | TI SDLS082, https://www.ti.com/lit/ds/symlink/sn7425.pdf | Second section: 2A, 2B, 2C, 2D = 9, 10, 12, 13. Strobe 2G = 11, output 2Y = 8. Y = /(G·(A+B+C+D)) |
| 7410, 7430, 7402, 7404, 7416, 7417 | TI sn74ls10, sn74ls30, sn74ls02, sn7404, sn7416, sn7417 (ti.com/lit/ds/symlink/…) | 7410 third section 9, 10, 11 → 8. 7430 inputs 1–6, 11, 12 → 8. 7402 11, 12 → 13. 7404 13 → 12 and 11 → 10. 7416 1 → 2, 3 → 4, 5 → 6. 7417 pinout as 7407 (Y = A) |

No drawn pin number disagrees with these pinouts. Two parts carry no
printed type, IC128 and the inverter IC79. They are discussed in their
own tables.

### Crops

Sheet M (page 17):

| Crop | Box | Contents |
|---|---|---|
| m-overview | (5500, 3400, 8500, 4600) | PR-54, IC129, IC124, IC128, pad FE, /+200 arrow |
| m-prom | (7450, 3600, 8000, 4100) | IC130 body, type, pin 15, output pins |
| m-mux | (7450, 4000, 8000, 4300) | IC129 data pins, pin 7, pin 6 |
| m-cross | (7450, 3960, 7900, 4030) | Enable row crossing the eight data wires |
| m-out | (7650, 4250, 8450, 4450) | `/+200 (R) Ⓒ` arrow |
| m-gates | (5650, 3700, 7250, 4150) | BONUS CP pad FE, IC128, IC124 |
| m-hlab | (5550, 3820, 6250, 4260) | Labels H4..H7 and H1..H3, IC128 pins |
| m-selpins | (7300, 4060, 7560, 4260) | IC129 pins 11, 10, 9 |
| m-trunk | (6280, 3740, 6440, 4250) | Trunks x≈6331 and x≈6383 crossing the BONUS CP, 128.8 and H1..H3 rows |
| m-addr | (6900, 3620, 7560, 3900) | PR-54 pins 10..14 and the five risers |
| m-turn | (6700, 2550, 7500, 2900) | Where the five address rows turn down |
| m-dots | (5800, 2550, 6150, 2850) | Junction dots of the address rows (bridge risers) |
| m-lbtop | (2800, 2560, 3150, 2850) | Where the V-bus risers join the address rows |
| m-lbbot | (2750, 3860, 3250, 4260) | Where the risers tap the V0..V4 rows next to PR-139 |
| m-band | (2880, 3860, 3060, 4120) | Same area, thresholded at 235, ×3 |
| m-band2 | (2700, 3850, 3200, 4750) | V/H bus below the taps, start of the H6 vertical |
| m-vbus | (600, 3850, 1500, 4500) | Bus labels `Ⓔ V0..V4, H1..H6, H8` |
| m-p11top | (6400, 1600, 7100, 1950) | Top of the IC124.11 riser, IC79 and its output dot |
| m-invz | (6500, 1680, 6700, 1840) | IC79 designator and pin numbers, ×3 |
| m-inv | (5500, 1450, 8200, 2300) | IC79 input and output rows in context |
| m-tr2 | (6200, 1750, 6600, 2350) | V-④ trunk x≈6383 near its top, dot at 106.3 |
| m-trbot | (5600, 4600, 6700, 5200) | Bottom of the V-④ trunk; DUMMY AREA trunk x≈6331 |
| m-v4 | (2550, 4550, 3150, 5150) | V-④ row turning down at x≈2720 to row y≈5050 |
| m-dot5050 | (2880, 4990, 2990, 5170) | The H6 vertical crossing rows y≈5050 and y≈5130, ×4 |
| m-h6low | (2600, 5000, 3400, 5900) | H6 vertical down to IC69 pin 9 |
| m-v4row | (1000, 4700, 2800, 4800) | V-④ row from its label to x≈2720 |
| m-ll | (500, 4250, 3600, 5300) | Lower-left labels `Ⓑ V-④` and `Ⓑ V-①`, IC53, IC96 |
| m-trunkx | Montage, x 6300–6470, at y 1890, 2020, 2090, 2310, 2620, 2990, 3100, 3230, 3330, 3750, 4015, 4100 and 5020 | Every widening along the V-④ trunk |

Sheet C (page 14):

| Crop | Box | Contents |
|---|---|---|
| c-red | (1500, 5300, 4100, 6200) | Red collector IC74 and its input labels |
| c-74 | (3150, 5350, 3900, 5900) | IC74 inputs, output 8, inverter IC2 13→12 |
| c-pins | (3430, 5280, 3580, 5720) | IC74 pin numerals, ×2.5 |
| c-lab | (3100, 5850, 3350, 6250) | Rotated `/+200 (R) Ⓜ` arrow |
| c-route | (2550, 5280, 3300, 6050) | Nested routes from the input labels to IC74 |
| c-out | (3800, 5300, 4300, 5600) | IC2.12 output and its dot |
| c-mid | (3900, 3500, 7300, 5600) | The two branches of the red line |
| c-r5500 | Widenings on row y≈5500, x 4130–6230 | Only the corner at x≈6213 |
| c-v4090 | Montage, x 4040–4140, y 3870–5276 | Every crossing on the upward branch |
| c-up4090 | (3800, 3700, 4200, 3900) | Upward branch turning left at y≈3860 |
| c-l3860 | (3200, 3600, 3900, 4000) | Branch entering the upward 7430 at pin 2 |
| c-rxlab | (3380, 3560, 3720, 3820) | That gate's designator ("43"?) and type "30" |
| c-g43, c-g43b | (3150, 3350, 3900, 3800), (3000, 2350, 4000, 2750) | Its output 8 up to IC47 pin 1 |
| c-47 | (2850, 2350, 3500, 2650) | IC67 and IC47 symbols |
| c-up2 | (2900, 1600, 4300, 2450) | IC47.3 up to row y≈1745 |
| c-e1top | (4050, 1650, 4500, 1900) | IC53 (7402) |
| c-row1766 | Montage, row y≈1766, x 4400–6774 | IC53.13 to IC2.11, every crossing |
| c-147 | (6800, 900, 8000, 1800) | 74147 (IC1) pins |
| c-9in | (6100, 1550, 7200, 1800) | Red line into 147 pin 10 |
| c-dot | (6130, 1720, 6280, 1820) | Red riser crossing the ROAD row at y≈1770, ×4 |
| c-x4240 | (6130, 4190, 6300, 4290) | Red riser crossing row y≈4240, ×4 |
| c-rgb | (6000, 900, 9100, 2900) | 7416 output inverters, 7417 pull-downs, RGB nodes |
| c-buf | (7400, 1700, 8200, 2200) | The four 7417 pull-downs and their nodes |

Sheet B (page 13):

| Crop | Box | Contents |
|---|---|---|
| b-42 | (2050, 4250, 4200, 6000) | IC71 "42" decoder and its output arrows |
| b-42z | (3100, 5420, 4200, 5880) | IC71 output pins and dots |
| b-arrows | (3550, 4300, 4150, 5700) | Outputs 1..5 rising to arrows ①..⑤ |
| b-top, b-mid | (2050, 650, 2900, 1150), (2250, 900, 2700, 1500) | `Ⓔ V1..V6, H3` bus and the V4, V5, V6 risers |
| b-ab | (2300, 5400, 2800, 5650) | Risers turning into IC71 A and B |

Notation: `nn.p` means IC nn, pin p. `/` transcribes an overbar.
Coordinates are approximate centre lines on the scale-1 render.

## Sheet M: PR-54 and IC129

### IC130: PR-54, printed `PR-54`, `6331`, `130`

| Pin | Function (MMI) | Connection read | Evidence | Confidence |
|---|---|---|---|---|
| 10 | A0 | **V0** (riser R0, see the address-route table) | m-addr; route | clear numeral. Route clear except the bus tap (clear for V0) |
| 11 | A1 | **V1** (R1) | m-addr; route | numeral clear; V1 identity probable |
| 12 | A2 | **V2** (R2) | m-addr; route | numeral probable (drawn like "1Z"); V2 identity probable |
| 13 | A3 | **V3** (R3) | m-addr; route | numeral probable (drawn like "17"); V3 identity clear |
| 14 | A4 | **V4** (R4) | m-addr; route | clear |
| 15 | /E1 | Bubble, ground symbol. Always enabled | m-prom | clear |
| 1, 2, 3, 4, 5, 6, 7, 9 | O1..O8 | Straight down to IC129 pins 4, 3, 2, 1, 15, 14, 13, 12 respectively | m-prom; m-mux | clear |
| 8, 16 | GND, Vcc | not drawn | m-prom | clear omission |

The eight data wires cross the horizontal IC124.8 → IC129.7 row at
y≈3995. All eight are plain crossings, slightly thickened, with no dot
(m-cross). No pull-up resistor is drawn on the eight data wires (m-prom,
m-mux), although the 6331-1 has open-collector outputs (MMI). With TTL
inputs this still works, because an undriven TTL input reads high.
Whether resistor packs not shown here exist on the board is not settled
by this sheet.

### IC129: printed `151`, `129`

| Pin | Function (TI) | Connection | Evidence | Confidence |
|---|---|---|---|---|
| 4, 3, 2, 1 | D0, D1, D2, D3 | PR-54 O1, O2, O3, O4 (pins 1, 2, 3, 4) | m-prom; m-mux | clear |
| 15, 14, 13, 12 | D4, D5, D6, D7 | PR-54 O5, O6, O7, O8 (pins 5, 6, 7, 9) | m-prom; m-mux | clear |
| 11 | A (select LSB) | **H1** | m-hlab; m-selpins; m-overview | clear (label "H₁" has a faint subscript) |
| 10 | B | **H2** | same | clear |
| 9 | C | **H3** | same | clear |
| 7 | /G strobe | IC124.8: row y≈3995 right to x≈7950, down to the bubbled pin 7 | m-overview; m-mux; m-cross | clear |
| 6 | W (complement) | Down, then right along y≈4380 to the arrow **`/+200 (R) Ⓒ`**. The bar over the label is clear | m-mux; m-out | clear |
| 5 | Y | not drawn | m-mux | clear omission |

The H1..H3 rows run from the `Ⓔ` bracket to IC129. They cross the
trunks x≈6331 and x≈6383 without dots (m-trunk; m-trunkx at y 4100). The
ink blob on the H1 row at about (5850, 4115) has no branch (m-hlab).

### Address route: from the V bus to PR-54 pins 10..14

The five wires run over three segments.

1. **Bus taps.** A riser leaves each bus row near PR-139, at x≈2850–3030.
2. **Long rows.** Each riser turns into a row at y≈2650–2820. The rows run
   right to x≈6950–7160. On the way, each row has a dot to a riser that
   goes up to the bridge XORs (IC114).
3. **Drops.** Each row turns down into PR-54 as nested L shapes: the top
   row turns furthest right and reaches the top pin.

| Riser | Bus tap (row, x) | Joins long row | Turns down at | PR-54 pin | Evidence | Confidence |
|---|---|---|---|---|---|---|
| R0 | **V0** (bus row y≈3912): dot at (3030, 3910). The riser runs x≈3025 continuously from above y 2400 to 3925 | y≈2650 (dot (3030, 2650)) | x≈7157 | **10** | m-lbbot; m-band; m-lbtop; m-turn; m-addr | clear |
| R1 | V1 (y≈3955), by elimination. Faint riser x≈2983 is continuous from the teardrop dot at (2980, 2695) down to y≈3866. Below that it enters a band, x≈2945–3000 by y 3920–4100, where the scan has lost most ink (rows V1..V4 are broken there too) | y≈2692 | x≈7120 | **11** | m-lbtop; m-band; m-band2 | probable |
| R2 | V2 (y≈3997). Riser x≈2940 is solid from above y 2400 to y≈3934, crosses the V0 row and leaves specks at y 3986–3990 that end on the V2 row. It does **not** continue below: the vertical at the same x below the bus starts at a corner on the H6 row, y≈4348 (m-band2) | y≈2735 (dot (2935, 2735)) | x≈7080 | **12** | m-lbtop; m-band; m-band2 | probable |
| R3 | **V3** (y≈4040): dot at (2895, 4040); the riser ends there | y≈2780 (dot (2895, 2780)) | x≈7040 | **13** | m-lbbot; m-lbtop | clear |
| R4 | **V4** (y≈4083): dot at (2853, 4080); the riser ends there | y≈2820 (corner (2850, 2820)) | x≈6990 | **14** | m-lbbot; m-lbtop | clear |

Supporting checks:

- **Bus labels.** The labels on m-vbus read V0, V1, V2, V3, V4, H1, H2, H3,
  H4, H5, H6, H8, top to bottom. The rows run straight from the labels to
  PR-139.
- **Rows stay in order.** The row walker found the five rows parallel and
  in the same order at every 300 px from x 3100 to x 6700. Over that
  stretch they move at most 6 px (2645–2651, 2690–2695, 2732–2737,
  2775–2780, 2820–2824).
- **Drops stay in order.** The five drops were sampled every 60 px from
  y 2860 to 3700 and stay in order (6983…7155 drifting to 6994…7164).
- **Other crossings.** All five rows cross the 124.11 riser at x≈6770 as
  plain crossings (m-turn).
- **Dots on the way.** The dots at (5905, 2645), (5950, 2690),
  (5990, 2732), (6030, 2775) and (6075, 2820) only add loads: risers up to
  the bridge XOR gates (m-dots, m-up).
- **Comparison with the original.** On the original sheet M the same V0..V3
  risers sit side by side with V0 rightmost, and V4 is separate
  (`docs/trace/SHEET_M_TRACE.md`, PR-138 and PR-139 tables). The Pro
  layout is the same: R0 is rightmost and R4 leftmost. This matches by
  function; it is not proof.

**What would settle R1 and R2.** R0, R3 and R4 are clear, so R1 and R2
carry V1 and V2 in one order or the other. Only these two are open. A
swap would exchange address bits A1 and A2. The bus ends at PR-139 and at
the bridge XORs, so either of these settles it:

- a cleaner scan of the box (2880, 3860, 3060, 4120);
- a continuity check on the board from PR-54 pins 11 and 12 to PR-139
  pins 7 and 6.

### Enable gating

| Part / pins | Reading | Evidence | Confidence |
|---|---|---|---|
| IC124, printed `124` | AND body, plain inputs, output bubble: a 3-input NAND. Pins 11, 10, 9 → 8 (third 7410 section) | m-gates; m-overview | clear |
| 124.10 | **BONUS CP**: pad `FE`, label `Ⓝ BONUS CP` (no bar). The row y≈3780 runs right to x≈6650, down to y≈4000, then into pin 10. It crosses trunks x≈6331 and x≈6383 without dots | m-gates; m-trunk; m-trunkx at y 3750 | clear |
| 124.9 | **IC128.8**: right to x≈5945, down to y≈4040, right to pin 9. Crosses the two trunks without dots | m-gates; m-trunk; m-trunkx at y 4015 | clear |
| 124.11 | **IC79.12**. The riser x≈6770 runs up without a break to the dot at (6768, 1770) on IC79's output row. It crosses the five address rows and others without dots | m-p11top; m-turn | clear |
| IC128, printed `128` only | AND body; all four inputs bubbled; no output bubble. So a 4-input **NOR**: 128.8 = 1 only when H4 = H5 = H6 = H7 = 0. Pins 13 = H4, 9 = H5, 10 = H6, 12 = H7 → 8 | m-hlab; m-gates | clear (connections and symbol) |
| IC128 type | Not printed. The pin set 9, 10, 12, 13 → 8 is the second section of a 7425 (TI). Its strobe 2G (pin 11) **is not drawn**; an open TTL input reads high, which enables the gate. A 7420 or 7421 has the same pins but would need a different symbol | m-hlab | type uncertain; settle by the parts list (pp. 4–5) or the board |
| IC79, printed `79` | Triangle with output bubble: an inverter. Input pin 13, output pin 12 (sixth 7404 section). Designator probable ("79" with a stroke over the 7); output numeral "12" is faint | m-invz; m-p11top | function clear; numerals probable |
| 79.13 | Row y≈1770 left to x≈6383, then down the long trunk x≈6383 (see V-④ route) | m-p11top; m-tr2 | clear |
| 79.12, other load | Row y≈1770 continues right past the dot to x≈8030 and down toward the strobe (pin 15) of the bridge `157 73`. Seen at overview scale only | m-inv | probable; not needed for +200 |

### V-④ route on sheet M (into IC79.13)

| Segment | Reading | Evidence | Confidence |
|---|---|---|---|
| Label | `Ⓑ V-④`, left margin, row y≈4740. Dot at (1175, 4745) to IC53 pin 2 | m-ll; m-v4row | clear |
| Row | Straight right to x≈2720, then down (corner) to y≈5050, then right | m-v4row; m-v4 | clear |
| Crossing at (2943, 5050) | The H6 vertical (it starts at a corner on the H6 bus row, y≈4348) ends on this row. Below the row it continues as a faint dashed line to IC69 pin 9, crossing the /DUMMY AREA row y≈5130 on the way. It is read as a **crossing**. Read as a joint, it would short H6 to V-④ and to /DUMMY AREA. It would also make IC69 = AND(/DUMMY AREA, NOT /DUMMY AREA) | m-dot5050; m-h6low; m-band2 | probable (scan gap between y 5061 and 5128) |
| Row y≈5050 | Right to x≈6376. Crosses the /DUMMY AREA trunk x≈6331 without a dot; that trunk ends on a dot at y≈5135 on the /DUMMY AREA row | m-trbot | clear |
| Trunk x≈6383 | Up from y≈5054 to y≈1768. It is continuous at threshold 245, with one 6 px dropout at y≈1997–2002 at threshold 200. Its only junction is the dot at (6380, 2110) to the upper gate (pins 3, 1, 5 → 6) left of IC85, which looks like IC106. Every other widening is a crossing at about line width (montage m-trunkx), including the five address rows and the BONUS CP, 128.8 and H1..H3 rows | m-tr2; m-trunkx; m-trunk | clear |
| Top | Corner at (6383, 1770) into IC79.13 | m-p11top | clear |

This route agrees with the note in `PR54_MAPPING.md` that the wire is
distinct from the parallel DUMMY AREA net. That note missed two things.
The V-④ wire ends at **IC79's input**, not at IC124. The 124.11 riser
rises to **IC79's output**.

## Sheet B: where V-④ comes from (page 13)

| Part / pins | Reading | Evidence | Confidence |
|---|---|---|---|
| IC71, printed `42`, `71` | Outputs drawn with bubbles, labelled 1..7 inside, pins 2, 3, 4, 5, 6, 7, 9 outside. This is the 7442 pinout (TI) | b-42z | clear |
| 71.15 (A) | Riser x≈2500, from the dot on the `V5` row of the `Ⓔ V1..V6, H3` bus (b-mid, dot about (2500, 925)), down to a corner into A | b-mid; b-ab | clear. The riser was sampled every 300 px from y 1000 to 5500 |
| 71.14 (B) | Riser x≈2460, from the dot on the `V6` row (about (2460, 967)), down to a corner into B | b-mid; b-ab | clear |
| 71.13 (C) | `Ⓔ V7` label straight into C | b-42 | clear (label "V₇" written small) |
| 71.12 (D) | Ground symbol | b-42 | clear |
| 71.5 (output 4) | Row y≈5640 right to x≈3920, up to the arrow `④`, captioned `Ⓜ Ⓓ Ⓒ` | b-42z; b-arrows | clear |

The V4 riser (x≈2546) crosses the A and B rows without dots (b-ab).

**Result.** V-④ is low only when V7, V6, V5 = 1, 0, 0, where V5 is the
LSB A and D = 0. Sheet B (96823-P D-1/5) and sheet M (D-5/5) are on the
same board, so V-④ is a board trace with no pad.

## Enable logic, as wired

```
IC129 /G (pin 7) = 124.8 = NOT( 124.9 AND 124.10 AND 124.11 )
  124.9  = 128.8 = NOT(H4 OR H5 OR H6 OR H7)
  124.10 = BONUS CP   (sheet N: IC107 pin 13, Q of a 74123; SHEET_N_TRACE W20)
  124.11 = 79.12 = NOT(V-④) = (V7 AND NOT V6 AND NOT V5)
/+200  = IC129 W (pin 6) = NOT( PR-54[V4..V0] bit O(k+1) ) when /G is low,
         where k = 4*H3 + 2*H2 + H1;  /+200 = 1 when /G is high
```

- **Polarity.** Inside the window, a 1 in the selected PROM bit drives
  /+200 low (active). Outside the window, /+200 is high (TI: strobe high
  forces W high).
- **Blank PROM.** On the MMI part an intact fuse reads high. An
  unprogrammed 6331 would therefore light the whole window.

## The window on the raster

This section uses the original board's sheet E counter ranges
(`docs/TIMING.md`). **Pro sheet E (page 16) was not traced for this
issue.** `BOARD_DIFFERENCES.md` reports only that its counter
architecture is broadly retained.

- **H.** H counts 0x098–0x1FF in the visible pass and 0x1A0–0x1FF in the
  blanking pass. H4..H7 = 0 occurs only at **H = 0x100–0x10F**, once per
  line, in the visible part: display positions 104–119 of 0..359. In the
  blanking pass H7 = H5 = 1, so the window cannot open there.
- **V.** V7..V5 = 100 with V8 = 0 gives **V = 0x080–0x09F**: 32 lines,
  inside the active V range 0x010–0x0FF. With V8 = 1 (V = 0x1F0–0x1FF)
  the decoder sees 111, so V-④ does not fire.
- **Size.** The graphic is a fixed window of 32 lines × 16 H clocks. No car
  position, score, or other moving counter enters the address, select or
  enable. It appears only while BONUS CP is high. The pulse length is set
  by R24/C41 on sheet N and is not computed here.

### PR-54 address and bit to raster and screen

| Quantity | Wiring | Confidence |
|---|---|---|
| PROM address a (A4..A0) | a = V & 0x1F = V − 0x080; one address per raster line. A0 = V0 … A4 = V4 | clear for A0, A3, A4; A1/A2 order probable (R1/R2) |
| Selected bit | k = (H − 0x100) >> 1 = 4·H3 + 2·H2 + H1. H0 is unused, so each bit lasts **two** H clocks | clear |
| Bit k to PROM pin | k = 0..7 ↔ O1..O8 (pins 1, 2, 3, 4, 5, 6, 7, 9) | clear |
| Lit pixel | Selected bit = 1 (high) → /+200 low | clear |

**Screen orientation.** `docs/SHEET_B_LOGIC.md` puts the picture upright
when the raster is turned 90° clockwise: H grows downward and V grows to
the left. The same convention is used here; it was not re-derived for
Pro. On the upright screen the +200 window is then **32 columns wide and
8 double-height rows tall**:

- **Column.** Screen column = 31 − a, counted from the left of the window.
  Address 31 (V 0x09F) is the leftmost column and address 0 (V 0x080) the
  rightmost.
- **Row.** Screen rows 2k and 2k + 1, counted from the top of the
  16-row window. O1 (k = 0) is the top pair and O8 (k = 7) the bottom pair.

So **one PROM word is one screen column**. Within a word, O1 is the top
of the column and O8 the bottom.

**Bit significance.** The schematic names pins only (O1..O8). It does not
say whether a programmer reads O1 as data bit 0 or bit 7. That convention
has to be fixed when the bytes are written, and stated with them.

## Sheet C: colour

### +200 into the red collector

| Element | Reading | Evidence | Confidence |
|---|---|---|---|
| Arrow | Rotated label read bottom to top: `Ⓜ`, `+200`, a parenthesised letter, and a bar alongside, i.e. `/+200 (R)` from M. The arrow points up into the sheet. The letter is blurred; sheet M's `(R)` is clear | c-lab; m-out | label probable on C, clear on M |
| Route | Up x≈3245 from the arrow, a 25 px dropout at y≈5663–5688, corner at (3240, 5652), then right into an IC74 input. Nothing else crosses the dropout | c-74; c-lab | probable (dropout) |
| IC74, printed `74`, `30` | OR body with every input bubbled = 8-input NAND (7430). Inputs, top to bottom: 1, 11, 2, 4, (3 or 5), 6, (5 or 3), 12. Output 8 | c-74; c-pins | symbol clear |
| Input carrying /+200 | Seventh from the top (y≈5652). Its numeral is overwritten and reads "5" or "3"; the input at y≈5550 has the other. **Not pin 6**: pin 6 (y≈5600) is /EXPLO (R). All 7430 inputs are equivalent, so this does not change the logic | c-pins; c-route | connection clear; numeral uncertain |
| Other IC74 inputs (route only, for context) | 1 = IC75.6; 11 = /PLAYER BODY (pad E7, Ⓖ); 2 = EX & GAME OVER (Ⓑ); 4 = /DUMMY (R) (Ⓜ); y≈5550 = /RESCUE (R) (Ⓜ); 6 = /EXPLO (R) (pad EK, Ⓖ); 12 = test point `T.P` | c-route; c-red | routes clear; labels as drawn |
| IC2 13 → 12 | Inverter. 74.8 → 2.13; 2.12 is the red-plane line, active low | c-74; c-out | clear |
| 2.12 → | Dot at (4090, 5500). Two branches: (a) and (b) below | c-out | clear |
| (a) | Row y≈5500 right to x≈6213 (no other widening), up x≈6215 to y≈1680, left into **IC1 (`147`) pin 10, input 9**. It crosses the ROAD row y≈1770 with a small jog, not a dot (c-dot), and row y≈4240 as a crossing (c-x4240) | c-mid; c-r5500; c-9in; c-dot; c-x4240 | clear (y≈1770 probable, but a joint there would short ROAD to red) |
| (b) | Up x≈4090. Every crossing up to y≈3870 is plain (c-v4090). It turns left along y≈3860, crossing x≈4000 and 3870, and rises at x≈3575 into **pin 2** of an upward-pointing 8-input NAND (bubbled inputs, printed `30`; designator reads like "43") | c-up4090; c-l3860; c-rxlab | route clear; designator uncertain |

### Priority and output

| Element | Reading | Evidence | Confidence |
|---|---|---|---|
| `147 1` (IC1) | Input 9 (pin 10) = red line. Inputs 8..2 on pins 5, 4, 3, 2, 1, 13, 12 from the other planes. Outputs A pin 9, B pin 7, C pin 6, all bubbled | c-147; c-9in | clear |
| A → 7416 1→2 → RED node (R5 470 Ω to Vcc) → pad D11 TV-RED | | c-rgb | clear |
| B → 7416 5→6 → BLUE node → D12; C → 7416 3→4 → GREEN node → D13 | | c-rgb | clear |
| Pull-downs | IC2 11 → 10 inverts row y≈1766. Its output drives three 7417 buffers (5→6, 3→4, 9→8), each through 470 Ω to the RED (R4), BLUE and GREEN (R11) nodes. A fourth buffer, 11→10, goes through R8 to the **BLUE node only**. That fourth buffer does not appear in the original's output stage. All four are drawn with a bubbled input and a bubbled output, so they are non-inverting (7417) | c-rgb; c-buf | clear; IC2 output numeral "10" probable |
| Row y≈1766 source | **IC53.13**. IC53 is drawn as an AND body with bubbled inputs, i.e. NOR: pins 11, 12 → 13 (7402). The row runs right to IC2.11; every widening on the way is a crossing (c-row1766) | c-e1top; c-row1766 | clear |
| 53.11 | IC47.3. IC47 is drawn as an AND body with every input and the output bubbled, i.e. **OR**. 47.2 = IC67.6. 47.1 = output 8 of the upward NAND from branch (b): it rises at x≈3500 to y≈2595, runs left to x≈3150 and up into pin 1 (scan gaps near x 3350–3380) | c-g43; c-g43b; c-47; c-up2 | symbols clear; route probable |
| 53.12 | Riser x≈4180 with a dot on the row at y≈1790, running down to the select pin 1 of the `157` below. That points to EXTEND, as on the original, but it was not followed to its label | c-e1top; c-up2 | not checked |

### Colour result

When /+200 is low:

1. 74.8 goes high, so 2.12 goes low.
2. **Encoder.** 147 input 9 (the highest priority) is active, so the
   outputs are D C B A = L H H L (onsemi function table) whatever its
   inputs 1..8 carry. A low releases the RED 7416, so the red node is
   pulled up. B and C high drive the BLUE and GREEN 7416s low. **The
   pixel is pure red.**
3. **Brightness.** The same low on 2.12 makes the upward NAND's output 8
   high. Then 47.3 (OR) is high, 53.13 (NOR) is low and 2.10 is high, so
   the three 7417 pull-downs are off. The pixel is therefore **full
   brightness**, not the dimmed level. The fourth pull-down acts on blue
   only, and blue is already low.

**+200 overrides what is underneath.** The 147 ignores every lower
plane while input 9 is active. Brightness is forced to full whatever
53.12 carries. The colours do not mix.

**Sharing with GAME OVER.** +200 shares the red collector with EX & GAME
OVER (pin 2) and five other red sources. If both were active on the same
pixel the result would be the same red. They do not overlap anyway, as
the next section shows.

The original board has the same structure here: red on 147 input 9
through a 7430 and an inverter, and red also feeding the
brightness-control collector (`docs/trace/SHEET_C_TRACE.md`, IC33, IC3,
IC13). The Pro board adds one input to the existing red NAND.

**Not checked.** TR1's blanking clamp acts only in blanking, outside this
window, and was not re-read on Pro.

## Placing Aldo's artwork

The reconstruction files are `pro/reconstruction/plus200-user-bitmap.txt`
and `game-over-plus200-user.png`, by Aldo. They are a reconstruction, not
original data.

### What the wiring fixes

- **Rows: below GAME OVER.** The window is H 0x100–0x10F. On the original
  board GAME OVER's text window is H 0x0F0–0x0FF on lines 0x40–0xBF
  (`docs/SHEET_B_LOGIC.md`). If Pro sheet B keeps that window, the +200
  band is the 16 H clocks immediately after GAME OVER's band. On the
  upright screen that is directly below GAME OVER, which is how the
  drawing places it. Pro sheet B's text window was **not traced** here.
  Its gates differ in layout from the original (IC77, IC81 and IC24 near
  (1100–2500, 1550–2200) on page 13).
- **Columns: inside GAME OVER's width.** GAME OVER's address uses V1..V6,
  so each of its 64 columns spans 2 lines. Counted from the left of GAME
  OVER (V 0x0BF), +200's lines V 0x09F..0x080 fall in GAME OVER columns
  **16..31**, the second quarter of the message from the left.
  Aldo's 64-column frame matches this:
  - column c (0–63) holds PROM addresses 2·(31 − c) and 2·(31 − c) + 1;
  - the drawn `+200` occupies frame columns 17–31, which is inside 16..31,
    and column 16 is left blank.

  This holds under the same unchecked assumptions about Pro sheet B.
- **Vertical resolution: 8 bit-rows, each two H clocks tall.** If the
  drawing's lower 16-row band stands for H 0x100–0x10F, frame rows 2k and
  2k + 1 must be identical. The drawn glyph occupies rows 5–10 and
  straddles the pairs (4, 5), (6, 7), (8, 9) and (10, 11), and those
  rows differ. **It cannot be stored as drawn.** It has to be redrawn on
  8 double rows: for example 3 double rows, 6 H clocks tall, or 6 double
  rows, 12 tall. That choice is Aldo's to make.
- **Horizontal resolution: twice GAME OVER's.** A +200 column is one line
  wide, against two for GAME OVER. A drawing in GAME OVER's grid uses
  each drawn column for two identical PROM words.

### What the wiring leaves open

- **Exact edge alignment.** GAME OVER's original path ends in a
  registered stage (`docs/SHEET_B_LOGIC.md`). The +200 path is
  combinational: the PROM address changes once per line and the mux
  follows H1..H3 directly. A one-clock offset between the two bands is
  therefore possible, and it is not settled here.
- **A1/A2 order.** If R1 and R2 turned out to be swapped, words within
  each group of four columns would be permuted.
- **Bit significance in a dump.** See the note above the "Sheet C:
  colour" section.

## Corrections to PR54_MAPPING.md

| PR54_MAPPING.md says | This trace reads | Basis |
|---|---|---|
| PR-54 pins 10..14 = V4, V3, V2, V1, V0 (bit-reversed address) | Pins 10..14 = **V0, V1, V2, V3, V4** (A0 = V0) | The rows nest as L shapes: the top row y≈2650 turns down furthest right (x≈7157) into the top pin, 10 (m-turn, m-addr). That top row is joined to the V0 riser by a dot at (3030, 2650), and the riser taps the V0 row with a dot at (3030, 3910) (m-lbtop, m-lbbot). V3 and V4 are clear the same way; V1/V2 are probable |
| IC124 pin 11 is fed by V-④ directly, so the gate would be disabled inside the strip (inconsistency) | 124.11 = **IC79.12 = NOT V-④**. The strip enables the window as expected | The 124.11 riser (x≈6770) goes **up** to the dot (6768, 1770) on IC79's output. The V-④ trunk (x≈6383) ends at IC79's input pin 13 (m-p11top, m-invz, m-tr2) |
| +200 enters IC74 on the input shown as pin 6 | It enters the seventh input from the top (numeral 5 or 3). Pin 6 carries /EXPLO (R) | c-route; c-pins. No logical effect |

Confirmed from that file: PROM outputs to IC129 I0..I7 in order; select
lines H1, H2, H3; output from W (pin 6); strobe from IC124.8 through
pin 7; a shared red path with GAME OVER; no colour stored in PR-54.

## Short report

**Established (clear unless noted):**

- **PROM and mux.** PR-54 (6331, open collector per MMI) with /E grounded.
  O1..O8 go to IC129 D0..D7, select H1..H3 (H0 unused), output W =
  `/+200 (R)`. One address per line; each bit two H clocks.
- **Address.** A0 = V0, A3 = V3, A4 = V4. A1 = V1 and A2 = V2 are
  probable.
- **Strobe.** IC129 /G = NAND(BONUS CP, NOR(H4..H7), NOT V-④). The NOT V-④
  is inverter IC79 13 → 12, which **resolves the enable-polarity
  inconsistency**.
- **V-④.** It is sheet B 7442 output 4 with A, B, C = V5, V6, V7 and
  D grounded: low for V7..V5 = 100.
- **Window.** Fixed: H 0x100–0x10F × V 0x080–0x09F, using the original
  board's counter ranges. It is shown only while BONUS CP is high and
  depends on no car or score position.
- **Colour.** /+200 is one input of the 8-input red NAND IC74, beside EX &
  GAME OVER. Through IC2 13 → 12 it drives 147 input 9 (highest priority)
  and the brightness logic. The result is **pure red at full brightness,
  overriding everything underneath**.

**Still uncertain:**

- **Which of R1/R2 carries V1 and V2.** The scan has lost ink in box
  (2880, 3860, 3060, 4120). A cleaner scan or a board continuity check
  from PR-54 pins 11 and 12 would settle it.
- **IC128's type.** The 7425 fits, but its strobe pin 11 is not drawn. The
  parts list or the board would settle it.
- **Numerals.** IC79's designator and output numeral; the IC74 input
  numeral (5 or 3); PR-54 numerals 12 and 13. None affects the logic.
- **Two scan gaps.** The H6 / V-④ crossing at (2943, 5050) was read as a
  crossing, and the +200 route on C has a 25 px dropout at x≈3245. Both
  readings are forced by logic, but neither has a clean scan.
- **Pull-ups.** Whether the 6331's open-collector outputs have pull-ups on
  the board; none are drawn.

**Not checked:**

- Pro sheet E counter ranges; the original ranges were assumed.
- Pro sheet B's GAME OVER window and pipeline, and so the exact alignment
  with GAME OVER.
- The screen-rotation convention on Pro, taken from the original sheet B
  notes.
- BONUS CP pulse length.
- Where 53.12 comes from (probably EXTEND).
- IC79.12's second load (the bridge `157` strobe).
- TR1 blanking on Pro.
- The bit-significance convention for writing PR-54 data.
