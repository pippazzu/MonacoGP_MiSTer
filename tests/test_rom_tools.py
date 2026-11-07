"""Transfer format checks, including rejection of a corrupted or incomplete set."""
# SPDX-License-Identifier: GPL-3.0-or-later
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
import xml.etree.ElementTree as ET
import zipfile
import zlib

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location("prepare_roms",ROOT/"scripts/prepare_roms.py")
prep=importlib.util.module_from_spec(spec)
spec.loader.exec_module(prep)

class RomTests(unittest.TestCase):
    def test_mra_order_and_checksums_match_memory_layout(self):
        m=json.loads(prep.MANIFEST.read_text())
        root=ET.fromstring(prep.mra_text(m))
        parts=root.find("rom[@index='0']").findall("part")
        crc={r["name"]:r["crc32"] for r in m["roms"]}
        self.assertEqual(sorted(crc),sorted(prep.MRA_ORDER))
        self.assertEqual([(n,crc[n]) for n in prep.MRA_ORDER],
                         [(p.attrib["name"],p.attrib["crc"]) for p in parts])
        self.assertEqual(root.find("rbf").text,"MonacoGP")
        self.assertEqual(root.find("nvram").attrib,{"index":"2","size":"514"})
        self.assertEqual((ROOT/"cores/monacogp/cfg/monacogp.mra").read_text(),prep.mra_text(m))
        # Main_MiSTer sends ROM data only from <part> elements.
        self.assertEqual([p.text for p in root.find("rom[@index='1']").findall("part")],["05 80"])
        self.assertEqual([r["offset"] for r in m["roms"]],list(range(0,8704,512))+[8704,8736,8768])

    def test_pro_mra(self):
        """#89: one RBF, two games. The Pro MRA differs from Monaco GP's only in
        its name, setname (its own NVRAM and DIP files), year, the hidden
        pro bit 15 in the switch default and the RAM RESET entry (bit 14)."""
        m=json.loads(prep.MANIFEST.read_text())
        mon=ET.fromstring(prep.mra_text(m))
        pro=ET.fromstring(prep.mra_text(m,pro=True))
        self.assertEqual((ROOT/"cores/monacogp/cfg/promonacogp.mra").read_text(),prep.mra_text(m,pro=True))
        self.assertEqual((pro.find("name").text,pro.find("setname").text,pro.find("year").text),
                         ("Pro Monaco GP","promonacogp","1980"))
        self.assertNotEqual(pro.find("setname").text,mon.find("setname").text)
        for tag in ("rbf","rotation","nvram"):
            self.assertEqual(ET.tostring(pro.find(tag)),ET.tostring(mon.find(tag)))
        self.assertEqual(ET.tostring(pro.find("rom[@index='0']")),ET.tostring(mon.find("rom[@index='0']")))
        self.assertEqual(ET.tostring(pro.find("rom[@index='1']")),ET.tostring(mon.find("rom[@index='1']")))
        # Monaco GP keeps pro = 0: bit 15 clear and no entry for bits 14/15
        sw_m,sw_p=mon.find("switches"),pro.find("switches")
        self.assertEqual(sw_m.attrib["default"],"00,00")
        self.assertEqual(sw_p.attrib["default"],"00,80")      # bit 15 = pro, bit 14 (RAM reset) Off
        bits_m=[d.attrib["bits"] for d in sw_m.findall("dip")]
        bits_p=[d.attrib["bits"] for d in sw_p.findall("dip")]
        self.assertEqual(bits_m,["0","8","9"])
        self.assertEqual(bits_p,["0","8","9","14"])            # bit 15 has no entry: not changeable
        self.assertEqual(sw_p.findall("dip")[-1].attrib["ids"],"Off,On")

    def test_osd_name_and_version(self):
        import sys
        sys.path.insert(0,str(ROOT/"scripts"))
        from mister_overlay import patch_cfgstr
        src=b"JTMONACOGP;;DIP;V,vabc1234\0\0\0\0"
        out=bytes(int(x,16) for x in patch_cfgstr(" ".join(f"{b:02X}" for b in src)).split())
        self.assertEqual(len(out),len(src))
        self.assertEqual(out.split(b"\0")[0],b"MonacoGP;;DIP;V,v1.0")

    def test_bad_archives_fail_without_producing_a_stream(self):
        blob=b"example"
        m={"total_bytes":7,"roms":[{"name":"test.bin","size":7,"offset":0,
                                  "crc32":f"{zlib.crc32(blob):08x}"}]}
        with tempfile.TemporaryDirectory() as tmp:
            path=Path(tmp)/"input.zip"
            for name,data in [("missing.bin",blob),("test.bin",b"bad"),("test.bin",b"examplf")]:
                with zipfile.ZipFile(path,"w") as z: z.writestr(name,data)
                with self.assertRaises(ValueError): prep.read_roms(path,m)
            with zipfile.ZipFile(path,"w") as z: z.writestr("test.bin",blob)
            self.assertEqual(prep.read_roms(path,m)[0],blob)

if __name__=="__main__": unittest.main()
