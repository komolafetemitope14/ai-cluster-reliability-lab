# LAB-015 — Integrated Reliability Investigation Runbook

## Purpose

This runbook documents a safe, repeatable investigation of a simulated monitoring connectivity failure in a local AI infrastructure environment.

It integrates Kubernetes, Slurm, Prometheus, Bash health checks, Python diagnostics, evidence collection, and customer incident communication.

**Scenario:** LAB-015-SIM-001

**Classification:** Controlled local training exercise.

No real customer outage or production infrastructure failure is assumed.

## Safety Rules

All infrastructure commands in this runbook are read-only unless explicitly identified otherwise.

Do not:

- Delete or recreate the Kubernetes cluster.
- Drain or modify Kubernetes nodes.
- Stop, restart, or reconfigure Slurm services.
- Submit disruptive workloads.
- Modify the existing Prometheus installation.
- Treat a failed monitoring check as proof of a compute outage.

The controlled failure must be introduced through a deliberately unreachable monitoring endpoint, not by disrupting infrastructure.

## Phase 1 — Establish the Environment Baseline

### 1.1 Confirm Kubernetes Context

Run:

```bash
kubectl config current-context
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -A
```

Record the observed cluster context, node readiness, and pod status.

If Kubernetes is unavailable, preserve the error and record the limitation rather than recreating the cluster.

### 1.2 Inspect Slurm Health

Run:

```bash
sinfo
squeue
scontrol ping
scontrol show nodes
```

Record scheduler responsiveness, node states, and queued or running jobs.

An empty queue does not indicate a scheduler failure.

If Slurm commands fail, capture their errors and investigate separately.

### 1.3 Inspect Monitoring Resources

Run:

```bash
kubectl get deployments -A
kubectl get services -A
kubectl get pods -A
```

Identify monitoring-related deployments, services, and pods.

Do not assume that a Prometheus endpoint is accessible from the host simply because its Kubernetes pod is running.

## Phase 2 — Inspect Existing Automation

### 2.1 Bash Health Check

Existing script:

```text
scripts/bash/lab-013/check-infrastructure-health.sh
```

Review its usage and configuration before execution.

Confirm whether it accepts a monitoring endpoint override and whether it performs read-only checks.

### 2.2 Bash Evidence Collector

Existing script:

```text
scripts/bash/lab-013/collect-incident-evidence.sh
```

Review its output directory, dependencies, and behavior before execution.

Do not run the collector until its destination and effects are understood.

### 2.3 Python Diagnostic Tool

Existing script:

```text
scripts/python/lab-012/diagnose.py
```

Review supported arguments and output behavior.

Reuse the tool only with documented, safe arguments.

## Phase 3 — Capture Baseline Evidence

Save newly observed infrastructure results under:

```text
labs/LAB-015-integrated-reliability-capstone/evidence/
```

Recommended evidence filenames:

```text
01-kubernetes-baseline.txt
02-slurm-baseline.txt
03-monitoring-baseline.txt
```

Evidence must include the executed command, actual output, and any relevant exit status.

If a component is unavailable, preserve the failure output rather than inventing a healthy result.

## Phase 4 — Controlled Monitoring Failure

### Objective

Demonstrate that a monitoring connectivity diagnostic identifies an intentionally unreachable endpoint.

### Procedure

1. Review the Bash health-check script's accepted configuration.
2. Establish a valid monitoring endpoint when available.
3. Execute the diagnostic against an intentionally unreachable endpoint.
4. Capture the actual output and exit status.
5. Confirm that the failure is limited to the controlled diagnostic configuration.
6. Preserve the result in the evidence directory.

Recommended evidence filename:

```text
04-controlled-monitoring-failure.txt
```

The intentionally unreachable endpoint must not be substituted into live monitoring configuration.

## Phase 5 — Failure-Domain Isolation

Compare the following independently:

| Domain | Evidence required | Interpretation |
|---|---|---|
| Monitoring connectivity | Endpoint response and diagnostic exit code | Determines whether the tested endpoint is reachable |
| Prometheus service | Available readiness or service evidence | Helps assess monitoring service state |
| Kubernetes | Node and pod status | Helps assess container infrastructure health |
| Slurm | Controller, node, and queue status | Helps assess scheduler and compute availability |

A monitoring endpoint failure does not independently establish a Kubernetes or Slurm outage.

Classify each finding as:

- **Confirmed:** Directly supported by collected evidence.
- **Hypothesis:** Plausible but not established.
- **Not evaluated:** Insufficient evidence or unavailable component.

## Phase 6 — Recovery and Validation

Repeat the healthy monitoring check if the intended endpoint is available.

Compare the healthy and deliberately failed outcomes.

Record:

- Endpoint tested.
- Observed result.
- Diagnostic exit status.
- Relevant infrastructure baseline.
- Any remaining limitations.

Do not claim production service restoration.

Recommended evidence filename:

```text
05-validation-summary.txt
```

## Phase 7 — Incident Analysis

Create:

```text
incident-report.md
```

Include:

1. Executive summary.
2. Simulated customer symptom.
3. Investigation scope.
4. Evidence inventory.
5. Technical observations.
6. Incident timeline.
7. Failure-domain assessment.
8. Root cause and confidence.
9. Validation outcome.
10. Corrective and preventive recommendations.
11. Investigation limitations.

Only include actual command outputs and observations that have been collected.

## Phase 8 — Customer Communication

Create:

```text
customer-update.md
```

The fictional customer update should:

- Acknowledge the reported monitoring problem.
- Explain verified technical findings.
- Separate monitoring visibility from compute availability.
- Avoid unsupported outage claims.
- State validation results and remaining uncertainty.
- Summarize appropriate next steps.

Label the document as a simulation.

## Existing Supporting Evidence

Previous labs provide supporting examples:

- LAB-010: Prometheus and Grafana monitoring screenshots.
- LAB-011: Alerting and monitoring health evidence.
- LAB-012: Python baseline, failure, and test evidence.
- LAB-013: Bash healthy checks, controlled failure, and automated tests.
- LAB-014: Incident timeline, root cause analysis, and customer communications.

Historical evidence is useful for comparison but must not be presented as newly collected LAB-015 results.

## Completion Checklist

- [ ] Kubernetes baseline captured or limitation recorded.
- [ ] Slurm baseline captured or limitation recorded.
- [ ] Monitoring resources inspected.
- [ ] Existing automation reviewed.
- [ ] Controlled connectivity failure executed safely.
- [ ] Diagnostic output and exit status preserved.
- [ ] Healthy validation performed where possible.
- [ ] Failure domains assessed independently.
- [ ] Incident report completed.
- [ ] Simulated customer update completed.
- [ ] Evidence and Markdown references validated.
- [ ] LAB-015 committed and pushed to GitHub.

## Final Principle

**Observe first, isolate the failure domain, preserve evidence, and communicate only what the evidence supports.**

This runbook is an investigation procedure, not evidence that any particular infrastructure state or outage has occurred.
