#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Floating-point stepped model of sound sheet D-4/7's sound sources: the
S2688 noise and its amplifier, the explosion (two band-pass filters, two
MC3340s under 74123 envelopes, IC66 a), the skid tone (triangle oscillator,
noise and 555) and the EXTEND beep. Circuit: docs/trace/SOUND_D4_TRACE.md
(1 November check); reference netlist: spice/d4_effects.cir.

One step() per model step (480 kHz), inputs held through the step: the
explosion trigger T (IC60 a), the 555's RES (the 7432) and pad 14 EX.CP.
It returns the three currents into the mixer's 6 V virtual ground (R401,
R402, R403). The block methods are what d4_check.py drives against SPICE.

Method as d3_model.py: op-amps ideal inside their output range (virtual
ground at the + input) and limited to it, with the virtual ground let go
while limited; capacitors stepped by Euler, except the 555's timing
capacitor, whose single-RC charge and discharge use the exact factor over
eight sub-steps per step.
"""
import math
import sound_parts as P

DT=P.DT
VOL,VOH=P.VOL,P.VOH
V6=P.V6

# ---- S2688 (IC62): a 17-bit shift register, taps 14 and 17 (as the
# MM5837 it replaces), shifted at about 100 kHz on 12 V; its output is bit
# 17. Output levels on 12 V about 3.0 and 10.5 V (bench measurement of the
# MM5837 on 12 V into 22K, quoted in MAME's mm5837.h). The clock is a
# phase accumulator: NOISE_NUM/NOISE_DEN shifts per model step.
NOISE_HZ=100_000
NOISE_NUM,NOISE_DEN=5,24              # 100 kHz / 480 kHz
assert NOISE_NUM/NOISE_DEN*P.TICK_HZ==NOISE_HZ
NOISE_LO,NOISE_HI=3.0,10.5

class S2688:
    def __init__(self):
        self.reg=0x1ffff; self.ph=0
    def step(self):
        self.ph+=NOISE_NUM
        if self.ph>=NOISE_DEN:
            self.ph-=NOISE_DEN
            fb=(self.reg>>13 ^ self.reg>>16 ^ (self.reg==0))&1
            self.reg=((self.reg<<1)|fb)&0x1ffff
        return self.reg>>16&1

# ---- 74123: tw = 0.28 R C (1 + 0.7 / R[kohm]) (SN74123 data sheet, Cext
# above 1000 pF); the three one-shots have 47K and 4.7 uF.
def tw_74123(r,c): return 0.28*r*c*(1+0.7/(r/1e3))
TW_STEPS=int(round(tw_74123(47e3,4.7e-6)*P.TICK_HZ))

# ---- parts
R361,R362=150e3,51e3
BPU=dict(c_in=4.7e-6,r1=4.7e3,r2=27e3,c1=0.01e-6,c2=0.01e-6,r3=220e3)   # IC63 b
BPL=dict(c_in=4.7e-6,r1=4.7e3,r2=8.2e3,c1=0.047e-6,c2=0.047e-6,r3=220e3) # IC63 a
R_ENV_U,R_ENV_L=330e3,1e6             # R374, R375
C_ENV=10e-6
R_QPULL=330.0                         # R377, R376
VB=P.V12*3.9e3/(8.2e3+3.9e3)          # R368 / R366
# the followers' lowest output: the LM324's low limit plus its output
# resistance sinking the inverter's input current (10K from VB)
VOL_FOL=P.VOL+P.R_OPOUT*(VB-P.VOL)/(10e3+P.R_OPOUT)
R_MCIN=33e3                           # R397, R398
C_MCIN=1e-6                           # C82, C98
R_EXU,R_EXL=150e3,100e3               # R365, "R397" (IC71's)
C_MCOUT=1e-6                          # C83, C99
R400,R423=1e6,2e6
R401,C100=220e3,10e-6
# skid
R392,R393,R394,C94=51e3,100e3,6.8e3,10e-6
R385,R390,R386=100e3,68e3,10e3
C80,C81=1e-6,33e-6
R_CTL=1/(1/5e3+1/10e3)                # the 555's divider seen at CONTROL
V_CTL=P.VCC*10e3/15e3
R383,R384,C89=47e3,47e3,4700e-12
V555_HI,V555_LO=3.3,0.05              # NE555 OUTPUT on 5 V (typical)
R_DIS=10.0
R405,R404,R403,C101=10e3,10e3,220e3,10e-6
# EXTEND CP
VEX_HI,VEX_LO=5.0,0.2
C_EX,R402=2.2e-6,220e3

MC=P.MC3340()
MC_VB,MC_RIN=P.mc3340_input_line(MC)
RTH_MC=1/(1/R_MCIN+1/MC_RIN)
# D30/D31 with R377/R376 in series: current against the voltage across both
T_DQ=P.Table.build(0.0,1/64,385,lambda v:P.diode_i_series(v,R_QPULL))   # 0..6 V

class BandPass:
    """Multiple-feedback band-pass around an LM324 (IC63 a or b): C_in and
    r1 into node X, r2 from X to GND, c1 from X to the - input, c2 from X to
    the output, r3 from the - input to the output; + at 6 V."""
    def __init__(self,p):
        self.p=p; self.qin=0.0; self.q1=0.0; self.q2=0.0   # C_in, X - pin, X - out
    def step(self,vsrc):
        p=self.p
        vo=V6+self.q1-self.q2
        if VOL<=vo<=VOH: vm=V6; vx=V6+self.q1
        else:
            vo=min(max(vo,VOL),VOH); vx=vo+self.q2; vm=vx-self.q1
        e=vsrc-self.qin-vx
        i_in=e/p["r1"]
        i1=(vm-vo)/p["r3"]
        i2=i_in-vx/p["r2"]-i1
        self.qin+=i_in*DT/p["c_in"]
        self.q1+=i1*DT/p["c1"]
        self.q2+=i2*DT/p["c2"]
        return vo

class MCChain:
    """C_MCIN and R_MCIN into an MC3340's IN (its linear part plus the rest
    of its table current from the previous step, as on D-3); its output
    through R_MC_OUT, C_MCOUT and r_out into IC66 a's - input."""
    def __init__(self,r_out):
        self.r_out=r_out+P.R_MC_OUT
        self.qin=0.0; self.qout=0.0; self.inl=0.0
    def mc(self,vsrc,con):
        s=vsrc-self.qin
        mcin=(s/R_MCIN+MC_VB/MC_RIN-self.inl)*RTH_MC
        mco,iin=MC(mcin,con)
        self.inl=iin-(mcin-MC_VB)/MC_RIN
        self.qin+=iin*DT/C_MCIN
        return mcin,mco

