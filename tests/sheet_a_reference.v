// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected, event-driven reference for sheet A (manual
// 420-0358, PDF page 25). Each package is modelled from its data sheet pin
// functions and wired by IC and pin number from the consolidated pin list in
// docs/trace/SHEET_A_TRACE.md. Self-contained: the ra_ models below are
// written for this file.
//
// Timing rule ("settled layers", the one of tests/sheet_f_reference.v):
// - Gates take 0.01 ns, latches and asynchronous inputs 0.02 ns.
// - Every clock, trigger and asynchronous clear, preset, load and latch input
//   goes through a 3 ns inertial filter (ra_filt), which absorbs and counts
//   hazards; flip-flops and counters act 1 ns after the filtered edge.
// - The 555, the one-shots and the RC pulse shapers count 7 MHz periods: at
//   each rising f7 they read their settled inputs, and their outputs change
//   5 ns later, when the testbench changes the other sheets' nets too.
`timescale 1ns/1ps

`ifndef TTL
`define TTL(x) ((x) === 1'bz ? 1'b1 : (x))
`endif
`define RA_G  0.01
`define RA_L  0.02
`define RA_W  3.0
`define RA_CQ 1.0
`define RA_T  5.0       // timed elements, after the f7 edge

module ra_filt(input a, output y);
    assign #(`RA_W) y = `TTL(a);
    integer hazards = 0;
    realtime t = -1.0e9;
    always @(a) begin
        if ($realtime > 1000.0 && $realtime - t < `RA_W) hazards = hazards + 1;
        t = $realtime;
    end
endmodule

module ra_7400(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RA_G) p3 =~(`TTL(p1)&`TTL(p2));
    assign #(`RA_G) p6 =~(`TTL(p4)&`TTL(p5));
    assign #(`RA_G) p8 =~(`TTL(p9)&`TTL(p10));
    assign #(`RA_G) p11=~(`TTL(p12)&`TTL(p13));
endmodule
module ra_7402(input p2,p3,p5,p6,p8,p9,p11,p12, output p1,p4,p10,p13);
    assign #(`RA_G) p1 =~(`TTL(p2)|`TTL(p3));
    assign #(`RA_G) p4 =~(`TTL(p5)|`TTL(p6));
    assign #(`RA_G) p10=~(`TTL(p8)|`TTL(p9));
    assign #(`RA_G) p13=~(`TTL(p11)|`TTL(p12));
endmodule
module ra_7404(input p1,p3,p5,p9,p11,p13, output p2,p4,p6,p8,p10,p12);
    assign #(`RA_G) p2 =~`TTL(p1);
    assign #(`RA_G) p4 =~`TTL(p3);
    assign #(`RA_G) p6 =~`TTL(p5);
    assign #(`RA_G) p8 =~`TTL(p9);
    assign #(`RA_G) p10=~`TTL(p11);
    assign #(`RA_G) p12=~`TTL(p13);
endmodule
// 7407 open-collector buffers; the pull-ups are on the other boards.
module ra_7407(input p1,p3,p5,p9,p11,p13, output p2,p4,p6,p8,p10,p12);
    assign #(`RA_G) {p2,p4,p6,p8,p10,p12} = {`TTL(p1),`TTL(p3),`TTL(p5),`TTL(p9),`TTL(p11),`TTL(p13)};
endmodule
module ra_7408(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RA_G) p3 =`TTL(p1)&`TTL(p2);
    assign #(`RA_G) p6 =`TTL(p4)&`TTL(p5);
    assign #(`RA_G) p8 =`TTL(p9)&`TTL(p10);
    assign #(`RA_G) p11=`TTL(p12)&`TTL(p13);
endmodule
module ra_7411(input p1,p2,p13,p3,p4,p5,p9,p10,p11, output p12,p6,p8);
    assign #(`RA_G) p12=`TTL(p1)&`TTL(p2)&`TTL(p13);
    assign #(`RA_G) p6 =`TTL(p3)&`TTL(p4)&`TTL(p5);
    assign #(`RA_G) p8 =`TTL(p9)&`TTL(p10)&`TTL(p11);
