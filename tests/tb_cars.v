// SPDX-License-Identifier: GPL-3.0-or-later
// Sheet H other cars, frame counter and divider. The RTL (jtmonacogp_cars.v)
// and the pin-wired reference (tests/sheet_h_reference.v) see the same
// stimulus on the real sheet E raster.
//
// - Every output and 69 internal state bits are compared for every pixel;
//   the RTL must settle before edge 1.
// - The reference's 7 MHz edge (f7) is the RTL's capture edge; the other
//   sheets' nets reach it 5 ns later, and f14 falls 30 and 90 ns after f7.
// - Directed checks, written here from the trace:
//   every divider period (load to load) is 456 pixels, except one started by
//       a load on line 1FF (/(V-CA x V8) low): 464 - L + m, L the PR-38 nibble
//       D7..D4 and m = 4 ACCE. D + 2 (ACCE. C . /SP. IRREG.) + ACCE. B (the
//       restart pause), unless L = 15;
//   the frame counter counts every fall of /VS;
//   at most one AREA line and at most one 367 enable are active; with none
//       enabled the strobe line is high and the /OTHER outputs are high.
// The stimulus stands in for sheets A, D, E, F, I and M; it is not gameplay.
// ACCE., SP. CONT., /SP. IRREG. and /EXT. 500 change at frame starts (line
// 1F4); side-line pulses, BRIDGE AP., the car pulses and their clear at
// random. FAST = 1 divides the one-shot capacitors by 1000.
`timescale 1ns/1ps
module tb_cars #(parameter integer FAST = 1, FRAMES = 40, PIC0 = 30, NPIC = 3,
                 parameter [31:0] SEED = 32'h4d4f4e48);
    reg clk=0, rst=1;
    always #10.416666667 clk=~clk;                   // 48 MHz
    localparam real CS = FAST ? 1.0e-3 : 1.0;
    function integer px123(input real c_pf);
        px123 = $rtoi(0.28*47.0*c_pf*CS*(1.0+0.7/47.0)*7.1525e-3 + 0.5);
    endfunction
    localparam integer N1 = px123(1.0e8), N2 = px123(2.2e8);

    // PR-38, PR-39, PR-132 as stored in the core (banks 17, 18 and 7 of
    // jtmonacogp_proms.v), written the way JTFRAME downloads the image.
    reg wr=0;
    reg [25:0] wa=0;
    reg [7:0] wd=0;
    reg [7:0] image[0:8799];
    reg [1023:0] path, outdir;
    wire [4:0] a38, a39;
    wire [8:0] a132;
    wire [7:0] q38, q39, q132;
    jtmonacogp_prom #(.AW(5),.BASE(8704)) u_pr38(.clk(clk),.addr(a38),.q(q38),.wr(wr),.wr_addr(wa),.wr_data(wd));
    jtmonacogp_prom #(.AW(5),.BASE(8736)) u_pr39(.clk(clk),.addr(a39),.q(q39),.wr(wr),.wr_addr(wa),.wr_data(wd));
    jtmonacogp_prom #(.BASE(3584)) u_pr132(.clk(clk),.addr(a132),.q(q132),.wr(wr),.wr_addr(wa),.wr_data(wd));

    wire pcen, p2cen;
    wire [8:0] h,v,x,y,hp,vp;
    wire hb,vb,hs,vs;
    jtmonacogp_cen u_cen(.clk(clk),.cen14(p2cen),.cen7(pcen));
    jtmonacogp_timing u_timing(.clk(clk),.rst(rst),.pxl_cen(pcen),.h(h),.v(v),
        .hblank(hb),.vblank(vb),.hs(hs),.vs(vs),.x(x),.y(y),.hpos(hp),.vpos(vp));
    wire cs_n = ~(&v[7:0] & v[8]);

    // ---------------- Stimulus (changes at the 7 MHz edge)
    reg l1=1, l2=1, r1=1, r2=1, rl=1, bridge=1, car_n=1, carcl=0, ext500_n=1, irreg_n=1, spcont=0;
    reg [3:0] acce=0;

    // ---------------- RTL
    wire d_vs2, d_vs4, d_vs8, d_vs16, d_vs32, d_vs64, d_car, d_body, d_tiar, d_fs, busy;
    wire [3:0] d_sp;
    wire [5:1] d_area;
    wire [68:0] d_dbg;
    jtmonacogp_cars #(.OS1A_PIXELS(N1),.OS1B_PIXELS(N1),.OS2A_PIXELS(N2),.OS2B_PIXELS(N2)) dut(
        .clk(clk),.rst(rst),.pxl_cen(pcen),
        .h6_n(~h[6]),.h8_n(~h[8]),.hs_n(~hs),.vs_n(~vs),.v8_n(~v[8]),.vca_v8_n(cs_n),
        .l1_side_n(l1),.l2_side_n(l2),.r1_side_n(r1),.r2_side_n(r2),.rl_side_n(rl),
        .bridge_ap(bridge),.car_sp_cont_n(car_n),.car_cont_cl(carcl),.ext500_n(ext500_n),
        .sp_irreg_n(irreg_n),.acce(acce),.sp_cont(spcont),
        .pr38_addr(a38),.pr39_addr(a39),.pr38_q(q38),.pr39_q(q39),.pr132_addr(a132),.pr132_q(q132),
        .vs2(d_vs2),.vs4(d_vs4),.vs8(d_vs8),.vs16(d_vs16),.vs32(d_vs32),.vs64(d_vs64),.sp(d_sp),
        .area(d_area),.other_car_n(d_car),.other_body_n(d_body),.other_tiar_n(d_tiar),.f_sound_n(d_fs),
        .dbg(d_dbg),.busy(busy));

    // ---------------- Pin-wired reference
    reg [2:0] sr=0;
    wire e1 = sr[0], e2 = sr[1], e3 = sr[2];
    reg f7=0, f14=0;
    // Snapshot of the inputs the RTL captures at edge 2, applied 5 ns after f7
    reg s_h6=1, s_h8=1, s_hs=1, s_vs=1, s_v8=1, s_cs=1, s_l1=1, s_l2=1, s_r1=1, s_r2=1, s_rl=1;
    reg s_bridge=1, s_car=1, s_carcl=0, s_ext=1, s_irreg=1, s_spcont=0;
    reg [3:0] s_acce=0;
    wire r_h6, r_h8, r_hs, r_vs, r_v8, r_cs, r_l1, r_l2, r_r1, r_r2, r_rl, r_bridge, r_car, r_carcl, r_ext, r_irreg, r_spcont;
    wire [3:0] r_acce;
    assign #5 {r_h6, r_h8, r_hs, r_vs, r_v8, r_cs, r_l1, r_l2, r_r1, r_r2, r_rl, r_bridge, r_car, r_carcl,
               r_ext, r_irreg, r_spcont, r_acce} =
              {s_h6, s_h8, s_hs, s_vs, s_v8, s_cs, s_l1, s_l2, s_r1, s_r2, s_rl, s_bridge, s_car, s_carcl,
               s_ext, s_irreg, s_spcont, s_acce};
    always @(posedge f7) begin
        f14 = 1; #30 f14 = 0; #30 f14 = 1; #30 f14 = 0;
    end
    wire r_vs2, r_vs4, r_vs8, r_vs16, r_vs32, r_vs64, r_car_n, r_body_n, r_tiar_n, r_fs;
    wire [3:0] r_sp;
    wire [5:1] r_area;
    wire [68:0] r_dbg;
    sheet_h_reference #(.OS1A_PIXELS(N1),.OS1B_PIXELS(N1),.OS2A_PIXELS(N2),.OS2B_PIXELS(N2)) reff(
        .f7(f7),.f14(f14),.h_h6_n(r_h6),.h_h8_n(r_h8),.h_hs_n(r_hs),.h_vs_n(r_vs),.h_v8_n(r_v8),.h_cs(r_cs),
        .h_l1_n(r_l1),.h_l2_n(r_l2),.h_r1_n(r_r1),.h_r2_n(r_r2),.h_rl_n(r_rl),.h_bridge(r_bridge),.h_car_n(r_car),
        .h_carcl(r_carcl),.h_ext500_n(r_ext),.h_irreg_n(r_irreg),.h_acce(r_acce),.h_spcont(r_spcont),
        .vs2(r_vs2),.vs4(r_vs4),.vs8(r_vs8),.vs16(r_vs16),.vs32(r_vs32),.vs64(r_vs64),.sp(r_sp),
        .area(r_area),.other_car_n(r_car_n),.other_body_n(r_body_n),.other_tiar_n(r_tiar_n),.f_sound_n(r_fs),
        .dbg(r_dbg));

    wire [87:0] d_vec = {d_vs2, d_vs4, d_vs8, d_vs16, d_vs32, d_vs64, d_sp, d_area, d_car, d_body, d_tiar, d_fs, d_dbg};
    wire [87:0] r_vec = {r_vs2, r_vs4, r_vs8, r_vs16, r_vs32, r_vs64, r_sp, r_area, r_car_n, r_body_n, r_tiar_n, r_fs, r_dbg};
    reg [87:0] r_snap;

    // ---------------- Checks and stimulus
    integer seed = SEED, pixels = 0, frames = 0, k, n, fp, sx, sy, hr, busy_max = 0, steps = 0;
    reg running = 0;
    integer last_load = -1, exp_period = 0, periods_456 = 0, periods_1ff = 0, periods_l15 = 0;
    integer vs_falls = 0, os_trig[0:3], latch_flips = 0, lit_car = 0, lit_body = 0, lit_tiar = 0, fs_edges = 0;
    integer loads_lo[7:9], two_enabled = 0;
    reg prev_vs_n = 1, prev_fs = 1;
    reg [2:0] prev_latches = 0;
    reg [3:0] prev_os = 0;
    // The whole line (hpos 0..455: the 360 visible pixels, then the 96
    // blanked ones) for the 240 visible lines.
    reg [23:0] pic [0:455][0:239];
    reg [8:0] cap_x = 0, cap_y = 0, out_x = 0, out_y = 0, cap_hp = 0, out_hp = 0;
    reg cap_hb = 1, out_hb = 1, cap_vb = 1, out_vb = 1;
    function [3:0] nib(input integer a); nib = image[8704 + a][7:4]; endfunction

    task write_pic(input integer num);
        begin
            fp = $fopen($sformatf("%0s/cars-%0d.ppm", outdir, num), "w");
            if (!fp) $fatal(1, "cannot open the picture file");
            // Upright, as the sheet B and D pictures: H down, V to the left.
            // Each line is drawn from hpos 424, where V counts (H = 1DF ->
            // 1E0), so the blanking is a grey band above (424..455) and below
            // (360..423) the visible 360, and an object crossing the line
            // start is drawn whole.
            $fwrite(fp, "P3\n%0d %0d\n255\n", 240*2, 456*2);
            for (sy = 0; sy < 456*2; sy = sy + 1) begin
                hr = (sy/2 + 424) % 456;
                for (sx = 0; sx < 240*2; sx = sx + 1)
                    $fwrite(fp, "%0d %0d %0d\n", pic[hr][239 - sx/2][23:16],
                            pic[hr][239 - sx/2][15:8], pic[hr][239 - sx/2][7:0]);
            end
            $fclose(fp);
        end
    endtask

    always @(posedge clk) begin
        sr <= rst ? 3'd0 : {sr[1:0], pcen};
        if (e1 && running) begin
            if (busy) $fatal(1, "RTL still settling at edge 1");
        end
        if (e2) steps = 0; else if (busy) steps = steps + 1;
        if (running && steps > busy_max) busy_max = steps;
        if (e2 && !rst) begin
            // The 7 MHz edge for the reference; its inputs follow 5 ns later
            r_snap <= r_vec;
            f7 <= 1;
            {s_h6, s_h8, s_hs, s_vs, s_v8, s_cs} <= {~h[6], ~h[8], ~hs, ~vs, ~v[8], cs_n};
            {s_l1, s_l2, s_r1, s_r2, s_rl} <= {l1, l2, r1, r2, rl};
            {s_bridge, s_car, s_carcl, s_ext, s_irreg, s_spcont, s_acce} <= {bridge, car_n, carcl, ext500_n, irreg_n, spcont, acce};
            {out_x, out_y, out_hp, out_hb, out_vb} <= {cap_x, cap_y, cap_hp, cap_hb, cap_vb};
            {cap_x, cap_y, cap_hp, cap_hb, cap_vb} <= {x, y, hp, hb, vb};
            // ---------------- divider period, on the RTL's settled nets of the ending pixel
            if (running && !dut.n80_8) begin
                if (last_load >= 0) begin
                    if (exp_period > 0 && pixels - last_load != exp_period)
                        $fatal(1, "divider period %0d, expected %0d", pixels - last_load, exp_period);
                    if (exp_period == 456) periods_456 = periods_456 + 1;
                    else if (exp_period > 0) periods_1ff = periods_1ff + 1;
                    else periods_l15 = periods_l15 + 1;
                end
                last_load = pixels;
                if (dut.i_cs) exp_period = 456;
                else begin
                    n = nib({dut.i_spcont, dut.i_acce});
                    exp_period = n == 15 ? 0 :
                        464 - n + 4*dut.i_acce[3] + 2*(dut.i_acce[2] & dut.i_irreg_n) + dut.i_acce[1];
                end
            end
        end else if (sr[2]) f7 <= 0;
        if (e3 && running) begin
            // edge 3: the RTL registered the pixel the snapshot holds
            pixels = pixels + 1;
            if (^d_vec === 1'bx || ^r_snap === 1'bx)
                $fatal(1, "unknown net at pixel %0d:\n RTL %b\n REF %b", pixels, d_vec, r_snap);
            if (d_vec !== r_snap)
                $fatal(1, "sheet H mismatch at pixel %0d (x=%0d y=%0d):\n RTL %b\n REF %b\n XOR %b",
                       pixels, out_x, out_y, d_vec, r_snap, d_vec ^ r_snap);
            // ---------------- directed checks
            n = d_area[1] + d_area[2] + d_area[3] + d_area[4] + d_area[5];
            if (n > 1) $fatal(1, "two AREA lines active: %b", d_area);
            n = !d_dbg[2] + !d_dbg[1] + !d_dbg[0];
            if (n > 1) two_enabled = two_enabled + 1;
            if (n > 1) $fatal(1, "two 367 buffers enabled");
            if (n == 0 && !d_dbg[3]) $fatal(1, "strobe line low with no buffer enabled");
            if (d_dbg[3] && !(d_car && d_body && d_tiar)) $fatal(1, "/OTHER output low with the strobe line high");
            // ---------------- coverage
            if (!d_car) lit_car = lit_car + 1;
            if (!d_body) lit_body = lit_body + 1;
            if (!d_tiar) lit_tiar = lit_tiar + 1;
            if (d_fs != prev_fs) fs_edges = fs_edges + 1;
            prev_fs = d_fs;
            if (d_dbg[18:16] != prev_latches) latch_flips = latch_flips + 1;
            prev_latches = d_dbg[18:16];
            for (k = 0; k < 4; k = k + 1) if (d_dbg[15-k] && !prev_os[3-k]) os_trig[k] = os_trig[k] + 1;
            prev_os = d_dbg[15:12];
            // Placeholder colours (sheet C mixes them): tyres over body over
            // the car outline. The blanked band is drawn with a grey cast.
            if (!out_vb && out_hp < 456 && out_y < 240) begin
                pic[out_hp][out_y] = !d_tiar ? 24'hffffff : !d_body ? 24'hffd000 : !d_car ? 24'hff3030 :
                                     d_area[1] ? 24'h202040 : d_area[2] ? 24'h203020 : d_area[3] ? 24'h302020 :
                                     d_area[4] ? 24'h303000 : d_area[5] ? 24'h203030 : 24'h000000;
                if (out_hb) pic[out_hp][out_y] = ((pic[out_hp][out_y] >> 1) & 24'h7f7f7f) + 24'h303030;
            end
        end
        if (pcen && running) begin
            // ---------------- next pixel's stimulus
            if (vs && prev_vs_n) vs_falls = vs_falls + 1;   // /VS falls as VS rises
            prev_vs_n = !vs;
            if (v == 9'h1f4 && h == 9'h0a0) begin
                frames = frames + 1;
                if (frames > PIC0 && frames <= PIC0 + NPIC) write_pic(frames - PIC0);
                for (sy = 0; sy < 456; sy = sy + 1) for (sx = 0; sx < 240; sx = sx + 1) pic[sy][sx] = 0;
                if (dut.fc !== vs_falls[11:0]) $fatal(1, "frame counter %0d after %0d falls of /VS", dut.fc, vs_falls);
                acce <= $random(seed);
                spcont <= $random(seed);
                irreg_n <= ($random(seed) & 3) != 0;
                ext500_n <= $random(seed);
            end
            // Side lines: pulses one line long at random lines
            if (h == 9'h0a0) begin
                l1 <= ($random(seed) & 31) != 0; l2 <= ($random(seed) & 63) != 0;
                r1 <= ($random(seed) & 31) != 0; r2 <= ($random(seed) & 63) != 0; rl <= ($random(seed) & 63) != 0;
            end
            if (($random(seed) & 32'h7fffffff) % 300000 == 0) bridge <= 0;
            else if (!bridge && ($random(seed) & 255) == 0) bridge <= 1;
            if (($random(seed) & 32'h7fffffff) % 40000 == 0) car_n <= ~car_n;
            if (($random(seed) & 32'h7fffffff) % 400000 == 0) carcl <= 1;
            else if (carcl && ($random(seed) & 63) == 0) carcl <= 0;
        end
    end

    initial begin
        if (!$value$plusargs("ROM=%s",path) || !$value$plusargs("OUT=%s",outdir))
            $fatal(1,"missing ROM/OUT");
        $readmemh(path,image);
        for (k = 0; k < 4; k = k + 1) os_trig[k] = 0;
        repeat(4) @(negedge clk);
        for (n=0;n<8800;n=n+1) begin
            @(negedge clk); wa=n; wd=image[n]; wr=1;
        end
        @(negedge clk); wr=0;
        repeat(4) @(negedge clk);
        rst=0;
        running=1;
        wait (frames == FRAMES);
        running = 0;
        $display("PASS cars%0s: %0d pixels over %0d frames match the pin-wired sheet H reference",
                 FAST ? " (one-shot capacitors / 1000)" : "", pixels, frames);
        $display("  divider periods: %0d of 456, %0d started on line 1FF (464 - L + m), %0d with L = 15 (not predicted); RTL settled within %0d steps",
                 periods_456, periods_1ff, periods_l15, busy_max);
        $display("  /VS falls %0d; direction latch changes %0d; one-shot pulses IC121 %0d/%0d, IC120 %0d/%0d",
                 vs_falls, latch_flips, os_trig[0], os_trig[1], os_trig[2], os_trig[3]);
        $display("  pixels active: /OTHER CAR %0d, /OTHER BODY %0d, /OTHER TIAR %0d; /F-SOUND changes %0d",
                 lit_car, lit_body, lit_tiar, fs_edges);
        $display("  reference hazards absorbed: IC80/position clocks %0d, IC87 CK %0d, IC81c %0d/%0d, IC75 CK %0d",
                 reff.ic90.fck.hazards, reff.ic87.fck.hazards, reff.ic81c.fs1.hazards, reff.ic81c.fr.hazards, reff.ic75b.fck.hazards);
        if (periods_1ff == 0 || latch_flips == 0 || lit_body == 0)
            $fatal(1, "coverage: a part of the circuit was not reached");
        $finish;
    end
endmodule
