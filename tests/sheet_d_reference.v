// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected, event-driven reference for sheet D (manual
// 420-0358, PDF page 31). Each package is modelled from its data sheet pin
// functions and wired by IC and pin number from the pin tables in
// docs/trace/SHEET_D_TRACE.md. Self-contained: the rd_ models below are
// written for this file.
//
// Timing rule ("settled layers", the one of tests/sheet_f_reference.v):
// - Gates, decoders, multiplexers and the PROMs take 0.01 ns, latch and
//   asynchronous outputs 0.02 ns, so that every combinational path settles
//   within a fraction of a nanosecond.
// - Every clock input and every asynchronous clear, preset, reset and latch
//   input goes through a 3 ns inertial filter (rd_filt): a shorter pulse is a
//   hazard of the path delays above, is absorbed and counted.
// - Flip-flops and the counter act 1 ns after the filtered clock edge.
// The testbench changes every input at the same instant, as the counters of
// sheets B and E clocked by the same 7 MHz edge would.
`timescale 1ns/1ps

`ifndef TTL
`define TTL(x) ((x) === 1'bz ? 1'b1 : (x))
`endif
`define RD_G  0.01      // gate
`define RD_L  0.02      // latch, asynchronous input
`define RD_W  3.0       // filter
`define RD_CQ 1.0       // clock to output

// Inertial filter with a hazard counter.
module rd_filt(input a, output y);
    assign #(`RD_W) y = `TTL(a);
    integer hazards = 0;
    realtime t = -1.0e9;
    always @(a) begin
        if ($realtime > 1000.0 && $realtime - t < `RD_W) hazards = hazards + 1;
        t = $realtime;
    end
endmodule

module rd_7400(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RD_G) p3 =~(`TTL(p1)&`TTL(p2));
    assign #(`RD_G) p6 =~(`TTL(p4)&`TTL(p5));
    assign #(`RD_G) p8 =~(`TTL(p9)&`TTL(p10));
    assign #(`RD_G) p11=~(`TTL(p12)&`TTL(p13));
endmodule
module rd_7402(input p2,p3,p5,p6,p8,p9,p11,p12, output p1,p4,p10,p13);
    assign #(`RD_G) p1 =~(`TTL(p2)|`TTL(p3));
    assign #(`RD_G) p4 =~(`TTL(p5)|`TTL(p6));
    assign #(`RD_G) p10=~(`TTL(p8)|`TTL(p9));
    assign #(`RD_G) p13=~(`TTL(p11)|`TTL(p12));
endmodule
module rd_7404(input p1,p3,p5,p9,p11,p13, output p2,p4,p6,p8,p10,p12);
    assign #(`RD_G) p2 =~`TTL(p1);
    assign #(`RD_G) p4 =~`TTL(p3);
    assign #(`RD_G) p6 =~`TTL(p5);
    assign #(`RD_G) p8 =~`TTL(p9);
    assign #(`RD_G) p10=~`TTL(p11);
    assign #(`RD_G) p12=~`TTL(p13);
endmodule
module rd_7408(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RD_G) p3 =`TTL(p1)&`TTL(p2);
    assign #(`RD_G) p6 =`TTL(p4)&`TTL(p5);
    assign #(`RD_G) p8 =`TTL(p9)&`TTL(p10);
    assign #(`RD_G) p11=`TTL(p12)&`TTL(p13);
endmodule
module rd_7410(input p1,p2,p13,p3,p4,p5,p9,p10,p11, output p12,p6,p8);
    assign #(`RD_G) p12=~(`TTL(p1)&`TTL(p2)&`TTL(p13));
    assign #(`RD_G) p6 =~(`TTL(p3)&`TTL(p4)&`TTL(p5));
    assign #(`RD_G) p8 =~(`TTL(p9)&`TTL(p10)&`TTL(p11));
endmodule
module rd_7411(input p1,p2,p13,p3,p4,p5,p9,p10,p11, output p12,p6,p8);
    assign #(`RD_G) p12=`TTL(p1)&`TTL(p2)&`TTL(p13);
    assign #(`RD_G) p6 =`TTL(p3)&`TTL(p4)&`TTL(p5);
    assign #(`RD_G) p8 =`TTL(p9)&`TTL(p10)&`TTL(p11);
endmodule
module rd_7420(input p1,p2,p4,p5,p9,p10,p12,p13, output p6,p8);
    assign #(`RD_G) p6=~(`TTL(p1)&`TTL(p2)&`TTL(p4)&`TTL(p5));
    assign #(`RD_G) p8=~(`TTL(p9)&`TTL(p10)&`TTL(p12)&`TTL(p13));
endmodule
// Dual 4-input gate for IC90. TYPE 1: 7425, Y = /(G & (A | B | C | D)) with
// strobes G on pins 3 and 11; TYPE 2: 7421, Y = A & B & C & D; TYPE 0: the
// drawing as it stands, section 8 an AND and section 6 a NOR (no strobe).
module rd_ic90 #(parameter integer TYPE = 1)(input p1,p2,p3,p4,p5,p9,p10,p11,p12,p13, output p6,p8);
    wire and6 = `TTL(p1)&`TTL(p2)&`TTL(p4)&`TTL(p5);
    wire and8 = `TTL(p9)&`TTL(p10)&`TTL(p12)&`TTL(p13);
    wire nor6 = ~(`TTL(p3) & (`TTL(p1)|`TTL(p2)|`TTL(p4)|`TTL(p5)));
    wire nor8 = ~(`TTL(p11) & (`TTL(p9)|`TTL(p10)|`TTL(p12)|`TTL(p13)));
    assign #(`RD_G) p6 = TYPE == 2 ? and6 : TYPE == 1 ? nor6 : ~(`TTL(p1)|`TTL(p2)|`TTL(p4)|`TTL(p5));
    assign #(`RD_G) p8 = TYPE == 2 ? and8 : TYPE == 1 ? nor8 : and8;
