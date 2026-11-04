#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Run upstream's own per-core Verilator lint (modules/jtframe/bin/lint-one.sh).
# The pinned JTFRAME passes --quiet-stats, which needs Verilator >= 5.050-era
# releases; its installer (bin/install/jotego_20.04.sh) checks out v5.050.
# Also needs envsubst (gettext-base). Set VERILATOR to a 5.050 binary if needed.
set -e
if [ "$#" -ne 1 ]; then
    echo "Usage: bash scripts/lint_upstream.sh /path/to/pinned/jtcores" >&2
    exit 2
fi
if [ -n "$VERILATOR" ]; then export PATH="$(dirname "$VERILATOR"):$PATH"; fi
verilator --version
command -v envsubst >/dev/null || { echo "envsubst missing (install gettext-base)" >&2; exit 1; }
export JTROOT=$(realpath "$1")
source "$JTROOT/modules/jtframe/bin/setprj.sh" >/dev/null
cd "$JTROOT"
bash modules/jtframe/bin/lint-one.sh monacogp
echo "PASS upstream lint-one.sh monacogp"
