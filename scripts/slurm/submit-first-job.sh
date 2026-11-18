
#!/usr/bin/env bash

# LAB-008: Submit the first Slurm batch job
# Run from anywhere within the repository.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
JOB_FILE="$REPO_DIR/slurm/jobs/lab-008/first-job.sh"
OUTPUT_DIR="$REPO_DIR/slurm/output/lab-008"

echo "=========================================="
echo " LAB-008: SUBMIT FIRST SLURM JOB"
echo "=========================================="

if [[ ! -f "$JOB_FILE" ]]; then
    echo "[ERROR] Job script not found: $JOB_FILE"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

cd "$REPO_DIR"

echo
echo "=== Submitting job ==="

job_id="$(sbatch --parsable "$JOB_FILE")"

echo "[SUBMITTED] Job ID: $job_id"

echo
echo "=== Queue status ==="

squeue --jobs="$job_id" || true

echo
echo "=== Job details ==="

scontrol show job "$job_id" || true

echo
echo "=== Output locations ==="
echo "stdout: $OUTPUT_DIR/job-$job_id.out"
echo "stderr: $OUTPUT_DIR/job-$job_id.err"

echo
echo "=========================================="
echo " Submission completed"
echo "=========================================="
