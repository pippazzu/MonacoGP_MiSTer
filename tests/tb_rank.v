// SPDX-License-Identifier: GPL-3.0-or-later
// Sheet I (score counter, high-score memory and ranking) and sheet K (rank
// latches): the RTL (jtmonacogp_score.v, jtmonacogp_rank.v,
// jtmonacogp_ranks.v) against the pin-wired references
// (tests/sheet_i_score_reference.v, tests/sheet_i_rank_reference.v,
// tests/sheet_k_reference.v), on the same inputs.
//
// The host clock is the 14 MHz clock itself (cen14 always high, cen7 every
// other clock): the references take it as the 14 MHz input, rising with the
// host clock. Inputs change at the falling edge of the host clock and have
// settled in the references long before the next rising edge, where the RTL
// takes them. Compared just before every rising edge: the score, S-100 lines
// and SP. CONT., the rank lines 1ST..5TH, LATCH CL., N, R, the five FLASH
// lines, the search flag and all five ranks of sheet K (one host clock
// later in the RTL); the D bus while a
// comparison strobe (J2 Q2 or Q3) is on.
//
// The run: power-up (/INI. RESET), then GAMES games, each a coin, a start, a
// score from SCORES, the end of the game, and the whole search (about 1.4 s
// of 14 MHz clocks) before the next coin. After each search the ranks, N and
// R are also checked against the stored scores (every memory entry is 0000
// after power-up): the five highest in order, N = games played, R = 1 + the
// number of stored scores above the new one (DOWN_INV = 1). With COIN_EARLY
// the last game's coin comes in the middle of its search.
`timescale 1ns/1ps
module tb_rank #(
    parameter integer DOWN_INV = 1,
    parameter integer GAMES = 4,
    parameter [16*8-1:0] SCORES = {16'h1234, 16'h0712, 16'h2500, 16'h0712, 16'h0000, 16'h9999, 16'h0300, 16'h0712},
    parameter integer COIN_EARLY = 0
);
    reg clk = 0;
    always #34.95 clk = ~clk;
    reg rst = 1, cen7 = 0;
    always @(posedge clk) cen7 <= ~cen7;
    // raster: 456 x 264 pixels, pixel = two 14 MHz clocks
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

    // ------------------------------------------------ RTL
    wire [15:0] p, d;
    wire [3:0] s100;
    wire s2, spc, lcl, srch;
    wire [4:0] ck;
    wire [11:0] n, r;
    wire [5:1] fl;
    wire [79:0] kq;
    jtmonacogp_score u_score(.clk(clk),.rst(rst),.pxl_cen(cen7),.score_cp_n(scp_n),.coin_test_n(ct_n),
        .ini_reset_n(ir_n),.digits(p),.s100(s100),.s100_d2(s2),.sp_cont(spc));
    // the 2111s; the cycle-exact read of the bench's clock, where each clock is an enable
    wire [7:0] ram_a;
    wire [15:0] ram_di;
    wire ram_we;
    reg [15:0] ram_m [0:255];
    integer ri;
    initial for (ri = 0; ri < 256; ri = ri + 1) ram_m[ri] = 16'd0;
    always @(posedge clk) if (ram_we) ram_m[ram_a] <= ram_di;
    jtmonacogp_rank #(.DOWN_INV(DOWN_INV)) u_rank(.clk(clk),.rst(rst),.cen14(1'b1),.h5(h5),.v2(v2),
        .vs16(vs16),.game(game),.coin_test_n(ct_n),.ini_reset_n(ir_n),.p(p),.d(d),.rank_ck(ck),
        .latch_cl(lcl),.n(n),.r(r),.flash(fl),.searching(srch),
        .ram_addr(ram_a),.ram_din(ram_di),.ram_we(ram_we),.ram_dout(ram_m[ram_a]),
        .ptr_din(),.ptr_we(),.ptr_dout(8'd0));
    jtmonacogp_ranks u_ranks(.clk(clk),.rst(rst),.d(d),.ck(ck),.latch_cl(lcl),.q(kq));

    // ------------------------------------------------ references
    wire [15:0] rp_, rd;
    wire [3:0] rs100;
    wire rs2, rspc, rlcl, rsrch;
    wire [4:0] rck;
    wire [11:0] rn, rr;
    wire [5:1] rfl;
    wire [79:0] rkq;
    sheet_i_score_reference ref_score(.score_cp_n(scp_n),.coin_test_n(ct_n),.ini_reset_n(ir_n),
        .digits(rp_),.s100(rs100),.s100_d2(rs2),.sp_cont(rspc));
    sheet_i_rank_reference #(.DOWN_INV(DOWN_INV)) ref_rank(.osc14(clk),.h5(h5),.v2(v2),.vs16(vs16),
        .game(game),.coin_test_n(ct_n),.ini_reset_n(ir_n),.p(rp_),.d(rd),.rank_ck(rck),
        .latch_cl(rlcl),.n(rn),.r(rr),.flash(rfl),.searching(rsrch));
    sheet_k_reference ref_k(.d(rd),.ck(rck),.latch_cl(rlcl),.q(rkq));

    // ------------------------------------------------ comparison
    integer checks = 0, dchecks = 0, ckpulses = 0, flashes = 0;
    reg [4:0] ck_l = 0;
    reg [79:0] rkq_l = 0;
    reg [5:1] fl_seen = 0;
    always @(posedge clk) if (!rst) begin
        #33;
        checks = checks + 1;
        if ({p, s100, s2, spc} !== {rp_, rs100, rs2, rspc})
            $fatal(1, "score mismatch at %0t: RTL %h %b %b %b REF %h %b %b %b", $time, p, s100, s2, spc, rp_, rs100, rs2, rspc);
        if ({ck, lcl, n, r, fl, srch} !== {rck, rlcl, rn, rr, rfl, rsrch})
            $fatal(1, "rank mismatch at %0t: RTL ck %b cl %b n %h r %h fl %b s %b, REF ck %b cl %b n %h r %h fl %b s %b",
                   $time, ck, lcl, n, r, fl, srch, rck, rlcl, rn, rr, rfl, rsrch);
        // the RTL latches take a rank line's rising edge at the next host
        // clock (jtmonacogp_ranks.v), one clock after the 74174s
        if (kq !== rkq_l)
            $fatal(1, "sheet K mismatch at %0t: RTL %h REF (one clock before) %h", $time, kq, rkq_l);
        rkq_l = rkq;
        if (ref_rank.j2[2] === 1'b1 || ref_rank.j2[3] === 1'b1) begin
            dchecks = dchecks + 1;
            if (d !== rd) $fatal(1, "D bus mismatch at %0t: RTL %h REF %h", $time, d, rd);
        end
        if (ck & ~ck_l) ckpulses = ckpulses + 1;
        ck_l = ck;
        if (fl != 0) flashes = flashes + 1;
        fl_seen = fl_seen | fl;
    end

    // ------------------------------------------------ stimulus
    integer pix;
    task automatic pixels(input integer k);
        for (pix = 0; pix < k; pix = pix + 1) begin
            @(negedge clk); while (!cen7) @(negedge clk);
        end
    endtask
    // the score pulses: falling edges of /SCORE CP, one per 4 pixels
    task automatic score_to(input [15:0] target);
        integer i, units;
        begin
            units = target[15:12]*1000 + target[11:8]*100 + target[7:4]*10 + target[3:0];
            for (i = 0; i < units; i = i + 1) begin
                pixels(2); scp_n = 0; pixels(2); scp_n = 1;
            end
        end
    endtask

    // expected results, from the stored scores
    reg [15:0] mem [0:255];
    integer stored = 256, games_played = 0;
    function integer val(input [15:0] x); val = x[15:12]*1000 + x[11:8]*100 + x[7:4]*10 + x[3:0]; endfunction
    task automatic expect_ranks(input [15:0] score);
        integer i, k, above;
        reg [15:0] top [0:4];
        reg [15:0] best, lim;
        integer cnt_at, used, lv;
        begin
            above = 0;
            for (i = 0; i < 256; i = i + 1) if (val(mem[i]) > val(score)) above = above + 1;
            // five highest entries, duplicates included, in descending order
            used = 0; lv = 10000;
            for (k = 0; k < 5; k = k + 1) top[k] = 0;
            k = 0;
            for (lv = 9999; lv >= 0 && k < 5; lv = lv - 1)
                for (i = 0; i < 256 && k < 5; i = i + 1)
                    if (val(mem[i]) == lv) begin top[k] = mem[i]; k = k + 1; end
            for (k = 0; k < 5; k = k + 1)
                if (kq[16*k +: 16] !== top[k])
                    $fatal(1, "rank %0d is %h, expected %h", k + 1, kq[16*k +: 16], top[k]);
            if (val({4'd0, n}) != games_played % 1000)
                $fatal(1, "N is %h, expected %0d", n, games_played);
            if (DOWN_INV && val({4'd0, r}) != above + 1)
                $fatal(1, "R is %h, expected %0d", r, above + 1);
            $display("  game %0d: score %h, ranks %h %h %h %h %h, N %h, R %h (%0d above)",
                     games_played, score, kq[15:0], kq[31:16], kq[47:32], kq[63:48], kq[79:64], n, r, above);
        end
    endtask

    integer g, i, wait_pix;
    reg [15:0] sc;
    initial begin
        for (i = 0; i < 256; i = i + 1) mem[i] = 0;
        repeat (4) @(negedge clk);
        rst = 0;
        // power-up: /INI. RESET low (6.28 s on the board, here 20,000 pixels)
        ir_n = 0; pixels(20000); ir_n = 1;
        pixels(80000);
        if (lcl !== 1'b0) $fatal(1, "LATCH CL. still high after power-up");
        $display("  power-up done at %0t ns", $time); $fflush;
        for (g = 0; g < GAMES; g = g + 1) begin
            sc = SCORES[16*(7-g) +: 16];
            ct_n = 0; pixels(50); ct_n = 1;                  // coin
            pixels(3000); game = 1;                          // start
            score_to(sc);
            pixels(2000); game = 0;                          // game over
            games_played = games_played + 1;
            // the memory address after ADR INC.: the reference's 9F
            pixels(200);
            mem[ref_rank.adr] = sc;
            if (COIN_EARLY && g == GAMES - 1) begin
                pixels(400000);                              // about half the search
                if (!srch) $fatal(1, "search not running before the early coin");
                ct_n = 0; pixels(50); ct_n = 1;
                pixels(2000);
                if (srch) $fatal(1, "search still running after the coin");
                $display("  game %0d: coin during the search, ranks %h %h %h %h %h, N %h, R %h",
                         games_played, kq[15:0], kq[31:16], kq[47:32], kq[63:48], kq[79:64], n, r);
            end else begin
                wait_pix = 0;
                while (!srch && wait_pix < 2000) begin pixels(1); wait_pix = wait_pix + 1; end
                if (!srch) $fatal(1, "search did not start after game %0d", games_played);
                $display("  game %0d: score %h, search started at %0t ns", games_played, sc, $time); $fflush;
                while (srch) pixels(1000);
                $display("  game %0d: search ended at %0t ns", games_played, $time); $fflush;
                pixels(5000);
                expect_ranks(sc);
                // one Vs/16 period of flashing
                pixels(456*264*16);
            end
        end
        $display("PASS rank: %0d host clocks and %0d strobed D-bus samples match the pin-wired sheet I and K references",
                 checks, dchecks);
        $display("  %0d rank latch clocks, FLASH lines seen %b (%0d clocks lit)", ckpulses, fl_seen, flashes); $fflush;
        $finish;
    end
endmodule
