#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Fixed-point twin of the D-5 Verilog (jtmonacogp_snd_d5.v) and the
generator of its constants and tables (jtmonacogp_snd_d5.vh).

The arithmetic is the Verilog's, operation for operation, with the D-3
twin's conventions (d3_fixed.py): signals 2^28 per volt in 36 bits,
capacitor states 2^44 per volt in 52 bits, products mul(a, b, s) =
(a*b + 2^(s-1)) >> s with a 27-bit second operand, tables read at two
neighbouring entries and interpolated. The MC3340 is the D-6/D-7 twin's
(d67_fixed.mc3340); the Verilog computes it inline on its own multiplier,
from a copy of the same tables. The floating-point model (d5_model.py)
supplies every value; this file only quantizes it.

Settings (Build): the six trimmers and the tempo capacitor. The core is
built with the model's (d5_model.DEFAULT_VR, C106); the checks use the
SPICE reference's (d5_reference.ref_vr(), REF_C106), written as a second
include (jtmonacogp_snd_d5_ref.vh, never in the core) that the module
reads when D5_REF is defined.

  d5_fixed.py vh DIR [ref]   write jtmonacogp_snd_d5.vh (or with `ref`
                             jtmonacogp_snd_d5_ref.vh) into DIR
  d5_fixed.py check [S]      compare with the floating-point model (scenario
                             of d5_reference.py, S seconds, default 3)
