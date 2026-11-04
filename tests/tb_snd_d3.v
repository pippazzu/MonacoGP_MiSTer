// SPDX-License-Identifier: GPL-3.0-or-later
// Sound sheet D-3 (jtmonacogp_snd_d3.v) through the scenario of the SPICE
// reference (tests/sound/d3_reference.py, "full"): power-on with every
// capacitor at 0 V, then the S-ACCE code, SHIFT A and MY CAR SOUND ON
// switched at the times below, 3 s in all. The model step is issued as soon
// as the previous one has finished (the core issues one per 100 clocks);
// the arithmetic does not depend on that spacing.
// Every step's inputs and outputs go to OUT/snd_d3_full.txt, which
// tests/sound/d3_verilog_check.py compares with the fixed-point twin
// (exactly) and with the SPICE reference (features).
`timescale 1ns/1ps
module tb_snd_d3 #(parameter integer STEPS = 1440000);
    reg clk = 0, rst = 1;
    always #10.416666667 clk = ~clk;
    reg        tick = 0;
    reg  [3:0] acc = 4'b0111;
    reg        shift_a = 0, sound_on = 1;
    wire signed [35:0] i_mix, lag, cv, o1, o2, o3, c1, c2, c3, con, mcin, mco;
    jtmonacogp_snd_d3 dut(.clk(clk),.rst(rst),.tick(tick),.acc(acc),.shift_a(shift_a),
        .sound_on(sound_on),.i_mix(i_mix),.v_lag(lag),.v_cv(cv),.v_o1(o1),.v_o2(o2),
        .v_o3(o3),.v_c1(c1),.v_c2(c2),.v_c3(c3),.v_con(con),.v_mcin(mcin),.v_mco(mco));

    // events in model steps (480,000 per second), as d3_reference.FULL
    task automatic inputs(input integer k);
        case (k)
                  0: begin acc = 4'b0111; shift_a = 0; sound_on = 1; end
             288000: begin acc = 4'b1111; shift_a = 0; sound_on = 1; end
             576000: begin acc = 4'b1111; shift_a = 1; sound_on = 1; end
             720000: begin acc = 4'b0000; shift_a = 1; sound_on = 1; end
             864000: begin acc = 4'b0000; shift_a = 1; sound_on = 0; end
             960000: begin acc = 4'b0000; shift_a = 0; sound_on = 1; end
            1152000: begin acc = 4'b1010; shift_a = 0; sound_on = 1; end
            default:;
        endcase
    endtask

    integer fd, k, w;
    reg [1023:0] outdir;
    initial begin
        if (!$value$plusargs("OUT=%s", outdir)) outdir = "build/tests";
        fd = $fopen({outdir, "/snd_d3_full.txt"}, "w");
        if (fd == 0) $fatal(1, "cannot open the output file");
        repeat (4) @(posedge clk);
        rst <= 0;
        @(posedge clk);
        for (k = 0; k < STEPS; k = k + 1) begin
            inputs(k);
            @(posedge clk) tick <= 1;
            @(posedge clk) tick <= 0;
            @(posedge clk);
            // the step ends in S_O3; S_IDLE follows
            w = 2;
            while (dut.st != 0) begin
                @(posedge clk);
                w = w + 1;
                if (w > 98) $fatal(1, "step %0d takes more than 100 clocks", k);
            end
            $fwrite(fd, "%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n",
                acc, shift_a, sound_on, lag, cv, o1, o2, o3, c1, c2, c3, con, mcin, mco, i_mix);
        end
        $fclose(fd);
        $display("tb_snd_d3: %0d steps written", STEPS);
        $finish;
    end
endmodule
