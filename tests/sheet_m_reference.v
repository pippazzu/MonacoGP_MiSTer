// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected, event-driven reference for sheet M (manual
// 420-0358, PDF page 33). Each package is modelled from its data sheet pin
// functions and wired by IC and pin number from the pin tables in
// docs/trace/SHEET_M_TRACE.md. Self-contained: the rm_ models below are
// written for this file.
//
// Timing rule ("settled layers", every element one layer), as in
// tests/sheet_h_reference.v:
// - Gates, decoders and multiplexers take 0.01 ns.
// - Every element's clock, trigger and asynchronous input goes through a 3 ns
//   inertial filter (rm_filt), which absorbs and counts hazards. Clocked
//   outputs follow 1 ns after the filtered edge, asynchronous ones (clears,
//   presets) 0.02 ns after; a clock edge's output is dropped if a clear or
//   preset is active by then. The PROMs follow their address after 3.02 ns,
//   also one layer.
// - f7 is the 7 MHz edge (7M of sheet E). The testbench changes the other
//   sheets' nets 5 ns after it, after IC36 and IC37 have sampled theirs, and
//   IC18 ends its pulse then too.
`timescale 1ns/1ps

`ifndef TTL
`define TTL(x) ((x) === 1'bz ? 1'b1 : (x))
`endif
`define RM_G  0.01
`define RM_L  0.02
`define RM_W  3.0
`define RM_CQ 1.0
`define RM_T  5.0

module rm_filt(input a, output y);
    assign #(`RM_W) y = `TTL(a);
    integer hazards = 0;
    realtime t = -1.0e9;
    always @(a) begin
        if ($realtime > 1000.0 && $realtime - t < `RM_W) hazards = hazards + 1;
        t = $realtime;
    end
endmodule

module rm_nand2(input a, b, output y);    // one 7400 section
    assign #(`RM_G) y = ~(`TTL(a)&`TTL(b));
endmodule
module rm_nand3(input a, b, c, output y); // one 7410 section
    assign #(`RM_G) y = ~(`TTL(a)&`TTL(b)&`TTL(c));
endmodule
module rm_nand4(input a, b, c, d, output y); // one 7420 section
    assign #(`RM_G) y = ~(`TTL(a)&`TTL(b)&`TTL(c)&`TTL(d));
endmodule
module rm_and2(input a, b, output y);     // one 7408 / 7409 section
    assign #(`RM_G) y = `TTL(a)&`TTL(b);
endmodule
module rm_and3(input a, b, c, output y);  // one 7411 section
    assign #(`RM_G) y = `TTL(a)&`TTL(b)&`TTL(c);
endmodule
module rm_or2(input a, b, output y);      // one 7432 section
    assign #(`RM_G) y = `TTL(a)|`TTL(b);
endmodule
module rm_nor2(input a, b, output y);     // one 7402 section
    assign #(`RM_G) y = ~(`TTL(a)|`TTL(b));
endmodule
module rm_nor3(input a, b, c, output y);  // one 7427 section
    assign #(`RM_G) y = ~(`TTL(a)|`TTL(b)|`TTL(c));
endmodule
module rm_xor2(input a, b, output y);     // one 7486 section
    assign #(`RM_G) y = `TTL(a)^`TTL(b);
endmodule
module rm_inv(input a, output y);         // one 7404 / 7406 section
    assign #(`RM_G) y = ~`TTL(a);
endmodule
// 74157: select pin 1 (low: A inputs), strobe pin 15 (active low).
module rm_74157(input p1,p2,p3,p5,p6,p10,p11,p13,p14,p15, output p4,p7,p9,p12);
    wire s = `TTL(p1), g = !`TTL(p15);
    assign #(`RM_G) p4  = g && (s ? `TTL(p3)  : `TTL(p2));
    assign #(`RM_G) p7  = g && (s ? `TTL(p6)  : `TTL(p5));
    assign #(`RM_G) p9  = g && (s ? `TTL(p10) : `TTL(p11));
    assign #(`RM_G) p12 = g && (s ? `TTL(p13) : `TTL(p14));
