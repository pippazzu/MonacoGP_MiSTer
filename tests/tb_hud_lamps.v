// SPDX-License-Identifier: GPL-3.0-or-later
// Pro bonus lamps under the score overlay (jtmonacogp_hud.v, pro = 1).
// For a set of (cars overtaken, stored bonuses) lamp words the whole raster
// is swept and every pixel of the strip under the score is checked (lamps
// 1 x 2 pixels, 2 apart, from 2 pixels into the strip): lamp k
// of the top bar lit for k < cars, green (12'h0f0) for lamps 1..9 and red
// (12'hf00) for 10..14; the bottom bar lit red for k < bonuses; unlit lamps
// black, like the gaps; the gaps black; outside the strip and the score,
// time and gear boxes, the picture unchanged. The gear box is two cells
// (HI or LO). With pro = 0, or the score
// overlay off, no pixel of the strip changes.
// Output: hud_lamps.ppm, the upright screen for cars 11, bonuses 3.
`timescale 1ns/1ps
module tb_hud_lamps;
    reg  [8:0] x = 0, y = 0;
    reg        pro = 1, show = 1, hi = 1;
    reg [14:0] cars = 0, bon = 0;
    wire [11:0] rgb;
    // a background that is none of the overlay's colours
    wire [8:0] bu = 9'd239 - y;
    wire [11:0] bg = (bu >= 9'd72 && bu < 9'd168) ? 12'h777 : 12'h5a5;
    jtmonacogp_hud u_hud(.x(x),.y(y),.show_score(show),.show_gear(1'b1),
        .t_tens(4'd4),.t_units(4'd7),.score(16'h1260),.high_gear(hi),
        .pro(pro),.cars_lamps(cars),.bonus_lamps(bon),
        .rgb_in(bg),.rgb_out(rgb));

    localparam integer SU = 176, SW = 40;           // score box, upright
    localparam integer LU = SU, LW = SW + 8;        // the strip: 32 x 8
    integer errors = 0;

    function [14:0] bar(input integer n);
        bar = n >= 15 ? 15'h3fff : (15'd1 << n) - 15'd1;
    endfunction

    // expected colour at upright (u, w), or 12'hxxx outside the strip
    function [11:0] want(input integer u, input integer w, input [14:0] c, input [14:0] b);
        integer lu, k, r;
        begin
            want = 12'hxxx;
            if (u >= LU && u < LU + 32 && w >= LW && w < LW + 8) begin
                want = 12'h000;
                lu = u - LU - 2; r = w - LW;
                if (lu >= 0 && lu < 27 && lu % 2 == 0 && (r == 1 || r == 2 || r == 5 || r == 6)) begin
                    k = lu / 2;
                    if (r < 4) want = !c[k] ? 12'h000 : k < 9 ? 12'h0f0 : 12'hf00;
                    else       want = !b[k] ? 12'h000 : 12'hf00;
                end
            end
        end
    endfunction

    task sweep(input integer nc, input integer nb, input expect_strip);
        integer xi, yi, u, w;
        reg [11:0] e;
        begin
            cars = bar(nc); bon = bar(nb);
            for (yi = 0; yi < 240; yi = yi + 1)
                for (xi = 0; xi < 360; xi = xi + 1) begin
                    x = xi; y = yi; #1;
                    u = 239 - yi; w = xi;
                    e = want(u, w, cars, bon);
                    if (e !== 12'hxxx) begin
                        if (!expect_strip) begin
                            if (rgb !== bg) begin
                                errors = errors + 1;
                                if (errors < 10) $display("FAIL strip shown: pro=%0d show=%0d u=%0d w=%0d rgb=%h", pro, show, u, w, rgb);
                            end
                        end else if (rgb !== e) begin
                            errors = errors + 1;
                            if (errors < 10) $display("FAIL cars=%0d bonus=%0d u=%0d w=%0d rgb=%h want %h", nc, nb, u, w, rgb, e);
                        end
                    end
                end
        end
    endtask

    task dump(input [8*32-1:0] name);
        integer fd, u, w;
        begin
            fd = $fopen(name, "w");
            $fwrite(fd, "P3\n240 360\n15\n");
            for (w = 0; w < 360; w = w + 1)
                for (u = 0; u < 240; u = u + 1) begin
                    x = w; y = 239 - u; #1;
                    $fwrite(fd, "%0d %0d %0d\n", rgb[11:8], rgb[7:4], rgb[3:0]);
                end
            $fclose(fd);
        end
    endtask

    initial begin
        sweep(0, 0, 1);
        sweep(11, 3, 1);
        sweep(9, 14, 1);
        sweep(15, 15, 1);
        // the score's own box and the picture around the strip are untouched
        cars = bar(5); bon = bar(2);
        x = SW; y = 239 - SU; #1;               // score box corner: black
        if (rgb !== 12'h000) begin errors = errors + 1; $display("FAIL score box %h", rgb); end
        x = LW + 8; y = 239 - (LU + 5); #1;     // one line below the strip
        if (rgb !== bg) begin errors = errors + 1; $display("FAIL below strip %h", rgb); end
        x = LW + 3; y = 239 - (LU - 1); #1;     // left of the strip
        if (rgb !== bg) begin errors = errors + 1; $display("FAIL left of strip %h", rgb); end
        // the gear reads HI or LO, two cells either way
        hi = 0; x = 312; y = 239 - 48; #1;      // where LOW's W was
        if (rgb !== bg) begin errors = errors + 1; $display("FAIL gear box is wider than LO: %h", rgb); end
        x = 312; y = 239 - 40; #1;              // inside the LO box
        if (rgb === bg) begin errors = errors + 1; $display("FAIL no LO box"); end
        hi = 1;
        pro = 0; sweep(11, 3, 0);
        pro = 1; show = 0; sweep(11, 3, 0);
        show = 1;
        cars = bar(11); bon = bar(3);
        dump("hud_lamps.ppm");
        if (errors) $fatal(1, "tb_hud_lamps: %0d errors", errors);
        $display("PASS tb_hud_lamps");
        $finish;
    end
endmodule
