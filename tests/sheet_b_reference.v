// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected, event-driven reference for sheet B (manual
// 420-0358, PDF page 29). Each package is modelled from its data sheet pin
// functions and wired by IC and pin number from the pin tables in
// docs/trace/SHEET_B_TRACE.md. Self-contained: the rb_ models below are
// written for this file.
//
// Timing rule ("settled layers", the one of tests/sheet_f_reference.v):
// - Gates, the decoder, multiplexers and the PROM take 0.01 ns, latch
//   outputs 0.02 ns, so that every combinational path settles within a
//   fraction of a nanosecond.
// - Every clock input and every asynchronous latch input goes through a
//   3 ns inertial filter (rb_filt): a shorter pulse is a hazard of the path
//   delays above, is absorbed and counted. A change that lasts a layer passes.
// - The counters act 1 ns after the filtered clock edge, reading their other
//   inputs as settled.
// The testbench changes the V lines in the same layer as M1V and M2V, as
// the sheet E counters clocked by the same /HS would.
`timescale 1ns/1ps

`ifndef TTL
`define TTL(x) ((x) === 1'bz ? 1'b1 : (x))
`endif
`define RB_G  0.01      // gate
`define RB_L  0.02      // latch
`define RB_W  3.0       // filter
`define RB_CQ 1.0       // clock to output

// Inertial filter with a hazard counter.
module rb_filt(input a, output y);
    assign #(`RB_W) y = `TTL(a);
    integer hazards = 0;
    realtime t = -1.0e9;
    always @(a) begin
        if ($realtime > 1000.0 && $realtime - t < `RB_W) hazards = hazards + 1;
        t = $realtime;
    end
endmodule

module rb_7400(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RB_G) p3 =~(`TTL(p1)&`TTL(p2));
    assign #(`RB_G) p6 =~(`TTL(p4)&`TTL(p5));
    assign #(`RB_G) p8 =~(`TTL(p9)&`TTL(p10));
    assign #(`RB_G) p11=~(`TTL(p12)&`TTL(p13));
endmodule
module rb_7404(input p1,p3,p5,p9,p11,p13, output p2,p4,p6,p8,p10,p12);
    assign #(`RB_G) p2 =~`TTL(p1);
    assign #(`RB_G) p4 =~`TTL(p3);
    assign #(`RB_G) p6 =~`TTL(p5);
    assign #(`RB_G) p8 =~`TTL(p9);
    assign #(`RB_G) p10=~`TTL(p11);
    assign #(`RB_G) p12=~`TTL(p13);
endmodule
module rb_7408(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RB_G) p3 =`TTL(p1)&`TTL(p2);
    assign #(`RB_G) p6 =`TTL(p4)&`TTL(p5);
    assign #(`RB_G) p8 =`TTL(p9)&`TTL(p10);
    assign #(`RB_G) p11=`TTL(p12)&`TTL(p13);
endmodule
module rb_7410(input p1,p2,p13,p3,p4,p5,p9,p10,p11, output p12,p6,p8);
    assign #(`RB_G) p12=~(`TTL(p1)&`TTL(p2)&`TTL(p13));
    assign #(`RB_G) p6 =~(`TTL(p3)&`TTL(p4)&`TTL(p5));
    assign #(`RB_G) p8 =~(`TTL(p9)&`TTL(p10)&`TTL(p11));
endmodule
module rb_7420(input p1,p2,p4,p5,p9,p10,p12,p13, output p6,p8);
    assign #(`RB_G) p6=~(`TTL(p1)&`TTL(p2)&`TTL(p4)&`TTL(p5));
    assign #(`RB_G) p8=~(`TTL(p9)&`TTL(p10)&`TTL(p12)&`TTL(p13));
endmodule
module rb_7427(input p1,p2,p13,p3,p4,p5,p9,p10,p11, output p12,p6,p8);
    assign #(`RB_G) p12=~(`TTL(p1)|`TTL(p2)|`TTL(p13));
    assign #(`RB_G) p6 =~(`TTL(p3)|`TTL(p4)|`TTL(p5));
    assign #(`RB_G) p8 =~(`TTL(p9)|`TTL(p10)|`TTL(p11));
