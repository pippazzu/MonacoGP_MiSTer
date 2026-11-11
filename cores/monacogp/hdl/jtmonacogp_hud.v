// SPDX-License-Identifier: GPL-3.0-or-later
// Score, time and gear overlay. NOT original circuitry: the cabinet shows
// the score and time on LED displays (sheets I, J, K); this draws them over
// the picture, white on black boxes as big as
// the letters, for a MiSTer without those displays. OSD settings switch the
// two groups off.
//
// The picture is turned clockwise for the cabinet's monitor, so the text is
// drawn turned the other way: on the upright screen (240 wide, 360 tall) a
// point (u, w) is the raster's x = w, y = 239 - u. Layout on the upright
// screen (Aldo's sketch), numbers only, about 32 pixels in from the edges
// to stay clear of a CRT's overscan:
//   top left     the time, 2 digits
//   top right    the score, 4 digits
//   bottom left  HI or LO (whichever gear is in)
//
// Pro Monaco GP (pro = 1) adds the cabinet's two bonus lamp bars, small,
// in a black strip one cell tall right under the score (Aldo, 2026-11-11):
//   dddd             the score
//   ..............   cars overtaken: lamps 1..9 green, 10..14 red
//   ..............   bonus x200: 14 red lamps
// Lamp 1 is on the left. Each lamp is 1 pixel wide and 2 tall, 2 apart
// (Aldo); the strip is as wide as the score. Lit lamps are the game's own green 12'h0f0
// and red 12'hf00, as on the full panel (jtmonacogp_panel.v, which
// documents the lamp count and colours); unlit lamps are the strip's black: the
// overlay adds no colour the board cannot make (Aldo). The strip follows show_score. With pro = 0 nothing
// changes.
module jtmonacogp_hud(
    input      [8:0] x, y,              // raster position, x 0..359, y 0..239
    input            show_score,        // TIME and SCORE
    input            show_gear,         // the gear
    input      [3:0] t_tens, t_units,   // sheet A timer
    input     [15:0] score,             // sheet I, thousands..units
    input            high_gear,
    // Pro board; ignored while pro = 0
    input            pro,
    input     [14:0] cars_lamps,        // top bar: bit 0 = lamp 1 (leftmost)
    input     [14:0] bonus_lamps,       // bottom bar: bit 0 = lamp 1
    input     [11:0] rgb_in,
    output reg [11:0] rgb_out
);
    localparam integer CH = 8;          // cell size on the upright screen
    function [7:0] digit(input [3:0] d);
        digit = d > 4'd9 ? "?" : "0" + {4'd0, d};
    endfunction
    // upright coordinates
    wire [8:0] u = 9'd239 - y;
    wire [8:0] w = x;

    // Fields: upright origin (u0, w0), up to 10 characters, text MSB first
    localparam [8:0] TIME_U = 32,  TIME_W = 40;
    localparam [8:0] SCORE_U = 176, SCORE_W = 40;     // 4 cells, right edge at 208
    localparam [8:0] GEAR_U = 32,  GEAR_W = 312;
    wire [79:0] t_time  = {digit(t_tens), digit(t_units), "        "};
    wire [79:0] t_score = {digit(score[15:12]), digit(score[11:8]), digit(score[7:4]), digit(score[3:0]), "      "};
    wire [79:0] t_gear  = {high_gear ? "HI" : "LO", "        "};

    // one field: inside, the cell's character and the pixel within it
    reg        in_box;
    reg [79:0] text;
    reg [3:0]  len;
    reg [8:0]  du, dw;
    always @* begin
        in_box = 0; text = 0; len = 0; du = 0; dw = 0;
        if (show_score && w >= TIME_W && w < TIME_W + CH && u >= TIME_U && u < TIME_U + 2*CH) begin
            in_box = 1; text = t_time; len = 2; du = u - TIME_U; dw = w - TIME_W;
        end
        if (show_score && w >= SCORE_W && w < SCORE_W + CH && u >= SCORE_U && u < SCORE_U + 4*CH) begin
            in_box = 1; text = t_score; len = 4; du = u - SCORE_U; dw = w - SCORE_W;
        end
        if (show_gear && w >= GEAR_W && w < GEAR_W + CH && u >= GEAR_U && u < GEAR_U + 2*CH) begin
            in_box = 1; text = t_gear; len = 2; du = u - GEAR_U; dw = w - GEAR_W;
        end
    end
    wire [3:0] cidx = du[6:3];
    wire [7:0] ch = text[(4'd9 - cidx)*8 +: 8];
    wire       ink;
    // 5 x 7 glyph in the 8 x 8 cell, one pixel in from the box's edge
    wire [2:0] col = du[2:0] - 3'd1, row = dw[2:0] - 3'd1;
    wire       in_glyph = du[2:0] >= 3'd1 && du[2:0] <= 3'd5 && dw[2:0] >= 3'd1;
    jtmonacogp_font u_font(.ch(ch), .row(row), .col(col), .pix(ink));

    // Pro: the lamp strip, w 48..55 right under the score, u 176..207;
    // lamps from u 178 to 204
    localparam [8:0] LAMP_U = SCORE_U, LAMP_W = SCORE_W + CH;
    localparam [8:0] SW = 4*CH;         // strip width, that of the score
    localparam [8:0] L0 = 2;            // lamp 1's column, from LAMP_U
    localparam [8:0] LP = 2;            // lamp pitch: 1 lit, 1 gap
    localparam [3:0] GREEN = 4'd9;      // green lamps on the top bar
    wire       in_strip = show_score && pro && u >= LAMP_U && u < LAMP_U + SW &&
                          w >= LAMP_W && w < LAMP_W + CH;
    wire [8:0] lu = u - LAMP_U - L0, lw = w - LAMP_W;
    wire [8:0] lk9 = lu / LP;
    wire [3:0] lk  = lk9[3:0];          // lamp 0..13 under this pixel
    wire       lrow = lw >= 9'd4;       // 0: cars overtaken, 1: bonus
    wire       in_lamp = in_strip && u >= LAMP_U + L0 && lu < 14*LP && lu - LP*lk9 < 1 &&
                         (lw == 9'd1 || lw == 9'd2 || lw == 9'd5 || lw == 9'd6);
    wire       lamp_lit = lrow ? bonus_lamps[lk] : cars_lamps[lk];
    wire [11:0] lamp_rgb = !lamp_lit ? 12'h000 : (!lrow && lk < GREEN) ? 12'h0f0 : 12'hf00;

    always @* rgb_out = in_box ? ((in_glyph && ink) ? 12'hfff : 12'h000) :
                        in_strip ? (in_lamp ? lamp_rgb : 12'h000) : rgb_in;
endmodule
