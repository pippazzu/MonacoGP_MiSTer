// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected, event-driven reference for sheet H (manual
// 420-0358, PDF page 28). Each package is modelled from its data sheet pin
// functions and wired by IC and pin number from the pin tables in
// docs/trace/SHEET_H_TRACE.md. Self-contained: the rh_ models below are
// written for this file.
//
// Timing rule ("settled layers", every element one layer):
// - Gates, decoders, multiplexers and buffers take 0.01 ns.
// - Every element's clock, trigger and asynchronous input goes through a 3 ns
//   inertial filter (rh_filt), which absorbs and counts hazards. Clocked
//   outputs follow 1 ns after the filtered edge, asynchronous ones (latches,
//   clears) 0.02 ns after; a clock edge's output is dropped if a clear or
//   preset is active by then. The PROMs follow their address after 3.02 ns,
//   also one layer.
// - f7 is the 7 MHz edge. The testbench changes the other sheets' nets 5 ns
//   after it, after IC101 and IC102 have sampled theirs, and the one-shots
//   end then too. f14 falls in each half of the pixel.
`timescale 1ns/1ps

`ifndef TTL
`define TTL(x) ((x) === 1'bz ? 1'b1 : (x))
`endif
`define RH_G  0.01
`define RH_L  0.02
`define RH_W  3.0
`define RH_CQ 1.0
`define RH_T  5.0

module rh_filt(input a, output y);
    assign #(`RH_W) y = `TTL(a);
    integer hazards = 0;
    realtime t = -1.0e9;
    always @(a) begin
        if ($realtime > 1000.0 && $realtime - t < `RH_W) hazards = hazards + 1;
        t = $realtime;
    end
endmodule

module rh_7400(input p9,p10, output p8);
    assign #(`RH_G) p8 = ~(`TTL(p9)&`TTL(p10));
endmodule
module rh_nor2(input a, b, output y);     // one 7402 section
    assign #(`RH_G) y = ~(`TTL(a)|`TTL(b));
endmodule
module rh_or2(input a, b, output y);      // one 7432 section
    assign #(`RH_G) y = `TTL(a)|`TTL(b);
endmodule
module rh_and2(input a, b, output y);     // one 7408 section
    assign #(`RH_G) y = `TTL(a)&`TTL(b);
endmodule
module rh_and3(input a, b, c, output y);  // one 7411 section
    assign #(`RH_G) y = `TTL(a)&`TTL(b)&`TTL(c);
endmodule
module rh_nand3(input a, b, c, output y); // one 7410 section
    assign #(`RH_G) y = ~(`TTL(a)&`TTL(b)&`TTL(c));
endmodule
module rh_nor3(input a, b, c, output y);  // one 7427 section
    assign #(`RH_G) y = ~(`TTL(a)|`TTL(b)|`TTL(c));
endmodule
module rh_inv(input a, output y);         // one 7404 section
    assign #(`RH_G) y = ~`TTL(a);
endmodule
module rh_buf(input a, output y);         // one 7407 section
    assign #(`RH_G) y = `TTL(a);
endmodule
// 7450 dual AND-OR-invert: 1Y 8 = /(1A 1 . 1B 13 + 1C 9 . 1D 10);
// 2Y 6 = /(2A 2 . 2B 3 + 2C 4 . 2D 5). Expander pins not used.
module rh_7450(input p1,p13,p9,p10,p2,p3,p4,p5, output p8,p6);
    assign #(`RH_G) p8 = ~((`TTL(p1)&`TTL(p13)) | (`TTL(p9)&`TTL(p10)));
    assign #(`RH_G) p6 = ~((`TTL(p2)&`TTL(p3)) | (`TTL(p4)&`TTL(p5)));
