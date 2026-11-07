// SPDX-License-Identifier: GPL-3.0-or-later
// Sheet B road-motion counters and text. The RTL (jtmonacogp_motion.v) and
// the pin-wired reference (tests/sheet_b_reference.v) see the same stimulus
// on the real sheet E raster.
//
// - Every output and internal net is compared at the end of every pixel.
// - Directed checks, written here from the trace:
//   MH: after a load at line 1FF the next period is 480 - 2*SP clocks,
//       otherwise 456.
//   M1V, M2V: each load writes 8 (VSEL high) or 7 / 9 (IC69 Q high / low),
//       the next FF line follows 256 - load lines later, IC69 changes only
//       on the line where its counter is at FF: M1V half set on lines 20-2F,
//       cleared on 50-5F; M2V half set on A0-BF, cleared on F0-FF.
//   Text: /EX. & GAME OVER is lit only in H 0F0-0FF and /COIN & START only
//       in H 1D0-1DF, both within lines 40-BF, with the bit of PR-133 at
//       the traced address.
// Stages, each skipped when its length is 0: TEXT (three frames; the
// second and third write the four messages to PPM files), MOVE (/IN RESET
// low: the counters move a line every frame and swing between the IC69
// windows), STILL (VSEL high: the counters hold), RANDOM.
// M1V_INIT and M2V_INIT put the counters' FF lines at 3F and CF after
// reset, a few frames from the IC69 windows. The stimulus stands in for
// sheets A, D and H; it is not gameplay.
// PRO = 1: the Pro board (pro/docs/SHEETS_B_C_D_PRO_LOGIC.md). Vs/512 rises
// every fourth frame, /COIN IN is low in one frame of seven and at random
// pixels, and EXTEND, D-TIME and SLOW change at random. Further directed
// checks: /DISPLAY follows a model of IC72 written from the trace (cleared
// while /COIN IN is low, low after the IC72A-th rise of Vs/512 with /COIN IN
// high); D-EXTEND, /D-EXTEND and /D-GAME are EXTEND, /EXTEND, /GAME or D-TIME,
// NOT D-TIME, low by /DISPLAY; the MH period and VSEL use {SLOW, 0, 0, 0}
// for SP while /DISPLAY is low. With PRO = 0 the Pro inputs stay still and
// the stimulus is the one it was.
`timescale 1ns/1ps
module tb_motion #(parameter integer TEXT_FRAMES = 3, MOVE_FRAMES = 170,
                   STILL_FRAMES = 8, RANDOM_FRAMES = 0,
                   parameter [7:0] M1V_INIT = 8'hd0, M2V_INIT = 8'h40,
                   parameter integer PRO = 0, IC72A = 1);
    reg clk=0, rst=1;
    always #10.416666667 clk=~clk;                   // 48 MHz

    // PR-133 as stored in the core: the PROM bank of jtmonacogp_proms.v at
    // offset 4096, written the way JTFRAME downloads the whole image. (The
    // other 19 banks would triple the simulation time.)
    reg wr=0;
    reg [25:0] wa=0;
    reg [7:0] wd=0;
    reg [7:0] image[0:8799];
    reg [1023:0] path, outdir;
    wire [8:0] a133;
    wire [7:0] q133;
    jtmonacogp_prom #(.BASE(4096)) u_pr133(.clk(clk),.addr(a133),.q(q133),
        .wr(wr),.wr_addr(wa),.wr_data(wd));

    wire pcen, p2cen;
    wire [8:0] h,v,x,y,hp,vp;
    wire hb,vb,hs,vs;
    jtmonacogp_cen u_cen(.clk(clk),.cen14(p2cen),.cen7(pcen));
    jtmonacogp_timing u_timing(.clk(clk),.rst(rst),.pxl_cen(pcen),.h(h),.v(v),
        .hblank(hb),.vblank(vb),.hs(hs),.vs(vs),.x(x),.y(y),.hpos(hp),.vpos(vp));

    // ---------------- Stimulus (changes at the 7 MHz edge)
    reg [3:0] sp=4'd0;                               // {SP.D, SP.C, SP.B, SP.A}
    reg vs2=0, vs4=0, vs16=1;
    reg coin_in_n=1, coin_in_e1_n=1, ex_signal_n=0, game_n=1, in_reset_n=1;
    reg tunnel_bridge_n=1;
    // Pro board: Vs/512 (H), EXTEND and /EXTEND (A), D-TIME and SLOW (D)
    wire pro = PRO != 0;
    reg vs512=0, extend=0, d_time=0, slow=0;

    // ---------------- RTL
    wire [8:0] d_mh;
    wire [7:0] d_m1v, d_m2v;
    wire [5:1] d_vdec;
    wire d_mhld_n, d_m1vld_n, d_m2vld_n, d_exgo_n, d_coinst_n;
    wire d_q1, d_q2, d_q68, d_vsel, d_strobe_n, d_txt;
    wire d_display_n, d_dext, d_dext_n, d_dgame_n;
    jtmonacogp_motion #(.M1V_INIT(M1V_INIT),.M2V_INIT(M2V_INIT),.IC72A(IC72A)) dut(.clk(clk),.rst(rst),.pxl_cen(pcen),.h(h),.hs(hs),.v(v),
        .sp(sp),.vs2(vs2),.vs4(vs4),.vs16(vs16),
        .coin_in_n(coin_in_n),.coin_in_e1_n(coin_in_e1_n),.ex_signal_n(ex_signal_n),
        .game_n(game_n),.in_reset_n(in_reset_n),.tunnel_bridge_n(tunnel_bridge_n),
        .pro(pro),.vs512(vs512),.extend(extend),.extend_n(~extend),.d_time(d_time),.slow(slow),
        .display_n(d_display_n),.d_extend(d_dext),.d_extend_n(d_dext_n),.d_game_n(d_dgame_n),
        .pr133_addr(a133),.pr133_q(q133),
        .mh(d_mh),.mhld_n(d_mhld_n),.m1v(d_m1v),.m2v(d_m2v),.m1vld_n(d_m1vld_n),
        .m2vld_n(d_m2vld_n),.vdec_n(d_vdec),.ex_gameover_n(d_exgo_n),.coin_start_n(d_coinst_n),
        .q1(d_q1),.q2(d_q2),.q68(d_q68),.vsel(d_vsel),.strobe_n(d_strobe_n),.txt(d_txt));

    // ---------------- Pin-wired reference
    // The 7 MHz edge is the pixel boundary. The reference sees the reset
    // state of sheet E from time zero and no 7 MHz edge during reset, so it
    // starts where the RTL leaves reset.
    reg f7=0;
    reg [2:0] f7cnt=0;
    always @(posedge clk) begin
        if (pcen && !rst) begin f7<=1; f7cnt<=0; end
        else begin f7cnt<=f7cnt+3'd1; if (f7cnt==3'd2) f7<=0; end
    end
    wire [8:0] h_t = rst ? 9'h098 : h;
    wire [8:0] v_t = rst ? 9'h010 : v;
    wire hs_t = rst ? 1'b0 : hs;
    // H and /HS settle 5 ns after the edge, as outputs of counters clocked by
    // it. The V lines come from the sheet E counters clocked by /HS: they
    // change in the same layer as M1V and M2V, the reference's filter and
    // clock-to-output time (3 + 1 ns) after /HS.
    wire [8:0] r_h;
    wire [7:1] r_v;
    wire r_h5_n, r_h8_n, r_hs_n, r_v4_n, r_v8_n, r_vca_v8_n;
    assign #5 {r_h, r_h5_n, r_h8_n, r_hs_n} = {h_t, ~h_t[5], ~h_t[8], ~hs_t};
    assign #9 {r_v, r_v4_n, r_v8_n, r_vca_v8_n} =
              {v_t[7:1], ~v_t[4], ~v_t[8], ~(&v_t[7:0] & v_t[8])};
    // The other sheets' nets change 20 ns after the edge, after the
    // reference's counters have sampled them (3 ns after the 7M edge, 8 ns
    // after the /HS edge): every part sees the value of the pixel that ends,
    // as in the RTL.
    wire [3:0] r_sp;
    wire r_vs2, r_vs4, r_vs16, r_coin_ed_n, r_coin_e1_n, r_ex_n, r_game_n, r_inrst_n, r_tb_n;
    assign #20 {r_sp, r_vs2, r_vs4, r_vs16, r_coin_ed_n, r_coin_e1_n, r_ex_n, r_game_n,
                r_inrst_n, r_tb_n} =
               {sp, vs2, vs4, vs16, coin_in_n, coin_in_e1_n, ex_signal_n, game_n,
                in_reset_n, tunnel_bridge_n};
    wire r_vs512, r_extend, r_d_time, r_slow;
    assign #20 {r_vs512, r_extend, r_d_time, r_slow} = {vs512, extend, d_time, slow};

    wire [8:0] r_mh;
    wire [7:0] r_m1v, r_m2v;
    wire [5:1] r_vdec;
    wire r_mhld_n, r_m1vld_n, r_m2vld_n, r_exgo_n, r_coinst_n;
    wire r_q1, r_q2, r_q68, r_vsel, r_strobe_n, r_txt;
    wire r_display_n, r_dext, r_dext_n, r_dgame_n;
    sheet_b_reference #(.M1V_INIT(M1V_INIT),.M2V_INIT(M2V_INIT),.IC72A(IC72A)) reff(.b_7m(f7),.b_h(r_h),.b_h5_n(r_h5_n),.b_h8_n(r_h8_n),.b_hs_n(r_hs_n),
        .b_v(r_v),.b_v4_n(r_v4_n),.b_v8_n(r_v8_n),.b_vca_v8_n(r_vca_v8_n),
        .b_sp_a(r_sp[0]),.b_sp_b(r_sp[1]),.b_sp_c(r_sp[2]),.b_sp_d(r_sp[3]),
        .b_vs2(r_vs2),.b_vs4(r_vs4),.b_vs16(r_vs16),
        .b_coin_in_ed_n(r_coin_ed_n),.b_coin_in_e1_n(r_coin_e1_n),.b_ex_signal_n(r_ex_n),
        .b_game_n(r_game_n),.b_in_reset_n(r_inrst_n),.b_tunnel_bridge_n(r_tb_n),
        .b_pro(pro),.b_vs512(r_vs512),.b_extend(r_extend),.b_extend_n(~r_extend),
        .b_d_time(r_d_time),.b_slow(r_slow),
        .display_n(r_display_n),.d_extend(r_dext),.d_extend_n(r_dext_n),.d_game_n(r_dgame_n),
        .mh(r_mh),.mhld_n(r_mhld_n),.m1v(r_m1v),.m2v(r_m2v),.m1vld_n(r_m1vld_n),
        .m2vld_n(r_m2vld_n),.vdec_n(r_vdec),.ex_gameover_n(r_exgo_n),.coin_start_n(r_coinst_n),
        .q1(r_q1),.q2(r_q2),.q68(r_q68),.vsel(r_vsel),.strobe_n(r_strobe_n),.txt(r_txt));

    wire [44:0] d_vec = {d_mh, d_mhld_n, d_m1v, d_m2v, d_m1vld_n, d_m2vld_n, d_vdec,
                         d_exgo_n, d_coinst_n, d_q1, d_q2, d_q68, d_vsel, d_strobe_n, d_txt,
                         d_display_n, d_dext, d_dext_n, d_dgame_n};
    wire [44:0] r_vec = {r_mh, r_mhld_n, r_m1v, r_m2v, r_m1vld_n, r_m2vld_n, r_vdec,
                         r_exgo_n, r_coinst_n, r_q1, r_q2, r_q68, r_vsel, r_strobe_n, r_txt,
                         r_display_n, r_dext, r_dext_n, r_dgame_n};

    // ---------------- Stimulus generator and checks
    localparam integer S_TEXT = 0, S_MOVE = 1, S_STILL = 2, S_RANDOM = 3, S_DONE = 4;
    integer seed = 32'h4d4f4e42;
    integer stage = S_TEXT, stage_frames = 0, frames = 0;
    function integer stage_len(input integer st);
        case (st)
            S_TEXT: stage_len = TEXT_FRAMES;
            S_MOVE: stage_len = MOVE_FRAMES;
            S_STILL: stage_len = STILL_FRAMES;
            S_RANDOM: stage_len = RANDOM_FRAMES;
            default: stage_len = 1;
        endcase
    endfunction
    integer pixels = 0, lines = 0;
    reg running = 0, frame_ev = 0, line_end = 0;
    reg [7:0] vsdiv = 0;
    integer k, n;
    // Pro IC72, from the trace (reading IC72A): Q of each half
    reg e72a = 0, e72b = 0, vs512_m = 0;
    integer seed_p = 32'h50524f42, disp_falls = 0, disp_rises = 0, disp_px = 0, slow_loads = 0;
    reg disp_prev = 1;
    // Expected values from the trace
    reg [3:0] spx;                                         // IC29, set below
    reg vsel_exp, ck_old, ck_new, a_new;
    wire [7:0] tbyte = image[4096 + {coin_in_n, h[8], h[3], v[6:1]}];
    wire q68_exp = !v[8] && v[7:0] >= 8'h40 && v[7:0] <= 8'hbf;
    wire msg_win  = !h[8] && h[7:4] == 4'hf && q68_exp && vs16 && (!ex_signal_n || !coin_in_e1_n);
    wire coin_win =  h[8] && h[7:4] == 4'hd && q68_exp && game_n;
    // MH
    integer mh_last = -1, mh_expect = 0, mh_loads = 0, mh_sp_loads = 0, mh_double = 0;
    integer sp_seen = 0, sp_line_last = -1;
    integer period_n [0:511];
    // M1V (index 0) and M2V (index 1)
    integer abs_line = 0;
    integer ff_pred [0:1], ff_last_v [0:1], ld_n [0:1][7:9];
    integer sets [0:1], clears [0:1], ff_min [0:1], ff_max [0:1], first_set [0:1];
    integer race_lines [0:1], race_flips [0:1];
    reg [1:0] q_prev, load_pend;
    reg [3:0] ld_pend [0:1];
    integer ex_lit = 0, coin_lit = 0, ex_lit_frame = 0, coin_lit_frame = 0;
    // Text images of the TEXT stage, written rotated so that they read upright:
    // V 0BF..040 left to right, H down (0F0-0FF, then 1D0-1DF).
    reg pic [0:1][0:31][0:127];
    integer pic_n = 0, fp, sx, sy;

    function inrange(input [7:0] vv, input [7:0] lo, input [7:0] hi);
        inrange = vv >= lo && vv <= hi;
    endfunction

    task write_pic(input integer which, input [8*16-1:0] name);
        begin
            fp = $fopen($sformatf("%0s/%0s.ppm", outdir, name), "w");
            if (!fp) $fatal(1, "cannot open %0s", name);
            $fwrite(fp, "P3\n%0d %0d\n255\n", 128*4, 36*4);
            for (sy = 0; sy < 36*4; sy = sy + 1)
                for (sx = 0; sx < 128*4; sx = sx + 1) begin
                    if (sy/4 >= 16 && sy/4 < 20) $fwrite(fp, "40 40 40\n");
                    else if (sy/4 < 16 && pic[which][sy/4][sx/4]) $fwrite(fp, "255 255 255\n");
                    else if (sy/4 >= 20 && pic[which][sy/4 - 4][sx/4]) $fwrite(fp, "255 220 0\n");
                    else $fwrite(fp, "0 0 0\n");
                end
            $fclose(fp);
        end
    endtask

    always @(posedge clk) if (pcen && running) begin
        pixels = pixels + 1;
        // ---------------- Pro IC72 model, for the pixel that ends here
        if (pro) begin
            if (!coin_in_n) begin
                e72a = 0; e72b = 0;
            end else if (vs512 && !vs512_m) begin
                ck_old = IC72A == 1 ? ~e72a : e72a;
                a_new  = IC72A == 0 ? e72a : ~e72a;
                ck_new = IC72A == 1 ? ~a_new : a_new;
                e72a = a_new;
                if (!ck_old && ck_new) e72b = coin_in_n;
            end
            vs512_m = vs512;
        end
        spx = pro && e72b ? {slow, 3'b000} : sp;
        vsel_exp = in_reset_n & ~(vs4 & vs2 & tunnel_bridge_n & ~(spx[3] & spx[2]));
        if (d_display_n !== !e72b) $fatal(1, "/DISPLAY %b, expected %b (pixel %0d)", d_display_n, !e72b, pixels);
        if ({d_dext, d_dext_n, d_dgame_n} !== (e72b ? {d_time, ~d_time, 1'b0} : {extend, ~extend, game_n}))
            $fatal(1, "IC70 outputs %b, /DISPLAY %b (pixel %0d)", {d_dext, d_dext_n, d_dgame_n}, d_display_n, pixels);
        if (!d_display_n) disp_px = disp_px + 1;
        if (!d_display_n && disp_prev) disp_falls = disp_falls + 1;
        if (d_display_n && !disp_prev) disp_rises = disp_rises + 1;
        disp_prev = d_display_n;
        // ---------------- compare the pixel that ends here
        if (^d_vec === 1'bx || ^r_vec === 1'bx)
            $fatal(1, "unknown net at pixel %0d (h=%h v=%h):\n RTL %b\n REF %b", pixels, h, v, d_vec, r_vec);
        if (d_vec !== r_vec)
            $fatal(1, "sheet B mismatch at pixel %0d (h=%h v=%h):\n RTL %b\n REF %b\n XOR %b",
                   pixels, h, v, d_vec, r_vec, d_vec ^ r_vec);
        // ---------------- text
        if (frames >= 1) begin
            if (!d_exgo_n !== (msg_win && tbyte[h[2:0]]))
                $fatal(1, "/EX. & GAME OVER at h=%h v=%h: %b", h, v, d_exgo_n);
            if (!d_coinst_n !== (coin_win && tbyte[h[2:0]]))
                $fatal(1, "/COIN & START at h=%h v=%h: %b", h, v, d_coinst_n);
            if (d_q68 !== q68_exp) $fatal(1, "IC68 at v=%h: %b", v, d_q68);
        end
        if (!d_exgo_n) begin ex_lit = ex_lit + 1; ex_lit_frame = ex_lit_frame + 1; end
        if (!d_coinst_n) begin coin_lit = coin_lit + 1; coin_lit_frame = coin_lit_frame + 1; end
        if (stage == S_TEXT && stage_frames >= 1 && q68_exp && !hb) begin
            if (!h[8] && h[7:4] == 4'hf) pic[stage_frames-1][h[3:0]][8'hbf - v[7:0]] = !d_exgo_n;
            if (h[8] && h[7:4] == 4'hd) pic[stage_frames-1][16 + h[3:0]][8'hbf - v[7:0]] = !d_coinst_n;
        end
        // ---------------- MH period
        if (d_mh == 9'h1ff) begin
            if (mh_last >= 0) begin
                if (pixels - mh_last != mh_expect)
                    $fatal(1, "MH period %0d at h=%h v=%h, expected %0d", pixels - mh_last, h, v, mh_expect);
                period_n[pixels - mh_last] = period_n[pixels - mh_last] + 1;
            end
            mh_last = pixels;
            mh_loads = mh_loads + 1;
            if (v == 9'h1ff) begin
                mh_expect = 480 - 2*spx;
                if (pro && e72b) slow_loads = slow_loads + 1;
                mh_sp_loads = mh_sp_loads + 1;
                sp_seen = sp_seen | (1 << sp);
                if (sp_line_last == lines) mh_double = mh_double + 1;
                sp_line_last = lines;
            end else mh_expect = 456;
        end
        // ---------------- M1V, M2V at the end of each line (/HS rises next)
        line_end = hb && h[7:0] == 8'hdf;
        for (k = 0; k < 2; k = k + 1) if (load_pend[k]) begin
            // The pixel after a load: the counter holds the load value
            if ((k ? d_m2v : d_m1v) !== {4'd0, ld_pend[k]})
                $fatal(1, "M%0dV after load: %h, expected %h", k+1, k ? d_m2v : d_m1v, ld_pend[k]);
            load_pend[k] = 0;
        end
        if (line_end) begin
            lines = lines + 1;
            for (k = 0; k < 2; k = k + 1) begin
                if (!v[8] && (k ? d_m2v : d_m1v) == 8'hff) begin
                    // R1 (R2) low on this line: a load at its end
                    if ((k ? d_m2vld_n : d_m1vld_n) !== 1'b0) $fatal(1, "R%0d not low at FF", k+1);
                    if (ff_pred[k] >= 0 && ff_pred[k] != abs_line)
                        $fatal(1, "M%0dV FF on active line %0d (v=%h), expected %0d", k+1, abs_line, v, ff_pred[k]);
                    // IC69 window
                    n = k ? (inrange(v[7:0], 8'ha0, 8'hbf) ? 1 : inrange(v[7:0], 8'hf0, 8'hff) ? 0 : q_prev[k])
                          : (inrange(v[7:0], 8'h20, 8'h2f) ? 1 : inrange(v[7:0], 8'h50, 8'h5f) ? 0 : q_prev[k]);
                    if ((k ? d_q2 : d_q1) !== n[0])
                        $fatal(1, "IC69 M%0dV half on line %h: %b, expected %b", k+1, v, k ? d_q2 : d_q1, n[0]);
                    if (n[0] && !q_prev[k]) sets[k] = sets[k] + 1;
                    if (!n[0] && q_prev[k]) begin
                        clears[k] = clears[k] + 1;
                        // A full turn: the swing is measured from here
                        if (first_set[k] < 0 && stage == S_MOVE && sets[k] > 0) first_set[k] = frames;
                    end
                    // Lines after which, on the board, R1 (R2) is still low while
                    // the V lines and the decoder change: a set (M1V lines 1F
                    // and 3F, M2V line 9F) or a clear (M1V 4F, M2V EF) that
                    // the settled model does not make (docs/SHEET_B_LOGIC.md)
                    n = k ? (v[7:0] == 8'h9f ? 1 : v[7:0] == 8'hef ? 0 : -1)
                          : (v[7:0] == 8'h1f || v[7:0] == 8'h3f ? 1 : v[7:0] == 8'h4f ? 0 : -1);
                    if (n >= 0) begin
                        race_lines[k] = race_lines[k] + 1;
                        if (q_prev[k] != n[0]) race_flips[k] = race_flips[k] + 1;
                    end
                    n = k ? (inrange(v[7:0], 8'ha0, 8'hbf) ? 1 : inrange(v[7:0], 8'hf0, 8'hff) ? 0 : q_prev[k])
                          : (inrange(v[7:0], 8'h20, 8'h2f) ? 1 : inrange(v[7:0], 8'h50, 8'h5f) ? 0 : q_prev[k]);
                    ld_pend[k] = vsel_exp ? 4'd8 : n[0] ? 4'd7 : 4'd9;
                    if (d_vsel !== vsel_exp) $fatal(1, "VSEL %b, expected %b", d_vsel, vsel_exp);
                    load_pend[k] = 1;
                    ld_n[k][ld_pend[k]] = ld_n[k][ld_pend[k]] + 1;
                    ff_pred[k] = abs_line + 256 - ld_pend[k];
                    if (stage == S_MOVE && first_set[k] >= 0 && first_set[k] != frames) begin
                        if (v[7:0] < ff_min[k]) ff_min[k] = v[7:0];
                        if (v[7:0] > ff_max[k]) ff_max[k] = v[7:0];
                    end
                    ff_last_v[k] = v[7:0];
                end else if ((k ? d_q2 : d_q1) !== q_prev[k])
                    $fatal(1, "IC69 M%0dV half changed on line %h without a load", k+1, v);
                q_prev[k] = k ? d_q2 : d_q1;
            end
            if (!v[8]) abs_line = abs_line + 1;
        end
        // ---------------- next pixel's stimulus
        frame_ev = v == 9'h1f4 && h == 9'h0a0;
        if (frame_ev) begin
            frames = frames + 1;
            stage_frames = stage_frames + 1;
            if (stage == S_TEXT && stage_frames == 2) write_pic(0, "motion-text-1");
            if (stage == S_TEXT && stage_frames == 3) write_pic(1, "motion-text-2");
            ex_lit_frame = 0; coin_lit_frame = 0;
            // Next stage, skipping empty ones, and its settings
            while (stage != S_DONE && stage_frames >= stage_len(stage)) begin
                stage = stage + 1;
                stage_frames = 0;
                case (stage)
                    S_MOVE: in_reset_n <= 0;
                    S_STILL: begin in_reset_n <= 1; vs2 <= 0; end
                    S_RANDOM: in_reset_n <= 1;
                    default: ;
                endcase
            end
            if (stage == S_TEXT && stage_frames == 1) begin
                // /COIN IN high: GAME OVER, DEPOSIT COIN
                coin_in_n <= 1; coin_in_e1_n <= 1; ex_signal_n <= 0; game_n <= 1; vs16 <= 1;
            end
            if (stage == S_TEXT && stage_frames == 2) begin
                // /COIN IN low: EXTENDED PLAY, START
                coin_in_n <= 0; coin_in_e1_n <= 0;
            end
            if (stage == S_MOVE || stage == S_RANDOM) begin
                // Text inputs change once a frame
                vs16 <= $random(seed) % 3 != 0;
                coin_in_n <= $random(seed) % 2;
                coin_in_e1_n <= $random(seed) % 2;
                ex_signal_n <= $random(seed) % 2;
                game_n <= $random(seed) % 3 != 0;
            end
            if (stage == S_RANDOM) begin
                vsdiv = vsdiv + 8'd1;
                vs2 <= vsdiv[0]; vs4 <= vsdiv[1];
                tunnel_bridge_n <= $random(seed) % 4 != 0;
                in_reset_n <= $random(seed) % 10 != 0;
            end
            if (pro) begin
                // Pro: Vs/512 rises every fourth frame; /COIN IN low in one
                // frame of seven (replacing the coin stimulus above)
                vs512 <= frames[1];
                if (stage != S_TEXT) coin_in_n <= frames % 7 != 3;
                extend <= $random(seed_p) % 2;
                d_time <= $random(seed_p) % 2;
                slow <= $random(seed_p) % 2;
            end
        end
        if (pro && stage != S_TEXT) begin
            // Pro inputs at random pixels; SLOW often on line 1FF
            if (($random(seed_p) & 32'h7fffffff) % (v == 9'h1ff ? 300 : 30000) == 0) slow <= ~slow;
            if (($random(seed_p) & 32'h7fffffff) % 30000 == 0) d_time <= ~d_time;
            if (($random(seed_p) & 32'h7fffffff) % 30000 == 0) extend <= ~extend;
            if (($random(seed_p) & 32'h7fffffff) % 4000000 == 0) coin_in_n <= 0;
        end
        // SP changes at random pixels, often on line 1FF where MH loads it
        if (stage != S_TEXT && ($random(seed) & 32'h7fffffff) % (v == 9'h1ff ? 400 : 30000) == 0)
            sp <= $random(seed);
        if (stage == S_RANDOM) begin
            // Mid-frame changes of the inputs of VSEL and of the text gates
            if (($random(seed) & 32'h7fffffff) % 40000 == 0) tunnel_bridge_n <= ~tunnel_bridge_n;
            if (($random(seed) & 32'h7fffffff) % 60000 == 0) in_reset_n <= ~in_reset_n;
            if (($random(seed) & 32'h7fffffff) % 60000 == 0) vs2 <= ~vs2;
            if (($random(seed) & 32'h7fffffff) % 60000 == 0) vs4 <= ~vs4;
            // (Pro: /COIN IN from the Pro stimulus instead, so that IC72 runs)
            if (($random(seed) & 32'h7fffffff) % 30000 == 0) coin_in_n <= pro ? coin_in_n : ~coin_in_n;
            if (($random(seed) & 32'h7fffffff) % 30000 == 0) game_n <= ~game_n;
        end
    end

    initial begin
        if (!$value$plusargs("ROM=%s",path) || !$value$plusargs("OUT=%s",outdir))
            $fatal(1,"missing ROM/OUT");
        $readmemh(path,image);
        for (k = 0; k < 512; k = k + 1) period_n[k] = 0;
        for (k = 0; k < 2; k = k + 1) begin
            ff_pred[k] = -1; ff_last_v[k] = -1; sets[k] = 0; clears[k] = 0;
            ff_min[k] = 999; ff_max[k] = 0; first_set[k] = -1;
            race_lines[k] = 0; race_flips[k] = 0;
            ld_n[k][7] = 0; ld_n[k][8] = 0; ld_n[k][9] = 0;
            ld_pend[k] = 0;
        end
        q_prev = 0; load_pend = 0;
        repeat(4) @(negedge clk);
        for (n=0;n<8800;n=n+1) begin
            @(negedge clk); wa=n; wd=image[n]; wr=1;
        end
        @(negedge clk); wr=0;
        repeat(4) @(negedge clk);
        for (n=0;n<512;n=n+1)
            if (u_pr133.mem[n] !== image[4096+n]) $fatal(1,"PR-133 download failed at %0d",n);
        rst=0;
        running=1;
        wait (stage == S_DONE);
        running = 0;
        $display("PASS motion: %0d pixels over %0d frames match the pin-wired sheet B reference",
                 pixels, frames);
        $display("  MH: %0d loads, %0d of them at line 1FF (SP values seen %b, %0d lines with two), periods 456 x%0d, others:",
                 mh_loads, mh_sp_loads, sp_seen[15:0], mh_double, period_n[456]);
        for (k = 450; k <= 480; k = k + 2) if (k != 456 && period_n[k] > 0) $display("    %0d x%0d", k, period_n[k]);
        for (k = 0; k < 2; k = k + 1)
            $display("  M%0dV: loads of 7/8/9: %0d/%0d/%0d; IC69 set %0d, cleared %0d; MOVE swing after the first turn (frame %0d): FF on lines %h..%h",
                     k+1, ld_n[k][7], ld_n[k][8], ld_n[k][9], sets[k], clears[k], first_set[k], ff_min[k], ff_max[k]);
        $display("  loads on board-race lines (M1V 1F, 3F, 4F; M2V 9F, EF): M1V %0d (%0d where the board may flip IC69), M2V %0d (%0d)",
                 race_lines[0], race_flips[0], race_lines[1], race_flips[1]);
        $display("  text pixels lit: /EX. & GAME OVER %0d, /COIN & START %0d",
                 ex_lit, coin_lit);
        $display("  reference hazards absorbed (pulses under 3 ns): IC69 /PR %0d /CL %0d (M1V), /PR %0d /CL %0d (M2V); IC68 %0d/%0d; IC57 CK %0d; 161 clocks %0d",
                 reff.ic69b.fpr.hazards, reff.ic69b.fcl.hazards, reff.ic69a.fpr.hazards, reff.ic69a.fcl.hazards,
                 reff.ic68.fs.hazards, reff.ic68.fr.hazards, reff.ic57.fck.hazards,
                 reff.ic118.fck.hazards + reff.ic103.fck.hazards + reff.ic85.fck.hazards +
                 reff.ic76.fck.hazards + reff.ic91.fck.hazards + reff.ic77.fck.hazards);
        // Coverage the run must reach
        if (frames >= 100 && sp_seen[15:0] != 16'hffff) $fatal(1, "not every SP value was loaded at line 1FF");
        for (k = 0; k < 2; k = k + 1) begin
            if (ld_n[k][8] == 0) $fatal(1, "M%0dV: never loaded 8", k+1);
            if (MOVE_FRAMES > 0 && (ld_n[k][7] == 0 || ld_n[k][9] == 0)) $fatal(1, "M%0dV: never loaded 7 or 9", k+1);
            if (MOVE_FRAMES > 0 && (sets[k] < 2 || clears[k] < 2)) $fatal(1, "M%0dV: IC69 half did not swing twice", k+1);
            if (RANDOM_FRAMES > 0 && sets[k] + clears[k] == 0) $fatal(1, "M%0dV: IC69 half never changed", k+1);
        end
        // The settled model turns on the first line of each window it enters
        if (MOVE_FRAMES > 0 && (ff_min[0] != 8'h2f || ff_max[0] != 8'h50)) $fatal(1, "M1V swing not 2F..50");
        if (MOVE_FRAMES > 0 && (ff_min[1] != 8'hbf || ff_max[1] != 8'hf0)) $fatal(1, "M2V swing not BF..F0");
        if (ex_lit == 0 || coin_lit == 0) $fatal(1, "a text output never lit");
        if (pro) begin
            $display("  Pro (IC72 reading %0d): /DISPLAY fell %0d times, rose %0d times, low for %0d pixels; %0d MH loads at line 1FF took {SLOW, 0, 0, 0}",
                     IC72A, disp_falls, disp_rises, disp_px, slow_loads);
            if (IC72A != 0 && (disp_falls < 2 || disp_rises < 2 || slow_loads < 2))
                $fatal(1, "coverage: the display timer did not run");
            if (IC72A == 0 && disp_falls != 0) $fatal(1, "IC72a as drawn: /DISPLAY fell");
        end
        $finish;
    end
endmodule
