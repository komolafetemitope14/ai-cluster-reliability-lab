
# LAB-011: Alerting and Observability Troubleshooting

## Overview

This lab demonstrates a controlled alerting incident using Prometheus in a local Kubernetes environment.

The exercise covers configuring alert rules, validating Prometheus configuration, simulating a failure, investigating an active alert, restoring the healthy configuration, and verifying recovery.

This lab builds on the Prometheus and Grafana monitoring environment deployed in LAB-010.

## Environment

| Component | Configuration |
|---|---|
| Operating system | Ubuntu Linux |
| Kubernetes | kind, Kubernetes v1.34.0 |
| Cluster context | `kind-ai-reliability-lab` |
| Namespace | `monitoring` |
| Prometheus | v3.5.0 |
| Grafana | v12.1.0 |
| Compute | CPU-only local workstation |
| Alert evaluation interval | 30 seconds |
| Alert pending duration | 1 minute |

No GPU hardware or production infrastructure was required.

## Objectives

1. Configure Prometheus alerting rules.
2. Validate rules using `promtool`.
3. Confirm alert health and evaluation state.
4. Trigger a controlled synthetic failure.
5. Observe the transition to the Firing state.
6. Restore the healthy rule configuration.
7. Reload Prometheus without restarting the deployment.
8. Verify recovery and monitoring service health.
9. Automate basic troubleshooting checks.

## Architecture

```text
Local Ubuntu workstation
          |
          v
kind Kubernetes cluster
          |
          v
monitoring namespace
          |
          +-- Prometheus deployment
          |      |
          |      +-- Scrape configuration
          |      +-- Alert rules ConfigMap
          |      +-- Prometheus rule evaluator
          |      +-- HTTP API and /alerts UI
          |
          +-- Grafana deployment
                 |
                 +-- Prometheus datasource
```

Prometheus evaluates alert expressions and exposes their state through its HTTP API and web interface.

Grafana remains available for metrics visualization.

## Alert Rules

Two alert rules were configured.

### PrometheusTargetDown

```yaml
- alert: PrometheusTargetDown
  expr: up == 0
  for: 1m
  labels:
    severity: critical
    lab: lab-011
```

This rule detects a monitored target whose `up` metric is zero for at least one minute.

### Lab011SyntheticFailure

Healthy baseline:

```yaml
- alert: Lab011SyntheticFailure
  expr: vector(0) == 1
  for: 1m
  labels:
    severity: warning
    lab: lab-011
```

The expression evaluates to an empty vector, so the synthetic alert remains inactive.

Controlled failure condition:

```promql
vector(1) == 1
```

This expression produces an active result and allows the alert to transition to Firing after the configured pending duration.

The failure was simulated by temporarily changing the synthetic rule expression. No real Kubernetes workload or monitoring target was intentionally disrupted.

## Incident Scenario

**Scenario:** A monitoring alert begins firing after a controlled failure condition is introduced.

**Impact:** The synthetic warning alert entered the Firing state. The Prometheus and Grafana services remained operational.

**Detection:** The alert was observed using the Prometheus `/api/v1/rules` endpoint.

**Resolution:** The original healthy expression was restored, the updated ConfigMap was propagated into the Prometheus pod, and the Prometheus configuration was reloaded.

## Investigation and Troubleshooting

### 1. Verify monitoring deployment health

```bash
kubectl get deployments -n monitoring
kubectl get pods -n monitoring
```

Both Prometheus and Grafana were observed running with zero pod restarts.

### 2. Validate the alert rules

```bash
kubectl exec -n monitoring deployment/prometheus -- \
  promtool check rules /etc/prometheus/rules/alerts.yml
```

Observed result:

```text
SUCCESS: 2 rules found
```

### 3. Inspect alert states

Prometheus was accessed using a local port-forward:

```bash
kubectl port-forward -n monitoring svc/prometheus 9091:9090
```

Port `9091` was used because local port `9090` was already occupied.

The rule API was queried using:

```bash
curl -fsS http://127.0.0.1:9091/api/v1/rules \
  | python3 -m json.tool
```

During the simulated failure, `Lab011SyntheticFailure` was observed in the `firing` state with rule health `ok`.

### 4. Restore the healthy rule

The synthetic expression was changed back to:

```promql
vector(0) == 1
```

The manifest was applied:

