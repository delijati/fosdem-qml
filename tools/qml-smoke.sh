#!/bin/sh
# QML smoke check: runs the app in the Ubuntu Touch 24.04 SDK image (xvfb),
# opens every page with tests/data/small.xml and fails on QML/python errors.
# usage: tools/qml-smoke.sh [screenshot-dir]
set -eu

IMAGE=${SMOKE_IMAGE:-docker.io/clickable/ci-ut24.04-1.x-amd64:8}
REPO=$(cd "$(dirname "$0")/.." && pwd)
OUT=${1:-$(mktemp -d)}
mkdir -p "$OUT"
LOG="$OUT/smoke.log"

docker run --rm --network host \
    -v "$REPO:/repo:ro" -v "$OUT:/out" \
    "$IMAGE" sh -c '
        export XDG_DATA_HOME=$(mktemp -d)
        mkdir -p "$XDG_DATA_HOME/fosdem-qml.delijati"
        cp /repo/tests/data/small.xml "$XDG_DATA_HOME/fosdem-qml.delijati/schedule.xml"
        # update for the re-download step: talk 100 (starred by the smoke run) removed
        python3 -c "import re,sys; s=open(sys.argv[1]).read(); open(sys.argv[2],\"w\").write(re.sub(r\"<event guid=.g-100.*?</event>\", \"\", s, flags=re.S))" \
            /repo/tests/data/small.xml /tmp/small-update.xml
        cd /repo
        timeout 60 xvfb-run -a -s "-screen 0 1024x768x24" \
            qmlscene tests/qml/smoke.qml
    ' > "$LOG" 2>&1 || true

# Missing theme icons are expected in the SDK image (no suru icon theme).
ERRORS=$(grep -v "Failed to get image from provider" "$LOG" \
    | grep -E "MISMATCH|Error|error:|Unable to assign|Cannot read|is not defined|is not a function|Binding loop|Traceback|\.qml:[0-9]+" || true)

grep "^qml: SMOKE" "$LOG" || true
if [ -n "$ERRORS" ]; then
    echo "SMOKE FAILED: errors in $LOG"
    echo "$ERRORS"
    exit 1
fi
if ! grep -q "SMOKE DONE" "$LOG"; then
    echo "SMOKE FAILED: did not finish, see $LOG"
    tail -20 "$LOG"
    exit 1
fi
echo "SMOKE OK: screenshots in $OUT"
