# Sheet B — text PROM and road-motion counters

Source: Sega **Monaco GP (420-0358)**, PDF page **29**, drawing **B**, board **96578-P**, **D-1/5**, “IC BOARD ASS’Y, B”. Transcribed from the supplied `sheets/page29-sheet-B.png`, **10160 × 6624** pixels, upright. The attachment’s `START_HERE.md` defines the scope and output format; `reference/docs/trace/SHEET_G_PLAYER.md` supplies the organizational model. This document transcribes **sheet B only**.

**Status:** a first-pass, whole-sheet transcription for review, **not an implementation-ready or independently reviewed netlist**. The drawn functional sections are covered below; uncertain labels, possible pin-number discrepancies and terminals not drawn are explicitly retained. No ROM contents, emulator, other FPGA implementation or inferred gameplay were used to fill gaps. No circuit code or simulation was produced.

Source PNG SHA-256: `27d1783dd4b8d406728167fb474450ecd7994c96e4ce595dfe70144b183b3c27`.

## Review by Claude, 21 October 2026

This trace was written by ChatGPT from the handover package and reviewed by
Claude against the same image (manual 420-0358, PDF page 29, same
SHA-256). The review re-read every section at block level, the gate bodies,
the tie-offs of IC111/IC83/IC84, the decoder outputs and their off-sheet
labels, and two wire crossings on the IC63 output (no junction; ink thickness
6.4 and 5.6 px against 9.4 to 9.8 px for drawn dots). It did not re-read every
pin numeral. Corrections, each marked "[Review ...]" in place:

1. **IC111 pin 10 is tied to Vcc, not GND.** With pins 3 and 6 at GND and 10
   and 13 at Vcc, IC111 selects between the SP bits and the fixed value
   `1100`. Wiring-derived consequence, assuming the 74161/74107 behaviour
   (IC57 toggling as the low byte leaves FF): the MH period is 512 minus the
   load value. With the fixed value the load is 0x38 and the period 456 pixel
   clocks, exactly one line; with the SP bits it is
   `0x20 + 16·SP.D + 8·SP.C + 4·SP.B + 2·SP.A`, a period of 450 to 480.
   This also settles the open pin-10 question in Claude's earlier sheet B
   notes, which had the labels of the SP.D lead and the pin-10 lead swapped.
2. **IC52, IC95 and IC87 are drawn with OR bodies**, with bubbles on both
   inputs and the output, so they are AND functions (the trace had AND bodies
   and OR). IC70 and UG1 are AND bodies with bubbles everywhere (OR), and IC72
   is an OR body with input bubbles only (NAND), as the trace says.
3. **The IC54 off-sheet arrows V-(1) to V-(5) are all labelled M** (V-(4)
   also D); the trace had H for V-(2), V-(4) and V-(5). The letter on V-(2)
   is less clear than the others.

Readings of the trace's uncertain captions, from the same crops: the IC70
lower output numeral reads 8 (U4); the separators read as `&`, "EX. & GAME
OVER" and "COIN & START" (U5); the D-sheet input reads "TUNNEL & BRIDGE",
written `TUNNEL& BR.DGE` (U9); the A-sheet input reads "INI RESET" (U10);
the IC111 select caption reads `/(V-CA × V8)` under one overbar (U7,
resolved with the maintainer's reading of "V8"; the middle mark is the `A` of `CA`).
Sheet E confirms it: IC110 there is a NAND, pin 1 V-CA and pin 2 V8 in,
pin 3 out to connector FS, labelled `/V-CA×V8` with destination B (a second
arrow with the same label goes to H). Evidence crops on
manual 420-0358, PDF page 32, which is stored upside down, so view
them turned 180°: `(4100,1100,4900,2900)` for IC110 and its output arrows,
`(4300,2500,4900,3050)` for the circled B and H destination letters.

Everything else checked agrees with the scan.

## Cross-check with an independent redraw, 22 October 2026

stonedDiscord's KiCad redraw of the boards (github.com/stonedDiscord/MonacoGP,
no licence, so used here only for comparison and not copied) has a netlist for
board 96578, whose U numbers are the IC numbers. Of this trace's pin-to-pin
links, 151 agree with it and none conflict. It also agrees with the review
corrections above (IC111 pin 10 at Vcc; IC52, IC87, IC95 are 74LS08) and with
the standard-pinout readings of U3 (IC55 pin 9), U6 (IC111 is a 74LS157) and
U8 (IC54 output 7 is pin 9). It shows the unnumbered gate UG1 as the fourth
gate of IC70, pins 1 and 2 in, 3 out.

Two of the trace's input labels were wrong; both were checked on the sheet E
scan, where each signal starts:

- **IC85.10 and IC91.10 are /V8, not /V0.** Sheet E IC114 inverts the V8
  wire (the IC109 flip-flop with J and K at Vcc, clocked by V-CA) and sends
  pin 2 out through connector FN, with an arrow labelled for sheet B. In the
  redraw, V0 (IC102.14) goes only to IC23, IC30 and IC51. The drawn subscript
  is the same glyph as in `/V-CA × V8`.
- **IC71.9 is /H8, not /H4.** On sheet B the subscript is covered by the IC72
  output wire. Sheet E sends IC116 pin 2, the /Q of the H8 flip-flop, through
  connector FB, with an arrow labelled for sheet B.

The redraw itself has one error found here: it joins V8 and H8 into one net,
named H8, which is why its IC111 select net is named `V-CAXVb` while its
IC110.2 sits on H8. The sheet E scan shows IC110.2 on V8.

## Reading conventions

- Coordinates are `(x0, y0, x1, y1)` in the original PNG, origin at its upper left; the right/bottom crop edges are exclusive. Overview reduction was used only to locate sections. Pin and wire readings were made from the crops listed below; small ambiguous marks were also viewed at 2× nearest-neighbour scale.
- `/NAME` transcribes an overbar. Subscripts and ditto marks are expanded in prose, while uncertain spelling and punctuation are preserved in the interface table. A slash does not by itself establish the signal’s source circuitry or timing.
- A dot is a junction; crossings without a distinct dot are separate. The counter load/clock crossings were compared with adjacent definite dots, rather than joined because their strokes overlap.
- Gate functions below follow the **drawn body and inversion bubbles**, not the chip number. AND bodies with input and output bubbles implement OR; AND bodies with input bubbles only implement NOR; an OR body with input bubbles only implements NAND.
- The drawing often prints just `161`, `157`, `151`, `42`, `74/2`, `107/2` or `279/4`. These are recorded literally, with the corresponding standard 74xx pinout used to check terminal numbers. Small gates generally have an IC designator but **no printed part type**. A compatible standard pinout is identified as a comparison, not a recovered part marking or logic-family suffix.
- **clear** means the stated mark or route is legible in this scan. It is not a claim that the original drawing or the circuit is correct. **uncertain** means the row contains a reading that must not be used as a settled fact; see “Unresolved”.
- **not drawn** is distinct from tied high, tied low or proven unconnected. No floating-TTL default is assigned. Power terminals omitted from a symbol are not silently connected to the page’s other Vcc/GND symbols.
- Names `T_H`, `T_MSG`, `T_COIN`, `T_COMB`, `TXT`, `VSEL`, `R1`, `R2`, `Q1`, `Q2`, `D1`…`D7`, and `UG1` are **local transcription aliases**, not labels printed on the schematic. `ICn.p` means pin p of ICn.

