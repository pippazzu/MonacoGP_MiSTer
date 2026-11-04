// SPDX-License-Identifier: GPL-3.0-or-later
// tb_cars with the one-shots as drawn (no capacitor scaling), for 200 frames:
// IC121's 1.34 s and IC120's 2.94 s pulses at full length.
`timescale 1ns/1ps
module tb_cars_full;
    tb_cars #(.FAST(0),.FRAMES(200),.PIC0(1000),.SEED(32'h4d4f4e49)) u();
endmodule
