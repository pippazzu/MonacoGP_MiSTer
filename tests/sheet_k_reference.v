// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected reference for sheet K (manual 420-0358, PDF page
// 24, docs/trace/SHEET_K_TRACE.md): 15 x 74174 in five columns and 11D's two
// inverters. Delays only enforce settling order; they are NOT measured TTL
// delays. Unconnected TTL inputs read high.
//
// PRO = 1: the Pro board's sheet K (manual 420-0525, PDF page 20), wired
// from pro/docs/trace/SHEET_K_TRACE.md: the same 15 rank latches with every
// /MR (pin 1) tied to Vcc, and the SUPER RACER SCORE store: 74174s 43, 49,
// 57, 7485s 44, 50, 58, 67 and AND 66. latch_cl is then NOT /LATCH CL (I,
// 73.11), the 174s' /MR being /LATCH CL itself. SRS_GE selects 44's cascade
// inputs: 1 = as read (pin 4 Vcc, pins 2 and 3 ground: 67.5 = P >= S), 0 =
// the usual tie (pin 3 high: P > S), trace K-U1. The display drive (42, 48,
// 41, 36, 37, 07, 17 and the transistors) is not modelled. p, trs, srs and
// srs_flag are unused with PRO = 0.
`timescale 1ns/1ps
`define KTTL(x) ((x) === 1'bz ? 1'b1 : (x))
// 74174: six D flip-flops, positive edge, /MR (pin 1) clears.
// D 3, 4, 6, 11, 13, 14 -> Q 2, 5, 7, 10, 12, 15; CP 9
// A clock that only goes from 0 to unknown (the references' first settling
// after time 0) is not an edge: on the original board LATCH CL. cleared it
// anyway, the Pro board's rank latches are never cleared.
module kref_174(input mr_n, cp, d3, d4, d6, d11, d13, d14,
                output reg q2=0, output reg q5=0, output reg q7=0, output reg q10=0,
                output reg q12=0, output reg q15=0);
    always @(posedge cp or negedge mr_n)
        if (!mr_n) {q2, q5, q7, q10, q12, q15} <= #2 6'd0;
        else if (cp === 1'b1)
            {q2, q5, q7, q10, q12, q15} <= #2 {`KTTL(d3), `KTTL(d4), `KTTL(d6), `KTTL(d11), `KTTL(d13), `KTTL(d14)};
endmodule
// 7485 4-bit magnitude comparator: A0 10, A1 12, A2 13, A3 15, B0 9, B1 11,
// B2 14, B3 1, cascade in A<B 2, A=B 3, A>B 4, out A>B 5, A=B 6, A<B 7
module kref_7485(input [3:0] a, b, input p4, p3, p2, output p5, p6, p7);
    wire gt = `KTTL(p4), eq = `KTTL(p3), lt = `KTTL(p2);
    wire [3:0] aa = {`KTTL(a[3]), `KTTL(a[2]), `KTTL(a[1]), `KTTL(a[0])};
    wire [3:0] bb = {`KTTL(b[3]), `KTTL(b[2]), `KTTL(b[1]), `KTTL(b[0])};
    assign #1 p5 = aa > bb || (aa == bb && !eq && !lt);
    assign #1 p7 = aa < bb || (aa == bb && !eq && !gt);
    assign #1 p6 = aa == bb && eq;
endmodule
module kref_and2(input a, b, output y); assign #1 y = `KTTL(a) & `KTTL(b); endmodule
module sheet_k_reference #(parameter integer PRO = 0, parameter integer SRS_GE = 1)(
    input  [15:0] d,          // D-1A (bit 0) .. D-4D (bit 15)
    input   [4:0] ck,         // 1ST..5TH
    input         latch_cl,   // Pro: NOT /LATCH CL
    input  [15:0] p,          // Pro: P-1A (bit 0) .. P-4D (bit 15)
    input         trs,        // Pro: T.R.S
    output [79:0] q,
    output [15:0] srs,        // Pro: S1A (bit 0) .. S4D (bit 15)
    output        srs_flag    // Pro: FLAG (57.12)
);
    wire mr_a, mr_b;
    wire vcc = 1'b1, gnd = 1'b0, open = 1'bz;
    generate if (PRO) begin : g_pro_mr
        assign mr_a = vcc, mr_b = vcc;       // every rank latch /MR to Vcc
    end else begin : g_orig_mr
        assign #1 mr_a = ~`KTTL(latch_cl);   // 11D 1 -> 2: columns 1-3
        assign #1 mr_b = ~`KTTL(latch_cl);   // 11D 3 -> 4: columns 4-5
    end endgenerate
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
    // ------------------------------------------------ Pro: SUPER RACER SCORE
    generate if (PRO) begin : g_srs
        wire lcl_n = ~latch_cl;              // /LATCH CL (the net from I's 73.11)
        wire [15:0] s;                       // S1A .. S4D
        wire flag, clk66;
        // 44 (units), 50, 58, 67 (thousands): A = P, B = S
        wire c44_5, c44_6, c44_7, c50_5, c50_6, c50_7, c58_5, c58_6, c58_7, c67_5, c67_6, c67_7;
        wire t4 = SRS_GE ? vcc : gnd, t3 = SRS_GE ? gnd : vcc;
        kref_7485 u44(.a(p[3:0]),   .b(s[3:0]),   .p4(t4),    .p3(t3),    .p2(gnd),
                      .p5(c44_5), .p6(c44_6), .p7(c44_7));
        kref_7485 u50(.a(p[7:4]),   .b(s[7:4]),   .p4(c44_5), .p3(c44_6), .p2(c44_7),
                      .p5(c50_5), .p6(c50_6), .p7(c50_7));
        kref_7485 u58(.a(p[11:8]),  .b(s[11:8]),  .p4(c50_5), .p3(c50_6), .p2(c50_7),
                      .p5(c58_5), .p6(c58_6), .p7(c58_7));
        kref_7485 u67(.a(p[15:12]), .b(s[15:12]), .p4(c58_5), .p3(c58_6), .p2(c58_7),
                      .p5(c67_5), .p6(c67_6), .p7(c67_7));
        kref_and2 u66(.a(c67_5), .b(trs), .y(clk66));                 // 66 9, 10 -> 8
        // 43: P-1A..P-1D, P-2A, P-2B; 49: P-2C..P-3D; 57: P-4A..P-4D, Vcc
        kref_174 u43(.mr_n(lcl_n), .cp(clk66), .d3(p[0]), .d4(p[1]), .d6(p[2]), .d11(p[3]), .d13(p[4]), .d14(p[5]),
                     .q2(s[0]), .q5(s[1]), .q7(s[2]), .q10(s[3]), .q12(s[4]), .q15(s[5]));
        kref_174 u49(.mr_n(lcl_n), .cp(clk66), .d3(p[6]), .d4(p[7]), .d6(p[8]), .d11(p[9]), .d13(p[10]), .d14(p[11]),
                     .q2(s[6]), .q5(s[7]), .q7(s[8]), .q10(s[9]), .q12(s[10]), .q15(s[11]));
        kref_174 u57(.mr_n(lcl_n), .cp(clk66), .d3(p[12]), .d4(p[13]), .d6(p[14]), .d11(p[15]), .d13(vcc), .d14(open),
                     .q2(s[12]), .q5(s[13]), .q7(s[14]), .q10(s[15]), .q12(flag), .q15());
        assign srs = s, srs_flag = flag;
    end else begin : g_nosrs
        assign srs = 16'd0, srs_flag = 1'b0;
    end endgenerate
endmodule
