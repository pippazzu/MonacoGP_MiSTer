// SPDX-License-Identifier: GPL-3.0-or-later
// tb_rank on the Pro board (PRO = 1): sheets I and K of manual 420-0525
// against the pin-wired references switched to Pro. /GAME END stands in for
// sheet N. Scores over 9999 light the 10,000-point lamp, are neither stored
// nor ranked, and SUPER RACER SCORE keeps the best of them (67.5 = P >= S,
// as read); RAM RESET clears the memory and SUPER RACER SCORE; neither it
// nor /INI. RESET clears the rank latches; power-up writes nothing.
`timescale 1ns/1ps
module tb_rank_pro;
    tb_rank #(.PRO(1)) u();
endmodule
