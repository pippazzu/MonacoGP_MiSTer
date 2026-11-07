// SPDX-License-Identifier: GPL-3.0-or-later
// Sheet A coin, timer and extended-play logic. The RTL (jtmonacogp_coin.v)
// and the pin-wired reference (tests/sheet_a_reference.v) see the same
// stimulus on the real sheet E raster (V2 is the raster's V2).
//
// - Every output and 28 internal state bits are compared for every pixel,
//   and the RTL must settle before each edge 3.
// - Directed checks, written here from the trace:
//   /COIN & TEST low loads the timer with 90; each rise of the 555 output
//       during a game takes one off it, and nothing else changes it;
//   the 555 output is high for T555_FIRST pixels after GAME rises, then low
//       for T555_LOW and high for T555_HIGH pixels in turn;
//   every IC49 and tilt pulse that runs out does so TILT_PIXELS (IC49_PIXELS)
//       after its last trigger; /INI RESET is low while the tilt pulse runs;
//   GAME needs COIN IN at the rise of ACCE. ST., and MCLR clears both;
//   at 00, with the 555 low: EXTEND is set if IC50's first half was set, and
//       the game is cleared otherwise.
// FAST = 0 runs the circuit as drawn, except the tilt one-shot (C19 / 1000, so
// that the power-up pulse is short), through a coin, a start and the score
// pulses, for FULL_FRAMES frames: the first 555 periods and one IC49 pulse at
// full length.
// FAST = 1 divides the 74123 and 555 capacitors by 1000. The stages are:
// power-up (the INI RESET pulse), a coin and a start, A30 score pulses that
// earn an extend, the timer running out (EXTEND), GAME OVER, a second game
// that ends at 00, a 2-play credit, the TEST switch, a tilt during a game,
// then random inputs. The stimulus stands in for the cabinet and sheets E,
// F, H, I and M; it is not gameplay.
// Pro board gates (pro/docs/trace/SHEET_A_BONUS_TRACE.md): BONUS SOUND and
// /BONUS CP from sheet N are driven in every run from their own random
// sequence, which leaves the rest of the stimulus as it was. PRO selects
// the board in both models. Checked from the trace for every pixel:
//   pad A29 EX. CP = (V2 AND Vs/16 AND IC49 Q) OR (PRO AND BONUS SOUND);
//   pad A28 = /COIN IN AND (/BONUS CP OR NOT PRO).
// Both inputs must have been active in pixels where they change these
// outputs on the Pro board (and, with PRO = 0, where they would).
`timescale 1ns/1ps
module tb_coin #(parameter integer FAST = 1, RANDOM_FRAMES = 30, FULL_FRAMES = 100,
                 parameter [31:0] SEED = 32'h4d4f4e41, parameter integer PRO = 0);
    reg clk=0, rst=1;
    always #10.416666667 clk=~clk;                   // 48 MHz
    localparam real CS = FAST ? 1.0e-3 : 1.0;
    function integer px123(input real c_pf);
        px123 = $rtoi(0.28*47.0*c_pf*CS*(1.0+0.7/47.0)*7.1525e-3 + 0.5);
    endfunction
    function integer px555(input real k, input real r_ohm);
        px555 = $rtoi(k*r_ohm*47.0e-6*CS*7.1525e6 + 0.5);
    endfunction
    // The full-scale run keeps the power-up pulse short: C19 / 1000 there too.
    localparam integer NTILT = FAST ? px123(4.7e8) : px123(4.7e5), N49 = px123(1.0e8), NHI = px123(1.0e5);
    localparam integer N5F = px555(1.0986123, 15.3e3), N5H = px555(0.6931472, 15.3e3),
                       N5L = px555(0.6931472, 12.0e3);

    wire pcen, p2cen;
    wire [8:0] h,v,x,y,hp,vp;
    wire hb,vb,hs,vs;
    jtmonacogp_cen u_cen(.clk(clk),.cen14(p2cen),.cen7(pcen));
    jtmonacogp_timing u_timing(.clk(clk),.rst(rst),.pxl_cen(pcen),.h(h),.v(v),
        .hblank(hb),.vblank(vb),.hs(hs),.vs(vs),.x(x),.y(y),.hpos(hp),.vpos(vp));

    // ---------------- Stimulus (changes at the 7 MHz edge)
    reg coin_sw=0, test_sw=0, credit_sw=0, two_play=0, tilt_n=1;
    reg acce_st=0, game_over=0, a30=1;
    reg bonus_sound=0, bonus_cp_n=1;                 // sheet N (Pro)
    wire pro = PRO != 0;
    reg [7:0] vsdiv=0;
    wire vs16 = vsdiv[3];

    // ---------------- RTL
    wire d_game, d_game_n, d_coin, d_coin_n, d_ct, d_ext, d_ext_n, d_exs_n, d_excp_n, d_excp;
    wire d_cccl, d_8000, d_mute, d_hi_n, d_ini_n, d_meter, d_lamp, busy, d_snd_n;
    wire [3:0] d_t1, d_t2;
    wire [27:0] d_dbg;
    jtmonacogp_coin #(.TILT_PIXELS(NTILT),.IC49_PIXELS(N49),.HI_PIXELS(NHI),
        .T555_FIRST(N5F),.T555_HIGH(N5H),.T555_LOW(N5L)) dut(
        .clk(clk),.rst(rst),.pxl_cen(pcen),
        .coin_sw(coin_sw),.test_sw(test_sw),.credit_sw(credit_sw),.two_play(two_play),.tilt_n(tilt_n),
        .acce_st(acce_st),.game_over(game_over),.v2(v[2]),.vs16(vs16),.a30(a30),
        .pro(pro),.bonus_sound(bonus_sound),.bonus_cp_n(bonus_cp_n),.snd_coin_in_n(d_snd_n),
        .game(d_game),.game_n(d_game_n),.coin_in(d_coin),.coin_in_n(d_coin_n),.coin_test_n(d_ct),
        .extend(d_ext),.extend_n(d_ext_n),.ex_signal_n(d_exs_n),.ex_signal_cp_n(d_excp_n),
        .ex_cp(d_excp),.car_cont_cl(d_cccl),.pts8000(d_8000),.mute(d_mute),.hiscore_n(d_hi_n),
        .ini_reset_n(d_ini_n),.t1(d_t1),.t2(d_t2),.coin_meter(d_meter),.credit_lamp(d_lamp),
        .dbg(d_dbg),.busy(busy));

    // ---------------- Pin-wired reference
    // The 7 MHz edge is the pixel boundary; no edge during reset. The other
    // sheets' nets and the switch contacts change 5 ns after it.
    reg f7=0;
    reg [2:0] f7cnt=0;
    always @(posedge clk) begin
        if (pcen && !rst) begin f7<=1; f7cnt<=0; end
        else begin f7cnt<=f7cnt+3'd1; if (f7cnt==3'd2) f7<=0; end
    end
    wire r_aa, r_a23, r_ab, r_a24, r_aq, r_a32, r_2p, r_aj, r_acce, r_go, r_v2, r_vs16, r_a30;
    wire r_bsnd, r_bcp_n;
    wire [8:0] v_t = rst ? 9'h010 : v;
    assign #5 {r_bsnd, r_bcp_n} = {bonus_sound, bonus_cp_n};
    // Each switch rests on its upper contact: closed (0) at rest.
    assign #5 {r_aa, r_a23, r_ab, r_a24, r_aq, r_a32, r_2p, r_aj, r_acce, r_go, r_v2, r_vs16, r_a30} =
              {coin_sw, ~coin_sw, test_sw, ~test_sw, credit_sw, ~credit_sw, two_play, tilt_n,
               acce_st, game_over, v_t[2], vs16, a30};
    wire r_game, r_game_n, r_coin, r_coin_n, r_ct, r_ext, r_ext_n, r_exs_n, r_excp_n, r_excp;
    wire r_cccl, r_8000, r_mute, r_hi_n, r_ini_n, r_meter, r_lamp, r_snd_n;
    wire [3:0] r_t1, r_t2;
    wire [27:0] r_dbg;
    sheet_a_reference #(.TILT_PIXELS(NTILT),.IC49_PIXELS(N49),.HI_PIXELS(NHI),
        .T555_FIRST(N5F),.T555_HIGH(N5H),.T555_LOW(N5L)) reff(.f7(f7),
        .a_aa(r_aa),.a_a23(r_a23),.a_ab(r_ab),.a_a24(r_a24),.a_aq(r_aq),.a_a32(r_a32),
        .a_two_play(r_2p),.a_aj(r_aj),.a_acce_st(r_acce),.a_game_over(r_go),.a_v2(r_v2),
        .a_vs16(r_vs16),.a_a30(r_a30),
        .a_pro(pro),.a_bonus_sound(r_bsnd),.a_bonus_cp_n(r_bcp_n),.snd_coin_in_n(r_snd_n),
        .game(r_game),.game_n(r_game_n),.coin_in(r_coin),.coin_in_n(r_coin_n),.coin_test_n(r_ct),
        .extend(r_ext),.extend_n(r_ext_n),.ex_signal_n(r_exs_n),.ex_signal_cp_n(r_excp_n),
        .ex_cp(r_excp),.car_cont_cl(r_cccl),.pts8000(r_8000),.mute(r_mute),.hiscore_n(r_hi_n),
        .ini_reset_n(r_ini_n),.t1(r_t1),.t2(r_t2),.coin_meter(r_meter),.credit_lamp(r_lamp),
        .dbg(r_dbg));

    wire [53:0] d_vec = {d_snd_n, d_game, d_game_n, d_coin, d_coin_n, d_ct, d_ext, d_ext_n, d_exs_n, d_excp_n,
                         d_excp, d_cccl, d_8000, d_mute, d_hi_n, d_ini_n, d_t1, d_t2, d_meter, d_lamp, d_dbg};
    wire [53:0] r_vec = {r_snd_n, r_game, r_game_n, r_coin, r_coin_n, r_ct, r_ext, r_ext_n, r_exs_n, r_excp_n,
                         r_excp, r_cccl, r_8000, r_mute, r_hi_n, r_ini_n, r_t1, r_t2, r_meter, r_lamp, r_dbg};
    reg [53:0] r_snap;
    // The reference's inputs of the same pixel: BONUS SOUND, /BONUS CP, V2, Vs/16
    reg [3:0] r_in_snap;
    wire s_snd_n = r_snap[53], s_coin_n = r_snap[49], s_excp = r_snap[43], s_q49 = r_snap[2];
    wire s_bsnd = r_in_snap[3], s_bcp_n = r_in_snap[2], s_v2 = r_in_snap[1], s_vs16 = r_in_snap[0];

    // ---------------- Checks and stimulus
    reg [4:0] sr=0;
    integer pixels = 0, frames = 0, stage = 0, wait_px = 0, n, k;
    integer seed = SEED, a30_edges = 0, rnd_frame0 = 0;
    // Sheet N stand-in, from its own sequence
    integer seed_b = SEED ^ 32'h50524f21, bcp_left = 0;
    integer bcp_px = 0, bsnd_px = 0, bcp_low = 0, bsnd_high = 0;
    reg running = 0;
    // Expectations, from the trace
    integer games = 0, n_ext = 0, timeouts = 0, loads = 0, counts = 0;
    integer trig49_px = -1, n49ok = 0, trigtilt_px = 0, ntiltok = 0, n555[0:1];
    integer since555 = -1, his = 0, credits = 0, tilts = 0, step_px = 0;
    reg first555 = 0;
    reg prev_sec = 0, prev_game = 0, prev_q49 = 0, prev_tilt = 1, prev_ct = 1, prev_ext = 0;
    reg prev_hi = 1, prev_coin = 0, game_over_l = 0;
    reg [7:0] prev_t = 0;
    wire sec = d_dbg[4], q49 = d_dbg[2], tiltq = d_dbg[3];
    wire [7:0] tcnt = {d_t2, d_t1};
    function integer bcd(input [7:0] t); bcd = t[7:4]*10 + t[3:0]; endfunction

    always @(posedge clk) begin
        sr <= rst ? 5'd0 : {sr[3:0], pcen};
        if (pcen && !rst) begin
            r_snap <= r_vec;
            r_in_snap <= {r_bsnd, r_bcp_n, r_v2, r_vs16};
        end
        // One-shot triggers in the RTL's settling steps belong to the pixel
        // captured at the last edge 3, which is compared two compares later.
        if (sr[2]) step_px = pixels + 2;
        if (running && dut.trig49) trig49_px = step_px;
        if (running && dut.trig_tilt) trigtilt_px = step_px;
        if (sr[3] && running) begin
            // edge 4: the RTL registered the pixel the snapshot holds
            pixels = pixels + 1;
            if (^d_vec === 1'bx || ^r_snap === 1'bx)
                $fatal(1, "unknown net at pixel %0d:\n RTL %b\n REF %b", pixels, d_vec, r_snap);
            if (d_vec !== r_snap)
                $fatal(1, "sheet A mismatch at pixel %0d (stage %0d):\n RTL %b\n REF %b\n XOR %b",
                       pixels, stage, d_vec, r_snap, d_vec ^ r_snap);
            // ---------------- Pro gates (pads A29, A28), from the trace
            if (s_excp !== ((s_v2 & s_vs16 & s_q49) | (pro & s_bsnd)))
                $fatal(1, "EX. CP %b at pixel %0d: V2 %b Vs/16 %b IC49 Q %b BONUS SOUND %b (PRO %0d)",
                       s_excp, pixels, s_v2, s_vs16, s_q49, s_bsnd, PRO);
            if (s_snd_n !== (s_coin_n & (s_bcp_n | !pro)))
                $fatal(1, "pad A28 %b at pixel %0d: /COIN IN %b /BONUS CP %b (PRO %0d)",
                       s_snd_n, pixels, s_coin_n, s_bcp_n, PRO);
            if (!s_bcp_n) bcp_low = bcp_low + 1;
            if (s_bsnd) bsnd_high = bsnd_high + 1;
            // pixels where the Pro gate changes (would change) the output
            if (!s_bcp_n && s_coin_n) bcp_px = bcp_px + 1;
            if (s_bsnd && !(s_v2 & s_vs16 & s_q49)) bsnd_px = bsnd_px + 1;
            // ---------------- timer
            if (!d_ct && !d_mute) begin
                if (tcnt !== 8'h90) $fatal(1, "/COIN & TEST low but the timer holds %h", tcnt);
                if (prev_ct) loads = loads + 1;
            end else if (!d_mute && tcnt != prev_t) begin
                if (!(sec && !prev_sec)) $fatal(1, "timer changed without a 555 rise");
                if (bcd(tcnt) != (bcd(prev_t) + 99) % 100) $fatal(1, "timer %h after %h", tcnt, prev_t);
                counts = counts + 1;
            end
            // ---------------- 555
            if (!d_game && !prev_game && sec) $fatal(1, "555 high a pixel after GAME fell");
            if (d_game && !prev_game) begin first555 = 1; since555 = -1; end
            if (since555 >= 0) since555 = since555 + 1;
            if (d_game && prev_game && sec != prev_sec) begin
                if (sec && since555 >= 0 && since555 != N5L) $fatal(1, "555 low for %0d pixels", since555);
                if (!sec && since555 != (first555 ? N5F : N5H)) $fatal(1, "555 high for %0d pixels", since555);
                if (!sec) first555 = 0;
                n555[sec] = n555[sec] + 1;
                since555 = 0;
            end
            // ---------------- one-shots
            if (!q49 && prev_q49) begin
                if (pixels - trig49_px != N49) $fatal(1, "IC49 pulse ended %0d pixels after its trigger", pixels - trig49_px);
                n49ok = n49ok + 1;
            end
            if (tiltq !== !d_ini_n) $fatal(1, "/INI RESET is not the tilt /Q");
            if (!tiltq && prev_tilt) begin
                // the power-up pulse runs from the reset
                if (pixels - trigtilt_px != NTILT && !(trigtilt_px == 0 && pixels == NTILT + 1))
                    $fatal(1, "tilt pulse ended %0d pixels after its trigger", pixels - trigtilt_px);
                ntiltok = ntiltok + 1;
            end
            // ---------------- game, extend
            if (d_game && !prev_game) begin
                games = games + 1;
                if (!prev_coin) $fatal(1, "GAME without COIN IN");
            end
            if (d_ext && !prev_ext) begin
                n_ext = n_ext + 1;
                if (tcnt != 0) $fatal(1, "EXTEND set with the timer at %h", tcnt);
            end
            if (!d_game && prev_game && !game_over_l && !d_mute && !prev_tilt) begin
                timeouts = timeouts + 1;
                if (tcnt != 0 || sec) $fatal(1, "game cleared with the timer at %h", tcnt);
            end
            if (!d_hi_n && prev_hi) his = his + 1;
            prev_sec = sec; prev_game = d_game; prev_q49 = q49; prev_tilt = tiltq; prev_ct = d_ct;
            prev_ext = d_ext; prev_hi = d_hi_n; prev_coin = d_coin; prev_t = tcnt;
            game_over_l = dut.i_game_over;
        end
        if (pcen && running) begin
            // ---------------- next pixel's stimulus
            if (v == 9'h1f4 && h == 9'h0a0) begin
                frames = frames + 1;
                vsdiv = vsdiv + 8'd1;
            end
            // Sheet N stand-in: /BONUS CP low pulses, BONUS SOUND toggling
            if (bcp_left > 0) begin
                bcp_left = bcp_left - 1;
                if (bcp_left == 0) bonus_cp_n <= 1;
            end else if (($random(seed_b) & 32'h7fffffff) % 20000 == 0) begin
                bcp_left = 1 + ($random(seed_b) & 4095);
                bonus_cp_n <= 0;
            end
            if (($random(seed_b) & 32'h7fffffff) % 3000 == 0) bonus_sound <= ~bonus_sound;
            if (wait_px > 0) wait_px = wait_px - 1;
            else case (stage)
                0: if (d_ini_n) begin stage = 1; wait_px = 3000; end           // power-up pulse over
                1: begin coin_sw <= 1; stage = 2; wait_px = 2000; end          // a coin
                2: begin coin_sw <= 0; stage = 3; wait_px = 3000; end
                3: begin acce_st <= 1; stage = 4; wait_px = 500; end           // start
                4: begin acce_st <= 0; stage = 5; wait_px = 40000; end
                5: begin                                                      // A30: four score pulses
                       a30 <= ~a30; wait_px = 700;
                       a30_edges = a30_edges + 1;
                       if (a30_edges == 8) begin stage = FAST ? 6 : 98; wait_px = 100; end
                   end
                6: if (d_ext) begin stage = 7; wait_px = 50000; end            // the timer runs out: EXTEND
                7: begin game_over <= 1; stage = 8; wait_px = 300; end         // sheet M ends the game
                8: begin game_over <= 0; stage = 9; wait_px = 3000; end
                9: begin coin_sw <= 1; stage = 10; wait_px = 1500; end         // second game, no extend
                10: begin coin_sw <= 0; stage = 11; wait_px = 2000; end
                11: begin acce_st <= 1; stage = 12; wait_px = 400; end
                12: begin acce_st <= 0; stage = 13; end
                13: if (!d_game) begin stage = 14; wait_px = 3000; end         // cleared at 00
                14: begin two_play <= 1; coin_sw <= 1; stage = 15; wait_px = 1500; end
                15: begin coin_sw <= 0; stage = 16; wait_px = 3000; end
                16: begin credit_sw <= 1; stage = 17; wait_px = 1500; end      // 2-play credit
                17: begin credit_sw <= 0; credits = credits + 1; stage = 18; wait_px = 3000; end
                18: begin test_sw <= 1; stage = 19; wait_px = 1500; end        // TEST
                19: begin test_sw <= 0; stage = 20; wait_px = 3000; end
                20: begin acce_st <= 1; stage = 21; wait_px = 400; end
                21: begin acce_st <= 0; stage = 22; wait_px = 60000; end
                22: begin tilt_n <= 0; stage = 23; wait_px = 200; end          // tilt in a game
                23: begin tilt_n <= 1; tilts = tilts + 1; stage = 24; rnd_frame0 = frames; end
                24: begin                                                     // random inputs
                    if (($random(seed) & 32'h7fffffff) % 20000 == 0) coin_sw <= ~coin_sw;
                    if (($random(seed) & 32'h7fffffff) % 30000 == 0) test_sw <= ~test_sw;
                    if (($random(seed) & 32'h7fffffff) % 20000 == 0) credit_sw <= ~credit_sw;
                    if (($random(seed) & 32'h7fffffff) % 200000 == 0) two_play <= ~two_play;
                    if (($random(seed) & 32'h7fffffff) % 8000 == 0) acce_st <= ~acce_st;
                    if (($random(seed) & 32'h7fffffff) % 900 == 0) a30 <= ~a30;
                    if (($random(seed) & 32'h7fffffff) % 300000 == 0) game_over <= 1;
                    else if (game_over && ($random(seed) & 255) == 0) game_over <= 0;
                    if (($random(seed) & 32'h7fffffff) % 600000 == 0) tilt_n <= 0;
                    else if (!tilt_n && ($random(seed) & 63) == 0) tilt_n <= 1;
                    if (frames - rnd_frame0 >= RANDOM_FRAMES) stage = 99;
                end
                98: if (frames >= FULL_FRAMES) stage = 99;               // full scale: one window
                default: ;
            endcase
        end
    end

    initial begin
        n555[0] = 0; n555[1] = 0;
        repeat(4) @(negedge clk);
        rst = 0;
        running = 1;
        wait (stage == 99);
        running = 0;
        $display("PASS coin%0s: %0d pixels over %0d frames match the pin-wired sheet A reference",
                 FAST ? " (capacitors / 1000)" : "", pixels, frames);
        $display("  timer: %0d loads to 90, %0d counts; 555 periods high %0d, low %0d (first %0d, then %0d/%0d pixels)",
                 loads, counts, n555[1], n555[0], N5F, N5H, N5L);
        $display("  games %0d, cleared at 00 %0d, EXTEND %0d, /HISCORE %0d, 2-play credits %0d, tilts %0d",
                 games, timeouts, n_ext, his, credits, tilts);
        $display("  IC49 pulses run out after exactly %0d pixels: %0d; tilt pulses after %0d: %0d",
                 N49, n49ok, NTILT, ntiltok);
        $display("  reference hazards absorbed: IC37 CK %0d/%0d; IC21 CPD %0d; IC20 CPD %0d; IC50 CK %0d; IC32 %0d/%0d/%0d",
                 reff.ic37a.fck.hazards, reff.ic37b.fck.hazards, reff.ic21.fcp.hazards, reff.ic20.fcp.hazards,
                 reff.ic50a.fck.hazards, reff.ic32k.fs1.hazards, reff.ic32k.fr.hazards, reff.ic32c.fs1.hazards);
        $display("  Pro gates (PRO=%0d): /BONUS CP low %0d px, %0d with /COIN IN high; BONUS SOUND high %0d px, %0d with the EX. CP AND low",
                 PRO, bcp_low, bcp_px, bsnd_high, bsnd_px);
        if (bcp_px == 0 || bsnd_px == 0)
            $fatal(1, "coverage: BONUS SOUND or /BONUS CP never reached a pixel where the Pro gate matters");
        if (FAST && (games < 3 || n_ext == 0 || timeouts == 0 || n49ok == 0 || ntiltok < 2 || counts < 90))
            $fatal(1, "coverage: a stage did not reach its part of the circuit");
        if (!FAST && (games == 0 || n49ok == 0 || n555[0] == 0 || n555[1] == 0))
            $fatal(1, "coverage: the full-scale run did not reach a 555 period and an IC49 pulse");
        $finish;
    end
endmodule
