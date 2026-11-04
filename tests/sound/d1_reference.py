#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run the pin-wired D-1 reference (spice/d1_slip.cir) through its test
scenario and store the waveforms, so that d1_check.py can compare the
stepped model with it. Needs ngspice (with XSPICE) and numpy.

The scenario, from power-on (every capacitor at 0 V, `uic`, the supplies
rising over the first millisecond), 3 s, VR7 at REF_A7:
  the S2688's output: the D-4 model's own S2688 (d4_model.py), one bit a
               model step, from its reset state (as in the core);
  pad J (SLIP ZONE) low, so the 4016 passes the sound, from 0.5 to 2.0 s
               and from 2.3 s to the end; high (silent) otherwise.
The model sees each input as it is at the start of its step.
Usage: d1_reference.py OUTDIR [SECONDS]
"""
import math
import sys
import time
from pathlib import Path
import numpy as np
import sound_parts as P
import spice_run as S
import d4_model as D4M

HERE=Path(__file__).resolve().parent
T_END=3.0
REF_A7=0.167                       # VR7 (d1_model.VR7_A7 when the reference was made)
SLIP=[(0.5,2.0),(2.3,3.0)]         # pad J low
VECTORS=["c63","o53_8","o53_14","na","o53_1","o53_7","sw"]
CURRENTS=["vm412#branch"]

def step_index(t):
    """The first model step whose start is at or after t."""
    return int(math.ceil(t*P.TICK_HZ-1e-9))

def noise_bits(n):
    ns=D4M.S2688()
    return [ns.step() for _ in range(n)]

def slip_n(k):
    """Pad J at model step k (0 = in the slip zone)."""
    return 0 if any(step_index(a)<=k<step_index(b) for a,b in SLIP) else 1

def write_stim(path,n):
    """For the Verilog testbench: the number of steps, then one line a step:
    'noise slip_n'."""
    nb=noise_bits(n)
    lines=[str(n)]+[f"{b} {slip_n(k)}" for k,b in enumerate(nb)]
    Path(path).write_text("\n".join(lines)+"\n")

def pwl(name,levels,edge=1e-7):
    """PWL source of a level that changes at step boundaries."""
    pts=[(0.0,levels[0])]; prev=levels[0]
    for k,v in enumerate(levels):
        if v!=prev:
            t=k*P.DT; pts += [(t,prev),(t+edge,v)]; prev=v
    pts.append((len(levels)*P.DT,prev))
    s=[f"{t:.9e} {v}" for t,v in pts]
    return f"V{name} {name} 0 PWL(\n"+"".join("+ "+" ".join(s[i:i+8])+"\n" for i in range(0,len(s),8))+"+ )\n"

def netlist(t_end,a7=REF_A7):
    n=int(round(t_end*P.TICK_HZ))
    nb=noise_bits(n)
    body=f".title d1 reference\n.param a7={a7}\n"
    body+=pwl("noise",[D4M.NOISE_HI if b else D4M.NOISE_LO for b in nb])
    body+=pwl("padj",[3.4 if slip_n(k) else 0.2 for k in range(n)])
    return body+(HERE/"spice/d1_slip.cir").read_text()

def run(outdir,t_end=T_END):
    t0=time.time()
    x,d=S.run(netlist(t_end),f"tran 2u {t_end} 0 2u uic",
              [f"v({v})" for v in VECTORS]+CURRENTS,timeout=8*3600,save_only=True)
    arr={"t":np.array(x)}
    for v in VECTORS: arr[v]=np.array(d[f"v({v})"])
    arr["i412"]=np.array(d["vm412#branch"])
    out=Path(outdir); out.mkdir(parents=True,exist_ok=True)
    np.savez_compressed(out/"d1_spice.npz",**arr)
    print(f"d1: {len(x)} points, ngspice {time.time()-t0:.0f} s")

if __name__=="__main__":
    run(sys.argv[1],float(sys.argv[2]) if len(sys.argv)>2 else T_END)
