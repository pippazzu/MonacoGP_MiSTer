// SPDX-License-Identifier: GPL-3.0-or-later
// tb_colour on the Pro board (pro = 1): the same random lines, with /+200
// from the sheet M stand-in reaching the red collector
// (pro/docs/trace/SHEET_M_C_PLUS200_TRACE.md), against the pin-wired
// reference.
`timescale 1ns/1ps
module tb_colour_pro;
    tb_colour #(.PRO(1)) u();
endmodule
