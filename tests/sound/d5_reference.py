#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Run the pin-wired D-5 reference (spice/d5_hiscore.cir) through its test
scenario and store the waveforms, so that d5_check.py can compare the
stepped model with it. Needs ngspice and numpy.

The reference is the analog part. The sequencer is logic; d5_model.py's
Sequencer makes its outputs (the PROM's A, B, C and H bits and the 74123's
Q), one value a model step, and they drive the netlist as sources. To fit
the whole tune, H rows included, into one run, the scenario's sequencer
runs on a faster test tempo (C106 = REF_C106 instead of 47 uF); the analog
parts do not know the tempo.

The scenario, from power-on (every capacitor at 0 V, `uic`), T_END:
  HI SCORE low for 1.3 ms from 0.2 s (one pulse of sheet A's one-shot);
  MUTE low. R10 and R29 as REF_* below (the model's values when the
  reference was made; d5_check.py refuses others); the trimmers as
  ref_vr(): the upper bank at the printed notes, the lower a semitone
  flat.
SPICE runs with a 0.1 us maximum step (the sawtooth's period is 1.8 % off
at 1 us) and stores its results interpolated on the model's step.
Usage: d5_reference.py OUTDIR [SECONDS]
"""
import math
import sys
import time
from pathlib import Path
import numpy as np
import sound_parts as P
import spice_run as S
import d5_model as M

HERE=Path(__file__).resolve().parent
T_END=3.0
REF_C106=18.8e-6                   # test tempo, 2.5 times the board's
HISCORE=(0.2,1.3e-3)               # start, length
REF_R10,REF_R29=10e3,51e3
VECTORS=["lfo","cvu","cvl","sawu","sawl","mix","lp","hp","env","con","mco"]
CURRENTS=["vm408#branch"]
TMAX="0.1u"

def step_index(t):
    """The first model step whose start is at or after t."""
    return int(math.ceil(t*P.TICK_HZ-1e-9))

def hiscore_n(k):
    a=step_index(HISCORE[0]); b=step_index(HISCORE[0]+HISCORE[1])
    return 0 if a<=k<b else 1

LOWER_FLAT=2**(-1/12)              # the lower bank a semitone flat

def ref_vr():
    """The trimmers of the reference: the upper bank at the printed notes,
    the lower bank a semitone below them, so that the two voices are
    distinct (identical voices would add in whatever phase their start
    and rounding leave them, in the model and in SPICE alike)."""
    up=M.solve_trimmers()
    low=M.solve_trimmers({k:v*LOWER_FLAT for k,v in M.NOTE_HZ.items()})
    return {k:(up[k] if k in ("VR4","VR5","VR6") else low[k]) for k in up}

def sequences(n,prom=None):
    seq=M.Sequencer(prom,REF_C106)
    out={"na":[],"nb":[],"nc":[],"nh":[],"q123":[]}
    for k in range(n):
        s=seq.step(hiscore_n(k),0)
        for b in "abch": out["n"+b].append(5.0 if s[b] else 0.0)
        out["q123"].append(M.TTL_VOH if s["q123"] else 0.2)
    return out

def pwl(name,levels,edge=1e-7):
    pts=[(0.0,levels[0])]; prev=levels[0]
    for k,v in enumerate(levels):
        if v!=prev:
            t=k*P.DT; pts += [(t,prev),(t+edge,v)]; prev=v
    pts.append((len(levels)*P.DT,prev))
    s=[f"{t:.9e} {v}" for t,v in pts]
    return f"V{name} {name} 0 PWL(\n"+"".join("+ "+" ".join(s[i:i+8])+"\n" for i in range(0,len(s),8))+"+ )\n"

def netlist(t_end,vr):
    n=int(round(t_end*P.TICK_HZ))
    seq=sequences(n)
    body=".title d5 reference\n.options interp\n"
    body+=f".param r10={REF_R10} r29={REF_R29} r1={M.R1} r23={M.R23}\n"
    body+=".param "+" ".join(f"{k.lower()}={v}" for k,v in sorted(vr.items()))+"\n"
    for name,levels in seq.items(): body+=pwl(name,levels)
    return body+(HERE/"spice/d5_hiscore.cir").read_text()

def run(outdir,t_end=T_END):
    if (M.R10,M.R29)!=(REF_R10,REF_R29):
        raise SystemExit("d5_model R10/R29 differ from the reference's")
    vr=ref_vr()
    t0=time.time()
    x,d=S.run(netlist(t_end,vr),f"tran {P.DT:.12e} {t_end} 0 {TMAX} uic",
              [f"v({v})" for v in VECTORS]+CURRENTS,timeout=12*3600,save_only=True)
    arr={"t":np.array(x)}
    for v in VECTORS: arr[v]=np.array(d[f"v({v})"])
    arr["i408"]=np.array(d["vm408#branch"])
    arr["vr"]=np.array([vr[k] for k in sorted(vr)]); arr["vr_names"]=np.array(sorted(vr))
    out=Path(outdir); out.mkdir(parents=True,exist_ok=True)
    np.savez_compressed(out/"d5_spice.npz",**arr)
    print(f"d5: {len(x)} points, ngspice {time.time()-t0:.0f} s")

if __name__=="__main__":
    run(sys.argv[1],float(sys.argv[2]) if len(sys.argv)>2 else T_END)
