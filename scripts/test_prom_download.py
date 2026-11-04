"""Exercise the game's exact load tracker with the pinned JTFRAME downloader.
Usage: python scripts/test_prom_download.py JTFRAME_DIR [iverilog-directory] [8800-byte-hex]
Synthetic bytes cover every PROM address; no copyrighted ROM is required.
"""
import pathlib, re, subprocess, sys, tempfile
root = pathlib.Path(__file__).resolve().parents[1]
jt = pathlib.Path(sys.argv[1]).resolve()
bin = pathlib.Path(sys.argv[2]) if len(sys.argv)>2 else pathlib.Path('.')
source = (root/'cores/monacogp/hdl/jtmonacogp_game.v').read_text()
tracker = source[source.index('    // JTFRAME may hold'):source.index('    // Host clocks')]
widths = [int(w) for w in re.findall(r'addr_width: (\d+), data_width: 8, prom: true', (root/'cores/monacogp/cfg/mem.yaml').read_text())]
assert len(widths)==20
bench = """
module tb;
reg clk=0; always #5 clk=~clk;
reg ioctl_rom=0, ioctl_wr=0;
reg [26:0] ioctl_addr=0;
reg [7:0] ioctl_dout=0;
wire [21:0] prog_addr;
wire [15:0] prog_data;
wire prom_we;
reg loaded=0,load_error=0;
reg [13:0] bytes_loaded=0;
jtframe_dwnld #(.PROM_START(0),.SWAB(1)) dl(
.clk(clk),.ioctl_rom(ioctl_rom),.ioctl_wr(ioctl_wr),
.ioctl_addr(ioctl_addr),.ioctl_dout(ioctl_dout),.prog_addr(prog_addr),
.prog_data(prog_data),.prom_we(prom_we),.sdram_ack(1'b0),
.gfx4_en(1'b0),.gfx8_en(1'b0),.gfx16_en(1'b0),.gfx16b_en(1'b0),.gfx16c_en(1'b0));
""" + tracker
checks=[]; offset=0
for n, aw in enumerate(widths):
    bench += f"""
wire [{aw-1}:0] a{n}; wire w{n}; wire [7:0] d{n};
jtframe_ioctl_range #(.SDRAMW(22),.AW({aw}),.OFFSET({offset})) range{n}(
.clk(clk),.addr(prog_addr),.en(prom_we),.din(prog_data[7:0]),.addr_rel(a{n}),.inrange(w{n}),.dout(d{n}));
jtframe_prom #(.AW({aw})) ram{n}(.clk(clk),.cen(1'b1),.data(d{n}),.wr_addr(a{n}),.we(w{n}),.rd_addr({aw}'d0),.q());
"""
    checks.append(f'for(j=0;j<{1<<aw};j=j+1) if(ram{n}.mem[j] !== pattern(j+{offset})) $fatal(1,"PROM {n} byte %d mismatch",j);')
    offset += 1<<aw
assert offset==8800
bench += """
function [7:0] pattern(input integer a); pattern=(a ^ (a>>8) ^ (a>>4)); endfunction
task send(input integer a,input integer gap);
begin
@(negedge clk); ioctl_wr=1; ioctl_addr=a; ioctl_dout=pattern(a);
if(gap>0) begin @(negedge clk); ioctl_wr=0; repeat(gap-1) @(negedge clk); end
end endtask
task finish_load;
begin @(negedge clk); ioctl_wr=0; repeat(20) @(negedge clk); ioctl_rom=0; repeat(10) @(negedge clk); end
endtask
integer i,j,mode;
initial begin
repeat(5) @(negedge clk);
for(mode=0;mode<3;mode=mode+1) begin
ioctl_rom=1;
for(i=0;i<8800;i=i+1) send(i,mode==0 ? 0 : mode==1 ? 8 : (i%19)+1);
finish_load;
if(!loaded || load_error || bytes_loaded!=8800) $fatal(1,"valid load rejected mode=%d count=%d",mode,bytes_loaded);
"""+'\n'.join(checks)+"""
$display("PASS transfer mode %d: all 8800 bytes across 20 PROMs",mode);
end
ioctl_rom=1; send(0,8); send(2,8); finish_load;
if(!load_error || loaded) $fatal(1,"missing byte accepted");
ioctl_rom=1; for(i=0;i<8800;i=i+1) send(i,2); send(8800,2); finish_load;
if(!load_error || loaded) $fatal(1,"oversize accepted");
ioctl_rom=1; for(i=0;i<8800;i=i+1) send(i,2); finish_load;
if(load_error || !loaded) $fatal(1,"reload did not recover");
ioctl_rom=1; for(i=0;i<100;i=i+1) send(i,2); finish_load;
if(loaded) $fatal(1,"truncated load marked complete");
$display("PASS missing/extra/truncated bytes and recovery"); $finish;
end
endmodule
"""
if len(sys.argv)>3:
    rom = pathlib.Path(sys.argv[3]).resolve()
    assert len(rom.read_text().split()) == 8800
    bench = bench.replace('function [7:0] pattern(input integer a); pattern=(a ^ (a>>8) ^ (a>>4)); endfunction',
        f'reg [7:0] image[0:8799]; initial $readmemh("{rom.as_posix()}",image);\n'
        'function [7:0] pattern(input integer a); pattern=a<8800 ? image[a] : 0; endfunction')
with tempfile.TemporaryDirectory() as temp:
    tb=pathlib.Path(temp)/'tb.v'; tb.write_text(bench)
    out=pathlib.Path(temp)/'sim'
    subprocess.run([str(bin/'iverilog.exe'),'-g2012','-s','tb','-o',str(out),str(tb),str(jt/'hdl/sdram/jtframe_dwnld.v'),str(jt/'hdl/sdram/jtframe_ioctl_range.v'),str(jt/'hdl/ram/jtframe_prom.v')],check=True)
    subprocess.run([str(bin/'vvp.exe'),str(out)],check=True)
