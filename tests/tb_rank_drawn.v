// SPDX-License-Identifier: GPL-3.0-or-later
// tb_rank with 7H's DOWN clock as drawn (12D's QD, DOWN_INV = 0): three
// games. The ranks and N are checked; R (the number of stored scores above
// the new one, as drawn) is reported, not checked.
`timescale 1ns/1ps
module tb_rank_drawn;
    tb_rank #(.DOWN_INV(0),.GAMES(3)) u();
endmodule
