#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run the pin-wired D-2 reference (spice/d2_rescue.cir) through its test
scenario and store the waveforms, so that d2_check.py can compare the
stepped model with it. Needs ngspice (with XSPICE) and numpy.

The scenario, from power-on (every capacitor at 0 V, `uic`, the supplies
rising over the first millisecond), 6 s:
  pad P (/RESCUE CP) low for 20 ms (sheet M's IC18 pulse) at 1.0 s and at
               3.0 s, the second while the front envelope is still rising;
  BACK SOUND STB. sunk (D-4 IC57, attract mute) from 5.0 to 5.5 s;
  BACK OTHER CAR: from 0.2 s a 400 Hz sine, 0.5 V about 6 V, behind 51K
               (a test signal for the back amplifier's sum).
The model sees each input as it is at the start of its step.
Usage: d2_reference.py OUTDIR [SECONDS]
"""
import math
import sys
import time
from pathlib import Path
import numpy as np
import sound_parts as P
import spice_run as S

HERE=Path(__file__).resolve().parent
T_END=6.0
RESC=[(1.0,1.02),(3.0,3.02)]       # pad P low
MUTE=[(5.0,5.5)]                   # BACK SOUND STB. sunk
BKO_T0,BKO_HZ,BKO_A=0.2,400.0,0.5
VECTORS=["env_r","env_f","o42_1","o42_14","o42_8","o43_14","q","o43_1","o43_7",
         "o44_14","con41","con45","tri","o40_1","w","o555","th555","mc41o","mc45o",
         "o40_7","z","padr","o44_7","r28"]
CURRENTS=["vm410#branch","vm424#branch"]
SAVE_ONLY=True

def step_index(t):
    """The first model step whose start is at or after t."""
    return int(math.ceil(t*P.TICK_HZ-1e-9))

def inputs(k):
    """The scenario's inputs at model step k: (pad P low, STB. sunk,
    BACK OTHER CAR source volts)."""
    resc=any(step_index(a)<=k<step_index(b) for a,b in RESC)
    mute=any(step_index(a)<=k<step_index(b) for a,b in MUTE)
    t=k*P.DT
    bko=P.V6+(BKO_A*math.sin(2*math.pi*BKO_HZ*(t-BKO_T0)) if t>=BKO_T0 else 0.0)
    return resc,mute,bko

def write_stim(path,n):
    """For the Verilog testbench: the number of steps, then one line a step:
    'resc mute i_bk' (i_bk: BACK OTHER CAR's current times 51K, 2^28 per
    volt, as d2_fixed.py takes it)."""
    import d3_fixed as F3
    lines=[str(n)]
    for k in range(n):
        resc,mute,bko=inputs(k)
        lines.append(f"{int(resc)} {int(mute)} {F3.vq(bko-P.V6)}")
    Path(path).write_text("\n".join(lines)+"\n")

def netlist(t_end):
    def pulses(name,spans,hi,lo):
        pts=[(0.0,hi)]
        for a,b in spans:
            if a>=t_end: continue
            ta,tb=step_index(a)*P.DT,step_index(b)*P.DT
            pts += [(ta,hi),(ta+1e-7,lo),(tb,lo),(tb+1e-7,hi)]
        pts.append((t_end,hi))
        return f"V{name} {name} 0 PWL("+" ".join(f"{t:.9e} {v}" for t,v in pts)+")\n"
    body=".title d2 reference\n"
    body+=pulses("resc",RESC,3.4,0.2)
    body+=pulses("bstb",MUTE,5.0,0.0)
    body+=f"Vbko bko 0 SIN({P.V6} {BKO_A} {BKO_HZ} {BKO_T0})\n"
    return body+(HERE/"spice/d2_rescue.cir").read_text()

def run(outdir,t_end=T_END):
    t0=time.time()
    x,d=S.run(netlist(t_end),f"tran 2u {t_end} 0 2u uic",
              [f"v({v})" for v in VECTORS]+CURRENTS,timeout=8*3600,save_only=SAVE_ONLY)
    arr={"t":np.array(x)}
    for v in VECTORS: arr[v]=np.array(d[f"v({v})"])
    arr["i410"]=np.array(d["vm410#branch"]); arr["i424"]=np.array(d["vm424#branch"])
    out=Path(outdir); out.mkdir(parents=True,exist_ok=True)
    np.savez_compressed(out/"d2_spice.npz",**arr)
    print(f"d2: {len(x)} points, ngspice {time.time()-t0:.0f} s")

if __name__=="__main__":
    run(sys.argv[1],float(sys.argv[2]) if len(sys.argv)>2 else T_END)
