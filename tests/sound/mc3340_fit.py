#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Separable table model of the MC3340, fitted to its transistor-level DC
characterization (characterize_mc3340.py, 12 V supply).

    sep = VO0(Vc) - G(Vc) * Heff(Vin, Vc)
    out = min( LO(Vc) + S(sep - LO(Vc)), HI )
    Heff = H(Vin) * (1 - W(Vin - VONW(Vc))) + H_LOW * W(Vin - VONW(Vc))
    iin  = IB(Vin) + IC(Vin - VON(Vc))

G is the gain (1 at low control voltage, 0 above about 4.5 V); H is the
input transfer, H_LOW its value with the input stage cut off (Vin below
about 0.4 V). Above VON (about 4.3 to 5.3 V, rising with Vc) the input
transistor saturates: the input then takes extra current IC(u) and the
signal collapses to the cut-off value (W -> 1) a little later (VONW). The tables are uniform
grids, read with linear interpolation; the same tables drive the Verilog.
Input: build/sound/mc3340_dc.json (characterize_mc3340.py); output:
data/mc3340_tables.json.
LO is the deepest low clip of each control row; S (identity above 0.4 V)
rounds the knee, since the output keeps falling slowly as the input rises
into the clip.
"""
import json
from pathlib import Path
import numpy as np

HERE=Path(__file__).resolve().parent
HI=11.249
# grids: (first value, step, count)
VC_GRID=(0.0,1/16,129)      # 0 .. 8 V
VIN_GRID=(-2.0,1/32,289)    # -2 .. 7 V
U_GRID=(-0.25,1/256,193)    # -0.25 .. 0.5 V
S_GRID=(-4.0,1/32,141)      # -4 .. 0.375 V
VON_LEVEL=500e-6            # VON: where the extra input current reaches this
W_ALIGN=0.7                 # VONW: where the collapse W reaches this

def interp(grid,table,x):
    x0,dx,n=grid
    f=(np.asarray(x,dtype=float)-x0)/dx
    i=np.clip(np.floor(f).astype(int),0,n-2)
    t=np.clip(f-i,0.0,1.0)
    tab=np.asarray(table)
    return tab[i]*(1-t)+tab[i+1]*t

def axis(grid): return grid[0]+grid[1]*np.arange(grid[2])

def fit(path=HERE.parents[1]/"build/sound/mc3340_dc.json"):
    d=json.loads(Path(path).read_text())
    vin=np.array(d["vin"]); vcs=np.array(d["vc"]); out=np.array(d["out"]); iin=np.array(d["iin"])
    i16=int(np.argmin(abs(vin-1.6)))
    slope=-(out[:,i16+5]-out[:,i16-5])/(vin[i16+5]-vin[i16-5])
    g=np.clip(slope/slope[0],0,1)
    g[vcs>=4.8+0.13]=0.0   # (spice/mc3340.lib's 0.13 V control offset)
    vo0=out[:,i16].copy()
    # input current without the clamp: the highest control row up to 5 V,
    # then its slope continued
    top=iin[-1]; m=vin<=5.0
    s=(top[m][-1]-top[m][-51])/(vin[m][-1]-vin[m][-51])
    ib=np.where(m,top,top[m][-1]+s*(vin-vin[m][-1]))
    # VON per control row
    von=np.empty(len(vcs))
    for k in range(len(vcs)):
        ex=iin[k]-ib; j=int(np.argmax(ex>VON_LEVEL))
        von[k]=vin[j-1]+(VON_LEVEL-ex[j-1])/(ex[j]-ex[j-1])*(vin[j]-vin[j-1])
    # clamp current against u, averaged over the rows that clamp below 5 V
    ua=axis(U_GRID); ics=[]
    for k in range(len(vcs)):
        if von[k]>4.95: continue
        ics.append(np.interp(ua,vin-von[k],iin[k]-ib))
    ic=np.mean(ics,axis=0)
    # H from the rows with useful gain and no clipping, below VON
    hs=np.zeros(len(vin)); ws=np.zeros(len(vin))
    for k in range(len(vcs)):
        if g[k]<0.03: continue
        ok=(out[k]>3.6)&(out[k]<11.0)&(vin<von[k]-0.12)
        hk=(vo0[k]-out[k])/g[k]
        hs[ok]+=g[k]**2*hk[ok]; ws[ok]+=g[k]**2
    have=ws>0
    h=np.interp(vin,vin[have],hs[have]/ws[have])
    # above the highest measured point (about 4.4 V) continue the slope
    last=vin[have][-1]; sl=(h[have][-1]-h[have][-20])/(vin[have][-1]-vin[have][-20])
    h=np.where(vin>last,h[have][-1]+sl*(vin-last),h)
    h_low=float(np.median(h[vin<0.0]))
    # low clip per control row: the lowest output below VON
    lo_raw=np.array([out[k][vin<von[k]-0.05].min() for k in range(len(vcs))])
    # W: the collapse, aligned per row where it reaches W_ALIGN (a point
    # every row with useful gain shows unclipped), shape from the rows with
    # moderate gain, which show all of it
    vonw=np.full(len(vcs),np.nan); wrow={}
    for k in range(len(vcs)):
        if g[k]<0.04: continue
        heff=(vo0[k]-out[k])/g[k]
        with np.errstate(divide="ignore",invalid="ignore"):
            w=np.nan_to_num((h-heff)/(h-h_low))
        ok=(vin>von[k]-0.1)&(out[k]>lo_raw[k]+0.05)&(out[k]<HI-0.05)
        j=np.nonzero(ok&(w>=W_ALIGN))[0]
        if not len(j): continue
        j=j[0]
        vonw[k]=vin[j-1]+(W_ALIGN-w[j-1])/(w[j]-w[j-1])*(vin[j]-vin[j-1])
        wrow[k]=w
    have=~np.isnan(vonw)
    off=np.mean((vonw-von)[have])
    vonw[~have]=von[~have]+off
    wsum=np.zeros(len(ua)); wn=np.zeros(len(ua))
    for k,w in wrow.items():
        if not (0.04<g[k]<0.4): continue
        wsum+=np.interp(ua,vin-vonw[k],w); wn+=1
    w=np.clip(wsum/wn,0,1)
    w[ua<-0.15]=0.0
    w=np.maximum.accumulate(w)
    lo=lo_raw.copy()
    # rows whose separable value never goes below their lowest output do not
    # clip: hold the last clipping row's level there
    for k in range(len(vcs)):
        sepmin=(vo0[k]-g[k]*h[vin<von[k]-0.05]).min()
        if sepmin>lo[k]-0.05 and k: lo[k]=min(lo[k-1],lo[k])
    # knee: the output against the separable value, both above LO
    sa=axis(S_GRID); ssum=np.zeros(len(sa)); sn=np.zeros(len(sa))
    for k in range(len(vcs)):
        if g[k]<0.3: continue
        ok=vin<von[k]-0.12
        sep=vo0[k]-g[k]*h
        x=(sep-lo[k])[ok]; y=(out[k]-lo[k])[ok]
        idx=np.round((x-S_GRID[0])/S_GRID[1]).astype(int)
        sel=(idx>=0)&(idx<len(sa))
        np.add.at(ssum,idx[sel],y[sel]); np.add.at(sn,idx[sel],1)
    have=sn>0
    sv=np.interp(sa,sa[have],ssum[have]/sn[have])
    sv[sa>=0.4-1e-9]=sa[sa>=0.4-1e-9]
    sv=np.maximum(sv,0.0)
    va=axis(VC_GRID); xa=axis(VIN_GRID)
    t={"vc_grid":VC_GRID,"s_grid":S_GRID,"s":sv.tolist(),"vin_grid":VIN_GRID,"u_grid":U_GRID,"hi":HI,"h_low":h_low,
       "g":np.interp(va,vcs,g).tolist(),"vo0":np.interp(va,vcs,vo0).tolist(),
       "lo":np.interp(va,vcs,lo).tolist(),"von":np.interp(va,vcs,von).tolist(),
       "vonw":np.interp(va,vcs,vonw).tolist(),
       "h":np.interp(xa,vin,h).tolist(),"ib":np.interp(xa,vin,ib).tolist(),
       "ic":ic.tolist(),"w":w.tolist(),
       "ic_slope":float((ic[-1]-ic[-11])/(ua[-1]-ua[-11]))}
    return t,(vin,vcs,out,iin)

def model(t,vin,vc):
    """Vectorised table model: returns (out, iin)."""
    vin=np.asarray(vin,dtype=float); vc=np.asarray(vc,dtype=float)
    g=interp(t["vc_grid"],t["g"],vc); vo0=interp(t["vc_grid"],t["vo0"],vc)
    lo=interp(t["vc_grid"],t["lo"],vc); von=interp(t["vc_grid"],t["von"],vc)
    h=interp(t["vin_grid"],t["h"],vin); u=vin-von
    w=interp(t["u_grid"],t["w"],vin-interp(t["vc_grid"],t["vonw"],vc))
    ic=interp(t["u_grid"],t["ic"],u)
    umax=t["u_grid"][0]+t["u_grid"][1]*(t["u_grid"][2]-1)
    ic=np.where(u>umax,t["ic"][-1]+t["ic_slope"]*(u-umax),ic)
    heff=h*(1-w)+t["h_low"]*w
    x=vo0-g*heff-lo
    smax=t["s_grid"][0]+t["s_grid"][1]*(t["s_grid"][2]-1)
    o=lo+np.where(x>=smax,x,interp(t["s_grid"],t["s"],x))
    o=np.minimum(o,t["hi"])
    return o,interp(t["vin_grid"],t["ib"],vin)+ic

def main():
    t,(vin,vcs,out,iin)=fit()
    (HERE/"data/mc3340_tables.json").write_text(json.dumps(t))
    V,C=np.meshgrid(vin,vcs)
    o,i=model(t,V,C)
    eo=abs(o-out); ei=abs(i-iin)
    sel=(V>-1.0)&(V<4.2)
    print(f"output error, input -1..4.2 V: max {eo[sel].max():.3f} V, rms {np.sqrt((eo[sel]**2).mean()):.4f} V")
    print(f"output error, all: max {eo.max():.3f} V, rms {np.sqrt((eo**2).mean()):.4f} V")
    print(f"input current error, input -1..4.2 V: max {ei[sel].max()*1e6:.2f} uA; all: max {ei.max()*1e6:.1f} uA, rms {np.sqrt((ei**2).mean())*1e6:.2f} uA")
    von=interp(t["vc_grid"],t["von"],C)
    band=(C<=6)&(V<=6)&(abs(V-interp(t["vc_grid"],t["vonw"],C))>0.05)
    print(f"Vc<=6, Vin<=6 more than 0.05 V from the collapse edge (VONW): output max {eo[band].max():.3f} V, "
          f"rms {np.sqrt((eo[band]**2).mean()):.4f} V; input current max {ei[(C<=6)&(V<=6)].max()*1e6:.0f} uA, "
          f"rms {np.sqrt((ei[(C<=6)&(V<=6)]**2).mean())*1e6:.1f} uA")
    k=np.unravel_index(np.argmax(eo*sel),eo.shape); print("worst out (in range) at vin",V[k],"vc",C[k],out[k],o[k])
    k=np.unravel_index(np.argmax(eo),eo.shape); print("worst out at vin",V[k],"vc",C[k],out[k],o[k])
    k=np.unravel_index(np.argmax(ei),ei.shape); print("worst iin at vin",V[k],"vc",C[k],iin[k],i[k])
    print("h_low",t["h_low"])

if __name__=="__main__": main()
