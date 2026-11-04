// SPDX-License-Identifier: GPL-3.0-or-later
// Sheet G headlight, explosion and splash paths. The RTL
// (jtmonacogp_effects.v) and the pin-wired reference
// (tests/sheet_g_effects_reference.v) see the same counters and inputs; their
// five outputs and the internal EQ, W and splash-window nets are compared at
// every pixel enable, once the latches have been set from both power-up
// states (after the first frame).
// The counters follow jtmonacogp_player's model: HC counts 7 MHz pixels after
// PL-H-ST and stops at 0xA0, VC counts ends of HS after PL-V-ST and stops at
// 0x80, both stepping one host clock after the pixel enable; PL-H-ST and
// PL-V-ST move to random positions each frame. HWIN and VWIN are the player
// windows (HC 0x80..0x9F with /COIN IN low, VC 0x30..0x4F). The sheet F
// inputs change at random pixels: mostly once a frame, sometimes within a
// line.
// Coverage: the headlight switched on and off by the comparators, /S1 forcing
// it off, explosion pixels in yellow and in red, splash pixels from both
// /SPLAY A pages, the splash window in both states.
`timescale 1ns/1ps
module tb_effects #(parameter integer FRAMES = 40, parameter [31:0] SEED = 32'h47454646);
    reg clk = 0, rst = 1;
    always #10.416666667 clk = ~clk;                 // 48 MHz
    wire pcen, p2cen;
    jtmonacogp_cen u_cen(.clk(clk),.cen14(p2cen),.cen7(pcen));

    // PROM image
    reg [7:0] image[0:8799];
    reg [1023:0] path;
    initial begin
        if (!$value$plusargs("ROM=%s", path)) $fatal(1, "missing +ROM");
        $readmemh(path, image);
    end

    // Raster: 456 pixels a line, 264 lines a frame, HS for pixels 0..31.
    integer h = 0, v = 0, frame = 0;
    integer plh = 100, plv = 60, seed = SEED;
    reg hs = 0, plh_st = 0, plv_st = 0, hs_l = 0, plh_l = 0, plv_l = 0;
    reg [7:0] hc_q = 8'ha0, vc_q = 8'h80;
    wire [7:0] hc = plh_st ? 8'd0 : hc_q;
    wire [7:0] vc = plv_st ? 8'd0 : vc_q;
    reg coin_n = 0, vwin_q = 0;
    wire hwin = ~(coin_n | hc[5] | hc[6] | ~hc[7]);
    wire vwin = ~(~(~vc[6] & vc[5] & vc[4])) | (~(vc[6] & vc[4]) & vwin_q);
    reg [1:0] cen_sr = 0;

    // Sheet F and player-path inputs
    reg ic66_3 = 0, acc1_n = 1, tunnel_n = 0, explo_st = 0, splay_a_n = 1, splay_b = 0;
    reg [3:0] explo_sel = 0;
    wire explo_st_n = ~explo_st;

    // RTL with registered PROM reads
    wire [8:0] a125, a126, a131;
    reg  [7:0] q125, q126, q131;
    always @(posedge clk) begin
        q125 <= image[a125];
        q126 <= image[512 + a126];
        q131 <= image[3072 + a131];
    end
    wire light_n, explo_r_n, explo_y_n, explo_area_n, splay_n, eq, w, swin;
    jtmonacogp_effects dut(.clk(clk),.rst(rst),.pxl_cen(pcen),.hc(hc),.vc(vc),.hwin(hwin),.vwin(vwin),
        .ic66_3(ic66_3),.acc1_n(acc1_n),.tunnel_n(tunnel_n),.explo_st(explo_st),.explo_st_n(explo_st_n),
        .explo_sel(explo_sel),.splay_a_n(splay_a_n),.splay_b(splay_b),
        .pr125_addr(a125),.pr126_addr(a126),.pr131_addr(a131),.pr125_q(q125),.pr126_q(q126),.pr131_q(q131),
        .light_n(light_n),.explo_r_n(explo_r_n),.explo_y_n(explo_y_n),.explo_area_n(explo_area_n),
        .splay_n(splay_n),.eq(eq),.w(w),.splash_win(swin));
    wire r_light_n, r_explo_r_n, r_explo_y_n, r_explo_area_n, r_splay_n, r_eq, r_w, r_swin;
    sheet_g_effects_reference reff(.hc(hc),.vc(vc),.hwin(hwin),.vwin(vwin),.ic66_3(ic66_3),
        .acc1_n(acc1_n),.tunnel_n(tunnel_n),.explo_st(explo_st),.explo_st_n(explo_st_n),
        .explo_sel(explo_sel),.splay_a_n(splay_a_n),.splay_b(splay_b),
        .light_n(r_light_n),.explo_r_n(r_explo_r_n),.explo_y_n(r_explo_y_n),
        .explo_area_n(r_explo_area_n),.splay_n(r_splay_n),.eq(r_eq),.w(r_w),.splash_win(r_swin));

    function integer rnd(input integer n);
        rnd = ($random(seed) & 32'h7fffffff) % n;
    endfunction

    integer pixels = 0, light_on = 0, light_px = 0, light_offs = 0, s1_offs = 0;
    integer ex_y = 0, ex_r = 0, sp_a0 = 0, sp_a1 = 0, swin_hi = 0, swin_lo = 0;
    reg l_prev = 1;
    // Compare at every pixel enable: the nets have settled since edge 3.
    always @(posedge clk) if (!rst && pcen && frame >= 1) begin
        if ({light_n, explo_r_n, explo_y_n, explo_area_n, splay_n, w, swin} !==
            {r_light_n, r_explo_r_n, r_explo_y_n, r_explo_area_n, r_splay_n, r_w, r_swin})
            $fatal(1, "mismatch frame %0d line %0d pixel %0d (HC %h VC %h): RTL L R Y A S W win %b, REF %b",
                frame, v, h, hc, vc,
                {light_n, explo_r_n, explo_y_n, explo_area_n, splay_n, w, swin},
                {r_light_n, r_explo_r_n, r_explo_y_n, r_explo_area_n, r_splay_n, r_w, r_swin});
        if (eq !== r_eq) $fatal(1, "EQ mismatch frame %0d line %0d pixel %0d", frame, v, h);
        pixels = pixels + 1;
        if (!light_n) light_px = light_px + 1;
        if (l_prev && !light_n) light_on = light_on + 1;
        // /S1 low holds the light off through a start match
        if (eq && w && !ic66_3) s1_offs = s1_offs + 1;
        if (!l_prev && light_n) light_offs = light_offs + 1;
        l_prev = light_n;
        if (!explo_y_n) ex_y = ex_y + 1;
        if (!explo_r_n) ex_r = ex_r + 1;
        if (!splay_n && !splay_a_n) sp_a0 = sp_a0 + 1;
        if (!splay_n && splay_a_n) sp_a1 = sp_a1 + 1;
        if (swin) swin_hi = swin_hi + 1; else swin_lo = swin_lo + 1;
    end

    // Raster and counters (the player module's model)
    always @(posedge clk) begin
        cen_sr <= {cen_sr[0], pcen};
        vwin_q <= vwin;
        if (pcen) begin
            hs_l <= hs; plh_l <= plh_st; plv_l <= plv_st;
        end
        if (cen_sr[0]) begin
            if (plh_st || plh_l) hc_q <= 0;
            else if (!(hc_q[5] && hc_q[7])) hc_q <= hc_q + 8'd1;
            if (plv_st || plv_l) vc_q <= 0;
            else if (hs_l && !hs && !vc_q[7]) vc_q <= vc_q + 8'd1;
        end
    end

    // Stimulus, 5 ns after each pixel enable
    task new_frame;
        begin
            plh = rnd(300);
            plv = rnd(200);
            // Mostly a driving state; sometimes the accident state (light
            // forced off), out of the tunnel or with /COIN IN high
            tunnel_n = rnd(3) == 0;
            acc1_n = rnd(6) != 0;
            ic66_3 = acc1_n && rnd(8) != 0;
            coin_n = rnd(10) == 0;
            // EXPLO.SEL D blanks the explosion: low in most explosion frames
            explo_st = rnd(2) == 0;
            explo_sel = !explo_st ? 4'd0 : rnd(4) == 0 ? rnd(16) : rnd(8);
            splay_b = rnd(3) == 0;
            splay_a_n = rnd(2);
        end
    endtask
    initial begin
        repeat (4) @(negedge clk);
        rst = 0;
        // First frame: the accident state, so that both latch 3 models set
        ic66_3 = 0;
        while (frame < FRAMES) begin
            @(posedge clk);
            while (!pcen) @(posedge clk);
            #5;
            plh_st = h == plh;
            plv_st = v == plv;
            hs = h < 32;
            // An occasional change within a frame
            if (frame >= 1 && rnd(5000) == 0) begin
                case (rnd(6))
                    0: tunnel_n = ~tunnel_n;
                    1: ic66_3 = ~ic66_3;
                    2: splay_b = ~splay_b;
                    3: splay_a_n = ~splay_a_n;
                    4: explo_sel = explo_sel + 4'd1;
                    5: coin_n = ~coin_n;
                endcase
            end
            h = h + 1;
            if (h == 456) begin
                h = 0; v = v + 1;
                if (v == 264) begin
                    v = 0; frame = frame + 1;
                    if (frame >= 1) new_frame;
                end
            end
        end
        $display("PASS effects: %0d pixels over %0d frames match the pin-wired sheet G reference", pixels, FRAMES);
        $display("  headlight: %0d lit pixels, %0d switch-ons, %0d switch-offs, %0d start matches held off by /S1",
                 light_px, light_on, light_offs, s1_offs);
        $display("  explosion: %0d yellow and %0d red pixels; splash: %0d pixels with /SPLAY A low, %0d high",
                 ex_y, ex_r, sp_a0, sp_a1);
        $display("  splash window high for %0d pixels, low for %0d", swin_hi, swin_lo);
        if (light_on == 0 || light_offs == 0 || s1_offs == 0 || ex_y == 0 || ex_r == 0 ||
            sp_a0 == 0 || sp_a1 == 0 || swin_hi == 0 || swin_lo == 0)
            $fatal(1, "coverage: a part of the circuit was not reached");
        $finish;
    end
endmodule