## Signal path in brief

1. **Text:** PR133/IC64 has nine drawn address connections, eight outputs directly wired to the eight data inputs of IC63 (`151`), and four drawn enable connections. H0…H2 select a bit through IC63. IC71, IC55, IC52 and IC70 qualify the text path; two outputs leave for sheet C. The bottom terminal of IC63 is pin 6, its complemented data output; the right-hand bubbled terminal is pin 7, its strobe **input**. Their placement on the page must not be mistaken for a swap of pin functions.
2. **MH:** IC118 and IC103 (`161`) form a cascaded eight-bit counter clocked by `7M (E)`. IC57 (`107/2`) extends the path with the output labelled MH8. IC111 selects four of the parallel-load bits; IC55 generates the shared active-low load. The four incoming SP bits also feed a gate used in the lower section.
3. **Vertical decode:** IC54 (`42`) decodes three E-sheet counter bits with its fourth input tied low. Its active-low outputs go to other sheets, the IC68 latch, and the lower asynchronous preset/clear logic. IC68 feeds the text qualifier.
4. **M1V and M2V:** the two lower counter pairs share `/HS (E)` as clock and `/V8 (E)` [review 22 Oct: corrected from `/V0`, see the cross-check section] as low-counter enable. Each high-counter carry is inverted into that pair’s load net. IC83 and IC84 select each pair’s low-nibble load values. Both halves of IC69 (`74/2`) are drawn with asynchronous preset/clear control and complementary outputs; their D/clock connections are **not drawn**. Do not assume ordinary clocked D-flop operation here.
5. **Common selection:** SP.C/SP.D, the D-sheet tunnel/bridge-labelled input, Vs/2, Vs/4 and the A-sheet reset-labelled input feed IC110, IC95, IC94 and IC87. IC87’s output selects **both** lower multiplexers. This select net is separate from each pair’s carry-derived load net.

These are wiring descriptions. They do not establish absolute screen position, road shape, game-state sequencing, pulse widths or a cycle-accurate counter model.

## Crops and positions

All boxes refer to `sheets/page29-sheet-B.png`; crop identifiers below are reproducible without needing companion image files. The main reading crops are listed first; narrower follow-up crops document crossings and doubtful marks.

| Crop ID | Pixel box | Confidence |
| --- | --- | --- |
| text_prom | `2350, 550, 3650, 1640` | clear |
| text_gates | `1130, 1400, 4300, 2300` | clear |
| text_left | `1120, 1000, 2950, 2250` | clear |
| text_right | `2750, 1260, 4300, 2200` | clear |
| motion_h | `5150, 850, 7150, 2190` | clear |
| h_left | `4420, 1550, 6220, 2950` | clear |
| h_right | `6200, 1430, 7860, 2510` | clear |
| v_left_top | `4650, 3600, 6600, 4780` | clear |
| v_right_top | `6560, 3600, 8560, 4790` | clear |
| v_left_bottom | `4850, 4750, 6730, 5970` | clear |
| v_right_bottom | `6670, 4750, 8610, 6100` | clear |
| v_decode | `2300, 4900, 4390, 6240` | clear |
| text_crossings | `1650, 1000, 2100, 2240` | clear |
| text_coin_labels | `1100, 1700, 1800, 1900` | clear |
| common_control | `4390, 3640, 5350, 5300` | clear |
| decoder_outputs | `3500, 4300, 4380, 5900` | clear |
| mid_lower_wires | `4310, 5470, 6170, 6220` | clear |
| right_lower_wires | `6110, 5470, 7970, 6220` | clear |
| text_input_detail | `900, 1670, 1650, 1940` | clear |
| h_sp_gate | `4850, 2540, 5180, 3140` | clear |
| left_latch_detail | `5000, 5430, 6080, 5980` | clear |
| right_latch_detail | `6850, 5430, 7750, 6080` | clear |
| text_labels | `3400, 1850, 4360, 2200` | clear |
| reload_labels | `8060, 4770, 9000, 5100` | clear |
| h_labels | `7430, 2150, 8000, 2400` | clear |
| prom_type | `2810, 590, 3300, 790` | clear |
| gate70_detail | `3440, 1310, 3760, 1550` | clear |
| gate70_outputs | `3410, 1860, 3710, 2160` | clear |
| decoder_wires_left | `3850, 5340, 5370, 6110` | clear |
| h_mux_detail | `5370, 2200, 6060, 2510` | clear |
| v_wires_upper | `3820, 5400, 4980, 5840` | clear |
| v_top_complete | `5180, 4330, 6630, 4960` | clear |
| v_top_right_complete | `7040, 4350, 8630, 4980` | clear |
| h_carry_loop | `5820, 1420, 7350, 2200` | clear |
| control_mid_route | `4900, 2920, 5220, 3890` | clear |
| reload_mid | `5750, 4580, 7350, 5360` | clear |
| reload_end | `7240, 4630, 8870, 5260` | clear |
| top_crossing_strips | `2600, 790, 2940, 1610` | clear |
| decoder_inputs | `2620, 5300, 3560, 6150` | clear |
| counter_outputs | `5390, 850, 6550, 1400` | clear |
| load_clock_crossing | `5940, 4790, 6070, 5010` | clear |
| load_clock_crossing2 | `6960, 4780, 7110, 5030` | clear |
| type_mux63 | `2860, 1290, 3310, 1550` | clear |
| type_gate55 | `6740, 2010, 7070, 2180` | clear |
| h_select_label | `4400, 2230, 4980, 2440` | clear |
| tunnel_label | `4350, 3660, 4910, 3850` | clear |
| title | `900, 380, 2510, 880` | clear |
| text_pin_numbers | `2830, 750, 3280, 1350` | clear |
| v_reset_label | `4390, 5080, 5010, 5320` | clear |
| h_eight_output | `6870, 840, 7300, 1570` | clear |
| latch_to_text | `1750, 2200, 2060, 5060` | clear |
| v_inputs_long | `2660, 1500, 2870, 5500` | clear |
| decoder_pin_detail | `3260, 5360, 3760, 5900` | clear |
| h_gate_number | `5000, 2840, 5140, 3010` | clear |
| h8_label_detail | `1400, 2010, 1770, 2150` | clear |
| prom_high_enable_detail | `3180, 810, 3580, 1190` | clear |
| counter_enable_detail | `5290, 1570, 6300, 1920` | clear |

## Pin tables — text section

Main evidence: `text_prom`, `text_left`, `text_right`, `text_crossings`, `text_input_detail`, `text_pin_numbers`, `type_mux63`, `gate70_detail`, `gate70_outputs` and `text_labels`. The long latch connection is also checked in `latch_to_text` and `v_decode`.

### IC64 — PR133

