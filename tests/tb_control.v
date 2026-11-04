// SPDX-License-Identifier: GPL-3.0-or-later
// Sheet F control logic. The RTL (jtmonacogp_control.v) and the pin-wired
// reference (tests/sheet_f_reference.v) see the same pseudo-random stimulus,
// which changes only at pixel boundaries, on the real sheet E raster.
//
// - IC19, IC40, PL-H-ST and PL-V-ST are compared at the end of every pixel.
//   The RTL takes the two targets from the control logic one pixel late, so
//   the PL comparison is skipped in a pixel whose target the reference has
//   just changed (counted and reported).
// - Every other output and the internal state of the RTL, registered one
//   pixel late, are compared with the reference's values at the end of the
//   previous pixel.
// - The RTL must have settled before each of its edge-3 registers: a
//   further step would have changed nothing.
// - Directed checks, written here from the trace: PL-H-ST and PL-V-ST
//   positions after /COIN & TEST, the one-shot widths in pixels.
//
// FAST = 1 shortens the one-shot capacitors by 1000 and takes the Vs/n
// lines from the line counter instead of the frame counter, so that the
// slow parts of the circuit cycle many times; it must reach every path.
// FAST = 0 runs the circuit as drawn. Both start with a directed sequence:
// pedal floored from rest in low gear, change up, four frames of slip with
// the handle turned, one pool, each followed by enough frames for the
// pulses to run out, one crash and the return to the start position.
// FRAMES frames of random play follow.
// The stimulus stands in for sheets A, D, G, H and M; it is not gameplay.
`timescale 1ns/1ps
module tb_control #(parameter FAST = 0, parameter integer FRAMES = 30,
                   // Directed stages run: 0 accelerate, 1 slip, 2 pool, 3 crash
                   parameter integer FIRST_STAGE = 0, parameter integer LAST_STAGE = 2);
    reg clk=0, rst=1;
    always #10.416666667 clk=~clk;                   // 48 MHz

    wire pcen, p2cen;
    wire [8:0] h,v,x,y,hp,vp;
    wire hb,vb,hs,vs;
    jtmonacogp_cen u_cen(.clk(clk),.cen14(p2cen),.cen7(pcen));
    jtmonacogp_timing u_timing(.clk(clk),.rst(rst),.pxl_cen(pcen),.h(h),.v(v),
        .hblank(hb),.vblank(vb),.hs(hs),.vs(vs),.x(x),.y(y),.hpos(hp),.vpos(vp));

    // One-shot widths. The reference computes them from R and C.
    localparam real CS = FAST ? 1.0e-3 : 1.0;
    function integer px(input real c_pf);
        px = $rtoi(0.28*47.0*c_pf*CS*(1.0+0.7/47.0)*7.1525e-3 + 0.5);
    endfunction
    localparam integer N1  = FAST ? 449  : 448985;
    localparam integer N43A = FAST ? 955  : 955288;
    localparam integer N43B = FAST ? 1433 : 1432932;
    localparam integer N49 = FAST ? 2102 : 2101633;

    // ---------------- Stimulus (changes at the 7 MHz edge)
    reg coin_test_n=0, game_n=1, extend=0, pts8000=0;
    reg other_body_n=1, slip_n=1, pool2_n=1, road=1, tunnel_n=1, ext500_n=1;
    reg rescue_n=1, bridge_n=1, ext_car_cont=0;
    reg sp_down_n=1, sp_down=0, score_st_n=1, acc1_st_n=1, acc1_pulse_n=1, player=0;
    reg acce_a=1, acce_b=1, han_l=0, han_r=0, shift_no=0, shift_nc=1, ic27_3=1;
    reg [7:0] vsdiv=0;
    wire vs2=vsdiv[0], vs8=vsdiv[2], vs16=vsdiv[3], vs32=vsdiv[4], vs64=vsdiv[5];

    // ---------------- RTL
    wire d_plh, d_plv, d_shift, d_slipzone_n, d_nonroad_n, d_acce_st, d_score_cp_n;
    wire d_s_acc1_n, d_acc1_n, d_splay_a_n, d_splay_b_n, d_sp_irreg_n, d_home_n;
    wire d_explo, d_explo_n, d_busy;
    wire [3:0] d_acce, d_sel;
    wire [7:0] d_ic19, d_ic40, d_vpos;
    wire [6:0] d_hpos;
    wire [36:0] d_dbg, d_live;
    jtmonacogp_control #(.IC1A_PIXELS(N1),.IC1B_PIXELS(N1),.IC43A_PIXELS(N43A),
        .IC43B_PIXELS(N43B),.IC49_PIXELS(N49)) dut(
        .clk(clk),.rst(rst),.pxl_cen(pcen),
        .h4(h[4]),.h5(h[5]),.h6(h[6]),.h8(h[8]),.hs(hs),.v(v[7:4]),
        .coin_test_n(coin_test_n),.game_n(game_n),.extend(extend),.pts8000(pts8000),
        .vs2(vs2),.vs8(vs8),.vs16(vs16),.vs32(vs32),.vs64(vs64),.other_body_n(other_body_n),
        .slip_n(slip_n),.pool2_n(pool2_n),.road(road),.tunnel_n(tunnel_n),.ext500_n(ext500_n),
        .rescue_n(rescue_n),.bridge_n(bridge_n),.ext_car_cont(ext_car_cont),
        .sp_down_n(sp_down_n),.sp_down(sp_down),.score_st_n(score_st_n),.acc1_st_n(acc1_st_n),
        .acc1_pulse_n(acc1_pulse_n),.player(player),
        .acce_cont_a(acce_a),.acce_cont_b(acce_b),.han_l_cp(han_l),.han_r_cp(han_r),
        .shift_no(shift_no),.shift_nc(shift_nc),.ic27_3(ic27_3),
        .pl_h_st(d_plh),.pl_v_st(d_plv),.shift(d_shift),.slipzone_n(d_slipzone_n),
        .nonroad_slip_n(d_nonroad_n),.acce_st(d_acce_st),.acce(d_acce),.score_cp_n(d_score_cp_n),
        .s_acc1_n(d_s_acc1_n),.acc1_n(d_acc1_n),.splay_a_n(d_splay_a_n),.splay_b_n(d_splay_b_n),
        .sp_irreg_n(d_sp_irreg_n),.home_pos_n(d_home_n),.explo_sel(d_sel),.explo_st(d_explo),
        .explo_st_n(d_explo_n),.ic19_q(d_ic19),.ic40_q(d_ic40),.hpos_t(d_hpos),.vpos_t(d_vpos),
        .dbg(d_dbg),.dbg_live(d_live),.busy(d_busy));

    // ---------------- Pin-wired reference
    // The 7 MHz edge is the pixel boundary. Nets from other sheets settle 5 ns
    // after it, as outputs of counters clocked by that edge would.
    reg f7=0;
    reg [2:0] f7cnt=0;
    always @(posedge clk) begin
        if (pcen) begin f7<=1; f7cnt<=0; end
        else begin f7cnt<=f7cnt+3'd1; if (f7cnt==3'd2) f7<=0; end
    end
    wire r_h4, r_h5, r_h6, r_h8, r_hs_n, r_v4, r_v5_n, r_v6, r_v6_n, r_v7, r_v7_n;
    wire r_coin_test_n, r_game_n, r_extend, r_8000, r_vs2, r_vs8, r_vs16, r_vs32, r_vs64;
    wire r_other_body_n, r_slip_n, r_pool2_n, r_road, r_tunnel_n, r_ext500_n;
    wire r_rescue_n, r_bridge_n, r_ext_car_cont, r_sp_down_n, r_sp_down, r_score_st_n;
    wire r_acc1_st_n, r_acc1_pulse_n, r_player, r_acce_a, r_acce_b, r_han_l, r_han_r;
    wire r_shift_no, r_shift_nc, r_ic27_3;
    assign #5 {r_h4, r_h5, r_h6, r_h8, r_hs_n, r_v4, r_v5_n, r_v6, r_v6_n, r_v7, r_v7_n} =
              {h[4], h[5], h[6], h[8], ~hs, v[4], ~v[5], v[6], ~v[6], v[7], ~v[7]};
    assign #5 {r_coin_test_n, r_game_n, r_extend, r_8000, r_vs2, r_vs8, r_vs16, r_vs32, r_vs64} =
              {coin_test_n, game_n, extend, pts8000, vs2, vs8, vs16, vs32, vs64};
    assign #5 {r_other_body_n, r_slip_n, r_pool2_n, r_road, r_tunnel_n, r_ext500_n,
               r_rescue_n, r_bridge_n, r_ext_car_cont} =
              {other_body_n, slip_n, pool2_n, road, tunnel_n, ext500_n,
               rescue_n, bridge_n, ext_car_cont};
    assign #5 {r_sp_down_n, r_sp_down, r_score_st_n, r_acc1_st_n, r_acc1_pulse_n, r_player} =
              {sp_down_n, sp_down, score_st_n, acc1_st_n, acc1_pulse_n, player};
    assign #5 {r_acce_a, r_acce_b, r_han_l, r_han_r, r_shift_no, r_shift_nc, r_ic27_3} =
              {acce_a, acce_b, han_l, han_r, shift_no, shift_nc, ic27_3};

    wire r_plh, r_plv, r_shift, r_slipzone_n, r_nonroad_n, r_acce_st, r_score_cp_n;
    wire r_s_acc1_n, r_acc1_n, r_splay_a_n, r_splay_b_n, r_sp_irreg_n, r_home_n;
    wire r_explo, r_explo_n;
    wire [3:0] r_acce, r_s_acce, r_sel;
    wire [7:0] r_ic19, r_ic40, r_vpos;
    wire [6:0] r_hpos;
    wire [36:0] r_state;
    sheet_f_reference #(.C1A_PF(4.7e6*CS),.C1B_PF(4.7e6*CS),.C43A_PF(1.0e7*CS),
        .C43B_PF(1.5e7*CS),.C49_PF(2.2e7*CS)) reff(
        .f_7mhz(f7),.f_h4(r_h4),.f_h5(r_h5),.f_h6(r_h6),.f_h8(r_h8),.f_hs_n(r_hs_n),
        .f_v4(r_v4),.f_v5_n(r_v5_n),.f_v6(r_v6),.f_v6_n(r_v6_n),.f_v7(r_v7),.f_v7_n(r_v7_n),
        .f_coin_test_n(r_coin_test_n),.f_game_n(r_game_n),.f_extend(r_extend),.f_8000(r_8000),
        .f_vs2(r_vs2),.f_vs8(r_vs8),.f_vs16(r_vs16),.f_vs32(r_vs32),.f_vs64(r_vs64),
        .f_other_body_n(r_other_body_n),.f_slip_n(r_slip_n),.f_pool2_n(r_pool2_n),
        .f_road(r_road),.f_tunnel_n(r_tunnel_n),.f_ext500_n(r_ext500_n),
        .f_rescue_n(r_rescue_n),.f_bridge_n(r_bridge_n),.f_ext_car_cont(r_ext_car_cont),
        .f_sp_down_n(r_sp_down_n),.f_sp_down(r_sp_down),.f_score_st_n(r_score_st_n),
        .f_acc1_st_n(r_acc1_st_n),.f_acc1_pulse_n(r_acc1_pulse_n),.f_player(r_player),
        .f_acce_a(r_acce_a),.f_acce_b(r_acce_b),.f_han_l(r_han_l),.f_han_r(r_han_r),
        .f_shift_no(r_shift_no),.f_shift_nc(r_shift_nc),.f_ic27_3(r_ic27_3),
        .pl_h_st(r_plh),.pl_v_st(r_plv),.shift(r_shift),.slipzone_n(r_slipzone_n),
        .nonroad_slip_n(r_nonroad_n),.acce_st(r_acce_st),.acce(r_acce),.s_acce(r_s_acce),
        .score_cp_n(r_score_cp_n),.s_acc1_n(r_s_acc1_n),.acc1_n(r_acc1_n),
        .splay_a_n(r_splay_a_n),.splay_b_n(r_splay_b_n),.sp_irreg_n(r_sp_irreg_n),
        .home_pos_n(r_home_n),.explo_sel(r_sel),.explo_st(r_explo),.explo_st_n(r_explo_n),
        .ic19_q(r_ic19),.ic40_q(r_ic40),.hpos_t(r_hpos),.vpos_t(r_vpos),.state(r_state));

    // Lagged comparison vectors: outputs, targets, internal state
    wire [83:0] d_lag = {d_shift, d_slipzone_n, d_nonroad_n, d_acce_st, d_acce, d_acce,
        d_score_cp_n, d_s_acc1_n, d_acc1_n, d_splay_a_n, d_splay_b_n, d_sp_irreg_n, d_home_n,
        d_sel, d_explo, d_explo_n, d_hpos, d_vpos, d_dbg};
    wire [83:0] r_lag = {r_shift, r_slipzone_n, r_nonroad_n, r_acce_st, r_acce, r_s_acce,
        r_score_cp_n, r_s_acc1_n, r_acc1_n, r_splay_a_n, r_splay_b_n, r_sp_irreg_n, r_home_n,
        r_sel, r_explo, r_explo_n, r_hpos, r_vpos, r_state};

    // ---------------- Stimulus generator
    integer seed = 32'h4d4f4e46;
    integer lines=0, frames=0, pixel=0, rnd;
    integer stage = FIRST_STAGE, stage_frames = 0, crash_frame = -1;
    reg homed = 0;
    reg home_seen = 0;   // /HOME POS. low since the last frame event
    // Frames after the last slip and the pool crossing: long enough for the
    // longest pulse of each stage (IC43 slip 8.4 frames, IC49 17.6 frames).
    localparam integer SLIP_WAIT = FAST ? 3 : 14, POOL_WAIT = FAST ? 3 : 24;
    // In the slip stage the handle is turned right in frame 1 and left in
    // this frame only, so that each IC1 half's last pulse runs out (3.7
    // frames) before the other half clears it, while IC43 still holds A low.
    localparam integer HAN_L_FRAME = FAST ? 3 : 7;
    integer han_left=0, han_gap=0, lever=0, coin_left=0, game_left=0, pulse_left=0, calm_left=0;
    integer px0=200, py0=120, sx0=0, sy0=0, rx0=0, ry0=0;
    reg running=0, han_side=0, en_player=1, en_slip=0, en_pool=0, en_road=0, en_rescue=0;
    reg en_bridge=0, en_body=0, vs_q=0, gear=0, calm=0, frame_ev=0, slow=0;
    reg [1:0] pedal=0;
    // Pedal positions 0 (released) to 3, as {ACCE. CONT. A, B}. The order is
    // inferred from IC7's B word (IC22.3, IC2.11, IC16.6), which grows
    // 0001, 1011, 1101, 1111 along it in high gear; adjacent positions differ
    // in one line, as on a two-track encoder. Not read from the drawing.
    function [1:0] pedal_ab(input [1:0] n);
        case (n) 2'd0: pedal_ab = 2'b11; 2'd1: pedal_ab = 2'b01;
                 2'd2: pedal_ab = 2'b00; default: pedal_ab = 2'b10; endcase
    endfunction
    function inbox(input integer xx, yy, x0, y0, w, hh);
        inbox = xx >= x0 && xx < x0+w && yy >= y0 && yy < y0+hh;
    endfunction
    function integer od(input integer fast_odds, full_odds);
        od = FAST ? fast_odds : full_odds;
    endfunction
    function flip(input cur, input integer odds);   // changes with probability 1/odds
        flip = ($random(seed) % odds) == 0 ? ~cur : cur;
    endfunction

    always @(posedge clk) if (pcen && running) begin
        pixel = pixel + 1;
        // Line events, in mid-line. Nothing here changes on the 7 MHz edge
        // that steps V: where two nets reach a gate through paths of
        // different length, the reference would show the hazard that a
        // simultaneous change leaves (for example V5 and Vs/32 at IC66), and
        // the settled RTL would not. Sheet H, which drives the Vs/n lines, is
        // not traced yet.
        frame_ev = vs && v[2:0] == 3'd4 && h == 9'h0a0;   // end of the first VS line
        // Slow nets (game state from sheets A, D, G and M, the pedal, the
        // lever, /COIN & TEST, /GAME) change on a slow tick: every line in
        // FAST mode, where the Vs/n lines also step every line, and every
        // frame otherwise, with odds set per mode.
        slow = FAST ? h == 9'h0a0 : frame_ev;
        if (h == 9'h0a0) begin
            lines = lines + 1;
            if (FAST) vsdiv <= vsdiv + 8'd1;
            score_st_n <= flip(score_st_n, 8);
        end
        if (slow && stage == 4) begin
            extend       <= flip(extend, od(40, 8));
            pts8000      <= flip(pts8000, od(50, 10));
            ext500_n     <= flip(ext500_n, od(50, 10));
            ext_car_cont <= flip(ext_car_cont, od(50, 10));
            tunnel_n     <= flip(tunnel_n, od(60, 12));
            sp_down      <= flip(sp_down, od(30, 8));
            sp_down_n    <= flip(sp_down_n, od(30, 8));
            acc1_st_n    <= flip(acc1_st_n, od(40, 8));
            ic27_3       <= ic27_3 ? ($random(seed) % od(400, 40) != 0) : ($random(seed) % 3 == 0);
            if ($random(seed) % od(24, 12) == 0) begin
                // One position at a time, pressed more often than released
                if ($random(seed) % 3 != 0) begin if (pedal != 2'd3) pedal = pedal + 2'd1; end
                else if (pedal != 2'd0) pedal = pedal - 2'd1;
                {acce_a, acce_b} <= pedal_ab(pedal);
            end
            if (lever == 0 && $random(seed) % od(1500, 60) == 0) begin
                lever = 1 + ($random(seed) & 3);
                {shift_no, shift_nc} <= 2'b11;
            end
            // /COIN & TEST and /GAME pulses
            if (coin_left > 0) begin coin_left = coin_left - 1; if (coin_left == 0) coin_test_n <= 1; end
            else if ($random(seed) % od(2500, 150) == 0) begin coin_left = 1; coin_test_n <= 0; end
            if (game_left > 0) begin game_left = game_left - 1; if (game_left == 0) game_n <= 0; end
            else if ($random(seed) % od(3000, 200) == 0) begin game_left = 2; game_n <= 1; end
        end
        // Shift lever: both lines open for a few ticks in transit
        if (slow && lever > 0) begin
            lever = lever - 1;
            if (lever == 0) begin
                gear = ~gear;
                {shift_no, shift_nc} <= gear ? 2'b10 : 2'b01;   // high gear closes NC
            end
        end
        if (vs && !vs_q) frames = frames + 1;
        // Frame events. A calm stretch of frames, without collision objects
        // or /ACC1. PULSE, lets the car return to its start position after a
        // crash and the accelerator count climb.
        if (frame_ev) begin
            if (!FAST) vsdiv <= vsdiv + 8'd1;
            if (calm_left > 0) calm_left = calm_left - 1;
            else if ($random(seed) % 2 == 0) calm_left = FAST ? 4 + ($random(seed) & 15)
                                                              : 40 + ($random(seed) & 63);
            calm = calm_left > 0 || stage != 4;
            en_player = stage != 4 || ($random(seed) % 10) != 0;
            px0 = 120 + ($random(seed) & 127);
            py0 = 40 + ($random(seed) & 127);
            en_slip = ($random(seed) % 3) == 0;
            en_pool = ($random(seed) % 3) == 0;
            // A directed start before the random play. Floor the pedal in
            // low gear, change up at ACCE. = 6, and once ACCE. D is high
            // (IC43's /CLR) cross a slip zone, then one pool, each followed
            // by enough frames for the pulses to run out; then one crash.
            if (stage != 4) begin
                en_slip = 0; en_pool = 0;
                if (comparing) stage_frames = stage_frames + 1;
                case (stage)
                    0: begin
                        pedal = 2'd3;
                        {acce_a, acce_b} <= pedal_ab(pedal);
                        if (!gear && lever == 0 && r_acce >= 4'd6) begin
                            lever = 2;
                            {shift_no, shift_nc} <= 2'b11;
                        end
                        if (r_acce[3]) begin stage = 1; stage_frames = 0; end
                    end
                    1: begin
                        // Four slip frames; the handle turns (IC1 triggers
                        // only in a slip) as set by HAN_L_FRAME
                        en_slip = stage_frames <= 4;
                        if (stage_frames == 4 + SLIP_WAIT) begin
                            stage = LAST_STAGE >= 2 ? 2 : 4; stage_frames = 0;
                        end
                    end
                    2: begin
                        en_pool = stage_frames == 1;
                        if (stage_frames == 1 + POOL_WAIT) begin
                            stage = LAST_STAGE >= 3 ? 3 : 4; stage_frames = 0;
                        end
                    end
                    default: begin
                        // Pedal floored until the car has left its start
                        // position (/HOME POS. high for a whole frame), then
                        // one collision with another body over the car, with
                        // EXTEND high (explosion), and calm until /HOME POS.
                        // has ended the crash and IC39 the explosion (or
                        // 200 frames)
                        if (crash_frame < 0) begin
                            pedal = 2'd3;
                            {acce_a, acce_b} <= pedal_ab(pedal);
                            if (stage_frames > 1 && !home_seen) begin
                                crash_frame = stage_frames;
                                extend <= 1;
                            end
                        end else begin
                            if (home_seen) homed = 1;
                            if ((homed && !r_explo) || stage_frames == crash_frame + 200) begin
                                stage = 4; stage_frames = 0;
                            end
                        end
                    end
                endcase
            end
            en_road = !calm && ($random(seed) % 4) == 0;
            en_rescue = !calm && ($random(seed) % 5) == 0;
            en_bridge = !calm && ($random(seed) % 5) == 0;
            en_body = !calm && ($random(seed) % 5) == 0;
            if (stage == 3 && stage_frames == crash_frame) en_body = 1;
            sx0 = px0 - 20 + ($random(seed) & 31);
            sy0 = py0 - 20 + ($random(seed) & 31);
            rx0 = px0 - 10 + ($random(seed) & 31);
            ry0 = py0 - 10 + ($random(seed) & 31);
            if (stage != 4) begin   // zones and the body over the car
                sx0 = px0 - 4; sy0 = py0 - 4; rx0 = px0 - 4; ry0 = py0 - 4;
            end
            home_seen = 0;
        end
        vs_q = vs;
        if (!r_home_n) home_seen = 1;
        // Pixel-level nets on the raster: the car, slip and pool zones,
        // collision objects
        player   <= en_player && inbox(x, y, px0, py0, 32, 16);
        slip_n   <= !(en_slip && inbox(x, y, sx0, sy0, 40, 24));
        pool2_n  <= !(en_pool && inbox(x, y, sx0 + 16, sy0 + 8, 40, 24));
        road     <= !(en_road && inbox(x, y, rx0, ry0, 24, 24));
        rescue_n <= !(en_rescue && inbox(x, y, rx0 + 8, ry0, 8, 8));
        bridge_n <= !(en_bridge && inbox(x, y, rx0, ry0 + 8, 8, 8));
        other_body_n <= !(en_body && inbox(x, y, rx0 + 4, ry0 + 4, 12, 12)) &&
                        (calm || $random(seed) % 20000 != 0);
        // /ACC1. PULSE: short low pulses
        if (pulse_left > 0) begin pulse_left = pulse_left - 1; if (pulse_left == 0) acc1_pulse_n <= 1; end
        else if (!calm && $random(seed) % 30000 == 0) begin pulse_left = 1 + ($random(seed) & 7); acc1_pulse_n <= 0; end
        // Handle pulses: one line at a time, never both
        if (han_left > 0) begin
            han_left = han_left - 1;
            if (han_left == 0) begin han_l <= 0; han_r <= 0; han_gap = 1 + ($random(seed) & 255); end
        end else if (han_gap > 0) han_gap = han_gap - 1;
        else if (stage == 1 ? (stage_frames == 1 || stage_frames == HAN_L_FRAME) &&
                              $random(seed) % 300 == 0
                            : $random(seed) % 2000 == 0) begin
            han_left = 20 + ($random(seed) & 2047);
            han_side = stage == 1 ? stage_frames == 1 : $random(seed) & 1;
            if (han_side) han_r <= 1; else han_l <= 1;
        end
    end

    // ---------------- Checks
    integer compared=0, plh_masked=0, plv_masked=0, settle_max=0, step_n=0, last_change=0;
    integer plh_seen=0, plv_seen=0, explo_rises=0, explo_falls=0, home_falls=0, crash_sets=0;
    integer m1a_rises=0, m1b_rises=0, m43a_rises=0, m43b_rises=0, l27d_sets=0, l27a_sets=0;
    integer qd15_px=0, acce_max=0, c5_steps=0, sel12=0, irreg_low=0;
    reg [83:0] r_lag_q;
    reg [7:0] r_ic19_q;
    reg comparing=0, directed=0, have_prev=0;
    reg [2:0] tcen;
    reg [36:0] live_q, dbg_q;
    reg [6:0] r_hpos_q;
    reg [7:0] r_vpos_q;
    wire exp_plh = h == 9'h150;
    // IC40 is cleared on lines 0xE0-0xEF and counts each start of HS, so it
    // holds 0x0F from the HS of line 0xFE to the HS of line 0xFF.
    wire exp_plv = (v == 9'h0fe && hs) || (v == 9'h0ff && !hs);

    always @(posedge clk) tcen <= rst ? 3'd0 : {tcen[1:0], pcen};
    // Settling: record the last step that changed the RTL state, and require
    // that none was left to do before each edge-3 register.
    always @(negedge clk) if (!rst && running) begin
        if (tcen[2]) step_n = 0;             // just after edge 3: the first step comes next
        else begin
            step_n = step_n + 1;
            if (d_live !== live_q) last_change = step_n;
        end
        live_q = d_live;
        if (tcen[1] && comparing) begin       // next edge is edge 3
            if (d_busy) $fatal(1,"RTL not settled before edge 3 at pixel %0d (h=%h v=%h)",pixel,h,v);
            if (last_change > settle_max) settle_max = last_change;
            last_change = 0;
        end
    end

    always @(negedge clk) if (pcen && !rst && running) begin
        if (comparing || directed) begin
            if ((^{d_ic19,d_ic40,d_plh,d_plv}) === 1'bx || (^{r_ic19,r_ic40,r_plh,r_plv}) === 1'bx)
                $fatal(1,"unknown position net at pixel %0d",pixel);
            if ({d_ic19,d_ic40} !== {r_ic19,r_ic40})
                $fatal(1,"position counters at pixel %0d (h=%h v=%h): RTL IC19 %h IC40 %h, reference %h %h",
                       pixel,h,v,d_ic19,d_ic40,r_ic19,r_ic40);
            if (d_hpos != r_hpos) plh_masked = plh_masked + 1;
            else if (d_plh !== r_plh)
                $fatal(1,"PL-H-ST at pixel %0d (h=%h v=%h): RTL %b reference %b",pixel,h,v,d_plh,r_plh);
            if (d_vpos != r_vpos) plv_masked = plv_masked + 1;
            else if (d_plv !== r_plv)
                $fatal(1,"PL-V-ST at pixel %0d (h=%h v=%h): RTL %b reference %b",pixel,h,v,d_plv,r_plv);
            if (have_prev) begin
                if ((^d_lag) === 1'bx || (^r_lag_q) === 1'bx)
                    $fatal(1,"unknown net at pixel %0d:\n RTL %b\n REF %b",pixel,d_lag,r_lag_q);
                if (d_lag !== r_lag_q)
                    $fatal(1,"sheet F mismatch for pixel %0d (h=%h v=%h):\n RTL %b\n REF %b\n XOR %b",
                           pixel-1,h,v,d_lag,r_lag_q,d_lag^r_lag_q);
            end
            compared = compared + 1;
        end
        if (directed) begin
            if (d_plh !== exp_plh) $fatal(1,"PL-H-ST at h=%h v=%h: %b, expected %b",h,v,d_plh,exp_plh);
            if (d_plv !== exp_plv) $fatal(1,"PL-V-ST at h=%h v=%h: %b, expected %b",h,v,d_plv,exp_plv);
        end
        if (comparing) begin
            if (r_plh) plh_seen = plh_seen + 1;
            if (r_plv) plv_seen = plv_seen + 1;
            // Activity, from the reference state {.., explo 9, l27a 8, l27b 7, l27d 6,
            // l32 5, q1a 4, q1b 3, q43a 2, q43b 1, q49 0}
            if (r_state[9] && !r_lag_q[9]) explo_rises = explo_rises + 1;
            if (!r_state[9] && r_lag_q[9]) explo_falls = explo_falls + 1;
            if (r_state[7] && !r_lag_q[7]) crash_sets = crash_sets + 1;
            if (r_state[8] && !r_lag_q[8]) l27a_sets = l27a_sets + 1;
            if (r_state[6] && !r_lag_q[6]) l27d_sets = l27d_sets + 1;
            if (r_state[4] && !r_lag_q[4]) m1a_rises = m1a_rises + 1;
            if (r_state[3] && !r_lag_q[3]) m1b_rises = m1b_rises + 1;
            if (r_state[2] && !r_lag_q[2]) m43a_rises = m43a_rises + 1;
            if (r_state[1] && !r_lag_q[1]) m43b_rises = m43b_rises + 1;
            if (!r_home_n && r_lag_q[58]) home_falls = home_falls + 1;
            if (r_state[36:33] > acce_max) acce_max = r_state[36:33];
            if (r_state[36]) qd15_px = qd15_px + 1;
            if (r_state[17:14] != r_lag_q[17:14]) c5_steps = c5_steps + 1;
            if (r_sel == 4'd12) sel12 = sel12 + 1;
            if (!r_sp_irreg_n) irreg_low = irreg_low + 1;
        end
        r_lag_q = r_lag;
        have_prev = comparing || directed;
    end

    // One-shot pulse widths in the reference. The pulses are retriggerable,
    // so each is timed from its last trigger to its end, for the pulses that
    // run out (not those that /CLR ends: IC15 QD for IC43 and IC49).
    wire sample = pcen && comparing;
    tb_control_width w43a(.clk(clk),.sample(sample),.pixel(pixel),.q(r_state[2]),
        .clr_n(r_state[36]),.trigs(reff.ic43a.trigs));
    tb_control_width w43b(.clk(clk),.sample(sample),.pixel(pixel),.q(r_state[1]),
        .clr_n(r_state[36]),.trigs(reff.ic43b.trigs));
    tb_control_width w49(.clk(clk),.sample(sample),.pixel(pixel),.q(r_state[0]),
        .clr_n(r_state[36]),.trigs(reff.ic49.trigs));
    tb_control_width w1a(.clk(clk),.sample(sample),.pixel(pixel),.q(r_state[4]),
        .clr_n(!r_state[3]),.trigs(reff.ic1a.trigs));
    tb_control_width w1b(.clk(clk),.sample(sample),.pixel(pixel),.q(r_state[3]),
        .clr_n(!r_state[4]),.trigs(reff.ic1b.trigs));
    task check_width(input [8*5-1:0] name, input integer ends, wmin, wmax, n);
        begin
            $display("  %0s: %0d pulses ran out, %0d to %0d px after their last trigger (width %0d)",
                     name,ends,wmin,wmax,n);
            if (ends > 0 && (wmin != n || wmax != n)) $fatal(1,"%0s pulse width",name);
        end
    endtask

    initial begin
        if (reff.ic1a.pixels != N1 || reff.ic1b.pixels != N1 || reff.ic43a.pixels != N43A ||
            reff.ic43b.pixels != N43B || reff.ic49.pixels != N49 || px(1.0e7) != N43A)
            $fatal(1,"one-shot widths: reference %0d %0d %0d %0d %0d, RTL %0d %0d %0d %0d",
                   reff.ic1a.pixels,reff.ic1b.pixels,reff.ic43a.pixels,reff.ic43b.pixels,
                   reff.ic49.pixels,N1,N43A,N43B,N49);
        repeat(8) @(negedge clk);
        rst=0;
        running=1;
        // Power-up frames: /COIN & TEST low loads the position counters,
        // /GAME high clears IC15 and IC5. IC19 is cleared at H 0x0D0-0x0DF
        // and counts the pixels after, so it reaches 0x70 at H 0x150.
        @(posedge vs); @(posedge vs);
        directed=1;
        @(posedge vs);
        directed=0;
        $display("PASS control: directed PL-H-ST at h=0x150 and PL-V-ST from line 0xFE (HS) after /COIN & TEST, one frame");
        @(negedge clk); while (!(pcen && h == 9'h1df)) @(negedge clk);
        coin_test_n <= 1; game_n <= 0;
        comparing=1;
        // The directed start (at most 500 frames), then FRAMES frames of
        // random play.
        while (stage != 4 && frames < 500) @(posedge vs);
        if (stage != 4) $fatal(1,"directed start unfinished after %0d frames (stage %0d)",frames,stage);
        $display("  directed start finished at frame %0d",frames);
        $fflush;
        repeat(FRAMES) @(posedge vs);
        comparing=0;
        $display("PASS control: %0d settled pixels over %0d frames match the pin-wired sheet F reference (FAST=%0d)",
                 compared,frames,FAST);
        $display("  RTL settled within %0d of its 5-6 steps per pixel; PL-H-ST skipped in %0d pixels, PL-V-ST in %0d (target changing)",
                 settle_max,plh_masked,plv_masked);
        $display("  activity: PL-H-ST %0d px, PL-V-ST %0d px, crash latch %0d, EXPLO.ST %0d/%0d, /HOME POS %0d, IC27 latch 1 %0d, latch 4 %0d",
                 plh_seen,plv_seen,crash_sets,explo_rises,explo_falls,home_falls,l27a_sets,l27d_sets);
        $display("  IC1 %0d/%0d, IC43 slip %0d pool %0d rises; IC15 max %0d (QD high %0d px); IC5 steps %0d; SEL=12 %0d px; /SP.IRREG low %0d px",
                 m1a_rises,m1b_rises,m43a_rises,m43b_rises,acce_max,qd15_px,c5_steps,sel12,irreg_low);
        check_width("IC43A",w43a.ends,w43a.wmin,w43a.wmax,N43A);
        check_width("IC43B",w43b.ends,w43b.wmin,w43b.wmax,N43B);
        check_width("IC49",w49.ends,w49.wmin,w49.wmax,N49);
        check_width("IC1A",w1a.ends,w1a.wmin,w1a.wmax,N1);
        check_width("IC1B",w1b.ends,w1b.wmin,w1b.wmax,N1);
        $display("  reference hazards absorbed (pulses under 3 ns): IC15 %0d/%0d IC25 %0d/%0d IC24 %0d/%0d IC36 %0d/%0d IC35 %0d/%0d IC5 %0d IC39 %0d IC33 %0d IC27.1 %0d",
                 reff.ic15.fup.hazards,reff.ic15.fdn.hazards,reff.ic25.fup.hazards,reff.ic25.fdn.hazards,
                 reff.ic24.fup.hazards,reff.ic24.fdn.hazards,reff.ic36.fup.hazards,reff.ic36.fdn.hazards,
                 reff.ic35.fup.hazards,reff.ic35.fdn.hazards,reff.ic5.u1.fcp.hazards,
                 reff.ic39.u1.fcp.hazards,reff.ic33.fck.hazards,reff.cut27.u.hazards);
        $display("  one-shot input hazards (A/B/CLR): IC1 %0d/%0d/%0d %0d/%0d/%0d IC43 %0d/%0d/%0d %0d/%0d/%0d IC49 %0d/%0d/%0d; C3 %0d C17 %0d",
                 reff.ic1a.fa.hazards,reff.ic1a.fb.hazards,reff.ic1a.fc.hazards,
                 reff.ic1b.fa.hazards,reff.ic1b.fb.hazards,reff.ic1b.fc.hazards,
                 reff.ic43a.fa.hazards,reff.ic43a.fb.hazards,reff.ic43a.fc.hazards,
                 reff.ic43b.fa.hazards,reff.ic43b.fb.hazards,reff.ic43b.fc.hazards,
                 reff.ic49.fa.hazards,reff.ic49.fb.hazards,reff.ic49.fc.hazards,
                 reff.c3.hazards,reff.c17.hazards);
        // Each directed stage that ran must have reached its part of the circuit.
        if (FIRST_STAGE <= 0 && (l27d_sets == 0 || acce_max < 8))
            $fatal(1,"accelerate stage: IC27 latch 4 or ACCE. D never set");
        if (FIRST_STAGE <= 1 && LAST_STAGE >= 1 &&
            (m43a_rises == 0 || w43a.ends == 0 || w1a.ends == 0 || w1b.ends == 0))
            $fatal(1,"slip stage: an IC43 slip or IC1 pulse never ran out");
        if (FIRST_STAGE <= 2 && LAST_STAGE >= 2 && (m43b_rises == 0 || w43b.ends + w49.ends == 0))
            $fatal(1,"pool stage: no IC43 pool or IC49 pulse ran out");
        if (LAST_STAGE >= 3 && (crash_sets == 0 || explo_rises == 0 || explo_falls == 0 || home_falls == 0))
            $fatal(1,"crash stage: crash, explosion or return to the start position missing");
        if (c5_steps == 0) $fatal(1,"IC5 score clock never stepped");
        $finish;
    end
endmodule

// Width of one reference one-shot: pixels from its last trigger to the end
// of a pulse that runs out while /CLR is high.
module tb_control_width(input clk, sample, input integer pixel, input q, clr_n,
                        input integer trigs);
    integer last=-1, wmin=-1, wmax=-1, ends=0, trigs_q=0;
    reg q_q=0;
    always @(negedge clk) if (sample) begin
        if (trigs != trigs_q) last = pixel;
        trigs_q = trigs;
        if (!q && q_q && clr_n && last >= 0) begin
            if (wmin < 0 || pixel - last < wmin) wmin = pixel - last;
            if (pixel - last > wmax) wmax = pixel - last;
            ends = ends + 1;
        end
        q_q = q;
    end
endmodule
