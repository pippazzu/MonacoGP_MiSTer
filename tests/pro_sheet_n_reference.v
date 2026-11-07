// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected, event-driven reference for Pro Monaco GP sheet
// N, the bonus circuit (manual 420-0525, PDF page 12, board 96822-P). Each
// package is modelled from its data sheet pin functions and wired by IC and
// pin number from pro/docs/trace/SHEET_N_TRACE.md (second pass). Self-
// contained: the rn_ models below are written for this file and share no
// code with cores/monacogp/hdl/jtmonacogp_bonus.v.
//
// Timing rule ("settled layers", the rule of tests/sheet_f_reference.v). The
// delays are NOT TTL delays; they make the circuit settle in layers, the rule
// that the RTL implements step by step:
// - Gates and multiplexers take 0.01 ns; the asynchronous clears and loads
//   act 0.02 ns after their input.
// - Every clock and trigger input goes through a 3 ns inertial filter
//   (rn_filt): a pulse shorter than that is a hazard of the path delays, is
//   absorbed and counted. A change that lasts a layer passes.
// - The edge-triggered parts act 1 ns after the filtered edge and do not act
//   if their asynchronous clear (load) is then active.
// - The 74123 widths are counted in 7 MHz periods: at each rising f7 the
//   pulse loses a period and ends 5 ns later, when the testbench changes the
//   other sheets' nets too.
// Readings: IC132 pin 9 (/LOAD) is not drawn and is left floating (a TTL
// input reads it high). IR, IP and GPR are the trace's aliases for packages
// whose labels are uncertain. The open-collector 7417 outputs read high when
// off: R27 is drawn for M5; M1-M4's pull-ups are not on N.
// DU_LAG: layers (rn_layer) inserted between /GAME and IC140 pin 5, standing
// for R34; 0 as drawn. See the RTL header for what each setting does.
`timescale 1ns/1ps

`ifndef TTL
`define TTL(x) ((x) === 1'bz ? 1'b1 : (x))
`endif
`define RN_G  0.01      // gate
`define RN_L  0.02      // asynchronous clear or load
`define RN_W  3.0       // clock and trigger filter
`define RN_CQ 1.0       // filtered edge to action
`define RN_T  5.0       // 74123 end, after the f7 edge

module rn_filt(input a, output y);
    assign #(`RN_W) y = `TTL(a);
    integer hazards = 0;
    realtime t = -1.0e9;
    always @(a) begin
        if ($realtime > 1000.0 && $realtime - t < `RN_W) hazards = hazards + 1;
        t = $realtime;
    end
endmodule
// One layer of delay (filter and action time of an edge-triggered part)
module rn_layer(input a, output y);
    wire f;
    rn_filt u(.a(a),.y(f));
    assign #(`RN_CQ) y = f;
endmodule

module rn_7400(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RN_G) p3 =~(`TTL(p1)&`TTL(p2));
    assign #(`RN_G) p6 =~(`TTL(p4)&`TTL(p5));
    assign #(`RN_G) p8 =~(`TTL(p9)&`TTL(p10));
    assign #(`RN_G) p11=~(`TTL(p12)&`TTL(p13));
endmodule
module rn_7402(input p2,p3,p5,p6,p8,p9,p11,p12, output p1,p4,p10,p13);
    assign #(`RN_G) p1 =~(`TTL(p2)|`TTL(p3));
    assign #(`RN_G) p4 =~(`TTL(p5)|`TTL(p6));
    assign #(`RN_G) p10=~(`TTL(p8)|`TTL(p9));
    assign #(`RN_G) p13=~(`TTL(p11)|`TTL(p12));
endmodule
module rn_7404(input p1,p3,p5,p9,p11,p13, output p2,p4,p6,p8,p10,p12);
    assign #(`RN_G) p2 =~`TTL(p1);
    assign #(`RN_G) p4 =~`TTL(p3);
    assign #(`RN_G) p6 =~`TTL(p5);
    assign #(`RN_G) p8 =~`TTL(p9);
    assign #(`RN_G) p10=~`TTL(p11);
    assign #(`RN_G) p12=~`TTL(p13);