Printed IC number `64`, PROM designation `PR-133`; the device marking appears `µPB-425D` but its prefix is uncertain (U1). The standard 7641-style terminal arrangement is a comparison only; it is not substituted for that marking. The words inside the PROM are “EXTENDED PLAY”, “START”, “GAME OVER” and “DEPOSIT COIN”.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 8 | V1 (E) → PROM address terminal. | clear |
| 7 | V2 (E) → address. | clear |
| 6 | V3 (E) → address. | clear |
| 5 | V4 (E) → address; its source wire also continues downward to the lower logic. | clear |
| 4 | V5 (E) → address; branch continues to IC54.15. | clear |
| 3 | V6 (E) → address; branch continues to IC54.14. | clear |
| 2 | H3 (E) → address. | clear |
| 1 | H8 (E), the same wire as IC55.4; separate from the long IC68.Q wire. | clear |
| 23 | /COIN IN from (A), connector ED; also forwarded to (M), (D). | clear |
| 9 → IC63.4 | First drawn data connection; D0 in the standard compatible PROM pinout. | clear |
| 10 → IC63.3 | Second data connection; D1. | clear |
| 11 → IC63.2 | Third data connection; D2. | clear |
| 13 → IC63.1 | Fourth data connection; D3. | clear |
| 14 → IC63.15 | Fifth data connection; D4. | clear |
| 15 → IC63.14 | Sixth data connection; D5. | clear |
| 16 → IC63.13 | Seventh data connection; D6. | clear |
| 17 → IC63.12 | Eighth data connection; D7. | clear |
| 18, 19 | Both drawn to Vcc. These are enable-position terminals in the compatible PROM pinout, not a drawing of the package’s power pin. | clear |
| 20, 21 | Both bubbled terminals drawn to GND. | clear |
| 12, 22, 24 | not drawn; no physical package connection asserted. | clear |

### IC63 — `151`

Standard 74151 comparison: data pins 4,3,2,1,15,14,13,12; select A/B/C = 11/10/9; strobe 7; complemented output 6. The small solid mark at the upper right is not treated as an additional connected pin.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 4, 3, 2, 1, 15, 14, 13, 12 | Eight data inputs from IC64.9,10,11,13,14,15,16,17 respectively. | clear |
| 11 | H0 (E), select A. | clear |
| 10 | H1 (E), select B. | clear |
| 9 | H2 (E), select C. | clear |
| 7, right-hand bubble | Strobe input from IC70.6. | clear |
| 6, bottom bubble | TXT, complemented selected-data output → IC70.12 and IC70.10. | clear |
| 5 | Non-complemented output: no numbered wire drawn. | clear |
| 8, 16 | Package GND/Vcc: not drawn. | clear |

### IC71 — type not printed

Two four-input AND bodies with output bubbles: NAND functions. Pin groups match the standard 7420 comparison.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 1 | H4 (E), first NAND input. | clear |
| 4 | H6 (E), first NAND input. | clear |
| 2 | H7 (E), first NAND input. | clear |
| 5 | IC68.13 (Q), routed around the left/bottom of the text section. | clear |
| 6 | T_H = NAND of the preceding four inputs → IC70.4. | clear |
| 12 | H5 (E), second NAND input. | clear |
| 9 | /H8 (E), second NAND input [review 22 Oct: corrected from `/H4`; the subscript is covered by the IC72 output wire, and sheet E sends /H8 from IC116.2 to B via connector FB] (U2). | clear |
| 13 | IC72.6. | clear |
| 10 | Vs/16 (H), connector E19; same node forwarded to (M). | clear |
| 8 | T_MSG → IC52.5 and IC70.13. | clear |
| 3, 11 | not drawn. | clear |
| 7, 14 | Package GND/Vcc: not drawn. | clear |

### IC72 — type not printed

OR body with bubbles on both inputs, no output inversion bubble: NAND by De Morgan. Pin group 4,5 → 6 is compatible with a 7400 NAND.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 4 | /EX.SIGNAL (A), connector F1. | clear |
| 5 | /COIN IN (A), connector E1; the two left input captions have separate overbars. | clear |
| 6 | Output → IC71.13. | clear |
| Other gates; package power | not drawn in the sheet-B area; no unused-input ties inferred. | clear |

### IC55 — type not printed

Three-input NAND symbols in two separated parts of the sheet. The normal pin groups are compatible with a 7410; one MH-group input number is doubtful (U3).

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 3 | /GAME (A), connector E6; forwarded to (M). | clear |
| 4 | H8 (E); also IC64.1. | clear |
| 5 | /H5 (E). | clear |
| 6 | T_COIN → IC52.4 and IC70.9. | clear |
| 11, MH gate | IC57.Q, same net as MH8. | clear |
| 10, MH gate | IC103.15 (carry), also IC57.CK and an unnumbered 470p capacitor. | clear |
| Lowest input of MH gate, appears `1` | Wire from IC118.15. Standard 7410 output-8 group expects pin **9**, not 1. The printed mark is not silently changed to 9 (U3). | uncertain |
| 8, MH gate | NAND output → IC118.9, IC103.9, C15 and /MHLD (D). | clear |
| Remaining gate; package power | not drawn. | clear |

### IC52 — type not printed

OR body (curved back, pointed front), bubbles at both inputs and output: AND by De Morgan. **[Review 21 Oct: corrected from "AND body ... OR"; the body is drawn as an OR shape.]** The 4,5 → 6 group is compatible with a 7408 or 7432; the part type is not printed.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 5 | T_MSG from IC71.8. | clear |
| 4 | T_COIN from IC55.6. | clear |
| 6 | T_COMB = T_MSG AND T_COIN → IC70.5. [Review: AND, see above.] | clear |
| Other gates; package power | not drawn. | clear |

### IC70 — type not printed

Three AND-body symbols with inverted inputs and inverted outputs: OR functions. The gate driving the mux is drawn facing left. Output outlines are faint at the two sheet-C gates; the output pin on the lower gate is also ambiguous (U4).

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 4 | T_H from IC71.6. | clear |
| 5 | T_COMB from IC52.6. | clear |
| 6 | Output → IC63.7 (strobe); not connected to IC63.6. | clear |
| 12 | TXT from IC63.6, upper sheet-C gate. | clear |
| 13 | T_MSG from IC71.8. | clear |
| 11 | Output wire labelled with an overbar over `EX. [separator] GAME OVER`, to (C); separator and faint output bubble require review (U4, U5). | uncertain |
| 10 | TXT from IC63.6, lower sheet-C gate. | clear |
| 9 | T_COIN from IC55.6. | clear |
| Output of 9/10 gate: `8` or `3` | Wire labelled with an overbar over `COIN [separator] START`, to (C). Standard 7432 expects 8; scan resembles 3. Do not substitute a definite number (U4, U5). | uncertain |
| Remaining gate; package power | not drawn. | clear |

The supported text connectivity is a PROM → 8:1 mux → two qualified text outputs. If the faint IC70 output bubbles are confirmed, the symbol-derived logic is:

- IC63 strobe = `T_H OR (T_MSG AND T_COIN)` [review: IC52 is AND].
- Upper C-sheet output = `TXT OR T_MSG`.
- Lower C-sheet output = `TXT OR T_COIN`.

