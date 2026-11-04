#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Compare D-3 waveforms (stepped model or Verilog) with the SPICE reference
by features measured in time windows: lag and CV levels, each oscillator's
frequency and triangle limits, the attenuation control range, and the
MC3340 / output levels and AC RMS. Phases are not compared: a frequency
difference of a fraction of a percent moves them apart within a second.

  d3_check.py features SPICE.npz OUT.json      reduce a SPICE run to features
  d3_check.py model full|cells OUT.npz         run the stepped model
  d3_check.py compare REF.json OTHER.npz|json  compare, print a report, exit 1 on failure
"""
import json
import sys
from array import array
from pathlib import Path
import numpy as np
import d3_reference as R
import sound_parts as P

SIGNALS=["lag","cv","o51a","o50a","o49a","o51b","o50b","o49b","con","mcin","mcout","mixr"]
CELLS=(("cell1","o51a","o51b"),("cell2","o50a","o50b"),("cell3","o49a","o49b"))

def windows(name):
    if name=="full":
        return [(round(a,3),round(a+0.05,3)) for a in np.arange(0.0,R.FULL_T-1e-9,0.05)]
    # each half-segment of the CV sweep, after 20 ms of settling
    return [(round(k*R.CELL_STEP+0.02,3),round((k+1)*R.CELL_STEP,3))
            for k in range(2*len(R.CELL_LEVELS))]

def long_windows(name):
    """Windows over which the mixed output's statistics are compared: they
    span many beats between the cells, whose phases are not compared."""
    if name=="full":
        return [(0.3,0.6),(0.7,1.2),(1.25,1.5),(1.55,1.8),(2.05,2.4),(2.45,3.0)]
    # the CV sweep's segments are too short for that: its mixed output is
    # checked block by block only (driven)
    return []

def edges(t,v,level):
    """Interpolated times of the rising crossings of `level`."""
    a=v[:-1]<level; b=v[1:]>=level
    k=np.nonzero(a&b)[0]
    return t[k]+(level-v[k])/(v[k+1]-v[k])*(t[k+1]-t[k])

def wstats(tt,v):
    """Time-weighted mean and RMS about it (the reference's steps are uneven)."""
    w=np.gradient(tt); mean=float(np.sum(v*w)/np.sum(w))
    return mean,float(np.sqrt(np.sum((v-mean)**2*w)/np.sum(w)))

def features(name,d):
    t=np.asarray(d["t"]); out=[]; lout=[]
    for a,b in windows(name):
        m=(t>=a)&(t<b)
        tt=t[m]; f={"t0":a,"t1":b}
        for s in ("lag","cv"): f[s]=float(np.mean(d[s][m]))
        for cell,tri,cmp in CELLS:
            e=edges(tt,d[cmp][m],0.5*(P.VOL+P.VOH))
            f[cell+"_n"]=int(len(e))
            f[cell+"_hz"]=float((len(e)-1)/(e[-1]-e[0])) if len(e)>=2 else None
            f[cell+"_min"]=float(d[tri][m].min()); f[cell+"_max"]=float(d[tri][m].max())
        out.append(f)
    for a,b in long_windows(name):
        m=(t>=a)&(t<b); tt=t[m]; f={"t0":a,"t1":b}
        for s in ("con","mcin","mcout","mixr"):
            f[s+"_mean"],f[s+"_rms"]=wstats(tt,d[s][m])
        lout.append(f)
    return {"scenario":name,"windows":out,"long":lout}

def schedule(name):
    if name=="full": return R.FULL,None,R.FULL_T
    ev,lag=R.cells_schedule(); return ev,lag,R.CELLS_T

def run_model(name):
    import d3_model as M
    ev,lag,tend=schedule(name)
    n=int(round(tend*P.TICK_HZ))
    d3=M.D3(); rec={s:array("d") for s in SIGNALS}; ts=array("d")
    ev=R.event_ticks(ev,P.TICK_HZ); ei=0
    code,sh,on=ev[0][1:]
    if lag is not None:
        pts=R.steps(lag,R.LAG_EDGE)
        force=np.interp(np.arange(n)*P.DT,[p[0] for p in pts],[p[1] for p in pts]).tolist()
    for k in range(n):
        while ei<len(ev) and ev[ei][0]<=k: code,sh,on=ev[ei][1:]; ei+=1
        if lag is not None: d3.lag_force=force[k]
        d3.step(code,sh,on)
        o=d3.out
        ts.append((k+1)*P.DT)
        for s in SIGNALS: rec[s].append(o[s])
    res={s:np.frombuffer(v,dtype=float) for s,v in rec.items()}
    res["t"]=np.frombuffer(ts,dtype=float)
    return res

def driven(name,d):
    """Drive each block of the stepped model with the reference's own input
    waveforms (resampled at the model step) and compare its outputs point by
    point. Returns {check: (max |error|, rms error)}."""
    import d3_model as M
    ev,lag,tend=schedule(name)
    n=int(round(tend*P.TICK_HZ))
    tk=(np.arange(n)+1)*P.DT
    ref={s:np.interp(tk,d["t"],d[s]) for s in ("lag","cv","o51a","o50a","o49a","con","mcin","mcout","swo","mixr")}
    code=np.zeros(n,dtype=int); sh=np.zeros(n,dtype=int); on=np.zeros(n,dtype=int)
    for k,c,a,b in R.event_ticks(ev,P.TICK_HZ):
        code[k:]=c; sh[k:]=a; on[k:]=b
    if lag is not None:
        pts=R.steps(lag,R.LAG_EDGE)
        force=np.interp(tk-P.DT,[p[0] for p in pts],[p[1] for p in pts])
    m=M.D3(); res={s:np.zeros(n) for s in ("lag","cv","con","mcin","mcout","mixr")}
    rc=ref["cv"].tolist(); r1=ref["o51a"].tolist(); r2=ref["o50a"].tolist(); r3=ref["o49a"].tolist()
    rcon=ref["con"].tolist(); rmc=ref["mcout"].tolist()
    lagv=res["lag"]; cvv=res["cv"]; conv=res["con"]; mcinv=res["mcin"]; mcov=res["mcout"]; mixv=res["mixr"]
    for k in range(n):
        if lag is not None: m.lag_force=force[k]
        cvv[k]=m.lag_cv(int(code[k]),int(sh[k])); lagv[k]=m.lag
        conv[k]=m.amctl(rc[k],r1[k])
        _,mcinv[k],mcov[k]=m.busmc(r2[k],r3[k],rcon[k])
        _,i72=m.output(rmc[k],P.R_4016,int(on[k])); mixv[k]=i72*100e3+P.V6
    # IC52's unloaded output, from the reference's loaded one
    unl=ref["mcout"]+np.where(on>0,P.R_MC_OUT*(ref["mcout"]-ref["swo"])/P.R_4016,0.0)
    # skip the first millisecond (the reference's amplifiers start from 0 V
    # and slew) and 100 us after every input change (the reference's
    # followers slew; the model's are immediate)
    keep=tk>1e-3
    for t in [e[0] for e in ev]+([p[0] for p in lag] if lag is not None else []):
        keep&=~((tk>=t)&(tk<t+100e-6+(R.LAG_EDGE if lag is not None else 0)))
    # IC52's output is not compared while its input is in the clamp (above
    # 4.3 V, only in the first 50 ms after power-on), where the output
    # collapses within a few millivolts of input
    keep_mc=keep&(ref["mcin"]<4.3)
    out={}
    for s,r in (("lag",ref["lag"]),("cv",ref["cv"]),("con",ref["con"]),("mcin",ref["mcin"]),
                ("mcout",unl),("mixr",ref["mixr"])):
        kk=keep_mc if s=="mcout" else keep
        e=np.where(kk,res[s]-r,0.0)
        k=int(np.argmax(abs(e)))
        out[s]=(float(abs(e).max()),float(np.sqrt((e[kk]**2).mean())),float(tk[k]))
    return out

# Closed-loop tolerances. Levels in volts; frequencies relative; the mixed
# output's RMS relative (its beats are compared over long windows only).
TOL={"lag":0.002,"cv":0.005,"hz":0.01,"tri":0.03,"mean":0.1,"rms":0.1}
# Driven (block by block, point by point) tolerances: (max, rms) volts
TOL_DRIVEN={"lag":(0.002,0.001),"cv":(0.002,0.001),"con":(0.1,0.015),"mcin":(0.05,0.01),
            "mcout":(0.1,0.02),"mixr":(0.002,0.001)}

def compare(ref,oth):
    rows=[]; worst={}; allok=True
    def chk(key,a,b,tol,rel=False):
        err=abs(b-a)/abs(a) if rel else abs(b-a)
        worst[key]=max(worst.get(key,0.0),err)
        if err>tol:
            rows.append(f"  {key}: reference {a:.5g}, model {b:.5g}")
            return False
        return True
    for fr,fo in zip(ref["windows"],oth["windows"]):
        assert fr["t0"]==fo["t0"]
        n0=len(rows); ok=True
        for s in ("lag","cv"): ok&=chk(s,fr[s],fo[s],TOL[s])
        for cell,_,_ in CELLS:
            if abs(fr[cell+"_n"]-fo[cell+"_n"])>1:
                rows.append(f"  {cell}: {fr[cell+'_n']} rising edges in the reference, {fo[cell+'_n']} in the model")
                ok=False
            if fr[cell+"_hz"] is not None and fo[cell+"_hz"] is not None:
                ok&=chk(cell+"_hz",fr[cell+"_hz"],fo[cell+"_hz"],TOL["hz"],True)
            # the limits only where the cell runs (several periods)
            if fr[cell+"_n"]>=3:
                for q in ("_min","_max"): ok&=chk(cell+q,fr[cell+q],fo[cell+q],TOL["tri"])
        if not ok:
            allok=False; rows.insert(n0,f"window {fr['t0']}-{fr['t1']} s:")
    for fr,fo in zip(ref["long"],oth["long"]):
        n0=len(rows); ok=True
        for s in ("con","mcin","mcout","mixr"):
            ok&=chk(s+"_mean",fr[s+"_mean"],fo[s+"_mean"],TOL["mean"])
            ok&=chk(s+"_rms",fr[s+"_rms"],fo[s+"_rms"],TOL["rms"],True)
        if not ok:
            allok=False; rows.insert(n0,f"long window {fr['t0']}-{fr['t1']} s:")
    return allok,rows,worst

def main():
    cmd=sys.argv[1]
    if cmd=="features":
        name=Path(sys.argv[2]).stem.split("_")[-1]
        d=dict(np.load(sys.argv[2]))
        Path(sys.argv[3]).write_text(json.dumps(features(name,d)))
    elif cmd=="driven":
        name=Path(sys.argv[2]).stem.split("_")[-1]
        ok=True
        for k,(mx,rms,tw) in driven(name,dict(np.load(sys.argv[2]))).items():
            good=mx<=TOL_DRIVEN[k][0] and rms<=TOL_DRIVEN[k][1]; ok&=good
            print(f"{k:6s} max {mx:.4f} V (at {tw:.4f} s)  rms {rms:.5f} V  {'ok' if good else 'FAIL'}")
        print("PASS" if ok else "FAIL")
        sys.exit(0 if ok else 1)
    elif cmd=="model":
        np.savez_compressed(sys.argv[3],**run_model(sys.argv[2]))
    elif cmd=="compare":
        ref=json.loads(Path(sys.argv[2]).read_text())
        p=Path(sys.argv[3])
        oth=json.loads(p.read_text()) if p.suffix==".json" else features(ref["scenario"],dict(np.load(p)))
        ok,rows,worst=compare(ref,oth)
        print("\n".join(rows[:80]))
        print("largest differences:"," ".join(f"{k} {v:.4g}" for k,v in sorted(worst.items())))
        print("PASS" if ok else "FAIL")
        sys.exit(0 if ok else 1)

if __name__=="__main__": main()
