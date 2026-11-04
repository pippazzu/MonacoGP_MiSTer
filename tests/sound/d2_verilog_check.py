#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""The D-2 rescue siren and back sound against their fixed-point twin and
the SPICE reference.

  d2_verilog_check.py stim OUTDIR [STEPS]   write the testbench's inputs
                                            (OUTDIR/d2_stim.txt)
  d2_verilog_check.py check OUTDIR          check tests/tb_snd_d2.v's run:
      1. jtmonacogp_snd_d2.vh is what d2_fixed.py generates now;
      2. every step of OUTDIR/snd_d2_steps.txt equals the fixed-point twin
         (d2_fixed.D2Fixed), bit for bit;
      3. (full run) its window features are within the tolerances of the
         SPICE reference's (data/d2_spice_features.json, d2_check.py).
"""
import filecmp
import json
import sys
import tempfile
from pathlib import Path
import numpy as np
import sound_parts as P
import d2_check as F
import d2_reference as R
import d2_fixed as X

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
N_STEPS=int(round(R.T_END*P.TICK_HZ))
COLS=["i_mix","padr","env_r","env_f","con41","con45","mc41o","mc45o",
      "o40_7","z","o44_7","o42_1","o43_7","i410","i424",
      "tri","o40_1","o555","o42_8","o43_14","o43_1","o44_14"]
FLAGS=("o555","o42_8","o43_14","o43_1","o44_14")

def stim(outdir,n=N_STEPS):
    out=Path(outdir); out.mkdir(parents=True,exist_ok=True)
    R.write_stim(out/"d2_stim.txt",n)

def check(outdir):
    out=Path(outdir)
    with tempfile.TemporaryDirectory() as td:
        X.write_vh(Path(td)/"jtmonacogp_snd_d2.vh")
        if not filecmp.cmp(Path(td)/"jtmonacogp_snd_d2.vh",
                           ROOT/"cores/monacogp/hdl/jtmonacogp_snd_d2.vh",shallow=False):
            print("FAIL: jtmonacogp_snd_d2.vh differs from what d2_fixed.py generates")
            sys.exit(1)
    tw=X.D2Fixed(); c=X.C; n=0; bad=0; rows=[]; latest=0
    with open(out/"snd_d2_steps.txt") as fh:
        for line in fh:
            resc,mute,bko=R.inputs(n)
            i,pr=tw.step(resc,mute,X.vq(bko-P.V6))
            o=tw.out
            exp=[i,pr]+[o[k] for k in COLS[2:17]]+[int(o["o555"])]+ \
                [int(o[k]==c["VOH"]) for k in FLAGS[1:]]
            got=[int(v) for v in line.split()]
            latest=max(latest,got[-1]); got=got[:-1]
            rows.append(got)
            if got!=exp:
                bad+=1
                if bad<=5:
                    diff=[f"{k} {g} twin {e}" for k,g,e in zip(COLS,got,exp) if g!=e]
                    print(f"step {n}: "+"; ".join(diff))
            n+=1
    if bad: print(f"FAIL: {bad} of {n} steps differ from the fixed-point twin"); sys.exit(1)
    print(f"{n} steps equal to the fixed-point twin, bit for bit; done by clock {latest}")
    if n<N_STEPS:
        print(f"short run ({n} of {N_STEPS} steps): no comparison with SPICE")
        return n
    features(np.array(rows[:N_STEPS],dtype=np.float64))
    return n

def features(a):
    """Step 3: the run's window features against the SPICE reference's.
    Signals are 2^28 per volt; i_mix is the R410 and R424 currents times
    R414 (22K), i410 and i424 are volts across R410 and R424; the flags are
    0 or 1."""
    ref=json.loads((HERE/"data/d2_spice_features.json").read_text())
    n=a.shape[0]
    t=(np.arange(n)+1)*P.DT        # a step's values hold at its end
    d={k:a[:,i]/float(1<<28) for i,k in enumerate(COLS)}
    for k in FLAGS: d[k]=a[:,COLS.index(k)]*12.0
    got=F.features(t,d,ref["t_end"])
    w=F.compare(ref,got); F.report(w)
    bad=F.failures(w)
    if bad:
        print(f"FAIL: {len(bad)} features outside the tolerances: "+"; ".join(bad))
        sys.exit(1)
    print("window features within the tolerances of the SPICE reference")

if __name__=="__main__":
    if sys.argv[1]=="stim": stim(sys.argv[2],int(sys.argv[3]) if len(sys.argv)>3 else N_STEPS)
    elif sys.argv[1]=="check": check(sys.argv[2])
