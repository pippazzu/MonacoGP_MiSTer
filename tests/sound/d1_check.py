#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Features of the D-1 slip-zone sound, and their comparison between a
stepped model (float, fixed-point twin, Verilog) and the SPICE reference
(d1_reference.py).

  d1_check.py features SPICE.npz OUT.json   reduce a SPICE run
  d1_check.py model [OUT.json]              the floating-point model's
                                            features and its report

Features, per 50 ms window over the 3 s scenario from 0.1 s on (the
oscillator's first charge of C63 from 0 V and the transistor taking hold
of node A come before): the means of C63 and node A, the RMS about the
mean of node A, IC53 a, IC53 b, the 4016's output node and the mixer
current through R412 (taken as volts across 51K), and the band's centre:
IC53 a's power-weighted mean frequency between 300 Hz and 3 kHz on the
48 kHz grid. Over the whole run: the times at which the oscillator
(IC53 c) switches (crossings of 6 V), also from 0.1 s on.
"""
import json
import sys
from pathlib import Path
import numpy as np
import sound_parts as P

HERE=Path(__file__).resolve().parent
WIN=0.05
T0=0.1
MEANS=["c63","na"]
RMS=["na","o1","o7","sw","i412"]
EVENTS=["o8"]
SCALE={"i412":51e3}
SPICE_NAMES={"o8":"o53_8","o1":"o53_1","o7":"o53_7"}
FS_C=48000                         # the centre's grid
# Tolerances between a model and SPICE (volts; hertz for the centre;
# seconds for the switching times); see TOL_NOTE. Floating-point model
# against the 3 s SPICE run (2 November): the largest per-window
# differences times 2.5. They come from the oscillator's phase: its first
# switch is 0.78 ms early (SPICE's supplies rise over the first
# millisecond) and the difference ends 0.57 ms late (the model's period is
# 0.045 % longer), which moves where the warble falls in a window. Then the
# band's centre differs by up to 2.7 Hz in a window (it swings about 85 Hz
# over a cycle), IC53 b's RMS by 2 % (0.0136 V of about 0.66 V).
TOL={"centre":6.7,"mean_c63":0.0076,"mean_na":0.00037,"rms_na":0.00046,"rms_o1":0.0112,
     "rms_o7":0.034,"rms_sw":0.034,"rms_i412":0.034}
TOL_EVENT={"o8":0.00194}
TOL_NOTE="docs/SOUND_LOGIC.md, D-1 checks"

def windows(t_end):
    n=int(round((t_end-T0)/WIN))
    return [(T0+k*WIN,T0+(k+1)*WIN) for k in range(n)]

def centre(t,v,a,b):
    """Power-weighted mean frequency (300 Hz .. 3 kHz) of v over [a, b),
    resampled on a 48 kHz grid."""
    tu=np.arange(a,b,1/FS_C)
    x=np.interp(tu,t,v); x=x-x.mean()
    s=np.abs(np.fft.rfft(x*np.hanning(len(x))))**2
    f=np.fft.rfftfreq(len(x),1/FS_C)
    m=(f>=300)&(f<=3000)
    return float((f[m]*s[m]).sum()/max(s[m].sum(),1e-300))

def edges(t,v,thr=6.0):
    b=v>thr
    i=np.nonzero(b[:-1]!=b[1:])[0]
    return [(float(t[k+1]),int(b[k+1])) for k in i if t[k+1]>=T0]

def features(t,d,t_end):
    w=[]
    for a,b in windows(t_end):
        m=(t>=a)&(t<b)
        f={"t":a}
        for k in MEANS: f["mean_"+k]=float(d[k][m].mean())
        for k in RMS: f["rms_"+k]=float(d[k][m].std())
        f["centre"]=centre(t,d["o1"],a,b)
        w.append(f)
    ev={k:edges(t,d[k]) for k in EVENTS}
    return {"windows":w,"events":ev}

def spice_features(npz,out):
    s=np.load(npz); t=s["t"]
    d={k:s[SPICE_NAMES.get(k,k)] for k in set(MEANS+RMS+EVENTS)}
    for k,r in SCALE.items(): d[k]=d[k]*r
    t_end=float(round(t[-1],3))
    f=features(t,d,t_end); f["t_end"]=t_end
    Path(out).write_text(json.dumps(f,indent=0)+"\n")

def model_run(t_end,model=None):
    import d1_model as M
    import d1_reference as R
    n=int(round(t_end*P.TICK_HZ))
    m=model or M.D1(R.REF_A7)
    nb=R.noise_bits(n)
    keys=sorted(set(MEANS+RMS+EVENTS))
    rec={k:np.zeros(n) for k in keys}
    for k in range(n):
        m.step(nb[k],R.slip_n(k))
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
            elif n not in TOL_EVENT: bad.append(f"{k}: no tolerance")
        elif k in TOL and e>TOL[k]:
            bad.append(f"{k}: {e:.4g} at {t:.2f} s (tolerance {TOL[k]})")
        elif k not in TOL: bad.append(f"{k}: no tolerance")
    return bad

def report(worst):
    for k,(e,t) in sorted(worst.items()):
        if k.startswith("ev_"): print(f"  {k:16s} count/direction {e}, edges within {t*1e3:.3f} ms")
        else: print(f"  {k:16s} {e:.6g} at {t:.2f} s")

if __name__=="__main__":
    if sys.argv[1]=="features": spice_features(sys.argv[2],sys.argv[3])
    elif sys.argv[1]=="model":
        ref=json.loads((HERE/"data/d1_spice_features.json").read_text())
        t,rec=model_run(ref["t_end"])
        got=features(t,rec,ref["t_end"])
        if len(sys.argv)>2: Path(sys.argv[2]).write_text(json.dumps(got,indent=0)+"\n")
        w=compare(ref,got); report(w)
        bad=failures(w)
        print(f"{len(bad)} features outside the tolerances"+("" if not bad else ": "+"; ".join(bad)))
