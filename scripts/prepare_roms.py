#!/usr/bin/env python3
"""Verify the user's original PROM archive and construct the FPGA byte stream."""
# SPDX-License-Identifier: GPL-3.0-or-later
import argparse
import hashlib
import json
from pathlib import Path
import sys
import xml.etree.ElementTree as ET
import zipfile
import zlib

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "rom_manifest.json"

def read_roms(archive, manifest):
    stream = bytearray()
    report = []
    with zipfile.ZipFile(archive) as z:
        for r in manifest["roms"]:
            candidates = [n for n in z.namelist() if n == r["name"]]
            if len(candidates) != 1:
                raise ValueError(f"Expected exactly one original {r['name']}; found {len(candidates)}")
            blob = z.read(candidates[0])
            crc = f"{zlib.crc32(blob) & 0xffffffff:08x}"
            if len(blob) != r["size"] or crc != r["crc32"]:
                raise ValueError(f"{r['name']}: expected {r['size']} bytes / CRC {r['crc32']}; got {len(blob)} / {crc}")
            if len(stream) != r["offset"]:
                raise ValueError(f"Non-contiguous manifest offset for {r['name']}")
            stream.extend(blob)
            report.append(dict(r, sha256=hashlib.sha256(blob).hexdigest()))
    if len(stream) != manifest["total_bytes"]:
        raise ValueError("Manifest total does not match PROM lengths")
    return bytes(stream), report

CORE_MOD="05 80"
CORE_MOD_NOTE=(" core_mod: bit 0 vertical screen; bit 2 set: JTFRAME XORs it with\n"
               "       dip_flip (high while OSD Flip screen is Off) to choose the frame\n"
               "       buffer's direction, so set it turns the picture clockwise while the\n"
               "       flip is off, as the cabinet's monitor is turned ")

SWITCHES_NOTE=""" The boards' setting switches (OSD "DIP Switches"), 0 = the default:
       bit 0, sheet A's changeover switch; bit 8, DIP SW. 2's contact that
       sends the back sound (D-2, R424) into the front speaker's mix;
       bit 9, DIP SW. 2 contact 2-15 (R423, a louder explosion).
       jtmonacogp_game.v reads them from dipsw. """
SWITCHES=[("Coin, play","0","1 coin 1 play,1 coin 2 plays"),
          ("Back sound in front mix","8","On,Off"),
          ("Louder explosion","9","Off,On")]

# Pro Monaco GP (#89): the same RBF and PROM set; the MRA sets dipsw[15]
# (pro, jtmonacogp_game.v) in its switch default and gives it no <dip>
# entry, so the OSD cannot change it. JTFRAME does not pass core_mod to the
# game, so a hidden DIP bit is the per-MRA setting. Its own setname keeps its
# NVRAM (high scores) and DIP files apart from Monaco GP's. The Pro board's
# RAM RESET switch (sheet I, SW.1) is dipsw[14], on this DIP page only.
PRO_SWITCHES_NOTE=""" The boards' setting switches (OSD "DIP Switches"), 0 = the default:
       bit 0, sheet A's changeover switch; bit 8, DIP SW. 2's contact that
       sends the back sound (D-2, R424) into the front speaker's mix;
       bit 9, DIP SW. 2 contact 2-15 (R423, a louder explosion);
       bit 14, the Pro board's RAM RESET switch (sheet I, SW.1): On holds it
       closed and clears the score memory (all 256 slots to 0000), then set
       it back to Off; bit 15, set and not shown: the Pro board (pro in
       jtmonacogp_game.v). jtmonacogp_game.v reads them from dipsw. """
PRO_SWITCHES=SWITCHES+[("RAM reset (board switch)","14","Off,On")]

MRA_ORDER=["pra125.ic59","pra126.ic65","pra131.ic71","pra127.ic77","pra128.ic84","pra129.ic91",
           "pra130.ic98","pra132.ic111","prm39.ic105","prm38.ic115","pra140.ic12","pra141.ic17",
           "pra138.ic30","pra139.ic51","pra133.ic64","pra136.ic99","pra135.ic106","pra134.ic113",
           "pra137.ic120","prm40.ic21"]

