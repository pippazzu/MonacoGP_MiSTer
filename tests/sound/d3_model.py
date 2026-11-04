# SPDX-License-Identifier: GPL-3.0-or-later
"""Sound sheet D-3/7 (MY CAR SOUND, the engine) as a stepped model.

Floating-point twin of the Verilog (cores/monacogp/hdl/jtmonacogp_snd_d3.v):
same step (sound_parts.DT), same order of updates, same tables. The circuit
is docs/trace/SOUND_D3_TRACE.md; spice/d3_mycar.cir is the pin-wired
reference it is checked against (d3_check.py). Equations: docs/SOUND_LOGIC.md.
"""
import math
import sound_parts as P

# oscillator cells: (CV -> integrator - resistor, collector resistor, timing C)
CELLS=((150e3,68e3,6800e-12+470e-12),   # 1: IC51 a/b, TR18; C67 + C113
       (270e3,120e3,4700e-12),          # 2: IC50 a/b
       (220e3,100e3,0.022e-6))          # 3: IC49 a/b, TR16
R_SCH6,R_SCHFB=51e3,100e3               # comparator + input: 6 V / output
# Cell comparator output levels: the LM324 limits less the drop across its
# output resistance; high, it drives the 10K / MA150 / base network (about
# 1.2 V at the diode and base), low it sinks the 100K feedback current.
VB_NET=1.2
VOH_C=(P.VOH+P.R_OPOUT*VB_NET/10e3)/(1+P.R_OPOUT/10e3)
VOL_C=P.VOL+P.R_OPOUT*(4.0-P.VOL)/R_SCHFB
# The comparator's internal node runs on past its output limits by CMP_OVER
# volts, so a decision moves the output only after CMP_OVER / slew. This
# stands for the input stage's regeneration and the recovery from
# saturation (about 3 us in the LM324 macro-model of the reference).
CMP_OVER=2.0
SHIFT_K=(470e3+P.R_OC)/(690e3+P.R_OC)
# CV at IC50 c's output limit, less the drop across its output resistance:
# each cell's 51K + 51K divider and its input resistor to the integrator's
# virtual ground at CV/2 (about 0.39 mA in all)
CV_MAX=P.VOH/(1+P.R_OPOUT*sum(1/102e3+0.5/rin for rin,_,_ in CELLS))

def dac_level(code):
    """DAC node for S-ACCE code (bit 0 = A). Each buffer is open (12 V
    through 1K) or sinking (R_OC); weights 390K, 220K, 100K, 51K; R298 390K
    from 12 V."""
    g=1/390e3; i=P.V12/390e3
    r_lo=1e3*P.R_OC/(1e3+P.R_OC); v_lo=P.V12*P.R_OC/(1e3+P.R_OC)
    for b,rw in enumerate((390e3,220e3,100e3,51e3)):
        if code>>b&1: rth,vth=1e3+rw,P.V12
        else: rth,vth=rw+r_lo,v_lo
        g+=1/rth; i+=vth/rth
    return i/g

# V10: IC51 + input, CV through R305 10K, clamped by D27/D28 to the
# R341 680 / R342 330 divider (3.92 V through 222 ohm)
CLAMP_V=P.V12*330/(680+330)
CLAMP_R=680*330/(680+330)
def v10_level(cv):
    def resid(i):    # i: current from CV into the clamp, A
        vd=P.diode_v(abs(i)); vd=vd if i>=0 else -vd
        return cv-i*10e3-(CLAMP_V+CLAMP_R*i+vd)
    lo,hi=-2e-3,2e-3
    for _ in range(80):
        m=0.5*(lo+hi)
        if resid(m)>0: lo=m
        else: hi=m
    i=0.5*(lo+hi)
    return cv-i*10e3

DAC=[dac_level(c) for c in range(16)]
T_D21=P.Table.build(0.0,1/16,177,lambda v:P.diode_i_series(v,33e3))   # lag - f8, 0..11 V
T_V10=P.Table.build(0.0,1/32,337,v10_level)                           # CV 0..10.5 V
MC=P.MC3340()
MC_VB,MC_RIN=P.mc3340_input_line(MC)
BUS_RTH=1/(1/10e3+1/MC_RIN)
# diode drop with BUS_RTH in series, against the voltage across both: 0..16 V
T_VDROP=P.Table.build(0.0,1/32,513,lambda v:v-P.diode_i_series(v,BUS_RTH)*BUS_RTH)
T_SOFT=P.Table.build(0.0,1/512,129,P.softmax_excess)                  # 0..0.25 V

