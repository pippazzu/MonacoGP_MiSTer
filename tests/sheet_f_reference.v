// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected, event-driven reference for sheet F (manual
// 420-0358, PDF page 26). Each package is modelled from its data sheet pin
// functions and wired by IC and pin number from the pin tables in
// docs/trace/SHEET_F_TRACE.md. Self-contained: the rf_ models below are
// written for this file.
//
// Timing rule ("settled layers"). The delays are NOT TTL delays; they make
// the circuit settle in layers, the rule that the RTL implements step by step:
// - Gates, multiplexers and comparators take 0.01 ns, latches and the
//   asynchronous load, clear and reset inputs 0.02 ns, so that every
//   combinational path settles within a fraction of a nanosecond.
// - Every clock and trigger input goes through a 3 ns inertial filter
//   (rf_filt): a pulse shorter than that is a hazard of the path delays
//   above, is absorbed and counted. A change that lasts a layer passes.
// - The edge-triggered parts act 1 ns after the filtered edge, reading their
//   other inputs (D, the other 74193 clock, the 74123 B input) as settled.
// So all parts clocked by one settled change act together, about 4 ns later,
// and see each other's new outputs only in the next layer, as in the RTL.
`timescale 1ns/1ps

`ifndef TTL
`define TTL(x) ((x) === 1'bz ? 1'b1 : (x))
`endif
`define RF_G  0.01      // gate
`define RF_L  0.02      // latch, asynchronous load/clear
`define RF_W  3.0       // clock filter
`define RF_CQ 1.0       // clock to output

// Inertial filter on clock and trigger inputs, with a hazard counter.
module rf_filt(input a, output y);
    assign #(`RF_W) y = `TTL(a);
    integer hazards = 0;
    realtime t = -1.0e9;
    always @(a) begin
        if ($realtime > 1000.0 && $realtime - t < `RF_W) hazards = hazards + 1;
        t = $realtime;
    end
endmodule
// One layer of delay: stands for a cut that the RTL makes in a loop of
// gates and latches (it reads the net's value at the previous step).
module rf_layer(input a, output y);
    wire f;
    rf_filt u(.a(a),.y(f));
    assign #(`RF_CQ) y = f;
endmodule

module rf_7400(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RF_G) p3 =~(`TTL(p1)&`TTL(p2));
    assign #(`RF_G) p6 =~(`TTL(p4)&`TTL(p5));
    assign #(`RF_G) p8 =~(`TTL(p9)&`TTL(p10));
    assign #(`RF_G) p11=~(`TTL(p12)&`TTL(p13));
endmodule
module rf_7402(input p2,p3,p5,p6,p8,p9,p11,p12, output p1,p4,p10,p13);
    assign #(`RF_G) p1 =~(`TTL(p2)|`TTL(p3));
    assign #(`RF_G) p4 =~(`TTL(p5)|`TTL(p6));
    assign #(`RF_G) p10=~(`TTL(p8)|`TTL(p9));
    assign #(`RF_G) p13=~(`TTL(p11)|`TTL(p12));
endmodule
module rf_7404(input p1,p3,p5,p9,p11,p13, output p2,p4,p6,p8,p10,p12);
    assign #(`RF_G) p2 =~`TTL(p1);
    assign #(`RF_G) p4 =~`TTL(p3);
    assign #(`RF_G) p6 =~`TTL(p5);
    assign #(`RF_G) p8 =~`TTL(p9);
    assign #(`RF_G) p10=~`TTL(p11);
    assign #(`RF_G) p12=~`TTL(p13);
endmodule
// 7414 hex Schmitt inverter: the logic function of a 7404.
module rf_7414(input p1,p3,p5,p9,p11,p13, output p2,p4,p6,p8,p10,p12);
    rf_7404 u(.p1(p1),.p3(p3),.p5(p5),.p9(p9),.p11(p11),.p13(p13),
              .p2(p2),.p4(p4),.p6(p6),.p8(p8),.p10(p10),.p12(p12));
endmodule
// 7417 hex buffer (open collector; the pull-ups are not modelled).
module rf_7417(input p1,p3,p5,p9,p11,p13, output p2,p4,p6,p8,p10,p12);
    assign #(`RF_G) p2 =`TTL(p1);
    assign #(`RF_G) p4 =`TTL(p3);
    assign #(`RF_G) p6 =`TTL(p5);
    assign #(`RF_G) p8 =`TTL(p9);
    assign #(`RF_G) p10=`TTL(p11);
    assign #(`RF_G) p12=`TTL(p13);
endmodule
module rf_7408(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RF_G) p3 =`TTL(p1)&`TTL(p2);
    assign #(`RF_G) p6 =`TTL(p4)&`TTL(p5);
    assign #(`RF_G) p8 =`TTL(p9)&`TTL(p10);
    assign #(`RF_G) p11=`TTL(p12)&`TTL(p13);
endmodule
module rf_7410(input p1,p2,p13,p3,p4,p5,p9,p10,p11, output p12,p6,p8);
    assign #(`RF_G) p12=~(`TTL(p1)&`TTL(p2)&`TTL(p13));
    assign #(`RF_G) p6 =~(`TTL(p3)&`TTL(p4)&`TTL(p5));
    assign #(`RF_G) p8 =~(`TTL(p9)&`TTL(p10)&`TTL(p11));
endmodule
module rf_7420(input p1,p2,p4,p5,p9,p10,p12,p13, output p6,p8);
    assign #(`RF_G) p6=~(`TTL(p1)&`TTL(p2)&`TTL(p4)&`TTL(p5));
    assign #(`RF_G) p8=~(`TTL(p9)&`TTL(p10)&`TTL(p12)&`TTL(p13));