endmodule
module rn_7408(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RN_G) p3 =`TTL(p1)&`TTL(p2);
    assign #(`RN_G) p6 =`TTL(p4)&`TTL(p5);
    assign #(`RN_G) p8 =`TTL(p9)&`TTL(p10);
    assign #(`RN_G) p11=`TTL(p12)&`TTL(p13);
endmodule
module rn_7410(input p1,p2,p13,p3,p4,p5,p9,p10,p11, output p12,p6,p8);
    assign #(`RN_G) p12=~(`TTL(p1)&`TTL(p2)&`TTL(p13));
    assign #(`RN_G) p6 =~(`TTL(p3)&`TTL(p4)&`TTL(p5));
    assign #(`RN_G) p8 =~(`TTL(p9)&`TTL(p10)&`TTL(p11));
endmodule
module rn_7411(input p1,p2,p13,p3,p4,p5,p9,p10,p11, output p12,p6,p8);
    assign #(`RN_G) p12=`TTL(p1)&`TTL(p2)&`TTL(p13);
    assign #(`RN_G) p6 =`TTL(p3)&`TTL(p4)&`TTL(p5);
    assign #(`RN_G) p8 =`TTL(p9)&`TTL(p10)&`TTL(p11);
endmodule
// 7417 hex buffers, open collector: low or off (z).
module rn_7417(input p1,p3,p5,p9,p11,p13, output p2,p4,p6,p8,p10,p12);
    assign #(`RN_G) p2 = `TTL(p1)  ? 1'bz : 1'b0;
    assign #(`RN_G) p4 = `TTL(p3)  ? 1'bz : 1'b0;
    assign #(`RN_G) p6 = `TTL(p5)  ? 1'bz : 1'b0;
    assign #(`RN_G) p8 = `TTL(p9)  ? 1'bz : 1'b0;
    assign #(`RN_G) p10= `TTL(p11) ? 1'bz : 1'b0;
    assign #(`RN_G) p12= `TTL(p13) ? 1'bz : 1'b0;
endmodule
module rn_7420(input p1,p2,p4,p5,p9,p10,p12,p13, output p6,p8);
    assign #(`RN_G) p6 =~(`TTL(p1)&`TTL(p2)&`TTL(p4)&`TTL(p5));
    assign #(`RN_G) p8 =~(`TTL(p9)&`TTL(p10)&`TTL(p12)&`TTL(p13));
endmodule
module rn_7432(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #(`RN_G) p3 =`TTL(p1)|`TTL(p2);
    assign #(`RN_G) p6 =`TTL(p4)|`TTL(p5);
    assign #(`RN_G) p8 =`TTL(p9)|`TTL(p10);
    assign #(`RN_G) p11=`TTL(p12)|`TTL(p13);
endmodule
// 74157 quad 2-to-1 multiplexer: select 1, /G 15; 1A 2, 1B 3, 1Y 4; 2A 5,
// 2B 6, 2Y 7; 3A 11, 3B 10, 3Y 9; 4A 14, 4B 13, 4Y 12. Y = B while select is
// high, A while it is low, low while /G is high.
module rn_74157(input p1,p15,p2,p3,p5,p6,p11,p10,p14,p13, output p4,p7,p9,p12);
    wire s = `TTL(p1), g = `TTL(p15);
    assign #(`RN_G) p4  = !g & (s ? `TTL(p3)  : `TTL(p2));
    assign #(`RN_G) p7  = !g & (s ? `TTL(p6)  : `TTL(p5));
    assign #(`RN_G) p9  = !g & (s ? `TTL(p10) : `TTL(p11));
    assign #(`RN_G) p12 = !g & (s ? `TTL(p13) : `TTL(p14));
endmodule

// One 7474 D flip-flop: /CLR, D, CK, /PR, Q, /Q. Rising clock; D is sampled
// at the filtered edge and taken 1 ns later if /CLR and /PR are then high.
// Both /PR and /CLR low drive both outputs high.
module rn_7474_ff(input clr_in, d_in, ck_in, pr_in, output reg q = 0, output q_n);
    wire clr_n = `TTL(clr_in), pr_n = `TTL(pr_in);
    wire ck;
    rn_filt fck(.a(ck_in),.y(ck));
    reg ck_l = 1'bx, dd;
    assign q_n = (!clr_n && !pr_n) ? 1'b1 : ~q;
    always @(clr_n or pr_n)
        if (!clr_n) q <= #(`RN_L) 0;
        else if (!pr_n) q <= #(`RN_L) 1;
    always @(ck) begin
        if (ck_l === 1'b0 && ck === 1'b1) begin
            dd = `TTL(d_in);
            #(`RN_CQ) if (clr_n && pr_n) q <= dd;
        end
        ck_l = ck;
    end
