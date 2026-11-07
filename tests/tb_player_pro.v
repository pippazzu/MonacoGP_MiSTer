// SPDX-License-Identifier: GPL-3.0-or-later
// tb_player on the Pro board (pro = 1): the same stimulus and checks, with
// PLAYER ST, the Pro sheet G gate to sheet N (IC31 = AND(HWIN, HC4),
// pro/docs/trace/BONUS_INPUTS_TRACE.md), against the pin-wired reference.
`timescale 1ns/1fs
module tb_player_pro;
    tb_player #(.PRO(1)) u();
endmodule
