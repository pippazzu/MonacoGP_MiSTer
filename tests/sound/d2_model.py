# SPDX-License-Identifier: GPL-3.0-or-later
"""Sound sheet D-2/7 (RESCUE CAR siren and BACK SOUND) as a stepped model.

Floating-point model of the circuit in docs/trace/SOUND_D2_TRACE.md (with
its 2 November check); spice/d2_rescue.cir is the pin-wired reference it is
checked against (d2_check.py). Same step as the other sheets
(sound_parts.DT). Equations: docs/SOUND_LOGIC.md.

Per step, in this order:
  rear      IC42: the comparator (3.44 V, 1K / 100K hysteresis) on the rear
            envelope, the latch pair (gain -100 each, cross-coupled through
            1K) with pin 3 at 12 V while pad P (/RESCUE CP) is low (TR15
            off) or 6 V, and the integrator (16.5 uF) steered from pin 1
            through D18 / R283 51K (down) or R282 82K / D17 (up).
  front     IC43 a (the rear envelope against 4.90 V), C55 0.68 uF into node
            Q (R251 10K, D32 as a clamp at its drop), the IC43 Schmitt,
            the IC43 latch pair (pin 5 from IC43.1, pin 10 from IC44.14),
            the integrator IC44 a (23.5 uF) steered from IC43.7 through D20
            / R291 10K (down) or R290 220K / D19 (up), and IC44 d (the
            front envelope against 3.44 V, R264 8.2K from 12 V / R263 3.3K).
  controls  the 2.8 V rail (R239 8.88K / R238 2.7K) loaded by R236 / R265
            51K; the followers IC40 c (rear) and IC44 c (front).
  tone      the 555 IC39 (12 V; R268 10K, R269 680K, C47 0.68 uF; once
            per step) keys node W through D15 / R230 22K; the sawtooth VCO IC40 d with C49
            0.033 uF, discharged through R231 680 ohm by TR16 (table,
            characterize_d2_tr16.py) while the Schmitt IC40 a is high;
            8 sub-steps per step, the Schmitt's output slewing.
  MC3340s   IC41 (rear, C51 2.2 uF) and IC45 (front, C59 1 uF) on the
            sawtooth, the D-3 table model; they take the previous step's
            sawtooth and CONTROLs (one step, about 2 us, late), as the
            Verilog does.
  outputs   rear: C52 2.2 uF, R276 18K into IC40 b with BACK OTHER CAR
            (R277 22K), C50 10 uF, R274 1K into node Z: pad R (R279 1K and
            an assumed 10K amplifier input), BACK SOUND STB. (R275 50 ohm,
            sunk by D-4's IC57 in attract), and C114 2.2 uF / R424 100K into
            the D-4 mixer's 6 V virtual ground when DIP SW. 2's contact is
            closed. Front: C58 2.2 uF, R292 10K into IC44 b (R293 100K),
            C60 2.2 uF and R410 220K into the mixer.
Op-amps outside the VCO switch at once to their rails (their 20 us slew is
nothing against the envelopes); the latches and comparators are evaluated
in the order above with this step's inputs.
"""
import json
import math
import d3_model as D3M
import sound_parts as P

DT=P.DT
V12=P.V12
V6=P.V6
VOL,VOH=P.VOL,P.VOH
SUB=8                          # VCO sub-steps per model step
DTS=DT/SUB
SLEW_SUB=0.5e6*DTS             # LM324 slew per sub-step (opamps.lib)
GM_SL=1e-3/(0.5e6*1e-3/(2*math.pi*1.2e6))   # gm / islew (opamps.lib), 1/V
# the slewing node's step against the input difference: -0.5..0.5 V, 1/256 V
T_SLEW=P.Table.build(-0.5,1/256,257,lambda d:SLEW_SUB*math.tanh(GM_SL*d))

def rail(x): return VOH if x>0 else VOL
def clamp(x): return min(max(x,VOL),VOH)

# ---- the latch pairs: out = r + 100 (r - other), within the rails
def latch(ra,rb,a,b):
    """Two inverting stages (1K in from the other's output, 100K feedback)
    with + inputs at ra, rb, settled from outputs a, b."""
    for _ in range(4):
        a=clamp(ra+100*(ra-b))
        b=clamp(rb+100*(rb-a))
    return a,b

