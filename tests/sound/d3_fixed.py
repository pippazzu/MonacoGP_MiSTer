#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Fixed-point twin of the D-3 Verilog (cores/monacogp/hdl/jtmonacogp_snd_d3.v)
and the generator of its constants and tables (jtmonacogp_snd_d3.vh).

The arithmetic is the Verilog's, operation for operation: signals are signed
integers with 2^28 per volt, capacitor states 2^44 per volt, and every
product is mul(a, b, s) = (a*b + 2^(s-1)) >> s with a 36-bit signal and a
27-bit coefficient or fraction. Tables are read at two neighbouring entries
and interpolated. The floating-point model (d3_model.py) supplies every
value; this file only quantizes it.

  d3_fixed.py vh PATH     write the Verilog include
  d3_fixed.py check       compare with the floating-point model (3 s run)
"""
import json
import sys
from pathlib import Path
import sound_parts as P
import d3_model as M

FV=28                      # signal: 2^28 per volt
FS=44                      # capacitor state: 2^44 per volt
SW=FS-FV
VBITS=36                   # signal width
SBITS=52                   # state width
BBITS=27                   # second multiplier operand (signed)

def vq(x): return int(round(x*(1<<FV)))
def mul(a,b,s): return (a*b+(1<<(s-1)))>>s
def clamp(x,lo,hi): return lo if x<lo else hi if x>hi else x

class Coef:
    """k as m / 2^s scaled from in_frac to out_frac bits, |m| < 2^26."""
    def __init__(self,name,k,out_frac=FV,in_frac=FV):
        self.name=name; self.k=k
        s=1
        while abs(k)*2.0**(s+1+out_frac-in_frac)<2**26 and s<62: s+=1
        self.s=s; self.m=int(round(k*2.0**(s+out_frac-in_frac)))
        assert 0<abs(self.m)<2**26 and s>=1, (name,k,s,self.m)
    def __call__(self,a): return mul(a,self.m,self.s)

# ---- coefficients
DT=P.DT
C_LAG300=Coef("K300",DT/(150e3*47e-6),FS)
C_LAG302=Coef("K302",DT/((68e3+P.R_4016)*47e-6),FS)
C_SHIFT=Coef("KSHIFT",M.SHIFT_K)
C_KA=[Coef(f"KA{n}",DT/(rin*c),FS) for n,(rin,rc,c) in enumerate(M.CELLS,1)]
C_KB=[Coef(f"KB{n}",DT/(rc*c),FS) for n,(rin,rc,c) in enumerate(M.CELLS,1)]
C_SCH=Coef("KSCH",M.R_SCH6/(M.R_SCH6+M.R_SCHFB))
C_K66=Coef("K66",DT/(10e3*22e-6),FS)
C_K66B=Coef("K66B",DT/(20e3*22e-6),FS)
C_KTH=Coef("KTH",M.BUS_RTH/M.MC_RIN)
C_K64=Coef("K64",DT/(10e-6*M.BUS_RTH),FS)
def _out_coefs(gs):
    d=gs+2/51e3+1/100e3
    return gs/d,1/(100e3*d),(P.V12/51e3+P.V6/100e3)/d
_on=_out_coefs(1/(P.R_MC_OUT+P.R_4016)); _off=_out_coefs(0.0)
C_OA_ON=Coef("KOA_ON",_on[0]); C_OB_ON=Coef("KOB_ON",_on[1]); OC_ON=vq(_on[2])
C_OB_OFF=Coef("KOB_OFF",_off[1]); OC_OFF=vq(_off[2])
C_K72=Coef("K72",DT/(100e3*22e-6),FS)
MCT=M.MC.t
C_ICS=Coef("KICS",MCT["ic_slope"]*M.BUS_RTH)
COEFS=[C_LAG300,C_LAG302,C_SHIFT]+C_KA+C_KB+[C_SCH,C_K66,C_K66B,C_KTH,C_K64,C_OA_ON,
       C_OB_ON,C_OB_OFF,C_K72,C_ICS]

# ---- constants (signal units)
CONSTS={"VOH":vq(P.VOH),"VOL":vq(P.VOL),"VOH_C":vq(M.VOH_C),"VOL_C":vq(M.VOL_C),
        "CMP_OVER":vq(M.CMP_OVER),"VTR":vq(P.VTR),"VCE":vq(P.VCE_SAT),"V6":vq(P.V6),
        "CV_MAX":vq(M.CV_MAX),"SLEW":vq(P.SLEW_TICK),
        "SCH0":vq(P.V6*M.R_SCHFB/(M.R_SCH6+M.R_SCHFB)),"MC_VB":vq(M.MC_VB),
        "H_LOW":vq(MCT["h_low"]),"MC_HI":vq(MCT["hi"]),"OC_ON":OC_ON,"OC_OFF":OC_OFF}
DAC=[min(vq(v),CONSTS["VOH"]) for v in M.DAC]

# ---- tables: (name, x0 volts, log2(1/step), values in their units)
def _grid(g): x0,dx,n=g; return x0,round(-__import__("math").log2(dx)),n
def _tab(name,table,scale):
    import math
    k=round(-math.log2(table.dx)); assert 2.0**-k==table.dx
    return {"name":name,"x0":vq(table.x0),"k":k,"v":[int(round(v*scale)) for v in table.v]}
TABLES=[_tab("D21",M.T_D21,DT/47e-6*2**FS),
        _tab("V10",M.T_V10,2**FV),
        _tab("SOFT",M.T_SOFT,2**FV),
        _tab("VDROP",M.T_VDROP,2**FV),
        _tab("G",M.MC.g,2**FV),_tab("VO0",M.MC.vo0,2**FV),_tab("LO",M.MC.lo,2**FV),
        _tab("VON",M.MC.von,2**FV),_tab("VONW",M.MC.vonw,2**FV),
        _tab("H",M.MC.h,2**FV),_tab("IB",M.MC.ib,M.BUS_RTH*2**FV),
        _tab("W",M.MC.w,2**FV),_tab("IC",M.MC.ic,M.BUS_RTH*2**FV),
        _tab("S",M.MC.s,2**FV)]
base=0
for t in TABLES:
    t["base"]=base; t["n"]=len(t["v"]); base+=t["n"]
    # below 2^34, so that a difference of two entries fits the 36-bit operand
    assert all(abs(v)<2**(VBITS-2) for v in t["v"]),t["name"]
    assert FV-t["k"]<=BBITS-2,t["name"]
ROM_SIZE=base
TAB={t["name"]:t for t in TABLES}
U_MAX=vq(M.MC.umax); IC_LAST=TAB["IC"]["v"][-1]; S_MAX=vq(M.MC.smax)

def tab(name,x):
    """Interpolated table read, as the Verilog does it."""
    t=TAB[name]; F=FV-t["k"]; r=x-t["x0"]
    if r<0: i,f=0,0
    else:
        i=r>>F; f=r&((1<<F)-1)
        if i>=t["n"]-1: i,f=t["n"]-2,1<<F
    v0=t["v"][i]; v1=t["v"][i+1]
    return v0+mul(v1-v0,f,F)

class D3Fixed:
    def __init__(self):
        c=CONSTS
        self.lag=0
        self.cap=[0,0,0]
        self.cmp=[c["VOL_C"]-c["CMP_OVER"]]*3
        self.tr=[False]*3
        self.q66=0; self.q64=0; self.q72=0; self.inl=0
        self.out={}

    def step(self,acc,shift_a,sound_on):
        c=CONSTS; o=self.out
        # lag
        f8=DAC[acc]
        lag_s=self.lag>>SW
        d=f8-lag_s
        dl=C_LAG300(d)
        if not (acc>>3&1): dl+=C_LAG302(d)
        if lag_s>f8: dl-=tab("D21",lag_s-f8)
        self.lag+=dl
        # CV
        f14=clamp(self.lag>>SW,c["VOL"],c["VOH"])
        n10=C_SHIFT(f14) if shift_a else f14
        cv=clamp(n10,c["VOL"],c["CV_MAX"])
        vm=cv>>1
        # cells
        outs=[]
        for n in range(3):
            dc=C_KA[n](cv-vm)
            if self.tr[n]: dc-=C_KB[n](vm-c["VCE"])
            self.cap[n]+=dc
            vout=vm-(self.cap[n]>>SW)
            if vout>c["VOH"]: vout=c["VOH"]; self.cap[n]=(vm-c["VOH"])<<SW
            elif vout<c["VOL"]: vout=c["VOL"]; self.cap[n]=(vm-c["VOL"])<<SW
            vo=clamp(self.cmp[n],c["VOL_C"],c["VOH_C"])
            vplus=c["SCH0"]+C_SCH(vo)
            if vplus>vout: self.cmp[n]=min(self.cmp[n]+c["SLEW"],c["VOH_C"]+c["CMP_OVER"])
            else: self.cmp[n]=max(self.cmp[n]-c["SLEW"],c["VOL_C"]-c["CMP_OVER"])
            self.tr[n]=self.cmp[n]>c["VTR"]
            outs.append(vout)
        o1,o2,o3=outs
        # attenuation control
        v10=tab("V10",cv)
        c66r=o1-(self.q66>>SW)
        con=2*v10-c66r
        if con>c["VOH"] or con<c["VOL"]:
            con=clamp(con,c["VOL"],c["VOH"])
            self.q66+=C_K66B(c66r-con)
        else:
            self.q66+=C_K66(c66r-v10)
        # audio bus
        if o2>=o3: hi_,d=o2,o3-o2
        else: hi_,d=o3,o2-o3
        top=hi_+tab("SOFT",-d)
        q64s=self.q64>>SW
        vth=C_KTH(q64s+c["MC_VB"])-self.inl
        v=top-vth
        bus=vth if v<=0 else top-tab("VDROP",v)
        mcin=bus-q64s
        # MC3340
        g=tab("G",con); vo0=tab("VO0",con); lo=tab("LO",con)
        von=tab("VON",con); vonw=tab("VONW",con)
        h=tab("H",mcin); ib=tab("IB",mcin)
        w=tab("W",mcin-vonw)
        u=mcin-von
        ic=tab("IC",u) if u<=U_MAX else IC_LAST+C_ICS(u-U_MAX)
        heff=h+mul(c["H_LOW"]-h,w>>3,FV-3)
        x=vo0-mul(heff,g>>3,FV-3)-lo
        mco=lo+(x if x>=S_MAX else tab("S",x))
        mco=min(mco,c["MC_HI"])
        iin=ib+ic
        self.inl=iin-C_KTH(mcin-c["MC_VB"])
        self.q64+=C_K64(iin)
        # output
        q72s=self.q72>>SW
        if sound_on: swo=C_OA_ON(mco)+C_OB_ON(q72s)+c["OC_ON"]
        else: swo=C_OB_OFF(q72s)+c["OC_OFF"]
        i72v=swo-q72s-c["V6"]
        self.q72+=C_K72(i72v)
        o.update(lag=self.lag>>SW,cv=cv,o51a=o1,o50a=o2,o49a=o3,
                 o51b=clamp(self.cmp[0],c["VOL_C"],c["VOH_C"]),
                 o50b=clamp(self.cmp[1],c["VOL_C"],c["VOH_C"]),
                 o49b=clamp(self.cmp[2],c["VOL_C"],c["VOH_C"]),
                 con=con,bus=bus,mcin=mcin,mcout=mco,swo=swo,mixr=i72v+c["V6"],i_mix=i72v)
        return i72v

def write_vh(path):
    def sv(v,bits=VBITS):
        return f"-{bits}'sd{-v}" if v<0 else f"{bits}'sd{v}"
    L=["// SPDX-License-Identifier: GPL-3.0-or-later",
       "// GENERATED by tests/sound/d3_fixed.py from the sound models in tests/sound;",
       "// do not edit. Constants and tables of jtmonacogp_snd_d3.v: signals 2^28",
       "// per volt, capacitor states 2^44 per volt; coefficient = M / 2^S.",
       ""]
    for k,v in CONSTS.items(): L.append(f"localparam signed [{VBITS-1}:0] {k} = {sv(v)};")
    L.append(f"localparam signed [{VBITS-1}:0] U_MAX = {sv(U_MAX)};")
    L.append(f"localparam signed [{VBITS-1}:0] IC_LAST = {sv(IC_LAST)};")
    L.append(f"localparam signed [{VBITS-1}:0] S_MAX = {sv(S_MAX)};")
    for co in COEFS:
        L.append(f"localparam signed [{BBITS-1}:0] {co.name}_M = {sv(co.m,BBITS)};  // {co.k:.6g}")
        L.append(f"localparam [5:0] {co.name}_S = 6'd{co.s};")
    assert ROM_SIZE<4096
    for t in TABLES:
        L.append(f"localparam [11:0] T_{t['name']}_BASE = 12'd{t['base']}, T_{t['name']}_N = 12'd{t['n']};")
        L.append(f"localparam [4:0] T_{t['name']}_F = 5'd{FV-t['k']};")
        L.append(f"localparam signed [{VBITS-1}:0] T_{t['name']}_X0 = {sv(t['x0'])};")
    L.append(f"localparam integer ROM_SIZE = {ROM_SIZE};")
    L.append("function signed [35:0] dac_level(input [3:0] code);")
    L.append("    case (code)")
    for i,v in enumerate(DAC): L.append(f"        4'd{i}: dac_level = {sv(v)};")
    L.append("    endcase")
    L.append("endfunction")
    L.append(f"reg signed [{VBITS-1}:0] rom [0:ROM_SIZE-1];")
    L.append("initial begin")
    for t in TABLES:
        L.append(f"    // {t['name']}")
        for i,v in enumerate(t["v"]):
            L.append(f"    rom[{t['base']+i}] = {sv(v)};")
    L.append("end")
    Path(path).write_text("\n".join(L)+"\n")

def check(seconds=3.0):
    """Run both models through the 3 s scenario; report the differences."""
    import d3_reference as R
    ev=R.event_ticks(R.FULL,P.TICK_HZ); n=int(round(seconds*P.TICK_HZ))
    a=M.D3(); b=D3Fixed(); ei=0; code,sh,on=ev[0][1:]
    worst={}; s=1.0/(1<<FV)
    for k in range(n):
        t=k*P.DT
        while ei<len(ev) and ev[ei][0]<=k: code,sh,on=ev[ei][1:]; ei+=1
        a.step(code,sh,on); b.step(code,sh,on)
        if k%48==0:
            for key in ("lag","cv","o51a","o50a","o49a","con","mcin","mcout","mixr"):
                e=abs(a.out[key]-b.out[key]*s)
                if e>worst.get(key,(0,0))[0]: worst[key]=(e,t)
    for key,(e,t) in worst.items(): print(f"{key:6s} max |float - fixed| {e:.5f} V at {t:.3f} s")

if __name__=="__main__":
    if sys.argv[1]=="vh": write_vh(sys.argv[2])
    elif sys.argv[1]=="check": check(float(sys.argv[2]) if len(sys.argv)>2 else 3.0)
