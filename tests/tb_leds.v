// SPDX-License-Identifier: GPL-3.0-or-later
// Sheet J (score display scan, selection and decoding): jtmonacogp_leds.v
// against the pin-wired reference tests/sheet_j_reference.v. V2 comes from a
// 456 x 264 raster at 7 MHz; every few lines the rank, score, N, R, timer
// and FLASH inputs take new random values (all sixteen codes, so the 7448's
// glyphs 10..15 are exercised too). Compared before every rising edge of
// the host clock: the scan count, the eight row drives and all 28 segments.
// Also checked: every scan position is visited and every row is seen both
// lit and (for rows 1..5) blanked by its FLASH line.
`timescale 1ns/1ps
module tb_leds #(parameter integer FRAMES = 40);
    reg clk = 0;
    always #34.95 clk = ~clk;
    reg rst = 1, cen7 = 0;
    always @(posedge clk) cen7 <= ~cen7;
    reg [8:0] hc = 0, vc = 0;
    always @(negedge clk) if (cen7) begin
        hc <= hc == 9'd455 ? 9'd0 : hc + 9'd1;
        if (hc == 9'd455) vc <= vc == 9'd263 ? 9'd0 : vc + 9'd1;
    end
    wire v2 = vc[2];
    reg [79:0] ranks = 0;
    reg [15:0] p = 0;
    reg [11:0] n = 0, r = 0;
    reg [3:0] t1 = 0, t2 = 0;
    reg [5:1] flash = 0;

    wire [2:0] scan, rscan;
    wire [7:0] row, rrow;
    wire [27:0] seg, rseg;
    jtmonacogp_leds uut(.clk(clk), .rst(rst), .pxl_cen(cen7), .v2(v2), .ranks(ranks), .p(p), .n(n), .r(r),
        .t1(t1), .t2(t2), .flash(flash), .scan(scan), .row_on(row), .seg(seg));
    sheet_j_reference ref_j(.v2(v2), .ranks(ranks), .p(p), .n(n), .r(r), .t1(t1), .t2(t2), .flash(flash),
        .scan(rscan), .row_on(rrow), .seg(rseg));

    integer checks = 0;
    reg [7:0] scans_seen = 0, lit_seen = 0, dark_seen = 0;
    reg [15:0] codes_seen = 0;
    always @(posedge clk) if (!rst) begin
        #33;
        checks = checks + 1;
        if ({scan, row, seg} !== {rscan, rrow, rseg})
            $fatal(1, "mismatch at %0t: RTL scan %0d rows %b seg %h, REF scan %0d rows %b seg %h",
                   $time, scan, row, seg, rscan, rrow, rseg);
        scans_seen[scan] = 1'b1;
        lit_seen = lit_seen | row;
        if (scan < 5 && !row[scan]) dark_seen[scan] = 1'b1;
        codes_seen[uut.dig[3:0]] = 1'b1;
    end

    integer f, l;
    initial begin
        repeat (4) @(negedge clk);
        rst = 0;
        for (f = 0; f < FRAMES; f = f + 1)
            for (l = 0; l < 264; l = l + 8) begin
                // change in the middle of a line, away from V2's edges
                wait (vc == l && hc == 200);
                @(negedge clk);
                ranks = {$random, $random, $random};
                p = $random; n = $random; r = $random;
                {t1, t2} = $random;
                flash = $random;
                if (f % 4 == 0) flash = 0;
                @(negedge clk);
            end
        if (scans_seen !== 8'hff || lit_seen !== 8'hff || dark_seen[4:0] !== 5'h1f || codes_seen !== 16'hffff)
            $fatal(1, "coverage: scans %b lit %b blanked %b codes %b", scans_seen, lit_seen, dark_seen, codes_seen);
        $display("PASS leds: %0d host clocks match the pin-wired sheet J reference (all 8 rows, 16 codes, FLASH blanking)", checks);
        $finish;
    end
endmodule