endmodule
// 74157: select pin 1 (low: A inputs), strobe pin 15 (active low).
module rh_74157(input p1,p2,p3,p5,p6,p10,p11,p13,p14,p15, output p4,p7,p9,p12);
    wire s = `TTL(p1), g = !`TTL(p15);
    assign #(`RH_G) p4  = g && (s ? `TTL(p3)  : `TTL(p2));
    assign #(`RH_G) p7  = g && (s ? `TTL(p6)  : `TTL(p5));
    assign #(`RH_G) p9  = g && (s ? `TTL(p10) : `TTL(p11));
    assign #(`RH_G) p12 = g && (s ? `TTL(p13) : `TTL(p14));
endmodule
// 74367 hex tri-state buffer, both enables tied: Y = A while /G is low.
module rh_74367(input g_n, input [6:1] a, output [6:1] y);
    assign #(`RH_G) y = `TTL(g_n) ? 6'bzzzzzz : {`TTL(a[6]),`TTL(a[5]),`TTL(a[4]),`TTL(a[3]),`TTL(a[2]),`TTL(a[1])};
endmodule
// 74259 with /CLR at GND: a 1-of-8 decoder, the addressed output = D while
// /E is low, every output low while /E is high.
module rh_74259_clr(input a0, a1, a2, e_n, d, output [7:0] q);
    wire [2:0] a = {`TTL(a2),`TTL(a1),`TTL(a0)};
    assign #(`RH_G) q = `TTL(e_n) ? 8'd0 : ({7'd0, `TTL(d)} << a);
endmodule
// 7485 4-bit comparator, A=B output only (cascade A=B in at Vcc, the others
// at GND).
module rh_7485_eq(input [3:0] a, input [3:0] b, output eq);
    assign #(`RH_G) eq = {`TTL(a[3]),`TTL(a[2]),`TTL(a[1]),`TTL(a[0])} ==
                         {`TTL(b[3]),`TTL(b[2]),`TTL(b[1]),`TTL(b[0])};
endmodule
// One 7474 half. Both /PR and /CLR low drives both outputs high. Clock edges
// are changes between valid levels.
module rh_7474_half(input clr_in, d, ck_in, pr_in, output reg q = 0, output q_n);
    wire ck, clr_n, pr_n;
    rh_filt fck(.a(ck_in),.y(ck));
    rh_filt fcl(.a(clr_in),.y(clr_n));
    rh_filt fpr(.a(pr_in),.y(pr_n));
    reg ck_l = 1'bx, dv;
    assign #(`RH_L) q_n = (!clr_n && !pr_n) ? 1'b1 : ~q;
    always @(clr_n or pr_n)
        if (!pr_n) q <= #(`RH_L) 1;
        else if (!clr_n) q <= #(`RH_L) 0;
    always @(ck) begin
        if (ck_l === 1'b0 && ck === 1'b1 && clr_n && pr_n) begin
            dv = `TTL(d);
            #(`RH_CQ) if (clr_n && pr_n) q = dv;
        end
        ck_l = ck;
    end
endmodule
// One 74107 half, J = K = /CLR = Vcc: toggles at the falling clock edge.
module rh_74107_toggle(input ck_in, output reg q = 0, output q_n);
    wire ck;
    rh_filt fck(.a(ck_in),.y(ck));
    reg ck_l = 1'bx;
    assign q_n = ~q;
    always @(ck) begin
        if (ck_l === 1'b1 && ck === 1'b0) q <= #(`RH_CQ) ~q;
        ck_l = ck;
    end
endmodule
// 74161: /MR pin 1 (at Vcc here), CP 2, D0..D3 3..6, CEP 7, /PE 9 (synchronous
// load), CET 10, Q0..Q3 14..11, TC 15 = CET & Q = 15.
module rh_74161(input p2,p3,p4,p5,p6,p7,p9,p10, output p11,p12,p13,p14,p15);
    wire ck;
    rh_filt fck(.a(p2),.y(ck));
    reg [3:0] q = 0, nq;
    reg ck_l = 1'bx;
    always @(ck) begin
        if (ck_l === 1'b0 && ck === 1'b1) begin
            if (!`TTL(p9)) nq = {`TTL(p6),`TTL(p5),`TTL(p4),`TTL(p3)};
            else if (`TTL(p7) && `TTL(p10)) nq = q + 4'd1;
            else nq = q;
            q <= #(`RH_CQ) nq;
        end
        ck_l = ck;
    end
    assign {p11,p12,p13,p14} = q;
    assign #(`RH_G) p15 = `TTL(p10) && q == 4'hf;
