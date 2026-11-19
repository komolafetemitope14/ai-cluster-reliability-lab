#!/usr/bin/env bash
# LAB-013: Automated tests for Bash reliability automation.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

HEALTH_SCRIPT="$REPO_ROOT/scripts/bash/lab-013/check-infrastructure-health.sh"
COLLECTOR_SCRIPT="$REPO_ROOT/scripts/bash/lab-013/collect-incident-evidence.sh"

passed=0
failed=0

pass() {
    printf 'PASS: %s\n' "$1"
    passed=$((passed + 1))
}

fail() {
    printf 'FAIL: %s\n' "$1"
    failed=$((failed + 1))
}

check_syntax() {
    local script="$1"

    if bash -n "$script"; then
        pass "Valid Bash syntax: $(basename "$script")"
    else
        fail "Invalid Bash syntax: $(basename "$script")"
    fi
}

check_shebang() {
    local script="$1"
    local first_line

    IFS= read -r first_line < "$script"

    if [[ "$first_line" == '#!/usr/bin/env bash' ]]; then
        pass "Correct shebang: $(basename "$script")"
    else
        fail "Incorrect shebang: $(basename "$script")"
    fi
}

printf '=== LAB-013 Automated Tests ===\n'

printf '\n=== Static validation ===\n'

check_syntax "$HEALTH_SCRIPT"
check_syntax "$COLLECTOR_SCRIPT"

check_shebang "$HEALTH_SCRIPT"
check_shebang "$COLLECTOR_SCRIPT"

printf '\n=== Healthy infrastructure test ===\n'

healthy_output="$(
    PROMETHEUS_URL="http://127.0.0.1:9091" \
    "$HEALTH_SCRIPT" 2>&1
)"
healthy_status=$?

if (( healthy_status == 0 )) &&
   grep -q 'Overall status: PASS' <<< "$healthy_output"; then
    pass "Healthy infrastructure returns exit code 0"
else
    fail "Healthy infrastructure test"
fi

printf '\n=== Controlled failure test ===\n'

failure_output="$(
    PROMETHEUS_URL="http://127.0.0.1:19091" \
    "$HEALTH_SCRIPT" 2>&1
)"
failure_status=$?

if (( failure_status == 1 )) &&
   grep -q 'Overall status: FAIL' <<< "$failure_output"; then
    pass "Unreachable Prometheus returns exit code 1"
else
    fail "Controlled failure detection"
fi

if grep -q 'Prometheus endpoint unreachable' \
    <<< "$failure_output"; then
    pass "Failure output identifies Prometheus"
else
    fail "Failure output does not identify Prometheus"
fi

printf '\n=== Test summary ===\n'

printf 'Passed tests: %d\n' "$passed"
printf 'Failed tests: %d\n' "$failed"

if (( failed > 0 )); then
    printf 'Overall test result: FAIL\n'
    exit 1
fi

printf 'Overall test result: PASS\n'
exit 0
