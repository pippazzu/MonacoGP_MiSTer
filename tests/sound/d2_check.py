#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Features of the D-2 rescue siren and back sound, and their comparison
between a stepped model (float, fixed-point twin, Verilog) and the SPICE
reference (d2_reference.py).

  d2_check.py features SPICE.npz OUT.json   reduce a SPICE run
  d2_check.py model [OUT.json]              the floating-point model's
                                            features and its report

Features, per 50 ms window over the 6 s scenario from 50 ms on (the first
window holds the power-on, where SPICE's supplies rise over 1 ms and its
op-amps slew from 0 V): the means of the envelopes, the MC3340 CONTROLs and
the 2.8 V rail, the RMS about the mean of the audio nodes (the two MC3340
outputs, IC40 b, node Z, pad R, IC44 b, and the mixer currents through
R410 and R424, taken as volts across 220K and 100K), and the siren tone's
cycles (the sawtooth's discharges: falls through 7 V after a rise above
8 V). Over the whole run: the times at which the comparators, latches and
the 555 change state (crossings of 6 V), also from 50 ms on.
"""
import json
import sys
from pathlib import Path
import numpy as np
import sound_parts as P

HERE=Path(__file__).resolve().parent
WIN=0.05
T0=0.05
MEANS=["env_r","env_f","con41","con45","r28"]
RMS=["mc41o","mc45o","o40_7","z","padr","o44_7","i410","i424"]
CELLS=["tri"]
EVENTS=["o42_8","o42_1","o43_14","o43_1","o43_7","o44_14","o555"]
TRI_HI,TRI_LO=8.0,7.0
SCALE={"i410":220e3,"i424":100e3}
# Tolerances between a model and SPICE (volts; cycles per window; seconds
# for the switching times). Set from the floating-point model's
# differences (docs/SOUND_LOGIC.md, D-2 checks); see TOL_NOTE.
# Floating-point model against the 6 s SPICE run (2 November): the largest
# per-window differences times 2.5, at least 0.01 V (the largest fall in
# the windows where an envelope switches, where a millisecond's offset
# moves the window's level); tone cycles 2 per window (a window can gain or
# lose one from phase) and 0.5 % over the run (observed 0.05 %); the
# switching times 2.5 times the largest offset (observed: the envelopes'
# falls 0.2 to 0.7 % shorter or longer than SPICE's, up to 4.8 ms; the 555
# 0.5 ms, from SPICE's supplies rising over the first millisecond).
TOL={"mean_con41":0.013,"mean_con45":0.047,"mean_env_f":0.13,"mean_env_r":0.037,
     "mean_r28":0.01,"rms_i410":0.38,"rms_i424":0.21,"rms_mc41o":0.15,"rms_mc45o":0.21,
     "rms_o40_7":0.23,"rms_o44_7":0.38,"rms_padr":0.19,"rms_z":0.21}
TOL_CYC=2
TOL_CYC_TOTAL=0.005
TOL_EVENT={"o42_1":0.0058,"o42_8":0.0064,"o43_1":0.0057,"o43_14":0.0085,"o43_7":0.0089,
           "o44_14":0.0121,"o555":0.0013}
TOL_NOTE="docs/SOUND_LOGIC.md, D-2 checks"

def windows(t_end):
    n=int(round((t_end-T0)/WIN))
    return [(T0+k*WIN,T0+(k+1)*WIN) for k in range(n)]

def cycles(v):
    """Discharges of the sawtooth: a fall below TRI_LO after a rise above
    TRI_HI."""
    st=v[0]>TRI_HI; c=0
    for x in v:
        if not st and x>TRI_HI: st=True
        elif st and x<TRI_LO: st=False; c+=1
    return c

def edges(t,v,thr=6.0):
    """(time, 1 rising / 0 falling) of each crossing of thr after the
    power-on window."""
    b=v>thr
    i=np.nonzero(b[:-1]!=b[1:])[0]
    return [(float(t[k+1]),int(b[k+1])) for k in i if t[k+1]>=T0]

def features(t,d,t_end):
    """d: name -> array on the times t (volts; currents already as volts).
    A mean the run does not have (the 2.8 V rail of the Verilog) is left
    out of the comparison."""
    w=[]
    for a,b in windows(t_end):
        m=(t>=a)&(t<b)
        f={"t":a}
        for k in MEANS:
            if k in d: f["mean_"+k]=float(d[k][m].mean())
        for k in RMS: f["rms_"+k]=float(d[k][m].std())
        for k in CELLS: f["cyc_"+k]=cycles(d[k][m])
        w.append(f)
    ev={k:edges(t,d[k]) for k in EVENTS}
    return {"windows":w,"events":ev}

def spice_features(npz,out):
    s=np.load(npz); t=s["t"]
    d={k:s[k] for k in s.files}
    for k,r in SCALE.items(): d[k]=s[k]*r
    t_end=float(round(t[-1],3))
    f=features(t,d,t_end); f["t_end"]=t_end
    Path(out).write_text(json.dumps(f,indent=0)+"\n")

def model_run(t_end,model=None):
    import d2_model as M
    import d2_reference as R
    n=int(round(t_end*P.TICK_HZ))
    m=model or M.D2()
    keys=sorted(set(MEANS+RMS+CELLS+EVENTS))
    rec={k:np.zeros(n) for k in keys}
    for k in range(n):
        resc,mute,bko=R.inputs(k)
        m.step(resc,mute,(bko-P.V6)/51e3)
        o=m.out
        for key in keys: rec[key][k]=float(o[key])*SCALE.get(key,1.0)
    t=(np.arange(n)+1)*P.DT        # a step's values hold at its end
    return t,rec

def compare(ref,got):
    """Largest differences per feature: {name: (difference, window start)};
    for events, (difference in count, largest time difference)."""
    worst={}
    for a,b in zip(ref["windows"],got["windows"]):
        for k,v in a.items():
            if k=="t" or k not in b: continue
            e=abs(b[k]-v)
            if e>=worst.get(k,(-1,0))[0]: worst[k]=(e,a["t"])
    for k in CELLS:
        a=sum(x["cyc_"+k] for x in ref["windows"]); b=sum(x["cyc_"+k] for x in got["windows"])
        worst["total_"+k]=(abs(b-a)/a,0.0)
    for k in EVENTS:
        ra,ga=ref["events"][k],got["events"][k]
        same=len(ra)==len(ga) and all(x[1]==y[1] for x,y in zip(ra,ga))
        dt=max([abs(x[0]-y[0]) for x,y in zip(ra,ga)],default=0.0)
        worst["ev_"+k]=(0 if same else max(1,abs(len(ra)-len(ga))),dt)
    return worst

def failures(worst):
    bad=[]
    for k,(e,t) in worst.items():
        if k.startswith("ev_"):
            n=k[3:]
            if e!=0: bad.append(f"{k}: edges differ in number or direction")
            elif n in TOL_EVENT and t>TOL_EVENT[n]:
                bad.append(f"{k}: edges {t*1e3:.3f} ms apart (tolerance {TOL_EVENT[n]*1e3} ms)")
        elif k.startswith("total_"):
            if TOL_CYC_TOTAL is not None and e>TOL_CYC_TOTAL:
                bad.append(f"{k}: cycles over the run {e*100:.2f} % apart (tolerance {TOL_CYC_TOTAL*100} %)")
        elif k.startswith("cyc_"):
            if TOL_CYC is not None and e>TOL_CYC: bad.append(f"{k}: {e} cycles at {t:.2f} s (tolerance {TOL_CYC})")
        elif k in TOL and e>TOL[k]:
            bad.append(f"{k}: {e:.4g} at {t:.2f} s (tolerance {TOL[k]})")
        elif k not in TOL: bad.append(f"{k}: no tolerance")
    return bad

def report(worst):
    for k,(e,t) in sorted(worst.items()):
        if k.startswith("ev_"): print(f"  {k:16s} count/direction {e}, edges within {t*1e3:.3f} ms")
        elif k.startswith("total_"): print(f"  {k:16s} {e*100:.3f} % over the run")
        else: print(f"  {k:16s} {e:.5f} at {t:.2f} s")

if __name__=="__main__":
    if sys.argv[1]=="features": spice_features(sys.argv[2],sys.argv[3])
    elif sys.argv[1]=="model":
        ref=json.loads((HERE/"data/d2_spice_features.json").read_text())
        t,rec=model_run(ref["t_end"])
        got=features(t,rec,ref["t_end"])
        if len(sys.argv)>2: Path(sys.argv[2]).write_text(json.dumps(got,indent=0)+"\n")
        w=compare(ref,got); report(w)
        bad=failures(w)
        print(f"{len(bad)} features outside the tolerances"+("" if not bad else ": "+"; ".join(bad)))
