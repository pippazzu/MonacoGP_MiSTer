// SPDX-License-Identifier: GPL-3.0-or-later
// tb_control on the Pro board (pro = 1), as the short run of tb_control_fast
// (one-shot capacitors / 1000, Vs/n from the line counter): /BONUS POINT
// pulses from the sheet N stand-in reach /SCORE CP through the Pro sheet F
// gate (pro/docs/trace/SHEET_F_BONUS_TRACE.md), against the pin-wired
// reference.
`timescale 1ns/1ps
module tb_control_pro;
    tb_control #(.FAST(1),.FRAMES(30),.FIRST_STAGE(0),.LAST_STAGE(3),.PRO(1)) u();
endmodule