endmodule
// Dual 4-input NOR with strobe: Y = /(G & (A+B+C+D)).
module rf_7425(input p1,p2,p3,p4,p5,p9,p10,p11,p12,p13, output p6,p8);
    assign #(`RF_G) p6=~(`TTL(p3)&(`TTL(p1)|`TTL(p2)|`TTL(p4)|`TTL(p5)));
    assign #(`RF_G) p8=~(`TTL(p11)&(`TTL(p9)|`TTL(p10)|`TTL(p12)|`TTL(p13)));
endmodule
module rf_7427(input p1,p2,p13,p3,p4,p5,p9,p10,p11, output p12,p6,p8);
    assign #(`RF_G) p12=~(`TTL(p1)|`TTL(p2)|`TTL(p13));
    assign #(`RF_G) p6 =~(`TTL(p3)|`TTL(p4)|`TTL(p5));
    assign #(`RF_G) p8 =~(`TTL(p9)|`TTL(p10)|`TTL(p11));
endmodule
module rf_7432(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RF_G) p3 =`TTL(p1)|`TTL(p2);
    assign #(`RF_G) p6 =`TTL(p4)|`TTL(p5);
    assign #(`RF_G) p8 =`TTL(p9)|`TTL(p10);
    assign #(`RF_G) p11=`TTL(p12)|`TTL(p13);
endmodule
// Dual 2-wide 2-input AND-OR-invert: 1Y = /(1A.1B + 1C.1D + X), 2Y = /(2A.2B + 2C.2D).
// The expander pins 11 (1/X) and 12 (1X) are left open: no expander.
module rf_7450(input p1,p13,p9,p10,p2,p3,p4,p5, output p8,p6);
    assign #(`RF_G) p8=~((`TTL(p1)&`TTL(p13))|(`TTL(p9)&`TTL(p10)));
    assign #(`RF_G) p6=~((`TTL(p2)&`TTL(p3))|(`TTL(p4)&`TTL(p5)));
endmodule
module rf_7486(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RF_G) p3 =`TTL(p1)^`TTL(p2);
    assign #(`RF_G) p6 =`TTL(p4)^`TTL(p5);
    assign #(`RF_G) p8 =`TTL(p9)^`TTL(p10);
    assign #(`RF_G) p11=`TTL(p12)^`TTL(p13);
endmodule
// Quad /S-/R latch. A low /S wins (both low drives Q high).
module rf_74279(input p1,p2,p3,p5,p6,p10,p11,p12,p14,p15,
                output reg p4=0, output reg p7=0, output reg p9=0, output reg p13=0);
    always @* begin
        if (!`TTL(p2) || !`TTL(p3)) p4 <= #(`RF_L) 1; else if (!`TTL(p1)) p4 <= #(`RF_L) 0;
        if (!`TTL(p6)) p7 <= #(`RF_L) 1; else if (!`TTL(p5)) p7 <= #(`RF_L) 0;
        if (!`TTL(p11) || !`TTL(p12)) p9 <= #(`RF_L) 1; else if (!`TTL(p10)) p9 <= #(`RF_L) 0;
        if (!`TTL(p15)) p13 <= #(`RF_L) 1; else if (!`TTL(p14)) p13 <= #(`RF_L) 0;
    end
endmodule
// 4-bit magnitude comparator. A0..A3 = pins 10, 12, 13, 15; B0..B3 = pins
// 9, 11, 14, 1; cascade inputs A<B pin 2, A=B pin 3, A>B pin 4; outputs
// A>B pin 5, A=B pin 6, A<B pin 7. Equal words follow the data sheet's
// cascade table, including the cases with several cascade inputs high.
module rf_7485(input p1,p2,p3,p4,p9,p10,p11,p12,p13,p14,p15, output p5,p6,p7);
    wire [3:0] a = {`TTL(p15),`TTL(p13),`TTL(p12),`TTL(p10)};
    wire [3:0] b = {`TTL(p1),`TTL(p14),`TTL(p11),`TTL(p9)};
    wire ilt=`TTL(p2), ieq=`TTL(p3), igt=`TTL(p4);
    reg [2:0] o;                      // {A>B, A=B, A<B}
    always @* begin
        if (a > b) o = 3'b100;
        else if (a < b) o = 3'b001;
        else if (ieq) o = 3'b010;
        else if (igt && !ilt) o = 3'b100;
        else if (!igt && ilt) o = 3'b001;
        else if (igt && ilt) o = 3'b000;
        else o = 3'b101;
    end
    assign #(`RF_G) {p5,p6,p7} = o;
endmodule
// Dual 4-to-1 mux: S1 pin 2, S0 pin 14; section 1 /E pin 1, I0..I3 = pins
// 6, 5, 4, 3, Z pin 7; section 2 /E pin 15, I0..I3 = pins 10, 11, 12, 13, Z pin 9.
module rf_74153(input p1,p2,p3,p4,p5,p6,p10,p11,p12,p13,p14,p15, output p7,p9);
    wire [1:0] s = {`TTL(p2),`TTL(p14)};
    wire [3:0] c1 = {`TTL(p3),`TTL(p4),`TTL(p5),`TTL(p6)};
    wire [3:0] c2 = {`TTL(p13),`TTL(p12),`TTL(p11),`TTL(p10)};
    assign #(`RF_G) p7 = !`TTL(p1)  && c1[s];
    assign #(`RF_G) p9 = !`TTL(p15) && c2[s];
