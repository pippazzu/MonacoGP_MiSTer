// SPDX-License-Identifier: GPL-3.0-or-later
// The score display panel drawn over the picture. NOT original circuitry:
// the cabinet has a separate LED panel (sheet J's LED board: 1ST..5TH,
// YOUR SCORE, 人中 = players to date, 位 = rank) and the timer's two-digit
// display behind connector H; this draws what they show, for a MiSTer
// without them.
//
// It is driven by sheet J's multiplexed outputs, like the real LEDs: while
// row k's transistor conducts, the segments of that row are those on the 28
// segment lines, and they stay as captured until the row's next scan (one
// scan of the eight rows takes 64 lines). A row blanked by its FLASH line
// during its scan is dark until the next one, so the flashing shows as on
// the panel. Group 1 (units column) of rows 7 and 8 is not on the LED board:
// it goes through connector H to the timer display (row 7 = tens T2, row 8
// = units T1).
//
// Upright layout (240 x 360 screen, see jtmonacogp_hud.v for the raster
// mapping), a black box with red seven-segment digits (unlit segments dim):
//   1ST  dddd
//   2ND  dddd
//   3RD  dddd
//   4TH  dddd
//   5TH  dddd
//   SCORE dddd
//   OF    ddd     (人中, players to date)
//   RANK  ddd     (位)
//   TIME   dd     (timer display)
// The row names are the panel's printed captions, not drawn by the board.
module jtmonacogp_panel(
    input             clk, rst, pxl_cen,
    input       [2:0] scan,
    input       [7:0] row_on,
    input      [27:0] seg,
    input       [8:0] x, y,
    input             show,
    input      [11:0] rgb_in,
    output reg [11:0] rgb_out
);
    // ---------------------------------------------------- LED persistence
    reg [8*28-1:0] lit;                 // row k at [28*k +: 28]
    always @(posedge clk) begin
        if (rst) lit <= 0;
        else if (pxl_cen) lit[28*scan +: 28] <= row_on[scan] ? seg : 28'd0;
    end

    // ---------------------------------------------------- layout
    wire [8:0] u = 9'd239 - y;          // upright column, 0 = left
    wire [8:0] w = x;                   // upright line, 0 = top
    localparam [8:0] U0 = 9'd64, W0 = 9'd88;     // box origin
    localparam [8:0] BW = 9'd112, BH = 9'd178;   // box size
    localparam [8:0] LH = 9'd19;                 // line pitch
    localparam [8:0] DU = 9'd56;                 // first digit column, from U0
    localparam [8:0] DP = 9'd12;                 // digit pitch
    wire in_box = show && u >= U0 && u < U0 + BW && w >= W0 && w < W0 + BH;
    wire [8:0] bu = u - U0, bw = w - W0;
    // line 0..8 and the position within it (8 px margin at the top)
    reg [3:0] line;
    reg [8:0] lw;
    integer j;
    always @* begin
        line = 4'd15; lw = 9'd0;
        for (j = 0; j < 9; j = j + 1)
            if (bw >= 9'd8 + LH*j[8:0] && bw < 9'd8 + LH*j[8:0] + LH) begin
                line = j[3:0]; lw = bw - 9'd8 - LH*j[8:0];
            end
    end

    // captions, 6 characters from 8 px inside the box
    reg [47:0] cap;
    always @* case (line)
        4'd0: cap = "1ST   "; 4'd1: cap = "2ND   "; 4'd2: cap = "3RD   ";
        4'd3: cap = "4TH   "; 4'd4: cap = "5TH   "; 4'd5: cap = "SCORE ";
        4'd6: cap = "OF    "; 4'd7: cap = "RANK  "; 4'd8: cap = "TIME  ";
        default: cap = "      ";
    endcase
    wire       in_cap = bu >= 9'd8 && bu < 9'd8 + 9'd48 && lw >= 9'd6 && lw < 9'd13 && line != 4'd15;
    wire [8:0] cu = bu - 9'd8;
    wire [2:0] ci = cu[8:3];
    wire [7:0] ch = cap[(3'd5 - ci)*8 +: 8];
    wire [8:0] frow = lw - 9'd6;        // 0..6 inside in_cap
    wire       cap_ink;
    jtmonacogp_font u_font(.ch(ch), .row(frow[2:0]), .col(cu[2:0]), .pix(cap_ink));

    // digits: 4 positions (group 4 .. group 1) from DU, each 8 x 15
    wire [8:0] du = bu - DU;
    reg  [1:0] pos;
    reg        in_dig;
    reg  [3:0] su;                      // within the digit, 0..7
    always @* begin
        in_dig = 0; pos = 0; su = 0;
        if (bu >= DU && bu < DU + 4*DP && line != 4'd15 && lw >= 9'd2 && lw < 9'd17) begin
            pos = du < DP ? 2'd0 : du < 2*DP ? 2'd1 : du < 3*DP ? 2'd2 : 2'd3;
            su  = du - DP*pos;
            in_dig = su < 4'd8;
        end
    end
    wire [8:0] lw2 = lw - 9'd2;
    wire [3:0] sw = lw2[3:0];           // 0..14 inside a digit
    // segment a..g under this pixel
    reg [6:0] at;
    always @* begin
        at = 0;
        at[0] = sw == 0  && su >= 1 && su <= 6;                     // a
        at[1] = su == 7  && sw >= 1 && sw <= 6;                     // b
        at[2] = su == 7  && sw >= 8 && sw <= 13;                    // c
        at[3] = sw == 14 && su >= 1 && su <= 6;                     // d
        at[4] = su == 0  && sw >= 8 && sw <= 13;                    // e
        at[5] = su == 0  && sw >= 1 && sw <= 6;                     // f
        at[6] = sw == 7  && su >= 1 && su <= 6;                     // g
    end
    // the digit shown at (line, pos): group = 4 - pos
    reg [6:0] segs;
    reg       present;
    always @* begin
        segs = 0; present = 0;
        case (line)
            4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5: begin
                present = 1; segs = lit[28*line[2:0] + 7*(3-pos) +: 7];
            end
            4'd6: begin present = pos != 2'd3; segs = lit[28*6 + 7*(3-pos) +: 7]; end
            4'd7: begin present = pos != 2'd3; segs = lit[28*7 + 7*(3-pos) +: 7]; end
            4'd8: begin                                  // timer: tens, units
                present = pos >= 2'd2;
                segs = pos == 2'd2 ? lit[28*6 +: 7] : lit[28*7 +: 7];
            end
            default: ;
        endcase
    end
    wire on_seg  = in_dig && present && |(at & segs);
    wire off_seg = in_dig && present && |at;

    always @* begin
        if (!in_box) rgb_out = rgb_in;
        else if (on_seg) rgb_out = 12'hf31;
        else if (off_seg) rgb_out = 12'h300;
        else if (in_cap && cap_ink) rgb_out = 12'hccc;
        else rgb_out = 12'h000;
    end
endmodule
