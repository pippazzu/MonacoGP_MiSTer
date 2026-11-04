#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""The D-5 hi-score tune against its fixed-point twin and the SPICE
reference.

  d5_verilog_check.py stim OUTDIR [STEPS]   write the testbench's inputs
                                            (OUTDIR/d5_stim.txt) and the
                                            reference's include
                                            (OUTDIR/d5ref/jtmonacogp_snd_d5_ref.vh)
  d5_verilog_check.py check OUTDIR ROM [nospice]
                                            check tests/tb_snd_d5.v's run,
                                            whose PROM came from ROM
                                            (proms.hex):
      1. jtmonacogp_snd_d5.vh is what d5_fixed.py generates now;
      2. every step of OUTDIR/snd_d5_steps.txt equals the fixed-point twin
         (d5_fixed.D5Fixed with the reference's settings and that PROM),
         bit for bit;
      3. (full run, unless nospice) its window features are within the
         tolerances of the SPICE reference's (data/d5_spice_features.json,
         d5_check.py). The reference was made with the original PROM, so
         a run on another image (run_tests.py --synthetic) skips this.
The testbench runs the module with the reference's trimmers and test tempo
(the D5_REF include); the core's own settings differ only in those
constants, which step 1 checks.
"""
import filecmp
import json
import sys
import tempfile
from pathlib import Path
import numpy as np
import sound_parts as P
import d5_check as F
import d5_model as M
import d5_reference as R
import d5_fixed as X

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
N_STEPS=int(round(R.T_END*P.TICK_HZ))
COLS=["i_mix","lfo","cvu","cvl","sawu","sawl","mix","lp","hp","env","con","mco",
      "addr","cnt","q123","alarm","clk"]

def stim(outdir,n=N_STEPS):
    out=Path(outdir); out.mkdir(parents=True,exist_ok=True)
    with open(out/"d5_stim.txt","w") as f:
        f.write(f"{n}\n")
        for k in range(n): f.write(f"{R.hiscore_n(k)} 0\n")
    (out/"d5ref").mkdir(exist_ok=True)
    X.write_vh(out/"d5ref"/"jtmonacogp_snd_d5_ref.vh",X.ref_build())

def check(outdir,rom,spice=True):
    out=Path(outdir)
    with tempfile.TemporaryDirectory() as td:
        X.write_vh(Path(td)/"jtmonacogp_snd_d5.vh")
        if not filecmp.cmp(Path(td)/"jtmonacogp_snd_d5.vh",
                           ROOT/"cores/monacogp/hdl/jtmonacogp_snd_d5.vh",shallow=False):
            print("FAIL: jtmonacogp_snd_d5.vh differs from what d5_fixed.py generates")
            sys.exit(1)
    tw=X.D5Fixed(X.ref_build(),M.load_prom_hex(rom)); n=0; bad=0; rows=[]; latest=0
    for line in (out/"snd_d5_steps.txt").read_text().splitlines():
        i=tw.step(R.hiscore_n(n),0)
        o=tw.out
        exp=[i]+[int(o[k]) for k in COLS[1:]]
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
    if n<N_STEPS or not spice:
        print(f"no comparison with SPICE ("+(f"short run, {n} of {N_STEPS} steps" if n<N_STEPS
              else "not the original PROM set")+")")
        return n
    features(np.array(rows[:N_STEPS],dtype=np.float64))
    return n

def features(a):
    """Step 3: the run's window features against the SPICE reference's.
    Signals are 2^28 per volt; i_mix is the R408 current times R414,
    taken back to volts across 39K as the features want."""
    ref=json.loads((HERE/"data/d5_spice_features.json").read_text())
    n=a.shape[0]
    t=(np.arange(n)+1)*P.DT
    d={k:a[:,i]/float(1<<28) for i,k in enumerate(COLS[:12])}
    d["i408"]=d["i_mix"]*(39e3/X.R414)
    got=F.features(t,d,ref["t_end"])
    w=F.compare(ref,got); F.report(w)
    bad=F.failures(w)
    if bad:
        print(f"FAIL: {len(bad)} features outside the tolerances: "+"; ".join(bad))
        sys.exit(1)
    print("window features within the tolerances of the SPICE reference")

if __name__=="__main__":
    if sys.argv[1]=="stim": stim(sys.argv[2],int(sys.argv[3]) if len(sys.argv)>3 else N_STEPS)
    elif sys.argv[1]=="check": check(sys.argv[2],sys.argv[3],sys.argv[4:5]!=["nospice"])