"""
import math
import sys
from pathlib import Path
import sound_parts as P
import d3_fixed as F3
import d67_fixed as F67
import d4_fixed as F4
import d5_model as M

FV,FS,SW=F3.FV,F3.FS,F3.SW
VBITS,SBITS,BBITS=F3.VBITS,F3.SBITS,F3.BBITS
vq,mul,clamp,Coef=F3.vq,F3.mul,F3.clamp,F3.Coef
DT=P.DT
R_U=F67.R_U                    # current unit of the MC3340's input current
R414=F4.R414
F_RUD=24                       # RUD table: 2^24 per unit ratio
def sq(x): return int(round(x*(1<<FS)))

def sel_index(a,b,c):
    """The note selects (PROM bits A, B, C, low = selected) as the index of
    the CV0 tables: bit 2 A, bit 1 B, bit 0 C, set when selected."""
    return ((not a)<<2)|((not b)<<1)|(not c)

class Build:
    """Constants, coefficients and tables for one setting of the trimmers
    and the tempo capacitor."""
    def __init__(self,vr=None,c106=M.C106):
        vr=dict(vr) if vr else dict(M.DEFAULT_VR)
        self.vr=vr; self.c106=c106
        ref=M.V12*M.R10/(33e3+M.R10)
        v3,i14,i5=M.D5.lfo_currents()
        k_tempo=math.exp(-DT/(M.RP_TEMPO*c106))
        self.C={"VOH":vq(M.VOH),"VOL":vq(M.VOL),"V6":vq(M.V6),"REF":vq(ref),
                # tempo: thresholds (state units), where the node heads
                "VTP":sq(M.VT_P),"VTN":sq(M.VT_N),"VC0":sq(M.tempo_vinf(True,False)),
                "VI_HB":vq(M.tempo_vinf(True,True)),"VI_HA":vq(M.tempo_vinf(True,False)),
                "VI_LB":vq(M.tempo_vinf(False,True)),"VI_LA":vq(M.tempo_vinf(False,False)),
                # vibrato: C3's step with TR1 off / on (state units), the
                # IC1 b thresholds with its output high / low, the start
                "DL_OFF":sq(i14*DT/0.47e-6),"DL_ON":sq((i14-i5)*DT/0.47e-6),
                "TH_H":vq((M.V6+M.O1_7_HIGH)/2),"TH_L":vq((M.V6+M.VOL)/2),
                "LFO0":sq(v3),
                # envelope
                "VQ":vq(M.TTL_VOH),"N50A":sq(M.VCC/2.7e3*DT/47e-6)}
        # the summers' outputs with the vibrato at rest, per select index
        # (bit 2 A, bit 1 B, bit 0 C) and bank
        def cv0(branches,radj,idx):
            sel=(bool(idx>>2&1),bool(idx>>1&1),bool(idx&1))
            vth,rth=M.bank_thevenin(radj,branches,sel)
            return vq(ref-10e3*(vth-ref)/(rth+39e3))
        self.CV0U=[cv0((vr["VR4"],vr["VR5"]+220,vr["VR6"]+680),M.R23,i) for i in range(8)]
        self.CV0L=[cv0((vr["VR1"],vr["VR2"]+220,vr["VR3"]+680),M.R1,i) for i in range(8)]
        K=[]
        def co(name,k,out=FV):
            c=Coef(name,k,out); K.append(c); return c
        self.KT=co("KT",1-k_tempo,FS)
        self.KL=co("KL",10e3/1e6)
        self.KQ=co("KQ",DT/(1e6*4.7e-6),FS)
        vu=M.Vco(M.R29); vl=M.Vco(M.R37)
        assert vu.k_dn==vl.k_dn and vu.a==vl.a, "the two oscillators differ: per-bank tables needed"
        self.vco=vu
        self.KDN=co("KDN",vu.k_dn*DT)
        self.KA=co("KA",vu.a)
        self.KM=co("KM",100e3/220e3)
        # filters: Phi - I (state per signal) and the inputs' gains
        def foh(name,f):
            phi,g0,g1=f
            return ([[co(f"{name}A{i}{j}",phi[i][j]-(1.0 if i==j else 0.0),FS) for j in range(2)] for i in range(2)],
                    [co(f"{name}G{i}0",g0[i],FS) for i in range(2)],
                    [co(f"{name}G{i}1",g1[i],FS) for i in range(2)])
        self.LP=foh("LP",M.FOH_LP); self.HP=foh("HP",M.FOH_HP)
        self.KE=[co("KE0",DT/6.8e-6*(1/470e3+1/(68e3+P.R_OC)),FS),co("KE1",DT/6.8e-6/470e3,FS)]
        self.K50=co("K50",(1/2.7e3+1/5.1e3)*DT/47e-6,FS)
        self.KC=co("KC",15e3/33e3)
        self.KC8=co("KC8",DT/(1e-6*R_U),FS)
        self.KROLL=co("KROLL",M.K_ROLL)
        r15=P.R_MC_OUT+39e3
        self.K15=co("K15",DT/(r15*2.2e-6),FS)
        self.KMX=co("KMX",R414/r15)
        self.KPIN=co("KPIN",P.R_MC_OUT/r15)
        self.COEFS=K
        self.TW=M.TW_STEPS
        # tables: the oscillators' (against CV), the envelope diode, then
        # the MC3340's (d67_fixed)
        t=vu
        x0,dx=t.top.x0,t.top.dx
        cvs=[x0+dx*k for k in range(t.top.n)]
        rud=P.Table(x0,dx,[t.r_up.v[k]/(cv*t.k_dn) for k,cv in enumerate(cvs)])
        rdu=P.Table(x0,dx,[(cv*t.k_dn)/t.r_up.v[k] for k,cv in enumerate(cvs)])
        def tab(name,table,scale):
            k=round(-math.log2(table.dx)); assert 2.0**-k==table.dx,name
            return {"name":name,"x0":vq(table.x0),"k":k,"v":[int(round(v*scale)) for v in table.v]}
        own=[tab("TOP",t.top,2**FV),tab("BOT",t.bot,2**FV),tab("RUP",t.r_up,DT*2**FV),
             tab("RUD",rud,2**F_RUD),tab("RDU",rdu,2**FV),tab("D4",M.T_D4,DT/6.8e-6*2**FS)]
        mc=[dict(t) for t in F67.ROMS["mc"]]
        self.TABS=own+mc
        base=0
        for t in self.TABS:
            t["base"]=base; t["n"]=len(t["v"]); base+=t["n"]
            assert all(abs(v)<2**(VBITS-2) for v in t["v"]),t["name"]
            assert FV-t["k"]<=BBITS-2,t["name"]
        self.ROM_SIZE=base
        self.TAB={t["name"]:t for t in self.TABS}
        assert max(self.TAB["RDU"]["v"])<2**(BBITS-1)

    def tab(self,name,x):
        t=self.TAB[name]; F=FV-t["k"]; r=x-t["x0"]
        if r<0: i,f=0,0
        else:
            i=r>>F; f=r&((1<<F)-1)
            if i>=t["n"]-1: i,f=t["n"]-2,1<<F
        v0=t["v"][i]; v1=t["v"][i+1]
        return v0+mul(v1-v0,f,F)

B=Build()

class SequencerFixed(M.Sequencer):
    """The float sequencer's logic with the tempo capacitor in state units."""
    def __init__(self,b,prom=None):
        super().__init__(prom,b.c106)
        self.b=b
        self.vc=b.C["VC0"]
    def t_ge_p(self): return self.vc>=self.b.C["VTP"]
    def t_le_n(self): return self.vc<=self.b.C["VTN"]
    def t_update(self):
        c=self.b.C
        below=self.vc<c["VTP"]
        v=(c["VI_HB"] if below else c["VI_HA"]) if self.o11 else (c["VI_LB"] if below else c["VI_LA"])
        self.vc+=self.b.KT(v-(self.vc>>SW))

