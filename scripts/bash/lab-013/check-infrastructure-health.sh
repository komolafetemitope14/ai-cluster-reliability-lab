#!/usr/bin/env bash
# LAB-013: Read-only infrastructure health checks.

set -uo pipefail

PROMETHEUS_URL="${PROMETHEUS_URL:-http://127.0.0.1:9091}"

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

section() {
    printf '\n=== %s ===\n' "$1"
}

section "LAB-013 Infrastructure Health Check"
printf 'Timestamp (UTC): %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

section "Kubernetes"

if ! command -v kubectl >/dev/null 2>&1; then
    fail "kubectl command unavailable"
else
    context="$(kubectl config current-context 2>/dev/null)"

    if [[ -n "$context" ]]; then
        pass "Kubernetes context: $context"
    else
        fail "Kubernetes context unavailable"
    fi

    if node_output="$(kubectl get nodes --no-headers 2>/dev/null)"; then
        if [[ -z "$node_output" ]]; then
            fail "No Kubernetes nodes found"
        else
            not_ready="$(
                printf '%s\n' "$node_output" |
                awk '$2 != "Ready" { print $1 " (" $2 ")" }'
            )"

            if [[ -z "$not_ready" ]]; then
                pass "All Kubernetes nodes Ready"
            else
                fail "Kubernetes nodes not Ready: $not_ready"
            fi
        fi
    else
        fail "Unable to retrieve Kubernetes nodes"
    fi
fi

section "Slurm"

if ! command -v systemctl >/dev/null 2>&1; then
    fail "systemctl command unavailable"
else
    for service in munge slurmctld slurmd; do
        if systemctl is-active --quiet "$service"; then
            pass "Service active: $service"
        else
            fail "Service inactive or unavailable: $service"
        fi
    done
fi

if ! command -v sinfo >/dev/null 2>&1; then
    fail "sinfo command unavailable"
else
    if slurm_nodes="$(sinfo -N -h -o '%N|%T' 2>/dev/null)"; then
        if [[ -z "$slurm_nodes" ]]; then
            fail "No Slurm nodes returned"
        else
            unhealthy=0
            node_count=0

            while IFS='|' read -r node state; do
                [[ -z "$node" ]] && continue

                node_count=$((node_count + 1))
                normalized="${state,,}"

                case "$normalized" in
                    idle|alloc|allocated|mix|mixed|completing)
                        pass "Slurm node $node: $state"
                        ;;
                    *)
                        fail "Slurm node $node requires review: $state"
                        unhealthy=$((unhealthy + 1))
                        ;;
                esac
            done <<< "$slurm_nodes"

            if (( node_count == 0 )); then
                fail "No valid Slurm node records"
            fi
        fi
    else
        fail "Unable to retrieve Slurm node states"
    fi
fi

section "Prometheus"

if ! command -v curl >/dev/null 2>&1; then
    fail "curl command unavailable"
else
    if http_code="$(
        curl \
          --silent \
          --show-error \
          --max-time 5 \
          --output /dev/null \
          --write-out '%{http_code}' \
          "${PROMETHEUS_URL%/}/-/ready" 2>/dev/null
    )"; then
        if [[ "$http_code" == "200" ]]; then
            pass "Prometheus Ready (HTTP 200)"
        else
            fail "Prometheus readiness returned HTTP $http_code"
        fi
    else
        fail "Prometheus endpoint unreachable: $PROMETHEUS_URL"
    fi
fi

section "Summary"

printf 'Passed checks: %d\n' "$passed"
printf 'Failed checks: %d\n' "$failed"

if (( failed > 0 )); then
    printf 'Overall status: FAIL\n'
    exit 1
fi

printf 'Overall status: PASS\n'
exit 0
