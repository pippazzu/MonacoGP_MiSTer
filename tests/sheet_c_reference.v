// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected reference for sheet C (manual 420-0358, PDF page
// 30). Each package is modelled from its data sheet pin functions and wired
// by IC and pin number from the pin tables in docs/trace/SHEET_C_TRACE.md.
// Self-contained: the rc_ models below are written for this file. Gates take
// 0.01 ns; IC79 (74174) takes D on the rising edge of 7M, Q 1 ns later.
// IC86 (74368) floats its outputs while disabled; IC79's D inputs then read
// high, as TTL inputs do. Open inputs (IC8.4, IC20.3, IC2.11, IC33.4's test
// point, the unwired 7430 inputs) read high.
`timescale 1ns/1ps

`ifndef TTL
`define TTL(x) ((x) === 1'bz ? 1'b1 : (x))
`endif
`define RC_G 0.01

module rc_nand2(input a, b, output y);  assign #(`RC_G) y = ~(`TTL(a)&`TTL(b)); endmodule
module rc_nand3(input a, b, c, output y);  assign #(`RC_G) y = ~(`TTL(a)&`TTL(b)&`TTL(c)); endmodule
module rc_nand4(input a, b, c, d, output y);  assign #(`RC_G) y = ~(`TTL(a)&`TTL(b)&`TTL(c)&`TTL(d)); endmodule
module rc_nand8(input [7:0] a, output y);  // 7430: inputs 1, 2, 3, 4, 5, 6, 11, 12
    assign #(`RC_G) y = ~(`TTL(a[0])&`TTL(a[1])&`TTL(a[2])&`TTL(a[3])&`TTL(a[4])&`TTL(a[5])&`TTL(a[6])&`TTL(a[7]));
endmodule
module rc_and2(input a, b, output y);  assign #(`RC_G) y = `TTL(a)&`TTL(b); endmodule
module rc_and3(input a, b, c, output y);  assign #(`RC_G) y = `TTL(a)&`TTL(b)&`TTL(c); endmodule
module rc_or2(input a, b, output y);  assign #(`RC_G) y = `TTL(a)|`TTL(b); endmodule
module rc_nor2(input a, b, output y);  assign #(`RC_G) y = ~(`TTL(a)|`TTL(b)); endmodule
module rc_nor3(input a, b, c, output y);  assign #(`RC_G) y = ~(`TTL(a)|`TTL(b)|`TTL(c)); endmodule
module rc_inv(input a, output y);  assign #(`RC_G) y = ~`TTL(a); endmodule
module rc_buf(input a, output y);  assign #(`RC_G) y = `TTL(a); endmodule
// 74157: select pin 1 (low: A inputs), strobe pin 15 (active low).
module rc_74157(input p1,p2,p3,p5,p6,p10,p11,p13,p14,p15, output p4,p7,p9,p12);
    wire s = `TTL(p1), g = !`TTL(p15);
    assign #(`RC_G) p4  = g && (s ? `TTL(p3)  : `TTL(p2));
    assign #(`RC_G) p7  = g && (s ? `TTL(p6)  : `TTL(p5));
    assign #(`RC_G) p9  = g && (s ? `TTL(p10) : `TTL(p11));
    assign #(`RC_G) p12 = g && (s ? `TTL(p13) : `TTL(p14));
endmodule
// 74147 10-line to 4-line priority encoder: inputs 1..9 on pins 11, 12, 13,
// 1, 2, 3, 4, 5, 10 (active low, 9 highest); outputs A 9, B 7, C 6, D 14
// (active low).
module rc_74147(input p11,p12,p13,p1,p2,p3,p4,p5,p10, output p9,p7,p6,p14);
    wire [9:1] in_n = {`TTL(p10),`TTL(p5),`TTL(p4),`TTL(p3),`TTL(p2),`TTL(p1),`TTL(p13),`TTL(p12),`TTL(p11)};
    reg [3:0] n;
    integer k;
    always @* begin
        n = 0;
        for (k = 1; k <= 9; k = k + 1) if (!in_n[k]) n = k;
    end
    assign #(`RC_G) {p14,p6,p7,p9} = ~n;
