// SPDX-License-Identifier: GPL-3.0-or-later
`timescale 1ns/1ps
module tb_game;
    reg clk=0,rst=1,rom=0,wr=0;
    always #5 clk=~clk;
    reg [25:0] wa=0;
    reg [7:0] wd=0;
    reg [5:0] joy=6'b111111;
    reg [31:0] status=0;
    wire pcen,p2cen,lhbl,lvbl,hs,vs;
    wire [3:0] r,g,b;
    wire signed [15:0] snd;
    wire [7:0] debug_view;
    wire [3:0] rd,write_bank;
    wire prog_we,prog_rd,busy;
    reg [7:0] expected[0:8799];
    reg [1023:0] path,outdir;
    integer n,k,fp,pixels;
    `include "tb_game_mem.vh"
    jtmonacogp_game dut(
`include "tb_game_mem_ports.vh"
        .clk(clk),.rst(rst),.rst24(rst),.clk24(clk),.rst96(rst),.clk96(clk),
        .pxl_cen(pcen),.pxl2_cen(p2cen),.red(r),.green(g),.blue(b),
        .LHBL(lhbl),.LVBL(lvbl),.HS(hs),.VS(vs),
        .cab_1p(4'hf),.coin(4'hf),.joystick1(joy),.joystick2(6'h3f),
        .joystick3(6'h3f),.joystick4(6'h3f),.dial_x(2'b00),.dial_y(2'b00),
        .joyana_l1(16'd0),.joyana_l2(16'd0),.joyana_l3(16'd0),.joyana_l4(16'd0),
        .joyana_r1(16'd0),.joyana_r2(16'd0),.joyana_r3(16'd0),.joyana_r4(16'd0),
        .snd_en(6'h3f),.snd_vol(8'hff),.status(status),.dipsw(32'd0),
        .dip_pause(1'b1),.dip_test(1'b1),.service(1'b1),.tilt(1'b1),
        .dip_fxlevel(2'b00),.gfx_en(4'hf),.debug_bus(8'd0),.debug_view(debug_view),
        .ioctl_ram(1'b0),.ioctl_cart(1'b0),
        .snd(snd));
    task reset_game;
        begin
            @(negedge clk); rst=1;
            repeat(4) @(negedge clk);
            rst=0;
        end
    endtask
    task button;
        input integer bitno;
        begin
            @(negedge clk); joy[bitno]=0;
            repeat(8) @(negedge clk);
            joy[bitno]=1;
            repeat(8) @(negedge clk);
        end
    endtask
    // Road and scenery view: the PROM data reaching sheets B and D are those
    // of PR-133..PR-137 at the address of the clock before.
    reg [44:0] scen_a_l=0;
    reg scen_check=0;
    integer scen_reads=0, kk;
    always @(posedge clk) scen_a_l <= dut.prom_addr[72+:45];
    always @(negedge clk) if(scen_check) begin
        for(kk=0;kk<5;kk=kk+1)
            if(dut.prom_q[(8+kk)*8+:8]!==expected[4096+kk*512+scen_a_l[kk*9+:9]])
                $fatal(1,"road and scenery view: PR-%0d data for address %h",133+kk,scen_a_l[kk*9+:9]);
        if({dut.u_scenery_nand.pr134_addr,dut.u_scenery_nand.pr135_addr,dut.u_scenery_nand.pr136_addr,
            dut.u_scenery_nand.pr137_addr}!=={dut.pr134_addr,dut.pr135_addr,dut.pr136_addr,dut.pr137_addr})
            $fatal(1,"road and scenery view: the IC66 NAND copy addresses the PROMs differently");
        scen_reads=scen_reads+1;
    end
    // OSD Display option (status bits 15:13): 0 player-car test, 1 PROM bits,
    // 2 timing grid, 3 road and scenery, 4 the same with IC66 read as a NAND
    // (5, the connected sheets, is checked in tests/tb_play.v).
    task capture;
        input integer mode;
        reg expected_bit;
        reg [7:0] d;
        reg [1:0] code;
        reg [11:0] want;
        integer byte_addr,bitno,rr,cc,car_pixels;
        begin
            status[15:13]=mode;
            if(mode<3) reset_game();   // the road and scenery frame follows its own setup
            if(!dut.loaded) $fatal(1,"game reset erased ROM completion");
            car_pixels=0;
            if(mode>=3) fp=$fopen($sformatf("%0s/road-scenery%0s.ppm",outdir,mode==4 ? "-ic66nand" : ""),"w");
            else if(mode==2) fp=$fopen($sformatf("%0s/timing-grid.ppm",outdir),"w");
            else if(mode==1) fp=$fopen($sformatf("%0s/prom-diagnostic.ppm",outdir),"w");
            else fp=$fopen($sformatf("%0s/player-car-test.ppm",outdir),"w");
            if(!fp) $fatal(1,"cannot open screenshot output");
            $fdisplay(fp,"P3\n360 240\n255");
            pixels=0;
            while(pixels<360*240) begin
                @(posedge clk);
                if(pcen) begin
                    if((^({r,g,b,hs,vs,lhbl,lvbl}))===1'bx) $fatal(1,"unknown video output");
                    if(debug_view!==0) $fatal(1,"non-zero debug_view, which JTFRAME draws over the picture");
                    if(snd!==0)
                        $fatal(1,"unexpected audio activity");
                    if(lhbl && lvbl) begin
                        if(dut.x!==pixels%360 || dut.y!==pixels/360)
                            $fatal(1,"display coordinate/enable alignment");
                        if(mode==1 && dut.x>=116 && dut.x<244 && dut.y>=64 && dut.y<192) begin
                            byte_addr=((dut.y-64)/2)*8+(dut.x-116)/16;
                            bitno=7-(((dut.x-116)/2)%8);
                            expected_bit=expected[byte_addr][bitno];
                            if({r,g,b}!=={12{expected_bit}}) $fatal(1,"display/PROM pipeline alignment at %0d,%0d",dut.x,dut.y);
                        end
                        // Player-car test, first frame after reset: PR127 with
                        // A8 = Vs/4 = 0 in the window x=164..195, y=104..135.
                        if(mode==0 && dut.x>=164 && dut.x<196 && dut.y>=104 && dut.y<136) begin
                            rr=dut.y-104; cc=dut.x-164;
                            d=expected[1024+((cc/4)*32)+((48+rr)%32)];
                            code={d[4+cc%4],d[cc%4]};
                            want=code==1 ? 12'hfa0 : code==2 ? 12'h0bf : code==3 ? 12'hf0b : 12'h445;
                            if({r,g,b}!==want) $fatal(1,"player-car pixel %0d,%0d: colour %h, PROM code %0d",dut.x,dut.y,{r,g,b},code);
                            if(code!=0) car_pixels=car_pixels+1;
                        end
                        $fdisplay(fp,"%0d %0d %0d",r*17,g*17,b*17);
                        pixels=pixels+1;
                    end else if({r,g,b}!==0) $fatal(1,"video outside active raster");
                end
            end
            $fclose(fp);
            if(mode==0 && car_pixels!=351) $fatal(1,"player-car test shows %0d car pixels",car_pixels);
        end
    endtask
    initial begin
        if(!$value$plusargs("ROM=%s",path) || !$value$plusargs("OUT=%s",outdir)) $fatal(1,"missing ROM/OUT");
        $readmemh(path,expected);
        repeat(4) @(negedge clk);
        rom=1;
        // Hold the game in reset throughout the transfer, as JTFRAME does.
        for(n=0;n<8800;n=n+1) begin
            @(negedge clk); wa=n; wd=expected[n]; wr=1;
        end
        @(negedge clk); wr=0; rom=0; rst=0;
        repeat(3) @(negedge clk);
        if(!dut.loaded || dut.load_error) $fatal(1,"download failed while in reset");
        status[15:13]=1;    // the page buttons act on the PROM diagnostic
        repeat(3) @(negedge clk);
        for(k=1;k<=20;k=k+1) begin
            button(4);
            if(dut.selected!==k%20) $fatal(1,"next-button/held-button/wrap failure");
        end
        button(5);
        if(dut.selected!==19) $fatal(1,"previous-button wrap failure");
        capture(1);
        capture(2);
        capture(0);
        // Road and scenery: S-100 code 0 (B1 once), then three frames, the last
        // one captured; the PROM routing is checked at every clock.
        status[15:13]=3;
        reset_game();
        button(4);
        if(dut.s100!==4'hf) $fatal(1,"S-100 code changed before the end of VS");
        scen_check=1;
        repeat(2) begin
            @(posedge vs); @(negedge vs);
        end
        if(dut.s100!==4'd0) $fatal(1,"B1 did not select S-100 code 0");
        capture(3);
        // The next frame with IC66 read as a NAND (display 4)
        status[15:13]=4;
        @(posedge vs); @(negedge vs);
        capture(4);
        status[15:13]=3;
        scen_check=0;
        if(dut.u_scenery.busy===1'bx) $fatal(1,"road and scenery logic unknown");
        $display("PASS JTFRAME game: download during reset, reset retention, 20-page controls, five 360x240 frames (PROM bits, timing grid, player-car test, road and scenery with IC66 as AND and as NAND), pixel/PROM alignment, PR127 car at x=164..195 y=104..135, PR-133..PR-137 routing and the same addresses from both IC66 copies (%0d reads), silent audio, idle SDRAM, zero debug_view",scen_reads);
        $finish;
    end
endmodule
