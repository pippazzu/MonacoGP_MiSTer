// SPDX-License-Identifier: GPL-3.0-or-later
// tb_scenery with IC66 read as a NAND, the other reading of the scan (see the
// trace): the comparison with the reference, and four pictures to set beside
// those of the AND reading.
`timescale 1ns/1ps
module tb_scenery_ic66nand;
    tb_scenery #(.IC66_NAND(1),.FRAMES(26),.PIC0(20)) u();
endmodule
