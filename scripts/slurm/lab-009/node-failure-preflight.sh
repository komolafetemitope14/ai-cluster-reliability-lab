#!/usr/bin/env bash

# LAB-009: Compute-node failure preflight
# Read-only safety checks before a controlled experiment.

set -euo pipefail

echo "=========================================="
echo " LAB-009: NODE FAILURE PREFLIGHT"
echo "=========================================="

echo
echo "=== 1. Slurm services ==="

for service in munge slurmctld slurmd; do
    state=$(systemctl is-active "$service" || true)
    printf "%-12s : %s\n" "$service" "$state"

    if [[ "$state" != "active" ]]; then
        echo "[FAIL] Required service is not active: $service"
        exit 1
    fi
done

echo
echo "=== 2. Cluster partitions ==="
sinfo

echo
echo "=== 3. Compute node states ==="
sinfo -N -l

echo
echo "=== 4. Check for active jobs ==="

active_jobs=$(squeue -h -o "%i %T %j")

if [[ -n "$active_jobs" ]]; then
    echo "[FAIL] Active or pending jobs detected:"
    echo "$active_jobs"
    echo
    echo "Do not begin the node-failure experiment."
    exit 1
fi

echo "[PASS] No active or pending jobs."

echo
echo "=== 5. Node capacity ==="
scontrol show nodes

echo
echo "=========================================="
echo " PREFLIGHT COMPLETED SUCCESSFULLY"
echo "=========================================="

