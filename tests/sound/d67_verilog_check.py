#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""The D-6/D-7 other-car sounds against their fixed-point twin and the
SPICE reference.

  d67_verilog_check.py stim OUTDIR [STEPS]   write the testbench's inputs
                                             (OUTDIR/d67_stim.txt)
  d67_verilog_check.py check OUTDIR          check tests/tb_snd_d67.v's run:
      1. jtmonacogp_snd_d67.vh is what d67_fixed.py generates now;
      2. every step of OUTDIR/snd_d67_steps.txt equals the fixed-point twin
         (d67_fixed.D67Fixed), bit for bit;
      3. (full run) its window features are within the tolerances of the
         SPICE reference's (data/d67_spice_features.json, d67_check.py), and
         IC32 b and the banks' output nodes do not flip between steps
         (d67_check.flips).
"""
import filecmp
import json
import sys
import tempfile
from pathlib import Path
import numpy as np
import sound_parts as P
import d67_check as F
import d67_reference as R
import d67_fixed as X

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
N_STEPS=int(round(R.T_END*P.TICK_HZ))
COLS=["i_mf","i_mb","front","r6","feed","r14","r28","u1","u2",
      "con20","con19","con34","con33","cv1","cv2",
      "q59a","q59b","q58","c292","c2913",
      "o1","o2","o3","con1","con2","o1b","snd1","snd2"]

def stim(outdir,n=N_STEPS):
    out=Path(outdir); out.mkdir(parents=True,exist_ok=True)
    R.write_stim(out/"d67_stim.txt",n)

def check(outdir):
    out=Path(outdir)
    with tempfile.TemporaryDirectory() as td:
        X.write_vh(Path(td)/"jtmonacogp_snd_d67.vh")
        if not filecmp.cmp(Path(td)/"jtmonacogp_snd_d67.vh",
                           ROOT/"cores/monacogp/hdl/jtmonacogp_snd_d67.vh",shallow=False):
            print("FAIL: jtmonacogp_snd_d67.vh differs from what d67_fixed.py generates")
            sys.exit(1)
    tw=X.D67Fixed(); n=0; bad=0; rows=[]
    with open(out/"snd_d67_steps.txt") as fh:
        for line in fh:
            acc,low=R.inputs(n)
            i=tw.step(acc,low)
            o=tw.out
            exp=[i,o["i_mb"],o["front"],o["r6"],o["feed"],o["r14"],o["r28"],o["u1"],o["u2"],
                 o["con20"],o["con19"],o["con34"],o["con33"],o["cv1"],o["cv2"],
                 int(o["q59a"]),int(o["q59b"]),int(o["q58"]),int(o["c292"]),int(o["c2913"]),
                 o["o1"],o["o2"],o["o3"],o["con1"],o["con2"],o["o1b"],o["snd1"],o["snd2"]]
            got=[int(v) for v in line.split()]
            rows.append(got)
            if got!=exp:
                bad+=1
                if bad<=5:
                    diff=[f"{c} {g} twin {e}" for c,g,e in zip(COLS,got,exp) if g!=e]
                    print(f"step {n}: "+"; ".join(diff))
            n+=1
    if bad: print(f"FAIL: {bad} of {n} steps differ from the fixed-point twin"); sys.exit(1)
    print(f"{n} steps equal to the fixed-point twin, bit for bit")
    if n<N_STEPS:
        print(f"short run ({n} of {N_STEPS} steps): no comparison with SPICE")
        return n
    features(np.array(rows[:N_STEPS],dtype=np.float64))
    return n

def features(a):
    """Step 3: the run's window features against the SPICE reference's.
    Signals are 2^28 per volt; i_mf and i_mb are already currents times
    R414 and 51K; the one-shots are 0 or 1."""
    ref=json.loads((HERE/"data/d67_spice_features.json").read_text())
    n=a.shape[0]
    t=(np.arange(n)+1)*P.DT        # a step's values hold at its end
    d={c:a[:,i]/float(1<<28) for i,c in enumerate(COLS)}
    for c in ("q59a","q59b","q58","c292","c2913"): d[c]=a[:,COLS.index(c)]
    got=F.features(t,d,ref["t_end"])
    w=F.compare(ref,got); F.report(w)
    fl=F.flips(d)
    bad=F.failures(w)+F.flip_failures(fl)
    print("flips:"," ".join(f"{k} {v}" for k,v in fl.items()))
    print("events: spice",ref["events"]); print("        verilog",got["events"])
    if bad:
        print(f"FAIL: {len(bad)} features outside the tolerances: "+"; ".join(bad))
        sys.exit(1)
    print("window features within the tolerances of the SPICE reference; no step flips")

if __name__=="__main__":
    if sys.argv[1]=="stim": stim(sys.argv[2],int(sys.argv[3]) if len(sys.argv)>3 else N_STEPS)
    elif sys.argv[1]=="check": check(sys.argv[2])
