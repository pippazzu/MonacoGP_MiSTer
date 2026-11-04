# SPDX-License-Identifier: GPL-3.0-or-later
"""Sound sheets D-6/7 and D-7/7 (the other cars) as a stepped model.

Floating-point model of the circuit in docs/trace/SOUND_D6_TRACE.md and
docs/trace/SOUND_D7_TRACE.md; spice/d67_cars.cir is the pin-wired reference
it is checked against (d67_check.py). Same step as the other sheets
(sound_parts.DT). Equations: docs/SOUND_LOGIC.md.

Per step, in this order:
  decoder   S-ACCE B, C, D (IC36 74145, IC38, IC47) set the feed node: R125
            1K from 12 V against R169 1.2K (codes 0-5) or R124 1.5K (6, 7),
            and the two ramps' 33K inputs.
  ramps     TL081 integrators IC14 / IC28 (33K, 11 uF), + at R151/R127 with
            C30; each is reset by TR12 / TR13 (table, characterize_d7_reset.py)
            while its 74123 output is high. After a reset the integrator
            stays at its upper limit (12 V, fitted to the board recordings:
            TL_HI) until its capacitor has recharged
            through 33K; then it ramps down at (feed - 6 V) / 33K / 11 uF.
  IC15      u = 6.857 V * 1.47 - 0.47 * ramp (for both cars).
  triggers  IC29 (two LM339 stages with 2.2K / 100K hysteresis) on u
            against 6 V; IC55 / IC46 gates with pad C (/F-SOUND) and IC56
            (codes 0-3 block); 74123 one-shots IC59 a/b (6.59 ms) and IC58
            (0.628 s), retriggerable, counted in steps.
  shapers   IC17 / IC16 amplifiers of u; IC31 / IC30 comparators choose the
            larger of each pair through the 4016s (IC24, IC23); the IC18 /
            IC32 followers drive the four D-7 MC3340s' CONTROL.
  CAR CON   IC18 c / d: 2 * reference - front CONTROL (car 1: R192 5.1K /
            R191 5.6K; car 2: R189 5.6K / R190).
  banks     D-6: three cells as on D-3 (comparators on D-6's half-rail
            R82 / R83 with C22 / C23), cell 1 through 22 uF into the bank
            MC3340's CONTROL with its bias divider and the pin's own source
            (sound_parts.MC_CTL_V0 / MC_CTL_R), cells 2 and 3 through MA150s
            to the bus and 10 uF into IN, as on D-3.
  D-7 MC3340s  each bank's output through 2.2 uF into two MC3340 inputs
            (front, back); outputs through 2.2 uF, the IC25 4016 (open while
            the car's reset pulse is high, through TR11 / TR10), the 10K /
            10K bias, 2.2 uF and R207 / R204 10K (front, to IC32 b, R426 33K)
            or R220 / R217 51K (back, to D-2's IC40 pin 6, a 6 V virtual
            ground). IC32 b's output through C15 2.2 uF and R409 82K into the
            D-4 mixer's 6 V virtual ground.
Simplifications against the reference: href (R208 / R209 with C33) is taken
as 6 V from the first step; the comparators switch at once (the LM339's
0.3 us and the 4016 controls' ramp are left out); op-amps slew at once
except in the cells (as on D-3). Each D-7 MC3340's IN current beyond its
linear part moves a sixteenth of the way to its new value each step (taken
whole from the previous step, the input's knee made the node flip between
steps).
"""
import json
import d3_model as D3M
import sound_parts as P

DT=P.DT
V12=P.V12
R_OC=P.R_OC
VOL,VOH=P.VOL,P.VOH
R_OP=P.R_OPOUT

# ---- decoder and feed
R125=1e3
R169=1.2e3
R124=1.5e3
R_IN=33e3                     # R126, R150
def feed_source(n):
    """Thevenin (volts, ohms) of the feed node without the ramp inputs."""
    rlo=(R124 if n>=6 else R169)+R_OC
    return V12*rlo/(R125+rlo),R125*rlo/(R125+rlo)
FEED=[feed_source(n) for n in range(8)]