class VcoFixed:
    def __init__(self): self.s=None; self.up=False
    def step(self,b,cv):
        dn=b.KDN(cv)
        upr=b.tab("RUP",cv)
        bt=b.tab("TOP" if self.up else "BOT",cv)
        ratio=b.tab("RDU" if self.up else "RUD",cv)
        if self.s is None:
            # power-up (d5_model.Vco): at the + input, rising if below BOT
            self.s=b.KA(cv); self.up=self.s<=bt
            return self.s
        s=self.s
        if not self.up:
            s-=dn
            if s<=bt:
                s=bt+mul(ratio,bt-s,F_RUD); self.up=True
        else:
            s+=upr
            if s>=bt:
                s=bt-mul(s-bt,ratio,FV); self.up=False
        self.s=s
        return s

class D5Fixed:
    def __init__(self,build=None,prom=None):
        self.b=build or B
        c=self.b.C
        self.seq=SequencerFixed(self.b,prom)
        self.lfo=c["LFO0"]; self.o17=True
        self.q=0
        self.vu=VcoFixed(); self.vl=VcoFixed()
        self.xlp=[0,0]; self.xhp=[0,0]; self.p_mix=0; self.p_lp=0
        self.env=0; self.n50=0; self.q8=0; self.q15=0; self.mcf=None
        self.out={}

    def foh(self,f,x,u0,u1):
        A,G0,G1=f
        xs=[x[0]>>SW,x[1]>>SW]
        return [x[i]+A[i][0](xs[0])+A[i][1](xs[1])+G0[i](u0)+G1[i](u1) for i in range(2)]

    def step(self,hiscore_n=1,mute=0):
        b=self.b; c=b.C
        s=self.seq.step(hiscore_n,mute)
        # vibrato
        self.lfo-=c["DL_ON"] if self.o17 else c["DL_OFF"]
        self.lfo=clamp(self.lfo,c["VOL"]<<SW,c["VOH"]<<SW)
        lfo=self.lfo>>SW
        self.o17=lfo<(c["TH_H"] if self.o17 else c["TH_L"])
        # the note voltages
        e=lfo-(self.q>>SW)-c["REF"]
        kl=b.KL(e)
        idx=sel_index(s["a"],s["b"],s["c"])
        cvu=clamp(b.CV0U[idx]-kl,c["VOL"],c["VOH"])
        cvl=clamp(b.CV0L[idx]-kl,c["VOL"],c["VOH"])
        self.q+=b.KQ(e)
        # the sawtooths and the mixer
        su=self.vu.step(b,cvu); sl=self.vl.step(b,cvl)
        mix=clamp(c["V6"]-(su-c["V6"])-b.KM(sl-c["V6"]),c["VOL"],c["VOH"])
        # filters
        self.xlp=self.foh(b.LP,self.xlp,self.p_mix,mix); self.p_mix=mix
        lp=clamp(self.xlp[1]>>SW,c["VOL"],c["VOH"])
        self.xhp=self.foh(b.HP,self.xhp,self.p_lp-c["V6"],lp-c["V6"]); self.p_lp=lp
        hp=clamp(lp-(self.xhp[0]>>SW)-(self.xhp[1]>>SW),c["VOL"],c["VOH"])
        # envelope
        envs=self.env>>SW
        d=b.tab("D4",c["VQ"]-envs) if s["q123"] else 0
        self.env+=d-b.KE[s["h"]](envs)
        envf=clamp(self.env>>SW,c["VOL"],c["VOH"])
        self.n50+=c["N50A"]-b.K50(self.n50>>SW)
        n50=self.n50>>SW
        con=clamp(n50+b.KC(n50-envf),c["VOL"],c["VOH"])
        # MC3340, C8, the C100 pole, C15 and R408
        mcin=hp-(self.q8>>SW)
        mco,iin=F67.mc3340(mcin,con)
        self.q8+=b.KC8(iin)
        self.mcf=mco if self.mcf is None else self.mcf+b.KROLL(mco-self.mcf)
        e15=self.mcf-(self.q15>>SW)-c["V6"]
        self.q15+=b.K15(e15)
        pin=self.mcf-b.KPIN(e15)
        imix=b.KMX(e15)
        self.out={"lfo":lfo,"cvu":cvu,"cvl":cvl,"sawu":su,"sawl":sl,"mix":mix,"lp":lp,"hp":hp,
                  "env":self.env>>SW,"con":con,"mco":pin,"e15":e15,"i_mix":imix,**s}
        return imix

