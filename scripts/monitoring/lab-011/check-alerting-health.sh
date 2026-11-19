#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="monitoring"
PROMETHEUS_DEPLOYMENT="prometheus"
GRAFANA_DEPLOYMENT="grafana"
RULES_FILE="/etc/prometheus/rules/alerts.yml"

echo "=========================================="
echo " LAB-011: Alerting Health Check"
echo "=========================================="

echo
echo "[1/5] Checking Kubernetes context"
kubectl config current-context

echo
echo "[2/5] Checking monitoring deployments"
kubectl get deployments -n "$NAMESPACE"

for deployment in "$PROMETHEUS_DEPLOYMENT" "$GRAFANA_DEPLOYMENT"; do
    kubectl rollout status \
        "deployment/$deployment" \
        -n "$NAMESPACE" \
        --timeout=30s
done

echo
echo "[3/5] Checking monitoring pods"
kubectl get pods -n "$NAMESPACE"

echo
echo "[4/5] Validating Prometheus alert rules"
kubectl exec -n "$NAMESPACE" \
    "deployment/$PROMETHEUS_DEPLOYMENT" -- \
    promtool check rules "$RULES_FILE"

echo
echo "[5/5] Checking restored synthetic alert expression"

expression="$(
    kubectl exec -n "$NAMESPACE" \
        "deployment/$PROMETHEUS_DEPLOYMENT" -- \
        grep 'expr: vector' "$RULES_FILE"
)"

echo "$expression"

if [[ "$expression" != *"vector(0) == 1"* ]]; then
    echo "FAIL: Synthetic alert is not in its baseline configuration."
    exit 1
fi

echo
echo "PASS: Monitoring deployments and alert rules verified."
echo "NOTE: This script checks the mounted baseline rule."
echo "      Confirm live alert states through the Prometheus API."