# ---- ramps
C_RAMP=11e-6                  # 22 uF back to back
TL_LO=1.5                     # TL081 on 12 V (opamps.lib)
# The ramps' upper limit: a setting fitted to the maintainer's board recordings of the
# passing cars (3 November 2026), not the TL081's typical V12 - 1.5 V. At
# 10.5 V a reset parks u exactly at the selectors' crossing (the loudest,
# highest-pitched point) for the 0.6 s windup: a steady full-level tone. On
# the board each pass rises about 4 % in pitch to that point and then falls,
# which needs the ramp to start at about 12 V (docs/SOUND_LOGIC.md).
TL_HI=V12
C30=2.2e-6
R_REF14=5e3                   # R151 / R127 10K each
REF130=V12*6.8e3/(5.1e3+6.8e3)
K15=47e3/100e3                # R133 / R132 (R129 / R128)
R132=100e3
_t=json.loads((P.HERE/"data/d7_reset_tr.json").read_text())
T_TR=P.Table(_t["grid"][0],_t["grid"][1],_t["i"])
OS59=round(6.5912e-3*P.TICK_HZ)   # C75 / C85 2.2u, R259 / R371 10K
OS58=round(0.62831*P.TICK_HZ)     # C84-like 47u, R320 47K

# ---- LM339 stages with 2.2K pull-up and 2.2K / 100K hysteresis
R_PU=2.2e3
R_HA,R_HB=2.2e3,100e3         # input resistor, feedback resistor
def lm339_low(x=6.0):
    """Output level while sinking the pull-up and the feedback path to x
    (the smooth LM339 of the reference, fully on)."""
    import math
    def sink(v): return 16e-3*math.tanh(0.02*math.log1p(math.exp(v/0.02))/0.1)
    lo,hi=0.0,1.0
    for _ in range(80):
        m=0.5*(lo+hi)
        if (V12-m)/R_PU+(x-m)/(R_HA+R_HB)>sink(m): lo=m
        else: hi=m
    return 0.5*(lo+hi)
V339_LO=lm339_low()
def hyst_plus(x,hi):
    """+ input of a stage fed from x through 2.2K, 100K back from its
    output (high: the pull-up loaded by that path)."""
    out=(V12/R_PU+x/(R_HA+R_HB))/(1/R_PU+1/(R_HA+R_HB)) if hi else V339_LO
    return (x*R_HB+out*R_HA)/(R_HA+R_HB)
REF6=V12*0.5                  # ref33 (R157 / R156 3.3K), r152 (R152 / R153 10K)

# ---- shaper references
REFA=V12*5.1e3/(10e3+5.1e3)   # R161 / R157
K_P17=6.8e3/(3.3e3+6.8e3)     # R159 / R160 (R135 / R136)
REFC=V12*3.3e3/(5.6e3+330+3.3e3)   # R140, R144, R119
def refb(u1,u2):
    """R147 6.8K / R122 2.7K, loaded by R148 / R123 51K to IC17 a/d's -
    inputs (at their + inputs)."""
    g=1/6.8e3+1/2.7e3+2/51e3
    return (V12/6.8e3+(u1+u2)*K_P17/51e3)/g
def refd(u1,u2):
    """R141 5.1K / R116 1K, loaded by R136 / R117 51K + R143 / R118 51K from u."""
    g=1/5.1e3+1/1e3+2/102e3
    return (V12/5.1e3+(u1+u2)/102e3)/g

# ---- CAR CON references
REF192=V12*5.6e3/(5.1e3+5.6e3)
def ref189(r190): return V12*r190/(5.6e3+r190)
R190_BOARD=6.8e3              # board photo (D-7 trace); 68K on the schematic
# IC18 c / d at the top: the cells' load as on D-3 plus R198 / R187 100K to
# the - input (half-way to the front CONTROL, taken at 6 V)
G_CV=sum(1/102e3+0.5/rin for rin,_,_ in D3M.CELLS)+0.5/100e3
def cv_max(): return (VOH+R_OP*3.0/100e3)/(1+R_OP*G_CV)
CV_MAX=cv_max()

