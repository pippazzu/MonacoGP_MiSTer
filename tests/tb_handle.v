// SPDX-License-Identifier: GPL-3.0-or-later
// Handle board 96599-P. The RTL (jtmonacogp_handle.v) and the pin-wired
// reference (tests/handle_reference.v) see the same two sensor lines from a
// virtual slotted disc that turns left and right at random speeds, stops
// and reverses; HAN-L-CP, HAN-R-CP and the clear are compared one host
// clock after every pixel enable. The sensor lines change three host clocks
// after an enable. The RTL steps C4 once per pixel and the reference every
// 10 ns, so where either clear changes the outputs may differ for up to three
// pixels; those pixels are counted and capped.
// Coverage: pulses on both outputs, pulses cut short by the clear, pulses
// ended early by their own sensor line, and fast turning where the clear
// swallows slots.
`timescale 1ns/1ps
module tb_handle #(parameter integer PIXELS = 2000000, parameter [31:0] SEED = 32'h48414e44);
    reg clk = 0, rst = 1;
    always #10.416666667 clk = ~clk;
    wire pcen, p2cen;
    jtmonacogp_cen u_cen(.clk(clk),.cen14(p2cen),.cen7(pcen));
    reg a = 0, b = 0;
    wire l, r, c, rl, rr, rc;
    jtmonacogp_handle dut(.clk(clk),.rst(rst),.pxl_cen(pcen),.a(a),.b(b),.han_l_cp(l),.han_r_cp(r),.clr_n(c));
    handle_reference reff(.a(a),.b(b),.han_l_cp(rl),.han_r_cp(rr),.clr_n(rc));

    integer seed = SEED, n = 0, phase = 0, acc = 0, period = 1000, dir = 1, left = 0;
    integer masked = 0, lp = 0, rp = 0, cut = 0, early = 0, swallowed = 0, since_clr = 99;
    reg cen_d = 0, l_l = 0, r_l = 0, c_l = 1, rc_l = 1;
    function integer rnd(input integer k); rnd = ($random(seed) & 32'h7fffffff) % k; endfunction
    always @(posedge clk) begin
        cen_d <= pcen;
        if (cen_d && !rst && n > 10) begin
            if (c != c_l || rc != rc_l) since_clr = 0; else since_clr = since_clr + 1;
            if ({l, r, c} !== {rl, rr, rc}) begin
                if (since_clr <= 3) masked = masked + 1;
                else $fatal(1, "mismatch at pixel %0d: RTL L R CLR %b%b%b, REF %b%b%b", n, l, r, c, rl, rr, rc);
            end
            if (l && !l_l) lp = lp + 1;
            if (r && !r_l) rp = rp + 1;
            if ((l_l && !l || r_l && !r) && !c) cut = cut + 1;
            if ((l_l && !l || r_l && !r) && c) early = early + 1;
            l_l = l; r_l = r; c_l = c; rc_l = rc;
        end
    end
    initial begin
        repeat (4) @(negedge clk);
        rst = 0;
        for (n = 0; n < PIXELS; n = n + 1) begin
            @(posedge clk); while (!pcen) @(posedge clk);
            repeat (3) @(posedge clk);
            // a new turn now and then: speed (pixels per quarter slot),
            // direction, or a stop
            if (left == 0) begin
                left = 2000 + rnd(60000);
                case (rnd(4))
                    0: period = 0;                       // stopped
                    1: period = 40 + rnd(300);           // faster than the clear allows
                    default: period = 400 + rnd(8000);
                endcase
                dir = rnd(2) ? 1 : -1;
            end
            left = left - 1;
            if (period != 0) begin
                acc = acc + 1;
                if (acc >= period) begin
                    acc = 0;
                    phase = (phase + dir) & 3;
                    if (period < 400 && c == 0) swallowed = swallowed + 1;
                end
            end
            // quadrature: lit, both, other, none
            {a, b} = phase == 0 ? 2'b10 : phase == 1 ? 2'b11 : phase == 2 ? 2'b01 : 2'b00;
        end
        $display("PASS handle: %0d pixels match the pin-wired handle board reference (%0d pixels at clear edges masked)",
                 PIXELS, masked);
        $display("  pulses: %0d left, %0d right; %0d ended by the clear, %0d by their sensor line; %0d quarter steps during a clear",
                 lp, rp, cut, early, swallowed);
        if (lp == 0 || rp == 0 || cut == 0 || early == 0 || swallowed == 0)
            $fatal(1, "coverage: a part of the board was not reached");
        if (masked > (lp + rp) * 4) $fatal(1, "too many masked pixels: %0d", masked);
        $finish;
    end
endmodule
