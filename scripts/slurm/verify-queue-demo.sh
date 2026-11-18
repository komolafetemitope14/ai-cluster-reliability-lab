
#!/usr/bin/env bash

# LAB-008: Verify queue contention experiment results

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUTPUT_DIR="$REPO_DIR/slurm/output/lab-008"

echo "=========================================="
echo " LAB-008: QUEUE EXPERIMENT VERIFICATION"
echo "=========================================="

echo
echo "=== 1. Cluster health ==="
sinfo

echo
echo "=== 2. Remaining jobs ==="
squeue -j 2,3

echo
echo "=== 3. Job A output ==="

if [[ -f "$OUTPUT_DIR/holder-2.out" ]]; then
    cat "$OUTPUT_DIR/holder-2.out"
else
    echo "[NOT FOUND] Job A output"
fi

echo
echo "=== 4. Job B output ==="

if [[ -f "$OUTPUT_DIR/waiting-3.out" ]]; then
    cat "$OUTPUT_DIR/waiting-3.out"
else
    echo "[NOT FOUND] Job B output"
fi

echo
echo "=== 5. Output file metadata ==="
ls -lh "$OUTPUT_DIR"

echo
echo "=========================================="
echo " VERIFICATION COMPLETED"
echo "=========================================="
