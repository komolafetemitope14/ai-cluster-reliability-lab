# LAB-015 — Integrated Reliability Incident Report

## Incident Summary

| Field | Value |
|---|---|
| Scenario ID | LAB-015-SIM-001 |
| Incident title | Simulated Monitoring Connectivity Failure in an AI Compute Environment |
| Classification | Controlled local training exercise |
| Customer | Fictional AI infrastructure customer |
| Environment | Local Ubuntu workstation, kind Kubernetes, Slurm, Prometheus, and Grafana |
| Investigation dates | November 19–20, 2026 |
| Final assessment | Deliberately unreachable diagnostic monitoring endpoint |
| Actual production impact | None established |
| Real Prometheus outage | Not observed |
| Status | Controlled test completed; actual service readiness validated |

## 1. Executive Summary

LAB-015 investigated a fictional customer report of unavailable monitoring information in an AI compute environment.

The exercise integrated Kubernetes diagnostics, Slurm scheduler checks, Prometheus monitoring validation, and existing Bash health-check automation.

Initial infrastructure evidence showed that the Kubernetes control-plane node was Ready, the Slurm controller was responsive, the CPU partition was available, and the monitoring deployments were running.

A controlled failure was introduced by configuring the diagnostic script to query `http://127.0.0.1:19091`, an intentionally unreachable local endpoint.

The script detected the monitoring connectivity failure, returned exit code `1`, and reported six successful checks and one failed check. Kubernetes and Slurm checks remained successful.

Subsequent validation confirmed that the real Prometheus server responded successfully to its HTTP readiness endpoint. The Slurm controller remained UP and the Kubernetes node remained Ready.

**Conclusion:** The observed diagnostic failure was caused by the intentionally unreachable endpoint supplied to the health-check script. The evidence does not support a real Prometheus outage or a Kubernetes or Slurm compute disruption.

## 2. Simulated Customer Report

The fictional customer reported an inability to access expected monitoring information.

The investigation considered several possible failure domains:

- Incorrect or unreachable monitoring endpoint.
- Unavailable Prometheus service.
- Kubernetes infrastructure disruption.
- Slurm scheduler or compute node disruption.

The customer report was a training scenario. No actual customer complaint, production incident, or business impact was observed.

## 3. Environment and Investigation Scope

The investigation used:

- A local kind Kubernetes cluster with context `kind-ai-reliability-lab`.
- A Kubernetes control-plane node named `ai-reliability-lab-control-plane`.
- Slurm 25.11.2 with the `cpu` partition.
- Prometheus 3.5.0 and Grafana 12.1.0.
- The existing LAB-013 Bash infrastructure health-check script.
- Read-only infrastructure commands and a controlled diagnostic endpoint override.

No Kubernetes workloads were deleted, no Slurm services were restarted, and no Prometheus configuration was changed.

The controlled failure affected only the diagnostic request destination.

## 4. Evidence Inventory

All files below contain newly collected LAB-015 diagnostic evidence.

| Evidence file | Description |
|---|---|
| [01-kubernetes-baseline.txt](evidence/01-kubernetes-baseline.txt) | Kubernetes context, cluster connectivity, node readiness, and pod status |
| [02-slurm-baseline.txt](evidence/02-slurm-baseline.txt) | Slurm version, partition, queue, controller, and node state |
| [03-monitoring-baseline.txt](evidence/03-monitoring-baseline.txt) | Monitoring deployments, pods, services, endpoints, and readiness |
| [04-controlled-monitoring-failure.txt](evidence/04-controlled-monitoring-failure.txt) | Deliberately failed monitoring connectivity check and exit code |
| [05-validation-summary.txt](evidence/05-validation-summary.txt) | Actual Prometheus HTTP readiness and infrastructure validation |

The investigation procedure is documented in [investigation-runbook.md](investigation-runbook.md).

## 5. Technical Findings

### 5.1 Kubernetes Baseline

The Kubernetes context was `kind-ai-reliability-lab`.