endmodule
// 74153 dual 4-to-1: A pin 14, B pin 2; /1G 1, 1C0..1C3 6, 5, 4, 3, 1Y 7;
// /2G 15, 2C0..2C3 10, 11, 12, 13, 2Y 9.
module rm_74153(input p1,p2,p3,p4,p5,p6,p10,p11,p12,p13,p14,p15, output p7,p9);
    wire [1:0] s = {`TTL(p2), `TTL(p14)};
    wire [3:0] c1 = {`TTL(p3), `TTL(p4), `TTL(p5), `TTL(p6)};
    wire [3:0] c2 = {`TTL(p13), `TTL(p12), `TTL(p11), `TTL(p10)};
    assign #(`RM_G) p7 = !`TTL(p1) && c1[s];
    assign #(`RM_G) p9 = !`TTL(p15) && c2[s];
endmodule
// 7442 BCD to decimal: A 15, B 14, C 13, D 12; outputs 0..9 on pins 1..7,
// 9..11, low when selected.
module rm_7442(input p15,p14,p13,p12, output p1,p2,p3,p4,p5,p6,p7,p9,p10,p11);
    wire [3:0] n = {`TTL(p12), `TTL(p13), `TTL(p14), `TTL(p15)};
    assign #(`RM_G) {p11,p10,p9,p7,p6,p5,p4,p3,p2,p1} = ~(10'd1 << n);
endmodule
// 74161: /MR pin 1, CP 2, D0..D3 3..6, CEP 7, /PE 9 (synchronous load),
// CET 10, Q0..Q3 14..11, TC 15 = CET & Q = 15.
module rm_74161(input p1,p2,p3,p4,p5,p6,p7,p9,p10, output p11,p12,p13,p14,p15);
    wire ck, mr_n;
    rm_filt fck(.a(p2),.y(ck));
    rm_filt fmr(.a(p1),.y(mr_n));
    reg [3:0] q = 0, nq;
    reg ck_l = 1'bx;
    always @(mr_n) if (!mr_n) q <= #(`RM_L) 0;
    always @(ck) begin
        if (ck_l === 1'b0 && ck === 1'b1 && mr_n) begin
            if (!`TTL(p9)) nq = {`TTL(p6),`TTL(p5),`TTL(p4),`TTL(p3)};
            else if (`TTL(p7) && `TTL(p10)) nq = q + 4'd1;
            else nq = q;
            #(`RM_CQ) if (mr_n) q = nq;
        end
        ck_l = ck;
    end
    assign {p11,p12,p13,p14} = q;
    assign #(`RM_G) p15 = `TTL(p10) && q == 4'hf;
endmodule
// One 74107 half: J, K, /CLR, CLK (falling edge), Q, /Q.
module rm_74107_half(input j, k, clr_in, ck_in, output reg q = 0, output q_n);
    wire ck, clr_n;
    rm_filt fck(.a(ck_in),.y(ck));
    rm_filt fcl(.a(clr_in),.y(clr_n));
    reg ck_l = 1'bx, nq;
    assign q_n = ~q;
    always @(clr_n) if (!clr_n) q <= #(`RM_L) 0;
    always @(ck) begin
        if (ck_l === 1'b1 && ck === 1'b0 && clr_n) begin
            nq = {`TTL(j),`TTL(k)} == 2'b11 ? ~q : {`TTL(j),`TTL(k)} == 2'b10 ? 1'b1 :
                 {`TTL(j),`TTL(k)} == 2'b01 ? 1'b0 : q;
            #(`RM_CQ) if (clr_n) q = nq;
        end
        ck_l = ck;
    end
endmodule
// One 7474 half. Both /PR and /CLR low drives both outputs high.
module rm_7474_half(input clr_in, d, ck_in, pr_in, output reg q = 0, output q_n);
    wire ck, clr_n, pr_n;
    rm_filt fck(.a(ck_in),.y(ck));
    rm_filt fcl(.a(clr_in),.y(clr_n));
    rm_filt fpr(.a(pr_in),.y(pr_n));
    reg ck_l = 1'bx, dv;
    assign #(`RM_L) q_n = (!clr_n && !pr_n) ? 1'b1 : ~q;
    always @(clr_n or pr_n)
        if (!pr_n) q <= #(`RM_L) 1;
        else if (!clr_n) q <= #(`RM_L) 0;
    always @(ck) begin
        if (ck_l === 1'b0 && ck === 1'b1 && clr_n && pr_n) begin
            dv = `TTL(d);
            #(`RM_CQ) if (clr_n && pr_n) q = dv;
        end
        ck_l = ck;
    end
