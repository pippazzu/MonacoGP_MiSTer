#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Fixed-point twin of the D-2 Verilog (jtmonacogp_snd_d2.v,
jtmonacogp_snd_d2vco.v) and the generator of their constants and tables
(jtmonacogp_snd_d2.vh).

The arithmetic is the Verilog's, operation for operation, with the D-3
twin's conventions (d3_fixed.py): signals 2^28 per volt in 36 bits,
capacitor states 2^44 per volt in 52 bits, products mul(a, b, s) =
(a*b + 2^(s-1)) >> s with a 27-bit coefficient, tables read at two
neighbouring entries and interpolated. The MC3340s are the D-6/D-7 twin's
(d67_fixed.mc3340, one shared jtmonacogp_snd_mc3340 in the Verilog).
Currents are carried as volts across a stated resistance. The
floating-point model (d2_model.py) supplies every value; this file only
quantizes it.

  d2_fixed.py vh DIR      write jtmonacogp_snd_d2.vh into DIR
  d2_fixed.py check [S]   compare with the floating-point model (scenario
                          of d2_reference.py, S seconds, default 6)
"""
import math
import sys
from pathlib import Path
import sound_parts as P
import d3_fixed as F3
import d67_fixed as F67
import d2_model as M

FV,FS,SW=F3.FV,F3.FS,F3.SW
VBITS,BBITS=F3.VBITS,F3.BBITS
vq,mul,clamp,Coef=F3.vq,F3.mul,F3.clamp,F3.Coef
DT,DTS=P.DT,M.DTS
mc3340=F67.mc3340
R_U=F67.R_U                    # current unit of the MC3340's input current

# ---- constants (signal units unless named Q_: state units)
def _sq(x): return int(round(x*(1<<FS)))
C={"VOH":vq(M.VOH),"VOL":vq(M.VOL),"V6":vq(M.V6),
   # comparators: + input with the output high / low
   "TH42_H":vq(M.hyst_plus(M.V249,M.R249,M.VOH)),"TH42_L":vq(M.hyst_plus(M.V249,M.R249,M.VOL)),
   "TH43_H":vq(M.hyst_plus(M.V252,M.R252,M.VOH)),"TH43_L":vq(M.hyst_plus(M.V252,M.R252,M.VOL)),
   "TH44_H":vq(M.hyst_plus(M.V264,M.R264,M.VOH)),"TH44_L":vq(M.hyst_plus(M.V264,M.R264,M.VOL)),
   # latch + inputs
   "R12_H":vq((M.V12+M.VOH)/2),"R12_L":vq((M.V12+M.VOL)/2),
   "R3_OFF":vq(M.V12),"R3_ON":vq(M.R3_ON),
   # node Q: the IC43 Schmitt switches above Q_TH (IC43.1 high / low);
   # the D32 clamp; C55's step from IC43.1 (state units)
   "QTH_H":vq((M.V6*110e3-M.VOH*10e3)/100e3),"QTH_L":vq((M.V6*110e3-M.VOL*10e3)/100e3),
   "QCLAMP":vq(-0.55),
   "Q55O_H":_sq(M.VOH/110e3*DT/0.68e-6),"Q55O_L":_sq(M.VOL/110e3*DT/0.68e-6),
   # 555
   "TH_HI":vq(M.TH_HI),"TH_LO":vq(M.TH_LO),"V12":vq(M.V12),"V_DSG":vq(M.V_DSG),
   # VCO: IC40's - input (W / 2), its current from node W, the most R231
   # passes, per sub-step on C49 (signal units)
   "V13_H":vq(M.W_HI/2),"V13_L":vq(M.W_LO/2),
   "IW_H":vq((M.W_HI-M.W_HI/2)/30e3*DTS/M.C49),"IW_L":vq((M.W_LO-M.W_LO/2)/30e3*DTS/M.C49),
   "ICM_H":vq(max(M.W_HI/2-0.05,0.0)/M.R231*DTS/M.C49),
   "ICM_L":vq(max(M.W_LO/2-0.05,0.0)/M.R231*DTS/M.C49),
   "SP0":vq(M.V6*100e3/151e3),
   "N40_LO":vq(M.VOL-0.25),"N40_HI":vq(M.VOH+0.25),
}
# the 2.8 V rail and the followers: con41 = A + KCS*(env_r + env_f) + KH*env_r
_ka=1/100e3+1/51e3
_ga=(1/51e3)/_ka
_kh=(1/100e3)/_ka
_g=1/M.R239+1/M.R238+2/51e3
_den=_g-2*_ga/51e3
C["CON0"]=vq(_ga*(M.V12/M.R239)/_den)
K_CS=Coef("KCS",_ga*(_kh/51e3)/_den)
K_H=Coef("KH",_kh)
# node Z (mute off / on): z = KZ1*(o40_7 - q50) + KZ2*(q114 + 6 V)
def _gz(mute): return 1/1e3+1/M.R_PADR+1/100e3+(1/M.R_STB if mute else 0.0)

# ---- coefficients
K_Q55=Coef("KQ55",(1/10e3+1/110e3)*DT/0.68e-6,FS)
K_CH=Coef("KCH",1-M.K_CH,FS)
K_DSG=Coef("KDSG",1-M.K_DSG,FS)
K_SP=Coef("KSP",51e3/151e3)
K_C51=Coef("KC51",DT/(M.C51*R_U),FS)
K_C59=Coef("KC59",DT/(M.C59*R_U),FS)
_r18=18e3+M.R_MC; _r10=10e3+M.R_MC
K_R7=Coef("KR7",22e3/_r18)
K_BK=Coef("KBK",22e3/51e3)
_gv=1/_r18+1/22e3
K_VA=Coef("KVA",(1/_r18)/_gv); K_VB=Coef("KVB",(1/22e3)/_gv); K_VC=Coef("KVC",(1/51e3)/_gv)
K_52=Coef("K52",DT/(_r18*M.C52),FS)
K_Z1=[Coef(f"KZ1{n}",(1/1e3)/_gz(m)) for n,m in (("",False),("M",True))]
K_Z2=[Coef(f"KZ2{n}",(1/100e3)/_gz(m)) for n,m in (("",False),("M",True))]
K_50=Coef("K50",DT/(1e3*M.C50),FS)
K_114=Coef("K114",DT/(100e3*M.C114),FS)
K_PR=Coef("KPR",10e3/M.R_PADR)
K_F7=Coef("KF7",100e3/_r10)
K_FA=Coef("KFA",100e3/(100e3+_r10)); K_FB=Coef("KFB",_r10/(100e3+_r10))
K_58=Coef("K58",DT/(_r10*M.C58),FS)
K_60=Coef("K60",DT/(220e3*M.C60),FS)
K_410=Coef("K410",22e3/220e3)
K_424=Coef("K424",22e3/100e3)
COEFS=[K_CS,K_H,K_Q55,K_CH,K_DSG,K_SP,K_C51,K_C59,K_R7,K_BK,K_VA,K_VB,K_VC,K_52]+K_Z1+K_Z2+ \
      [K_50,K_114,K_PR,K_F7,K_FA,K_FB,K_58,K_60,K_410,K_424]

# ---- tables, in two ROMs: the envelopes' steering (state units per step)
# and the VCO's (TR16's current per sub-step on C49, the slewing node's
# step; signal units)
def _tab(name,table,scale):
    k=round(-math.log2(table.dx)); assert 2.0**-k==table.dx,name
    return {"name":name,"x0":vq(table.x0),"k":k,"v":[int(round(v*scale)) for v in table.v]}
ROMS={"env":[_tab("D51",M.T_51,DT/M.C_REAR*2**FS),_tab("D82",M.T_82,DT/M.C_REAR*2**FS),
             _tab("D10",M.T_10,DT/M.C_FRONT*2**FS),_tab("D220",M.T_220,DT/M.C_FRONT*2**FS)],
      "vco":[_tab("TR16",M.T_TR16,DTS/M.C49*2**FV),_tab("SLEW",M.T_SLEW,2**FV)]}
ROM_SIZE={}
for rom,tabs in ROMS.items():
    base=0
    for t in tabs:
        t["base"]=base; t["n"]=len(t["v"]); base+=t["n"]
        assert all(abs(v)<2**(VBITS-2) for v in t["v"]),t["name"]
        assert FV-t["k"]<=BBITS-2,t["name"]
    ROM_SIZE[rom]=base
TAB={t["name"]:t for tabs in ROMS.values() for t in tabs}

def tab(name,x):
    t=TAB[name]; F=FV-t["k"]; r=x-t["x0"]
    if r<0: i,f=0,0
    else:
        i=r>>F; f=r&((1<<F)-1)
        if i>=t["n"]-1: i,f=t["n"]-2,1<<F
    v0=t["v"][i]; v1=t["v"][i+1]
    return v0+mul(v1-v0,f,F)

def latch(ra,rb,a,b):
    c=C
    for _ in range(4):
        a=clamp(ra+100*(ra-b),c["VOL"],c["VOH"])
        b=clamp(rb+100*(rb-a),c["VOL"],c["VOH"])
    return a,b

class IntegFixed:
    """M.Integrator: q (state units) is the capacitor's voltage, output side
    minus - input side."""
    def __init__(self,tin,tout): self.q=0; self.tin=tin; self.tout=tout
    def out(self):
        c=C; return clamp(c["V6"]+(self.q>>SW),c["VOL"],c["VOH"])
    def step(self,s):
        c=C; qs=self.q>>SW; v=c["V6"]+qs
        if v>c["VOH"]: vm=c["VOH"]-qs
        elif v<c["VOL"]: vm=c["VOL"]-qs
        else: vm=c["V6"]
        self.q-=tab(self.tin,s-vm)-tab(self.tout,vm-s)

class VcoFixed:
    """The 555, node W and the sawtooth VCO (jtmonacogp_snd_d2vco.v)."""
    def __init__(self):
        c=C
        self.v47=0; self.o555=True
        self.q49=0                       # C49, signal units
        self.n40=c["VOL"]; self.o40_1=c["VOL"]; self.tri=0
    def step(self):
        c=C
        v47=self.v47>>SW
        if self.o555:
            self.v47+=K_CH(c["V12"]-v47)
            if (self.v47>>SW)>=c["TH_HI"]: self.o555=False
        else:
            self.v47-=K_DSG(v47-c["V_DSG"])
            if (self.v47>>SW)<=c["TH_LO"]: self.o555=True
        h=self.o555
        v13=c["V13_H"] if h else c["V13_L"]
        iw=c["IW_H"] if h else c["IW_L"]
        icm=c["ICM_H"] if h else c["ICM_L"]
        for _ in range(M.SUB):
            ic=min(tab("TR16",self.o40_1),icm)
            self.q49+=ic-iw
            tri=v13+self.q49
            if tri>c["VOH"]: tri=c["VOH"]; self.q49=c["VOH"]-v13
            elif tri<c["VOL"]: tri=c["VOL"]; self.q49=c["VOL"]-v13
            d=c["SP0"]+K_SP(self.o40_1)-tri
            self.n40=clamp(self.n40+tab("SLEW",d),c["N40_LO"],c["N40_HI"])
            self.o40_1=clamp(self.n40,c["VOL"],c["VOH"])
        self.tri=tri
        return tri

class D2Fixed:
    def __init__(self,dip_back=True):
        c=C
        self.dip_back=dip_back
        self.o42_8=c["VOL"]; self.o42_14=c["VOH"]; self.o42_1=c["VOL"]
        self.rear=IntegFixed("D51","D82")
        self.o43_14=c["VOL"]; self.q55=0; self.o43_1=c["VOL"]
        self.o43_7=c["VOL"]; self.o43_8=c["VOH"]; self.o44_14=c["VOL"]
        self.front=IntegFixed("D10","D220")
        self.vco=VcoFixed()
        self.qin41=0; self.qin45=0
        self.p_tri=0; self.p_con41=0; self.p_con45=0
        self.q52=0; self.q58=0; self.q60=0; self.q50=0; self.q114=0
        self.out={}

    def envelopes(self,resc):
        c=C; H=c["VOH"]
        env_r=self.rear.out()
        th=c["TH42_H"] if self.o42_8==H else c["TH42_L"]
        self.o42_8=H if th-env_r>0 else c["VOL"]
        r12=c["R12_H"] if self.o42_8==H else c["R12_L"]
        r3=c["R3_OFF"] if resc else c["R3_ON"]
        self.o42_14,self.o42_1=latch(r12,r3,self.o42_14,self.o42_1)
        self.rear.step(self.o42_1)
        th=c["TH43_H"] if self.o43_14==H else c["TH43_L"]
        self.o43_14=H if th-env_r>0 else c["VOL"]
        q=self.o43_14-(self.q55>>SW)
        if q<c["QCLAMP"]: q=c["QCLAMP"]; self.q55=(self.o43_14-c["QCLAMP"])<<SW
        hi1=self.o43_1==H
        self.q55+=K_Q55(q)-(c["Q55O_H"] if hi1 else c["Q55O_L"])
        self.o43_1=H if q>(c["QTH_H"] if hi1 else c["QTH_L"]) else c["VOL"]
        r5=c["R12_H"] if self.o43_1==H else c["R12_L"]
        r10=c["R12_H"] if self.o44_14==H else c["R12_L"]
        self.o43_7,self.o43_8=latch(r5,r10,self.o43_7,self.o43_8)
        env_f=self.front.out()
        self.front.step(self.o43_7)
        th=c["TH44_H"] if self.o44_14==H else c["TH44_L"]
        self.o44_14=H if th-env_f>0 else c["VOL"]
        return env_r,env_f

    def step(self,resc,mute,i_bk):
        """i_bk: the BACK OTHER CAR current times 51K (signal units).
        Returns (the R410 and R424 currents times R414, pad R)."""
        c=C
        env_r,env_f=self.envelopes(resc)
        cs=K_CS(env_r+env_f)
        con41=clamp(c["CON0"]+cs+K_H(env_r),c["VOL"],c["VOH"])
        con45=clamp(c["CON0"]+cs+K_H(env_f),c["VOL"],c["VOH"])
        m41i=self.p_tri-(self.qin41>>SW)
        m41o,i41=mc3340(m41i,self.p_con41)
        self.qin41+=K_C51(i41)
        m45i=self.p_tri-(self.qin45>>SW)
        m45o,i45=mc3340(m45i,self.p_con45)
        self.qin45+=K_C59(i45)
        tri=self.vco.step()
        self.p_tri,self.p_con41,self.p_con45=tri,con41,con45
        # rear: IC40 b
        q52=self.q52>>SW
        e=m41o-q52
        ir=e-c["V6"]
        o40_7=c["V6"]-K_R7(ir)-K_BK(i_bk)
        if o40_7>c["VOH"] or o40_7<c["VOL"]:
            o40_7=clamp(o40_7,c["VOL"],c["VOH"])
            ir=e-(K_VA(e)+K_VB(o40_7)+K_VC(i_bk))
        self.q52+=K_52(ir)
        # node Z
        q50=self.q50>>SW; q114=self.q114>>SW
        z=K_Z1[mute](o40_7-q50)+K_Z2[mute](q114+c["V6"])
        self.q50+=K_50(o40_7-q50-z)
        i424=z-q114-c["V6"] if self.dip_back else 0
        self.q114+=K_114(i424)
        padr=K_PR(z)
        # front: IC44 b
        e=m45o-(self.q58>>SW)
        o44_7=c["V6"]-K_F7(e-c["V6"])
        if o44_7>c["VOH"] or o44_7<c["VOL"]:
            o44_7=clamp(o44_7,c["VOL"],c["VOH"])
            vm=K_FA(e)+K_FB(o44_7)
        else: vm=c["V6"]
        self.q58+=K_58(e-vm)
        q60=self.q60>>SW
        i410=o44_7-q60-c["V6"]
        self.q60+=K_60(i410)
        i_mix=K_410(i410)+K_424(i424)
        self.out.update(env_r=env_r,env_f=env_f,o42_1=self.o42_1,o42_14=self.o42_14,
                        o42_8=self.o42_8,o43_14=self.o43_14,o43_1=self.o43_1,
                        o43_7=self.o43_7,o44_14=self.o44_14,con41=con41,con45=con45,
                        tri=tri,o40_1=self.vco.o40_1,o555=self.vco.o555,
                        mc41o=m41o,mc45o=m45o,o40_7=o40_7,z=z,padr=padr,o44_7=o44_7,
                        i410=i410,i424=i424,i_mix=i_mix)
        return i_mix,padr

def write_vh(path):
    def sv(v,bits=VBITS):
        return f"-{bits}'sd{-v}" if v<0 else f"{bits}'sd{v}"
    L=["// SPDX-License-Identifier: GPL-3.0-or-later",
       "// GENERATED by tests/sound/d2_fixed.py from the sound models in tests/sound;",
       "// do not edit. Constants and tables of the D-2 modules: signals 2^28",
       "// per volt, capacitor states 2^44 per volt; coefficient = M / 2^S.",
       ""]
    for k,v in C.items():
        bits=SBITS if k.startswith("Q55O") else VBITS
        L.append(f"localparam signed [{bits-1}:0] D2_{k} = {sv(v,bits)};")
    L.append(f"localparam integer D2_SUB = {M.SUB};")
    for co in COEFS:
        L.append(f"localparam signed [{BBITS-1}:0] {co.name}_M = {sv(co.m,BBITS)};  // {co.k:.6g}")
        L.append(f"localparam [5:0] {co.name}_S = 6'd{co.s};")
    for rom,tabs in ROMS.items():
        assert ROM_SIZE[rom]<1024
        for t in tabs:
            L.append(f"localparam [9:0] T_{t['name']}_BASE = 10'd{t['base']}, T_{t['name']}_N = 10'd{t['n']};")
            L.append(f"localparam [4:0] T_{t['name']}_F = 5'd{FV-t['k']};")
            L.append(f"localparam signed [{VBITS-1}:0] T_{t['name']}_X0 = {sv(t['x0'])};")
        L.append(f"localparam integer ROM_{rom.upper()}_SIZE = {ROM_SIZE[rom]};")
    for rom in ROMS:
        L.append(f"reg signed [{VBITS-1}:0] rom_{rom} [0:ROM_{rom.upper()}_SIZE-1];")
    L.append("initial begin")
    for rom,tabs in ROMS.items():
        for t in tabs:
            L.append(f"    // {t['name']}")
            for i,v in enumerate(t["v"]):
                L.append(f"    rom_{rom}[{t['base']+i}] = {sv(v)};")
    L.append("end")
    Path(path).write_text("\n".join(L)+"\n")
SBITS=F3.SBITS

KEYS=("env_r","env_f","con41","con45","tri","o40_1","mc41o","mc45o","o40_7","z","padr","o44_7")
def check(seconds=6.0):
    """Run both models through the reference scenario; report the largest
    differences and the switching steps."""
    import d2_reference as R
    n=int(round(seconds*P.TICK_HZ))
    a=M.D2(); b=D2Fixed(); s=1.0/(1<<FV)
    worst={}; sw={"a":[],"b":[]}
    pa=pb=None
    fall={"a":[],"b":[]}; hi={"a":False,"b":False}
    for k in range(n):
        resc,mute,bko=R.inputs(k)
        ia,_=a.step(resc,mute,(bko-P.V6)/51e3)
        ib,_=b.step(resc,mute,vq(bko-P.V6))
        qa=(a.out["o42_1"]>6,a.out["o43_7"]>6,a.out["o44_14"]>6,a.out["o42_8"]>6,a.out["o555"]>6)
        qb=(b.out["o42_1"]*s>6,b.out["o43_7"]*s>6,b.out["o44_14"]*s>6,b.out["o42_8"]*s>6,b.out["o555"])
        if qa!=pa: sw["a"].append((k,qa))
        if qb!=pb: sw["b"].append((k,qb))
        pa,pb=qa,qb
        for w,v in (("a",a.out["tri"]),("b",b.out["tri"]*s)):
            if not hi[w] and v>8.0: hi[w]=True
            elif hi[w] and v<7.0: hi[w]=False; fall[w].append(k)
        if k%16==0:
            for key in KEYS:
                e=abs(a.out[key]-b.out[key]*s)
                if e>worst.get(key,(0,0))[0]: worst[key]=(e,k*P.DT)
            e=abs(ia*22e3-ib*s)
            if e>worst.get("i_mix",(0,0))[0]: worst["i_mix"]=(e,k*P.DT)
    for key,(e,t) in worst.items(): print(f"{key:6s} max |float - fixed| {e:.5f} V at {t:.3f} s")
    fa,fb=fall["a"],fall["b"]
    dk=max([abs(x-y) for x,y in zip(fa,fb)],default=0)
    print(f"sawtooth discharges: float {len(fa)}, fixed {len(fb)}; largest offset {dk} steps")
    same=[x[0] for x in sw["a"]]==[x[0] for x in sw["b"]] and [x[1] for x in sw["a"]]==[x[1] for x in sw["b"]]
    print("switching steps identical" if same else "switching steps differ")
    if not same:
        print("float",sw["a"][:30]); print("fixed",sw["b"][:30])

if __name__=="__main__":
    if sys.argv[1]=="vh": write_vh(Path(sys.argv[2])/"jtmonacogp_snd_d2.vh")
    elif sys.argv[1]=="check": check(float(sys.argv[2]) if len(sys.argv)>2 else 6.0)
