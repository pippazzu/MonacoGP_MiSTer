// SPDX-License-Identifier: GPL-3.0-or-later
// The connected sheets (display 5): sheets A, B, C, D, F, G, H and M wired to
// each other in jtmonacogp_game.v, with the cabinet and sheet I from
// jtmonacogp_gtest.v. The picture is sheet C's. FAST = 1 divides the one-shot capacitors by 1000 and
// the 555's by 100 (one timer count in about 0.6 frames).
//
// The run follows a game from power-up: the tilt one-shot's power-up pulse,
// a coin, the pedal (which starts the game through ACCE. ST.), the gear
// lever, the handle both ways, and the timer down to 00, which ends the game.
// Checked, from the traces and the sheet notes:
// - no unknown video, and every sheet module settled before its next
//   capture (D and H at edge 1, A and F at edge 3);
// - the timer reads 00 before the first coin (TCLR at power-up);
// - before the coin sheet B shows its top text (GAME OVER: /COIN IN high)
//   and its bottom one (DEPOSIT COIN, while /GAME is high); during the game,
//   with no extend earned, the top text (EXTENDED PLAY) stays off, as on the
//   real game (Aldo, 30 October). Pad E1 carries COIN IN for this;
// - while COIN is pressed /COIN & TEST is low and the timer holds 90; on
//   release COIN IN is set; the pedal then sets GAME;
// - the timer reads 89 within a few pixels of GAME rising: the 555 output
//   rises as GAME releases its reset, and IC21 counts on that rise (on a
//   video of the real game 89 shows as the car appears, CONNECTED.md);
// - during the game the timer only counts down, by one at a time;
// - in low gear ACCE. stays at 6 or below;
// - sheet H's SP is PR-38's low nibble at {SP. CONT., ACCE.};
// - the handle moves sheet F's vertical target one way for left, the other
//   way for right;
// - the player car is drawn while the game runs;
// - at 00 GAME falls (no extended play: the S-100 code stays at none, so
//   pad A30 has no falls). With an extend earned sheet A would set EXTEND
//   instead and the game would go on until GAME OVER from sheet M (the
//   lives running out, Aldo), which the stand-ins hold low.
// - sheet C: every visible pixel of sheet B's top text is red (the red plane
//   has the highest priority).
// Reported, not checked: the colours of the bottom text and of the road
// (sheet C's levels: 15 full, 8 dim), the highest ACCE. in high gear (sheet F steps it
// once every 64 frames there) and the crashes. The car starts beside the
// road, where sheet F shakes it (docs/CONNECTED.md).
// Pictures of the connected view are written every 10 frames.
`timescale 1ns/1ps
module tb_play;
    reg clk=0,rst=1,rom=0,wr=0;
    always #10.416666667 clk=~clk;                   // 48 MHz
    reg [25:0] wa=0;
    reg [7:0] wd=0;
    reg [5:0] joy=6'b111111;
    reg [1:0] dial=2'b00;          // the wheel's sensors {A, B} through JTFRAME's dial
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
    // The sound board is left out here: with it the game takes too long in
    // Icarus. tests/tb_play_sound.v runs the start of a game with it.
    `include "tb_game_mem.vh"
    jtmonacogp_game #(.FAST(1),.SOUND(0),.RANK(0)) dut(
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

    // ---------------------------------------------------------------- checks
    reg [2:0] sr=0;
    always @(posedge clk) sr <= rst ? 3'd0 : {sr[1:0], pcen};
    wire e1 = sr[0], e3 = sr[2];
    reg running=0;
    integer frames=0, fp, pixels=0, car_px=0, car_px_game=0, other_px=0, crashes=0;
    integer bottom_col[0:4095], road_col[0:4095], ci, cbest, rbest;
    initial for (ci = 0; ci < 4096; ci = ci + 1) begin bottom_col[ci] = 0; road_col[ci] = 0; end
    integer timer_steps=0, max_acce_low=0, max_acce_high=0, sp_checks=0, since_game=-1;
    integer top_attract=0, bottom_attract=0, top_game=0;
    reg [7:0] timer_l=0;
    reg game_l=0, explo_l=0;
    wire [7:0] timer = {dut.a_t2, dut.a_t1};
    always @(posedge clk) if (running) begin
        if (e1 && (dut.h_busy || dut.scen_busy)) $fatal(1,"sheet D or H still settling at edge 1");
        if (e3 && (dut.a_busy || dut.f_busy)) $fatal(1,"sheet A or F still settling at edge 3");
        if (pcen) begin
            if ((^{r,g,b,hs,vs,lhbl,lvbl}) === 1'bx) $fatal(1,"unknown video output");
            if (debug_view !== 0) $fatal(1,"non-zero debug_view");
            if (!dut.a_coin_test_n && timer != 8'h90 && timer_l == 8'h90)
                $fatal(1,"timer %h while /COIN & TEST is low", timer);
            // First count: within 10 pixels of GAME rising
            if (dut.a_game && !game_l) since_game = 0;
            else if (since_game >= 0 && since_game < 10) begin
                since_game = since_game + 1;
                if (timer == 8'h89) since_game = 100 + since_game;
                else if (since_game == 10) $fatal(1,"timer %h 10 pixels after GAME rose", timer);
            end
            if (dut.a_game && game_l && timer != timer_l) begin
                if (timer != (timer_l[3:0] == 0 ? {timer_l[7:4] - 4'd1, 4'd9} : timer_l - 8'd1))
                    $fatal(1,"timer went from %h to %h", timer_l, timer);
                timer_steps = timer_steps + 1;
            end
            if (dut.a_game && !dut.high_gear && dut.f_acce > max_acce_low) max_acce_low = dut.f_acce;
            if (dut.a_game && dut.high_gear && dut.f_acce > max_acce_high) max_acce_high = dut.f_acce;
            // SP is reset to 0 until sheet H registers its first pixel
            if (frames > 0 && dut.u_cars.i_acce == dut.f_acce && dut.u_cars.i_spcont == dut.sp_cont &&
                dut.h_sp !== expected[8704 + {dut.sp_cont, dut.f_acce}][3:0] &&
                dut.u_cars.dbg[0] === dut.u_cars.dbg[0]) begin
                // SP is registered with the pixel; allow the pixel in which ACCE. changed
                if (dut.f_acce == acce_l && dut.f_acce == acce_ll)
                    $fatal(1,"SP %h for ACCE. %h, PR-38 gives %h (address %h, data %h, frame %0d)",
                           dut.h_sp, dut.f_acce, expected[8704 + {dut.sp_cont, dut.f_acce}][3:0],
                           dut.prom_addr[153+:9], dut.prom_q[17*8+:8], frames);
            end else if (frames > 0) sp_checks = sp_checks + 1;
            if (!dut.ex_gameover_n && !dut.a_coin_in) top_attract = top_attract + 1;
            if (!dut.coin_start_n && !dut.a_coin_in) bottom_attract = bottom_attract + 1;
            if (!dut.ex_gameover_n && dut.a_game) top_game = top_game + 1;
            if (dut.f_explo_st && !explo_l) crashes = crashes + 1;
            explo_l = dut.f_explo_st;
            // The picture inputs held for this pixel (as jtmonacogp_gview sees them)
            if (lhbl && lvbl && !dut.g_body_n) begin
                car_px = car_px + 1;
                if (dut.a_game) car_px_game = car_px_game + 1;
            end
            if (lhbl && lvbl && !(dut.h_other_body_n && dut.h_other_car_n)) other_px = other_px + 1;
            if (lhbl && lvbl && dut.y >= 8 && dut.y < 232) begin
                if (!dut.b_exgo_n && (g != 0 || b != 0 || r == 0))
                    $fatal(1,"top text pixel not red: %h at x=%0d y=%0d", {r,g,b}, dut.x, dut.y);
                if (!dut.b_coinst_n) bottom_col[{r,g,b}] = bottom_col[{r,g,b}] + 1;
                if (dut.road && dut.a_game) road_col[{r,g,b}] = road_col[{r,g,b}] + 1;
            end
            timer_l = timer;
            game_l = dut.a_game;
        end
    end
    reg [3:0] acce_l=0, acce_ll=0;
    always @(posedge clk) if (pcen) begin acce_ll <= acce_l; acce_l <= dut.f_acce; end

    // ---------------------------------------------------------------- pictures
    reg [11:0] pic[0:359][0:239];
    integer px, py;
    always @(posedge clk) if (pcen && lhbl && lvbl) pic[dut.x][dut.y] <= {r,g,b};
    task write_pic(input integer num);
        begin
            fp = $fopen($sformatf("%0s/play-%0d.ppm", outdir, num), "w");
            if (!fp) $fatal(1,"cannot open the picture file");
            $fwrite(fp, "P3\n360 240\n255\n");
            for (py = 0; py < 240; py = py + 1)
                for (px = 0; px < 360; px = px + 1)
                    $fwrite(fp, "%0d %0d %0d\n", pic[px][py][11:8]*17, pic[px][py][7:4]*17,
                            pic[px][py][3:0]*17);
            $fclose(fp);
        end
    endtask
    always @(negedge vs) if (running) begin
        frames = frames + 1;
        if (frames % 10 == 0) write_pic(frames);
    end

    task wait_frames(input integer n);
        repeat (n) @(negedge vs);
    endtask
    // Turn the wheel: n quarter steps of the quadrature, one every 8 lines
    // (two handle pulses a frame, as JTFRAME's dial emulation gave at its
    // highest sensitivity before JTFRAME_DIAL_EMUSENS=16; now its 8 setting). Right: 00, 01, 11, 10; left: 00, 10, 11, 01.
    task turn(input integer n, input right);
        integer i;
        for (i = 0; i < n; i = i + 1) begin
            repeat (8) @(negedge hs);
            dial = right ? (dial == 2'b00 ? 2'b01 : dial == 2'b01 ? 2'b11 : dial == 2'b11 ? 2'b10 : 2'b00)
                         : (dial == 2'b00 ? 2'b10 : dial == 2'b10 ? 2'b11 : dial == 2'b11 ? 2'b01 : 2'b00);
        end
    endtask

    integer v0, v1, v2, k;
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
        // Power-up: the tilt one-shot's pulse holds /INI RESET low. Then
        // attract frames, Vs/16 high in 8 of them.
        wait_frames(18);
        if (top_attract == 0 || bottom_attract == 0)
            $fatal(1,"before the coin: top text %0d, bottom text %0d pixels", top_attract, bottom_attract);
        if (!dut.a_ini_reset_n) $fatal(1,"/INI RESET still low after the power-up pulse");
        if (dut.a_game || dut.a_coin_in) $fatal(1,"a game before any coin");
        // The power-up pulse clears the timer (TCLR): it reads 00 until a coin
        if (timer != 8'h00) $fatal(1,"timer %h before the first coin", timer);
        // Coin
        coin[0] = 0;
        wait_frames(2);
        if (dut.a_coin_test_n || timer != 8'h90) $fatal(1,"COIN pressed: /COIN & TEST %b, timer %h", dut.a_coin_test_n, timer);
        coin[0] = 1;
        wait_frames(1);
        if (!dut.a_coin_in) $fatal(1,"COIN IN not set after the coin");
        if (dut.a_game) $fatal(1,"GAME before the pedal");
        // Pedal floored in low gear
        joy[4] = 0;
        k = 0;
        while (!dut.a_game && k < 20) begin wait_frames(1); k = k + 1; end
        if (!dut.a_game) $fatal(1,"the pedal did not start the game");
        $display("  game started %0d frames after the pedal; the timer read 89 %0d pixels after GAME rose",
                 k, since_game - 100);
        wait_frames(8);
        // High gear (button 2 changes over)
        joy[5] = 0; wait_frames(1); joy[5] = 1;
        wait_frames(10);
        // Handle: left, then right
        v0 = dut.f_vpos_t;
        turn(48, 0);                    // six frames to the left
        v1 = dut.f_vpos_t;
        turn(96, 1);                    // twelve frames to the right
        v2 = dut.f_vpos_t;
        $display("  vertical target: %0d, after left %0d, after right %0d", v0, v1, v2);
        if (v1 == v0 || v2 == v1 || (v1 > v0) == (v2 > v1))
            $fatal(1,"the handle does not move the target both ways");
        // Run the timer out
        k = 0;
        while (dut.a_game && k < 120) begin wait_frames(1); k = k + 1; end
        if (dut.a_game) $fatal(1,"the game did not end");
        if (timer != 8'h00) $fatal(1,"the game ended with the timer at %h", timer);
        wait_frames(2);
        running = 0;
        if (top_game != 0) $fatal(1,"top text (EXTENDED PLAY) on %0d pixels during the game", top_game);
        if (max_acce_low > 6 || timer_steps < 80 || car_px_game == 0)
            $fatal(1,"ACCE. low %0d high %0d, timer steps %0d, car pixels %0d",
                   max_acce_low, max_acce_high, timer_steps, car_px_game);
        $display("PASS play (one-shots / 1000, 555 / 100): %0d frames of the connected sheets", frames);
        $display("  timer counted down %0d times and the game ended at 00; ACCE. up to %0d in low gear, %0d in high gear",
                 timer_steps, max_acce_low, max_acce_high);
        $display("  before the coin: GAME OVER %0d pixels, DEPOSIT COIN %0d; top text during the game %0d",
                 top_attract, bottom_attract, top_game);
        $display("  SP = PR-38 low nibble at %0d pixels; crashes %0d; player car pixels %0d (%0d in the game), other-car pixels %0d",
                 sp_checks, crashes, car_px, car_px_game, other_px);
        cbest = 0; rbest = 0;
        for (ci = 0; ci < 4096; ci = ci + 1) begin
            if (bottom_col[ci] > bottom_col[cbest]) cbest = ci;
            if (road_col[ci] > road_col[rbest]) rbest = ci;
        end
        $display("  sheet C: top text all red; bottom text mostly RGB %h (%0d pixels); bare road in the game mostly RGB %h (%0d pixels)",
                 cbest[11:0], bottom_col[cbest], rbest[11:0], road_col[rbest]);
        $finish;
    end
endmodule
