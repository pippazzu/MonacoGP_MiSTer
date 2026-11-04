// SPDX-License-Identifier: GPL-3.0-or-later
// Sheet I score counter. The RTL (jtmonacogp_score.v) and the pin-wired
// reference (tests/sheet_i_score_reference.v) see the same /SCORE CP,
// /COIN & TEST and /INI. RESET; the four digits, the S-100 lines, S-100-D'
// and SP. CONT. are compared one host clock after every pixel enable. The
// inputs change three host clocks after an enable, so the RTL takes them at
// the next enable and the reference has settled long before.
// The score pulses come one to three pixels long with random gaps; a reset
// (COIN & TEST or INI. RESET) comes now and then, and a run is let up to
// 9999. Coverage: every hundreds digit with tens below and above 40 (the
// S-100-D rule), SP. CONT. set at 6000 and cleared by a reset, the score
// held at 9999 while pulses keep coming.
`timescale 1ns/1ps
module tb_score #(parameter integer PIXELS = 3000000, parameter [31:0] SEED = 32'h53434f52);
    reg clk = 0, rst = 1;
    always #10.416666667 clk = ~clk;
    wire pcen, p2cen;
    jtmonacogp_cen u_cen(.clk(clk),.cen14(p2cen),.cen7(pcen));
    reg scp_n = 1, ct_n = 1, ir_n = 1;
    wire [15:0] d, rd;
    wire [3:0] s, rs;
    wire s2, rs2, sp, rsp;
    jtmonacogp_score dut(.clk(clk),.rst(rst),.pxl_cen(pcen),.score_cp_n(scp_n),.coin_test_n(ct_n),
        .ini_reset_n(ir_n),.digits(d),.s100(s),.s100_d2(s2),.sp_cont(sp));
    sheet_i_score_reference reff(.score_cp_n(scp_n),.coin_test_n(ct_n),.ini_reset_n(ir_n),
        .digits(rd),.s100(rs),.s100_d2(rs2),.sp_cont(rsp));
    integer seed = SEED, n = 0, gap = 0, len = 0, held = 0, sp_set = 0, sp_clr = 0;
    reg [19:0] seen = 0;        // {hundreds digit, tens >= 40}
    reg sp_l = 0, cen_d = 0, scp_l = 1;
    function integer rnd(input integer k); rnd = ($random(seed) & 32'h7fffffff) % k; endfunction
    // compare one clock after the enable
    always @(posedge clk) begin
        cen_d <= pcen;
        if (cen_d && !rst && n > 4) begin
            if ({d, s, s2, sp} !== {rd, rs, rs2, rsp})
                $fatal(1, "mismatch at pixel %0d: RTL %h %b %b %b, REF %h %b %b %b", n, d, s, s2, sp, rd, rs, rs2, rsp);
            seen[{d[11:8], 1'b0} + (d[6] ? 1 : 0)] = 1;
            if (d == 16'h9999 && !scp_n) held = held + 1;
            if (sp && !sp_l) sp_set = sp_set + 1;
            if (!sp && sp_l) sp_clr = sp_clr + 1;
            sp_l = sp;
        end
    end
    initial begin
        repeat (4) @(negedge clk);
        rst = 0;
        for (n = 0; n < PIXELS; n = n + 1) begin
            @(posedge clk); while (!pcen) @(posedge clk);
            repeat (3) @(posedge clk);
            // a score pulse of 1..3 pixels after a gap of 0..5 (fast runs)
            scp_l = scp_n;
            if (len > 0) begin len = len - 1; if (len == 0) scp_n = 1; end
            else if (gap > 0) gap = gap - 1;
            else begin scp_n = 0; len = 1 + rnd(3); gap = rnd(6); end
            // A reset now and then, except during one long run to 9999. It
            // never changes in the pixel a score pulse edge does: a clear
            // released at a clock edge is a matter of the 74390's recovery
            // time, which neither model claims.
            if (scp_n == scp_l) begin
                ct_n = !(rnd(400000) == 0 && n < PIXELS * 3 / 4);
                ir_n = !(rnd(900000) == 0 && n < PIXELS * 3 / 4);
            end
        end
        $display("PASS score: %0d pixels match the pin-wired sheet I score reference", PIXELS);
        $display("  SP. CONT. set %0d times, cleared %0d; %0d pixels of score pulses held at 9999",
                 sp_set, sp_clr, held);
        if (seen != 20'hfffff || sp_set == 0 || sp_clr == 0 || held == 0)
            $fatal(1, "coverage: hundreds/tens cases %b", seen);
        $finish;
    end
endmodule