These expressions do not decode the words in the PROM or establish display orientation. IC63 uses H0/H1/H2 as A/B/C; the direct data mapping is recorded above without a ROM-artwork experiment.

## Pin tables — MH counter and load selection

Main evidence: `motion_h`, `h_left`, `h_right`, `h_carry_loop`, `counter_outputs`, `h_eight_output`, `h_labels`, `h_select_label`, `h_mux_detail`, `h_sp_gate`, `control_mid_route` and `type_gate55`.

### IC118 — `161`

Standard 74161 counter comparison. Parallel inputs A/B/C/D = 3/4/5/6; outputs QA/QB/QC/QD = 14/13/12/11.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 1 (/CLR), 7 (ENP), 10 (ENT) | Vcc. Pin 1 joins the Vcc node beside IC103.7; it does not join the carry wire crossing it. | clear |
| 2 (CLK) | 7M (E), shared with IC103.2. | clear |
| 3 (A) | GND. | clear |
| 4 (B) | IC111.4. | clear |
| 5 (C) | IC111.7. | clear |
| 6 (D) | IC111.9. | clear |
| 9 (/LOAD) | IC55.8; shared /MHLD net. | clear |
| 14, 13, 12, 11 | MH0, MH1, MH2, MH3 respectively → (D) and (M). | clear |
| 15 (carry) | IC103.10; loops above the counters to the lowest input of the MH IC55 gate (pin label doubtful, U3). | clear |
| 8, 16 | Package GND/Vcc: not drawn. | clear |

### IC103 — `161`

The second MH nibble; same standard pinout comparison as IC118.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 1 (/CLR), 7 (ENP) | Vcc. | clear |
| 10 (ENT) | IC118.15. | clear |
| 2 (CLK) | 7M (E). | clear |
| 3 (A) | IC111.12. | clear |
| 4 (B) | Vcc. | clear |
| 5, 6 (C, D) | GND. | clear |
| 9 (/LOAD) | IC55.8; same /MHLD net as IC118.9. | clear |
| 14 | MH4 → (D), (M). | clear |
| 13, 12, 11 | MH5, MH6, MH7 → (D). No (M) circle is drawn above these three outputs. | clear |
| 15 (carry) | IC57.CK and IC55.10; unnumbered 470p capacitor to GND. | clear |
| 8, 16 | Package GND/Vcc: not drawn. | clear |

### IC57 — `107/2`

One JK half is shown; **no numeric pin labels are drawn** on this symbol. A standard 74107 has two different terminal-number sets, so this transcription does not choose a half by inference.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| J, K, bubbled CL | Each drawn to Vcc. | clear |
| CK | IC103.15. | clear |
| Q | MH8 → (D), also IC55.11. | clear |
| /Q, numeric terminals, other half, package power | not drawn. | clear |

### IC111 — marking appears `157`

Leading digit of the part marking is faint (U6); the visible terminal arrangement agrees with a 74157. The select-input caption is `/(V-CA × V8)` [review: resolved, see U7].

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 1 (select) | `/(V-CA × V8)` (E) [review: caption read as `/(V-CA × V8)`; generated by sheet E IC110.3, NAND of V-CA and V8, via connector FS]. An unnumbered 220p capacitor connects this node to GND. | clear |
| 15 (bubbled enable) | GND. | clear |
| 2 | SP.A (H), connector F16. | clear |
| 5 | SP.B (H), connector F7. | clear |
| 11 | SP.C (H), connector F17; branch to IC110.13. | clear |
| 14 | SP.D (H), connector FU; branch to IC110.12. | clear |
| 3, 6 | GND; alternate inputs of channels 1 and 2. | clear |
| 10, 13 | Vcc; alternate inputs of channels 3 and 4. **[Review 21 Oct: corrected; pin 10 was read as GND.]** The lead labelled 10 runs down to its own Vcc caption and pin 13 joins it; the GND tie (dot below pin 3) takes only pins 3 and 6, and there is a gap between the pin 6 box and the pin 10 lead. Crop `5500,2380,5880,2580`. The printed labels of the SP.D lead and the pin-10 lead look alike (`14`/`10`); the standard 74157 assignment is used. | clear |
| 4 | First mux output → IC118.4. | clear |
| 7 | Second output → IC118.5. | clear |
| 9 | Third output → IC118.6. | clear |
| 12 | Fourth output → IC103.3. | clear |
| 8, 16 | Package GND/Vcc: not drawn. | clear |

### IC110 — type not printed

Two-input AND body with output bubble: NAND, standard 7400-compatible pin group. The hand-written `110` has joined leading strokes; see `h_gate_number`.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 13 | SP.C (H), from the F17/IC111.11 wire. | clear |
| 12 | SP.D (H), from the FU/IC111.14 wire. | clear |
| 11 | NAND output, long vertical wire → IC95.10. | clear |
| Other gates; package power | not drawn. | clear |

On the 74157 interpretation, IC111 selects between `{SP.D, SP.C, SP.B, SP.A}` and the fixed four-bit value `1100` [review: corrected from `1000`, see pin 10], in output order pin 12,9,7,4. The receiving eight-bit counter’s parallel-load bits are `[7:0] = {0,0,1,IC111.12,IC111.9,IC111.7,IC111.4,0}`. This is a wiring-derived description, conditional on the faint `157` type reading. [Review: with the select at `/(V-CA × V8)`, the fixed value `1100` (P = 0x38, period 456 clocks) is loaded on every line except the one where V-CA and V8 are both high, when the SP bits are loaded instead. This behavioural reading is inferred from the wiring and not yet confirmed in simulation.]

## Pin tables — vertical decode and text latch

Main evidence: `v_decode`, `decoder_inputs`, `decoder_pin_detail`, `decoder_outputs`, `decoder_wires_left`, `mid_lower_wires`, `right_lower_wires`, `top_crossing_strips`, `v_inputs_long`, `latch_to_text` and the text-section crops.

### IC54 — `42`

Standard 7442 comparison: active-low decimal decoder. The drawing explicitly labels outputs 1 through 7; output 7’s pin numeral is weak (U8). `D1`…`D7` below name the corresponding drawn output nets, not address bits.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 15 (A) | V5 (E), long wire from the IC64.4 source branch. | clear |
| 14 (B) | V6 (E), long wire from the IC64.3 source branch. | clear |
| 13 (C) | V7 (E). | clear |
| 12 (D) | GND. | clear |
| 2 (output 1) | D1 → off-sheet V-(1) (M), and IC61.13. | clear |
| 3 (output 2) | D2 → off-sheet V-(2) (M; review: corrected from H, letter less clear than the others), IC68.15 and IC61.3. | uncertain |
| 4 (output 3) | D3 → off-sheet V-(3) (M). | clear |
| 5 (output 4) | D4 → off-sheet V-(4) (M), (D). [Review: corrected from H.] | clear |
| 6 (output 5) | D5 → off-sheet V-(5) (M), and UG1 input marked 2. [Review: corrected from H.] | clear |
| 7 (output 6) | D6 → IC68.14; also unnumbered 470p capacitor to GND. | clear |
| Output 7, standard pin 9 | D7 → IC61.9. The numeral looks like a small `9`/`0`; retain uncertainty about the printed number (U8). | uncertain |
| 1, 10, 11 (outputs 0, 8, 9 in standard pinout) | not drawn. | clear |
| 8, 16 | Package GND/Vcc: not drawn. | clear |

