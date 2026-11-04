#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Full MiSTer compile on Windows (Git Bash) with a local Quartus 17.0 Lite, the
# version MiSTer's own template is made for, instead of the jtcore20 Docker
# image (scripts/build_mister_docker.sh). Needs Go (the jtframe tool) and
# Python; first install the core with scripts/setup_jtframe.py --update.
# Two Windows workarounds, both outside the core's sources:
# - PATH entries must be in /c/... form: jtcore appends $JTFRAME/bin, and a
#   C:/... entry splits at the colon, so the tool folder is added here too;
# - the jtframe tool writes the file list (files.qip) with backslashes, which
#   Quartus's Tcl reader drops; jtcore's own compile therefore stops at
#   "sys_top is undefined", and the list is rewritten with forward slashes
#   and compiled again here.
# Usage: bash scripts/build_mister_windows.sh [/path/to/pinned/jtcores]
# Environment: QUARTUS_BIN (default /c/intelFPGA_lite/17.0/quartus/bin64),
#              GO_BIN (default: go on PATH),
#              SEED (fitter seed, default 1): MiSTer's own HDMI scaler and OSD
#              paths have little margin, and a fit that misses them by a
#              fraction of a nanosecond usually meets them with another seed.
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
JTPOSIX=$(cd "${1:-$ROOT/build/jtcores}" && pwd)
QUARTUS_BIN=${QUARTUS_BIN:-/c/intelFPGA_lite/17.0/quartus/bin64}
[ -n "$GO_BIN" ] && PATH=$GO_BIN:$PATH
[ -x "$QUARTUS_BIN/quartus_sh.exe" ] || { echo "quartus_sh not found in $QUARTUS_BIN" >&2; exit 1; }
# Paths handed to Quartus and the jtframe tool: C:/... form
export JTROOT=$(cygpath -m "$JTPOSIX")
export JTFRAME=$JTROOT/modules/jtframe MODULES=$JTROOT/modules CORES=$JTROOT/cores TARGET=mister
export PATH=$QUARTUS_BIN:$JTPOSIX/modules/jtframe/bin:$PATH
export GOFLAGS=-mod=mod
# The jtframe wrapper rebuilds the tool (and runs its Go tests) when the binary
# is missing; build it once without the tests.
EXE=$JTPOSIX/modules/jtframe/src/jtframe/jtframe.exe
if [ ! -e "$EXE" ]; then
    (cd "$JTPOSIX/modules/jtframe/src/jtframe" && go build -o jtframe.exe .)
    git -C "$JTPOSIX/modules/jtframe" checkout -- src/jtframe/go.mod src/jtframe/go.sum 2>/dev/null || true
fi
touch "$EXE"
PRJ=$JTPOSIX/cores/monacogp/mister
LOG=$JTPOSIX/log/mister/jtmonacogp.log
# Project generation (macros, templates, file list); its compile fails, see above
(cd "$JTPOSIX" && bash modules/jtframe/bin/jtcore monacogp -mister --nolinter) || true
[ -e "$PRJ/files.qip" ] || { echo "project generation failed, see $LOG" >&2; exit 1; }
python - "$PRJ" "${SEED:-1}" <<'EOF'
import pathlib, re, sys
for f in pathlib.Path(sys.argv[1]).glob("*.q[si][fp]"):
    t = f.read_text(encoding="utf-8")
    t2 = t.replace(chr(92), "/")
    if f.suffix == ".qsf":
        t2 = re.sub(r"(?m)^set_global_assignment -name seed \d+$",
                    "set_global_assignment -name seed " + sys.argv[2], t2)
    if t2 != t: f.write_text(t2, encoding="utf-8")
EOF
# Analog triggers (MiSTer Main's UIO_ATRIG): a patched copy of the pinned hps_io
python "$ROOT/scripts/mister_overlay.py" "$(cygpath -m "$PRJ")" "$JTFRAME"
cd "$PRJ"
rm -rf db incremental_db output_files
quartus_sh --flow compile jtmonacogp > "$LOG" 2>&1 || true
grep -q "Full Compilation was successful" "$LOG" || { grep -m 20 "^Error" "$LOG"; echo FAIL; exit 1; }
grep "Worst-case.*slack" "$LOG"
if grep "Worst-case.*slack is -" "$LOG"; then echo "FAIL: negative slack"; exit 1; fi
OUT=$ROOT/build/release/$(date +%Y%m%d)
mkdir -p "$OUT"
cp output_files/jtmonacogp.rbf "$OUT/MonacoGP_$(date +%Y%m%d).rbf"
cp "$ROOT/cores/monacogp/cfg/monacogp.mra" "$OUT/Monaco GP.mra"
echo "PASS: $OUT"
