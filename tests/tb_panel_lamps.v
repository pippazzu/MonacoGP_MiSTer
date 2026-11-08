// SPDX-License-Identifier: GPL-3.0-or-later
// Pro bonus lamps on the score panel overlay: sheet I's lamp PROMs
// (jtmonacogp_lamps.v) driving the panel's lamp box (jtmonacogp_panel.v,
// pro = 1).
// 1. The PROM contents: every one of the 32 addresses is applied and the
//    element lines and the selected common are checked against
//    pro/reconstruction/lamp-proms.txt (path relative to the repository
//    root, where scripts/run_tests.py runs; +LAMPS=<path> overrides it).
//    The file is a RECONSTRUCTION (#69), not a dump.
// 2. For a set of (cars overtaken, stored bonuses) counts, BONUS A-D is
//    multiplexed by V2 as sheet N's IC133 does (4 lines per phase, a pixel
//    capture each clock here), and the panel is swept: the top bar must show
//    lamps 1..cars lit, 1..9 green (12'h0f0) and 10..14 red (12'hf00), the
//    bottom bar lamps 1..bonuses red, every other lamp black. There are 14
//    lamps a bar (Aldo); a count of 15 shows all 14.
//    G26 is taken as the top bar and Gd as the bottom bar, as in
//    jtmonacogp_game.v (the reconstruction's assumption 3).
// Output: panel_lamps.ppm, the upright panel and lamp box for cars 11,
// bonuses 3.
`timescale 1ns/1ps
module tb_panel_lamps;
    reg clk = 0, rst = 1, cen = 0, v2 = 0;
    always #5 clk = ~clk;
    reg  [3:0] bonus = 0;
    wire [14:0] g26, gd;
    jtmonacogp_lamps u_lamps(.clk(clk),.rst(rst),.cen(cen),.v2(v2),.bonus(bonus),.g26(g26),.gd(gd));
    reg [8:0] x = 0, y = 0;
    wire [11:0] rgb;
    jtmonacogp_panel u_panel(.clk(clk),.rst(rst),.pxl_cen(1'b0),.scan(3'd0),.row_on(8'd0),.seg(28'd0),
        .x(x),.y(y),.show(1'b1),.pro(1'b1),.cars_lamps(g26),.bonus_lamps(gd),
        .tenk(1'b0),
        .rgb_in(12'h5a5),.rgb_out(rgb));

    // the lamp box sits right below the nine-line box
    localparam integer U0 = 64, W0 = 88, BW = 112, BH = 178, LW0 = W0 + BH, LBH = 50;
    localparam integer LU = 11, LP = 6, GREEN = 9, NL = 14;

    // ---------------------------------------------------- the PROM file
    reg [7:0] pr01 [0:31], pr02 [0:31];
    task load_lamps;
        reg [1023:0] path;
        reg [8*200-1:0] line;
        reg [7:0] b [0:7];
        integer fd, len, n, i, got;
        begin
            if (!$value$plusargs("LAMPS=%s", path)) path = "pro/reconstruction/lamp-proms.txt";
            fd = $fopen(path, "r");
            if (!fd) $fatal(1, "cannot open the lamp PROM file %0s", path);
            n = 0;
            while (!$feof(fd)) begin
                line = 0;
                len = $fgets(line, fd);
                if (len > 0 && line[8*(len-1) +: 8] != "#") begin
                    got = $sscanf(line, "%h %h %h %h %h %h %h %h", b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7]);
                    if (got == 8) begin
                        for (i = 0; i < 8; i = i + 1)
                            if (n < 32) pr01[n + i] = b[i]; else pr02[n - 32 + i] = b[i];
                        n = n + 8;
                    end else if (got > 0)
                        $fatal(1, "lamp PROM file: a data line with %0d bytes", got);
                end
            end
            $fclose(fd);
            if (n != 64) $fatal(1, "lamp PROM file: %0d bytes, expected 64", n);
        end
    endtask

    task capture;   // one capture of the current address
        begin
            @(negedge clk); cen = 1;
            @(negedge clk); cen = 0;
        end
    endtask

    // ---------------------------------------------------- the panel
    integer xi, yi, u, w, bu, lbw, lrw, lk, lamps_lit = 0, lamps_dark = 0, i, a;
    reg lrow, lit;
    reg [11:0] want;
    reg [14:0] want_on;
    task check_panel(input integer cars, input integer bonuses);
        for (xi = LW0; xi < LW0 + LBH; xi = xi + 1)
            for (yi = 239 - (U0 + BW - 1); yi <= 239 - U0; yi = yi + 1) begin
                x = xi; y = yi; #1;
                u = 239 - yi; w = xi; bu = u - U0;
                lbw = w - LW0; lrow = lbw >= 27; lrw = lrow ? lbw - 21 : lbw;
                if (lrw >= 16 && lrw < 22 && bu >= LU && bu < LU + NL*LP && (bu - LU) % LP != LP - 1) begin
                    lk = (bu - LU) / LP;          // lamp lk + 1
                    lit = lk < (lrow ? bonuses : cars);
                    want = !lit ? 12'h000 : (!lrow && lk < GREEN) ? 12'h0f0 : 12'hf00;
                    if (rgb !== want)
                        $fatal(1, "cars %0d, bonuses %0d: %0s bar lamp %0d is %h, expected %h",
                               cars, bonuses, lrow ? "bottom" : "top", lk + 1, rgb, want);
                    if (lrw == 18 && (bu - LU) % LP == 2) begin
                        if (lit) lamps_lit = lamps_lit + 1; else lamps_dark = lamps_dark + 1;
                    end
                end
            end
    endtask

    task show_counts(input integer cars, input integer bonuses);
        integer ph;
        begin
            // two V2 periods of 4 lines each phase, a capture per "pixel"
            for (ph = 0; ph < 4; ph = ph + 1) begin
                v2 = ph[0];
                bonus = v2 ? bonuses[3:0] : cars[3:0];
                repeat (4) capture;
            end
            // a stale capture: V2 low with the bonus count still on BONUS
            // A-D (the address at a V2 edge if V2 and the count were not
            // aligned), then the settled phase, which must overwrite it
            v2 = 0; capture;
            bonus = cars[3:0]; repeat (4) capture;
            check_panel(cars, bonuses);
            $display("  cars %2d, bonuses %2d: top bar %b, bottom bar %b (lamp 15 .. 1)", cars, bonuses, g26, gd);
        end
    endtask

    integer fp, wi, ui;
    integer cars_list [0:7], bon_list [0:7];
    initial begin
        load_lamps;
        repeat (3) @(negedge clk);
        rst = 0;
        // 1. every address
        for (a = 0; a < 32; a = a + 1) begin
            v2 = a[4]; bonus = a[3:0];
            capture;
            want_on = ~{pr02[a][6:0], pr01[a]};
            if (pr02[a][7] ? gd !== want_on : g26 !== want_on)
                $fatal(1, "address %0d: common %0s elements %b, expected %b", a,
                       pr02[a][7] ? "Gd" : "G26", pr02[a][7] ? gd : g26, want_on);
            // the reconstruction's bar: count n lights lamps 1..n, and 15 lights
            // 1..14 (14 lamps; element line 15 is never lit)
            if (want_on !== (a[3:0] == 4'd15 ? 15'h3fff : 15'h7fff >> (15 - a[3:0])))
                $fatal(1, "address %0d: the file's bytes are not the bar graph the RTL test assumes", a);
            if (pr02[a][7] !== a[4])
                $fatal(1, "address %0d: O8 is not V2 in the file", a);
        end
        $display("PROM contents: 32 addresses agree with lamp-proms.txt (RECONSTRUCTION)");
        // 2. counts on the panel
        cars_list[0] = 0;  bon_list[0] = 0;
        cars_list[1] = 1;  bon_list[1] = 0;
        cars_list[2] = 9;  bon_list[2] = 1;
        cars_list[3] = 10; bon_list[3] = 2;
        cars_list[4] = 11; bon_list[4] = 3;
        cars_list[5] = 14; bon_list[5] = 7;
        cars_list[6] = 15; bon_list[6] = 15;
        cars_list[7] = 0;  bon_list[7] = 8;
        for (i = 0; i < 8; i = i + 1) begin
            show_counts(cars_list[i], bon_list[i]);
            if (i == 4) begin
                fp = $fopen($sformatf("%0s/panel_lamps.ppm", outdir), "w");
                $fwrite(fp, "P3\n%0d %0d\n15\n", BW, BH + LBH);
                for (wi = W0; wi < LW0 + LBH; wi = wi + 1)
                    for (ui = U0; ui < U0 + BW; ui = ui + 1) begin
                        x = wi; y = 239 - ui; #1;
                        $fwrite(fp, "%0d %0d %0d\n", rgb[11:8], rgb[7:4], rgb[3:0]);
                    end
                $fclose(fp);
            end
        end
        if (lamps_lit == 0 || lamps_dark == 0) $fatal(1, "coverage: lamps lit %0d, dark %0d", lamps_lit, lamps_dark);
        $display("PASS panel_lamps: 8 count pairs, lamp centres lit %0d, dark %0d; panel_lamps.ppm", lamps_lit, lamps_dark);
        $finish;
    end
    reg [1023:0] outdir;
    initial if (!$value$plusargs("OUT=%s", outdir)) outdir = ".";
endmodule