The control-plane node was Ready, and the Kubernetes API was responsive.

The baseline pod listing showed the monitoring pods running.

**Assessment:** No Kubernetes node outage was identified during baseline collection.

This does not prove that every possible Kubernetes workload or application function was tested.

### 5.2 Slurm Baseline

The Slurm baseline was collected on November 19, 2026.

Observed results included:

- Slurm version: 25.11.2.
- Controller: UP.
- Partition: `cpu`, available.
- Compute node: IDLE.
- Configured CPUs: 2.
- Configured memory: 2 GB.
- Job queue: empty.
- Diagnostic command exit statuses: all `0`.

**Assessment:** The scheduler responded normally and the configured compute node was available.

An empty queue is not evidence of a scheduling failure. No new batch workload was submitted during this capstone, so end-to-end job execution was not independently validated.

### 5.3 Monitoring Baseline

The monitoring baseline showed:

- Prometheus deployment: 1/1 available.
- Grafana deployment: 1/1 available.
- Prometheus pod: Running, zero restarts.
- Grafana pod: Running, zero restarts.
- Prometheus service: ClusterIP on port 9090.
- Grafana service: ClusterIP on port 3000.
- Prometheus endpoint: `10.244.0.22:9090`.

The Kubernetes monitoring checks returned exit code `0`.

**Assessment:** Monitoring resources were available from the Kubernetes control plane's perspective.

Resource availability alone does not establish successful external HTTP access. A separate HTTP readiness validation was therefore required.

### 5.4 Controlled Monitoring Connectivity Failure

At November 20, 2026, 09:37:06 UTC+01:00, the existing health-check script was executed with:

```bash
PROMETHEUS_URL="http://127.0.0.1:19091" \
  bash scripts/bash/lab-013/check-infrastructure-health.sh
```

The endpoint was intentionally unreachable.

The diagnostic reported:

```text
PASS: Kubernetes context: kind-ai-reliability-lab
PASS: All Kubernetes nodes Ready
PASS: Service active: munge
PASS: Service active: slurmctld
PASS: Service active: slurmd
PASS: Slurm node enianyole-ThinkPad-T480: idle
FAIL: Prometheus endpoint unreachable: http://127.0.0.1:19091

Passed checks: 6
Failed checks: 1
Overall status: FAIL
```

The process exited with status `1`, as expected.

**Assessment:** The diagnostic automation correctly identified the unreachable monitoring endpoint while its Kubernetes and Slurm checks passed.

This result does not establish that the real Prometheus service was unavailable.

### 5.5 Actual Prometheus Readiness Validation

At November 20, 2026, 09:39:16 UTC+01:00, the real Prometheus deployment was inspected and its readiness endpoint was queried from inside the Prometheus container.

The HTTP readiness response was:

```text
Prometheus Server is Ready.
```

The command exited with status `0`.

Additional checks confirmed:

- Prometheus deployment: 1/1 available.
- Prometheus pod: Running, zero restarts.
- Slurm controller: UP.
- Kubernetes control-plane node: Ready.
- All recorded validation commands exited with status `0`.

**Assessment:** The actual Prometheus server was ready during validation. Kubernetes and Slurm also remained responsive.

## 6. Investigation Timeline

All timestamps below use UTC+01:00 and come from captured evidence.

| Date and time | Event | Observation |
|---|---|---|
| Nov 19, 2026, 23:51:14 | Kubernetes baseline | Cluster accessible; control-plane node Ready |
| Nov 19, 2026, 23:54:59 | Latest Slurm baseline | Controller UP; CPU node IDLE; queue empty |
| Nov 19, 2026, 23:57:17 | Latest monitoring baseline | Prometheus and Grafana deployments available |
| Nov 20, 2026, 09:37:06 | Controlled failure | Unreachable diagnostic endpoint detected; exit code 1 |
| Nov 20, 2026, 09:39:16 | Validation | Real Prometheus readiness successful; Kubernetes and Slurm healthy |

The timeline represents evidence collection and testing, not the duration of an actual customer outage.

