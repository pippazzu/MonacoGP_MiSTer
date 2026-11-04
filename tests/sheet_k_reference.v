// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected reference for sheet K (manual 420-0358, PDF page
// 24, docs/trace/SHEET_K_TRACE.md): 15 x 74174 in five columns and 11D's two
// inverters. Delays only enforce settling order; they are NOT measured TTL
// delays. Unconnected TTL inputs read high.
`timescale 1ns/1ps
`define KTTL(x) ((x) === 1'bz ? 1'b1 : (x))
// 74174: six D flip-flops, positive edge, /MR (pin 1) clears.
// D 3, 4, 6, 11, 13, 14 -> Q 2, 5, 7, 10, 12, 15; CP 9
module kref_174(input mr_n, cp, d3, d4, d6, d11, d13, d14,
                output reg q2=0, output reg q5=0, output reg q7=0, output reg q10=0,
                output reg q12=0, output reg q15=0);
    always @(posedge cp or negedge mr_n)
        if (!mr_n) {q2, q5, q7, q10, q12, q15} <= #2 6'd0;
        else {q2, q5, q7, q10, q12, q15} <= #2 {`KTTL(d3), `KTTL(d4), `KTTL(d6), `KTTL(d11), `KTTL(d13), `KTTL(d14)};
endmodule
module sheet_k_reference(
    input  [15:0] d,          // D-1A (bit 0) .. D-4D (bit 15)
    input   [4:0] ck,         // 1ST..5TH
    input         latch_cl,
    output [79:0] q
);
    wire mr_a, mr_b;
    wire open = 1'bz;
    assign #1 mr_a = ~`KTTL(latch_cl);       // 11D 1 -> 2: columns 1-3
    assign #1 mr_b = ~`KTTL(latch_cl);       // 11D 3 -> 4: columns 4-5
    genvar c;
    generate for (c = 0; c < 5; c = c + 1) begin : col
        wire mr = c < 3 ? mr_a : mr_b;
        wire [15:0] o;
        // top (9x): D-1A..D-1D, D-2A, D-2B; middle (8x): D-2C..D-3D; bottom (7x): D-4A..D-4D
        kref_174 top(.mr_n(mr), .cp(ck[c]), .d3(d[0]), .d4(d[1]), .d6(d[2]), .d11(d[3]), .d13(d[4]), .d14(d[5]),
                     .q2(o[0]), .q5(o[1]), .q7(o[2]), .q10(o[3]), .q12(o[4]), .q15(o[5]));
        kref_174 mid(.mr_n(mr), .cp(ck[c]), .d3(d[6]), .d4(d[7]), .d6(d[8]), .d11(d[9]), .d13(d[10]), .d14(d[11]),
                     .q2(o[6]), .q5(o[7]), .q7(o[8]), .q10(o[9]), .q12(o[10]), .q15(o[11]));
        kref_174 bot(.mr_n(mr), .cp(ck[c]), .d3(d[12]), .d4(d[13]), .d6(d[14]), .d11(d[15]), .d13(open), .d14(open),
                     .q2(o[12]), .q5(o[13]), .q7(o[14]), .q10(o[15]), .q12(), .q15());
        assign q[16*c +: 16] = o;
    end endgenerate
endmodule
