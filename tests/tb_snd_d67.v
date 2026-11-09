// SPDX-License-Identifier: GPL-3.0-or-later
// The D-6/D-7 other-car sounds (jtmonacogp_snd_d67.v) at 48 MHz, one model
// step every 100 clocks, through the 3 s scenario of the SPICE reference
// (tests/sound/d67_reference.py). The inputs come from OUT/d67_stim.txt,
// written by tests/sound/d67_verilog_check.py: the number of steps, then
// 'k code low' lines, each from step k (code: S-ACCE with bit 0 = A; low:
// pad C low during the step). Pad C is driven over the 100 clocks before
// its step's tick, as the module samples it.
// The module must finish within 90 clocks of the step's start, leaving the
// mixer its 10. One line per step to OUT/snd_d67_steps.txt;
// tests/sound/d67_verilog_check.py compares every line with the fixed-point
// twin (tests/sound/d67_fixed.py) and the window features with SPICE.
// With D67_R109 defined, the module's r109 input is held at that R109 option
// (bank 1's CONTROL bias, docs/sound/OTHER_CAR_COMPARE.md) and it is compared
// with the twin built the same way only.
`timescale 1ns/1ps
module tb_snd_d67;
`ifdef D67_R109
    localparam [1:0] R109 = `D67_R109;
`else
    localparam [1:0] R109 = 0;
`endif
    reg clk = 0, rst = 1;
    always #10.416666667 clk = ~clk;

    reg  [6:0] cnt = 0;
    reg        tick = 0;
    reg  [3:0] acc = 0;
    reg        fs_n = 1;
    wire signed [35:0] i_mf, i_mb, v_front, v_r6, v_feed, v_r14, v_r28, v_u1, v_u2;
    wire signed [35:0] v_con20, v_con19, v_con34, v_con33, v_cv1, v_cv2;
    wire signed [35:0] v_o1, v_o2, v_o3, v_con1, v_con2, v_o1b, v_snd1, v_snd2;
    wire        done, v_q59a, v_q59b, v_q58, v_c292, v_c2913;
    jtmonacogp_snd_d67 uut(
        .clk(clk),.rst(rst),.r109(R109),.tick(tick),.acc(acc),.fs_n(fs_n),
        .i_mf(i_mf),.i_mb(i_mb),.done(done),.v_front(v_front),.v_r6(v_r6),
        .v_feed(v_feed),.v_r14(v_r14),.v_r28(v_r28),.v_u1(v_u1),.v_u2(v_u2),
        .v_con20(v_con20),.v_con19(v_con19),.v_con34(v_con34),.v_con33(v_con33),
        .v_cv1(v_cv1),.v_cv2(v_cv2),.v_q59a(v_q59a),.v_q59b(v_q59b),.v_q58(v_q58),
        .v_c292(v_c292),.v_c2913(v_c2913),.v_o1(v_o1),.v_o2(v_o2),.v_o3(v_o3),
        .v_con1(v_con1),.v_con2(v_con2),.v_o1b(v_o1b),.v_snd1(v_snd1),.v_snd2(v_snd2));

    integer fd, fs, r, k = 0, nk = 0, steps = 0, latest = 0, d_at = -1;
    integer ncode, nlow, total;
    // the stimulus is read one step ahead: pad C for step k + 1 goes out
    // with step k's tick
    reg [1023:0] outdir;
    task next_line;
        begin
            r = $fscanf(fs, "%d %d %d\n", nk, ncode, nlow);
            if (r != 3) nk = -1;
        end
    endtask
    reg [3:0] cur_code;
    reg       cur_low;
    // the inputs of a step (lines apply from their step on)
    task inputs_at(input integer step);
        begin
            while (nk >= 0 && nk <= step) begin
                cur_code = ncode; cur_low = nlow;
                next_line;
            end
        end
    endtask
    initial begin
        if (!$value$plusargs("OUT=%s", outdir)) outdir = "build/tests";
        fs = $fopen({outdir, "/d67_stim.txt"}, "r");
        if (fs == 0) $fatal(1, "cannot open d67_stim.txt");
        r = $fscanf(fs, "%d\n", total);
        next_line;
        cur_code = 0; cur_low = 0;
        inputs_at(0);
        fs_n = !cur_low;               // pad C for step 0, before the first tick
        fd = $fopen({outdir, "/snd_d67_steps.txt"}, "w");
        if (fd == 0) $fatal(1, "cannot open the output file");
        repeat (4) @(posedge clk);
        rst <= 0;
    end

    reg [3:0] code_now;
    reg       low_next;
    always @(posedge clk) if (!rst) begin
        tick <= 0;
        cnt <= cnt == 7'd99 ? 7'd0 : cnt + 7'd1;
        if (done) d_at = cnt;
        if (cnt == 7'd99) begin
            if (k > 0) begin
                if (d_at < 0 || d_at > 90)
                    $fatal(1, "step %0d: done at clock %0d", k-1, d_at);
                if (d_at > latest) latest = d_at;
                $fwrite(fd, "%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n",
                    i_mf, i_mb, v_front, v_r6, v_feed, v_r14, v_r28, v_u1, v_u2,
                    v_con20, v_con19, v_con34, v_con33, v_cv1, v_cv2,
                    v_q59a, v_q59b, v_q58, v_c292, v_c2913,
                    v_o1, v_o2, v_o3, v_con1, v_con2, v_o1b, v_snd1, v_snd2);
                steps = steps + 1;
            end
            d_at = -1;
            if (k == total) begin
                $fclose(fd);
                $display("tb_snd_d67: %0d steps; the step finishes by clock %0d of 100", steps, latest);
                $finish;
            end
            // step k's code with its tick; pad C for step k + 1
            inputs_at(k);
            code_now = cur_code;
            inputs_at(k + 1);
            low_next = cur_low;
            acc  <= code_now;
            fs_n <= !low_next;
            tick <= 1;
            k = k + 1;
        end
    end
endmodule