# ---- D-6 banks
R6_R=500.0                    # R82 / R83 1K
R6_C=200e-6                   # C22 + C23
C_CON=22e-6                   # C26 (NO1), C24 (NO2)
BANK_BIAS={1:(10e3,330.0),2:(10e3,3.3e3)}   # R108/R109, R80/R81

# ---- D-7 MC3340s and outputs
MC=D3M.MC
MC_VB,MC_RIN=D3M.MC_VB,D3M.MC_RIN
C_IN=2.2e-6                   # C37, C36, C45 and NO2-back's
C_A=2.2e-6                    # C35, C38, C43 and NO2-back's (MC side of IC25)
C_B=2.2e-6                    # C39, C41, C38(b), C40
R_BIAS=5e3                    # R202 / R205 10K each (and the others)
R_FRONT=10e3                  # R207, R204
R_BACK=51e3                   # R220, R217
R426=33e3
C15=2.2e-6
R409=82e3
R_SRC_ON=P.R_MC_OUT+P.R_4016
INL_ALPHA=1/16                # D-7 inputs' nonlinear current: relaxation per step

class Bank:
    """One D-6 bank: cells, CONTROL node, bus and its MC3340 (unloaded
    output), driving two D-7 MC3340 inputs."""
    def __init__(self,no):
        self.d3=D3M.D3()           # cells, bus and IN state (q64, inl)
        rbt,rbb=BANK_BIAS[no]
        g=1/rbt+1/rbb+1/P.MC_CTL_R
        self.con_g=g
        self.con_i0=V12/rbt+P.MC_CTL_V0/P.MC_CTL_R   # con node: i = con*g - i0
        self.qcon=0.0              # cell-1 side minus CONTROL
    def step(self,cv,r6):
        o1,o2,o3=self.d3.cells_step(cv,r6)
        con=o1-self.qcon
        self.qcon+=(con*self.con_g-self.con_i0)*DT/C_CON
        bus,mcin,mco=self.d3.busmc(o2,o3,max(con,0.0))
        self.o=(o1,o2,o3); self.con=con; self.bus=bus; self.mcin=mcin; self.mco=mco
        return mco

class Path:
    """One D-7 MC3340 with its input capacitor (from the bank's output node)
    and its output network up to the summing resistor."""
    def __init__(self,rout):
        self.qin=0.0               # input capacitor: bank side minus IN
        self.inl=0.0               # IN current beyond its linear part, relaxed (INL_ALPHA)
        self.qa=0.0                # MC side minus switch side
        self.qb=0.0                # bias node side minus resistor side
        self.rout=rout
    def a_lin(self):
        """IN current = node / MC_RIN + this (the linear part with the
        previous step's rest)."""
        return (-self.qin-MC_VB)/MC_RIN+self.inl
    def mc(self,node,con):
        mcin=node-self.qin
        mco,iin=MC(mcin,con)
        # the rest of the IN current moves a sixteenth of the way each step:
        # taken whole from the previous step, the input's knee (up to
        # 22 mS against the bank's 220 ohm, both inputs) makes the node
        # flip between steps
        self.inl+=(iin-(mcin-MC_VB)/MC_RIN-self.inl)*INL_ALPHA
        self.qin+=iin*DT/C_IN
        self.mcin=mcin; self.mco=mco
        return mco
    def out(self,mco,on,vsum):
        """Network from the MC3340 output into a virtual ground at vsum;
        returns the current into it."""
        gs=1/R_SRC_ON if on else 0.0
        g=gs+1/R_BIAS+1/self.rout
        b=(gs*(mco-self.qa)+P.V6/R_BIAS+(self.qb+vsum)/self.rout)/g
        i_s=gs*(mco-self.qa-b)
        i_o=(b-self.qb-vsum)/self.rout
        self.qa+=i_s*DT/C_A
        self.qb+=i_o*DT/C_B
        self.b=b; self.pin=mco-P.R_MC_OUT*i_s
        return i_o

