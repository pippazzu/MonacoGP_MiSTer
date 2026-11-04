// SPDX-License-Identifier: GPL-3.0-or-later
// Short companion of tb_control: one-shot capacitors divided by 1000 and the
// Vs/n lines taken from the line counter. It supplements the full-length run,
// it does not replace it.
`timescale 1ns/1ps
module tb_control_fast;
    tb_control #(.FAST(1),.FRAMES(30),.FIRST_STAGE(0),.LAST_STAGE(3)) u();
endmodule
