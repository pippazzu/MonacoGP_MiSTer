// SPDX-License-Identifier: GPL-3.0-or-later
`timescale 1ns/1ps
module tb_proms;
    reg clk=0;
    always #5 clk=~clk;
    reg [179:0] addr=0;
    wire [159:0] q;
    reg rom=0,wr=0;
    reg [25:0] wa=0;
    reg [7:0] wd=0;
    wire loaded,error;
    wire [13:0] count;
    reg [7:0] expected[0:8799];
    reg [1023:0] path;
    integer n,k,base,ra;
    jtmonacogp_proms dut(clk,addr,q,rom,wr,wa,wd,loaded,error,count);
    task write_byte;
        input [25:0] a;
        input [7:0] d;
        begin
            @(negedge clk); wa=a; wd=d; wr=1;
            @(negedge clk); wr=0;
        end
    endtask
    initial begin
        if(!$value$plusargs("ROM=%s",path)) $fatal(1,"missing +ROM");
        $readmemh(path,expected);
        rom=1;
        // Missing and reordered bytes must not mark a partially loaded set ready.
        write_byte(0,0); write_byte(2,0);
        if(!error || loaded) $fatal(1,"out-of-order transfer accepted");
        write_byte(0,0); write_byte(1,0);
        if(error || loaded || count!=2) $fatal(1,"restart/partial-transfer failure");
        for(n=0;n<8800;n=n+1) write_byte(n,expected[n]);
        if(!loaded || error || count!=8800) $fatal(1,"valid transfer incomplete");
        rom=0;
        // Independent address buses: every bank reads a different address.
        // Every byte in every bank is checked against the loaded image.
        for(n=0;n<512;n=n+1) begin
            @(negedge clk);
            for(k=0;k<20;k=k+1) addr[k*9+:9]=(n+k*7)&511;
            @(posedge clk); #1;
            for(k=0;k<20;k=k+1) begin
                base=k<17 ? k*512 : 8704+(k-17)*32;
                ra=(n+k*7)&(k<17 ? 511 : 31);
                if(q[k*8+:8]!==expected[base+ra]) $fatal(1,"PROM %0d address %0d mismatch",k,ra);
            end
        end
        // Unselected ioctl traffic and oversized writes must not alias a PROM.
        write_byte(0,8'hac);
        rom=1; write_byte(26'h2000000,8'hac);
        if(loaded || !error) $fatal(1,"oversized stream accepted");
        @(negedge clk); addr=0;
        @(posedge clk); #1;
        if(q[7:0]!==expected[0]) $fatal(1,"out-of-range/unselected write aliased memory");
        $display("PASS PROMs: all 8800 loaded bytes, independent bank addresses, partial/reordered/restarted/oversized transfers");
        $finish;
    end
endmodule
