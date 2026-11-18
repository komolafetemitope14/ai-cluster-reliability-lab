
#!/usr/bin/env bash

# LAB-008: Install Slurm packages on Ubuntu
# Purpose: Install MUNGE, Slurm controller, compute daemon,
# and command-line utilities.
#
# This script installs system packages but does not
# configure or start the Slurm cluster.

set -euo pipefail

echo "=========================================="
echo " LAB-008: SLURM PACKAGE INSTALLATION"
echo "=========================================="

if [[ $EUID -eq 0 ]]; then
    echo "[ERROR] Run this script as your normal user."
    echo "It will request sudo privileges when needed."
    exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
    echo "[ERROR] apt-get was not found."
    exit 1
fi

echo
echo "=== Packages to install ==="
packages=(
    munge
    slurmctld
    slurmd
    slurm-client
)

printf '  %s\n' "${packages[@]}"

echo
echo "=== Refreshing package metadata ==="
sudo apt-get update

echo
echo "=== Installing packages ==="

# Prevent package installation from automatically starting
# system services before Slurm configuration is complete.
policy_file="/usr/sbin/policy-rc.d"

if [[ -e "$policy_file" ]]; then
    echo "[ERROR] Existing $policy_file detected."
    echo "Stopping to avoid modifying an existing policy."
    exit 1
fi

cleanup() {
    if [[ -f "$policy_file" ]] &&
       grep -q 'LAB-008 temporary policy' "$policy_file"; then
        sudo rm -f "$policy_file"
    fi
}

trap cleanup EXIT

sudo tee "$policy_file" >/dev/null <<'POLICY'
#!/bin/sh
# LAB-008 temporary policy
exit 101
POLICY

sudo chmod 755 "$policy_file"

sudo apt-get install -y "${packages[@]}"

echo
echo "=== Installation completed ==="
echo "Package installation succeeded."
echo "Slurm configuration will be handled separately."
