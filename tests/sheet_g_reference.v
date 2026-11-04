// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected, event-driven reference for the sheet G player-car
// path (manual 420-0358, PDF page 27). Each package is modelled from its data
// sheet pin functions and wired by IC and pin number from the trace in
// docs/trace/SHEET_G_PLAYER.md. Counters ripple stage by stage.
// Delays only enforce settling order; they are NOT measured TTL delays.
`timescale 1ns/1ps

// TTL input: an open (high-impedance) input reads high.
`define TTL(x) ((x) === 1'bz ? 1'b1 : (x))

module ref_7400(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #2 p3 =~(`TTL(p1)&`TTL(p2));
    assign #2 p6 =~(`TTL(p4)&`TTL(p5));
    assign #2 p8 =~(`TTL(p9)&`TTL(p10));
    assign #2 p11=~(`TTL(p12)&`TTL(p13));
endmodule
module ref_7402(input p2,p3,p5,p6,p8,p9,p11,p12, output p1,p4,p10,p13);
    assign #2 p1 =~(`TTL(p2)|`TTL(p3));
    assign #2 p4 =~(`TTL(p5)|`TTL(p6));
    assign #2 p10=~(`TTL(p8)|`TTL(p9));
    assign #2 p13=~(`TTL(p11)|`TTL(p12));
endmodule
module ref_7404(input p1,p3,p5,p9,p11,p13, output p2,p4,p6,p8,p10,p12);
    assign #2 p2 =~`TTL(p1);
    assign #2 p4 =~`TTL(p3);
    assign #2 p6 =~`TTL(p5);
    assign #2 p8 =~`TTL(p9);
    assign #2 p10=~`TTL(p11);
    assign #2 p12=~`TTL(p13);
endmodule
module ref_7408(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #2 p3 =`TTL(p1)&`TTL(p2);
    assign #2 p6 =`TTL(p4)&`TTL(p5);
    assign #2 p8 =`TTL(p9)&`TTL(p10);
    assign #2 p11=`TTL(p12)&`TTL(p13);
endmodule
module ref_7410(input p1,p2,p13,p3,p4,p5,p9,p10,p11, output p12,p6,p8);
    assign #2 p12=~(`TTL(p1)&`TTL(p2)&`TTL(p13));
    assign #2 p6 =~(`TTL(p3)&`TTL(p4)&`TTL(p5));
    assign #2 p8 =~(`TTL(p9)&`TTL(p10)&`TTL(p11));
endmodule
// Dual 4-input NOR with strobe: Y = /(G & (A+B+C+D)).
module ref_7425(input p1,p2,p3,p4,p5,p9,p10,p11,p12,p13, output p6,p8);
    assign #2 p6=~(`TTL(p3)&(`TTL(p1)|`TTL(p2)|`TTL(p4)|`TTL(p5)));
    assign #2 p8=~(`TTL(p11)&(`TTL(p9)|`TTL(p10)|`TTL(p12)|`TTL(p13)));
endmodule
module ref_7432(input p1,p2,p4,p5,p9,p10,p12,p13, output p3,p6,p8,p11);
    assign #2 p3 =`TTL(p1)|`TTL(p2);
    assign #2 p6 =`TTL(p4)|`TTL(p5);
    assign #2 p8 =`TTL(p9)|`TTL(p10);
    assign #2 p11=`TTL(p12)|`TTL(p13);
endmodule
// Quad /S-/R latch. Both inputs low drives Q high.
module ref_74279(input p1,p2,p3,p5,p6,p10,p11,p12,p14,p15,
                 output reg p4=0, output reg p7=0, output reg p9=0, output reg p13=0);
    always @* begin
        if (!`TTL(p2) || !`TTL(p3)) p4 <= #3 1; else if (!`TTL(p1)) p4 <= #3 0;
        if (!`TTL(p6)) p7 <= #3 1; else if (!`TTL(p5)) p7 <= #3 0;
        if (!`TTL(p11) || !`TTL(p12)) p9 <= #3 1; else if (!`TTL(p10)) p9 <= #3 0;
        if (!`TTL(p15)) p13 <= #3 1; else if (!`TTL(p14)) p13 <= #3 0;
    end
endmodule
// One 74393 counter: each stage toggles on the falling edge of the previous
// one; the clear is asynchronous and active high.
module ref_393_half(input clk, clr, output reg qa=0, output reg qb=0, output reg qc=0, output reg qd=0);
    always @(negedge clk or posedge clr) if (clr) qa <= #3 0; else qa <= #3 ~qa;
    always @(negedge qa  or posedge clr) if (clr) qb <= #3 0; else qb <= #3 ~qb;
    always @(negedge qb  or posedge clr) if (clr) qc <= #3 0; else qc <= #3 ~qc;
    always @(negedge qc  or posedge clr) if (clr) qd <= #3 0; else qd <= #3 ~qd;
endmodule
module ref_74393(input p1,p2,p12,p13, output p3,p4,p5,p6,p8,p9,p10,p11);
    ref_393_half u1(`TTL(p1),`TTL(p2),p3,p4,p5,p6);
    ref_393_half u2(`TTL(p13),`TTL(p12),p11,p10,p9,p8);
endmodule
module ref_74153(input p1,p2,p3,p4,p5,p6,p10,p11,p12,p13,p14,p15, output p7,p9);
    wire [1:0] s = {`TTL(p2),`TTL(p14)};
    wire [3:0] c1 = {`TTL(p3),`TTL(p4),`TTL(p5),`TTL(p6)};
    wire [3:0] c2 = {`TTL(p13),`TTL(p12),`TTL(p11),`TTL(p10)};
    assign #3 p7 = !`TTL(p1)  && c1[s];
    assign #3 p9 = !`TTL(p15) && c2[s];
endmodule
// BCD-to-decimal. Inputs 10..15 select no output.
module ref_7442(input p15,p14,p13,p12, output p1,p2,p3,p4,p5,p6,p7,p9,p10,p11);
    wire [3:0] n = {`TTL(p12),`TTL(p13),`TTL(p14),`TTL(p15)};
    assign #3 {p11,p10,p9,p7,p6,p5,p4,p3,p2,p1} = ~(10'd1 << n) | {10{n > 4'd9}};
endmodule
// 512 x 8 PROM with three-state outputs: /CE1 pin 20, /CE2 pin 21, CE3 pin 19,
// CE4 pin 18; A0..A7 = pins 8..1, A8 = pin 23; O1..O8 = pins 9..11, 13..17.
module ref_7641 #(parameter integer OFFSET=0)(
    input p1,p2,p3,p4,p5,p6,p7,p8,p23,p18,p19,p20,p21,
    output p9,p10,p11,p13,p14,p15,p16,p17
);
    reg [7:0] mem[0:511];
    reg [1023:0] path;
    reg [7:0] all[0:8799];
    integer k;
    initial begin
        if (!$value$plusargs("ROM=%s",path)) $fatal(1,"ref_7641: missing +ROM");
        $readmemh(path,all);
        for (k=0;k<512;k=k+1) mem[k]=all[OFFSET+k];
    end
    wire [8:0] a = {`TTL(p23),`TTL(p1),`TTL(p2),`TTL(p3),`TTL(p4),
                    `TTL(p5),`TTL(p6),`TTL(p7),`TTL(p8)};
    wire en = !`TTL(p20) && !`TTL(p21) && `TTL(p19) && `TTL(p18);
    wire [7:0] q;
    assign #10 q = en ? mem[a] : 8'bz;
    assign {p17,p16,p15,p14,p13,p11,p10,p9} = q;
endmodule
// One half of a 74123 retriggerable monostable: A pin 1/9 (active low),
// B pin 2/10, /CLR pin 3/11, Q pin 13/5, /Q pin 4/12. External R in kohm and
// C in pF; tw = 0.28*R*C*(1+0.7/R) ns from the data sheet's C > 1000 pF formula.
// Input pulses shorter than 20 ns (decoder hazards while counters ripple) are
// ignored, standing in for the data sheet's minimum trigger pulse width.
module ref_74123_half #(parameter real R_KOHM=47.0, parameter real C_PF=1.0e7)(
    input a, b, clr_n, output reg q=0, output q_n
);
    localparam real TW = 0.28*R_KOHM*C_PF*(1.0+0.7/R_KOHM);
    wire #20 ta = `TTL(a);
    wire #20 tb = `TTL(b);
    wire #20 tc = `TTL(clr_n);
    reg ta_l=1, tb_l=1, tc_l=1;
    real t_end = 0.0;
    event start;
    assign q_n = ~q;
    always @(ta or tb or tc) begin
        if (!tc) begin
            t_end = 0.0;
            q <= #3 0;
        end else if ((ta_l && !ta && tb) || (!tb_l && tb && !ta) || (!tc_l && !ta && tb)) begin
            t_end = $realtime + TW;
            q <= #3 1;
            -> start;
        end
        ta_l = ta; tb_l = tb; tc_l = tc;
    end
    // A retrigger extends t_end while this process waits. The loop ends once
    // less than this module's 1 ps precision remains: a shorter delay rounds
    // to zero and would never advance time.
    always begin
        @(start);
        while (t_end - $realtime >= 0.001) #(t_end - $realtime);
        q <= 0;
    end
endmodule

module sheet_g_reference(
    // Sheet-edge inputs, named as drawn
    input f_7mhz, f_hs_n, f_pl_h_st, f_pl_v_st,
    input f_explo_st, f_explo_st_n, f_acc1_n, f_home_pos_n,
    input a_coin_in_n, a_extend_n, d_gravel_n, d_slide_n,
    input h_vs4, h_vs8, h_vs16, h_vs32,
    // IC51 pin 3 is not drawn
    input ic51_3,
    // Observation
    output [7:0] hc, vc,
    output vwin, hwin, strobe_n,
    output [3:0] prom_en,
    output [7:0] bus,
    output y1, y2,
    output player_body_n, tire_n, player_bl_n, player_n, player,
    output sp_down_n, sp_down, acc1_pulse_n, acc1_st_n, score_st_n, ic66_3,
    output [3:0] ic38_q,
    output ic68_3, ic19_q
);
    wire ic63_1, ic63_4, ic34_11, ic46_4, ic46_6, ic48, ic45_12, ic51_4, ic51_7, ic51_9;
    wire ic56_6, ic57_6, ic57_8, ic62_6, ic62_8, ic66_11, ic72_1, ic80_6, ic83_2, ic83_3, ic83_4;
    wire ic95_6, ic95_8, ic73_10, ic76_7, ic76_9, ic61_10, ic44_10, ic119_5, ic119_12;
    wire ic68_pin3, ic19_13, ic19_4;
    wire nc;
    wire [7:0] c52, c54;   // pins 3,4,5,6,11,10,9,8 in that order (QA..QD, QA..QD)
    wire ic52_3=c52[0], ic52_4=c52[1], ic52_5=c52[2], ic52_6=c52[3];
    wire ic52_11=c52[4], ic52_10=c52[5], ic52_9=c52[6], ic52_8=c52[7];
    wire ic54_3=c54[0], ic54_4=c54[1], ic54_5=c54[2], ic54_6=c54[3];
    wire ic54_11=c54[4], ic54_10=c54[5], ic54_9=c54[6], ic54_8=c54[7];
    wire ic38_8, ic38_9, ic38_10, ic38_11;
    wire d0,d1,d2,d3,d4,d5,d6,d7;   // shared PROM data bus
    // Several three-state drivers; the low level wins (see trace notes).
    wand [7:0] dbus;

    // IC63 (7402): pins 3,2 -> 1 and 5,6 -> 4.
    ref_7402 ic63(.p2(ic34_11),.p3(f_7mhz),.p5(f_hs_n),.p6(ic54_8),
        .p8(1'b0),.p9(1'b0),.p11(1'b0),.p12(1'b0),
        .p1(ic63_1),.p4(ic63_4),.p10(),.p13());
    // IC52, IC54 (74393): pins 2 and 12 joined; pin 6 drives pin 13.
    ref_74393 ic52(.p1(ic63_1),.p2(f_pl_h_st),.p12(f_pl_h_st),.p13(ic52_6),
        .p3(c52[0]),.p4(c52[1]),.p5(c52[2]),.p6(c52[3]),
        .p11(c52[4]),.p10(c52[5]),.p9(c52[6]),.p8(c52[7]));
    ref_74393 ic54(.p1(ic63_4),.p2(f_pl_v_st),.p12(f_pl_v_st),.p13(ic54_6),
        .p3(c54[0]),.p4(c54[1]),.p5(c54[2]),.p6(c54[3]),
        .p11(c54[4]),.p10(c54[5]),.p9(c54[6]),.p8(c54[7]));
    // IC34 (7408): 13,12 -> 11.
    ref_7408 ic34(.p1(1'b0),.p2(1'b0),.p4(1'b0),.p5(1'b0),.p9(1'b0),.p10(1'b0),
        .p12(ic52_8),.p13(ic52_10),.p3(),.p6(),.p8(),.p11(ic34_11));
    // IC46 (7404): 3 -> 4, 5 -> 6, 9 -> 8.
    ref_7404 ic46(.p1(1'b0),.p3(ic54_9),.p5(ic52_8),.p9(ic57_8),.p11(1'b0),.p13(1'b0),
        .p2(),.p4(ic46_4),.p6(ic46_6),.p8(),.p10(),.p12());
    // IC48 (NAND, pin numbers not drawn): VC6, VC4 -> IC51 pin 1.
    assign #2 ic48 = ~(ic54_9 & ic54_11);
    // IC45 (7410): 1,2,13 -> 12.
    ref_7410 ic45(.p1(ic46_4),.p2(ic54_10),.p13(ic54_11),
        .p3(1'b0),.p4(1'b0),.p5(1'b0),.p9(1'b0),.p10(1'b0),.p11(1'b0),
        .p12(ic45_12),.p6(),.p8());
    // IC51 (74279). Pin 3 is undrawn (driven by the test). Latch 3 pins 10, 12
    // are not traced here and are left open.
    ref_74279 ic51(.p1(ic48),.p2(ic45_12),.p3(ic51_3),.p5(f_home_pos_n),.p6(ic19_13),
        .p10(1'bz),.p11(ic66_3),.p12(1'bz),.p14(1'bz),.p15(1'bz),
        .p4(ic51_4),.p7(ic51_7),.p9(ic51_9),.p13());
    // IC57 (7425). The drawing labels the HC6 input '3' (the strobe pin); this
    // model follows the trace reading of pin 5 with the strobe left open.
    ref_7425 ic57(.p1(a_coin_in_n),.p2(ic46_6),.p3(1'bz),.p4(ic52_10),.p5(ic52_9),
        .p9(ic52_8),.p10(ic52_9),.p11(1'bz),.p12(ic52_10),.p13(1'b1),
        .p6(ic57_6),.p8(ic57_8));
    // IC56 (7400): 4,5 -> 6.
    ref_7400 ic56(.p1(1'b0),.p2(1'b0),.p4(ic51_4),.p5(ic57_6),.p9(1'b0),.p10(1'b0),
        .p12(1'b0),.p13(1'b0),.p3(),.p6(ic56_6),.p8(),.p11());
    // IC62 (7432): 9,10 -> 8 and 4,5 -> 6.
    ref_7432 ic62(.p1(1'b0),.p2(1'b0),.p4(ic51_7),.p5(a_extend_n),.p9(ic56_6),
        .p10(f_explo_st),.p12(1'b0),.p13(1'b0),.p3(),.p6(ic62_6),.p8(ic62_8),.p11());
    // IC38 (74393, second half): clock pin 13 = Vs/32, clear pin 12 = IC62 pin 6.
    ref_74393 ic38(.p1(1'b0),.p2(1'b1),.p12(ic62_6),.p13(h_vs32),
        .p3(),.p4(),.p5(),.p6(),.p11(ic38_11),.p10(ic38_10),.p9(ic38_9),.p8(ic38_8));
    // IC80 (7410): 3,4,5 -> 6.
    ref_7410 ic80(.p1(1'b0),.p2(1'b0),.p13(1'b0),.p3(ic38_10),.p4(ic38_9),.p5(ic38_8),
        .p9(1'b0),.p10(1'b0),.p11(1'b0),.p12(),.p6(ic80_6),.p8());
    // IC72 (7402): 3,2 -> 1.
    ref_7402 ic72(.p2(ic119_5),.p3(ic38_8),.p5(1'b0),.p6(1'b0),.p8(1'b0),.p9(1'b0),
        .p11(1'b0),.p12(1'b0),.p1(ic72_1),.p4(),.p10(),.p13());
    // IC66 (7408): 1,2 -> 3 and 12,13 -> 11.
    ref_7408 ic66(.p1(f_acc1_n),.p2(ic119_12),.p4(1'b0),.p5(1'b0),.p9(1'b0),.p10(1'b0),
        .p12(d_gravel_n),.p13(d_slide_n),.p3(ic66_3),.p6(),.p8(),.p11(ic66_11));
    // IC119 (74123, second half): A pin 9, B pin 10 = IC68 pin 3, /CLR pin 11; R16, C30.
    ref_74123_half #(.R_KOHM(47.0),.C_PF(1.0e7)) ic119(
        .a(ic66_11),.b(ic68_pin3),.clr_n(ic51_7),.q(ic119_5),.q_n(ic119_12));
    // IC19 (74123, first half): A pin 1 = /SLIDE, B pin 2 = IC68 pin 3,
    // /CLR pin 3 = Vcc, Q pin 13 -> IC51 pin 6, /Q pin 4 -> /SCORE.ST; R19, C33.
    ref_74123_half #(.R_KOHM(47.0),.C_PF(1.0e7)) ic19(
        .a(d_slide_n),.b(ic68_pin3),.clr_n(1'b1),.q(ic19_13),.q_n(ic19_4));
    // IC68 (pins 1, 2 -> 3), drawn as an OR with inverted inputs: a NAND.
    ref_7400 ic68(.p1(f_explo_st_n),.p2(ic83_2),.p4(1'b0),.p5(1'b0),.p9(1'b0),.p10(1'b0),
        .p12(1'b0),.p13(1'b0),.p3(ic68_pin3),.p6(),.p8(),.p11());
    // IC95 (7432): 4,5 -> 6 and 9,10 -> 8; IC73 (7404): 11 -> 10.
    ref_7432 ic95(.p1(1'b0),.p2(1'b0),.p4(h_vs16),.p5(f_acc1_n),.p9(f_acc1_n),
        .p10(ic73_10),.p12(1'b0),.p13(1'b0),.p3(),.p6(ic95_6),.p8(ic95_8),.p11());
    ref_7404 ic73(.p1(1'b0),.p3(1'b0),.p5(1'b0),.p9(1'b0),.p11(h_vs16),.p13(1'b0),
        .p2(),.p4(),.p6(),.p8(),.p10(ic73_10),.p12());

    // PR127 (IC77), PR128 (IC84), PR129 (IC91), PR130 (IC98).
    // Address pins 8..4 = IC54 pins 3,4,5,6,11; pins 3,2,1 = IC52 pins 5,6,11.
    wire [7:0] q127, q128, q129, q130;
    ref_7641 #(.OFFSET(1024)) pr127(
        .p8(ic54_3),.p7(ic54_4),.p6(ic54_5),.p5(ic54_6),.p4(ic54_11),
        .p3(ic52_5),.p2(ic52_6),.p1(ic52_11),.p23(h_vs4),
        .p20(1'b0),.p21(1'b0),.p19(ic66_3),.p18(ic66_3),
        .p9(q127[0]),.p10(q127[1]),.p11(q127[2]),.p13(q127[3]),
        .p14(q127[4]),.p15(q127[5]),.p16(q127[6]),.p17(q127[7]));
    ref_7641 #(.OFFSET(1536)) pr128(
        .p8(ic54_3),.p7(ic54_4),.p6(ic54_5),.p5(ic54_6),.p4(ic54_11),
        .p3(ic52_5),.p2(ic52_6),.p1(ic52_11),.p23(h_vs8),
        .p20(ic72_1),.p21(ic72_1),.p19(f_explo_st_n),.p18(f_explo_st_n),
        .p9(q128[0]),.p10(q128[1]),.p11(q128[2]),.p13(q128[3]),
        .p14(q128[4]),.p15(q128[5]),.p16(q128[6]),.p17(q128[7]));
    ref_7641 #(.OFFSET(2048)) pr129(
        .p8(ic54_3),.p7(ic54_4),.p6(ic54_5),.p5(ic54_6),.p4(ic54_11),
        .p3(ic52_5),.p2(ic52_6),.p1(ic52_11),.p23(h_vs8),
        .p20(ic95_6),.p21(ic95_6),.p19(f_explo_st_n),.p18(f_explo_st_n),
        .p9(q129[0]),.p10(q129[1]),.p11(q129[2]),.p13(q129[3]),
        .p14(q129[4]),.p15(q129[5]),.p16(q129[6]),.p17(q129[7]));
    ref_7641 #(.OFFSET(2560)) pr130(
        .p8(ic54_3),.p7(ic54_4),.p6(ic54_5),.p5(ic54_6),.p4(ic54_11),
        .p3(ic52_5),.p2(ic52_6),.p1(ic52_11),.p23(h_vs8),
        .p20(ic95_8),.p21(ic95_8),.p19(f_explo_st_n),.p18(f_explo_st_n),
        .p9(q130[0]),.p10(q130[1]),.p11(q130[2]),.p13(q130[3]),
        .p14(q130[4]),.p15(q130[5]),.p16(q130[6]),.p17(q130[7]));
    assign dbus = q127;
    assign dbus = q128;
    assign dbus = q129;
    assign dbus = q130;
    assign {d7,d6,d5,d4,d3,d2,d1,d0} = dbus;

    // IC76 (74153): data pins 9,10,11,13,14,15,16,17 -> 6,5,4,3,10,11,12,13.
    ref_74153 ic76(.p1(ic62_8),.p15(ic62_8),.p14(ic52_3),.p2(ic52_4),
        .p6(d0),.p5(d1),.p4(d2),.p3(d3),.p10(d4),.p11(d5),.p12(d6),.p13(d7),
        .p7(ic76_7),.p9(ic76_9));
    // IC83 (7442): A = IC76 pin 7, B = IC76 pin 9, C = D = IC62 pin 8.
    ref_7442 ic83(.p15(ic76_7),.p14(ic76_9),.p13(ic62_8),.p12(ic62_8),
        .p1(),.p2(ic83_2),.p3(ic83_3),.p4(ic83_4),.p5(),.p6(),.p7(),.p9(),.p10(),.p11());
    // IC61 (7402): 8,9 -> 10. IC44 (7404): 11 -> 10.
    ref_7402 ic61(.p2(1'b0),.p3(1'b0),.p5(1'b0),.p6(1'b0),.p8(ic76_7),.p9(ic76_9),
        .p11(1'b0),.p12(1'b0),.p1(),.p4(),.p10(ic61_10),.p13());
    ref_7404 ic44(.p1(1'b0),.p3(1'b0),.p5(1'b0),.p9(1'b0),.p11(ic83_2),.p13(1'b0),
        .p2(),.p4(),.p6(),.p8(),.p10(ic44_10),.p12());

    // Observation, by net
    assign hc = {ic52_8,ic52_9,ic52_10,ic52_11,ic52_6,ic52_5,ic52_4,ic52_3};
    assign vc = {ic54_8,ic54_9,ic54_10,ic54_11,ic54_6,ic54_5,ic54_4,ic54_3};
    assign vwin = ic51_4;
    assign hwin = ic57_6;
    assign strobe_n = ic62_8;
    assign prom_en = {pr130.en, pr129.en, pr128.en, pr127.en};
    assign bus = {`TTL(d7),`TTL(d6),`TTL(d5),`TTL(d4),`TTL(d3),`TTL(d2),`TTL(d1),`TTL(d0)};
    assign y1 = ic76_7;
    assign y2 = ic76_9;
    assign player_body_n = ic83_2;
    assign tire_n = ic83_3;
    assign player_bl_n = ic83_4;
    assign player_n = ic61_10;
    assign player = ic44_10;
    assign sp_down_n = ic72_1;
    assign sp_down = ic119_5;
    assign acc1_pulse_n = ic80_6;
    assign acc1_st_n = ic51_7;
    assign score_st_n = ic19_4;
    assign ic68_3 = ic68_pin3;
    assign ic19_q = ic19_13;
    assign ic38_q = {ic38_8,ic38_9,ic38_10,ic38_11};
    assign nc = ic51_9;
endmodule
