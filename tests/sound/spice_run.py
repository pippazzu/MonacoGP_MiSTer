# SPDX-License-Identifier: GPL-3.0-or-later
"""Run an ngspice netlist in batch mode and read the vectors it writes.

The netlist's .control block writes its results with `wrdata`; this module
appends that block, runs ngspice and parses the columns. Used by the sound
reference scripts (tests/sound/*.py)."""
import os
import subprocess
import tempfile
from pathlib import Path

SPICE_DIR=Path(__file__).resolve().parent/"spice"

def run(netlist,control,vectors,timeout=3600,save_only=False):
    """netlist: circuit text without .control/.end. control: analysis lines.
    vectors: names to write. Returns (x, {name: list}) where x is the scale.
    save_only: keep only these vectors in memory during the analysis
    (ngspice otherwise keeps every node's, gigabytes on a long run)."""
    with tempfile.TemporaryDirectory() as td:
        out=Path(td)/"out.txt"
        cir=Path(td)/"in.cir"
        body=netlist+"\n.control\nset wr_singlescale\nset wr_vecnames\n"+ \
             ("save "+" ".join(vectors)+"\n" if save_only else "")+control+ \
             f"\nwrdata {out} "+" ".join(vectors)+"\nquit\n.endc\n.end\n"
        cir.write_text(body)
        r=subprocess.run(["ngspice","-b",str(cir)],cwd=SPICE_DIR,stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT,text=True,timeout=timeout)
        if not out.is_file():
            raise RuntimeError("ngspice wrote no data:\n"+r.stdout[-4000:])
        for bad in ("Timestep too small","simulation(s) aborted","doAnalyses:"):
            if bad in r.stdout:
                raise RuntimeError(f"ngspice: {bad}\n"+r.stdout[-4000:])
        lines=out.read_text().split("\n")
        names=lines[0].split()
        cols=[[] for _ in names]
        for ln in lines[1:]:
            parts=ln.split()
            if len(parts)!=len(names): continue
            for i,p in enumerate(parts): cols[i].append(float(p))
        return cols[0],{n:cols[i] for i,n in enumerate(names) if i}