endmodule
// 7425 section 1: Y pin 6 = /(G pin 3 & (pins 1 | 2 | 4 | 5)).
module rd_7425a(input p1,p2,p3,p4,p5, output p6);
    assign #(`RD_G) p6 = ~(`TTL(p3) & (`TTL(p1)|`TTL(p2)|`TTL(p4)|`TTL(p5)));
endmodule
module rd_7427(input p1,p2,p13,p3,p4,p5,p9,p10,p11, output p12,p6,p8);
    assign #(`RD_G) p12=~(`TTL(p1)|`TTL(p2)|`TTL(p13));
    assign #(`RD_G) p6 =~(`TTL(p3)|`TTL(p4)|`TTL(p5));
    assign #(`RD_G) p8 =~(`TTL(p9)|`TTL(p10)|`TTL(p11));
endmodule
module rd_7432(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RD_G) p3 =`TTL(p1)|`TTL(p2);
    assign #(`RD_G) p6 =`TTL(p4)|`TTL(p5);
    assign #(`RD_G) p8 =`TTL(p9)|`TTL(p10);
    assign #(`RD_G) p11=`TTL(p12)|`TTL(p13);
endmodule
// 7486 (Pro IC113)
module rd_7486(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RD_G) p3 =`TTL(p1)^`TTL(p2);
    assign #(`RD_G) p6 =`TTL(p4)^`TTL(p5);
    assign #(`RD_G) p8 =`TTL(p9)^`TTL(p10);
    assign #(`RD_G) p11=`TTL(p12)^`TTL(p13);
endmodule
// BCD-to-decimal decoder: A, B, C, D = pins 15, 14, 13, 12; outputs 0..9 =
// pins 1..7, 9..11, active low; codes 10 to 15 select no output.
module rd_7442(input p15,p14,p13,p12, output p1,p2,p3,p4,p5,p6,p7,p9,p10,p11);
    wire [3:0] n = {`TTL(p12),`TTL(p13),`TTL(p14),`TTL(p15)};
    assign #(`RD_G) {p11,p10,p9,p7,p6,p5,p4,p3,p2,p1} =
        {n != 9, n != 8, n != 7, n != 6, n != 5, n != 4, n != 3, n != 2, n != 1, n != 0};
