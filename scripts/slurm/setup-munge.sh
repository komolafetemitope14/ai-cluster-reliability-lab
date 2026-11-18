
#!/usr/bin/env bash

# LAB-008: Configure MUNGE authentication
# Creates a local authentication key if one does not exist.
# Never prints or stores the secret key in the Git repository.

set -euo pipefail

echo "=========================================="
echo " LAB-008: MUNGE AUTHENTICATION SETUP"
echo "=========================================="

if [[ $EUID -eq 0 ]]; then
    echo "[ERROR] Run as your normal user, not root."
    exit 1
fi

if ! command -v mungekey >/dev/null 2>&1; then
    echo "[ERROR] mungekey is missing."
    exit 1
fi

echo
echo "=== 1. Checking authentication key ==="

if sudo test -f /etc/munge/munge.key; then
    echo "[EXISTS] Keeping existing MUNGE key."
else
    echo "[INFO] Generating a new MUNGE key."
    sudo install -d -o munge -g munge -m 0700 /etc/munge
    sudo mungekey --create
fi

echo
echo "=== 2. Securing key permissions ==="

sudo chown munge:munge /etc/munge/munge.key
sudo chmod 0400 /etc/munge/munge.key

echo
echo "=== 3. Starting MUNGE ==="

sudo systemctl enable --now munge

echo
echo "=== 4. Checking service ==="

if systemctl is-active --quiet munge; then
    echo "[PASS] MUNGE service is running."
else
    echo "[FAIL] MUNGE service is not running."
    exit 1
fi

echo
echo "=== 5. Testing authentication ==="

if command -v unmunge >/dev/null 2>&1; then
    if munge -n | unmunge >/dev/null; then
        echo "[PASS] MUNGE authentication succeeded."
    else
        echo "[FAIL] MUNGE authentication failed."
        exit 1
    fi
else
    echo "[WARNING] unmunge command unavailable."
fi

echo
echo "=== 6. Checking key metadata ==="

sudo stat -c \
    'Owner: %U | Group: %G | Permissions: %a' \
    /etc/munge/munge.key

echo
echo "=========================================="
echo " MUNGE SETUP COMPLETED SUCCESSFULLY"
echo "=========================================="
