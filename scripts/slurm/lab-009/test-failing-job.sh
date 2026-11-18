
#!/usr/bin/env bash

# LAB-009: Submit and diagnose a deliberately failing job.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
JOB_FILE="$REPO_DIR/slurm/jobs/lab-009/failing-job.sh"
OUTPUT_DIR="$REPO_DIR/slurm/output/lab-009"

mkdir -p "$OUTPUT_DIR"

echo "=========================================="
echo " LAB-009: FAILED JOB TROUBLESHOOTING"
echo "=========================================="

echo
echo "=== 1. Cluster state ==="
sinfo

echo
echo "=== 2. Submit failing job ==="

JOB_ID=$(sbatch --parsable \
    --output="$OUTPUT_DIR/failure-%j.out" \
    --error="$OUTPUT_DIR/failure-%j.err" \
    "$JOB_FILE")

echo "Submitted job ID: $JOB_ID"

echo
echo "=== 3. Wait for job to finish ==="

for attempt in {1..20}; do
    JOB_STATE=$(squeue -h -j "$JOB_ID" -o "%T")

    if [[ -z "$JOB_STATE" ]]; then
        echo "Job is no longer in the active queue."
        break
    fi

    echo "Attempt $attempt: $JOB_STATE"
    sleep 2
done

echo
echo "=== 4. Standard output ==="
if [[ -f "$OUTPUT_DIR/failure-$JOB_ID.out" ]]; then
    cat "$OUTPUT_DIR/failure-$JOB_ID.out"
else
    echo "[WARN] Standard output file not found."
fi

echo
echo "=== 5. Standard error ==="
if [[ -f "$OUTPUT_DIR/failure-$JOB_ID.err" ]]; then
    cat "$OUTPUT_DIR/failure-$JOB_ID.err"
else
    echo "[WARN] Standard error file not found."
fi

echo
echo "=== 6. Slurm job diagnostics ==="
scontrol show job "$JOB_ID" || true

echo
echo "=== 7. Accounting availability ==="
if command -v sacct >/dev/null 2>&1; then
    sacct -j "$JOB_ID" \
        --format=JobID,JobName,State,ExitCode \
        2>&1 || true
else
    echo "sacct command unavailable."
fi

echo
echo "=== 8. Final cluster state ==="
sinfo

echo
echo "=========================================="
echo " FAILED JOB EXPERIMENT COMPLETED"
echo "=========================================="

