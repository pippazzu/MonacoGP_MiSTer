#!/usr/bin/env python3
"""Generate real JTFRAME MiSTer configuration, elaborate the game interface and
simulate the MiSTer reset, download and video path with the pinned JTFRAME modules.

It does not run Quartus or produce an RBF.
"""
# SPDX-License-Identifier: GPL-3.0-or-later
import argparse
from pathlib import Path
import os
import re
import shutil
import subprocess

ROOT=Path(__file__).resolve().parents[1]

# JTFRAME directories searched for modules (iverilog -y), as in jtframe_mister.sv's
# dependency tree.
BOARD_LIBS=["hdl","hdl/sdram","hdl/ram","hdl/video","hdl/video/crosshair","hdl/keyboard",
            "hdl/lightgun","hdl/clocking","hdl/debug","hdl/sound","hdl/cheat","target/mister/hdl"]
# Files that hold modules not named after the file, which -y cannot find.
BOARD_FILES=["hdl/keyboard/jt4701.v","hdl/keyboard/jtframe_beta_lock.v"]

def board_check(jtframe,out,iv,defines):
    """tests/tb_board.v: game reset release, PROM download and video timing through
    the pinned JTFRAME download, reset, sync and board modules. About seven minutes."""
    out.mkdir(parents=True,exist_ok=True)
    shutil.copy(jtframe/"bin/font0.hex",out)   # jtframe_font loads it with $readmemh
    cmd=iv+["-g2012","-Wall","-Wno-timescale","-I",str(jtframe/"hdl/inc")]
    cmd += ["-D"+d for d in defines]
    for lib in BOARD_LIBS: cmd += ["-y",str(jtframe/lib)]
    cmd += ["-Y",".v","-Y",".sv","-s","tb_board","-o",str(out/"board.vvp"),str(ROOT/"tests/tb_board.v")]
    cmd += [str(p) for p in sorted((ROOT/"cores/monacogp/hdl").glob("*.v"))]
    cmd += [str(jtframe/f) for f in BOARD_FILES]
    subprocess.run(cmd,check=True)
    vvp=os.environ.get("VVP","vvp")
    try:
        r=subprocess.run([vvp,"-n","board.vvp"],cwd=out,text=True,timeout=3600,
                         stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    except subprocess.TimeoutExpired:
        raise SystemExit("FAIL: board simulation did not finish within 3600 s")
    (out/"board.log").write_text(r.stdout)
    passed=[l for l in r.stdout.splitlines() if l.startswith("PASS JTFRAME board")]
    if r.returncode or len(passed)!=1: raise SystemExit(r.stdout+"FAIL: board simulation")
    return passed[0]+"\n"

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--jtroot",type=Path,default=ROOT/"build/jtcores")
    p.add_argument("--jtframe-exe",type=Path)
    args=p.parse_args()
    jtroot=args.jtroot.resolve()
    jtframe=jtroot/"modules/jtframe"
    out=ROOT/"build/jtframe"
    out.mkdir(parents=True,exist_ok=True)
    actual=subprocess.check_output(["git","-C",str(jtroot),"rev-parse","HEAD"],text=True).strip()
    if actual!=(ROOT/"UPSTREAM_REVISION").read_text().strip(): p.error("JTFRAME revision differs from pin")
    for source in (ROOT/"cores/monacogp").rglob("*"):
        if source.is_file():
            target=jtroot/"cores/monacogp"/source.relative_to(ROOT/"cores/monacogp")
            if not target.is_file() or target.read_bytes()!=source.read_bytes():
                p.error("Installed core is stale. Run setup_jtframe.py JTROOT --update")
    env=dict(os.environ,JTROOT=str(jtroot),JTFRAME=str(jtframe),
             CORES=str(jtroot/"cores"),MODULES=str(jtroot/"modules"),
             JTBIN=str(jtroot/"release"),ROM=str(jtroot/"rom"),MRA=str(jtroot/"release/mra"))
    exe=args.jtframe_exe.resolve() if args.jtframe_exe else out/"jtframe"
    if not args.jtframe_exe:
        subprocess.run([os.environ.get("GO","go"),"build","-o",str(exe),"."],
                       cwd=jtframe/"src/jtframe",env=env,check=True)
    def jt(*cmd):
        r=subprocess.run([str(exe),*cmd],cwd=out,env=env,text=True,capture_output=True,check=True)
        # Some upstream versions print a file-list error without failing the process.
        if r.stderr.strip(): raise SystemExit(r.stderr)
        return r.stdout
    macros=jt("cfgstr","monacogp","-t","mister","-o","quartus")
    (out/"macros.qsf").write_text(macros)
    jt("cfgstr","monacogp","-t","mister","-o","cfgstr")
    config=bytes.fromhex((out/"cfgstr.hex").read_text()).split(b"\0",1)[0].decode("ascii")
    (out/"cfgstr.txt").write_text(config)
    if "P2OD,Show Score & Time,On,Off" not in config or "P2OE,Show Gear,On,Off" not in config:
        raise SystemExit("Score overlay options missing from configuration")
    jt("files","syn","monacogp","-t","mister")
    qip=(out/"files.qip").read_text()
    for name in (ROOT/"cores/monacogp/hdl").glob("*.v"):
        if name.name not in qip: raise SystemExit(f"File absent from generated QIP: {name.name}")
    iv=[os.environ.get("IVERILOG","iverilog")]
    if os.environ.get("IVL_BASE"): iv += ["-B",os.environ["IVL_BASE"]]
    defines=re.findall(r'VERILOG_MACRO "([^"]*)"',macros)
    cmd=iv+["-g2012","-Wall","-Wno-timescale","-I",str(jtframe/"hdl/inc")]
    cmd += ["-D"+d for d in defines]
    cmd += ["-s","jtmonacogp_game","-o",str(out/"game-interface.vvp")]
    cmd += [str(p) for p in sorted((ROOT/"cores/monacogp/hdl").glob("*.v"))]
    subprocess.run(cmd,check=True)
    board=board_check(jtframe,out/"board",iv,defines)
    result=(f"PASS JTFRAME {actual}: real MiSTer macros, OSD configuration, source list, game-port elaboration.\n"
            f"{board}"
            "Quartus synthesis, fit, STA and hardware boot: not run by this check.\n")
    (out/"results.txt").write_text(result)
    print(result,end="")

if __name__=="__main__": main()