def write_vh(path,b=B):
    def sv(v,bits=VBITS):
        return f"-{bits}'sd{-v}" if v<0 else f"{bits}'sd{v}"
    L=["// SPDX-License-Identifier: GPL-3.0-or-later",
       "// GENERATED by tests/sound/d5_fixed.py from the sound models in tests/sound;",
       "// do not edit. Constants and tables of jtmonacogp_snd_d5: signals 2^28",
       "// per volt, capacitor states 2^44 per volt; coefficient = M / 2^S.",
       "// Trimmers (ohm): "+", ".join(f"{k} {b.vr[k]:g}" for k in sorted(b.vr))+f"; C106 {b.c106*1e6:g} uF.",
       ""]
    for k,v in b.C.items():
        bits=SBITS if k in ("VTP","VTN","VC0","DL_OFF","DL_ON","LFO0","N50A") else VBITS
        L.append(f"localparam signed [{bits-1}:0] D5_{k} = {sv(v,bits)};")
    for name,arr in (("CV0U",b.CV0U),("CV0L",b.CV0L)):
        for i,v in enumerate(arr):
            L.append(f"localparam signed [{VBITS-1}:0] D5_{name}{i} = {sv(v)};")
    L.append(f"localparam [14:0] D5_TW = 15'd{b.TW};")
    for co in b.COEFS:
        L.append(f"localparam signed [{BBITS-1}:0] {co.name}_M = {sv(co.m,BBITS)};  // {co.k:.6g}")
        L.append(f"localparam [5:0] {co.name}_S = 6'd{co.s};")
    for k in ("H_LOW","MC_HI"):
        L.append(f"localparam signed [{VBITS-1}:0] MC_{k} = {sv(F67.C[k])};")
    L.append(f"localparam signed [{VBITS-1}:0] MC_U_MAX = {sv(F67.U_MAX)};")
    L.append(f"localparam signed [{VBITS-1}:0] MC_IC_LAST = {sv(F67.IC_LAST)};")
    L.append(f"localparam signed [{VBITS-1}:0] MC_S_MAX = {sv(F67.S_MAX)};")
    L.append(f"localparam signed [{BBITS-1}:0] KICS_M = {sv(F3.C_ICS.m,BBITS)};")
    L.append(f"localparam [5:0] KICS_S = 6'd{F3.C_ICS.s};")
    for t in b.TABS:
        L.append(f"localparam [11:0] T_{t['name']}_BASE = 12'd{t['base']}, T_{t['name']}_N = 12'd{t['n']};")
        L.append(f"localparam [4:0] T_{t['name']}_F = 5'd{FV-t['k']};")
        L.append(f"localparam signed [{VBITS-1}:0] T_{t['name']}_X0 = {sv(t['x0'])};")
    L.append(f"localparam integer ROM_D5_SIZE = {b.ROM_SIZE};")
    L.append(f"reg signed [{VBITS-1}:0] rom_d5 [0:ROM_D5_SIZE-1];")
    L.append("initial begin")
    for t in b.TABS:
        L.append(f"    // {t['name']}")
        for i,v in enumerate(t["v"]):
            L.append(f"    rom_d5[{t['base']+i}] = {sv(v)};")
    L.append("end")
    Path(path).write_text("\n".join(L)+"\n")

