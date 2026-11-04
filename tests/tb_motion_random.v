// SPDX-License-Identifier: GPL-3.0-or-later
// Full-length companion of tb_motion: eight frames with VSEL high, then
// random inputs from sheets A, D and H, changing at frame starts and at
// random pixels. It runs apart from tb_motion so that each simulation stays
// well under an hour.
`timescale 1ns/1ps
module tb_motion_random;
    tb_motion #(.TEXT_FRAMES(0),.MOVE_FRAMES(0),.STILL_FRAMES(8),.RANDOM_FRAMES(110)) u();
endmodule
