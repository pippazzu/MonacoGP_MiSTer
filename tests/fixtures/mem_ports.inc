`ifdef JTFRAME_SRAM
    output    [16:0]  sram_addr,
    output    [15:0]  sram_din,
    input     [15:0]  sram_dout,
    output            sram_wen,
    output    [ 1:0]  sram_dsn,
    input             sram_ok,
`endif
    input board_cen, // 14318181 = 42954544*1/3 Hz 

    // Audio channels
    
    // Sound output
`ifndef JTFRAME_STEREO
    output  signed [15:0] snd,
`else
    output  signed [15:0] snd_left, snd_right,
`endif
    output          sample,

    // Memory ports
`ifdef JTFRAME_SDRAM_XL
    input   [23:0]  prog_addr,
`elsif JTFRAME_SDRAM_LARGE
    input   [22:0]  prog_addr,
`else
    input   [21:0]  prog_addr,
`endif
    input   [ 7:0]  prog_data,
    input           prog_we,
    input   [ 1:0]  prog_ba,
`ifdef JTFRAME_SDRAM_XL
    input   [26:0]  ioctl_addr,
`else
    input   [25:0]  ioctl_addr,
`endif
    input           prom_we,
`ifdef JTFRAME_HEADER
    input           header,
`endif
`ifdef JTFRAME_IOCTL_RD
    input           ioctl_wr,
    output   [ 7:0] ioctl_din,
    input    [ 7:0] ioctl_dout, `endif
    input           ioctl_ram,
    input           ioctl_cart,
    // Explicit ports
    output   [8:1] score_addr,
    output   [15:0] score_din,
    input   [15:0] score_dout,
    output   [8:0] rom00_addr,
    output   [8:0] rom03_addr,
    output   [8:0] rom04_addr,
    input   [7:0] rom06_data,
    input   [15:0] flipread0_data,
    input   [15:0] flipread2_data,
    output    scoreptr_we,
    input   [7:0] rom00_data,
    output   [1:0] flip_wr_we,
    output   [1:0] score_we,
    input   [7:0] rom02_data,
    input   [7:0] rom04_data,
    output   [4:0] rom08_addr,
    output   [4:0] rom19_addr,
    input   [7:0] rom08_data,
    output   [8:0] rom12_addr,
    input   [7:0] rom13_data,
    output   [8:0] rom16_addr,
    output   [15:1] flip_rd_addr,
    input   [15:0] flipbuf1_dout,
    input   [15:0] flipbuf2_dout,
    input   [7:0] rom03_data,
    input   [7:0] rom16_data,
    output   [15:0] flipbuf2_din,
    output   [8:0] rom01_addr,
    input   [7:0] rom19_data,
    output   [15:0] flipbuf0_din,
    output   [8:0] rom07_addr,
    output   [8:0] rom13_addr,
    output   [8:0] rom17_addr,
    output   [15:1] flip_wr_addr,
    input   [15:0] flipbuf0_dout,
    input   [7:0] rom01_data,
    input   [7:0] rom09_data,
    output   [8:0] rom10_addr,
    output   [8:0] rom11_addr,
    output   [8:0] rom14_addr,
    input   [7:0] rom17_data,
    output   [8:0] rom06_addr,
    input   [7:0] rom15_data,
    output    scoreptr_addr,
    output   [7:0] scoreptr_din,
    input   [7:0] scoreptr_dout,
    input   [7:0] rom10_data,
    output   [8:0] rom18_addr,
    input   [7:0] rom05_data,
    input   [7:0] rom18_data,
    output   [15:0] flipbuf1_din,
    input   [7:0] rom07_data,
    output   [8:0] rom05_addr,
    output   [4:0] rom09_addr,
    input   [7:0] rom11_data,
    output   [8:0] rom15_addr,
    input   [15:0] flipread1_data,
    output   [8:0] rom02_addr,
    input   [7:0] rom12_data,
    input   [7:0] rom14_data,
    // Buses to BRAM

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
