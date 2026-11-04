// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected, event-driven reference for the score counter of
// sheet I (manual 420-0358, PDF page 23): 7F, 8F (74390), 12F (7430), 13H
// (7400), 13E (74279), 11C (7432), 11D and the RST inverter (7404), 2E-1
// (7416). Wired by IC and pin number from docs/trace/SHEET_I_TRACE.md.
// Delays only enforce settling order; they are NOT measured TTL delays.
`timescale 1ns/1ps
`define ITTL(x) ((x) === 1'bz ? 1'b1 : (x))

// One half of a 74390: QA toggles on CPA falling; QB..QD count 0..4 on CPB
// falling (divide by 5); MR (active high) clears.
module iref_390_half(input cpa, cpb, mr, output reg qa=0, output qb, qc, qd);
    reg [2:0] q5 = 0;
    always @(negedge cpa or posedge mr) if (mr) qa <= #3 0; else qa <= #3 ~qa;
    always @(negedge cpb or posedge mr) if (mr) q5 <= #3 0; else q5 <= #3 (q5 == 3'd4 ? 3'd0 : q5 + 3'd1);
    assign {qd, qc, qb} = q5;
endmodule
module iref_74390(input p1, p2, p4, p15, p14, p12, output p3, p5, p6, p7, p13, p11, p10, p9);
    iref_390_half u1(`ITTL(p1), `ITTL(p4), `ITTL(p2), p3, p5, p6, p7);
    iref_390_half u2(`ITTL(p15), `ITTL(p12), `ITTL(p14), p13, p11, p10, p9);
endmodule
module iref_7430(input p1,p2,p3,p4,p5,p6,p11,p12, output p8);
    assign #2 p8 = ~(`ITTL(p1)&`ITTL(p2)&`ITTL(p3)&`ITTL(p4)&`ITTL(p5)&`ITTL(p6)&`ITTL(p11)&`ITTL(p12));
endmodule
module iref_nand2(input a, b, output y);  assign #2 y = ~(`ITTL(a)&`ITTL(b)); endmodule
module iref_or2(input a, b, output y);    assign #2 y = `ITTL(a)|`ITTL(b);    endmodule
module iref_inv(input a, output y);       assign #2 y = ~`ITTL(a);            endmodule
// 2E-1 section, open collector with the receiving board's pull-up: taken as
// a non-inverting buffer (plain triangle; the "16" printed above is not
// followed, see jtmonacogp_score.v).
module iref_oc_buf(input a, output y);    assign #2 y = `ITTL(a) ? 1'b1 : 1'b0; endmodule
// 74279 latch with one /S input: /S low drives Q high, else /R low drives it low.
module iref_279_1(input s_n, r_n, output reg q=0);
    always @* if (!`ITTL(s_n)) q <= #3 1; else if (!`ITTL(r_n)) q <= #3 0;
endmodule

module sheet_i_score_reference(
    input         score_cp_n, coin_test_n, ini_reset_n,
    output [15:0] digits,
    output  [3:0] s100,
    output        s100_d2, sp_cont
);
    wire rst_t, n9999, g, s13e_n, rst_n, ic11d_12, ic11c_11;
    // 13H sections
    iref_nand2 h13b(.a(coin_test_n), .b(ini_reset_n), .y(rst_t));   // drawn OR with input bubbles
    iref_nand2 h13a(.a(score_cp_n), .b(n9999), .y(g));              // 12, 13 -> 11
    // 7F, 8F
    wire [3:0] p1, p2, p3, p4;
    iref_74390 f7(.p1(g), .p2(rst_t), .p4(p1[0]), .p15(p1[3]), .p14(rst_t), .p12(p2[0]),
        .p3(p1[0]), .p5(p1[1]), .p6(p1[2]), .p7(p1[3]), .p13(p2[0]), .p11(p2[1]), .p10(p2[2]), .p9(p2[3]));
    iref_74390 f8(.p1(p2[3]), .p2(rst_t), .p4(p3[0]), .p15(p3[3]), .p14(rst_t), .p12(p4[0]),
        .p3(p3[0]), .p5(p3[1]), .p6(p3[2]), .p7(p3[3]), .p13(p4[0]), .p11(p4[1]), .p10(p4[2]), .p9(p4[3]));
    assign digits = {p4, p3, p2, p1};
    // 12F (7430): 6 P-1A, 12 P-1D, 11 P-2A, 4 P-2D, 5 P-3A, 2 P-3D, 3 P-4A, 1 P-4D
    iref_7430 f12(.p6(p1[0]), .p12(p1[3]), .p11(p2[0]), .p4(p2[3]), .p5(p3[0]), .p2(p3[3]),
        .p3(p4[0]), .p1(p4[3]), .p8(n9999));
    // SP. CONT.: 13H 4, 5 -> 6; RST inverter; 13E latch 4 (15 /S, 14 /R, 13 Q)
    iref_nand2 h13c(.a(p4[1]), .b(p4[2]), .y(s13e_n));
    iref_inv   irst(.a(rst_t), .y(rst_n));
    iref_279_1 e13(.s_n(s13e_n), .r_n(rst_n), .q(sp_cont));
    // S-100: 11D 13 -> 12, 11C 12, 13 -> 11, 2E-1 sections
    iref_inv   d11(.a(p2[2]), .y(ic11d_12));
    iref_or2   c11(.a(ic11d_12), .b(p3[3]), .y(ic11c_11));
    iref_oc_buf e2a(.a(p3[0]), .y(s100[0]));      // 13 -> 12, S-100-A
    iref_oc_buf e2b(.a(p3[1]), .y(s100[1]));      // 1 -> 2, S-100-B
    iref_oc_buf e2c(.a(p3[2]), .y(s100[2]));      // 9 -> 8, S-100-C
    iref_oc_buf e2d(.a(ic11c_11), .y(s100[3]));   // 3 -> 4, S-100-D
    iref_oc_buf e2e(.a(p3[3]), .y(s100_d2));      // 11 -> 10, S-100-D'
endmodule
