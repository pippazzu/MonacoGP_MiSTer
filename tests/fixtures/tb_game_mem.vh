// Stand-in for the generated memory wrapper (jtmonacogp_game_sdram.v) in the
// game-level benches: PR35's clock enables, then the pinned JTFRAME downloader,
// address ranges and PROMs the wrapper uses. Include inside the bench's module;
// expects clk, rom, wr, wa and wd. The benches download proms.hex, which is in
// rom_manifest.json order, so the ranges follow that order and not the MRA's.
// tb_game_mem_ports.vh connects the game.
    reg  [2:0] tb_cnt = 0;
    always @(posedge clk) tb_cnt <= tb_cnt == 5 ? 3'd0 : tb_cnt + 3'd1;
    assign pcen = tb_cnt == 0;
    assign p2cen = tb_cnt == 0 || tb_cnt == 3;
    wire [21:0] tb_prog_addr;
    wire [15:0] tb_prog_data;
    wire        tb_prom_we;
    jtframe_dwnld #(.PROM_START(0),.SWAB(1)) u_tb_dwnld(
        .clk(clk),.ioctl_rom(rom),.ioctl_wr(wr),.ioctl_addr({1'b0,wa}),.ioctl_dout(wd),
        .prog_addr(tb_prog_addr),.prog_data(tb_prog_data),.prom_we(tb_prom_we),.sdram_ack(1'b0),
        .gfx4_en(1'b0),.gfx8_en(1'b0),.gfx16_en(1'b0),.gfx16b_en(1'b0),.gfx16c_en(1'b0));
    wire [8:0] rom00_addr, rom00_waddr; wire [7:0] rom00_data, rom00_dd; wire rom00_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(0)) u_tb_range_rom00(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom00_waddr),.inrange(rom00_we),.dout(rom00_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom00(.clk(clk),.cen(1'b1),.data(rom00_dd),.rd_addr(rom00_addr),
        .wr_addr(rom00_waddr),.we(rom00_we),.q(rom00_data));
    wire [8:0] rom01_addr, rom01_waddr; wire [7:0] rom01_data, rom01_dd; wire rom01_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(512)) u_tb_range_rom01(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom01_waddr),.inrange(rom01_we),.dout(rom01_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom01(.clk(clk),.cen(1'b1),.data(rom01_dd),.rd_addr(rom01_addr),
        .wr_addr(rom01_waddr),.we(rom01_we),.q(rom01_data));
    wire [8:0] rom02_addr, rom02_waddr; wire [7:0] rom02_data, rom02_dd; wire rom02_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(3072)) u_tb_range_rom02(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom02_waddr),.inrange(rom02_we),.dout(rom02_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom02(.clk(clk),.cen(1'b1),.data(rom02_dd),.rd_addr(rom02_addr),
        .wr_addr(rom02_waddr),.we(rom02_we),.q(rom02_data));
    wire [8:0] rom03_addr, rom03_waddr; wire [7:0] rom03_data, rom03_dd; wire rom03_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(1024)) u_tb_range_rom03(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom03_waddr),.inrange(rom03_we),.dout(rom03_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom03(.clk(clk),.cen(1'b1),.data(rom03_dd),.rd_addr(rom03_addr),
        .wr_addr(rom03_waddr),.we(rom03_we),.q(rom03_data));
    wire [8:0] rom04_addr, rom04_waddr; wire [7:0] rom04_data, rom04_dd; wire rom04_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(1536)) u_tb_range_rom04(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom04_waddr),.inrange(rom04_we),.dout(rom04_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom04(.clk(clk),.cen(1'b1),.data(rom04_dd),.rd_addr(rom04_addr),
        .wr_addr(rom04_waddr),.we(rom04_we),.q(rom04_data));
    wire [8:0] rom05_addr, rom05_waddr; wire [7:0] rom05_data, rom05_dd; wire rom05_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(2048)) u_tb_range_rom05(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom05_waddr),.inrange(rom05_we),.dout(rom05_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom05(.clk(clk),.cen(1'b1),.data(rom05_dd),.rd_addr(rom05_addr),
        .wr_addr(rom05_waddr),.we(rom05_we),.q(rom05_data));
    wire [8:0] rom06_addr, rom06_waddr; wire [7:0] rom06_data, rom06_dd; wire rom06_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(2560)) u_tb_range_rom06(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom06_waddr),.inrange(rom06_we),.dout(rom06_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom06(.clk(clk),.cen(1'b1),.data(rom06_dd),.rd_addr(rom06_addr),
        .wr_addr(rom06_waddr),.we(rom06_we),.q(rom06_data));
    wire [8:0] rom07_addr, rom07_waddr; wire [7:0] rom07_data, rom07_dd; wire rom07_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(3584)) u_tb_range_rom07(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom07_waddr),.inrange(rom07_we),.dout(rom07_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom07(.clk(clk),.cen(1'b1),.data(rom07_dd),.rd_addr(rom07_addr),
        .wr_addr(rom07_waddr),.we(rom07_we),.q(rom07_data));
    wire [4:0] rom08_addr, rom08_waddr; wire [7:0] rom08_data, rom08_dd; wire rom08_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(5),.OFFSET(8736)) u_tb_range_rom08(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom08_waddr),.inrange(rom08_we),.dout(rom08_dd));
    jtframe_prom #(.DW(8),.AW(5)) u_tb_prom_rom08(.clk(clk),.cen(1'b1),.data(rom08_dd),.rd_addr(rom08_addr),
        .wr_addr(rom08_waddr),.we(rom08_we),.q(rom08_data));
    wire [4:0] rom09_addr, rom09_waddr; wire [7:0] rom09_data, rom09_dd; wire rom09_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(5),.OFFSET(8704)) u_tb_range_rom09(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom09_waddr),.inrange(rom09_we),.dout(rom09_dd));
    jtframe_prom #(.DW(8),.AW(5)) u_tb_prom_rom09(.clk(clk),.cen(1'b1),.data(rom09_dd),.rd_addr(rom09_addr),
        .wr_addr(rom09_waddr),.we(rom09_we),.q(rom09_data));
    wire [8:0] rom10_addr, rom10_waddr; wire [7:0] rom10_data, rom10_dd; wire rom10_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(7680)) u_tb_range_rom10(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom10_waddr),.inrange(rom10_we),.dout(rom10_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom10(.clk(clk),.cen(1'b1),.data(rom10_dd),.rd_addr(rom10_addr),
        .wr_addr(rom10_waddr),.we(rom10_we),.q(rom10_data));
    wire [8:0] rom11_addr, rom11_waddr; wire [7:0] rom11_data, rom11_dd; wire rom11_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(8192)) u_tb_range_rom11(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom11_waddr),.inrange(rom11_we),.dout(rom11_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom11(.clk(clk),.cen(1'b1),.data(rom11_dd),.rd_addr(rom11_addr),
        .wr_addr(rom11_waddr),.we(rom11_we),.q(rom11_data));
    wire [8:0] rom12_addr, rom12_waddr; wire [7:0] rom12_data, rom12_dd; wire rom12_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(6656)) u_tb_range_rom12(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom12_waddr),.inrange(rom12_we),.dout(rom12_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom12(.clk(clk),.cen(1'b1),.data(rom12_dd),.rd_addr(rom12_addr),
        .wr_addr(rom12_waddr),.we(rom12_we),.q(rom12_data));
    wire [8:0] rom13_addr, rom13_waddr; wire [7:0] rom13_data, rom13_dd; wire rom13_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(7168)) u_tb_range_rom13(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom13_waddr),.inrange(rom13_we),.dout(rom13_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom13(.clk(clk),.cen(1'b1),.data(rom13_dd),.rd_addr(rom13_addr),
        .wr_addr(rom13_waddr),.we(rom13_we),.q(rom13_data));
    wire [8:0] rom14_addr, rom14_waddr; wire [7:0] rom14_data, rom14_dd; wire rom14_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(4096)) u_tb_range_rom14(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom14_waddr),.inrange(rom14_we),.dout(rom14_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom14(.clk(clk),.cen(1'b1),.data(rom14_dd),.rd_addr(rom14_addr),
        .wr_addr(rom14_waddr),.we(rom14_we),.q(rom14_data));
    wire [8:0] rom15_addr, rom15_waddr; wire [7:0] rom15_data, rom15_dd; wire rom15_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(5632)) u_tb_range_rom15(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom15_waddr),.inrange(rom15_we),.dout(rom15_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom15(.clk(clk),.cen(1'b1),.data(rom15_dd),.rd_addr(rom15_addr),
        .wr_addr(rom15_waddr),.we(rom15_we),.q(rom15_data));
    wire [8:0] rom16_addr, rom16_waddr; wire [7:0] rom16_data, rom16_dd; wire rom16_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(5120)) u_tb_range_rom16(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom16_waddr),.inrange(rom16_we),.dout(rom16_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom16(.clk(clk),.cen(1'b1),.data(rom16_dd),.rd_addr(rom16_addr),
        .wr_addr(rom16_waddr),.we(rom16_we),.q(rom16_data));
    wire [8:0] rom17_addr, rom17_waddr; wire [7:0] rom17_data, rom17_dd; wire rom17_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(4608)) u_tb_range_rom17(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom17_waddr),.inrange(rom17_we),.dout(rom17_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom17(.clk(clk),.cen(1'b1),.data(rom17_dd),.rd_addr(rom17_addr),
        .wr_addr(rom17_waddr),.we(rom17_we),.q(rom17_data));
    wire [8:0] rom18_addr, rom18_waddr; wire [7:0] rom18_data, rom18_dd; wire rom18_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(9),.OFFSET(6144)) u_tb_range_rom18(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom18_waddr),.inrange(rom18_we),.dout(rom18_dd));
    jtframe_prom #(.DW(8),.AW(9)) u_tb_prom_rom18(.clk(clk),.cen(1'b1),.data(rom18_dd),.rd_addr(rom18_addr),
        .wr_addr(rom18_waddr),.we(rom18_we),.q(rom18_data));
    wire [4:0] rom19_addr, rom19_waddr; wire [7:0] rom19_data, rom19_dd; wire rom19_we;
    jtframe_ioctl_range #(.SDRAMW(22),.AW(5),.OFFSET(8768)) u_tb_range_rom19(.clk(clk),.addr(tb_prog_addr),.en(tb_prom_we),
        .din(tb_prog_data[7:0]),.addr_rel(rom19_waddr),.inrange(rom19_we),.dout(rom19_dd));
    jtframe_prom #(.DW(8),.AW(5)) u_tb_prom_rom19(.clk(clk),.cen(1'b1),.data(rom19_dd),.rd_addr(rom19_addr),
        .wr_addr(rom19_waddr),.we(rom19_we),.q(rom19_data));
    wire [15:1] flip_wr_addr, flip_rd_addr;
    wire  [1:0] flip_wr_we;
    wire [15:0] flipbuf0_din, flipbuf1_din, flipbuf2_din, flipread0_data, flipread1_data, flipread2_data;
    jtframe_dual_ram16 #(.AW(15),.LATCH0_IN(0),.LATCH0_OUT(0),.LATCH1_IN(0),.LATCH1_OUT(0),.ENDIAN(0)) u_tb_flip0(
        .clk0(clk),.addr0(flip_wr_addr),.data0(flipbuf0_din),.we0(flip_wr_we),.q0(),
        .clk1(clk),.data1(16'd0),.addr1(flip_rd_addr),.we1(2'd0),.q1(flipread0_data));
    jtframe_dual_ram16 #(.AW(15),.LATCH0_IN(0),.LATCH0_OUT(0),.LATCH1_IN(0),.LATCH1_OUT(0),.ENDIAN(0)) u_tb_flip1(
        .clk0(clk),.addr0(flip_wr_addr),.data0(flipbuf1_din),.we0(flip_wr_we),.q0(),
        .clk1(clk),.data1(16'd0),.addr1(flip_rd_addr),.we1(2'd0),.q1(flipread1_data));
    jtframe_dual_ram16 #(.AW(15),.LATCH0_IN(0),.LATCH0_OUT(0),.LATCH1_IN(0),.LATCH1_OUT(0),.ENDIAN(0)) u_tb_flip2(
        .clk0(clk),.addr0(flip_wr_addr),.data0(flipbuf2_din),.we0(flip_wr_we),.q0(),
        .clk1(clk),.data1(16'd0),.addr1(flip_rd_addr),.we1(2'd0),.q1(flipread2_data));
    // mem.yaml's score and scoreptr, zero as on a freshly loaded FPGA
    wire [8:1] score_addr; wire [15:0] score_din; wire [1:0] score_we;
    reg  [15:0] score_dout; reg [15:0] tb_score[0:255];
    wire scoreptr_addr, scoreptr_we; wire [7:0] scoreptr_din; reg [7:0] scoreptr_dout = 8'd0, tb_scoreptr = 8'd0;
    integer tb_si;
    initial begin score_dout = 16'd0; for (tb_si = 0; tb_si < 256; tb_si = tb_si + 1) tb_score[tb_si] = 16'd0; end
    always @(posedge clk) begin
        if (&score_we) tb_score[score_addr] <= score_din;
        score_dout <= tb_score[score_addr];
        if (scoreptr_we) tb_scoreptr <= scoreptr_din;
        scoreptr_dout <= tb_scoreptr;
    end
