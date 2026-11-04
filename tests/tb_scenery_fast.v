// SPDX-License-Identifier: GPL-3.0-or-later
// tb_scenery with MH reloading a random value on every line, so that IC40's
// lower half turns every few dozen lines and IC49 runs through its count: the
// POOL sequence (IC38) and the IC49 clear are reached within the run.
`timescale 1ns/1ps
module tb_scenery_fast;
    tb_scenery #(.FAST(1),.FRAMES(40),.SEED(32'h4d4f4e45)) u();
endmodule
