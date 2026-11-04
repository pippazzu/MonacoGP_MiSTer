# SPDX-License-Identifier: GPL-3.0-or-later
"""Sound sheet D-1/7 (SLIP ZONE SOUND) as a stepped model.

Floating-point model of the circuit in docs/trace/SOUND_D1_TRACE.md (its
31 October review); spice/d1_slip.cir is the pin-wired reference it is
checked against (d1_check.py). Same step as the other sheets
(sound_parts.DT). Equations: docs/SOUND_LOGIC.md.

Per step, in this order:
  oscillator  IC53 c, a relaxation oscillator: C63 22 uF charged and
              discharged through R309 10K from its output, the + input
              from VR7's wiper (a Thevenin source) through R351 1K with
              R307 100K back from the output. The output node slews as
              opamps.lib's LM324 (0.5 V/us, tanh of the input difference)
              and is held 0.25 V beyond the output's limits (with the
              step's regeneration taken exactly, slew_table). IC53 d
              follows C63 and drives the transistor's base through R308.
  band-pass   the S2688's output through C68 1 uF, R345 10K (C105 0.1 uF
              to ground) and R350 10K into node A; IC53 a's multiple-
              feedback band-pass (C71, C70 0.022 uF, R348 220K); R349 and
              the 2SC458 shunt node A (a cubic in node A's voltage per
              follower level, characterize_d1_tr.py). IC53 a has a finite
              gain-bandwidth (1.2 MHz, opamps.lib): its output is the
              integral of the input difference, stepped by backward Euler
              (the capacitors fix the input difference for a given output).
              C70 is stepped first and C71 from C70's new charge
              (semi-implicit Euler), which keeps the filter's damping.
  gain        C69 2.2 uF, R347 33K into IC53 b (R346 100K), ideal inside
              its output limits.
  output      the 4016 (IC54, 300 ohm on) closes while pad J (SLIP ZONE)
              is low (the 7416 releases R352's pull-up); its output node
              has R353 / R354 51K to 12 V and ground and C73 2.2 uF, R412
              51K into the D-4 mixer's 6 V virtual ground.
VR7's setting is a parameter (a7: the wiper's place from the ground end);
its fitted value is VR7_A7 (docs/SOUND_LOGIC.md, D-1).
"""
import json
import math
import sound_parts as P
import d4_model as D4M

DT=P.DT
V12=P.V12
V6=P.V6
VOL,VOH=P.VOL,P.VOH

# ---- parts
C68,R345,C105,R350=1e-6,10e3,0.1e-6,10e3
C70,C71,R348=0.022e-6,0.022e-6,220e3
C69,R347,R346=2.2e-6,33e3,100e3
R4016=P.R_4016
R353,R354,C73,R412=51e3,51e3,2.2e-6,51e3
VR7,R351,R307,R309,C63=20e3,1e3,100e3,10e3,22e-6
VR7_A7=0.167          # VR7 wiper: the trace's "2.2 V / 1.8 V" notes (C63's swing)

# LM324 (opamps.lib): unity-gain bandwidth, slew
WT=2*math.pi*1.2e6
K_OA=WT*DT                     # backward-Euler gain of IC53 a per step
SLEW_TICK=P.SLEW_TICK
GM_SL=1e-3/(0.5e6*1e-3/(2*math.pi*1.2e6))   # gm / islew (opamps.lib), 1/V


def clamp(x): return min(max(x,VOL),VOH)

# ---- the transistor shunt: c0..c3 per follower level
_t=json.loads((P.HERE/"data/d1_tr.json").read_text())
VA_LIM=_t["va_lim"]
T_TR=[P.Table(_t["grid"][0],_t["grid"][1],_t[f"c{j}"]) for j in range(4)]

def tr_current(va,vf):
    """Current from node A into R349 and the transistor (A): the cubic within
    +-VA_LIM, continued with its linear term beyond (node A leaves that range
    only while the circuit powers up)."""
    c0,c1,c2,c3=(t(vf) for t in T_TR)
    x=min(max(va,-VA_LIM),VA_LIM)
    return c0+x*(c1+x*(c2+x*c3))+c1*(va-x)

