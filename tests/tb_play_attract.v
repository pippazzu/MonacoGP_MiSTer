// SPDX-License-Identifier: GPL-3.0-or-later
// The connected sheets on the Pro board (jtmonacogp_game with dipsw[15] set,
// as the Pro MRA selects it; #89) with no
// coin: the display mode of pro/docs/SHEETS_B_C_D_PRO_LOGIC.md, as the
// picture shows it over 40 frames. FAST = 1 as in tests/tb_play_pro.v
// (one-shots / 1000, the 555 / 100), no sound board, no sheets I (rank
// part), J and K.
//
// The board has no reset for IC72, the display timer; it may power up
// either way. Started as the core resets it (both halves clear), the mode
// would begin at the second rise of Vs/512, 512 to 1024 frames on, which is
// too long to simulate here (tests/tb_motion_pro.v runs the timer itself).
// So the bench takes the other power-up state of IC72's second half, set
// (/DISPLAY low), by writing it once after reset. Nothing else is forced.
//
// Checked, from the logic note:
// - no unknown video; sheets A, F and N settled before edge 3, D and H
//   before edge 1;
// - no coin and no game: /COIN IN high, GAME low, so /DISPLAY stays low;
// - sheet B: the speed word MH loads is {SLOW, 0, 0, 0}; D-EXTEND and
//   /D-EXTEND are D-TIME and its inverse; /D-GAME is low;
// - sheet D: SLOW is high exactly while GRAVEL, SLIP, TUNNEL or BRIDGE is
//   set; the decoder sees {NOT(1QC XOR 1QD), 2QC, 2QB, 2QA} of Pro IC41;
// - the picture changes from frame to frame (the road scrolls), and the
//   road's edges (the M1V and M2V reload lines) move.
// Written: a log line per frame (a hash of the visible picture, Pro IC41,
// SLOW, D-TIME, the M1V and M2V reload lines) and the pictures
// attract-8.ppm .. attract-40.ppm, every eighth frame.
`timescale 1ns/1ps
module tb_play_attract;
    reg clk=0,rst=1,rom=0,wr=0;
    always #10.416666667 clk=~clk;                   // 48 MHz
    reg [25:0] wa=0;
    reg [7:0] wd=0;
    reg [31:0] status=0;
    wire pcen,p2cen,lhbl,lvbl,hs,vs;
    wire [3:0] r,g,b;
    wire signed [15:0] snd;
    wire [7:0] debug_view;
    wire [3:0] rd,write_bank;
    wire prog_we,prog_rd,busy;
    reg [7:0] expected[0:8799];
    reg [1023:0] path,outdir;
    localparam integer FRAMES = 40;
    `include "tb_game_mem.vh"
    // The Pro board is selected as the Pro MRA does on MiSTer (#89): PRO = 0
    // and the hidden switch bit dipsw[15] set (bit 14, RAM RESET, off).
    jtmonacogp_game #(.FAST(1),.SOUND(0),.RANK(0),.PRO(0)) dut(
