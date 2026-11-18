
#!/usr/bin/env bash

# LAB-008: Start and verify the single-node Slurm cluster
# Starts the controller and compute daemon, then collects
# basic diagnostics if either service fails.

set -euo pipefail

echo "=========================================="
echo " LAB-008: START SLURM CLUSTER"
echo "=========================================="

echo
echo "=== 1. Checking prerequisites ==="

if [[ ! -f /etc/slurm/slurm.conf ]]; then
    echo "[FAIL] Slurm configuration file is missing."
    exit 1
fi

if ! systemctl is-active --quiet munge; then
    echo "[FAIL] MUNGE authentication is not running."
    exit 1
fi

echo "[PASS] Configuration and MUNGE found."

echo
echo "=== 2. Starting Slurm controller ==="

if sudo systemctl start slurmctld; then
    echo "[PASS] Controller start command succeeded."
else
    echo "[FAIL] Controller could not start."
    sudo journalctl -u slurmctld -n 30 --no-pager
    exit 1
fi

echo
echo "=== 3. Starting compute daemon ==="

if sudo systemctl start slurmd; then
    echo "[PASS] Compute daemon start command succeeded."
else
    echo "[FAIL] Compute daemon could not start."
    sudo journalctl -u slurmd -n 30 --no-pager
    exit 1
fi

echo
echo "=== 4. Service status ==="

for service in munge slurmctld slurmd; do
    if systemctl is-active --quiet "$service"; then
        echo "[RUNNING] $service"
    else
        echo "[NOT RUNNING] $service"
    fi
done

echo
echo "=== 5. Cluster information ==="

if ! sinfo; then
    echo "[WARNING] sinfo failed."
    echo "Controller diagnostics:"
    sudo journalctl -u slurmctld -n 30 --no-pager
fi

echo
echo "=== 6. Node information ==="

if ! scontrol show nodes; then
    echo "[WARNING] Unable to retrieve node information."
fi

echo
echo "=== 7. Queue information ==="

if ! squeue; then
    echo "[WARNING] Unable to retrieve queue information."
fi

echo
echo "=========================================="
echo " SLURM STARTUP CHECK COMPLETED"
echo "=========================================="