endmodule
module rb_7432(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RB_G) p3 =`TTL(p1)|`TTL(p2);
    assign #(`RB_G) p6 =`TTL(p4)|`TTL(p5);
    assign #(`RB_G) p8 =`TTL(p9)|`TTL(p10);
    assign #(`RB_G) p11=`TTL(p12)|`TTL(p13);
endmodule
// BCD-to-decimal decoder: A, B, C, D = pins 15, 14, 13, 12; outputs 0..9 =
// pins 1..7, 9..11, active low; codes 10 to 15 select no output.
module rb_7442(input p15,p14,p13,p12, output p1,p2,p3,p4,p5,p6,p7,p9,p10,p11);
    wire [3:0] n = {`TTL(p12),`TTL(p13),`TTL(p14),`TTL(p15)};
    wire [9:0] y;
    genvar k;
    generate for (k=0; k<10; k=k+1) begin: dec
        assign y[k] = n != k;
    end endgenerate
    assign #(`RB_G) {p11,p10,p9,p7,p6,p5,p4,p3,p2,p1} = y;
endmodule
// 8-to-1 multiplexer: D0..D7 = pins 4, 3, 2, 1, 15, 14, 13, 12; A, B, C =
// pins 11, 10, 9; strobe G pin 7 (active low); Y pin 5, W pin 6.
module rb_74151(input p1,p2,p3,p4,p7,p9,p10,p11,p12,p13,p14,p15, output p5,p6);
    wire [7:0] d = {`TTL(p12),`TTL(p13),`TTL(p14),`TTL(p15),`TTL(p1),`TTL(p2),`TTL(p3),`TTL(p4)};
    wire [2:0] s = {`TTL(p9),`TTL(p10),`TTL(p11)};
    wire y = !`TTL(p7) && d[s];
    assign #(`RB_G) p5 = y;
    assign #(`RB_G) p6 = !y;
endmodule
// Quad 2-to-1 multiplexer: select pin 1 (low: 1A, 2A, 3A, 4A), strobe pin 15
// (active low); 1A 2, 1B 3, 1Y 4; 2A 5, 2B 6, 2Y 7; 3A 11, 3B 10, 3Y 9;
// 4A 14, 4B 13, 4Y 12.
module rb_74157(input p1,p2,p3,p5,p6,p10,p11,p13,p14,p15, output p4,p7,p9,p12);
    wire s = `TTL(p1), g = !`TTL(p15);
    assign #(`RB_G) p4  = g && (s ? `TTL(p3)  : `TTL(p2));
    assign #(`RB_G) p7  = g && (s ? `TTL(p6)  : `TTL(p5));
    assign #(`RB_G) p9  = g && (s ? `TTL(p10) : `TTL(p11));
    assign #(`RB_G) p12 = g && (s ? `TTL(p13) : `TTL(p14));
endmodule
// Synchronous 4-bit binary counter: /CLR pin 1 (asynchronous), CLK pin 2
// (rising), A..D pins 3..6, ENP pin 7, /LOAD pin 9 (synchronous, overrides
// the enables), ENT pin 10, QA..QD pins 14, 13, 12, 11,
// RCO pin 15 = ENT & QA & QB & QC & QD.
// Clock edges are changes between valid levels: the power-up transition
// from x is not an edge (also in the parts below).
module rb_74161 #(parameter [3:0] INIT = 0)(input p1,p2,p3,p4,p5,p6,p7,p9,p10, output p11,p12,p13,p14,p15);
    wire ck;
    rb_filt fck(.a(p2),.y(ck));
    wire clr_n = `TTL(p1);
    reg [3:0] q = INIT, nq;
    reg ck_l = 1'bx;
    always @(ck) begin
        if (ck_l === 1'b0 && ck === 1'b1 && clr_n) begin
            if (!`TTL(p9)) nq = {`TTL(p6),`TTL(p5),`TTL(p4),`TTL(p3)};
            else if (`TTL(p7) && `TTL(p10)) nq = q + 4'd1;
            else nq = q;
            q <= #(`RB_CQ) nq;
        end
        ck_l = ck;
    end
    always @(clr_n) if (!clr_n) q <= #(`RB_L) 0;
    assign {p11,p12,p13,p14} = q;
    assign #(`RB_G) p15 = `TTL(p10) && q == 4'hf;