endmodule
// 7474: 1/CLR 1, 1D 2, 1CK 3, 1/PR 4, 1Q 5, 1/Q 6; 2/CLR 13, 2D 12, 2CK 11,
// 2/PR 10, 2Q 9, 2/Q 8.
module rn_7474(input p1,p2,p3,p4,p13,p12,p11,p10, output p5,p6,p9,p8);
    rn_7474_ff u1(.clr_in(p1),.d_in(p2),.ck_in(p3),.pr_in(p4),.q(p5),.q_n(p6));
    rn_7474_ff u2(.clr_in(p13),.d_in(p12),.ck_in(p11),.pr_in(p10),.q(p9),.q_n(p8));
endmodule
// One 74107 J-K flip-flop: J, K, CK (acts on the falling edge, as the data
// sheet's output transition; the standard part is master-slave, the LS107A
// edge-triggered), /CLR asynchronous.
module rn_74107_ff(input j_in, k_in, ck_in, clr_in, output reg q = 0, output q_n);
    wire clr_n = `TTL(clr_in);
    wire ck;
    rn_filt fck(.a(ck_in),.y(ck));
    reg ck_l = 1'bx, jj, kk;
    assign q_n = ~q;
    always @(clr_n) if (!clr_n) q <= #(`RN_L) 0;
    always @(ck) begin
        if (ck_l === 1'b1 && ck === 1'b0) begin
            jj = `TTL(j_in); kk = `TTL(k_in);
            #(`RN_CQ) if (clr_n) q <= (jj && kk) ? ~q : jj ? 1'b1 : kk ? 1'b0 : q;
        end
        ck_l = ck;
    end
endmodule
// 74107: 1J 1, 1/Q 2, 1Q 3, 1K 4, 1CK 12, 1/CLR 13; 2J 8, 2CK 9, 2/CLR 10,
// 2K 11, 2Q 5, 2/Q 6.
module rn_74107(input p1,p4,p12,p13,p8,p11,p9,p10, output p3,p2,p5,p6);
    rn_74107_ff u1(.j_in(p1),.k_in(p4),.ck_in(p12),.clr_in(p13),.q(p3),.q_n(p2));
    rn_74107_ff u2(.j_in(p8),.k_in(p11),.ck_in(p9),.clr_in(p10),.q(p5),.q_n(p6));
endmodule
// One 74390 section: a divide-by-2 stage (CKA -> QA) and a divide-by-5
// stage (CKB -> QB, QC, QD counting 0-4 in binary), both on falling edges,
// CLR (high) asynchronous for both. The stages are joined only by the
// board's wiring.
module rn_390_section(input cka_in, ckb_in, clr_in, output reg qa = 0, output qb, qc, qd);
    wire clr = `TTL(clr_in);
    wire cka, ckb;
    rn_filt fa(.a(cka_in),.y(cka));
    rn_filt fb(.a(ckb_in),.y(ckb));
    reg [2:0] q5 = 0;
    reg cka_l = 1'bx, ckb_l = 1'bx;
    assign {qd, qc, qb} = q5;
    always @(clr) if (clr) begin qa <= #(`RN_L) 0; q5 <= #(`RN_L) 0; end
    always @(cka) begin
        if (cka_l === 1'b1 && cka === 1'b0) #(`RN_CQ) if (!clr) qa <= ~qa;
        cka_l = cka;
    end
    always @(ckb) begin
        if (ckb_l === 1'b1 && ckb === 1'b0) #(`RN_CQ) if (!clr) q5 <= q5 == 3'd4 ? 3'd0 : q5 + 3'd1;
        ckb_l = ckb;
    end
