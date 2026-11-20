# LAB-015 — Integrated AI Infrastructure Reliability Capstone

## Overview

LAB-015 is the final practical exercise in the 15-lab AI Cluster Reliability portfolio.

It integrates Kubernetes infrastructure diagnostics, Slurm workload scheduling, Prometheus and Grafana monitoring, Bash health-check automation, evidence collection, failure-domain analysis, and customer incident communication.

The capstone investigates a simulated monitoring connectivity problem in a local AI compute environment. The exercise demonstrates how to distinguish an unreachable diagnostic endpoint from an actual monitoring service failure or underlying compute infrastructure outage.

**Classification:** Controlled local training exercise — not a production customer incident.

**Scenario ID:** `LAB-015-SIM-001`

**Technical status:** Completed and validated.

## Learning Objectives

The capstone demonstrates the ability to:

1. Establish independent Kubernetes, Slurm, and monitoring baselines.
2. Execute safe, read-only infrastructure diagnostics.
3. Detect a deliberately introduced monitoring connectivity failure.
4. Distinguish endpoint reachability from Prometheus service health.
5. Evaluate Kubernetes and Slurm independently of monitoring symptoms.
6. Preserve timestamps, diagnostic output, and exit statuses.
7. Reuse existing Bash automation rather than duplicate tools.
8. Perform evidence-based failure-domain and root-cause analysis.
9. Validate actual service readiness after a controlled diagnostic failure.
10. Prepare clear internal and customer-facing incident communications.

## Environment

The exercise was conducted on a local Ubuntu ThinkPad T480 without GPU hardware or cloud infrastructure.

| Component | Role |
|---|---|
| Ubuntu Linux | Local engineering workstation |
| kind Kubernetes | Cluster infrastructure and workload diagnostics |
| Slurm 25.11.2 | Scheduler and compute-node diagnostics |
| Prometheus 3.5.0 | Monitoring service and readiness validation |
| Grafana 12.1.0 | Monitoring visualization component |
| Bash | Infrastructure health-check automation |
| Python | Supporting diagnostic automation developed in LAB-012 |
| Git and GitHub | Evidence preservation and portfolio publication |

The investigation reused the existing infrastructure instead of rebuilding or disrupting it.

## Simulated Incident Scenario

**Incident title:** Simulated Monitoring Connectivity Failure in an AI Compute Environment

**Customer:** Fictional AI infrastructure customer

**Reported symptom:** Expected monitoring information is unavailable.

**Potential concern:** Monitoring visibility may be reduced, but the symptom alone does not establish a compute outage.

The investigation considered four distinct failure domains:

- Diagnostic monitoring endpoint configuration and reachability.
- Actual Prometheus service availability.
- Kubernetes infrastructure health.
- Slurm scheduler and compute-node health.

The controlled failure was introduced by directing an existing Bash health-check script to an intentionally unreachable local endpoint.

No live monitoring configuration was changed.

## Safety and Scope

All infrastructure checks were non-destructive.

The exercise did not:

- Delete or recreate the kind cluster.
- Drain Kubernetes nodes or remove workloads.
- Stop or restart Slurm services.
- Modify the Prometheus deployment or configuration.
- Submit disruptive compute workloads.
- Cause a real customer outage.
- Establish actual customer or business impact.

The deliberately failed request was limited to the diagnostic endpoint supplied to the health-check script.

## Deliverables

| File | Purpose |
|---|---|
| [Investigation runbook](investigation-runbook.md) | Repeatable diagnostic procedure and safety rules |
| [Incident report](incident-report.md) | Evidence-based investigation, timeline, root cause, and limitations |
| [Simulated customer update](customer-update.md) | Initial, investigation, and final customer-facing communications |
| [Kubernetes baseline](evidence/01-kubernetes-baseline.txt) | Cluster connectivity, node readiness, and pod status |
| [Slurm baseline](evidence/02-slurm-baseline.txt) | Scheduler, partition, queue, and compute-node state |
| [Monitoring baseline](evidence/03-monitoring-baseline.txt) | Prometheus and Grafana deployments, pods, services, and endpoints |
| [Controlled failure evidence](evidence/04-controlled-monitoring-failure.txt) | Intentionally unreachable endpoint and health-check exit status |
| [Validation evidence](evidence/05-validation-summary.txt) | Actual Prometheus readiness and infrastructure validation |

All nine required LAB-015 files were checked for existence and nonempty content. Local Markdown links passed validation.

## Investigation Methodology

### Phase 1 — Kubernetes Baseline

The investigation confirmed:

- Kubernetes context: `kind-ai-reliability-lab`.
- The Kubernetes API was responsive.
- The control-plane node was Ready.
- Prometheus and Grafana pods were Running.

The baseline did not identify a Kubernetes node outage.

### Phase 2 — Slurm Baseline

Slurm diagnostics confirmed:

- Version: 25.11.2.
- Controller: UP.
- Partition: `cpu`, available.
- Compute node: IDLE.
- Configured resources: 2 CPUs and 2 GB memory.
- Job queue: empty.
- Recorded command exit statuses: all `0`.

The empty job queue was not classified as a scheduler failure.

No new batch job was submitted during this capstone, so end-to-end job execution was not independently tested.

### Phase 3 — Monitoring Baseline

The Kubernetes monitoring checks confirmed:

