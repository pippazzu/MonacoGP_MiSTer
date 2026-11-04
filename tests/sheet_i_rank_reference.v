// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected, event-driven reference for the high-score memory
// and ranking of sheet I (manual 420-0358, PDF page 23), wired by IC and pin
// number from docs/trace/SHEET_I_TRACE.md ("Memory and ranking"): 11A, 12A,
// 13A, 13F, 2E, 2H, 11B, 11C, 11D, 13D, 12B, 12C, 12D, 12F, J2, 9F, the
// 2111s 10F/11F/11E/11H, the 8216s 6E..3E, 7H..10H (74192), 6H..3H and
// 6F..3F (7485), 10A, 14H (74259), 10B..10D (74390), 12E, 13E (74279) and
// the RST inverter. The score P comes in as an input (the score counter's
// reference is tests/sheet_i_score_reference.v). Delays only enforce
// settling order (gates 0.5 ns, flip-flops and counters 1 ns per stage, all
// settled well inside one 14 MHz half period); they are NOT measured TTL
// delays. Unconnected TTL inputs read high (`RTTL`).
//
// DOWN_INV = 1 puts an inverter between 12D pin 6 and 7H pin 4 (the
// correction described in jtmonacogp_rank.v); 0 is the drawing.
`timescale 1ns/1ps
`define RTTL(x) ((x) === 1'bz ? 1'b1 : (x))

// half 74393: 4-bit binary, counts on CP falling, MR high clears
module rref_393_half(input cp, mr, output qa, qb, qc, qd);
    reg a=0, b=0, c=0, d=0;
    always @(negedge cp or posedge mr) if (mr) a <= #0.5 0; else a <= #1 ~a;
    always @(negedge a  or posedge mr) if (mr) b <= #0.5 0; else b <= #1 ~b;
    always @(negedge b  or posedge mr) if (mr) c <= #0.5 0; else c <= #1 ~c;
    always @(negedge c  or posedge mr) if (mr) d <= #0.5 0; else d <= #1 ~d;
    assign {qa, qb, qc, qd} = {a, b, c, d};
endmodule
// half 74390: QA toggles on CPA falling; QB..QD divide by 5 on CPB falling
module rref_390_half(input cpa, cpb, mr, output reg qa=0, output qb, qc, qd);
    reg [2:0] q5 = 0;
    always @(negedge cpa or posedge mr) if (mr) qa <= #0.5 0; else qa <= #1 ~qa;
    always @(negedge cpb or posedge mr) if (mr) q5 <= #0.5 0; else q5 <= #1 (q5 == 3'd4 ? 3'd0 : q5 + 3'd1);
    assign {qd, qc, qb} = q5;