endmodule
// 74390: 1CKA 1, 1CLR 2, 1QA 3, 1CKB 4, 1QB 5, 1QC 6, 1QD 7; 2QD 9, 2QC 10,
// 2QB 11, 2CKB 12, 2QA 13, 2CLR 14, 2CKA 15.
module rn_74390(input p1,p2,p4,p15,p14,p12, output p3,p5,p6,p7,p13,p11,p10,p9);
    rn_390_section u1(.cka_in(p1),.ckb_in(p4),.clr_in(p2),.qa(p3),.qb(p5),.qc(p6),.qd(p7));
    rn_390_section u2(.cka_in(p15),.ckb_in(p12),.clr_in(p14),.qa(p13),.qb(p11),.qc(p10),.qd(p9));
endmodule
// 74161 synchronous 4-bit counter: /CLR 1 (asynchronous), CLK 2 (rising),
// A-D 3-6, ENP 7, /LOAD 9, ENT 10, QD 11, QC 12, QB 13, QA 14, RCO 15.
module rn_74161(input p1,p2,p3,p4,p5,p6,p7,p9,p10, output p14,p13,p12,p11,p15);
    wire clr_n = `TTL(p1);
    wire ck;
    rn_filt fck(.a(p2),.y(ck));
    reg [3:0] q = 0, dd;
    reg ck_l = 1'bx, ld, en;
    always @(clr_n) if (!clr_n) q <= #(`RN_L) 0;
    always @(ck) begin
        if (ck_l === 1'b0 && ck === 1'b1) begin
            ld = !`TTL(p9);
            en = `TTL(p7) & `TTL(p10);
            dd = {`TTL(p6),`TTL(p5),`TTL(p4),`TTL(p3)};
            #(`RN_CQ) if (clr_n) begin
                if (ld) q <= dd;
                else if (en) q <= q + 4'd1;
            end
        end
        ck_l = ck;
    end
    assign {p11,p12,p13,p14} = q;
    assign #(`RN_G) p15 = `TTL(p10) & (q == 4'd15);
endmodule
// 74191 synchronous up/down counter: B 1, QB 2, QA 3, /CTEN 4, D/U 5 (low
// up, high down), QC 6, QD 7, D 9, C 10, /LOAD 11 (asynchronous), MAX/MIN 12,
// /RCO 13, CLK 14 (rising), A 15. MAX/MIN is high at 15 counting up and at 0
// counting down; /RCO is low while MAX/MIN is high, /CTEN low and CLK low.
module rn_74191(input p15,p1,p10,p9,p4,p5,p11,p14, output p3,p2,p6,p7,p12,p13);
    wire ld_n = `TTL(p11);
    wire [3:0] d = {`TTL(p9),`TTL(p10),`TTL(p1),`TTL(p15)};
    wire ck;
    rn_filt fck(.a(p14),.y(ck));
    reg [3:0] q = 0;
    reg ck_l = 1'bx, dn, en;
    always @(ld_n or d) if (!ld_n) q <= #(`RN_L) d;
    always @(ck) begin
        if (ck_l === 1'b0 && ck === 1'b1) begin
            dn = `TTL(p5);
            en = !`TTL(p4);
            #(`RN_CQ) if (ld_n && en) q <= dn ? q - 4'd1 : q + 4'd1;
        end
        ck_l = ck;
    end
    assign {p7,p6,p2,p3} = q;
    assign #(`RN_G) p12 = `TTL(p5) ? (q == 4'd0) : (q == 4'd15);
    assign #(`RN_G) p13 = ~(p12 & !`TTL(p4) & !`TTL(p14));
