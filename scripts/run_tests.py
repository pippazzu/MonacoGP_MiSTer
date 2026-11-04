#!/usr/bin/env python3
"""Run ROM, pin-connected TTL, enable, and JTFRAME-interface simulations."""
# SPDX-License-Identifier: GPL-3.0-or-later
import argparse
import hashlib
import json
from pathlib import Path
import os
import random
import shutil
import subprocess
import sys
import threading
from concurrent.futures import ThreadPoolExecutor

ROOT=Path(__file__).resolve().parents[1]
SYNTHETIC_SEED=0x4d4f4e41
SIM_TIMEOUT=3600   # seconds per simulation; the longest, the sheet F control run, takes about 37 minutes
# The connected sheets (tb_play, 79 frames) run close to the hour even
# without sheets I, J and K (56-58 minutes alone on the cloud machine; with
# them, 77 minutes beside three other test groups, 2 November), and with the
# whole sound board (tb_play_sound) about 65-85 minutes since the other cars
# (D-6/D-7) are in; they get their own guard against a hung simulation.
SIM_TIMEOUT_LONG={"play":7200,"play_sound":7200}

def write_synthetic(path):
    """Deterministic pseudo-random 8,800-byte image. NOT original PROM data."""
    rng=random.Random(SYNTHETIC_SEED)
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text("".join(f"{rng.randrange(256):02x}\n" for _ in range(8800)))

