#!/usr/bin/env python3
"""Analog triggers for the MiSTer build, without touching the pinned JTFRAME.

MiSTer Main (a8ed7e9, 3 November 2026) sends the analog triggers to the core as
UIO_ATRIG 0x46: the player, then one word {RT, LT}. Template_MiSTer's hps_io
(e901a9f) receives it; the pinned JTFRAME's copy does not, and JTFRAME has no
wire from hps_io to the game for it. So the build compiles a patched copy of
the pinned hps_io.sv, made here from the pinned file, which puts player 1's
{RT, LT} on an output that already reaches the game: joystick_r_analog_3,
the game's joyana_r4. Monaco GP is a one-player game; player 4's right stick
is not used and is dropped.

Usage: python scripts/mister_overlay.py PROJECT_DIR JTFRAME_DIR
Writes hps_io_atrig.sv and two QIP files into PROJECT_DIR and points its
generated files.qip at them. Run it after project generation, before Quartus.
"""
# SPDX-License-Identifier: GPL-3.0-or-later
from pathlib import Path
import re
import sys

def patch_hps_io(text):
    """The pinned hps_io.sv with the receiver. Fails if the source has moved."""
    text=text.replace("\r\n","\n")
    edits=[
        ("\toutput reg [15:0] joystick_r_analog_3,\n",
         "\toutput reg [15:0] joystick_r_analog_3 = 0, // player 1's {RT, LT} (0x46), 0..255, released at power-up\n"),
        ("reg  [3:0] stick_idx;\n","reg  [3:0] stick_idx;\nreg  [7:0] atrig_idx;\n"),
        ("\t\t\t\t\t\t\t\t\t\t 3: joystick_r_analog_3 <= io_din;\n",""),
        ("\t\t\t\t// notify image selection\n",
         "\t\t\t\t// 0x46: player, {RT, LT}\n"
         "\t\t\t\t'h46: case(byte_cnt)\n"
         "\t\t\t\t\t\t\t1: atrig_idx <= io_din[7:0];\n"
         "\t\t\t\t\t\t\t2: if(atrig_idx == 0) joystick_r_analog_3 <= io_din;\n"
         "\t\t\t\t\t\tendcase\n\n"
         "\t\t\t\t// notify image selection\n"),
    ]
    for old,new in edits:
        if text.count(old)!=1: raise SystemExit(f"hps_io.sv: expected one match of {old!r}")
        text=text.replace(old,new)
    return text

def patch_cfgstr(hex_text,name="MonacoGP",version="1.0"):
    """The OSD's core name and version in JTFRAME's generated cfgstr.hex. JTFRAME
    takes them from CORENAME and the git commit, and CORENAME also names the
    project files and modules, which keep their jt prefix."""
    data=bytes(int(x,16) for x in hex_text.split())
    size=len(data)
    text=data.split(b"\0",1)[0].decode("ascii")
    text,n=re.subn(r"^[^;]*;",name+";",text,count=1)
    if n!=1: raise SystemExit("cfgstr: core name not found")
    text,n=re.subn(r"V,v[^;]*(;?)",lambda m:"V,v"+version+m[1],text)
    if n!=1: raise SystemExit("cfgstr: version not found")
    out=text.encode("ascii").ljust(size,b"\0")
    if len(out)!=size: raise SystemExit("cfgstr: too long")
    return "".join(f"{b:02X}"+("\n" if i%16==15 else " ") for i,b in enumerate(out))+"\n"

def main():
    project,jtframe=Path(sys.argv[1]),Path(sys.argv[2]).resolve()
    sysdir=jtframe/"target/mister/hdl/sys"
    (project/"hps_io_atrig.sv").write_text(patch_hps_io((sysdir/"hps_io.sv").read_text()),newline="\n")
    qip=(sysdir/"sys.qip").read_text()
    entry=re.compile(r"\[file join \$::quartus\(qip_path\) hps_io\.sv \]")
    if len(entry.findall(qip))!=1: raise SystemExit("sys.qip: hps_io.sv entry not found")
    qip=entry.sub('[file join "@HERE@" hps_io_atrig.sv ]',qip)
    qip=qip.replace("$::quartus(qip_path)",f'"{sysdir.as_posix()}"').replace("@HERE@",project.resolve().as_posix())
    (project/"sys_atrig_files.qip").write_text(qip,newline="\n")
    # The same library as JTFRAME's syn/sys.qip
    pinned=(jtframe/"target/mister/syn/sys.qip").read_text()
    if pinned.count('"../hdl/sys/sys.qip"')!=1: raise SystemExit("syn/sys.qip has changed")
    (project/"sys_atrig.qip").write_text(pinned.replace('"../hdl/sys/sys.qip"','"sys_atrig_files.qip"'),newline="\n")
    files=project/"files.qip"
    text=files.read_text(encoding="utf-8")
    text,n=re.subn(r"(?m)^(set_global_assignment -name QIP_FILE ).*/target/mister/syn/sys\.qip$",r"\1sys_atrig.qip",text)
    if n!=1: raise SystemExit("files.qip: sys.qip entry not found")
    files.write_text(text,encoding="utf-8",newline="\n")
    cfg=project/"cfgstr.hex"
    cfg.write_text(patch_cfgstr(cfg.read_text()),newline="\n")
    print("hps_io with analog triggers (0x46), OSD name and version in",project)

if __name__=="__main__": main()
