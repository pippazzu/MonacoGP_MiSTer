// SPDX-License-Identifier: GPL-3.0-or-later
// tb_rescue on the Pro board (pro = 1): IC18's capacitor / 1000 for 30
// frames, with BONUS CP from the sheet N stand-in opening the +200 window
// (pro/docs/trace/SHEET_M_C_PLUS200_TRACE.md), against the pin-wired
// reference.
`timescale 1ns/1ps
module tb_rescue_pro;
    tb_rescue #(.FAST(1),.PRO(1)) u();
endmodule
