#!/usr/bin/env bash

# LAB-009: Recover the local Slurm compute node.
# Run only during the controlled node-failure experiment.

set -euo pipefail

NODE_NAME="$(hostname)"

echo "=========================================="
echo " LAB-009: COMPUTE NODE RECOVERY"
echo "=========================================="

echo
echo "=== 1. Check controller and authentication ==="

for service in munge slurmctld; do
    state=$(systemctl is-active "$service" || true)
    echo "$service: $state"

    if [[ "$state" != "active" ]]; then
        echo "[FAIL] Required service is unavailable."
        exit 1
    fi
done

echo
echo "=== 2. Start compute daemon ==="

sudo systemctl start slurmd

echo
echo "=== 3. Verify compute daemon ==="

if ! systemctl is-active --quiet slurmd; then
    echo "[FAIL] slurmd did not start."
    exit 1
fi

echo "[PASS] slurmd is active."

echo
echo "=== 4. Inspect node state ==="

scontrol show node "$NODE_NAME"

echo
echo "=== 5. Resume node if necessary ==="

NODE_STATE=$(scontrol show node "$NODE_NAME" | \
    sed -n 's/.*State=\([^ ]*\).*/\1/p' | head -n 1)

echo "Observed node state: $NODE_STATE"

if [[ "$NODE_STATE" == *DOWN* ||
      "$NODE_STATE" == *DRAIN* ||
      "$NODE_STATE" == *FAIL* ]]; then

    echo "Node requires an explicit resume."

    sudo scontrol update \
        NodeName="$NODE_NAME" \
        State=RESUME

else
    echo "No explicit resume requested."
fi

echo
echo "=== 6. Final cluster state ==="

sinfo
squeue

echo
echo "=== 7. Final service health ==="

systemctl is-active munge slurmctld slurmd

echo
echo "=========================================="
echo " RECOVERY CHECK COMPLETED"
echo "=========================================="

