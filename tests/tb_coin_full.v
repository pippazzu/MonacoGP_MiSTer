// SPDX-License-Identifier: GPL-3.0-or-later
// tb_coin with the circuit as drawn (no capacitor scaling): a coin, a start
// and four score pulses, then 100 frames, enough for the first 555 periods
// and one full IC49 pulse (1.34 s). The tilt one-shot is shortened (C19 / 1000)
// so that the power-up pulse is short.
`timescale 1ns/1ps
module tb_coin_full;
    tb_coin #(.FAST(0),.FULL_FRAMES(100)) u();
endmodule
