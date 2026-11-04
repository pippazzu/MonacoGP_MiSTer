#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Fixed-point twin of the D-6/D-7 Verilog (jtmonacogp_snd_d7ctl.v,
jtmonacogp_snd_d6bank.v, jtmonacogp_snd_d7car.v, jtmonacogp_snd_d67.v) and
the generator of their constants and tables (jtmonacogp_snd_d67.vh).

The arithmetic is the Verilog's, operation for operation, with the D-3
twin's conventions (d3_fixed.py): signals 2^28 per volt in 36 bits,
capacitor states 2^44 per volt in 52 bits, products mul(a, b, s) =
(a*b + 2^(s-1)) >> s with a 27-bit coefficient, tables read at two
neighbouring entries and interpolated. Currents are carried as volts across
a stated resistance. The floating-point model (d67_model.py) supplies every
value; this file only quantizes it.

  d67_fixed.py vh DIR      write jtmonacogp_snd_d67.vh into DIR
  d67_fixed.py check [S]   compare with the floating-point model (scenario
                           of d67_reference.py, S seconds, default 3)
"""
import math
import sys
from pathlib import Path
import sound_parts as P
import d3_model as M3
import d3_fixed as F3
import d67_model as M

FV,FS,SW=F3.FV,F3.FS,F3.SW
VBITS,BBITS=F3.VBITS,F3.BBITS
vq,mul,clamp,Coef=F3.vq,F3.mul,F3.clamp,F3.Coef
DT=P.DT

# ---- constants (signal units)
C=dict(F3.CONSTS)
for k in ("OC_ON","OC_OFF","CV_MAX","SCH0"): del C[k]
R_U=M3.BUS_RTH                 # current unit of the MC3340 tables (IB, IC)
R_TR=100.0                     # current unit of the reset table
_g6=[1/M.FEED[n][1]+2/M.R_IN for n in (0,6)]
C.update({
    "TL_HI":vq(M.TL_HI),"TL_LO":vq(M.TL_LO),
    "FEED0_LO":vq(M.FEED[0][0]/M.FEED[0][1]/_g6[0]),
    "FEED0_HI":vq(M.FEED[6][0]/M.FEED[6][1]/_g6[1]),
    "U0":vq(M.REF130*(1+M.K15)),"REF6":vq(M.REF6),
    "SA0":vq(M.REFA*(1+5.1e3/10e3)),"SC0":vq(2*M.REFC),
    "RB0":vq((M.V12/6.8e3)/(1/6.8e3+1/2.7e3+2/51e3)),
    "RD0":vq((M.V12/5.1e3)/(1/5.1e3+1/1e3+2/102e3)),
    "CV1_0":vq(2*M.REF192),"CV2_0":vq(2*M.ref189(M.R190_BOARD)),
    "CV_MAX":vq(M.CV_MAX),
    "PH0":0,"PL0":0,               # filled below
})
_D=1+M.R_OP/M.R132+M.R_OP/M.R_IN
C["PH0"]=vq((M.TL_HI+M.R_OP*M.REF130/M.R132)/_D)
C["PL0"]=vq((M.TL_LO+M.R_OP*M.REF130/M.R132)/_D)
# hysteresis stages: + = x * A + B (output high or low)
_ra=M.R_HA/(M.R_HA+M.R_HB); _rb=M.R_HB/(M.R_HA+M.R_HB)
_gh=1/M.R_PU+1/(M.R_HA+M.R_HB)
HYST_AH=_rb+_ra*(1/(M.R_HA+M.R_HB))/_gh
C["HYST_BH"]=vq(_ra*(M.V12/M.R_PU)/_gh)
C["HYST_BL"]=vq(_ra*M.V339_LO)
# banks: CONTROL node current = con * G - I0, as volts on C_CON per step
BANK_I0=[(M.V12/rbt+P.MC_CTL_V0/P.MC_CTL_R) for rbt,rbb in (M.BANK_BIAS[1],M.BANK_BIAS[2])]
BANK_G=[1/rbt+1/rbb+1/P.MC_CTL_R for rbt,rbb in (M.BANK_BIAS[1],M.BANK_BIAS[2])]
C["CON_I0_1"]=int(round(BANK_I0[0]*DT/M.C_CON*2**FS))
C["CON_I0_2"]=int(round(BANK_I0[1]*DT/M.C_CON*2**FS))
# D-7 outputs: bias node constants (switch on / off)
def _bias(gs,rout):
    g=gs+1/M.R_BIAS+1/rout
    return gs/g,(1/rout)/g,(P.V6/M.R_BIAS+P.V6/rout)/g
_gs=1/M.R_SRC_ON
C["BF_ON"]=vq(_bias(_gs,M.R_FRONT)[2]); C["BF_OFF"]=vq(_bias(0,M.R_FRONT)[2])
C["BB_ON"]=vq(_bias(_gs,M.R_BACK)[2]);  C["BB_OFF"]=vq(_bias(0,M.R_BACK)[2])
C["R6_0"]=vq(P.V6)

# ---- coefficients
KF=[Coef(f"KF{s}",(1/M.R_IN)/g) for s,g in zip(("LO","HI"),_g6)]
K_P1=Coef("KP1",(M.R_OP/M.R_IN)/_D)              # pin from feed - q
K_P2=Coef("KP2",(M.R_OP/R_TR)/_D)                # pin from the reset current
K_Q1=Coef("KQ1",DT/(M.R_IN*M.C_RAMP),FS)
K_Q2=Coef("KQ2",DT/(R_TR*M.C_RAMP),FS)
K_REF=Coef("KREF",DT/(M.R_REF14*M.C30),FS)
K_U=Coef("KU",M.K15)
K_HA=Coef("KHA",HYST_AH)
K_HL=Coef("KHL",_rb)
K_SA=Coef("KSA",5.1e3/10e3)
K_SB=Coef("KSB",2*M.K_P17)
K_RB=Coef("KRB",(M.K_P17/51e3)/(1/6.8e3+1/2.7e3+2/51e3))
K_RD=Coef("KRD",(1/102e3)/(1/5.1e3+1/1e3+2/102e3))
K_R6=Coef("KR6",M3.R_SCHFB/(M3.R_SCH6+M3.R_SCHFB))      # cells: vplus from r6
K_CON=[Coef(f"KCON{n}",g*DT/M.C_CON,FS) for n,g in ((1,BANK_G[0]),(2,BANK_G[1]))]
K_R6A=Coef("KR6A",2*DT/(1e3*M.R6_C),FS)
K_R6B=Coef("KR6B",DT/(51e3*M.R6_C),FS)
_kn=1+2*P.R_MC_OUT/M.MC_RIN
K_N1=Coef("KN1",1/_kn)
K_N2=Coef("KN2",(P.R_MC_OUT/R_U)/_kn)
K_CIN=Coef("KCIN",DT/(M.C_IN*R_U),FS)
_bf=_bias(_gs,M.R_FRONT); _bb=_bias(_gs,M.R_BACK)
K_BFA=Coef("KBFA",_bf[0]); K_BFB=Coef("KBFB",_bf[1]); K_BFBO=Coef("KBFBO",_bias(0,M.R_FRONT)[1])
K_BBA=Coef("KBBA",_bb[0]); K_BBB=Coef("KBBB",_bb[1]); K_BBBO=Coef("KBBBO",_bias(0,M.R_BACK)[1])
K_QA=Coef("KQA",DT*_gs/M.C_A,FS)
K_QBF=Coef("KQBF",DT/(M.R_FRONT*M.C_B),FS)
K_QBB=Coef("KQBB",DT/(M.R_BACK*M.C_B),FS)
K_IF=Coef("KIF",M.R426/M.R_FRONT)                # front current times R426
K_MF=Coef("KMF",22e3/M.R409)                     # R409 current times R414
K_15=Coef("K15C",DT/(M.R409*M.C15),FS)
COEFS=KF+[K_P1,K_P2,K_Q1,K_Q2,K_REF,K_U,K_HA,K_HL,K_SA,K_SB,K_RB,K_RD,K_R6]+K_CON+ \
      [K_R6A,K_R6B,K_N1,K_N2,K_CIN,K_BFA,K_BFB,K_BFBO,K_BBA,K_BBB,K_BBBO,K_QA,K_QBF,
       K_QBB,K_IF,K_MF,K_15]+[F3.C_KA[0],F3.C_KA[1],F3.C_KA[2],F3.C_KB[0],F3.C_KB[1],
       F3.C_KB[2],F3.C_SCH,F3.C_KTH,F3.C_K64,F3.C_ICS]

# ---- tables, in three ROMs: the MC3340's (each MC3340 block), the bus's
# (the banks: SOFT, VDROP) and the reset current's (the control block)
def _from3(name): return dict(F3.TAB[name])
_k=round(-math.log2(M.T_TR.dx)); assert 2.0**-_k==M.T_TR.dx
ROMS={"mc":[_from3(n) for n in ("G","VO0","LO","VON","VONW","H","IB","W","IC","S")],
      "bus":[_from3(n) for n in ("SOFT","VDROP")],
      "tr":[{"name":"TR","x0":vq(M.T_TR.x0),"k":_k,
             "v":[int(round(v*R_TR*2**FV)) for v in M.T_TR.v]}]}
ROM_SIZE={}
for rom,tabs in ROMS.items():
    base=0
    for t in tabs:
        t["base"]=base; t["n"]=len(t["v"]); base+=t["n"]
        assert all(abs(v)<2**(VBITS-2) for v in t["v"]),t["name"]
        assert FV-t["k"]<=24,t["name"]
    ROM_SIZE[rom]=base
TABLES=[t for tabs in ROMS.values() for t in tabs]
TAB={t["name"]:t for t in TABLES}
U_MAX,IC_LAST,S_MAX=F3.U_MAX,F3.IC_LAST,F3.S_MAX

def tab(name,x):
    t=TAB[name]; F=FV-t["k"]; r=x-t["x0"]
    if r<0: i,f=0,0
    else:
        i=r>>F; f=r&((1<<F)-1)
        if i>=t["n"]-1: i,f=t["n"]-2,1<<F
    v0=t["v"][i]; v1=t["v"][i+1]
    return v0+mul(v1-v0,f,F)

def mc3340(mcin,con):
    """The D-3 twin's MC3340: (unloaded output, input current times R_U)."""
    c=C
    g=tab("G",con); vo0=tab("VO0",con); lo=tab("LO",con)
    von=tab("VON",con); vonw=tab("VONW",con)
    h=tab("H",mcin); ib=tab("IB",mcin)
    w=tab("W",mcin-vonw)
    u=mcin-von
    ic=tab("IC",u) if u<=U_MAX else IC_LAST+F3.C_ICS(u-U_MAX)
    heff=h+mul(c["H_LOW"]-h,w>>3,FV-3)
    x=vo0-mul(heff,g>>3,FV-3)-lo
    mco=lo+(x if x>=S_MAX else tab("S",x))
    return min(mco,c["MC_HI"]),ib+ic

