// SPDX-License-Identifier: GPL-3.0-or-later
// X1 frequency is provisional; see docs/TIMING.md. Enables, never fabric clocks.
//
// The enables run freely and have no reset, like the X1 oscillator they stand
// for. JTFRAME's jtframe_reset releases the game reset only after counting
// pxl_cen pulses, and with JTFRAME_PXLCLK undefined those pulses come from this
// module: a generator held in reset by the game reset never releases it.
module jtmonacogp_cen #(
    parameter integer CLK_HZ = 48000000,
    parameter integer X1_HZ  = 14305000
)(
    input      clk,
    output reg cen14 = 0,
    output reg cen7  = 0
);
    reg [31:0] phase = 0;
    reg half = 0;
    wire [32:0] sum = {1'b0, phase} + {1'b0,X1_HZ[31:0]};
    wire [32:0] remainder = sum - {1'b0,CLK_HZ[31:0]};
    always @(posedge clk) begin
        cen14 <= 0;
        cen7  <= 0;
        if (sum >= {1'b0,CLK_HZ[31:0]}) begin
            phase <= remainder[31:0];
            half  <= ~half;
            cen14 <= 1;
            cen7  <= half;
        end else phase <= sum[31:0];
    end
endmodule
