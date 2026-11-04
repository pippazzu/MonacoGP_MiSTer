#!/usr/bin/env python3
"""Fetch the pinned JTFRAME checkout and install this core into it."""
# SPDX-License-Identifier: GPL-3.0-or-later
import argparse
from pathlib import Path
import shutil
import subprocess

ROOT=Path(__file__).resolve().parents[1]
REV=(ROOT/"UPSTREAM_REVISION").read_text().strip()

def run(*args):
    subprocess.run(args,check=True)

def install(dest,update=False):
    actual=subprocess.check_output(["git","-C",str(dest),"rev-parse","HEAD"],text=True).strip()
    if actual!=REV:
        raise SystemExit(f"Expected pinned JTFRAME {REV}, found {actual}. Use a separate checkout.")
    target=dest/"cores/monacogp"
    if target.exists() and not update:
        raise SystemExit(f"{target} exists. Use --update to copy this package's source files over it.")
    shutil.copytree(ROOT/"cores/monacogp",target,dirs_exist_ok=update)
    print(f"Installed monacogp core at {target}")

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("destination",type=Path,nargs="?",default=ROOT/"build/jtcores")
    p.add_argument("--update",action="store_true",help="copy current package sources into an existing pinned checkout")
    args=p.parse_args()
    dest=args.destination.resolve()
    if not dest.exists():
        dest.mkdir(parents=True)
        run("git","-C",str(dest),"init")
        run("git","-C",str(dest),"remote","add","origin","https://github.com/jotego/jtcores.git")
        run("git","-C",str(dest),"fetch","--depth=1","--filter=blob:none","origin",REV)
        # Upstream's jtframe wrapper runs self-tests before its first build.
        # Those tests use these small existing module/core fixtures.
        run("git","-C",str(dest),"sparse-checkout","set","--skip-checks","modules/jtframe",
            "modules/jt12","modules/jt007232","cores/gng","cores/1942")
        run("git","-C",str(dest),"checkout","--detach","FETCH_HEAD")
        run("git","-C",str(dest),"submodule","update","--init","--depth=1","--","modules/jt12")
    install(dest,args.update)

if __name__=="__main__": main()
