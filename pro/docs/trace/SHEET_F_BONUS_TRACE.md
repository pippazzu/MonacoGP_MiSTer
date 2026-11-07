# Pro sheet F — bonus input to score counter

Date: 2026-11-05. Sega 420-0525, Pro Monaco GP, sheet F (PDF page 9), board 96822-P, D-2/5. Limited continuation onto sheet I (PDF page 18) and sheet K (PDF page 20).

## Result and limits

The drawn functional path is `/BONUS POINT` -> a two-input combining gate on F -> a noninverting output buffer -> `/SCORE CP`, F pad A14 -> I pad H16 -> the first half of I IC75, a 74390. The other combining input is the ordinary score NAND's output. The combining symbol has an OR body, bubbles on both inputs and an output bubble: electrically it ANDs the two active-low pulse streams.

**One accepted falling edge at I's score-clock input advances P-1, the lowest decimal stage, by one.** The four traced decades have weights 1, 10, 100 and 1000. There is no extra divide-by-ten or multiplication between F's output and that first decade. K receives the parallel score; it is not inserted into this clock path.

**At logic level, the wiring of N and F gives exactly 200 points per stored bonus: stored count x 200.** IC32 is held clear by /GAME during payout, so the normal score branch cannot merge with or block the bonus pulses. The derivation is below. This is a reading of the drawn logic, not a measurement, and the end-of-game race in U5 remains open. No different arithmetic, such as 200 pulses adding 2000 points, is supported by the counter wiring inspected here.

Several pin numerals and package labels on F are washed out. The functional reading is recorded separately from those uncertainties; this is not a claim that every package pin is now certain. No HDL was changed. No emulators, remake, gameplay account, footage, PROM contents or independent redraw were used to fill a gap.

## Sources, coordinate system and fresh evidence

Pro source: `C:/Users/kakyo/Downloads/promonacogp420-0525_1.pdf`, SHA-256 `9473d6dd84418129f389e7c5becc0f6f7d105611e1d508ff60bbc062a27432f2`.

Fresh upright pypdfium2 renders at **scale 1**: F = 10175 x 6617, I = 10184 x 6617, K = 10200 x 6617 pixels. Boxes below are `(left, top, right, bottom)`, origin top-left, in the corresponding complete render. Crops were read at original resolution/high zoom. Enlarging them does not recover missing scan ink.

Evidence directory: `C:/Users/kakyo/.codex/visualizations/2026/11/03/01a1a260-b7d3-7c90-805a-3bfc2fa52b96/f-bonus/`. Crop IDs are PNG basenames there. Complete renders are `F.png`, `I.png`, `K.png`. Overview images were used for navigation, not pin readings. Images are outside the repository and are not committed.

Original source: `C:/Users/kakyo/Documents/ChatGPT/monacogp/build/pr35-bram/schematics/pages/page26-sheet-F.png`, 10176 x 6624, SHA-256 `c632f2ce8c5fbb369b307036510d8b2662598b4a0b6f27cba8149c0420c2a056`. It is stored upside down: original-board boxes below use its **180-degree-rotated upright view**, saved as `O-F.png`, at native scale. A box converts back to stored coordinates as `(10176-right, 6624-bottom, 10176-left, 6624-top)`.

The supplied original `build/pr35-bram/docs/trace/SHEET_F_TRACE.md` was consulted for its score-clock, extended-play and component tables after reading the Pro crops. Its redraw-derived assignments are not evidence for an unreadable Pro pin.

