// SPDX-License-Identifier: GPL-3.0-or-later
`timescale 1ns/1ps
module tb_cen;
    reg clk=0;
    always #5 clk=~clk;
    wire c14,c7;
    jtmonacogp_cen dut(.clk(clk),.cen14(c14),.cen7(c7));
    integer n,n14=0,n7=0,last=-1,spacing;
    initial begin
        repeat(2) @(negedge clk);
        // 4.8 million host clocks = 0.1s; expected counts are exact integers.
        for(n=0;n<4800000;n=n+1) begin
            @(posedge clk); #1;
            if(c14) n14=n14+1;
            if(c7) begin
                n7=n7+1;
                if(!c14) $fatal(1,"7 MHz enable without 14 MHz enable");
                if(last>=0) begin
                    spacing=n-last;
                    if(spacing!=6 && spacing!=7) $fatal(1,"unexpected fractional-enable gap %0d",spacing);
                end
                last=n;
            end
        end
        if(n14!=1430500 || n7!=715250) $fatal(1,"incorrect average frequency %0d/%0d",n14,n7);
        $display("PASS enables: 1430500 master and 715250 pixel enables per 4800000 host clocks; pixel gaps 6/7 clocks");
        $finish;
    end
endmodule
