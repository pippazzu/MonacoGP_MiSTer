#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""The D-1 slip-zone sound against its fixed-point twin and the SPICE
reference.

  d1_verilog_check.py stim OUTDIR [STEPS]   write the testbench's inputs
                                            (OUTDIR/d1_stim.txt)
  d1_verilog_check.py check OUTDIR          check tests/tb_snd_d1.v's run:
      1. jtmonacogp_snd_d1.vh is what d1_fixed.py generates now;
      2. every step of OUTDIR/snd_d1_steps.txt equals the fixed-point twin
         (d1_fixed.D1Fixed at the reference's VR7 setting), bit for bit;
      3. (full run) its window features are within the tolerances of the
         SPICE reference's (data/d1_spice_features.json, d1_check.py).
The core's VR7 setting (d1_model.VR7_A7) must be the reference's
(d1_reference.REF_A7), so that the module checked is the one built.
"""
import filecmp
import json
import sys
import tempfile
from pathlib import Path
import numpy as np
import sound_parts as P
import d1_check as F
import d1_model as M
import d1_reference as R
import d1_fixed as X

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
N_STEPS=int(round(R.T_END*P.TICK_HZ))
COLS=["i_mix","c63","o8","na","o1","o7","sw"]

def stim(outdir,n=N_STEPS):
    out=Path(outdir); out.mkdir(parents=True,exist_ok=True)
    R.write_stim(out/"d1_stim.txt",n)

def check(outdir):
    out=Path(outdir)
    if M.VR7_A7!=R.REF_A7:
        print(f"FAIL: VR7 in the core ({M.VR7_A7}) is not the SPICE reference's ({R.REF_A7})")
        sys.exit(1)
    with tempfile.TemporaryDirectory() as td:
        X.write_vh(Path(td)/"jtmonacogp_snd_d1.vh")
        if not filecmp.cmp(Path(td)/"jtmonacogp_snd_d1.vh",
                           ROOT/"cores/monacogp/hdl/jtmonacogp_snd_d1.vh",shallow=False):
            print("FAIL: jtmonacogp_snd_d1.vh differs from what d1_fixed.py generates")
            sys.exit(1)
    tw=X.D1Fixed(); n=0; bad=0; rows=[]; latest=0
    lines=(out/"snd_d1_steps.txt").read_text().splitlines()
    nb=R.noise_bits(len(lines))
    for line in lines:
        i=tw.step(nb[n],R.slip_n(n))
        o=tw.out
        exp=[i]+[o[k] for k in COLS[1:]]
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
    Signals are 2^28 per volt; i_mix is the R412 current times R414 (22K),
    taken back to volts across R412 as the features want."""
    ref=json.loads((HERE/"data/d1_spice_features.json").read_text())
    n=a.shape[0]
    t=(np.arange(n)+1)*P.DT
    d={k:a[:,i]/float(1<<28) for i,k in enumerate(COLS)}
    d["i412"]=d["i_mix"]*(M.R412/X.R414)
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