## 7. Failure-Domain Assessment

| Domain | Evidence | Conclusion |
|---|---|---|
| Diagnostic monitoring connectivity | Intentionally unreachable `127.0.0.1:19091`; failed check | Confirmed controlled failure |
| Actual Prometheus service | HTTP readiness succeeded; deployment available | No outage observed during validation |
| Kubernetes infrastructure | Node Ready; checks successful | No node failure observed |
| Slurm scheduler | Controller UP; node IDLE; checks successful | No scheduler failure observed |
| Customer-facing monitoring access | Fictional customer symptom; no external client test | Not independently evaluated |
| End-to-end compute job execution | No capstone job submission | Not independently evaluated |

The evidence supports a failure of the selected diagnostic endpoint, not a broad AI infrastructure outage.

## 8. Root Cause Analysis

### Confirmed Cause of the Controlled Failure

The health-check script was explicitly configured with:

```text
PROMETHEUS_URL=http://127.0.0.1:19091
```

The configured endpoint was unreachable, so the script failed its Prometheus readiness check.

The Bash script was operating as designed: it checked the supplied endpoint and returned a nonzero exit code when that endpoint could not be reached.

**Root cause confidence:** High for the controlled diagnostic failure, because the endpoint override and resulting failure are directly documented.

### What Was Not Established

The investigation did not establish:

- A real Prometheus process or service outage.
- A Kubernetes control-plane or node outage.
- A Slurm scheduler failure.
- A failed customer workload.
- Actual customer or business impact.
- A root cause for any real customer monitoring-access problem.

These claims would require additional evidence beyond this training exercise.

## 9. Recovery and Validation

No infrastructure recovery operation was necessary.

The controlled failure was introduced only through the health-check script's endpoint configuration.

Validation then targeted the actual Prometheus readiness endpoint inside the running deployment and received a successful response.

The exercise therefore demonstrated **diagnostic validation and fault isolation**, not restoration of a failed production service.

## 10. Corrective and Preventive Recommendations

1. **Validate endpoint configuration.** Confirm that monitoring health checks target the intended service address and port.
2. **Separate connectivity from service health.** Distinguish an unreachable client-selected endpoint from an unhealthy Prometheus server.
3. **Preserve failure evidence.** Capture diagnostic output, timestamps, and exit statuses before drawing conclusions.
4. **Cross-check infrastructure domains.** Evaluate Kubernetes and Slurm independently rather than assuming monitoring failure means compute failure.
5. **Use safe, reproducible tests.** Prefer controlled endpoint overrides over intentionally disrupting live services.
6. **Maintain clear customer communications.** Report verified findings, limitations, and next steps without overstating impact.
7. **Expand validation when needed.** For a real incident, test the actual customer access path and relevant workload execution before closing the investigation.

## 11. Limitations

This exercise was conducted on a local CPU-only training environment.

The scenario was fictional and no production customer was affected.

The controlled failure did not change Prometheus configuration or interrupt its service.

The validation demonstrated Prometheus readiness from inside its container; it did not test external customer connectivity to the monitoring interface.

Kubernetes and Slurm checks established observed infrastructure health at the recorded times, but did not provide exhaustive workload-level validation.

Historical evidence from earlier labs may provide supporting examples, but it is not presented as newly collected LAB-015 evidence.

## 12. Final Assessment

**Controlled diagnostic outcome:** PASS — the intentionally unreachable monitoring endpoint was detected.

**Actual Prometheus readiness:** PASS — the server returned a successful readiness response.

**Kubernetes validation:** PASS — the control-plane node remained Ready.

**Slurm validation:** PASS — the controller remained UP.

**Incident classification:** Simulated monitoring connectivity failure, isolated to a deliberately incorrect diagnostic endpoint.

**Customer impact:** No real customer impact established.

**Final conclusion:** The investigation successfully demonstrated safe evidence collection, monitoring failure detection, independent infrastructure validation, and evidence-based failure-domain isolation.
