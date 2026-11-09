// SPDX-License-Identifier: GPL-3.0-or-later
// The score panel overlay (jtmonacogp_panel.v, not original circuitry) with
// pro = 0 and pro = 1 side by side, on the same LED lines. After each of a
// set of random LED states (and 10,000-point lamp values), the whole
// 360 x 240 raster is swept:
// - the two agree on every pixel outside what Pro adds: the bonus lamp box
//   below the box (tb_panel_lamps and tb_panel_colour check its contents)
//   and the lamp place (the caption's sixth place of SCORE);
// - with pro = 1, the YOUR SCORE 10000POINT lamp is lit (12'hf00) or black
//   as its input;
// - with pro = 1, the box keeps its nine lines: no SUPER RACER SCORE line
//   (removed 2026-11-08), so inside the box only black, 12'hf00 and the
//   caption colour 12'hccc appear, and the lamp box starts right below it;
// - with pro = 0, nothing is drawn below the box.
`timescale 1ns/1ps
module tb_panel;
    reg clk = 0, rst = 1, pxl_cen = 0;
    always #5 clk = ~clk;
    reg [2:0] scan = 0;
    reg [7:0] row_on = 0;
    reg [27:0] seg = 0;
    reg [8:0] x = 0, y = 0;
    reg tenk = 0;
    wire [11:0] rgb0, rgb1;
    wire [11:0] bg = 12'h5a5;
    jtmonacogp_panel u0(.clk(clk),.rst(rst),.pxl_cen(pxl_cen),.scan(scan),.row_on(row_on),.seg(seg),
        .x(x),.y(y),.show(1'b1),.pro(1'b0),.tenk(tenk),
        .cars_lamps(15'd0),.bonus_lamps(15'd0),.rgb_in(bg),.rgb_out(rgb0));
    jtmonacogp_panel u1(.clk(clk),.rst(rst),.pxl_cen(pxl_cen),.scan(scan),.row_on(row_on),.seg(seg),
        .x(x),.y(y),.show(1'b1),.pro(1'b1),.tenk(tenk),
        .cars_lamps(15'd0),.bonus_lamps(15'd0),.rgb_in(bg),.rgb_out(rgb1));

    // the layout of jtmonacogp_panel.v, upright: u = 239 - y, w = x
    localparam integer U0 = 64, W0 = 88, BW = 112, BH = 178, LH = 19;
    function integer line_of(input integer w);   // 0..8, -1 outside
        integer j;
        begin
            line_of = -1;
            for (j = 0; j < 9; j = j + 1)
                if (w - W0 >= 8 + LH*j && w - W0 < 8 + LH*j + LH) line_of = j;
        end
    endfunction

    integer seed = 32'h50414e4c, k, s, xi, yi, u, w, bu, bw, ln, lw, checked = 0;
    integer lamps_lit = 0, lamps_dim = 0;
    reg lamp, in_new;
    task automatic sweep;
        for (xi = 0; xi < 360; xi = xi + 1)
            for (yi = 0; yi < 240; yi = yi + 1) begin
                x = xi; y = yi; #1;
                u = 239 - yi; w = xi; bu = u - U0; bw = w - W0;
                ln = line_of(w); lw = bw - 8 - LH*ln;
                lamp = ln == 5 && bu >= 49 && bu < 55 && lw >= 6 && lw < 13 && u >= U0 && u < U0 + BW;
                in_new = u >= U0 && u < U0 + BW && bw >= BH && bw < BH + 50;   // the lamp box
                if (!lamp && !in_new && rgb0 !== rgb1)
                    $fatal(1, "pro changed (%0d, %0d) outside its additions: %h -> %h", xi, yi, rgb0, rgb1);
                if (in_new && rgb0 !== bg)
                    $fatal(1, "pro = 0 draws below the box at (%0d, %0d)", xi, yi);
                if (u >= U0 && u < U0 + BW && bw >= 0 && bw < BH &&
                    rgb1 !== 12'h000 && rgb1 !== 12'hf00 && rgb1 !== 12'hccc)
                    $fatal(1, "pro = 1: (%0d, %0d) inside the box is %h: not black, f00 or ccc", xi, yi, rgb1);
                if (lamp) begin
                    if (rgb1 !== (tenk ? 12'hf00 : 12'h000))
                        $fatal(1, "10,000-point lamp at (%0d, %0d) is %h", xi, yi, rgb1);
                    if (tenk) lamps_lit = lamps_lit + 1; else lamps_dim = lamps_dim + 1;
                end
                checked = checked + 1;
            end
    endtask
    initial begin
        repeat (3) @(negedge clk);
        rst = 0;
        for (k = 0; k < 12; k = k + 1) begin
            // a random LED state: every row captured once
            for (s = 0; s < 8; s = s + 1) begin
                @(negedge clk);
                scan = s; row_on = $random(seed); seg = $random(seed); pxl_cen = 1;
                @(negedge clk); pxl_cen = 0;
            end
            tenk = k[0];
            sweep;
        end
        if (lamps_lit == 0 || lamps_dim == 0)
            $fatal(1, "coverage: lamps lit %0d dim %0d", lamps_lit, lamps_dim);
        $display("PASS panel: %0d pixels, pro = 0 and pro = 1 agree outside the Pro lamp and lamp box;", checked);
        $display("  no SUPER RACER SCORE line; lamp pixels lit (f00) %0d, unlit (black) %0d", lamps_lit, lamps_dim);
        $finish;
    end
endmodule
