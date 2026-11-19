#!/usr/bin/env bash
# LAB-013: Read-only infrastructure incident evidence collection.

set -uo pipefail
umask 077

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

PROMETHEUS_URL="${PROMETHEUS_URL:-http://127.0.0.1:9091}"
OUTPUT_ROOT="${OUTPUT_ROOT:-$REPO_ROOT/labs/LAB-013-bash-health-checks-and-evidence-collection/evidence}"

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
BUNDLE_NAME="lab-013-evidence-$TIMESTAMP"
BUNDLE_DIR="$OUTPUT_ROOT/$BUNDLE_NAME"

capture_success=0
capture_failure=0

if ! mkdir -p "$BUNDLE_DIR"/{kubernetes,slurm,prometheus,health}; then
    printf 'ERROR: Unable to create evidence directory\n' >&2
    exit 2
fi

printf 'LAB-013 Incident Evidence Collection\n'
printf 'Timestamp (UTC): %s\n' "$TIMESTAMP"
printf 'Output directory: %s\n\n' "$BUNDLE_DIR"

capture() {
    local output="$1"
    local status
    shift

    if "$@" >"$output" 2>&1; then
        capture_success=$((capture_success + 1))
        printf 'OK: %s\n' "${output#"$BUNDLE_DIR"/}"
    else
        status=$?
        capture_failure=$((capture_failure + 1))

        printf 'Command exited %s: %s\n' \
            "$status" "$*" >>"$output"

        printf 'WARN: %s (exit %s)\n' \
            "${output#"$BUNDLE_DIR"/}" "$status"
    fi
}

printf '=== Kubernetes evidence ===\n'

capture "$BUNDLE_DIR/kubernetes/context.txt" \
    kubectl config current-context

capture "$BUNDLE_DIR/kubernetes/nodes.txt" \
    kubectl get nodes -o wide

capture "$BUNDLE_DIR/kubernetes/pods.txt" \
    kubectl get pods -A -o wide

capture "$BUNDLE_DIR/kubernetes/deployments.txt" \
    kubectl get deployments -A

capture "$BUNDLE_DIR/kubernetes/events.txt" \
    kubectl get events -A \
    --sort-by=.metadata.creationTimestamp

printf '\n=== Slurm evidence ===\n'

capture "$BUNDLE_DIR/slurm/services.txt" \
    systemctl is-active munge slurmctld slurmd

capture "$BUNDLE_DIR/slurm/nodes.txt" \
    sinfo -N -l

capture "$BUNDLE_DIR/slurm/queue.txt" \
    squeue

capture "$BUNDLE_DIR/slurm/node-details.txt" \
    scontrol show nodes

printf '\n=== Prometheus evidence ===\n'

capture "$BUNDLE_DIR/prometheus/readiness.txt" \
    curl --silent --show-error --fail --max-time 5 \
    "${PROMETHEUS_URL%/}/-/ready"

capture "$BUNDLE_DIR/prometheus/alerts.json" \
    curl --silent --show-error --fail --max-time 5 \
    "${PROMETHEUS_URL%/}/api/v1/alerts"

capture "$BUNDLE_DIR/prometheus/rules.json" \
    curl --silent --show-error --fail --max-time 5 \
    "${PROMETHEUS_URL%/}/api/v1/rules"

printf '\n=== Health-check evidence ===\n'

capture "$BUNDLE_DIR/health/health-check.txt" \
    env PROMETHEUS_URL="$PROMETHEUS_URL" \
    "$SCRIPT_DIR/check-infrastructure-health.sh"

printf '\n=== Collection summary ===\n'

if (( capture_failure == 0 )); then
    overall_status="PASS"
else
    overall_status="WARNING"
fi

{
    printf 'LAB-013 Collection Summary\n'
    printf 'Timestamp (UTC): %s\n' "$TIMESTAMP"
    printf 'Successful captures: %d\n' "$capture_success"
    printf 'Failed captures: %d\n' "$capture_failure"
    printf 'Overall status: %s\n' "$overall_status"
} >"$BUNDLE_DIR/summary.txt"

cat "$BUNDLE_DIR/summary.txt"

printf '\n=== Evidence manifest ===\n'

{
    printf 'LAB-013 Incident Evidence Bundle\n'
    printf 'Timestamp (UTC): %s\n' "$TIMESTAMP"
    printf 'Collection host: %s\n' "$(hostname)"
    printf '\nFiles:\n'
    find "$BUNDLE_DIR" -type f \
        -printf '%P\n' | sort
} >"$BUNDLE_DIR/manifest.txt"

printf 'OK: manifest.txt\n'

printf '\n=== Archive creation ===\n'

if ! tar -czf "$OUTPUT_ROOT/$BUNDLE_NAME.tar.gz" \
    -C "$OUTPUT_ROOT" "$BUNDLE_NAME"; then
    printf 'ERROR: Unable to create evidence archive\n' >&2
    exit 2
fi

printf 'PASS: Evidence archive created\n'

printf '\nEvidence directory: %s\n' "$BUNDLE_DIR"
printf 'Evidence archive: %s\n' \
    "$OUTPUT_ROOT/$BUNDLE_NAME.tar.gz"

printf '\nReview evidence for sensitive information before publication.\n'

if (( capture_failure > 0 )); then
    printf 'Collection completed with warnings.\n'
    exit 1
fi

printf 'Collection completed successfully.\n'
exit 0