def hyst_plus(vth,rth,out,r_in=1e3,r_fb=100e3):
    """+ input fed from a Thevenin source (vth, rth) through r_in, with r_fb
    back from the output."""
    rs=rth+r_in
    return (vth*r_fb+out*rs)/(r_fb+rs)

# ---- references
V249=V12*3.3e3/(8.2e3+3.3e3); R249=8.2e3*3.3e3/(8.2e3+3.3e3)
V252=V12*4.7e3/(6.8e3+4.7e3); R252=6.8e3*4.7e3/(6.8e3+4.7e3)
V264=V12*3.3e3/(8.2e3+3.3e3); R264=8.2e3*3.3e3/(8.2e3+3.3e3)
R3_ON=(V12*10e3+P.VCE_SAT*10e3)/20e3          # IC42.3 with TR15 on

# ---- integrators with diode steering
C_REAR=16.5e-6                 # C53 + C54, 33 uF back to back
C_FRONT=23.5e-6                # C56 + C57, 47 uF back to back
def diode_table(r): return P.Table.build(0.0,1/16,177,lambda v:P.diode_i_series(v,r))  # 0..11 V
T_51,T_82=diode_table(51e3),diode_table(82e3)
T_10,T_220=diode_table(10e3),diode_table(220e3)

class Integrator:
    """An LM324 integrator about 6 V with capacitor c, steered from node s
    through a diode into the - input (r_in) or out of it (r_out). q is the
    capacitor's voltage, output side minus - input side. While the output
    sits at a rail the - input leaves 6 V."""
    def __init__(self,c,t_in,t_out):
        self.c=c; self.t_in=t_in; self.t_out=t_out; self.q=0.0
    def out(self):
        v=V6+self.q
        return clamp(v)
    def step(self,s):
        v=V6+self.q
        if v>VOH: vm=VOH-self.q
        elif v<VOL: vm=VOL-self.q
        else: vm=V6
        i=self.t_in(s-vm)-self.t_out(vm-s)          # into the - input
        self.q-=i*DT/self.c
        return i

# ---- the 2.8 V rail and the followers
R239,R238=8.88e3,2.7e3
def controls(env_r,env_f):
    """con41, con45 and the rail: the followers' + inputs take 100K from
    their envelopes and 51K from the rail, which they load."""
    # unknowns r (rail), a (IC40.10), b (IC44.10)
    # a = (env_r/100K + r/51K)/(1/100K + 1/51K), the same for b
    ka=1/100e3+1/51e3
    ga=(1/51e3)/ka                       # a = ga*r + ha
    ha=(env_r/100e3)/ka
    hb=(env_f/100e3)/ka
    g=1/R239+1/R238+2/51e3
    # r*g = 12/R239 + (a+b)/51K
    r=(V12/R239+(ha+hb)/51e3)/(g-2*ga/51e3)
    return clamp(ga*r+ha),clamp(ga*r+hb),r

# ---- the 555 and node W
C47=0.68e-6
R_CH=10e3+680e3                # R268 + R269
# discharging: R269 into DISCHARGE (10 ohm, ne555.lib), which R268 10K holds
# at 12 mV
R_DSG=680e3+10.0*10e3/(10e3+10.0)
V_DSG=V12*10.0/(10e3+10.0)
V555_HI=V12-1.7                # ne555.lib: vcc - 1.75 + 0.05
V555_LO=0.05
TH_HI,TH_LO=V12*2/3,V12/3
K_CH=math.exp(-DT/(R_CH*C47))
K_DSG=math.exp(-DT/(R_DSG*C47))
def node_w(o555):
    """Node W (R233 3.9K from 12 V, R235 12K, R232 30K to IC40's - input at
    W/2, R234 51K + R416 51K to ground) with D15 / R230 22K to the 555's
    output."""
    g=1/3.9e3+1/12e3+1/60e3+1/102e3
    w0=(V12/3.9e3)/g
    if w0<=o555: return w0
    lo,hi=o555,w0
    for _ in range(60):
        m=0.5*(lo+hi)
        if (V12/3.9e3-m*g)>P.diode_i_series(m-o555,22e3): lo=m
        else: hi=m
    return 0.5*(lo+hi)
