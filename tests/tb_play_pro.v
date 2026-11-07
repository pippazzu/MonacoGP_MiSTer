// SPDX-License-Identifier: GPL-3.0-or-later
// The connected sheets on the Pro board (jtmonacogp_game PRO = 1): sheet N's
// bonus circuit wired to sheets A, D, E, F, G and H (pro/docs/SHEET_N_LOGIC.md,
// "Pro board"), from power-up through a game and its bonus payout. As
// tests/tb_play.v: FAST = 1 (one-shot capacitors / 1000, the 555's / 100),
// no sound board, no sheets I (rank part), J and K.
//
// The run: a coin, the pedal floored in low gear (which starts the game),
// and the timer run out, as in tests/tb_play.v. The other cars pass the
// player car, so overlaps (an other-car pixel inside the PLAYER ST span)
// reach sheet N from the game's own nets.
//
// TEST STIMULUS, NOT GAMEPLAY: a fast player. In this core the car starts
// beside the road, where it shakes, the handle is switched out and ACCE.
// stays at 0-2 (docs/CONNECTED.md, open items), and ACCE. climbs one step
// every 16 frames, while the shortened game lasts about 54 frames. So the
// player is always in PR-38's slow-player range (D6 . D7 = 1, which in
// Monaco GP's PR-38 dump is ACCE. 0-4 with SP. CONT. low), where every
// overlap clears the car count and the bridge one-shot is held clear: the
// cars overtake the player, and the game never earns a bonus. To reach the
// payout, the bench holds sheet N's two PR-38 inputs (PR-38-7, PR-38-9)
// low from the start of the game until the first bonus is stored, as a
// fast player's PR-38 data would; sheet H and everything else keep their
// own nets. After that the real PR-38 bits are back, the next overlaps
// clear the count, and the stored count stays small, which keeps the
// payout (200 V5 periods, about 50 frames, per bonus) short.
//
// With FAST = 1, sheet N's one-shots are / 1000 too (game.v divides them by
// CS like every sheet's): IC100's 44 ms overlap pulse becomes 315 pixels,
// shorter than a line, so each line of an other car inside the PLAYER ST
// span is a separate overlap episode, where with the drawn values one car
// passing is one. Bonuses come many times faster than on the board; the
// payout is not shortened (V5 is the raster).
//
// Checked, from the traces:
// - no unknown video; sheets A, F and N settled before their next capture
//   (edge 3), D and H before edge 1;
// - IC140 (the bonus store) holds 0 from power-up to the game, only steps by
//   one, never passes 15, and does not change between the end of the game
//   and the start of the payout;
// - /BONUS POINT stays high during the game and while GAME is low before
//   it; after the game it pulses exactly 200 times per stored bonus, then
//   stays high; /GAME END goes low once the payout is over (and IC140 is 0);
// - the score (the Pro sheet I counter, through the Pro sheet F gate) steps
//   by one at the start of each /BONUS POINT pulse, 200 per stored bonus:
//   /SCORE CP = /BONUS POINT AND NOT(/SCORE ST AND Y) falls with it, and on
//   the Pro board /SCORE CP clocks the first 74390 decade directly, on its
//   falling edge (pro/docs/trace/SHEET_I_TRACE.md; on the original board
//   13H inverts it and the step came at the end of the pulse); the only
//   other step allowed after the game is one within 16 pixels of its end,
//   while sheet F's normal score NAND was low then (a normal score pulse
//   ended by /GAME clearing the score divider);
// - BONUS A-D (pads M1-M4) carry IC140 while V2 is high and IC132 while V2
//   is low (IC133);
// - at least one bonus is earned.
`timescale 1ns/1ps
module tb_play_pro;
    reg clk=0,rst=1,rom=0,wr=0;
    always #10.416666667 clk=~clk;                   // 48 MHz
    reg [25:0] wa=0;
    reg [7:0] wd=0;
    reg [5:0] joy=6'b111111;
    reg [1:0] dial=2'b00;
    reg [3:0] coin=4'hf, cab=4'hf;
    reg [31:0] status=0;
    wire pcen,p2cen,lhbl,lvbl,hs,vs;
    wire [3:0] r,g,b;
    wire signed [15:0] snd;
    wire [7:0] debug_view;
    wire [3:0] rd,write_bank;
    wire prog_we,prog_rd,busy;
    reg [7:0] expected[0:8799];
    reg [1023:0] path,outdir;
    `include "tb_game_mem.vh"
    jtmonacogp_game #(.FAST(1),.SOUND(0),.RANK(0),.PRO(1)) dut(