| Crop ID | Sheet | Box | Evidence |
|---|---|---|---|
| F-bonus | F | (5650, 300, 6500, 2750) | Both incoming score arrows and bonus trunk |
| F-score | F | (5000, 2250, 8050, 2800) | Score gates through A14 |
| F-gate | F | (5600, 2200, 7100, 2700) | Faded normal NAND, combining symbol and buffer |
| F-normal-detail | F | (5650, 2280, 6320, 3070) | Mux-output riser and normal NAND output bend |
| F-normal-to-score | F | (5650, 2320, 6600, 2690) | Normal output -> lower combining input |
| F-bufferbank | F | (6420, 1960, 7010, 2700) | `17 x 6` caption and score buffer 5 -> 6 |
| F-upper | F | (4300, 350, 6400, 1500) | V6/V7 pads, AOI and counter clock |
| F-clock-select | F | (1950, 750, 5700, 1670) | Clock-selection gate, inverter and C54 |
| F-clock-source | F | (1950, 400, 3200, 1100) | /TUNNEL pad and arrow |
| F-clock-return | F | (1800, 850, 4100, 2400) | Return from slip/pool NOR toward selector |
| F-clock-return-low | F | (1700, 2150, 3800, 3350) | Lower end of that return and one-shot Q wires |
| F-slip-labels | F | (850, 2500, 2150, 3450) | /SLIP, /POOL(2), IC99 and timing captions |
| F-slip-pool | F | (1150, 2570, 2750, 3800) | Both IC99 halves and Q-combining gate |
| F-player-strip | F | (1350, 2750, 1800, 6140) | PLAYER trunk to IC99 B inputs |
| F-player-label | F | (850, 5730, 2050, 6150) | PLAYER (G) arrow |
| F-mux | F | (4300, 1350, 6000, 2450) | Divider outputs and selector inversions |
| F-mux-bottom | F | (4800, 2450, 6650, 3200) | 151 input pairs, Y5 and ST7 |
| F-mux-left | F | (3500, 2300, 5850, 3120) | Selector wires and crossings |
| F-reset-source | F | (4550, 1650, 6750, 2400) | IC32 clear loop and ACCE B/C/D inversions |
| F-acc-bus | F | (3500, 1750, 5650, 2150) | Accelerator bit rows |
| F-acc-arrows | F | (5500, 1660, 8100, 2000) | Named ACCE A-D arrows |
| F-enable | F | (5300, 2800, 6650, 5150) | Mux strobe trunk and local conditioning |
| F-enable-low | F | (5200, 4400, 7750, 5200) | Collision/explosion sources of strobe conditioning |
| F-enable-arrow | F | (5600, 2740, 8060, 3000) | Strobe branch, Vcc XOR and ACC1 arrow to G/N |
| F-8000-route | F | (6800, 400, 7750, 3550) | 8000, /EXT.500, EXT.CAR CONT and /SP.IRREG |
| F-score-crossings | F | (6950, 2450, 7300, 2740) | Three crossings of score output: no junction dots |
| F-clear-route | F | (4300, 1100, 6300, 2500) | IC32 clear 2 -> loop -> row near y2035 -> x4760 -> row near y2305; inverters |
| F-clear-left | F | (1700, 2050, 4900, 2600) | Row near y2305 continuing left past the 193 |
| F-game-arrow | F | (700, 2100, 2300, 2500) | `/GAME (A)` arrow at the left end of that row |
| F-acce-rows | F | (3050, 1700, 4100, 2500) | 193 outputs 3/2/6/7 -> their four rows |
| F-acce-names | F | (5800, 1700, 8100, 2300) | Top-to-bottom row names ACCE D, C, B, A |
| F-selectors | F | (4750, 2250, 5750, 3150) | Inverter outputs -> M151 C9, B10, A11 |
| F-acc-label | F | (6600, 2500, 8060, 3000) | `/ACC1 (G)(N)` caption with its overbar |
| I-score | I | (1400, 1800, 3700, 3000) | H16, pull-up, C5, first counter and reset |
| I-chain | I | (2900, 2200, 3800, 3900) | Decade feedback loops, carries and P-1..P-4 |
| K-live-input | K | (1650, 4050, 6550, 5360) | P-1..P-4 arriving from I and input branches |
| O-score | Original F, upright | (5450, 2050, 8850, 3050) | Original single normal-score NAND -> buffer -> A14 |
| O-select | Original F, upright | (2800, 650, 6500, 1950) | Original selector net, without Pro C54 |
| O-clocks | Original F, upright | (4700, 650, 6450, 1650) | Original V6/V7 clock circuit |
| O-slip | Original F, upright | (1000, 2450, 3050, 3400) | Original pool timing capacitor, 15u |
| O-8000 | Original F, upright | (7350, 300, 8050, 3450) | Original 8000 branch toward speed control |