def mra_text(manifest, pro=False):
    """Monaco GP's MRA, or with pro the Pro Monaco GP one (same RBF and PROMs)."""
    root = ET.Element("misterromdescription")
    for key,value in [
        ("name","Pro Monaco GP" if pro else "Monaco GP"),
        ("setname","promonacogp" if pro else "monacogp"), ("rbf","MonacoGP"),
        ("year","1980" if pro else "1979"), ("manufacturer","Sega"),
        ("category","Racing"),
        ("rotation","vertical (cw)"),
    ]:
        ET.SubElement(root,key).text=value
    ET.SubElement(root,"buttons",names="Accelerate,Gear,Scoreboard,Start,Coin",default="A,B,Y,Start,Select")
    rom=ET.SubElement(root,"rom",index="0",zip="monacogp.zip",md5="None")
    # mem.yaml's order (rom00..rom19), which is what the core loads
    by_name={r["name"]:r for r in manifest["roms"]}
    for name in MRA_ORDER:
        ET.SubElement(rom,"part",name=name,crc=by_name[name]["crc32"])
    # core_mod as JTFRAME's MRA tool writes it (src/jtframe/mra/core_mod.go):
    # byte 0 = 05 (bit 0 vertical; bit 2, see the comment written below);
    # byte 1 = 80, unity volume. Main_MiSTer sends only <part> data, so the
    # bytes go in a part.
    root.append(ET.Comment(CORE_MOD_NOTE))
    ET.SubElement(ET.SubElement(root,"rom",index="1"),"part").text=CORE_MOD
    # the boards' setting switches: MiSTer's "DIP Switches" page
    root.append(ET.Comment(PRO_SWITCHES_NOTE if pro else SWITCHES_NOTE))
    sw=ET.SubElement(root,"switches",default="00,80" if pro else "00,00",base="16",page_id="1",page_name="Switches")
    for name,bits,ids in (PRO_SWITCHES if pro else SWITCHES):
        ET.SubElement(sw,"dip",name=name,bits=bits,ids=ids)
    # the high scores' file, as JTFRAME_IOCTL_RD in macros.def
    ET.SubElement(root,"nvram",index="2",size="514")
    ET.indent(root,space="  ")
    return '<?xml version="1.0" encoding="utf-8"?>\n'+ET.tostring(root,encoding="unicode")+'\n'

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("archive",type=Path)
    p.add_argument("--out",type=Path,default=ROOT/"build"/"roms")
    p.add_argument("--write-mra",type=Path)
    p.add_argument("--write-pro-mra",type=Path,help="also write the Pro Monaco GP MRA (#89)")
    args=p.parse_args()
    manifest=json.loads(MANIFEST.read_text())
    try:
        stream,report=read_roms(args.archive,manifest)
    except (ValueError,zipfile.BadZipFile,KeyError,OSError) as e:
        p.exit(1,f"ROM verification failed: {e}\n")
    args.out.mkdir(parents=True,exist_ok=True)
    (args.out/"proms.bin").write_bytes(stream)
    (args.out/"proms.hex").write_text("".join(f"{v:02x}\n" for v in stream))
    (args.out/"verification.json").write_text(json.dumps({
        "total_bytes":len(stream),"sha256":hashlib.sha256(stream).hexdigest(),"roms":report
    },indent=2)+"\n")
    if args.write_mra:
        args.write_mra.parent.mkdir(parents=True,exist_ok=True)
        args.write_mra.write_text(mra_text(manifest))
    if args.write_pro_mra:
        args.write_pro_mra.parent.mkdir(parents=True,exist_ok=True)
        args.write_pro_mra.write_text(mra_text(manifest,pro=True))
    print(f"PASS ROM archive: {len(report)} original PROMs, {len(stream)} bytes; sizes and CRC32 match")

if __name__=="__main__":
    main()
