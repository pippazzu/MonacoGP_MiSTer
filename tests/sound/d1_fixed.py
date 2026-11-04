#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Fixed-point twin of the D-1 Verilog (jtmonacogp_snd_d1.v) and the
generator of its constants and tables (jtmonacogp_snd_d1.vh).

The arithmetic is the Verilog's, operation for operation, with the D-3
twin's conventions (d3_fixed.py): signals 2^28 per volt in 36 bits,
capacitor states 2^44 per volt in 52 bits, products mul(a, b, s) =
(a*b + 2^(s-1)) >> s with a 27-bit second operand, tables read at two
neighbouring entries and interpolated. Currents are carried as volts
across R_U (10K, R345 and R350). The floating-point model (d1_model.py)
supplies every value; this file only quantizes it.

  d1_fixed.py vh DIR      write jtmonacogp_snd_d1.vh into DIR
  d1_fixed.py check [S]   compare with the floating-point model (scenario
                          of d1_reference.py, S seconds, default 3)
"""
import math
import sys
from pathlib import Path
import sound_parts as P
import d3_fixed as F3
import d4_fixed as F4
import d1_model as M
import d4_model as D4M

FV,FS,SW=F3.FV,F3.FS,F3.SW
VBITS,SBITS,BBITS=F3.VBITS,F3.SBITS,F3.BBITS
vq,mul,clamp,Coef=F3.vq,F3.mul,F3.clamp,F3.Coef
DT=P.DT
R_U=M.R345
assert M.R345==M.R350
R414=F4.R414

class Build:
    """Constants, coefficients and tables for one VR7 setting."""
    def __init__(self,a7=M.VR7_A7):
        self.a7=a7
        w7,rw=M.vr7(a7); rw+=M.R351
        on=1/M.R4016+1/M.R353+1/M.R354+1/M.R412
        off=1/M.R353+1/M.R354+1/M.R412
        self.C={"VOH":vq(M.VOH),"VOL":vq(M.VOL),"V6":vq(M.V6),
                "A10":vq(w7*M.R307/(M.R307+rw)),
                "N8_LO":vq(M.VOL-0.25),"N8_HI":vq(M.VOH+0.25),
                "SLEW":vq(M.SLEW_TICK),"XLIM":vq(M.VA_LIM),
                "SB_ON":vq((M.V12/M.R353+M.V6/M.R412)/on),
                "SB_OFF":vq((M.V12/M.R353+M.V6/M.R412)/off),
                "VN_HI":vq(D4M.NOISE_HI),"VN_LO":vq(D4M.NOISE_LO)}
        K=[]
        def co(name,k,out=FV):
            c=Coef(name,k,out); K.append(c); return c
        self.K10=co("K10",rw/(M.R307+rw))
        self.K63=co("K63",DT/(M.R309*M.C63),FS)
        self.KA=co("KA",1/(1+M.K_OA))
        self.KB=co("KB",M.K_OA/(1+M.K_OA))
        self.K68=co("K68",DT/(M.R345*M.C68),FS)
        self.K105=co("K105",DT/(M.R345*M.C105),FS)
        self.K3=co("K3",R_U/M.R348)
        self.K70=co("K70",DT/(R_U*M.C70),FS)
        self.K71=co("K71",DT/(M.R348*M.C71),FS)
        self.KG=co("KG",M.R346/M.R347)
        self.KGA=co("KGA",M.R346/(M.R346+M.R347))
        self.KGB=co("KGB",M.R347/(M.R346+M.R347))
        self.K69=co("K69",DT/(M.R347*M.C69),FS)
        self.KS1=co("KS1",(1/M.R4016)/on)
        self.KS2=co("KS2",(1/M.R412)/on)
        self.KS2F=co("KS2F",(1/M.R412)/off)
        self.K73=co("K73",DT/(M.R412*M.C73),FS)
        self.KMX=co("KMX",R414/M.R412)
        self.COEFS=K
        # tables: the slew step, then the transistor's c0..c3 (c0 in signal
        # units of volts across R_U; c1..c3 times R_U, scaled by 2^F1..F3)
        tr=M.T_TR
        mx=[max(abs(v) for v in t.v)*R_U for t in tr]
        self.F=[FV]+[35-math.ceil(math.log2(m)) for m in mx[1:]]
        assert self.F[1]==FV
        def tab(name,table,scale):
            k=round(-math.log2(table.dx)); assert 2.0**-k==table.dx,name
            return {"name":name,"x0":vq(table.x0),"k":k,"v":[int(round(v*scale)) for v in table.v]}
        self.TABS=[tab("SLEW",M.slew_table(a7),2**FV)]+ \
                  [tab(f"C{j}",tr[j],R_U*2.0**self.F[j]) for j in range(4)]
        base=0
        for t in self.TABS:
            t["base"]=base; t["n"]=len(t["v"]); base+=t["n"]
            assert all(abs(v)<2**(VBITS-1) for v in t["v"]),t["name"]
            assert FV-t["k"]<=BBITS-2,t["name"]
        self.ROM_SIZE=base
        assert base<=1024
        self.TAB={t["name"]:t for t in self.TABS}
        # Horner shifts: c3*x -> 2^F2, (..)*x -> 2^F1, (..)*x -> signal
        self.S3=self.F[3]+FV-self.F[2]
        self.S2=self.F[2]+FV-self.F[1]
        self.S1=self.F[1]
        # the linear continuation beyond XLIM: c1 >> E1 fits the 27-bit operand
        self.E1=max(0,math.ceil(math.log2(max(abs(v) for v in self.TAB["C1"]["v"])+1))-(BBITS-1))
        assert max(abs(v) for v in self.TAB["C1"]["v"])>>self.E1 < 2**(BBITS-1)

    def tab(self,name,x):
        t=self.TAB[name]; F=FV-t["k"]; r=x-t["x0"]
        if r<0: i,f=0,0
        else:
            i=r>>F; f=r&((1<<F)-1)
            if i>=t["n"]-1: i,f=t["n"]-2,1<<F
        v0=t["v"][i]; v1=t["v"][i+1]
        return v0+mul(v1-v0,f,F)

B=Build()

class D1Fixed:
    def __init__(self,build=None):
        self.b=build or B
        c=self.b.C
        self.v63=0; self.n8=0; self.o8=c["VOL"]
        self.q68=0; self.v105=0; self.q70=0; self.q71=0; self.vo=0
        self.q69=0; self.q73=0
        self.out={}

    def tr(self,va,vf):
        b=self.b; c=b.C
        x=clamp(va,-c["XLIM"],c["XLIM"])
        c3=b.tab("C3",vf); c2=b.tab("C2",vf); c1=b.tab("C1",vf); c0=b.tab("C0",vf)
        t=c2+mul(c3,x,b.S3)
        t=c1+mul(t,x,b.S2)
        i=c0+mul(t,x,b.S1)
        if va!=x: i+=mul(va-x,c1>>b.E1,b.S1-b.E1)
        return i

    def step(self,noise_hi,slip_n):
        """noise_hi: the S2688's bit this step; slip_n: pad J. Returns the
        R412 current times R414 (signal units)."""
        b=self.b; c=b.C
        # oscillator IC53 c and follower IC53 d
        v63s=self.v63>>SW
        vf=clamp(v63s,c["VOL"],c["VOH"])
        d=c["A10"]+b.K10(self.o8)-v63s
        self.v63+=b.K63(self.o8-v63s)
        self.n8=clamp(self.n8+b.tab("SLEW",d),c["N8_LO"],c["N8_HI"])
        self.o8=clamp(self.n8,c["VOL"],c["VOH"])
        # IC53 a's output, node A, the shunt
        q70s=self.q70>>SW; q71s=self.q71>>SW
        vo=b.KA(self.vo)+b.KB(c["V6"]-q70s+q71s)
        vo=clamp(vo,self.vo-c["SLEW"],self.vo+c["SLEW"])
        vo=clamp(vo,c["VOL"],c["VOH"])
        va=vo+q70s
        itr=self.tr(va,vf)
        # the noise input network
        vn=c["VN_HI"] if noise_hi else c["VN_LO"]
        v105s=self.v105>>SW
        e345=vn-(self.q68>>SW)-v105s
        e350=v105s-va
        self.q68+=b.K68(e345)
        self.v105+=b.K105(e345-e350)
        # C70, then C71 from C70's new charge
        e3=b.K3(q70s-q71s)
        self.q70+=b.K70(e350-itr-e3)
        self.q71+=b.K71((self.q70>>SW)-q71s)
        self.vo=vo
        # gain stage IC53 b
        n69=vo-(self.q69>>SW)
        o7=c["V6"]-b.KG(n69-c["V6"])
        if o7>c["VOH"] or o7<c["VOL"]:
            o7=clamp(o7,c["VOL"],c["VOH"])
            vm=b.KGA(n69)+b.KGB(o7)
        else: vm=c["V6"]
        self.q69+=b.K69(n69-vm)
        # the 4016 and the output
        q73s=self.q73>>SW
        if not slip_n: sw=b.KS1(o7)+b.KS2(q73s)+c["SB_ON"]
        else: sw=b.KS2F(q73s)+c["SB_OFF"]
        e412=sw-q73s-c["V6"]
        self.q73+=b.K73(e412)
        imix=b.KMX(e412)
        self.out.update(c63=self.v63>>SW,o8=self.o8,vf=vf,na=va,itr=itr,o1=vo,o7=o7,sw=sw,e412=e412)
        return imix

def write_vh(path,b=B):
    def sv(v,bits=VBITS):
        return f"-{bits}'sd{-v}" if v<0 else f"{bits}'sd{v}"
    L=["// SPDX-License-Identifier: GPL-3.0-or-later",
       "// GENERATED by tests/sound/d1_fixed.py from the sound models in tests/sound;",
       "// do not edit. Constants and tables of jtmonacogp_snd_d1: signals 2^28",
       "// per volt, capacitor states 2^44 per volt; coefficient = M / 2^S.",
       f"// VR7 wiper at {b.a7} of its travel from the ground end.",
       ""]
    for k,v in b.C.items():
        L.append(f"localparam signed [{VBITS-1}:0] D1_{k} = {sv(v)};")
    for co in b.COEFS:
        L.append(f"localparam signed [{BBITS-1}:0] {co.name}_M = {sv(co.m,BBITS)};  // {co.k:.6g}")
        L.append(f"localparam [5:0] {co.name}_S = 6'd{co.s};")
    L.append(f"localparam [5:0] D1_S3 = 6'd{b.S3}, D1_S2 = 6'd{b.S2}, D1_S1 = 6'd{b.S1};")
    L.append(f"localparam [5:0] D1_E1 = 6'd{b.E1}, D1_SE = 6'd{b.S1-b.E1};")
    for t in b.TABS:
        L.append(f"localparam [9:0] T_{t['name']}_BASE = 10'd{t['base']}, T_{t['name']}_N = 10'd{t['n']};")
        L.append(f"localparam [4:0] T_{t['name']}_F = 5'd{FV-t['k']};")
        L.append(f"localparam signed [{VBITS-1}:0] T_{t['name']}_X0 = {sv(t['x0'])};")
    L.append(f"localparam integer ROM_D1_SIZE = {b.ROM_SIZE};")
    L.append(f"reg signed [{VBITS-1}:0] rom_d1 [0:ROM_D1_SIZE-1];")
    L.append("initial begin")
    for t in b.TABS:
        L.append(f"    // {t['name']}")
        for i,v in enumerate(t["v"]):
            L.append(f"    rom_d1[{t['base']+i}] = {sv(v)};")
    L.append("end")
    Path(path).write_text("\n".join(L)+"\n")

KEYS=("c63","o8","na","o1","o7","sw")
def check(seconds=3.0):
    """Run both models through the reference scenario; report the largest
    differences and the oscillator's switching steps."""
    import d1_reference as R
    n=int(round(seconds*P.TICK_HZ))
    bb=Build(R.REF_A7)
    a=M.D1(R.REF_A7); b=D1Fixed(bb); s=1.0/(1<<FV)
    nb=R.noise_bits(n)
    worst={}; sw={"a":[],"b":[]}; pa=pb=None
    for k in range(n):
        sl=R.slip_n(k)
        ia=a.step(nb[k],sl)
        ib=b.step(nb[k],sl)
        qa=a.out["o8"]>6; qb=b.out["o8"]*s>6
        if qa!=pa: sw["a"].append(k)
        if qb!=pb: sw["b"].append(k)
        pa,pb=qa,qb
        if k%16==0:
            for key in KEYS:
                e=abs(a.out[key]-b.out[key]*s)
                if e>worst.get(key,(0,0))[0]: worst[key]=(e,k*P.DT)
            e=abs(ia*R414-ib*s)
            if e>worst.get("i_mix",(0,0))[0]: worst["i_mix"]=(e,k*P.DT)
    for key,(e,t) in worst.items(): print(f"{key:6s} max |float - fixed| {e:.3g} V at {t:.3f} s")
    dk=max([abs(x-y) for x,y in zip(sw["a"],sw["b"])],default=0)
    print(f"oscillator switches: float {len(sw['a'])}, fixed {len(sw['b'])}; largest offset {dk} steps")

if __name__=="__main__":
    if sys.argv[1]=="vh": write_vh(Path(sys.argv[2])/"jtmonacogp_snd_d1.vh")
    elif sys.argv[1]=="check": check(float(sys.argv[2]) if len(sys.argv)>2 else 3.0)