endmodule
// One 74107 J-K flip-flop: J, K, /CLR (asynchronous); the outputs change
// at the falling clock edge.
module rb_74107_half(input j, k, ck_in, clr_in, output reg q = 0, output q_n);
    wire ck, clr_n;
    rb_filt fck(.a(ck_in),.y(ck));
    rb_filt fcl(.a(clr_in),.y(clr_n));
    reg ck_l = 1'bx;
    assign q_n = ~q;
    always @(ck) begin
        if (ck_l === 1'b1 && ck === 1'b0 && clr_n)
            case ({`TTL(j),`TTL(k)})
                2'b01: q <= #(`RB_CQ) 0;
                2'b10: q <= #(`RB_CQ) 1;
                2'b11: q <= #(`RB_CQ) ~q;
                default: ;
            endcase
        ck_l = ck;
    end
    always @(clr_n) if (!clr_n) q <= #(`RB_L) 0;
endmodule
// One 7474 half: /CLR pin 1 (13), D pin 2 (12), CK pin 3 (11), /PR pin 4
// (10), Q pin 5 (9), /Q pin 6 (8). Both /PR and /CLR low drives both
// outputs high.
module rb_7474_half(input clr_in, d, ck_in, pr_in, output reg q = 0, output q_n);
    wire ck, clr_n, pr_n;
    rb_filt fck(.a(ck_in),.y(ck));
    rb_filt fcl(.a(clr_in),.y(clr_n));
    rb_filt fpr(.a(pr_in),.y(pr_n));
    reg ck_l = 1'bx;
    assign #(`RB_L) q_n = (!clr_n && !pr_n) ? 1'b1 : ~q;
    always @(clr_n or pr_n)
        if (!pr_n) q <= #(`RB_L) 1;
        else if (!clr_n) q <= #(`RB_L) 0;
    always @(ck) begin
        if (ck_l === 1'b0 && ck === 1'b1 && clr_n && pr_n) q <= #(`RB_CQ) `TTL(d);
        ck_l = ck;
    end
endmodule
// One 74279 latch with a single /S input: Q goes high while /S is low, low
// while only /R is low.
module rb_279_latch(input s_in, r_in, output reg q = 0);
    wire s_n, r_n;
    rb_filt fs(.a(s_in),.y(s_n));
    rb_filt fr(.a(r_in),.y(r_n));
    always @(s_n or r_n)
        if (!s_n) q <= #(`RB_L) 1;
        else if (!r_n) q <= #(`RB_L) 0;
endmodule
// 512 x 8 PROM (7641 pin-out): A0..A7 = pins 8..1, A8 = pin 23; O1..O8 =
// pins 9, 10, 11, 13..17; enabled while pins 20 and 21 are low and 18 and 19
// high. OFFSET is the device's place in the +ROM image.
module rb_7641 #(parameter integer OFFSET = 0)(
    input p1,p2,p3,p4,p5,p6,p7,p8,p18,p19,p20,p21,p23,
    output p9,p10,p11,p13,p14,p15,p16,p17
);
    reg [7:0] image [0:8799];
    reg [1023:0] path;
    initial begin
        if (!$value$plusargs("ROM=%s",path)) $fatal(1,"rb_7641: missing +ROM");
        $readmemh(path,image);
    end
    wire [8:0] a = {`TTL(p23),`TTL(p1),`TTL(p2),`TTL(p3),`TTL(p4),`TTL(p5),`TTL(p6),`TTL(p7),`TTL(p8)};
    wire en = !`TTL(p20) && !`TTL(p21) && `TTL(p19) && `TTL(p18);
    assign #(`RB_G) {p17,p16,p15,p14,p13,p11,p10,p9} = en ? image[OFFSET+a] : 8'bz;
endmodule

