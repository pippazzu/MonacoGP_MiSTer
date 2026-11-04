// SPDX-License-Identifier: GPL-3.0-or-later
// Sheet M with IC18 as drawn (C4 1.5 uF): tb_rescue for 60 frames.
`timescale 1ns/1ps
module tb_rescue_full;
    tb_rescue #(.FAST(0),.FRAMES(60),.PIC0(1000),.NPIC(0),.SEED(32'h4d52464c)) u();
endmodule
