
#!/usr/bin/env bash

# LAB-008: Configure a single-node Slurm cluster
# Target: Ubuntu ThinkPad T480, CPU-only
#
# Creates a minimal cluster with conservative resources.
# Does not start the Slurm services automatically.

set -euo pipefail

CLUSTER_NAME="ai-reliability-slurm"
NODE_NAME="$(hostname -s)"
CONFIG_DIR="/etc/slurm"
CONFIG_FILE="$CONFIG_DIR/slurm.conf"

echo "=========================================="
echo " LAB-008: SLURM CLUSTER CONFIGURATION"
echo "=========================================="

if [[ $EUID -eq 0 ]]; then
    echo "[ERROR] Run as your normal user."
    exit 1
fi

echo
echo "=== 1. Checking prerequisites ==="

for command_name in slurmd slurmctld munge; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "[ERROR] Missing command: $command_name"
        exit 1
    fi
done

if ! systemctl is-active --quiet munge; then
    echo "[ERROR] MUNGE must be running."
    exit 1
fi

if ! getent hosts "$NODE_NAME" >/dev/null; then
    echo "[ERROR] Hostname does not resolve: $NODE_NAME"
    exit 1
fi

echo "[PASS] Prerequisites verified."

echo
echo "=== 2. Checking existing configuration ==="

if sudo test -e "$CONFIG_FILE"; then
    echo "[ERROR] $CONFIG_FILE already exists."
    echo "Refusing to overwrite an existing configuration."
    exit 1
fi

echo
echo "=== 3. Creating Slurm directories ==="

sudo install -d -o root -g root -m 0755 "$CONFIG_DIR"

sudo install -d -o slurm -g slurm -m 0755 \
    /var/spool/slurmctld

sudo install -d -o root -g root -m 0755 \
    /var/spool/slurmd

sudo install -d -o slurm -g slurm -m 0755 \
    /var/log/slurm

echo
echo "=== 4. Writing cluster configuration ==="

sudo tee "$CONFIG_FILE" >/dev/null <<EOF
# LAB-008: Single-node Slurm cluster
# CPU-only learning environment

ClusterName=$CLUSTER_NAME
SlurmctldHost=$NODE_NAME

SlurmUser=slurm
AuthType=auth/munge

StateSaveLocation=/var/spool/slurmctld
SlurmdSpoolDir=/var/spool/slurmd

SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdLogFile=/var/log/slurm/slurmd.log

SlurmctldPidFile=/run/slurmctld.pid
SlurmdPidFile=/run/slurmd.pid

SlurmctldPort=6817
SlurmdPort=6818

ProctrackType=proctrack/linuxproc
TaskPlugin=task/none
JobAcctGatherType=jobacct_gather/none

SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_CPU_Memory

ReturnToService=1

# Advertise a small subset of laptop resources.
NodeName=$NODE_NAME CPUs=2 RealMemory=2048 State=UNKNOWN

PartitionName=cpu Nodes=$NODE_NAME Default=YES MaxTime=00:30:00 State=UP
EOF

sudo chmod 0644 "$CONFIG_FILE"

echo
echo "=== 5. Configuration summary ==="

echo "Cluster: $CLUSTER_NAME"
echo "Controller: $NODE_NAME"
echo "Compute node: $NODE_NAME"
echo "Advertised CPUs: 2"
echo "Advertised memory: 2048 MiB"
echo "Partition: cpu"

echo
echo "=== 6. Checking configuration file ==="

sudo test -s "$CONFIG_FILE"
echo "[PASS] Configuration file created."

echo
echo "=========================================="
echo " CONFIGURATION COMPLETED"
echo " Services have not been started yet."
echo "=========================================="
