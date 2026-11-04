#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run the pin-wired D-6/D-7 reference (spice/d67_cars.cir) through its
test scenario and store the waveforms, so that d67_check.py can compare the
stepped model with it. Needs ngspice (with XSPICE) and numpy.

The scenario, from power-on (every capacitor at 0 V, `uic`, the supplies
rising over the first millisecond), 3 s, R190 as on the board (6.8K):
  0.00-0.30 s  S-ACCE code 2 (B C D = 0 1 0), no other car
  0.30-0.50 s  code 2 with /F-SOUND pulses: IC56 blocks the triggers
  0.50-2.00 s  code 5 (1 0 1) with pulses: car 1 starts, car 2 follows
               once IC58 has run out
  2.00-2.60 s  code 7 (R124 feed: faster ramps) with pulses
  2.60-3.00 s  code 7, no pulses: both ramps run on
/F-SOUND is low for one model step at the start of every frame
(59.4 Hz, docs/TIMING.md) while a car is present, so both the reference
and the model see the same pulses.
Usage: d67_reference.py OUTDIR [SECONDS]
"""
import sys
import time
from pathlib import Path
import numpy as np
import sound_parts as P
import spice_run as S

HERE=Path(__file__).resolve().parent
T_END=3.0
R190=6.8e3
LINE_HZ=14_305_000/2/456          # docs/TIMING.md: 7,152,500 / 456
FRAME_HZ=LINE_HZ/264
CODES=[(0.0,2),(0.50,5),(2.00,7)]     # (from, n = B + 2C + 4D)
PULSES=[(0.30,2.60)]
VECTORS=["feed","r14","r28","u1","u2","c292","c2913","q59a","q59b","q58",
         "con20","con19","con34","con33","cv1","cv2","r6","ref14",
         "xno1.con","xno2.con","xno1.o1","xno1.o2","xno1.o3","xno2.o1",
         "snd1","snd2","m20o","m19o","m34o","m33o","b1f","b1b","b2f","b2b","front"]
CURRENTS=["vmf#branch","vmb#branch"]
NAMES={"xno1.con":"con1","xno2.con":"con2","xno1.o1":"o1","xno1.o2":"o2",
       "xno1.o3":"o3","xno2.o1":"o1b"}

def code_at(t):
    n=0
    for t0,c in CODES:
        if t>=t0: n=c
    return n

def inputs(k):
    """The scenario's inputs at model step k: (S-ACCE code with bit 0 = A,
    /F-SOUND low during this step)."""
    t=k*P.DT
    n=code_at(t)
    low=False
    if any(a<=t<b for a,b in PULSES):
        f=int(t*FRAME_HZ)
        low=int(f/FRAME_HZ*P.TICK_HZ+0.999999)==k   # first step of the frame
    return n<<1,low

def write_stim(path,n):
    """For the Verilog testbench: the number of steps, then 'k code low' at
    step 0 and at every step where an input changes."""
    lines=[str(n)]; prev=None
    for k in range(n):
        v=inputs(k)
        if v!=prev: lines.append(f"{k} {v[0]} {int(v[1])}"); prev=v
    Path(path).write_text("\n".join(lines)+"\n")

def pwl(levels,edge=1e-7):
    pts=[(0.0,levels[0])]; prev=levels[0]
    for k,v in enumerate(levels):
        if v!=prev:
            t=k*P.DT; pts += [(t,prev),(t+edge,v)]; prev=v
    pts.append((len(levels)*P.DT,prev))
    return pts

def netlist(n):
    seq={"acc_b":[],"acc_c":[],"acc_d":[],"fsnd":[]}
    for k in range(n):
        code,low=inputs(k)
        for b,name in ((1,"acc_b"),(2,"acc_c"),(3,"acc_d")):
            seq[name].append(5.0 if code>>b&1 else 0.0)
        seq["fsnd"].append(0.0 if low else 5.0)
    body=f".title d67 reference\n.param r190={R190:g}\n"
    for name,levels in seq.items():
        pts=[f"{t:.9e} {v}" for t,v in pwl(levels)]
        body+=f"V{name} {name} 0 PWL(\n"
        body+="".join("+ "+" ".join(pts[i:i+8])+"\n" for i in range(0,len(pts),8))
        body+="+ )\n"
    return body+(HERE/"spice/d67_cars.cir").read_text()

SAVE_ONLY=True
def run(outdir,t_end=T_END):
    n=int(round(t_end*P.TICK_HZ))
    t0=time.time()
    x,d=S.run(netlist(n),f"tran 2u {t_end} 0 2u uic",
              [f"v({v})" for v in VECTORS]+CURRENTS,timeout=8*3600,save_only=SAVE_ONLY)
    arr={"t":np.array(x)}
    for v in VECTORS: arr[NAMES.get(v,v)]=np.array(d[f"v({v})"])
    arr["i_mf"]=np.array(d["vmf#branch"]); arr["i_mb"]=np.array(d["vmb#branch"])
    out=Path(outdir); out.mkdir(parents=True,exist_ok=True)
    np.savez_compressed(out/"d67_spice.npz",**arr)
    print(f"d67: {len(x)} points, ngspice {time.time()-t0:.0f} s")

if __name__=="__main__":
    run(sys.argv[1],float(sys.argv[2]) if len(sys.argv)>2 else T_END)
