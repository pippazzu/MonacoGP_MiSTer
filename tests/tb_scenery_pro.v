// SPDX-License-Identifier: GPL-3.0-or-later
// tb_scenery_fast on the Pro board (pro = 1, pro/docs/SHEETS_B_C_D_PRO_LOGIC.md):
// MH reloading a random value on every line, so that the HSB flip-flop
// turns often and Pro IC41 steps the decoder through its codes and D-TIME
// within the run; /DISPLAY high for a few frames before and in a game.
`timescale 1ns/1ps
module tb_scenery_pro;
    tb_scenery #(.FAST(1),.FRAMES(46),.SEED(32'h50524f44),.PRO(1)) u();
endmodule