endmodule
// One half of a 74123 retriggerable monostable: A (active low), B, /CLR, Q,
// /Q. Triggers: A falling while B is high, B rising while A is low, /CLR
// rising while A is low and B high; the filtered inputs are evaluated
// together 0.5 ns after the first of them changes, and Q rises 0.5 ns later,
// one layer after the change. A low /CLR ends the pulse at once and holds Q
// low. The width tw = 0.28*R*C*(1+0.7/R) ns of the data sheet (R in kohm, C
// in pF) is counted in 7 MHz periods.
module rn_123_half #(parameter real R_KOHM = 47.0, parameter real C_PF = 1.0e6)(
    input a_in, b_in, clr_in, f7, output reg q = 0, output q_n
);
    localparam real TW = 0.28*R_KOHM*C_PF*(1.0+0.7/R_KOHM);
    integer pixels, left = 0, trigs = 0;
    initial pixels = $rtoi(TW*7.1525e-3 + 0.5);
    wire clr_n = `TTL(clr_in);
    wire ta, tb, tc;
    rn_filt fa(.a(a_in),.y(ta));
    rn_filt fb(.a(b_in),.y(tb));
    rn_filt fc(.a(clr_in),.y(tc));
    reg ta_l = 1'bx, tb_l = 1'bx, tc_l = 1'bx, trig;
    assign q_n = ~q;
    always @(clr_n) if (!clr_n) begin
        left = 0;
        q <= #(`RN_L) 0;
    end
    always @(ta or tb or tc) begin
        #0.5;
        trig = (ta_l === 1'b1 && ta === 1'b0 && tb === 1'b1) ||
               (tb_l === 1'b0 && tb === 1'b1 && ta === 1'b0) ||
               (tc_l === 1'b0 && tc === 1'b1 && ta === 1'b0 && tb === 1'b1);
        if (trig && clr_n) begin
            trigs = trigs + 1;
            left = pixels;
            q <= #0.5 1;
        end
        ta_l = ta; tb_l = tb; tc_l = tc;
    end
    always @(posedge f7) if (left > 0) begin
        left = left - 1;
        if (left == 0) q <= #(`RN_T) 0;
    end
endmodule
// 74123: 1A 1, 1B 2, 1/CLR 3, 1/Q 4, 1Q 13, timing 14/15 (R1, C1);
// 2A 9, 2B 10, 2/CLR 11, 2/Q 12, 2Q 5, timing 6/7 (R2, C2).
module rn_74123 #(parameter real R1_KOHM = 47.0, C1_PF = 1.0e6,
                  parameter real R2_KOHM = 47.0, C2_PF = 1.0e6)(
    input p1,p2,p3,p9,p10,p11,f7, output p13,p4,p5,p12
);
    rn_123_half #(.R_KOHM(R1_KOHM),.C_PF(C1_PF)) u1(.a_in(p1),.b_in(p2),.clr_in(p3),.f7(f7),.q(p13),.q_n(p4));
    rn_123_half #(.R_KOHM(R2_KOHM),.C_PF(C2_PF)) u2(.a_in(p9),.b_in(p10),.clr_in(p11),.f7(f7),.q(p5),.q_n(p12));
endmodule

module pro_sheet_n_reference #(
    // One-shot capacitors in pF, as read: C39 3.3 uF, C33 1 uF, C41 22 uF,
    // C40 3.3 uF; all timing resistors 47k (R20, R22, R24, R23).
    parameter real C39_PF = 3.3e6, C33_PF = 1.0e6, C41_PF = 2.2e7, C40_PF = 3.3e6,
    parameter integer DU_LAG = 0
)(
    input        f7,
    // Sheet-edge inputs, named as drawn
    input        n_v2, n_v4, n_v5, n_coin_test_n, n_ini_reset_n, n_bridge_ap_n,
    input        n_player_st, n_other_car_n, n_game, n_game_n, n_score_st_n,
    input        n_pr38_7, n_pr38_9, n_acc1_n,
    // Outputs, as the RTL's
    output       bonus_sound, bonus_point_n, game_end_n,
    output [3:0] bonus,
    output       bonus_cp, bonus_cp_n,
    output [23:0] dbg
);
    wire vcc = 1'b1, gnd = 1'b0, nc = 1'bz;

    // ------------------------------------------------------------ reset
    wire w01, n95_8, n95_3, n95_11, n94_8;
    rn_7400 ic95(.p5(n_coin_test_n),.p4(n_ini_reset_n),.p6(w01),
                 .p10(n94_8),.p9(n_game_n),.p8(n95_8),
                 .p1(nc),.p2(nc),.p3(n95_3),.p12(nc),.p13(nc),.p11(n95_11));
    // IR: inverter 9 -> 8 (package label uncertain, IC88?)
    wire w02, ir_2, ir_4, ir_6, ir_10, ir_12;
    rn_7404 ir(.p9(w01),.p8(w02),
               .p1(nc),.p2(ir_2),.p3(nc),.p4(ir_4),.p5(nc),.p6(ir_6),.p11(nc),.p10(ir_10),.p13(nc),.p12(ir_12));

    // ------------------------------------------------------------ bonus store
    wire n140_12, n102_10, n102_1, n102_4, n102_13;
    rn_7402 ic102(.p9(w01),.p8(n140_12),.p10(n102_10),
                  .p2(nc),.p3(nc),.p1(n102_1),.p5(nc),.p6(nc),.p4(n102_4),.p11(nc),.p12(nc),.p13(n102_13));
    wire n94_9, n94_5, n94_6;
    rn_7474 ic94(.p13(n102_10),.p12(vcc),.p11(n_game_n),.p10(vcc),.p9(n94_9),.p8(n94_8),
                 .p1(nc),.p2(nc),.p3(nc),.p4(nc),.p5(n94_5),.p6(n94_6));
    wire n101_11, n101_8, n101_6, n101_3, n132_15, n100_13, n100_5;
    rn_7408 ic101(.p12(n_v5),.p13(n94_9),.p11(n101_11),
                  .p10(n132_15),.p9(n100_13),.p8(n101_8),
                  .p4(n100_5),.p5(n_player_st),.p6(n101_6),
                  .p1(nc),.p2(nc),.p3(n101_3));
    // IP: inverter 11 -> 10 (package label uncertain, IC88?)
    wire ip_2, ip_4, ip_6, ip_8, ip_12;
    rn_7404 ip(.p11(n101_11),.p10(bonus_point_n),
               .p1(nc),.p2(ip_2),.p3(nc),.p4(ip_4),.p5(nc),.p6(ip_6),.p9(nc),.p8(ip_8),.p13(nc),.p12(ip_12));
    // R34: /GAME -> 140.5 (C55 on the /GAME side); DU_LAG layers stand for
    // the unsettled order of U5.
    wire [2:0] du;
    assign du[0] = n_game_n;
    genvar gl;
    generate for (gl = 0; gl < 2; gl = gl + 1) begin : r34
        rn_layer lay(.a(du[gl]),.y(du[gl+1]));
    end endgenerate
    wire n140_5 = du[DU_LAG];
    wire n108_3, n140_3, n140_2, n140_6, n140_7, n140_13;
    rn_74191 ic140(.p15(gnd),.p1(gnd),.p10(gnd),.p9(gnd),.p4(gnd),.p5(n140_5),.p11(w02),.p14(n108_3),
                   .p3(n140_3),.p2(n140_2),.p6(n140_6),.p7(n140_7),.p12(n140_12),.p13(n140_13));

    // ------------------------------------------------------------ divider
    wire n81_3, n81_2, n81_5, n81_6;
    rn_74107 ic81(.p1(vcc),.p4(vcc),.p12(n101_11),.p13(w02),.p3(n81_3),.p2(n81_2),
                  .p8(nc),.p11(nc),.p9(nc),.p10(nc),.p5(n81_5),.p6(n81_6));
    wire n80_3, n80_5, n80_6, n80_7, n80_13, n80_11, n80_10, n80_9;
    rn_74390 ic80(.p1(n81_3),.p2(w01),.p4(n80_3),.p15(n80_7),.p14(w01),.p12(n80_13),
                  .p3(n80_3),.p5(n80_5),.p6(n80_6),.p7(n80_7),.p13(n80_13),.p11(n80_11),.p10(n80_10),.p9(n80_9));
    wire n107_5, n72_1, n72_4, n72_10, n72_13;
    rn_7402 ic72(.p2(n80_9),.p3(n107_5),.p1(n72_1),
                 .p5(nc),.p6(nc),.p4(n72_4),.p8(nc),.p9(nc),.p10(n72_10),.p11(nc),.p12(nc),.p13(n72_13));
    wire n108_6, n108_8, n108_11;
    rn_7432 ic108(.p1(n140_12),.p2(n72_1),.p3(n108_3),
                  .p5(n101_8),.p4(n101_6),.p6(n108_6),
                  .p9(nc),.p10(nc),.p8(n108_8),.p12(nc),.p13(nc),.p11(n108_11));

    // ------------------------------------------------------------ car counter
    // GPR: two-input NAND 10, 9 -> 8 (package label uncertain, 113?)
    wire gpr_8, gpr_3, gpr_6, gpr_11;
    rn_7400 gpr(.p10(n_pr38_7),.p9(n_pr38_9),.p8(gpr_8),
                .p1(nc),.p2(nc),.p3(gpr_3),.p4(nc),.p5(nc),.p6(gpr_6),.p12(nc),.p13(nc),.p11(gpr_11));
    wire n100_4, n100_12;
    rn_74123 #(.R1_KOHM(47.0),.C1_PF(C39_PF),.R2_KOHM(47.0),.C2_PF(C33_PF)) ic100(
        .p1(n_other_car_n),.p2(n_player_st),.p3(n_score_st_n),.p13(n100_13),.p4(n100_4),
        .p9(n_bridge_ap_n),.p10(n_player_st),.p11(gpr_8),.p5(n100_5),.p12(n100_12),.f7(f7));
    wire n143_8, n143_12, n143_6;
    rn_7410 ic143(.p9(n_pr38_7),.p10(n_pr38_9),.p11(n100_13),.p8(n143_8),
                  .p13(n143_8),.p2(n_acc1_n),.p1(n_acc1_n),.p12(n143_12),
                  .p3(n143_12),.p4(n143_12),.p5(n143_12),.p6(n143_6));
    wire n53_8, n53_12, n53_6;
    rn_7411 ic53(.p9(n143_6),.p10(n_game),.p11(w02),.p8(n53_8),
                 .p1(nc),.p2(nc),.p13(nc),.p12(n53_12),.p3(nc),.p4(nc),.p5(nc),.p6(n53_6));
    wire n132_14, n132_13, n132_12, n132_11;
    rn_74161 ic132(.p1(n53_8),.p2(n100_4),.p3(gnd),.p4(gnd),.p5(gnd),.p6(gnd),
                   .p7(n100_12),.p9(nc),.p10(n100_12),
                   .p14(n132_14),.p13(n132_13),.p12(n132_12),.p11(n132_11),.p15(n132_15));

    // ------------------------------------------------------------ bonus pulse
    wire n107_12, n107_13, n107_4;
    rn_74123 #(.R1_KOHM(47.0),.C1_PF(C41_PF),.R2_KOHM(47.0),.C2_PF(C40_PF)) ic107(
        .p1(gnd),.p2(n108_3),.p3(vcc),.p13(n107_13),.p4(n107_4),
        .p9(n_other_car_n),.p10(n108_6),.p11(n_score_st_n),.p5(n107_5),.p12(n107_12),.f7(f7));
    assign bonus_cp = n107_13;
    assign bonus_cp_n = n107_4;

    // ------------------------------------------------------------ outputs
    wire n133_4, n133_7, n133_9, n133_12;
    rn_74157 ic133(.p1(n_v2),.p15(gnd),.p2(n132_14),.p3(n140_3),.p5(n132_13),.p6(n140_2),
                   .p11(n132_12),.p10(n140_6),.p14(n132_11),.p13(n140_7),
                   .p4(n133_4),.p7(n133_7),.p9(n133_9),.p12(n133_12));
    wire m1, m2, m3, m4, m5, n126_12;
    rn_7417 ic126(.p9(n133_4),.p8(m1),.p11(n133_7),.p10(m2),.p5(n133_9),.p6(m3),
                  .p3(n133_12),.p4(m4),.p1(n95_8),.p2(m5),.p13(nc),.p12(n126_12));
    pullup r27(m5);
    assign game_end_n = `TTL(m5);
    assign bonus = {`TTL(m4), `TTL(m3), `TTL(m2), `TTL(m1)};
    wire n21_8, n21_6;
    rn_7420 ic21(.p9(n100_13),.p12(n132_12),.p10(n132_11),.p13(n_v2),.p8(n21_8),
                 .p1(nc),.p2(nc),.p4(nc),.p5(nc),.p6(n21_6));
    wire n113_3, n113_6, n113_8;
    rn_7400 ic113(.p2(n_v4),.p1(n107_13),.p3(n113_3),
                  .p12(n113_3),.p13(n21_8),.p11(bonus_sound),
                  .p4(nc),.p5(nc),.p6(n113_6),.p9(nc),.p10(nc),.p8(n113_8));

    // Internal state, in the RTL's order
    assign dbg = {n81_3, n80_7, n80_6, n80_5, n80_3, n80_9, n80_10, n80_11, n80_13,
                  n132_11, n132_12, n132_13, n132_14, n140_7, n140_6, n140_2, n140_3,
                  n94_9, n100_13, n100_5, n107_13, n107_5, n140_12, w01};
endmodule
