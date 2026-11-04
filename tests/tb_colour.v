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
`timescale 1ns/1ps
module tb_colour #(parameter integer PIXELS = 400000, parameter [31:0] SEED = 32'h4d4f4e43);
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
        .grb_hi(grb_hi),.grb_lo(grb_lo),.code_hi(code_hi),.code_lo(code_lo),.red(red),.green(green),.blue(blue));
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
        .red_on(r_red),.blue_on(r_blue),.green_on(r_green),.bright(r_bright),.code(r_code));

    integer seed = SEED, k, n, halves = 0, codes[0:9], dims = 0, splits = 0, areas = 0, q;
    task check(input [3:0] code, input [3:0] grb, input [8*2-1:0] half);
        begin
            if ({code, grb} !== {r_code, r_green, r_blue, r_red, r_bright})
                $fatal(1, "sheet C mismatch at pixel %0d (%0s): RTL code %0d GBR+ %b, REF code %0d GBR+ %b",
                       n, half, code, grb, r_code, {r_green, r_blue, r_red, r_bright});
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
            #30 check(code_hi, grb_hi, "hi");
            m7 = 0;
            #40 check(code_lo, grb_lo, "lo");
            if ({code_hi, grb_hi} != {code_lo, grb_lo}) splits = splits + 1;
            #5;
        end
        $display("PASS colour: %0d pixels (%0d halves) match the pin-wired sheet C reference", PIXELS, halves);
        $display("  IC2 codes: none %0d, blue %0d, magenta %0d, green %0d, yellow %0d, cyan %0d, white %0d, black %0d, red %0d",
                 codes[0], codes[2], codes[3], codes[4], codes[5], codes[6], codes[7], codes[8], codes[9]);
        $display("  dim halves %0d; pixels changing colour at mid-pixel (7M) %0d; pixels with an AREA held in IC79 %0d",
                 dims, splits, areas);
        for (k = 2; k < 10; k = k + 1) if (codes[k] == 0) $fatal(1, "coverage: code %0d never won", k);
        if (codes[0] == 0 || dims == 0 || splits == 0 || areas == 0) $fatal(1, "coverage: a part of the circuit was not reached");
        $finish;
    end
endmodule