Notation: `nn.p` means ICnn pin p, local to the sheet. `/` transcribes an overbar, not a guessed polarity. A crossing is not connected unless a junction dot is visible. Thick strokes at crossings, scan speckles and gaps are not new junctions. Bends and wire endpoints are followed as drawn. `clear` means a scan reading, not a PCB continuity measurement; `probable` identifies a route or symbol whose missing ink still matters; `uncertain` is not an implementation instruction.

Local aliases avoid inventing package labels:

- **GS**: the normal-score NAND above/left of IC8. Its two inputs and output bubble are visible; its designator and pin numerals are not reliably legible.
- **GB**: the combining gate labelled **8**. Lower input reads **9**, output reads **8**. The upper numeral looks like `11` in places, possibly a damaged `10`; it is **not certified as 10** just because that would fit a standard 7408.
- **M151**: the block marked **151**, below GS. Its package number is washed out. Its printed selector/input/output numbers can still be read.
- **GT**: the two-input gate near (3100, 1000), output **6**, with /TUNNEL at input **5**. Its other input is **4**. The drawing is an OR body with input bubbles, hence NAND. Its package number is uncertain.
- **GSP**: the upward NOR combining the two IC99 Q outputs near (1970, 2700). Package/pin lettering is faint.
- **B17**: the score output buffer, printed 5 -> 6, in the bank captioned `17 x 6`; the package label appears to be **19**. The buffer's input contour is damaged, so identification rests on both the bank caption and the surviving symbol, not a substituted original-board pin assignment.

## End-to-end F trace

Approximate waypoints supplement the exact crop boxes. They locate routes; they are not PCB coordinates. Confidence is per row; pin uncertainty is retained even where the functional route is readable.

