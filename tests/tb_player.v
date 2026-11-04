// SPDX-License-Identifier: GPL-3.0-or-later
// Sheet G player-car path. Every settled pixel of the RTL is compared with the
// pin-wired reference (tests/sheet_g_reference.v), driven by the same stimulus.
// Window geometry and the 74123/74279 behaviour are also checked against
// expectations written here from the data-sheet function tables, and the car
// region of every frame is dumped for scripts/player_raster_check.py.
// Femtosecond precision: the reference times its monostables in absolute
// nanoseconds, so the 48 MHz period must not be rounded (at 1 ps it would run
// 32 ppm slow, about 30 pixels over one 0.1336 s pulse).
`timescale 1ns/1fs
module tb_player;
    reg clk=0, rst=1;
    always #10.416666667 clk=~clk;                   // 48 MHz

    // PROM storage as used in the core, loaded the way JTFRAME downloads it.
    reg rom=0, wr=0;
    reg [25:0] wa=0;
    reg [7:0] wd=0;
    reg [7:0] image[0:8799];
    reg [1023:0] path, outdir;
    wire [179:0] prom_addr;
    wire [159:0] prom_q;
    wire loaded, load_error;
    wire [13:0] bytes_loaded;
    jtmonacogp_proms u_proms(.clk(clk),.addr(prom_addr),.q(prom_q),
        .ioctl_rom(rom),.ioctl_wr(wr),.ioctl_addr(wa),.ioctl_dout(wd),
        .loaded(loaded),.load_error(load_error),.bytes_loaded(bytes_loaded));

    wire pcen, p2cen;
    wire [8:0] h,v,x,y,hp,vp;
    wire hb,vb,hs,vs;
    jtmonacogp_cen u_cen(.clk(clk),.cen14(p2cen),.cen7(pcen));
    jtmonacogp_timing u_timing(.clk(clk),.rst(rst),.pxl_cen(pcen),.h(h),.v(v),
        .hblank(hb),.vblank(vb),.hs(hs),.vs(vs),.x(x),.y(y),.hpos(hp),.vpos(vp));

    reg next_n=1, prev_n=1;
    wire [1:0] state;
    wire [4:0] frame;
    wire t_plh, t_plv, t_coin_n, t_explo, t_explo_n, t_acc1_n, t_home_n;
    wire t_extend_n, t_gravel_n, t_slide_n, t_vs4, t_vs8, t_vs16, t_vs32, t_51_3;
    jtmonacogp_ptest u_ptest(.clk(clk),.rst(rst),.pxl_cen(pcen),.h(h),.v(v),.vs(vs),
        .next_n(next_n),.prev_n(prev_n),.state(state),.frame(frame),
        .pl_h_st(t_plh),.pl_v_st(t_plv),.coin_in_n(t_coin_n),.explo_st(t_explo),
        .explo_st_n(t_explo_n),.acc1_n(t_acc1_n),.home_pos_n(t_home_n),
        .extend_n(t_extend_n),.gravel_n(t_gravel_n),.slide_n(t_slide_n),
        .vs4(t_vs4),.vs8(t_vs8),.vs16(t_vs16),.vs32(t_vs32),.ic51_3(t_51_3));

    // Overrides reach the paths that the four test states leave static.
    // They change only at pixel boundaries, like every other stimulus net.
    reg ovr=0, fast32=0;
    reg o_explo=0, o_acc1_n=1, o_home_n=1, o_extend_n=1, o_slide_n=1, o_gravel_n=1;
    wire s_explo    = ovr ? o_explo    : t_explo;
    wire s_explo_n  = ovr ? ~o_explo   : t_explo_n;
    wire s_acc1_n   = ovr ? o_acc1_n   : t_acc1_n;
    wire s_home_n   = ovr ? o_home_n   : t_home_n;
    wire s_extend_n = ovr ? o_extend_n : t_extend_n;
    wire s_slide_n  = ovr ? o_slide_n  : t_slide_n;
    wire s_gravel_n = ovr ? o_gravel_n : t_gravel_n;
    wire s_vs32     = fast32 ? v[3]    : t_vs32;

    // ---------------- RTL under test
    wire [8:0] a127, a128, a129, a130;
    wire d_body_n, d_tire_n, d_bl_n, d_player_n, d_player, d_spd_n, d_spd;
    wire d_pulse_n, d_st_n, d_score_n, d_66_3, d_vwin, d_hwin, d_strobe_n, d_68_3, d_19q;
    wire [7:0] d_hc, d_vc, d_bus;
    wire [3:0] d_en, d_38;
    wire [1:0] d_mux;
    jtmonacogp_player dut(.clk(clk),.rst(rst),.pxl_cen(pcen),.hs(hs),
        .pl_h_st(t_plh),.pl_v_st(t_plv),.explo_st(s_explo),.explo_st_n(s_explo_n),
        .acc1_n(s_acc1_n),.home_pos_n(s_home_n),.coin_in_n(t_coin_n),
        .extend_n(s_extend_n),.gravel_n(s_gravel_n),.slide_n(s_slide_n),
        .vs4(t_vs4),.vs8(t_vs8),.vs16(t_vs16),.vs32(s_vs32),.ic51_3(t_51_3),
        .pr127_addr(a127),.pr128_addr(a128),.pr129_addr(a129),.pr130_addr(a130),
        .pr127_q(prom_q[2*8+:8]),.pr128_q(prom_q[3*8+:8]),
        .pr129_q(prom_q[4*8+:8]),.pr130_q(prom_q[5*8+:8]),
        .player_body_n(d_body_n),.tire_n(d_tire_n),.player_bl_n(d_bl_n),
        .player_n(d_player_n),.player(d_player),.sp_down_n(d_spd_n),.sp_down(d_spd),
        .acc1_pulse_n(d_pulse_n),.acc1_st_n(d_st_n),.score_st_n(d_score_n),.ic66_3(d_66_3),
        .hc(d_hc),.vc(d_vc),.vwin(d_vwin),.hwin(d_hwin),.strobe_n(d_strobe_n),
        .prom_en(d_en),.bus(d_bus),.mux(d_mux),.ic38_q(d_38),.ic68_3(d_68_3),.ic19_q(d_19q));
    assign prom_addr = {126'd0, a130, a129, a128, a127, 18'd0};

    // ---------------- Pin-wired reference
    // The 7 MHz edge is the pixel boundary. Nets from other sheets settle 5 ns
    // after it, as outputs of counters clocked by that edge would.
    reg f7=0;
    reg [2:0] f7cnt=0;
    always @(posedge clk) begin
        if (pcen) begin f7<=1; f7cnt<=0; end
        else begin f7cnt<=f7cnt+3'd1; if (f7cnt==3'd2) f7<=0; end
    end
    wire r_hs_n, r_plh, r_plv, r_explo, r_explo_n, r_acc1_n, r_home_n, r_coin_n;
    wire r_extend_n, r_gravel_n, r_slide_n, r_vs4, r_vs8, r_vs16, r_vs32, r_51_3;
    assign #5 {r_hs_n, r_plh, r_plv, r_explo, r_explo_n, r_acc1_n, r_home_n, r_coin_n,
               r_extend_n, r_gravel_n, r_slide_n, r_vs4, r_vs8, r_vs16, r_vs32, r_51_3} =
              {~hs, t_plh, t_plv, s_explo, s_explo_n, s_acc1_n, s_home_n, t_coin_n,
               s_extend_n, s_gravel_n, s_slide_n, t_vs4, t_vs8, t_vs16, s_vs32, t_51_3};
    wire [7:0] r_hc, r_vc, r_bus;
    wire [3:0] r_en, r_38;
    wire r_vwin, r_hwin, r_strobe_n, r_y1, r_y2, r_body_n, r_tire_n, r_bl_n, r_68_3, r_19q;
    wire r_player_n, r_player, r_spd_n, r_spd, r_pulse_n, r_st_n, r_score_n, r_66_3;
    sheet_g_reference refg(.f_7mhz(f7),.f_hs_n(r_hs_n),.f_pl_h_st(r_plh),.f_pl_v_st(r_plv),
        .f_explo_st(r_explo),.f_explo_st_n(r_explo_n),.f_acc1_n(r_acc1_n),
        .f_home_pos_n(r_home_n),.a_coin_in_n(r_coin_n),.a_extend_n(r_extend_n),
        .d_gravel_n(r_gravel_n),.d_slide_n(r_slide_n),
        .h_vs4(r_vs4),.h_vs8(r_vs8),.h_vs16(r_vs16),.h_vs32(r_vs32),.ic51_3(r_51_3),
        .hc(r_hc),.vc(r_vc),.vwin(r_vwin),.hwin(r_hwin),.strobe_n(r_strobe_n),
        .prom_en(r_en),.bus(r_bus),.y1(r_y1),.y2(r_y2),
        .player_body_n(r_body_n),.tire_n(r_tire_n),.player_bl_n(r_bl_n),
        .player_n(r_player_n),.player(r_player),.sp_down_n(r_spd_n),.sp_down(r_spd),
        .acc1_pulse_n(r_pulse_n),.acc1_st_n(r_st_n),.score_st_n(r_score_n),
        .ic66_3(r_66_3),.ic38_q(r_38),.ic68_3(r_68_3),.ic19_q(r_19q));

    wire [49:0] dut_nets = {d_hc,d_vc,d_vwin,d_hwin,d_strobe_n,d_en,d_bus,d_mux,
        d_body_n,d_tire_n,d_bl_n,d_player_n,d_player,d_spd_n,d_spd,d_pulse_n,d_st_n,
        d_score_n,d_66_3,d_38,d_68_3,d_19q};
    wire [49:0] ref_nets = {r_hc,r_vc,r_vwin,r_hwin,r_strobe_n,r_en,r_bus,r_y2,r_y1,
        r_body_n,r_tire_n,r_bl_n,r_player_n,r_player,r_spd_n,r_spd,r_pulse_n,r_st_n,
        r_score_n,r_66_3,r_38,r_68_3,r_19q};
    wire [1:0] d_code = !d_body_n ? 2'd1 : !d_tire_n ? 2'd2 : !d_bl_n ? 2'd3 : 2'd0;
    // The two monostables time in pixels (RTL) and nanoseconds (reference).
    wire [1:0] d_mono = {d_spd, d_19q}, r_mono = {r_spd, r_19q};

    real px_ns = 1.0e9/7152500.0;
    integer fp, n, pixel=0, frames=0, compared=0, window_px=0, car_px=0;
    integer edge_mask=0, d_edges=0, r_edges=0, rise119=-1, pulse119=0;
    integer d_edge_at[0:63], r_edge_at[0:63];
    reg comparing=0, dumping=0, vs_q=0;
    reg [1:0] d_mono_q=0, r_mono_q=0;
    reg [5:0] seen;                 // {d_spd,d_19q,d_st_n, r_spd,r_19q,r_st_n}
    reg active, exp_win;

    // Sample each settled pixel during the last host clock of its period.
    always @(negedge clk) if (pcen && !rst) begin
        pixel = pixel + 1;
        if (vs_q && !vs) frames = frames + 1;
        vs_q = vs;
        active = !hb && !vb;
        if (comparing) begin
            if ((^dut_nets) === 1'bx || (^ref_nets) === 1'bx)
                $fatal(1,"unknown net at pixel %0d: DUT %b REF %b",pixel,dut_nets,ref_nets);
            // Monostable edges may differ by up to two pixel periods.
            if (d_mono != d_mono_q) begin
                if (d_edges < 64) d_edge_at[d_edges] = pixel;
                d_edges = d_edges + 1;
                if (d_spd && !d_mono_q[1]) rise119 = pixel;
                if (!d_spd && d_mono_q[1] && rise119 >= 0 && pixel - rise119 > pulse119)
                    pulse119 = pixel - rise119;
            end
            if (r_mono != r_mono_q) begin
                if (r_edges < 64) r_edge_at[r_edges] = pixel;
                r_edges = r_edges + 1;
            end
            d_mono_q = d_mono;
            r_mono_q = r_mono;
            if (dut_nets !== ref_nets) begin
                if (d_mono !== r_mono) edge_mask = edge_mask + 1;
                else $fatal(1,"sheet G mismatch at pixel %0d (x=%0d y=%0d h=%h v=%h):\n DUT %b\n REF %b",
                            pixel,x,y,h,v,dut_nets,ref_nets);
            end
            compared = compared + 1;
            // Geometry: PL-H-ST at x=35 holds HC at 0 for that pixel and the
            // next, so HC=0x80 at x=35+1+128=164. PL-V-ST on line y=56 clears
            // VC, which counts each later HS end: VC=0x30 at y=56+48=104.
            exp_win = active && x>=164 && x<196 && y>=104 && y<136 && !s_explo;
            if ((!d_strobe_n) !== exp_win)
                $fatal(1,"car window at x=%0d y=%0d (active %b): strobe %b",x,y,active,d_strobe_n);
            if (exp_win) window_px = window_px + 1;
            if (d_code != 0) begin
                car_px = car_px + 1;
                if (!exp_win) $fatal(1,"car pixel outside the window at x=%0d y=%0d",x,y);
            end
        end
        if (dumping && active && y>=100 && y<140 && x>=160 && x<200) begin
            if (x==160 && y==100)
                $fwrite(fp,"FRAME %0d STATE %0d VS %b%b%b%b OVR %b EXPLO %b\n",frames,state,
                        t_vs4,t_vs8,t_vs16,s_vs32,ovr,s_explo);
            $fwrite(fp,"%0d%h",d_code,d_en);
            if (x==199) begin
                $fwrite(fp,"\n");
                if (y==139) $fflush(fp);        // progress is visible frame by frame
            end
        end
    end

    task wait_frames(input integer k);
        integer target;
        begin
            target = frames + k;
            while (frames < target) @(negedge clk);
            // The test state register changes one pixel after the VS edge.
            repeat(16) @(negedge clk);
        end
    endtask
    task press(input integer which);
        begin
            @(negedge clk);
            if (which) next_n=0; else prev_n=0;
            repeat(8) @(negedge clk);
            next_n=1; prev_n=1;
            repeat(8) @(negedge clk);
        end
    endtask
    // Records the monostable and latch outputs at the end of line v=line-1,
    // then returns at the pixel boundary where v becomes line, so the caller's
    // nonblocking assignments change the overrides on that 7 MHz edge.
    task boundary(input integer line);
        begin
            @(negedge clk);
            while (!(pcen && hb && h==9'h1df && v==line-1)) @(negedge clk);
            seen = {d_spd, d_19q, d_st_n, r_spd, r_19q, r_st_n};
            @(posedge clk);
        end
    endtask
    task expect_state(input [1:0] s);
        if (state !== s) $fatal(1,"test state %0d, expected %0d",state,s);
    endtask
    // q119 = IC119 Q, q19 = IC19 Q, st = /ACC1.ST, for both models
    task expect_seen(input q119, input q19, input st, input [8*32-1:0] what);
        if (seen !== {q119,q19,st,q119,q19,st})
            $fatal(1,"after %0s: RTL IC119 %b IC19 %b /ACC1.ST %b; reference %b %b %b; expected %b %b %b",
                   what,seen[5],seen[4],seen[3],seen[2],seen[1],seen[0],q119,q19,st);
    endtask

    initial begin
        if (!$value$plusargs("ROM=%s",path) || !$value$plusargs("OUT=%s",outdir))
            $fatal(1,"missing ROM/OUT");
        $readmemh(path,image);
        fp=$fopen($sformatf("%0s/player-frames.txt",outdir),"w");
        if (!fp) $fatal(1,"cannot open frame dump");
        repeat(4) @(negedge clk);
        rom=1;
        for (n=0;n<8800;n=n+1) begin
            @(negedge clk); wa=n; wd=image[n]; wr=1;
        end
        @(negedge clk); wr=0; rom=0;
        repeat(4) @(negedge clk);
        if (!loaded || load_error) $fatal(1,"PROM download failed");
        rst=0;
        // Frame 0 lets the reference leave its power-up state.
        wait_frames(1);
        comparing=1; dumping=1;
        expect_state(0);
        wait_frames(4);                                   // normal: Vs/4 = 0, 1
        press(1); wait_frames(1); expect_state(1);
        wait_frames(3);                                   // slide
        press(0); wait_frames(1); expect_state(0);
        wait_frames(9);                                   // IC119 runs out
        if (d_spd || r_spd) $fatal(1,"IC119 still active nine frames after the slide state");
        press(1); press(1); wait_frames(1); expect_state(2);
        wait_frames(16);                                  // accident: Vs/8, Vs/16 cycle
        press(1); wait_frames(1); expect_state(3);
        wait_frames(2);                                   // explosion
        press(1); wait_frames(1); expect_state(0);

        // Monostable, latch and IC38 sequence. EXPLO.ST high holds IC68 pin 3
        // (both B inputs) high and blanks the car.
        boundary(9'd20);
        ovr<=1; o_explo<=1; o_acc1_n<=0; o_extend_n<=0; fast32<=1;
        o_slide_n<=0;                                     // A falls, B high
        boundary(9'd21); o_slide_n<=1;
        boundary(9'd30); expect_seen(1,1,1,"/SLIDE falling with B high");
        o_home_n<=0;                                      // IC51 /S released by IC19 Q
        boundary(9'd31); o_home_n<=1;
        boundary(9'd40); expect_seen(0,1,0,"/HOME POS. low");
        // /ACC1.ST low clears IC119 and, with /EXTEND low, releases IC38,
        // which V3 (in place of Vs/32) steps every 16 lines. PR128 (QD) then
        // shares the bus with PR129 or PR130.
        o_explo<=0;
        wait_frames(4);
        boundary(9'd20);
        o_explo<=1; o_gravel_n<=0;                        // IC119 A low, B high
        boundary(9'd40); expect_seen(0,1,0,"IC119 held clear");
        // IC19 expires 0.1336 s after its trigger; /S then sets IC51 and the
        // rising /CLR of IC119 triggers it (A low, B high).
        wait_frames(5);
        boundary(9'd20); expect_seen(1,0,1,"IC19 expiry");
        o_gravel_n<=1; o_explo<=0;
        wait_frames(1);
        comparing=0;

        for (n=0;n<64 && (n<d_edges || n<r_edges);n=n+1)
            $display("monostable edge %0d: RTL pixel %0d, reference pixel %0d",n,
                     n<d_edges ? d_edge_at[n] : -1, n<r_edges ? r_edge_at[n] : -1);
        if (d_edges != r_edges || d_edges > 64)
            $fatal(1,"monostable edges: RTL %0d, reference %0d",d_edges,r_edges);
        for (n=0;n<d_edges;n=n+1)
            if (d_edge_at[n]-r_edge_at[n] > 2 || r_edge_at[n]-d_edge_at[n] > 2)
                $fatal(1,"monostable edge %0d: RTL pixel %0d, reference %0d",n,d_edge_at[n],r_edge_at[n]);
        if (edge_mask > 2*d_edges) $fatal(1,"too many pixels around monostable edges: %0d",edge_mask);
        $fclose(fp);
        $display("PASS player: %0d settled pixels over %0d frames match the pin-wired sheet G reference (%0d monostable edges, each within 2 pixels; %0d pixels masked at those edges)",
                 compared,frames-1,d_edges,edge_mask);
        $display("PASS player: car window x=164..195 y=104..135 in every frame (%0d window pixels, %0d car pixels); 74123/74279 function-table cases pass; longest IC119 pulse %0d pixels (%0.4f s)",
                 window_px,car_px,pulse119,pulse119*px_ns*1.0e-9);
        $finish;
    end
endmodule