endmodule
// 8-to-1 multiplexer: D0..D7 = pins 4, 3, 2, 1, 15, 14, 13, 12; A, B, C =
// pins 11, 10, 9; strobe G pin 7 (active low); Y pin 5, W pin 6.
module rd_74151(input p1,p2,p3,p4,p7,p9,p10,p11,p12,p13,p14,p15, output p5,p6);
    wire [7:0] d = {`TTL(p12),`TTL(p13),`TTL(p14),`TTL(p15),`TTL(p1),`TTL(p2),`TTL(p3),`TTL(p4)};
    wire [2:0] s = {`TTL(p9),`TTL(p10),`TTL(p11)};
    wire y = !`TTL(p7) && d[s];
    assign #(`RD_G) p5 = y;
    assign #(`RD_G) p6 = !y;
endmodule
// Dual 4-to-1 multiplexer: A pin 14, B pin 2; 1G pin 1, 1C0..1C3 pins 6..3,
// 1Y pin 7; 2G pin 15, 2C0..2C3 pins 10..13, 2Y pin 9. A high strobe forces
// its Y low.
module rd_74153(input p1,p2,p3,p4,p5,p6,p10,p11,p12,p13,p14,p15, output p7,p9);
    wire [1:0] s = {`TTL(p2),`TTL(p14)};
    wire [3:0] c1 = {`TTL(p3),`TTL(p4),`TTL(p5),`TTL(p6)};
    wire [3:0] c2 = {`TTL(p13),`TTL(p12),`TTL(p11),`TTL(p10)};
    assign #(`RD_G) p7 = !`TTL(p1) && c1[s];
    assign #(`RD_G) p9 = !`TTL(p15) && c2[s];
endmodule
// Quad 2-to-1 multiplexer: select pin 1 (low: 1A, 2A, 3A, 4A), strobe pin 15
// (active low); 1A 2, 1B 3, 1Y 4; 2A 5, 2B 6, 2Y 7; 3A 11, 3B 10, 3Y 9;
// 4A 14, 4B 13, 4Y 12.
module rd_74157(input p1,p2,p3,p5,p6,p10,p11,p13,p14,p15, output p4,p7,p9,p12);
    wire s = `TTL(p1), g = !`TTL(p15);
    assign #(`RD_G) p4  = g && (s ? `TTL(p3)  : `TTL(p2));
    assign #(`RD_G) p7  = g && (s ? `TTL(p6)  : `TTL(p5));
    assign #(`RD_G) p9  = g && (s ? `TTL(p10) : `TTL(p11));
    assign #(`RD_G) p12 = g && (s ? `TTL(p13) : `TTL(p14));
endmodule
// One 7474 half: /CLR pin 1 (13), D pin 2 (12), CK pin 3 (11), /PR pin 4
// (10), Q pin 5 (9), /Q pin 6 (8). Both /PR and /CLR low drives both
// outputs high. Clock edges are changes between valid levels: the power-up
// transition from x is not an edge (also in the counter below).
module rd_7474_half(input clr_in, d, ck_in, pr_in, output reg q = 0, output q_n);
    wire ck, clr_n, pr_n;
    rd_filt fck(.a(ck_in),.y(ck));
    rd_filt fcl(.a(clr_in),.y(clr_n));
    rd_filt fpr(.a(pr_in),.y(pr_n));
    reg ck_l = 1'bx;
    assign #(`RD_L) q_n = (!clr_n && !pr_n) ? 1'b1 : ~q;
    always @(clr_n or pr_n)
        if (!pr_n) q <= #(`RD_L) 1;
        else if (!clr_n) q <= #(`RD_L) 0;
    always @(ck) begin
        if (ck_l === 1'b0 && ck === 1'b1 && clr_n && pr_n) q <= #(`RD_CQ) `TTL(d);
        ck_l = ck;
    end
endmodule
// One 74393 half: clock pin 13 (counts on the falling edge), MR pin 12
// (asynchronous, active high), QA..QD pins 11, 10, 9, 8.
module rd_74393_half(input ck_in, mr_in, output reg [3:0] q = 0);
    wire ck, mr;
    rd_filt fck(.a(ck_in),.y(ck));
    rd_filt fmr(.a(mr_in),.y(mr));
    reg ck_l = 1'bx;
    always @(mr) if (mr) q <= #(`RD_L) 0;
    always @(ck) begin
        if (ck_l === 1'b1 && ck === 1'b0 && !mr) q <= #(`RD_CQ) q + 4'd1;
        ck_l = ck;
    end
endmodule
// One 74279 latch with a single /S input: Q goes high while /S is low, low
// while only /R is low. The latch looks at both filtered inputs RD_L after
// either changes, so that /S and /R released in the same layer hold it,
// whatever order the simulator takes the two events in: the settled-layer
// rule. (On the board the later release decides; see docs/SHEET_D_LOGIC.md.)
module rd_279_latch(input s_in, r_in, output reg q = 0);
    wire s_n, r_n;
    rd_filt fs(.a(s_in),.y(s_n));
    rd_filt fr(.a(r_in),.y(r_n));
    always @(s_n or r_n) begin
        #(`RD_L);
        if (!s_n) q = 1;
        else if (!r_n) q = 0;
    end
endmodule
// 512 x 8 PROM: A0..A7 = pins 8..1, A8 = pin 23; O1..O8 = pins 9, 10, 11,
// 13..17; enabled while pins 20 and 21 are low and 18 and 19 high. OFFSET is
// the device's place in the +ROM image.
module rd_prom512 #(parameter integer OFFSET = 0)(
    input p1,p2,p3,p4,p5,p6,p7,p8,p18,p19,p20,p21,p23,
    output p9,p10,p11,p13,p14,p15,p16,p17
);
    reg [7:0] image [0:8799];
    reg [1023:0] path;
    initial begin
        if (!$value$plusargs("ROM=%s",path)) $fatal(1,"rd_prom512: missing +ROM");
        $readmemh(path,image);
    end
    wire [8:0] a = {`TTL(p23),`TTL(p1),`TTL(p2),`TTL(p3),`TTL(p4),`TTL(p5),`TTL(p6),`TTL(p7),`TTL(p8)};
    wire en = !`TTL(p20) && !`TTL(p21) && `TTL(p19) && `TTL(p18);
    assign #(`RD_G) {p17,p16,p15,p14,p13,p11,p10,p9} = en ? image[OFFSET+a] : 8'bz;
endmodule

