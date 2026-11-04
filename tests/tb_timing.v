// SPDX-License-Identifier: GPL-3.0-or-later
`timescale 1ns/1ps
module tb_timing;
    reg clk=0, rst=1, run=0;
    always #20 clk=~clk;
    wire [8:0] h,v,x,y,hp,vp,rh,rv;
    wire hb,vb,hs,vs,rhb,rvb,rhs,rvs;
    jtmonacogp_timing dut(clk,rst,1'b1,h,v,hb,vb,hs,vs,x,y,hp,vp);
    sheet_e_reference refboard(clk & run,run,rh,rv,rhb,rvb,rhs,rvs);
    integer n,active_pixels=0,hs_pixels=0,vs_pixels=0;
    integer hblank_pixels=0,vblank_pixels=0;
    integer last_h=-1;
    initial begin
        repeat(3) @(negedge clk);
        rst=0; run=1;
        // Allow reference startup to settle, then compare complete settled states.
        // V is checked as well as sync: no linear counter can hide a wrong reload.
        for(n=0;n<456*264*3;n=n+1) begin
            @(posedge clk); #18;
            if ({h,v,hb,vb,hs,vs} !== {rh,rv,rhb,rvb,rhs,rvs})
                $fatal(1,"sheet E mismatch pixel %0d: DUT H=%h V=%h HB=%b HS=%b VS=%b; ref H=%h V=%h HB=%b HS=%b VS=%b",n,h,v,hb,hs,vs,rh,rv,rhb,rhs,rvs);
            if (last_h>=0 && hp != (last_h==455 ? 0 : last_h+1))
                $fatal(1,"horizontal period/sequence mismatch");
            last_h=hp;
            if (!hb && !vb) begin
                active_pixels=active_pixels+1;
                if (x>=360 || y>=240) $fatal(1,"active coordinate out of bounds");
            end
            if(hs) hs_pixels=hs_pixels+1;
            if(vs) vs_pixels=vs_pixels+1;
            if(hb) hblank_pixels=hblank_pixels+1;
            if(vb) vblank_pixels=vblank_pixels+1;
        end
        if(active_pixels!=3*360*240 || hs_pixels!=3*264*32 ||
           vs_pixels!=3*456*4 || hblank_pixels!=3*264*96 ||
           vblank_pixels!=3*456*24) $fatal(1,"incorrect raster geometry");
        $display("PASS timing: 361152 pixels match pin-connected TTL reference; 456x264 total, 360x240 active, HS=32 pixels, VS=4 lines");
        $finish;
    end
endmodule
