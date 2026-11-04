// SPDX-License-Identifier: GPL-3.0-or-later
// The D-1 slip-zone sound (jtmonacogp_snd_d1.v) at 48 MHz, one model step
// every 100 clocks, through the 3 s scenario of the SPICE reference
// (tests/sound/d1_reference.py). The inputs come from OUT/d1_stim.txt,
// written by tests/sound/d1_verilog_check.py: the number of steps, then one
// 'noise slip_n' line a step (the S2688's bit, pad J). The noise bit is
// set on the step's first clock, as jtmonacogp_snd_noise sets `nbit`.
// The module must finish within 90 clocks of the step's start, leaving the
// mixer its 10. One line per step to OUT/snd_d1_steps.txt;
// tests/sound/d1_verilog_check.py compares every line with the fixed-point
// twin (tests/sound/d1_fixed.py) and the window features with SPICE.
`timescale 1ns/1ps
module tb_snd_d1;
    reg clk = 0, rst = 1;
    always #10.416666667 clk = ~clk;

    reg  [6:0] cnt = 0;
    reg        tick = 0;
    reg        noise = 0, slip_n = 1, noise_nx = 0;
    wire signed [35:0] i_mix, v_c63, v_o8, v_na, v_o1, v_o7, v_sw;
    wire        done;
    jtmonacogp_snd_d1 uut(
        .clk(clk),.rst(rst),.start(tick),.noise(noise),.slip_n(slip_n),
        .i_mix(i_mix),.done(done),
        .v_c63(v_c63),.v_o8(v_o8),.v_na(v_na),.v_o1(v_o1),.v_o7(v_o7),.v_sw(v_sw));

    integer fd, fs, r, k = 0, steps = 0, latest = 0, d_at = -1, total;
    integer nn, ns;
    reg [1023:0] outdir;
    initial begin
        if (!$value$plusargs("OUT=%s", outdir)) outdir = "build/tests";
        fs = $fopen({outdir, "/d1_stim.txt"}, "r");
        if (fs == 0) $fatal(1, "cannot open d1_stim.txt");
        r = $fscanf(fs, "%d\n", total);
        fd = $fopen({outdir, "/snd_d1_steps.txt"}, "w");
        if (fd == 0) $fatal(1, "cannot open the output file");
        repeat (4) @(posedge clk);
        rst <= 0;
    end

    always @(posedge clk) if (!rst) begin
        tick <= 0;
        if (tick) noise <= noise_nx;     // the step's bit from its second clock on
        cnt <= cnt == 7'd99 ? 7'd0 : cnt + 7'd1;
        if (done) d_at = cnt;
        if (cnt == 7'd99) begin
            if (k > 0) begin
                if (d_at < 0 || d_at > 90)
                    $fatal(1, "step %0d: done at clock %0d", k-1, d_at);
                if (d_at > latest) latest = d_at;
                $fwrite(fd, "%0d %0d %0d %0d %0d %0d %0d %0d\n",
                    i_mix, v_c63, v_o8, v_na, v_o1, v_o7, v_sw, d_at);
                steps = steps + 1;
            end
            d_at = -1;
            if (k == total) begin
                $fclose(fd);
                $display("tb_snd_d1: %0d steps; the step finishes by clock %0d of 100", steps, latest);
                $finish;
            end else begin
                r = $fscanf(fs, "%d %d\n", nn, ns);
                if (r != 2) $fatal(1, "d1_stim.txt: no line for step %0d", k);
                noise    <= 1'bx;            // not this step's until the next clock
                noise_nx <= nn != 0;
                slip_n   <= ns != 0;
                tick <= 1;
                k = k + 1;
            end
        end
    end
endmodule
