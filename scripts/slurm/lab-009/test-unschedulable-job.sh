
#!/usr/bin/env bash

# LAB-009: Unschedulable Slurm job experiment
# Requests more CPUs than the cluster provides.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OUTPUT_DIR="$REPO_DIR/slurm/output/lab-009"

mkdir -p "$OUTPUT_DIR"

echo "=========================================="
echo " LAB-009: UNSCHEDULABLE JOB EXPERIMENT"
echo "=========================================="

echo
echo "=== 1. Available cluster resources ==="
sinfo -o "%P %D %C %m %T"

echo
echo "=== 2. Submit job requesting 3 CPUs ==="

set +e
SUBMISSION_OUTPUT=$(sbatch \
    --parsable \
    --partition=cpu \
    --job-name=lab009-too-many-cpus \
    --nodes=1 \
    --ntasks=1 \
    --cpus-per-task=3 \
    --mem=256M \
    --time=00:02:00 \
    --output="$OUTPUT_DIR/unschedulable-%j.out" \
    --wrap="echo This job should not run with only 2 CPUs available" \
    2>&1)
SUBMISSION_STATUS=$?
set -e

echo "$SUBMISSION_OUTPUT"

echo
echo "=== 3. Interpret submission result ==="

if [[ "$SUBMISSION_STATUS" -ne 0 ]]; then
    echo "[OBSERVED] Slurm rejected the submission."
    echo "Exit status: $SUBMISSION_STATUS"
    echo "No job was created by this submission."
else
    JOB_ID="${SUBMISSION_OUTPUT%%;*}"

    if [[ ! "$JOB_ID" =~ ^[0-9]+$ ]]; then
        echo "[WARN] Could not identify the submitted job ID."
        exit 1
    fi

    echo "[OBSERVED] Job accepted with ID: $JOB_ID"

    echo
    echo "=== 4. Job queue ==="
    squeue -j "$JOB_ID" || true

    echo
    echo "=== 5. Detailed job diagnostics ==="
    scontrol show job "$JOB_ID" || true

    echo
    echo "=== 6. Cancel experiment job ==="
    scancel "$JOB_ID"
    echo "[DONE] Cancellation requested for job $JOB_ID"
fi

echo
echo "=== 7. Final cluster state ==="
sinfo

echo
echo "=========================================="
echo " EXPERIMENT COMPLETED"
echo "=========================================="