### IC68 — `279/4`

One SR-latch section, with pin group consistent with the fourth latch of a standard 74279. The IC designator reads **68**, not 48.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 15 (/S) | D2 = IC54.3. | clear |
| 14 (/R) | D6 = IC54.7; unnumbered 470p capacitor to GND. | clear |
| 13 (Q) | Long wire left at approximately y=4950, then up near x=1920 → IC71.5. It is separate from H8/IC64.1. | clear |
| Other latch terminals; 8,16 power terminals | not drawn. | clear |

With D held low, IC54 decodes the V7/V6/V5 combination. IC68 is drawn as an active-low-set/active-low-reset latch set by decoded output 2 and reset by output 6. Its Q qualifies the text-window NAND. No startup state or capacitor delay is assigned.

## Pin tables — common movement selector

Main evidence: `common_control`, `tunnel_label`, `v_reset_label`, `h_sp_gate`, `control_mid_route`, `v_left_bottom`, `reload_mid` and `v_right_bottom`.

### IC95 — type not printed

OR body with both inputs and output inverted: AND by De Morgan. **[Review 21 Oct: corrected from "AND body ... OR".]** Group 9,10 → 8 is compatible with a 7408 or 7432; the part type is not printed.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 9 | D-sheet overbarred tunnel/bridge-labelled input. Top word is drawn `TUNNELL`; second line is abbreviated/unclear (U9). | uncertain |
| 10 | IC110.11. | clear |
| 8 | Output → IC94.13. Crosses /V8 [review: was /V0] without a junction dot. | clear |
| Other gates; package power | not drawn. | clear |

### IC94 — type not printed

Three-input NAND, standard 7410-compatible group 1,2,13 → 12.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 1 | Vs/4 (H), connector EW; same node forwarded to (M). | clear |
| 2 | Vs/2 (H), connector E20. | clear |
| 13 | IC95.8. | clear |
| 12 | Output → IC87.2; crosses /HS without a dot. | clear |
| Other gates; package power | not drawn. | clear |

### IC87 — type not printed

OR body with inverted inputs and output: AND by De Morgan. **[Review 21 Oct: corrected from "AND body ... OR".]** Group 1,2 → 3 is compatible with a 7408 or 7432; the part type is not printed.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 1 | Overbarred `IN RESET` (A), connector EA. The quote-like stroke after IN is retained as punctuation uncertainty, not a different signal (U10). | uncertain |
| 2 | IC94.12. | clear |
| 3 | VSEL → IC83.1 and IC84.1. The branch runs horizontally above IC83/84; it is not either counter’s load net. | clear |
| Other gates; package power | not drawn. | clear |

The gate shapes give `IC110.11 = NAND(SP.C, SP.D)`, `IC95.8 = AND(input at IC95.9, IC110.11)`, `IC94.12 = NAND(Vs/4, Vs/2, IC95.8)`, and `VSEL = AND(input at IC87.1, IC94.12)` [review: AND for both, see the gate bodies]. Names or timing of the unresolved input captions are not expanded from gameplay expectations.

## Pin tables — two lower counter pairs

The drawing labels the on-page left-hand pair “right side” and the on-page right-hand pair “left side” in Japanese. The net labels are **M1V** (IC85/76) and **M2V** (IC91/77). These are retained as names; no physical display rotation is inferred.

Main evidence: `v_left_top`, `v_right_top`, `v_top_complete`, `v_top_right_complete`, `v_left_bottom`, `v_right_bottom`, `reload_mid`, `reload_end`, `reload_labels`, `load_clock_crossing` and `load_clock_crossing2`.

### IC85 — `161`

Low nibble of M1V; standard 74161 comparison.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 1 (/CLR), 7 (ENP) | Vcc. | clear |
| 10 (ENT) | /V8 (E), shared between IC85 and IC91 [review 22 Oct: corrected from `/V0`; sheet E IC114.2 via connector FN]. | clear |
| 2 (CLK) | /HS (E), shared by all four lower counters. | clear |
| 3 (A) | IC83.4. | clear |
| 4 (B) | IC83.7. | clear |
| 5 (C) | IC83.9. | clear |
| 6 (D) | IC83.12. | clear |
| 9 (/LOAD) | R1, from IC62.4; also IC76.9. | clear |
| 14, 13, 12, 11 | M1V0, M1V1, M1V2, M1V3 respectively → (D). | clear |
| 15 (carry) | IC76.10. | clear |
| 8, 16 | Package GND/Vcc: not drawn. | clear |

### IC76 — `161`

High nibble of M1V; standard 74161 comparison.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 1 (/CLR), 7 (ENP) | Vcc. | clear |
| 10 (ENT) | IC85.15. | clear |
| 2 (CLK) | /HS (E). | clear |
| 3, 4, 5, 6 | GND. | clear |
| 9 (/LOAD) | R1, same node as IC85.9. | clear |
| 14, 13, 12, 11 | M1V4, M1V5, M1V6, M1V7 respectively → (D). | clear |
| 15 (carry) | IC62.3. | clear |
| 8, 16 | Package GND/Vcc: not drawn. | clear |

### IC91 — `161`

Low nibble of M2V; standard 74161 comparison.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 1 (/CLR), 7 (ENP) | Vcc. | clear |
| 10 (ENT) | /V8 (E), shared between IC85 and IC91 [review 22 Oct: corrected from `/V0`; sheet E IC114.2 via connector FN]. | clear |
| 2 (CLK) | /HS (E), shared by all four lower counters. | clear |
| 3 (A) | IC84.4. | clear |
| 4 (B) | IC84.7. | clear |
| 5 (C) | IC84.9. | clear |
| 6 (D) | IC84.12. | clear |
| 9 (/LOAD) | R2, from IC62.8; also IC77.9. | clear |
| 14, 13, 12, 11 | M2V0, M2V1, M2V2, M2V3 respectively → (D). | clear |
| 15 (carry) | IC77.10. | clear |
| 8, 16 | Package GND/Vcc: not drawn. | clear |

### IC77 — `161`

High nibble of M2V; standard 74161 comparison.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 1 (/CLR), 7 (ENP) | Vcc. | clear |
| 10 (ENT) | IC91.15. | clear |
| 2 (CLK) | /HS (E). | clear |
| 3, 4, 5, 6 | GND. | clear |
| 9 (/LOAD) | R2, same node as IC91.9. | clear |
| 14, 13, 12, 11 | M2V4, M2V5, M2V6, M2V7 respectively → (D). | clear |
| 15 (carry) | IC62.9. | clear |
| 8, 16 | Package GND/Vcc: not drawn. | clear |

### IC83 — `157`

