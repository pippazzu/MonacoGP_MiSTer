// SPDX-License-Identifier: GPL-3.0-or-later
// The connected sheets (display 5) with the sound board, from power-up to
// the first seconds of a game; one-shot capacitors / 1000 and the 555's /
// 100 as in tests/tb_play.v. Power-up and attract frames, a coin, the pedal
// floored in low gear, the change to high gear, the pedal released.
// Checked here:
// - a sample every 1000 clocks (48 kHz), never unknown; with JTFRAME_STEREO
//   (the MiSTer build) the left channel is SOUND OUT and the right channel
//   SOUND OUT, or BACK SOUND OUT (D-2's pad R) while OSD "Back speaker" is
//   on (from the game's start);
// - the sound board's inputs are the sheets' outputs, and its gates follow
//   the game: before the coin MY CAR SOUND ON is low and SOUND OUT is muted;
//   during the game (no crash) MY CAR SOUND ON is high, nothing is muted and
//   SHIFT A follows the gear lever;
// - the engine is heard during the game (peak above 1000, 0.04 V on pad 13)
//   and not before the coin (peak below 350).
// About 30 frames: Icarus runs the game about four times slower with the
// sound board.
// Every model step goes to OUT/play_sound_steps.txt (the format of
// tests/tb_sound.v), which tests/sound/sound_check.py compares with the
// fixed-point twin; it writes OUT/play_sound.wav.
`timescale 1ns/1ps
module tb_play_sound;
    reg clk=0,rst=1,rom=0,wr=0;
    always #10.416666667 clk=~clk;                   // 48 MHz
    reg [25:0] wa=0;
    reg [7:0] wd=0;
    reg [5:0] joy=6'b111111;
    reg [3:0] coin=4'hf;
    reg [31:0] status=0;
    wire pcen,p2cen,lhbl,lvbl,hs,vs;
    wire [3:0] r,g,b;
    wire signed [15:0] snd, snd_r;
    wire sample;
    wire [7:0] debug_view;
    wire [3:0] rd,write_bank;
    wire prog_we,prog_rd,busy;
    reg [7:0] expected[0:8799];
    reg [1023:0] path,outdir;
    `include "tb_game_mem.vh"
    jtmonacogp_game #(.FAST(1)) dut(