| Row | Wire or gate reading | Evidence and crossings | Confidence |
|---|---|---|---|
| F01 | `/BONUS POINT (N)` arrow -> GB upper input | F-bonus -> F-gate/F-score. Descends near x6320 from the top arrow, then bends right near y2580. Several lower segments have lost ink. No junction dot is drawn where it crosses accelerator or sound rows. No pad is printed at the arrow. | Clear label and endpoints; probable continuous route through faded segments; upper pin numeral uncertain |
| F02 | `/SCORE ST (G)` arrow -> GS upper input | F-bonus/F-upper -> F-normal-detail. Separate vertical near x5750 ends on the NAND input near y2385. Intermediate horizontal rows have crossings, not junction dots. | Clear route; GS pin numeral uncertain |
| F03 | M151.Y5 -> GS lower input | F-mux-bottom -> F-normal-detail. Y5 drops, turns right, then rises near x5750 to the lower NAND input. Crossings of the ST7 and sound/control rows do not supply an additional input. The scan loses short pieces around y2475-2530; do not turn those crossings into wired joins. | Probable route; needs better ink at the close crossings to certify pin-level continuity |
| F04 | GS output -> GB lower input 9 | F-normal-to-score/F-gate. Output runs right near y2410 to x6230, then descends and turns right near y2630 into 9. A short part of the vertical is faded; the unrelated horizontal sound row is crossed without a junction dot. | Clear endpoints and bends; probable continuity across faded portion |
| F05 | GB combines the two inputs as AND in positive logic | F-gate/F-bufferbank. OR-shaped body, two input bubbles, output bubble; therefore NOT(NOT upper OR NOT lower). No third input is drawn. | Clear functional symbol; upper pin number uncertain |
| F06 | GB.8 -> B17.5; B17.6 -> A14 `/SCORE CP (I)` | F-score/F-bufferbank. Continuous output row to A14. Bank says `17 x 6`; score section is noninverting/open-collector family. | Clear pin pair and endpoint; probable package label 19 |
| F07 | `8000 (A)` -> downward OR input 10; `/EXT.500 (D)` at BJ -> its input 9; output 8 -> lower three-input NAND, then `/SP.IRREG (H)` | F-8000-route. Other NAND inputs are EXT.CAR CONT from M at BZ and the inverted ACCE D row. The 8000/OR-output/EXT.CAR CONT verticals cross `/SCORE CP` without junction dots: F-score-crossings. `/EXT.500` also has an arrow toward H. | Clear functional route and absence of score junction; some gate package lettering faint |
| F08 | V6 from E at B12 -> AOI 79.2; V7 from E at BN -> 79.4 | F-upper/F-clock-select. The two clock rows have separate dotted branches to the other 50/2 section. They are not joined at their crossing. | Clear |
| F09 | GT.6 -> 79.3 and inverter -> 79.5; 79.6 -> 32.CP1 | F-clock-select/F-mux. GT output runs right near y1010, turns down near x4840; visible split drives the direct input and the inverter. The inverter's package/pin caption is faded. AOI marked 50/2; divider marked 393/2. | Clear functional route; inverter identity uncertain |
| F10 | GT.5 = `/TUNNEL`, pad BF from D, also arrow to G; GT.4 = GSP output | F-clock-source, F-clock-return, F-clock-return-low. The latter route rises near x2175 and turns right near y1040. It passes beside/crosses /SLIPZONE; it is **not** a tap on /SLIPZONE. | Clear endpoints and separate trunk; GSP pin/designator uncertain |
| F11 | GSP inputs = IC99 Q13 and Q5, from the /SLIP and /POOL(2) one-shots | F-slip-labels/F-slip-pool/F-clock-return-low. Q13 runs right to one NOR input; lower Q runs right and up to the other. Q and /Q rows are separate. The lower Q numeral is faint, but standard 123 Q5 agrees with the symbol; it is not read as Q4. | Clear source halves and NOR function; lower numeral less clear |
| F12 | `/SLIP (D)` at CA -> IC99 A1; `/POOL(2) (D)` -> IC99 A9. B2/B10 share PLAYER from G | F-slip-labels -> F-player-strip -> F-player-label. Dot at the B10 branch; the /POOL input crosses the B trunk without a joining dot. The Pro pool pad caption is unreadable in this scan; do not import original CM. | Clear labels, input halves and PLAYER route; pool pad uncertain |
| F13 | IC32 QA3, QB4, QC5, QD6 -> M151 data pairs (0,1), (2,3), (4,5), (6,7) | F-mux/F-mux-bottom. Each vertical has its own dot and bent paired lead. Printed mux data pins: 4/3, 2/1, 15/14, 13/12 respectively. | Clear |
| F14a | `/GAME (A)` -> IC32 clear 2 | F-game-arrow -> F-clear-left -> F-clear-route. The row near y2305 runs right from the arrow, past a branch down toward the 193's clear, to x4760, rises to the row near y2035, runs right to x5580, rises to the loop above IC32 and enters clear 2. It crosses the four ACCE rows with no junction dots. | Clear route; the short 193 clear branch is faded |
| F14b | ACCE B/C/D -> inversions -> M151 selectors A11/B10/C9 | F-acce-rows -> F-reset-source -> F-selectors, names from F-acce-names. Top to bottom the rows are D (193.7), C (193.6), B (193.2), A (193.3). D enters an inverter (3 -> 4) whose output feeds C9 and a second inverter (5 -> 6) that drives the ACCE D arrows. C enters an inverter (13 -> 12) to B10; B enters an inverter (ending at 2) to A11. ACCE A has no tap here. | Clear bit roles and selector pins; inverter package numerals uncertain |
| F15 | M151.ST7 -> local conditioning trunk; its branch feeds a Vcc XOR whose output is labelled `/ACC1` toward G and N | F-mux-bottom/F-enable/F-enable-arrow/F-acc-label. The strobe is not an additional bonus-gate input. The overbar is visible on F, matching N's incoming /ACC1. | Clear |
| F16 | The strobe-conditioning trunk continues down to a Vcc XOR; that XOR's other input comes from a gate combining latch 37.Q and the upper Q output of flip-flop 44, also labelled EXPLO.ST toward G | F-enable -> F-enable-low. Stops at the named explosion-state signal and local latch, rather than deriving collision/game rules. Gate lettering/output contour is damaged. | Probable route; upstream gate identity/polarity not certified |