W_HI,W_LO=node_w(V555_HI),node_w(V555_LO)

# ---- the VCO
C49=0.033e-6
_t=json.loads((P.HERE/"data/d2_tr16.json").read_text())
T_TR16=P.Table(_t["grid"][0],_t["grid"][1],_t["i"])
R231=680.0
def schmitt_plus(out): return (V6*100e3+out*51e3)/151e3   # R272 51K, R273 100K

# ---- MC3340s and outputs
MC=D3M.MC
C51,C59=2.2e-6,1e-6
C52,C58,C60=2.2e-6,2.2e-6,2.2e-6
C50,C114=10e-6,2.2e-6
R_MC=P.R_MC_OUT
R_PADR=1e3+10e3                # R279 and the assumed amplifier input
R_STB=50.0+P.R_OC              # R275 into IC57's sinking output

class D2:
    def __init__(self,dip_back=True):
        self.dip_back=dip_back
        # rear
        self.o42_8=VOL; self.o42_14=VOH; self.o42_1=VOL
        self.rear=Integrator(C_REAR,T_51,T_82)
        # front
        self.o43_14=VOL; self.q55=0.0; self.o43_1=VOL
        # the symmetric latches power up as the reference's do (IC42 pin 1
        # low, IC43 pin 7 low); the drawing does not decide it
        self.o43_7=VOL; self.o43_8=VOH; self.o44_14=VOL
        self.front=Integrator(C_FRONT,T_10,T_220)
        # tone
        self.v47=0.0; self.o555=True
        self.q49=0.0                 # C49: output minus - input
        self.o40_1=VOL; self.n40=VOL
        # MC3340s
        self.qin41=0.0; self.qin45=0.0
        self.p_tri=0.0; self.p_con41=0.0; self.p_con45=0.0
        # outputs
        self.q52=0.0; self.q58=0.0; self.q60=0.0; self.q50=0.0; self.q114=0.0
        self.out={}

    def envelopes(self,resc):
        env_r=self.rear.out()
        # IC42 c comparator: - env_r, + from 3.44 V with hysteresis
        self.o42_8=rail(hyst_plus(V249,R249,self.o42_8)-env_r)
        r12=(V12+self.o42_8)/2
        r3=V12 if resc else R3_ON
        self.o42_14,self.o42_1=latch(r12,r3,self.o42_14,self.o42_1)
        self.rear.step(self.o42_1)
        # IC43 a on the rear envelope
        self.o43_14=rail(hyst_plus(V252,R252,self.o43_14)-env_r)
        # node Q: C55 from IC43.14, R251 10K, R284 10K + R285 100K to IC43.1,
        # D32 a clamp at its drop
        q=self.o43_14-self.q55
        if q<-0.55: q=-0.55; self.q55=self.o43_14+0.55
        i=q/10e3+(q-self.o43_1)/110e3
        self.q55+=i*DT/0.68e-6
        p3=(q*100e3+self.o43_1*10e3)/110e3
        self.o43_1=rail(p3-V6)
        # IC43 latch: 5 from IC43.1, 10 from IC44.14
        r5=(V12+self.o43_1)/2
        r10=(V12+self.o44_14)/2
        self.o43_7,self.o43_8=latch(r5,r10,self.o43_7,self.o43_8)
        env_f=self.front.out()
        self.front.step(self.o43_7)
        # IC44 d: the front envelope against 3.44 V
        self.o44_14=rail(hyst_plus(V264,R264,self.o44_14)-env_f)
        return env_r,env_f

    def tone(self):
        """The 555 (once per step), node W and the VCO over SUB sub-steps;
        returns the sawtooth at the step's end."""
        # 555: C47 charges through R268 + R269 while the output is high,
        # discharges through R269 towards DISCHARGE while low (once per
        # step: it runs at 1.4 Hz)
        if self.o555:
            self.v47=V12+(self.v47-V12)*K_CH
            if self.v47>=TH_HI: self.o555=False
        else:
            self.v47=V_DSG+(self.v47-V_DSG)*K_DSG
            if self.v47<=TH_LO: self.o555=True
        w=W_HI if self.o555 else W_LO
        for _ in range(SUB):
            v13=w/2
            ic=min(T_TR16(self.o40_1),max(v13-0.05,0.0)/R231)
            i=(w-v13)/30e3-ic                     # into C49 from the - input
            self.q49-=i*DTS/C49
            tri=v13+self.q49
            if tri>VOH: tri=VOH; self.q49=VOH-v13
            elif tri<VOL: tri=VOL; self.q49=VOL-v13
            # IC40 a as opamps.lib's LM324: an internal node slewing at
            # 0.5 V/us (tanh of the input difference), held 0.25 V beyond
            # the output's limits
            d=schmitt_plus(self.o40_1)-tri
            self.n40+=T_SLEW(d)
            self.n40=min(max(self.n40,VOL-0.25),VOH+0.25)
            self.o40_1=clamp(self.n40)
        self.tri=tri
        return tri

    def step(self,resc,mute,i_bk):
        """resc: pad P low (/RESCUE CP); mute: BACK SOUND STB. sunk (D-4
        IC57); i_bk: the BACK OTHER CAR current into IC40 pin 6 (A).
        Returns (current into the D-4 mixer through R410 and R424 (A), pad R
        volts)."""
        env_r,env_f=self.envelopes(resc)
        con41,con45,r28=controls(env_r,env_f)
        # MC3340s on the sawtooth through their input capacitors, with the
        # previous step's sawtooth and CONTROLs (the Verilog evaluates them
        # beside the VCO)
        m41i=self.p_tri-self.qin41
        m41o,i41=MC(m41i,self.p_con41)
        self.qin41+=i41*DT/C51
        m45i=self.p_tri-self.qin45
        m45o,i45=MC(m45i,self.p_con45)
        self.qin45+=i45*DT/C59
        tri=self.tone()
        self.p_tri,self.p_con41,self.p_con45=tri,con41,con45
        # rear: C52, R276 into IC40 b with BACK OTHER CAR
        ir=(m41o-self.q52-V6)/(18e3+R_MC)
        o40_7=V6-22e3*(ir+i_bk)
        if o40_7>VOH or o40_7<VOL:
            o40_7=clamp(o40_7)
            # the - input leaves 6 V: R276 + R_MC, R277 and the 51K source
            # meet there (the source is taken as a current here)
            vm=((m41o-self.q52)/(18e3+R_MC)+o40_7/22e3+i_bk)/(1/(18e3+R_MC)+1/22e3)
            ir=(m41o-self.q52-vm)/(18e3+R_MC)
        self.q52+=ir*DT/C52
        # node Z
        g=1/1e3+1/R_PADR+1/100e3+(1/R_STB if mute else 0.0)
        z=((o40_7-self.q50)/1e3+(self.q114+V6)/100e3)/g
        i50=(o40_7-self.q50-z)/1e3
        i424=(z-self.q114-V6)/100e3 if self.dip_back else 0.0
        self.q50+=i50*DT/C50
        self.q114+=i424*DT/C114
        padr=z*10e3/R_PADR
        # front: C58, R292 into IC44 b, C60, R410
        e=m45o-self.q58
        o44_7=V6-100e3*(e-V6)/(10e3+R_MC)
        if o44_7>VOH or o44_7<VOL:
            o44_7=clamp(o44_7)
            vm=(e*100e3+o44_7*(10e3+R_MC))/(100e3+10e3+R_MC)
        else: vm=V6
        i_f=(e-vm)/(10e3+R_MC)
        self.q58+=i_f*DT/C58
        i410=(o44_7-self.q60-V6)/220e3
        self.q60+=i410*DT/C60
        self.out.update(env_r=env_r,env_f=env_f,o42_1=self.o42_1,o42_14=self.o42_14,
                        o42_8=self.o42_8,o43_14=self.o43_14,o43_1=self.o43_1,
                        o43_7=self.o43_7,o44_14=self.o44_14,con41=con41,con45=con45,
                        r28=r28,tri=tri,o40_1=self.o40_1,o555=V555_HI if self.o555 else V555_LO,
                        mc41o=m41o,mc45o=m45o,o40_7=o40_7,z=z,padr=padr,o44_7=o44_7,
                        i410=i410,i424=i424)
        return i410+i424,padr
