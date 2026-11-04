// SPDX-License-Identifier: GPL-3.0-or-later
// Sheet D scenery logic. The RTL (jtmonacogp_scenery.v) and the pin-wired
// reference (tests/sheet_d_reference.v) see the same stimulus on the real
// sheet E raster, with M1V, M2V and their load lines from the sheet B RTL
// (jtmonacogp_motion.v) moving a line every frame (/IN RESET low).
//
// - Every output and 24 internal state bits are compared for every pixel.
//   The reference's inputs change at the RTL's capture edge and its outputs
//   are read just before the next one, so both describe the same pixel.
// - The RTL must have settled before edge 1 (busy low), so that the PROM
//   data it registers are those of the settled pixel.
// - Directed checks, written here from the trace:
//   ROAD (IC74) follows /M1VL0 and /M2VL0: set to /V8 as /M1VL0 rises,
//       cleared while /M2VL0 is low;
//   /SIDE LINE is low only where MH4 is low;
//   IC49 never settles at 12 or above: QC and QD clear the four flip-flops
//       IC32 watches, which clears IC49;
//   with /COIN IN high those four flip-flops stay clear;
//   at most one /HOUSE output is low, and only while /HOUSE ST is low;
//   /GRASS (W) is low only while /GRASS AREA is low.
// FAST = 0: MH and /MHL0 come from the sheet B RTL. MH's pattern moves 24 -
//   2 * SP pixels a frame against the raster (SP is mostly 0 here), so IC40's
//   lower half, which samples /HS as MH reloads, turns about every 19 frames.
//   Frames PIC0 to PIC0 + 3 are written as pictures.
// FAST = 1: MH reloads with a random value on every line instead (as if SP
//   changed every line), so that IC40 turns every few dozen lines and IC49
//   runs through its count within a frame or two.
// The stimulus stands in for sheets A, C and I; it is not gameplay.
`timescale 1ns/1ps
module tb_scenery #(parameter integer FAST = 0, FRAMES = 40, PIC0 = 20,
                    IC90_TYPE = 1, IC66_NAND = 0, parameter [31:0] SEED = 32'h4d4f4e44);
    reg clk=0, rst=1;
    always #10.416666667 clk=~clk;                   // 48 MHz

    // PR-134 to PR-137 as stored in the core: the PROM banks of
    // jtmonacogp_proms.v at offsets 4608 to 6144, written the way JTFRAME
    // downloads the whole image.
    reg wr=0;
    reg [25:0] wa=0;
    reg [7:0] wd=0;
    reg [7:0] image[0:8799];
    reg [1023:0] path, outdir;
    wire [8:0] a134, a135, a136, a137;
    wire [7:0] q134, q135, q136, q137;
    jtmonacogp_prom #(.BASE(4608)) u_pr134(.clk(clk),.addr(a134),.q(q134),.wr(wr),.wr_addr(wa),.wr_data(wd));
    jtmonacogp_prom #(.BASE(5120)) u_pr135(.clk(clk),.addr(a135),.q(q135),.wr(wr),.wr_addr(wa),.wr_data(wd));
    jtmonacogp_prom #(.BASE(5632)) u_pr136(.clk(clk),.addr(a136),.q(q136),.wr(wr),.wr_addr(wa),.wr_data(wd));
    jtmonacogp_prom #(.BASE(6144)) u_pr137(.clk(clk),.addr(a137),.q(q137),.wr(wr),.wr_addr(wa),.wr_data(wd));

    wire pcen, p2cen;
    wire [8:0] h,v,x,y,hp,vp;
    wire hb,vb,hs,vs;
    jtmonacogp_cen u_cen(.clk(clk),.cen14(p2cen),.cen7(pcen));
    jtmonacogp_timing u_timing(.clk(clk),.rst(rst),.pxl_cen(pcen),.h(h),.v(v),
        .hblank(hb),.vblank(vb),.hs(hs),.vs(vs),.x(x),.y(y),.hpos(hp),.vpos(vp));

    // ---------------- Sheet B (RTL)
    reg [3:0] sp=4'd0;
    reg in_reset_n=0;
    wire tunnel_bridge_n;
    wire [8:0] b_mh;
    wire [7:0] m1v, m2v;
    wire [5:1] vdec_n;
    wire b_mhld_n, m1vld_n, m2vld_n;
    jtmonacogp_motion #(.M1V_INIT(8'hd0),.M2V_INIT(8'h40)) u_motion(.clk(clk),.rst(rst),.pxl_cen(pcen),
        .h(h),.hs(hs),.v(v),.sp(sp),.vs2(1'b0),.vs4(1'b0),.vs16(1'b1),
        .coin_in_n(1'b1),.coin_in_e1_n(1'b1),.ex_signal_n(1'b1),.game_n(1'b1),
        .in_reset_n(in_reset_n),.tunnel_bridge_n(tunnel_bridge_n),
        .pr133_addr(),.pr133_q(8'd0),
        .mh(b_mh),.mhld_n(b_mhld_n),.m1v(m1v),.m2v(m2v),.m1vld_n(m1vld_n),.m2vld_n(m2vld_n),
        .vdec_n(vdec_n),.ex_gameover_n(),.coin_start_n(),
        .q1(),.q2(),.q68(),.vsel(),.strobe_n(),.txt());

    // FAST: MH as sheet B's counter, stepped at edge 1 like it, reloading
    // {001, random, 0} at 1FF on every line.
    reg [2:0] tsr=0;
    wire t_edge1 = tsr[0], t_edge2 = tsr[1], t_edge3 = tsr[2];
    integer seed = SEED;
    reg [8:0] f_mh=0;
    reg [3:0] f_ld=0;
    always @(posedge clk) begin
        tsr <= rst ? 3'd0 : {tsr[1:0], pcen};
        if (t_edge1 && !rst) begin
            f_ld = $random(seed);
            f_mh <= f_mh == 9'h1ff ? {3'b001, f_ld, 1'b0} : f_mh + 9'd1;
        end
    end
    wire [8:0] mh = FAST ? f_mh : b_mh;
    wire mhl_n = FAST ? f_mh != 9'h1ff : b_mhld_n;

    // ---------------- Other sheets
    reg extend=0, coin_in_n=1;
    reg [3:0] s100=4'hf;

    // ---------------- RTL
    wire d_side, d_tgg, d_tgbl, d_garea, d_gw, d_hst, d_pool, d_wall, d_gravel, d_slide, d_slip;
    wire d_green, d_yline, d_tap, d_bap, d_road, d_road_n, d_tunnel_n, d_tb_n, d_ext, d_ext_n;
    wire d_cnc, d_rside, d_lside, d_zero, busy;
    wire [3:0] d_house;
    wire [23:0] d_dbg;
    jtmonacogp_scenery #(.IC90_TYPE(IC90_TYPE),.IC66_NAND(IC66_NAND)) dut(.clk(clk),.rst(rst),.pxl_cen(pcen),
        .hs(hs),.v7(v[7]),.v8(v[8]),.mh(mh),.mhl_n(mhl_n),.m1v(m1v),.m2v(m2v),
        .m1vl_n(m1vld_n),.m2vl_n(m2vld_n),.v4dec_n(vdec_n[4]),
        .extend(extend),.coin_in_n(coin_in_n),.s100(s100),
        .pr134_addr(a134),.pr135_addr(a135),.pr136_addr(a136),.pr137_addr(a137),
        .pr134_q(q134),.pr135_q(q135),.pr136_q(q136),.pr137_q(q137),
        .side_line_n(d_side),.tree_grass_g_n(d_tgg),.tree_grass_bl_n(d_tgbl),.grass_area_n(d_garea),
        .grass_w_n(d_gw),.house_st_n(d_hst),.house_n(d_house),.pool_n(d_pool),.wall_n(d_wall),
        .gravel_n(d_gravel),.slide_n(d_slide),.slip_n(d_slip),.green_belt_n(d_green),
        .y_line_n(d_yline),.tunnel_ap(d_tap),.bridge_ap(d_bap),.road(d_road),.road_n(d_road_n),
        .tunnel_n(d_tunnel_n),.tunnel_bridge_n(d_tb_n),.ext500(d_ext),.ext500_n(d_ext_n),
        .car_no_cont_n(d_cnc),.r_side_n(d_rside),.l_side_n(d_lside),.zero_area_n(d_zero),
        .dbg(d_dbg),.busy(busy));
    assign tunnel_bridge_n = d_tb_n;

    // ---------------- Pin-wired reference
    // Its inputs are the RTL's captured inputs, all changing at once at the
    // capture edge (edge 2).
    reg r_hs_n=1, r_v7=0, r_v8_n=1, r_mhl_n=1, r_m1vl_n=1, r_m2vl_n=1, r_v4dec_n=1;
    reg [8:0] r_mh=0;
    reg [7:0] r_m1v=0, r_m2v=0;
    reg r_extend=0, r_coin_in_n=1;
    reg [3:0] r_s100=4'hf;
    wire r_side, r_tgg, r_tgbl, r_garea, r_gw, r_hst, r_pool, r_wall, r_gravel, r_slide, r_slip;
    wire r_green, r_yline, r_tap, r_bap, r_road, r_road_n, r_tunnel_n, r_tb_n, r_ext, r_ext_n;
    wire r_cnc, r_rside, r_lside, r_zero;
    wire [3:0] r_house;
    wire [23:0] r_dbg;
    sheet_d_reference #(.IC90_TYPE(IC90_TYPE),.IC66_NAND(IC66_NAND)) reff(.d_hs_n(r_hs_n),.d_v7(r_v7),.d_v8_n(r_v8_n),
        .d_mh(r_mh),.d_mhl_n(r_mhl_n),.d_m1v(r_m1v),.d_m2v(r_m2v),.d_m1vl_n(r_m1vl_n),
        .d_m2vl_n(r_m2vl_n),.d_v4dec_n(r_v4dec_n),.d_extend(r_extend),.d_coin_in_n(r_coin_in_n),
        .d_s100(r_s100),
        .side_line_n(r_side),.tree_grass_g_n(r_tgg),.tree_grass_bl_n(r_tgbl),.grass_area_n(r_garea),
        .grass_w_n(r_gw),.house_st_n(r_hst),.house_n(r_house),.pool_n(r_pool),.wall_n(r_wall),
        .gravel_n(r_gravel),.slide_n(r_slide),.slip_n(r_slip),.green_belt_n(r_green),
        .y_line_n(r_yline),.tunnel_ap(r_tap),.bridge_ap(r_bap),.road(r_road),.road_n(r_road_n),
        .tunnel_n(r_tunnel_n),.tunnel_bridge_n(r_tb_n),.ext500(r_ext),.ext500_n(r_ext_n),
        .car_no_cont_n(r_cnc),.r_side_n(r_rside),.l_side_n(r_lside),.zero_area_n(r_zero),
        .dbg(r_dbg));

    wire [52:0] d_vec = {d_side, d_tgg, d_tgbl, d_garea, d_gw, d_hst, d_house, d_pool, d_wall,
                         d_gravel, d_slide, d_slip, d_green, d_yline, d_tap, d_bap, d_road, d_road_n,
                         d_tunnel_n, d_tb_n, d_ext, d_ext_n, d_cnc, d_rside, d_lside, d_zero, d_dbg};
    wire [52:0] r_vec = {r_side, r_tgg, r_tgbl, r_garea, r_gw, r_hst, r_house, r_pool, r_wall,
                         r_gravel, r_slide, r_slip, r_green, r_yline, r_tap, r_bap, r_road, r_road_n,
                         r_tunnel_n, r_tb_n, r_ext, r_ext_n, r_cnc, r_rside, r_lside, r_zero, r_dbg};
    reg [52:0] r_snap;
    // The pixel the RTL captures, and the one its registered outputs describe
    reg [8:0] cap_x=0, cap_y=0, out_x=0, out_y=0;
    reg cap_blank=1, out_blank=1;
    reg cap_m1vl_n=1, cap_m2vl_n=1, cap_v8=0, cap_mh4=0, cap_coin_n=1;
    reg out_m1vl_n=1, out_m2vl_n=1, out_v8=0, out_mh4=0, out_coin_n=1;

    // ---------------- Checks and stimulus
    integer pixels = 0, frames = 0, k, n, fp, sx, sy;
    reg running = 0, road_exp = 0, m1vl_prev = 1;
    integer sets[0:10], clears[0:10], lit[0:21], ic49_full = 0, ic49_max = 0, busy_max = 0, settle_n = 0;
    integer events = 0, coin_frames = 0;
    reg [10:0] ff_prev = 0;
    reg l68_prev = 0, c49_full_l = 0, sr68_low = 0;
    integer ic68_race = 0;
    integer l68_sets = 0, l68_clears = 0;
    reg [23:0] pic [0:359][0:239];

    // False colours, one per output, for the pictures (not the game's colours,
    // which sheet C mixes)
    function [23:0] colour(input integer dummy);
        begin
            colour = 24'h000000;
            if (d_road)          colour = 24'h303030;
            if (!d_green)        colour = 24'h557700;
            if (!d_garea)        colour = 24'h104010;
            if (!d_gw)           colour = 24'h80ff80;
            if (!d_tgbl)         colour = 24'h006060;
            if (!d_tgg)          colour = 24'h00c000;
            if (!d_gravel)       colour = 24'hc0a060;
            if (!d_pool)         colour = 24'h2040ff;
            if (!d_wall)         colour = 24'hff8000;
            if (!d_house[0])     colour = 24'hff0000;
            if (!d_house[1])     colour = 24'hff00ff;
            if (!d_house[2])     colour = 24'h804000;
            if (!d_house[3])     colour = 24'hffffff;
            if (!d_slip)         colour = 24'h00ffff;
            if (!d_yline)        colour = 24'hffff00;
            if (!d_side)         colour = 24'he0e0e0;
        end
    endfunction

    task write_pic(input integer num);
        begin
            fp = $fopen($sformatf("%0s/scenery%0s-%0d.ppm", outdir, IC66_NAND ? "-ic66nand" : "", num), "w");
            if (!fp) $fatal(1, "cannot open the picture file");
            // Upright when the raster is turned 90 degrees clockwise: H grows
            // downward, V to the left.
            $fwrite(fp, "P3\n%0d %0d\n255\n", 240*2, 360*2);
            for (sy = 0; sy < 360*2; sy = sy + 1)
                for (sx = 0; sx < 240*2; sx = sx + 1)
                    $fwrite(fp, "%0d %0d %0d\n", pic[sy/2][239 - sx/2][23:16],
                            pic[sy/2][239 - sx/2][15:8], pic[sy/2][239 - sx/2][7:0]);
            $fclose(fp);
        end
    endtask

    always @(posedge clk) if (!rst) begin
        if (t_edge1 && running) begin
            if (busy) $fatal(1, "RTL still settling at edge 1 (h=%h v=%h)", h, v);
        end
        // IC68's /S and /R released in the same pixel, after a pixel with
        // both low: the settled model holds the latch (a board race)
        if (t_edge1 && running) begin
            if (dut.d48[dut.s49] && dut.d41[dut.s49] && sr68_low) ic68_race = ic68_race + 1;
            sr68_low = !dut.d48[dut.s49] && !dut.d41[dut.s49];
        end
        // Settling steps that changed the state, since the capture
        if (t_edge2) settle_n = 0;
        else if (busy) settle_n = settle_n + 1;
        if (running && settle_n > busy_max) busy_max = settle_n;
        if (t_edge2) begin
            r_snap <= r_vec;
            {r_hs_n, r_v7, r_v8_n, r_mhl_n, r_m1vl_n, r_m2vl_n, r_v4dec_n} <=
                {~hs, v[7], ~v[8], mhl_n, m1vld_n, m2vld_n, vdec_n[4]};
            r_mh <= mh; r_m1v <= m1v; r_m2v <= m2v;
            r_extend <= extend; r_coin_in_n <= coin_in_n; r_s100 <= s100;
            {out_x, out_y, out_blank} <= {cap_x, cap_y, cap_blank};
            {cap_x, cap_y, cap_blank} <= {x, y, hb | vb};
            {out_m1vl_n, out_m2vl_n, out_v8, out_mh4, out_coin_n} <=
                {cap_m1vl_n, cap_m2vl_n, cap_v8, cap_mh4, cap_coin_n};
            {cap_m1vl_n, cap_m2vl_n, cap_v8, cap_mh4, cap_coin_n} <=
                {m1vld_n, m2vld_n, v[8], mh[4], coin_in_n};
        end
        if (t_edge3 && running) begin
            pixels = pixels + 1;
            // ---------------- compare the pixel the outputs describe
            if (^d_vec === 1'bx || ^r_snap === 1'bx)
                $fatal(1, "unknown net at pixel %0d:\n RTL %b\n REF %b", pixels, d_vec, r_snap);
            if (d_vec !== r_snap)
                $fatal(1, "sheet D mismatch at pixel %0d (x=%0d y=%0d):\n RTL %b\n REF %b\n XOR %b",
                       pixels, out_x, out_y, d_vec, r_snap, d_vec ^ r_snap);
            // ---------------- directed checks
            if (!out_m2vl_n) road_exp = 0;
            else if (out_m1vl_n && !m1vl_prev) road_exp = !out_v8;
            m1vl_prev = out_m1vl_n;
            if (d_road !== road_exp) $fatal(1, "ROAD %b, expected %b (x=%0d y=%0d)", d_road, road_exp, out_x, out_y);
            if (!d_side && out_mh4) $fatal(1, "/SIDE LINE low with MH4 high");
            if (d_dbg[12:9] >= 4'd12) $fatal(1, "IC49 settled at %0d", d_dbg[12:9]);
            if (out_coin_n && |{d_dbg[23], d_dbg[19], d_dbg[18], d_dbg[17]})
                $fatal(1, "a flip-flop of IC34's clear is set with /COIN IN high");
            if ((d_house != 4'hf && d_hst) || (d_house != 4'hf && d_house != 4'he && d_house != 4'hd &&
                d_house != 4'hb && d_house != 4'h7))
                $fatal(1, "/HOUSE outputs %b with /HOUSE ST %b", d_house, d_hst);
            if (!d_gw && d_garea) $fatal(1, "/GRASS (W) low outside /GRASS AREA");
            // ---------------- coverage
            for (k = 0; k < 11; k = k + 1) begin
                if (d_dbg[23-k] && !ff_prev[10-k]) sets[k] = sets[k] + 1;
                if (!d_dbg[23-k] && ff_prev[10-k]) clears[k] = clears[k] + 1;
            end
            ff_prev = d_dbg[23:13];
            if (d_dbg[8] && !l68_prev) l68_sets = l68_sets + 1;
            if (!d_dbg[8] && l68_prev) l68_clears = l68_clears + 1;
            l68_prev = d_dbg[8];
            if (d_dbg[12:9] > ic49_max) ic49_max = d_dbg[12:9];
            n = 0;
            for (k = 0; k < 22; k = k + 1) begin
                case (k)
                    0: n = !d_side;   1: n = !d_tgg;   2: n = !d_tgbl;  3: n = !d_garea;
                    4: n = !d_gw;     5: n = !d_hst;   6: n = !d_house[0]; 7: n = !d_house[1];
                    8: n = !d_house[2]; 9: n = !d_house[3]; 10: n = !d_pool; 11: n = !d_wall;
                    12: n = !d_gravel; 13: n = !d_slide; 14: n = !d_slip; 15: n = !d_green;
                    16: n = !d_yline; 17: n = d_tap;    18: n = d_bap;   19: n = d_road;
                    20: n = !d_tunnel_n; 21: n = d_ext;
                endcase
                lit[k] = lit[k] + n;
            end
            if (!out_blank && out_x < 360 && out_y < 240) pic[out_x][out_y] = colour(0);
        end
        // IC49 reaching 12 inside a pixel, before its clear (RTL internal)
        if (running && dut.c49 == 4'd12 && !c49_full_l) ic49_full = ic49_full + 1;
        c49_full_l = dut.c49 == 4'd12;
        if (pcen && running) begin
            // ---------------- next pixel's stimulus
            if (v == 9'h1f4 && h == 9'h0a0) begin
                frames = frames + 1;
                if (!FAST && frames > PIC0 && frames <= PIC0 + 4) write_pic(frames - PIC0);
                for (sy = 0; sy < 360; sy = sy + 1)
                    for (sx = 0; sx < 240; sx = sx + 1) pic[sy][sx] = 24'h000000;
                // /COIN IN high for one frame in twelve: the clear of IC34
                coin_in_n <= frames % 12 == 6;
                if (coin_in_n) coin_frames = coin_frames + 1;
                if (($random(seed) & 3) == 0) extend <= ~extend;
                // SP mostly 0 (fastest drift), sometimes another value
                sp <= ($random(seed) & 7) == 0 ? $random(seed) : 4'd0;
            end
            // S-100 code changes at random pixels: a few per frame, or a burst
            if (($random(seed) & 32'h7fffffff) % (FAST ? 6000 : 20000) == 0) begin
                n = ($random(seed) & 32'h7fffffff) % 12;
                s100 <= n >= 10 ? 4'hf : n;
                events = events + 1;
            end
        end
    end

    initial begin
        if (!$value$plusargs("ROM=%s",path) || !$value$plusargs("OUT=%s",outdir))
            $fatal(1,"missing ROM/OUT");
        $readmemh(path,image);
        for (k = 0; k < 11; k = k + 1) begin sets[k] = 0; clears[k] = 0; end
        for (k = 0; k < 22; k = k + 1) lit[k] = 0;
        repeat(4) @(negedge clk);
        for (n=0;n<8800;n=n+1) begin
            @(negedge clk); wa=n; wd=image[n]; wr=1;
        end
        @(negedge clk); wr=0;
        repeat(4) @(negedge clk);
        for (n=0;n<512;n=n+1)
            if (u_pr134.mem[n] !== image[4608+n] || u_pr135.mem[n] !== image[5120+n] ||
                u_pr136.mem[n] !== image[5632+n] || u_pr137.mem[n] !== image[6144+n])
                $fatal(1,"PROM download failed at %0d",n);
        coin_in_n = 0;
        rst=0;
        running=1;
        wait (frames == FRAMES);
        running = 0;
        $display("PASS scenery%0s (IC90 type %0d, IC66 %0s): %0d pixels over %0d frames match the pin-wired sheet D reference",
                 FAST ? " fast" : "", IC90_TYPE, IC66_NAND ? "NAND" : " AND", pixels, frames);
        $display("  S-100 code changes %0d; frames with /COIN IN high %0d; IC49 reached 12 %0d times, highest settled count %0d; RTL settled within %0d steps",
                 events, coin_frames, ic49_full, ic49_max, busy_max);
        $display("  flip-flop sets/clears: IC40 GRAVEL %0d/%0d, IC40 lower %0d/%0d, IC38 POOL %0d/%0d, IC38 other %0d/%0d,",
                 sets[0], clears[0], sets[1], clears[1], sets[2], clears[2], sets[3], clears[3]);
        $display("    IC31 SLIP %0d/%0d, IC31 TUNNEL %0d/%0d, IC25 lower %0d/%0d, IC25 EXT. 500 %0d/%0d,",
                 sets[4], clears[4], sets[5], clears[5], sets[6], clears[6], sets[7], clears[7]);
        $display("    IC88 upper %0d/%0d, IC88 lower %0d/%0d, IC74 ROAD %0d/%0d; IC68 %0d/%0d",
                 sets[8], clears[8], sets[9], clears[9], sets[10], clears[10], l68_sets, l68_clears);
        $display("  pixels active: /SIDE LINE %0d, /TREE&GRASS (G) %0d, (BL) %0d, /GRASS AREA %0d, /GRASS (W) %0d, /HOUSE ST %0d,",
                 lit[0], lit[1], lit[2], lit[3], lit[4], lit[5]);
        $display("    /HOUSE (R) %0d, (Mu) %0d, (St) %0d, (W) %0d, /POOL %0d, /WALL %0d, /GRAVEL %0d, /SLIDE %0d, /SLIP %0d,",
                 lit[6], lit[7], lit[8], lit[9], lit[10], lit[11], lit[12], lit[13], lit[14]);
        $display("    /GREEN BELT %0d, /Y-LINE %0d, TUNNEL AP %0d, BRIDGE AP %0d, ROAD %0d, /TUNNEL %0d, EXT. 500 %0d",
                 lit[15], lit[16], lit[17], lit[18], lit[19], lit[20], lit[21]);
        $display("  IC68 /S and /R released together (held; a race on the board): %0d", ic68_race);
        $display("  reference hazards absorbed (pulses under 3 ns): IC68 /S %0d /R %0d; IC49 CK %0d MR %0d; IC88 lower CK %0d; IC40 lower CK %0d",
                 reff.ic68.fs.hazards, reff.ic68.fr.hazards, reff.ic49.fck.hazards, reff.ic49.fmr.hazards,
                 reff.ic88b.fck.hazards, reff.ic40b.fck.hazards);
        // Coverage the run must reach
        for (k = 0; k < 11; k = k + 1)
            if ((FAST || (k != 2 && k != 3 && k != 7)) && (sets[k] == 0 || clears[k] == 0))
                $fatal(1, "flip-flop %0d of the coverage list never set and cleared", k);
        if (l68_sets == 0 || l68_clears == 0) $fatal(1, "IC68 never changed");
        if (FAST && ic49_full == 0) $fatal(1, "IC49 never reached 12");
        for (k = 0; k < 22; k = k + 1)
            if (lit[k] == 0) $display("  NOTE: output %0d of the coverage list was never active", k);
        $finish;
    end
endmodule
