cd ~/Projects/ai-cluster-reliability-lab

python3 - <<'PY'
from pathlib import Path

file = Path("labs/LAB-013-bash-health-checks-and-evidence-collection/README.md")

content = file.read_text()
file.write_text(content.rstrip("\n") + "\n")

print("PASS: Extra blank lines removed from README.")
PY

git add labs/LAB-013-bash-health-checks-and-evidence-collection/README.md

echo
echo "=== Verify README whitespace ==="

if git diff --cached --check -- \
  labs/LAB-013-bash-health-checks-and-evidence-collection/README.md
then
    echo "PASS: README whitespace is clean"
else
    echo "FAIL: README still has whitespace errors"
fi
