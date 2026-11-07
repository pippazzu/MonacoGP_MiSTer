# PR-54 mapping investigation

> **Update, 6 November 2026:** the mapping is now traced in `pro/docs/trace/SHEET_M_C_PLUS200_TRACE.md`, and Aldo has redrawn the glyph on two-row marks: `plus200-glyph.txt`, with its PR-54 bytes. The notes below are the earlier analysis, kept for the record.

Source: manual 420-0525, PDF page 17, sheet M, board 96823-P. Read from schematic images; not a hardware measurement.

## Direct readings

- IC130 is PR-54, type 6331, 32 words x 8 bits. Enable pin 15 is grounded.
- PROM outputs pins 1,2,3,4,5,6,7,9 connect respectively to IC129 (74151) inputs pins 4,3,2,1,15,14,13,12: I0..I7 in normal order.
- Select pins 11,10,9 connect to H1,H2,H3 respectively. Consequently each selected PROM bit lasts two H clocks. This differs from the main text circuit using H0..H2.
- The five address wires branch from V0..V4 beside PR139. Following their nested routes, the current reading is PR54 pins 10,11,12,13,14 = V4,V3,V2,V1,V0 respectively. With standard 6331 pin assignments, A0=V4 through A4=V0: address is bit-reversed V[4:0]. This long-wire reading should receive an independent recheck before integration.
- Output goes from IC129 pin 6, the complemented output, to the +200 line on sheet C. An asserted pixel is therefore expected to be an active-low video signal when the selected PROM bit is 1, subject to confirming the receiving colour gate.
- IC129 pin 7 is the strobe input, supplied by the adjacent gating. Do not confuse it with the PROM enable or an output. Exact strobe window/phase and receiving colour logic remain to be fully checked.

## Geometry correction

The GAME OVER reference has 64 unique V1-addressed columns across 128 raster lines and 16 H-clock rows. PR54 instead has 32 V0-addressed columns and eight H1-addressed rows, so its full local raster footprint is 32 columns by 16 rows after rotation (before CRT scaling). The drawing tool was not designed around this distinction.

The user's original drawing remains unchanged: 15 occupied stored-text columns by six drawn rows. Preserving its horizontal size relative to GAME OVER requires duplicating each column, making 30 PROM columns. Treating its six drawn rows as six PROM bits would produce 12 raster rows, not the six rows shown in the template. This is a proposed reinterpretation for approval/visual comparison, NOT a lossless encoding of the screenshot/template.

As drawn, rows are not identical in adjacent pairs, so the source bitmap cannot be reproduced exactly at the same vertical scale by H1..H3 selection. No verified PROM binary has been produced. Do not claim its exact screen placement, byte order or original contents have been confirmed.

## Next checks

Recheck the V-address routing, trace the strobe's vertical/horizontal window and colour input, then position the user's reconstructed bitmap in that window. Use the user's first-2/last-M alignment as a visual cross-check rather than overriding contrary wiring. Compare a 30-by-12 raster candidate with the original-machine photo. Preserve the user artwork including the second-row left pixel of 2 unless changed by the user.

## Follow-up wiring check

IC129 multiplexer pinout cross-checked with TI SN74LS151 datasheet (https://www.ti.com/lit/ds/symlink/sn74ls151.pdf): A/B/C=11/10/9, active-low strobe=7, complemented output W=6. This confirms the interpretation of the schematic symbol; it is not evidence about PROM contents.

The PR54 output wires run directly, without crossings, to I0..I7 in normal bit order. Selection is (H >> 1) & 7. A 1 in the selected word bit drives the active-low pixel line low when strobe is enabled. Each bit therefore occupies two H clocks.

Sheet C, PDF page 14: +200 enters IC74's eight-input combining gate (marked 30), on the input shown as pin 6. EX & GAME OVER joins this same gate on pin 2. Its output pin 8 runs through inverter IC2 pins 13->12 into the red composition path. Thus +200 and GAME OVER share the red combining path. The bonus colour is not stored in PR54.

The horizontal position-address interpretation V0..V4 was re-followed across the nested routing. The working reading remains A0=V4, A1=V3, A2=V2, A3=V1, A4=V0. Spatial columns progress with V; because the screen is rotated clockwise, left-to-right image order is decreasing V. A file stored in increasing PROM addresses is therefore neither simple screen-row order nor simple left-to-right column order.

Enable path: IC129 pin 7 is fed by the adjacent three-input NAND output (shown as IC124 pin 8 in the larger crop). Its inputs include BONUS CP on pin 10, the H4..H7 decode on pin 9, and a third qualification line on pin 11. IC128 uses a negative-input AND symbol for its H4..H7 decode. Exact polarities of every incoming label and the full origin of pin 11 have NOT been closed; do not assert an absolute H/V window from this partial trace.

Result: data/selector ordering, two-H-clock row repetition and shared red path are supported. Absolute positioning and gate qualification are still unresolved. No verified PROM file can yet be claimed. The original submitted artwork remains untouched.

## Enable-path continuation: polarity inconsistency found

The previously unidentified qualification wire was followed down and left to the sheet-B V-(4) input on sheet M. It is distinct from the parallel DUMMY AREA net (which has a junction dot on the lower line).

Sheet B, PDF page 13: IC71 is marked 42, with output bubbles, and V-(4) leaves output pin 5. It is therefore an active-low decoded output, not an active-high window. Inputs appear to be V5,V6,V7 with the fourth input grounded; exact incoming labels should be retained in the full trace.

A close crop of sheet M IC124 confirms a flat-input AND-shaped gate with an output bubble, pins 11/10/9 -> 8: a NAND as drawn. Feeding active-low V-(4) directly to this gate would force the mux strobe high (disabled) inside the selected V-(4) strip. This contradicts the earlier expectation that the wire positively enables that strip. Do not silently insert an inverter to force the desired location.

This is an unresolved schematic-reading/polarity inconsistency, not confirmation that the original board is faulty. The alternatives to audit are the full route, any missed inversion, actual gate/package identity, or a drawing error. Absolute placement remains unverified. The known mux selection and PROM output ordering are unaffected by this inconsistency.
