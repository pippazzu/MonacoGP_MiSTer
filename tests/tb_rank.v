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
//
// PRO = 1 (tb_rank_pro): the Pro board's sheets I and K (manual 420-0525,
// pro/docs/trace/SHEET_I_TRACE.md and SHEET_K_TRACE.md), with /GAME END
// (sheet N, not connected here) driven by the bench: low from power-up and
// after each game's bonus payout, high from each start. Also compared every
// clock: the 10,000-point flip-flop 56 (lamp) and sheet K's SUPER RACER
// SCORE latches and FLAG (one host clock later in the RTL); the rising
// edges of T.R.S and of 66.8 (the SUPER RACER SCORE clock) are counted on
// both sides. The run, with directed checks:
// - power-up writes nothing to the memory;
// - a game of 1634 (1234 + two bonuses) is stored and ranked;
// - games of 10400, 10200, 12345 and 12345 (bonuses included) light the
//   10,000-point lamp, start no search, write nothing and leave the ranks
//   alone; SUPER RACER SCORE keeps 0400, 0400, 2345, 2345 with FLAG set;
//   66.8 rises three times as read (P >= S, SRS_GE = 1), twice with P > S;
// - the coin after each of those games: as drawn, RST clears 56 while
//   /GAME END is low, and the sequencer writes 0000 into the next slot
//   (N counts it; RST holds the search off);
// - a game of 0712 is stored and ranked;
// - /INI. RESET: nothing written (the scores stay), the rank latches
//   unchanged, SUPER RACER SCORE cleared;
// - RAM RESET: LATCH CL. high, the rank latches unchanged, all 256 slots
//   0000 in the RTL's memory and the reference's (a sequencer cycle left
//   over at the release may start a search, which is let finish);
// - /INI. RESET again, then a game of 0300 stored and ranked against the
//   cleared memory.
// The two memories are compared slot by slot after every check, each from
// its own 9F (the reference's settles one or two steps on at time 0).
// N is checked only after an /INI. RESET with no RAM RESET since: as
// modelled (not traced on Pro), N counts while RAM RESET is held.
`timescale 1ns/1ps
module tb_rank #(
    parameter integer DOWN_INV = 1,
    parameter integer GAMES = 4,
    parameter [16*8-1:0] SCORES = {16'h1234, 16'h0712, 16'h2500, 16'h0712, 16'h0000, 16'h9999, 16'h0300, 16'h0712},
    parameter integer COIN_EARLY = 0,
    parameter integer PRO = 0,
    parameter integer SRS_GE = 1,
    parameter integer TRS_W = 1912
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
    // Pro: /GAME END low while no game is on (sheet N), /RAM RESET
    reg ge_n = PRO ? 1'b0 : 1'b1, rr_n = 1;
    wire pro = PRO != 0;

    // ------------------------------------------------ RTL
    wire [15:0] p, d;
    wire [3:0] s100;
    wire s2, spc, lcl, srch;
    wire [4:0] ck;
    wire [11:0] n, r;
    wire [5:1] fl;
    wire [79:0] kq;
    wire tenk, trs, sflag;
    wire [15:0] srs;
    jtmonacogp_score u_score(.clk(clk),.rst(rst),.pxl_cen(cen7),.score_cp_n(scp_n),.coin_test_n(ct_n),
        .ini_reset_n(ir_n),.pro(pro),.ram_reset_n(rr_n),
        .digits(p),.s100(s100),.s100_d2(s2),.sp_cont(spc));
    // the 2111s; the cycle-exact read of the bench's clock, where each clock is an enable
    wire [7:0] ram_a;
    wire [15:0] ram_di;
    wire ram_we;
    reg [15:0] ram_m [0:255];
    integer ri;
    initial for (ri = 0; ri < 256; ri = ri + 1) ram_m[ri] = 16'd0;
    always @(posedge clk) if (ram_we) ram_m[ram_a] <= ram_di;
    jtmonacogp_rank #(.DOWN_INV(DOWN_INV),.TRS_W(TRS_W)) u_rank(.clk(clk),.rst(rst),.cen14(1'b1),.h5(h5),.v2(v2),
        .vs16(vs16),.game(game),.coin_test_n(ct_n),.ini_reset_n(ir_n),.p(p),
        .pro(pro),.game_end_n(ge_n),.ram_reset_n(rr_n),.tenk(tenk),.trs(trs),
        .d(d),.rank_ck(ck),
        .latch_cl(lcl),.n(n),.r(r),.flash(fl),.searching(srch),
        .ram_addr(ram_a),.ram_din(ram_di),.ram_we(ram_we),.ram_dout(ram_m[ram_a]),
        .ptr_din(),.ptr_we(),.ptr_dout(8'd0));
    jtmonacogp_ranks #(.SRS_GE(SRS_GE)) u_ranks(.clk(clk),.rst(rst),.d(d),.ck(ck),.latch_cl(lcl),
        .pro(pro),.p(p),.trs(trs),.q(kq),.srs(srs),.srs_flag(sflag));

    // ------------------------------------------------ references
    wire [15:0] rp_, rd;
    wire [3:0] rs100;
    wire rs2, rspc, rlcl, rsrch;
    wire [4:0] rck;
    wire [11:0] rn, rr;
    wire [5:1] rfl;
    wire [79:0] rkq;
    wire rtenk, rtrs, rsflag;
    wire [15:0] rsrs;
    sheet_i_score_reference #(.PRO(PRO)) ref_score(.score_cp_n(scp_n),.coin_test_n(ct_n),.ini_reset_n(ir_n),
        .ram_reset_n(rr_n),.digits(rp_),.s100(rs100),.s100_d2(rs2),.sp_cont(rspc));
    sheet_i_rank_reference #(.DOWN_INV(DOWN_INV),.PRO(PRO),.TRS_NS(TRS_W*69.9)) ref_rank(.osc14(clk),.h5(h5),.v2(v2),.vs16(vs16),
        .game(game),.coin_test_n(ct_n),.ini_reset_n(ir_n),.game_end_n(ge_n),.ram_reset_n(rr_n),
        .p(rp_),.d(rd),.rank_ck(rck),
        .latch_cl(rlcl),.n(rn),.r(rr),.flash(rfl),.searching(rsrch),.tenk(rtenk),.trs(rtrs));
    sheet_k_reference #(.PRO(PRO),.SRS_GE(SRS_GE)) ref_k(.d(rd),.ck(rck),.latch_cl(rlcl),.p(rp_),.trs(rtrs),
        .q(rkq),.srs(rsrs),.srs_flag(rsflag));

    // ------------------------------------------------ comparison
    integer checks = 0, dchecks = 0, ckpulses = 0, flashes = 0;
    reg [4:0] ck_l = 0;
    reg [79:0] rkq_l = 0;
    reg [16:0] rsrs_l = 0;
    reg rtenk_l = 0;
    reg [5:1] fl_seen = 0;
    // Pro: rising edges of T.R.S and of the SUPER RACER SCORE clock, memory writes
    integer trs_up = 0, rtrs_up = 0, scp_up = 0, rscp_up = 0, writes = 0;
    reg trs_l = 0, rtrs_l = 0, scp_l = 0, rscp_l = 0, we_l = 0;
    wire rscp;
    generate if (PRO) begin : g_rscp
        assign rscp = ref_k.g_srs.clk66;
    end else begin : g_norscp
        assign rscp = 1'b0;
    end endgenerate
    // The reference's 66.8 is counted on its own edges: with P > S
    // (SRS_GE = 0) it falls again a few ns after the 174s take P. While the
    // 7485 chain settles on the new S it may also pulse again (a hazard; the
    // 174s take the same P again): a rise within 100 ns of the last one is
    // not counted, and reported.
    realtime rscp_t = -1.0e9;
    integer rscp_hz = 0;
    always @(rscp) begin
        if (rscp_l === 1'b0 && rscp === 1'b1) begin
            if ($realtime - rscp_t > 100.0) rscp_up = rscp_up + 1;
            else begin
                rscp_hz = rscp_hz + 1;
                $display("  66.8 in the reference rose again %0.1f ns after its last rise (7485 hazard, the same P)",
                         $realtime - rscp_t);
            end
            rscp_t = $realtime;
        end
        rscp_l = rscp;
    end
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
        // 56 and the SUPER RACER SCORE latches: the RTL takes the score and
        // T.R.S one host clock after the reference, and RST or LATCH CL. at
        // once; it must show the reference's value of now or of one clock
        // before (the same value, while the reference holds it)
        if (tenk !== rtenk && tenk !== rtenk_l)
            $fatal(1, "10,000 flip-flop mismatch at %0t: RTL %b REF %b (one clock before %b)", $time, tenk, rtenk, rtenk_l);
        rtenk_l = rtenk;
        if ({sflag, srs} !== {rsflag, rsrs} && {sflag, srs} !== rsrs_l)
            $fatal(1, "SUPER RACER SCORE mismatch at %0t: RTL %b %h REF %b %h (one clock before %b %h)",
                   $time, sflag, srs, rsflag, rsrs, rsrs_l[16], rsrs_l[15:0]);
        rsrs_l = {rsflag, rsrs};
        if (ref_rank.j2[2] === 1'b1 || ref_rank.j2[3] === 1'b1) begin
            dchecks = dchecks + 1;
            if (d !== rd) $fatal(1, "D bus mismatch at %0t: RTL %h REF %h", $time, d, rd);
        end
        if (ck & ~ck_l) ckpulses = ckpulses + 1;
        ck_l = ck;
        if (fl != 0) flashes = flashes + 1;
        fl_seen = fl_seen | fl;
        if (trs && !trs_l) trs_up = trs_up + 1;
        if (rtrs && !rtrs_l) rtrs_up = rtrs_up + 1;
        if (u_ranks.srs_cp && !scp_l) scp_up = scp_up + 1;
        {trs_l, rtrs_l, scp_l} = {trs, rtrs, u_ranks.srs_cp};
        if (ram_we && !we_l) writes = writes + 1;
        we_l = ram_we;
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
    task automatic score_pulses(input integer units);
        integer i;
        for (i = 0; i < units; i = i + 1) begin
            pixels(2); scp_n = 0; pixels(2); scp_n = 1;
        end
    endtask

    // expected results, from the stored scores
    reg [15:0] mem [0:255];
    integer stored = 256, games_played = 0;
    reg n_valid = 1;
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
            if (n_valid && val({4'd0, n}) != games_played % 1000)
                $fatal(1, "N is %h, expected %0d", n, games_played);
            if (DOWN_INV && val({4'd0, r}) != above + 1)
                $fatal(1, "R is %h, expected %0d", r, above + 1);
            $display("  game %0d: score %h, ranks %h %h %h %h %h, N %h, R %h (%0d above)",
                     games_played, score, kq[15:0], kq[31:16], kq[47:32], kq[63:48], kq[79:64], n, r, above);
        end
    endtask

    // ------------------------------------------------ Pro
    // slot i of the reference's 5101s (Pro only)
    generate if (PRO) begin : g_mem
        task automatic get(input integer i, output [15:0] v);
            v = {ref_rank.g_pro_mem.digit[3].ram.mem[i], ref_rank.g_pro_mem.digit[2].ram.mem[i],
                 ref_rank.g_pro_mem.digit[1].ram.mem[i], ref_rank.g_pro_mem.digit[0].ram.mem[i]};
        endtask
    end else begin : g_mem
        task automatic get(input integer i, output [15:0] v);
            v = 16'hxxxx;
        endtask
    end endgenerate
    // the reference's 5101s against the RTL's memory, and against a value.
    // The two 9F counters may differ by a constant: the reference's settles
    // from unknown at time 0 (an edge the RTL does not see), and both then
    // step together. Slot k after each one's own address is compared.
    task automatic pro_check_ram(input check_all, input [15:0] all);
        integer i;
        reg [15:0] rv;
        reg [7:0] off;
        begin
            off = ref_rank.adr - u_rank.adr;
            for (i = 0; i < 256; i = i + 1) begin
                g_mem.get((i + off) % 256, rv);
                if (rv !== ram_m[i])
                    $fatal(1, "memory slot %0d: RTL %h, reference (slot %0d) %h", i, ram_m[i], (i + off) % 256, rv);
                if (check_all && ram_m[i] !== all)
                    $fatal(1, "memory slot %0d holds %h, expected %h", i, ram_m[i], all);
            end
        end
    endtask
    // /GAME END and /RAM RESET change in the middle of an H5 half period:
    // an edge of either at the same instant as an H5 edge would be a race
    // between the sequencer's clock and its reset, which neither model claims
    task automatic mid_h5;
        while (hc[4:0] != 5'd16) pixels(1);
    endtask
    // A Pro game: coin, start (/GAME END rises with /GAME), the score,
    // game over, the bonus payout (pulses on /SCORE CP, as sheet F gives
    // /BONUS POINT), then /GAME END falls. The coin switch is held for 1000
    // pixels (140 us; a real press is far longer), more than the sequencer's
    // eight H5 periods.
    // After a game over 9999, as drawn: RST at the coin clears 56 while
    // /GAME END is still low, so 92b runs once: ADR INC., 192 LD., a write
    // of the score RST holds at 0000 into the next slot, 256 CL. (N counts;
    // the search does not start, 12B being held clear by RST).
    reg prev_over = 0;
    integer w_coin = 0;                 // memory writes counted up to the coin's end
    task automatic pro_game(input integer pts, input integer bonus);
        integer w0;
        begin
            w0 = writes;
            mid_h5; ct_n = 0; pixels(1000); ct_n = 1;        // coin
            if (writes - w0 != (prev_over ? 1 : 0))
                $fatal(1, "%0d memory writes at the coin, expected %0d", writes - w0, prev_over ? 1 : 0);
            if (srch) $fatal(1, "a search runs after the coin");
            if (prev_over) begin
                mem[ref_rank.adr] = 16'h0000;
                games_played = games_played + 1;
            end
            w_coin = writes;
            pixels(3000); mid_h5; game = 1; ge_n = 1;        // start
            score_pulses(pts);
            pixels(2000); game = 0;                          // game over
            score_pulses(bonus);                             // the payout
            pixels(100); mid_h5; ge_n = 0;                   // /GAME END
        end
    endtask
    // /INI. RESET (a power cycle with the memory kept): no write, the rank
    // latches kept; N restarts from 0
    task automatic pro_ini_reset;
        integer w0;
        reg [79:0] kq0;
        begin
            kq0 = kq; w0 = writes;
            ir_n = 0; pixels(20000); ir_n = 1;
            pixels(80000);
            if (writes != w0) $fatal(1, "%0d memory writes at /INI. RESET", writes - w0);
            if (kq !== kq0) $fatal(1, "/INI. RESET changed the rank latches");
            if (srch) $fatal(1, "a search runs after /INI. RESET");
            $display("  /INI. RESET: ranks kept %h %h %h %h %h",
                     kq[15:0], kq[31:16], kq[47:32], kq[63:48], kq[79:64]); $fflush;
            n_valid = 1; games_played = 0;
        end
    endtask
    // a game below 10,000: stored, searched and ranked
    task automatic pro_ranked(input integer pts, input integer bonus);
        integer w0, wait_pix;
        reg [15:0] sc;
        begin
            pro_game(pts, bonus);
            w0 = w_coin;
            prev_over = 0;
            sc = p;
            if (tenk !== 1'b0) $fatal(1, "10,000 lamp lit for %h", sc);
            games_played = games_played + 1;
            pixels(200);
            mem[ref_rank.adr] = sc;
            wait_pix = 0;
            while (!srch && wait_pix < 2000) begin pixels(1); wait_pix = wait_pix + 1; end
            if (!srch) $fatal(1, "search did not start after a game of %h", sc);
            while (srch) pixels(1000);
            pixels(5000);
            if (writes - w0 != 1) $fatal(1, "%0d memory writes after a game of %h, expected 1", writes - w0, sc);
            expect_ranks(sc);
            pro_check_ram(0, 0);
            pixels(456*264*16);
        end
    endtask
    // a game over 9999: the lamp, no write, no search, SUPER RACER SCORE
    task automatic pro_over(input integer pts, input integer bonus, input [15:0] best);
        integer w0, t0, s0, i;
        reg [79:0] kq0;
        reg seen;
        begin
            t0 = trs_up; s0 = scp_up; kq0 = kq;
            pro_game(pts, bonus);
            w0 = w_coin;
            prev_over = 1;
            if (tenk !== 1'b1) $fatal(1, "10,000 lamp off after %0d points", pts + bonus);
            seen = 0;
            for (i = 0; i < 4000; i = i + 1) begin pixels(1); seen = seen | srch; end
            if (seen) $fatal(1, "a search ran after a game over 9999");
            if (writes != w0) $fatal(1, "a game over 9999 was written to the memory");
            if (kq !== kq0) $fatal(1, "the ranks changed after a game over 9999");
            if (r !== 12'd0 || fl !== 5'd0) $fatal(1, "R %h, FLASH %b after a game over 9999", r, fl);
            if (trs_up != t0 + 1) $fatal(1, "T.R.S rose %0d times at /GAME END", trs_up - t0);
            if (!sflag || srs !== best)
                $fatal(1, "SUPER RACER SCORE %b %h after %0d points, expected 1 %h", sflag, srs, pts + bonus, best);
            $display("  game over 9999: score %h (+10000, lamp lit), SUPER RACER SCORE %h, 66.8 rose %0d times",
                     p, srs, scp_up - s0);
            pro_check_ram(0, 0);
        end
    endtask

    integer g, i, wait_pix, w0;
    reg [15:0] sc;
    reg [79:0] kq0;
    initial begin
        for (i = 0; i < 256; i = i + 1) mem[i] = 0;
        repeat (4) @(negedge clk);
        rst = 0;
        // power-up: /INI. RESET low (6.28 s on the board, here 20,000 pixels)
        ir_n = 0; pixels(20000); ir_n = 1;
        pixels(80000);
        if (lcl !== 1'b0) $fatal(1, "LATCH CL. still high after power-up");
        $display("  power-up done at %0t ns", $time); $fflush;
        if (!PRO) begin
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
        end else begin
            // ---------------------------------------- the Pro board
            if (writes != 0) $fatal(1, "%0d memory writes at power-up", writes);
            pro_ranked(1234, 400);
            pro_over(9800, 600, 16'h0400);
            pro_over(10000, 200, 16'h0400);
            pro_over(12145, 200, 16'h2345);
            pro_over(12145, 200, 16'h2345);
            if (scp_up != (SRS_GE ? 3 : 2))
                $fatal(1, "66.8 rose %0d times, expected %0d", scp_up, SRS_GE ? 3 : 2);
            pro_ranked(712, 0);
            // /INI. RESET: nothing written (the memory keeps its scores), the
            // rank latches kept, SUPER RACER SCORE cleared (LATCH CL.)
            if (!sflag) $fatal(1, "SUPER RACER SCORE not set before /INI. RESET");
            pro_ini_reset;
            if (sflag || srs !== 16'd0) $fatal(1, "/INI. RESET left SUPER RACER SCORE at %b %h", sflag, srs);
            pro_check_ram(0, 0);
            // RAM RESET, held for about 390 sequencer cycles (256 needed)
            kq0 = kq;
            mid_h5; rr_n = 0; pixels(400000);
            if (lcl !== 1'b1) $fatal(1, "LATCH CL. low during RAM RESET");
            if (kq !== kq0) $fatal(1, "RAM RESET changed the rank latches");
            if (sflag || srs !== 16'd0) $fatal(1, "RAM RESET left SUPER RACER SCORE at %b %h", sflag, srs);
            mid_h5; rr_n = 1;
            $display("  RAM RESET: %0d memory writes, ranks kept %h %h %h %h %h", writes,
                     kq[15:0], kq[31:16], kq[47:32], kq[63:48], kq[79:64]); $fflush;
            pixels(4000);
            while (srch) pixels(1000);                       // a cycle left over may start a search
            pixels(5000);
            for (i = 0; i < 256; i = i + 1) mem[i] = 0;
            pro_check_ram(1, 16'h0000);
            n_valid = 0;
            // /INI. RESET again: N starts from 0
            pro_ini_reset;
            pro_ranked(300, 0);
            if (trs_up != rtrs_up) $fatal(1, "T.R.S rose %0d times, the reference %0d", trs_up, rtrs_up);
            if (scp_up != rscp_up) $fatal(1, "66.8 rose %0d times, the reference %0d", scp_up, rscp_up);
            $display("PASS rank_pro: %0d host clocks and %0d strobed D-bus samples match the pin-wired Pro sheet I and K references",
                     checks, dchecks);
            $display("  T.R.S rose %0d times, 66.8 %0d times (SRS_GE %0d), %0d memory writes, 9F reference - RTL = %0d",
                     trs_up, scp_up, SRS_GE, writes, ref_rank.adr - u_rank.adr);
        end
        $display("  %0d rank latch clocks, FLASH lines seen %b (%0d clocks lit)", ckpulses, fl_seen, flashes); $fflush;
        $finish;
    end
endmodule
