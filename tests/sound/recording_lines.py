#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Spectral lines of a recording or of a model step file, for comparing the
core's sounds with Aldo's board recordings (not part of the test suite).

  recording_lines.py timeline FILE [T0 T1]    level and the six strongest
                                              lines every 50 ms (100 ms window)
  recording_lines.py bands FILE,T0,T1 ...     energy per band and the
                                              strongest peaks (Welch) over
                                              each stretch

FILE is a WAV (channels averaged) or a model step file (*.txt, one line per
480 kHz step, the first column in 2^28 per volt), decimated to 48 kHz."""
import sys
import numpy as np
from scipy.io import wavfile
from scipy.signal import find_peaks, resample_poly, welch

def load(p):
    if p.endswith(".txt"):
        d=np.loadtxt(p,usecols=0)/2.0**28
        return 48000,resample_poly(d,1,10)
    fs,x=wavfile.read(p)
    x=x.astype(float)
    return fs,(x.mean(1) if x.ndim>1 else x)

def timeline(p,t0=0.0,t1=None):
    fs,x=load(p)
    t1=len(x)/fs if t1 is None else t1
    x=x[int(t0*fs):int(t1*fs)]
    n=int(0.1*fs); hop=n//2; w=np.hanning(n)
    ref=np.abs(x).max()+1e-12
    f=np.fft.rfftfreq(n,1/fs); m=(f>60)&(f<4000)
    for k in range(0,len(x)-n,hop):
        s=x[k:k+n]
        X=np.abs(np.fft.rfft(s*w))[m]
        pk,_=find_peaks(X,distance=5)
        top=sorted(pk[np.argsort(X[pk])[::-1][:6]])
        lvl=20*np.log10(np.sqrt(np.mean(s**2))/ref+1e-9)
        print(f"{t0+k/fs:6.2f} {lvl:6.1f} dB  "+" ".join(f"{f[m][i]:5.0f}" for i in top))

BANDS=[(50,200),(200,350),(350,500),(500,650),(650,800),(800,1100),
       (1100,1400),(1400,2000),(2000,3000),(3000,6000)]
def bands(spec):
    p,t0,t1=spec.rsplit(",",2)
    fs,x=load(p)
    s=x[int(float(t0)*fs):int(float(t1)*fs)]
    f,P=welch(s,fs,nperseg=8192)
    tot=P[(f>50)&(f<8000)].sum()
    print(p.split("/")[-1],t0,t1,
          " ".join(f"{a}-{b}:{10*np.log10(P[(f>=a)&(f<b)].sum()/tot):5.1f}" for a,b in BANDS))
    m=(f>50)&(f<4000)
    pk,_=find_peaks(10*np.log10(P[m]),prominence=6)
    top=pk[np.argsort(P[m][pk])[::-1][:12]]
    print("   peaks:"," ".join(f"{f[m][i]:.0f}({10*np.log10(P[m][i]/P[m].max()):.0f})"
                             for i in sorted(top)))

if __name__=="__main__":
    a=sys.argv[1:]
    if a and a[0]=="timeline" and len(a) in (2,4):
        timeline(a[1],*(float(v) for v in a[2:]))
    elif a and a[0]=="bands" and len(a)>1:
        for spec in a[1:]: bands(spec)
    else:
        sys.exit(__doc__)