endmodule
// 74259 addressable latch: /CL low and /E low = demultiplexer, /CL low and
// /E high = clear, /CL high and /E low = addressed latch, both high = hold
module rref_259(input a, b, c, d, e_n, cl_n, output reg [7:0] q = 0);
    wire [2:0] s = {`RTTL(c), `RTTL(b), `RTTL(a)};
    always @* begin
        case ({`RTTL(cl_n), `RTTL(e_n)})
        2'b00: begin q <= #0.5 8'd0; q[s] <= #0.5 `RTTL(d); end
        2'b01: q <= #0.5 8'd0;
        2'b10: q[s] <= #0.5 `RTTL(d);
        default: ;
        endcase
    end
endmodule
// 7442 BCD-to-decimal: output n (active low) for input n = DCBA
module rref_7442(input a, b, c, d, output [9:0] y_n);
    wire [3:0] s = {`RTTL(d), `RTTL(c), `RTTL(b), `RTTL(a)};
    assign #0.5 y_n = ~(10'd1 << s);    // 10..15: all high
endmodule
// 74107 J-K flip-flop, negative-edge clocked, clear active low
module rref_107(input j, k, ck, cl_n, output reg q = 0, output q_n);
    always @(negedge ck or negedge cl_n)
        if (!cl_n) q <= #0.5 0;
        else case ({`RTTL(j), `RTTL(k)})
            2'b10: q <= #0.5 1;
            2'b01: q <= #0.5 0;
            2'b11: q <= #1 ~q;
            default: ;
        endcase
    assign q_n = ~q;
endmodule
// 74192 BCD up/down counter: counts down on DOWN rising (UP high), up on UP
// rising (DOWN high); /LOAD low loads A..D; CLR high clears.
// /BO low while DOWN is low at 0, /CO low while UP is low at 9.
module rref_192(input up, down, load_n, clr, input [3:0] din, output reg [3:0] q = 4'd9,
                output bo_n, co_n);
    wire dn = `RTTL(down), upp = `RTTL(up), ld = `RTTL(load_n), cl = `RTTL(clr);
    always @(posedge dn) if (!cl && ld && upp) q <= #1 (q == 4'd0 ? 4'd9 : q - 4'd1);
    always @(posedge upp) if (!cl && ld && dn) q <= #1 (q == 4'd9 ? 4'd0 : q + 4'd1);
    always @* if (cl) q <= #1 4'd0; else if (!ld) q <= #1 din;
    assign #0.5 bo_n = ~(!dn && q == 4'd0);
    assign #0.5 co_n = ~(!upp && q == 4'd9);
endmodule
// 7485 4-bit magnitude comparator with cascade inputs
module rref_7485(input [3:0] a, b, input i_gt, i_eq, i_lt, output o_gt, o_eq, o_lt);
    wire gt = `RTTL(i_gt), eq = `RTTL(i_eq), lt = `RTTL(i_lt);
    wire [3:0] aa = {`RTTL(a[3]), `RTTL(a[2]), `RTTL(a[1]), `RTTL(a[0])};
    wire [3:0] bb = {`RTTL(b[3]), `RTTL(b[2]), `RTTL(b[1]), `RTTL(b[0])};
    assign #0.5 o_gt = aa > bb || (aa == bb && !eq && !lt);
    assign #0.5 o_lt = aa < bb || (aa == bb && !eq && !gt);
    assign #0.5 o_eq = aa == bb && eq;
endmodule
// 2111 256 x 4 static RAM, common I/O: written while R/W is low and both
// chip enables are low; drives the I/O lines while reading with OD low
module rref_2111(input [7:0] a, input rw, od, ce1_n, ce2_n, inout [3:0] io);
    reg [3:0] mem [0:255];
    integer k;
    initial for (k = 0; k < 256; k = k + 1) mem[k] = 4'd0;
    wire sel = !`RTTL(ce1_n) && !`RTTL(ce2_n);
    always @* if (sel && rw === 1'b0) mem[a] = io;
    assign #0.5 io = (sel && `RTTL(rw) && !`RTTL(od)) ? mem[a] : 4'bzzzz;
endmodule
// 8216 4-bit bidirectional bus driver: /DIEN low drives DB from DI, high
// drives DO from DB; /CS high turns both off
module rref_8216(input [3:0] di, inout [3:0] db, output [3:0] dout, input dien_n, cs_n);
    wire on = !`RTTL(cs_n);
    wire [3:0] dbi = {`RTTL(db[3]), `RTTL(db[2]), `RTTL(db[1]), `RTTL(db[0])};
    assign #0.5 db   = (on && !`RTTL(dien_n)) ? di : 4'bzzzz;
    assign #0.5 dout = (on &&  `RTTL(dien_n)) ? dbi : 4'bzzzz;
endmodule
// 74279 S-R latch section with one /S: /S low sets, else /R low resets
module rref_279(input s_n, r_n, output reg q = 0);
    always @* if (!`RTTL(s_n)) q <= #0.5 1; else if (!`RTTL(r_n)) q <= #0.5 0;
endmodule
module rref_nor2(input a, b, output y); assign #0.5 y = ~(`RTTL(a) | `RTTL(b)); endmodule
module rref_and2(input a, b, output y); assign #0.5 y = `RTTL(a) & `RTTL(b);    endmodule
module rref_or2 (input a, b, output y); assign #0.5 y = `RTTL(a) | `RTTL(b);    endmodule
module rref_nand2(input a, b, output y); assign #0.5 y = ~(`RTTL(a) & `RTTL(b)); endmodule
module rref_inv (input a, output y);    assign #0.5 y = ~`RTTL(a);              endmodule

module sheet_i_rank_reference #(parameter integer DOWN_INV = 1)(
    input         osc14,                       // (E) 14 MHz, pad a
    input         h5, v2, vs16, game, coin_test_n, ini_reset_n,
    input  [15:0] p,                           // {P-4 .. P-1}
    output [15:0] d,                           // {D-4 .. D-1}
    output  [4:0] rank_ck,                     // 1ST..5TH
    output        latch_cl,
    output [11:0] n, r,
    output  [5:1] flash,
    output        searching
);
    wire vcc = 1'b1, gnd = 1'b0, open = 1'bz;
    // ------------------------------------------------ reset and power-up
    wire rst_t, rst_n, ini;
    rref_nand2 h13b(.a(coin_test_n), .b(ini_reset_n), .y(rst_t));    // 13H (OR body, bubbles)
    rref_inv   irst(.a(rst_t), .y(rst_n));                           // 04 at (2210,4285)
    rref_inv   a13a(.a(ini_reset_n), .y(ini));                       // 13A 11 -> 10
    wire c12b_ck, c12b_qd;
    rref_nor2  e2(.a(c12b_qd), .b(v2), .y(c12b_ck));                 // 2E 3, 2 -> 1
    rref_393_half c12b(.cp(c12b_ck), .mr(ini), .qa(), .qb(), .qc(), .qd(c12b_qd));   // 12C 13, 12 / 8
    wire pwr;
    rref_inv   d11a(.a(c12b_qd), .y(pwr));                           // 11D 5 -> 6 (left)
    assign latch_cl = pwr;
    // ------------------------------------------------ end-of-game sequencer
    wire mr11a, b11_11, ck11a, a_qa, a_qb, a_qc, a_qd, a13_8;
    rref_and2  h2(.a(ini_reset_n), .b(game), .y(mr11a));             // 2H 10, 9 -> 8
    rref_and2  b11c(.a(a_qd), .b(ini_reset_n), .y(b11_11));          // 11B 12, 13 -> 11
    rref_nor2  f13a(.a(b11_11), .b(h5), .y(ck11a));                  // 13F 3, 2 -> 1
    rref_390_half a11a(.cpa(ck11a), .cpb(a_qa), .mr(mr11a), .qa(a_qa), .qb(a_qb), .qc(a_qc), .qd(a_qd));
    rref_inv   a13b(.a(a_qa), .y(a13_8));                            // 13A 9 -> 8
    wire [9:0] y12a;
    rref_7442  a12(.a(a_qb), .b(a_qc), .c(a_qd), .d(a13_8), .y_n(y12a));   // 15, 14, 13, 12
    wire adr_inc, f13_4, dien_n, od;
    wire ld192_n = y12a[1], rw = y12a[2];
    rref_inv   d13a(.a(y12a[0]), .y(adr_inc));                       // 13D 5 -> 6
    rref_nor2  f13b(.a(y12a[3]), .b(pwr), .y(f13_4));                // 13F 5, 6 -> 4
    rref_inv   d11b(.a(a_qc), .y(dien_n));                           // 11D 5 -> 6 (right)
    rref_inv   d13b(.a(rw), .y(od));                                 // 13D (RAM OD)
    // ------------------------------------------------ search clock
    wire q12b_n, ck12c, c_qa, c_qb, c_qc, d_qd2, d_qd1, ck11c3, bo_n, d13_8;
    rref_nor2  f12(.a(q12b_n), .b(osc14), .y(ck12c));                // 12F 5, 6 -> 4
    rref_393_half c12a(.cp(ck12c), .mr(rst_t), .qa(c_qa), .qb(c_qb), .qc(c_qc), .qd());
    rref_393_half d12b(.cp(c_qc), .mr(rst_t), .qa(), .qb(), .qc(), .qd(d_qd2));       // 13 / 12 / 8
    rref_393_half d12a(.cp(d_qd2), .mr(rst_t), .qa(), .qb(), .qc(), .qd(d_qd1));      // 1 / 2 / 6
    rref_inv   d13c(.a(bo_n), .y(d13_8));                            // 13D 9 -> 8
    rref_or2   c11b(.a(f13_4), .b(d13_8), .y(ck11c3));               // 11C 1, 2 -> 3
    rref_107   b12a(.j(vcc), .k(vcc), .ck(ck11c3), .cl_n(rst_n), .q(searching), .q_n(q12b_n));
    wire [7:0] j2;
    rref_259   j2l(.a(c_qb), .b(c_qc), .c(gnd), .d(c_qa), .e_n(gnd), .cl_n(gnd), .q(j2));
    // ------------------------------------------------ memory
    wire ck9f;
    wire [7:0] adr;
    rref_or2   c11a(.a(c_qc), .b(adr_inc), .y(ck9f));                // 11C 4, 5 -> 6
    rref_393_half f9a(.cp(ck9f),   .mr(gnd), .qa(adr[0]), .qb(adr[1]), .qc(adr[2]), .qd(adr[3]));
    rref_393_half f9b(.cp(adr[3]), .mr(gnd), .qa(adr[4]), .qb(adr[5]), .qc(adr[6]), .qd(adr[7]));
    wire [15:0] db;
    genvar g;
    generate for (g = 0; g < 4; g = g + 1) begin : digit
        // 2111 (10F, 11F, 11E, 11H) and 8216 (6E, 5E, 4E, 3E) for digit g+1
        rref_2111 ram(.a(adr), .rw(rw), .od(od), .ce1_n(gnd), .ce2_n(gnd), .io(db[4*g +: 4]));
        rref_8216 drv(.di(p[4*g +: 4]), .db(db[4*g +: 4]), .dout(d[4*g +: 4]), .dien_n(dien_n), .cs_n(gnd));
    end endgenerate
    // ------------------------------------------------ the down-counter 7H..10H
    wire down;
    generate if (DOWN_INV) begin : g_inv
        rref_inv dinv(.a(d_qd1), .y(down));
    end else begin : g_drawn
        assign down = d_qd1;
    end endgenerate
    wire [15:0] cnt;
    wire [3:0] bo;
    rref_192 h7 (.up(open), .down(down),  .load_n(ld192_n), .clr(gnd), .din(4'd9), .q(cnt[3:0]),   .bo_n(bo[0]), .co_n());
    rref_192 h8 (.up(open), .down(bo[0]), .load_n(ld192_n), .clr(gnd), .din(4'd9), .q(cnt[7:4]),   .bo_n(bo[1]), .co_n());
    rref_192 h9 (.up(open), .down(bo[1]), .load_n(ld192_n), .clr(gnd), .din(4'd9), .q(cnt[11:8]),  .bo_n(bo[2]), .co_n());
    rref_192 h10(.up(open), .down(bo[2]), .load_n(ld192_n), .clr(gnd), .din(4'd9), .q(cnt[15:12]), .bo_n(bo[3]), .co_n());
    assign bo_n = bo[3];
    // ------------------------------------------------ comparisons
    wire [4:0] eq_h, eq_f;
    assign eq_h[0] = j2[3];                                          // 6H 3 = J2 7 (Q3)
    assign eq_f[0] = j2[2];                                          // 6F 3 = J2 6 (Q2)
    generate for (g = 0; g < 4; g = g + 1) begin : cmp
        // 6H, 5H, 4H, 3H: A = P-(g+1), B = 7H..10H
        rref_7485 hh(.a(p[4*g +: 4]), .b(cnt[4*g +: 4]), .i_gt(open), .i_eq(eq_h[g]), .i_lt(open),
                     .o_gt(), .o_eq(eq_h[g+1]), .o_lt());
        // 6F, 5F, 4F, 3F: A = D-(g+1), B = 7H..10H
        rref_7485 ff(.a(d[4*g +: 4]), .b(cnt[4*g +: 4]), .i_gt(open), .i_eq(eq_f[g]), .i_lt(open),
                     .o_gt(), .o_eq(eq_f[g+1]), .o_lt());
    end endgenerate
    wire own = eq_h[4], match = eq_f[4];
    wire found, f_n;                                                 // 12B second half: Q 5, /Q 6
    rref_107   b12b(.j(vcc), .k(gnd), .ck(own), .cl_n(rst_n), .q(found), .q_n(f_n));
    // ------------------------------------------------ rank counter and K clocks
    wire r_qa, r_qb, r_qc, r_qd, d11_10, rp, mr2;
    rref_inv   d11c(.a(r_qd), .y(d11_10));                           // 11D 11 -> 10
    rref_and2  b11b(.a(d11_10), .b(match), .y(rp));                  // 11B 4, 5 -> 6
    rref_inv   d13d(.a(rst_n), .y(mr2));                             // 13D 1 -> 2
    rref_390_half a11b(.cpa(rp), .cpb(r_qa), .mr(mr2), .qa(r_qa), .qb(r_qb), .qc(r_qc), .qd(r_qd));
    wire [7:0] q10a;
    rref_259   a10(.a(r_qa), .b(r_qb), .c(r_qc), .d(rp), .e_n(gnd), .cl_n(gnd), .q(q10a));
    assign rank_ck = q10a[4:0];                                      // 4, 5, 6, 7, 9
    // ------------------------------------------------ R and N (10B, 10C, 10D)
    wire rr;
    rref_and2  b11a(.a(match), .b(f_n), .y(rr));                     // 11B 9, 10 -> 8
    rref_390_half r1(.cpa(rr),    .cpb(r[0]), .mr(mr2), .qa(r[0]), .qb(r[1]), .qc(r[2]),  .qd(r[3]));
    rref_390_half r2(.cpa(r[3]),  .cpb(r[4]), .mr(mr2), .qa(r[4]), .qb(r[5]), .qc(r[6]),  .qd(r[7]));
    rref_390_half r3(.cpa(r[7]),  .cpb(r[8]), .mr(mr2), .qa(r[8]), .qb(r[9]), .qc(r[10]), .qd(r[11]));
    rref_390_half n1(.cpa(f13_4), .cpb(n[0]), .mr(pwr), .qa(n[0]), .qb(n[1]), .qc(n[2]),  .qd(n[3]));
    rref_390_half n2(.cpa(n[3]),  .cpb(n[4]), .mr(pwr), .qa(n[4]), .qb(n[5]), .qc(n[6]),  .qd(n[7]));
    rref_390_half n3(.cpa(n[7]),  .cpb(n[8]), .mr(pwr), .qa(n[8]), .qb(n[9]), .qc(n[10]), .qd(n[11]));
    // ------------------------------------------------ flash (14H)
    wire f13_12, e13q, d14;
    rref_inv   f13c(.a(r[3]), .y(f13_12));                           // "13F" 13 -> 12 (04)
    rref_279   e13(.s_n(f13_12), .r_n(rst_n), .q(e13q));             // 13E 2 / 1 / 4
    rref_nor2  e12(.a(f_n), .b(vs16), .y(d14));                      // 12E 12, 11 -> 13
    wire [7:0] q14h;
    rref_259   h14(.a(r[0]), .b(r[1]), .c(r[2]), .d(d14), .e_n(e13q), .cl_n(r_qd), .q(q14h));
    assign flash = q14h[5:1];                                        // 5, 6, 7, 9, 10
endmodule
