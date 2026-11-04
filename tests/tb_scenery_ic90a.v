// SPDX-License-Identifier: GPL-3.0-or-later
// tb_scenery, fast stimulus, with IC90 read as the drawing as it stands (one AND section, one NOR section)
// instead of a 7425 (see the trace).
`timescale 1ns/1ps
module tb_scenery_ic90a;
    tb_scenery #(.FAST(1),.FRAMES(12),.IC90_TYPE(0),.SEED(32'h4d4f4e46)) u();
endmodule