- Prometheus deployment: 1/1 available.
- Grafana deployment: 1/1 available.
- Prometheus pod: Running, zero restarts.
- Grafana pod: Running, zero restarts.
- Prometheus service: port 9090.
- Grafana service: port 3000.
- Prometheus endpoint: `10.244.0.22:9090`.

These results established Kubernetes resource availability, not external client HTTP connectivity.

### Phase 4 — Controlled Connectivity Failure

The existing LAB-013 health-check script was executed with an intentionally unreachable endpoint:

```bash
PROMETHEUS_URL="http://127.0.0.1:19091" \
  bash scripts/bash/lab-013/check-infrastructure-health.sh
```

Observed results:

| Diagnostic result | Count |
|---|---:|
| Passed checks | 6 |
| Failed checks | 1 |
| Overall status | FAIL |
| Process exit code | 1 |

The failed check was:

```text
FAIL: Prometheus endpoint unreachable: http://127.0.0.1:19091
```

Kubernetes and Slurm checks passed during the same execution.

**Interpretation:** The diagnostic correctly identified the intentionally unreachable endpoint. This was not evidence of a real Prometheus outage.

### Phase 5 — Actual Service Validation

The real Prometheus readiness endpoint was queried from inside the running Prometheus container.

Observed response:

```text
Prometheus Server is Ready.
```

The HTTP readiness command exited with status `0`.

Additional validation confirmed:

- Prometheus deployment: 1/1 available.
- Prometheus pod: Running, zero restarts.
- Slurm controller: UP.
- Kubernetes control-plane node: Ready.
- All recorded validation commands: exit status `0`.

No infrastructure recovery action was necessary.

## Evidence Timeline

All times are UTC+01:00.

| Date and time | Activity | Result |
|---|---|---|
| Nov 19, 2026, 23:51:14 | Kubernetes baseline | Cluster accessible; node Ready |
| Nov 19, 2026, 23:54:59 | Slurm baseline | Controller UP; node IDLE |
| Nov 19, 2026, 23:57:17 | Monitoring baseline | Prometheus and Grafana available |
| Nov 20, 2026, 09:37:06 | Controlled connectivity failure | Expected failure detected; exit code 1 |
| Nov 20, 2026, 09:39:16 | Actual service validation | Prometheus Ready; Kubernetes and Slurm healthy |

These timestamps describe evidence collection, not the duration of a production incident.

## Root Cause and Failure-Domain Assessment

**Confirmed cause of the controlled failure:** The diagnostic script was supplied with an intentionally unreachable Prometheus endpoint.

**Confidence:** High for the controlled diagnostic failure.

The evidence did not establish:

- A real Prometheus service outage.
- A Kubernetes node or control-plane failure.
- A Slurm scheduler failure.
- A failed compute workload.
- An actual customer-facing monitoring access failure.
- Production customer impact.

The real Prometheus server was Ready during validation.

For a real customer incident, further investigation would need to test the customer's actual network and application access path.

## Key Reliability Lessons

1. A failed monitoring connectivity check is not automatically a compute outage.
2. Diagnostic endpoint configuration must be validated before attributing failure to a service.
3. Kubernetes, Slurm, and monitoring health should be assessed independently.
4. Timestamps, command output, and exit codes make investigations reproducible.
5. Controlled failures can test automation without disrupting running infrastructure.
6. Customer communications should distinguish confirmed facts, hypotheses, and limitations.
7. Successful service readiness validation is not the same as production service recovery.

## Existing Automation Reused

The capstone reused:

- `scripts/bash/lab-013/check-infrastructure-health.sh` for infrastructure and monitoring health checks.
- Existing LAB-012 Python diagnostic work as supporting portfolio context.
- Existing monitoring and incident-response lessons from LAB-010 through LAB-014.

No new diagnostic script was necessary for the controlled failure exercise.

Historical evidence from earlier labs is not presented as newly collected LAB-015 evidence.

## Related Labs

This capstone integrates lessons from:

- LAB-008 — Slurm Batch Jobs and Queues.
- LAB-009 — Slurm Failures and Resource Allocation.
- LAB-010 — Prometheus and Grafana Monitoring.
- LAB-011 — Alerting and Observability Troubleshooting.
- LAB-012 — Python Diagnostic Automation.
- LAB-013 — Bash Health Checks and Evidence Collection.
- LAB-014 — Customer Incident Communication and Root Cause Analysis.

Earlier Kubernetes labs provide the cluster troubleshooting foundation.

## Completion Status

**Technical investigation:** Complete.

**Kubernetes, Slurm, and monitoring baselines:** Complete.

**Controlled monitoring failure:** Successfully detected.

**Actual Prometheus readiness validation:** Passed.

**Incident report:** Complete.

**Simulated customer communication:** Complete.

**Required file and local Markdown link validation:** Passed.

**GitHub publication:** Final repository publication and verification are tracked separately.

**Overall conclusion:** LAB-015 successfully demonstrates integrated AI infrastructure reliability investigation, safe fault isolation, evidence-based root-cause assessment, and customer incident communication.

## Skills Demonstrated

- AI infrastructure reliability engineering.
- Kubernetes cluster diagnostics.
- Slurm scheduling and compute-node troubleshooting.
- Prometheus and Grafana monitoring.
- Bash health-check automation.
- Python diagnostic automation foundations.
- Controlled failure testing.
- Infrastructure failure-domain isolation.
- Technical evidence collection and validation.
- Root cause analysis.
- Customer incident communication.
- Operational runbook development.
- Git-based engineering portfolio delivery.
