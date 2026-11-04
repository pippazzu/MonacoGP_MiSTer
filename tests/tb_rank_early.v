// SPDX-License-Identifier: GPL-3.0-or-later
// tb_rank with three games, the third coin coming in the middle of the
// search after the third game (RST ends the search).
`timescale 1ns/1ps
module tb_rank_early;
    tb_rank #(.COIN_EARLY(1),.GAMES(3)) u();
endmodule
