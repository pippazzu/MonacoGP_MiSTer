#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run the pin-wired D-4 sound-source reference (spice/d4_effects.cir)
through its test scenario and store the waveforms, so that d4_check.py can
compare the stepped model with it. Needs ngspice (with XSPICE) and numpy.

The scenario, from power-on (every capacitor at 0 V, `uic`), 2 s:
  0.05-0.30 s  a crash: T (IC60 a) high, so the explosion fires and the
               skid 555 runs (the 7432 ORs T in)
  0.45-0.80 s  off the road: the 555 alone
  0.85-1.32 s  EX.CP: V2 (3,922 Hz) gated by Vs/16 (8 frames on, 8 off)
  1.40-1.70 s  a second crash while the first one's rumble still decays
The S2688's output, the 74123 outputs, the 555's RES and EX.CP are sources
made here from the model's own S2688 and one-shot logic (d4_model.py), at
model-step boundaries, so that both see the same inputs.
Usage: d4_reference.py OUTDIR [SECONDS]
"""
import sys
import time
from pathlib import Path
import numpy as np
import sound_parts as P
import spice_run as S
import d4_model as M

HERE=Path(__file__).resolve().parent
T_END=2.0
CRASHES=[(0.05,0.30),(1.40,1.70)]
OFFROAD=[(0.45,0.80)]
EX_ON=(0.85,1.32)
LINE_HZ=14_305_000/2/456          # docs/TIMING.md: 7,152,500 / 456
V2_HZ=LINE_HZ/4
FRAME_HZ=LINE_HZ/264              # 264 lines a frame (docs/TIMING.md)
VECTORS=["namp","bpu","bpl","envu","envl","conu","conl","mciu","mcil","mcou","mcol",
         "expo","c94","tri","o63d","ctl555","thtr","out555"]
CURRENTS=["vm401#branch","vm402#branch","vm403#branch"]

def within(t,spans): return any(a<=t<b for a,b in spans)

def inputs(k):
    """The scenario's inputs at model step k: (T, skid_on, EX.CP)."""
    t=k*P.DT
    tt=within(t,CRASHES)
    sk=tt or within(t,OFFROAD)
    ex=False
    if EX_ON[0]<=t<EX_ON[1]:
        frame=int((t-EX_ON[0])*FRAME_HZ)
        ex=(frame//8)%2==0 and int(t*V2_HZ*2)%2==0
    return int(tt),int(sk),int(ex)

def write_stim(path,n):
    """The inputs for the Verilog testbench: the number of steps, then
    'k T skid EX.CP' at step 0 and at every step where one of them changes."""
    lines=[str(n)]; prev=None
    for k in range(n):
        v=inputs(k)
        if v!=prev: lines.append(f"{k} {v[0]} {v[1]} {v[2]}"); prev=v
    Path(path).write_text("\n".join(lines)+"\n")

def sequences(n):
    """Per-step input levels and the model's own S2688 bits and 74123
    outputs for n steps."""
    d=M.D4()
    seq={"noise":[],"q61a":[],"q61b":[],"skid_en":[],"excp":[]}
    for k in range(n):
        t,sk,ex=inputs(k)
        nb=d.noise.step()
        qa,qb=d.oneshots(t)
        seq["noise"].append(M.NOISE_HI if nb else M.NOISE_LO)
        seq["q61a"].append(5.0*qa); seq["q61b"].append(5.0*qb)
        seq["skid_en"].append(5.0*sk)
        seq["excp"].append(M.VEX_HI if ex else M.VEX_LO)
    return seq

def pwl(name,levels,edge=1e-7):
    """PWL points of a level that changes at step boundaries, each change
    taking `edge` seconds."""
    pts=[(0.0,levels[0])]; prev=levels[0]
    for k,v in enumerate(levels):
        if v!=prev:
            t=k*P.DT; pts += [(t,prev),(t+edge,v)]; prev=v
    pts.append((len(levels)*P.DT,prev))
    return pts

def netlist(seq):
    body=".title d4 reference\n"
    for name,levels in seq.items():
        pts=[f"{t:.9e} {v}" for t,v in pwl(name,levels)]
        body+=f"V{name} {name} 0 PWL(\n"
        body+="".join("+ "+" ".join(pts[i:i+8])+"\n" for i in range(0,len(pts),8))
        body+="+ )\n"
    return body+(HERE/"spice/d4_effects.cir").read_text()

def run(outdir,t_end=T_END):
    n=int(round(t_end*P.TICK_HZ))
    seq=sequences(n)
    t0=time.time()
    x,d=S.run(netlist(seq),f"tran 2u {t_end} 0 2u uic",
              [f"v({v})" for v in VECTORS]+CURRENTS,timeout=4*3600,save_only=True)
    arr={"t":np.array(x)}
    for v in VECTORS: arr[v]=np.array(d[f"v({v})"])
    for c,name in zip(CURRENTS,("i401","i402","i403")): arr[name]=np.array(d[c])
    out=Path(outdir); out.mkdir(parents=True,exist_ok=True)
    np.savez_compressed(out/"d4_spice.npz",**arr)
    print(f"d4: {len(x)} points, ngspice {time.time()-t0:.0f} s")

if __name__=="__main__":
    run(sys.argv[1],float(sys.argv[2]) if len(sys.argv)>2 else T_END)
