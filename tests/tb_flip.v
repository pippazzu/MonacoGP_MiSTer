// SPDX-License-Identifier: GPL-3.0-or-later
// jtmonacogp_flip on the real sheet E raster. The input is a pattern that
// changes every frame. With flip high, every visible pixel shown in frame k
// must be the input of frame k-1 at the opposite position (359-x, 239-y);
// outside the visible area the output is black. With flip low the output is
// the input.
`timescale 1ns/1ps
module tb_flip;
    reg clk=0, rst=1, flip=1;
    always #10.416666667 clk=~clk;                   // 48 MHz
    wire pcen, p2cen;
    wire [8:0] h,v,x,y,hp,vp;
    wire hb,vb,hs,vs;
    // The build's pixel enable: one clock in six
    reg [2:0] cen_cnt = 0;
    always @(posedge clk) cen_cnt <= cen_cnt == 5 ? 3'd0 : cen_cnt + 3'd1;
    assign pcen = cen_cnt == 0;
    assign p2cen = cen_cnt == 0 || cen_cnt == 3;
    jtmonacogp_timing u_timing(.clk(clk),.rst(rst),.pxl_cen(pcen),.h(h),.v(v),
        .hblank(hb),.vblank(vb),.hs(hs),.vs(vs),.x(x),.y(y),.hpos(hp),.vpos(vp));
    integer frame = 0, checked = 0, passed = 0;
    // A pattern that depends on the position and the frame
    wire [11:0] pat = {x[3:0] ^ frame[3:0], y[3:0] + x[7:4], frame[1:0], y[5:4]};
    wire active = !hb && !vb;
    wire [11:0] out;
    wire [14:0] ram_wa, ram_ra;
    wire [47:0] ram_d, ram_q;
    wire  [1:0] ram_we;
    jtmonacogp_flip dut(.clk(clk),.rst(rst),.pxl_cen(pcen),.flip(flip),.active(active),
        .x(x),.y(y),.vb(vb),.rgb_in(pat),.rgb_out(out),
        .ram_wr_addr(ram_wa),.ram_rd_addr(ram_ra),.ram_data(ram_d),.ram_we(ram_we),.ram_q(ram_q));
    // The three buffers as mem.yaml makes them
    genvar b;
    generate for (b = 0; b < 3; b = b + 1) begin : g_buf
        jtframe_dual_ram16 #(.AW(15),.LATCH0_IN(0),.LATCH0_OUT(0),.LATCH1_IN(0),.LATCH1_OUT(0),.ENDIAN(0)) u_ram(
            .clk0(clk),.addr0(ram_wa),.data0(ram_d[b*16+:16]),.we0(ram_we),.q0(),
            .clk1(clk),.data1(16'd0),.addr1(ram_ra),.we1(2'd0),.q1(ram_q[b*16+:16]));
    end endgenerate
    reg [11:0] prev [0:359][0:239];
    reg [11:0] cur  [0:359][0:239];
    reg vb_l = 0;
    integer i, j;
    always @(posedge clk) if (pcen && !rst) begin
        // The output shown during this pixel (it is valid until the next enable)
        if (active) begin
            cur[x][y] <= pat;
            if (frame >= 2 && flip) begin
                if (out !== prev[359-x][239-y])
                    $fatal(1, "frame %0d x=%0d y=%0d: shown %h, expected %h", frame, x, y, out, prev[359-x][239-y]);
                checked = checked + 1;
            end
            if (!flip) begin
                if (out !== pat) $fatal(1, "pass-through: %h for %h", out, pat);
                passed = passed + 1;
            end
        end else if (out !== 12'd0 && flip) $fatal(1, "colour outside the visible area while flipped");
        vb_l <= vb;
        if (vb && !vb_l) begin
            frame = frame + 1;
            for (i = 0; i < 360; i = i + 1) for (j = 0; j < 240; j = j + 1) prev[i][j] = cur[i][j];
        end
    end
    initial begin
        repeat(4) @(negedge clk);
        rst = 0;
        wait (frame == 5);
        flip = 0;
        wait (frame == 6);
        $display("PASS flip: %0d flipped pixels from the frame before, %0d passed through", checked, passed);
        $finish;
    end
endmodule
