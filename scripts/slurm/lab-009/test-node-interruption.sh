#!/usr/bin/env bash

# LAB-009: Controlled Slurm compute-daemon interruption.
# Requires sudo privileges.
# Automatically attempts recovery after a short observation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFLIGHT="$SCRIPT_DIR/node-failure-preflight.sh"
RECOVERY="$SCRIPT_DIR/recover-compute-node.sh"

RECOVERY_ATTEMPTED=0

recover_on_exit() {
    if [[ "$RECOVERY_ATTEMPTED" -eq 0 ]]; then
        RECOVERY_ATTEMPTED=1

        echo
        echo "=== Automatic recovery ==="

        bash "$RECOVERY" || {
            echo "[WARN] Recovery script reported an error."
            echo "Check slurmd with:"
            echo "  sudo systemctl start slurmd"
        }
    fi
}

echo "=========================================="
echo " LAB-009: COMPUTE NODE INTERRUPTION"
echo "=========================================="

echo
echo "=== 1. Safety preflight ==="

bash "$PREFLIGHT"

echo
echo "=== 2. Confirm sudo access ==="

sudo -v

echo
echo "=== 3. Register recovery handler ==="

trap recover_on_exit EXIT

echo
echo "=== 4. Stop slurmd temporarily ==="

sudo systemctl stop slurmd

echo
echo "=== 5. Confirm service interruption ==="

systemctl is-active slurmd || true

echo
echo "=== 6. Observe scheduler state ==="

for attempt in 1 2 3; do
    echo
    echo "Observation $attempt"

    sinfo -N -l || true

    sleep 5
done

echo
echo "=== 7. Recover compute node ==="

recover_on_exit

echo
echo "=== 8. Verify services ==="

systemctl is-active munge slurmctld slurmd

echo
echo "=== 9. Final cluster state ==="

sinfo
squeue

echo
echo "=========================================="
echo " NODE INTERRUPTION EXPERIMENT COMPLETED"
echo "=========================================="