endmodule
// 8-to-1 mux: I0..I7 = pins 4, 3, 2, 1, 15, 14, 13, 12; S0..S2 = pins 11,
// 10, 9; /E pin 7; Z pin 5, /Z pin 6.
module rf_74151(input p1,p2,p3,p4,p7,p9,p10,p11,p12,p13,p14,p15, output p5,p6);
    wire [7:0] i = {`TTL(p12),`TTL(p13),`TTL(p14),`TTL(p15),`TTL(p1),`TTL(p2),`TTL(p3),`TTL(p4)};
    wire [2:0] s = {`TTL(p9),`TTL(p10),`TTL(p11)};
    assign #(`RF_G) p5 = !`TTL(p7) && i[s];
    assign #(`RF_G) p6 = ~(!`TTL(p7) && i[s]);
endmodule
// Quad 2-to-1 mux: S pin 1, /E pin 15; channels (I0, I1 -> Z) = (2, 3 -> 4),
// (5, 6 -> 7), (11, 10 -> 9), (14, 13 -> 12).
module rf_74157(input p1,p2,p3,p5,p6,p10,p11,p13,p14,p15, output p4,p7,p9,p12);
    wire s=`TTL(p1), en=!`TTL(p15);
    assign #(`RF_G) p4  = en && (s ? `TTL(p3)  : `TTL(p2));
    assign #(`RF_G) p7  = en && (s ? `TTL(p6)  : `TTL(p5));
    assign #(`RF_G) p9  = en && (s ? `TTL(p10) : `TTL(p11));
    assign #(`RF_G) p12 = en && (s ? `TTL(p13) : `TTL(p14));
endmodule
// One 7474 half: /CLR pin 1, D pin 2, CK pin 3, /PR pin 4, Q pin 5, /Q pin 6.
module rf_7474_half(input p1,p2,p3,p4, output reg p5=0, output p6);
    wire clr_n=`TTL(p1), d=`TTL(p2), pr_n=`TTL(p4);
    wire ck;
    reg dd;
    rf_filt fck(.a(p3),.y(ck));
    assign p6 = (!clr_n && !pr_n) ? 1'b1 : ~p5;
    always @(clr_n or pr_n)
        if (!clr_n) p5 <= #(`RF_L) 0;
        else if (!pr_n) p5 <= #(`RF_L) 1;
    always @(posedge ck) if (clr_n && pr_n) begin
        dd = d;
        #(`RF_CQ) if (clr_n && pr_n) p5 <= dd;
    end
endmodule
// Synchronous 4-bit up/down counter. A, B, C, D = pins 15, 1, 10, 9;
// QA, QB, QC, QD = pins 3, 2, 6, 7; DOWN pin 4, UP pin 5, /LOAD pin 11,
// CLR pin 14 (active high), /CO pin 12, /BO pin 13. A rising UP counts up
// while DOWN is high, and the other way round.
module rf_74193(input p15,p1,p10,p9,p4,p5,p11,p14, output p3,p2,p6,p7,p12,p13);
    wire ld_n=`TTL(p11), clr=`TTL(p14), up_s=`TTL(p5), dn_s=`TTL(p4);
    wire up, dn;
    rf_filt fup(.a(p5),.y(up));
    rf_filt fdn(.a(p4),.y(dn));
    wire [3:0] d = {`TTL(p9),`TTL(p10),`TTL(p1),`TTL(p15)};
    reg  [3:0] q = 0, nu, nd;
    always @(posedge up) if (!clr && ld_n && dn_s) begin
        nu = q + 4'd1;
        #(`RF_CQ) if (!clr && ld_n) q = nu;
    end
    always @(posedge dn) if (!clr && ld_n && up_s) begin
        nd = q - 4'd1;
        #(`RF_CQ) if (!clr && ld_n) q = nd;
    end
    always @(clr or ld_n or d) if (clr) q <= #(`RF_L) 0; else if (!ld_n) q <= #(`RF_L) d;
    assign {p7,p6,p2,p3} = q;
    assign #(`RF_G) p12 = ~((&q) & ~up_s);
    assign #(`RF_G) p13 = ~((~|q) & ~dn_s);
endmodule
// One 74393 counter: counts the falling edges of CP; MR is asynchronous and
// active high. The four stages switch together (their ripple delay is below
// the layer).
module rf_393_half(input cp_in, mr_in, output qa, qb, qc, qd);
    wire cp;
    wire mr = `TTL(mr_in);
    reg [3:0] q = 0, nq;
    rf_filt fcp(.a(cp_in),.y(cp));
    always @(negedge cp) if (!mr) begin
        nq = q + 4'd1;
        #(`RF_CQ) if (!mr) q = nq;
    end
    always @(mr) if (mr) q <= #(`RF_L) 0;
    assign {qd,qc,qb,qa} = q;
endmodule
module rf_74393(input p1,p2,p12,p13, output p3,p4,p5,p6,p8,p9,p10,p11);
    rf_393_half u1(.cp_in(p1),.mr_in(p2),.qa(p3),.qb(p4),.qc(p5),.qd(p6));
    rf_393_half u2(.cp_in(p13),.mr_in(p12),.qa(p11),.qb(p10),.qc(p9),.qd(p8));
endmodule
// One half of a 74123 retriggerable monostable: A pin 1/9 (active low),
// B pin 2/10, /CLR pin 3/11, Q pin 13/5, /Q pin 4/12. Triggers: A falling
// while B is high, B rising while A is low, /CLR rising while A is low and
// B high. The filtered inputs are evaluated together 0.5 ns after the
// first of them changes, and Q follows 0.5 ns later, one layer after the
// change. CLR_ASYNC = 1: a low /CLR ends the pulse at once (0.02 ns);
// CLR_ASYNC = 0: one layer later, like a trigger (the RTL's cut for IC1,
// whose two halves clear each other).
// The width tw = 0.28*R*C*(1+0.7/R) ns of the data sheet (R in kohm, C in
// pF) is counted in 7 MHz periods: the pulse ends at the 7 MHz edge after
// its last pixel, when the nets from other sheets change too (5 ns).
module rf_74123 #(parameter real R_KOHM=47.0, parameter real C_PF=1.0e7,
                  parameter CLR_ASYNC=1)(
    input a, b, clr_n, f7, output reg q=0, output q_n
);
    localparam real TW = 0.28*R_KOHM*C_PF*(1.0+0.7/R_KOHM);
    integer pixels, left = 0, trigs = 0;
    initial pixels = $rtoi(TW*7.1525e-3 + 0.5);
    wire ta, tb, tc;
    wire clr_s = `TTL(clr_n);
    rf_filt fa(.a(a),.y(ta));
    rf_filt fb(.a(b),.y(tb));
    rf_filt fc(.a(clr_n),.y(tc));
    reg ta_l=1, tb_l=0, tc_l=1, trig;
    assign q_n = ~q;
    always @(clr_s) if (CLR_ASYNC && !clr_s) begin
        left = 0;
        q <= #(`RF_L) 0;
    end
    always @(ta or tb or tc) begin
        #0.5;
        trig = (ta_l && !ta && tb) || (!tb_l && tb && !ta) || (!tc_l && tc && !ta && tb);
        if (!tc || (CLR_ASYNC && !clr_s)) begin
            left = 0;
            q <= #0.5 0;
        end else if (trig) begin
            trigs = trigs + 1;
            left = pixels;
            q <= #0.5 1;
        end
        ta_l = ta; tb_l = tb; tc_l = tc;
    end
    always @(posedge f7) if (left > 0) begin
        left = left - 1;
        if (left == 0) q <= #5 0;
    end
