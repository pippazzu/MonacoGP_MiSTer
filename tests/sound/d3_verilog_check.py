#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check the D-3 Verilog run (tests/tb_snd_d3.v) three ways:
  1. jtmonacogp_snd_d3.vh is what d3_fixed.py generates now;
  2. every step equals the fixed-point twin (d3_fixed.py), bit for bit, fed
     with the inputs the testbench recorded;
  3. its waveforms, measured as d3_check.py does, are within the tolerances
     of the SPICE reference's (data/d3_spice_full_features.json).
Usage: d3_verilog_check.py OUTDIR (holding snd_d3_full.txt)"""
import filecmp
import sys
import tempfile
from pathlib import Path
import numpy as np
import d3_check as C
import d3_fixed as F
import sound_parts as P

ROOT=Path(__file__).resolve().parents[2]
KEYS=["lag","cv","o51a","o50a","o49a","o51b","o50b","o49b","con","mcin","mcout","i_mix"]

def main():
    out=Path(sys.argv[1])
    with tempfile.TemporaryDirectory() as td:
        vh=Path(td)/"d3.vh"; F.write_vh(vh)
        if not filecmp.cmp(vh,ROOT/"cores/monacogp/hdl/jtmonacogp_snd_d3.vh",shallow=False):
            print("FAIL: jtmonacogp_snd_d3.vh differs from d3_fixed.py's output; regenerate it")
            sys.exit(1)
    print("jtmonacogp_snd_d3.vh matches the generator")
    rows=np.loadtxt(out/"snd_d3_full.txt",dtype=np.int64)
    n=len(rows)
    b=F.D3Fixed(); bad=0
    for k in range(n):
        r=rows[k]
        b.step(int(r[0]),int(r[1]),int(r[2]))
        o=b.out
        exp=[o[x] for x in KEYS]
        got=[int(x) for x in r[3:]]
        if exp!=got:
            bad+=1
            if bad<=5:
                print(f"step {k}: "+", ".join(f"{x} Verilog {g} twin {e}" for x,g,e in zip(KEYS,got,exp) if g!=e))
    if bad:
        print(f"FAIL: {bad} of {n} steps differ from the fixed-point twin"); sys.exit(1)
    print(f"{n} steps equal to the fixed-point twin, bit for bit")
    s=1.0/(1<<F.FV)
    d={x:rows[:,3+i]*s for i,x in enumerate(KEYS)}
    d["mixr"]=d.pop("i_mix")+P.V6
    d["t"]=(np.arange(n)+1)*P.DT
    ref=__import__("json").loads((Path(__file__).parent/"data/d3_spice_full_features.json").read_text())
    if n<int(round(3.0*P.TICK_HZ)):
        print(f"short run ({n} steps): SPICE comparison skipped"); return
    ok,rep,worst=C.compare(ref,C.features("full",d))
    print("\n".join(rep[:60]))
    print("against the SPICE reference, largest differences: "+
          " ".join(f"{k} {v:.4g}" for k,v in sorted(worst.items())))
    if not ok:
        print("FAIL: outside the SPICE tolerances"); sys.exit(1)
    print("within the SPICE reference tolerances")

if __name__=="__main__": main()
