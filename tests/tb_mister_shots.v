// SPDX-License-Identifier: GPL-3.0-or-later
// Replays the boot-test button and OSD sequence on the game
// and writes every active frame of the capture windows as raw RGB, for
// comparison with MiSTer screenshots (scripts/mister_screens.py).
`timescale 1ns/1ps
module tb_mister_shots;
    reg clk=0,rst=1,rom=0,wr=0;
    always #10.4166667 clk=~clk;
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
    reg [7:0] proms[0:8799];
    reg [1023:0] path,outfile;
    integer n,k,fp,frames_out=0;
    reg capturing=0;
    reg [7:0] tag=0;
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

    // Frame writer: one record = tag byte + 360*240*3 bytes, written only for
    // frames that start (x=0,y=0) while capturing is set.
    reg infr=0;
    integer px=0;
    always @(posedge clk) if(pcen && lhbl && lvbl) begin
        if(dut.x==0 && dut.y==0) begin
            infr = capturing;
            px = 0;
            if(infr) $fwrite(fp,"%c",tag);
        end
        if(infr) begin
            $fwrite(fp,"%c%c%c",r*8'd17,g*8'd17,b*8'd17);
            px = px + 1;
            if(px==360*240) begin infr=0; frames_out=frames_out+1; end
        end
    end

    integer vsn=0;
    reg vsl=0;
    always @(posedge clk) if(pcen) begin vsl<=vs; if(vsl && !vs) vsn<=vsn+1; end
    task wait_frames(input integer nf);
        integer s; begin s=vsn; while(vsn<s+nf) @(posedge clk); end
    endtask
    // A button held for 6 frames, about as long as a quick press.
    task press(input integer bitno);
        begin
            @(negedge clk); joy[bitno]=0;
            wait_frames(6);
            @(negedge clk); joy[bitno]=1;
        end
    endtask
    task grab(input [7:0] t, input integer nf);
        begin
            @(negedge clk); tag=t; capturing=1;
            wait_frames(nf+1);
            @(negedge clk); capturing=0;
            wait_frames(1);
        end
    endtask

    initial begin
        if(!$value$plusargs("ROM=%s",path) || !$value$plusargs("OUT=%s",outfile))
            $fatal(1,"missing ROM/OUT");
        $readmemh(path,proms);
        fp=$fopen(outfile,"wb");
        repeat(4) @(negedge clk);
        rom=1;
        for(n=0;n<8800;n=n+1) begin
            @(negedge clk); wa=n; wd=proms[n]; wr=1;
        end
        @(negedge clk); wr=0; rom=0; rst=0;
        if(!dut.loaded) $fatal(1,"not loaded");
        // Player-car test, default Display option. The order of the 21 October
        // screenshots: normal, then
        // button 2 (previous) four times: explosion, accident, slide, normal.
        wait_frames(120);
        grab(8'd0,64);
        for(k=1;k<=4;k=k+1) begin
            press(5);
            wait_frames(120);
            grab(k[7:0],64);
        end
        // PROM bits: PROM 0, then button 1 (next) through all 20.
        status[14:13]=2'd1;
        wait_frames(10);
        grab(8'd20,2);
        for(k=1;k<20;k=k+1) begin
            press(4);
            wait_frames(10);
            grab(8'd20+k[7:0],2);
        end
        // Timing grid, PROM 19 still selected.
        status[14:13]=2'd2;
        wait_frames(10);
        grab(8'd40,4);
        $fclose(fp);
        $display("DONE %0d frames",frames_out);
        $finish;
    end
endmodule
