
#!/usr/bin/env bash

# Remove trailing blank lines from LAB-008 Bash scripts.
# Preserve exactly one newline at the end of each file.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "=========================================="
echo " LAB-008: FILE FORMATTING CLEANUP"
echo "=========================================="

for file in "$REPO_DIR"/scripts/slurm/*.sh \
            "$REPO_DIR"/slurm/jobs/lab-008/*.sh; do

    [[ -f "$file" ]] || continue

    sed -i '${/^[[:space:]]*$/d;}' "$file"

    echo "[CHECKED] ${file#"$REPO_DIR"/}"
done

echo
echo "Formatting cleanup completed."