def vr7(a7):
    """VR7's wiper as a Thevenin source (volts, ohms)."""
    return V12*a7,VR7*a7*(1-a7)

def slew_table(a7):
    """IC53 c's internal-node step against its input difference: the
    macro-model's SLEW_TICK*tanh(gm*d/islew). Its linear part is scaled by
    (e^a - 1)/a, a = wt*DT*(the + input's share of the output): while the
    output moves inside its limits, the R307 feedback makes the input
    difference grow by e^a in a step, which a step-start value (Euler)
    would take as 1 + a; with this factor the switching takes as long as in
    the reference (without it the oscillator ran 0.17 % slow)."""
    rw=vr7(a7)[1]+R351
    a=WT*DT*rw/(R307+rw)
    g=(math.exp(a)-1)/a
    return P.Table.build(-0.5,1/128,129,lambda d:SLEW_TICK*math.tanh(GM_SL*g*d))

class D1:
    def __init__(self,a7=VR7_A7):
        self.w7,rw=vr7(a7)
        self.rw=rw+R351
        self.t_slew=slew_table(a7)
        self.v63=0.0; self.n8=0.0; self.o8=VOL
        self.q68=0.0; self.v105=0.0; self.q70=0.0; self.q71=0.0; self.vo=0.0
        self.q69=0.0; self.q73=0.0
        self.out={}

    def plus10(self,o8):
        """IC53 c's + input with the output at o8."""
        return (self.w7*R307+o8*self.rw)/(R307+self.rw)

    def oscillator(self):
        vf=clamp(self.v63)                       # IC53 d
        o8=self.o8
        d=self.plus10(o8)-self.v63
        self.v63+=(o8-self.v63)/R309*DT/C63
        self.n8+=self.t_slew(d)
        self.n8=min(max(self.n8,VOL-0.25),VOH+0.25)
        self.o8=clamp(self.n8)
        return vf

    def bandpass(self,vn,vf):
        """vn: the S2688's output (V); returns IC53 a's output and node A."""
        vo=(self.vo+K_OA*(V6-self.q70+self.q71))/(1+K_OA)
        vo=min(max(vo,self.vo-SLEW_TICK),self.vo+SLEW_TICK)
        vo=clamp(vo)
        va=vo+self.q70
        itr=tr_current(va,vf)
        i345=(vn-self.q68-self.v105)/R345
        i350=(self.v105-va)/R350
        self.q68+=i345*DT/C68
        self.v105+=(i345-i350)*DT/C105
        i3=(self.q70-self.q71)/R348
        self.q70+=(i350-itr-i3)*DT/C70
        self.q71+=(self.q70-self.q71)/R348*DT/C71
        self.vo=vo
        return vo,va,itr

    def gain(self,o1):
        n69=o1-self.q69
        o7=V6-R346/R347*(n69-V6)
        if o7>VOH or o7<VOL:
            o7=clamp(o7)
            vm=(n69*R346+o7*R347)/(R346+R347)
        else: vm=V6
        self.q69+=(n69-vm)/R347*DT/C69
        return o7

    def output(self,o7,on):
        g=(1/R4016 if on else 0.0)
        sw=(o7*g+V12/R353+(self.q73+V6)/R412)/(g+1/R353+1/R354+1/R412)
        i412=(sw-self.q73-V6)/R412
        self.q73+=i412*DT/C73
        return sw,i412

    def step(self,noise_hi,slip_n):
        """noise_hi: the S2688's output bit this step (D-4's); slip_n: pad J
        (low = in the slip zone). Returns the current into the D-4 mixer
        through R412 (A)."""
        vn=D4M.NOISE_HI if noise_hi else D4M.NOISE_LO
        vf=self.oscillator()
        o1,va,itr=self.bandpass(vn,vf)
        o7=self.gain(o1)
        sw,i412=self.output(o7,not slip_n)
        self.out.update(c63=self.v63,o8=self.o8,vf=vf,na=va,itr=itr,o1=o1,o7=o7,sw=sw,i412=i412)
        return i412
