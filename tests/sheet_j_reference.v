// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected reference for sheet J (manual 420-0358, PDF page
// 22, docs/trace/SHEET_J_TRACE.md): K9 (half 74393), 2H (7408), 2F (7445),
// the five NOR + 7406 flash gates of rows 1ST..5TH, the eight row
// transistors, sixteen 74151 muxes and four 7448 decoders. The 75468
// drivers only sink the segments the 7448 drives high, so the outputs here
// are the 7448 outputs. Delays only enforce settling order; they are NOT
// measured TTL delays. Unconnected TTL inputs read high.
`timescale 1ns/1ps
`define JTTL(x) ((x) === 1'bz ? 1'b1 : (x))
// half 74393: four-bit ripple counter, falling-edge clock, MR high clears
module jref_393_half(input cp, mr, output reg [3:0] q = 0);
    always @(negedge cp or posedge mr)
        if (mr) q <= #2 0; else q <= #2 q + 4'd1;
endmodule
// 7445: BCD to decimal, open-collector outputs 0..9 on pins 1-7, 9-11
module jref_7445(input a15, b14, c13, d12, output [9:0] o);
    wire [3:0] x = {`JTTL(d12), `JTTL(c13), `JTTL(b14), `JTTL(a15)};
    genvar k;
    generate for (k = 0; k < 10; k = k + 1) begin : out
        assign #2 o[k] = x == k ? 1'b0 : 1'bz;
    end endgenerate