def describe_rom(path,synthetic):
    """Returns the provenance line and whether the image is the verified original set."""
    data=bytes(int(line,16) for line in path.read_text().split())
    digest=hashlib.sha256(data).hexdigest()
    if synthetic:
        return f"PROM image: SYNTHETIC pseudo-random data (seed {SYNTHETIC_SEED:#x}), sha256 {digest}. Not original PROM contents.\n",False
    report=path.parent/"verification.json"
    if report.is_file() and json.loads(report.read_text()).get("sha256")==digest:
        return f"PROM image: original set verified by prepare_roms.py, sha256 {digest}.\n",True
    return f"PROM image: {path}, sha256 {digest}; NOT verified against the original archive.\n",False

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--jtroot",type=Path,default=ROOT/"build/jtcores")
    p.add_argument("--rom",type=Path,default=ROOT/"build/roms/proms.hex")
    p.add_argument("--synthetic",action="store_true",
                   help="use a generated pseudo-random image instead of the original PROMs")
    p.add_argument("--jobs",type=int,default=1,
                   help="parallel independent test groups; related cases sharing outputs stay sequential")
    args=p.parse_args()
    if args.jobs<1: p.error("--jobs must be positive")
    if args.synthetic:
        args.rom=ROOT/"build/synthetic/proms.hex"
        write_synthetic(args.rom)
    include=args.jtroot.resolve()/"modules/jtframe/hdl/inc"
    if not (include/"jtframe_game_ports.inc").is_file():
        p.error("JTFRAME includes unavailable; run scripts/setup_jtframe.py first")
    if not args.rom.is_file():
        p.error("PROM image unavailable; run scripts/prepare_roms.py first, or pass --synthetic")
    iv=os.environ.get("IVERILOG","iverilog")
    vvp=os.environ.get("VVP","vvp")
    for exe in (iv,vvp):
        if shutil.which(exe) is None: p.error(f"Executable unavailable: {exe}")
    build=ROOT/"build/tests"
    build.mkdir(parents=True,exist_ok=True)
    hdl=ROOT/"cores/monacogp/hdl"
    fix=ROOT/"tests/fixtures"
    jt=args.jtroot.resolve()/"modules/jtframe/hdl"
    mem=[jt/"sdram/jtframe_dwnld.v",jt/"sdram/jtframe_ioctl_range.v",jt/"ram/jtframe_prom.v",
         jt/"ram/jtframe_dual_ram16.v",jt/"ram/jtframe_dual_ram.v"]
    provenance,original=describe_rom(args.rom,args.synthetic)
    lines=[provenance]
    log_lock=threading.Lock()
    print(lines[0],end="")
    def run(cmd,timeout=None):
        try:
            result=subprocess.run([str(c) for c in cmd],cwd=ROOT,stdout=subprocess.PIPE,
                                  stderr=subprocess.STDOUT,text=True,timeout=timeout)
        except subprocess.TimeoutExpired as e:
            out=(e.stdout or b"")
            out=out.decode() if isinstance(out,bytes) else out
            with log_lock:
                lines.append(out+f"FAIL: {cmd[0]} {cmd[1]} did not finish within {timeout} s\n")
                print(lines[-1],end="",flush=True)
                (build/"results.txt").write_text("".join(lines))
            raise SystemExit(1)
        with log_lock:
            print(result.stdout,end="",flush=True)
            lines.append(result.stdout)
            (build/"results.txt").write_text("".join(lines))
        if result.returncode:
            raise SystemExit(result.returncode)
    run([sys.executable,"-m","unittest","discover","-s","tests","-p","test_*.py"])
    ivdir=str(Path(shutil.which(iv)).parent)
    run([sys.executable,ROOT/"scripts/test_prom_download.py",args.jtroot.resolve()/"modules/jtframe",ivdir])
    run([sys.executable,ROOT/"scripts/test_hps_trigger.py",args.jtroot.resolve()/"modules/jtframe",ivdir])
    ivbase=[iv]
    if os.environ.get("IVL_BASE"): ivbase += ["-B",os.environ["IVL_BASE"]]
    cases=[
        ("gtest_trigger",[hdl/"jtmonacogp_gtest.v"]),
        ("timing",[ROOT/"tests/sheet_e_reference.v",hdl/"jtmonacogp_timing.v"]),
        ("cen",[fix/"jtmonacogp_cen.v"]),
        ("proms",[fix/"jtmonacogp_proms.v"]),
        ("game",sorted(hdl.glob("*.v"))+mem),
        # The connected sheets (display 5) from power-up to the end of a
        # game, one-shots / 1000 and the 555 / 100, without the sound board
        # and without sheets I (rank part), J and K; about 56 minutes on the
        # cloud machine of 2 November 2026, close to the one-hour limit.
        ("play",sorted(hdl.glob("*.v"))+mem),
        # Sheet G player-car path against the pin-wired reference; about twelve
        # minutes in Icarus.
        ("player",[ROOT/"tests/sheet_g_reference.v",hdl/"jtmonacogp_player.v",
                   hdl/"jtmonacogp_ptest.v",fix/"jtmonacogp_proms.v",
                   fix/"jtmonacogp_cen.v",hdl/"jtmonacogp_timing.v"]),
        # Sheet F control logic against the pin-wired reference: the short
        # run (one-shot capacitors / 1000) first, then the circuit as drawn
        # in two runs (accelerate, slip and pool; crash and return), each
        # well under the time limit.
        ("control_fast",[ROOT/"tests/tb_control.v",ROOT/"tests/sheet_f_reference.v",
                         hdl/"jtmonacogp_control.v",fix/"jtmonacogp_cen.v",
                         hdl/"jtmonacogp_timing.v"]),
        ("control",[ROOT/"tests/sheet_f_reference.v",hdl/"jtmonacogp_control.v",
                    fix/"jtmonacogp_cen.v",hdl/"jtmonacogp_timing.v"]),
        ("control_crash",[ROOT/"tests/tb_control.v",ROOT/"tests/sheet_f_reference.v",
                          hdl/"jtmonacogp_control.v",fix/"jtmonacogp_cen.v",
                          hdl/"jtmonacogp_timing.v"]),
        # Sheet B road-motion counters and text against the pin-wired
        # reference, in two runs of about 20 and 14 minutes: the four text
        # messages and the counters swinging between the IC69 windows, then
        # random inputs.
        ("motion",[ROOT/"tests/sheet_b_reference.v",hdl/"jtmonacogp_motion.v",
                   fix/"jtmonacogp_proms.v",fix/"jtmonacogp_cen.v",hdl/"jtmonacogp_timing.v"]),
        ("motion_random",[ROOT/"tests/tb_motion.v",ROOT/"tests/sheet_b_reference.v",
                          hdl/"jtmonacogp_motion.v",fix/"jtmonacogp_proms.v",
                          fix/"jtmonacogp_cen.v",hdl/"jtmonacogp_timing.v"]),
    ]
    # Sheet D scenery logic against the pin-wired reference, on the sheet B
    # RTL's counters: the real MH drift (with pictures), a fast MH stimulus
    # that runs IC49 through its count, and the other readings of IC66 and
    # IC90. About 7, 7, 4, 2 and 2 minutes.
    scenery=[ROOT/"tests/tb_scenery.v",ROOT/"tests/sheet_d_reference.v",hdl/"jtmonacogp_scenery.v",
             hdl/"jtmonacogp_motion.v",fix/"jtmonacogp_proms.v",fix/"jtmonacogp_cen.v",
             hdl/"jtmonacogp_timing.v"]
    cases += [("scenery",scenery[1:]),("scenery_fast",scenery),("scenery_ic66nand",scenery),
              ("scenery_ic90a",scenery),("scenery_ic90b",scenery)]
    # Sheet A coin, timer and extended-play logic against the pin-wired
    # reference: capacitors / 1000 through every stage, then the circuit as
    # drawn for 100 frames (first 555 periods, one full IC49 pulse). About 4
    # and 8 minutes.
    coin=[ROOT/"tests/tb_coin.v",ROOT/"tests/sheet_a_reference.v",hdl/"jtmonacogp_coin.v",
          fix/"jtmonacogp_cen.v",hdl/"jtmonacogp_timing.v"]
    cases += [("coin",coin[1:]),("coin_full",coin)]
    # Sheet H other cars, frame counter and divider against the pin-wired
    # reference: one-shot capacitors / 1000 for 40 frames (pictures), then the
    # one-shots as drawn for 200 frames. About 6 and 30 minutes.
    cars=[ROOT/"tests/tb_cars.v",ROOT/"tests/sheet_h_reference.v",hdl/"jtmonacogp_cars.v",
          fix/"jtmonacogp_proms.v",fix/"jtmonacogp_cen.v",hdl/"jtmonacogp_timing.v"]
    cases += [("cars",cars[1:]),("cars_full",cars)]
    # Sheet M rescue car, signs, lives and bridge against the pin-wired
    # reference: IC18's capacitor / 1000 for 30 frames (pictures), then as
    # drawn for 60 frames. About 4 and 8 minutes.
    rescue=[ROOT/"tests/tb_rescue.v",ROOT/"tests/sheet_m_reference.v",hdl/"jtmonacogp_rescue.v",
            fix/"jtmonacogp_proms.v",fix/"jtmonacogp_cen.v",hdl/"jtmonacogp_timing.v"]
    cases += [("rescue",rescue[1:]),("rescue_full",rescue)]
    # Sheet C colour mixing against the pin-wired reference: 400,000 pixels of
    # random lines, both halves of 7M. Under a minute.
    cases += [("colour",[ROOT/"tests/sheet_c_reference.v",hdl/"jtmonacogp_colour.v"])]
    # The OSD 180-degree flip (frame buffers), on the real raster: 6 frames.
    cases += [("flip",[hdl/"jtmonacogp_flip.v",hdl/"jtmonacogp_timing.v",jt/"ram/jtframe_dual_ram16.v",jt/"ram/jtframe_dual_ram.v"])]
    # Sheet G headlight, explosion and splash paths against the pin-wired
    # reference (its gate models come from sheet_g_reference.v): 40 frames.
    # Sheet I score counter against the pin-wired reference: 3,000,000 pixels
    # of score pulses and resets, runs up to 9999.
    cases += [("score",[ROOT/"tests/sheet_i_score_reference.v",hdl/"jtmonacogp_score.v",
                        fix/"jtmonacogp_cen.v"])]
    # Handle board 96599 against the pin-wired reference (C4 integrated in
    # real time): 2,000,000 pixels of a virtual disc turning both ways.
    # Sheet I high-score memory and ranking with sheet K's rank latches,
    # against the pin-wired references (docs/SHEET_I_LOGIC.md): four games
    # with whole 1.43 s searches; three games with 7H's DOWN as drawn; three
    # games with a coin during the last search. Sheet J's display scan
    # against its reference: 40 frames of random inputs.
    rank=[ROOT/"tests/tb_rank.v",ROOT/"tests/sheet_i_score_reference.v",
          ROOT/"tests/sheet_i_rank_reference.v",ROOT/"tests/sheet_k_reference.v",
          hdl/"jtmonacogp_score.v",hdl/"jtmonacogp_rank.v",hdl/"jtmonacogp_ranks.v"]
    # The same memory across restarts, with its NVRAM file (not original
    # circuitry), and the file through JTFRAME's own modules.
    cases += [("rank_keep",[hdl/"jtmonacogp_score.v",hdl/"jtmonacogp_rank.v",hdl/"jtmonacogp_ranks.v"]),
              ("score_ioctl",[jt/"ram/jtframe_ioctl_dump.v",jt/"ram/jtframe_ram16.v",jt/"ram/jtframe_ram.v"])]
    cases += [("rank",rank[1:]),("rank_drawn",rank),("rank_early",rank),
              ("leds",[ROOT/"tests/sheet_j_reference.v",hdl/"jtmonacogp_leds.v"])]
    cases += [("handle",[ROOT/"tests/handle_reference.v",hdl/"jtmonacogp_handle.v",
                         fix/"jtmonacogp_cen.v"])]
    cases += [("effects",[ROOT/"tests/sheet_g_reference.v",ROOT/"tests/sheet_g_effects_reference.v",
                          hdl/"jtmonacogp_effects.v",fix/"jtmonacogp_cen.v"])]
    # Sound board (docs/SOUND_LOGIC.md). D-3 (the engine) for 3 s from
    # power-on, the scenario of the SPICE reference, about 22 minutes; the
    # D-4 sources (noise, explosion, skid tone, EXTEND beep) for their 2 s
    # SPICE scenario, about 30 minutes; the other cars (D-6/D-7) for their
    # 3 s SPICE scenario under Verilator (Icarus would take over two hours),
    # a few minutes; the rescue siren and back sound (D-2) for its 6 s SPICE
    # scenario under Verilator, a few minutes; the slip-zone sound (D-1) for
    # its 3 s SPICE scenario under Verilator, a few minutes; the hi-score
    # tune (D-5) for its 3 s SPICE scenario under Verilator, with the
    # reference's settings (D5_REF, the include written into the build
    # directory), a few minutes; the sound top (gates, D-3, D-4, other cars,
    # D-2, D-1, D-5, mixer, SOUND OUT and BACK SOUND OUT) for 0.3 s and all
    # 32 gate-input combinations; the connected
    # sheets with the sound board from power-up into a game.
    # Checked after the simulations by tests/sound/*_check.py against the
    # fixed-point twins and the stored SPICE features.
    snd=[hdl/"jtmonacogp_snd_noise.v",hdl/"jtmonacogp_snd_band.v",hdl/"jtmonacogp_snd_expl.v"]
    d67=[hdl/"jtmonacogp_snd_d67.v",hdl/"jtmonacogp_snd_d7ctl.v",hdl/"jtmonacogp_snd_d6bank.v",
         hdl/"jtmonacogp_snd_d7car.v",hdl/"jtmonacogp_snd_mc3340.v"]
    d2=[hdl/"jtmonacogp_snd_d2.v",hdl/"jtmonacogp_snd_d2vco.v"]
    d1=[hdl/"jtmonacogp_snd_d1.v"]
    d5=[hdl/"jtmonacogp_snd_d5.v"]
    run([sys.executable,ROOT/"tests/sound/d4_verilog_check.py","stim",build])
    run([sys.executable,ROOT/"tests/sound/d67_verilog_check.py","stim",build])
    verilator=os.environ.get("VERILATOR","verilator")
    if shutil.which(verilator) is None: p.error(f"Executable unavailable: {verilator}")
    vdir=build/"snd_d67_obj"
    run([verilator,"--binary","--timing","-O3","-Wno-fatal","-Wno-lint","-Wno-WIDTH","-j","2",
         "-I"+str(hdl),"-Mdir",vdir,"--top-module","tb_snd_d67",ROOT/"tests/tb_snd_d67.v"]+d67,
        timeout=SIM_TIMEOUT)
    run([vdir/"Vtb_snd_d67",f"+OUT={build}"],timeout=SIM_TIMEOUT)
    run([sys.executable,ROOT/"tests/sound/d2_verilog_check.py","stim",build])
    vdir=build/"snd_d2_obj"
    run([verilator,"--binary","--timing","-O3","-Wno-fatal","-Wno-lint","-Wno-WIDTH","-j","2",
         "-I"+str(hdl),"-Mdir",vdir,"--top-module","tb_snd_d2",ROOT/"tests/tb_snd_d2.v"]+d2+
        [hdl/"jtmonacogp_snd_mc3340.v"],timeout=SIM_TIMEOUT)
    run([vdir/"Vtb_snd_d2",f"+OUT={build}"],timeout=SIM_TIMEOUT)
    run([sys.executable,ROOT/"tests/sound/d1_verilog_check.py","stim",build])
    vdir=build/"snd_d1_obj"
    run([verilator,"--binary","--timing","-O3","-Wno-fatal","-Wno-lint","-Wno-WIDTH","-j","2",
         "-I"+str(hdl),"-Mdir",vdir,"--top-module","tb_snd_d1",ROOT/"tests/tb_snd_d1.v"]+d1,
        timeout=SIM_TIMEOUT)
    run([vdir/"Vtb_snd_d1",f"+OUT={build}"],timeout=SIM_TIMEOUT)
    run([sys.executable,ROOT/"tests/sound/d5_verilog_check.py","stim",build])
    vdir=build/"snd_d5_obj"
    run([verilator,"--binary","--timing","-O3","-Wno-fatal","-Wno-lint","-Wno-WIDTH","-j","2",
         "-DD5_REF","-I"+str(build/"d5ref"),"-I"+str(hdl),"-Mdir",vdir,"--top-module","tb_snd_d5",
         ROOT/"tests/tb_snd_d5.v"]+d5,timeout=SIM_TIMEOUT)
    run([vdir/"Vtb_snd_d5",f"+OUT={build}",f"+ROM={args.rom.resolve()}"],timeout=SIM_TIMEOUT)
    cases += [("snd_d3",[hdl/"jtmonacogp_snd_d3.v"]),
              ("snd_d4",snd),
              ("sound",[hdl/"jtmonacogp_sound.v",hdl/"jtmonacogp_snd_d3.v",hdl/"jtmonacogp_snd_mix.v"]+snd+d67+d2+d1+d5),
              ("play_sound",sorted(hdl.glob("*.v"))+mem)]
    # The MiSTer build has two sound channels (JTFRAME_STEREO); the game-level
    # sound test runs that way, the other game tests with the mono port.
    stereo={"play_sound"}
    def run_case(name,sources):
        exe=build/(name+".vvp")
        run(ivbase+["-g2012","-Wall","-Wno-timescale","-I",include,"-I",hdl,"-I",fix,"-DJTFRAME_MEMGEN","-DJTFRAME_PXLCLK=8",
                    "-DJTFRAME_BUTTONS=2","-DJTFRAME_COLORW=4","-DMONACOGP_DEVVIEWS"]+
                   (["-DJTFRAME_STEREO"] if name in stereo else [])+["-s","tb_"+name,
                    "-o",exe,ROOT/"tests"/("tb_"+name+".v")]+sources)
        # A simulation that stops advancing time would otherwise run forever.
        run([vvp,exe,f"+ROM={args.rom.resolve()}",f"+OUT={build}"],
            timeout=SIM_TIMEOUT_LONG.get(name,SIM_TIMEOUT))
    if args.jobs==1:
        for name,sources in cases: run_case(name,sources)
    else:
        # These families share screenshot names or include the same stimulus
        # bench. Keep each family's original order and every original check.
        families=("control","motion","scenery","coin","cars","rescue","rank")
        groups={}
        for name,sources in cases:
            family=next((f for f in families if name==f or name.startswith(f+"_")),name)
            groups.setdefault(family,[]).append((name,sources))
        def run_group(group):
            for name,sources in group: run_case(name,sources)
        with ThreadPoolExecutor(max_workers=args.jobs) as pool:
            futures=[pool.submit(run_group,group) for group in groups.values()]
            for future in futures: future.result()
    sound=ROOT/"tests/sound"
    run([sys.executable,sound/"d3_verilog_check.py",build])
    run([sys.executable,sound/"d4_verilog_check.py","check",build])
    run([sys.executable,sound/"d67_verilog_check.py","check",build])
    run([sys.executable,sound/"d2_verilog_check.py","check",build])
    run([sys.executable,sound/"d1_verilog_check.py","check",build])
    # the SPICE reference of D-5 was made with the original PROM
    run([sys.executable,sound/"d5_verilog_check.py","check",build,args.rom.resolve()]+
        ([] if original else ["nospice"]))
    run([sys.executable,sound/"sound_check.py",build,"sound",args.rom.resolve()])
    run([sys.executable,sound/"sound_check.py",build,"play_sound",args.rom.resolve()])
    # Artwork and raster checks read the PROM bytes through prepare_roms.py's
    # offsets, so they apply to the verified original set only.
    if original:
        proms_bin=args.rom.parent/"proms.bin"
        run([sys.executable,ROOT/"scripts/player_image_checks.py",proms_bin,
             build/"player-image-checks.txt"])
        run([sys.executable,ROOT/"scripts/player_raster_check.py",proms_bin,
             build/"player-frames.txt",build/"player-raster-check.txt"])
    else:
        note="Sheet G artwork and raster checks skipped: they need the verified original PROM set.\n"
        print(note,end="")
        lines.append(note)
    (build/"results.txt").write_text("".join(lines))
    print(f"All simulation checks passed. Logs and PPM screenshots: {build}")

if __name__=="__main__": main()