endmodule
// One 74393 half: CP (falling edge), MR (asynchronous, high), Q0..Q3.
module rm_74393_half(input ck_in, mr_in, output reg [3:0] q = 0);
    wire ck, mr;
    rm_filt fck(.a(ck_in),.y(ck));
    rm_filt fmr(.a(mr_in),.y(mr));
    reg ck_l = 1'bx;
    always @(mr) if (mr) q <= #(`RM_L) 0;
    always @(ck) begin
        if (ck_l === 1'b1 && ck === 1'b0 && !mr) begin
            #(`RM_CQ) if (!mr) q = q + 4'd1;
        end
        ck_l = ck;
    end
endmodule
// 74193 up/down counter: UP 5, DOWN 4 (count on the rising edge while the
// other is high), CLR 14 (asynchronous, high), /LOAD 11 (asynchronous, low),
// A..D 15, 1, 10, 9, QA..QD 3, 2, 6, 7, /CO 12, /BO 13.
module rm_74193(input p5,p4,p14,p11,p15,p1,p10,p9, output p3,p2,p6,p7,p12,p13);
    wire up, dn, clr, ld_n;
    rm_filt fup(.a(p5),.y(up));
    rm_filt fdn(.a(p4),.y(dn));
    rm_filt fcl(.a(p14),.y(clr));
    rm_filt fld(.a(p11),.y(ld_n));
    reg [3:0] q = 0, nq;
    reg up_l = 1'bx, dn_l = 1'bx;
    always @(clr or ld_n)
        if (clr) q <= #(`RM_L) 0;
        else if (!ld_n) q <= #(`RM_L) {`TTL(p9),`TTL(p10),`TTL(p1),`TTL(p15)};
    always @(up or dn) begin
        if (up_l === 1'b0 && up === 1'b1 && dn === 1'b1 && !clr && ld_n) begin
            nq = q + 4'd1;
            #(`RM_CQ) if (!clr && ld_n) q = nq;
        end else if (dn_l === 1'b0 && dn === 1'b1 && up === 1'b1 && !clr && ld_n) begin
            nq = q - 4'd1;
            #(`RM_CQ) if (!clr && ld_n) q = nq;
        end
        up_l = up; dn_l = dn;
    end
    assign {p7,p6,p2,p3} = q;
    assign #(`RM_G) p12 = !(!`TTL(p5) && q == 4'hf);
    assign #(`RM_G) p13 = !(!`TTL(p4) && q == 4'h0);
endmodule
// One half of a 74123 retriggerable monostable: A (active low), B, /CLR, Q,
// /Q. Triggers: A falling while B is high, B rising while A is low, /CLR
// rising while A is low and B is high. PIXELS 7 MHz periods.
module rm_74123 #(parameter integer PIXELS = 1)(input a, b, clr_n, f7, output reg q = 0, output q_n);
    integer left = 0, trigs = 0;
    wire ta, tb, tc;
    rm_filt fa(.a(a),.y(ta));
    rm_filt fb(.a(b),.y(tb));
    rm_filt fc(.a(clr_n),.y(tc));
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
        if (left == 0) q <= #(`RM_T) 0;
    end
endmodule
// Pro board parts (pro/docs/trace/SHEET_M_C_PLUS200_TRACE.md, datasheets as
// listed there).
// One 7425 section with its strobe G open (reads high): Y = NOR(A, B, C, D).
module rm_nor4(input a, b, c, d, output y);
    assign #(`RM_G) y = ~(`TTL(a)|`TTL(b)|`TTL(c)|`TTL(d));
endmodule
// 74151 8-to-1: D0..D7 pins 4, 3, 2, 1, 15, 14, 13, 12; A, B, C 11, 10, 9;
// /G 7; Y 5, W 6. /G high forces Y low and W high.
module rm_74151(input p4,p3,p2,p1,p15,p14,p13,p12,p11,p10,p9,p7, output p5,p6);
    wire [7:0] d = {`TTL(p12),`TTL(p13),`TTL(p14),`TTL(p15),`TTL(p1),`TTL(p2),`TTL(p3),`TTL(p4)};
    wire [2:0] s = {`TTL(p9),`TTL(p10),`TTL(p11)};
    assign #(`RM_G) p5 = !`TTL(p7) && d[s];
    assign #(`RM_G) p6 = !(!`TTL(p7) && d[s]);
endmodule
// 6331 (MMI 53/6331-1) 32 x 8 PROM, open collector: A0..A4 pins 10..14, /E1
// pin 15, O1..O8 pins 1..7, 9. A stored 1 leaves the output off (floating,
// read high by a TTL input), a 0 pulls it low; disabled, all are off. One
// layer, as rm_prom. Contents: PR-54 has no known dump; these are Aldo's
// RECONSTRUCTION bytes (pro/reconstruction/plus200-glyph.txt, address 0..31,
// O1 = bit 0), written here from that file.
module rm_6331(input p10,p11,p12,p13,p14,p15, output p1,p2,p3,p4,p5,p6,p7,p9);
    localparam [255:0] PR54 = {
        8'h00, 8'h00, 8'h10, 8'h10, 8'h7c, 8'h7c, 8'h10, 8'h10,    // 31..24
        8'h00, 8'h00, 8'h66, 8'h66, 8'h52, 8'h52, 8'h4e, 8'h4e,    // 23..16
        8'h00, 8'h00, 8'h7e, 8'h7e, 8'h42, 8'h42, 8'h7e, 8'h7e,    // 15..8
        8'h00, 8'h00, 8'h7e, 8'h7e, 8'h42, 8'h42, 8'h7e, 8'h7e};   // 7..0
    wire [4:0] a = {`TTL(p14),`TTL(p13),`TTL(p12),`TTL(p11),`TTL(p10)};
    wire [7:0] w = `TTL(p15) ? 8'hff : PR54[a*8 +: 8];
    wire [7:0] o;
    genvar k;
    generate for (k = 0; k < 8; k = k + 1) begin: g
        assign #(`RM_W + `RM_L) o[k] = w[k] ? 1'bz : 1'b0;
    end endgenerate
    assign {p9,p7,p6,p5,p4,p3,p2,p1} = o;
endmodule
// 512 x 8 PROM (µPB425) with /CE1, /CE2 (20, 21) and CE3, CE4 (18, 19); the
// outputs float while disabled. A one-layer element: the data follow 3.02 ns
// after the address. OFFSET is the part's place in the +ROM image.
module rm_prom(input [8:0] a, input ce1_n, ce2_n, ce3, ce4, output [7:0] d);
    parameter integer OFFSET = 0;
    reg [7:0] image [0:8799];
    reg [1023:0] path;
    initial begin
        if (!$value$plusargs("ROM=%s",path)) $fatal(1,"rm_prom: missing +ROM");
        $readmemh(path,image);
    end
    wire [8:0] at;
    genvar k;
    generate for (k = 0; k < 9; k = k + 1) begin: g
        assign at[k] = `TTL(a[k]);
    end endgenerate
    wire en = !`TTL(ce1_n) && !`TTL(ce2_n) && `TTL(ce3) && `TTL(ce4);
    assign #(`RM_W + `RM_L) d = en ? image[OFFSET + at] : 8'bzzzzzzzz;
endmodule

module sheet_m_reference #(
    parameter integer IC18_PIXELS = 143293
)(
    input        f7,
    // Sheet E
    input  [8:0] m_h, m_v,
    input        m_hs_n,
    // Sheet B
    input  [5:1] m_vd,               // V-(1)..V-(5)
    input  [4:0] m_mh,
    // Sheet H
    input        m_vs4, m_vs16, m_vs32, m_vs64,
    // Sheets A, C, D, F
    input        m_extend, m_extend_n, m_game_n, m_coin_n, m_excp_n,
    input        m_100c, m_cnc_n, m_ext500, m_ext500_n, m_zero_n, m_bap, m_other_n,
    input        m_acce_d, m_explo,
    // Pro board: 1 adds PR-54 and its gates; BONUS CP from sheet N
    input        m_pro, m_bonus_cp,
    // Outputs, as the RTL's
    output       rescue_bl_n, rescue_r_n, rescue_w_n, rescue_y_n, rl_side_n, ext_car_cont, rescue_cp_n,
    output       sig_y_n, sig_bl_n, dummy_area_n, dummy_w_n, dummy_r_n, dummy_bl_n, game_over,
    output       bridge_w_n, bridge_dbu_n, bridge_y_n, bridge_r_n, bridge_bu_n, l2_side_n, r2_side_n,
    output       plus200_n,          // Pro: IC129 pin 6; high on the original board
    output [21:0] dbg
);
    wire vcc = 1'b1, gnd = 1'b0, nc = 1'bz;
    wire h0 = m_h[0], h1 = m_h[1], h2 = m_h[2], h3 = m_h[3], h4 = m_h[4], h5 = m_h[5], h6 = m_h[6], h8 = m_h[8];
    wire v0 = m_v[0], v1 = m_v[1], v2 = m_v[2], v3 = m_v[3], v4 = m_v[4], v6 = m_v[6], v7 = m_v[7], v8 = m_v[8];
    // Sheet E's inverted and carry lines, as sheet E forms them
    wire h8_n = ~h8, v4_n = ~v4, v7_n = ~v7, vca = &m_v[7:0];

    // ------------------------------------------------------------ rescue counters
    wire n42_6, n44_8, n44_6;
    wire n43_4, n43_7, n43_9, n43_12;
    rm_74157 ic43(.p1(n42_6),.p15(gnd),
        .p2(gnd),.p3(gnd),.p4(n43_4),
        .p5(vcc),.p6(gnd),.p7(n43_7),
        .p11(gnd),.p10(gnd),.p9(n43_9),
        .p14(vcc),.p13(vcc),.p12(n43_12));
    wire n36_11, n36_12, n36_13, n36_14, n36_15, n37_11, n37_12, n37_13, n37_14, n37_15;
    rm_74161 ic36(.p1(vcc),.p2(f7),.p3(n43_4),.p4(n43_7),.p5(n43_9),.p6(n43_12),.p7(vcc),.p9(n44_8),.p10(vcc),
        .p11(n36_11),.p12(n36_12),.p13(n36_13),.p14(n36_14),.p15(n36_15));
    rm_74161 ic37(.p1(vcc),.p2(f7),.p3(vcc),.p4(vcc),.p5(gnd),.p6(gnd),.p7(vcc),.p9(n44_8),.p10(n36_15),
        .p11(n37_11),.p12(n37_12),.p13(n37_13),.p14(n37_14),.p15(n37_15));
    wire n57_5, n57_6;
    rm_74107_half ic57(.j(vcc),.k(vcc),.clr_in(vcc),.ck_in(n37_15),.q(n57_5),.q_n(n57_6));   // pins 8, 11, 10, 9 -> 5, 6
    rm_nand3 ic44c(.a(n36_15),.b(n37_15),.c(n57_5),.y(n44_8));         // pins 9, 10, 11 -> 8
    rm_nand3 ic44b(.a(n57_5),.b(n37_12),.c(n37_11),.y(n44_6));         // pins 3, 4, 5 -> 6

    // ------------------------------------------------------------ rescue timing
    wire [3:0] q49;                                                     // pins 3..6
    rm_74393_half ic49(.ck_in(m_vs64),.mr_in(m_extend_n),.q(q49));      // pins 1, 2
    wire n45_8, n47_8, n42_8;
    rm_nand2 ic45(.a(q49[3]),.b(m_acce_d),.y(n45_8));                   // pins 10, 9 -> 8
    rm_and2 ic47(.a(n45_8),.b(m_vs64),.y(n47_8));                       // pins 9, 10 -> 8
    wire n35_5, n35_6, n35_9, n35_8;
    rm_7474_half ic35l(.clr_in(nc),.d(m_100c),.ck_in(n47_8),.pr_in(q49[2]),.q(n35_9),.q_n(n35_8));   // 13, 12, 11, 10 -> 9, 8
    rm_nand3 ic42c(.a(n35_8),.b(q49[1]),.c(q49[0]),.y(n42_8));          // pins 9, 10, 11 -> 8
    rm_7474_half ic35u(.clr_in(nc),.d(m_hs_n),.ck_in(n44_6),.pr_in(n42_8),.q(n35_5),.q_n(n35_6));    // 1, 2, 3, 4 -> 5, 6
    rm_nand3 ic42b(.a(vca),.b(v8),.c(n35_5),.y(n42_6));                 // pins 3, 4, 5 -> 6
    wire n18_5, n18_12, n7_4;
    rm_74123 #(.PIXELS(IC18_PIXELS)) ic18(.a(n35_9),.b(vcc),.clr_n(vcc),.f7(f7),.q(n18_5),.q_n(n18_12));  // 9, 10, 11 -> 5, 12
    rm_inv ic7(.a(n18_5),.y(n7_4));                                     // pins 3 -> 4
    assign rescue_cp_n = n7_4;
    assign ext_car_cont = q49[1];

    // ------------------------------------------------------------ rescue picture
    wire n60_12, n59_10, n10_6;
    rm_nor3 ic60(.a(m_vd[3]),.b(n35_6),.c(v4_n),.y(n60_12));            // pins 2, 1, 13 -> 12
    rm_inv ic59f(.a(n60_12),.y(n59_10));                                // pins 11 -> 10
    assign rl_side_n = n59_10;
    rm_or2 ic10b(.a(n44_6),.b(n59_10),.y(n10_6));                       // pins 5, 4 -> 6
    wire [7:0] d30;
    rm_prom #(.OFFSET(6656)) ic30(.a({m_vs4, n37_13, n37_14, n36_11, n36_12, v3, v2, v1, v0}),
        .ce1_n(gnd),.ce2_n(gnd),.ce3(vcc),.ce4(vcc),.d(d30));          // PR-138
    wire n29_4, n29_7, n29_9, n29_12;
    rm_74157 ic29(.p1(n36_13),.p15(n10_6),
        .p2(d30[0]),.p3(d30[1]),.p4(n29_4),
        .p5(d30[2]),.p6(d30[3]),.p7(n29_7),
        .p11(d30[4]),.p10(d30[5]),.p9(n29_9),
        .p14(d30[6]),.p13(d30[7]),.p12(n29_12));
    rm_inv ic22e(.a(n29_12),.y(rescue_bl_n));                          // pins 11 -> 10
    rm_inv ic22d(.a(n29_7),.y(rescue_w_n));                            // pins 9 -> 8
    rm_inv ic22f(.a(n29_4),.y(rescue_y_n));                            // pins 13 -> 12
    rm_nand2 ic16b(.a(n29_9),.b(m_vs32),.y(rescue_r_n));               // pins 5, 4 -> 6

    // ------------------------------------------------------------ signs
    wire [7:0] d51;
    rm_prom #(.OFFSET(7168)) ic51(.a({h4, h3, h2, h1, v4, v3, v2, v1, v0}),
        .ce1_n(gnd),.ce2_n(gnd),.ce3(vcc),.ce4(vcc),.d(d51));          // PR-139
    wire n50_4, n50_7, n50_9, n50_12;
    rm_74157 ic50(.p1(h0),.p15(gnd),
        .p2(d51[0]),.p3(d51[1]),.p4(n50_4),
        .p5(d51[2]),.p6(d51[3]),.p7(n50_7),
        .p11(d51[4]),.p10(d51[5]),.p9(n50_9),
        .p14(d51[6]),.p13(d51[7]),.p12(n50_12));
    wire n42_12, n73_8, n65_1, n59_8, n66_8;
    rm_nand3 ic42a(.a(h6),.b(h5),.c(h8_n),.y(n42_12));                  // pins 1, 2, 13 -> 12
    rm_nor3 ic73(.a(n42_12),.b(m_vs16),.c(m_game_n),.y(n73_8));         // pins 11, 9, 10 -> 8
    rm_nor2 ic65(.a(m_ext500_n),.b(m_vd[4]),.y(n65_1));                 // pins 2, 3 -> 1
    rm_inv ic59d(.a(m_cnc_n),.y(n59_8));                                // pins 9 -> 8
    rm_and3 ic66(.a(n59_8),.b(n73_8),.c(n65_1),.y(n66_8));              // pins 10, 9, 11 -> 8
    wire n9_3;
    rm_nand2 ic9a(.a(n50_12),.b(n66_8),.y(n9_3));                       // pins 1, 2 -> 3
    rm_nand2 ic9d(.a(n9_3),.b(n66_8),.y(sig_bl_n));                     // pins 12, 13 -> 11
    assign sig_y_n = n9_3;

    // ------------------------------------------------------------ lives and spare cars
    wire n46_3, n46_2, n46_6, n46_7, n46_12, n46_13;
    wire n39_8, n39_6, n52_3, n59_2;
    rm_or2 ic39c(.a(h5),.b(h6),.y(n39_8));                              // pins 10, 9 -> 8
    wire n53_7, n53_9;
    rm_74153 ic53(.p14(n46_3),.p2(n46_2),
        .p1(h8),.p6(gnd),.p5(h5),.p4(vcc),.p3(vcc),.p7(n53_7),
        .p15(m_vd[1]),.p10(gnd),.p11(h6),.p12(h6),.p13(n39_8),.p9(n53_9));
    wire n26_8, n59_4, n52_8;
    rm_nand4 ic26(.a(m_extend),.b(v4),.c(n53_7),.d(n53_9),.y(n26_8));   // pins 12, 13, 10, 9 -> 8
    rm_inv ic59b(.a(n26_8),.y(n59_4));                                  // pins 3 -> 4
    rm_and2 ic52c(.a(m_vs16),.b(n59_4),.y(n52_8));                      // pins 9, 10 -> 8
    rm_nand2 ic56a(.a(n52_8),.b(n50_7),.y(dummy_w_n));                  // pins 4, 5 -> 6
    rm_nand2 ic56c(.a(n52_8),.b(n50_4),.y(dummy_r_n));                  // pins 10, 9 -> 8
    rm_nand3 ic55(.a(dummy_w_n),.b(dummy_r_n),.c(n59_4),.y(dummy_bl_n)); // pins 1, 13, 2 -> 12
    assign dummy_area_n = n26_8;
    rm_and2 ic52a(.a(n46_3),.b(n46_2),.y(n52_3));                       // pins 2, 1 -> 3
    rm_or2 ic39b(.a(n52_3),.b(m_excp_n),.y(n39_6));                     // pins 4, 5 -> 6
    rm_inv ic59a(.a(m_explo),.y(n59_2));                                // pins 1 -> 2
    rm_74193 ic46(.p5(n39_6),.p4(n59_2),.p14(m_coin_n),.p11(nc),.p15(gnd),.p1(gnd),.p10(gnd),.p9(gnd),
        .p3(n46_3),.p2(n46_2),.p6(n46_6),.p7(n46_7),.p12(n46_12),.p13(n46_13));
    rm_inv ic59c(.a(n46_13),.y(game_over));                             // pins 5 -> 6

    // ------------------------------------------------------------ bridge
    wire n15_11, n10_11, n52_11;
    rm_and2 ic15a(.a(m_vd[5]),.b(m_vd[3]),.y(n15_11));                  // pins 13, 12 -> 11
    rm_or2 ic10a(.a(m_zero_n),.b(n15_11),.y(n10_11));                   // pins 13, 12 -> 11
    rm_and2 ic52d(.a(vcc),.b(v7),.y(n52_11));                           // pins 13, 12 -> 11
    wire n23_8, n23_6, n23_11, n23_3, n28_3, n28_6, n21_8;
    rm_xor2 ic23c(.a(v0),.b(n52_11),.y(n23_8));                         // pins 10, 9 -> 8
    rm_xor2 ic23b(.a(v1),.b(n52_11),.y(n23_6));                         // pins 4, 5 -> 6
    rm_xor2 ic23d(.a(v2),.b(n52_11),.y(n23_11));                        // pins 13, 12 -> 11
    rm_xor2 ic23a(.a(v3),.b(n52_11),.y(n23_3));                         // pins 1, 2 -> 3
    rm_xor2 ic28a(.a(v4),.b(n52_11),.y(n28_3));                         // pins 2, 1 -> 3
    rm_xor2 ic28b(.a(v6),.b(n52_11),.y(n28_6));                         // pins 4, 5 -> 6
    rm_and3 ic21c(.a(n28_3),.b(m_vd[2]),.c(n28_6),.y(n21_8));           // pins 11, 10, 9 -> 8
    wire [8:0] abr = {m_mh[4], m_mh[3], m_mh[2], m_mh[1], n21_8, n23_3, n23_11, n23_6, n23_8};
    tri [7:0] dbr;
    rm_prom #(.OFFSET(7680)) ic12(.a(abr),.ce1_n(gnd),.ce2_n(gnd),.ce3(n10_11),.ce4(n10_11),.d(dbr));     // PR-140
    rm_prom #(.OFFSET(8192)) ic17(.a(abr),.ce1_n(n10_11),.ce2_n(n10_11),.ce3(vcc),.ce4(vcc),.d(dbr));     // PR-141
    wire n22_2, n11_4, n11_7, n11_9, n11_12;
    rm_inv ic22a(.a(m_vd[4]),.y(n22_2));                                // pins 1 -> 2
    rm_74157 ic11(.p1(m_mh[0]),.p15(n22_2),
        .p2(dbr[0]),.p3(dbr[4]),.p4(n11_4),
        .p5(dbr[1]),.p6(dbr[5]),.p7(n11_7),
        .p11(dbr[2]),.p10(dbr[6]),.p9(n11_9),
        .p14(dbr[3]),.p13(dbr[7]),.p12(n11_12));
    wire n21_12, n16_8;
    rm_and3 ic21a(.a(m_vd[4]),.b(n26_8),.c(m_other_n),.y(n21_12));      // pins 1, 2, 13 -> 12
    rm_nand2 ic16c(.a(m_bap),.b(n21_12),.y(n16_8));                     // pins 10, 9 -> 8
    wire o6_3, o6_6, o6_7, o6_9, o6_10, o6_11;
    rm_7442 ic6(.p15(n11_4),.p14(n11_7),.p13(n11_9),.p12(n16_8),
        .p1(bridge_bu_n),.p2(bridge_r_n),.p3(bridge_y_n),.p4(o6_3),.p5(bridge_dbu_n),.p6(bridge_w_n),
        .p7(o6_7),.p9(o6_9),.p10(o6_10),.p11(o6_11));
    wire n15_8;
    rm_and2 ic15b(.a(m_ext500),.b(n11_4),.y(n15_8));                    // pins 9, 10 -> 8
    rm_nand2 ic16a(.a(n15_8),.b(n52_11),.y(l2_side_n));                 // pins 2, 1 -> 3
    rm_nand2 ic16d(.a(n15_8),.b(v7_n),.y(r2_side_n));                   // pins 13, 12 -> 11

    // ------------------------------------------------------------ +200 (Pro board)
    // Pro sheet M (manual 420-0525, PDF page 17), wired by IC and pin number
    // from pro/docs/trace/SHEET_M_C_PLUS200_TRACE.md. The parts exist only
    // with m_pro = 1; the original board has no /+200 line (read high).
    wire h7 = m_h[7];
    wire n128_8, n79_12, n124_8, n129_5, n129_6;
    wire [8:1] o130;                                                    // O1..O8, pins 1..7, 9
    rm_nor4 pro_ic128(.a(h4),.b(h5),.c(h6),.d(h7),.y(n128_8));         // pins 13, 9, 10, 12 -> 8
    rm_inv pro_ic79(.a(m_vd[4]),.y(n79_12));                           // pins 13 -> 12 (V-(4), sheet B)
    rm_nand3 pro_ic124(.a(n79_12),.b(m_bonus_cp),.c(n128_8),.y(n124_8)); // pins 11, 10, 9 -> 8
    rm_6331 pro_ic130(.p10(v0),.p11(v1),.p12(v2),.p13(v3),.p14(v4),.p15(gnd),       // PR-54
        .p1(o130[1]),.p2(o130[2]),.p3(o130[3]),.p4(o130[4]),.p5(o130[5]),.p6(o130[6]),
        .p7(o130[7]),.p9(o130[8]));
    rm_74151 pro_ic129(.p4(o130[1]),.p3(o130[2]),.p2(o130[3]),.p1(o130[4]),
        .p15(o130[5]),.p14(o130[6]),.p13(o130[7]),.p12(o130[8]),
        .p11(h1),.p10(h2),.p9(h3),.p7(n124_8),.p5(n129_5),.p6(n129_6));
    assign plus200_n = m_pro ? n129_6 : vcc;

    // Internal state, in the RTL's order
    assign dbg = {n36_11, n36_12, n36_13, n36_14, n37_11, n37_12, n37_13, n37_14, n57_5, n35_5, n35_9,
                  q49[3], q49[2], q49[1], q49[0], n46_7, n46_6, n46_2, n46_3, n18_5, n10_6, n10_11};
endmodule
