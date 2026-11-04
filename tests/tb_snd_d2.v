// SPDX-License-Identifier: GPL-3.0-or-later
// The D-2 rescue siren and back sound (jtmonacogp_snd_d2.v) at 48 MHz, one
// model step every 100 clocks, through the 6 s scenario of the SPICE
// reference (tests/sound/d2_reference.py). The inputs come from
// OUT/d2_stim.txt, written by tests/sound/d2_verilog_check.py: the number
// of steps, then one 'resc mute i_bk' line a step. DIP SW. 2's contact is
// closed (back sound into the mix).
// The module must finish within 90 clocks of the step's start, leaving the
// mixer its 10. One line per step to OUT/snd_d2_steps.txt;
// tests/sound/d2_verilog_check.py compares every line with the fixed-point
// twin (tests/sound/d2_fixed.py) and the window features with SPICE.
`timescale 1ns/1ps
module tb_snd_d2;
    reg clk = 0, rst = 1;
    always #10.416666667 clk = ~clk;

    reg  [6:0] cnt = 0;
    reg        tick = 0;
    reg        resc = 0, mute = 0;
    reg signed [35:0] i_bk = 0;
    wire signed [35:0] i_mix, padr;
    wire signed [35:0] v_env_r, v_env_f, v_con41, v_con45, v_mc41o, v_mc45o, v_o40_7, v_z, v_o44_7;
    wire signed [35:0] v_o42_1, v_o43_7, v_i410, v_i424, v_saw, v_o40_1;
    wire        done, v_o42_8, v_o43_14, v_o43_1, v_o44_14, v_o555;
    jtmonacogp_snd_d2 uut(
        .clk(clk),.rst(rst),.start(tick),.resc(resc),.mute(mute),.dip_back(1'b1),.i_bk(i_bk),
        .i_mix(i_mix),.padr(padr),.done(done),
        .v_env_r(v_env_r),.v_env_f(v_env_f),.v_con41(v_con41),.v_con45(v_con45),
        .v_mc41o(v_mc41o),.v_mc45o(v_mc45o),.v_o40_7(v_o40_7),.v_z(v_z),.v_o44_7(v_o44_7),
        .v_o42_1(v_o42_1),.v_o43_7(v_o43_7),.v_i410(v_i410),.v_i424(v_i424),
        .v_o42_8(v_o42_8),.v_o43_14(v_o43_14),.v_o43_1(v_o43_1),.v_o44_14(v_o44_14),
        .v_saw(v_saw),.v_o40_1(v_o40_1),.v_o555(v_o555));

    integer fd, fs, r, k = 0, steps = 0, latest = 0, d_at = -1, total;
    integer nr, nm;
    reg signed [63:0] nb;
    reg [1023:0] outdir;
    initial begin
        if (!$value$plusargs("OUT=%s", outdir)) outdir = "build/tests";
        fs = $fopen({outdir, "/d2_stim.txt"}, "r");
        if (fs == 0) $fatal(1, "cannot open d2_stim.txt");
        r = $fscanf(fs, "%d\n", total);
        fd = $fopen({outdir, "/snd_d2_steps.txt"}, "w");
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
                // the saw tooth and IC40 pin 1 are the VCO's (it finishes
                // before the module's done)
                $fwrite(fd, "%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n",
                    i_mix, padr, v_env_r, v_env_f, v_con41, v_con45, v_mc41o, v_mc45o,
                    v_o40_7, v_z, v_o44_7, v_o42_1, v_o43_7, v_i410, v_i424,
                    v_saw, v_o40_1, v_o555, v_o42_8, v_o43_14, v_o43_1, v_o44_14, d_at);
                steps = steps + 1;
            end
            d_at = -1;
            if (k == total) begin
                $fclose(fd);
                $display("tb_snd_d2: %0d steps; the step finishes by clock %0d of 100", steps, latest);
                $finish;
            end else begin
                r = $fscanf(fs, "%d %d %d\n", nr, nm, nb);
                if (r != 3) $fatal(1, "d2_stim.txt: no line for step %0d", k);
                resc <= nr != 0;
                mute <= nm != 0;
                i_bk <= nb[35:0];
                tick <= 1;
                k = k + 1;
            end
        end
    end
endmodule
