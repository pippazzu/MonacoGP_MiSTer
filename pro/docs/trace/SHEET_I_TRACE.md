# Pro sheet I: score memory (5101), battery, bonus lamps and /GAME END

Date: 2026-11-05. Issue #38. Bounded trace of Sega 420-0525 (Pro Monaco GP),
PDF page 18, board **96824-P (D-1/3) SCORE DISPLAY IC BOARD ASS'Y**, issue
stamp 1980-7-16. It covers what the issue asks for: the four 5101 RAMs
(address, data, select, R/W, OD, supply), the battery and its supply circuit,
the power-up and power-fail protection, the bonus lamp drive, and every load
of /GAME END. It also records the parts these lines run into: the sequencer
gate that replaces the original GAME input, the RAM RESET switch and the
10,000-point flip-flop. The search, comparison and rank logic is compared with
the original only at block level. The score counter entry is not traced again:
see `SHEET_F_BONUS_TRACE.md`, rows I01–I05.

Rechecked 2026-11-06 for issue #70: the RAM type (5101 or 2101) and the
select pins. See "RAM type and select pins: recheck (issue #70)" below. The
rows changed by that recheck are the Packages table, the pin 17 and 19 rows
of "Control and supply", the "Selects" paragraph under question 1, the
chip-select row of the comparison, U2, the summary and the short report.

## Sources and method

- Pro: `pro/schematics/promonacogp420-0525_1.pdf` (SHA-256 `9473d6dd…32f2`).
  Page 18 rendered with PyMuPDF at `Matrix(1, 1)`, upright: **10184 × 6617**
  pixels, the same size as the sheet I render in `SHEET_F_BONUS_TRACE.md`.
  Page 7 (cabinet wiring, 5100 × 6651, drawn sideways, read rotated by 270°)
  and page 5 (power supply parts list) for the battery. Every box below is
  (left, top, right, bottom) on the scale-1 render of its page. Crop names
  are local identifiers. The crops are not in the repository.
- Original: `schematics/pages/page23-sheet-I-score.png`,
  `docs/trace/SHEET_I_TRACE.md` ("Memory and ranking — pin-level reading")
  and `docs/SHEET_I_LOGIC.md`. The original is cited from those documents. It
  was not read again.
- Sheet N: `pro/docs/trace/SHEET_N_TRACE.md`, "IC133 / IC126" and "Complete N
  inter-sheet interface". `pro/docs/trace/BONUS_INPUTS_TRACE.md` was read for
  context. Neither was read again from the scan.
- Reading rules from `pro/README.md`: a drawn dot is a junction. A crossing
  is not, even where the scan thickens it. Gate function comes from the
  drawn symbol: body, input bubbles, output bubble. Pin numbers are checked
  against standard pinouts. Where they disagree, both are recorded and nothing
  is corrected.
- Confidence: **clear** (read directly, no competing reading), **probable**
  (one reading fits much better, but the scan or the route is not clean),
  **uncertain**.
- No MAME, emulator, other core, fan remake, footage, gameplay description
  or PROM contents were used.