module sheet_d_reference #(parameter integer IC90_TYPE = 1, IC66_NAND = 0)(
    // Sheet E
    input        d_hs_n,            // /HS, pad FJ
    input        d_v7,              // V7, pad EN
    input        d_v8_n,            // /V8, pad FN
    // Sheet B
    input  [8:0] d_mh,
    input        d_mhl_n,           // /MHL0
    input  [7:0] d_m1v, d_m2v,
    input        d_m1vl_n, d_m2vl_n,
    input        d_v4dec_n,         // V-(4)
    // Sheets C, A, I
    input        d_extend,
    input        d_coin_in_n,       // pad ED
    input  [3:0] d_s100,            // {D, C, B, A}
    // Pro board (manual 420-0525 page 15, pro/docs/trace/SHEET_D_COMPARE.md
    // and pro/docs/SHEETS_B_C_D_PRO_LOGIC.md): /DISPLAY and /D-GAME from B;
    // d_extend is then D-EXTEND. With d_pro low the Pro parts are cut off
    // and the sheet is the original.
    input        d_pro, d_display_n, d_d_game_n,
    output       d_time, slow, belt, slip, c100,
    output [7:0] dbg_pro,
    // Outputs, as the RTL's
    output       side_line_n, tree_grass_g_n, tree_grass_bl_n, grass_area_n, grass_w_n,
    output       house_st_n,
    output [3:0] house_n,
    output       pool_n, wall_n, gravel_n, slide_n, slip_n, green_belt_n, y_line_n,
    output       tunnel_ap, bridge_ap, road, road_n, tunnel_n, tunnel_bridge_n,
    output       ext500, ext500_n, car_no_cont_n, r_side_n, l_side_n, zero_area_n,
    output [23:0] dbg
);
    wire vcc = 1'b1, gnd = 1'b0, nc = 1'bz;
    wire [8:0] mh = d_mh;
    wire [7:0] m1v = d_m1v, m2v = d_m2v;

    // ------------------------------------------------------------ Pro input stage
    // 74157 IC34 (S 1 = /DISPLAY, /G 15 GND), 74393 IC41 (1CLK 1, 1CLR 2,
    // 2CLK 13, 2CLR 12), 7486 IC113 (9, 10 -> 8), 7404 IC36 (1 -> 2, 5 -> 6).
    // Pro designators, prefixed p (the original numbers are used below).
    wire n40_9;                                      // HSB flip-flop Q (pin 9)
    wire [3:0] p41a_q, p41b_q;                       // QA..QD: pins 3..6, 11..8
    wire p41_mr = d_pro ? d_display_n : vcc;
    rd_74393_half p41a(.ck_in(n40_9),.mr_in(p41_mr),.q(p41a_q));
    rd_74393_half p41b(.ck_in(p41a_q[3]),.mr_in(p41_mr),.q(p41b_q));
    wire p113_8, p113_3, p113_6, p113_11;
    rd_7486 p113(.p9(p41a_q[3]),.p10(p41a_q[2]),.p8(p113_8),
        .p1(nc),.p2(nc),.p3(p113_3),.p4(nc),.p5(nc),.p6(p113_6),.p12(nc),.p13(nc),.p11(p113_11));
    wire p36_2, p36_6, p36_4, p36_8, p36_10, p36_12, p34_4, p34_7, p34_9, p34_12;
    rd_7404 p36(.p1(p113_8),.p2(p36_2),.p5(p34_12),.p6(p36_6),
        .p3(nc),.p4(p36_4),.p9(nc),.p8(p36_8),.p11(nc),.p10(p36_10),.p13(nc),.p12(p36_12));
    rd_74157 p34(.p1(d_display_n),.p15(gnd),
        .p2(p41b_q[0]),.p3(d_s100[0]),.p4(p34_4),
        .p5(p41b_q[1]),.p6(d_s100[1]),.p7(p34_7),
        .p11(p41b_q[2]),.p10(d_s100[2]),.p9(p34_9),
        .p14(p36_2),.p13(d_s100[3]),.p12(p34_12));
    assign d_time = p41b_q[3];
    assign dbg_pro = {p41b_q, p41a_q};
    // The original has the pads straight on the 7442.
    wire [3:0] dec_in = d_pro ? {p34_12, p34_9, p34_7, p34_4} : d_s100;
    assign c100 = dec_in[2];

    // ------------------------------------------------------------ IC24, RA1
    wire n24_1, n24_2, n24_3, n24_4, n24_5, n24_6, n24_7, n24_9, n24_10, n24_11;
    rd_7442 ic24(.p15(dec_in[0]),.p14(dec_in[1]),.p13(dec_in[2]),.p12(dec_in[3]),
        .p1(n24_1),.p2(n24_2),.p3(n24_3),.p4(n24_4),.p5(n24_5),.p6(n24_6),.p7(n24_7),
        .p9(n24_9),.p10(n24_10),.p11(n24_11));
    assign car_no_cont_n = n24_6;

    // ------------------------------------------------------------ state flip-flops
    wire n47_3, n47_6, n47_11, n47_8;
    wire n49_8, n49_9, n49_10, n49_11;
    rd_7408 ic47(.p1(vcc),.p2(d_hs_n),.p3(n47_3),
        .p4(n24_2),.p5(n24_7),.p6(n47_6),
        .p12(n49_9),.p13(n49_8),.p11(n47_11),
        .p9(nc),.p10(nc),.p8(n47_8));
    wire n34_10, n34_4, n34_13, n34_1;
    wire n112_7, n105_9;
    wire n31_9, n25_5;
    // Pro: /D-GAME on pin 9 (Pro 63 pin 3)
    rd_7402 ic34(.p8(n47_11),.p9(d_pro ? d_d_game_n : d_coin_in_n),.p10(n34_10),
        .p6(n31_9),.p5(n25_5),.p4(n34_4),
        .p11(n112_7),.p12(n105_9),.p13(n34_13),
        .p2(nc),.p3(nc),.p1(n34_1));
    assign tunnel_bridge_n = n34_4;
    assign tree_grass_bl_n = n34_13;
    // IC40: upper half GRAVEL (pins 1-6), lower half (pins 8-13, /CLR, /PR not drawn)
    wire n40_5, n40_6, n40_8;
    rd_7474_half ic40a(.clr_in(n34_10),.d(d_extend),.ck_in(n24_1),.pr_in(nc),.q(n40_5),.q_n(n40_6));
    rd_7474_half ic40b(.clr_in(nc),.d(n47_3),.ck_in(d_mhl_n),.pr_in(nc),.q(n40_9),.q_n(n40_8));
    // IC38: POOL half (pins 2-6, /CLR, /PR not drawn), other half (pins 9-13)
    wire n38_5, n38_6, n38_9, n38_8, n45_3, n31_8;
    rd_7474_half ic38a(.clr_in(nc),.d(n38_9),.ck_in(n40_9),.pr_in(nc),.q(n38_5),.q_n(n38_6));
    // Pro: clocked by IC36 pin 6, NOT(IC34 pin 12); 7442 output 1 unused
    rd_7474_half ic38b(.clr_in(n45_3),.d(n31_8),.ck_in(d_pro ? p36_6 : n47_6),.pr_in(nc),.q(n38_9),.q_n(n38_8));
    // IC31: SLIP (pins 1-6) and TUNNEL (pins 8-13)
    wire n31_5, n31_6;
    rd_7474_half ic31a(.clr_in(n34_10),.d(n38_6),.ck_in(n24_3),.pr_in(nc),.q(n31_5),.q_n(n31_6));
    rd_7474_half ic31b(.clr_in(n34_10),.d(n31_6),.ck_in(n24_9),.pr_in(nc),.q(n31_9),.q_n(n31_8));
    assign tunnel_n = n31_8;
    // IC25: lower half (pins 1-6), upper half EXT. 500 (pins 8-13)
    wire n25_6, n25_9, n25_8;
    rd_7474_half ic25a(.clr_in(n34_10),.d(n25_9),.ck_in(n24_6),.pr_in(nc),.q(n25_5),.q_n(n25_6));
    // Pro: /CLR on 7442 output 6 (pin 7)
    rd_7474_half ic25b(.clr_in(d_pro ? n24_7 : n45_3),.d(d_extend),.ck_in(n24_5),.pr_in(nc),.q(n25_9),.q_n(n25_8));
    assign ext500 = n25_9;
    assign ext500_n = n25_8;
    assign slip = n31_5;                             // Pro pad EH
    // IC45 (1, 2 -> 3)
    wire n45_6, n45_8, n45_11;
    rd_7400 ic45(.p1(n40_8),.p2(n38_5),.p3(n45_3),
        .p4(nc),.p5(nc),.p6(n45_6),.p9(nc),.p10(nc),.p8(n45_8),.p12(nc),.p13(nc),.p11(n45_11));
    // IC32 (7425 section 1; strobe pin 3 not drawn)
    wire n32_6;
    rd_7425a ic32(.p5(n31_5),.p2(n31_9),.p4(n25_5),.p1(n40_5),.p3(nc),.p6(n32_6));
    // Pro: SLOW, an inverter (5 -> 6, designator unread) on IC32's output
    wire p9_6, p9_2, p9_4, p9_8, p9_10, p9_12;
    rd_7404 p9(.p5(n32_6),.p6(p9_6),
        .p1(nc),.p2(p9_2),.p3(nc),.p4(p9_4),.p9(nc),.p8(p9_8),.p11(nc),.p10(p9_10),.p13(nc),.p12(p9_12));
    assign slow = p9_6;
    // IC49 (74393 second half)
    rd_74393_half ic49(.ck_in(n40_8),.mr_in(n32_6),.q({n49_8,n49_9,n49_10,n49_11}));
    // IC39 (12, 13 -> 11)
    wire n39_11, n39_3, n39_6, n39_8;
    rd_7432 ic39(.p12(n49_10),.p13(n49_9),.p11(n39_11),
        .p1(nc),.p2(nc),.p3(n39_3),.p4(nc),.p5(nc),.p6(n39_6),.p9(nc),.p10(nc),.p8(n39_8));
    wire n48_5, n48_6, n41_5, n41_6;
    rd_74151 ic48(.p4(n47_3),.p3(d_mhl_n),.p2(vcc),.p1(vcc),.p15(vcc),.p14(vcc),.p13(vcc),.p12(n47_3),
        .p11(n49_11),.p10(n39_11),.p9(n49_8),.p7(gnd),.p5(n48_5),.p6(n48_6));
    rd_74151 ic41(.p4(vcc),.p3(n47_3),.p2(n47_3),.p1(n47_3),.p15(n47_3),.p14(n47_3),.p13(n47_3),.p12(d_mhl_n),
        .p11(n49_11),.p10(n39_11),.p9(n49_8),.p7(gnd),.p5(n41_5),.p6(n41_6));
    wire n68_7;
    rd_279_latch ic68(.s_in(n48_5),.r_in(n41_5),.q(n68_7));     // latch 2: /S 6, /R 5, Q 7

    // ------------------------------------------------------------ road sides
    wire n78_6, n78_8;
    rd_7420 ic78(.p1(m1v[0]),.p2(m1v[1]),.p5(m1v[3]),.p4(m1v[4]),.p6(n78_6),
        .p13(m2v[3]),.p9(m2v[5]),.p10(m2v[6]),.p12(m2v[7]),.p8(n78_8));
    wire n117_4, n117_2, n117_6, n117_8, n117_10, n117_12, n87_6;
    rd_7404 ic117(.p3(m2v[2]),.p4(n117_4),.p1(n87_6),.p2(n117_2),
        .p5(nc),.p6(n117_6),.p9(nc),.p8(n117_8),.p11(nc),.p10(n117_10),.p13(nc),.p12(n117_12));
    wire n90_6, n90_8;
    rd_ic90 #(.TYPE(IC90_TYPE)) ic90(.p13(m1v[2]),.p12(m1v[5]),.p10(m1v[6]),.p9(m1v[7]),.p11(nc),.p8(n90_8),
        .p2(m2v[0]),.p1(m2v[1]),.p4(n117_4),.p5(m2v[4]),.p3(nc),.p6(n90_6));
    wire n82_2, n82_4, n82_6, n82_8, n82_10, n82_12, n96_1, n89_12;
    rd_7404 ic82(.p1(n78_8),.p2(n82_2),.p3(m2v[6]),.p4(n82_4),.p5(m2v[5]),.p6(n82_6),
        .p9(n96_1),.p8(n82_8),.p11(n89_12),.p10(n82_10),.p13(n78_6),.p12(n82_12));
    assign zero_area_n = n82_10;
    wire n81_3, n81_6, n81_8, n81_11, n65_13, n87_8;
    rd_7400 ic81(.p13(n82_12),.p12(n90_8),.p11(n81_11),
        .p1(n82_2),.p2(n90_6),.p3(n81_3),
        .p4(n65_13),.p5(n87_8),.p6(n81_6),
        .p9(n82_8),.p10(n87_8),.p8(n81_8));
    assign r_side_n = n81_11;
    assign l_side_n = n81_3;
    assign house_st_n = n81_8;
    // IC88: upper half (pins 1-6, /PR not drawn), lower half (pins 8-13, /PR not drawn)
    wire n88_5, n88_6, n88_9, n88_8, n95_11;
    rd_7474_half ic88a(.clr_in(n95_11),.d(mh[6]),.ck_in(mh[5]),.pr_in(nc),.q(n88_5),.q_n(n88_6));
    rd_7474_half ic88b(.clr_in(n81_3),.d(d_v8_n),.ck_in(n81_11),.pr_in(nc),.q(n88_9),.q_n(n88_8));
    // IC74 (one half; pins not numbered, /PR not drawn)
    wire n74_q, n74_qn;
    rd_7474_half ic74(.clr_in(d_m2vl_n),.d(d_v8_n),.ck_in(d_m1vl_n),.pr_in(nc),.q(n74_q),.q_n(n74_qn));
    assign road = n74_q;
    assign road_n = n74_qn;

    // ------------------------------------------------------------ MH decodes
    wire n96_2, n96_3, n96_4, n96_5, n96_6, n96_7, n96_9, n96_10, n96_11;
    rd_7442 ic96(.p15(mh[5]),.p14(mh[6]),.p13(mh[7]),.p12(n88_9),
        .p1(n96_1),.p2(n96_2),.p3(n96_3),.p4(n96_4),.p5(n96_5),.p6(n96_6),.p7(n96_7),
        .p9(n96_9),.p10(n96_10),.p11(n96_11));
    wire n89_6, n89_8, n75_8, n104_6;
    rd_7427 ic89(.p1(mh[5]),.p2(mh[6]),.p13(mh[7]),.p12(n89_12),
        .p3(n88_6),.p4(n38_6),.p5(n75_8),.p6(n89_6),
        .p9(n89_6),.p10(n87_6),.p11(n104_6),.p8(n89_8));
    wire n95_6, n95_3, n95_8;
    rd_7408 ic95(.p4(n96_7),.p5(n96_6),.p6(n95_6),.p12(mh[8]),.p13(mh[7]),.p11(n95_11),
        .p1(nc),.p2(nc),.p3(n95_3),.p9(nc),.p10(nc),.p8(n95_8));
    wire n104_3, n104_8, n104_11, n67_7, n80_10, n66_6;
    rd_7432 ic104(.p1(d_v7),.p2(n88_9),.p3(n104_3),
        .p4(n80_10),.p5(n66_6),.p6(n104_6),
        .p9(mh[4]),.p10(n67_7),.p8(n104_8),
        .p13(mh[8]),.p12(n95_6),.p11(n104_11));
    assign side_line_n = n104_8;
    wire n56_3, n56_11, n56_6, n56_8;
    rd_7400 ic56(.p2(n104_11),.p1(n68_7),.p3(n56_3),
        .p12(n56_3),.p13(n87_8),.p11(n56_11),
        .p4(nc),.p5(nc),.p6(n56_6),.p9(nc),.p10(nc),.p8(n56_8));
    assign grass_area_n = n56_11;
    wire n65_4, n65_1, n65_10, n58_3, n58_6;
    rd_7402 ic65(.p12(n56_3),.p11(n82_8),.p13(n65_13),
        .p5(n58_3),.p6(n58_6),.p4(n65_4),
        .p2(nc),.p3(nc),.p1(n65_1),.p8(nc),.p9(nc),.p10(n65_10));
    assign slide_n = n65_4;
    wire n110_6, n110_8, n110_3, n110_11;
    rd_7400 ic110(.p4(n96_3),.p5(n96_5),.p6(n110_6),.p9(n110_6),.p10(mh[8]),.p8(n110_8),
        .p1(nc),.p2(nc),.p3(n110_3),.p12(nc),.p13(nc),.p11(n110_11));

    // ------------------------------------------------------------ control gates
    wire n80_1, n80_4, n80_13, n94_6, n94_8;
    rd_7402 ic80(.p2(n25_6),.p3(n68_7),.p1(n80_1),
        .p6(n80_1),.p5(n80_13),.p4(n80_4),
        .p11(n31_8),.p12(n68_7),.p13(n80_13),
        .p9(n94_6),.p8(n94_8),.p10(n80_10));
    assign bridge_ap = n80_1;
    assign tunnel_ap = n80_13;
    wire n87_11, n87_3;
    rd_7408 ic87(.p4(n74_qn),.p5(n80_13),.p6(n87_6),
        .p10(n74_qn),.p9(n80_4),.p8(n87_8),
        .p13(n81_11),.p12(n81_3),.p11(n87_11),
        .p1(nc),.p2(nc),.p3(n87_3));
    assign y_line_n = n87_11;
    wire n94_12;
    rd_7410 ic94(.p4(n87_11),.p3(n96_1),.p5(n80_4),.p6(n94_6),
        .p9(n80_4),.p11(n74_q),.p10(n88_8),.p8(n94_8),
        .p1(nc),.p2(nc),.p13(nc),.p12(n94_12));
    assign green_belt_n = n94_8;
    wire n73_6, n73_12, n73_8;
    rd_7427 ic73(.p4(n40_6),.p3(n68_7),.p5(n88_8),.p6(n73_6),
        .p1(n31_6),.p13(n68_7),.p2(n88_8),.p12(n73_12),
        .p9(nc),.p10(nc),.p11(nc),.p8(n73_8));
    wire n59_12, n59_2, n59_4, n59_6, n59_8, n59_10;
    rd_7404 ic59(.p13(n73_12),.p12(n59_12),
        .p1(nc),.p2(n59_2),.p3(nc),.p4(n59_4),.p5(nc),.p6(n59_6),.p9(nc),.p8(n59_8),.p11(nc),.p10(n59_10));
    assign slip_n = n59_12;
    wire n75_6, n75_12;
    rd_7410 ic75(.p3(m2v[6]),.p4(m2v[7]),.p5(n82_6),.p6(n75_6),
        .p9(m2v[5]),.p11(n82_4),.p10(m2v[7]),.p8(n75_8),
        .p1(nc),.p2(nc),.p13(nc),.p12(n75_12));
    // IC66: 7410 or 7411, by the reading of its output (see the trace)
    wire n66_12, n66_8;
    generate if (IC66_NAND) begin: g66n
        rd_7410 ic66(.p3(n75_6),.p4(n82_10),.p5(n73_6),.p6(n66_6),
            .p1(nc),.p2(nc),.p13(nc),.p12(n66_12),.p9(nc),.p10(nc),.p11(nc),.p8(n66_8));
    end else begin: g66a
        rd_7411 ic66(.p3(n75_6),.p4(n82_10),.p5(n73_6),.p6(n66_6),
            .p1(nc),.p2(nc),.p13(nc),.p12(n66_12),.p9(nc),.p10(nc),.p11(nc),.p8(n66_8));
    end endgenerate

    // ------------------------------------------------------------ PROM paths
    wire av0, av1, av2, av3, av4, n67_9, n67_12;
    rd_74157 ic92(.p1(n104_3),.p15(gnd),
        .p2(m1v[0]),.p3(m2v[0]),.p4(av0),
        .p5(m1v[1]),.p6(m2v[1]),.p7(av1),
        .p11(m1v[2]),.p10(m2v[2]),.p9(av2),
        .p14(m1v[3]),.p13(m2v[3]),.p12(av3));
    rd_74157 ic67(.p1(n104_3),.p15(gnd),
        .p2(m1v[4]),.p3(m2v[4]),.p4(av4),
        .p5(d_m1vl_n),.p6(d_m2vl_n),.p7(n67_7),
        .p11(nc),.p10(nc),.p9(n67_9),.p14(nc),.p13(nc),.p12(n67_12));
    // PR-134 = IC113
    wire n113_9, n113_10, n113_11, n113_13, n113_14, n113_15, n113_16, n113_17;
    rd_prom512 #(.OFFSET(4608)) ic113(.p8(av0),.p7(av1),.p6(av2),.p5(av3),.p4(av4),
        .p3(mh[2]),.p2(mh[3]),.p1(mh[4]),.p23(n110_8),
        .p18(vcc),.p19(vcc),.p20(gnd),.p21(gnd),
        .p9(n113_9),.p10(n113_10),.p11(n113_11),.p13(n113_13),.p14(n113_14),
        .p15(n113_15),.p16(n113_16),.p17(n113_17));
    wire n112_9;
    rd_74153 ic112(.p14(mh[0]),.p2(mh[1]),.p1(n81_6),.p15(n81_6),
        .p6(n113_9),.p5(n113_10),.p4(n113_11),.p3(n113_13),
        .p10(n113_14),.p11(n113_15),.p12(n113_16),.p13(n113_17),
        .p7(n112_7),.p9(n112_9));
    // PR-135 = IC106 (pin 23 grounded)
    wire n106_9, n106_10, n106_11, n106_13, n106_14, n106_15, n106_16, n106_17;
    rd_prom512 #(.OFFSET(5120)) ic106(.p8(av0),.p7(av1),.p6(av2),.p5(av3),.p4(av4),
        .p3(mh[2]),.p2(mh[3]),.p1(mh[4]),.p23(gnd),
        .p18(vcc),.p19(vcc),.p20(gnd),.p21(gnd),
        .p9(n106_9),.p10(n106_10),.p11(n106_11),.p13(n106_13),.p14(n106_14),
        .p15(n106_15),.p16(n106_16),.p17(n106_17));
    wire n105_7;
    rd_74153 ic105(.p14(mh[0]),.p2(mh[1]),.p1(n56_11),.p15(n56_11),
        .p6(n106_9),.p5(n106_10),.p4(n106_11),.p3(n106_13),
        .p10(n106_14),.p11(n106_15),.p12(n106_16),.p13(n106_17),
        .p7(n105_7),.p9(n105_9));
    wire n22_4, n22_6, n22_2, n22_8, n22_10, n22_12;
    rd_7404 ic22(.p3(n105_9),.p4(n22_4),.p5(n80_1),.p6(n22_6),
        .p1(nc),.p2(n22_2),.p9(nc),.p8(n22_8),.p11(nc),.p10(n22_10),.p13(nc),.p12(n22_12));
    assign grass_w_n = n22_4;
    // PR-136 = IC99
    wire n99_9, n99_10, n99_11, n99_13, n99_14, n99_15, n99_16, n99_17;
    rd_prom512 #(.OFFSET(5632)) ic99(.p8(av0),.p7(av1),.p6(av2),.p5(av3),.p4(av4),
        .p3(mh[1]),.p2(mh[2]),.p1(mh[3]),.p23(mh[4]),
        .p18(vcc),.p19(vcc),.p20(gnd),.p21(gnd),
        .p9(n99_9),.p10(n99_10),.p11(n99_11),.p13(n99_13),.p14(n99_14),
        .p15(n99_15),.p16(n99_16),.p17(n99_17));
    wire n98_4, n98_7, n98_9, n98_12;
    rd_74157 ic98(.p1(mh[0]),.p15(n81_8),
        .p2(n99_9),.p3(n99_10),.p4(n98_4),
        .p5(n99_11),.p6(n99_13),.p7(n98_7),
        .p11(n99_14),.p10(n99_15),.p9(n98_9),
        .p14(n99_16),.p13(n99_17),.p12(n98_12));
    wire n97_1, n97_6, n97_7, n97_9, n97_10, n97_11;
    rd_7442 ic97(.p15(n98_4),.p14(n98_7),.p13(n98_9),.p12(gnd),
        .p1(n97_1),.p2(house_n[0]),.p3(house_n[1]),.p4(house_n[2]),.p5(house_n[3]),
        .p6(n97_6),.p7(n97_7),.p9(n97_9),.p10(n97_10),.p11(n97_11));
    // PR-137 = IC120
    wire n120_9, n120_10, n120_11, n120_13, n120_14, n120_15, n120_16, n120_17;
    rd_prom512 #(.OFFSET(6144)) ic120(.p8(av0),.p7(av1),.p6(av2),.p5(av3),.p4(av4),
        .p3(mh[2]),.p2(mh[3]),.p1(mh[4]),.p23(n117_2),
        .p18(vcc),.p19(vcc),.p20(gnd),.p21(gnd),
        .p9(n120_9),.p10(n120_10),.p11(n120_11),.p13(n120_13),.p14(n120_14),
        .p15(n120_15),.p16(n120_16),.p17(n120_17));
    wire n119_7, n119_9;
    rd_74153 ic119(.p14(mh[0]),.p2(mh[1]),.p1(n89_8),.p15(n89_8),
        .p6(n120_9),.p5(n120_10),.p4(n120_11),.p3(n120_13),
        .p10(n120_14),.p11(n120_15),.p12(n120_16),.p13(n120_17),
        .p7(n119_7),.p9(n119_9));

    // ------------------------------------------------------------ output gates
    wire n60_8, n60_12, n60_6, n58_11, n58_8;
    rd_7427 ic60(.p9(n112_9),.p10(n105_7),.p11(n58_11),.p8(n60_8),
        .p1(nc),.p2(nc),.p13(nc),.p12(n60_12),.p3(nc),.p4(nc),.p5(nc),.p6(n60_6));
    assign tree_grass_g_n = n60_8;
    assign belt = n58_11;                            // Pro: BELT (C), a branch of this net
    rd_7408 ic58(.p2(n88_8),.p1(n22_6),.p3(n58_3),
        .p5(n80_1),.p4(d_v4dec_n),.p6(n58_6),
        .p13(n119_7),.p12(n80_10),.p11(n58_11),
        .p9(nc),.p10(nc),.p8(n58_8));
    wire n72_3, n72_6, n72_8, n72_11;
    rd_7400 ic72(.p9(n119_9),.p10(n89_6),.p8(n72_8),
        .p2(n119_7),.p1(n87_6),.p3(n72_3),
        .p13(n119_7),.p12(n66_6),.p11(n72_11),
        .p4(nc),.p5(nc),.p6(n72_6));
    assign pool_n = n72_8;
    assign wall_n = n72_3;
    assign gravel_n = n72_11;

    // Internal state, in the RTL's order
    assign dbg = {n40_5, n40_9, n38_5, ic38b.q, n31_5, n31_9, n25_5, ic25b.q, ic88a.q, ic88b.q, ic74.q,
                  ic49.q, n68_7, n40_5, n31_5, n31_9, n25_5, n38_9, n25_9, n88_5, n88_9};
endmodule
