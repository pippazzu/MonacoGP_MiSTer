#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Features of the D-5 hi-score tune, and their comparison between a
stepped model (float, fixed-point twin, Verilog) and the SPICE reference
(d5_reference.py).

  d5_check.py features SPICE.npz OUT.json   reduce a SPICE run
  d5_check.py model [OUT.json] [SPICE.npz]  the floating-point model's
                                            features and its report; with
                                            the SPICE run also the blocks
                                            driven by the reference's own
                                            signals

Features, per 50 ms window from T0: the means of the vibrato triangle (IC1
pin 1), both note voltages (IC1 pins 8 and 14), the envelope (C14) and the
MC3340's CONTROL; the RMS about the mean of both sawtooths, the mixer
(IC15 pin 8), both filters' outputs, the MC3340's output and the current
through R408 (taken as volts across 39K); and both sawtooths' frequencies
(falling crossings of 6 V, interpolated, over the window), only in windows
where the note holds: the two halves' frequencies within STEADY of each
other. In a window where the note changes the measure depends on where
the change falls, which a step's difference moves.

The block check (float model only, needs the SPICE run): the filters fed
with the reference's mixer output, and the MC3340 chain fed with the
reference's high-pass output and CONTROL, compared sample by sample.
"""
import json
import sys
from pathlib import Path
import numpy as np
import sound_parts as P

HERE=Path(__file__).resolve().parent
WIN=0.05
T0=0.05
STEADY=0.05
MEANS=["lfo","cvu","cvl","env","con"]
RMS=["sawu","sawl","mix","lp","hp","mco","i408"]
FREQ=["sawu","sawl"]
SCALE={"i408":39e3}
# Tolerances between a model and SPICE (volts; hertz for the frequencies);
# see TOL_NOTE. Floating-point model against the 3 s SPICE run (Gear,
# 2 November): the largest per-window differences times 2.5. The vibrato
# runs about 0.08 % slow against SPICE's, so its phase drifts by about
# 2.3 ms over the run and the triangle's window mean differs by up to
# 0.22 V at the end (of 3.86..7.59 V); the notes' frequencies differ by up
# to 0.8 Hz (upper) and 1.6 Hz (lower) in windows where the note holds, the
# RMS of the sawtooths, the mixer and the filters by up to 0.035 V (of
# about 1 V), the MC3340's output and the R408 current by up to 0.0083 V.
TOL={"mean_lfo":0.56,"mean_cvu":0.0055,"mean_cvl":0.0055,"mean_env":0.012,"mean_con":0.005,
     "rms_sawu":0.049,"rms_sawl":0.054,"rms_mix":0.078,"rms_lp":0.087,"rms_hp":0.033,
     "rms_mco":0.021,"rms_i408":0.021,"f_sawu":2.0,"f_sawl":4.1}
TOL_NOTE="docs/SOUND_LOGIC.md, D-5 checks"

def windows(t_end):
    n=int(round((t_end-T0)/WIN))
    return [(T0+k*WIN,T0+(k+1)*WIN) for k in range(n)]

def freq(t,v,a,b,thr=6.0):
    m=(t>=a)&(t<b); x=t[m]; s=v[m]
    i=np.nonzero((s[:-1]>thr)&(s[1:]<=thr))[0]
    if len(i)<3: return 0.0
    tc=x[i]+(s[i]-thr)/(s[i]-s[i+1])*(x[i+1]-x[i])
    return float((len(tc)-1)/(tc[-1]-tc[0]))

def features(t,d,t_end):
    w=[]
    for a,b in windows(t_end):
        m=(t>=a)&(t<b)
        f={"t":a}
        for k in MEANS: f["mean_"+k]=float(d[k][m].mean())
        for k in RMS: f["rms_"+k]=float(d[k][m].std())
        for k in FREQ:
            fw=freq(t,d[k],a,b); f1=freq(t,d[k],a,0.5*(a+b)); f2=freq(t,d[k],0.5*(a+b),b)
            if fw>0 and f1>0 and f2>0 and abs(f1-f2)<=STEADY*fw: f["f_"+k]=fw
        w.append(f)
    return {"windows":w}

def spice_features(npz,out):
    s=np.load(npz); t=s["t"]
    d={k:np.array(s[k]) for k in set(MEANS+RMS+FREQ)}
    for k,r in SCALE.items(): d[k]=d[k]*r
    t_end=float(round(t[-1],3))
    f=features(t,d,t_end); f["t_end"]=t_end
    f["vr"]={str(k):float(v) for k,v in zip(s["vr_names"],s["vr"])}
    Path(out).write_text(json.dumps(f,indent=0)+"\n")

def model_run(t_end,model=None):
    import d5_model as M
    import d5_reference as R
    n=int(round(t_end*P.TICK_HZ))
    m=model or M.D5(vr=R.ref_vr(),c106=R.REF_C106)
    keys=sorted(set(MEANS+RMS+FREQ))
    rec={k:np.zeros(n) for k in keys}
    for k in range(n):
        m.step(R.hiscore_n(k),0)
        o=m.out
        for key in keys: rec[key][k]=float(o[key])*SCALE.get(key,1.0)
    t=(np.arange(n)+1)*P.DT        # a step's values hold at its end
    return t,rec

def compare(ref,got):
    worst={}
    for a,b in zip(ref["windows"],got["windows"]):
        for k,v in a.items():
            if k=="t" or k not in b: continue
            e=abs(b[k]-v)
            if e>=worst.get(k,(-1,0))[0]: worst[k]=(e,a["t"])
    return worst

def failures(worst):
    bad=[]
    for k,(e,t) in worst.items():
        if k in TOL and e>TOL[k]: bad.append(f"{k}: {e:.4g} at {t:.2f} s (tolerance {TOL[k]})")
        elif k not in TOL: bad.append(f"{k}: no tolerance")
    return bad

def report(worst):
    for k,(e,t) in sorted(worst.items()): print(f"  {k:16s} {e:.6g} at {t:.2f} s")

def blocks(npz):
    """The filters and the MC3340 chain driven by the reference's signals;
    the largest and RMS sample differences after T0."""
    import d5_model as M
    s=np.load(npz); t=s["t"]; n=len(t)
    mix,hp_r,con_r=np.array(s["mix"]),np.array(s["hp"]),np.array(s["con"])
    m=M.D5()
    lp=np.zeros(n); hp=np.zeros(n); mco=np.zeros(n); i408=np.zeros(n)
    for k in range(n):
        lp[k],hp[k]=m.filters(mix[k])
        mco[k],i408[k]=m.mc_chain(hp_r[k],con_r[k])
    sel=t>=T0
    # fed the reference's sample at t[k], a block's output is for t[k]
    for name,ref,got in (("lp",s["lp"],lp),("hp",s["hp"],hp),("mco",s["mco"],mco),
                         ("i408",np.array(s["i408"])*39e3,i408*39e3)):
        ref=np.array(ref)[sel]; got=got[sel]
        e=got-ref
        print(f"  block {name:5s} max |diff| {np.abs(e).max():.4g} V, rms diff {e.std():.4g} V "
              f"(rms {ref.std():.4g} V)")

if __name__=="__main__":
    if sys.argv[1]=="features": spice_features(sys.argv[2],sys.argv[3])
    elif sys.argv[1]=="model":
        ref=json.loads((HERE/"data/d5_spice_features.json").read_text())
        t,rec=model_run(ref["t_end"])
        got=features(t,rec,ref["t_end"])
        if len(sys.argv)>2 and sys.argv[2]!="-": Path(sys.argv[2]).write_text(json.dumps(got,indent=0)+"\n")
        w=compare(ref,got); report(w)
        bad=failures(w)
        print(f"{len(bad)} features outside the tolerances"+("" if not bad else ": "+"; ".join(bad)))
        if len(sys.argv)>3: blocks(sys.argv[3])