endmodule
module sheet_f_reference #(
    // One-shot capacitors in pF, as read: C2, C1 4.7 uF; C20 10 uF; C18 15 uF; C21 22 uF
    parameter real C1A_PF = 4.7e6, C1B_PF = 4.7e6,
    parameter real C43A_PF = 1.0e7, C43B_PF = 1.5e7, C49_PF = 2.2e7
)(
    // Sheet-edge inputs, named as drawn
    input f_7mhz,                               // pad C13
    input f_h4, f_h5, f_h6, f_h8, f_hs_n,       // pads C8, C7, CH, CF, CJ
    input f_v4, f_v5_n, f_v6, f_v6_n, f_v7, f_v7_n, // pads BT, BU, B12, B17, BN, B18
    input f_coin_test_n, f_game_n, f_extend, f_8000,
    input f_vs2, f_vs8, f_vs16, f_vs32, f_vs64, f_other_body_n,
    input f_slip_n, f_pool2_n, f_road, f_tunnel_n, f_ext500_n,
    input f_rescue_n, f_bridge_n, f_ext_car_cont,
    input f_sp_down_n, f_sp_down, f_score_st_n, f_acc1_st_n, f_acc1_pulse_n, f_player,
    input f_acce_a, f_acce_b, f_han_l, f_han_r, f_shift_no, f_shift_nc,
    input f_ic27_3,                             // IC27 pin 3 is not drawn
    // Sheet-edge outputs
    output pl_h_st, pl_v_st, shift, slipzone_n, nonroad_slip_n, acce_st,
    output [3:0] acce, s_acce,
    output score_cp_n, s_acc1_n, acc1_n, splay_a_n, splay_b_n, sp_irreg_n, home_pos_n,
    output [3:0] explo_sel,
    output explo_st, explo_st_n,
    // Observation
    output [7:0] ic19_q, ic40_q,
    output [6:0] hpos_t,
    output [7:0] vpos_t,
    output [36:0] state
);
    wire nc;
    wire ic1_4, ic1_5, ic1_12, ic1_13;
    wire ic2_3, ic2_6, ic2_8, ic2_11;
    wire ic3_7, ic3_9, ic4_5;
    wire ic5_3, ic5_4, ic5_5, ic5_6;
    wire ic6_2, ic6_4, ic6_6, ic6_8, ic6_10, ic6_12;
    wire ic7_5, ic7_7, ic8_3, ic8_6, ic8_8, ic8_11, ic9_7, ic9_9;
    wire ic10_5, ic10_7, ic11_5, ic11_6, ic11_7, ic12_3, ic12_6;
    wire ic13_2, ic13_4, ic13_6, ic13_8, ic13_10, ic13_12, ic14_6, ic14_8;
    wire ic15_2, ic15_3, ic15_6, ic15_7, ic16_3, ic16_6, ic16_8, ic16_11;
    wire ic17_6, ic18_6;
    wire ic19_3, ic19_4, ic19_5, ic19_6, ic19_8, ic19_9, ic19_10, ic19_11;
    wire ic22_3, ic23_3, ic23_6, ic23_8, ic23_11;
    wire ic24_2, ic24_3, ic24_6, ic25_2, ic25_3, ic25_6, ic25_7, ic25_12, ic25_13;
    wire ic27_4, ic27_7, ic27_13, ic28_6, ic28_8, ic29_2, ic29_4, ic29_8;
    wire ic30_3, ic30_8, ic30_11, ic32_13, ic33_5, ic33_6, ic34_3, ic34_6, ic34_8;
    wire ic35_2, ic35_3, ic35_6, ic35_7, ic36_2, ic36_3, ic36_6, ic36_7, ic36_12, ic36_13;
    wire ic39_3, ic39_4, ic39_5, ic39_6;
    wire ic40_3, ic40_4, ic40_5, ic40_6, ic40_8, ic40_9, ic40_10, ic40_11;
    wire ic41_6, ic42_6, ic43_4, ic43_5, ic43_12, ic43_13, ic44_2, ic44_12, ic46_2;
    wire ic47_6, ic47_8, ic48_8, ic49_5, ic60_4, ic60_7, ic61_1, ic62_3, ic63_13;
    wire ic66_8, ic67_6, ic67_8, ic68_6, ic68_11, ic69_7, ic69_9;
    wire ic72_4, ic72_13, ic73_6, ic73_8, ic74_12, ic80_6, ic80_12;
    // C3 (IC74 output) and C17 (IC47 pin 8), 330-470 pF to ground on the two
    // counter clears, are modelled as clock filters: they absorb decoder
    // hazards such as the one IC68 leaves on IC74 when H goes from 0x1FF to
    // 0x098. C16 on the IC39 clock (IC34 pin 8) is the filter of that clock
    // input.
    wire c3_net, c17_net;
    rf_filt c3(.a(ic74_12),.y(c3_net));
    rf_filt c17(.a(ic47_8),.y(c17_net));

    // IC1 (74123): the halves clear each other, a loop that the RTL cuts
    // with a layer at /CLR (CLR_ASYNC = 0). First half A 1, B 2 = HAN.-L-CP (pad A8), /CLR 3 = IC1.12,
    // Q 13, /Q 4, C2/R3 on pins 14, 15; second half A 9, B 10 = HAN.-R-CP
    // (pad AJ), /CLR 11 = IC1.4, Q 5, /Q 12, C1/R2 on pins 6, 7.
    rf_74123 #(.C_PF(C1A_PF),.CLR_ASYNC(0)) ic1a(.a(ic43_4),.b(f_han_l),.clr_n(ic1_12),.f7(f_7mhz),
        .q(ic1_13),.q_n(ic1_4));
    rf_74123 #(.C_PF(C1B_PF),.CLR_ASYNC(0)) ic1b(.a(ic43_4),.b(f_han_r),.clr_n(ic1_4),.f7(f_7mhz),
        .q(ic1_5),.q_n(ic1_12));
    // IC2 (7408)
    rf_7408 ic2(.p1(ic43_12),.p2(f_sp_down_n),.p4(f_v6_n),.p5(ic1_5),.p9(ic1_13),.p10(f_v6_n),
        .p12(f_sp_down_n),.p13(ic6_10),.p3(ic2_3),.p6(ic2_6),.p8(ic2_8),.p11(ic2_11));
    // IC3 (74153)
    rf_74153 ic3(.p1(1'b0),.p2(ic43_4),.p3(f_han_l),.p4(ic72_4),.p5(ic2_8),.p6(1'b0),
        .p10(1'b0),.p11(ic2_6),.p12(ic66_8),.p13(f_han_r),.p14(ic43_12),.p15(1'b0),
        .p7(ic3_7),.p9(ic3_9));
    // IC4 (74151): pin 6 is an open stub.
    rf_74151 ic4(.p1(ic5_4),.p2(ic5_4),.p3(ic5_3),.p4(ic5_3),.p7(ic23_3),.p9(ic6_2),
        .p10(ic6_4),.p11(ic6_6),.p12(ic5_6),.p13(ic5_6),.p14(ic5_5),.p15(ic5_5),
        .p5(ic4_5),.p6());
    // IC5 (74393, first half drawn)
    rf_74393 ic5(.p1(ic67_6),.p2(f_game_n),.p12(1'b1),.p13(1'b0),
        .p3(ic5_3),.p4(ic5_4),.p5(ic5_5),.p6(ic5_6),.p8(),.p9(),.p10(),.p11());
    // IC6 (Schmitt inverter)
    rf_7414 ic6(.p1(ic15_7),.p3(ic15_6),.p5(ic15_2),.p9(f_acce_a),.p11(f_acce_b),.p13(ic6_2),
        .p2(ic6_2),.p4(ic6_4),.p6(ic6_6),.p8(ic6_8),.p10(ic6_10),.p12(ic6_12));
    // IC7 (7485): pin 6 open stub.
    rf_7485 ic7(.p1(ic22_3),.p2(1'b1),.p3(1'b1),.p4(1'b1),.p9(1'b1),.p10(1'b1),.p11(ic16_6),
        .p12(ic15_2),.p13(ic15_6),.p14(ic2_11),.p15(ic15_7),.p5(ic7_5),.p6(),.p7(ic7_7));
    // IC8 (7400)
    rf_7400 ic8(.p1(f_vs8),.p2(ic7_5),.p4(ic60_4),.p5(ic7_7),.p9(f_score_st_n),.p10(ic4_5),
        .p12(ic61_1),.p13(f_tunnel_n),.p3(ic8_3),.p6(ic8_6),.p8(ic8_8),.p11(ic8_11));
    // IC9 (74153)
    rf_74153 ic9(.p1(1'b0),.p2(ic44_2),.p3(ic3_7),.p4(ic72_4),.p5(ic3_7),.p6(1'b0),
        .p10(ic69_9),.p11(ic3_9),.p12(ic66_8),.p13(ic3_9),.p14(ic16_11),.p15(1'b0),
        .p7(ic9_7),.p9(ic9_9));
    // IC10, IC11 (7485)
    rf_7485 ic10(.p1(1'b1),.p2(ic11_7),.p3(ic11_6),.p4(ic11_5),.p9(ic6_6),.p10(ic24_3),
        .p11(ic6_4),.p12(ic24_2),.p13(ic24_6),.p14(ic6_2),.p15(1'b1),
        .p5(ic10_5),.p6(),.p7(ic10_7));
    rf_7485 ic11(.p1(1'b0),.p2(1'b1),.p3(1'b1),.p4(1'b1),.p9(1'b0),.p10(ic25_3),.p11(1'b0),
        .p12(ic25_2),.p13(ic25_6),.p14(1'b0),.p15(ic25_7),.p5(ic11_5),.p6(ic11_6),.p7(ic11_7));
    // IC12 (7400, two sections on this sheet)
    rf_7400 ic12(.p1(ic69_7),.p2(ic10_7),.p4(ic60_7),.p5(ic10_5),.p9(1'b0),.p10(1'b0),
        .p12(1'b0),.p13(1'b0),.p3(ic12_3),.p6(ic12_6),.p8(),.p11());
    // IC13 (7417)
    rf_7417 ic13(.p1(ic6_12),.p3(ic15_6),.p5(ic15_2),.p9(ic15_3),.p11(ic8_8),.p13(ic16_11),
        .p2(ic13_2),.p4(ic13_4),.p6(ic13_6),.p8(ic13_8),.p10(ic13_10),.p12(ic13_12));
    // IC14 (7420)
    rf_7420 ic14(.p1(ic15_6),.p2(ic15_3),.p4(ic15_2),.p5(ic6_2),.p9(f_rescue_n),.p10(f_bridge_n),
        .p12(f_road),.p13(f_other_body_n),.p6(ic14_6),.p8(ic14_8));
    // IC15 (74193): data inputs grounded; /CO and /BO open stubs.
    rf_74193 ic15(.p15(1'b0),.p1(1'b0),.p10(1'b0),.p9(1'b0),.p4(ic8_3),.p5(ic8_6),
        .p11(ic16_11),.p14(f_game_n),.p3(ic15_3),.p2(ic15_2),.p6(ic15_6),.p7(ic15_7),
        .p12(),.p13());
    // IC16 (7486)
    rf_7486 ic16(.p1(1'b1),.p2(ic23_3),.p4(ic6_10),.p5(ic6_8),.p9(ic32_13),.p10(ic27_13),
        .p12(ic23_3),.p13(1'b1),.p3(ic16_3),.p6(ic16_6),.p8(ic16_8),.p11(ic16_11));
    // IC17, IC18 (7485): pins 5, 7 open stubs.
    rf_7485 ic17(.p1(1'b1),.p2(1'b1),.p3(ic18_6),.p4(1'b1),.p9(ic24_3),.p10(ic19_11),
        .p11(ic24_2),.p12(ic19_10),.p13(ic19_9),.p14(ic24_6),.p15(1'b1),
        .p5(),.p6(ic17_6),.p7());
    rf_7485 ic18(.p1(ic25_7),.p2(1'b1),.p3(ic63_13),.p4(1'b1),.p9(ic25_3),.p10(ic19_3),
        .p11(ic25_2),.p12(ic19_4),.p13(ic19_5),.p14(ic25_6),.p15(ic19_6),
        .p5(),.p6(ic18_6),.p7());
    // IC19 (74393), pin numbers as printed (F45): pin 6 clocks pin 13.
    rf_74393 ic19(.p1(ic63_13),.p2(c3_net),.p12(c3_net),.p13(ic19_6),
        .p3(ic19_3),.p4(ic19_4),.p5(ic19_5),.p6(ic19_6),
        .p11(ic19_11),.p10(ic19_10),.p9(ic19_9),.p8(ic19_8));
    // IC22 (7408, one section on this sheet)
    rf_7408 ic22(.p1(ic23_6),.p2(ic32_13),.p4(1'b0),.p5(1'b0),.p9(1'b0),.p10(1'b0),
        .p12(1'b0),.p13(1'b0),.p3(ic22_3),.p6(),.p8(),.p11());
    // IC23 (7432)
    rf_7432 ic23(.p1(ic33_5),.p2(ic27_7),.p4(ic6_10),.p5(ic16_6),.p9(ic46_2),.p10(ic44_2),
        .p12(ic68_6),.p13(ic27_7),.p3(ic23_3),.p6(ic23_6),.p8(ic23_8),.p11(ic23_11));
    // IC24 (74193): data inputs at Vcc, CLR grounded. Pin 7 (QD) is drawn
    // tied to Vcc; no pin on this sheet reads that net. /CO, /BO open stubs.
    rf_74193 ic24(.p15(1'b1),.p1(1'b1),.p10(1'b1),.p9(1'b1),.p4(ic25_13),.p5(ic25_12),
        .p11(f_coin_test_n),.p14(1'b0),.p3(ic24_3),.p2(ic24_2),.p6(ic24_6),.p7(nc),
        .p12(),.p13());
    // IC25 (74193): data inputs and CLR grounded.
    rf_74193 ic25(.p15(1'b0),.p1(1'b0),.p10(1'b0),.p9(1'b0),.p4(ic12_6),.p5(ic12_3),
        .p11(f_coin_test_n),.p14(1'b0),.p3(ic25_3),.p2(ic25_2),.p6(ic25_6),.p7(ic25_7),
        .p12(ic25_12),.p13(ic25_13));
    // IC27 (74279): latch 3 (pins 9-12) is not on this sheet.
    // Pin 1 is reached through one layer (cut27): the loop IC27.7 -> IC23.3
    // -> IC27.1 -> IC27.4 -> IC44.2 -> IC23.8 -> IC27.5 is cut there in the RTL.
    wire ic27_1;
    rf_layer cut27(.a(ic23_3),.y(ic27_1));
    rf_74279 ic27(.p1(ic27_1),.p2(ic28_6),.p3(f_ic27_3),.p5(ic23_8),.p6(ic34_3),
        .p10(1'bz),.p11(1'bz),.p12(1'bz),.p14(ic44_12),.p15(ic14_6),
        .p4(ic27_4),.p7(ic27_7),.p9(),.p13(ic27_13));
    // IC28 (7410, two sections on this sheet)
    rf_7410 ic28(.p1(1'b0),.p2(1'b0),.p13(1'b0),.p3(ic24_2),.p4(ic24_3),.p5(ic24_6),
        .p9(ic32_13),.p10(ic16_11),.p11(f_coin_test_n),.p12(),.p6(ic28_6),.p8(ic28_8));
    // IC29 (7417, three sections on this sheet)
    rf_7417 ic29(.p1(ic2_3),.p3(ic43_4),.p5(1'b0),.p9(ic32_13),.p11(1'b0),.p13(1'b0),
        .p2(ic29_2),.p4(ic29_4),.p6(),.p8(ic29_8),.p10(),.p12());
    // IC30 (7400): section 4, 5 -> 6 is not on this sheet.
    rf_7400 ic30(.p1(ic9_9),.p2(ic46_2),.p4(1'b0),.p5(1'b0),.p9(ic9_7),.p10(ic30_11),
        .p12(ic35_7),.p13(ic35_6),.p3(ic30_3),.p6(),.p8(ic30_8),.p11(ic30_11));
    // IC32 (74279 latch 4): /R 14 = NO line, /S 15 = NC line (through RA2;
    // the RC filters are not modelled).
    rf_74279 ic32(.p1(1'bz),.p2(1'bz),.p3(1'bz),.p5(1'bz),.p6(1'bz),.p10(1'bz),.p11(1'bz),
        .p12(1'bz),.p14(f_shift_no),.p15(f_shift_nc),.p4(),.p7(),.p9(),.p13(ic32_13));
    // IC33 (7474, first half)
    rf_7474_half ic33(.p1(ic23_11),.p2(f_extend),.p3(ic27_7),.p4(1'b1),.p5(ic33_5),.p6(ic33_6));
    // IC34 (7408)
    rf_7408 ic34(.p1(ic80_6),.p2(f_acc1_pulse_n),.p4(ic23_6),.p5(ic60_7),.p9(ic68_6),
        .p10(f_vs8),.p12(1'b0),.p13(1'b0),.p3(ic34_3),.p6(ic34_6),.p8(ic34_8),.p11());
    // IC35 (74193): data inputs and CLR grounded; /CO, /BO open stubs.
    rf_74193 ic35(.p15(1'b0),.p1(1'b0),.p10(1'b0),.p9(1'b0),.p4(ic36_13),.p5(ic36_12),
        .p11(f_coin_test_n),.p14(1'b0),.p3(ic35_3),.p2(ic35_2),.p6(ic35_6),.p7(ic35_7),
        .p12(),.p13());
    // IC36 (74193): data inputs at Vcc, CLR grounded.
    rf_74193 ic36(.p15(1'b1),.p1(1'b1),.p10(1'b1),.p9(1'b1),.p4(ic30_3),.p5(ic30_8),
        .p11(f_coin_test_n),.p14(1'b0),.p3(ic36_3),.p2(ic36_2),.p6(ic36_6),.p7(ic36_7),
        .p12(ic36_12),.p13(ic36_13));
    // IC39 (74393, first half); C16 on pin 1. MR = IC33 /Q. The RTL reads
    // IC33's stored state here instead; the two differ only in the layer in
    // which /CLR empties IC33, where nothing depends on the difference.
    rf_74393 ic39(.p1(ic34_8),.p2(ic33_6),.p12(1'b1),.p13(1'b0),
        .p3(ic39_3),.p4(ic39_4),.p5(ic39_5),.p6(ic39_6),.p8(),.p9(),.p10(),.p11());
    // IC40 (74393): pin 6 clocks pin 13; C17 on MR.
    rf_74393 ic40(.p1(f_hs_n),.p2(c17_net),.p12(c17_net),.p13(ic40_6),
        .p3(ic40_3),.p4(ic40_4),.p5(ic40_5),.p6(ic40_6),
        .p11(ic40_11),.p10(ic40_10),.p9(ic40_9),.p8(ic40_8));
    // IC41, IC42 (7485): pins 5, 7 open stubs.
    rf_7485 ic41(.p1(ic40_8),.p2(1'b1),.p3(ic42_6),.p4(1'b1),.p9(ic40_11),.p10(ic35_3),
        .p11(ic40_10),.p12(ic35_2),.p13(ic35_6),.p14(ic40_9),.p15(ic35_7),
        .p5(),.p6(ic41_6),.p7());
    rf_7485 ic42(.p1(ic40_6),.p2(1'b1),.p3(1'b1),.p4(1'b1),.p9(ic40_3),.p10(ic36_3),
        .p11(ic40_4),.p12(ic36_2),.p13(ic36_6),.p14(ic40_5),.p15(ic36_7),
        .p5(),.p6(ic42_6),.p7());
    // IC43 (74123): first half A 1 = /SLIP (pad CA), B 2 = PLAYER, /CLR 3,
    // Q 13, /Q 4, C20/R11 on pins 14, 15; second half A 9 = /POOL(2) (pad CM),
    // B 10 = PLAYER, /CLR 11, Q 5, /Q 12, C18/R10 on pins 6, 7.
    rf_74123 #(.C_PF(C43A_PF)) ic43a(.a(f_slip_n),.b(f_player),.clr_n(ic15_7),.f7(f_7mhz),
        .q(ic43_13),.q_n(ic43_4));
    rf_74123 #(.C_PF(C43B_PF)) ic43b(.a(f_pool2_n),.b(f_player),.clr_n(ic15_7),.f7(f_7mhz),
        .q(ic43_5),.q_n(ic43_12));
    // IC44 (7404, two sections), IC46 (7404, one section)
    rf_7404 ic44(.p1(ic27_4),.p3(1'b0),.p5(1'b0),.p9(1'b0),.p11(1'b0),.p13(ic28_8),
        .p2(ic44_2),.p4(),.p6(),.p8(),.p10(),.p12(ic44_12));
    rf_7404 ic46(.p1(ic47_6),.p3(1'b0),.p5(1'b0),.p9(1'b0),.p11(1'b0),.p13(1'b0),
        .p2(ic46_2),.p4(),.p6(),.p8(),.p10(),.p12());
    // IC47 (7425): the strobes (pins 3, 11) are not drawn and left open.
    rf_7425 ic47(.p1(ic35_7),.p2(ic35_6),.p3(1'bz),.p4(ic35_2),.p5(ic35_3),
        .p9(f_v5_n),.p10(f_v6_n),.p11(1'bz),.p12(f_v4),.p13(f_v7_n),.p6(ic47_6),.p8(ic47_8));
    // IC48 (7400, one section)
    rf_7400 ic48(.p1(1'b0),.p2(1'b0),.p4(1'b0),.p5(1'b0),.p9(ic43_5),.p10(ic49_5),
        .p12(1'b0),.p13(1'b0),.p3(),.p6(),.p8(ic48_8),.p11());
    // IC49 (74123, second half): A 9, B 10, /CLR 11, Q 5; C21 on pins 6, 7.
    rf_74123 #(.C_PF(C49_PF)) ic49(.a(f_pool2_n),.b(f_player),.clr_n(ic15_7),.f7(f_7mhz),
        .q(ic49_5),.q_n());
    // IC60 (74157), channels a and b
    rf_74157 ic60(.p1(ic16_8),.p2(f_vs16),.p3(f_vs64),.p5(f_vs2),.p6(f_vs8),
        .p10(1'b0),.p11(1'b0),.p13(1'b0),.p14(1'b0),.p15(1'b0),
        .p4(ic60_4),.p7(ic60_7),.p9(),.p12());
    // IC61, IC63, IC72 (7402)
    rf_7402 ic61(.p2(ic43_5),.p3(ic43_13),.p5(1'b0),.p6(1'b0),.p8(1'b0),.p9(1'b0),
        .p11(1'b0),.p12(1'b0),.p1(ic61_1),.p4(),.p10(),.p13());
    rf_7402 ic63(.p2(1'b0),.p3(1'b0),.p5(1'b0),.p6(1'b0),.p8(1'b0),.p9(1'b0),
        .p11(ic19_8),.p12(f_7mhz),.p1(),.p4(),.p10(),.p13(ic63_13));
    rf_7402 ic72(.p2(1'b0),.p3(1'b0),.p5(ic69_9),.p6(f_vs32),.p8(1'b0),.p9(1'b0),
        .p11(ic23_3),.p12(f_sp_down),.p1(),.p4(ic72_4),.p10(),.p13(ic72_13));
    // IC62 (7432, one section)
    rf_7432 ic62(.p1(f_8000),.p2(f_ext500_n),.p4(1'b0),.p5(1'b0),.p9(1'b0),.p10(1'b0),
        .p12(1'b0),.p13(1'b0),.p3(ic62_3),.p6(),.p8(),.p11());
    // IC66 (7408, one section)
    rf_7408 ic66(.p1(1'b0),.p2(1'b0),.p4(1'b0),.p5(1'b0),.p9(ic69_9),.p10(f_vs32),
        .p12(1'b0),.p13(1'b0),.p3(),.p6(),.p8(ic66_8),.p11());
    // IC67 (7450)
    rf_7450 ic67(.p1(f_v6),.p13(ic73_8),.p9(f_v7),.p10(ic72_13),
        .p2(f_v6),.p3(ic8_11),.p4(f_v7),.p5(ic73_6),.p8(ic67_8),.p6(ic67_6));
    // IC68 (7400, two sections)
    rf_7400 ic68(.p1(1'b0),.p2(1'b0),.p4(ic39_5),.p5(ic39_6),.p9(1'b0),.p10(1'b0),
        .p12(f_h4),.p13(f_h6),.p3(),.p6(ic68_6),.p8(),.p11(ic68_11));
    // IC69 (74153)
    rf_74153 ic69(.p1(1'b0),.p2(ic33_5),.p3(f_v5_n),.p4(1'b0),.p5(ic67_8),.p6(ic67_8),
        .p10(f_v6_n),.p11(f_v6_n),.p12(1'b0),.p13(f_v5_n),.p14(ic39_6),.p15(1'b0),
        .p7(ic69_7),.p9(ic69_9));
    // IC73 (7404, two sections)
    rf_7404 ic73(.p1(1'b0),.p3(1'b0),.p5(ic8_11),.p9(ic72_13),.p11(1'b0),.p13(1'b0),
        .p2(),.p4(),.p6(ic73_6),.p8(ic73_8),.p10(),.p12());
    // IC74 (7427, one section); C3 on its output.
    rf_7427 ic74(.p1(f_h5),.p2(ic68_11),.p13(f_h8),.p3(1'b0),.p4(1'b0),.p5(1'b0),
        .p9(1'b0),.p10(1'b0),.p11(1'b0),.p12(ic74_12),.p6(),.p8());
    // IC80 (7410, two sections)
    rf_7410 ic80(.p1(ic6_2),.p2(ic62_3),.p13(f_ext_car_cont),.p3(f_acc1_st_n),.p4(ic14_8),
        .p5(f_player),.p9(1'b0),.p10(1'b0),.p11(1'b0),.p12(ic80_12),.p6(ic80_6),.p8());

    // Sheet-edge outputs
    assign pl_h_st = ic17_6;
    assign pl_v_st = ic41_6;
    assign shift = ic29_8;
    assign slipzone_n = ic29_4;
    assign nonroad_slip_n = ic29_2;
    assign acce_st = ic34_6;
    assign acce = {ic6_12, ic15_6, ic15_2, ic15_3};
    assign s_acce = {ic13_2, ic13_4, ic13_6, ic13_8};
    assign score_cp_n = ic13_10;
    assign s_acc1_n = ic13_12;
    assign acc1_n = ic16_3;
    assign splay_a_n = ic48_8;
    assign splay_b_n = ic49_5;
    assign sp_irreg_n = ic80_12;
    assign home_pos_n = ic23_8;
    assign explo_sel = {ic39_6, ic39_5, ic39_4, ic39_3};
    assign explo_st = ic33_5;
    assign explo_st_n = ic33_6;
    // Observation, by net
    assign ic19_q = {ic19_8, ic19_9, ic19_10, ic19_11, ic19_6, ic19_5, ic19_4, ic19_3};
    assign ic40_q = {ic40_8, ic40_9, ic40_10, ic40_11, ic40_6, ic40_5, ic40_4, ic40_3};
    assign hpos_t = {ic24_6, ic24_2, ic24_3, ic25_7, ic25_6, ic25_2, ic25_3};
    assign vpos_t = {ic35_7, ic35_6, ic35_2, ic35_3, ic36_7, ic36_6, ic36_2, ic36_3};
    assign state = {ic15_7, ic15_6, ic15_2, ic15_3, ic24_6, ic24_2, ic24_3,
                    ic25_7, ic25_6, ic25_2, ic25_3, vpos_t,
                    ic5_6, ic5_5, ic5_4, ic5_3, ic39_6, ic39_5, ic39_4, ic39_3,
                    ic33_5, ic27_4, ic27_7, ic27_13, ic32_13,
                    ic1_13, ic1_5, ic43_13, ic43_5, ic49_5};
endmodule
