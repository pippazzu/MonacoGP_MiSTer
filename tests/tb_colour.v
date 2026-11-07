// SPDX-License-Identifier: GPL-3.0-or-later
// Sheet C colour mixing. The RTL (jtmonacogp_colour.v) and the pin-wired
// reference (tests/sheet_c_reference.v) see the same random lines; the
// colour of both halves of every pixel (7M high, then low), IC2's code and
// the brightness line are compared. 7M rises at the start of a pixel and
// clocks IC79 in both; the other lines change 5 ns later. Each active-low
// line is active with probability 1/q, q drawn per pixel from 2 to 61, so
// every colour plane wins at times.
// Coverage: every IC2 code (0, 2..9), both brightness levels, a half-pixel
// change of colour (the 7M path through IC14) and IC79 holding an AREA.
// Pro board (pro/docs/trace/SHEET_M_C_PLUS200_TRACE.md): /+200 from sheet M
// is driven in every run from its own random sequence, which leaves the rest
// of the stimulus as it was; PRO selects the board in both models. Checked
// from the trace for both halves of every pixel: with PRO = 1 and /+200 low,
// IC2's code is 9 (red), red alone, at full brightness; otherwise the colour
// is that of a third copy of the RTL with pro = 0 (the original sheet). /+200
// must have been low where it changes (with PRO = 0: would change) the colour.
// Pro blue term (pro/docs/SHEETS_B_C_D_PRO_LOGIC.md): EXTEND stands for
// D-EXTEND, and BELT (D) is driven from a sequence of its own. The R8 dim
// (bdim) is compared with the reference too; it is low with PRO = 0, and
// with PRO = 1 it is high only while EXTEND is. With PRO = 1 and EXTEND low
// the colour is the original sheet's (as above); with EXTEND high the blue
// term differs from the original by design and only the reference decides.
// Where both halves are full-brightness blue with R8 on, BLUE is 8.
`timescale 1ns/1ps
module tb_colour #(parameter integer PIXELS = 400000, parameter [31:0] SEED = 32'h4d4f4e43,
                   parameter integer PRO = 0);
    reg m7 = 0;
    reg [5:1] area = 0;
    reg [3:0] house_n = 4'hf;
    reg [39:0] l = {40{1'b1}};          // the active-low and plain lines below
    reg extend = 0;
    wire other_body_n = l[0], other_tiar_n = l[1], other_car_n = l[2], road_n = l[3], tg_g_n = l[4];
    wire tg_bl_n = l[5], house_st_n = l[6], grass_area_n = l[7], grass_w_n = l[8], tunnel_ap = l[9];
    wire bridge_ap = l[10], green_belt_n = l[11], y_line_n = l[12], gravel_n = l[13], pool_n = l[14];
    wire slip_n = l[15], wall_n = l[16], side_line_n = l[17], coin_start_n = l[18], ex_gameover_n = l[19];
    wire v4d = l[20], light_n = l[21], splay_n = l[22], explo_y_n = l[23], explo_r_n = l[24];
    wire explo_area_n = l[25], player_n = l[26], player_body_n = l[27], player_tiar_n = l[28], player_bl_n = l[29];
    wire sig_bl_n = l[30], sig_y_n = l[31], dummy_area_n = l[32], dummy_bl_n = l[33], dummy_w_n = l[34];
    wire dummy_r_n = l[35], rescue_bl_n = l[36], rescue_w_n = l[37], rescue_y_n = l[38], rescue_r_n = l[39];
    wire road = ~road_n;                // sheet D's ROAD and /ROAD
    reg bridge_dbu_n = 1, bridge_bu_n = 1, bridge_y_n = 1, bridge_w_n = 1, bridge_r_n = 1, rescue_y2 = 1;
    reg plus200_n = 1;                  // sheet M (Pro)
    reg belt = 0;                       // sheet D (Pro)
    wire bdim_hi, bdim_lo, r_bdim;
    wire pro = PRO != 0;

    wire [3:0] grb_hi, grb_lo, code_hi, code_lo, red, green, blue;
    jtmonacogp_colour dut(.clk(m7),.rst(1'b0),.cen7(1'b1),
        .area(area),.other_body_n(other_body_n),.other_tiar_n(other_tiar_n),.other_car_n(other_car_n),
        .road_n(road_n),.road(road),.tg_g_n(tg_g_n),.tg_bl_n(tg_bl_n),.house_st_n(house_st_n),.grass_area_n(grass_area_n),
        .grass_w_n(grass_w_n),.house_n(house_n),.tunnel_ap(tunnel_ap),.bridge_ap(bridge_ap),
        .green_belt_n(green_belt_n),.y_line_n(y_line_n),.gravel_n(gravel_n),.pool_n(pool_n),.slip_n(slip_n),
        .wall_n(wall_n),.side_line_n(side_line_n),.extend(extend),.extend_n(~extend),
        .coin_start_n(coin_start_n),.ex_gameover_n(ex_gameover_n),.v4d(v4d),
        .light_n(light_n),.splay_n(splay_n),.explo_y_n(explo_y_n),.explo_r_n(explo_r_n),.explo_area_n(explo_area_n),
        .player_n(player_n),.player_body_n(player_body_n),.player_tiar_n(player_tiar_n),.player_bl_n(player_bl_n),
        .sig_bl_n(sig_bl_n),.sig_y_n(sig_y_n),.dummy_area_n(dummy_area_n),.dummy_bl_n(dummy_bl_n),
        .dummy_w_n(dummy_w_n),.dummy_r_n(dummy_r_n),.rescue_bl_n(rescue_bl_n),.rescue_w_n(rescue_w_n),
        .rescue_y_n(rescue_y_n),.rescue_r_n(rescue_r_n),.bridge_dbu_n(bridge_dbu_n),.bridge_bu_n(bridge_bu_n),
        .bridge_y_n(bridge_y_n),.bridge_w_n(bridge_w_n),.bridge_r_n(bridge_r_n),
        .pro(pro),.plus200_n(plus200_n),.belt(belt),.bdim_hi(bdim_hi),.bdim_lo(bdim_lo),
        .grb_hi(grb_hi),.grb_lo(grb_lo),.code_hi(code_hi),.code_lo(code_lo),.red(red),.green(green),.blue(blue));
    // The original sheet (pro = 0), for what lies under /+200
    wire [3:0] o_grb_hi, o_grb_lo, o_code_hi, o_code_lo;
    jtmonacogp_colour dut0(.clk(m7),.rst(1'b0),.cen7(1'b1),
        .area(area),.other_body_n(other_body_n),.other_tiar_n(other_tiar_n),.other_car_n(other_car_n),
        .road_n(road_n),.road(road),.tg_g_n(tg_g_n),.tg_bl_n(tg_bl_n),.house_st_n(house_st_n),.grass_area_n(grass_area_n),
        .grass_w_n(grass_w_n),.house_n(house_n),.tunnel_ap(tunnel_ap),.bridge_ap(bridge_ap),
        .green_belt_n(green_belt_n),.y_line_n(y_line_n),.gravel_n(gravel_n),.pool_n(pool_n),.slip_n(slip_n),
        .wall_n(wall_n),.side_line_n(side_line_n),.extend(extend),.extend_n(~extend),
        .coin_start_n(coin_start_n),.ex_gameover_n(ex_gameover_n),.v4d(v4d),
        .light_n(light_n),.splay_n(splay_n),.explo_y_n(explo_y_n),.explo_r_n(explo_r_n),.explo_area_n(explo_area_n),
        .player_n(player_n),.player_body_n(player_body_n),.player_tiar_n(player_tiar_n),.player_bl_n(player_bl_n),
        .sig_bl_n(sig_bl_n),.sig_y_n(sig_y_n),.dummy_area_n(dummy_area_n),.dummy_bl_n(dummy_bl_n),
        .dummy_w_n(dummy_w_n),.dummy_r_n(dummy_r_n),.rescue_bl_n(rescue_bl_n),.rescue_w_n(rescue_w_n),
        .rescue_y_n(rescue_y_n),.rescue_r_n(rescue_r_n),.bridge_dbu_n(bridge_dbu_n),.bridge_bu_n(bridge_bu_n),
        .bridge_y_n(bridge_y_n),.bridge_w_n(bridge_w_n),.bridge_r_n(bridge_r_n),
        .pro(1'b0),.plus200_n(plus200_n),.belt(belt),.bdim_hi(),.bdim_lo(),
        .grb_hi(o_grb_hi),.grb_lo(o_grb_lo),.code_hi(o_code_hi),.code_lo(o_code_lo),.red(),.green(),.blue());
    wire r_red, r_blue, r_green, r_bright;
    wire [3:0] r_code;
    sheet_c_reference reff(.m7(m7),
        .area(area),.other_body_n(other_body_n),.other_tiar_n(other_tiar_n),.other_car_n(other_car_n),
        .road_n(road_n),.road(road),.tg_g_n(tg_g_n),.tg_bl_n(tg_bl_n),.house_st_n(house_st_n),.grass_area_n(grass_area_n),
        .grass_w_n(grass_w_n),.house_n(house_n),.tunnel_ap(tunnel_ap),.bridge_ap(bridge_ap),
        .green_belt_n(green_belt_n),.y_line_n(y_line_n),.gravel_n(gravel_n),.pool_n(pool_n),.slip_n(slip_n),
        .wall_n(wall_n),.side_line_n(side_line_n),.extend(extend),.extend_n(~extend),
        .coin_start_n(coin_start_n),.ex_gameover_n(ex_gameover_n),.v4d(v4d),
        .light_n(light_n),.splay_n(splay_n),.explo_y_n(explo_y_n),.explo_r_n(explo_r_n),.explo_area_n(explo_area_n),
        .player_n(player_n),.player_body_n(player_body_n),.player_tiar_n(player_tiar_n),.player_bl_n(player_bl_n),
        .sig_bl_n(sig_bl_n),.sig_y_n(sig_y_n),.dummy_area_n(dummy_area_n),.dummy_bl_n(dummy_bl_n),
        .dummy_w_n(dummy_w_n),.dummy_r_n(dummy_r_n),.rescue_bl_n(rescue_bl_n),.rescue_w_n(rescue_w_n),
        .rescue_y_n(rescue_y_n),.rescue_r_n(rescue_r_n),.bridge_dbu_n(bridge_dbu_n),.bridge_bu_n(bridge_bu_n),
        .bridge_y_n(bridge_y_n),.bridge_w_n(bridge_w_n),.bridge_r_n(bridge_r_n),
        .pro(pro),.plus200_n(plus200_n),.belt(belt),.bdim(r_bdim),
        .red_on(r_red),.blue_on(r_blue),.green_on(r_green),.bright(r_bright),.code(r_code));

    integer seed = SEED, k, n, halves = 0, codes[0:9], dims = 0, splits = 0, areas = 0, q;
    // Sheet M stand-in for /+200, from its own sequence
    integer seed_p = SEED ^ 32'h2b323030, p200_low = 0, p200_px = 0, bdims = 0, ext_diff = 0;
    integer seed_b = SEED ^ 32'h42454c54;   // BELT, its own sequence
    task check(input [3:0] code, input [3:0] grb, input [3:0] o_code, input [3:0] o_grb,
               input bdim, input [8*2-1:0] half);
        begin
            if ({code, grb, bdim} !== {r_code, r_green, r_blue, r_red, r_bright, r_bdim})
                $fatal(1, "sheet C mismatch at pixel %0d (%0s): RTL code %0d GBR+ %b R8 %b, REF code %0d GBR+ %b R8 %b",
                       n, half, code, grb, bdim, r_code, {r_green, r_blue, r_red, r_bright}, r_bdim);
            if (bdim && !(pro && extend)) $fatal(1, "R8 on at pixel %0d (%0s) with PRO %0d, EXTEND %b", n, half, PRO, extend);
            if (bdim) bdims = bdims + 1;
            // ---------------- /+200 (Pro), from the trace
            if (pro && !plus200_n) begin
                if (code !== 4'd9 || grb !== 4'b0011)
                    $fatal(1, "+200 at pixel %0d (%0s): code %0d GBR+ %b, expected pure red at full brightness",
                           n, half, code, grb);
            end else if (pro && extend) begin
                if ({code, grb} !== {o_code, o_grb}) ext_diff = ext_diff + 1;
            end else if ({code, grb} !== {o_code, o_grb})
                $fatal(1, "pixel %0d (%0s): code %0d GBR+ %b, the original sheet gives %0d %b (PRO %0d, /+200 %b)",
                       n, half, code, grb, o_code, o_grb, PRO, plus200_n);
            if (!plus200_n) p200_low = p200_low + 1;
            // halves where /+200 changes (would change) the colour
            if (!plus200_n && {o_code, o_grb} !== {4'd9, 4'b0011}) p200_px = p200_px + 1;
            if (code == 1 || code > 9) $fatal(1, "impossible code %0d", code);
            codes[code] = codes[code] + 1;
            if (code != 0 && !grb[0]) dims = dims + 1;
            halves = halves + 1;
        end
    endtask
    initial begin
        for (k = 0; k < 10; k = k + 1) codes[k] = 0;
        for (n = 0; n < PIXELS; n = n + 1) begin
            m7 = 1;
            #5;
            // each active-low line active with probability 1/q, q from 2 to 61
            q = 2 + ($random(seed) & 32'h7fffffff) % 60;
            for (k = 0; k < 40; k = k + 1) l[k] = ($random(seed) & 32'h7fffffff) % q != 0;
            // plain (active-high) lines: half the time
            {extend, area} = $random(seed);
            {bridge_dbu_n, bridge_bu_n, bridge_y_n, bridge_w_n, bridge_r_n} = ~(5'd1 << (($random(seed) & 32'h7fffffff) % (5 + q/4)));
            house_n = ~(4'd1 << (($random(seed) & 32'h7fffffff) % (4 + q/4)));
            if (dut.q79 != 5'h1f) areas = areas + 1;
            plus200_n = ($random(seed_p) & 7) != 0;
            belt = ($random(seed_b) & 7) == 0;
            #30 check(code_hi, grb_hi, o_code_hi, o_grb_hi, bdim_hi, "hi");
            m7 = 0;
            #40 check(code_lo, grb_lo, o_code_lo, o_grb_lo, bdim_lo, "lo");
            if (bdim_hi && bdim_lo && grb_hi[2] && grb_lo[2] && grb_hi[0] && grb_lo[0] && blue !== 4'd8)
                $fatal(1, "pixel %0d: full blue with R8 gives %0d, expected 8", n, blue);
            if ({code_hi, grb_hi} != {code_lo, grb_lo}) splits = splits + 1;
            #5;
        end
        $display("PASS colour: %0d pixels (%0d halves) match the pin-wired sheet C reference", PIXELS, halves);
        $display("  IC2 codes: none %0d, blue %0d, magenta %0d, green %0d, yellow %0d, cyan %0d, white %0d, black %0d, red %0d",
                 codes[0], codes[2], codes[3], codes[4], codes[5], codes[6], codes[7], codes[8], codes[9]);
        $display("  dim halves %0d; pixels changing colour at mid-pixel (7M) %0d; pixels with an AREA held in IC79 %0d",
                 dims, splits, areas);
        $display("  /+200 (PRO=%0d): low in %0d halves, %0d of them over another colour or the dim level",
                 PRO, p200_low, p200_px);
        $display("  R8 (PRO=%0d): on in %0d halves; %0d halves in extended play differ from the original sheet",
                 PRO, bdims, ext_diff);
        if (p200_px == 0) $fatal(1, "coverage: /+200 never reached a pixel where it matters");
        if (pro && (bdims == 0 || ext_diff == 0)) $fatal(1, "coverage: the Pro blue term never acted");
        for (k = 2; k < 10; k = k + 1) if (codes[k] == 0) $fatal(1, "coverage: code %0d never won", k);
        if (codes[0] == 0 || dims == 0 || (!pro && splits == 0) || areas == 0) $fatal(1, "coverage: a part of the circuit was not reached");
        // Pro: 7M only clocks IC79, so no pixel changes colour at mid-pixel
        if (pro && splits != 0) $fatal(1, "Pro: %0d pixels changed colour at mid-pixel", splits);
        $finish;
    end
endmodule
