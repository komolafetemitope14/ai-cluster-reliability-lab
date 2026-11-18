#!/usr/bin/env bash
#SBATCH --job-name=lab009-failure
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=256M
#SBATCH --time=00:02:00

# LAB-009: Deliberately failing batch job.

set -euo pipefail

echo "=========================================="
echo " LAB-009: JOB EXECUTION FAILURE"
echo "=========================================="

echo "Job ID: ${SLURM_JOB_ID:-unknown}"
echo "Hostname: $(hostname)"
echo "Start time: $(date -Is)"

echo
echo "Step 1: Initializing workload..."
sleep 2

echo
echo "Step 2: Simulating application failure..."
echo "ERROR: Simulated application processing failure." >&2

exit 42

