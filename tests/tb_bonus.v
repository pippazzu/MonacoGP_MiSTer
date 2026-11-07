// SPDX-License-Identifier: GPL-3.0-or-later
// Pro sheet N, the bonus circuit. The RTL (jtmonacogp_bonus.v) and the
// pin-wired reference (tests/pro_sheet_n_reference.v) see the same stimulus,
// in three pairs: one for each setting of DU_LAG (0, the default, 1 and 2),
// the order at game over with 0 or 15 stored bonuses that the drawing does
// not settle. Each RTL is compared with a reference built with the same
// setting.
//
// - Every output and 24 bits of internal state (IC81, IC80, IC132, IC140,
//   IC94, the four one-shots, MAX/MIN and the reset net) are compared at
//   every pixel, and each RTL must settle before every edge 3.
// - Directed checks, written here from the trace:
//   IC140 only steps by one (or is loaded with 0 by /COIN & TEST and /INI.
//   RESET), and never passes 15 during play;
//   each payout gives 200 /BONUS POINT pulses per stored bonus, and /GAME
//   END falls when it is over; 0 stored gives none; 15 stored gives 3000
//   with DU_LAG = 0 and none with DU_LAG 1 and 2 (U5);
//   /BONUS POINT is low only while IC94 is set; /GAME END is low only with
//   /GAME high and IC94 clear;
//   W01 clears IC81, IC80, IC132 and IC140;
//   every IC107 pulse that runs out does so its width after its last trigger.
// The stimulus is not gameplay: the meaning of N's inputs on the Pro board
// is open (issue #36). V2, V4 and V5 come from a counter that advances one
// "line" every LINE_PX pixels, not the sheet E raster, so that a 15-bonus
// payout (3000 V5 periods) fits a short run. FAST = 1 divides the 74123
// capacitors by 1000.
// Stages: power-up reset, then games with 1 (cars, with a car-count clear by
// /ACC1 and by PR-38), 2 (bridge with PR-38-7 and 9 low, cars; the same
// bridge with them high gives none), 17 (saturation at 15) and 0 stored
// bonuses, each paid out; a payout cut by /INI. RESET and one cut by a coin;
// then random inputs.
`timescale 1ns/1ps
module tb_bonus #(parameter integer FAST = 1, LINE_PX = 2, RANDOM_PX = 400000,
                  parameter [31:0] SEED = 32'h4d4f4e4e);
    reg clk=0, rst=1;
    always #10.416666667 clk=~clk;                   // 48 MHz
    localparam real CS = FAST ? 1.0e-3 : 1.0;
    function integer px123(input real c_pf);
        px123 = $rtoi(0.28*47.0*c_pf*CS*(1.0+0.7/47.0)*7.1525e-3 + 0.5);
    endfunction
    localparam integer N100A = px123(3.3e6), N100B = px123(1.0e6),
                       N107A = px123(2.2e7), N107B = px123(3.3e6);

    wire pcen, p2cen;
    jtmonacogp_cen u_cen(.clk(clk),.cen14(p2cen),.cen7(pcen));

    // ---------------- Stimulus (changes at the 7 MHz edge)
    reg [9:0] vcnt = 0;
    integer line_px = 0;
    reg coin_test_n=1, ini_reset_n=1, bridge_ap_n=1, player_st=0, other_car_n=1, game=0;
    reg score_st_n=1, pr38_7=0, pr38_9=0, acc1_n=1;
    wire game_n = ~game;
    wire v2 = vcnt[2], v4 = vcnt[4], v5 = vcnt[5];

    // ---------------- Reference timing: the 7 MHz edge is the pixel boundary
    reg f7=0;
    reg [2:0] f7cnt=0;
    always @(posedge clk) begin
        if (pcen && !rst) begin f7<=1; f7cnt<=0; end
        else begin f7cnt<=f7cnt+3'd1; if (f7cnt==3'd2) f7<=0; end
    end
    wire r_v2, r_v4, r_v5, r_ct, r_ini, r_br, r_pl, r_oc, r_game, r_game_n, r_ss, r_p7, r_p9, r_acc;
    assign #5 {r_v2, r_v4, r_v5, r_ct, r_ini, r_br, r_pl, r_oc, r_game, r_game_n, r_ss, r_p7, r_p9, r_acc} =
              {v2, v4, v5, coin_test_n, ini_reset_n, bridge_ap_n, player_st, other_car_n,
               game, game_n, score_st_n, pr38_7, pr38_9, acc1_n};

    reg [4:0] sr=0;
    reg [2:0] tcen=0;
    always @(posedge clk) begin
        sr <= rst ? 5'd0 : {sr[3:0], pcen};
        tcen <= rst ? 3'd0 : {tcen[1:0], pcen};
    end
    integer pixels = 0, step_px = 0;
    reg running = 0, exact = 0;   // exact: directed payouts (no interruption expected)
    reg cut = 0;                  // this payout is cut by a reset or a coin
    // pixels: the index of the pixel compared at the next edge 4, counted at
    // edge 3 so that the checks at edge 4 read it without a race. One-shot
    // triggers in the settling steps that follow belong to the pixel compared
    // one compare later.
    always @(posedge clk) if (sr[2] && running) begin
        pixels = pixels + 1;
        step_px = pixels + 1;
    end

    // /GAME and /SCORE ST of the pixel being compared (the stimulus of the
    // pixel before); a low /SCORE ST ends IC107's second half early.
    reg gn_px = 1, ss_px = 1;
    wire game_n_px = gn_px;
    wire score_ok = ss_px;
    always @(posedge clk) if (pcen && running) begin
        gn_px <= game_n;
        ss_px <= score_st_n;
    end
    integer stage = 0, wait_px = 0, cars = 0, bonuses = 0, seed = SEED, rnd_px = 0;

    // ---------------- Three RTL / reference pairs
    genvar g;
    generate for (g = 0; g < 3; g = g + 1) begin : pair
        wire d_snd, d_bp_n, d_ge_n, d_cp, d_cp_n, busy;
        wire [3:0] d_bonus;
        wire [23:0] d_dbg;
        jtmonacogp_bonus #(.IC100A_PIXELS(N100A),.IC100B_PIXELS(N100B),
            .IC107A_PIXELS(N107A),.IC107B_PIXELS(N107B),.DU_LAG(g)) dut(
            .clk(clk),.rst(rst),.pxl_cen(pcen),
            .v2(v2),.v4(v4),.v5(v5),.coin_test_n(coin_test_n),.ini_reset_n(ini_reset_n),
            .bridge_ap_n(bridge_ap_n),.player_st(player_st),.other_car_n(other_car_n),
            .game(game),.game_n(game_n),.score_st_n(score_st_n),.pr38_7(pr38_7),.pr38_9(pr38_9),
            .acc1_n(acc1_n),
            .bonus_sound(d_snd),.bonus_point_n(d_bp_n),.game_end_n(d_ge_n),.bonus(d_bonus),
            .bonus_cp(d_cp),.bonus_cp_n(d_cp_n),.dbg(d_dbg),.busy(busy));
        wire r_snd, r_bp_n, r_ge_n, r_cp, r_cp_n;
        wire [3:0] r_bonus;
        wire [23:0] r_dbg;
        pro_sheet_n_reference #(.C39_PF(3.3e6*CS),.C33_PF(1.0e6*CS),.C41_PF(2.2e7*CS),
            .C40_PF(3.3e6*CS),.DU_LAG(g)) reff(.f7(f7),
            .n_v2(r_v2),.n_v4(r_v4),.n_v5(r_v5),.n_coin_test_n(r_ct),.n_ini_reset_n(r_ini),
            .n_bridge_ap_n(r_br),.n_player_st(r_pl),.n_other_car_n(r_oc),.n_game(r_game),
            .n_game_n(r_game_n),.n_score_st_n(r_ss),.n_pr38_7(r_p7),.n_pr38_9(r_p9),.n_acc1_n(r_acc),
            .bonus_sound(r_snd),.bonus_point_n(r_bp_n),.game_end_n(r_ge_n),.bonus(r_bonus),
            .bonus_cp(r_cp),.bonus_cp_n(r_cp_n),.dbg(r_dbg));
        wire [32:0] d_vec = {d_snd, d_bp_n, d_ge_n, d_bonus, d_cp, d_cp_n, d_dbg};
        wire [32:0] r_vec = {r_snd, r_bp_n, r_ge_n, r_bonus, r_cp, r_cp_n, r_dbg};
        reg [32:0] r_snap;
        // dbg fields
        wire       q81 = d_dbg[23];
        wire [3:0] q80a = d_dbg[22:19], q80b = d_dbg[18:15], q132 = d_dbg[14:11], q140 = d_dbg[10:7];
        wire       q94 = d_dbg[6], q100a = d_dbg[5], q100b = d_dbg[4], q107a = d_dbg[3], q107b = d_dbg[2];
        wire       mm = d_dbg[1], w01 = d_dbg[0];

        integer step_n = 0, last_change = 0, settle_max = 0;
        reg [23:0] live_q = 0;
        // Settling: no step may be left to do at the edge-3 register
        always @(negedge clk) if (!rst && running) begin
            if (tcen[2]) begin
                if (busy) $fatal(1, "DU_LAG %0d: RTL not settled before edge 3 at pixel %0d", g, pixels);
                if (last_change > settle_max) settle_max = last_change;
                last_change = 0;
                step_n = 0;
            end else begin
                step_n = step_n + 1;
                if (dut.state !== live_q) last_change = step_n;
            end
            live_q = dut.state;   // step_n 1 is the capture at edge 3, not a step
        end

        integer trig107a_px = -1, trig107b_px = -1, n107a_ok = 0, n107b_ok = 0, cp_trigs = 0;
        integer pulses = 0, payouts = 0, stored = 0, exp_pulses = 0, ups = 0, downs = 0, saturated = 0;
        integer escapes = 0, cuts = 0, zero_ends = 0, full_ends = 0;
        reg in_payout = 0, prev_bp = 1, prev_ge = 0, prev_q107a = 0, prev_q107b = 0, prev_gn = 1;
        reg [3:0] prev_q140 = 0;
        always @(posedge clk) begin
            if (pcen && !rst) r_snap <= r_vec;
            if (running && dut.trig107a) begin trig107a_px = step_px; cp_trigs = cp_trigs + 1; end
            if (running && dut.trig107b && dut.i_score_n) trig107b_px = step_px;
            if (sr[3] && running) begin
                if (^d_vec === 1'bx || ^r_snap === 1'bx)
                    $fatal(1, "DU_LAG %0d: unknown net at pixel %0d:\n RTL %b\n REF %b", g, pixels, d_vec, r_snap);
                if (d_vec !== r_snap)
                    $fatal(1, "DU_LAG %0d: sheet N mismatch at pixel %0d (stage %0d):\n RTL %b\n REF %b\n XOR %b",
                           g, pixels, stage, d_vec, r_snap, d_vec ^ r_snap);
                // ---------------- IC140
                if (w01) begin
                    if (q140 != 0 || q132 != 0 || q81 || q80a != 0 || q80b != 0)
                        $fatal(1, "DU_LAG %0d: W01 high but a counter is not clear", g);
                end else if (q140 != prev_q140) begin
                    if (q140 == prev_q140 + 4'd1) ups = ups + 1;
                    else if (q140 == prev_q140 - 4'd1) downs = downs + 1;
                    else $fatal(1, "DU_LAG %0d: IC140 went from %0d to %0d", g, prev_q140, q140);
                    if (exact && !d_dbg[6] && prev_gn == 0 && q140 == 0 && prev_q140 == 15)
                        $fatal(1, "DU_LAG %0d: IC140 passed 15 during play", g);
                end
                if (exact && !prev_gn && q140 == 15 && mm) saturated = 1;
                // ---------------- payout
                if (!d_bp_n && !q94) $fatal(1, "DU_LAG %0d: /BONUS POINT low with IC94 clear", g);
                if (!d_ge_n && (!game_n_px || q94))
                    $fatal(1, "DU_LAG %0d: /GAME END low with /GAME low or IC94 set", g);
                if (game_n_px && !prev_gn) begin
                    in_payout = 1; pulses = 0; stored = prev_q140;
                    exp_pulses = stored == 15 ? (g == 0 ? 3000 : 0) : 200 * stored;
                end
                // a pulse that starts with the payout (V5 already high) counts
                if (prev_bp && !d_bp_n) pulses = pulses + 1;
                if (in_payout && w01 && cut) begin
                    in_payout = 0;
                    cuts = cuts + 1;
                    if (pulses >= exp_pulses) $fatal(1, "DU_LAG %0d: the cut payout was not cut", g);
                    $display("  DU_LAG %0d: %0d stored, cut after %0d /BONUS POINT pulses", g, stored, pulses);
                end
                if (in_payout && !d_ge_n && prev_ge) begin
                    in_payout = 0;
                    payouts = payouts + 1;
                    if (stored == 0) zero_ends = zero_ends + 1;
                    if (stored == 15) full_ends = full_ends + 1;
                    if (exact && !cut) begin
                        if (pulses != exp_pulses)
                            $fatal(1, "DU_LAG %0d: %0d stored bonuses gave %0d /BONUS POINT pulses, expected %0d",
                                   g, stored, pulses, exp_pulses);
                        if (exp_pulses != 0 && (q140 != 0 || q81 || q80a != 0 || q80b != 0))
                            $fatal(1, "DU_LAG %0d: payout ended with IC140 %0d, divider %0d%0d%0d", g, q140, q80b, q80a, q81);
                        if (stored == 0) begin
                            if (q81) escapes = escapes + 1;
                            if (q81 != (g == 2)) $fatal(1, "DU_LAG %0d: 0 stored, IC81 %0d after game over", g, q81);
                        end
                        $display("  DU_LAG %0d: %0d stored -> %0d /BONUS POINT pulses", g, stored, pulses);
                    end
                end
                // ---------------- one-shot widths
                if (!q107a && prev_q107a) begin
                    if (pixels - trig107a_px != N107A)
                        $fatal(1, "DU_LAG %0d: BONUS CP ended %0d pixels after its trigger", g, pixels - trig107a_px);
                    n107a_ok = n107a_ok + 1;
                end
                if (!q107b && prev_q107b && score_ok) begin
                    if (pixels - trig107b_px != N107B)
                        $fatal(1, "DU_LAG %0d: IC107 Q5 ended %0d pixels after its trigger", g, pixels - trig107b_px);
                    n107b_ok = n107b_ok + 1;
                end
                prev_bp = d_bp_n; prev_ge = d_ge_n; prev_q107a = q107a; prev_q107b = q107b;
                prev_q140 = q140; prev_gn = game_n_px;
            end
        end
    end endgenerate

    // ---------------- Stimulus
    localparam integer CAR_GAP = FAST ? 400 : 330000;   // longer than IC100's first half
    localparam integer BONUS_GAP = FAST ? 2500 : 2200000; // longer than BONUS CP
    always @(posedge clk) if (pcen && running) begin
        if (line_px == LINE_PX - 1) begin line_px = 0; vcnt <= vcnt + 10'd1; end
        else line_px = line_px + 1;
        if (wait_px > 0) wait_px = wait_px - 1;
        else case (stage)
            // power-up: /INI. RESET
            0: begin ini_reset_n <= 0; stage = 1; wait_px = 50; end
            1: begin ini_reset_n <= 1; stage = 2; wait_px = 200; exact = 1; end
            // ---- game 1: one bonus from cars, with car-count clears
            2: begin coin_test_n <= 0; stage = 3; wait_px = 50; end
            3: begin coin_test_n <= 1; stage = 4; wait_px = 200; end
            4: begin game <= 1; player_st <= 1; stage = 5; wait_px = 300; cars = 8; end
            5: begin other_car_n <= 0; stage = 6; wait_px = 30; end          // a car
            6: begin other_car_n <= 1; wait_px = CAR_GAP; cars = cars - 1;
                   if (cars == 0) stage = 7; else stage = 5; end
            7: begin                                                       // /ACC1 clears IC132
                   if (pair[0].q132 != 8) $fatal(1, "8 cars counted as %0d", pair[0].q132);
                   acc1_n <= 0; stage = 8; wait_px = 20; end
            8: begin acc1_n <= 1; stage = 9; wait_px = 100; end
            9: begin
                   if (pair[0].q132 != 0) $fatal(1, "/ACC1 did not clear IC132");
                   cars = 3; stage = 10; end
            10: begin other_car_n <= 0; stage = 11; wait_px = 30; end
            11: begin other_car_n <= 1; cars = cars - 1;
                   if (cars == 0) begin stage = 12; wait_px = 100; end
                   else begin stage = 10; wait_px = CAR_GAP; end end
            12: begin                                                      // PR-38-7 and 9 during a car
                   if (pair[0].q132 != 2) $fatal(1, "3 cars (one running) counted as %0d", pair[0].q132);
                   pr38_7 <= 1; pr38_9 <= 1; stage = 13; wait_px = 20; end
            13: begin
                   if (pair[0].q132 != 0) $fatal(1, "PR-38-7 and 9 did not clear IC132");
                   pr38_7 <= 0; pr38_9 <= 0; stage = 14; wait_px = CAR_GAP; end
            14: begin                                                      // the running car counts as it ends
                   if (pair[0].q132 != 1) $fatal(1, "after the clear, IC132 holds %0d", pair[0].q132);
                   cars = 15; stage = 15; end
            15: begin other_car_n <= 0; stage = 16; wait_px = 30; end
            16: begin other_car_n <= 1; wait_px = CAR_GAP; cars = cars - 1;
                   if (cars == 0) begin stage = 17; wait_px = BONUS_GAP; end else stage = 15; end
            17: begin
                   if (pair[0].q140 != 1) $fatal(1, "16 cars gave %0d bonuses", pair[0].q140);
                   game <= 0; stage = 18; end                             // game over: 1 stored
            18: if (!pair[0].d_ge_n && !pair[0].q94) begin stage = 20; wait_px = 1000; end
            // ---- game 2: one bonus from the bridge, one from cars
            20: begin coin_test_n <= 0; stage = 21; wait_px = 50; end
            21: begin coin_test_n <= 1; stage = 22; wait_px = 200; end
            22: begin game <= 1; stage = 23; wait_px = 300; end
            // PR-38-7 and 9 are low here (D6 . D7 = 0), so GPR holds IC100.11
            // high and the bridge one-shot can run.
            23: begin bridge_ap_n <= 0; stage = 24; wait_px = 20; end      // bridge
            24: begin
                   if (!pair[0].q100b) $fatal(1, "D6 . D7 = 0: the bridge one-shot did not run");
                   bridge_ap_n <= 1; stage = 25; wait_px = 20; end
            25: begin other_car_n <= 0; stage = 26; wait_px = 30; end      // a car during it
            26: begin other_car_n <= 1; stage = 27; wait_px = BONUS_GAP; end
            27: begin
                   if (pair[0].q140 != 1) $fatal(1, "the bridge gave %0d bonuses", pair[0].q140);
                   pr38_7 <= 1; pr38_9 <= 1; stage = 34; wait_px = 20; end
            // the same bridge and car with PR-38-7 and 9 high (D6 . D7 = 1):
            // GPR holds IC100.11 low, so the bridge one-shot stays clear and
            // gives no bonus; the car clears the car count (IC143, IC53)
            34: begin bridge_ap_n <= 0; stage = 35; wait_px = 20; end      // bridge
            35: begin
                   if (pair[0].q100b) $fatal(1, "D6 . D7 = 1: the bridge one-shot ran");
                   bridge_ap_n <= 1; stage = 36; wait_px = 20; end
            36: begin other_car_n <= 0; stage = 37; wait_px = 30; end      // a car during it
            37: begin other_car_n <= 1; stage = 38; wait_px = BONUS_GAP; end
            38: begin
                   if (pair[0].q140 != 1)
                       $fatal(1, "D6 . D7 = 1: the bridge gave a bonus (%0d stored)", pair[0].q140);
                   stage = 28; end
            28: begin pr38_7 <= 0; pr38_9 <= 0; acc1_n <= 0; stage = 29; wait_px = 20; end
            29: begin acc1_n <= 1; cars = 16; stage = 30; wait_px = 100; end
            30: begin other_car_n <= 0; stage = 31; wait_px = 30; end
            31: begin other_car_n <= 1; wait_px = CAR_GAP; cars = cars - 1;
                   if (cars == 0) begin stage = 32; wait_px = BONUS_GAP; end else stage = 30; end
            32: begin
                   if (pair[0].q140 != 2) $fatal(1, "game 2 stored %0d bonuses", pair[0].q140);
                   game <= 0; stage = 33; end                             // 2 stored
            33: if (!pair[0].d_ge_n && !pair[0].q94) begin stage = 40; wait_px = 1000; end
            // ---- game 3: 17 bonuses, stored 15
            40: begin coin_test_n <= 0; stage = 41; wait_px = 50; end
            41: begin coin_test_n <= 1; stage = 42; wait_px = 200; end
            42: begin game <= 1; stage = 43; wait_px = 300; bonuses = 17; end
            43: begin bridge_ap_n <= 0; stage = 44; wait_px = 20; end
            44: begin bridge_ap_n <= 1; other_car_n <= 0; stage = 45; wait_px = 30; end
            45: begin other_car_n <= 1; bonuses = bonuses - 1; wait_px = FAST ? 700 : 600000;
                    if (bonuses == 0) begin stage = 46; wait_px = BONUS_GAP; end else stage = 43; end
            46: begin
                   if (pair[0].q140 != 15) $fatal(1, "17 bonuses stored as %0d", pair[0].q140);
                   if (!pair[0].saturated) $fatal(1, "IC140 did not hold at 15");
                   game <= 0; stage = 47; end                             // 15 stored
            47: if (!pair[0].d_ge_n && !pair[0].q94) begin stage = 50; wait_px = 1000; end
            // ---- game 4: none stored; game over while V5 is high
            50: begin coin_test_n <= 0; stage = 51; wait_px = 50; end
            51: begin coin_test_n <= 1; stage = 52; wait_px = 200; end
            52: begin game <= 1; stage = 53; wait_px = 3000; end
            53: if (vcnt[5:3] == 3'b110 && line_px == 0) begin game <= 0; stage = 54; wait_px = 1000; end
            // ---- game 5: three stored, payout cut by /INI. RESET
            54: begin coin_test_n <= 0; stage = 55; wait_px = 50; end
            55: begin coin_test_n <= 1; stage = 56; wait_px = 200; end
            56: begin game <= 1; stage = 57; wait_px = 300; bonuses = 3; end
            57: begin bridge_ap_n <= 0; stage = 58; wait_px = 20; end
            58: begin bridge_ap_n <= 1; other_car_n <= 0; stage = 59; wait_px = 30; end
            59: begin other_car_n <= 1; bonuses = bonuses - 1; wait_px = FAST ? 700 : 600000;
                    if (bonuses == 0) begin stage = 60; wait_px = BONUS_GAP; end else stage = 57; end
            60: begin game <= 0; stage = 61; wait_px = 250 * 64 * LINE_PX; cut = 1; end
            61: begin ini_reset_n <= 0; stage = 62; wait_px = 50; end
            62: begin ini_reset_n <= 1; stage = 63; wait_px = 500; end
            63: begin cut = 0; stage = 64; wait_px = 500; end
            // ---- game 6: two stored, payout cut by a coin
            64: begin coin_test_n <= 0; stage = 65; wait_px = 50; end
            65: begin coin_test_n <= 1; stage = 66; wait_px = 200; end
            66: begin game <= 1; stage = 67; wait_px = 300; bonuses = 2; end
            67: begin bridge_ap_n <= 0; stage = 68; wait_px = 20; end
            68: begin bridge_ap_n <= 1; other_car_n <= 0; stage = 69; wait_px = 30; end
            69: begin other_car_n <= 1; bonuses = bonuses - 1; wait_px = FAST ? 700 : 600000;
                    if (bonuses == 0) begin stage = 70; wait_px = BONUS_GAP; end else stage = 67; end
            70: begin game <= 0; stage = 71; wait_px = 100 * 64 * LINE_PX; cut = 1; end
            71: begin coin_test_n <= 0; stage = 72; wait_px = 50; end
            72: begin coin_test_n <= 1; stage = 73; wait_px = 500; end
            73: begin cut = 0; exact = 0; stage = 80; rnd_px = 0; end
            // ---- random inputs
            80: begin
                    if (($random(seed) & 32'h7fffffff) % 40000 == 0) coin_test_n <= 0;
                    else if (!coin_test_n && ($random(seed) & 63) == 0) coin_test_n <= 1;
                    if (($random(seed) & 32'h7fffffff) % 150000 == 0) ini_reset_n <= 0;
                    else if (!ini_reset_n && ($random(seed) & 63) == 0) ini_reset_n <= 1;
                    if (($random(seed) & 32'h7fffffff) % 30000 == 0) game <= ~game;
                    if (($random(seed) & 32'h7fffffff) % 700 == 0) other_car_n <= ~other_car_n;
                    if (($random(seed) & 32'h7fffffff) % 3000 == 0) bridge_ap_n <= ~bridge_ap_n;
                    if (($random(seed) & 32'h7fffffff) % 5000 == 0) player_st <= ~player_st;
                    if (($random(seed) & 32'h7fffffff) % 4000 == 0) score_st_n <= 0;
                    else if (!score_st_n && ($random(seed) & 15) == 0) score_st_n <= 1;
                    if (($random(seed) & 32'h7fffffff) % 3000 == 0) pr38_7 <= ~pr38_7;
                    if (($random(seed) & 32'h7fffffff) % 3000 == 0) pr38_9 <= ~pr38_9;
                    if (($random(seed) & 32'h7fffffff) % 6000 == 0) acc1_n <= 0;
                    else if (!acc1_n && ($random(seed) & 31) == 0) acc1_n <= 1;
                    rnd_px = rnd_px + 1;
                    if (rnd_px >= RANDOM_PX) stage = 99;
                end
            default: ;
        endcase
    end

    initial begin
        repeat(4) @(negedge clk);
        rst = 0;
        running = 1;
        wait (stage == 99);
        running = 0;
        $display("PASS bonus%0s: %0d pixels match the pin-wired sheet N reference for DU_LAG 0, 1 and 2",
                 FAST ? " (capacitors / 1000)" : "", pixels);
        `define SUMMARY(G) \
        $display("  DU_LAG %0d: %0d payouts (%0d with 0 stored, %0d with 15), %0d cut; IC140 %0d up, %0d down; BONUS CP %0d triggers, %0d pulses of %0d px exact; IC107 Q5 %0d of %0d px exact; 0-stored escapes %0d; settled in at most %0d steps", \
                 G, pair[G].payouts, pair[G].zero_ends, pair[G].full_ends, pair[G].cuts, pair[G].ups, pair[G].downs, \
                 pair[G].cp_trigs, pair[G].n107a_ok, N107A, pair[G].n107b_ok, N107B, pair[G].escapes, pair[G].settle_max - 1); \
        $display("    reference hazards absorbed: IC81 CK %0d, IC140 CK %0d, IC107 B %0d/%0d", \
                 pair[G].reff.ic81.u1.fck.hazards, pair[G].reff.ic140.fck.hazards, \
                 pair[G].reff.ic107.u1.fb.hazards, pair[G].reff.ic107.u2.fb.hazards);
        `SUMMARY(0)
        `SUMMARY(1)
        `SUMMARY(2)
        if (pair[0].payouts < 6 || pair[0].cuts != 2 || pair[0].n107a_ok == 0 || pair[0].n107b_ok == 0 ||
            pair[0].zero_ends == 0 || pair[0].full_ends == 0)
            $fatal(1, "coverage: a stage did not reach its part of the circuit");
        $finish;
    end
endmodule