F12's one-shot clear wiring and F16's collision conditioning are control boundaries, not extra payout inputs. Their details must not be completed from the original board's trace. The Boolean equation below uses the actual voltage level at M151.Y5 and does not depend on guessing those controls.

## Boolean expression and pulse sources

Let:

- `B` = voltage level on the wire labelled `/BONUS POINT`;
- `S` = voltage level on `/SCORE ST`;
- `Y` = M151 pin 5, its noninverting selected-data output;
- `N = NOT(S AND Y)` = GS output;
- `C` = voltage level on `/SCORE CP` at A14, ignoring propagation and analogue edge shape.

Reading the symbols in F02-F06 gives:

**`C = B AND NOT(S AND Y)`**

Equivalently the active-low assertion is **`NOT C = (NOT B) OR (S AND Y)`**. This is a Boolean reading of the drawn gates; F03/F04's scan gaps and the unreadable package/pin details remain explicit. It is not a verified timing model.

For the normal clock source, let `T` be GT.6. The shown 7450 section gives `clock32 = NOT((V6 AND T) OR (V7 AND NOT T))`. IC32 divides that clock into QA..QD. M151 selects the paired data inputs using the inverted ACCE B, C and D bits. Its strobe can suppress Y. While /GAME is high, IC32 is held clear, every M151 data input is low and Y is low whatever the selection or strobe, so N is high. The GT selector is controlled by /TUNNEL and the combined slip/pool one-shot outputs, not directly by 8000.

| Path or event | Condition producing an asserted score output | Evidence | Confidence |
|---|---|---|---|
| Normal scoring | With B high, S AND Y going from 0 to 1 makes C fall. Changes in the S gate can also make an edge if Y is already high. | F02-F04, F08-F16 | Functional reading supported; faded routes retained as probable |
| Bonus | With the normal NAND output N high, B falling makes C fall; it bypasses the M151 selection and the S gate. | F01, F05, F06 | Supported by drawn combining symbol; upper pin numeral unresolved |
| 8000 | No independent 8000-to-score pulse branch is drawn in this path. Its trace ends in /SP.IRREG control, not on the score combining inputs. A downstream indirect effect through other sheets is outside this trace. | F07; F-score-crossings | Clear within inspected F path |
| Simultaneous/overlapping sources | C remains low for the union of the low intervals of B and N. One source falling while C is already low produces no additional falling edge. | F05 Boolean equation | Clear logical consequence; actual overlap not measured |
| Selection/reset changes | A change of mux select, strobe, source selection or counter clear can change Y. The drawing does not provide edge arbitration or a pulse queue. | F08-F16 | Clear structural possibility; no rate or glitch count calculated |

## Filtering and pulse shaping

| Element | As drawn and relevance | Evidence | Confidence |
|---|---|---|---|
| F C54 | **470 pF**, GT output to ground, on the control of the V6/V7 clock selector. It loads that control net; no delay or rejected-pulse width is calculated. | F-clock-select | Clear |
| F IC99 /SLIP timing | C35 **10 uF**, between timing pins 14/15, positive toward 15; R21 to Vcc. A **47K** value is readable, with an additional overprinted annotation above it. The latter is not resolved into a second value. | F-slip-labels/F-slip-pool | Clear C/value/topology; resistor annotation uncertain |
| F IC99 /POOL(2) timing | C32 **22 uF** between timing pins 6/7, positive toward 7; resistor to Vcc marked **47K**. Resistor designator is washed out. | F-slip-labels/F-slip-pool | Clear nominal values and topology; designator uncertain |
| F IC99 and associated clear node | One-shots condition the clock-selection control through GSP; they do not stretch each /BONUS POINT pulse. C28 is visible among their control wires, but its value and exact attachment are not certified here. | F-slip-pool/F-clock-return-low | Clear one-shot role; C28 and full clear fanout uncertain |
| F output stage | No capacitor, monostable, synchronizer or event counter is drawn between GB and the A14 output buffer. Its combinational merging cannot preserve two overlapping events as two counts. | F-score/F-bufferbank | Clear within this bounded route |
| I input pull-up | H16 has a **1K** pull-up, RA2 connection labelled **9**, to Vcc. | I-score | Clear |
| I C5 | **680 pF**, score-clock node to ground, immediately before the first IC75 clock input. Along with the pull-up and output driver it affects the waveform; a narrow pulse cannot be certified as accepted from a static drawing. | I-score | Clear |
| Nearby I 1000p | **1000 pF** is on the IC66 output beside the counter bus, not on the H16 clock node. It must not be added to C5 as though those wires were joined. | I-score/I-chain | Clear distinct nodes |

