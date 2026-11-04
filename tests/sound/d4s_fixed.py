#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Fixed-point twin of the D-4 sound sources in Verilog and the generator of
their constants and tables:

  jtmonacogp_snd_noise.v  S2688, noise amplifier, skid tone (triangle,
                          IC63 d, 555), EXTEND CP       -> .vh
  jtmonacogp_snd_band.v   one explosion band: band-pass, envelope, MC3340
                          chain (two instances, upper and lower) -> .vh
  jtmonacogp_snd_expl.v   the 74123 one-shots, both bands, IC66 a -> .vh

Arithmetic as d3_fixed.py: signals 2^28 per volt (36 bit), capacitor states
2^44 per volt (52 bit), products mul(a, m, s) with a 27-bit coefficient. The
floating-point model (d4_model.py) supplies every value. The sources'
currents into the mixer leave as voltages: current times R414 (22K).

  d4s_fixed.py vh HDLDIR     write the three Verilog includes
  d4s_fixed.py check [S]     compare with the floating-point model
"""
import math
import sys
from pathlib import Path
import sound_parts as P
import d3_fixed as F
import d4_model as M

FV,FS,SW=F.FV,F.FS,F.SW
vq,mul,clamp,Coef=F.vq,F.mul,F.clamp,F.Coef
R414=22e3
DT=P.DT

class Rom:
    """Tables on power-of-two grids in one ROM, read as d3_fixed.tab()."""
    def __init__(self,tables):
        self.tables=[]; base=0
        for name,table,scale in tables:
            k=round(-math.log2(table.dx)); assert 2.0**-k==table.dx
            t={"name":name,"x0":vq(table.x0),"k":k,"v":[int(round(v*scale)) for v in table.v],
               "base":base,"n":len(table.v)}
            assert all(abs(v)<2**(F.VBITS-2) for v in t["v"]),name
            assert FV-k<=F.BBITS-2,name
            base+=t["n"]; self.tables.append(t)
        self.size=base; self.t={t["name"]:t for t in self.tables}
    def __call__(self,name,x):
        t=self.t[name]; Fb=FV-t["k"]; r=x-t["x0"]
        if r<0: i,f=0,0
        else:
            i=r>>Fb; f=r&((1<<Fb)-1)
            if i>=t["n"]-1: i,f=t["n"]-2,1<<Fb
        v0=t["v"][i]; v1=t["v"][i+1]
        return v0+mul(v1-v0,f,Fb)

# =================================================================== noise
NC={"V6":vq(P.V6),"VOL":vq(P.VOL),"VOH":vq(P.VOH),"SLEW":vq(P.SLEW_TICK),
    "VN_HI":vq(M.NOISE_HI),"VN_LO":vq(M.NOISE_LO),
    "VP_HI":vq(M.D4.tri_switch(P.VOH)),"VP_LO":vq(M.D4.tri_switch(P.VOL)),
    "VTH_HI":vq(M.D4.tri_vth(P.VOH)),"VTH_LO":vq(M.D4.tri_vth(P.VOL)),
    "VCTL":vq(M.V_CTL),"VCC":vq(P.VCC),"VDIS":vq(M.D4.V_DIS),
    "O555_D":vq((M.V555_HI-M.V555_LO)*M.R404/(M.R404+M.R405)),
    "O555_LO":vq(M.V555_LO*M.R404/(M.R404+M.R405)),
    "VEX_HI":vq(M.VEX_HI),"VEX_LO":vq(M.VEX_LO)}
_R101=M.R405*M.R404/(M.R404+M.R405)+M.R403
NK=[Coef("K362",M.R362/M.R361),
    Coef("KMS",M.R362/(M.R361+M.R362)),Coef("KMO",M.R361/(M.R361+M.R362)),
    Coef("K79",DT/(M.R361*1e-6),FS),
    Coef("K94",DT/((M.R394+M.D4.TRI_RTH)*M.C94),FS),
    Coef("K385",M.R386/M.R385),Coef("K390",M.R386/M.R390),
    Coef("K80",DT/(M.R385*M.C80),FS),
    Coef("KCTL",M.R_CTL/(M.R_CTL+P.R_OPOUT)),
    Coef("K81",DT/((M.R_CTL+P.R_OPOUT)*M.C81),FS),
    Coef("KCH",M.D4.K_CH,FS),Coef("KDIS",M.D4.K_DIS,FS),
    Coef("K101",DT/(_R101*M.C101),FS),Coef("K403",R414/_R101),
    Coef("KEX",DT/(M.R402*M.C_EX),FS),Coef("K402",R414/M.R402)]
N={c.name:c for c in NK}

class NoiseFixed:
    def __init__(self):
        self.reg=0x1ffff; self.ph=0
        self.q79=0; self.namp=NC["V6"]
        self.c94=0; self.hi=True
        self.q80=0; self.q81=0
        self.c89=0; self.q555=False; self.q101=0
        self.qex=0; self.out={}
    def step(self,skid_on,excp):
        c=NC
        # S2688
        self.ph+=M.NOISE_NUM
        if self.ph>=M.NOISE_DEN:
            self.ph-=M.NOISE_DEN
            fb=(self.reg>>13^self.reg>>16^(self.reg==0))&1
            self.reg=((self.reg<<1)|fb)&0x1ffff
        vn=c["VN_HI"] if self.reg>>16&1 else c["VN_LO"]
        # noise amplifier IC63 c
        s=vn-(self.q79>>SW)
        vt=c["V6"]-N["K362"](s-c["V6"])
        vo=clamp(self.namp+clamp(vt-self.namp,-c["SLEW"],c["SLEW"]),c["VOL"],c["VOH"])
        vm=c["V6"] if vo==vt else N["KMS"](s)+N["KMO"](vo)
        self.q79+=N["K79"](s-vm)
        self.namp=vo
        # triangle IC64 b, follower IC64 a
        vot=c["VTH_HI"] if self.hi else c["VTH_LO"]
        self.c94+=N["K94"](vot-(self.c94>>SW))
        c94s=self.c94>>SW
        if self.hi and c94s>c["VP_HI"]: self.hi=False
        elif not self.hi and c94s<c["VP_LO"]: self.hi=True
        tri=clamp(c94s,c["VOL"],c["VOH"])
        # IC63 d
        s80=vn-(self.q80>>SW)
        o63d=clamp(c["V6"]-(N["K385"](s80-c["V6"])+N["K390"](tri-c["V6"])),c["VOL"],c["VOH"])
        self.q80+=N["K80"](s80-c["V6"])
        # C81 into the 555's CONTROL
        e81=o63d-(self.q81>>SW)-c["VCTL"]
        ctl=c["VCTL"]+N["KCTL"](e81)
        self.q81+=N["K81"](e81)
        # 555, SUB555 sub-steps; its output for the step is their mean
        nhi=0
        for _ in range(M.D4.SUB555):
            if not skid_on: self.q555=False
            nhi+=self.q555
            c89s=self.c89>>SW
            if self.q555: self.c89+=N["KCH"](c["VCC"]-c89s)
            else: self.c89+=N["KDIS"](c["VDIS"]-c89s)
            c89s=self.c89>>SW
            if skid_on:
                if c89s>=ctl: self.q555=False
                elif c89s<=ctl>>1: self.q555=True
        e101=c["O555_LO"]+(c["O555_D"]*nhi>>3)-(self.q101>>SW)-c["V6"]
        self.q101+=N["K101"](e101)
        i403=N["K403"](e101)
        # EXTEND CP
        e=(c["VEX_HI"] if excp else c["VEX_LO"])-(self.qex>>SW)-c["V6"]
        self.qex+=N["KEX"](e)
        i402=N["K402"](e)
        self.out.update(noise=vn,namp=vo,c94=c94s,tri=tri,o63d=o63d,ctl555=ctl,thtr=c89s,
                        out555=self.q555,i402=i402,i403=i403)
        return vo,i402+i403

# =================================================================== bands
MC=M.MC; MCT=MC.t
RTH=M.RTH_MC
BAND_ROM=Rom([("DQ",M.T_DQ,DT/M.C_ENV*2**(FS-4)),
              ("G",MC.g,2**FV),("VO0",MC.vo0,2**FV),("LO",MC.lo,2**FV),
              ("VON",MC.von,2**FV),("VONW",MC.vonw,2**FV),
              ("H",MC.h,2**FV),("IB",MC.ib,RTH*2**FV),
              ("W",MC.w,2**FV),("IC",MC.ic,RTH*2**FV),("S",MC.s,2**FV)])
BC={"V6":vq(P.V6),"VOL":vq(P.VOL),"VOH":vq(P.VOH),"VCC":vq(P.VCC),"VB2":vq(2*M.VB),
    "VOL_FOL":vq(M.VOL_FOL),"MC_VB":vq(M.MC_VB),"MC_C0":vq(M.MC_VB*RTH/M.MC_RIN),
    "H_LOW":vq(MCT["h_low"]),"MC_HI":vq(MCT["hi"]),"U_MAX":vq(MC.umax),
    "IC_LAST":BAND_ROM.t["IC"]["v"][-1],"S_MAX":vq(MC.smax)}
def band_coefs(tag,bp,renv):
    return [Coef(f"KIN_{tag}",DT/(bp["r1"]*bp["c_in"]),FS),
            Coef(f"K1_{tag}",DT/(bp["r3"]*bp["c1"]),FS),
            Coef(f"K2A_{tag}",DT/(bp["r1"]*bp["c2"]),FS),
            Coef(f"K2B_{tag}",DT/(bp["r2"]*bp["c2"]),FS),
            Coef(f"K2C_{tag}",DT/(bp["r3"]*bp["c2"]),FS),
            Coef(f"KENV_{tag}",DT/(renv*M.C_ENV),FS)]
BCOMMON=[Coef("KMS",RTH/M.R_MCIN),Coef("KTH",RTH/M.MC_RIN),
         Coef("KQ",DT/(M.C_MCIN*RTH),FS),Coef("KICS",MCT["ic_slope"]*RTH)]
BU=band_coefs("U",M.BPU,M.R_ENV_U); BL=band_coefs("L",M.BPL,M.R_ENV_L)

class BandFixed:
    def __init__(self,upper):
        ks=BU if upper else BL
        self.k={c.name.rsplit("_",1)[0]:c for c in ks}
        self.k.update({c.name:c for c in BCOMMON})
        self.qin=0; self.q1=0; self.q2=0; self.env=0
        self.qmc=0; self.inl=0; self.out={}
    def step(self,vsrc,q):
        c=BC; k=self.k; tab=BAND_ROM
        # band-pass
        q1s=self.q1>>SW; q2s=self.q2>>SW
        vo=c["V6"]+q1s-q2s
        if c["VOL"]<=vo<=c["VOH"]: vm=c["V6"]; vx=c["V6"]+q1s
        else:
            vo=clamp(vo,c["VOL"],c["VOH"]); vx=vo+q2s; vm=vx-q1s
        e=vsrc-(self.qin>>SW)-vx
        self.qin+=k["KIN"](e)
        self.q1+=k["K1"](vm-vo)
        self.q2+=k["K2A"](e)-k["K2B"](vx)-k["K2C"](vm-vo)
        # envelope and control
        envs=self.env>>SW
        d=-k["KENV"](envs)
        if q: d+=tab("DQ",c["VCC"]-envs)<<4
        self.env+=d
        envs=self.env>>SW
        con=clamp(c["VB2"]-clamp(envs,c["VOL_FOL"],c["VOH"]),c["VOL"],c["VOH"])
        # MC3340 chain
        s=vo-(self.qmc>>SW)
        mcin=k["KMS"](s)+c["MC_C0"]-self.inl
        g=tab("G",con); vo0=tab("VO0",con); lo=tab("LO",con)
        von=tab("VON",con); vonw=tab("VONW",con)
        h=tab("H",mcin); ib=tab("IB",mcin)
        w=tab("W",mcin-vonw)
        u=mcin-von
        ic=tab("IC",u) if u<=c["U_MAX"] else c["IC_LAST"]+k["KICS"](u-c["U_MAX"])
        heff=h+mul(c["H_LOW"]-h,w>>3,FV-3)
        x=vo0-mul(heff,g>>3,FV-3)-lo
        mco=lo+(x if x>=c["S_MAX"] else tab("S",x))
        mco=min(mco,c["MC_HI"])
        iin=ib+ic
        self.inl=iin-k["KTH"](mcin-c["MC_VB"])
        self.qmc+=k["KQ"](iin)
        self.out.update(bp=vo,env=envs,con=con,mcin=mcin,mco=mco)
        return mco

# =================================================================== expl
def _amp_coefs(tag,rf):
    ru=M.R_EXU+P.R_MC_OUT; rl=M.R_EXL+P.R_MC_OUT
    g=1/ru+1/rl+1/rf
    return [Coef(f"KU_{tag}",rf/ru),Coef(f"KL_{tag}",rf/rl),
            Coef(f"AU_{tag}",1/(ru*g)),Coef(f"AL_{tag}",1/(rl*g)),Coef(f"AF_{tag}",1/(rf*g))]
EA=_amp_coefs("N",M.R400); EAL=_amp_coefs("D",1/(1/M.R400+1/M.R423))
EK=[Coef("KQU",DT/((M.R_EXU+P.R_MC_OUT)*M.C_MCOUT),FS),
    Coef("KQL",DT/((M.R_EXL+P.R_MC_OUT)*M.C_MCOUT),FS),
    Coef("K100",DT/(M.R401*M.C100),FS),Coef("K401",R414/M.R401)]
EC={"V6":vq(P.V6),"VOL":vq(P.VOL),"VOH":vq(P.VOH)}
assert M.TW_STEPS<2**16
assert M.D4.SUB555==8      # the >>3 of the 555 output mean

class ExplFixed:
    def __init__(self,loud=False):
        self.bu=BandFixed(True); self.bl=BandFixed(False)
        self.t_prev=0; self.n61a=0; self.n69=0; self.n61b=0
        self.qu=0; self.ql=0; self.q100=0
        ks=EAL if loud else EA
        self.k={c.name.rsplit("_",1)[0]:c for c in ks}; self.k.update({c.name:c for c in EK})
        self.out={}
    def step(self,t,namp):
        c=EC; k=self.k
        if t and not self.t_prev: self.n61a=M.TW_STEPS; self.n69=M.TW_STEPS
        self.t_prev=t
        q61a=self.n61a>0; q61b=self.n61b>0
        if self.n61a: self.n61a-=1
        if self.n61b: self.n61b-=1
        if self.n69:
            self.n69-=1
            if self.n69==0: self.n61b=M.TW_STEPS
        mcou=self.bu.step(namp,q61a)
        mcol=self.bl.step(namp,q61b)
        su=mcou-(self.qu>>SW); sl=mcol-(self.ql>>SW)
        vo=c["V6"]-(k["KU"](su-c["V6"])+k["KL"](sl-c["V6"]))
        if c["VOL"]<=vo<=c["VOH"]: vm=c["V6"]
        else:
            vo=clamp(vo,c["VOL"],c["VOH"])
            vm=k["AU"](su)+k["AL"](sl)+k["AF"](vo)
        self.qu+=k["KQU"](su-vm)
        self.ql+=k["KQL"](sl-vm)
        e100=vo-(self.q100>>SW)-c["V6"]
        self.q100+=k["K100"](e100)
        i401=k["K401"](e100)
        self.out.update(q61a=q61a,q61b=q61b,expo=vo,i401=i401)
        return i401

class D4Fixed:
    """The D-4 sources in one step, as jtmonacogp_sound.v runs them: the
    noise module first (its noise amplifier output feeds the bands)."""
    def __init__(self,loud=False):
        self.noise=NoiseFixed(); self.expl=ExplFixed(loud); self.out={}
    def step(self,t,skid_on,excp):
        namp,isk=self.noise.step(skid_on,excp)
        i401=self.expl.step(t,namp)
        return i401+isk

# =================================================================== Verilog
def _sv(v,bits=F.VBITS): return f"-{bits}'sd{-v}" if v<0 else f"{bits}'sd{v}"
def _head(name):
    return ["// SPDX-License-Identifier: GPL-3.0-or-later",
            f"// GENERATED by tests/sound/d4s_fixed.py from the sound models in tests/sound;",
            f"// do not edit. Constants of {name}: signals 2^28 per volt, capacitor",
            "// states 2^44 per volt; coefficient = M / 2^S.",""]
def _consts(L,consts):
    for k,v in consts.items(): L.append(f"localparam signed [{F.VBITS-1}:0] {k} = {_sv(v)};")
def _coefs(L,coefs):
    for co in coefs:
        L.append(f"localparam signed [{F.BBITS-1}:0] {co.name}_M = {_sv(co.m,F.BBITS)};  // {co.k:.6g}")
        L.append(f"localparam [5:0] {co.name}_S = 6'd{co.s};")
def _rom(L,rom):
    assert rom.size<4096
    for t in rom.tables:
        L.append(f"localparam [11:0] T_{t['name']}_BASE = 12'd{t['base']}, T_{t['name']}_N = 12'd{t['n']};")
        L.append(f"localparam [4:0] T_{t['name']}_F = 5'd{FV-t['k']};")
        L.append(f"localparam signed [{F.VBITS-1}:0] T_{t['name']}_X0 = {_sv(t['x0'])};")
    L.append(f"localparam integer ROM_SIZE = {rom.size};")
    L.append(f"reg signed [{F.VBITS-1}:0] rom [0:ROM_SIZE-1];")
    L.append("initial begin")
    for t in rom.tables:
        L.append(f"    // {t['name']}")
        for i,v in enumerate(t["v"]): L.append(f"    rom[{t['base']+i}] = {_sv(v)};")
    L.append("end")

def write_vh(hdl):
    hdl=Path(hdl)
    L=_head("jtmonacogp_snd_noise.v"); _consts(L,NC); _coefs(L,NK)
    L.append(f"localparam [4:0] NOISE_NUM = 5'd{M.NOISE_NUM}, NOISE_DEN = 5'd{M.NOISE_DEN};")
    (hdl/"jtmonacogp_snd_noise.vh").write_text("\n".join(L)+"\n")
    L=_head("jtmonacogp_snd_band.v"); _consts(L,BC); _coefs(L,BU+BL+BCOMMON); _rom(L,BAND_ROM)
    (hdl/"jtmonacogp_snd_band.vh").write_text("\n".join(L)+"\n")
    L=_head("jtmonacogp_snd_expl.v"); _consts(L,EC); _coefs(L,EA+EAL+EK)
    L.append(f"localparam [15:0] TW_STEPS = 16'd{M.TW_STEPS};")
    (hdl/"jtmonacogp_snd_expl.vh").write_text("\n".join(L)+"\n")

def check(seconds=2.0):
    """Both models through the d4_reference scenario; the largest
    differences of each signal."""
    import d4_reference as R
    n=int(round(seconds*P.TICK_HZ))
    a=M.D4(); b=D4Fixed(); s=1.0/(1<<FV); worst={}
    keys=[("namp",lambda:b.noise.out["namp"]),("tri",lambda:b.noise.out["tri"]),
          ("o63d",lambda:b.noise.out["o63d"]),("ctl555",lambda:b.noise.out["ctl555"]),
          ("bpu",lambda:b.expl.bu.out["bp"]),("bpl",lambda:b.expl.bl.out["bp"]),
          ("envu",lambda:b.expl.bu.out["env"]),("envl",lambda:b.expl.bl.out["env"]),
          ("conu",lambda:b.expl.bu.out["con"]),("conl",lambda:b.expl.bl.out["con"]),
          ("mcou",lambda:b.expl.bu.out["mco"]),("mcol",lambda:b.expl.bl.out["mco"]),
          ("expo",lambda:b.expl.out["expo"])]
    i_sum=lambda: (a.out["i401"]+a.out["i402"]+a.out["i403"])*R414
    edges_a=edges_b=0; pa=pb=False
    for k in range(n):
        tt,sk,ex=R.inputs(k)
        a.step(tt,sk,ex); iv=b.step(tt,sk,ex)
        qa=a.out["out555"]>1; qb=b.noise.out["out555"]
        edges_a+=qa and not pa; edges_b+=qb and not pb; pa,pb=qa,qb
        if k%16==0:
            for key,f in keys:
                e=abs(a.out[key]-f()*s)
                if e>worst.get(key,(0,0))[0]: worst[key]=(e,k*P.DT)
            e=abs(i_sum()-iv*s)
            if e>worst.get("i_sum",(0,0))[0]: worst["i_sum"]=(e,k*P.DT)
    for key,(e,t) in worst.items(): print(f"{key:7s} max |float - fixed| {e:.3e} V at {t:.3f} s")
    print(f"555 rising edges: float {edges_a}, fixed {edges_b}")

if __name__=="__main__":
    if sys.argv[1]=="vh": write_vh(sys.argv[2])
    elif sys.argv[1]=="check": check(float(sys.argv[2]) if len(sys.argv)>2 else 2.0)
