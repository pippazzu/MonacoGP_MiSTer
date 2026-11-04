// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected, event-driven reference for the sheet G headlight,
// explosion and splash paths (manual 420-0358, PDF page 27). Each package is
// modelled from its data sheet pin functions and wired by IC and pin number
// from docs/trace/SHEET_G_TRACE.md. The gate packages, the 74279 and the 7641
// come from tests/sheet_g_reference.v (compile both). HC and VC are inputs:
// the counters belong to the player path, checked by tb_player.
// Delays only enforce settling order; they are NOT measured TTL delays. The
// 470 pF capacitors on IC58 pin 6 (EQ) and IC56 pin 8 are modelled as 20 ns
// inertial filters (shorter pulses are lost).
`timescale 1ns/1ps
`ifndef TTL
`define TTL(x) ((x) === 1'bz ? 1'b1 : (x))
`endif

// 4-bit magnitude comparator; outputs A>B pin 5, A=B pin 6, A<B pin 7.
// Cascade inputs A<B pin 2, A=B pin 3, A>B pin 4.
module ref_7485(input p10,p12,p13,p15, p9,p11,p14,p1, p2,p3,p4, output p5,p6,p7);
    wire [3:0] a = {`TTL(p15),`TTL(p13),`TTL(p12),`TTL(p10)};
    wire [3:0] b = {`TTL(p1),`TTL(p14),`TTL(p11),`TTL(p9)};
    wire lt = `TTL(p2), eqi = `TTL(p3), gt = `TTL(p4);
    // Data sheet function table for A = B: A=B in high gives A=B out high and
    // the others low; otherwise the outputs follow A>B in and A<B in inverted
    // as listed (L, L, L for H, H, L cascade inputs is not used here).
    assign #3 p5 = a > b || (a == b && !eqi && !lt);
    assign #3 p7 = a < b || (a == b && !eqi && !gt);
    assign #3 p6 = a == b && eqi;
endmodule
// 8-input multiplexer: D0..D7 pins 4, 3, 2, 1, 15, 14, 13, 12; A, B, C pins
// 11, 10, 9; /G pin 7; Y pin 5, /W pin 6.
module ref_74151(input p4,p3,p2,p1,p15,p14,p13,p12, p11,p10,p9, p7, output p5,p6);
    wire [7:0] d = {`TTL(p12),`TTL(p13),`TTL(p14),`TTL(p15),`TTL(p1),`TTL(p2),`TTL(p3),`TTL(p4)};
    wire [2:0] s = {`TTL(p9),`TTL(p10),`TTL(p11)};
    assign #3 p5 = !`TTL(p7) && d[s];
    assign #3 p6 = !(!`TTL(p7) && d[s]);
endmodule
// Triple 3-input NOR.
module ref_7427(input p1,p2,p13,p3,p4,p5,p9,p10,p11, output p12,p6,p8);
    assign #2 p12=~(`TTL(p1)|`TTL(p2)|`TTL(p13));
    assign #2 p6 =~(`TTL(p3)|`TTL(p4)|`TTL(p5));
    assign #2 p8 =~(`TTL(p9)|`TTL(p10)|`TTL(p11));
endmodule

