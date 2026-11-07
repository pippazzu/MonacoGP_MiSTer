// SPDX-License-Identifier: GPL-3.0-or-later
// Sheet M rescue car, signs, lives and bridge. The RTL (jtmonacogp_rescue.v)
// and the pin-wired reference (tests/sheet_m_reference.v) see the same
// stimulus on the real sheet E raster.
//
// - Every output and 22 internal state bits are compared for every pixel;
//   the RTL must settle before edge 1.
// - The reference's 7 MHz edge (f7) is the RTL's capture edge; the other
//   sheets' nets reach it 5 ns later.
// - Directed checks, written here from the trace:
//   every rescue-counter period (load to load) is 464 - L pixels, L the value
//       IC43 gave IC36 at the load before (B 1000 = 8, or A 1010 = 10 when
//       IC42.6 was low: line 1FF with IC35's upper Q set);
//   IC46 is 0 while /COIN IN is high, and GAME OVER is high exactly while
//       IC46 is 0 and EXPLO. SEL. D is high;
//   at most one /BRIDGE output is low.
// The stimulus stands in for sheets A, B, C, D, F and H; it is not gameplay.
// The frame-counter lines step every line (Vs/64 falls four times a
// frame); the sheet B decoder lines V-(1)..V-(5) and MH0..MH4 are random.
// FAST = 1 divides IC18's capacitor by 1000.
// Pro board +200 graphic (pro/docs/trace/SHEET_M_C_PLUS200_TRACE.md): BONUS
// CP from sheet N is driven in every run from its own random sequence, which
// leaves the rest of the stimulus as it was. PRO selects the board in both
// models; /+200 is compared with the other outputs. Checked from the trace
// for every pixel, with the drawing of Aldo's reconstruction
// (tests/fixtures/plus200_glyph.vh):
//   /+200 low exactly when PRO, BONUS CP, V-(4) low, H4..H7 = 0 and the
//   drawing's cell for (H0..H3, V0..V4) is lit.
// BONUS CP must have been high on lit cells of the window (with PRO = 0:
// where they would be lit). Here V-(4) is random, so the window is not at its
// place on the raster; tests/tb_plus200.v draws it on the real raster.
`timescale 1ns/1ps
module tb_rescue #(parameter integer FAST = 1, FRAMES = 30, PIC0 = 20, NPIC = 3,
                   parameter [31:0] SEED = 32'h4d4f4e4d, parameter integer PRO = 0);
`include "plus200_glyph.vh"
    reg clk=0, rst=1;
    always #10.416666667 clk=~clk;                   // 48 MHz
    localparam integer N18 = FAST ? 143 : 143293;

    // PR-138..PR-141 as stored in the core (banks 13..16 of jtmonacogp_proms.v)
    reg wr=0;
    reg [25:0] wa=0;
    reg [7:0] wd=0;
    reg [7:0] image[0:8799];
    reg [1023:0] path, outdir;
    wire [8:0] a138, a139, a140;
    wire [7:0] q138, q139, q140, q141;
    jtmonacogp_prom #(.BASE(6656)) u_pr138(.clk(clk),.addr(a138),.q(q138),.wr(wr),.wr_addr(wa),.wr_data(wd));
    jtmonacogp_prom #(.BASE(7168)) u_pr139(.clk(clk),.addr(a139),.q(q139),.wr(wr),.wr_addr(wa),.wr_data(wd));
    jtmonacogp_prom #(.BASE(7680)) u_pr140(.clk(clk),.addr(a140),.q(q140),.wr(wr),.wr_addr(wa),.wr_data(wd));
    jtmonacogp_prom #(.BASE(8192)) u_pr141(.clk(clk),.addr(a140),.q(q141),.wr(wr),.wr_addr(wa),.wr_data(wd));

    wire pcen, p2cen;
    wire [8:0] h,v,x,y,hp,vp;
    wire hb,vb,hs,vs;
    jtmonacogp_cen u_cen(.clk(clk),.cen14(p2cen),.cen7(pcen));
    jtmonacogp_timing u_timing(.clk(clk),.rst(rst),.pxl_cen(pcen),.h(h),.v(v),
        .hblank(hb),.vblank(vb),.hs(hs),.vs(vs),.x(x),.y(y),.hpos(hp),.vpos(vp));

    // ---------------- Stimulus (changes at pxl_cen)
    reg [5:1] vd = 5'h1f;
    reg [4:0] mh = 0;
    reg [7:0] fc = 0;
    reg extend=0, game_n=1, coin_n=1, excp_n=1, s100c=0, cnc_n=1, ext500=0, zero_n=1, bap=1, other_n=1;
    reg acce_d=0, explo=0;
    reg bonus_cp=0;                                  // sheet N (Pro)
    wire pro = PRO != 0;
    wire vs4 = fc[1], vs16 = fc[3], vs32 = fc[4], vs64 = fc[5];

    // ---------------- RTL
    wire [20:0] d_out;
    wire [21:0] d_dbg;
    wire busy, d_plus_n;
    jtmonacogp_rescue #(.IC18_PIXELS(N18)) dut(
        .clk(clk),.rst(rst),.pxl_cen(pcen),.h(h),.v(v),.hs(hs),.vdec_n(vd),.mh(mh),
        .vs4(vs4),.vs16(vs16),.vs32(vs32),.vs64(vs64),
        .extend(extend),.extend_n(~extend),.game_n(game_n),.coin_in_n(coin_n),.ex_signal_cp_n(excp_n),
        .s100c(s100c),.car_no_cont_n(cnc_n),.ext500(ext500),.ext500_n(~ext500),.zero_area_n(zero_n),
        .bridge_ap(bap),.other_car_n(other_n),.acce_d(acce_d),.explo_sel_d(explo),
        .pro(pro),.bonus_cp(bonus_cp),.plus200_n(d_plus_n),
        .pr138_addr(a138),.pr139_addr(a139),.pr140_addr(a140),
        .pr138_q(q138),.pr139_q(q139),.pr140_q(q140),.pr141_q(q141),
        .rescue_bl_n(d_out[20]),.rescue_r_n(d_out[19]),.rescue_w_n(d_out[18]),.rescue_y_n(d_out[17]),
        .rl_side_n(d_out[16]),.ext_car_cont(d_out[15]),.rescue_cp_n(d_out[14]),
        .sig_y_n(d_out[13]),.sig_bl_n(d_out[12]),.dummy_area_n(d_out[11]),.dummy_w_n(d_out[10]),
        .dummy_r_n(d_out[9]),.dummy_bl_n(d_out[8]),.game_over(d_out[7]),
        .bridge_w_n(d_out[6]),.bridge_dbu_n(d_out[5]),.bridge_y_n(d_out[4]),.bridge_r_n(d_out[3]),
        .bridge_bu_n(d_out[2]),.l2_side_n(d_out[1]),.r2_side_n(d_out[0]),
        .dbg(d_dbg),.busy(busy));

    // ---------------- Pin-wired reference
    reg [2:0] sr=0;
    wire e1 = sr[0], e2 = sr[1], e3 = sr[2];
    reg f7=0;
    // Snapshot of the inputs the RTL captures at edge 2, applied 5 ns after f7
    reg [8:0] s_h=0, s_v=0;
    reg [5:1] s_vd=5'h1f;
    reg [4:0] s_mh=0;
    reg [16:0] s_misc=17'h107af;           // the RTL's reset values
    wire [8:0] r_h, r_v;
    wire [5:1] r_vd;
    wire [4:0] r_mh;
    wire [16:0] r_misc;
    assign #5 {r_h, r_v, r_vd, r_mh, r_misc} = {s_h, s_v, s_vd, s_mh, s_misc};
    // r_misc: {hs_n, vs4, vs16, vs32, vs64, extend, extend_n, game_n, coin_n, excp_n,
    //          100c, cnc_n, ext500, ext500_n, zero_n, bap, other_n} and acce_d, explo below
    reg s_acce=0, s_explo=0, s_bcp=0;
    wire r_acce, r_explo, r_bcp;
    assign #5 {r_acce, r_explo, r_bcp} = {s_acce, s_explo, s_bcp};
    wire [20:0] r_out;
    wire [21:0] r_dbg;
    wire r_plus_n;
    sheet_m_reference #(.IC18_PIXELS(N18)) reff(
        .f7(f7),.m_h(r_h),.m_v(r_v),.m_hs_n(r_misc[16]),.m_vd(r_vd),.m_mh(r_mh),
        .m_vs4(r_misc[15]),.m_vs16(r_misc[14]),.m_vs32(r_misc[13]),.m_vs64(r_misc[12]),
        .m_extend(r_misc[11]),.m_extend_n(r_misc[10]),.m_game_n(r_misc[9]),.m_coin_n(r_misc[8]),
        .m_excp_n(r_misc[7]),.m_100c(r_misc[6]),.m_cnc_n(r_misc[5]),.m_ext500(r_misc[4]),
        .m_ext500_n(r_misc[3]),.m_zero_n(r_misc[2]),.m_bap(r_misc[1]),.m_other_n(r_misc[0]),
        .m_acce_d(r_acce),.m_explo(r_explo),.m_pro(pro),.m_bonus_cp(r_bcp),.plus200_n(r_plus_n),
        .rescue_bl_n(r_out[20]),.rescue_r_n(r_out[19]),.rescue_w_n(r_out[18]),.rescue_y_n(r_out[17]),
        .rl_side_n(r_out[16]),.ext_car_cont(r_out[15]),.rescue_cp_n(r_out[14]),
        .sig_y_n(r_out[13]),.sig_bl_n(r_out[12]),.dummy_area_n(r_out[11]),.dummy_w_n(r_out[10]),
        .dummy_r_n(r_out[9]),.dummy_bl_n(r_out[8]),.game_over(r_out[7]),
        .bridge_w_n(r_out[6]),.bridge_dbu_n(r_out[5]),.bridge_y_n(r_out[4]),.bridge_r_n(r_out[3]),
        .bridge_bu_n(r_out[2]),.l2_side_n(r_out[1]),.r2_side_n(r_out[0]),.dbg(r_dbg));

    wire [43:0] d_vec = {d_plus_n, d_out, d_dbg};
    wire [43:0] r_vec = {r_plus_n, r_out, r_dbg};
    reg [43:0] r_snap;

    // ---------------- Checks and stimulus
    integer seed = SEED, pixels = 0, frames = 0, k, n, fp, sx, sy, hr, busy_max = 0, steps = 0;
    reg running = 0;
    integer last_load = -1, exp_period = 0, periods_456 = 0, periods_454 = 0;
    integer ups = 0, downs = 0, gameovers = 0, os18 = 0, max46 = 0;
    integer lit[0:20];
    reg [3:0] prev46 = 0;
    reg prev_go = 0, prev_o18 = 0, co_a = 1, co_b = 1, ex_a = 0, ex_b = 0;
    reg [20:0] prev_out = 21'h1fffff;
    // +200: the inputs of the pixel just registered, {H, V, V-(4), BONUS CP}
    reg [19:0] p2a = 0, p2b = 0;
    reg ex200;
    integer seed_b = SEED ^ 32'h2b323030, lit200 = 0, would200 = 0, low200 = 0;
    reg [23:0] pic [0:455][0:239];
    reg [8:0] cap_y = 0, out_y = 0, cap_hp = 0, out_hp = 0;
    reg cap_hb = 1, out_hb = 1, cap_vb = 1, out_vb = 1;

    task write_pic(input integer num);
        begin
            fp = $fopen($sformatf("%0s/rescue-%0s%0d.ppm", outdir, PRO ? "pro-" : "", num), "w");
            if (!fp) $fatal(1, "cannot open the picture file");
            // Upright, as the sheet B, D and H pictures: H down, V to the left,
            // each line drawn from hpos 424.
            $fwrite(fp, "P3\n%0d %0d\n255\n", 240*2, 456*2);
            for (sy = 0; sy < 456*2; sy = sy + 1) begin
                hr = (sy/2 + 424) % 456;
                for (sx = 0; sx < 240*2; sx = sx + 1)
                    $fwrite(fp, "%0d %0d %0d\n", pic[hr][239 - sx/2][23:16],
                            pic[hr][239 - sx/2][15:8], pic[hr][239 - sx/2][7:0]);
            end
            $fclose(fp);
        end
    endtask

    always @(posedge clk) begin
        sr <= rst ? 3'd0 : {sr[1:0], pcen};
        if (e1 && running) begin
            if (busy) $fatal(1, "RTL still settling at edge 1");
        end
        if (e2 || !running) steps = 0; else if (busy) steps = steps + 1;
        if (running && steps > busy_max) busy_max = steps;
        if (e2 && !rst) begin
            r_snap <= r_vec;
            f7 <= 1;
            {s_h, s_v, s_vd, s_mh} <= {h, v, vd, mh};
            s_misc <= {~hs, vs4, vs16, vs32, vs64, extend, ~extend, game_n, coin_n, excp_n,
                       s100c, cnc_n, ext500, ~ext500, zero_n, bap, other_n};
            {s_acce, s_explo, s_bcp} <= {acce_d, explo, bonus_cp};
            {co_a, co_b, ex_a, ex_b} <= {coin_n, co_a, explo, ex_a};
            {p2a, p2b} <= {h, v, vd[4], bonus_cp, p2a};
            {out_y, out_hp, out_hb, out_vb} <= {cap_y, cap_hp, cap_hb, cap_vb};
            {cap_y, cap_hp, cap_hb, cap_vb} <= {y, hp, hb, vb};
            // ---------------- rescue counter period, on the RTL's settled nets
            if (running && !dut.n44_8) begin
                if (last_load >= 0) begin
                    if (pixels - last_load != exp_period)
                        $fatal(1, "rescue counter period %0d, expected %0d", pixels - last_load, exp_period);
                    if (exp_period == 456) periods_456 = periods_456 + 1; else periods_454 = periods_454 + 1;
                end
                last_load = pixels;
                exp_period = 464 - dut.l43;
            end
        end else if (sr[2]) f7 <= 0;
        if (e3 && running) begin
            pixels = pixels + 1;
            if (^d_vec === 1'bx || ^r_snap === 1'bx)
                $fatal(1, "unknown net at pixel %0d:\n RTL %b\n REF %b", pixels, d_vec, r_snap);
            if (d_vec !== r_snap)
                $fatal(1, "sheet M mismatch at pixel %0d (y=%0d hpos=%0d):\n RTL %b\n REF %b\n XOR %b",
                       pixels, out_y, out_hp, d_vec, r_snap, d_vec ^ r_snap);
            // ---------------- directed checks (dbg[6:3] = IC46 QD..QA)
            // co_b and ex_b are the inputs of the pixel just registered
            if (co_b && d_dbg[6:3] != 0)
                $fatal(1, "IC46 at %0d with /COIN IN high", d_dbg[6:3]);
            if (d_out[7] != (d_dbg[6:3] == 0 && ex_b))
                $fatal(1, "GAME OVER %b with IC46 at %0d and EXPLO. SEL. D %b", d_out[7], d_dbg[6:3], ex_b);
            n = !d_out[6] + !d_out[5] + !d_out[4] + !d_out[3] + !d_out[2];
            if (n > 1) $fatal(1, "two /BRIDGE outputs low: %b", d_out[6:2]);
            // ---------------- +200 (p2b = {H, V, V-(4), BONUS CP})
            ex200 = p2b[0] && !p2b[1] && p2b[18:15] == 4'd0 && glyph_cell(p2b[19:11], p2b[10:2]);
            if (d_plus_n !== !(pro && ex200))
                $fatal(1, "/+200 %b at pixel %0d: H %h V %h V-(4) %b BONUS CP %b drawing %b (PRO %0d)",
                       d_plus_n, pixels, p2b[19:11], p2b[10:2], p2b[1], p2b[0],
                       glyph_cell(p2b[19:11], p2b[10:2]), PRO);
            if (ex200) would200 = would200 + 1;
            if (!d_plus_n) lit200 = lit200 + 1;
            if (p2b[0]) low200 = low200 + 1;
            // ---------------- coverage
            for (k = 0; k < 21; k = k + 1) if (d_out[k] != prev_out[k]) lit[k] = lit[k] + 1;
            prev_out = d_out;
            if (d_dbg[6:3] == prev46 + 4'd1) ups = ups + 1;
            if (d_dbg[6:3] == prev46 - 4'd1) downs = downs + 1;
            if (d_dbg[6:3] > max46 && d_dbg[6:3] < 8) max46 = d_dbg[6:3];
            prev46 = d_dbg[6:3];
            if (d_out[7] && !prev_go) gameovers = gameovers + 1;
            prev_go = d_out[7];
            if (d_dbg[2] && !prev_o18) os18 = os18 + 1;
            prev_o18 = d_dbg[2];
            // Placeholder colours (sheet C mixes them)
            if (!out_vb && out_hp < 456 && out_y < 240) begin
                pic[out_hp][out_y] = !d_plus_n ? 24'hff0000 : !d_out[17] ? 24'hffff00 : !d_out[18] ? 24'hffffff : !d_out[19] ? 24'hff2020 :
                                     !d_out[20] ? 24'h2020ff :
                                     !d_out[10] ? 24'hffffff : !d_out[9] ? 24'hff4040 : !d_out[8] ? 24'h4040ff :
                                     !d_out[13] ? 24'hffd000 : !d_out[12] ? 24'h0060ff :
                                     !d_out[6] ? 24'he0e0e0 : !d_out[5] ? 24'h0000a0 : !d_out[4] ? 24'hc0c000 :
                                     !d_out[3] ? 24'hc00000 : !d_out[2] ? 24'h4060ff :
                                     !d_out[11] ? 24'h203020 : !d_out[16] ? 24'h302020 : 24'h000000;
                if (out_hb) pic[out_hp][out_y] = ((pic[out_hp][out_y] >> 1) & 24'h7f7f7f) + 24'h303030;
            end
        end
        if (pcen && running) begin
            // ---------------- next pixel's stimulus
            mh <= ($random(seed) & 7) == 0 ? $random(seed) : mh + 5'd1;
            if (h == 9'h0a0) begin
                fc <= fc + 8'd1;
                vd <= ($random(seed) & 3) == 0 ? 5'h1f : ~(5'd1 << (($random(seed) & 32'h7fffffff) % 5));
                other_n <= ($random(seed) & 7) != 0;
            end
            if (v == 9'h1f4 && h == 9'h0a0) begin
                frames = frames + 1;
                if (frames > PIC0 && frames <= PIC0 + NPIC) write_pic(frames - PIC0);
                for (sy = 0; sy < 456; sy = sy + 1) for (sx = 0; sx < 240; sx = sx + 1) pic[sy][sx] = 0;
                extend <= ($random(seed) & 3) != 0;
                game_n <= ($random(seed) & 3) == 0;
                coin_n <= ($random(seed) & 3) == 0;
                s100c <= $random(seed);
                cnc_n <= ($random(seed) & 3) != 0;
                ext500 <= $random(seed);
                acce_d <= $random(seed);
                zero_n <= $random(seed);
                bap <= $random(seed);
            end
            // Pulses: /EX. SIGNAL CP low and EXPLO. SEL. D high for a few lines
            if (($random(seed) & 32'h7fffffff) % 8000 == 0) excp_n <= 0;
            else if (!excp_n && ($random(seed) & 1023) == 0) excp_n <= 1;
            if (($random(seed) & 32'h7fffffff) % 60000 == 0) explo <= 1;
            else if (explo && ($random(seed) & 1023) == 0) explo <= 0;
            // Sheet N stand-in: BONUS CP toggling, its own sequence
            if (($random(seed_b) & 32'h7fffffff) % 30000 == 0) bonus_cp <= ~bonus_cp;
        end
    end

    initial begin
        if (!$value$plusargs("ROM=%s",path) || !$value$plusargs("OUT=%s",outdir))
            $fatal(1,"missing ROM/OUT");
        $readmemh(path,image);
        load_glyph;
        for (k = 0; k < 21; k = k + 1) lit[k] = 0;
        repeat(4) @(negedge clk);
        for (n=0;n<8800;n=n+1) begin
            @(negedge clk); wa=n; wd=image[n]; wr=1;
        end
        @(negedge clk); wr=0;
        repeat(4) @(negedge clk);
        rst=0;
        running=1;
        wait (frames == FRAMES);
        running = 0;
        $display("PASS rescue%0s: %0d pixels over %0d frames match the pin-wired sheet M reference",
                 FAST ? " (IC18 capacitor / 1000)" : "", pixels, frames);
        $display("  rescue counter periods: %0d of 456, %0d of 454; RTL settled within %0d steps",
                 periods_456, periods_454, busy_max);
        $display("  IC46: %0d counts up, %0d down, highest %0d; GAME OVER %0d times; IC18 pulses %0d",
                 ups, downs, max46, gameovers, os18);
        $display("  output changes: /RESCUE BL %0d R %0d W %0d Y %0d, /R-L-SIDE %0d, EXT. CAR CONT %0d, /RESCUE CP %0d",
                 lit[20], lit[19], lit[18], lit[17], lit[16], lit[15], lit[14]);
        $display("  /SIG Y %0d BL %0d, /DUMMY AREA %0d W %0d R %0d BL %0d, /BRIDGE W %0d DBu %0d Y %0d R %0d Bu %0d, /L2 %0d /R2 %0d",
                 lit[13], lit[12], lit[11], lit[10], lit[9], lit[8], lit[6], lit[5], lit[4], lit[3], lit[2], lit[1], lit[0]);
        $display("  reference hazards absorbed: IC57 CK %0d, IC35 upper CK %0d, IC35 lower CK %0d, IC46 UP %0d DOWN %0d",
                 reff.ic57.fck.hazards, reff.ic35u.fck.hazards, reff.ic35l.fck.hazards,
                 reff.ic46.fup.hazards, reff.ic46.fdn.hazards);
        $display("  +200 (PRO=%0d): BONUS CP high %0d px; drawn cells in the window %0d px, /+200 low %0d px",
                 PRO, low200, would200, lit200);
        if (would200 == 0) $fatal(1, "coverage: BONUS CP never reached a lit cell of the +200 window");
        if (periods_454 == 0 || ups == 0 || downs == 0 || gameovers == 0 || os18 == 0 ||
            lit[17] == 0 || lit[13] == 0 || lit[10] == 0 || lit[6] == 0 || lit[1] == 0 || lit[16] == 0)
            $fatal(1, "coverage: a part of the circuit was not reached");
        $finish;
    end
endmodule
