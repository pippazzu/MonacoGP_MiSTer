#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Full MiSTer compile in upstream's own Quartus 20.1 container (jotego/jtcore20),
# the image JTCORES' q20.yaml workflow uses. Like that workflow, the Verilator
# lint is run separately (scripts/lint_upstream.sh) and skipped here.
set -e
if [ "$#" -ne 1 ]; then
    echo "Usage: bash scripts/build_mister_docker.sh /path/to/pinned/jtcores" >&2
    exit 2
fi
JTROOT=$(realpath "$1")
GOBIN=$(command -v go || true)
# Pre-build the jtframe tool on the host so the container does not need network
# access to the Go module proxy. A static binary runs inside the image.
(cd "$JTROOT/modules/jtframe/src/jtframe" && CGO_ENABLED=0 go build .)
# --network host: on 2026-10-16 quartus_map crashed at start-up (segmentation
# fault in realloc, also on a one-gate project) inside Docker's default bridge
# network on the cloud VM used here, and ran normally with the host's network.
docker run --rm --network host -v "$JTROOT":/jtcores --entrypoint /bin/bash jotego/jtcore20 -c '
    git config --global --add safe.directory /jtcores
    cd /jtcores
    source modules/jtframe/bin/setprj.sh >/dev/null
    export PATH=$PATH:/usr/local/go/bin
    jtcore monacogp -mister --nolinter'
echo "RBF: $JTROOT/release/mister/jtmonacogp.rbf"
echo "Reports: $JTROOT/cores/monacogp/mister/output_files/"
