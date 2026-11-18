#!/usr/bin/env bash

#SBATCH --job-name=lab008-first-job
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=256M
#SBATCH --time=00:02:00
#SBATCH --output=slurm/output/lab-008/job-%j.out
#SBATCH --error=slurm/output/lab-008/job-%j.err

# LAB-008: First Slurm batch job
# Purpose: Demonstrate batch submission and execution.

set -euo pipefail

echo "=========================================="
echo " LAB-008: FIRST SLURM BATCH JOB"
echo "=========================================="

echo
echo "=== Job Information ==="
echo "Job ID: ${SLURM_JOB_ID:-unknown}"
echo "Job Name: ${SLURM_JOB_NAME:-unknown}"
echo "Node: $(hostname)"
echo "Allocated CPUs: ${SLURM_CPUS_PER_TASK:-unknown}"

echo
echo "=== Execution Time ==="
date

echo
echo "=== Simulated Workload ==="

for step in 1 2 3 4 5; do
    echo "Processing step $step of 5"
    sleep 2
done

echo
echo "=== Completion ==="
echo "Job finished successfully."
date
