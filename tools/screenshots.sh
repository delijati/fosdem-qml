#!/bin/sh
# Screenshots of the main features with the demo schedule, for the README.
# Runs the app in the Ubuntu Touch 24.04 SDK image (xvfb).
# usage: tools/screenshots.sh [dir]   (default: docs/screenshots)
set -eu

IMAGE=${SMOKE_IMAGE:-docker.io/clickable/ci-ut24.04-1.x-amd64:8}
REPO=$(cd "$(dirname "$0")/.." && pwd)
OUT=${1:-$REPO/docs/screenshots}
mkdir -p "$OUT"
LOG=$(mktemp)

docker run --rm --network host \
    -v "$REPO:/repo:ro" -v "$OUT:/out" \
    "$IMAGE" sh -c '
        export XDG_DATA_HOME=$(mktemp -d)
        cd /repo
        timeout 90 xvfb-run -a -s "-screen 0 1024x768x24" \
            qmlscene tests/qml/screenshots.qml
    ' > "$LOG" 2>&1 || true

grep "^qml: SHOT" "$LOG" || true
if ! grep -q "SHOTS DONE" "$LOG"; then
    echo "SCREENSHOTS FAILED, see $LOG"
    tail -20 "$LOG"
    exit 1
fi
echo "screenshots in $OUT"
