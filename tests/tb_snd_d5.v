// SPDX-License-Identifier: GPL-3.0-or-later
// The D-5 hi-score tune (jtmonacogp_snd_d5.v) at 48 MHz, one model step
// every 100 clocks, through the scenario of the SPICE reference
// (tests/sound/d5_reference.py). Compiled with D5_REF, so that the module
// reads the reference's settings (jtmonacogp_snd_d5_ref.vh, written by
// tests/sound/d5_fixed.py into the build directory). The PROM's 32 bytes
// come from the PROM image (+ROM=proms.hex, bytes 8768..8799) through the
// module's download port before reset ends. The inputs come from
// OUT/d5_stim.txt, written by tests/sound/d5_verilog_check.py: the number
// of steps, then one 'hiscore_n mute' line a step. The module must finish
// within 90 clocks of the step's start, leaving the mixer its 10. One line
// per step to OUT/snd_d5_steps.txt; tests/sound/d5_verilog_check.py
// compares every line with the fixed-point twin (tests/sound/d5_fixed.py)
// and the window features with SPICE.
`timescale 1ns/1ps
module tb_snd_d5;
    reg clk = 0, rst = 1;
    always #10.416666667 clk = ~clk;

    reg  [6:0] cnt = 0;
    reg        tick = 0;
    reg        hiscore_n = 1, mute = 0;
    wire [4:0] prom_a;
    reg  [7:0] prom_q = 0;
    wire signed [35:0] i_mix, v_lfo, v_cvu, v_cvl, v_sawu, v_sawl, v_mix, v_lp, v_hp,
                       v_env, v_con, v_mco;
    wire [4:0] v_addr;
    wire [3:0] v_cnt;
    wire       v_q123, v_clk, alarm, done;
    jtmonacogp_snd_d5 uut(
        .clk(clk),.rst(rst),.start(tick),.hiscore_n(hiscore_n),.mute(mute),
        .prom_addr_d5(prom_a),.prom_data_d5(prom_q),
        .i_mix(i_mix),.alarm(alarm),.done(done),
        .v_lfo(v_lfo),.v_cvu(v_cvu),.v_cvl(v_cvl),.v_sawu(v_sawu),.v_sawl(v_sawl),
        .v_mix(v_mix),.v_lp(v_lp),.v_hp(v_hp),.v_env(v_env),.v_con(v_con),.v_mco(v_mco),
        .v_addr(v_addr),.v_cnt(v_cnt),.v_q123(v_q123),.v_clk(v_clk));

    reg [7:0] image [0:8799];
    // prm40.ic21 behind the same one-clock read as jtframe_prom
    always @(posedge clk) prom_q <= image[8768+prom_a];
    integer fd, fs, r, i, k = 0, steps = 0, latest = 0, d_at = -1, total;
    integer nh, nm;
    reg [1023:0] outdir, romfile;
    initial begin
        if (!$value$plusargs("OUT=%s", outdir)) outdir = "build/tests";
        if (!$value$plusargs("ROM=%s", romfile)) $fatal(1, "no +ROM=proms.hex");
        $readmemh(romfile, image);
        fs = $fopen({outdir, "/d5_stim.txt"}, "r");
        if (fs == 0) $fatal(1, "cannot open d5_stim.txt");
        r = $fscanf(fs, "%d\n", total);
        fd = $fopen({outdir, "/snd_d5_steps.txt"}, "w");
        if (fd == 0) $fatal(1, "cannot open the output file");
        repeat (4) @(posedge clk);
        rst <= 0;
    end

    always @(posedge clk) if (!rst) begin
        tick <= 0;
        cnt <= cnt == 7'd99 ? 7'd0 : cnt + 7'd1;
        if (done) d_at = cnt;
        if (cnt == 7'd99) begin
            if (k > 0) begin
                if (d_at < 0 || d_at > 90)
                    $fatal(1, "step %0d: done at clock %0d", k-1, d_at);
                if (d_at > latest) latest = d_at;
                $fwrite(fd, "%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n",
                    i_mix, v_lfo, v_cvu, v_cvl, v_sawu, v_sawl, v_mix, v_lp, v_hp, v_env, v_con,
                    v_mco, v_addr, v_cnt, v_q123, alarm, v_clk, d_at);
                steps = steps + 1;
            end
            d_at = -1;
            if (k == total) begin
                $fclose(fd);
                $display("tb_snd_d5: %0d steps; the step finishes by clock %0d of 100", steps, latest);
                $finish;
            end else begin
                r = $fscanf(fs, "%d %d\n", nh, nm);
                if (r != 2) $fatal(1, "d5_stim.txt: no line for step %0d", k);
                hiscore_n <= nh != 0;
                mute      <= nm != 0;
                tick <= 1;
                k = k + 1;
            end
        end
    end
endmodule
