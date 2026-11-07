// SPDX-License-Identifier: GPL-3.0-or-later
// tb_rank_pro with sheet K's other reading of 44's cascade inputs (K-U1):
// 67.5 = P > S (SRS_GE = 0), so an equal score over 9999 does not clock
// SUPER RACER SCORE again.
`timescale 1ns/1ps
module tb_rank_pro_gt;
    tb_rank #(.PRO(1),.SRS_GE(0)) u();
endmodule