endmodule
module ra_7427(input p1,p2,p13,p3,p4,p5,p9,p10,p11, output p12,p6,p8);
    assign #(`RA_G) p12=~(`TTL(p1)|`TTL(p2)|`TTL(p13));
    assign #(`RA_G) p6 =~(`TTL(p3)|`TTL(p4)|`TTL(p5));
    assign #(`RA_G) p8 =~(`TTL(p9)|`TTL(p10)|`TTL(p11));
endmodule
module ra_7432(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RA_G) p3 =`TTL(p1)|`TTL(p2);
    assign #(`RA_G) p6 =`TTL(p4)|`TTL(p5);
    assign #(`RA_G) p8 =`TTL(p9)|`TTL(p10);
    assign #(`RA_G) p11=`TTL(p12)|`TTL(p13);
endmodule
// One 7474 half: /CLR, D, CK, /PR, Q, /Q. Both /PR and /CLR low drives both
// outputs high. Clock edges are changes between valid levels.
module ra_7474_half(input clr_in, d, ck_in, pr_in, output reg q = 0, output q_n);
    wire ck, clr_n, pr_n;
    ra_filt fck(.a(ck_in),.y(ck));
    ra_filt fcl(.a(clr_in),.y(clr_n));
    ra_filt fpr(.a(pr_in),.y(pr_n));
    reg ck_l = 1'bx;
    assign #(`RA_L) q_n = (!clr_n && !pr_n) ? 1'b1 : ~q;
    always @(clr_n or pr_n)
        if (!pr_n) q <= #(`RA_L) 1;
        else if (!clr_n) q <= #(`RA_L) 0;
    always @(ck) begin
        if (ck_l === 1'b0 && ck === 1'b1 && clr_n && pr_n) q <= #(`RA_CQ) `TTL(d);
        ck_l = ck;
    end
endmodule
// One 74279 latch with one or two /S inputs: Q high while a /S is low, low
// while only /R is low. It looks at its filtered inputs 0.02 ns after one of
// them changes, so that inputs released together hold it.
module ra_279_latch(input s1_in, s2_in, r_in, output reg q = 0);
    wire s1_n, s2_n, r_n;
    ra_filt fs1(.a(s1_in),.y(s1_n));
    ra_filt fs2(.a(s2_in),.y(s2_n));
    ra_filt fr(.a(r_in),.y(r_n));
    always @(s1_n or s2_n or r_n) begin
        #(`RA_L);
        if (!s1_n || !s2_n) q = 1;
        else if (!r_n) q = 0;
    end
endmodule
// 74192 synchronous BCD up/down counter: B 1, QB 2, QA 3, CPD 4, CPU 5,
// QC 6, QD 7, D 9, C 10, /LOAD 11, /CO 12, /BO 13, CLR 14, A 15. CLR (high)
// and /LOAD (low) are asynchronous, CLR first; it counts down at a rising
// CPD while CPU is high. /BO is low while CPD is low at count 0.
module ra_74192(input p1,p4,p5,p9,p10,p11,p14,p15, output p2,p3,p6,p7,p12,p13);
    wire cpd, ld_n, clr;
    ra_filt fcp(.a(p4),.y(cpd));
    ra_filt fld(.a(p11),.y(ld_n));
    ra_filt fcl(.a(p14),.y(clr));
    reg [3:0] q = 0;
    reg cpd_l = 1'bx;
    always @(clr or ld_n or p15 or p1 or p10 or p9)
        if (clr) q <= #(`RA_L) 0;
        else if (!ld_n) q <= #(`RA_L) {`TTL(p9),`TTL(p10),`TTL(p1),`TTL(p15)};
    always @(cpd) begin
        if (cpd_l === 1'b0 && cpd === 1'b1 && !clr && ld_n && `TTL(p5))
            q <= #(`RA_CQ) q == 0 ? 4'd9 : q - 4'd1;
        cpd_l = cpd;
    end
    assign {p7,p6,p2,p3} = q;
    assign #(`RA_G) p13 = ~(q == 0 && !`TTL(p4));
    assign #(`RA_G) p12 = ~(q == 9 && !`TTL(p5));
