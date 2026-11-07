// SPDX-License-Identifier: GPL-3.0-or-later
// tb_motion on the Pro board (pro = 1, pro/docs/SHEETS_B_C_D_PRO_LOGIC.md):
// the display timer IC72 (IC72a read as dividing, the default reading),
// IC70 and the IC29 speed selector against the pin-wired reference, with
// random inputs from sheets A, D and H for 4 still frames and 56 random
// ones.
`timescale 1ns/1ps
module tb_motion_pro;
    tb_motion #(.TEXT_FRAMES(0),.MOVE_FRAMES(0),.STILL_FRAMES(4),.RANDOM_FRAMES(56),.PRO(1)) u();
endmodule