class D4:
    def __init__(self,dip_loud=False):
        self.noise=S2688()
        self.q79=0.0; self.namp=V6
        self.bpu=BandPass(BPU); self.bpl=BandPass(BPL)
        self.t_prev=0; self.n61a=0; self.n69=0; self.n61b=0
        self.envu=0.0; self.envl=0.0
        self.chu=MCChain(R_EXU); self.chl=MCChain(R_EXL)
        self.rf=1/(1/R400+1/R423) if dip_loud else R400
        self.q100=0.0
        self.c94=0.0; self.tri_hi=True
        self.q80=0.0; self.q81=0.0
        self.c89=0.0; self.q555=False; self.q101=0.0
        self.qex=0.0
        self.out={}

    # -- blocks
    def noise_amp(self,vn):
        """IC63 c: C79, R361 into the 6 V virtual ground, R362. Its output
        slews at the LM324's rate after each S2688 edge (a 2.5 V step takes
        about 5 us); while it slews or is limited, the - input leaves 6 V."""
        s=vn-self.q79
        vt=V6-(s-V6)*R362/R361
        vo=self.namp+min(max(vt-self.namp,-P.SLEW_TICK),P.SLEW_TICK)
        vo=min(max(vo,VOL),VOH)
        vm=V6 if vo==vt else (s*R362+vo*R361)/(R361+R362)
        self.namp=vo
        self.q79+=(s-vm)/R361*DT/1e-6
        return vo

    def oneshots(self,t):
        """IC61 a and IC69 a fire on T's rising edge, IC61 b as IC69's Q
        falls; each Q stays high for TW_STEPS steps (retriggerable)."""
        if t and not self.t_prev: self.n61a=TW_STEPS; self.n69=TW_STEPS
        self.t_prev=t
        q61a=self.n61a>0; q61b=self.n61b>0
        if self.n61a: self.n61a-=1
        if self.n61b: self.n61b-=1
        if self.n69:
            self.n69-=1
            if self.n69==0: self.n61b=TW_STEPS
        return q61a,q61b

    @staticmethod
    def _env(v,q,r):
        i=-v/r
        if q: i+=T_DQ(P.VCC-v)
        return v+i*DT/C_ENV

    def envelopes(self,q61a,q61b):
        """D30/D31 into C77/C78 (R374, R375); followers IC66 d, IC64 d;
        inverters IC66 c, IC64 c about VB. Returns the MC3340 controls."""
        self.envu=self._env(self.envu,q61a,R_ENV_U)
        self.envl=self._env(self.envl,q61b,R_ENV_L)
        cu=2*VB-min(max(self.envu,VOL_FOL),VOH)
        cl=2*VB-min(max(self.envl,VOL_FOL),VOH)
        return min(max(cu,VOL),VOH),min(max(cl,VOL),VOH)

    def amp_a(self,mcou,mcol):
        """IC66 a sums both MC3340 outputs (through C83/R365, C99/100K);
        C100 and R401 into the mixer. Returns (IC66 a out, R401 current)."""
        su=mcou-self.chu.qout; sl=mcol-self.chl.qout
        ru,rl,rf=self.chu.r_out,self.chl.r_out,self.rf
        vo=V6-rf*((su-V6)/ru+(sl-V6)/rl)
        if VOL<=vo<=VOH: vm=V6
        else:
            vo=min(max(vo,VOL),VOH)
            vm=(su/ru+sl/rl+vo/rf)/(1/ru+1/rl+1/rf)
        self.chu.qout+=(su-vm)/ru*DT/C_MCOUT
        self.chl.qout+=(sl-vm)/rl*DT/C_MCOUT
        i401=(vo-self.q100-V6)/R401
        self.q100+=i401*DT/C100
        return vo,i401

    # IC64 b's output pin: its limited internal level through the output
    # resistance, loaded by R394 (to C94) and R393 + R392 (to 6 V). Seen
    # from C94: a Thevenin source TRI_VTH(level) behind R394 + TRI_RTH.
    TRI_RS=R392+R393
    TRI_RTH=P.R_OPOUT*TRI_RS/(P.R_OPOUT+TRI_RS)
    @classmethod
    def tri_vth(cls,vo): return (vo*cls.TRI_RS+V6*P.R_OPOUT)/(cls.TRI_RS+P.R_OPOUT)
    @classmethod
    def tri_switch(cls,vo):
        """The C94 voltage at which the + input (R392/R393 from the loaded
        output pin) equals C94: where IC64 b switches."""
        k=R392/cls.TRI_RS; g=cls.TRI_RTH/(R394+cls.TRI_RTH); vth=cls.tri_vth(vo)
        return (V6*(1-k)+k*vth*(1-g))/(1-k*g)

    def triangle(self):
        """IC64 b relaxation oscillator (R392/R393 hysteresis, R394 and C94),
        IC64 a follower (its feedback is at its pin, so it follows C94).
        The comparator's output pin drops under its load (as on D-3); that
        narrows the hysteresis and is worth 0.4 % of the period against
        SPICE. Returns the follower's output."""
        vo=VOH if self.tri_hi else VOL
        self.c94+=(self.tri_vth(vo)-self.c94)/(R394+self.TRI_RTH)*DT/C94
        vs=self.tri_switch(vo)
        if self.tri_hi and self.c94>vs: self.tri_hi=False
        elif not self.tri_hi and self.c94<vs: self.tri_hi=True
        return min(max(self.c94,VOL),VOH)

    def skid_mod(self,vn,tri):
        """IC63 d: noise through C80/R385 and the triangle through R390 into
        R386; its output through C81 into the 555's CONTROL. Returns
        (IC63 d out, CONTROL)."""
        s=vn-self.q80
        i385=(s-V6)/R385; i390=(tri-V6)/R390
        vo=min(max(V6-R386*(i385+i390),VOL),VOH)
        self.q80+=i385*DT/C80
        i81=(vo-self.q81-V_CTL)/(R_CTL+P.R_OPOUT)
        ctl=V_CTL+i81*R_CTL
        self.q81+=i81*DT/C81
        return vo,ctl

    # The 555 is stepped SUB555 times per model step. Deciding at a step's
    # end only, each switch came up to a step late: at a fixed CONTROL of
    # 3.33 V it ran 0.67 % below the exact period, and with the noise on
    # CONTROL 1.5 % below a 16 times finer step in the test scenario. With
    # 8 sub-steps: 0.11 % at the fixed CONTROL.
    SUB555=8
    K_CH=1-math.exp(-DT/SUB555/((R383+R384)*C89))
    K_DIS=1-math.exp(-DT/SUB555/((R384+R_DIS)*C89))
    V_DIS=P.VCC*R_DIS/(R383+R_DIS)
    def timer(self,run,ctl):
        """The 555: RES low resets it; C89 charges through R383 + R384 while
        OUTPUT is high, discharges through R384 into DISCHARGE while low;
        the threshold (CONTROL) and trigger (half of it) comparators,
        decided after each sub-step. OUTPUT, for the step, is the mean of
        its sub-steps. Returns (OUTPUT, R403 current)."""
        nhi=0
        for _ in range(self.SUB555):
            if not run: self.q555=False
            nhi+=self.q555
            if self.q555: self.c89+=(P.VCC-self.c89)*self.K_CH
            else: self.c89+=(self.V_DIS-self.c89)*self.K_DIS
            if run:
                if self.c89>=ctl: self.q555=False
                elif self.c89<=ctl*0.5: self.q555=True
        out=V555_LO+(V555_HI-V555_LO)*nhi/self.SUB555
        i403=(out*R404/(R404+R405)-self.q101-V6)/(R405*R404/(R404+R405)+R403)
        self.q101+=i403*DT/C101
        return out,i403

    def extend(self,excp):
        v=VEX_HI if excp else VEX_LO
        i402=(v-self.qex-V6)/R402
        self.qex+=i402*DT/C_EX
        return i402

    def step(self,t,skid_on,excp,noise_bit=None):
        """t: IC60 a (explosion trigger), skid_on: the 7432 output (555 RES),
        excp: pad 14. noise_bit overrides the S2688 (tests). Returns
        (i401, i402, i403) in amperes."""
        nb=self.noise.step()
        if noise_bit is not None: nb=noise_bit
        vn=NOISE_HI if nb else NOISE_LO
        namp=self.noise_amp(vn)
        bpu=self.bpu.step(namp); bpl=self.bpl.step(namp)
        q61a,q61b=self.oneshots(t)
        conu,conl=self.envelopes(q61a,q61b)
        mciu,mcou=self.chu.mc(bpu,conu)
        mcil,mcol=self.chl.mc(bpl,conl)
        expo,i401=self.amp_a(mcou,mcol)
        tri=self.triangle()
        o63d,ctl=self.skid_mod(vn,tri)
        out555,i403=self.timer(skid_on,ctl)
        i402=self.extend(excp)
        self.out.update(noise=vn,namp=namp,bpu=bpu,bpl=bpl,q61a=q61a,q61b=q61b,
                        envu=self.envu,envl=self.envl,conu=conu,conl=conl,mciu=mciu,
                        mcil=mcil,mcou=mcou,mcol=mcol,expo=expo,c94=self.c94,tri=tri,
                        o63d=o63d,ctl555=ctl,thtr=self.c89,out555=out555,
                        i401=i401,i402=i402,i403=i403)
        return i401,i402,i403
