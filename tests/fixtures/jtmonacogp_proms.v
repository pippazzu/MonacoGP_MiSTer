// SPDX-License-Identifier: GPL-3.0-or-later
// Separate synchronous memories allow independent addresses for future circuits.
module jtmonacogp_prom #(
    parameter integer AW = 9,
    parameter integer BASE = 0
)(
    input clk,
    input [AW-1:0] addr,
    output reg [7:0] q,
    input wr,
    input [25:0] wr_addr,
    input [7:0] wr_data
);
    reg [7:0] mem [0:(1<<AW)-1];
    always @(posedge clk) begin
        q <= mem[addr];
        // All banks have power-of-two sizes and aligned BASE addresses.
        if (wr && wr_addr[25:AW] == BASE[25:AW])
            mem[wr_addr[AW-1:0]] <= wr_data;
    end
endmodule

module jtmonacogp_proms(
    input clk,
    input [179:0] addr,
    output [159:0] q,
    input ioctl_rom, ioctl_wr,
    input [25:0] ioctl_addr,
    input [7:0] ioctl_dout,
    output reg loaded = 0,
    output reg load_error = 0,
    output reg [13:0] bytes_loaded = 0
);
    wire wr = ioctl_rom && ioctl_wr;
    genvar k;
    generate
        for (k=0; k<17; k=k+1) begin: graphics
            jtmonacogp_prom #(.BASE(k*512)) u_prom(
                .clk(clk), .addr(addr[k*9+:9]), .q(q[k*8+:8]),
                .wr(wr), .wr_addr(ioctl_addr), .wr_data(ioctl_dout));
        end
        for (k=17; k<20; k=k+1) begin: small_proms
            jtmonacogp_prom #(.AW(5), .BASE(8704+(k-17)*32)) u_prom(
                .clk(clk), .addr(addr[k*9+:5]), .q(q[k*8+:8]),
                .wr(wr), .wr_addr(ioctl_addr), .wr_data(ioctl_dout));
        end
    endgenerate

    // Do NOT reset this with the game reset: JTFRAME asserts reset while loading.
    // Starting at address zero begins a new, sequential, 8,800-byte transaction.
    // CRC validation is performed by the ROM preparation tool/MRA, not in FPGA.
    always @(posedge clk) if (wr) begin
        if (ioctl_addr == 0) begin
            bytes_loaded <= 1;
            load_error <= 0;
            loaded <= 0;
        end else if (!load_error && ioctl_addr == {12'd0,bytes_loaded}
                     && ioctl_addr < 26'd8800) begin
            bytes_loaded <= bytes_loaded + 14'd1;
            if (ioctl_addr == 26'd8799) loaded <= 1;
        end else begin
            loaded <= 0;
            load_error <= 1;
        end
    end
endmodule
