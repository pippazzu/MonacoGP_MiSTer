#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Check the sound-board run (tests/tb_sound.v):
  1. jtmonacogp_snd_mix.vh is what d4_fixed.py generates now;
  2. the gates held for each step follow the D-4 gate equations from the
     inputs taken for that step, and (tb_sound only) every combination of
     the five gate inputs occurred;
  3. D-3's mixer current, the other cars' R409 current, D-2's mixer current
     and pad R, D-1's mixer current, D-5's mixer current and alarm line,
     the mixer's other input (the D-4 sources, R409, D-2, D-1, D-5), pad
     13 and every sample of both channels equal the fixed-point twin
     (d4_fixed.SoundFixed, with pad C, pad P, pad J, HI SCORE, MUTE and
     the back-sound contact as the testbench saw the module take them, and
     D-5's PROM from the image the testbench loaded), bit for bit;
  4. a sample comes every ten steps;
  5. jtmonacogp_snd_d5.vh is what d5_fixed.py generates now, and (tb_sound
     only) the hi-score tune played with the alarm line both high and low.
The samples are written to OUT/NAME.wav (SOUND OUT) and OUT/NAME_back.wav
(BACK SOUND OUT), 48 kHz, 16-bit mono, to listen to.
Usage: sound_check.py OUTDIR NAME ROM   (OUTDIR/NAME_steps.txt; NAME is
sound for tests/tb_sound.v or play_sound for tests/tb_play_sound.v; ROM is
the proms.hex the testbench read)"""
import filecmp
import sys
import tempfile
import wave
from pathlib import Path
import d4_fixed as D
import d5_fixed as D5
import d5_model as M5

ROOT=Path(__file__).resolve().parents[2]
GATES=["my_car_on","shift_a","mute","explo_t","skid_on"]

def main():
    out=Path(sys.argv[1]); name=sys.argv[2]; rom=sys.argv[3]
    with tempfile.TemporaryDirectory() as td:
        for fn,gen in (("jtmonacogp_snd_mix.vh",D.write_vh),("jtmonacogp_snd_d5.vh",D5.write_vh)):
            vh=Path(td)/fn; gen(vh)
            if not filecmp.cmp(vh,ROOT/"cores/monacogp/hdl"/fn,shallow=False):
                print(f"FAIL: {fn} differs from its generator's output; regenerate it")
                sys.exit(1)
    print("jtmonacogp_snd_mix.vh and jtmonacogp_snd_d5.vh match their generators")
    rows=[[int(x) for x in l.split()] for l in (out/f"{name}_steps.txt").read_text().splitlines()]
    s=D.SoundFixed(prom=M5.load_prom_hex(rom)); bad=0; combos=set(); samples=[]; back=[]; last=-1
    lows=0; rescs=0; slips=0; his=0; mutes=0; tune={}
    for k,r in enumerate(rows):
        acce,s_acc1_n,coin_in_n,game_n,shift,nonroad,excp=r[0:7]
        got_g=dict(zip(GATES,r[7:12])); i_my,vpad,i_d4,has,snd,fs_low,i_mf=r[12:19]
        resc,back_on,i_d2,padr,snd_b,slip_n,i_d1,hs_n,mpad,i_d5,alarm=r[19:30]
        combos.add((s_acc1_n,coin_in_n,game_n,shift,nonroad))
        s.d2.dip_back=bool(back_on)
        exp_s=s.step(acce,s_acc1_n,coin_in_n,game_n,shift,nonroad,excp,fs_low=bool(fs_low),
                     resc=bool(resc),slip_n=slip_n,hiscore_n=hs_n,mute_pad=mpad)
        lows+=fs_low; rescs+=resc; slips+=1-slip_n; his+=1-hs_n; mutes+=mpad
        if s.d5.out["addr"]!=s.d5.seq.END_ADDR: tune[alarm]=tune.get(alarm,0)+1
        exp_g={g:s.g[g] for g in GATES}
        errs=[]
        if got_g!=exp_g: errs.append(f"gates {got_g} expected {exp_g}")
        if i_my!=s.d3.out["i_mix"]: errs.append(f"i_my {i_my} twin {s.d3.out['i_mix']}")
        if i_mf!=s.i_mf: errs.append(f"i_mf {i_mf} twin {s.i_mf}")
        if i_d2!=s.i_d2: errs.append(f"i_d2 {i_d2} twin {s.i_d2}")
        if i_d1!=s.i_d1: errs.append(f"i_d1 {i_d1} twin {s.i_d1}")
        if i_d5!=s.i_d5: errs.append(f"i_d5 {i_d5} twin {s.i_d5}")
        if alarm!=s.alarm: errs.append(f"alarm {alarm} twin {s.alarm}")
        if padr!=s.padr: errs.append(f"padr {padr} twin {s.padr}")
        if i_d4!=s.i_d4: errs.append(f"i_d4 {i_d4} twin {s.i_d4}")
        if vpad!=s.mix.out["vpad"]: errs.append(f"pad {vpad} twin {s.mix.out['vpad']}")
        if bool(has)!=(exp_s is not None) or (has and snd!=exp_s):
            errs.append(f"sample {has}:{snd} twin {exp_s}")
        if has and snd_b!=s.mix.snd_b: errs.append(f"back sample {snd_b} twin {s.mix.snd_b}")
        if has:
            if last>=0 and k-last!=D.DECIM: errs.append(f"sample {k-last} steps after the previous one")
            last=k; samples.append(snd); back.append(snd_b)
        if errs:
            bad+=1
            if bad<=5: print(f"step {k}: "+"; ".join(errs))
    if bad:
        print(f"FAIL: {bad} of {len(rows)} steps differ"); sys.exit(1)
    if name=="sound" and len(combos)!=32:
        print(f"FAIL: only {len(combos)} of the 32 gate-input combinations occurred"); sys.exit(1)
    if name=="sound" and not (tune.get(0) and tune.get(1)):
        print(f"FAIL: the hi-score tune did not play with the alarm line both high and low ({tune})")
        sys.exit(1)
    print(f"{len(rows)} steps and {len(samples)} samples equal to the fixed-point twin, bit for bit; "
          f"gates right for the {len(combos)} input combinations that occurred; "
          f"pad C low in {lows} steps, pad P low in {rescs}, pad J low in {slips}, "
          f"HI SCORE low in {his}, MUTE high in {mutes}; the tune playing in "
          f"{sum(tune.values())} steps, {tune.get(1,0)} of them with the alarm line high")
    for fn,data in ((f"{name}.wav",samples),(f"{name}_back.wav",back)):
        with wave.open(str(out/fn),"wb") as w:
            w.setnchannels(1); w.setsampwidth(2); w.setframerate(48000)
            w.writeframes(b"".join(int(v).to_bytes(2,"little",signed=True) for v in data))
        print(f"samples written to {out/fn}; peak {max(abs(v) for v in data)}")

if __name__=="__main__": main()
