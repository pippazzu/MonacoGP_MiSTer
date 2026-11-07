// SPDX-License-Identifier: GPL-3.0-or-later
// Pro +200 graphic on the real raster (pro/docs/trace/SHEET_M_C_PLUS200_TRACE.md):
// sheet M (jtmonacogp_rescue.v) and sheet C (jtmonacogp_colour.v), both with
// pro = 1, on the sheet E timing. BONUS CP (sheet N) is held high for two
// frames, then low for one. V-(4) is sheet B's decoder output 4, formed here
// as the trace reads it (7442, A, B, C = V5, V6, V7, D at GND). The other
// sheet M inputs are at rest and the PROM inputs at 0: PR-54 is in the RTL.
//
// Sheet C sees /+200 and a background drawn by the bench: white (/DUMMY (W)
// low) on lines V 0x090-0x0BF and yellow (/SIG (Y) low) on H 0x108-0x117, so
// the window lies over nothing, white, yellow and white over yellow. (Lines
// at rest would light planes of their own: /TREE & GRASS (BL) low and TUNNEL
// AP low keep the yellow, white and black planes off.) A second
// sheet C with pro = 0 gives the colour underneath.
//
// Checked for every pixel, from the trace and Aldo's drawing
// (pro/reconstruction/plus200-glyph.txt, read by tests/fixtures/plus200_glyph.vh):
// - /+200 is low exactly where BONUS CP is high, H 0x100-0x10F, V 0x080-0x09F
//   and the drawing is lit at row H - 0x100, column 31 - (V - 0x080);
// - there, sheet C gives pure red at full brightness (code 9, red 15, green
//   and blue 0, both halves of the pixel); elsewhere, the colour of the
//   original sheet;
// - each frame with BONUS CP high lights exactly the drawing's cells, and the
//   frame with BONUS CP low lights none.
// Outputs: plus200.ppm (the upright screen of the first frame, H downward,
// V to the left) and the window as text in the log.
`timescale 1ns/1ps
module tb_plus200;
`include "plus200_glyph.vh"
    reg clk=0, rst=1;
    always #10.416666667 clk=~clk;                   // 48 MHz
    reg [1023:0] outdir;

    wire pcen, p2cen;
    wire [8:0] h,v,x,y,hp,vp;
    wire hb,vb,hs,vs;
    jtmonacogp_cen u_cen(.clk(clk),.cen14(p2cen),.cen7(pcen));
    jtmonacogp_timing u_timing(.clk(clk),.rst(rst),.pxl_cen(pcen),.h(h),.v(v),
        .hblank(hb),.vblank(vb),.hs(hs),.vs(vs),.x(x),.y(y),.hpos(hp),.vpos(vp));

    // Sheet B's decoder, as the trace reads it: output n low for V7..V5 = n
    wire [5:1] vd;
    genvar gk;
    generate for (gk = 1; gk <= 5; gk = gk + 1) begin: g_vd
        assign vd[gk] = v[7:5] != gk;
    end endgenerate
    reg bonus_cp = 1;

    // ---------------- Sheet M
    wire plus200_n, busy;
    jtmonacogp_rescue #(.IC18_PIXELS(143)) dut(
        .clk(clk),.rst(rst),.pxl_cen(pcen),.h(h),.v(v),.hs(hs),.vdec_n(vd),.mh(5'd0),
        .vs4(1'b0),.vs16(1'b0),.vs32(1'b0),.vs64(1'b0),
        .extend(1'b0),.extend_n(1'b1),.game_n(1'b1),.coin_in_n(1'b1),.ex_signal_cp_n(1'b1),
        .s100c(1'b0),.car_no_cont_n(1'b1),.ext500(1'b0),.ext500_n(1'b1),.zero_area_n(1'b1),
        .bridge_ap(1'b0),.other_car_n(1'b1),.acce_d(1'b0),.explo_sel_d(1'b0),
        .pro(1'b1),.bonus_cp(bonus_cp),.plus200_n(plus200_n),
        .pr138_addr(),.pr139_addr(),.pr140_addr(),
        .pr138_q(8'd0),.pr139_q(8'd0),.pr140_q(8'd0),.pr141_q(8'd0),
        .rescue_bl_n(),.rescue_r_n(),.rescue_w_n(),.rescue_y_n(),.rl_side_n(),.ext_car_cont(),
        .rescue_cp_n(),.sig_y_n(),.sig_bl_n(),.dummy_area_n(),.dummy_w_n(),.dummy_r_n(),
        .dummy_bl_n(),.game_over(),.bridge_w_n(),.bridge_dbu_n(),.bridge_y_n(),.bridge_r_n(),
        .bridge_bu_n(),.l2_side_n(),.r2_side_n(),.dbg(),.busy(busy));

    // {H, V, HBLANK, BONUS CP} of the pixel sheet M captures at an edge 2
    // (cap1), and of the pixel whose outputs it has registered (cap_*)
    reg [19:0] cap1 = 0;
    reg [8:0] cap_h = 0, cap_v = 0;
    reg cap_hb = 1, cap_bcp = 0;
    wire bg_w_n = !(cap_v >= 9'h090 && cap_v <= 9'h0bf);
    wire bg_y_n = !(cap_h >= 9'h108 && cap_h <= 9'h117);

    // ---------------- Sheet C, Pro (u_c) and original (u_c0)
    wire [3:0] grb_hi, grb_lo, code_hi, code_lo, red, green, blue;
    wire [3:0] o_grb_hi, o_grb_lo, o_code_hi, o_code_lo, o_red, o_green, o_blue;
`define PLUS200_SHEET_C(name, pro_in, p_n, ghi, glo, chi, clo, r, g, b) \
    jtmonacogp_colour name(.clk(clk),.rst(rst),.cen7(pcen), \
        .area(5'd0),.other_body_n(1'b1),.other_tiar_n(1'b1),.other_car_n(1'b1), \
        .road_n(1'b1),.road(1'b0),.tg_g_n(1'b1),.tg_bl_n(1'b0),.house_st_n(1'b1), \
        .grass_area_n(1'b1),.grass_w_n(1'b1),.house_n(4'hf),.tunnel_ap(1'b0),.bridge_ap(1'b0), \
        .green_belt_n(1'b1),.y_line_n(1'b1),.gravel_n(1'b1),.pool_n(1'b1),.slip_n(1'b1), \
        .wall_n(1'b1),.side_line_n(1'b1),.extend(1'b0),.extend_n(1'b1), \
        .coin_start_n(1'b1),.ex_gameover_n(1'b1),.v4d(vd[4]), \
        .light_n(1'b1),.splay_n(1'b1),.explo_y_n(1'b1),.explo_r_n(1'b1),.explo_area_n(1'b1), \
        .player_n(1'b1),.player_body_n(1'b1),.player_tiar_n(1'b1),.player_bl_n(1'b1), \
        .sig_bl_n(1'b1),.sig_y_n(bg_y_n),.dummy_area_n(1'b1),.dummy_bl_n(1'b1), \
        .dummy_w_n(bg_w_n),.dummy_r_n(1'b1),.rescue_bl_n(1'b1),.rescue_w_n(1'b1), \
        .rescue_y_n(1'b1),.rescue_r_n(1'b1),.bridge_dbu_n(1'b1),.bridge_bu_n(1'b1), \
        .bridge_y_n(1'b1),.bridge_w_n(1'b1),.bridge_r_n(1'b1), \
        .pro(pro_in),.plus200_n(p_n),.belt(1'b0),.bdim_hi(),.bdim_lo(), \
        .grb_hi(ghi),.grb_lo(glo),.code_hi(chi),.code_lo(clo),.red(r),.green(g),.blue(b));
    `PLUS200_SHEET_C(u_c,  1'b1, plus200_n, grb_hi, grb_lo, code_hi, code_lo, red, green, blue)
    `PLUS200_SHEET_C(u_c0, 1'b0, plus200_n, o_grb_hi, o_grb_lo, o_code_hi, o_code_lo, o_red, o_green, o_blue)

    // ---------------- Checks
    integer frames = 0, pixels = 0, k, sx, sy, fp, lit_frame = 0, win_on = 0, win_off = 0;
    integer lit_off = 0, over_w = 0, over_y = 0, over_0 = 0;
    integer frame_lit [0:2];
    reg running = 0, exp_lit;
    reg [31:0] seen [0:15];                          // the window as lit in frame 0
    reg [11:0] pic [0:359][0:239];                   // visible pass, V 0x010-0x0FF

    always @(posedge clk) begin
        if (running && dut.edge2) begin
            // ---------------- the pixel registered at the previous edge 2
            pixels = pixels + 1;
            exp_lit = cap_bcp && glyph_at(cap_h, cap_v);
            if (plus200_n !== !exp_lit)
                $fatal(1, "/+200 %b at H %h V %h (HBLANK %b, BONUS CP %b): the drawing gives %0s",
                       plus200_n, cap_h, cap_v, cap_hb, cap_bcp, exp_lit ? "lit" : "unlit");
            if (exp_lit) begin
                if (code_hi !== 4'd9 || code_lo !== 4'd9 || grb_hi !== 4'b0011 || grb_lo !== 4'b0011 ||
                    red !== 4'd15 || green !== 4'd0 || blue !== 4'd0)
                    $fatal(1, "+200 pixel H %h V %h: code %0d/%0d GBR+ %b/%b RGB %0d %0d %0d, expected pure red",
                           cap_h, cap_v, code_hi, code_lo, grb_hi, grb_lo, red, green, blue);
                // underneath: IC2 code 7 white, 5 yellow, 0 none
                if (o_code_hi == 4'd7) over_w = over_w + 1;
                if (o_code_hi == 4'd5) over_y = over_y + 1;
                if (o_code_hi == 4'd0) over_0 = over_0 + 1;
                frame_lit[frames] = frame_lit[frames] + 1;
                if (frames == 0) seen[cap_h[3:0]][31 - cap_v[4:0]] = 1'b1;
            end else if ({code_hi, code_lo, grb_hi, grb_lo, red, green, blue} !==
                         {o_code_hi, o_code_lo, o_grb_hi, o_grb_lo, o_red, o_green, o_blue})
                $fatal(1, "H %h V %h, /+200 high: the colour differs from the original sheet", cap_h, cap_v);
            if (!plus200_n && !cap_bcp) lit_off = lit_off + 1;
            if (cap_h[8:4] == 5'h10 && cap_v[8:5] == 4'h4) begin
                if (cap_bcp) win_on = win_on + 1; else win_off = win_off + 1;
            end
            if (frames == 0 && !cap_hb && cap_v >= 9'h010 && cap_v <= 9'h0ff)
                pic[cap_h - 9'h098][cap_v - 9'h010] = {red, green, blue};
            // ---------------- one pixel on
            {cap_h, cap_v, cap_hb, cap_bcp} <= cap1;
            cap1 <= {h, v, hb, bonus_cp};
        end
        // Frames end in the vertical blanking, at line 0x1F8
        if (running && pcen && v == 9'h1f8 && h == 9'h098) begin
            frames = frames + 1;
            if (frames == 2) bonus_cp <= 0;
            if (frames == 3) running = 0;
        end
    end

    task write_pic;
        begin
            fp = $fopen($sformatf("%0s/plus200.ppm", outdir), "w");
            if (!fp) $fatal(1, "cannot open the picture file");
            // Upright: H downward, V to the left
            $fwrite(fp, "P3\n240 360\n255\n");
            for (sy = 0; sy < 360; sy = sy + 1)
                for (sx = 0; sx < 240; sx = sx + 1)
                    $fwrite(fp, "%0d %0d %0d\n", pic[sy][239 - sx][11:8] * 17,
                            pic[sy][239 - sx][7:4] * 17, pic[sy][239 - sx][3:0] * 17);
            $fclose(fp);
        end
    endtask

    integer r, c, diff;
    initial begin
        if (!$value$plusargs("OUT=%s",outdir)) $fatal(1,"missing OUT");
        load_glyph;
        for (k = 0; k < 3; k = k + 1) frame_lit[k] = 0;
        for (r = 0; r < 16; r = r + 1) seen[r] = 0;
        for (sy = 0; sy < 360; sy = sy + 1) for (sx = 0; sx < 240; sx = sx + 1) pic[sy][sx] = 0;
        repeat(4) @(negedge clk);
        rst = 0;
        running = 1;
        wait (!running);
        write_pic;
        // The window as lit in frame 0, upright, against the drawing
        diff = 0;
        $display("  +200 window, frame 0 (upright: H 0x100 at the top, V 0x09F at the left):");
        for (r = 0; r < 16; r = r + 1) begin
            for (c = 0; c < 32; c = c + 1) begin
                $write("%0s", seen[r][c] ? "#" : ".");
                if (seen[r][c] != glyph_row[r][c]) diff = diff + 1;
            end
            $write("\n");
        end
        if (diff != 0) $fatal(1, "the window differs from the drawing in %0d cells", diff);
        if (frame_lit[0] != glyph_lit || frame_lit[1] != glyph_lit || frame_lit[2] != 0)
            $fatal(1, "lit pixels per frame %0d %0d %0d, the drawing has %0d",
                   frame_lit[0], frame_lit[1], frame_lit[2], glyph_lit);
        if (win_on != 2*512 || win_off != 512)
            $fatal(1, "window pixels seen: %0d with BONUS CP high, %0d low (expected 1024, 512)", win_on, win_off);
        if (lit_off != 0) $fatal(1, "/+200 low with BONUS CP low");
        if (over_w == 0 || over_y == 0 || over_0 == 0)
            $fatal(1, "coverage: +200 not drawn over each of white, yellow and nothing");
        $display("PASS plus200: %0d pixels over 3 frames; the window H 0x100-0x10F x V 0x080-0x09F matches the drawing",
                 pixels);
        $display("  lit pixels per frame (BONUS CP high, high, low): %0d %0d %0d; drawing %0d cells; lit over white %0d, yellow %0d, nothing %0d",
                 frame_lit[0], frame_lit[1], frame_lit[2], glyph_lit, over_w, over_y, over_0);
        $finish;
    end
endmodule
