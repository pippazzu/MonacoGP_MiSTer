#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""The D-4 sound sources (explosion, skid tone, EXTEND beep) against their
fixed-point twin and the SPICE reference.

  d4_verilog_check.py stim OUTDIR            write the testbench's inputs
                                             (OUTDIR/d4_stim.txt)
  d4_verilog_check.py check OUTDIR           check tests/tb_snd_d4.v's run:
      1. the three .vh files are what d4s_fixed.py generates now;
      2. every step of OUTDIR/snd_d4_steps.txt equals the fixed-point twin
         (d4s_fixed.D4Fixed), bit for bit;
      3. its window features are within the tolerances of the SPICE
         reference's (data/d4_spice_features.json).
  d4_verilog_check.py features SPICE.npz OUT.json   reduce a SPICE run
  d4_verilog_check.py model OUT.json         the floating-point model's
                                             features (and its report)

Features, per 50 ms window over the 2 s scenario: the mean and RMS of the
noise amplifier, both band-passes, both MC3340 outputs, IC66 a, the
envelopes and controls, the 555's CONTROL and the mixer currents (times
R414); the 555's output cycles and the triangle's rising crossings of
5.75 V (with 0.5 V of hysteresis either side, so that noise on a slow edge
counts once). The first window starts at 1 ms: at power-on SPICE's op-amps
slew from 0 V for some 15 us, which the model (op-amps at their limits or
virtual ground from the first step) leaves out. Over the whole run: the
555's cycles and the triangle's mean period. Waveforms with the same noise
agree closely (the noise is the same bits in both), but the 555 and the
triangle drift in phase, so they are compared by their counts; the
triangle's phase also moves CONTROL's 50 ms means, hence its tolerance.
The band-passes come out about 1.5 % louder than SPICE's (their Euler
step), and that carries through the MC3340s and IC66 a.
"""
import filecmp
import json
import sys
import tempfile
from pathlib import Path
import numpy as np
import sound_parts as P
import d4_model as M
import d4_reference as R
import d4s_fixed as X

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
N_STEPS=int(round(R.T_END*P.TICK_HZ))
WIN=0.05
COLS=["namp","tri","o63d","ctl555","thtr","out555","bpu","bpl","envu","envl","conu","conl",
      "mciu","mcil","mcou","mcol","expo","i401","isk","q61a","q61b"]
LEVELS=["namp","bpu","bpl","envu","envl","conu","conl","mcou","mcol","expo","ctl555","i401","isk"]
TRI_MID=5.75
# Tolerances between a model and SPICE (volts; counts per window; relative
# for the whole run). Set on 2 November 2026 at about 2.5 times the float
# model's largest difference over the 40 windows (below), with a floor of
# 2 mV and of one 555 cycle per window, so that a change that moves a level
# is caught:
#   means: namp 0.0002, bpu 0.0008, bpl 0.0006, envu 0.0033, envl 0.0092,
#     conu 0.0005, conl 0.0008, mcou 0.0053, mcol 0.0021, expo 0.016,
#     ctl555 0.028 (the triangle's phase: CONTROL carries 0.5 V of it),
#     i401 0.0015, isk 0.0004;
#   RMS: namp 0.0075, bpu 0.033 (of 2 V: the Euler step's +2 % peak gain),
#     bpl 0.0073, envu 0.0018, envl 0.0055, conu 0.0011, conl 0.0005,
#     mcou 0.018, mcol 0.0085, expo 0.045 (of up to 4.5 V: the band-passes'
#     gain carried through), ctl555 0.0069, i401 0.0045, isk 0.0004;
#   555 cycles 4 in a window (phase), 0.15 % over the run; triangle 1 in a
#     window, its period 0.12 %.
TOL={"mean":{"namp":0.002,"bpu":0.003,"bpl":0.003,"envu":0.01,"envl":0.02,"conu":0.003,"conl":0.003,
             "mcou":0.006,"mcol":0.005,"expo":0.04,"ctl555":0.07,"i401":0.004,"isk":0.002},
     "rms":{"namp":0.02,"bpu":0.08,"bpl":0.02,"envu":0.005,"envl":0.015,"conu":0.003,"conl":0.003,
            "mcou":0.05,"mcol":0.025,"expo":0.12,"ctl555":0.02,"i401":0.012,"isk":0.002},
     "cyc555":8,"tri":1,"cyc555_rel":0.004,"tri_period_rel":0.003}
T_SETTLE=1e-3
TRI_HYST=0.5

def windows():
    return [(max(round(a,3),T_SETTLE),round(a+WIN,3)) for a in np.arange(0.0,R.T_END-1e-9,WIN)]

def rising(t,v,lo,hi):
    """Times at which v rises above hi, having been below lo since the last."""
    up=v>hi; dn=v<lo; out=[]; st=bool(up[0])
    idx=np.flatnonzero(up|dn)
    for i in idx:
        if st and dn[i]: st=False
        elif not st and up[i]: st=True; out.append(t[i])
    return np.array(out)

def features(t,d):
    """d: name -> array over times t (seconds). Returns the windows and
    the totals."""
    t=np.asarray(t); out=[]
    w=np.gradient(t)
    e555=rising(t,np.asarray(d["out555"]),1.0,1.0+1e-9)
    etri=rising(t,np.asarray(d["tri"]),TRI_MID-TRI_HYST,TRI_MID+TRI_HYST)
    for a,b in windows():
        m=(t>=a)&(t<b); f={"t0":a,"t1":b}; ww=w[m]
        for s in LEVELS:
            v=np.asarray(d[s])[m]; mean=float(np.sum(v*ww)/np.sum(ww))
            f[s+"_mean"]=mean; f[s+"_rms"]=float(np.sqrt(np.sum((v-mean)**2*ww)/np.sum(ww)))
        f["cyc555"]=int(np.sum((e555>=a)&(e555<b)))
        f["tri"]=int(np.sum((etri>=a)&(etri<b)))
        out.append(f)
    tot={"cyc555":len(e555),"tri_period":float(np.mean(np.diff(etri)))}
    return out,tot

def spice_features(npz,out):
    d=dict(np.load(npz))
    d["i401"]=d["i401"]*X.R414; d["isk"]=(d["i402"]+d["i403"])*X.R414
    w,tot=features(d["t"],d)
    Path(out).write_text(json.dumps({"windows":w,"totals":tot},indent=1)+"\n")

def model_run():
    d4=M.D4(); keys=LEVELS+["out555","tri"]; rec={k:np.zeros(N_STEPS) for k in keys}
    for k in range(N_STEPS):
        tt,sk,ex=R.inputs(k)
        i401,i402,i403=d4.step(tt,sk,ex)
        o=d4.out
        for s in keys:
            if s=="i401": rec[s][k]=i401*X.R414
            elif s=="isk": rec[s][k]=(i402+i403)*X.R414
            else: rec[s][k]=o[s]
    return (np.arange(N_STEPS)+1)*P.DT,rec

def compare(refj,got):
    """refj: the stored SPICE features; got: (windows, totals). Returns the
    failures and the largest difference of each feature."""
    ref=refj["windows"]; rt=refj["totals"]; got,gt=got
    bad=[]; worst={}
    for s in ("cyc555","tri_period"):
        e=abs(gt[s]/rt[s]-1); worst[s+"_rel"]=(e,0.0)
        if e>TOL[s+"_rel"]: bad.append(f"whole run {s}: SPICE {rt[s]:.6g}, here {gt[s]:.6g}")
    for r,g in zip(ref,got):
        for s in LEVELS:
            for kind in ("mean","rms"):
                e=abs(r[f"{s}_{kind}"]-g[f"{s}_{kind}"]); key=f"{s}_{kind}"
                if e>worst.get(key,(0,0))[0]: worst[key]=(e,r["t0"])
                if e>TOL[kind][s]: bad.append(f"{r['t0']:.2f} s {key}: SPICE {r[key]:.4f}, here {g[key]:.4f}")
        for s in ("cyc555","tri"):
            e=abs(r[s]-g[s])
            if e>worst.get(s,(0,0))[0]: worst[s]=(e,r["t0"])
            if e>TOL[s]: bad.append(f"{r['t0']:.2f} s {s}: SPICE {r[s]}, here {g[s]}")
    return bad,worst

def report(worst):
    print("against the SPICE reference, largest differences: "+
          " ".join(f"{k} {v[0]:.4g}" for k,v in sorted(worst.items())))

def check(outdir):
    out=Path(outdir)
    with tempfile.TemporaryDirectory() as td:
        X.write_vh(td)
        for n in ("noise","band","expl"):
            f=f"jtmonacogp_snd_{n}.vh"
            if not filecmp.cmp(Path(td)/f,ROOT/"cores/monacogp/hdl"/f,shallow=False):
                print(f"FAIL: {f} differs from d4s_fixed.py's output; regenerate it"); sys.exit(1)
    print("jtmonacogp_snd_noise.vh, _band.vh, _expl.vh match the generator")
    twin=X.D4Fixed(); bad=0; n=0
    sc=1.0/(1<<X.FV)
    rec={s:np.zeros(N_STEPS) for s in LEVELS+["out555","tri"]}
    with open(out/"snd_d4_steps.txt") as fh:
        for k,line in enumerate(fh):
            got=[int(v) for v in line.split()]
            tt,sk,ex=R.inputs(k)
            isk_x=None
            namp,isk=twin.noise.step(sk,ex)
            i401=twin.expl.step(tt,namp)
            no,bu,bl,eo=twin.noise.out,twin.expl.bu.out,twin.expl.bl.out,twin.expl.out
            exp=[namp,no["tri"],no["o63d"],no["ctl555"],no["thtr"],int(no["out555"]),
                 bu["bp"],bl["bp"],bu["env"],bl["env"],bu["con"],bl["con"],bu["mcin"],bl["mcin"],
                 bu["mco"],bl["mco"],eo["expo"],i401,isk,int(eo["q61a"]),int(eo["q61b"])]
            if got!=exp:
                bad+=1
                if bad<=5:
                    diff=[f"{c} {g} twin {e}" for c,g,e in zip(COLS,got,exp) if g!=e]
                    print(f"step {k}: "+"; ".join(diff))
            v=dict(zip(COLS,got))
            for s in LEVELS: rec[s][k]=v[s]*sc
            rec["out555"][k]=M.V555_HI if v["out555"] else M.V555_LO
            rec["tri"][k]=v["tri"]*sc
            n+=1
    if n!=N_STEPS: print(f"FAIL: {n} steps, expected {N_STEPS}"); sys.exit(1)
    if bad: print(f"FAIL: {bad} of {n} steps differ from the fixed-point twin"); sys.exit(1)
    print(f"{n} steps equal to the fixed-point twin, bit for bit")
    ref=json.loads((HERE/"data/d4_spice_features.json").read_text())
    fails,worst=compare(ref,features((np.arange(N_STEPS)+1)*P.DT,rec))
    report(worst)
    if fails:
        for f in fails[:10]: print("  "+f)
        print(f"FAIL: {len(fails)} features outside the SPICE tolerances"); sys.exit(1)
    print("within the SPICE reference tolerances")

if __name__=="__main__":
    cmd=sys.argv[1]
    if cmd=="stim": R.write_stim(Path(sys.argv[2])/"d4_stim.txt",N_STEPS)
    elif cmd=="check": check(sys.argv[2])
    elif cmd=="features": spice_features(sys.argv[2],sys.argv[3])
    elif cmd=="model":
        t,rec=model_run(); f=features(t,rec)
        Path(sys.argv[2]).write_text(json.dumps({"windows":f[0],"totals":f[1]},indent=1)+"\n")
        ref=HERE/"data/d4_spice_features.json"
        if ref.is_file():
            fails,worst=compare(json.loads(ref.read_text()),f)
            report(worst)
            for x in fails[:20]: print("  "+x)
            print(f"{len(fails)} features outside the tolerances")