endmodule
// One 74393 half: clock (falling edge), MR (asynchronous, high), QA..QD.
module ra_74393_half(input ck_in, mr_in, output reg [3:0] q = 0);
    wire ck, mr;
    ra_filt fck(.a(ck_in),.y(ck));
    ra_filt fmr(.a(mr_in),.y(mr));
    reg ck_l = 1'bx;
    always @(mr) if (mr) q <= #(`RA_L) 0;
    always @(ck) begin
        if (ck_l === 1'b1 && ck === 1'b0 && !mr) q <= #(`RA_CQ) q + 4'd1;
        ck_l = ck;
    end
endmodule
// One half of a 74123 retriggerable monostable, /CLR at Vcc: A (active low),
// B, Q, /Q. Triggers: A falling while B is high, B rising while A is low;
// the filtered inputs are evaluated together 0.5 ns after the first of them
// changes. PIXELS 7 MHz periods; RUN = 1 starts with a pulse running.
module ra_74123 #(parameter integer PIXELS = 1, RUN = 0)(input a, b, f7, output reg q = RUN, output q_n);
    integer left = RUN ? PIXELS : 0, trigs = 0;
    wire ta, tb;
    ra_filt fa(.a(a),.y(ta));
    ra_filt fb(.a(b),.y(tb));
    reg ta_l = 1, tb_l = 1;
    assign q_n = ~q;
    always @(ta or tb) begin
        #0.5;
        if ((ta_l && !ta && tb) || (!tb_l && tb && !ta)) begin
            trigs = trigs + 1;
            left = PIXELS;
            q <= #0.5 1;
        end
        ta_l = ta; tb_l = tb;
    end
    always @(posedge f7) if (left > 0) begin
        left = left - 1;
        if (left == 0) q <= #(`RA_T) 0;
    end
endmodule
// 555 astable with its reset (pin 4): output low while reset is low; when
// released, high for FIRST periods (the capacitor charging from 0 V), then
// LOW and HIGH periods in turn.
module ra_555 #(parameter integer FIRST = 1, HIGH = 1, LOW = 1)(input rst_n, f7, output reg q = 0);
    integer left = 0;
    reg armed = 1;
    always @(posedge f7) begin
        if (!`TTL(rst_n)) begin
            q <= #(`RA_T) 0;
            armed = 1;
        end else if (armed) begin
            q <= #(`RA_T) 1;
            armed = 0;
            left = FIRST;
        end else if (left > 1) left = left - 1;
        else begin
            left = q ? LOW : HIGH;
            q <= #(`RA_T) ~q;
        end
    end
endmodule
// RC low-pass as seen by the next gate's input threshold: the input level
// reaches the output N 7 MHz periods later.
module ra_rc #(parameter integer N = 2, parameter INIT = 1'b0)(input a, f7, output reg y = INIT);
    reg [N-1:0] sr = {N{INIT}};
    always @(posedge f7) begin
        sr = {sr[N-2:0], `TTL(a)};
        y <= #(`RA_T) sr[N-1];
    end
endmodule