module sheet_b_reference #(
    // Power-up contents of M1V and M2V
    parameter [7:0] M1V_INIT = 8'd0,
    parameter [7:0] M2V_INIT = 8'd0
)(
    // Sheet E
    input        b_7m,              // 7M: IC118, IC103 pin 2
    input  [8:0] b_h,               // H0..H8
    input        b_h5_n, b_h8_n,    // /H5, /H8
    input        b_hs_n,            // /HS
    input  [7:1] b_v,               // V1..V7
    input        b_v4_n, b_v8_n,    // /V4, /V8
    input        b_vca_v8_n,        // /(V-CA x V8)
    // Sheet H
    input        b_sp_a, b_sp_b, b_sp_c, b_sp_d,
    input        b_vs2, b_vs4, b_vs16,
    // Sheet A
    input        b_coin_in_ed_n, b_coin_in_e1_n, b_ex_signal_n, b_game_n, b_in_reset_n,
    // Sheet D
    input        b_tunnel_bridge_n,
    // Outputs
    output [8:0] mh,
    output       mhld_n,
    output [7:0] m1v, m2v,
    output       m1vld_n, m2vld_n,
    output [5:1] vdec_n,
    output       ex_gameover_n, coin_start_n,
    // Internal nets
    output       q1, q2, q68, vsel, strobe_n, txt
);
    wire vcc = 1'b1, gnd = 1'b0, nc = 1'bz;

    // ------------------------------------------------------------ text
    wire n64_9, n64_10, n64_11, n64_13, n64_14, n64_15, n64_16, n64_17;
    rb_7641 #(.OFFSET(4096)) ic64(
        .p8(b_v[1]),.p7(b_v[2]),.p6(b_v[3]),.p5(b_v[4]),.p4(b_v[5]),.p3(b_v[6]),
        .p2(b_h[3]),.p1(b_h[8]),.p23(b_coin_in_ed_n),
        .p18(vcc),.p19(vcc),.p20(gnd),.p21(gnd),
        .p9(n64_9),.p10(n64_10),.p11(n64_11),.p13(n64_13),.p14(n64_14),
        .p15(n64_15),.p16(n64_16),.p17(n64_17));
    wire ic70_6, ic63_5;
    rb_74151 ic63(.p4(n64_9),.p3(n64_10),.p2(n64_11),.p1(n64_13),.p15(n64_14),
        .p14(n64_15),.p13(n64_16),.p12(n64_17),.p11(b_h[0]),.p10(b_h[1]),.p9(b_h[2]),
        .p7(ic70_6),.p5(ic63_5),.p6(txt));
    wire ic68_13, ic71_6, ic71_8, ic72_6;
    rb_7420 ic71(.p1(b_h[4]),.p2(b_h[7]),.p4(b_h[6]),.p5(ic68_13),.p6(ic71_6),
        .p9(b_h8_n),.p10(b_vs16),.p12(b_h[5]),.p13(ic72_6),.p8(ic71_8));
    wire ic72_3, ic72_8, ic72_11;
    rb_7400 ic72(.p4(b_ex_signal_n),.p5(b_coin_in_e1_n),.p6(ic72_6),
        .p1(nc),.p2(nc),.p3(ic72_3),.p9(nc),.p10(nc),.p8(ic72_8),.p12(nc),.p13(nc),.p11(ic72_11));
    // IC55: gate 3, 4, 5 -> 6 (text) and gate 9, 10, 11 -> 8 (/MHLD; the
    // lowest input is printed like "1", pin 9 on a 7410, trace U3).
    wire ic55_6, ic55_8, ic55_12, tc118, tc103, mh8;
    rb_7410 ic55(.p3(b_game_n),.p4(b_h[8]),.p5(b_h5_n),.p6(ic55_6),
        .p9(tc118),.p10(tc103),.p11(mh8),.p8(ic55_8),
        .p1(nc),.p2(nc),.p13(nc),.p12(ic55_12));
    wire ic52_6, ic52_3, ic52_8, ic52_11;
    rb_7408 ic52(.p4(ic55_6),.p5(ic71_8),.p6(ic52_6),
        .p1(nc),.p2(nc),.p3(ic52_3),.p9(nc),.p10(nc),.p8(ic52_8),.p12(nc),.p13(nc),.p11(ic52_11));
    // IC70: three OR gates, and the undesignated UG1 drawn with pins 1, 2 -> 3,
    // which match IC70's fourth gate (the KiCad redraw places it there).
    wire ic70_3, ic70_8, ic70_11, r2;
    wire [7:0] d;
    rb_7432 ic70(.p4(ic71_6),.p5(ic52_6),.p6(ic70_6),
        .p12(txt),.p13(ic71_8),.p11(ic70_11),
        .p9(ic55_6),.p10(txt),.p8(ic70_8),
        .p1(r2),.p2(d[5]),.p3(ic70_3));
    assign ex_gameover_n = ic70_11;
    assign coin_start_n = ic70_8;
    assign strobe_n = ic70_6;

    // ------------------------------------------------------------ decoder
    wire ic54_1, ic54_10, ic54_11;
    rb_7442 ic54(.p15(b_v[5]),.p14(b_v[6]),.p13(b_v[7]),.p12(gnd),
        .p1(ic54_1),.p2(d[1]),.p3(d[2]),.p4(d[3]),.p5(d[4]),.p6(d[5]),.p7(d[6]),.p9(d[7]),
        .p10(ic54_10),.p11(ic54_11));
    assign d[0] = ic54_1;
    assign vdec_n = d[5:1];
    rb_279_latch ic68(.s_in(d[2]),.r_in(d[6]),.q(ic68_13));     // pins 15, 14 -> 13
    assign q68 = ic68_13;

    // ------------------------------------------------------------ MH
    wire ic111_4, ic111_7, ic111_9, ic111_12;
    rb_74157 ic111(.p1(b_vca_v8_n),.p15(gnd),
        .p2(b_sp_a),.p3(gnd),.p4(ic111_4),
        .p5(b_sp_b),.p6(gnd),.p7(ic111_7),
        .p11(b_sp_c),.p10(vcc),.p9(ic111_9),
        .p14(b_sp_d),.p13(vcc),.p12(ic111_12));
    rb_74161 ic118(.p1(vcc),.p2(b_7m),.p3(gnd),.p4(ic111_4),.p5(ic111_7),.p6(ic111_9),
        .p7(vcc),.p9(ic55_8),.p10(vcc),
        .p14(mh[0]),.p13(mh[1]),.p12(mh[2]),.p11(mh[3]),.p15(tc118));
    rb_74161 ic103(.p1(vcc),.p2(b_7m),.p3(ic111_12),.p4(vcc),.p5(gnd),.p6(gnd),
        .p7(vcc),.p9(ic55_8),.p10(tc118),
        .p14(mh[4]),.p13(mh[5]),.p12(mh[6]),.p11(mh[7]),.p15(tc103));
    wire mh8_n;
    rb_74107_half ic57(.j(vcc),.k(vcc),.ck_in(tc103),.clr_in(vcc),.q(mh8),.q_n(mh8_n));
    assign mh[8] = mh8;
    assign mhld_n = ic55_8;

    // ------------------------------------------------------------ VSEL
    wire ic110_11, ic110_3, ic110_6, ic110_8;
    rb_7400 ic110(.p13(b_sp_c),.p12(b_sp_d),.p11(ic110_11),
        .p1(nc),.p2(nc),.p3(ic110_3),.p4(nc),.p5(nc),.p6(ic110_6),.p9(nc),.p10(nc),.p8(ic110_8));
    wire ic95_8, ic95_3, ic95_6, ic95_11;
    rb_7408 ic95(.p9(b_tunnel_bridge_n),.p10(ic110_11),.p8(ic95_8),
        .p1(nc),.p2(nc),.p3(ic95_3),.p4(nc),.p5(nc),.p6(ic95_6),.p12(nc),.p13(nc),.p11(ic95_11));
    wire ic94_12, ic94_6, ic94_8;
    rb_7410 ic94(.p1(b_vs4),.p2(b_vs2),.p13(ic95_8),.p12(ic94_12),
        .p3(nc),.p4(nc),.p5(nc),.p6(ic94_6),.p9(nc),.p10(nc),.p11(nc),.p8(ic94_8));
    wire ic87_3, ic87_6, ic87_8, ic87_11;
    rb_7408 ic87(.p1(b_in_reset_n),.p2(ic94_12),.p3(ic87_3),
        .p4(nc),.p5(nc),.p6(ic87_6),.p9(nc),.p10(nc),.p8(ic87_8),.p12(nc),.p13(nc),.p11(ic87_11));
    assign vsel = ic87_3;

    // ------------------------------------------------------------ M1V, M2V
    wire r1, q1_n, q2_n;
    wire ic83_4, ic83_7, ic83_9, ic83_12, ic84_4, ic84_7, ic84_9, ic84_12;
    rb_74157 ic83(.p1(ic87_3),.p15(gnd),
        .p2(vcc),.p3(gnd),.p4(ic83_4),
        .p5(q1),.p6(gnd),.p7(ic83_7),
        .p11(q1),.p10(gnd),.p9(ic83_9),
        .p14(q1_n),.p13(vcc),.p12(ic83_12));
    rb_74157 ic84(.p1(ic87_3),.p15(gnd),
        .p2(vcc),.p3(gnd),.p4(ic84_4),
        .p5(q2),.p6(gnd),.p7(ic84_7),
        .p11(q2),.p10(gnd),.p9(ic84_9),
        .p14(q2_n),.p13(vcc),.p12(ic84_12));
    wire tc85, tc76, tc91, tc77;
    rb_74161 #(.INIT(M1V_INIT[3:0])) ic85(.p1(vcc),.p2(b_hs_n),.p3(ic83_4),.p4(ic83_7),.p5(ic83_9),.p6(ic83_12),
        .p7(vcc),.p9(r1),.p10(b_v8_n),
        .p14(m1v[0]),.p13(m1v[1]),.p12(m1v[2]),.p11(m1v[3]),.p15(tc85));
    rb_74161 #(.INIT(M1V_INIT[7:4])) ic76(.p1(vcc),.p2(b_hs_n),.p3(gnd),.p4(gnd),.p5(gnd),.p6(gnd),
        .p7(vcc),.p9(r1),.p10(tc85),
        .p14(m1v[4]),.p13(m1v[5]),.p12(m1v[6]),.p11(m1v[7]),.p15(tc76));
    rb_74161 #(.INIT(M2V_INIT[3:0])) ic91(.p1(vcc),.p2(b_hs_n),.p3(ic84_4),.p4(ic84_7),.p5(ic84_9),.p6(ic84_12),
        .p7(vcc),.p9(r2),.p10(b_v8_n),
        .p14(m2v[0]),.p13(m2v[1]),.p12(m2v[2]),.p11(m2v[3]),.p15(tc91));
    rb_74161 #(.INIT(M2V_INIT[7:4])) ic77(.p1(vcc),.p2(b_hs_n),.p3(gnd),.p4(gnd),.p5(gnd),.p6(gnd),
        .p7(vcc),.p9(r2),.p10(tc91),
        .p14(m2v[4]),.p13(m2v[5]),.p12(m2v[6]),.p11(m2v[7]),.p15(tc77));
    wire ic61_12, ic61_6, ic61_8;
    rb_7427 ic61(.p13(d[1]),.p1(b_v[4]),.p2(r1),.p12(ic61_12),
        .p3(d[2]),.p5(b_v4_n),.p4(r1),.p6(ic61_6),
        .p9(d[7]),.p10(b_v4_n),.p11(r2),.p8(ic61_8));
    wire ic62_2, ic62_6, ic62_10, ic62_12;
    rb_7404 ic62(.p3(tc76),.p4(r1),.p9(tc77),.p8(r2),
        .p11(ic61_12),.p10(ic62_10),.p1(ic61_6),.p2(ic62_2),.p13(ic61_8),.p12(ic62_12),
        .p5(nc),.p6(ic62_6));
    assign m1vld_n = r1;
    assign m2vld_n = r2;
    // IC69: D and CK not drawn (open inputs).
    rb_7474_half ic69a(.clr_in(ic62_12),.d(nc),.ck_in(nc),.pr_in(ic70_3),.q(q2),.q_n(q2_n));  // pins 1..6
    rb_7474_half ic69b(.clr_in(ic62_2),.d(nc),.ck_in(nc),.pr_in(ic62_10),.q(q1),.q_n(q1_n)); // pins 13..8
endmodule