class D3:
    """One instance per board. step() advances one model step; the block
    methods are also driven separately by the tests (d3_check.py driven)."""
    def __init__(self):
        self.lag=0.0                   # C62
        # per cell: [C volts (- input minus output), comparator internal
        # node, transistor on]
        self.cell=[[0.0,VOL_C-CMP_OVER,False] for _ in CELLS]
        self.q66=0.0                   # C66, cell-1 side minus R304 side
        self.q64=0.0                   # C64, bus side minus IC52 IN
        self.q72=0.0                   # C72, IC54.3 side minus mixer side
        self.inl=0.0                   # IC52 IN current beyond its linear part, previous step
        self.lag_force=None            # tests: hold C62 at this voltage
        self.out={}

    def lag_cv(self,acc,shift_a):
        """DAC follower IC49 c and the lag (C62: R300; R302 through IC54
        11-10 while S-ACCE D is low; D21 + R299 back to the follower), the
        IC50 d follower, R303/R301 to the SHIFT inverter (sinking while
        SHIFT A is high) and the IC50 c follower. Returns CV."""
        f8=min(DAC[acc],P.VOH)
        if self.lag_force is not None: self.lag=self.lag_force
        else:
            i=(f8-self.lag)/150e3
            if not (acc>>3&1): i+=(f8-self.lag)/(68e3+P.R_4016)
            if self.lag>f8: i-=T_D21(self.lag-f8)
            self.lag+=i*P.DT/47e-6
        f14=min(max(self.lag,P.VOL),P.VOH)
        n10=f14*SHIFT_K if shift_a else f14
        return min(max(n10,P.VOL),CV_MAX)

    def cells_step(self,cv,vref=P.V6):
        """The three integrator/comparator cells. Returns the integrator
        outputs (IC51.1, IC50.1, IC49.1). vref: the comparators' 51K
        reference (D-5's 6 V here; D-6's own half-rail for its banks).
        Each comparator's + input is left in self.vplus."""
        vm=cv*0.5
        outs=[]
        self.vplus=[]
        for (rin,rc,c),st in zip(CELLS,self.cell):
            i=(cv-vm)/rin
            if st[2]: i-=(vm-P.VCE_SAT)/rc
            st[0]+=i*P.DT/c
            vout=vm-st[0]
            if vout>P.VOH: vout=P.VOH; st[0]=vm-P.VOH
            elif vout<P.VOL: vout=P.VOL; st[0]=vm-P.VOL
            vo=min(max(st[1],VOL_C),VOH_C)
            vplus=(vref*R_SCHFB+vo*R_SCH6)/(R_SCH6+R_SCHFB)
            self.vplus.append(vplus)
            if vplus>vout: st[1]=min(st[1]+P.SLEW_TICK,VOH_C+CMP_OVER)
            else: st[1]=max(st[1]-P.SLEW_TICK,VOL_C-CMP_OVER)
            st[2]=st[1]>P.VTR
            outs.append(vout)
        return outs

    def amctl(self,cv,o1):
        """IC51 c: + is V10 (CV through R305, D27/D28 clamp), - from cell 1
        through C66 and R304, R306 feedback. Returns CON (IC52 pin 2)."""
        v10=T_V10(cv)
        c66r=o1-self.q66
        con=2*v10-c66r
        if con>P.VOH or con<P.VOL:
            con=min(max(con,P.VOL),P.VOH)
            i66=(c66r-con)/20e3
        else:
            i66=(c66r-v10)/10e3
        self.q66+=i66*P.DT/22e-6
        return con

    def busmc(self,o2,o3,con):
        """D24 (cell 2) and D22 (cell 3) into R325 10K and, through C64, IC52
        IN. IN is its linear part (MC_VB through MC_RIN) plus the rest of
        the table current from the previous step; the two diodes are one
        diode from the higher output plus the sharing excess. Returns
        (bus, IC52 IN, IC52 OUT unloaded)."""
        hi_,d=(o2,o3-o2) if o2>=o3 else (o3,o2-o3)
        top=hi_+T_SOFT(-d)
        vth=((self.q64+MC_VB)/MC_RIN-self.inl)*BUS_RTH
        v=top-vth
        bus=vth if v<=0 else top-T_VDROP(v)
        mcin=bus-self.q64
        mco,iin=MC(mcin,con)
        self.inl=iin-(mcin-MC_VB)/MC_RIN
        self.q64+=iin*P.DT/10e-6
        return bus,mcin,mco

    def output(self,vsrc,rsrc,sound_on):
        """IC54 4-3 (on while SOUND ON is high), R356/R355, C72 and R411 into
        the mixer's 6 V virtual ground, fed from vsrc through rsrc (IC52's
        output resistance and the 4016's). Returns (IC54.3, R411 current)."""
        gs=1/rsrc if sound_on else 0.0
        swo=(vsrc*gs+P.V12/51e3+(self.q72+P.V6)/100e3)/(gs+2/51e3+1/100e3)
        i72=(swo-self.q72-P.V6)/100e3
        self.q72+=i72*P.DT/22e-6
        return swo,i72

    def step(self,acc,shift_a,sound_on):
        cv=self.lag_cv(acc,shift_a)
        o1,o2,o3=self.cells_step(cv)
        con=self.amctl(cv,o1)
        bus,mcin,mco=self.busmc(o2,o3,con)
        swo,i72=self.output(mco,P.R_MC_OUT+P.R_4016,sound_on)
        cmp=[min(max(c[1],VOL_C),VOH_C) for c in self.cell]
        self.out.update(lag=self.lag,cv=cv,o51a=o1,o50a=o2,o49a=o3,o51b=cmp[0],o50b=cmp[1],
                        o49b=cmp[2],con=con,bus=bus,mcin=mcin,mcout=mco,swo=swo,
                        mixr=i72*100e3+P.V6,i_mix=i72)
        return i72