module sheet_a_reference #(
    parameter integer TILT_PIXELS = 44898531, IC49_PIXELS = 9552879, HI_PIXELS = 9553,
    parameter integer T555_FIRST = 5650562, T555_HIGH = 3565107, T555_LOW = 2796163,
    parameter integer RC_PIXELS = 2, POWERUP_TILT = 1
)(
    input        f7,
    // Cabinet: contact levels at the pads (0 = closed to the common at GND)
    input        a_aa, a_a23,       // COIN SW upper, lower
    input        a_ab, a_a24,       // TEST SW upper, lower
    input        a_aq, a_a32,       // CREDIT SW upper, lower
    input        a_two_play,        // changeover switch at 1 COIN 2 PLAY
    input        a_aj,              // TILT SW node
    // Other sheets
    input        a_acce_st, a_game_over, a_v2, a_vs16, a_a30,
    // Outputs, as the RTL's
    output       game, game_n, coin_in, coin_in_n, coin_test_n, extend, extend_n,
    output       ex_signal_n, ex_signal_cp_n, ex_cp, car_cont_cl, pts8000, mute, hiscore_n,
    output       ini_reset_n,
    output [3:0] t1, t2,
    output       coin_meter, credit_lamp,
    output [27:0] dbg
);
    wire vcc = 1'b1, gnd = 1'b0, nc = 1'bz;

    // ------------------------------------------------------------ switches
    // The CR filters (RA 560 + 100, 0.1 uF) are not modelled.
    wire n72_10, n32_4, n32_7, n32_9, n32_13;
    ra_279_latch ic32c(.s1_in(n72_10),.s2_in(a_aq),.r_in(a_a32),.q(n32_9));   // pins 11, 12, 10 -> 9
    ra_279_latch ic32t(.s1_in(a_ab),.s2_in(a_ab),.r_in(a_a24),.q(n32_4));     // pins 3, 2, 1 -> 4
    ra_279_latch ic32k(.s1_in(a_aa),.s2_in(vcc),.r_in(a_a23),.q(n32_7));      // pins 5, 6 (as drawn) -> 7
    // Changeover switch: common = IC33 pin 11, IC125 pin 3
    wire sw1 = a_two_play ? n32_9 : vcc;
    wire ct, n125_12, n125_8;
    ra_7411 ic125(.p3(sw1),.p4(n32_4),.p5(n32_7),.p6(ct),
        .p1(nc),.p2(nc),.p13(nc),.p12(n125_12),.p9(nc),.p10(nc),.p11(nc),.p8(n125_8));
    assign coin_test_n = ct;
    wire n73_2, n73_4, n73_12, n73_6, n73_8, n73_10, n79_3;
    ra_7404 ic73(.p1(ct),.p2(n73_2),.p3(n73_2),.p4(n73_4),.p13(n79_3),.p12(n73_12),
        .p5(nc),.p6(n73_6),.p9(nc),.p8(n73_8),.p11(nc),.p10(n73_10));

    // ------------------------------------------------------------ tilt, clears
    wire tclr, tilt_q_n;
    ra_74123 #(.PIXELS(TILT_PIXELS),.RUN(POWERUP_TILT)) ic38a(.a(a_aj),.b(vcc),.f7(f7),.q(tclr),.q_n(tilt_q_n));
    assign mute = tclr;
    assign ini_reset_n = tilt_q_n;
    wire mclr, n61_13, n61_4, n61_1, n61_10, n20_13, n50_5, n55_6, rc27;
    ra_7402 ic61(.p11(n20_13),.p12(n50_5),.p13(n61_13),.p5(n55_6),.p6(rc27),.p4(n61_4),
        .p2(nc),.p3(nc),.p1(n61_1),.p8(nc),.p9(nc),.p10(n61_10));
    wire n74_12, n74_6;
    ra_7427 ic74(.p11(a_game_over),.p9(tclr),.p10(n61_13),.p8(mclr),
        .p1(nc),.p2(nc),.p13(nc),.p12(n74_12),.p3(nc),.p4(nc),.p5(nc),.p6(n74_6));
    wire n37_5, n37_6, n37_9, n37_8;
    ra_7474_half ic37a(.clr_in(mclr),.d(vcc),.ck_in(ct),.pr_in(vcc),.q(n37_5),.q_n(n37_6));
    ra_7474_half ic37b(.clr_in(mclr),.d(n37_5),.ck_in(a_acce_st),.pr_in(nc),.q(n37_9),.q_n(n37_8));
    assign coin_in = n37_5;
    assign coin_in_n = n37_6;
    assign game = n37_9;
    assign game_n = n37_8;
    wire n33_9, n33_8;
    ra_7474_half ic33(.clr_in(tilt_q_n),.d(gnd),.ck_in(sw1),.pr_in(n32_7),.q(n33_9),.q_n(n33_8));
    wire n72_1, n72_4, n72_13;
    ra_7402 ic72(.p9(n33_8),.p8(n37_5),.p10(n72_10),
        .p2(nc),.p3(nc),.p1(n72_1),.p5(nc),.p6(nc),.p4(n72_4),.p11(nc),.p12(nc),.p13(n72_13));
    wire n12_8, n12_3, n12_6, n12_11;
    ra_7400 ic12(.p10(a_vs16),.p9(n72_10),.p8(n12_8),
        .p1(nc),.p2(nc),.p3(n12_3),.p4(nc),.p5(nc),.p6(n12_6),.p12(nc),.p13(nc),.p11(n12_11));
    assign credit_lamp = ~n12_8;

    // ------------------------------------------------------------ game timer
    wire sec, n22_6, n22_11, n22_3, n22_8;
    ra_555 #(.FIRST(T555_FIRST),.HIGH(T555_HIGH),.LOW(T555_LOW)) ic26(.rst_n(n37_9),.f7(f7),.q(sec));
    ra_7408 ic22(.p4(sec),.p5(n20_13),.p6(n22_6),.p12(ct),.p13(mclr),.p11(n22_11),
        .p1(nc),.p2(nc),.p3(n22_3),.p9(nc),.p10(nc),.p8(n22_8));
    wire n21_13, n21_12, n20_12;
    ra_74192 ic21(.p5(vcc),.p4(n22_6),.p11(ct),.p14(tclr),.p15(gnd),.p1(gnd),.p10(gnd),.p9(gnd),
        .p3(t1[0]),.p2(t1[1]),.p6(t1[2]),.p7(t1[3]),.p12(n21_12),.p13(n21_13));
    ra_74192 ic20(.p5(vcc),.p4(n21_13),.p11(ct),.p14(tclr),.p15(vcc),.p1(gnd),.p10(gnd),.p9(vcc),
        .p3(t2[0]),.p2(t2[1]),.p6(t2[2]),.p7(t2[3]),.p12(n20_12),.p13(n20_13));

    // ------------------------------------------------------------ extended play
    wire n50_6, n50_9, n50_8, excp_n;
    ra_7474_half ic50a(.clr_in(n22_11),.d(vcc),.ck_in(excp_n),.pr_in(nc),.q(n50_5),.q_n(n50_6));
    ra_7474_half ic50b(.clr_in(n22_11),.d(vcc),.ck_in(nc),.pr_in(n55_6),.q(n50_9),.q_n(n50_8));
    assign extend = n50_9;
    assign extend_n = n50_8;
    wire n55_8, n55_11, rc25;
    ra_7432 ic55(.p4(n50_6),.p5(n20_13),.p6(n55_6),.p10(n61_4),.p9(n73_2),.p8(n55_8),
        .p12(n79_3),.p13(n37_8),.p11(n55_11),.p2(n55_11),.p1(rc25),.p3(excp_n));
    assign car_cont_cl = n55_8;
    assign ex_signal_cp_n = excp_n;
    wire n44_8, n44_6, n44_2, n44_4, n44_10, n44_12;
    ra_7404 ic44(.p9(n55_6),.p8(n44_8),.p5(n32_7),.p6(n44_6),
        .p1(nc),.p2(n44_2),.p3(nc),.p4(n44_4),.p11(nc),.p10(n44_10),.p13(nc),.p12(n44_12));
    assign coin_meter = n44_6;
    // R14/C27 (IC44 pin 8 -> IC61 pin 6) and R15/C25 (IC73 pin 12 -> IC55 pin 1)
    ra_rc #(.N(RC_PIXELS),.INIT(1'b0)) rc_27(.a(n44_8),.f7(f7),.y(rc27));
    ra_rc #(.N(RC_PIXELS),.INIT(1'b1)) rc_25(.a(n73_12),.f7(f7),.y(rc25));
    wire [3:0] q79;
    ra_74393_half ic79(.ck_in(a_a30),.mr_in(n73_2),.q(q79));
    assign n79_3 = q79[0];
    assign pts8000 = q79[3];
    wire n49_13, n49_4;
    ra_74123 #(.PIXELS(IC49_PIXELS)) ic49(.a(excp_n),.b(vcc),.f7(f7),.q(n49_13),.q_n(n49_4));
    assign ex_signal_n = n49_4;
    wire n85_6, n85_8;
    ra_7411 ic85(.p13(a_v2),.p1(a_vs16),.p2(n49_13),.p12(ex_cp),
        .p3(nc),.p4(nc),.p5(nc),.p6(n85_6),.p9(nc),.p10(nc),.p11(nc),.p8(n85_8));
    wire n38_5;
    ra_74123 #(.PIXELS(HI_PIXELS)) ic38b(.a(mclr),.b(n50_9),.f7(f7),.q(n38_5),.q_n(hiscore_n));

    // Internal state, in the RTL's order (stored and settled flip-flop
    // states agree once settled)
    assign dbg = {n37_5, n37_9, n33_9, n50_5, n50_9, n37_5, n37_9, n33_9, n50_5, n50_9,
                  t1, t2, q79, n20_13, sec, tclr, n49_13, n38_5, ct};
endmodule
