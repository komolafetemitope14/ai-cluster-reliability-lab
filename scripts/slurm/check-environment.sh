
#!/usr/bin/env bash

# LAB-008: Slurm Environment Diagnostic Script
# Purpose: Inspect Ubuntu resources and existing Slurm installation.
# Safe to run: Read-only checks.

set -u

echo "=========================================="
echo " LAB-008: SLURM ENVIRONMENT CHECK"
echo "=========================================="
echo

echo "=== Operating System ==="
if command -v lsb_release >/dev/null 2>&1; then
    lsb_release -a
else
    cat /etc/os-release
fi

echo
echo "=== Hostname ==="
hostname

echo
echo "=== CPU Resources ==="
nproc

echo
echo "=== Memory Resources ==="
free -h

echo
echo "=== Slurm Command Availability ==="

for cmd in sinfo sbatch squeue scontrol sacct; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "[FOUND] $cmd: $(command -v "$cmd")"
    else
        echo "[MISSING] $cmd"
    fi
done

echo
echo "=== Installed Slurm Packages ==="

if dpkg-query -W -f='${binary:Package} ${Version}\n' \
    'slurm*' 2>/dev/null; then
    :
else
    echo "No matching Slurm packages found."
fi

echo
echo "=== Slurm Service Status ==="

for service in munge slurmctld slurmd slurmdbd; do
    if systemctl is-active --quiet "$service"; then
        echo "[RUNNING] $service"
    else
        echo "[NOT RUNNING] $service"
    fi
done

echo
echo "=========================================="
echo " Environment check completed"
echo "=========================================="