def ref_build():
    import d5_reference as R
    return Build(R.ref_vr(),R.REF_C106)

KEYS=("lfo","cvu","cvl","sawu","sawl","mix","lp","hp","env","con","mco")
def check(seconds=3.0):
    """Run both models through the reference scenario; report the largest
    differences and the sawtooths' turning steps."""
    import d5_reference as R
    n=int(round(seconds*P.TICK_HZ))
    bb=ref_build()
    a=M.D5(vr=R.ref_vr(),c106=R.REF_C106); f=D5Fixed(bb); s=1.0/(1<<FV)
    worst={}; turns={"a":[],"b":[]}; pa=pb=None; seqbad=0
    for k in range(n):
        h=R.hiscore_n(k)
        ia=a.step(h,0); ib=f.step(h,0)
        for key in ("addr","cnt","q123","alarm","clk"):
            if a.out[key]!=f.out[key]: seqbad+=1; break
        qa=a.vu.up; qb=f.vu.up
        if qa!=pa: turns["a"].append(k)
        if qb!=pb: turns["b"].append(k)
        pa,pb=qa,qb
        if k%16==0:
            for key in KEYS:
                e=abs(a.out[key]-f.out[key]*s)
                if e>worst.get(key,(0,0))[0]: worst[key]=(e,k*P.DT)
            e=abs(ia*R414-ib*s)
            if e>worst.get("i_mix",(0,0))[0]: worst["i_mix"]=(e,k*P.DT)
    for key,(e,t) in worst.items(): print(f"{key:6s} max |float - fixed| {e:.3g} V at {t:.3f} s")
    dk=max([abs(x-y) for x,y in zip(turns["a"],turns["b"])],default=0)
    print(f"upper sawtooth turns: float {len(turns['a'])}, fixed {len(turns['b'])}; largest offset {dk} steps")
    print(f"sequencer steps that differ: {seqbad}")

if __name__=="__main__":
    if sys.argv[1]=="vh":
        if len(sys.argv)>3 and sys.argv[3]=="ref": write_vh(Path(sys.argv[2])/"jtmonacogp_snd_d5_ref.vh",ref_build())
        else: write_vh(Path(sys.argv[2])/"jtmonacogp_snd_d5.vh")
    elif sys.argv[1]=="check": check(float(sys.argv[2]) if len(sys.argv)>2 else 3.0)
