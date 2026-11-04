// SPDX-License-Identifier: GPL-3.0-or-later
// Sound board top (jtmonacogp_sound.v) at 48 MHz: 0.3 s of play-like inputs
// (accelerate, shift, coin-in released, crash, off the road, the EXTEND
// beep, other cars: /F-SOUND pulses of one microsecond once a frame, a
// /RESCUE CP pulse of 20 ms, the slip zone from 0.15 to 0.27 s, a HI SCORE
// pulse of 1.3 ms (sheet A's length) at 10 ms that starts the hi-score
// tune, MUTE high from 0.2 to 0.215 s, while COIN IN is released), then every combination of the five
// gate inputs for 200 steps each, with EX.CP toggling, /F-SOUND pulsing,
// /RESCUE CP low for 30 steps in every fourth combination, /SLIPZONE low in
// every third, MUTE high in every other one and DIP SW. 2's back-sound
// contact open in the second half. D-5's PROM comes from the PROM image
// (+ROM=proms.hex, bytes 8768..8799) before reset ends. The tune (about
// 3 s) plays on through the run, its alarm line low while MUTE is high.
// Inputs change 37 clocks into a step, so
// the module must hold what it took at the step's start; every state machine must be
// idle again before the step ends.
// One line per model step to OUT/sound_steps.txt: the inputs taken for the
// step, the gates held, D-3's mixer current, pad 13, the D-4 sources' and
// the other cars' current, the sample, if one was produced, pad C as the
// other cars' block takes it (low at a clock since the previous step's start)
// and their R409 current, pad P and the back-sound contact as taken for the
// step, D-2's mixer current and pad R, the back sample, pad J as taken
// for the step with D-1's mixer current, and HI SCORE and MUTE as taken for
// the step with D-5's mixer current and its alarm line.
// tests/sound/sound_check.py compares every line with the fixed-point twin
// (tests/sound/d4_fixed.py SoundFixed) and writes the samples to
// OUT/sound.wav (SOUND OUT) and OUT/sound_back.wav (BACK SOUND OUT).
`timescale 1ns/1ps
module tb_sound;
    localparam integer PLAY = 144000;      // 0.3 s of model steps
    localparam integer COMB = 200;         // steps per gate combination
    localparam integer STEPS = PLAY + 32*COMB;

    reg clk = 0, rst = 1;
    always #10.416666667 clk = ~clk;
    reg [3:0] acce = 0;
    reg       s_acc1_n = 1, coin_in_n = 0, game_n = 0, shift = 0, nonroad_slip_n = 1, excp = 0;
    reg       f_sound_n = 1, rescue_cp_n = 1, back_mix = 1, slip_n = 1, hiscore_n = 1, mute_in = 0;
    wire [4:0] prom_a;
    reg  [7:0] prom_q = 0;
    wire signed [15:0] snd, snd_b;
    wire sample, my_car_on, shift_a, mute, explo_t, skid_on, alarm;
    jtmonacogp_sound dut(
        .clk(clk),.rst(rst),.acce(acce),.s_acc1_n(s_acc1_n),.coin_in_n(coin_in_n),
        .game_n(game_n),.shift(shift),.nonroad_slip_n(nonroad_slip_n),.excp(excp),.explo_loud(1'b0),
        .f_sound_n(f_sound_n),.rescue_cp_n(rescue_cp_n),.back_mix(back_mix),.slip_n(slip_n),
        .hiscore_n(hiscore_n),.mute_in(mute_in),.prom_addr_d5(prom_a),.prom_data_d5(prom_q),
        .alarm(alarm),.snd(snd),.snd_b(snd_b),.sample(sample),.my_car_on(my_car_on),.shift_a(shift_a),.mute(mute),
        .explo_t(explo_t),.skid_on(skid_on));

    // inputs for step k
    task automatic inputs(input integer k);
        integer c;
        if (k < PLAY) begin
            {s_acc1_n, coin_in_n, game_n, nonroad_slip_n} <= 4'b1001;
            shift <= 0; acce <= 4'b0011;
            if (k >= 24000)  acce <= 4'b1111;
            if (k >= 57600)  shift <= 1;
            if (k >= 81600)  acce <= 4'b0000;
            if (k >= 96000 && k < 110400) coin_in_n <= 1;     // released: mute
            if (k >= 110400 && k < 124800) s_acc1_n <= 0;     // crash
            if (k >= 124800) begin acce <= 4'b1010; shift <= 0; end
            if (k >= 129600 && k < 139200) nonroad_slip_n <= 0;  // off the road
            // EX.CP: V2 (about 3.9 kHz) in two bursts
            excp <= ((k >= 31200 && k < 50400) || k >= 136800) && (k / 61) % 2 == 1;
            // /RESCUE CP: sheet M's 20 ms pulse
            rescue_cp_n <= !(k >= 14400 && k < 24000);
            slip_n <= !(k >= 72000 && k < 129600);
            // HI SCORE: sheet A's pulse, 1.3 ms
            hiscore_n <= !(k >= 4800 && k < 5424);
            // MUTE through the first half of COIN IN's release: the alarm
            // line then low, SOUND OUT muted; un-muted by the alarm after
            mute_in <= k >= 96000 && k < 103200;
            back_mix <= 1;
        end else begin
            c = (k - PLAY) / COMB;
            {s_acc1_n, coin_in_n, game_n, shift, nonroad_slip_n} <= c[4:0];
            acce <= c[3:0];
            excp <= (k / 61) % 2 == 1;
            rescue_cp_n <= !(c % 4 == 1 && (k - PLAY) % COMB < 30);
            slip_n <= c % 3 != 2;
            hiscore_n <= 1;
            mute_in <= c % 2 == 1;
            back_mix <= c < 16;
        end
    endtask

    integer fd, clocks = 0, k = 0, rows = 0;
    reg [1023:0] outdir;
    reg [3:0] r_acce;
    reg r_s_acc1_n, r_coin_in_n, r_game_n, r_shift, r_nonroad, r_excp, r_resc, r_back, r_slip;
    reg r_hs, r_mpad;
    reg [7:0] image [0:8799];
    // prm40.ic21 behind the same one-clock read as jtframe_prom
    always @(posedge clk) prom_q <= image[8768+prom_a];
    reg [1023:0] romfile;
    integer i;
    reg have = 0, got = 0;
    reg signed [15:0] got_snd = 0, got_b = 0;
    initial begin
        if (!$value$plusargs("OUT=%s", outdir)) outdir = "build/tests";
        fd = $fopen({outdir, "/sound_steps.txt"}, "w");
        if (fd == 0) $fatal(1, "cannot open the output file");
        if (!$value$plusargs("ROM=%s", romfile)) $fatal(1, "no +ROM=proms.hex");
        $readmemh(romfile, image);
        repeat (4) @(posedge clk);
        rst <= 0;
    end

    // /F-SOUND: low for 48 clocks once a frame (806,724 clocks) from 0.06 s
    // to 0.29 s, and for 30 clocks every 9,973 clocks in the combinations,
    // independent of the steps
    always @(posedge clk)
        f_sound_n <= clocks < 2880000 ? 1'b1 :
                     clocks < 13920000 ? (clocks % 806724) >= 48 :
                     (clocks % 9973) >= 30;
    // pad C as the module takes it: low at any clock from one step's tick
    // to the clock before the next
    reg fs_acc = 0, fs_step = 0;
    always @(posedge clk) if (!rst) begin
        if (dut.tick) begin fs_step <= fs_acc; fs_acc <= !f_sound_n; end
        else fs_acc <= fs_acc || !f_sound_n;
    end

    always @(posedge clk) if (!rst) begin
        clocks <= clocks + 1;
        if (sample) begin
            if (got) $fatal(1, "two samples in one step");
            got <= 1; got_snd <= snd; got_b <= snd_b;
        end
        // the module takes its inputs when its counter is at 99
        if (dut.cnt == 7'd99) begin
            if (dut.u_d3.st != 0 || dut.u_mix.st != 0 || dut.u_noise.st != 0 ||
                dut.u_expl.st != 0 || dut.u_expl.u_bu.st != 0 || dut.u_expl.u_bl.st != 0 ||
                dut.u_d67.st != 0 || dut.u_d2.st != 0 || dut.u_d2.u_vco.st != 0 ||
                dut.u_d2.u_mc.st != 0 || dut.u_d1.st != 0 || dut.u_d5.st != 0 || dut.dn != 0)
                $fatal(1, "step %0d not finished within 100 clocks", rows);
            if (have) begin
                $fwrite(fd, "%0d %0d %0d %0d %0d %0d %0d  %0d %0d %0d %0d %0d  %0d %0d %0d  %0d %0d  %0d %0d  %0d %0d %0d %0d %0d  %0d %0d  %0d %0d %0d %0d\n",
                    r_acce, r_s_acc1_n, r_coin_in_n, r_game_n, r_shift, r_nonroad, r_excp,
                    my_car_on, shift_a, mute, explo_t, skid_on,
                    dut.i_my, dut.u_mix.v_pad, dut.u_mix.i_d4_l, got || sample, sample ? snd : got_snd,
                    fs_step, dut.i_mf, r_resc, r_back, dut.i_d2, dut.padr, sample ? snd_b : got_b,
                    r_slip, dut.i_d1, r_hs, r_mpad, dut.i_d5, alarm);
                rows = rows + 1;
                got <= 0;
                if (rows == STEPS) begin
                    $fclose(fd);
                    $display("tb_sound: %0d steps, %0d clocks", rows, clocks);
                    $finish;
                end
            end
            have <= 1;
            {r_acce, r_s_acc1_n, r_coin_in_n, r_game_n, r_shift, r_nonroad, r_excp, r_resc, r_back, r_slip,
             r_hs, r_mpad} <=
                {acce, s_acc1_n, coin_in_n, game_n, shift, nonroad_slip_n, excp, !rescue_cp_n, back_mix, slip_n,
                 hiscore_n, mute_in};
        end
        if (dut.cnt == 7'd36) begin
            inputs(k);
            k = k + 1;
        end
    end
endmodule
