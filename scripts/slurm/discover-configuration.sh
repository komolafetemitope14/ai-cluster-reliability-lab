
#!/usr/bin/env bash

# LAB-008: Slurm Configuration Discovery
# Purpose: Gather hardware and configuration details
# before creating a single-node Slurm cluster.
#
# Read-only: Does not change system configuration.

set -u

echo "=========================================="
echo " LAB-008: SLURM CONFIGURATION DISCOVERY"
echo "=========================================="

echo
echo "=== 1. Hostname ==="
hostname
hostname -s
getent hosts "$(hostname)" || true

echo
echo "=== 2. CPU Topology ==="
lscpu | grep -E \
'^(Architecture|CPU\(s\)|Thread\(s\) per core|Core\(s\) per socket|Socket\(s\)):'

echo
echo "=== 3. Slurm Node Discovery ==="
if command -v slurmd >/dev/null 2>&1; then
    slurmd -C || true
else
    echo "[MISSING] slurmd"
fi

echo
echo "=== 4. Memory ==="
free -m

echo
echo "=== 5. Slurm Version ==="
if command -v sinfo >/dev/null 2>&1; then
    sinfo --version
fi

echo
echo "=== 6. Slurm Configuration Directories ==="

for path in \
    /etc/slurm \
    /etc/slurm-llnl \
    /var/spool/slurmctld \
    /var/spool/slurmd \
    /var/log/slurm
do
    if [[ -e "$path" ]]; then
        echo "[EXISTS] $path"
        ls -ld "$path"
    else
        echo "[ABSENT] $path"
    fi
done

echo
echo "=== 7. Slurm and MUNGE Accounts ==="

for account in slurm munge; do
    if id "$account" >/dev/null 2>&1; then
        id "$account"
    else
        echo "[MISSING] $account"
    fi
done

echo
echo "=== 8. MUNGE Key Metadata ==="

if [[ -e /etc/munge/munge.key ]]; then
    echo "[EXISTS] /etc/munge/munge.key"
    sudo stat -c 'Owner: %U Group: %G Permissions: %a' \
        /etc/munge/munge.key
else
    echo "[ABSENT] /etc/munge/munge.key"
fi

echo
echo "=== 9. Temporary Service Policy ==="

if [[ -e /usr/sbin/policy-rc.d ]]; then
    echo "[WARNING] /usr/sbin/policy-rc.d exists"
else
    echo "[PASS] Temporary service policy absent"
fi

echo
echo "=========================================="
echo " Discovery completed"
echo "=========================================="