endmodule
// 74151: D0..D7 on pins 4,3,2,1,15,14,13,12; A11 B10 C9; /ST 7; Y 5
module jref_74151(input p4, p3, p2, p1, p15, p14, p13, p12, p11, p10, p9, p7, output p5);
    wire [7:0] dd = {`JTTL(p12), `JTTL(p13), `JTTL(p14), `JTTL(p15), `JTTL(p1), `JTTL(p2), `JTTL(p3), `JTTL(p4)};
    wire [2:0] s = {`JTTL(p9), `JTTL(p10), `JTTL(p11)};
    assign #2 p5 = `JTTL(p7) ? 1'b0 : dd[s];
endmodule
// 7448: BCD to seven segments (data-sheet display table: 6 without a,
// 9 without d, 10..14 the special glyphs, 15 blank); LT, RBI, BI/RBO not
// wired (inactive). Outputs a13 b12 c11 d10 e9 f15 g14.
module jref_7448(input a7, b1, c2, d6, output p13, p12, p11, p10, p9, p15, p14);
    wire [3:0] x = {`JTTL(d6), `JTTL(c2), `JTTL(b1), `JTTL(a7)};
    // lit digits per segment, bit n = digit n
    localparam [15:0] SA = 16'b0010_0011_1010_1101,  // 0 2 3 5 7 8 9 13
                      SB = 16'b0001_0011_1001_1111,  // 0 1 2 3 4 7 8 9 12
                      SC = 16'b0000_1011_1111_1011,  // 0 1 3 4 5 6 7 8 9 11
                      SD = 16'b0110_1101_0110_1101,  // 0 2 3 5 6 8 10 11 13 14
                      SE = 16'b0100_0101_0100_0101,  // 0 2 6 8 10 14
                      SF = 16'b0111_0011_0111_0001,  // 0 4 5 6 8 9 12 13 14
                      SG = 16'b0111_1111_0111_1100;  // 2 3 4 5 6 8 9 10 11 12 13 14
    assign #2 p13 = SA[x];
    assign #2 p12 = SB[x];
    assign #2 p11 = SC[x];
    assign #2 p10 = SD[x];
    assign #2 p9  = SE[x];
    assign #2 p15 = SF[x];
    assign #2 p14 = SG[x];
endmodule
module jref_and2(input a, b, output y); assign #2 y = `JTTL(a) & `JTTL(b); endmodule
module jref_nor2(input a, b, output y); assign #2 y = ~(`JTTL(a) | `JTTL(b)); endmodule
module jref_oc_inv(input a, output y);  assign #2 y = `JTTL(a) ? 1'b0 : 1'bz;  endmodule
// PNP row driver: conducts while its base (through 560 ohms) is pulled low
module jref_pnp(input base, output on); assign on = base === 1'b0; endmodule

module sheet_j_reference(
    input         v2,
    input  [79:0] ranks,      // {5TH .. 1ST}, each {-4D .. -1A}
    input  [15:0] p,
    input  [11:0] n, r,
    input   [3:0] t1, t2,
    input   [5:1] flash,
    output  [2:0] scan,
    output  [7:0] row_on,
    output [27:0] seg         // {group 4 g..a, .., group 1 g..a}
);
    wire gnd = 1'b0, vcc = 1'b1;
    wire [3:0] k9;
    jref_393_half u_k9(.cp(v2), .mr(gnd), .q(k9));
    wire sa, sb, sc;                          // 2H outputs
    jref_and2 u_2h_3 (.a(vcc), .b(k9[0]), .y(sa));
    jref_and2 u_2h_11(.a(vcc), .b(k9[1]), .y(sb));
    jref_and2 u_2h_6 (.a(vcc), .b(k9[2]), .y(sc));
    wire [9:0] o2f;
    jref_7445 u_2f(.a15(sa), .b14(sb), .c13(sc), .d12(gnd), .o(o2f));
    // RA 1K pull-ups on rows 1..5
    wire [4:0] strobe;
    genvar k;
    generate for (k = 0; k < 5; k = k + 1) begin : pu
        assign strobe[k] = o2f[k] === 1'b0 ? 1'b0 : 1'b1;
    end endgenerate
    wire [4:0] nor_o, base;
    jref_nor2 u_2e2_1 (.a(strobe[0]), .b(flash[1]), .y(nor_o[0]));   // 2/3 -> 1
    jref_nor2 u_2e2_4 (.a(strobe[1]), .b(flash[2]), .y(nor_o[1]));   // 5/6 -> 4
    jref_nor2 u_2e2_13(.a(strobe[2]), .b(flash[3]), .y(nor_o[2]));   // 11/12 -> 13
    jref_nor2 u_12e_10(.a(strobe[3]), .b(flash[4]), .y(nor_o[3]));   // 8/9 -> 10
    jref_nor2 u_2e2_10(.a(strobe[4]), .b(flash[5]), .y(nor_o[4]));   // 8/9 -> 10
    jref_oc_inv u_1e_4 (.a(nor_o[0]), .y(base[0]));
    jref_oc_inv u_1e_2 (.a(nor_o[1]), .y(base[1]));
    jref_oc_inv u_1e_6 (.a(nor_o[2]), .y(base[2]));
    jref_oc_inv u_1e_8 (.a(nor_o[3]), .y(base[3]));
    jref_oc_inv u_1e_12(.a(nor_o[4]), .y(base[4]));
    jref_pnp tr1(.base(base[0]), .on(row_on[0]));
    jref_pnp tr2(.base(base[1]), .on(row_on[1]));
    jref_pnp tr3(.base(base[2]), .on(row_on[2]));
    jref_pnp tr4(.base(base[3]), .on(row_on[3]));
    jref_pnp tr5(.base(base[4]), .on(row_on[4]));
    jref_pnp tr6(.base(o2f[5]), .on(row_on[5]));
    jref_pnp tr7(.base(o2f[6]), .on(row_on[6]));
    jref_pnp tr8(.base(o2f[7]), .on(row_on[7]));
    assign scan = k9[2:0];

    // muxes: group g (1..4) bit b (A..D)
    genvar g, b;
    generate for (g = 0; g < 4; g = g + 1) begin : grp
        wire [3:0] y;
        for (b = 0; b < 4; b = b + 1) begin : bit_
            wire d6, d7;
            if (g == 0) begin : timer          // group 1: the timer, T2 tens and T1 units
                assign d6 = t2[b];
                assign d7 = t1[b];
            end else begin : nr
                assign d6 = n[4*(g-1) + b];
                assign d7 = r[4*(g-1) + b];
            end
            jref_74151 u_mux(.p4(ranks[4*g + b]), .p3(ranks[16 + 4*g + b]), .p2(ranks[32 + 4*g + b]),
                .p1(ranks[48 + 4*g + b]), .p15(ranks[64 + 4*g + b]), .p14(p[4*g + b]), .p13(d6), .p12(d7),
                .p11(sa), .p10(sb), .p9(sc), .p7(gnd), .p5(y[b]));
        end
        jref_7448 u_dec(.a7(y[0]), .b1(y[1]), .c2(y[2]), .d6(y[3]),
            .p13(seg[7*g+0]), .p12(seg[7*g+1]), .p11(seg[7*g+2]), .p10(seg[7*g+3]),
            .p9(seg[7*g+4]), .p15(seg[7*g+5]), .p14(seg[7*g+6]));
    end endgenerate
endmodule
