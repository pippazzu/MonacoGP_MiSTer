// SPDX-License-Identifier: GPL-3.0-or-later
// tb_score on the Pro board (PRO = 1): the score counter without the 9999
// stop, wrapping to 0000, and cleared by RAM RESET as well, against the
// pin-wired reference switched to Pro (manual 420-0525, sheet I).
`timescale 1ns/1ps
module tb_score_pro;
    tb_score #(.PRO(1)) u();
endmodule