`include "tb_game_mem_ports.vh"
        .clk(clk),.rst(rst),.rst24(rst),.clk24(clk),.rst96(rst),.clk96(clk),
        .pxl_cen(pcen),.pxl2_cen(p2cen),.red(r),.green(g),.blue(b),
        .LHBL(lhbl),.LVBL(lvbl),.HS(hs),.VS(vs),
        .cab_1p(4'hf),.coin(coin),.joystick1(joy),.joystick2(6'h3f),
        .joystick3(6'h3f),.joystick4(6'h3f),.dial_x(2'b00),.dial_y(2'b00),
        .joyana_l1(16'd0),.joyana_l2(16'd0),.joyana_l3(16'd0),.joyana_l4(16'd0),
        .joyana_r1(16'd0),.joyana_r2(16'd0),.joyana_r3(16'd0),.joyana_r4(16'd0),
        .snd_en(6'h3f),.snd_vol(8'hff),.status(status),.dipsw(32'd0),
        .dip_pause(1'b1),.dip_test(1'b1),.service(1'b1),.tilt(1'b1),
        .dip_fxlevel(2'b00),.gfx_en(4'hf),.debug_bus(8'd0),.debug_view(debug_view),
        .ioctl_ram(1'b0),.ioctl_cart(1'b0),
        .snd_left(snd),.snd_right(snd_r),.sample(sample));

    // ---------------------------------------------------------------- steps
    // as tests/tb_sound.v: one line per model step, written when the next
    // step's inputs are taken
    integer fd, rows=0, clocks=0, last_sample=-1, samples=0;
    reg have=0, got=0;
    reg signed [15:0] got_snd = 0, got_b = 0;
    reg [3:0] r_acce;
    reg r_s_acc1_n, r_coin_in_n, r_game_n, r_shift, r_nonroad, r_excp, r_resc, r_back, r_slip;
    reg r_hs, r_mpad;
    wire signed [15:0] snd_b = dut.g_sound.u_sound.snd_b;
    wire [6:0] scnt = dut.g_sound.u_sound.cnt;
    // pad C as the other cars' block takes it (see tests/tb_sound.v)
    reg fs_acc = 0, fs_step = 0;
    always @(posedge clk) if (!rst) begin
        if (dut.g_sound.u_sound.tick) begin fs_step <= fs_acc; fs_acc <= !dut.h_f_sound_n; end
        else fs_acc <= fs_acc || !dut.h_f_sound_n;
    end
    always @(posedge clk) if (!rst) begin
        clocks <= clocks + 1;
        if (sample) begin
            if (^snd === 1'bx || ^snd_r === 1'bx) $fatal(1,"unknown sample");
            if (snd_r != (status[18] ? snd_b : snd))
                $fatal(1,"right channel %0d, expected %0d", snd_r, status[18] ? snd_b : snd);
            if (last_sample >= 0 && clocks - last_sample != 1000)
                $fatal(1,"sample %0d clocks after the previous one", clocks - last_sample);
            last_sample <= clocks;
            samples = samples + 1;
            got <= 1; got_snd <= snd; got_b <= snd_b;
        end
        if (scnt == 7'd99) begin
            if (have) begin
                $fwrite(fd, "%0d %0d %0d %0d %0d %0d %0d  %0d %0d %0d %0d %0d  %0d %0d %0d  %0d %0d  %0d %0d  %0d %0d %0d %0d %0d  %0d %0d  %0d %0d %0d %0d\n",
                    r_acce, r_s_acc1_n, r_coin_in_n, r_game_n, r_shift, r_nonroad, r_excp,
                    dut.g_sound.u_sound.my_car_on, dut.g_sound.u_sound.shift_a,
                    dut.g_sound.u_sound.mute, dut.g_sound.u_sound.explo_t,
                    dut.g_sound.u_sound.skid_on, dut.g_sound.u_sound.i_my,
                    dut.g_sound.u_sound.u_mix.v_pad, dut.g_sound.u_sound.u_mix.i_d4_l,
                    got || sample, sample ? snd : got_snd,
                    fs_step, dut.g_sound.u_sound.i_mf, r_resc, r_back, dut.g_sound.u_sound.i_d2,
                    dut.g_sound.u_sound.padr, sample ? snd_b : got_b, r_slip, dut.g_sound.u_sound.i_d1,
                    r_hs, r_mpad, dut.g_sound.u_sound.i_d5, dut.g_sound.u_sound.alarm);
                rows = rows + 1;
                got <= 0;
            end
            have <= 1;
            {r_acce, r_s_acc1_n, r_coin_in_n, r_game_n, r_shift, r_nonroad, r_excp, r_resc, r_back, r_slip,
             r_hs, r_mpad} <=
                {dut.f_acce, dut.f_s_acc1_n, dut.a_coin_in_n, dut.a_game_n, dut.f_shift,
                 dut.f_nonroad_slip_n, dut.a_ex_cp, !dut.rescue_cp_n, !dut.dipsw[8], dut.f_slipzone_n,
                 dut.a_hiscore_n, dut.a_mute};
        end
    end

    // ---------------------------------------------------------------- phases
    // 0 power-up, 1 attract (checked), 2 coin to game, 3 game in low gear,
    // 4 game in high gear, 5 pedal released
    integer phase=0, n[0:5], peak[0:5], crash_steps=0;
    real sq[0:5];
    integer i;
    initial for (i=0;i<6;i=i+1) begin n[i]=0; peak[i]=0; sq[i]=0.0; end
    always @(posedge clk) if (sample) begin
        n[phase] = n[phase] + 1;
        sq[phase] = sq[phase] + $itor(snd)*$itor(snd);
        if ((snd < 0 ? -snd : snd) > peak[phase]) peak[phase] = snd < 0 ? -snd : snd;
    end
    // the gates, once per step, against the game state. The lever reaches
    // SHIFT A through sheet F's latch and the step's input register, so a
    // change shows one or two steps later: SHIFT A is checked from the
    // fourth step after the lever moved.
    integer since_gear=0, shifted_steps=0;
    reg gear_l=0;
    always @(posedge clk) if (!rst && scnt == 7'd2) begin
        since_gear = dut.high_gear != gear_l ? 0 : since_gear + 1;
        gear_l = dut.high_gear;
        if (phase == 4 && dut.g_sound.u_sound.shift_a) shifted_steps = shifted_steps + 1;
        if (phase == 1 && (dut.g_sound.u_sound.my_car_on || !dut.g_sound.u_sound.mute))
            $fatal(1,"before the coin: MY CAR SOUND ON %b, mute %b",
                   dut.g_sound.u_sound.my_car_on, dut.g_sound.u_sound.mute);
        if (phase >= 3 && dut.a_game) begin
            if (!dut.f_s_acc1_n) crash_steps = crash_steps + 1;
            else if (!dut.g_sound.u_sound.my_car_on || dut.g_sound.u_sound.mute ||
                     (since_gear > 3 && dut.g_sound.u_sound.shift_a != dut.high_gear))
                $fatal(1,"in the game: MY CAR SOUND ON %b, mute %b, SHIFT A %b, high gear %b",
                       dut.g_sound.u_sound.my_car_on, dut.g_sound.u_sound.mute,
                       dut.g_sound.u_sound.shift_a, dut.high_gear);
        end
    end

    task wait_frames(input integer k);
        repeat (k) @(negedge vs);
    endtask
    function integer rms(input integer p);
        rms = n[p] ? $rtoi($sqrt(sq[p] / n[p])) : 0;
    endfunction

    integer k;
    initial begin
        if (!$value$plusargs("ROM=%s",path) || !$value$plusargs("OUT=%s",outdir)) $fatal(1,"missing ROM/OUT");
        $readmemh(path,expected);
        fd = $fopen({outdir, "/play_sound_steps.txt"}, "w");
        if (fd == 0) $fatal(1,"cannot open the output file");
        status[15:13] = 5;
        repeat(4) @(negedge clk);
        rom=1;
        for (k=0;k<8800;k=k+1) begin
            @(negedge clk); wa=k; wd=expected[k]; wr=1;
        end
        @(negedge clk); wr=0; rom=0; rst=0;
        // power-up: C103 charges (the power-on thump, muted), then attract
        // (nine frames at six clocks a pixel: the same time as eight at 48 MHz)
        wait_frames(9);
        phase = 1;
        wait_frames(4);
        if (dut.a_game || dut.a_coin_in) $fatal(1,"a game before any coin");
        phase = 2;
        coin[0] = 0; wait_frames(2); coin[0] = 1; wait_frames(1);
        joy[4] = 0;
        k = 0;
        while (!dut.a_game && k < 20) begin wait_frames(1); k = k + 1; end
        if (!dut.a_game) $fatal(1,"the pedal did not start the game");
        wait_frames(1);
        phase = 3;
        status[18] = 1;
        wait_frames(5);
        joy[5] = 0; wait_frames(1); joy[5] = 1;
        if (!dut.high_gear) $fatal(1,"no high gear");
        phase = 4;
        wait_frames(5);
        joy[4] = 1;
        phase = 5;
        wait_frames(2);
        if (!dut.a_game) $fatal(1,"the game ended early");
        $fclose(fd);
        $display("PASS play with sound: %0d model steps, %0d samples at 48 kHz", rows, samples);
        $display("  SOUND OUT, peak / RMS (16384 per volt): attract %0d / %0d; coin to game %0d / %0d",
                 peak[1], rms(1), peak[2], rms(2));
        $display("  game: low gear %0d / %0d, high gear %0d / %0d, pedal released %0d / %0d; %0d steps in a crash",
                 peak[3], rms(3), peak[4], rms(4), peak[5], rms(5), crash_steps);
        // Muted is -20.8 dB, not silence: 328 on the 48 MHz code of 6e011d0 and here
        if (peak[1] > 350) $fatal(1,"attract mode not silent (peak %0d)", peak[1]);
        // MY CAR SOUND at the lowest ACCE. codes peaks at a few tenths of a
        // volt on pad 13 (thousands at 16384 per volt)
        if (peak[3] < 1000 || peak[4] < 1000) $fatal(1,"no engine in the game");
        if (shifted_steps == 0) $fatal(1,"SHIFT A never high in high gear");
        $finish;
    end
endmodule