There are no basis here for numerical RC delays, one-shot durations, pulse-loss percentages or claims that pulses actually overlap. Those need unambiguous component variants, driver/load information and timing evidence. The drawing establishes where pulses can be combined or conditioned.

## I: the counter receiving the pulses; bounded K check

| Row | Reading and consequence | Evidence | Confidence |
|---|---|---|---|
| I01 | `/SCORE CP (F)` at H16 runs right, then down to the top clock terminal of the first IC75 half, marked **390**. Pull-up and C5 join this same wire with dots. | I-score | Clear wire and device type; the top clock pin numeral itself is absent/faint |
| I02 | First IC75 half prints **3,4** together on its QA output/feedback row, then **5**, **6**, **7** on the other outputs. These go to P-1A/B/C/D. Thus QA3 feeds CKB4, making this a BCD decade. The incoming top clock is CKA1 by the 74390 pinout, explicitly a pinout identification rather than a newly legible numeral. | I-score/I-chain; TI 390 pinout | Clear feedback and P-1 mapping; clock numeral supplied by device identification |
| I03 | IC75.7 runs down/left to IC75.15, the next half's clock. That half prints **13,12** together, then **11,10,9**, giving P-2A/B/C/D. | I-chain | Clear |
| I04 | IC75.9 -> IC84.1; IC84.3 -> 4; IC84.7 -> 15; IC84.13 -> 12. IC84 output groups are P-3 and P-4. | I-chain | Clear |
| I05 | IC75 clear 2 and clear 14, and the corresponding IC84 clears, share the separate reset trunk. It comes from I gate 91.3; it is not a K clock return. Counting assumes this clear is inactive. /COIN & TEST from A at HV is one gate input. | I-score/I-chain | Clear counter clear route and named input; reset-control network not fully transcribed |
| K01 | I's P-1A..D, P-2A..D, P-3A..D and P-4A..D appear as inputs on K. Dotted branches go to parallel comparison and latch circuitry. They are data values, not a replacement score clock. | K-live-input; I-score/I-chain | Clear input bus and branch roles |
| K02 | No K signal enters the H16-to-first-clock wire or the three carry links above. The I counter drawing shows those wires end to end. Thus K cannot change the increment per accepted edge through this route. | I-score/I-chain, checked against K's input interface | Clear for this bounded counter route; not an audit of all K behavior |

For the inspected counter chain, `Q = P1 + 10*P2 + 100*P3 + 1000*P4`. A valid falling edge at the first clock, with clears inactive, increments Q by **1**, with decimal carry. P-1 is therefore the **ones decade**, not tens or hundreds. The four-decade chain wraps at its own capacity; this trace does not reconstruct a fifth display position or any overflow indication.

The K check stops at the score-data interface and its absence from the counter clock route. **SUPER RACER SCORE, its storage/comparison operation, and the score memory have not been transcribed.** No claim that all K circuitry is passive or irrelevant to every game operation is made.