module sheet_g_effects_reference(
    input [7:0] hc, vc,
    input       hwin, vwin, ic66_3,
    input       acc1_n, tunnel_n, explo_st, explo_st_n,
    input [3:0] explo_sel,
    input       splay_a_n, splay_b,
    output      light_n, explo_r_n, explo_y_n, explo_area_n, splay_n,
    output      eq, w, splash_win
);
    wire hi = 1'b1, lo = 1'b0, nc = 1'bz;
    // PR-125 (IC59)
    wire [7:0] d125;
    wire ic46_8, ic46_10;
    ref_7641 #(.OFFSET(0)) ic59(
        .p8(vc[0]),.p7(vc[1]),.p6(vc[2]),.p5(vc[3]),.p4(vc[4]),.p3(vc[5]),.p2(vc[6]),
        .p1(ic46_8),.p23(lo),.p20(lo),.p21(lo),.p18(acc1_n),.p19(acc1_n),
        .p9(d125[0]),.p10(d125[1]),.p11(d125[2]),.p13(d125[3]),
        .p14(d125[4]),.p15(d125[5]),.p16(d125[6]),.p17(d125[7]));
    // IC53, IC58 (7485)
    wire ic53_6, ic58_6;
    ref_7485 ic53(.p10(hc[0]),.p12(hc[1]),.p13(hc[2]),.p15(hc[3]),
        .p9(d125[0]),.p11(d125[1]),.p14(d125[2]),.p1(d125[3]),
        .p2(hi),.p3(ic46_10),.p4(hi),.p5(),.p6(ic53_6),.p7());
    ref_7485 ic58(.p10(hc[4]),.p12(hc[5]),.p13(hc[6]),.p15(hc[7]),
        .p9(d125[4]),.p11(d125[5]),.p14(d125[6]),.p1(d125[7]),
        .p2(hi),.p3(ic53_6),.p4(hi),.p5(),.p6(ic58_6),.p7());
    wire eq_f;
    assign #20 eq_f = ic58_6;                   // C26 470 pF
    assign eq = ic58_6;
    // IC46 (7404): 11 -> 10, 9 -> 8 (the other sections belong to the player path)
    wire ic57_8;
    ref_7404 ic46(.p1(nc),.p3(nc),.p5(nc),.p9(ic57_8),.p11(vc[7]),.p13(nc),
        .p2(),.p4(),.p6(),.p8(ic46_8),.p10(ic46_10),.p12());
    // IC57 (7425): second gate 9, 10, 12, 13 -> 8, strobe pin 11 not drawn
    ref_7425 ic57(.p1(nc),.p2(nc),.p3(nc),.p4(nc),.p5(nc),
        .p9(hc[7]),.p10(hc[6]),.p11(nc),.p12(hc[5]),.p13(tunnel_n),.p6(),.p8(ic57_8));
    assign w = ic57_8;
    // IC56 (7400): 1, 2 -> 3; 4, 5 -> 6; 9, 10 -> 8; 12, 13 -> 11
    wire ic56_3, ic56_6, ic56_8, ic56_11, ic63_10, ic64_5;
    ref_7400 ic56(.p1(ic63_10),.p2(ic64_5),.p4(vwin),.p5(hwin),.p9(ic57_8),.p10(eq_f),
        .p12(eq_f),.p13(ic46_8),.p3(ic56_3),.p6(ic56_6),.p8(ic56_8),.p11(ic56_11));
    wire ic56_8f;
    assign #20 ic56_8f = ic56_8;                // C39 470 pF
    // IC48 (7400): 4, 5 -> 6; 12, 13 -> 11
    wire ic48_6, ic48_11, ic44_12, ic44_4, ic74_6;
    ref_7400 ic48(.p1(hi),.p2(hi),.p4(vc[4]),.p5(ic44_12),.p9(hi),.p10(hi),.p12(vc[4]),.p13(vc[5]),
        .p3(),.p6(ic48_6),.p8(),.p11(ic48_11));
    // IC44 (7404): 3 -> 4, 13 -> 12
    ref_7404 ic44(.p1(nc),.p3(ic74_6),.p5(nc),.p9(nc),.p11(nc),.p13(vc[5]),
        .p2(),.p4(ic44_4),.p6(),.p8(),.p10(),.p12(ic44_12));
    // IC51 (74279): latch 3 pins 10, 11, 12 -> 9; latch 4 pins 14, 15 -> 13
    wire ic51_9, ic51_13;
    ref_74279 ic51(.p1(hi),.p2(hi),.p3(hi),.p5(hi),.p6(hi),
        .p10(ic56_8f),.p11(ic66_3),.p12(ic56_11),.p14(ic48_11),.p15(ic48_6),
        .p4(),.p7(),.p9(ic51_9),.p13(ic51_13));
    assign light_n = ic51_9;
    assign splash_win = ic51_13;
    // IC74 (7427): 3, 4, 5 -> 6
    ref_7427 ic74(.p1(hi),.p2(hi),.p13(hi),.p3(explo_st_n),.p4(explo_sel[3]),.p5(ic56_6),
        .p9(hi),.p10(hi),.p11(hi),.p12(),.p6(ic74_6),.p8());
    // PR-126 (IC65)
    wire [7:0] d126;
    ref_7641 #(.OFFSET(512)) ic65(
        .p8(vc[0]),.p7(vc[1]),.p6(vc[2]),.p5(vc[3]),.p4(vc[4]),.p3(hc[3]),.p2(hc[4]),
        .p1(explo_sel[0]),.p23(explo_sel[1]),.p20(lo),.p21(lo),.p18(explo_st),.p19(explo_st),
        .p9(d126[0]),.p10(d126[1]),.p11(d126[2]),.p13(d126[3]),
        .p14(d126[4]),.p15(d126[5]),.p16(d126[6]),.p17(d126[7]));
    // IC64 (74151)
    wire ic64_6;
    ref_74151 ic64(.p4(d126[0]),.p3(d126[1]),.p2(d126[2]),.p1(d126[3]),
        .p15(d126[4]),.p14(d126[5]),.p13(d126[6]),.p12(d126[7]),
        .p11(hc[0]),.p10(hc[1]),.p9(hc[2]),.p7(ic44_4),.p5(ic64_5),.p6(ic64_6));
    assign explo_area_n = ic64_6;
    // IC63 (7402): 8, 9 -> 10
    ref_7402 ic63(.p2(nc),.p3(nc),.p5(nc),.p6(nc),.p8(explo_sel[2]),.p9(explo_sel[0]),.p11(nc),.p12(nc),
        .p1(),.p4(),.p10(ic63_10),.p13());
    // IC62 (7432): 12, 13 -> 11
    wire ic62_11;
    ref_7432 ic62(.p1(nc),.p2(nc),.p4(nc),.p5(nc),.p9(nc),.p10(nc),.p12(ic64_6),.p13(ic63_10),
        .p3(),.p6(),.p8(),.p11(ic62_11));
    assign explo_r_n = ic62_11;
    assign explo_y_n = ic56_3;
    // PR-131 (IC71)
    wire [7:0] d131;
    ref_7641 #(.OFFSET(3072)) ic71(
        .p8(vc[0]),.p7(vc[1]),.p6(vc[2]),.p5(vc[3]),.p4(vc[4]),.p3(hc[3]),.p2(hc[4]),
        .p1(splay_a_n),.p23(vc[6]),.p20(lo),.p21(lo),.p18(hi),.p19(hi),
        .p9(d131[0]),.p10(d131[1]),.p11(d131[2]),.p13(d131[3]),
        .p14(d131[4]),.p15(d131[5]),.p16(d131[6]),.p17(d131[7]));
    // IC45 (7410): 9, 10, 11 -> 8
    wire ic45_8;
    ref_7410 ic45(.p1(hi),.p2(hi),.p13(hi),.p3(hi),.p4(hi),.p5(hi),
        .p9(hwin),.p10(ic51_13),.p11(splay_b),.p12(),.p6(),.p8(ic45_8));
    // IC70 (74151)
    wire ic70_6;
    ref_74151 ic70(.p4(d131[0]),.p3(d131[1]),.p2(d131[2]),.p1(d131[3]),
        .p15(d131[4]),.p14(d131[5]),.p13(d131[6]),.p12(d131[7]),
        .p11(hc[0]),.p10(hc[1]),.p9(hc[2]),.p7(ic45_8),.p5(),.p6(ic70_6));
    assign splay_n = ic70_6;
endmodule