class BankFixed:
    def __init__(self,no):
        c=C; self.no=no
        self.cap=[0,0,0]; self.cmp=[c["VOL_C"]-c["CMP_OVER"]]*3; self.tr=[False]*3
        self.qcon=0; self.q64=0; self.inl=0
    def step(self,cv,r6):
        c=C
        vm=cv>>1
        outs=[]; svp=0
        for n in range(3):
            dc=F3.C_KA[n](cv-vm)
            if self.tr[n]: dc-=F3.C_KB[n](vm-c["VCE"])
            self.cap[n]+=dc
            vout=vm-(self.cap[n]>>SW)
            if vout>c["VOH"]: vout=c["VOH"]; self.cap[n]=(vm-c["VOH"])<<SW
            elif vout<c["VOL"]: vout=c["VOL"]; self.cap[n]=(vm-c["VOL"])<<SW
            vo=clamp(self.cmp[n],c["VOL_C"],c["VOH_C"])
            vplus=K_R6(r6)+F3.C_SCH(vo)
            svp+=vplus
            if vplus>vout: self.cmp[n]=min(self.cmp[n]+c["SLEW"],c["VOH_C"]+c["CMP_OVER"])
            else: self.cmp[n]=max(self.cmp[n]-c["SLEW"],c["VOL_C"]-c["CMP_OVER"])
            self.tr[n]=self.cmp[n]>c["VTR"]
            outs.append(vout)
        o1,o2,o3=outs
        con=o1-(self.qcon>>SW)
        self.qcon+=K_CON[self.no-1](con)-c[f"CON_I0_{self.no}"]
        if o2>=o3: hi_,d=o2,o3-o2
        else: hi_,d=o3,o2-o3
        top=hi_+tab("SOFT",-d)
        q64s=self.q64>>SW
        vth=F3.C_KTH(q64s+c["MC_VB"])-self.inl
        v=top-vth
        bus=vth if v<=0 else top-tab("VDROP",v)
        mcin=bus-q64s
        mco,iin=mc3340(mcin,con)
        self.inl=iin-F3.C_KTH(mcin-c["MC_VB"])
        self.q64+=F3.C_K64(iin)
        self.svp=svp; self.o=outs; self.con=con; self.mcin=mcin; self.mco=mco
        return mco

