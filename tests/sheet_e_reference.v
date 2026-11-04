// SPDX-License-Identifier: GPL-3.0-or-later
// Independent pin-connected, event-driven reference for sheet E.
// Delays only enforce settling order; these are NOT measured TTL delays.
`timescale 1ns/1ps
module ref_74161 #(parameter INIT=0, parameter RC_DELAY=1)(
    input cp, clr_n, load_n, ep, et, observe,
    input [3:0] d,
    output reg [3:0] q=INIT,
    output rco
);
    assign #(RC_DELAY) rco = et && (&q);
    always @(posedge cp or negedge clr_n) if(observe)
        if (!clr_n) q<=#1 0;
        else if (!load_n) q<=#1 d;
        else if (ep && et) q<=#1 q+4'd1;
endmodule
module ref_74107 #(parameter INIT=0)(
    input cp, clr_n, j, k, observe,
    output reg q=INIT,
    output q_n
);
    assign q_n=~q;
    always @(negedge cp or negedge clr_n) if(observe)
        if (!clr_n) q<=#1 0;
        else case ({j,k})
            2'b01: q<=#1 0;
            2'b10: q<=#1 1;
            2'b11: q<=#1 ~q;
            default: ;
        endcase
endmodule
module sheet_e_reference(
    input pixel_clk, observe,
    output [8:0] h,v,
    output hb,vb,hs,vs
);
    wire hc_lo,hc_hi,h_load_n,h8_n,hb_n;
    wire vc_lo,vc_hi,v_load_n,v8_n;
    wire hs_n=~hs;
    // IC108: P=T=1. IC107: P=IC108 carry; T=1.
    // observe suppresses time-zero X->0 events in this test fixture only.
    ref_74161 #(.INIT(8)) ic108(pixel_clk,1'b1,h_load_n,1'b1,1'b1,observe,
        {hb,3'b000},h[3:0],hc_lo);
    ref_74161 #(.INIT(9)) ic107(pixel_clk,1'b1,h_load_n,hc_lo,1'b1,observe,
        {1'b1,1'b0,hb_n,hb},h[7:4],hc_hi);
    ref_74107 ic116a(hc_hi,1'b1,hb_n,hb,observe,h[8],h8_n);
    // Scan: IC116 pins 8 (J), 10 (/CLR) and 11 (K) share the H8 node.
    ref_74107 ic116b(hc_hi,h[8],h[8],h[8],observe,hb,hb_n);
    assign #1 h_load_n=~(hc_lo & hc_hi & h[8]);
    assign #1 hs=hb & ~h[5] & h[6];
    // IC102: P=T=1. IC100: P=1; T=IC102 carry.
    ref_74161 #(.INIT(0)) ic102(hs_n,1'b1,v_load_n,1'b1,1'b1,observe,
        {v[8],3'b000},v[3:0],vc_lo);
    ref_74161 #(.INIT(1),.RC_DELAY(2)) ic100(hs_n,1'b1,v_load_n,1'b1,vc_lo,observe,
        {4{v8_n}},v[7:4],vc_hi);
    ref_74107 ic109a(vc_hi,1'b1,1'b1,1'b1,observe,v[8],v8_n);
    assign #1 v_load_n=~vc_hi;
    assign #1 vs=v[8] & ~v[3] & v[2];
    assign #1 vb=v[8] | (~|v[7:4]);
endmodule
