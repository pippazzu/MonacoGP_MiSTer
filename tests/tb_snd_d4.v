// SPDX-License-Identifier: GPL-3.0-or-later
// The D-4 sound sources (jtmonacogp_snd_noise.v and jtmonacogp_snd_expl.v)
// at 48 MHz, one model step every 100 clocks, through the 2 s scenario of
// the SPICE reference (tests/sound/d4_reference.py: two crashes, off the
// road, the EXTEND beep). The inputs come from OUT/d4_stim.txt, written by
// tests/sound/d4_verilog_check.py: the number of steps, then 'k T skid
// EX.CP' lines, each from step k.
// Both modules must finish within 90 clocks of the step's start, leaving
// the mixer its 10. One line per step to OUT/snd_d4_steps.txt;
// tests/sound/d4_verilog_check.py compares every line with the fixed-point
// twin (tests/sound/d4s_fixed.py) and the window features with SPICE.
`timescale 1ns/1ps
module tb_snd_d4;
    reg clk = 0, rst = 1;
    always #10.416666667 clk = ~clk;

    reg  [6:0] cnt = 0;
    reg        tick = 0;
    reg        t = 0, skid = 0, excp = 0;
    wire signed [35:0] namp, i_sk, i401;
    wire        namp_rdy, n_done, e_done;
    wire        v_noise, v_q555, v_q61a, v_q61b;
    wire signed [35:0] v_tri, v_o63d, v_ctl, v_c89, v_expo, v_bpu, v_bpl, v_envu, v_envl;
    wire signed [35:0] v_conu, v_conl, v_mciu, v_mcil, v_mcou, v_mcol;
    jtmonacogp_snd_noise u_noise(
        .clk(clk),.rst(rst),.tick(tick),.skid_on(skid),.excp(excp),
        .namp(namp),.namp_rdy(namp_rdy),.i_sk(i_sk),.done(n_done),.nbit(),
        .v_noise(v_noise),.v_tri(v_tri),.v_o63d(v_o63d),.v_ctl(v_ctl),.v_c89(v_c89),
        .v_q555(v_q555));
    jtmonacogp_snd_expl u_expl(
        .clk(clk),.rst(rst),.go(namp_rdy),.t(t),.loud(1'b0),.namp(namp),
        .i401(i401),.done(e_done),
        .v_q61a(v_q61a),.v_q61b(v_q61b),.v_expo(v_expo),.v_bpu(v_bpu),.v_bpl(v_bpl),
        .v_envu(v_envu),.v_envl(v_envl),.v_conu(v_conu),.v_conl(v_conl),
        .v_mciu(v_mciu),.v_mcil(v_mcil),.v_mcou(v_mcou),.v_mcol(v_mcol));

    integer fd, fs, r, k = 0, nk = 0, steps = 0, latest = 0, nlatest = 0, nd_at = -1, ed_at = -1;
    integer nt, ns, nx, total;
    reg [1023:0] outdir;
    initial begin
        if (!$value$plusargs("OUT=%s", outdir)) outdir = "build/tests";
        fs = $fopen({outdir, "/d4_stim.txt"}, "r");
        if (fs == 0) $fatal(1, "cannot open d4_stim.txt");
        r = $fscanf(fs, "%d\n", total);
        r = $fscanf(fs, "%d %d %d %d\n", nk, nt, ns, nx);
        fd = $fopen({outdir, "/snd_d4_steps.txt"}, "w");
        if (fd == 0) $fatal(1, "cannot open the output file");
        repeat (4) @(posedge clk);
        rst <= 0;
    end

    always @(posedge clk) if (!rst) begin
        tick <= 0;
        cnt <= cnt == 7'd99 ? 7'd0 : cnt + 7'd1;
        if (n_done) nd_at = cnt;
        if (e_done) ed_at = cnt;
        if (cnt == 7'd99) begin
            if (k > 0) begin
                if (nd_at < 0 || ed_at < 0 || nd_at > 90 || ed_at > 90)
                    $fatal(1, "step %0d: noise done at %0d, explosion done at %0d", k-1, nd_at, ed_at);
                if (ed_at > latest) latest = ed_at;
                if (nd_at > nlatest) nlatest = nd_at;
                $fwrite(fd, "%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n",
                    namp, v_tri, v_o63d, v_ctl, v_c89, v_q555, v_bpu, v_bpl, v_envu, v_envl,
                    v_conu, v_conl, v_mciu, v_mcil, v_mcou, v_mcol, v_expo, i401, i_sk,
                    v_q61a, v_q61b);
                steps = steps + 1;
            end
            nd_at = -1; ed_at = -1;
            if (k == total) begin
                $fclose(fd);
                $display("tb_snd_d4: %0d steps; the noise and skid block finishes by clock %0d, the explosion by clock %0d of 100",
                         steps, nlatest, latest);
                $finish;
            end
            if (k == nk) begin
                t <= nt; skid <= ns; excp <= nx;
                r = $fscanf(fs, "%d %d %d %d\n", nk, nt, ns, nx);
                if (r != 4) nk = -1;
            end
            tick <= 1;
            k = k + 1;
        end
    end
endmodule
