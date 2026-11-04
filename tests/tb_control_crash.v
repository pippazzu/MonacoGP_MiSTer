// SPDX-License-Identifier: GPL-3.0-or-later
// Full-length companion of tb_control: the circuit as drawn, starting with
// the crash stage (a collision with EXPLO. ST., the return to the start
// position and the end of the explosion), then random play. It runs apart
// from tb_control so that each simulation stays well under an hour.
`timescale 1ns/1ps
module tb_control_crash;
    tb_control #(.FAST(0),.FRAMES(40),.FIRST_STAGE(3),.LAST_STAGE(3)) u();
endmodule