- Datasheets (recheck, issue #70): Intel, *1978 Component Data Catalog*,
  bitsavers `components/intel/_dataBooks/1978_Intel_Component_Data_Catalog.pdf`
  (SHA-256 `144f2b1e…2646d`, 815 PDF pages). **5101 family**, catalog page
  3-153 (PDF page 185), pin configuration and description; data retention on
  3-154 (PDF 186). **2101A/8101A-4**, catalog page 3-26 (PDF page 58), pin
  configuration. Only these pages were read.

Notation: `nn.p` is the part drawn with designator nn, pin p, on this sheet.
Designators on this sheet collide (see U1), so the local names below are
used where needed.

### Crops

| Crop | Box (page 18 unless noted) | Contents |
|---|---|---|
| ov | (0, 0, 10184, 6617) at 0.15 | Navigation only |
| lamp-in | (2700, 150, 4300, 1300) | BONUS A–D pads, RA2, PR-01/PR-02 inputs |
| lamp-pads | (2850, 300, 3700, 650) | Pad labels HK, H8, HQ, HJ |
| prom1 / prom2 | (4050, 250, 4350, 800) / (4050, 750, 4350, 1300) | PR-01 and PR-02 bodies, pin numerals, LAMP RET |
| lamp-out | (4100, 150, 5900, 1300) | 220 Ω ×15, connector G, lamp unit, drivers |
| lamp-r1 / lamp-r2 | (4180, 340, 4880, 790) / (4180, 780, 4880, 1180) | Resistor and pad labels |
| lamp-box | (4850, 300, 5250, 1250) | Lamp unit pins 3–17 |
| lamp-drv | (5150, 300, 6050, 1350); zoom (5300, 400, 5700, 700) | TR16, TR13, R41, R43, R45, inverter 37, `(TM8132-9G)` |
| v2-row | (1350, 750, 3200, 1150); (3100, 850, 4000, 1100) | Pad HH V2 → PROM A4 |
| ram-97 | (3600, 2050, 4400, 2650); zooms (3800, 2300, 4250, 2620), (3880, 2180, 4120, 2280) | First 5101 |
| ram-96 / ram-95 / ram-74 | (4050, 2600, 4850, 3150) / (4500, 3000, 5300, 3550) / (4900, 3450, 5700, 4000) | Other three 5101s |
| addr | (2900, 1400, 4900, 2900); zooms (3800, 1550, 4600, 2250), (4250, 1750, 4950, 2700) | Counter 93 → address bus |
| data | (4700, 1400, 6700, 2900); (4850, 2150, 5750, 2560); (5550, 2200, 6450, 2560); (4150, 2250, 5000, 2450) | RAM DO → comparators, D bus |
| ctl-1 / ctl-2 | (3700, 2450, 4900, 3450) / (4300, 3350, 5700, 4500) | RAM pins 20, 18, 22, 17 |
| ctl-3 / ctl-dec | (3300, 3300, 4600, 4800) / (3450, 3850, 4500, 4600) | R64, rail, 7442 (82), inverter 64 |
| pwr | (4300, 3900, 6200, 5100) | D10, R43, C4, PWR-OK row |
| bat | (3800, 4900, 5400, 6200); (4100, 5300, 5200, 6150); (4650, 5500, 4950, 5800); (4450, 5550, 4700, 5700) | D9, R62, HX, H20, battery |
| seq | (2250, 4050, 3950, 5150); (3050, 4250, 3950, 4750); (2050, 4780, 3400, 4960) | 92a, 92b, 91, 93, 82 inputs |
| trunks | (2000, 4250, 2900, 5650); (2000, 2900, 2900, 4300) | Left vertical trunks |
| reset | (1350, 1150, 3000, 2350); (1350, 2300, 3000, 3300); (2050, 2250, 2400, 2700); (2200, 2200, 2550, 2400) | Input pads, 73 11, 91 3 |
| left-low | (1350, 4250, 3000, 5300); (1350, 5200, 3000, 6200); (1400, 4400, 2100, 4650) | HU, HS, HP /GAME END, RAM RESET SW.1, LATCH CL. |
| tenk | (2400, 4900, 3900, 6200); (2400, 5050, 3900, 5450); (2650, 5250, 3300, 5650); (2850, 5300, 3600, 5750); (2550, 5150, 6200, 5450) | 72, 73, 56, 65, 10,000 lamp |
| p4-row | (2400, 3200, 3900, 4400) | IC84, 90, 64 3→4 |
| right | (8000, 650, 9300, 1300); (5200, 5600, 6600, 6300) | S-100 pads, SP. CONT, Vs/16 |
| p7-bat | page 7: (300, 1150, 800, 1800), rotated 270° | Cabinet battery `2.4V (NR-…)`, terminals X and 20 |
| p5 | page 5: whole page at 0.2 | Item 8, S-96821 Ni & Cd Battery |
| r70-97 / r70-96 / r70-95 / r70-74 | (3600, 2050, 4400, 2650) / (4050, 2600, 4850, 3150) / (4500, 3000, 5300, 3550) / (4900, 3450, 5700, 4000), each at 2× | #70 recheck: body text and all 22 pin numerals of each RAM |
| r70-body97 | (3880, 2280, 4120, 2400) at 6× | #70: R97 body text alone |
| r70-glyph95 | (4760, 3080, 4960, 3290) at 5× | #70: R95's top pin numerals `2`, `21`, `5` above its body text, same hand, for comparing the first glyph |
| r70-ov | (3500, 2000, 5800, 4100) at 0.35× | #70: the four RAMs together |
| r70-p4 / r70-p5 | pages 4 and 5, whole page at 0.3× | #70: parts lists checked for a RAM type |

## Summary

- **Memory.** Four 5101 static RAMs, 256 × 4 each, one per score decade.
  They share one 8-bit address from a 74393 pair (drawn `93`) whose resets
  are grounded. Inputs DI come from the score counter (P-1…P-4). Outputs DO go
  to the A inputs of the memory comparators (drawn 88, 87, 86, 85). There
  are no 8216 bus drivers. The 256-slot score list survives power-off. The
  address counter, the score counter and the rank latches on K do not.
- **Supply.** The four RAM supply pins (22) are on a separate thick rail:
  Vcc → diode D9 → rail → R62 56 Ω → pad HX → Ni-Cd battery + → pad H20. On
  sheet I the battery symbol is captioned `Ni-CA 3.6V NR-AA`. The cabinet
  wiring (p7) draws the same two terminals (X +, 20 −) with a battery
  captioned `2.4V`. **3.6 V is the battery's caption on sheet I, not a rail
  name.** The rail itself is Vcc less one diode drop while the board is
  powered, and the battery voltage less R62's drop when it is not.
- **Protection.** All four CE2 selects (drawn pin 17, no bubble; 17 is CE2 on
  the datasheet, see the #70 recheck) are on one node,
  here called PWR-OK: R43 4.7 kΩ from Vcc, C4 22 µF to ground, D10 (MA-150)
  from the node to Vcc. The node rises about 0.1 s after Vcc and falls with
  Vcc through D10 when power fails. R/W (pin 20) is pulled to the battery rail
  by R64 1 kΩ. At power-up the write decoder (82, a 7442) is held off until
  eight V2 periods after /INI. RESET ends. The original board wrote 0000 into
  every slot during /INI. RESET. **Pro no longer does that.** A new RAM RESET
  switch (SW.1) does it instead.
- **Bonus lamps.** The parts the issue calls "two 138 decoders" are drawn as
  two PROMs, **PR-01 (IC55) and PR-02 (IC54), type 3188**. Their pinout is
  that of a 32 × 8 open-collector PROM, not a 74138. Address: BONUS A–D →
  A0–A3, V2 (pad HH) → A4. Fifteen outputs go through 220 Ω resistors to
  connector G and an off-board lamp unit drawn dashed, `(TM8132-9G)`. The
  sixteenth (PR-02 pin 9) picks one of two PNP common drivers, TR16 (G26) or
  TR13 (Gd). **Which lamp lights for which BONUS value is set by the PROM
  contents. The schematic does not give them.**
- **/GAME END** (pad HP) starts the after-game sequencer: it takes the
  place of the original GAME input. It also triggers a 74123 (drawn 65)
  whose output `T.R.S` goes to K, but only while the 10,000-point flip-flop
  (56) is set. It does not reach the lamps. While 56 is set the sequencer is
  held reset, so as drawn a game that passed 9999 is neither written to the
  5101s nor searched (see Q2 and the notes for #37).

## 5101 memory: pin tables

### Packages

| Item | Reading | Box | Confidence |
|---|---|---|---|
| Type | `5101` in all four bodies. Rechecked at high zoom for #70: the first glyph is a `5` (short top bar, down-stroke, bowl at the bottom opening left), drawn as the `5` pin numerals on the same sheet, not a `2` (which this hand draws as a Z with a flat base: pins 2, 20, 22). No body reads `2101` | r70-97, r70-96, r70-95, r70-74, r70-body97, r70-glyph95 | clear on R96 and R95; probable on R97 and R74 (first glyph broken in the scan, but no flat base) |
| Designators, top to bottom | **97**, **96**, **95**, **74** as read. The issue (from an overview) gives 59, 66, 65, 74. On this sheet `65` is also the 74123 at (2950, 5450) and `66` an AND gate at (5870, 4815), which supports the readings here. Below, the RAMs are called R97, R96, R95, R74 | ram-97 zooms; ram-96; ram-95; ram-74 | 96 clear; 97 and 95 probable (first numeral malformed); 74 probable |
| Drawn pins | Top 4, 3, 2, 1, 21, 5, 6, 7. Left 9, 11, 13, 15. Right 10, 12, 14, 16. Bottom 20 (bubble), 18, 22, 17, 19 (bubble), 8 | all four; rechecked on r70-97..r70-74 | clear on R97/R96/R74; R95's top numerals probable (its `7` is malformed). On all four the `17` label sits by the plain stem and `19` by the bubbled stem that joins pin 8 |
| Datasheet check (Intel 5101) | **Corrected for #70** against Intel's 1978 catalog, p. 3-153: A0–A3 = 4, 3, 2, 1; A4 = 21; A5–A7 = 5, 6, 7; DI1–4 = 9, 11, 13, 15; DO1–4 = 10, 12, 14, 16; GND 8; **CE2 17; OD 18; /CE1 19**; R/W 20; Vcc 22. The first version of this row had 17 and 19 swapped and reported a conflict that does not exist: every drawn pin agrees, and the bubble on 19 and none on 17 match /CE1 and CE2 | datasheet | clear |
| Datasheet check (Intel 2101A) | Catalog p. 3-26: the same 22-pin assignment, pin for pin (CE2 17, OD 18, /CE1 19, /WE 20, Vcc 22, GND 8, same address and data pins). The 5101 sheet itself calls the 2101A "pin compatible". **So the drawn pin numbers and bubbles cannot tell a 5101 from a 2101**; only the body text can. The bubble on 20 fits both (2101A /WE; 5101 R/W writes when low) | datasheet | clear |

### Address

| Item | Reading | Box | Confidence |
|---|---|---|---|
| Counter | Two halves of one 74393, both drawn `93`. First half: CP 1 ← 72.11 (OR, inputs 12, 13; sources not traced), MR 2 → ground; QA–QD 3, 4, 5, 6. Second half: CP 13 ← first half pin 6 (dot), MR 12 → ground; QA–QD 11, 10, 9, 8 | addr zoom (3800, 1550, 4600, 2250) | clear |
| R97 | 93.3 → 4 (A0), 93.4 → 3 (A1), 93.5 → 2 (A2), 93.6 → 1 (A3), 93.11 → 21 (A4), 93.10 → 5 (A5), 93.9 → 6 (A6), 93.8 → 7 (A7). The upper four come down straight. The lower four reach their pins through rows with dots on 11, 10, 9, 8 | addr zoom | clear |
| R96 | Same eight rows, each taken down by a dot: A0 → 4, A1 → 3, A2 → 2, A3 → 1, A4 → 21, A5 → 5, A6 → 6, A7 → 7 | (4250, 1750, 4950, 2700) | clear |
| R95, R74 | The same rows continue right and drop to the same pin order. Followed as a bus, not dot by dot | addr; ram-95; ram-74 | probable |
| Function | Counter bit k → A_k on every RAM. All four RAMs share one address, as in the original (9F → 2111s). The counter has no clear and no battery supply | | clear (R97, R96) / probable (R95, R74) |

### Data

| Item | Reading | Box | Confidence |
|---|---|---|---|
| R97 DI 9, 11, 13, 15 | Rows from the first IC75 half, 3/4, 5, 6, 7 = P-1A, B, C, D (labelled taps with arrows to I/J/K) | addr (2900, 1400, 4900, 2900) | clear |
| R96 DI | Rows from the second IC75 half, 13/12, 11, 10, 9 = P-2A–D | addr | clear |
| R95 DI, R74 DI | P-3 rows (IC84 first half) and P-4 rows (IC84 second half, 13/12, 11, 10, 9; P-4A–D taps) | addr; p4-row (2400, 3200, 3900, 4400) | probable (overview zoom) |
| R97 DO 10, 12, 14, 16 | Four rows right to 85 (7485) drawn `88`, A inputs 10, 12, 13, 15. No dots seen on the address-bus crossings | data (4850, 2150, 5750, 2560); (4150, 2250, 5000, 2450) | probable (dense crossings) |
| R96, R95, R74 DO | To the A inputs of 85s `87`, `86`, `85`, in the same way | data; ov | probable |
| 88..85 B inputs (9, 11, 14, 1) | Rows that continue right to the 74192s `62`, `71`, `80`, `89`. The same rows carry the B inputs of the top comparator row `79`, `78`, `77`, `76` (A = P-1..P-4, drawn as labelled arrows) | data (5550, 2200, 6450, 2560); right ov | probable |
| **D-1A..D-4D → K** | The labelled D-bus arrows to K tap, with dots, **the rows on the right of 88..85**: the 192 outputs and comparator B inputs. They do not tap the RAM DO rows | data zoom (5550, 2200, 6450, 2560) | probable |

**Data function.** Each 5101 holds one decimal digit of 256 scores: R97
units, R96 tens, R95 hundreds, R74 thousands. A write stores the live score
P. There is no bus turnaround: DI and DO are separate pins, which is why the
8216s are gone.

### Control and supply

| RAM pin | Connection | Box | Confidence |
|---|---|---|---|
| 20, R/W (bubble) | One line at x ≈ 3875–3881: R97.20 and R96.20 (dot y ≈ 3010), R95.20 (row y ≈ 3438, dot), R74.20 (row y ≈ 4095 from the 82.3 dot). It goes down to **82.3**, output 2 of the 7442 drawn `82 42`. **R64 1 kΩ** from this line (dot at about (3881, 3537)) to the RAM rail (dot at about (4047, 3531)) | ctl-1; ctl-2; ctl-3; ctl-dec | clear |
| 18, OD | Common line: R97.18 → row y ≈ 3050 → R96.18 line (x ≈ 4390). R95.18 and R74.18 → row y ≈ 4228 with dots at x ≈ 4817 and 4394. Source: **inverter 64, 13 → 12**, input 82.3 | ctl-1; ctl-2; ctl-dec | clear |
| 22, Vcc | Thick lines: R96.22 is the rail trunk itself at x ≈ 4472. R95.22 → thick row y ≈ 3528 → trunk (dot). R74.22 → thick row y ≈ 4317 → trunk (dot). R97.22 → x ≈ 4045 → thick row y ≈ 3531 → trunk (dot), with R64 on the same row. The trunk goes down to the D9 cathode node (x ≈ 4481, y ≈ 5537) | ctl-1; ctl-2; ctl-3; bat | clear for R96, R95, R74; R97 probable (its riser joins the R64 dot) |
| 17, CE2 (no bubble) | **PWR-OK**: R74.17 down to the node at about (5370, 4260–4378). R95.17 → dot at (5006, 4378). R96.17 and R97.17 → dot at about (4517, 4375). The row y ≈ 4378 has no other load in the crops | ctl-2; ctl-3; pwr | clear (R74, R95, R96); R97 probable (it jogs at y ≈ 3840) |
| 19, /CE1 (bubble), and 8 | Joined and grounded on all four: /CE1 permanently active | ram-97 zoom; ram-96; ram-95; ram-74 | clear |

### Power and protection circuit

| Part | Reading | Box | Confidence |
|---|---|---|---|
| D9 | `SiB01-02` (prefix probable), anode at a `Vcc` dot, cathode at the rail node | bat (4100, 5300, 5200, 6150) | type probable; orientation clear |
| R62 | Rail node → pad HX. Value `56Ω`, followed by `1/` and a blotted glyph (1/2 W or 1 W) | bat; (4450, 5550, 4700, 5700) | 56 Ω clear; wattage uncertain |
| Battery | HX (filled pad) → `+` cell plate. `−` plate → pad H20 (crossed pad). Caption `Ni-CA 3.6V NR-AA` and a katakana line `(バッテリー…)(…)` that was not read | bat | caption clear; katakana not read |
| H20 inside the board | A short riser from H20 to a blotted symbol, probably a ground mark | (4650, 5500, 4950, 5800) | uncertain |
| Cabinet, p7 | Battery `2.4V (NR-…)` (suffix unclear, AA or 4A). `+` → wire tag `20` → terminal **X**. `−` → wire tag `50` → terminal **20** of the score-board connector. These match pads HX (+) and H20 (−) | p7-bat | terminals and polarity probable (small print); 2.4 V clear |
| Parts list, p5 | Item 8, `S-96821 Ni & Cd Battery`, in the power supply assembly. No voltage | p5 | clear |
| D10 | `MA-150`. Anode on PWR-OK (dot), cathode to the `Vcc` end of R43 (dot) | pwr (4300, 3900, 6200, 5100) | clear |
| R43 | 4.7 kΩ, PWR-OK ↔ Vcc | pwr | clear |
| C4 | 22 µ, 16 V, `+` on PWR-OK, `−` to ground. A second caption beside it was not read | pwr | value clear |
| Rail (the thick trunk) | No label. Nothing on it but the four pin-22s, R64 and R62/D9 | ctl-1..3; bat | probable (the whole rail was followed at 0.8–0.9 scale) |

**Answer to question 1.**

*What is kept.* All four 5101s, that is, all 256 four-digit score slots.
Nothing else on the sheet is on the battery rail. The address counter (93)
has its resets grounded and is not battery-backed, so after power-up the next
write goes to an arbitrary slot. The rank latches on K are cleared by LATCH
CL. (below). The score counter is cleared by RST.

*What protects the memory while power fails.*

1. **Select.** The four CE2 selects (pin 17) follow PWR-OK. When Vcc falls, C4
   discharges through D10 into the falling Vcc line, so PWR-OK goes low with
   Vcc and the RAMs are deselected. At power-up PWR-OK lags Vcc by about
   R43 × C4 ≈ 0.1 s.
2. **R/W.** R/W is held high by R64 to the battery rail. A write needs 82.3
   actively low.
3. **No write at power-up.** 82 is enabled only while 92a has finished
   counting (next section). That takes eight V2 periods after /INI. RESET
   rises.

*Selects (corrected for #70).* The first version of this trace said the
drawn pin numbers conflict with the datasheet. They do not: it had quoted
the 5101 pinout with 17 and 19 swapped. Intel's 1978 catalog (p. 3-153)
gives **17 = CE2 (active high) and 19 = /CE1 (active low)**. As drawn, the
bubbled 19 is grounded (/CE1 always active) and the unbubbled 17 is PWR-OK.
Numerals, bubbles and datasheet agree, and the circuit works: PWR-OK on CE2.
The same page says the 5101 draws its minimum standby current "when CE2 is
at a low level", which is what PWR-OK does when Vcc fails. The drawing
settles which pin carries PWR-OK (17), as far as a schematic can; board
continuity would only confirm it.

Electrical notes, not settled: while powered, the rail is Vcc less one diode
drop. The battery charges from it through R62. Whether the battery is two
cells (2.4 V, page 7) or three (3.6 V, sheet I) is not settled by the
drawings.

### RAM type and select pins: recheck (issue #70)

A follow-up on #38 reported `2101` in the RAM bodies, seen on an overview
crop from the sheet K work. Rechecked on 2026-11-06 at 2× to 6× on the
native-resolution scan (the page image is 10184 × 6617, so scale 1 is the
scan's own resolution; higher zoom only enlarges it).

| Check | Finding | Box | Confidence |
|---|---|---|---|
| Body text, R97 | `5101` over `97`. The `5` is broken in two (a top bar with a stub, then a bowl opening left), with no flat base | r70-97; r70-body97 (3880, 2280, 4120, 2400) | probable `5` (broken glyph) |
| Body text, R96 | `5101` over `96`, the `5` drawn whole | r70-96 (4050, 2600, 4850, 3150) | clear |
| Body text, R95 | `5101` over `95` (the `0` partly open). The first glyph matches the pin-5 numeral printed just above the body; the pin-2 numeral beside it is a Z with a flat base | r70-95; r70-glyph95 (4760, 3080, 4960, 3290) | clear |
| Body text, R74 | `5101` over `74`. First glyph broken like R97's, bowl at the bottom | r70-74 (4900, 3450, 5700, 4000) | probable `5` |
| Overview | At 0.35× all four still read `5101` (r70-ov). The `2101` report came from a smaller overview, where the broken `5`s of R97 and R74 can pass for a `2` | r70-ov (3500, 2000, 5800, 4100) | the cause is a guess, not a reading |
| Parts lists, PDF pp. 4–5 | Page 4: front panel and handle assembly. Page 5: power supply assembly (item 8 S-96821 Ni & Cd Battery). Neither lists ICs; no RAM type is given. Page 3 lists the 96824-P score board only as an assembly. The PDF text layer has neither `2101` nor `5101` on any page | r70-p4, r70-p5 | clear |
| Pinout | 5101 (catalog p. 3-153) and 2101A (p. 3-26) have the same pin assignment, so the pin numbers cannot separate them. Every drawn numeral and bubble agrees with that assignment | datasheet | clear |
| Select pins | 17 = CE2 → PWR-OK; 19 = /CE1 → ground (with pin 8). No conflict; the earlier conflict came from a swapped pinout in this trace | r70-97..r70-74 | clear |

**Verdict.** The schematic draws **5101** in all four bodies (clear on two,
probable on two, no body reads 2101). The trace's type stands; the title is
unchanged. The circuit is consistent with a CMOS part: the RAM rail is
battery-backed and CE2 is pulled low when Vcc fails, which is the 5101's
standby condition. That fit is supporting context, not evidence of the type:
a 2101A would wire the same way. Whether the boards carried the 5101 or the
5101L (the version with guaranteed retention down to 2.0 V, catalog
p. 3-153) is not drawn.

## Sequencer, resets and the write

The original's sequencer (11A first half, 12A 7442, `SHEET_I_LOGIC.md` steps
1 and 6) is present. Its start and enable conditions have changed.

| Part | Pins and connections | Box | Confidence |
|---|---|---|---|
| Pad H13 `/INI. RESET` (A) | RA3 1 kΩ (pin 1). Trunk at x ≈ 2117 with 1000 pF to ground (dot y ≈ 3050). Loads: 73.13, 83.13 | reset; trunks | clear |
| `RAM RESET SW.1` | Switch between a ground mark and a node. The node has a filled pad (unlabelled) with a ground-like mark below it, RA3 1 kΩ (pin 8) to Vcc, and a row (y ≈ 5569) to the trunk at x ≈ 2160, here **/RAM RESET**. Loads: 73.12, 73.4, 91.9 | left-low (1350, 5200, 3000, 6200); trunks | switch and pull-up clear; pad and mark under the node uncertain |
| 73 (12, 13 → 11) | OR body, input and output bubbles: **AND**. 11 = /INI. RESET · /RAM RESET | reset zoom (2050, 2250, 2400, 2700) | clear |
| 91 (1, 2 → 3) | OR body, input bubbles: **NAND**. 1 = /COIN & TEST (pad HV, RA4 pin 8), 2 = 73.11. **3 = RST** = COIN & TEST + INI. RESET + RAM RESET. 91.3 is the counter clear named in F trace I05 | reset; (2200, 2200, 2550, 2400) | clear |
| LATCH CL. → K | From 73.11 (dot at about (2222, 2365)) down the trunk at x ≈ 2225 to the arrow. No other dot on the trunk in the crops | reset; trunks; left-low | probable |
| 83 (13 → 12) | 13 = /INI. RESET, 12 → 92a MR 2 | trunks; seq | clear |
| 92a (74393 half, `393/2 92`) | CP 1 ← 81.10. 81 (8, 9 → 10) is an AND body with input bubbles: NOR. 81.8 = 92a QD 6 and 81.9 = HU. HU is `V2` (E) with a raised mark, R63 560 Ω pull-up, and also an arrow to K and J. QD 6 → 81.8 and **91.5**. QC 5 → 72.9 | seq; left-low (1350, 4250, 3000, 5300); (1400, 4400, 2100, 4650) | clear; the pin-5 numeral is probable |
| 92a function | Cleared during INI. RESET. Then it counts HU V2 periods and stops with QD high after eight. This is the same as the original's 12C second half (MR = NOT /INI. RESET, eight V2 periods) | | clear |
| 92b (74393 half, `393/2 92`) | CP 13 ← 93.8. 93 (9, 10 → 8) is an AND: 9 = 91.8, 10 = H5 (pad HS, RA4 pin 7). 1000 pF on 93.8. 91 (9, 10 → 8) is a NAND: 10 = 92b QD 8, 9 = **/RAM RESET**. Outputs: QA 11 → 91.4; QB 10 → 82.15 (A); QC 9 → 82.14 (B); QD 8 → 82.13 (C) and 91.10 | seq; (3050, 4250, 3950, 4750); (2050, 4780, 3400, 4960) | clear |
| 92b MR 12 | ← **73.6**, with C3 470 pF to ground. 73 (4, 5 → 6) is an AND (OR body, all bubbles): 4 = /RAM RESET (dot on the x ≈ 2160 trunk at y ≈ 5177), 5 = 72.6. 72 (5, 4 → 6) is an AND body with input and output bubbles: **OR**. 5 = **/GAME END**, 4 = 56.Q (pin 9) | tenk (2400, 5050, 3900, 5450); trunks | clear for the routing; the "4" numeral on 72 is probable |
| 91 (5, 4 → 6) | NAND. 5 = 92a QD (dot at about (2891, 4399)), 4 = 92b QA. **6 → 82.12 (D)** | seq zoom | clear |
| 82 (7442) | A, B, C = 92b QB, QC, QD; D = 91.6. Output 1 (/0) ADR INC., output 2 (/1) 192 LD., **output 3 (/2) = RAM R/W**: R/W of all four RAMs, the inverter 64 input (→ OD), and a row y ≈ 4095 east. Output 4 (/3) → 256 CL. side (not followed) | ctl-dec | 82.3 loads clear; phase names follow the original by position, not re-read |

**What this does.**

- **After a game.** 92b's MR is 73.6 = /RAM RESET · (/GAME END + 56.Q). With
  /RAM RESET high and 56 clear, MR follows /GAME END. During the game MR is
  high and the sequencer is held. When /GAME END goes low, 92b counts H5 to
  8 and stops (91.10 = QD). On its odd counts 82 decodes ADR INC., 192 LD.,
  **RAM R/W** (the score P is written into the slot) and 256 CL. (search and
  ranking). This is the original sequence. Only the start condition differs:
  the original used GAME low (2H with /INI. RESET), Pro uses /GAME END low.
- **Power-up.** /INI. RESET no longer frees 92b. In the original, 11B.13 =
  /INI. RESET let 11A run freely and write 0000 everywhere; in Pro that input
  (91.9) is /RAM RESET. 82 is also blocked (91.5 = 92a QD low) until eight
  V2 periods after /INI. RESET ends. **So power-up no longer clears the
  memory.**
- **RAM RESET (SW.1).** It does what /INI. RESET did on the original. RST
  holds the score at 0000 (through 91.3). 92b is freed (73.6 low) and free
  runs (91.8 high). 82 is enabled once 92a has finished. So holding the
  switch writes 0000 into slot after slot while the address advances. Like
  /INI. RESET, it also asserts LATCH CL. How long it must be held to cover
  all 256 slots was not worked out.
- What 92b does at power-up when /GAME END is already low depends on how its
  run lines up with 92a's eight V2 periods. That timing was not worked out.

## The 10,000-point flip-flop (context for #37)

| Part | Reading | Box | Confidence |
|---|---|---|---|
| 56 (`74/2`, D flip-flop) | D 12 = Vcc. CK 11 ← inverter (1 → 2, designator blotted) with C6 680 pF (`セラ`) to ground. /CL 13 ← a trunk at x ≈ 3062 from above. Q 9 → 72.4, 65.B 2 and the lamp inverter `06` 13 → 12 | tenk (2650, 5250, 3300, 5650), (2850, 5300, 3600, 5750) | clear; /CL source probable (below) |
| CK source | Inverter input ← row y ≈ 5310 east to x ≈ 4228, up to a dot at about (4221, 3750) on the P-4D row (IC84 QD 9, thousands decade) | (2550, 5150, 6200, 5450); ctl-3 | probable |
| /CL source | The x ≈ 3056–3062 trunk: RST at IC84 MR 14 (dot), then inverter 64 (3 → 4), then 90 CL 13 and on down. So /CL = /RST | p4-row (2400, 3200, 3900, 4400) | probable |
| Lamp | 06 (13 → 12) → R42 1 kΩ → base of TR14 (A684, emitter to `LAMP V` (H)) → pad G25 → lamp `YOUR SCORE 10000POINT LAMP` → ground | tenk; bat (3800, 4900, 5400, 6200) | probable |
| 65 (`123/2`) | /A 1 = /GAME END (dot at about (2500, 5222)), B 2 = 56.Q, /CLR 3 = Vcc. Timing: a capacitor (`.01`/`1µ`, overwritten) and R57 47 kΩ to Vcc on 14/15. Q 13 → arrow **T.R.S** → K | tenk (2400, 4900, 3900, 6200) | connections probable; capacitor value uncertain |

As drawn: 56 sets when the thousands decade carries out (P-4D falls), lights
the 10,000-point lamp and stays set until RST. While it is set, 72.6 is high,
so 92b stays reset after /GAME END. No RAM write and no search happen for
that game. /GAME END instead fires 65, and `T.R.S` goes to K.

## Bonus lamps

| Item | Reading | Box | Confidence |
|---|---|---|---|
| Inputs | `BONUS A.`, `B.`, `C.`, `D.` with a brace to circled **N**, into a column of four crossed pads. Labels: `HK` above, `H8` below, `HQ` and `HJ` left of the circled N. The four labels are probably the four pads, but which label belongs to which pad is not drawn unambiguously | lamp-pads (2850, 300, 3700, 650) | labels probable; per-pad assignment uncertain |
| Pull-ups | RA2 `1K×4` from Vcc, network pins 6 (A), 5 (B), 4 (C), 3 (D), each with a dot on its line | lamp-in | clear |
| PROMs | `PR-01`, `3188`, designator **55**; `PR-02`, `3188`, designator **54**. The issue's "138, IC35/IC34" is not what is drawn | prom1; prom2 | type and names clear; 55 and 54 probable |
| Datasheet check | Drawn pins: inputs 10–14, outputs 1–7 and 9, select 15 (bubble). This matches a 32 × 8 bipolar PROM (74S188 / 82S23 family: A0–A4 = 10–14, O1–O8 = 1–7, 9, /CE = 15). It does not match a 74138 (inputs 1–3, enables 4–6, outputs 15–7) | | clear |
| Address | A → 10 on both, B → 11, C → 12, D → 13 (dots on four verticals). Pin 14 on both ← the row from pad **HH**, `V2` (E), RA2 1 kΩ pin 2 (dot at about (3835, 987)) | lamp-in; v2-row | clear |
| /CE 15 | Both to an arrow `LAMP RET.` (PR-01 upward, PR-02 downward) | prom1; prom2 | clear; what LAMP RET is was not traced |
| PR-01 outputs | 1, 2, 3, 4, 5, 6, 7, 9 → R60, R59, R58, R57, R56, R55, R54, R53 (`220×15`) → connector G pins 37, 36, 35, 34, 33, 32, 31, 30 → lamp-unit pins 3–10 | lamp-r1 (4180, 340, 4880, 790); lamp-box | resistor names probable (R57 is also printed near 65); G 37–31 clear, 30 probable |
| PR-02 outputs | 1–7 → R52, R51, R50, R49, R48, R47, R46 → G pins l, m, n, p, r, s, t → lamp-unit pins 11–17 | lamp-r2 (4180, 780, 4880, 1180); lamp-box | letters p, r, s probable |
| PR-02 pin 9 (O8) | Down and right along y ≈ 1215 to a vertical at x ≈ 5915. Loads: R43 1 kΩ to `LAMP V`; R45 330 Ω to the base of TR16; inverter `37` 5 → 6, then R41 330 Ω to the base of TR13 | lamp-out; lamp-drv | clear |
| TR16, TR13 | `A684` (PNP symbol, arrow on the emitter). Emitters on `LAMP V`. Collectors → pads **G26** (TR16) and **Gd** (TR13) → arrows into the right edge of the lamp unit | lamp-drv; zoom (5300, 400, 5700, 700) | clear; a mark where the G26 row crosses the emitter riser is read as a crossing (it is arrow-shaped, smaller than a dot) |
| Lamp unit | Dashed outline, lamp/LED symbol at the top, diagonal dashed line. Inputs 3–17 on the left and two common entries on the right. Caption `(TM8132-9G)`, partly unclear | lamp-box; lamp-drv | outline clear; caption probable |

**Answer to question 2.**

*Which lamp for which BONUS value.* **Not given by the schematic.** The
decode is a PROM look-up: each 5-bit address (BONUS D–A, plus V2) gives a
15-bit pattern on the element lines and, on PR-02 O8, the choice of common
(O8 low: TR16 / G26; O8 high (open): inverter 37 → TR13 / Gd). With no PROM
dump, how values map to lamps cannot be read. Dumps of PR-01 and PR-02, or
the lamp unit's artwork, would settle it.

What the wiring does establish: the unit is driven as a matrix, with 15
element lines (sunk by the open-collector PROM outputs through 220 Ω) and
two commons (sourced from LAMP V by the PNPs). V2 is PROM address A4 here,
and sheet N's 74157 (IC133, select = V2) switches BONUS A–D between IC132
and IC140 (N trace, "IC133 / IC126"). So the display is probably
time-multiplexed: in one V2 phase BONUS A–D carries one count and the PROM
can pick that phase's common, in the other phase the other count. This is
probable only. V2 on N comes from A, here from E (pad HH), and that they are
the same signal in the same phase is not shown on these sheets.

*What /GAME END does on this sheet.* Pad **HP**, `/GAME END` from circled N,
RA3 1 kΩ (pin 7) pull-up. The row runs right with one dot at x ≈ 2500 (down
to 65 /A) and ends at 72.5. It crosses the trunks at x ≈ 2117, 2160 and 2225
without dots. Two functions:

1. Through 72 and 73 it is the reset of the after-game sequencer 92b: when
   /GAME END falls, the score is written to the 5101s and the search and
   ranking run (unless 56 is set).
2. It is the trigger of 65 (`T.R.S` → K), which fires only while 56 is set.

It has no connection to the lamp PROMs or drivers.

## Off-sheet signals and pads

Pads are as printed next to each crossed (×) or filled (■) square. Direction
is relative to sheet I.

| Signal (as written) | Pad | Dir. | Other sheet | Where it goes on I | Confidence |
|---|---|---|---|---|---|
| BONUS A–D | HK, HQ, HJ, H8 (assignment uncertain); N's pads M1–M4 | in | N | RA2; PR-01/PR-02 A0–A3 | probable |
| V2 | HH | in | E | RA2 pin 2; PR-01/PR-02 A4 | clear |
| /14MHz (bar) | H18 | in | E | RA4 pin 1; 81.2 (search clock gate) | clear (load not followed) |
| /SCORE CP | H16 | in | F | RA2 pin 9; score counter (F trace I01) | clear |
| /COIN & TEST | HV | in | A | RA4 pin 8; 91.1 | clear |
| /INI. RESET | H13 | in | A | RA3 pin 1; 1000 pF; 73.13; 83.13 | clear |
| V2 (raised mark) | HU | in | E | R63 560 Ω; 81.9; arrow to K and J | clear; the mark is unread |
| H5 | HS | in | E | RA4 pin 7; 93.10 | clear |
| /GAME END | HP | in | N (pad M5) | RA3 pin 7; 72.5; 65.1 | clear |
| RAM RESET | SW.1 and an unlabelled filled pad | in (switch) | cabinet | /RAM RESET trunk | probable |
| Battery + / − | HX / H20 | power | cabinet (X / 20, p7) | rail via R62 / unclear | probable |
| LAMP V | arrows, no pad | power in | not stated at the drivers; `(H)` beside TR14 | TR16, TR13, TR14 emitters; R43 | clear |
| LAMP RET. | arrows, no pad | | not stated | PR-01/PR-02 /CE | clear |
| Lamp elements | G37–G30, Gl–Gt | out | lamp unit | PR outputs via 220 Ω | probable |
| Lamp commons | G26, Gd | out | lamp unit | TR16, TR13 collectors | clear |
| 10,000-point lamp | G25 | out | cabinet lamp | TR14 collector | probable |
| T.R.S | arrow, no pad | out | K | 65.Q 13 | probable |
| LATCH CL. | arrow, no pad | out | K | 73.11 | probable |
| P-1..P-4 A–D | arrows | out | I/J/K (circled marks above P-1) | score counter | clear for labels |
| D-1..D-4 A–D | arrows | out | K | 192 / comparator B rows | probable |
| 1ST..5TH | arrows | out | K | 259 drawn `10` | read at overview only |
| 1ST FLASH..5TH | arrows | out | J | 259 drawn `3` | read at overview only |
| R-1..R-3 A–D | arrows | out | J | 390 halves | read at overview only |
| S-100 A, B, C, D | H10, HL, H12, H11? | out | D | buffers drawn `63` | pads probable |
| S-100-D' | H11 | out | A | buffer 63 13 → 12 | probable (two pads read H11) |
| SP. CONT | HT | out | H | inverter 11 → 10 | probable |
| Vs/16 | H17 (filled) | in | circled letter (I or H) unclear | RA6 1 kΩ pin 6; north into the flash logic (gate `81`, 5, 6 → 4, read at overview only) | pad probable; load not checked |

Not on Pro sheet I: the original's **GAME** input (pad "e"). Its role is taken
by /GAME END.

## Comparison with the original by function and net

| Function | Original (420-0358 p23) | Pro (420-0525 p18) | Confidence |
|---|---|---|---|
| Memory | 2111 × 4 (10F, 11F, 11E, 11H), shared I/O through 8216 × 4 (6E..3E) | 5101 × 4 (97, 96, 95, 74), separate DI/DO, no 8216 | clear |
| Address | 9F 74393, both halves, MRs grounded, A0–A7 | 93 74393, both halves, MRs grounded, bit k → A_k | clear |
| Data written | P-1..P-4 through the 8216s | P-1..P-4 straight to DI | clear (R97, R96), probable (R95, R74) |
| Memory to comparators | D bus (8216 DO) → 6F..3F A | RAM DO → 88..85 A | probable |
| D bus to K | 8216 DO (the memory data) | Taps on the 192 / comparator-B rows. At a memory match the two values are equal, but as nets they differ | probable; a net-level difference |
| R/W | 12A.3 RAM R/W | 82.3, plus R64 1 kΩ to the battery rail | clear |
| Output disable | 13D inverter of RAM R/W → 2111 OD | 64 (13 → 12) of 82.3 → OD 18 | clear |
| Chip selects | /CE1, /CE2 grounded | CE2 (17) on PWR-OK (R43/C4/D10), /CE1 (19) grounded | clear (pin identity settled by the #70 recheck) |
| RAM supply | Vcc | Separate rail: D9 from Vcc, R62 to the Ni-Cd battery (HX/H20) | clear |
| 7442 D input | NOT 11A QA | NAND(92b QA, 92a QD): adds the power-up block | clear |
| Sequencer start | 2H: /INI. RESET with GAME | 73/72: /RAM RESET with (/GAME END + 56.Q) | clear (72 pin numeral probable) |
| Free run during reset | 11B.13 = /INI. RESET | 91.9 = /RAM RESET | clear |
| Memory cleared | At every power-up (during /INI. RESET) | Only by RAM RESET SW.1 | clear (reading of the drawn logic) |
| Reset trunk RST | 13H: COIN & TEST + INI. RESET | 91.3: COIN & TEST + INI. RESET + RAM RESET | clear |
| LATCH CL. → K | pwr, NOT 12C QD | 73.11 = /INI. RESET · /RAM RESET | probable |
| Bonus lamps | none | PR-01/PR-02 PROMs, 220 Ω × 15, TR16/TR13, lamp unit | clear |
| 10,000-point flag and lamp, T.R.S | none | 56, 06/TR14/G25, 65 → K | probable |
| Search/rank (393 + 259 search clock, 192 × 4, 85 rows, 390/259 rank logic, R, N, flash) | as in `SHEET_I_LOGIC.md` | The same blocks are recognisable at overview level | **not checked** at pin level |
| S-100 outputs | 11C/11D/2E-1 drivers, J/G pads | Buffers `63`/`17`, an extra NAND `72` with NOT P-2C and P-3D, pads H10–H12, H11 | not checked |

## Uncertainties and what would settle them

| ID | Uncertain | What would settle it |
|---|---|---|
| U1 | RAM designators 97 and 95 (malformed first digit); PROM designators 55 and 54; RAM 74 versus the `74/2` type caption on 56. Other collisions on the sheet: `93` is both the address 74393 and an AND section (9, 10 → 8) and an inverter (5 → 6); `81`, `91`, `72`, `73` each label several sections. They are kept as drawn, located by box | A sharper scan, or the board's silkscreen |
| U2 | **Resolved (#70).** The drawing puts PWR-OK on 17 without a bubble and grounds the bubbled 19. Intel's catalog (p. 3-153) has 17 = CE2 and 19 = /CE1, so the drawing is consistent; the conflict came from a pinout swapped in this trace. Still open under U2: the RAM type is read from the body text only (`5101`, two bodies probable), and the 5101/5101L variant is not drawn | The board's chips, for the type and variant |
| U3 | Battery voltage: 3.6 V (sheet I caption) against 2.4 V (cabinet p7). R62 wattage. Where H20 goes inside the board (blotted symbol, probably ground) | The battery fitted to a board, or the parts list of the score board |
| U4 | Bonus-pad labels: which of HK, HQ, HJ, H8 is BONUS A..D | The board, or the cabinet wiring of the 96824-P connector |
| U5 | Lamp mapping: PROM contents of PR-01/PR-02 | PROM dumps, or the lamp unit's artwork |
| U6 | The two V2s (E at HH and HU here, A on N) and their relative phase | Sheet E and A traces |
| U7 | The D bus to K is taken from the 192 rows, not the RAM DO rows (probable reading in a dense matrix) | Higher zoom on each digit, or continuity |
| U8 | 72's "4" numeral; the 65 capacitor value; the RAM RESET pad and mark | A sharper scan |
| U9 | Timing of RAM RESET (how long to hold it) and of power-up with /GAME END already low | A timing model of 92a/92b; not a reading problem |

## Short report

**Established** (from the drawn wiring, not measured):

- Four 5101s, one per decade, on a shared 8-bit address (93, bit k → A_k).
  DI = P-1..P-4. DO → comparator A inputs. No 8216s.
- R/W = 82.3 with R64 to the battery rail. OD = NOT 82.3. CE2 (17) on
  PWR-OK (R43 4.7 k / C4 22 µ / D10 to Vcc), /CE1 (19) grounded.
- #70 recheck: all four bodies read `5101`, not `2101`; the parts lists give
  no RAM type; the 5101 and 2101A share one pinout, so the pins cannot tell
  them apart. The 17/19 conflict is withdrawn (the trace had the pinout
  swapped).
- The RAM supply is a separate rail: Vcc via D9, and the Ni-Cd battery via
  R62 56 Ω (pads HX +, H20 −). "3.6V" is the battery's caption on sheet I.
  Page 7 calls the same battery 2.4 V.
- All 256 slots are kept. Power-up no longer clears them (82 blocked by 92a,
  free run moved to /RAM RESET). The new RAM RESET switch clears them.
- The lamp decode is two 3188 PROMs (PR-01 IC55, PR-02 IC54), addressed by
  BONUS A–D and V2, driving 15 lines through 220 Ω and two PNP commons.
- /GAME END starts the after-game write and search (in place of GAME) and
  triggers 65 → T.R.S (K) when the 10,000 flip-flop 56 is set.

**Still uncertain:** U1–U9 above, chiefly the battery voltage (U3), the lamp mapping (U5, needs PROM dumps) and the D bus
source (U7).

**Not checked:** the search clock (81/9/6/11 259), 72.11 sources, 192 count
and borrow wiring, the 85 cascades, the rank, R, N and flash logic (259s `10`
and `3`, 390 halves, 279 latch, 66, 93 5 → 6), the S-100 block, SP. CONT, the
90 J-K flip-flop and Vs/16 loads, the score counter (F trace I01–I05), and
sheets K and J. No HDL, test or other document was changed.
