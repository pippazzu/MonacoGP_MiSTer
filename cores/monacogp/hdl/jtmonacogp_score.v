// SPDX-License-Identifier: GPL-3.0-or-later
// 96597-P sheet I (manual 420-0358, PDF page 23): the score counter and the
// lines it gives the game logic. Pin-level reading:
// docs/trace/SHEET_I_TRACE.md (the high-score memory, comparators and
// rank logic on the same sheet are not in this module yet).
//
// - 7F, 8F (74390): four BCD decades P-1 (units) .. P-4 (thousands),
//   counting falling edges of 13H.11 = NAND(/SCORE CP, 12F.8);
// - 12F (7430) = NAND of bits A and D of every digit: low at 9999, which
//   blocks the clock, so the score stops at 9999;
// - RST = NAND(/COIN&TEST, /INI.RESET) (13H) clears the counters;
// - 2E-1 (open collector, pulled up on the receiving boards), taken as
//   NON-inverting buffers: the triangles have no bubbles, though "16"
//   (7416, inverting) is printed above them on both scans. As buffers the
//   S-100 code gives sheet D's decoder exactly the owner's zone table
//   (pools x185/x685, slip 295, bridge 595, tunnel 795, gravel 095) and
//   S-100-D' gives sheet A an extend every 2000 (recordings from several
//   machines, the net name "8000"); as inverters neither fits.
//   S-100-A/B/C = P-3A/B/C, S-100-D = P-3D OR NOT P-2C (11C, 11D),
//   S-100-D' = P-3D;
// - 13E (74279) latch 4: /S = 13H.6 = NAND(P-4B, P-4C), /R = NOT RST;
//   Q = SP. CONT.: set at 6000 points, cleared by RST.
//
// Timing: the inputs are taken at the pixel enable, as the other sheets give
// them. The counters step at the enable after the gated clock falls, and
// the outputs follow at once. The 74390 ripple and the 470 pF on 13E's /S
// are not reproduced.
module jtmonacogp_score(
    input             clk, rst,
    input             pxl_cen,
    input             score_cp_n,     // /SCORE CP (F), pad 23
    input             coin_test_n,    // /COIN & TEST (A), pad b
    input             ini_reset_n,    // /INI. RESET (A), pad 24
    output     [15:0] digits,         // {P-4, P-3, P-2, P-1} D..A
    output      [3:0] s100,           // line levels {S-100-D, -C, -B, -A}
    output            s100_d2,        // line level S-100-D' (to A, pad A30)
    output            sp_cont         // SP. CONT. (to H), 13E pin 13
);
    reg  [3:0] p1, p2, p3, p4;
    reg        g_l, q13e;
    wire       rst_t   = ~(coin_test_n & ini_reset_n);              // 13H
    wire       n9999   = ~(p1[0] & p1[3] & p2[0] & p2[3] & p3[0] & p3[3] & p4[0] & p4[3]); // 12F
    wire       g       = ~(score_cp_n & n9999);                      // 13H.11
    wire       s13e_n  = ~(p4[1] & p4[2]);                           // 13H.6
    assign digits  = {p4, p3, p2, p1};
    assign s100    = {p3[3] | ~p2[2], p3[2], p3[1], p3[0]};
    assign s100_d2 = p3[3];
    // 74279: /S low drives Q high, otherwise /R low drives it low
    assign sp_cont = !s13e_n ? 1'b1 : rst_t ? 1'b0 : q13e;

    function [3:0] inc(input [3:0] d);
        inc = d == 4'd9 ? 4'd0 : d + 4'd1;
    endfunction

    always @(posedge clk) begin
        if (rst) begin
            {p1, p2, p3, p4} <= 0;
            g_l  <= 1;
            q13e <= 0;
        end else if (pxl_cen) begin
            q13e <= sp_cont;
            if (rst_t) begin
                // The clear also reopens 12F; any edge of the gated clock
                // while it lasts is lost, so the next one is judged from
                // the cleared state.
                {p1, p2, p3, p4} <= 0;
                g_l <= ~score_cp_n;
            end else if (g_l && !g) begin
                g_l <= g;
                // each decade's QD falling clocks the next
                p1 <= inc(p1);
                if (p1 == 4'd9) begin
                    p2 <= inc(p2);
                    if (p2 == 4'd9) begin
                        p3 <= inc(p3);
                        if (p3 == 4'd9) p4 <= inc(p4);
                    end
                end
            end else begin
                g_l <= g;
            end
        end
    end
endmodule