endmodule
// One 74393 half: CP (falling edge), MR (asynchronous, high), Q0..Q3.
module rh_74393_half(input ck_in, mr_in, output reg [3:0] q = 0);
    wire ck, mr;
    rh_filt fck(.a(ck_in),.y(ck));
    rh_filt fmr(.a(mr_in),.y(mr));
    reg ck_l = 1'bx;
    always @(mr) if (mr) q <= #(`RH_L) 0;
    always @(ck) begin
        if (ck_l === 1'b1 && ck === 1'b0 && !mr) q <= #(`RH_CQ) q + 4'd1;
        ck_l = ck;
    end
endmodule
// One 74279 latch, one or two /S inputs: Q high while a /S is low, low while
// only /R is low. Evaluated 0.02 ns after one of its filtered inputs changes.
module rh_279_latch(input s1_in, s2_in, r_in, output reg q = 0);
    wire s1_n, s2_n, r_n;
    rh_filt fs1(.a(s1_in),.y(s1_n));
    rh_filt fs2(.a(s2_in),.y(s2_n));
    rh_filt fr(.a(r_in),.y(r_n));
    always @(s1_n or s2_n or r_n) begin
        #(`RH_L);
        if (!s1_n || !s2_n) q = 1;
        else if (!r_n) q = 0;
    end
