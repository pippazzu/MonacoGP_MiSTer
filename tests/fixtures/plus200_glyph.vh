// SPDX-License-Identifier: GPL-3.0-or-later
// Reads the upright drawing of the Pro +200 graphic from Aldo's
// reconstruction, pro/reconstruction/plus200-glyph.txt (path relative to the
// repository root, where scripts/run_tests.py runs; +GLYPH=<path> overrides
// it). The drawing is the file's 16 lines of 32 '.' or '#' characters; '#'
// is lit. glyph_row[r][c] = 1 when row r (0 = top of the window), column c
// (0 = left) is lit. Included inside a testbench module.
//
// The trace's mapping (pro/docs/trace/SHEET_M_C_PLUS200_TRACE.md): raster
// line V = 0x080 + a is window column 31 - a, H clock 0x100 + r is window
// row r.
reg  [31:0] glyph_row [0:15];
integer     glyph_lit;

// The drawing's cell for the PR-54 address V0..V4 and H0..H3, whatever the
// window
function glyph_cell(input [8:0] hh, input [8:0] vv);
    glyph_cell = glyph_row[hh[3:0]][31 - vv[4:0]];
endfunction
// Lit on the raster: inside H 0x100-0x10F x V 0x080-0x09F and drawn
function glyph_at(input [8:0] hh, input [8:0] vv);
    glyph_at = hh[8:4] == 5'h10 && vv[8:5] == 4'h4 && glyph_cell(hh, vv);
endfunction

task load_glyph;
    reg [1023:0] gpath;
    reg [8*80-1:0] line;
    reg [7:0] ch;
    integer fd, len, r, c, ok;
    begin
        if (!$value$plusargs("GLYPH=%s", gpath)) gpath = "pro/reconstruction/plus200-glyph.txt";
        fd = $fopen(gpath, "r");
        if (!fd) $fatal(1, "cannot open the +200 drawing %0s", gpath);
        r = 0;
        glyph_lit = 0;
        while (!$feof(fd)) begin
            line = 0;
            len = $fgets(line, fd);
            // drop the line end
            while (len > 0 && (line[7:0] == 8'h0a || line[7:0] == 8'h0d)) begin
                line = line >> 8;
                len = len - 1;
            end
            ok = len == 32;
            for (c = 0; c < len && ok; c = c + 1) begin
                ch = line[8*(len-1-c) +: 8];
                if (ch != "." && ch != "#") ok = 0;
            end
            if (ok) begin
                if (r > 15) $fatal(1, "the +200 drawing has more than 16 rows");
                for (c = 0; c < 32; c = c + 1) begin
                    glyph_row[r][c] = line[8*(31-c) +: 8] == "#";
                    glyph_lit = glyph_lit + glyph_row[r][c];
                end
                r = r + 1;
            end
        end
        $fclose(fd);
        if (r != 16) $fatal(1, "the +200 drawing has %0d rows of 32, expected 16", r);
    end
endtask