```bash
kubectl apply \
  -f monitoring/lab-011/prometheus-alert-rules.yaml
```

### 5. Investigate ConfigMap propagation delay

After the Kubernetes ConfigMap was updated, the file mounted inside the Prometheus pod initially still contained the previous expression:

```promql
vector(1) == 1
```

This demonstrated that updating a Kubernetes ConfigMap does not necessarily update the corresponding projected volume immediately.

The mounted file was checked using:

```bash
kubectl exec -n monitoring deployment/prometheus -- \
  grep 'expr: vector' /etc/prometheus/rules/alerts.yml
```

The recovery process continued only after the mounted file showed:

```promql
vector(0) == 1
```

### 6. Reload Prometheus

The mounted rules were validated again:

```bash
kubectl exec -n monitoring deployment/prometheus -- \
  promtool check rules /etc/prometheus/rules/alerts.yml
```

Prometheus was reloaded without restarting its pod:

```bash
curl -fsS -X POST http://127.0.0.1:9091/-/reload
```

Readiness was verified:

```bash
curl -fsS http://127.0.0.1:9091/-/ready
```

Observed result:

```text
Prometheus Server is Ready.
```

### 7. Confirm recovery

Immediately after reloading, the alert API temporarily reported rule health as `unknown`, while the synthetic alert still showed `firing`.

After a subsequent evaluation, both alerts were observed as `inactive` with rule health `ok`.

Final monitoring verification showed:

- Prometheus deployment: 1/1 Ready
- Grafana deployment: 1/1 Ready
- Both pods: Running
- Pod restarts: 0

## Automated Health Check

A reusable Bash script is available at:

`../../scripts/monitoring/lab-011/check-alerting-health.sh`

Run it from the repository root:

```bash
./scripts/monitoring/lab-011/check-alerting-health.sh
```

The script verifies:

- Current Kubernetes context
- Monitoring deployment rollout status
- Monitoring pod status
- Prometheus rule syntax
- Restored synthetic alert expression

The script does not independently verify live alert states. For that, use the Prometheus HTTP API.

## Evidence

The `evidence/` directory contains:

| File | Description |
|---|---|
| `01-monitoring-deployments.txt` | Deployment availability |
| `02-monitoring-pods.txt` | Pod health and restart counts |
| `03-prometheus-rule-validation.txt` | `promtool` validation |
| `04-alert-rule-definitions.txt` | Restored alert definitions |
| `05-alert-rules-api.json` | Alert rule API response after recovery |
| `06-prometheus-readiness.txt` | Prometheus readiness response |
| `07-health-check-script.txt` | Automated diagnostic output |

The controlled Firing state was verified in terminal output during the experiment. The saved evidence files primarily document the recovered state.

Screenshots, when available, are stored in `screenshots/`.

## Files

```text
monitoring/lab-011/
  prometheus-alert-rules.yaml
  prometheus-config.yaml
  prometheus-deployment.yaml

scripts/monitoring/lab-011/
  check-alerting-health.sh

labs/LAB-011-alerting-and-observability-troubleshooting/
  README.md
  evidence/
  screenshots/
```

## Key Lessons Learned

1. Alert state and rule health are separate concepts.
2. A syntactically valid rule does not guarantee that the expected alert state has been reached.
3. Kubernetes ConfigMap projected-volume updates can be delayed.
4. Reloading Prometheus before the mounted configuration changes may leave the previous rule active.
5. Prometheus can briefly report rule health as `unknown` immediately after a reload.
6. Alert recovery should be verified through live evaluation results, not only configuration changes.
7. Prometheus configuration reloads can avoid unnecessary pod restarts.

## Limitations

- The failure was synthetic; no real monitoring target outage was generated.
- No Alertmanager integration or notification delivery was tested.
- Prometheus uses ephemeral `emptyDir` storage in this local environment.
- The Kubernetes API server scrape configuration uses legacy Endpoints discovery, which produces a deprecation warning.
- The environment does not include GPU hardware.
- The health-check script does not query live alert state.

## Outcome

**Result: Successful**

The controlled synthetic alert reached Firing, the healthy configuration was restored, and both alert rules returned to Inactive with rule health `ok`.

The monitoring stack remained available, and a reusable diagnostic script was created to support future troubleshooting exercises.

## Next Lab

LAB-012: Python Infrastructure Diagnostic Tool.