class PathFixed:
    def __init__(self,front):
        self.front=front
        self.qin=0; self.inl=0; self.qa=0; self.qb=0
    def a_lin(self):
        return -F3.C_KTH((self.qin>>SW)+C["MC_VB"])+self.inl
    def mc(self,node,con):
        mcin=node-(self.qin>>SW)
        mco,iin=mc3340(mcin,con)
        # relaxed by a sixteenth a step (d67_model.Path.mc)
        self.inl+=(iin-F3.C_KTH(mcin-C["MC_VB"])-self.inl)>>4
        self.qin+=K_CIN(iin)
        self.mcin=mcin; self.mco=mco
        return mco
    def out(self,on):
        """Returns b - qb - 6 V (the current times the summing resistor)."""
        c=C
        qa=self.qa>>SW; qb=self.qb>>SW
        if self.front:
            b=(K_BFA(self.mco-qa)+K_BFB(qb)+c["BF_ON"]) if on else K_BFBO(qb)+c["BF_OFF"]
        else:
            b=(K_BBA(self.mco-qa)+K_BBB(qb)+c["BB_ON"]) if on else K_BBBO(qb)+c["BB_OFF"]
        if on: self.qa+=K_QA(self.mco-qa-b)
        e=b-qb-c["V6"]
        self.qb+=(K_QBF if self.front else K_QBB)(e)
        self.b=b
        return e

