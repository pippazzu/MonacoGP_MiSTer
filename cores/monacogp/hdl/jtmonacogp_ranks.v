// SPDX-License-Identifier: GPL-3.0-or-later
// 96597-P sheet K (manual 420-0358, PDF page 24): the five rank latches.
// docs/trace/SHEET_K_TRACE.md. Each rank 1ST..5TH is three 74174s (16 of
// their 18 flip-flops) that take sheet I's D bus {D-4 .. D-1} on the rising
// edge of that rank's line from sheet I (10A); LATCH CL. clears all fifteen
// through 11D's two inverters.
//
// Timing: the rank lines come from jtmonacogp_rank.v's register, and the
// D bus with them; a rising edge is taken at the next host clock, while the
// D bus still shows the value it had at the edge (it changes at the earliest
// two 14 MHz enables later).
module jtmonacogp_ranks(
    input             clk, rst,
    input      [15:0] d,              // D bus {D-4 .. D-1}
    input       [4:0] ck,             // 1ST..5TH
    input             latch_cl,       // LATCH CL.
    output reg [79:0] q               // {5TH, 4TH, 3RD, 2ND, 1ST}, each {-4 .. -1}
);
    reg [4:0] ck_l;
    integer k;
    always @(posedge clk) begin
        if (rst) begin
            q <= 0; ck_l <= 0;
        end else begin
            ck_l <= ck;
            if (latch_cl) q <= 0;                       // 11D 1 -> 2, 3 -> 4: /MR low
            else for (k = 0; k < 5; k = k + 1)
                if (ck[k] && !ck_l[k]) q[16*k +: 16] <= d;
        end
    end
endmodule
