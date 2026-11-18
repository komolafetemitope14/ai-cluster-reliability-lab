
#!/usr/bin/env bash

# LAB-008: Slurm Installation Preflight
# Purpose: Check package availability and system readiness.
# This script does not install or modify anything.

set -u

echo "========================================"
echo " LAB-008: SLURM INSTALLATION PREFLIGHT"
echo "========================================"

echo
echo "=== 1. Operating System ==="
. /etc/os-release
echo "OS: $PRETTY_NAME"
echo "Version: $VERSION_ID"

echo
echo "=== 2. Hostname Resolution ==="
echo "Hostname: $(hostname)"

if getent hosts "$(hostname)" >/dev/null; then
    echo "[PASS] Hostname resolves"
    getent hosts "$(hostname)"
else
    echo "[WARNING] Hostname does not resolve"
fi

echo
echo "=== 3. CPU and Memory ==="
echo "Logical CPUs: $(nproc)"
free -h

echo
echo "=== 4. Package Availability ==="

packages=(
    munge
    slurm-wlm
    slurmctld
    slurmd
    slurm-client
)

for package in "${packages[@]}"; do
    echo
    echo "--- $package ---"

    if apt-cache show "$package" >/dev/null 2>&1; then
        echo "[AVAILABLE] $package"
        apt-cache policy "$package" | head -n 8
    else
        echo "[NOT FOUND] $package"
    fi
done

echo
echo "=== 5. Existing Configuration ==="

for path in \
    /etc/slurm \
    /etc/slurm-llnl \
    /etc/munge
do
    if [ -e "$path" ]; then
        echo "[EXISTS] $path"
    else
        echo "[ABSENT] $path"
    fi
done

echo
echo "=== 6. Available Disk Space ==="
df -h /

echo
echo "=== 7. Container Runtime ==="

if command -v docker >/dev/null 2>&1; then
    echo "[FOUND] Docker"
    docker --version
else
    echo "[NOT FOUND] Docker"
fi

echo
echo "========================================"
echo " Preflight completed"
echo " No changes were made"
echo "========================================"
