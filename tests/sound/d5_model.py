#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Sound sheet D-5/7 (the hi-score tune) as a stepped model.

Circuit: docs/trace/SOUND_D5_TRACE.md (with its 1 and 2 November checks).
The sequencer is logic and is modelled exactly at the model step; the
analog part is checked against spice/d5_hiscore.cir (d5_check.py), driven
by this sequencer's outputs.

Sequencer (one step per model step, inputs held through the step):
  tempo     IC27 (74LS132) Schmitt oscillator, R114 1K output to input,
            C106 47 uF and R113 22K to ground; enabled by IC38 pin 11
            (/END). Its capacitor is stepped with the exact single-RC
            factor; typical 74LS132 figures (below). CLK (IC26 pin 2) is
            the oscillator output inverted (three NANDs).
  latch 1   IC37 (NAND pair): pin 8 = NAND(pin 11, HI SCORE), pin 11 =
            NAND(/CLK, pin 8). Pin 8 high clears the address counter IC22
            and holds IC26 loading; it falls at the first CLK high after the
            HI SCORE pulse.
  IC26      74161: asynchronous clear while END; /LOAD = NOR(RCO, latch
            pin 8) loads the PROM's duration bits; counts on CLK rising.
  IC22      74393 as one 5-bit ripple counter (address A0..A4), clocked on
            the falling edge of NOR(END, RCO): it steps when RCO rises.
  END       IC38 = NAND(A0, A4), so END is address 17 (the first address
            with A0 and A4 set): it stops the clock and clears IC26 and the
            74123; its rising edge fires the IC46 / R267 C46 / IC38 pulse
            that resets latch 2.
  latch 2   IC37 (NAND pair): pin 3 = NAND(end pulse, pin 6), pin 6 =
            NAND(pin 3, HI SCORE): low from HI SCORE to END.
  output    IC35 pin 4 = NOR(latch 2 pin 3, MUTE): the line to D-4's mute
            gate (IC67 pin 10), high while the tune plays (unmutes the
            amplifier between games).
  74123     A = /LOAD (IC35 pin 13), B = Vcc, /CLR = /END: fires on /LOAD
            falling or /CLR rising with /LOAD low; R358 47K, C74 3.3 uF with
            the D29 diode: tw = 0.25 R C (1 + 0.7 / R[kohm]) (SN74123 data
            sheet, constant 0.25 with the diode).
The PROM (IC21, 74S188, prm40.ic21) bits: 0-3 duration, 4 C, 5 B, 6 A,
7 H. A note lasts 16 - duration clocks.