endmodule
// One half of a 74123 retriggerable monostable: A (active low), B, /CLR, Q,
// /Q. Triggers: A falling while B is high, B rising while A is low, /CLR
// rising while A is low and B is high. The filtered inputs are evaluated
// together 0.5 ns after the first of them changes, and Q follows 0.5 ns
// later; a low /CLR ends the pulse the same way. PIXELS 7 MHz periods.
module rh_74123 #(parameter integer PIXELS = 1)(input a, b, clr_n, f7, output reg q = 0, output q_n);
    integer left = 0, trigs = 0;
    wire ta, tb, tc;
    rh_filt fa(.a(a),.y(ta));
    rh_filt fb(.a(b),.y(tb));
    rh_filt fc(.a(clr_n),.y(tc));
    // Edges are changes between valid levels: the power-up transition from x
    // is not one.
    reg ta_l = 1'bx, tb_l = 1'bx, tc_l = 1'bx;
    assign q_n = ~q;
    always @(ta or tb or tc) begin
        #0.5;
        if (tc === 1'b0) begin
            left = 0;
            q <= #0.5 0;
        end else if ((ta_l === 1'b1 && ta === 1'b0 && tb === 1'b1) || (tb_l === 1'b0 && tb === 1'b1 && ta === 1'b0) ||
                     (tc_l === 1'b0 && tc === 1'b1 && ta === 1'b0 && tb === 1'b1)) begin
            trigs = trigs + 1;
            left = PIXELS;
            q <= #0.5 1;
        end
        ta_l = ta; tb_l = tb; tc_l = tc;
    end
    always @(posedge f7) if (left > 0) begin
        left = left - 1;
        if (left == 0) q <= #(`RH_T) 0;
    end
endmodule
// PROMs (74S288 32 x 8, and the 512 x 8 PR-132) as one-layer elements: the
// data follow the address 3.02 ns later. OFFSET is the part's place in the
// +ROM image.
module rh_prom #(parameter integer AW = 5, OFFSET = 0)(input [AW-1:0] a, output [7:0] d);
    reg [7:0] image [0:8799];
    reg [1023:0] path;
    initial begin
        if (!$value$plusargs("ROM=%s",path)) $fatal(1,"rh_prom: missing +ROM");
        $readmemh(path,image);
    end
    wire [AW-1:0] at;
    genvar k;
    generate for (k = 0; k < AW; k = k + 1) begin: g
        assign at[k] = `TTL(a[k]);
    end endgenerate
    assign #(`RH_W + `RH_L) d = image[OFFSET + at];
endmodule

module sheet_h_reference #(
    parameter integer OS1A_PIXELS = 9552879, OS1B_PIXELS = 9552879,
    parameter integer OS2A_PIXELS = 21016334, OS2B_PIXELS = 21016334
)(
    input        f7, f14,
    // Sheet E
    input        h_h6_n, h_h8_n, h_hs_n, h_vs_n, h_v8_n, h_cs,
    // Sheets D and M
    input        h_l1_n, h_l2_n, h_r1_n, h_r2_n, h_rl_n, h_bridge, h_car_n,
    // Sheets A, F, I
    input        h_carcl, h_ext500_n, h_irreg_n,
    input  [3:0] h_acce,             // ACCE. D..A
    input        h_spcont,
    // Outputs, as the RTL's
    output       vs2, vs4, vs8, vs16, vs32, vs64,
    output [3:0] sp,
    output [5:1] area,
    output       other_car_n, other_body_n, other_tiar_n, f_sound_n,
    output [68:0] dbg
);
    wire vcc = 1'b1, gnd = 1'b0, nc = 1'bz;

    // ------------------------------------------------------------ frame counter
    wire [3:0] q79b, q78a, q78b;
    rh_74393_half ic79b(.ck_in(h_vs_n),.mr_in(gnd),.q(q79b));            // pins 13, 12; 11..8
    rh_74393_half ic78a(.ck_in(q79b[3]),.mr_in(gnd),.q(q78a));          // pins 1, 2; 3..6
    rh_74393_half ic78b(.ck_in(q78a[3]),.mr_in(gnd),.q(q78b));          // pins 13, 12; 11..8
    assign {vs16, vs8, vs4, vs2} = q79b;
    assign vs32 = q78a[0];
    assign vs64 = q78a[1];
    wire vs256 = q78a[3], vs512 = q78b[0], vs1k = q78b[1];
    wire n30_6;
    rh_7400 ic30(.p9(vs4),.p10(vs2),.p8(n30_6));                        // pins 4, 5 -> 6

    // ------------------------------------------------------------ divider
    wire [7:0] d115;
    rh_prom #(.AW(5),.OFFSET(8704)) ic115(.a({h_spcont, h_acce}),.d(d115));   // PR-38
    assign sp = d115[3:0];                                              // pins 4..1
    wire n108_4, n108_7, n108_9, n108_12;
    rh_74157 ic108(.p1(h_cs),.p15(gnd),
        .p2(d115[4]),.p3(gnd),.p4(n108_4),
        .p5(d115[5]),.p6(gnd),.p7(n108_7),
        .p11(d115[6]),.p10(gnd),.p9(n108_9),
        .p14(d115[7]),.p13(vcc),.p12(n108_12));
    wire n80_8, n81_9, n102_11, n102_12, n102_13, n102_14, n102_15;
    wire n101_11, n101_12, n101_13, n101_14, n101_15;
    rh_74161 ic102(.p2(f7),.p3(n108_4),.p4(n108_7),.p5(n108_9),.p6(n108_12),
        .p7(n81_9),.p9(n80_8),.p10(vcc),
        .p11(n102_11),.p12(n102_12),.p13(n102_13),.p14(n102_14),.p15(n102_15));
    rh_74161 ic101(.p2(f7),.p3(vcc),.p4(vcc),.p5(gnd),.p6(gnd),
        .p7(vcc),.p9(n80_8),.p10(n102_15),
        .p11(n101_11),.p12(n101_12),.p13(n101_13),.p14(n101_14),.p15(n101_15));
    wire n87_5, n87_6;
    rh_74107_toggle ic87(.ck_in(n101_15),.q(n87_5),.q_n(n87_6));       // pins 9 -> 5, 6
    rh_nand3 ic80(.a(n102_15),.b(n101_15),.c(n87_5),.y(n80_8));         // pins 9, 10, 11 -> 8
    wire n86_10, n86_13, n86_4, n106_8;
    rh_nor2 ic86c(.a(n80_8),.b(h_cs),.y(n86_10));                       // pins 8, 9 -> 10
    rh_nor2 ic86d(.a(h_hs_n),.b(h_vs_n),.y(n86_13));                    // pins 11, 12 -> 13
    rh_nor2 ic86b(.a(h_car_n),.b(n106_8),.y(n86_4));                    // pins 5, 6 -> 4
    // IC112: first half (car pulses), second half (14 MHz)
    wire [3:0] q112a, q112b;
    rh_74393_half ic112a(.ck_in(n86_4),.mr_in(h_carcl),.q(q112a));      // pins 1, 2; 3..6
    rh_74393_half ic112b(.ck_in(f14),.mr_in(n86_10),.q(q112b));         // pins 13, 12; 11..8
    wire n106_11, n113_6, n114_4, n114_6;
    rh_and2 ic106d(.a(h_irreg_n),.b(h_acce[2]),.y(n106_11));            // pins 12, 13 -> 11
    rh_and2 ic106c(.a(q112a[1]),.b(q112a[0]),.y(n106_8));               // pins 9, 10 -> 8
    rh_7485_eq ic113(.a({h_acce[3], n106_11, h_acce[1], nc}),.b(q112b),.eq(n113_6));  // A0 pin 10 open
    rh_inv ic114b(.a(n86_10),.y(n114_4));                               // pins 3 -> 4
    rh_inv ic114c(.a(n113_6),.y(n114_6));                               // pins 5 -> 6
    rh_279_latch ic81c(.s1_in(n114_6),.s2_in(n114_6),.r_in(n114_4),.q(n81_9));  // pins 11, 12, 10 -> 9

    // ------------------------------------------------------------ AREA
    wire [7:0] q94;
    rh_74259_clr ic94(.a0(n101_13),.a1(n101_12),.a2(n101_11),.e_n(n87_6),.d(vcc),.q(q94));
    wire area1 = q94[5], area2 = q94[0], area3 = q94[4], area5 = q94[7];
    wire n107_6, area4;
    rh_nor3 ic107b(.a(n87_5),.b(n101_13),.c(n101_12),.y(n107_6));       // pins 3, 4, 5 -> 6
    rh_and2 ic106a(.a(n107_6),.b(n101_11),.y(area4));                   // pins 1, 2 -> 3
    assign area = {area5, area4, area3, area2, area1};
    wire n93_3, n93_6, n93_8, n93_11, n66_6;
    rh_and2 ic93a(.a(area3),.b(n86_13),.y(n93_3));                      // pins 1, 2 -> 3
    rh_and2 ic93b(.a(n86_13),.b(area2),.y(n93_6));                      // pins 4, 5 -> 6
    rh_and2 ic93c(.a(area5),.b(n86_13),.y(n93_8));                      // pins 9, 10 -> 8
    rh_and2 ic93d(.a(area4),.b(n86_13),.y(n93_11));                     // pins 12, 13 -> 11
    rh_and2 ic66(.a(n86_13),.b(area1),.y(n66_6));                       // pins 4, 5 -> 6
    wire [7:0] d105;
    rh_prom #(.AW(5),.OFFSET(8736)) ic105(.a({q112a[1], q112a[0], vs1k, vs512, vs256}),.d(d105));  // PR-39
    wire n99_5, n99_9, n92_5, n92_9, n75_5, n106_6, n99_6, n99_8, n92_6, n92_8, n75_6;
    rh_7474_half ic99a(.clr_in(vcc),.d(d105[1]),.ck_in(n93_3),.pr_in(vcc),.q(n99_5),.q_n(n99_6));
    rh_7474_half ic99b(.clr_in(vcc),.d(d105[3]),.ck_in(n93_11),.pr_in(vcc),.q(n99_9),.q_n(n99_8));
    rh_7474_half ic92a(.clr_in(vcc),.d(d105[0]),.ck_in(n93_8),.pr_in(vcc),.q(n92_5),.q_n(n92_6));
    rh_7474_half ic92b(.clr_in(vcc),.d(d105[2]),.ck_in(n93_6),.pr_in(vcc),.q(n92_9),.q_n(n92_8));
    rh_and2 ic106b(.a(h_ext500_n),.b(d105[4]),.y(n106_6));              // pins 4, 5 -> 6
    rh_7474_half ic75a(.clr_in(vcc),.d(n106_6),.ck_in(n66_6),.pr_in(vcc),.q(n75_5),.q_n(n75_6));
    wire n100_8, n100_6, n68_8;
    rh_7450 ic100(.p1(n99_5),.p13(area3),.p9(n99_9),.p10(area4),
                  .p2(n92_5),.p3(area5),.p4(n92_9),.p5(area2),.p8(n100_8),.p6(n100_6));
    rh_7400 ic68(.p9(n75_5),.p10(area1),.p8(n68_8));

    // ------------------------------------------------------------ position channels
    wire n85_6, n85_8;
    rh_and3 ic85a(.a(nc),.b(h_l1_n),.c(h_l2_n),.y(n85_6));              // pins 3 (open), 4, 5 -> 6
    rh_and3 ic85b(.a(h_r1_n),.b(h_r2_n),.c(h_rl_n),.y(n85_8));          // pins 9, 10, 11 -> 8
    wire cmp1, cmp2, cmp3;                                              // IC123 pins 12, 6, 8
    wire n81_4, n81_13, n81_7;
    // Channel 1: latch IC81a through IC95
    wire n95_3, n95_11;
    rh_or2 ic95a(.a(cmp1),.b(n85_8),.y(n95_3));                         // pins 1, 2 -> 3
    rh_or2 ic95b(.a(n85_6),.b(cmp1),.y(n95_11));                        // pins 12, 13 -> 11
    rh_279_latch ic81a(.s1_in(n95_11),.s2_in(n95_11),.r_in(n95_3),.q(n81_4));   // pins 2, 3, 1 -> 4
    // Channel 2: latch IC81d through IC88
    wire n88_3, n88_11, n88_6, n88_8;
    rh_or2 ic88a(.a(n85_6),.b(cmp2),.y(n88_3));                         // pins 1, 2 -> 3
    rh_or2 ic88d(.a(cmp2),.b(n85_8),.y(n88_11));                        // pins 12, 13 -> 11
    rh_279_latch ic81d(.s1_in(n88_3),.s2_in(vcc),.r_in(n88_11),.q(n81_13));     // pins 15, 14 -> 13
    // Channel 3: latch IC81b through IC88
    rh_or2 ic88b(.a(n85_6),.b(cmp3),.y(n88_6));                         // pins 4, 5 -> 6
    rh_or2 ic88c(.a(cmp3),.b(n85_8),.y(n88_8));                         // pins 9, 10 -> 8
    rh_279_latch ic81b(.s1_in(n88_6),.s2_in(vcc),.r_in(n88_8),.q(n81_7));       // pins 6, 5 -> 7
    // One-shots
    wire o1a, o1b, o2a, o2b, o1a_n, o1b_n, o2a_n, o2b_n;
    rh_74123 #(.PIXELS(OS1A_PIXELS)) ic121a(.a(o1b),.b(n81_4),.clr_n(h_bridge),.f7(f7),.q(o1a),.q_n(o1a_n));
    rh_74123 #(.PIXELS(OS1B_PIXELS)) ic121b(.a(n81_4),.b(o1a_n),.clr_n(h_bridge),.f7(f7),.q(o1b),.q_n(o1b_n));
    rh_74123 #(.PIXELS(OS2A_PIXELS)) ic120a(.a(o2b),.b(n81_13),.clr_n(h_bridge),.f7(f7),.q(o2a),.q_n(o2a_n));
    rh_74123 #(.PIXELS(OS2B_PIXELS)) ic120b(.a(n81_13),.b(o2a_n),.clr_n(h_bridge),.f7(f7),.q(o2b),.q_n(o2b_n));
    wire n107_12, n107_8;
    rh_nor3 ic107a(.a(o1a),.b(n30_6),.c(o1b),.y(n107_12));              // pins 1, 2, 13 -> 12
    rh_nor3 ic107c(.a(o2a),.b(o2b),.c(vs2),.y(n107_8));                 // pins 9, 10, 11 -> 8
    wire n82_2, n82_4, n82_6, n82_8, n82_10, n82_12;
    wire tc96, tc109, tc116;
    rh_inv ic82a(.a(n81_7),.y(n82_2));                                  // 1 -> 2
    rh_inv ic82b(.a(tc109),.y(n82_4));                                  // 3 -> 4
    rh_inv ic82c(.a(n81_4),.y(n82_6));                                  // 5 -> 6
    rh_inv ic82d(.a(n81_13),.y(n82_8));                                 // 9 -> 8
    rh_inv ic82e(.a(tc96),.y(n82_10));                                  // 11 -> 10
    rh_inv ic82f(.a(tc116),.y(n82_12));                                 // 13 -> 12
    wire n89_4, n89_7, n89_9, n89_12, n103_4, n103_7, n103_9, n103_12;
    rh_74157 ic89(.p1(n107_12),.p15(gnd),.p2(gnd),.p3(vcc),.p4(n89_4),.p5(gnd),.p6(n82_6),.p7(n89_7),
        .p11(gnd),.p10(n82_6),.p9(n89_9),.p14(vcc),.p13(n81_4),.p12(n89_12));
    rh_74157 ic103(.p1(n107_8),.p15(gnd),.p2(gnd),.p3(vcc),.p4(n103_4),.p5(gnd),.p6(n82_8),.p7(n103_7),
        .p11(gnd),.p10(n82_8),.p9(n103_9),.p14(vcc),.p13(n81_13),.p12(n103_12));
    wire [3:0] lo1, hi1, lo2, hi2, lo3, hi3;
    wire tc90, tc104, tc117;
    rh_74161 ic90(.p2(n80_8),.p3(n89_4),.p4(n89_7),.p5(n89_9),.p6(n89_12),.p7(vcc),.p9(n82_10),.p10(h_v8_n),
        .p11(lo1[3]),.p12(lo1[2]),.p13(lo1[1]),.p14(lo1[0]),.p15(tc90));
    rh_74161 ic96(.p2(n80_8),.p3(gnd),.p4(gnd),.p5(gnd),.p6(gnd),.p7(vcc),.p9(n82_10),.p10(tc90),
        .p11(hi1[3]),.p12(hi1[2]),.p13(hi1[1]),.p14(hi1[0]),.p15(tc96));
    rh_74161 ic104(.p2(n80_8),.p3(n103_4),.p4(n103_7),.p5(n103_9),.p6(n103_12),.p7(vcc),.p9(n82_4),.p10(h_v8_n),
        .p11(lo2[3]),.p12(lo2[2]),.p13(lo2[1]),.p14(lo2[0]),.p15(tc104));
    rh_74161 ic109(.p2(n80_8),.p3(gnd),.p4(gnd),.p5(gnd),.p6(gnd),.p7(vcc),.p9(n82_4),.p10(tc104),
        .p11(hi2[3]),.p12(hi2[2]),.p13(hi2[1]),.p14(hi2[0]),.p15(tc109));
    rh_74161 ic117(.p2(n80_8),.p3(vcc),.p4(n82_2),.p5(n82_2),.p6(n81_7),.p7(vcc),.p9(n82_12),.p10(h_v8_n),
        .p11(lo3[3]),.p12(lo3[2]),.p13(lo3[1]),.p14(lo3[0]),.p15(tc117));
    rh_74161 ic116(.p2(n80_8),.p3(gnd),.p4(gnd),.p5(gnd),.p6(gnd),.p7(vcc),.p9(n82_12),.p10(tc117),
        .p11(hi3[3]),.p12(hi3[2]),.p13(hi3[1]),.p14(hi3[0]),.p15(tc116));
    // Windows: IC122 (7402) and IC123 (7410)
    wire n122_10, n122_1, n122_13;
    rh_nor2 ic122c(.a(hi1[0]),.b(hi1[2]),.y(n122_10));                  // pins 8, 9 -> 10
    rh_nor2 ic122a(.a(hi2[2]),.b(hi2[0]),.y(n122_1));                   // pins 2, 3 -> 1
    rh_nor2 ic122d(.a(hi3[0]),.b(hi3[2]),.y(n122_13));                  // pins 11, 12 -> 13
    rh_nand3 ic123a(.a(hi1[1]),.b(hi1[3]),.c(n122_10),.y(cmp1));        // pins 1, 2, 13 -> 12
    rh_nand3 ic123b(.a(hi2[1]),.b(n122_1),.c(hi2[3]),.y(cmp2));         // pins 3, 4, 5 -> 6
    rh_nand3 ic123c(.a(hi3[3]),.b(n122_13),.c(hi3[1]),.y(cmp3));        // pins 9, 10, 11 -> 8

    // ------------------------------------------------------------ bus, PR-132, outputs
    tri1 [6:1] bus;                                                     // RA3 5.6K pull-ups (Y5 open)
    rh_74367 ic97(.g_n(n100_8),.a({cmp1, nc, lo1}),.y(bus));
    rh_74367 ic110(.g_n(n100_6),.a({cmp2, nc, lo2}),.y(bus));
    rh_74367 ic124(.g_n(n68_8),.a({cmp3, nc, lo3}),.y(bus));
    wire strobe = bus[6];
    wire [7:0] d111;
    rh_prom #(.AW(9),.OFFSET(3584)) ic111(.a({vs4, n101_14, n102_11, n102_12, n102_13, bus[4:1]}),.d(d111));  // PR-132
    wire n118_4, n118_7, n118_9, n118_12;
    rh_74157 ic118(.p1(n102_14),.p15(strobe),
        .p2(d111[0]),.p3(d111[1]),.p4(n118_4),
        .p5(d111[2]),.p6(d111[3]),.p7(n118_7),
        .p11(d111[4]),.p10(d111[5]),.p9(n118_9),
        .p14(d111[6]),.p13(d111[7]),.p12(n118_12));
    rh_inv ic114a(.a(n118_7),.y(other_tiar_n));                         // 1 -> 2
    rh_inv ic114e(.a(n118_12),.y(other_car_n));                         // 11 -> 10
    rh_inv ic114f(.a(n118_9),.y(other_body_n));                         // 13 -> 12
    wire n75_9, n75_8;
    rh_7474_half ic75b(.clr_in(h_h8_n),.d(h_h6_n),.ck_in(strobe),.pr_in(nc),.q(n75_9),.q_n(n75_8));
    rh_buf ic29(.a(n75_8),.y(f_sound_n));                               // 11 -> 10

    // Internal state, in the RTL's order
    assign dbg = {n101_11, n101_12, n101_13, n101_14, n102_11, n102_12, n102_13, n102_14, q112b, n87_5, n81_9,
                  q78b, q78a, q79b, lo1, hi1, lo2, hi2, lo3, hi3, n81_4, n81_13, n81_7,
                  o1a, o1b, o2a, o2b, n99_5, n99_9, n92_5, n92_9, n75_5, n75_9,
                  q112a[1:0], strobe, n100_8, n100_6, n68_8};
endmodule
