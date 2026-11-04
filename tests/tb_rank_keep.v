// SPDX-License-Identifier: GPL-3.0-or-later
// jtmonacogp_rank.v with KEEP = 1 (not original circuitry): the scores survive a
// restart through the NVRAM file. On a memory as the file restores it:
// - power-up writes nothing and takes the address from the file;
// - one search fills the five ranks, with N, R and FLASH at zero;
// - a game stores its score in the next address only, and the ranks, N, R and
//   the saved address follow;
// - a second restart finds it all again, and the next game goes on after it;
// - with no file (all zeros) the first game goes to address 1, as on the board.
`timescale 1ns/1ps
module tb_rank_keep;
    reg clk = 0;
    always #34.95 clk = ~clk;
    reg rst = 1, cen7 = 0;
    always @(posedge clk) cen7 <= ~cen7;
    reg [8:0] hc = 0, vc = 0;
    reg [7:0] frame = 0;
    always @(negedge clk) if (cen7) begin
        hc <= hc == 9'd455 ? 9'd0 : hc + 9'd1;
        if (hc == 9'd455) begin
            vc <= vc == 9'd263 ? 9'd0 : vc + 9'd1;
            if (vc == 9'd263) frame <= frame + 8'd1;
        end
    end
    wire h5 = hc[5], v2 = vc[2], vs16 = frame[3];
    reg scp_n = 1, ct_n = 1, ir_n = 1, game = 0;

    wire [15:0] p, d;
    wire [3:0] s100;
    wire s2, spc, lcl, srch;
    wire [4:0] ck;
    wire [11:0] n, r;
    wire [5:1] fl;
    wire [79:0] kq;
    wire [7:0] ram_a, ptr_di;
    wire [15:0] ram_di;
    wire ram_we, ptr_we;
    reg [15:0] ram [0:255];
    reg [15:0] want [0:255];
    reg [7:0] ptr = 0;
    integer writes = 0, ptr_writes = 0, lit = 0, shown = 0;
    reg watch = 0;
    always @(posedge clk) begin
        if (ram_we) begin ram[ram_a] <= ram_di; writes = writes + 1; end
        if (ptr_we) begin ptr <= ptr_di; ptr_writes = ptr_writes + 1; end
        if (watch && !rst) begin
            if (fl != 0) lit = lit + 1;
            if (r != 0 || n != 0) shown = shown + 1;
        end
    end
    jtmonacogp_score u_score(.clk(clk),.rst(rst),.pxl_cen(cen7),.score_cp_n(scp_n),.coin_test_n(ct_n),
        .ini_reset_n(ir_n),.digits(p),.s100(s100),.s100_d2(s2),.sp_cont(spc));
    jtmonacogp_rank #(.KEEP(1)) u_rank(.clk(clk),.rst(rst),.cen14(1'b1),.h5(h5),.v2(v2),
        .vs16(vs16),.game(game),.coin_test_n(ct_n),.ini_reset_n(ir_n),.p(p),.d(d),.rank_ck(ck),
        .latch_cl(lcl),.n(n),.r(r),.flash(fl),.searching(srch),
        .ram_addr(ram_a),.ram_din(ram_di),.ram_we(ram_we),.ram_dout(ram[ram_a]),
        .ptr_din(ptr_di),.ptr_we(ptr_we),.ptr_dout(ptr));
    jtmonacogp_ranks u_ranks(.clk(clk),.rst(rst),.d(d),.ck(ck),.latch_cl(lcl),.q(kq));

    integer pix;
    task automatic pixels(input integer k);
        for (pix = 0; pix < k; pix = pix + 1) begin
            @(negedge clk); while (!cen7) @(negedge clk);
        end
    endtask
    task automatic score_to(input [15:0] target);
        integer i, units;
        begin
            units = target[15:12]*1000 + target[11:8]*100 + target[7:4]*10 + target[3:0];
            for (i = 0; i < units; i = i + 1) begin
                pixels(2); scp_n = 0; pixels(2); scp_n = 1;
            end
        end
    endtask
    task automatic check_ram(input [8*24-1:0] where);
        integer i;
        for (i = 0; i < 256; i = i + 1)
            if (ram[i] !== want[i])
                $fatal(1, "%0s: address %0d holds %h, expected %h", where, i, ram[i], want[i]);
    endtask
    task automatic check_ranks(input [15:0] a, b, c, e, f);
        if (kq !== {f, e, c, b, a})
            $fatal(1, "ranks %h %h %h %h %h, expected %h %h %h %h %h",
                   kq[15:0], kq[31:16], kq[47:32], kq[63:48], kq[79:64], a, b, c, e, f);
    endtask
    task automatic wait_search(input [8*12-1:0] what);
        integer w;
        begin
            w = 0;
            while (!srch && w < 100000) begin pixels(1); w = w + 1; end
            if (!srch) $fatal(1, "%0s: no search", what);
            while (srch) pixels(1000);
            pixels(5000);
        end
    endtask
    // a power cycle: the core restarts, the memory and the address as in the file
    task automatic restart(input [7:0] saved);
        begin
            rst = 1; repeat (4) @(negedge clk); rst = 0;
            lit = 0; shown = 0; watch = 1;
            writes = 0; ptr_writes = 0;
            ir_n = 0; pixels(20000);
            if (ram_a !== saved) $fatal(1, "address %h after restore, file says %h", ram_a, saved);
            ir_n = 1;
            pixels(1000);
            check_ram("power-up");
            wait_search("boot");
            if (writes != 0) $fatal(1, "%0d memory writes during power-up", writes);
            if (ptr_writes != 0) $fatal(1, "%0d address writes during power-up", ptr_writes);
            if (ram_a !== saved) $fatal(1, "boot search left the address at %h, not %h", ram_a, saved);
            if (lit != 0 || shown != 0) $fatal(1, "FLASH on %0d, N or R on %0d clocks", lit, shown);
            watch = 0;
        end
    endtask
    task automatic play(input [15:0] sc);
        begin
            ct_n = 0; pixels(50); ct_n = 1;
            pixels(3000); game = 1;
            score_to(sc);
            pixels(2000); game = 0;
            pixels(800);                 // past RAM R/W, 11A's count 5
        end
    endtask

    integer i;
    initial begin
        // what the file restores
        for (i = 0; i < 256; i = i + 1) begin ram[i] = 16'd0; want[i] = 16'd0; end
        want[1] = 16'h0712; want[2] = 16'h2500; want[3] = 16'h0300; want[4] = 16'h9999;
        want[5] = 16'h0712; want[6] = 16'h1234; want[200] = 16'h0100;
        for (i = 0; i < 256; i = i + 1) ram[i] = want[i];
        ptr = 8'd6;
        repeat (4) @(negedge clk);

        restart(8'd6);
        check_ranks(16'h9999, 16'h2500, 16'h1234, 16'h0712, 16'h0712);
        $display("  restored: ranks %h %h %h %h %h, N %h, R %h", kq[15:0], kq[31:16], kq[47:32], kq[63:48], kq[79:64], n, r);

        play(16'h1500);
        want[7] = 16'h1500;
        check_ram("game 1");
        wait_search("game 1");
        check_ranks(16'h9999, 16'h2500, 16'h1500, 16'h1234, 16'h0712);
        if (n !== 12'h001 || r !== 12'h003) $fatal(1, "game 1: N %h R %h", n, r);
        if (fl[3] === 1'bx) $fatal(1, "game 1: FLASH unknown");
        if (ptr !== ram_a || ptr_writes == 0) $fatal(1, "game 1: address %h, saved %h", ram_a, ptr);
        $display("  game 1: stored at 7, next from %0d, ranks %h %h %h, N %h, R %h", ptr, kq[15:0], kq[31:16], kq[47:32], n, r);

        restart(ptr);
        check_ranks(16'h9999, 16'h2500, 16'h1500, 16'h1234, 16'h0712);
        play(16'h0050);
        for (i = 0; i < 256; i = i + 1) if (ram[i] !== want[i]) begin
            if (want[i] !== 16'd0 || ram[i] !== 16'h0050)
                $fatal(1, "second session: address %0d overwritten with %h", i, ram[i]);
            $display("  second session: stored at %0d", i);
            want[i] = 16'h0050;
        end
        check_ram("game 2");
        wait_search("game 2");
        if (n !== 12'h001) $fatal(1, "game 2: N %h", n);

        // no file
        for (i = 0; i < 256; i = i + 1) begin ram[i] = 16'd0; want[i] = 16'd0; end
        ptr = 8'd0;
        restart(8'd0);
        check_ranks(16'd0, 16'd0, 16'd0, 16'd0, 16'd0);
        play(16'h0200);
        want[1] = 16'h0200;
        check_ram("no file");
        $display("PASS rank_keep: restored scores, address and ranks survive two restarts; first game with no file at address 1");
        $finish;
    end
endmodule
