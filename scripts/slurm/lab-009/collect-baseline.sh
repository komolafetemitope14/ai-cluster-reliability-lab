
#!/usr/bin/env bash

# LAB-009: Slurm cluster health baseline
# Read-only diagnostic script.

set -uo pipefail

echo "=========================================="
echo " LAB-009: SLURM HEALTH BASELINE"
echo "=========================================="

echo
echo "=== 1. Timestamp ==="
date -Is

echo
echo "=== 2. Hostname ==="
hostname

echo
echo "=== 3. Slurm services ==="
for service in munge slurmctld slurmd; do
    printf "%-12s : " "$service"
    systemctl is-active "$service" || true
done

echo
echo "=== 4. Slurm version ==="
sinfo --version || true

echo
echo "=== 5. Cluster partitions ==="
sinfo || true

echo
echo "=== 6. Compute node summary ==="
sinfo -N -l || true

echo
echo "=== 7. Detailed node information ==="
scontrol show nodes || true

echo
echo "=== 8. Current job queue ==="
squeue || true

echo
echo "=== 9. Partition configuration ==="
scontrol show partition || true

echo
echo "=== 10. MUNGE authentication test ==="
if command -v munge >/dev/null 2>&1 &&
   command -v unmunge >/dev/null 2>&1; then
    if munge -n | unmunge >/dev/null 2>&1; then
        echo "[PASS] MUNGE authentication successful"
    else
        echo "[FAIL] MUNGE authentication unsuccessful"
    fi
else
    echo "[WARN] MUNGE test commands unavailable"
fi

echo
echo "=========================================="
echo " BASELINE COLLECTION COMPLETED"
echo "=========================================="

