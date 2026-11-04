#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Compare MiSTer screenshots with the simulated game.

tests/tb_mister_shots.v replays the boot-test sequence (player-car test:
normal, then button 2 four times; PROM bits: PROM 0, then button 1 through all
20; timing grid) and writes every frame of each capture window. Each
screenshot, taken in that order and sorted by file name, must equal one of the
simulated frames of its screen exactly. Screenshots must be the native 360x240
ones (MiSTer saves those with the scaler at its native size). Needs Verilator 5
(VERILATOR) and Pillow; the simulation takes about 17 minutes.
"""
import argparse,os,shutil,subprocess,sys
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
W,H=360,240
REC=1+W*H*3
SEQ=[0,1,2,3,4]+[20+k for k in range(20)]+[40]
NAMES={0:"player-car test, normal",1:"player-car test, explosion",
       2:"player-car test, accident",3:"player-car test, slide",
       4:"player-car test, normal again",40:"timing grid"}
NAMES.update({20+k:f"PROM bits, PROM {k}" for k in range(20)})

def simulate(jtroot,rom,out):
    ver=os.environ.get("VERILATOR","verilator")
    if shutil.which(ver) is None: sys.exit(f"Executable unavailable: {ver}")
    obj=out/"obj_dir"
    hdl=sorted((ROOT/"cores/monacogp/hdl").glob("*.v"))
    subprocess.run([ver,"--binary","--timing","-O3","-Wno-fatal","-Wno-WIDTH","-Wno-lint",
                    "-I"+str(jtroot/"modules/jtframe/hdl/inc"),
                    "-DJTFRAME_BUTTONS=2","-DJTFRAME_COLORW=4",
                    "--top-module","tb_mister_shots","--Mdir",str(obj),
                    str(ROOT/"tests/tb_mister_shots.v")]+[str(h) for h in hdl],
                   check=True,stdout=subprocess.DEVNULL)
    frames=out/"frames.bin"
    subprocess.run([str(obj/"Vtb_mister_shots"),f"+ROM={rom}",f"+OUT={frames}"],check=True)
    return frames

def main():
    p=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("shots",type=Path,help="directory of the 26 screenshots")
    p.add_argument("--jtroot",type=Path,default=ROOT/"build/jtcores")
    p.add_argument("--rom",type=Path,default=ROOT/"build/roms/proms.hex")
    p.add_argument("--frames",type=Path,help="reuse a frames.bin from an earlier run")
    args=p.parse_args()
    shots=sorted(args.shots.glob("*.png"))
    if len(shots)!=len(SEQ): sys.exit(f"expected {len(SEQ)} screenshots, found {len(shots)}")
    out=ROOT/"build/mister-screens"
    out.mkdir(parents=True,exist_ok=True)
    frames=args.frames or simulate(args.jtroot.resolve(),args.rom.resolve(),out)
    data=frames.read_bytes()
    recs=[data[i:i+REC] for i in range(0,len(data)-REC+1,REC)]
    lines=[f"{len(recs)} simulated frames, {len({r[1:] for r in recs})} different\n"]
    fails=0
    for shot,tag in zip(shots,SEQ):
        im=Image.open(shot).convert("RGB")
        if im.size!=(W,H): sys.exit(f"{shot.name}: {im.size[0]}x{im.size[1]}, not native {W}x{H}")
        px=im.tobytes()
        cand=[r[1:] for r in recs if r[0]==tag]
        exact=sum(c==px for c in cand)
        if exact:
            lines.append(f"PASS {shot.name}: {NAMES[tag]}, equal to {exact} of {len(cand)} simulated frames\n")
            continue
        fails+=1
        best=min(sum(c[i:i+3]!=px[i:i+3] for i in range(0,len(px),3)) for c in cand)
        lines.append(f"FAIL {shot.name}: {NAMES[tag]}, closest simulated frame differs in {best} pixels\n")
    lines.append("All screenshots equal simulated frames.\n" if not fails else f"{fails} screenshots differ.\n")
    (out/"results.txt").write_text("".join(lines))
    print("".join(lines),end="")
    sys.exit(1 if fails else 0)

if __name__=="__main__": main()