class CtlFixed:
    def __init__(self):
        c=C
        self.ref14=0; self.q=[0,0]; self.vm=[0,0]
        self.c29=[False,False]; self.sel=[False]*4
        self.os59=[0,0]; self.os58=0; self.nor_a=False; self.nor_c=False
    def hyst(self,x,hi,ref):
        b=C["HYST_BH"]+K_HA(x) if hi else C["HYST_BL"]+K_HL(x)
        return b>ref
    def ramp(self,k,feed,tr_on):
        c=C
        q=self.q[k]>>SW; ref=self.ref14>>SW
        itr=tab("TR",self.vm[k]) if tr_on else 0
        common=K_P1(feed-q)-K_P2(itr)
        pin=c["PH0"]+common; vm=pin+q
        if vm>ref:
            pin=c["PL0"]+common; vm=pin+q
            if vm<ref: vm=ref; pin=ref-q
        self.q[k]+=K_Q1(feed-vm)-K_Q2(itr)
        self.vm[k]=vm
        return pin
    def step(self,acc,fs_low):
        c=C
        n=acc>>1&7
        hi=n>=6
        feed=(c["FEED0_HI"] if hi else c["FEED0_LO"])+KF[hi](self.vm[0]+self.vm[1])
        r14=self.ramp(0,feed,self.os59[0]>0)
        r28=self.ramp(1,feed,self.os59[1]>0)
        self.ref14+=K_REF(c["V6"]-(self.ref14>>SW))
        u1=clamp(c["U0"]-K_U(r14),c["VOL"],c["VOH"])
        u2=clamp(c["U0"]-K_U(r28),c["VOL"],c["VOH"])
        self.c29[0]=self.hyst(u1,self.c29[0],c["REF6"])
        self.c29[1]=self.hyst(u2,self.c29[1],c["REF6"])
        c292=not self.c29[0]; c2913=not self.c29[1]
        n56=n<4
        nor_a=fs_low and not c292 and not n56
        nor_b=fs_low and not c2913 and not n56
        nor_c=nor_b and c292 and not self.os58>0
        if self.os59[0]>0: self.os59[0]-=1
        if self.os59[1]>0: self.os59[1]-=1
        if self.os58>0: self.os58-=1
        if nor_a and not self.nor_a: self.os59[0]=M.OS59; self.os58=M.OS58
        if nor_c and not self.nor_c: self.os59[1]=M.OS59
        self.nor_a,self.nor_c=nor_a,nor_c
        su=u1+u2
        rb=c["RB0"]+K_RB(su); rd=c["RD0"]+K_RD(su)
        def lim(x): return clamp(x,c["VOL"],c["VOH"])
        s=[]
        for u in (u1,u2):
            s.append((lim(c["SA0"]-K_SA(u)),lim(K_SB(u)-rb),lim(c["SC0"]-u),lim((u+rd)>>1)))
        cons=[]
        for k,(x,y) in enumerate(((s[0][0],s[0][1]),(s[0][2],s[0][3]),
                                  (s[1][0],s[1][1]),(s[1][2],s[1][3]))):
            self.sel[k]=self.hyst(x,self.sel[k],y)
            cons.append(x if self.sel[k] else y)
        con20,con19,con34,con33=cons
        return dict(feed=feed,r14=r14,r28=r28,u1=u1,u2=u2,c292=c292,c2913=c2913,
                    q59a=self.os59[0]>0,q59b=self.os59[1]>0,q58=self.os58>0,
                    con20=con20,con19=con19,con34=con34,con33=con33,
                    cv1=clamp(c["CV1_0"]-con20,c["VOL"],c["CV_MAX"]),
                    cv2=clamp(c["CV2_0"]-con34,c["VOL"],c["CV_MAX"]),ref14=self.ref14>>SW)

