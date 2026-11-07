// SPDX-License-Identifier: GPL-3.0-or-later
// tb_coin on the Pro board (pro = 1): the stages of the short run
// (capacitors / 1000), with BONUS SOUND and /BONUS CP from the sheet N
// stand-in reaching pads A29 and A28 through the Pro sheet A gates
// (pro/docs/trace/SHEET_A_BONUS_TRACE.md), against the pin-wired reference.
`timescale 1ns/1ps
module tb_coin_pro;
    tb_coin #(.FAST(1),.PRO(1)) u();
endmodule