M1V load mux; standard 74157 comparison. Q1 is the corresponding IC69 Q output.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 1 (select) | VSEL = IC87.3. | clear |
| 15 (bubbled enable) | GND. | clear |
| 2 | Vcc. | clear |
| 5, 11 | Q1 = IC69.9. | clear |
| 14 | /Q1 = IC69.8. | clear |
| 3, 6, 10 | GND. | clear |
| 13 | Vcc. | clear |
| 4, 7, 9, 12 | Outputs → IC85.3,4,5,6 respectively. | clear |
| 8, 16 | Package GND/Vcc: not drawn. | clear |

### IC84 — `157`

M2V load mux; standard 74157 comparison. Q2 is the corresponding IC69 Q output.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 1 (select) | VSEL = IC87.3. | clear |
| 15 (bubbled enable) | GND. | clear |
| 2 | Vcc. | clear |
| 5, 11 | Q2 = IC69.5. | clear |
| 14 | /Q2 = IC69.6. | clear |
| 3, 6, 10 | GND. | clear |
| 13 | Vcc. | clear |
| 4, 7, 9, 12 | Outputs → IC91.3,4,5,6 respectively. | clear |
| 8, 16 | Package GND/Vcc: not drawn. | clear |

The standard 74157 interpretation therefore gives each low counter the parallel nibble `{ /Q, Q, Q, 1 }` when select is low, or `1000` when select is high; each high nibble is wired `0000`. This statement describes only the mux wiring. It does not assign a power-up Q state or claim a motion rate.

`R1` is IC62.4 → IC85.9/IC76.9, C12, lower feedback gates and the D-sheet output `/M1VL…`. `R2` is IC62.8 → IC91.9/IC77.9, C10, lower feedback gates and `/M2VL…`. The final character of the printed output labels is uncertain (U11). The line exporting R1 detours downward/right past the second pair; that detour is **not** the parallel VSEL route.

## Pin tables — lower preset/clear feedback

Main evidence: `left_latch_detail`, `right_latch_detail`, `mid_lower_wires`, `right_lower_wires`, `decoder_wires_left`, `reload_mid` and `reload_end`.

### IC61 — type not printed

Three AND bodies with input bubbles and no output bubbles: NOR functions. All three groups match the standard 7427 pinout comparison.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 13 | D1 = IC54.2. | clear |
| 1 | V4 (E), the long uncomplemented wire branching from the IC64.5 source. | clear |
| 2 | R1 = IC62.4. | clear |
| 12 | NOR(D1, V4, R1) → IC62.11. | clear |
| 3 | D2 = IC54.3. | clear |
| 5 | /V4 (E), separate bottom input from the uncomplemented V4 wire. | clear |
| 4 | R1 = IC62.4; same feedback wire as IC61.2. | clear |
| 6 | NOR(D2, /V4, R1) → IC62.1. | clear |
| 9 | D7, IC54 output 7 (printed pin numeral uncertain, U8). | clear |
| 10 | /V4 (E). | clear |
| 11 | R2 = IC62.8. | clear |
| 8 | NOR(D7, /V4, R2) → IC62.13. | clear |
| 7, 14 | Package GND/Vcc: not drawn. | clear |

### IC62 — inverter symbols, type not printed

Five visible inverter sections; their pin groups match a standard 7404. This does not establish a particular TTL family or unused-input treatment.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 3 → 4 | IC76.15 → R1. R1 joins IC85.9, IC76.9, C12, IC61.2, IC61.4 and the /M1VL… output (D). | clear |
| 9 → 8 | IC77.15 → R2. R2 joins IC91.9, IC77.9, C10, UG1.1, IC61.11 and the /M2VL… output (D). | clear |
| 11 → 10 | IC61.12 → IC69.10 (/PRE of the M1V half). | clear |
| 1 → 2 | IC61.6 → IC69.13 (/CLR of the M1V half). | clear |
| 13 → 12 | IC61.8 → IC69.1 (/CLR of the M2V half). | clear |
| 5 → 6 | not drawn. | clear |
| 7, 14 | Package GND/Vcc: not drawn. | clear |

### IC69 — two symbols marked `74/2`

Both halves of a standard 7474 are consistent with the printed asynchronous control and Q terminal numbers. D and CLK terminals are absent from both drawn symbols. No assumption is made about their actual board connections.

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| 10 (/PRE, M1V half) | IC62.10. | clear |
| 13 (/CLR, M1V half) | IC62.2. | clear |
| 9 (Q) | Q1 → IC83.5 and IC83.11. | clear |
| 8 (/Q) | /Q1 → IC83.14. | clear |
| 11 (CLK), 12 (D) | not drawn. | clear |
| 4 (/PRE, M2V half) | UG1 output marked 3. | clear |
| 1 (/CLR, M2V half) | IC62.12. | clear |
| 5 (Q) | Q2 → IC84.5 and IC84.11. | clear |
| 6 (/Q) | /Q2 → IC84.14. | clear |
| 2 (D), 3 (CLK) | not drawn. | clear |
| 7, 14 | Package GND/Vcc: not drawn. | clear |

### UG1 — unnumbered gate beside IC69 pin 4

No IC designator or part type is visible inside this gate. `UG1` is a local name. AND body with inverted inputs and output gives OR. The 1,2 → 3 group is standard 7432-compatible, but assigning this gate to a particular IC would be a guess (U12).

| Pin(s) / drawn terminal | Net and connection | Confidence |
| --- | --- | --- |
| Input marked 2 | D5 = IC54.6. | clear |
| Input marked 1 | R2 = IC62.8, same feedback wire as IC61.11. | clear |
| Output marked 3 | OR(D5, R2) → IC69.4. | clear |
| IC designator, device type, other gates, power | Not identified/drawn; do not label it IC61 merely because an IC61 gate is nearby (U12). | uncertain |

The lower controls use asynchronous preset/clear inputs. In the drawn logic, the inverters following IC61 turn each NOR result into an OR presented to the active-low control; UG1 already draws that OR form directly. This is a wiring observation only. No simultaneous-preset/clear behaviour, RC edge order or stable-state trajectory is assumed.

## Resistors and capacitors on signal lines

`p` is reproduced as printed and conventionally denotes pF; it is not a tolerance or measured value. No resistor symbol or resistance value was found in the inspected sheet-B functional circuitry. Missing capacitor designators are not invented.

| Part as drawn | Value | Connections | Crop(s) | Confidence |
| --- | --- | --- | --- | --- |
| Unnumbered capacitor | 220p | IC111.1 select-input wire → GND. | h_left, h_select_label | clear |
| Unnumbered capacitor | 470p | IC103.15 / IC57.CK / IC55.10 node → GND. | h_right, h_carry_loop | clear |
| C15 | 470p | IC55.8 shared MH load node → GND. | h_right | clear |
| Unnumbered capacitor | 470p | IC68.14 / IC54.7 (D6) → GND. | v_decode, decoder_outputs | clear |
| C12 | 470p | R1 = IC62.4 → GND. | v_right_bottom, reload_mid | clear |
| C10 | 470p | R2 = IC62.8 → GND. | v_right_bottom, reload_end | clear |

## Off-sheet inputs, outputs and connector labels