Device checks: [TI 74390/74393](https://www.ti.com/lit/ds/symlink/sn74ls390.pdf) supplies the CKA/CKB/QA/QD mapping, decade connection and falling-edge counting; [TI 74151](https://www.ti.com/lit/ds/symlink/sn74ls151.pdf) supplies Y5, ST7 and select/data pin meanings; [TI 7450](https://www.ti.com.cn/cn/lit/gpn/SN5450) checks the AOI function; [TI 7417](https://www.ti.com/lit/ds/symlink/sn7417.pdf) checks the noninverting open-collector buffer. These references interpret readable device captions; they do not repair faded wire/pin readings.

## Comparison with original Monaco GP — this path only

The comparison is by function and net. Reused IC numbers are not proof of equivalence: in particular, original F IC8 is the normal NAND, whereas Pro's clearly labelled IC8 is the added combining symbol. Only differences supported in this score path and its inspected source-conditioning branches are listed.

| Function/net | Original scan | Pro scan | Evidence | Confidence |
|---|---|---|---|---|
| Bonus input | No /BONUS POINT source at the score-output gate | Adds `/BONUS POINT (N)` as a separate combining input | O-score; F-bonus/F-score | Clear addition; Pro upper pin uncertain |
| Output combination | Normal-score NAND goes directly to noninverting buffer, then A14 | Normal-score NAND goes to a further AND with /BONUS POINT, then buffer and A14 | O-score; F-normal-to-score/F-bufferbank | Clear added functional stage; GS identity and short Pro wire gaps remain uncertain |
| V6/V7 selector-control loading | No shunt capacitor is drawn on the corresponding NAND-output selector net | C54 470p to ground | O-select; F-clock-select | Clear drawing difference; not a statement about undocumented PCB parts |
| Pool one-shot timing | Timing capacitor marked **15u**, resistor 47K | Timing capacitor C32 marked **22u**, resistor 47K | O-slip; F-slip-labels | Clear nominal capacitor difference; Pro resistor designator unreadable |
| Existing ACC1 interface | Arrow goes to G | Arrow names G and the added sheet N | O-score; F-enable-arrow | Clear added destination; Pro caption overbar uncertain |

The score divider's clear is /GAME on both boards (Pro IC32.2, original IC5.2). No change to the basic V6/V7-divider-mux choice or a new direct 8000 score source is demonstrated by this bounded comparison. This is **not** an assertion that the remainder of Pro F, its collision circuitry, or all source timing is unchanged. Unreadable Pro details have not been filled from the original trace.

## Hypothesis: 200 pulses and one stored bonus

There are two distinct claims:

1. **Unit conversion:** a distinct valid /BONUS POINT low pulse, while GS output is high, passes the combining gate and buffer as one falling score edge. I adds one count. Therefore **200 such accepted edges x 1 point/edge = 200 points**. The traced F/I wiring supports this, subject to the recorded scan gaps and normal electrical acceptance.
2. **Whole payout:** the drawn logic of N and F gives **200 accepted edges per stored bonus**:
   - **Normal branch:** IC94's Q, which opens the pulse gate, can only rise when /GAME rises (`SHEET_N_TRACE.md`, 94.11). While /GAME is high, IC32 is clear, Y is low and N is high (F14a). So no normal pulse can merge with or block a bonus pulse during payout.
   - **One signal, two uses:** 101.11 feeds both IP.11 and 81.12. Each high pulse there makes one falling edge on /BONUS POINT, hence one point, and then one falling clock at 81.12. A first pulse cut short by the gate opening still counts once on both.
   - **Start phase:** IC81 and IC80 are cleared by 95.6 and return to zero after each 200 pulses, so every payout starts at zero.
   - **Step per 200:** the 200th falling clock makes 80.9 fall. Through IC72 and IC108, 140.14 rises and IC140, counting down because /GAME is high, steps once.
   - **Stop:** when IC140 reaches zero, 140.12 goes high and 102.10 clears IC94, just after the falling clock that ended the last pulse. No extra pulse follows.

   This is not a multiplier in I: the total is stored count x 200, delivered as individual score clocks. The result is a reading of the drawn logic. It has not been measured or simulated, and it assumes the faded routes in U2 and the part functions read above.

## Remaining uncertainties and what would settle them

| Item | Still uncertain | Needed evidence | Confidence |
|---|---|---|---|
| U1 | GB upper pin numeral: damaged 10 versus apparent 11; GS package/pins; B17 package label; M151 package label | A sharper original sheet F scan or continuity/package inspection of this board revision. Do not force these to the original board's numbers.  uncertain |
| U2 | Short faded stretches on the /BONUS POINT trunk, M151.Y-to-GS route and GS-to-GB bend | Higher quality scan of F-bonus/F-normal-detail/F-normal-to-score, or PCB continuity. The functional route is probable, not a certified complete pin netlist.  uncertain |
| U3 | Pool pad caption; GSP package/pins; exact IC99 clear fanout and C28 attachment/value; R21 overprint and pool resistor designator | Better crops from a higher quality source or PCB/component inspection. Nominal 10u/22u and the readable 47K marks do not settle every annotation.  uncertain |
| U4 | Full polarity/identity of upstream strobe conditioning | Sharper F-enable-low/F-enable-arrow and a matching receiving-sheet/PCB check. The score equation deliberately uses measured node Y instead of guessing this logic.  uncertain |
| U5 | Game end with exactly 0 or 15 stored bonuses. /GAME rising clocks IC94, while the same edge through R34 flips IC140's direction, which changes 140.12 and so IC94's clear. With 0 a brief pulse may escape; with 15 the clear may still be active at the clock, skipping the payout. The drawing does not settle this order | Measured behaviour of a real board, or a deliberate, documented choice in the core.  uncertain |
| U6 | Actual analogue pulse acceptance at the output buffer, 1K/C5 node and counter | Device variants, relevant loading and measured waveforms or a justified electrical model. No RC threshold was inferred.  uncertain |

## New signals in this bounded path

| Signal | Direction/pad | Difference from original | Confidence/evidence |
|---|---|---|---|
| `/BONUS POINT` | N -> F; no pad printed on F arrow | New named input to the score combiner | Clear label; F01 |
| Combined active-low normal/bonus node | GB.8 -> B17.5, internal F, no pad | New internal gate result. `/SCORE CP` at A14 retains its existing external name. | Clear functional addition; F05/F06 |
| ACC1 connection to N | F -> N, no pad on arrow | Additional destination of an existing signal, **not** a new signal name | Clear destination; F15 |

Within the traced F score-combining path there are no other demonstrated new named inputs. 8000, /EXT.500, /SCORE ST, V6/V7 and the accelerator/source controls already exist on the original. This list does not inventory new memory, bonus-display or other interfaces elsewhere on I/K/N.

## Changes the Monaco core's F and I logic would need — words only

- **F score output:** accept N's /BONUS POINT signal and reproduce the extra AND of the active-low normal and bonus outputs before the output buffer. Keep the normal NAND's /SCORE ST qualification on the normal branch. Do not put that same qualification around the bonus branch. Do not add a pulse queue or add two counts for an overlapping low interval unless deliberately departing from the schematic.
- **F source conditioning:** account for the documented C54 selector-control load and the pool timing-capacitor change when implementing the Pro timing model. First resolve the uncertain component annotations and control connections. The scan does not justify an invented filter duration, a direct 8000-point adder or a guessed normal-scoring rule.
- **I score entry:** preserve the ones-decade clock entry, decimal feedback and carries. Each accepted falling edge of the combined /SCORE CP advances the existing counter by one. No bonus-specific times-ten stage or direct add-200 operation is called for here. Any implementation that separately blocks score-clock edges outside active play would have to be checked against the actual reset/gating wires so it does not suppress the new bonus input.
- **I electrical behavior:** if pulse shaping is modeled, place the 1K pull-up/C5 680p behavior at the shared clock entry and respect the clear input. Do not silently treat arbitrarily narrow simulated pulses as hardware-valid. This trace supplies topology and nominal values, not a fitted pulse filter.
- **Scope:** these are circuit requirements, not a claim that the current HDL has been audited. No HDL, tests, memory implementation or SUPER RACER SCORE logic was changed as part of this documentation task.
