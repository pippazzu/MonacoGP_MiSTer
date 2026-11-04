// SPDX-License-Identifier: GPL-3.0-or-later
// The high scores' NVRAM file through JTFRAME's own modules, wired as the memory
// generator wires mem.yaml's "score" and "scoreptr": 514 bytes restored from
// the file reach the memories (low byte first, the address at byte 512), the
// game's ports work again afterwards, and a save reads the same bytes back.
`timescale 1ns/1ps
module tb_score_ioctl;
    reg clk = 0;
    always #5 clk = ~clk;
    reg ioctl_ram = 0, ioctl_wr = 0;
    reg [23:0] ioctl_addr = 0;
    reg [7:0] ioctl_dout = 0;
    wire [7:0] ioctl_din;

    reg  [8:1] score_addr = 0;
    reg  [15:0] score_din = 0;
    reg  [1:0] score_we = 0;
    wire [15:0] score_dout, score_dimx;
    wire [1:0] score_wemx;
    wire [8:1] score_amux;
    reg  ptr_addr = 0, ptr_we = 0;
    reg  [7:0] ptr_din = 0;
    wire [7:0] ptr_dout, ptr_dimx;
    wire [0:0] ptr_wemx;
    wire [0:0] ptr_amux;

    jtframe_ram16 #(.AW(8)) u_score(.clk(clk),.addr(score_amux),.data(score_dimx),.we(score_wemx),.q(score_dout));
    jtframe_ram #(.DW(8),.AW(1)) u_ptr(.clk(clk),.cen(1'b1),.addr(ptr_amux),.data(ptr_dimx),.we(ptr_wemx[0]),.q(ptr_dout));
    jtframe_ioctl_dump #(.DW0(16),.AW0(9),.DW1(8),.AW1(1),.DW2(8),.AW2(0),.DW3(8),.AW3(0),.DW4(8),.AW4(0),.DW5(8),.AW5(0)) u_dump(
        .clk(clk),
        .dout0(score_dout),.addr0(score_addr),.addr0_mx(score_amux),.din0(score_din),.din0_mx(score_dimx),.we0(score_we),.we0_mx(score_wemx),
        .dout1(ptr_dout),.addr1(ptr_addr),.addr1_mx(ptr_amux),.din1(ptr_din),.din1_mx(ptr_dimx),.we1(ptr_we),.we1_mx(ptr_wemx),
        .dout2(8'd0),.addr2(1'b0),.addr2_mx(),.din2(8'd0),.din2_mx(),.we2(1'b0),.we2_mx(),
        .dout3(8'd0),.addr3(1'b0),.addr3_mx(),.din3(8'd0),.din3_mx(),.we3(1'b0),.we3_mx(),
        .dout4(8'd0),.addr4(1'b0),.addr4_mx(),.din4(8'd0),.din4_mx(),.we4(1'b0),.we4_mx(),
        .dout5(8'd0),.addr5(1'b0),.addr5_mx(),.din5(8'd0),.din5_mx(),.we5(1'b0),.we5_mx(),
        .ioctl_addr(ioctl_addr),.ioctl_ram(ioctl_ram),.ioctl_aux(8'd0),.ioctl_wr(ioctl_wr),
        .ioctl_din(ioctl_din),.ioctl_dout(ioctl_dout));

    function [7:0] pattern(input integer k);
        pattern = (k * 7 + 3) ^ (k >> 3);
    endfunction
    integer k;
    reg [15:0] w;
    initial begin
        repeat (4) @(negedge clk);
        // restore, as MiSTer Main sends the file
        ioctl_ram = 1;
        for (k = 0; k < 514; k = k + 1) begin
            ioctl_addr = k; ioctl_dout = pattern(k);
            repeat (3) @(negedge clk);
            ioctl_wr = 1; @(negedge clk); ioctl_wr = 0;
            repeat (3) @(negedge clk);
        end
        ioctl_ram = 0;
        repeat (4) @(negedge clk);
        // the game's side
        for (k = 0; k < 256; k = k + 1) begin
            score_addr = k[7:0];
            repeat (2) @(negedge clk);
            w = {pattern(2*k + 1), pattern(2*k)};
            if (score_dout !== w) $fatal(1, "address %0d holds %h, file says %h", k, score_dout, w);
        end
        ptr_addr = 0; repeat (2) @(negedge clk);
        if (ptr_dout !== pattern(512)) $fatal(1, "address byte is %h, file says %h", ptr_dout, pattern(512));
        // the game writes one score and the address
        score_addr = 8'd9; score_din = 16'h4321; score_we = 2'b11; @(negedge clk); score_we = 0;
        ptr_din = 8'd9; ptr_we = 1; @(negedge clk); ptr_we = 0;
        repeat (2) @(negedge clk);
        if (score_dout !== 16'h4321 || ptr_dout !== 8'd9) $fatal(1, "game writes lost: %h %h", score_dout, ptr_dout);
        // save
        ioctl_ram = 1;
        for (k = 0; k < 514; k = k + 1) begin
            ioctl_addr = k;
            repeat (5) @(negedge clk);
            w[7:0] = k == 18 ? 8'h21 : k == 19 ? 8'h43 : k == 512 ? 8'd9 : pattern(k);
            if (ioctl_din !== w[7:0]) $fatal(1, "save, byte %0d: %h, expected %h", k, ioctl_din, w[7:0]);
        end
        $display("PASS score_ioctl: 514 bytes restored, used by the game and saved back");
        $finish;
    end
endmodule
