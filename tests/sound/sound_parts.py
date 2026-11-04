# SPDX-License-Identifier: GPL-3.0-or-later
"""Shared component figures and tables for the sound-board models.

Every figure here is a typical data-sheet value or a SPICE model parameter
of the references in spice/ (opamps.lib, parts.lib); none is measured on a
Monaco GP board. The Python models and the Verilog constants and tables
(d3_fixed.py, d4_fixed.py)
are built from this one file, so the two cannot drift apart.
"""
import json
import math
from pathlib import Path

HERE=Path(__file__).resolve().parent

TICK_HZ=480_000            # model step: 48 MHz / 100
DT=1.0/TICK_HZ

V12=12.0
VCC=5.0
V6=6.0                     # D-5's 6 V reference, taken as ideal

# LM324 on 12 V (TI SLOS066, typical): output 0.02 V .. V+ - 1.5 V,
# slew 0.5 V/us; as in spice/opamps.lib
VOL=0.02
VOH=V12-1.5
SLEW_TICK=0.5e6*DT         # volts per model step
R_OPOUT=50.0               # output resistance (opamps.lib)

R_OC=20.0                  # open-collector TTL output sinking (parts.lib OCOUT)
R_4016=300.0               # CD4016 on resistance at 12 V (parts.lib SW4016)

# MA150 diode as modelled in parts.lib (1N4148-like)
D_IS=2.52e-9
D_N=1.752
D_RS=0.568
VT=8.617333262e-5*300.15   # ngspice default 27 C
D_NVT=D_N*VT

# 2SC458 cell switch: the comparator output level at which the transistor
# saturates (10K, MA150 and 2.2K base network, Vbe about 0.58 V at 50 uA),
# and its saturation voltage at that drive (parts.lib model)
VTR=3.72
VCE_SAT=0.005

# MC3340 output resistance: R16 200 ohm plus the follower's emitter
# resistance (about 1.3 mA through R15 5.1K)
R_MC_OUT=220.0

# MC3340 CONTROL pin (spice/mc3340.lib: R6 3.9K into the bias chain) seen
# from outside: a source of MC_CTL_V0 behind MC_CTL_R. Least-squares line
# through the model's pin current for -3 .. 7 V at 12 V supply (DC sweep
# in 0.25 V steps); within 3.2 uA of it over that range, and the input
# voltage moves it by less than 0.01 uA. Needed where CONTROL is driven
# through resistors (the D-6 banks), not from an op-amp.
MC_CTL_V0=5.5296+0.13         # + spice/mc3340.lib's control offset (3 November 2026)
MC_CTL_R=4697.4

def diode_v(i):
    """Diode voltage at forward current i (A), series resistance included."""
    return D_NVT*math.log1p(max(i,0.0)/D_IS)+max(i,0.0)*D_RS

def diode_i_series(v,r):
    """Current through a diode in series with r (ohm) across v volts (v >= 0)."""
    if v<=0: return 0.0
    lo,hi=0.0,v/r
    for _ in range(80):
        m=0.5*(lo+hi)
        if diode_v(m)+m*r>v: hi=m
        else: lo=m
    return 0.5*(lo+hi)

class Table:
    """Uniform grid with linear interpolation, clamped at both ends."""
    def __init__(self,x0,dx,values):
        self.x0=float(x0); self.dx=float(dx); self.v=[float(v) for v in values]
        self.n=len(self.v)
    @classmethod
    def build(cls,x0,dx,n,f): return cls(x0,dx,[f(x0+dx*k) for k in range(n)])
    def __call__(self,x):
        f=(x-self.x0)/self.dx
        if f<=0: return self.v[0]
        if f>=self.n-1: return self.v[-1]
        i=int(f); t=f-i
        return self.v[i]+(self.v[i+1]-self.v[i])*t

def softmax_excess(d):
    """Two equal diodes from v1 and v2 into one node with |v1 - v2| = d share
    the current: the node sits nVt*ln(1 + exp(-d/nVt)) above the single-diode
    level of the higher source."""
    return D_NVT*math.log1p(math.exp(-d/D_NVT))

class MC3340:
    """Separable MC3340 table model (mc3340_fit.py), scalar version."""
    def __init__(self,path=HERE/"data/mc3340_tables.json"):
        t=json.loads(Path(path).read_text())
        vg,xg,ug,sg=t["vc_grid"],t["vin_grid"],t["u_grid"],t["s_grid"]
        self.g=Table(vg[0],vg[1],t["g"]); self.vo0=Table(vg[0],vg[1],t["vo0"])
        self.lo=Table(vg[0],vg[1],t["lo"]); self.von=Table(vg[0],vg[1],t["von"])
        self.vonw=Table(vg[0],vg[1],t["vonw"])
        self.h=Table(xg[0],xg[1],t["h"]); self.ib=Table(xg[0],xg[1],t["ib"])
        self.w=Table(ug[0],ug[1],t["w"]); self.ic=Table(ug[0],ug[1],t["ic"])
        self.s=Table(sg[0],sg[1],t["s"])
        self.umax=ug[0]+ug[1]*(ug[2]-1); self.ic_slope=t["ic_slope"]
        self.smax=sg[0]+sg[1]*(sg[2]-1)
        self.h_low=t["h_low"]; self.hi=t["hi"]; self.t=t
    def __call__(self,vin,vc):
        """Returns (unloaded output voltage, input current)."""
        lo=self.lo(vc); u=vin-self.von(vc)
        w=self.w(vin-self.vonw(vc))
        heff=self.h(vin)*(1-w)+self.h_low*w
        x=self.vo0(vc)-self.g(vc)*heff-lo
        o=lo+(x if x>=self.smax else self.s(x))
        if o>self.hi: o=self.hi
        ic=self.ic(u) if u<=self.umax else self.ic.v[-1]+self.ic_slope*(u-self.umax)
        return o,self.ib(vin)+ic

def mc3340_input_line(mc):
    """Bias voltage and slope resistance of the MC3340 input at its bias
    point (the table model's input current, control low)."""
    lo,hi=0.0,3.0
    for _ in range(60):
        m=0.5*(lo+hi)
        if mc(m,0.0)[1]>0: hi=m
        else: lo=m
    vb=0.5*(lo+hi)
    r=0.2/(mc(vb+0.1,0.0)[1]-mc(vb-0.1,0.0)[1])
    return vb,r