class D67Fixed:
    def __init__(self):
        self.ctl=CtlFixed()
        self.banks=[BankFixed(1),BankFixed(2)]
        self.paths=[PathFixed(True),PathFixed(False),PathFixed(True),PathFixed(False)]
        self.r6=C["R6_0"]<<SW
        self.q15=0
        self.prev=dict(m1=0,m2=0,con20=0,con19=0,con34=0,con33=0,cv1=0,cv2=0,
                       q59a=False,q59b=False)
        self.out={}
    def step(self,acc,fs_low):
        c=C; pv=self.prev; p=self.paths; b1,b2=self.banks
        snds=[]
        for mco,pf,pb,cf,cb in ((pv["m1"],p[0],p[1],pv["con20"],pv["con19"]),
                                (pv["m2"],p[2],p[3],pv["con34"],pv["con33"])):
            node=K_N1(mco)-K_N2(pf.a_lin()+pb.a_lin())
            snds.append(node)
            pf.mc(node,cf); pb.mc(node,cb)
        on1=not pv["q59a"]; on2=not pv["q59b"]
        e_f=K_IF(p[0].out(on1))+K_IF(p[2].out(on2))
        i_b=p[1].out(on1)+p[3].out(on2)
        front=clamp(c["V6"]-e_f,c["VOL"],c["VOH"])
        q15=self.q15>>SW
        e15=front-q15-c["V6"]
        i_mf=K_MF(e15)
        self.q15+=K_15(e15)
        r6=self.r6>>SW
        m1=b1.step(pv["cv1"],r6)
        m2=b2.step(pv["cv2"],r6)
        self.r6+=K_R6A(c["V6"]-r6)-K_R6B(6*r6-b1.svp-b2.svp)
        cc=self.ctl.step(acc,fs_low)
        self.prev=dict(cc,m1=m1,m2=m2)
        self.out.update(cc,snd1=snds[0],snd2=snds[1],con1=b1.con,con2=b2.con,
                        o1=b1.o[0],o2=b1.o[1],o3=b1.o[2],o1b=b2.o[0],front=front,
                        i_mf=i_mf,i_mb=i_b,r6=self.r6>>SW,b1f=p[0].b,b1b=p[1].b,
                        b2f=p[2].b,b2b=p[3].b,m20=p[0].mco,m19=p[1].mco,m34=p[2].mco,
                        m33=p[3].mco)
        return i_mf

