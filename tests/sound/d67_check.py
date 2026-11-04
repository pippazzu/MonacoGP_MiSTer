#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Features of the D-6/D-7 other-car sounds, and their comparison between
a stepped model (float, fixed-point twin, Verilog) and the SPICE reference
(d67_reference.py).

  d67_check.py features SPICE.npz OUT.json   reduce a SPICE run
  d67_check.py model [OUT.json]              the floating-point model's
                                             features and its report

Features, per 50 ms window over the 3 s scenario from 50 ms on (the first
window holds the power-on, where SPICE's supplies rise over 1 ms and its
op-amps slew from 0 V): the means of the control levels (feed, ramps,
IC15 outputs, the four MC3340 CONTROLs, CAR CON, D-6's half-rail, the
banks' CONTROL nodes and outputs), the RMS about the mean of the audio
nodes (the banks' CONTROL nodes and outputs, IC32 b, the R409 and D-2
currents), and the cycles of four cells (bank 1's three, bank 2's first:
crossings of 5.75 V with 0.5 V of hysteresis either side). Over the whole
run: the times at which the 74123s (IC59 a, IC59 b, IC58) start a pulse.
Currents are taken as volts: R409's times R414 (22K), D-2's times 51K.
"""
import json
import sys
from pathlib import Path
import numpy as np
import sound_parts as P

HERE=Path(__file__).resolve().parent
WIN=0.05
T0=0.05
MEANS=["feed","r14","r28","u1","u2","con20","con19","con34","con33","cv1","cv2","r6",
       "con1","con2","snd1","snd2"]
RMS=["con1","con2","snd1","snd2","front","i_mf","i_mb"]
CELLS=["o1","o2","o3","o1b"]
EVENTS=["q59a","q59b","q58"]
CELL_MID,CELL_HYST=5.75,0.5
# Tolerances between a model and SPICE (volts; cycles per window; seconds
# for the pulse starts). Set from the floating-point model's differences
# (docs/SOUND_LOGIC.md); see TOL_NOTE.
# Floating-point model against the 3 s SPICE run (2 November): the largest
# per-window differences times 2.5, at least 0.01 V; cycle counts 2 per
# window (a window can gain or lose one from phase) and 2.6 % over the run
# (largest 1.04 %, bank 1's cell 3); pulse starts 10 us (observed
# 2 us, one step).
TOL={"cyc_o1":2,"cyc_o1b":2,"cyc_o2":2,"cyc_o3":2,
     "mean_con1":0.11,"mean_con19":0.013,"mean_con2":0.13,"mean_con20":0.032,
     "mean_con33":0.026,"mean_con34":0.068,"mean_cv1":0.033,"mean_cv2":0.068,
     "mean_feed":0.01,"mean_r14":0.054,"mean_r28":0.11,"mean_r6":0.01,
     "mean_snd1":0.49,"mean_snd2":0.39,"mean_u1":0.025,"mean_u2":0.054,
     "rms_con1":0.24,"rms_con2":0.19,"rms_front":0.32,"rms_i_mb":0.088,
     "rms_i_mf":0.089,"rms_snd1":0.28,"rms_snd2":0.33}
TOL_CYC_TOTAL=0.026
TOL_EVENT=10e-6
TOL_NOTE="docs/SOUND_LOGIC.md, D-6/D-7 checks"
# Step-to-step flips: a step whose change and the next step's are both
# larger than FLIP_V and of opposite sign. SPICE resampled to the steps has
# 0 / 1 / 0 over the run; the stepped model had about 100,000 before the D-7
# inputs' current was relaxed (2 November, the passing cars' "quack" on
# the MiSTer), 3 / 2 / 2 after (two of them the power-on step).
FLIP_SIGNALS=["front","snd1","snd2"]
FLIP_V=0.2
FLIP_MAX=8

def flips(d):
    """Number of step-to-step flips of each FLIP_SIGNALS series (volts)."""
    out={}
    for k in FLIP_SIGNALS:
        a=np.diff(np.asarray(d[k],dtype=np.float64))
        out[k]=int(((a[:-1]*a[1:]<0)&(np.abs(a[:-1])>FLIP_V)&(np.abs(a[1:])>FLIP_V)).sum())
    return out

def flip_failures(c):
    return [f"flips_{k}: {v} steps flip by more than {FLIP_V} V (at most {FLIP_MAX})"
            for k,v in c.items() if v>FLIP_MAX]

def windows(t_end):
    n=int(round((t_end-T0)/WIN))
    return [(T0+k*WIN,T0+(k+1)*WIN) for k in range(n)]

def cycles(v):
    st=v[0]>CELL_MID; c=0
    for x in v:
        if not st and x>CELL_MID+CELL_HYST: st=True; c+=1
        elif st and x<CELL_MID-CELL_HYST: st=False
    return c

def starts(t,v,thr):
    b=v>thr
    return [float(x) for x in t[1:][(~b[:-1])&b[1:]]]

def features(t,d,t_end):
    """d: name -> array on the times t (volts; currents already as volts;
    events as levels with 1.7 V or 0.5 as threshold)."""
    w=[]
    for a,b in windows(t_end):
        m=(t>=a)&(t<b)
        f={"t":a}
        for k in MEANS: f["mean_"+k]=float(d[k][m].mean())
        for k in RMS: f["rms_"+k]=float(d[k][m].std())
        for k in CELLS: f["cyc_"+k]=cycles(d[k][m])
        w.append(f)
    ev={}
    for k in EVENTS:
        v=d[k]; thr=1.7 if v.max()>1.5 else 0.5
        ev[k]=starts(t,v,thr)
    return {"windows":w,"events":ev}

def spice_features(npz,out):
    s=np.load(npz); t=s["t"]
    d={k:s[k] for k in s.files}
    d["i_mf"]=s["i_mf"]*22e3; d["i_mb"]=s["i_mb"]*51e3
    t_end=float(round(t[-1],3))
    f=features(t,d,t_end); f["t_end"]=t_end
    Path(out).write_text(json.dumps(f,indent=0)+"\n")

def model_run(t_end):
    import d67_model as M
    import d67_reference as R
    n=int(round(t_end*P.TICK_HZ))
    m=M.D67()
    keys=sorted(set(MEANS+RMS+CELLS+EVENTS))
    rec={k:np.zeros(n) for k in keys}
    for k in range(n):
        acc,low=R.inputs(k)
        i=m.step(acc,low)
        o=m.out
        for key in keys:
            if key=="i_mf": rec[key][k]=i*22e3
            elif key=="i_mb": rec[key][k]=o["i_mb"]*51e3
            else: rec[key][k]=float(o[key])
    t=(np.arange(n)+1)*P.DT        # a step's values hold at its end
    return t,rec

def compare(ref,got):
    """Largest differences per feature: {name: (difference, window start)};
    for events, (difference in count, largest time difference)."""
    worst={}
    for a,b in zip(ref["windows"],got["windows"]):
        for k,v in a.items():
            if k=="t": continue
            e=abs(b[k]-v)
            if e>=worst.get(k,(-1,0))[0]: worst[k]=(e,a["t"])
    for k in CELLS:
        a=sum(x["cyc_"+k] for x in ref["windows"]); b=sum(x["cyc_"+k] for x in got["windows"])
        worst["total_"+k]=(abs(b-a)/a,0.0)
    for k in EVENTS:
        ra,ga=ref["events"][k],got["events"][k]
        dt=max([abs(x-y) for x,y in zip(ra,ga)],default=0.0)
        worst["ev_"+k]=(abs(len(ra)-len(ga)),dt)
    return worst

def failures(worst):
    bad=[]
    for k,(e,t) in worst.items():
        if k.startswith("ev_"):
            if e!=0 or (TOL_EVENT is not None and t>TOL_EVENT):
                bad.append(f"{k}: {e} pulses more or fewer, starts {t*1e3:.2f} ms apart")
        elif k.startswith("total_"):
            if e>TOL_CYC_TOTAL: bad.append(f"{k}: cycles over the run {e*100:.2f} % apart (tolerance {TOL_CYC_TOTAL*100} %)")
        elif k in TOL and e>TOL[k]:
            bad.append(f"{k}: {e:.4g} at {t:.2f} s (tolerance {TOL[k]})")
    return bad

def report(worst):
    for k,(e,t) in sorted(worst.items()):
        if k.startswith("ev_"): print(f"  {k:16s} count {e}, starts within {t*1e3:.3f} ms")
        elif k.startswith("total_"): print(f"  {k:16s} {e*100:.3f} % over the run")
        else: print(f"  {k:16s} {e:.5f} at {t:.2f} s")

if __name__=="__main__":
    if sys.argv[1]=="features": spice_features(sys.argv[2],sys.argv[3])
    elif sys.argv[1]=="model":
        ref=json.loads((HERE/"data/d67_spice_features.json").read_text())
        t,rec=model_run(ref["t_end"])
        got=features(t,rec,ref["t_end"])
        if len(sys.argv)>2: Path(sys.argv[2]).write_text(json.dumps(got,indent=0)+"\n")
        w=compare(ref,got); report(w)
        fl=flips(rec)
        bad=failures(w)+flip_failures(fl)
        print("flips:"," ".join(f"{k} {v}" for k,v in fl.items()))
        print("events: spice",ref["events"]); print("        model",got["events"])
        print(f"{len(bad)} features outside the tolerances"+("" if not bad else ": "+"; ".join(bad)))
