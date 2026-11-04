#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run the pin-wired D-3 reference (spice/d3_mycar.cir) through the test
scenarios and store the waveforms, so that d3_check.py can compare the
stepped model and the Verilog against them. Needs ngspice and numpy.

Scenarios (all from power-on: every capacitor at 0 V, `uic`):
  full   3 s: the S-ACCE code, SHIFT A and SOUND ON switched as below,
         through the real C62 lag
  cells  1.08 s: C62 replaced by a voltage stepping through the CV range,
         SHIFT A off then on at each level, to measure the oscillators
Usage: d3_reference.py [full|cells] OUTDIR
"""
import sys
import time
from pathlib import Path
import numpy as np
import spice_run as S

HERE=Path(__file__).resolve().parent
VECTORS=["lag","cv","o51a","o50a","o49a","o51b","o50b","o49b","con","bus","mcin","mcout",
         "swo","mixr","i51p10"]

# (time s, S-ACCE code, SHIFT A, SOUND ON); code bit 0 = A
FULL=[(0.0,0b0111,0,1),(0.6,0b1111,0,1),(1.2,0b1111,1,1),(1.5,0b0000,1,1),
      (1.8,0b0000,1,0),(2.0,0b0000,0,1),(2.4,0b1010,0,1)]
FULL_T=3.0
CELL_LEVELS=[0.5,1.0,2.0,3.0,4.5,6.0,7.5,9.0,10.5]
CELL_STEP=0.06
LAG_EDGE=50e-6     # the forced C62 voltage moves over 50 us (ngspice cannot
                   # follow a 0.1 us jump of every cell at once)
def cells_schedule():
    ev=[]; lag=[]
    for k,v in enumerate(CELL_LEVELS):
        t=2*k*CELL_STEP
        ev += [(t,0b0111,0,1),(t+CELL_STEP,0b0111,1,1)]
        lag.append((t,v))
    return ev,lag
CELLS_T=2*len(CELL_LEVELS)*CELL_STEP

def event_ticks(events,tick_hz):
    """The events as (model step, code, SHIFT A, SOUND ON): an event at time t
    applies from the step that starts at t."""
    return [(int(round(t*tick_hz)),c,a,b) for t,c,a,b in events]

def pwl(name,points):
    pts=" ".join(f"{t:.7f}s {v}" for t,v in points)
    return f"V{name} {name}_l 0 PWL({pts})\nR{name} {name}_l {name} 1\n"

def steps(seq,edge=1e-7):
    """Step waveform: each change takes `edge` seconds."""
    out=[]; prev=None
    for t,v in seq:
        if prev is None: out.append((t,v))
        elif v!=prev: out += [(t,prev),(t+edge,v)]
        prev=v
    return out

def netlist(events,lag=None):
    sig={"acc_a":[],"acc_b":[],"acc_c":[],"acc_d":[],"shift_a":[],"sound_on":[]}
    for t,code,sh,on in events:
        for b,n in enumerate(("acc_a","acc_b","acc_c","acc_d")): sig[n].append((t,5*(code>>b&1)))
        sig["shift_a"].append((t,5*sh)); sig["sound_on"].append((t,5*on))
    body=".title d3 reference\n"+"".join(pwl(k,steps(v)) for k,v in sig.items())
    cir=(HERE/"spice/d3_mycar.cir").read_text()
    if lag is not None:
        assert "C62 lag 0 47u" in cir
        cir=cir.replace("C62 lag 0 47u","Vlagforce lag 0 PWL("+" ".join(f"{t:.7f}s {v}" for t,v in steps(lag,LAG_EDGE))+")")
    # the reference's .include lines are relative to spice/
    return body+cir

def run(name,outdir):
    if name=="full": events,lag,tend=FULL,None,FULL_T
    else:
        events,lag=cells_schedule(); tend=CELLS_T
    t0=time.time()
    x,d=S.run(netlist(events,lag),f"tran 2u {tend} 0 2u uic",[f"v({v})" for v in VECTORS],timeout=7200)
    arr={"t":np.array(x)}
    for v in VECTORS: arr[v]=np.array(d[f"v({v})"])
    out=Path(outdir); out.mkdir(parents=True,exist_ok=True)
    np.savez_compressed(out/f"d3_spice_{name}.npz",**arr)
    print(f"{name}: {len(x)} points, ngspice {time.time()-t0:.0f} s")

if __name__=="__main__":
    run(sys.argv[1],sys.argv[2])
