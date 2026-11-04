"""The patched hps_io (scripts/mister_overlay.py) against Main's 0x46 packets.
Usage: python scripts/test_hps_trigger.py JTFRAME_DIR [iverilog-directory]
"""
# SPDX-License-Identifier: GPL-3.0-or-later
import pathlib, subprocess, sys, tempfile
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parent))
from mister_overlay import patch_hps_io
jt=pathlib.Path(sys.argv[1]).resolve()
bin=pathlib.Path(sys.argv[2]) if len(sys.argv)>2 else pathlib.Path('.')
bench=r"""
`timescale 1ns/1ps
module tb;
reg clk=0; always #5 clk=~clk;
reg [15:0] din=0; reg strobe=0, enable=0;
wire [48:0] bus;
assign bus[31:16]=din; assign bus[33]=strobe; assign bus[34]=enable; assign bus[35]=1'b0;
wire [15:0] r0,r1,r2,r3,r4,r5,l3;
hps_io #(.STRLEN(8),.CONF_STR("MONACOGP"),.CONF_STR_BRAM(0),.PS2DIV(32),.WIDE(0),.BLKSZ(1)) dut(
  .clk_sys(clk),.HPS_BUS(bus),.joystick_r_analog_0(r0),.joystick_r_analog_1(r1),.joystick_r_analog_2(r2),
  .joystick_r_analog_3(r3),.joystick_r_analog_4(r4),.joystick_r_analog_5(r5),.joystick_l_analog_3(l3),
  .ioctl_wait(1'b0),.status_menumask(16'd0),.status_in(128'd0),.status_set(1'b0),.info_req(1'b0),.info(8'd0),
  .ioctl_din(8'd0),.sd_lba(),.sd_rd(1'b0),.sd_wr(1'b0),.sd_blk_cnt(),.sd_buff_din(),.TIMESTAMP(),.ps2_kbd_led_status(3'd0),
  .ps2_kbd_led_use(3'd0));
task word(input [15:0] w); begin @(negedge clk); din=w; strobe=1; @(negedge clk); strobe=0; end endtask
task start; begin @(negedge clk); enable=1; end endtask
task stop; begin @(negedge clk); enable=0; repeat(2) @(negedge clk); end endtask
initial begin
  repeat(4) @(negedge clk);
  if(r3!==16'h0) $fatal(1,"triggers not released at power-up: %h",r3);
  start; word(16'h46); word(0); word(16'hC040); stop;
  if(r3!==16'hC040) $fatal(1,"player 1 {RT,LT}: %h",r3);
  start; word(16'h46); word(1); word(16'h1234); stop;
  if(r3!==16'hC040) $fatal(1,"player 2 reached player 1's triggers: %h",r3);
  start; word(16'h46); word(0); word(16'hFF00); word(16'h1111); word(16'h2222); stop;
  if(r3!==16'hFF00) $fatal(1,"extra words were taken: %h",r3);
  start; word(16'h3d); word(3); word(16'h5555); stop;
  if(r3!==16'hFF00) $fatal(1,"player 4's right stick reached the triggers: %h",r3);
  start; word(16'h3d); word(0); word(16'h8877); stop;
  if(r0!==16'h8877 || r3!==16'hFF00) $fatal(1,"player 1's right stick: %h %h",r0,r3);
  $display("PASS hps_io 0x46: {RT, LT} of player 1, power-up, other players, extra words, right stick"); $finish;
end
endmodule
"""
with tempfile.TemporaryDirectory() as temp:
    temp=pathlib.Path(temp)
    (temp/'hps_io_atrig.sv').write_text(patch_hps_io((jt/'target/mister/hdl/sys/hps_io.sv').read_text()))
    (temp/'tb.v').write_text(bench)
    subprocess.run([str(bin/'iverilog'),'-g2012','-s','tb','-o',str(temp/'sim'),str(temp/'tb.v'),str(temp/'hps_io_atrig.sv')],check=True)
    r=subprocess.run([str(bin/'vvp'),str(temp/'sim')],check=True,text=True,capture_output=True)
    print(r.stdout,end='')
    if 'PASS' not in r.stdout: raise SystemExit(1)