`include "tb_game_mem_ports.vh"
        .clk(clk),.rst(rst),.rst24(rst),.clk24(clk),.rst96(rst),.clk96(clk),
        .pxl_cen(pcen),.pxl2_cen(p2cen),.red(r),.green(g),.blue(b),
        .LHBL(lhbl),.LVBL(lvbl),.HS(hs),.VS(vs),
        .cab_1p(cab),.coin(coin),.joystick1(joy),.joystick2(6'h3f),
        .joystick3(6'h3f),.joystick4(6'h3f),.dial_x(dial),.dial_y(2'b00),
        .joyana_l1(16'd0),.joyana_l2(16'd0),.joyana_l3(16'd0),.joyana_l4(16'd0),
        .joyana_r1(16'd0),.joyana_r2(16'd0),.joyana_r3(16'd0),.joyana_r4(16'd0),
        .snd_en(6'h3f),.snd_vol(8'hff),.status(status),.dipsw(32'd0),
        .dip_pause(1'b1),.dip_test(1'b1),.service(1'b1),.tilt(1'b1),
        .dip_fxlevel(2'b00),.gfx_en(4'hf),.debug_bus(8'd0),.debug_view(debug_view),
        .ioctl_ram(1'b0),.ioctl_cart(1'b0),
        .snd(snd));

    // Score digits as a number, 0..9999
    function integer bcd(input [15:0] d);
        bcd = d[15:12]*1000 + d[11:8]*100 + d[7:4]*10 + d[3:0];
    endfunction

    // ---------------------------------------------------------------- checks
    reg [2:0] sr=0;
    always @(posedge clk) sr <= rst ? 3'd0 : {sr[1:0], pcen};
    wire e1 = sr[0], e3 = sr[2];
    reg running=0, after_game=0;
    integer frames=0, k, n_stored=-1, score0=0, bp_pulses=0, bonus_checks=0;
    integer ups=0, downs=0, overlaps=0, slow_px=0, game_frames=0, crashes=0;
    integer forced_overlaps=0, forced_frames=0;
    reg forced=0;
    reg bp_l=1, explo_l=0, ov_l=0, game_l=0;
    integer end_frame=0;
    reg [15:0] score_l=0;
    integer since_bp=1000000, since_end=0, bonus_steps=0, other_steps=0;
    reg normal_low=0;
    reg [3:0] q140_l=0;
    reg [2:0] stable=0;
    reg [8:0] stable_l=0;
    wire [3:0] q140 = dut.u_bonus.q140, q132 = dut.u_bonus.q132;
    always @(posedge clk) if (running) begin
        if (e1 && (dut.h_busy || dut.scen_busy)) $fatal(1,"sheet D or H still settling at edge 1");
        if (e3 && (dut.a_busy || dut.f_busy || dut.n_busy)) $fatal(1,"sheet A, F or N still settling at edge 3");
        if (pcen) begin
            // The end of the game: GAME falls (and /GAME rises), IC140 turns
            // to count down, normal scoring stops
            if (game_l && !dut.a_game && !after_game) begin
                after_game = 1;
                n_stored = q140;
                score0 = bcd(dut.score);
                end_frame = frames;
                // sheet F's normal score NAND (IC8 9, 10 -> 8) at that moment
                normal_low = dut.u_control.i_score_st_n & dut.u_control.z4;
                if (bp_pulses != 0) $fatal(1,"%0d /BONUS POINT pulses during the game", bp_pulses);
            end
            game_l = dut.a_game;
            if ((^{r,g,b,hs,vs,lhbl,lvbl}) === 1'bx) $fatal(1,"unknown video output");
            if ((^{dut.n_bonus_sound,dut.n_bonus_point_n,dut.n_bonus_cp,dut.n_bonus_cp_n,
                   dut.n_bonus,dut.n_game_end_n}) === 1'bx) $fatal(1,"unknown sheet N output");
            if (q140 != q140_l) begin
                if (q140 == q140_l + 4'd1) ups = ups + 1;
                else if (q140 == q140_l - 4'd1) downs = downs + 1;
                else $fatal(1,"IC140 went from %0d to %0d", q140_l, q140);
                if (!after_game && !dut.a_game) $fatal(1,"IC140 changed to %0d outside the game", q140);
                if (after_game && q140 > q140_l) $fatal(1,"IC140 counted up after the game");
            end
            q140_l = q140;
            // /BONUS POINT: only after the game
            if (!dut.n_bonus_point_n && !after_game)
                $fatal(1,"/BONUS POINT low before the end of the game (frame %0d)", frames);
            if (bp_l && !dut.n_bonus_point_n) bp_pulses = bp_pulses + 1;
            // pixels since /BONUS POINT last fell (the start of a pulse)
            if (bp_l && !dut.n_bonus_point_n) since_bp = 0;
            else if (since_bp < 1000000) since_bp = since_bp + 1;
            if (after_game && since_end < 1000000) since_end = since_end + 1;
            // Score steps after the game: one at the start of each /BONUS POINT
            // pulse (sheet F, then sheet I a few pixels later), and any other
            if (after_game && dut.score != score_l) begin
                if (bcd(dut.score) != (bcd(score_l) + 1) % 10000)
                    $fatal(1,"score went from %h to %h after the game", score_l, dut.score);
                if (since_bp <= 8) bonus_steps = bonus_steps + 1;
                else begin
                    other_steps = other_steps + 1;
                    $display("  a score step %0d pixels after the end of the game, not at the start of a /BONUS POINT pulse (%0d pulses so far; the normal score NAND was %0s then)",
                             since_end, bp_pulses, normal_low ? "low" : "high");
                    if (since_end > 16 || !normal_low)
                        $fatal(1,"score step %0d pixels after the end of the game, away from /BONUS POINT", since_end);
                end
            end
            score_l = dut.score;
            bp_l = dut.n_bonus_point_n;
            // BONUS A-D (IC133): IC140 with V2 high, IC132 with V2 low, once
            // V2 and both counters have been steady for a few pixels (the
            // outputs are registered a pixel late)
            stable = {dut.v[2], q140, q132} != stable_l ? 3'd0 : stable == 3'd7 ? stable : stable + 3'd1;
            stable_l = {dut.v[2], q140, q132};
            if (stable == 3'd7) begin
                if (dut.n_bonus !== (dut.v[2] ? q140 : q132))
                    $fatal(1,"BONUS A-D %h with V2 %b: IC140 %h IC132 %h", dut.n_bonus, dut.v[2], q140, q132);
                bonus_checks = bonus_checks + 1;
            end
            if (dut.a_game) begin
                if (dut.u_bonus.q100a && !ov_l) overlaps = overlaps + 1;
                // sheet H's PR-38 D6 . D7, whatever N is given
                if (dut.prom_q[17*8+6] && dut.prom_q[17*8+7]) slow_px = slow_px + 1;
                if (forced && dut.u_bonus.q100a && !ov_l) forced_overlaps = forced_overlaps + 1;
            end
            ov_l = dut.u_bonus.q100a;
            if (dut.f_explo_st && !explo_l) crashes = crashes + 1;
            explo_l = dut.f_explo_st;
        end
    end

    always @(negedge vs) if (running) begin
        frames = frames + 1;
        if (dut.a_game) game_frames = game_frames + 1;
        if (frames % 5 == 0)
            $display("  frame %0d: GAME %b ACCE. %0d; IC132 %0d IC140 %0d; overlaps %0d, slow-player pixels %0d, crashes %0d; score %h; timer %h%h",
                     frames, dut.a_game, dut.f_acce, q132, q140, overlaps, slow_px, crashes, dut.score, dut.a_t2, dut.a_t1);
        $fflush;
    end

    task wait_frames(input integer n);
        repeat (n) @(negedge vs);
    endtask

    initial begin
        if (!$value$plusargs("ROM=%s",path) || !$value$plusargs("OUT=%s",outdir)) $fatal(1,"missing ROM/OUT");
        $readmemh(path,expected);
        status[15:13] = 5;
        repeat(4) @(negedge clk);
        rom=1;
        for (k=0;k<8800;k=k+1) begin
            @(negedge clk); wa=k; wd=expected[k]; wr=1;
        end
        @(negedge clk); wr=0; rom=0; rst=0;
        running=1;
        // Power-up: the tilt one-shot's pulse holds /INI RESET low; it
        // loads IC140 with 0.
        wait_frames(3);
        if (!dut.a_ini_reset_n) $fatal(1,"/INI RESET still low after the power-up pulse");
        if (dut.a_game || q140 != 0) $fatal(1,"before the coin: GAME %b, IC140 %0d", dut.a_game, q140);
        if (dut.n_game_end_n) $fatal(1,"/GAME END high before the first game");
        // Coin, then the pedal floored in low gear
        coin[0] = 0; wait_frames(2); coin[0] = 1; wait_frames(1);
        if (!dut.a_coin_in) $fatal(1,"COIN IN not set after the coin");
        joy[4] = 0;
        k = 0;
        while (!dut.a_game && k < 20) begin wait_frames(1); k = k + 1; end
        if (!dut.a_game) $fatal(1,"the pedal did not start the game");
        if (!dut.n_game_end_n) $fatal(1,"/GAME END low during the game");
        // The fast-player stand-in (see the header): N's PR-38 inputs low
        // until the first bonus is stored
        force dut.u_bonus.pr38_7 = 1'b0;
        force dut.u_bonus.pr38_9 = 1'b0;
        forced = 1;
        k = 0;
        while (dut.a_game && q140 == 0 && k < 120) begin wait_frames(1); k = k + 1; end
        if (q140 == 0) $fatal(1,"no bonus stored in %0d frames of driving (%0d overlap pulses)", k, overlaps);
        release dut.u_bonus.pr38_7;
        release dut.u_bonus.pr38_9;
        forced = 0;
        forced_frames = k;
        $display("  first bonus stored at frame %0d, %0d frames into the game (%0d overlap pulses); N's PR-38 inputs released",
                 frames, k, overlaps);
        // Run the timer out
        k = 0;
        while (dut.a_game && k < 150) begin wait_frames(1); k = k + 1; end
        if (dut.a_game) $fatal(1,"the game did not end");
        repeat (8) @(posedge clk);
        if (!after_game) $fatal(1,"the end of the game was not seen");
        $display("  game over at frame %0d (%0d frames of game): %0d bonuses stored, score %0d",
                 end_frame, game_frames, n_stored, score0);
        // The payout: 200 V5 periods (4 a frame) per bonus
        k = 0;
        while (dut.n_game_end_n && k < n_stored*52 + 10) begin wait_frames(1); k = k + 1; end
        if (dut.n_game_end_n) $fatal(1,"/GAME END still high %0d frames after the game (%0d pulses)", k, bp_pulses);
        if (q140 != 0) $fatal(1,"/GAME END low with %0d bonuses still stored", q140);
        wait_frames(3);
        running = 0;
        if (bp_pulses != 200*n_stored)
            $fatal(1,"%0d /BONUS POINT pulses for %0d stored bonuses", bp_pulses, n_stored);
        // 200 points per bonus, one at the start of each pulse; at most one
        // other step, just after the end of the game (a normal score pulse
        // cut short by /GAME clearing the score divider)
        if (bonus_steps != 200*n_stored || other_steps > 1 ||
            bcd(dut.score) != (score0 + bonus_steps + other_steps) % 10000)
            $fatal(1,"score %h after the payout, %0d before, %0d stored bonuses: %0d steps at /BONUS POINT, %0d others",
                   dut.score, score0, n_stored, bonus_steps, other_steps);
        if (!dut.n_bonus_point_n) $fatal(1,"/BONUS POINT low after the payout");
        if (dut.u_bonus.q80a != 0 || dut.u_bonus.q80b != 0 || dut.u_bonus.q81 != 0)
            $fatal(1,"divider not back at 0 after the payout");
        if (bonus_checks == 0) $fatal(1,"BONUS A-D never compared");
        $display("PASS play_pro (Pro board, one-shots / 1000, 555 / 100): %0d frames of the connected sheets with sheet N", frames);
        $display("  %0d bonuses stored in the game (IC140 up %0d, down %0d); %0d /BONUS POINT pulses after it, in %0d frames; score %0d -> %0d: +%0d at the starts of the pulses (200 x %0d), +%0d just after the end of the game",
                 n_stored, ups, downs, bp_pulses, k, score0, bcd(dut.score), bonus_steps, n_stored, other_steps);
        $display("  %0d overlap pulses (IC100 first half) in the game, %0d of them in the %0d frames with N's PR-38 inputs held low (fast-player stand-in); sheet H's PR-38 D6 . D7 = 1 at %0d game pixels; %0d crashes; BONUS A-D = IC140/IC132 by V2 at %0d pixels",
                 overlaps, forced_overlaps, forced_frames, slow_px, crashes, bonus_checks);
        $finish;
    end
endmodule