Directions below describe the arrows/connections on B, not proof of the remote circuit. Where the drawing uses an overbar across a multiword phrase, the slash applies to the whole phrase. A connector contact is recorded separately from its sheet reference. Output names expanded from ditto marks preserve the drawn numeric order. `V-(n)` represents the drawn V–circled-number notation; no explicit overbar is added to those labels even though the decoder outputs are active low.

| Direction | Caption / contact as read | Sheet reference(s) | B-side connection | Confidence |
| --- | --- | --- | --- | --- |
| Input | V1, V2, V3 | E | IC64.8,7,6 respectively. | clear |
| Input | V4 | E | IC64.5; long lower route → IC61.1. | clear |
| Input | V5, V6 | E | IC64.4,3 and IC54.15,14 respectively. | clear |
| Input | V7 | E | IC54.13. | clear |
| Input | H0, H1, H2 | E | IC63.11,10,9. | clear |
| Input | H3 | E | IC64.2. | clear |
| Input | H4, H6, H7 | E | IC71.1,4,2. | clear |
| Input | H5 | E | IC71.12. | clear |
| Input | /H8 [review: was /H4, U2] | E (IC116.2 via FB) | IC71.9. | clear |
| Input | /H5 | E | IC55.5. | clear |
| Input | H8 | E | IC55.4 and IC64.1. | clear |
| Input / forwarded output | /COIN IN, ED | Input A; output M, D | IC64.23. | clear |
| Input | /EX.SIGNAL, F1 | A | IC72.4. | clear |
| Input | /COIN IN, E1 | A | IC72.5; do not short ED and E1 locally solely because their captions match. | clear |
| Input / forwarded output | Vs/16, E19 | Input H; output M | IC71.10. | clear |
| Input / forwarded output | /GAME, E6 | Input A; output M | IC55.3. | clear |
| Output | /EX. [separator] GAME OVER | C | IC70.11; exact separator uncertain (U5). | uncertain |
| Output | /COIN [separator] START | C | IC70 lower output (8/3 unresolved, U4); separator uncertain (U5). | uncertain |
| Input | 7M | E | IC118.2 and IC103.2. | clear |
| Input | `/(V-CA × V8)` [review: resolved, U7] | E (IC110.3 via FS) | IC111.1 and 220p capacitor. | clear |
| Input | SP.A, F16 | H | IC111.2. | clear |
| Input | SP.B, F7 | H | IC111.5. | clear |
| Input | SP.C, F17 | H | IC111.11 and IC110.13. | clear |
| Input | SP.D, FU | H | IC111.14 and IC110.12. | clear |
| Output | MH0…MH3 | D, M | IC118.14,13,12,11 respectively. | clear |
| Output | MH4 | D, M | IC103.14. | clear |
| Output | MH5…MH7 | D | IC103.13,12,11 respectively. | clear |
| Output | MH8 | D | IC57.Q. | clear |
| Output | /MHLD; final glyph could be O/0 (U11) | D | IC55.8 shared load. | uncertain |
| Input | /TUNNELL [second line BR… unclear] (U9) | D | IC95.9. | uncertain |
| Input | /V8 [review: was /V0] | E (IC114.2 via FN) | IC85.10 and IC91.10. | clear |
| Input / forwarded output | Vs/4, EW | Input H; output M | IC94.1. | clear |
| Input | Vs/2, E20 | H | IC94.2. | clear |
| Input | /HS | E | IC85.2, IC76.2, IC91.2, IC77.2. | clear |
| Input | /IN RESET, EA (punctuation unclear, U10) | A | IC87.1. | uncertain |
| Input | /V4 | E | IC61.5 and IC61.10. | clear |
| Output | V-(1) | M | IC54.2. | clear |
| Output | V-(2) | M (review; letter less clear) | IC54.3. | uncertain |
| Output | V-(3) | M | IC54.4. | clear |
| Output | V-(4) | M, D (review) | IC54.5. | clear |
| Output | V-(5) | M (review) | IC54.6. | clear |
| Output | M1V0…M1V3 | D | IC85.14,13,12,11. | clear |
| Output | M1V4…M1V7 | D | IC76.14,13,12,11. | clear |
| Output | M2V0…M2V3 | D | IC91.14,13,12,11. | clear |
| Output | M2V4…M2V7 | D | IC77.14,13,12,11. | clear |
| Output | /M1VLD, /M2VLD; last glyph D/O/0 unclear (U11) | D | R1 = IC62.4; R2 = IC62.8 respectively. | uncertain |

No input to the sheet-G player path is asserted to originate on B simply because B uses a related name. In particular, the attached G trace’s Vs/4…Vs/32 sources remain references to H. B receives Vs/2, Vs/4 and Vs/16 as drawn; it does not establish their source counter here.

## Standard-pinout cross-check

The following checks compare printed terminal groups with standard 74xx pinouts. They do not supply absent chip markings or assign unprinted package connections. Possible discrepancies stay unresolved rather than being repaired to fit a familiar circuit.

| Printed marking / symbol group | Comparison and outcome | Confidence |
| --- | --- | --- |
| 161: IC118,103,85,76,91,77 | Drawn controls 1,2,7,9,10, carry 15, parallel inputs 3…6 and outputs 14,13,12,11 agree with standard 74161. | clear |
| 157: IC83,84; faint marking on IC111 | All drawn channel terminal groups, select 1 and enable 15 agree with standard 74157. IC111 marking itself still uncertain. | uncertain |
| 151: IC63 | Drawn data/select/strobe/complemented-output numbers agree with standard 74151. Right bubble 7 is an input; bottom bubble 6 is an output. No swapped-pin correction is required. | clear |
| 42: IC54 | Inputs A15/B14/C13/D12 and output 1…6 terminals 2…7 agree with 7442. Output 7 should be pin 9, but its printed numeral is weak (U8). | uncertain |
| 279/4: IC68 | /S15, /R14, Q13 agree with one standard 74279 latch section. | clear |
| 74/2: IC69 | M1V half /PRE10, /CLR13, Q9, /Q8; M2V half /PRE4, /CLR1, Q5, /Q6 agree with 7474. D/clock pins absent; not evidence of a different pinout. | clear |
| 107/2: IC57 | J/K/CK/CL/Q names consistent with 74107 function; no numeric terminals to compare and no half assignment possible. | clear |
| IC71 NAND groups | 1,2,4,5 → 6 and 9,10,12,13 → 8 are 7420-compatible. Device type not printed. | clear |
| IC55 NAND groups | 3,4,5 → 6 agrees with 7410. Group feeding output 8 includes an apparent `1` where standard 7410 requires 9 (U3). | uncertain |
| IC94 NAND group | 1,2,13 → 12 is 7410-compatible. | clear |
| IC72, IC110 NAND groups | 4,5 → 6 and 12,13 → 11 respectively are 7400-compatible. | clear |
| IC52, IC95, IC87 (AND function, OR bodies); IC70 and UG1 (OR function, AND bodies) | Visible pin groups agree with 7408/7432 patterns. The IC70 lower output reads 8 (review). UG1 has no designator (U12). | clear |
| IC61 NOR groups | 1,2,13 → 12; 3,4,5 → 6; 9,10,11 → 8 agree with 7427. | clear |
| IC62 inverter groups | 1→2, 3→4, 9→8, 11→10, 13→12 agree with 7404. | clear |
| IC64 PROM | Visible terminals follow a 7641-compatible layout, but exact device marking remains uncertain; this comparison is not proof of PROM output technology or a substitution of device type. | uncertain |

