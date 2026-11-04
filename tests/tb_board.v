// SPDX-License-Identifier: GPL-3.0-or-later
`timescale 1ns/1ps
// MiSTer reset, download and video path at board level. The pinned JTFRAME
// download (jtframe_mister_dwnld), sync (jtframe_resync), horizontal scaler
// (jtframe_hsize) and board (jtframe_board, which contains jtframe_reset)
// modules are wired as in jtframe_mister.sv, and the game is instantiated by
// JTFRAME's own jtframe_game_instance.v. The HPS side follows
// sys/hps_io.sv and an MRA load by Main_MiSTer: status[0] (reset) is held
// while file index 0 (the PROMs) and file index 1 (core_mod, the bytes 00 80
// of the MRA) are sent.
// scripts/check_jtframe.py compiles this with the macros JTFRAME generates.
//
// Expectations come from those JTFRAME sources and from docs/TIMING.md:
// - game_rst falls after power-up, is high throughout the download, and falls
//   within 100 clk_rom cycles of status[0] clearing (two sync stages, four
//   pixel enables through jtframe_reset's rst_rom, eight game_rst_cnt cycles);
// - every PROM byte reaches the game at its address, and the core reports the
//   load complete without error; the core_mod bytes leave core_mod at 0
//   (horizontal) and the volume at 80, unity (jtframe_mister_dwnld);
// - afterwards the signals that jtframe_mister.sv hands to arcade_video, sampled
//   on its ce_pix, have 456-pixel lines with 32-pixel HS, 264-line frames with a
//   four-line VS and 360x240 active pixels, one frame lasts 240,768 cycles of a
//   14.305 MHz X1 at the 48 MHz clk_rom, and every active pixel equals the
//   game's own output (no JTFRAME overlay), not all black.
// The core's pixel enables feed jtframe_reset (JTFRAME_PXLCLK is not set), so
// a pixel enable generator held in reset by game_rst never releases it.
module tb_board;
    localparam SDRAMW=22, ROMLEN=8800, RELEASE_MAX=100,
               LINE=456, HSW=32, LINES=264, VSW=4*LINE, ACTIVE=360*240;
    localparam integer FRAME_CLK=807890;  // 240,768 * 48 MHz / 14.305 MHz = 807,889.8
    reg clk_rom=0;
    always #(1000.0/96.0) clk_rom=~clk_rom;   // 48 MHz: clk_sys = clk_rom (no JTFRAME_SDRAM96)
    wire clk_sys=clk_rom, clk96=clk_rom, clk24=clk_rom;
    wire rst96, rst24;
    reg  pll_locked=0;
    reg  [63:0] status=0;
    wire rst_req=status[0];
    // HPS side, as sys/hps_io.sv drives it
    reg  hps_download=0, hps_wr=0;
    reg  [15:0] hps_index=0;
    reg  [26:0] hps_addr=0;
    reg  [ 7:0] hps_dout=0;
    wire hps_wait;
    // jtframe_mister.sv / jtframe_emu.sv nets
    wire ioctl_rom, ioctl_wr, ioctl_ram, ioctl_cart, ioctl_cheat, ioctl_lock;
    wire [26:0] ioctl_addr;
    wire [ 7:0] ioctl_dout;
    wire [17:0] core_mod;
    wire [ 7:0] game_vol;
    wire [31:0] dipsw, cheat;
    wire rst, rst_n, game_rst, game_rst_n, sdram_init, dwnld_busy;
    wire pxl_cen, pxl2_cen;
    wire [`JTFRAME_COLORW-1:0] red, green, blue;
    wire LHBL, LVBL, hs, vs;
    wire [SDRAMW-1:0] prog_addr, ba0_addr, ba1_addr, ba2_addr, ba3_addr;
    wire [15:0] prog_data, ba0_din, ba1_din, ba2_din, ba3_din, sdram_dout;
    wire [ 1:0] prog_mask, prog_ba, ba0_dsn, ba1_dsn, ba2_dsn, ba3_dsn;
    wire prog_we, prog_rd, prog_rdy, prog_ack, prog_dst, prog_dok;
    wire [ 3:0] ba_rd, ba_wr, ba_ack, ba_rdy, ba_dst, ba_dok;
    wire [ 9:0] game_joy1, game_joy2, game_joy3, game_joy4;
    wire [ 3:0] game_coin, game_start;
    wire game_service, game_tilt, dip_test, dip_pause, dip_flip;
    wire [ 1:0] dip_fxlevel, dial_x, dial_y;
    wire [15:0] joyana_l1, joyana_l2, joyana_l3, joyana_l4,
                joyana_r1, joyana_r2, joyana_r3, joyana_r4;
    wire [ 3:0] gfx_en;
    wire [ 7:0] debug_bus, debug_view, snd_vol, st_addr, st_dout;
    wire [ 5:0] snd_en, snd_vu;
    wire [15:0] snd_left;
    wire sample, snd_peak;
    wire [15:0] SDRAM_DQ;
    wire [12:0] SDRAM_A;
    wire [ 1:0] SDRAM_BA;
    wire SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS, SDRAM_CKE;
    wire [3*`JTFRAME_COLORW-1:0] base_rgb;
    wire base_lhbl, base_lvbl, base_hs, base_vs;
    wire hs_resync, vs_resync, hsize_hs, hsize_vs, hsize_hb, hsize_vb;
    wire [`JTFRAME_COLORW-1:0] hsize_r, hsize_g, hsize_b;
    reg  pxl1_cen=0;
    assign {joyana_l3, joyana_l4, joyana_r3, joyana_r4}=0;

    jtframe_rst_sync u_reset96(.rst(game_rst),.clk(clk96),.rst_sync(rst96));
    jtframe_rst_sync u_reset24(.rst(game_rst),.clk(clk24),.rst_sync(rst24));

    // FPGA registers power up at zero. jtframe_resync has no reset: it sets
    // these four only under SIMULATION, and its field flag nowhere.
    initial begin
        u_resync.hs_cnt=0;
        u_resync.vs_cnt=0;
        u_resync.hs_out=0;
        u_resync.vs_out=0;
        u_resync.field=0;
    end
    always @(posedge clk_sys) pxl1_cen <= pxl2_cen & ~pxl_cen;
    // status[60:53] (H/V offset) and status[48] (horizontal scaling) are zero,
    // as jtframe_mister_status decodes them.
    jtframe_resync u_resync(.clk(clk_sys),.pxl_cen(pxl1_cen),.hs_in(hs),.vs_in(vs),
        .LVBL(LVBL),.LHBL(LHBL),.hoffset(status[56:53]),.voffset(status[60:57]),
        .hs_out(hs_resync),.vs_out(vs_resync));
    jtframe_hsize #(.COLORW(`JTFRAME_COLORW)) u_hsize(.clk(clk_sys),.pxl_cen(pxl1_cen),
        .pxl2_cen(pxl2_cen),.scale(status[52:49]),.offset(5'd0),.enable(status[48]),
        .r_in(red),.g_in(green),.b_in(blue),.HS_in(hs_resync),.VS_in(vs_resync),
        .HB_in(~LHBL),.VB_in(~LVBL),.HS_out(hsize_hs),.VS_out(hsize_vs),
        .HB_out(hsize_hb),.VB_out(hsize_vb),.r_out(hsize_r),.g_out(hsize_g),.b_out(hsize_b));

    jtframe_mister_dwnld u_dwnld(
        .rst(rst),.clk(clk_rom),.prog_we(prog_we),.prog_rdy(prog_rdy),
        .ioctl_rom(ioctl_rom),.dwnld_busy(dwnld_busy),
        .hps_download(hps_download),.hps_upload(1'b0),.hps_index(hps_index[7:0]),
        .hps_wr(hps_wr),.hps_addr(hps_addr),.hps_dout(hps_dout),.hps_wait(hps_wait),
        .ioctl_wr(ioctl_wr),.ioctl_addr(ioctl_addr),.ioctl_dout(ioctl_dout),
        .ioctl_ram(ioctl_ram),.ioctl_cart(ioctl_cart),.ioctl_cheat(ioctl_cheat),
        .ioctl_lock(ioctl_lock),.core_mod(core_mod),.game_vol(game_vol),
        .status(status[31:0]),.dipsw(dipsw),.cheat(cheat),
        .ddram_busy(1'b0),.ddram_burstcnt(),.ddram_addr(),.ddram_dout(64'd0),
        .ddram_dout_ready(1'b0),.ddram_rd());

    jtframe_board #(.BUTTONS(`JTFRAME_BUTTONS),.COLORW(`JTFRAME_COLORW),.SDRAMW(SDRAMW),
        .VIDEO_WIDTH(`JTFRAME_WIDTH),.VIDEO_HEIGHT(`JTFRAME_HEIGHT),.MISTER(1)) u_board(
        .rst(rst),.rst_n(rst_n),.game_rst(game_rst),.game_rst_n(game_rst_n),
        .rst_req(rst_req),.sdram_init(sdram_init),.pll_locked(pll_locked),
        .ioctl_cart(ioctl_cart),.ioctl_ram(ioctl_ram),.dwnld_busy(dwnld_busy),
        .clk_sys(clk_sys),.clk_rom(clk_rom),.clk_pico(clk_sys),
        .core_mod(core_mod),.game_vol(game_vol),.vertical(),.black_frame(),
        .snd_lin(snd_left),.snd_rin(snd_left),.snd_lout(),.snd_rout(),
        .snd_sample(sample),.snd_en(snd_en),.snd_vu(snd_vu),.snd_vol(snd_vol),
        .snd_peak(snd_peak),
        .ps2_kbd_clk(1'b1),.ps2_kbd_data(1'b1),
        .board_joystick1(16'd0),.board_joystick2(16'd0),
        .board_joystick3(16'd0),.board_joystick4(16'd0),
        .joyana_l1(16'd0),.joyana_r1(16'd0),.joyana_l2(16'd0),.joyana_r2(16'd0),
        .board_start(4'd0),.board_coin(4'd0),
        .game_joystick1(game_joy1),.game_joystick2(game_joy2),
        .game_joystick3(game_joy3),.game_joystick4(game_joy4),
        .game_coin(game_coin),.game_start(game_start),
        .game_service(game_service),.game_tilt(game_tilt),
        .bd_mouse_dx(9'd0),.bd_mouse_dy(9'd0),.bd_mouse_st(1'b0),.bd_mouse_f(8'd0),
        .bd_mouse_idx(1'b0),
        .board_paddle_1(8'd0),.board_paddle_2(8'd0),.game_paddle_1(),.game_paddle_2(),
        .mouse_1p(),.mouse_2p(),.mouse_strobe(),.spinner_1(9'd0),.spinner_2(9'd0),
        .dial_x(dial_x),.dial_y(dial_y),
        .gun_1p_x(),.gun_1p_y(),.gun_2p_x(),.gun_2p_y(),.lightgun_en(),
        .status(status),.dipsw(dipsw[23:0]),.dip_test(dip_test),.dip_pause(dip_pause),
        .dip_flip(dip_flip),.dip_fxlevel(dip_fxlevel),.timestamp(32'd0),
        .hdmi_arx(),.hdmi_ary(),.rotate(),.rot_osdonly(),
        .osd_shown(1'b0),.led(),.uart_rx(1'b1),.uart_tx(),
        .ba0_addr(ba0_addr),.ba1_addr(ba1_addr),.ba2_addr(ba2_addr),.ba3_addr(ba3_addr),
        .ba_rd(ba_rd),.ba_wr(ba_wr),.ba_dst(ba_dst),.ba_dok(ba_dok),.ba_rdy(ba_rdy),
        .ba_ack(ba_ack),
        .ba0_din(ba0_din),.ba0_dsn(ba0_dsn),.ba1_din(ba1_din),.ba1_dsn(ba1_dsn),
        .ba2_din(ba2_din),.ba2_dsn(ba2_dsn),.ba3_din(ba3_din),.ba3_dsn(ba3_dsn),
        .prog_addr(prog_addr),.prog_ba(prog_ba),.prog_rd(prog_rd),.prog_we(prog_we),
        .prog_data(prog_data),.prog_dsn(prog_mask),.prog_rdy(prog_rdy),
        .prog_dst(prog_dst),.prog_dok(prog_dok),.prog_ack(prog_ack),
        .SDRAM_DQ(SDRAM_DQ),.SDRAM_A(SDRAM_A),.SDRAM_DQML(SDRAM_DQML),
        .SDRAM_DQMH(SDRAM_DQMH),.SDRAM_nWE(SDRAM_nWE),.SDRAM_nCAS(SDRAM_nCAS),
        .SDRAM_nRAS(SDRAM_nRAS),.SDRAM_nCS(SDRAM_nCS),.SDRAM_BA(SDRAM_BA),
        .SDRAM_CKE(SDRAM_CKE),
        .sdram_dout(sdram_dout),
        .cheat(cheat),.prog_cheat(ioctl_cheat),.prog_lock(ioctl_lock),
        .ioctl_wr(hps_wr),.ioctl_dout(ioctl_dout),.ioctl_addr(ioctl_addr[7:0]),
        .ioctl_din(8'd0),.ioctl_merged(),.osd_rotate(2'd0),
        .game_r(hsize_r),.game_g(hsize_g),.game_b(hsize_b),.LHBL(~hsize_hb),.LVBL(~hsize_vb),
        .hs(hsize_hs),.vs(hsize_vs),.pxl2_cen(pxl2_cen),.pxl_cen(pxl_cen),
        .base_rgb(base_rgb),.base_lhbl(base_lhbl),.base_lvbl(base_lvbl),
        .base_hs(base_hs),.base_vs(base_vs),
        .st_addr(st_addr),.st_dout(st_dout),.target_info(8'd0),
        .gfx_en(gfx_en),.debug_bus(debug_bus),.debug_view(debug_view));

`include "jtframe_game_instance.v"

    // PROM image: a deterministic pattern stands in for the dumps, which this
    // check does not need.
    reg [7:0] rom[0:ROMLEN-1];
    integer n;
    initial for(n=0;n<ROMLEN;n=n+1) rom[n]=(n*37+11)&8'hff;
    reg  [7:0] coremod[0:1];                      // <rom index="1"><part>00 80</part>
    initial begin coremod[0]=8'h00; coremod[1]=8'h80; end

    // One FIO_FILE_INDEX, FIO_FILE_TX(0xff), one FIO_FILE_TX_DAT per byte and
    // FIO_FILE_TX(0x00). hps_io presents address and data, then pulses
    // ioctl_wr on the next clock; words arrive at SPI pace.
    task hps_file(input [7:0] index, input integer length);
        integer i;
        begin
            @(posedge clk_rom) hps_index<=index;
            repeat(40) @(posedge clk_rom);
            hps_download<=1;
            for(i=0;i<length;i=i+1) begin
                repeat(16) @(posedge clk_rom);
                while(hps_wait) @(posedge clk_rom);
                hps_addr<=i;
                hps_dout<= index==0 ? rom[i] : coremod[i];
                @(posedge clk_rom) hps_wr<=1;
                @(posedge clk_rom) hps_wr<=0;
            end
            repeat(40) @(posedge clk_rom);
            hps_download<=0;
            hps_addr<=length;
        end
    endtask

    // Watchers
    reg  holding=0, waiting=0, released=0;
    integer writes=0, since_req=0;
    always @(posedge clk_rom) begin
        if(ioctl_wr && ioctl_rom) begin
            if(ioctl_addr>=ROMLEN || ioctl_dout!==rom[ioctl_addr])
                $fatal(1,"PROM byte %0d reached the game as %h",ioctl_addr,ioctl_dout);
            writes=writes+1;
        end
        if(holding && game_rst!==1'b1) $fatal(1,"game reset released during the download");
        if(released && game_rst!==1'b0) $fatal(1,"game reset asserted again after release");
        if(waiting) since_req=since_req+1;
    end

    // The game's own picture: active pixels in raster order, restarting at VS.
    reg  [3*`JTFRAME_COLORW-1:0] game_frame[0:ACTIVE-1];
    integer gidx=0, gpix=0, gstart=0, changed=0;
    reg     gvs=0;

    // Video as arcade_video receives it: RGB and blanking from the board,
    // syncs from jtframe_hsize, sampled on ce_pix (pxl_cen). After the reset,
    // jtframe_resync gives no VS until it has measured the game's VS in both of
    // its alternating fields. From its first VS on, two frames are checked, and
    // each active pixel is compared with the game's pixel at the same raster
    // position of the same frame. The game's pixel is stored first, in the same
    // block: with jtframe_hsize disabled (status[48]=0) nothing on this path
    // holds a line, and a pixel can reach the scaler input at the same pixel
    // enable as it leaves the game, so separate blocks would race on that edge.
    // The player-car test changes its VS/4 or VS/8 digit every second frame, so
    // the two frames include a change, which a comparison with the previous
    // frame would miss.
    localparam SETTLE=1, CHECKED=2;
    integer pixels=0, line_start=-1, hs_start=-1, vs_start=-1, vs_rises=0, frame_clk=0;
    integer active=0, lit=0, lines=0, frames=0, lag=-1;
    reg     lhs=0, lvs=0;
    always @(posedge clk_rom) begin
        if(pxl_cen) begin
            if(vs && !gvs) gidx=0;
            if(LHBL && LVBL && gidx<ACTIVE) begin
                if(gidx==0) gstart=gpix;
                if(released && vs_rises>=SETTLE && game_frame[gidx]!=={red,green,blue})
                    changed=changed+1;
                game_frame[gidx]={red,green,blue};
                gidx=gidx+1;
            end
            gvs<=vs;
        end
        if(released) begin
            frame_clk=frame_clk+1;
            if(pxl_cen) begin
                if((^{base_rgb,base_lhbl,base_lvbl,hsize_hs,hsize_vs})===1'bx)
                    $fatal(1,"unknown video at the scaler input, pixel %0d after release",pixels);
                if(hsize_hs && !lhs) begin
                    if(vs_rises>=SETTLE && pixels-line_start!=LINE)
                        $fatal(1,"line of %0d pixel enables, expected %0d",pixels-line_start,LINE);
                    line_start=pixels;
                    hs_start=pixels;
                    lines=lines+1;
                end
                if(!hsize_hs && lhs && vs_rises>=SETTLE && pixels-hs_start!=HSW)
                    $fatal(1,"HS of %0d pixel enables, expected %0d",pixels-hs_start,HSW);
                if(hsize_vs && !lvs) begin
                    $display("VS %0d at pixel %0d after release: %0d lines, %0d active pixels, %0d lit, %0d clk_rom cycles since the previous VS",
                             vs_rises+1,pixels,lines,active,lit,frame_clk);
                    if(vs_rises>=SETTLE) begin
                        if(lines!=LINES) $fatal(1,"frame of %0d lines, expected %0d",lines,LINES);
                        if(active!=ACTIVE) $fatal(1,"frame of %0d active pixels, expected %0d",active,ACTIVE);
                        if(lit==0) $fatal(1,"active area entirely black");
                        if(frame_clk<FRAME_CLK-1 || frame_clk>FRAME_CLK+1)
                            $fatal(1,"frame of %0d clk_rom cycles, expected %0d",frame_clk,FRAME_CLK);
                        frames=frames+1;
                    end
                    vs_rises=vs_rises+1;
                    vs_start=pixels;
                    lines=0; active=0; lit=0; frame_clk=0;
                end
                if(!hsize_vs && lvs && vs_rises>=SETTLE && pixels-vs_start!=VSW)
                    $fatal(1,"VS of %0d pixel enables, expected %0d",pixels-vs_start,VSW);
                if(base_lhbl && base_lvbl) begin
                    if(vs_rises>=SETTLE && active==0) begin
                        if(gpix-gstart<0 || gpix-gstart>=LINE)
                            $fatal(1,"first active pixel at the scaler input %0d pixel enables after the game's, expected less than one line",
                                   gpix-gstart);
                        if(lag>=0 && gpix-gstart!=lag)
                            $fatal(1,"delay to the scaler input changed from %0d to %0d pixel enables",lag,gpix-gstart);
                        lag=gpix-gstart;
                    end
                    if(vs_rises>=SETTLE && active<ACTIVE && base_rgb!==game_frame[active])
                        $fatal(1,"pixel %0d,%0d is %h at the scaler input, %h from the game",
                               active%360,active/360,base_rgb,game_frame[active]);
                    active=active+1;
                    if(base_rgb!=0) lit=lit+1;
                end
                lhs<=hsize_hs;
                lvs<=hsize_vs;
                pixels=pixels+1;
            end
        end
        if(pxl_cen) gpix=gpix+1;
    end

    integer t;
    initial begin
        #2000 pll_locked=1;
        // Power-up: after JTFRAME's own reset and the SDRAM initialisation,
        // jtframe_reset counts pixel enables and releases the game.
        t=0;
        while(rst!==1'b0 || sdram_init!==1'b0) begin
            @(posedge clk_rom) t=t+1;
            if(t>48000) $fatal(1,"JTFRAME reset and SDRAM initialisation not finished within 1 ms");
        end
        t=0;
        while(game_rst!==1'b0) begin
            @(posedge clk_rom) t=t+1;
            if(t>RELEASE_MAX) $fatal(1,"game reset still high %0d clk_rom cycles after power-up initialisation",t);
        end
        repeat(4800) @(posedge clk_rom);
        if(game_rst!==1'b0) $fatal(1,"game reset asserted again after power-up");
        // MRA load: Main_MiSTer holds status[0] around the ROM transfer.
        status[0]=1;
        repeat(16) @(posedge clk_rom);
        holding=1;
        hps_file(8'd0,ROMLEN);
        hps_file(8'd1,2);
        repeat(480) @(posedge clk_rom);
        if(writes!=ROMLEN) $fatal(1,"%0d PROM writes reached the game, expected %0d",writes,ROMLEN);
        if(!u_game.loaded || u_game.load_error) $fatal(1,"core reports the load incomplete or in error");
        if(core_mod!==0 || game_vol!==8'h80) $fatal(1,"core_mod %h and volume %h after the MRA bytes 00 80",core_mod,game_vol);
        holding=0;
        waiting=1;
        status[0]=0;
        while(game_rst!==1'b0) begin
            @(posedge clk_rom);
            if(since_req>RELEASE_MAX)
                $fatal(1,"game reset still high %0d clk_rom cycles after status[0] cleared",since_req);
        end
        waiting=0;
        released=1;
        t=0;
        while(frames<CHECKED) begin
            @(posedge clk_rom) t=t+1;
            if(t>6*FRAME_CLK) $fatal(1,"%0d of %0d frames checked within six frame times of release",frames,CHECKED);
        end
        if(changed==0) $fatal(1,"the game's picture did not change during the checked frames");
        $display("PASS JTFRAME board: game reset released after power-up; %0d PROM bytes through jtframe_mister_dwnld with status[0] held; release %0d clk_rom cycles after status[0] cleared; at the scaler input %0d frames of %0d lines x %0d pixel enables, %0dx%0d active, each %0d +/- 1 clk_rom cycles, pixels equal to the game's output %0d pixel enables later (%0d of them changed between frames)",
                 writes,since_req,CHECKED,LINES,LINE,`JTFRAME_WIDTH,`JTFRAME_HEIGHT,FRAME_CLK,lag,changed);
        $finish;
    end
endmodule