`include "tb_game_mem_ports.vh"
        .clk(clk),.rst(rst),.rst24(rst),.clk24(clk),.rst96(rst),.clk96(clk),
        .pxl_cen(pcen),.pxl2_cen(p2cen),.red(r),.green(g),.blue(b),
        .LHBL(lhbl),.LVBL(lvbl),.HS(hs),.VS(vs),
        .cab_1p(4'hf),.coin(4'hf),.joystick1(6'h3f),.joystick2(6'h3f),
        .joystick3(6'h3f),.joystick4(6'h3f),.dial_x(2'b00),.dial_y(2'b00),
        .joyana_l1(16'd0),.joyana_l2(16'd0),.joyana_l3(16'd0),.joyana_l4(16'd0),
        .joyana_r1(16'd0),.joyana_r2(16'd0),.joyana_r3(16'd0),.joyana_r4(16'd0),
        .snd_en(6'h3f),.snd_vol(8'hff),.status(status),.dipsw(32'h0000_8000),
        .dip_pause(1'b1),.dip_test(1'b1),.service(1'b1),.tilt(1'b1),
        .dip_fxlevel(2'b00),.gfx_en(4'hf),.debug_bus(8'd0),.debug_view(debug_view),
        .ioctl_ram(1'b0),.ioctl_cart(1'b0),
        .snd(snd));

    // ---------------------------------------------------------------- checks
    reg [2:0] sr=0;
    always @(posedge clk) sr <= rst ? 3'd0 : {sr[1:0], pcen};
    wire e1 = sr[0], e3 = sr[2];
    reg running=0;
    integer frames=0, k, fp, px, py, same=0, slow_px=0, sp_loads=0, steps=0;
    integer m1v_line=-1, m2v_line=-1, m1v_last=-1, m2v_last=-1, edge_moves=0;
    reg [31:0] hash=0, hash_l=0;
    reg [7:0] dbgp_l=0;
    wire [7:0] dbgp = dut.u_scenery.dbg_pro;
    wire [3:0] q41a = dut.u_scenery.q41a, q41b = dut.u_scenery.q41b;
    wire [3:0] code_exp = {~(q41a[2] ^ q41a[3]), q41b[2:0]};
    always @(posedge clk) if (running) begin
        if (e1 && (dut.h_busy || dut.scen_busy)) $fatal(1,"sheet D or H still settling at edge 1");
        if (e3 && (dut.a_busy || dut.f_busy || dut.n_busy)) $fatal(1,"sheet A, F or N still settling at edge 3");
        if (pcen) begin
            if ((^{r,g,b,hs,vs,lhbl,lvbl}) === 1'bx) $fatal(1,"unknown video output");
            if (!dut.a_coin_in_n || dut.a_game) $fatal(1,"a coin or a game without a coin");
            if (dut.b_display_n) $fatal(1,"/DISPLAY high without a coin (frame %0d)", frames);
            if (dut.u_motion.spx !== {dut.d_slow, 3'b000}) $fatal(1,"speed word %b with SLOW %b", dut.u_motion.spx, dut.d_slow);
            if ({dut.b_d_extend, dut.b_d_extend_n, dut.b_d_game_n} !== {dut.d_time, ~dut.d_time, 1'b0})
                $fatal(1,"IC70 outputs %b with D-TIME %b", {dut.b_d_extend, dut.b_d_extend_n, dut.b_d_game_n}, dut.d_time);
            if (dut.d_slow !== |dut.scen_dbg[7:4]) $fatal(1,"SLOW %b with the four flip-flops at %b", dut.d_slow, dut.scen_dbg[7:4]);
            if (dut.u_scenery.code !== code_exp && dut.u_scenery.disp)
                $fatal(1,"decoder input %h, Pro IC41 %h", dut.u_scenery.code, dbgp);
            if (dut.d_slow) slow_px = slow_px + 1;
            if (dbgp != dbgp_l) steps = steps + 1;
            dbgp_l = dbgp;
            if (dut.v == 9'h1ff && dut.mh == 9'h1ff) sp_loads = sp_loads + 1;
            // The reload lines of M1V and M2V (R1, R2 low), the road's edges
            if (!dut.m1vld_n) m1v_line = dut.v;
            if (!dut.m2vld_n) m2v_line = dut.v;
            if (lhbl && lvbl) hash = hash * 32'd31 + {r, g, b};
        end
    end

    // ---------------------------------------------------------------- pictures
    reg [11:0] pic[0:359][0:239];
    always @(posedge clk) if (pcen && lhbl && lvbl) pic[dut.x][dut.y] <= {r,g,b};
    task write_pic(input integer num);
        begin
            fp = $fopen($sformatf("%0s/attract-%0d.ppm", outdir, num), "w");
            if (!fp) $fatal(1,"cannot open the picture file");
            $fwrite(fp, "P3\n360 240\n255\n");
            for (py = 0; py < 240; py = py + 1)
                for (px = 0; px < 360; px = px + 1)
                    $fwrite(fp, "%0d %0d %0d\n", pic[px][py][11:8]*17, pic[px][py][7:4]*17,
                            pic[px][py][3:0]*17);
            $fclose(fp);
        end
    endtask

    always @(negedge vs) if (running) begin
        frames = frames + 1;
        if (frames > 1 && hash == hash_l) same = same + 1;
        if (frames > 1 && (m1v_line != m1v_last || m2v_line != m2v_last)) edge_moves = edge_moves + 1;
        $display("  frame %0d: picture hash %h; /DISPLAY %b; Pro IC41 %h (code %h); SLOW %b; D-TIME %b; M1V, M2V reload lines %h, %h",
                 frames, hash, dut.b_display_n, dbgp, code_exp, dut.d_slow, dut.d_time, m1v_line, m2v_line);
        if (frames % 8 == 0) write_pic(frames);
        hash_l = hash; hash = 0;
        m1v_last = m1v_line; m2v_last = m2v_line;
        $fflush;
    end

    initial begin
        if (!$value$plusargs("ROM=%s",path) || !$value$plusargs("OUT=%s",outdir)) $fatal(1,"missing ROM/OUT");
        $readmemh(path,expected);
        status[15:13] = 5;
        repeat(4) @(negedge clk);
        rom=1;
        for (k=0;k<8800;k=k+1) begin
            @(negedge clk); wa=k; wd=expected[k]; wr=1;
        end
        @(negedge clk); wr=0; rom=0; rst=0;
        // IC72's other power-up state: its second half set, /DISPLAY low
        @(negedge clk); dut.u_motion.q72b = 1'b1;
        running=1;
        wait (frames == FRAMES);
        running = 0;
        $display("PASS play_attract (Pro board, no coin, /DISPLAY low): %0d frames", frames);
        $display("  frames with the same picture as the frame before %0d; frames where the road's edges moved %0d; MH speed loads %0d; Pro IC41 changes %0d; SLOW high %0d pixels",
                 same, edge_moves, sp_loads, steps, slow_px);
        if (same > FRAMES / 4) $fatal(1,"the picture stood still in %0d frames", same);
        if (edge_moves == 0) $fatal(1,"the road's edges never moved");
        if (steps == 0) $fatal(1,"Pro IC41 never counted");
        $finish;
    end
endmodule
