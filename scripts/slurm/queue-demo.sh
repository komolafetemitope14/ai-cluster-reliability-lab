
#!/usr/bin/env bash

# LAB-008: Slurm Queue Contention Demonstration
# Two lightweight jobs compete for two advertised CPUs.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_DIR="$REPO_DIR/slurm/output/lab-008"

mkdir -p "$OUTPUT_DIR"
cd "$REPO_DIR"

echo "=========================================="
echo " LAB-008: SLURM QUEUE CONTENTION"
echo "=========================================="

echo
echo "=== Checking cluster availability ==="

sinfo -o "%P %a %D %t"

echo
echo "=== Submitting Job A (2 CPUs, 40 seconds) ==="

job_a=$(sbatch --parsable \
    --job-name=lab008-resource-holder \
    --partition=cpu \
    --cpus-per-task=2 \
    --mem=512M \
    --time=00:02:00 \
    --output="$OUTPUT_DIR/holder-%j.out" \
    --wrap='echo "Job A started"; sleep 40; echo "Job A completed"')

echo "Job A ID: $job_a"

echo
echo "=== Waiting for Job A to start ==="

for attempt in $(seq 1 20); do
    state=$(squeue -h -j "$job_a" -o "%t")

    if [[ "$state" == "R" ]]; then
        echo "[RUNNING] Job A holds both CPUs."
        break
    fi

    if [[ -z "$state" ]]; then
        echo "[ERROR] Job A left the queue unexpectedly."
        exit 1
    fi

    sleep 1
done

if [[ "$state" != "R" ]]; then
    echo "[ERROR] Job A did not start within 20 seconds."
    exit 1
fi

echo
echo "=== Submitting Job B (1 CPU, 5 seconds) ==="

job_b=$(sbatch --parsable \
    --job-name=lab008-waiting-job \
    --partition=cpu \
    --cpus-per-task=1 \
    --mem=256M \
    --time=00:02:00 \
    --output="$OUTPUT_DIR/waiting-%j.out" \
    --wrap='echo "Job B started"; sleep 5; echo "Job B completed"')

echo "Job B ID: $job_b"

echo
echo "=== Monitoring queue for 10 seconds ==="

for attempt in $(seq 1 5); do
    echo
    echo "--- Queue observation $attempt ---"

    squeue -j "$job_a,$job_b" \
        -o "%.10i %.26j %.3t %.12M %R"

    sleep 2
done

echo
echo "=== Job B scheduling details ==="

scontrol show job "$job_b" \
    | grep -E 'JobId=|JobState=|ReqTRES=' || true

echo
echo "=== Experiment job IDs ==="
echo "Job A: $job_a"
echo "Job B: $job_b"

echo
echo "Both jobs will finish automatically."
echo "Review output files in:"
echo "$OUTPUT_DIR"

echo
echo "=========================================="
echo " QUEUE DEMONSTRATION COMPLETED"
echo "=========================================="