endmodule
// 74368 hex inverting buffer, three-state: /G1 (pin 1) for the first four,
// /G2 (pin 15) for the last two.
module rc_74368(input g1_n, g2_n, input [6:1] a, output [6:1] y);
    assign #(`RC_G) y[4:1] = `TTL(g1_n) ? 4'bzzzz : ~{`TTL(a[4]),`TTL(a[3]),`TTL(a[2]),`TTL(a[1])};
    assign #(`RC_G) y[6:5] = `TTL(g2_n) ? 2'bzz : ~{`TTL(a[6]),`TTL(a[5])};
endmodule
// 74174 hex D flip-flop: CP pin 9 (rising), /MR pin 1.
module rc_74174(input cp, mr_n, input [6:1] d, output reg [6:1] q = 6'h3f);
    reg cp_l = 1'bx;
    reg [6:1] dv;
    always @(cp) begin
        if (cp_l === 1'b0 && cp === 1'b1 && `TTL(mr_n)) begin
            dv = {`TTL(d[6]),`TTL(d[5]),`TTL(d[4]),`TTL(d[3]),`TTL(d[2]),`TTL(d[1])};
            q <= #1 dv;
        end
        cp_l = cp;
    end
    always @(mr_n) if (!`TTL(mr_n)) q <= 0;
endmodule

module sheet_c_reference(
    input        m7,                    // 7M
    input  [5:1] area,
    input        other_body_n, other_tiar_n, other_car_n,
    input        road_n, tg_g_n, tg_bl_n, house_st_n, grass_area_n, grass_w_n,
    input        road,                  // ROAD, the second arrow (no overbar)
    input  [3:0] house_n,               // /HOUSE (W), (St), (Mu), (R)
    input        tunnel_ap, bridge_ap, green_belt_n, y_line_n, gravel_n, pool_n, slip_n, wall_n, side_line_n,
    input        extend, extend_n, coin_start_n, ex_gameover_n, v4d,
    input        light_n, splay_n, explo_y_n, explo_r_n, explo_area_n,
    input        player_n, player_body_n, player_tiar_n, player_bl_n,
    input        sig_bl_n, sig_y_n, dummy_area_n, dummy_bl_n, dummy_w_n, dummy_r_n,
    input        rescue_bl_n, rescue_w_n, rescue_y_n, rescue_r_n,
    input        bridge_dbu_n, bridge_bu_n, bridge_y_n, bridge_w_n, bridge_r_n,
    // Pro board: /+200 (R) from Pro sheet M joins the red collector; BELT
    // from Pro sheet D; extend and extend_n are then D-EXTEND, /D-EXTEND
    input        pro, plus200_n, belt,
    output       red_on, blue_on, green_on, bright,
    output       bdim,                  // Pro: the R8 pull-down on BLUE is on
    output [3:0] code
);
    wire vcc = 1'b1, gnd = 1'b0, nc = 1'bz;
    // ------------------------------------------------------------ AREA register
    wire [6:1] y86;
    rc_74368 ic86(.g1_n(other_body_n),.g2_n(other_body_n),.a({nc, area[5], area[4], area[3], area[2], area[1]}),.y(y86));
    // y86[1..5] = pins 3, 5, 7, 9, 11 (inputs 2, 4, 6, 10, 12)
    wire [6:1] q79;   // Q1 2, Q2 5, Q3 7, Q4 10, Q5 12, Q6 15
    rc_74174 ic79(.cp(m7),.mr_n(nc),.d({nc, y86[5], y86[4], y86[3], y86[2], y86[1]}),.q(q79));
    // ------------------------------------------------------------ gates
    wire n21_6, n19b_8, n19c_6, n19a_12, n15a_3, n15b_6, n10a_3, n10b_8, n34_1;
    wire n8a_6, n8b_8, n8c_12, n9a_8, n9b_6, n14a_6, n14b_8, n26_6, n44_12, n66_12, n45_11, n58_8;
    wire n13_8, n4_8, n27_8, n33_8;
    wire n3_2, n3_4, n3_6, n3_8, n3_10, n3_12;
    wire n5_4, n5_7, n5_9, n5_12, n20_4, n20_7, n20_9, n20_12;
    rc_and3  ic21  (.a(tg_g_n),.b(house_st_n),.c(grass_area_n),.y(n21_6));       // 5, 3, 4 -> 6
    rc_nand3 ic19b (.a(road_n),.b(n21_6),.c(tg_bl_n),.y(n19b_8));                // 9, 10, 11 -> 8
    rc_nand3 ic19c (.a(light_n),.b(tunnel_ap),.c(n66_12),.y(n19c_6));            // 3, 4, 5 -> 6
    rc_nand3 ic19a (.a(q79[1]),.b(n20_9),.c(n10b_8),.y(n19a_12));                // 2, 13, 1 -> 12
    rc_and2  ic15a (.a(road_n),.b(light_n),.y(n15a_3));                          // 1, 2 -> 3
    rc_and2  ic15b (.a(rescue_bl_n),.b(gravel_n),.y(n15b_6));                    // 4, 5 -> 6
    rc_or2   ic10a (.a(n13_8),.b(n15a_3),.y(n10a_3));                            // 1, 2 -> 3
    rc_or2   ic10b (.a(extend_n),.b(n5_7),.y(n10b_8));                           // 10, 9 -> 8
    rc_nor2  ic34  (.a(n10a_3),.b(extend),.y(n34_1));                            // 3, 2 -> 1
    rc_and3  ic8a  (.a(q79[3]),.b(n20_4),.c(nc),.y(n8a_6));                      // 5, 3, 4 (open) -> 6
    rc_and3  ic8b  (.a(q79[5]),.b(coin_start_n),.c(n9a_8),.y(n8b_8));            // 9, 10, 11 -> 8
    rc_and3  ic8c  (.a(rescue_bl_n),.b(other_car_n),.c(n66_12),.y(n8c_12));      // 13, 1, 2 -> 12
    rc_nand2 ic9a  (.a(n14b_8),.b(n8c_12),.y(n9a_8));                            // 9, 10 -> 8
    rc_nand2 ic9b  (.a(v4d),.b(bridge_dbu_n),.y(n9b_6));                         // 4, 5 -> 6
    // Pro (pro/docs/trace/SHEET_C_COMPARE.md D2): this is 57 (5, 1, 2, 4 ->
    // 6) with D-EXTEND in place of 7M and NOR 51 (4, 3, 5 -> 6) of inverter
    // 92 (1 -> 2) on IC15 pin 6, BELT and IC14 pin 8 in place of IC15 pin 6.
    wire p92_2, p51_6;
    rc_inv  ic92p(.a(n15b_6),.y(p92_2));
    rc_nor3 ic51p(.a(p92_2),.b(belt),.c(n14b_8),.y(p51_6));
    rc_nand4 ic14a (.a(pro ? extend : m7),.b(pro ? p51_6 : n15b_6),.c(n8c_12),.d(n5_4),.y(n14a_6)); // 4, 1, 5, 2 -> 6
    rc_nand4 ic14b (.a(splay_n),.b(pool_n),.c(slip_n),.d(house_n[2]),.y(n14b_8)); // 10, 12, 9, 13 -> 8
    rc_nand4 ic26  (.a(n19c_6),.b(sig_bl_n),.c(dummy_bl_n),.d(player_bl_n),.y(n26_6)); // 5, 1, 2, 4 -> 6
    rc_nand3 ic44  (.a(house_n[0]),.b(wall_n),.c(bridge_r_n),.y(n44_12));        // 13, 2, 1 -> 12
    rc_and3  ic66  (.a(player_n),.b(dummy_area_n),.c(explo_area_n),.y(n66_12));  // 2, 1, 13 -> 12
    rc_nand2 ic45  (.a(n44_12),.b(n66_12),.y(n45_11));                           // 12, 13 -> 11
    rc_and2  ic58  (.a(q79[2]),.b(house_n[1]),.y(n58_8));                        // 10, 9 -> 8
    // 7430s, inputs in the order 1, 2, 3, 4, 5, 6, 11, 12
    rc_nand8 ic13(.a({n21_6, green_belt_n, n8b_8, n3_10, y_line_n, n8c_12, tg_bl_n, nc}),.y(n13_8));
    rc_nand8 ic4 (.a({sig_y_n, n5_9, q79[4], explo_y_n, nc, n20_12, nc, rescue_y_n}),.y(n4_8));
    rc_nand8 ic27(.a({house_n[3], other_tiar_n, n20_7, player_tiar_n, nc, n5_12, rescue_w_n, dummy_w_n}),.y(n27_8));
    // Pro (pro/docs/trace/SHEET_M_C_PLUS200_TRACE.md): the red collector, IC74
    // there, has /+200 on one more input (numeral 5 or 3 on Pro). It goes on
    // the input left unwired here, pin 3; the 7430 inputs are equivalent.
    wire n33_p3 = pro ? plus200_n : nc;
    rc_nand8 ic33(.a({ex_gameover_n, n45_11, player_body_n, explo_r_n, nc, n33_p3, dummy_r_n, rescue_r_n}),.y(n33_8));
    rc_inv ic3a(.a(n26_6),.y(n3_2));     // 1 -> 2
    rc_inv ic3b(.a(n27_8),.y(n3_4));     // 3 -> 4
    rc_inv ic3c(.a(n4_8),.y(n3_6));      // 5 -> 6
    rc_inv ic3d(.a(n19a_12),.y(n3_8));   // 9 -> 8
    rc_inv ic3e(.a(n33_8),.y(n3_10));    // 11 -> 10
    rc_inv ic3f(.a(n34_1),.y(n3_12));    // 13 -> 12
    // ------------------------------------------------------------ multiplexers
    rc_74157 ic5(.p1(bridge_ap),.p15(gnd),
        .p2(road),.p3(n9b_6),.p4(n5_4),
        .p5(road),.p6(bridge_bu_n),.p7(n5_7),
        .p11(y_line_n),.p10(bridge_y_n),.p9(n5_9),
        .p14(side_line_n),.p13(bridge_w_n),.p12(n5_12));
    rc_74157 ic20(.p1(extend),.p15(gnd),
        .p2(tg_g_n),.p3(nc),.p4(n20_4),
        .p5(n10a_3),.p6(tg_g_n),.p7(n20_7),
        .p11(grass_w_n),.p10(n14a_6),.p9(n20_9),
        .p14(n19b_8),.p13(tg_bl_n),.p12(n20_12));
    // ------------------------------------------------------------ encoder and output
    wire a2, b2, c2, d2;
    rc_74147 ic2(.p11(nc),.p12(n3_8),.p13(n58_8),.p1(n8a_6),.p2(n3_6),.p3(n8b_8),.p4(n3_4),.p5(n3_2),.p10(n3_10),
                 .p9(a2),.p7(b2),.p6(c2),.p14(d2));
    rc_inv ic7d(.a(a2),.y(red_on));      // 9 -> 8 (open collector: high = node pulled up)
    rc_inv ic7e(.a(b2),.y(blue_on));     // 11 -> 10
    rc_inv ic7f(.a(c2),.y(green_on));    // 13 -> 12
    rc_buf ic1 (.a(n3_12),.y(bright));   // IC1 (7417): low pulls the three nodes to the dim level
    // Pro (D1): a fourth 7417 section, 11 -> 10, from 57 pin 6 to R8 on BLUE
    wire p17_10;
    rc_buf ic1p(.a(n14a_6),.y(p17_10));
    assign bdim = pro & ~p17_10;
    assign code = ~{d2, c2, b2, a2};
endmodule
