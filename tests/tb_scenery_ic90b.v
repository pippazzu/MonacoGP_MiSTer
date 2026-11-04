// SPDX-License-Identifier: GPL-3.0-or-later
// tb_scenery, fast stimulus, with IC90 read as two AND sections (a 7421)
// instead of a 7425 (see the trace).
`timescale 1ns/1ps
module tb_scenery_ic90b;
    tb_scenery #(.FAST(1),.FRAMES(12),.IC90_TYPE(2),.SEED(32'h4d4f4e48)) u();
endmodule