def write_vh(path):
    def sv(v,bits=VBITS):
        return f"-{bits}'sd{-v}" if v<0 else f"{bits}'sd{v}"
    L=["// SPDX-License-Identifier: GPL-3.0-or-later",
       "// GENERATED by tests/sound/d67_fixed.py from the sound models in tests/sound;",
       "// do not edit. Constants and tables of the D-6/D-7 modules: signals 2^28",
       "// per volt, capacitor states 2^44 per volt; coefficient = M / 2^S.",
       ""]
    for k,v in C.items():
        bits=SBITS if k.startswith("CON_I0") else VBITS
        L.append(f"localparam signed [{bits-1}:0] {k} = {sv(v,bits)};")
    L.append(f"localparam signed [{VBITS-1}:0] U_MAX = {sv(U_MAX)};")
    L.append(f"localparam signed [{VBITS-1}:0] IC_LAST = {sv(IC_LAST)};")
    L.append(f"localparam signed [{VBITS-1}:0] S_MAX = {sv(S_MAX)};")
    L.append(f"localparam integer OS59_N = {M.OS59}, OS58_N = {M.OS58};")
    for co in COEFS:
        L.append(f"localparam signed [{BBITS-1}:0] {co.name}_M = {sv(co.m,BBITS)};  // {co.k:.6g}")
        L.append(f"localparam [5:0] {co.name}_S = 6'd{co.s};")
    for rom,tabs in ROMS.items():
        assert ROM_SIZE[rom]<4096
        for t in tabs:
            L.append(f"localparam [11:0] T_{t['name']}_BASE = 12'd{t['base']}, T_{t['name']}_N = 12'd{t['n']};")
            L.append(f"localparam [4:0] T_{t['name']}_F = 5'd{FV-t['k']};")
            L.append(f"localparam signed [{VBITS-1}:0] T_{t['name']}_X0 = {sv(t['x0'])};")
        L.append(f"localparam integer ROM_{rom.upper()}_SIZE = {ROM_SIZE[rom]};")
    for rom,tabs in ROMS.items():
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

KEYS=("r14","r28","u1","u2","con20","con19","con34","con33","cv1","cv2","con1","con2",
      "o1","o2","o3","snd1","snd2","front","r6")
def check(seconds=3.0):
    """Run both models through the reference scenario; report the largest
    differences and the trigger steps."""
    import d67_reference as R
    n=int(round(seconds*P.TICK_HZ))
    a=M.D67(); b=D67Fixed(); s=1.0/(1<<FV)
    worst={}; trig={"a":[],"b":[]}
    pa=pb=(False,False)
    for k in range(n):
        acc,low=R.inputs(k)
        ia=a.step(acc,low); ib=b.step(acc,low)
        qa=(a.out["q59a"],a.out["q59b"]); qb=(b.out["q59a"],b.out["q59b"])
        for j in (0,1):
            if qa[j] and not pa[j]: trig["a"].append((j,k))
            if qb[j] and not pb[j]: trig["b"].append((j,k))
        pa,pb=qa,qb
        if k%48==0:
            for key in KEYS:
                e=abs(a.out[key]-b.out[key]*s)
                if e>worst.get(key,(0,0))[0]: worst[key]=(e,k*P.DT)
            e=abs(ia*22e3-ib*s)
            if e>worst.get("i_mf",(0,0))[0]: worst["i_mf"]=(e,k*P.DT)
    for key,(e,t) in worst.items(): print(f"{key:6s} max |float - fixed| {e:.5f} V at {t:.3f} s")
    print("triggers (car, step): float",trig["a"]); print("                     fixed",trig["b"])

if __name__=="__main__":
    if sys.argv[1]=="vh": write_vh(Path(sys.argv[2])/"jtmonacogp_snd_d67.vh")
    elif sys.argv[1]=="check": check(float(sys.argv[2]) if len(sys.argv)>2 else 3.0)
