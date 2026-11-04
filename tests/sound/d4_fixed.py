#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Sound sheet D-4/7: control gates, mixer and SOUND OUT, as the Verilog
does them (cores/monacogp/hdl/jtmonacogp_sound.v, jtmonacogp_snd_mix.v),
and the generator of the mixer's constants (jtmonacogp_snd_mix.vh).

Circuit: docs/trace/SOUND_D4_TRACE.md. The mixer sums MY CAR SOUND (D-3),
the D-4 sources (d4s_fixed.py: explosion, skid tone, EXTEND beep), the
other cars (d67_fixed.py, R409) and the rescue siren and back sound
(d2_fixed.py, R410 and R424); it also decimates D-2's BACK SOUND OUT
(pad R) for a second channel. Fixed point as
in d3_fixed.py (signals 2^28 per volt, states 2^44).

  d4_fixed.py vh PATH     write the Verilog include
"""
import sys
from pathlib import Path
import sound_parts as P
import d3_fixed as F
import d4s_fixed as D4S

# ---- control gates (IC68 inverters, IC60 7402, the 7432, IC67, IC57 7417)
def gates(s_acc1_n,coin_in_n,nonroad_slip_n,game_n,shift,alarm):
    game=1-game_n; coin_in=1-coin_in_n
    g60a=1-(s_acc1_n|game_n)              # explosion trigger T; 555 enable
    my_car_on=1-(g60a|coin_in_n)          # IC60 b -> D-3 MY CAR SOUND ON
    g60c=1-(coin_in_n|game)
    shift_a=1-(g60c|(1-shift))            # IC60 d -> D-3 SHIFT A
    skid_on=g60a|(1-nonroad_slip_n)       # 7432 pin 6 -> the 555's RES
    mute=1-(coin_in|alarm)                # IC67 low: IC57 sinks R406 (and Z on D-2)
    return dict(explo_t=g60a,my_car_on=my_car_on,shift_a=shift_a,skid_on=skid_on,mute=mute)

# ---- mixer IC66 b: R414 22K feedback around the 6 V virtual ground; MY CAR
# SOUND arrives as the R411 current (d3's i_mix = current x 100K)
R414=22e3
R_LOAD=10e3      # input of the cabinet's amplifier: not on the board (assumed)
C103=10e-6; R413=1e3; R407=1e3; R406=100.0
# 16-bit output: 16384 per volt at pad 13, full scale 2.0 V (the sample
# saturates there). Provisional: MY CAR SOUND alone peaks at about 0.4 V on
# pad 13 (about -14 dBFS), an explosion at about 0.55 V, and the sounds
# together (engine, explosion, skid tone) at about 1.3 V; pad 13 can swing
# about -5.0..+3.8 V when IC66 b limits. The balance between the sounds and
# the level are to be set against the real board's recordings once every
# sound is built.
SND_PER_VOLT=16384
# BACK SOUND OUT (pad R, D-2) as a second channel: 4096 per volt, full
# scale 8 V (pad R swings up to about +-4.5 V; the siren alone reaches
# about 2.7 V RMS). Provisional, like SOUND OUT's.
SND_B_PER_VOLT=4096
DECIM=10                   # 480 kHz steps -> 48 kHz samples

def _out(rg):
    """C103 charge and pad-13 voltage per volt across C103 + R413 + rg."""
    return P.DT/(C103*(R413+rg)),rg*R_LOAD/((R407+R_LOAD)*(R413+rg))
_rg_on=R407+R_LOAD
_rg_mute=1/(1/(R407+R_LOAD)+1/(R406+P.R_OC))
C_MY=F.Coef("KMY",R414/100e3)
_k=_out(_rg_on);   C_C103=F.Coef("KC103",_k[0],F.FS); C_PAD=F.Coef("KPAD",_k[1])
_k=_out(_rg_mute); C_C103M=F.Coef("KC103M",_k[0],F.FS); C_PADM=F.Coef("KPADM",_k[1])
C_SND=F.Coef("KSND",SND_PER_VOLT/DECIM,0,F.FV)
C_SNDB=F.Coef("KSNDB",SND_B_PER_VOLT/DECIM,0,F.FV)
COEFS=[C_MY,C_C103,C_PAD,C_C103M,C_PADM,C_SND,C_SNDB]

def _sat16(x): return max(-32768,min(32767,x))

class MixFixed:
    def __init__(self):
        self.c103=0; self.acc=0; self.acc_b=0; self.n=0; self.snd=0; self.snd_b=0; self.out={}
    def step(self,i_my,mute,i_d4=0,padr=0):
        """One model step; i_d4 is the D-4 mixer's other input currents
        times R414, padr D-2's pad R (BACK SOUND OUT). Returns the 16-bit
        SOUND OUT sample when one is complete, else None; the BACK SOUND
        OUT sample is then in snd_b."""
        c=F.CONSTS
        vm=c["V6"]-C_MY(i_my)-i_d4
        vm=F.clamp(vm,c["VOL"],c["VOH"])
        d=vm-(self.c103>>F.SW)
        if mute: self.c103+=C_C103M(d); vpad=C_PADM(d)
        else:    self.c103+=C_C103(d);  vpad=C_PAD(d)
        self.acc+=vpad; self.acc_b+=padr; self.n+=1
        self.out.update(vm=vm,vpad=vpad)
        if self.n==DECIM:
            self.snd=_sat16(C_SND(self.acc)); self.snd_b=_sat16(C_SNDB(self.acc_b))
            self.acc=0; self.acc_b=0; self.n=0
            return self.snd
        return None

class SoundFixed:
    """jtmonacogp_sound.v: the gates as held for the step, D-3, the D-4
    sources, the other cars (D-6/D-7), the rescue siren and back sound
    (D-2, with the other cars' back current of the previous step), the
    slip-zone sound (D-1, on the S2688 bit of the step), the hi-score tune
    (D-5, the core's settings; its alarm line of the previous step goes to
    the gates), the mixer. fs_low: pad C (/F-SOUND) was low at a clock
    before the step (since the previous one); resc: pad P (/RESCUE CP) low
    at the step's start; back: DIP SW. 2's back-sound contact closed;
    slip_n: pad J at the step's start; hiscore_n, mute_pad: D-5's pad 3
    and MUTE at the step's start. prom: D-5's 32 PROM bytes (default: the
    original image in build/roms)."""
    def __init__(self,loud=False,back=True,prom=None):
        import d67_fixed as D67
        import d2_fixed as D2
        import d1_fixed as D1
        import d5_fixed as D5
        self.d3=F.D3Fixed(); self.d4=D4S.D4Fixed(loud); self.d67=D67.D67Fixed()
        self.d2=D2.D2Fixed(back); self.d1=D1.D1Fixed(); self.d5=D5.D5Fixed(prom=prom)
        self.mix=MixFixed(); self.g={}
        self.i_d4=0; self.i_mb=0; self.i_d1=0; self.i_d5=0; self.alarm=0
    def step(self,acce,s_acc1_n,coin_in_n,game_n,shift,nonroad_slip_n,excp=0,fs_low=False,
             resc=False,slip_n=1,hiscore_n=1,mute_pad=0):
        g=gates(s_acc1_n,coin_in_n,nonroad_slip_n,game_n,shift,self.alarm)
        self.g=g
        i_my=self.d3.step(acce,g["shift_a"],g["my_car_on"])
        self.i_d2,self.padr=self.d2.step(resc,bool(g["mute"]),self.i_mb)
        self.i_mf=self.d67.step(acce,fs_low)
        self.i_mb=self.d67.out["i_mb"]
        i4=self.d4.step(g["explo_t"],g["skid_on"],excp)
        self.i_d1=self.d1.step(self.d4.noise.reg>>16&1,slip_n)
        self.i_d5=self.d5.step(hiscore_n,mute_pad)
        self.alarm=int(self.d5.out["alarm"])
        self.i_d4=i4+self.i_mf+self.i_d2+self.i_d1+self.i_d5
        return self.mix.step(i_my,g["mute"],self.i_d4,self.padr)

def write_vh(path):
    def sv(v,bits):
        return f"-{bits}'sd{-v}" if v<0 else f"{bits}'sd{v}"
    L=["// SPDX-License-Identifier: GPL-3.0-or-later",
       "// GENERATED by tests/sound/d4_fixed.py; do not edit. Constants of",
       "// jtmonacogp_snd_mix.v: signals 2^28 per volt, C103 2^44 per volt;",
       "// coefficient = M / 2^S.",""]
    for k in ("V6","VOL","VOH"):
        L.append(f"localparam signed [35:0] {k} = {sv(F.CONSTS[k],36)};")
    assert DECIM<16
    L.append(f"localparam [3:0] DECIM = 4'd{DECIM};")
    for co in COEFS:
        L.append(f"localparam signed [26:0] {co.name}_M = {sv(co.m,27)};  // {co.k:.6g}")
        L.append(f"localparam [5:0] {co.name}_S = 6'd{co.s};")
    Path(path).write_text("\n".join(L)+"\n")

if __name__=="__main__":
    if sys.argv[1]=="vh": write_vh(sys.argv[2])
