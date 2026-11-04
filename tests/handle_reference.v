// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected reference for the handle board 96599-P (manual
// 420-0358, PDF page 14), wired by IC and pin number from
// docs/trace/STEERING_TRACE.md. C4 is integrated in real time: every 10 ns
// its voltage moves by the exact exponential towards IC3.6's level through
// R3 (220 ohm * 1 uF), and IC1's section 9 -> 8 compares it with the 7414's
// thresholds. Levels as typical LS parts: output high 3.4 V, thresholds
// 1.7 V and 0.9 V. Gate delays only enforce settling order.
`timescale 1ns/1ps
`define HTTL(x) ((x) === 1'bz ? 1'b1 : (x))

// Half of a 74107: J, K sampled at the falling clock edge, CLR low clears.
module href_107_half(input j, k, clk_n, clr_n, output reg q = 0, output qn);
    assign qn = ~q;
    always @(negedge clk_n or negedge clr_n)
        if (!clr_n) q <= #3 0;
        else case ({`HTTL(j), `HTTL(k)})
            2'b01: q <= #3 0;
            2'b10: q <= #3 1;
            2'b11: q <= #3 ~q;
            default: ;
        endcase
endmodule
module href_nand2(input a, b, output y); assign #2 y = ~(`HTTL(a) & `HTTL(b)); endmodule
module href_inv(input a, output y);     assign #2 y = ~`HTTL(a);              endmodule

module handle_reference(
    input  a, b,                 // IC1.12, IC1.10 (sensors lit)
    output han_l_cp, han_r_cp, clr_n
);
    wire q1, q2, n3, n8, n6;
    // IC2: 1J 1 = B, 1K 4 = B, 1CK 12 = A, 1CLR 13; 2J 8 = A, 2K 11 = A,
    // 2CK 9 = B, 2CLR 10
    href_107_half ic2a(.j(b), .k(b), .clk_n(a), .clr_n(clr_n), .q(q1), .qn());
    href_107_half ic2b(.j(a), .k(a), .clk_n(b), .clr_n(clr_n), .q(q2), .qn());
    // IC3: 1, 2 -> 3; 9, 10 -> 8; 4, 5 -> 6
    href_nand2 ic3a(.a(q1), .b(b), .y(n3));
    href_nand2 ic3c(.a(a), .b(q2), .y(n8));
    href_nand2 ic3b(.a(n3), .b(n8), .y(n6));
    // IC1: 3 -> 4, 1 -> 2 (outputs)
    href_inv ic1b(.a(n3), .y(han_l_cp));
    href_inv ic1a(.a(n8), .y(han_r_cp));
    // R3, C4 and IC1 9 -> 8
    real v = 0.0, tgt;
    reg  s9 = 0;
    assign clr_n = ~s9;
    always begin
        #10;
        tgt = n6 ? 3.4 : 0.0;
        v = tgt + (v - tgt) * $exp(-10.0e-9 / 220.0e-6);
        if (v > 1.7) s9 = 1;
        else if (v < 0.9) s9 = 0;
    end
endmodule