class Hyst:
    """An LM339 stage with 2.2K / 100K hysteresis: high while its + input
    (from x) is above its - input (ref)."""
    def __init__(self): self.hi=False
    def step(self,x,ref):
        self.hi=hyst_plus(x,self.hi)>ref
        return self.hi

class D67:
    def __init__(self,r190=R190_BOARD):
        self.ref189=ref189(r190)
        self.ref14=0.0             # C30
        self.r6=V12*0.5            # C22 / C23 split the supply at power-on
        self.q=[0.0,0.0]           # ramp capacitors: - input side minus output
        self.vm=[0.0,0.0]          # integrators' - inputs, previous step
        self.c29=[Hyst(),Hyst()]   # IC29 first stages (u1, u2)
        self.sel=[Hyst() for _ in range(4)]   # IC31 a, IC30 a, IC31 c, IC30 c
        self.os59=[0,0]; self.os58=0
        self.nor_a=False; self.nor_c=False
        self.banks=[Bank(1),Bank(2)]
        self.paths=[Path(R_FRONT),Path(R_BACK),Path(R_FRONT),Path(R_BACK)]
        self.q15=0.0
        # the other blocks' outputs of the previous step (power-on: 0 V,
        # no reset pulse)
        self.prev=dict(m1=0.0,m2=0.0,con20=0.0,con19=0.0,con34=0.0,con33=0.0,
                       cv1=0.0,cv2=0.0,q59a=False,q59b=False)
        self.out={}

    # -- ramps
    def ramp(self,k,feed,tr_on):
        """One integrator. Returns its output pin."""
        q=self.q[k]; ref=self.ref14
        itr=T_TR(self.vm[k]) if tr_on else 0.0
        # saturated at a limit L: pin = L - R_OP*(i_load - i_c), vm = pin + q,
        # i_c = (feed - vm)/R_IN - itr, i_load = (pin - REF130)/R132; linear
        # in pin
        def sat(L):
            # pin*(1 + R_OP/R132 + R_OP/R_IN) = L + R_OP*REF130/R132 + R_OP*((feed - q)/R_IN - itr)
            pin=(L+R_OP*REF130/R132+R_OP*((feed-q)/R_IN-itr))/(1+R_OP/R132+R_OP/R_IN)
            return pin,pin+q
        pin,vm=sat(TL_HI)
        if vm>ref:
            pin,vm=sat(TL_LO)
            if vm<ref:
                vm=ref; pin=ref-q
        ic=(feed-vm)/R_IN-itr
        self.q[k]=q+ic*DT/C_RAMP
        self.vm[k]=vm
        return pin

    def control(self,acc,fs_low):
        """D-7's decoder, ramps, triggers, shapers, selectors and CAR CON."""
        n=acc>>1&7
        # feed, with the ramps' inputs at the previous step's levels
        vth,rth=FEED[n]
        feed=(vth/rth+(self.vm[0]+self.vm[1])/R_IN)/(1/rth+2/R_IN)
        r14=self.ramp(0,feed,self.os59[0]>0)
        r28=self.ramp(1,feed,self.os59[1]>0)
        self.ref14+=(V12*0.5-self.ref14)/R_REF14*DT/C30
        u1=min(max(REF130+(REF130-r14)*K15,VOL),VOH)
        u2=min(max(REF130+(REF130-r28)*K15,VOL),VOH)
        # triggers: c292 / c2913 are high while u is below its threshold
        c292=not self.c29[0].step(u1,REF6)
        c2913=not self.c29[1].step(u2,REF6)
        n56=n<4
        nor_a=fs_low and not c292 and not n56
        nor_b=fs_low and not c2913 and not n56
        nor_c=nor_b and c292 and not self.os58>0
        if self.os59[0]>0: self.os59[0]-=1
        if self.os59[1]>0: self.os59[1]-=1
        if self.os58>0: self.os58-=1
        if nor_a and not self.nor_a: self.os59[0]=OS59; self.os58=OS58
        if nor_c and not self.nor_c: self.os59[1]=OS59
        self.nor_a,self.nor_c=nor_a,nor_c
        # shapers
        rb=refb(u1,u2); rd=refd(u1,u2)
        def lim(x): return min(max(x,VOL),VOH)
        s=[]
        for u in (u1,u2):
            sa=lim(REFA+(REFA-u)*5.1e3/10e3)       # IC17 b / c
            sb=lim(2*u*K_P17-rb)                   # IC17 a / d
            sc=lim(2*REFC-u)                       # IC16 b / c
            sd=lim(0.5*(u+rd))                     # IC16 a / d followers
            s.append((sa,sb,sc,sd))
        cons=[]
        for k,(x,y) in enumerate(((s[0][0],s[0][1]),(s[0][2],s[0][3]),
                                  (s[1][0],s[1][1]),(s[1][2],s[1][3]))):
            cons.append(lim(x if self.sel[k].step(x,y) else y))
        con20,con19,con34,con33=cons
        return dict(feed=feed,r14=r14,r28=r28,u1=u1,u2=u2,c292=c292,c2913=c2913,
                    q59a=self.os59[0]>0,q59b=self.os59[1]>0,q58=self.os58>0,
                    con20=con20,con19=con19,con34=con34,con33=con33,
                    cv1=min(max(2*REF192-con20,VOL),CV_MAX),
                    cv2=min(max(2*self.ref189-con34,VOL),CV_MAX),ref14=self.ref14)

    def step(self,acc,fs_low):
        """acc: S-ACCE code (bit 0 = A); fs_low: pad C (/F-SOUND) was low
        during this step. Returns the R409 current (A).
        The blocks work side by side, as the Verilog's modules do: the D-7
        MC3340s take the banks' outputs and the control voltages of the
        previous step, the banks take CAR CON of the previous step (each
        one step, about 2 us, late)."""
        pv=self.prev; p=self.paths; b1,b2=self.banks
        # D-7 MC3340s: each bank's output into two inputs
        snds=[]
        for mco,pf,pb,cf,cb in ((pv["m1"],p[0],p[1],pv["con20"],pv["con19"]),
                                (pv["m2"],p[2],p[3],pv["con34"],pv["con33"])):
            a=pf.a_lin()+pb.a_lin()
            node=(mco-P.R_MC_OUT*a)/(1+2*P.R_MC_OUT/MC_RIN)
            snds.append(node)
            pf.mc(node,cf); pb.mc(node,cb)
        on1=not pv["q59a"]; on2=not pv["q59b"]
        i_f=p[0].out(p[0].mco,on1,P.V6)+p[2].out(p[2].mco,on2,P.V6)
        i_b=p[1].out(p[1].mco,on1,P.V6)+p[3].out(p[3].mco,on2,P.V6)
        front=P.V6-R426*i_f
        if front>VOH or front<VOL:
            # clipped: the summing node leaves 6 V (the branch currents were
            # taken at 6 V; the error is one step's)
            front=min(max(front,VOL),VOH)
        i_mf=(front-self.q15-P.V6)/R409
        self.q15+=i_mf*DT/C15
        # D-6 banks; D-6's half-rail with the six comparators' 51K loads
        m1=b1.step(pv["cv1"],self.r6)
        m2=b2.step(pv["cv2"],self.r6)
        i_r6=sum((self.r6-vp)/51e3 for b in self.banks for vp in b.d3.vplus)
        self.r6+=((V12-self.r6)/1e3-self.r6/1e3-i_r6)*DT/R6_C
        # D-7 control
        c=self.control(acc,fs_low)
        self.prev=dict(c,m1=m1,m2=m2)
        self.out.update(c,snd1=snds[0],snd2=snds[1],con1=b1.con,con2=b2.con,
                        o1=b1.o[0],o2=b1.o[1],o3=b1.o[2],o1b=b2.o[0],front=front,
                        i_mf=i_mf,i_mb=i_b,r6=self.r6,
                        m20o=p[0].pin,m19o=p[1].pin,m34o=p[2].pin,m33o=p[3].pin,
                        b1f=p[0].b,b1b=p[1].b,b2f=p[2].b,b2b=p[3].b)
        return i_mf