Analog part, per step in this order (op-amps ideal inside their output
range, capacitors stepped by Euler, as the other sheets):
  vibrato   IC1 a integrator (C3 0.47 uF, R14 100K from the R13 15K / R12
            47K divider, + input at half of it through R15/R16 51K, R5 51K
            to TR1) and the IC1 b Schmitt (R17 100K to 6 V, R19 100K from
            pin 7) driving TR1 through R18 10K and D1. TR1 is a switch: its
            current through R5 at saturation (VCE_SAT_TR1).
  notes     IC1 c and d: inverting summers (R4/R3 39K in, R9/R6 10K
            feedback) about the R20 33K / R10 point, their inputs the bank
            nodes (R23 / R1 ADJ to 12 V, the selected branches to the IC13
            7417s), plus the vibrato through C2/C1 4.7 uF and R8/R7 1M.
  sawtooth  IC2/IC4/TR2 and IC3/IC5/TR3: a two-slope model, falling at the
            integrator's rate CV (1 - a) / (R26 C4), a = R29 / (R27 + R29),
            rising at the characterized reset rate, turning at the
            characterized points (characterize_d5_vco.py: the comparators'
            delays and TR2's turn-off move them beyond the thresholds); the
            time past a turning point is carried into the other slope.
  mixer     IC15 c: 6 V - (upper - 6 V) R115/R31 - (lower - 6 V) R115/R39.
  filters   IC6 c Sallen-Key low-pass (R43, R46 4.7K, C13 0.033 uF, C12
            6800 pF) and IC6 d Sallen-Key high-pass (C11, C10 6800 pF, R44
            12K, R42 22K to 6 V).
  envelope  74123 Q (3.4 V high behind 100 ohm, as the reference) through
            D4 and R49 1K (tabulated, T_D4) into C14 6.8 uF, R52 470K, R55 68K to the IC48
            7407 (PROM H low sinks it); IC6 a follower, IC6 b: CON =
            n50 + (n50 - env) R57/R48, n50 = 5 V * R47/(R50 + R47).
  MC3340    IC7 through C8 1 uF (the D-3 table model) with a pole for
            C100 680 pF on pin 6 (against the device's R13 6.2K), OUT
            through C15 2.2 uF and R408 39K into the D-4 mixer's 6 V
            virtual ground.
"""
import json
import math
from pathlib import Path
import d3_model as D3M
import sound_parts as P

HERE=Path(__file__).resolve().parent
DT=P.DT
V12,V6,VCC=P.V12,P.V6,P.VCC
VOL,VOH=P.VOL,P.VOH

# ---- settings the drawing leaves open (see docs/SOUND_LOGIC.md, D-5)
R10=10e3          # drawn 1K over a crossed-out value: 1K cannot reach the
                  # printed notes (the summers' outputs stay below 0.44 V)
R29=51e3          # overwritten on the drawing, begins with 5 (R37 is 51K)
R23=R1=1e3        # ADJ (select on test), drawn 1K
NOTE_HZ={"C":262.0,"B":330.0,"A":392.0}   # printed: do/mi/so

# ---- the PROM (IC21, prm40.ic21 at offset 8768 in the PROM image)
def load_prom(path=None):
    if path is None:
        root=HERE.parent.parent
        path=root/"build/roms/proms.bin"
    return list(Path(path).read_bytes()[8768:8768+32])

def load_prom_hex(path):
    """The same 32 bytes from a PROM image as the testbenches read it
    (proms.hex: one byte a line, in hexadecimal)."""
    return [int(x,16) for x in Path(path).read_text().split()[8768:8768+32]]

# ---- 74LS132 tempo oscillator (SN74LS132 data sheet, typical): positive
# threshold 1.6 V, negative 0.8 V, output 3.4 V high and 0.25 V low;
# input current 0.2 mA out of the input while it is below the positive
# threshold (the data sheet gives -0.4 mA as the maximum at 0.4 V), none
# above
VT_P,VT_N=1.6,0.8
TTL_VOH,TTL_VOL=3.4,0.25
I_IN_LS=0.2e-3
R114,R113=1e3,22e3
C106_DRAWN=47e-6
# The tempo: with the drawn 47 uF and the typical figures above the clock
# period is 68.0 ms; the recordings (2 November: three boards and the Saturn
# version) run at 37.5 to 45.6 ms, 41.8 ms on average. The period scales
# with C106, so the 74LS132's spread and the electrolytic's tolerance are
# taken together as an effective C106 that gives 42 ms.
C106=C106_DRAWN*42.0/68.002
RP_TEMPO=R114*R113/(R114+R113)
def tempo_vinf(o_high,below):
    """Where the timing node heads: output through R114, R113 to ground,
    the input current while below the threshold."""
    return ((TTL_VOH if o_high else TTL_VOL)/R114+(I_IN_LS if below else 0.0))*RP_TEMPO

# ---- 74123 with the diode (R358 47K, C74 3.3 uF)
def tw_74123_diode(r,c): return 0.25*r*c*(1+0.7/(r/1e3))
TW_STEPS=int(round(tw_74123_diode(47e3,3.3e-6)*P.TICK_HZ))

class Sequencer:
    """Exact logic at the model step. Power-up state: parked at END
    (address 17, latch 2 set), as after a tune; the drawing does not
    decide it (a real board powers up anywhere)."""
    END_ADDR=17
    def __init__(self,prom=None,c106=C106):
        self.prom=prom if prom is not None else load_prom()
        self.k_tempo=math.exp(-DT/(RP_TEMPO*c106))
        self.addr=self.END_ADDR; self.cnt=0
        self.q8=False; self.q11=True          # latch 1
        self.q3=True; self.q6=False           # latch 2
        self.o11=True                          # IC27 pin 11 (forced high at END)
        self.vc=tempo_vinf(True,False)         # charged while parked
        self.clk=False; self.ck393=False
        self.end=True; self.load_n=True; self.clr_n=False
        self.q123=0                            # steps left of the 74123 pulse

    def _rco(self): return self.cnt==15
    def _end(self): return (self.addr&1)==1 and (self.addr>>4&1)==1

    # the tempo capacitor (the fixed-point twin overrides these)
    def t_ge_p(self): return self.vc>=VT_P
    def t_le_n(self): return self.vc<=VT_N
    def t_update(self):
        v=tempo_vinf(self.o11,self.vc<VT_P)
        self.vc=v+(self.vc-v)*self.k_tempo

    ITER=8                                     # settling passes a step

    def settle(self,line):
        """One pass of the asynchronous logic; idempotent once settled.
        Returns True when END rose in this pass."""
        rose=False
        end=self._end()
        if end and not self.end: rose=True
        self.end=end
        if end: self.cnt=0                     # IC26 asynchronous clear
        # the oscillator's Schmitt decision on the capacitor
        if end: o11=True
        elif self.o11 and self.t_ge_p(): o11=False
        elif not self.o11 and self.t_le_n(): o11=True
        else: o11=self.o11
        self.o11=o11
        clk=not o11
        # latch 1 (unrolled: it settles in two rounds)
        for _ in range(2):
            self.q11=not((not clk) and self.q8)
            self.q8=not(self.q11 and line)
        if self.q8: self.addr=0                # IC22 asynchronous clear
        load_n=not(self._rco() or self.q8)
        clr_n=not self._end()
        # 74123: /LOAD falling with /CLR high, or /CLR rising with /LOAD low
        if not clr_n: self.q123=0
        elif (self.load_n and not load_n) or (not self.clr_n and not load_n):
            self.q123=TW_STEPS
        self.load_n=load_n; self.clr_n=clr_n
        # IC26 on CLK rising (the counter's ripple waits for the next pass)
        if clk and not self.clk:
            self.clk=clk
            if not self._end():
                self.cnt=(self.prom[self.addr]&15) if not load_n else (self.cnt+1)&15
            return rose
        self.clk=clk
        # IC22 on the falling edge of NOR(END, RCO)
        ck=not(self._end() or self._rco())
        if self.ck393 and not ck and not self.q8: self.addr=(self.addr+1)&31
        self.ck393=ck
        return rose

    def step(self,hiscore_n,mute):
        line=bool(hiscore_n)
        end_pulse=False
        for _ in range(self.ITER):
            if self.settle(line): end_pulse=True
        # latch 2: the END pulse (low on pin 1) resets it, HI SCORE sets it
        if end_pulse:
            self.q3=True; self.q6=not(self.q3 and line)
        for _ in range(2):
            self.q3=not(self.q6)
            self.q6=not(self.q3 and line)
        self.t_update()
        # the 74123's pulse
        q=self.q123>0
        if self.q123>0: self.q123-=1
        d=self.prom[self.addr]
        return {"c":d>>4&1,"b":d>>5&1,"a":d>>6&1,"h":d>>7&1,"q123":int(q),
                "alarm":int((not self.q3) and not mute),"addr":self.addr,"cnt":self.cnt,
                "clk":int(self.clk)}

# ---- analog parts
VCO_DATA=HERE/"data/d5_vco.json"
R26=R27=R35=R36=51e3
R37=51e3
C4=C5=0.022e-6
VCE_SAT_TR1=P.VCE_SAT     # TR1 deep in saturation (76 uA, about 0.4 mA base)
# IC1 pin 7 high: VOH less its 50 ohm output resistance's drop at the base
# drive (R18 10K into D1 and TR1's base, about 1.25 V)
O1_7_HIGH=VOH-P.R_OPOUT*(VOH-1.25)/10e3

def bank_thevenin(radj,branches,sel):
    """The bank node: radj from 12 V, each selected branch (resistance) to
    a 7417 sinking through R_OC. Returns (V, R)."""
    g=1/radj; i=V12/radj
    for r,on in zip(branches,sel):
        if on: g+=1/(r+P.R_OC)
    return i/g,1/g

class Vco:
    """Two-slope sawtooth with characterized turning points."""
    def __init__(self,r_plus,path=VCO_DATA):
        t=json.loads(Path(path).read_text())
        x0,dx,n=t["cv_grid"]
        self.top=P.Table(x0,dx,t["top"]); self.bot=P.Table(x0,dx,t["bot"])
        self.r_up=P.Table(x0,dx,t["r_up"])
        self.k_dn=(1-r_plus/(51e3+r_plus))/(51e3*0.022e-6)
        self.a=r_plus/(51e3+r_plus)
        self.s=None; self.up=False
    def step(self,cv):
        if self.s is None:
            # power-up: C4 at 0 V puts the output at the + input, below the
            # lower turning point, so the reset transistor raises it
            self.s=self.a*cv; self.up=self.s<=self.bot(cv)
            return self.s
        r_dn=max(cv,0.0)*self.k_dn
        r_up=self.r_up(cv)
        if not self.up:
            self.s-=r_dn*DT
            b=self.bot(cv)
            if self.s<=b:
                self.s=b+(b-self.s)*r_up/max(r_dn,1e-9)
                self.up=True
        else:
            self.s+=r_up*DT
            tp=self.top(cv)
            if self.s>=tp:
                self.s=tp-(self.s-tp)*r_dn/r_up
                self.up=False
        return self.s

MC=D3M.MC

# ---- exact stepping of the two filters (linear, so their state moves by
# fixed matrices; the input taken as a straight line across the step)
def _mm(a,b): return [[sum(a[i][k]*b[k][j] for k in range(len(b))) for j in range(len(b[0]))] for i in range(len(a))]
def expm(a):
    """Matrix exponential: scaling and squaring of a Taylor series."""
    n=len(a); norm=max(sum(abs(v) for v in row) for row in a)
    sq=max(0,int(math.ceil(math.log2(norm)))+1) if norm>0 else 0
    s=[[v/2**sq for v in row] for row in a]
    e=[[float(i==j) for j in range(n)] for i in range(n)]; term=[r[:] for r in e]
    for k in range(1,30):
        term=[[v/k for v in row] for row in _mm(term,s)]
        e=[[e[i][j]+term[i][j] for j in range(n)] for i in range(n)]
    for _ in range(sq): e=_mm(e,e)
    return e

def foh(a,b):
    """x' = a x + b u, u linear from u0 to u1 over DT: returns (Phi, G0, G1)
    with x[k+1] = Phi x[k] + G0 u0 + G1 u1."""
    n=len(a); m=[[0.0]*(n+2) for _ in range(n+2)]
    for i in range(n):
        for j in range(n): m[i][j]=a[i][j]*DT
        m[i][n]=b[i]*DT
    m[n][n+1]=1.0
    e=expm(m)
    phi=[[e[i][j] for j in range(n)] for i in range(n)]
    g1=[e[i][n] for i in range(n)]; g2=[e[i][n+1] for i in range(n)]
    return phi,[g1[i]-g2[i] for i in range(n)],g2

R43=R46=4.7e3; C13,C12=0.033e-6,6800e-12
R44,R42=12e3,22e3; C11=C10=6800e-12
# low-pass: q13 = n43 - pin 8, v12 = pin 8; i43 = (u - n43)/R43, i46 = q13/R46
FOH_LP=foh([[(-1/R43-1/R46)/C13,-1/(R43*C13)],[1/(R46*C12),0.0]],[1/(R43*C13),0.0])
# high-pass on w = pin 8 - 6 V: pin 14 - 6 V = w - q11 - q10; i10 = (pin 14 -
# 6 V)/R42, i11 = i10 + q10/R44
FOH_HP=foh([[-1/(R42*C11),-1/(R42*C11)+1/(R44*C11)],[-1/(R42*C10),-1/(R42*C10)]],
           [1/(R42*C11),1/(R42*C10)])

K_ROLL=1-math.exp(-DT/(6.2e3*680e-12))

# D4 and R49 1K with the 74123's 100 ohm: current against the voltage
# across them (0 .. 3.5 V)
T_D4=P.Table.build(0.0,1/128,449,lambda v:P.diode_i_series(v,1e3+100.0))

class D5:
    def __init__(self,vr=None,prom=None,c106=C106):
        # trimmers (ohm): upper bank VR4 (A) VR5 (B) VR6 (C), lower VR1 VR2 VR3
        self.vr=dict(vr) if vr else dict(DEFAULT_VR)
        self.seq=Sequencer(prom,c106)
        self.ref=V12*R10/(33e3+R10)
        # power-up as the reference (`uic`): every capacitor at 0 V, the
        # op-amps' outputs low
        # vibrato: C3 at 0 V puts IC1 pin 1 at its - input
        self.lfo=self.lfo_currents()[0]
        # IC1 b went high in the reference's power-up (its - input passes
        # below the + input while IC1 a's output rises)
        self.o1_7=O1_7_HIGH
        # coupling capacitors C2 / C1 (lfo side minus summing-node side)
        self.q2=0.0; self.q1=0.0
        self.vu=Vco(R29); self.vl=Vco(R37)
        # filters: low-pass [C13 (n43 - pin 8), C12], high-pass [C11 (pin 8
        # - n11), C10 (n11 - pin 14)]; the previous step's inputs
        self.xlp=[0.0,0.0]; self.xhp=[0.0,0.0]; self.p_mix=0.0; self.p_lp=0.0
        # envelope, MC3340
        self.env=0.0; self.n50=0.0; self.q8=0.0; self.q15=0.0; self.mcf=None
        self.out={}

    # vibrato: the + input divider and the two integrator currents
    VN13=None
    @staticmethod
    def lfo_currents():
        """The R13/R12 node with R14 into the - input and R15/R16 at the +
        input (both inputs at the same voltage, V3): returns (V3, current
        through R14 into C3, current through R5 when TR1 conducts)."""
        # node n13: (12 - vn)/15K = vn/47K + 2 (vn - v3) path... solved
        # exactly: v3 = vn/2 (R15 = R16, no input current); R14 carries
        # (vn - v3)/100K
        g=1/15e3+1/47e3+(1-0.5)/100e3+1/(51e3+51e3)
        vn=(V12/15e3)/g
        v3=vn/2
        return v3,(vn-v3)/100e3,(v3-VCE_SAT_TR1)/51e3

    def vibrato(self):
        v3,i14,i5=self.lfo_currents()
        # IC1 b compares the triangle (- input) with th
        tr_on=self.o1_7>V6
        i=i14-(i5 if tr_on else 0.0)        # into C3 from the - input side
        self.lfo-=i*DT/0.47e-6
        self.lfo=min(max(self.lfo,VOL),VOH)
        self.o1_7=O1_7_HIGH if self.lfo<(V6+self.o1_7)/2 else VOL
        return self.lfo

    def summer(self,branches,sel,radj,cpl_q,lfo):
        """IC1 c or d: returns (CV, current through the coupling capacitor)."""
        vth,rth=bank_thevenin(radj,branches,sel)
        i_bank=(vth-self.ref)/(rth+39e3)
        i_lfo=(lfo-cpl_q-self.ref)/1e6
        cv=self.ref-10e3*(i_bank+i_lfo)
        return min(max(cv,VOL),VOH),i_lfo

    def filters(self,mix):
        """Both Sallen-Key sections, each stepped exactly for an input that
        moves linearly across the step (first-order hold: FOH_* below).
        Returns the low-pass (IC6 pin 8) and high-pass (pin 14) outputs at
        the step's end."""
        x=self.xlp; u0=self.p_mix
        nx=[sum(FOH_LP[0][i][j]*x[j] for j in range(2))+FOH_LP[1][i]*u0+FOH_LP[2][i]*mix
            for i in range(2)]
        self.xlp=nx; self.p_mix=mix
        lp=min(max(nx[1],VOL),VOH)
        y=self.xhp; w0=self.p_lp-V6; w1=lp-V6
        ny=[sum(FOH_HP[0][i][j]*y[j] for j in range(2))+FOH_HP[1][i]*w0+FOH_HP[2][i]*w1
            for i in range(2)]
        self.xhp=ny; self.p_lp=lp
        hp=lp-ny[0]-ny[1]
        return lp,min(max(hp,VOL),VOH)

    def envelope(self,q123,h):
        i4=T_D4(TTL_VOH-self.env) if q123 else 0.0
        i=i4-self.env/470e3-(0.0 if h else self.env/(68e3+P.R_OC))
        self.env+=i*DT/6.8e-6
        envf=min(max(self.env,VOL),VOH)
        # IC6 pin 5: R50 2.7K from 5 V, R47 5.1K, C9 47 uF
        self.n50+=((VCC-self.n50)/2.7e3-self.n50/5.1e3)*DT/47e-6
        con=self.n50+(self.n50-envf)*15e3/33e3
        return min(max(con,VOL),VOH)

    def mc_chain(self,hp,con):
        """C8 1 uF into IC7 IN, IC7 OUT (unloaded) through R_MC_OUT, C15
        2.2 uF and R408 39K into the mixer's 6 V. Returns (the OUT pin's
        voltage, the R408 current)."""
        mcin=hp-self.q8
        mco,iin=MC(mcin,con)
        self.q8+=iin*DT/1e-6
        # C100 680 pF on pin 6 with the MC3340's R13 6.2K: a pole on the
        # output (the table model is static)
        self.mcf=mco if self.mcf is None else self.mcf+(mco-self.mcf)*K_ROLL
        mco=self.mcf
        i408=(mco-self.q15-V6)/(P.R_MC_OUT+39e3)
        self.q15+=i408*DT/2.2e-6
        return mco-i408*P.R_MC_OUT,i408

    def step(self,hiscore_n=1,mute=0):
        s=self.seq.step(hiscore_n,mute)
        lfo=self.vibrato()
        vr=self.vr
        sel=(not s["a"],not s["b"],not s["c"])
        cvu,il2=self.summer((vr["VR4"],vr["VR5"]+220,vr["VR6"]+680),sel,R23,self.q2,lfo)
        cvl,il1=self.summer((vr["VR1"],vr["VR2"]+220,vr["VR3"]+680),sel,R1,self.q1,lfo)
        self.q2+=il2*DT/4.7e-6; self.q1+=il1*DT/4.7e-6
        su=self.vu.step(cvu); sl=self.vl.step(cvl)
        mix=V6-(su-V6)*100e3/100e3-(sl-V6)*100e3/220e3
        mix=min(max(mix,VOL),VOH)
        lp,hp=self.filters(mix)
        con=self.envelope(s["q123"],s["h"])
        mco,i408=self.mc_chain(hp,con)
        self.out={"lfo":lfo,"cvu":cvu,"cvl":cvl,"sawu":su,"sawl":sl,"mix":mix,"lp":lp,"hp":hp,
                  "env":self.env,"con":con,"mco":mco,"i408":i408,**s}
        return i408

def static_hz(cv,path=VCO_DATA,r_plus=R29):
    """The sawtooth's frequency at a steady control voltage (two-slope
    model with the characterized corners)."""
    v=Vco(r_plus,path)
    r_dn=cv*v.k_dn
    return 1/((v.top(cv)-v.bot(cv))*(1/r_dn+1/v.r_up(cv)))

# the trimmers: which bank branch each note grounds, and its range
TRIMS={"VR4":("A",0.0,1e3,R23,"u"),"VR5":("B",220.0,1e3,R23,"u"),"VR6":("C",680.0,2e3,R23,"u"),
       "VR1":("A",0.0,1e3,R1,"l"),"VR2":("B",220.0,2e3,R1,"l"),"VR3":("C",680.0,2e3,R1,"l")}

def note_cv(rbranch,radj):
    """A summer's output with one branch grounded, the vibrato at rest."""
    ref=V12*R10/(33e3+R10)
    vth,rth=bank_thevenin(radj,(rbranch,),(True,))
    return ref-10e3*(vth-ref)/(rth+39e3)

def solve_trimmers(note_hz=NOTE_HZ,path=VCO_DATA):
    """Each trimmer set so that its note has the printed frequency (both
    banks alike: the drawing prints one frequency per note). A trimmer
    that cannot reach it is left at the end nearer to it."""
    out={}
    for name,(note,rfix,rmax,radj,bank) in TRIMS.items():
        rp=R29 if bank=="u" else R37
        f=lambda r:static_hz(note_cv(rfix+r,radj),path,rp)
        lo,hi=0.0,rmax           # frequency falls as the branch grows
        if f(lo)<note_hz[note]: out[name]=lo; continue
        if f(hi)>note_hz[note]: out[name]=hi; continue
        for _ in range(60):
            m=0.5*(lo+hi)
            if f(m)>note_hz[note]: lo=m
            else: hi=m
        out[name]=round(0.5*(lo+hi),3)
    return out

# solve_trimmers() with R10 10K, R29 51K and data/d5_vco.json (2 November)
DEFAULT_VR={"VR4":339.025,"VR5":453.645,"VR6":614.801,"VR1":339.025,"VR2":453.645,"VR3":614.801}