## Unresolved

1. **U1 — PROM device marking.** Crop `prom_type` `(2810,590,3300,790)`: the line below PR-133 appears `µPB-425D`. The leading µ/P/B-like strokes and exact spelling need a cleaner reading. Alternative: a similar-looking manufacturer/type prefix. The PR133 and IC64 identifiers and physical wire endpoints are clear. Do not replace the marking with “7641” just because the pin arrangement is compatible. Package power/unused terminals are not shown.
2. **U2 — complemented H input of IC71.9.** [Review 22 Oct: resolved as `/H8`; see the cross-check section. Original note follows.] Crops `text_left` `(1120,1000,2950,2250)` and `text_input_detail` `(900,1670,1650,1940)`: read as `/H4`; the small subscript is less legible than H5/H6/H7. Alternative: another H subscript obscured by the neighbouring label/wire. No gate equation depending on this digit should be treated as final until checked.
3. **U3 — MH IC55 input pin discrepancy.** Crop `type_gate55` `(6740,2010,7070,2180)`: inputs beside output 8 read 11,10, and a single stroke resembling **1**. The lowest input is unambiguously routed from IC118.15; standard 7410 expects **9** for that terminal. Alternatives: damaged/poorly written 9 versus an actual drafting error. The net is recorded without “correcting” its pin number.
4. **U4 — lower text IC70 output numeral and faint bubbles.** Crops `gate70_outputs` `(3410,1860,3710,2160)` and `text_labels` `(3400,1850,4360,2200)`: lower output number can be read as **8** or **3**. Inputs 9 and 10 are clear; standard 7432 output is 8. Output bubble outlines are weak, especially on this gate. Alternatives: incomplete scan strokes versus a drawn pin/function discrepancy. The OR interpretation is supported by the inverted-input AND-body form and the other IC70 gate, but must not turn the doubtful marks into certainty.
5. **U5 — sheet-C output-caption separators.** Crop `text_labels` `(3400,1850,4360,2200)`: overbarred `EX. [separator] GAME OVER` and `COIN [separator] START`. The separator resembles an ampersand/triangular shorthand, not a securely read alphabetic character. Alternatives include “&” or a handwritten logical separator. Preserve the two output wires; do not infer remote mixing/priority from the punctuation.
6. **U6 — IC111 type marking.** Crop `h_mux_detail` `(5370,2200,6060,2510)`: visible ending `57`, faint preceding stroke consistent with `157`. The complete terminal arrangement matches 74157, but that compatibility does not restore the missing ink. Alternative: the first digit is not reliably legible. Derived mux-selection statements above are explicitly conditional.
7. **U7 — IC111.1 E-sheet caption.** [Review: resolved as `/(V-CA × V8)`, matching sheet E IC110.3 and its FS output arrow labelled for B; see the review section above. Original note follows.] Crop `h_select_label` `(4400,2230,4980,2440)`: a bar spans a label beginning `V-C…` and ending `V0`; the middle characters and separator are not clear enough to distinguish, for example, a C/parenthesis/letter sequence and a plus/arrow-like separator. No single expanded name is adopted. Alternatives: a compound V-related net caption, or a damaged abbreviation followed by V0. The route into pin 1 and the 220p shunt are clear. Do not equate this input to plain `/V0` solely from the final characters.
8. **U8 — IC54 output-7 terminal numeral.** Crop `decoder_pin_detail` `(3260,5360,3760,5900)`: the drawn output function is 7, but the tiny physical pin numeral resembles `9` or `0`. Standard 7442 gives pin 9. The D7 wire to IC61.9 is clear. Alternative: a weak 9 versus a drafting/scan error; the standard value is not presented as a certain ink reading.
9. **U9 — D-sheet tunnel/bridge caption.** Crop `tunnel_label` `(4350,3660,4910,3850)`: top word reads `TUNNELL`, with an overbar; second line begins `BR.` and has unclear following characters. It may abbreviate bridge, but its exact lettering and whether the overbar applies to the entire two-line phrase cannot be settled here. Alternative: `BR.GE`/another abbreviated spelling. Only the single input wire to IC95.9 is certain; no internal D-sheet logic is inferred.
10. **U10 — reset-caption punctuation.** Crop `v_reset_label` `(4390,5080,5010,5320)`: overbarred `IN RESET`, with a quote-like mark after IN; connector EA, sheet A. Alternative: punctuation or a damaged additional letter. The intended expansion (such as “initial”) is not supplied as a reading.
11. **U11 — load-output final glyphs.** Crops `h_labels` `(7430,2150,8000,2400)` and `reload_labels` `(8060,4770,9000,5100)`: the legible prefixes are `/MHL`, `/M1VL`, `/M2VL`, followed by a small round glyph that may be D/O/0. The LD spellings used provisionally above are not settled ink readings. The nets are identified unambiguously by their drivers IC55.8, IC62.4 and IC62.8. Alternative caption transcription retains O or 0; no electrical change follows from choosing a spelling.
12. **U12 — unnumbered gate UG1.** Crop `right_latch_detail` `(6850,5430,7750,6080)`: gate at lower left of the M2V half of IC69 has inputs marked 2 and 1, output 3, with inverted inputs and output on an AND body. No IC number is visible. Alternatives: omitted designator, erased marking, or a section of an IC whose number is printed elsewhere. **No particular IC is assigned.** It must not be conflated with the neighbouring three-input IC61 symbol.
13. **Undrawn sequential terminals.** `h_right` `(6200,1430,7860,2510)` and both latch-detail crops: IC57’s numeric pins and unused output/half are not drawn. IC69 D and clock terminals are not drawn. Alternatives include board connections omitted from this functional drawing; “open” and “tied” are not interchangeable here. No half selection, floating-input state or power-up behaviour is assumed.
14. **Undrawn package power and unused gates.** The per-IC tables explicitly distinguish signal pins tied to Vcc/GND from package supply pins absent from the symbols. IC64’s other terminals and the unused outputs of IC54 are also not drawn. The alternatives are an intentionally omitted connection or a physically unconnected terminal; this sheet alone does not decide.
15. **Analog timing and transitions.** The six capacitors are transcribed with endpoints and printed values. No resistor or capacitor tolerance is supplied by the inspected circuitry. Propagation/ripple delays, clock-to-load relationship, asynchronous-control races and the PROM’s electrical output behaviour are unresolved; no timing specification or simulation result is claimed.

## Review boundaries

The whole drawn sheet-B functional area was inspected, including the shared text/decode wire and both lower feedback loops. This document does not continue onto sheets A, C, D, E, F, G, H or M. References to them are only the B-sheet labels and the supplied model’s naming conventions. No external cross-sheet continuity was presumed.

Before implementation, resolve the numbered uncertainties, check the gate/pin readings against the scan independently, and confirm omitted sequential/power connections from an appropriate source. The “clear” rows remain transcription claims for that review, not evidence from an original PCB.
