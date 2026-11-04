#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# A real Quartus installation and the JTFRAME build dependencies are required.
set -e
if [ "$#" -ne 1 ]; then
    echo "Usage: bash scripts/build_mister.sh /path/to/pinned/jtcores" >&2
    exit 2
fi
export JTROOT
JTROOT=$(realpath "$1")
export JTFRAME="$JTROOT/modules/jtframe"
export CORES="$JTROOT/cores"
export MODULES="$JTROOT/modules"
export JTBIN="$JTROOT/release"
export ROM="$JTROOT/rom"
export MRA="$JTROOT/release/mra"
export PATH="$JTFRAME/bin:$PATH"
if ! command -v quartus_sh >/dev/null 2>&1 && [ ! -d /opt/intelFPGA_lite ]; then
    echo "Quartus is not installed. Simulation uses scripts/run_tests.py instead." >&2
    exit 1
fi
mkdir -p "$JTBIN" "$ROM" "$MRA" "$JTROOT/log/mister"
exec "$JTFRAME/bin/jtcore" monacogp -mister
